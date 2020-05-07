---
layout: post
title: 日刊Promise(4) 継続モナドで明日への布石
tags: [日刊Promise]
thumb: true
---

<!--sectionize on-->

# はじめに
こんにちは､びしょ〜じょです｡
前回はPromiseの実装に失敗していることが明らかになりました｡
そこで今回は､Promiseの実装に必要となる継続モナドの導入をします｡

# 継続? モナド? は? ママ?

継続モナドは実はみんなのママなのですが

{% twicard "The Mother of all Monads" https://www.schoolofhaskell.com/school/to-infinity-and-beyond/pick-of-the-week/the-mother-of-all-monads %}

今回は単純に評価器をCPSにするにあたって継続を渡しまくることになるので､継続モナドを導入して実装をスッキリさせるつもりです｡

evalがCPSとはどういうことかというと､evalがCPSになっているということ……｡
わかりやすい二項演算を例に見てみると､

```ocaml
let rec eval_k : type ans. env -> exp -> (value -> ans) -> ans =
  fun env exp k ->
  match exp with
  ......
  | Op (op, e1, e2) ->
    eval_k env e1 @@ fun v1 ->
    eval_k env e2 @@ fun v2 ->
    binop_k op v1 v2 k
    ......
```

こんな雰囲気｡
若干ゃだるいので､継続モナドを使ってスマートに実装する｡
ここでいう"モナド"とは `>>=` や `return` のある便利な代数構造を指しています｡

継続モナドを導入すると上記のプログラムは

```ocaml
let rec eval : type ans. env -> exp -> (value, ans) Cont.t =
  fun env exp ->
  match exp with
  ......
  | Op (op, e1, e2) ->
    let* v1 = eval env e1 in
    let* v2 = eval env e2 in
    lift @@ binop_k op v1 v2
```

こういう感じで書けるようになることが期待される｡

# `cont.ml` 実装
継続は残りの計算なんですが､型で表すと

```ocaml
type ('hole, 'ans) t = ('hole -> 'ans) -> 'ans
```

計算に穴(`'hole`)が空いており､それに何か値を渡すと残りの計算(`'hole -> 'ans`)が走って実行結果(`'ans`)が返ってくる､と読める｡

あとはやるだけなのでこのようなシグネチャと対応する実装を用意すれ

```ocaml
val ( >>= ) : ('a, 'ans) t -> ('a -> ('b, 'ans) t) -> ('b, 'ans) t
val ( let* ) : ('a, 'ans) t -> ('a -> ('b, 'ans) t) -> ('b, 'ans) t
val return : 'a -> ('a, 'ans) t
val lift : (('a -> 'b) -> 'b) -> ('a, 'b) t
val run : ('a, 'b) t -> ('a -> 'b) -> 'b
val run_identity : ('a, 'a) t -> 'a
```

特に､

```ocaml
let ( >>= ) cont k k' =
  cont
  @@ fun a ->
  let cont' = k a in
  cont' k'
;;
```

加えて､`List.map`も継続バージョンが欲しくなったので追加した｡

```ocaml
module List = struct
  let rec map ~f xs =
    match xs with
    | [] -> return []
    | x :: xs' ->
      let* y = f x in
      let* ys = map ~f xs' in
      return @@ (y :: ys)
  ;;
end
```

一般的な`List.map`とほとんど同じように定義されているのにCPSになっているのが面白い｡
これが抽象化の力である｡

# evalをCPSify
`eval_exp`および`eval_stmts`も､`List.map`と同様に､ちょっと書き換えるだけである｡

```diff
......
+and eval_exp : type ans. env -> exp -> (runtime_value, ans) Cont.t =
+ fun env exp ->
+  let open Cont in
-and eval_exp env exp =
   let () = Thread_pool.run () |> ignore in
   match exp with
+  | Value v -> return @@ rtv_of_value env v
-  | Value v -> rtv_of_value env v
   | Op (op, e1, e2) ->
+    let* v1 = eval_exp env e1 in
+    let* v2 = eval_exp env e2 in
+    return @@ binop op v1 v2
+  | Call (e, es) ->
+    let* fn = eval_exp env e in
+    let* args = Cont.List.map ~f:(eval_exp env) es in
-    let v1 = eval_exp env e1 in
-    let v2 = eval_exp env e2 in
-    binop op v1 v2
-  | Call (e1, e2) ->
-    let fn = eval_exp env e1 in
-    let args = List.map ~f:(eval_exp env) e2 in
     (match fn with
     | Closure (env', xs, body) ->
       let env'' = bind_args xs args @ env' in
......

+and eval_stmts : type ans. env -> stmts -> (runtime_value, ans) Cont.t =
+ fun env stmts ->
+  let open Cont in
-and eval_stmts env stmts =
   match stmts with
   | End stmt ->
     (match stmt with
     | Expression e | Def (_, e) ->
+      let* _ = eval_exp env e in
+      return RUnit
-      let () = eval_exp env e |> ignore in
-      RUnit
     | Return e -> eval_exp env e)
   | Last (stmt, tl) ->
     (match stmt with
     | Expression e ->
+      let* _ = eval_exp env e in
-      let () = eval_exp env e |> ignore in
       eval_stmts env tl
     | Def (x, e) ->
+      let* rtv = eval_exp env e in
+      let env' = (x, rtv) :: env in
-      let env' = (x, eval_exp env e) :: env in
       eval_stmts env' tl
     | Return e -> eval_exp env e)
 ;;
```

answer typeを多相にしたかったので`forall`で型注釈を付けた｡
GADTsやrecord以外でOCamlのプログラムに型注釈を付けたくなる数少ないシーンな気がする｡

実際のところ､あまり変わってないのはとりあえずCPSっぽくしたというだけで本当にやるべきことをやってないからです｡
次やるべきことは､`Promise(Wait(-))`で継続をガバッと取って､前回確認したように`.then`に取ってきた継続を渡して残りの文を1つの大きなpromise objectにするところですね｡

# おわりに
jane streetが`Core.Cont`を用意してくれれば睡眠時間が長くなったんじゃないですか? でも楽しかったからオッケーです!
