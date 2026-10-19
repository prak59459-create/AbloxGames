import Foundation

// 231–: games from the suggestion box (みんなのアイデア). Each one started as a
// player's idea; the game itself is original.

let ideaGames: [Game] = [
    Game(number: 231, id: "lucky-chip-party", title: "Lucky Chip Party",
         summary: "4人でテーブルをかこむ ゲームショー！ サイコロ・カード・ルーレット・どうぶつレース・ブラフ・ばくだんカード・カップシャッフル・ふうせん・あみだくじ・つり大会・じゃんけん・多数決・ひみつの入札・🎯ストップメーター・⏱ぴったり5びょう…など 25種類のミニゲームで チップをかけて ふやせ。毎回ちがうゲームが出る。ひみつのヒント、レイズとブラフ、0になったら OUT。たりない席には BOT（チップは このゲームの中だけのもの）",
         tags: ["party", "cards", "dice", "bluff"], maxPlayers: 8, build: luckyChipParty),
    Game(number: 232, id: "sky-thread-city", title: "Sky Thread City",
         summary: "糸のヒーロー「スレッドランナー」になって、たて1000m の大都会を 🕸 スイング・🧗 かべのぼり・⚡ ジップで かけまわれ！ 超高層ビル・ランドマークタワー・公園・港・駐車場。どろぼうロボを ネットでつかまえ、屋上の 🆘 をたすけ、💎 スカイトークン60こと スイングレースに挑戦。スーツと ロープの強化も",
         tags: ["superhero", "open-world", "swing", "city"], maxPlayers: 12, build: skyThreadCity),
]

// MARK: 231 Lucky Chip Party

func luckyChipParty(_ m: MapBuilder) {
    m.indoor(ground: "#1E1033")
    m.sky("#120A24", "#2A1450", light: 0.62, showGround: false, sunPitch: -50, fall: -20)
    m.part("Cover Focus", at: (0, 2, -3), size: (34, 1, 1), color: "#000000", tags: ["yaw=20", "pitch=30"], solid: false, visible: false)

    // The studio: carpet, walls with neon strips, a truss of lights overhead.
    m.ground(64, 72, color: "#3B0764", name: "Studio Floor")
    m.part("Carpet Ring", at: (0, 0.02, 0), size: (26, 0.04, 26), color: "#7C2D12", shape: .cylinder, material: .matte, solid: false)
    m.part("Carpet Inner", at: (0, 0.03, 0), size: (22, 0.04, 22), color: "#B91C1C", shape: .cylinder, material: .matte, solid: false)
    m.walls(0, 0, w: 64, d: 72, h: 14, color: "#1E1B4B", name: "Studio Wall")
    for (i, x) in stride(from: Float(-28), through: 28, by: 8).enumerated() {
        let color = ["#F472B6", "#22D3EE", "#FDE047", "#A78BFA"][i % 4]
        m.part("Wall Neon", at: (x, 7, -35.4), size: (0.4, 10, 0.2), color: color, material: .neon, solid: false)
        m.part("Wall Neon", at: (x, 7, 35.4), size: (0.4, 10, 0.2), color: color, material: .neon, solid: false)
    }
    for z: Float in [-24, -8, 8, 24] {
        m.part("Wall Neon", at: (-31.4, 7, z), size: (0.2, 10, 0.4), color: "#F472B6", material: .neon, solid: false)
        m.part("Wall Neon", at: (31.4, 7, z), size: (0.2, 10, 0.4), color: "#22D3EE", material: .neon, solid: false)
    }
    for (x, z) in grid(3, 4, spacing: 12) where abs(z) < 30 {
        m.part("Spot Lamp", at: (x, 12.4, z), size: (1.2, 1.2, 1.2), color: "#FEF9C3", shape: .cone, material: .neon, solid: false,
               rotation: (180, 0, 0))
    }

    // The table: felt, a wooden rim, a pedestal, and the roulette ring
    // printed on the felt.
    m.part("Table Foot", at: (0, 0.25, 0), size: (4, 0.5, 4), color: "#451A03", shape: .cylinder, material: .wood)
    m.part("Table Leg", at: (0, 0.8, 0), size: (1.6, 1.2, 1.6), color: "#78350F", shape: .cylinder, material: .wood)
    m.part("Table Rim", at: (0, 1.1, 0), size: (11.8, 0.4, 11.8), color: "#92400E", shape: .cylinder, material: .wood)
    m.part("Table Felt", at: (0, 1.18, 0), size: (10.8, 0.25, 10.8), color: "#15803D", shape: .cylinder, material: .matte)
    m.part("Felt Line", at: (0, 1.31, 0), size: (7.4, 0.02, 7.4), color: "#FDE68A", shape: .cylinder, material: .matte, solid: false)
    m.part("Felt Inner", at: (0, 1.32, 0), size: (7.0, 0.02, 7.0), color: "#166534", shape: .cylinder, material: .matte, solid: false)
    let wheel = ["red", "blue", "red", "blue", "red", "blue", "red", "blue", "red", "blue", "gold", "rainbow"]
    let wheelColor = ["red": "#DC2626", "blue": "#2563EB", "gold": "#FACC15", "rainbow": "#E879F9"]
    for (i, p) in ring(12, radius: 3.0, phase: -.pi / 2).enumerated() {
        m.part("Slot \(i + 1)", at: (p.0, 1.34, p.1), size: (0.95, 0.06, 0.95), color: wheelColor[wheel[i]] ?? "#FFFFFF",
               shape: .cylinder, material: wheel[i] == "red" || wheel[i] == "blue" ? .plastic : .neon, solid: false)
    }
    m.part("Wheel Light", at: (0, 1.75, -3), size: (0.7, 0.7, 0.7), color: "#FFFFFF", shape: .sphere, material: .neon,
           solid: false, visible: false)
    m.part("Pot", at: (0, 1.45, 0), size: (1.3, 0.3, 1.3), color: "#FACC15", shape: .cylinder, material: .metal,
           solid: false, visible: false)

    // Piles of chips between the seats, for the look.
    let chipColors = ["#DC2626", "#2563EB", "#16A34A", "#111827", "#F8FAFC"]
    for (i, p) in ring(4, radius: 4.4, phase: .pi / 4).enumerated() {
        for level in 0..<(3 + i % 3) {
            m.part("Chip Pile", at: (p.0 + Float(level % 2) * 0.05, 1.37 + Float(level) * 0.13, p.1), size: (0.7, 0.12, 0.7),
                   color: chipColors[(i + level) % chipColors.count], shape: .cylinder, solid: false)
        }
        m.part("Chip Pile", at: (p.0 + 0.75, 1.37, p.1 - 0.2), size: (0.7, 0.12, 0.7), color: chipColors[(i + 2) % chipColors.count],
               shape: .cylinder, solid: false)
    }

    // What each round puts on the table (scripts show and hide them).
    m.part("Die 1", at: (-0.9, 1.85, 0.4), size: (0.9, 0.9, 0.9), color: "#F8FAFC", solid: false, visible: false)
    m.part("Die 2", at: (0.9, 1.85, 0.4), size: (0.9, 0.9, 0.9), color: "#F8FAFC", solid: false, visible: false)
    m.part("Card 1", at: (-1.1, 2.5, 0), size: (1.5, 2.1, 0.12), color: "#FFFFFF", solid: false, visible: false)
    m.part("Card 2", at: (1.1, 2.5, 0), size: (1.5, 2.1, 0.12), color: "#1E3A8A", solid: false, visible: false)
    for (k, x) in [Float(-2.3), 0, 2.3].enumerated() {
        let color = ["#DC2626", "#16A34A", "#2563EB"][k]
        m.part("Box \(k + 1)", at: (x, 1.95, 0.6), size: (1.3, 1.3, 1.3), color: color, solid: false, visible: false)
        m.part("Box Lid \(k + 1)", at: (x, 2.68, 0.6), size: (1.45, 0.2, 1.45), color: "#FDE047", material: .metal,
               solid: false, visible: false)
    }
    m.part("Deck", at: (0, 1.6, 1.6), size: (1.0, 0.5, 1.4), color: "#7F1D1D", solid: false, visible: false)
    m.part("Coin", at: (0, 2.3, 0), size: (1.4, 0.18, 1.4), color: "#FACC15", shape: .cylinder, material: .metal,
           solid: false, visible: false, rotation: (90, 0, 0))
    m.part("Big Balloon", at: (0, 2.1, 0), size: (0.8, 0.95, 0.8), color: "#F472B6", shape: .sphere, material: .glass,
           solid: false, visible: false)

    // Four seats: a podium, a stand for the player, a stack of chips on the
    // table and a sign that shows the chips.
    let seatColors = ["#EF4444", "#3B82F6", "#22C55E", "#F59E0B"]
    let seats: [(Float, Float)] = [(0, 8.6), (8.6, 0), (0, -8.6), (-8.6, 0)]
    for (k, s) in seats.enumerated() {
        let n = k + 1
        let dx = s.0 / 8.6, dz = s.1 / 8.6
        let across = abs(dx) > 0.5
        m.part("Seat \(n)", at: (s.0, 0.1, s.1), size: (2.4, 0.2, 2.4), color: seatColors[k], shape: .cylinder, material: .neon)
        let podium = (dx * 7.0, dz * 7.0)
        m.slab("Podium \(n)", x: podium.0, y: 0, z: podium.1, w: across ? 0.9 : 3.2, h: 1.3, d: across ? 3.2 : 0.9, color: "#1F2937",
               material: .metal)
        m.part("Podium Glow \(n)", at: (podium.0, 1.33, podium.1), size: (across ? 1.0 : 3.3, 0.08, across ? 3.3 : 1.0),
               color: seatColors[k], material: .neon, solid: false)
        m.part("Podium Face \(n)", at: (podium.0 + dx * 0.47, 0.7, podium.1 + dz * 0.47),
               size: (across ? 0.05 : 2.6, 0.7, across ? 2.6 : 0.05), color: seatColors[k], material: .neon, solid: false, opacity: 0.8)
        m.part("Stack \(n)", at: (dx * 4.3, 1.6, dz * 4.3), size: (0.9, 0.6, 0.9), color: "#FACC15", shape: .cylinder, material: .metal,
               solid: false)
        let sign = m.part("Seat Sign \(n)", at: (dx * 7.0, 2.2, dz * 7.0), size: (0.3, 0.3, 0.3), color: seatColors[k], shape: .sphere,
                          material: .neon, solid: false)
        m.label(sign, [("\(["レッド", "ブルー", "グリーン", "イエロー"][k]) の席", seatColors[k]), ("あいています", "#CBD5E1")],
                height: 0.6, size: 1.1, range: 80)
    }

    // The big board behind the race track, and the sign over it.
    m.slab("Board Back", x: 0, y: 2, z: -32, w: 26, h: 9, d: 0.6, color: "#0F172A")
    m.part("Board Screen", at: (0, 6.5, -31.6), size: (24, 7.6, 0.1), color: "#1E1B4B", solid: false)
    for (y, h) in [(Float(2.6), Float(0.3)), (10.4, 0.3)] {
        m.part("Board Frame", at: (0, y, -31.5), size: (24.6, h, 0.12), color: "#F472B6", material: .neon, solid: false)
    }
    for x: Float in [-12.2, 12.2] {
        m.part("Board Frame", at: (x, 6.5, -31.5), size: (0.3, 8, 0.12), color: "#F472B6", material: .neon, solid: false)
    }
    for (i, x) in stride(from: Float(-10), through: 10, by: 2.5).enumerated() {
        m.part("Board Bulb", at: (x, 10.9, -31.4), size: (0.5, 0.5, 0.5), color: i % 2 == 0 ? "#FDE047" : "#FFFFFF", shape: .sphere,
               material: .neon, solid: false)
    }
    let boardText = m.part("Board Text", at: (0, 5.4, -31.4), size: (0.4, 0.4, 0.4), color: "#4C1D95", solid: false, opacity: 0.05)
    m.label(boardText, [("🎰 ラッキーチップ・パーティー", "#FDE047"), ("まもなく はじまります", "#FFFFFF")], height: 0.4, size: 2.0, range: 120)
    let title = m.part("Title Sign", at: (0, 11.6, -31.4), size: (0.4, 0.4, 0.4), color: "#000000", solid: false, opacity: 0.05)
    m.label(title, [("LUCKY CHIP PARTY", "#F472B6")], height: 0.2, size: 2.6, range: 140)
    for x: Float in [-13.5, 13.5] {
        m.pillar("Board Pillar", x: x, z: -31.5, height: 11.4, radius: 0.5, color: "#FDE047", material: .neon)
    }

    // The race track: four lanes, a start and a finish.
    m.slab("Track", x: 0, y: 0, z: -21, w: 28, h: 0.15, d: 8.4, color: "#A16207", material: .sand)
    let racerColors = ["#16A34A", "#F9A8D4", "#A16207", "#94A3B8"]
    for k in 0..<4 {
        let z = -18 - Float(k) * 2
        m.part("Lane \(k + 1)", at: (0, 0.17, z), size: (26, 0.02, 1.6), color: k % 2 == 0 ? "#CA8A04" : "#B45309", material: .matte,
               solid: false)
        m.part("Racer \(k + 1)", at: (-11, 0.6, z), size: (0.9, 0.9, 0.9), color: racerColors[k], shape: .sphere, solid: false)
    }
    m.part("Start Line", at: (-11.6, 0.18, -21), size: (0.25, 0.02, 8.2), color: "#FFFFFF", solid: false)
    for k in 0..<8 {
        m.part("Finish Line", at: (11.2, 0.18, -17.5 - Float(k)), size: (0.5, 0.03, 1), color: k % 2 == 0 ? "#111827" : "#F8FAFC",
               solid: false)
    }
    m.slab("Track Rail", x: 0, y: 0, z: -16.6, w: 28, h: 0.6, d: 0.3, color: "#FDE68A")
    m.slab("Track Rail", x: 0, y: 0, z: -25.4, w: 28, h: 0.6, d: 0.3, color: "#FDE68A")

    // The audience: three rows of benches facing the table, and the spawn.
    for row in 0..<3 {
        let y = Float(row) * 0.9
        m.slab("Gallery Step", x: 0, y: 0, z: 25 + Float(row) * 2.4, w: 30, h: y + 0.9, d: 2.4, color: row % 2 == 0 ? "#312E81" : "#3730A3")
        for x in stride(from: Float(-12), through: 12, by: 4) {
            m.slab("Bench", x: x, y: y + 0.9, z: 25.6 + Float(row) * 2.4, w: 3, h: 0.4, d: 0.8, color: "#F472B6")
        }
    }
    m.spawnRing(0, 18.5, radius: 3.4, count: 8, name: "Lobby Spawn", color: "#FDE047")
    let welcome = m.part("Welcome Sign", at: (0, 3.6, 15.5), size: (0.3, 0.3, 0.3), color: "#000000", solid: false, opacity: 0.05)
    m.label(welcome, [("🎰 ショーは 自動ではじまる", "#FDE047"), ("たりない席には 🤖 BOT", "#C4B5FD")], height: 0.2, size: 1.2, range: 50)

    // Party decoration: balloons, confetti cannons and big chips.
    let balloon = ["#F472B6", "#60A5FA", "#FDE047", "#34D399", "#C084FC"]
    for (i, p) in ring(10, radius: 14.5).enumerated() where abs(p.1 + 21) > 6 {
        m.part("Balloon String", at: (p.0, 2.4, p.1), size: (0.05, 4.8, 0.05), color: "#E5E7EB", shape: .cylinder, solid: false)
        let b = m.part("Balloon", at: (p.0, 5.2, p.1), size: (1.1, 1.3, 1.1), color: balloon[i % balloon.count], shape: .sphere,
                       material: .glass, solid: false)
        m.animate(b, .sway, speed: 0.6)
    }
    for (x, z) in [(-26, -10), (26, -10), (-26, 12), (26, 12)] as [(Float, Float)] {
        m.part("Confetti Cannon", at: (x, 1.2, z), size: (1.2, 2.4, 1.2), color: "#1F2937", shape: .cylinder, material: .metal)
        m.part("Cannon Ring", at: (x, 2.5, z), size: (1.4, 0.3, 1.4), color: "#F472B6", shape: .cylinder, material: .neon, solid: false)
    }
    for (i, p) in [(-20, -2), (20, 2), (-18, 8), (18, -8)].enumerated() {
        let chip = m.part("Giant Chip", at: (Float(p.0), 1.6, Float(p.1)), size: (3, 0.5, 3), color: ["#DC2626", "#2563EB", "#16A34A", "#F59E0B"][i],
                          shape: .cylinder, material: .plastic, solid: false, rotation: (90, Float(i) * 40, 0))
        m.animate(chip, .spin, speed: 0.3)
    }
}

// MARK: 232 Sky Thread City
//
// A city 1000 m long and 100 m deep: one avenue down the middle, a cross
// street every 80 m, and a lot on each side between them. West to east: the
// harbour (warehouses, cranes, water), downtown (skyscrapers and the Sky
// Needle), the park, and uptown (lower towers and parking lots). Every
// building's body is tagged "building", which is what the scripts climb and
// swing from.

func skyThreadCity(_ m: MapBuilder) {
    // An island city: the sea all round, a far skyline across the water.
    m.day(ground: "#1D6FB8")
    m.sky("#4F9DFF", "#DCEBFF", light: 0.78, ground: "#1D6FB8", sunPitch: -38, fall: -30)
    m.part("Cover Focus", at: (-90, 45, 0), size: (240, 1, 1), color: "#000000", tags: ["yaw=72", "pitch=16"], solid: false, visible: false)
    var rng = Seeded("sky-thread-city")

    // The ground, the seawall, the avenue and the cross streets.
    m.ground(1010, 112, color: "#52525B", name: "City Ground", material: .stone)
    for side: Float in [-1, 1] {
        m.slab("Seawall", x: 0, y: 0, z: side * 56.4, w: 1012, h: 1.2, d: 0.8, color: "#D6D3D1", material: .stone)
        m.slab("Seawall", x: side * 505.4, y: 0, z: 0, w: 0.8, h: 1.2, d: 113.6, color: "#D6D3D1", material: .stone)
    }
    for side: Float in [-1, 1] {
        for k in 0..<12 {
            let x = -460 + Float(k) * 84 + rng.range(-20, 20)
            let h = rng.range(30, 95)
            m.slab("Far City", x: x, y: 0, z: side * rng.range(230, 260), w: rng.range(30, 60), h: h * 1.3, d: 30,
                   color: rng.pick(["#94A3B8", "#A5B4FC", "#CBD5E1", "#7DD3FC"]), material: .matte, solid: false)
        }
    }
    m.road(from: (-505, 0), to: (505, 0), width: 16, name: "Avenue", dashed: false, color: "#27272A")
    for x in stride(from: Float(-490), through: 490, by: 20) {
        m.part("Avenue Line", at: (x, 0.06, 0), size: (8, 0.02, 0.3), color: "#FACC15", material: .neon, solid: false)
    }
    for side: Float in [-1, 1] {
        m.slab("Sidewalk", x: 0, y: 0, z: side * 9.6, w: 1010, h: 0.25, d: 3.2, color: "#A1A1AA", material: .stone)
    }
    let crossings = stride(from: Float(-480), through: 480, by: 80).map { $0 }
    for x in crossings {
        m.road(from: (x, -56), to: (x, 56), width: 12, y: 0.03, name: "Cross Street", dashed: false, color: "#27272A")
        for side: Float in [-1, 1] {
            for k in 0..<4 {
                m.part("Crosswalk", at: (x - 4.5 + Float(k) * 3, 0.07, side * 6.2), size: (1.6, 0.02, 3.2), color: "#F4F4F5", solid: false)
            }
        }
    }
    // Lamps down both sidewalks.
    for x in stride(from: Float(-470), through: 470, by: 40) {
        for side: Float in [-1, 1] {
            m.part("Lamp Post", at: (x, 3, side * 8.4), size: (0.25, 6, 0.25), color: "#3F3F46", shape: .cylinder, material: .metal)
            m.part("Lamp Light", at: (x, 6.2, side * 7.6), size: (0.9, 0.3, 1.6), color: "#FEF3C7", material: .neon, solid: false)
        }
    }

    // A building: a body to climb, glass bands, a rim, sometimes a setback
    // top and something on the roof. Returns the roof height.
    // Three looks: a glass tower with floor plates, stone with window
    // bands, and brick with light trim.
    func building(_ x: Float, _ z: Float, w: Float, d: Float, h: Float, color: String, glass: String, setback: Bool) -> Float {
        let style = rng.int(0, 2)
        let material: MaterialKind = style == 0 ? .glass : style == 1 ? .stone : .brick
        let body = style == 0 ? rng.pick(["#7DD3FC", "#93C5FD", "#A5F3FC", "#C4B5FD", "#99F6E4"]) : style == 2
            ? rng.pick(["#B45309", "#9A3412", "#A16207", "#7C2D12"]) : color
        let bands = style == 0 ? "#F1F5F9" : style == 2 ? "#FEF3C7" : glass
        m.slab("Building", x: x, y: 0, z: z, w: w, h: h, d: d, color: body, material: material, tags: ["building"])
        var y: Float = style == 0 ? 6 : 5
        while y < h - 3 {
            m.part("Window Band", at: (x, y, z), size: (w + 0.14, style == 0 ? 0.5 : 1.6, d + 0.14), color: bands,
                   material: style == 1 ? .glass : .plastic, solid: false)
            y += style == 0 ? 8 : 7
        }
        // Shop fronts at street level.
        m.part("Shop Front", at: (x, 2, z + (z > 0 ? -1 : 1) * (d / 2 + 0.08)), size: (w * 0.8, 3, 0.1),
               color: rng.pick(["#FDE68A", "#FBCFE8", "#BBF7D0", "#BAE6FD"]), material: .neon, solid: false, opacity: 0.85)
        m.slab("Roof Rim", x: x, y: h, z: z, w: w + 0.4, h: 0.5, d: d + 0.4, color: MapBuilder.shade(color, -0.25),
               tags: ["building"])
        var top = h + 0.5
        if setback && h > 50 {
            let th = rng.range(10, 24)
            m.slab("Building", x: x, y: top, z: z, w: w * 0.6, h: th, d: d * 0.6, color: MapBuilder.shade(color, 0.08),
                   material: .stone, tags: ["building"])
            m.part("Window Band", at: (x, top + th * 0.5, z), size: (w * 0.6 + 0.12, 1.4, d * 0.6 + 0.12), color: glass,
                   material: .glass, solid: false)
            top += th
            m.part("Antenna", at: (x, top + 6, z), size: (0.4, 12, 0.4), color: "#E5E7EB", shape: .cylinder, material: .metal)
            m.part("Antenna Light", at: (x, top + 12.3, z), size: (0.8, 0.8, 0.8), color: "#EF4444", shape: .sphere, material: .neon,
                   solid: false)
            return top
        }
        switch rng.int(0, 3) {
        case 0:
            // A water tower on legs.
            let tx = x + w * 0.2, tz = z - d * 0.2
            for (lx, lz) in [(-0.9, -0.9), (0.9, -0.9), (-0.9, 0.9), (0.9, 0.9)] as [(Float, Float)] {
                m.part("Tower Leg", at: (tx + lx, top + 1.5, tz + lz), size: (0.2, 3, 0.2), color: "#57534E", shape: .cylinder)
            }
            m.part("Water Tower", at: (tx, top + 4.2, tz), size: (3, 2.6, 3), color: "#A16207", shape: .cylinder, material: .wood,
                   tags: ["building"])
            m.part("Water Tower Roof", at: (tx, top + 6.1, tz), size: (3.2, 1.2, 3.2), color: "#57534E", shape: .cone)
        case 1:
            m.slab("Roof Unit", x: x - w * 0.2, y: top, z: z + d * 0.15, w: 3, h: 1.6, d: 2.2, color: "#9CA3AF", material: .metal)
            m.slab("Roof Unit", x: x + w * 0.15, y: top, z: z - d * 0.2, w: 2.2, h: 1.2, d: 2.2, color: "#9CA3AF", material: .metal)
        case 2:
            // A billboard facing the avenue.
            let face: Float = z > 0 ? -1 : 1
            let colors = ["#F472B6", "#22D3EE", "#FACC15", "#A78BFA", "#34D399"]
            m.slab("Billboard Frame", x: x, y: top, z: z + face * d * 0.3, w: w * 0.7, h: 0.6, d: 0.4, color: "#3F3F46", material: .metal)
            m.part("Billboard", at: (x, top + 3.4, z + face * d * 0.3), size: (w * 0.7, 5, 0.3), color: rng.pick(colors), material: .neon,
                   solid: false)
        default:
            m.part("Helipad", at: (x, top + 0.06, z), size: (min(w, d) * 0.6, 0.1, min(w, d) * 0.6), color: "#FDE047", shape: .cylinder,
                   material: .neon, solid: false)
        }
        return top
    }

    var roofs: [(x: Float, y: Float, z: Float)] = []
    let palettes: [(String, String)] = [("#E7E5E4", "#1E3A8A"), ("#FDE68A", "#1E40AF"), ("#FECACA", "#334155"), ("#D9F99D", "#14532D"),
                                        ("#CBD5E1", "#0F172A"), ("#F5F5F4", "#0E7490"), ("#FED7AA", "#7C2D12"), ("#E0E7FF", "#312E81")]

    func parkingLot(_ x: Float, _ z: Float, w: Float, d: Float, name: String) {
        m.part(name, at: (x, 0.05, z), size: (w, 0.06, d), color: "#3F3F46", material: .matte, solid: false)
        let rows: [Float] = [z - d * 0.22, z + d * 0.22]
        for (r, rz) in rows.enumerated() {
            for k in 0..<7 {
                let px = x - w * 0.42 + Float(k) * (w * 0.84 / 6)
                m.part("Parking Line", at: (px, 0.1, rz), size: (0.2, 0.02, 5), color: "#F4F4F5", solid: false)
                if k < 6, rng.int(0, 2) > 0 {
                    let colors = ["#DC2626", "#2563EB", "#F8FAFC", "#111827", "#16A34A", "#F59E0B"]
                    m.parkedCar("Parked Car", x: px + w * 0.07, z: rz, yaw: r == 0 ? 0 : 180, color: rng.pick(colors), sporty: rng.int(0, 4) == 0)
                }
            }
        }
        for (lx, lz) in [(x - w * 0.45, z), (x + w * 0.45, z)] {
            m.part("Lot Lamp", at: (lx, 4, lz), size: (0.3, 8, 0.3), color: "#3F3F46", shape: .cylinder, material: .metal)
            m.part("Lot Light", at: (lx, 8.2, lz), size: (1.4, 0.3, 1.4), color: "#FEF3C7", material: .neon, solid: false)
        }
        let sign = m.part("Parking Sign", at: (x - w * 0.45, 9.4, z), size: (1.6, 1.6, 0.2), color: "#2563EB", material: .neon, solid: false)
        m.label(sign, [("🅿️ パーキング", "#FFFFFF")], height: 0.3, size: 0.9, range: 50)
    }

    // The lots between the cross streets, west to east.
    for k in 0..<12 {
        let cx = -440 + Float(k) * 80
        for side: Float in [-1, 1] {
            let cz = side * 30.5
            let district: String
            if cx < -330 { district = "harbor" } else if cx < 170 { district = "downtown" } else if cx < 330 { district = "park" } else { district = "uptown" }
            if district == "park" && side > 0 {
                continue // the park is built below
            }
            if (k == 1 && side < 0) || (k == 6 && side > 0) || (k == 10 && side < 0) || (k == 11 && side > 0) {
                parkingLot(cx, cz, w: 62, d: 34, name: "Parking Lot")
                continue
            }
            if district == "harbor" {
                // Warehouses, low and wide.
                let h = rng.range(9, 16)
                let top = building(cx - 14, cz, w: 30, d: 30, h: h, color: rng.pick(["#92400E", "#57534E", "#1E40AF"]), glass: "#E7E5E4",
                                   setback: false)
                roofs.append((cx - 14, top, cz))
                let h2 = rng.range(12, 22)
                let top2 = building(cx + 18, cz + side * 2, w: 24, d: 26, h: h2, color: rng.pick(["#B45309", "#44403C", "#0F766E"]),
                                    glass: "#FDE68A", setback: false)
                roofs.append((cx + 18, top2, cz + side * 2))
                continue
            }
            if cx == -40 && side > 0 {
                continue // the Sky Needle's plaza
            }
            let tall = district == "downtown"
            let count = tall ? rng.int(2, 3) : rng.int(2, 4)
            let width = 62 / Float(count)
            for b in 0..<count {
                let bx = cx - 31 + width * (Float(b) + 0.5)
                let h = tall ? rng.range(45, 125) : rng.range(18, 48)
                let (color, glass) = rng.pick(palettes)
                let depth = rng.range(22, 30)
                let top = building(bx, cz + side * rng.range(-1.5, 1.5), w: width - rng.range(3, 6), d: depth, h: h, color: color,
                                   glass: glass, setback: tall && rng.int(0, 2) > 0)
                roofs.append((bx, top, cz))
            }
        }
    }

    // The Sky Needle: the tallest thing in the city, with a deck to stand on.
    let needle: (Float, Float) = (-40, 30)
    m.slab("Needle Plaza", x: needle.0, y: 0, z: needle.1, w: 60, h: 0.3, d: 34, color: "#D6D3D1", material: .stone)
    m.slab("Needle Base", x: needle.0, y: 0, z: needle.1, w: 18, h: 26, d: 18, color: "#CBD5E1", material: .stone, tags: ["building"])
    m.part("Needle Shaft", at: (needle.0, 26 + 70, needle.1), size: (8, 140, 8), color: "#E2E8F0", shape: .cylinder, material: .metal,
           tags: ["building"])
    m.part("Needle Deck", at: (needle.0, 166, needle.1), size: (26, 3, 26), color: "#94A3B8", shape: .cylinder, material: .metal,
           tags: ["building"])
    m.part("Needle Glass", at: (needle.0, 168.6, needle.1), size: (24, 2.2, 24), color: "#7DD3FC", shape: .cylinder, material: .glass,
           solid: false, opacity: 0.5)
    m.part("Needle Roof", at: (needle.0, 170.5, needle.1), size: (26, 1.4, 26), color: "#64748B", shape: .cylinder, material: .metal,
           tags: ["building"])
    m.part("Needle Spire", at: (needle.0, 186, needle.1), size: (1.2, 30, 1.2), color: "#F8FAFC", shape: .cone, material: .metal)
    m.part("Needle Beacon", at: (needle.0, 201.5, needle.1), size: (1.4, 1.4, 1.4), color: "#EF4444", shape: .sphere, material: .neon,
           solid: false)
    for k in 0..<6 {
        m.part("Needle Ring", at: (needle.0, 40 + Float(k) * 20, needle.1), size: (9.4, 0.8, 9.4), color: "#38BDF8", shape: .cylinder,
               material: .neon, solid: false)
    }
    let needleSign = m.part("Needle Sign", at: (needle.0, 27, needle.1 - 9.2), size: (10, 2, 0.3), color: "#0EA5E9", material: .neon,
                            solid: false)
    m.label(needleSign, [("スカイニードル", "#FFFFFF"), ("てっぺんまで 200m", "#BAE6FD")], height: 0.3, size: 1.2, range: 90)
    roofs.append((needle.0, 172, needle.1))

    // The park: grass, paths, trees, a pond with a fountain.
    let park: (Float, Float) = (240, 30.5)
    m.slab("Park Lawn", x: park.0, y: 0, z: park.1, w: 148, h: 0.3, d: 39, color: "#4ADE80", material: .grass)
    m.slab("Park Path", x: park.0, y: 0.3, z: park.1, w: 148, h: 0.04, d: 3, color: "#D6D3D1", material: .stone)
    m.slab("Park Path", x: park.0, y: 0.3, z: park.1, w: 3, h: 0.04, d: 39, color: "#D6D3D1", material: .stone)
    m.water(park.0 + 35, park.1 + 8, w: 26, d: 14, y: 0.05, name: "Park Pond")
    m.part("Fountain", at: (park.0, 1.1, park.1), size: (6, 1.6, 6), color: "#E7E5E4", shape: .cylinder, material: .stone)
    m.part("Fountain Water", at: (park.0, 2.4, park.1), size: (1.2, 2.6, 1.2), color: "#7DD3FC", shape: .cylinder, material: .glass,
           solid: false, opacity: 0.7)
    for _ in 0..<26 {
        let tx = park.0 + rng.range(-66, 66), tz = park.1 + rng.range(-16, 16)
        if abs(tx - park.0) < 3 || abs(tz - park.1) < 3 || (abs(tx - park.0 - 35) < 15 && abs(tz - park.1 - 8) < 9) { continue }
        m.tree(tx, tz, y: 0.3, height: rng.range(3.5, 6))
    }
    for x: Float in [park.0 - 30, park.0 + 10, park.0 + 50] {
        m.slab("Park Bench", x: x, y: 0.3, z: park.1 - 2.6, w: 3, h: 0.5, d: 0.8, color: "#92400E", material: .wood)
    }

    // The harbour at the west end: water, piers and two cranes.
    m.water(-497, 0, w: 18, d: 112, y: 0.05, name: "Harbor Water")
    for z: Float in [-36, 0, 36] {
        m.slab("Pier", x: -493, y: 0, z: z, w: 12, h: 0.6, d: 6, color: "#78350F", material: .wood)
    }
    for z: Float in [-24, 24] {
        m.slab("Crane Tower", x: -470, y: 0, z: z, w: 3, h: 34, d: 3, color: "#F59E0B", material: .metal, tags: ["building"])
        m.slab("Crane Arm", x: -480, y: 34, z: z, w: 30, h: 1.6, d: 2, color: "#F59E0B", material: .metal, tags: ["building"])
        m.part("Crane Cable", at: (-492, 26, z), size: (0.15, 16, 0.15), color: "#1F2937", shape: .cylinder, solid: false)
        m.slab("Crane Box", x: -492, y: 15, z: z, w: 4, h: 3, d: 3, color: "#2563EB", material: .metal)
        roofs.append((-470, 35.6, z))
    }

    // The elevated rail along the south side of the avenue: something to
    // swing from over the street, and to run along.
    m.slab("Sky Rail", x: 0, y: 14, z: -11.8, w: 1000, h: 1, d: 2.8, color: "#6B7280", material: .metal, tags: ["building"])
    for x in stride(from: Float(-480), through: 480, by: 40) {
        m.slab("Rail Pillar", x: x + 20, y: 0, z: -11.8, w: 1.6, h: 14, d: 1.6, color: "#4B5563", material: .metal, tags: ["building"])
    }

    // Spawn: the plaza in front of the Sky Needle.
    m.spawnRing(-40, 6, y: 0.25, radius: 4, count: 8, name: "Hero Spawn", color: "#38BDF8")
    let hello = m.part("Hero Sign", at: (-40, 3, 11.2), size: (8, 1.6, 0.3), color: "#0EA5E9", material: .neon, solid: false)
    m.label(hello, [("🕸 スカイスレッド・シティ", "#FFFFFF"), ("ビルに向かって歩くと かべのぼり", "#BAE6FD")], height: 0.3, size: 1.0, range: 40)

    // Shops: the suit shop and the gadget lab on the plaza.
    m.pad("Suit Shop", x: -52, z: 6, y: 0.25, size: 3, color: "#F472B6", tags: ["shop"])
    let suitSign = m.part("Suit Shop Sign", at: (-52, 3.2, 7.8), size: (3.4, 1, 0.2), color: "#BE185D", material: .neon, solid: false)
    m.label(suitSign, [("👕 スーツ", "#FFFFFF")], height: 0.2, size: 0.9, range: 30)
    m.pad("Gadget Lab", x: -28, z: 6, y: 0.25, size: 3, color: "#A78BFA", tags: ["shop"])
    let labSign = m.part("Gadget Lab Sign", at: (-28, 3.2, 7.8), size: (3.4, 1, 0.2), color: "#6D28D9", material: .neon, solid: false)
    m.label(labSign, [("🔧 ガジェット", "#FFFFFF")], height: 0.2, size: 0.9, range: 30)

    // Street spots for the people walking and the robber robots running:
    // invisible markers on both sidewalks and down the cross streets.
    var spots: [(Float, Float)] = []
    for x in stride(from: Float(-470), through: 470, by: 30) {
        spots.append((x, 9.6))
        spots.append((x + 15, -9.6))
    }
    m.markers("Street Spot", points: spots, y: 0.25, color: "#000000", tags: ["spot"], visible: false, size: 0.6, behavior: .none)

    // Sky tokens: on rooftops, the Needle, the cranes and in the air
    // between towers. Touched to collect (each player keeps their own).
    var tokens: [V] = [(needle.0, 205, needle.1), (needle.0 + 10, 172.5, needle.1)]
    for r in roofs {
        tokens.append((r.x + rng.range(-4, 4), r.y + 1.6, r.z + rng.range(-4, 4)))
    }
    for k in 0..<22 {
        let x = -460 + Float(k) * 43 + rng.range(-8, 8)
        tokens.append((x, rng.range(18, 40), rng.range(-6, 6)))
    }
    for (i, t) in tokens.prefix(60).enumerated() {
        let id = m.part("Sky Token \(i + 1)", at: t, size: (1.2, 1.6, 1.2), color: "#22D3EE", shape: .sphere, material: .neon,
                        behavior: .trigger, tags: ["token"], solid: false)
        m.animate(id, .spin, speed: 1)
    }

    // Rescue spots: the edges of tall roofs (someone stuck up there).
    for (i, r) in roofs.filter({ $0.y > 30 }).prefix(24).enumerated() {
        m.part("Rescue Spot \(i + 1)", at: (r.x + 3, r.y + 0.2, r.z), size: (0.3, 0.3, 0.3), color: "#000000", tags: ["rescue"],
               solid: false, visible: false)
    }

    // Two swing races: gates in the air down the avenue.
    func race(_ id: String, from x0: Float, to x1: Float, gates: Int, color: String) {
        m.pad("Race \(id) Start", x: x0, z: id == "A" ? 4 : -4, y: 0.06, size: 4, color: color, tags: ["race"])
        let sign = m.part("Race \(id) Sign", at: (x0, 3.6, id == "A" ? 4 : -4), size: (0.4, 0.4, 0.4), color: color, solid: false,
                          opacity: 0.05)
        m.label(sign, [("🏁 スイングレース \(id)", "#FFFFFF"), ("のると スタート", color)], height: 0.2, size: 1.0, range: 40)
        for g in 0..<gates {
            let t = Float(g + 1) / Float(gates)
            let x = x0 + (x1 - x0) * t
            let y = 14 + 16 * sin(Float(g) * 1.3) + 10
            let z: Float = (g % 2 == 0 ? 1 : -1) * 3
            m.part("Race \(id) Gate \(g + 1)", at: (x, y, z), size: (1, 8, 8), color: color, material: .neon, behavior: .trigger,
                   tags: ["gate"], solid: false, opacity: 0.25)
            for (dy, dz, sy, sz) in [(Float(4.2), Float(0), Float(0.4), Float(8.8)), (-4.2, 0, 0.4, 8.8), (0, 4.2, 8.8, 0.4), (0, -4.2, 8.8, 0.4)] {
                m.part("Gate Frame", at: (x, y + dy, z + dz), size: (0.5, sy, sz), color: color, material: .neon, solid: false)
            }
        }
    }
    race("A", from: -70, to: 160, gates: 10, color: "#F97316")
    race("B", from: -300, to: 460, gates: 12, color: "#22C55E")
}
