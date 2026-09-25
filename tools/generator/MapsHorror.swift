import Foundation

// 46–58: horror, survival and escape.

let horrorGames: [Game] = [
    Game(number: 46, id: "color-monsters", title: "Color Monsters",
         summary: "夜のおもちゃ倉庫で5色のモンスターから隠れて、夜ごとの任務（ブロック・ヒューズ・電池・ガス・ロケットの部品）を集めよう。箱やロッカーに隠れ、つかまった仲間は檻から助けて、5夜目にロケットで脱出！",
         tags: ["horror", "hide", "coop"], maxPlayers: 8, build: colorMonsters),
    Game(number: 47, id: "porkys-house", title: "Porky's House",
         summary: "毎回ちがう場所にあるカギ・ハンマー・レンチを見つけてドアを開け、玄関（出口のカギ＋暗号）か車庫の車で脱出するなぞ解きホラー。ブタの怪物はわなをしかけて追ってくる。クローゼットに隠れて、幽霊になっても仲間を助けよう！",
         tags: ["horror", "puzzle", "escape"], maxPlayers: 8, build: porkysHouse),
    Game(number: 48, id: "run-from-faces", title: "Run From The Faces",
         summary: "巨大な顔がものすごい速さで追いかけてくる！全力で逃げて、つかまった仲間は助け起こそう。3分生きのびたら勝ち。",
         tags: ["chase", "coop", "funny"], maxPlayers: 12, build: runFaces),
    Game(number: 49, id: "anomaly-hallway", title: "Anomaly Hallway",
         summary: "終わらない病院の廊下。いつもとちがう「異変」があれば引き返し、なければ進む。8回続けて正解すれば出口へ。",
         tags: ["horror", "puzzle", "observe"], maxPlayers: 6, build: anomalyHallway),
    Game(number: 50, id: "last-train-west", title: "Last Train West",
         summary: "荒野を走る最後の列車。石炭をくべて走らせ、駅で物資を集め、夜におそってくる怪物から列車を守りぬけ。",
         tags: ["survival", "train", "coop"], maxPlayers: 8, build: lastTrain),
    Game(number: 51, id: "yokai-shrine", title: "Yokai Shrine",
         summary: "夜の神社に散らばった5枚のお札を集めて祭壇へ。仲間のふりをする妖怪に気をつけて…和風ホラー。",
         tags: ["horror", "japanese", "coop"], maxPlayers: 8, build: yokaiShrine),
    Game(number: 52, id: "night-lockdown", title: "Night Lockdown",
         summary: "昼は町で食料と板を集め、夜は家の窓に板を打ちつけて立てこもる。侵入者から家族を守って3夜を生きのびろ。",
         tags: ["survival", "story", "defend"], maxPlayers: 8, build: nightLockdown),
    Game(number: 53, id: "toy-factory-night-shift", title: "Toy Factory Night Shift",
         summary: "おもちゃ工場の夜間警備。カメラで動くおもちゃを見張り、電力を節約しながらドアを閉めて、朝6時まで耐えろ。",
         tags: ["horror", "cameras", "coop"], maxPlayers: 6, build: toyFactory),
    Game(number: 54, id: "midnight-guard", title: "Midnight Guard",
         summary: "真夜中の施設を見回る警備員。発電機を動かし続け、懐中電灯で怪異を追い払え。",
         tags: ["horror", "guard", "coop"], maxPlayers: 8, build: midnightGuard),
    Game(number: 55, id: "endless-rooms", title: "Endless Rooms",
         summary: "どこまでも続く黄色い部屋の迷路。徘徊する何かから逃げながら出口を探し、次のレベルへ進め。",
         tags: ["horror", "maze", "explore"], maxPlayers: 8, build: endlessRooms),
    Game(number: 56, id: "infinite-store", title: "Infinite Store",
         summary: "終わりのない巨大家具店。昼は家具を集めて基地を作り、夜は店員の怪物から基地を守れ。何日生きのびられる？",
         tags: ["survival", "build", "horror"], maxPlayers: 10, build: infiniteStore),
    Game(number: 57, id: "smile-outbreak", title: "Smile Outbreak",
         summary: "笑顔に感染した人が追いかけてくるパンデミック鬼ごっこ。ワクチンを見つけて感染者を元にもどせ！",
         tags: ["tag", "infection", "party"], maxPlayers: 12, build: smileOutbreak),
    Game(number: 58, id: "watch-the-house", title: "Watch The House",
         summary: "ひとけのない家で、窓やドアに近づく何かを見張る。カメラと懐中電灯で追い払い、5夜を乗り切れ。",
         tags: ["horror", "cameras", "hard"], maxPlayers: 6, build: watchHouse),
]

// MARK: 46 Color Monsters

func colorMonsters(_ m: MapBuilder) {
    m.sky("#050816", "#1E1B4B", light: 0.3, ground: "#111827", sunPitch: -20)
    m.ground(140, 140, color: "#1F2937", name: "Warehouse Floor")
    m.walls(0, 0, w: 140, d: 140, h: 12, color: "#374151", name: "Warehouse Wall")
    m.slab("Warehouse Roof", x: 0, y: 12, z: 0, w: 141, h: 0.4, d: 141, color: "#111827")

    // The start room: the monsters never come in. A wide doorway to the north.
    m.slab("Start Room", x: 0, y: 0, z: -60, w: 30, h: 0.1, d: 20, color: "#4B5563")
    m.slab("Start Wall", x: -9.5, y: 0, z: -50, w: 11, h: 5, d: 0.6, color: "#6B7280")
    m.slab("Start Wall", x: 9.5, y: 0, z: -50, w: 11, h: 5, d: 0.6, color: "#6B7280")
    m.slab("Start Wall", x: -15, y: 0, z: -60, w: 0.6, h: 5, d: 20, color: "#6B7280")
    m.slab("Start Wall", x: 15, y: 0, z: -60, w: 0.6, h: 5, d: 20, color: "#6B7280")
    m.part("Safe Sign", at: (0, 5.8, -50), size: (8, 1, 0.2), color: "#22C55E", material: .neon, solid: false)
    m.spawnRing(0, -62, radius: 4, count: 8, color: "#FDE68A")
    m.pad("Delivery Chute", x: 0, z: -54, size: 3.4, color: "#22C55E", tags: ["chute"])

    // Storage aisles.
    let shelfColors = ["#6B7280", "#4B5563", "#78350F"]
    var k = 0
    for gx in stride(from: Float(-45), through: 45, by: 18) {
        for gz in stride(from: Float(-35), through: 35, by: 14) {
            if abs(gx) < 10 && gz > 25 { continue }
            k += 1
            m.slab("Shelf \(k)", x: gx, y: 0, z: gz, w: 11, h: 3.6, d: 1.6, color: shelfColors[k % 3])
            m.slab("Shelf Toys \(k)", x: gx, y: 3.6, z: gz, w: 9, h: 0.9, d: 1.2,
                   color: ["#F472B6", "#FACC15", "#34D399", "#60A5FA", "#A78BFA"][k % 5], solid: false)
        }
    }

    // Lockers along the west wall, and vents in the floor.
    for i in 0..<6 {
        let z = -36 + Float(i) * 15
        m.slab("Locker \(i + 1) Box", x: -67.5, y: 0, z: z, w: 3, h: 3.4, d: 2.6, color: "#475569")
        m.pad("Locker \(i + 1)", x: -64.5, z: z, size: 2.4, color: "#94A3B8", tags: ["locker"])
    }
    let vents: [(Float, Float)] = [(-27, -12), (27, -12), (-27, 30), (27, 30), (54, 5), (-54, 5)]
    for (i, v) in vents.enumerated() {
        m.part("Vent \(i + 1)", at: (v.0, 0.05, v.1), size: (2.4, 0.1, 2.4), color: "#0B0B0F", material: .metal,
               behavior: .trigger, tags: ["vent"])
    }

    // The pantry (food for Orange) and its bowls.
    // Walls on three sides and half of the fourth: the doorway faces west.
    m.slab("Pantry Wall", x: 56, y: 0, z: -26, w: 20.6, h: 4, d: 0.6, color: "#92400E")
    m.slab("Pantry Wall", x: 56, y: 0, z: -42, w: 20.6, h: 4, d: 0.6, color: "#92400E")
    m.slab("Pantry Wall", x: 66, y: 0, z: -34, w: 0.6, h: 4, d: 16, color: "#92400E")
    m.slab("Pantry Wall", x: 46, y: 0, z: -39.5, w: 0.6, h: 4, d: 5, color: "#92400E")
    m.slab("Pantry Wall", x: 46, y: 0, z: -28.5, w: 0.6, h: 4, d: 5, color: "#92400E")
    m.pad("Food Crate", x: 56, z: -34, size: 3, color: "#F97316", tags: ["food"])
    m.markers("Food Bowl", points: [(-36, 20), (38, 42), (0, 12)], color: "#FB923C", tags: ["bowl"], size: 2.6)

    // The cage, where caught players wait for a friend to pull the lever.
    m.slab("Cage Floor", x: -56, y: 0, z: 56, w: 20, h: 0.1, d: 20, color: "#450A0A")
    for (x, z, w, d) in [(-56, 46, 20, 0.6), (-66, 56, 0.6, 20), (-46, 56, 0.6, 20), (-56, 66, 20, 0.6)] as [(Float, Float, Float, Float)] {
        m.slab("Cage Bars", x: x, y: 0, z: z, w: w, h: 6, d: d, color: "#9CA3AF", material: .metal, opacity: 0.55)
    }
    m.pad("Cage Lever", x: -40, z: 46, size: 2.6, color: "#EF4444", tags: ["lever"])
    m.part("Cage Spot", at: (-56, 0.5, 58), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)

    // The machine room: fuse boxes and the generator.
    m.slab("Machine Floor", x: 54, y: 0, z: 54, w: 28, h: 0.1, d: 28, color: "#1E3A8A")
    m.pad("Generator", x: 54, z: 58, size: 4, color: "#38BDF8", tags: ["generator"])
    m.part("Generator Body", at: (54, 1.6, 64), size: (6, 3.2, 3), color: "#334155", material: .metal)
    for (i, z) in [44, 54, 64].enumerated() {
        m.part("Fuse Box \(i + 1) Panel", at: (69.3, 2.5, Float(z)), size: (0.4, 2, 1.6), color: "#FACC15")
        m.pad("Fuse Box \(i + 1)", x: 66.5, z: Float(z), size: 2.6, color: "#FDE047", tags: ["fusebox"])
    }

    // The rocket at the back: the way out on the last night.
    m.part("Rocket Body", at: (0, 6, 62), size: (4, 10, 4), color: "#E5E7EB", shape: .cylinder, material: .metal)
    m.part("Rocket Nose", at: (0, 12.5, 62), size: (4, 3, 4), color: "#EF4444", shape: .cone)
    for (dx, dz) in [(-2.6, 0), (2.6, 0), (0, -2.6)] as [(Float, Float)] {
        m.part("Rocket Fin", at: (dx, 1.6, 62 + dz), size: (dx == 0 ? 3 : 0.4, 3, dz == 0 ? 3 : 0.4), color: "#EF4444")
    }
    m.pad("Rocket", x: 0, z: 55, size: 5, color: "#F43F5E", tags: ["rocket"])

    // A playground corner, for colour.
    m.slab("Playground", x: -40, y: 0, z: -34, w: 22, h: 0.08, d: 16, color: "#DB2777")
    m.stairs(-48, -30, steps: 4, rise: 0.6, run: 1.2, width: 2.4, color: "#FACC15", name: "Slide Step")
    m.slab("Slide", x: -39, y: 1.2, z: -30, w: 6, h: 0.3, d: 2.4, color: "#38BDF8", rotation: (0, 0, -18))
    for (i, c) in ["#EF4444", "#F59E0B", "#22C55E", "#3B82F6"].enumerated() {
        m.part("Ball Pit Ball", at: (-34 + Float(i), 0.5, -38 + Float(i % 2)), size: (0.9, 0.9, 0.9), color: c, shape: .sphere, solid: false)
    }

    // Where things turn up, where the monsters start, and Blue's rounds.
    var r = Seeded("rainbow")
    var spots: [(Float, Float)] = []
    for gx in stride(from: Float(-54), through: 54, by: 18) {
        for gz in stride(from: Float(-28), through: 42, by: 14) { spots.append((gx + r.range(-3, 3), gz)) }
    }
    m.markers("Part Spot", points: spots, color: "#000000", visible: false, behavior: .none)
    m.markers("Monster Spot", points: [(-40, 30), (40, 30), (0, 40), (-50, -10), (50, -10)], color: "#000000", visible: false, behavior: .none)
    m.markers("Patrol", points: [(-54, -42), (-54, 42), (-18, 42), (18, 42), (54, 42), (54, -42), (18, -42), (-18, -42), (0, 0), (-36, 0), (36, 0)],
              color: "#000000", visible: false, behavior: .none)
    for i in 0..<9 {
        let x = -48 + Float(i % 3) * 48
        let z = -30 + Float(i / 3) * 34
        m.part("Ceiling Light", at: (x, 11.5, z), size: (4, 0.3, 4), color: "#C4B5FD", material: .neon, solid: false)
    }
}

// MARK: 47 Porky's House

func porkysHouse(_ m: MapBuilder) {
    m.night(ground: "#1C1917")
    m.ground(110, 90, color: "#292524", name: "Yard")
    m.slab("House Floor", x: 0, y: 0, z: 0, w: 48, h: 0.3, d: 36, color: "#57534E")
    m.slab("House Roof", x: 7, y: 5.3, z: 0, w: 63, h: 0.4, d: 37, color: "#292524")
    let wall = "#78716C", inner = "#A8A29E", y: Float = 0.3, h: Float = 4.7
    // Outer walls, with the front door in the north wall and the kitchen's
    // east side opening into the garage.
    m.slab("Outer Wall", x: 0, y: y, z: -18, w: 48.6, h: h, d: 0.6, color: wall)
    m.slab("Outer Wall", x: -24, y: y, z: 0, w: 0.6, h: h, d: 36, color: wall)
    m.slab("Outer Wall", x: -13.25, y: y, z: 18, w: 21.5, h: h, d: 0.6, color: wall)
    m.slab("Outer Wall", x: 13.25, y: y, z: 18, w: 21.5, h: h, d: 0.6, color: wall)
    m.slab("Outer Wall", x: 0, y: 3.1, z: 18, w: 5, h: 1.9, d: 0.6, color: wall)
    m.slab("Outer Wall", x: 24, y: y, z: 9, w: 0.6, h: h, d: 18, color: wall)
    m.slab("Outer Wall", x: 24, y: y, z: -15, w: 0.6, h: h, d: 6, color: wall)
    m.slab("Outer Wall", x: 24, y: y, z: -3, w: 0.6, h: h, d: 6, color: wall)
    // Inner walls: a doorway in each, some of them locked.
    func splitWall(alongX: Bool, fixed: Float, from a: Float, to b: Float, gap: Float) {
        let g0 = gap - 1.6, g1 = gap + 1.6
        if alongX {
            m.slab("Inner Wall", x: (a + g0) / 2, y: y, z: fixed, w: g0 - a, h: h, d: 0.5, color: inner)
            m.slab("Inner Wall", x: (g1 + b) / 2, y: y, z: fixed, w: b - g1, h: h, d: 0.5, color: inner)
        } else {
            m.slab("Inner Wall", x: fixed, y: y, z: (a + g0) / 2, w: 0.5, h: h, d: g0 - a, color: inner)
            m.slab("Inner Wall", x: fixed, y: y, z: (g1 + b) / 2, w: 0.5, h: h, d: b - g1, color: inner)
        }
    }
    splitWall(alongX: true, fixed: 0, from: -24, to: -8, gap: -16)   // bedroom ↔ study (red door)
    splitWall(alongX: true, fixed: 0, from: -8, to: 8, gap: 0)       // living ↔ foyer (boards)
    splitWall(alongX: true, fixed: 0, from: 8, to: 24, gap: 16)      // kitchen ↔ bathroom (blue door)
    splitWall(alongX: false, fixed: -8, from: -18, to: 0, gap: -9)   // bedroom ↔ living
    splitWall(alongX: false, fixed: 8, from: -18, to: 0, gap: -9)    // living ↔ kitchen
    splitWall(alongX: false, fixed: -8, from: 0, to: 18, gap: 9)     // study ↔ foyer
    splitWall(alongX: false, fixed: 8, from: 0, to: 18, gap: 9)      // foyer ↔ bathroom
    // The locks.
    let locks: [(String, Float, Float, Bool, String)] = [
        ("Red Door", -16, 0, true, "#DC2626"), ("Wooden Boards", 0, 0, true, "#92400E"), ("Blue Door", 16, 0, true, "#2563EB"),
        ("Garage Grate", 24, -9, false, "#9CA3AF"), ("Exit Door", 0, 18, true, "#F59E0B")
    ]
    for l in locks {
        // Inner doorways are 3.2 m; the front door and the grate fill wider gaps.
        let span: Float = l.0 == "Exit Door" ? 5.2 : (l.0 == "Garage Grate" ? 6.2 : 3.2)
        m.slab(l.0, x: l.1, y: y, z: l.2, w: l.3 ? span : 0.4, h: l.0 == "Exit Door" ? 2.9 : 2.8, d: l.3 ? 0.4 : span, color: l.4, tags: ["lock"])
    }
    m.pad("Keypad", x: 3.5, z: 16, y: y, size: 1.6, color: "#22D3EE", tags: ["keypad"])

    // Rooms and their furniture.
    m.spawnRing(-16, -10, y: y, radius: 2.5, count: 6, color: "#FDE68A")
    m.slab("Bed", x: -20, y: y, z: -15, w: 4, h: 0.8, d: 2.6, color: "#7F1D1D")
    m.slab("Sofa", x: 0, y: y, z: -15, w: 6, h: 1, d: 1.6, color: "#1E3A8A")
    m.slab("Table", x: 0, y: y, z: -8, w: 3, h: 0.9, d: 2, color: "#78350F")
    m.slab("Counter", x: 20, y: y, z: -15, w: 6, h: 1.1, d: 1.4, color: "#E7E5E4")
    m.slab("Stove", x: 12, y: y, z: -16, w: 2, h: 1, d: 1.6, color: "#44403C")
    m.slab("Desk", x: -20, y: y, z: 14, w: 3.5, h: 0.9, d: 1.6, color: "#78350F")
    m.slab("Bookshelf", x: -12, y: y, z: 17, w: 5, h: 3, d: 0.8, color: "#451A03")
    m.slab("Bathtub", x: 20, y: y, z: 14, w: 4, h: 0.8, d: 2, color: "#F8FAFC")
    m.slab("Rug", x: 0, y: y, z: 9, w: 6, h: 0.03, d: 4, color: "#9F1239", solid: false)
    for (i, c) in [(-22, -4), (12, -3), (-12, 4), (20, 4)].enumerated() {
        m.slab("Closet \(i + 1) Box", x: Float(c.0), y: y, z: Float(c.1), w: 2.2, h: 3, d: 1.2, color: "#57534E")
        m.pad("Closet \(i + 1)", x: Float(c.0), z: Float(c.1) + (c.1 < 0 ? -1.6 : 1.6), y: y, size: 1.8, color: "#6B7280", tags: ["closet"])
    }
    m.part("Clock", at: (-2, 3.4, 17.6), size: (1.6, 1.6, 0.2), color: "#FDE68A", shape: .cylinder, material: .neon,
           solid: false, rotation: (90, 0, 0))

    // The garage: the other way out.
    m.slab("Garage Floor", x: 31, y: 0, z: -9, w: 14, h: 0.3, d: 18, color: "#44403C")
    m.slab("Garage Wall", x: 31, y: y, z: -18, w: 14.6, h: h, d: 0.6, color: wall)
    m.slab("Garage Wall", x: 31, y: y, z: 0, w: 14.6, h: h, d: 0.6, color: wall)
    m.slab("Garage Door", x: 38, y: y, z: -9, w: 0.4, h: h, d: 18.6, color: "#57534E")
    m.parkedCar("Getaway Car", x: 31, z: -9, yaw: 90, color: "#B91C1C")
    m.pad("Car", x: 31, z: -3.5, y: y, size: 3, color: "#F97316", tags: ["car"])

    // Where the things turn up, room by room. Doors' keys only ever land
    // in the rooms you start with open, so nothing can lock itself away.
    let rooms: [(String, [(Float, Float)])] = [
        ("Bedroom", [(-22, -12), (-12, -16), (-18, -2), (-11, -6)]),
        ("Living", [(-5, -12), (5, -4), (0, -16.5), (-5, -2)]),
        ("Kitchen", [(20, -12), (12, -7), (22, -3), (15, -16.5)]),
        ("Study", [(-22, 10), (-12, 13), (-18, 3), (-10, 8)]),
        ("Foyer", [(-5, 12), (5, 6), (-4, 3)]),
        ("Bathroom", [(22, 10), (12, 14), (18, 3)]),
        ("Garage", [(27, -15), (35, -3), (27, -3)])
    ]
    for room in rooms {
        m.markers("\(room.0) Spot", points: room.1, y: y, color: "#000000", visible: false, behavior: .none)
    }
    m.markers("Porky Walk", points: [(0, -9), (-16, -9), (16, -9), (-16, 9), (0, 9), (16, 9), (31, -9)], y: y,
              color: "#000000", visible: false, behavior: .none)
    m.part("Porky Home", at: (0, 1, -9), size: (1, 0.1, 1), color: "#000000", visible: false)
    m.pad("Escape", x: 0, z: 24, size: 5, color: "#22C55E", tags: ["escape"])
    m.slab("Porch", x: 0, y: 0, z: 21, w: 8, h: 0.2, d: 5, color: "#78350F")
    for i in 0..<6 { m.pine(-40 + Float(i) * 16, 36, height: 8) }
    m.lamp(-5, 22)
    m.lamp(5, 22)
}

// MARK: 48 Run From The Faces

func runFaces(_ m: MapBuilder) {
    m.sky("#FDE68A", "#FEF3C7", light: 0.8, ground: "#A8A29E")
    m.ground(180, 180, color: "#D6D3D1", name: "Mall Floor")
    m.walls(0, 0, w: 180, d: 180, h: 12, color: "#78716C", name: "Mall Wall")
    m.spawnRing(0, 0, radius: 6, count: 12, color: "#60A5FA")
    var r = Seeded("faces")
    for i in 0..<24 {
        m.slab("Kiosk \(i + 1)", x: r.range(-80, 80), y: 0, z: r.range(-80, 80), w: r.range(3, 8), h: r.range(1, 4), d: r.range(3, 8),
               color: r.pick(["#F472B6", "#60A5FA", "#FBBF24", "#34D399"]))
    }
    for i in 0..<6 {
        let x = r.range(-70, 70), z = r.range(-70, 70)
        m.part("Bounce \(i + 1)", at: (x, 0.15, z), size: (3, 0.3, 3), color: "#22C55E", shape: .cylinder, material: .neon, behavior: .bounce)
    }
    m.markers("Face Spawn", points: ring(6, radius: 80), color: "#000000", visible: false, behavior: .none)
}

// MARK: 49 Anomaly Hallway

func anomalyHallway(_ m: MapBuilder) {
    m.indoor(ground: "#000000")
    m.sky("#000000", "#0A0A0A", light: 0.6, showGround: false)
    m.slab("Hall Floor", x: 0, y: -0.3, z: 0, w: 8, h: 0.3, d: 60, color: "#D1D5DB")
    m.slab("Hall Wall L", x: -4, y: 0, z: 0, w: 0.4, h: 4, d: 60, color: "#E5E7EB")
    m.slab("Hall Wall R", x: 4, y: 0, z: 0, w: 0.4, h: 4, d: 60, color: "#E5E7EB")
    m.slab("Hall Ceiling", x: 0, y: 4, z: 0, w: 8.4, h: 0.3, d: 60, color: "#9CA3AF")
    for i in 0..<6 {
        m.part("Ceiling Lamp \(i + 1)", at: (0, 3.8, -25 + Float(i) * 10), size: (2.4, 0.15, 0.6), color: "#F8FAFC", material: .neon, solid: false)
    }
    // The hallway's fixtures: the same every loop, unless one is an anomaly.
    m.part("Door A", at: (-3.8, 1.3, -12), size: (0.2, 2.6, 1.6), color: "#60A5FA", solid: false)
    m.part("Door B", at: (3.8, 1.3, 6), size: (0.2, 2.6, 1.6), color: "#60A5FA", solid: false)
    m.part("Poster", at: (-3.78, 2, 10), size: (0.05, 1.2, 0.9), color: "#F472B6", solid: false)
    m.part("Bench", at: (3, 0.35, -2), size: (1.2, 0.7, 3), color: "#78716C")
    m.part("Plant", at: (-3, 0.8, 20), size: (0.9, 1.6, 0.9), color: "#16A34A", shape: .cone)
    m.part("Exit Sign", at: (0, 3.2, 28), size: (1.6, 0.5, 0.1), color: "#22C55E", material: .neon, solid: false)
    m.part("Fire Extinguisher", at: (3.7, 0.6, 16), size: (0.3, 0.8, 0.3), color: "#DC2626", shape: .cylinder)
    m.part("Clock", at: (-3.78, 2.8, -20), size: (0.05, 0.7, 0.7), color: "#FFFFFF", shape: .cylinder, solid: false, rotation: (0, 0, 90))
    m.part("Anomaly Spot", at: (0, 1, 0), size: (0.5, 0.5, 0.5), color: "#000000", visible: false)
    m.spawnRing(0, -26, radius: 1.5, count: 4, color: "#FDE68A")
    m.pad("Go Forward", x: 0, z: 29, size: 3, color: "#22C55E", tags: ["forward"], shape: .box)
    m.pad("Go Back", x: 0, z: -29.5, size: 2, color: "#EF4444", tags: ["back"], shape: .box)
}

// MARK: 50 Last Train West

func lastTrain(_ m: MapBuilder) {
    m.sunset(ground: "#B45309")
    m.ground(260, 260, color: "#C2410C", name: "Desert")
    // The rails, and the train on them.
    m.part("Rails", at: (0, 0.05, 0), size: (3, 0.1, 260), color: "#57534E", material: .metal, solid: false)
    let cars: [(String, Float, String)] = [("Engine", 18, "#1F2937"), ("Coal Car", 8, "#44403C"), ("Passenger Car", -3, "#7F1D1D"),
                                           ("Cargo Car", -14, "#78350F")]
    for c in cars {
        m.slab(c.0, x: 0, y: 0.6, z: c.1, w: 4, h: 0.4, d: 9.5, color: c.2, tags: ["train"])
        m.slab("\(c.0) Rail L", x: -2, y: 1, z: c.1, w: 0.2, h: 1, d: 9.5, color: "#A8A29E")
        m.slab("\(c.0) Rail R", x: 2, y: 1, z: c.1, w: 0.2, h: 1, d: 9.5, color: "#A8A29E")
    }
    m.slab("Engine Cab", x: 0, y: 1, z: 20, w: 4, h: 3, d: 4, color: "#111827")
    m.part("Smokestack", at: (0, 3.5, 15), size: (1, 2, 1), color: "#27272A", shape: .cylinder)
    m.pad("Boiler", x: 0, z: 17, y: 1, size: 1.8, color: "#F97316", tags: ["boiler"])
    m.pad("Coal Pile", x: 0, z: 8, y: 1, size: 3, color: "#18181B", tags: ["coal"])
    m.spawnRing(0, -3, y: 1, radius: 1.2, count: 6, color: "#FDE68A")
    // The station town, reached by stepping off.
    m.slab("Platform", x: 14, y: 0, z: 0, w: 10, h: 0.6, d: 40, color: "#A8A29E", tags: ["station"])
    for i in 0..<4 {
        m.house("Station Shack \(i + 1)", x: 34, z: -30 + Float(i) * 20, w: 10, d: 10, h: 3.4, wall: "#D6B98C", roof: "#57534E",
                floor: "#A16207", door: false, tags: ["town"], facing: -1)
    }
    m.markers("Loot Spot", points: [(34, -30), (34, -10), (34, 10), (34, 30), (50, 0), (22, 25)], color: "#000000", visible: false, behavior: .none)
    m.markers("Monster Spawn", points: [(-40, -40), (-40, 40), (60, -60), (60, 60), (-60, 0)], color: "#000000", visible: false, behavior: .none)
    var r = Seeded("west")
    for _ in 0..<18 {
        let x = r.range(-120, 120), z = r.range(-120, 120)
        if abs(x) < 50 { continue }
        m.part("Cactus", at: (x, 2, z), size: (0.8, 4, 0.8), color: "#15803D", shape: .cylinder)
    }
}

// MARK: 51 Yokai Shrine

func yokaiShrine(_ m: MapBuilder) {
    m.night(ground: "#0F172A")
    m.sky("#020617", "#1E1B4B", light: 0.25, ground: "#0F172A", sunPitch: -15)
    m.ground(160, 160, color: "#1E293B", name: "Shrine Grounds")
    m.part("Torii", at: (0, 5, -60), size: (12, 0.8, 1), color: "#B91C1C")
    m.pillar("Torii Leg", x: -5, z: -60, height: 5, radius: 0.45, color: "#B91C1C")
    m.pillar("Torii Leg", x: 5, z: -60, height: 5, radius: 0.45, color: "#B91C1C")
    m.spawnRing(0, -66, radius: 3, count: 8, color: "#FDE68A")
    m.slab("Stone Path", x: 0, y: 0, z: -20, w: 4, h: 0.1, d: 80, color: "#57534E")
    m.slab("Main Hall", x: 0, y: 0, z: 30, w: 24, h: 1, d: 16, color: "#7C2D12")
    m.walls(0, 30, w: 24, d: 16, h: 5, y: 1, color: "#92400E", name: "Hall Wall", opacity: 0.9)
    m.part("Hall Roof", at: (0, 7.5, 30), size: (28, 3, 20), color: "#1C1917", shape: .cone)
    m.pad("Altar", x: 0, z: 34, y: 1, size: 3, color: "#FACC15", tags: ["altar"])
    for (i, p) in ring(10, radius: 45, cz: 0).enumerated() {
        m.part("Stone Lantern \(i + 1)", at: (p.0, 1, p.1), size: (0.8, 2, 0.8), color: "#78716C", shape: .cylinder)
        m.part("Lantern Light \(i + 1)", at: (p.0, 2.2, p.1), size: (0.6, 0.6, 0.6), color: "#FB923C", shape: .sphere, material: .neon, solid: false)
    }
    var r = Seeded("yokai")
    for i in 0..<30 {
        let a = r.range(0, 2 * .pi), d = r.range(20, 75)
        m.pine(cos(a) * d, sin(a) * d, height: r.range(6, 10), leaves: "#052E16", name: "Cedar \(i + 1)")
    }
    m.markers("Ofuda Spot", points: [(-40, 10), (40, 20), (-30, -40), (35, -35), (0, 60), (-55, -5), (55, 0), (20, 50)],
              color: "#000000", visible: false, behavior: .none)
    m.pad("Exit Gate", x: 0, z: -72, size: 4, color: "#22C55E", tags: ["exit"])
}

// MARK: 52 Night Lockdown

func nightLockdown(_ m: MapBuilder) {
    m.sunset(ground: "#365314")
    m.ground(180, 180, color: "#4D7C0F", name: "Town")
    m.slab("Safehouse Floor", x: 0, y: 0, z: 0, w: 20, h: 0.3, d: 16, color: "#A16207")
    m.walls(0, 0, w: 20, d: 16, h: 4, y: 0.3, color: "#E7E5E4", name: "Safehouse Wall")
    m.slab("Safehouse Roof", x: 0, y: 4.3, z: 0, w: 21, h: 0.4, d: 17, color: "#7F1D1D")
    let windows: [(Float, Float, Bool)] = [(-6, -8, true), (6, -8, true), (-6, 8, true), (6, 8, true), (-10, 0, false), (10, 0, false)]
    for (i, w) in windows.enumerated() {
        m.part("Window \(i + 1)", at: (w.0, 2, w.1), size: w.2 ? (3, 1.6, 0.6) : (0.6, 1.6, 3), color: "#93C5FD", material: .glass,
               tags: ["window"], opacity: 0.6)
    }
    m.part("Front Door", at: (0, 1.4, 8), size: (2, 2.6, 0.6), color: "#78350F", tags: ["window"])
    m.spawnRing(0, 0, y: 0.3, radius: 3, count: 8, color: "#FDE68A")
    m.pad("Pantry", x: -7, z: -5, y: 0.3, size: 2, color: "#F59E0B", tags: ["pantry"])
    var r = Seeded("lockdown")
    for i in 0..<6 {
        let x = r.range(-70, 70), z = r.range(-70, 70)
        if abs(x) < 20 && abs(z) < 20 { continue }
        m.house("Store \(i + 1)", x: x, z: z, w: 10, d: 8, h: 3.4, wall: r.pick(["#E5E7EB", "#FDE68A", "#FECACA"]), roof: "#44403C",
                floor: "#78716C", door: false, tags: ["store"])
    }
    m.markers("Supply", points: (0..<12).map { _ in (r.range(-75, 75), r.range(-75, 75)) }, color: "#000000", visible: false, behavior: .none)
    m.markers("Intruder Spawn", points: ring(6, radius: 80), color: "#000000", visible: false, behavior: .none)
}

// MARK: 53 Toy Factory Night Shift

func toyFactory(_ m: MapBuilder) {
    m.indoor(ground: "#111111")
    m.sky("#000000", "#0B0B0B", light: 0.4, showGround: false)
    m.ground(80, 70, color: "#27272A", name: "Factory Floor")
    m.walls(0, 0, w: 80, d: 70, h: 7, color: "#3F3F46", name: "Factory Wall")
    // The office, with a door on each side.
    m.slab("Office Floor", x: 0, y: 0, z: -25, w: 12, h: 0.2, d: 10, color: "#57534E")
    m.slab("Office Back", x: 0, y: 0.2, z: -30, w: 12, h: 4, d: 0.4, color: "#52525B")
    m.slab("Office Front", x: 0, y: 0.2, z: -20, w: 12, h: 1.2, d: 0.4, color: "#52525B")
    m.slab("Office Window", x: 0, y: 1.4, z: -20, w: 12, h: 2.8, d: 0.1, color: "#93C5FD", material: .glass, opacity: 0.3)
    m.part("Left Door", at: (-6, 2.1, -25), size: (0.4, 4, 4), color: "#71717A", material: .metal, visible: false)
    m.part("Right Door", at: (6, 2.1, -25), size: (0.4, 4, 4), color: "#71717A", material: .metal, visible: false)
    m.spawnRing(0, -25, y: 0.2, radius: 2, count: 6, color: "#FDE68A")
    // Camera points and the stations the toys move between.
    let stations: [(String, Float, Float)] = [("Stage", 0, 25), ("Assembly", -25, 10), ("Storage", 25, 10), ("Hall West", -20, -12),
                                              ("Hall East", 20, -12), ("Left Door Spot", -8, -25), ("Right Door Spot", 8, -25)]
    for s in stations {
        m.part("Station \(s.0)", at: (s.1, 0.2, s.2), size: (2, 0.1, 2), color: "#3F3F46", shape: .cylinder, visible: false)
    }
    for (i, c) in [("Stage", 0, 20, 12), ("Assembly", -20, 8, 5), ("Storage", 20, 8, 5), ("Hall West", -14, -8, -3),
                   ("Hall East", 14, -8, -3)].enumerated() {
        m.part("Cam \(i + 1)", at: (Float(c.1), 5.5, Float(c.2) + Float(c.3)), size: (0.4, 0.4, 0.4), color: "#EF4444",
               shape: .sphere, material: .neon, solid: false)
    }
    m.slab("Stage Platform", x: 0, y: 0, z: 27, w: 16, h: 0.8, d: 6, color: "#7C2D12")
    var r = Seeded("toys")
    for i in 0..<10 {
        m.slab("Conveyor \(i + 1)", x: r.range(-30, 30), y: 0, z: r.range(-5, 20), w: r.range(4, 8), h: 1, d: 1.6, color: "#52525B")
    }
}

// MARK: 54 Midnight Guard

func midnightGuard(_ m: MapBuilder) {
    m.indoor(ground: "#000000")
    m.sky("#000000", "#050505", light: 0.3, showGround: false)
    m.ground(100, 100, color: "#1F2937", name: "Facility Floor")
    m.walls(0, 0, w: 100, d: 100, h: 6, color: "#374151", name: "Facility Wall")
    m.slab("Guard Room", x: 0, y: 0, z: 0, w: 12, h: 0.2, d: 12, color: "#1E3A8A")
    m.spawnRing(0, 0, y: 0.2, radius: 3, count: 8, color: "#93C5FD")
    let rooms: [(String, Float, Float)] = [("Lab", -30, -30), ("Archive", 30, -30), ("Ward", -30, 30), ("Boiler", 30, 30)]
    for rm in rooms {
        m.slab("\(rm.0) Floor", x: rm.1, y: 0, z: rm.2, w: 22, h: 0.2, d: 22, color: "#374151")
        m.walls(rm.1, rm.2, w: 22, d: 22, h: 4, y: 0.2, color: "#4B5563", thickness: 0.4, name: "\(rm.0) Wall", opacity: 0.85)
        m.pad("\(rm.0) Generator", x: rm.1, z: rm.2, y: 0.2, size: 2.5, color: "#FACC15", tags: ["generator"])
        m.part("\(rm.0) Light", at: (rm.1, 3.8, rm.2), size: (2, 0.2, 2), color: "#FEF9C3", material: .neon, solid: false)
    }
    // Doorways cut as see-through slabs.
    for rm in rooms {
        m.part("\(rm.0) Doorway", at: (rm.1 * 0.64, 1.5, rm.2), size: (0.5, 3, 3), color: "#1F2937", solid: false, opacity: 0.1)
    }
    m.markers("Entity Spot", points: [(-30, -20), (30, -20), (-30, 20), (30, 20), (0, 40), (0, -40)], color: "#000000", visible: false, behavior: .none)
}

// MARK: 55 Endless Rooms

func endlessRooms(_ m: MapBuilder) {
    m.indoor(ground: "#000000")
    m.sky("#1A1606", "#2A2408", light: 0.55, showGround: false)
    m.ground(160, 160, color: "#8B7D3A", name: "Carpet")
    m.slab("Ceiling", x: 0, y: 4, z: 0, w: 160, h: 0.3, d: 160, color: "#CFC48A")
    // A maze of yellow walls on a grid, with openings.
    var r = Seeded("backrooms")
    let cell: Float = 8
    for gx in -9...9 {
        for gz in -9...9 {
            let x = Float(gx) * cell, z = Float(gz) * cell
            if abs(gx) <= 1 && abs(gz) <= 1 { continue }
            let kind = r.int(0, 5)
            if kind == 0 { m.slab("Wall", x: x, y: 0, z: z + cell / 2, w: cell, h: 4, d: 0.4, color: "#D9C66B") }
            if kind == 1 { m.slab("Wall", x: x + cell / 2, y: 0, z: z, w: 0.4, h: 4, d: cell, color: "#D9C66B") }
            if kind == 2 {
                m.slab("Wall", x: x, y: 0, z: z + cell / 2, w: cell, h: 4, d: 0.4, color: "#D9C66B")
                m.slab("Wall", x: x + cell / 2, y: 0, z: z, w: 0.4, h: 4, d: cell, color: "#D9C66B")
            }
            if kind == 3 && r.unit() < 0.3 {
                m.part("Buzzing Light", at: (x, 3.85, z), size: (1.6, 0.1, 0.6), color: "#FFFBEB", material: .neon, solid: false)
            }
        }
    }
    m.walls(0, 0, w: 160, d: 160, h: 4, color: "#D9C66B", name: "Edge")
    m.spawnRing(0, 0, radius: 3, count: 8, color: "#FDE68A")
    m.markers("Exit Spot", points: [(-68, -68), (68, -68), (-68, 68), (68, 68), (0, 70), (0, -70), (70, 0), (-70, 0)],
              color: "#000000", visible: false, behavior: .none)
    m.markers("Entity Spawn", points: [(-60, 0), (60, 0), (0, 60), (0, -60)], color: "#000000", visible: false, behavior: .none)
}

// MARK: 56 Infinite Store

func infiniteStore(_ m: MapBuilder) {
    m.indoor(ground: "#000000")
    m.sky("#E5E7EB", "#F3F4F6", light: 0.8, showGround: false)
    m.ground(200, 200, color: "#9CA3AF", name: "Store Floor")
    m.spawnRing(0, 0, radius: 5, count: 10, color: "#FACC15")
    var r = Seeded("store")
    let items: [(String, V, String, BlockShape)] = [("Sofa", (3, 1, 1.2), "#2563EB", .box), ("Shelf", (2, 3, 0.8), "#F5F5F4", .box),
                                                    ("Bed", (2.2, 0.7, 3.2), "#FDE68A", .box), ("Table", (2.4, 1, 1.4), "#A16207", .box),
                                                    ("Lamp", (0.6, 1.8, 0.6), "#FDE68A", .cylinder), ("Wardrobe", (2, 2.6, 1), "#78350F", .box),
                                                    ("Plant", (1, 1.8, 1), "#16A34A", .cone), ("Fridge", (1.2, 2.2, 1.2), "#E5E7EB", .box)]
    for i in 0..<70 {
        let it = r.pick(items)
        let x = r.range(-90, 90), z = r.range(-90, 90)
        if abs(x) < 8 && abs(z) < 8 { continue }
        m.part("\(it.0) \(i + 1)", at: (x, it.1.1 / 2, z), size: it.1, color: it.2, shape: it.3, tags: ["furniture"])
    }
    for gx in stride(from: Float(-80), through: 80, by: 40) {
        for gz in stride(from: Float(-80), through: 80, by: 40) {
            m.pillar("Store Pillar", x: gx, z: gz, height: 10, radius: 1, color: "#D1D5DB")
        }
    }
    m.markers("Food Spot", points: (0..<10).map { _ in (r.range(-80, 80), r.range(-80, 80)) }, color: "#000000", visible: false, behavior: .none)
    m.markers("Employee Spawn", points: ring(6, radius: 85), color: "#000000", visible: false, behavior: .none)
}

// MARK: 57 Smile Outbreak

func smileOutbreak(_ m: MapBuilder) {
    m.day(ground: "#94A3B8")
    m.ground(150, 150, color: "#CBD5E1", name: "School Yard")
    m.walls(0, 0, w: 150, d: 150, h: 6, color: "#64748B", name: "Fence")
    m.spawnRing(0, 0, radius: 8, count: 12, color: "#FDE047")
    var r = Seeded("smile")
    for i in 0..<16 {
        m.slab("Building \(i + 1)", x: r.range(-60, 60), y: 0, z: r.range(-60, 60), w: r.range(6, 12), h: r.range(3, 8), d: r.range(6, 12),
               color: r.pick(["#E2E8F0", "#FDE68A", "#BFDBFE"]))
    }
    m.markers("Vaccine Spot", points: (0..<8).map { _ in (r.range(-65, 65), r.range(-65, 65)) }, color: "#000000", visible: false, behavior: .none)
}

// MARK: 58 Watch The House

func watchHouse(_ m: MapBuilder) {
    m.night(ground: "#0F172A")
    m.sky("#020617", "#0F172A", light: 0.18, ground: "#0F172A", sunPitch: -10)
    m.ground(100, 100, color: "#1E293B", name: "Yard")
    m.slab("House Floor", x: 0, y: 0, z: 0, w: 24, h: 0.3, d: 18, color: "#57534E")
    m.walls(0, 0, w: 24, d: 18, h: 4, y: 0.3, color: "#44403C", name: "House Wall")
    m.slab("House Roof", x: 0, y: 4.3, z: 0, w: 25, h: 0.4, d: 19, color: "#1C1917")
    m.slab("Inner Wall", x: 0, y: 0.3, z: -3, w: 0.4, h: 3.7, d: 12, color: "#57534E")
    let openings: [(String, Float, Float, Bool)] = [("Kitchen Window", -8, -9, true), ("Bedroom Window", 8, -9, true),
                                                    ("Living Window", -12, 3, false), ("Bath Window", 12, 3, false), ("Front Door", 0, 9, true)]
    for o in openings {
        m.part(o.0, at: (o.1, 2, o.2), size: o.3 ? (2.6, 2, 0.5) : (0.5, 2, 2.6), color: "#1E3A8A", material: .glass, tags: ["opening"], opacity: 0.5)
        m.part("\(o.0) Outside", at: (o.1 * 1.25, 0.5, o.2 * 1.25), size: (1, 0.1, 1), color: "#000000", visible: false)
    }
    m.spawnRing(0, 3, y: 0.3, radius: 2, count: 6, color: "#FDE68A")
    m.pad("Monitor Desk", x: -4, z: 5, y: 0.3, size: 2, color: "#22D3EE", tags: ["monitor"])
    for p in ring(8, radius: 40) { m.pine(p.0, p.1, height: 8, leaves: "#052E16") }
}
