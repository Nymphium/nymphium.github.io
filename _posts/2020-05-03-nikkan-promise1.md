---
layout: post
title: 日刊Promise(1) 初回は嬉しいASTの定義付き
tags: [JavaScript, Promise, 日刊Promise]
thumb: true
---

<!--sectionize on-->

# はじめに
こんにちは､びしょ〜じょです｡
最近は神絵師になってしまいプログラマ性が薄れてきてマズいので手慣らしになんかやろうと思ってゴールデンウィークなんで脳をしっかり使える知育玩具ということでPromiseを含むJavaScriptのサブセットを実装しようかなと思います(おたく早口)｡

とりあえず勘でやってみようと思います｡

# Promiseはどういった雰囲気でしょうか?

とりあえず勘で進めるんで､勘で考えます｡
Promiseは並行･非同期処理のための機能ですね｡
とりあえずスレッドプールに突っ込んでおけば良いんでしょ､わかるわかる
ｽﾚﾌﾟから1つpromiseをpopして､pendingしたら新たにpopしたあとpendingしたものをpushして､……という感じでいけば良い気がする｡
ヨシ､あとはやるだけだ｡

ここに実装を置いていく｡

{% gh_repo nymphium/acom %}

# 構文

初回なので構文を考えよう｡
具体構文は感心がないんで最後の最後(あるいはやらない)でいいでしょう｡

まずは値から｡

```ocaml
(**
 * n     ∈ Numebrs
 * x     ∈ Variables
 * v    := n
 *       | function(x* ) { stmt+ }
 *)
type number = int
type variable = string

type value =
  | Num of number
  | Fun of variable list * stmt nlist
  | Builtin of builtin
```
毎度何度も`let-in`を書くプログラム言語を作るのも飽きた[^1]のでstatement-list basedな構文にします｡
したがって後述のとおり`return`があるので､インタプリタがCPSになるのがすでに明らかそうですな｡

`builtin`は組み込みの定数を突っ込むスペース｡
とりあえずなんかプログラム動いてる感を出すために`console.log`､promiseが動いてる例を書きやすいために`setTimeout`を持つようにする｡

```ocaml
type builtin =
  | SetTimeout
  | ConsoleLog
```

式はあんまおもんないが

```ocaml
(**
 * exp  := v
 *       | exp op exp
 *       | exp(exp* )
 *       | promise
 *)
and exp =
  | Value of value
  | Op of binop * exp * exp
  | Call of exp * exp list
  | Promise of promise
```

`Promise`は種類を分けるために新たなtypeを定義した｡

```ocaml
and promise =
  | Constructor of exp
  | All of exp nlist
  (* await *)
  | Wait of exp
```

ブン!w

```ocaml
(**
 * stmt := exp
 *       | const x = exp
 *       | return exp
 *)
and stmt =
  | Expression of exp
  | Def of variable * exp
  | Return of exp
```

ところで`'a nlist` はnon-empty listです｡

```ocaml
type 'a nlist =
  | Head of 'a
  | Tail of 'a * 'a nlist
```

# おわりに
まあ今日はこんなところで勘弁しといてやるわ｡
ゴルウィー中にはinterpreter完成させるぞ!!

[^1]: 書くのは飽きてないしむしろジャバスクにも`let-in`入れろというかもうジャバスク書きたないです……
