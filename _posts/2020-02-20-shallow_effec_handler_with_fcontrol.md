---
layout: post
title: fcontrol/runでshallow effect handler
tags: [Algebraic Effects, Delimited Continuation, Racket]
---

<!--sectionize on-->

こんにちは､びしょ〜じょです｡
気づけば2020年になってました｡
2020年ってなんだ? SFですか?

---

# はじめに - Algebraic Effectsおさらい
本日はshallow effect handlerを実装します｡
まず *shallow* effect handlerとはなんでしょう?
最初にalgebraic effects and handlersについておさらいします｡
あれとかこれとかそれとかを読んでおさらいしてください｡

{% twicard "Algebraic Effectsであそぼう - lilyum ensemble" https://nymphium.github.io/2018/08/13/algebraic_effects_tutorial.html %}
{% twicard "Dive into Algebraic Effects - lilyum ensemble" https://nymphium.github.io/pdf/mlday2.html %}
{% twicard "Algebraic Effectsとは? 出身は? 使い方は? その特徴とは? 調べてみました! - Qiita" https://qiita.com/Nymphium/items/e6ce580da8b87ded912b %}

なるほど､ **復帰可能な例外** ですね｡承知しました｡

# shallow effect handler
では改めて､ *shallow* effect handlerとはなんでしょう?
上に挙げられたシステムでは､ハンドラが取ってきた継続を起動させたときにまた発生するエフェクトが､また同じハンドラによって捕捉されています｡
逆に *shallow* effect handler は､ハンドラが取得した継続の中で発生するエフェクトは同じハンドラによっては捕捉されず､一つ外側のハンドラまで到達します｡
論文はこちら:

{% twicard "Shallow Effect Handlers | SpringerLink" https://link.springer.com/chapter/10.1007/978-3-030-02768-1_22 %}

感覚としては､ `shift/reset` の `shift` が継続を切り取るときに `reset` がくっついてくるけど､ `shift0/reset0` ではくっついてこないという関係と同じですね｡
`shift/reset` などについてはコチラ

{% twicard "delimited continuationの夏 - lilyum ensemble" https://nymphium.github.io/2018/07/19/delimited-continuationの夏.html %}

ごちゃごちゃ言ったけど[Eff言語](https://www.eff-lang.org/)でサクッと例を見てみましょう｡
こんなエフェクトと関数を定義します｡
ハンドラ`h`で`P`エフェクトが2回発生する式をハンドルします｡

```ocaml
effect P : int -> int

let c h =
  with h handle
    perform (P 2) + perform (P 3)
```
ほんで

```ocaml
let a1 = c (handler
  | effect P i k -> k (i + i)
  | val x -> x)

assert (a1 = (4 + 9))
```

うん､よさそうだ｡
`(+)` の評価は左辺の部分項を評価してから右辺に移る､と自然に考えると､最初に`P`が発生したときにハンドラが取得する継続 `k` は `with h handle □ + perform (P 3)` となる｡
`□`に`(i + i)[i/2]`を放り込むので(中略) `4 + 9 (= 13)` という結果が得られる｡

続いてshallow handlerを使います｡
ジッサイのEffにはないんですが､ `handler†` をshallow handlerとします｡

```ocaml
let a2 = c (handler†
  | effecf P i k ->
    with (handler†
      | effect P i k -> k 10
      | val x -> x
    ) handle
    k (i + i)
  | val x -> x)

assert (a2 = (4 + 10))
```

フーム妙だ､妙だな……｡
最初に`perform (P 2)`をハンドルすると､取得する継続 `k` は `□ + perform (P 3)` です｡
おや､これは`a1`の評価と異なりますね｡
これが **shallow** です｡
ハンドラは継続の中まで追っていきません｡
なので2回めのエフェクトの発生は､ `P` のマッチアーム内で新たに定義しているハンドラによってハンドルされます｡
なので `4 + 10 (= 14)` が返ってきます｡

## 役に立つんですか?
Hillerströmらの論文では､pipe/copipeのように生成と消費をおこなう相互再帰関数を例にあげている｡
またコルーチンのようにリターンポイントをハンドラで実装するときなども､shallow handlerで事足りるだろう｡

# `fcontrol/run`でshallow effect handlerの実装
ところでわたくし[こういう研究](http://logic.cs.tsukuba.ac.jp/~sat/pdf/tfp2020.pdf)をしてるんですが､実は先日もポーランドに行って[発表しました](http://logic.cs.tsukuba.ac.jp/~sat/pdf/tfp2020-slide.pdf)(隙自語)｡
このコルーチンによるalgebraic effectsの実装は､ハンドラがdeepになってます｡
[修論](http://logic.cs.tsukuba.ac.jp/~sat/pdf/master_thesis.pdf)ではshallowな方の埋め込み方法も乗せているんですが､ご覧の通りなんかぱっとしないし効率もよく無さそうだ｡

ところで `fcontrol/run` というコントロールオペレータがあるのですが
{% twicard "CiteSeerX — Handling Control" http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.22.7256 %}
あんまりいい感じに意味論が書かれてないんで[`racket/control` のドキュメント](https://docs.racket-lang.org/reference/cont.html#%28def._%28%28lib._racket%2Fcontrol..rkt%29._fcontrol%29%29)より引用すると

$$
\begin{array}{rcll}
	\left(\%\ \mathit{val}\ \mathit{proc}\right) & \rightarrow & \mathit{val} & \cr
	\left(\%\ E \left[\left(\mathtt{fcontrol}\ \mathit{val}\right)\right] \mathit{proc} \right) & \rightarrow & \left(\mathit{proc}\ \mathit{val}\ \left(\lambda \left(x\right)\ E\left[x\right]\right)\right) & \text{$E$ has no $\%$}
\end{array}
$$

となっています｡
`%` は`run`のwrapperで､`(% exp handler) === (run (λ () exp) handler)`とのことです｡
`%` がdelimiterで `fcontrol` が継続を取り出すオペレータです｡
面白いのは `shift/reset` や `control/prompt` と違い､ `fcontrol` 自体は継続を扱わずにdelimiterの `%` の引数の `proc` が継続を使います｡
アレッ?! これすでに `(% □ proc)` がハンドラで `fcontrol` がエフェクト発生じゃん?!
ところでRacketの `fcontrol/run` はプロンプトタグが使えます｡
つまり `fcontrol` が評価されたときに､どのdelimiterまで戻ればいいかをタグにより指定することができるんですねえ｡
ここで吉報です｡multi-prompt shift/resetによるEff言語の埋め込みはKiselyovらにより示されています｡
{% twicard "(PDF) Eff Directly in OCaml" https://www.researchgate.net/publication/308969161_Eff_Directly_in_OCaml %}

よし! では実装しましたはいこちら

```racket
#lang racket

(require racket/control)

(define (fcontrol f #:tag [prompt-tag (default-continuation-prompt-tag)])
  (call-with-composable-continuation
   (lambda (k)
     (abort-current-continuation
      prompt-tag
      f
      k))
   prompt-tag))
```
Racket v7.6以前は`fcontrol/run`をプロンプトタグを指定して使う場合にバグがあったので､最新の環境でない場合は上記のように`fcontrol`を上書きします｡
次こそ本題です｡

```racket
(define (perform eff v)
  (fcontrol v #:tag eff))

(define (new-effect)
  (make-continuation-prompt-tag))
```

エフェクト`eff`を引数`v`を渡して発生させるので､そのまま`fcontrol`を使います｡
Racketの`fcontrol`ではオプショナル引数`#:tag`でタグを渡せます｡

エフェクトはプロンプトタグに対応するのでそのままです｡

ハンドラの実装がメインディッシュです｡

```racket
(define ((call-with-shallow-handler eff vh effh) th)
    (let* [(p (make-continuation-prompt-tag 'return))
           (const (λ (x _) x))
           (effh~ (λ (x k)
                     (fcontrol (effh x k) #:tag p)))]
      (%
        (let [(r (% (th) effh~ #:tag eff))]
          (vh r))
        const #:tag p)))
```

`(call-with-shalow-handler effe vh effh)`で､エフェクト`eff`をハンドルするハンドラを作ります｡
んでサンク`th`をこのハンドラに渡すと､ハンドラのもとでサンクが潰れて評価が走ります｡

基本的な考え方は非常に簡単､`fcontrol/run`がalgebraic effects & handlersであるという直感をそのまま使います｡
`(% (th) effh #:tag eff)` でエフェクト`eff`が起きたときにエフェクトハンドラ`effh`でハンドルします｡
しかし`fcontrol/run`に足りないものがある｡なにか｡value handlerである｡
shallow effect handlerにおいてvalue handlerが介入するタイミングはdeepな場合と同じ､値をハンドルする場合のみです｡
そしてshallowなので一度エフェクトをハンドルしたらハンドラは撤退しなければならない｡
なのでこういう戦略でいきます｡
- 戻り値は常にvalue handlerで取るようにする
- しかしエフェクトが発生したらvalue handlerを迂回する
ベストか? と言われると自信ないですが､ハンドリングされた式を評価したときにエフェクトハンドラでハンドルされたかどうかのフラグを持っておくのはなんかダサいし状態を持ちたくないというのはピュアな感覚です｡
またタグをつけたり外したりもちょっと面倒です｡
なので今回はどうにかして迂回します｡
幸い今回はコントロールオペレータが1つ､`fcontrol/run`が与えられています｡
しかも今回はプロンプトタグのおまけ付きだ｡
エフェクトハンドラの戻り値を`fcontrol`で飛ばしてvalue handlerに渡るのを阻止しました｡
吹っ飛んだときの継続は使わなくていいので､`const`関数でエフェクトハンドラの戻り値だけ受け取って返します｡

いい感じじゃないですか｡
それではコルーチンを実装してみます｡

```racket
(struct coroutine ([it #:mutable]) #:extra-name Coroutine)

(define Yield (new-effect))
(define (yield v)
  (perform Yield v))

(define (resume co v)
  ((call-with-shallow-handler Yield
                              (λ (x) x)
                              (λ (u k)
                                 (begin
                                   (set-coroutine-it! co k)
                                   u)))
   (λ () ((coroutine-it co) v))))
```

`yield`はエフェクトの発生､`resume`はハンドラ､コルーチンスレッドは継続が保存されたセルです｡
実装うまくいったかな?

```racket
(let [(co (coroutine
           (λ (_)
              (begin
                (display "hello,")
                (displayln (yield '()))
                ))))]
  (begin
    (resume co '())
    (resume co "world")))
```

こいつ､動くぞ……!

# おわりに
`fcontrol/run`というおもしろいコントロールオペレータとそれを利用したshallow effect handlerの実装を紹介しました｡
パフォーマンス比較とか他のコントロールオペレータとの関係は読者の皆さんの課題と勝手にさせて､ええ､いただきます｡
夏休み最終日に絶望する小学生にならないように､日々こつこつと取り組んでください｡

---

エッ修論?! 俺は卒業したのか……｡
