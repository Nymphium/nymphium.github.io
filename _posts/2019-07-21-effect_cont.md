---
layout: post
title: エフェクト､do､ANF､継続､継続
tags: [continuation, ANF, effects, OCaml, Haskell]
date: 2019-07-21
---

<!--sectionize on-->

こんにちは､びしょ〜じょです｡

修士中間発表終わったのでもう研究しなくてOK!!!!!!!!

# はじめに
突然ですがみなさんエフェクトを発生させていますか｡
ところでエフェクトはどこで発生するのでしょうか｡
あ! とりあえずcall-by-valueでいいですか｡はい｡

エフェクトは値でないexpression､つまり関数呼び出しで発生する､というのはなんとなく分かるんじゃないでしょうか｡
値を使ったり変数を参照したり[^1]するだけでなんかよくわからんことが起きては困る｡

[label:lst:example]
```ocaml:プログラム[ref:lst:example]. 計算エフェクトの発生
let comp () = (print_endline "hello"; 3);;
let f x = x + 5;;

let v = comp () in (* ここで発生 *)
f v
```

ところで計算エフェクトの発生に印を付けたいのですがOCamlでは…｡

# notion of computation
effect-and-type systemを思い出してみましょう｡
なにか`t`型の値を返すが､途中に計算エフェクト`T`が発生する場合､`T t`と書いたりします｡
高カインド型は今回あまり触れないかもしれないですが､念の為Haskellでいきましょう｡
Scalaもあるがエフェクトがどこでも発生させられるので今回はやめておこう｡
自分､ `-XStrict` いいっすか

## 値の取り出しと継続
`T t`から`t`を取り出したいときはどうするんでしょうか｡
そうだね､bind(`(>>=) :: T t -> (t -> T u) -> T u`)だね(プログラム[ref:lst:bind])｡

[label:lst:bind]
```haskell:プログラム[ref:lst:bind]. bind
comp () >>= (\v -> f v) -- わかりやすくeta expansion
```
左辺で計算エフェクトが発生しつつ値が出てきて(`T t`)､値を取り出して(`t`)処理をおこなって値を返す(`T u`)｡
ところでHaskellならdoがありますねえ(プログラム[ref:lst:do])

[label:lst:do]
```haskell:プログラム[ref:lst:do]. do記法
do
  v <- comp (); -- 手続き感を出すためにケツセミコロン
  f v
```
[ref:lst:bind]から[ref:lst:do]への変換はみたまんまで､`do`(の一部)は`>>=`の糖衣構文である｡
ところでこの変換により､bindの右辺が`do`記法における残りの計算部分､つまり**継続**になることが分かる｡
`>>=`でチェインしまくるのがCPSを手で書くことにあたるのに対し､`do`による書き方はCPSをうまく隠蔽しています｡

# A-Normal Form､あるいはMonadic Normal Form
ところでOCamlはエフェクト発生させ放題プランに加入してるのでどこでもエフェクトが発生します(プログラム[ref:lst:effectful])｡

[label:lst:effectful]
```ocaml:プログラム[ref:lst:effectful]. 計算エフェクトの大量発生
let comp () = (print_endline "hello"; 3);;
let f x = x + 5;;

print_int @@ f @@ comp () + comp () (* prints "hello\nhello\n11" *)
```

計算エフェクトがどこで起きるのかよくわかんね〜〜
`e1 e2`のような場合､先に`e2`で発生しうるエフェクトを解消してから､つまり評価をおこなって出てきた値を､`e1`を評価して出てきた関数に渡したい｡
ではexpressionがネストしないような形にしよう(プログラム[ref:lst:anf])｡

[label:lst:anf]
```ocaml:プログラム[ref:lst:anf]. 値を逐一取り出し太郎
let v1 = comp () in
let v2 = comp () in
let v3 = v1 + v2 in
let v4 = f v3 in
print_int v4
```

このような形式は*A-Normal Form*(略してANF)と呼ばれ､`let`の右辺はredexが一つしか無い状態に制限されている｡
それにしてもこれは[ref:lst:do]に近いですねえ｡
MoggiがHaskellのモナドのコンセプトとなる論文[fnref: 3]で計算エフェクトを扱う計算体系として提案しているものは､`let (x : t) <= (e1 : T t) in (e2 : T u)`のように非常にANFに似た形の構文を持っている｡
そしてANFは**Monadic** *Normal Form*ともよばれている[fnref: 4]｡
`>>=`のシグネチャを思い出してみると､`let`をラムダ抽象でエイヤッできることと合わせれば言いたいことが分かる｡

# 受け継がれる`do`の意志と計算エフェクト､そして継続はなぜ現れるのか
時は令和､現在計算エフェクトを扱う機能として代数的効果が爆流行りである<sup>*[要出展]*</sup>｡
いや令和は関係ないんですが､代数的効果という概念の初出が2003年なので､計算機科学においては非常に新しいものである｡
代数的効果とは､計算エフェクトを代数的に扱うような言語機能である｡
代数的に､というのはソレ自体には意味がなく､ただ構造があるだけで…なんたらかんたら…｡
では意味はどこで付くかというと､ハンドラというものによって与えられる｡
代数的や例外というキーワードから､とりあえずOCamlの例外機構を思い出してもらえるとなんとなく分かってもらえるかもしれない｡

Eff[fnref: 5] [fnref: 6]という言語で例を見てみよう(プログラム[ref:lst:eff])｡
[fnref: 5]との構文的な差分として､エフェクトの発生にはわかりやすさのため､慣習的に使われる`#`をつけるようにした｡

[label:lst:eff]
```haskell:プログラム[ref:lst:eff]. Effの例 ([fnref:5]のFig.2より引用､一部改変)
do n <- #get () in
if n < 0 then
  #print "B"
  return -n^2
else
  return n + 1
```

ここで`#get`と`#print`がエフェクトの発生を表している｡
また､[fnref:5]にある通り､`do y <- #op v in c`は`#op(v; y. c)`の糖衣構文となっている｡
つまり`do n <- #get () in e`は`#get((); n. e)`となる｡
おや､`#get((); n. e)`のうち`n. e`は継続じゃないですか､
そして`do`の右辺でエフェクトが発生しているではないか｡
先述のとおり､エフェクトに意味を与えるのはハンドラでした｡
ハンドラでどうにかなる様子を､desugarしながら見てみよう(プログラム[ref:lst:effhandle])｡
[label:lst:effhandle]
```haskell:プログラム[ref:lst:effhandle]. 脱糖&エフェクトのハンドル
handle
  #get((); n.
  if n < 0 then
    #print("B"; _.
    return -n^2)
  else
    return n + 1)
with
| #get((); k) -> k 10
| #print(v; k) -> write_stdout v; k ()
```
このdesugaringを見てみると､エフェクトが`>>=`の左辺､継続が右辺に対応しそうだ｡
Haskellにおける型クラスのようにimplicitに実装が与えられるのではなく､例外発生箇所をハンドラでexplicitにハンドルするというところが異なりますね｡

エフェクトが発生するとハンドラにコントロールが移り､エフェクトの引数がパターンマッチ風に渡る｡
ハンドラでは継続がファーストクラスで使える｡
継続はつまりハンドルされている式の残りの部分なので､継続を実行するとコントロールがハンドラから元の式に戻る｡

エフェクトを扱いたい場合に継続はなぜ現れるのか､分かってきたかもしれません｡
エフェクトに意味を与えるもの(Monadのインスタンス､エフェクトハンドラ)にコントロールが移ったあと､元の式に復帰するためには継続をハンドラに渡して呼んでもらうのがシンプルである｡
そして､`List`モナドとか､非決定計算など､継続が複数回(あるいは末尾位置以外で)呼び出されるのがそもそも計算エフェクトに織り込まれている場合もあり､継続がファーストクラスであることがそもそもエフェクトシステムには必要なのである｡

# 継続からエフェクトへ
## OCaml4.08のbinding operator
OCaml4.08で新たな構文拡張が生まれました｡
詳細はこちらに書いた｡

{% twicard "qiita" https://qiita.com/Nymphium/items/a13ed0fe3461708fe306 %}

簡単にいうと､ただならぬ`let`が定義できる(プログラム[ref:lst:ocamlbinding])｡

[label:lst:ocamlbinding]
```ocaml:プログラム[ref:lst:ocamlbinding]. binding operatorを使ったOptionモナド風
(* val ( let* ) : 'a option -> ('a -> 'b option) -> 'b option *)
let (let*) x k =
  match x with
  | Some v -> k v
  | none   -> none

let return x = Some x

let* x = Some 5 in
return (x + 10)
```

継続が使えるようになったのでeffectfulな計算を手続き的に書けるようになった､という逆の流れである｡
流れは逆であるが､やりたかったのは上記のように*monadic*な`let`である｡

{% twicard "" https://github.com/ocaml/ocaml/pull/1947 %}

=&lt; 4.07までは[ppxによる拡張](https://github.com/janestreet/ppx_let)もあり､非常に期待されていた機能である｡

## `ContT`
継続があれば計算エフェクトを手続き的に書けるのか! ということでcontinuationモナドになんでも突っ込めばいいんじゃないか｡
そこで`ContT` monad transformerです｡
という話を読みました!!!

{% twicard "ContT を使ってコードを綺麗にしよう! - BIGMOON Haskeller's BLOG" https://haskell.e-bigmoon.com/posts/2018/06-26-cont-param.html %}

{% twicard "" https://haskell.jp/blog/posts/2019/fallible.html %}

# おわりに
継続はつよい

エフェクトフルコンピュテーションはおもしろい

DSLの組み立てにも継続がめっちゃ使えるやんみたいな話を書こうと思ったけど別の機会に｡

---

この記事はHERP労働時間に書かれた｡
HERPは本物のcontinuationプログラマーも募集しています｡

{% twicard "" https://www.wantedly.com/projects/334093 %}

<!-- -->
[^1]: 変数の参照もエフェクトとして考えることができるがここでは割愛
[^3]: Moggi, Eugenio. "Notions of computation and monads." Information and computation 93.1 (1991): 55-92.
[^4]: Danvy, Olivier. "A new one-pass transformation into monadic normal form." International Conference on Compiler Construction. Springer, Berlin, Heidelberg, 2003.
[^5]: Pretnar, Matija. "An introduction to algebraic effects and handlers. invited tutorial paper." Electronic Notes in Theoretical Computer Science 319 (2015): 19-35.
[^6]: Eff Programming Language - https://www.eff-lang.org/ こちらの実際のプログラム言語はMLっぽい構文になっているので本文では[fnref: 5] に従う｡
