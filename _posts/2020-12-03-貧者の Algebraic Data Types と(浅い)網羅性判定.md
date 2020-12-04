---
layout: post
title: 貧者の Algebraic Data Types と(浅い)網羅性判定
tags: [TypeScript, Scala, Advent Calendar]
---

<!--sectionize on-->

こんにちは､びしょ～じょです｡
これは [TypeScript アドベントカレンダー 2020](https://qiita.com/advent-calendar/2020/typescript) の3日目の記事です｡
ちなみに12月3日は冴草きいちゃんの誕生日です｡大変めでたいですね｡

# はじめに

関数型プログラミングといえばなんですか? はい円楽さん早かった! はいはい､ **パターンマッチング**､いいですね｡
パターンマッチングといえばプリミティブな数値や文字列のリテラルのみならず､ユーザが定義した型もその構造によってマッチできます｡回りくどい言い方をしましたが代数的データ型(Algebraic Data Types, ADTs)です｡

```ocaml: [label:ocaml1] listing [ref:ocaml1]. 例えば OCaml
type 'a option =
  | None
  | Some of 'a

let to_default default o =
  match o with
  | None -> default
  | Some v -> v

type ('key, 'val) map_internal = ('key * 'val) list

let rec find key map =
  match map with
  | [] -> None
  (* 表層 (list) だけなじゃくて内部 (tuple) もマッチできるぞい *)
  | (key', val) :: _ when key = key' -> Some(val)
  | hd :: map' -> find key map'
```

# emulating ADTs in TypeScript
ところで TypeScript ってェ言語があるんですが[^1]､この言語にはパターンマッチング～以前に ADTs がサポートされてません! 息ができん!!
でも TypeScript には Union という強力な型がある｡

```typescript: TS の Union
type BakaString = string | undefined
```

これを使いましょう｡

```typescript
type Some<T> = { value: T }
type None<_> = { } // TypeScript は頭がおかしいのでこれが object 型になるんですが目をつぶっていただいて空の record だと思ってください｡
type Option<T> = Some<T> | None<T>
```

ほならねパターンマッチングで分解や! といきたいのですが…

```typescript
const toDefault = <T>(default: T, o: Option<T>): T =>
  o.value !== undefined ? o.value : default;
```

そんなことある??? って感じになりました｡
nullish coalescing 使えとかそういう話ではありません｡

```typescript
toDefault(0, { value: 10, hoge: "aaa" }); // ==> `10` !!
```

TypeScript は構造的部分型を採用しているため､ `Some<T>` が指すものは property に `value: T` のある object なわけですね｡つまりなんでもアリです｡
これはマズい! という民草の嘆きに答えたのかは知りませんが､言語レベルの UUID みたいな `Symbol` という便利なものがあり､これを使います

```typescript: [label:option1] listing [ref:option1]. 真面目に定義した Option<T>
const someSym = Symbol();
const noneSym = Symbol();
// someSym !== noneSym

type Some<T> = { _tag: typeof someSym; value: T }
type None<T> = { _tag: typeof noneSym }

type Option<T> = Some<T> | None<T>
```

なんとかなったな｡
パターンマッチングをいい感じにやるためのオペレータも用意します｡

```typescript: [label:match1] listing [ref:match1]. match
/**
 * @example
 *   match(o,
 *     (v) => v,
 *     ()  => default
 *   );
 */
const match = <T, A>(o: Option<T>, onSome: (_: T) => A, onNone: () => A): A =>
  o._tag === someSym ? onSome(o.value) : onNone();
```

はぁ……と一瞬で関心が薄れそうな味気ない実装ですがちょっとまって!!
`onSome` の処理で `o.value` を参照してます｡`None<T>` の場合もあるのにこれをコンパイラが通してくれるのは TypeScript の型システムが control-flow based type analysis というのをやってくれているからです｡
型レベル supercompilation みたいですね｡
Typed Racket も同様に control-flow based type analysis を組み込んだ Occurrence Typing という型システムを採用しており､こちらは論文が出ており定式化されているので気になったら読んでみてください｡
さて戻りますと､ここでは､ `o._tag === someSym` という条件を通過したら､型付けの文脈に"`o._tag` は `someSym` である"とうのがまず追加されるわけです｡
これから更に"`o` は `Option<T>` だったので､そのうち `o._tag === someSym` なのは `Some<T>` の場合なので `o.value` が存在する"まで推論してくれるため､ `o.value` に参照できるわけですな｡
そして､三項演算子のもう一方の部分では､ `Option<T>` だが `Some<T>` ではないという情報が渡ってきまして､今回は `Some | None` の2つしかないのでちょっと雰囲気出ませんがとにかく `o` は `None<T>` ということが分かります｡

……とまぁかような具合に TypeScript でもなんとか ADTs とパターンマッチングができました｡
この `_tag` を用いた手法は TypeScript で functional programming したい人のためのライブラリ fp-ts で採用されているものでした｡
上記で定義した `match` という名前のパターンマッチングする関数は fp-ts では慣習的に `fold` という名前で定義されています｡
あと本記事では省略した `readonly` とかをちゃんとしているが､ `_tag` には optimistic に string literal type を利用している｡
{% gh_repo gcanti/fp-ts %}

# 苦難の型推論
さて! 帰って飯食って寝よう～といきたいところですが､ちょっと待ってよ｡
`Some<_>` と `None<_>` の型を作るために毎度 object リテラルに `_tag` をえっさほいさするのは面倒です｡
それにこれを乱用して野良 `Option<_>` 型を作ってほしくないので smart constructors を定義してそれだけユーザに見せるようにしましょう｡

```typescript: スマコン
const Some = <T>(value: T): Some<T> => ({ _tag: someSym, value });
const None = <T>(): None<T> = ({ _tag: noneSym });
```

よし! そしてこちらを御覧ください｡

```typescript
const to123 = (num: number) =>
  num >= 0 && num <= 2 ? Some(num) : None()
```

突然ですがクイズです! `to123` の return type は何でしょう?
はい残念または正解! `None<number> | Some<unknown>` です｡絶望しましたか? 私はしました｡
絶望したんですが､なぜ絶望したか考えていきましょう｡
結局私も何が起きたのか分からなかったのですが､{% twid hiroqn %}さんがかなりそれっぽい回答をしていたのでそれを書きます｡

まず `None` のスマコンがよくない｡
return type は `Option<T>` ですが､この `T` が何者によっても与えられていないので解決できません｡
したがって､型注釈を書かないかぎりは､ TypeScript の型システムは推論できない型変数を`unknown` で埋めます｡
よって､三項演算子の**片方**はまず `Option<unknown>` を返すことになります｡

次に三項演算子の第二項では `Some(sum)` を返します｡
`Some` のスマコンは引数の型がすなわち `T` なので､こちらは `Option<number>` を返します｡
このことから､まず `to123` の return type は `Option<number> | Option<unknown>` という型を返すという計算がおこなわれます｡

さて､ TypeScript における `type` declaration は単なる alias なので､**特に指定がなければ** 型推論の上で union types をほどいても怒られませんので､ `Option<number> | Option<unknown>` は `Some<number> | None<number> | Some<unknown> | None<unknown>` と展開できます｡
ところで TypeScript は(構造的)部分型を採用しているのですが､builtin な型達の間でも subtyping relation が予め定義されています｡
`number <: unknown` なので､上記の展開した型のうち `None` には **具体的な型** である `number` が来ます ( `None<number>` )｡
一方 `Some` は､ body の方ですでに `Some<number>` という型が定まっているが return type の上で `Some<number> | Some<unknown>` になりました｡
これをほどいてくと `{ _tag: typeof someSym; value: number | unknown }` なのですが､ `number <: unknown` より `number | unknown === unknown` と計算を進められます｡
つまり `{ _tag: .....; value: unknown } === Some<unknown>` です｡

以上より､ `to123` の return type は `None<number> | Some<unknown>` となるようです[^2]｡
`Some<_> | None<_>` の順番が flip してるのも香りがありますね｡

………… ***グワ～～頭が痛い!!!***
ちょっと OCaml 吸っていいですか? ……フゥ､ OCaml で `None` のスマコンを作ったら……あぁ `none ()` は多相性を保ってくれるんで weak polymorphic variable 導入せずに `'a option` か､そうか｡

よし｡
ちなみにワーワー騒いだが､型注釈をつけると

```typescript
const to123 = (num: number): Option<number> =>
  num >= 0 && num <= 2 ? Some(num) : None();
```

# Scala-like ADT definition
上記でワーワーやったアホアホ推論をおこなわず､注釈にしたがいます｡
**けど!** 俺たち \\(\lambda_\rightarrow\\) 生まれ OCaml 育ち型推論はだいたい決定可能としても注釈なんて書かずにもっと直感的で使いやすい推論結果を出してほしい｡

う～ん､そういえば Scala (2.x) って言語があって～､あれも ADTs を言語機能として持っていないけどなんかいい感じにしていたな｡

```scala: Scala 2.x による伝統的な ADTs の定義
sealed trait Option[_] {}
case class Some[T](value: T) extends Option[T]
case class None[T]() extends Option[T]
```

なるほど! 小さい型を定義して､それを継承するのか｡
先程の方法が集合を外延的に定義するのに似ているのに対して､こちらは帰属関係を要素一つずつに対して定義している感じですね｡
こういった手法に名前が付いてるんでしょうか? 私気になります｡

ともあれひとまず TypeScript でもやってみましょう｡

```typescript: TS でもやってみよう
interface Option<T> { _tag: symbol }

const someSym = Symbol();
interface Some<T> extends Option<T> {
  _tag: typeof someSym;
  value: T;
}

const noneSym = Symbol();
interface None<T> extends Option<T> {
  _tag: typeof noneSym;
}
```

オッいい感じじゃん｡
でもスマコンを定義するときにちょっと困ります｡

```typescript
// return type が Option<T> だと型検査が通らない!
const Some = <T>(value: T): Some<T> => ({ _tag: someSym, value });
const None = <T>(): None<T> => ({ _tag: noneSym });
```

そう､ `Some` の return type を `Option<T>` にすると `value` という余計な property があるので怒られます｡
マジか～て感じですが `Some<T> <: Option<T>` という関係がすでにあるのであんまり困らない｡

では先程の `to123` は型推論でバシッと return type がいい感じになるか?
……なりますねぇ!! 無事 `Option<number>` に推論してくれます｡心､つながったね｡

スマコンの型をいい感じにしたから `to123` の型が合ったんじゃないか? と思い listing [ref:option1]の方法で定義したやつのスマコンも上記と同じようにすると､ `to123` の return type は `Some<number> | None<unknown>` になりました｡
お腹いっぱいなんでもういいです｡

# 力の代償: 網羅性判定
さーて listing [ref:match1] の `match` も実装しておわりおわり

```typescript: [label:match2] listing [ref:match2]. match その2
const match = <T, A>(o: Option<T>, onSome: (_: T) => A, onNone: () => A) =>
    o._tag === someSym ? onSome(o.value) : onNone();
// 🤬 Property 'value' does not exist on type 'Option<T>'.
```

オワッ?! TypeScript の怒りを買いました｡
コチラは熱弁した control-flow based type analysis やってくれへんのかいと思ったんですが､ `Option<_>` 側は `Some<_>` の supertype という情報を持ってないためどうしようもないわけです｡
うーんこまった､困ったんで conditional type を利用します｡

```typescript
const isSome = <T>(o: Option<T>): o is Some<T> =>
  o._tag === someSym;

const isNone = <T>(o: Option<T>): o is None<T> =>
  o._tag === noneSYm;
```

エッ依存型!?
これは `isSome(o)` が `true` の場合の条件分岐などに `o` は `Some<T>` 型ということを伝えるための型であり､実際はあまり大層なものではなくむしろちょっと危なげな型です｡

```typescript: これも型検査通るやで
const bad = <T>(o: Option<T>): o is None<T> =>
  // oh ...
  o._tag === someSym;

// こういうのは流石に通らない
// (n: number): n is boolean => n !== 0
```

まあそれなりに根拠のある `as any as T` みたいな感じですね｡

では､いきます｡

```typescript: [label: match2'] listing [ref:match2']. match その2'
const match = <T, A>(o: Option<T>, onSome: (_: T) => A, onNone: () => A): A =>
  isNone(o) ? onNone() : onSome(o.value);
// 🤬 Property 'value' does not exist on type 'Option<T>'.
```

｢こいつ､やったな｣と思った方正解なんですが､ちょっと例が悪かったんで恣意的に `onSome` と `onNone` の位置を flip しました｡
まずこれが何故エラーなのかというと､ listing [ref:match2] と同様に `onSome` 側に `o` が `Some<T>` という情報が渡ってないからですね｡
`Option<_>` の定義からわかるとおり､`None<T>` でないは `Some<T>` である *ではない* わけです｡
なので､ flip するとあたかも問題が解決してるようですが､例えば `Either<E, A>` みたいに2パラメータある型を分解するときに困る｡なのでちょっと強引にでも問題提起しました｡

では `isSome` 使えばEジャンとなるんですが……

```typescript
const match = <T, A>(...) => {
  if (isSome(o)) return onSome(o.value);
  if (isNone(o)) return onNone();
};
// 🤬 Not all code paths return a value.
```

実は `--noImplicitReturns` をコンパイラに渡さなければ怒られないんですが､strict に型をつけたい場合は是非怒られたい｡
ここまで来ればなんで怒られるかも理由がつきますね｡
そう､ `Option<T>` が `Some<T>` でも `None<T>` でもない場合にどうするかを書いてません｡
んな場合無いよ! と人は思うんですが必ずしもそうではない｡
[ref:3.+苦難の型推論と網羅性判定のジレンマ]章で熱弁した通り､注釈をつけないととんでもない場合があるので `Option<T>` は `export` して他のモジュールで利用する場合があります｡
特にこれをライブラリとして開発していたら知らんところで人が使います｡
そして **`Option<T>` が `extends` され得るのです** !
また TypeScript も極めて賢いわけではないため､ `export` がついてるかどうかなどのアクセス制御と連携した型システムは備わっていないようです｡

ところでこの場合分けが全ての場合を網羅しているかどうかの判定を網羅性判定(exhaustivity check)と呼びます(まんまやんけ)｡
この手法では `match` が not exhaustive なので怒られました｡

```typescript: キモいけどしゃーなし
const match = <T, A>(...) => {
  if (isSome(o)) return onSome(o.value);
  if (isNone(o)) return onNone();

  throw new Error('may be unreachable');
};
// よし､通れ
```

え～じゃあ Scala はどうしてんのよ､となるんですが､ Scala は `sealed` という attribute でよろしくやってます[^3]｡
`Option[_]` という抽象型はこのファイル外には出ませんよということを明示することで､`Some(_)` の場合と `None()` のパターン *だけ* で全て網羅していることが言語も分かってくれるわけですね｡

---

ハ～疲れたちょっと休憩します｡裏で OCaml 吸ってきます｡
そういえば OCaml にも extensible variants とかあったな……

```ocaml: おまけ: extensible variants
type t = ..
type t += A | B

let to_int = function
  | A -> 0
  | B -> 1 
(*
Warning 7: this pattern-matching is not exhaustive.
Here is an example of a case that is not matched:
*extension*
Matching over values of extensible variant types (the *extension* above)
must include a wild card pattern in order to be exhaustive.
*)
```

ワー! だけどそもそも OCaml には ADTs を定義するのとは別に拡張性を残したやり方としてあるので､はい｡

```ocaml: ふつうこうする
let to_int fwd = function
  | A -> 0
  | B -> 1
  | other -> fwd other
```

マッチャを接ぎ木できるようにするわけですね｡
パターンマッチングで接ぎ木の話をするとまた Egison とか MetaOCaml とか Scala の話がワーッと膨らんでしまうので､後日｡

# おわりに
TypeScript で ADTs を定義するには2通りあるけど2通りのつらさがありました｡

|   | メリット | デメリット |
|--:| :-- | :-- |
| union type | パターンマッチングを網羅できる | 型推論が終わる
| Scala ぽいやつ | 型推論がナイス! | exhaustivity check で涙をのむ

うーん､キツいですね｡
キツいですが面白い議論ができました｡
突然 CM なんですが､こういった面白い議論ができる TypeScript を用いて株式会社 HERP でなんかいろいろやっています｡
面白いね!🤬 とかゴミ!🤡 みたいな議論やその他プログラム言語に関する面白い話をしつつ TypeScript の罠を回避したり向き合いたい方はぜひいらしてください｡
ちなみに弊社新サービスなどの実装言語には *Haskell が採用されがちです*｡
この記事の大半は労働時間中に書かれました｡

{% twicard "求人一覧" https://herp.careers/v1/herpinc %}

---

タイトルにもある通りパターンマッチングには深さがるんですが､今回は深さ1のパターンマッチングの話でした｡
例えば OCaml では深いパターンマッチングができるので

```ocaml
let hd = function
  | Some(hd  :: _) -> hd
  (* いつもなら _ -> failwith ... と書くが明示 *)
  | Some(_) | None -> failwith "hoge"
```

のように `Some(_)` の中のリストをさらに分解しています｡
TypeScript で深いパターンマッチングは……未来に期待しましょう｡

[^1]: TypeScript 言語およびその参照実装であるコンパイラ tsc (v4.1.2) を指す｡以降これに倣う｡
[^2]: TypeScript の型システムの推論規則が特に示されてないんで推測の域を出ない｡実装が仕様と言われたらすみません､いつか実装読む……かも……｡
[^3]: [A Tour of Scala: Sealed Classes | The Scala Programming Language](https://www.scala-lang.org/old/node/123)
