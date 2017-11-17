---
layout: post
title: OCamlでevalして結果をstringで得る
tags: [OCaml]
---

<!--sectionize on-->

こんにちは､何者でもなくなりました｡

さて､今はOCamlとLaTeXしか書いてないという状況に陥りました｡人生にありがちな時期ですね｡

# OCamlでも`eval`がしたい!
ではこちらをどうぞ｡

[“Eval” a string in OCaml - stackoverflow](https://stackoverflow.com/questions/33291754/eval-a-string-in-ocaml)

以下引用(upop上で動くよ)｡

[label:fig-origeval]
```ocaml:listing[ref:fig-origeval]: eval
#require "compiler-libs" (* Assuming you're using utop, if compiling then this is the package you need *)
let eval code =
  let as_buf = Lexing.from_string code in
  let parsed = !Toploop.parse_toplevel_phrase as_buf in
  ignore (Toploop.execute_phrase true Format.std_formatter parsed)
```

`compiler-libs`というOCamlに同梱されているライブラリーを使いますと､このようにevaれるわけですね｡

# `eval`の結果を文字列で取りたい!
evaってるのは`Toploop.execute_phrase`で､戻り値はランタイムエラーしたかそうでないかの`bool`になります｡
上記では`ignore`で捨てて`unit`にしてますね｡

例えば､`eval "int_of_char 'a';;"`なんてしたときに戻り値が`"97"`という`string`だと嬉しい人がいるかもしれない｡

俺なら実装やってくだけだな

# 出力先
`format`型の話をしよう｡

[OCaml 標準ライブラリ探訪 #3.0: Printf: 便利だけどいろいろ謎のある奴 - Oh, you  \`re no (fun _ → more)](http://d.hatena.ne.jp/camlspotter/20091102/1257099984)

[OCamlのformat (型安全なprintf/scanf) の仕組み - 簡潔なQ](http://qnighy.hatenablog.com/entry/2017/01/26/215948)

話おわり

# 解
listing[ref:fig-origeval]の`Toploop.execute_phrase`に渡している引数を観察すると､
`true`と`Format.std_formatter`を渡していることが分かる｡

`true`は後述｡第2引数は件の`format`じゃねえかい｡
このformatの出力先を`string ref`みたいなところに出してその中身を返せば行けそうだ｡
でもどうやって? まずは`Format.std_formatter`がどうなってるかを見てみよう｡

[stdlib/format.ml#L1038](https://github.com/ocaml/ocaml/blob/trunk/stdlib/format.ml#L1038)で定義されている｡
`formatter_out_ouf_channel`が何者か辿ってみると､

```ocaml
let formatter_of_out_channel oc =
  make_formatter (output_substring oc) (fun () -> flush oc)
```

了解!

この`make_formatter`って使えそうだなと思って定義を見てみるが全くわからない｡
幸運にも､`formatter_of_out_channel`の真下にわかりやすい例がある｡

```ocaml:stdlib/format.ml#1023
let formatter_of_buffer b =
  make_formatter (Buffer.add_substring b) ignore
```

`Buffer.add_substring`と`ignore`という､わかりやすい関数で構成されている｡
これなら型がたちどころに分かるな｡

[Module Buffer - OCaml.jp](http://ocaml.jp/refman/libref/Buffer.html#VALadd_substring)
を見るとsubstringしてバッファーにくっつける感じですね｡
そしてバッファー`b`を部分適用しているので､なるほど`make_formatter`に渡しているのは`string -> int -> int -> unit`と`unit -> unit`か｡

もう見えてきましたね｡substringを`string ref`などに書いて参照すればOK｡
あとはやるだけ｡

```ocaml
let records = ref ""
let ref_b rs = fun s i j ->
  let subs = String.sub s i j in
  rs := !rs ^ subs
let fmt = (ref_b records |> Format.make_formatter) ignore

let eval code =
  let as_buf = Lexing.from_string code in
  let parsed = !Toploop.parse_toplevel_phrase as_buf in
  let () = Toploop.execute_phrase true fmt parsed |> ignore in
  let ret = !records in 
  records := ""; ret
```

はい実行

```:utop
utop # eval "int_of_char 'a';;";;
- : string = "- : int = 97\n"
```

ありがたい! 型名まで付いている!!! いらない!!!!!

おわりだよ〜

---

『ブレードランナー 2049』観に行きましたが全部最高でした｡

『ブレードランナー』の続編としての立ち位置､ストーリー､BGM､ハリソン・フォード…全て…｡

