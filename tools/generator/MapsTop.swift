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
    m.ground(140, 140, color: "#B8E6A0")
    m.part("Plaza", at: (0, 0.03, 0), size: (26, 0.06, 26), color: "#FDE2E4", shape: .cylinder, material: .matte)
    m.spawnRing(0, 0, radius: 6, count: 8, color: "#F9A8D4")

    // The nursery sells eggs.
    m.house("Nursery", x: 0, z: -34, w: 22, d: 12, h: 4.5, wall: "#FBCFE8", roof: "#DB2777", floor: "#FFF1F2", tags: ["nursery"])
    let eggs: [(String, String, Float)] = [("Egg Common", "#F5F5F4", -6), ("Egg Rare", "#60A5FA", 0), ("Egg Legendary", "#FACC15", 6)]
    for e in eggs {
        m.slab("\(e.0) Stand", x: e.2, y: 0, z: -37, w: 2.4, h: 0.8, d: 2.4, color: "#FFFFFF")
        m.part(e.0, at: (e.2, 1.6, -37), size: (1.3, 1.7, 1.3), color: e.1, shape: .sphere, material: .plastic,
               behavior: .trigger, tags: ["egg"])
    }

    // Where pets get looked after.
    let needs: [(String, String, Float, Float, String)] = [
        ("Food Stand", "#F97316", -32, 8, "food"), ("Water Well", "#38BDF8", 32, 8, "drink"),
        ("Pet Bed", "#A78BFA", -32, 32, "sleep"), ("Playground", "#22C55E", 32, 32, "play"),
        ("Bath House", "#67E8F9", 0, 42, "bath")
    ]
    for n in needs {
        m.slab("\(n.0) Base", x: n.2, y: 0, z: n.3, w: 10, h: 0.3, d: 10, color: "#FFFFFF")
        m.pad(n.0, x: n.2, z: n.3, y: 0.3, size: 5, color: n.1, tags: ["need", n.4])
        m.pillar("\(n.0) Post", x: n.2 + 4, z: n.3 - 4, y: 0.3, height: 3, radius: 0.3, color: n.1)
    }
    m.part("Well Roof", at: (32, 3.6, 8), size: (6, 1.4, 6), color: "#1D4ED8", shape: .cone)
    for i in 0..<3 { m.slab("Slide \(i + 1)", x: 28 + Float(i) * 4, y: 0.3, z: 36, w: 2, h: 2 + Float(i), d: 2, color: "#FDE047") }

    for p in ring(12, radius: 58) { m.tree(p.0, p.1, height: 4, leaves: "#F472B6") }
    for p in ring(10, radius: 48, phase: 0.3) { m.tree(p.0, p.1, height: 3.5, leaves: "#86EFAC") }
    for p in grid(4, 2, spacing: 3, cx: -12, cz: 16) {
        m.part("Flower", at: (p.0, 0.3, p.1), size: (0.8, 0.6, 0.8), color: "#F43F5E", shape: .sphere, solid: false)
    }
}

// MARK: 4 Meme Heist

func memeHeist(_ m: MapBuilder) {
    m.sky("#FF7AD9", "#FFE3A3", light: 0.8, ground: "#3B2A6B")
    m.ground(150, 150, color: "#4C3A8A")
    // The carpet memes walk along, from the gate at -z to the stage at +z.
    m.part("Red Carpet", at: (0, 0.05, 0), size: (6, 0.1, 110), color: "#DC2626", material: .matte)
    m.slab("Meme Gate", x: 0, y: 0, z: -56, w: 10, h: 6, d: 1, color: "#FACC15", material: .neon)
    m.part("Carpet Start", at: (0, 0.2, -52), size: (2, 0.2, 2), color: "#FFFFFF", shape: .cylinder, visible: false)
    m.part("Carpet End", at: (0, 0.2, 52), size: (2, 0.2, 2), color: "#FFFFFF", shape: .cylinder, visible: false)
    m.spawnRing(0, -40, radius: 3, count: 4, color: "#FDE047")

    // Eight bases, four on each side of the carpet.
    let colors = ["#EF4444", "#3B82F6", "#22C55E", "#F59E0B", "#A855F7", "#EC4899", "#14B8A6", "#F97316"]
    for i in 0..<8 {
        let side: Float = i < 4 ? -1 : 1
        let z = -36 + Float(i % 4) * 24
        let x = side * 34
        m.slab("Base \(i + 1) Floor", x: x, y: 0, z: z, w: 20, h: 0.4, d: 18, color: "#1F1B3A", tags: ["base"])
        m.pad("Base \(i + 1) Claim", x: x - side * 7, z: z, y: 0.4, size: 3, color: colors[i], tags: ["claim"])
        m.pad("Base \(i + 1) Home", x: x, z: z, y: 0.4, size: 5, color: colors[i], tags: ["home"], shape: .box)
        m.pad("Base \(i + 1) Lock", x: x + side * 8, z: z + 6, y: 0.4, size: 2, color: "#FFFFFF", tags: ["lock"])
        // A wall of lasers across the entrance, off until locked.
        m.part("Base \(i + 1) Laser", at: (x - side * 10, 1.5, z), size: (0.3, 3, 16), color: colors[i], material: .neon,
               behavior: .hazard, tags: ["laser"], solid: false, visible: false)
        for k in 0..<5 {
            let sz = z - 6 + Float(k) * 3
            m.part("Base \(i + 1) Slot \(k + 1)", at: (x + side * 6, 0.9, sz), size: (2, 1, 2), color: "#D4D4D8",
                   shape: .cylinder, material: .metal, behavior: .trigger, tags: ["slot"])
        }
        m.walls(x, z, w: 20, d: 18, h: 2.5, y: 0.4, color: colors[i], thickness: 0.4, name: "Base \(i + 1) Wall", opacity: 0.35)
    }
}

// MARK: 5 Reel Legends

func reelLegends(_ m: MapBuilder) {
    m.ocean()
    m.ground(220, 220, color: "#C8B68A", name: "Lakebed", y: -2)
    // Land in the middle, water around it.
    m.part("Harbor Town", at: (0, -0.5, 0), size: (50, 1, 40), color: "#9CCB6B", material: .matte, tags: ["ground"])
    m.part("Sea", at: (0, -0.3, 0), size: (220, 0.1, 220), color: "#1E7AD1", material: .glass, solid: false, opacity: 0.75)
    m.spawnRing(0, 0, radius: 5, count: 6)
    m.shop("Bait Shop", x: -14, z: -10, w: 10, d: 8, color: "#0EA5E9", sign: "#FDE68A")
    m.pad("Merchant", x: -14, z: -8, size: 2.4, color: "#FACC15", tags: ["merchant"])
    m.shop("Rod Shop", x: 14, z: -10, w: 10, d: 8, color: "#1E40AF", sign: "#FFFFFF")
    for p in ring(6, radius: 16, phase: 0.5) { m.tree(p.0, p.1, height: 4) }

    // Four fishing grounds, each with a dock and two spots.
    let zones: [(String, Float, Float, String)] = [
        ("Pond", 0, 40, "#86EFAC"), ("Ocean", 55, 0, "#38BDF8"), ("Deep Trench", 0, -60, "#1E3A8A"), ("Volcano Lake", -60, 0, "#F97316")
    ]
    for z in zones {
        let dx = z.1 == 0 ? Float(0) : (z.1 > 0 ? -1 : 1)
        let dz = z.2 == 0 ? Float(0) : (z.2 > 0 ? -1 : 1)
        // A pier from town out to the zone.
        let length: Float = max(abs(z.1), abs(z.2)) - 14
        let midX = z.1 + dx * length / 2, midZ = z.2 + dz * length / 2
        m.slab("\(z.0) Pier", x: midX, y: -0.2, z: midZ, w: dx == 0 ? 4 : length, h: 0.4, d: dz == 0 ? 4 : length, color: "#8B5A2B")
        m.slab("\(z.0) Dock", x: z.1, y: -0.2, z: z.2, w: 12, h: 0.4, d: 12, color: "#A16207")
        m.pad("Fishing Spot \(z.0) A", x: z.1 - 3, z: z.2, y: 0.2, size: 2, color: z.3, tags: ["spot", z.0])
        m.pad("Fishing Spot \(z.0) B", x: z.1 + 3, z: z.2, y: 0.2, size: 2, color: z.3, tags: ["spot", z.0])
    }
    m.part("Volcano", at: (-80, 6, 0), size: (22, 16, 22), color: "#57301B", shape: .cone, material: .matte)
    m.part("Lava Glow", at: (-80, 14.2, 0), size: (4, 0.4, 4), color: "#FF5A1F", shape: .cylinder, material: .neon, solid: false)
}

// MARK: 6 Clash Duels

func clashDuels(_ m: MapBuilder) {
    m.sky("#1F2937", "#94A3B8", light: 0.7, ground: "#374151")
    m.ground(90, 60, color: "#475569", name: "Arena Floor")
    m.walls(0, 0, w: 90, d: 60, h: 6, color: "#1E293B", name: "Arena Wall")
    // Two bases.
    m.slab("Red Base", x: -38, y: 0, z: 0, w: 10, h: 0.3, d: 20, color: "#B91C1C")
    m.slab("Blue Base", x: 38, y: 0, z: 0, w: 10, h: 0.3, d: 20, color: "#1D4ED8")
    for (i, z) in [-6, -2, 2, 6].enumerated() {
        m.spawn(-40, Float(z), y: 0.3, name: "Red Spawn \(i + 1)", color: "#F87171")
        m.spawn(40, Float(z), y: 0.3, name: "Blue Spawn \(i + 1)", color: "#60A5FA")
    }
    // Cover.
    var r = Seeded("clash")
    for i in 0..<14 {
        let x = r.range(-26, 26), z = r.range(-24, 24)
        let tall = r.unit() > 0.5
        m.slab("Cover \(i + 1)", x: x, y: 0, z: z, w: r.range(2, 5), h: tall ? 3.2 : 1.3, d: r.range(1.5, 4),
               color: tall ? "#64748B" : "#94A3B8")
    }
    m.slab("Tower", x: 0, y: 0, z: 0, w: 6, h: 4, d: 6, color: "#334155")
    m.stairs(-7, 0, steps: 4, rise: 1, run: 1, width: 3, color: "#475569", name: "Tower Step")
    m.slab("Lobby", x: 0, y: 12, z: 0, w: 1, h: 0.2, d: 1, color: "#000000", solid: false)
}

// MARK: 7 Sprout Garden

func sproutGarden(_ m: MapBuilder) {
    m.day(ground: "#7CB342")
    m.ground(150, 150, color: "#8BC34A")
    m.part("Plaza", at: (0, 0.03, 0), size: (20, 0.06, 20), color: "#E7D3A8", shape: .cylinder, material: .matte)
    m.spawnRing(0, 0, radius: 5, count: 8)
    m.shop("Seed Shop", x: -10, z: -18, w: 10, d: 8, color: "#65A30D", sign: "#FEF08A")
    m.pad("Seed Counter", x: -10, z: -16, size: 2.4, color: "#A3E635", tags: ["seeds"])
    m.shop("Market", x: 10, z: -18, w: 10, d: 8, color: "#EA580C", sign: "#FFFFFF")
    m.pad("Sell Counter", x: 10, z: -16, size: 2.4, color: "#FB923C", tags: ["sell"])

    // Eight plots in a ring, each three by three soil squares.
    for i in 0..<8 {
        let a = Float(i) / 8 * 2 * .pi
        let cx = cos(a) * 42, cz = sin(a) * 42
        m.slab("Plot \(i + 1)", x: cx, y: 0, z: cz, w: 16, h: 0.2, d: 16, color: "#6D4C2F", tags: ["plot"])
        m.pad("Plot \(i + 1) Sign", x: cx - cos(a) * 10, z: cz - sin(a) * 10, size: 2, color: "#FDE047", tags: ["claim"])
        var k = 0
        for p in grid(3, 3, spacing: 4.5, cx: cx, cz: cz) {
            k += 1
            m.part("Plot \(i + 1) Soil \(k)", at: (p.0, 0.3, p.1), size: (3.2, 0.2, 3.2), color: "#4A3222", material: .matte,
                   behavior: .trigger, tags: ["soil"])
        }
        m.fence(from: (cx - 8, cz + 8), to: (cx + 8, cz + 8))
        m.fence(from: (cx - 8, cz - 8), to: (cx + 8, cz - 8))
    }
    for p in ring(14, radius: 68) { m.tree(p.0, p.1, height: 5, leaves: "#4CAF50") }
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
}

// MARK: 10 99 Nights Camp

func nightsCamp(_ m: MapBuilder) {
    m.sky("#6FB7E8", "#D8EEFF", light: 0.7, ground: "#2F4A2A")
    m.ground(200, 200, color: "#3E5F32")
    m.part("Clearing", at: (0, 0.03, 0), size: (30, 0.06, 30), color: "#7A6A4A", shape: .cylinder, material: .matte)
    m.part("Campfire", at: (0, 0.5, 0), size: (3, 1, 3), color: "#F97316", shape: .cone, material: .neon, behavior: .trigger, tags: ["fire"])
    m.part("Fire Ring", at: (0, 0.15, 0), size: (4.2, 0.3, 4.2), color: "#57534E", shape: .cylinder)
    m.spawnRing(0, 0, radius: 7, count: 8, color: "#FDBA74")
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
    m.walls(0, -10, w: 14, d: 14, h: 5, color: "#3F2A1F", name: "Lobby Wall")
    m.spawnRing(0, -12, radius: 3, count: 6, color: "#FDE68A")
    m.part("Reception", at: (0, 0.6, -15), size: (6, 1.2, 1.2), color: "#7C2D12")
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
        if n % 5 == 0 {
            m.part("Key \(n)", at: (-side * 0.6, 0.8, z + 1), size: (0.5, 0.2, 0.9), color: "#FACC15", material: .neon,
                   behavior: .trigger, tags: ["key"])
        }
    }
    m.slab("Exit", x: 0, y: -0.3, z: 101 * roomLength, w: 20, h: 0.3, d: 20, color: "#FDE68A")
    m.pad("Exit Light", x: 0, z: 101 * roomLength, size: 5, color: "#FFFFFF", tags: ["exit"])
}

// MARK: 14 Pet Coin Frenzy

func petCoin(_ m: MapBuilder) {
    m.sky("#7DD3FC", "#FDF4FF", light: 0.8, ground: "#86EFAC")
    let zones: [(String, String, Float)] = [("Spawn Meadow", "#86EFAC", 0), ("Candy Land", "#F9A8D4", 60),
                                            ("Frost Peak", "#E0F2FE", 120), ("Lava Isle", "#F97316", 180), ("Galaxy", "#312E81", 240)]
    for (i, z) in zones.enumerated() {
        m.ground(56, 56, color: z.1, name: "\(z.0) Ground", z: z.2)
        if i > 0 {
            m.part("Gate \(i + 1)", at: (0, 3, z.2 - 29), size: (56, 6, 1), color: "#A855F7", material: .glass,
                   behavior: .trigger, tags: ["gate"], solid: false, opacity: 0.5)
        }
        var r = Seeded("coins\(i)")
        for k in 0..<10 {
            let big = k == 9
            m.part("\(z.0) Pile \(k + 1)", at: (r.range(-22, 22), big ? 1.5 : 0.6, z.2 + r.range(-20, 20)),
                   size: big ? (3, 3, 3) : (1.4, 1.2, 1.4), color: big ? "#FDE047" : "#FACC15",
                   shape: big ? .sphere : .cylinder, material: .metal, tags: ["pile", "zone\(i + 1)"])
        }
        m.slab("\(z.0) Egg Stand", x: 20, y: 0, z: z.2 + 22, w: 4, h: 1, d: 4, color: "#FFFFFF")
        m.part("Egg \(i + 1)", at: (20, 2, z.2 + 22), size: (1.6, 2, 1.6), color: z.1, shape: .sphere, material: .neon,
               behavior: .trigger, tags: ["egg"])
    }
    m.spawnRing(0, -10, radius: 4, count: 6)
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
    let teams: [(String, String, Float, Float)] = [("Red", "#EF4444", 0, -50), ("Blue", "#3B82F6", 50, 0),
                                                  ("Green", "#22C55E", 0, 50), ("Yellow", "#EAB308", -50, 0)]
    for t in teams {
        m.slab("\(t.0) Island", x: t.2, y: -2, z: t.3, w: 16, h: 2, d: 16, color: "#6B8E4E", tags: ["island"])
        m.slab("\(t.0) Island Rock", x: t.2, y: -5, z: t.3, w: 12, h: 3, d: 12, color: "#57534E")
        m.part("\(t.0) Crystal", at: (t.2 * 1.08, 1.2, t.3 * 1.08), size: (1.4, 2.4, 1.4), color: t.1, shape: .cone, material: .glass,
               tags: ["crystal", t.0.lowercased()])
        m.pad("\(t.0) Generator", x: t.2 * 0.9, z: t.3 * 0.9 + (t.3 == 0 ? 4 : 0), size: 2.5, color: "#D1D5DB", tags: ["generator", t.0.lowercased()])
        m.pad("\(t.0) Shop", x: t.2 * 0.9 + (t.2 == 0 ? 4 : 0), z: t.3 * 0.9, size: 2.5, color: t.1, tags: ["shop"])
        for k in 0..<2 {
            m.spawn(t.2 + (t.2 == 0 ? Float(k * 3 - 1) : 0) * 1.5, t.3 + (t.3 == 0 ? Float(k * 3 - 1) : 0) * 1.5,
                    name: "\(t.0) Spawn \(k + 1)", color: t.1)
        }
    }
    m.slab("Center Island", x: 0, y: -2, z: 0, w: 14, h: 2, d: 14, color: "#8B7355")
    m.pad("Diamond Generator", x: 0, z: 0, size: 3, color: "#22D3EE", tags: ["generator", "diamond"])
    // A short starter bridge from each island, the rest is built.
    for t in teams {
        let dx: Float = t.2 == 0 ? 0 : -t.2 / abs(t.2)
        let dz: Float = t.3 == 0 ? 0 : -t.3 / abs(t.3)
        for k in 1...4 {
            m.slab("\(t.0) Bridge \(k)", x: t.2 + dx * (8 + Float(k) * 2), y: -1, z: t.3 + dz * (8 + Float(k) * 2), w: 2, h: 1, d: 2,
                   color: "#D6D3D1", tags: ["placed"])
        }
    }
}

// MARK: 17 Slime Roll

func slimeRoll(_ m: MapBuilder) {
    m.sky("#A5F3FC", "#F0FDFA", light: 0.8, ground: "#99F6E4")
    m.ground(120, 120, color: "#5EEAD4")
    m.part("Roll Altar", at: (0, 0.5, 0), size: (8, 1, 8), color: "#FFFFFF", shape: .cylinder, material: .metal)
    m.part("Roll Crystal", at: (0, 3, 0), size: (2, 3, 2), color: "#A855F7", shape: .sphere, material: .neon, solid: false)
    m.spawnRing(0, 0, radius: 9, count: 8, color: "#C4B5FD")
    m.slab("Battle Field", x: 0, y: 0, z: 40, w: 50, h: 0.3, d: 30, color: "#65A30D")
    m.walls(0, 40, w: 50, d: 30, h: 1.2, y: 0.3, color: "#3F6212", name: "Field Fence")
    m.markers("Blob Spot", points: grid(4, 2, spacing: 10, cx: 0, cz: 40), y: 0.3, color: "#000000", visible: false, behavior: .none)
    for p in ring(10, radius: 50) { m.tree(p.0, p.1, height: 4, leaves: "#2DD4BF") }
}

// MARK: 18 Hero Tower Defense

func heroTD(_ m: MapBuilder) {
    m.day(ground: "#4D7C0F")
    m.ground(120, 120, color: "#65A30D")
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
    m.slab("Castle", x: 40, y: 0, z: 56, w: 14, h: 6, d: 6, color: "#CBD5E1")
    for x in [34, 46] { m.pillar("Castle Tower", x: Float(x), z: 56, height: 9, radius: 1.6, color: "#94A3B8") }
    // Places to stand a hero, alongside the path.
    let spots: [(Float, Float)] = [(-43, -30), (-57, -20), (-35, -18), (-12, -25), (-27, -47), (0, -47), (13, -20), (27, -20),
                                   (5, 7), (-15, 7), (-37, 17), (-23, 28), (0, 28), (20, 42), (33, 28), (47, 42)]
    for (i, p) in spots.enumerated() {
        m.part("Tower Spot \(i + 1)", at: (p.0, 0.15, p.1), size: (3.2, 0.3, 3.2), color: "#A3A3A3", shape: .cylinder,
               material: .metal, behavior: .trigger, tags: ["spot"])
    }
    m.spawnRing(20, 55, radius: 3, count: 6, color: "#60A5FA")
}

// MARK: 19 Domain Clash

func domainClash(_ m: MapBuilder) {
    m.sky("#1E1B4B", "#6D28D9", light: 0.6, ground: "#1F1B2E")
    m.ground(140, 140, color: "#2E2A3F", name: "Arena")
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
    m.part("Torii", at: (0, 5, -60), size: (14, 1, 1.2), color: "#DC2626")
    m.pillar("Torii Leg", x: -5.5, z: -60, height: 5, radius: 0.5, color: "#DC2626")
    m.pillar("Torii Leg", x: 5.5, z: -60, height: 5, radius: 0.5, color: "#DC2626")
}

// MARK: 20 Tsunami Dash

func tsunamiDash(_ m: MapBuilder) {
    m.sky("#38BDF8", "#E0F2FE", light: 0.8, showGround: false, fall: -20)
    // A 300 m course along +z, twelve wide.
    m.slab("Start Area", x: 0, y: -1, z: -10, w: 24, h: 1, d: 20, color: "#FDE68A")
    m.spawnRing(0, -10, radius: 4, count: 8, color: "#FB923C")
    var r = Seeded("dash")
    for i in 0..<15 {
        let z = Float(i) * 20 + 10
        let gap = i % 3 == 2
        m.slab("Track \(i + 1)", x: 0, y: -1, z: z, w: 14, h: 1, d: gap ? 12 : 20, color: i % 2 == 0 ? "#F472B6" : "#A78BFA", tags: ["track"])
        if gap {
            m.part("Jump Pad \(i + 1)", at: (0, 0.1, z + 4), size: (4, 0.2, 2), color: "#22C55E", material: .neon, behavior: .bounce)
        }
        // Obstacles.
        for k in 0..<2 {
            m.slab("Block \(i + 1)-\(k + 1)", x: r.range(-5, 5), y: 0, z: z + r.range(-7, 5), w: r.range(1.5, 3), h: r.range(1, 2.2),
                   d: 1, color: "#FFFFFF")
        }
        m.part("Meme \(i + 1)", at: (r.range(-5, 5), 1, z), size: (0.9, 0.9, 0.9), color: r.pick(["#FACC15", "#34D399", "#F87171"]),
               shape: .sphere, material: .neon, behavior: .trigger, tags: ["meme"], solid: false)
    }
    m.slab("Finish", x: 0, y: -1, z: 320, w: 24, h: 1, d: 16, color: "#22C55E")
    m.pad("Finish Line", x: 0, z: 316, size: 12, color: "#FFFFFF", tags: ["finish"], shape: .box)
    m.part("Wave Start", at: (0, 3, -30), size: (1, 1, 1), color: "#FFFFFF", visible: false)
}
