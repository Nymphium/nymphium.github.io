---
layout: post
title: 技術書典6に合同誌を出した; effect system勉強会をやった
tags: [技術書典, effect system, 勉強会, Algebraic Effects]
---

こんにちは､びしょ〜じょです｡
なんか最近時間なくないですか? モンスターをハントしてる場合ではないんですが…｡

# 技術書典6
4月の話なんですが5月にやっていいですか｡やります｡
典5に続いてDragon Universityやっていきました｡

首謀者の{% twid rizaudo %}､{% twid ntsc_j %}や{% twid xrekkusu %}とだいたい似た面子で行った｡
前回同様ぼちぼち売れたので打ち上げで無事生肉を焼く儀式を開くことができました｡

https://twitter.com/Nymphium/status/1119188965997678592

しかし前回と比べて売上はやや落ち込みました｡
貴重なAI人材(AI人材ではない)rizaudo氏が今回はネットワークシミュレータの記事で挑んだためではないかと推察されます｡

『Let's go Algebraic Effects and Handlers: from an introduction to advanced topics』というタイトルで書きましたが､3月はPPLに行ったり九州旅行に行ったりして気づけばギリギリになってしまいadvanced topicsに関してはちょっと物足りなくなってます｡
他3記事も面白いのでそれで目をつぶってください｡

{% twicard "Dragon University 2019.4(技術書典6) - BOOTH" https://dragonuniversity.booth.pm/items/1317197 %}

# effect system勉強会をやった
[前回](http://nymphium.github.io/2019/03/28/%E5%8B%89%E5%BC%B7%E4%BC%9A%E3%82%92%E9%96%8B%E5%82%AC%E3%81%97%E3%81%9F%E3%82%89big-name%E3%82%92%E5%8F%AC%E5%96%9A%E3%81%97%E3%81%A6%E3%81%97%E3%81%BE%E3%81%A3%E3%81%9F.html)触れたとおり､来る5月26日に日本全国のeffect system researcherやuserが集うかもしれないeffect system勉強会がありました｡

{% twicard "effect system勉強会 - connpass" https://connpass.com/event/124786/ %}

"日本全国のeffect system researcherやuserが集うかもしれない" なんて適当言いましたが､予想を上回る数の参加者に驚きました｡
最初はマイナージャンルだし集まるのは高々20人くらいだろうと思ってたんですがなんかめちゃくちゃ人きた……｡

ボクが適当人間であることを知ってるので会場を積極的に用意してくれた {% twid linerlock %}センパイおよびサイボウズ株式会社様ありがとうございました｡
カンファレンスルームは最大200人収容できるそうです｡あとパークがある｡

https://twitter.com/Nymphium/status/1132562844807884800

また､主催として同行していただいていろいろやっていただいた{% twid ryotakameoka %}さん{% twid hiroqn %}さんありがとうございました｡
そして発表者の皆さんと参加者の皆さんも勉強会を盛り上げて頂いて大変ありがとうございました｡

発表は20分枠が私含め5人+10分枠が3人と､8人も集まりました｡effect systemというジャンルで8人集まるのはすごいと思いました｡

それでは発表を軽く見直してみましょう｡

## Extensible Eff Applicative
{% twid halcat0x15a %}さんによる発表でした｡資料は[こちら](https://www.slideshare.net/SanshiroYoshida/extensible-eff-applicative)｡

Free ApplicativeをOpen UnionでEffのように複数の文脈をいちどきに扱えるように拡張するという内容でした｡
皆さんへの課題として､簡潔なハンドラの定義と､データ構造をどうするかというものが与えられました｡

HaskellをモリモリやってないんでApplicativeにできてMonadにできないことがあるのは知らなかったデス｡
モチベーションがわかりやすくて課題とそれに対する複数の解法とそれらの利点欠点がまとまっており非常にわかりやすかったです｡

https://twitter.com/_yyu_/status/1132501011866607618
https://twitter.com/dico_leque/status/1132500764197236736
https://twitter.com/fumieval/status/1132501183875100672
https://twitter.com/fumieval/status/1132502512680833024
https://twitter.com/dico_leque/status/1132503577019133953

## 名前付きextenslble effects
次は{% twid fumieval %}さんの発表でした｡資料は[こちら](https://shared-assets.adobe.com/link/a5ae0acd-4d78-4774-6590-2b6b79b5dcc1)｡
イラレでスライド作っとる!!? すごい……｡

内容は､extensible effectsに名前をつけることで種々の問題を解決するというものでした｡
モナトラの問題点とextensible effectsによる解決と､extensible effectsに残った問題点と名前付きextensible effectsによる解決と､うまく要点のまとまった発表でした｡

open unionをdictionaryにするのはなかなかおもしろいですね｡

<p style="font-size: 34pt;">今すぐダウンロー</p>

{% twicard "http://hackage.haskell.org/package/extensible" http://hackage.haskell.org/package/extensible %}

<p style="font-size: 34pt;">ド</p>

{% twicard "fumieval/extensible - GitHub" https://github.com/fumieval/extensible %}

https://twitter.com/ryotakameoka/status/1132504296530989056
https://twitter.com/blackenedgold/status/1132504993011912704
https://twitter.com/dico_leque/status/1132505654705283072
https://twitter.com/ryna4c2e/status/1132505916241108992
https://twitter.com/ryna4c2e/status/1132506703084212224
https://twitter.com/Nymphium/status/1132507189275348993

## Effect{ive,ful} Cycle.js
3番手は{% twid ryotakameoka %}さんの発表でした｡

{% twicard "Effect{ive,ful} Cycle.js - Qiita" https://qiita.com/ryota-ka/items/b46f43dc18a9229feb03 %}

内容は､Webフロントエンドにおける様々な副作用をCycle.jsでうまくやっていくというものでした｡

副作用を分離して処理したい､まさにalgebraic effectsがやろうとしてることですね｡
実際にHERP社さんですか?でもプロダクトですでに活用しているとのことです｡
HERP社さん面白いですね｡
product-capableなCycle.jsの実装を見ていくと面白いものが見られるかも｡

ryotakaさんがトゥギャ(?)ってたのを引用します｡

{% twicard  "Effect{ive,ful} Cycle.js"  https://twitter.com/i/moments/1132869165562310656 %}

## Effective Rust
続いて{% twid __pandaman64__ %}さんの発表でした｡資料は[こちら](https://docs.google.com/presentation/d/1RYu-XDa0GWGGxAcOq2LzYEjJLbQYcWM-DJcN2hN9g2I)

Rustのcoroutinesを使ってalgebraic effectsを実装したぜ､という内容でした｡
なんと[ボクの記事](https://nymphium.github.io/2018/12/09/asymmetric-coroutinesによるoneshot-algebraic-effectsの実装.html)を読んでインスピレーションを受けたそうです｡
書いた甲斐がありました｡

Rustだと所有権が絡んできて大変な場面があり､Frankを参考にするとうまくいったという面白い噛み合わせの話が聞けました｡
また序盤のいらすとやによる所有権の話がわかりやすくて面白かった｡

https://twitter.com/Nymphium/status/1132520285477847040
https://twitter.com/blackenedgold/status/1132520179206725634
https://twitter.com/mod_poppo/status/1132520819630804992
https://twitter.com/mod_poppo/status/1132521274125590528
https://twitter.com/kakkun61/status/1132522163989204992
https://twitter.com/blackenedgold/status/1132523401271074816
https://twitter.com/__pandaman64__/status/1132590740159131649
https://twitter.com/bd_gfngfn/status/1132524127556739072

書典6で販売したRustのジェネレータの解説本をBOOTHでも販売中とのこと｡

{% twicard "Rustジェネレータ徹底解説 - BOOTH" https://booth.pm/ja/items/1318774 %}

## Monads and Effects
5番目は{% twid myuon_myon %}さんの発表でした｡

{% twicard "Monads and Effects - Speaker Deck" https://speakerdeck.com/myuon/monads-and-effects %}

effect systemとはなにかから､Kokaを題材にあげ､最終的にmonadsとの関係について述べるという内容でした｡

Kokaの処理系の[ビルドシステム周りで少しだけcontributionした](https://github.com/koka-lang/koka/pull/74)ので勝手に親近感を持ってる言語です｡
あとshift0/reset0は書けるけどshift/resetは型で弾かれた経験があるので､もう少し頑張ってトライしてみたいです｡
{% twicard "Nymphium/typed-delimcc.kk" https://gist.github.com/Nymphium/3cb574cb511a179a30390599e6e51669 %}
圏論におけるMonadわからんマンなのでがんばっていかんとな……

https://twitter.com/inamiy/status/1132527229370478594
https://twitter.com/yuchiki1000yen/status/1132527206490447873
https://twitter.com/yuchiki1000yen/status/1132528208065073152
https://twitter.com/GolDDranks/status/1132528469156302849
https://twitter.com/e_ntyo/status/1132528132940951553
https://twitter.com/shionemo/status/1132528733217148928
https://twitter.com/keita44_f4/status/1132529327411613699
https://twitter.com/keita44_f4/status/1132530399161139200
https://twitter.com/Nymphium/status/1132530719325020160
https://twitter.com/blackenedgold/status/1132530858819088384
https://twitter.com/bd_gfngfn/status/1132531060141506561
https://twitter.com/bd_gfngfn/status/1132533468221493248

↑Frankの論文のタイトルが『Do be do be do』なのってFrank Sinatraの捩りか

## How do you implement Algebraic Effects?
6番目はボクが発表しました｡資料は[こちら](https://nymphium.github.io/pdf/effect_study.html)｡

内容は､Algebraic Effects and Handlersのさまざまなインプリ方法について考える｡というものでした｡

libhandler, eff.lua, Multicore OCaml, Effekt, Effの内部の実装方針について軽くまとめてみました｡
いかがでしたか?
ライブラリとしてのalgebraic effectsの利点というのは､まさにボクの研究のモチベーションとして強く主張すべき部分なので言いたかったです｡
適切な場所がなかったのでconclusionの1枚手前という微妙な位置になってしまったのはかなり反省です｡
というわけでみなさんやっていきましょう｡

https://twitter.com/mod_poppo/status/1132534088089292800
https://twitter.com/ryotakameoka/status/1132534848910872577
https://twitter.com/inamiy/status/1132535016355901440
https://twitter.com/dico_leque/status/1132535471500718085
https://twitter.com/keita44_f4/status/1132535385085448193
https://twitter.com/dico_leque/status/1132536355332825089
https://twitter.com/myuon_myon/status/1132538503844073473
https://twitter.com/blackenedgold/status/1132538873425174528

手前味噌で持ってきたN-Barreled CPSですが､質問で耳寄り情報をいただきましたが､すでにAlgebraic EffectsをCPS変換する研究はあるそうです(当然)

{% twicard "Continuation Passing Style for Effect Handlers" https://bentnib.org/handlers-cps.html %}

あと{% twid __pandaman64__ %}さんが宣伝してたんでボクもしようと思ってそのまま忘れてたんで宣伝します｡
なんかいろいろまとめたやつです｡
大事なことなので2回

{% twicard "Dragon University 2019.4(技術書典6) - BOOTH" https://dragonuniversity.booth.pm/items/1317197 %}

## Effective Idris: Effects
次は{% twid blackenedgold %}さんの発表でした｡ 資料は[こちら](https://keens.github.io/slide/effective_idris__effects/)｡

Effを参考にしたIdrisのAlgebraic Effectsライブラリの話でした｡
Idrisに詳しくないんで "型がfirst-class" というところでspace catになってしまいました｡

https://twitter.com/rider_yi/status/1132545126603952128
https://twitter.com/inamiy/status/1132545844941533184
https://twitter.com/myuon_myon/status/1132546912035278849
https://twitter.com/myuon_myon/status/1132547550618120192
https://twitter.com/__pandaman64__/status/1132547897025687553

## Row-based type systems for algebraic effect handlers
最後は{% twid skymountain_ %}さんによる発表でした｡資料は[こちら](https://www.slideshare.net/TaroSekiyama/rowbased-effect-systems-for-algebraic-effect-handlers)

内容は､parameterized effectsを持つrow-based type systemsにおけるeffect handlerの話でした｡

序盤ではAlgebraic Effectsについて簡単な例から初めて丁寧な説明があり､effect systemを知らない方にも優しいintroductionでした｡

https://twitter.com/kakkun61/status/1132554009481322497
これは私がミスったわね｡

parameterized effectsの導入から､row-based effect systemとその特徴について述べ､他のset-based onesとの比較など大変わかり易く面白い内容でした｡

Kokaの論文を中途半端に読んでたのでtype systemの部分をちゃんと読み直そうと思います｡
fumievalさんの名前付きextensible effectsとrow-based effect systemはなにか近そうな感じがするので､深堀りしてみると面白い発見があるかもしれない｡

call for collaborationも出していらっしゃったので興味のある方はぜひ｡

https://twitter.com/myuon_myon/status/1132550779267477506
https://twitter.com/yuchiki1000yen/status/1132552819586658304
https://twitter.com/Nymphium/status/1132553055377866753
https://twitter.com/Nymphium/status/1132553610686951424
https://twitter.com/nekketsuuu/status/1132554452349595649
https://twitter.com/bd_gfngfn/status/1132555193713741824

## こんしんかい
(めっちゃ腹減ってたししこたま酒を飲んだんで写真などは)ないです

25人くらい参加してくださいました｡

---

開催しといてなんですがどうなるかと思ってました､が､参加者5､60人くらい+発表者8人と大きな会で無事発表もつつがなく終わって本当に良かったです｡

# 他
ん?

https://twitter.com/keigoi/status/1132522206502633472

(うち一人ですが資料づくり終わって)ないです…
