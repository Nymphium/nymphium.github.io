---
layout: post
title: LuaRocksとの戦い2
tags: [Lua, LuaRocks]
---
こんにちは､びしょ〜じょです｡クズ極まって奨学金が廃止になりましたが､とりあえず学籍は保持されました｡

さて本題

---
戦い1は[こちら](http://nymphium.hateblo.jp/entry/2015/02/01/153037)｡

[これ](https://github.com/Nymphium/luakatsu)をウッピデートしていたら色々問題が見えてきた｡いや､問題か…?


---
### luarocksがショボい

ぶっちゃけluarocksコマンドがショボい｡write_rockspecオプションでrockspecファイルを作るわけだが､source.urlはrockspecファイルを自力で編集する必要がある｡そのくらいオプションに追加してくれよ｡

そしてdescription.detailedも､detailedオプションの記述よりもREADME.mdのよく分からない部分を優先してしまうなど色々残念感が多い｡

というわけでひどく簡易的だがluarocks/write_rockspec.luaを一部書き換えた｡

```diff
89c89
<          rockspec.description.detailed = paragraph
---
>          -- rockspec.description.detailed = paragraph
95c95
<          rockspec.description.detailed = paragraph
---
>          -- rockspec.description.detailed = paragraph
222c222
< 
---
>    
258c258,259
<          url = "*** please add URL for source tarball, zip or repository here ***",
---
>          url = flags["url"],
```

何もしないとdetailedはREADMEの一部を適当に引っ張ってくる｡これはwrite_rockspec.luaのdetect_description関数を見ていただければわかる｡

で､luarocksコマンドはLuaで記述されており､どうやらwrite_rockspecオプションでは以後に続く`--hoge=huga`の形式のサブオプションを`flags["hoge"] = "huga"`のようにflagsというtableに突っ込んでいるようだ｡

というわけでsource.urlもオプションで記述できるように`flags["url"]`を用いた｡

これでとりあえずはrockspecを触ることも少なくなることを祈るしか無い｡


---
#### 追記 3/25
教えてもらいました｡

https://twitter.com/hisham_hm/status/580435538357944321

https://twitter.com/hisham_hm/status/580436720354750464

"--detailed"がREADMEを優先するのはバグだが､source.urlに関してはやはりボクが悪いですね｡

追記終わり｡

---
### tagについて

無事にluakatsuもv1.3になったということで､[LuaRocks](https://rocks.moonscript.org/ "LuaRocks")にrockspecを登録し､無事にインストールできるか試してみた

*…が､ダメ…っ!!*

これはボクが完全に悪く､バージョンはGitでtagを付けて分けており､[LuaRocksnのDocumentation](https://github.com/keplerproject/luarocks/wiki/Documentation)を読むと､soure.urlが"git://"から始まっていると､source.tagやsource.branchから､文字通りtagやbranchを指定することができるようだ｡

逆に､指定しないとmaster branchなどから引っ張ってくるようで､そのせいでインストールがうまく行かなかった｡

ということで､write_rockspecオプションのサブオプションに`--tag=TAG`を付けることで解決｡

Documentationは読もう(アイカツ格言)｡


---
## 全く関係ないその他

アイカツ2015年第3段､もう弾が切れそうなのでスミレちゃんのレアドレスが揃いそうにない｡
第4段のPVが公式から上がっており､ニューカマーの二人には期待が募るばかりである｡

