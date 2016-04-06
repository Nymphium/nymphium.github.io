---
layout: post
title: ArchLinuxをインストールしました｡
tags: [Linux]
---
どうもX1 Carbonのグラフィックドライバ調子が悪いように見える｡あるいは適切なドライバがインストールされていない｡

しんどくなってきた.jpなので､こういうところをよしなにしてくれるUbuntuでも使おう｡でもUnity(Wndow Manager)は好きじゃないのでXubuntuでも入れようか｡

―5年後―

https://twitter.com/Nymphium/status/624712527516073984

https://twitter.com/Nymphium/status/624733566245564416

https://twitter.com/Nymphium/status/624712750858547200

ドライバとかなんとかの前に大惨事だった｡ただこれはUbuntu特有の慣れが必要なのでこうなったとも言える｡
しかしインターネッツにある解説サイトがことごとくGUIの説明だけで､XubuntuとかLubuntuとか派生品が死亡するのはどうなんですかね｡
設定ファイルの場所と書き方とかそういうところを知りたかったわけよ｡

仕方がないのでArchに戻った｡せっかくだし､T芝を見習って個人的にチャレンジングなことをした｡

## rEFInd
GRUBよりもモダンな感じがするので入れた｡

```
# pacman -S refind-efi
# refind-install
```

なんて簡単な導入なんだ｡

## No Display Manager
Display ManagerにはいつもSLiMを使っていた｡一番軽い(と思う)し､いつもオートログインなので機能はぶっちゃけ全く要らない｡

***が､しかし***

https://twitter.com/mohemohe/status/624737072989863937

確認したところ､たしかにSLiMはアレだった｡でも他のDMもなんか微妙だしなぁオイ…｡と探していたところ､ちょうどいい物体が見つかった｡

[xlogin](https://aur.archlinux.org/packages/xlogin-git/)

これでミニマリズムをね､

```
# yaourt -S xlogin-git
# systemctl enable xlogin@username
```

~/.xinitrcを読んでくれるだけなので､これといった設定は要らず｡

## dnsmasq
[dnsmasq](https://wiki.archlinuxjp.org/index.php/Dnsmasq#NetworkManager)

DNSクエリをキャッスしてほげほげ…速くなる…

たしかに速くなった｡

## other daemons
[verynice](https://wiki.archlinux.org/index.php/VeryNice?redirect=no)とか[preload](https://wiki.archlinux.org/index.php/Preload)とかそういえば入れてなかった｡

---

Archを何度インストールしてもだいたい同じような感じになるので､Chefとかなんとか使わなきゃと毎回思う(が使わない)｡
