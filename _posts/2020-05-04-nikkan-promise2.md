---
layout: post
title: 日刊Promise(2) とりあえずPromiseを置いてけぼりにして評価器を実装する
tags: [日刊Promise, JavaScript]
thumb: true
---

<!--sectionize on-->

# はじめに
こんにちは､びしょ〜じょです｡
昨日の続きから､とりあえず評価器を実装します｡
statement-basedの言語を実装したことがあまりないので､とりあえずPromiseのことを考えずにいきます｡

なんとなく作業を放映したので本当に暇な人しか見ないでください｡絶対に虚無感に襲われてしまいます｡
{% twicard "youtube" https://www.youtube.com/watch?v=Omquszj_SPw %}

# 実装
さっそくやっていく｡

実装の全体はコチラ

{% gh_repo nymphium/acom %}

リポジトリ名のacomは"promise"から連想しました(?)｡

評価器を実装する前に､syntaxにいくつか変更(追加)があったので言及スル｡

```diff:前回からのdiff
-(* non-empty list *)
-type 'a nlist =
-  | Head of 'a
-  | Tail of 'a * 'a nlist
-
```

やっぱりsyntaxを定義するファイルにこれがあるのはウケてまうんで別ファイル(モジュール)に移動した｡

```diff
 type binop =
   | Add
   | Minus
@@ -19,18 +14,24 @@ type variable = string
  * n     ∈ Numebrs
  * x     ∈ Variables
  * v    := n
+ *       | x
  *       | function(x* ) { stmt+ }
+ *       | null
+ *       | ()
  *)
 type value =
   | Num of number
+  | Var of variable
   | Builtin of builtin
+  | Null
+  | Unit
```

変数定義し忘れてワロてまうわ
あと`null`に加えて`unit`を追加しておいた(OCaml脳)｡

ヨシ! いい感じだな｡
では次行ってみよう｡
expressionのevalを実装して､それを呼び出すstatementsのevalを実装という流れ｡

```ocaml
(* val eval_exp : (variable * value) list -> exp -> value *)
let rec eval_exp env exp =
  match exp with
  | Value (Var x) -> lookup x env
  | Value v -> v
  | Op(op, e1, e2) ->
    let v1 = eval_exp env e1 in
    let v2 = eval_exp env e2 in
    binop op v1 v2
```

はいマッチしました｡
この辺は解説するまでもないですね｡
変数がvalueなのはなんかミスったなーまあいいや｡
`binop` 関数は適当に `Add | Mul | Minus` をそれぞれ対応する算術にmapするやつです｡

関数の実装もまあナイーブな実装｡

```ocaml:eval_expつづき
  | Call(e1, e2) ->
    let fn = eval_exp env e1 in
    let args = List.map (eval_exp env) e2 in
    begin match fn with
    | Fun(xs, body) ->
      let env' = bind_args xs args @ env in
      eval_stmts body env'
    | Builtin bin ->
      builtin bin args
    | _ -> failwith "this is not callable object"
    end
```

user-definedな関数と組み込み関数の呼び出しで分岐する｡
`import`とかは今回無いんで関数のボディはトップレベルと同様statement listになっている｡

ジャバスクなんでカリー化はされておらず､引数はexpression listで受け取る｡

`bind_args` は仮引数と実引数をassoc listにして環境に突っ込む関数｡
ジャバスクで引数が足りないときってどうなるんやっけ?
どうせぶっ壊れ言語なので､とりあえず`null`を埋めるようにする｡

```ocaml:bind_argsの実装
let bind_args xs vs =
  let xl, vl = List.(length xs, length vs) in
  List.combine xs @@
    if xl > vl then
       Array.(make (xl - vl) Null |> to_list) @ vs
    else if xl < vl then
        Base.List.take vs xl
      else vs
```

`eval_exp` に戻りますが､

```ocaml:eval_expおわり
  | Promise _ -> failwith "undefined"
```

今回は本丸のpromiseを完全に無視してく男

残りの `eval_stmts` は関数の実装でも利用するので `eval_exp` と相互再帰になっている｡
この実装はstatement listが空の場合を許さない独自実装になっている｡

```ocaml
(* val eval_stmts : stmt Nlist.t -> (variable * value) list -> value *)
and eval_stmts stmts env =
  match stmts with
  | End stmt ->
    begin match stmt with
    | Expression e | Def(_, e) ->
      let _ = eval_exp env e in Unit
    | Return e -> eval_exp env e
    end
```

末尾が`return`の場合にそのexpressionの結果を返し､他はunitを返す｡

```ocaml:eval_stmts続き
  | Last(stmt, tl) ->
    begin match stmt with
    | Expression e ->
      let _ = eval_exp env e in
      eval_stmts tl env
    | Def(x, e) ->
      let env' = (x, eval_exp env e) :: env in
      eval_stmts tl env'
    | Return e ->
      eval_exp env e
    end
```

前回は｢`return`使って評価脱出するならCPSじゃなきゃジャン｣とは言ったが､実際のところは続くstatementsが実質continuationになっているため､`Return`の実装では残りのstatementsを捨てれば良い､という気付きがあった｡
statements-basedな言語の実装も､簡単です!

環境はとりあえず外から注入する予定がないんで､適当にラッパーを作っておく｡

```ocaml
let run_program stmts = eval_stmts stmts []
```

# テスト
OCamlでテストといえばOUnitだったと思うんですが､今回は`ppx_inline_test`を使ったる｡

```ocaml
let%test _ =
  (**
   * (setTimeout(5000))(() => {
   *   console.log(100);
   * });
   *)
  let stmts = Nlist.from_list [ 
     Expression(Call(Call(Value(Builtin(SetTimeout)), [Value(Num(5000))]),
       [Value(Fun([], Nlist.from_list [
         Expression(Call(Value(Builtin(ConsoleLog)), [Value(Num(100))]))]))]))]
  in
  let result = run_program stmts in
  result = Unit
```

勝手に`setTimeout`を高階にしたけど特に良いことなかったぜ｡
なんか動いてるっぽいんでヨシ! ですが実際はあまりよくない｡
組み込み関数をどうにかする実装はこちらなんですが､

```ocaml
let builtin bin vs =
  match bin with
  | SetTimeout ->
    let n = coerce_number @@ List.nth vs 0 in
    let () = Unix.sleepf @@ (float_of_int n) /. 1000. in
    (* (f) => { f(); } *)
    Fun(["f"], Nlist.from_list [
      Expression(Call(Value(Var("f")), []))
    ])
  | ConsoleLog ->
    ......
```

なんかちゃうよな……｡
これだと同期的にsleepしてまうんで何か対策を講じたい｡
Lwtかなんか使っちゃいますか? でもそれはちょっと違うじゃないですか｡
睡眠時間を細切れにしてスレッドマネージャが度々問い合わせるみたいな感じでやるか｡
これは次回ということで､今回はこの辺で｡

# おわりに
とりあえず言語の実装の体裁は取れてきたが､肝心のpromiseにはまだまだ届いていません｡
これから私どうなっちゃうの〜〜?
