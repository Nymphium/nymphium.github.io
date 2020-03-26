---
layout: post
title: NVIDIAのGPUのファン速度を動的に変更する
tags: [ArchLinux, NVIDIA]
---

こんにちは､びしょ〜じょです｡最近GTX 750 Tiを買ったんですが､その金でCPUをもう少しマシにしたほうが良かったと思いました｡おわり｡


# 準備
ArchLinuxの話です｡まず `nvidia-settings`コマンドが使いたいので *nvidia-settings* をインストールします｡
ArchWikiだと*nvidia-utils* パッケージに入ってるような話しぶりですが実はそうではない(2016/05/09現在)｡

GPUファンを触りたいのでxorg.conf(.d)をいじる｡Device SectionでターゲットのGPUに言及しているところで	 `Option "Coolbits" "4"` を追加する｡

```conf:20-nvidia.conf
Section "Device"
    Identifier     "Device0"
    Driver         "nvidia"
    VendorName     "NVIDIA Corporation"
    BoardName      "GeForce GTX 750 Ti"
    Option         "Coolbits" "4"
    # ...
EndSection
```

ひとまず再起動してください｡

# nvidia-settings
`nvidia-settings` コマンドでGUIが表示され､ *GPU 0* - *Thermal Settings* などを見てみると **Enable GPU Fan Settings** と下にバーがあると思います｡
これでファンの速度を調節できるわけですな｡

## cli
さて自動化ということで､GUIを触っていくのは得策ではありません｡ `nvidia-settings`はコマンドラインにいろいろ渡すとGUIを触らなくてもよくなる｡

`nvidia-settings -e list` とすると､CLIから触れるパラメータが出ます｡ボクもよくわからないので詳細ははぶきます｡"fan"などでgrepしてみると､いろいろ出てくる｡察していくと **GPUFanControlState**と**GPUTargetFanSpeed**が必要なことが分かった｡まず前者でファン速度を変更できるようになり(0がdisabled､1がenabled)､後者がファン速度(単位は%､0〜100の整数)

なるほど｡

GPUの温度からファンの速度を変更したくなってくる｡それは`nvidia-settings -q '[gpu:0]/GPUCoreTemp'`で取れる｡OK｡
あとはスクリプトを書いてみる｡


```zsh:fnctrl.sh
#!/bin/zsh

temp=$(nvidia-settings -q '[gpu:0]/GPUCoreTemp' | grep Attribute | awk '{print $4}')

nvidia-settings -a GPUFanControlState=1

if [[ "${temp}" -gt 40 ]]; then # 41度以上でファン速度が爆速
	nvidia-settings -a GPUTargetFanSpeed=100
elif [[ "${temp}" -gt 38 ]]; then # 39度から70%
	nvidia-settings -a GPUTargetFanSpeed=70
else # デフォルト
	nvidia-settings -a GPUTargetFanSpeed=33
fi
```

雑ですが､まぁよしとします｡

# systemd.timerで温度を監視
systemdはなんでもできるし､cronも吸収した｡
5秒ごとに上のスクリプトを回したい｡
はいご覧の通り

```gpufnctrl.service
[Unit]
Description=gpu fan control

[Service]
Type=simple
ExecStart=/usr/bin/zsh /home/nymphium/.config/systemd/script/gpufanctrl.sh

[Install]
WantedBy=default.target
```

```gpufnctrl.timer
[Unit]
Description=watch GPU temperature every 5 sec

[Timer]
OnBootSec=1min ; 起動してから1分後に開始
OnUnitActiveSec=5sec ;以後5秒毎
AccuracySec=5sec ; ブレ(?)を修正
Persistent=true ; これが動かすserviceがFAILUREしても続ける

[Install]
WantedBy=timers.target
```

serviceファイルと同じ名前(同じ名前ではない)のtimerファイルを作成することで､指定した時間にserviceが実行される｡
timerファイルの`[Timer]`の項に`Unit=hoge.service`などとすると別のserviceファイルのコントロールができる｡

最初`/etc/systemd/system/`に置いたところ､timerは動くがserviceがFAILUREしまくるというよくわからない事態に陥ったため､`~/.config/systemd/user/`に配置したら無事動いた｡

# その他
<blockquote class="twitter-tweet" data-lang="en"><p lang="ja" dir="ltr">お母さんが母の日に欲しかったもの、これでしょ？<br><br>お母さん、いつもありがとう！<a href="https://twitter.com/hashtag/mothersday?src=hash">#mothersday</a> <a href="https://twitter.com/hashtag/%E6%AF%8D%E3%81%AE%E6%97%A5?src=hash">#母の日</a> <a href="https://twitter.com/hashtag/GameReady?src=hash">#GameReady</a> <a href="https://t.co/tEpeAmK6hp">pic.twitter.com/tEpeAmK6hp</a></p>&mdash; NVIDIA Japan (@NVIDIAJapan) <a href="https://twitter.com/NVIDIAJapan/status/729144379416272896">May 8, 2016</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

# 参考
[systemd/Timers](https://wiki.archlinux.org/index.php/Systemd/Timers) ArchWiki
[systemdでの定期実行(timerユニット)](http://qiita.com/sharow/items/e8f7d3e0628d7ee925db) Qiita
