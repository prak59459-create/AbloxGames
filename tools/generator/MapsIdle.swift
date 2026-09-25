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
         summary: "ダンジョンの部屋を次々に攻略するハクスラ。敵をたおしてレアな剣やよろいを手に入れ、最深部のボスをたおせ。",
         tags: ["dungeon", "loot", "coop"], maxPlayers: 8, build: dungeonDelve),
    Game(number: 65, id: "critter-quest", title: "Critter Quest",
         summary: "草むらでふしぎな生き物「クリッター」に出会ったら、ターン制バトルでつかまえよう。チームを育ててトレーナーに勝て！",
         tags: ["monsters", "rpg", "turn-based"], maxPlayers: 12, build: critterQuest),
    Game(number: 66, id: "blade-summon-sim", title: "Blade Summon Sim",
         summary: "武器を召喚すると、まわりをぐるぐる回って勝手に敵をたおしてくれる。コインでガチャを回して、最強の武器軍団を。",
         tags: ["idle", "summon", "collect"], maxPlayers: 12, build: bladeSummon),
    Game(number: 67, id: "crusher-yard", title: "Crusher Yard",
         summary: "車をベルトコンベアにのせて、プレス機やシュレッダーでグシャッ！こわした車で資金をかせいで、もっと大きな車を。",
         tags: ["simulator", "cars", "satisfying"], maxPlayers: 10, build: crusherYard),
    Game(number: 68, id: "slime-merge", title: "Slime Merge",
         summary: "草原のスライムをつかまえて、同じレベルどうしを合体！台にのせるとお金を生む。最強スライムを作りだせ。",
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

func dungeonDelve(_ m: MapBuilder) {
    m.indoor(ground: "#000000")
    m.sky("#0C0A09", "#1C1917", light: 0.45, showGround: false, fall: -30)
    m.slab("Lobby", x: 0, y: -1, z: -30, w: 26, h: 1, d: 20, color: "#57534E")
    m.walls(0, -30, w: 26, d: 20, h: 5, color: "#44403C", name: "Lobby Wall")
    m.spawnRing(0, -32, radius: 4, count: 8, color: "#FDE68A")
    m.pad("Dungeon Gate", x: 0, z: -21, size: 3, color: "#7C3AED", tags: ["gate"])
    m.shop("Blacksmith", x: -8, z: -36, w: 8, d: 6, color: "#57534E", sign: "#F97316")
    m.pad("Blacksmith Anvil", x: -8, z: -34, size: 2, color: "#F97316", tags: ["smith"])
    // Rooms in a line, each closed by a door.
    for n in 1...6 {
        let z = Float(n) * 30
        let boss = n == 6
        m.slab("Room \(n) Floor", x: 0, y: -1, z: z, w: boss ? 34 : 24, h: 1, d: 24, color: boss ? "#450A0A" : "#44403C")
        m.walls(0, z, w: boss ? 34 : 24, d: 24, h: 6, color: boss ? "#7F1D1D" : "#57534E", name: "Room \(n) Wall")
        m.slab("Room \(n) Door", x: 0, y: 0, z: z + 12, w: 4, h: 4, d: 1, color: "#78350F", tags: ["rdoor"])
        if n < 6 { m.slab("Hall \(n)", x: 0, y: -1, z: z + 15, w: 4, h: 1, d: 6, color: "#57534E") }
        m.part("Room \(n) Center", at: (0, 0.5, z), size: (1, 0.1, 1), color: "#000000", visible: false)
        for p in ring(4, radius: 7, cx: 0, cz: z, phase: 0.5) {
            m.part("Torch", at: (p.0, 3, p.1), size: (0.4, 0.4, 0.4), color: "#F97316", shape: .sphere, material: .neon, solid: false)
        }
    }
    m.slab("Room 0 Hall", x: 0, y: -1, z: 10, w: 4, h: 1, d: 20, color: "#57534E")
}

// MARK: 65 Critter Quest

func critterQuest(_ m: MapBuilder) {
    m.day(ground: "#4D7C0F")
    m.ground(220, 220, color: "#65A30D", name: "Route")
    m.road(from: (0, -100), to: (0, 100), width: 6, name: "Route Path")
    m.spawnRing(0, -80, radius: 4, count: 8, color: "#F87171")
    m.shop("Critter Center", x: 12, z: -80, w: 12, d: 10, color: "#F87171", sign: "#FFFFFF", facing: -1)
    m.pad("Heal Counter", x: 12, z: -82, size: 2.4, color: "#FDA4AF", tags: ["heal"])
    let grass: [(String, Float, Float, String)] = [("Grass Meadow", -30, -40, "#16A34A"), ("Grass Lake", 30, -10, "#0891B2"),
                                                   ("Grass Volcano", -30, 30, "#B45309"), ("Grass Forest", 30, 60, "#14532D")]
    for g in grass {
        m.pad(g.0, x: g.1, z: g.2, size: 26, color: g.3, tags: ["grass"], shape: .box)
        var r = Seeded(g.0)
        for _ in 0..<14 {
            m.part("Tall Grass", at: (g.1 + r.range(-11, 11), 0.5, g.2 + r.range(-11, 11)), size: (1, 1, 1), color: g.3, shape: .cone, solid: false)
        }
    }
    m.slab("Arena", x: 0, y: 0, z: 90, w: 24, h: 0.4, d: 18, color: "#CBD5E1")
    m.pad("Trainer Challenge", x: 0, z: 84, y: 0.4, size: 3, color: "#7C3AED", tags: ["trainer"])
    for p in ring(12, radius: 95) { m.tree(p.0, p.1, height: 5) }
}

// MARK: 66 Blade Summon Sim

func bladeSummon(_ m: MapBuilder) {
    m.sky("#0F172A", "#1E3A8A", light: 0.75, ground: "#1E293B")
    let areas: [(String, String, Float)] = [("Training Grounds", "#475569", 0), ("Crystal Cave", "#6D28D9", 60), ("Lava Fields", "#B91C1C", 120),
                                            ("Sky Palace", "#E0F2FE", 180)]
    for (i, a) in areas.enumerated() {
        m.ground(50, 50, color: a.1, name: "\(a.0) Ground", z: a.2)
        if i > 0 {
            m.part("Area Gate \(i + 1)", at: (0, 3, a.2 - 26), size: (50, 6, 1), color: "#F59E0B", material: .glass, behavior: .trigger,
                   tags: ["gate"], solid: false, opacity: 0.4)
        }
        m.markers("Enemy \(i + 1)", points: grid(3, 2, spacing: 12, cx: 0, cz: a.2 + 8), color: "#000000", visible: false, behavior: .none)
    }
    m.spawnRing(0, -12, radius: 4, count: 8, color: "#60A5FA")
    m.part("Summon Altar", at: (15, 1, -15), size: (4, 2, 4), color: "#FBBF24", shape: .cylinder, material: .metal, behavior: .trigger, tags: ["altar"])
}

// MARK: 67 Crusher Yard

func crusherYard(_ m: MapBuilder) {
    m.sky("#94A3B8", "#CBD5E1", light: 0.75, ground: "#57534E")
    m.ground(160, 120, color: "#78716C", name: "Yard")
    m.spawnRing(0, -40, radius: 5, count: 10, color: "#FACC15")
    m.pad("Car Menu", x: 0, z: -28, size: 3, color: "#F59E0B", tags: ["menu"])
    let crushers: [(String, Float, String)] = [("Press", -40, "#6B7280"), ("Shredder", 0, "#B91C1C"), ("Lava Pit", 40, "#F97316")]
    for c in crushers {
        m.slab("\(c.0) Conveyor", x: c.1, y: 0, z: 0, w: 5, h: 0.6, d: 36, color: "#374151")
        m.part("\(c.0) Start", at: (c.1, 1.5, -14), size: (1, 1, 1), color: "#000000", visible: false)
        m.part("\(c.0) End", at: (c.1, 1.5, 16), size: (1, 1, 1), color: "#000000", visible: false)
        m.slab("\(c.0) Machine", x: c.1, y: 0, z: 22, w: 8, h: 6, d: 8, color: c.2)
        m.pad("\(c.0) Load", x: c.1, z: -20, size: 3, color: "#22C55E", tags: ["load"])
    }
    m.part("Press Head", at: (-40, 6, 16), size: (6, 1.5, 6), color: "#9CA3AF", material: .metal)
}

// MARK: 68 Slime Merge

func slimeMerge(_ m: MapBuilder) {
    m.sky("#A7F3D0", "#ECFDF5", light: 0.85, ground: "#6EE7B7")
    m.ground(140, 140, color: "#86EFAC", name: "Slime Field")
    m.spawnRing(0, 0, radius: 5, count: 10, color: "#34D399")
    m.slab("Ranch", x: 0, y: 0, z: -35, w: 40, h: 0.3, d: 14, color: "#D6B98C")
    for i in 0..<10 {
        m.pad("Pen \(i + 1)", x: -18 + Float(i % 5) * 9, z: i < 5 ? -38 : -32, y: 0.3, size: 3, color: "#FDE68A", tags: ["pen"])
    }
    m.markers("Wild Spot", points: grid(4, 3, spacing: 14, cx: 0, cz: 30), color: "#000000", visible: false, behavior: .none)
    for p in ring(10, radius: 62) { m.tree(p.0, p.1, height: 4, leaves: "#10B981") }
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
