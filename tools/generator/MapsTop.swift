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
         summary: "赤いカーペットを歩く300体のヘンなミームを買って、自分のきちの台にならべよう。ミームはお金をうむ。ライバルや友だちのきちからぬすみ出して、ロックで守れ！ 50のイベント・儀式・合体・転生15回・図鑑。",
         tags: ["simulator", "steal", "funny", "top20"], maxPlayers: 8, build: memeHeist),
    Game(number: 5, id: "reel-legends", title: "Reel Legends",
         summary: "つりのアドベンチャー。タイミングよくリールを引いて魚をつり上げ、売ってロッドを強化。池、海、深海、火山湖で伝説の魚を探そう。",
         tags: ["fishing", "simulator", "collect", "top20"], maxPlayers: 12, libs: ["crowd"], build: reelLegends),
    Game(number: 6, id: "clash-duels", title: "Clash Duels",
         summary: "1対1から5対5まで、短い試合で勝負するFPS。ラウンドごとに武器を選んで、先に5ラウンド取ったチームの勝ち。",
         tags: ["fps", "pvp", "teams", "top20"], maxPlayers: 10, libs: ["bots"], build: clashDuels),
    Game(number: 7, id: "sprout-garden", title: "Sprout Garden",
         summary: "自分の畑にタネをまいて、育ったら収穫して売ろう。雨や虹のイベントで作物がパワーアップ。レアなタネで夢の庭園を。",
         tags: ["farming", "simulator", "chill", "top20"], maxPlayers: 8, build: sproutGarden),
    Game(number: 8, id: "runway-star", title: "Runway Star",
         summary: "テーマに合わせて服の色や帽子をコーディネートしてランウェイへ。みんなで星をつけ合って、トップモデルを決めよう。",
         tags: ["fashion", "vote", "party", "top20"], maxPlayers: 12, build: runwayStar),
    Game(number: 9, id: "mystery-manor", title: "Mystery Manor",
         summary: "市民・保安官・犯人に分かれる推理サバイバル。犯人は正体をかくして全員を、保安官は犯人を見つけてたおせ。市民は生きのこれ！",
         tags: ["mystery", "roles", "pvp", "top20"], maxPlayers: 12, libs: ["crowd"], build: mysteryManor),
    Game(number: 10, id: "99-nights-camp", title: "99 Nights Camp",
         summary: "森のキャンプで99日を生きのびるサバイバル。昼は木を切ってたき火を守り、夜はおそってくる怪物からみんなで身を守ろう。",
         tags: ["survival", "horror", "coop", "top20"], maxPlayers: 10, build: nightsCamp),
    Game(number: 11, id: "lucky-kick-run", title: "Lucky Kick Run",
         summary: "ラッキーブロックをけとばして何が出るかな？アイテムを手に入れたら、せまる大津波から高台へにげろ！",
         tags: ["luck", "survival", "action", "top20"], maxPlayers: 12, libs: ["crowd"], build: luckyKick),
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
         tags: ["obby", "hard", "tower", "top20"], maxPlayers: 16, libs: ["crowd"], build: towerChaos),
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
         tags: ["runner", "survival", "funny", "top20"], maxPlayers: 16, libs: ["crowd"], build: tsunamiDash),
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
    mapleBayDetail(m)
}

/// Finishing touches, only to look at (nothing here is solid or tagged, and
/// no name is one a script looks for): sidewalks and crossings, a paved
/// plaza with flowers, benches and bunting, front gardens, signs at every
/// workplace, furniture inside them, and grass and wildflowers in between.
func mapleBayDetail(_ m: MapBuilder) {
    // Sidewalks with a curb and paving seams, between the crossings.
    for side in [Float(-1), 1] {
        // The main road (8 wide) leaves the plaza both ways.
        for (a, b) in [(Float(11), Float(90)), (-90, -11)] {
            m.sidewalk(x: a, b, z: side * 5, curbZ: side * 4.1)
        }
        // The north and south roads (6 wide) cross the town.
        for road in [Float(45), -45] {
            for (a, b) in [(Float(4), Float(90)), (-90, -4)] {
                m.sidewalk(x: a, b, z: road + side * 4, curbZ: road + side * 3.1)
            }
        }
        // The road through the middle, north to south.
        for (a, b) in [(Float(11), Float(40)), (50, 90), (-40, -11), (-90, -50)] {
            m.sidewalk(z: a, b, x: side * 5, curbX: side * 4.1)
        }
    }
    // Zebra crossings at both junctions and where the roads meet the plaza.
    for road in [Float(45), -45] {
        m.crosswalk(0, road + 4.6, across: 8, yaw: 0, stripes: 6)
        m.crosswalk(0, road - 4.6, across: 8, yaw: 0, stripes: 6)
        m.crosswalk(5.6, road, across: 6, yaw: 90)
        m.crosswalk(-5.6, road, across: 6, yaw: 90)
    }
    for s in [Float(-13), 13] {
        m.crosswalk(s, 0, across: 8, yaw: 90, stripes: 6)
        m.crosswalk(0, s, across: 8, yaw: 0, stripes: 6)
    }

    // The plaza: rings of paving, a flower ring round the fountain, benches,
    // planters and bunting between the four lamps.
    let stone = "#C9B48F", light = "#E3D6BC"
    for (r, color, y) in [(Float(10), stone, Float(0.065)), (9, light, 0.07), (6, stone, 0.075), (5.2, light, 0.08)] {
        m.deco("Plaza Paving", at: (0, y, 0), size: (r * 2, 0.01, r * 2), color: color, shape: .cylinder, material: .matte)
    }
    for p in ring(16, radius: 9.5, phase: .pi / 16) {
        m.deco("Plaza Stone", at: (p.0, 0.075, p.1), size: (0.7, 0.01, 0.7), color: "#A8926C", shape: .cylinder, material: .matte)
    }
    m.deco("Fountain Bed Rim", at: (0, 0.12, 0), size: (8.4, 0.24, 8.4), color: "#B8AFA3", shape: .cylinder, material: .matte)
    m.deco("Fountain Bed Soil", at: (0, 0.2, 0), size: (7.8, 0.1, 7.8), color: "#6B4A2E", shape: .cylinder, material: .matte)
    let blooms = ["#F43F5E", "#FACC15", "#FFFFFF", "#A855F7", "#FB923C", "#38BDF8", "#F472B6"]
    for (i, p) in ring(14, radius: 3.5).enumerated() { m.flower(p.0, p.1, y: 0.24, color: blooms[i % blooms.count]) }
    for p in ring(4, radius: 10, phase: .pi / 4) {
        m.bench(in: Frame(p.0, p.1, yaw: atan2(-p.0, -p.1) * 180 / .pi))
    }
    for (i, p) in ring(8, radius: 10.2, phase: .pi / 4 - 0.38).enumerated() where i % 2 == 0 {
        m.planter(p.0, p.1, bloom: blooms[i % blooms.count])
    }
    for (i, p) in ring(8, radius: 10.2, phase: .pi / 4 + 0.38).enumerated() where i % 2 == 0 {
        m.planter(p.0, p.1, bloom: blooms[(i + 3) % blooms.count])
    }
    let corners: [V] = [(10, 3.25, 10), (-10, 3.25, 10), (-10, 3.25, -10), (10, 3.25, -10)]
    for i in 0..<4 {
        m.pennants(from: corners[i], to: corners[(i + 1) % 4], count: 9, colors: ["#EF4444", "#FACC15", "#22C55E", "#3B82F6", "#F472B6"])
    }
    m.signboard("Welcome Sign", in: Frame(7.5, 13.5, yaw: 180 + 29), lines: [("🍁 メープルベイへようこそ", "#FFFFFF"), ("Maple Bay", "#FDE68A")],
                board: "#B45309", width: 4)
    m.deco("Clock Tower Roof", at: (10, 9.7, -12), size: (3, 1.4, 3), color: "#7C2D12", shape: .cone, material: .matte)
    m.deco("Clock Tower Base", at: (10, 0.3, -12), size: (3, 0.6, 3), color: "#78716C", shape: .cylinder, material: .matte)

    // Front gardens: a mat and a stepping-stone path to the sidewalk, a
    // mailbox, flower boxes under the windows, bushes by the door and a bed
    // of flowers by the fence. The same houses as the street above.
    let mailColors = ["#2563EB", "#DC2626", "#16A34A", "#F59E0B"]
    var n = 0
    for (row, z) in [(0, 62), (1, 28), (2, -28), (3, -62)] {
        for x in [-60, -30, 30, 60] where n < 8 && !(row == 1 && x == 30) && !(row == 2 && x == -30) {
            let f: Float = (row == 0 || row == 2) ? -1 : 1
            let hx = Float(x), front = Float(z) + f * 5
            let out = Frame(hx, front, yaw: f > 0 ? 0 : 180)
            m.deco("Doormat", at: (hx, 0.02, front + f * 0.7), size: (1.4, 0.03, 0.8), color: "#92400E", material: .matte)
            for k in 0..<4 {
                m.deco("Path Stone", at: (hx + (k % 2 == 0 ? 0.15 : -0.15), 0.02, front + f * (1.8 + Float(k) * 1.4)),
                       size: (1.1, 0.03, 0.8), color: "#BDB5A6", shape: .cylinder, material: .matte)
            }
            m.mailbox(in: Frame(hx + 1.8, front + f * 6.3, yaw: f > 0 ? 0 : 180), color: mailColors[n % mailColors.count])
            for side in [Float(-1), 1] {
                m.deco("Flower Box", in: out, side * 3.4, 0.95, 0.38, size: (1.3, 0.25, 0.3), color: "#8B5A2B")
                for k in 0..<3 {
                    m.deco("Flower Box Bloom", in: out, side * 3.4 + Float(k - 1) * 0.4, 1.14, 0.38, size: (0.25, 0.2, 0.25),
                           color: blooms[(n + k) % blooms.count], shape: .sphere)
                }
                m.bush(hx + side * 1.7, front + f * 0.8, color: "#3F8F3F", size: 0.9)
            }
            m.flowerBed(hx - 4.5, front + f * 1.2, w: 3, d: 0.9, colors: [blooms[n % 7], blooms[(n + 2) % 7]], seed: "maple bed \(n)")
            n += 1
        }
    }

    // Workplaces: a sign by every door, a mat inside, and what each one is for.
    struct Place { let name: String, text: String, x: Float, z: Float, w: Float, d: Float, f: Float, board: String }
    let places = [
        Place(name: "Police", text: "👮 警察署", x: 30, z: 28, w: 14, d: 10, f: -1, board: "#1E3A8A"),
        Place(name: "Hospital", text: "🏥 病院", x: -30, z: -28, w: 14, d: 10, f: 1, board: "#DC2626"),
        Place(name: "Cafe", text: "☕ カフェ", x: -78, z: 12, w: 10, d: 10, f: -1, board: "#92400E"),
        Place(name: "Fire", text: "🚒 消防署", x: 78, z: -12, w: 12, d: 10, f: 1, board: "#B91C1C"),
        Place(name: "School", text: "🏫 学校", x: 78, z: 12, w: 14, d: 10, f: -1, board: "#15803D"),
        Place(name: "Post", text: "📮 郵便局", x: -52, z: 12, w: 10, d: 8, f: -1, board: "#C2410C"),
        Place(name: "Bank", text: "🏦 銀行", x: 52, z: -12, w: 12, d: 9, f: 1, board: "#A16207"),
        Place(name: "Furniture", text: "🛋 家具屋", x: -52, z: -12, w: 12, d: 9, f: 1, board: "#BE185D"),
        Place(name: "City Hall", text: "🏛 市役所", x: -12, z: -28, w: 12, d: 9, f: 1, board: "#1D4ED8"),
    ]
    for p in places {
        // Local frame: +z out of the front door.
        let inside = Frame(p.x, p.z, y: 0.15, yaw: p.f > 0 ? 0 : 180)
        let side = p.w / 2 - 1.0, back = -(p.d / 2 - 0.7)
        m.signboard("\(p.name) Entrance Sign", in: Frame(p.x + p.w / 2 - 1.4, p.z + p.f * (p.d / 2 + 1.3), yaw: p.f > 0 ? 0 : 180),
                    lines: [(p.text, "#FFFFFF")], board: p.board, width: 2.4)
        m.deco("Entrance Mat", in: inside, 0, 0.01, p.d / 2 - 0.9, size: (2.2, 0.02, 1.2), color: MapBuilder.shade(p.board, 0.2))
        switch p.name {
        case "Police":
            for s in [Float(-1), 1] {
                m.deco("Desk", in: inside, s * side, 0.75, back + 1.2, size: (1.6, 0.08, 0.9), color: "#E5E7EB")
                m.deco("Desk Body", in: inside, s * side, 0.37, back + 1.2, size: (1.5, 0.72, 0.8), color: "#64748B")
                m.deco("Computer", in: inside, s * side, 1.1, back + 1.0, size: (0.7, 0.45, 0.06), color: "#0F172A", material: .neon)
                m.deco("Chair Seat", in: inside, s * side, 0.45, back + 2.1, size: (0.55, 0.08, 0.55), color: "#1E3A8A")
            }
            for k in 0..<3 {
                m.deco("Wanted Poster", in: inside, Float(k - 1) * 1.1, 2.0, -(p.d / 2 - 0.25), size: (0.8, 1, 0.04),
                       color: ["#FDE68A", "#FEF3C7", "#FDE68A"][k])
            }
            m.deco("Police Badge", in: inside, 0, 3.0, -(p.d / 2 - 0.25), size: (0.9, 0.9, 0.06), color: "#FACC15", shape: .cylinder,
                   material: .metal, tilt: (90, 0))
            for k in 0..<5 {
                m.deco("Cell Bar", in: inside, side + 0.5 - Float(k) * 0.35, 1.2, 1.5, size: (0.06, 2.4, 0.06), color: "#4B5563",
                       shape: .cylinder, material: .metal)
            }
        case "Hospital":
            for s in [Float(-1), 1] {
                m.bed(in: Frame(p.x + s * side, p.z + p.f * (back + 1.5), y: 0.15, yaw: p.f > 0 ? 0 : 180), blanket: "#93C5FD")
                m.deco("Drip Stand", in: inside, s * (side - 1.1), 0.9, back + 0.8, size: (0.05, 1.8, 0.05), color: "#D1D5DB",
                       shape: .cylinder, material: .metal)
                m.deco("Drip Bag", in: inside, s * (side - 1.1), 1.75, back + 0.8, size: (0.25, 0.35, 0.1), color: "#BAE6FD",
                       material: .glass, opacity: 0.8)
                m.deco("Curtain", in: inside, s * (side - 1.5), 1.2, back + 1.5, size: (0.06, 2.0, 2.2), color: "#A7F3D0", opacity: 0.85)
            }
            m.deco("Red Cross", in: inside, 0, 2.6, -(p.d / 2 - 0.25), size: (1.2, 0.35, 0.05), color: "#EF4444", material: .neon)
            m.deco("Red Cross", in: inside, 0, 2.6, -(p.d / 2 - 0.25), size: (0.35, 1.2, 0.05), color: "#EF4444", material: .neon)
        case "Cafe":
            for s in [Float(-1), 1] {
                let t = inside.at(s * (side - 0.4), 0, 2.2)
                m.table(t.0, t.2, y: 0.15, top: "#FEF3C7", chairs: 2, chair: "#92400E", phase: .pi / 2)
            }
            m.deco("Coffee Machine", in: inside, -1.5, 1.4, -1, size: (0.6, 0.9, 0.5), color: "#374151", material: .metal)
            m.deco("Coffee Cup", in: inside, -0.6, 1.07, -1, size: (0.2, 0.24, 0.2), color: "#FFFFFF", shape: .cylinder)
            m.deco("Cake Stand", in: inside, 1.2, 1.1, -1, size: (0.8, 0.3, 0.8), color: "#F9A8D4", shape: .cylinder)
            m.deco("Cake Dome", in: inside, 1.2, 1.5, -1, size: (0.8, 0.5, 0.8), color: "#E0F2FE", shape: .sphere, material: .glass, opacity: 0.5)
            m.deco("Menu Board", in: inside, 0, 2.4, -(p.d / 2 - 0.25), size: (2.6, 1.2, 0.05), color: "#1F2937")
            for k in 0..<3 {
                m.deco("Menu Line", in: inside, 0, 2.7 - Float(k) * 0.3, -(p.d / 2 - 0.29), size: (2.0, 0.07, 0.02), color: "#FDE68A")
            }
        case "Fire":
            m.shelf(in: Frame(p.x - p.f * side, p.z, y: 0.15, yaw: p.f > 0 ? 90 : -90), width: 3, height: 2, color: "#7F1D1D",
                    goods: ["#FACC15", "#EF4444"], goodsShape: .sphere)
            m.deco("Hose Reel", in: inside, side - 0.3, 1.0, back + 0.4, size: (1.4, 0.5, 1.4), color: "#B91C1C", shape: .cylinder,
                   tilt: (90, 0))
            m.deco("Hose Reel Hub", in: inside, side - 0.3, 1.0, back + 0.4, size: (0.5, 0.6, 0.5), color: "#FACC15", shape: .cylinder,
                   tilt: (90, 0))
            m.deco("Fire Pole", in: inside, side - 0.6, 2.0, 1.8, size: (0.12, 4, 0.12), color: "#D1D5DB", shape: .cylinder, material: .metal)
            m.deco("Fire Extinguisher", in: inside, -side + 0.3, 0.4, back + 0.3, size: (0.3, 0.8, 0.3), color: "#DC2626", shape: .cylinder)
        case "School":
            for s in [Float(-1), 1] {
                for row in 0..<2 {
                    for col in 0..<2 {
                        let dx = s * (side - 0.3 - Float(col) * 1.4), dz = 1.2 + Float(row) * 1.6
                        m.deco("School Desk", in: inside, dx, 0.6, dz, size: (1.0, 0.06, 0.6), color: "#F5DEB3")
                        m.deco("School Desk Leg", in: inside, dx, 0.3, dz, size: (0.9, 0.56, 0.06), color: "#6B7280", material: .metal)
                        m.deco("School Chair", in: inside, dx, 0.38, dz + 0.55, size: (0.45, 0.06, 0.45), color: "#16A34A")
                    }
                }
            }
            m.deco("Chalkboard", in: inside, 0, 2.2, -(p.d / 2 - 0.25), size: (4.4, 1.5, 0.05), color: "#14532D")
            m.deco("Chalkboard Frame", in: inside, 0, 2.2, -(p.d / 2 - 0.28), size: (4.7, 1.8, 0.04), color: "#8B5A2B")
            m.deco("Chalk Line", in: inside, -0.6, 2.4, -(p.d / 2 - 0.22), size: (2.2, 0.06, 0.02), color: "#FFFFFF")
            m.deco("Globe", in: inside, side - 0.2, 1.3, back + 0.5, size: (0.7, 0.7, 0.7), color: "#38BDF8", shape: .sphere)
            m.deco("Globe Stand", in: inside, side - 0.2, 0.5, back + 0.5, size: (0.1, 1, 0.1), color: "#A16207", shape: .cylinder)
        case "Post":
            for s in [Float(-1), 1] {
                m.shelf(in: Frame(p.x + s * side, p.z + p.f * (back + 0.6), y: 0.15, yaw: p.f > 0 ? 0 : 180),
                        width: 1.8, height: 2, color: "#78350F", goods: ["#D6A15E", "#C08A4B", "#E9C48A"])
            }
            m.deco("Parcel", in: inside, -side + 0.4, 0.4, 1.2, size: (0.8, 0.8, 0.8), color: "#C08A4B")
            m.deco("Parcel", in: inside, -side + 0.5, 1.0, 1.2, size: (0.6, 0.45, 0.6), color: "#D6A15E")
            m.mailbox(in: Frame(p.x - p.w / 2 + 1.2, p.z + p.f * (p.d / 2 + 1.2), yaw: p.f > 0 ? 0 : 180), color: "#DC2626")
        case "Bank":
            m.deco("Vault Door", in: inside, 0, 1.6, -(p.d / 2 - 0.28), size: (2.4, 0.15, 2.4), color: "#9CA3AF", shape: .cylinder,
                   material: .metal, tilt: (90, 0))
            m.deco("Vault Wheel", in: inside, 0, 1.6, -(p.d / 2 - 0.4), size: (0.9, 0.12, 0.9), color: "#FACC15", shape: .cylinder,
                   material: .metal, tilt: (90, 0))
            for s in [Float(-1), 1] {
                for k in 0..<3 {
                    m.deco("Gold Bar", in: inside, s * side + Float(k - 1) * 0.4, 0.25 + (k == 1 ? 0.18 : 0), back + 0.9,
                           size: (0.35, 0.18, 0.6), color: "#FACC15", material: .metal)
                }
                m.deco("Rope Post", in: inside, s * 1.6, 0.5, 2.0, size: (0.14, 1, 0.14), color: "#FACC15", shape: .cylinder, material: .metal)
            }
            m.deco("Rope", in: inside, 0, 0.85, 2.0, size: (3.2, 0.08, 0.08), color: "#B91C1C")
        case "Furniture":
            for s in [Float(-1), 1] {
                let c = s < 0 ? "#60A5FA" : "#F59E0B"
                m.deco("Sofa Seat", in: inside, s * side, 0.35, back + 1.3, size: (1.0, 0.4, 2.0), color: c)
                m.deco("Sofa Back", in: inside, s * (side + 0.45), 0.75, back + 1.3, size: (0.25, 0.8, 2.0), color: MapBuilder.shade(c, -0.15))
                m.deco("Floor Lamp", in: inside, s * side, 0.8, back + 2.8, size: (0.08, 1.6, 0.08), color: "#3A3A44", shape: .cylinder)
                m.deco("Floor Lamp Shade", in: inside, s * side, 1.65, back + 2.8, size: (0.5, 0.4, 0.5), color: "#FEF3C7", shape: .cone,
                       material: .neon)
            }
            m.rug(p.x, p.z + p.f * 1.8, y: 0.15, w: 3, d: 2, color: "#FBCFE8", border: "#BE185D")
        default:
            for s in [Float(-1), 1] {
                m.deco("Flag Pole", in: inside, s * side, 1.4, back + 0.3, size: (0.08, 2.8, 0.08), color: "#D1D5DB", shape: .cylinder)
                m.deco("Flag", in: inside, s * side + s * 0.45, 2.4, back + 0.3, size: (0.8, 0.55, 0.03), color: s < 0 ? "#1D4ED8" : "#DC2626")
            }
            m.deco("Red Carpet", in: inside, 0, 0.02, 1.4, size: (1.4, 0.02, 3), color: "#B91C1C", material: .matte)
            m.deco("Podium", in: inside, 3.5, 0.6, back + 1.0, size: (0.8, 1.2, 0.6), color: "#8B5A2B")
        }
    }

    // The market: fruit and bread on the stalls, crates, a striped roof.
    let produce = [["#EF4444", "#F87171"], ["#22C55E", "#84CC16"], ["#60A5FA", "#A78BFA"], ["#F59E0B", "#FDE68A"]]
    for i in 0..<4 {
        let sx = -18 + Float(i) * 4
        for k in 0..<4 {
            m.deco("Stall Goods", at: (sx - 0.9 + Float(k) * 0.6, 1.15, 34 + (k % 2 == 0 ? 0.3 : -0.3)), size: (0.35, 0.3, 0.35),
                   color: produce[i][k % 2], shape: .sphere)
        }
        m.deco("Stall Stripe", at: (sx, 2.52, 34), size: (1.1, 0.06, 2.6), color: ["#EF4444", "#22C55E", "#3B82F6", "#F59E0B"][i])
    }
    m.deco("Market Crate", at: (-22.3, 0.35, 33), size: (0.7, 0.7, 0.7), color: "#A16207")
    m.deco("Market Crate", at: (-22.3, 0.35, 35), size: (0.7, 0.7, 0.7), color: "#92400E")
    m.signboard("Market Sign", in: Frame(-4, 32, yaw: 180), lines: [("🛍 市場", "#FFFFFF")], board: "#D97706", width: 2.4)

    // The car lot, the gas station and the taxi stand.
    for k in 0..<4 {
        m.deco("Parking Line", at: (-85.5 + Float(k) * 5, 0.07, -14), size: (0.15, 0.01, 5), color: "#F8FAFC", material: .matte)
    }
    m.signboard("Car Lot Sign", in: Frame(-70, -7.5), lines: [("🚗 車屋", "#FFFFFF")], board: "#EA580C", width: 2.4)
    m.signboard("Gas Sign", in: Frame(28, -53.5), lines: [("⛽ ガソリン", "#FFFFFF")], board: "#16A34A", width: 2.4)
    for k in 0..<3 {
        m.deco("Tire", at: (13, 0.17 + Float(k) * 0.3, -61), size: (0.9, 0.28, 0.9), color: "#1F2023", shape: .cylinder, material: .matte)
    }
    m.deco("Oil Can", at: (22, 0.3, -61.2), size: (0.4, 0.6, 0.4), color: "#2563EB", shape: .cylinder, material: .metal)
    m.deco("Oil Can", at: (22.6, 0.3, -61.2), size: (0.4, 0.6, 0.4), color: "#DC2626", shape: .cylinder, material: .metal)
    m.deco("Taxi Sign", at: (12, 2.7, -9), size: (1.6, 0.5, 0.35), color: "#111827")
    m.label(m.deco("Taxi Sign Light", at: (12, 3.1, -9), size: (1.0, 0.3, 0.3), color: "#FDE047", material: .neon),
            [("🚕 タクシー乗り場", "#FFFFFF")], height: 0.2, size: 0.9, range: 50)
    m.bench(in: Frame(14.5, -9, yaw: 0), color: "#FACC15")

    // On the sidewalks: bins and hydrants.
    for (i, x) in [Float(-70), -40, -20, 20, 40, 70].enumerated() {
        m.bin(x + 2, i % 2 == 0 ? 5.6 : -5.6)
        m.hydrant(x - 3, i % 2 == 0 ? -5.4 : 5.4)
        m.bin(x + 6, i % 2 == 0 ? 49.6 : -49.6, color: "#1E3A8A")
    }

    // The park: a ring of stepping stones round the pond, ducks, benches
    // and a picnic table.
    for (i, p) in ring(18, radius: 6.6, cx: 40, cz: 70).enumerated() {
        m.deco("Park Path", at: (p.0, 0.02, p.1), size: (1.0, 0.03, 1.0), color: i % 2 == 0 ? "#D6CBB4" : "#C7BBA2",
               shape: .cylinder, material: .matte)
    }
    for (k, p) in [(38.0, 69.0), (42.0, 71.5), (40.5, 67.8)].enumerated() {
        let x = Float(p.0), z = Float(p.1), yaw = Float(k) * 120
        m.deco("Duck", at: (x, 0.18, z), size: (0.5, 0.3, 0.7), color: "#FFFFFF", shape: .sphere, rotation: (0, yaw, 0))
        let head = Frame(x, z, yaw: yaw).at(0, 0.42, 0.3)
        m.deco("Duck Head", at: head, size: (0.26, 0.26, 0.26), color: k == 1 ? "#166534" : "#FFFFFF", shape: .sphere)
        m.deco("Duck Beak", at: Frame(x, z, yaw: yaw).at(0, 0.4, 0.48), size: (0.12, 0.08, 0.16), color: "#F59E0B")
    }
    m.bench(in: Frame(40, 79, yaw: 180))
    m.bench(in: Frame(49, 70, yaw: -90))
    m.table(30, 76, top: "#A86A3A", chairs: 4, chair: "#78350F", phase: .pi / 4)
    m.flowerBed(31, 64, w: 2.6, d: 1.6, colors: ["#F43F5E", "#FACC15", "#FFFFFF"], seed: "maple park 1")
    m.flowerBed(49, 76, w: 2.6, d: 1.6, colors: ["#A855F7", "#38BDF8", "#F472B6"], seed: "maple park 2")

    // Grass between it all: darker patches, tufts and wildflowers, kept off
    // the roads, the paving and the buildings.
    let keepOut: [(Float, Float, Float, Float)] = [
        (0, 0, 92, 7.5), (0, 45, 92, 6.5), (0, -45, 92, 6.5), (0, 0, 7.5, 92),
        (-60, 62, 8, 7), (-30, 62, 8, 7), (30, 62, 8, 7), (60, 62, 8, 7),
        (-60, 28, 8, 7), (-30, 28, 8, 7), (30, 28, 9, 7), (60, 28, 8, 7),
        (-60, -28, 8, 7), (-30, -28, 9, 7), (-12, -28, 8, 6.5), (40, 70, 15, 15),
        (-78, 12, 7, 7), (-78, -12, 9, 7), (78, -12, 8, 7), (78, 12, 9, 7), (-52, 12, 7, 6), (52, -12, 8, 6.5),
        (-52, -12, 8, 6.5), (-12, 34, 11, 6), (20, -58, 9, 7), (10, -12, 3, 3), (12, -8, 4, 3), (0, 0, 14, 14)
    ]
    func open(_ x: Float, _ z: Float, margin: Float) -> Bool {
        guard abs(x) < 88 - margin, abs(z) < 88 - margin else { return false }
        return !keepOut.contains { abs(x - $0.0) < $0.2 + margin && abs(z - $0.1) < $0.3 + margin }
    }
    var r = Seeded("maple bay grass")
    var patches = 0, tries = 0
    while patches < 36 && tries < 2000 {
        tries += 1
        let x = r.range(-86, 86), z = r.range(-86, 86), size = r.range(3, 7)
        guard open(x, z, margin: size / 2) else { continue }
        m.deco("Grass Patch", at: (x, 0.006 + Float(patches) * 0.0004, z), size: (size, 0.01, size * r.range(0.6, 1)),
               color: patches % 2 == 0 ? "#5FAE4E" : "#7CC66A", shape: .cylinder, material: .matte)
        patches += 1
    }
    var spots: [(Float, Float)] = []
    tries = 0
    while spots.count < 150 && tries < 4000 {
        tries += 1
        let x = r.range(-86, 86), z = r.range(-86, 86)
        if open(x, z, margin: 0.5) { spots.append((x, z)) }
    }
    m.tufts(spots, color: "#4E9A3F")
    var wild = 0
    tries = 0
    while wild < 45 && tries < 4000 {
        tries += 1
        let x = r.range(-86, 86), z = r.range(-86, 86)
        guard open(x, z, margin: 0.5) else { continue }
        m.flower(x, z, color: blooms[wild % blooms.count], size: 0.8)
        wild += 1
    }
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
    fruitSeasDetail(m)
}

/// Finishing touches, only to look at (nothing here is solid or tagged, and
/// no name is one a script looks for): surf round every beach with shells
/// and palms, a sign and a stone path at every dock, posts under the piers,
/// tents and a campfire where the enemies gather, torches round the boss
/// arenas, a paved town square with shop signs and shop furniture on Start
/// Island, and props that suit each island.
func fruitSeasDetail(_ m: MapBuilder) {
    struct Isle { let name: String, jp: String, level: String, x: Float, z: Float, r: Float, y: Float, beach: Bool, palms: Bool }
    let isles = [
        Isle(name: "Start Island", jp: "🏝 はじまりの島", level: "あんぜんな町", x: 0, z: 0, r: 22, y: 0.6, beach: true, palms: true),
        Isle(name: "Pirate Islet", jp: "🏴‍☠️ 海賊の小島", level: "Lv.1〜", x: 40, z: 32, r: 12, y: 0.6, beach: true, palms: true),
        Isle(name: "Jungle Island", jp: "🌴 ジャングル島", level: "Lv.10〜", x: 75, z: -40, r: 26, y: 0.6, beach: true, palms: true),
        Isle(name: "Desert Island", jp: "🏜 砂漠の島", level: "Lv.30〜", x: -80, z: -55, r: 30, y: 0.6, beach: true, palms: true),
        Isle(name: "Snow Island", jp: "❄️ 雪の島", level: "Lv.60〜", x: 10, z: 95, r: 22, y: 0.6, beach: true, palms: false),
        Isle(name: "Marine Fort", jp: "⚓ 海軍のとりで", level: "Lv.90〜", x: -95, z: 55, r: 22, y: 0.6, beach: true, palms: true),
        Isle(name: "Volcano Island", jp: "🌋 火山島", level: "Lv.130〜", x: 110, z: 75, r: 24, y: 0.6, beach: true, palms: false),
        Isle(name: "Sky Island", jp: "☁️ 空島", level: "Lv.180〜", x: -10, z: -115, r: 20, y: 40.2, beach: false, palms: false),
    ]
    let shells = ["#FBCFE8", "#FFFFFF", "#FDBA74", "#FDE68A", "#F87171"]
    for isle in isles {
        let x = isle.x, z = isle.z, r = isle.r, y = isle.y
        var rand = Seeded("fruit seas \(isle.name)")
        if isle.beach {
            // Surf round the beach, and shells and starfish on the sand.
            m.deco("Surf", at: (x, -0.19, z), size: (r * 2 + 8, 0.02, r * 2 + 8), color: "#E0F2FE", shape: .cylinder, opacity: 0.75)
            m.deco("Wet Sand", at: (x, 0.305, z), size: (r * 2 + 5.4, 0.01, r * 2 + 5.4), color: "#D9C48E", shape: .cylinder, material: .matte)
            for k in 0..<10 {
                let a = Float.pi / 2 + 0.5 + Float(k) * (2 * .pi - 1) / 10 + rand.range(-0.1, 0.1)
                let d = r + rand.range(0.8, 2.2)
                let star = k % 3 == 0
                m.deco(star ? "Starfish" : "Shell", at: (x + cos(a) * d, 0.34, z + sin(a) * d),
                       size: star ? (0.5, 0.06, 0.5) : (0.3, 0.14, 0.24), color: star ? "#FB923C" : shells[k % shells.count],
                       shape: star ? .cylinder : .sphere, rotation: (0, rand.range(0, 360), 0))
            }
            if isle.palms {
                for a: Float in [Float.pi / 2 + 1.4, Float.pi / 2 + 3.1, Float.pi / 2 + 4.6] {
                    let px = x + cos(a) * (r + 1.2), pz = z + sin(a) * (r + 1.2)
                    m.palm(px, pz, y: 0.3, height: rand.range(4.5, 6), lean: atan2(cos(a), sin(a)) * 180 / .pi)
                }
            }
        }
        // The dock: posts and bollards under the pier, a sign with the
        // island's name, and a stone path in toward the middle.
        let pierZ = z + r + 1
        for sx in [Float(-2.2), 2.2] {
            for dz in [Float(-2.5), 2.8] {
                m.deco("Pier Post", at: (x + sx, y - 0.9, pierZ + dz), size: (0.35, 2.2, 0.35), color: "#5C3A1E", shape: .cylinder)
            }
            m.deco("Pier Rope", at: (x + sx, y + 0.5, pierZ + 0.2), size: (0.06, 0.06, 6.4), color: "#E7D3A8")
            m.deco("Pier Bollard", at: (x + sx, y + 0.25, pierZ + 3.1), size: (0.3, 0.5, 0.3), color: "#374151", shape: .cylinder,
                   material: .metal)
        }
        m.signboard("\(isle.name) Welcome Sign", in: Frame(x + 3.4, z + r - 1.2, y: y, yaw: 0),
                    lines: [(isle.jp, "#FFFFFF"), (isle.level, "#FDE68A")], board: "#7C4A21", width: 3)
        var pz = z + r - 4.4
        var k = 0
        while pz > z + r * 0.45 {
            m.deco("Path Stone", at: (x + (k % 2 == 0 ? 0.25 : -0.25), y + 0.02, pz), size: (1.2, 0.04, 0.9),
                   color: k % 2 == 0 ? "#A8A29E" : "#C4BDB4", shape: .cylinder, material: .matte)
            pz -= 1.6
            k += 1
        }
        // A notice board by the quest giver.
        m.signboard("\(isle.name) Quest Board", in: Frame(x - 7, z + r - 6.8, y: y, yaw: 30), lines: [("❗ クエスト", "#FDE047")],
                    board: "#78350F", width: 1.8, height: 1.8, size: 0.8)
        guard isle.name != "Start Island" else { continue }
        // The camp: two tents, a campfire and a barrel.
        let cx = x + r * 0.35, cz = z - r * 0.3
        for (i, side) in [Float(-1), 1].enumerated() {
            let tx = cx + side * 2.6, tz = cz - 2.2
            m.deco("Camp Tent", at: (tx, y + 1.0, tz), size: (2.4, 2.0, 2.4), color: i == 0 ? "#78716C" : "#A16207", shape: .cone,
                   material: .matte)
            m.deco("Camp Tent Door", at: (tx, y + 0.5, tz + 1.0), size: (0.7, 1.0, 0.05), color: "#292524")
        }
        for k in 0..<3 {
            m.deco("Campfire Log", at: (cx, y + 0.12, cz + 0.6), size: (0.18, 0.18, 1.1), color: "#5C3A1E", shape: .cylinder,
                   rotation: (90, Float(k) * 60, 0))
        }
        m.deco("Campfire Flame", at: (cx, y + 0.45, cz + 0.6), size: (0.6, 0.7, 0.6), color: "#F97316", shape: .cone, material: .neon)
        m.barrel(cx + 3.2, cz + 1.6, y: y)
        // Torches on the boss arena's pillars, and a darker ring inside it.
        for p in ring(6, radius: 7, cx: x - r * 0.4, cz: z - r * 0.35) {
            m.deco("Pillar Bowl", at: (p.0, y + 3.6, p.1), size: (0.9, 0.2, 0.9), color: "#3A3A44", shape: .cylinder, material: .metal)
            m.deco("Pillar Flame", at: (p.0, y + 4.0, p.1), size: (0.55, 0.7, 0.55), color: isle.name == "Sky Island" ? "#A5F3FC" : "#FB923C",
                   shape: .cone, material: .neon)
        }
        m.deco("Arena Ring", at: (x - r * 0.4, y + 0.125, z - r * 0.35), size: (7, 0.01, 7), color: "#7F1D1D", shape: .cylinder,
               material: .matte)
    }

    // Start Island: a paved square round the spawn, signs and furniture in
    // the shops, a roof over the well and lanterns.
    let y: Float = 0.6
    for (rad, color, h) in [(Float(8), "#D6CBB4", Float(0.005)), (6.6, "#C7BBA2", 0.01), (3.2, "#D6CBB4", 0.015)] {
        m.deco("Town Square", at: (0, y + h, 0), size: (rad * 2, 0.01, rad * 2), color: color, shape: .cylinder, material: .matte)
    }
    for (i, p) in ring(12, radius: 7.3, phase: 0.26).enumerated() {
        m.deco("Square Stone", at: (p.0, y + 0.018, p.1), size: (0.8, 0.01, 0.8), color: i % 2 == 0 ? "#A8A29E" : "#B8AFA3",
               shape: .cylinder, material: .matte)
    }
    struct Stall { let name: String, text: String, x: Float, z: Float, f: Float, board: String }
    let stalls = [
        Stall(name: "Sword Dealer", text: "⚔️ 剣屋", x: -11, z: -11, f: 1, board: "#B45309"),
        Stall(name: "Fruit Dealer", text: "🍎 果実屋", x: 11, z: -11, f: 1, board: "#BE185D"),
        Stall(name: "Dojo", text: "🥋 道場", x: -12, z: 9, f: -1, board: "#1E3A8A"),
        Stall(name: "Gun Shop", text: "🔫 銃屋", x: 12, z: 9, f: -1, board: "#374151"),
    ]
    for s in stalls {
        let inside = Frame(s.x, s.z, y: y + 0.15, yaw: s.f > 0 ? 0 : 180)
        m.signboard("\(s.name) Entrance Sign", in: Frame(s.x + 2.6, s.z + s.f * 4.3, y: y, yaw: s.f > 0 ? 0 : 180),
                    lines: [(s.text, "#FFFFFF")], board: s.board, width: 2.2, height: 2)
        m.deco("Entrance Mat", in: inside, 0, 0.01, 2.2, size: (1.8, 0.02, 1.0), color: MapBuilder.shade(s.board, 0.25))
        switch s.name {
        case "Sword Dealer":
            for side in [Float(-1), 1] {
                m.deco("Sword Rack", in: inside, side * 3.4, 1.4, 0.4, size: (0.1, 0.12, 3.0), color: "#5C3A1E")
                for k in 0..<3 {
                    let dz = -0.8 + Float(k) * 0.9
                    m.deco("Sword Blade", in: inside, side * 3.5, 1.3, dz + 0.4, size: (0.05, 1.3, 0.14), color: "#E5E7EB", material: .metal)
                    m.deco("Sword Guard", in: inside, side * 3.5, 0.62, dz + 0.4, size: (0.08, 0.08, 0.5), color: "#CA8A04", material: .metal)
                    m.deco("Sword Hilt", in: inside, side * 3.5, 0.42, dz + 0.4, size: (0.09, 0.32, 0.09), color: ["#7F1D1D", "#1E3A8A", "#166534"][k],
                           shape: .cylinder)
                }
            }
            m.deco("Anvil", in: inside, 2.2, 0.35, 1.6, size: (0.9, 0.5, 0.45), color: "#4B5563", material: .metal)
        case "Fruit Dealer":
            for (i, side) in [Float(-1), 1].enumerated() {
                for k in 0..<2 {
                    let dz = Float(k) * 1.4 - 0.2
                    m.deco("Fruit Basket", in: inside, side * 3.0, 0.3, dz, size: (0.9, 0.45, 0.9), color: "#A16207", shape: .cylinder,
                           material: .matte)
                    for j in 0..<3 {
                        m.deco("Basket Fruit", in: inside, side * 3.0 + Float(j - 1) * 0.25, 0.6, dz + (j == 1 ? 0.15 : -0.1),
                               size: (0.3, 0.3, 0.3), color: [["#EF4444", "#A855F7", "#F97316"], ["#22C55E", "#FACC15", "#3B82F6"]][i][(j + k) % 3],
                               shape: .sphere, material: .neon)
                    }
                }
            }
            m.deco("Fruit Poster", in: inside, 0, 2.6, -2.75, size: (1.6, 1.0, 0.04), color: "#FBCFE8")
            m.deco("Fruit Poster Fruit", in: inside, 0, 2.6, -2.7, size: (0.6, 0.6, 0.06), color: "#9333EA", shape: .sphere, material: .neon)
        case "Dojo":
            for side in [Float(-1), 1] {
                m.deco("Tatami", in: inside, side * 2.2, 0.01, 0.6, size: (1.8, 0.03, 3.4), color: "#D9C48E", material: .matte)
                m.deco("Tatami Edge", in: inside, side * 2.2, 0.02, 0.6, size: (1.85, 0.02, 0.12), color: "#14532D")
            }
            let d = inside.at(2.6, 0, 1.2)
            m.deco("Dummy Post", at: (d.0, d.1 + 0.6, d.2), size: (0.16, 1.2, 0.16), color: "#5C3A1E", shape: .cylinder)
            m.deco("Dummy Body", at: (d.0, d.1 + 1.3, d.2), size: (0.6, 0.8, 0.4), color: "#D6A15E", shape: .cylinder)
            m.deco("Dummy Head", at: (d.0, d.1 + 1.9, d.2), size: (0.4, 0.4, 0.4), color: "#E9C48A", shape: .sphere)
            m.deco("Dummy Arms", in: Frame(d.0, d.2, y: d.1, yaw: inside.yaw), 0, 1.45, 0, size: (1.2, 0.12, 0.12), color: "#5C3A1E")
            m.deco("Dojo Scroll", in: inside, -1.4, 2.4, -2.75, size: (0.7, 1.4, 0.04), color: "#FEF3C7")
            m.deco("Dojo Scroll Mark", in: inside, -1.4, 2.5, -2.71, size: (0.3, 0.6, 0.02), color: "#111827")
        default:
            m.deco("Gun Rack", in: inside, -3.5, 1.5, 0.4, size: (0.08, 1.4, 2.6), color: "#5C3A1E")
            for k in 0..<3 {
                m.deco("Rack Gun", in: inside, -3.42, 1.0 + Float(k) * 0.42, 0.4, size: (0.08, 0.16, 1.4), color: "#1F2937", material: .metal)
                m.deco("Rack Gun Grip", in: inside, -3.42, 0.9 + Float(k) * 0.42, 0.85, size: (0.08, 0.3, 0.16), color: "#78350F")
            }
            for (k, c) in ["#FFFFFF", "#EF4444", "#FFFFFF", "#EF4444"].enumerated() {
                m.deco("Target", in: inside, 1.6, 2.2, -2.73 + Float(k) * 0.01, size: (1.2 - Float(k) * 0.3, 0.02, 1.2 - Float(k) * 0.3),
                       color: c, shape: .cylinder, tilt: (90, 0))
            }
        }
    }
    // The gacha well gets a roof on two posts and a bucket.
    for side in [Float(-1), 1] {
        m.deco("Well Post", at: (side * 1.4, y + 1.4, 8), size: (0.16, 2.8, 0.16), color: "#5C3A1E", shape: .cylinder)
    }
    m.deco("Well Roof", at: (0, y + 3.3, 8), size: (3.4, 1.0, 2.4), color: "#B45309", shape: .cone, material: .matte)
    m.deco("Well Bucket", at: (0.5, y + 2.2, 8), size: (0.35, 0.35, 0.35), color: "#8B5A2B", shape: .cylinder)
    m.deco("Stat Stone Ring", at: (0, y + 0.02, -6), size: (2.6, 0.02, 2.6), color: "#C4B5FD", shape: .cylinder, material: .neon)
    for p in ring(6, radius: 9) { m.torch(p.0, p.1, y: y, height: 1.6) }
    m.flowerBed(-5.5, 13, y: y, w: 2.6, d: 1.2, colors: ["#F43F5E", "#FACC15", "#FFFFFF"], seed: "start bed 1")
    m.flowerBed(5.5, 13, y: y, w: 2.6, d: 1.2, colors: ["#FB923C", "#A855F7", "#38BDF8"], seed: "start bed 2")
    for p in [(-6.5, -14.5), (6.5, -14.5), (-16, 3), (16, 3)] {
        m.barrel(Float(p.0), Float(p.1), y: y)
    }
    for (i, p) in ring(5, radius: 11, phase: 2.2).enumerated() { m.bush(p.0, p.1, y: y, color: i % 2 == 0 ? "#2F8F3A" : "#4CAF50") }

    // Pirate Islet: barrels, a pile of gold, a skull on the flag, a wreck.
    for (i, p) in [(35.5, 34.0), (36.4, 35.0), (48.0, 31.0)].enumerated() { m.barrel(Float(p.0), Float(p.1), y: y, color: i == 2 ? "#78350F" : "#8B5A2B") }
    for k in 0..<6 {
        m.deco("Gold Coin Pile", at: (42 + Float(k % 3) * 0.35, y + 0.15 + Float(k / 3) * 0.2, 37 + Float(k % 2) * 0.3), size: (0.4, 0.25, 0.4),
               color: "#FACC15", shape: .sphere, material: .metal)
    }
    m.deco("Pirate Skull", at: (45.2, 5.9, 36.08), size: (0.5, 0.5, 0.05), color: "#FFFFFF", shape: .cylinder, rotation: (90, 0, 0))
    m.deco("Wreck Hull", at: (55, -0.1, 20), size: (2.2, 1.0, 5.5), color: "#5C3A1E", rotation: (0, 30, 18))
    m.deco("Wreck Mast", at: (55.4, 1.0, 20.3), size: (0.2, 3.2, 0.2), color: "#78350F", shape: .cylinder, rotation: (0, 0, 35))
    m.deco("Wreck Sail", at: (56.0, 1.6, 20.4), size: (0.05, 1.4, 1.6), color: "#E7E5E4", rotation: (0, 30, 30), opacity: 0.85)
    m.deco("Pirate Cannon", at: (46.5, y + 0.4, 34.5), size: (0.5, 0.5, 1.6), color: "#1F2937", shape: .cylinder, material: .metal, rotation: (80, 40, 0))
    m.deco("Pirate Cannon Wheels", at: (46.5, y + 0.25, 34.5), size: (1.0, 0.5, 0.5), color: "#5C3A1E", rotation: (0, 40, 0))

    // Jungle Island: ferns, mushrooms, mossy rocks and an old stone idol.
    var jr = Seeded("jungle props")
    for k in 0..<14 {
        let a = jr.range(0, 2 * .pi), d = jr.range(4, 22)
        let px = 75 + cos(a) * d, pz = -40 + sin(a) * d
        if k % 2 == 0 {
            m.deco("Fern", at: (px, y + 0.35, pz), size: (1.4, 0.7, 1.4), color: "#15803D", shape: .cone, material: .matte)
        } else {
            m.deco("Mushroom Stem", at: (px, y + 0.25, pz), size: (0.2, 0.5, 0.2), color: "#FEF3C7", shape: .cylinder)
            m.deco("Mushroom Cap", at: (px, y + 0.55, pz), size: (0.6, 0.3, 0.6), color: k % 4 == 1 ? "#DC2626" : "#F59E0B", shape: .sphere)
        }
    }
    for p in [(62.0, -30.0), (88.0, -50.0), (70.0, -58.0), (90.0, -28.0)] {
        m.deco("Mossy Rock", at: (Float(p.0), y + 0.4, Float(p.1)), size: (1.8, 1.0, 1.4), color: "#6B7280", shape: .sphere, material: .matte)
        m.deco("Moss", at: (Float(p.0), y + 0.85, Float(p.1)), size: (1.3, 0.25, 1.0), color: "#4D7C0F", shape: .sphere, material: .matte)
    }
    m.deco("Idol Base", at: (75, y + 0.4, -30), size: (2.0, 0.8, 2.0), color: "#78716C", material: .matte)
    m.deco("Idol", at: (75, y + 1.9, -30), size: (1.2, 2.2, 1.0), color: "#A8A29E", material: .matte)
    for side in [Float(-1), 1] {
        m.deco("Idol Eye", at: (75 + side * 0.28, y + 2.4, -29.48), size: (0.22, 0.22, 0.05), color: "#22C55E", material: .neon)
    }
    m.deco("Idol Mouth", at: (75, y + 1.7, -29.48), size: (0.6, 0.14, 0.05), color: "#292524")

    // Desert Island: arms on the cacti, dunes, an oasis, bones, a door in
    // the pyramid.
    for p in ring(8, radius: 22, cx: -80, cz: -55) {
        for (side, h) in [(Float(-1), Float(2.2)), (1, 2.7)] {
            m.deco("Cactus Arm", at: (p.0 + side * 0.65, h, p.1), size: (0.9, 0.35, 0.35), color: "#4D7C0F", shape: .cylinder,
                   rotation: (0, 0, 90))
            m.deco("Cactus Arm", at: (p.0 + side * 1.0, h + 0.45, p.1), size: (0.35, 0.9, 0.35), color: "#4D7C0F", shape: .cylinder)
        }
        m.deco("Cactus Flower", at: (p.0, 3.5, p.1), size: (0.3, 0.2, 0.3), color: "#F472B6", shape: .sphere)
    }
    for (k, p) in [(-68.0, -70.0), (-95.0, -66.0), (-70.0, -45.0), (-86.0, -75.0), (-100.0, -50.0)].enumerated() {
        m.deco("Dune", at: (Float(p.0), y - 0.1, Float(p.1)), size: (5 + Float(k), 1.2, 3.5), color: "#F0DFA8", shape: .sphere, material: .matte,
               rotation: (0, Float(k) * 40, 0))
    }
    m.deco("Oasis", at: (-66, y + 0.02, -58), size: (6, 0.03, 4.5), color: "#38BDF8", shape: .cylinder, material: .glass, opacity: 0.85)
    for (k, p) in [(-63.5, -60.0), (-68.5, -60.5), (-65.0, -55.5)].enumerated() {
        m.palm(Float(p.0), Float(p.1), y: y, height: 4.5 + Float(k) * 0.6, lean: Float(k) * 120)
    }
    m.deco("Bone", at: (-74, y + 0.08, -64), size: (1.2, 0.14, 0.14), color: "#F5F5F4", shape: .cylinder, rotation: (0, 30, 90))
    m.deco("Skull", at: (-73.3, y + 0.2, -64.8), size: (0.45, 0.4, 0.45), color: "#F5F5F4", shape: .sphere)
    m.deco("Pyramid Door", at: (-92, y + 0.9, -34.6), size: (1.6, 1.8, 0.1), color: "#292524")

    // Snow Island: snowmen, an igloo, ice crystals and snow drifts.
    for (k, p) in [(2.0, 88.0), (20.0, 100.0), (4.0, 104.0)].enumerated() {
        let sx = Float(p.0), sz = Float(p.1)
        m.deco("Snowman", at: (sx, y + 0.5, sz), size: (1.1, 1.0, 1.1), color: "#FFFFFF", shape: .sphere, material: .matte)
        m.deco("Snowman", at: (sx, y + 1.3, sz), size: (0.8, 0.75, 0.8), color: "#FFFFFF", shape: .sphere, material: .matte)
        m.deco("Snowman Head", at: (sx, y + 1.9, sz), size: (0.55, 0.55, 0.55), color: "#FFFFFF", shape: .sphere, material: .matte)
        m.deco("Snowman Nose", at: (sx, y + 1.9, sz + 0.35), size: (0.1, 0.1, 0.3), color: "#F97316", shape: .cone, rotation: (90, 0, 0))
        m.deco("Snowman Hat", at: (sx, y + 2.25, sz), size: (0.45, 0.35, 0.45), color: ["#1F2937", "#DC2626", "#2563EB"][k], shape: .cylinder)
    }
    m.deco("Igloo", at: (-2, y, 98), size: (4, 3, 4), color: "#F1F5F9", shape: .sphere, material: .matte)
    m.deco("Igloo Door", at: (-2, y + 0.6, 100.1), size: (1.2, 1.2, 0.8), color: "#CBD5E1", shape: .cylinder, rotation: (90, 0, 0))
    for (k, p) in ring(6, radius: 9, cx: 10, cz: 95, phase: 0.4).enumerated() {
        m.deco("Ice Crystal", at: (p.0, y + 0.7, p.1), size: (0.5, 1.4 + Float(k % 3) * 0.4, 0.5), color: "#A5F3FC", shape: .cone,
               material: .glass, opacity: 0.8)
    }
    for p in ring(5, radius: 19, cx: 10, cz: 95, phase: 1.1) {
        m.deco("Snow Drift", at: (p.0, y, p.1), size: (3, 0.8, 2), color: "#FFFFFF", shape: .sphere, material: .matte)
    }

    // Marine Fort: flags on the tower, crates, cannonballs and sandbags.
    for p in ring(4, radius: 1.6, cx: -95, cz: 55, phase: .pi / 4) {
        m.deco("Fort Flag Pole", at: (p.0, 11, p.1), size: (0.08, 3, 0.08), color: "#D1D5DB", shape: .cylinder)
        m.deco("Fort Flag", at: (p.0 + 0.45, 12, p.1), size: (0.8, 0.5, 0.03), color: "#1D4ED8")
    }
    for (k, p) in [(-106.0, 64.0), (-86.0, 64.0), (-100.0, 66.0)].enumerated() {
        m.deco("Fort Crate", at: (Float(p.0), y + 0.4, Float(p.1)), size: (0.8, 0.8, 0.8), color: "#A16207")
        m.deco("Fort Crate", at: (Float(p.0) + 0.85, y + 0.4, Float(p.1)), size: (0.8, 0.8, 0.8), color: "#92400E")
        if k != 1 { m.deco("Fort Crate", at: (Float(p.0) + 0.4, y + 1.2, Float(p.1)), size: (0.8, 0.8, 0.8), color: "#B45309") }
    }
    for p in ring(4, radius: 12, cx: -95, cz: 55) {
        for k in 0..<3 {
            m.deco("Cannonball", at: (p.0 + 0.9 + Float(k) * 0.3, y + 0.15, p.1 + 0.9), size: (0.3, 0.3, 0.3), color: "#111827",
                   shape: .sphere, material: .metal)
        }
    }
    for k in 0..<6 {
        m.deco("Sandbag", at: (-99 + Float(k % 3) * 1.0, y + 0.2 + Float(k / 3) * 0.35, 40.6), size: (0.95, 0.35, 0.55),
               color: "#C8B68A", shape: .sphere, material: .matte)
    }

    // Volcano Island: smoke over the crater, glowing cracks, rocks, dead trees.
    for k in 0..<4 {
        m.deco("Smoke", at: (118 + Float(k % 2) * 0.8, 11.2 + Float(k) * 1.4, 66 - Float(k) * 0.5), size: (2.4 + Float(k), 1.6 + Float(k) * 0.5, 2.4 + Float(k)),
               color: "#57534E", shape: .sphere, material: .matte, opacity: 0.7 - Float(k) * 0.1)
    }
    var vr = Seeded("volcano props")
    for k in 0..<10 {
        let a = vr.range(0, 2 * .pi), d = vr.range(5, 21)
        let px = 110 + cos(a) * d, pz = 75 + sin(a) * d
        if k % 3 == 0 {
            m.deco("Lava Crack", at: (px, y + 0.02, pz), size: (0.25, 0.02, 2.2), color: "#F97316", material: .neon, rotation: (0, vr.range(0, 180), 0))
        } else {
            m.deco("Volcanic Rock", at: (px, y + 0.3, pz), size: (1.0, 0.7, 0.8), color: "#1C1917", shape: .sphere, material: .matte)
        }
    }
    for p in [(100.0, 84.0), (122.0, 82.0), (98.0, 68.0)] {
        m.deco("Dead Tree", at: (Float(p.0), y + 1.4, Float(p.1)), size: (0.3, 2.8, 0.3), color: "#292524", shape: .cylinder)
        m.deco("Dead Branch", at: (Float(p.0) + 0.4, y + 2.3, Float(p.1)), size: (0.14, 1.2, 0.14), color: "#292524", shape: .cylinder,
               rotation: (0, 0, -40))
    }

    // Sky Island: a ring of columns, golden orbs and small clouds.
    for (k, p) in ring(8, radius: 15, cx: -10, cz: -115, phase: 0.2).enumerated() {
        let sy: Float = 40.2
        m.deco("Sky Column Base", at: (p.0, sy + 0.2, p.1), size: (1.2, 0.4, 1.2), color: "#E9D5FF", material: .matte)
        m.deco("Sky Column", at: (p.0, sy + 2.0, p.1), size: (0.7, 3.2, 0.7), color: "#F5F3FF", shape: .cylinder)
        m.deco("Sky Column Top", at: (p.0, sy + 3.75, p.1), size: (1.2, 0.3, 1.2), color: "#E9D5FF", material: .matte)
        if k % 2 == 0 {
            m.deco("Sky Orb", at: (p.0, sy + 4.3, p.1), size: (0.6, 0.6, 0.6), color: "#FDE047", shape: .sphere, material: .neon)
        }
    }
    for p in ring(5, radius: 9, cx: -10, cz: -115, phase: 0.9) {
        m.deco("Sky Puff", at: (p.0, 40.6, p.1), size: (2.0, 0.8, 1.4), color: "#FFFFFF", shape: .sphere, material: .matte, opacity: 0.9)
    }

    // Out at sea: buoys, rocks and far-off sailboats, away from the islands.
    var sr = Seeded("fruit seas sea")
    var buoys = 0, tries = 0
    while buoys < 14 && tries < 500 {
        tries += 1
        let bx = sr.range(-150, 150), bz = sr.range(-150, 150)
        guard !isles.contains(where: { ((bx - $0.x) * (bx - $0.x) + (bz - $0.z) * (bz - $0.z)).squareRoot() < $0.r + 8 }) else { continue }
        if buoys % 2 == 0 {
            m.deco("Buoy", at: (bx, -0.05, bz), size: (0.7, 0.7, 0.7), color: buoys % 4 == 0 ? "#EF4444" : "#FACC15", shape: .sphere)
            m.deco("Buoy Light", at: (bx, 0.45, bz), size: (0.12, 0.4, 0.12), color: "#F8FAFC", shape: .cylinder, material: .neon)
        } else {
            m.deco("Sea Rock", at: (bx, -0.2, bz), size: (2.4, 1.4, 1.8), color: "#6B7280", shape: .sphere, material: .matte)
        }
        buoys += 1
    }
    for (k, p) in [(140.0, -20.0), (-140.0, 0.0), (60.0, 140.0), (-60.0, -150.0)].enumerated() {
        let bx = Float(p.0), bz = Float(p.1), yaw = Float(k) * 70
        let f = Frame(bx, bz, y: 0, yaw: yaw)
        m.deco("Sailboat Hull", in: f, 0, -0.05, 0, size: (1.6, 0.7, 4.5), color: k % 2 == 0 ? "#7C2D12" : "#1E3A8A")
        m.deco("Sailboat Mast", in: f, 0, 2.2, 0, size: (0.15, 4, 0.15), color: "#5C3A1E", shape: .cylinder)
        m.deco("Sailboat Sail", in: f, 0, 2.4, 0.5, size: (0.05, 3, 1.8), color: "#F8FAFC")
        m.deco("Sailboat Flag", in: f, 0, 4.4, 0.2, size: (0.04, 0.35, 0.6), color: "#EF4444")
    }
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
    // What each sign says: the place a pet asks for, as the game calls it.
    let signWords = ["Food Stand": "🍖 フードスタンド", "Water Well": "💧 井戸", "Pet Beds": "💤 ペットベッド", "Bath House": "🛁 おふろ屋さん",
                     "Playground": "⚽ 公園", "Vet Clinic": "🏥 どうぶつ病院", "Campsite": "⛺ キャンプ場", "School": "🏫 学校",
                     "Pizza Place": "🍕 ピザ屋さん", "Beach": "🏖 ビーチ"]
    for n in needs {
        m.slab("\(n.0) Base", x: n.2, y: 0, z: n.3, w: 12, h: 0.3, d: 12, color: "#FFFFFF")
        m.pad(n.0, x: n.2, z: n.3, y: 0.3, size: 6, color: n.1, tags: ["need", n.4])
        m.pillar("\(n.0) Post", x: n.2 + 5, z: n.3 - 5, y: 0.3, height: 3.5, radius: 0.3, color: n.1)
        let sign = m.part("\(n.0) Sign", at: (n.2 + 5, 4.2, n.3 - 5), size: (2.4, 1.2, 0.2), color: n.1, material: .neon, solid: false)
        m.label(sign, [(signWords[n.0] ?? n.0, "#FFFFFF")], height: 0.25, size: 1, range: 60)
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
    petHomeDetail(m)
}

/// Finishing touches, only to look at (nothing here is solid or tagged, and
/// no name is one a script looks for): sidewalks and crossings on Pet Road,
/// a plaza with a pet statue, balloons, benches and bunting, paw-print
/// trails, signs at every building, nests and shelves inside, props at every
/// place a pet asks for, and grass and wildflowers in between.
func petHomeDetail(_ m: MapBuilder) {
    let walk = "#F5E6E8", curb = "#E9B8C4", seam = "#E5CBD1"
    for side in [Float(-1), 1] {
        for (a, b) in [(Float(14.5), Float(55)), (69, 94), (-55, -14.5), (-94, -69)] {
            m.sidewalk(x: a, b, z: side * 4.5, curbZ: side * 3.6, color: walk, curb: curb, seam: seam)
        }
        for (a, b) in [(Float(14.5), Float(22)), (34, 55), (68, 94), (-33, -14.5), (-78, -47)] {
            m.sidewalk(z: a, b, x: side * 4.5, curbX: side * 3.6, color: walk, curb: curb, seam: seam)
        }
        m.crosswalk(side * 16.5, 0, across: 7, yaw: 90)
        m.crosswalk(0, side * 16.5, across: 7, yaw: 0)
    }

    // The plaza: rings of pink paving, a golden pet on a pedestal in the
    // middle, balloons, benches, planters and bunting between the lamps.
    for (r, color, y) in [(Float(12.5), "#FBCFE8", Float(0.065)), (11, "#FDE2E4", 0.07), (3.6, "#F9A8D4", 0.075)] {
        m.deco("Plaza Paving", at: (0, y, 0), size: (r * 2, 0.01, r * 2), color: color, shape: .cylinder, material: .matte)
    }
    let gold = "#FCD34D"
    m.deco("Statue Pedestal", at: (0, 0.5, 0), size: (2.4, 1, 2.4), color: "#F5F5F4", shape: .cylinder, material: .matte)
    m.deco("Statue Pedestal Trim", at: (0, 1.02, 0), size: (2.7, 0.12, 2.7), color: "#F9A8D4", shape: .cylinder)
    m.deco("Statue Body", at: (0, 1.85, 0), size: (1.1, 0.9, 1.7), color: gold, shape: .sphere, material: .metal)
    for (dx, dz) in [(Float(-0.35), Float(0.5)), (0.35, 0.5), (-0.35, -0.5), (0.35, -0.5)] {
        m.deco("Statue Leg", at: (dx, 1.38, dz), size: (0.28, 0.6, 0.28), color: gold, shape: .cylinder, material: .metal)
    }
    m.deco("Statue Head", at: (0, 2.55, 0.85), size: (0.9, 0.85, 0.85), color: gold, shape: .sphere, material: .metal)
    m.deco("Statue Snout", at: (0, 2.4, 1.3), size: (0.45, 0.35, 0.4), color: gold, shape: .sphere, material: .metal)
    m.deco("Statue Nose", at: (0, 2.48, 1.5), size: (0.16, 0.12, 0.1), color: "#1F2937", shape: .sphere)
    for side in [Float(-1), 1] {
        m.deco("Statue Ear", at: (side * 0.38, 2.95, 0.75), size: (0.3, 0.45, 0.15), color: "#F59E0B", shape: .sphere, material: .metal,
               rotation: (0, 0, side * 20))
        m.deco("Statue Eye", at: (side * 0.2, 2.68, 1.24), size: (0.12, 0.12, 0.06), color: "#1F2937", shape: .sphere)
    }
    m.deco("Statue Tail", at: (0, 2.25, -0.95), size: (0.2, 0.7, 0.2), color: gold, shape: .cone, material: .metal, rotation: (-35, 0, 0))
    m.deco("Statue Collar", at: (0, 2.2, 0.75), size: (0.75, 0.12, 0.6), color: "#EF4444", shape: .cylinder)
    let balloons = ["#F43F5E", "#FACC15", "#38BDF8", "#A855F7", "#22C55E", "#FB923C", "#F472B6", "#FFFFFF"]
    for (i, p) in ring(8, radius: 13.2, phase: .pi / 8).enumerated() {
        m.deco("Balloon String", at: (p.0, 1.5, p.1), size: (0.03, 3, 0.03), color: "#E5E7EB", shape: .cylinder)
        m.deco("Balloon", at: (p.0, 3.4, p.1), size: (0.8, 1.0, 0.8), color: balloons[i], shape: .sphere)
    }
    for p in ring(4, radius: 10, phase: .pi / 4) {
        m.bench(in: Frame(p.0, p.1, yaw: atan2(-p.0, -p.1) * 180 / .pi), color: "#F9A8D4", metal: "#FFFFFF")
    }
    for (i, p) in ring(8, radius: 10.2, phase: .pi / 4 - 0.38).enumerated() where i % 2 == 0 {
        m.planter(p.0, p.1, pot: "#F9A8D4", bloom: balloons[i])
    }
    for (i, p) in ring(8, radius: 10.2, phase: .pi / 4 + 0.38).enumerated() where i % 2 == 0 {
        m.planter(p.0, p.1, pot: "#C4B5FD", bloom: balloons[i + 1])
    }
    let corners: [V] = [(12, 3.25, 12), (-12, 3.25, 12), (-12, 3.25, -12), (12, 3.25, -12)]
    for i in 0..<4 {
        m.pennants(from: corners[i], to: corners[(i + 1) % 4], count: 9, colors: ["#F472B6", "#FDE047", "#67E8F9", "#C4B5FD", "#86EFAC"])
    }
    m.signboard("Welcome Sign", in: Frame(9, 16.5, yaw: 180 + 28.6), lines: [("🐾 ペットホーム・パラダイス", "#FFFFFF"), ("Pet Home Paradise", "#FDE68A")],
                board: "#DB2777", width: 4.4)

    // Paw prints: a ring round the spawn, and trails out to the pet beds and
    // the bath house.
    for p in ring(10, radius: 8.4, phase: 0.31) {
        m.pawPrint(p.0, p.1, y: 0.075, yaw: atan2(-p.1, p.0) * 180 / .pi, color: "#EC4899", size: 0.9)
    }
    for (from, to) in [((Float(-17), Float(8)), (Float(-54), Float(25))), ((17, 8), (54, 25))] {
        let dx = to.0 - from.0, dz = to.1 - from.1
        let length = (dx * dx + dz * dz).squareRoot()
        let yaw = atan2(dx, dz) * 180 / .pi
        for k in 0..<10 {
            let t = Float(k) / 9
            let off: Float = k % 2 == 0 ? 0.35 : -0.35
            m.pawPrint(from.0 + dx * t + off * dz / length, from.1 + dz * t - off * dx / length, y: 0.012, yaw: yaw, color: "#F9A8D4")
        }
    }

    // A sign by every building.
    for (name, text, x, z, yaw, board) in [
        ("Nursery", "🥚 ナーサリー", Float(8), Float(-32.6), Float(0), "#DB2777"),
        ("Pet Shop", "🛒 ペットショップ", -34.4, -33.6, 0, "#EA580C"),
        ("Neon Cave", "✨ ネオンの洞くつ", 47.5, -32.6, 0, "#6D28D9"),
        ("Trade Plaza", "🤝 トレード", 9.6, 28, 90, "#D97706"),
        ("Show Stage", "🏆 ペットショー", 12.5, 56, 180, "#E11D48"),
    ] {
        m.signboard("\(name) Entrance Sign", in: Frame(x, z, yaw: yaw), lines: [(text, "#FFFFFF")], board: board, width: 3)
    }

    // The nursery: a straw nest and a warm lamp over every egg, shelves of
    // little eggs on the side walls, a rug and plants in the corners.
    let floorY: Float = 0.15
    for ex in [Float(-11), -5.5, 0, 5.5, 11] {
        m.deco("Nest", at: (ex, 0.92, -43), size: (1.7, 0.28, 1.7), color: "#C08A4B", shape: .cylinder, material: .matte)
        m.deco("Nest Straw", at: (ex, 1.07, -43), size: (1.4, 0.04, 1.4), color: "#E9C48A", shape: .cylinder, material: .matte)
        m.deco("Lamp Cord", at: (ex, 3.95, -43), size: (0.04, 1.1, 0.04), color: "#3A3A44", shape: .cylinder)
        m.deco("Warm Lamp Shade", at: (ex, 3.25, -43), size: (0.8, 0.45, 0.8), color: "#F472B6", shape: .cone)
        m.deco("Warm Lamp", at: (ex, 3.0, -43), size: (0.3, 0.3, 0.3), color: "#FDE68A", shape: .sphere, material: .neon)
    }
    m.deco("Nursery Wall Band", at: (0, 1.0, -45.75), size: (29, 0.35, 0.05), color: "#F9A8D4")
    for k in 0..<6 {
        m.deco("Nursery Wall Dot", at: (-12.5 + Float(k) * 5, 2.6, -45.75), size: (0.7, 0.7, 0.04), color: balloons[k], shape: .cylinder,
               rotation: (90, 0, 0))
    }
    m.rug(0, -36.6, y: floorY, w: 8, d: 2.4, color: "#FFE4E6", border: "#F472B6")
    for p in [(-13.5, -35.6), (13.5, -35.6), (-13.5, -45.0), (13.5, -45.0)] {
        m.planter(Float(p.0), Float(p.1), y: floorY, pot: "#FBCFE8", bloom: "#F43F5E")
    }
    for side in [Float(-1), 1] {
        m.shelf(in: Frame(side * 14.4, -40, y: floorY, yaw: side < 0 ? 90 : -90), width: 3, height: 2, color: "#FBCFE8",
                goods: ["#F5F5F4", "#FDE68A", "#4ADE80", "#38BDF8", "#C4B5FD"], goodsShape: .sphere)
    }

    // The pet shop: shelves of food, toys and potions behind the counters,
    // a fish tank and a pet bed on show.
    for (x, goods, shape) in [(Float(-48), ["#F97316", "#DC2626", "#FACC15"], BlockShape.cylinder),
                              (-42, ["#22C55E", "#3B82F6", "#F43F5E"], .sphere),
                              (-36, ["#A855F7", "#E879F9", "#67E8F9"], .cylinder)] {
        m.shelf(in: Frame(x, -44.45, y: floorY), width: 3.4, height: 2.2, color: "#A16207", goods: goods, goodsShape: shape)
    }
    m.deco("Fish Tank Stand", at: (-49.6, 0.55, -37), size: (1.6, 0.8, 0.9), color: "#78350F")
    m.deco("Fish Tank", at: (-49.6, 1.4, -37), size: (1.5, 0.9, 0.8), color: "#7DD3FC", material: .glass, opacity: 0.55)
    m.deco("Fish Tank Gravel", at: (-49.6, 1.0, -37), size: (1.45, 0.08, 0.75), color: "#FDE68A", material: .matte)
    m.deco("Fish", at: (-49.9, 1.45, -37), size: (0.3, 0.18, 0.1), color: "#F97316", shape: .sphere)
    m.deco("Fish", at: (-49.2, 1.6, -36.9), size: (0.25, 0.15, 0.1), color: "#FACC15", shape: .sphere)
    m.deco("Pet Cushion", at: (-35, 0.3, -37), size: (1.6, 0.3, 1.6), color: "#F472B6", shape: .cylinder)
    m.deco("Pet Cushion Middle", at: (-35, 0.42, -37), size: (1.1, 0.1, 1.1), color: "#FBCFE8", shape: .cylinder)
    m.deco("Bone Sign", at: (-42, 3.0, -44.75), size: (1.6, 0.35, 0.05), color: "#FFFFFF")
    for side in [Float(-1), 1] {
        m.deco("Bone Sign End", at: (-42 + side * 0.85, 3.0, -44.75), size: (0.5, 0.6, 0.06), color: "#FFFFFF", shape: .cylinder,
               rotation: (90, 0, 0))
    }

    // The neon cave: glowing mushrooms, crystals on the walls, stars above
    // and a glowing ring round the altar.
    let glow = ["#22D3EE", "#E879F9", "#A3E635", "#FDE047"]
    for (k, p) in [(35.5, -44.5), (48.5, -44.5), (35.5, -37.0), (48.5, -37.0), (39.0, -45.0), (45.0, -45.0)].enumerated() {
        m.deco("Glow Mushroom Stem", at: (Float(p.0), 0.3, Float(p.1)), size: (0.2, 0.6, 0.2), color: "#E0E7FF", shape: .cylinder)
        m.deco("Glow Mushroom Cap", at: (Float(p.0), 0.65, Float(p.1)), size: (0.7, 0.35, 0.7), color: glow[k % 4], shape: .sphere,
               material: .neon)
    }
    for k in 0..<8 {
        let onLeft = k < 4
        let z = -44 + Float(k % 4) * 2.6
        m.deco("Wall Crystal", at: (onLeft ? 34.7 : 49.3, 2.2 + Float(k % 2) * 0.8, z), size: (0.4, 1.1, 0.4), color: glow[k % 4],
               shape: .cone, material: .neon, rotation: (0, 0, onLeft ? -30 : 30))
    }
    for p in grid(4, 2, spacing: 3.2, cx: 42, cz: -40) {
        m.deco("Cave Star", at: (p.0, 4.85, p.1), size: (0.22, 0.22, 0.22), color: "#FFFFFF", shape: .sphere, material: .neon)
    }
    m.deco("Altar Glow", at: (42, 0.02, -41), size: (6, 0.02, 6), color: "#7C3AED", shape: .cylinder, material: .neon, opacity: 0.6)

    // The show stage: posts under the arch, curtains, spotlights, stars,
    // a carpet, and benches for the audience.
    for side in [Float(-1), 1] {
        m.deco("Show Arch Post", at: (side * 10, 3, 66), size: (0.6, 4, 0.6), color: "#F472B6", shape: .cylinder)
        m.deco("Show Curtain", at: (side * 9.1, 2.9, 65.6), size: (1.4, 3.8, 0.15), color: "#BE123C", material: .matte)
    }
    m.deco("Show Valance", at: (0, 4.3, 65.6), size: (19, 0.5, 0.15), color: "#9F1239", material: .matte)
    for k in 0..<4 {
        let sx = -6 + Float(k) * 4
        m.deco("Spotlight", at: (sx, 5.7, 66), size: (0.5, 0.6, 0.5), color: "#1F2937", shape: .cylinder, material: .metal, rotation: (-30, 0, 0))
        m.deco("Spotlight Lens", at: (sx, 5.55, 65.75), size: (0.4, 0.05, 0.4), color: "#FEF9C3", shape: .cylinder, material: .neon,
               rotation: (-30, 0, 0))
    }
    for k in 0..<5 {
        m.deco("Show Star", at: (-8 + Float(k) * 4, 6.0, 66.3), size: (0.5, 0.5, 0.2), color: "#FDE047", shape: .sphere, material: .neon)
    }
    m.deco("Stage Carpet", at: (0, 1.01, 61), size: (5, 0.02, 7), color: "#E11D48", material: .matte)
    for (bx, bz) in [(Float(-8), Float(47)), (8, 47), (-8, 50.5), (8, 50.5)] {
        m.bench(in: Frame(bx, bz, yaw: 0), color: "#FDE68A", metal: "#F472B6")
    }

    // The trade plaza: two little stalls, gift boxes and a pair of scales.
    for side in [Float(-1), 1] {
        let sx = side * 6.3
        m.deco("Trade Stall", at: (sx, 0.55, 30.5), size: (2.4, 0.9, 1.0), color: "#FDE68A")
        for px in [Float(-1.1), 1.1] {
            m.deco("Trade Stall Post", at: (sx + px, 1.4, 30.1), size: (0.1, 2.6, 0.1), color: "#FFFFFF", shape: .cylinder)
        }
        m.deco("Trade Stall Awning", at: (sx, 2.75, 30.3), size: (2.8, 0.12, 1.6), color: side < 0 ? "#F472B6" : "#38BDF8",
               rotation: (12, 0, 0))
    }
    for (k, p) in [(-6.5, 24.6), (-4.9, 24.4), (5.0, 24.5), (6.6, 24.7), (-7.2, 26.3), (7.1, 26.2)].enumerated() {
        let gx = Float(p.0), gz = Float(p.1), s: Float = k % 2 == 0 ? 0.7 : 0.55
        m.deco("Gift Box", at: (gx, 0.08 + s / 2, gz), size: (s, s, s), color: balloons[k])
        m.deco("Gift Ribbon", at: (gx, 0.08 + s / 2, gz), size: (s + 0.02, s + 0.02, 0.12), color: "#FFFFFF")
        m.deco("Gift Ribbon", at: (gx, 0.08 + s / 2, gz), size: (0.12, s + 0.02, s + 0.02), color: "#FFFFFF")
    }
    m.deco("Scales Post", at: (0, 1.0, 31.8), size: (0.14, 1.9, 0.14), color: gold, shape: .cylinder, material: .metal)
    m.deco("Scales Beam", at: (0, 1.9, 31.8), size: (1.8, 0.08, 0.08), color: gold, material: .metal)
    for side in [Float(-1), 1] {
        m.deco("Scales Pan", at: (side * 0.85, 1.6, 31.8), size: (0.6, 0.06, 0.6), color: gold, shape: .cylinder, material: .metal)
    }

    // The places pets ask for. Each base is 12 wide with the pad (6 wide) in
    // the middle and the sign post at one corner, so props stand round the
    // edge, and two bushes sit just off the corners.
    m.deco("Food Sack", at: (-66.6, 0.75, 4.4), size: (0.9, 0.9, 0.7), color: "#D6A15E", shape: .cylinder, material: .matte)
    m.deco("Food Sack Top", at: (-66.6, 1.25, 4.4), size: (0.5, 0.2, 0.4), color: "#C08A4B", shape: .sphere)
    for p in [(-66.5, 0.0), (-66.5, -2.4), (-57.5, 2.4), (-57.5, 0.0)] {
        m.deco("Pet Bowl", at: (Float(p.0), 0.42, Float(p.1)), size: (0.9, 0.24, 0.9), color: "#F97316", shape: .cylinder)
        m.deco("Pet Bowl Food", at: (Float(p.0), 0.55, Float(p.1)), size: (0.7, 0.16, 0.7), color: "#92400E", shape: .sphere, material: .matte)
    }
    m.deco("Well Ring", at: (62, 0.75, 0), size: (3.2, 0.9, 3.2), color: "#A8A29E", shape: .cylinder, material: .matte, opacity: 0.9)
    m.deco("Well Water", at: (62, 1.18, 0), size: (2.6, 0.04, 2.6), color: "#38BDF8", shape: .cylinder, material: .glass, opacity: 0.85)
    for side in [Float(-1), 1] {
        m.deco("Well Post", at: (62 + side * 2.3, 1.8, 0), size: (0.2, 3.0, 0.2), color: "#8B5A2B", shape: .cylinder)
    }
    m.deco("Well Rope", at: (62, 2.5, 0), size: (0.04, 1.4, 0.04), color: "#E7D3A8", shape: .cylinder)
    m.deco("Well Bucket", at: (62, 1.65, 0), size: (0.45, 0.45, 0.45), color: "#78350F", shape: .cylinder)
    for (k, bx) in [Float(-66), -63.3, -60.6, -57.9].enumerated() {
        m.deco("Bed Pillow", at: (bx, 0.9, 35.1), size: (1.4, 0.2, 0.6), color: "#FFFFFF", shape: .sphere)
        m.deco("Bed Blanket", at: (bx, 0.83, 33.3), size: (2.1, 0.06, 1.6), color: ["#F9A8D4", "#93C5FD", "#FDE68A", "#86EFAC"][k])
    }
    m.deco("Mobile Post", at: (-56.5, 1.8, 25.5), size: (0.1, 3.0, 0.1), color: "#FFFFFF", shape: .cylinder)
    m.deco("Mobile Moon", at: (-56.5, 3.5, 25.5), size: (0.7, 0.7, 0.2), color: "#FDE047", shape: .sphere, material: .neon)
    for side in [Float(-1), 1] {
        m.deco("Mobile Star", at: (-56.5 + side * 0.7, 3.1, 25.5), size: (0.3, 0.3, 0.1), color: "#FFFFFF", shape: .sphere, material: .neon)
    }
    m.deco("Bath Tub", at: (62, 0.7, 34.6), size: (3.2, 0.8, 1.7), color: "#FFFFFF")
    m.deco("Bath Water", at: (62, 1.08, 34.6), size: (2.8, 0.06, 1.3), color: "#67E8F9", material: .glass, opacity: 0.85)
    for k in 0..<6 {
        m.deco("Bubble", at: (60.9 + Float(k) * 0.45, 1.25 + Float(k % 2) * 0.2, 34.3 + Float(k % 3) * 0.3), size: (0.35, 0.35, 0.35),
               color: "#FFFFFF", shape: .sphere, material: .glass, opacity: 0.7)
    }
    m.deco("Rubber Duck", at: (63.2, 1.25, 34.9), size: (0.4, 0.3, 0.45), color: "#FACC15", shape: .sphere)
    m.deco("Rubber Duck Head", at: (63.2, 1.5, 35.1), size: (0.25, 0.25, 0.25), color: "#FACC15", shape: .sphere)
    m.deco("Rubber Duck Beak", at: (63.2, 1.48, 35.27), size: (0.14, 0.06, 0.12), color: "#F97316")
    m.deco("Shower Post", at: (57.2, 1.6, 34.5), size: (0.12, 2.6, 0.12), color: "#D1D5DB", shape: .cylinder, material: .metal)
    m.deco("Shower Head", at: (57.6, 2.85, 34.5), size: (0.5, 0.12, 0.5), color: "#D1D5DB", shape: .cylinder, material: .metal)
    m.deco("Ball Pit", at: (-40.5, 0.55, 67.2), size: (3.4, 0.5, 3.4), color: "#38BDF8", shape: .cylinder, opacity: 0.9)
    for k in 0..<10 {
        let a = Float(k) * 2.4, d: Float = k < 5 ? 0.6 : 1.2
        m.deco("Pit Ball", at: (-40.5 + cos(a) * d, 0.85, 67.2 + sin(a) * d), size: (0.35, 0.35, 0.35), color: balloons[k % 8], shape: .sphere)
    }
    m.deco("Seesaw Base", at: (-40.5, 0.55, 74.6), size: (0.5, 0.5, 0.5), color: "#EF4444", shape: .cone)
    m.deco("Seesaw Plank", at: (-40.5, 0.85, 74.6), size: (3.4, 0.1, 0.4), color: "#FACC15", rotation: (0, 0, 10))
    for dx in [Float(-1.4), 1.4] {
        m.deco("Seesaw Handle", at: (-40.5 + dx, 1.05 + dx * 0.17, 74.6), size: (0.08, 0.08, 0.6), color: "#3B82F6", shape: .cylinder,
               rotation: (90, 0, 0))
    }
    m.deco("Exam Table", at: (40.5, 1.0, 69), size: (1.2, 0.12, 2.0), color: "#E0F2FE")
    m.deco("Exam Table Leg", at: (40.5, 0.65, 69), size: (0.2, 0.7, 0.2), color: "#9CA3AF", shape: .cylinder, material: .metal)
    m.deco("Clinic Board", at: (31.5, 1.6, 77.3), size: (1.6, 1.6, 0.08), color: "#FFFFFF")
    m.deco("Clinic Cross", at: (31.5, 1.6, 77.25), size: (1.1, 0.35, 0.06), color: "#EF4444", material: .neon)
    m.deco("Clinic Cross", at: (31.5, 1.6, 77.25), size: (0.35, 1.1, 0.06), color: "#EF4444", material: .neon)
    m.shelf(in: Frame(30.8, 70, y: 0.3, yaw: 90), width: 2, height: 1.6, color: "#E5E7EB", goods: ["#F87171", "#FFFFFF", "#86EFAC"],
            goodsShape: .cylinder)
    for k in 0..<3 {
        let a = Float(k) * 2.1 + 0.5
        m.deco("Log Seat", at: (-80 + cos(a) * 2.0, 0.5, 78 + sin(a) * 2.0), size: (0.4, 1.3, 0.4), color: "#78350F", shape: .cylinder,
               rotation: (0, -a * 180 / .pi, 90))
    }
    for p in ring(6, radius: 0.95, cx: -80, cz: 78) {
        m.deco("Fire Stone", at: (p.0, 0.4, p.1), size: (0.4, 0.25, 0.35), color: "#78716C", shape: .sphere, material: .matte)
    }
    m.deco("Lantern Post", at: (-75.2, 1.3, 79.8), size: (0.1, 2.0, 0.1), color: "#3A3A44", shape: .cylinder)
    m.deco("Lantern", at: (-75.2, 2.35, 79.8), size: (0.35, 0.45, 0.35), color: "#FDE68A", material: .neon)
    for (k, p) in [(75.5, 71.0), (75.5, 79.0), (84.5, 79.0)].enumerated() {
        m.deco("School Desk", at: (Float(p.0), 0.95, Float(p.1)), size: (1.2, 0.08, 0.7), color: "#F5DEB3")
        m.deco("School Desk Leg", at: (Float(p.0), 0.62, Float(p.1)), size: (1.0, 0.6, 0.08), color: "#6B7280", material: .metal)
        m.deco("School Chair", at: (Float(p.0), 0.72, Float(p.1) - 0.6), size: (0.5, 0.06, 0.5), color: balloons[k + 2])
    }
    m.deco("Easel Board", at: (85.5, 1.9, 72.5), size: (1.8, 1.2, 0.08), color: "#14532D", rotation: (-8, 0, 0))
    for side in [Float(-1), 1] {
        m.deco("Easel Leg", at: (85.5 + side * 0.7, 1.2, 72.4), size: (0.08, 1.8, 0.08), color: "#8B5A2B")
    }
    m.deco("School Bell", at: (80, 3.1, 83.6), size: (0.6, 0.6, 0.6), color: gold, shape: .cone, material: .metal)
    for (k, p) in [(-79.6, -71.0), (-70.6, -71.0)].enumerated() {
        let tx = Float(p.0), tz = Float(p.1)
        m.table(tx, tz, y: 0.3, top: "#FFFFFF", chairs: 2, chair: "#DC2626", phase: .pi / 2)
        m.deco("Pizza", at: (tx, 1.13, tz), size: (0.9, 0.04, 0.9), color: "#FBBF24", shape: .cylinder)
        for j in 0..<3 {
            let a = Float(j) * 2.1 + Float(k)
            m.deco("Pepperoni", at: (tx + cos(a) * 0.22, 1.16, tz + sin(a) * 0.22), size: (0.18, 0.02, 0.18), color: "#B91C1C", shape: .cylinder)
        }
    }
    // The beach: towels under the umbrellas, sandcastles, shells, a ball,
    // foam at the water's edge and two loungers.
    for (k, x) in [Float(-20), -10, 10, 20].enumerated() {
        m.deco("Beach Towel", at: (x, 0.06, -87.6), size: (1.2, 0.02, 2.2), color: balloons[k])
        m.deco("Beach Towel Stripe", at: (x, 0.075, -87.6), size: (1.22, 0.02, 0.4), color: "#FFFFFF")
    }
    for x in [Float(-14), 14] {
        m.deco("Sandcastle", at: (x, 0.35, -90.5), size: (1.6, 0.6, 1.2), color: "#EAD08A", material: .matte)
        for side in [Float(-1), 1] {
            m.deco("Sandcastle Tower", at: (x + side * 0.6, 0.85, -90.5), size: (0.5, 0.6, 0.5), color: "#EAD08A", shape: .cylinder, material: .matte)
            m.deco("Sandcastle Roof", at: (x + side * 0.6, 1.3, -90.5), size: (0.55, 0.35, 0.55), color: "#E3C477", shape: .cone, material: .matte)
        }
        m.deco("Sandcastle Flag", at: (x + 0.15, 1.55, -90.5), size: (0.35, 0.22, 0.03), color: "#EF4444")
    }
    var br = Seeded("pet beach")
    for k in 0..<12 {
        let sx = br.range(-28, 28), sz = br.range(-92, -80)
        guard abs(sx) > 7 else { continue }
        m.deco(k % 3 == 0 ? "Starfish" : "Shell", at: (sx, 0.08, sz), size: k % 3 == 0 ? (0.5, 0.04, 0.5) : (0.3, 0.12, 0.24),
               color: k % 3 == 0 ? "#FB923C" : ["#FBCFE8", "#FFFFFF", "#FDE68A"][k % 3], shape: k % 3 == 0 ? .cylinder : .sphere)
    }
    m.deco("Beach Ball", at: (8.5, 0.4, -81), size: (0.7, 0.7, 0.7), color: "#F43F5E", shape: .sphere)
    m.deco("Beach Ball Stripe", at: (8.5, 0.4, -81), size: (0.72, 0.2, 0.72), color: "#FFFFFF", shape: .sphere)
    m.deco("Surf", at: (0, 0.045, -92.1), size: (120, 0.02, 0.6), color: "#F0F9FF", material: .matte, opacity: 0.9)
    for x in [Float(-25), 25] {
        m.deco("Lounger", at: (x, 0.3, -86), size: (0.9, 0.12, 2.0), color: "#38BDF8")
        m.deco("Lounger Back", at: (x, 0.6, -85.1), size: (0.9, 0.12, 0.8), color: "#38BDF8", rotation: (-50, 0, 0))
    }
    let needSpots: [(Float, Float)] = [(-62, 0), (62, 0), (-62, 30), (62, 30), (-36, 72), (36, 72), (-80, 75), (80, 75), (-75, -75), (0, -84)]
    for (k, p) in needSpots.enumerated() {
        m.bush(p.0 - 6.8, p.1 - 6.8, color: k % 2 == 0 ? "#4CAF50" : "#65A30D", size: 1.1)
        m.bush(p.0 + 6.8, p.1 + 6.8, color: k % 2 == 0 ? "#65A30D" : "#4CAF50", size: 1.1)
    }

    // Grass between it all: darker patches, tufts and wildflowers, kept off
    // the roads, the paving, the buildings and the beach.
    var keepOut: [(Float, Float, Float, Float)] = [
        (0, 0, 102, 5.6), (0, 0, 5.6, 102), (0, 0, 16, 16), (0, -40, 16, 7.5), (-42, -40, 10, 6.5), (42, -40, 9, 7),
        (0, 28, 9, 6), (0, 57, 11, 11), (80, 88, 8, 5), (-75, -88, 7, 5), (0, -90, 62, 10), (-14, 14, 6, 3.5),
        (-36, 78, 6, 2), (9, 16.5, 3, 1.5)
    ]
    keepOut += needSpots.map { ($0.0, $0.1, 7.6, 7.6) }
    func open(_ x: Float, _ z: Float, margin: Float) -> Bool {
        guard abs(x) < 100 - margin, abs(z) < 100 - margin else { return false }
        return !keepOut.contains { abs(x - $0.0) < $0.2 + margin && abs(z - $0.1) < $0.3 + margin }
    }
    var r = Seeded("pet home grass")
    var patches = 0, tries = 0
    while patches < 30 && tries < 2000 {
        tries += 1
        let x = r.range(-98, 98), z = r.range(-98, 98), size = r.range(3, 7)
        guard open(x, z, margin: size / 2) else { continue }
        m.deco("Grass Patch", at: (x, 0.006 + Float(patches) * 0.0004, z), size: (size, 0.01, size * r.range(0.6, 1)),
               color: patches % 2 == 0 ? "#A3D98B" : "#C6EDB0", shape: .cylinder, material: .matte)
        patches += 1
    }
    var spots: [(Float, Float)] = []
    tries = 0
    while spots.count < 140 && tries < 4000 {
        tries += 1
        let x = r.range(-98, 98), z = r.range(-98, 98)
        if open(x, z, margin: 0.5) { spots.append((x, z)) }
    }
    m.tufts(spots, color: "#7CC66A")
    var wild = 0
    tries = 0
    let wildColors = ["#F472B6", "#FDE047", "#FFFFFF", "#C4B5FD", "#FB923C", "#67E8F9"]
    while wild < 45 && tries < 4000 {
        tries += 1
        let x = r.range(-98, 98), z = r.range(-98, 98)
        guard open(x, z, margin: 0.5) else { continue }
        m.flower(x, z, color: wildColors[wild % wildColors.count], size: 0.8)
        wild += 1
    }
}

// MARK: 4 Meme Heist


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
