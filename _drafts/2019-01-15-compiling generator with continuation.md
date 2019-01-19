---
layout: post
title: compiling generator with continuation
tags: [Generator, CPS, Program conversion]
---

<!--sectionize on-->

こんにちは､びしょ〜じょです｡

ほならねやっていこう｡

# はじめに

# ソース言語 $\lambda_\textit{gen}$

<div>
<center>
[label:lambdagen]
\[
@importmd(src{{page.id}}/lambdagen.tex)
\]

図[ref:lambdagen]. the syntax of $\lambda_\textit{gen}$
</center>
</div>

<mathp>
ラムダ計算にletとジェネレータの生成&ラベルへの束縛$\mathtt{let}_\mathit{gen}$とresume/yieldを追加した｡
ジェネレータの直下にしかyieldを書けないというsyntacticな制限のために､yieldのない項$e^-$を定義した｡
$\mathtt{let}_\mathit{gen}\ l\ x = e_1\ \mathtt{in}\ e_2$はJSにおける`const l = (function*(x){ e_1 })(); e_2`と考えればいい｡
</mathp>

$\mathtt{resume}$の第1引数はジェネレータというのをsyntacticに強制したいので､$l$は変数とは区別した*ラベル*として扱われる｡

# ターゲット言語 $\lambda$

<div>
<center>
[label:lambda]
\[
@importmd(src{{page.id}}/lambda.tex)
\]

図[ref:lambda]. the syntax of $\lambda$
</center>
</div>

とりあえず`let`式はあるけどただのラムダ計算ですね｡

# 変換
では変換を考えます｡

<div>
<center>
[label:conv]
\[
@importmd(src{{page.id}}/conv.tex)
\]

図[ref:conv]. conversion from $\lambda_\mathit{gen}$ to $\lambda$
</center>
</div>

