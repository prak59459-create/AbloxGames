import Foundation

// More arenas for #78 Last Survivor Games, from the suggestion box: the
// three-legged race for five, hide-and-seek in a two-floor house under a
// painted night sky, the jump-rope bridge and the sky towers. Called from
// survivorGames; each arena keeps to its own corner of the map.

func survivorMoreArenas(_ m: MapBuilder) {
    // 5人6脚 — twenty lanes, 110 m, a tie for each team (moved by the script).
    let relayX: Float = 400
    m.ground(124, 134, color: "#B45309", name: "Relay Ground", x: relayX, z: 0, material: .sand)
    for k in 0...20 {
        let x = relayX + (Float(k) - 10) * 5
        m.part("Relay Lane Line", at: (x, 0.03, 0), size: (0.18, 0.02, 116), color: "#FEF3C7", solid: false)
    }
    for k in 1...20 {
        let x = relayX + (Float(k) - 10.5) * 5
        m.part("Relay Lane \(k)", at: (x, 0.1, -55), size: (1, 0.2, 1), color: "#000000", solid: false, visible: false)
        m.part("Relay Tie \(k)", at: (x, 0.35, -55), size: (4.2, 0.18, 0.25), color: k % 2 == 0 ? "#DC2626" : "#2563EB",
               solid: false, visible: false)
        let number = m.part("Relay Number \(k)", at: (x, 0.04, -59), size: (2.4, 0.04, 2.4), color: "#FDE68A", shape: .cylinder,
                            solid: false)
        m.label(number, [("\(k)", "#111827")], height: 0.2, size: 0.8, range: 40)
    }
    m.part("Relay Start Line", at: (relayX, 0.05, -56), size: (101, 0.03, 0.6), color: "#F8FAFC", material: .neon, solid: false)
    for k in 0..<20 {
        m.part("Relay Goal Line", at: (relayX + (Float(k) - 9.5) * 5, 0.05, 55), size: (5, 0.03, 0.8),
               color: k % 2 == 0 ? "#111827" : "#F8FAFC", solid: false)
    }
    for x: Float in [relayX - 52, relayX + 52] {
        m.pillar("Relay Goal Post", x: x, z: 55, height: 9, radius: 0.5, color: "#F8FAFC")
    }
    let banner = m.part("Relay Banner", at: (relayX, 9.2, 55), size: (104, 1.6, 0.3), color: "#DC2626", material: .neon, solid: false)
    m.label(banner, [("🏁 GOAL", "#FFFFFF")], height: 0.4, size: 2.2, range: 160)
    m.slab("Relay Gallery", x: relayX + 64, y: 6, z: 0, w: 8, h: 0.6, d: 100, color: "#7C2D12")
    m.slab("Relay Gallery Rail", x: relayX + 60.4, y: 6.6, z: 0, w: 0.3, h: 1, d: 100, color: "#FDE68A")

    // かくれんぼ — a house with two floors, rooms with wide doorways, two
    // staircases, a cage for the seekers and an exit door. The ceiling of
    // the top floor is painted as a night sky.
    let hx: Float = -400, hz: Float = 0
    let w: Float = 60, d: Float = 44
    m.ground(w + 8, d + 8, color: "#1E293B", name: "Hide Yard", x: hx, z: hz)
    m.slab("Hide Floor", x: hx, y: 0, z: hz, w: w, h: 0.1, d: d, color: "#78350F", material: .wood)
    m.walls(hx, hz, w: w, d: d, h: 12.4, color: "#312E81", name: "Hide Wall")
    // The upper floor at 6 m, with a hole over each staircase. The stairs
    // climb toward +x: the west one at z -16 from x -28, the east one at
    // z +16 from x +16.
    let floorPieces: [(x0: Float, x1: Float, z0: Float, z1: Float)] = [
        (-30, 30, -14.5, 14.5), (-30, 30, -22, -17.5), (-30, -28.5, -17.5, -14.5), (-16.5, 30, -17.5, -14.5),
        (-30, 30, 17.5, 22), (-30, 16.5, 14.5, 17.5), (28.5, 30, 14.5, 17.5)
    ]
    for f in floorPieces {
        m.slab("Hide Upper Floor", x: hx + (f.x0 + f.x1) / 2, y: 6, z: hz + (f.z0 + f.z1) / 2, w: f.x1 - f.x0, h: 0.4, d: f.z1 - f.z0,
               color: "#92400E", material: .wood)
    }
    m.stairs(hx - 28, hz - 16, y: 0, steps: 12, rise: 0.53, run: 1, width: 2.8, color: "#B45309", name: "Hide Stair West")
    m.stairs(hx + 16, hz + 16, y: 0, steps: 12, rise: 0.53, run: 1, width: 2.8, color: "#B45309", name: "Hide Stair East")
    // The painted night sky: a dark ceiling, a moon and stars.
    m.slab("Hide Ceiling", x: hx, y: 12, z: hz, w: w, h: 0.4, d: d, color: "#0B1026")
    var rng = Seeded("hide-stars")
    for _ in 0..<46 {
        m.part("Hide Star", at: (hx + rng.range(-28, 28), 11.9, hz + rng.range(-20, 20)), size: (0.35, 0.05, 0.35),
               color: rng.pick(["#FEF9C3", "#FFFFFF", "#BAE6FD"]), shape: .sphere, material: .neon, solid: false)
    }
    m.part("Hide Moon", at: (hx + 14, 11.8, hz - 10), size: (3.2, 0.2, 3.2), color: "#FEF08A", shape: .cylinder, material: .neon, solid: false)
    // Rooms: partitions with doorways four metres wide, on both floors.
    for floorY: Float in [0, 6.4] {
        let h: Float = 5.6
        for x in [hx - 10, hx + 10] {
            m.slab("Hide Partition", x: x, y: floorY, z: hz - 14, w: 0.4, h: h, d: 16, color: "#4338CA")
            m.slab("Hide Partition", x: x, y: floorY, z: hz + 14, w: 0.4, h: h, d: 16, color: "#4338CA")
        }
        m.slab("Hide Partition", x: hx - 20, y: floorY, z: hz, w: 12, h: h, d: 0.4, color: "#4338CA")
        m.slab("Hide Partition", x: hx + 20, y: floorY, z: hz, w: 12, h: h, d: 0.4, color: "#4338CA")
        // Things to hide behind.
        for (dx, dz) in [(-24, -6), (-14, 16), (-4, -18), (6, 16), (16, -16), (25, -14), (-25, 8), (12, 8)] as [(Float, Float)] {
            m.slab("Hide Closet", x: hx + dx, y: floorY, z: hz + dz, w: 2.6, h: 3.2, d: 1.4, color: "#A16207", material: .wood)
        }
        for (dx, dz) in [(-16, -6), (14, 6), (0, -8), (-2, 9)] as [(Float, Float)] {
            m.slab("Hide Bed", x: hx + dx, y: floorY, z: hz + dz, w: 3.4, h: 0.8, d: 2, color: "#BE185D")
            m.slab("Hide Crate", x: hx + dx + 2.6, y: floorY, z: hz + dz + 1.6, w: 1.4, h: 1.4, d: 1.4, color: "#9A6B3E", material: .wood)
        }
        for (dx, dz) in [(-6, 0), (8, -2)] as [(Float, Float)] {
            m.part("Hide Lamp", at: (hx + dx, floorY + 5.4, hz + dz), size: (0.8, 0.4, 0.8), color: "#FDE68A", shape: .sphere,
                   material: .neon, solid: false)
        }
    }
    // The seekers' cage in the middle of the ground floor; its bars open.
    m.slab("Seeker Room", x: hx, y: 0.05, z: hz, w: 6, h: 0.1, d: 6, color: "#7F1D1D", material: .neon)
    for (bx, bz, bw, bd) in [(hx, hz - 3, Float(6.2), Float(0.2)), (hx, hz + 3, 6.2, 0.2), (hx - 3, hz, 0.2, 6.2), (hx + 3, hz, 0.2, 6.2)] {
        m.slab("Seeker Bars", x: bx, y: 0, z: bz, w: bw, h: 4, d: bd, color: "#EF4444", material: .metal, tags: ["bars"], opacity: 0.6)
    }
    // Where hiders start, where the keys may be, and the way out.
    var starts: [(Float, Float, Float)] = []
    for (dx, dz) in [(-24, -10), (-24, 10), (24, -10), (24, 12), (-4, -14), (4, 14), (-14, 0), (14, 0)] as [(Float, Float)] {
        starts.append((hx + dx, 0.4, hz + dz))
        starts.append((hx + dx, 6.8, hz + dz))
    }
    for (i, s) in starts.enumerated() {
        m.part("Hide Spawn \(i + 1)", at: s, size: (0.6, 0.2, 0.6), color: "#000000", tags: ["hidespawn"], solid: false, visible: false)
    }
    let keySpots: [(Float, Float, Float)] = [(-27, 1, -20), (27, 1, 20), (-27, 7.4, 20), (27, 7.4, -20), (0, 1, 20), (0, 7.4, -20),
                                            (-15, 1, -2), (15, 7.4, 2), (-8, 7.4, 18), (8, 1, -18), (-20, 1, 1.2), (20, 7.4, -1.2),
                                            (-24, 7.4, -10), (24, 1, 6)]
    for (i, k) in keySpots.enumerated() {
        m.part("Key Spot \(i + 1)", at: (hx + k.0, k.1, hz + k.2), size: (0.4, 0.4, 0.4), color: "#000000", tags: ["keyspot"], solid: false,
               visible: false)
    }
    for k in 1...3 {
        let key = m.part("Hide Key \(k)", at: (hx, -20, hz), size: (0.9, 0.9, 0.3), color: "#FACC15", material: .neon,
                         behavior: .trigger, tags: ["hidekey"], solid: false, visible: false)
        m.animate(key, .spin, speed: 1.2)
    }
    m.slab("Exit Door", x: hx, y: 0, z: hz - d / 2, w: 4, h: 4.4, d: 1.2, color: "#DC2626", material: .metal)
    let exitSign = m.part("Exit Sign", at: (hx, 5.2, hz - d / 2 + 0.7), size: (3, 0.8, 0.1), color: "#22C55E", material: .neon, solid: false)
    m.label(exitSign, [("🚪 出口（🔑×3）", "#FFFFFF")], height: 0.2, size: 0.8, range: 30)
    m.part("Exit Pad", at: (hx, 1, hz - d / 2 + 1.4), size: (4, 2, 1.2), color: "#22C55E", behavior: .trigger, tags: ["exit"], solid: false,
           opacity: 0.25)
    m.slab("Hide Gallery", x: hx + 38, y: 7, z: hz, w: 8, h: 0.6, d: 40, color: "#1E1B4B")
    m.slab("Hide Gallery Rail", x: hx + 34.4, y: 7.6, z: hz, w: 0.3, h: 1, d: 40, color: "#A5B4FC")

    // 大なわとびの橋 — fifty metres of planks over a pit, a hole somewhere,
    // and two giant dolls turning the rope.
    let rz0: Float = 374
    m.slab("Rope Pit", x: 0, y: -1, z: 400, w: 44, h: 1, d: 100, color: "#0F172A", tags: ["ground"])
    m.slab("Rope Start", x: 0, y: 20, z: rz0 - 5, w: 12, h: 1, d: 10, color: "#6B7280")
    m.slab("Rope Start Base", x: 0, y: 0, z: rz0 - 5, w: 6, h: 20, d: 6, color: "#374151")
    for k in 0..<25 {
        m.slab("Rope Bridge \(k + 1)", x: 0, y: 20.6, z: rz0 + 1 + Float(k) * 2, w: 4, h: 0.4, d: 1.94, color: k % 2 == 0 ? "#A16207" : "#92400E",
               material: .wood, tags: ["ropebridge"])
    }
    m.slab("Rope End", x: 0, y: 20, z: rz0 + 55, w: 12, h: 1, d: 10, color: "#6B7280")
    m.slab("Rope End Base", x: 0, y: 0, z: rz0 + 55, w: 6, h: 20, d: 6, color: "#374151")
    m.pad("Rope Goal", x: 0, z: rz0 + 56, y: 21, size: 6, color: "#22C55E", tags: ["ropegoal"])
    m.part("Jump Rope", at: (0, 29.8, 400), size: (0.45, 56, 0.45), color: "#F97316", shape: .cylinder, material: .neon, solid: false,
           rotation: (90, 0, 0))
    for (name, z, face) in [("A", rz0 - 9, Float(1)), ("B", rz0 + 59, -1)] {
        m.slab("Rope Doll Stand \(name)", x: 0, y: 0, z: z, w: 5, h: 21, d: 5, color: "#334155")
        m.part("Rope Doll \(name)", at: (0, 26, z), size: (3.4, 9, 2.4), color: "#F97316", shape: .cylinder)
        m.part("Rope Doll Head \(name)", at: (0, 32.6, z), size: (4, 4, 4), color: "#FDE68A", shape: .sphere)
        m.part("Rope Doll Hair \(name)", at: (0, 34, z - face * 0.4), size: (4.2, 2, 4.2), color: "#111827", shape: .sphere, solid: false)
        m.part("Rope Doll Arm \(name)", at: (0, 26.5, z + face * 2.4), size: (0.9, 0.9, 4), color: "#FDE68A", solid: false)
    }
    m.slab("Rope Gallery", x: 15, y: 24, z: 400, w: 6, h: 0.6, d: 40, color: "#1E293B")
    m.slab("Rope Gallery Rail", x: 12.2, y: 24.6, z: 400, w: 0.3, h: 1, d: 40, color: "#94A3B8")

    // 空のタワー — three towers, each higher and smaller than the last.
    let towers: [(x: Float, y: Float, r: Float, color: String)] = [(360, 36, 8, "#38BDF8"), (400, 46, 6.5, "#A78BFA"), (440, 56, 5, "#F472B6")]
    m.slab("Towers Ground", x: 400, y: -1, z: 300, w: 120, h: 1, d: 50, color: "#86EFAC", tags: ["ground"])
    for (i, t) in towers.enumerated() {
        m.pillar("Sky Tower Pillar \(i + 1)", x: t.x, z: 300, height: t.y - 0.3, radius: 1.6, color: "#E2E8F0")
        m.part("Sky Tower \(i + 1)", at: (t.x, t.y, 300), size: (t.r * 2, 0.6, t.r * 2), color: t.color, shape: .cylinder,
               tags: ["skytower"])
        m.part("Sky Tower Rim \(i + 1)", at: (t.x, t.y - 0.35, 300), size: (t.r * 2 + 0.4, 0.2, t.r * 2 + 0.4), color: "#FDE047",
               shape: .cylinder, material: .neon, solid: false)
        let sign = m.part("Sky Tower Sign \(i + 1)", at: (t.x, t.y + 6, 300), size: (0.4, 0.4, 0.4), color: t.color, solid: false,
                          opacity: 0.05)
        m.label(sign, [("🗼 \(i + 1)", "#FFFFFF")], height: 0.2, size: 1.4, range: 120)
    }
    var clouds = Seeded("tower-clouds")
    for _ in 0..<14 {
        m.part("Tower Cloud", at: (clouds.range(340, 460), clouds.range(22, 44), clouds.range(276, 324)),
               size: (clouds.range(6, 12), clouds.range(2, 4), clouds.range(5, 9)), color: "#F8FAFC", shape: .sphere, solid: false,
               opacity: 0.7)
    }
    m.slab("Towers Gallery", x: 400, y: 40, z: 332, w: 50, h: 0.6, d: 6, color: "#1E3A8A")
    m.slab("Towers Gallery Rail", x: 400, y: 40.6, z: 329.2, w: 50, h: 1, d: 0.3, color: "#BFDBFE")
}
