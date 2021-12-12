---
layout: post
title: Purely Functional OCaml Project with Nix
tags: [OCaml, Nix]
---

こんにちは､びしょ～じょです｡
これは[Meta Languages Advent Calendar 2021](https://qiita.com/advent-calendar/2021/ml)の12日目の記事です｡

今日はNixの話します｡

# `direnv`
[`direnv`](https://direnv.net/)という､projectごとに`.bashrc`みたいなんを置ける便利なものがある｡
まず`.zshrc`などにフックを書き

```shell
$ echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
```

project rootに`.envrc`を書く｡
環境変数の定義をDockerのenv fileと同様の形式で`.env`に分けてもよい｡

```shell
$ echo 'dotenv' > .envrc
$ ehco 'FOO=42'  > .env
$ direnv allow # そのdirectoryに入ると`.envrc`が評価される
$ echo $FOO
42
```

`direnv stdlib`で`direnv`が提供するコマンド(シェル関数)一覧が見られる｡
たとえば`dotenv_if_exists .env.local`で`.env.local`を`.gitignore`に書いておけば､git projectのうちローカルでのみ変更したい環境変数を`.env.local`に定義してgitからtrackされないようにできる｡

そのなかに`use_nix`というコマンドがある｡

# Nix
ところでNixという便利なパッケージ管理システムがある｡
パッケージ管理しつつ､それらパッケージを利用してシェル環境を作ったりプロジェクトのビルドに使える｡
設定は[Nix expression](https://nixos.wiki/wiki/Nix_Expression_Language)という言語で記述する｡
Nix expressionはuntyped functional lazy languageである｡
データ型は関数､実数､文字列､リスト､パス､attrset(いわゆるhashmap)などがある｡

```nix:shell.nix
let
	pkgs = import <nixpkgs> {};
in
# 新しいシェル環境(bash)を作る関数
pkgs.mkShell {
  # helloというパッケージを引っ張っている
  buildInputs = [ pkgs.hello ];
  # シェル環境に入るときのフックが書ける
  shellHook = ''
   export BAR=5 
  '';
}
```

```shell
$ nix-shell # shell.nixを読み込んだシェル環境に入る
nix-shell$ hello
Hello, World!
nix-shell$ echo $BAR
5
```

よさげですね｡
Dockerと比較すると同一ホスト上で動くので軽量だし環境が統合されてるので使いやすい｡
`import <nixpkgs> {}`は､詳細を省くとパッケージのリポジトリを引っ張ってくる式である｡
`nix-channel --list`でリポジトリのリストが取得できる｡
それが束縛された`pkgs`はattrsetとなっており､パッケージやパッケージを束ねるattrsetにアクセスできる｡
`pkgs.hello`がそのパッケージだが､このパッケージと読んでいるものは`derivation`と呼ばれてなんたらかんたら｡
とにかくこのパッケージは`hello`というコマンドを提供する｡
言語のライブラリを提供するderivationとかもある｡

`direnv`に話を戻すと､`use nix`コマンドを使うことで､今のシェル環境に`shell.nix`の内容を反映させることができる｡

```shell
$ echo "use nix" >> .envrc
$ direnv reload
$ hello
Hello, World!
$ echo $FOO $BAR
42 5
```

ところでnixpkgsはGitHubの[`NixOS/nixpkgs`](https://github.com/NixOS/nixpkgs)で管理されており､このリポジトリの特定のリビジョンを指定することで環境を固定できる｡
リビジョン固定には[`niv`](https://github.com/nmattia/niv)を使うと楽だろう[^1]｡

```nix:shell.nix
...
buildInputs = [ pkgs.niv pkgs.hello ];
...
```

そう､`niv`を引っ張ってリポジトリのリビジョンを固定するために､まず適当な(デフォルトで用意されている)nixpkgsを用意する必要があるという､ブートストラップ問題がある｡
これは仕方ない｡

```shell
$ niv init # nix/sources.json と nix/sources.nix ができる
```

`nix/sources.json`を覗いてみると､`NixOS/nixpkgs`の特定のリビジョンをさしてそうな雰囲気がある｡
`niv`も特定のリビジョンのものになっている｡

```json:nix/sources.json
{
    "niv": {
        "branch": "master",
        "description": "Easy dependency management for Nix projects",
        "homepage": "https://github.com/nmattia/niv",
        "owner": "nmattia",
        "repo": "niv",
        "rev": "5830a4dd348d77e39a0f3c4c762ff2663b602d4c",
        "sha256": "1d3lsrqvci4qz2hwjrcnd8h5vfkg8aypq3sjd4g3izbc8frwz5sm",
        "type": "tarball",
        "url": "https://github.com/nmattia/niv/archive/5830a4dd348d77e39a0f3c4c762ff2663b602d4c.tar.gz",
        "url_template": "https://github.com/<owner>/<repo>/archive/<rev>.tar.gz"
    },
    "nixpkgs": {
        "branch": "master",
        "description": "Nix Packages collection",
        "homepage": "",
        "owner": "NixOS",
        "repo": "nixpkgs",
        "rev": "0292b1b460268b91027751a49f3f9a8eea041216",
        "sha256": "0ds1gv2j5xnyx91hzr99drzwkxz246dmhqv4f6i0cjrqklicgady",
        "type": "tarball",
        "url": "https://github.com/NixOS/nixpkgs/archive/0292b1b460268b91027751a49f3f9a8eea041216.tar.gz",
        "url_template": "https://github.com/<owner>/<repo>/archive/<rev>.tar.gz"
    }
}
```

```nix:nix/pkgs.nix
let
  # パスはそのファイルからの相対パスで指定される
  sources = import ./sources.nix;
in
import sources.nixpkgs {};
```

そして`shell.nix`を変更する｡

```nix:shell.nix
let
  pkgs = import ./nix/pkgs.nix;
in
...
```

これでパッケージが固定され､パッケージの依存もすべて固定です｡
この環境下で`hello`コマンドっつったら0292b1b460268b91027751a49f3f9a8eea041216の`hello`であり､それの成す依存である､と｡

# 

[^1]: Nix2.4ではflakeという機構が入ってniv使わなくてもよくなったらしいが､筆者は深堀ってない｡すまん｡
