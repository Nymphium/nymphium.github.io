---
layout: post
title: Define-Use chainとその構成法
tags: [Lua,MoonScript]
---
<!--sectionize on-->
こんにちは､びしょ〜じょです｡これは[言語実装 Advent Calendar 2016](http://qiita.com/advent-calendar/2016/lang_dev)11日目の記事です｡
百合が好きなんですが､百合以外にも活動はしているということで､百合以外の活動について今回触れたいと､えぇ､思います｡

#はじめに
今年は通年の講義で[Lua](https://lua.org) VMのバイトコードの最適化器を作っています｡
去年は[こんなもの](https://nymphium.github.io/2016/01/13/llix.html)を作ってました｡
最適化器は最終報告会の後に公開しようと思っています｡

さて､とある文による定義(や代入)がそれ以降使われないとき､その文を削除したいなんていうケースがあります｡
はい､[dead code elimination](https://en.wikipedia.org/wiki/Dead_code_elimination)などです｡
この"それ以降使われない"かどうかの判別に*Define-Use Chain*を使います｡
##prerequirements
まずひとつに､example codesは実装言語に倣って[MoonScript](https://moonscript.org)を使います｡
あまり分からなくてもいいですが､Luaのtableについて知っておいてもらえるとありがたいです､まぁだいたい連想配列でいいですはい｡

それともう一つ､今回は*Lua VM*というレジスターベースのVMの命令をターゲットにして進めます｡
Lua VM 5.3には47個の命令がありますが､今回簡単のため以下の5つで戦わせていただきます｡

- `LOADK A B`

    `レジスターA`にconstant listの`B`番目の値をブッ込みます｡`A = Cst(B)`といった感じで｡

- `ADD A B C`

    `レジスターA` に`レジスターB`と`C`を足したものを格納する｡
    つまり `A = B + C`と考えればいい｡

- `EQ A B C`

    `XOR(A == 0, レジスターBの値 == レジスターCの値) `のときにプログラムカウンターをインクリメントする｡

    つまり`XOR(A == 0, レジスターBの値 == レジスターCの値) `が真のときに次の命令を無視する｡

- `JMP A B`

    プログラムカウンターに`B`を足す｡`A`に関しては今回関係ないので省略｡
    `JumpEq`みたいなものは`EQ`と`JMP`を並べて使うわけですね｡

- `RETURN A B`

    今回はトップレベルだけ考えるので､まぁプログラムの終了位置と考えてください｡本当は全然違うぞ｡

まぁこれだけでいいか｡
簡単のためにだいぶ端折ってますんで､詳細はドキュメント…公式にそんなものはない[^3])[^4])…Luaのソースコードを見てください｡


最後に一つ､後述しますがほとんど手探りなので*間違ってる可能性が極めて高い*です｡｢そうじゃなくてこうだ｣というのがあったら大変ありがたいですのでどしどしご指摘願います｡

---
こんな感じのLua VMの命令を見てみましょうか｡

```
LOADK 0 0 -- load `3`
LOADK 1 1 -- load `5`
LOADK 1 2 -- load `7` *<!>*
EQ 0 0 1 -- R(0) == R(1) ?
JMP 0 2
LOADK 2 2 -- load `7`
JMP 0 1
LOADK 2 3 -- load `9`
RETURN 0 1

constant list: [3, 5, 7, 9]
```

上から見ていくと､

1. `レジスター0`に`3`をロードして
2. `レジスター1`に`5`をロードして､
3. `レジスター1`に`7`をロードする｡
4. `レジスター0`と`レジスター1`の値が同じかどうかを比較する
5. 同じ場合は8. に飛ぶ
6. `レジスター2`に`7`をロードして
7. 9.に飛ぶ
8. `レジスター2`に`9`をロードする
9. おわり

なるほど｡3行目*<!>*は`レジスター1`の値を上書きしています｡
とすると2行目の彼は無駄なのでは…ということが人間はすぐに分かります｡すぐに分かる｡
しかしプログラムは書かないといけない｡
人間も､もっと複雑なものがでてくるとあっぷあっぷになる｡
ということで書く｡

#What is Define-Use Chain?
Wikipediaを読んで知った気になるのが趣味なので､Wikipediaを引用します｡

[Use-define chain - Wikipedia](https://en.wikipedia.org/wiki/Use-define_chain)
> A Use-Definition Chain (UD Chain) is a data structure that consists of a use, U, of a variable, and all the definitions, D, of that variable that can reach that use without any other intervening definitions.
> A definition can have many forms, but is generally taken to mean the assignment of some value to a variable (which is different from the use of the term that refers to the language construct involving a data type and allocating storage).

オイオイこれは*Use-Define Chain*の記事じゃねーかってすみません｡

Use-Define Chainは､変数を使用する部分から､その変数の定義位置を逆引きするようなイメージですか｡
例で見ると､`EQ`からどこで定義されたレジスター`1`の値を使いたいか､ということになりますね｡

*Define-Use Chain*はその逆で､定義から使用先が紐付けられています｡
例でいくと､2行目の宣言は誰も使ってないので参照する使用先が無い､3行目は`EQ`で使われるので使用先が1つある､となり2行目が不要であることが分かるわけですね!

#Reachable Definition
ただ､資料に乏しく､なんかウマイ感じのアルゴリズムの説明もありません｡
仕方なく雰囲気だけで我流の実装をしてみたところもちろんガバガバで爆死しました｡

先生に伺ったところ､｢*Reachable Definition*からちょっと発展させればできる｣とのことでした｡
Reachable Definition､それならちょっと前に読んだ本[^1]に出てきたなとなってなんとかなりそうだった｡

段階を追うのが下手なので､ここで強制的に段階を追わせていただきます｡
まず､Reachable Definitionについて語るために､*Control Flow Graph*について語る必要があります｡
## Control Flow Graph (CFG)
簡単に言ってしまうと､プログラムの実行の流れをグラフにしたようなものです｡context-free grammarではないよ｡
最適化などでしょっちゅう使われる物体ですね[^2]｡
各ノードは*基本ブロック*と呼ばれ､各ブロックには文が突っ込まれている｡
[^3])によると､

> ブロック\\(B_1\\)からブロック\\(B_2\\)に有向辺が引かれるのは, 以下の場合である.
> 
> 1) \\(B_1\\)の最後の文から\\(B_2\\)の最初の文へ無条件あるいは条件付き飛越しがある
> 
> 2) \\(B_1\\)の最後が無条件飛越し文以外の文で終わっていて, プログラムの字面上で\\(B_1\\)の直後に\\(B_2\\)が来る

とのこと｡

ブロックBから有向辺が伸びている先のブロックの集合を先行ブロック(successor)､
Bに向かって有向辺を向けているブロックの集合を後続ブロック(predecessor)となる｡

Lua VMの命令で見ていくと､`EQ`､`JP`と`RETURN`がブロックの出口となります｡
特に`RETURN`がブロック最後の命令のときは､先行ブロックがそのブロックに付きません｡

説明のため､基本ブロックは次のようなtableとなる:

```moon
{
    start: (基本ブロックの開始行: number) -- これいる
    end:   (終了行: number) -- これいる
    succ:  {......} -- 先行ブロック､これ要らない
    pred:  {......} -- 後続ブロック これいる
}
```

さてこれにより命令は以下のようなCFGになります(inspect[^5]による整形)｡

```lua
cfg = { <1>{
    end = 4,
    pred = {},
    start = 1,
    succ = { <2>{
        end = 5,
        pred = { <table 1> },
        start = 5,
        succ = { <3>{
            end = 8,
            pred = { <table 2> },
            start = 8,
            succ = { <4>{
                end = 9,
                pred = { <5>{
                    end = 7,
                    pred = { <table 1> },
                    start = 6,
                    succ = { <table 4> }
                  }, <table 3> },
                start = 9,
                succ = {}
              } }
          } }
      }, <table 5> }
  }, <table 2>, <table 5>, <table 3>, <table 4> }
```

ビジュアライザーも作ったんでよかったら見ていってください｡
![Control Flow Graph](/pictures/2016-12-11-duchain_cfg.png)

CFGそれ自体は本題でないので､説明はこの辺にとどめます｡

---

さて､Reachable Definitionに話を戻します｡

まず､各ブロックについて*定義*と*使用*を取っていきます｡
各ブロックのメンバーに`gen`, `use`というリストを追加し､以下のようなtableを突っ込みます｡

```moon
-- for gen
{
    reg: (レジスター)
    line: (行番号)
}

-- for use
{
    reg: (レジスター)
    line: (行番号)
}
```

例をまた引っ張ってきます｡

```
-- block 1 to 2, 3
LOADK 0 0
LOADK 1 1
LOADK 1 2
EQ 0 0 1
-- block 2 to 4
JMP 0 2
-- block 3 to 5
LOADK 2 2
JMP 0 1
-- block 4 to 5
LOADK 2 3
-- block 5
RETURN 0 1

constant list: [3, 5, 7, 9]
```

これより`gen`と`use`を取っていくと､次のようになります( [^5])による整形を一部改変)｡

```lua
cfg = { <1>{
    start = 1,
    end = 4,
    -- gen/use of block 1
    gen = {
        {line = 1, reg = 0},
        {line = 2, reg = 1},
        {line = 3, geg = 1}
    },
    use = {
        {line = 4, reg = 0},
        {line = 4, reg = 1}
    },
    pred = {},
    succ = { <2>{
        start = 5,
        end = 5,
        -- gen/use of block 2
        gen = {},
        use = {},
        pred = { <table 1> },
        succ = { <3>{
            start = 8,
            end = 8,
            -- gen/use of block 3
            gen = {
                {line = 8, reg = 2}
            },
            use = {},
            pred = { <table 2> },
            succ = { <4>{
                start = 9,
                end = 9,
                -- gen/use of block 4
                gen = {},
                use = {
                    {line = 9, reg = 0}
                },
                pred = { <5>{
                    end = 7,
                    -- gen/use of block 5
                    gen = {
                        {line = 6, reg = 2}
                    },
                    use = {},
                    pred = { <table 1> },
                    start = 6,
                    succ = { <table 4> }
                  }, <table 3> },
                succ = {}
              } },
          } },
      }, <table 5> }
  }, <table 2>, <table 5>, <table 3>, <table 4> }
```

これを踏まえ､Reachable Definitionの実装はこんな感じになる:

```moon
modified = {true}
while foldl ((acc, mod) -> acc or mod), false, modified
    for i = 1, #cfg
      block = cfg[i]
        block.in = foldl ((acc, pred) -> union acc, pred.out), {}, block.pred
        block.kill = intersec block.in, block.gen
        out = block.out
        block.out = union (latest block.gen), (diff block.in, block.kill)
        table.insert modified, (diff out, block.out)
```

フ〜ム…解説します｡

- `block.gen`
  
    CFGの要素のブロック`block`で新たに生成される定義の集合｡これはプログラムの代入文から明らか｡

- `block.in`
  
    `block`の入り口に到達する定義の集合｡
    後続ブロック`block.pred`の各要素`p`について`p.out`の和集合となる｡

- `block.kill`
  
    `block`に到達したが､ブロック中で無効になる､つまりブロック中で新たな代入により不要になるものの集まり｡

    `block.in`と`block.gen`のintersectionを取ればいいわけだな｡

- `block.out`
  
    ブロックの出口に到達する定義の集合｡
    (`block.in`と`block.kill`の差集合)と`block.gen`の和集合とすればいいか｡

    ここで一つ､例えば変数`x`への代入が同一ブロック中に2回あったらちょっと困る｡

    そこで､*最新の`x`への代入*(つまりブロック内で最後に実行される`x`への代入)のみに注目し､他は無視することで対処する (関数`latest()`)｡

<p>
</p>

で､それを各ブロックの`block.out`の変更がなくなるまで繰り返しておりますわけですな｡

これでCFGにReachable Definitionをくっつけた感じになりました｡

#DU Chainの構成
さてここまでくれば後は簡単｡かも｡
今の所CFG'に定義の集合`block.def`が無く､`block.def`から使用をたどるといったギミックがありません｡
逆にこの2つを実装するとゴールです｡がんばります｡

```moon
for i = 1, #cfg
    block = cfg[i]
    block.def = union block.gen, block.in

    for u = 1, #block.use
        use = block.use[u]
        use.defined = {}

        if defr = last latest filter ((g) -> g.line < use.line and g.reg == use.reg), block.gen
            insert use.defined, defr unless have use.defined, defr

            unless defr.used
                defr.used = {use}
            else
                insert defr.used, use unless have use.defined, use
        else
            for defr in *(filter ((i) -> i.reg == use.reg), block.in)
                insert use.defined, defr unless have use.defined, defr

                unless defr.used
                    defr.used = {use}
                else
                    insert defr.used, use unless have defr.used, use
```

まず3行目で`block.def`を作ります｡Define-Useの*Define*です｡`block.egn`と`block.in`のunionというのは直感で分かると思います｡
さて､あとはこの`def`から`use`がわかればOKとなりました｡早い｡

中のイテレーションで`block.use`から定義をたどるギミックを作ります｡
イテレーションした各`block`の`use`のメンバーに`defined`を生やし､使用しているレジスターの定義を突っ込んでいきます｡

まず`block`内での定義を探します｡
ここで`block.def`から探さないのはなぜかというと､そうですね､`block`内(*直近*)での定義がもちろん最優先なので｡
`block`内のさらに直近を最優先するので`latest()`で`use`に最も近い定義を拾います｡かぶりがないように(`unless have ......`)`use.defined`に突っ込みます｡

`block`内に定義が無い場合は`block.in`から定義全部引っ張ります｡

`use.defined`を基に`def.used`を作ります｡これは簡単ですね｡
`use.defined`の各構成ステップで`use`自体を､`use`が引っ張ってくる`defr`の`defr.used`に突っ込めばいいわけですから｡ポインター最高!!!!! :p

あれ? 定義から使用も､使用から定義も参照できるようになってるな…


これで欲しかったものが手に入りました( [^5])による整形)｡

```lua
{ <1>{
    def = { <2>{
        line = 1,
        reg = 0,
        used = { <3>{
            defined = { <table 2> },
            line = 4,
            reg = 0
          }, <4>{
            defined = { <table 2> },
            line = 9,
            reg = 0
          } }
      }, {
        line = 2,
        reg = 1,
        used = {}
      }, <5>{
        line = 3,
        reg = 1,
        used = { <6>{
            defined = { <table 5> },
            line = 4,
            reg = 1
          } }
      } },
    end = 4,
    pred = {},
    start = 1,
    succ = { <7>{
        def = { <table 2>, <table 5> },
        end = 5,
        pred = { <table 1> },
        start = 5,
        succ = { <8>{
            def = { <9>{
                line = 8,
                reg = 2,
                used = {}
              }, <table 2>, <table 5> },
            end = 8,
            pred = { <table 7> },
            start = 8,
            succ = { <10>{
                def = { <11>{
                    line = 6,
                    reg = 2,
                    used = {}
                  }, <table 2>, <table 5>, <table 9> },
                end = 9,
                pred = { <12>{
                    def = { <table 11>, <table 2>, <table 5> },
                    end = 7,
                    pred = { <table 1> },
                    start = 6,
                    succ = { <table 10> },
                    use = {}
                  }, <table 8> },
                start = 9,
                succ = {},
                use = { <table 4> }
              } },
            use = {}
          } },
        use = {}
      }, <table 12> },
    use = { <table 3>, <table 6> }
  }, <table 7>, <table 12>, <table 8>, <table 10> }
```


#おわりに
それでは皆さんもガンガン最適化をしていってください｡
ちなみに､現在鋭意製作中の最適化器を用いると､例は以下のように最適化されます｡

```
JMP 0 0
RETURN 0 1
```

そうだね…｡

---

『Vivid Strike!』8話までイッキ見しましたが面白いですね｡今季は他に何もアニメを観てない｡

[^1]: 中田 育男, 佐々木 正孝, 滝本 宗宏, 渡邉 担. [コンパイラの基盤技術と実践―コンパイラ・インフラストラクチャCOINSを用いて](https://www.amazon.co.jp/%E3%82%B3%E3%83%B3%E3%83%91%E3%82%A4%E3%83%A9%E3%81%AE%E5%9F%BA%E7%9B%A4%E6%8A%80%E8%A1%93%E3%81%A8%E5%AE%9F%E8%B7%B5_%E3%82%B3%E3%83%B3%E3%83%91%E3%82%A4%E3%83%A9%E3%83%BB%E3%82%A4%E3%83%B3%E3%83%95%E3%83%A9%E3%82%B9%E3%83%88%E3%83%A9%E3%82%AF%E3%83%81%E3%83%A3COINS%E3%82%92%E7%94%A8%E3%81%84%E3%81%A6-%E4%B8%AD%E7%94%B0-%E8%82%B2%E7%94%B7/dp/4254121733)
[^2]: Zdenek Dvorák, Jan Hubicka, Pavel Nejedlý, Josef Zlomek. [Control Flow Graph - Infrastructure for Profile Driven Optimizations in GCC Compiler](http://www.ucw.cz/~hubicka/papers/proj/node18.html#CFG)
[^3]: Dibyendu Majumdar. [Lua 5.3 Bytecode Reference](https://github.com/dibyendumajumdar/ravi/blob/master/readthedocs/lua_bytecode_reference.rst)
[^4]: Kein-Hong Man. [A No-Frills Introduction to Lua 5.1 VM Instructions](http://luaforge.net/docman/83/98/ANoFrillsIntroToLua51VMInstructions.pdf)
[^5]: Enrique Garcíao. [inspect.lua](https://github.com/kikito/inspect.lua)

[^]: 
