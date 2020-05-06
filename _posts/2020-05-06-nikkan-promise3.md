---
layout: post
title: 日刊Promise(3) スレッドプールっぽいものを作ってsetTimeoutを改修
tags: [日刊Promise, JavaScript]
thumb: true
---

<!--sectionize on-->

# はじめに

こんにちは､びしょ〜じょです｡
"日刊"ですが昨日は神絵師活動のためお休みをいただいたため､ほぼ日になってしまいました｡

今回は､前回の課題であった`setTimeout`がなんかおかしいのを直しました｡
本当は`Promise`までイッキにいきたかったが､もう一発大改修が必要そうだったので今回は諦めました｡

今回も放映した

{% twicard "youtube" https://www.youtube.com/watch?v=D5ZkCvEomm4 %}

ところで中途半端に`Base`を使っていたが､いよいよ`open Base`した｡

# closure
クロージャ実装してなくてﾜﾛﾀなので実装した｡
クロージャというのはですねえ変数環境をclosingしている関数のことです｡

```javascript:fが環境[{name: "x"; value: 3}]をclosingしている
const x = 3;
const f = () => x;
console.log(f()); // ==> 3
```

`let`にした場合(内部的に)reference cellになるので外側から書き換えができますが､今回の実装はJSのサブセットになっており`let`はomitしているので考えません｡

クロージャを実装するために､まず*実行時の値*を定義する｡

```ocaml
(* 確かに環境は束縛されている変数と 実行時の値 のペアのリストですね *)
type env = (variable * runtime_value) list

and runtime_value =
  | RNull
  | RUnit
  | RNum of number
  | RBuiltin of builtin
  | Closure of env * variable list * stmts
```

`Closure` 以外はかなり作者都合によるものですね｡キツい｡
そしてそれらと`value`を相互に変換するための`value_of_rtv`と`rtv_of_value`を定義した｡
後者は関数からクロージャを作るときに環境を注入したいので`env`を同時に受け取る｡

```ocaml
let eval_exp env exp =
  match exp with
  (* Value(Var(x)) -> lookup x env が要らなくなったんでｳﾚｼ *)
  | Value v -> rtv_of_value v
  ......
  | Call (e1, e2) ->
    let fn = eval_exp env e1 in
    let args = List.map ~f:(eval_exp env) e2 in
    (match fn with
    | Closure (env', xs, body) ->
      let env'' = bind_args xs args @ env' in
      eval_stmts env'' body |> rtv_of_value env''
    ......)
```

closingした環境だけでやっていくので､現在の評価環境は使いません｡

```ocaml
let%test "fun" =
  (**
   * const x = 5;
   * const f = (y) => x + y;
   * const x = 10; // そもそもsyntax errorだが念のため
   * return f(12)
   *)
  let stmts =
    Nlist.from_list
      [ Def ("x", Value (Num 5))
      ; Def
          ( "f"
          , Value
              (Fun
                 ( [ "y" ]
                 , Nlist.from_list [ Return (Op (Add, Value (Var "x"), Value (Var "y"))) ]
                 )) )
      ; Def ("x", Value (Num 10))
      ; Return (Call (Value (Var "f"), [ Value (Num 12) ]))
      ]
  in
  let result = run_program stmts in
  equal_value result @@ Num 17
;;
```

ヨシ!
……そういえば再帰関数が定義できない｡

closingしている環境に関数自身を参照できるようにしなければならない｡
自身が束縛される変数名を持っておく必要もある｡

ま､まあ今回はJSのサブセットなんで再帰関数は実装しないという逃げの一手でいきます｡

`let-rec in`のように環境を作る変数束縛だったらシュッといけたのに……｡

# `setTimeout` をやりなおしましょうーｽﾚﾌﾟっぽいやつ
前回問題として残ったものは`setTimeout`が同期的にsleepするためになんもいいことがない､ということであった｡

では､こうしましょう｡

まずスレッドプールを作る｡
`setTimeout`に渡された関数をスレプに突っ込む｡
nマイクロ秒ずつsleepしてからpending､nマイクロ秒ずつsleepしてからpendingを繰り返す｡
pendingしたらもとの実行に戻る｡
合計して`setTimeout`に渡された時間だけsleepしたら､渡された関数を実行し､終了｡

スレプにツッコまれる"スレッド"は以下の値を返すthunkである｡

```ocaml
type thread_status =
  | Pending of (unit -> thread_status)
  | Done of runtime_value
```

`Pending`にOCamlレベルの関数を渡すことで､いい感じにsleepを走らせられるようにする｡
スレプはこのthunkがツッコまれたキューになっている｡
`Thread_pool`がスレプを実装したモジュールである｡
キュー自体は隠蔽されている｡

前回定義した`builtin`を拡張し､以下のように関数をキューイングする｡

```ocaml
(* 睡眠時間の最小単位 20ms *)
let wait_unit : Float.t = 20. /. 1000.

let rec builtin bin rtvs =
  match bin with
  | SetTimeout ->
    let n = List.nth_exn rtvs 0 |> value_of_rtv |> number_of_value in
    (* やはりカリー化をやめた｡第2引数に関数を受け取る｡ *)
    (match List.nth_exn rtvs 1 with
    (* クロージャが役に立った😃 とりあえず引数は捨てる｡ *)
    | Closure (env, _, stmts) ->
      (* refにつっこむ *)
      let time = ref @@ (Float.of_int n /. 1000.) in
      let () =
        ignore
        @@ Thread_pool.enqueue
        @@
        (* トランポリン化のような形になって面白い｡この関数をスレプに突っ込む｡ *)
        let rec it () =
          (* wait_unit秒sleepする *)
          let () = Unix.sleepf wait_unit in
          (* 最悪19ms余計にsleepするが､精度はそんなに精密である必要はない *)
          let rest = !time -. wait_unit in
          if Float.(rest < 0.)
          then (
            let () = eval_stmts env stmts |> ignore in
            Done RUnit)
          else (
            time := rest;
            Pending it)
        in
        it
      in
      RUnit
    | _ -> failwith "second value of setTimeout should be a function")
  ......
```

スレプからスレッドを1つ取り出して実行し､pendingしたらまたスレプに戻す､という操作を`eval_exp`1回ごとにおこなう｡

```ocaml
and eval_exp env exp =
  let () = Thread_pool.run () |> ignore in
  match exp with
  ......
```

`eval_exp`1回あたりの評価時間を無視しているが､無視している実行時間によりsleepがどんどんズレていくことになるが､まあこの方法では仕方ない｡

`Thread_pool.run`はこんな感じにoptionalに`Done`の持つ値を返す｡

```ocaml
let run () =
  (* キューの先頭を取り出し､ *)
  let top = Queue.dequeue q in
  match top with
  | None -> None
  | Some ts ->
    (match ts with
    | Done rtv -> Some rtv
    (* pendingしていたらそのスレッドを走らせて結果をキューイングする｡ *)
    | Pending thread -> Fn.const None @@ Queue.enqueue q @@ thread ())
;;
```

しかしこれだけだと､

```javascript
setTimeout(() => {
  console.log("world")
}, 500);

console.log("hello");
```

というプログラムを実行したときに､(500/20=)25回も式を評価しないため､`setTimeout`に渡さされた関数が実行されない｡
ではどうするか?

プログラムを実行してから､スレッドプールに入っているスレッドが全て`Done`になるまで走らせれば良いでしょう｡

```ocaml
let run_program stmts =
  let ret = eval_stmts [] stmts in
  let () = Thread_pool.run_all () in
  (* 実行世界から帰るのでとりあえず変換しているが…… *)
  value_of_rtv ret
;;
```

`Thread_pool.run_all`はこんなかんじ

```ocaml
let rec run_all () = if Queue.is_empty q then () else run () |> ignore |> run_all
```

テストしますよーテスト

```ocaml
let%expect_test _ =
  (**
   * const x = 100;
   * setTimeout(() => console.log(x), 2000);
   * console.log(500);
   * setTimeout(() => console.log(40), 500);
   *)
  let stmts =
    Nlist.from_list
      [ Def ("x", Value (Num 100))
      ; Expression
          (Call
             ( Value (Builtin SetTimeout)
             , [ Value (Num 2000)
               ; Value
                   (Fun
                      ( []
                      , Nlist.from_list
                          [ Expression
                              (Call (Value (Builtin ConsoleLog), [ Value (Var "x") ]))
                          ] ))
               ] ))
      ; Expression (Call (Value (Builtin ConsoleLog), [ Value (Num 500) ]))
      ; Expression
          (Call
             ( Value (Builtin SetTimeout)
             , [ Value (Num 500)
               ; Value
                   (Fun
                      ( []
                      , Nlist.from_list
                          [ Expression
                              (Call (Value (Builtin ConsoleLog), [ Value (Num 40) ]))
                          ] ))
               ] ))
      ]
  in
  let () = run_program stmts |> ignore in
  [%expect {|
    500
    40
    100
    |}]
;;
```

標準出力のテストのために[`ppx_expect`](https://github.com/janestreet/ppx_expect)を使った｡
こいつぁすげえや｡

# Promise､ゆ､友じょ……
スレプできたしもう勢いで`Promise`実装やっちゃうかー!!
と思ったんですがダメそうなことが分かりました｡

`new Promise`が返す実行時の値として`RPromise`を追加します｡
`Promise`がスレプにツッコまれるので､スレッドに対応するUUIDを返す｡
ところでUUIDは内部で`core_kernel`を使っている｡

```ocaml:runtime_repr.ml
and runtime_value =
  ......
  | RPromise of Uuid.t
```

逆にスレプにはスレッドとそれのUUIDのtupleを突っ込む｡
対応するUUIDを返すことで､`await`でスレプから対応するスレッドを一気に走らせられるようにする｡

```ocaml:thread_pool.ml
type t = (Uuid.t * thread_status) Queue.t

let enqueue th =
  let uuid = Uuid.create () in
  let () = Queue.enqueue q (uuid, Pending th) in
  uuid
;;

let wait =
  let rec go th =
    match th () with
    | Pending th' -> go th'
    | Done r -> r
  in
  fun id ->
    let o_th = Queue.find ~f:(fun (id', _) -> Uuid.equal id id') q in
    match o_th with
    | Some (_, ts) ->
      (match ts with
      | Done rtv -> rtv
      | Pending thread -> go thread)
    | None -> failwith "no such id"
;;
```

あとはやるだけ!w
と思ったのですが……

```ocaml:eval_exp
  ......
  | Promise p ->
    (match p with
    | Constructor exp ->
      (match exp with
      | Value (Fun (_, _) as fn) ->
        let exp' = Call (Value fn, [ Value Unit ]) in
        let uuid = Thread_pool.enqueue @@ fun () -> Done (eval_exp env exp') in
        RPromise uuid
      | _ -> failwith "this is not callable object")
    | Wait exp ->
      let rtv = eval_exp env exp in
      (match rtv with
      | RPromise uuid -> Thread_pool.wait uuid
      | _ -> rtv))
```

うまくいかない｡
とりあえず､`Promise(Constructor(-))`に渡されるものが関数ーさらに今回は手抜きで関数*リテラル*に制限しているーの場合にそれをスレッドにしてスレプに突っ込み､対応するUUIDを`RPromise`に包んで実行時の値にして返す｡
`Wait`はそのまま`Thread_pool.wait`のラッパーになっている｡
`Promise`以外を`await`するときはJSと同じようにサッと流す｡
そういえばこのサブセットには配列がないので`Promise(All(-))`はしれっと消した｡

しかしこれではうまくいかない｡
`Wait`がうまくproimiseを待ってくれない｡
これはまあまあ検討がついている｡

JSの`Promise`を思い出してみると､

```javascript
const f = async () => {
  const promise = new Promise(resolve => setTimeout(() => {
    console.log("hello");
    resolve();
  }, 500));
  await promise;
  console.log("world")
}

f();
```

そういえば`resolve`とかいうやつあったな｡
上記のJSプログラムで`resolve`を`setTimeout`内で呼ばないと結構面白い結果が得られる｡
……どうですか? 結果は500ミリ秒の沈黙ののちに`hello`が出力されるのみである｡
`await`は何なのかを思い出してみると､`await`を使わなければ上記のプログラムは以下のように変形できる｡

```javascript
const f = async () => {
  const promise = new Promise(resolve => setTimeout(() => {
    console.log("hello");
    resolve();
  }, 500))
  promise.then(() =>
    console.log("world"));
}

f();
```

まるで`call/cc`だな｡
実際のところは現在のscope内の限定継続を利用しているのだが｡

ふーむ､振り返るまでもなくこのような挙動にはなってない｡
前回は｢statementの残りこそが継続である｣と言ったが､まさにこれを利用すべきで､`Promise`内で`resolve`のようなものを呼んだら"この残りのstatement"を評価すればよい｡

これは次回だな｡
木曜は有給取ってないんですが今って木曜の午前4時……

# おわりに
pending
