---
layout: post
title: Lua5.2から5.3への内部表現について💢
tags: [Lua]
---
<!--sectionize on-->
こんにちは､びしょ〜じょです｡極めて眠いホトトギス

# はじめに
Lua5.2のVMのバイトコードをデコードする物体を用いて､Lua5.3のVMのバイトコードをデコードしようとしたら結構つまづきました｡という話｡
Luaはわりと､関数が減っただ増えただ程度の変更しか無く､互換性は高いかのように見えますが､内部ではガッツリ変わってるんですねぇここ2ヶ月で思い知らされました｡

# internal constant expression
luaファイルを`luac`でコンパイルすると*luac.out*というファイルが得られます｡

ところで`"hoge"`とか`3`などの定数はluac.outのfunction blockのconstants listという部分に､コード中での出現順に格納されます｡
もう少し解説すると､constants listは以下のような構造になっている｡

\\[
\[格納されている定数の数(4\mathsf{byte})\]\[定数\[種類(1\mathsf{byte}) 種類別(n\ \mathsf{byte})\]...\]
\\]

この種類がクセモノなんですねぇ…｡

# 型が増えた? integer, long string
まずこの種類について見ていきます｡constants listに現れる種類は以下のようになります｡

|type | value|
|:----|-----:|
|nil  |    00|
|bool |    01|
|number|   03|
|string |  04|

次のようなコードを考える｡

```lua
-- hoge.lua
local a = "aaaaaaaa...aaaa" -- 256文字以上で適当に､ここでは256文字とする
local b = 3.0
local c = 4
```

## until Lua 5.2
まずLua5.2でコンパイルしてバイトコードを見てみる｡

```
$ luac5.2  hoge.lua
$ xxd -g 1 luac.out
00000000: 1b 4c 75 61 52 00 01 04 08 04 08 00 19 93 0d 0a  .LuaR...........
00000010: 1a 0a 00 00 00 00 00 00 00 00 00 01 03 04 00 00  ................
00000020: 00 01 00 00 00 41 40 00 00 81 80 00 00 1f 00 80  .....A@.........
00000030: 00 03 00 00 00 04 01 01 00 00 00 00 00 00 61 61  ..............aa
00000040: 61 61 61 61 61 61 61 61 61 61 61 61 61 61 61 61  aaaaaaaaaaaaaaaa
......
00000130: 61 61 61 61 61 61 61 61 61 61 61 61 61 61 00 03  aaaaaaaaaaaaaa..
00000140: 00 00 00 00 00 00 08 40 03 00 00 00 00 00 00 10  .......@........
00000150: 40 00 00 00 00 01 00 00 00 01 00 0a 00 00 00 00  @...............
......
```

ヘッダがあり､(中略)､0x00000031からconstants listです｡
ちなみにヘッダからリトルエンディアンであることがわかるので､最初の`03 00 00 00`はつまり"3"､定数の数です｡一致していますね｡

次に定数が3つ出現順に見えますはい｡ここから本題なんやな｡

### string `a`
まず1byte､種類がみえてくるわけですが`04`ということはつまりstring､これはつまり変数`a`に格納される定数`"aaaaaa....aa"`ですね｡
次の8byteは実は文字列の長さなんですねぇ､はい｡`01 01 00 00 00 00 00 00`ということで､リトルエンディアンで解釈すると257文字ですか､この+1は`\0`ですねわかります｡
さて257byteみていくと､たしかに0x61が256個並んで最後に0x00があります｡いいですね｡ここまでで0x0000013eまで読みました｡

### number `b`, `c`
さて続きまして1byte見ると`03`ということで､numberですか｡8byte読んでみてください｡はい`00 00 00 00 00 00 08 40`ということですがまずこれをIEEE 754 単精度浮動小数点数にするんやな…｡
ではこちらをご覧ください｡

```lua
local decodenum = function(input)
  local mantissa = (input:byte(7)) % 16

  for i = 6, 1, -1 do
    mantissa = mantissa * (256 + input:byte(i))
  end

  local exponent = ((input:byte(8)) % 128) * 16 + (input:byte(7)) // 16

  if exponent == 0 then
    return 0
  end

  mantissa = (math.ldexp(mantissa, -52) + 1) * ((input:byte(8)) > 127 and -1 or 1)

  return math.ldexp(mantissa, exponent - 1023)
end

local ieee754 = string.char(0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x40)

print(decodenum(ieee754)) --> 3.0
```

はい､`3.0`ということで､`b`ですね｡OK｡0x00000147まで読みました｡

同様にして次は`4.0`ですねはい論破

## Lua 5.3
いやいや内部表現変わらんでしょ→死

ではコンパイルしてみる｡

```
$ luac5.3 hoge.lua
$ xxd -g 1 luac.out
00000000: 1b 4c 75 61 53 00 19 93 0d 0a 1a 0a 04 08 04 08  .LuaS...........
00000010: 08 78 56 00 00 00 00 00 00 00 00 00 00 00 28 77  .xV...........(w
00000020: 40 01 0a 40 68 6f 67 65 2e 6c 75 61 00 00 00 00  @..@hoge.lua....
00000030: 00 00 00 00 00 02 03 04 00 00 00 01 00 00 00 41  ...............A
00000040: 40 00 00 81 80 00 00 26 00 80 00 03 00 00 00 14  @......&........
00000050: ff 01 01 00 00 00 00 00 00 61 61 61 61 61 61 61  .........aaaaaaa
00000060: 61 61 61 61 61 61 61 61 61 61 61 61 61 61 61 61  aaaaaaaaaaaaaaaa
......
00000150: 61 61 61 61 61 61 61 61 61 03 00 00 00 00 00 00  aaaaaaaaa.......
00000160: 08 40 13 04 00 00 00 00 00 00 00 01 00 00 00 01  .@..............
......
```

ウーン､そうですか…｡0x0000004bからconstants listが始まり､`03 00 00 00`からconstantは3つということがわかるんですが…｡

### long string ←は?
1byte読みすすめると早速0x14という謎の種類が爆誕するんですねぇ実はコレLua5.3から追加されたlong stringですが内部表現のみに現れるので皆さん安心してください｡

さらに進めてみると`ff 01 01 00 00 00 00 00 00 61 61 61 61 61 ......`というよくわからない感じになってますね｡
0x61は'a'だというのはわかる｡その前の`ff 01 01 00 00 00 00 00 00`はおそらく文字列の長さなんですが､なんだこれは｡
256文字なので､0x0100か'\0'を追加した0x0101という表現がどこかにあるはずで､ありますね `01 01 00 00 00 00 00 00`｡
頭の`ff`は変わらないんで､`14 ff`がobject typeだと思っていいんじゃないでしょうか｡
で､0x100文字で`a`が出土したと｡ポイントは､'\0'はいらなくなったので`0x101 - 1` ですね｡

ネタバレをいうと､255文字以下はLua 5.2までと同じです｡0xff文字以下とそれより上を別のオブジェクトとすることで､何か良いことがあるんですかねぇ謎｡

### integer ←は?
まぁええわ｡次は`b`ですね〜ハイハイ同じ感じで`03 00 00 00 00 00 00 08 40`ですね終わり｡この時点で0x00000161まで読みました｡

次に`13`というのが来て､民衆は困惑するんですねぇ…｡と思ったけどじつはだいぶ素直で､8byte読んでみると`04 00 00 00 00 00 00 00`でこれはリトルエンディアンで読むとたちどころに`4`であることが分かってしまう｡

*まさにintegerって感じですね!* Lua 5.3からbitwise operation(`&`, `|`, `<<`, `>>`, `bit32`モジュール)が追加されたので､これを速く動かしたいという狙いなのかもしれない｡ちなみにsigned integerなので0x7fffffffffffffff(16桁)がINT\_MAXッシュ

### Lua 5.3での内部のオブジェクトの種類
つまりこう｡

|type | value| 備考|
|:----|-----:|:---|
|nil  |    00|
|bool |    01|
|number|   03|64bit float|
|integer|  13|64bit signed int|
|string |  04| 長さ255以下の文字列|
|long string| 14| 長さ256以上の文字列|

nilとboolってさぁ…`LOADNIL`命令と`LOADBOOL`命令があるんだから定数としてなんていらないんだよなぁ…｡

# ベンチマーク
long stringはどれくらい活きるのか､integerは､ファイッ

## 環境
|key|value|
|---:|---|
|CPU|Intel(R) Core(TM) i5-5200U CPU @ 2.20GHz|
|OS| Arch Linux 4.6.2-1-ARCH|

処理系はLua 5.2.5､5.3.3を使用

## Prerequirement
```
$ luarocls --local install luasock
$ luarocls-5.2 --local install luasock
```

こんなファイルを用意

```lua
--[[
testsuite.lua
]]

local sock = require'socket'

return {
  REP = 500000000, -- 感謝の5億回ループ

  -- 関数fnの実行時間を測る
  get_exectime = function(fn)
    local t1 = sock.gettime()
    fn()
    local t2 = sock.gettime()
    return t2 - t1
  end
}
```

## long string
次のようなものを考える｡メモリの確保･開放を見る｡


```lua
local _ENV = setmetatable(require'testsuite', {__index=_ENV})

print(get_exectime(function()
  for i = 1, REP do
    local str = "aaaaaaaaaaaaaaaaaaaaaaaaaaa"
  end
end))
```

こういうときbashが便利なんですよ〜〜

```bash
for ((i=0;i<10;i++)) {
  lua alloc.lua;
  sleep 3
} | awk '{i+= $1}END{print i / 10.00}'
```

|version | time(sec)|
|:---|---:|
|5.2|5.25221|
|5.3|3.72571|

```lua
local _ENV = setmetatable(require'testsuite', {__index=_ENV})

print(get_exectime(function()
  local str = "aaaaaaaaaaaaaaaaaaaaaaaaaaa" -- < 256

  for i = 1, REP do
    str:upper()
  end
end))
```

|version | time(sec)|
|:---|---:|
|5.2 |67.8894|
|5.3|68.0755|

long stringを見る｡

```lua
local _ENV = setmetatable(require'testsuite', {__index=_ENV})

print(get_exectime(function()
  for i = 1, REP do
    local str = "aaaaaaaaaaa......aaaaa" -- 256文字
  end
end))
```

|version|time(sec)|
|:---|---:|
|5.2|5.25645|
|5.3|3.72407|

```lua
local _ENV = setmetatable(require'testsuite', {__index=_ENV})

print(get_exectime(function()
  local str = "aaaaaaaaaaa......aaaaa"
  for i = 1, REP do
    str:upper()
  end
end))
```

|version|time(sec)|
|:---|---:|
|5.2|224.461|
|5.3|217.083|

あんまおもんないですね｡

とりあえずtableのkeyにつっこむか｡

```lua
local _ENV = setmetatable(require'testsuite', {__index=_ENV})

print(get_exectime(function()
  local str = "aaaaaaaaaaa......aaaaa"
	local t = {
		[str] = 3
	}
	for i = 1, REP do
		local _ = t[str]
	end
end))
```

|version|time(sec)|
|:---|---:|
|5.2|13.2316
|5.3|13.4676

あんまおもんないですね｡

## integer/number
```lua
local _ENV = setmetatable(require'testsuite', {__index=_ENV})

print(get_exectime(function()
	for i = 1, REP do
		local num = 4
	end
end))
```

|version|time(sec)|
|:---|---:|
|5.2|5.53783|
|5.3|3.91654|

おもむろにtableのkeyにつっこんでみます｡

```lua
local _ENV = setmetatable(require'testsuite', {__index=_ENV})

print(get_exectime(function()
	local num = 4.0 -- number
	local t = {1,3,5,9}
	for i = 1, REP do
		local _ = t[num]
	end
end))
```

|version|time(sec)|
|:---|---:|
|5.2|9.43846
|5.3|9.59013

はい｡

ではinteger vs numberではドウカナ…

```lua
local _ENV = setmetatable(require'testsuite', {__index=_ENV})

print(get_exectime(function()
	local num = 4 -- integer
	local t = {1,3,5,9}
	for i = 1, REP do
		local _ = t[num]
	end
end))
```

|version|time(sec)|
|:---|---:|
|5.2|9.13759
|5.3|6.32312

ｲｲﾈ･

ところで! ところでですよ奥さん｡Lua 5.3には`math.tointeger()`という関数が追加されて､機能は名前の通りです｡

```lua
local _ENV = setmetatable(require'testsuite', {__index=_ENV})

print(get_exectime(function()
	local num = 4.0
	local numi = math.tointeger(num)
	local t = {1,3,5,9}
	for i = 1, REP do
		local _ = t[numi]
	end
end))
```

てな感じでnumberからintegerに変換すると､

|version|time(sec)|
|:---|---:|
|5.2|---
|5.3|6.38205

という具合ですね｡

## さらなる詳細
`grep -rE 'LUA_(TNUMINT|TLNGSTR)' lua-5.3.3/src` してください(飽きた)｡

# おわりに
stringは何も変わらなくてつまらない感じでしたが､integer型はtableのindexingでそこそこの性能がありますね｡
ボクはbytecodeの解析時にLua 5.2のノリで5.3をやったら突然の種類追加につまづいたので､みなさんもつまづいてください｡

---
このサイトのCSSやら何やらをいじって可愛い感じになったので､可愛い気持ちになってください｡

