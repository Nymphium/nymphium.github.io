---
layout: post
title: Ensime-vimを入れる
tags: [Scala, Vim, ArchLinux]
---

<!--sectionize on-->

こんにちは､びしょ〜じょです｡
最近は死んでるのでコードも全然書いてませんでした｡

---

# はじめに
VimでScalaを書いている､というと赤黒いアイコンを思い出すかもしれないが､そんな感じになっている｡
動機としては､最近一切コードを書いてなかったのでなにか作ろうと思い､またScalaも以前から少し書いてみようと思っていたのでこの機会にと｡
Vimでやろうとしたのは当然手元に(Neo)Vimがあるからだ｡

# プラギン
## [vim-scala](https://github.com/derekwyatt/vim-scala)
シンタックスハイライトが寂しいので入れる｡

## [ensime-vim](https://github.com/ensime/ensime-vim)
VimでJava/Scalaというと､EclimというEclipseの情報をVimから引っ張ってグニャグニャするやつがありますが､俺達VimmerとしてはエディタのためにIDEを使うのはなんとなくはばかられる｡

(中略)

特にArchLinux(でyaourt)を使っており､Pythonなんて書かねーよハゲということでpipも基本的に触らない人用にインストールガイドを書こう｡
だいたいは[公式のインストールガイド](http://ensime.github.io/editors/vim/install/)に則ればいい｡

### Python modules
注意する点はpipに関する記述だが､Pythonは3で問題ない｡
pipでなくpacman/yourtに任せたいので､公式リポジトリから*python-websocket-client*､AURから*python-sexpdata*を引っ張る｡
後者は微妙にメンテされておらず､PKGSBUILDをいじる必要がある｡

```diff
# http -> httpsにするだけだが
-source=("http://pypi.python.org/packages/source/s/sexpdata/sexpdata-${pkgver}.tar.gz")
+source=("https://pypi.python.org/packages/source/s/sexpdata/sexpdata-${pkgver}.tar.gz")
```

### sbt plugin
あとはsbtのグローバルプラグインに以下を追加する｡

```scala
addSbtPlugin("org.ensime" % "sbt-ensime" % "2.6.0")
```

sbtで`ensimeConfig`を実行すると､プロジェクトルートに`.ensime`が生成される｡

# おわりに
人生おわった
