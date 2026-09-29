import Foundation

// Games 96–110: driving and vehicles, each after a vehicle game popular on
// Roblox (docs/research-150.md). Most run on lib/kit_ride.absc, which
// handles the ride's look and speed, boosts, launches and flying.

let vehicleGames: [Game] = [
    Game(number: 102, id: "island-flight-school", title: "Island Flight School",
         summary: "島の空港でパイロットになろう！ スロットルで速さ、⬆⬇で上昇・下降。お客さんをのせて ほかの島の空港へ飛び、滑走路にふんわり着陸。ランクが上がると ジェット機や旅客機に乗れる。",
         tags: ["flying", "simulator", "roleplay"], maxPlayers: 12, libs: ["ride"], build: islandFlightSchool),
    Game(number: 101, id: "build-a-plane", title: "Build a Plane & Fly",
         summary: "がけの上の格納庫で飛行機を組み立てて、海の向こうへ飛ばそう！ 遠くへ飛ぶほどお金が入る。つばさ・エンジン・タンク・しっぽ・ブースターを強くして、4つの島を見つけよう。",
         tags: ["building", "flying", "simulator"], maxPlayers: 8, libs: ["ride"], build: buildAPlane),
    Game(number: 100, id: "dusty-road-trip", title: "Dusty Road Trip",
         summary: "砂漠の一本道を、どこまで行ける？ ガソリン・エンジン・水に気をつけて、とちゅうの廃墟でガソリン缶や部品をひろおう。夜は盗賊、昼は砂あらし。2.4km先のオアシスの町をめざせ！",
         tags: ["survival", "cars", "desert"], maxPlayers: 8, libs: ["ride", "move"], build: dustyRoadTrip),
    Game(number: 99, id: "green-valley-drive", title: "Green Valley Drive",
         summary: "緑の谷の町をドライブ！ ガソリンを入れて、信号とスピードを守って、宅配やピザ配達でお金をかせごう。免許試験に合格すると乗れる車がふえる。洗車もできるよ。",
         tags: ["roleplay", "cars", "town"], maxPlayers: 12, libs: ["ride", "move"], build: greenValleyDrive),
    Game(number: 98, id: "dream-car-dealership", title: "Dream Car Dealership",
         summary: "自分の車屋さんをひらこう！ 工場から車を仕入れて並べると、お客さんが見に来て買っていく。店を大きく、スタッフをやとって、スーパーカーまで。自分の車はテストコースで試乗も。",
         tags: ["tycoon", "cars", "shop"], maxPlayers: 6, libs: ["ride"], build: dreamCarDealership),
    Game(number: 97, id: "midnight-highway-battle", title: "Midnight Highway Battle",
         summary: "真夜中の高速道路。ライバルのうしろでパッシング🔦するとバトル開始！ はなされるほどSPがへって、先に0になったほうの負け。一般車をよけながら走れ。パーキングで車とチューニング。",
         tags: ["racing", "cars", "night"], maxPlayers: 12, libs: ["ride", "move"], build: midnightHighway),
    Game(number: 96, id: "drag-strip-kings", title: "Drag Strip Kings",
         summary: "400mのドラッグレース！ メーターが🟩のときにシフトアップ、ここぞでニトロ。エンジン・ターボ・タイヤをチューニングして、10人のライバルに勝ちすすめ。ウイリーも。",
         tags: ["racing", "cars", "tuning"], maxPlayers: 8, libs: ["rounds", "ride"], build: dragStripKings),
]

// MARK: 96 Drag Strip Kings (Drag Drive Simulator)

func dragStripKings(_ m: MapBuilder) {
    m.sky("#0F172A", "#F97316", light: 0.6, ground: "#1C1917", fall: -30)
    m.environment.skyStyle = .sunset
    m.ground(160, 620, color: "#292524", z: 200, material: .matte)
    let lanes = 8
    let laneW: Float = 3.6
    let x0 = -Float(lanes) * laneW / 2
    // The strip: eight lanes, walls between, the start and the finish.
    m.slab("Strip", x: 0, y: -0.02, z: 210, w: Float(lanes) * laneW, h: 0.04, d: 480, color: "#44403C")
    for i in 0...lanes {
        let x = x0 + Float(i) * laneW
        m.slab("Lane Wall", x: x, y: 0, z: 210, w: 0.3, h: 0.9, d: 480, color: i == 0 || i == lanes ? "#F8FAFC" : "#A8A29E")
    }
    for i in 0..<lanes {
        let x = x0 + (Float(i) + 0.5) * laneW
        m.part("Lane Start \(i + 1)", at: (x, 0.1, -4), size: (1, 0.2, 1), color: "#000000", solid: false, visible: false)
        m.part("Lane Line", at: (x, 0.01, 200), size: (0.12, 0.02, 400), color: "#FACC15", solid: false, opacity: 0.4)
    }
    m.part("Start Line", at: (0, 0.02, 0), size: (Float(lanes) * laneW, 0.03, 0.6), color: "#FFFFFF", material: .neon, solid: false)
    m.part("Finish Line", at: (0, 0.02, 400), size: (Float(lanes) * laneW, 0.03, 1.2), color: "#EF4444", material: .neon, solid: false)
    m.part("Drag Finish", at: (0, 2, 401), size: (Float(lanes) * laneW, 4, 2), color: "#EF4444", material: .neon, behavior: .trigger,
           tags: ["drag_finish"], solid: false, opacity: 0.12)
    for (k, z) in [100, 200, 300].enumerated() {
        m.part("Distance Board \(k + 1)", at: (x0 - 2.5, 3, Float(z)), size: (0.3, 2, 3), color: "#FDE68A", material: .neon, solid: false)
    }
    // The tree of lights, and the gantry over the finish.
    m.slab("Tree Post", x: 0, y: 0, z: -1.5, w: 0.4, h: 4.6, d: 0.4, color: "#1F2937")
    for (k, c) in ["#F59E0B", "#F59E0B", "#F59E0B", "#22C55E"].enumerated() {
        m.part("Tree Light \(k + 1)", at: (0, 4.2 - Float(k) * 0.8, -1.2), size: (0.6, 0.6, 0.2), color: "#3F3F46", shape: .sphere,
               material: .neon, tags: ["tree_light", c], solid: false)
    }
    m.slab("Gantry", x: 0, y: 7, z: 400, w: Float(lanes) * laneW + 2, h: 0.8, d: 1, color: "#1F2937")
    m.slab("Gantry Leg", x: x0 - 1, y: 0, z: 400, w: 0.6, h: 7, d: 0.6, color: "#1F2937")
    m.slab("Gantry Leg", x: -x0 + 1, y: 0, z: 400, w: 0.6, h: 7, d: 0.6, color: "#1F2937")
    m.slab("Shutdown Wall", x: 0, y: 0, z: 450.5, w: Float(lanes) * laneW + 2, h: 3, d: 1, color: "#DC2626")
    // Staging and the pits: where you wait, tune and paint.
    m.slab("Pits", x: 0, y: -0.05, z: -24, w: 60, h: 0.1, d: 36, color: "#57534E")
    m.spawnRing(0, -26, radius: 4, count: 8, color: "#F97316")
    m.pad("Garage Pad", x: -18, z: -30, size: 3.4, color: "#F59E0B", tags: ["garage"])
    m.pad("Tune Pad", x: -10, z: -34, size: 3.4, color: "#22D3EE", tags: ["tune"])
    m.pad("Rival Board", x: 12, z: -32, size: 3.4, color: "#EF4444", tags: ["rivals"])
    m.part("Rival Sign", at: (12, 3, -36), size: (8, 3, 0.3), color: "#991B1B", material: .neon, solid: false)
    m.slab("Garage Shed", x: -18, y: 0, z: -38, w: 12, h: 4, d: 6, color: "#78716C")
    m.slab("Grandstand", x: x0 - 12, y: 0, z: 200, w: 8, h: 5, d: 260, color: "#475569")
    for k in 0..<12 {
        m.lamp(-x0 + 3, Float(k) * 40, glow: "#FDE68A")
    }
    m.coverFocus(x: 0, y: 1, z: 30, yaw: 180, width: 40)
}

// MARK: 97 Midnight Highway Battle (Midnight Racing: Tokyo)

/// The loop's corners, clockwise, at the centre of the road.
let highwayCorners: [(Float, Float)] = [(-300, -100), (300, -100), (300, 100), (-300, 100)]

func midnightHighway(_ m: MapBuilder) {
    m.night(ground: "#0B1120")
    m.environment.skyStyle = .stars
    m.ground(760, 360, color: "#0B1120", material: .matte)
    let road: Float = 16
    // The four stretches, with rails either side.
    for i in 0..<4 {
        let a = highwayCorners[i], b = highwayCorners[(i + 1) % 4]
        let alongX = abs(b.0 - a.0) > 0
        let length = alongX ? abs(b.0 - a.0) : abs(b.1 - a.1)
        let cx = (a.0 + b.0) / 2, cz = (a.1 + b.1) / 2
        m.part("Highway", at: (cx, 0.02, cz), size: alongX ? (length + road, 0.04, road) : (road, 0.04, length + road), color: "#1F2937",
               material: .matte)
        for k in [-1, 1] as [Float] {
            let off = k * road / 2
            // The inner rail has a gap to the parking area on the south stretch.
            if i == 0 && k > 0 {
                m.slab("Rail", x: cx - length / 4 - 10, y: 0, z: cz + off, w: length / 2 - 20 + road, h: 1, d: 0.4, color: "#9CA3AF", material: .metal)
                m.slab("Rail", x: cx + length / 4 + 10, y: 0, z: cz + off, w: length / 2 - 20 + road, h: 1, d: 0.4, color: "#9CA3AF", material: .metal)
                continue
            }
            // The inner rail (towards the middle of the loop) stops short of
            // the corners; the outer one runs round them.
            let inner = alongX ? (cz + off).magnitude < cz.magnitude : (cx + off).magnitude < cx.magnitude
            let railLength = inner ? length - road : length + road
            m.slab("Rail", x: alongX ? cx : cx + off, y: 0, z: alongX ? cz + off : cz, w: alongX ? railLength : 0.4, h: 1,
                   d: alongX ? 0.4 : railLength, color: "#9CA3AF", material: .metal)
        }
        // Lane marks and lamps.
        let marks = Int(length / 12)
        for s in 0..<marks {
            let t = (Float(s) + 0.5) / Float(marks)
            let x = a.0 + (b.0 - a.0) * t, z = a.1 + (b.1 - a.1) * t
            for lane in [-1, 1] as [Float] {
                m.part("Lane Mark", at: alongX ? (x, 0.05, z + lane * 4) : (x + lane * 4, 0.05, z), size: alongX ? (4, 0.02, 0.2) : (0.2, 0.02, 4),
                       color: "#E5E7EB", solid: false)
            }
            if s % 3 == 0 {
                m.part("Lamp", at: alongX ? (x, 7, z - road / 2 - 1) : (x - road / 2 - 1, 7, z), size: (1.2, 0.3, 1.2), color: "#FDE68A", material: .neon,
                       solid: false)
                m.part("Lamp Post", at: alongX ? (x, 3.5, z - road / 2 - 1) : (x - road / 2 - 1, 3.5, z), size: (0.3, 7, 0.3), color: "#374151",
                       solid: false)
            }
        }
    }
    // Route markers the traffic and rivals drive by (each lane's corners).
    for (i, c) in highwayCorners.enumerated() {
        m.part("Corner \(i + 1)", at: (c.0, 0.8, c.1), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    }
    // Traffic: slow cars round the loop.
    var r = Seeded("midnight")
    for i in 0..<10 {
        let c = highwayCorners[i % 4]
        m.movingHazard("Traffic \(i + 1)", at: (c.0 + r.range(-4, 4), 0.9, c.1 + r.range(-4, 4)), size: (2.2, 1.6, 2.2),
                       color: r.pick(["#E5E7EB", "#9CA3AF", "#1D4ED8", "#B91C1C", "#FDE68A"]), material: .metal, tags: ["traffic", "lane=\(i % 3 - 1)"])
    }
    // The parking area, off the south stretch.
    m.slab("Parking", x: 0, y: -0.05, z: -40, w: 70, h: 0.1, d: 50, color: "#111827")
    m.part("Parking Road", at: (0, 0.02, -75), size: (20, 0.04, 34), color: "#1F2937", material: .matte)
    m.spawnRing(0, -38, radius: 5, count: 8, color: "#A855F7")
    m.pad("Dealer Pad", x: -20, z: -50, size: 3.4, color: "#F59E0B", tags: ["dealer"])
    m.pad("Tune Pad", x: 20, z: -50, size: 3.4, color: "#22D3EE", tags: ["tune"])
    m.pad("Rival Pad", x: 0, z: -58, size: 3.4, color: "#EF4444", tags: ["rivals"])
    for k in 0..<8 {
        m.part("Parking Line", at: (-28 + Float(k) * 8, 0.02, -30), size: (0.2, 0.02, 6), color: "#FFFFFF", solid: false)
    }
    m.part("Vending", at: (30, 1.2, -32), size: (1.4, 2.4, 1), color: "#DC2626", material: .neon, solid: false)
    // The city around, lit.
    for _ in 0..<50 {
        let x = r.range(-360, 360), z = r.pick([r.range(-175, -125), r.range(125, 175)])
        let h = r.range(20, 80)
        m.part("Tower", at: (x, h / 2, z), size: (r.range(12, 24), h, r.range(12, 24)), color: "#111827", material: .matte, solid: false)
        m.part("Tower Lights", at: (x, h * 0.6, z), size: (r.range(10, 20), h * 0.5, 0.2), color: r.pick(["#F472B6", "#22D3EE", "#FDE68A"]),
               material: .neon, solid: false, opacity: 0.35)
    }
    m.coverFocus(x: -150, y: 3, z: -100, yaw: 110, width: 90)
}

// MARK: 98 Dream Car Dealership (Car Dealership Tycoon)

func dreamCarDealership(_ m: MapBuilder) {
    m.day(ground: "#4D7C0F")
    m.ground(340, 340, color: "#65A30D", material: .grass)
    // The main street, and six lots along it.
    m.road(from: (-150, 0), to: (150, 0), width: 12, name: "Main Street")
    m.spawnRing(0, 12, radius: 4, count: 8, color: "#F59E0B")
    m.part("Customer Gate", at: (-140, 0.1, 0), size: (1, 0.2, 1), color: "#000000", solid: false, visible: false)
    m.part("Customer Exit", at: (140, 0.1, 0), size: (1, 0.2, 1), color: "#000000", solid: false, visible: false)
    for k in 0..<6 {
        let side: Float = k < 3 ? -1 : 1
        let lx = Float(k % 3) * 90 - 90
        let lz = side * 26
        m.slab("Lot \(k + 1)", x: lx, y: -0.05, z: lz, w: 60, h: 0.1, d: 32, color: "#9CA3AF")
        m.pad("Lot Sign \(k + 1)", x: lx - 26, z: lz - side * 13, size: 3, color: "#E5E7EB", tags: ["lot", "k=\(k + 1)"])
        m.pad("Lot Buy \(k + 1)", x: lx - 20, z: lz - side * 13, size: 3, color: "#F59E0B", tags: ["catalog", "k=\(k + 1)"])
        m.pad("Lot Upgrade \(k + 1)", x: lx - 14, z: lz - side * 13, size: 3, color: "#A855F7", tags: ["build", "k=\(k + 1)"])
        // Twelve display spots, and where the salespeople stand.
        for j in 0..<12 {
            let sx = lx - 26 + Float(j % 6) * 7, sz = lz + side * (Float(j / 6) * 9 - 2)
            m.part("Lot \(k + 1) Spot \(j + 1)", at: (sx, 0.1, sz), size: (4, 0.1, 6), color: "#FFFFFF", solid: false, opacity: 0.35)
        }
        m.part("Lot \(k + 1) Staff", at: (lx + 22, 0.1, lz - side * 6), size: (1, 0.2, 1), color: "#000000", solid: false, visible: false)
        // The showroom: pieces a script shows as the dealership grows.
        let bx = lx + 22, bz = lz + side * 6
        m.group("show\(k + 1)_1", shown: false) {
            m.slab("Showroom Floor", x: bx, y: 0, z: bz, w: 14, h: 0.3, d: 14, color: "#F1F5F9")
        }
        m.group("show\(k + 1)_2", shown: false) {
            m.slab("Showroom Wall", x: bx, y: 0.3, z: bz + side * 6.8, w: 14, h: 5, d: 0.4, color: "#E2E8F0")
            m.slab("Showroom Wall", x: bx + 6.8, y: 0.3, z: bz, w: 0.4, h: 5, d: 14, color: "#E2E8F0")
        }
        m.group("show\(k + 1)_3", shown: false) {
            m.slab("Showroom Glass", x: bx - 6.8, y: 0.3, z: bz, w: 0.3, h: 5, d: 14, color: "#BAE6FD", material: .glass, opacity: 0.4)
            m.slab("Showroom Roof", x: bx, y: 5.3, z: bz, w: 14.6, h: 0.5, d: 14.6, color: "#1E293B")
        }
        m.group("show\(k + 1)_4", shown: false) {
            m.part("Showroom Sign", at: (bx, 7, bz + side * 7), size: (10, 1.4, 0.3), color: "#F43F5E", material: .neon, solid: false)
            m.part("Turntable", at: (bx, 0.4, bz), size: (7, 0.2, 7), color: "#FDE68A", shape: .cylinder, material: .neon, solid: false)
        }
        m.group("show\(k + 1)_5", shown: false) {
            for q in 0..<4 {
                m.part("Flag", at: (lx - 28 + Float(q) * 16, 4, lz - side * 15.5), size: (0.2, 8, 0.2), color: "#94A3B8", solid: false)
                m.part("Flag Top", at: (lx - 27.4 + Float(q) * 16, 7.4, lz - side * 15.5), size: (1.2, 0.8, 0.05), color: "#F59E0B", material: .neon,
                       solid: false)
            }
        }
    }
    // The test track behind the lots.
    let track: [(Float, Float)] = [(-120, 70), (120, 70), (120, 130), (-120, 130)]
    for i in 0..<4 {
        m.road(from: track[i], to: track[(i + 1) % 4], width: 12, name: "Test Track")
        m.part("TT \(i + 1)", at: (track[i].0, 2, track[i].1), size: (12, 4, 12), color: "#FFFFFF", shape: .cylinder, behavior: .trigger,
               tags: ["tt", "n=\(i + 1)"], solid: false, opacity: 0.06)
    }
    m.pad("Test Drive Pad", x: -120, z: 56, size: 3.4, color: "#22C55E", tags: ["testdrive"])
    m.road(from: (-120, 5), to: (-120, 64), width: 8, name: "Track Road")
    var r = Seeded("dealer")
    for _ in 0..<30 { m.tree(r.range(-160, 160), r.pick([r.range(-160, -50), r.range(145, 160)]), height: r.range(4, 7)) }
    m.coverFocus(x: -90, y: 1, z: -26, yaw: 140, width: 60)
}

// MARK: 99 Green Valley Drive (Greenville)

/// The town's streets: four roads each way, 100 m apart; the outer ones make
/// a ring. The four crossings in the middle have traffic lights.
let valleyLines: [Float] = [-150, -50, 50, 150]

func greenValleyDrive(_ m: MapBuilder) {
    m.day(ground: "#4D7C0F")
    m.environment.skyStyle = .clouds
    m.ground(420, 420, color: "#65A30D", material: .grass)
    for v in valleyLines {
        m.road(from: (-156, v), to: (156, v), width: 12, name: "Street")
        m.road(from: (v, -156), to: (v, 156), width: 12, y: 0.025, name: "Avenue")
    }
    // Sidewalks round the middle block, where the plaza is.
    m.slab("Plaza", x: 0, y: -0.02, z: 0, w: 86, h: 0.06, d: 86, color: "#D6D3D1")
    m.spawnRing(0, 0, radius: 4, count: 8, color: "#22C55E")
    m.part("Fountain", at: (0, 0.5, 0), size: (6, 1, 6), color: "#7DD3FC", shape: .cylinder, material: .glass, solid: false, opacity: 0.7)
    // Traffic lights at the four middle crossings.
    var k = 0
    for x in [-50, 50] as [Float] {
        for z in [-50, 50] as [Float] {
            k += 1
            m.part("Cross \(k)", at: (x, 1.5, z), size: (11, 3, 11), color: "#FFFFFF", behavior: .trigger, tags: ["cross", "ix=\(k)"],
                   solid: false, visible: false)
            for (dir, dx, dz) in [("ns", Float(7), Float(-7)), ("ew", Float(-7), Float(7))] {
                m.part("Light Pole", at: (x + dx, 2.2, z + dz), size: (0.3, 4.4, 0.3), color: "#374151", solid: false)
                m.part("Light \(k) \(dir)", at: (x + dx, 4.6, z + dz), size: (0.9, 0.9, 0.9), color: "#22C55E", shape: .sphere,
                       material: .neon, tags: ["light", "ix=\(k)", "dir=\(dir)"], solid: false)
            }
            for (cx, cz, w, d) in [(x, z - 7.5, Float(10), Float(0.5)), (x, z + 7.5, Float(10), Float(0.5)),
                                   (x - 7.5, z, Float(0.5), Float(10)), (x + 7.5, z, Float(0.5), Float(10))] {
                m.part("Stop Line", at: (cx, 0.06, cz), size: (w, 0.02, d), color: "#F8FAFC", solid: false)
            }
        }
    }
    // Speed cameras: a zone sign before, the camera at the line.
    let cameras: [(Float, Float, Bool, Int)] = [(-100, -50, true, 60), (50, -100, false, 40), (0, 150, true, 60), (-150, 0, false, 80)]
    for (i, c) in cameras.enumerated() {
        let (x, z, alongX, limit) = c
        m.part("Camera \(i + 1)", at: (x, 1.5, z), size: alongX ? (2, 3, 12) : (12, 3, 2), color: "#FFFFFF", behavior: .trigger,
               tags: ["camera", "limit=\(limit)"], solid: false, visible: false)
        for off in [-24, 24] as [Float] {
            m.part("Camera Zone", at: alongX ? (x + off, 1.5, z) : (x, 1.5, z + off), size: alongX ? (2, 3, 12) : (12, 3, 2), color: "#FFFFFF",
                   behavior: .trigger, tags: ["zone", "limit=\(limit)"], solid: false, visible: false)
            m.part("Limit Sign", at: alongX ? (x + off, 3, z - 7.5) : (x - 7.5, 3, z + off), size: (1.6, 0.2, 1.6), color: limit < 50 ? "#FACC15" : "#F8FAFC",
                   shape: .cylinder, material: .neon, solid: false, rotation: (90, alongX ? 90 : 0, 0))
        }
        m.part("Camera Pole", at: alongX ? (x, 2.5, z - 7.5) : (x - 7.5, 2.5, z), size: (0.3, 5, 0.3), color: "#475569", solid: false)
        m.part("Camera Box", at: alongX ? (x, 5, z - 6.8) : (x - 6.8, 5, z), size: (1.2, 0.8, 1.2), color: "#1E293B", tags: ["camera_box", "n=\(i + 1)"],
               solid: false)
    }
    // The plaza: dealer, job centre, car wash, licence centre.
    m.shop("Car Dealer", x: -26, z: -30, w: 14, d: 10, color: "#FCA5A5", sign: "#EF4444", facing: 1)
    m.pad("Dealer Pad", x: -26, z: -20, size: 3.4, color: "#EF4444", tags: ["dealer"])
    for (j, c) in ["#EF4444", "#3B82F6", "#FACC15"].enumerated() {
        m.parkedCar("Show Car \(j + 1)", x: -38 + Float(j) * 4, z: -14, yaw: 180, color: c, sporty: j == 2)
    }
    m.shop("Job Center", x: 26, z: -30, w: 14, d: 10, color: "#FDE68A", sign: "#F59E0B", facing: 1)
    m.pad("Depot Pad", x: 26, z: -20, size: 3.4, color: "#F59E0B", tags: ["depot"])
    for q in 0..<3 { m.crate(20 + Float(q) * 2, -16, size: 1.2, color: "#B45309") }
    m.slab("Wash Frame", x: 26, y: 0, z: 30, w: 0.6, h: 4, d: 10, color: "#0EA5E9")
    m.slab("Wash Frame", x: 34, y: 0, z: 30, w: 0.6, h: 4, d: 10, color: "#0EA5E9")
    m.slab("Wash Roof", x: 30, y: 4, z: 30, w: 9, h: 0.4, d: 10, color: "#0369A1")
    m.part("Wash Brush", at: (30, 2, 30), size: (1, 3.2, 1), color: "#F472B6", shape: .cylinder, material: .neon, solid: false, opacity: 0.6)
    m.pad("Wash Pad", x: 30, z: 36, size: 3.4, color: "#38BDF8", tags: ["wash"])
    m.shop("License Center", x: -26, z: 30, w: 14, d: 10, color: "#C4B5FD", sign: "#7C3AED", facing: -1)
    m.pad("License Pad", x: -26, z: 20, size: 3.4, color: "#A855F7", tags: ["license"])
    // The exam course: eight gates round the middle crossings.
    let exam: [(Float, Float)] = [(-50, 20), (-50, -20), (-20, -50), (20, -50), (50, -20), (50, 20), (20, 50), (-20, 50)]
    for (i, e) in exam.enumerated() {
        m.part("Exam \(i + 1)", at: (e.0, 2, e.1), size: (12, 4, 12), color: "#A855F7", shape: .cylinder, behavior: .trigger,
               tags: ["exam", "n=\(i + 1)"], solid: false, opacity: 0.08)
    }
    // Gas stations.
    for (g, gx, gz) in [(1, Float(-100), Float(-100)), (2, Float(100), Float(100))] {
        m.slab("Station Floor", x: gx, y: -0.02, z: gz, w: 40, h: 0.06, d: 30, color: "#A8A29E")
        m.slab("Station Roof", x: gx, y: 5, z: gz, w: 30, h: 0.6, d: 16, color: "#DC2626")
        for c in [-12, 12] as [Float] { m.slab("Station Post", x: gx + c, y: 0, z: gz, w: 0.6, h: 5, d: 0.6, color: "#E5E7EB") }
        for q in 0..<4 {
            let px = gx - 9 + Float(q) * 6
            m.slab("Pump", x: px, y: 0, z: gz - 2, w: 1, h: 1.8, d: 0.8, color: "#F8FAFC")
            m.pad("Fuel \(g)-\(q + 1)", x: px, z: gz + 2, size: 3, color: "#F97316", tags: ["fuel"])
        }
        m.shop("Station Shop", x: gx, z: gz + (gz < 0 ? -12 : 12), w: 12, d: 6, color: "#FEF3C7", sign: "#F97316", facing: gz < 0 ? 1 : -1)
    }
    // Pizza shop and school.
    m.shop("Pizza Shop", x: -100, z: 88, w: 14, d: 10, color: "#FDBA74", sign: "#DC2626", facing: -1)
    m.pad("Pizza Pad", x: -100, z: 78, size: 3.4, color: "#DC2626", tags: ["pizza"])
    m.slab("School", x: 100, y: 0, z: -104, w: 40, h: 8, d: 24, color: "#FDE68A")
    m.slab("School Roof", x: 100, y: 8, z: -104, w: 42, h: 0.6, d: 26, color: "#B45309")
    m.part("School Clock", at: (100, 6.5, -91.8), size: (2.4, 0.2, 2.4), color: "#F8FAFC", shape: .cylinder, solid: false, rotation: (90, 0, 0))
    m.slab("School Yard", x: 100, y: -0.02, z: -76, w: 60, h: 0.05, d: 24, color: "#D97706")
    // Sixteen houses to deliver to, a pad by each front door.
    var drops: [(Float, Float, Float)] = []
    for bx in [-100, 0, 100] as [Float] {
        for bz in [-100, 0, 100] as [Float] where abs(bx) + abs(bz) == 100 {
            for (hx, facing) in [(Float(-22), Float(-1)), (22, -1), (-22, 1), (22, 1)] {
                let x = bx + hx, z = bz + facing * 28
                drops.append((x, z + facing * 10, facing))
            }
        }
    }
    var rr = Seeded("valley")
    for (i, d) in drops.enumerated() {
        let hz = d.1 - d.2 * 10
        m.house("House \(i + 1)", x: d.0, z: hz, w: 10, d: 8, wall: rr.pick(["#FEF3C7", "#E0F2FE", "#FCE7F3", "#DCFCE7", "#F5F5F4"]),
                roof: rr.pick(["#B91C1C", "#1D4ED8", "#15803D", "#7C2D12"]), tags: ["house"], facing: d.2)
        m.pad("Drop \(i + 1)", x: d.0, z: d.1 - d.2 * 3, size: 2.6, color: "#FDE68A", tags: ["drop", "n=\(i + 1)"])
    }
    // Traffic on the outer ring.
    let ring: [(Float, Float)] = [(-150, -150), (150, -150), (150, 150), (-150, 150)]
    for i in 0..<6 {
        let c = ring[i % 4]
        m.movingHazard("Traffic \(i + 1)", at: (c.0, 0.9, c.1), size: (2.2, 1.6, 2.2), color: rr.pick(["#E5E7EB", "#1D4ED8", "#B91C1C", "#FDE68A", "#0F766E"]),
                       material: .metal, tags: ["traffic", "lane=\(i % 2 == 0 ? 1 : -1)", "start=\(i % 4 + 1)"])
    }
    for (i, c) in ring.enumerated() {
        m.part("Ring \(i + 1)", at: (c.0, 0.9, c.1), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    }
    // Parked cars and trees round town.
    for _ in 0..<14 {
        let line = rr.pick(valleyLines), along = rr.range(-140, 140)
        if valleyLines.contains(where: { abs($0 - along) < 12 }) { continue }
        if rr.unit() < 0.5 {
            m.parkedCar("Parked", x: along, z: line + 8, yaw: 90, color: rr.pick(["#64748B", "#F8FAFC", "#1E3A8A", "#991B1B"]))
        } else {
            m.parkedCar("Parked", x: line + 8, z: along, yaw: 0, color: rr.pick(["#64748B", "#F8FAFC", "#1E3A8A", "#991B1B"]))
        }
    }
    for _ in 0..<60 {
        let x = rr.range(-205, 205), z = rr.range(-205, 205)
        if abs(x) < 162 && abs(z) < 162 { continue }
        m.tree(x, z, height: rr.range(4, 7))
    }
    for bx in [-100, 0, 100] as [Float] {
        for bz in [-100, 0, 100] as [Float] where bx != 0 || bz != 0 {
            for (cx, cz) in [(Float(-40), Float(-40)), (40, -40), (-40, 40), (40, 40)] { m.tree(bx + cx, bz + cz, height: 4.5) }
        }
    }
    m.coverFocus(x: -40, y: 1, z: -40, yaw: 135, width: 70)
}

// MARK: 100 Dusty Road Trip (A Dusty Trip)

/// The desert road, start to the oasis town, as points it bends at.
let dustyRoad: [(Float, Float)] = [(0, -10), (0, 200), (20, 400), (-10, 600), (-30, 800), (0, 1000), (30, 1200), (10, 1400), (-20, 1600),
                                   (0, 1800), (25, 2000), (0, 2200), (0, 2440)]

func dustyRoadTrip(_ m: MapBuilder) {
    m.sky("#60A5FA", "#FDE68A", light: 0.8, ground: "#D6B77A", fall: -30)
    m.environment.skyStyle = .clouds
    m.ground(420, 2700, color: "#E3C58D", z: 1200, material: .sand)
    for i in 0..<(dustyRoad.count - 1) {
        m.road(from: dustyRoad[i], to: dustyRoad[i + 1], width: 10, name: "Desert Road", dashed: false, color: "#6B5B4B")
        m.part("Road Point \(i + 1)", at: (dustyRoad[i].0, 0.5, dustyRoad[i].1), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    }
    // Mile markers every 100 m, so the distance is always in sight.
    var r = Seeded("dusty")
    for k in 1...24 {
        let (x, z) = dustyPoint(Float(k) * 100)
        m.part("Marker Post", at: (x + 7, 0.8, z), size: (0.3, 1.6, 0.3), color: "#F8FAFC", solid: false)
        m.part("Marker Top", at: (x + 7, 1.7, z), size: (0.6, 0.3, 0.2), color: k % 5 == 0 ? "#EF4444" : "#FACC15", material: .neon, solid: false)
    }
    // The garage at the start, and the start line.
    m.slab("Garage Yard", x: 0, y: -0.02, z: -40, w: 50, h: 0.06, d: 40, color: "#A8A29E")
    m.spawnRing(0, -40, radius: 4, count: 8, color: "#F97316")
    m.shop("Garage", x: -14, z: -52, w: 14, d: 10, color: "#FDBA74", sign: "#EA580C", facing: 1)
    m.pad("Garage Pad", x: -14, z: -42, size: 3.4, color: "#F97316", tags: ["garage"])
    m.pad("Record Pad", x: 14, z: -42, size: 3.4, color: "#FACC15", tags: ["records"])
    m.part("Start Line", at: (0, 1.5, 0), size: (10, 3, 1.5), color: "#FFFFFF", behavior: .trigger, tags: ["start_line"], solid: false, opacity: 0.25)
    m.part("Start Banner", at: (0, 5, 0), size: (12, 1, 0.3), color: "#F97316", material: .neon, solid: false)
    for x in [-6, 6] as [Float] { m.slab("Banner Post", x: x, y: 0, z: 0, w: 0.4, h: 5.5, d: 0.4, color: "#78716C") }
    // Stops along the way. Each one is some ruined buildings with things to find.
    let kinds = ["gas", "motel", "post", "farm", "junk", "post", "gas", "oasis", "post", "motel", "junk"]
    for (i, kind) in kinds.enumerated() {
        let (rx, rz) = dustyRoad[i + 1]
        let side: Float = i % 2 == 0 ? 1 : -1
        let cx = rx + side * 26, cz = rz
        m.slab("Stop Lot", x: cx, y: -0.01, z: cz, w: 34, h: 0.04, d: 30, color: "#C2A878")
        m.road(from: (rx + side * 5, rz), to: (cx - side * 10, cz), width: 6, name: "Side Road", dashed: false, color: "#7C6A58")
        var loot: [(String, Float, Float)] = []
        switch kind {
        case "gas":
            m.slab("Old Canopy", x: cx, y: 4, z: cz, w: 14, h: 0.5, d: 10, color: "#B91C1C", rotation: (0, 0, side * 4))
            m.slab("Old Post", x: cx - 5, y: 0, z: cz, w: 0.5, h: 4, d: 0.5, color: "#A8A29E")
            m.slab("Old Pump", x: cx + 2, y: 0, z: cz, w: 1, h: 1.6, d: 0.8, color: "#E7E5E4")
            m.house("Gas Shack \(i + 1)", x: cx + side * 10, z: cz - 8, w: 8, d: 6, wall: "#D6D3D1", roof: "#57534E", tags: ["ruin"], facing: 1)
            loot = [("fuel", cx - 2, cz + 2), ("fuel", cx + 4, cz - 3), ("fuel", cx + side * 10, cz - 8), ("scrap", cx - 6, cz + 8)]
        case "motel":
            m.house("Motel \(i + 1)", x: cx, z: cz - 6, w: 20, d: 7, wall: "#FDE68A", roof: "#9A3412", tags: ["ruin"], facing: 1)
            m.part("Motel Sign", at: (cx - side * 12, 5, cz + 6), size: (0.3, 2, 5), color: "#F472B6", material: .neon, solid: false)
            loot = [("water", cx - 6, cz - 6), ("water", cx + 6, cz - 6), ("scrap", cx, cz + 6), ("repair", cx + side * 12, cz + 8)]
        case "farm":
            m.house("Farm House \(i + 1)", x: cx - 6, z: cz - 5, w: 10, d: 8, wall: "#FEF3C7", roof: "#B91C1C", tags: ["ruin"], facing: 1)
            m.slab("Barn", x: cx + 9, y: 0, z: cz + 2, w: 10, h: 6, d: 12, color: "#991B1B")
            m.part("Windmill", at: (cx - 13, 5, cz + 10), size: (0.5, 10, 0.5), color: "#78716C", solid: false)
            m.part("Windmill Blades", at: (cx - 13, 10, cz + 10.4), size: (6, 0.5, 0.2), color: "#E7E5E4", solid: false, rotation: (0, 0, 30))
            loot = [("scrap", cx + 3, cz + 9), ("scrap", cx - 6, cz - 5), ("water", cx - 12, cz + 6), ("scrap", cx + 9, cz - 6)]
        case "junk":
            for q in 0..<6 {
                let jx = cx + r.range(-13, 13), jz = cz + r.range(-11, 11)
                m.parkedCar("Wreck", x: jx, z: jz, yaw: r.range(0, 360), color: r.pick(["#78350F", "#57534E", "#9A3412", "#44403C"]))
                _ = q
            }
            m.slab("Junk Pile", x: cx + side * 12, y: 0, z: cz - 10, w: 6, h: 2.5, d: 5, color: "#57534E", material: .metal)
            loot = [("scrap", cx - 8, cz + 12), ("scrap", cx + 8, cz + 12), ("repair", cx, cz - 12), ("repair", cx - side * 14, cz), ("fuel", cx + side * 14, cz + 6)]
        case "oasis":
            m.water(cx, cz, w: 16, d: 12, name: "Oasis", color: "#38BDF8", tags: ["oasis"])
            for (px, pz) in [(cx - 10, cz - 7), (cx + 10, cz + 7), (cx - 9, cz + 8), (cx + 11, cz - 6)] {
                m.pine(px, pz, height: 7, leaves: "#65A30D")
            }
            loot = [("water", cx - 12, cz), ("water", cx + 12, cz), ("fuel", cx, cz + 12)]
        default:
            // A trading post: someone still lives here and sells things.
            m.shop("Trading Post \(i + 1)", x: cx, z: cz - 6, w: 14, d: 9, color: "#A16207", sign: "#FACC15", facing: 1)
            m.pad("Trade Pad \(i + 1)", x: cx, z: cz + 3, size: 3.4, color: "#FACC15", tags: ["trade"])
            m.part("Post Flag", at: (cx + side * 10, 4, cz + 8), size: (0.2, 8, 0.2), color: "#78716C", solid: false)
            m.part("Post Flag Top", at: (cx + side * 10.6, 7.4, cz + 8), size: (1.2, 0.8, 0.05), color: "#22C55E", material: .neon, solid: false)
            loot = [("fuel", cx - 10, cz + 8), ("water", cx + 10, cz + 8)]
        }
        for (j, l) in loot.enumerated() {
            m.part("Loot \(i + 1)-\(j + 1)", at: (l.1, 0.6, l.2), size: (0.9, 0.9, 0.9), color: dustyLootColor(l.0), material: .neon,
                   behavior: .trigger, tags: ["loot", "kind=\(l.0)"])
        }
    }
    // Rocks on the road (they knock the engine), tumbleweeds rolling across.
    for k in 0..<26 {
        let d = 150 + Float(k) * 85 + r.range(-20, 20)
        let (x, z) = dustyPoint(d)
        m.part("Road Rock", at: (x + r.range(-3, 3), 0.35, z), size: (1.1, 0.7, 1.1), color: "#78716C", shape: .sphere, material: .stone,
               behavior: .trigger, tags: ["rock"], solid: false)
    }
    for k in 0..<10 {
        let (x, z) = dustyPoint(260 + Float(k) * 210)
        m.movingHazard("Tumbleweed \(k + 1)", at: (x - 14, 0.7, z), size: (1.4, 1.4, 1.4), color: "#A16207", shape: .sphere, material: .matte,
                       tags: ["tumbleweed"])
    }
    // Cacti, rocks and dunes for the view.
    for _ in 0..<150 {
        let z = r.range(-60, 2560), x = r.range(-200, 200)
        let (rx, _) = dustyPoint(max(0, z))
        if abs(x - rx) < 50 { continue }
        if r.unit() < 0.6 {
            m.pillar("Cactus", x: x, z: z, height: r.range(1.8, 4), radius: 0.35, color: "#3F6212")
        } else {
            m.rock(x, z, size: r.range(1.5, 5), color: r.pick(["#B45309", "#92400E", "#A8A29E"]))
        }
    }
    for _ in 0..<16 {
        let z = r.range(0, 2500), x = r.pick([r.range(-190, -80), r.range(80, 190)])
        m.part("Mesa", at: (x, 6, z), size: (r.range(20, 40), 12, r.range(20, 40)), color: "#C2410C", material: .sand, solid: false)
    }
    // The oasis town at the end.
    let (ex, ez) = dustyRoad[dustyRoad.count - 1]
    m.part("Goal Line", at: (ex, 1.5, ez - 20), size: (10, 3, 1.5), color: "#22C55E", behavior: .trigger, tags: ["goal_line"], solid: false, opacity: 0.3)
    m.part("Goal Banner", at: (ex, 5, ez - 20), size: (12, 1, 0.3), color: "#22C55E", material: .neon, solid: false)
    m.slab("Town Square", x: ex, y: -0.02, z: ez + 10, w: 60, h: 0.06, d: 50, color: "#FCD34D")
    m.water(ex, ez + 10, w: 14, d: 10, name: "Town Pool", color: "#22D3EE", tags: ["oasis"])
    for (hx, hz) in [(-22, 0), (22, 0), (-22, 24), (22, 24), (0, 30)] as [(Float, Float)] {
        m.house("Town House", x: ex + hx, z: ez + hz, w: 10, d: 8, wall: "#FEF3C7", roof: "#0E7490", tags: ["town"], facing: hz > 10 ? -1 : 1)
    }
    for q in 0..<8 { m.pine(ex - 28 + Float(q) * 8, ez + 38, height: 8, leaves: "#16A34A") }
    m.coverFocus(x: 0, y: 1, z: 190, yaw: 200, width: 60)
}

/// The point on the desert road `distance` metres along it (measured in z).
func dustyPoint(_ distance: Float) -> (Float, Float) {
    for i in 0..<(dustyRoad.count - 1) where dustyRoad[i + 1].1 >= distance {
        let a = dustyRoad[i], b = dustyRoad[i + 1]
        let t = (distance - a.1) / (b.1 - a.1)
        return (a.0 + (b.0 - a.0) * t, distance)
    }
    return dustyRoad[dustyRoad.count - 1]
}

func dustyLootColor(_ kind: String) -> String {
    switch kind {
    case "fuel": return "#EF4444"
    case "water": return "#38BDF8"
    case "repair": return "#A3E635"
    default: return "#A8A29E"
    }
}

// MARK: 101 Build a Plane & Fly (Build a Plane)

/// Where the four islands are, out over the sea (x, z).
let planeIslands: [(Float, Float)] = [(0, 700), (40, 1500), (-40, 2500), (0, 3600)]

func buildAPlane(_ m: MapBuilder) {
    m.ocean()
    m.environment.skyStyle = .clouds
    // The sea: a sand floor under a sheet of water you splash into.
    m.ground(700, 4400, color: "#C2B280", y: -4, z: 2050, material: .sand)
    m.part("Sea", at: (0, -0.6, 2110), size: (700, 1, 4200), color: "#1D6FB8", material: .glass, behavior: .trigger, tags: ["sea"],
           solid: false, opacity: 0.85)
    // The cliff with the hangars and the runway.
    m.slab("Cliff", x: 0, y: -4, z: -45, w: 240, h: 19, d: 130, color: "#78716C", material: .stone)
    m.slab("Cliff Top", x: 0, y: 15, z: -45, w: 240, h: 0.2, d: 130, color: "#65A30D", material: .grass)
    m.spawnRing(0, -95, y: 15.2, radius: 4, count: 8, color: "#38BDF8")
    m.part("Runway", at: (0, 15.25, -20), size: (14, 0.1, 76), color: "#374151", material: .matte, solid: false)
    for k in 0..<8 { m.part("Runway Line", at: (0, 15.32, -52 + Float(k) * 9), size: (0.4, 0.02, 4), color: "#F8FAFC", solid: false) }
    m.pad("Launch Pad", x: 0, z: -50, y: 15.2, size: 4, color: "#22C55E", tags: ["launch"])
    m.part("Ramp", at: (0, 16, 14), size: (14, 0.4, 10), color: "#F97316", solid: false, rotation: (-12, 0, 0))
    m.part("Launch Arch", at: (0, 22, 16), size: (18, 1, 1), color: "#F97316", material: .neon, solid: false)
    for x in [-9, 9] as [Float] { m.slab("Arch Post", x: x, y: 15.2, z: 16, w: 0.8, h: 7, d: 0.8, color: "#9A3412") }
    // Eight hangars; the plane inside is built from parts that appear as you buy them.
    let tiers = ["#A16207"]
    for k in 1...8 {
        let hx = -98 + Float(k - 1) * 28, hz: Float = -78
        m.slab("Hangar Floor", x: hx, y: 15.2, z: hz, w: 22, h: 0.1, d: 22, color: "#D6D3D1")
        m.slab("Hangar Wall", x: hx, y: 15.2, z: hz - 11, w: 22, h: 7, d: 0.5, color: "#94A3B8")
        m.slab("Hangar Wall", x: hx - 11, y: 15.2, z: hz, w: 0.5, h: 7, d: 22, color: "#94A3B8")
        m.slab("Hangar Wall", x: hx + 11, y: 15.2, z: hz, w: 0.5, h: 7, d: 22, color: "#94A3B8")
        m.slab("Hangar Roof", x: hx, y: 22.2, z: hz, w: 23, h: 0.5, d: 23, color: "#475569")
        m.pad("Build Pad \(k)", x: hx - 6, z: hz + 13, y: 15.2, size: 3, color: "#FACC15", tags: ["build", "k=\(k)"])
        m.part("Hangar Sign \(k)", at: (hx, 21.4, hz + 11.3), size: (8, 1, 0.2), color: "#FFFFFF", material: .neon, tags: ["sign", "k=\(k)"], solid: false)
        let y: Float = 15.3
        let pz = hz + 2
        m.group("pl\(k)_body", shown: false) {
            m.part("Fuselage", at: (hx, y + 1.1, pz), size: (1.6, 1.6, 7), color: tiers[0], solid: false)
            m.part("Cockpit", at: (hx, y + 2.0, pz + 1.5), size: (1.2, 0.6, 1.6), color: "#BAE6FD", material: .glass, solid: false)
        }
        m.group("pl\(k)_wings", shown: false) {
            m.part("Wing", at: (hx, y + 1.2, pz), size: (11, 0.25, 2.2), color: tiers[0], solid: false)
        }
        m.group("pl\(k)_engine", shown: false) {
            m.part("Nose", at: (hx, y + 1.1, pz + 3.8), size: (1.4, 0.8, 1.4), color: tiers[0], shape: .cylinder, solid: false, rotation: (90, 0, 0))
            m.part("Propeller", at: (hx, y + 1.1, pz + 4.3), size: (3.6, 0.3, 0.1), color: "#1F2937", solid: false)
        }
        m.group("pl\(k)_tank", shown: false) {
            m.part("Belly Tank", at: (hx, y + 0.2, pz), size: (0.9, 0.6, 3), color: tiers[0], solid: false)
        }
        m.group("pl\(k)_tail", shown: false) {
            m.part("Tail Fin", at: (hx, y + 2.3, pz - 3.2), size: (0.2, 1.8, 1.4), color: tiers[0], solid: false)
            m.part("Stabilizer", at: (hx, y + 1.3, pz - 3.2), size: (4, 0.2, 1.2), color: tiers[0], solid: false)
        }
        m.group("pl\(k)_boost", shown: false) {
            for sx in [-3, 3] as [Float] {
                m.part("Rocket", at: (hx + sx, y + 0.8, pz), size: (0.5, 2.4, 0.5), color: tiers[0], shape: .cylinder, material: .metal, solid: false,
                       rotation: (90, 0, 0))
            }
        }
    }
    // Rings in the sky: fly through for coins and a little more fuel.
    var r = Seeded("plane")
    for k in 0..<30 {
        let z = 140 + Float(k) * 118 + r.range(-20, 20)
        let x = r.range(-30, 30), y = r.range(18, 60)
        m.part("Sky Ring \(k + 1)", at: (x, y, z), size: (9, 0.6, 9), color: "#FACC15", shape: .cylinder, material: .neon, behavior: .trigger,
               tags: ["ring"], solid: false, rotation: (90, 0, 0), opacity: 0.55)
    }
    // Buoys every 250 m, so you can see how far you are.
    for k in 1...16 {
        let z = Float(k) * 250
        m.part("Buoy", at: (-12, 0.6, z), size: (1.2, 2, 1.2), color: k % 4 == 0 ? "#EF4444" : "#F8FAFC", shape: .cylinder, material: .neon, solid: false)
    }
    // The four islands.
    for (i, isl) in planeIslands.enumerated() {
        let size: Float = [80, 70, 60, 70][i]
        m.slab("Island \(i + 1) Land", x: isl.0, y: -4, z: isl.1, w: size, h: 6.5, d: size, color: "#FDE68A", material: .sand)
        m.slab("Island \(i + 1) Grass", x: isl.0, y: 2.5, z: isl.1, w: size - 16, h: 0.3, d: size - 16, color: "#4ADE80", material: .grass)
        m.part("Island \(i + 1)", at: (isl.0, 4, isl.1), size: (size, 2.4, size), color: "#FFFFFF", behavior: .trigger, tags: ["island", "n=\(i + 1)"],
               solid: false, visible: false)
        for q in 0..<6 {
            let a = Float(q) / 6 * 2 * .pi
            m.pine(isl.0 + cos(a) * size * 0.3, isl.1 + sin(a) * size * 0.3, y: 2.8, height: 6, leaves: "#15803D")
        }
        m.part("Island Flag Pole", at: (isl.0, 7.5, isl.1), size: (0.3, 9, 0.3), color: "#E5E7EB", solid: false)
        m.part("Island Flag \(i + 1)", at: (isl.0 + 1.4, 11, isl.1), size: (2.6, 1.6, 0.1), color: ["#EF4444", "#3B82F6", "#A855F7", "#FACC15"][i],
               material: .neon, solid: false)
    }
    // Clouds.
    for _ in 0..<40 {
        m.part("Cloud", at: (r.range(-200, 200), r.range(50, 95), r.range(-50, 4000)), size: (r.range(14, 30), r.range(3, 6), r.range(10, 22)),
               color: "#FFFFFF", material: .matte, solid: false, opacity: 0.85)
    }
    m.coverFocus(x: -42, y: 17, z: -76, yaw: 160, width: 50)
}

// MARK: 102 Island Flight School (Pilot Training Flight Simulator)

/// The four airports: island centre (x, z). Every runway runs along +z.
let flightAirports: [(Float, Float)] = [(0, 0), (520, 460), (-560, 620), (120, 1160)]

func islandFlightSchool(_ m: MapBuilder) {
    m.ocean()
    m.environment.skyStyle = .clouds
    m.ground(2200, 2200, color: "#C2B280", y: -4, z: 580, material: .sand)
    m.part("Sea", at: (0, -0.6, 580), size: (2200, 1, 2200), color: "#1D6FB8", material: .glass, behavior: .trigger, tags: ["sea"],
           solid: false, opacity: 0.85)
    let land = ["#86EFAC", "#FDE68A", "#F1F5F9", "#A8A29E"]
    for (i, a) in flightAirports.enumerated() {
        let k = i + 1
        let (cx, cz) = a
        m.slab("Island \(k)", x: cx, y: -4, z: cz, w: 130, h: 6, d: 280, color: land[i], material: i == 2 ? .ice : .grass)
        m.part("Runway \(k) Strip", at: (cx, 2.03, cz), size: (18, 0.06, 230), color: "#374151", material: .matte, solid: false)
        for q in 0..<14 { m.part("Runway Mark", at: (cx, 2.08, cz - 100 + Float(q) * 15.4), size: (0.6, 0.02, 6), color: "#F8FAFC", solid: false) }
        for q in 0..<2 {
            let ez = cz + (q == 0 ? -113 : 113)
            m.part("Runway Lights", at: (cx, 2.1, ez), size: (18, 0.1, 1), color: q == 0 ? "#22C55E" : "#EF4444", material: .neon, solid: false)
        }
        m.part("Runway \(k)", at: (cx, 4.5, cz), size: (22, 5, 236), color: "#FFFFFF", behavior: .trigger, tags: ["runway", "n=\(k)"],
               solid: false, visible: false)
        m.part("Runway Start \(k)", at: (cx, 2.6, cz - 104), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
        // Terminal, gate, tower.
        m.shop("Terminal \(k)", x: cx + 40, z: cz - 70, w: 24, d: 12, color: "#E0F2FE", sign: "#0284C7", facing: 1)
        m.pad("Gate \(k)", x: cx + 26, z: cz - 90, y: 2, size: 3.4, color: "#0EA5E9", tags: ["gate", "n=\(k)"])
        m.pad("Hangar Pad \(k)", x: cx + 34, z: cz - 90, y: 2, size: 3, color: "#F59E0B", tags: ["planes"])
        m.slab("Tower \(k)", x: cx + 44, y: 2, z: cz - 20, w: 3, h: 16, d: 3, color: "#F8FAFC")
        m.slab("Tower Cab \(k)", x: cx + 44, y: 18, z: cz - 20, w: 6, h: 3, d: 6, color: "#7DD3FC", material: .glass, opacity: 0.6)
        m.part("Tower Beacon", at: (cx + 44, 21.8, cz - 20), size: (1, 1, 1), color: "#22C55E", shape: .sphere, material: .neon, solid: false)
        m.part("Windsock", at: (cx - 14, 4, cz + 60), size: (0.8, 0.8, 2.4), color: "#F97316", shape: .cone, solid: false, rotation: (90, 0, 0))
        m.part("Airport Sign \(k)", at: (cx + 40, 9.5, cz - 63.6), size: (18, 1.4, 0.2), color: ["#22C55E", "#FACC15", "#38BDF8", "#EF4444"][i],
               material: .neon, solid: false)
    }
    var r = Seeded("flight")
    // Home island: fields and a flight school.
    m.spawnRing(26, -104, y: 2, radius: 4, count: 8, color: "#22C55E")
    m.shop("Flight School", x: 40, z: -104, w: 18, d: 10, color: "#DCFCE7", sign: "#16A34A", facing: 1)
    for _ in 0..<12 { m.tree(r.pick([r.range(-60, -20), r.range(20, 60)]), r.range(-40, 130), y: 2, height: r.range(4, 6)) }
    // Palm island.
    let (bx, bz) = flightAirports[1]
    for _ in 0..<14 { m.pine(bx + r.pick([r.range(-60, -16), r.range(16, 30)]), bz + r.range(-120, 120), y: 2, height: 6, leaves: "#65A30D") }
    // Snow island.
    let (sx, sz) = flightAirports[2]
    for _ in 0..<16 { m.pine(sx + r.pick([r.range(-60, -16), r.range(16, 30)]), sz + r.range(-120, 120), y: 2, height: 7, leaves: "#E2E8F0") }
    m.part("Snow Peak", at: (sx - 100, 30, sz + 60), size: (90, 60, 90), color: "#F8FAFC", shape: .cone, material: .matte, solid: false)
    // Volcano island.
    let (vx, vz) = flightAirports[3]
    m.part("Volcano", at: (vx - 120, 40, vz + 40), size: (120, 80, 120), color: "#57534E", shape: .cone, material: .stone, solid: false)
    m.part("Lava Glow", at: (vx - 120, 78, vz + 40), size: (16, 4, 16), color: "#F97316", shape: .cylinder, material: .neon, solid: false)
    // Clouds.
    for _ in 0..<50 {
        m.part("Cloud", at: (r.range(-800, 800), r.range(60, 140), r.range(-300, 1500)), size: (r.range(20, 50), r.range(4, 9), r.range(16, 36)),
               color: "#FFFFFF", material: .matte, solid: false, opacity: 0.85)
    }
    m.coverFocus(x: 20, y: 4, z: -80, yaw: 150, width: 60)
}
