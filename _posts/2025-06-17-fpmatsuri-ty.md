---
layout: post
title: 関数型まつり2025ありがとう､そして補足
tags: [関数型まつり, Continuations, 雑感]
thumb: yes
---

こんにちは､びしょ〜じょです｡

ナイトレインは買ったら最後資料が作れなくなると思って発表終わるまで買うまいとしていたんですが､結局LoLのブロウルを無限にやってました｡
ショウジンTF黒斧のファイタールシアンが面白いですが､ナヴォリ積むならショウジンじゃなくてIEでよくないか? と思わなくもない｡
今ならポーションで無限スケールするので､天啓で金策ビルドも良いかもしれない｡
みんなのブロウル用クソビルドはどうかな?

---

# はじめに
[関数型まつり2025](https://2025.fp-matsuri.org/)にスピーカーおよびスポンサーとして参加した｡

{% twicard "" https://nymphium.github.io/pdf/fp_matsuri_2025.html %}

とりあえず発表すると人から声を掛けてもらえるのと､他の発表者に声を掛けやすいという雑なモチベで応募した｡
ちゅうか関数型というある程度話す内容のあるドメインではあるし｡
スライド作るのが､ジジイになって馬力や集中力が減り､当日発表30分前まで泣きながら作るという激ヤバだったんですが､とりあえず情報を詰め込むという発表においてはアンチパターン寄りな方向でバリューを出しにいった｡

## スポンサーブース
ブースに来てくれた方々にも話したが､弊社は積極的に関数型言語を使っているわけではなく､

- び｢これどうすか? プロポーザルも一応投げているが｣ 
- 社｢関数型明るくないけど採択されたらいいですよ｣
- →採択された

という流れでスポンサー出展が決まった｡
そもそも[PPLにもスポンサーしていた](https://note.com/eiicon/n/nd8df6784778d)ので､社内での出展ハードルはそんなに高くはなかったんですが､よかったですね｡

自転車置き場の議論のように誰でも参加できる､さらにインタラクションのある催しをしたいなと思ってたんで､仕事で書きたい言語にシールを貼ってもらうというアクティビティをした｡

https://x.com/eiicon_dev/status/1934188461940158531

https://x.com/Nymphium/status/1934500447915745508

シールを貼っていただいた言語について自分がたまによくわかんねえ話をするという謎システムですが､盛り上がってよかったです｡感謝

# 感想
まず自分の発表以外の部分｡
最初に言いたいのは…コーヒーがうまかった! ホットとアイスがあって大変うれしかったです｡ありがとうございました｡

Rustにモナドを入れたい話[^1]はなかなかおもしろく啓発的だった｡
MonadはRustのようなリソースセンシティブな型の上では､継続を使える回数でData Functor(anytime)とControl Functor(up to/ exact once)の2つに分かれる(そしてData Functor ⊃ Affine-Control ones ⊃ Linear-Control ones)(と非線形な富豪モナド)という発表最大のポイントも良かった｡

んですが､ *モナドは`do`を記述するためのデータ構造* という､おおよそ普段とは逆方向の見方が興味深い｡
`do` expressionの初出っぽい[Haskell 1.3 report](https://github.com/typeclasses/haskell-report-archive/blob/master/1996-05-haskell-1.3/haskell-report.pdf)では､
> A do expression provides a more readable syntax for monadic programming.

とあり､へぇ〜proceduralではないのだな､となるが､proceduralがreadableなことをimplyしてるのかなぁ〜とは思う｡
セミコロンによるsequenceはCなどの手続き的記述を流石に意識してないわけがないだろう｡
確かに副作用が起こる部分が1行ずつに分かれると､プログラムを追うのが大変ラクになる｡
コントロールを直列にする､CPSよりANF､ﾑﾆｬﾑﾆｬ…

非同期のやつ[^2]は､確かに非同期ランタイムを言語の上でやる場合Freeとインタプリタになって､計算木とCEKだ〜になった｡
CEK tripleを非同期キューで回すことで人々が思うような非同期ランタイムになれるとか､big-step semanticsだと継続が取り出せないんで[^4]非同期ランタイムとしては採用できず､プログラムをナイーブに読むときってbig-step semanticsなのかもなぁ……など｡

Scalaのcats-effectの例は､JVMのJITが頑張るんでナイーブなインタプリタでもOKとのことでしたが､ユーザレベルのランタイムでちゃんとやるってむずいよなぁ〜計算木を最適化するのかインタプリタをCPSで書いて言語自体の処理系がいい感じに最適化してくれるのを祈るかガチgotoで手動dispatchか…楽しいですね｡


# 補足など
完走した感想ですが､もう二度とBeamerでスライドは作りません……[^3]｡
あと奇しくも知り合いの方が直近で継続の話をしており､タイトルのテイストもなんとなく似ててウケ

{% twicard "" https://www.wantedly.com/companies/wantedly/post_articles/890437?utm_source=t.co&utm_medium=share&lang=ja %}

call/ccよりmodularなshift/resetや! という自分もすこし触れたものをRubyで掘り下げた内容｡
人は一般に､継続で何か話そうとすると､`/*Compiling with(out)? Continuations*/`というタイトルを先に考えたくなってしまい､そこから変形するので似てしまうわけですね｡

内容はまぁ〜先述のとおりカツカツだったのでゴチャついてるんですが､functionalとproceduralの比較とエフェクトになんで継続が絡むのかが整理できてよかったかなと｡
前者の対応関係は思ったより評判がよく､継続への理解がしやすいのとCPS-SSAはそんなにメジャーな話じゃないからかな｡
SSAのphi関数は､Join Point[^6]とかK-Normal Form[^5]に当たるが､素のCPSはcontinuationのコピーになる｡ちょっと重いですね｡
話し足りなかった部分でいくと､ANFとかdouble-barreled CPSとかSelective CPSなどといった様々な中間表現…｡

後者については､[昔ダラダラ書いた内容](https://nymphium.github.io/2019/07/21/effect_cont.html)をシャキッと話せたんで個人的にかなりスッキリしました｡
悔しいのは､スライド制作でChatGPTと相談していたときにこういった整理をチャGがしてきたこと｡
俺はもうAIに勝てないんや…いや俺のブログ学習してんだろ? 学習禁止〜!!

それはさておき､この発表で継続に興味を持った方とかもちらほら居て､やってよかったなぁ〜…｡

## Q など
バカタレなんで､発表30分前に資料作り終えたんで､発表練習ができず質問時間分も食ってしまった｡
申し訳ございません｡
懇親会などで質問等してくださった方々がおり､大変うれしいですマジで｡

### OCamlの人らがshift/resetを語るのはなぜ
OCamlで限定継続といえば[delimcc](https://okmij.org/ftp/continuations/implementations.html)と浅井先生の[shift/resetプログラミング入門](http://pllab.is.ocha.ac.jp/~asai/cw2011tutorial/main-j.pdf)[^7]なんですが､いずれもshift/resetを題材にしているため｡
Scala2.12に入っていた限定継続もshift/resetじゃなかったか?

スライド中でいっぱいでてきたdelimited controlsたちですが､一番強いのがcontrol0/prompt0で､GHCはさらにプロンプトつきのものを採用している[^8]｡
0系のが表現力高いというのは､(中略)よりプリミティブな操作のほうが強いということですね[^9]｡

### 妄想 -- parallel effect handlers
このあたりの話をしていて

{% gh_repo nymphium/eff.go %}

Goにコルーチンを作ってone-shot algebraic effect handlersといういつものテクをやろうとしたんですが

{% twicard "" https://nymphium.github.io/2023/11/27/go-algebraic-effects.html %}

コルーチンの管理にgoroutinesの参照をグローバルなstackで持つということをやっていて､並列にするとぶっ壊れるわけですな｡
事情は全然ちゃうんだけど､並列処理が標準で使えるようになったOCamlのalgebraic effect handlersでも､エフェクトの捕捉はスレッドをまたげないという制約がある｡
C FFIのコールスタックをまたげないという部分とも絡んでいるが､まあ､無理っちゅうわけですな｡
パラフレーズしておいてどれくらい関連あるか謎なんだけど､algebraic effect handlersは並列に少し弱いらしい｡

ランタイムの継続の表現､つまりコールスタックと変数ストアをポータブルな形にするとか､Cの呼び出し部分とのcompatibilityを保つとか､そのあたりをケアした話が出るんじゃないかなぁという妄想を語った｡
先に実装の話が､それこそOCamlのグループから出て来ると思うが､物好きな理論系の人が並列計算+代数的効果のモデルを提案するかもしれない｡

### "継続"という邦訳……
"Continuations"なんだからまあ"継続"ではあるが､じゃあ先に"継続"がでてきたらどう思いますか?
確かに……残りの計算というモノっぽい概念に対して"継続"って､あまり日本語話者の感覚ではない気がする｡
という話をしたら"残りの計算"もなんだか分からんと｡
"計算"もなんやねん! と｡

継続はstaticなのに"継続"といういかにもdynamicな語がワカラン! と言われたんですが､これはそもそも継続がdynamicなんですな｡
CPSにするとまあなんとなく感覚が掴めて､ほらCPS変換で得られたmetacontinuationは実行時に到達するんだしdynamicやないですか?
と説明したんだけど､だからって継続……ウーン……あなたはタイムスリップできたらもっとプロパーな名前付けられそうですか?

### Haskellなにが純粋やねん何がdoだモナドだ
igrepさんと懇親会でお話して､彼の発表にもある↑について
<https://the.igreque.info/slides/2025-06-15-fp-matsuri#(22)>

私も昔は確かに､IOは実際に発火してんだから純粋じゃないやんけHaskellerは詐欺師集団か!! と憤りを覚えたこともある｡
まあ今なら､純粋は "(Monadでエフェクトを隠蔽しているのであたかも)純粋(かのようにプログラムを記述し､`main`に`IO a`を接着させないと発火しませんよ)"の略であることは分かる｡
ただ､この"純粋"が略語であることを初心者は分からないんで､確かに純粋関数型言語って何言ってんだコイツにはなる｡
この辺もうすこし議論があるらしいんですが､議論のすえHaskellが"純粋"の看板を下ろしてもランタイムとIOのシステムは変わらないと思うんで､別にこの辺のレトリックにこだわらなくていいです(という話を↑ですこししてくれています)｡

IOプログラミングの本質は順序があってchainするという部分の話を共感してもらえ､手続き的に書く(`do`)にはmonadという構造が必要になる､というkonnさんの話にも戻っていって､エッセンシャルな部分なんやなぁということが再確認できた｡

### fcontrol/runとSCIENCE TOKYO
SCIENCE TOKYOでは某お茶女の研究室を出た方が継続を布教しまくってるらしい｡
今年のPPLではポスター発表にて､私も熱烈推奨しているfcontrol/runが理解しやすく学生ウケがよいという話を聞いた｡
しかし懇親会でshift/resetのみならずfcontrol/runも講義でもはや利用されてないと言われ椅子から転げ落ち横転して号泣して顔がなくなった｡
しかしよく聞くと､全部algebraic effect handlersに統一されるとのことで､逆にどうなってんねん､と真顔になった｡
SCIENCE TOKYOでとんでもないことが起きてますよ｡

### WASMとeffect handler
https://x.com/mizchi/status/1933808299285389329

なぁWasmFX､息してるか…? してる…

{% gh_repo wasmfx/specfx %}

発表で触れたOCamlのWASMバックエンドはselective CPSまたはJSPIでPromiseに変換される[^10] [^11]｡
特にJSPIでOKなのは継続がone-shotなところが出たわね｡

### その他
2日目に発表していたYoutuberの大堀さん…いや､あの大堀先生が､奇跡的なかみ合わせで本日継続に関する動画を投稿してました｡

{% twicard "" https://www.youtube.com/watch?v=0ViMkBxYsnk %}

継続に興味持った方も持ってない方も絶対これ見たほうが良いです｡
2日目のSML#の話を､大堀先生と上野先生の2連続で聞けたのも大変すばらしかった｡

# おわりに
わりと満足｡

このブログの読者ですという人々がたまに弊社ブースなどでお声がけしてくださったりして大変うれしかったです｡
令和の日本において信仰の自由は保証されているので､弊ブログのファンというのはもっと声を大にしていただいて大丈夫です｡多分迫害されません｡

https://x.com/Nymphium/status/1933706679985811725

元同僚の方に｢江の島のチューリングと呼ばれている｣まで詠唱されてウケました｡

{% twicard "" https://nymphium.github.io/2023/02/20/migrate_enoshima.html %}

[^1]: [Rust世界の二つのモナド──Rust でも do 式をしてプログラムを直感的に記述する件について by konn](https://fortee.jp/2025fp-matsuri/proposal/a8cd6d02-37c5-4009-90a4-9495c3189420)
[^2]: [ラムダ計算と抽象機械と非同期ランタイム by Kory](https://fortee.jp/2025fp-matsuri/proposal/3bdbadb9-7d77-4de0-aa37-5a7a38c577c3)
[^3]: 前回もそう誓ったはずだが…｡
[^4]: 制御演算子を持つ言語を､CPSを使わずに実装すると感覚が得られる: <https://github.com/Nymphium/lambdaeff/blob/master/text/main.pdf>
[^5]: <https://esumii.github.io/min-caml/tutorial-mincaml-9.eng.htm>
[^6]: 多分AspectJのJの部分｡ 思っているのはこちらの方: <https://www.microsoft.com/en-us/research/wp-content/uploads/2016/11/join-points-pldi17.pdf>
[^7]: 正しくはOCamlではなくてOchaCamlというvariant｡Answer-Type Modificationも導入されており型を含めた限定継続の雰囲気を掴むのに大変よい｡
[^8]: <https://github.com/ghc-proposals/ghc-proposals/blob/master/proposals/0313-delimited-continuation-primops.rst>
[^9]: 継続の中で再度限定継続を取り出すとき､delimiterの指定が自動で入るのがshift/reset等､入らないのがshift0/reset0など0系｡rehandleの自由度が高い(≒表現力が高い)のが後者ということ｡
[^10]: <https://github.com/ocsigen/js_of_ocaml/blob/master/manual/effects.wiki>
[^11]: <https://v8.dev/blog/jspi>
