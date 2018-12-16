---
layout: post
title: Asymmetric CoroutinesによるOneshot Algebraic Effectsの実装
tags: [Lua, Coroutines, Algebraic Effects, Advent Calendar]
thumb: true
---

<!--sectionize on-->

こんにちは､びしょ〜じょです｡
これは[言語実装Advent Calendar 2018](https://qiita.com/advent-calendar/2018/lang_dev)の9日目の記事です｡
最初は "変数が全部箱の言語の設計と実装" と題して全部optionにくるまれてる参照とかそういう感じの何かを作ろうとしたけど多分面白くなくなって筆者の熱も醒めると思ったのでやめた｡
またそうこうしてるうちに良い感じのものが作れたので､論理的背景を整理するためにも内容を再考して今回のような内容となりました｡
ほならね早速いってみましょう｡

# はじめに
Algebraic effects and handlers(以降 "algebraic effects" と省略)は､いわば限定継続を取れる例外である｡
try節をdelimiterとし､例外発生位置から残りの計算を限定継続として受け取り､継続をもちいて例外から復帰したり､単に継続を捨てて例外として扱うこともできる｡
最近各所で注目されており､組み込みの言語機能やライブラリとしていくつか提供されている｡
しかし､強力なコントロールオペレータとしての様々な使用が期待される一方､実装はそれほど多くないのが難点である｡

Asymmetric coroutinesは､コントロール抽象化機構の一つであり､ノンプリエンプティブなマルチタスクをおこなうことができる｡
Lua､Rubyなどの言語機能またはライブラリとして提供されており､様々な場面で使うことができる｡
一方コントロールオペレータとして扱うには操作が低級であり､スパゲッティコードになりがちである｡

本稿では､oneshot algebraic effectsからasymmetric coroutinesへの変換､つまり､asymmetric coroutinesによる､継続の使用をワンショットに制限したalgebraic effectsの実装を考える｡
これによりalgebraic effectsをよりカジュアルにあつかえるようになり､さらにasymmetric coroutinesよりも高級なコントロールの操作により､コードを簡潔に書くことが期待される｡

コントロールオペレータとしてのasymmetric coroutinesについて述べ､asymmetric coroutinesとoneshot algebraic effectsとの関係について述べる｡
余力があれば実際に変換を考え､変換を元にした実装を眺める｡
変換の正しさについては証明はないため､読者への課題､あるいは筆者の研究の一環とする｡

本稿の実装はLuaのモジュールとして公開してある｡
お手元にご用意したりして本稿をお楽しみください｡

[label:repo]
{%gh_repo Nymphium/eff.lua%}

# algebraic effects
これについては直近でそこそこ話したので､[あれ]({{ base.url }}/2018/08/13/algebraic_effects_tutorial.html)とか[これ]({{ base.url }}/pdf/mlday2.html)とか[それ](https://qiita.com/Nymphium/items/e6ce580da8b87ded912b)とかをご参照ください｡

## Core Eff
今回は1つのハンドラでハンドルできるエフェクトは1つというCore Effという言語を考える(図[ref:ce-syn])｡
[fnref:1]を参考にした｡

<div>
<center>
[label:ce-syn]
\\[
@importmd(src{{page.id}}/ce-syn.tex)
\\]
図[ref:ce-syn]. the syntax of Core Eff
</center>
</div>

ラムダ計算に`let`が付いて､あとはalgebraic effects関連の項が追加されている｡
`inst ()`でエフェクトインスタンスを生成する｡
エフェクトインスタンスは任意のエフェクト定義に対応する｡
例えば`State`モナドっぽい`State`エフェクトを定義するとなどきに､ハンドラと対応するエフェクトを一意に定められるという点とか各所メリットがある｡
`perform eff e`は引数`e`を渡しエフェクト`eff`を発生する｡
`handler eff vh effh`でエフェクト`eff`のハンドラを定義する｡
`vh`はvalue handlerとなり､ハンドラがエフェクトをハンドルしきって値を返すときにvalue handlerによりハンドルした値を返す｡
`effh`はエフェクトの引数と継続を取る｡

ハンドルできるエフェクトが少ないため一見して弱くなったか? と思うがそんなことはない｡
[fnref:1]ではエフェクトにADTを渡してハンドラ内でさらにパターンマッチする方法で事実上n個のエフェクトをハンルするようにしている｡

意味論に関してはっきりと示せる自信がない(面倒くさいとも言う)のと､後述のように継続の使用回数を制限するので省略します｡
[fnref:2]にあるような､よくあるcall by valueの体系を想定している｡
次の例題で雰囲気を掴んでもらいたい｡

## 例題

```ocaml
let choose = inst () in (* instantiate *)
let lh = handler choose
          (val x -> x)
          (((l, r), k) -> k l) (* choose left *)
in
with lh handle (perform choose (3, 10)) + 5 (* returns `8` *)
```

突然tupleが出てきましたが､純真な心で呼んでみてください｡
`inst ()`が返す値はeffect instancesの中でuniqueならなんでもいい｡
ハンドラ`lh`を定義する｡
エフェクトハンドラ`((l, r), k) -> k l`を見ると､`(l, r)`というtupleを受け取って継続`k`に`l`だけ渡して`r`は捨てる｡

## oneshot algebraic effects
今回はさらに､継続の使用を高々1回に制限する｡
マイナーな言語機能でさらに制限を加えてしまっているが､例えば[Multicore OCaml](http://ocamllabs.io/doc/multicore.html)は原則的に継続の使用は1回に制限されている[^3]｡
例えば次のような例(コード[ref:ng-twice])はNGにしたい｡
continuationを2回使ってはいけない(戒め)｡

[label:ng-twice]
```ocaml:コード[ref:ng-twice]. NG: using *k* twice
let p = inst E in
with (handler p
  (val x  -> x)
  ((x, k) -> print (k (k x)))) (* NG!!! 2回使うな!!! *)
handle 3 + perform (E 3)
```

Affine typesなどにより継続を2回使う箇所を検出したいが､それはまたいつかお話しましょう｡
高級な型システムでなくても､継続に適当な型を付けてdef-use chainを使えばヒューリスティックに解決できそうですね｡

今回は継続を2回以上使ってはいけない*お約束*しかないので誰も注意してくれない｡
そのため我々が注意するしかない｡

継続が1回しか使えないのはmultishot(ノーマルな) algebraic effectsと比較すると真にパワーが弱くなっている｡
とはいえ継続を2回も使う必要のない場面[fnref:4]が多く､継続がワンショットであることを前提にするとパフォーマンスの良い実装ができる[fnref:5][fnref:6]｡

#asymmetric coroutines
## asymmetric?
非常に簡単に説明すると､みなさんがお使いのコルーチンは概ねasymmetric coroutineです｡
Asymmetric coroutineがあるのでsymmetric coroutineももちろん存在する｡
Asymmetric coroutinesは対象のコルーチンへ*飛ぶ*操作resumeと操作してるコルーチンから*戻る*操作yieldの2つを持つ｡
一方symmetric coroutinesはコントロールを移すという唯一の操作controlのみを持ちます(表[ref:tbl-cor])｡

<center>
[label:tbl-cor]
表[ref:tbl-cor]. the comparision of a?symmetric coroutines

|                      | ***a***symmetric coroutines | symmetric coroutines |
|:--------------------:|:----------------------------|:---------------------|
| control manipuration | resume, yield               | conttrol             |
</center>

Asymmetric coroutinesはresumeで呼び出す呼び出し側と､呼び出される側という呼ぶ呼ばれるの関係がコルーチン(とメインスレッド)間にあるのが特徴となっている｡

```lua:example.lua
local co, co2
co = coroutine.create(function()
  coroutine.yield(print("a"))
  coroutine.resume(co2)
  coroutine.yield(print("c"))
  coroutine.resume(co2)
end)

co2 = coroutine.create(function()
  coroutine.yield(print("b"))
  coroutine.resume(co)
  coroutine.yield(print("d"))
end)

coroutine.resume(co)
print(" 1")
coroutine.resume(co)
print(" 2")
coroutine.resume(co)
print(" 3")

--[[ prints
a
 1
b
c
 2
d
 3
--]]
```

なるほど､***完全に理解した***｡

## λ<sub>cor</sub>
Luaだとちょっと大きすぎるし扱いづらいため､変換のための小さな計算体系として\\(\lambda_{\text{\textit{cor}}}\\)を考える(図[ref:lcor-syn])｡

<div>
<center>
[label:lcor-syn]
\\[
@importmd(src{{page.id}}/lcor-syn.tex)
\\]
図[ref:lcor-syn]. the syntax of \\(\lambda_{\text{\textit{cor}}}\\)
</center>
</div>

こちらも筆者が疲れたので意味論はフィーリングで行く｡
すまんが[fnref:7]を参照されたし｡
ランタイムにラベルストアなどを用意してがちゃがちゃやっていく感じ｡

構成員としては､ラムダ計算にくわえ､`let`式､(相互)再帰､ADTとパターンマッチに加え､コルーチンの操作`create` `resume` `yield`がある｡
各エフェクトを一意にするために`inst ()`もそのまま持ってきている｡
小さくなるよう努力したものの､依然としてゴタゴタしているのはひとえに筆者の力不足である｡

ところで上記のプログラムは書けるのだろうか?
https://twitter.com/Nymphium/status/1070882855582986241

変換のターゲットとしてコルーチンが出てくるため､上記のようなプログラムは\\(\lambda_{\text{\textit{cor}}}\\)では書けなくても問題はないので問題ない｡

## asymmetric coroutines and oneshot continuation
Asymmetric coroutinesは強力なコントロールオペレータであり､まずsymmetric coroutinesを模倣することができ､のみならずcall/1ccもasymmetric coroutinesにより実装することができる[fnref:7]｡
call/1ccとは､継続の実行が高々1回に制限されているcall/ccである｡

オッoneshotnessが出てきた｡
これはcontinuationがコルーチンに対応し､コルーチンは状態を複製する操作が基本的に提供されてないためである｡
したがってコルーチンの状態を複製する操作が追加されない限りは､コルーチンで継続をエミュレーションするときは基本的にワンショットである(表[ref:tbl-cont-cor])｡

<center>
[label:tbl-cont-cor]
表[ref:tbl-cont-cor]. the correspondence between continuations and asymmetric coroutines

|                     | continuations      | asymmetric coroutines |
|:--------------------|:-------------------|:----------------------|
| continuation object | function           | coroutine thread      |
| run continuation    | call function      | `resume`              |
| suspend             | waste continuation | `yield`               |
</center>

##!コラム: JavaScriptのgenerator
ES2015からgeneratorというものが追加された｡

```javascript
function* gen() {
  yield 3;
  yield 5;
  return 0;
}

const c = gen()
console.log(c.next()); // { value: 3, done: false }
console.log(c.next()); // { value: 5, done: false }
console.log(c.next()); // { value: 0, done: true }
console.log(c.next()); // { value: undefined, done: true }
```

おっこれはasymmetric coroutineか? と一瞬錯覚するが､実はasymmetric coroutinesよりも表現力が低い｡
理由は簡単､`yield`はgenerator **リテラル**の直下にしか書けないためである｡
つまり以下のようなことがsyntacticに書けない｡

```javascript
const yieldf = x => yield x;

function* gen() {
  yieldf(3);
  yieldf(5);
  return 0;
}

/*
const yieldf = x => yield x;
                          ^

SyntaxError: Unexpected identifier
*/
```

筆者の推理としては､(おそらく)asymmetric coroutinesをCPSで表現するのは難しいが､
JSのgeneratorなら多分CPS変換できるので､babelなどによるES2015以前のJSへのコンパイルが可能になるからではないかと考えられる｡

https://twitter.com/Nymphium/status/1069176528032849923

ところで､generatorも(おそらく)状態を複製する操作が用意されてないので､変換先のCPSの継続はワンショットになるはずである｡

# oneshot algebraic effects → asymmetric coroutines
Core Effから\\(\lambda_{\text{\textit{cor}}}\\)への変換､つまり言語Aから言語Bへの変換なのでコンパイルですね｡本稿の変換の実装はすなわちコンパイラになります｡
言語実装アドベントカレンダーにふさわしいですね｡
本稿では変換の実装はしないので読者の課題あるいは筆者の研究の一環です｡

## 直感的な対応
筆者は直観で実装してしまったので､とりあえず直感的なところからかためていく｡
方針としてはこんな感じになるだろうか(表[ref:tbl-aeac]).

<center>
[label:tbl-aeac]
表[ref:tbl-aeac]. the intuitional correspondence between (oneshot ) algebraic effects and asymmetric coroutines

| (oneshot) algebraic effects | asymmetric coroutines |
|:----------------------------|:----------------------|
| handler                     | (`create` & `resume`) |
| perform                     | `yield`               |
| continuation                | coroutine thread      |
| run continuation            | `resume`              |
</center>

ハンドラは対応が取りづらいので曖昧になっている｡
ハンドラの動作を思い出そう｡
エフェクトインスタンス､value handler, effect handlerを受け取ったらthunkを取ってそのthunkをハンドラでハンドルする､という動作である｡
thunk内でエフェクトを発生(`yield`)すると一時停止してハンドラに操作が移ってほしい､とするとthunkをコルーチンでencapsulateして即実行､という流れになる｡
なのでとりあえず`create` & `resume`としてある｡

## 変換
##! 追記20181209
投稿即バグが見つかり泣きました｡
まずは修正前をご覧ください｡
追記suspend

<div>
<center>
[label:conv]
\\[
@importmd(src{{page.id}}/conv.tex)
\\]
図[ref:conv]. the conversion \\(\left[\left[e_{ce}\right]\right] = e_{\lambda_{\textit{cor}}}\\)
</center>
</div>

***`handler`長すぎんじゃボケー!!!***
ただの実装やろがい!!!
散々引っ張っておいて大変申し訳無いが､今の所スッキリできそうにないので勘弁してもらいたい｡
さらに見返してみるとなんだか洗練されてない｡
もう少しCPSっぽく書ける部分がたしかにあり､そうすれば末尾呼び出しになって良いことがありそうだが､筆者はCPSで実装を試みたところバグバグになって一回諦めているため､読者への課題としたい｡
CPSにすればvalue handlerを複数使ってしまうのを防ぐための`Val`コンストラクタが不要になるだろう｡

メタの話はこの程度にして､内容を見てみよう｡
`handler`以外はだいたいふ〜んて感じで､`perform`も表[ref:tbl-aeac]でぼんやりと考えたとおりに`yield`に対応している｡

問題は爆発している`handler`である｡
thunkを受け取ってコルーチンを作り､`resume`のラッパーとなっている`continue`を走らせてるので､なるほど`create` & `resume`である｡

`handler`の内部の`handle`が一番仕事してる雰囲気を出している｡
`handle`は`contiue`からのみ呼ばれており､呼び出し時に`resume`の戻り値､つまり`yield`に渡された引数かコルーチンでencapsulateされた関数の戻り値である｡
`Val`以外でコルーチンから戻ってくるものとなると､`yield`は`perform`だから`Eff`だな｡

そして`Eff(eff', v)`の`eff'`がハンドルすべきエフェクト`eff`の場合は`effh`によって処理をおこなっている｡
`effh`に渡される第2引数は限定継続であるが､ここでは`continue`をさらにラップして`Val`タグを剥がしている｡
ハンドルしないエフェクトの場合は`UncaughtEff`にエフェクトと継続を渡して**`yield`している**｡
これによって一つ外側のハンドラにエフェクトを飛ばしているのである｡
だからさっき述べた`continue`内の`resume`が返すのは関数の戻り値と`Eff`だけでなく`UncaughtEff`もある｡

では`handle`内で`UncaughtEff`をハンドルしてる部分を見る｡
だいたい同じ要領だが､`effh`に渡している継続は様子がちょっとちがう｡
`UncaughtEff`は継続を一緒にもってくるので､まずこれを走らせる｡
そして継続の戻り値をさらに*現在の*継続に渡して現在の継続を走らせる｡
ハンドルできない`UncaughtEff`の場合も面白い｡
さらに外側のハンドラにエフェクトの処理をまかせたいので同様に`UncaughtEff`を`yield`で飛ばしている｡
ただし`UncaughtEff`に渡している継続は､渡ってきた継続の結果をさらに現在の継続に渡している｡
つまりこれは継続をネストさせている｡
ますますCPSで実装したくなりますね｡
実装に自信ニキはよろしくお願いします｡
脳が発光しますね｡

最後に`Val`が来た場合､中身を剥がしてvalue handlerに突っ込んでいる｡
型がない世界でよかったですね｡

##! 追記20181209 resume
多分これが一番正しいと思います｡

<div>
<center>
[label:conv2]
\\[
@importmd(src{{page.id}}/conv2.tex)
\\]
図[ref:conv2]. the revision of the conversion
</center>
</div>

`handler`だけの変更だが､だいぶダイエットに成功した｡
`Val`タグはそもそも不要だったことがわかった｡
`UncaughtEff`をハンドルしてる部分も様子が変わっている｡
`UncaughtEff`が持ってきた継続をコルーチンでencapsulateして即走らせ､その値を`handle`に渡す､という関数を`effh`に継続として渡している｡
`continue`を見るとだいたい同じことをやっており､encapsulateしない場合コルーチンを突き抜けて`yield`してしまうパターンがあった｡
また現在の継続は`handle`が内部で`continue`を呼んでくれるため､わざわざ`continue`を引っ張る必要はなく､走らせる継続の戻り値は`handle`でハンドルするという元からの考えを使えばいいだけだった｡
操作を継続の中に押し込んでいく感じが､なんとなく`Functor Free`を思わせる｡

追記おわり

#! 追記20181216
さらに大学のゼミ発表などを経てコンパクトになりました｡

<div>
<center>
[label:conv3]
\\[
@importmd(src{{page.id}}/conv3.tex)
\\]
図[ref:conv3]. the conversion v3.
</center>
</div>

[ref:conv2]とは本質的に何も変わってません｡
`continue`を汎用的なものにした｡
これにより､処理がどうなってるかがより簡潔になったんじゃないでしょうか｡
`handle`を連れ回すことで現在のハンドラによるハンドル処理を続けることができる｡
`UncaughtEff`に渡す継続をコルーチンでencapsulateするのは､エフェクトの発生(`yield`)を再びキャッチするためである｡

#実装
それでは改めて<リポジトリ>[ref:repo]の方を見てみよう｡
Asymmetric coroutinesと非常に縁の深いLuaにより実装した｡
本稿で変換を改めて考えるにあたり､バグが複数発見､修正された｡
フィーリングの脆さと簡単なモデルに落として内容をしっかり検討することの重要さを再確認した｡

実装は図[ref:conv]とほとんど同じである｡
なんといっても順番が逆で､実装が先にあり､図[ref:conv]は実装をもとに書き下したためである｡
しかしLuaはclassもADTもないし関数リテラルが冗長､文志向なので`return`必須といろいろしんどいところがあった｡

本稿の変換と異なる点は､ハンドラが多値に対応している点である｡
…というのは半分ウソというか､Multicore OCamlではtupleで表現するところを､tableでガッとやるのではなく可変長引数や多値などといったLuaの持ち味を活かすための細工をおこなった｡
多値を引き回すのは面倒なので､ハンドラに渡ってきた多値をtableに押し込み､実際に使われるタイミングで`unpack`によって多値に戻している｡
この操作のため､effect handlerの引数の順序が`(value, continuation)`から`(continuation, value...)`と逆になっている｡
多値については[こちら]({{base.url}}/2018/11/16/Lua-VMに見る多値の扱い.html)を参照…とおもったけど多値を返す関数の呼び出しをそのまま関数の引数の位置に書いた場合についてはあまりふれられてませんね｡
Lua VM的な説明をすると､引数の末尾位置に多値を返す関数の呼び出しを書かないと､1引数分､つまり1レジスタしか関数の戻り値を受けるレジスタが用意されないためである｡

最初期からフィーリングで突っ走っており､`UncaughtEff`相当のことを､赤ちゃんでも思いつくような､例外処理機によって実装していた｡
OCamlのように代数的な例外がないのも相まって散々な目にあったが､部分的にはalgebraic effectsを実装していた｡
例外のハンドリングは一般にコストフル[^8]であり､Luaもご多分に漏れず遅い｡
コントロールを全てコルーチンの操作だけでおこなった場合と例外でぴょんぴょんする場合のパフォーマンスを比較してみたいが､まぁ半分ナンセンスだし半分は筆者のやる気不足なので､多分速くなってるだろうということで終わる｡

## デモ
皆さん大好き[multiprompt shift/resetが実装できる](https://github.com/Nymphium/eff.lua/blob/master/example/shiftreset.lua)｡
ただしエフェクトハンドラの継続をそのままつかっているので､継続の使用は高々1回に制限されている｡

```lua
local eff = require("eff")
local Eff, perform, handler = eff.Eff, eff.perform, eff.handler

local sr0
do
  local new_prompt = function()
    local Shift0 = Eff("Shift0")

    return {
      take = function(f) return perform(Shift0(f)) end,
      push = handler(Shift0,
        function(v) return v end,
        function(k, f)
          return f(k)
        end)
    }
  end

  local reset_at = function(p, th)
    return p.push(th)
  end

  local shift0_at = function(p, f)
    return p.take(function(k) return f(k) end)
  end

  sr0 = {
    new_prompt = new_prompt,
    reset_at = reset_at,
    shift0_at = shift0_at
  }
end
```

プロンプトごとに`Shift0`エフェクトインスタンスを作っている｡
`handler`がそのまんまdelimiterになってるのがいいよね｡

```lua
local p = sr0.new_prompt()

sr0.reset_at(p, function()
  print(sr0.shift0_at(p, function(k)
     k("Hello")
     print("?")
  end))

  io.write("World")
end)

--[[ prints
Hello
World?
--]]
```

だいぶ自然に書けているんじゃないでしょうか｡

エフェクトの抽象化､実装の分離…[型クラス](https://github.com/Nymphium/eff.lua/blob/master/example/typeclass.lua)か?

```lua
local Map = Eff("Map")

local map = function(f, fa)
  return perform(Map(f, fa))
end

-- list map
local lmaph = handler(Map,
  function(v) return v end,
  function(k, f, fa)
    local newt = {}

    for i, x in ipairs(fa) do
      newt[i] = f(x)
    end

    return k(newt)
  end)

lmaph(function()
  local t = map(function(x) return x * x end, {1, 2, 3, 4, 5})

  for i = 1, #t do
    print(t[i])
  end
end)

-- string map
local smaph = handler(Map,
  function(v) return v end,
  function(k, f, s)
    local news = ""

    for c in s:gmatch(".") do
      news = news .. f(c)
    end

    return k(news)
  end)

smaph(function()
  print(map(function(c) return c .. c end, "hello"))
end)
```

Functorっぽいものを書いてるなと思ったが`smaph`をみると全然そんなことなく､自分でも困惑した｡
Luaは残念ながら型のない世界なのでなんでもアリである｡

# 関連研究
Koka言語などをやっていってるLeijenによりC言語によるalgebraic effectsの実装[fnref:9]がおこなわれている｡
本稿と比較すると1ハンドラ1エフェクトや継続がワンショットなどの制限ががない一方､非常にユーザーアンフレンドリーな構文となっている｡
そのためP言語などのコンパイラのターゲットという位置づけがなされている｡
本稿では式指向の言語での変換をおこなっており､\\(\lambda_{\textit{cor}}\\)相当をサブセットとして持つ言語ならばsyntacticな辛さはない､と思う｡

# おわりに
本稿ではoneshot algebraic effectsからasymmetric coroutinesへの変換を提示した｡
この変換を用いることで､asymmetric coroutinesを持つ言語でoneshot algebraic effectsを使用することが可能になる｡
本稿ではすでにLuaによる実装を与えており､Luaはalgebraic effects-readyな状態となっている｡

ただし本稿の変換の正しさについては証明されていない｡
いまのところ "なんとなくうごいてる" 状態であり､とりあえずテストに[Multicore OCamlのチュートリアル](https://github.com/ocamllabs/ocaml-effects-tutorial)[を実装する](https://github.com/Nymphium/eff.lua/tree/master/test)ことで正しく動いてそうなことを確認している｡
未来のボクや､読者のみなさんに託されています｡
2019年には本稿の変換の証明､あるいは間違った部分の指摘などが湧き出ることを願っている｡

[^1]: Kiselyov, Oleg, and Kc Sivaramakrishnan. "Eff directly in OCaml.(2016)." ACM SIGPLAN Workshop on ML. 2016.
[^2]: Bauer, Andrej, and Matija Pretnar. "Programming with algebraic effects and handlers." Journal of Logical and Algebraic Methods in Programming 84.1 (2015): 108-123.
[^3]: むしろ他に継続がワンショットのalgebraic effectsを知りませんが…｡あとMulticore OCamlには`Obj.clone_continuation`という継続を複製する関数が用意されており､ランタイムにコストを支払うことで継続を2回以上使うことができる｡
[^4]: Dolan, Stephen, et al. "Concurrent system programming with effect handlers." International Symposium on Trends in Functional Programming. Springer, Cham, 2017.
[^5]: Bruggeman, Carl, Oscar Waddell, and R. Kent Dybvig. "Representing control in the presence of one-shot continuations." ACM SIGPLAN Notices. Vol. 31. No. 5. ACM, 1996.
[^6]: Dolan, Stephen, et al. "Effective concurrency through algebraic effects." OCaml Workshop. 2015.
[^7]: Moura, Ana Lúcia De, and Roberto Ierusalimschy. "Revisiting coroutines." ACM Transactions on Programming Languages and Systems (TOPLAS) 31.2 (2009): 6.
[^8]: 例外処理のある言語は概ねモダンであり､モダンな言語は比較的親切であり､親切な言語はエラーを吐くとスタックトレースを出してくれる｡ この新設のためにスタックトレースを記録するので遅くなる｡gotoとしての例外おおいに結構しかしパフォーマンスとしっかり勘案すること｡
[^9]: Leijen, Daan. "Implementing Algebraic Effects in C." Asian Symposium on Programming Languages and Systems. Springer, Cham, 2017.
