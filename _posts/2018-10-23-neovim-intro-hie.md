---
latouy: post
title: Neovimへのhaskell-ide-engineの導入
tags: [Haskell, Neovim, LSP]
---

様々なエディタ､IDEをまたいで言語ごとの補完や定義へのジャンプなどの機能を提供してくれる仕組みとして､*Language Server Protocol* (LSP) というものが盛り上がっています｡
現在はエディタによるプログラミングの支援が､エディタの数×言語の数となっていますが､LSPによって､Language Server = プログラム言語の数となり､エディタはLSPのクライアント機能だけもっていればよくなります｡
エディタ自作勢にとっても､LSPを喋れるようになればモダンなIDEの機能が使えるようになるので嬉しいですね｡

さて本題

---

[haskell-ide-engine](https://github.com/haskell/haskell-ide-engine)を導入し､NeovimのLSP Clientプラグインの[LanguaceClient-neovim](https://github.com/autozimu/LanguageClient-neovim)を使ってLSPによる恩恵を与りたいと思います｡

# LanguageClient-neovimの導入
LanguageClient-neovimのnextブランチでinstall.shを叩くことで`bin/languageclient`が爆誕します｡
そして`plugin/LanguageClient.vim`を呼べばOK｡
もはやプラグインはプラグインマネージャに任せてるのでそんな感じのことを彼らに任せる｡

neobundleなら

```vim
" NeoBundleLazyだと動かなかったので注意
NeoBundle 'autozimu/LanguageClient-neovim', {
  \ 'branch': 'next',
  \ 'build': {'linux': 'bash install.sh'},
  \ }
```

deinなら

```vim
call dein#add('autozimu/LanguageClient-neovim', {
  \ 'rev': 'next',
  \ 'build': 'bash install.sh',
  \ })
```

tomlに書くなら

```toml
[[plugins]]
repo = "autozimu/LanguageClient-neovim"
rev = "next"
build = "bash install.sh"
```
そして以下を書く

```vim
let g:LanguageClient_rootMakers = {
  \ 'haskell': ['*.cabal', 'stack.yaml'],
  \ } 
let g:LanguageClient_serverCommands = {
  \ 'haskell': ['hie-wrapper'],
  \ }

" LanguageClientの機能のショートカットを登録
function LC_maps()
  if has_key(g:LanguageClient_serverCommands, &filetype)
    nnoremap <silent> <F5> :call LanguageClient_contextMenu()<CR>
    map <silent> <Leader>lt :call LanguageClient#textDocument_hover()<CR>
    map <silent> <Leader>lg :call LanguageClient#textDocument_definition()<CR>
    map <silent> <Leader>lr :call LanguageClient#textDocument_rename()<CR>
    map <silent> <Leader>lf :call LanguageClient#textDocument_formatting()<CR>
    map <silent> <Leader>lb :call LanguageClient#textDocument_references()<CR>
    map <silent> <Leader>la :call LanguageClient#textDocument_codeAction()<CR>
    map <silent> <Leader>ls :call LanguageClient#textDocument_documentSymbol()<CR>
  endif
endfunction
                                                                                       
augroup LanguageClientKeyconfig
  autocmd!
  autocmd Filetype * call LC_maps()
augroup END
```

#Haskell-IDE-Engineの導入

stackをまず用意します｡

```shell-session
$ pacman -S stack
```

引っ張ってインストールする｡
stack ghcのバージョンによるので詳細はREADMEよんで

```shell-session
$ git clone https://github.com/haskell/haskell-ide-engine --recursive
$ cd haskell-ide-engine
$ git submodule update --init
$ stack install cabal-install
$ cabal update
$ stack install
$ stack exec hoogle generate # hoogleのDBを作る
```

完了だ!!
しかし実際に使う前にプロジェクトで以下を実行

```shell-session
$ cd path/to/your/project
$ stack haddock --keep-going # プロジェクトの補完/ドキュメント用DBを作る
```

適当な場所でF5を押す(`call LanguageClient_contextMenu()`)と

```
1) Type Definition
2) Code Action
3) Workspace Symbol
4) Rename
5) Definition
6) References
7) Formatting
8) Range Formatting
9) Document Highlight
10) Signature Help
11) Hover
12) Document Symbol
13) Implementation
Type number and <Enter> or click with mouse (empty cancels):
```

のようなものが出てくればOK｡

# 問題点
Docker上でプロジェクトをビルドする場合､補完やドキュメントなどが動作しない｡
なんとかならんか｡
