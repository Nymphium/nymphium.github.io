---
layout: post
title: スライドを書いてると思ったらBeamerのテンプレートだけが肥大化した
tags: [LaTeX]
---

こんにちは､びしょ〜じょです｡先日書いたエントリーは私が`git push -f`したので消えました｡私は十字架を背負って生きていきます｡

ところで今日の『「桜Trick」オールナイト一挙上映 ～夜通しWon(＊3＊)Chu KissMe!～』は最高でしたね…!
漫画は1巻から発売日付近に買っていますがアニメはテレビがないなどで未視聴でした｡
最初の相坂さんと五十嵐さんのトークはいつもどおりなんだこれって感じで､よかった…｡
席は最後列の一つ前なうえに左端というだいぶアレでしたが､アニメを観るには問題なかった｡
いやしかしアニメはね､本当に最高でな､うん…よかった…｡

---
## Beamerの拡張

{% gh_repo Nymphium/my_LaTeX_template %}

の､[これ](https://github.com/Nymphium/my_LaTeX_template/blob/master/beamertemp.tex)をご覧ください｡

section/subsectionが始まる時点でTOCを突っ込んでいる｡
TOCの上部にはスライドのタイトルを入れたいので､`\title`を再定義して`\thetitle`でタイトルを参照できるようにしている｡

beamerbasemisc.styから一部拝借してTOCページの総数をsrc.navファイルに`\inserttotaltocpage`として突っ込む｡

フッタをねじ込む`\Setfooter`なんかを定義してね｡

1. 左端にsection - subsection
2. 右端に(現frame - 現在のTOCページ数)/(総frame数 - 総TOCページ数)
3. タイトルページ､TOCページには何も入れたくない

このワガママを解消した｡まぁ1はどうでもよくて､2のためにTOCのページをnavファイルに書き込んでおいたのさ!  あとは適当に…｡

これで`\input{beamertemp.tex}`するだけでBeamerがデラックスな感じになりました｡`\zw`使っちゃってるのでLuaLaTeXでしか動きませんが､気が向いたら`\ifluatex`などで条件分岐させるかもしれん｡

---
土曜はデレマス3rdや!

