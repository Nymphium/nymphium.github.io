---
layout: post
title: 日刊Coroutines(1) 初回は嬉しいASTの定義付き
tags: [日刊Coroutines, coroutines]
---

<!--sectionize on-->

# はじめに
こんにちは､びしょ～じょです｡
さて前回発作が出ちゃってコルーチンの話したんですが､発作に次ぐ発作でコルーチンを持つ体系を考えて実装していきます｡

# コンセプト
今回はコルーチン以外興味ないね(クラウド)なので作りなれたラムダ計算にコルーチンの操作を乗せるだけでいきます｡
具体的には修論[fnref:1]で定義した\\(\lambda_{\mathit{ac}}\\)からコルーチン的な本質だけ抜き出したサブセットを作りましょう｡
今更修論の話するの結構こじらせてる感なくもないですが､コルーチンを持つ体系で扱いやすいものがあんまりないので許してほしい｡

# 構文
ある言語を論じるための皆さんと私の共通の道具として､なにはともあれ構文を用意します｡

```ocaml
(**
 *  n ∈ Numbers
 *  x ∈ Variables
 *  t ::=
 *      | n | x
 *      | let x = t in t
 *      | fun x -> t | t t
 *      | create t | resume t t | yield t
 *      | t b t
 *  b ::= + | - | ...
 *)

type t =
  | Int of int
  | Var of string
  | Let of string * t * t
  | Fun of string * t
  | App of t * t
  | PrimOp of string (* t1 + t2 === App(PrimOp("+"), t1, t2) *)
  | Create of t
  | Resume of t * t
  | Yield of t
```

順当～ですね｡
`create` には関数を渡すのを想定しています｡
ついでに数値を出すと人は論理的だと感じるので､整数と演算ができそうな primitive を適当に突っ込める機構を追加しました｡

# AST builder
ocamlyacc も menhir も 書きたくね～～!! ということで eDSL として書くためのビルディングァーを用意します｡

```ocaml
module Builder = struct
  open struct
    let gensym =
      let x = ref 0 in
      fun () ->
        let () = incr x in
        Printf.sprintf "x%d" !x
    ;;
  end

  let int v = Int v
  let var x = Var x

  let fn f : t =
    let x = var @@ gensym () in
    f x
  ;;

  let ( let@ ) v k =
    let x = gensym () in
    Let (x, v, k @@ var x)
  ;;

  let ( @ ) f a = App (f, a)
  let prim s = PrimOp s
  let create f = Create f
  let resume co a = Resume (co, a)
  let yield v = Yield v
end
```

`open struct` で `Builder` に signature を書かなくても`gensym`を外から参照できなくしてます｡
これについてはML Advent Calendarの小ネタ枠として書こうかなと思いますが､[fnref:2]を読んでいただければ多分私の駄文をまたなくてよくなります｡
HOASで書けばイージャンみたいなところもありますが､説明すんのもダルいんでナイーブにやっていきます｡

ほいでこんな具合に

```ocaml
let program =
  let open Builder in
  let@ x = int 3 in
  let@ y = int 5 in
  let@ co = create @@ fn @@ fun x' ->
    let@ z = (prim "+" @ x) @ y in
    let@ r = yield z in
    z
  in
  let@ r  = resume co @@ int 2 in
  let@ r' = resume co @@ int 4 in
  r'
```


```ocaml
print_endline @@ show program;;
(** 
 * (Let ("x1", (Int 3),
 *    (Let ("x2", (Int 5),
 *        (Let ("x6",
 *           (Create
 *             (Let ("x4", (App ((App ((PrimOp "+"), (Var "x1"))), (Var "x2"))),
 *                (Let ("x5", (Yield (Var "x4")), (Var "x4")))))),
 *           (Let ("x7", (Resume ((Var "x6"), (Int 2))),
 *             (Let ("x8", (Resume ((Var "x6"), (Int 4))), (Var "x8")))))
 *          ))
 *        ))
 *     ))
 *)
```

ええ感じや｡

# おわりに
焦らない焦らない一休み一休みということで本日はここまで｡

[^1]: [河原悟 『コルーチンを用いた代数的効果の新しい実装方法の提案』 (令和元年度 筑波大学大学院 博士課程 システム情報工学研究科 修士論文)](http://logic.cs.tsukuba.ac.jp/~sat/pdf/master_thesis.pdf)
[^2]: [Li, Runhang, and Jeremy Yallop. Extending OCaml's 'open'."](https://arxiv.org/abs/1905.06543)
