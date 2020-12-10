---
layout: post
title: 日刊Coroutines(0) ｢コルーチン｣とは何だったのか?
tags: [日刊Coroutines]
---

<!--sectionize on-->
# はじめに
こんにちは､びしょ～じょです｡
コルーチンの話したい発作が出たんで､やらせてください｡

# おさらい
さて､お手元の『n月刊ラムダノートVo.1, No.1』を参照いただきたいんですが､

{% twicard "" https://www.lambdanote.com/collections/n/products/nmonthly-vol-1-no-1-2019 %}

ない人もいらっしゃるんでかいつまんで説明します｡
最初のコルーチンは1963年にConwayらによってもたらされました｡
コンウェイの法則のコンウェイですね｡
どうやらCOBOLの構文解析に使うためにもたらされたようです｡
そしてこのコルーチンは後述のように対称コルーチンで､コルーチンが提唱される論文の数年後に登場する構造化プログラミングと相性が悪いです｡
ちょうど時代の裂け目で面白いですね｡

構造化プログラミングにおいては対称コルーチンが扱いづらいため､非対称コルーチンというものが出てきます｡
昔は"コルーチン"といったら対称コルーチンのことを指していましたが､対称性によって対称コルーチン､非対称コルーチンという分類がおこなわれるようになりました｡
そして今日日非構造化プログラミングはなかなか使われないため対称コルーチンも活躍の機会を失ったため､"コルーチン"といえば現代では非対称コルーチンが真っ先に思い浮かばれます｡

# 対称性による分類
ではこの対称性による分類とはなんでしょうか?
それは､コルーチンスレッドに親子関係がない､つまり caller-callee のような非対称な関係がない(かどうか)です｡

対称コルーチンは､コルーチン間の移動は慣習的に`transfer`という名前の操作1つしか提供されません｡
これは､あるコルーチンスレッドから別のコルーチンに制御を移すという操作です｡
一度制御を移したら戻ってくるという操作は与えられておらず､戻ってきたければまた元いたコルーチンに`transfer`で制御を移す､という運用です｡
コルーチン間の関係は対称的ですね｡

一方非対称コルーチンには､`resume`､`yield`という2つの操作があります｡
これはもはや皆さんも見慣れてますね｡
*親*コルーチンスレッド(あるいはコルーチンではなくメインスレッドなど)は`resume`で*子*スレッドに制御を一旦移します｡
そしてその子スレッドは`yield`で実行を中断し､親スレッドに制御を*戻し*ます｡
たしかに､非対称な関係でやっていってますね｡

# stackfulness による分類
ところで皆さんはいろんなコルーチンに触ってきたと思うんですけど､JavaScriptだと`yield`できるのは`function*`内だけなのにLuaでは色んな所で`coroutine.yield`が使えることに気づいたでしょうか｡
これはコールスタックをまたげるかどうかという違いがあるなとわかるわけですが､(中略)こちらをご覧ください｡

{% twicard "" https://nymphium.github.io/2019/01/27/stackfulness-of-coroutines.html %}

# その他
対称性に関する分類はLuaの作者であるde Mouraらによる[^1]に拠る｡

最近の研究としては､コルーチンにスナップショット機能をつけるというものがある[^2]｡
かんたんに述べると､コルーチンを`resume`すると*ある状態にある*コルーチンが実行されるわけですが､この*ある状態*をコピーする機能である｡
分かってる人にとっては､つまるところmulti-shot continuationということ｡

また､`yield`オペレータ自体に着目した研究もある[^3]｡

# おわりに
さーて予習したし明日[^4]にでも[^1]で定式化されているコルーチンをもつ小さな計算体系のインタプリタでも実装してみようかな｡

[^1]: Moura, Ana Lúcia De, and Roberto Ierusalimschy. "Revisiting coroutines." ACM Transactions on Programming Languages and Systems (TOPLAS) 31.2 (2009): 6.
[^2]: Prokopec, Aleksandar, and Fengyun Liu. "Theory and Practice of Coroutines with Snapshots." European Conference on Object-Oriented Programming (ECOOP) 109. (2018): 3.
[^3]: James, Roshan P., and Amr Saby. "Yield: Mainstream Delimited Continuations." The Workshop on the Theory and Practice of Delimited Continuations (TDPC) 2011.
[^4]: 明日はこの記事の公開日の翌日､とは限らない｡
