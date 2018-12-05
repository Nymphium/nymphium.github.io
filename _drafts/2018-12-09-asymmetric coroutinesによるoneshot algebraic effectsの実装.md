---
layout: post
title: Asymmetric CoroutinesによるOneshot Algebraic Effectsの実装
tags: [Lua, Coroutines, Algebraic Effects, Advent Calendar]
---

<!--sectionize on-->
<!--orderedfn-->

こんにちは､びしょ〜じょです｡
これは[言語実装Advent Calendar 2018](https://qiita.com/advent-calendar/2018/lang_dev)の9日目の記事です｡
最初は "変数が全部箱の言語の設計と実装" と題して全部optionにくるまれてるとかそういう感じの何かを作ろうとしたけど多分面白くなくなって筆者の熱も醒めると思ったのでやめた｡
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
これについてはそこそこ話しているので､[あれ]({{ base.url }}/2018/08/13/algebraic_effects_tutorial.html)とか[これ](https://qiita.com/Nymphium/items/e6ce580da8b87ded912b)とかをご参照ください｡

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

ハンドルできるエフェクトが少ないため一見して弱くなったか? と思うがそんなことはない｡
[fnref:1]にエフェクトにADTを渡してハンドラ内でさらにパターンマッチする方法で事実上n個のエフェクトをハンルするようにしている｡

## oneshot algebraic effects
今回はさらに､継続の使用を高々1回に制限する｡
マイナーな言語機能でさらに制限を加えてしまっているが､例えば[Multicore OCaml](http://ocamllabs.io/doc/multicore.html)は原則的に継続の使用は1回に制限されている[^2]｡
例えば次のような例(コード[ref:ng-twice])はNGにしたい｡
continuationを2回使ってはいけない(戒め)｡

[label:ng-twice]
```ocaml:コード[ref:ng-twice]. NG:using *k* twice
let p = inst E in
with ( handler p
  (val x  -> x)
  ((x, k) -> print (k (k x)))) (* NG!!! 2回使うな!!! *)
handle 3 + perform (E 3)
```

Affine typesなどにより継続を2回使う箇所を検出したいが､それはまたいつかお話しましょう｡
高級な型システムでなくても､継続に適当な型を付けてdef-use chainを使えばヒューリスティックに解決できそうですね｡

今回は継続を2回以上使ってはいけない*お約束*しかないので誰も注意してくれない｡
そのため我々が注意するしかない｡

継続が1回しか使えないのはmultishot(normal) algebraic effectsと比較すると真にパワーが弱くなっている｡
とはいえ継続を2回も使う必要のない場面が多く､継続がワンショットであることを前提にするとパフォーマンスの良い実装ができる｡

# asymmetric coroutines
## asymmetric?
非常に簡単に説明すると､みなさんがお使いのコルーチンは概ねasymmetric coroutineです｡
Asymmetric coroutineがあるのでsymmetric coroutineももちろん存在する｡
Asymmetric coroutinesは対象のコルーチンへ*飛ぶ*操作resumeと操作してるコルーチンから*戻る*操作yieldの2つを持つ｡
一方symmetric coroutinesはコントロールを移すという唯一の操作controlのみを持ちます(表[ref:tbl-cor])｡

<center>
[label:tbl-cor]
表[ref:tbl-cor]. a?symmetric coroutines 比較

|   -   |  ***a***symmetric coroutines | symmetric coroutines |
| :---: | :--------------------------- | :------------------- |
| control manipuration | resume, yield | conttrol             |
</center>


## as control operator

# 実装
<リポジトリ>[ref:repo]をご覧

## 直感的な対応
| oneshot algebraic effects | asymmetric coroutines |
| :-----------------------  | :-------------------- |
| handler                   | create & resume       |
| perform                   | yield                 |
| (continuation)            | paused coroutine      |

---

[^1]: Kiselyov, Oleg, and Kc Sivaramakrishnan. "Eff directly in OCaml.(2016)." ACM SIGPLAN Workshop on ML. 2016.
[^2]: むしろ他に継続がワンショットのalgebraic effectsを知りませんが…｡あとMulticore OCamlには`Obj.clone_continuation`という継続を複製する関数が用意されており､ランタイムにコストを支払うことで継続を2回以上使うことができる｡
