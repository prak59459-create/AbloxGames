import Foundation

// 1–20: the headline games.

let topGames: [Game] = [
    Game(number: 1, id: "maple-bay-life", title: "Maple Bay Life RP",
         summary: "街でくらすロールプレイ。家に住んで、仕事を選んで、車やジェットパックで走り回ろう。勝ち負けなし、友だちとのんびり交流。",
         tags: ["rp", "town", "life", "top20"], maxPlayers: 16, build: mapleBay),
    Game(number: 2, id: "fruit-seas", title: "Fruit Seas Adventure",
         summary: "ふしぎな果実を食べて技を覚え、剣をきたえて島から島へ。山賊をたおしてレベルアップ、海の巨人ボスにみんなで挑もう。",
         tags: ["rpg", "action", "adventure", "top20"], maxPlayers: 12, build: fruitSeas),
    Game(number: 3, id: "pet-home-paradise", title: "Pet Home Paradise",
         summary: "たまごを買ってかえし、ペットを育てよう。お世話をするとコインがもらえてペットが大きくなる。レアなペットを集めて友だちにプレゼントも。",
         tags: ["pets", "collect", "cute", "top20"], maxPlayers: 12, build: petHome),
    Game(number: 4, id: "meme-heist", title: "Meme Heist",
         summary: "ランウェイを歩くヘンなミームキャラを買って自分の基地へ。キャラはお金を生み出す。ほかの人の基地からこっそり盗み出せ！",
         tags: ["simulator", "steal", "funny", "top20"], maxPlayers: 8, build: memeHeist),
    Game(number: 5, id: "reel-legends", title: "Reel Legends",
         summary: "つりのアドベンチャー。タイミングよくリールを引いて魚をつり上げ、売ってロッドを強化。池、海、深海、火山湖で伝説の魚を探そう。",
         tags: ["fishing", "simulator", "collect", "top20"], maxPlayers: 12, build: reelLegends),
    Game(number: 6, id: "clash-duels", title: "Clash Duels",
         summary: "1対1から5対5まで、短い試合で勝負するFPS。ラウンドごとに武器を選んで、先に5ラウンド取ったチームの勝ち。",
         tags: ["fps", "pvp", "teams", "top20"], maxPlayers: 10, build: clashDuels),
    Game(number: 7, id: "sprout-garden", title: "Sprout Garden",
         summary: "自分の畑にタネをまいて、育ったら収穫して売ろう。雨や虹のイベントで作物がパワーアップ。レアなタネで夢の庭園を。",
         tags: ["farming", "simulator", "chill", "top20"], maxPlayers: 8, build: sproutGarden),
    Game(number: 8, id: "runway-star", title: "Runway Star",
         summary: "テーマに合わせて服の色や帽子をコーディネートしてランウェイへ。みんなで星をつけ合って、トップモデルを決めよう。",
         tags: ["fashion", "vote", "party", "top20"], maxPlayers: 12, build: runwayStar),
    Game(number: 9, id: "mystery-manor", title: "Mystery Manor",
         summary: "市民・保安官・犯人に分かれる推理サバイバル。犯人は正体をかくして全員を、保安官は犯人を見つけてたおせ。市民は生きのこれ！",
         tags: ["mystery", "roles", "pvp", "top20"], maxPlayers: 12, build: mysteryManor),
    Game(number: 10, id: "99-nights-camp", title: "99 Nights Camp",
         summary: "森のキャンプで99日を生きのびるサバイバル。昼は木を切ってたき火を守り、夜はおそってくる怪物からみんなで身を守ろう。",
         tags: ["survival", "horror", "coop", "top20"], maxPlayers: 10, build: nightsCamp),
    Game(number: 11, id: "lucky-kick-run", title: "Lucky Kick Run",
         summary: "ラッキーブロックをけとばして何が出るかな？アイテムを手に入れたら、せまる大津波から高台へにげろ！",
         tags: ["luck", "survival", "action", "top20"], maxPlayers: 12, build: luckyKick),
    Game(number: 12, id: "battleground-legends", title: "Battleground Legends",
         summary: "パンチ、アッパー、衝撃波、そして必殺の覚醒！技を組み合わせてオープンフィールドで戦う爽快バトル。",
         tags: ["pvp", "fighting", "combo", "top20"], maxPlayers: 12, build: battleground),
    Game(number: 13, id: "hotel-100-doors", title: "Hotel 100 Doors",
         summary: "なぞのホテルの100の部屋を進むホラー。明かりがチカチカしたらクローゼットへ！紫の目は見ちゃダメ。カギを見つけて先へ。",
         tags: ["horror", "coop", "escape", "top20"], maxPlayers: 8, build: hotelDoors),
    Game(number: 14, id: "pet-coin-frenzy", title: "Pet Coin Frenzy",
         summary: "コインの山をタップしてこわし、たまごからペットを出してパワーアップ。新しいエリアを開いて、巨大ペットを引き当てろ！",
         tags: ["pets", "clicker", "collect", "top20"], maxPlayers: 12, build: petCoin),
    Game(number: 15, id: "tower-of-chaos", title: "Tower of Chaos",
         summary: "チェックポイントなしの超むずかしいタワー。毎回ランダムに組み上がる障害物を、時間内にてっぺんまで登りきれ！",
         tags: ["obby", "hard", "tower", "top20"], maxPlayers: 16, build: towerChaos),
    Game(number: 16, id: "crystal-wars", title: "Crystal Wars",
         summary: "浮島でチームに分かれて自分のクリスタルを守り、相手のクリスタルをこわせ。ブロックで橋をかけて、装備を強化して攻めこもう。",
         tags: ["pvp", "teams", "build", "top20"], maxPlayers: 12, build: crystalWars),
    Game(number: 17, id: "slime-roll", title: "Slime Roll",
         summary: "運だめしでスライムを引こう。レアなスライムほど強くて、勝手に戦ってコインをかせいでくれる。100万分の1を引けるか？",
         tags: ["rng", "idle", "collect", "top20"], maxPlayers: 12, build: slimeRoll),
    Game(number: 18, id: "hero-tower-defense", title: "Hero Tower Defense",
         summary: "道の横にヒーローを置いて、せまる敵の大群を止めろ。剣士、弓使い、魔法使い、氷使い。強化のタイミングが勝負のカギ。",
         tags: ["tower-defense", "coop", "strategy", "top20"], maxPlayers: 8, build: heroTD),
    Game(number: 19, id: "domain-clash", title: "Domain Clash",
         summary: "炎・雷・重力・影の術で戦うバトル。ゲージがたまったら「領域展開」で相手を閉じこめろ！地面や柱もこわれる。",
         tags: ["pvp", "fighting", "powers", "top20"], maxPlayers: 12, build: domainClash),
    Game(number: 20, id: "tsunami-dash", title: "Tsunami Dash",
         summary: "うしろからせまる巨大な津波！障害物をかわし、アイテムを拾いながらゴールまで走りぬけろ。ミームだらけのにぎやかコース。",
         tags: ["runner", "survival", "funny", "top20"], maxPlayers: 16, build: tsunamiDash),
]

// MARK: 1 Maple Bay Life RP

func mapleBay(_ m: MapBuilder) {
    m.day(ground: "#5DA34F")
    m.ground(180, 180, color: "#6DBB5A")
    m.road(from: (-90, 0), to: (90, 0), width: 8)
    m.road(from: (0, -90), to: (0, 90), width: 8)
    m.road(from: (-90, 45), to: (90, 45), width: 6, name: "North Road")
    m.road(from: (-90, -45), to: (90, -45), width: 6, name: "South Road")

    // The plaza and its fountain.
    m.part("Plaza", at: (0, 0.03, 0), size: (22, 0.06, 22), color: "#D9CBB0", shape: .cylinder, material: .matte)
    m.part("Fountain", at: (0, 0.5, 0), size: (6, 1, 6), color: "#BFC7D5", shape: .cylinder, material: .metal)
    m.water(0, 0, w: 5, d: 5, y: 1.05, name: "Fountain Water", tags: ["fountain"])
    m.part("Fountain Top", at: (0, 2, 0), size: (1, 2, 1), color: "#E5E7EB", shape: .cylinder)
    m.spawnRing(0, 0, radius: 8, count: 8)

    // Houses on both sides of the north and south roads.
    let colors = ["#F7D6E0", "#D6EAF8", "#FDEBD0", "#D5F5E3", "#E8DAEF", "#FCF3CF", "#FADBD8", "#D1F2EB"]
    let roofs = ["#B5453B", "#2E4A7D", "#7D4E2E", "#3C7D4E", "#6B3F8A", "#B58A2E", "#8A2E3C", "#2E7D6B"]
    var n = 0
    for (row, z) in [(0, 62), (1, 28), (2, -28), (3, -62)] {
        for x in [-60, -30, 30, 60] where n < 8 && !(row == 1 && x == 30) && !(row == 2 && x == -30) {
            let facing: Float = (row == 0 || row == 2) ? -1 : 1
            m.house("House \(n + 1)", x: Float(x), z: Float(z), w: 12, d: 10, h: 3.6,
                    wall: colors[n], roof: roofs[n], facing: facing)
            m.fence(from: (Float(x) - 7, Float(z) + facing * 7), to: (Float(x) - 2, Float(z) + facing * 7))
            m.tree(Float(x) + 8, Float(z) + facing * 4)
            n += 1
        }
    }

    // Places to work.
    m.shop("Police Station", x: 30, z: 28, w: 14, d: 10, color: "#2F4F8F", sign: "#60A5FA", facing: -1)
    m.pad("Job Police", x: 30, z: 26, size: 2.4, color: "#3B82F6", tags: ["job"])
    m.shop("Hospital", x: -30, z: -28, w: 14, d: 10, color: "#F4F6F8", sign: "#EF4444", facing: 1)
    m.pad("Job Doctor", x: -30, z: -26, size: 2.4, color: "#F87171", tags: ["job"])
    m.shop("Cafe", x: -78, z: 12, w: 10, d: 10, color: "#C98B5A", sign: "#FDE68A", facing: -1)
    m.pad("Job Chef", x: -78, z: 14, size: 2.4, color: "#F59E0B", tags: ["job"])
    m.shop("Fire Station", x: 78, z: -12, w: 12, d: 10, color: "#B91C1C", sign: "#FCA5A5", facing: 1)
    m.pad("Job Firefighter", x: 78, z: -14, size: 2.4, color: "#EF4444", tags: ["job"])
    m.shop("School", x: 78, z: 12, w: 14, d: 10, color: "#F2C14E", sign: "#FFFFFF", facing: -1)
    m.pad("Job Teacher", x: 78, z: 14, size: 2.4, color: "#22C55E", tags: ["job"])

    // The car lot: step on a pad to take a car out.
    m.part("Car Lot", at: (-78, 0.03, -12), size: (14, 0.06, 10), color: "#4B5563", material: .matte)
    for (i, c) in ["#EF4444", "#3B82F6", "#FACC15"].enumerated() {
        let x = -83 + Float(i) * 5
        m.slab("Display Car \(i + 1)", x: x, y: 0, z: -14, w: 2.2, h: 1, d: 4, color: c, material: .metal)
        m.slab("Display Car \(i + 1) Roof", x: x, y: 1, z: -14.3, w: 1.8, h: 0.7, d: 2.2, color: "#DDEEFF", material: .glass)
    }
    m.pad("Car Pad", x: -78, z: -8, size: 3, color: "#F97316", tags: ["car"])

    // More places: post office, bank, furniture store, taxi stand, the market.
    m.shop("Post Office", x: -52, z: 12, w: 10, d: 8, color: "#F59E0B", sign: "#1E3A8A", facing: -1)
    m.pad("Job Courier", x: -52, z: 14, size: 2.4, color: "#FBBF24", tags: ["job"])
    m.shop("Bank", x: 52, z: -12, w: 12, d: 9, color: "#E5E7EB", sign: "#FACC15", facing: 1)
    m.pad("Bank Counter", x: 52, z: -14, size: 2.4, color: "#FACC15", tags: ["bank"])
    m.shop("Furniture Store", x: -52, z: -12, w: 12, d: 9, color: "#F472B6", sign: "#FFFFFF", facing: 1)
    m.pad("Furniture Counter", x: -52, z: -14, size: 2.4, color: "#EC4899", tags: ["furniture"])
    m.pad("Job Taxi", x: 12, z: -6, size: 2.4, color: "#FACC15", tags: ["job"])
    m.slab("Taxi Stand", x: 12, y: 0, z: -9, w: 4, h: 2.4, d: 0.3, color: "#FACC15")
    m.part("Market Stalls", at: (-12, 0.03, 34), size: (18, 0.06, 8), color: "#FDE68A", material: .matte, solid: false)
    for i in 0..<4 {
        m.slab("Stall \(i + 1)", x: -18 + Float(i) * 4, y: 0, z: 34, w: 3, h: 1, d: 2, color: ["#EF4444", "#22C55E", "#3B82F6", "#F59E0B"][i])
        m.part("Stall \(i + 1) Roof", at: (-18 + Float(i) * 4, 2.4, 34), size: (3.4, 0.2, 2.6), color: "#FFFFFF", solid: false)
    }
    m.pad("Market", x: -12, z: 37, size: 3, color: "#FDE68A", tags: ["market"])
    // Where townsfolk walk, where fires break out and where passengers wait.
    m.markers("Town Spot", points: [(0, 12), (-30, 6), (30, 6), (-60, 6), (60, 6), (0, 40), (0, -40), (-78, 6), (78, -6),
                                    (40, 60), (-12, 30), (52, -6)], color: "#000000", visible: false, behavior: .none)
    m.pillar("Clock Tower", x: 10, z: -12, height: 9, radius: 1.2, color: "#A16207")
    m.part("Clock Face", at: (10, 8, -10.7), size: (1.6, 1.6, 0.1), color: "#FFFFFF", shape: .cylinder, material: .neon, solid: false,
           rotation: (90, 0, 0))

    // The gas station: cars run on fuel.
    m.part("Gas Station", at: (20, 0.03, -58), size: (14, 0.06, 10), color: "#9CA3AF", material: .matte)
    m.slab("Gas Canopy", x: 20, y: 4, z: -58, w: 12, h: 0.4, d: 8, color: "#DC2626")
    for (i, x) in [15, 25].enumerated() {
        m.pillar("Gas Canopy Post \(i + 1)", x: Float(x), z: -58, height: 4, radius: 0.3, color: "#E5E7EB")
    }
    m.slab("Gas Pump Machine", x: 20, y: 0, z: -61, w: 1.2, h: 1.8, d: 0.8, color: "#F9FAFB")
    m.pad("Gas Pump", x: 20, z: -58, size: 2.6, color: "#22C55E", tags: ["gas"])
    m.road(from: (20, -48), to: (20, -53), width: 5, name: "Gas Road")

    // City hall: vote for the mayor.
    m.shop("City Hall", x: -12, z: -28, w: 12, d: 9, color: "#F8FAFC", sign: "#1D4ED8", facing: 1)
    m.pad("Ballot Box", x: -12, z: -30, size: 2.4, color: "#60A5FA", tags: ["vote"])
    m.part("City Hall Dome", at: (-12, 5.4, -28), size: (5, 3, 5), color: "#93C5FD", shape: .sphere, material: .metal, solid: false)

    // A park.
    for p in ring(7, radius: 12, cx: 40, cz: 70) { m.tree(p.0, p.1, height: 4.5) }
    m.part("Pond", at: (40, 0.02, 70), size: (10, 0.04, 8), color: "#3B9DEB", shape: .cylinder, material: .glass, solid: false)
    for p in [(10, 10), (-10, 10), (10, -10), (-10, -10)] { m.lamp(Float(p.0), Float(p.1)) }
    for i in 0..<10 { m.lamp(-85 + Float(i) * 19, 5) }
}


// MARK: 2 Fruit Seas Adventure

/// An island: a flattened cylinder whose top is at y = 0.6.
func island(_ m: MapBuilder, _ name: String, x: Float, z: Float, radius: Float, color: String, sand: String = "#E8D7A5") {
    m.part("\(name) Beach", at: (x, -0.55, z), size: (radius * 2 + 6, 1.7, radius * 2 + 6), color: sand, shape: .cylinder, material: .matte)
    m.part(name, at: (x, -0.2, z), size: (radius * 2, 1.6, radius * 2), color: color, shape: .cylinder, material: .matte, tags: ["island"])
}

func fruitSeas(_ m: MapBuilder) {
    m.ocean()
    m.environment.killPlaneHeight = -30
    m.ground(320, 320, color: "#C9B98A", name: "Seabed", y: -1.4)
    m.part("Sea", at: (0, -0.25, 0), size: (320, 0.1, 320), color: "#2C8BE0", material: .glass, solid: false, opacity: 0.7)

    // Every island has the same named places, so the script can find them:
    // "<Island> Dock" (the boat menu), "<Island> Quest" (the quest giver),
    // "<Island> Spawn" (where you come back), "<Island> Camp" (enemies) and
    // "<Island> Boss" (the boss's arena).
    func places(_ name: String, x: Float, z: Float, radius r: Float, y: Float = 0.6, dock: String = "#38BDF8") {
        m.slab("\(name) Pier", x: x, y: y - 0.6, z: z + r + 1, w: 5, h: 0.6, d: 7, color: "#8B5A2B")
        m.pad("\(name) Dock", x: x, z: z + r - 2.5, y: y, size: 2.6, color: dock, tags: ["dock"])
        m.part("\(name) Quest", at: (x - 5, y + 0.1, z + r - 6), size: (1.4, 0.2, 1.4), color: "#FDE047", shape: .cylinder,
               material: .neon, behavior: .trigger, solid: false)
        m.part("\(name) Spawn", at: (x + 4, y + 0.1, z + r - 5), size: (1, 0.2, 1), color: "#FFFFFF", shape: .cylinder,
               solid: false, visible: false)
        m.part("\(name) Camp", at: (x + r * 0.35, y + 0.06, z - r * 0.3), size: (8, 0.12, 8), color: "#7C2D12", shape: .cylinder,
               material: .matte, solid: false)
        m.part("\(name) Boss", at: (x - r * 0.4, y + 0.06, z - r * 0.35), size: (12, 0.12, 12), color: "#991B1B", shape: .cylinder,
               material: .matte, solid: false)
        for p in ring(6, radius: 7, cx: x - r * 0.4, cz: z - r * 0.35) {
            m.pillar("\(name) Boss Pillar", x: p.0, z: p.1, y: y, height: 3.5, radius: 0.5, color: "#57534E")
        }
    }

    // 1 Start Island: the town. Shops for swords, fruit, guns and fighting styles.
    island(m, "Start Island", x: 0, z: 0, radius: 22, color: "#6CC26A")
    m.spawnRing(0, 0, y: 0.6, radius: 5, count: 6)
    m.shop("Sword Dealer", x: -11, z: -11, y: 0.6, w: 8, d: 6, color: "#8B5E3C", sign: "#FDE68A")
    m.pad("Sword Shop", x: -11, z: -13, y: 0.6, size: 2.2, color: "#F59E0B", tags: ["shop_sword"])
    m.shop("Fruit Dealer", x: 11, z: -11, y: 0.6, w: 8, d: 6, color: "#DB2777", sign: "#FBCFE8")
    m.pad("Fruit Shop", x: 11, z: -13, y: 0.6, size: 2.2, color: "#EC4899", tags: ["shop_fruit"])
    m.shop("Dojo", x: -12, z: 9, y: 0.6, w: 8, d: 6, color: "#1E3A8A", sign: "#93C5FD", facing: -1)
    m.pad("Dojo Mat", x: -12, z: 11, y: 0.6, size: 2.2, color: "#3B82F6", tags: ["shop_style"])
    m.shop("Gun Shop", x: 12, z: 9, y: 0.6, w: 8, d: 6, color: "#374151", sign: "#D1D5DB", facing: -1)
    m.pad("Gun Counter", x: 12, z: 11, y: 0.6, size: 2.2, color: "#9CA3AF", tags: ["shop_gun"])
    m.part("Stat Stone", at: (0, 1.6, -6), size: (1.4, 2, 1.4), color: "#A78BFA", shape: .cylinder, material: .neon,
           behavior: .trigger, tags: ["stats"])
    m.part("Gacha Well", at: (0, 1.1, 8), size: (2.4, 1, 2.4), color: "#FDE68A", shape: .cylinder, material: .metal,
           behavior: .trigger, tags: ["gacha"])
    for p in ring(6, radius: 17) { m.tree(p.0, p.1, y: 0.6, height: 5, leaves: "#3FA34D") }
    places("Start Island", x: 0, z: 0, radius: 22)

    // 2 Pirate Islet: the first enemies.
    island(m, "Pirate Islet", x: 40, z: 32, radius: 12, color: "#86C06C")
    for i in 0..<3 { m.crate(36 + Float(i) * 2.2, 30, y: 0.6) }
    m.part("Pirate Flag Pole", at: (44, 3.6, 36), size: (0.3, 6, 0.3), color: "#3F3F46", shape: .cylinder)
    m.part("Pirate Flag", at: (45.2, 5.8, 36), size: (2.2, 1.4, 0.1), color: "#111827", solid: false)
    places("Pirate Islet", x: 40, z: 32, radius: 12)

    // 3 Jungle Island.
    island(m, "Jungle Island", x: 75, z: -40, radius: 26, color: "#2F8F3A")
    for p in ring(10, radius: 19, cx: 75, cz: -40) { m.tree(p.0, p.1, y: 0.6, height: 6, leaves: "#1F6E2A") }
    for p in ring(5, radius: 9, cx: 75, cz: -40) { m.tree(p.0, p.1, y: 0.6, height: 4, leaves: "#166534") }
    places("Jungle Island", x: 75, z: -40, radius: 26)

    // 4 Desert Island.
    island(m, "Desert Island", x: -80, z: -55, radius: 30, color: "#E3C77A", sand: "#F0DFA8")
    for p in ring(8, radius: 22, cx: -80, cz: -55) {
        m.part("Cactus", at: (p.0, 2, p.1), size: (0.8, 2.8, 0.8), color: "#4D7C0F", shape: .cylinder)
    }
    m.part("Pyramid", at: (-92, 4, -40), size: (12, 7, 12), color: "#D6B45A", shape: .cone, material: .matte)
    places("Desert Island", x: -80, z: -55, radius: 30)

    // 5 Snow Island.
    island(m, "Snow Island", x: 10, z: 95, radius: 22, color: "#F1F5F9", sand: "#E2E8F0")
    for p in ring(8, radius: 16, cx: 10, cz: 95) { m.pine(p.0, p.1, y: 0.6, height: 6, leaves: "#E0F2FE") }
    m.part("Ice Castle", at: (18, 3.5, 84), size: (6, 6, 6), color: "#BAE6FD", material: .glass, opacity: 0.8)
    places("Snow Island", x: 10, z: 95, radius: 22)

    // 6 Marine Fort.
    island(m, "Marine Fort", x: -95, z: 55, radius: 22, color: "#9CA3AF", sand: "#D1D5DB")
    m.walls(-95, 55, w: 30, d: 30, h: 1.2, y: 0.6, color: "#E5E7EB", name: "Fort Wall")
    for p in ring(4, radius: 12, cx: -95, cz: 55) {
        m.part("Cannon", at: (p.0, 1.3, p.1), size: (0.8, 0.8, 2.4), color: "#1F2937", shape: .cylinder, rotation: (90, 0, 0))
    }
    m.part("Marine Tower", at: (-95, 5, 55), size: (4, 9, 4), color: "#F8FAFC", shape: .cylinder)
    places("Marine Fort", x: -95, z: 55, radius: 22)

    // 7 Volcano Island.
    island(m, "Volcano Island", x: 110, z: 75, radius: 24, color: "#44403C", sand: "#57534E")
    m.part("Volcano", at: (118, 5, 66), size: (14, 10, 14), color: "#292524", shape: .cone, material: .matte)
    m.part("Lava Top", at: (118, 9.6, 66), size: (3, 1, 3), color: "#F97316", shape: .cylinder, material: .neon, solid: false)
    for p in ring(5, radius: 15, cx: 110, cz: 75) {
        m.part("Lava Pool", at: (p.0, 0.62, p.1), size: (3, 0.06, 3), color: "#EA580C", shape: .cylinder, material: .neon, behavior: .trigger,
               tags: ["lava"], solid: false)
    }
    places("Volcano Island", x: 110, z: 75, radius: 24)

    // 8 Sky Island, high above the sea. The boat menu takes you up.
    m.part("Sky Island", at: (-10, 39.4, -115), size: (40, 1.6, 40), color: "#F5F3FF", shape: .cylinder, material: .matte, tags: ["island"])
    for p in ring(8, radius: 24, cx: -10, cz: -115) {
        m.part("Cloud", at: (p.0, 38.5, p.1), size: (7, 2.5, 5), color: "#FFFFFF", shape: .sphere, material: .matte, solid: false, opacity: 0.85)
    }
    m.part("Sky Temple", at: (-10, 44, -125), size: (8, 7, 8), color: "#FDE68A", shape: .cylinder, material: .metal)
    places("Sky Island", x: -10, z: -115, radius: 20, y: 40.2, dock: "#E879F9")

    // Where fruit may appear, under the trees.
    m.markers("Fruit Spot", points: [(8, 12), (-14, 6), (80, -30), (65, -52), (-70, -40), (-92, -62), (18, 88), (0, 104),
                                     (44, 36), (-88, 62), (104, 84), (-4, -110)],
              y: 0.6, color: "#FFFFFF", visible: false, behavior: .none)
}


// MARK: 3 Pet Home Paradise

func petHome(_ m: MapBuilder) {
    m.day(ground: "#A7E08F")
    m.ground(210, 210, color: "#B8E6A0")
    m.part("Plaza", at: (0, 0.03, 0), size: (28, 0.06, 28), color: "#FDE2E4", shape: .cylinder, material: .matte)
    m.spawnRing(0, 0, radius: 6, count: 8, color: "#F9A8D4")
    m.road(from: (-100, 0), to: (100, 0), width: 7, name: "Pet Road")
    m.road(from: (0, -100), to: (0, 100), width: 7, name: "Pet Road")

    // The nursery sells eggs: one stand per egg.
    m.house("Nursery", x: 0, z: -40, w: 30, d: 12, h: 4.5, wall: "#FBCFE8", roof: "#DB2777", floor: "#FFF1F2", tags: ["nursery"])
    let eggs: [(String, String, Float)] = [("Egg Basic", "#F5F5F4", -11), ("Egg Farm", "#FDE68A", -5.5), ("Egg Forest", "#4ADE80", 0),
                                           ("Egg Ocean", "#38BDF8", 5.5), ("Egg Space", "#6D28D9", 11)]
    for e in eggs {
        m.slab("\(e.0) Stand", x: e.2, y: 0, z: -43, w: 2.4, h: 0.8, d: 2.4, color: "#FFFFFF")
        m.part(e.0, at: (e.2, 1.6, -43), size: (1.3, 1.7, 1.3), color: e.1, shape: .sphere, material: .plastic,
               behavior: .trigger, tags: ["egg"])
    }

    // The pet shop: food, toys, potions.
    m.shop("Pet Shop", x: -42, z: -40, w: 18, d: 10, color: "#FDBA74", sign: "#FFFFFF")
    m.pad("Food Counter", x: -48, z: -42, size: 2.4, color: "#F97316", tags: ["shop_food"])
    m.pad("Toy Counter", x: -42, z: -42, size: 2.4, color: "#22C55E", tags: ["shop_toy"])
    m.pad("Potion Counter", x: -36, z: -42, size: 2.4, color: "#A855F7", tags: ["shop_potion"])

    // The neon cave: four grown-up pets of a kind make one glowing pet.
    // Back, sides and a front with a 4 m doorway facing the plaza.
    m.slab("Neon Cave Wall", x: 42, y: 0, z: -46, w: 17, h: 5, d: 1, color: "#1E1B4B")
    m.slab("Neon Cave Wall", x: 34, y: 0, z: -40, w: 1, h: 5, d: 12, color: "#1E1B4B")
    m.slab("Neon Cave Wall", x: 50, y: 0, z: -40, w: 1, h: 5, d: 12, color: "#1E1B4B")
    m.slab("Neon Cave Wall", x: 37, y: 0, z: -34, w: 6, h: 5, d: 1, color: "#1E1B4B")
    m.slab("Neon Cave Wall", x: 47, y: 0, z: -34, w: 6, h: 5, d: 1, color: "#1E1B4B")
    m.slab("Neon Cave Roof", x: 42, y: 5, z: -40, w: 17, h: 0.5, d: 13, color: "#312E81")
    m.part("Neon Altar", at: (42, 0.4, -41), size: (4, 0.8, 4), color: "#E879F9", shape: .cylinder, material: .neon,
           behavior: .trigger, tags: ["neon"])
    for p in ring(4, radius: 5, cx: 42, cz: -41) {
        m.part("Neon Crystal", at: (p.0, 1.4, p.1), size: (0.8, 2.8, 0.8), color: "#22D3EE", shape: .cone, material: .neon, solid: false)
    }

    // Trading plaza and the pet show stage.
    m.part("Trade Plaza", at: (0, 0.04, 28), size: (16, 0.08, 10), color: "#FEF3C7", material: .matte)
    m.pad("Trade Booth", x: 0, z: 28, size: 3, color: "#F59E0B", tags: ["trade"])
    m.slab("Show Stage", x: 0, y: 0, z: 62, w: 20, h: 1, d: 10, color: "#FDE68A")
    m.pad("Show Spot", x: 0, z: 62, y: 1, size: 4, color: "#F43F5E", tags: ["show"])
    for i in 0..<3 {
        m.slab("Show Step \(i + 1)", x: -3 + Float(i) * 3, y: 0, z: 56, w: 2, h: 0.35 + Float(i) * 0.3, d: 2, color: "#FDE047")
    }
    m.part("Show Arch", at: (0, 5, 66), size: (20, 1, 1), color: "#F472B6", material: .neon, solid: false)

    // The ten places pets ask for.
    let needs: [(String, String, Float, Float, String)] = [
        ("Food Stand", "#F97316", -62, 0, "hungry"), ("Water Well", "#38BDF8", 62, 0, "thirsty"),
        ("Pet Beds", "#A78BFA", -62, 30, "sleepy"), ("Bath House", "#67E8F9", 62, 30, "dirty"),
        ("Playground", "#22C55E", -36, 72, "bored"), ("Vet Clinic", "#F87171", 36, 72, "sick"),
        ("Campsite", "#65A30D", -80, 75, "camping"), ("School", "#FACC15", 80, 75, "school"),
        ("Pizza Place", "#DC2626", -75, -75, "pizza"), ("Beach", "#FDE68A", 0, -84, "beach")
    ]
    for n in needs {
        m.slab("\(n.0) Base", x: n.2, y: 0, z: n.3, w: 12, h: 0.3, d: 12, color: "#FFFFFF")
        m.pad(n.0, x: n.2, z: n.3, y: 0.3, size: 6, color: n.1, tags: ["need", n.4])
        m.pillar("\(n.0) Post", x: n.2 + 5, z: n.3 - 5, y: 0.3, height: 3.5, radius: 0.3, color: n.1)
        m.part("\(n.0) Sign", at: (n.2 + 5, 4.2, n.3 - 5), size: (2.4, 1.2, 0.2), color: n.1, material: .neon, solid: false)
    }
    m.part("Well Roof", at: (62, 3.6, 0), size: (6, 1.4, 6), color: "#1D4ED8", shape: .cone)
    for i in 0..<3 { m.slab("Slide \(i + 1)", x: -40 + Float(i) * 4, y: 0.3, z: 78, w: 2, h: 2 + Float(i), d: 2, color: "#FDE047") }
    for i in 0..<3 { m.part("Tent \(i + 1)", at: (-84 + Float(i) * 4, 1.3, 70), size: (3, 2.6, 3), color: "#EA580C", shape: .cone) }
    m.part("Campfire", at: (-80, 0.5, 78), size: (1.4, 0.8, 1.4), color: "#F97316", shape: .cone, material: .neon, solid: false)
    for i in 0..<4 { m.slab("Bed \(i + 1)", x: -66 + Float(i) * 2.7, y: 0.3, z: 34, w: 2.2, h: 0.5, d: 3, color: "#C4B5FD") }
    m.house("School House", x: 80, z: 88, w: 14, d: 8, h: 4, wall: "#FEF08A", roof: "#B45309", tags: ["school"], facing: -1)
    m.house("Pizza House", x: -75, z: -88, w: 12, d: 8, h: 4, wall: "#FECACA", roof: "#B91C1C", tags: ["pizza"], facing: 1)
    m.part("Sea", at: (0, 0.02, -97), size: (120, 0.04, 10), color: "#0EA5E9", material: .glass, solid: false)
    m.part("Sand", at: (0, 0.03, -86), size: (60, 0.04, 14), color: "#FDE68A", material: .matte, solid: false)
    for x in [-20, -10, 10, 20] {
        m.part("Umbrella", at: (Float(x), 2.2, -86), size: (3, 0.6, 3), color: "#F43F5E", shape: .cone, solid: false)
        m.part("Umbrella Pole", at: (Float(x), 1.1, -86), size: (0.15, 2.2, 0.15), color: "#FFFFFF", shape: .cylinder)
    }

    for p in ring(16, radius: 96) { m.tree(p.0, p.1, height: 4, leaves: "#F472B6") }
    for p in ring(12, radius: 50, phase: 0.3) { m.tree(p.0, p.1, height: 3.5, leaves: "#86EFAC") }
    for p in grid(4, 2, spacing: 3, cx: -14, cz: 14) {
        m.part("Flower", at: (p.0, 0.3, p.1), size: (0.8, 0.6, 0.8), color: "#F43F5E", shape: .sphere, solid: false)
    }
    for p in [(12, 12), (-12, 12), (12, -12), (-12, -12)] { m.lamp(Float(p.0), Float(p.1)) }
}

// MARK: 4 Meme Heist

func memeHeist(_ m: MapBuilder) {
    m.sky("#FF7AD9", "#FFE3A3", light: 0.8, ground: "#3B2A6B")
    m.ground(160, 160, color: "#4C3A8A")
    // The carpet memes walk along, from the gate at -z to the stage at +z.
    m.part("Red Carpet", at: (0, 0.05, 0), size: (6, 0.1, 110), color: "#DC2626", material: .matte)
    m.slab("Meme Gate", x: 0, y: 0, z: -56, w: 10, h: 6, d: 1, color: "#FACC15", material: .neon)
    m.slab("Meme Stage", x: 0, y: 0, z: 58, w: 12, h: 1, d: 6, color: "#FDE047")
    m.part("Carpet Start", at: (0, 0.2, -52), size: (2, 0.2, 2), color: "#FFFFFF", shape: .cylinder, visible: false)
    m.part("Carpet End", at: (0, 0.2, 52), size: (2, 0.2, 2), color: "#FFFFFF", shape: .cylinder, visible: false)
    m.spawnRing(0, -40, radius: 3, count: 4, color: "#FDE047")
    // Carpet-side spots where robots and players stand to buy.
    m.markers("Carpet Spot", points: [(4, -30), (-4, -10), (4, 10), (-4, 30)], color: "#FDE047", size: 1.6)

    // The gear shop and the rebirth altar, at the top of the carpet.
    m.shop("Gear Shop", x: -16, z: -48, w: 10, d: 8, color: "#1E293B", sign: "#22D3EE")
    m.pad("Gear Counter", x: -16, z: -50, size: 2.4, color: "#22D3EE", tags: ["gear"])
    m.part("Rebirth Altar", at: (16, 0.6, -48), size: (4, 1.2, 4), color: "#F472B6", shape: .cylinder, material: .neon,
           behavior: .trigger, tags: ["rebirth"])
    m.part("Rebirth Crystal", at: (16, 3, -48), size: (1.6, 3, 1.6), color: "#E879F9", shape: .cone, material: .neon, solid: false)

    // Eight bases, four on each side of the carpet. The doorway faces the carpet.
    let colors = ["#EF4444", "#3B82F6", "#22C55E", "#F59E0B", "#A855F7", "#EC4899", "#14B8A6", "#F97316"]
    for i in 0..<8 {
        let side: Float = i < 4 ? -1 : 1
        let z = -36 + Float(i % 4) * 24
        let x = side * 34
        let n = i + 1
        m.slab("Base \(n) Floor", x: x, y: 0, z: z, w: 20, h: 0.4, d: 18, color: "#1F1B3A", tags: ["base"])
        m.pad("Base \(n) Claim", x: x - side * 7.5, z: z - 6, y: 0.4, size: 2.5, color: colors[i], tags: ["claim"])
        m.pad("Base \(n) Home", x: x - side * 2, z: z, y: 0.4, size: 4, color: colors[i], tags: ["home"], shape: .box)
        m.pad("Base \(n) Lock", x: x - side * 7.5, z: z + 6, y: 0.4, size: 2, color: "#FFFFFF", tags: ["lock"])
        // A wall of lasers across the doorway, off until locked.
        m.part("Base \(n) Laser", at: (x - side * 10, 1.9, z), size: (0.3, 3, 7), color: colors[i], material: .neon,
               behavior: .trigger, tags: ["laser"], solid: false, visible: false)
        // Ten pedestals: the outer row first, the inner row unlocked later.
        for k in 0..<10 {
            let row: Float = k < 5 ? 7 : 3.5
            let sz = z - 6 + Float(k % 5) * 3
            m.part("Base \(n) Slot \(k + 1)", at: (x + side * row, 0.9, sz), size: (2, 1, 2), color: k < 5 ? "#D4D4D8" : "#6B7280",
                   shape: .cylinder, material: .metal, behavior: .trigger, tags: ["slot"])
        }
        // Walls: back, two sides, and the front in two parts around a 7 m doorway.
        let wall = "Base \(n) Wall"
        m.slab(wall, x: x + side * 10, y: 0.4, z: z, w: 0.4, h: 2.5, d: 18, color: colors[i], opacity: 0.35)
        m.slab(wall, x: x, y: 0.4, z: z - 9, w: 20, h: 2.5, d: 0.4, color: colors[i], opacity: 0.35)
        m.slab(wall, x: x, y: 0.4, z: z + 9, w: 20, h: 2.5, d: 0.4, color: colors[i], opacity: 0.35)
        m.slab(wall, x: x - side * 10, y: 0.4, z: z - 6.25, w: 0.4, h: 2.5, d: 5.5, color: colors[i], opacity: 0.35)
        m.slab(wall, x: x - side * 10, y: 0.4, z: z + 6.25, w: 0.4, h: 2.5, d: 5.5, color: colors[i], opacity: 0.35)
    }
}

// MARK: 5 Reel Legends

func reelLegends(_ m: MapBuilder) {
    m.ocean()
    m.ground(240, 240, color: "#C8B68A", name: "Lakebed", y: -2)
    // Land in the middle, water around it.
    m.part("Harbor Town", at: (0, -0.5, 0), size: (50, 1, 40), color: "#9CCB6B", material: .matte, tags: ["ground"])
    m.part("Sea", at: (0, -0.3, 0), size: (240, 0.1, 240), color: "#1E7AD1", material: .glass, solid: false, opacity: 0.75)
    m.spawnRing(0, 0, radius: 5, count: 6)
    m.shop("Fish Market", x: -14, z: -10, w: 10, d: 8, color: "#0EA5E9", sign: "#FDE68A")
    m.pad("Merchant", x: -14, z: -12, size: 2.4, color: "#FACC15", tags: ["merchant"])
    m.shop("Rod Shop", x: 14, z: -10, w: 10, d: 8, color: "#1E40AF", sign: "#FFFFFF")
    m.pad("Rod Counter", x: 14, z: -12, size: 2.4, color: "#60A5FA", tags: ["rodshop"])
    m.shop("Bait Shop", x: 14, z: 10, w: 10, d: 8, color: "#15803D", sign: "#BBF7D0", facing: -1)
    m.pad("Bait Counter", x: 14, z: 12, size: 2.4, color: "#4ADE80", tags: ["baitshop"])
    m.pad("Angler", x: -14, z: 10, size: 2.4, color: "#F97316", tags: ["angler"])
    m.part("Angler Hut", at: (-14, 1.5, 14), size: (6, 3, 3), color: "#92400E")
    m.part("Bestiary Board", at: (0, 1.8, -17), size: (6, 3, 0.3), color: "#FEF3C7", material: .matte, behavior: .trigger, tags: ["bestiary"])
    for p in ring(6, radius: 16, phase: 0.5) { m.tree(p.0, p.1, height: 4) }

    // Eight fishing grounds around town, each with a pier, a dock and two spots.
    let zones: [(String, Float, Float, String)] = [
        ("Pond", 0, 48, "#86EFAC"), ("River", 45, 45, "#7DD3FC"), ("Ocean", 64, 0, "#38BDF8"), ("Coral Reef", 45, -45, "#F472B6"),
        ("Deep Trench", 0, -66, "#1E3A8A"), ("Frozen Lake", -45, -45, "#E0F2FE"), ("Volcano Lake", -64, 0, "#F97316"),
        ("Sunken Ruins", -45, 45, "#A78BFA")
    ]
    for z in zones {
        // A pier from the edge of town out to the dock.
        let len = (z.1 * z.1 + z.2 * z.2).squareRoot()
        let ux = z.1 / len, uz = z.2 / len
        let edge: Float = 18
        let pierLength = len - edge - 5
        let mx = ux * (edge + pierLength / 2), mz = uz * (edge + pierLength / 2)
        let yaw = atan2(ux, uz) * 180 / .pi
        m.part("\(z.0) Pier", at: (mx, -0.2, mz), size: (4, 0.4, pierLength + 2), color: "#8B5A2B", rotation: (0, yaw, 0))
        m.slab("\(z.0) Dock", x: z.1, y: -0.4, z: z.2, w: 12, h: 0.4, d: 12, color: "#A16207")
        m.pad("Fishing Spot \(z.0) A", x: z.1 - 3, z: z.2, y: 0, size: 2, color: z.3, tags: ["spot", z.0])
        m.pad("Fishing Spot \(z.0) B", x: z.1 + 3, z: z.2, y: 0, size: 2, color: z.3, tags: ["spot", z.0])
        m.pillar("\(z.0) Sign", x: z.1, z: z.2 - 5, y: 0, height: 3, radius: 0.3, color: z.3, material: .neon)
        m.part("\(z.0) Water", at: (z.1 + ux * 12, -0.22, z.2 + uz * 12), size: (18, 0.06, 18), color: z.3, shape: .cylinder,
               material: .glass, solid: false, opacity: 0.45)
    }
    // What makes each ground look like itself.
    for i in 0..<5 { m.part("Reed", at: (40 + Float(i) * 2, 0.6, 52), size: (0.3, 2.4, 0.3), color: "#65A30D", shape: .cylinder, solid: false) }
    for p in ring(6, radius: 7, cx: 54, cz: -54) {
        m.part("Coral", at: (p.0, 0.2, p.1), size: (1.6, 1.8, 1.6), color: ["#F472B6", "#FB923C", "#A78BFA"][Int(p.0) % 3 == 0 ? 0 : 1],
               shape: .sphere, solid: false)
    }
    m.part("Ice Sheet", at: (-54, -0.15, -54), size: (16, 0.2, 16), color: "#F0F9FF", material: .glass, solid: false, opacity: 0.8)
    m.part("Volcano", at: (-88, 6, 0), size: (22, 16, 22), color: "#57301B", shape: .cone, material: .matte)
    m.part("Lava Glow", at: (-88, 14.2, 0), size: (4, 0.4, 4), color: "#FF5A1F", shape: .cylinder, material: .neon, solid: false)
    for p in ring(5, radius: 8, cx: -56, cz: 56) {
        m.part("Ruin Pillar", at: (p.0, 1.2, p.1), size: (1, 3.2, 1), color: "#C4B5FD", shape: .cylinder, material: .matte)
    }
    // Where a treasure map leads.
    m.markers("Treasure Spot", points: [(20, 18), (-22, -16), (8, -18), (-6, 16)], y: 0, color: "#FACC15", visible: false, behavior: .none)
}

// MARK: 6 Clash Duels

func clashDuels(_ m: MapBuilder) {
    m.sky("#1F2937", "#94A3B8", light: 0.75, ground: "#374151")
    m.ground(360, 260, color: "#1F2937", name: "Void")

    // The lobby: queues, shop, loadout, training. Everyone starts here.
    m.slab("Lobby Floor", x: -140, y: 0, z: 0, w: 50, h: 0.4, d: 50, color: "#334155")
    m.spawnRing(-140, 0, y: 0.4, radius: 6, count: 8, color: "#22D3EE")
    let pads: [(String, Float, Float, String, String)] = [
        ("Duel Queue", -154, -14, "#F43F5E", "queue_duel"), ("Team Queue", -140, -14, "#F59E0B", "queue_team"),
        ("FFA Portal", -126, -14, "#A855F7", "ffa"), ("Training Portal", -154, 14, "#22C55E", "training"),
        ("Weapon Shop", -140, 14, "#FACC15", "shop"), ("Loadout Rack", -126, 14, "#38BDF8", "loadout")
    ]
    for pd in pads {
        m.pad(pd.0, x: pd.1, z: pd.2, y: 0.4, size: 4, color: pd.3, tags: [pd.4])
        m.part("\(pd.0) Sign", at: (pd.1, 3.6, pd.2 + (pd.2 < 0 ? -2.6 : 2.6)), size: (6, 1.2, 0.3), color: pd.3, material: .neon, solid: false)
    }
    m.walls(-140, 0, w: 50, d: 50, h: 2, y: 0.4, color: "#475569", name: "Lobby Wall")

    // Training range next to the lobby.
    m.slab("Range Floor", x: -140, y: 0, z: 58, w: 44, h: 0.4, d: 28, color: "#14532D")
    m.markers("Range Start", points: [(-140, 50)], y: 0.4, color: "#22C55E", behavior: .none)
    m.markers("Dummy Spot", points: [(-156, 68), (-148, 70), (-140, 68), (-132, 70), (-124, 68)], y: 0.4, color: "#F97316", behavior: .none)
    m.pad("Range Exit", x: -140, z: 46, y: 0.4, size: 3, color: "#94A3B8", tags: ["lobby"])

    // Team arena: Crossroads.
    m.slab("Arena Floor", x: 0, y: 0, z: 0, w: 90, h: 0.4, d: 60, color: "#475569")
    m.walls(0, 0, w: 90, d: 60, h: 6, y: 0.4, color: "#1E293B", name: "Arena Wall")
    m.slab("Red Base", x: -38, y: 0.4, z: 0, w: 10, h: 0.3, d: 20, color: "#B91C1C")
    m.slab("Blue Base", x: 38, y: 0.4, z: 0, w: 10, h: 0.3, d: 20, color: "#1D4ED8")
    m.markers("Red Spawn", points: [(-40, -8), (-40, -4), (-40, 0), (-40, 4), (-40, 8)], y: 0.7, color: "#F87171", behavior: .none)
    m.markers("Blue Spawn", points: [(40, -8), (40, -4), (40, 0), (40, 4), (40, 8)], y: 0.7, color: "#60A5FA", behavior: .none)
    var r = Seeded("clash")
    for i in 0..<14 {
        let x = r.range(-26, 26), z = r.range(-24, 24)
        let tall = r.unit() > 0.5
        m.slab("Cover \(i + 1)", x: x, y: 0.4, z: z, w: r.range(2, 5), h: tall ? 3.2 : 1.3, d: r.range(1.5, 4),
               color: tall ? "#64748B" : "#94A3B8")
    }
    m.slab("Tower", x: 0, y: 0.4, z: 0, w: 6, h: 4, d: 6, color: "#334155")
    m.stairs(-7, 0, y: 0.4, steps: 4, rise: 1, run: 1, width: 3, color: "#475569", name: "Tower Step")

    // Duel arena: Docks.
    m.slab("Docks Floor", x: 0, y: 0, z: 110, w: 60, h: 0.4, d: 36, color: "#78716C")
    m.walls(0, 110, w: 60, d: 36, h: 5, y: 0.4, color: "#44403C", name: "Docks Wall")
    m.markers("Duel Spawn", points: [(-26, 110), (26, 110)], y: 0.7, color: "#F43F5E", behavior: .none)
    let containers: [(Float, Float, String)] = [(-14, 100, "#DC2626"), (-6, 118, "#2563EB"), (6, 102, "#16A34A"), (14, 120, "#F59E0B"),
                                                (0, 110, "#7C3AED"), (-18, 122, "#0EA5E9"), (18, 98, "#DB2777")]
    for (i, c) in containers.enumerated() {
        m.slab("Container \(i + 1)", x: c.0, y: 0.4, z: c.1, w: 6, h: 2.6, d: 2.6, color: c.2, material: .metal)
    }
    for i in 0..<6 { m.crate(-22 + Float(i) * 9, 110 + (i % 2 == 0 ? -8 : 8), y: 0.4) }

    // Free-for-all arena: Temple.
    m.slab("Temple Floor", x: 130, y: 0, z: 0, w: 70, h: 0.4, d: 70, color: "#A8A29E")
    m.walls(130, 0, w: 70, d: 70, h: 6, y: 0.4, color: "#78716C", name: "Temple Wall")
    m.slab("Temple Platform", x: 130, y: 0.4, z: 0, w: 14, h: 2.5, d: 14, color: "#D6D3D1")
    m.stairs(121, -1.5, y: 0.4, steps: 3, rise: 0.8, run: 1, width: 3, color: "#A8A29E", name: "Temple Step")
    for p in ring(8, radius: 22, cx: 130, cz: 0) {
        m.pillar("Temple Pillar", x: p.0, z: p.1, y: 0.4, height: 5, radius: 1, color: "#E7E5E4")
    }
    let ffa = ring(8, radius: 30, cx: 130, cz: 0, phase: 0.2).map { ($0.0, $0.1) }
    m.markers("FFA Spawn", points: ffa, y: 0.7, color: "#A855F7", behavior: .none)

    // A way back to the lobby from every arena.
    m.pad("Arena Exit", x: 0, z: -26, y: 0.4, size: 3, color: "#94A3B8", tags: ["lobby"])
    m.pad("Docks Exit", x: 0, z: 125, y: 0.4, size: 3, color: "#94A3B8", tags: ["lobby"])
    m.pad("Temple Exit", x: 130, z: -32, y: 0.4, size: 3, color: "#94A3B8", tags: ["lobby"])
}

// MARK: 7 Sprout Garden

func sproutGarden(_ m: MapBuilder) {
    m.day(ground: "#7CB342")
    m.ground(170, 170, color: "#8BC34A")
    m.part("Plaza", at: (0, 0.03, 0), size: (24, 0.06, 24), color: "#E7D3A8", shape: .cylinder, material: .matte)
    m.spawnRing(0, 0, radius: 5, count: 8)
    m.shop("Seed Shop", x: -14, z: -18, w: 10, d: 8, color: "#65A30D", sign: "#FEF08A")
    m.pad("Seed Counter", x: -14, z: -20, size: 2.4, color: "#A3E635", tags: ["seeds"])
    m.shop("Market", x: 0, z: -20, w: 10, d: 8, color: "#EA580C", sign: "#FFFFFF")
    m.pad("Sell Counter", x: 0, z: -22, size: 2.4, color: "#FB923C", tags: ["sell"])
    m.shop("Gear Shop", x: 14, z: -18, w: 10, d: 8, color: "#0369A1", sign: "#BAE6FD")
    m.pad("Gear Counter", x: 14, z: -20, size: 2.4, color: "#38BDF8", tags: ["gear"])
    m.part("Egg Stand", at: (0, 0.5, 14), size: (6, 1, 3), color: "#FDE68A", material: .matte)
    for (i, c) in ["#F5F5F4", "#86EFAC", "#93C5FD", "#F0ABFC"].enumerated() {
        m.part("Egg \(i + 1)", at: (-2.25 + Float(i) * 1.5, 1.5, 14), size: (0.9, 1.1, 0.9), color: c, shape: .sphere)
    }
    m.pad("Pet Eggs", x: 0, z: 11, size: 2.4, color: "#FBBF24", tags: ["eggs"])

    // Eight gardens in a ring, each four by four soil squares.
    for i in 0..<8 {
        let a = Float(i) / 8 * 2 * .pi
        let cx = cos(a) * 50, cz = sin(a) * 50
        m.slab("Plot \(i + 1)", x: cx, y: 0, z: cz, w: 17, h: 0.2, d: 17, color: "#6D4C2F", tags: ["plot"])
        m.pad("Plot \(i + 1) Sign", x: cx - cos(a) * 11, z: cz - sin(a) * 11, size: 2, color: "#FDE047", tags: ["claim"])
        var k = 0
        for p in grid(4, 4, spacing: 3.8, cx: cx, cz: cz) {
            k += 1
            m.part("Plot \(i + 1) Soil \(k)", at: (p.0, 0.3, p.1), size: (3, 0.2, 3), color: "#3B2A1E", material: .matte,
                   behavior: .trigger, tags: ["soil"])
        }
        m.fence(from: (cx - 8.5, cz + 8.5), to: (cx + 8.5, cz + 8.5))
        m.fence(from: (cx - 8.5, cz - 8.5), to: (cx + 8.5, cz - 8.5))
    }
    for p in ring(16, radius: 78) { m.tree(p.0, p.1, height: 5, leaves: "#4CAF50") }
    for p in [(10, 10), (-10, 10), (10, -10), (-10, -10)] { m.lamp(Float(p.0), Float(p.1)) }
}

// MARK: 8 Runway Star

func runwayStar(_ m: MapBuilder) {
    m.indoor()
    m.sky("#2A0B3D", "#7C3AED", light: 0.7, showGround: false)
    m.ground(70, 60, color: "#1F1235", name: "Studio Floor")
    m.walls(0, 0, w: 70, d: 60, h: 8, color: "#3B0764", name: "Studio Wall")
    // The dressing room.
    m.slab("Dressing Room", x: -20, y: 0, z: 0, w: 24, h: 0.2, d: 40, color: "#F5D0FE")
    for (i, z) in [-12, -6, 0, 6, 12].enumerated() {
        m.slab("Mirror \(i + 1)", x: -31, y: 0, z: Float(z), w: 0.3, h: 4, d: 4, color: "#E0F2FE", material: .glass)
    }
    m.spawnRing(-20, 0, y: 0.2, radius: 6, count: 8, color: "#F0ABFC")
    // The runway, lit, with the judges' seats.
    m.slab("Runway", x: 16, y: 0, z: 0, w: 6, h: 1, d: 44, color: "#FFFFFF", material: .metal)
    m.part("Runway Start", at: (16, 1.3, -20), size: (2, 0.2, 2), color: "#F472B6", shape: .cylinder, material: .neon)
    m.part("Runway End", at: (16, 1.3, 20), size: (2, 0.2, 2), color: "#F472B6", shape: .cylinder, material: .neon)
    for z in stride(from: Float(-20), through: 20, by: 5) {
        m.part("Runway Light", at: (12.6, 1.05, z), size: (0.4, 0.1, 0.4), color: "#FDE047", shape: .cylinder, material: .neon, solid: false)
        m.part("Runway Light", at: (19.4, 1.05, z), size: (0.4, 0.1, 0.4), color: "#FDE047", shape: .cylinder, material: .neon, solid: false)
    }
    for i in 0..<6 { m.slab("Seat \(i + 1)", x: 26, y: 0, z: -12 + Float(i) * 5, w: 2, h: 1, d: 2, color: "#9D174D") }
    m.part("Camera Spot", at: (30, 6, 24), size: (0.5, 0.5, 0.5), color: "#000000", visible: false)
    m.part("Stage Light", at: (16, 7.5, 0), size: (8, 0.3, 30), color: "#FFFFFF", material: .neon, solid: false)

    // The judges' table at the end of the runway.
    m.slab("Judge Table", x: 16, y: 0, z: 26, w: 10, h: 1.1, d: 1.2, color: "#F9A8D4")
    m.markers("Judge Seat", points: [(13, 28), (16, 28), (19, 28)], color: "#FDE047", size: 1, behavior: .none)
    // The podium for the top three.
    m.slab("Podium 1 Step", x: -4, y: 0, z: 24, w: 3, h: 1.8, d: 3, color: "#FACC15")
    m.slab("Podium 2 Step", x: -7.2, y: 0, z: 24, w: 3, h: 1.2, d: 3, color: "#D1D5DB")
    m.slab("Podium 3 Step", x: -0.8, y: 0, z: 24, w: 3, h: 0.8, d: 3, color: "#D97706")
    m.markers("Podium", points: [(-4, 24), (-7.2, 24), (-0.8, 24)], y: 1.8, color: "#FFFFFF", visible: false, behavior: .none)
    // The boutique and the closet in the dressing room.
    m.pad("Boutique", x: -28, z: -16, y: 0.2, size: 3, color: "#F472B6", tags: ["boutique"])
    m.part("Boutique Sign", at: (-28, 3.4, -18.5), size: (5, 1, 0.2), color: "#F472B6", material: .neon, solid: false)
    m.pad("Closet", x: -28, z: 16, y: 0.2, size: 3, color: "#A78BFA", tags: ["closet"])
    m.part("Closet Rack", at: (-30.5, 1.8, 16), size: (0.3, 3.2, 6), color: "#78350F")
    for i in 0..<5 {
        m.part("Hanging Dress \(i + 1)", at: (-30, 1.6, 13.6 + Float(i) * 1.2), size: (0.2, 1.6, 0.9),
               color: ["#F472B6", "#60A5FA", "#FACC15", "#34D399", "#A78BFA"][i], solid: false)
    }
}

// MARK: 9 Mystery Manor

func mysteryManor(_ m: MapBuilder) {
    m.dusk(ground: "#1F2A1F")
    m.ground(120, 120, color: "#2D3B2D")
    // The lobby, away from the manor.
    m.slab("Lobby", x: 0, y: 0, z: -48, w: 24, h: 0.4, d: 16, color: "#44403C")
    m.walls(0, -48, w: 24, d: 16, h: 3, y: 0.4, color: "#78716C", name: "Lobby Wall")
    m.spawnRing(0, -48, y: 0.4, radius: 4, count: 6, name: "Lobby Spawn", color: "#FDE68A")
    // The manor: a big house of rooms.
    m.slab("Manor Floor", x: 0, y: 0, z: 10, w: 56, h: 0.3, d: 44, color: "#6B4F3A")
    m.walls(0, 10, w: 56, d: 44, h: 5, y: 0.3, color: "#8C6E54", name: "Manor Wall")
    m.slab("Manor Roof", x: 0, y: 5.3, z: 10, w: 57, h: 0.5, d: 45, color: "#3F2A1E")
    // Inner walls with gaps for doorways.
    for (x, z0, z1) in [(-10, -12, -2), (-10, 4, 20), (-10, 26, 32), (10, -12, 0), (10, 6, 16), (10, 22, 32)] {
        m.slab("Inner Wall", x: Float(x), y: 0.3, z: Float(z0 + z1) / 2, w: 0.5, h: 4.7, d: Float(z1 - z0), color: "#A1887F")
    }
    for (z, x0, x1) in [(10, -28, -16), (10, -4, 4), (10, 16, 28)] {
        m.slab("Inner Wall", x: Float(x0 + x1) / 2, y: 0.3, z: Float(z), w: Float(x1 - x0), h: 4.7, d: 0.5, color: "#A1887F")
    }
    // Furniture to hide behind.
    var r = Seeded("manor")
    for i in 0..<16 {
        m.slab("Furniture \(i + 1)", x: r.range(-25, 25), y: 0.3, z: r.range(-9, 29), w: r.range(1.5, 3), h: r.range(0.8, 2.2),
               d: r.range(1, 2.5), color: r.pick(["#7F1D1D", "#1E3A8A", "#78350F", "#365314"]))
    }
    for (i, p) in grid(3, 2, spacing: 16, cx: 0, cz: 10).enumerated() {
        m.part("Manor Spawn \(i + 1)", at: (p.0, 0.4, p.1), size: (1, 0.1, 1), color: "#000000", shape: .cylinder, visible: false)
        m.part("Chandelier \(i + 1)", at: (p.0, 4.6, p.1), size: (1.2, 0.5, 1.2), color: "#FDE68A", shape: .sphere, material: .neon, solid: false)
    }
    // Coin spots.
    m.markers("Coin Spot", points: (0..<14).map { _ in (r.range(-25, 25), r.range(-9, 29)) }, y: 0.3, color: "#000000",
              visible: false, behavior: .none)
    m.slab("Front Steps", x: 0, y: 0, z: -13, w: 8, h: 0.3, d: 2, color: "#57534E")

    // The lobby's mystery box and wardrobe.
    m.pad("Mystery Box", x: -8, z: -52, y: 0.4, size: 2.4, color: "#A855F7", tags: ["crate"])
    m.part("Mystery Box Chest", at: (-8, 1.2, -54.5), size: (1.6, 1.2, 1.2), color: "#7E22CE", material: .metal)
    m.pad("Weapon Rack", x: 8, z: -52, y: 0.4, size: 2.4, color: "#38BDF8", tags: ["inventory"])
    m.part("Weapon Rack Board", at: (8, 1.6, -54.5), size: (3, 2, 0.3), color: "#1E3A8A")

    // Map 2: the ski lodge, west of the manor.
    m.slab("Lodge Floor", x: -80, y: 0, z: 10, w: 50, h: 0.3, d: 40, color: "#A16207")
    m.walls(-80, 10, w: 50, d: 40, h: 5, y: 0.3, color: "#78350F", name: "Lodge Wall")
    m.slab("Lodge Roof", x: -80, y: 5.3, z: 10, w: 51, h: 0.5, d: 41, color: "#F8FAFC")
    for (x, z0, z1) in [(-88, -10, 0), (-88, 6, 30), (-70, -10, 14), (-70, 20, 30)] {
        m.slab("Lodge Inner Wall", x: Float(x), y: 0.3, z: Float(z0 + z1) / 2, w: 0.5, h: 4.7, d: Float(z1 - z0), color: "#92400E")
    }
    m.slab("Fireplace", x: -104, y: 0.3, z: 10, w: 1.5, h: 3, d: 5, color: "#57534E")
    m.part("Fireplace Fire", at: (-103.4, 1, 10), size: (0.6, 1, 3), color: "#F97316", material: .neon, solid: false)
    var lr = Seeded("lodge")
    for i in 0..<12 {
        m.slab("Lodge Furniture \(i + 1)", x: lr.range(-102, -58), y: 0.3, z: lr.range(-8, 28), w: lr.range(1.5, 3), h: lr.range(0.8, 2),
               d: lr.range(1, 2.5), color: lr.pick(["#7F1D1D", "#F8FAFC", "#1E3A8A", "#15803D"]))
    }
    for (i, p) in grid(3, 2, spacing: 14, cx: -80, cz: 10).enumerated() {
        m.part("Lodge Spawn \(i + 1)", at: (p.0, 0.4, p.1), size: (1, 0.1, 1), color: "#000000", shape: .cylinder, visible: false)
    }
    m.markers("Lodge Coin", points: (0..<14).map { _ in (lr.range(-102, -58), lr.range(-8, 28)) }, y: 0.3, color: "#000000",
              visible: false, behavior: .none)

    // Map 3: the laboratory, east of the manor.
    m.slab("Lab Floor", x: 80, y: 0, z: 10, w: 50, h: 0.3, d: 40, color: "#E5E7EB")
    m.walls(80, 10, w: 50, d: 40, h: 5, y: 0.3, color: "#94A3B8", name: "Lab Wall")
    m.slab("Lab Roof", x: 80, y: 5.3, z: 10, w: 51, h: 0.5, d: 41, color: "#475569")
    for (z, x0, x1) in [(0, 56, 70), (0, 76, 104), (20, 56, 84), (20, 90, 104)] {
        m.slab("Lab Inner Wall", x: Float(x0 + x1) / 2, y: 0.3, z: Float(z), w: Float(x1 - x0), h: 4.7, d: 0.5, color: "#CBD5E1")
    }
    for i in 0..<5 {
        m.part("Lab Tank \(i + 1)", at: (62 + Float(i) * 9, 1.8, 10), size: (1.8, 3, 1.8), color: "#22D3EE", shape: .cylinder,
               material: .glass, opacity: 0.6)
    }
    var ar = Seeded("lab")
    for i in 0..<10 {
        m.slab("Lab Desk \(i + 1)", x: ar.range(58, 102), y: 0.3, z: ar.range(-8, 28), w: ar.range(2, 3.5), h: 1, d: ar.range(1, 1.6),
               color: "#F8FAFC")
    }
    for (i, p) in [(62, 5), (80, 12), (98, 5), (62, 26), (80, 26), (98, 12)].enumerated() {
        m.part("Lab Spawn \(i + 1)", at: (Float(p.0), 0.4, Float(p.1)), size: (1, 0.1, 1), color: "#000000", shape: .cylinder, visible: false)
    }
    m.markers("Lab Coin", points: (0..<14).map { _ in (ar.range(58, 102), ar.range(-8, 28)) }, y: 0.3, color: "#000000",
              visible: false, behavior: .none)
}

// MARK: 10 99 Nights Camp

func nightsCamp(_ m: MapBuilder) {
    m.sky("#6FB7E8", "#D8EEFF", light: 0.7, ground: "#2F4A2A")
    m.ground(200, 200, color: "#3E5F32")
    m.part("Clearing", at: (0, 0.03, 0), size: (30, 0.06, 30), color: "#7A6A4A", shape: .cylinder, material: .matte)
    m.part("Campfire", at: (0, 0.5, 0), size: (3, 1, 3), color: "#F97316", shape: .cone, material: .neon, behavior: .trigger, tags: ["fire"])
    m.part("Fire Ring", at: (0, 0.15, 0), size: (4.2, 0.3, 4.2), color: "#57534E", shape: .cylinder)
    m.spawnRing(0, 0, radius: 7, count: 8, color: "#FDBA74")
    m.part("Cover Focus", at: (0, 1, -2), size: (54, 1, 1), color: "#000000", tags: ["yaw=35"], solid: false, visible: false)
    for p in ring(4, radius: 11, phase: 0.4) {
        m.part("Tent", at: (p.0, 1.2, p.1), size: (3.4, 2.4, 3.4), color: "#1D4ED8", shape: .cone, material: .matte)
    }
    m.shop("Workbench", x: 0, z: -14, w: 8, d: 6, color: "#6B4423", sign: "#FDE68A")
    // The forest: choppable trees, denser further out.
    var r = Seeded("forest")
    var n = 0
    for _ in 0..<70 {
        let a = r.range(0, 2 * .pi), d = r.range(22, 90)
        n += 1
        m.pine(cos(a) * d, sin(a) * d, height: r.range(5, 8), leaves: r.pick(["#1F4D2B", "#27613A", "#2F6B3F"]),
               name: "Tree \(n)")
    }
    m.markers("Monster Den", points: ring(6, radius: 85), color: "#000000", visible: false, behavior: .none)

    // Camp: craft table, cooking pot, a sleeping area.
    m.pad("Craft Table", x: 0, z: -12, size: 2.4, color: "#FDE68A", tags: ["craft"])
    m.part("Cooking Pot", at: (4.5, 0.6, 3), size: (1.4, 1.2, 1.4), color: "#374151", shape: .cylinder, material: .metal,
           behavior: .trigger, tags: ["cook"])
    // Things to gather: rocks, berry bushes and scrap piles.
    var g = Seeded("gather")
    for i in 0..<18 {
        let a = g.range(0, 2 * .pi), d = g.range(20, 80)
        m.part("Rock \(i + 1)", at: (cos(a) * d, 0.6, sin(a) * d), size: (g.range(1.4, 2.4), 1.2, g.range(1.4, 2.2)), color: "#78716C",
               shape: .sphere, material: .matte, tags: ["rock"])
    }
    for i in 0..<14 {
        let a = g.range(0, 2 * .pi), d = g.range(16, 70)
        m.part("Bush \(i + 1)", at: (cos(a) * d, 0.6, sin(a) * d), size: (1.6, 1.2, 1.6), color: "#166534", shape: .sphere,
               material: .matte, behavior: .trigger, tags: ["bush"])
        m.part("Bush \(i + 1) Berries", at: (cos(a) * d, 1.25, sin(a) * d), size: (0.9, 0.3, 0.9), color: "#DC2626", shape: .sphere,
               solid: false)
    }
    for i in 0..<10 {
        let a = g.range(0, 2 * .pi), d = g.range(35, 88)
        m.part("Scrap \(i + 1)", at: (cos(a) * d, 0.5, sin(a) * d), size: (1.8, 1, 1.4), color: "#71717A", material: .metal,
               behavior: .trigger, tags: ["scrap"])
    }
    m.markers("Chest Spot", points: (0..<10).map { _ in let a = g.range(0, 2 * .pi); let d = g.range(30, 90); return (cos(a) * d, sin(a) * d) },
              color: "#000000", visible: false, behavior: .none)
    // Four lost children, hiding far out in the forest.
    let kids: [(Float, Float)] = [(70, 60), (-75, 55), (-65, -70), (72, -66)]
    for (i, k) in kids.enumerated() {
        m.part("Kid Spot \(i + 1)", at: (k.0, 0.1, k.1), size: (1, 0.2, 1), color: "#000000", shape: .cylinder, solid: false, visible: false)
        m.part("Kid Hideout \(i + 1)", at: (k.0 + 2.5, 1, k.1), size: (3, 2, 3), color: "#57534E", shape: .cone, material: .matte)
    }
}


// MARK: 11 Lucky Kick Run

func luckyKick(_ m: MapBuilder) {
    m.ocean()
    m.ground(60, 40, color: "#E9D8A6", name: "Beach", x: 0, z: -80)
    m.part("Sea", at: (0, -0.3, -130), size: (200, 0.2, 80), color: "#1E7AD1", material: .glass, solid: false, opacity: 0.8)
    // The long hill up from the beach, in terraces.
    for i in 0..<8 {
        let z = -60 + Float(i) * 20
        m.slab("Terrace \(i + 1)", x: 0, y: Float(i) * 1.5 - 1, z: z, w: 40, h: 1, d: 20, color: i % 2 == 0 ? "#86C06C" : "#7AB35E",
               tags: ["ground"])
    }
    m.spawnRing(0, -80, radius: 5, count: 6, color: "#FDE047")
    // Lucky blocks near the beach.
    for (i, p) in grid(4, 2, spacing: 7, cx: 0, cz: -90).enumerated() {
        m.part("Lucky Block \(i + 1)", at: (p.0, 1, p.1), size: (1.6, 1.6, 1.6), color: "#FACC15", material: .neon,
               behavior: .trigger, tags: ["lucky"])
    }
    // Safe towers up the hill.
    for (i, x) in [-14, 14, -10, 12].enumerated() {
        let z = -40 + Float(i) * 30
        let base = Float(i + 1) * 1.5 + 0.5
        m.slab("Safe Tower \(i + 1)", x: Float(x), y: base - 1, z: z, w: 8, h: 10 + Float(i) * 2, d: 8, color: "#94A3B8", tags: ["tower"])
        m.pad("Safe Zone \(i + 1)", x: Float(x), z: z, y: base + 9 + Float(i) * 2, size: 6, color: "#22C55E", tags: ["safe"])
        m.stairs(Float(x) - 9, z, y: base - 1, steps: 10 + i * 2, rise: 1, run: 0.9, width: 3, color: "#CBD5E1", name: "Tower \(i + 1) Step")
    }
    m.pad("Bank", x: 0, z: 90, y: 11.5, size: 6, color: "#A855F7", tags: ["bank"])
    m.part("Wave Start", at: (0, 2, -120), size: (1, 1, 1), color: "#FFFFFF", visible: false)
    m.part("Wave End", at: (0, 2, 110), size: (1, 1, 1), color: "#FFFFFF", visible: false)
    for p in ring(6, radius: 26, cx: 0, cz: -80) { m.tree(p.0, p.1, height: 5, leaves: "#4ADE80") }
    // The upgrade shop on the beach, and the rebirth altar and collection board by the bank.
    m.pad("Upgrade Shop", x: -18, z: -78, size: 3, color: "#38BDF8", tags: ["shop"])
    m.part("Upgrade Shop Sign", at: (-18, 3.2, -80.5), size: (5, 1.1, 0.2), color: "#38BDF8", material: .neon, solid: false)
    m.part("Rebirth Altar", at: (10, 12.6, 94), size: (3, 1, 3), color: "#F472B6", shape: .cylinder, material: .neon,
           behavior: .trigger, tags: ["rebirth"])
    m.part("Collection Board", at: (-10, 13.5, 96), size: (5, 3, 0.3), color: "#FEF3C7", material: .matte, behavior: .trigger,
           tags: ["index"])
}

// MARK: 12 Battleground Legends

func battleground(_ m: MapBuilder) {
    m.sky("#94A3B8", "#E2E8F0", light: 0.75, ground: "#57534E")
    m.ground(160, 160, color: "#78716C", name: "Battlefield")
    m.spawnRing(0, 0, radius: 30, count: 10, color: "#F87171")
    var r = Seeded("battle")
    for i in 0..<18 {
        let x = r.range(-60, 60), z = r.range(-60, 60)
        m.slab("Rubble \(i + 1)", x: x, y: 0, z: z, w: r.range(2, 6), h: r.range(1, 5), d: r.range(2, 6),
               color: r.pick(["#A8A29E", "#78716C", "#57534E"]), tags: ["breakable"])
    }
    for p in ring(6, radius: 45, phase: 0.2) {
        m.pillar("Pillar", x: p.0, z: p.1, height: 12, radius: 1.5, color: "#D6D3D1", tags: ["breakable"])
    }
    m.slab("Center Stage", x: 0, y: 0, z: 0, w: 16, h: 0.8, d: 16, color: "#44403C")
    m.markers("Dummy Spot", points: ring(4, radius: 8, cx: 50, cz: 50), color: "#FDE047", visible: false, behavior: .none)
    m.slab("Training Floor", x: 50, y: 0, z: 50, w: 22, h: 0.3, d: 22, color: "#CA8A04")
}

// MARK: 13 Hotel 100 Doors

func hotelDoors(_ m: MapBuilder) {
    m.indoor(ground: "#000000")
    m.sky("#000000", "#050505", light: 0.35, showGround: false, fall: -30)
    m.slab("Lobby", x: 0, y: -0.3, z: -10, w: 14, h: 0.3, d: 14, color: "#5B3A29")
    // Lobby walls, with a doorway at +z into the hallway to room 1.
    m.slab("Lobby Wall", x: 0, y: 0, z: -17, w: 14.4, h: 5, d: 0.4, color: "#3F2A1F")
    m.slab("Lobby Wall", x: -7, y: 0, z: -10, w: 0.4, h: 5, d: 14, color: "#3F2A1F")
    m.slab("Lobby Wall", x: 7, y: 0, z: -10, w: 0.4, h: 5, d: 14, color: "#3F2A1F")
    m.slab("Lobby Wall", x: -4.5, y: 0, z: -3, w: 5, h: 5, d: 0.4, color: "#3F2A1F")
    m.slab("Lobby Wall", x: 4.5, y: 0, z: -3, w: 5, h: 5, d: 0.4, color: "#3F2A1F")
    m.slab("Hallway", x: 0, y: -0.3, z: 0, w: 4, h: 0.3, d: 6.2, color: "#5B3A29")
    m.slab("Hallway Wall", x: -2.2, y: 0, z: 0, w: 0.4, h: 4, d: 6, color: "#3F2A1F")
    m.slab("Hallway Wall", x: 2.2, y: 0, z: 0, w: 0.4, h: 4, d: 6, color: "#3F2A1F")
    m.spawnRing(0, -12, radius: 3, count: 6, color: "#FDE68A")
    m.part("Reception", at: (0, 0.6, -15), size: (6, 1.2, 1.2), color: "#7C2D12")
    // The cover: the lobby and the first rooms, seen from behind the desk.
    m.part("Cover Focus", at: (0, 1, 6), size: (40, 1, 1), color: "#000000", tags: ["yaw=200"], solid: false, visible: false)
    let roomLength: Float = 12
    var r = Seeded("hotel")
    for n in 1...100 {
        let z = Float(n) * roomLength - 3
        let wall = r.pick(["#4A3728", "#3B2F2F", "#2F3B32", "#3A3446"])
        m.slab("Room \(n) Floor", x: 0, y: -0.3, z: z, w: 10, h: 0.3, d: roomLength, color: n % 2 == 0 ? "#6B4F3A" : "#5E4432")
        m.slab("Room \(n) Wall L", x: -5, y: 0, z: z, w: 0.4, h: 4, d: roomLength, color: wall)
        m.slab("Room \(n) Wall R", x: 5, y: 0, z: z, w: 0.4, h: 4, d: roomLength, color: wall)
        m.slab("Room \(n) Ceiling", x: 0, y: 4, z: z, w: 10.4, h: 0.3, d: roomLength, color: "#1C1917")
        // The doorway at the far end, and the door in it.
        let dz = z + roomLength / 2
        m.slab("Room \(n) Frame L", x: -3.5, y: 0, z: dz, w: 3, h: 4, d: 0.4, color: wall)
        m.slab("Room \(n) Frame R", x: 3.5, y: 0, z: dz, w: 3, h: 4, d: 0.4, color: wall)
        m.slab("Room \(n) Frame Top", x: 0, y: 2.8, z: dz, w: 4, h: 1.2, d: 0.4, color: wall)
        m.slab("Door \(n)", x: 0, y: 0, z: dz, w: 4, h: 2.8, d: 0.3, color: n % 10 == 0 ? "#B45309" : "#78350F", tags: ["door"])
        m.part("Door \(n) Number", at: (0, 3.1, dz - 0.25), size: (0.8, 0.4, 0.05), color: "#FDE68A", material: .neon, solid: false)
        m.part("Room \(n) Lamp", at: (0, 3.7, z), size: (0.8, 0.3, 0.8), color: "#FFE9A8", shape: .cylinder, material: .neon, tags: ["lamp"],
               solid: false)
        // A closet to hide in, on alternate sides.
        let side: Float = n % 2 == 0 ? -3.8 : 3.8
        m.part("Closet \(n)", at: (side, 1.25, z - 2), size: (1.6, 2.5, 1.6), color: "#292524", behavior: .trigger, tags: ["closet"],
               solid: false, opacity: 0.92)
        if n % 5 == 0 && n != 50 {
            m.part("Key \(n)", at: (-side * 0.6, 0.8, z + 1), size: (0.5, 0.2, 0.9), color: "#FACC15", material: .neon,
                   behavior: .trigger, tags: ["key"])
        }
        // Two drawers to search in every room.
        m.part("Room \(n) Drawer A", at: (-side * 0.9, 0.5, z + 3), size: (1.4, 1, 0.9), color: "#57534E", behavior: .trigger,
               tags: ["drawer"])
        m.part("Room \(n) Drawer B", at: (side * 0.9, 0.5, z + 1.5), size: (1.4, 1, 0.9), color: "#57534E", behavior: .trigger,
               tags: ["drawer"])
    }
    // Room 50 is the library: shelves, and four books that each hide a digit of the code for door 50.
    let library = 50 * roomLength - 3
    for (i, x) in [-4.2, 4.2].enumerated() {
        m.slab("Bookshelf \(i + 1)", x: Float(x), y: 0, z: library, w: 1, h: 3.4, d: 9, color: "#451A03")
    }
    for i in 0..<4 {
        let bx: Float = i % 2 == 0 ? -3.4 : 3.4
        m.part("Book \(i + 1)", at: (bx, 1 + Float(i / 2) * 1.2, library - 3 + Float(i) * 2), size: (0.3, 0.8, 0.6),
               color: ["#DC2626", "#2563EB", "#16A34A", "#CA8A04"][i], behavior: .trigger, tags: ["book"])
    }
    // The shop in the lobby, before the first door.
    m.pad("Lobby Shop", x: 4, z: -6, size: 2.4, color: "#FACC15", tags: ["shop"])
    m.slab("Exit", x: 0, y: -0.3, z: 101 * roomLength, w: 20, h: 0.3, d: 20, color: "#FDE68A")
    m.pad("Exit Light", x: 0, z: 101 * roomLength, size: 5, color: "#FFFFFF", tags: ["exit"])
}

// MARK: 14 Pet Coin Frenzy

func petCoin(_ m: MapBuilder) {
    m.sky("#7DD3FC", "#FDF4FF", light: 0.8, ground: "#86EFAC")
    // Eight worlds in a row, each behind a gate that costs coins.
    let zones: [(String, String, Float)] = [("Spawn Meadow", "#86EFAC", 0), ("Candy Land", "#F9A8D4", 60),
                                            ("Frost Peak", "#E0F2FE", 120), ("Lava Isle", "#F97316", 180), ("Galaxy", "#312E81", 240),
                                            ("Toy Town", "#FDE68A", 300), ("Crystal Cave", "#67E8F9", 360), ("Rainbow Road", "#F0ABFC", 420)]
    for (i, z) in zones.enumerated() {
        m.ground(56, 56, color: z.1, name: "\(z.0) Ground", z: z.2)
        if i > 0 {
            m.part("Gate \(i + 1)", at: (0, 3, z.2 - 29), size: (56, 6, 1), color: "#A855F7", material: .glass,
                   behavior: .trigger, tags: ["gate"], solid: false, opacity: 0.5)
        }
        var r = Seeded("coins\(i)")
        for k in 0..<14 {
            let kind = k == 13 ? 2 : (k >= 10 ? 1 : 0)   // 0 coins, 1 chest, 2 giant chest
            let size: (Float, Float, Float) = kind == 2 ? (3.4, 3, 3.4) : (kind == 1 ? (2, 1.6, 1.4) : (1.4, 1.2, 1.4))
            m.part("\(z.0) Pile \(k + 1)", at: (r.range(-22, 22), size.1 / 2, z.2 + r.range(-20, 20)), size: size,
                   color: kind == 2 ? "#F59E0B" : (kind == 1 ? "#B45309" : "#FACC15"),
                   shape: kind == 0 ? .cylinder : .box, material: .metal, tags: ["pile", "zone\(i + 1)", "kind\(kind)"])
        }
        m.slab("\(z.0) Egg Stand", x: 20, y: 0, z: z.2 + 22, w: 4, h: 1, d: 4, color: "#FFFFFF")
        m.part("Egg \(i + 1)", at: (20, 2, z.2 + 22), size: (1.6, 2, 1.6), color: z.1, shape: .sphere, material: .neon,
               behavior: .trigger, tags: ["egg"])
        m.slab("\(z.0) Golden Stand", x: -20, y: 0, z: z.2 + 22, w: 4, h: 1, d: 4, color: "#FDE68A")
    }
    m.spawnRing(0, -10, radius: 4, count: 6)
    // Machines in the meadow: gold, rainbow, fuse, and the trading booth.
    let machines: [(String, String, Float, String)] = [("Golden Machine", "#FACC15", -18, "golden"), ("Rainbow Machine", "#EC4899", -10, "rainbow"),
                                                       ("Fuse Machine", "#8B5CF6", 10, "fuse"), ("Trade Booth", "#22C55E", 18, "trade")]
    for mc in machines {
        m.slab("\(mc.0) Body", x: mc.2, y: 0, z: -22, w: 4, h: 3, d: 3, color: mc.1, material: .metal)
        m.pad(mc.0, x: mc.2, z: -19, size: 2.6, color: mc.1, tags: [mc.3])
    }
    m.pad("Upgrade Shop", x: 0, z: -24, size: 3, color: "#38BDF8", tags: ["shop"])
}

// MARK: 15 Tower of Chaos

func towerChaos(_ m: MapBuilder) {
    m.sky("#0F172A", "#475569", light: 0.7, ground: "#1E293B", fall: -20)
    m.ground(60, 60, color: "#334155", name: "Base")
    m.spawnRing(0, 0, radius: 4, count: 8, color: "#F472B6")
    m.part("Tower Core", at: (0, 36, 0), size: (3, 72, 3), color: "#1E293B", shape: .cylinder, material: .metal)
    for p in ring(8, radius: 26) { m.pillar("Base Light", x: p.0, z: p.1, height: 3, radius: 0.4, color: "#F472B6", material: .neon) }
}

// MARK: 16 Crystal Wars

func crystalWars(_ m: MapBuilder) {
    m.sky("#60A5FA", "#E0F2FE", light: 0.8, showGround: false, fall: -25)
    // Four team islands 56 m out, each with a crystal on its far side.
    // Local axes: u points away from the middle, v across the island.
    let teams: [(String, String, String, Float, Float)] = [("Red", "#EF4444", "#FCA5A5", 0, -1), ("Blue", "#3B82F6", "#93C5FD", 1, 0),
                                                           ("Green", "#22C55E", "#86EFAC", 0, 1), ("Yellow", "#EAB308", "#FDE047", -1, 0)]
    for t in teams {
        let ox = t.3, oz = t.4, px = -oz, pz = ox
        func at(_ u: Float, _ v: Float) -> (Float, Float) { (ox * (56 + u) + px * v, oz * (56 + u) + pz * v) }
        let c = at(0, 0)
        m.slab("\(t.0) Island", x: c.0, y: -2, z: c.1, w: 22, h: 2, d: 22, color: "#6B8E4E", tags: ["island", t.0.lowercased()])
        m.slab("\(t.0) Island Rock", x: c.0, y: -6, z: c.1, w: 16, h: 4, d: 16, color: "#57534E")
        m.slab("\(t.0) Island Root", x: c.0, y: -9, z: c.1, w: 8, h: 3, d: 8, color: "#44403C")
        // The crystal, on a pedestal, inside a ring of wool.
        let cr = at(8, 0)
        m.slab("\(t.0) Pedestal", x: cr.0, y: 0, z: cr.1, w: 2, h: 0.6, d: 2, color: "#E5E7EB", material: .metal)
        m.part("\(t.0) Crystal", at: (cr.0, 1.9, cr.1), size: (1.4, 2.6, 1.4), color: t.1, shape: .cone, material: .glass,
               tags: ["crystal", t.0.lowercased()])
        for (du, dv) in [(-2, -2), (0, -2), (2, -2), (-2, 0), (2, 0), (-2, 2), (0, 2), (2, 2)] as [(Float, Float)] {
            let w = at(8 + du, dv)
            m.slab("\(t.0) Guard Wool", x: w.0, y: 0, z: w.1, w: 2, h: 1, d: 2, color: t.2, tags: ["placed", "wool"])
        }
        let g = at(1, 7)
        m.pad("\(t.0) Generator", x: g.0, z: g.1, size: 3.2, color: "#D1D5DB", tags: ["generator", "team_gen", t.0.lowercased()])
        m.slab("\(t.0) Generator Frame", x: at(1, 9.2).0, y: 0, z: at(1, 9.2).1, w: 1, h: 1.6, d: 1, color: "#9CA3AF", material: .metal)
        let shop = at(-1, -7)
        m.pad("\(t.0) Item Shop", x: shop.0, z: shop.1, size: 2.6, color: t.1, tags: ["item_shop", t.0.lowercased()])
        let keeper = at(-1, -9.4)
        m.pillar("\(t.0) Shopkeeper", x: keeper.0, z: keeper.1, height: 1.6, radius: 0.45, color: "#F59E0B")
        m.part("\(t.0) Shopkeeper Head", at: (keeper.0, 1.95, keeper.1), size: (0.7, 0.7, 0.7), color: "#FDE68A", shape: .sphere)
        let up = at(4, -7)
        m.pad("\(t.0) Upgrade Shop", x: up.0, z: up.1, size: 2.6, color: "#A78BFA", tags: ["upgrade_shop", t.0.lowercased()])
        let smith = at(4, -9.4)
        m.pillar("\(t.0) Smith", x: smith.0, z: smith.1, height: 1.6, radius: 0.45, color: "#7C3AED")
        m.part("\(t.0) Smith Head", at: (smith.0, 1.95, smith.1), size: (0.7, 0.7, 0.7), color: "#FDE68A", shape: .sphere)
        for v: Float in [-2, 2] {
            let s = at(-4, v)
            m.spawn(s.0, s.1, name: "\(t.0) Spawn \(v < 0 ? 1 : 2)", color: t.1)
        }
        for v: Float in [-10, 10] {
            let b = at(-10, v)
            m.pillar("\(t.0) Banner Pole", x: b.0, z: b.1, height: 5, radius: 0.15, color: "#E5E7EB")
            m.part("\(t.0) Banner", at: (b.0 + px * 0.9, 4.2, b.1 + pz * 0.9), size: (abs(px) * 1.6 + 0.1, 1.2, abs(pz) * 1.6 + 0.1),
                   color: t.1, material: .neon, solid: false)
        }
        m.tree(at(6, 9).0, at(6, 9).1, height: 3.5, leaves: t.2)
        // A short wool bridge toward the middle; the rest is built.
        for k in 1...3 {
            let b = at(-11 - Float(k) * 2 + 1, 0)
            m.slab("\(t.0) Bridge", x: b.0, y: -1, z: b.1, w: 2, h: 1, d: 2, color: t.2, tags: ["placed", "wool"])
        }
    }
    // Diamond islands on the diagonals.
    for (i, d) in [(38, -38), (38, 38), (-38, 38), (-38, -38)].enumerated() {
        let x = Float(d.0), z = Float(d.1)
        m.slab("Diamond Island \(i + 1)", x: x, y: -2, z: z, w: 9, h: 2, d: 9, color: "#78716C")
        m.slab("Diamond Island Rock \(i + 1)", x: x, y: -5, z: z, w: 6, h: 3, d: 6, color: "#57534E")
        m.pad("Diamond Generator \(i + 1)", x: x, z: z, size: 3, color: "#22D3EE", tags: ["generator", "diamond_gen"])
        m.part("Diamond Crystal \(i + 1)", at: (x, 3.2, z), size: (0.8, 0.8, 0.8), color: "#67E8F9", shape: .sphere, material: .neon, solid: false)
    }
    // The middle: two emerald generators and some cover.
    m.slab("Center Island", x: 0, y: -2, z: 0, w: 20, h: 2, d: 20, color: "#8B7355")
    m.slab("Center Rock", x: 0, y: -7, z: 0, w: 14, h: 5, d: 14, color: "#57534E")
    m.slab("Center Stage", x: 0, y: 0, z: 0, w: 8, h: 1, d: 8, color: "#A8A29E")
    for (i, x) in [-2, 2].enumerated() {
        m.pad("Emerald Generator \(i + 1)", x: Float(x), z: 0, y: 1, size: 2.6, color: "#10B981", tags: ["generator", "emerald_gen"])
    }
    for p in [(-7, -7), (7, -7), (7, 7), (-7, 7)] {
        m.pillar("Center Pillar", x: Float(p.0), z: Float(p.1), height: 3, radius: 0.7, color: "#D6D3D1")
    }
    m.part("Center Beacon", at: (0, 6, 0), size: (1, 1, 1), color: "#34D399", shape: .sphere, material: .neon, solid: false)
}

// MARK: 17 Slime Roll

func slimeRoll(_ m: MapBuilder) {
    m.sky("#A5F3FC", "#F0FDFA", light: 0.8, ground: "#99F6E4")
    m.ground(300, 300, color: "#5EEAD4")
    // The hub: the roll altar in the middle, shops around it.
    m.part("Roll Altar", at: (0, 0.5, 0), size: (8, 1, 8), color: "#FFFFFF", shape: .cylinder, material: .metal)
    m.part("Roll Crystal", at: (0, 3, 0), size: (2, 3, 2), color: "#A855F7", shape: .sphere, material: .neon, solid: false)
    m.spawnRing(0, 0, radius: 9, count: 8, color: "#C4B5FD")
    let counters: [(String, Float, Float, String, String)] = [
        ("Upgrade Shop", 17, 0, "#F59E0B", "upgrade_shop"), ("Potion Shop", -17, 0, "#A855F7", "potion_shop"),
        ("Craft Table", 12, -12, "#92400E", "craft"), ("Fuse Machine", -12, -12, "#0EA5E9", "fuse"),
        ("Index Board", 0, -17, "#22C55E", "index_board"), ("Bag Chest", 12, 12, "#78350F", "bag_chest")
    ]
    for c in counters {
        m.pad(c.0, x: c.1, z: c.2, size: 3, color: c.3, tags: [c.4])
        m.slab("\(c.0) Stand", x: c.1 * 1.18, y: 0, z: c.2 * 1.18, w: 3, h: 1.2, d: 3, color: c.3)
        m.part("\(c.0) Sign", at: (c.1 * 1.18, 2.4, c.2 * 1.18), size: (2.6, 0.8, 0.2), color: "#FFFFFF", material: .neon, solid: false,
               rotation: (0, atan2(c.1, c.2) * 180 / .pi, 0))
    }
    // Pads that take you to each zone (the grass field is just a walk away).
    m.pad("Desert Pad", x: -12, z: 12, size: 3, color: "#FBBF24", tags: ["zone_pad", "desert"])
    m.pad("Volcano Pad", x: -6, z: 16, size: 3, color: "#EF4444", tags: ["zone_pad", "volcano"])
    m.pad("Sky Pad", x: 6, z: 16, size: 3, color: "#E0F2FE", tags: ["zone_pad", "sky"])
    for p in ring(12, radius: 30) { m.tree(p.0, p.1, height: 4, leaves: "#2DD4BF") }

    // Zones: grass (walk north), desert (east), volcano (west), sky (a floating island high up).
    let zones: [(String, Float, Float, Float, String, String)] = [
        ("Grass", 0, 60, 0, "#65A30D", "#3F6212"), ("Desert", 110, 0, 0, "#FCD34D", "#B45309"),
        ("Volcano", -110, 0, 0, "#44403C", "#7F1D1D"), ("Sky", 0, -110, 40, "#F0F9FF", "#BAE6FD")
    ]
    for z in zones {
        let y = z.3
        if y > 0 {
            m.slab("\(z.0) Field", x: z.1, y: y - 2, z: z.2, w: 56, h: 2, d: 44, color: z.4)
        } else {
            m.slab("\(z.0) Field", x: z.1, y: 0, z: z.2, w: 56, h: 0.3, d: 44, color: z.4)
        }
        let floorY: Float = y > 0 ? y : 0.3
        if z.0 == "Grass" {
            // Open toward the hub, so you can just walk in.
            m.slab("Grass Fence", x: z.1, y: floorY, z: z.2 + 22, w: 57, h: 1.2, d: 1, color: z.5)
        } else {
            m.walls(z.1, z.2, w: 56, d: 44, h: 4, y: floorY, color: z.5, name: "\(z.0) Fence")
        }
        m.markers("\(z.0) Spot", points: grid(4, 2, spacing: 11, cx: z.1, cz: z.2), y: floorY, color: "#000000", visible: false, behavior: .none)
        m.markers("\(z.0) Boss Spot", points: [(z.1, z.2 + 14)], y: floorY, color: "#000000", visible: false, behavior: .none)
        if z.0 != "Grass" {
            // Not a real spawn: you only arrive here through the pads.
            m.part("\(z.0) Spawn", at: (z.1, floorY + 0.1, z.2 - 18), size: (2.4, 0.2, 2.4), color: z.5, shape: .cylinder, material: .neon)
            m.pad("\(z.0) Home Pad", x: z.1 + 6, z: z.2 - 18, y: floorY, size: 3, color: "#C4B5FD", tags: ["home_pad"])
        }
    }
    m.part("Volcano Mountain", at: (-110, 8, 26), size: (20, 16, 10), color: "#57534E", shape: .cone)
    m.part("Volcano Lava", at: (-110, 16.5, 26), size: (5, 1, 5), color: "#F97316", shape: .cylinder, material: .neon, solid: false)
    for i in 0..<5 { m.part("Cactus", at: (90 + Float(i) * 10, 1.5, -18), size: (0.8, 3, 0.8), color: "#15803D", shape: .cylinder) }
    for p in ring(6, radius: 30, cx: 0, cz: -110) {
        m.part("Cloud", at: (p.0, 38, p.1), size: (8, 2.5, 5), color: "#FFFFFF", shape: .sphere, material: .matte, solid: false)
    }
}

// MARK: 18 Hero Tower Defense

func heroTD(_ m: MapBuilder) {
    m.day(ground: "#4D7C0F")
    m.ground(160, 160, color: "#65A30D")
    // The path: a zig-zag of waypoints from the portal to the castle.
    let points: [(Float, Float)] = [(-50, -45), (-50, -10), (-20, -10), (-20, -40), (20, -40), (20, 0), (-30, 0), (-30, 35), (40, 35), (40, 50)]
    for i in 0..<(points.count - 1) {
        let a = points[i], b = points[i + 1]
        let cx = (a.0 + b.0) / 2, cz = (a.1 + b.1) / 2
        let w = abs(a.0 - b.0) + 6, d = abs(a.1 - b.1) + 6
        m.part("Path \(i + 1)", at: (cx, 0.02, cz), size: (w, 0.04, d), color: "#D6B97A", material: .matte)
    }
    m.markers("Waypoint", points: points, color: "#000000", visible: false, behavior: .none)
    m.part("Portal", at: (-50, 3, -50), size: (6, 6, 1), color: "#7C3AED", material: .neon, solid: false)
    m.part("Portal Frame", at: (-50, 3, -50.8), size: (7.4, 7.4, 0.6), color: "#1E1B4B", material: .metal)
    m.slab("Castle", x: 40, y: 0, z: 56, w: 14, h: 6, d: 6, color: "#CBD5E1")
    m.slab("Castle Gate", x: 40, y: 0, z: 52.8, w: 4, h: 4, d: 0.4, color: "#78350F")
    for x in [34, 46] { m.pillar("Castle Tower", x: Float(x), z: 56, height: 9, radius: 1.6, color: "#94A3B8") }
    m.part("Castle Flag", at: (40, 8, 56), size: (2.4, 1.4, 0.1), color: "#2563EB", material: .neon, solid: false)
    // Places to stand a hero, alongside the path.
    let spots: [(Float, Float)] = [(-43, -30), (-57, -20), (-35, -18), (-12, -25), (-27, -47), (0, -47), (13, -20), (27, -20),
                                   (5, 7), (-15, 7), (-37, 17), (-23, 28), (0, 28), (20, 42), (33, 28), (47, 42),
                                   (-57, -35), (-43, -3), (-27, -30), (0, -33), (27, -5), (-10, -7), (-37, 42), (10, 42),
                                   (-23, 17), (27, 28), (-13, -47), (13, -47)]
    for (i, p) in spots.enumerated() {
        m.part("Tower Spot \(i + 1)", at: (p.0, 0.15, p.1), size: (3.2, 0.3, 3.2), color: "#A3A3A3", shape: .cylinder,
               material: .metal, behavior: .trigger, tags: ["spot"])
    }
    m.spawnRing(20, 55, radius: 3, count: 6, color: "#60A5FA")
    // The lobby beside the castle: vote for a difficulty, unlock heroes.
    let votes: [(String, String, String)] = [("Easy", "#22C55E", "easy"), ("Normal", "#3B82F6", "normal"),
                                             ("Hard", "#EF4444", "hard"), ("Endless", "#A855F7", "endless")]
    for (i, v) in votes.enumerated() {
        m.pad("Vote \(v.0)", x: 6 + Float(i) * 4.5, z: 64, size: 3, color: v.1, tags: ["vote", v.2])
    }
    m.pad("Hero Hall", x: 30, z: 64, size: 3.4, color: "#F59E0B", tags: ["hero_hall"])
    m.slab("Hero Hall Stand", x: 30, y: 0, z: 67.5, w: 5, h: 2.4, d: 1.2, color: "#92400E")
    m.part("Hero Hall Sign", at: (30, 3, 67.5), size: (4.6, 1, 0.2), color: "#FDE68A", material: .neon, solid: false)
    for p in ring(14, radius: 72) { m.tree(p.0, p.1, height: 4.5) }
    for p in [(-60, 20), (55, -30), (60, 10), (-5, 60)] { m.rock(Float(p.0), Float(p.1), size: 2.4) }
}

// MARK: 19 Domain Clash

func domainClash(_ m: MapBuilder) {
    m.sky("#1E1B4B", "#6D28D9", light: 0.6, ground: "#1F1B2E")
    m.ground(160, 160, color: "#2E2A3F", name: "Arena")
    m.spawnRing(0, 0, radius: 26, count: 10, color: "#C084FC")
    var r = Seeded("domain")
    for i in 0..<12 {
        let a = r.range(0, 2 * .pi), d = r.range(15, 55)
        m.pillar("Shrine Pillar \(i + 1)", x: cos(a) * d, z: sin(a) * d, height: r.range(6, 12), radius: 1.2,
                 color: r.pick(["#7F1D1D", "#1F2937", "#4C1D95"]), tags: ["breakable"])
    }
    for i in 0..<8 {
        m.slab("Wall Chunk \(i + 1)", x: r.range(-50, 50), y: 0, z: r.range(-50, 50), w: r.range(4, 8), h: 3, d: 1.2,
               color: "#57534E", tags: ["breakable"])
    }
    // The shrine in the middle, where special-grade curses appear.
    m.part("Center Seal", at: (0, 0.05, 0), size: (12, 0.1, 12), color: "#7C3AED", shape: .cylinder, material: .neon, solid: false)
    m.markers("Boss Spot", points: [(0, 0)], color: "#000000", visible: false, behavior: .none)
    // The torii and the style shrine behind it.
    m.part("Torii", at: (0, 5, -60), size: (14, 1, 1.2), color: "#DC2626")
    m.pillar("Torii Leg", x: -5.5, z: -60, height: 5, radius: 0.5, color: "#DC2626")
    m.pillar("Torii Leg", x: 5.5, z: -60, height: 5, radius: 0.5, color: "#DC2626")
    m.slab("Shrine Floor", x: 0, y: 0, z: -68, w: 16, h: 0.4, d: 10, color: "#78350F")
    m.pad("Style Shrine", x: 0, z: -68, y: 0.4, size: 3.4, color: "#E9D5FF", tags: ["style_shrine"])
    m.part("Shrine Roof", at: (0, 5, -70), size: (14, 0.6, 8), color: "#1F2937")
    // The dojo in one corner: training dummies that stand still.
    m.slab("Dojo Floor", x: 58, y: 0, z: 58, w: 20, h: 0.3, d: 20, color: "#A16207")
    for p in [(48.5, 48.5), (67.5, 48.5), (48.5, 67.5), (67.5, 67.5)] as [(Float, Float)] {
        m.pillar("Dojo Post", x: p.0, z: p.1, y: 0.3, height: 2.4, radius: 0.35, color: "#78350F")
    }
    m.markers("Dummy Spot", points: [(52, 58), (58, 58), (64, 58)], y: 0.3, color: "#000000", visible: false, behavior: .none)
    m.pad("Dojo Mat", x: 58, z: 51, y: 0.3, size: 3, color: "#FDE68A", tags: ["dojo"])
    // The title board in another.
    m.slab("Title Board", x: -58, y: 0, z: 62, w: 6, h: 3, d: 0.6, color: "#312E81")
    m.pad("Title Pad", x: -58, z: 58, size: 3, color: "#FBBF24", tags: ["title_board"])
    for p in ring(8, radius: 76) { m.part("Cursed Lantern", at: (p.0, 2, p.1), size: (0.8, 1.2, 0.8), color: "#A855F7", material: .neon, solid: false) }
}

// MARK: 20 Tsunami Dash

func tsunamiDash(_ m: MapBuilder) {
    m.sky("#38BDF8", "#E0F2FE", light: 0.8, showGround: false, fall: -20)

    // The lobby, behind the three starting lines: vote pads, the meme shop
    // and the skin stand. Spawns are only here.
    m.slab("Lobby", x: 0, y: -1, z: -70, w: 60, h: 1, d: 24, color: "#FDE68A")
    m.spawnRing(0, -72, radius: 4, count: 8, color: "#FB923C")
    let votes: [(String, Float, String)] = [("Beach", -12, "#38BDF8"), ("City", 0, "#94A3B8"), ("Volcano", 12, "#EF4444")]
    for v in votes {
        m.pad("Vote \(v.0)", x: v.1, z: -62, size: 3.4, color: v.2, tags: ["vote", v.0.lowercased()])
        m.part("Vote \(v.0) Sign", at: (v.1, 3, -60), size: (4, 1.2, 0.2), color: v.2, material: .neon, solid: false)
    }
    m.pad("Meme Shop", x: -22, z: -74, size: 3.4, color: "#FACC15", tags: ["meme_shop"])
    m.slab("Meme Shop Stand", x: -22, y: 0, z: -78, w: 5, h: 2, d: 1.2, color: "#CA8A04")
    m.pad("Skin Stand", x: 22, z: -74, size: 3.4, color: "#F472B6", tags: ["skin_stand"])
    m.slab("Skin Stand Wall", x: 22, y: 0, z: -78, w: 5, h: 2, d: 1.2, color: "#DB2777")
    m.part("Record Board", at: (0, 3, -82), size: (14, 4, 0.4), color: "#1E293B")

    // Three courses side by side, each 300 m along +z from z = 0.
    let courses: [(String, Float)] = [("Beach", 0), ("City", 90), ("Volcano", -90)]
    for (index, course) in courses.enumerated() {
        let cx = course.1
        let n = index + 1
        var r = Seeded("dash-\(course.0)")
        m.slab("Course \(n) Start Area", x: cx, y: -1, z: -10, w: 24, h: 1, d: 20, color: "#FDE68A")
        m.markers("Course \(n) Start", points: [(cx - 4, -8), (cx, -8), (cx + 4, -8), (cx - 2, -12), (cx + 2, -12), (cx - 6, -12), (cx + 6, -12), (cx, -4)],
                  color: "#000000", visible: false, behavior: .none)
        m.part("Course \(n) Wave Start", at: (cx, 3, -30), size: (1, 1, 1), color: "#FFFFFF", visible: false)
        for i in 0..<15 {
            let z = Float(i) * 20 + 10
            let gap = i % 3 == 2
            // The city climbs and drops between rooftops; the others are flat.
            let y: Float = course.0 == "City" ? [0, 0.5, 1, 1, 0.5, 1.5, 1.5, 1, 0.5, 0, 1, 1.5, 1, 0.5, 0][i] : 0
            let colors: [String]
            switch course.0 {
            case "City": colors = ["#94A3B8", "#64748B"]
            case "Volcano": colors = ["#44403C", "#57534E"]
            default: colors = ["#F472B6", "#A78BFA"]
            }
            m.slab("Course \(n) Track \(i + 1)", x: cx, y: y - 1, z: z, w: 14, h: 1, d: gap ? 12 : 20, color: colors[i % 2], tags: ["track"])
            if gap {
                m.part("Course \(n) Jump Pad \(i + 1)", at: (cx, y + 0.1, z + 4), size: (4, 0.2, 2), color: "#22C55E",
                       material: .neon, behavior: .bounce)
            }
            // Obstacles to weave through.
            for k in 0..<2 {
                m.slab("Course \(n) Block \(i + 1)-\(k + 1)", x: cx + r.range(-5, 5), y: y, z: z + r.range(-7, 5),
                       w: r.range(1.5, 3), h: r.range(1, 2.2), d: 1, color: course.0 == "Volcano" ? "#1C1917" : "#FFFFFF")
            }
            m.part("Course \(n) Meme \(i + 1)", at: (cx + r.range(-5, 5), y + 1, z), size: (0.9, 0.9, 0.9),
                   color: r.pick(["#FACC15", "#34D399", "#F87171"]), shape: .sphere, material: .neon, behavior: .trigger,
                   tags: ["meme"], solid: false)
            // A speed strip on every fourth section.
            if i % 4 == 1 {
                m.part("Course \(n) Boost \(i + 1)", at: (cx + r.range(-3, 3), y + 0.06, z - 5), size: (3, 0.12, 3), color: "#F97316",
                       material: .neon, behavior: .trigger, tags: ["boost"], solid: false)
            }
            // Power-ups every third section.
            if i % 3 == 0, i > 0 {
                let kinds = ["speed", "shield", "jump", "freeze", "magnet"]
                let kind = kinds[(i / 3 + index) % kinds.count]
                m.part("Course \(n) Power \(i + 1)", at: (cx + r.range(-4, 4), y + 1.2, z + 6), size: (1.2, 1.2, 1.2),
                       color: "#E879F9", shape: .box, material: .neon, behavior: .trigger, tags: ["power", kind], solid: false,
                       rotation: (45, 45, 0))
            }
            // Course hazards: blinking lava on the volcano, gates in the city.
            if course.0 == "Volcano", !gap, i > 0 {
                m.part("Course \(n) Lava \(i + 1)", at: (cx, y + 0.06, z + 2), size: (14, 0.12, 2.4), color: "#EA580C",
                       material: .neon, behavior: .hazard, tags: ["lava_strip"], solid: false)
            }
            if course.0 == "City", !gap, i % 2 == 1 {
                m.slab("Course \(n) Gate \(i + 1)", x: cx + (i % 4 == 1 ? -3.5 : 3.5), y: y, z: z + 6, w: 7, h: 2.6, d: 0.6,
                       color: "#DC2626", tags: ["gate"])
            }
        }
        m.slab("Course \(n) Finish", x: cx, y: -1, z: 320, w: 24, h: 1, d: 16, color: "#22C55E")
        m.pad("Course \(n) Finish Line", x: cx, z: 316, size: 12, color: "#FFFFFF", tags: ["finish", "course\(n)"], shape: .box)
    }
    m.part("Volcano Cone", at: (-90, 20, 345), size: (40, 40, 20), color: "#57534E", shape: .cone)
    for i in 0..<6 {
        m.part("City Tower \(i + 1)", at: (Float(70 + (i % 2) * 40), 15, Float(40 + i * 45)), size: (10, 30, 10), color: "#475569")
    }
}
