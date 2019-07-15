---
layout: post
title: エフェクトと継続から考えるANFとかdoとかOCaml4.08
tags: [continuation, ANF, effects, OCaml, Haskell]
date: 2019-07-15
---

<!--sectionize on-->

こんにちは､びしょ〜じょです｡

最近は修士中間発表しかやってない｡
聴衆は自分の研究内容とは560度くらい違う研究をやってるので0から説明する必要がある｡
制限時間は15分｡
浅く広く話す必要があるのでだいぶエフォートをかけないと研究のおもしろいところまで話せない｡
発表が大成功しても特に500単位降ってくるなどはないが研究室の名前も出るのでそこそこやっておきたい｡
また聞く側に立ったときも上記の通り全く分からん話を浅く広く聞く必要がありしんどい｡
という非常に誰得なうえにパワいれる必要があるので精神的に苦しい｡
しかしこれも発表日になれば開放されるわけですねえ!!
発表スライドをほぼfreezeしたのでOKです!!!!!!!!!

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
Haskellですね｡
他あんまりなかったですね｡
Scalaもあるがエフェクトがどこでも発生させられるのでHaskellでいきましょう｡

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

このような形式は*A-Normal Form*(略してANF)と呼ばれ､関数の引数には変数(値)しかこない[^2]｡
それにしてもこれは[ref:lst:do]に近いですねえ｡
MoggiがHaskellのモナドのコンセプトとなる論文[fnref: 3]で計算エフェクトを扱う計算体系として提案しているものは､`let (x : t) <= (e1 : T t) in (e2 : T u)`のように非常にANFに似た形の構文を持っている｡
そしてANFは**Monadic** *Normal Form*ともよばれている[fnref: 4]｡
`>>=`のシグネチャを思い出してみると､`let`をラムダ抽象でエイヤッできることと合わせれば言いたいことが分かる｡

# 受け継がれる`do`の意思と計算エフェクト
時は令和､現在計算エフェクトを扱う機能として代数的効果が爆流行りである <sup>*[要出展]*</sup>｡


<!-- Effは`do x <- e1; e2`という形をとっている｡ -->


[^1]: 変数の参照もエフェクトとして考えることができるがここでは割愛
[^2]: curried functionは割愛
[^3]: Moggi, Eugenio. "Notions of computation and monads." Information and computation 93.1 (1991): 55-92.
[^4]: Danvy, Olivier. "A new one-pass transformation into monadic normal form." International Conference on Compiler Construction. Springer, Berlin, Heidelberg, 2003.
