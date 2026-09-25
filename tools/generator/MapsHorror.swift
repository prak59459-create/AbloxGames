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
         summary: "5種類の巨大な顔（ダッシュ・ワープ・ジャンプ・分裂）が追いかけてくる！ ダッシュとアイテムで逃げて、倒れた仲間は助け起こそう。モール・屋上・迷路・公園の4ステージを投票で。3分生きのびたら勝ち！",
         tags: ["chase", "coop", "funny"], maxPlayers: 12, build: runFaces),
    Game(number: 49, id: "anomaly-hallway", title: "Anomaly Hallway",
         summary: "終わらない駅の廊下。30種類の「異変」— 色・位置・数・おじさんの動き・せまる赤い波 — を見つけたら引き返し、なければ進む。8回続けて正解で出口へ。異変図鑑を集め、最速記録と裏モードにも挑戦！",
         tags: ["horror", "puzzle", "observe"], maxPlayers: 6, build: anomalyHallway),
    Game(number: 50, id: "last-train-west", title: "Last Train West",
         summary: "荒野を走る最後の列車で10kmの旅。石炭をくべて走らせ、4つの町（ゴーストタウン・銀行・教会・砦）で物資と金塊を集め、夜の怪物とならず者から列車を守れ。役割と列車の強化、最後は大きな橋の防衛戦！",
         tags: ["survival", "train", "coop"], maxPlayers: 8, build: lastTrain),
    Game(number: 51, id: "yokai-shrine", title: "Yokai Shrine",
         summary: "夜の神社でお札を集めて本殿に納める、三つの夜の和風ホラー。仲間に化けるのっぺらぼう・灯籠を消す狐火・お札をうばうからかさ・池のかっぱ、そして最後は目ざめた鬼から鳥居の外へ逃げろ。勇気・おみくじ・お守り・妖怪図鑑！",
         tags: ["horror", "japanese", "coop"], maxPlayers: 8, build: yokaiShrine),
    Game(number: 52, id: "night-lockdown", title: "Night Lockdown",
         summary: "昼は町の6つのお店で板・釘・鉄板・食料・燃料を集め、夜は家の窓とドアに板を打って立てこもる。わな・作業場・発電機、5種類の侵入者。おばあちゃん・妹・犬を守って5日目の救助ヘリへ！",
         tags: ["survival", "story", "defend"], maxPlayers: 8, build: nightLockdown),
    Game(number: 53, id: "toy-factory-night-shift", title: "Toy Factory Night Shift",
         summary: "おもちゃ工場の夜間警備。9台のカメラ・左右のドアとライト・通気口で、歩きまわるクマ・ウサギ・ニワトリ、見られないと飛び出すキツネ、オルゴールが止まると開くびっくり箱から身を守れ。電力を節約して朝6時まで。6夜目はナイトメア！",
         tags: ["horror", "cameras", "coop"], maxPlayers: 6, build: toyFactory),
    Game(number: 54, id: "midnight-guard", title: "Midnight Guard",
         summary: "真夜中の研究施設の警備員になって3つの夜を見回る。所長の巡回リスト（ニセの無線に注意）、6つの棟の発電機と燃料運び、電池つきのライトで影を消し、見張る者・迷子・停電の王に立ち向かえ。",
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
    m.ground(900, 900, color: "#A8A29E", name: "Ground")
    var r = Seeded("faces")

    // The lobby, where everyone waits and votes between rounds.
    m.slab("Lobby Floor", x: -220, y: 0, z: 0, w: 40, h: 0.2, d: 40, color: "#E0E7FF")
    m.walls(-220, 0, w: 40, d: 40, h: 3, y: 0.2, color: "#A5B4FC", name: "Lobby Wall")
    m.spawnRing(-220, 0, y: 0.2, radius: 7, count: 12, color: "#60A5FA")
    m.part("Lobby Sign", at: (-220, 6, -19), size: (18, 2, 0.4), color: "#F472B6", material: .neon, solid: false)
    m.pad("Lobby Spot", x: -220, z: 12, y: 0.2, size: 3, color: "#C7D2FE", tags: ["lobbyspot"])

    // Stage 1: the mall.
    let mall: (Float, Float) = (0, 0)
    m.slab("Mall Floor", x: mall.0, y: 0, z: mall.1, w: 160, h: 0.2, d: 160, color: "#D6D3D1")
    m.walls(mall.0, mall.1, w: 160, d: 160, h: 12, y: 0.2, color: "#78716C", name: "Mall Wall")
    for i in 0..<22 {
        m.slab("Kiosk \(i + 1)", x: mall.0 + r.range(-68, 68), y: 0.2, z: mall.1 + r.range(-68, 68), w: r.range(3, 8), h: r.range(1, 3.5),
               d: r.range(3, 8), color: r.pick(["#F472B6", "#60A5FA", "#FBBF24", "#34D399"]))
    }
    m.water(mall.0, mall.1, w: 10, d: 10, y: 0.25, name: "Fountain")
    m.stairs(mall.0 - 50, mall.1 + 40, y: 0.2, steps: 8, rise: 0.6, run: 1.5, width: 5, color: "#94A3B8", name: "Mall Stair")
    m.slab("Mall Balcony", x: mall.0 - 30, y: 0.2, z: mall.1 + 40, w: 16, h: 4.8, d: 10, color: "#CBD5E1")
    for (i, p) in [(-40, -40), (40, -40), (40, 40), (0, -60)].enumerated() {
        m.part("Mall Jump \(i + 1)", at: (mall.0 + Float(p.0), 0.35, mall.1 + Float(p.1)), size: (3, 0.3, 3), color: "#22C55E",
               shape: .cylinder, material: .neon, behavior: .bounce)
    }
    m.markers("Mall Start", points: ring(8, radius: 10).map { (mall.0 + $0.0, mall.1 + $0.1) }, y: 0.2, color: "#000000", visible: false, behavior: .none)
    m.markers("Mall Face", points: ring(6, radius: 70).map { (mall.0 + $0.0, mall.1 + $0.1) }, y: 0.2, color: "#000000", visible: false, behavior: .none)

    // Stage 2: rooftops — blocks of different heights, bridges and jump pads.
    let roof: (Float, Float) = (300, 0)
    m.slab("Street", x: roof.0, y: 0, z: roof.1, w: 160, h: 0.2, d: 160, color: "#374151")
    var tops: [(Float, Float, Float)] = []
    for gx in stride(from: Float(-60), through: 60, by: 30) {
        for gz in stride(from: Float(-60), through: 60, by: 30) {
            let hgt = r.range(4, 12)
            tops.append((roof.0 + gx, roof.1 + gz, hgt))
            m.slab("Building", x: roof.0 + gx, y: 0.2, z: roof.1 + gz, w: 20, h: hgt, d: 20,
                   color: r.pick(["#64748B", "#475569", "#94A3B8", "#7C2D12"]))
            // A fire stair along the south face, climbing east to the roof.
            let steps = Int((hgt / 0.8).rounded(.up))
            m.stairs(roof.0 + gx - 10, roof.1 + gz - 11.6, y: 0.2, steps: steps, rise: hgt / Float(steps), run: 18 / Float(steps),
                     width: 3, color: "#FBBF24", name: "Fire Stair")
        }
    }
    for t in tops where r.range(0, 1) > 0.45 {
        m.part("Roof Jump", at: (t.0 - 5, 0.2 + t.2 + 0.15, t.1 + 5), size: (3, 0.3, 3), color: "#22C55E", shape: .cylinder,
               material: .neon, behavior: .bounce)
    }
    m.markers("Roof Start", points: ring(8, radius: 6).map { (roof.0 + $0.0 + 15, roof.1 + $0.1 + 15) }, y: 0.2, color: "#000000", visible: false, behavior: .none)
    m.markers("Roof Face", points: ring(6, radius: 72).map { (roof.0 + $0.0, roof.1 + $0.1) }, y: 0.2, color: "#000000", visible: false, behavior: .none)

    // Stage 3: the endless yellow rooms — a maze.
    let maze: (Float, Float) = (0, 300)
    m.slab("Maze Floor", x: maze.0, y: 0, z: maze.1, w: 150, h: 0.2, d: 150, color: "#CA8A04")
    m.walls(maze.0, maze.1, w: 150, d: 150, h: 5, y: 0.2, color: "#EAB308", name: "Maze Wall")
    for gx in stride(from: Float(-60), through: 60, by: 15) {
        for gz in stride(from: Float(-60), through: 60, by: 15) {
            if abs(gx) < 10 && abs(gz) < 10 { continue }
            if r.range(0, 1) > 0.5 {
                m.slab("Maze Wall", x: maze.0 + gx, y: 0.2, z: maze.1 + gz, w: 12, h: 4, d: 0.8, color: "#FACC15")
            } else {
                m.slab("Maze Wall", x: maze.0 + gx, y: 0.2, z: maze.1 + gz, w: 0.8, h: 4, d: 12, color: "#FACC15")
            }
        }
    }
    for i in 0..<9 { m.part("Maze Light", at: (maze.0 - 60 + Float(i % 3) * 60, 4.4, maze.1 - 60 + Float(i / 3) * 60), size: (3, 0.2, 3),
                             color: "#FEF9C3", material: .neon, solid: false) }
    m.markers("Maze Start", points: ring(8, radius: 5).map { (maze.0 + $0.0, maze.1 + $0.1) }, y: 0.2, color: "#000000", visible: false, behavior: .none)
    m.markers("Maze Face", points: ring(6, radius: 66).map { (maze.0 + $0.0, maze.1 + $0.1) }, y: 0.2, color: "#000000", visible: false, behavior: .none)

    // Stage 4: the park — trees, a pond with bridges, hills and a playground.
    let park: (Float, Float) = (300, 300)
    m.slab("Park Lawn", x: park.0, y: 0, z: park.1, w: 170, h: 0.2, d: 170, color: "#4D7C0F")
    m.water(park.0 + 20, park.1 - 10, w: 50, d: 30, y: 0.25, name: "Pond")
    m.slab("Bridge", x: park.0 + 20, y: 0.2, z: park.1 - 10, w: 54, h: 1, d: 4, color: "#92400E")
    for i in 0..<30 { m.tree(park.0 + r.range(-75, 75), park.1 + r.range(-75, 75), y: 0.2, height: r.range(4, 7)) }
    for (i, h) in [(-50, 50), (50, 55), (-55, -45)].enumerated() {
        for k in 0..<4 {
            m.slab("Hill \(i + 1) Step \(k + 1)", x: park.0 + Float(h.0), y: 0.2 + Float(k) * 1.2, z: park.1 + Float(h.1), w: 26 - Float(k) * 6, h: 1.2,
                   d: 26 - Float(k) * 6, color: ["#65A30D", "#4D7C0F", "#3F6212", "#365314"][k])
        }
    }
    m.slab("Playground", x: park.0 - 20, y: 0.2, z: park.1 + 30, w: 20, h: 0.1, d: 14, color: "#DB2777")
    m.part("Park Jump", at: (park.0 - 20, 0.45, park.1 + 30), size: (3, 0.3, 3), color: "#22C55E", shape: .cylinder, material: .neon, behavior: .bounce)
    m.markers("Park Start", points: ring(8, radius: 6).map { (park.0 + $0.0 - 30, park.1 + $0.1 - 30) }, y: 0.2, color: "#000000", visible: false, behavior: .none)
    m.markers("Park Face", points: ring(6, radius: 75).map { (park.0 + $0.0, park.1 + $0.1) }, y: 0.2, color: "#000000", visible: false, behavior: .none)
}

// MARK: 49 Anomaly Hallway

func anomalyHallway(_ m: MapBuilder) {
    m.indoor(ground: "#000000")
    m.sky("#000000", "#0A0A0A", light: 0.6, showGround: false)
    // A long white station corridor. Everything in it is the same every
    // loop — unless something is not.
    m.slab("Hall Floor", x: 0, y: -0.3, z: 0, w: 8, h: 0.3, d: 64, color: "#D1D5DB")
    for i in 0..<8 {
        m.part("Floor Stripe \(i + 1)", at: (0, 0.01, -28 + Float(i) * 8), size: (7.6, 0.02, 0.3), color: "#9CA3AF", solid: false)
    }
    m.slab("Hall Wall L", x: -4, y: 0, z: 0, w: 0.4, h: 4, d: 64, color: "#E5E7EB")
    m.slab("Hall Wall R", x: 4, y: 0, z: 0, w: 0.4, h: 4, d: 64, color: "#E5E7EB")
    m.slab("Hall Ceiling", x: 0, y: 4, z: 0, w: 8.4, h: 0.3, d: 64, color: "#9CA3AF")
    m.slab("Hall End", x: 0, y: 0, z: 32.2, w: 8.4, h: 4, d: 0.4, color: "#E5E7EB")
    m.slab("Hall Start", x: 0, y: 0, z: -32.2, w: 8.4, h: 4, d: 0.4, color: "#E5E7EB")
    m.part("Handrail L", at: (-3.7, 1, 0), size: (0.1, 0.1, 56), color: "#94A3B8", material: .metal, solid: false)
    m.part("Handrail R", at: (3.7, 1, 0), size: (0.1, 0.1, 56), color: "#94A3B8", material: .metal, solid: false)
    for i in 0..<6 {
        m.part("Ceiling Lamp \(i + 1)", at: (0, 3.8, -25 + Float(i) * 10), size: (2.4, 0.15, 0.6), color: "#F8FAFC", material: .neon, solid: false)
    }
    // The fixtures.
    m.part("Door A", at: (-3.8, 1.3, -12), size: (0.2, 2.6, 1.6), color: "#60A5FA", solid: false)
    m.part("Door B", at: (3.8, 1.3, 6), size: (0.2, 2.6, 1.6), color: "#60A5FA", solid: false)
    m.part("Door A Knob", at: (-3.65, 1.2, -11.5), size: (0.1, 0.12, 0.12), color: "#FACC15", shape: .sphere, solid: false)
    m.part("Poster 1", at: (-3.78, 2, 10), size: (0.05, 1.2, 0.9), color: "#F472B6", solid: false)
    m.part("Poster 2", at: (3.78, 2, -18), size: (0.05, 1.2, 0.9), color: "#38BDF8", solid: false)
    m.part("Poster 3", at: (-3.78, 2, 22), size: (0.05, 0.9, 1.4), color: "#FDE68A", solid: false)
    m.part("Bench", at: (3, 0.35, -2), size: (1.2, 0.7, 3), color: "#78716C")
    m.part("Plant", at: (-3, 0.8, 20), size: (0.9, 1.6, 0.9), color: "#16A34A", shape: .cone)
    m.part("Plant Pot", at: (-3, 0.2, 20), size: (0.8, 0.4, 0.8), color: "#92400E", shape: .cylinder)
    m.part("Exit Sign", at: (0, 3.2, 30), size: (1.6, 0.5, 0.1), color: "#22C55E", material: .neon, solid: false)
    m.part("Fire Extinguisher", at: (3.7, 0.6, 16), size: (0.3, 0.8, 0.3), color: "#DC2626", shape: .cylinder)
    m.part("Clock", at: (-3.78, 2.8, -20), size: (0.05, 0.7, 0.7), color: "#FFFFFF", shape: .cylinder, solid: false, rotation: (0, 0, 90))
    m.part("Vending Machine", at: (3.3, 1.1, 24), size: (1, 2.2, 1.6), color: "#DC2626")
    m.part("Vending Light", at: (2.78, 1.5, 24), size: (0.05, 1, 1.2), color: "#FEF9C3", material: .neon, solid: false)
    m.part("Trash Can", at: (-3.3, 0.45, 2), size: (0.7, 0.9, 0.7), color: "#475569", shape: .cylinder)
    m.part("Camera", at: (3.6, 3.6, -26), size: (0.3, 0.3, 0.6), color: "#111827", solid: false)
    m.part("Anomaly Spot", at: (0, 1, 4), size: (0.5, 0.5, 0.5), color: "#000000", visible: false)
    m.part("Man Start", at: (0, 0.5, 28), size: (0.5, 0.5, 0.5), color: "#000000", visible: false)
    m.part("Man End", at: (-2.6, 0.5, -30), size: (0.5, 0.5, 0.5), color: "#000000", visible: false)
    m.spawnRing(0, -27, radius: 1.5, count: 4, color: "#FDE68A")
    m.pad("Go Forward", x: 0, z: 30.5, size: 3, color: "#22C55E", tags: ["forward"], shape: .box)
    m.pad("Go Back", x: 0, z: -30.8, size: 2, color: "#EF4444", tags: ["back"], shape: .box)
}

// MARK: 50 Last Train West

func lastTrain(_ m: MapBuilder) {
    m.sunset(ground: "#B45309")
    m.ground(320, 320, color: "#C2410C", name: "Desert")
    // The rails, and the train standing on them. The world rolls past it.
    m.part("Rails", at: (0, 0.05, 0), size: (3, 0.1, 320), color: "#57534E", material: .metal, solid: false)
    for i in 0..<16 { m.part("Sleeper", at: (0, 0.06, -150 + Float(i) * 20), size: (4.4, 0.08, 0.6), color: "#78350F", solid: false) }
    let cars: [(String, Float, String)] = [("Engine", 18, "#1F2937"), ("Coal Car", 8, "#44403C"), ("Passenger Car", -3, "#7F1D1D"),
                                           ("Cargo Car", -14, "#78350F")]
    for c in cars {
        m.slab(c.0, x: 0, y: 0.6, z: c.1, w: 4, h: 0.4, d: 9.5, color: c.2, tags: ["train"])
        m.slab("\(c.0) Rail L", x: -2, y: 1, z: c.1, w: 0.2, h: 1, d: 9.5, color: "#A8A29E")
        if c.0 == "Passenger Car" || c.0 == "Cargo Car" {
            // A door on the platform side: step down to the station.
            m.slab("\(c.0) Rail R", x: 2, y: 1, z: c.1 - 3.2, w: 0.2, h: 1, d: 3.1, color: "#A8A29E")
            m.slab("\(c.0) Rail R", x: 2, y: 1, z: c.1 + 3.2, w: 0.2, h: 1, d: 3.1, color: "#A8A29E")
            m.slab("\(c.0) Step", x: 3.5, y: 0, z: c.1, w: 3, h: 0.6, d: 2.5, color: "#57534E")
        } else {
            m.slab("\(c.0) Rail R", x: 2, y: 1, z: c.1, w: 0.2, h: 1, d: 9.5, color: "#A8A29E")
        }
        for dz: Float in [-3.2, 3.2] {
            for dx: Float in [-1.6, 1.6] {
                m.part("\(c.0) Wheel", at: (dx, 0.45, c.1 + dz), size: (0.9, 0.3, 0.9), color: "#111827", shape: .cylinder,
                       solid: false, rotation: (0, 0, 90))
            }
        }
    }
    m.slab("Engine Cab", x: 0, y: 1, z: 20, w: 4, h: 3, d: 4, color: "#111827")
    m.slab("Engine Boiler", x: 0, y: 1, z: 15, w: 2.6, h: 2, d: 5, color: "#374151")
    m.part("Smokestack", at: (0, 3.5, 14), size: (1, 2, 1), color: "#27272A", shape: .cylinder)
    m.part("Headlamp", at: (0, 2.2, 22.9), size: (0.8, 0.8, 0.2), color: "#FEF9C3", shape: .cylinder, material: .neon, solid: false,
           rotation: (90, 0, 0))
    m.pad("Boiler", x: 0, z: 19, y: 1, size: 1.8, color: "#F97316", tags: ["boiler"])
    m.pad("Coal Pile", x: 0, z: 8, y: 1, size: 3, color: "#18181B", tags: ["coal"])
    m.slab("Passenger Roof", x: 0, y: 3.4, z: -3, w: 4.2, h: 0.3, d: 9.5, color: "#991B1B")
    m.pad("Upgrade Board", x: -1, z: -6, y: 1, size: 1.6, color: "#FACC15", tags: ["upgrades"])
    m.pad("Role Board", x: 1, z: -6, y: 1, size: 1.6, color: "#A78BFA", tags: ["roles"])
    m.pad("Repair Bench", x: 0, z: -12, y: 1, size: 2, color: "#60A5FA", tags: ["repair"])
    m.pad("Cargo Hold", x: 0, z: -17, y: 1, size: 2, color: "#EAB308", tags: ["cargo"])
    m.part("Turret", at: (0, 2.2, -14), size: (1.2, 1, 1.2), color: "#334155", material: .metal, visible: false)
    m.part("Turret Barrel", at: (0, 2.5, -15.2), size: (0.25, 0.25, 1.6), color: "#111827", visible: false)
    m.spawnRing(0, -3, y: 1, radius: 1.2, count: 6, color: "#FDE68A")
    m.slab("Platform", x: 14, y: 0, z: 0, w: 10, h: 0.6, d: 40, color: "#A8A29E", tags: ["station"])
    m.stairs(19, -2, y: 0, steps: 1, rise: 0.3, run: 1, width: 4, color: "#A8A29E", name: "Platform Step")

    // The four station towns, built in the same place and shown one at a
    // time as the train pulls in.
    func town(_ n: Int, _ build: () -> Void) { m.group("town\(n)", shown: n == 1, build) }
    town(1) {    // A ghost town: a saloon, shacks and a water tower.
        m.house("Saloon", x: 40, z: -18, w: 14, d: 10, h: 4, wall: "#B45309", roof: "#451A03", floor: "#78350F", door: false, tags: ["t1"], facing: -1)
        for i in 0..<3 { m.house("Shack", x: 40, z: 2 + Float(i) * 14, w: 9, d: 9, wall: "#D6B98C", roof: "#57534E", floor: "#A16207", door: false, tags: ["t1"], facing: -1) }
        m.part("Water Tower", at: (58, 7, 0), size: (5, 4, 5), color: "#78350F", shape: .cylinder)
        for dx: Float in [-1.8, 1.8] { m.part("Tower Leg", at: (58 + dx, 2.5, 0), size: (0.4, 5, 0.4), color: "#451A03") }
    }
    town(2) {    // A bank town.
        m.house("Bank", x: 42, z: -14, w: 16, d: 12, h: 5, wall: "#E7E5E4", roof: "#1C1917", floor: "#D6D3D1", door: false, tags: ["t2"], facing: -1)
        m.part("Vault", at: (46, 1.5, -14), size: (3, 3, 3), color: "#71717A", material: .metal)
        m.house("Sheriff Office", x: 40, z: 10, w: 10, d: 9, wall: "#A16207", roof: "#292524", floor: "#78350F", door: false, tags: ["t2"], facing: -1)
        m.house("Hotel", x: 42, z: 28, w: 12, d: 10, h: 4.5, wall: "#FDBA74", roof: "#7C2D12", floor: "#9A3412", door: false, tags: ["t2"], facing: -1)
    }
    town(3) {    // A church town with a graveyard.
        m.house("Church", x: 42, z: -12, w: 12, d: 16, h: 5, wall: "#F5F5F4", roof: "#44403C", floor: "#A8A29E", door: false, tags: ["t3"], facing: -1)
        m.part("Steeple", at: (42, 8, -12), size: (3, 6, 3), color: "#F5F5F4")
        m.part("Steeple Top", at: (42, 12, -12), size: (3, 2.5, 3), color: "#44403C", shape: .cone)
        for i in 0..<8 { m.slab("Tombstone", x: 36 + Float(i % 4) * 4, y: 0, z: 12 + Float(i / 4) * 5, w: 1.2, h: 1.4, d: 0.4, color: "#78716C") }
        m.house("Parsonage", x: 44, z: 30, w: 9, d: 9, wall: "#E7E5E4", roof: "#57534E", floor: "#A8A29E", door: false, tags: ["t3"], facing: -1)
    }
    town(4) {    // A fort.
        m.slab("Fort Wall", x: 44, y: 0, z: -24, w: 30, h: 4, d: 1, color: "#78350F")
        m.slab("Fort Wall", x: 44, y: 0, z: 24, w: 30, h: 4, d: 1, color: "#78350F")
        m.slab("Fort Wall", x: 59, y: 0, z: 0, w: 1, h: 4, d: 48, color: "#78350F")
        m.slab("Fort Wall", x: 29, y: 0, z: -14, w: 1, h: 4, d: 20, color: "#78350F")
        m.slab("Fort Wall", x: 29, y: 0, z: 14, w: 1, h: 4, d: 20, color: "#78350F")
        for p in [(31, -22), (57, -22), (31, 22), (57, 22)] as [(Float, Float)] {
            m.slab("Watchtower", x: p.0, y: 0, z: p.1, w: 3, h: 7, d: 3, color: "#451A03")
        }
        m.house("Barracks", x: 48, z: 0, w: 12, d: 10, wall: "#A16207", roof: "#292524", floor: "#78350F", door: false, tags: ["t4"], facing: -1)
        m.pad("Fort Flag", x: 40, z: 16, size: 2, color: "#DC2626", tags: ["t4flag"])
    }
    for n in 1...4 {
        town(n) {
            // The sheriff's stall at the edge of town: a pad under an awning.
            m.pad("Sheriff \(n)", x: 25, z: -8, size: 2.4, color: "#FACC15", tags: ["sheriff"])
            for p in [(23.2, -9.8), (26.8, -9.8), (23.2, -6.2), (26.8, -6.2)] as [(Float, Float)] {
                m.part("Stall Post", at: (p.0, 1.4, p.1), size: (0.25, 2.8, 0.25), color: "#451A03", solid: false)
            }
            m.part("Stall Awning", at: (25, 2.9, -8), size: (4.2, 0.2, 4.2), color: "#B91C1C", solid: false)
        }
        let spots: [(Float, Float)] = [(32, -24), (34, -6), (34, 8), (33, 22), (50, 36), (52, -30)]
        m.markers("T\(n) Loot", points: spots, color: "#000000", visible: false, behavior: .none)
    }
    // The bridge over the canyon at the end of the line.
    m.slab("Canyon", x: 0, y: -0.1, z: 60, w: 320, h: 0.12, d: 80, color: "#1C1917", solid: false)
    m.part("Bridge Girder L", at: (-3, 1.8, 0), size: (0.5, 3.6, 120), color: "#57534E", material: .metal, solid: false, visible: false)
    m.part("Bridge Girder R", at: (3, 1.8, 0), size: (0.5, 3.6, 120), color: "#57534E", material: .metal, solid: false, visible: false)
    m.markers("Monster Spawn", points: [(-50, -50), (-50, 50), (70, -70), (70, 70), (-70, 0), (80, 0)], color: "#000000", visible: false, behavior: .none)
    var r = Seeded("west")
    for i in 0..<12 {
        let side: Float = i % 2 == 0 ? -1 : 1
        m.part("Passing Cactus \(i + 1)", at: (side * r.range(12, 60), 2, -150 + Float(i) * 25), size: (0.8, 4, 0.8), color: "#15803D",
               shape: .cylinder, tags: ["scenery"], solid: false)
    }
    for i in 0..<6 {
        m.part("Passing Rock \(i + 1)", at: (r.range(-70, -10), 1, -140 + Float(i) * 50), size: (3, 2, 3), color: "#9A3412",
               shape: .sphere, tags: ["scenery"], solid: false)
    }
}

// MARK: 51 Yokai Shrine

func yokaiShrine(_ m: MapBuilder) {
    m.sky("#020617", "#1E1B4B", light: 0.25, ground: "#0F172A", sunPitch: -15)
    m.ground(220, 240, color: "#1E293B", name: "Shrine Grounds")
    m.part("Moon", at: (-30, 70, 190), size: (16, 16, 16), color: "#FEF9C3", shape: .sphere, material: .neon, tags: ["sky"], solid: false)
    // The cover looks up the path at the main hall, from the south-east.
    m.part("Cover Focus", at: (0, 2, 4), size: (88, 1, 1), color: "#000000", tags: ["yaw=160"], solid: false, visible: false)

    // The red fence (tamagaki) all round, open only at the great torii.
    let fence = "#991B1B"
    m.slab("Tamagaki", x: -75, y: 0, z: 4, w: 1, h: 3, d: 168, color: fence)
    m.slab("Tamagaki", x: 75, y: 0, z: 4, w: 1, h: 3, d: 168, color: fence)
    m.slab("Tamagaki", x: 0, y: 0, z: 88, w: 151, h: 3, d: 1, color: fence)
    m.slab("Tamagaki", x: -40.5, y: 0, z: -80, w: 69, h: 3, d: 1, color: fence)
    m.slab("Tamagaki", x: 40.5, y: 0, z: -80, w: 69, h: 3, d: 1, color: fence)

    // The great torii, its barrier, and the way out.
    func torii(_ name: String, z: Float, halfWidth: Float, height: Float, color: String, post: Float) {
        m.pillar("\(name) Leg", x: -halfWidth, z: z, height: height, radius: post, color: color)
        m.pillar("\(name) Leg", x: halfWidth, z: z, height: height, radius: post, color: color)
        m.part("\(name) Nuki", at: (0, height * 0.8, z), size: (halfWidth * 2 + 1, height * 0.07, post * 1.2), color: color)
        m.part("\(name) Kasagi", at: (0, height + 0.2, z), size: (halfWidth * 2 + 2.4, height * 0.1, post * 2.6), color: "#1C1917")
    }
    torii("Great Torii", z: -80, halfWidth: 5.5, height: 7, color: "#DC2626", post: 0.5)
    m.part("Kekkai", at: (0, 2.6, -80), size: (10.6, 5.2, 0.3), color: "#A855F7", material: .neon, behavior: .trigger,
           tags: ["barrier"], solid: false, opacity: 0.35)
    m.slab("Outer Path", x: 0, y: 0, z: -95, w: 5, h: 0.08, d: 28, color: "#57534E")
    m.pad("Exit Gate", x: 0, z: -93, size: 5, color: "#22C55E", tags: ["exit"])
    m.spawnRing(0, -69, radius: 3, count: 8, color: "#FDE68A")

    // The stone path through a tunnel of small torii (senbon torii).
    m.slab("Stone Path", x: 0, y: 0, z: -24, w: 4, h: 0.08, d: 112, color: "#78716C")
    for i in 0..<8 { torii("Path Torii", z: -62 + Float(i) * 6, halfWidth: 2.5, height: 3.8, color: "#EA580C", post: 0.22) }

    // The purification basin (temizuya).
    m.slab("Temizuya Basin", x: -12, y: 0, z: -60, w: 3, h: 0.9, d: 1.5, color: "#A8A29E")
    m.part("Temizuya Water", at: (-12, 0.86, -60), size: (2.6, 0.08, 1.1), color: "#38BDF8", material: .glass, solid: false)
    for p in [(-14, -61.6), (-10, -61.6), (-14, -58.4), (-10, -58.4)] as [(Float, Float)] {
        m.part("Temizuya Post", at: (p.0, 1.5, p.1), size: (0.25, 3, 0.25), color: "#78350F", solid: false)
    }
    m.slab("Temizuya Roof", x: -12, y: 3, z: -60, w: 5, h: 0.3, d: 4.2, color: "#44403C", solid: false)
    m.pad("Temizuya", x: -12, z: -57.2, size: 2, color: "#38BDF8", tags: ["purify"])

    // The charm stall (omamori) and the fortune stand (omikuji).
    m.slab("Stall Counter", x: 13, y: 0, z: -52, w: 5, h: 1, d: 1, color: "#7F1D1D")
    m.slab("Stall Back", x: 13, y: 0, z: -50.2, w: 5, h: 3, d: 0.3, color: "#FEF3C7")
    m.slab("Stall Roof", x: 13, y: 3, z: -51.3, w: 6, h: 0.3, d: 3.4, color: "#991B1B", solid: false)
    for (i, c) in ["#EF4444", "#3B82F6", "#22C55E", "#EAB308", "#A855F7"].enumerated() {
        m.part("Charm", at: (11.2 + Float(i) * 0.9, 1.2, -52), size: (0.35, 0.45, 0.1), color: c, solid: false)
    }
    m.part("Stall Sign", at: (13, 3.7, -52.8), size: (3.4, 0.7, 0.1), color: "#FDE68A", material: .neon, solid: false)
    m.pad("Omamori Stall", x: 13, z: -54.6, size: 2.4, color: "#EF4444", tags: ["charms"])
    m.slab("Omikuji Box", x: -13, y: 0, z: -44, w: 1.2, h: 1.4, d: 1.2, color: "#DC2626")
    m.pad("Omikuji", x: -10.8, z: -44, size: 2, color: "#FDE68A", tags: ["omikuji"])
    m.part("Rack Post", at: (-19, 0.9, -38), size: (0.2, 1.8, 0.2), color: "#78350F")
    m.part("Rack Post", at: (-15, 0.9, -38), size: (0.2, 1.8, 0.2), color: "#78350F")
    m.part("Rack Rope", at: (-17, 1.6, -38), size: (4, 0.08, 0.08), color: "#D6D3D1", solid: false)
    for i in 0..<7 { m.part("Tied Fortune", at: (-18.6 + Float(i) * 0.53, 1.4, -38), size: (0.14, 0.35, 0.05), color: "#FFFFFF", solid: false) }
    m.pad("Omikuji Rack", x: -17, z: -36.4, size: 2, color: "#F5F5F4", tags: ["musubi"])

    // The plaza: the sacred tree and the kagura dance stage.
    m.slab("Plaza", x: 0, y: 0, z: 4, w: 40, h: 0.06, d: 30, color: "#44403C")
    m.pillar("Sacred Tree Trunk", x: -20, z: 6, height: 12, radius: 1.8, color: "#5B3A1E")
    m.part("Sacred Tree", at: (-20, 14, 6), size: (13, 8, 13), color: "#14532D", shape: .sphere, material: .matte, solid: false)
    m.part("Sacred Tree", at: (-17, 11, 9), size: (8, 5, 8), color: "#166534", shape: .sphere, material: .matte, solid: false)
    m.part("Shimenawa", at: (-20, 3, 6), size: (4.3, 0.45, 4.3), color: "#FDE68A", shape: .cylinder, solid: false)
    for a in [0, 90, 180, 270] as [Float] {
        let r = a * .pi / 180
        m.part("Shide", at: (-20 + cos(r) * 2.2, 2.4, 6 + sin(r) * 2.2), size: (0.3, 0.7, 0.05), color: "#FFFFFF", solid: false)
    }
    m.slab("Kagura Stage", x: 22, y: 0, z: 4, w: 10, h: 1, d: 8, color: "#78350F")
    m.stairs(15.5, 4, steps: 2, rise: 0.5, run: 1, width: 3, color: "#78350F", name: "Stage Step")
    for p in [(17.4, 0.4), (26.6, 0.4), (17.4, 7.6), (26.6, 7.6)] as [(Float, Float)] {
        m.part("Stage Post", at: (p.0, 3, p.1), size: (0.3, 4, 0.3), color: "#DC2626", solid: false)
    }
    m.slab("Stage Roof", x: 22, y: 5, z: 4, w: 11, h: 0.4, d: 9, color: "#1C1917", solid: false)
    for x: Float in [-5, 5] {
        m.slab("Komainu Base", x: x, y: 0, z: 26, w: 1.6, h: 1, d: 1.6, color: "#57534E")
        m.part("Komainu", at: (x, 1.7, 26), size: (1.2, 1.4, 1.4), color: "#A8A29E", shape: .sphere, material: .matte)
    }

    // The main hall (honden): a porch with the bell and the offering box,
    // the altar inside and the seal slots that light up one by one.
    m.slab("Hall Base", x: 0, y: 0, z: 42, w: 26, h: 1.2, d: 18, color: "#78350F")
    for i in 0..<3 { m.slab("Hall Step", x: 0, y: 0, z: 30.5 + Float(i), w: 10, h: 0.4 * Float(i + 1), d: 1, color: "#A8A29E") }
    let wall = "#B91C1C"
    m.slab("Hall Wall", x: 0, y: 1.2, z: 51, w: 26, h: 5, d: 0.6, color: wall)
    m.slab("Hall Wall", x: -13, y: 1.2, z: 43.5, w: 0.6, h: 5, d: 15, color: wall)
    m.slab("Hall Wall", x: 13, y: 1.2, z: 43.5, w: 0.6, h: 5, d: 15, color: wall)
    m.slab("Hall Wall", x: -8, y: 1.2, z: 36, w: 10, h: 5, d: 0.6, color: wall)
    m.slab("Hall Wall", x: 8, y: 1.2, z: 36, w: 10, h: 5, d: 0.6, color: wall)
    m.slab("Hall Wall", x: 0, y: 4.8, z: 36, w: 6, h: 1.4, d: 0.6, color: wall)
    m.slab("Hall Roof", x: 0, y: 6.2, z: 42, w: 30, h: 0.5, d: 22, color: "#1C1917", solid: false)
    m.part("Hall Roof Top", at: (0, 8, 43), size: (26, 3, 17), color: "#1C1917", shape: .cone, material: .matte, solid: false)
    m.part("Bell Beam", at: (-3.5, 5.9, 34.5), size: (2.6, 0.3, 0.3), color: "#78350F", solid: false)
    m.part("Bell", at: (-3.5, 5.1, 34.5), size: (1.1, 1.1, 1.1), color: "#EAB308", shape: .sphere, material: .metal, solid: false)
    m.part("Bell Rope", at: (-3.5, 3, 34.5), size: (0.18, 3.4, 0.18), color: "#DC2626", solid: false)
    m.pad("Bell Pad", x: -3.5, z: 34.4, y: 1.2, size: 1.8, color: "#EAB308", tags: ["bell"])
    m.slab("Saisen Box", x: 5.2, y: 1.2, z: 35.1, w: 2.4, h: 0.9, d: 1, color: "#78350F")
    m.pad("Offering", x: 5.2, z: 33.9, y: 1.2, size: 1.8, color: "#F59E0B", tags: ["offering"])
    for x: Float in [-9, 9] {
        m.part("Hall Lantern", at: (x, 4.4, 34.6), size: (1, 1.3, 1), color: "#EF4444", shape: .sphere, material: .neon, solid: false)
    }
    m.slab("Altar Table", x: 0, y: 1.2, z: 48.8, w: 7, h: 1.4, d: 2, color: "#1C1917")
    m.part("Sacred Mirror", at: (0, 3.3, 48.8), size: (1.4, 1.4, 0.15), color: "#FDE68A", shape: .cylinder, material: .metal, solid: false,
           rotation: (90, 0, 0))
    m.pad("Altar", x: 0, z: 45.6, y: 1.2, size: 3.2, color: "#FACC15", tags: ["altar"])
    for i in 0..<9 {
        m.part("Seal Slot \(i + 1)", at: (-4 + Float(i), 4.6, 50.6), size: (0.6, 1, 0.1), color: "#44403C", solid: false)
    }

    // The pond with its arched bridge, where the kappa lives.
    m.water(48, 12, w: 26, d: 22, y: 0.02, name: "Pond", color: "#0E7490", depth: 0.3, tags: ["water", "pond"])
    let arch: [Float] = [0.35, 0.8, 1.1, 0.8, 0.35]
    for (i, h) in arch.enumerated() {
        m.slab("Taiko Bridge", x: 48, y: 0, z: 1.6 + Float(i) * 5.2, w: 3, h: h, d: 5.2, color: "#DC2626")
    }
    for z: Float in [2, 7, 12, 17, 22] {
        for x: Float in [46.4, 49.6] { m.part("Bridge Post", at: (x, 1.9, z), size: (0.2, 1.2, 0.2), color: "#DC2626", solid: false) }
    }
    m.rock(55, 5, size: 3, color: "#57534E", name: "Kappa Rock")
    for p in [(40, 18), (43, 4), (56, 20), (52, 16)] as [(Float, Float)] {
        m.part("Lily Pad", at: (p.0, 0.05, p.1), size: (1.4, 0.04, 1.4), color: "#15803D", shape: .cylinder, solid: false)
    }
    m.part("Pond Bank", at: (31, 0.1, 12), size: (1.2, 0.2, 1.2), color: "#000000", shape: .cylinder, solid: false, visible: false)

    // The bamboo grove in the west, with two paths through it.
    var r = Seeded("yokai")
    var placedBamboo = 0
    while placedBamboo < 90 {
        let x = r.range(-70, -30), z = r.range(-34, 42)
        if abs(z - 6) < 2.2 || abs(x + 48) < 2.2 { continue }
        let h = r.range(8, 12)
        m.part("Bamboo", at: (x, h / 2, z), size: (0.35, h, 0.35), color: placedBamboo % 3 == 0 ? "#4D7C0F" : "#65A30D",
               shape: .cylinder, tags: ["tree"])
        m.part("Bamboo Leaves", at: (x, h, z), size: (1.8, 1.4, 1.8), color: "#3F6212", shape: .sphere, material: .matte, solid: false)
        placedBamboo += 1
    }

    // The graveyard in the north-west.
    for row in 0..<4 {
        for col in 0..<7 {
            let x = -64 + Float(col) * 5, z = 54 + Float(row) * 7
            m.slab("Grave Base", x: x, y: 0, z: z, w: 1.5, h: 0.4, d: 1.1, color: "#57534E")
            m.slab("Gravestone", x: x, y: 0.4, z: z, w: 0.7, h: 1.6 + Float((row + col) % 3) * 0.2, d: 0.5, color: "#78716C")
            m.part("Sotoba", at: (x + 0.6, 1.2, z + 0.5), size: (0.2, 2.4, 0.05), color: "#D6D3D1", solid: false)
        }
    }

    // Four small shrines (hokora) to hide in.
    let hokora: [(Float, Float, Float)] = [(-32, -44, 1), (34, -36, 1), (62, 62, -1), (-24, 74, -1)]
    for (i, h) in hokora.enumerated() {
        m.house("Hokora", x: h.0, z: h.1, w: 3.2, d: 3.2, h: 2.8, wall: "#A16207", roof: "#1C1917", floor: "#78350F", door: false,
                tags: ["hokora_building"], facing: h.2)
        m.pad("Hokora \(i + 1)", x: h.0, z: h.1, y: 0.15, size: 1.6, color: "#A78BFA", tags: ["hokora"])
    }

    // The black torii behind the hall, where the oni sleeps.
    torii("Oni Torii", z: 80, halfWidth: 4, height: 6, color: "#0C0A09", post: 0.45)
    m.part("Oni Gate", at: (0, 3, 80), size: (0.2, 0.2, 0.2), color: "#0C0A09", solid: false, visible: false)
    m.part("Oni Seal", at: (0, 3.4, 80), size: (1.2, 2, 0.1), color: "#FDE68A", material: .neon, solid: false)
    m.part("Oni Rope", at: (0, 5, 80), size: (8, 0.3, 0.3), color: "#FDE68A", solid: false)

    // Stone lanterns: touch the base to light one the fox fires put out.
    let lanterns: [(Float, Float)] = [(-4.5, -48), (4.5, -48), (-4.5, -16), (4.5, -16), (-12, 22), (12, 22),
                                      (-40, 6), (-46, 62), (36, 26), (60, -4), (-20, 62), (22, 62)]
    for (i, p) in lanterns.enumerated() {
        m.pad("Lantern Base \(i + 1)", x: p.0, z: p.1, size: 2.4, color: "#57534E", tags: ["lantern"])
        m.part("Stone Lantern \(i + 1)", at: (p.0, 1, p.1), size: (0.8, 2, 0.8), color: "#78716C", shape: .cylinder)
        m.part("Lantern Light \(i + 1)", at: (p.0, 2.15, p.1), size: (0.7, 0.5, 0.7), color: "#FB923C", shape: .sphere, material: .neon, solid: false)
        m.part("Lantern Cap", at: (p.0, 2.7, p.1), size: (1.4, 0.7, 1.4), color: "#57534E", shape: .cone, solid: false)
    }

    // Where the ofuda can turn up, and where the yokai come from.
    let spots: [(Float, Float, Float)] = [(-50, -20, 0), (-60, 12, 0), (-38, 30, 0), (-60, 58, 0), (-40, 78, 0), (-52, 70, 0),
                                          (48, 12, 1.1), (62, 28, 0), (22, 4, 1), (-20, 12, 0), (0, 72, 0), (40, -40, 0),
                                          (-34, -54, 0), (30, 70, 0)]
    for (i, s) in spots.enumerated() {
        m.part("Ofuda Spot \(i + 1)", at: (s.0, s.2 + 0.1, s.1), size: (1.2, 0.2, 1.2), color: "#000000", shape: .cylinder, solid: false,
               visible: false)
    }
    m.markers("Yokai Den", points: [(-62, -44), (-62, 82), (64, -50), (64, 82)], color: "#000000", visible: false, behavior: .none)

    // Cedars outside the fence and in the quiet corners.
    for i in 0..<44 {
        let side = i % 4
        let t = r.range(-95, 95)
        let p: (Float, Float) = side == 0 ? (-82 - r.range(0, 14), t) : side == 1 ? (82 + r.range(0, 14), t)
            : side == 2 ? (t, 94 + r.range(0, 12)) : (t < 0 ? min(t, -12) : max(t, 12), -86 - r.range(0, 14))
        m.pine(p.0, p.1, height: r.range(9, 14), leaves: "#052E16", name: "Cedar")
    }
    for p in [(50, -62), (58, -30), (-20, -66), (40, 44), (-66, -64), (66, 44), (20, 82), (-10, 84)] as [(Float, Float)] {
        m.pine(p.0, p.1, height: r.range(8, 12), leaves: "#052E16", name: "Cedar")
    }
}

// MARK: 52 Night Lockdown

func nightLockdown(_ m: MapBuilder) {
    m.day(ground: "#4D7C0F")
    m.ground(220, 220, color: "#4D7C0F", name: "Town")
    m.part("Cover Focus", at: (0, 2, 4), size: (70, 1, 1), color: "#000000", tags: ["yaw=35"], solid: false, visible: false)

    // MARK: The family's house
    // Floor 0.3 high, walls 4 m, openings cut into them: six windows and two
    // doors. Every opening has a board spot inside, a trap spot outside,
    // markers for the intruders (Out / In) and hidden boards to show.
    m.slab("House Floor", x: 0, y: 0, z: 0, w: 26, h: 0.3, d: 20, color: "#A16207")
    let floorY: Float = 0.3, wallTop: Float = 4.3, t: Float = 0.4
    let wallColor = "#F5F5F4"
    /// A wall along x (at z) or along z (at x), from a to b, with gaps
    /// (centre, width, bottom, top).
    func wall(alongX: Bool, at fixed: Float, from a: Float, to b: Float, gaps: [(Float, Float, Float, Float)] = [],
              name: String = "House Wall", color: String = wallColor) {
        func piece(_ lo: Float, _ hi: Float, _ y0: Float, _ y1: Float) {
            guard hi - lo > 0.01, y1 - y0 > 0.01 else { return }
            if alongX {
                m.slab(name, x: (lo + hi) / 2, y: y0, z: fixed, w: hi - lo, h: y1 - y0, d: t, color: color)
            } else {
                m.slab(name, x: fixed, y: y0, z: (lo + hi) / 2, w: t, h: y1 - y0, d: hi - lo, color: color)
            }
        }
        var cursor = a
        for g in gaps.sorted(by: { $0.0 < $1.0 }) {
            let g0 = g.0 - g.1 / 2, g1 = g.0 + g.1 / 2
            piece(cursor, g0, floorY, wallTop)
            piece(g0, g1, floorY, g.2)
            piece(g0, g1, g.3, wallTop)
            cursor = g1
        }
        piece(cursor, b, floorY, wallTop)
    }
    // (id, side, position along the wall, door)
    let openings: [(String, String, Float, Bool)] = [("N1", "N", -7, false), ("N2", "N", 7, false), ("S1", "S", -7, false),
                                                      ("S2", "S", 8.5, false), ("FD", "S", 0, true), ("W", "W", 3, false),
                                                      ("E", "E", -6.5, false), ("BD", "E", 6, true)]
    func gaps(_ side: String) -> [(Float, Float, Float, Float)] {
        openings.filter { $0.1 == side }.map { o in o.3 ? (o.2, 2.4, floorY, 3.1) : (o.2, 3, 1.5, 3.1) }
    }
    wall(alongX: true, at: -10, from: -13.2, to: 13.2, gaps: gaps("N"))
    wall(alongX: true, at: 10, from: -13.2, to: 13.2, gaps: gaps("S"))
    wall(alongX: false, at: -13, from: -10, to: 10, gaps: gaps("W"))
    wall(alongX: false, at: 13, from: -10, to: 10, gaps: gaps("E"))
    for o in openings {
        let normal: (Float, Float) = o.1 == "N" ? (0, -1) : o.1 == "S" ? (0, 1) : o.1 == "W" ? (-1, 0) : (1, 0)
        let centre: (Float, Float) = o.1 == "N" ? (o.2, -10) : o.1 == "S" ? (o.2, 10) : o.1 == "W" ? (-13, o.2) : (13, o.2)
        func at(_ d: Float) -> (Float, Float) { (centre.0 + normal.0 * d, centre.1 + normal.1 * d) }
        let alongX = normal.0 == 0
        let width: Float = o.3 ? 2.4 : 3
        if o.3 {
            m.part("Door \(o.0)", at: (centre.0, 1.7, centre.1), size: alongX ? (width, 2.8, 0.25) : (0.25, 2.8, width), color: "#78350F",
                   tags: ["door"], solid: false, opacity: 0.35)
            let step = at(1.5)
            m.pad("Door Step \(o.0)", x: step.0, z: step.1, size: 1.4, color: "#22C55E", tags: ["door_step"])
        } else {
            m.part("Window \(o.0)", at: (centre.0, 2.3, centre.1), size: alongX ? (width, 1.6, 0.2) : (0.2, 1.6, width), color: "#93C5FD",
                   material: .glass, tags: ["window"], opacity: 0.55)
        }
        let heights: [Float] = o.3 ? [0.75, 1.3, 1.85, 2.4, 2.95] : [1.75, 2.3, 2.85]
        let face = at(0.35)
        for (k, y) in heights.enumerated() {
            let tilt: Float = k % 2 == 0 ? 6 : -6
            m.part("Board \(o.0) \(k + 1)", at: (face.0, y, face.1), size: alongX ? (width + 0.8, 0.35, 0.12) : (0.12, 0.35, width + 0.8),
                   color: "#A16207", solid: false, visible: false, rotation: alongX ? (0, 0, tilt) : (tilt, 0, 0))
        }
        let inside = at(-1.1), trap = at(4), out = at(2.6), inn = at(-2.2)
        m.pad("Board Spot \(o.0)", x: inside.0, z: inside.1, y: floorY, size: 1.4, color: "#92400E", tags: ["board_spot"])
        m.pad("Trap Spot \(o.0)", x: trap.0, z: trap.1, size: 1.6, color: "#57534E", tags: ["trap_spot"])
        m.part("Trap \(o.0)", at: (trap.0, 0.3, trap.1), size: (1.2, 0.2, 1.2), color: "#78350F", solid: false, visible: false)
        m.part("Out \(o.0)", at: (out.0, 0.1, out.1), size: (1, 0.2, 1), color: "#000000", solid: false, visible: false)
        m.part("In \(o.0)", at: (inn.0, 0.4, inn.1), size: (1, 0.2, 1), color: "#000000", solid: false, visible: false)
    }
    // Rooms: kitchen (NW), workshop (NE), living room (SW), bedroom (SE).
    wall(alongX: true, at: -3, from: -13, to: 13, gaps: [(-6.5, 2.4, floorY, 3), (6.5, 2.4, floorY, 3)], name: "Inner Wall", color: "#E7E5E4")
    wall(alongX: false, at: 0, from: -10, to: -3, name: "Inner Wall", color: "#E7E5E4")
    wall(alongX: false, at: 4, from: -3, to: 10, gaps: [(3.5, 2.4, floorY, 3)], name: "Inner Wall", color: "#E7E5E4")
    m.slab("House Roof", x: 0, y: 4.3, z: 0, w: 27.5, h: 0.4, d: 21.5, color: "#7F1D1D")
    m.part("House Roof Top", at: (0, 6, 0), size: (26, 3, 19), color: "#7F1D1D", shape: .cone, material: .matte, solid: false)
    // Kitchen and pantry.
    m.slab("Counter", x: -11, y: floorY, z: -8.9, w: 3.5, h: 1, d: 1.2, color: "#D6D3D1")
    m.slab("Fridge", x: -12.1, y: floorY, z: -5, w: 1.2, h: 2.4, d: 1.2, color: "#F8FAFC")
    m.slab("Kitchen Table", x: -6, y: floorY, z: -6, w: 3, h: 0.9, d: 2, color: "#B45309")
    m.slab("Pantry Shelf", x: -0.9, y: floorY, z: -8, w: 1, h: 2.6, d: 3.2, color: "#92400E")
    for i in 0..<4 {
        m.part("Pantry Food", at: (-1.2, floorY + 0.7 + Float(i % 2) * 1, -9 + Float(i / 2) * 1.6), size: (0.5, 0.5, 0.6),
               color: i % 2 == 0 ? "#F59E0B" : "#DC2626", solid: false)
    }
    m.pad("Pantry", x: -2.4, z: -8, y: floorY, size: 1.8, color: "#F59E0B", tags: ["deposit"])
    // Workshop and generator.
    m.slab("Workbench", x: 1.2, y: floorY, z: -6.5, w: 1.2, h: 1, d: 4, color: "#78350F")
    m.part("Saw", at: (1.2, floorY + 1.1, -7.5), size: (0.8, 0.1, 0.8), color: "#9CA3AF", shape: .cylinder, material: .metal, solid: false)
    m.pad("Workshop Bench", x: 2.8, z: -6.5, y: floorY, size: 1.8, color: "#EAB308", tags: ["workshop"])
    m.slab("Generator", x: 11.5, y: floorY, z: -8.8, w: 1.6, h: 1.4, d: 1.2, color: "#6B7280", material: .metal)
    m.pad("Generator Pad", x: 9.4, z: -8.6, y: floorY, size: 1.6, color: "#F97316", tags: ["deposit"])
    // Living room.
    m.slab("Rug", x: -5, y: floorY, z: 3.5, w: 7, h: 0.03, d: 5, color: "#1D4ED8")
    m.slab("Sofa", x: -9.5, y: floorY, z: 6.3, w: 4, h: 0.9, d: 1.4, color: "#7C3AED")
    m.slab("TV Stand", x: -4, y: floorY, z: -2.1, w: 3, h: 0.6, d: 0.6, color: "#44403C")
    m.part("TV", at: (-4, floorY + 1.3, -2.2), size: (2.4, 1.3, 0.12), color: "#111827")
    m.slab("Laptop Table", x: 2, y: floorY, z: 0, w: 1.4, h: 0.8, d: 1.4, color: "#B45309")
    m.part("Laptop Screen", at: (2, floorY + 1.1, -0.3), size: (0.9, 0.6, 0.05), color: "#38BDF8", material: .neon, solid: false)
    m.pad("Laptop", x: 2, z: 1.6, y: floorY, size: 1.4, color: "#38BDF8", tags: ["laptop"])
    m.slab("Supply Crate", x: -4.2, y: floorY, z: 8.9, w: 1.4, h: 0.9, d: 1, color: "#A16207")
    m.pad("Supply Box", x: -2.8, z: 7.8, y: floorY, size: 1.8, color: "#F59E0B", tags: ["deposit"])
    m.part("Dog Bed", at: (-2.5, floorY + 0.1, 4), size: (1.4, 0.2, 1.4), color: "#DC2626", shape: .cylinder, solid: false)
    m.part("Sister Spot", at: (-8.5, floorY + 0.1, 7.6), size: (1, 0.2, 1), color: "#000000", solid: false, visible: false)
    m.spawnRing(-6, 2.5, y: floorY, radius: 1.8, count: 6, color: "#FDE68A")
    // Bedroom.
    for x: Float in [9.2, 11.8] {
        m.slab("Bed", x: x, y: floorY, z: 0.5, w: 2, h: 0.6, d: 3, color: "#F1F5F9")
        m.slab("Pillow", x: x, y: floorY + 0.6, z: -0.5, w: 1.6, h: 0.2, d: 0.6, color: "#FDE68A")
    }
    m.slab("Rocking Chair", x: 6.2, y: floorY, z: 7.4, w: 1.2, h: 1, d: 1.2, color: "#92400E")
    m.pad("Grandma Chair", x: 6.2, z: 5.4, y: floorY, size: 1.8, color: "#A78BFA", tags: ["grandma"])
    // Lights on the ceiling, off until the generator runs at night.
    for (i, p) in [(-6.5, -6.5), (6.5, -6.5), (-8, 1), (-1, 6), (8.5, 1), (8.5, 7)].enumerated() {
        m.part("House Light \(i + 1)", at: (Float(p.0), 4.0, Float(p.1)), size: (0.5, 0.3, 0.5), color: "#44403C", shape: .sphere, solid: false)
    }
    m.slab("Porch", x: 0, y: 0, z: 12, w: 6, h: 0.3, d: 3, color: "#78716C")
    m.part("Porch Light", at: (0, 3.6, 10.5), size: (0.5, 0.5, 0.5), color: "#FEF3C7", shape: .sphere, solid: false)
    m.part("Power Box", at: (13.4, 1.6, -9), size: (0.3, 1, 0.8), color: "#9CA3AF", material: .metal)
    m.pad("Power Box Pad", x: 14.6, z: -9, size: 1.4, color: "#FACC15", tags: ["powerbox"])
    // The yard.
    m.slab("Driveway", x: 0, y: 0.02, z: 19, w: 4, h: 0.04, d: 14, color: "#6B7280")
    for (a, b) in [((-22, -17), (22, -17)), ((-22, -17), (-22, 17)), ((22, -17), (22, 17)), ((-22, 17), (-3, 17)), ((3, 17), (22, 17))]
        as [((Float, Float), (Float, Float))] {
        m.fence(from: a, to: b, color: "#FAFAF9")
    }
    m.part("Mailbox", at: (4, 0.9, 18), size: (0.5, 0.5, 0.8), color: "#1D4ED8")
    m.tree(-18, -13, height: 5)
    m.tree(18, 13, height: 5)
    m.tree(-18, 13, height: 4)

    // MARK: The town
    m.road(from: (-105, 26), to: (105, 26), width: 8, name: "Main Street")
    m.road(from: (-105, -34), to: (105, -34), width: 8, name: "North Road")
    m.road(from: (-40, -105), to: (-40, 105), width: 8, name: "West Avenue")
    m.road(from: (40, -105), to: (40, 105), width: 8, name: "East Avenue")
    func loot(_ id: String, _ points: [(Float, Float)], y: Float = 0) {
        for (i, p) in points.enumerated() {
            m.part("\(id) Loot \(i + 1)", at: (p.0, y + 0.1, p.1), size: (1, 0.2, 1), color: "#000000", solid: false, visible: false)
        }
    }
    // Hardware store (north), grocery (north-east), pharmacy (south-west).
    m.shop("Hardware Store", x: 0, z: -58, w: 18, d: 12, color: "#F97316", sign: "#FFFFFF", facing: 1)
    for x: Float in [-6, 6] { m.slab("Shelf", x: x, y: 0.15, z: -62.5, w: 3, h: 2.2, d: 0.8, color: "#9CA3AF") }
    loot("hardware", [(-7, -61), (7, -61), (-6, -55), (6, -55)], y: 0.15)
    m.shop("Grocery", x: 62, z: -58, w: 20, d: 14, color: "#22C55E", sign: "#FEF08A", facing: 1)
    for x: Float in [56, 62, 68] { m.slab("Grocery Shelf", x: x, y: 0.15, z: -63.5, w: 3.5, h: 1.8, d: 0.8, color: "#FDE68A") }
    loot("grocery", [(55, -62), (62, -61.5), (69, -62), (57, -54), (67, -54)], y: 0.15)
    m.shop("Pharmacy", x: -62, z: 50, w: 12, d: 10, color: "#E0F2FE", sign: "#22C55E", facing: -1)
    m.part("Pharmacy Cross", at: (-62, 5, 44.6), size: (1.6, 1.6, 0.2), color: "#22C55E", material: .neon, solid: false)
    loot("pharmacy", [(-66, 53), (-58, 53), (-62, 47.5)], y: 0.15)
    // Gas station (south-east).
    m.slab("Forecourt", x: 62, y: 0, z: 50, w: 22, h: 0.06, d: 16, color: "#9CA3AF")
    for p in [(55, 45), (69, 45), (55, 55), (69, 55)] as [(Float, Float)] { m.pillar("Canopy Post", x: p.0, z: p.1, height: 5, radius: 0.3, color: "#F8FAFC") }
    m.slab("Gas Canopy", x: 62, y: 5, z: 50, w: 17, h: 0.5, d: 12, color: "#DC2626")
    for x: Float in [59, 65] { m.slab("Fuel Pump", x: x, y: 0, z: 50, w: 1, h: 1.6, d: 0.8, color: "#B91C1C") }
    m.house("Gas Kiosk", x: 62, z: 64, w: 8, d: 6, wall: "#FEF3C7", roof: "#DC2626", floor: "#D6D3D1", door: false, tags: ["store"], facing: -1)
    loot("gas", [(57, 50), (67, 50), (62, 64)], y: 0)
    // Lumber yard (north-west): a fenced yard with stacks of planks.
    for (a, b) in [((-74, -67), (-50, -67)), ((-74, -67), (-74, -49)), ((-50, -67), (-50, -49)), ((-74, -49), (-65, -49)), ((-59, -49), (-50, -49))]
        as [((Float, Float), (Float, Float))] {
        m.fence(from: a, to: b, color: "#92400E")
    }
    for (i, p) in ([(-70, -63), (-62, -64), (-54, -63), (-70, -56), (-54, -56)] as [(Float, Float)]).enumerated() {
        for k in 0..<3 {
            m.slab("Lumber Stack", x: p.0, y: Float(k) * 0.35, z: p.1, w: 4, h: 0.35, d: 1.4, color: (i + k) % 2 == 0 ? "#D97706" : "#B45309")
        }
    }
    m.house("Lumber Shed", x: -62, z: -76, w: 10, d: 6, wall: "#78350F", roof: "#44403C", floor: "#A16207", door: false, tags: ["store"], facing: 1)
    loot("lumber", [(-66, -60), (-58, -60), (-66, -52), (-58, -52)])
    // Empty houses to search.
    let homes: [(Float, Float, Float)] = [(-66, 0, 1), (66, 0, 1), (-18, 58, -1), (18, 58, -1), (-20, -80, 1)]
    for (i, h) in homes.enumerated() {
        m.house("Empty House", x: h.0, z: h.1, w: 10, d: 8, wall: ["#FDE68A", "#FECACA", "#BFDBFE", "#E9D5FF", "#D1FAE5"][i], roof: "#44403C",
                floor: "#78716C", door: false, tags: ["store"], facing: h.2)
    }
    loot("homes", homes.map { ($0.0, $0.1 - $0.2 * 1.5) }, y: 0.15)
    // The park and the helipad, where the rescue lands.
    m.slab("Park", x: 0, y: 0.02, z: 78, w: 30, h: 0.05, d: 24, color: "#65A30D")
    m.pad("Helipad", x: 0, z: 78, size: 8, color: "#FDE047", tags: ["helipad"])
    m.part("Helipad H", at: (-1.2, 0.25, 78), size: (0.5, 0.05, 4), color: "#1C1917", solid: false)
    m.part("Helipad H", at: (1.2, 0.25, 78), size: (0.5, 0.05, 4), color: "#1C1917", solid: false)
    m.part("Helipad H", at: (0, 0.25, 78), size: (2.4, 0.05, 0.5), color: "#1C1917", solid: false)
    m.group("heli", shown: false) {
        m.part("Helicopter", at: (0, 2.2, 83), size: (3, 2.2, 5.5), color: "#1D4ED8", shape: .sphere, solid: false)
        m.part("Helicopter Tail", at: (0, 2.6, 88), size: (0.6, 0.6, 5), color: "#1D4ED8", solid: false)
        m.part("Helicopter Rotor", at: (0, 3.6, 83), size: (10, 0.1, 0.5), color: "#111827", solid: false)
        m.part("Helicopter Rotor", at: (0, 3.6, 83), size: (0.5, 0.1, 10), color: "#111827", solid: false)
        m.part("Helicopter Skid", at: (-1.2, 0.5, 83), size: (0.2, 0.2, 5), color: "#111827", solid: false)
        m.part("Helicopter Skid", at: (1.2, 0.5, 83), size: (0.2, 0.2, 5), color: "#111827", solid: false)
    }
    for p in [(-10, 70), (10, 70), (-12, 86), (12, 86)] as [(Float, Float)] { m.tree(p.0, p.1, height: 4.5) }
    // Street lamps, parked cars, trees.
    for x in stride(from: Float(-90), through: 90, by: 30) {
        m.lamp(x, 31.5)
        m.lamp(x, -28.5)
    }
    m.parkedCar("Car", x: -24, z: 31.5, yaw: 90, color: "#DC2626")
    m.parkedCar("Car", x: 28, z: -28.5, yaw: -90, color: "#F8FAFC")
    m.parkedCar("Car", x: 45.5, z: 12, yaw: 0, color: "#1D4ED8")
    m.parkedCar("Car", x: -35, z: -10, yaw: 180, color: "#16A34A")
    var r = Seeded("lockdown")
    var planted = 0
    while planted < 26 {
        let x = r.range(-100, 100), z = r.range(-100, 100)
        let clear = abs(x) < 26 && abs(z) < 21 || abs(z - 26) < 7 || abs(z + 34) < 7 || abs(x + 40) < 7 || abs(x - 40) < 7
            || abs(x) > 44 && abs(x) < 80 && (abs(z + 58) < 14 || abs(z - 50) < 14 || abs(z) < 8)
            || abs(x) < 26 && (abs(z - 58) < 8 || abs(z - 78) < 14 || abs(z + 58) < 10 || abs(z + 80) < 8)
        if clear { continue }
        m.tree(x, z, height: r.range(4, 6.5))
        planted += 1
    }
    m.markers("Intruder Spawn", points: [(-92, 0), (92, 0), (0, -95), (0, 95), (-72, -72), (72, -72), (-72, 72), (72, 72)],
              color: "#000000", visible: false, behavior: .none)
}

// MARK: 53 Toy Factory Night Shift

func toyFactory(_ m: MapBuilder) {
    m.sky("#000000", "#0B0B0B", light: 0.35, showGround: false)
    m.ground(100, 90, color: "#27272A", name: "Factory Floor")
    m.walls(0, 0, w: 100, d: 90, h: 8, color: "#3F3F46", name: "Factory Wall")
    m.part("Cover Focus", at: (0, 2, -6), size: (72, 1, 1), color: "#000000", tags: ["yaw=205"], solid: false, visible: false)

    // MARK: The security office (south): two doors, two hall lights, a vent.
    m.slab("Office Floor", x: 0, y: 0, z: -32, w: 12, h: 0.2, d: 12, color: "#57534E")
    m.slab("Office Back", x: -3.5, y: 0.2, z: -38, w: 5, h: 4, d: 0.4, color: "#52525B")
    m.slab("Office Back", x: 3.5, y: 0.2, z: -38, w: 5, h: 4, d: 0.4, color: "#52525B")
    m.slab("Office Back", x: 0, y: 1.4, z: -38, w: 2, h: 2.8, d: 0.4, color: "#52525B")
    m.part("Vent Grate", at: (0, 0.8, -38), size: (2, 1.2, 0.2), color: "#18181B", material: .metal)
    m.part("Vent Seal", at: (0, 0.8, -37.7), size: (2.2, 1.4, 0.15), color: "#9CA3AF", material: .metal, solid: false, visible: false)
    m.part("Vent Eyes", at: (0, 0.9, -38.15), size: (1, 0.2, 0.05), color: "#EF4444", material: .neon, solid: false, visible: false)
    for x: Float in [-6, 6] {
        m.slab("Office Side", x: x, y: 0.2, z: -36, w: 0.4, h: 4, d: 4, color: "#52525B")
        m.slab("Office Side", x: x, y: 0.2, z: -28, w: 0.4, h: 4, d: 4, color: "#52525B")
        m.slab("Office Side", x: x, y: 3.4, z: -32, w: 0.4, h: 0.8, d: 4, color: "#52525B")
    }
    m.slab("Office Front", x: 0, y: 0.2, z: -26, w: 12.4, h: 1.2, d: 0.4, color: "#52525B")
    m.slab("Office Window", x: 0, y: 1.4, z: -26, w: 12, h: 2.8, d: 0.1, color: "#93C5FD", material: .glass, opacity: 0.25)
    m.slab("Office Ceiling", x: 0, y: 4.2, z: -32, w: 12.4, h: 0.3, d: 12.4, color: "#27272A")
    m.part("Left Door", at: (-6, 1.8, -32), size: (0.5, 3.2, 4), color: "#71717A", material: .metal, solid: false, visible: false)
    m.part("Right Door", at: (6, 1.8, -32), size: (0.5, 3.2, 4), color: "#71717A", material: .metal, solid: false, visible: false)
    m.part("Left Light", at: (-7.5, 3.6, -32), size: (0.5, 0.3, 0.5), color: "#3F3F46", shape: .sphere, solid: false)
    m.part("Right Light", at: (7.5, 3.6, -32), size: (0.5, 0.3, 0.5), color: "#3F3F46", shape: .sphere, solid: false)
    m.slab("Desk", x: 0, y: 0.2, z: -36.2, w: 6, h: 1, d: 1.4, color: "#78350F")
    for x: Float in [-1.8, 0, 1.8] {
        m.part("Monitor", at: (x, 1.7, -36.4), size: (1.4, 0.9, 0.12), color: "#0EA5E9", material: .neon, solid: false)
    }
    m.part("Desk Fan", at: (2.6, 1.5, -35.9), size: (0.6, 0.6, 0.1), color: "#D4D4D8", shape: .cylinder, solid: false, rotation: (90, 0, 0))
    m.part("Poster", at: (-4, 2.6, -37.75), size: (1.6, 2, 0.05), color: "#F472B6", solid: false)
    m.part("Poster", at: (4, 2.6, -37.75), size: (1.6, 2, 0.05), color: "#FACC15", solid: false)
    m.spawnRing(0, -31, y: 0.2, radius: 1.8, count: 6, color: "#FDE68A")

    // MARK: The two halls leading to the office doors.
    m.slab("Hall Wall", x: -15, y: 0, z: -29, w: 0.6, h: 5, d: 18, color: "#3F3F46")
    m.slab("Hall Wall", x: 15, y: 0, z: -29, w: 0.6, h: 5, d: 18, color: "#3F3F46")
    m.slab("Hall Wall", x: -6, y: 0, z: -19, w: 0.6, h: 5, d: 14, color: "#3F3F46")
    m.slab("Hall Wall", x: 6, y: 0, z: -19, w: 0.6, h: 5, d: 14, color: "#3F3F46")
    m.slab("Hall Floor", x: -10.5, y: 0, z: -25, w: 8.4, h: 0.05, d: 26, color: "#1F2937")
    m.slab("Hall Floor", x: 10.5, y: 0, z: -25, w: 8.4, h: 0.05, d: 26, color: "#1F2937")
    for z: Float in [-12, -20, -28, -36] {
        for x: Float in [-10.5, 10.5] { m.part("Hall Stripe", at: (x, 0.06, z), size: (7, 0.02, 0.4), color: "#FACC15", solid: false) }
    }

    // MARK: The factory: stage, dining, toy box, assembly, storage, alcove, prize corner.
    m.slab("Stage Platform", x: 0, y: 0, z: 31, w: 18, h: 0.8, d: 7, color: "#7C2D12")
    m.slab("Stage Curtain", x: 0, y: 0.8, z: 35, w: 18, h: 6, d: 0.3, color: "#991B1B")
    for x: Float in [-6, 0, 6] {
        m.part("Stage Light", at: (x, 6.5, 27), size: (0.8, 0.8, 0.8), color: "#FDE68A", shape: .sphere, material: .neon, solid: false)
    }
    m.slab("Stage Sign", x: 0, y: 5.5, z: 34.7, w: 10, h: 1.2, d: 0.2, color: "#F472B6")
    for p in [(-10, 4), (0, 8), (10, 4), (-8, -4), (8, -4)] as [(Float, Float)] {
        m.slab("Party Table", x: p.0, y: 0, z: p.1, w: 5, h: 0.9, d: 2, color: "#E5E7EB")
        m.part("Party Hat", at: (p.0 - 1.2, 1.25, p.1), size: (0.5, 0.7, 0.5), color: "#A855F7", shape: .cone, solid: false)
        m.part("Party Hat", at: (p.0 + 1.2, 1.25, p.1), size: (0.5, 0.7, 0.5), color: "#22C55E", shape: .cone, solid: false)
    }
    for (i, p) in ([(-14, 14), (14, 14), (-4, 16), (6, 18)] as [(Float, Float)]).enumerated() {
        m.part("Balloon", at: (p.0, 4.5, p.1), size: (1, 1.2, 1), color: ["#EF4444", "#3B82F6", "#FACC15", "#22C55E"][i], shape: .sphere, solid: false)
        m.part("Balloon String", at: (p.0, 2, p.1), size: (0.05, 4, 0.05), color: "#E5E7EB", solid: false)
    }
    // Lou's toy box: a booth with a curtain, open to the east.
    m.slab("Toy Box Wall", x: -38, y: 0, z: 14, w: 0.5, h: 5, d: 8, color: "#7C3AED")
    m.slab("Toy Box Wall", x: -34, y: 0, z: 18, w: 8, h: 5, d: 0.5, color: "#7C3AED")
    m.slab("Toy Box Wall", x: -34, y: 0, z: 10, w: 8, h: 5, d: 0.5, color: "#7C3AED")
    m.part("Toy Box Curtain", at: (-30.2, 2.5, 14), size: (0.2, 5, 7.6), color: "#6D28D9", solid: false, opacity: 0.85)
    m.slab("Toy Box Sign", x: -30, y: 5, z: 14, w: 0.3, h: 1, d: 5, color: "#FDE68A")
    // Assembly line (west) and storage (east).
    for i in 0..<3 {
        m.slab("Conveyor", x: -32 + Float(i) * 0, y: 0, z: -14 + Float(i) * 5, w: 12, h: 1, d: 1.6, color: "#52525B")
        for k in 0..<4 {
            m.part("Toy Part", at: (-36 + Float(k) * 2.6, 1.3, -14 + Float(i) * 5), size: (0.7, 0.6, 0.7), color: ["#F472B6", "#60A5FA", "#FACC15", "#A3E635"][k],
                   shape: k % 2 == 0 ? .sphere : .box, solid: false)
        }
    }
    for i in 0..<3 {
        m.slab("Storage Shelf", x: 36, y: 0, z: -16 + Float(i) * 6, w: 8, h: 3, d: 1.2, color: "#78716C")
        m.part("Box", at: (34, 3.4, -16 + Float(i) * 6), size: (1.4, 0.8, 1), color: "#A16207", solid: false)
        m.part("Box", at: (38, 3.4, -16 + Float(i) * 6), size: (1.4, 0.8, 1), color: "#B45309", solid: false)
    }
    // The alcove (supply closet) where the vent starts.
    m.slab("Closet Wall", x: 34, y: 0, z: 10, w: 8, h: 5, d: 0.5, color: "#44403C")
    m.slab("Closet Wall", x: 34, y: 0, z: 22, w: 8, h: 5, d: 0.5, color: "#44403C")
    m.slab("Closet Wall", x: 38, y: 0, z: 16, w: 0.5, h: 5, d: 12, color: "#44403C")
    m.part("Vent Opening", at: (37.7, 1, 16), size: (0.2, 1.2, 2), color: "#111827", solid: false)
    m.slab("Mop Bucket", x: 35, y: 0, z: 20, w: 1, h: 0.8, d: 1, color: "#FACC15")
    // Prize corner with Jack's music box.
    m.slab("Prize Counter", x: 22, y: 0, z: 26, w: 8, h: 1.1, d: 1, color: "#16A34A")
    m.part("Jack Box", at: (22, 0.9, 30), size: (1.8, 1.8, 1.8), color: "#15803D")
    m.part("Jack Box Lid", at: (22, 1.9, 30), size: (1.9, 0.2, 1.9), color: "#FACC15", solid: false)
    m.part("Music Box Crank", at: (23.1, 1.1, 30), size: (0.5, 0.15, 0.15), color: "#FDE047", material: .metal, solid: false)
    for i in 0..<5 {
        m.part("Prize Plush", at: (18.5 + Float(i) * 1.8, 1.4, 26), size: (0.6, 0.6, 0.6), color: ["#F472B6", "#60A5FA", "#FACC15", "#A3E635", "#F97316"][i],
               shape: .sphere, solid: false)
    }

    // MARK: The vent duct, a closed passage outside the east wall.
    m.slab("Duct Floor", x: 60, y: 0, z: -8, w: 6, h: 0.1, d: 60, color: "#3F3F46")
    m.slab("Duct Wall", x: 57, y: 0, z: -8, w: 0.4, h: 2.4, d: 60, color: "#52525B")
    m.slab("Duct Wall", x: 63, y: 0, z: -8, w: 0.4, h: 2.4, d: 60, color: "#52525B")

    // Where the toys stand and walk to, and the cameras that watch them.
    let stations: [(String, Float, Float, Float)] = [("Stage", 0, 30, 0.8), ("Dining", 0, 0, 0), ("Toy Box", -34, 14, 0),
        ("Assembly", -28, -6, 0), ("Storage", 28, -8, 0), ("Closet", 33, 16, 0), ("Hall West", -10.5, -16, 0),
        ("Hall East", 10.5, -16, 0), ("Door L", -8.2, -32, 0), ("Door R", 8.2, -32, 0), ("Prize", 22, 30, 0),
        ("Vent A", 60, 18, 0.1), ("Vent B", 60, -16, 0.1), ("Vent", 60, -34, 0.1)]
    for st in stations {
        m.part("Station \(st.0)", at: (st.1, st.3 + 0.1, st.2), size: (1.5, 0.1, 1.5), color: "#000000", solid: false, visible: false)
    }
    let cams: [(Float, Float, Float)] = [(0, 6, 20), (-12, 6, -6), (-24, 5, 6), (-18, 6, 0), (18, 6, 0), (-10.5, 5, -6),
                                         (10.5, 5, -6), (14, 6, 20), (60, 2.2, -2)]
    for (i, c) in cams.enumerated() {
        m.part("Cam \(i + 1)", at: (c.0, c.1, c.2), size: (0.35, 0.35, 0.35), color: "#EF4444", shape: .sphere, material: .neon, solid: false)
    }
}

// MARK: 54 Midnight Guard

func midnightGuard(_ m: MapBuilder) {
    m.sky("#000000", "#050505", light: 0.3, showGround: false)
    m.ground(120, 120, color: "#1F2937", name: "Facility Floor")
    m.walls(0, 0, w: 120, d: 120, h: 6, color: "#374151", name: "Facility Wall")
    m.part("Cover Focus", at: (0, 2, 0), size: (90, 1, 1), color: "#000000", tags: ["yaw=35"], solid: false, visible: false)

    /// A wall along x (at z) or along z (at x), from a to b, with doorways
    /// (centre, width) cut out of it.
    func wall(alongX: Bool, at fixed: Float, from a: Float, to b: Float, doors: [(Float, Float)] = [], h: Float = 4.5,
              color: String = "#4B5563", name: String = "Wall") {
        func piece(_ lo: Float, _ hi: Float) {
            guard hi - lo > 0.01 else { return }
            if alongX { m.slab(name, x: (lo + hi) / 2, y: 0, z: fixed, w: hi - lo, h: h, d: 0.5, color: color) }
            else { m.slab(name, x: fixed, y: 0, z: (lo + hi) / 2, w: 0.5, h: h, d: hi - lo, color: color) }
        }
        var cursor = a
        for d in doors.sorted(by: { $0.0 < $1.0 }) {
            piece(cursor, d.0 - d.1 / 2)
            cursor = d.0 + d.1 / 2
        }
        piece(cursor, b)
    }
    /// A room: four walls with doorways on the named sides (N is +z).
    func room(_ name: String, _ cx: Float, _ cz: Float, w: Float, d: Float, doors: [(String, Float)], color: String, floor: String) {
        m.slab("\(name) Floor", x: cx, y: 0, z: cz, w: w, h: 0.05, d: d, color: floor)
        func gaps(_ side: String) -> [(Float, Float)] { doors.filter { $0.0 == side }.map { ($0.1, 5) } }
        wall(alongX: true, at: cz + d / 2, from: cx - w / 2, to: cx + w / 2, doors: gaps("N"), color: color, name: "\(name) Wall")
        wall(alongX: true, at: cz - d / 2, from: cx - w / 2, to: cx + w / 2, doors: gaps("S"), color: color, name: "\(name) Wall")
        wall(alongX: false, at: cx + w / 2, from: cz - d / 2, to: cz + d / 2, doors: gaps("E"), color: color, name: "\(name) Wall")
        wall(alongX: false, at: cx - w / 2, from: cz - d / 2, to: cz + d / 2, doors: gaps("W"), color: color, name: "\(name) Wall")
        m.part("\(name) Center", at: (cx, 0.1, cz), size: (1, 0.1, 1), color: "#000000", solid: false, visible: false)
        m.part("\(name) Light", at: (cx, 4.3, cz), size: (4, 0.2, 4), color: "#FEF9C3", material: .neon, solid: false)
    }
    /// A corridor 5 m wide between two doorways, walls on both sides.
    func corridor(alongX: Bool, at c: Float, from a: Float, to b: Float) {
        wall(alongX: alongX, at: c - 2.5, from: a, to: b, h: 4, color: "#374151", name: "Corridor Wall")
        wall(alongX: alongX, at: c + 2.5, from: a, to: b, h: 4, color: "#374151", name: "Corridor Wall")
        if alongX { m.slab("Corridor Floor", x: (a + b) / 2, y: 0, z: c, w: b - a, h: 0.04, d: 5, color: "#111827") }
        else { m.slab("Corridor Floor", x: c, y: 0, z: (a + b) / 2, w: 5, h: 0.04, d: b - a, color: "#111827") }
        for t in stride(from: a + 4, to: b, by: 8) {
            m.part("Corridor Lamp", at: alongX ? (t, 3.9, c) : (c, 3.9, t), size: (0.6, 0.15, 0.6), color: "#94A3B8", material: .neon, solid: false)
        }
    }
    func generator(_ wing: String, _ x: Float, _ z: Float, pad: (Float, Float)) {
        m.slab("Generator Body", x: x, y: 0, z: z, w: 2.2, h: 1.6, d: 1.4, color: "#6B7280", material: .metal)
        m.part("Generator Lamp", at: (x, 1.8, z), size: (0.4, 0.3, 0.4), color: "#FACC15", shape: .sphere, material: .neon, solid: false)
        m.pad("Generator \(wing)", x: pad.0, z: pad.1, size: 2, color: "#FACC15", tags: ["generator"])
    }
    func checkpoint(_ wing: String, _ x: Float, _ z: Float) {
        m.pad("Checkpoint \(wing)", x: x, z: z, size: 1.6, color: "#22D3EE", tags: ["checkpoint"])
        m.part("Checkpoint Panel", at: (x, 1.6, z), size: (0.5, 0.7, 0.5), color: "#0891B2", material: .neon, solid: false)
    }

    // MARK: The guard hub in the middle.
    room("Hub", 0, 0, w: 18, d: 18, doors: [("N", 0), ("S", 0), ("E", 0), ("W", 0)], color: "#1E3A8A", floor: "#1E3A8A")
    m.spawnRing(0, 0, radius: 3, count: 8, color: "#93C5FD")
    m.slab("Guard Desk", x: -6, y: 0, z: -6, w: 3.5, h: 1, d: 1.6, color: "#78350F")
    for x: Float in [-7, -5] { m.part("Guard Monitor", at: (x, 1.5, -6.6), size: (1.4, 0.9, 0.1), color: "#38BDF8", material: .neon, solid: false) }
    m.pad("Fuel Depot", x: -6, z: 6, size: 2.2, color: "#F97316", tags: ["fuel"])
    for dx: Float in [-7.8, -4.2] { m.slab("Fuel Can", x: dx, y: 0, z: 7.6, w: 0.8, h: 1, d: 0.6, color: "#DC2626") }
    m.pad("Charger", x: 6, z: 6, size: 2, color: "#22C55E", tags: ["charger"])
    m.slab("Charging Station", x: 6, y: 0, z: 8.1, w: 2, h: 1.4, d: 0.5, color: "#166534")
    m.pad("Locker", x: 6, z: -6, size: 2, color: "#3B82F6", tags: ["locker"])
    for i in 0..<3 { m.slab("Locker Door", x: 4.6 + Float(i) * 1.4, y: 0, z: -8.3, w: 1.2, h: 2.4, d: 0.6, color: "#475569") }

    // MARK: The six wings.
    room("Server", 0, 44, w: 26, d: 20, doors: [("S", 0), ("W", 44)], color: "#334155", floor: "#1E293B")
    for x: Float in [-8, 8] {
        m.slab("Server Rack", x: x, y: 0, z: 44, w: 1.2, h: 2.8, d: 8, color: "#111827")
        for k in 0..<4 {
            m.part("Rack LED", at: (x + (x < 0 ? 0.65 : -0.65), 0.6 + Float(k) * 0.6, 44), size: (0.05, 0.08, 7), color: k % 2 == 0 ? "#22C55E" : "#3B82F6",
                   material: .neon, solid: false)
        }
    }
    generator("Server", 9, 51.5, pad: (9, 48.8))
    checkpoint("Server", -9, 52)
    room("Lobby", 0, -44, w: 26, d: 20, doors: [("N", 0), ("E", -44)], color: "#57534E", floor: "#44403C")
    m.slab("Reception Desk", x: 5, y: 0, z: -50, w: 7, h: 1.1, d: 1.5, color: "#92400E")
    m.slab("Front Doors", x: 0, y: 0, z: -54, w: 6, h: 3, d: 0.2, color: "#93C5FD", material: .glass, opacity: 0.5)
    m.part("Lobby Sign", at: (0, 3.6, -53.6), size: (8, 0.8, 0.1), color: "#22D3EE", material: .neon, solid: false)
    for p in [(-11, -36), (11, -36), (-11, -52)] as [(Float, Float)] {
        m.part("Plant Pot", at: (p.0, 0.4, p.1), size: (1, 0.8, 1), color: "#78350F", shape: .cylinder)
        m.part("Plant", at: (p.0, 1.5, p.1), size: (1.6, 1.6, 1.6), color: "#166534", shape: .sphere, material: .matte, solid: false)
    }
    generator("Lobby", -10, -51.5, pad: (-10, -48.8))
    checkpoint("Lobby", -11, -38)
    room("Lab", -44, 0, w: 20, d: 26, doors: [("E", 0), ("N", -44)], color: "#475569", floor: "#E2E8F0")
    for z: Float in [-8, 8] {
        m.slab("Lab Bench", x: -48, y: 0, z: z, w: 6, h: 1, d: 1.4, color: "#F8FAFC")
        for k in 0..<3 {
            m.part("Flask", at: (-50 + Float(k) * 2, 1.3, z), size: (0.4, 0.6, 0.4), color: ["#22C55E", "#A855F7", "#F97316"][k], shape: .cylinder,
                   material: .neon, solid: false)
        }
    }
    m.part("Specimen Tank", at: (-51.5, 1.8, 0), size: (2.6, 3.6, 2.6), color: "#4ADE80", shape: .cylinder, material: .glass, opacity: 0.6)
    generator("Lab", -50.5, -11, pad: (-47.6, -11))
    checkpoint("Lab", -37, -11)
    room("Archive", 44, 0, w: 20, d: 26, doors: [("W", 0), ("S", 44)], color: "#57534E", floor: "#78716C")
    for z: Float in [-8, 8] {
        m.slab("Archive Shelf", x: 46, y: 0, z: z, w: 10, h: 3, d: 1, color: "#92400E")
        for k in 0..<5 {
            m.part("Files", at: (42 + Float(k) * 2, 3.2, z), size: (1.2, 0.4, 0.8), color: k % 2 == 0 ? "#FDE68A" : "#F5F5F4", solid: false)
        }
    }
    generator("Archive", 51, 11, pad: (48.2, 11))
    checkpoint("Archive", 37, 11)
    room("Ward", -44, 44, w: 20, d: 20, doors: [("S", -44), ("E", 44)], color: "#94A3B8", floor: "#CBD5E1")
    for z: Float in [38, 44, 50] {
        m.slab("Ward Bed", x: -52, y: 0, z: z, w: 2.2, h: 0.7, d: 3.2, color: "#F1F5F9")
        m.part("Ward Curtain", at: (-50.4, 1.6, z), size: (0.05, 3.2, 3.2), color: "#BAE6FD", solid: false, opacity: 0.7)
        m.part("IV Stand", at: (-50.8, 1.2, z - 1.6), size: (0.1, 2.4, 0.1), color: "#9CA3AF", solid: false)
    }
    generator("Ward", -38, 51.5, pad: (-38, 48.8))
    checkpoint("Ward", -46, 52.5)
    room("Boiler", 44, -44, w: 20, d: 20, doors: [("N", 44), ("W", -44)], color: "#7C2D12", floor: "#44403C")
    for z: Float in [-38, -46] {
        m.part("Boiler Tank", at: (51, 2.2, z), size: (4, 4.4, 4), color: "#9A3412", shape: .cylinder, material: .metal)
    }
    for y: Float in [3.2, 3.8] {
        m.part("Pipe", at: (44, y, -53), size: (18, 0.4, 0.4), color: "#B45309", shape: .cylinder, material: .metal, solid: false, rotation: (0, 0, 90))
    }
    generator("Boiler", 38, -51.5, pad: (40.8, -51.5))
    checkpoint("Boiler", 52.5, -52.5)

    // MARK: Corridors: a cross from the hub, and a ring through the wings.
    corridor(alongX: false, at: 0, from: 9, to: 34)
    corridor(alongX: false, at: 0, from: -34, to: -9)
    corridor(alongX: true, at: 0, from: -34, to: -9)
    corridor(alongX: true, at: 0, from: 9, to: 34)
    corridor(alongX: false, at: -44, from: 13, to: 34)
    corridor(alongX: true, at: 44, from: -34, to: -13)
    corridor(alongX: false, at: 44, from: -34, to: -13)
    corridor(alongX: true, at: -44, from: 13, to: 34)
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
