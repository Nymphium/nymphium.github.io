---
layout: post
title: OCaml環境をNixでセットアップしてGitHub Actionsでopamに楽にパッケージを上げる
tags: [OCaml, Nix]
---

こんにちは､びしょ～じょです｡
パン作りにドハマリしました｡

今回は､Nixを使ったOCaml開発環境構築の話をします｡
といってもテンプレを引っ張るだけで基本OKにしておいたので､テンプレを引っ張る部分と仕組みの簡単な説明をし､その後テンプレの内容を説明する｡
では､やっていき｡

# TL;DR
1. Install Nix on your PC and brain.
2. `$ nix flake init -t github:Nymphium/templates#ocaml`
3. Refer to README.md obtained to setup GitHub Actions.


<!--sectionize on-->


# Nix
Nixという便利なものがある｡
[前職でめちゃくちゃ使って](https://tech-hub.herp.co.jp/tags/nix/1.html)ノウハウも溜まったが､本ブログでは全く触れてなかった｡
説明がやや面倒なのが原因だと思う｡
なのでNixの導入は各自がんばってください｡
[Download Nix](https://nixos.org/download.html)の"Multi-user installation (recommended)"をおこなってください｡recommendedなんで｡

Nixの良いところといえば､再現可能性が極めて高い環境を構築できること｡
悪いところは､ドキュメントがない､若干の変更で再度ビルドが走る[^1]､などなど｡
ただ使い方がわかると気分がいいので使ってしまう｡
Docker以上に手元でintegratedされてる感がある｡
メタキャラではないが独特の使用感があり楽しいのでピックするイメージ｡

## Nix Flake
では皆さんNixは完全に理解できましたね｡
最近は`nix flake`というサブコマンドが生えた｡
極めて雰囲気だけ説明すると､npmとpackage.jsonに対してyarnとpackage.json+yarn.lockみたいな感じで､flake.nixとflake.lockというファイルが生えることになる｡
flake.nixに色々書くと､環境構築のみならず設定を共有できるビルド環境も提供してくれる｡いいですね｡

さらに､こいつはテンプレートを引っ張ってくる機能があるので､引っ張ります｡

{% gh_repo Nymphium/flake-templates %}

```shell:テンプレートを引っ張る
$ nix flake init -t github:Nymphium/templates#ocaml
```

これで上記リポジトリの`templates/ocaml`ディレクトリをそのまま引っ張ってくる｡

ところで! direnvという便利なものがあり､.envrcというbashファイルを置いて`$ direnv allow`とすると､そのファイルの内容を実行してシェルセッションに反映してくれる｡

{% twicard "direnv" https://direnv.net/ %}

```shell:direnvは便利じゃぞい
$ cat .envrc
export FOO=3
$ direnv allow
$ echo $FOO
3
```

そして､direnvはnix-flakeをサポートしており､`use flake`コマンドを.envrcに書くことで､flake.nix(の`devShells.default`)を読み込んでくれる｡
多分direnvの説明も必要だったのが執筆から遠ざけたのを､本節を書いて思い出した｡

上記のテンプレートは.envrcも用意しているので､あとは`$ dirienv allow`するだけで…ocaml､ocamlformat､ocamllsp､utop…のビルドが走る｡

```shell:ご確認ください
$ direnv allow
# 初回は数分かかる
$ dune exec app/main.exe
hello
```

たったこれだけで再現性のあるOCaml開発環境が無事整備された｡
お好きなエディタでOCamlを書いてください｡

nix-direnvを導入するとビルドをいい感じにキャッシュしてくれるので､是非セットアップされたし｡

{% gh_repo nix-community/nix-direnv %}

## opam-nix
まあなんて手軽なんでしょう｡
とにかく動かしたい皆さん(誰?)のためにゴールまでバーッといってしまいましたが､もう少し中身を見ていきます｡

ライブラリの依存をopamファイルに記述してアレしてコレしてというopam-usualな手法を取ってはいる｡
opamとnixをつなぐのが､opam-nixである｡

{% gh_repo tweag/opam-nix %}

詳細は↑を見てくださいなんだが､`buildOpamProject'`の`resolveArgs`に`with-test`と`with-doc`を渡すと､プロジェクトだけでなく*ライブラリのテストとドキュメントの依存も引っ張ってしまう*｡
これを抑制するために､`opam__with_test`と`opam__with_doc`に`"false"`を渡す[^2]｡

```nix:part of flake.nix
......
overlay = self: super:
  with builtins;
  let
    super' = mapAttrs
      (p: _:
        if hasAttr "passthru" super.${p}
          && hasAttr "pkgdef" super.${p}.passthru
        # これね
        then super.${p}.overrideAttrs (_: {
          opam__with_test = "false";
          opam__with_doc = "false"; })
        else super.${p})
      super;
    local' = mapAttrs
      (p: _:
        super.${p}.overrideAttrs (_: {
          doNixSupport = false;
        }))
      localPackagesQuery;
  in
  super' // local';
......
```

## その他
### ocamlformat
ocamlformatは使うのに微妙にコツがいる｡
具体的には､設定ファイルに指定したバージョンとコマンドのバージョンをあわせる必要がある｡
ひと手間ではあるのだが､ひと手間すらかけたくないのがエンジニアの怠惰な性｡
opam-nixで依存を解決するときに､nix expressionで設定ファイルからバージョンを取得し､該当するバージョンのocamlformatを使うようにしている｡

```nix:それ､nixでできるよ
# part of flake.niix
......
ocamlformat = pkgs.callPackage ./nix/ocamlformat.nix { ocamlformat = "${src}/.ocamlformat"; };
......

# ocamlformat.nix
{ pkgs, lib, ocamlformat }:
let
  ocamlformat_config = lib.strings.splitString "\n" (builtins.readFile ocamlformat);
  re = builtins.match "version\s*=\s*(.*)\s*$";
  version_line = lib.lists.findFirst
    (l: builtins.isList (re l))
    (throw "no version specified in .ocamlformat")
    ocamlformat_config;
  version = builtins.elemAt (re version_line) 0;
in
builtins.trace
  "detect ocamlformat version: ${version}"
  version
```

# opam-repositoryにパッケージを上げる
さて､ライブラリかなんかができたんでopamに上げたくなったかもしれない｡
opamはopam-repositoryにPRを出して､approve & mergeされると`opam install`等で引っ張ることができるようになる[^3]｡

{% gh_repo ocaml/opam-repository %}

## dune-release
｢PR作るのダリィよ｣と思いましたよね｡dune-releaseを使うとopamファイルのvalidityチェックからPR自動生成までやってくれる｡

{% gh_repo tarides/dune-release %}

当テンプレートはタグを切ってpushするとopam-repositoryにパッケージをアップロードするためのPRを作ってくれる｡
GitHub Actioinsで使うには微妙に工夫が必要なので､する｡
GitHub APIでopam-repositoryをフォークしてPRを作るので､GitHub API tokenを生成する｡
また､内部的にsshではなくtokenを使ったhttpsでリポジトリのclone&pushをするようにする｡

{% raw %}
```shell:なんでこんなことせなあかんねん
$ git config --global user.email "${{ env.GIT_EMAIL }}"
$ git config --global user.name "${{ env.GIT_NAME }}"
$ git config --global url."https://github.com/".pushInsteadOf "git@github.com:"
$ echo "machine github.com login ${{ env.GITHUB_ID }} password ${{ secrets.GH_TOKEN }}" > ~/.netrc
```
{% endraw %}

そして､dune-releaseがデフォルトでopam-repositoryの保存場所を`$HOME/git/opam-repository`にしているので､そこにopam-repositoryを*手動で*引っ張る｡

```shell:なんでこんなことせな2
$ mkdir -p $HOME/git
$ git clone https://github.com/ocaml/opam-repository $HOME/git/opam-repository
```

あとはdune-releaseを実行すればOK｡

{% raw %}
```shell
$ eval $(opam env)
$ dune-release distrib --skip-lint --skip-build
$ echo "https://github.com/${{ env.GITHUB_ID }}/${{ env.GITHUB_REPO_NAME }}/archive/refs/tags/${{ env.RELEASE_VERSION }}.tar.gz" > _build/asset-${{ env.RELEASE_VERSION }}.url
$ dune-release opam pkg
$ dune-release opam submit -y --no-auto-open --token ${{ secrets.GH_TOKEN }}
```
{% endraw %}

あとはタグを切ってpushすればリリースが切られてopam-repositoryにPRが作られる｡
メンテナがレビューしてくれるので､問題なければマージしてもらう｡

---

これでOCamlの開発環境セットアップからCIとパッケージアップデートまで簡単にできるようになる｡
ぜひみなさんも使ってください｡


---
[^1]: 朗報は差分ビルドだが､悲報は差分がよくわからず全ビルドになることが多々ある
[^2]: この辺を参照: <https://github.com/tweag/opam-nix#package> 各パッケージの`with-{test,doc}`フラグを折る
[^3]: 全部ビルド等がうまくいくことや､マリシャスでないパッケージかどうかがチェックされるというメリットがある反面､パッケージのアップロードにコミュニケーションが必要になったりメンテナが休んでるときにアップロードできなかったりというデメリットもある｡OCamlのエコシステムがあまり成長しないのはこのせいなんj…
