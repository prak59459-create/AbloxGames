import Foundation

// 21–32: action, battle and versus.

let actionGames: [Game] = [
    Game(number: 21, id: "power-training-sim", title: "Power Training Sim",
         summary: "力・気・速さ・耐久の4つを修行できたえる育成バトル。岩場や滝の修行場でパワーアップして、ボスや友だちと戦おう。",
         tags: ["training", "rpg", "pvp"], maxPlayers: 12, build: powerTraining),
    Game(number: 22, id: "deflect-ball", title: "Deflect Ball",
         summary: "ねらった相手を追いかける光のボール。ギリギリで「はじく」を押して打ち返せ！最後まで残った人の勝ち。",
         tags: ["pvp", "reflex", "party"], maxPlayers: 12, build: deflectBall),
    Game(number: 23, id: "gun-swap-arena", title: "Gun Swap Arena",
         summary: "たおすたびに武器が変わるスピードFPS。12の武器を順番にクリアして、最後の黄金ナイフで決めた人の勝ち。",
         tags: ["fps", "pvp", "fast"], maxPlayers: 12, build: gunSwap),
    Game(number: 24, id: "warrior-brawl", title: "Warrior Brawl",
         summary: "やり・大剣・刀・爆弾で戦う近接バトル。タイミングよく「はじく」で相手をよろめかせ、回避と包帯で生きのこれ。",
         tags: ["melee", "pvp", "skill"], maxPlayers: 12, build: warriorBrawl),
    Game(number: 25, id: "ring-boxing-league", title: "Ring Boxing League",
         summary: "リングで1対1のボクシング。ジャブ、ストレート、アッパー、ガード。スタミナを考えて打ち合い、ランキングを上げよう。",
         tags: ["boxing", "1v1", "sports"], maxPlayers: 10, build: ringBoxing),
    Game(number: 26, id: "power-roulette", title: "Power Roulette",
         summary: "ラウンドごとにルーレットで能力が決まる！炎、巨大化、ワープ、分身…運と工夫で最後まで生きのこれ。",
         tags: ["rng", "pvp", "party"], maxPlayers: 12, build: powerRoulette),
    Game(number: 27, id: "armed-racers", title: "Armed Racers",
         summary: "武装したレースカーでコースを3周。アイテム箱からミサイル、オイル、ブーストを手に入れて、ライバルをじゃましろ！",
         tags: ["racing", "items", "pvp"], maxPlayers: 8, build: armedRacers),
    Game(number: 28, id: "blade-and-revolver", title: "Blade & Revolver",
         summary: "ナイフとリボルバーだけのデスマッチ。ナイフは投げることもできる。先に20キルした人の勝ち。",
         tags: ["pvp", "deathmatch", "skill"], maxPlayers: 12, build: bladeRevolver),
    Game(number: 29, id: "last-squad", title: "Last Squad vs Horde",
         summary: "人間チームとゾンビの大群のサバイバル。やられた人間はゾンビになる！3分間生きのびて、ヘリで脱出せよ。",
         tags: ["zombies", "teams", "survival"], maxPlayers: 12, build: lastSquad),
    Game(number: 30, id: "style-boxing", title: "Style Boxing",
         summary: "スピード、パワー、タンク、カウンター。自分のスタイルを選んで、必殺技ゲージをためて殴り合うボクシングバトル。",
         tags: ["boxing", "pvp", "styles"], maxPlayers: 12, build: styleBoxing),
    Game(number: 31, id: "hero-academy-sim", title: "Hero Academy Sim",
         summary: "ヒーローかヴィランか。16の個性をガチャで集めて熟練度を上げ、事件の解決や金庫やぶり、停電、改造怪人との戦い、昇格試験に挑む。",
         tags: ["heroes", "rpg", "powers"], maxPlayers: 12, build: heroAcademy),
    Game(number: 32, id: "oni-blade", title: "Oni Blade",
         summary: "夜になると鬼が村をおそう。7つの流派の型をきわめ、刀をきたえて家を守れ。4夜ごとに土蜘蛛や酒呑童子など昔話の鬼の大将があらわれる。",
         tags: ["swords", "rpg", "night"], maxPlayers: 12, build: oniBlade),
]

// MARK: 21 Power Training Sim

func powerTraining(_ m: MapBuilder) {
    m.day(ground: "#6B8E4E")
    m.ground(340, 340, color: "#7CA05A")
    m.part("Dojo Floor", at: (0, 0.1, 0), size: (24, 0.2, 24), color: "#C8A26B", material: .matte)
    for p in [(-11.5, -11.5), (11.5, -11.5), (-11.5, 11.5), (11.5, 11.5)] as [(Float, Float)] {
        m.pillar("Dojo Post", x: p.0, z: p.1, height: 3, radius: 0.4, color: "#7C2D12")
    }
    m.spawnRing(0, 0, y: 0.2, radius: 5, count: 8, color: "#F59E0B")
    m.pad("Champion Shrine", x: 8, z: 8, y: 0.2, size: 3, color: "#FBBF24", tags: ["champion_shrine"])
    m.pad("Rebirth Altar", x: -8, z: 8, y: 0.2, size: 3, color: "#A855F7", tags: ["rebirth_altar"])
    m.pad("Ability Scroll", x: 8, z: -8, y: 0.2, size: 3, color: "#38BDF8", tags: ["ability_board"])
    // Training grounds: three tiers per stat, harder further out. All at
    // walking height — a locked one bounces you off instead.
    let grounds: [(String, String, Float, Float)] = [
        ("Boulder Field", "#78716C", 45, 0), ("Mountain Top", "#57534E", 85, 30), ("Titan Quarry", "#44403C", 135, 60),
        ("Waterfall", "#38BDF8", -45, 0), ("Sky Temple", "#E0E7FF", -85, 30), ("Spirit Realm", "#C4B5FD", -135, 60),
        ("Speed Track", "#F97316", 0, 45), ("Lightning Road", "#FACC15", 0, 85), ("Time Rift", "#22D3EE", -40, 135),
        ("Fire Pit", "#DC2626", 0, -45), ("Volcano Core", "#7F1D1D", 30, -85), ("Meteor Crater", "#1C1917", 80, -135)
    ]
    for (i, g) in grounds.enumerated() {
        let tier = i % 3
        m.slab("\(g.0) Base", x: g.2, y: 0, z: g.3, w: 18 + Float(tier) * 4, h: 0.4, d: 18 + Float(tier) * 4, color: "#A8A29E")
        m.pad(g.0, x: g.2, z: g.3, y: 0.4, size: 12 + Float(tier) * 3, color: g.1, tags: ["zone"])
        for p in ring(4 + tier * 2, radius: 10 + Float(tier) * 2, cx: g.2, cz: g.3, phase: 0.3) {
            m.pillar("\(g.0) Marker", x: p.0, z: p.1, y: 0.4, height: 2 + Float(tier) * 1.5, radius: 0.35, color: g.1,
                     material: tier == 2 ? .neon : .plastic)
        }
    }
    for p in ring(5, radius: 6, cx: 45, cz: 0) { m.rock(p.0, p.1, y: 0.4, size: 2.5) }
    m.part("Falls", at: (-45, 8, -9), size: (10, 16, 1), color: "#7DD3FC", material: .glass, solid: false, opacity: 0.6)
    m.part("Spirit Orb", at: (-135, 8, 60), size: (4, 4, 4), color: "#A78BFA", shape: .sphere, material: .neon, solid: false)
    m.part("Rift Ring", at: (-40, 6, 135), size: (10, 10, 0.6), color: "#22D3EE", shape: .cylinder, material: .neon, solid: false,
           rotation: (90, 0, 0))
    m.part("Crater Rock", at: (80, 3, -135), size: (8, 6, 8), color: "#292524", shape: .sphere)
    // An arena for fights and the boss.
    m.slab("Arena", x: -60, y: 0, z: -60, w: 36, h: 0.4, d: 36, color: "#44403C")
    for side: Float in [-1, 1] {
        m.slab("Arena Wall", x: -60, y: 0.4, z: -60 + side * 18, w: 36, h: 2, d: 1, color: "#292524")
        m.slab("Arena Wall", x: -60 + side * 18, y: 0.4, z: -60 - 10, w: 1, h: 2, d: 16, color: "#292524")
    }
    m.markers("Enemy Spot", points: ring(6, radius: 10, cx: -60, cz: -60), y: 0.4, color: "#000000", visible: false, behavior: .none)
    m.markers("Bandit Spot", points: [(110, 20), (-110, 20), (-20, 110), (55, -110), (120, 90), (-120, 90)], color: "#000000",
              visible: false, behavior: .none)
    m.markers("Chest Spot", points: [(30, 30), (-30, 30), (30, -30), (-30, -30), (100, 100), (-100, 100)], color: "#000000",
              visible: false, behavior: .none)
    for p in ring(18, radius: 150, phase: 0.1) { m.tree(p.0, p.1, height: 6, leaves: "#3F6212") }
}

// MARK: 22 Deflect Ball

func deflectBall(_ m: MapBuilder) {
    m.sky("#0B1026", "#312E81", light: 0.65, ground: "#0F172A", showGround: false)
    m.part("Arena Floor", at: (0, -0.5, 0), size: (60, 1, 60), color: "#1E1B4B", shape: .cylinder, material: .matte)
    m.part("Arena Ring", at: (0, 0.02, 0), size: (58, 0.04, 58), color: "#6366F1", shape: .cylinder, material: .neon, solid: false)
    m.part("Arena Inner", at: (0, 0.03, 0), size: (54, 0.05, 54), color: "#1E1B4B", shape: .cylinder, material: .matte, solid: false)
    for p in ring(12, radius: 30) { m.pillar("Rim Light", x: p.0, z: p.1, height: 2, radius: 0.5, color: "#A5B4FC", material: .neon) }
    m.spawnRing(0, 0, radius: 14, count: 12, color: "#818CF8")
    // The lobby floats above the arena: where you wait, shop and watch.
    m.slab("Lobby", x: 0, y: 12, z: 0, w: 22, h: 0.4, d: 22, color: "#312E81")
    m.walls(0, 0, w: 22, d: 22, h: 1.5, y: 12.4, color: "#4338CA", name: "Lobby Rail")
    m.markers("Lobby Spot", points: [(0, 0), (3, 3), (-3, 3), (3, -3), (-3, -3), (0, 5)], y: 12.4, color: "#000000",
              visible: false, behavior: .none)
    m.pad("Ability Shop", x: -7, z: -7, y: 12.4, size: 3, color: "#0EA5E9", tags: ["ability_shop"])
    m.pad("Blade Crate", x: 7, z: -7, y: 12.4, size: 3, color: "#F59E0B", tags: ["blade_crate"])
    m.pad("Rank Board", x: 0, z: -8, y: 12.4, size: 3, color: "#A78BFA", tags: ["rank_board"])
    m.part("Ball Home", at: (0, 3, 0), size: (0.5, 0.5, 0.5), color: "#FFFFFF", visible: false)
    m.part("Red Side", at: (-14, 0.04, 0), size: (8, 0.02, 8), color: "#EF4444", shape: .cylinder, material: .neon, solid: false, opacity: 0.4)
    m.part("Blue Side", at: (14, 0.04, 0), size: (8, 0.02, 8), color: "#3B82F6", shape: .cylinder, material: .neon, solid: false, opacity: 0.4)
}

// MARK: 23 Gun Swap Arena

func gunSwap(_ m: MapBuilder) {
    m.sky("#F59E0B", "#FDE68A", light: 0.75, ground: "#78716C")
    m.ground(460, 200, color: "#A8A29E", name: "Street")

    // The lobby, north of the street: vote pads, the locker and the spawns.
    m.slab("Lobby", x: 0, y: 0, z: 90, w: 40, h: 0.4, d: 24, color: "#44403C")
    m.walls(0, 90, w: 40, d: 24, h: 3, y: 0.4, color: "#292524", name: "Lobby Wall")
    m.spawnRing(0, 92, y: 0.4, radius: 4, count: 8, color: "#F97316")
    let maps: [(String, Float, String)] = [("Street", -10, "#F59E0B"), ("Warehouse", 0, "#64748B"), ("Rooftops", 10, "#38BDF8")]
    for v in maps {
        m.pad("Vote \(v.0)", x: v.1, z: 82, y: 0.4, size: 3, color: v.2, tags: ["vote_map", v.0.lowercased()])
    }
    let sets: [(String, Float, String)] = [("Classic", -12, "#DC2626"), ("Shotguns", -4, "#A16207"), ("Snipers", 4, "#1D4ED8"), ("Random", 12, "#A855F7")]
    for v in sets {
        m.pad("Vote \(v.0)", x: v.1, z: 98, y: 0.4, size: 2.6, color: v.2, tags: ["vote_set", v.0.lowercased()])
    }
    m.pad("Locker", x: 16, z: 90, y: 0.4, size: 3, color: "#10B981", tags: ["locker"])

    // Arena 1: the street — buildings with stairs to their roofs.
    m.walls(0, 0, w: 100, d: 100, h: 8, color: "#57534E", name: "Boundary")
    var r = Seeded("swap")
    for i in 0..<8 {
        let x = r.range(-38, 38), z = r.range(-38, 38)
        let h = r.range(3, 7)
        m.slab("Building \(i + 1)", x: x, y: 0, z: z, w: r.range(6, 10), h: h, d: r.range(6, 10), color: r.pick(["#B45309", "#92400E", "#6B7280", "#475569"]))
        m.stairs(x - 8, z, steps: Int(h / 0.6), rise: 0.6, run: 0.7, width: 2, color: "#D6D3D1", name: "Stair \(i + 1)")
    }
    for i in 0..<16 {
        m.crate(r.range(-45, 45), r.range(-45, 45), size: r.range(1.2, 2), name: "Cover \(i + 1)")
    }
    m.markers("Street Spot", points: ring(10, radius: 40), color: "#000000", visible: false, behavior: .none)
    m.markers("Street Med", points: [(0, 0), (30, -30), (-30, 30)], y: 0.4, color: "#22C55E", tags: ["medkit"], size: 1)

    // Arena 2: the warehouse — shelves, crates and a catwalk.
    let wx: Float = 150
    m.slab("Warehouse Floor", x: wx, y: 0, z: 0, w: 70, h: 0.2, d: 70, color: "#4B5563")
    m.walls(wx, 0, w: 70, d: 70, h: 9, y: 0.2, color: "#1F2937", name: "Warehouse Wall")
    for row in 0..<4 {
        for col in 0..<3 {
            m.slab("Shelf \(row)-\(col)", x: wx - 20 + Float(col) * 20, y: 0.2, z: -24 + Float(row) * 16, w: 10, h: 3, d: 1.6,
                   color: "#92400E")
        }
    }
    m.slab("Catwalk", x: wx, y: 4.5, z: 0, w: 60, h: 0.4, d: 3, color: "#9CA3AF")
    m.stairs(wx - 34, -3, y: 0.2, steps: 8, rise: 0.55, run: 0.8, width: 2.4, color: "#6B7280", name: "Catwalk Step")
    var w = Seeded("warehouse")
    for i in 0..<14 { m.crate(wx + w.range(-30, 30), w.range(-30, 30), y: 0.2, size: w.range(1.2, 2.2), name: "Crate \(i + 1)") }
    m.markers("Warehouse Spot", points: ring(10, radius: 28, cx: wx), y: 0.2, color: "#000000", visible: false, behavior: .none)
    m.markers("Warehouse Med", points: [(wx, 0), (wx + 25, 25), (wx - 25, -25)], y: 0.4, color: "#22C55E", tags: ["medkit"], size: 1)

    // Arena 3: rooftops — flat roofs at different heights joined by planks.
    let rx: Float = -150
    let roofs: [(Float, Float, Float)] = [(-20, -20, 6), (0, -20, 8), (20, -20, 6), (-20, 0, 7), (0, 0, 10), (20, 0, 7),
                                           (-20, 20, 6), (0, 20, 8), (20, 20, 6)]
    for (i, roof) in roofs.enumerated() {
        m.slab("Roof \(i + 1)", x: rx + roof.0, y: 0, z: roof.1, w: 14, h: roof.2, d: 14, color: i % 2 == 0 ? "#7C2D12" : "#44403C")
    }
    for i in 0..<3 {
        let z = Float(i - 1) * 20
        m.slab("Plank \(i + 1)a", x: rx - 10, y: 6.5, z: z, w: 8, h: 0.3, d: 2, color: "#D6D3D1")
        m.slab("Plank \(i + 1)b", x: rx + 10, y: 6.5, z: z, w: 8, h: 0.3, d: 2, color: "#D6D3D1")
    }
    for i in 0..<3 {
        let x = Float(i - 1) * 20
        m.slab("Bridge \(i + 1)a", x: rx + x, y: 6.5, z: -10, w: 2, h: 0.3, d: 8, color: "#D6D3D1")
        m.slab("Bridge \(i + 1)b", x: rx + x, y: 6.5, z: 10, w: 2, h: 0.3, d: 8, color: "#D6D3D1")
    }
    for (i, roof) in roofs.enumerated() where i % 2 == 1 {
        m.part("Roof Pad \(i + 1)", at: (rx + roof.0 + 6, 0.1, roof.1 + 6), size: (2, 0.2, 2), color: "#22C55E", material: .neon, behavior: .bounce)
    }
    // Spawn spots on top of each roof (a marker on the street would put you inside the building).
    for (i, roof) in roofs.enumerated() {
        m.part("Rooftops Spot \(i + 1)", at: (rx + roof.0 - 3, roof.2 + 0.1, roof.1 - 3), size: (1.2, 0.2, 1.2), color: "#000000",
               shape: .cylinder, material: .neon, solid: false, visible: false)
    }
    m.markers("Rooftops Med", points: [(rx, 0), (rx - 20, -20), (rx + 20, 20)], y: 0.4, color: "#22C55E", tags: ["medkit"], size: 1)
}

// MARK: 24 Warrior Brawl

func warriorBrawl(_ m: MapBuilder) {
    m.sky("#94A3B8", "#E2E8F0", light: 0.7, ground: "#4B5563")
    m.ground(120, 120, color: "#6B7280", name: "Courtyard")
    m.walls(0, 0, w: 120, d: 120, h: 10, color: "#374151", name: "Castle Wall")
    m.slab("Keep", x: 0, y: 0, z: -30, w: 24, h: 8, d: 16, color: "#4B5563")
    m.stairs(-16, -24, steps: 13, rise: 0.6, run: 0.8, width: 3, color: "#9CA3AF", name: "Keep Step")
    m.slab("Keep Roof", x: 0, y: 8, z: -30, w: 24, h: 0.4, d: 16, color: "#1F2937")
    var r = Seeded("brawl")
    for i in 0..<12 {
        m.slab("Barricade \(i + 1)", x: r.range(-50, 50), y: 0, z: r.range(-10, 50), w: r.range(3, 6), h: 1.4, d: 0.8,
               color: "#78350F", rotation: (0, r.range(0, 180), 0))
    }
    m.shop("Armory", x: 40, z: 40, w: 10, d: 8, color: "#7F1D1D", sign: "#FCA5A5")
    m.pad("Armory Counter", x: 40, z: 42, size: 2.5, color: "#EF4444", tags: ["armory"])
    m.shop("Supply Tent", x: -40, z: 40, w: 10, d: 8, color: "#14532D", sign: "#86EFAC")
    m.pad("Supply Counter", x: -40, z: 42, size: 2.5, color: "#22C55E", tags: ["supplies"])
    // A healing fountain in the middle of the courtyard: slow, and you are in the open.
    m.part("Fountain Basin", at: (0, 0.4, 20), size: (8, 0.8, 8), color: "#9CA3AF", shape: .cylinder)
    m.part("Fountain Water", at: (0, 0.85, 20), size: (7, 0.1, 7), color: "#38BDF8", shape: .cylinder, material: .glass,
           behavior: .trigger, tags: ["fountain"], solid: false, opacity: 0.7)
    m.pillar("Fountain Spire", x: 0, z: 20, y: 0.8, height: 3, radius: 0.5, color: "#E5E7EB")
    // The pit: a sunken ring for duels.
    m.slab("Pit Rim", x: 30, y: 0, z: -30, w: 18, h: 0.6, d: 18, color: "#57534E")
    m.slab("Pit Floor", x: 30, y: 0.6, z: -30, w: 14, h: 0.1, d: 14, color: "#A16207")
    m.spawnRing(0, 0, radius: 45, count: 10, color: "#F87171")
}

// MARK: 25 Ring Boxing League

func boxingRing(_ m: MapBuilder, name: String, x: Float, z: Float, size: Float = 12, rope: String = "#DC2626") {
    m.slab("\(name) Platform", x: x, y: 0, z: z, w: size + 2, h: 1.2, d: size + 2, color: "#1F2937")
    m.slab("\(name) Canvas", x: x, y: 1.2, z: z, w: size, h: 0.1, d: size, color: "#E5E7EB")
    for (dx, dz) in [(-1, -1), (1, -1), (-1, 1), (1, 1)] {
        m.pillar("\(name) Post", x: x + Float(dx) * size / 2, z: z + Float(dz) * size / 2, y: 1.2, height: 2, radius: 0.2, color: "#9CA3AF")
    }
    for h in [1.9, 2.5] as [Float] {
        m.walls(x, z, w: size, d: size, h: 0.08, y: 1.2 + h, color: rope, thickness: 0.08, name: "\(name) Rope")
    }
    m.part("\(name) Corner A", at: (x - size / 2 + 1.5, 1.4, z - size / 2 + 1.5), size: (1, 0.2, 1), color: "#EF4444", shape: .cylinder,
           visible: false)
    m.part("\(name) Corner B", at: (x + size / 2 - 1.5, 1.4, z + size / 2 - 1.5), size: (1, 0.2, 1), color: "#3B82F6", shape: .cylinder,
           visible: false)
}

func ringBoxing(_ m: MapBuilder) {
    m.indoor()
    m.sky("#111827", "#1F2937", light: 0.65, showGround: false)
    m.ground(90, 80, color: "#374151", name: "Gym Floor")
    m.walls(0, 0, w: 90, d: 80, h: 10, color: "#1F2937", name: "Gym Wall")
    // Two rings, so two bouts can run at once.
    boxingRing(m, name: "Ring", x: -14, z: 0, size: 12)
    boxingRing(m, name: "Ring2", x: 14, z: 0, size: 12, rope: "#2563EB")
    for x: Float in [-14, 14] {
        m.part("Ring Light", at: (x, 8, 0), size: (10, 0.3, 10), color: "#FFFFFF", material: .neon, solid: false)
    }
    for i in 0..<10 {
        m.slab("Bench \(i + 1)", x: -30 + Float(i % 5) * 15, y: 0, z: i < 5 ? -30 : 30, w: 10, h: 0.8, d: 2, color: "#7C2D12")
    }
    m.spawnRing(0, 22, radius: 6, count: 8, color: "#FBBF24")
    m.pad("Queue Pad", x: 0, z: 12, size: 4, color: "#22C55E", tags: ["queue"])
    m.pad("Career Door", x: -8, z: 30, size: 3, color: "#F59E0B", tags: ["career"])
    m.pad("Bet Board", x: 8, z: 30, size: 3, color: "#A855F7", tags: ["bets"])
    // The gym: heavy bags (power), speed bags (speed), the rope (stamina), the chin trainer.
    for i in 0..<4 {
        m.part("Punching Bag \(i + 1)", at: (-38 + Float(i) * 4, 2, -18), size: (1, 2.4, 1), color: "#B91C1C", shape: .cylinder,
               behavior: .trigger, tags: ["bag", "power"])
    }
    for i in 0..<3 {
        m.part("Speed Bag \(i + 1)", at: (38 - Float(i) * 4, 2.2, -18), size: (0.6, 0.8, 0.6), color: "#F59E0B", shape: .sphere,
               behavior: .trigger, tags: ["bag", "speed"])
    }
    m.pad("Jump Rope", x: -34, z: 18, size: 3, color: "#38BDF8", tags: ["bag", "stamina"])
    m.pad("Chin Trainer", x: 34, z: 18, size: 3, color: "#64748B", tags: ["bag", "chin"])
}

// MARK: 26 Power Roulette

func powerRoulette(_ m: MapBuilder) {
    m.sky("#831843", "#F9A8D4", light: 0.75, ground: "#4A044E", showGround: false)
    m.part("Arena", at: (0, -1, 0), size: (70, 2, 70), color: "#701A75", shape: .cylinder, material: .matte)
    // A roulette-wheel floor.
    let colors = ["#EF4444", "#F59E0B", "#22C55E", "#3B82F6", "#A855F7", "#EC4899"]
    for i in 0..<12 {
        let a = Float(i) / 12 * 360
        m.part("Wheel \(i + 1)", at: (cos(a * .pi / 180) * 16, 0.02, sin(a * .pi / 180) * 16), size: (10, 0.04, 6),
               color: colors[i % 6], material: .neon, solid: false, rotation: (0, -a, 0))
    }
    m.part("Wheel Center", at: (0, 0.3, 0), size: (8, 0.6, 8), color: "#FDE047", shape: .cylinder, material: .metal)
    m.pad("Jackpot Pad", x: 0, z: 0, y: 0.6, size: 3, color: "#F43F5E", tags: ["jackpot"])
    m.pad("Power Index", x: 0, z: -32, size: 3, color: "#22D3EE", tags: ["index_board"])
    m.pad("Ticket Booth", x: 0, z: 32, size: 3, color: "#A855F7", tags: ["ticket_booth"])
    m.spawnRing(0, 0, radius: 24, count: 12, color: "#F0ABFC")
    var r = Seeded("roulette")
    for i in 0..<10 {
        let a = r.range(0, 2 * .pi), d = r.range(8, 30)
        m.slab("Block \(i + 1)", x: cos(a) * d, y: 0, z: sin(a) * d, w: 3, h: r.range(1, 4), d: 3, color: "#F5D0FE")
    }
}

// MARK: 27 Armed Racers

func armedRacers(_ m: MapBuilder) {
    m.day(ground: "#4D7C0F")
    m.ground(300, 560, color: "#65A30D")
    // Track 1, the green oval: a loop of straights and checkpoints.
    racingTrack(m, prefix: "", cz: 0, points: [(-90, -60), (0, -75), (90, -60), (110, 0), (90, 60), (0, 75), (-90, 60), (-110, 0)],
                road: "#34353B")
    m.part("Start Line", at: (-110, 0.06, 0), size: (14, 0.04, 2), color: "#FFFFFF", material: .neon, solid: false)
    for i in 0..<8 {
        m.spawn(-114 + Float(i % 4) * 2.5, -6 - Float(i / 4) * 4, name: "Grid \(i + 1)", color: "#F97316")
    }
    m.slab("Grandstand", x: -135, y: 0, z: 0, w: 8, h: 4, d: 40, color: "#9CA3AF")
    m.pad("Garage", x: -128, z: 26, size: 3.4, color: "#F59E0B", tags: ["garage"])
    m.pad("Vote Oval", x: -128, z: -24, size: 3, color: "#22C55E", tags: ["vote_track", "oval"])
    m.pad("Vote Canyon", x: -128, z: -30, size: 3, color: "#C2410C", tags: ["vote_track", "canyon"])

    // Track 2, the canyon: sandier, tighter, with two ramps over gaps.
    let cz: Float = 280
    m.slab("Canyon Floor", x: 0, y: -0.3, z: cz, w: 280, h: 0.3, d: 200, color: "#D6B97A")
    let canyon: [(Float, Float)] = [(-80, -50), (0, -60), (60, -20), (100, 40), (40, 70), (-30, 40), (-60, 70), (-110, 10)]
    racingTrack(m, prefix: "2", cz: cz, points: canyon, road: "#7C2D12")
    for (i, ramp) in [(30, -40), (-45, 55)].enumerated() {
        m.part("Ramp \(i + 1)", at: (Float(ramp.0), 0.8, cz + Float(ramp.1)), size: (12, 0.4, 6), color: "#F59E0B", rotation: (0, 0, 12))
        m.part("Ramp Boost \(i + 1)", at: (Float(ramp.0), 1.2, cz + Float(ramp.1)), size: (4, 0.1, 4), color: "#F97316",
               material: .neon, behavior: .trigger, tags: ["boostpad"], solid: false)
    }
    for i in 0..<8 {
        m.part("Grid2 \(i + 1)", at: (-114 + Float(i % 4) * 2.5, 0.1, cz + 4 + Float(i / 4) * 4), size: (2, 0.2, 2),
               color: "#F97316", shape: .cylinder, material: .neon, solid: false)
    }
    for i in 0..<6 {
        m.part("Mesa \(i + 1)", at: (Float(-120 + i * 48), 6, cz + (i % 2 == 0 ? -95 : 95)), size: (20, 12, 16), color: "#B45309")
    }
}

/// One racing loop: road straights between corners, a see-through checkpoint
/// ring at each corner ("CP<prefix> n"), item boxes and coins on the straights.
func racingTrack(_ m: MapBuilder, prefix: String, cz: Float, points raw: [(Float, Float)], road: String) {
    let points = raw.map { ($0.0, $0.1 + cz) }
    for i in 0..<points.count {
        let a = points[i], b = points[(i + 1) % points.count]
        m.road(from: a, to: b, width: 14, name: "Track\(prefix) \(i + 1)")
        m.part("Corner\(prefix) \(i + 1)", at: (a.0, 0.02, a.1), size: (14, 0.04, 14), color: road, shape: .cylinder, material: .matte)
        m.part("CP\(prefix) \(i + 1)", at: (a.0, 2, a.1), size: (14, 4, 14), color: "#FFFFFF", shape: .cylinder, behavior: .trigger,
               tags: ["cp", "track\(prefix.isEmpty ? "1" : prefix)"], solid: false, visible: true, opacity: 0.08)
        for k in 0..<3 {
            let t = Float(k + 1) / 4
            m.part("Item Box", at: (a.0 + (b.0 - a.0) * t + Float(k - 1) * 3, 1, a.1 + (b.1 - a.1) * t), size: (1.2, 1.2, 1.2),
                   color: "#A855F7", material: .neon, behavior: .trigger, tags: ["itembox"], solid: false, rotation: (45, 45, 0))
        }
        for k in 0..<2 {
            let t = Float(k) * 0.3 + 0.35
            m.part("Track Coin", at: (a.0 + (b.0 - a.0) * t - 4, 0.8, a.1 + (b.1 - a.1) * t), size: (0.8, 0.8, 0.15),
                   color: "#FACC15", shape: .cylinder, material: .neon, behavior: .trigger, tags: ["coin"], solid: false, rotation: (90, 0, 0))
        }
    }
}

// MARK: 28 Blade & Revolver

func bladeRevolver(_ m: MapBuilder) {
    m.dusk(ground: "#3F3F46")
    m.ground(90, 90, color: "#52525B", name: "Plaza")
    m.walls(0, 0, w: 90, d: 90, h: 6, color: "#27272A", name: "Boundary")
    var r = Seeded("kat")
    for i in 0..<20 {
        m.slab("Pillar \(i + 1)", x: r.range(-40, 40), y: 0, z: r.range(-40, 40), w: 2, h: r.range(2, 5), d: 2,
               color: r.pick(["#71717A", "#52525B", "#A1A1AA"]))
    }
    m.slab("Center Hall", x: 0, y: 0, z: 0, w: 18, h: 0.4, d: 18, color: "#3F3F46")
    // Four wall pieces with a doorway in the middle of each side.
    for side: Float in [-1, 1] {
        for half: Float in [-1, 1] {
            m.slab("Hall Wall", x: half * 5.5, y: 0.4, z: side * 9, w: 7, h: 4, d: 0.6, color: "#18181B")
            m.slab("Hall Wall", x: side * 9, y: 0.4, z: half * 5.5, w: 0.6, h: 4, d: 7, color: "#18181B")
        }
    }
    m.slab("Hall Roof", x: 0, y: 4.4, z: 0, w: 18.6, h: 0.3, d: 18.6, color: "#27272A")
    m.stairs(-16.1, -6, steps: 8, rise: 0.58, run: 0.8, width: 2, color: "#71717A", name: "Roof Step")
    m.pad("Skin Crate", x: 38, z: 38, size: 3, color: "#F59E0B", tags: ["crate"])
    m.pad("Mode Board", x: -38, z: 38, size: 3, color: "#8B5CF6", tags: ["mode_board"])
    m.spawnRing(0, 0, radius: 36, count: 12, color: "#E11D48")
}

// MARK: 29 Last Squad vs Horde

func lastSquad(_ m: MapBuilder) {
    m.sky("#3F3F46", "#A1A1AA", light: 0.5, ground: "#3F3F46")
    m.ground(160, 160, color: "#52525B", name: "Ruined City")
    var r = Seeded("horde")
    for i in 0..<14 {
        let x = r.range(-65, 65), z = r.range(-65, 65)
        m.slab("Ruin \(i + 1)", x: x, y: 0, z: z, w: r.range(6, 12), h: r.range(3, 9), d: r.range(6, 12), color: r.pick(["#57534E", "#44403C", "#78716C"]))
    }
    for i in 0..<10 {
        m.slab("Car Wreck \(i + 1)", x: r.range(-60, 60), y: 0, z: r.range(-60, 60), w: 2.2, h: 1.4, d: 4.2, color: r.pick(["#7F1D1D", "#1E3A8A", "#3F6212"]),
               rotation: (0, r.range(0, 180), 0))
    }
    m.slab("Safehouse", x: 0, y: 0, z: 0, w: 14, h: 0.3, d: 14, color: "#1F2937")
    m.spawnRing(0, 0, y: 0.3, radius: 4, count: 8, color: "#60A5FA")
    m.slab("Helipad", x: 60, y: 0, z: 60, w: 14, h: 0.5, d: 14, color: "#374151")
    m.pad("Extraction", x: 60, z: 60, y: 0.5, size: 10, color: "#FACC15", tags: ["extract"])
    m.markers("Horde Spawn", points: ring(8, radius: 75), color: "#000000", visible: false, behavior: .none)
    m.markers("Supply", points: [(-30, 20), (30, -25), (-45, -40), (40, 30)], color: "#22C55E", tags: ["supply"], size: 2)
    m.pad("Class Board", x: 0, z: -9, y: 0.3, size: 2.6, color: "#60A5FA", tags: ["class_board"])
    m.markers("Drop Spot", points: [(-50, 50), (50, -50), (-55, 0), (0, 55), (20, -55)], color: "#000000", visible: false, behavior: .none)
}

// MARK: 30 Style Boxing

func styleBoxing(_ m: MapBuilder) {
    m.sky("#0F172A", "#1E40AF", light: 0.65, ground: "#0F172A", showGround: false)
    m.ground(90, 90, color: "#1E293B", name: "Arena Floor")
    boxingRing(m, name: "Ring A", x: -18, z: 0, size: 14, rope: "#F59E0B")
    boxingRing(m, name: "Ring B", x: 18, z: 0, size: 14, rope: "#22D3EE")
    m.walls(0, 0, w: 90, d: 90, h: 6, color: "#0F172A", name: "Arena Wall")
    m.spawnRing(0, 26, radius: 6, count: 10, color: "#38BDF8")
    m.pad("Duel Queue", x: -18, z: 14, size: 3, color: "#F59E0B", tags: ["duel_queue"])
    m.pad("King Entry", x: 18, z: 14, size: 3, color: "#22D3EE", tags: ["king_entry"])
    m.pad("Style Spinner", x: 0, z: 36, size: 3.4, color: "#A855F7", tags: ["spinner"])
    m.part("Spinner Wheel", at: (0, 3, 39), size: (5, 5, 0.4), color: "#7C3AED", shape: .cylinder, material: .neon, solid: false,
           rotation: (90, 0, 0))
}

// MARK: 31 Hero Academy Sim

func heroAcademy(_ m: MapBuilder) {
    m.day(ground: "#57534E")
    m.ground(200, 200, color: "#A8A29E", name: "City")
    m.road(from: (-100, 0), to: (100, 0), width: 10)
    m.road(from: (0, -100), to: (0, 100), width: 10)
    // The academy, its gear shop, quirk lottery and the side gate.
    m.house("Academy", x: -40, z: -40, w: 30, d: 20, h: 8, wall: "#F1F5F9", roof: "#1D4ED8", floor: "#CBD5E1", tags: ["academy"])
    m.spawnRing(-40, -40, radius: 6, count: 6, color: "#60A5FA")
    m.pillar("Hero Signal", x: -52, z: -44, y: 8, height: 8, radius: 0.6, color: "#E2E8F0")
    m.part("Hero Signal Lamp", at: (-52, 16.6, -44), size: (3, 1.2, 3), color: "#FDE047", shape: .sphere, material: .neon, solid: false)
    m.pad("Quirk Lottery", x: -50, z: -24, size: 3, color: "#A855F7", tags: ["gacha"])
    m.pad("Support Gear", x: -30, z: -24, size: 3, color: "#22D3EE", tags: ["gear"])
    m.pad("Side Gate", x: -40, z: -20, size: 2.4, color: "#F8FAFC", tags: ["side"])
    // The promotion exam hall, behind the academy.
    m.slab("Exam Floor", x: -75, y: 0, z: -72, w: 24, h: 0.2, d: 24, color: "#CBD5E1")
    m.walls(-75, -72, w: 24, d: 24, h: 4, color: "#1E3A8A", name: "Exam Wall")
    m.pad("Exam Gate", x: -58, z: -52, size: 3, color: "#FACC15", tags: ["exam"])
    m.markers("Exam Start", points: [(-75, -80)], y: 0.2, color: "#FDE047", visible: true, size: 2, behavior: .none)
    m.markers("Exam Bot", points: ring(8, radius: 8).map { ($0.0 - 75, $0.1 - 70) }, y: 0.2, color: "#000000", visible: false,
              behavior: .none)
    m.markers("Exam Exit", points: [(-58, -46)], color: "#000000", visible: false, behavior: .none)
    // The villains' hideout, black market and their own lottery.
    m.house("Hideout", x: 40, z: 40, w: 22, d: 16, h: 6, wall: "#1F2937", roof: "#7F1D1D", floor: "#111827", tags: ["hideout"])
    m.spawnRing(40, 40, radius: 5, count: 6, name: "Villain Spawn", color: "#F87171")
    m.pad("Dark Lottery", x: 32, z: 54, size: 3, color: "#A855F7", tags: ["gacha"])
    m.pad("Black Market", x: 48, z: 54, size: 3, color: "#22D3EE", tags: ["gear"])
    m.pad("Hideout Gate", x: 40, z: 58, size: 2.4, color: "#F8FAFC", tags: ["side"])
    // Places villains rob.
    m.shop("Bank", x: 40, z: -40, w: 16, d: 12, color: "#D4AF37", sign: "#FFFFFF")
    m.pad("Bank Vault", x: 40, z: -42, size: 3, color: "#FACC15", tags: ["vault"])
    m.shop("Jewelry", x: -40, z: 40, w: 12, d: 10, color: "#BE185D", sign: "#FBCFE8")
    m.pad("Jewelry Case", x: -40, z: 38, size: 3, color: "#F472B6", tags: ["vault"])
    m.shop("Museum", x: -72, z: 72, w: 16, d: 12, color: "#E7E5E4", sign: "#FDE68A")
    m.pad("Museum Gem", x: -72, z: 70, size: 3, color: "#34D399", tags: ["vault"])
    m.markers("Guard Post", points: [(40, -28), (-40, 50), (-72, 84)], color: "#000000", visible: false, behavior: .none)
    // The power plant: knock out all three generators for a city-wide blackout.
    m.slab("Power Plant", x: 72, y: 0, z: -72, w: 22, h: 0.3, d: 22, color: "#3F3F46")
    m.fence(from: (61, -83), to: (83, -83), color: "#71717A")
    m.fence(from: (83, -83), to: (83, -61), color: "#71717A")
    m.fence(from: (61, -83), to: (61, -61), color: "#71717A")
    for (i, p) in [(66, -77), (78, -77), (72, -66)].enumerated() {
        m.pillar("Generator \(i + 1)", x: Float(p.0), z: Float(p.1), y: 0.3, height: 4, radius: 1.3, color: "#FDE047", material: .neon,
                 tags: ["generator"])
    }
    // Where rescued people are taken.
    m.shop("Hospital", x: 22, z: -72, w: 14, d: 10, color: "#F8FAFC", sign: "#EF4444")
    m.markers("Safe Zone", points: [(22, -60), (22, 62)], color: "#22C55E", tags: ["safe"], visible: true, size: 5, behavior: .none)
    m.shop("Shelter", x: 22, z: 74, w: 14, d: 10, color: "#DCFCE7", sign: "#16A34A")
    // Towers, kept clear of everything above.
    let keepClear: [(Float, Float, Float)] = [(-40, -40, 22), (-75, -72, 18), (40, 46, 22), (40, -40, 14), (-40, 40, 12), (-72, 72, 14),
                                             (72, -72, 16), (22, -68, 14), (22, 68, 14)]
    var r = Seeded("hero")
    var towers = 0
    for _ in 0..<40 where towers < 14 {
        let x = r.range(-90, 90), z = r.range(-90, 90)
        let h = r.range(10, 30)
        let color = r.pick(["#64748B", "#94A3B8", "#475569"])
        if abs(x) < 12 || abs(z) < 12 { continue }
        if keepClear.contains(where: { abs($0.0 - x) < $0.2 && abs($0.1 - z) < $0.2 }) { continue }
        towers += 1
        m.slab("Tower \(towers)", x: x, y: 0, z: z, w: 10, h: h, d: 10, color: color)
    }
    m.markers("Incident", points: [(20, 20), (-20, 25), (25, -18), (-25, -18), (60, 0), (-60, 5)], color: "#000000", visible: false,
              behavior: .none)
}

// MARK: 32 Oni Blade

func oniBlade(_ m: MapBuilder) {
    m.sunset(ground: "#3F3F2E")
    m.ground(200, 200, color: "#5B6B3A", name: "Valley")
    // The village: six houses the oni attack at night, a well and the request board.
    for (i, p) in ring(6, radius: 18).enumerated() {
        m.house("Village House \(i + 1)", x: p.0, z: p.1, w: 7, d: 7, h: 3, wall: "#E7D8B8", roof: "#3F3F46", floor: "#8B6F47",
                door: false, tags: ["village", "house\(i + 1)"])
    }
    m.spawnRing(0, 0, radius: 5, count: 8, color: "#FCA5A5")
    m.pillar("Village Well", x: 0, z: 0, height: 0.9, radius: 1.1, color: "#78716C")
    m.pad("Request Board", x: 8, z: 0, size: 2.4, color: "#FDE68A", tags: ["board"])
    m.part("Board Sign", at: (9.6, 1.4, 0), size: (0.3, 1.6, 2.4), color: "#92400E")
    // The swordsmith's forge.
    m.shop("Swordsmith", x: 0, z: -34, w: 10, d: 8, color: "#57534E", sign: "#FDE68A")
    m.pad("Forge", x: 0, z: -32, size: 2.5, color: "#F97316", tags: ["forge"])
    // Training: straw dummies and the waterfall.
    m.slab("Training Yard", x: -40, y: 0, z: 0, w: 18, h: 0.2, d: 18, color: "#A8A29E")
    m.markers("Dummy", points: grid(3, 1, spacing: 5, cx: -40, cz: 0), color: "#000000", visible: false, behavior: .none)
    m.slab("Waterfall Cliff", x: -40, y: 0, z: -40, w: 12, h: 12, d: 3, color: "#57534E")
    m.part("Waterfall", at: (-40, 6, -38.2), size: (5, 12, 0.6), color: "#7DD3FC", material: .glass, solid: false, opacity: 0.6)
    m.slab("Waterfall Pool", x: -40, y: 0, z: -34, w: 10, h: 0.12, d: 6, color: "#38BDF8", opacity: 0.8)
    m.pad("Waterfall Stone", x: -40, z: -36, size: 3, color: "#BAE6FD", tags: ["waterfall"])
    // The dojo, where a sword school is chosen.
    m.house("Dojo", x: 40, z: 0, w: 12, d: 10, h: 4, wall: "#FEF3C7", roof: "#7F1D1D", floor: "#A16207", tags: ["dojo"])
    m.pad("School Mat", x: 40, z: -1, size: 3, color: "#F472B6", tags: ["school"])
    // The forest: oni come out of it at night; firewood, herbs and lost children by day.
    let keepClear: [(Float, Float, Float)] = [(0, 80, 16), (40, 0, 10), (-40, -38, 9), (-40, 0, 11), (0, -34, 8)]
    var r = Seeded("oni")
    var cedars = 0
    for _ in 0..<60 where cedars < 44 {
        let a = r.range(0, 2 * .pi), d = r.range(45, 95)
        let x = cos(a) * d, z = sin(a) * d
        let h = r.range(6, 10)
        if keepClear.contains(where: { hypot($0.0 - x, $0.1 - z) < $0.2 }) { continue }
        cedars += 1
        m.pine(x, z, height: h, leaves: "#14532D", name: "Cedar \(cedars)")
    }
    m.markers("Oni Spawn", points: ring(8, radius: 70), color: "#000000", visible: false, behavior: .none)
    m.markers("Wood Spot", points: ring(10, radius: 50, phase: 0.2), color: "#000000", visible: false, behavior: .none)
    m.markers("Herb Spot", points: ring(8, radius: 38, phase: 0.5), color: "#000000", visible: false, behavior: .none)
    m.markers("Lost Spot", points: [(60, 40), (-62, 35), (-55, -60), (58, -55)], color: "#000000", visible: false, behavior: .none)
    // The shrine where the oni lords appear.
    m.slab("Oni Shrine", x: 0, y: 0, z: 80, w: 24, h: 0.6, d: 24, color: "#450A0A")
    m.part("Shrine Gate", at: (0, 5, 67), size: (12, 1, 1), color: "#B91C1C")
    m.pillar("Gate Leg", x: -5, z: 67, height: 5, radius: 0.5, color: "#B91C1C")
    m.pillar("Gate Leg", x: 5, z: 67, height: 5, radius: 0.5, color: "#B91C1C")
    m.house("Shrine Hall", x: 0, z: 88, w: 10, d: 6, h: 4, y: 0.6, wall: "#7F1D1D", roof: "#1C1917", floor: "#292524", door: false,
            tags: ["shrine"])
    for (x, z) in [(-10, 72), (10, 72), (-10, 90), (10, 90)] {
        m.lamp(Float(x), Float(z), y: 0.6, glow: "#F87171", name: "Shrine Lantern")
    }
    m.markers("Boss Spot", points: [(0, 78)], y: 0.6, color: "#000000", visible: false, behavior: .none)
}
