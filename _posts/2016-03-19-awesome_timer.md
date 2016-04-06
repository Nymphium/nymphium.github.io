---
layout: post
title: awesome WMでタイマー
tags: [awesome,Lua]
---

<!--sectionize on-->

こんにちは､びしょ〜じょです｡映画プリパラとミルキィホームズを観てきました｡連続で森脇ふでやすペアの作品は疲れますね｡

# はじめに
世の中にはこんな便利なLuaモジュールがあります｡

{% gh_repo nymphium/luakatsu %}

ところでawesomeというLuaで設定ファイルを記述できるウィンドウマネージャがあります｡ピンときましたね｡

そうですね､*お誕生日にメッセージが出る*とハッピーですね｡

# awesome timer API
awesomeには実はtimer APIというものがあったんですねぇ…｡

[awesome API Document: timer module](https://awesomewm.org/doc/api/modules/timer.html#timer)

せっかくなのでちょっとみてみます｡ドキュメントは(個人的に)初見だと若干不親切だったので補足ッピよ｡

##! table
###! timer
`timer`はtableですが､オブジェクト指向のクラスだと思ってください｡
awesome実行時に_Gに展開されます｡
`{timeout = N}`というtableを渡すことでインスタンスを生成します｡
この`N`は､number型で､N秒ごとにこのインスタンスに登録されているイベントを､やっていく｡
また､読み取り専用でインスタンスには`started`というbool型のメンバ変数があり､インスタンスのタイマーが開始されているか(後述)がわかります｡

このtimreインスタンスにイベントを追加していくということです｡

##! function
###! t:start()
timerのインスタンスtを開始します｡これによりtのタイマーが起動し､`t.timeout`秒ごとにイベントを繰り出します｡
`T:f()`は`T.f(T)`の糖衣構文なのでもちろん`timer.start(t)`とすることもできます｡

このとき､`t.started`は`true`となります｡

###! t:stop()
インスタンスtのタイマーを止めます｡

このとき､`t.started`は`false`となります｡

###! t:again()
止まっているtを再開します｡

###! t:connect_signal(signame, func)
これがイベントの追加関数です｡`signame`にはstring型でsignal名を追加します｡
signal is 何な人はawesome のsignalを学んでほしい｡と言いたいところですが､timerは`"timeout"`signalを見るので､ここは`"timeout"`とでもしておいてください｡
`func`には関数を追加します｡この登録する関数は第1引数にtを取ります｡第2引数以降にブツをわたしたいときは､後述の`t:emmit_signal()`を使います｡

###! t:disconnect_signal(signame, func)
イベントを削除します｡`signame`は上記と同じですね｡`"timeout"`としておいてください｡
`func`ですが､例えば`foo`という関数を登録した場合､`t:disconnect_signal("timeout", foo)`としないといかんのですな｡

ところでLuaでは各関数にidが振ってあります｡
`tostring(foo)`などしてみるとidが伺えます｡
これはtableも同じで､中身が同じでもidが異なると､`foo == bar`は`false`を返します｡

なにが言いたいかというと､`disconnect_signal()`の第2引数には登録した関数そのものを渡したいので
､イベントを削除したい場合は`connect_signal()`に無名関数を渡すのはまずく､適当な変数にバインドしてください｡

###! t:emit_signal(signame, ...)
インスタンスtの`signame` signalに登録されている関数すべてを適用します｡各関数の第1引数にはtが､それ以降には`...`が渡されます｡

###! timer.instances()
timer全体で登録されているイベントの数を返します｡インスタンス毎じゃないぞ､timer全体だぞ｡なので引数はいりません｡

# 実装
まず考えよっか｡

---

luakatsuの`find_birthday()`を使います｡`find_birthday(today)`でアイドル情報が帰ってきたらそれを出力します｡

```lua
local idol = Aikatsu.find_birthday(os.date("%m/%d"))

if idol then
	...
end
```

awesomeの通知モジュールというとnaughtyです｡これは`naughty.notify {title = ..., text = ...}`といった感じで､うん｡

```lua
naughty.notify {
	title = "notificatoin",
	text = "今日は" .. idol.name .. "ちゃんの誕生日だよ!"
}
```

これを関数にして､例えば毎日0000､0600､1200､1800あたりに発火してみます｡
でもこのままだと起動時即`t:start()`するとよくわからない時間に通知が出ますね｡調節します｡

区切りのいい時間になったら通知タイマーを開始させるタイマーを作ってみます｡
パディング用のタイマーのtimeoutをうまくやります｡とりあえずベタな方法でいってみます｡

```lua
local now = os.date"*t"
local sec = (now.hour * 60 + now.min) * 60 + now.sec

if sec < 21600 then
	sec = 21600 - sec
elseif sec < 43200 then
	sec = 43200 - sec
elseif sec < 64800 then
	sec = 64800 - sec
elseif sec < 86400 then
	sec = 86400 - sec
end
```

次に行く前に通知タイマーを作ってしまおう｡

```lua
local luakatsutime = timer {timeout = 21600} -- every 6 hours
luakatsutimer:connect_signal("timeout", celebrate_notify)
```

登録する関数はこんな感じですか｡

```lua
local function padding(timer)
	return function(self)
		self:stop()
		timer:start()
	end
end
```

Luaは外のブロックで定義された変数も見えるので特に必要はないですが高階関数にしてあります｡
実際に実行したいタイマー`timer`を引数にとり､期を待ちます｡
第一引数には登録したインスタンスが来るので､`self`で受けます｡で､中で`stop()` & `start()`｡

この関数をパディング用タイマーに登録してさっきの泥臭い手法で計算した`sec`秒後に発火させておわり｡

## 全体
```lua
do
	package.path = package.path .. LUAKATSU_PATH
	local naughty = naughty or require'naughty'
	local timer = timer or require'timer'
	require'luakatsu'

	local tsig = "timeout"

	local function oiwai()
		local today = os.date "*t"
		today.md = ("%02d/%02d"):format(today.month, today.day)

		local idol = Aikatsu.find_birthday(today.md)

		if idol then
			naughty.notify {
				title = today.month .. "がつ" .. today.day .. "にち",
				text =  "今日は" .. idol.name .. "ちゃんのお誕生日だよ!",
				height = 50,
				whdth = 160,
				timeout = 10,
				fg = "ff0000", -- 黄色背景に赤文字でアイカツ感を出す
				bg = "ffff00",
				run = -- notificatoinをクリックするとお祝いツイートができる
					function(n)
						awful.util.spawn(
							"xdg-open https://twitter.com/intent/tweet?text="
							.. (idol.name):gsub("%s", "+")
							.. "ちゃん誕生日おめでとう!"
						)
						naughty.destroy(n) -- そして消える
					end
			}
		end
	end

	local luakatsutimer = timer{timeout = 21600} -- every 6 hours
	luakatsutimer:connect_signal(tsig, celebrate_notify)

	local now = os.date"*t"
	local sec = (now.hour * 60 + now.min) * 60 + now.sec

	if sec < 21600 then
		sec = 21600 - sec
	elseif sec < 43200 then
		sec = 43200 - sec
	elseif sec < 64800 then
		sec = 64800 - sec
	elseif sec < 86400 then
		sec = 86400 - sec
	end

	celebrate_notify() -- 起動時にも出したい

	local function padding(timer)
		return function(self)
			self:stop()
			timer:start()
		end
	end

	paddingtimer = timer{timeout = sec}
	paddingtimer:connect_signal(tsig, padding(luakatsutimer))
	paddingtimer:start()
end
```

実装の全体図です｡
awesome-clientなどで`error(pcakage.path)`などdirtyな方法で`package.path`をさっと確認してもらえればわかりますが､luakatsuなどがありそうなパスは読んでくれませんね｡
ということで､`package.path`にパスを追加します｡設定ファイル内の名前空間を汚したくないので､`do ... end`でくくっています｡

# demo
https://twitter.com/Nymphium/status/711097741535895552

今日は3/19で､あいにくアイカツキャラで誕生日の人はいませんでした｡が､アイマスなら人間が多いので今日もだれか誕生日だろうという予想がずばりあたり､後略

# おわりに
awesomeは実はまだまだ機能が豊富なんですよねぇ〜使ってない機能は多々あるのでガンガン発掘していきたい｡
awesomeは今年に入ってから3.5.6→3.5.9と開発がぐんぐん進んでいるので注目していきたい｡

おわりだよー(○・▽・○)

---

明日はアイカツのあれのライブですが､自由席で整理番号がなんと41番だったのでやっぱり日頃の行いがな〜最高〜〜

