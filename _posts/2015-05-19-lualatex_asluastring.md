---
layout: post
title: texluaとtex.print
tags: [LaTeX, Lua]
---

こんにちは､びしょ〜じょです｡アイカツ劇場版のBD発売ももうすぐですね｡もちろん予約注文してあります｡ソウルマリオネットコーデがあとブーツだけなので皆さんよろしくお願いします｡当方トップスが被っております｡

---

## クソッタレtexluaを使う

texluaとは､LuaTeXにねじ込まれているLuaの処理系であり､クソッタレである｡

```tex
\documentclass{ltjsarticle}

\begin{document}
\directlua{
for i = 1, 10 do
tex.print("$2^{" .. i  .. "}$")
end

tex.print("")

for i = 1, 10 do
tex.write("$2^{" .. i .. "}$")
end
}
\end{document}
```

適当なファイル名にして､`lualatex tekitou.tex`とでもすると､こんな感じのPDFが出る｡

<center><img src="/pictures/2015-05-19-lualatex1.png" alt="hello"></center>

`tex.print`は受け取った文字列を*LaTeXの入力として*受け取り､コンパイル(実行)時に出力先に吐き出す｡`tex.write`は受け取った文字列をただの文字列として受け取る｡

画像を見ると､`tex.print`で出力した\\(2^i\\)は意図通りに出力されており[^1]､`tex.write`を用いた部分では"$2^-1$"とかよく分からない感じになっている｡

ここで､｢おっこれはLaTeXコマンドもいけるんちゃうか〜｣と思った好奇心旺盛な少年が多いことは間違いない｡しかし､texluaはちょっとここで少年たちを嘲笑う｡

---

`tex.print("\LaTeX")`などとすると､まぁLuaを学んだ人間はわかるがバックスラッシュのところで怒られる｡正しい｡

ではバックスラッシュを2つ重ねるとOK､と思うだろうがそうは問屋が云々｡

```tex
...
tex.print"(Hello, \\LaTeX")
...
```

`! Undefined control seq` ***ファーーーック*** だバカヤロウど畜生めが｡ここで名案閃き､Luaは`[[]]`で文字列を囲むことでバックスラッシュも解決するのだ〜ハハハハ

```tex
...
tex.print([[Hello, \LaTeX]])
...
```

`! Undefined control seq` ***ファーーーック*** 慈悲はない｡

### 解決法
```
...
tex.print(\asluastring{Hello, \LaTeX})
...
```

ltj{,s}articleには`\asluastring`というLaTeXコマンドがあり､良い感じになってくれる｡

もうちょっと良い感じの例

```tex
\documentclass{ltjsarticle}

\directlua{
	tex.print(
		\asluastring{\begin{document}} ..
		\asluastring{Lua\LaTeX} ..
		\asluastring{\end{document}}
	)
}
```

<center> <img src="/pictures/2015-05-19-lualatex.png" alt="LuaLaTeX"> </center>

プレアンブルでも`\directlua`は使うことができ､こういった悲劇を編み出すことも可能*(全然良い感じじゃないんだよなぁ…)*｡

しかし`tex.print`を2個使って`\begin{document}`と`\end{document}`を､環境を分けることができない｡うーん､`tex.print`で環境をネストさせたい時は滅茶苦茶にキモくなるので､
~~こういうことはやめておこう~~環境の中身は適当な変数に突っ込むべきだろう｡

一気に話が飛んでしまった｡`{\texttt hoge}`みたいなことをしたいときはどうするか｡

```tex
...
tex.print("{" .. \asluastring{\texttt} .. "fuck}")
...
```

こんな感じにすることで漏れを防ぐ｡`\asluastring{\texttt{}`みたいな感じにするとコンパイルエラーになるので注意｡

## 他

luatexja-presetにdeluxeオプションを渡すと編集中のtexファイルとは無関係そうな場所を指摘され､なんだか腹が立つ｡これはluatexja-fontspecのバグで､[こちら](http://osdn.jp/projects/luatex-ja/wiki/FrontPage#h3-.E3.83.90.E3.82.B0.E6.83.85.E5.A0.B1)を参照｡これはtexluaとあまり関係はないですね､はい｡

## 他2

LuaLaTeXはコンパイル時にTwitterのタイムラインを取得できる数少ないLaTeX処理系なので好きですよ｡

https://twitter.com/Nymphium/status/599485391658352641

- - -

今期は単位がいっぱい取れそうな予感｡

[^1]: (jekyll + redcarpetでは意図通り2^iが出ませんね💢) (追記2015/06/04:と思ったけどMatJax使えるじゃねーか｡ごめんなさい｡)
