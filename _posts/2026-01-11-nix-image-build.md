---
layout: post
title: DarwinホストでNixでDocker imageをビルド､するんだぜ
tags: [Nix]
---

小ネタ

---

皆さんご存知Dockerfileを用意せずともNixでDocker imageをビルドすることができる｡

```nix :nix/image.nix
{
  pkgs,
  tag ? "latest",
  app ? pkgs.hello,
}:
pkgs.dockerTools.buildImage {
  name = "app";
  inherit tag;
  created = "now";
  copyToRoot = pkgs.buildEnv {
    name = "app-root";
    extraPrefix = "/usr/local";
    paths = [ app ];
  };
  config = {
    Env = [
      "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
    Entrypoint = [
      "${pkgs.dumb-init}/bin/dumb-init"
      "--"
    ];
    ExposedPorts = {
      "8080/tcp" = { };
    };
  };
  compressor = "zstd";
}
```

```nix :flake.nix
{
  # ...
  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # ...
        image = pkgs.callPackage ./nix/image.nix { };
        # ...
      in
      {
        packages = { inherit image; };
      }
    );
}
```

そしてimageをビルドし､dockerでロードして実行する:

```sh
$ nix build .#image --no-link -o image.tar.zst
$ docker image load -i image.tar.zst
$ docker container run --rm app:latest hello
hello
```

すんなり動くだろう…… *あなたのホストOSがLinuxならば* ｡

まず大前提として､Dockerコンテナの実体はLinuxである｡
macOSホストでDockerを実行する場合､LinuxのVMがDocker Desktop等により立ち上げられており､そのLinuxカーネルが各コンテナに共有されて動作する｡

ところで､`nix build .#image` の指す `.#image` は `.#packages.${builtins.currentSystem}.image` のエイリアスであり､現在のアーキテクチャのパッケージをビルドする｡

つまりホストOSが`x86_64-linux`ならばx86_64向けのELFから成るバイナリの詰まったDockerイメージをビルドしてくれるが､`*-darwin`なら *Mach-O形式のバイナリから成るDockerイメージ* がビルドされる｡
これをLinuxが動いているコンテナ上で実行すると当然executable format errorになる｡

ではどうするか? いくつかやり方はあるが､今回は2つ紹介する｡

一番カンタンな方法として､対象をDocker上でビルドする｡
Dockerに完全に非依存でOCIイメージをビルドしたいというモチベーションならば本末転倒だが､アプリケーションのDockerfileをNixで管理･記述したいだけならば､メタなDockerfileは許容されるだろう｡
NixOSベースでもよかったが､experimental featuresを有効化しないといけなかったりnixos/nixがキャッシュされてなくて引っ張るのに時間かかったりするので､一旦Debianベースにして[DeterminateSystem/nix-installer](https://github.com/DeterminateSystems/nix-installer)を利用する｡

```Dockerfile
# syntax=docker/dockerfile:1

FROM debian:stable-slim AS builder

RUN apt-get update && apt-get install -y git curl
RUN curl -fsSL https://install.determinate.systems/nix \
  | sh -s -- install linux --init none --no-confirm \
       --extra-conf \
         "cores = 0" \
         "filter-syscalls = false" # Apple Siliconにて必要

ENV PATH="${PATH}:/nix/var/nix/profiles/default/bin"

WORKDIR /app

RUN --mount=type=bind,source=.,rw \
  nix -L build '.#image' --show-trace -o /image.tar.zst

FROM scratch AS out
COPY --from=builder /image.tar.zst /
```


`buildx`で`linux/${ホストのCPU arch}`を指定し､output optionを利用することで`image.tar.zst`が生成されるので､あとは上記同様に`docker image load -i image.tar.zst`すれば無事`hello`を実行できるコンテナが展開される｡

```sh
$ docker buildx build --platform linux/arm64 -t app:latest . -o .
```

この方法の注意点は､当然ながらDocker上でビルドされるため､Nixのキャッシュがホストに保存されない｡

これの解決のため､もう一つの[darwin.linux-builder](https://nixos.org/manual/nixpkgs/stable/#sec-darwin-builder)を使う手法を紹介する｡

{% twicard "" https://nixos.org/manual/nixpkgs/stable/#sec-darwin-builder %}

簡単に申し上げると､(Linuxベースである)NixOSのVMをQEMUから起動し､そこにホストからコピーしたソースをderivationとしてビルドする｡
つまり分散コンパイルですね｡

まずユーザをtrusted-userとして登録し､`${ホストのCPU arch}-linux`用のビルダーとして追加する｡
darwin.linux-builderはSSHで接続するが､SSH鍵はdarwin.linux-builderが生成してくれるのでSSHの設定だけ追加する｡

```sh :リンクをかいつまむと
$ echo "extra-trusted-users = $USER" >> /etc/nix/nix.conf
$ echo 'builders = ssh-ng://builder@linux-builder' \
'aarch64-linux /etc/nix/builder_ed25519 4' \
'- - - c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUpCV2N4Yi9CbGFxdDFhdU90RStGOFFVV3JVb3RpQzVxQkorVXVFV2RWQ2Igcm9vdEBuaXhvcwo='
$ cat <<EOL >> /etc/ssh/ssh_config.d/100-linux-builder.conf
Host linux-builder
  Hostname localhost
  HostKeyAlias linux-builder
  Port 31022
  User builder
  IdentityFile /etc/nix/builder_ed25519
EOL
$ sudo launchctl kickstart -k system/org.nixos.nix-daemon
```

そしてイメージのビルド前にlinux-builderを起動しておく｡

```sh
$ nix run nixpkgs#darwin.linux-builder
Creating Nix store image...
Created Nix store image.
[    0.082206] armv8-pmu pmu: hw perfevents: failed to probe PMU!

<<< NixOS Stage 1 >>>
<<< Welcome to NixOS 26.05pre-git (aarch64) - ttyAMA0 >>>

Run 'nixos-help' for the NixOS manual.

nixos login: builder (automatic login)


[builder@nixos:~]$ uname -a
Linux nixos 6.12.64 #1-NixOS SMP Thu Jan  8 09:15:06 UTC 2026 aarch64 GNU/Linux
```

Ctrl-Dを連打してもVMは止まらんので`shutdown now`で終了する｡

VMが立ち上がったところで､ホスト側でおもむろに

```sh 
$ nix build .#packages.aarch64-linux.image --no-link -o image.tar.zst
```

を叩くとビルドに成功する｡`-L`オプションなどつけてログを観察すると､linux-builderにcopyして生成物をpullしているのが見える｡

この手法の良い点は､Nixキャッシュがホスト側に保存されるところにある｡
ソースからderivationのハッシュが得られ､ *どうやって生成されるかにかかわらず* ホスト側にderivationが得られれば`/nix/store`に置かれるので､linux-builder上でビルドしてもOKなんやね｡
なのでlinux-builder VMを再起動したり変更をほどこしても､ちゃんと差分だけをビルドしてくれる｡

---

SSHでビルダーと通信できるちゅうことはリモートにビルドサーバを用意してもええわけですし､他にも[Determinate Nixのnative Linux builder](https://determinate.systems/blog/changelog-determinate-nix-384/)を利用してもよい｡
とまあやり方は様々だが簡単な順に[^1]2つ紹介した｡

[^1]: これって私の感想ですよ
