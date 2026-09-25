import Foundation

// 71–80: obstacle courses, minigames and social.

let miniGames: [Game] = [
    Game(number: 71, id: "disaster-island", title: "Disaster Island",
         summary: "15種類の自然災害（洪水・津波・いん石・火山・たつまき・地震・酸性雨・吹雪・雷・砂嵐・火事・巨人・UFO・ブラックホール・熱波）を島で生きのびろ。警報のヒント、ダブル災害、くずれる建物、装備のお店！",
         tags: ["survival", "disasters", "classic"], maxPlayers: 16, build: disasterIsland),
    Game(number: 72, id: "chaos-golf", title: "Chaos Golf",
         summary: "ボールがほんとうにころがるミニゴルフ大会。坂・砂・氷・加速床・水・ワープ・風車の9ホールを、みんな同時にプレイ。アイテム（スーパー・マグネット・ゴースト・アイス・たつまき・スワップ）でカオスに！",
         tags: ["golf", "sports", "party"], maxPlayers: 8, build: chaosGolf),
    Game(number: 73, id: "speed-worlds", title: "Speed Worlds",
         summary: "8つのワールド（草原・氷・溶岩・宇宙・おかし・砂漠・雲・ネオン）を超スピードで走るスピードラン。金銀銅メダル、自分のベスト走りの👻ゴースト、レース大会、シューズ・ブーツ・グライダー！",
         tags: ["obby", "speedrun", "fast"], maxPlayers: 12, build: speedWorlds),
    Game(number: 74, id: "island-drama-show", title: "Island Drama Show",
         summary: "無人島のサバイバル番組！ 丸太わたり・玉よけ・早押しクイズ・山の王さま・タワーのぼり・コイン集め・色の床・氷のゆか割り・記憶の道。1位はイミュニティ、下位2人はみんなの投票で…最後の1人がチャンピオン！",
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
    m.part("Cover Focus", at: (0, 4, 4), size: (118, 1, 1), color: "#000000", tags: ["yaw=215"], solid: false, visible: false)
    m.part("Island", at: (0, -1, 0), size: (120, 2, 120), color: "#65A30D", shape: .cylinder, material: .matte, tags: ["ground"])
    m.part("Beach", at: (0, -1.2, 0), size: (132, 2, 132), color: "#FDE68A", shape: .cylinder, material: .matte)
    // The lobby floats above the sea, with the gear shop.
    m.slab("Lobby", x: 0, y: 30, z: -95, w: 26, h: 1, d: 22, color: "#E5E7EB")
    m.walls(0, -95, w: 26, d: 22, h: 1.2, y: 31, color: "#94A3B8", name: "Lobby Rail")
    m.spawnRing(0, -95, y: 31, radius: 4, count: 8, name: "Lobby Spawn", color: "#FDE68A")
    m.pad("Shop Pad", x: 8, z: -88, y: 31, size: 2.6, color: "#0EA5E9", tags: ["shop"])
    m.slab("Shop Counter", x: 8, y: 31, z: -86.4, w: 4, h: 1.1, d: 0.8, color: "#0369A1")
    m.part("Lobby Board", at: (-8, 33.5, -105.6), size: (8, 3, 0.2), color: "#1E3A8A", material: .neon, solid: false)
    m.spawnRing(0, 0, radius: 12, count: 8, name: "Island Spawn", color: "#22D3EE")
    // Buildings to shelter in (and to crumble or burn).
    m.house("Cabin", x: -28, z: -20, w: 12, d: 10, h: 4, wall: "#D6B98C", roof: "#7C2D12", floor: "#A16207", door: false, tags: ["building"])
    m.house("Store", x: 28, z: -18, w: 14, d: 10, h: 4, wall: "#E5E7EB", roof: "#1E3A8A", floor: "#CBD5E1", door: false, tags: ["building"])
    m.house("Hut", x: -25, z: 28, w: 10, d: 8, h: 3.4, wall: "#A16207", roof: "#57534E", floor: "#78350F", door: false, tags: ["building"])
    m.house("Bunker", x: 6, z: -40, w: 10, d: 8, h: 2.6, wall: "#57534E", roof: "#44403C", floor: "#292524", door: false, tags: ["building"])
    // The lookout tower with a staircase.
    m.slab("Tower", x: 20, y: 0, z: 30, w: 8, h: 14, d: 8, color: "#94A3B8", tags: ["building"])
    m.stairs(12, 30, steps: 23, rise: 0.6, run: 0.35, width: 3, color: "#CBD5E1", name: "Tower Step")
    m.slab("Tower Top Rail", x: 20, y: 14, z: 30, w: 8, h: 0.8, d: 0.4, color: "#64748B", tags: ["building"])
    // The lighthouse: tall, with a spiral of steps.
    let lh: (Float, Float) = (-44, -8)
    m.pillar("Lighthouse", x: lh.0, z: lh.1, height: 20, radius: 3, color: "#F8FAFC", tags: ["building"])
    for k in 0..<3 { m.part("Lighthouse Stripe", at: (lh.0, 3 + Float(k) * 6, lh.1), size: (6.1, 1.2, 6.1), color: "#DC2626", shape: .cylinder, solid: false) }
    for k in 0..<26 {
        let a = Float(k) * 0.55
        m.slab("Lighthouse Step", x: lh.0 + cos(a) * 4.2, y: Float(k) * 0.78, z: lh.1 + sin(a) * 4.2, w: 1.8, h: 0.35, d: 1.8, color: "#CBD5E1")
    }
    m.slab("Lighthouse Top", x: lh.0, y: 20, z: lh.1, w: 8, h: 0.5, d: 8, color: "#475569", tags: ["building"])
    m.part("Lighthouse Lamp", at: (lh.0, 21.6, lh.1), size: (2.4, 2.4, 2.4), color: "#FDE047", shape: .sphere, material: .neon, solid: false)
    // The treehouse on stilts.
    for q in [(-6, 38), (2, 38), (-6, 44), (2, 44)] as [(Float, Float)] {
        m.part("Treehouse Leg", at: (q.0, 3.5, q.1), size: (0.8, 7, 0.8), color: "#78350F", shape: .cylinder, tags: ["building"])
    }
    m.slab("Treehouse Floor", x: -2, y: 7, z: 41, w: 10, h: 0.5, d: 8, color: "#A16207", tags: ["building"])
    m.slab("Treehouse Roof", x: -2, y: 10, z: 41, w: 11, h: 0.5, d: 9, color: "#166534", tags: ["building"])
    m.stairs(-11, 41, steps: 14, rise: 0.5, run: 0.6, width: 2.4, color: "#92400E", name: "Treehouse Step")
    // The windmill.
    m.pillar("Windmill", x: 42, z: 6, height: 12, radius: 2.6, color: "#FEF3C7", tags: ["building"])
    m.part("Windmill Cap", at: (42, 13.2, 6), size: (6, 2.8, 6), color: "#B91C1C", shape: .cone, tags: ["building"])
    for a: Float in [0, 90] {
        m.part("Windmill Blade", at: (42, 10, 3.2), size: (1, 11, 0.2), color: "#F8FAFC", solid: false, rotation: (0, 0, a + 45))
    }
    // The volcano on the north shore, the lava basin at its foot, and the pond.
    m.part("Volcano", at: (32, 8, 50), size: (26, 16, 22), color: "#57534E", shape: .cone, material: .matte)
    m.part("Volcano Crater", at: (32, 15.6, 50), size: (5, 1, 4.4), color: "#F97316", shape: .cylinder, material: .neon, solid: false)
    m.part("Volcano Peak", at: (32, 17, 50), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    m.part("Lava Basin", at: (18, 0, 44), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    m.water(-30, -42, w: 12, d: 10, y: 0.06, name: "Pond")
    for q in [(-35, -38), (-25, -46), (-24, -37)] as [(Float, Float)] { m.rock(q.0, q.1, size: 1.4) }
    // A grassy hill in the middle-west.
    m.part("Hill", at: (-20, 0, 0), size: (22, 8, 20), color: "#4D7C0F", shape: .sphere, material: .matte)
    for p in ring(12, radius: 50, phase: 0.3) { m.tree(p.0, p.1, height: 6) }
}

// MARK: 72 Chaos Golf

/// A mini-golf green for Chaos Golf: the green itself, a rim of walls the ball bounces off (tag h<n>wall), the tee and the cup.
/// The script reads every feature back by its tag, so the ball physics matches what is drawn.
func golfHole(_ m: MapBuilder, n: Int, ox: Float, oz: Float, color: String, cupX: Float, features: (Float, Float, String) -> Void) {
    let w: Float = 16, d: Float = 36
    m.slab("Hole \(n) Green", x: ox, y: -1, z: oz, w: w, h: 1, d: d, color: color, tags: ["green", "h\(n)green"])
    m.slab("Hole \(n) Base", x: ox, y: -3, z: oz, w: w + 1.2, h: 2, d: d + 1.2, color: "#78350F")
    for sx: Float in [-1, 1] {
        m.slab("Rail", x: ox + sx * (w / 2 + 0.3), y: 0, z: oz, w: 0.6, h: 0.6, d: d + 1.2, color: "#F8FAFC", tags: ["h\(n)wall"])
    }
    for sz: Float in [-1, 1] {
        m.slab("Rail", x: ox, y: 0, z: oz + sz * (d / 2 + 0.3), w: w, h: 0.6, d: 0.6, color: "#F8FAFC", tags: ["h\(n)wall"])
    }
    m.part("Hole \(n) Tee", at: (ox, 0.03, oz - 14), size: (2, 0.06, 2), color: "#FFFFFF", material: .matte, solid: false)
    m.part("Hole \(n) Cup", at: (ox + cupX, 0.02, oz + 14), size: (1, 0.05, 1), color: "#111827", shape: .cylinder, solid: false)
    m.part("Hole \(n) Flag Pole", at: (ox + cupX, 1.6, oz + 14), size: (0.08, 3.2, 0.08), color: "#F8FAFC", shape: .cylinder, solid: false)
    m.part("Hole \(n) Flag", at: (ox + cupX + 0.5, 2.8, oz + 14), size: (1, 0.6, 0.05), color: "#DC2626", solid: false)
    m.part("Hole \(n) Number", at: (ox - 6.5, 2.2, oz - 17.8), size: (2.2, 1.6, 0.2), color: color, material: .neon, solid: false)
    features(ox, oz, "h\(n)")
}

func chaosGolf(_ m: MapBuilder) {
    m.sky("#7DD3FC", "#F0F9FF", light: 0.85, showGround: false, fall: -20)
    m.part("Cover Focus", at: (22, 0, 22), size: (80, 1, 1), color: "#000000", tags: ["yaw=205"], solid: false, visible: false)
    // The clubhouse, where everyone waits between rounds.
    m.slab("Clubhouse Lawn", x: 0, y: -1, z: -40, w: 30, h: 1, d: 20, color: "#86EFAC")
    m.spawnRing(0, -40, radius: 4, count: 8, color: "#FFFFFF")
    m.house("Clubhouse", x: -10, z: -44, w: 8, d: 6, wall: "#FEF3C7", roof: "#15803D", floor: "#D6D3D1")
    m.part("Scoreboard", at: (8, 3, -49.6), size: (10, 4, 0.3), color: "#14532D", material: .neon, solid: false)
    let wall = "#F8FAFC"
    // 1: a straight hole with a bumper in the middle.
    golfHole(m, n: 1, ox: 0, oz: 0, color: "#4ADE80", cupX: 0) { ox, oz, h in
        m.slab("Bumper", x: ox, y: 0, z: oz + 2, w: 3, h: 0.6, d: 1, color: "#F472B6", tags: ["\(h)wall"])
        m.part("\(h) Item 1", at: (ox - 4, 0.4, oz + 6), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)
    }
    // 2: a dogleg: a long wall makes you go round.
    golfHole(m, n: 2, ox: 24, oz: 0, color: "#22C55E", cupX: 5) { ox, oz, h in
        m.slab("Dogleg", x: ox + 2, y: 0, z: oz + 2, w: 12, h: 0.6, d: 0.6, color: wall, tags: ["\(h)wall"])
        m.slab("Dogleg", x: ox - 2, y: 0, z: oz + 9, w: 12, h: 0.6, d: 0.6, color: wall, tags: ["\(h)wall"])
        m.part("\(h) Item 1", at: (ox - 5, 0.4, oz + 5), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)
    }
    // 3: a slope that tips the ball toward the water.
    golfHole(m, n: 3, ox: 48, oz: 0, color: "#84CC16", cupX: -4) { ox, oz, h in
        m.part("Slope +x", at: (ox - 1, 0.01, oz), size: (10, 0.02, 12), color: "#65A30D", tags: ["\(h)slope"], solid: false)
        m.part("Water", at: (ox + 6, 0.02, oz), size: (4, 0.04, 12), color: "#38BDF8", material: .glass, tags: ["\(h)water"], solid: false)
        m.part("\(h) Item 1", at: (ox - 5, 0.4, oz - 8), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)
    }
    // 4: the windmill: two blades sweep across the middle.
    golfHole(m, n: 4, ox: 48, oz: 48, color: "#16A34A", cupX: 0) { ox, oz, h in
        m.slab("Windmill Blade", x: ox - 4, y: 0, z: oz, w: 5, h: 0.6, d: 0.8, color: "#DC2626", tags: ["\(h)mover"])
        m.slab("Windmill Blade", x: ox + 4, y: 0, z: oz + 6, w: 5, h: 0.6, d: 0.8, color: "#DC2626", tags: ["\(h)mover"])
        m.part("Windmill Tower", at: (ox + 7, 3, oz + 3), size: (1.4, 6, 1.4), color: "#FEF3C7", shape: .cylinder, solid: false)
        m.part("\(h) Item 1", at: (ox + 4, 0.4, oz - 8), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)
    }
    // 5: sand traps around an island green.
    golfHole(m, n: 5, ox: 24, oz: 48, color: "#65A30D", cupX: 3) { ox, oz, h in
        m.part("Sand", at: (ox - 3, 0.02, oz + 4), size: (8, 0.04, 6), color: "#FDE68A", tags: ["\(h)sand"], solid: false)
        m.part("Sand", at: (ox + 4, 0.02, oz + 9), size: (6, 0.04, 3), color: "#FDE68A", tags: ["\(h)sand"], solid: false)
        m.part("Water", at: (ox, 0.02, oz - 4), size: (16, 0.04, 3), color: "#38BDF8", material: .glass, tags: ["\(h)water"], solid: false)
        m.part("\(h) Item 1", at: (ox + 5, 0.4, oz), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)
    }
    // 6: boost pads down the middle.
    golfHole(m, n: 6, ox: 0, oz: 48, color: "#4D7C0F", cupX: -3) { ox, oz, h in
        m.part("Boost +z", at: (ox, 0.03, oz - 6), size: (3, 0.06, 2), color: "#22D3EE", material: .neon, tags: ["\(h)boost"], solid: false)
        m.slab("Blocker", x: ox + 3, y: 0, z: oz + 6, w: 8, h: 0.6, d: 0.6, color: wall, tags: ["\(h)wall"])
        m.part("\(h) Item 1", at: (ox - 5, 0.4, oz), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)
    }
    // 7: portals past a wall of blocks.
    golfHole(m, n: 7, ox: 0, oz: 96, color: "#A3E635", cupX: 0) { ox, oz, h in
        m.slab("Portal Wall", x: ox, y: 0, z: oz, w: 16, h: 0.6, d: 1, color: "#7C3AED", tags: ["\(h)wall"])
        m.part("Hole 7 Portal A", at: (ox - 4, 0.03, oz - 8), size: (2, 0.06, 2), color: "#A855F7", shape: .cylinder, material: .neon, tags: ["\(h)portal"], solid: false)
        m.part("Hole 7 Portal B", at: (ox + 3, 0.03, oz + 6), size: (2, 0.06, 2), color: "#F0ABFC", shape: .cylinder, material: .neon, tags: ["\(h)portal"], solid: false)
        m.slab("Side Gap Block", x: ox + 7, y: 0, z: oz - 1.5, w: 2, h: 0.6, d: 2, color: "#7C3AED", tags: ["\(h)wall"])
    }
    // 8: an icy zig-zag.
    golfHole(m, n: 8, ox: 24, oz: 96, color: "#BAE6FD", cupX: 5) { ox, oz, h in
        m.part("Ice", at: (ox, 0.015, oz), size: (16, 0.03, 36), color: "#E0F2FE", material: .glass, tags: ["\(h)ice"], solid: false)
        m.slab("Zig", x: ox - 2, y: 0, z: oz - 5, w: 12, h: 0.6, d: 0.6, color: "#7DD3FC", tags: ["\(h)wall"])
        m.slab("Zag", x: ox + 2, y: 0, z: oz + 4, w: 12, h: 0.6, d: 0.6, color: "#7DD3FC", tags: ["\(h)wall"])
        m.part("\(h) Item 1", at: (ox + 5, 0.4, oz - 10), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)
    }
    // 9: the chaos finale: a sweeper, water, sand and a boost.
    golfHole(m, n: 9, ox: 48, oz: 96, color: "#15803D", cupX: -5) { ox, oz, h in
        m.slab("Sweeper", x: ox, y: 0, z: oz - 4, w: 6, h: 0.6, d: 0.8, color: "#F97316", tags: ["\(h)mover"])
        m.part("Water", at: (ox + 4, 0.02, oz + 4), size: (8, 0.04, 4), color: "#38BDF8", material: .glass, tags: ["\(h)water"], solid: false)
        m.part("Sand", at: (ox - 4, 0.02, oz + 9), size: (6, 0.04, 4), color: "#FDE68A", tags: ["\(h)sand"], solid: false)
        m.part("Boost -x", at: (ox + 4, 0.03, oz + 10), size: (2, 0.06, 3), color: "#22D3EE", material: .neon, tags: ["\(h)boost"], solid: false)
        m.part("Slope -z", at: (ox, 0.01, oz + 1), size: (16, 0.02, 3), color: "#166534", tags: ["\(h)slope"], solid: false)
        m.part("\(h) Item 1", at: (ox - 5, 0.4, oz - 8), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)
        m.part("\(h) Item 2", at: (ox + 5, 0.4, oz), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)
    }
    for q in [(-14, 24), (36, 24), (12, 72), (36, 120), (62, 72), (-14, 120)] as [(Float, Float)] {
        m.part("Cloud", at: (q.0, -6, q.1), size: (8, 3, 6), color: "#FFFFFF", shape: .sphere, material: .matte, solid: false)
    }
}

// MARK: 73 Speed Worlds

func speedWorlds(_ m: MapBuilder) {
    m.sky("#22D3EE", "#ECFEFF", light: 0.85, showGround: false, fall: -25)
    m.part("Cover Focus", at: (-60, 4, 40), size: (130, 1, 1), color: "#000000", tags: ["yaw=215"], solid: false, visible: false)
    // The hub: spawns, a portal pad in front of each world, the shop and the records board.
    m.slab("Hub", x: 0, y: -1, z: -36, w: 500, h: 1, d: 26, color: "#F8FAFC")
    m.spawnRing(0, -40, radius: 5, count: 8, color: "#22D3EE")
    m.pad("Shop Pad", x: -12, z: -44, size: 3, color: "#F59E0B", tags: ["shop"])
    m.slab("Shop Stand", x: -12, y: 0, z: -47.5, w: 5, h: 2.6, d: 1, color: "#B45309")
    m.part("Records Board", at: (12, 3, -48.6), size: (10, 4, 0.3), color: "#0F172A", material: .neon, solid: false)
    let worlds: [(String, String, String)] = [("grass", "#4ADE80", "#15803D"), ("ice", "#E0F2FE", "#7DD3FC"), ("lava", "#78716C", "#44403C"),
                                              ("space", "#312E81", "#A78BFA"), ("candy", "#F9A8D4", "#DB2777"), ("desert", "#FDE68A", "#D97706"),
                                              ("cloud", "#F8FAFC", "#CBD5E1"), ("neon", "#0F172A", "#22D3EE")]
    var r = Seeded("speedworlds")
    for (i, w) in worlds.enumerated() {
        let n = i + 1
        let bx = Float(i) * 60 - 210
        m.pad("Portal \(n)", x: bx, z: -28, size: 3.4, color: w.2, tags: ["portal"])
        m.part("Portal Arch \(n)", at: (bx, 2.5, -26.4), size: (4.4, 5, 0.4), color: w.2, material: .neon, solid: false, opacity: 0.7)
        m.slab("World \(n) Start", x: bx, y: -1, z: 0, w: 12, h: 1, d: 12, color: w.1)
        var z: Float = 6
        var level: Float = 0
        for k in 0..<14 {
            let theme = w.0
            var gap = r.range(3, 6)
            var len = r.range(8, 16)
            var width = r.range(4, 7)
            if theme == "ice" { width = r.range(2.2, 3.6) }
            if theme == "space" { gap = r.range(6, 10) }
            if theme == "neon" { len = r.range(10, 20) }
            level = max(0, min(5, level + r.range(-1, 1.4)))
            z += gap + len / 2
            let x = bx + r.range(-5, 5)
            let color = k % 2 == 0 ? w.1 : w.2
            if theme == "desert" && k % 3 == 1 {
                m.part("Mover", at: (x, level - 0.5, z), size: (width, 1, len), color: "#B45309", tags: ["mover"])
            } else {
                m.slab("World \(n) Run", x: x, y: level - 1, z: z, w: width, h: 1, d: len, color: color, material: theme == "ice" ? .glass : .plastic)
            }
            if theme == "lava" && k % 2 == 1 {
                m.part("Lava", at: (x, level + 0.03, z), size: (width * 0.6, 0.06, len * 0.5), color: "#F97316", material: .neon, behavior: .hazard)
            }
            if (theme == "candy" || theme == "cloud") && k % 3 == 2 {
                m.part("Bounce", at: (x, level + 0.1, z + len / 2 - 1.2), size: (min(width, 3), 0.2, 2), color: theme == "candy" ? "#F472B6" : "#38BDF8",
                       material: .neon, behavior: .bounce)
                level = min(6, level + 3)
            }
            if (theme == "neon" && k % 2 == 0) || (theme == "grass" && k % 4 == 3) {
                m.part("Boost", at: (x, level + 0.1, z - len / 2 + 1.2), size: (3, 0.2, 2), color: "#FACC15", material: .neon, behavior: .trigger, tags: ["boost"])
            }
            if k == 4 || k == 9 {
                m.pad("World \(n) CP \(k == 4 ? 1 : 2)", x: x, z: z, y: level, size: 2.6, color: "#22C55E", tags: ["cp"])
            }
            if theme == "cloud" && k % 2 == 0 {
                m.part("Cloud Puff", at: (x + width, level - 1, z), size: (4, 2, 4), color: "#FFFFFF", shape: .sphere, material: .matte, solid: false)
            }
            if theme == "space" && k % 3 == 0 {
                m.part("Star", at: (x + r.range(-10, 10), level + r.range(3, 8), z), size: (0.6, 0.6, 0.6), color: "#FDE047", shape: .sphere, material: .neon, solid: false)
            }
            z += len / 2
        }
        m.slab("World \(n) End", x: bx, y: level - 1, z: z + 8, w: 12, h: 1, d: 10, color: w.2)
        m.pad("World \(n) Finish", x: bx, z: z + 8, y: level, size: 4, color: "#FFFFFF", tags: ["finish"])
        m.part("Finish Flag \(n)", at: (bx + 4, level + 2.5, z + 8), size: (0.2, 5, 0.2), color: "#111827", solid: false)
        m.part("Finish Checker \(n)", at: (bx + 5, level + 4.4, z + 8), size: (2, 1.2, 0.1), color: "#F8FAFC", solid: false)
    }
}

// MARK: 74 Island Drama Show

func dramaShow(_ m: MapBuilder) {
    m.sky("#38BDF8", "#E0F2FE", light: 0.85, ground: "#1D4ED8")
    m.environment.killPlaneHeight = -30
    m.part("Cover Focus", at: (0, 2, 0), size: (150, 1, 1), color: "#000000", tags: ["yaw=200"], solid: false, visible: false)
    var r = Seeded("drama")
    // Camp island: spawns, the campfire, the stage with quiz podiums, the ceremony and the audience benches.
    m.part("Camp Island", at: (0, -1, 0), size: (70, 2, 70), color: "#84CC16", shape: .cylinder, material: .matte)
    m.part("Camp Beach", at: (0, -1.2, 0), size: (78, 2, 78), color: "#FDE68A", shape: .cylinder, material: .matte)
    m.spawnRing(0, 8, radius: 7, count: 12, color: "#FACC15")
    m.part("Campfire Logs", at: (0, 0.2, 8), size: (2, 0.4, 2), color: "#78350F", shape: .cylinder)
    m.part("Campfire", at: (0, 1, 8), size: (1.4, 1.6, 1.4), color: "#F97316", shape: .cone, material: .neon, solid: false)
    m.slab("Stage", x: 0, y: 0, z: -22, w: 30, h: 1, d: 10, color: "#7C2D12")
    m.part("Stage Sign", at: (0, 5.5, -27.2), size: (18, 3, 0.4), color: "#FACC15", material: .neon, solid: false)
    for k in 0..<8 {
        let x = -10.5 + Float(k) * 3
        m.part("Podium \(k + 1)", at: (x, 1.6, -21), size: (1.8, 1.2, 1.2), color: k % 2 == 0 ? "#DC2626" : "#2563EB", solid: false)
    }
    m.part("Host Spot", at: (0, 1.1, -25), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)
    m.slab("Ceremony Stage", x: -20, y: 0, z: 14, w: 12, h: 0.6, d: 6, color: "#A16207")
    m.part("Marshmallow Plate", at: (-20, 1.4, 12), size: (2, 0.2, 2), color: "#F8FAFC", shape: .cylinder, solid: false)
    for k in 0..<5 {
        m.part("Marshmallow", at: (-20.5 + Float(k % 3) * 0.5, 1.7, 11.6 + Float(k / 3) * 0.6), size: (0.35, 0.35, 0.35), color: "#FFFFFF", shape: .sphere, solid: false)
    }
    for k in 0..<3 {
        m.slab("Audience Bench", x: 20, y: 0, z: 8 + Float(k) * 3, w: 10, h: 0.6 + Float(k) * 0.6, d: 1.6, color: "#92400E")
    }
    m.part("Audience", at: (20, 2.4, 14), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)
    m.slab("Dock", x: 34, y: -0.5, z: 0, w: 14, h: 0.5, d: 4, color: "#A16207")
    for p in ring(9, radius: 30, phase: 0.2) {
        if abs(p.1 + 22) > 8 { m.tree(p.0, p.1, height: 5) }
    }
    // 1: the log run over the water.
    m.slab("Log Start", x: 70, y: -1, z: -4, w: 8, h: 1, d: 8, color: "#A16207")
    for i in 0..<12 {
        m.part("Log", at: (70 + r.range(-1.5, 1.5), -0.6, Float(i) * 4 + 3), size: (2.2, 0.6, 3), color: "#92400E", behavior: .disappear,
               gimmick: GimmickSettings(disappearDelay: 0.6, respawnDelay: 2.5))
    }
    m.slab("Log End", x: 70, y: -1, z: 52, w: 8, h: 1, d: 8, color: "#A16207")
    m.pad("Log Finish", x: 70, z: 52, size: 5, color: "#22C55E", tags: ["logfinish"])
    // 2: the dodgeball arena.
    m.slab("Dodge Arena", x: -70, y: -1, z: 0, w: 30, h: 1, d: 30, color: "#E5E7EB")
    m.walls(-70, 0, w: 30, d: 30, h: 1.2, color: "#EF4444", name: "Dodge Rail")
    // 3: the hill: a stepped pyramid with a small top and two pushers sweeping it.
    m.slab("Hill Arena", x: 0, y: -1, z: 80, w: 30, h: 1, d: 30, color: "#A3E635")
    for (k, w) in ([14, 9, 5] as [Float]).enumerated() {
        m.slab("Hill Step", x: 0, y: Float(k) * 1.2, z: 80, w: w, h: 1.2, d: w, color: k == 2 ? "#FACC15" : "#65A30D")
    }
    m.pad("Hill Top", x: 0, z: 80, y: 3.6, size: 4, color: "#FDE047", tags: ["hilltop"], shape: .box)
    m.part("Pusher", at: (-8, 4.4, 80), size: (1, 1.2, 6), color: "#DC2626", tags: ["pusher"])
    m.part("Pusher", at: (8, 1.2, 76), size: (1, 1.2, 6), color: "#DC2626", tags: ["pusher"])
    // 4: the tower climb: a spiral of platforms to a flag.
    m.slab("Tower Start", x: 70, y: -1, z: -70, w: 10, h: 1, d: 10, color: "#78716C")
    m.pillar("Tower Core", x: 70, z: -60, height: 30, radius: 2, color: "#57534E")
    for k in 0..<16 {
        let a = Float(k) * 0.8
        m.slab("Tower Step", x: 70 + cos(a) * 6, y: 1.2 + Float(k) * 1.8, z: -60 + sin(a) * 6, w: 3, h: 0.5, d: 3, color: k % 2 == 0 ? "#F97316" : "#FACC15")
    }
    m.slab("Tower Top Floor", x: 70, y: 30, z: -60, w: 6, h: 0.5, d: 6, color: "#FDE047")
    m.pad("Tower Top", x: 70, z: -60, y: 30.5, size: 4, color: "#22C55E", tags: ["towertop"])
    // 5: the coin arena.
    m.slab("Coin Arena", x: -70, y: -1, z: 70, w: 30, h: 1, d: 30, color: "#FEF3C7")
    m.walls(-70, 70, w: 30, d: 30, h: 1.2, color: "#F59E0B", name: "Coin Rail")
    // 6: the colour floor: 6 × 6 tiles.
    for row in 0..<6 {
        for col in 0..<6 {
            m.slab("Color Tile \(row * 6 + col + 1)", x: 70 - 7.5 + Float(col) * 3, y: -0.5, z: 70 - 7.5 + Float(row) * 3, w: 2.9, h: 0.5, d: 2.9, color: "#F8FAFC",
                   tags: ["colortile"])
        }
    }
    m.part("Color Floor", at: (70, 0.1, 70), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)
    // 7: the ice floor that cracks under your feet.
    for row in 0..<7 {
        for col in 0..<7 {
            m.slab("Spleef \(row * 7 + col + 1)", x: -70 - 7.5 + Float(col) * 2.5, y: -0.5, z: -70 - 7.5 + Float(row) * 2.5, w: 2.4, h: 0.5, d: 2.4, color: "#BAE6FD",
                   material: .glass, behavior: .trigger, tags: ["spleef"])
        }
    }
    m.part("Spleef Floor", at: (-70, 0.1, -70), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)
    // 8: the memory path: 5 across, 8 deep.
    m.slab("Memory Start", x: 0, y: -1, z: -84, w: 14, h: 1, d: 5, color: "#A78BFA")
    for row in 0..<8 {
        for col in 0..<5 {
            m.slab("Mem \(row + 1) \(col + 1)", x: -5 + Float(col) * 2.5, y: -0.5, z: -80 + Float(row) * 2.5, w: 2.3, h: 0.5, d: 2.3, color: "#E9D5FF", behavior: .trigger, tags: ["memtile"])
        }
    }
    m.slab("Memory End", x: 0, y: -1, z: -59, w: 14, h: 1, d: 5, color: "#A78BFA")
    m.pad("Memory Finish", x: 0, z: -59, size: 4, color: "#22C55E", tags: ["memfinish"])
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
