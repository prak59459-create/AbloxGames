import Foundation

// 71–80: obstacle courses, minigames and social.

let miniGames: [Game] = [
    Game(number: 71, id: "disaster-island", title: "Disaster Island",
         summary: "島に次々とおそいかかる自然災害！洪水、いん石、たつまき、地震、酸性雨…生きのびるたびにポイント。",
         tags: ["survival", "disasters", "classic"], maxPlayers: 16, build: disasterIsland),
    Game(number: 72, id: "chaos-golf", title: "Chaos Golf",
         summary: "へんてこなコースを回るゴルフ対戦。パワーをえらんで打って、少ない打数でカップイン！全6ホール。",
         tags: ["golf", "sports", "party"], maxPlayers: 8, build: chaosGolf),
    Game(number: 73, id: "speed-worlds", title: "Speed Worlds",
         summary: "ものすごいスピードで走りぬけるアスレチック。5つの世界をワープでつなぐコースを、最速タイムでクリアしよう。",
         tags: ["obby", "speedrun", "fast"], maxPlayers: 12, build: speedWorlds),
    Game(number: 74, id: "island-drama-show", title: "Island Drama Show",
         summary: "サバイバル番組の出演者になって、毎回ちがうミニゲームで勝ちぬけ！最下位は脱落…最後に残るのはだれだ？",
         tags: ["minigames", "elimination", "party"], maxPlayers: 12, build: dramaShow),
    Game(number: 75, id: "prop-hide-and-seek", title: "Prop Hide & Seek",
         summary: "家具に変身してかくれんぼ！鬼は怪しいものを撃って探す。まちがえると鬼がダメージ。最後まで見つからなければ勝ち。",
         tags: ["hide-and-seek", "props", "party"], maxPlayers: 12, build: propHunt),
    Game(number: 76, id: "mega-minigames", title: "Mega Minigames",
         summary: "落ちる床、山の王、色あわせ、玉よけ…次々に出るミニゲームで勝ってポイントを集めよう。",
         tags: ["minigames", "party", "classic"], maxPlayers: 16, build: megaMinigames),
    Game(number: 77, id: "rhythm-battle", title: "Rhythm Battle",
         summary: "落ちてくるノーツに合わせてボタンを押す、対戦リズムゲーム。パーフェクトを決めて相手より高いスコアを！",
         tags: ["rhythm", "music", "1v1"], maxPlayers: 8, build: rhythmBattle),
    Game(number: 78, id: "last-survivor-games", title: "Last Survivor Games",
         summary: "「だるまさんがころんだ」とガラスの橋。動いたら失格、まちがえたら落ちる。最後まで生き残れ！",
         tags: ["survival", "minigames", "tense"], maxPlayers: 16, build: survivorGames),
    Game(number: 79, id: "shark-attack-bay", title: "Shark Attack Bay",
         summary: "巨大なサメと、ボートに乗った人間の海上バトル。人間はサメを撃退、サメは全員を海に引きずりこめ！",
         tags: ["pvp", "shark", "ocean"], maxPlayers: 12, build: sharkBay),
    Game(number: 80, id: "tip-jar-plaza", title: "Tip Jar Plaza",
         summary: "自分のお店ブースを出して、メッセージを書こう。遊んでたまったチップを、気に入ったブースにプレゼント！（ゲーム内のコインだけです）",
         tags: ["social", "chill", "booths"], maxPlayers: 16, build: tipJarPlaza),
]

// MARK: 71 Disaster Island

func disasterIsland(_ m: MapBuilder) {
    m.ocean()
    m.environment.killPlaneHeight = -20
    m.part("Island", at: (0, -1, 0), size: (120, 2, 120), color: "#65A30D", shape: .cylinder, material: .matte, tags: ["ground"])
    m.part("Beach", at: (0, -1.2, 0), size: (132, 2, 132), color: "#FDE68A", shape: .cylinder, material: .matte)
    m.slab("Lobby", x: 0, y: 30, z: -90, w: 20, h: 1, d: 20, color: "#E5E7EB")
    m.spawnRing(0, -90, y: 31, radius: 4, count: 8, name: "Lobby Spawn", color: "#FDE68A")
    m.spawnRing(0, 0, radius: 12, count: 8, name: "Island Spawn", color: "#22D3EE")
    // Buildings to shelter in.
    m.house("Cabin", x: -28, z: -20, w: 12, d: 10, h: 4, wall: "#D6B98C", roof: "#7C2D12", floor: "#A16207", door: false, tags: ["building"])
    m.house("Store", x: 28, z: -18, w: 14, d: 10, h: 4, wall: "#E5E7EB", roof: "#1E3A8A", floor: "#CBD5E1", door: false, tags: ["building"])
    m.slab("Tower", x: 20, y: 0, z: 30, w: 8, h: 14, d: 8, color: "#94A3B8", tags: ["building"])
    m.stairs(12, 30, steps: 23, rise: 0.6, run: 0.35, width: 3, color: "#CBD5E1", name: "Tower Step")
    m.house("Hut", x: -25, z: 28, w: 10, d: 8, h: 3.4, wall: "#A16207", roof: "#57534E", floor: "#78350F", door: false, tags: ["building"])
    for p in ring(10, radius: 44) { m.tree(p.0, p.1, height: 6) }
    m.part("Volcano Peak", at: (0, 0, 70), size: (1, 1, 1), color: "#000000", visible: false)
}

// MARK: 72 Chaos Golf

func chaosGolf(_ m: MapBuilder) {
    m.sky("#7DD3FC", "#F0F9FF", light: 0.85, showGround: false, fall: -20)
    m.spawnRing(0, -12, y: 0, radius: 3, count: 8, color: "#FFFFFF")
    let holes: [(Float, Float, String)] = [(0, 0, "#4ADE80"), (60, 0, "#22C55E"), (120, 0, "#84CC16"), (120, 60, "#16A34A"), (60, 60, "#65A30D"), (0, 60, "#15803D")]
    for (i, h) in holes.enumerated() {
        let n = i + 1
        m.slab("Hole \(n) Green", x: h.0, y: -1, z: h.1 + 10, w: 16, h: 1, d: 40, color: h.2, tags: ["green"])
        m.pad("Hole \(n) Tee", x: h.0, z: h.1 - 6, size: 2, color: "#FFFFFF", tags: ["tee"])
        m.part("Hole \(n) Cup", at: (h.0 + (i % 2 == 0 ? 3 : -3), 0.02, h.1 + 26), size: (1.2, 0.05, 1.2), color: "#111827", shape: .cylinder, solid: false)
        m.part("Hole \(n) Flag", at: (h.0 + (i % 2 == 0 ? 3 : -3), 1.6, h.1 + 26), size: (0.08, 3.2, 0.08), color: "#DC2626", shape: .cylinder, solid: false)
        // Chaos: bumpers and a moving wall.
        m.slab("Hole \(n) Bumper", x: h.0 + (i % 2 == 0 ? -3 : 3), y: 0, z: h.1 + 10, w: 3, h: 1, d: 1, color: "#F472B6")
        m.slab("Hole \(n) Wall", x: h.0, y: 0, z: h.1 + 18, w: 6, h: 1.2, d: 0.6, color: "#A855F7", tags: ["mover"])
    }
}

// MARK: 73 Speed Worlds

func speedWorlds(_ m: MapBuilder) {
    m.sky("#22D3EE", "#ECFEFF", light: 0.85, showGround: false, fall: -25)
    let worlds: [(String, String, String)] = [("Grass World", "#4ADE80", "#15803D"), ("Ice World", "#E0F2FE", "#7DD3FC"), ("Lava World", "#F97316", "#7F1D1D"),
                                             ("Space World", "#312E81", "#A78BFA"), ("Candy World", "#F9A8D4", "#DB2777")]
    var r = Seeded("speedworlds")
    var portals: [UUID] = []
    var starts: [UUID] = []
    for (i, w) in worlds.enumerated() {
        let baseZ = Float(i) * 400
        starts.append(m.slab("\(w.0) Start", x: 0, y: -1, z: baseZ, w: 16, h: 1, d: 16, color: w.1))
        var z = baseZ + 14
        for k in 0..<12 {
            let gap = r.range(3, 7)
            let len = r.range(10, 22)
            z += gap + len / 2
            let x = r.range(-6, 6)
            m.slab("\(w.0) Run \(k + 1)", x: x, y: -1 + Float(k % 3) * 0.6, z: z, w: r.range(3, 6), h: 1, d: len, color: k % 2 == 0 ? w.1 : w.2)
            if k == 5 { m.pad("\(w.0) Checkpoint", x: x, z: z, y: Float(k % 3) * 0.6, size: 3, color: "#4ADE80", tags: ["cp"]) }
            if k % 4 == 3 {
                m.part("\(w.0) Boost \(k + 1)", at: (x, 0.15 + Float(k % 3) * 0.6, z - len / 2 + 1), size: (3, 0.2, 2), color: "#FACC15",
                       material: .neon, behavior: .trigger, tags: ["boost"])
            }
            z += len / 2
        }
        m.slab("\(w.0) End", x: 0, y: -1, z: z + 6, w: 10, h: 1, d: 6, color: w.2)
        if i == worlds.count - 1 {
            m.pad("Finish", x: 0, z: z + 6, size: 4, color: "#FFFFFF", tags: ["finish"])
        } else {
            portals.append(m.part("\(w.0) Portal", at: (0, 1.5, z + 6), size: (4, 4, 0.6), color: "#A855F7", material: .neon,
                                  behavior: .teleport, tags: ["portal"], opacity: 0.8))
        }
    }
    for i in portals.indices { m.setTeleport(from: portals[i], to: starts[i + 1]) }
    m.spawnRing(0, 0, radius: 4, count: 8, color: "#FACC15")
}

// MARK: 74 Island Drama Show

func dramaShow(_ m: MapBuilder) {
    m.day(ground: "#65A30D")
    m.sky("#38BDF8", "#E0F2FE", light: 0.8, ground: "#1D4ED8")
    m.part("Camp Island", at: (0, -1, 0), size: (70, 2, 70), color: "#84CC16", shape: .cylinder, material: .matte)
    m.spawnRing(0, 0, radius: 8, count: 12, color: "#FACC15")
    m.slab("Stage", x: 0, y: 0, z: -24, w: 16, h: 1, d: 8, color: "#7C2D12")
    m.part("Campfire", at: (0, 0.5, 10), size: (2, 1, 2), color: "#F97316", shape: .cone, material: .neon)
    // Log run over the water.
    m.slab("Log Start", x: 60, y: -1, z: 0, w: 8, h: 1, d: 8, color: "#A16207")
    for i in 0..<10 {
        m.part("Log \(i + 1)", at: (60, -0.6, Float(i) * 4 + 6), size: (2.2, 0.6, 3), color: "#92400E", shape: .box, behavior: .disappear,
               gimmick: GimmickSettings(disappearDelay: 0.6, respawnDelay: 2.5))
    }
    m.slab("Log End", x: 60, y: -1, z: 48, w: 8, h: 1, d: 8, color: "#A16207")
    m.pad("Log Finish", x: 60, z: 48, size: 5, color: "#22C55E", tags: ["logfinish"])
    // A dodge arena.
    m.slab("Dodge Arena", x: -60, y: -1, z: 0, w: 30, h: 1, d: 30, color: "#E5E7EB")
}

// MARK: 75 Prop Hide & Seek

func propHunt(_ m: MapBuilder) {
    m.indoor()
    m.sky("#F5F5F4", "#E7E5E4", light: 0.8, showGround: false)
    m.ground(80, 70, color: "#D6D3D1", name: "House Floor")
    m.walls(0, 0, w: 80, d: 70, h: 7, color: "#A8A29E", name: "House Wall")
    for (x, z0, z1) in [(-15, -35, -8), (-15, 2, 35), (15, -35, -12), (15, -2, 35)] {
        m.slab("Room Wall", x: Float(x), y: 0, z: Float(z0 + z1) / 2, w: 0.5, h: 4, d: Float(z1 - z0), color: "#E7E5E4")
    }
    var r = Seeded("props")
    let props: [(String, V, String, BlockShape)] = [("Box", (1.4, 1.4, 1.4), "#A16207", .box), ("Barrel", (1.2, 1.6, 1.2), "#7C2D12", .cylinder),
                                                    ("Plant", (1, 1.8, 1), "#16A34A", .cone), ("Chair", (1, 1.2, 1), "#1E3A8A", .box),
                                                    ("Lamp", (0.6, 1.8, 0.6), "#FDE68A", .cylinder), ("Ball", (1, 1, 1), "#EF4444", .sphere)]
    for i in 0..<40 {
        let p = r.pick(props)
        m.part("\(p.0) \(i + 1)", at: (r.range(-36, 36), p.1.1 / 2, r.range(-31, 31)), size: p.1, color: p.2, shape: p.3, tags: ["decor"])
    }
    m.slab("Seeker Room", x: 0, y: 0, z: -40, w: 16, h: 0.2, d: 8, color: "#1F2937")
    m.part("Seeker Cage", at: (0, 2, -40), size: (1, 0.1, 1), color: "#000000", visible: false)
    m.spawnRing(0, 0, radius: 6, count: 10, color: "#FBBF24")
}

// MARK: 76 Mega Minigames

func megaMinigames(_ m: MapBuilder) {
    m.sky("#A855F7", "#F0ABFC", light: 0.8, showGround: false, fall: -20)
    m.slab("Lobby", x: 0, y: -1, z: -60, w: 30, h: 1, d: 20, color: "#F5F5F4")
    m.spawnRing(0, -60, radius: 6, count: 12, color: "#F472B6")
    // A 10x10 floor of tiles used by several games.
    let colors = ["#EF4444", "#3B82F6", "#22C55E", "#FACC15"]
    for gx in 0..<10 {
        for gz in 0..<10 {
            m.part("Tile \(gx)-\(gz)", at: (-18 + Float(gx) * 4, -0.5, -18 + Float(gz) * 4), size: (3.9, 1, 3.9),
                   color: colors[(gx + gz * 3) % 4], behavior: .trigger, tags: ["tile"])
        }
    }
    m.part("Hill", at: (0, 1, 0), size: (6, 2, 6), color: "#FDE047", shape: .cylinder, material: .neon, behavior: .trigger, tags: ["hill"], visible: false)
    m.part("Arena Center", at: (0, 1, 0), size: (1, 1, 1), color: "#000000", visible: false)
}

// MARK: 77 Rhythm Battle

func rhythmBattle(_ m: MapBuilder) {
    m.indoor()
    m.sky("#0F0A1F", "#3B0764", light: 0.7, showGround: false)
    m.ground(60, 50, color: "#1E1B4B", name: "Club Floor")
    m.slab("Stage", x: 0, y: 0, z: -10, w: 24, h: 1.2, d: 10, color: "#312E81")
    m.pad("Stage Left", x: -6, z: -10, y: 1.2, size: 3, color: "#EC4899", tags: ["stage", "left"])
    m.pad("Stage Right", x: 6, z: -10, y: 1.2, size: 3, color: "#22D3EE", tags: ["stage", "right"])
    for (i, p) in grid(6, 1, spacing: 4, cx: 0, cz: -15.5).enumerated() {
        m.part("Speaker \(i + 1)", at: (p.0, 2.5, p.1), size: (2, 3, 1), color: "#111827")
    }
    m.part("Stage Lights", at: (0, 7, -10), size: (20, 0.3, 2), color: "#F0ABFC", material: .neon, solid: false)
    m.spawnRing(0, 10, radius: 6, count: 8, color: "#A78BFA")
}

// MARK: 78 Last Survivor Games

func survivorGames(_ m: MapBuilder) {
    m.day(ground: "#D6D3D1")
    m.sky("#93C5FD", "#E0F2FE", light: 0.85, showGround: false, fall: -25)
    // Stop & Go field.
    m.slab("Field", x: 0, y: -1, z: 0, w: 60, h: 1, d: 120, color: "#E7D8B8")
    m.spawnRing(0, -52, radius: 8, count: 16, color: "#10B981")
    m.part("Finish Line", at: (0, 0.03, 52), size: (60, 0.05, 1), color: "#DC2626", material: .neon, solid: false)
    m.pad("Field Finish", x: 0, z: 56, size: 8, color: "#22C55E", tags: ["fieldfinish"], shape: .box)
    m.part("Doll", at: (0, 4, 60), size: (3, 8, 3), color: "#F97316", shape: .cylinder)
    m.part("Doll Head", at: (0, 9, 60), size: (3, 3, 3), color: "#FDE68A", shape: .sphere)
    // Glass bridge: pairs of panes, one of each breaks.
    m.slab("Bridge Start", x: 0, y: 9, z: 100, w: 10, h: 1, d: 8, color: "#6B7280")
    for i in 0..<10 {
        let z = 108 + Float(i) * 5
        m.part("Glass \(i + 1) L", at: (-2.2, 9.6, z), size: (3, 0.2, 3), color: "#BAE6FD", material: .glass, tags: ["glass"], opacity: 0.6)
        m.part("Glass \(i + 1) R", at: (2.2, 9.6, z), size: (3, 0.2, 3), color: "#BAE6FD", material: .glass, tags: ["glass"], opacity: 0.6)
    }
    m.slab("Bridge End", x: 0, y: 9, z: 160, w: 10, h: 1, d: 8, color: "#6B7280")
    m.pad("Bridge Finish", x: 0, z: 160, y: 10, size: 6, color: "#22C55E", tags: ["bridgefinish"])
    m.slab("Spectator Deck", x: 40, y: 12, z: 0, w: 14, h: 1, d: 14, color: "#1F2937")
}

// MARK: 79 Shark Attack Bay

func sharkBay(_ m: MapBuilder) {
    m.ocean()
    m.environment.killPlaneHeight = -40
    m.ground(260, 260, color: "#0C4A6E", name: "Seabed", y: -12)
    m.water(0, 0, w: 260, d: 260, y: 0, name: "Bay Water", color: "#0284C7", depth: 12, tags: ["sea"])
    m.slab("Dock", x: 0, y: -1, z: -70, w: 40, h: 1.6, d: 14, color: "#A16207")
    m.spawnRing(0, -70, y: 0.6, radius: 6, count: 10, color: "#FDE68A")
    // Boats to stand on.
    for (i, p) in ring(6, radius: 30).enumerated() {
        m.slab("Boat \(i + 1)", x: p.0, y: -0.4, z: p.1, w: 5, h: 0.8, d: 9, color: ["#EF4444", "#3B82F6", "#FACC15", "#22C55E", "#F97316", "#A855F7"][i],
               tags: ["boat"])
        m.slab("Boat \(i + 1) Rail", x: p.0, y: 0.4, z: p.1 + 4.3, w: 5, h: 0.8, d: 0.3, color: "#FFFFFF")
    }
    m.part("Shark Den", at: (0, -6, 60), size: (1, 1, 1), color: "#000000", visible: false)
    m.part("Lighthouse", at: (60, 6, -60), size: (4, 14, 4), color: "#FFFFFF", shape: .cylinder)
}

// MARK: 80 Tip Jar Plaza

func tipJarPlaza(_ m: MapBuilder) {
    m.sunset(ground: "#A3A3A3")
    m.ground(120, 120, color: "#D6D3D1", name: "Plaza")
    m.part("Fountain", at: (0, 0.5, 0), size: (8, 1, 8), color: "#BFDBFE", shape: .cylinder, material: .metal)
    m.water(0, 0, w: 7, d: 7, y: 1.05, name: "Fountain Water", tags: ["wish"])
    m.spawnRing(0, 0, radius: 8, count: 10, color: "#FDE68A")
    for (i, p) in ring(12, radius: 28).enumerated() {
        let n = i + 1
        m.slab("Booth \(n) Counter", x: p.0, y: 0, z: p.1, w: 4, h: 1.1, d: 2, color: "#78350F")
        m.part("Booth \(n) Sign", at: (p.0, 3, p.1), size: (4, 1.2, 0.3), color: "#FFFFFF", material: .neon)
        m.pillar("Booth \(n) Pole", x: p.0 - 1.8, z: p.1, height: 3, radius: 0.1, color: "#57534E")
        m.pillar("Booth \(n) Pole", x: p.0 + 1.8, z: p.1, height: 3, radius: 0.1, color: "#57534E")
        m.pad("Booth \(n)", x: p.0 * 0.9, z: p.1 * 0.9, size: 2.2, color: "#22C55E", tags: ["booth"])
    }
    for i in 0..<8 { m.lamp(-42 + Float(i) * 12, 44) }
}
