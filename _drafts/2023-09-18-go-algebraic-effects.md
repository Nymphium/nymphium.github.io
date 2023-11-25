---
layout: post
title: "From Goroutines to Coroutines: goroutines+channelsから考えるコルーチンの分類"
tags: [Go, Algebraic Effects, effect system, coroutines]
date: 2023-10-10
---

<!--sectionize on-->

こんにちは､びしょ～じょです｡

---

だいぶ前にコルーチンの分類について記事を書きました[fnref:1]｡

今回は､この分類を実装サイドから考えていこうという企画です｡
実装にはGoのgoroutinesとchannelsを用いて説明していきます｡

ちなこの内容でGoCon miniにプロポーザルを出したら落ちました｡涙｡


# はじめに
非同期プログラミングは現代のソフトウェア開発における中心的なテーマの一つであり､特にGo言語はこの領域において独特なアプローチを取っている｡
Goの非同期処理の中心には､goroutinesとchannelsという二つの主要な概念が存在する｡
本稿では､これらGoの基礎的な要素と､より一般的な非同期プログラミングの概念であるcoroutinesとの関連性を考察する｡

<!-- 本記事の考察による最終的な成果はコチラでone-shot algebraic effect handlersとなった: -->

<!-- {% gh_repo Nymphium/eff.go %} -->

# Goroutinesとchannels
GoroutinesはGoにおける軽量スレッドの実装であり､独立したタスクの非同期実行を可能にするものである｡
これらのgoroutinesは多くの場合独立して動作するが､特定の状況下でデータの共有や同期が必要となる｡

Channelsは､このデータの共有や同期を実現するための手段として導入されている｡
また､特定のgoroutineがデータの送受信を待機することで､同期の役割も果たす｡
このようにして､channelsはデータの競合やデッドロックといった並行処理に関連する問題を軽減する機能を提供している｡

以下は､2つのgoroutines間で整数を送受信する基本的な例である([ref:prg1])｡

```go :[label:prg1][ref:prg1]. channelを利用したgoroutine間の整数の送受信
package main

import "fmt"

func send(ch chan int) {
	for i := 0; i < 5; i++ {
		// iを送信
		ch <- i
	}
	close(ch)
}

// mainはgoroutineとして実行される
func main() {
	channel := make(chan int)
	// mainと別のgoroutineでsendを走らせる
	go send(channel)

	// channel rangeで1回ずつ受信する
	for num := range channel {
		fmt.Println("Received:", num)
	}
}
```


この例では､`send`はchannelを通じて整数を送信し､`main`はそれらの整数を受け取ってprintする｡
`close(ch)`により､channelが閉じられ､これによって`range`を使用してchannelからのデータを読み取ることができる｡

Channelsを使用することで､データの競合やデッドロックといった並行処理に関連する問題を軽減する機能が提供される｡
この安全性と同期能力は､Goの並行処理の強力さの一因である｡

# Coroutinesとその分類

Coroutinesについてはすでに[fnref:1]で触れてきたのでかるくおさらいする｡
Coroutinesは､プログラムの実行を中断し､後で再開することができる軽量なスレッドの一種である｡
主な特徴として､callee-callerの対称性に基づく分類があげられる([ref:tbl1])｡

<center>
[label:tbl1]
表[ref:tbl1]. callee-callerの対称性によるコルーチンの分類[fnref:2]

|             | symmetric coroutines | asymmetric coroutines |
|:--          | :--:           | :--:             |
| "戻る" 操作<br> & 親子関係 | ない           | ある
| Examples    | Rubyの`Fiber.transfer`, Modula-2 | だいたいのcoroutines

</center>

Symmetric coroutinesは､callee-callerに親子関係はなく､コントロールを他方に"移す"操作しか存在しない｡
Modula-2に搭載されたサブルーチンを行き来する機能として"coroutine"という名前が使用された｡このcoroutinesがsymmetricであった｡
のちの構造化プログラミングの流れで､制御フローを明確にし柔軟性を高めるためにasymmetric coroutinesが生まれた｡
Asymmetric onesは対象のcoroutineを"呼び出す"操作と､現在のcoroutineから"脱出する"操作の2つがある｡

さらに､asymmetric coroutinesをコールスタックの有無で細分化できる([ref:tbl2])｡

<center>
[label:tbl2]
表[ref:tbl2]. stackfulnessによる分類[fnref:2]

|              | stackful         | stackless |
|:--           | :--              | :--       |
|関数をまたいだ呼び出し | できる           | できない  |
| examples     | Luaのcoroutine, RubyのFiber | Rustのcoroutine, JSのGenerator|

</center>

Stackful coroutinesは関数呼び出しをまたいだ､複数の関数の階層をもつことができる｡
一方stackless onesは関数呼び出しをまたぐことができない｡
この制約は､特にJSやPythonなどでは文法によってenforceされている｡

```js :JSのGenerator[fnref:3]
// `yield`はfunction*の中でのみ使える予約語
const foo = function* () {
  yield 'a';
  yield 'b';
  yield 'c';
};

let str = '';
for (const val of foo()) {
  str = str + val;
}

console.log(str);
// Expected output: "abc"
```

# Symmetric coroutines

まずはsymettric coroutinesをgoroutines+channelsから作っていく｡
ナイーブに考えると次のような対応が取れる([ref:symco-goch])｡

<center>
[label:symco-goch]
表[ref:symco-goch]. Symmetric coroutinesとgoroutines+channelsの対応

| symmetric coroutines | goroutines+channels|
|:-:|:-:|
|スレッド | goroutine |
|transfer | channel send/recv|

</center>

というか､対応付けるための材料が他に無いよね｡
Channelsはrecvしてる側に対してsendするためcallee-callerの関係が生まれそうだが､send側にrecv側は戻す必要がないので､実は関係としてはフラットである([ref:round])｡

```go :[label:round][ref:round]. 一周できるフラットな関係
package main

import "fmt"

func main() {
	r1 := make(chan int)
	r2 := make(chan int)
	r3 := make(chan int)

	go func() {
		fmt.Println("g1")
		r1 <- 0
	}()

	go func() {
		<- r1
		fmt.Println("g2")
		r2 <- 0
	}()

	go func() {
		<- r2
		fmt.Println("g3")
		r3 <- 0
	}()

	<-r3
	// g1
	// g2
	// g3
}
```

では､RubyのFiberを使ってみよう([ref:fiber_transfer])｡

```ruby :[label:fiber_transfer][ref:fiber_transfer]. Fiber#transfer
f1, f2, f3 = nil, nil, nil # mutual recursiveなので変数だけ確保
f1 = Fiber.new {|_|
  puts "f1"
  f2.transfer(0)
}
f2 = Fiber.new {|_|
  puts "f2"
  f3.transfer(0)
}
f3 = Fiber.new {|_|
  puts "f3"
}

f1.transfer(0)
```

だいたい同じだわな｡
Goroutinesは即起動する一方でcoroutinesは初回の呼び出しで起動するところは異なる点｡
この雰囲気から､1つのchannelを持つgoroutineがあればなんか良さそうだ([ref:sym-go])｡

```go :[label:sym-go][ref:sym-go]. symmetric coroutineの実装
package main

type T struct {
	ch chan any
}

func New(f func(any) any) *T {
	ch := make(chan any)
	co := &T{ch}

	go func() {
		var res any
		defer func() {
			ch <- res
		}()

		res = f(<-ch)
	}()

	return co
}

func (co *T) Transfer(v any) any {
	co.ch <- v
	return <-co.ch
}

func main() {
	var f1, f2, f3 *symgoT

	f1 = New(func(any) any {
		fmt.Println("f1")
		return f2.Transfer(0)
	})

	f2 = New(func(any) any {
		fmt.Println("f2")
		return f3.Transfer(0)
	})

	f3 = New(func(any) any {
		fmt.Println("f3")
		return 0
	})

	f1.Transfer(0)
}
// f1
// f2
// f3
```

ラップされる関数の引数をchannel recvが受け取るようにすることで､coroutineの起動待ちがエミュレートできる｡
Goroutine自体は値としての実態がないので､1回走らせてchannelで差し押さえておいてそのchannelのポインタをそのまま返す｡
最終的に呼ばれる`Transfer`に値を返すために､ラップされる関数の戻り値を`defer`でchannelに流し込む｡
いろんな型が出たり入ったりするので`any`です[^4]｡

# asymmetric stackless coroutinesとchannelsの管理

    通信用のchannelの管理とasymmetric stacklessの関連性｡
    実際の使用例や利点を示す｡

では今作ったsymmetric coroutinesをasymmetricにしていこう｡
表[ref:tbl1]を見るにcallee-caller関係を作ればいいわけだから､いいわけですね｡

# asymmetric stackful coroutinesとcall stackの関係

    call stackをコルーチンにどのように適用するか｡
    その結果としての動作や利益｡

# 結論

    goroutinesとchannelsからコルーチンの分類を理解する利点｡
    Goとcoroutinesを使用する際のヒントや考慮点｡

# GoroutinesとChannels

[^1]: <https://nymphium.github.io/2019/01/27/stackfulness-of-coroutines.html>
[^2]: [fnref:1] の表を参照､修正
[^3]: <https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Generator>より引用､筆者によるコメント
[^4]: Typed coroutinesをご所望の場合はこのあたりを参照のこと <https://link.springer.com/chapter/10.1007/978-3-642-22941-1_2> <https://arxiv.org/abs/2308.10548> けっこう大変そうではある｡
