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
         summary: "家具になりきってかくれんぼ！ 部屋ごとにちがう家具に「そっくり変身」、回転と固定、挑発でポイント。鬼は懐中電灯と探知機でさがす。見つかったら鬼の仲間に…！",
         tags: ["hide-and-seek", "props", "party"], maxPlayers: 12, build: propHunt),
    Game(number: 76, id: "mega-minigames", title: "Mega Minigames",
         summary: "投票で次のゲームを決めるパーティー！ 落ちる床・山の王・色あわせ・玉よけ・ハンマーよけ・たまご集め・リレー・床ぬり・的当て・にわとりつかまえ・いすとり・ばくだんパスの12種類で⭐を集めて総合優勝！",
         tags: ["minigames", "party", "classic"], maxPlayers: 16, build: megaMinigames),
    Game(number: 77, id: "rhythm-battle", title: "Rhythm Battle",
         summary: "8曲×3難易度のリズムゲーム。PERFECT判定・コンボ・フィーバー、ステージで対戦（おじゃま攻撃つき）かCPU戦、練習ブース、Sランクとファンで曲の解放！ 照明とダンサーがビートに合わせてノリノリ",
         tags: ["rhythm", "music", "1v1"], maxPlayers: 8, build: rhythmBattle),
    Game(number: 78, id: "last-survivor-games", title: "Last Survivor Games",
         summary: "24人で挑む5つのゲーム。だるまさんがころんだ・つなひき・なかま集め・ガラスの橋・最後のタイル。脱落するほど賞金がふえる。最後の1人になれ！",
         tags: ["survival", "minigames", "tense"], maxPlayers: 16, build: survivorGames),
    Game(number: 79, id: "shark-attack-bay", title: "Shark Attack Bay",
         summary: "サメ1匹 vs ボートの人間たち。ボートをこわして海へ落とせ／ハープーンとダイナマイトで撃退しろ。サメは3種類、技は4つ",
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
                   material: .glass, tags: ["spleef"])
        }
    }
    m.part("Spleef Floor", at: (-70, 0.1, -70), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)
    // 8: the memory path: 5 across, 8 deep.
    m.slab("Memory Start", x: 0, y: -1, z: -84, w: 14, h: 1, d: 5, color: "#A78BFA")
    for row in 0..<8 {
        for col in 0..<5 {
            m.slab("Mem \(row + 1) \(col + 1)", x: -5 + Float(col) * 2.5, y: -0.5, z: -80 + Float(row) * 2.5, w: 2.3, h: 0.5, d: 2.3, color: "#E9D5FF", tags: ["memtile"])
        }
    }
    m.slab("Memory End", x: 0, y: -1, z: -59, w: 14, h: 1, d: 5, color: "#A78BFA")
    m.pad("Memory Finish", x: 0, z: -59, size: 4, color: "#22C55E", tags: ["memfinish"])
}

// MARK: 75 Prop Hide & Seek

func propHunt(_ m: MapBuilder) {
    m.sky("#93C5FD", "#E0F2FE", light: 0.85, ground: "#65A30D")
    m.part("Cover Focus", at: (0, 2, 0), size: (84, 1, 1), color: "#000000", tags: ["yaw=200"], solid: false, visible: false)
    var r = Seeded("props")
    // The house: 80 × 64, split into rooms with doorways.
    m.ground(160, 150, color: "#65A30D", name: "Garden Grass")
    m.slab("House Floor", x: 0, y: 0, z: 0, w: 80, h: 0.1, d: 64, color: "#D6D3D1")
    // Outer walls with a doorway front and back.
    for sz: Float in [-32, 32] {
        for sx: Float in [-1, 1] { m.slab("House Wall", x: sx * 21.75, y: 0, z: sz, w: 37.5, h: 6, d: 0.6, color: "#FEF3C7") }
        m.slab("House Wall", x: 0, y: 3.2, z: sz, w: 6, h: 2.8, d: 0.6, color: "#FEF3C7")
    }
    for sx: Float in [-40, 40] { m.slab("House Wall", x: sx, y: 0, z: 0, w: 0.6, h: 6, d: 64.6, color: "#FEF3C7") }
    let inner: [(Float, Float, Float, Float)] = [(-14, -32, -14, -4), (-14, 4, -14, 32), (14, -32, 14, -4), (14, 4, 14, 32),
                                                 (-40, 0, -24, 0), (-18, 0, -14, 0), (14, 0, 18, 0), (24, 0, 40, 0)]
    for w in inner {
        let dx = w.2 - w.0, dz = w.3 - w.1
        m.slab("Room Wall", x: (w.0 + w.2) / 2, y: 0, z: (w.1 + w.3) / 2, w: dx == 0 ? 0.5 : dx, h: 4, d: dz == 0 ? 0.5 : dz, color: "#F5F5F4")
    }
    let rooms: [(String, Float, Float, String, [(String, V, String, BlockShape)])] = [
        ("Living", -27, 16, "#FDE68A", [("Sofa", (4, 1.2, 1.6), "#7C3AED", .box), ("TV", (2.6, 1.6, 0.3), "#111827", .box), ("Lamp", (0.6, 1.8, 0.6), "#FDE68A", .cylinder),
                                          ("Plant", (1, 1.8, 1), "#16A34A", .cone), ("Bookshelf", (2.4, 2.6, 0.8), "#78350F", .box), ("Armchair", (1.6, 1.2, 1.6), "#DB2777", .box)]),
        ("Kitchen", 27, 16, "#E0F2FE", [("Fridge", (1.4, 2.6, 1.2), "#E5E7EB", .box), ("Stove", (1.4, 1, 1.2), "#374151", .box), ("Barrel", (1.2, 1.6, 1.2), "#7C2D12", .cylinder),
                                         ("Pot", (0.9, 0.7, 0.9), "#9CA3AF", .cylinder), ("Chair", (1, 1.2, 1), "#1E3A8A", .box), ("Watermelon", (1.1, 0.9, 1.1), "#16A34A", .sphere)]),
        ("Bedroom", -27, -16, "#FBCFE8", [("Bed", (2.4, 0.9, 4), "#60A5FA", .box), ("Wardrobe", (2, 3, 1), "#92400E", .box), ("Lamp", (0.6, 1.8, 0.6), "#FDE68A", .cylinder),
                                           ("Teddy", (0.9, 1.1, 0.8), "#A16207", .sphere), ("Box", (1.4, 1.4, 1.4), "#A16207", .box), ("Laundry", (1.1, 1.2, 1.1), "#F8FAFC", .cylinder)]),
        ("Kids", 27, -16, "#BBF7D0", [("Ball", (1, 1, 1), "#EF4444", .sphere), ("Toy Block", (1, 1, 1), "#3B82F6", .box), ("Toy Rocket", (0.8, 2, 0.8), "#F97316", .cone),
                                       ("Teddy", (0.9, 1.1, 0.8), "#A16207", .sphere), ("Toy Block", (1, 1, 1), "#FACC15", .box), ("Drum", (1.2, 0.8, 1.2), "#DC2626", .cylinder)]),
        ("Hall", 0, 0, "#E7E5E4", [("Plant", (1, 1.8, 1), "#16A34A", .cone), ("Umbrella Stand", (0.6, 1.2, 0.6), "#1F2937", .cylinder), ("Box", (1.4, 1.4, 1.4), "#A16207", .box),
                                    ("Clock", (0.8, 2.4, 0.6), "#78350F", .box)])
    ]
    for room in rooms {
        m.slab("\(room.0) Rug", x: room.1, y: 0.1, z: room.2, w: room.0 == "Hall" ? 8 : 16, h: 0.04, d: room.0 == "Hall" ? 40 : 18, color: room.3)
        let count = room.0 == "Hall" ? 8 : 16
        for _ in 0..<count {
            let pr = r.pick(room.4)
            let hx: Float = room.0 == "Hall" ? 5 : 11
            let hz: Float = room.0 == "Hall" ? 26 : 12
            let x = room.1 + r.range(-hx, hx), z = room.2 + r.range(-hz, hz)
            m.part(pr.0, at: (x, 0.14 + pr.1.1 / 2, z), size: pr.1, color: pr.2, shape: pr.3, tags: ["decor"], rotation: (0, r.pick([0, 90, 45]), 0))
        }
    }
    // The garden in front and the garage behind.
    let garden: [(String, V, String, BlockShape)] = [("Bush", (1.6, 1.2, 1.6), "#15803D", .sphere), ("Flower Pot", (0.8, 0.8, 0.8), "#B45309", .cylinder),
                                                     ("Gnome", (0.6, 1, 0.6), "#DC2626", .cone), ("Rock", (1.4, 0.9, 1.2), "#78716C", .sphere),
                                                     ("Wheelbarrow", (1, 0.8, 1.8), "#16A34A", .box)]
    for _ in 0..<18 {
        let pr = r.pick(garden)
        m.part(pr.0, at: (r.range(-38, 38), pr.1.1 / 2, r.range(36, 52)), size: pr.1, color: pr.2, shape: pr.3, tags: ["decor"])
    }
    for q in [(-30, 58), (-10, 60), (12, 57), (32, 60)] as [(Float, Float)] { m.tree(q.0, q.1, height: 5) }
    m.slab("Garage Floor", x: 0, y: 0, z: -48, w: 30, h: 0.1, d: 24, color: "#57534E")
    for sx: Float in [-1, 1] { m.slab("Garage Wall", x: sx * 9, y: 0, z: -36.5, w: 12, h: 5, d: 0.5, color: "#A8A29E") }
    m.slab("Garage Wall", x: 0, y: 0, z: -60, w: 30, h: 5, d: 0.5, color: "#A8A29E")
    for sx: Float in [-15, 15] { m.slab("Garage Wall", x: sx, y: 0, z: -48, w: 0.5, h: 5, d: 24, color: "#A8A29E") }
    m.slab("Garage Path", x: 0, y: 0, z: -34.2, w: 6, h: 0.1, d: 4, color: "#A8A29E")
    let garage: [(String, V, String, BlockShape)] = [("Tyre", (1.2, 0.5, 1.2), "#111827", .cylinder), ("Toolbox", (1.2, 0.8, 0.6), "#DC2626", .box),
                                                     ("Barrel", (1.2, 1.6, 1.2), "#1D4ED8", .cylinder), ("Box", (1.4, 1.4, 1.4), "#A16207", .box), ("Cone", (0.6, 1, 0.6), "#F97316", .cone)]
    for _ in 0..<14 {
        let pr = r.pick(garage)
        m.part(pr.0, at: (r.range(-13, 13), 0.1 + pr.1.1 / 2, r.range(-58, -38)), size: pr.1, color: pr.2, shape: pr.3, tags: ["decor"])
    }
    m.parkedCar("Garage Car", x: 6, z: -48, color: "#2563EB")
    m.slab("Front Step", x: 0, y: 0, z: 34, w: 6, h: 0.3, d: 3, color: "#A8A29E")
    // The seekers' waiting room, away from everything.
    m.slab("Seeker Room", x: 0, y: -1, z: -95, w: 12, h: 1, d: 12, color: "#1F2937")
    m.walls(0, -95, w: 12, d: 12, h: 4, color: "#111827", name: "Seeker Room Wall")
    m.part("Seeker Cage", at: (0, 0.1, -95), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)
    m.spawnRing(0, 20, radius: 4, count: 10, color: "#FBBF24")
}

// MARK: 76 Mega Minigames

func megaMinigames(_ m: MapBuilder) {
    m.sky("#A855F7", "#F0ABFC", light: 0.85, showGround: false, fall: -20)
    m.part("Cover Focus", at: (0, 0, -8), size: (86, 1, 1), color: "#000000", tags: ["yaw=205"], solid: false, visible: false)
    // The lobby with a scoreboard.
    m.slab("Lobby", x: 0, y: -1, z: -48, w: 34, h: 1, d: 18, color: "#F5F5F4")
    m.spawnRing(0, -48, radius: 6, count: 12, color: "#F472B6")
    m.part("Lobby Board", at: (0, 4, -56.6), size: (20, 5, 0.3), color: "#4C1D95", material: .neon, solid: false)
    for sx: Float in [-1, 1] {
        m.part("Balloon", at: (sx * 14, 5, -52), size: (2, 2.6, 2), color: sx < 0 ? "#F472B6" : "#60A5FA", shape: .sphere, solid: false)
        m.part("Balloon String", at: (sx * 14, 2, -52), size: (0.05, 4, 0.05), color: "#F8FAFC", solid: false)
    }
    // The arena: a 10 × 10 floor of tiles inside a rim with a pad in each corner.
    let colors = ["#EF4444", "#3B82F6", "#22C55E", "#FACC15"]
    for gx in 0..<10 {
        for gz in 0..<10 {
            m.part("Tile \(gx)-\(gz)", at: (-18 + Float(gx) * 4, -0.5, -18 + Float(gz) * 4), size: (3.9, 1, 3.9),
                   color: colors[(gx + gz * 3) % 4], tags: ["tile"])
        }
    }
    for side in 0..<4 {
        let horizontal = side < 2
        let sgn: Float = side % 2 == 0 ? -1 : 1
        m.slab("Rim", x: horizontal ? 0 : sgn * 22.5, y: -1, z: horizontal ? sgn * 22.5 : 0, w: horizontal ? 50 : 5, h: 1, d: horizontal ? 5 : 40,
               color: "#E9D5FF")
    }
    let corners: [(Float, Float)] = [(-22.5, -22.5), (22.5, -22.5), (22.5, 22.5), (-22.5, 22.5)]
    for (i, c) in corners.enumerated() {
        m.pad("Corner \(i + 1)", x: c.0, z: c.1, size: 3.4, color: ["#EF4444", "#3B82F6", "#22C55E", "#FACC15"][i], tags: ["corner"])
        m.part("Corner Flag \(i + 1)", at: (c.0, 3, c.1), size: (0.2, 6, 0.2), color: "#F8FAFC", solid: false)
    }
    m.part("Hill", at: (0, 1, 0), size: (6, 2, 6), color: "#FDE047", shape: .cylinder, material: .neon, tags: ["hill"], visible: false)
    m.part("Arena Center", at: (0, 1, 0), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    m.slab("Bridge", x: 0, y: -1, z: -32, w: 6, h: 1, d: 15, color: "#F5F5F4")
    for p in ring(12, radius: 34) {
        m.part("Confetti Pole", at: (p.0, 4, p.1), size: (0.3, 8, 0.3), color: "#FDE047", solid: false)
        m.part("Confetti Ball", at: (p.0, 8.4, p.1), size: (1.2, 1.2, 1.2), color: "#F0ABFC", shape: .sphere, material: .neon, solid: false)
    }
}

// MARK: 77 Rhythm Battle

func rhythmBattle(_ m: MapBuilder) {
    m.indoor()
    m.sky("#0F0A1F", "#3B0764", light: 0.9, showGround: false)
    m.part("Cover Focus", at: (0, 3, -4), size: (44, 1, 1), color: "#000000", tags: ["yaw=20"], solid: false, visible: false)
    m.ground(64, 54, color: "#1E1B4B", name: "Club Floor")
    // A dance floor of glowing tiles.
    let tileColors = ["#EC4899", "#22D3EE", "#A3E635", "#F97316", "#A78BFA"]
    for gx in 0..<6 {
        for gz in 0..<4 {
            m.part("Dance Tile", at: (-10 + Float(gx) * 4, 0.03, 2 + Float(gz) * 4), size: (3.8, 0.06, 3.8), color: tileColors[(gx + gz) % 5], material: .neon,
                   tags: ["light"], solid: false, opacity: 0.55)
        }
    }
    // The battle stage with a pad on each side.
    m.slab("Stage", x: 0, y: 0, z: -12, w: 26, h: 1.2, d: 10, color: "#4338CA")
    m.stairs(-3, -6.5, steps: 2, rise: 0.6, run: 1, width: 6, color: "#4338CA", name: "Stage Step")
    m.pad("Stage Left", x: -6, z: -11, y: 1.2, size: 3.2, color: "#EC4899", tags: ["stage", "left"])
    m.pad("Stage Right", x: 6, z: -11, y: 1.2, size: 3.2, color: "#22D3EE", tags: ["stage", "right"])
    m.part("Stage Screen", at: (0, 5.5, -16.8), size: (18, 6, 0.3), color: "#1E1B4B", material: .neon, solid: false)
    m.part("Stage Screen Glow", at: (0, 5.5, -16.6), size: (16, 5, 0.1), color: "#7C3AED", material: .neon, tags: ["light"], solid: false, opacity: 0.6)
    for (i, p) in grid(6, 1, spacing: 4.4, cx: 0, cz: -18).enumerated() {
        m.part("Speaker \(i + 1)", at: (p.0, 2.5, p.1), size: (2.2, 3.4, 1.2), color: "#111827")
        m.part("Speaker Cone", at: (p.0, 2.5, p.1 + 0.62), size: (1.4, 0.05, 1.4), color: "#374151", shape: .cylinder, solid: false, rotation: (90, 0, 0))
    }
    for k in 0..<5 {
        m.part("Stage Light", at: (-10 + Float(k) * 5, 8, -10), size: (1, 0.6, 1), color: "#F0ABFC", shape: .cone, material: .neon, tags: ["light"], solid: false,
               rotation: (180, 0, 0))
    }
    // The DJ booth.
    m.slab("DJ Booth", x: 0, y: 1.2, z: -15, w: 6, h: 1.2, d: 1.6, color: "#0F172A")
    m.part("DJ Deck", at: (-1.4, 2.5, -15), size: (1.2, 0.1, 1.2), color: "#A855F7", shape: .cylinder, material: .neon, solid: false)
    m.part("DJ Deck", at: (1.4, 2.5, -15), size: (1.2, 0.1, 1.2), color: "#22D3EE", shape: .cylinder, material: .neon, solid: false)
    // Four practice booths down the sides.
    let booths: [(Float, Float, String)] = [(-26, -6, "#EC4899"), (-26, 10, "#22D3EE"), (26, -6, "#A3E635"), (26, 10, "#F97316")]
    for (i, b) in booths.enumerated() {
        m.slab("Booth Floor", x: b.0, y: 0, z: b.1, w: 8, h: 0.3, d: 8, color: "#312E81")
        m.slab("Booth Wall", x: b.0 + (b.0 < 0 ? -4 : 4), y: 0, z: b.1, w: 0.4, h: 3.4, d: 8, color: b.2)
        m.part("Booth Sign", at: (b.0 + (b.0 < 0 ? -3.7 : 3.7), 2.6, b.1), size: (0.2, 1, 4), color: b.2, material: .neon, tags: ["light"], solid: false)
        m.pad("Booth \(i + 1)", x: b.0, z: b.1, y: 0.3, size: 3, color: b.2, tags: ["booth"])
    }
    // Neon strips round the walls.
    m.walls(0, 0, w: 64, d: 54, h: 8, color: "#1E1B4B", name: "Club Wall")
    for sx: Float in [-31.6, 31.6] {
        m.part("Neon Strip", at: (sx, 5, 0), size: (0.2, 0.4, 50), color: "#F0ABFC", material: .neon, tags: ["light"], solid: false)
    }
    m.spawnRing(0, 18, radius: 5, count: 8, color: "#A78BFA")
}

// MARK: 78 Last Survivor Games

func survivorGames(_ m: MapBuilder) {
    m.day(ground: "#D6D3D1")
    m.sky("#93C5FD", "#E0F2FE", light: 0.95, showGround: false, fall: -25)
    m.part("Cover Focus", at: (0, 5, 150), size: (46, 1, 1), color: "#000000", tags: ["yaw=205"], solid: false, visible: false)

    // The dorm: bunk towers, the prize orb over the middle, the show board.
    m.ground(48, 40, color: "#E2E8F0", name: "Dorm Floor", material: .plastic)
    m.walls(0, 0, w: 48, d: 40, h: 12, color: "#CBD5E1", name: "Dorm Wall")
    for bx: Float in [-18, 18] {
        for bz: Float in [-12, 0, 12] {
            for lvl in 0..<5 {
                let y = Float(lvl) * 2.1
                m.slab("Bunk", x: bx, y: y + 0.5, z: bz, w: 6, h: 0.3, d: 3.2, color: "#0F766E")
                m.slab("Mattress", x: bx, y: y + 0.8, z: bz, w: 5.6, h: 0.3, d: 2.8, color: "#F8FAFC", solid: false)
            }
            for sx: Float in [-2.9, 2.9] {
                m.pillar("Bunk Post", x: bx + sx, z: bz - 1.5, height: 10.5, radius: 0.12, color: "#134E4A")
                m.pillar("Bunk Post", x: bx + sx, z: bz + 1.5, height: 10.5, radius: 0.12, color: "#134E4A")
            }
        }
    }
    m.part("Prize Chain", at: (0, 11, 0), size: (0.2, 2.2, 0.2), color: "#94A3B8", shape: .cylinder, material: .metal, solid: false)
    m.part("Prize Orb", at: (0, 7.5, 0), size: (5, 5, 5), color: "#E0F2FE", shape: .sphere, material: .glass, solid: false, opacity: 0.3)
    m.part("Prize Gold", at: (0, 6.2, 0), size: (0.6, 0.6, 0.6), color: "#FACC15", shape: .sphere, material: .neon, solid: false)
    m.part("Show Board", at: (0, 6, -19.4), size: (16, 5, 0.3), color: "#0F172A", material: .neon, solid: false)
    m.part("Show Board Glow", at: (0, 6, -19.2), size: (14, 3.6, 0.1), color: "#EC4899", material: .neon, tags: ["board"], solid: false,
           opacity: 0.7)
    m.slab("Crown Pedestal", x: 0, y: 0, z: 13, w: 4, h: 1.2, d: 4, color: "#FACC15", material: .metal)
    m.spawnRing(0, -4, radius: 6, count: 12, name: "Dorm Spawn", color: "#5EEAD4")

    // Game 1 — the field, the doll and rocks to hide behind.
    m.slab("Field", x: 0, y: -1, z: 120, w: 60, h: 1, d: 124, color: "#E7D8B8", tags: ["ground"])
    m.walls(0, 120, w: 60, d: 124, h: 10, color: "#BAE6FD", name: "Field Wall")
    var sky = Seeded("survivor-clouds")
    for k in 0..<14 {
        let side: Float = k % 2 == 0 ? -29.4 : 29.4
        m.part("Painted Cloud", at: (side, sky.range(5, 8.5), sky.range(66, 176)), size: (0.2, sky.range(1.2, 2), sky.range(4, 7)), color: "#FFFFFF",
               material: .matte, solid: false)
    }
    m.part("Start Line", at: (0, 0.03, 68), size: (58, 0.05, 0.6), color: "#FFFFFF", material: .neon, solid: false)
    m.part("Finish Line", at: (0, 0.03, 168), size: (58, 0.05, 1), color: "#DC2626", material: .neon, solid: false)
    m.part("Finish Zone", at: (0, 0.02, 173), size: (58, 0.04, 9), color: "#22C55E", material: .matte, solid: false, opacity: 0.6)
    for q in [(-18, 94), (14, 100), (-5, 116), (20, 128), (-21, 140), (5, 150)] as [(Float, Float)] {
        m.slab("Rock", x: q.0, y: 0, z: q.1, w: 3.2, h: 3, d: 2.2, color: "#A8A29E", material: .matte, tags: ["cover"])
        m.part("Rock Top", at: (q.0, 3.1, q.1), size: (3, 0.9, 2), color: "#78716C", shape: .sphere, material: .matte, solid: false)
    }
    m.part("Doll Body", at: (0, 4.5, 176), size: (5, 9, 5), color: "#F97316", shape: .cone)
    m.part("Doll Collar", at: (0, 8.6, 176), size: (4.2, 0.8, 4.2), color: "#FDE047", shape: .cylinder)
    m.part("Doll Head", at: (0, 11.2, 176), size: (4.6, 4.6, 4.6), color: "#FDE68A", shape: .sphere)
    m.part("Doll Hair", at: (0, 11.9, 176.7), size: (4.9, 3.8, 3.8), color: "#111827", shape: .sphere, solid: false)
    m.part("Doll Eye", at: (-1, 11.6, 173.75), size: (0.7, 0.7, 0.25), color: "#111827", shape: .sphere, tags: ["dolleye"], solid: false, visible: false)
    m.part("Doll Eye", at: (1, 11.6, 173.75), size: (0.7, 0.7, 0.25), color: "#111827", shape: .sphere, tags: ["dolleye"], solid: false, visible: false)
    m.part("Doll Glow", at: (0, 11.2, 176), size: (6, 0.25, 6), color: "#EF4444", shape: .cylinder, material: .neon, solid: false,
           visible: false)
    for sx: Float in [-1, 1] {
        m.part("Doll Pigtail", at: (sx * 2.6, 10.6, 176.8), size: (1.2, 2.4, 1.2), color: "#111827", shape: .sphere, solid: false)
    }
    m.part("Doll Tree Trunk", at: (0, 6, 181), size: (1.4, 12, 1.4), color: "#78350F", shape: .cylinder)
    m.part("Doll Tree", at: (0, 14, 181), size: (10, 7, 6), color: "#65A30D", shape: .sphere, material: .matte, solid: false)
    m.tree(-10, 180, height: 6, leaves: "#4D7C0F")
    m.tree(10, 180, height: 6, leaves: "#4D7C0F")
    m.slab("Field Gallery", x: 35, y: 10, z: 120, w: 8, h: 0.6, d: 50, color: "#334155")
    m.slab("Field Gallery Rail", x: 31.4, y: 10.6, z: 120, w: 0.3, h: 1, d: 50, color: "#94A3B8")
    for q in [(-26, 172), (26, 172)] as [(Float, Float)] {
        m.part("Referee", at: (q.0, 1, q.1), size: (1, 2, 1), color: "#1E293B")
        m.part("Referee Helmet", at: (q.0, 2.4, q.1), size: (1, 0.8, 1), color: "#FACC15", shape: .sphere)
    }

    // Game 2 — tug of war over a pit. The floors drop out from under the losers.
    m.slab("Tug Pit", x: 200, y: -1, z: 0, w: 70, h: 1, d: 36, color: "#1F2937", tags: ["ground"])
    m.walls(200, 0, w: 70, d: 36, h: 22, color: "#475569", name: "Tug Wall")
    for side: Float in [-1, 1] {
        let cx = 200 + side * 15
        for q in [(cx - 7.4, -5.4), (cx + 7.4, -5.4), (cx - 7.4, 5.4), (cx + 7.4, 5.4)] as [(Float, Float)] {
            m.pillar("Tug Leg", x: q.0, z: q.1, height: 9.4, radius: 0.45, color: "#334155", material: .metal)
        }
        m.slab(side < 0 ? "Tug Left Floor" : "Tug Right Floor", x: cx, y: 9.4, z: 0, w: 16, h: 0.6, d: 12,
               color: side < 0 ? "#DC2626" : "#2563EB", tags: ["tugfloor"])
        m.part(side < 0 ? "Tug Left Sign" : "Tug Right Sign", at: (cx + side * 7.6, 14, 0), size: (0.3, 3, 8), color: side < 0 ? "#F87171" : "#60A5FA",
               material: .neon, solid: false)
    }
    m.part("Rope", at: (200, 10.9, 0), size: (0.35, 40, 0.35), color: "#D6B98C", shape: .cylinder, material: .matte, solid: false,
           rotation: (0, 0, 90))
    m.part("Rope Flag", at: (200, 10.2, 0), size: (0.4, 1.2, 0.8), color: "#FACC15", material: .neon, solid: false)
    m.part("Tug Center Line", at: (200, 0.02, 0), size: (0.5, 0.05, 30), color: "#FACC15", material: .neon, solid: false)
    m.slab("Tug Gallery", x: 200, y: 17, z: -15, w: 30, h: 0.6, d: 5, color: "#1E293B")
    m.slab("Tug Gallery Rail", x: 200, y: 17.6, z: -12.6, w: 30, h: 1, d: 0.3, color: "#94A3B8")

    // Game 3 — the huddle hall: a carousel in the middle, ten rooms round the edge.
    m.ground(64, 64, color: "#FBCFE8", name: "Huddle Floor", x: -200, z: 0, material: .plastic)
    m.walls(-200, 0, w: 64, d: 64, h: 9, color: "#F9A8D4", name: "Huddle Wall")
    m.part("Carousel", at: (-200, 0.3, 0), size: (18, 0.6, 18), color: "#FDE68A", shape: .cylinder, tags: ["carousel"])
    m.part("Carousel Pole", at: (-200, 3.5, 0), size: (1, 6, 1), color: "#F59E0B", shape: .cylinder, material: .metal)
    m.part("Carousel Canopy", at: (-200, 7.4, 0), size: (19, 2, 19), color: "#EC4899", shape: .cone, solid: false)
    for (i, q) in ring(8, radius: 7, cx: -200, cz: 0).enumerated() {
        m.part("Carousel Horse", at: (q.0, 1.5, q.1), size: (0.6, 1, 1.6), color: ["#F87171", "#60A5FA", "#FDE047", "#86EFAC"][i % 4],
               tags: ["horse"], solid: false)
        m.part("Carousel Rod", at: (q.0, 4, q.1), size: (0.12, 6, 0.12), color: "#FBBF24", shape: .cylinder, material: .metal, solid: false)
    }
    let roomColors = ["#F472B6", "#A78BFA", "#60A5FA", "#34D399", "#FBBF24"]
    for (i, rx) in ([-24, -12, 0, 12, 24] as [Float]).enumerated() {
        for (j, side) in ([-1, 1] as [Float]).enumerated() {
            let n = j * 5 + i + 1
            let x = -200 + rx, z = side * 27
            let color = roomColors[i]
            m.slab("Room \(n) Floor", x: x, y: 0, z: z, w: 7, h: 0.1, d: 6, color: "#FFF1F2", tags: ["room"])
            m.slab("Room Wall", x: x - 3.6, y: 0, z: z, w: 0.4, h: 4, d: 6, color: color)
            m.slab("Room Wall", x: x + 3.6, y: 0, z: z, w: 0.4, h: 4, d: 6, color: color)
            let front = z - side * 3
            m.slab("Room Wall", x: x - 2.35, y: 0, z: front, w: 2.7, h: 4, d: 0.4, color: color)
            m.slab("Room Wall", x: x + 2.35, y: 0, z: front, w: 2.7, h: 4, d: 0.4, color: color)
            m.slab("Room Wall", x: x, y: 2.8, z: front, w: 2, h: 1.2, d: 0.4, color: color)
            m.slab("Room Wall", x: x, y: 0, z: z + side * 3, w: 7.6, h: 4, d: 0.4, color: color)
            m.part("Room \(n) Door", at: (x, 1.4, front), size: (2, 2.8, 0.4), color: "#475569", tags: ["door"], solid: false, visible: false)
            m.part("Room \(n) Lamp", at: (x, 4.4, front), size: (2.2, 0.6, 0.3), color: "#FFFFFF", material: .neon, tags: ["lamp"], solid: false)
        }
    }
    m.slab("Huddle Gallery", x: -164, y: 9, z: 0, w: 6, h: 0.6, d: 40, color: "#831843")

    // Game 4 — the glass bridge, high over a pit.
    m.slab("Bridge Pit", x: 0, y: -1, z: -192, w: 40, h: 1, d: 90, color: "#0F172A", tags: ["ground"])
    m.slab("Bridge Start", x: 0, y: 20, z: -160, w: 12, h: 1, d: 8, color: "#6B7280")
    m.slab("Bridge Start Base", x: 0, y: 0, z: -160, w: 6, h: 20, d: 6, color: "#374151")
    for i in 0..<12 {
        let z = -166 - Float(i) * 4.5
        m.part("Glass \(i + 1) L", at: (-2, 20.9, z), size: (3, 0.2, 3), color: "#BAE6FD", material: .glass, tags: ["glass"],
               opacity: 0.6)
        m.part("Glass \(i + 1) R", at: (2, 20.9, z), size: (3, 0.2, 3), color: "#BAE6FD", material: .glass, tags: ["glass"],
               opacity: 0.6)
        m.part("Row \(i + 1) Number", at: (-5.2, 21.8, z), size: (0.2, 0.8, 0.8), color: "#FDE047", material: .neon, solid: false)
    }
    for x: Float in [-3.7, -0.3, 0.3, 3.7] {
        m.part("Bridge Beam", at: (x, 20.6, -191), size: (0.15, 0.3, 54), color: "#475569", material: .metal, solid: false)
    }
    m.slab("Bridge End", x: 0, y: 20, z: -223, w: 12, h: 1, d: 8, color: "#6B7280")
    m.slab("Bridge End Base", x: 0, y: 0, z: -223, w: 6, h: 20, d: 6, color: "#374151")
    m.pad("Bridge Goal", x: 0, z: -224, y: 21, size: 5, color: "#22C55E", tags: ["bridgegoal"])
    m.slab("Bridge Gallery", x: 14, y: 24, z: -192, w: 6, h: 0.6, d: 40, color: "#1E293B")
    m.slab("Bridge Gallery Rail", x: 11.2, y: 24.6, z: -192, w: 0.3, h: 1, d: 40, color: "#94A3B8")
    for z: Float in [-170, -192, -214] {
        m.part("Bridge Lamp", at: (-9, 28, z), size: (1.2, 1.2, 1.2), color: "#FEF3C7", shape: .sphere, material: .neon, solid: false)
        m.part("Bridge Lamp Post", at: (-9, 14, z), size: (0.4, 28, 0.4), color: "#334155", shape: .cylinder, material: .metal)
    }

    // Game 5 — the last tiles.
    m.slab("Final Pit", x: 200, y: -1, z: -200, w: 44, h: 1, d: 44, color: "#450A0A", tags: ["ground"])
    for r in 0..<7 {
        for c in 0..<7 {
            let x = 200 + (Float(c) - 3) * 3.8, z = -200 + (Float(r) - 3) * 3.8
            m.slab("Tile \(r * 7 + c + 1)", x: x, y: 9.7, z: z, w: 3.6, h: 0.6, d: 3.6, color: (r + c) % 2 == 0 ? "#F8FAFC" : "#E2E8F0", tags: ["tile"])
        }
    }
    for q in ring(8, radius: 19, cx: 200, cz: -200, phase: 0.39) {
        m.pillar("Final Pillar", x: q.0, z: q.1, height: 16, radius: 0.7, color: "#7F1D1D")
        m.part("Final Torch", at: (q.0, 16.8, q.1), size: (1.4, 1.4, 1.4), color: "#F97316", shape: .sphere, material: .neon, solid: false)
    }
    m.slab("Final Gallery", x: 200, y: 16, z: -176, w: 30, h: 0.6, d: 5, color: "#1C1917")
}

// MARK: 79 Shark Attack Bay

/// Steps out of the shallow sea (floor at y = -1.2) up to a deck whose top is `top`: 0.4 m risers, walkable without jumping.
/// (x, z) is the step touching the deck; the steps run away from it along (dx, dz).
func seaLadder(_ m: MapBuilder, x: Float, z: Float, dx: Float, dz: Float, top: Float, color: String = "#A16207", width: Float = 1.8) {
    var height = top - 0.4 + 1.2
    var k: Float = 0
    while height > 0.05 {
        let cx = x + dx * k * 0.55, cz = z + dz * k * 0.55
        m.slab("Ladder", x: cx, y: -1.2, z: cz, w: dx != 0 ? 0.55 : width, h: height, d: dz != 0 ? 0.55 : width, color: color)
        height -= 0.4
        k += 1
    }
}

func sharkBay(_ m: MapBuilder) {
    m.ocean()
    m.environment.killPlaneHeight = -40
    m.part("Cover Focus", at: (0, 0, -8), size: (64, 1, 1), color: "#000000", tags: ["yaw=200"], solid: false, visible: false)
    // A shallow bay: you can stand on the bottom, but wading is slow — and the shark is fast.
    m.ground(260, 260, color: "#155E75", name: "Sea Floor", y: -1.2, tags: ["seafloor"])
    m.water(0, 0, w: 260, d: 260, y: 0, name: "Bay Water", color: "#0284C7", depth: 1.2, tags: ["sea"])
    var r = Seeded("shark-bay")
    for _ in 0..<26 {
        let x = r.range(-110, 110), z = r.range(-110, 110)
        if abs(x) < 40 && abs(z) < 40 { continue }
        m.part("Seaweed", at: (x, -0.9, z), size: (0.4, 0.8, 0.4), color: "#15803D", shape: .cone, solid: false)
    }
    // The dock with the armory, and a pier out toward the boats.
    m.slab("Dock", x: 0, y: -1.2, z: -70, w: 40, h: 1.8, d: 14, color: "#A16207", tags: ["dock"])
    m.slab("Pier", x: 0, y: -1.2, z: -50, w: 3.2, h: 1.8, d: 26, color: "#B45309", tags: ["dock"])
    for z: Float in [-60, -52, -44, -38] {
        m.pillar("Pier Post", x: -1.8, z: z, y: -1.2, height: 2.8, radius: 0.18, color: "#78350F")
        m.pillar("Pier Post", x: 1.8, z: z, y: -1.2, height: 2.8, radius: 0.18, color: "#78350F")
    }
    seaLadder(m, x: 0, z: -36.6, dx: 0, dz: 1, top: 0.6)
    seaLadder(m, x: -14, z: -62.7, dx: 0, dz: 1, top: 0.6)
    seaLadder(m, x: 14, z: -62.7, dx: 0, dz: 1, top: 0.6)
    m.spawnRing(0, -70, y: 0.6, radius: 6, count: 10, color: "#FDE68A")
    m.house("Armory", x: -13, z: -73, w: 8, d: 6, h: 3.4, y: 0.6, wall: "#1E3A8A", roof: "#DC2626", floor: "#78350F", door: false, tags: ["armory"])
    m.part("Armory Sign", at: (-13, 4.7, -69.6), size: (5, 0.9, 0.2), color: "#FACC15", material: .neon, solid: false)
    m.pad("Armory Pad", x: -13, z: -68.2, y: 0.6, size: 2.6, color: "#FACC15", tags: ["armory"])
    for (k, x) in ([8, 12, 16] as [Float]).enumerated() {
        m.slab("Barrel", x: x, y: 0.6, z: -75, w: 1, h: 1.3, d: 1, color: ["#DC2626", "#2563EB", "#16A34A"][k])
    }
    // Six boats round the middle, each with a ladder at both ends.
    let boatColors = ["#EF4444", "#3B82F6", "#FACC15", "#22C55E", "#F97316", "#A855F7"]
    for (i, q) in ring(6, radius: 26, phase: .pi / 6).enumerated() {
        let n = i + 1
        m.slab("Boat \(n)", x: q.0, y: -0.9, z: q.1, w: 5, h: 1.3, d: 9, color: boatColors[i], tags: ["boat"])
        m.slab("Boat \(n) Deck", x: q.0, y: 0.4, z: q.1, w: 4.2, h: 0.05, d: 8.2, color: "#F5F5F4", tags: ["boatpart"])
        for sx: Float in [-1, 1] {
            m.slab("Boat \(n) Rail", x: q.0 + sx * 2.35, y: 0.4, z: q.1, w: 0.3, h: 0.7, d: 7, color: "#FFFFFF", tags: ["boatpart"])
        }
        m.part("Boat \(n) Mast", at: (q.0, 2.8, q.1 + 2), size: (0.2, 4.8, 0.2), color: "#78350F", shape: .cylinder, tags: ["boatpart"], solid: false)
        m.part("Boat \(n) Flag", at: (q.0 + 0.5, 4.8, q.1 + 2), size: (1, 0.6, 0.05), color: boatColors[i], tags: ["boatpart"], solid: false)
        seaLadder(m, x: q.0, z: q.1 + 4.78, dx: 0, dz: 1, top: 0.4, color: "#F5F5F4", width: 1.6)
        seaLadder(m, x: q.0, z: q.1 - 4.78, dx: 0, dz: -1, top: 0.4, color: "#F5F5F4", width: 1.6)
    }
    // Buoys, the shark's den far out, the lighthouse where the fallen watch and cheer.
    for q in ring(10, radius: 50, phase: 0.2) {
        m.part("Buoy", at: (q.0, 0.3, q.1), size: (1, 1, 1), color: "#DC2626", shape: .sphere, solid: false)
        m.part("Buoy Top", at: (q.0, 1, q.1), size: (0.3, 0.8, 0.3), color: "#F8FAFC", shape: .cylinder, solid: false)
    }
    m.part("Shark Den", at: (0, -1.2, 70), size: (1, 0.2, 1), color: "#000000", solid: false, visible: false)
    m.part("Rock Island", at: (62, -0.5, 58), size: (18, 3, 16), color: "#78716C", shape: .sphere, material: .matte)
    m.pillar("Lighthouse", x: 62, z: 58, y: 0.6, height: 14, radius: 2.2, color: "#F8FAFC", tags: ["lighthouse"])
    for k in 0..<3 {
        m.part("Lighthouse Stripe", at: (62, 3 + Float(k) * 4.2, 58), size: (4.5, 1, 4.5), color: "#DC2626", shape: .cylinder, solid: false)
    }
    m.slab("Lighthouse Top", x: 62, y: 14.6, z: 58, w: 9, h: 0.5, d: 9, color: "#475569")
    m.walls(62, 58, w: 9, d: 9, h: 1, y: 15.1, color: "#94A3B8", thickness: 0.3, name: "Lighthouse Rail")
    m.part("Lighthouse Lamp", at: (62, 17, 58), size: (2, 2, 2), color: "#FDE047", shape: .sphere, material: .neon, solid: false)
    m.part("Lighthouse Seat", at: (62, 15.4, 58), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)
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
