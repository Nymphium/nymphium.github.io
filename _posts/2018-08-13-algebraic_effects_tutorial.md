---
layout: post
title: Algebraic Effectsであそぼう
tags: [OCaml, Algebraic Effects]
---

<!--orderedfn-->
<!--sectionize on-->

こんにちは､びしょ〜じょです｡

ここしばらく20行/日くらいしかコード書いてません｡
いやもっと少ないかも…｡
いや研究してますんで! いや〜研究もそんなにしてないな…じゃあ何を…

# はじめに
Algebraic effectsとは､2001年くらいに提唱されてから､爆流行らずともにわかに盛り上がりを見せつつある言語機能である｡
極めて雑に説明すると､*継続を取ってこれる例外*である｡
Plotkin氏(またお前か)が代数学的アプローチによる基盤を作り､そこにハンドラが付いてプログラム言語の機能として考えられるようになった｡
ボクの話のうち1〜10割間違っていることは確かなので､誤った情報を一切入れたくない人は[fnref: 1]を読んでください｡

## algebraic effects実装の有名どころ

- [Eff](http://www.eff-lang.org/)

    algebraic effectsを言語機能として初めて設計された言語｡
    MLスタイルのシンタックスでHinder-Milner型推論がある｡

    + impls
        * [matijapretnar/eff](https://github.com/matijapretnar/eff)[label: effinterp]

            OCaml製Effのインタープリタ

        * [athnos-org/eff](https://github.com/atnos-org/eff)

            ScalaのDSLとして実装されている

        * [『Eff Directly in OCaml』](http://okmij.org/ftp/continuations/Eff/)[fnref: 7]

            Oleg氏(またお前か)によるEffを､delimited continuationライブラリを使ってOCamlのDSLとして実装したもの｡
            Effはdelimited continuationをエミュレートできるが､実はEff *を* delimited continuationでエミュレートできることがわかる｡


- [Koka](https://www.microsoft.com/en-us/research/project/koka/)

    MS Researchがやっていってる言語｡
    手続き型っぽいシンタックスと､Row-typesというeffectsが型に滲み出る､さながらモナドみがある型システムを持っている｡

- [multicoreOCaml](https://github.com/ocamllabs/ocaml-multicore)

    OCamlに直接algebraic effects & handlerを追加した方言｡
    continuationがoneshotとなっており､明示的にクローンしないと2回使えない｡
    この"2回使えない"はlinear typeを導入して弾いてほしいが､実際はランタイムエラーである｡

# さっそく試す
algebraic effects界隈ではスタンダードなEff言語を例に見てみる｡


```ocaml
(* effect definition *)
effect Eff : int -> int

let _ =
  handle 3 + perform(* invoke *) (Eff 4) with
  | x -> print_int x (* value handler *)
  | effect (Eff x) k (* continuation *) -> print_int x; k x
```
これを実行すると､`47`という表示が得られる｡
どういうことなんや｡
素直な心を使うと､`(+)`は`int -> int -> int`､`3 + perform (Eff 4)`は`int`､`perform (Eff 4)`も`int`ということが考えられる｡
なるほど`Eff`のシグネチャ`int -> int`は､矢印の左辺がeffectの引数､右辺はcontextのholeの型か｡
`perform`は何??? ……じゃあ`Eff`は`int -> (int eff)`ということにして`perform`は`'a eff -> 'a`でどうだ､これでいいだろう!!!
という感じで推理していくと`4`という表示は`effect (Eff x) k -> print_int x; k x`という箇所で発射されたんじゃないかという感じがある｡
`7`は`x -> print_int x`ですね｡
[前回の記事](/2018/07/19/delimited-continuation%E3%81%AE%E5%A4%8F.html)を読んでもらえると分かるが､`handle e with (handlers)`がdelimiterで
`k`が切り取られた継続になる｡
だいたいそう｡

わかった｡
念のため他の例も見ておこう｡

```ocaml
effect Choose : ('a * 'a) -> 'a

let choose (x, y) = perform (Choose (x, y))

let chooseh f =
  handle f () with
  | x -> x
  | effect (Choose (x, y)) k -> k x; k y

let f () =
  let x = choose (3, 5) in
  print_int x;
  let y = choose (10, 20) in
  print_int y

let _ = chooseh f
```

`3102051020`という表示になる｡
継続を複製してる感ありますね｡

同じ`Choose` effectでも型さえ合ってれば異なる処理が書ける､つまり定義と実装を分けることができるのが特徴となっている｡
ここでHaskellerは｢Freeモナドやんけ!｣となるらしいですがボクはHaskellをやっていってないのでわかりませんでした｡
型だけ定義して､interpretationはユーザに任せるということなので確かに同じようだ｡
そもそもalgebraic effectの*algebraic*は"free *algebra*"から来てるそう[^2]なので､袂を分かつ存在である｡
実際<Effインタプリタ>[ref: effinterp]はFreeモナドを使って実装しているようだ｡

そしていろんなeffectsをいっぺんにハンドルするぜ!

```ocaml
let h = handler
  | x -> x
  | effect (Eff i) k -> k i
  | effect (Choose (x, y)) k -> k x
```

手軽だ｡
HaskellではFreeモナドを発展させたextensible effects[fnref: 3][fnref: 4]といったものが流行っているそうで､
確かにモナドトランスフォーマーガン積みして爆重になるという困難から抜け出せるらしい｡

# 応用
delimited continuationが扱えるうえにCPS的な書き方ではなくdirect-styleで記述できるため､
syntacticにきれいに､バグらず簡単に書ける､というありがたみがある｡
ボクの語彙が少ないので詳細は文献[fnref: 5][fnref: 6]を読んでください｡

# おわりに
また情報量が0になってしまった……!!!



[^1]: Matija Prentar. "An Introduction to Algebraic Effects and Handlers." Electronic Notes in Theoretical Computer Science 319. 2015.
[^2]: Andrej Bauer. "What is algebraic about algebraic effects and handlers?." eprint arXiv:1807.05923. 2018.
[^3]: 快速のExtensible effects  -- モナドとわたしとコモナド https://fumieval.hatenablog.com/entry/2017/08/02/230422
[^4]: Oleg Kiselyov, Amr Sabry, Cameron Swords. "Extensible Effeects: An Alternative to Monad Transformers." ACM SIGPLAN Notices. Vol. 48. No. 12. ACM, 2013.
[^5]: Anderj Bauer, Matija Prentar. "Programming with algebraic effects and handlers." Journal of Logical and Algebraic Methods in Programming, 84(1), pp.108-123.
[^6]: Dolan, Stephen, Spiros Eliopoulos, Daniel Hillerström, Anil Madhavapeddy, K. C. Sivaramakrishnan, Leo White. "Concurrent system programming with effect handlers." International Symposium on Trends in Functional Programming, pp. 98-117. Springer, Cham, 2017.
[^7]: Kiselyov, Oleg, K. C. Sivaramakrishnan. "Eff directly in OCaml." ML Workshop. 2016.
