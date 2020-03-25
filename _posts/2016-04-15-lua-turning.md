---
latouy: post
title: Luaちょっとしたコードチューニング
tags: [Lua]
---

#1. はじめに
こんにちは､びしょ〜じょです｡Luaに速度を求めるならもっと別の言語で書いたほうが良いんですが､そうはいってもLuaが書きたい! という人は多い｡ボクも書きたい｡まずはちょっとしたところから速度向上を図ろうということです｡

今回は*PUC Lua*(https://www.lua.org が提供する､もっともなじみのある本家Luaインタプリタ) についてみていきます｡

##1.1 環境
以下の環境でテストしました｡

|key|value|
|---:|---|
|CPU|Intel(R) Core(TM) i5-5200U CPU @ 2.20GHz|
|OS| Arch Linux 4.4.5-1-ARCH|
|||
|Lua|PUC Lua 5.3.2|


tmpfsでマウントしたディレクトリ上で作業した｡

##1.2 `_ENV`
とにかくループするのでループ回数を設定しておく｡
ついでに実行時間の計測を簡単にするものを書く｡

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

#2. (PUC) Lua
まずはpure Luaです｡実を言うとLuaJITでも有効ですが､pure Luaでもイケる､ということでね｡

##2.1 local
基本中の基本｡Luaは *変数宣言時に`local`prefixをつけないとすべてグローバルな変数になる* ので､毎回`local hoge = 1`などと書くことが多い｡
では書かないとどうなるか?

```lua
--[[
2_1_nolocal.lua

loacalなんて知らねえぜ
]]

local _ENV = setmetatable(require'testsuite', {__index=_ENV})

print(get_exectime(function()
  for x = 1, REP do
    a = x
  end
end))
```

```lua
--[[
2_1_witlocal.lua
jj
localをマメに書く
]]

local _ENV = setmetatable(require'testsuite', {__index=_ENV})

print(get_exectime(function()
  for x = 1, REP do
    local a = x
  end
end))
```

### 結果
|file|実行時間(sec)|
|---:|---|
|nolocal|9.699923992157|
|**withlocal**|**5.5564069747925**|

2倍近い差が出ました｡ワオ

##2.2 for
ループを何回まわしたかカウントしたくなる人もいます｡

```lua
--[[
2_2_docnt.lua

whileでn回リピートする｡ループとカウントの変数が一つしかないので見た目は良いかもしれない｡
]]

local _ENV = setmetatable(require'testsuite', {__index=_ENV})

print(get_exectime(function()
  local cnt = 0
  while cnt <= REP do
    -- something
    cnt = cnt + 1
  end
end))
```
一方でこうも書ける｡

```lua
--[[
2_2_forcnt.lua
]]

local _ENV = setmetatable(require'testsuite', {__index=_ENV})

print(get_exectime(function()
  local cnt = 0
  for x = 0, REP do
    -- somethihg
    cnt = cnt + 1
  end
end))
```
### 結果

|file|実行時間(sec)|
|---:|---|
|docnt|13.829463998477|
|**forcnt**|**5.6234021186829**|

約2倍の差が出た｡これはfor文が変数に足し算して更新してるのに対し､while文は1回ごとに数値の比較をしているという点で差がでたようだ｡

##2.3 `#t > 0`
table `t`の長さは0か? という問いはLuaでよく使われます｡`#t > 0`という式は多くのコードに存在する｡

```lua
--[[
2_3_sharpIfZero.lua
]]

local _ENV = setmetatable(require'testsuite', {__index=_ENV})

-- #t == 500000000だとメモリが足りないと怒られるので200000000に減らしました｡
local REP = 200000000
local t = {}

-- おっきなテーブルをつくる
for i = 1, REP do
  t[i] = i
end

print(get_exectime(function()
  for _ = 1, REP do
    if #t > 0 then      
      table.remove(t)
    end
  end
end))
```

また`t[1]`を見ることでもいけそうですね｡

```lua
--[[
2_3_indexIfZero.lua
]]

local _ENV = setmetatable(require'testsuite', {__index=_ENV})

local REP = 200000000
local t = {}

-- おっきなテーブルをつくる
for i = 1, REP do
  t[i] = i
end

print(get_exectime(function()
  for _ = 1, REP do
    if t[1] --[[ここが変更点]] > 0 then      
      table.remove(t)
    end
  end
end))
```


Luaには[`next`](https://www.lua.org/manual/5.3/manual.html#pdf-next)という関数がある｡
第1引数にtable､第2引数にindexを渡すと､table[index]**の次**の*key*と*value*を返す｡
**次** is 何なんですが､辞書順っぽいですねこれは｡Luaのtableといえばつまるところ連想配列のようなもので､はい｡

ここでindexが`nil`のとき､tableの最初のkeyとvalueを返します｡
**tableが空のとき`nil`を返します**｡`#t > 0`の代わりにこれを使うことができそうですね｡

```lua
--[[
2_3_nextIfZero.lua
]]

local _ENV = setmetatable(require'testsuite', {__index=_ENV})

local REP = 200000000
local t = {}

-- おっきなテーブルをつくる
for i = 1, REP do
  t[i] = i
end

print(get_exectime(function()
  for _ = 1, REP do
    if next(t)--[[ここが変更点]] then
      table.remove(t)
    end
  end
end))
```

### 結果
|file|実行時間(sec)|
|---:|---|
|sharpIfZero|183.32232999801|
|**indexIfZero**|**99.531152645747**|
|nextIfZero|105.69196510315|

`next`を力説しておきながらindexIfZeroに負けましたね｡なぜかというと`next`のあとに`t[1]`を思い出したからです｡

### 備考
`next`くん､実はダメでは疑惑ということで`t = {}`のときを見てみる｡

```lua
--[[
2_3_sharpConstantZero.lua
]]

local _ENV = setmetatable(require'testsuite', {__index=_ENV})

local REP = 200000000
local t = {}

print(get_exectime(function()
  for a = 1, REP do
    if #t > 0 --[[まずは#t]] then
      table.remove(t)
    end
  end
end))
```

```lua
--[[
2_3_indexConstantZero.lua
]]

local _ENV = setmetatable(require'testsuite', {__index=_ENV})

local REP = 200000000
local t = {}

print(get_exectime(function()
  for a = 1, REP do
    if t[1] --[[頭を見る]] then
      table.remove(t)
    end
  end
end))
```


```lua
--[[
2_3_nextConstantZero.lua
]]

local _ENV = setmetatable(require'testsuite', {__index=_ENV})

local REP = 200000000
local t = {}

print(get_exectime(function()
  for a = 1, REP do
    if next(t) --[[最後にnext]] then
      table.remove(t)
    end
  end
end))
```

#### 結果

|file|実行時間(sec)|
|---:|---|
|sharpConstantZero|5.9717473189036|
|**indexConstantZero**|**4.908634742101**|
|*nextConstantZero*|*15.312809944153*|

わずかですがindexの勝ちです｡そして`next`が3倍遅いンゴねぇ…｡

#3. おわりに
手動最適化できる箇所はまだまだあると思いますがボクが気づいたのはこの辺でした｡みなさんもぜひ最適化できそうな箇所をシェアしてください｡
末尾最適化もあるので書こうと思いましたが心が折れました｡

*LuaJIT2.1の命令に基づいた関数選び* などもやろうと思ったんですが､ちょっと重くなりそうなんでまた(気が向いたら)書きます｡
section 2.がLuaなのは途中まで書く気があったという意志の現れです :triumph:
