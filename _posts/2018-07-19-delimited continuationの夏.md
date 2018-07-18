---
layout: post
title: delimited continuationの夏
tags: [Delimited Continuation, Racket, OCaml]
---

<!--sectionize on-->

こんにちは､びしょ〜じょです｡
control/promptとprompt tagへの理解が必要になったため､やっていきましょう｡

# continuation??? 継続??? is power ???
継続とは *"残りの計算"* などと言われます｡
\\(e_1+e_2\\)という式があって､左辺から計算がおこなわれていくとする｡
\\(e_1 \Downarrow v_1\\)となると､残りの計算は\\(\lambda x. x + e_2 \\)となります｡
\\(\lambda x. x + e_2 \\)はよく\\([\ ]+e_2\\)と表現され､この\\([\ ]\\)はholeと呼ばれたりする｡
この継続を\\(E\\)などとおいて､\\(E\\)をぶっこ抜いてきてなにか値を渡したりするときは\\(E[x]\\)と表記し､holeに\\(x\\)が入っていく｡
OK､私も皆さんも ***完全に理解した*** と思うので話を進めよう｡

# Delimited continuation
和訳すると限定継続です｡これで9割は分かったと思うが､call/ccよりも取ってくる継続の範囲が限定されているというイッメジです｡
StackOverflowのこれ[^4]が図解付きでわかりやすい｡

## shift/reset
久しぶりにRacket引っ張ってきます｡Schemeでもなんでもdelimited continuationが使えれば良いですが｡
Racketだとshift/resetを使うには`(require racket/control)`する必要がある｡
Guileだと`(use-modules (ice-9 control))`やね｡

```scheme:call/cc
(- 4 (call/cc (lambda (k) (+ 3 (k 20)))))
; displays "-16"
```

```scheme:shift/reset
; (require racket/control)

(reset (- 4 (shift k (+ 3 (k 20)))))
; displays "-13"

(- 4 (shift k (+ 3 (k 20))))
; displays "-13" (work in the same way as above)

(- 4 (reset (shift k (+ 3 (k 20)))))
; displays "-19"
```
雑な説明でしたが､`call/cc`は中のコンテキスト`(+ 3 [])`も継続の呼び出し時に捨ててますね｡
あとRacketの`shift`は`reset`が見つからなかったらエラーにならずに最外のコンテキストを持ってくるんですねぇ｡

shift/resetの詳細は文献[^1]をご覧ください｡
…ちょっと待って! `shift0`が無いやん! ということで文献[^2]を見る｡

まず`shift`の定義を見ます｡

\\[
@importmd(src/20180710/shift.tex)
\\]

おk｡

では`shift0`はどうかな?

\\[
@importmd(src/20180710/shift0.tex)
\\]

えっ何が違うん? と一瞬困るわけですが､`shift0`では一発評価が進むと`M`の中から`reset`が消えてますね｡
なので`E'`の中の最外の`shift0`は`M`まで行ってしまうわけです｡
`shift`と`shift0`の違いを実際に文献の例から見てみます｡

```scheme:with-shift
(reset (cons 'a
  (reset (shift f (shift g '())))))
; returns '(a)
```

ここの`reset`外のコンテキスト`M`は`(reset (cons 'a []))`となる｡
つまり変換規則で対象となっている`reset`は内側のほう｡
`shift`外のコンテキスト`C`は`[]`､つまり空ですので最外の`shift`が対象となっている｡
`E`は`(shift g '())`となる｡

ではワンステップすすめると`M[(reset E{f := (lambda (x) (reset C[x]))})]`なので

```scheme
(reset (cons 'a
  (reset (shift g '()))))
```

あとは同様にやっていく｡内側の`reset`をやっていくので`(reset (cons 'a (reset '())))`で､あとはアーナンダビッグステップに行くぞということで`'(a)`が得られる｡

続いて`shift0`について見よう｡
文献[^2]ではdelimiterは`reset`のみだったが､racket/controlの`shift0`に対応するdelimiterは`reset0`となる｡

```scheme:with-shift0
(reset0 (cons 'a
  (reset0 (shift0 f (shift0 g '())))))
; returns '()
```

オッなんか違うな｡当然違うわけだ｡
だいたい形は同じなのですが､
ワンステップすすめると`M[(E{f := (lambda (x) (reset0 C[x]))})]`となる｡
`E`の外に`reset(0)`がつかないわけだ｡

```scheme
(reset0 (cons 'a
  (shift0 g '())))
```

で`reset0`と`shift0`の間のコンテキストは拾われずに`shift0`内のexpressionが生き残るので､`'()`を返す｡

あ〜〜 ***完全に理解した*** ｡
この *"resetは1度しか使えない"* という回数制限はlinear logicの影が潜んでいそうだ｡
実際この回数制限nessを型で表そうとするとそんな雰囲気になるはずだ｡

## control/prompt
だいたいshift/resetというと語弊があるが､だいたいそんな感じという認識がある(間違ってると思うのでご教授願います｡)｡
`prompt`は`control`と対応するdelimiterに過ぎず､動きとしては`reset`同様に継続を区切るだけだ｡
"control prompt"で検索するときは､"-command"を付けないとコマンドプロンプトに関する話が大量に出てきて血管ブチ切れそうになる｡

`control`は文献[^2]より､
\\[
@importmd(src/20180710/control.tex)
\\]

この論文ではdelimiterが`reset`だがとりあえずOKとしたい｡
`f`にバインドされる継続の中に`reset`がないという点で`shift`と異なっている｡
論文の例を見てみよう｡

```scheme:with-shift
(reset (let {[y (shift f (cons 'a (f '())))]}
  (shift g y)))
; returns '(a)
```

Racketは3種類のカッコが使えるからS式もちょっぴり分かりやすくなるぞ!
これを規則にそって解いてくと次のように進む｡

```scheme
; 1
(reset (cons 'a
  [(lambda (x) (reset (let {[y x]} (shift g y))))
  '()]))

; 2
(reset (cons 'a
  (reset (let {[y '()]} (shift g y)))))

; 3
(reset (cons 'a (reset shift g '())))

; 4
(reset (cons 'a (reset '())))

; 5
'(a)
```

ふむふむ｡はい｡

では`shift`を`control`にしたらどうなるか―

```scheme
(reset (let {[y (control f (cons 'a (f '())))]}
  (control g y)))
; returns '()
```

結果が異なるわけだな｡

```scheme
; 1
(reset [cons 'a
  ((λ (x)
    (let {[y x]} (control g y)))
    '())])

; 2
(reset [cons 'a
  (let {[y '()]} (control g y))])

; 3
(reset [cons 'a (control g '())])

; 4  gが使われないので `[cons 'a ...]` が破棄される
(reset '())

; 5
'()
```

わかった｡
とりあえずこのへんで ***完全に理解した*** ということにいたしましょうか…｡

# prompt tag
継続をキャプチャするオペレータ(`shift`, `shift0`,`control`など)はそれぞれ対応する､取るべき継続を区切ってくれるdelimiterがある｡
例えばracket/controlでは`shift`に対応するのは`reset`で､`shift0`には`reset0`が対応する｡
更には同じ`shift`でも､`shift`式[^3]のコンテキストで最も近い`reset`が動的に対応付けられる｡

この､`shift`や`control`などのcontrol operatorとdelimiterの対応をもっと柔軟にしたい! という要望に応えるのがprompt tagである｡

```scheme:prompt tag
(let {
  [p  (make-continuation-prompt-tag 'p)]
  [p~ (make-continuation-prompt-tag 'p~)]}
  (reset-at p
      (+ 3 (reset-at p~
        (begin
          (shift-at p f {begin
            (display "this is p")
            (f 4)})
          (shift-at p~ g {begin
            (display "this is p~")
            (g 20)}))))))
; display "this is pthis is p~23"
```

確かに､最寄りの`reset`ではなく､プロンプトに対応する`reset-at`の継続を取っている｡

ちなみにOCamlのdelimited continuationライブラリ[delimcc](http://okmij.org/ftp/continuations/implementations.html#caml-shift)では､prompt tagのみが使われている｡
なんだか日本語が足りないが､Racketの`shift`や`reset`はなく､`shift-at`や`reset-at`のみ､という感じ｡

```ocaml
let open Delimcc in
  let p = new_prompt () in
  let reset = push_prompt p in
  let shift f = shift0 p f in
  reset @@ fun () -> List.cons `A @@
    reset @@ fun () -> shift @@ fun f -> shift @@ fun g -> [];;
(* returns [] *)
```

これは何故か｡多分answer-type polymorphismをOCamlではサポートしてないからじゃないかな｡
詳細はdelimccに関する文献[^5]を読めって話ですよ｡読んでへん｡

とりあえずここは ***完全に理解した*** ということで､よろしいでしょうか｡

# おわりに
なんとなくつかめてきた気がします｡
夏服の剣持力也くんがうさんくさいメガネ掛けててよかった｡


[^1]: 浅井健一. "shift/reset プログラミング入門." ACM SIGPLAN Continuation Workshop 2011. 2011. http://pllab.is.ocha.ac.jp/~asai/cw2011tutorial/main-j.pdf
[^2]: Shan, Chung-chieh. "Shift to control." Proceedings of the 5th workshop on Scheme and Functional Programming. 2004. ftp://cs.indiana.edu/pub/techreports/TR600.pdf#page=103
[^3]: racket/controlの`shift`はマクロ! はいごもっとも!
[^4]: [What exactly is a “continuation prompt?”](https://stackoverflow.com/questions/29838344/what-exactly-is-a-continuation-prompt)
[^5]: Oleg Kiselyov. "Delimited Control in OCaml, Abstractly and Concretely: System Description." FLOPS 2010. 2010. https://link.springer.com/chapter/10.1007/978-3-642-12251-4_22

