# 効果音ライブラリ（sounds/）

Ablox の「効果音ライブラリ」と、スクリプトの `sound("名前")` が読む効果音です。
**6,056 個**、ぜんぶで **335 MB**。

> The sound library Ablox reads: 6,056 sound effects (335 MB), every one
> CC0 1.0 from [SFXMint](https://sfxmint.com). `index.json` lists each with its size and
> SHA-256; the app keeps a file only when both match.

## ライセンス

すべて [SFXMint](https://sfxmint.com) の音で、**CC0 1.0**（パブリックドメイン）です。
どのゲームでも自由に使えて、作った人の名前を書く必要もありません。
SFXMint のサイトにある元のファイルと、1バイトも変えていません（SHA-256 で確かめています）。

## 使い方

- Ablox: **設定 → 効果音ライブラリ** で聞く・名前をコピー・**すべてダウンロード**
- スクリプト: `sound("retro-game-coin-08")`、`p.sound("animal-cat-meow-02", {volume: 0.6})`
- Ablox Studio: ルールの「音を鳴らす」の ♪ ボタン、スクリプトの「効果音ライブラリ」ボタン

## カテゴリ

| カテゴリ | フォルダ | 数 | 大きさ |
|---|---|---|---|
| ボタン・画面（UI） | `sounds/ui/` | 538 | 14.4 MB |
| レトロゲーム（Retro game） | `sounds/retro-game/` | 325 | 9.1 MB |
| 切り替え・シュッ（Transitions） | `sounds/transition/` | 278 | 12.9 MB |
| ぶつかる・たたく（Impacts） | `sounds/impact/` | 381 | 11.0 MB |
| まわりの音（Ambience） | `sounds/ambience/` | 234 | 34.7 MB |
| 水（Water） | `sounds/water/` | 249 | 16.0 MB |
| 火・電気（Fire and electric） | `sounds/fire-electric/` | 265 | 22.6 MB |
| 足音（Footsteps） | `sounds/footsteps/` | 257 | 21.9 MB |
| ドア（Doors） | `sounds/door/` | 224 | 7.0 MB |
| 機械（Machines） | `sounds/mechanical/` | 377 | 25.6 MB |
| 紙・布（Paper and cloth） | `sounds/paper-fabric/` | 323 | 12.5 MB |
| ガラス（Glass） | `sounds/glass/` | 222 | 6.1 MB |
| 動物（Animals） | `sounds/animal/` | 295 | 13.2 MB |
| 人のざわめき（Crowds） | `sounds/crowd/` | 198 | 26.2 MB |
| アニメ・おもしろ（Cartoon） | `sounds/cartoon/` | 251 | 6.9 MB |
| 魔法・SF（Magic and sci-fi） | `sounds/magic-scifi/` | 278 | 15.5 MB |
| ホラー（Horror） | `sounds/horror/` | 262 | 33.5 MB |
| ゲームの合図（Game feedback） | `sounds/feedback/` | 351 | 9.8 MB |
| 楽器（Instruments） | `sounds/instrument/` | 271 | 13.8 MB |
| 事務所（Office） | `sounds/office/` | 339 | 15.9 MB |
| 人の声（People） | `sounds/human/` | 61 | 2.5 MB |
| 乗り物（Vehicles） | `sounds/vehicle/` | 27 | 1.3 MB |
| 家の音（Home） | `sounds/household/` | 50 | 2.1 MB |

## 作り方

```
python3 -I tools/sounds/harvest.py DATA sitemap.xml   # 一覧のページを読み、MP3 を1つずつダウンロード
python3 -I tools/sounds/walk.py DATA META             # 一覧のページにない テイクを たどって見つける
python3 -I tools/sounds/build_index.py DATA           # SHA-256 を確かめて sounds/ に置き、index.json を書く
```

どれも 1回に1つずつ、間をあけて SFXMint にたずねます（サイトに負担をかけないため）。
日本語の名前と検索語は `tools/sounds/ja_words.py` の単語表から作っています。
