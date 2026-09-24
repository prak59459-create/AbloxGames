import Foundation

// 59–70: idle, gacha, tycoon and collection.

let idleGames: [Game] = [
    Game(number: 59, id: "aura-roll", title: "Aura Roll",
         summary: "ボタンを押してオーラを引く運だめし。天気が変わると特別なオーラが出やすくなる。1億分の1を引き当てろ！",
         tags: ["rng", "collect", "idle"], maxPlayers: 12, build: auraRoll),
    Game(number: 60, id: "raft-to-treasure", title: "Raft to Treasure",
         summary: "ブロックで橋やいかだを作って、危険な川を下って宝箱をめざす工作ゲーム。遠くまで行くほどゴールドがもらえる。",
         tags: ["build", "adventure", "creative"], maxPlayers: 10, build: raftTreasure),
    Game(number: 61, id: "obby-maker", title: "Obby Maker",
         summary: "自分だけのアスレチックコースを作って公開しよう。足場、溶岩、ジャンプ台、チェックポイント。友だちのコースにも挑戦！",
         tags: ["obby", "build", "creative"], maxPlayers: 8, build: obbyMaker),
    Game(number: 62, id: "toy-army-tycoon", title: "Toy Army Tycoon",
         summary: "おもちゃの兵隊を買って基地を大きくするタイクーン。定期的におそってくる敵軍から、兵隊とタレットでコアを守れ。",
         tags: ["tycoon", "army", "defense"], maxPlayers: 8, build: toyArmy),
    Game(number: 63, id: "buzz-meadow", title: "Buzz Meadow",
         summary: "ハチを集めて花畑で花粉を集め、巣でハチミツに変えよう。ハチが増えるほど強くなり、奥の花畑へ行ける。",
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
    m.ground(120, 120, color: "#3730A3", name: "Plaza")
    m.part("Altar", at: (0, 0.6, 0), size: (10, 1.2, 10), color: "#E0E7FF", shape: .cylinder, material: .metal)
    m.part("Orb", at: (0, 4, 0), size: (2.4, 2.4, 2.4), color: "#A78BFA", shape: .sphere, material: .neon, solid: false)
    m.spawnRing(0, 0, radius: 9, count: 10, color: "#C4B5FD")
    for p in ring(8, radius: 30) {
        m.pillar("Crystal Pillar", x: p.0, z: p.1, height: 6, radius: 0.8, color: "#818CF8", material: .glass)
    }
    m.shop("Potion Shop", x: 0, z: -40, w: 12, d: 8, color: "#4C1D95", sign: "#F0ABFC")
    m.pad("Potion Counter", x: 0, z: -38, size: 2.4, color: "#E879F9", tags: ["potions"])
}

// MARK: 60 Raft to Treasure

func raftTreasure(_ m: MapBuilder) {
    m.day(ground: "#65A30D")
    m.sky("#7DD3FC", "#E0F2FE", light: 0.8, ground: "#1D4ED8", showGround: true)
    m.slab("Dock", x: 0, y: -1, z: -20, w: 50, h: 1, d: 20, color: "#A16207")
    m.spawnRing(0, -24, radius: 5, count: 10, color: "#FDE68A")
    // The river: hazard water between stages.
    m.part("River", at: (0, -1.8, 150), size: (40, 1, 320), color: "#2563EB", material: .glass, behavior: .hazard, opacity: 0.8)
    var r = Seeded("raft")
    for i in 0..<8 {
        let z = Float(i + 1) * 36
        m.slab("Stage \(i + 1)", x: r.range(-8, 8), y: -1, z: z, w: 10, h: 1, d: 8, color: i % 2 == 0 ? "#78716C" : "#A8A29E", tags: ["stage"])
        m.pad("Stage \(i + 1) Goal", x: 0, z: z, y: 0, size: 3, color: "#22C55E", tags: ["goal"])
        for k in 0..<2 {
            m.part("Rock \(i + 1)-\(k + 1)", at: (r.range(-15, 15), -0.5, z - r.range(10, 25)), size: (3, 2, 3), color: "#57534E",
                   shape: .sphere, behavior: .hazard)
        }
    }
    m.slab("Treasure Island", x: 0, y: -1, z: 320, w: 20, h: 1, d: 16, color: "#FDE68A")
    m.part("Treasure Chest", at: (0, 0.8, 320), size: (2.4, 1.6, 1.6), color: "#B45309", material: .metal, behavior: .trigger, tags: ["chest"])
    for p in ring(8, radius: 32, cx: 0, cz: -20) { m.tree(p.0, p.1, y: -1, height: 5) }
}

// MARK: 61 Obby Maker

func obbyMaker(_ m: MapBuilder) {
    m.sky("#38BDF8", "#E0F2FE", light: 0.8, showGround: false, fall: -30)
    m.slab("Hub", x: 0, y: -1, z: 0, w: 26, h: 1, d: 26, color: "#E5E7EB")
    m.spawnRing(0, 0, radius: 5, count: 8, color: "#F472B6")
    for i in 0..<8 {
        let a = Float(i) / 8 * 2 * .pi
        let x = cos(a) * 60, z = sin(a) * 60
        m.slab("Build \(i + 1) Start", x: x, y: -1, z: z, w: 8, h: 1, d: 8, color: ["#F87171", "#60A5FA", "#34D399", "#FBBF24", "#A78BFA", "#F472B6", "#22D3EE", "#FB923C"][i],
               tags: ["plotstart"])
        m.pad("Build \(i + 1) Claim", x: x * 0.8, z: z * 0.8, y: -0.4, size: 2, color: "#FFFFFF", tags: ["claim"])
        m.slab("Bridge \(i + 1)", x: x * 0.55, y: -1, z: z * 0.55, w: 3, h: 0.6, d: 3, color: "#D1D5DB")
        m.slab("Bridge \(i + 1)b", x: x * 0.35, y: -1, z: z * 0.35, w: 3, h: 0.6, d: 3, color: "#D1D5DB")
    }
}

// MARK: 62 Toy Army Tycoon

func toyArmy(_ m: MapBuilder) {
    m.day(ground: "#4D7C0F")
    m.ground(220, 220, color: "#65A30D", name: "Battlefield")
    m.spawnRing(0, 0, radius: 5, count: 8, color: "#FACC15")
    let items: [(String, Float, Float, V, String, BlockShape)] = [
        ("Dropper", -8, -10, (2, 3, 2), "#6B7280", .box), ("Barracks", 8, -10, (6, 3, 4), "#78716C", .box),
        ("Wall North", 0, -14, (28, 2.5, 0.8), "#A8A29E", .box), ("Turret 1", -10, 8, (1.6, 2.4, 1.6), "#3F3F46", .cylinder),
        ("Turret 2", 10, 8, (1.6, 2.4, 1.6), "#3F3F46", .cylinder), ("Tank Garage", 0, 10, (6, 2.4, 4), "#57534E", .box),
        ("Wall South", 0, 14, (28, 2.5, 0.8), "#A8A29E", .box), ("Flag", 12, -12, (0.3, 6, 0.3), "#DC2626", .cylinder)
    ]
    for (i, p) in [(-60, -60), (60, -60), (-60, 60), (60, 60)].enumerated() {
        tycoonPlot(m, n: i + 1, x: Float(p.0), z: Float(p.1), color: ["#EF4444", "#3B82F6", "#22C55E", "#F59E0B"][i], items: items,
                   padRow: true)
        m.part("Plot \(i + 1) Core", at: (Float(p.0), 1.4, Float(p.1)), size: (2.4, 2.4, 2.4), color: "#FACC15", shape: .sphere, material: .neon)
    }
    m.markers("Raid Spawn", points: [(0, -100), (0, 100), (-100, 0), (100, 0)], color: "#000000", visible: false, behavior: .none)
}

// MARK: 63 Buzz Meadow

func buzzMeadow(_ m: MapBuilder) {
    m.day(ground: "#65A30D")
    m.ground(220, 220, color: "#84CC16", name: "Meadow")
    m.spawnRing(0, 0, radius: 5, count: 10, color: "#FACC15")
    // Hives, one per player.
    for (i, p) in ring(8, radius: 16).enumerated() {
        m.part("Hive \(i + 1)", at: (p.0, 2, p.1), size: (2.6, 4, 2.6), color: "#F59E0B", shape: .cylinder, material: .matte)
        m.pad("Hive \(i + 1) Pad", x: p.0 * 1.2, z: p.1 * 1.2, size: 2.4, color: "#FDE047", tags: ["hive"])
    }
    let fields: [(String, String, Float, Float, Int)] = [("Sunflower Field", "#FACC15", 0, 45, 0), ("Clover Field", "#4ADE80", -45, 30, 5),
                                                        ("Blue Flower Field", "#60A5FA", 45, 30, 5), ("Mushroom Field", "#EF4444", -60, -30, 10),
                                                        ("Pine Tree Forest", "#166534", 60, -30, 15), ("Rose Field", "#F43F5E", 0, -70, 20),
                                                        ("Mountain Top Field", "#E0E7FF", 0, 90, 30)]
    for f in fields {
        m.pad(f.0, x: f.2, z: f.3, size: 22, color: f.1, tags: ["field", "need\(f.4)"], shape: .box)
        for (k, q) in grid(4, 4, spacing: 5, cx: f.2, cz: f.3).enumerated() where k % 3 == 0 {
            m.part("Flower", at: (q.0, 0.5, q.1), size: (0.9, 0.9, 0.9), color: "#FFFFFF", shape: .sphere, solid: false)
        }
    }
    m.shop("Bee Shop", x: 30, z: 0, w: 10, d: 8, color: "#EAB308", sign: "#111827")
    m.pad("Bee Shop Counter", x: 30, z: 2, size: 2.4, color: "#FACC15", tags: ["beeshop"])
    m.pad("Bear", x: -30, z: 0, size: 2.4, color: "#92400E", tags: ["bear"])
    m.part("Bear Statue", at: (-30, 1.8, -3), size: (2, 3.6, 2), color: "#78350F", shape: .sphere)
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
