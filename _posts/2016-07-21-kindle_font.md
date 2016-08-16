---
layout: post
title: うわ〜ん変わっちゃった〜〜! kindleのフォントが変わっちゃった〜! どうか､しましたか? kindleのフォントが変わってしまったのですが…｡
tags: [Kindle, 雑感]
---
# はじめに
Kindleの最安モデルがホコリをかぶっていたのですがなんとなくマウントしてみたところフォントの変更に成功した｡
こんなんググればいっぱい出てくると思うので今更書くまでもない話ですが､体験として面白かったので書いておく｡

# mount, ls
USB接続すると､/dev/sdc1というものが生える｡
`lsblk -f`とすると､どうやらvfatのようだ｡マウントする｡`ls`を撃ち込むと､document､systemというディレクトリ､名前がハッシュのファイルなどがある｡

# 怪しいsystem
あきらかにsystemディレクトリに何かありそうだ｡*fonts*というディレクトリがぶら下がっており､フォントを変えたい気持ちが突然わいてきた｡

# fonts
中を見ると､*ja.font*というファイルがある｡これやな｡

# cramfsやんけこれ
`xxd -g 1 ja.font | head`してみると**45 3d cd 28**というのが見える｡もちろん知らないのでググる｡Comressed ROMFSということが分かった｡
これもマウントしてみる｡
01-ja.confというfontconfigファイルとimage\_manifestというフォント情報などが書かれたjsonファイルっぽいもの､ありましたねぇttfファイルが置かれているfontsディレクトリ｡

# read-onlyじゃんハゲ! コピーする
とのこと

# fontをつっこむ
好きなフォントを突っ込もう!! ライセンスを無視するのは :no_good:

JSONに書かれた情報を更新する｡`"FONTFILE.ttf.md5"`というパラメーターがあるので､`md5sum FONTFILE.ttf`で得た値を差し込む｡
`"fonts.ja"`には明朝体をローマ字で書く(のか?)｡`"font.MINCHOROMAN.display"`パラメーターにはUTF-8でフォント名を埋め込みたい｡
ここでLua5.3の`utf8`モジュールが役に立つわけですね! MoonScriptのリスト内包表記も便利だ!!

```moon
print table.concat ["\\u%x"\format c for _, c in utf8.codes "FONT-NAME"]
```

# mkfs.cramfs
コピーおよび変更したディレクトリをComressed ROMFSにもどす｡

# すっとする
Comressed ROMFSに戻したイメージファイルをja.fontとしてスッと戻す

# umount､確認
ええな

# おわりに
買ってすぐ(2015年1月あたり)にフォントの変更を試み､ググってみたりはしたものの結局フォントの変更に至らなかったので､今回はよくやったと思いました｡
`file`コマンドなどの使用をパッと思いつけばもう少し早くできましたね､反省してください｡


