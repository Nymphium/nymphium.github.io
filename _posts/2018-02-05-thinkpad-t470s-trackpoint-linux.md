---
layout: post
title: ThinkPad T470sのトラックポイントの感度をLinux上でも良くする
tags: [Linux, ThinkPad]
---

# はじめに
ThinkPadは何台か持っており､いずれもArchLinuxを突っ込んで遊んでいた｡
トラックポイントの調節も`xset`とかでなんとかなったんだけどT470sだけ全然設定できなくない?
しかも愛用していたソフトリムキャップと非互換にしやがってお前Lenovoふざけんなよ…｡
ということでなんとかしたる!

# 解
```shell-session
$ id="$(xinput | perl -ne 'if ($_=~/Mouse/) {s/.*id=(\d+).*/$1/; print $_}')"
$ xinput set-prop "${id}" "$(xinput list-props "${id}" | perl -ne 'if ($_ =~ /^\s*Coordinate/) { s/.*\((\d+)\).*/$1/; print $_}')" 1 0 0 0 1 0 0 0 0.2
```

## どゆこと
`xinput`コマンドでトラックポイントのidを取得します｡

```shell-session
$ xinput
⎡ Virtual core pointer                          id=2    [master pointer  (3)]
⎜   ↳ Virtual core XTEST pointer                id=4    [slave  pointer  (2)]
⎜   ↳ PS/2 Generic Mouse                        id=10   [slave  pointer  (2)]
⎣ Virtual core keyboard                         id=3    [master keyboard (2)]
    ↳ Virtual core XTEST keyboard               id=5    [slave  keyboard (3)]
    ↳ Power Button                              id=6    [slave  keyboard (3)]
    ↳ Video Bus                                 id=7    [slave  keyboard (3)]
    ↳ Sleep Button                              id=8    [slave  keyboard (3)]
    ↳ AT Translated Set 2 keyboard              id=9    [slave  keyboard (3)]
    ↳ ThinkPad Extra Buttons                    id=11   [slave  keyboard (3)]
    ↳ Integrated Camera: Integrated C           id=12   [slave  keyboard (3)]
```

3行目の`PS/2 Generic Mouse id=10   [slave  pointer  (2)]`がそれです｡
いちいち目grepしたくないでしょうし､Perlでサッと値を取ります｡Perlワンライナーも使い慣れるとsedやawkよりもいい感じに使えます｡

で､id=10のデバイスのCTM(Coordinate Transformation Matrix)の値を変更します｡
ちゃんとはわかってないですが､トラックポイントへの入力に対する割合(?)を表しており､そのうち入力をn倍にして受け付ける的な値を変更することで感度を爆上げします｡

デフォルト値は以下のように取得できます｡

```shell-session
$ xinput list-props "${id}"
Device 'PS/2 Generic Mouse':
        Device Enabled (140):   1
        Coordinate Transformation Matrix (142): 1.000000, 0.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000, 0.000000, 1.000000
        libinput Natural Scrolling Enabled (275):       0
        libinput Natural Scrolling Enabled Default (276):       0
        libinput Left Handed Enabled (277):     0
        libinput Left Handed Enabled Default (278):     0
        libinput Accel Speed (279):     0.000000
        libinput Accel Speed Default (280):     0.000000
        libinput Accel Profiles Available (281):        1, 1
        libinput Accel Profile Enabled (282):   1, 0
        libinput Accel Profile Enabled Default (283):   1, 0
        libinput Scroll Methods Available (284):        0, 0, 1
        libinput Scroll Method Enabled (285):   0, 0, 1
        libinput Scroll Method Enabled Default (286):   0, 0, 1
        libinput Button Scrolling Button (287): 2
        libinput Button Scrolling Button Default (288): 2
        libinput Middle Emulation Enabled (289):        0
        libinput Middle Emulation Enabled Default (290):        0
        libinput Send Events Modes Available (260):     1, 0
        libinput Send Events Mode Enabled (261):        0, 0
        libinput Send Events Mode Enabled Default (262):        0, 0
        Device Node (263):      "/dev/input/event15"
        Device Product ID (264):        2, 1
        libinput Drag Lock Buttons (291):       <no items>
        libinput Horizontal Scroll Enabled (292):       1
```

出力3行目の`Coordinate Transformation Matrix (142): 1.000000, 0.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000, 0.000000, 1.00000`ですな｡

変更は`xinput set-prop (dev-id) (prop-id) (value)`でおこないます｡
プロパティIDは､CTMの横に書いてある`142`がそれですね｡

```shell-session
$ xinput set-prop "${id}" 142 1 0 0 0 1 0 0 0 0.2
```

こちらもプロパティIDが固定なのかよく分からんのでPerlでスッと取りました｡


各パラメータをいじっていくとトラックポイントがメチャメチャな動きになって面白いんですが､そういった地道な努力の末に最後の`1.00000`がトラックポイント感度に関係していることがわかります｡
値を小さくすると感度がよくなります｡0.2あたりがちょうどよかった｡

# おわりに
Lenovo氏〜〜T470s用にもソフトリムキャップ出してくれ〜〜〜
