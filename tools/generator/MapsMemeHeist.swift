import Foundation

// MARK: 4 Meme Heist (after Steal a Brainrot) — rebuilt big
//
// A red carpet runs east to west through the middle; meme characters walk
// along it from the Meme Gate to the far end. Four bases face it from each
// side: three floors of ten stands each, stairs inside up to the second
// floor and a ladder to the third, a laser gate across the front, a lock pad
// and a collect pad. The west square has the shops and the rebirth altar;
// the east square the fusion machine, the ritual garden, the admin's stage
// and the glitch room. Names and numbers the scripts rely on: "Base k …",
// "Ped k_f_s" and "Plate k_f_s" (k 1…8, floor 1…3, stand 1…10),
// "laser<k>", "Carpet Start", "Carpet End".

/// Bases: centre x and which side of the carpet (+1 north, -1 south).
let memeBases: [(Float, Float)] = [(-90, 1), (-30, 1), (30, 1), (90, 1), (-90, -1), (-30, -1), (30, -1), (90, -1)]
/// Where each floor's top is.
let memeFloors: [Float] = [0.2, 7.2, 14.2]
let memeStandX: [Float] = [-14, -7, 0, 7, 14]
let memeStandDepth: [Float] = [9, 21]

func memeHeist(_ m: MapBuilder) {
    m.day(ground: "#4D7C0F")
    m.environment.skyStyle = .clouds
    m.ground(520, 200, color: "#65A30D", x: 10, z: 0, material: .grass)

    // The carpet.
    m.slab("Carpet", x: 0, y: 0, z: 0, w: 252, h: 0.22, d: 6, color: "#DC2626")
    for z in [-3.3, 3.3] as [Float] { m.slab("Carpet Edge", x: 0, y: 0, z: z, w: 252, h: 0.3, d: 0.5, color: "#FACC15", material: .metal) }
    m.part("Carpet Start", at: (-122, 0.4, 0), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    m.part("Carpet End", at: (124, 0.4, 0), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    // The Meme Gate the characters come out of, and the hole they leave by.
    for z in [-4.4, 4.4] as [Float] {
        m.slab("Gate Post", x: -127, y: 0, z: z, w: 1.6, h: 9, d: 1.6, color: "#7C3AED", material: .metal)
    }
    let arch = m.part("Meme Gate", at: (-127, 9.6, 0), size: (2, 1.6, 10.4), color: "#C026D3", material: .neon, solid: false)
    m.label(arch, [("MEME GATE", "#FDE047"), ("ミームの門", "#FFFFFF")], height: 0.6, size: 1.6, range: 120)
    let swirl = m.part("Gate Swirl", at: (-127.5, 4.5, 0), size: (0.3, 8, 8), color: "#A855F7", shape: .cylinder, material: .neon,
                       solid: false, rotation: (0, 0, 90), opacity: 0.55)
    m.animate(swirl, .spin, speed: 0.8)
    let hole = m.part("Meme Exit", at: (128, 0.15, 0), size: (8, 0.1, 8), color: "#1E1B4B", shape: .cylinder, material: .neon, solid: false)
    m.animate(hole, .spin, speed: 1.5)
    for x in stride(from: -112 as Float, through: 112, by: 16) {
        for z in [-4.6, 4.6] as [Float] {
            m.part("Carpet Post", at: (x, 0.6, z), size: (0.3, 1.2, 0.3), color: "#FACC15", shape: .cylinder, material: .metal, solid: false)
        }
        m.part("Carpet Rope", at: (x + 8, 1.1, 4.6), size: (16, 0.08, 0.08), color: "#B91C1C", solid: false)
        m.part("Carpet Rope", at: (x + 8, 1.1, -4.6), size: (16, 0.08, 0.08), color: "#B91C1C", solid: false)
    }

    // The bases.
    for (index, base) in memeBases.enumerated() {
        memeBase(m, k: index + 1, x: base.0, side: base.1)
    }

    // West square: arrive here, shops and the rebirth altar.
    m.spawnRing(-150, 0, radius: 4, count: 8, color: "#F472B6")
    m.slab("West Square", x: -160, y: -0.02, z: 0, w: 70, h: 0.12, d: 76, color: "#E7E5E4", material: .stone)
    memeShop(m, "Gear Shop", x: -160, z: -26, color: "#BFDBFE", sign: "#2563EB", title: "🛠 ギア屋", sub: "GEAR", tag: "gearshop", facing: 1)
    memeShop(m, "Lucky Shop", x: -160, z: 26, color: "#FEF3C7", sign: "#F59E0B", title: "🎁 ラッキーブロック", sub: "LUCKY BLOCKS", tag: "luckyshop", facing: -1)
    m.slab("Rebirth Altar", x: -186, y: 0, z: 0, w: 8, h: 1.4, d: 8, color: "#831843", material: .stone)
    let crystal = m.part("Rebirth Crystal", at: (-186, 4.2, 0), size: (2.4, 4, 2.4), color: "#F472B6", shape: .sphere, material: .neon, solid: false)
    m.animate(crystal, .spin, speed: 0.6)
    m.label(crystal, [("🌟 転生の祭だん", "#FBCFE8"), ("REBIRTH", "#FFFFFF")], height: 0.5, size: 1.3, range: 80)
    m.pad("Rebirth Pad", x: -180, z: 0, size: 3.4, color: "#EC4899", tags: ["rebirthpad"])
    let board = m.part("Index Board", at: (-150, 3, 34), size: (10, 5, 0.4), color: "#0F766E", solid: true)
    m.label(board, [("📖 ミーム図鑑", "#99F6E4"), ("300体を集めよう", "#FFFFFF")], height: 0.3, size: 1.2, range: 70)
    m.pad("Index Pad", x: -150, z: 30, size: 3, color: "#14B8A6", tags: ["indexpad"])

    // The meme museum by the spawn: two rows of six pedestals the script
    // puts rare characters on (to look at, not to steal), facing the spawn.
    for (row, z) in [(0, -11), (1, 11)] as [(Int, Float)] {
        for i in 0..<6 {
            let x = -176 + Float(i) * 8
            m.slab("Show Ped \(row * 6 + i + 1)", x: x, y: 0, z: z, w: 3.4, h: 0.9, d: 3.4, color: "#FEF3C7", material: .stone)
            m.slab("Show Trim", x: x, y: 0.6, z: z, w: 3.56, h: 0.14, d: 3.56, color: "#F59E0B", material: .metal)
        }
    }
    for z in [-11, 11] as [Float] {
        m.slab("Museum Pole", x: -183, y: 0, z: z, w: 0.4, h: 5, d: 0.4, color: "#78350F", material: .wood)
        let museum = m.part("Museum Sign", at: (-183, 5.4, z), size: (0.3, 1.4, 4.6), color: "#B45309", material: .neon, solid: false)
        m.label(museum, [("🏛 ミーム博物館", "#FDE68A"), ("見るだけ・ぬすめないよ", "#FFFFFF")], height: 0.3, size: 1.1, range: 70)
    }

    // East square: fusion, rituals, the admin's stage, the glitch room.
    m.slab("East Square", x: 165, y: -0.02, z: 0, w: 80, h: 0.12, d: 90, color: "#E7E5E4", material: .stone)
    m.slab("Fusion Machine", x: 158, y: 0, z: -28, w: 10, h: 6, d: 8, color: "#334155", material: .metal)
    let tank = m.part("Fusion Tank", at: (158, 7.4, -28), size: (5, 3, 5), color: "#22D3EE", shape: .sphere, material: .glass, solid: false, opacity: 0.6)
    m.animate(tank, .pulse, speed: 0.8)
    m.label(tank, [("🧪 合体マシン", "#A5F3FC"), ("FUSION", "#FFFFFF")], height: 0.4, size: 1.2, range: 80)
    m.pad("Fusion Pad", x: 158, z: -22, size: 3.2, color: "#06B6D4", tags: ["fusionpad"])
    // The ritual garden: four altars in a square, a circle in the middle.
    m.slab("Ritual Garden", x: 160, y: 0, z: 30, w: 26, h: 0.2, d: 26, color: "#1E1B4B", material: .stone)
    let ring = m.part("Ritual Circle", at: (160, 0.32, 30), size: (12, 0.05, 12), color: "#A855F7", shape: .cylinder, material: .neon, solid: false)
    m.animate(ring, .spin, speed: 0.3)
    for (i, spot) in [(-8, -8), (8, -8), (-8, 8), (8, 8)].enumerated() {
        let x = 160 + Float(spot.0), z = 30 + Float(spot.1)
        m.slab("Altar \(i + 1)", x: x, y: 0.2, z: z, w: 3, h: 1.2, d: 3, color: "#4C1D95", material: .stone)
        m.pad("Altar Pad \(i + 1)", x: x, z: z - 2.6 * (spot.1 > 0 ? -1 : 1), size: 2, color: "#C084FC", tags: ["altarpad", "n=\(i + 1)"])
    }
    let rune = m.part("Ritual Sign", at: (160, 4, 44), size: (10, 2, 0.3), color: "#7C3AED", material: .neon, solid: false)
    m.label(rune, [("🔮 儀式の庭", "#E9D5FF"), ("RITUALS", "#FFFFFF")], height: 0.3, size: 1.2, range: 70)
    // The admin's stage.
    m.slab("Admin Stage", x: 192, y: 0, z: 0, w: 16, h: 1.6, d: 20, color: "#111827", material: .metal)
    m.part("Stage Screen", at: (199.6, 7, 0), size: (0.4, 9, 18), color: "#1D4ED8", material: .neon, solid: false)
    for z in [-9, 9] as [Float] {
        let light = m.part("Stage Light", at: (186, 9, z), size: (1, 1, 1), color: "#FDE047", shape: .sphere, material: .neon, solid: false)
        m.animate(light, .pulse, speed: 1.6)
        m.slab("Stage Pole", x: 186, y: 0, z: z, w: 0.4, h: 8.5, d: 0.4, color: "#374151", material: .metal)
    }
    m.part("Admin Spot", at: (192, 2.2, 0), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    // The glitch room: dark walls, four corners.
    // Back and sides whole; the front (facing south, -z) has a doorway under the sign.
    m.slab("Glitch Wall", x: 214, y: 0, z: 7, w: 15, h: 6, d: 1, color: "#0F172A")
    for sx in [-7, 7] as [Float] { m.slab("Glitch Wall", x: 214 + sx, y: 0, z: 0, w: 1, h: 6, d: 14, color: "#0F172A") }
    for sx in [-4.75, 4.75] as [Float] { m.slab("Glitch Wall", x: 214 + sx, y: 0, z: -7, w: 5.5, h: 6, d: 1, color: "#0F172A") }
    m.slab("Glitch Wall", x: 214, y: 3.4, z: -7, w: 4, h: 2.6, d: 1, color: "#0F172A")
    m.slab("Glitch Roof", x: 214, y: 6, z: 0, w: 15, h: 0.4, d: 15, color: "#020617")
    for (i, c) in ["#22C55E", "#A855F7", "#06B6D4"].enumerated() {
        let pixel = m.part("Glitch Pixel", at: (214 - 4 + Float(i) * 4, 3.4, 6.4), size: (1.4, 1.4, 0.2), color: c, material: .neon, solid: false)
        m.animate(pixel, .pulse, speed: 1.4 + Float(i) * 0.3)
    }
    m.slab("Glitch Floor", x: 214, y: 0, z: 0, w: 14, h: 0.2, d: 14, color: "#1E293B", material: .metal)
    for (i, c) in [(-5.5, -5.5), (5.5, -5.5), (-5.5, 5.5), (5.5, 5.5)].enumerated() {
        m.pad("Glitch Corner \(i + 1)", x: 214 + Float(c.0), z: Float(c.1), size: 1.8, color: "#22C55E", tags: ["glitchcorner"])
    }
    let gsign = m.part("Glitch Sign", at: (214, 7.2, -7.6), size: (8, 1.4, 0.3), color: "#22C55E", material: .neon, solid: false)
    m.label(gsign, [("👾 グリッチ部屋", "#86EFAC")], height: 0.3, size: 1.1, range: 60)
    // Taco stand for taco day.
    memeShop(m, "Taco Stand", x: 140, z: -40, color: "#FDE68A", sign: "#F97316", title: "🌮 タコスやさん", sub: "TACO", tag: "tacostand", facing: 1)

    // Trees and lamps round the edge.
    var r = Seeded("memeheist")
    for _ in 0..<70 {
        let x = r.range(-240, 250), z = r.pick([r.range(-95, -52), r.range(52, 95)])
        m.tree(x, z, height: r.range(4, 7), leaves: r.pick(["#16A34A", "#65A30D", "#15803D", "#F472B6"]))
    }
    for x in stride(from: -110 as Float, through: 110, by: 30) {
        m.lamp(x, -8)
        m.lamp(x, 8)
    }
    // The cover: the museum's front row, seen from the spawn, low down.
    m.part("Cover Focus", at: (-162, 2.4, -11), size: (24, 1, 1), color: "#000000", tags: ["yaw=22", "pitch=12"], solid: false, visible: false)
}

/// One base: k, centred on x, its front facing the carpet.
func memeBase(_ m: MapBuilder, k: Int, x bx: Float, side: Float) {
    let front = side * 12, back = side * 44, mid = side * 28
    let wall = ["#FDE68A", "#BFDBFE", "#FBCFE8", "#BBF7D0", "#FED7AA", "#DDD6FE", "#A5F3FC", "#FECACA"][k - 1]
    let trim = ["#D97706", "#2563EB", "#DB2777", "#16A34A", "#EA580C", "#7C3AED", "#0891B2", "#DC2626"][k - 1]
    // Floors: the first on the ground, the second with a gap over the
    // stairs, the third with a gap over the ladder.
    m.slab("Base \(k) Floor", x: bx, y: 0, z: mid, w: 40, h: 0.2, d: 32, color: "#E5E7EB", material: .wood)
    m.slab("Base \(k) Floor 2", x: bx - 2.25, y: 6.8, z: mid, w: 35.5, h: 0.4, d: 32, color: "#D6D3D1", material: .wood)
    m.slab("Base \(k) Floor 2", x: bx + 17.75, y: 6.8, z: side * (12 + 24.5), w: 4.5, h: 0.4, d: 15, color: "#D6D3D1", material: .wood)
    m.slab("Base \(k) Floor 3", x: bx + 2, y: 13.8, z: mid, w: 36, h: 0.4, d: 32, color: "#D6D3D1", material: .wood)
    m.slab("Base \(k) Floor 3", x: bx - 18, y: 13.8, z: side * (12 + 13.5), w: 4, h: 0.4, d: 27, color: "#D6D3D1", material: .wood)
    // Walls: back and sides, the full height; the front is open.
    m.slab("Base Wall", x: bx, y: 0, z: back, w: 40.8, h: 20, d: 0.8, color: wall, material: .brick)
    for sx in [-20.4, 20.4] as [Float] {
        m.slab("Base Wall", x: bx + sx, y: 0, z: mid, w: 0.8, h: 20, d: 32, color: wall, material: .brick)
    }
    // Pillars and rails at the front of the upper floors.
    for sx in [-20, 20] as [Float] {
        m.slab("Base Pillar", x: bx + sx, y: 0, z: front, w: 1.2, h: 20, d: 1.2, color: trim, material: .metal)
    }
    for y in [7.2, 14.2] as [Float] {
        m.slab("Base Rail", x: bx, y: y, z: front + side * 0.3, w: 40, h: 0.9, d: 0.2, color: trim, material: .metal)
    }
    // Stairs inside, along the right wall, from the front up to the second floor.
    for i in 0..<14 {
        m.slab("Base Step", x: bx + 17.75, y: 0, z: side * (12 + 3 + Float(i)), w: 4.5, h: 0.5 * Float(i + 1), d: 1, color: trim)
    }
    // A ladder in the back left corner, from the second floor to the third.
    m.part("Base Ladder", at: (bx - 19.3, 10.7, side * (12 + 29.5)), size: (1.2, 7, 1.2), color: "#92400E", material: .wood,
           behavior: .ladder)
    // The sign over the front, which the script writes the owner on.
    let sign = m.part("Base \(k) Sign", at: (bx, 21.5, front), size: (16, 2.4, 0.5), color: trim, material: .neon, solid: false)
    m.label(sign, [("BASE \(k)", "#FFFFFF"), ("あいています", "#E5E7EB")], height: 0.3, size: 1.4, range: 140)
    // Stands: two rows of five on each floor, a collect plate in front of each.
    for (f, top) in memeFloors.enumerated() {
        var s = 0
        for depth in memeStandDepth {
            for ox in memeStandX {
                s += 1
                let z = side * (12 + depth)
                m.slab("Ped \(k)_\(f + 1)_\(s)", x: bx + ox, y: top, z: z, w: 3.2, h: 0.7, d: 3.2, color: "#F8FAFC", material: .stone)
                m.part("Plate \(k)_\(f + 1)_\(s)", at: (bx + ox, top + 0.08, z - side * 2.4), size: (2.6, 0.12, 1.2), color: "#22C55E",
                       material: .neon, behavior: .trigger, tags: ["plate", "k=\(k)", "f=\(f + 1)", "s=\(s)"])
            }
        }
    }
    // The pads at the front: lock (red) on the left, collect everything (gold) on the right.
    let lock = m.pad("Lock \(k)", x: bx - 16, z: side * 15.5, size: 3, color: "#EF4444", tags: ["lock", "k=\(k)"])
    m.label(lock, [("🔒 ロック", "#FCA5A5")], height: 0.6, size: 0.9, range: 30)
    let collect = m.pad("Collect \(k)", x: bx + 11, z: side * 15.5, size: 3, color: "#FACC15", tags: ["collectall", "k=\(k)"])
    m.label(collect, [("💰 ぜんぶ受けとる", "#FDE68A")], height: 0.6, size: 0.9, range: 30)
    // The laser gate, shown while locked.
    m.group("laser\(k)", shown: false) {
        for y in [0.6, 1.4, 2.2, 3.0, 3.8] as [Float] {
            m.part("Laser", at: (bx, y, front + side * 0.2), size: (39, 0.14, 0.14), color: "#EF4444", material: .neon, solid: false)
        }
    }
}

/// A shop with a sign whose words float over it, and a pad in front.
func memeShop(_ m: MapBuilder, _ name: String, x: Float, z: Float, color: String, sign: String, title: String, sub: String, tag: String,
              facing: Float) {
    m.shop(name, x: x, z: z, w: 14, d: 10, color: color, sign: sign, facing: facing)
    let board = m.part("\(name) Board", at: (x, 6.2, z + facing * 5.3), size: (8, 1.4, 0.3), color: sign, material: .neon, solid: false)
    m.label(board, [(title, "#FFFFFF"), (sub, "#FDE68A")], height: 0.3, size: 1.2, range: 80)
    m.pad("\(name) Pad", x: x, z: z + facing * 8, size: 3.2, color: sign, tags: [tag])
}
