---
layout: post
title: RAID0なF2FSにArchをインストールする
tags: [Linux,Arch]
---
<!--sectionize on-->
こんにちは､びしょ〜じょです｡女性が､自分の本当の気持ちに気づかずに男性に嫉妬するシーン最高ですね､本当に最高｡

# はじめに
https://twitter.com/Nymphium/status/745232517612003330
https://twitter.com/Nymphium/status/745977783994593281
https://twitter.com/Nymphium/status/746677081539411968

ところでSSDを買い換えました｡ArchInstallBattleです｡

#! TL; DR
ArchWiki嫁

# 準備
## ストレージ
まずSSDを換装します｡ThinkPad X1 CarbonなのでM.2 SSDですね｡いや〜こういうの買うとだいたい規格を間違えるんですよねぇこれ長いのと短いのがあって､でもまぁ流石にパソコン触って何年目だよってね

https://twitter.com/Nymphium/status/747008569107587073

## iso
Archの最新インストーラを引っ張ってUSBメモリに流し込む｡

# インストール
## partitioning
`/`と`/home`を分けようかなと思いました｡でも同一ストレージ上で分けてもなんだか効果薄い気もしますが､まぁ気分が大事っつーわけよ｡
で､今回は[RAID0にしてF2FSだな](http://www.phoronix.com/scan.php?page=article&item=linux_raid_fs4)､という気持ちがふつふつと湧いてきた｡
BtrFSのようにRAID機能を提供してくれているわけではまったくないので､mdadmすっぞ｡
買ったのが256GBのSSDなので､`/`に40G(× 2)､`/home`に60G(× 2)､残り`/boot`といった具合か｡

ではインストールメディアを刺して起動して`/dev/sda`かなんかを`cfdisk`かなんかで分ける｡

でパッといく｡`md0`が`/`で､`md1`が`/home`という感じ｡

```
$ mdadm --create /dev/md0 --level=0 --raid-devices=2 /dev/sdb1 /dev/sdb2
$ mdadm --create /dev/md1 --level=1 --raid-devices=2 /dev/sdb3 /dev/sdb4
```

## format
でF2FSでガッといく｡

```
$ mkfs.f2fs /dev/md{0,1}
```

## mount
でスッと…｡

```
$ mount /dev/md0 /mnt
$ mkdir /mnt/{home,boot}
$ mount /dev/md1 /mnt/home
$ mount /dev/sdb5 /mnt/boot
```

## `chroot`ing
で`pacstrap`とかなんとかしてサーッといって`arch-chroot`する｡以降はchroot下の話になるぽよ

`f2fs-tools`とか`refind-efi`をヌッとやる必要がある｡

```
$(chroot) pacman -S f2fs-tools refind-efi neovim
$(chroot) refind-install
```

## register raid device
ひとまず登録

```
$(chroot) mdadm --detail --scan > /etc/mdadm.conf
$(chroot) mdadm --assemble --scan
```

## mkinitcpio
`/etc/mkinitcpio.conf`をいじる必要があるんやな｡

```config
......
MODULES="...... f2fs crc32_generic crc32-pclmul"
......
BINARIES="fsck fsck.f2fs"
......
HOOKS="...... mdadm_udev ....."
......
```

## refind
あと`/boot/redind_linux.conf`をいじる｡

```
"Boot with standard option" "ro root=/dev/md0 md=0,/dev/sda1,/dev/sda2 md=1,/dev/sda3,/dev/sda4"
"Boot to single-user mode" "ro root=/dev/md0 md=0,/dev/sda1,/dev/sda2 md=1,/dev/sda3,/dev/sda4 single"
"Boot with minimal options" "ro root=/dev/md0 md=0,/dev/sda1,/dev/sda2 md=1,/dev/sda3,/dev/sda4"
```

ちょっとださいですね､パーティションラベルで指定する方法もあるそうですが､うーん｡

さて

```
$(chroot) mkinitcpio -p linux
```

chroot抜けてあれしてこれしておわり

俺はちゃんと起動した｡お前はどうだ?

# おわりに
fstabに[オプション](https://www.kernel.org/doc/Documentation/filesystems/f2fs.txt)をいろいろ突っ込んで爆上げや｡

---
今週は期末試験100連発です｡
