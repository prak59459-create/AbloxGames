import Foundation

// Games 111–125: simulators, each after a simulator popular on Roblox
// (docs/research-150.md). They run on lib/kit_sim.absc: tap to train or
// collect, sell, buy better tools, hatch pets, be reborn.

let simGames: [Game] = [
    Game(number: 115, id: "tap-race-clicker", title: "Tap Race Clicker",
         summary: "タップタイムに いっぱいタップして速さをためて、レースで いっきに走れ！ 50mごとのゲートをくぐるたびに ごほうび。ペットと生まれかわりで、1500mのコースを走りきろう。",
         tags: ["simulator", "clicker", "racing"], maxPlayers: 12, libs: ["sim", "rounds"], build: tapRaceClicker),
    Game(number: 114, id: "speed-legends-city", title: "Speed Legends City",
         summary: "走れば走るほど速くなる！ 町を走ってステップをため、光る玉とリングを集めよう。くつを強くしてもっと速く、さばくの町・ようがんの谷へ。🏁レースで1位をねらえ！",
         tags: ["simulator", "running", "racing"], maxPlayers: 12, libs: ["sim"], build: speedLegendsCity),
    Game(number: 113, id: "shadow-ninja-legends", title: "Shadow Ninja Legends",
         summary: "刀をふって にんじゅつ をためよう！ 帯がいっぱいになったら ほこらで売ってお金に。ランクが上がると空中ジャンプの回数がふえて、空の修行島へ。刀・帯・ペットで、影の忍者をめざせ！",
         tags: ["simulator", "ninja", "pets"], maxPlayers: 12, libs: ["sim"], build: shadowNinjaLegends),
    Game(number: 112, id: "mega-muscle-legends", title: "Mega Muscle Legends",
         summary: "タップでトレーニング、きんにくムキムキ！ パワーがつくほど体が大きくなる。浜辺のジムから、氷・神話・永遠のジムへ。岩をこわしてお金、アリーナでパンチ勝負。ペットと生まれかわりで最強へ！",
         tags: ["simulator", "training", "pets"], maxPlayers: 12, libs: ["sim"], build: megaMuscleLegends),
    Game(number: 111, id: "bubble-gum-legends", title: "Bubble Gum Legends",
         summary: "ガムをかんで大きなあわをふくらませて売ろう！ あわが大きいほどお金に。空にうかぶ島へバブルジャンプで上がると、もっと高く売れる。たまごからペット、生まれかわってもっと大きく！",
         tags: ["simulator", "pets", "idle"], maxPlayers: 12, libs: ["sim", "ride"], build: bubbleGumLegends),
]

// MARK: 111 Bubble Gum Legends (Bubble Gum Simulator INFINITY)

/// The five islands: centre (x, y, z) and radius. The first is the ground.
let bubbleIslands: [(Float, Float, Float, Float)] = [(0, 0, 0, 60), (40, 30, 40, 20), (-40, 60, 40, 20), (-40, 90, -30, 20), (30, 120, -40, 22)]

func bubbleGumLegends(_ m: MapBuilder) {
    m.sky("#F9A8D4", "#FDF2F8", light: 0.75, showGround: false, fall: -20)
    m.environment.skyStyle = .clouds
    let colors = ["#86EFAC", "#E0F2FE", "#C4B5FD", "#FBCFE8", "#312E81"]
    let tops = ["#4ADE80", "#F8FAFC", "#A78BFA", "#F472B6", "#1E1B4B"]
    for (i, isl) in bubbleIslands.enumerated() {
        let (x, y, z, r) = isl
        let k = i + 1
        m.part("Island \(k)", at: (x, y - 3, z), size: (r * 2, 6, r * 2), color: colors[i], shape: .cylinder, material: i == 0 ? .grass : .matte)
        m.part("Island \(k) Top", at: (x, y + 0.02, z), size: (r * 2 - 2, 0.04, r * 2 - 2), color: tops[i], shape: .cylinder, solid: false)
        m.part("Island \(k) Rock", at: (x, y - 9, z), size: (r * 1.2, 8, r * 1.2), color: colors[i], shape: .cone, solid: false, rotation: (180, 0, 0))
        // Sell pad (worth more higher up), a chest, candies.
        m.pad("Sell \(k)", x: x - r * 0.45, z: z, y: y, size: 4, color: "#FACC15", tags: ["bsell", "k=\(k)"])
        m.part("Sell Sign \(k)", at: (x - r * 0.45, y + 3, z - 2.4), size: (4, 1.2, 0.2), color: "#FACC15", material: .neon, solid: false)
        m.slab("Chest \(k)", x: x + r * 0.45, y: y, z: z - r * 0.3, w: 2.4, h: 1.6, d: 1.6, color: "#B45309", material: .wood)
        m.pad("Chest Pad \(k)", x: x + r * 0.45, z: z - r * 0.3 + 2.2, y: y, size: 2.4, color: "#F59E0B", tags: ["chest", "k=\(k)"])
        for q in 0..<5 {
            let a = Float(q) / 5 * 2 * .pi + 0.4
            m.part("Candy", at: (x + cos(a) * r * 0.7, y + 1, z + sin(a) * r * 0.7), size: (1, 1, 1), color: ["#F472B6", "#38BDF8", "#FACC15", "#4ADE80", "#A78BFA"][q],
                   shape: .sphere, material: .neon, behavior: .trigger, tags: ["candy", "k=\(k)"])
        }
        // A bubble-jump pad to the next island, and where it lands.
        if k < bubbleIslands.count {
            let next = bubbleIslands[k]
            let dx = next.0 - x, dz = next.2 - z
            let len = (dx * dx + dz * dz).squareRoot()
            m.pad("Jump \(k)", x: x + dx / len * r * 0.6, z: z + dz / len * r * 0.6, y: y, size: 3.4, color: "#EC4899", tags: ["bjump", "k=\(k)"])
            m.part("Jump Bubble \(k)", at: (x + dx / len * r * 0.6, y + 2.2, z + dz / len * r * 0.6), size: (2.6, 2.6, 2.6), color: "#F9A8D4", shape: .sphere,
                   material: .glass, solid: false, opacity: 0.45)
            m.part("Land \(k + 1)", at: (next.0 - dx / len * next.3 * 0.5, next.1 + 0.8, next.2 - dz / len * next.3 * 0.5), size: (1, 1, 1), color: "#000000",
                   solid: false, visible: false)
        }
    }
    // The ground island: spawn, the gum machine, the shop and eggs.
    m.spawnRing(0, 8, radius: 4, count: 8, color: "#F472B6")
    m.part("Gum Machine Globe", at: (0, 7, -14), size: (8, 8, 8), color: "#F9A8D4", shape: .sphere, material: .glass, solid: false, opacity: 0.6)
    for q in 0..<12 {
        let a = Float(q) / 12 * 2 * .pi
        m.part("Gumball", at: (cos(a) * 2.2, 6 + Float(q % 3), -14 + sin(a) * 2.2), size: (1.2, 1.2, 1.2), color: ["#EF4444", "#FACC15", "#3B82F6", "#22C55E"][q % 4],
               shape: .sphere, solid: false)
    }
    m.slab("Gum Machine Base", x: 0, y: 0, z: -14, w: 6, h: 3, d: 6, color: "#DC2626")
    m.pad("Shop Pad", x: -8, z: -6, size: 3.4, color: "#3B82F6", tags: ["shop"])
    m.pad("Egg Pad", x: 8, z: -6, size: 3.4, color: "#A855F7", tags: ["eggs"])
    for (i, ex) in [4, 8, 12].enumerated() {
        m.part("Egg Display", at: (Float(ex), 1.2, -10), size: (1.6, 2.2, 1.6), color: ["#F8FAFC", "#FBCFE8", "#312E81"][i], shape: .sphere, solid: false)
    }
    var r = Seeded("bubble")
    for _ in 0..<18 {
        let a = r.range(0, 2 * .pi), d = r.range(30, 55)
        m.tree(cos(a) * d, sin(a) * d, height: r.range(4, 6), leaves: r.pick(["#F472B6", "#4ADE80", "#FACC15"]))
    }
    for _ in 0..<30 {
        m.part("Cloud", at: (r.range(-120, 120), r.range(10, 140), r.range(-120, 120)), size: (r.range(10, 24), r.range(3, 5), r.range(8, 18)),
               color: "#FFFFFF", material: .matte, solid: false, opacity: 0.8)
    }
    m.coverFocus(x: 0, y: 3, z: -8, yaw: 200, width: 30)
}

// MARK: 112 Mega Muscle Legends (Muscle Legends)

/// The four gyms: centre (x, z), size, and colours.
let muscleGyms: [(Float, Float, Float, String, String)] = [(-50, -40, 36, "#FDE68A", "#F59E0B"), (50, -40, 36, "#E0F2FE", "#38BDF8"),
                                                           (50, 50, 36, "#F5D0FE", "#A855F7"), (-50, 50, 36, "#FEF3C7", "#EAB308")]

func megaMuscleLegends(_ m: MapBuilder) {
    m.day(ground: "#FDE68A")
    m.environment.skyStyle = .clouds
    m.ground(260, 260, color: "#FDE68A", material: .sand)
    m.water(0, 125, w: 260, d: 20, name: "Sea", color: "#0EA5E9", tags: ["scenery"])
    m.spawnRing(0, 0, radius: 4, count: 8, color: "#EF4444")
    m.pad("Shop Pad", x: -8, z: 8, size: 3.2, color: "#3B82F6", tags: ["shop"])
    m.pad("Egg Pad", x: 8, z: 8, size: 3.2, color: "#A855F7", tags: ["eggs"])
    m.part("Statue", at: (0, 4, -8), size: (2.4, 8, 2.4), color: "#94A3B8", shape: .cylinder, material: .stone, solid: true)
    m.part("Statue Arms", at: (0, 7.2, -8), size: (6, 1.2, 1.2), color: "#94A3B8", material: .stone, solid: false)
    for (i, g) in muscleGyms.enumerated() {
        let (cx, cz, size, floor, trim) = g
        let k = i + 1
        m.slab("Gym Floor \(k)", x: cx, y: -0.02, z: cz, w: size, h: 0.1, d: size, color: floor)
        // Walls with the doorway facing the middle of the map.
        let h: Float = 3.2, half = size / 2
        let doorZ: Float = cz < 0 ? half : -half
        m.slab("Gym Wall", x: cx, y: 0, z: cz - doorZ, w: size, h: h, d: 0.6, color: trim)
        m.slab("Gym Wall", x: cx - half, y: 0, z: cz, w: 0.6, h: h, d: size, color: trim)
        m.slab("Gym Wall", x: cx + half, y: 0, z: cz, w: 0.6, h: h, d: size, color: trim)
        m.slab("Gym Wall", x: cx - half / 2 - 2.5, y: 0, z: cz + doorZ, w: half - 5, h: h, d: 0.6, color: trim)
        m.slab("Gym Wall", x: cx + half / 2 + 2.5, y: 0, z: cz + doorZ, w: half - 5, h: h, d: 0.6, color: trim)
        m.part("Gate \(k)", at: (cx, 1.8, cz + doorZ), size: (10, 3.6, 1.6), color: trim, material: .neon, behavior: .trigger,
               tags: ["sim_gate", "n=\(k)"], solid: false, opacity: 0.35)
        m.part("Gym Sign \(k)", at: (cx, 4.4, cz + doorZ), size: (10, 1.4, 0.3), color: trim, material: .neon, solid: false)
        // Equipment: benches, racks, a treadmill, big dumbbells.
        for q in 0..<3 {
            let ex = cx - 10 + Float(q) * 10
            m.slab("Bench", x: ex, y: 0, z: cz - doorZ * 0.4, w: 1.4, h: 0.8, d: 3.4, color: "#1F2937")
            m.part("Barbell", at: (ex, 1.6, cz - doorZ * 0.4 - 0.8), size: (4, 0.2, 0.2), color: "#94A3B8", material: .metal, solid: false)
            for sx in [-1.9, 1.9] as [Float] {
                m.part("Plate", at: (ex + sx, 1.6, cz - doorZ * 0.4 - 0.8), size: (0.3, 1.2, 1.2), color: "#111827", shape: .cylinder, solid: false,
                       rotation: (0, 0, 90))
            }
        }
        m.slab("Treadmill", x: cx - 12, y: 0, z: cz + doorZ * 0.2, w: 2.4, h: 0.4, d: 4, color: "#374151")
        m.part("Giant Dumbbell", at: (cx + 12, 1, cz + doorZ * 0.2), size: (5, 1, 1), color: trim, material: .metal, solid: false)
        m.part("Zone \(k)", at: (cx, 0.5, cz), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    }
    // Rocks to smash, stronger ones further out.
    let rocks: [(Float, Float, Float)] = [(-14, -18, 2), (14, -18, 2.6), (-22, 20, 3.2), (22, 20, 3.8), (0, -80, 4.6), (0, 86, 5.5)]
    for (i, rk) in rocks.enumerated() {
        m.part("Rock \(i + 1)", at: (rk.0, rk.2 / 2, rk.1), size: (rk.2 * 1.3, rk.2, rk.2 * 1.3), color: ["#A8A29E", "#78716C", "#57534E", "#7C2D12", "#1E3A8A", "#581C87"][i],
               shape: .sphere, material: .stone)
        m.pad("Rock Pad \(i + 1)", x: rk.0, z: rk.1 + rk.2 * 0.9 + 1.2, size: 2.4, color: "#EF4444", tags: ["rock", "n=\(i + 1)"])
    }
    // The arena.
    m.part("Arena", at: (0, 0.05, 50), size: (26, 0.1, 26), color: "#DC2626", shape: .cylinder, solid: false)
    m.part("Arena Ring", at: (0, 0.3, 50), size: (27, 0.6, 27), color: "#F8FAFC", shape: .cylinder, solid: false, opacity: 0.3)
    m.part("Arena Mark", at: (0, 0.5, 50), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    var r = Seeded("muscle")
    for _ in 0..<20 {
        let x = r.range(-125, 125), z = r.range(-120, 110)
        if abs(x) < 72 && abs(z) < 72 { continue }
        m.pine(x, z, height: r.range(6, 9), leaves: "#16A34A")
    }
    m.coverFocus(x: -50, y: 1.5, z: -40, yaw: 20, width: 36)
}

// MARK: 113 Shadow Ninja Legends (Ninja Legends)

/// The sky islands: centre (x, top y, z) and radius. Higher ones need more air jumps.
let ninjaIslands: [(Float, Float, Float, Float)] = [(10, 10, 6, 7), (-2, 26, 16, 7), (-14, 46, 6, 7), (-4, 72, -8, 8), (12, 104, 2, 9)]

func shadowNinjaLegends(_ m: MapBuilder) {
    m.dusk(ground: "#3F3F46")
    m.environment.skyStyle = .sunset
    m.ground(220, 220, color: "#57534E", material: .stone)
    m.slab("Courtyard", x: 0, y: -0.02, z: 0, w: 70, h: 0.06, d: 70, color: "#D6D3D1", material: .stone)
    m.spawnRing(0, -20, radius: 4, count: 8, color: "#DC2626")
    // The dojo and the shrine where ninjitsu is sold.
    m.slab("Dojo", x: 0, y: 0, z: -34, w: 24, h: 6, d: 12, color: "#7C2D12", material: .wood)
    m.part("Dojo Roof", at: (0, 8, -34), size: (28, 3, 16), color: "#1C1917", shape: .cone, solid: false)
    m.slab("Shrine", x: -26, y: 0, z: -12, w: 8, h: 4, d: 6, color: "#DC2626")
    m.part("Torii", at: (-26, 5.5, -6), size: (9, 0.6, 0.6), color: "#DC2626", solid: false)
    for x in [-29.5, -22.5] as [Float] { m.slab("Torii Post", x: x, y: 0, z: -6, w: 0.6, h: 5.5, d: 0.6, color: "#DC2626") }
    m.pad("Sell 1", x: -26, z: -3, size: 3.6, color: "#FACC15", tags: ["nsell", "k=1"])
    m.pad("Shop Pad", x: 20, z: -12, size: 3.2, color: "#3B82F6", tags: ["shop"])
    m.pad("Egg Pad", x: 26, z: -12, size: 3.2, color: "#A855F7", tags: ["eggs"])
    // Training dummies round the courtyard.
    for q in 0..<8 {
        let a = Float(q) / 8 * 2 * .pi
        m.part("Dummy", at: (cos(a) * 26, 1.2, 10 + sin(a) * 12), size: (0.8, 2.4, 0.8), color: "#A16207", shape: .cylinder, material: .wood)
    }
    // A bamboo grove.
    var r = Seeded("ninja")
    for _ in 0..<60 {
        let x = r.range(-100, 100), z = r.range(-100, 100)
        if abs(x) < 40 && abs(z) < 44 { continue }
        m.part("Bamboo", at: (x, 5, z), size: (0.5, 10, 0.5), color: "#65A30D", shape: .cylinder, solid: false)
    }
    // Sky islands, each with a training ground, a shrine to sell at, and a chest.
    let colors = ["#A3E635", "#38BDF8", "#F472B6", "#FACC15", "#A78BFA"]
    for (i, isl) in ninjaIslands.enumerated() {
        let (x, y, z, rad) = isl
        let k = i + 1
        m.part("Sky Island \(k)", at: (x, y - 1, z), size: (rad * 2, 2, rad * 2), color: "#78716C", shape: .cylinder, material: .stone)
        m.part("Sky Island \(k) Top", at: (x, y + 0.02, z), size: (rad * 2 - 1, 0.04, rad * 2 - 1), color: colors[i], shape: .cylinder, solid: false)
        m.part("Sky Island \(k) Root", at: (x, y - 5, z), size: (rad * 1.3, 6, rad * 1.3), color: "#57534E", shape: .cone, solid: false,
               rotation: (180, 0, 0))
        m.pad("Sell \(k + 1)", x: x - rad * 0.45, z: z, y: y, size: 2.6, color: "#FACC15", tags: ["nsell", "k=\(k + 1)"])
        m.pad("Chest \(k)", x: x + rad * 0.45, z: z, y: y, size: 2.4, color: "#F59E0B", tags: ["nchest", "k=\(k)"])
        m.slab("Chest Box", x: x + rad * 0.45, y: y, z: z + 1.8, w: 1.8, h: 1.2, d: 1.2, color: "#B45309", material: .wood)
        m.part("Island Lantern", at: (x, y + 1.2, z - rad * 0.5), size: (0.8, 1.4, 0.8), color: colors[i], material: .neon, solid: false)
        m.part("Train \(k)", at: (x, y + 0.5, z), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    }
    m.coverFocus(x: 0, y: 3, z: -24, yaw: 200, width: 40)
}

// MARK: 114 Speed Legends City (Legends of Speed)

func speedLegendsCity(_ m: MapBuilder) {
    m.sky("#60A5FA", "#E0F2FE", light: 0.75, showGround: false, fall: -25)
    m.environment.skyStyle = .clouds
    // Three separate lands: the city, the desert (north) and the magma valley (east). Pads carry you between them.
    m.ground(340, 300, color: "#A3A3A3", z: -20, material: .matte)
    m.ground(220, 180, color: "#FCD34D", name: "Desert", z: 300, material: .sand)
    m.ground(200, 200, color: "#7F1D1D", name: "Magma Land", x: 380, z: 0, material: .stone)
    for v in [-80, -40, 0, 40, 80] as [Float] {
        m.road(from: (-100, v), to: (100, v), width: 10, name: "Street")
        m.road(from: (v, -100), to: (v, 100), width: 10, y: 0.025, name: "Street")
    }
    var r = Seeded("speed")
    for bx in [-60, -20, 20, 60] as [Float] {
        for bz in [-60, -20, 20, 60] as [Float] where !(abs(bx) == 20 && abs(bz) == 20) {
            let h = r.range(10, 40)
            m.slab("Tower", x: bx, y: 0, z: bz, w: 22, h: h, d: 22, color: r.pick(["#CBD5E1", "#94A3B8", "#E2E8F0", "#FDE68A", "#BFDBFE"]))
            m.part("Tower Windows", at: (bx, h / 2, bz - 11.1), size: (18, h * 0.8, 0.1), color: "#7DD3FC", material: .glass, solid: false, opacity: 0.5)
        }
    }
    m.slab("Plaza", x: 0, y: -0.01, z: 0, w: 58, h: 0.05, d: 58, color: "#E5E7EB")
    m.spawnRing(0, 0, radius: 4, count: 8, color: "#22D3EE")
    m.pad("Shop Pad", x: -10, z: 10, size: 3.2, color: "#3B82F6", tags: ["shop"])
    m.pad("Egg Pad", x: 10, z: 10, size: 3.2, color: "#A855F7", tags: ["eggs"])
    m.part("Speed Statue", at: (0, 3, -12), size: (2, 6, 2), color: "#FACC15", shape: .cylinder, material: .metal)
    // Travel pads.
    m.pad("Go 2", x: -14, z: -10, size: 3.2, color: "#F59E0B", tags: ["goto", "n=2"])
    m.pad("Go 3", x: 14, z: -10, size: 3.2, color: "#EF4444", tags: ["goto", "n=3"])
    m.part("Arrive 1", at: (0, 0.6, 6), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    m.part("Arrive 2", at: (0, 0.6, 240), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    m.part("Arrive 3", at: (300, 0.6, 0), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    m.pad("Back 2", x: 0, z: 232, size: 3.2, color: "#22D3EE", tags: ["goto", "n=1"])
    m.pad("Back 3", x: 292, z: 0, size: 3.2, color: "#22D3EE", tags: ["goto", "n=1"])
    for _ in 0..<14 { m.part("Lava Pool", at: (r.range(300, 470), 0.05, r.range(-90, 90)), size: (r.range(6, 14), 0.1, r.range(6, 14)), color: "#F97316",
                             shape: .cylinder, material: .neon, solid: false) }
    for _ in 0..<16 { m.pillar("Cactus", x: r.range(-100, 100), z: r.range(230, 380), height: r.range(2, 4), radius: 0.4, color: "#3F6212") }
    for _ in 0..<5 { m.part("Pyramid", at: (r.pick([r.range(-100, -60), r.range(60, 100)]), 8, r.range(260, 370)), size: (18, 16, 18), color: "#D97706", shape: .cone,
                            material: .sand, solid: false) }
    // Orbs to collect in each land, and hoops.
    for (area, cx, cz, w, d) in [(1, Float(0), Float(0), Float(190), Float(190)), (2, 0, 300, 200, 160), (3, 380, 0, 180, 180)] {
        for _ in 0..<(area == 1 ? 40 : 30) {
            let x = cx + r.range(-w / 2, w / 2), z = cz + r.range(-d / 2, d / 2)
            let kind = r.unit() < 0.75 ? "step" : "gem"
            m.part("Orb", at: (x, 1.2, z), size: (1.2, 1.2, 1.2), color: kind == "step" ? ["#EF4444", "#F97316", "#A855F7"][area - 1] : "#22D3EE", shape: .sphere,
                   material: .neon, behavior: .trigger, tags: ["orb", "kind=\(kind)", "area=\(area)"], solid: false)
        }
        for q in 0..<5 {
            let x = cx + r.range(-w / 2 + 10, w / 2 - 10), z = cz + r.range(-d / 2 + 10, d / 2 - 10)
            m.part("Hoop", at: (x, 2.5, z), size: (5, 0.5, 5), color: "#FACC15", shape: .cylinder, material: .neon, behavior: .trigger,
                   tags: ["hoop", "area=\(area)"], solid: false, rotation: (90, Float(q) * 36, 0), opacity: 0.6)
        }
    }
    // The race track: a straight 300 m sprint south of the city.
    m.slab("Race Track", x: 0, y: -0.01, z: -150, w: 320, h: 0.05, d: 16, color: "#B91C1C")
    for q in 0..<9 { m.part("Track Line", at: (-150 + Float(q) * 37.5, 0.05, -150), size: (0.4, 0.02, 16), color: "#F8FAFC", solid: false) }
    m.pad("Race Pad", x: 0, z: -112, size: 4, color: "#EF4444", tags: ["race_join"])
    m.part("Race Start", at: (-150, 0.6, -150), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    m.part("Race Finish", at: (150, 2, -150), size: (2, 4, 16), color: "#FACC15", material: .neon, behavior: .trigger, tags: ["race_finish"], solid: false,
           opacity: 0.4)
    m.part("Finish Arch", at: (150, 6, -150), size: (1, 1, 18), color: "#FACC15", material: .neon, solid: false)
    m.coverFocus(x: 0, y: 2, z: -30, yaw: 200, width: 60)
}

// MARK: 115 Tap Race Clicker (Race Clicker)

func tapRaceClicker(_ m: MapBuilder) {
    m.day(ground: "#65A30D")
    m.environment.skyStyle = .clouds
    // The lobby where everyone taps.
    m.ground(90, 70, color: "#84CC16", z: -40, material: .grass)
    m.slab("Lobby", x: 0, y: -0.01, z: -40, w: 60, h: 0.05, d: 44, color: "#E5E7EB")
    m.spawnRing(0, -46, radius: 5, count: 10, color: "#F97316")
    m.pad("Shop Pad", x: -14, z: -30, size: 3.2, color: "#3B82F6", tags: ["shop"])
    m.pad("Egg Pad", x: 14, z: -30, size: 3.2, color: "#A855F7", tags: ["eggs"])
    m.part("Big Button", at: (0, 1, -60), size: (8, 2, 8), color: "#EF4444", shape: .cylinder, material: .neon)
    m.part("Big Button Base", at: (0, 0.3, -60), size: (10, 0.6, 10), color: "#1F2937", shape: .cylinder)
    // The track: 1500 m straight, a gate every 50 m, a new colour every 250 m.
    m.ground(40, 1540, color: "#65A30D", name: "Track Ground", z: 760, material: .grass)
    m.slab("Track", x: 0, y: -0.01, z: 760, w: 16, h: 0.05, d: 1530, color: "#B91C1C")
    m.part("Start Line", at: (0, 0.05, 0), size: (16, 0.02, 1), color: "#F8FAFC", solid: false)
    m.part("Race Start", at: (0, 0.6, -4), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    let zoneColors = ["#22C55E", "#0EA5E9", "#F59E0B", "#A855F7", "#EF4444", "#FACC15"]
    for k in 1...30 {
        let z = Float(k) * 50
        let c = zoneColors[min(5, (k - 1) / 5)]
        m.part("Gate \(k)", at: (0, 3, z), size: (16, 6, 1.5), color: c, material: .neon, behavior: .trigger, tags: ["rgate", "n=\(k)"], solid: false,
               opacity: 0.25)
        for x in [-8.5, 8.5] as [Float] { m.part("Gate Post", at: (x, 3.5, z), size: (1, 7, 1), color: c, material: .neon, solid: false) }
        m.part("Gate Top", at: (0, 7, z), size: (18, 1, 1), color: c, material: .neon, solid: false)
    }
    var r = Seeded("taprace")
    for q in 0..<60 {
        let side: Float = q % 2 == 0 ? -1 : 1
        m.tree(side * r.range(11, 18), Float(q) * 25 + r.range(0, 20), height: r.range(4, 6))
    }
    m.coverFocus(x: 0, y: 2, z: 30, yaw: 200, width: 30)
}
