# 新しい150本のためのリサーチ（2026年9月）

いまの80本（1〜80）に加えて、81〜230の150本を作ります。
**Roblox で実際に流行っている・人気のあるゲーム**を150本選び、それぞれを Ablox で遊べるオリジナル版にします。
いまの80本がもとにしたゲーム（Blox Fruits、Grow a Garden、Steal a Brainrot、Doors、Tower of Hell、Brookhaven、99 Nights in the Forest など）とは**かぶらないもの**だけを選びました。

- 下の（ ）は、遊び方の型を参考にした本物の Roblox ゲームです（このリサーチの中でだけ名前を書いています）。
- ゲームの中では、本物のゲームの名前・キャラクター・ロゴ・音楽は使いません。ゲームの名前もオリジナルです。
- 乗り物の見た目は、いまのアプリにあるもの（カート・車・スポーツカー・トラック・バイク・スクーター・ジェットパック・ホバーボード）だけで作ります。
  新しい見た目を足すと、まだ更新していない iPad でゲームが動かなくなるためです（ホバーボードは水に浮くので、ボートやサーフボードにもなります）。

## わかったこと

- 2026年9月の同時プレイ人数の上位は、Steal An Egg・Ride A Pet・Brookhaven・Blox Fruits・Slayers 2・Murder Mystery 2・Steal a Brainrot・Adopt Me!・99 Nights in the Forest・Fish It!・RIVALS。
- ロールプレイ（街でくらす）と、アニメ風の対戦が上位の半分以上。次にシミュレーター（集める→強くなる→生まれ変わる）とタイクーン。
- 2025年に大きくのびたのは、盗んで守るタイクーン、庭の放置ゲーム、協力ホラー（99 Nights、Forsaken）、タイミングで勝つ対戦（Blade Ball、Volleyball Legends）、サッカー（Blue Lock: Rivals）。
- ずっと人気の定番は、ストーリーのオビー（Barry's Prison Run）、難しさチャートのオビー、きたえるシミュレーター（Muscle Legends など）、Slap Battles、Doomspire、お仕事ゲーム。

参考にしたページ:
- rblxdb「Best Roblox Games (September 2026) — Ranked by Live Players」 https://rblxdb.com/best-roblox-games
- Wikipedia「List of Roblox games」 https://en.wikipedia.org/wiki/List_of_Roblox_games
- EJAW「Roblox Charts 2026: Top 10 Most-Played Games」 https://ejaw.net/roblox-charts/
- creation.dev「Best Roblox Games to Play in 2026」 https://www.creation.dev/blog/best-roblox-games-2026
- Bloxport「Best Roblox Obby Games (2026)」 https://bloxport.net/roblox-obby-games
- Bloxport「Best Roblox Tycoon Games (2026)」 https://bloxport.net/roblox-tycoon-games
- Roblox「The 2025 Roblox Replay」 https://about.roblox.com/newsroom/2025/12/roblox-replay-decoded-search-style
- Roblox のチャート https://www.roblox.com/charts

## 共通のエンジン（lib/）

150本を同じ質で作るため、よく出てくる「型」を先に共通のスクリプトにします。各ゲームはこれを読み込んで、自分のルールと地図を足します。
ファイル名はすべて `kit_` で始まります（ゲームのファイルと名前がぶつからないように）。

| ファイル | 中身 |
|---|---|
| `lib/kit_rounds.absc` | ラウンドの進みかた（待つ → カウントダウン → 遊ぶ → 結果 → くり返し） |
| `lib/kit_obby.absc` | オビーのステージ・チェックポイント・落ちたら戻る・スキップ・タイム |
| `lib/kit_race.absc` | チェックポイント・周回・順位・タイム・ベスト記録（地面でも空中の輪でも） |
| `lib/kit_ride.absc` | 乗り物の見た目と速さ、ブースト、空を飛ぶ・水に浮く動き |
| `lib/kit_sim.absc` | きたえる → 売る → 生まれ変わる（リバース）、たまごとペット |
| `lib/kit_tycoon.absc` | 区画をもらって、買うほど建物が増えて、収入が入る |
| `lib/kit_ball.absc` | ボール（ける・投げる・打つ、はね返り、ゴールの判定） |
| `lib/kit_waves.absc` | 敵の波・道・拠点（防衛戦・ゾンビ） |
| `lib/kit_quiz.absc` | クイズ・ことば（問題・4択・時間・点数） |

## 150本

番号 ゲーム名 日本語の説明（参考にした Roblox のゲーム）

### 🧗 オビー・アスレチック（81〜95）
- 81 Cell Block Run 脱獄ラン（Barry's Prison Run）
- 82 Color Chart Obby 難しさチャート（Difficulty Chart Obby）
- 83 Pedal Obby 自転車オビー（Obby But You're on a Bike）
- 84 Rising Flood Escape 洪水からにげろ（Flood Escape 2）
- 85 Trap Master Run ワナ師とランナー（Deathrun）
- 86 Speeding Wall Survival せまるかべ（Be Crushed by a Speeding Wall）
- 87 Easy Peasy Obby やさしいオビー（The Really Easy Obby）
- 88 Cart Ride Wonderland カートライド（Cart Ride Around Nothing）
- 89 Grapple Ascent グラップルで登れ（Ascend: Grapple Challenge）
- 90 Rooftop Parkour 屋上パルクール（Parkour Reborn）
- 91 Swing Rope Obby ロープでスイング（Swing Obby for Brainrots!）
- 92 Shrink & Grow Obby 小さく大きく（Shrink For Brainrots）
- 93 Chased by Stuff Obby なにかに追われる（Be chased by random stuff in an obby）
- 94 Rising Lava Rescue のぼるマグマ（Survive LAVA for Brainrots!）
- 95 Fishy Obby 魚になってオビー（obby but you're a fish）

### 🏎️ 乗り物・ドライブ（96〜110）
- 96 Drag Strip Kings ドラッグレース（Drag Drive Simulator）
- 97 Midnight Highway Battle 真夜中の高速バトル（Midnight Racing: Tokyo）
- 98 Dream Car Dealership 車の販売店（Car Dealership Tycoon）
- 99 Green Valley Drive 町ドライブRP（Greenville）
- 100 Dusty Road Trip 砂漠の旅（A Dusty Trip）
- 101 Build a Plane & Fly 飛行機を作って飛ばせ（Build a Plane）
- 102 Island Flight School 島の空港パイロット（Pilot Training Flight Simulator）
- 103 County Line Railway 電車の運転士（Stepford County Railway）
- 104 Ice Cream Van アイスクリームカー（Ice Cream Van Simulator）
- 105 Cabin Crew Service 客室乗務員（Cabin Crew Simulator）
- 106 Lawn Mower Kings しばかり（Lawn Mowing Simulator）
- 107 Grapple Cart Duo ふたりでグラップルカート（Grapple Cart Obby）
- 108 Blast Off Rockets ロケット発射（Blast Off Simulator）
- 109 Taxi Town タクシーの町（Taxi Boss）
- 110 Snow Plow Crew 除雪車（Snow Plow Simulator）

### 💪 シミュレーター（111〜125）
- 111 Bubble Gum Legends バブルガム（Bubble Gum Simulator INFINITY）
- 112 Mega Muscle Legends マッスル（Muscle Legends）
- 113 Shadow Ninja Legends ニンジャ（Ninja Legends）
- 114 Speed Legends City スピード（Legends of Speed）
- 115 Tap Race Clicker タップでレース（Race Clicker）
- 116 Arm Wrestle Champions うでずもう（Arm Wrestle Simulator）
- 117 Deep Mine Simulator 採掘（Mining Simulator 2）
- 118 Sand Treasure Hunt 砂の宝さがし（Treasure Hunt Simulator）
- 119 Mega Magnet Sim マグネット（Magnet Simulator）
- 120 Saber Swing Sim セイバー（Saber Simulator）
- 121 Snowball Shovel Sim 雪玉ころがし（Snow Shoveling Simulator）
- 122 Gym League Stars ジムリーグ（Gym League）
- 123 Dig It Deep 宝ほり（Dig）
- 124 Ghost Vacuum Sim おばけすいこみ（Ghost Simulator）
- 125 Dice Heroes ダイスヒーローズ（Anime Dice）

### 🏗️ タイクーン（126〜140）
- 126 Lumber Valley Tycoon きこり（Lumber Tycoon 2）
- 127 Corner Store Tycoon お店（Retail Tycoon 2）
- 128 Ore Factory Haven 鉱石工場（Miner's Haven）
- 129 Oil Baron Empire 石油王（Oil Empire）
- 130 Build Your Island 島づくり（Build An Island!）
- 131 Cruise Ship Tycoon 豪華客船（Cruise Line Tycoon）
- 132 Build a Zoo Park どうぶつえん（Build A Zoo / My ZOO）
- 133 Sword Forge Factory 剣の工場（Sword Factory）
- 134 Fish Farm Tycoon 魚の養殖場（Farm a Fish）
- 135 Egg Heist たまごどろぼう（Steal An Egg）
- 136 Duo Millionaire Tycoon ふたりでミリオネア（2 Player Millionaire Tycoon）
- 137 Streamer Studio Tycoon 配信スタジオ（Youtuber Tycoon）
- 138 Smoothie Factory スムージー工場（Smoothie Factory Tycoon）
- 139 Sky Airport Tycoon 空港（Airport Tycoon）
- 140 Element Powers Tycoon 属性パワー（Elemental Powers Tycoon）

### 👻 ホラー・ストーリー（141〜155）
- 141 Abandoned Survivors 見すてられた生存者（Forsaken）
- 142 Escape the Lab Beast 研究所の怪物（Flee the Facility）
- 143 Break-In Night 家族の長い夜（Break In）
- 144 Pale Creature Woods 森の白い怪物（The Rake）
- 145 Deep Pressure Station 深海の基地（Pressure）
- 146 Hush Corridors 静かな廊下（Grace）
- 147 Ghost Hunters Club ゆうれい調査隊（Specter / Blair）
- 148 Camping Trip Story キャンプのお話（Camping）
- 149 Field Trip Zombies 遠足ゾンビ（Field Trip Z）
- 150 Cheese Maze Escape チーズの迷路（Cheese Escape）
- 151 Toon Floors トゥーンの地下（Dandy's World）
- 152 Spooky Sushi Shop こわいお寿司屋さん（Scary Sushi）
- 153 Need More Warmth もっとあったかく（Need More Heat）
- 154 Mystery Isle なぞの島（Isle）
- 155 Area 51 Escape エリア51（Survive Area 51）

### ⚔️ バトル・シューター（156〜170）
- 156 Slap Arena ビンタバトル（Slap Battles）
- 157 Frontline Forces 最前線（Phantom Forces）
- 158 Paintball Splat ペイントボール（BIG Paintball 2）
- 159 Bomb Defuse 5v5 爆弾解除（Counter Blox）
- 160 Hyper Blast Arena ハイパーショット（Hypershot）
- 161 Brick Tower Battle レンガの塔の戦い（Doomspire Brickbattle）
- 162 Spirit Guardian Battle 守護霊バトル（Your Bizarre Adventure）
- 163 Time Bomb Duels 時限爆弾デュエル（Timebomb Duels）
- 164 Sword Heights 高台のけんとう（Sword Fights on the Heights）
- 165 Ability Wars Arena アビリティ・ウォーズ（Ability Wars）
- 166 Sniper Duels スナイパー・デュエル（Sniper Duels）
- 167 Laser Assault レーザー・アサルト（Energy Assault）
- 168 Zombie Attack Squad ゾンビアタック（Zombie Attack）
- 169 Tower Battles Duel 対戦タワーディフェンス（Tower Battles）
- 170 Base Battles 基地バトル（Base Battles）

### ⚽ スポーツ（171〜185）
- 171 Striker Rivals サッカー（Blue Lock: Rivals）
- 172 Volleyball Legends バレーボール（Volleyball Legends）
- 173 Hoops Zero バスケットボール（Basketball: Zero）
- 174 Gridiron Football アメフト（Ultimate Football）
- 175 Dodgeball Clash ドッジボール（Dodgeball!）
- 176 Tug of War Sim つなひき（Tug of War Simulator）
- 177 Sumo Push Sim すもう（Sumo Simulator）
- 178 Table Tennis Pro 卓球（Table Tennis）
- 179 Home Run Derby ホームラン競争（Home Run Simulator）
- 180 Dunk Simulator ダンク（Dunking Simulator）
- 181 Tennis Rivals テニス（Racket Rivals）
- 182 Strike Bowling ボウリング（Bowling）
- 183 Ice Hockey League アイスホッケー（Hockey）
- 184 Track & Field Day 陸上競技会（Track and Field: Infinite）
- 185 Shred Snowboard スノーボード（Shred）

### 🏡 ロールプレイ・くらし（186〜200）
- 186 Daycare Friends RP ほいくえん（Twilight Daycare）
- 187 Wild Horse Island 野生の馬の島（Wild Horse Islands）
- 188 Creature Kingdom いきもの王国（Creatures of Sonaria）
- 189 Dragon Keepers ドラゴンを育てる（Dragon Adventures）
- 190 Bird Family 鳥の家族（Feather Family）
- 191 Art Stall Plaza 絵を売る広場（Starving Artists）
- 192 Burger Kitchen Chaos バーガーをやこう（Cook Burgers）
- 193 Supermarket Shift スーパーのおしごと（Supermarket Simulator）
- 194 Storage Auction Hunters 倉庫オークション（Storage Hunters）
- 195 Find the Stickers ステッカーをさがせ（Find the Markers）
- 196 Quiet Lake Diving 湖のダイビング（Scuba Diving at Quill Lake）
- 197 Farm Friends なかよし農場（Farming and Friends）
- 198 Rate My Look コーデ採点（Rate My Avatar）
- 199 Dino Life きょうりゅう（Dinosaur Simulator）
- 200 Spray Paint Walls スプレーアート（Spray Paint!）

### 🎉 パーティー・ミニゲーム（201〜215）
- 201 Floor Is Lava ゆかはマグマ（The Floor is LAVA!）
- 202 Tag Game Arena 鬼ごっこ（Untitled Tag Game）
- 203 Speed Draw Party スピードおえかき（Speed Draw!）
- 204 Word Bomb ことばボム（Word Bomb）
- 205 Bomb Rain Survival ばくだんの雨（Super Bomb Survival）
- 206 Musical Chairs いすとり（Musical Chairs）
- 207 Color Block Party カラーブロック（Block Party / Color Block）
- 208 Fling Everything なげとばせ（Fling Things and People）
- 209 Simon Says サイモンのいうとおり（Simon Says）
- 210 Hole in the Wall かべぬけ（Hole in the Wall）
- 211 Freeze Tag こおりおに（Freeze Tag）
- 212 Marble Race Bets ビー玉レース（Marble Race）
- 213 King of the Hill 山の王さま（King of the Hill）
- 214 Trivia Town クイズタウン（Trivia Town）
- 215 Spelling Bee スペリング・ビー（Spelling Bee!）

### 🗡️ 冒険・サバイバル・防衛（216〜230）
- 216 Sky Islands Life 空の島ぐらし（Islands）
- 217 Tribe Survival げんしじんサバイバル（Booga Booga）
- 218 +1 Loot Forge ＋1きょうか（+1 Loot To Forge）
- 219 Ore & Anvil 鉱石と鍛冶屋（The Forge）
- 220 Sword Floors 剣の塔（Swordburst 2）
- 221 Shinobi Bloodlines 忍びの血すじ（Shindo Life）
- 222 Arcane Seas 魔法の海（Arcane Odyssey）
- 223 Rune Hunters ルーンのかりうど（Rune Slayer）
- 224 Gate Hunters ゲートのハンター（Hunters）
- 225 Deep Depths 深みへ（Deepwoken）
- 226 Apocalypse Survivors 世界の終わりを生きのびろ（Survive the Apocalypse）
- 227 Build & Blast Zombies 作ってたおせゾンビ（Build and Kill Zombies）
- 228 Plants vs Memes おにわ vs ミーム（Plants vs Brainrots）
- 229 Garden Defense ガーデン・ディフェンス（Garden Tower Defense）
- 230 War Base Tycoon 戦車基地タイクーン（War Tycoon）
