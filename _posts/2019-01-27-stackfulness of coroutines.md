---
layout: post
title: stackfulness of coroutines
tags: [coroutines]
---

<!--sectionize on-->

こんにちは､びしょ〜じょです｡
気づいたら1月も終わりますね｡
お前も俺も､もう終わりだ｡

# はじめに
研究ではコルーチンを使っている｡
ここでひとつコルーチンについてまとめておきたい｡
特にstackfulnessについての考察をこれまでおこなっていなかったため､そこに重点を置く｡
本稿では文献[fnref: 1]を参考にする｡

# 対称性による分類
コルーチンとは､一時停止､再開のできるサブルーチンを指す｡
コルーチンを呼び出した呼び出し元にコントロールを戻す操作の有無により､コルーチンを対称コルーチンと*非*対称コルーチンの2種類に分けることができる(図[ref:tbl1])｡


<center>
[label:tbl1]
表[ref:tbl1]. コルーチンの対称性による分類
</center>

|             | 対称コルーチン | 非対照コルーチン |
|:--          | :--:           | :--:             |
| "戻る" 操作 | ない           | ある

対称コルーチンを持つプログラム言語は筆者は知らない｡
非対称コルーチンはわりとメジャーな機能で､コルーチンやFiberと言われる言語機能は概ね非対称コルーチンと思われる｡
"戻る" 操作とは､多くの非対称コルーチンを持つプログラム言語では`yield`というキーワードや関数名として使うことができる｡

```lua:yield example
coroutine.create(function()
  -- callerに"戻る"
  coroutine.yield(3)
end)
```

# stackfulnessによる分類
**コールスタックをまたいで** yieldできるかどうかで､非対称コルーチンをさらに2つに分類できる(表[ref:tbl2])｡

<center>
[label:tbl2]
表[ref:tbl2]. stackfulnessによる分類

|              | stackful         | stackless |
|:--           | :--              | :--       |
|またいでyield | できる           | できない  |
| examples     | Luaのcoroutine, RubyのFiber | Rustのcoroutine, JSのGenerator|

</center>

stackful coroutinesは単に "coroutine" ､ あるいは "fiber" と呼ばれ､
stackless coroutinesは "generator" と称される傾向にある｡

では､ "コールスタックをまたげる" とはどういうことか?
これはyieldがネストした関数呼出しから一気にコルーチンの呼び出し元まで戻れる､またyieldした位置にコントロールを戻せるということである｡
次の例を見てみる(プログラム[ref:lst:stackfulexample], プログラム[ref:lst:stacklessexample])｡

[label:lst:stackfulexample]
```lua:プログラム[ref:lst:stackfulexample]. stackful example in Lua
local send = function(x)
  local y = yield(x)
  return y + 3
end

local co = coroutine.create(function()
  local x = send(10)
  return x + 10
end)

print(resume(co)) -- prints 10
print(resume(co, 2)) -- prints 15
```

[label:lst:stacklessexample]
```javascript:プログラム[ref:lst:stacklessexample]. stackless example in JS
/* syntax error
function send(x) {
  yield x
}
*/

const co = (function*() {
  const x = yield 10
  return x + 10
})

console.log(co.enxt())  // prints 10
console.log(co.next(3)) // prints 13
```

[ref:lst:stackfulexample]を見てみる｡
関数`send`の中で`yield`しているが､`send`自体はただの関数である｡
`send`をコルーチン`co`の中で呼び出すと､この`yield`で一時停止する｡
2度目の`resume`で渡した`2`が､`yield`の戻り値となり､`send`の戻り値は`2 + 3`となる｡

一方[ref:lst:stacklessexample]は､コルーチン(generator)の中でしか`yield`できない｡
特にJSは`yield`がキーワードとして扱われ､generatorの中でしか書けないというsyntacticな制約がある｡

# pros/cons
非対称コルーチンをさらにstaclful､stacklessの2種類に分類した｡
利点と欠点をまとめてみると､次のようになる(表[ref:tbl3])｡

<center>
[label:tbl3]
表[ref:tbl3]. 利点･欠点まとめ
</center>

|     | stackful | stackless |
|:--  | :--      | :--       |
|利点 | 関数呼出しをまたいだyieldができ､<br>stacklessよりも表現力が高い | ステートマシンに変換でき､実装が簡潔な<br>だけでなく実行のパフォーマンスも良い |
|欠点 | 実装が煩雑となり､コンテキストスイッチの<br>オーバーヘッドがかかる | 表現力が低い |

stackful coroutinesの利点･欠点が､逆にstackless coroutinesの欠点･利点と､一長一短となっている｡

# 研究との関連性
筆者の研究では "ネストした関数呼出しから一気に飛び出せる" というstackful coroutinesの特性を利用している｡
そのためstackless coroutinesではすぐには代替できない｡
stackful coroutines → stackless coroutinesの変換がある場合はなんとかなるかもしれないので､教えてください｡

# おわりに
という話をゼミでやった｡
(研究の進捗は)ないです

#! 他

なんかわかりやすいやつ

{% twicard "How do stackless coroutines differ from stackful coroutines? -- Stack Overflow" https://stackoverflow.com/questions/28977302/how-do-stackless-coroutines-differ-from-stackful-coroutines %}

---
[^1]: Moura, Ana Lúcia De, and Roberto Ierusalimschy. "Revisiting coroutines." ACM Transactions on Programming Languages and Systems (TOPLAS) 31.2 (2009): 6.
