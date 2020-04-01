---
layout: post
title: Algebraic Effectsの型システム入門
tags: [型システム, Algebraic Effects]
---

# はじめに
Algebraic Effectsは計算エフェクトを扱う言語機能である｡エフェクトとハンドラから成り､エフェクトの発生をハンドラが捕捉し､なんらかの値を返してエフェクト発生部分からの計算を再開する｡エフェクト自体は何もせず､ハンドラが具体的な計算をおこないという部分が重要である｡例えばDependency Injectionにおいては､インターフェースで定義されたメソッドがエフェクトの*定義*､メソッドを呼び出すのがエフェクトの*発生*､インターフェースの具体的な実装が*ハンドラ*､と対応づけることができる｡
[Eff言語](https://www.eff-lang.org)で実際に例をみてみる｡

```ocaml
effect Random : int
```

`Random` というエフェクトを定義した｡このエフェクトを発生させると適当な`int`型の値が得られる｡
そしてハンドラは次のようになる｡

```ocaml
let always_zero = handler
  | effect Random k -> continue k 0
  | val x -> x

let native_random = handler
  | effect Random k ->
    let r = get_random () in (* なんか都合のいいビルトイン関数 *)
    continue k r
  | val x -> x
```

常に`0`を返すハンドラと言語組み込みの乱数生成器を利用するハンドラの2つを用意した｡`effect Random k -> ...` というマッチアームで`Random`エフェクトを捕捉し､`continue k`に値を渡すことで計算を再開する｡`k`ってなんやねんとかは今回は省略する｡計算を再開できるんや｡
そしてハンドラを受け取って計算をおこなう関数を定義する｡

```ocaml
let rand_with h = with h handle
  let x = perform Random in
  let y = perform Random in
  x + y
```

ハンドラが第1級オブジェクトなおかげでハンドラを受け取る関数が書ける｡適当なハンドラが`Random`の発生をキャッチしてくれると計算ができる｡
では実際に使ってみる｡

```ocaml
let () = print_int (rand_with always_zero) (* prints "0" *)
let () = print_int (rand_with native_random) (* prints RANDOM number *)
```

いいですね｡`Random`エフェクトが発生したときにどんな値が返ってくるのかがハンドラによって切り替えられるのがとにかく重要です｡

もう少し丁寧な解説は[こちら](https://nymphium.github.io/2018/10/30/what-is-algebraic-effects.html)を参照されたし｡

# エフェクトの型
ところで`Random`エフェクトが発生すると必ずハンドラに捕捉されるという保証はあるのでしょうか? Javaの`throws HogeException`みたいになってると嬉しいんですが…｡
とりあえずエフェクトが発生した位置の残りの計算部分にエフェクトが発生したことが分かるようにマークを付けてみます｡

```ocaml
let rand_with h = with h handle
  <let x = perform Random in (* 1 *)
  <let y = perform Random in (* 2 *)
   x + y> (* Random(1)が起きた *) > (* Random(2)が起きた *)
```

テキストの限界を感じています､今

`<マークが付けられた計算部分>` といった感じでマークを付けてみました｡幸いにしてEffは式指向な言語なのでearly returnがなく末尾位置の式を見ればどういった値を返すのかが分かります｡返す値にマークが付いているので､`rand_with` は`Random`エフェクトが発生することが分かるようになりました｡したがって `rand_with` 内の計算は `intを返すがRandomが発生する` という型になります｡これを `int!{Random}` と表現しましょう｡


```ocaml
let rand_with h = with h handle
  let x : int!{Random} = perform Random in
  let y : int!{Random} = perform Random in
  (x + y) : int!{Random}
```

では`h`の型は `int!{Random} -> int!{}` とかでしょうか｡`t!{}`は`t`を返しつつ何もエフェクトを発生しないということを表しています｡つまり`{}`というのは**エフェクトの集合**を表すことになります｡Javaの`T throws HogeException, FugaException` というのは`t!{HogeException, HugaException}`といったように表現されます｡ハンドラの型についてはもう少しあとで真面目に考えてみましょう｡

```ocaml
val rand_with : (int!{Random} -> int!{} ...?) -> int!{}
```

## エフェクトいっぱい
とりあえずエフェクトを増やしてみましょう｡

```ocaml
type key = string
type value = int

effect Read : key -> value
effect Write : (key, value) -> unit
```

`(key, value) environment` みたいなデータ構造を仮定して`Read`/`Write`エフェクトを定義しました｡

```ocaml
let env_with h = with h handle
  let x : value!{Read} = perform (Read "x") in
  let y : value!{Read} = perform (Read "y") in
  let () : unit!{Read, Write} = perform (Write ("z", x + y)) in
  (perfofm (Read "z")) : int!{Read, Write}
```

なんか変な型になりましたがこうなってほしいはずです｡4行目に注目してください｡`let`右辺では`Write`エフェクトだけ発生していますが残りの計算部分は`{Read, Write}`になっています｡やりたかったことは式全体の型にエフェクトが発生することを伝搬することだったので､`Write`エフェクトが発生する部分でもそれまでに発生した`Read`エフェクトを引き継いでいるのです｡
サブタイピングのにおいがしますね｡`{}`がtopで､`{定義されているすべてのエフェクト}`がbottomとしてその間にtransitiveなサブタイピング関係がスパッとできそうです｡

```ocaml
val env_with : (int!{Read, Write} -> int!{} ...?) -> int!{}
```

## 多相エフェクト(未完)
難しいので割愛

```ocaml
type 'a option = Some of 'a | None
effect Option : 'a option -> 'a

let with_option th =
  handle th () with
  | effect (Option (Some v)) k -> k v (* `v`の型に関して具体的な操作(`v : int`として `v * 3`とか)はキツいカモ… *)
  | effect (Option None)     _ -> None
  | val v -> v
```

# ハンドラの型
ハンドラは式の型からエフェクトを取り除いていくものと考えられます｡またハンドラにはvalue handlerがあり､関数のように`a -> b`と受け取った値の型を変更することができます｡ではハンドラの型は `a!e => b!e'` としましょう｡ここで`e`と`e'`の間にはサイズに関する関係は定義する必要がありません｡というのもトップレベルで`a!{}`となれば良いわけですから､実はハンドラを適用する前後でエフェクトの集合のサイズは必ずしも縮小していなくていいからです｡
`Random`エフェクトをハンドルするハンドラを思い出してみましょう｡

```ocaml
let always_zero = handler
  | effect Random k -> continue k 0
  | val x -> x

let native_random = handler
  | effect Random k ->
    let r = get_random () in
    continue k r
  | val x -> x
```

これはvalue handlerがidのように受け取った値をそのまま返すので型の変更がありません｡したがってどちらも`'a!{Random} => 'a!{}`と考えられます｡
…いや本当ですか? すべてのハンドラはキャッチできないエフェクトを素通しします｡なので`effect e k -> perform e |> continue k` のようなマッチアームが暗に付属しています｡なのでこのエフェクトをして`'a!({Random} ∪ e) => 'a!e`のようになります｡
ハンドラ内部の型を見てみましょう｡
`continue k`の型は`int -> 'a!e`になります｡`int`は`Random`エフェクトの型に対応し､`'a!e`は *ハンドラ全体の戻り値* と同じになります｡ハンドルされる式と同じ型じゃないんですか? 違います｡`continue k hoge`が表すものは､ハンドルされる式が評価されきって､更に値がvalue handlerに渡されるところまでのコントロールとなります｡なので`continue k hoge`が返す値はvalue handlerの返す値であり､型も同様にvalue handlerの返す値の型になるのです｡value handlerの引数の型は`'a!e`､ボディの型もこの場合は同じく`'a!e`となります｡いい感じですね｡

```ocaml
val always_zero : 'a!({Random} ∪ e) => 'a!e
val native_random : 'a!({Random} ∪ e) => 'a!e
```

`Read`/`Write`エフェクトのハンドラも書いてみます｡

```ocaml
type ('l, 'r) either =
  | Left of 'l
  | Right of 'r

let with_fresh_hash () =
  let env = Hash.new () in (* なんか都合のいいデータ構造 *)
  let () = modify env "x" 4 in
  let () = modify env "y" 7 in
  handler
  | effect (Read key) k ->
    begin
       match lookup key env with
       | Some value -> continue k value
       | None -> Left ("key " ^ key ^ " not found")
    end
  | effect (Write (key, value)) k ->
    let () = modify env key value in continue k ()
  | val x -> Right x
```

まあまあ大きな実装になりました｡環境`env`を作ってclosingしたいので `unit -> (ハンドラ)`という関数の形になっています｡`Hash`のあたりはなんかいい感じに各位読み替えてください｡注目してほしいのは`Read`エフェクトで環境からの読み取りに失敗した場合(`None` マッチアームのところ)で`Left`を返すところです｡今更ですがエフェクトハンドラは計算を再開せずにやめることもできるんや! ということで`Read`エフェクトのハンドルでは`either`型を返してます｡`Random`エフェクトをキャッチしたときのことを思い出してみると､`with_fresh_hash`の返すハンドラの戻り値の型も`either`になってほしいわけです｡value handlerを見てみると､確かに`Right`コンストラクタに`x`を渡しているので`either`です｡ヤッタネ!
`continue k hoge`の型は先程話したとおり､value handlerの返す型と同じになります｡なので`Read`に成功した場合も`Write`した場合も型がいい感じに合いますね｡以上より､`with_fresh_hash`の型は`unit -> ( 'a!({Read, Write} ∪ e) => ((string, 'a) either)!e )`となります｡あるいは`either`を返す式をハンドルしてvalue handlerは受け取った値をそのまま返す実装にして `( ((string, 'a) either)!({Read, Write} ∪ e) => ((string, 'a) either)!e )`となるハンドラも良さそうですね｡

```ocaml
val with_fresh_hash : unit -> ( 'a!({Read, Write} ∪ e) => ((string, 'a) either)!e )
```

## エフェクトを持つ式の型 再考
さて､ハンドラの型が分かったところでこれまで定義してきた`rand_with`や`env_with`の型を明らかにしましょう｡

```ocaml
val rand_with : (int!{Random} -> int!{} ...?) -> int!{}
```
ハンドラは`int!({Rand}) => 'a!{}`となります｡`rand_with`では`Random`エフェクトだけ起こることが明らかなので他のエフェクトを考慮する必要はありません｡またvalue handlerによりintが何らかの型に変わる可能性があるので､ハンドラの戻り値の型は`'a`と多相になっています｡
したがって`rand_with`の返す値もvalue handlerの返す値の型になるため､次のようになるのが正しそうです｡

```ocaml
val rand_with : (int!{Rand) => 'a!{}) -> 'a!{}
```

`env_with`も見てみましょう｡

```ocaml
val env_with : (int!{Read, Write} -> int!{} ...?) -> int!{}
```

これも同様に

```ocaml
val env_with : (int!{Read, Write} => 'a!{}) -> 'a!{}
```

# エフェクトのハンドル
エフェクトの型とハンドラの型が明らかになったので､実際にエフェクトを発生する式からハンドラはエフェクトの型をとりのぞいてくれるのかを見てみましょう｡

```ocaml
env_with (with_fresh_hash ()) : ???
```

型だけ見てみましょう｡`with_fresh_hash ()` は`'a!({Read, Write} ∪ e) => ((string, 'a) either)!e`という型を持ちます｡これを`env_with`に渡す｡
`env_with`が欲しているハンドラの型は`(int!{Read, Write} => 'b!{})`です(型変数の衝突を避けるため､こちらを`'b`としました)｡`'a`を`int`に特殊化すると`int!({Read, Write} ∪ e) => ((string, int) either)!e`となります｡
`int!{Read, Write}`は`int!({Read, Write} ∪ e)`のスーパータイプとなり､`'b`を`(string, int) either`で特殊化した`((string, int) either)!{}`は`((string, int) either)!e`のスーパータイプなので受け入れOKです｡`env_with`の戻り値は`'b`が特殊化されたので`((string, int) either)!{}`となります｡
したがって`env_with (with_fresh_hash ())`は`((string, int) either)!{}`になりました｡いい感じですね｡

# おわりに(未完)
だいぶ大雑把な説明になりました｡また筆者の知識不足により多相エフェクトの詳細には踏み込めなかったので悲しい｡ハンドルされないエフェクト､ハンドラ内で発生するエフェクトやエフェクト集合に関するサブタイピングなど､抑えておきたいトピックはまだあります｡
もっとまともな説明が欲しい方はこちら[^1] [^2]とか､今回は説明しなかったrow typesを用いた型システム[^3]などを参照されたし｡
気が向いたら多相エフェクトの話も書きたいですが､今すぐ知りたいという方は[^4] [^5]あたりを読んで私にご教授お願いします｡

## 追記
続編: [Algebraic Effectsの型システム入門(2) 多相エフェクト - Qiita](https://nymphium.github.io/2019/12/09/ae-poly.html)

[^1]: Bauer, Andrej, and Matija Pretnar. "An effect system for algebraic effects and handlers." International Conference on Algebra and Coalgebra in Computer Science. Springer, Berlin, Heidelberg, 2013.
[^2]: Pretnar, Matija, et al. "Efficient compilation of algebraic effects and handlers." CW Reports (2017).
[^3]: Leijen, Daan. Algebraic Effects for Functional Programming. Technical Report. 15 pages. https://www.microsoft.com/en-us/research/publication/algebraic-effects-for-functional-programming, 2016.
[^4]: Sekiyama, Taro, and Atsushi Igarashi. "Handling polymorphic algebraic effects." European Symposium on Programming. Springer, Cham, 2019.
[^5]: Kammar, Ohad, and Matija Pretnar. "No value restriction is needed for algebraic effects and handlers." Journal of Functional Programming 27 (2017).
