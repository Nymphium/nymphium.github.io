---
layout: post
title: Luaで無限リスト
tags: [Lua]
---

こんにちは､びしょ〜じょです｡
さて､Luaでも無限リストを作っていきます｡

# 無限リスト
無限リストは､例えばフィボナッチ数列のように､漸化式が与えられてそれにならってindexとvalueが無限に並んでいるリスト､という考えを持ってます｡
詳細はWikipediaなどに問い合わせてください｡

# Luaのリスト
Luaの持つデータ構造はtableただ一つです｡
tableは長さが動的な､*成長する* arrayのように使えます｡

```lua
local t = {}
print(#t) -- prints "0"
t[1] = 10
print(#t) -- prints "1"
t[2] = 3
t[3] = 100
print(#t) -- prints "4"
print(t[3]) -- prints "100"
```

内部的な話をすると､tableはarray部分とhash map部分に分かれており､さらにはarrayとして扱いたい場合にもarrayの要素が疎な場合はhash map扱いだったり…などいろいろある｡
ここはそんなことは置いといてarrayとして扱っていこう｡

# metatable
さて､無限リストの実装方法だが､metatableを使う｡tableに対する操作をmetatableで上書きすることができる｡
今回は`__index`メタメソッドを使う｡ *未定義の* keyにアクセスした場合の挙動を変更できる｡
`__index`メタ*メソッド* とは言ったが､tableを渡すこともでき､その場合は渡したtableをフォールバック先のように使うことができる｡

```lua
local t = setmetatable({1}, {__index = {nil, 2, 3}})
print(t[1]) -- prints "1", which is the element of the  table
print(t[2]) -- prints "2", which is the element of __index table

local t2 = setmetatable({1}, {
  __index = function(self, k)
    print("access", k)
    self[k] = k -- assign k as kth element
    return k
  end
})

local _ = t2[1] -- do nothing
local _ = t2[3] -- prints "access 3", assigning 3 as 3rd element
local _ = t2[3] -- do NOTHING
```

`self`というのは予約語でもなんでもなく､`__index`メタメソッドの第1引数にはオリジナルのtableが入るので､わかりやすい変数名として`self`がよく用いられています｡

"**未定義の** keyにアクセスした場合の挙動を変更できる"というのが重要で､ オリジナルのtableに計算済みの値をメモできる｡
もうなんとなく分かってくるんじゃないでしょうか｡

# 実装すっぺ
例として次のような漸化式の無限リストを考える｡
$$
\begin{array}{l}
e_1 = 1\\\\
e_n=e_{n - 1} + n 
\end{array}
$$

*Luaは1オリジン*なんでそれに習います｡*Luaは1オリジン*です｡大事なことなので2度言いました｡*Luaは1オリジン*｡

```lua
local t = setmetatable({}, {
  __index = function(self, k)
    if k == 1 then
      self[k] = 1
      return 1
    else
      local n1 = self[k - 1]
        local n = n1 + k
        self[k] = n
        return n
    end
  end
})
```

いいんじゃないでしょうか｡
さてこれで使ってみると…｡

```lua
print(t[100]) -- prints "5050"
print(t[1000]) --[[
./test.lua:33: C stack overflow
stack traceback:
        ./test.lua:33: in metamethod '__index'
        ./test.lua:33: in metamethod '__index'
        ./test.lua:33: in metamethod '__index'
        ./test.lua:33: in metamethod '__index'
        ./test.lua:33: in metamethod '__index'
        ./test.lua:33: in metamethod '__index'
        ./test.lua:33: in metamethod '__index'
        ./test.lua:33: in metamethod '__index'
        ./test.lua:33: in metamethod '__index'
        ./test.lua:33: in metamethod '__index'
        ...
        ./test.lua:33: in metamethod '__index'
        ./test.lua:33: in metamethod '__index'
        ./test.lua:33: in metamethod '__index'
        ./test.lua:33: in metamethod '__index'
        ./test.lua:33: in metamethod '__index'
        ./test.lua:33: in metamethod '__index'
        ./test.lua:33: in metamethod '__index'
        ./test.lua:33: in metamethod '__index'
        ./test.lua:33: in metamethod '__index'
        stdin:1: in main chunk
        [C]: in ?
]]
```

ギャ〜という感じです｡`self[k - 1]`が未定義の場合､`__index`メタメソッドを再帰的に呼ぶことになるので､2行目ではメモ化が済んでない`self[101]`~`self[999]`までを再帰的に計算するためにスタックオーバーフローしてるわけです｡
あるていどの間隔でアクセスしていくとメモ化が無理なく進み(?)スタックオーバーフローしないことがわかります｡

```lua
print(t[100])
print(t[200])
......
print(t[900])
print(t[1000]) -- prints "500500"
```

まさかスタックオーバーフロー回避のためにいちいちこんなことを…? いやいやその必要はありません｡
スタックオーバーフローせずに再帰を深くできる方法としてCPSが考えられます｡

# CPS(Continuation Passing Style, 継続渡し方式)
CPSとは､残りの計算(継続)を関数として表現し､現在終わった計算の結果をその関数に渡していきます｡
詳細はWikipediaなどを参照ください｡
CPSに変形することにより全ての関数は末尾呼び出しになります｡嬉しいことにLua VMでは`TAILCALL`という命令があり関数呼出しの命令`CALL`とリターン命令`RETURN`を一度にやってくれます｡これによりLua VM内でコールスタックが伸びていくことなく関数を呼びまくれるわけですな｡


```lua
local t
do
  local function idxk(self, key, k)
    if key == 1 then
      self[key] = 1
      return k(1)
    else
      -- rawget関数で__indexメタメソッドを経由せず直接オリジナルのtableにアクセス
      local v = rawget(self, key)

      if not v then
        -- self[key]が未定義の場合
        return idxk(self, key - 1, function(n1)
          local n = n1 + key
          self[key] = n
          return k(n)
        end)
      else
        return k(v)
      end
    end
  end

  t = setmetatable({}, {
    __index = function(self, k)
      return idxk(self, k, function(i) return i end)
   end
  })
end
```

Luaでは[無名の再帰関数を定義する方法](http://nymphium.github.io/2016/10/20/Lua%E3%81%AE%E7%84%A1%E5%90%8D%E5%86%8D%E5%B8%B0.html)もありますが､コストがかかるのでどうしても無名関数で再帰したいとき以外は使わないほうが良いでしょう｡
ということで`idxk`という関数を外で定義し､`__index`メタメソッドに登録するときに恒等関数を渡しています｡

これでどうや｡
 
```lua
print(t[10000]) -- prints "50005000"
```

いきなり10000目の要素を計算してもスタックオーバーフローしません｡良いですね｡
100000目くらいの要素へのアクセスになると､2回アクセスすると1回計算して次はキャッシュから引っ張ってきたことが分かると思います｡

