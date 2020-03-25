---
layout: post
title: OCaml 4.08のbinding operator
tags: [OCaml]
---

# はじめに
OCaml 4.08よりbinding operatorというものが追加されました｡
[8.24  Binding operators](http://caml.inria.fr/pub/docs/manual-ocaml/manual046.html)

簡単にいうとこんなかんじ

```ocaml
(* val ( let* ) : 'a option -> ('a -> 'b option) -> 'b option *)
let (let*) x k =
  match x with
  | None -> None
  | Some v -> k v
```

そうだね､モナドだね

```haskell:HaskellでMaybeなMonad
-- OCamlっぽく書くと
(>>=) x k =
   case x of
   Nothing -> Nothing
   Just v  -> k v
```

OCamlにはHaskellのような`do`記法がありませんが､binding operatorのおかげで､`x <- e; k`を`let`束縛とほぼ同じ構文で書けるようになる｡***最高***｡

# binding operator
`let`はそもそもこんな感じ

```ocaml
let (x : t) = e1 in (e2 : t')
(*           ||            *)
((fun x -> e2) : t -> t') (e1 : t)
```
これをbinding operatorで実装するとこうなる｡

```ocaml
let (let*) : t -> (t -> t') -> t'
= fun x k -> k x

let* x = e1 in e2
```

`e2`は`x`を受け取って計算をおこなう関数と考えるとスッと入ってくると思います｡
もっと直球でいうと`e2`は`x`がholeになっている**継続**なんですねぇ…｡

# bindしないbinding operator
ただの演算子というか変数なのでどう定義しても怒られない｡

```ocaml
let (let*) = 3
print_int (let*) (* prints 3 *)
```

bindの形で使うと型エラーで怒られる｡

```ocaml
let (let*) = 3
let* x = 5 in x + 4
(*
Line 1, characters 0-4:
Error: The operator let* has type int but it was expected to have type
         'a -> ('b -> 'c) -> 'd
*)
```
実はOCaml4.08.0のコンパイラ/インタプリタではエラーメッセージも改善されたのでどこが間違ってるのかわかりやす〜い
ともかく､binding operatorをbindingの形で使うには第2引数が関数であることが必須のようだ｡

# 継続の利用
listでもうすこし雰囲気を出しますか｡

```ocaml
let (let+) x k = List.(map k x |> flatten)
let return x = [x]

let+ x = [1; 2; 3] in 
let  y = x + 4 in
let  z = y + 5 in
return z
(* int list = [10; 11; 12] *)
```
継続が触れるので`let`のbody部分を何回も走らせられるのがいいよねえ｡

# 継続の利用2
継続が使えるんで何でもできる｡
とりあえずGoのdeferが実装できてしまう｡

```ocaml
(* val ( let*> ) : (unit -> 'a) -> (unit -> 'b) -> 'a *)
let (let*>) th k = k (); th ()

let*> defer() = print_int 2 in
let*> defer'() = print_int 4 in
print_string "the answer is "
(* prints "the answert is 42" *)
```

bindeeのサンクを受け取り､bodyを先に走らせてあとでbindeeを実行する｡
Goのdeferでこんなんでいいんだっけ､とにかく後処理を登録することができるようになる｡

# 継続の利用3
なんかいろいろ書ける｡

```ocaml
let (let||) (x, y) (k : int -> 'a) : 'a list =
  Array.(make (y - x + 1) 0 |> mapi (fun z _ -> k (x + z)) |> to_list)

let|| x = (1, 10) in x * x
(* int list = [1; 4; 9; 16; 25; 36; 49; 64; 81; 100] *)
```

# おわりに
継続が使えるって最高…｡
