---
layout: post
title: Algebraic Effectsとは? 出身は? 使い方は? その特徴とは? 調べてみました!
tags: [Algebraic Effects, JavaScript]
---

ReactのHooksが実質algebraic effectsなんじゃないかということでalgebraic effectsに関する怪文書が流布して鼻白んでしまう､そんな未来を阻止するため､曲がりなりにもalgebraic effectsを研究している者としてalgebraic effectsについて書こうと思います｡

当方React全く知らないしJSにも明るくない侍ですが､プログラム片にはJSっぽいシンタックスを使っていこうと思います｡

# イントロ
Algebraic Effectsとは､Plotkinらによって提唱された､computational effectsを代数的に扱おうという試みである｡それにeffect handlerが後付けされ､現在はalgebraic effects *and handlers* を略してalgebraic effectsと呼んでいることが多い｡非常に直感的な説明としては､*継続を取ってこれる例外*である｡
チュートリアルとしては､こちらの論文[^3]の内容に尽きるわけですが……｡

algebraic effectsは､エフェクトの定義､発生､そしてハンドラに分かれる｡

```js
// effect definition
effect Foo /* : int -> int */;

// handler
handle(console.log(perform/* invocation */ Foo(3) + 10)) {
    case x: {
       x;
    }

    case Foo(x), k: {
        k(x * x);
    }
}

//==> prints `19`
```

うそうそシンタックスですが大丈夫ですか?

`Foo`という名前の`int -> int`というシグネチャを持つエフェクトを定義します｡JSは型がないので雰囲気出ないですが､一般にエフェクトは名前とシグネチャ(型)を持ちます｡

エフェクトの発生は`perform エフェクト(引数...)`というシンタックスです｡エフェクトの引数の型は､シグネチャの矢印`->`の左辺に対応します｡ここでは`int`の引数に`3`を渡してるので､確かに型は一致します｡

ハンドラは`handle(exp){ case エフェクト(仮引数), 継続: {...}... }`という感じ｡`exp`内で発生したエフェクトをハンドルします｡
例では`Foo`エフェクトが発生したので､`case Foo(x), k: ...`という部分でキャッチされます｡`x`に`3`が渡されそうですが､`k`とは一体…?
ここがalgebraic effectsのミソで､`k`には***継続***が渡されます｡出､出〜www継続奴という感じですがJSerの皆さんにはおなじみのはずです｡継続とは"*残りの計算* "であり､Promiseで`then`に渡してる関数はまさに継続といって差し支えありません｡具体的に`k`に入るものは､この場合`(h) => console.log(h + 10)`となります｡なるほど確かに残りの計算だ｡
したがって､このハンドラによって`console.log(perform Foo(3) + 10)`は`console.log(3 * 3 + 10)`となります｡
限定継続が分かる方は､この`handle(exp){...}`が継続のdelimiterといえばイメージが湧くかと思います｡限定継続に関して一筆したためているので､詳細は[こちら](https://nymphium.github.io/2018/07/19/delimited-continuation%E3%81%AE%E5%A4%8F.html)をご覧ください｡

`case x: x;`は何やねんということですが､これはvalue handlerと呼ばれる部分です｡今回は`console.log`の戻り値が`void`なので雰囲気出ませんが､`exp`部分が値になるまで評価されきったあとに､その値をハンドルする部分です｡value handlerはエフェクトのハンドル部分と異なり継続を取りません｡

かなり雰囲気はつかめたんじゃないでしょうか｡

# 特徴
algebraic effectsの特徴としては､

- エフェクトの抽象化, 実装の分離
- コントロール操作

が挙げられる｡

## エフェクトの抽象化､実装の分離
エフェクトの抽象化はまさにalgebraic effectsのやりたいことである｡エフェクトの抽象化は即ちインタフェースと実装を分離することになる｡

```js
effect Write /* : string -> void */;

// 標準出力に書き込む
const print_handler = (th) => {
    handle(th()){
        case x: x;
        case Write(str), k: {
            k(console.log(str));
        }
    }
}

// ファイルに書き込む
const write_file_handler = (file, th) => {
    handle(th()){
        case x: x;
        case Write(str), k: {
            fs.writeFile(file, str, k);
        }
    }
}


print_handler(() => {
    perform Write("Hello");
    perform Write("World");
});
// ==> prints `Hello\nWorld`

write_file_handler("hoge.txt", () => {
    perform Write("Hello");
    perform Write("World");
});
// ==> write "Hello" and "World" to hoge.txt
```

なるほどね｡

ハンドラの変更がそのまま実装の差し替えになる｡例えばDI注入にも使えるのではないだろうか｡
例えばなにかの顧客DBを取ってくるエフェクト`GetAccountList`を考えてみる｡`filter`は述語`p`を取ってDBをフィルタする関数であり､内部で`GetAccountList`エフェクトを発生している｡

```js
effect GetAccountList /* : void -> DB */;

const filter = (p) => {
    const list = perform GetAccountList();
    list.filter(p);
}
```

例えばテスト用DBのためのハンドラは

```js
const test_handler = (th) => {
    handle(th()){
        case x: x;
        case GetAccountList(), k: {
            k(db_for_test());
        }
    }
}
```

また本番のDBを返すハンドラは


```js
const production_handler = (th) => {
    handle(th()){
        case x: x;
        case GetAccountList(), k: {
            k(db_for_production());
        }
    }
}
```

あとは実際に`filter`関数を使うシチュエーションごとにハンドラを変えればいい｡

```js
const test_main = () => {
    ......
    const filtered_accounts = filter(p);
    ......
}

assert(test_handler(test_main))
```

## ハンドラの合成
エフェクトハンドラは例外ハンドラと同様に､unhandledなエフェクトはより上位のハンドラに捕捉されます(あるいはされずにランタイムエラー)｡この性質を利用することでハンドラを合成することができます｡
先程の`Write`を引っ張ってみます｡

```js
effect Write /* : string -> void */;

// 標準出力に書き込む
const print_handler = (th) => {
    handle(th()){
        case x: x;
        case Write(str), k: {
            k(console.log(str));
        }
    }
}

// ファイルに書き込む
const write_file_handler = (file, th) => {
    handle(th()){
        case x: x;
        case Write(str), k: {
            fs.writeFile(file, str, k);
        }
    }
}
```

`Write`があるなら`Read`もしたいのが人間の性です｡

```js
effect Read /* : void -> string */;
```

そしてやるだけ｡

```js
const scan_handler = (th) => {
    handle(th()){
        case x: x;
        case Read(), k: {
            k(readline())
        }
    }
}

const scan_file_handler = (file, th) => {
    handle(th()){
        case x: x;
        case Read(), k: {
            readFileAsync(file, k);
        }
    }
}
```

標準入出力とファイルの入出力をごっちゃにするシーンはあまり多くないので1つのハンドラにしたいと思います｡せっかくハンドラをそれぞれ書いたのでこれを使ってみます｡

```js
const stdio_handler = (th) => {
    print_handler(() => scan_handler(th));
}

const fileio_handler = (file, th) => {
    write_file_handler(file, () => scan_file_handler(file, th));
}
```

オッええやん｡`stdio_handler`の受け取るサンクの中で`Write`が発生した場合､`scan_handler`を突き抜けて`print_handler`によりハンドルされます｡これが合成だ､花京院｡
もちろんいちどきに一つのハンドラも実装できます｡

```js
const stdio = (th) => {
    handle(th()){
        case x: x;

        case Write(str), k: {
            k(console.log(str));
        }

        case Read(), k: {
            k(readline())
        }
    }
}

// fileも同様に(略)
```

また､同じエフェクトのハンドラをネストすることで､*部分的に実装を変える*ことができる｡

```js
fileio_handler(file, () => {
    perform Write("hoge");  // fileに"hoge"を書き込む
    let str = perform Read();  // fileから読む
    print_handler(() => perform Write(str));  // *標準出力に*書き込む
})
```

同じ`Write`を`fileio_handler`内で発生させているが､2つ目の`Write`はさらに`print_handler`に包んで発生させている｡このエフェクトの発生を最初に捕捉するハンドラは`print_handler`になるため､`str`はファイルではなく標準出力に書き込まれる｡

ちなみに､サンク1行目の`Write`がハンドラによって捕捉されるので､2行目以降はハンドラ内の継続として実行されます｡2行目の`Read`もしっかり`fileio_handler`により捕捉されるが､これはつまり継続も`fileio_handler`によりハンドルされていることになる｡このように継続も追随してハンドルしてくれるハンドラをdeep handler､明示的に継続をハンドルしないといけないハンドラはshallow handlerと呼ばれる｡deep handlerのほうが一般的だが､shallow handlerのほうが動作が軽量(のはず)である｡

## コントロール操作
継続を取ってこれるのが例外処理と決定的に異なる｡このおかげで例外の発生から復帰することができる[^5]｡
また継続はハンドラ側でよしなにしてくれるので､記述自体は直接形式で記述できる｡このためcallback hellが解消される｡例えば`scan_file_handler`関数はまさにコールバックを取る関数をラップすることで直接形式にしている｡

簡単のため､ファイル名と文字列を受け取るエフェクト`WriteToFile`を定義して様子を見る｡

```js
effect WriteToFile /* : (string, string) -> void */;

handle((() => {
    ......
    perform WriteToFile(file, "hogehoge");
    ......
})()){
    case x: x;
    case WriteToFile(file, str), k: {
        writeFile(file, str, k);
    }
}
```
なるほど確かに､ファイルに書き込んで残りの処理はコールバックにやらせる`writeFile`をラップして､見かけ上は直接形式で記述することに成功している｡

継続が取ってこれるので､[^5]にあるように､***async/awaitをalgebraic effectsで実装することができる***!!
これはコントロールオペレータのヒエラルキーとしてalgebraic effectsがasync/awaitと等価､またはそれ以上の表現力であることを示唆しています｡
実際algebraic effectsはあるがasync/awaitのない言語ではうれしい…のかもしれません｡

# Algebraic Effectsのある言語や実装
algebraic effectsにはいくつか実装が存在する｡たとえば言語機能にalgebraic effectsを組み込んだ言語､あるいはライブラリ｡フレームワークを自称しつつ実際は言語を拡張しているReactなど｡

- Eff

    algebraic effectsの計算モデルとしてよく使われる言語｡MLスタイルのシンタックスでHindley-Milner型推論がある｡
    + [matijapretnar/eff](https://github.com/matijapretnar/eff)

        OCaml製Effインタプリタ｡エフェクトが単相なのが惜しい以外はopamで簡単に導入できてシンタックスもOCamlに毛が生えた感じで様々な面でコストが低い｡

    + [atnos-org/eff](https://github.com/atnos-org/eff)

        ScalaのDSL実装
    + 『Eff Directly in OCaml』[^1]

        OCaml+delimccライブラリによるEffの実装｡shift/resetとalgebraic effectsの関係が分かる｡
        この論文を元に､[Racketによる実装](https://gist.github.com/Nymphium/60d4e2b5888f3e04b9b98c562854f143)をおこなってみた｡

- Koka[^2]

    Microsoft Researchが作っている言語｡エフェクトの型が明示されておりモナドみがある｡

    + [koka-lang/koka](https://github.com/koka-lang/koka)

        Haskell製｡ランタイムにJSまたはC#にコンパイルされて実行される｡
        stackによるビルドをできるようにしたのでぜひ使ってください｡

- Multicore OCaml

    OCamlにalgebraic effectsをぶっこんだOCaml方言｡継続がワンショットなことが特徴となっている｡

    + [ocamllabs/ocaml-multicore](https://github.com/ocamllabs/ocaml-multicore)

        OCaml labsが[ocaml/ocaml](https://github.com/ocaml/ocaml)からフォークしているOCaml方言｡

他にもC言語による実装[^4]などがあり､確かにコールスタックなどをバコッといければなんとかなりそう｡

<!-- bib -->

[^1]: Oleg Kiselyov, K. C. Sivaramakrishnan. "Eff directly in OCaml." ML Workshop. 2016.
[^2]: Leijen, Daan. "Algebraic Effects for Functional Programming. Technical Report." 15 pages. https://www.microsoft.com/en-us/research/publication/algebraic-effects-for-functional-programming, 2016.
[^3]: Pretnar, Matija. "An introduction to algebraic effects and handlers. invited tutorial paper." Electronic Notes in Theoretical Computer Science 319 (2015): 19-35.
[^4]: Leijen, Daan. "Implementing Algebraic Effects in C." Asian Symposium on Programming Languages and Systems. Springer, Cham, 2017.
[^5]: Dolan, Stephen, et al. "Concurrent system programming with effect handlers." International Symposium on Trends in Functional Programming. Springer, Cham, 2017.
