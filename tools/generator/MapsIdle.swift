import Foundation

// 59–70: idle, gacha, tycoon and collection.

let idleGames: [Game] = [
    Game(number: 59, id: "aura-roll", title: "Aura Roll",
         summary: "ボタンでオーラを引く運だめし。32種のオーラ、8つの天気（その天気だけのオーラ）、素材とオーラでギアをクラフト、旅の商人のポーション、運の塔。10回ごとのボーナスで1億分の1を引き当てろ！",
         tags: ["rng", "collect", "idle"], maxPlayers: 12, build: auraRoll),
    Game(number: 60, id: "raft-to-treasure", title: "Raft to Treasure",
         summary: "ブロックで橋を作って川を下る工作アドベンチャー。岩・流れる丸太・うずしお・滝・ワニの沼・氷・溶岩の10ステージ。8つの材料を解放し、大洪水の前に宝島の宝箱へ。タイムもきそおう！",
         tags: ["build", "adventure", "creative"], maxPlayers: 10, build: raftTreasure),
    Game(number: 61, id: "obby-maker", title: "Obby Maker",
         summary: "自分だけのアスレチックコースを作って公開しよう。17種のパーツ（動く床・回る溶岩バー・ワープ・コインも）、グリッドと回転、テストでクリアして公開、タイムといいね。お手本コースやみんなのコースに挑戦！",
         tags: ["obby", "build", "creative"], maxPlayers: 8, build: obbyMaker),
    Game(number: 62, id: "toy-army-tycoon", title: "Toy Army Tycoon",
         summary: "おもちゃの軍隊の基地を16の設備で大きくするタイクーン。兵隊・戦車・タレット・狙撃塔・迫撃砲・空爆で、予告つきの襲撃（5回ごとにおもちゃ将軍）からコアを守れ。研究所・銀行・昇進も！",
         tags: ["tycoon", "army", "defense"], maxPlayers: 8, build: toyArmy),
    Game(number: 63, id: "buzz-meadow", title: "Buzz Meadow",
         summary: "ハチを育てて花粉をハチミツに。12種のハチ（赤・青の花畑が得意なハチも）、8つの花畑、たまごとロイヤルゼリー、道具とバッグ、トークン、虫たいじと洞くつのカブトムシの王、くまさんの9つのクエスト！",
         tags: ["simulator", "bees", "collect"], maxPlayers: 12, build: buzzMeadow),
    Game(number: 64, id: "dungeon-delve", title: "Dungeon Delve",
         summary: "4つの職業で挑む協力ハクスラ。部屋ごとに戦い・強敵・宝物庫・祭壇・ワナ・休けい所、奥にはボス。4つのテーマと4体のボス、5段階のレア装備、12の遺物、鍛冶屋で強化してもっと深い階へ！",
         tags: ["dungeon", "loot", "coop"], maxPlayers: 8, build: dungeonDelve),
    Game(number: 65, id: "critter-quest", title: "Critter Quest",
         summary: "草むらでクリッターに出会って、つかまえて、育てるターン制RPG。24種（進化あり）、9タイプの相性、31の技と状態異常、4人のリーダーとチャンピオン、図鑑とあずかりボックス、そして伝説のクリッター！",
         tags: ["monsters", "rpg", "turn-based"], maxPlayers: 12, build: critterQuest),
    Game(number: 66, id: "blade-summon-sim", title: "Blade Summon Sim",
         summary: "召喚した武器がまわりを回って敵を自動でたおす放置系。6つのワールドと36本の武器、6段階のレア度、★合体、エンチャント、道場の強化、ワールドボス、転生と転生ショップ！",
         tags: ["idle", "summon", "collect"], maxPlayers: 12, build: bladeSummon),
    Game(number: 67, id: "crusher-yard", title: "Crusher Yard",
         summary: "自分のレーンで車をグシャッ！ 12台の車（部品ごとにこわれる）と6つの機械（プレス・シュレッダー・溶岩・レーザー・鉄球・ブラックホール）。スクラップ集め・磁石・自動投入・転生・スクラップラッシュ！",
         tags: ["simulator", "cars", "satisfying"], maxPlayers: 10, build: crusherYard),
    Game(number: 68, id: "slime-merge", title: "Slime Merge",
         summary: "スライムをすいこんで、自分の牧場の台で合体！ 8種類×10レベル、7つのバイオームとゲート、台16こ、自動合体、たまご屋と市場、図鑑80こ、スライムの雨とにげ足の速いにじいろスライム！",
         tags: ["merge", "idle", "cute"], maxPlayers: 10, build: slimeMerge),
    Game(number: 69, id: "mansion-builder-tycoon", title: "Mansion Builder Tycoon",
         summary: "小さな家から大豪邸へ。お金をためて部屋、プール、ガレージ、ヘリポートを順番に建てていくタイクーン。",
         tags: ["tycoon", "build", "rich"], maxPlayers: 8, build: mansionTycoon),
    Game(number: 70, id: "plus-one-speed-escape", title: "+1 Speed Wall Escape",
         summary: "1秒ごとにスピードが+1！うしろからせまる巨大なかべから逃げて、どこまで遠くへ行けるか。転生でさらに速く。",
         tags: ["runner", "speed", "idle"], maxPlayers: 12, build: speedEscape),
]

// MARK: 59 Aura Roll

func auraRoll(_ m: MapBuilder) {
    m.sky("#1E1B4B", "#6D28D9", light: 0.7, ground: "#312E81")
    m.ground(140, 140, color: "#3730A3", name: "Plaza")
    m.part("Cover Focus", at: (4, 3, 4), size: (70, 1, 1), color: "#000000", tags: ["yaw=215"], solid: false, visible: false)
    // The altar with the great orb in the middle.
    m.part("Altar", at: (0, 0.6, 0), size: (10, 1.2, 10), color: "#E0E7FF", shape: .cylinder, material: .metal)
    m.part("Altar Ring", at: (0, 1.25, 0), size: (8, 0.1, 8), color: "#A78BFA", shape: .cylinder, material: .neon, solid: false)
    m.part("Orb", at: (0, 5, 0), size: (3, 3, 3), color: "#A78BFA", shape: .sphere, material: .neon, solid: false)
    for p in ring(4, radius: 3.4, phase: .pi / 4) {
        m.part("Orb Pillar", at: (p.0, 2.7, p.1), size: (0.5, 3, 0.5), color: "#C4B5FD", shape: .cylinder, material: .glass)
    }
    m.spawnRing(0, 0, radius: 9, count: 10, color: "#C4B5FD")
    for p in ring(8, radius: 30) {
        m.pillar("Crystal Pillar", x: p.0, z: p.1, height: 6, radius: 0.8, color: "#818CF8", material: .glass)
        m.part("Crystal Top", at: (p.0, 7, p.1), size: (1.6, 2, 1.6), color: "#C4B5FD", shape: .cone, material: .neon, solid: false)
    }
    // The potion shop, the craft bench and the merchant's carpet.
    m.shop("Potion Shop", x: 0, z: -42, w: 12, d: 8, color: "#4C1D95", sign: "#F0ABFC")
    m.pad("Potion Counter", x: 0, z: -36.5, size: 2.4, color: "#E879F9", tags: ["potions"])
    m.slab("Craft Bench", x: -24, y: 0, z: -14, w: 5, h: 1.1, d: 2, color: "#78350F")
    m.part("Anvil", at: (-24, 1.5, -14), size: (1.4, 0.8, 0.8), color: "#6B7280", material: .metal, solid: false)
    m.pad("Craft Table", x: -24, z: -11.5, size: 2.4, color: "#FACC15", tags: ["craft"])
    m.part("Craft Sign", at: (-24, 3.4, -15.2), size: (4, 0.8, 0.2), color: "#FDE68A", material: .neon, solid: false)
    m.slab("Merchant Carpet", x: 24, y: 0, z: -14, w: 6, h: 0.05, d: 4, color: "#7C3AED")
    m.pad("Merchant Pad", x: 24, z: -11.8, size: 2, color: "#F0ABFC", tags: ["merchant"])
    m.part("Merchant Spot", at: (24, 0.1, -14.5), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)
    for dx: Float in [-2.5, 2.5] {
        m.part("Tent Pole", at: (24 + dx, 1.8, -16), size: (0.2, 3.6, 0.2), color: "#FDE68A", solid: false)
    }
    m.slab("Tent Roof", x: 24, y: 3.6, z: -15, w: 6.5, h: 0.2, d: 3, color: "#A21CAF")
    // The luck tower: a spiral of stepping stones to a potion at the top.
    let tc: (Float, Float) = (38, 34)
    m.pillar("Tower Core", x: tc.0, z: tc.1, height: 26, radius: 1.6, color: "#6366F1")
    for i in 0..<13 {
        let a = Float(i) * 0.9
        let rr: Float = 4.2
        m.slab("Tower Step", x: tc.0 + cos(a) * rr, y: 0.5 + Float(i) * 1.7, z: tc.1 + sin(a) * rr, w: 2.6, h: 0.4, d: 2.6,
               color: i % 2 == 0 ? "#A5B4FC" : "#C4B5FD")
    }
    m.slab("Tower Top Floor", x: tc.0, y: 26, z: tc.1, w: 5, h: 0.4, d: 5, color: "#FDE68A")
    m.pad("Tower Top", x: tc.0, z: tc.1, y: 26.4, size: 2.4, color: "#22C55E", tags: ["tower_top"])
    // Where the materials fall.
    for (i, p) in ring(16, radius: 20, phase: 0.2).enumerated() {
        let rr: Float = i % 2 == 0 ? 1 : 1.9
        m.part("Material Spot \(i + 1)", at: (p.0 * rr, 0.1, p.1 * rr), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)
    }
    // Floating lanterns and benches around the plaza.
    for p in ring(12, radius: 48) {
        m.part("Sky Lantern", at: (p.0, 9, p.1), size: (1, 1.2, 1), color: "#F0ABFC", shape: .sphere, material: .neon, solid: false)
    }
    for p in ring(6, radius: 16, phase: 0.5) { m.slab("Bench", x: p.0, y: 0, z: p.1, w: 2.4, h: 0.6, d: 0.8, color: "#4338CA") }
}

// MARK: 60 Raft to Treasure

func raftTreasure(_ m: MapBuilder) {
    // No ground plane: it would sit over the river (which runs below y = 0).
    m.sky("#7DD3FC", "#E0F2FE", light: 0.8, ground: "#4D7C0F", showGround: false)
    m.slab("River Bed", x: 0, y: -10, z: 195, w: 44, h: 1, d: 440, color: "#1E3A8A")
    for x: Float in [-47, 47] {
        m.slab("Bank", x: x, y: -8, z: 195, w: 46, h: 8, d: 440, color: "#4D7C0F")
    }
    m.slab("Bank", x: 0, y: -8, z: -40, w: 140, h: 8, d: 24, color: "#4D7C0F")
    m.part("Cover Focus", at: (0, 0, 34), size: (72, 1, 1), color: "#000000", tags: ["yaw=125"], solid: false, visible: false)
    // The dock where everyone starts.
    m.slab("Dock", x: 0, y: -1, z: -18, w: 44, h: 1, d: 20, color: "#A16207")
    for x in stride(from: Float(-20), through: 20, by: 5) {
        m.part("Dock Post", at: (x, -1.5, -8.3), size: (0.5, 2, 0.5), color: "#78350F", shape: .cylinder)
    }
    m.spawnRing(0, -20, radius: 5, count: 10, color: "#FDE68A")
    m.shop("Boat Shop", x: -14, z: -24, w: 10, d: 6, color: "#0EA5E9", sign: "#FDE68A", facing: 1)
    // The river: an upper stretch, a waterfall, and a lower stretch to the island.
    m.part("River Upper", at: (0, -1.8, 90), size: (44, 1, 200), color: "#38BDF8", material: .glass, behavior: .hazard, opacity: 0.9)
    m.part("River Lower", at: (0, -5.8, 300), size: (44, 1, 220), color: "#0EA5E9", material: .glass, behavior: .hazard, opacity: 0.9)
    m.part("Waterfall", at: (0, -3.3, 190.2), size: (44, 4, 0.4), color: "#93C5FD", material: .glass, solid: false, opacity: 0.6)
    m.part("Lava", at: (0, -5.72, 318), size: (44, 1, 30), color: "#EA580C", material: .neon, behavior: .hazard)
    m.part("Ice Sheet", at: (0, -5.7, 262), size: (44, 1, 18), color: "#E0F2FE", material: .glass, behavior: .hazard, opacity: 0.9)
    // Canyon walls on both sides.
    for x: Float in [-23, 23] {
        m.slab("Canyon Wall", x: x, y: -7, z: 90, w: 2, h: 10, d: 200, color: "#A8A29E")
        m.slab("Canyon Wall", x: x, y: -7, z: 300, w: 2, h: 6, d: 220, color: "#78716C")
    }
    // Ten islands, the river's stages.
    var r = Seeded("raft")
    for i in 0..<10 {
        let z = Float(i + 1) * 38
        let lower = i >= 5
        let y: Float = lower ? -5 : -1
        let x = r.range(-9, 9)
        let colors = ["#78716C", "#A8A29E", "#92400E", "#0E7490", "#57534E", "#166534", "#E0F2FE", "#334155", "#7F1D1D", "#FDE68A"]
        m.slab("Stage \(i + 1) Island", x: x, y: y, z: z, w: 10, h: 1, d: 8, color: colors[i], tags: ["stage"])
        m.pad("Stage \(i + 1) Goal", x: x, z: z, y: y + 1, size: 3, color: "#22C55E", tags: ["goal"])
        m.part("Stage \(i + 1) Flag", at: (x + 3.5, y + 3, z + 2.5), size: (0.15, 4, 0.15), color: "#F8FAFC", solid: false)
        m.part("Stage \(i + 1) Pennant", at: (x + 4.2, y + 4.6, z + 2.5), size: (1.4, 0.8, 0.05), color: "#EF4444", solid: false)
    }
    // Stage 2: rocks. Stages 3 and 8: logs. Stage 4: whirlpools. Stage 6: crocodiles.
    for i in 0..<5 {
        m.part("Rock", at: (r.range(-17, 17), -1.1, 46 + Float(i) * 5), size: (3, 2, 3), color: "#57534E", shape: .sphere, behavior: .hazard)
    }
    let logs: [(Float, Float)] = [(84, -1.1), (92, -1.1), (100, -1.1), (270, -5.1), (278, -5.1), (286, -5.1)]
    for (i, l) in logs.enumerated() {
        m.part("Log \(i + 1)", at: (i % 2 == 0 ? -14 : 14, l.1, l.0), size: (1.2, 7, 1.2), color: "#78350F", shape: .cylinder,
               behavior: .hazard, rotation: (0, 0, 90))
    }
    for (i, z) in ([122, 130, 138] as [Float]).enumerated() {
        m.part("Whirlpool \(i + 1)", at: (r.range(-10, 10), -1.25, z), size: (6, 0.1, 6), color: "#1E3A8A", shape: .cylinder, material: .neon,
               behavior: .hazard, opacity: 0.8)
    }
    for (i, z) in ([200, 208, 216] as [Float]).enumerated() {
        m.part("Croc Spot \(i + 1)", at: (r.range(-12, 12), -5.2, z), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)
    }
    // Treasure island.
    m.slab("Treasure Island", x: 0, y: -5, z: 400, w: 24, h: 1, d: 18, color: "#FDE68A")
    m.part("Treasure Chest", at: (0, -3.2, 403), size: (2.4, 1.6, 1.6), color: "#B45309", material: .metal, behavior: .trigger, tags: ["chest"])
    m.part("Chest Lid", at: (0, -2.3, 403), size: (2.5, 0.3, 1.7), color: "#FACC15", material: .metal, solid: false)
    for p in [(-8, 396), (8, 405), (-6, 406)] as [(Float, Float)] { m.tree(p.0, p.1, y: -4, height: 5, leaves: "#16A34A") }
    for p in [(3, 399), (-3, 399), (5, 404)] as [(Float, Float)] {
        m.part("Gold Pile", at: (p.0, -3.7, p.1), size: (1.2, 0.6, 1.2), color: "#FACC15", shape: .sphere, material: .neon, solid: false)
    }
    for p in ring(8, radius: 32, cx: 0, cz: -20) { m.tree(p.0, p.1, y: -1, height: 5) }
}

// MARK: 61 Obby Maker

func obbyMaker(_ m: MapBuilder) {
    m.sky("#38BDF8", "#E0F2FE", light: 0.8, showGround: false, fall: -30)
    m.part("Cover Focus", at: (0, 2, -40), size: (110, 1, 1), color: "#000000", tags: ["yaw=35"], solid: false, visible: false)
    m.slab("Hub", x: 0, y: -1, z: 0, w: 26, h: 1, d: 26, color: "#E5E7EB")
    m.part("Hub Ring", at: (0, 0.02, 0), size: (18, 0.04, 18), color: "#F472B6", shape: .cylinder, solid: false)
    m.spawnRing(0, 0, radius: 5, count: 8, color: "#F472B6")
    m.part("Showcase Board", at: (0, 4, -12.5), size: (12, 4, 0.3), color: "#7C3AED", material: .neon, solid: false)
    m.part("Showcase Frame", at: (0, 4, -12.8), size: (13, 5, 0.2), color: "#1E1B4B", solid: false)
    let colors = ["#F87171", "#60A5FA", "#34D399", "#FBBF24", "#A78BFA", "#F472B6", "#22D3EE", "#FB923C"]
    for i in 0..<8 {
        let a = Float(i) / 8 * 2 * .pi
        let x = cos(a) * 60, z = sin(a) * 60
        m.slab("Build \(i + 1) Start", x: x, y: -1, z: z, w: 8, h: 1, d: 8, color: colors[i], tags: ["plotstart"])
        m.part("Build \(i + 1) Beacon", at: (x, 6, z), size: (0.4, 12, 0.4), color: colors[i], material: .neon, solid: false, opacity: 0.5)
        m.pad("Build \(i + 1) Claim", x: x * 0.8, z: z * 0.8, y: -0.4, size: 2, color: "#FFFFFF", tags: ["claim"])
        m.slab("Bridge \(i + 1)", x: x * 0.55, y: -1, z: z * 0.55, w: 3, h: 0.6, d: 3, color: "#D1D5DB")
        m.slab("Bridge \(i + 1)b", x: x * 0.35, y: -1, z: z * 0.35, w: 3, h: 0.6, d: 3, color: "#D1D5DB")
        m.slab("Bridge \(i + 1)c", x: x * 0.68, y: -1, z: z * 0.68, w: 3, h: 0.6, d: 3, color: "#D1D5DB")
    }
    // The sample course (plot 9), out past the showcase: steps, a bounce, a beam, lava with a safe line, a checkpoint and the goal.
    let z0: Float = -110
    m.slab("Build 9 Start", x: 0, y: -1, z: z0, w: 8, h: 1, d: 8, color: "#E5E7EB", tags: ["plotstart"])
    let steps: [(Float, Float, Float, String)] = [(0, 0, -7, "block"), (2, 0.8, -11, "block"), (-1, 1.6, -15, "small"), (1, 2.4, -18.5, "small"),
                                                   (0, 2.4, -23, "block")]
    for s in steps {
        let big = s.3 == "block"
        m.slab("Sample \(s.3)", x: s.0, y: s.1, z: z0 + s.2, w: big ? 3 : 1.4, h: 0.6, d: big ? 3 : 1.4, color: big ? "#60A5FA" : "#A78BFA",
               tags: ["obby", "plot9", s.3])
    }
    m.part("Sample Bounce", at: (0, 3.2, z0 - 27), size: (2.4, 0.4, 2.4), color: "#22C55E", shape: .cylinder, behavior: .bounce, tags: ["obby", "plot9", "bounce"])
    m.slab("Sample Landing", x: 0, y: 6, z: z0 - 33, w: 4, h: 0.6, d: 4, color: "#60A5FA", tags: ["obby", "plot9", "block"])
    m.slab("Sample Beam", x: 0, y: 6, z: z0 - 40, w: 0.8, h: 0.4, d: 10, color: "#F472B6", tags: ["obby", "plot9", "beam"])
    m.part("Sample Check", at: (0, 6.2, z0 - 46), size: (2, 0.3, 2), color: "#4ADE80", shape: .cylinder, behavior: .checkpoint, tags: ["obby", "plot9", "check"])
    m.slab("Sample Floor", x: 0, y: 5.6, z: z0 - 46, w: 4, h: 0.5, d: 4, color: "#60A5FA", tags: ["obby", "plot9", "block"])
    m.slab("Sample Lava", x: 0, y: 5.6, z: z0 - 53, w: 6, h: 0.3, d: 8, color: "#EF4444", behavior: .hazard, tags: ["obby", "plot9", "lava"])
    for k in 0..<3 {
        m.slab("Sample Stone", x: -2 + Float(k) * 2, y: 5.9, z: z0 - 50.5 - Float(k) * 2.5, w: 1.2, h: 0.4, d: 1.2, color: "#A78BFA",
               tags: ["obby", "plot9", "small"])
    }
    m.slab("Sample Goal Floor", x: 0, y: 5.6, z: z0 - 60, w: 5, h: 0.5, d: 5, color: "#E5E7EB", tags: ["obby", "plot9", "block"])
    m.part("Sample Goal", at: (0, 6.3, z0 - 60), size: (3, 0.4, 3), color: "#FFFFFF", behavior: .trigger, tags: ["obby", "plot9", "finish"])
    m.part("Sample Goal Arch", at: (0, 9, z0 - 61.8), size: (6, 0.6, 0.6), color: "#FACC15", material: .neon, solid: false)
}

// MARK: 62 Toy Army Tycoon

func toyArmy(_ m: MapBuilder) {
    m.day(ground: "#4D7C0F")
    m.ground(240, 240, color: "#65A30D", name: "Battlefield")
    m.part("Cover Focus", at: (0, 2, -24), size: (58, 1, 1), color: "#000000", tags: ["yaw=35"], solid: false, visible: false)
    m.spawnRing(0, 0, radius: 5, count: 8, color: "#FACC15")
    m.part("HQ Tent", at: (0, 1.5, 0), size: (6, 3, 6), color: "#A16207", shape: .cone, solid: false)
    // The sixteen buildings of a base, bought in this order (the script names them).
    let items: [(String, Float, Float, V, String, BlockShape)] = [
        ("Dropper", -10, -10, (2, 3, 2), "#6B7280", .box), ("Conveyor", -5, -10, (6, 0.6, 1.6), "#374151", .box),
        ("Barracks", 8, -10, (6, 3, 4), "#78716C", .box), ("Wall North", 0, -14.5, (30, 2.5, 0.8), "#A8A29E", .box),
        ("Turret 1", -11, 7, (1.6, 2.4, 1.6), "#3F3F46", .cylinder), ("Turret 2", 11, 7, (1.6, 2.4, 1.6), "#3F3F46", .cylinder),
        ("Wall South", 0, 11, (22, 2.5, 0.8), "#A8A29E", .box), ("Sniper Tower", -12, -2, (2, 6, 2), "#57534E", .box),
        ("Tank Garage", 0, 5, (6, 2.4, 4), "#57534E", .box), ("Wall East", 14.5, 0, (0.8, 2.5, 22), "#A8A29E", .box),
        ("Wall West", -14.5, 0, (0.8, 2.5, 22), "#A8A29E", .box), ("Mortar Pit", 6, -3, (3, 1, 3), "#44403C", .cylinder),
        ("Helipad", -6, 2, (4, 0.2, 4), "#1F2937", .cylinder), ("Research Lab", 10.5, -4, (3, 2.5, 3), "#0E7490", .box),
        ("Bank", -6, -4, (3, 2.5, 3), "#CA8A04", .box), ("Monument", 0, -6, (1, 5, 1), "#FACC15", .cylinder)
    ]
    // A finished base on show by the spawn, so everyone sees what they are building toward.
    let sc: (Float, Float) = (0, -30)
    m.slab("Showcase Floor", x: sc.0, y: 0, z: sc.1, w: 30, h: 0.2, d: 30, color: "#D6D3D1")
    for item in items {
        m.part("Showcase \(item.0)", at: (sc.0 + item.1, 0.2 + item.3.1 / 2, sc.1 + item.2), size: item.3, color: item.4, shape: item.5)
    }
    m.part("Showcase Core", at: (sc.0, 1.4, sc.1), size: (2.4, 2.4, 2.4), color: "#FACC15", shape: .sphere, material: .neon, solid: false)
    for p in [(-9, 1), (9, 1), (-3, -8), (3, 6)] as [(Float, Float)] {
        m.part("Showcase Soldier", at: (sc.0 + p.0, 1.1, sc.1 + p.1), size: (0.8, 1.8, 0.5), color: "#4D7C0F", solid: false)
    }
    m.part("Showcase Tank", at: (sc.0 + 3, 0.9, sc.1 + 8), size: (3, 1.4, 2), color: "#3F6212")
    m.part("Showcase Barrel", at: (sc.0 + 5, 1.5, sc.1 + 8), size: (2, 0.3, 0.3), color: "#1F2937", solid: false)
    let colors = ["#EF4444", "#3B82F6", "#22C55E", "#F59E0B"]
    for (i, p) in [(-60, -60), (60, -60), (-60, 60), (60, 60)].enumerated() {
        tycoonPlot(m, n: i + 1, x: Float(p.0), z: Float(p.1), color: colors[i], items: items, padRow: true)
        m.part("Plot \(i + 1) Core", at: (Float(p.0), 1.4, Float(p.1)), size: (2.4, 2.4, 2.4), color: "#FACC15", shape: .sphere, material: .neon)
        m.part("Plot \(i + 1) Banner", at: (Float(p.0) + 15.5, 4, Float(p.1) + 15.5), size: (0.3, 8, 0.3), color: colors[i], material: .neon, solid: false)
    }
    // Scattered cover on the battlefield: sandbags and toy blocks.
    var r = Seeded("army")
    var placed = 0
    while placed < 24 {
        let x = r.range(-110, 110), z = r.range(-110, 110)
        if abs(abs(x) - 60) < 22 && abs(abs(z) - 60) < 22 { continue }
        if abs(x) < 10 && abs(z) < 10 { continue }
        let toy = r.pick([("Sandbags", (4, 1, 1.2), "#A8A29E", BlockShape.box), ("Toy Block", (2, 2, 2), "#F87171", .box),
                          ("Toy Block", (2, 2, 2), "#60A5FA", .box), ("Toy Ball", (2.4, 2.4, 2.4), "#FACC15", .sphere)] as [(String, V, String, BlockShape)])
        m.part(toy.0, at: (x, toy.1.1 / 2, z), size: toy.1, color: toy.2, shape: toy.3, rotation: (0, r.range(0, 90), 0))
        placed += 1
    }
    m.markers("Raid Spawn", points: [(0, -112), (0, 112), (-112, 0), (112, 0)], color: "#000000", visible: false, behavior: .none)
}

// MARK: 63 Buzz Meadow

/// One flower field: the coloured patch "Field `id`" the script measures, a
/// border, an arch on the hub side with one light per five bees it needs, and
/// twenty-five flowers of the field's kind.
func beeField(_ m: MapBuilder, id: String, x: Float, z: Float, y: Float = 0, soil: String, border: String, need: Int,
              kind: String, r: inout Seeded) {
    let half: Float = 11
    m.part("Field \(id)", at: (x, y + 0.04, z), size: (22, 0.08, 22), color: soil, material: .matte, solid: false)
    for s: Float in [-1, 1] {
        m.part("Field Edge", at: (x, y + 0.08, z + s * half), size: (22.6, 0.16, 0.6), color: border, solid: false)
        m.part("Field Edge", at: (x + s * half, y + 0.08, z), size: (0.6, 0.16, 22.6), color: border, solid: false)
    }
    let gz: Float = z - half - 0.6
    for s: Float in [-1, 1] {
        m.part("Field Arch Post", at: (x + s * 3.2, y + 2, gz), size: (0.4, 4, 0.4), color: border)
    }
    m.part("Field Arch", at: (x, y + 4.2, gz), size: (7.2, 0.6, 0.5), color: border, solid: false)
    let lights = need / 5
    for k in 0..<lights {
        let lx: Float = x + (Float(k) - Float(lights - 1) / 2) * 1.1
        m.part("Field Need Light", at: (lx, y + 4.2, gz - 0.35), size: (0.5, 0.5, 0.2), color: "#FDE047", shape: .sphere, material: .neon, solid: false)
    }
    for gx in 0..<5 {
        for gzi in 0..<5 {
            let fx: Float = x + Float(gx - 2) * 4 + r.range(-1, 1)
            let fz: Float = z + Float(gzi - 2) * 4 + r.range(-1, 1)
            let alt = (gx + gzi) % 2 == 0
            switch kind {
            case "sunflower":
                m.part("Flower Stem", at: (fx, y + 0.8, fz), size: (0.15, 1.6, 0.15), color: "#15803D", shape: .cylinder, solid: false)
                m.part("Sunflower", at: (fx, y + 1.7, fz), size: (1.2, 0.18, 1.2), color: "#FACC15", shape: .cylinder, solid: false, rotation: (-60, 0, 0))
                m.part("Sunflower Seeds", at: (fx, y + 1.72, fz - 0.06), size: (0.55, 0.2, 0.55), color: "#78350F", shape: .cylinder, solid: false,
                       rotation: (-60, 0, 0))
            case "clover":
                m.part("Clover", at: (fx, y + 0.25, fz), size: (1.3, 0.45, 1.3), color: alt ? "#16A34A" : "#22C55E", shape: .sphere, material: .matte, solid: false)
                m.part("Clover Bloom", at: (fx + 0.2, y + 0.6, fz), size: (0.45, 0.45, 0.45), color: alt ? "#FFFFFF" : "#FBCFE8", shape: .sphere, solid: false)
            case "blueflower":
                m.part("Flower Stem", at: (fx, y + 0.5, fz), size: (0.12, 1, 0.12), color: "#15803D", shape: .cylinder, solid: false)
                m.part("Blue Flower", at: (fx, y + 1.1, fz), size: (0.8, 0.5, 0.8), color: alt ? "#3B82F6" : "#93C5FD", shape: .sphere, solid: false)
            case "mushroom":
                m.part("Mushroom Stem", at: (fx, y + 0.4, fz), size: (0.4, 0.8, 0.4), color: "#FEF3C7", shape: .cylinder, solid: false)
                m.part("Mushroom Cap", at: (fx, y + 0.9, fz), size: (1.4, 0.7, 1.4), color: alt ? "#DC2626" : "#EF4444", shape: .sphere, solid: false)
                m.part("Mushroom Spot", at: (fx + 0.3, y + 1.2, fz - 0.2), size: (0.25, 0.1, 0.25), color: "#FFFFFF", shape: .sphere, solid: false)
            case "pine":
                m.part("Pine Sapling", at: (fx, y + 0.8, fz), size: (0.9, 1.6, 0.9), color: alt ? "#166534" : "#15803D", shape: .cone, material: .matte, solid: false)
                m.part("Pine Bloom", at: (fx, y + 0.2, fz + 0.6), size: (0.35, 0.35, 0.35), color: "#60A5FA", shape: .sphere, solid: false)
            case "rose":
                m.part("Rose Bush", at: (fx, y + 0.35, fz), size: (1.2, 0.7, 1.2), color: "#166534", shape: .sphere, material: .matte, solid: false)
                m.part("Rose", at: (fx, y + 0.8, fz), size: (0.55, 0.5, 0.55), color: alt ? "#E11D48" : "#FB7185", shape: .sphere, solid: false)
            case "cactus":
                m.part("Cactus", at: (fx, y + 0.8, fz), size: (0.55, 1.6, 0.55), color: "#4D7C0F", shape: .cylinder, material: .matte, solid: false)
                m.part("Cactus Arm", at: (fx + 0.4, y + 1, fz), size: (0.35, 0.8, 0.35), color: "#4D7C0F", shape: .cylinder, material: .matte, solid: false)
                m.part("Cactus Flower", at: (fx, y + 1.7, fz), size: (0.4, 0.3, 0.4), color: alt ? "#F472B6" : "#FDE047", shape: .sphere, solid: false)
            default:
                m.part("Flower Stem", at: (fx, y + 0.45, fz), size: (0.12, 0.9, 0.12), color: "#15803D", shape: .cylinder, solid: false)
                m.part("Mountain Flower", at: (fx, y + 1, fz), size: (0.7, 0.45, 0.7), color: alt ? "#F5F3FF" : "#C4B5FD", shape: .sphere, material: .neon,
                       solid: false)
            }
        }
    }
}

func buzzMeadow(_ m: MapBuilder) {
    m.day(ground: "#65A30D")
    m.ground(240, 260, color: "#84CC16", name: "Meadow", z: 50)
    m.part("Cover Focus", at: (0, 3, 58), size: (118, 1, 1), color: "#000000", tags: ["yaw=160"], solid: false, visible: false)
    // The hub: a honey fountain in a ring of spawns.
    m.part("Fountain Basin", at: (0, 0.4, 0), size: (4.4, 0.8, 4.4), color: "#E7E5E4", shape: .cylinder)
    m.part("Fountain Honey", at: (0, 0.82, 0), size: (3.8, 0.06, 3.8), color: "#FBBF24", shape: .cylinder, material: .glass, solid: false)
    m.part("Fountain Column", at: (0, 1.6, 0), size: (0.6, 1.6, 0.6), color: "#E7E5E4", shape: .cylinder)
    m.part("Fountain Drop", at: (0, 2.9, 0), size: (1.2, 1.5, 1.2), color: "#F59E0B", shape: .sphere, material: .neon, solid: false)
    m.spawnRing(0, 0, radius: 5.5, count: 10, color: "#FACC15")
    // Paths: hub to the first row, then a grid between the fields.
    let dirt = "#D6B98C"
    m.part("Path", at: (0, 0.02, 13.5), size: (4, 0.04, 19), color: dirt, material: .matte, solid: false)
    for pz: Float in [23, 53, 83] {
        m.part("Path", at: (0, 0.02, pz), size: (64, 0.04, 3), color: dirt, material: .matte, solid: false)
    }
    m.part("Path", at: (0, 0.02, 111), size: (34, 0.04, 3), color: dirt, material: .matte, solid: false)
    for px: Float in [-15, 15] {
        m.part("Path", at: (px, 0.02, 67), size: (3, 0.04, 88), color: dirt, material: .matte, solid: false)
    }
    for pz: Float in [8, 18] {
        for px: Float in [-3.2, 3.2] { m.lamp(px, pz, glow: "#FDE68A") }
    }
    // Eight hives in a row behind the spawn; the pad in front of each is where pollen turns into honey.
    let hiveColors = ["#F59E0B", "#FBBF24", "#EAB308", "#F97316", "#FACC15", "#D97706", "#FCD34D", "#FB923C"]
    for i in 0..<8 {
        let hx: Float = -21 + Float(i) * 6
        let hz: Float = -20
        m.slab("Hive Stand", x: hx, y: 0, z: hz, w: 3.6, h: 0.6, d: 3.6, color: "#78350F")
        m.part("Hive \(i + 1)", at: (hx, 2.1, hz), size: (3.2, 2.6, 3.2), color: hiveColors[i], shape: .cylinder, material: .matte)
        m.part("Hive Top", at: (hx, 4, hz), size: (2.5, 1.2, 2.5), color: hiveColors[i], shape: .cylinder, material: .matte)
        m.part("Hive Cap", at: (hx, 4.8, hz), size: (1.7, 0.9, 1.7), color: "#FDE68A", shape: .sphere, material: .matte, solid: false)
        for by: Float in [1.5, 2.7] {
            m.part("Hive Band", at: (hx, by, hz), size: (3.3, 0.16, 3.3), color: "#92400E", shape: .cylinder, solid: false)
        }
        m.part("Hive Door", at: (hx, 1.8, hz + 1.6), size: (0.9, 0.1, 0.9), color: "#1C1917", shape: .cylinder, solid: false, rotation: (90, 0, 0))
        m.part("Hive Drip", at: (hx - 0.9, 3.1, hz + 1.45), size: (0.35, 0.7, 0.35), color: "#F59E0B", shape: .sphere, material: .glass, solid: false)
        m.pad("Hive \(i + 1) Pad", x: hx, z: hz + 4.2, size: 2.8, color: "#FDE047", tags: ["hive"])
    }
    // The egg shop and the gear shop either side of the hub.
    m.shop("Egg Shop", x: -27, z: 2, color: "#FEF3C7", sign: "#F59E0B")
    m.pad("Egg Counter", x: -27, z: 3.8, size: 2.4, color: "#FDE68A", tags: ["eggs"])
    let eggs: [(Float, String, MaterialKind)] = [(-1.4, "#FFFBEB", .plastic), (0, "#CBD5E1", .metal), (1.4, "#FACC15", .metal)]
    for e in eggs {
        m.part("Egg Display", at: (-27 + e.0, 1.55, 1), size: (0.7, 0.95, 0.7), color: e.1, shape: .sphere, material: e.2, solid: false)
    }
    m.shop("Gear Shop", x: 27, z: 2, color: "#BFDBFE", sign: "#2563EB")
    m.pad("Gear Counter", x: 27, z: 3.8, size: 2.4, color: "#93C5FD", tags: ["gearshop"])
    m.part("Gear Rake", at: (25.8, 1.9, 1), size: (0.12, 1.6, 0.12), color: "#A16207", shape: .cylinder, solid: false, rotation: (0, 0, 20))
    m.part("Gear Bag", at: (27.6, 1.5, 1), size: (0.9, 0.8, 0.6), color: "#0E7490", shape: .sphere, solid: false)
    m.part("Gear Jar", at: (28.8, 1.55, 1), size: (0.5, 0.9, 0.5), color: "#E0F2FE", shape: .cylinder, material: .glass, solid: false)
    // The bear who hands out quests, beside a honey pot.
    let bx: Float = -12, bz: Float = 13
    m.part("Bear Body", at: (bx, 1.4, bz), size: (2.6, 2.8, 2.2), color: "#92400E", shape: .sphere, material: .matte)
    m.part("Bear Belly", at: (bx, 1.3, bz - 1), size: (1.5, 1.7, 0.4), color: "#FDE68A", shape: .sphere, solid: false)
    m.part("Bear Head", at: (bx, 3.3, bz - 0.2), size: (1.8, 1.7, 1.7), color: "#92400E", shape: .sphere, material: .matte, solid: false)
    for s: Float in [-1, 1] {
        m.part("Bear Ear", at: (bx + s * 0.7, 4.1, bz - 0.2), size: (0.6, 0.6, 0.35), color: "#78350F", shape: .sphere, solid: false)
        m.part("Bear Eye", at: (bx + s * 0.35, 3.6, bz - 1), size: (0.2, 0.2, 0.1), color: "#111111", shape: .sphere, solid: false)
    }
    m.part("Bear Snout", at: (bx, 3.1, bz - 1.05), size: (0.7, 0.5, 0.4), color: "#FDE68A", shape: .sphere, solid: false)
    m.part("Bear Nose", at: (bx, 3.25, bz - 1.25), size: (0.25, 0.18, 0.12), color: "#111111", shape: .sphere, solid: false)
    m.part("Honey Pot", at: (bx + 2.2, 0.6, bz - 0.4), size: (1.2, 1.2, 1.2), color: "#B45309", shape: .cylinder)
    m.part("Honey Pot Top", at: (bx + 2.2, 1.25, bz - 0.4), size: (1, 0.1, 1), color: "#FBBF24", shape: .cylinder, material: .glass, solid: false)
    m.pad("Bear Pad", x: bx, z: bz - 3, size: 2.6, color: "#FDBA74", tags: ["bear"])
    // The fields: three rows out from the hub, and the mountain field on a plateau at the back.
    var r = Seeded("bees")
    beeField(m, id: "sunflower", x: 0, z: 38, soil: "#A3E635", border: "#FACC15", need: 0, kind: "sunflower", r: &r)
    beeField(m, id: "clover", x: -30, z: 38, soil: "#4ADE80", border: "#16A34A", need: 5, kind: "clover", r: &r)
    beeField(m, id: "blueflower", x: 30, z: 38, soil: "#7DD3FC", border: "#2563EB", need: 5, kind: "blueflower", r: &r)
    beeField(m, id: "pine", x: -30, z: 68, soil: "#3F6212", border: "#1E3A8A", need: 15, kind: "pine", r: &r)
    beeField(m, id: "mushroom", x: 0, z: 68, soil: "#A16207", border: "#DC2626", need: 10, kind: "mushroom", r: &r)
    beeField(m, id: "rose", x: 30, z: 68, soil: "#65A30D", border: "#E11D48", need: 15, kind: "rose", r: &r)
    beeField(m, id: "cactus", x: 0, z: 98, soil: "#FDE68A", border: "#D97706", need: 20, kind: "cactus", r: &r)
    for pz in stride(from: Float(58), through: 78, by: 5) { m.pine(-45, pz, height: 6) }
    // The mountain: a plateau up a staircase, with a snowy peak behind.
    m.slab("Mountain", x: 0, y: 0, z: 139, w: 30, h: 6, d: 28, color: "#A8A29E", material: .matte)
    for i in 0..<12 {
        m.slab("Mountain Step", x: 0, y: 0, z: 113.5 + Float(i), w: 6, h: 0.5 * Float(i + 1), d: 1, color: i % 2 == 0 ? "#D6D3D1" : "#E7E5E4")
    }
    beeField(m, id: "mountain", x: 0, z: 139, y: 6, soil: "#E0E7FF", border: "#A78BFA", need: 25, kind: "mountain", r: &r)
    m.part("Peak", at: (0, 14, 168), size: (48, 28, 26), color: "#78716C", shape: .cone, material: .matte)
    m.part("Peak Snow", at: (0, 24.5, 168), size: (18, 8, 10), color: "#F8FAFC", shape: .cone, material: .matte, solid: false)
    for p in [(-14, 126), (14, 127), (-14, 151), (13, 152)] as [(Float, Float)] {
        m.rock(p.0, p.1, y: 6, size: 2.2, color: "#D6D3D1", name: "Snow Rock")
    }
    // The king beetle's cave: a rocky mound west of the cactus field, open on the east side.
    let cv: (Float, Float) = (-34, 98)
    m.slab("Cave Floor", x: cv.0, y: 0, z: cv.1, w: 16, h: 0.2, d: 16, color: "#292524")
    let rock = "#57534E"
    m.slab("Cave Wall", x: cv.0, y: 0, z: cv.1 - 8.5, w: 18, h: 7, d: 1, color: rock)
    m.slab("Cave Wall", x: cv.0, y: 0, z: cv.1 + 8.5, w: 18, h: 7, d: 1, color: rock)
    m.slab("Cave Wall", x: cv.0 - 8.5, y: 0, z: cv.1, w: 1, h: 7, d: 16, color: rock)
    for s: Float in [-1, 1] {
        m.slab("Cave Wall", x: cv.0 + 8.5, y: 0, z: cv.1 + s * 5.5, w: 1, h: 7, d: 5, color: rock)
    }
    m.slab("Cave Wall", x: cv.0 + 8.5, y: 4.6, z: cv.1, w: 1, h: 2.4, d: 6, color: rock)
    m.slab("Cave Roof", x: cv.0, y: 7, z: cv.1, w: 19, h: 1, d: 19, color: "#44403C")
    let mound: [(Float, Float, Float)] = [(-10, -9, 8), (0, -10, 9), (10, -9, 7), (-10, 9, 8), (0, 10, 9), (10, 9, 7), (-11, 0, 9), (0, 0, 10)]
    for q in mound {
        m.part("Cave Rock", at: (cv.0 + q.0, q.2 * 0.45, cv.1 + q.1), size: (q.2, q.2 * 0.9, q.2), color: "#78716C", shape: .sphere, material: .matte)
    }
    m.part("Cave Sign", at: (cv.0 + 9.2, 5.8, cv.1), size: (0.2, 0.8, 5), color: "#DC2626", material: .neon, solid: false)
    for q in [(-6, -6), (6, -6), (-6, 6), (6, 6)] as [(Float, Float)] {
        m.part("Cave Crystal", at: (cv.0 + q.0, 1, cv.1 + q.1), size: (0.8, 2, 0.8), color: "#A78BFA", shape: .cone, material: .neon, solid: false)
    }
    // A pond east of the cactus field.
    m.water(34, 98, w: 18, d: 14, y: 0.06, name: "Pond")
    for q in [(29, 95), (37, 101), (39, 94)] as [(Float, Float)] {
        m.part("Lily Pad", at: (q.0, 0.1, q.1), size: (1.6, 0.05, 1.6), color: "#16A34A", shape: .cylinder, solid: false)
    }
    for q in [(25, 92), (43, 104), (26, 105)] as [(Float, Float)] { m.rock(q.0, q.1, size: 1.8) }
    // Trees round the edge, and a few wild bees in the air.
    for tz in stride(from: Float(-40), through: 150, by: 14) {
        for s: Float in [-1, 1] {
            m.tree(s * (56 + r.range(-3, 3)), tz + r.range(-3, 3), height: r.range(4, 6), leaves: r.pick(["#15803D", "#16A34A", "#65A30D"]))
        }
    }
    for tx in stride(from: Float(-42), through: 42, by: 14) {
        m.tree(tx + r.range(-2, 2), -42 + r.range(-2, 2), height: r.range(4, 6), leaves: r.pick(["#15803D", "#16A34A", "#65A30D"]))
    }
    for k in 0..<10 {
        let wx: Float = r.range(-40, 40), wz: Float = r.range(10, 100), wy: Float = r.range(2.5, 4.5)
        m.part("Wild Bee", at: (wx, wy, wz), size: (0.5, 0.45, 0.7), color: k % 2 == 0 ? "#FACC15" : "#F59E0B", shape: .sphere, solid: false)
        m.part("Wild Bee Wing", at: (wx, wy + 0.3, wz), size: (0.8, 0.05, 0.35), color: "#E0F2FE", material: .glass, solid: false, opacity: 0.7)
    }
}

// MARK: 64 Dungeon Delve

/// Four walls round a dungeon room, with a 4 m doorway in the middle of each
/// side named in `open` ("N" is +z, "S" −z, "E" +x, "W" −x).
func dungeonWalls(_ m: MapBuilder, cx: Float, cz: Float, size s: Float, open: String, color: String) {
    let h: Float = 5
    let half = s / 2
    let seg = half + 0.5 - 2
    for side in ["N", "S", "E", "W"] {
        let alongX = side == "N" || side == "S"
        let sign: Float = side == "N" || side == "E" ? 1 : -1
        let wx: Float = alongX ? cx : cx + sign * half
        let wz: Float = alongX ? cz + sign * half : cz
        if open.contains(side) {
            for k: Float in [-1, 1] {
                let off = k * (2 + seg / 2)
                m.slab("Dungeon Wall", x: alongX ? wx + off : wx, y: 0, z: alongX ? wz : wz + off, w: alongX ? seg : 1, h: h, d: alongX ? 1 : seg,
                       color: color, tags: ["dwall"])
            }
            m.slab("Dungeon Wall", x: wx, y: 4, z: wz, w: alongX ? 4 : 1, h: 1, d: alongX ? 1 : 4, color: color, tags: ["dwall"])
        } else {
            m.slab("Dungeon Wall", x: wx, y: 0, z: wz, w: alongX ? s + 1 : 1, h: h, d: alongX ? 1 : s + 1, color: color, tags: ["dwall"])
        }
    }
}

func dungeonDelve(_ m: MapBuilder) {
    m.indoor(ground: "#000000")
    m.sky("#1C1917", "#44403C", light: 0.75, showGround: false, fall: -30)
    m.part("Cover Focus", at: (6, 0, 72), size: (104, 1, 1), color: "#000000", tags: ["yaw=215"], solid: false, visible: false)
    var r = Seeded("dungeon")
    // The camp: spawns round a fire, the class altars, the smith, the merchant, the records board and the gate.
    let lz: Float = -34
    m.slab("Camp Floor", x: 0, y: -1, z: lz, w: 44, h: 1, d: 30, color: "#57534E")
    m.walls(0, lz, w: 44, d: 30, h: 5, color: "#44403C", name: "Camp Wall")
    m.spawnRing(0, lz - 4, radius: 4, count: 8, color: "#FDE68A")
    m.part("Campfire Logs", at: (0, 0.2, lz - 4), size: (1.6, 0.4, 1.6), color: "#78350F", shape: .cylinder)
    m.part("Campfire", at: (0, 0.9, lz - 4), size: (1, 1.2, 1), color: "#F97316", shape: .cone, material: .neon, solid: false)
    let classes: [(String, String, String)] = [("warrior", "#B91C1C", "#9CA3AF"), ("ranger", "#15803D", "#A16207"),
                                               ("mage", "#6D28D9", "#C4B5FD"), ("cleric", "#F8FAFC", "#FACC15")]
    for (i, c) in classes.enumerated() {
        let cz: Float = lz - 10.5 + Float(i) * 7
        m.pad("Class \(c.0)", x: -16.5, z: cz, size: 2.6, color: c.1, tags: ["class"])
        m.part("Class Statue Base", at: (-20, 0.3, cz), size: (2, 0.6, 2), color: "#78716C", shape: .cylinder)
        m.part("Class Statue", at: (-20, 1.7, cz), size: (1, 2.2, 0.8), color: c.1)
        m.part("Class Statue Head", at: (-20, 3.2, cz), size: (0.8, 0.8, 0.8), color: "#FDE68A", shape: .sphere, solid: false)
        m.part("Class Statue Tool", at: (-19.3, 2.2, cz + 0.6), size: (0.2, 2, 0.2), color: c.2, material: .metal, solid: false, rotation: (20, 0, 0))
    }
    // The smith: a forge with a glowing mouth, an anvil and the pad.
    m.slab("Forge", x: 18, y: 0, z: lz - 8, w: 5, h: 3.2, d: 3, color: "#292524")
    m.part("Forge Fire", at: (18, 1.2, lz - 6.45), size: (2.4, 1.2, 0.1), color: "#F97316", material: .neon, solid: false)
    m.part("Forge Chimney", at: (18, 4.4, lz - 8.5), size: (1.2, 2.4, 1.2), color: "#44403C", shape: .cylinder)
    m.part("Anvil", at: (15, 0.6, lz - 4), size: (1.6, 1.2, 0.8), color: "#4B5563", material: .metal)
    m.pad("Smith Anvil", x: 15, z: lz - 1.8, size: 2.6, color: "#F97316", tags: ["smith"])
    // The merchant's stall.
    m.slab("Stall Counter", x: 17, y: 0, z: lz + 5, w: 5, h: 1.1, d: 1.2, color: "#92400E")
    for dx: Float in [-2.3, 2.3] { m.part("Stall Pole", at: (17 + dx, 1.8, lz + 6), size: (0.2, 3.6, 0.2), color: "#A16207", solid: false) }
    m.slab("Stall Awning", x: 17, y: 3.6, z: lz + 5.6, w: 5.6, h: 0.2, d: 2.6, color: "#DC2626")
    for (k, c) in ["#EF4444", "#3B82F6", "#22C55E"].enumerated() {
        m.part("Stall Potion", at: (15.6 + Float(k) * 1.4, 1.45, lz + 5), size: (0.4, 0.6, 0.4), color: c, shape: .cylinder, material: .glass, solid: false)
    }
    m.pad("Merchant Pad", x: 17, z: lz + 2.8, size: 2.6, color: "#FACC15", tags: ["shop"])
    // Training dummies and the records board.
    m.markers("Dummy Spot", points: [(6, lz + 10), (10, lz + 10)], color: "#000000", visible: false, behavior: .none)
    m.part("Board", at: (-10, 2.6, lz + 14.4), size: (6, 2.6, 0.2), color: "#1E3A8A", material: .neon, solid: false)
    m.part("Board Frame", at: (-10, 2.6, lz + 14.55), size: (6.6, 3.2, 0.1), color: "#78350F", solid: false)
    m.pad("Board Pad", x: -10, z: lz + 12, size: 2.6, color: "#60A5FA", tags: ["board"])
    // The gate: a stone arch with a purple portal in the north wall.
    for dx: Float in [-3, 3] { m.slab("Gate Pillar", x: dx, y: 0, z: lz + 14.2, w: 1.4, h: 6, d: 1.4, color: "#78716C") }
    m.slab("Gate Arch", x: 0, y: 6, z: lz + 14.2, w: 7.4, h: 1.2, d: 1.4, color: "#78716C")
    m.part("Gate Portal", at: (0, 3, lz + 14.2), size: (4.6, 6, 0.3), color: "#7C3AED", material: .neon, solid: false, opacity: 0.8)
    m.pad("Dungeon Gate", x: 0, z: lz + 11.5, size: 3.6, color: "#A855F7", tags: ["gate"])
    for p in [(-20.8, lz - 13.8), (20.8, lz - 13.8), (-20.8, lz + 13.8), (20.8, lz + 13.8)] as [(Float, Float)] {
        m.part("Camp Torch", at: (p.0, 3.2, p.1), size: (0.5, 0.5, 0.5), color: "#F97316", shape: .sphere, material: .neon, solid: false)
    }
    // The dungeon: eight rooms snaking north, each closed off from the next by a door.
    let rooms: [(Float, Float, Float, String)] = [(0, 20, 24, "N"), (0, 50, 24, "SE"), (32, 50, 24, "WN"), (32, 80, 24, "SW"),
                                                   (0, 80, 24, "EW"), (-32, 80, 24, "EN"), (-32, 112, 24, "SE"), (2, 112, 36, "W")]
    for (i, rm) in rooms.enumerated() {
        let n = i + 1
        let boss = n == 8
        m.slab("Room \(n) Floor", x: rm.0, y: -1, z: rm.1, w: rm.2, h: 1, d: rm.2, color: boss ? "#57534E" : "#78716C", tags: ["dfloor"])
        dungeonWalls(m, cx: rm.0, cz: rm.1, size: rm.2, open: rm.3, color: "#44403C")
        m.part("Room \(n) Center", at: (rm.0, 0.5, rm.1), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)
        m.part("Room Rune", at: (rm.0, 0.02, rm.1), size: (boss ? 12 : 7, 0.04, boss ? 12 : 7), color: "#F97316", shape: .cylinder, material: .neon,
               tags: ["torch"], solid: false, opacity: 0.35)
        let pd: Float = boss ? 12 : rm.2 / 2 - 5
        let posts: [(Float, Float)] = boss ? ring(6, radius: 12, cx: rm.0, cz: rm.1, phase: 0.52) :
            [(rm.0 - pd, rm.1 - pd), (rm.0 + pd, rm.1 - pd), (rm.0 - pd, rm.1 + pd), (rm.0 + pd, rm.1 + pd)]
        for p in posts {
            m.slab("Dungeon Pillar", x: p.0, y: 0, z: p.1, w: 1.4, h: 5, d: 1.4, color: "#44403C", tags: ["dwall"])
            m.part("Dungeon Torch", at: (p.0, 5.4, p.1), size: (0.6, 0.6, 0.6), color: "#F97316", shape: .sphere, material: .neon, tags: ["torch"], solid: false)
        }
        // Rubble and bones.
        for _ in 0..<(boss ? 6 : 3) {
            let hx = rm.0 + r.range(-rm.2 / 2 + 2, rm.2 / 2 - 2), hz = rm.1 + r.range(-rm.2 / 2 + 2, rm.2 / 2 - 2)
            if abs(hx - rm.0) < 3 && abs(hz - rm.1) < 3 { continue }
            if r.unit() < 0.5 {
                m.part("Rubble", at: (hx, 0.25, hz), size: (1.2, 0.5, 1), color: "#78716C", shape: .sphere, material: .matte, solid: false)
            } else {
                m.part("Bones", at: (hx, 0.1, hz), size: (0.9, 0.12, 0.2), color: "#E7E5E4", shape: .cylinder, solid: false, rotation: (0, r.range(0, 180), 90))
            }
        }
    }
    // The throne at the back of the boss hall.
    m.slab("Throne Dais", x: 2, y: 0, z: 125, w: 10, h: 0.6, d: 5, color: "#7F1D1D")
    m.slab("Throne", x: 2, y: 0.6, z: 126.5, w: 3, h: 1, d: 2, color: "#78350F")
    m.slab("Throne Back", x: 2, y: 0.6, z: 127.6, w: 3, h: 4, d: 0.5, color: "#78350F")
    m.part("Throne Gem", at: (2, 4.2, 127.3), size: (0.8, 0.8, 0.2), color: "#FACC15", shape: .sphere, material: .neon, solid: false)
    // Corridors, each with the door that opens when its room is cleared.
    let halls: [(Float, Float, Float, Float)] = [(0, 32, 0, 38), (12, 50, 20, 50), (32, 62, 32, 68), (20, 80, 12, 80),
                                                  (-12, 80, -20, 80), (-32, 92, -32, 100), (-20, 112, -16, 112)]
    for (i, h) in halls.enumerated() {
        let n = i + 1
        let alongZ = h.0 == h.2
        let mx = (h.0 + h.2) / 2, mz = (h.1 + h.3) / 2
        let len = abs(h.2 - h.0) + abs(h.3 - h.1)
        m.slab("Hall \(n) Floor", x: mx, y: -1, z: mz, w: alongZ ? 4 : len + 1, h: 1, d: alongZ ? len + 1 : 4, color: "#57534E", tags: ["dfloor"])
        for k: Float in [-1, 1] {
            m.slab("Dungeon Wall", x: alongZ ? mx + k * 2.5 : mx, y: 0, z: alongZ ? mz : mz + k * 2.5, w: alongZ ? 1 : len, h: 5, d: alongZ ? len : 1,
                   color: "#44403C", tags: ["dwall"])
        }
        m.slab("Room \(n) Door", x: mx, y: 0, z: mz, w: alongZ ? 4 : 0.8, h: 4, d: alongZ ? 0.8 : 4, color: "#78350F", tags: ["rdoor"])
    }
}

// MARK: 65 Critter Quest

func critterQuest(_ m: MapBuilder) {
    m.day(ground: "#4D7C0F")
    m.ground(170, 300, color: "#65A30D", name: "Route", z: 30)
    m.part("Cover Focus", at: (0, 2, 4), size: (150, 1, 1), color: "#000000", tags: ["yaw=200"], solid: false, visible: false)
    m.road(from: (0, -78), to: (0, 144), width: 6, name: "Route Path", dashed: false, color: "#D6B98C")
    var r = Seeded("critters")
    // The town: spawns, the Critter Center (healing and the storage box), the shop and the professor's lab.
    m.slab("Town Square", x: 0, y: 0, z: -86, w: 60, h: 0.06, d: 30, color: "#E7E5E4")
    m.spawnRing(0, -80, radius: 4, count: 8, color: "#F87171")
    m.part("Town Fountain", at: (0, 0.5, -80), size: (2.4, 1, 2.4), color: "#93C5FD", shape: .cylinder, material: .glass)
    m.shop("Critter Center", x: 17, z: -90, w: 12, d: 8, color: "#F87171", sign: "#FFFFFF")
    m.pad("Heal Counter", x: 14.5, z: -87.6, size: 2.2, color: "#FDA4AF", tags: ["heal"])
    m.pad("PC Pad", x: 19.5, z: -87.6, size: 2.2, color: "#93C5FD", tags: ["pc"])
    m.part("PC Screen", at: (19.5, 1.8, -89.6), size: (1.4, 1, 0.2), color: "#38BDF8", material: .neon, solid: false)
    m.shop("Critter Mart", x: -17, z: -90, w: 10, d: 8, color: "#3B82F6", sign: "#FFFFFF")
    m.pad("Mart Counter", x: -17, z: -87.6, size: 2.2, color: "#93C5FD", tags: ["mart"])
    m.house("Lab", x: 0, z: -100, w: 12, d: 7, wall: "#F8FAFC", roof: "#475569", floor: "#E5E7EB")
    m.pad("Lab Desk", x: 0, z: -98.6, size: 2.2, color: "#A5B4FC", tags: ["lab"])
    for dx: Float in [-26, 26] { m.lamp(dx, -76, glow: "#FDE68A") }
    // Six patches of tall grass up the route, each its own kind of critter.
    let grass: [(String, Float, Float, String, String)] = [("meadow", -24, -50, "#16A34A", "#4ADE80"), ("lake", 24, -20, "#0E7490", "#22D3EE"),
                                                          ("forest", -24, 12, "#14532D", "#15803D"), ("volcano", 24, 44, "#9A3412", "#EA580C"),
                                                          ("snow", -24, 76, "#E0F2FE", "#F8FAFC"), ("ruins", 24, 108, "#4C1D95", "#A78BFA")]
    for g in grass {
        m.part("Grass \(g.0)", at: (g.1, 0.03, g.2), size: (26, 0.06, 22), color: g.3, material: .matte, solid: false)
        for _ in 0..<22 {
            let gx = g.1 + r.range(-12, 12), gz = g.2 + r.range(-10, 10)
            m.part("Tall Grass", at: (gx, 0.55, gz), size: (0.9, 1.1, 0.9), color: r.unit() < 0.5 ? g.3 : g.4, shape: .cone, material: .matte, solid: false)
        }
        m.part("Grass Sign", at: (g.1 > 0 ? g.1 - 14 : g.1 + 14, 1.2, g.2 - 9), size: (0.2, 2.4, 0.2), color: "#78350F", solid: false)
        m.part("Grass Sign Board", at: (g.1 > 0 ? g.1 - 14 : g.1 + 14, 2.2, g.2 - 9), size: (1.6, 0.9, 0.12), color: g.4, solid: false)
    }
    // Scenery for each patch.
    m.water(24, -37, w: 22, d: 8, y: 0.06, name: "Lake")
    for q in [(18, -37), (27, -36), (31, -38)] as [(Float, Float)] {
        m.part("Lily Pad", at: (q.0, 0.1, q.1), size: (1.4, 0.05, 1.4), color: "#16A34A", shape: .cylinder, solid: false)
    }
    for pz in stride(from: Float(2), through: 22, by: 5) { m.pine(-40, pz, height: 6) }
    for px in stride(from: Float(-34), through: -14, by: 5) { m.pine(px, 26, height: 5) }
    m.part("Volcano", at: (28, 7, 70), size: (20, 14, 16), color: "#57534E", shape: .cone, material: .matte)
    m.part("Volcano Lava", at: (28, 13.6, 70), size: (4, 1, 3.2), color: "#F97316", shape: .cylinder, material: .neon, solid: false)
    for q in [(-38, 70), (-36, 82), (-12, 88), (-10, 66)] as [(Float, Float)] {
        m.pine(q.0, q.1, height: 5, leaves: "#E0F2FE")
    }
    for q in [(12, 100), (36, 102), (14, 118), (34, 116), (24, 121)] as [(Float, Float)] {
        let h = r.range(2, 5)
        m.part("Ruin Pillar", at: (q.0, h / 2, q.1), size: (1.2, h, 1.2), color: "#A8A29E", material: .matte)
    }
    // Trainers by the road: each stands by a pad that starts the battle.
    let trainers: [(String, Float, Float)] = [("t1", -6, -62), ("t2", 6, -2), ("t3", -6, 30), ("t4", 6, 62)]
    for t in trainers {
        m.part("Trainer \(t.0)", at: (t.1, 0.1, t.2), size: (1, 0.2, 1), color: "#000000", solid: false, visible: false)
        m.pad("Trainer \(t.0) Pad", x: t.1 > 0 ? t.1 - 2.6 : t.1 + 2.6, z: t.2, size: 2, color: "#FB923C", tags: ["trainer"])
    }
    // Four leaders' gyms, each open toward the road.
    let gyms: [(String, Float, Float, String, String)] = [("leader1", -54, -44, "#16A34A", "#BBF7D0"), ("leader2", 54, -14, "#0284C7", "#BAE6FD"),
                                                         ("leader3", 54, 50, "#DC2626", "#FECACA"), ("leader4", -54, 84, "#7DD3FC", "#F0F9FF")]
    for g in gyms {
        let toward: Float = g.1 < 0 ? 1 : -1
        m.slab("Gym Floor", x: g.1, y: 0, z: g.2, w: 18, h: 0.3, d: 18, color: g.4)
        m.part("Gym Ring", at: (g.1, 0.32, g.2), size: (10, 0.04, 10), color: g.3, shape: .cylinder, solid: false)
        m.slab("Gym Wall", x: g.1 - toward * 9, y: 0, z: g.2, w: 1, h: 4, d: 18, color: g.3)
        for sz: Float in [-9, 9] { m.slab("Gym Wall", x: g.1, y: 0, z: g.2 + sz, w: 18, h: 4, d: 1, color: g.3) }
        for sz: Float in [-6, 6] { m.slab("Gym Wall", x: g.1 + toward * 9, y: 0, z: g.2 + sz, w: 1, h: 4, d: 6, color: g.3) }
        m.part("Gym Emblem", at: (g.1 - toward * 9.6, 5, g.2), size: (0.4, 2.4, 2.4), color: g.3, shape: .cylinder, material: .neon, solid: false,
               rotation: (0, 0, 90))
        m.part("Trainer \(g.0)", at: (g.1 - toward * 5, 0.4, g.2), size: (1, 0.2, 1), color: "#000000", solid: false, visible: false)
        m.pad("Trainer \(g.0) Pad", x: g.1 - toward * 2.2, z: g.2, y: 0.3, size: 2.4, color: "#FACC15", tags: ["trainer"])
    }
    // The champion's hall at the end of the route.
    m.slab("Champion Stage", x: 0, y: 0, z: 134, w: 22, h: 0.6, d: 16, color: "#FDE68A")
    for q in [(-10, 127), (10, 127), (-10, 141), (10, 141)] as [(Float, Float)] {
        m.pillar("Champion Pillar", x: q.0, z: q.1, y: 0.6, height: 6, radius: 0.7, color: "#F8FAFC")
        m.part("Champion Flame", at: (q.0, 7.2, q.1), size: (0.9, 1.2, 0.9), color: "#F59E0B", shape: .cone, material: .neon, solid: false)
    }
    m.part("Trainer champion", at: (0, 0.7, 139), size: (1, 0.2, 1), color: "#000000", solid: false, visible: false)
    m.pad("Trainer champion Pad", x: 0, z: 135.5, y: 0.6, size: 2.6, color: "#F43F5E", tags: ["trainer"])
    // The sky shrine on the hill behind it.
    for i in 0..<10 {
        m.slab("Shrine Step", x: 0, y: 0, z: 146.5 + Float(i), w: 5, h: 0.5 * Float(i + 1), d: 1, color: "#A8A29E")
    }
    m.slab("Shrine Hill", x: 0, y: 0, z: 160, w: 18, h: 5, d: 18, color: "#57534E", material: .matte)
    for dx: Float in [-2.6, 2.6] { m.slab("Torii Pillar", x: dx, y: 5, z: 154, w: 0.6, h: 4.5, d: 0.6, color: "#DC2626") }
    m.slab("Torii Beam", x: 0, y: 9.3, z: 154, w: 7.4, h: 0.6, d: 0.8, color: "#DC2626")
    m.pad("Shrine Pad", x: 0, z: 161, y: 5, size: 3, color: "#818CF8", tags: ["shrine"])
    m.part("Shrine Orb", at: (0, 7.6, 164), size: (1.4, 1.4, 1.4), color: "#A5B4FC", shape: .sphere, material: .neon, solid: false)
    // Trees along both edges of the route.
    for tz in stride(from: Float(-110), through: 170, by: 16) {
        for sx: Float in [-1, 1] {
            let tx = sx * (74 + r.range(-4, 4))
            m.tree(tx, tz + r.range(-4, 4), height: r.range(4, 6))
        }
    }
}

// MARK: 66 Blade Summon Sim

func bladeSummon(_ m: MapBuilder) {
    m.sky("#1E1B4B", "#60A5FA", light: 0.8, showGround: false, fall: -40)
    m.part("Cover Focus", at: (0, 0, 40), size: (120, 1, 1), color: "#000000", tags: ["yaw=205"], solid: false, visible: false)
    var r = Seeded("blades")
    // Six floating worlds in a line, joined by bridges with a gate on each.
    let worlds: [(String, String, String)] = [("#65A30D", "#4D7C0F", "#FACC15"), ("#7C3AED", "#5B21B6", "#E9D5FF"), ("#7F1D1D", "#451A03", "#F97316"),
                                              ("#E0F2FE", "#7DD3FC", "#FFFFFF"), ("#FEF3C7", "#FDE68A", "#FFFFFF"), ("#1E1B4B", "#312E81", "#F0ABFC")]
    for (i, w) in worlds.enumerated() {
        let n = i + 1
        let zc = Float(i) * 75
        let first = n == 1
        let depth: Float = first ? 76 : 60
        let fz: Float = first ? -8 : zc
        m.slab("World \(n) Floor", x: 0, y: -1, z: fz, w: 60, h: 1, d: depth, color: w.0)
        m.slab("World \(n) Rock", x: 0, y: -7, z: fz, w: 52, h: 6, d: depth - 8, color: w.1)
        m.part("World \(n) Spot", at: (0, 0.1, zc - 24), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)
        // The altar.
        m.part("Altar \(n)", at: (-18, 1, zc - 20), size: (3.4, 2, 3.4), color: "#FBBF24", shape: .cylinder, material: .metal, behavior: .trigger, tags: ["altar"])
        m.part("Altar Orb", at: (-18, 3.2, zc - 20), size: (1.4, 1.4, 1.4), color: w.2, shape: .sphere, material: .neon, solid: false)
        for q in ring(4, radius: 2.6, cx: -18, cz: zc - 20, phase: 0.78) {
            m.part("Altar Candle", at: (q.0, 2.4, q.1), size: (0.3, 0.8, 0.3), color: "#FDE68A", shape: .cylinder, material: .neon, solid: false)
        }
        // Where the enemies stand, the elite and the boss ring.
        let spots: [(Float, Float)] = [(-15, -8), (-5, -8), (5, -8), (15, -8), (-10, 2), (10, 2), (-18, 10), (18, 10)]
        m.markers("Enemy \(n)", points: spots.map { ($0.0, zc + $0.1) }, color: "#000000", visible: false, behavior: .none)
        m.part("Elite \(n)", at: (0, 0.1, zc + 6), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)
        m.part("Elite Ring", at: (0, 0.03, zc + 6), size: (5, 0.04, 5), color: "#FACC15", shape: .cylinder, material: .neon, solid: false, opacity: 0.5)
        m.part("Boss \(n)", at: (0, 0.1, zc + 21), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)
        m.part("Boss Ring", at: (0, 0.03, zc + 21), size: (14, 0.04, 14), color: "#EF4444", shape: .cylinder, material: .neon, solid: false, opacity: 0.45)
        for q in ring(6, radius: 8.5, cx: 0, cz: zc + 21) {
            m.pillar("Boss Pillar", x: q.0, z: q.1, height: 3, radius: 0.5, color: w.1)
        }
        // Scenery of each world.
        for _ in 0..<10 {
            var x = r.range(-27, 27), z = zc + r.range(-27, 27)
            if abs(x) < 22 && z > zc - 14 && z < zc + 29 { x = x < 0 ? -26 : 26 }
            if abs(x + 18) < 4 && abs(z - (zc - 20)) < 4 { z += 6 }
            switch n {
            case 1: m.tree(x, z, height: r.range(3, 5))
            case 2: m.part("Crystal", at: (x, 1.4, z), size: (1.2, 2.8, 1.2), color: r.unit() < 0.5 ? "#A78BFA" : "#F0ABFC", shape: .cone, material: .neon, solid: false)
            case 3:
                m.rock(x, z, size: r.range(1.5, 3), color: "#44403C")
                m.part("Lava Pool", at: (x + 2, 0.03, z + 1), size: (2.4, 0.04, 2.4), color: "#F97316", shape: .cylinder, material: .neon, solid: false)
            case 4: m.pine(x, z, height: r.range(4, 6), leaves: "#E0F2FE")
            case 5: m.part("Cloud", at: (x, 0.8, z), size: (3, 1.4, 2.2), color: "#FFFFFF", shape: .sphere, material: .matte, solid: false)
            default: m.part("Star", at: (x, r.range(3, 7), z), size: (0.8, 0.8, 0.8), color: "#F0ABFC", shape: .sphere, material: .neon, solid: false)
            }
        }
        // The bridge and gate into this world.
        if !first {
            let from = Float(i - 1) * 75 + 30
            let to = zc - 30
            m.slab("Bridge", x: 0, y: -1, z: (from + to) / 2, w: 8, h: 1, d: to - from, color: "#A8A29E")
            for sx: Float in [-4.2, 4.2] {
                m.slab("Bridge Rail", x: sx, y: 0, z: (from + to) / 2, w: 0.4, h: 1, d: to - from, color: "#78716C")
            }
            m.part("Area Gate \(n)", at: (0, 3, (from + to) / 2), size: (8, 6, 0.6), color: "#F59E0B", material: .glass, behavior: .trigger,
                   tags: ["gate"], solid: false, opacity: 0.45)
            for sx: Float in [-4.6, 4.6] {
                m.slab("Gate Post", x: sx, y: 0, z: (from + to) / 2, w: 1, h: 7, d: 1, color: "#B45309")
            }
        }
    }
    // The hub at the start of the first world: spawns, the dojo, the enchanting table and the rebirth statue.
    m.spawnRing(0, -38, radius: 4, count: 8, color: "#60A5FA")
    m.house("Dojo", x: 19, z: -38, w: 10, d: 8, wall: "#FEF3C7", roof: "#7F1D1D", floor: "#D6D3D1")
    m.pad("Dojo Pad", x: 19, z: -37, size: 2.4, color: "#3B82F6", tags: ["dojo"])
    m.slab("Enchant Table", x: -19, y: 0, z: -38, w: 3, h: 1.1, d: 2, color: "#4C1D95")
    m.part("Enchant Book", at: (-19, 1.3, -38), size: (1, 0.2, 0.7), color: "#F0ABFC", material: .neon, solid: false)
    m.pad("Enchant Pad", x: -19, z: -35.5, size: 2.4, color: "#A855F7", tags: ["enchant"])
    m.part("Rebirth Statue Base", at: (0, 0.5, -44), size: (3, 1, 3), color: "#9D174D", shape: .cylinder)
    m.part("Rebirth Statue", at: (0, 2.6, -44), size: (1.4, 3.2, 1.4), color: "#F9A8D4", shape: .cone, material: .neon, solid: false)
    m.pad("Rebirth Pad", x: 0, z: -41.4, size: 2.4, color: "#EC4899", tags: ["rebirth"])
}

// MARK: 67 Crusher Yard

func crusherYard(_ m: MapBuilder) {
    m.sky("#94A3B8", "#E2E8F0", light: 0.8, ground: "#57534E")
    m.ground(170, 130, color: "#78716C", name: "Yard", z: -2)
    m.part("Cover Focus", at: (0, 2, 4), size: (116, 1, 1), color: "#000000", tags: ["yaw=200"], solid: false, visible: false)
    var r = Seeded("crusher")
    // The hub: spawns, the garage, the machine shop, the upgrade bench and the prestige statue.
    m.slab("Hub Floor", x: 0, y: 0, z: -42, w: 70, h: 0.06, d: 20, color: "#A8A29E")
    m.spawnRing(0, -40, radius: 5, count: 8, color: "#FACC15")
    m.shop("Garage", x: -26, z: -44, w: 12, d: 8, color: "#1D4ED8", sign: "#FDE68A")
    m.pad("Garage Pad", x: -26, z: -41.8, size: 2.4, color: "#60A5FA", tags: ["garage"])
    m.shop("Machine Shop", x: 26, z: -44, w: 12, d: 8, color: "#B91C1C", sign: "#FDE68A")
    m.pad("Machine Pad", x: 26, z: -41.8, size: 2.4, color: "#F87171", tags: ["machines"])
    m.slab("Upgrade Bench", x: -10, y: 0, z: -48, w: 4, h: 1.1, d: 1.6, color: "#374151")
    m.part("Upgrade Wrench", at: (-10, 1.3, -48), size: (1.6, 0.2, 0.3), color: "#9CA3AF", material: .metal, solid: false, rotation: (0, 30, 0))
    m.pad("Upgrade Pad", x: -10, z: -45.8, size: 2.4, color: "#3B82F6", tags: ["upgrades"])
    m.part("Prestige Base", at: (10, 0.5, -48), size: (2.6, 1, 2.6), color: "#6D28D9", shape: .cylinder)
    m.part("Prestige Star", at: (10, 2.6, -48), size: (1.6, 1.6, 1.6), color: "#F0ABFC", shape: .sphere, material: .neon, solid: false)
    m.pad("Prestige Pad", x: 10, z: -45.6, size: 2.4, color: "#C026D3", tags: ["prestige"])
    // Six lanes: a claim pad, a load button, the belt, the machine bay and the scrap bin.
    let colors = ["#EF4444", "#F59E0B", "#22C55E", "#06B6D4", "#6366F1", "#EC4899"]
    for i in 0..<6 {
        let n = i + 1
        let x = -50 + Float(i) * 20
        m.pad("Lane \(n) Claim", x: x, z: -24, size: 2.6, color: "#FACC15", tags: ["claim"])
        m.part("Lane \(n) Flag", at: (x - 2.4, 2, -24), size: (0.2, 4, 0.2), color: colors[i], material: .neon, solid: false)
        m.pad("Lane \(n) Load", x: x + 4, z: -13, size: 2.2, color: "#22C55E", tags: ["load"])
        m.slab("Lane \(n) Belt", x: x, y: 0, z: 8.5, w: 5, h: 0.6, d: 39, color: "#1F2937")
        for sx: Float in [-2.6, 2.6] {
            m.slab("Belt Edge", x: x + sx, y: 0, z: 8.5, w: 0.3, h: 0.8, d: 39, color: colors[i])
        }
        for k in 0..<7 {
            m.part("Belt Stripe", at: (x, 0.62, -9 + Float(k) * 4.5), size: (4.4, 0.03, 0.3), color: "#4B5563", solid: false)
        }
        m.part("Lane \(n) Start", at: (x, 0.6, -9), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)
        m.part("Lane \(n) Stop", at: (x, 0.6, 22), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)
        m.slab("Machine Bay", x: x, y: 0, z: 22, w: 9, h: 0.1, d: 11, color: "#44403C")
        // The scrap bin behind the machine.
        m.part("Lane \(n) Bin", at: (x, 0.1, 34), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)
        m.part("Bin Floor", at: (x, 0.03, 34), size: (11, 0.06, 8), color: colors[i], material: .matte, solid: false, opacity: 0.6)
        m.slab("Bin Wall", x: x, y: 0, z: 38.3, w: 11, h: 0.8, d: 0.4, color: "#57534E")
        for sx: Float in [-5.7, 5.7] { m.slab("Bin Wall", x: x + sx, y: 0, z: 35.5, w: 0.4, h: 0.8, d: 5.5, color: "#57534E") }
    }
    // Junk piles, tyre stacks and a big crane round the edge of the yard.
    for q in [(-72, -10), (-72, 20), (72, -10), (72, 20), (-40, 52), (0, 54), (40, 52)] as [(Float, Float)] {
        var y: Float = 0
        for k in 0..<4 {
            let h: Float = 0.8
            m.part("Junk", at: (q.0 + r.range(-1, 1), y + h / 2, q.1 + r.range(-1, 1)), size: (4 - Float(k) * 0.6, h, 2.6), color: r.pick(["#A8A29E", "#3B82F6", "#DC2626", "#FACC15", "#57534E"]),
                   material: .metal, rotation: (0, r.range(-30, 30), 0))
            y += h
        }
    }
    for q in [(-62, -30), (62, -30)] as [(Float, Float)] {
        for k in 0..<3 {
            m.part("Tyre", at: (q.0, 0.35 + Float(k) * 0.7, q.1), size: (1.6, 0.6, 1.6), color: "#111827", shape: .cylinder)
        }
    }
    m.slab("Crane Tower", x: 66, y: 0, z: 44, w: 2, h: 16, d: 2, color: "#EAB308")
    m.slab("Crane Jib", x: 56, y: 16, z: 44, w: 22, h: 1, d: 1.2, color: "#EAB308")
    m.part("Crane Magnet", at: (48, 11, 44), size: (3, 0.6, 3), color: "#374151", shape: .cylinder, material: .metal, solid: false)
    for fx in stride(from: Float(-80), through: 80, by: 10) {
        m.fence(from: (fx, 62), to: (fx + 10, 62), color: "#9CA3AF")
    }
}

// MARK: 68 Slime Merge

func slimeMerge(_ m: MapBuilder) {
    m.sky("#A7F3D0", "#ECFDF5", light: 0.85, ground: "#6EE7B7")
    m.ground(220, 280, color: "#86EFAC", name: "Slime Field", z: 50)
    m.part("Cover Focus", at: (0, 2, 22), size: (120, 1, 1), color: "#000000", tags: ["yaw=200"], solid: false, visible: false)
    var r = Seeded("slimes")
    // Big decorative slimes around the hub and the meadow.
    let deco: [(Float, Float, Float, String)] = [(-24, 14, 2.4, "#F9A8D4"), (24, 14, 2, "#38BDF8"), (-10, 34, 1.6, "#FBBF24"), (12, 40, 2.8, "#A78BFA"),
                                                 (-18, 52, 1.8, "#F97316"), (20, 56, 1.4, "#F0ABFC"), (0, 48, 3.4, "#F9A8D4")]
    for d in deco {
        m.part("Deco Slime", at: (d.0, d.2 * 0.42, d.1), size: (d.2 * 1.15, d.2 * 0.85, d.2 * 1.15), color: d.3, shape: .sphere, solid: false)
        for dx: Float in [-0.22, 0.22] {
            m.part("Deco Slime Eye", at: (d.0 + dx * d.2, d.2 * 0.54, d.1 - d.2 * 0.5), size: (d.2 * 0.14, d.2 * 0.2, d.2 * 0.1), color: "#111827", shape: .sphere, solid: false)
        }
    }
    // The hub: spawns, the egg shop, the market, the upgrade stand and the slime book.
    m.slab("Hub Plaza", x: 0, y: 0, z: 2, w: 44, h: 0.06, d: 22, color: "#FEF3C7")
    m.spawnRing(0, 2, radius: 5, count: 8, color: "#34D399")
    m.part("Hub Slime Statue", at: (0, 1.4, 2), size: (2.6, 2, 2.6), color: "#F9A8D4", shape: .sphere)
    let stalls: [(String, Float, Float, String, String)] = [("Egg", -16, 8, "#EC4899", "eggs"), ("Market", 16, 8, "#16A34A", "market"),
                                                            ("Upgrade", -16, -4, "#2563EB", "upgrades"), ("Pedia", 16, -4, "#6D28D9", "pedia")]
    for st in stalls {
        m.slab("\(st.0) Counter", x: st.1, y: 0, z: st.2 + 1.6, w: 4.4, h: 1.1, d: 1, color: "#92400E")
        for dx: Float in [-2, 2] { m.part("\(st.0) Pole", at: (st.1 + dx, 1.7, st.2 + 2.2), size: (0.2, 3.4, 0.2), color: "#A16207", solid: false) }
        m.slab("\(st.0) Awning", x: st.1, y: 3.4, z: st.2 + 1.8, w: 5, h: 0.2, d: 2.4, color: st.3)
        m.pad("\(st.0) Pad", x: st.1, z: st.2 - 0.4, size: 2.4, color: st.3, tags: [st.4])
    }
    // Six ranch plots south of the hub, each with a 4 × 4 grid of pads.
    let plotSpots: [(Float, Float)] = [(-40, -30), (0, -30), (40, -30), (-40, -60), (0, -60), (40, -60)]
    for (i, q) in plotSpots.enumerated() {
        let n = i + 1
        m.slab("Plot \(n) Floor", x: q.0, y: 0, z: q.1, w: 30, h: 0.08, d: 26, color: "#D9F99D")
        m.pad("Plot \(n) Claim", x: q.0, z: q.1 + 11.5, size: 2.6, color: "#FACC15", tags: ["claim"])
        for (k, g) in grid(4, 4, spacing: 5, cx: q.0, cz: q.1 - 1).enumerated() {
            m.part("Plot \(n) Pad \(k + 1)", at: (g.0, 0.15, g.1), size: (3.2, 0.14, 3.2), color: "#D6D3D1", behavior: .trigger, tags: ["pad"])
        }
        for sx: Float in [-15, 15] { m.fence(from: (q.0 + sx, q.1 - 13), to: (q.0 + sx, q.1 + 13), color: "#FBBF24") }
        m.fence(from: (q.0 - 15, q.1 - 13), to: (q.0 + 15, q.1 - 13), color: "#FBBF24")
        m.part("Plot \(n) Sign", at: (q.0 + 4, 1.4, q.1 + 12.6), size: (2.4, 1.2, 0.2), color: "#FEF3C7", solid: false)
    }
    // Seven biomes to the north; the meadow is open, the rest have a gate.
    let biomes: [(String, Float, Float, Float, Float, String, Float, Float)] = [
        ("meadow", 0, 45, 56, 34, "#BBF7D0", 0, 0), ("lake", -66, 45, 44, 34, "#7DD3FC", -40, 45), ("canyon", 66, 45, 44, 34, "#D6B98C", 40, 45),
        ("forest", -66, 97, 44, 40, "#4D7C0F", -66, 70), ("volcano", 66, 97, 44, 40, "#57534E", 66, 70),
        ("cave", 0, 101, 50, 40, "#4C1D95", 0, 71), ("graveyard", 0, 152, 50, 40, "#475569", 0, 126)]
    for b in biomes {
        m.part("Biome \(b.0)", at: (b.1, 0.03, b.2), size: (b.3, 0.06, b.4), color: b.5, material: .matte, solid: false)
        let spots = grid(3, 2, spacing: 12, cx: b.1, cz: b.2)
        m.markers("Wild \(b.0)", points: spots, color: "#000000", visible: false, behavior: .none)
        if b.0 != "meadow" {
            m.pad("Gate \(b.0)", x: b.6, z: b.7, size: 3, color: "#F59E0B", tags: ["gate"])
            let alongX = abs(b.6 - b.1) > abs(b.7 - b.2)
            for k: Float in [-1, 1] {
                m.pillar("Gate Post", x: b.6 + (alongX ? 0 : k * 2.4), z: b.7 + (alongX ? k * 2.4 : 0), height: 4.5, radius: 0.35, color: "#B45309")
            }
            m.part("Gate Glow", at: (b.6, 4.8, b.7), size: (alongX ? 0.4 : 5.2, 0.5, alongX ? 5.2 : 0.4), color: "#FDE68A", material: .neon, solid: false)
        }
        for _ in 0..<12 {
            let x = b.1 + r.range(-b.3 / 2 + 2, b.3 / 2 - 2), z = b.2 + r.range(-b.4 / 2 + 2, b.4 / 2 - 2)
            switch b.0 {
            case "meadow": m.part("Flower", at: (x, 0.35, z), size: (0.6, 0.6, 0.6), color: r.pick(["#F472B6", "#FDE047", "#FFFFFF", "#C084FC"]), shape: .sphere, solid: false)
            case "lake": m.part("Reed", at: (x, 0.8, z), size: (0.2, 1.6, 0.2), color: "#15803D", shape: .cylinder, solid: false)
            case "canyon": m.part("Mesa", at: (x, 1.5, z), size: (r.range(2, 4), 3, r.range(2, 4)), color: "#B45309", material: .matte)
            case "forest": m.tree(x, z, height: r.range(4, 6), leaves: "#15803D")
            case "volcano": m.part("Lava Crack", at: (x, 0.07, z), size: (r.range(1.5, 3), 0.04, 0.5), color: "#F97316", material: .neon, solid: false,
                                   rotation: (0, r.range(0, 180), 0))
            case "cave": m.part("Crystal", at: (x, 1.2, z), size: (1, 2.4, 1), color: r.pick(["#A78BFA", "#F0ABFC", "#67E8F9"]), shape: .cone, material: .neon, solid: false)
            default: m.slab("Tombstone", x: x, y: 0, z: z, w: 1.2, h: 1.6, d: 0.4, color: "#9CA3AF")
            }
        }
    }
    m.water(-66, 45, w: 18, d: 12, y: 0.07, name: "Lake Water")
    m.part("Volcano Cone", at: (80, 7, 110), size: (18, 14, 18), color: "#44403C", shape: .cone, material: .matte)
    m.part("Volcano Lava", at: (80, 13.6, 110), size: (4, 1, 4), color: "#F97316", shape: .cylinder, material: .neon, solid: false)
    for q in [(-80, 110), (-52, 112)] as [(Float, Float)] {
        m.part("Beehive", at: (q.0, 3.5, q.1), size: (1.4, 1.8, 1.4), color: "#F59E0B", shape: .sphere, solid: false)
    }
    for q in [(-20, 165), (20, 165), (-18, 140)] as [(Float, Float)] {
        m.part("Dead Tree", at: (q.0, 2.5, q.1), size: (0.6, 5, 0.6), color: "#44403C", shape: .cylinder)
    }
    for p in ring(16, radius: 105, cx: 0, cz: 40) {
        if abs(p.0) < 100 { m.tree(p.0, p.1, height: 5, leaves: "#10B981") }
    }
}

// MARK: 69 Mansion Builder Tycoon

func mansionTycoon(_ m: MapBuilder) {
    m.day(ground: "#65A30D")
    m.ground(240, 240, color: "#84CC16", name: "Estate")
    m.spawnRing(0, 0, radius: 5, count: 8, color: "#FACC15")
    let items: [(String, Float, Float, V, String, BlockShape)] = [
        ("Foundation", 0, 0, (20, 0.4, 16), "#D6D3D1", .box), ("Ground Floor Walls", 0, -7.8, (20, 3.6, 0.4), "#FEF3C7", .box),
        ("Living Room", -5, -2, (8, 0.1, 8), "#B45309", .box), ("Kitchen", 5, -2, (8, 0.1, 8), "#E5E7EB", .box),
        ("Second Floor", 0, 0, (20, 0.4, 16), "#FDE68A", .box), ("Pool", 0, 12, (12, 0.3, 6), "#38BDF8", .box),
        ("Garage", -12, 0, (6, 3, 10), "#9CA3AF", .box), ("Fountain", 12, 12, (3, 2, 3), "#93C5FD", .sphere),
        ("Tower", 10, -6, (3, 12, 3), "#FDE68A", .cylinder), ("Helipad", 0, 0, (8, 0.2, 8), "#1F2937", .cylinder)
    ]
    for (i, p) in [(-70, -70), (70, -70), (-70, 70), (70, 70)].enumerated() {
        tycoonPlot(m, n: i + 1, x: Float(p.0), z: Float(p.1), color: ["#EF4444", "#3B82F6", "#22C55E", "#F59E0B"][i], items: items,
                   lifts: [0, 0.4, 0.4, 0.4, 4, 0, 0, 0, 0, 4.4], padRow: true)
    }
}

// MARK: 70 +1 Speed Wall Escape

func speedEscape(_ m: MapBuilder) {
    m.sky("#F472B6", "#FDE68A", light: 0.8, showGround: false, fall: -30)
    m.slab("Start Pad", x: 0, y: -1, z: -20, w: 30, h: 1, d: 30, color: "#FFFFFF")
    m.spawnRing(0, -20, radius: 6, count: 12, color: "#F472B6")
    // A very long track in colored segments with gates every 100 m.
    let colors = ["#F87171", "#FB923C", "#FACC15", "#4ADE80", "#22D3EE", "#818CF8", "#E879F9"]
    for i in 0..<30 {
        let z = Float(i) * 50 + 20
        m.slab("Track \(i + 1)", x: 0, y: -1, z: z, w: 24, h: 1, d: 50, color: colors[i % colors.count], tags: ["track"])
        if i % 2 == 1 {
            m.part("Marker \(i / 2 + 1)", at: (0, 4, z + 25), size: (26, 0.6, 0.6), color: "#FFFFFF", material: .neon, solid: false)
        }
        if i > 2 && i % 3 == 0 {
            m.slab("Hurdle \(i + 1)", x: Float(i % 5) * 3 - 6, y: 0, z: z, w: 6, h: 1, d: 1, color: "#111827")
        }
    }
    m.part("Wall Start", at: (0, 8, -40), size: (1, 1, 1), color: "#000000", visible: false)
    m.pad("Rebirth Altar", x: 10, z: -28, size: 3, color: "#A855F7", tags: ["rebirth"])
}
