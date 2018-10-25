---
layout: plain
title: About
author: Kawahara Satoru s1311350@gmail.com
tags: {}
---

- Website: https://nymphium.github.io
- GitHub: https://github.com/Nymphium

# Summary
I'm a graduate student at University of Tsukuba, belonging to [Programming Logic Group](http://logic.cs.tsukuba.ac.jp).
My research target is functional programming language and that mechanisms, especially program conversion, control operators and algebraic effects.

# Main works
## llix
{% gh_repo nymphium/llix %}

llix is meta-circular [Lua](https://lua.org) interpreter with exception and delimited continuation mechanism.
The interpreter uses CPS as intermediate representation to manage contexts.
[Here]({{ BASE_PATH }}/pdf/information_special_seminar.html) is a presentation.

## Opeth
{% gh_repo nymphium/opeth %}

Opeth is Lua VM 5.3 Bytecode optimizer and debug tools.

Lua VM is not documented officially while the source code is [opened](https://github.com/lua/lua).
For implementing Opeth, I read VM's source code.

Opeth has an optimizer, bytecode visualizer, step-by-step instruction interpreter, based on global data/control -flow analysis, and, assembly-like language compiled to the bytecode.

[Here]({{ BASE_PATH }}/pdf/opeth_report.pdf) is a report.

## Pnyao
{% gh_repo nymphium/pnyao %}

Pnyao is pdf management system.
It adopts server-client method 
The server uses play framework and you can access with web browser as client.

# Education
## Bachelor: College of Information Science, University of Tsukuba, 04/2013 ~ 03/2018 
Bachelor thesis: [合流点を追加したコンパイラ中間言語の設計と検証](http://logic.cs.tsukuba.ac.jp/~sat/pdf/bachelor_thesis.pdf)

## Graduate school: same as above, 04/2018 ~
We taclke to the relationship about asymmetric coroutines and algebraic effects.

Poster session at [JSSST2018](https://jssst2018.wordpress.com/): [ワンショットの限定継続に着目した代数的効果から非対称コルーチンへの変換](http://logic.cs.tsukuba.ac.jp/~sat/pdf/jssst2018.pdf)

# Publication
## 『つくってかんたんVM-Based Interpreter』 from 『Dragon University 技術書典5』
This column focuses on how to design virtual machine-based interpreter and implement it.
You can learn the formalization of the VM state and the compilation rules from the source to the instruction sequence.

The book gives an implementation of toy language and you can see [the source code](https://github.com/Nymphium/techbookfest5-toylang).
You can purchase [here](https://dragonuniversity.booth.pm/items/1055860).

# Work carrer
- National Institute of Advanced Industrial Science and Technology, 09/2014 ~ 02/2015
- AgilePoint Japan, 05/2015 ~ 11/2018
- HERP, inc. 11/2018 ~
- Linux Development head office, Fujitsu, as an internship, 09/2015 ~ 10/2015

# IT Engineering Skills
## Languages
- OCaml
- Lua
- Haskell
- Scala
- JavaScript
- Racket
- Scheme
- Ruby

## Platforms
- Linux

## Other
- Git (locally, GitHub, BitBucket)
- Zsh
- Vim/Neovim

