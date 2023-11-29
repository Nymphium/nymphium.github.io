---
layout: post
title: qmk_firmwareで日本語配列 / マウスエミュレーションを頑張る
tags: [ErgoDox, QMK]
---

# 1. はじめに
qmk_firmware(以降qmkと省略)といえば最近の自作キーボードにおけるファームウェアの主流ですね｡
ちょっとしたことなら簡単にできますが､少し踏み込んだことをやろうとするとテクが必要となる印象です｡

今回は､筆者がErgoDox EZでおこなった設定を例に挙げ､いくつか踏み込んだ設定についてみていきます｡

ちなみに軸はKailh Goldにしました｡
丁度いいカチカチとしたクリック感が良いです｡

筆者の設定は､以下のURLから参照できます｡
https://github.com/Nymphium/qmk_firmware/tree/nymphium/keyboards/ergodox_ez/keymaps/nymphium

# 2. 日本語配列
ErgoDox EZでも日本語配列にしたくなります｡
今回は､Shift+数字を日本語配列にすることを考えます｡

<center>
表. 対応
</center>

|`Shift`+ | 英語配列 | 日本語配列 |
|:--:   | :---: | :--: |
| `2` | `@` | `"` |
| `6` | `^` | `&` |
| `7` | `&` | `'` |
| `8` | `*` | `(` |
| `9` | `(` | `)` |
| `0` | `)` | (none) |


# 実装
やることはズバリ､日本語配列の記号を入力するレイヤを作り､`process_record_user`関数でshiftキーの挙動を変えます｡

まずは記号を出す用のレイヤ`_SHIFT`を定義します｡
レイアウトはお手元のキーボードに適宜読み替えてください｡

```c:keycode.c
#define _SHIFT 3
/* ↑レイヤは`keymaps`という配列に格納されており､
 * インデックスは慣例的にレイヤ名(適当に考える)をマクロとして参照する
*/

// ......

,[_SHIFT] = LAYOUT_ergodox(
  // left hand
  _______, _______, KC_DQT,  _______, _______, _______, _______,
  _______, _______, _______, _______, _______, _______, _______,
  _______, _______, _______, _______, _______, _______,
  _______, _______, _______, _______, _______, _______, _______,
  _______, _______, _______, _______, _______,

                                               _______, _______,
                                                        _______,
                                      _______, _______, _______,

  // right hand
  // Shift+0はnopにしてもしなくてもよい
  KC_AMPR, KC_QUOT, KC_LPRN, KC_RPRN, _______, _______, _______,
  _______, _______, _______, _______, _______, _______, _______,
  _______, _______, _______, _______, _______, _______,
  _______, _______, _______, _______, _______, _______, _______,
  _______, _______, _______, _______, _______,

  _______, _______,
  _______,
  _______, _______, _______
)
```

続いて`process_record_user`関数でShiftキーの挙動を変えます｡
具体的には押下中に`_SHIFT`レイヤに切り替えることをやります｡

```c:NGその1
bool process_record_user(uint16_t keycode, keyrecord_t *record) {
  switch (keycode) { // ------------- キーコードで何を押下したかをスイッチ
    case KC_LSFT: // ---------------- 左シフト
      if (record->event.pressed) { // 押下中
        register_code(KC_LSFT); // -- 左シフトを入力
        layer_on(_SHIFT); // -------- レイヤーのスイッチ
      } else { // ------------------- 離した
        layer_off(_SHIFT); // ------- レイヤー戻る
        unregister_code(KC_LSFT); // 入力解除
      }

      return false; // -------------- 長押しで連続して入力しない
  }

  return true; // ------------------- デフォルト
}
```

`_SHIFT`レイヤに切り替えて､同時に`KC_LSFT`も入力しています｡
これによって､`_______`( `KC_TRANS` のalias)部分を同時に押下すると､前のレイヤのキーをShiftで修飾して入力とします｡

一瞬良い感じに見えますが…??
これで`Shift + 7`を押下するとおそらく **ダブルクオート** が入力されるはずです｡
なんでや念という感じですか､あるいは既に気づいてる方も居るかもしれません｡
上記の`process_record_user`による切り替えで､`_SHIFT`レイヤに切り替え､さらに`KC_LSFT`も入力しているのが問題です｡
`KC_LSFT`を入力しないと前のレイヤのキーはShift修飾できません｡

アドホックですが､解法を示しますと､`KC_QUOT`のようなキーを`_SHIFT`レイヤで入力し､かつShiftを入力したくない場合は､`KC_LSFT`の入力を解除してからキーを入力し､そのキーを入力解除してから`KC_LSFT`を再入力する､ということをします｡

`KC_QUOT`を入力することを例に挙げると､次のような流れになります｡

1. ユーザ: Shiftキーを押下
2. qmk   : `_SHIFT`にレイヤ切り替え+`KC_LSFT`入力
3. ユーザ: 7キーを押下
4. qmk   : `KC_LSFT`の入力解除
5. qmk   : `KC_QUOT`を入力
6. qmk   : `KC_QUOT`を入力解除
7. qmk   : `KC_LSFT `を入力

なるほどですね｡
あとはやるだけ

```c:NGその2
static bool shift; // Shiftキーを離してない場合のフラグ

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
  switch (keycode) {
    case KC_LSFT:
      if (record->event.pressed) {
        register_code(KC_LSFT);
        layer_on(_SHIFT);
        shift = true;
      } else {
        shift = false;
        layer_off(_SHIFT);
        unregister_code(KC_LSFT);
      }

      return false;

    case KC_QUOT: // 制御するのは7じゃなくて入力したい`KC_QUOT`
      if (record->event.pressed) {
        unregister_code(KC_LSFT);
        register_code(keycode);
      } else {
        if (shift) register_code(KC_LSFT);
        unregister_code(keycode);
      }
      return true; // 長押しで入力をリピートしたいので`true`

  // ......
```

Shiftを押下し､`7`を押下し､`7`を離すがShiftは離さない場合の制御のために`shift`というフラグを追加しました｡
これでいいかというとそうではなく､`Ctrl+Shift+7`みたいなキーマップをアプリケーションで使うかもしれませんが､そういうときに`KC_LSFT`を入力してないため無効となってしまいます｡
はい解法は以下の実装になります｡

```c:OK
static bool shift;
static bool modkey = false; // 修飾キーを押下中のフラグ

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
  switch (keycode) {
    case KC_LGUI: // Winキー
    case KC_LALT: // 左Alt
    case KC_LCTRL: // 左Ctrl
      if (record->event.pressed) {
        register_code(keycode);
        modkey = true;
      } else {
        unregister_code(keycode);
        modkey = false;
      }
      return false;

    case KC_LSFT:
      if (record->event.pressed) {
        register_code(KC_LSFT);

        if (!modkey) { // 修飾キー押下時はレイヤーを切り替えない
          shift = true;
          layer_on(_SHIFT);
        }
      } else {
        if (shift) {
          shift = false;
          layer_off(_SHIFT);
        }
        unregister_code(KC_LSFT);
      }

      return false;

    case KC_QUOT:
      if (record->event.pressed) {
        unregister_code(KC_LSFT);
        register_code(keycode);
      } else {
        if (shift) register_code(KC_LSFT);
        unregister_code(keycode);
      }

      return true;

  // ......
```

コレで完了です｡

# 3. マウスのエミュレーション
なんとqmkではマウスのエミュレーションができます｡
これまではThinkPadキーボードを使っていた筆者もそれなりに満足してます[^2]｡

さて､さっそく悲報ですが､qmkは何秒キーを押下したかのような情報は取得できません｡
したがって､ThinkPadのように､中クリック直後の寸瞬のうちにカーソルを上下左右に動かすとホイールアクションになる､ということはできません｡
今回は､中クリックに若干秒でホイールアクションに切り替わる､という方法でいきます｡
あまり違いがわからないかもしれませんが､今回実装する後者では中クリック押下即離しても一瞬ホイールアクションに切り替わります｡

## 実装
マウスエミュレーションを有効にするには､まずruls.mkで`MOUSEKEY_ENABLE = yes`にします｡
ErgoDox EZはデフォルトで`yes`になってます｡

マウスエミュレーションは`_MOUSE`レイヤ､ホイールアクションを`_WHEEL`でおこないます｡
`MOUSE`キー押下中にマウスエミュレーションをおこなう(`_MOUSE`レイヤに切り替え)ようにし､`MIDDLE`キー押下時に中クリック/ホイール(`_WHEEL`レイヤに切り替え)にします｡

ユーザ定義キーは`custom_keycodes`で表現します｡

```c:keycode.c
#define _BASE 0
// ......
#define _MOUSE 4
#define _WHEEL 5

// MODEキーで_MODEレイヤをonにするマクロ
#define TMP_MODE(MODE) \
    case MODE: \
      if (record->event.pressed) { \
        layer_on(_##MODE); \
      } else { \
        layer_off(_##MODE); \
      } \
      return false; \

enum custom_keycodes {
  BASE = SAFE_RANGE,
  MOUSE,
  MIDDLE,
};

// ......

[_BASE] = LAYOUT_ergodox(
  // ......
  MOUSE, // お好きなキーで切り替えてください
  // ......
)

// ......

,[_MOUSE] = LAYOUT_ergodox(
  // left hand
  ___,    ___,   ___,  ___,  ___,  ___,  ___,
  ___,    ___,   ___,  ___,  ___,  ___,  ___,
  ___,    ___,   ___,  ___,  ___,  ___,
  ___,    ___,   ___,  ___,  ___,  ___,  ___,
  //               左       中      右
  ___,    ___,   KC_BTN1, MIDDLE, KC_BTN2,

                                    ___, ___,
                                         ___,
                               ___, ___, ___,

  // right hand
  ___, ___,  ___, ___, ___,  ___,  ___,
  ___, ___,  ___, ___, ___,  ___,  ___,
  //     ←         ↓      ↑        →
       KC_MS_L, KC_MS_D, KC_MS_U, KC_MS_R,  ___,  ___,
  ___, ___,  ___, ___, ___,  ___,  ___,
  ___, ___,  ___, ___, ___,

  ___, ___,
  ___,
  ___, ___, ___
)

// ......

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
  switch (keycode) {
    case MIDDLE:
      if (record->event.pressed) {
        register_code(KC_BTN3); // -- 中クリックを入力しておく

        // -------------------------- とりあえず200ミリ秒待つ
        while (timer_elapsed(record->event.time) <= 200) {}

        unregister_code(KC_BTN3); // `KC_BTN3`を解放
        layer_on(_WHEEL); // ------- _WHEELレイヤ切り替え
      } else {
        layer_off(_WHEEL); // ------ 戻す
      }

      return false;

    TMP_MODE(MOUSE); // ------------ 押下中だけMOUSEレイヤ

    // ......
```

実装だけになったのであまりおもしろくないですね｡
`while`で空のループを回してるのはすこしドキッとします｡
`timer_elapsed`関数で､押下されてからの秒数を取得してます｡

これなら先述の､ "qmkは何秒キーを押下したかのような情報" を取得していろいろできるような気が一瞬します｡
しかし残念ながらそうではなく､これは押下イベントのタイムスタンプが入ったレコードであり､何秒押下しているかではありません｡
また､`record->event.pressed`も動的に変わるわけではなく､押下/離したというイベントが降ってくるので､どちらかという情報が格納されているだけです｡

よもやま話が挟まりましたが､これで全てです｡
`MIDDLE`の処理を見ての通り､一瞬押下してすぐ離そうがなんだろうが`_WHEEL`レイヤに切り替わるような実装になってます｡

# 4. おわりに
Shift+数字キーを例に日本語配列について少し考え､ホイール操作を勘案したマウスエミュレーションについて思いを馳せてみました｡
qmkは簡単なことは簡単にできますが､少しでも踏み入ったことをしようとすると複雑になります｡
しかしフラグによる制御を加えたりするとそこそこなんとかなったり､ならなかったりすることが分かりました｡
デバッグも大変なので､状態遷移をオートマトンなどのモデルにコンパイルして検査されてほしいですね｡

[^2]: 筆者はThinkPadキーボードのトラックポイントならMinecraftくらいまでならやってましたが､流石にqmkのマウスエミュレーションではウェブブラウジングくらいまでしかできません｡逆にマウスでゲームしないのならマウスとして充分機能します｡

