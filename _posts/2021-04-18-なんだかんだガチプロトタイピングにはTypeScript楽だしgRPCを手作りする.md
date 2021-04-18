---
layout: post
title: なんだかんだガチプロトタイピングにはTypeScript楽だしgRPCを手作りする
tags: [TypeScript, gRPC]
---

<!--sectionize on-->

こんにちは､びしょ～じょです｡
労働に手を染めて1年経ったんですが､特に深い話はないです｡
しかし金で殴る力が強くなったので､沖縄行きの飛行機に乗り遅れても翌日の航空券を買うという技ができました｡
美ら海水族館の往復で乗ったバスの中で読んだ『帰りたくない―少女沖縄連れ去り事件―』が1､2番目に印象に残っています｡
いい話ですね｡

# はじめに
今回はHTTP/2を喋るgRPCサーバを実装する｡
特に､gRPCプロトコルの理解のためにHTTP/2から上はgRPCのライブラリは使わずに手でやっていく｡
protobufのシリアライズ/デシリアライズはライブラリでやってもらう｡

なんと今回はTypeScriptで実装する｡
型システムとか意味論とか言語設計には言いたいことがいっぱいあるが､コミュニティがメチャクソデカいんでライブラリがいっぱいあるし脳死で書いて動かすまでは極めて楽ではある｡

今回使うライブラリは､新しめのNodeの標準ライブラリの[http2](https://nodejs.org/api/http2.html)と[ts-protoc-gen](https://github.com/improbable-eng/ts-protoc-gen)｡
クライアントはダルいんで[grpcurl](https://github.com/fullstorydev/grpcurl)を使う｡
便利｡

gRPC over HTTP/2はとりあえず公式のspec[fnref:1]を読めば全部OK!!
どいうったものを送ればいいのかABNFで書かれており追いやすい｡

では､いきます｡

# proto
こんな感じのprotoを用意する｡

```proto:echo.proto
syntax = "proto3";

package services;

service Echo {
  rpc Call (EchoRequest) returns (EchoResponse);
}

message EchoRequest {
  string message = 1;
}

message EchoResponse {
  string message = 1;
}
```

これを実装しているサーバの`services.Echo/Call`に`EchoRequest`をPOSTすると`EchoResponse`が返ってくる｡
サービス名は[こちら](https://github.com/grpc/grpc/blob/master/doc/PROTOCOL-HTTP2.md#appendix-a---grpc-for-protobuf)に規則が書かれている｡

# まずは受ける
## 仕様をよむ
とりあえずどういったリクエストがやってくるか見る｡
[fnref:1]曰く､

|rule|op|
|--:|:--
| Request | Request-Headers *Length-Prefixed-Message EOS

とのこと｡
さらに定義を展開すると､

|rule|op|
|--:|:--
| Length-Prefixed-Message | Compressed-Flag Message-Length Message
| Compressed-Flag | 0 / 1 # encoded as 1 byte unsigned integer
| Message-Length | {length of Message} # encoded as 4 byte unsigned integer (big endian)
| Message | *{binary octet}

おk ***完全に理解した***

## 実装
やるだけ｡

```typescript:echo-service.ts
import * as H2 from 'http2';

export const call = (request: H2.Http2ServerRequest, response: H2.Http2ServerResponse) => {
    const chunks: Buffer[] = [];

    request.on('data', (chunk: Buffer) => chunks.push(chunk));
    request.on('end', () => {
        console.log(chunks);
        response.end();
    });
};
```

```typescript:index.ts
import * as H2 from 'http2';
import * as EchoService from './echo-service'

const server = H2.createServer((request, response) => {
    switch (`${request.headers[':method']}${request.headers[':path']}`) {
        case 'POST/services.Echo/Call':
            EchoService.call(request, response);
  }
});

const port = 50051;
server.listen(port, () => {
    console.log(`listen on localhost:${port}`);
});
```

50051番ポートでとりえあず受ける｡
[ts-node](https://github.com/TypeStrong/ts-node)で適当に動かす｡

```shell-session
$ npx ts-node index.ts
listen on localhost:50051
```

叩く｡

```shell-session:クライアント
$ grpcurl -vv -plaintext -proto echo.proto -d '{"message": "hello"}' localhost:50051 services.Echo/Call

Resolved method descriptor:
rpc Call ( .services.EchoRequest ) returns ( .services.EchoResponse );

Request metadata to send:
(empty)

Response headers received:
(empty)

Response trailers received:
(empty)
Sent 1 request and received 0 responses
ERROR:
  Code: Unknown
  Message: OK: HTTP status code 200; transport: missing content-type field )
```
正しく怒られが発生している｡

```shell-session:サバログ
[ <Buffer 00 00 00 00 07 0a 05 68 65 6c 6c 6f> ]
```

長さ1の`Array<Buffer>`が`console.log`されたことがわかる｡
JavaScriptはそうなっている｡
先頭5バイトをまず読むと､

- 先頭の`\x00`はCompressed-Flag(uncompressed)
- `\x00 \x00 \x00 \x07`はメッセージの長さ(7)

となる｡
そして､続く7バイト`\x0a \x05 \x68 \x65 \x6c x6c \x6f`がメッセージである｡

今回は深堀りしないが､[この辺](https://developers.google.com/protocol-buffers/docs/encoding)を読むと､1番目のフィールド(`EchoRequest`の`message`)のlength-delimited type(`message`の型､`string`)が5バイト連なっており(`"hello".length`)､`\x68 ...`(`"hello"`)というバイト列がやってきていることが読める｡

いい感じだ｡

# デシリアライズする
さてprotobufのデータがやってきたので､ここで初めてprotobufを気にかける｡
ts-protoc-genをしてこの通り

```bash:bin/protogen.sh
#!/usr/bin/bash

set -eu

protoc \
  --plugin="protoc-plugin-ts=$(npx which protoc-gen-ts)" \
  --js_out="import_style=commonjs,binary:$2" \
  --ts_out="$2" \
  $1
```

```shell-session
$ mkdir pb
$ ./bin/protogen.sh echo.proto pb
$ ls pb
echo_pb.d.ts  echo_pb.js
```

よし｡
こいつらを引っ張ってなんかいい感じにやる｡

```typescript:echo-service.ts
import * as H2 from 'http2';
import * as Echo from './pb/echo_pb';

...
```

とりあえず`Echo.EchoRequest.deserializeBinary`すれば`EchoRequest`が手に入るようだ｡
`Uint8Array`を渡す必要がある｡
`Uint8Array`は`Uint8`､つまり1要素が`1`～`255`の`number`から成る`Array`である｡
型は無いんでランタイムに値を詰め込むだけ｡
確かにバイト列がやってくるんで`Uint8Array`なのね｡

いい感じのライブラリが標準に無いし知らんのでこの辺を実装する｡

```typescript:hexdata.ts
import * as Assert from 'assert';

type T = Uint8Array;

const encoder = new TextEncoder();
const decoder = new TextDecoder();

export const fromString = (v: string): T => encoder.encode(v);
export const fromBit = (i: boolean): T => Uint8Array.of(i ? 1 : 0);
// uint32をいい感じにuint8 arrayに敷き詰める
export const fromByte = (i: number): T => {
    // がんばる
    Assert.ok(i < 2 ** 32);
    return new Uint8Array(Uint32Array.of(i).buffer).reverse();
};
// ビャッとやる
export const toString = (...ts: T[]) => {
    const tmp = new Uint8Array(ts.reduce((acc, t) => acc + t.length, 0));

    ts.reduce((offset, t) => {
        tmp.set(t, offset);
        return t.length + offset;
    }, 0);

    return decoder.decode(tmp);
};
```

まあ真面目にやらんでいいのでこんなもんでしょう｡

ではこれを使って`EchoService.call`を変更する｡
先述のとおり､request bodyを構成する`Array<Buffer>`が来るのでこれを合体して`Buffer`にする｡
request bodyには先頭5byteにmessageの情報が入っているが､今回は雑に捨てる｡

```typescript:echo-service.ts
import * as H2 from 'http2';
import * as Echo from './pb/echo_pb'
import * as HexData from './hexdata'

export const call = (request: H2.Http2ServerRequest, response: H2.Http2ServerResponse) => {
    const chunks: Buffer[] = [];

    request.on('data', (chunk: Buffer) => chunks.push(chunk));
    request.on('end', () => {
        // Array<Buffer>を合体して雑に5byte捨てる
        const echoRequest = Echo.EchoRequest.deserializeBinary(HexData.fromString(chunks.join().substring(5)));
        console.log(JSON.stringify(echoRequest.toObject()));
        response.end();
    });
};
```

では同様に動かすと

```shell-session
$ npx ts-node index.ts
listen on localhost:50051
{"message":"hello"}
```

イージャン｡

# そして返す……がしかし
いい感じなったんでこれを返す｡

|rule|op|
|--:|:--
| Response | (Response-Headers *Length-Prefixed-Message Trailers) / Trailers-Only

これを返す｡
`Trailers-Only`は今回無視する[^2]｡

`Response-Headers`は

|rule|op|
|--:|:--
| Response-Headers | HTTP-Status [Message-Encoding] [Message-Accept-Encoding] Content-Type *Custom-Metadata
| HTTP-Status | ":status 200"
| Message-Encoding | "grpc-encoding" Content-Coding
| Message-Accept-Encoding | "grpc-accept-encoding" Content-Coding *("," Content-Coding)
| Content-Type | "content-type" "application/grpc" [("+proto" / "+json" / {custom})]
| Custom-Metadata | (省略)[^3]

`Trailers`は

|rule|op|
|--:|:--
| Trailers | Status [Status-Message] *Custom-Metadata
| Status | "grpc-status" 1*DIGIT ; 0-9
| Status-Message | "grpc-message" Percent-Encoded
| Percent-Encoded | 1*(Percent-Byte-Unencoded / Percent-Byte-Encoded)
| Percent-Byte-Unencoded | 1*( %x20-%x24 / %x26-%x7E ) ; space and VCHAR, except %
| Percent-Byte-Encoded | "%" 2HEXDIGIT ; 0-9 A-F

サーバは常にHTTP status200を返し､gRPCのstatusとして`grpc-status`を利用するようだ｡

今回は異常系も考えんでいいか｡

```ts:echo-service.ts
...
    request.on('data', (chunk: Buffer) => chunks.push(chunk));
    request.on('end', () => {
        const echoRequest = decodeEchoRequest(chunks.join().substring(5));
        const echoResponse = new Echo.EchoResponse();
        echoResponse.setMessage(echoRequest.getMessage());
        const msg = echoResponse.serializeBinary();
        const len = HexData.fromByte(msg.length);
        // compressしない
        const compression = HexData.fromBit(false);
        const responseBody = HexData.toString(compression, len, msg);
        response.writeHead(200, { 'content-type': 'application/grpc+proto' });
        response.write(responseBody);
        response.write('grpc-status: 0');
        response.end();
    });
...
```

よし｡
サーバを再起動して`grpcurl`をさっきと同じ引数で叩く｡

```shell-session
$ grpcurl ...

Resolved method descriptor:
rpc Call ( .services.EchoRequest ) returns ( .services.EchoResponse );

Request metadata to send:
(empty)

Response headers received:
content-type: application/grpc+proto
date: Sat, 17 Apr 2021 19:43:51 GMT

Response trailers received:
(empty)
Sent 1 request and received 0 responses
ERROR:
  Code: ResourceExhausted
  Message: grpc: received message larger than max (1919968045 vs. 4194304)
```

は?

## HTTP/2の`trailers`
[fnref:1]をガッコリ読むと

> For responses end-of-stream is indicated by the presence of the END_STREAM flag on the last received HEADERS frame that carries Trailers.

`END_STREAM`と`HEADERS` 何? ^^;

これはHTTP/2の話になる｡
ちょうど↑の文のちょっと下にHTTP/2のframing sequenceの例が挙がっている｡
レスポンスの方を見ると､

```
HEADERS (flags = END_HEADERS)
:status = 200
grpc-encoding = gzip
content-type = application/grpc+proto

DATA
<Length-Prefixed Message>

HEADERS (flags = END_STREAM, END_HEADERS)
grpc-status = 0 # OK
trace-proto-bin = jher831yy13JHy3hc
```

なんすかこれ｡
確かに､[RFC](https://tools.ietf.org/html/rfc7540#section-8.1)を見るとtrailing header fileldsというのが存在するようだ｡
勉強不足でした｡

つまりtrailing header fieldsに`grpc-status`とか`grpc-message`を突っ込めばいいらしい｡
streaming rpcをやっていってエラーを吐くときにメッセージを返しやすいとかなのかしら｡

## あとはやるだけ

```ts:echo-server.ts
...
        response.writeHead(200, { 'content-type': 'application/grpc+proto' });
        response.write(responseBody);
        response.addTrailers({ 'grpc-status': 0 });
        response.end();
...
```

叩く｡

```shell-session
$ grpcurl ...

Resolved method descriptor:
rpc Call ( .services.EchoRequest ) returns ( .services.EchoResponse );

Request metadata to send:
(empty)

Response headers received:
content-type: application/grpc+proto
date: Sat, 17 Apr 2021 21:00:57 GMT

Estimated response size: 7 bytes

Response contents:
{
  "message": "hello"
}

Response trailers received:
(empty)
Sent 1 request and received 1 response )
```

あーキタキタこれこれ

# おわりに
あ～～～～～～～今日もgRPCを完全に理解しちまったな……｡
完全に理解したんですが､[fnref:1]の`Request`を見ると`grpc-timeout`とか`grpc-accept-encoding`とか`grpc-message-type`とかあるし､ステータスコードもなんか色々あるし､当然ながらgRPCのライブラリを使ったほうがよい｡
でもgRPCは何をやってるか知ってると良いことがあるかもしれない｡gRPCライブラリのない言語でgRPCサーバをやっていきたい場合など[^4]｡

今回のコード全体はこちら

{% twicard "" https://github.com/Nymphium/grpc-over-http2-by-hand %}

---

[^1]: https://github.com/grpc/grpc/blob/master/doc/PROTOCOL-HTTP2.md
[^2]: エラーを返す場合に使う｡voidを返すrpcがあるならその場合もあるかもしれんけどprotobufの仕様上ない?
[^3]: key-value形式で色々メタデータを送れる｡今回は使わないので省略した｡
[^4]: 筆者はOCamlでgRPCサーバを実装したかったが､gRPCのOCaml bindingがなかったために本稿を書ける程度にはgRPCについて調べたという経緯がある｡HTTP/2に関する部分がかなり渋いので諦めてenvoyでHTTP/2と1.1をやっていったほうが良いかなと思っている｡
