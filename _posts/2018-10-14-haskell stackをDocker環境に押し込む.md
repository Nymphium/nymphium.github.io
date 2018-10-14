---
layout: post
title: haskell stackをDocker環境に押し込む
tags: [Docker]
---

# 背景
`pacman -S stack`とすると `haskell-*` パッケージを大量に引っ張ってくる｡
そして`pacman -Syu` するたびにそれら大量のパッケージのアップデートに費やされ､のみならず新たな`haskell-*`が依存パッケージとして追加される｡

鬱陶しいんじゃい!!!!! ということでstackはDockerコンテナにしまっちゃいましょうね｡

# ドッカー
適宜Dockerを使えるようにする｡
ここでは書かないので各自何らかの文献をあたってください｡

# ビルド
次のようなDockerfileを作る｡

```Dockerfile
FROM fpco/stack-build:latest

RUN useradd -m yourname

WORKDIR /home/yourname

ENV LANG en_US.UTF-8

USER yourname

CMD ["bash"]
```

fpco/stack-buildを元に作成するだけ｡

あとはビルドして使う｡

```shell-session
$ ls
Dockerfile ...
$ docker build --tag mystack .  # ビルド
$ docker run -itd --name mystack mystack #コンテナ立ち上げ
$ function stack() {
  docker exec -it mystack stack "${@}"
}
$ stack repl
......
Prelude >
```

# other
Docker内のstack経由でインストールしたコマンドももちろんつかえる｡

```shell-session
$ stack install ghc-mod
......
$ function ghc-mod() {
  docker exec mystack stack --no-stack-exe ghc-mod -- "${@}"
}
```

対話環境が必要な場合は`docker-exec`の引数に`-it`を渡せばよい｡

# おわり
観てのとおりstack-specificな話ではなくて､よりジェネリックに､手元を汚染しそうなツールを何でもかんでもDockerに詰め込めそうだ｡
2018年になってやっとDockerが分かってきてヤバいね｡
