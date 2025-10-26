---
layout: post
title: OCaml 5.4のlabeled tuples調査隊 ～名前の力を感じろ～
tags: [OCaml]
---

こんにちは､びしょ～じょです｡

PoE2パッチ0.3のアビサルもエンドゲームTier15到達したら急に飽きました｡
アクトランに関しては､新たに追加されたAct4は島々を船で回る楽しさや(Act3と比較して)移動の簡単さなどでけっこうすき｡
一方結局セケマとアルティメイタムがくだらんすぎるんですわな…｡
というのとアビサルでエグいDotを敷いてブリンクで粘着してくるmodがありえない話し! ブリンクにブリンクで合わせてdotから抜ければいいんだけど大量にmobがいて当たり判定があるんでブリンクアウトも少しむずいため確死があってさぁ～!
でも棘タイタンは面白かったです｡問題点はタイタンというジョブが単純に弱く､vs単体が特に弱いんでアクトボスで10分くらい盾を構えるだけの緊張感のない間延びした戦いを過ごす部分｡
安定感はすごい｡

ということでEscape From Duckovを始めたんですがこれはイイネ｡
本家EFTのPvP(vE)ゆえのスキルツリーやハイドアウト育成テンポの遅さはうまく解消されつつ漁る楽しさや難易度調整によるカジュアルから本家のハラハラまでいろんなプレイヤーに合わせたレンジの広さ､いいですねえ｡
ハイドアウトのチルいBGMも良い｡ あとは本家のようないろんなモーションにリアルサウンドがついてくるとおもろいやろなぁと思いつつもカートゥーン世界観にどれくらい合うんかなとも…現時点ですでにおもろいんでこっからブラッシュアップされて更に神ゲーになると嬉しい｡
確かにこれでPvPもしたいけど､先述のとおり今のテンポ感だと本家以上にギャップのあるマッチが生まれそうなんで､難しいね｡

<!-- sectionize on-->

# はじめに
OCaml5.4が最近リリースされた｡

{% twicard "" https://ocaml.org/releases/5.4.0#whats-new %}

今回のリリースでも多くの改善や新機能が追加されたが､本記事ではその中から **labeled tuples** に焦点を当てる｡

[公式ドキュメントはこちら](https://ocaml.org/manual/5.4/labeledtuples.html)

## 最初にネタバレ
ごちゃごちゃ書いていくが､端的に申し上げるとこういったことが書けて嬉しい｡

```ocaml :便利
let analyze_list lst =
  let min = List.fold_left min max_int lst in
  let max = List.fold_left max min_int lst in
  let sum = List.fold_left (+) 0 lst in
  let count = List.length lst in
  let avg =
    if count = 0 then
      0.0
    else float_of_int sum /. float_of_int count
  in
  (~min, ~max, ~avg)

let (~min, ~max, ~avg) = analyze_list [1; 2; 3; 4; 5] in
Printf.printf "Min: %d, Max: %d, Avg: %f\n" min max avg;;
```

関連する値をタプルで返す場面は多い｡
しかし､返ってきたタプルの1番目の要素は何だっけ､2番目は…？と､順序をいちいち覚えたり､ドキュメントを確認したりする必要があったりと､どのアドレスが何を意味するのかパッと分からんことがある｡
かといって､そのためだけにrecordで新たに型を定義するのも少し…｡
というときにlabeled tuplesが役に立つ｡

またADTsの引数にももちろん利用できる｡
特にGADTsを用いて柔軟なinterpreter patternを実装する際､これまでは引数にラベルを付けられず､少し可読性に欠けることがあったが､labeled tuplesでエレガントに表現できる｡

```ocaml
type _ command +=
  | CreateUser : (name:string * age:int) -> user command
  | FindUser : int -> user option command

let interpret : type a. a command -> a = function
  | CreateUser (~name, ~age) -> ...
  | FindUser id -> ... 
```

名前という**追加の意味を値に付けられる**ということですよこれは｡
名前があるって大変うれしいね｡
名前といえばローゼンメイデンで蒼星石さんが名前は何でも良いがついてると嬉しいという内容のシーンが好きなんですが[^2]､今はもう令和か｡

# ふつーのtuplesとの差分を見る
まずは小手調べ｡
基本的な構文とこれまでのunlabeled tuplesとの違いを見ていく｡
お手元のutopを起動して､一緒に試してみてください｡

```ocaml
(* リテラルの確認 *)
# (~x:3, ~y:5);;
- : x:int * y:int = (~x:3, ~y:5)

(* ラベルなしの要素とも混在可能 *)
# (~x:3, "hoge");;
- : x:int * string = (~x:3, "hoge")
```

型が`x:int * y:int`となっており､`int * int`とは区別されている｡

```ocaml :みんなちがってみんないい
# (~x:3, ~y:5) = (3, 5);;
Error: This expression has type 'a * 'b but an expression was expected of type
         x:int * y:int
       A label x was expected
# (~x:3, ~y:5) = (~y:5, ~x:3);;
Error: This expression has type y:'a * x:'b
       but an expression was expected of type x:int * y:int
       Labels y and x do not match
# (~x:3, ~y:5) = (~x:3, ~y:10);;
- : bool = false

(* destructuring assignmentも同様 *)
# let (x, y) = (~x:3, ~y:5);;
Error: This expression has type x:'a * y:'b
       but an expression was expected of type 'c * 'd
       The first tuple element is labeled x,
       but an unlabeled element was expected
# let (~x, ~y: _) = (~x:3, ~y:5);;
val x : int = 3
```

ラベル多相とかsubtypingはなさそう

```ocaml :まあtuplesにもサイズに関してsubtypingないし
# ((~x:3, ~y:5, ~z:10) :> (x:int * y:int));;
Error: Type x:int * y:int * z:int is not a subtype of x:int * y:int
```

当然型名にも束縛できるし多相も使える

```ocaml
# type 'a t = (x:int * y:'a);;
type 'a t = x:int * y:'a

# let f () : int t = (~x:3, ~y:5);;
val f : unit -> int t = <fun>

# f ();;
- : int t = (~x:3, ~y:5)
```

関数の引数にも驚きなく使える

```ocaml
# let g (~x, ~y) = x + y;;
val g : (x:int * y:int) -> int = <fun>
# g @@ f ();;
- : int = 8
```

単なるsyntacticな拡張ではなく､型レベルで組み込まれた新機能ということが分かる｡

# 関数のラベル付き引数と雰囲気似てますが
たしカーニハン｡
ただ明確な違いとしては､ラベル付き引数には順序がない一方､先述のとおりlabeled tuplesにはある｡

```ocaml
(* ラベル付き引数は順不同 *)
# ListLabels.fold_left ~f:(+) ~init:0 [1;2;3];;
- : int = 6
# ListLabels.fold_left [1;2;3] ~init:0 ~f:(+);;
- : int = 6

(* 再掲 *)
# (~x:3, ~y:5) = (~y:5, ~x:3);;
Error: This expression has type y:'a * x:'b
       but an expression was expected of type x:int * y:int
       Labels y and x do not match
```

また､ラベル付き引数の特徴であるオプショナル引数(`?arg`)もlabeled tuplesにはない｡

```ocaml
(* ラベル付き引数のoptional引数 *)
# let f ?(x=0) () = x + x;;
val f : ?x:int -> unit -> int = <fun>
# f ();;
- : int = 0
# f ~x:5 ();;
- : int = 10

(* まあ意味分からんですわな *)
# let (~x, ?(y=0)) = (~x:3, ~y:None);;
Error: Syntax error
```

[公式マニュアルのlimitationの項](https://ocaml.org/manual/5.4/labeledtuples.html#sss:labledtuples-limitations)にもラベル付き引数との曖昧性に関する言及がある｡
> Parentheses are necessary to disambiguate functions types with labeled arguments from function types with labeled tuple arguments when the first element of the tuple has a label.

あっ逆に関数の引数以外ではカッコ省略できるんだ

```ocaml :そうなんだ
# ~x:3, ~y:5;;
- : x:int * y:int = (~x:3, ~y:5)

(* 関数定義で括弧を省略するとラベル付き引数と解釈されて構文エラー *)
# let h ~x, ~y = x + y;;
Error: Syntax error

(* カッコヨシ! *)
# let h (~x, ~y) = x + y;;
val h : (x:int * y:int) -> int = <fun>
```

# Recordsより使い勝手いいんですかってね
類似の機能にrecordがあるやん｡
Recordsは型-モジュール(名前空間)に束縛されるが､labeled tuplesは自由なところが個人的に大きなポイントに感じる｡

Recordsは基本的に名前がついており[^3]､名前があるということは名前空間に属するということ｡
しかし､labeled tuplesはそうした制約から自由｡定義なしにアドホックに作ることができる｡

```ocaml
(* Recordは型を定義する必要がある *)
# module M = struct
  type t = { x : int; y : int }
end;;
module M : sig type t = { x : int; y : int; } end

(* Recordの名前空間は実は推論してくれるんですが､この文脈では失敗する *)
# let v = { x = 3; y = 5; };;
Error: Unbound record field x

(* ので明示的に名前空間Mを教える *)
# let v = M.{ x = 3; y = 5; };;
val v : M.t = {M.x = 3; y = 5}

(* 一方labeled tuplesは自由に作られる *)
# let v' = (~x: 3, ~y:5);;
val v' : x:int * y:int = (~x:3, ~y:5)

(* 異なるモジュール間でも構造が合っていればOK *)
# module N = struct
    let f () = (~x:3, ~y:5)
end;;
module N : sig val f : unit -> x:int * y:int end
# let (~x, ~y) = N.f ();;
val x : int = 3
val y : int = 5
```

手軽でイイネ｡

一方､recordsのフィールドには順序がないが､先述の通りlabeled tuplesには順序があるなどの取り回しずらさはある｡
加えて､recordsのフィールド省略やprojectionといった操作もない｡

```ocaml
(* おさらいレコード *)
# type t = { x: int; y: int };;
type t = { x : int; y : int; }
# let v = { x = 3; y = 5 };;
val v : t = {x = 3; y = 5}
# v.x;;
- : int = 3
# let { x; _ } = v;;
val x : int = 3

(* ちょっとかゆい使い勝手の悪さ *)
# let v' = (~x:3, ~y:5);;
val v' : x:int * y:int = (~x:3, ~y:5)
# v'.x;;
Error: This expression has type x:int * y:int which is not a record type.

(* あっそういう推論になって型検査が通らなくなるんですね *)
# let (~x, _) = v';;
Error: The value v' has type x:int * y:int
       but an expression was expected of type x:int * 'a
       The first tuple element is labeled y,
       but an unlabeled element was expected
(* なのでこちらはOK *)
# let (~x, ~y:_) = v';;
val x : int = 3
```

ランタイムの表現としてはいずれもn-length arrayなんで同じような操作感だと嬉しいニャンけどねえ
`Obj`で中身を見てみよう｡

```ocaml :ランタイム上は同じ
# let x : int =
  Obj.(repr (~x:3, ~y:5)
       |> Fun.flip field 0
       |> obj) ;;
val x : int = 3

# type t = { x: int; y: int };;
type t = { x : int; y : int; }
# let x : int =
  Obj.(repr { x = 3; y = 5; }
       |> Fun.flip field 0
       |> obj) ;;
val x : int = 3
```
おんなじやおんなじやおもて…この操作の不便さを…変えてほしい…!!

# 総評
器用貧乏だけど入ったことが嬉しいんで､嬉しいね｡
実は順序なしだとpolymorphic variantsで代替できる気がする(互換性は未検証)

```ocaml
# let f () = (`X 3, `Y 5);;
val f : unit -> [> `X of int ] * [> `Y of int ] = <fun>
# let (`X x, `Y y) = f () ;;
val x : int = 3
val y : int = 5
```

まあこっちのがランタイムコストちょっとかさむとか記述量がアレソレとかあるんで､一応優位性はね｡
ただADTsの引数については無名record書けるんやった～w

```ocaml
type _ command +=
  | CreateUser : { name: string; age: int } -> user command
  | FindUser : { id : int } -> user option command
```

まあ関数の戻り値に自然に名前をつけられるのはかなり良い｡

# おわりに
いろんな言語機能が入ると嬉しいです｡嬉しいなあ｡
[Modular explicits](https://github.com/ocaml/ocaml/pull/13275)が5.5に入りそうな気配があったりなかったりするんで､次のリリースも期待大です｡

ここで書く場所がなかったんで供養したい唐突なOCamlトリビア: ocaml/ocamlのtuplesは最大$2^{22}-1$個の要素を持てる[^1]｡

[^1]: <https://ocaml.org/manual/5.4/values.html#ss%3Avalues%3Atuple> さっき知った｡recordsも同じランタイム表現なので2^22-1個のフィールドを持てる
[^2]: 『Rosen Maiden』 Phase 28
[^3]: Variantのフィールドは無名といえば無名だが､variantの名前空間には紐づいてる
