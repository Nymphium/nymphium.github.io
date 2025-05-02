---
layout: post
title: キーボードアルティメイタム 第2話 Corne V4 Chocolate
tags: [自作キーボード,qmk_firmware]
---

こんにちは､びしょ〜じょです｡

最近『教皇選挙』を観ました｡
お前は観たか? 観たほうがいいぞ｡

内容○､画○､音響○なんで､キリスト教世界観分かるパーソンだったら更に面白く観られる気がします｡

<!--sectionize on-->

# はじめに 材料調達部門

頭がおかしくなってキーボードを買った｡

{% twicard "Corne V4 Chocolate | 遊舎工房" https://shop.yushakobo.jp/products/8962 %}

- ファームウェアはqmk
- いわゆる40%分割型
  - 数字キーが無い
- ビカビカ光る
- ホットスワップ
  - ソケットはすでに着いてるのでキースイッチ(別売)を刺すだけ

というのが特徴｡
数字キーいらねえんじゃねえのとなって､こうなった｡
ErgoDox EZからの乗り換えになる｡

<center>
[label:size]
<img src="/pictures/{{ page.id }}/comparing-size.jpg" alt="サイズ比較" width="80%">
図[ref:size]. サイズ比較｡手前がCorne､上の黒いのがErgoDox EZで白いのがMoonlander
</center>

キースイッチはKailhのChoc v2 Deep Sea Silent Isletという結構新しいやつを買った｡

{% twicard "" https://keeb-on.com/products/kailh-choc-v2-deep-sea-silent %}

HHKBみたいな､少しザラっとしてるけど滑らかな静音リニアで気持ちがいい｡
流通が少なそうなのがネック｡

親指で押すキーは軽くしたいのでChoc v1のピンク軸にした｡
v1とv2はソケット互換があるのでどちらも使える｡一方キャップに互換はない｡

{% twicard "" https://shop.yushakobo.jp/products/pg1350?variant=44079245754599 %}

めちゃ軽く手への負担は少ないが､Isletが静音すぎて相対的にカチャカチャ音が気になるのが玉に瑕｡

# qmk_firmware 小テク集

xmodmapでキーマップを変更していた10年以上前から入力の歴史は続いており(中略)(攻略)｡
[ErgoDox EZのキーマップ](https://github.com/Nymphium/qmk_firmware/blob/811c21b4822b8fddf76aa04578e84e259b8d9b1a/keyboards/ergodox_ez/keymaps/nymphium/keymap.c)をベースにした｡

{% twicard "" https://github.com/Nymphium/qmk_firmware/blob/bdee63cabddf0aefa192d44ff0f894eaf7e07f8f/keyboards/crkbd/keymaps/nymphium/keymap.c %}

キーボードがだいぶ小さくなったんで､マウス操作レイヤーと数字操作レイヤーを追加する｡
shift+数字も変更したいので､それ用のレイヤーも追加する｡

## tri layer

`LOWER`レイヤーでの入力にshift modifierを適用したい場合､ナイーブにシフトキーだけ押すとうまくいかない｡
うまくいかないんで､ `layer_state_set_user`関数内で`update_tri_layer_state`を使って複数レイヤーをまたぐ場合のルールを登録する｡

{% twicard "" https://docs.qmk.fm/features/tri_layer#tri-layers %}

```c : [label:layer_state]keymap.c
layer_state_t layer_state_set_user(layer_state_t state) {
    state = update_tri_layer_state(state, _LOWER, _SHIFT, _LSHIFT);
    state = update_tri_layer_state(state, _NUM, _LOWER, _NMODS);
    return state;
}
```

<center>
図[ref:layer_state]. `update_tri_layer_state` の使い所さん
</center>

Shiftキーを押したときに`_SHIFT`レイヤーに移行すればよい｡
このとき`_SHIFT`は何も登録してないレイヤーでよい｡

これで､

- `_LOWER`かつ`_SHIFT`のとき､`_LSHIFT`レイヤーに移行
- `_NUM`かつ`_LOWER`のとき､`_NMODS`レイヤーに移行

する｡
ちなむとcomboもうまくいかない｡switching layer系の組み合わせもうまくいかない｡
皆さんも諦めるか､smarterな解法があったら教えて下さい｡

## key override

QMKを触っていると人々はレイヤーがサァ! とか色気づくんだけど､modifier key+key→別のキーに変換というナイーブな機能がある｡

{% twicard "" https://docs.qmk.fm/features/key_overrides %}


```c :[label:key_overrid] keymap.c
const key_override_t *key_overrides[] = {
    &ko_make_basic(MOD_MASK_SHIFT, KC_0, JP_QUES),
};
```

<center>
図[ref:key_overrid]. key overrideでShift+0→`?`を出す
</center>

Shift+0で`?`が出てくるようになる｡
ちなみに俺は普通のキーボードでShift+0すると何が入力されるのかもう覚えてない｡

## マウス中クリック/ホイール

マウスホイールの中クリックを皆さん使っているか?
ブラウザのリンクを中クリックすると新しいタブで開いたり､タブを中クリックするとcloseしたりする優れモノです｡

qmk_firmwareはマウスエミュレーションができる｡

{% twicard "" https://docs.qmk.fm/features/mouse_keys %}

QMKと中クリックは人生のテーマだったんですが､


```c :[label:struggle_middle]process_record_user.switch in keymap.c
case MIDDLE:
    if (record->event.pressed) {
        register_code(KC_BTN3);

        WAIT_PRESSING(record);

        unregister_code(KC_BTN3);
        layer_on(_WHEEL);
    } else {
        layer_off(_WHEEL);
    }
    return false;
```

<center>
図[ref:struggle_middle]. 中クリック/ホイールの実装(incorrect)
</center>

プログラム[ref:struggle_middle]だと先中クリックが入力されるため､ホイール操作だけしたいのに変にリンクを開いたりしてしまい､Webサイトのスクロールできるtable of contentsでスクロールするつもりがうっかり別タブを開いてしまう事故が多々おきた｡

鬼の努力は実はたった1行で解決できる｡

```c :[label:lt_middle]keymap.c
#define MIDDLE LT(_WHEEL, KC_BTN3)
```

<center>
図[ref:lt_middle]. 中クリック/ホイールの実装(correct)
</center>

これをkeymapで呼ぶだけ｡

{% twicard "" https://docs.qmk.fm/feature_layers#switching-and-toggling-layers %}

ドキュメントはちゃんと隅々まで嫁ってことですな…w

## レイヤー数増やす

```c :[label:layer_count]config.h
#undef DYNAMIC_KEYMAP_LAYER_COUNT
#define DYNAMIC_KEYMAP_LAYER_COUNT 9
```

<center>
図[ref:layer_count]. レイヤー数を増やす
</center>

はいこれです｡
これを書かずに7以上のレイヤーを定義するとコンパイラが｢`DYNAMIC_KEYMAP_LAYER_COUNT` は6や!!｣と怒ってくるので､察せられます｡

# マウスtips
多分世の中には多くのqmkマウスエミュレーション愛好家がいると思うんですが､私もその一人でしてェ…｡

{% twicard "" https://docs.qmk.fm/features/mouse_keys %}

一旦こうなっている｡

```c :[label:config_mouse]config.h
#define MK_KINETIC_SPEED

#undef MOUSEKEY_DELAY
#define MOUSEKEY_DELAY 0
#undef MOUSEKEY_INITIAL_SPEED
#define MOUSEKEY_INITIAL_SPEED 80
#undef MOUSEKEY_MOVE_DELTA
#define MOUSEKEY_MOVE_DELTA 8
#undef MOUSEKEY_BASE_SPEED
#define MOUSEKEY_BASE_SPEED 2200

#undef MOUSEKEY_WHEEL_DELAY
#define MOUSEKEY_WHEEL_DELAY 3
#define MOUSEKEY_WHEEL_INTERVAL 40
#define MOUSEKEY_WHEEL_MAX_SPEED 12
#define MOUSEKEY_WHEEL_TIME_TO_MAX 16
```

<center>
図[ref:config_mouse]. マウスのパラメータ〜
</center>

Kineticモードはカーソルの速度がquadratic curveで加速するため､最大速度から逆算すると初動からしばらく小さく動けるので､繊細に動かせるし遠くに動かしたいときも困らない｡
`MOVE_DELTA`で加速度合いを変更し､`BASE_SPEED` まで (`BASE_SPEED - INITIAL_SPEED) / MOVE_DELTA` millisecかけて加速していく｡

結局この辺は好みなんで快適な数値を探してください(爆)

# おわりに
いかがでしたか?

ちなみに第1話はない｡

# おまけ
ありすぎだろ

https://x.com/Nymphium/status/1917971194021842950

TEXシリーズはYodaからぼちぼち買ってるので愛着がある｡
奥にあるLogiのG515もG HBUという専用のソフトウェアでレイヤー機能や様々なカスタマイズができるんで使い勝手がよい｡

なんとなくほしいな〜とかゲームしたいな〜となると､増えてしまうわけですね｡
