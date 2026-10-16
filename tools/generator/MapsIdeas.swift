import Foundation

// 231–: games from the suggestion box (みんなのアイデア). Each one started as a
// player's idea; the game itself is original.

let ideaGames: [Game] = [
    Game(number: 231, id: "lucky-chip-party", title: "Lucky Chip Party",
         summary: "4人でテーブルをかこむ ゲームショー！ サイコロ・カード・ルーレット・どうぶつレース・コイン・ブラフ・ミステリーボックス・ばくだんカード・「わける？ひとりじめ？」の9種類で チップをかけて ふやせ。ひみつのヒント、レイズとブラフ、0になったら OUT。たりない席には BOT（チップは このゲームの中だけのもの）",
         tags: ["party", "cards", "dice", "bluff"], maxPlayers: 8, build: luckyChipParty),
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
