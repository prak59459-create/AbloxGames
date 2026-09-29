import Foundation

// Games 81–95: obbies, each after an obby that is popular on Roblox
// (docs/research-150.md). They run on lib/kit_obby.absc: numbered "Stage n"
// checkpoints, "Finish", falling back, skips and a stage select.

let obbyGames: [Game] = [
    Game(number: 88, id: "cart-ride-wonderland", title: "Cart Ride Wonderland",
         summary: "カートに乗って長〜いコースをどこまでも。花畑・鉱山・おかし・雪・火山をぬけてお城まで20の駅。スピードは自分で調節、ジャンプ台・電車のふみきり・落石・マグマの橋に注意！",
         tags: ["obby", "cart", "ride"], maxPlayers: 16, libs: ["obby", "move"], build: cartRideWonderland),
    Game(number: 87, id: "easy-peasy-obby", title: "Easy Peasy Obby",
         summary: "小さい子でもクリアできる、とってもやさしい100ステージ。草原・おかし・ビーチ・雪・宇宙など10のワールド。ついてくるペット、ワールドごとのシールとぼうし、コイン集め。",
         tags: ["obby", "easy", "kids"], maxPlayers: 16, libs: ["obby"], build: easyPeasyObby),
    Game(number: 86, id: "speeding-wall-survival", title: "Speeding Wall Survival",
         summary: "どんどん速くなるカベがつっこんでくる！ すきまに入る・とびこえる・キノコで小さくなって穴をくぐる。ニセモノのカベにだまされるな。最後の1人まで生きのこれ。",
         tags: ["survival", "party", "dodge"], maxPlayers: 16, libs: ["rounds", "move"], build: speedingWallSurvival),
    Game(number: 85, id: "trap-master-run", title: "Trap Master Run",
         summary: "1人がワナ師、ほかはランナー。ワナ師はバルコニーから10このワナ（落とし穴・トゲ・大岩・つぶし天井・矢…）を動かす。ランナーはゴールしたら剣でワナ師にしかえし！",
         tags: ["obby", "pvp", "traps"], maxPlayers: 12, libs: ["rounds", "move"], build: trapMasterRun),
    Game(number: 84, id: "rising-flood-escape", title: "Rising Flood Escape",
         summary: "水がどんどん上がってくる！ みんなでボタンを順番に押してゲートを開け、てっぺんの出口へ。沈んだ神殿・おもちゃ工場・空の城の3マップ。水の中では息が続くまで。",
         tags: ["obby", "coop", "survival"], maxPlayers: 12, libs: ["rounds", "move"], build: risingFloodEscape),
    Game(number: 83, id: "pedal-obby", title: "Pedal Obby",
         summary: "自転車に乗ったままクリアするオビー。公園・キャニオン・雪山・ネオンの街の40ステージを、ジャンプ台とブースト床でとびこえろ。空中でトリックを決めるとコイン、ガレージで6台の自転車。",
         tags: ["obby", "bike", "stunts"], maxPlayers: 16, libs: ["obby", "move"], build: pedalObby),
    Game(number: 81, id: "cell-block-run", title: "Cell Block Run",
         summary: "ブルーノ所長の刑務所から脱獄！ 牢屋→通気口→食堂→洗濯室→運動場→所長室→下水道→屋根→ヘリの21ステージ。サーチライトと看守、起きたら止まれ、屋根では所長が追ってくる。",
         tags: ["obby", "story", "escape"], maxPlayers: 16, libs: ["obby", "move"], build: cellBlockRun),
    Game(number: 82, id: "color-chart-obby", title: "Color Chart Obby",
         summary: "12段階の難しさを色で進む60ステージ。らくらく（緑）からだいさいがい（白）まで、ゾーンをこえるたびにバッジ。コイルと⏱ゾーンタイムアタックも。",
         tags: ["obby", "difficulty", "parkour"], maxPlayers: 16, libs: ["obby"], build: colorChartObby),
]

// MARK: - Obstacles between two points
//
// Every obby section here runs from one checkpoint's top (a) to the next's
// (b), whatever the direction, so a course can turn corners and climb.

struct Span {
    let a: V, b: V
    var dx: Float { b.0 - a.0 }
    var dz: Float { b.2 - a.2 }
    var flat: Float { (dx * dx + dz * dz).squareRoot() }
    /// Along the span, 0 at a and 1 at b.
    func at(_ t: Float, side: Float = 0, up: Float = 0) -> V {
        let px = -dz / max(flat, 0.001), pz = dx / max(flat, 0.001)
        return (a.0 + dx * t + px * side, a.1 + (b.1 - a.1) * t + up, a.2 + dz * t + pz * side)
    }
    var yaw: Float { atan2(dx, dz) * 180 / .pi }
}

enum ObbyKind: CaseIterable {
    case stones, beam, killLines, movers, vanish, zigzag, trampoline, ladder, lavaChoice, wrap
}

/// Builds one section from `s.a` to `s.b` (both checkpoint tops, 4 m pads).
/// `d` is 0 (easiest) to 1 (hardest).
func obbySection(_ m: MapBuilder, _ s: Span, kind: ObbyKind, d: Float, color: String, accent: String, r: inout Seeded) {
    let margin: Float = 2.6 / max(s.flat, 1)
    let t0 = margin, t1 = 1 - margin
    let run = s.flat * (t1 - t0)
    switch kind {
    case .stones, .zigzag:
        let size = 3.4 - d * 1.6
        let gap = 1.3 + d * 2.1
        let count = max(2, Int((run + gap) / (size + gap)))
        for i in 0..<count {
            let t = t0 + (t1 - t0) * (Float(i) + 0.5) / Float(count)
            let side: Float = kind == .zigzag ? (i % 2 == 0 ? 1.6 + d * 1.2 : -1.6 - d * 1.2) : r.range(-0.6, 0.6) * d
            let p = s.at(t, side: side)
            m.step("Stone", x: p.0, y: p.1, z: p.2, w: size, d: size, color: i % 2 == 0 ? color : accent)
        }
    case .beam:
        let width = 1.9 - d * 1.35
        m.beam(from: s.at(t0 - 0.02), to: s.at(t1 + 0.02), width: width, color: color)
        if d > 0.5 {
            // Posts to squeeze past.
            for k in 1...2 {
                let p = s.at(t0 + (t1 - t0) * Float(k) / 3, side: k % 2 == 0 ? 0.9 : -0.9)
                m.killBrick(at: (p.0, p.1 + 1, p.2), size: (0.5, 2, 0.5), shape: .cylinder)
            }
        }
    case .killLines:
        let floorW: Float = 4 - d * 1.5
        m.part("Runway", at: s.at(0.5, up: -0.3), size: (floorW, 0.6, run + 1), color: color, rotation: (0, s.yaw, 0))
        let spacing = 4.6 - d * 1.6
        let lines = max(1, Int(run / spacing) - 1)
        let top = s.at(0.5).1
        for i in 0..<lines {
            let t = t0 + (t1 - t0) * (Float(i) + 1) / Float(lines + 1)
            let p = s.at(t)
            let tall: Float = 0.35 + d * 0.35
            m.killBrick(at: (p.0, top + tall / 2, p.2), size: (floorW, tall, 0.35), rotation: (0, s.yaw, 0))
        }
    case .movers:
        let count = max(2, Int(run / 5.5))
        for i in 0..<count {
            let t = t0 + (t1 - t0) * (Float(i) + 0.5) / Float(count)
            let p = s.at(t)
            let size = 3.2 - d * 1.2
            if i % 2 == 0 {
                let swing: Float = 3 + d * 2
                let px = -s.dz / max(s.flat, 0.001) * swing, pz = s.dx / max(s.flat, 0.001) * swing
                let start = s.at(t, side: -swing / 2)
                m.mover(at: (start.0, start.1 - 0.3, start.2), size: (size, 0.6, size), color: accent, offset: (px, 0, pz),
                        seconds: Double(2.8 - d * 1.5), pause: Double(0.8 - d * 0.5))
            } else {
                m.step("Stone", x: p.0, y: p.1, z: p.2, w: size, d: size, color: color)
            }
        }
    case .vanish:
        let size = 2.8 - d * 0.8
        let count = max(2, Int(run / (size + 0.6)))
        for i in 0..<count {
            let t = t0 + (t1 - t0) * (Float(i) + 0.5) / Float(count)
            let p = s.at(t)
            m.vanishing(at: (p.0, p.1 - 0.3, p.2), size: (size, 0.6, size), color: accent, delay: Double(0.55 - d * 0.3),
                        back: 2.5)
        }
    case .trampoline:
        let mid = s.at(0.5)
        let wall: Float = 3 + d * 2
        m.part("Runway", at: s.at(0.5, up: -0.3), size: (3.4, 0.6, run + 1), color: color, rotation: (0, s.yaw, 0))
        m.part("Wall", at: (mid.0, mid.1 + wall / 2, mid.2), size: (3.4, wall, 1), color: accent, rotation: (0, s.yaw, 0))
        let pad = s.at(0.5 - 2.4 / max(s.flat, 1))
        m.bouncer(at: (pad.0, pad.1 + 0.1, pad.2), size: (2.2, 0.2, 2.2), speed: 13 + wall * 1.4)
        if d > 0.4 {
            let lava = s.at(0.5 + 2.6 / max(s.flat, 1))
            m.killBrick(at: (lava.0, lava.1 + 0.05, lava.2), size: (3.4, 0.1, 1.6), rotation: (0, s.yaw, 0))
        }
    case .ladder:
        let mid = s.at(0.5)
        let tower: Float = 4 + d * 3
        m.part("Runway", at: s.at(0.5, up: -0.3), size: (3, 0.6, run + 1), color: color, rotation: (0, s.yaw, 0))
        m.part("Tower", at: (mid.0, mid.1 + tower / 2, mid.2), size: (3, tower, 2.5), color: accent, rotation: (0, s.yaw, 0))
        let face = s.at(0.5 - 1.45 / max(s.flat, 1))
        m.ladder(at: (face.0, face.1 + tower / 2, face.2), size: (1.4, tower, 0.3), rotation: (0, s.yaw, 0))
        if d > 0.5 {
            let top = s.at(0.5, side: 0, up: tower + 0.6)
            m.killBrick(at: top, size: (0.4, 1.2, 0.4), shape: .cylinder)
        }
    case .lavaChoice:
        let count = max(2, Int(run / 3.4))
        for i in 0..<count {
            let t = t0 + (t1 - t0) * (Float(i) + 0.5) / Float(count)
            let safeLeft = r.unit() < 0.5
            for side: Float in [-1.4, 1.4] {
                let p = s.at(t, side: side)
                let safe = (side < 0) == safeLeft
                if safe {
                    m.step("Stone", x: p.0, y: p.1, z: p.2, w: 2.2, d: 2.2, color: color)
                } else {
                    m.step("Stone", x: p.0, y: p.1, z: p.2, w: 2.2, d: 2.2, color: "#7F1D1D")
                    m.killBrick(at: (p.0, p.1 + 0.05, p.2), size: (2.2, 0.1, 2.2), color: "#F97316")
                }
            }
        }
    case .wrap:
        let mid = s.at(0.5, side: -1.6)
        m.part("Wrap Wall", at: (mid.0, mid.1 + 2, mid.2), size: (1, 5, run + 1), color: accent, rotation: (0, s.yaw, 0))
        let ledge = 1.3 - d * 0.6
        m.part("Ledge", at: s.at(0.5, side: -0.9 + ledge / 2 - 0.4, up: -0.3), size: (ledge, 0.6, run + 1), color: color,
               rotation: (0, s.yaw, 0))
    }
}

// MARK: 82 Color Chart Obby (Difficulty Chart Obby)

let chartTiers: [(String, String)] = [
    ("らくらく", "#4ADE80"), ("かんたん", "#16A34A"), ("ふつう", "#FACC15"), ("むずかしい", "#F97316"),
    ("とてもむずかしい", "#EF4444"), ("チャレンジ", "#991B1B"), ("はげしい", "#52525B"), ("ようしゃなし", "#D946EF"),
    ("むちゃくちゃ", "#2563EB"), ("きょくげん", "#38BDF8"), ("きょうふ", "#22D3EE"), ("だいさいがい", "#F8FAFC")
]

func colorChartObby(_ m: MapBuilder) {
    m.sky("#0F172A", "#1E3A8A", light: 0.7, showGround: false, fall: -60)
    m.environment.skyStyle = .stars
    // The lobby: spawns, the shop, the chart board.
    m.slab("Lobby", x: -70, y: -1, z: -20, w: 30, h: 1, d: 30, color: "#1F2937")
    m.rail(-70, -20, w: 30, d: 30, color: "#374151", gapSide: "+x", name: "Lobby Rail")
    m.spawnRing(-70, -20, radius: 5, count: 8, color: "#4ADE80")
    m.pad("Shop Pad", x: -80, z: -28, size: 3, color: "#F59E0B", tags: ["shop"])
    m.pad("Trial Pad", x: -60, z: -28, size: 3, color: "#38BDF8", tags: ["trial"])
    for (i, tier) in chartTiers.enumerated() {
        m.part("Chart Bar \(i + 1)", at: (-83.5 + Float(i) * 2.4, 1.5 + Float(i) * 0.35, -34.6), size: (2, 3 + Float(i) * 0.7, 0.4),
               color: tier.1, material: .neon, solid: false)
    }
    // The path out of the lobby to stage 1.
    m.slab("Lobby Bridge", x: -56, y: -1, z: -20, w: 4, h: 1, d: 4, color: "#374151")

    // 60 stages: twelve rows of five, back and forth, climbing.
    var r = Seeded("colorchart")
    var pads: [V] = []
    for n in 1...61 {
        let tier = (n - 1) / 5
        let k = (n - 1) % 5
        let row = min(tier, 11)
        let forward = row % 2 == 0
        let xs: [Float] = [-50, -28, -6, 16, 38]
        let x = n == 61 ? (forward ? 60 : -72) : (forward ? xs[k] : xs[4 - k])
        pads.append((x, Float(row) * 1.6, Float(row) * 24 - 20))
    }
    for n in 1...60 {
        let tier = chartTiers[(n - 1) / 5]
        let p = pads[n - 1]
        m.stagePad(n, x: p.0, y: p.1, z: p.2, color: tier.1)
    }
    let end = pads[60]
    m.finishLine(x: end.0, y: end.1, z: end.2)
    m.slab("Finish Deck", x: end.0, y: end.1 - 1.5, z: end.2, w: 16, h: 1, d: 16, color: "#FDE68A")
    // Lobby to stage 1: an easy walk.
    obbySection(m, Span(a: (-56, 0, -20), b: pads[0]), kind: .stones, d: 0, color: "#9CA3AF", accent: "#D1D5DB", r: &r)

    let kindsByTier: [[ObbyKind]] = [
        [.stones, .beam, .killLines, .stones, .zigzag],
        [.stones, .killLines, .trampoline, .zigzag, .beam],
        [.movers, .stones, .vanish, .ladder, .killLines],
        [.zigzag, .lavaChoice, .movers, .beam, .trampoline],
        [.vanish, .wrap, .killLines, .movers, .ladder],
        [.lavaChoice, .zigzag, .beam, .vanish, .trampoline],
        [.movers, .wrap, .stones, .killLines, .ladder],
        [.beam, .vanish, .lavaChoice, .zigzag, .movers],
        [.wrap, .movers, .killLines, .trampoline, .vanish],
        [.zigzag, .beam, .movers, .lavaChoice, .wrap],
        [.vanish, .killLines, .zigzag, .ladder, .movers],
        [.beam, .wrap, .vanish, .movers, .zigzag]
    ]
    for n in 1...60 {
        let tierIndex = (n - 1) / 5
        let tier = chartTiers[tierIndex]
        let d = Float(tierIndex) / 11 * 0.95 + Float((n - 1) % 5) * 0.01
        let kind = kindsByTier[tierIndex][(n - 1) % 5]
        let accent = tierIndex == 11 ? "#CBD5E1" : "#E5E7EB"
        obbySection(m, Span(a: pads[n - 1], b: pads[n]), kind: kind, d: d, color: tier.1, accent: accent, r: &r)
    }
    // Stars and a moon, for the look.
    var s = Seeded("chartstars")
    for _ in 0..<40 {
        m.part("Star", at: (s.range(-160, 160), s.range(20, 70), s.range(-120, 360)), size: (0.8, 0.8, 0.8), color: "#FEF9C3",
               shape: .sphere, material: .neon, solid: false)
    }
    m.part("Moon", at: (120, 60, 320), size: (24, 24, 24), color: "#F1F5F9", shape: .sphere, material: .neon, solid: false)
    m.coverFocus(x: -10, y: 6, z: 40, yaw: 200, width: 110)
}

// MARK: 81 Cell Block Run (Barry's Prison Run)

func cellBlockRun(_ m: MapBuilder) {
    m.sky("#64748B", "#CBD5E1", light: 0.62, ground: "#4B5563", fall: -40)
    let wall = "#9CA3AF", dark = "#374151", bars = "#1F2937"
    // Outer walls of the prison, the whole run long.
    m.slab("Prison Wall", x: -16, y: 0, z: 220, w: 1, h: 7, d: 460, color: "#6B7280")
    m.slab("Prison Wall", x: 16, y: 0, z: 220, w: 1, h: 7, d: 460, color: "#6B7280")
    m.slab("Prison Wall", x: 0, y: 0, z: -2, w: 33, h: 7, d: 1, color: "#6B7280")

    // 1. The cell block: eight cells, a door each, the corridor, the vent.
    m.slab("Cell Floor", x: 0, y: -0.2, z: 22, w: 31, h: 0.2, d: 48, color: "#D1D5DB")
    for i in 0..<8 {
        let side: Float = i < 4 ? -1 : 1
        let z = 6 + Float(i % 4) * 8
        let x = side * 9.5
        m.slab("Cell Wall", x: x, y: 0, z: z - 3.5, w: 11, h: 3.4, d: 0.4, color: wall)
        m.slab("Cell Bed", x: x + side * 3.5, y: 0, z: z + 1.5, w: 2.4, h: 0.6, d: 3, color: "#F8FAFC")
        m.spawn(x, z, name: "Spawn \(i + 1)", color: "#F97316")
        // The bars, with a door in them that opens when walked into.
        m.slab("Cell Bars", x: side * 4.2, y: 0, z: z - 2.2, w: 0.3, h: 3.4, d: 2.6, color: bars, material: .metal)
        m.slab("Cell Bars", x: side * 4.2, y: 0, z: z + 2.2, w: 0.3, h: 3.4, d: 2.6, color: bars, material: .metal)
        var g = GimmickSettings.default
        g.doorSeconds = 4
        m.part("Cell Door \(i + 1)", at: (side * 4.2, 1.2, z), size: (0.3, 2.4, 1.8), color: "#475569", material: .metal,
               behavior: .door, gimmick: g)
    }
    m.slab("Cell Wall", x: -9.5, y: 0, z: 34.5, w: 11, h: 3.4, d: 0.4, color: wall)
    m.slab("Cell Wall", x: 9.5, y: 0, z: 34.5, w: 11, h: 3.4, d: 0.4, color: wall)
    m.stagePad(1, x: 0, y: 0, z: 40, color: "#F97316")
    m.ladder(at: (0, 2.6, 44.6), size: (1.6, 5.2, 0.4))
    // A wall right across under the vent: the only way on is up the ladder.
    m.slab("Block Wall", x: 0, y: 0, z: 46.2, w: 32, h: 4.5, d: 0.6, color: wall)
    m.slab("Block Wall", x: 0, y: 0, z: 77.2, w: 32, h: 4.5, d: 0.6, color: wall)
    // The vent: a duct up in the air with broken grates.
    m.stagePad(2, x: 0, y: 5, z: 47, size: 2.2, color: "#F97316")
    for (a, b) in [(46.0, 52.0), (55.0, 60.0), (63.0, 68.0), (71.0, 76.0)] as [(Float, Float)] {
        m.slab("Vent Floor", x: 0, y: 4.6, z: (a + b) / 2, w: 2.4, h: 0.4, d: b - a, color: "#94A3B8", material: .metal)
    }
    for z in [53.5, 61.5, 69.5] as [Float] {
        m.vanishing("Vent Grate", at: (0, 4.8, z), size: (2.4, 0.2, 2.8), color: "#CBD5E1", delay: 0.6, back: 2)
    }
    m.slab("Vent Wall", x: -1.4, y: 4.6, z: 61, w: 0.3, h: 2.6, d: 30, color: "#64748B", material: .metal)
    m.slab("Vent Wall", x: 1.4, y: 4.6, z: 61, w: 0.3, h: 2.6, d: 30, color: "#64748B", material: .metal)
    m.slab("Vent Roof", x: 0, y: 7.2, z: 61, w: 3.1, h: 0.3, d: 30, color: "#64748B", material: .metal)
    m.movingHazard("Vent Fan", at: (0, 5.8, 64.8), size: (2.2, 0.3, 0.3), color: "#EF4444", tags: ["fan"])
    m.stagePad(3, x: 0, y: 5, z: 76, size: 2.2, color: "#F97316")
    m.stairs(-1.5, 79, y: 0, steps: 1, rise: 0.4, run: 3, width: 3, color: dark)
    m.slab("Vent Drop", x: 0, y: 0, z: 78.5, w: 4, h: 0.4, d: 3, color: dark)

    // 2. The cafeteria: the floor is wet (slippery = back), jump the tables.
    m.slab("Cafe Floor", x: 0, y: -0.2, z: 106, w: 31, h: 0.2, d: 56, color: "#E5E7EB")
    m.killBrick("Wet Floor", at: (0, 0.03, 106), size: (30, 0.06, 40), color: "#7DD3FC")
    m.stagePad(4, x: 0, y: 0.4, z: 84.5, color: "#F97316")
    var r = Seeded("cellblock")
    let tables: [(Float, Float)] = [(0, 88.5), (-3, 92.5), (1, 96.5), (4.5, 100), (1, 104), (-3.5, 108), (-1, 112.5), (3, 116.5),
                                    (0, 121), (-2.5, 125)]
    for (i, tpos) in tables.enumerated() {
        let top: Float = i == 4 ? 1.0 : 1.0
        m.step("Table", x: tpos.0, y: top, z: tpos.1, w: 3, d: 2.2, h: 0.3, color: "#B45309")
        m.slab("Table Leg", x: tpos.0, y: 0, z: tpos.1, w: 0.4, h: top - 0.3, d: 0.4, color: "#78350F")
        m.part("Food Tray", at: (tpos.0 + r.range(-0.8, 0.8), top + 0.08, tpos.1), size: (0.9, 0.1, 0.6), color: "#94A3B8", solid: false)
    }
    m.stagePad(5, x: 1, y: 1.0, z: 104, size: 3, color: "#F97316")
    for i in 0..<3 {
        m.movingHazard("Flying Tray \(i + 1)", at: (-12, 2, 94 + Float(i) * 11), size: (1.4, 0.2, 1.0), color: "#CBD5E1",
                       material: .metal, tags: ["tray"])
    }
    m.part("Pie", at: (12, 1.8, 110), size: (0.9, 0.9, 0.9), color: "#FBBF24", shape: .sphere, tags: ["pie"], solid: false)
    m.slab("Serving Counter", x: -12, y: 0, z: 106, w: 4, h: 1.2, d: 30, color: "#78716C")
    m.stagePad(6, x: 0, y: 0.4, z: 130, color: "#F97316")
    m.slab("Cafe Exit", x: 0, y: 0, z: 130, w: 8, h: 0.2, d: 6, color: "#E5E7EB")

    // 3. The laundry: bubbles to bounce on, machines to stand on, belts, steam.
    m.slab("Laundry Floor", x: 0, y: -0.2, z: 157, w: 31, h: 0.2, d: 46, color: "#BFDBFE")
    m.killBrick("Soap Water", at: (0, 0.03, 158), size: (30, 0.06, 32), color: "#A5F3FC")
    m.stagePad(7, x: 0, y: 0.4, z: 136, color: "#F97316")
    m.bouncer("Soap Bubble", at: (0, 0.3, 140), size: (2.4, 0.3, 2.4), color: "#E0F2FE", speed: 13)
    for (i, z) in [(0, 143.5), (1, 148), (2, 152.5)] as [(Int, Float)] {
        m.slab("Washer", x: Float(i - 1) * 3, y: 0, z: z, w: 2.6, h: 2.5, d: 2.6, color: "#F8FAFC", material: .metal)
        m.part("Washer Door", at: (Float(i - 1) * 3, 1.3, z - 1.32), size: (1.4, 1.4, 0.05), color: "#38BDF8", shape: .cylinder,
               material: .glass, solid: false, rotation: (90, 0, 0))
    }
    m.stagePad(8, x: 1, y: 2.5, z: 156.5, size: 3, color: "#F97316")
    m.slab("Washer", x: 1, y: 0, z: 156.5, w: 3, h: 2.5, d: 3, color: "#F8FAFC", material: .metal)
    m.mover("Laundry Belt", at: (1, 2.2, 161), size: (2.6, 0.4, 2.6), color: "#475569", offset: (0, 0, 7), seconds: 2.6, pause: 0.8,
            material: .metal)
    m.slab("Dryer", x: 1, y: 0, z: 169.5, w: 3, h: 2.5, d: 3, color: "#FDE68A", material: .metal)
    m.part("Steam 1", at: (1, 3.2, 164), size: (2.6, 3.2, 1.2), color: "#F1F5F9", material: .glass, tags: ["steam"], solid: false, opacity: 0.55)
    m.part("Steam 2", at: (1, 1.6, 176), size: (6, 3.2, 1.2), color: "#F1F5F9", material: .glass, tags: ["steam"], solid: false, opacity: 0.55)
    m.stagePad(9, x: 0, y: 0.4, z: 180, color: "#F97316")
    m.slab("Laundry Exit", x: 0, y: 0, z: 180, w: 8, h: 0.2, d: 6, color: "#BFDBFE")

    // 4. The yard: searchlights sweep it and a guard walks round.
    m.slab("Yard", x: 0, y: -0.2, z: 218, w: 31, h: 0.2, d: 72, color: "#65A30D", material: .grass)
    m.stagePad(10, x: 0, y: 0.4, z: 186, color: "#F97316")
    m.slab("Court", x: -8, y: 0, z: 200, w: 12, h: 0.05, d: 16, color: "#B45309")
    m.part("Hoop", at: (-8, 3, 192.5), size: (1.2, 0.1, 1.2), color: "#F97316", shape: .cylinder, solid: false)
    m.slab("Hoop Post", x: -8, y: 0, z: 191.8, w: 0.3, h: 3.2, d: 0.3, color: dark)
    for (i, z) in [(0, 198.0), (1, 212.0), (2, 232.0)] as [(Int, Float)] {
        m.movingHazard("Searchlight \(i + 1)", at: (-10, 1.5, z), size: (5, 3, 5), color: "#FEF08A", shape: .cylinder,
                       tags: ["searchlight"], opacity: 0.35)
    }
    for x in [-12, 12] as [Float] {
        m.slab("Tower", x: x, y: 0, z: 222, w: 3, h: 8, d: 3, color: dark)
        m.part("Tower Lamp", at: (x, 8.6, 222), size: (1.2, 1.2, 1.2), color: "#FDE68A", shape: .sphere, material: .neon, solid: false)
    }
    for (i, c) in [(-3.0, 206.0), (4.0, 214.0), (-5.0, 226.0), (3.0, 238.0)].enumerated() {
        m.crate(Float(c.0), Float(c.1), size: 2, color: i % 2 == 0 ? "#92400E" : "#78350F")
    }
    m.stagePad(11, x: 7, y: 0.4, z: 216, color: "#F97316")
    m.markers("Guard Post", points: [(-10, 204), (10, 204), (10, 240), (-10, 240)], color: "#000000", visible: false, behavior: .none)
    m.stagePad(12, x: 0, y: 0.4, z: 250, color: "#F97316")

    // 5. The warden's office: he is asleep. Freeze when he wakes.
    m.slab("Office Floor", x: 0, y: -0.2, z: 277, w: 31, h: 0.2, d: 46, color: "#7C2D12", material: .wood)
    m.slab("Office Wall", x: -8.5, y: 0, z: 255, w: 14, h: 5, d: 0.4, color: "#92400E")
    m.slab("Office Wall", x: 8.5, y: 0, z: 255, w: 14, h: 5, d: 0.4, color: "#92400E")
    m.stagePad(13, x: 0, y: 0.4, z: 258, color: "#F97316")
    m.slab("Desk", x: 0, y: 0, z: 292, w: 6, h: 1.1, d: 2.2, color: "#451A03")
    m.part("Warden Seat", at: (0, 0.1, 295.5), size: (1, 0.2, 1), color: "#000000", solid: false, visible: false)
    for (i, x) in [(0, 8.0), (1, 10.5), (2, 13.0)] as [(Int, Float)] {
        m.slab("Cabinet", x: x, y: 0, z: 266, w: 2, h: 1 + Float(i), d: 2, color: "#57534E", material: .metal)
    }
    m.part("Keycard", at: (13, 3.5, 266), size: (0.8, 0.1, 0.5), color: "#22C55E", material: .neon, behavior: .trigger,
           tags: ["keycard"], solid: false)
    m.stagePad(14, x: -6, y: 0.4, z: 278, color: "#F97316")
    for (x, z) in [(-9, 270), (9, 283), (-5, 286)] as [(Float, Float)] { m.slab("Bookshelf", x: x, y: 0, z: z, w: 3, h: 3, d: 1, color: "#78350F") }
    m.slab("Office Wall", x: -9, y: 0, z: 300, w: 13, h: 5, d: 0.4, color: "#92400E")
    m.slab("Office Wall", x: 9, y: 0, z: 300, w: 13, h: 5, d: 0.4, color: "#92400E")
    m.part("Office Door", at: (0, 1.3, 300), size: (5, 2.6, 0.5), color: "#DC2626", material: .neon, behavior: .trigger,
           tags: ["office_exit"], solid: false, opacity: 0.55)
    m.stagePad(15, x: 0, y: 0.4, z: 304, color: "#F97316")

    // 6. The sewer: down the steps, along pipes over the sludge, past the rats.
    m.slab("Sewer Top", x: 0, y: -0.2, z: 305, w: 10, h: 0.2, d: 6, color: dark)
    for k in 0..<3 {
        m.slab("Sewer Step", x: 0, y: -1 - Float(k), z: 308.5 + Float(k) * 1.2, w: 4, h: 1, d: 1.2, color: "#1F2937")
    }
    m.slab("Sewer Floor", x: 0, y: -3.4, z: 336, w: 31, h: 0.4, d: 56, color: "#1C1917")
    m.stagePad(16, x: 0, y: -3, z: 314, color: "#F97316")
    m.killBrick("Sludge", at: (0, -3.0, 337), size: (22, 0.1, 40), color: "#65A30D")
    m.slab("Sewer Wall", x: -11.5, y: -3, z: 336, w: 1, h: 6, d: 48, color: "#292524")
    m.slab("Sewer Wall", x: 11.5, y: -3, z: 336, w: 1, h: 6, d: 48, color: "#292524")
    m.slab("Walkway", x: -8, y: -3, z: 336, w: 4, h: 0.3, d: 40, color: "#57534E")
    m.slab("Walkway", x: 8, y: -3, z: 336, w: 4, h: 0.3, d: 40, color: "#57534E")
    m.beam(from: (-6, -2.6, 326), to: (6, -2.6, 326), width: 1.1, color: "#A16207", name: "Pipe")
    m.beam(from: (6, -2.6, 346), to: (-6, -2.6, 346), width: 0.9, color: "#A16207", name: "Pipe")
    m.stagePad(17, x: 8, y: -2.7, z: 336, size: 3.4, color: "#F97316")
    for i in 0..<3 {
        m.movingHazard("Rat \(i + 1)", at: (i % 2 == 0 ? -8 : 8, -2.4, 320 + Float(i) * 11), size: (0.6, 0.5, 1.1), color: "#57534E",
                       material: .matte, tags: ["rat"])
    }
    m.stagePad(18, x: -8, y: -2.7, z: 356, size: 3.4, color: "#F97316")
    for k in 0..<3 {
        m.slab("Sewer Step", x: -8, y: -3 + Float(k), z: 358.5 + Float(k) * 1.2, w: 4, h: 1, d: 1.2, color: "#1F2937")
    }

    // 7. The roofs: up the ladder, across the gaps; below is the electric fence.
    m.slab("Roof Yard", x: 0, y: -0.2, z: 395, w: 31, h: 0.2, d: 64, color: "#374151")
    m.killBrick("Electric Fence", at: (0, 0.05, 396), size: (30, 0.1, 50), color: "#FACC15")
    m.slab("Ladder Base", x: -8, y: 0, z: 364, w: 4, h: 0.4, d: 4, color: dark)
    m.ladder(at: (-8, 5, 366.3), size: (1.6, 10, 0.4))
    let roofs: [(Float, Float, Float, Float)] = [(-8, 370, 8, 6), (-5, 377.5, 5, 5), (0, 384.5, 5, 5), (4, 392, 6, 6), (0, 400, 5, 5),
                                                 (-4, 408, 7, 7)]
    for (i, roof) in roofs.enumerated() {
        let top: Float = 10 + Float(i % 2) * 0.6
        m.slab("Roof \(i + 1)", x: roof.0, y: 0, z: roof.1, w: roof.2, h: top, d: roof.3, color: i % 2 == 0 ? "#78716C" : "#57534E")
        m.part("Roof Edge", at: (roof.0, top + 0.05, roof.1), size: (roof.2, 0.1, roof.3), color: "#A8A29E", solid: false)
    }
    m.stagePad(19, x: -8, y: 10, z: 370, size: 3, color: "#F97316")
    m.stagePad(20, x: 4, y: 10.6, z: 392, size: 3, color: "#F97316")
    m.stagePad(21, x: -4, y: 10.6, z: 408, size: 3, color: "#F97316")
    m.markers("Bruno Roof", points: [(-8, 372)], y: 10, color: "#000000", visible: false, behavior: .none)
    // 8. The helipad and the way out.
    m.slab("Helipad", x: -2, y: 0, z: 419, w: 14, h: 10.6, d: 12, color: "#4B5563")
    m.finishLine(x: -2, y: 10.6, z: 420, size: 7)
    m.part("Heli Body", at: (3, 12, 423), size: (3, 2, 5), color: "#1D4ED8", shape: .sphere, solid: false)
    m.part("Heli Tail", at: (3, 12.4, 427), size: (0.6, 0.6, 4), color: "#1D4ED8", solid: false)
    m.part("Heli Rotor", at: (3, 13.3, 423), size: (8, 0.1, 0.5), color: "#111827", tags: ["rotor"], solid: false)
    m.part("Big H", at: (-2, 10.62, 420), size: (4, 0.02, 4), color: "#FFFFFF", solid: false)
    // Donuts: a burst of speed.
    for d in [(0, 0.8, 20), (0, 5.6, 50), (-3, 1.6, 93), (1, 3.1, 154), (8, 0.8, 230), (-10, 0.8, 290), (8, -2.1, 350), (0, 11, 384.5)]
        as [(Float, Float, Float)] {
        m.part("Donut", at: d, size: (0.9, 0.3, 0.9), color: "#F472B6", shape: .cylinder, material: .neon, behavior: .trigger,
               tags: ["donut"], solid: false)
    }
    m.coverFocus(x: 0, y: 3, z: 110, yaw: 150, width: 90)
}

// MARK: 83 Pedal Obby (Obby But You're on a Bike)

enum BikeKind {
    case road, gapJump, plank, mover, steps, logs, bounce, zigzag, boostGap, cones
}

/// A bike section: wide, fast, and with launch pads rather than jumps.
/// Launch pads carry their push in tags ("p=16", "u=8") and face along
/// the span (their yaw), which the script reads back.
func bikeSection(_ m: MapBuilder, _ s: Span, kind: BikeKind, d: Float, color: String, accent: String, logs: inout Int) {
    let margin: Float = 3.2 / max(s.flat, 1)
    let t0 = margin, t1 = 1 - margin
    let width: Float = 6 - d * 1.5
    func road(_ a: Float, _ b: Float, w: Float = width, c: String = color, up: Float = 0) {
        guard b > a else { return }
        let mid = s.at((a + b) / 2, up: up - 0.3)
        m.part("Road", at: mid, size: (w, 0.6, s.flat * (b - a) + 0.02), color: c, rotation: (0, s.yaw, 0))
    }
    func launch(_ at: Float, push: Int, up: Int) {
        let p = s.at(at, up: 0.06)
        m.part("Launch", at: p, size: (width * 0.8, 0.12, 2.4), color: "#F97316", material: .neon, behavior: .trigger,
               tags: ["launch", "p=\(push)", "u=\(up)"], solid: false, rotation: (0, s.yaw, 0))
        m.part("Ramp Look", at: s.at(at - 0.03, up: 0.35), size: (width * 0.8, 0.12, 2.6), color: accent, solid: false,
               rotation: (-14, s.yaw, 0))
    }
    switch kind {
    case .road, .cones:
        road(t0 - 0.01, t1 + 0.01)
        if kind == .cones {
            let count = 4 + Int(d * 4)
            for i in 0..<count {
                let t = t0 + (t1 - t0) * (Float(i) + 0.5) / Float(count)
                let p = s.at(t, side: i % 2 == 0 ? width * 0.22 : -width * 0.22)
                m.killBrick("Cone", at: (p.0, p.1 + 0.5, p.2), size: (1.1, 1, 1.1), color: "#F97316", shape: .cone)
            }
        }
    case .gapJump:
        road(t0 - 0.01, 0.38)
        launch(0.35, push: 16, up: 8)
        road(0.62, t1 + 0.01)
    case .boostGap:
        road(t0 - 0.01, 0.3)
        let b = s.at(0.2, up: 0.05)
        m.part("Boost", at: b, size: (width * 0.8, 0.1, 3), color: "#22D3EE", material: .neon, behavior: .trigger, tags: ["boost"],
               solid: false, rotation: (0, s.yaw, 0))
        launch(0.28, push: 21, up: 8)
        road(0.7, t1 + 0.01)
    case .plank:
        road(t0 - 0.01, 0.2)
        road(0.2, 0.8, w: 2.4 - d * 0.9, c: accent)
        road(0.8, t1 + 0.01)
    case .mover:
        road(t0 - 0.01, 0.28)
        let start = s.at(0.36, up: -0.3)
        let along = s.at(0.64)
        m.mover("Bike Lift", at: start, size: (5, 0.6, 5), color: accent,
                offset: (along.0 - s.at(0.36).0, 0, along.2 - s.at(0.36).2), seconds: Double(3.2 - d), pause: 1)
        road(0.72, t1 + 0.01)
    case .steps:
        road(t0 - 0.01, 0.2)
        let stepsUp = 10
        for k in 0..<stepsUp {
            let a = 0.2 + Float(k) * 0.025, b = a + 0.025
            road(a, b, up: 0.3 * Float(k + 1))
        }
        road(0.45, 0.62, up: 3)
        road(0.62, t1 + 0.01)
    case .logs:
        road(t0 - 0.01, t1 + 0.01)
        for k in 0..<3 {
            logs += 1
            let t = 0.3 + Float(k) * 0.2
            let p = s.at(t, side: -width / 2 - 1)
            let across = width + 2
            let ox = -s.dz / max(s.flat, 0.001) * across, oz = s.dx / max(s.flat, 0.001) * across
            m.movingHazard("Log \(logs)", at: (p.0, p.1 + 0.5, p.2), size: (1, 1, 1), color: "#78350F", shape: .sphere,
                           material: .wood, tags: ["log", "ox=\(Int(ox.rounded()))", "oz=\(Int(oz.rounded()))"])
        }
    case .bounce:
        road(t0 - 0.01, 0.5)
        let wallP = s.at(0.5, up: 2)
        m.part("Wall", at: wallP, size: (width, 4, 1), color: accent, rotation: (0, s.yaw, 0))
        m.bouncer("Bike Bounce", at: s.at(0.45, up: 0.1), size: (width * 0.7, 0.2, 2.4), color: "#38BDF8", speed: 17)
        road(0.5, 0.7, up: 4)
        road(0.7, t1 + 0.01)
    case .zigzag:
        road(t0 - 0.01, 0.18)
        let count = 4
        for i in 0..<count {
            let t = 0.26 + Float(i) * 0.16
            let p = s.at(t, side: i % 2 == 0 ? 2.2 : -2.2)
            m.step("Pad", x: p.0, y: p.1, z: p.2, w: 5 - d, d: 5 - d, color: i % 2 == 0 ? accent : color)
        }
        road(0.82, t1 + 0.01)
    }
}

func pedalObby(_ m: MapBuilder) {
    m.sky("#7DD3FC", "#E0F2FE", light: 0.8, showGround: false, fall: -50)
    m.environment.skyStyle = .clouds
    // The lobby and the garage.
    m.slab("Lobby", x: -40, y: -1, z: 0, w: 26, h: 1, d: 26, color: "#E5E7EB")
    m.rail(-40, 0, w: 26, d: 26, color: "#9CA3AF", gapSide: "+x", gap: 8, name: "Lobby Rail")
    m.spawnRing(-44, 0, radius: 5, count: 8, color: "#F97316")
    m.pad("Garage Pad", x: -48, z: -8, size: 3.4, color: "#F59E0B", tags: ["garage"])
    m.slab("Garage", x: -48, y: 0, z: -11.5, w: 8, h: 3.5, d: 1, color: "#B45309")
    m.pad("Shop Pad", x: -48, z: 8, size: 3.4, color: "#A855F7", tags: ["shop"])
    m.slab("Lobby Exit", x: -24.5, y: -1, z: 0, w: 5, h: 1, d: 8, color: "#E5E7EB")

    let worlds: [(String, String, String)] = [("park", "#4ADE80", "#FACC15"), ("canyon", "#D97706", "#92400E"),
                                               ("snow", "#E0F2FE", "#60A5FA"), ("neon", "#312E81", "#22D3EE")]
    let kindsByWorld: [[BikeKind]] = [
        [.road, .gapJump, .cones, .plank, .zigzag, .logs, .gapJump, .bounce, .steps, .road],
        [.gapJump, .logs, .plank, .mover, .cones, .boostGap, .zigzag, .steps, .gapJump, .bounce],
        [.plank, .mover, .gapJump, .logs, .zigzag, .boostGap, .cones, .mover, .plank, .steps],
        [.boostGap, .zigzag, .mover, .plank, .logs, .gapJump, .bounce, .boostGap, .zigzag, .cones]
    ]
    var pads: [V] = []
    for n in 1...41 {
        let row = min((n - 1) / 10, 3)
        let k = (n - 1) % 10
        let forward = row % 2 == 0
        let x: Float = n == 41 ? -36 : (forward ? Float(k) * 36 : Float(9 - k) * 36)
        pads.append((x, 0, Float(row) * 44))
    }
    for n in 1...40 {
        let world = worlds[(n - 1) / 10]
        m.stagePad(n, x: pads[n - 1].0, y: 0, z: pads[n - 1].2, size: 6, color: world.2)
    }
    m.finishLine(x: pads[40].0, y: 0, z: pads[40].2, size: 10)
    m.slab("Finish Deck", x: pads[40].0, y: -1, z: pads[40].2, w: 16, h: 1, d: 16, color: "#FDE68A")
    var logs = 0
    bikeSection(m, Span(a: (-22, 0, 0), b: pads[0]), kind: .road, d: 0, color: "#9CA3AF", accent: "#D1D5DB", logs: &logs)
    for n in 1...40 {
        let wi = (n - 1) / 10
        let world = worlds[wi]
        let d = Float(wi) / 3 * 0.8 + Float((n - 1) % 10) * 0.01
        bikeSection(m, Span(a: pads[n - 1], b: pads[n]), kind: kindsByWorld[wi][(n - 1) % 10], d: d, color: world.1,
                    accent: world.2, logs: &logs)
    }
    // Scenery under each world, far below: trees, mesas, snowy peaks, towers.
    var r = Seeded("pedal")
    for i in 0..<48 {
        let wi = i / 12
        let x = r.range(-20, 340), z = Float(wi) * 44 + r.range(-18, 18)
        switch wi {
        case 0: m.tree(x, z, y: -30, height: 8, leaves: "#16A34A")
        case 1: m.part("Mesa", at: (x, -24, z), size: (10, 14, 8), color: "#B45309", material: .sand)
        case 2: m.part("Peak", at: (x, -24, z), size: (12, 16, 12), color: "#F8FAFC", shape: .cone, material: .matte)
        default: m.part("Tower", at: (x, -20, z), size: (5, 24, 5), color: r.pick(["#6366F1", "#EC4899", "#22D3EE"]), material: .neon, solid: false)
        }
    }
    m.coverFocus(x: 120, y: 2, z: 22, yaw: 160, width: 140)
}

// MARK: 84 Rising Flood Escape (Flood Escape 2)

/// One flood map: a square tank with a path spiralling up its walls,
/// gates across the path that the buttons before them open, and the exit
/// at the top. The water ("Flood n") starts just below the floor.
func floodMap(_ m: MapBuilder, index n: Int, cx: Float, theme: (floor: String, wall: String, path: String, accent: String, water: String),
              material: MaterialKind, laps: Int, special: String) {
    let half: Float = 15
    let top: Float = Float(laps) * 12.8 + 4
    m.slab("Tank Floor \(n)", x: cx, y: -1, z: 0, w: half * 2 + 2, h: 1, d: half * 2 + 2, color: theme.floor, material: material)
    for (dx, dz, w, d) in [(0, -half - 0.5, half * 2 + 2, 1), (0, half + 0.5, half * 2 + 2, 1), (-half - 0.5, 0, 1, half * 2 + 2),
                           (half + 0.5, 0, 1, half * 2 + 2)] as [(Float, Float, Float, Float)] {
        m.slab("Tank Wall \(n)", x: cx + dx, y: 0, z: dz, w: w, h: top + 6, d: d, color: theme.wall, material: .glass, opacity: 0.35)
    }
    for i in 0..<8 {
        let a = Float(i) / 8 * 2 * .pi
        m.part("FStart\(n) \(i + 1)", at: (cx + cos(a) * 3, 0.1, sin(a) * 3), size: (1.2, 0.2, 1.2), color: "#000000", solid: false,
               visible: false)
    }
    // The spiral: platforms round the inside of the walls, 0.8 m up each time.
    let ring: [(Float, Float)] = {
        var list: [(Float, Float)] = []
        let edge: Float = half - 3
        for k in 0..<4 { list.append((-edge + Float(k) * edge * 2 / 4, -edge)) }
        for k in 0..<4 { list.append((edge, -edge + Float(k) * edge * 2 / 4)) }
        for k in 0..<4 { list.append((edge - Float(k) * edge * 2 / 4, edge)) }
        for k in 0..<4 { list.append((-edge, edge - Float(k) * edge * 2 / 4)) }
        return list
    }()
    let count = laps * 16
    let gates = [count / 4, count / 2, count * 3 / 4, count - 2]
    var r = Seeded("flood\(n)")
    var buttonIndex = 0
    for i in 0..<count {
        let spot = ring[i % 16]
        let y = 0.8 * Float(i + 1)
        let x = cx + spot.0, z = spot.1
        if special == "vanish" && i % 5 == 3 {
            m.vanishing("Cloud Tile", at: (x, y - 0.3, z), size: (4.8, 0.6, 4.8), color: "#F8FAFC", delay: 0.8, back: 2)
        } else if special == "movers" && i % 7 == 4 {
            m.mover("Temple Lift", at: (x, y - 0.3, z), size: (4.8, 0.6, 4.8), color: theme.accent, offset: (0, 1.2, 0), seconds: 1.6, pause: 0.6)
        } else {
            m.step("Path", x: x, y: y, z: z, w: 4.8, d: 4.8, color: i % 2 == 0 ? theme.path : theme.accent, material: material)
        }
        if special == "bounce" && i % 9 == 6 {
            m.bouncer("Spring", at: (x, y + 0.1, z), size: (1.8, 0.2, 1.8), color: "#F472B6", speed: 12)
        }
        if let k = gates.firstIndex(of: i) {
            // The gate stands on the next platform; its button on this one.
            let next = ring[(i + 1) % 16]
            let gx = cx + (spot.0 + next.0) / 2, gz = (spot.1 + next.1) / 2
            let alongX = abs(next.0 - spot.0) > abs(next.1 - spot.1)
            m.part("Gate \(n) \(k + 1)", at: (gx, y + 2.2, gz), size: (alongX ? 0.6 : 6, 5, alongX ? 6 : 0.6), color: "#DC2626",
                   material: .neon, tags: ["fgate", "map\(n)"], opacity: 0.8)
            m.part("Button \(n) \(k + 1)", at: (x + (r.unit() - 0.5), y + 0.15, z), size: (1.4, 0.3, 1.4), color: "#FACC15",
                   shape: .cylinder, material: .neon, behavior: .trigger, tags: ["fbutton", "map\(n)", "k=\(k + 1)"])
            buttonIndex += 1
        }
    }
    let last = ring[count % 16]
    let exitY = 0.8 * Float(count + 1)
    m.step("Exit Deck", x: cx + last.0, y: exitY, z: last.1, w: 6, d: 6, color: "#22C55E")
    m.part("Exit \(n)", at: (cx + last.0, exitY + 1.5, last.1), size: (3, 3, 3), color: "#22C55E", material: .neon,
           behavior: .trigger, tags: ["fexit", "map\(n)"], solid: false, opacity: 0.5)
    // A pillar up the middle, with a light on top the water climbs past.
    m.slab("Middle \(n)", x: cx, y: 0, z: 0, w: 4, h: top * 0.6, d: 4, color: theme.wall, material: material)
    m.part("Middle Light \(n)", at: (cx, top * 0.6 + 0.8, 0), size: (1.6, 1.6, 1.6), color: theme.accent, shape: .sphere, material: .neon,
           solid: false)
    // The water, just under the floor to begin with.
    m.part("Flood \(n)", at: (cx, -1.2 - 40, 0), size: (half * 2 - 0.2, 80, half * 2 - 0.2), color: theme.water, material: .water,
           tags: ["flood"], solid: false, opacity: 0.65)
}

func risingFloodEscape(_ m: MapBuilder) {
    m.sky("#60A5FA", "#DBEAFE", light: 0.75, ground: "#1E3A8A", fall: -60)
    // The lobby: where you wait, vote and shop.
    m.slab("Lobby", x: 0, y: -1, z: -110, w: 40, h: 1, d: 30, color: "#E0F2FE")
    m.rail(0, -110, w: 40, d: 30, color: "#93C5FD", gapSide: "+z", gap: 0.01, name: "Lobby Rail")
    m.spawnRing(0, -110, radius: 5, count: 8, color: "#38BDF8")
    m.pad("Shop Pad", x: -12, z: -118, size: 3.4, color: "#A855F7", tags: ["shop"])
    m.pad("Vote Temple", x: 8, z: -100, size: 3, color: "#A16207", tags: ["vote", "v=1"])
    m.pad("Vote Factory", x: 13, z: -100, size: 3, color: "#F472B6", tags: ["vote", "v=2"])
    m.pad("Vote Castle", x: 18, z: -100, size: 3, color: "#E5E7EB", tags: ["vote", "v=3"])
    m.part("Lobby Pool", at: (0, -0.9, -110), size: (10, 0.2, 6), color: "#38BDF8", material: .water, solid: false, opacity: 0.6)
    floodMap(m, index: 1, cx: -110, theme: ("#78716C", "#57534E", "#A8A29E", "#CA8A04", "#0EA5E9"), material: .stone, laps: 3, special: "movers")
    floodMap(m, index: 2, cx: 0, theme: ("#FDE68A", "#FB7185", "#60A5FA", "#FBBF24", "#22D3EE"), material: .plastic, laps: 3, special: "bounce")
    floodMap(m, index: 3, cx: 110, theme: ("#E2E8F0", "#CBD5E1", "#F8FAFC", "#A5B4FC", "#2563EB"), material: .brick, laps: 4, special: "vanish")
    m.coverFocus(x: 0, y: 14, z: 0, yaw: 200, width: 60)
}

// MARK: 85 Trap Master Run (Deathrun)

func trapMasterRun(_ m: MapBuilder) {
    m.sky("#1E1B4B", "#7C3AED", light: 0.6, showGround: false, fall: -60)
    m.environment.skyStyle = .stars
    let stone = "#57534E", dark = "#292524"
    // Start room, with a gate that drops at GO.
    m.slab("Start Room", x: 0, y: -1, z: -8, w: 12, h: 1, d: 14, color: "#44403C")
    m.slab("Start Wall", x: 0, y: 0, z: -15.2, w: 12, h: 4, d: 0.4, color: dark)
    m.slab("Start Wall", x: -6.2, y: 0, z: -8, w: 0.4, h: 4, d: 14, color: dark)
    m.slab("Start Wall", x: 6.2, y: 0, z: -8, w: 0.4, h: 4, d: 14, color: dark)
    m.part("Start Gate", at: (0, 2, -1), size: (12, 4, 0.4), color: "#22C55E", material: .neon, opacity: 0.6)
    for (i, spot) in grid(4, 3, spacing: 2.4, cx: 0, cz: -8).enumerated() {
        m.part("RStart \(i + 1)", at: (spot.0, 0.1, spot.1), size: (1, 0.2, 1), color: "#000000", solid: false, visible: false)
    }
    // Spectators watch from a box above the start.
    m.slab("Spectate Box", x: 0, y: 9, z: -8, w: 12, h: 0.4, d: 10, color: "#1F2937")
    m.rail(0, -8, w: 12, d: 10, h: 1.2, y: 9.4, color: "#4B5563", gapSide: "+z", gap: 0.01, name: "Spectate Rail")
    m.part("Spectate", at: (0, 9.6, -8), size: (1, 0.2, 1), color: "#000000", solid: false, visible: false)

    // Ten zones, 15 m each, over a pit.
    m.killBrick("Pit", at: (0, -9, 75), size: (40, 1, 170), color: "#7F1D1D")
    let zones: [(String, String)] = [("トラップドア", "#A8A29E"), ("トゲ", "#78716C"), ("おしだしカベ", "#A8A29E"), ("火の柱", "#78716C"),
                                     ("大岩", "#A8A29E"), ("レーザー", "#78716C"), ("つぶし天井", "#A8A29E"), ("くずれる橋", "#78716C"),
                                     ("矢", "#A8A29E"), ("マグマ", "#78716C")]
    for (i, zone) in zones.enumerated() {
        let k = i + 1
        let z0 = Float(i) * 15, zc = z0 + 7.5
        m.part("Zone Sign \(k)", at: (-5.4, 3.5, z0 + 0.5), size: (0.2, 1, 3), color: "#FDE68A", material: .neon, solid: false)
        m.slab("Side Wall", x: -5.2, y: 0, z: zc, w: 0.4, h: 4, d: 15, color: dark)
        switch k {
        case 1:
            for j in 0..<3 {
                m.part("T1 Floor", at: (0, -0.3, z0 + 2.5 + Float(j) * 5), size: (10, 0.6, 5), color: "#D6D3D1", tags: ["trap1"])
            }
        case 8:
            m.slab("Zone Floor", x: 0, y: -0.6, z: z0 + 1.5, w: 10, h: 0.6, d: 3, color: zone.1)
            m.slab("Zone Floor", x: 0, y: -0.6, z: z0 + 13.5, w: 10, h: 0.6, d: 3, color: zone.1)
            for j in 0..<5 {
                m.part("T8 Bridge", at: (0, -0.3, z0 + 4 + Float(j) * 1.8), size: (3, 0.6, 1.8), color: "#A16207", material: .wood, tags: ["trap8"])
            }
        default:
            m.slab("Zone Floor", x: 0, y: -0.6, z: zc, w: 10, h: 0.6, d: 15, color: zone.1, material: .stone)
        }
        switch k {
        case 2:
            for j in 0..<9 {
                let x = Float(j % 3) * 3 - 3, z = z0 + 4 + Float(j / 3) * 3.5
                m.part("T2 Spike", at: (x, 0.6, z), size: (1.4, 1.2, 1.4), color: "#E5E7EB", shape: .cone, material: .metal,
                       tags: ["trap2", "kill"], solid: false, visible: false)
            }
        case 3:
            m.movingHazard("T3 Wall", at: (-7.5, 1.5, zc), size: (1, 3, 8), color: "#B91C1C", tags: ["trap3"])
        case 4:
            for j in 0..<3 {
                m.part("T4 Fire", at: (Float(j) * 3.5 - 3.5, 2, z0 + 4 + Float(j) * 3.5), size: (2.4, 4, 2.4), color: "#F97316",
                       shape: .cylinder, material: .neon, tags: ["trap4", "kill"], solid: false, visible: false, opacity: 0.8)
            }
        case 5:
            m.movingHazard("T5 Boulder", at: (0, 1.8, z0 + 14), size: (3.4, 3.4, 3.4), color: "#57534E", shape: .sphere, material: .stone,
                           tags: ["trap5"])
        case 6:
            for j in 0..<4 {
                m.part("T6 Laser", at: (0, j % 2 == 0 ? 0.5 : 1.5, z0 + 3 + Float(j) * 3), size: (10, 0.15, 0.15), color: "#EF4444",
                       material: .neon, tags: ["trap6", "kill"], solid: false, visible: false)
            }
        case 7:
            m.movingHazard("T7 Crusher", at: (0, 7, zc), size: (10, 2, 6), color: "#44403C", material: .metal, tags: ["trap7"])
        case 9:
            for j in 0..<5 {
                m.movingHazard("T9 Arrow \(j + 1)", at: (-7, j % 2 == 0 ? 1 : 1.7, z0 + 2.5 + Float(j) * 2.5), size: (1.4, 0.15, 0.15),
                               color: "#FACC15", tags: ["trap9"])
            }
        case 10:
            m.part("T10 Lava", at: (0, 0.05, zc), size: (10, 0.1, 13), color: "#F97316", material: .neon, tags: ["trap10", "kill"],
                   solid: false, visible: false)
        default:
            break
        }
    }
    // The finish, and the way up to the trap master.
    m.slab("Finish Room", x: 0, y: -1, z: 158, w: 12, h: 1, d: 12, color: "#166534")
    m.part("DR Finish", at: (0, 1.5, 160), size: (10, 3, 2), color: "#22C55E", material: .neon, behavior: .trigger, tags: ["dr_finish"],
           solid: false, opacity: 0.5)
    // The trap master's balcony, alongside.
    m.slab("Balcony", x: 9, y: 5.6, z: 70, w: 4, h: 0.4, d: 160, color: "#312E81")
    m.slab("Balcony Rail", x: 7, y: 6, z: 70, w: 0.3, h: 1.1, d: 160, color: "#6366F1", opacity: 0.7)
    m.slab("Balcony Wall", x: 11.2, y: 6, z: 70, w: 0.4, h: 3, d: 160, color: "#1E1B4B")
    m.part("TMStart", at: (9, 6.1, 5), size: (1, 0.2, 1), color: "#000000", solid: false, visible: false)
    for i in 0..<4 {
        m.part("Revenge \(i + 1)", at: (9, 6.1, 150 - Float(i) * 3), size: (1, 0.2, 1), color: "#000000", solid: false, visible: false)
    }
    for i in 0..<10 {
        m.part("Lever \(i + 1)", at: (10.5, 6.8, Float(i) * 15 + 7.5), size: (0.3, 1.2, 0.3), color: "#FACC15", material: .neon, solid: false)
    }
    // The lobby between rounds is the start room.
    m.spawnRing(0, -8, y: 0, radius: 3, count: 6, color: "#A78BFA")
    for i in 0..<20 {
        m.part("Torch", at: (-5, 3.2, Float(i) * 8), size: (0.3, 0.6, 0.3), color: "#FB923C", material: .neon, solid: false)
    }
    m.coverFocus(x: 0, y: 2, z: 40, yaw: 210, width: 60)
}

// MARK: 86 Speeding Wall Survival (Be Crushed by a Speeding Wall)

func speedingWallSurvival(_ m: MapBuilder) {
    m.sky("#F59E0B", "#FDE68A", light: 0.8, showGround: false, fall: -40)
    m.environment.skyStyle = .sunset
    // The runway the walls speed down, with stripes to judge where they are.
    m.slab("Runway", x: 0, y: -1, z: 0, w: 32, h: 1, d: 96, color: "#E5E7EB")
    for i in 0..<12 {
        m.part("Stripe", at: (0, 0.01, -44 + Float(i) * 8), size: (32, 0.02, 0.5), color: i % 2 == 0 ? "#F87171" : "#FBBF24", solid: false)
    }
    for x in [-16.2, 16.2] as [Float] {
        m.part("Edge", at: (x, 0.1, 0), size: (0.4, 0.2, 96), color: "#111827", material: .neon, solid: false)
    }
    m.part("Wall Start", at: (0, 3, -47), size: (32, 6, 0.3), color: "#DC2626", material: .neon, solid: false, opacity: 0.25)
    m.part("Wall Home", at: (0, 3, -46), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    for (i, spot) in grid(4, 4, spacing: 4, cx: 0, cz: 10).enumerated() {
        m.part("Arena Spot \(i + 1)", at: (spot.0, 0.1, spot.1), size: (1, 0.2, 1), color: "#000000", solid: false, visible: false)
    }
    // The stands: where you wait, and watch once you are out.
    m.slab("Stands", x: -32, y: 1, z: 0, w: 18, h: 1, d: 40, color: "#1F2937")
    m.rail(-32, 0, w: 18, d: 40, h: 1.2, y: 2, color: "#4B5563", gapSide: "+x", gap: 0.01, name: "Stand Rail")
    for k in 0..<3 {
        m.slab("Bench", x: -36 + Float(k) * 3, y: 2, z: 0, w: 1.2, h: 0.5 + Float(k) * 0.5, d: 36, color: "#374151")
    }
    m.spawnRing(-30, 0, y: 2, radius: 4, count: 8, color: "#F59E0B")
    m.pad("Shop Pad", x: -30, z: -14, y: 2, size: 3, color: "#A855F7", tags: ["shop"])
    m.part("Scoreboard", at: (-40.5, 6, 0), size: (0.4, 5, 16), color: "#0F172A", material: .neon, solid: false)
    m.coverFocus(x: 0, y: 2, z: 0, yaw: 130, width: 70)
}

// MARK: 87 Easy Peasy Obby (The Really Easy Obby)

let easyWorlds: [(name: String, path: String, accent: String, deco: String)] = [
    ("草原", "#86EFAC", "#FDE68A", "tree"), ("おかし", "#F9A8D4", "#FDE047", "candy"), ("ビーチ", "#FDE68A", "#38BDF8", "palm"),
    ("雪", "#F1F5F9", "#93C5FD", "pine"), ("宇宙", "#6366F1", "#F0ABFC", "planet"), ("ジャングル", "#4D7C0F", "#FB923C", "tree"),
    ("おもちゃ", "#F87171", "#60A5FA", "blocks"), ("雲", "#FFFFFF", "#BAE6FD", "cloud"), ("にじ", "#C084FC", "#FACC15", "rainbow"),
    ("お城", "#D6D3D1", "#FBBF24", "tower")
]

func easyPeasyObby(_ m: MapBuilder) {
    m.sky("#93C5FD", "#F0F9FF", light: 0.85, showGround: false, fall: -40)
    m.environment.skyStyle = .clouds
    m.slab("Start Island", x: -18, y: -1, z: 0, w: 16, h: 1, d: 16, color: "#BBF7D0", material: .grass)
    m.spawnRing(-20, 0, radius: 3.5, count: 8, color: "#F472B6")
    m.pad("Pet Pad", x: -24, z: -5, size: 3, color: "#FB923C", tags: ["petshop"])
    m.pad("Shop Pad", x: -24, z: 5, size: 3, color: "#A855F7", tags: ["shop"])
    m.slab("Start Bridge", x: -8, y: -1, z: 0, w: 6, h: 1, d: 5, color: "#FDE68A")
    let kinds: [ObbyKind] = [.stones, .beam, .zigzag, .trampoline, .stones, .movers, .ladder, .killLines, .vanish, .beam]
    var pads: [V] = []
    for n in 1...101 {
        let row = min((n - 1) / 10, 9)
        let k = (n - 1) % 10
        let forward = row % 2 == 0
        let x: Float = n == 101 ? -14 : (forward ? Float(k) * 13 : Float(9 - k) * 13)
        pads.append((x, 0, Float(row) * 18))
    }
    var r = Seeded("easy")
    for n in 1...100 {
        let w = easyWorlds[(n - 1) / 10]
        m.stagePad(n, x: pads[n - 1].0, y: 0, z: pads[n - 1].2, size: 5, color: w.accent)
        // A coin on most stages.
        if n % 10 != 0 {
            let c = pads[n - 1]
            m.part("Coin", at: (c.0 + 1.2, 1.1, c.2 + 1.2), size: (0.8, 0.8, 0.15), color: "#FACC15", shape: .cylinder, material: .neon,
                   behavior: .trigger, tags: ["coin"], solid: false, rotation: (90, 0, 0))
        }
    }
    m.finishLine(x: pads[100].0, y: 0, z: pads[100].2, size: 8, color: "#F472B6")
    m.slab("Finish Island", x: pads[100].0, y: -1, z: pads[100].2, w: 14, h: 1, d: 14, color: "#FBCFE8")
    obbySection(m, Span(a: (-5, 0, 0), b: pads[0]), kind: .stones, d: 0, color: "#FDE68A", accent: "#FEF3C7", r: &r)
    for n in 1...100 {
        let wi = (n - 1) / 10
        let w = easyWorlds[wi]
        let d = Float(wi) * 0.02
        obbySection(m, Span(a: pads[n - 1], b: pads[n]), kind: kinds[(n - 1 + wi) % kinds.count], d: d, color: w.path, accent: w.accent,
                    r: &r)
    }
    // Scenery beside each world's row.
    for (wi, w) in easyWorlds.enumerated() {
        let z = Float(wi) * 18 + 8.5
        for k in 0..<5 {
            let x = Float(k) * 28 + r.range(-4, 4)
            switch w.deco {
            case "tree": m.tree(x, z, y: -1, height: 3, leaves: wi == 0 ? "#22C55E" : "#15803D")
            case "pine": m.pine(x, z, y: -1, height: 4, leaves: "#E2E8F0")
            case "palm":
                m.part("Palm", at: (x, 1, z), size: (0.4, 4, 0.4), color: "#A16207", shape: .cylinder, solid: false)
                m.part("Palm Leaves", at: (x, 3.2, z), size: (3, 0.6, 3), color: "#16A34A", shape: .sphere, solid: false)
            case "candy":
                m.part("Lollipop", at: (x, 1, z), size: (0.2, 3, 0.2), color: "#FFFFFF", shape: .cylinder, solid: false)
                m.part("Lollipop Top", at: (x, 2.8, z), size: (1.6, 1.6, 0.4), color: r.pick(["#F472B6", "#A78BFA", "#34D399"]), shape: .cylinder,
                       solid: false, rotation: (90, 0, 0))
            case "planet":
                m.part("Planet", at: (x, 4 + r.range(0, 4), z + 4), size: (3, 3, 3), color: r.pick(["#F59E0B", "#A78BFA", "#38BDF8"]), shape: .sphere,
                       material: .neon, solid: false)
            case "blocks":
                m.part("Toy Block", at: (x, 0.5, z), size: (1.5, 1.5, 1.5), color: r.pick(["#EF4444", "#3B82F6", "#FACC15", "#22C55E"]), solid: false)
            case "cloud":
                m.part("Cloud", at: (x, 0, z), size: (5, 1.5, 3), color: "#FFFFFF", shape: .sphere, material: .matte, solid: false)
            case "rainbow":
                for (i, c) in ["#EF4444", "#F97316", "#FACC15", "#22C55E", "#3B82F6", "#8B5CF6"].enumerated() {
                    m.part("Rainbow", at: (x, 5 - Float(i) * 0.5, z + 3), size: (8 - Float(i), 0.4, 0.4), color: c, material: .neon, solid: false)
                }
            default:
                m.part("Castle Tower", at: (x, 2, z), size: (2, 4, 2), color: "#A8A29E", shape: .cylinder, solid: false)
                m.part("Castle Roof", at: (x, 4.8, z), size: (2.6, 1.6, 2.6), color: "#DC2626", shape: .cone, solid: false)
            }
        }
        m.part("World Sign \(wi + 1)", at: (-8, 2.5, Float(wi) * 18), size: (0.3, 1.6, 4), color: w.accent, material: .neon, solid: false)
    }
    m.coverFocus(x: 55, y: 1, z: 30, yaw: 180, width: 110)
}

// MARK: 88 Cart Ride Wonderland (Cart Ride Around Nothing)

let cartPath: [V] = [(0, 0, 0), (0, 0, 60), (40, 0, 60), (40, 3, 16), (84, 3, 16), (84, 3, 92), (124, 6, 92), (124, 6, 16),
                     (164, 6, 16), (164, 2, 100), (204, 2, 100), (204, 8, 16), (244, 8, 16), (244, 8, 108), (284, 4, 108),
                     (284, 4, 16), (324, 10, 16), (324, 10, 116), (364, 10, 116), (364, 14, 28), (404, 14, 28)]
let cartFeatures = ["plain", "ramp", "jump", "train", "boostjump", "rocks", "lava", "slalom", "ramp", "jump", "ramp", "train", "lava",
                    "rocks", "ramp", "jump", "boostjump", "slalom", "ramp", "lava"]
let cartZones: [(road: String, rail: String, ground: String)] = [
    ("#65A30D", "#FDE68A", "#86EFAC"), ("#57534E", "#A16207", "#44403C"), ("#F9A8D4", "#FFFFFF", "#FBCFE8"),
    ("#E2E8F0", "#60A5FA", "#F8FAFC"), ("#44403C", "#F97316", "#1C1917")
]

func cartRideWonderland(_ m: MapBuilder) {
    m.sky("#7DD3FC", "#FEF3C7", light: 0.8, ground: "#4D7C0F", showGround: false, fall: -40)
    m.environment.skyStyle = .clouds
    m.slab("Depot", x: 0, y: -1, z: -14, w: 20, h: 1, d: 20, color: "#D6D3D1")
    m.spawnRing(0, -16, radius: 4, count: 8, color: "#F59E0B")
    m.pad("Shop Pad", x: -7, z: -20, size: 3, color: "#A855F7", tags: ["shop"])
    m.pad("Paint Pad", x: 7, z: -20, size: 3, color: "#EC4899", tags: ["paint"])
    var trains = 0, rocks = 0, bridges = 0
    for i in 0..<20 {
        let a = cartPath[i], b = cartPath[i + 1]
        let zone = cartZones[i / 4]
        // The station at the start of each stretch is its checkpoint.
        m.slab("Station", x: a.0, y: a.1 - 1, z: a.2, w: 10, h: 1, d: 10, color: zone.rail)
        m.stagePad(i + 1, x: a.0, y: a.1, z: a.2, size: 5, color: "#22C55E")
        let s = Span(a: a, b: b)
        let feature = cartFeatures[i]
        let horizontal = abs(s.dx) > abs(s.dz)
        func piece(_ t0: Float, _ t1: Float, y: Float, rails: Bool = true, color: String? = nil) {
            guard t1 > t0 else { return }
            let mid = s.at((t0 + t1) / 2)
            let length = s.flat * (t1 - t0) + 0.02
            m.part("Track", at: (mid.0, y - 0.3, mid.2), size: horizontal ? (length, 0.6, 6) : (6, 0.6, length), color: color ?? zone.road)
            if rails {
                for side: Float in [-3.2, 3.2] {
                    let p = s.at((t0 + t1) / 2, side: side)
                    m.part("Rail", at: (p.0, y + 0.65, p.2), size: horizontal ? (length, 1.3, 0.3) : (0.3, 1.3, length), color: zone.rail)
                }
            }
        }
        // Rise or fall in steps of 0.3 m between t = 0.12 and 0.42.
        let dy = b.1 - a.1
        let steps = Int((abs(dy) / 0.3).rounded(.up))
        var tFlat: Float = 0.08
        if steps > 0 {
            for k in 0..<steps {
                let ta = 0.08 + Float(k) * 0.34 / Float(steps), tb = ta + 0.34 / Float(steps)
                piece(ta, tb, y: a.1 + dy * Float(k + 1) / Float(steps))
            }
            tFlat = 0.42
        }
        let y = b.1
        piece(0, 0.08, y: a.1, rails: false)
        switch feature {
        case "jump", "boostjump":
            let gapA: Float = feature == "jump" ? 0.52 : 0.5, gapB: Float = feature == "jump" ? 0.66 : 0.72
            piece(tFlat, gapA, y: y)
            let lp = s.at(gapA - 0.03)
            m.part("Launch", at: (lp.0, y + 0.06, lp.2), size: horizontal ? (2.4, 0.12, 5) : (5, 0.12, 2.4), color: "#F97316", material: .neon,
                   behavior: .trigger, tags: ["launch", "p=\(feature == "jump" ? 15 : 19)", "u=8"], solid: false, rotation: (0, s.yaw, 0))
            if feature == "boostjump" {
                let bp = s.at(gapA - 0.12)
                m.part("Boost", at: (bp.0, y + 0.05, bp.2), size: horizontal ? (3, 0.1, 5) : (5, 0.1, 3), color: "#22D3EE", material: .neon,
                       behavior: .trigger, tags: ["boost"], solid: false)
            }
            piece(gapB, 0.92, y: y)
        case "lava":
            piece(tFlat, 0.5, y: y)
            let lava = s.at(0.61)
            m.killBrick("Lava", at: (lava.0, y - 4, lava.2), size: horizontal ? (s.flat * 0.24, 0.6, 12) : (12, 0.6, s.flat * 0.24), color: "#F97316")
            bridges += 1
            for k in 0..<4 {
                let tb = 0.5 + (Float(k) + 0.5) * 0.22 / 4
                let pb = s.at(tb)
                m.part("Lava Bridge \(bridges)", at: (pb.0, y - 0.3, pb.2), size: horizontal ? (s.flat * 0.055 + 0.05, 0.6, 5) : (5, 0.6, s.flat * 0.055 + 0.05),
                       color: "#78350F", material: .wood, tags: ["lavabridge", "k=\(k % 2)"])
            }
            piece(0.72, 0.92, y: y)
        default:
            piece(tFlat, 0.92, y: y)
        }
        if feature == "train" {
            trains += 1
            let tp = s.at(0.66, side: -12)
            let px = -s.dz / s.flat * 24, pz = s.dx / s.flat * 24
            m.movingHazard("Train \(trains)", at: (tp.0, y + 1.4, tp.2), size: horizontal ? (4, 2.8, 12) : (12, 2.8, 4), color: "#1D4ED8",
                           material: .metal, tags: ["train", "ox=\(Int(px))", "oz=\(Int(pz))"])
            let cross = s.at(0.66)
            m.part("Crossing", at: (cross.0, y + 0.02, cross.2), size: horizontal ? (4, 0.04, 6) : (6, 0.04, 4), color: "#FACC15", solid: false)
        }
        if feature == "rocks" {
            for k in 0..<3 {
                rocks += 1
                let rp = s.at(0.5 + Float(k) * 0.13, side: Float(k - 1) * 1.6)
                m.movingHazard("Rock \(rocks)", at: (rp.0, y + 9, rp.2), size: (2, 2, 2), color: "#78716C", shape: .sphere, material: .stone,
                               tags: ["rock"])
            }
        }
        if feature == "slalom" {
            for k in 0..<5 {
                let sp = s.at(tFlat + 0.08 + Float(k) * 0.09, side: k % 2 == 0 ? 1.5 : -1.5)
                m.killBrick("Barrel", at: (sp.0, y + 0.7, sp.2), size: (1.3, 1.4, 1.3), color: "#DC2626", shape: .cylinder)
            }
        }
        piece(0.92, 1.0, y: y, rails: false)
        // A little scenery either side.
        let deco = s.at(0.3, side: 9)
        switch i / 4 {
        case 0: m.tree(deco.0, deco.2, y: deco.1 - 6, height: 5)
        case 1: m.part("Mine Rock", at: (deco.0, deco.1 - 3, deco.2), size: (6, 8, 6), color: "#44403C", shape: .sphere, material: .stone, solid: false)
        case 2: m.part("Gumdrop", at: (deco.0, deco.1 - 2, deco.2), size: (5, 5, 5), color: "#F472B6", shape: .cone, solid: false)
        case 3: m.pine(deco.0, deco.2, y: deco.1 - 6, height: 6, leaves: "#E2E8F0")
        default: m.part("Volcano", at: (deco.0, deco.1 - 6, deco.2), size: (10, 12, 10), color: "#7C2D12", shape: .cone, material: .stone, solid: false)
        }
    }
    // The castle at the end.
    let end = cartPath[20]
    m.slab("Castle Yard", x: end.0 + 6, y: end.1 - 1, z: end.2, w: 20, h: 1, d: 20, color: "#E7E5E4")
    m.finishLine(x: end.0 + 4, y: end.1, z: end.2, size: 8, color: "#F472B6")
    for (dx, dz) in [(-8, -8), (8, -8), (-8, 8), (8, 8)] as [(Float, Float)] {
        m.part("Castle Tower", at: (end.0 + 6 + dx, end.1 + 4, end.2 + dz), size: (3, 8, 3), color: "#D6D3D1", shape: .cylinder, material: .stone)
        m.part("Castle Roof", at: (end.0 + 6 + dx, end.1 + 9, end.2 + dz), size: (4, 3, 4), color: "#DB2777", shape: .cone)
    }
    m.coverFocus(x: 120, y: 4, z: 60, yaw: 150, width: 130)
}
