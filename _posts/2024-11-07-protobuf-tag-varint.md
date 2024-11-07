---
layout: post
title: Protobufのフィールド番号は15以下のほうがSDGs - VARINTのvariability
tags: [Protocol Buffers]
---

こんにちは､びしょ〜じょです｡
今日は皆さん大好きprotobufのbinary wire formatのVARINTの話｡

# おさらい

こんなmessageがあるとする(プログラム[ref:helloproto])｡

[label:helloproto]
```proto : [ref:helloproto] hello.proto
message Hello {
    string name = 1;
}
```

あるんですが､binary wire formatではフィールド名は消えてフィールド番号と値のペアになるんで､`{ 1: "John" }`のようなものになる｡
実際にエンコードすると､次のようになる(図[ref:johnbin])｡

[label:johnbin]
```bin : 図[ref:johnbin] { 1: "John" } のbinary wire format
0a 04 4a 6f 68 6e
```

[Protobufのドキュメント](https://protobuf.dev/programming-guides/encoding/)を読むと､binary wire formatは`(tag value)*`で表されている｡
で`value`はここでは`"John"`(`4a 6f 68 6e`)なはずなんで､`tag`は`1:`(`0a 04`)ですな｡
`tag`はVARINTで定義され､MSB(most-significant bit)+7bitsの値から成る｡
MSBは今回用がないんで`0`なんで､7bitsでフィールド番号とwire typeを示す｡
文字列なのでwire typeはLEN (`010`)､フィールド番号は1だから､`0 0001 010` → `0a`(図[ref:wakariyasuizu])｡

[label:wakariyasuizu]
```:[ref:wakariyasuizu] 極めてわかりやすい図
0a
---------------------- to bin
0000 1010
----------------------
0     0001             010
^     ^                ^
MSB   フィールド番号   wire type
```

LEN wire typeなので､後続のデータの長さが必要になり`"John".length = 0x04`｡
いいじゃないですか｡

コマンドでも念の為やると

```sh
$ xxd -r -ps <<< "0a044a6f686e" | protoscope
1: {"John"}
```

ええやんか｡

# フィールド番号が大きいとどうなるだ?
VARINTなので､n-bytesになる｡
話おわりなんで皆さん帰ってもらってOKです｡

以下解説

---

[ref:johnbin]の解説で､フィールド番号1だと`0 0001 xxx`(`xxx`はwire type)にエンコードされた｡
MSBとかいう訳わかんねー奴を考えると､0b1111=15より大きい場合どうなるか｡
MSBとかいう訳わかんねー奴を使う｡
0b10000以上のフィールド番号は､複数bytesにまたがって表現される｡
最初の1byteではwire type(+MSB)を含めるので4bits分｡
後続のデータは､MSBが0まではずっとtrailing dataとして読み込まれる｡

フィールド番号が0b100000010000001111のI64 type(`001`)の`42`を考える(`{ 132111: 42i64 }`)｡
VARINTはリトルエンディアン､最初は4bits､MSBを除くと1byteに7bitsの情報､なので

```
100000010000001111
-------------------- 分割
1000000 1000000 1111
-------------------- big endian
1111 1000000 1000000
-------------------- VARINT
1    1111 001  1 1000000 0 1000000
^         ^    ^         ^
MSB       I64  MSB       MSB (end)
-------------------- to hex
f9             c0        40
```

I64は〜わからんが`2a00000000000000`らしいです｡
なんで､

```
f9 c0 40 2a 00 00 00 00 00 00 00
```

になる｡

# 結論
Protobufでフィールド番号が15より大きいフィールドの場合､エンコーディング時にタグが2bytes以上になる｡
不必要に大きなフィールド番号はprotobufでメッセージを送受信するときに通信量に負荷がかかるためSDGsでない｡
したがって可能な限りフィールド番号は小さくしましょう｡

フィールド番号$k$に対し､$n\ \mathrm{for}\ 2^{\left(4+7\left(n-1\right)\right)}\leq k+1 \lt 2^{\left(4+7n\right)}$bytes必要になるので､ネットワーク環境に配慮したフィールド番号の付与をお願いします｡

