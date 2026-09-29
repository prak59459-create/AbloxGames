import Foundation

// Games 96–110: driving and vehicles, each after a vehicle game popular on
// Roblox (docs/research-150.md). Most run on lib/kit_ride.absc, which
// handles the ride's look and speed, boosts, launches and flying.

let vehicleGames: [Game] = [
    Game(number: 110, id: "snow-plow-crew", title: "Snow Plow Crew",
         summary: "雪の町の除雪車チーム！ 道や駐車場の雪をかいて、お仕事の時間内にピカピカに。ふぶきが来たらまた出動。こおった道には🧂塩をまこう。ブレードやタンクを強くして、空港の滑走路まで！",
         tags: ["vehicles", "simulator", "winter"], maxPlayers: 8, libs: ["ride"], build: snowPlowCrew),
    Game(number: 109, id: "taxi-town", title: "Taxi Town",
         summary: "タクシーの運転手になって、大きな町でお客さんを運ぼう！ 🙋手をあげている人の前で止まって乗せ、目的地へ。はやく安全に着くとチップ。タクシー会社を大きくして、運転手をやとおう。",
         tags: ["cars", "roleplay", "tycoon"], maxPlayers: 12, libs: ["ride", "move"], build: taxiTown),
    Game(number: 108, id: "blast-off-rockets", title: "Blast Off Rockets",
         summary: "燃料をためて、ロケットを空へ発射！ 高く上がるほどお金が入る。雲をぬけて宇宙ステーション、そして2000m上の月へ。部品を強くして、月に着いたら生まれかわってもっと上へ！",
         tags: ["simulator", "space", "flying"], maxPlayers: 8, libs: ["ride", "move"], build: blastOffRockets),
    Game(number: 107, id: "grapple-cart-duo", title: "Grapple Cart Duo",
         summary: "カートでオビー！ すき間は🪝グラップルでびゅーん、ジャンプ台でひとっとび。ふたり組になると、落ちてもロープで引き上げてもらえる。ハンマーをよけて20ステージをゴールまで！",
         tags: ["obby", "cars", "coop"], maxPlayers: 10, libs: ["obby", "ride", "move"], build: grappleCartDuo),
    Game(number: 106, id: "lawn-mower-kings", title: "Lawn Mower Kings",
         summary: "芝かりでお金持ちに！ 草の上を走ると芝がかれてお金が入る。バッグがいっぱいになったら たい肥場へ。刃・エンジン・バッグを強くして、大きな庭やゴルフ場もピカピカに。金色の草はおたから！",
         tags: ["simulator", "vehicles", "idle"], maxPlayers: 8, libs: ["ride"], build: lawnMowerKings),
    Game(number: 105, id: "cabin-crew-service", title: "Cabin Crew Service",
         summary: "客室乗務員になって、みんなで空の旅をもりあげよう！ 搭乗・安全のデモ・離陸・機内サービス・着陸・おそうじ。お客さんの🔔にこたえて、ジュースやごはんを運ぼう。フライトの⭐をふやせ！",
         tags: ["roleplay", "flying", "teamwork"], maxPlayers: 10, build: cabinCrewService),
    Game(number: 104, id: "ice-cream-van", title: "Ice Cream Van",
         summary: "アイスクリームカーで町をまわろう！ 🔔チャイムを鳴らすとお客さんが集まってくる。注文どおりにコーン・味・トッピングを作ってわたそう。公園・ビーチ・学校・住宅街、アイスを仕入れて新しい味も。",
         tags: ["cars", "cooking", "shop"], maxPlayers: 8, libs: ["ride"], build: iceCreamVan),
    Game(number: 103, id: "county-line-railway", title: "County Line Railway",
         summary: "電車の運転士になろう！ ノッチで加速とブレーキ、信号を守って、6つの駅にぴったり止まる。ドアをあけてお客さんをのせ、時間どおりに次の駅へ。急行・特急にも乗れるようになる。",
         tags: ["trains", "simulator", "driving"], maxPlayers: 8, libs: ["ride", "move"], build: countyLineRailway),
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

// MARK: 103 County Line Railway (Stepford County Railway)

/// The line's corners, in the direction trains run.
let railCorners: [(Float, Float)] = [(-200, -120), (200, -120), (200, 120), (-200, 120)]

func countyLineRailway(_ m: MapBuilder) {
    m.day(ground: "#4D7C0F")
    m.environment.skyStyle = .clouds
    m.ground(520, 360, color: "#65A30D", material: .grass)
    let half: Float = 2.4
    for i in 0..<4 {
        let a = railCorners[i], b = railCorners[(i + 1) % 4]
        let alongX = abs(b.0 - a.0) > 0
        let length = alongX ? abs(b.0 - a.0) : abs(b.1 - a.1)
        let cx = (a.0 + b.0) / 2, cz = (a.1 + b.1) / 2
        m.part("Ballast", at: (cx, 0.03, cz), size: alongX ? (length + 2 * half, 0.06, 2 * half) : (2 * half, 0.06, length + 2 * half),
               color: "#78716C", material: .stone, solid: false)
        for off in [-0.75, 0.75] as [Float] {
            m.part("Rail", at: alongX ? (cx, 0.12, cz + off) : (cx + off, 0.12, cz), size: alongX ? (length + 2 * half, 0.1, 0.12) : (0.12, 0.1, length + 2 * half),
                   color: "#D1D5DB", material: .metal, solid: false)
        }
        // Walls either side keep the train on the line; the inner one stops short of the corners.
        for k in [-1, 1] as [Float] {
            let off = k * (half + 0.2)
            let inner = alongX ? (cz + off).magnitude < cz.magnitude : (cx + off).magnitude < cx.magnitude
            let wall = inner ? length - 2 * half - 0.8 : length + 2 * half + 0.8
            m.slab("Track Wall", x: alongX ? cx : cx + off, y: 0, z: alongX ? cz + off : cz, w: alongX ? wall : 0.4, h: 0.7, d: alongX ? 0.4 : wall,
                   color: "#A8A29E")
        }
        m.part("Corner \(i + 1)", at: (a.0, 0.8, a.1), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    }
    // Sleepers every 8 m, just for the look.
    for i in 0..<4 {
        let a = railCorners[i], b = railCorners[(i + 1) % 4]
        let length = abs(b.0 - a.0) + abs(b.1 - a.1)
        for q in 0..<Int(length / 8) {
            let t = (Float(q) + 0.5) * 8 / length
            let x = a.0 + (b.0 - a.0) * t, z = a.1 + (b.1 - a.1) * t
            m.part("Sleeper", at: (x, 0.07, z), size: abs(b.0 - a.0) > 0 ? (0.5, 0.06, 3.2) : (3.2, 0.06, 0.5), color: "#57534E", solid: false)
        }
    }
    // Six stations: platform outside the loop, a stop zone on the line, a signal before it.
    let stations: [(Float, Float, Float, Float)] = [(-100, -120, 0, -1), (100, -120, 0, -1), (200, 0, 1, 0), (100, 120, 0, 1), (-100, 120, 0, 1), (-200, 0, -1, 0)]
    let colors = ["#22C55E", "#0EA5E9", "#F59E0B", "#A855F7", "#EF4444", "#14B8A6"]
    for (i, st) in stations.enumerated() {
        let (x, z, ox, oz) = st
        let alongX = ox == 0
        let k = i + 1
        let px = x + ox * 5.4, pz = z + oz * 5.4
        m.slab("Platform \(k)", x: px, y: 0, z: pz, w: alongX ? 34 : 4, h: 1, d: alongX ? 4 : 34, color: "#D6D3D1")
        m.part("Platform Edge", at: (x + ox * 3.5, 1.02, z + oz * 3.5), size: alongX ? (34, 0.04, 0.3) : (0.3, 0.04, 34), color: "#FACC15", solid: false)
        m.slab("Canopy \(k)", x: px + ox * 0.5, y: 4, z: pz + oz * 0.5, w: alongX ? 24 : 4, h: 0.3, d: alongX ? 4 : 24, color: colors[i])
        for q in [-9, 9] as [Float] {
            m.slab("Canopy Post", x: alongX ? px + q : px + ox, y: 1, z: alongX ? pz + oz : pz + q, w: 0.3, h: 3, d: 0.3, color: "#57534E")
        }
        m.part("Station Sign \(k)", at: (px + ox * 1.6, 3.2, pz + oz * 1.6), size: alongX ? (5, 0.8, 0.15) : (0.15, 0.8, 5), color: colors[i], material: .neon,
               solid: false)
        m.part("Stop \(k)", at: (x, 1.5, z), size: alongX ? (10, 3, 4) : (4, 3, 10), color: "#FFFFFF", behavior: .trigger, tags: ["stop", "n=\(k)"],
               solid: false, visible: false)
        m.part("Stop Mark \(k)", at: alongX ? (x + 5, 1.6, z + oz * 3.8) : (x + ox * 3.8, 1.6, z + 5 * (oz == 0 ? 1 : 1)), size: (0.3, 1.2, 0.3), color: "#F8FAFC",
               material: .neon, solid: false)
        // Waiting spots for passengers.
        for q in 0..<4 {
            let w: Float = -9 + Float(q) * 6
            m.part("Wait \(k)-\(q + 1)", at: alongX ? (px + w, 1.1, pz) : (px, 1.1, pz + w), size: (0.6, 0.1, 0.6), color: "#000000", solid: false, visible: false)
        }
        // The station building, with steps up to the platform.
        let bx = x + ox * 14, bz = z + oz * 14
        m.slab("Station House \(k)", x: bx, y: 0, z: bz, w: alongX ? 12 : 8, h: 4, d: alongX ? 8 : 12, color: "#FEF3C7")
        m.slab("Station Roof", x: bx, y: 4, z: bz, w: alongX ? 13 : 9, h: 0.5, d: alongX ? 9 : 13, color: colors[i])
        for q in 0..<3 {
            let h = 0.33 * Float(q + 1)
            m.slab("Platform Step", x: alongX ? px - 19.5 + Float(q) : px, y: 0, z: alongX ? pz : pz - 19.5 + Float(q), w: alongX ? 1 : 3, h: h,
                   d: alongX ? 3 : 1, color: "#A8A29E")
        }
    }
    // Signals, 25 m before each station.
    let signalS: [Float] = [75, 275, 495, 715, 915, 1135]
    for (i, sv) in signalS.enumerated() {
        let (x, z, alongX) = railPoint(sv)
        let side: Float = 3.4
        let (mx, mz) = alongX ? (x, z + (z < 0 ? -side : side)) : (x + (x < 0 ? -side : side), z)
        m.part("Signal Mast", at: (mx, 2, mz), size: (0.3, 4, 0.3), color: "#1F2937", solid: false)
        m.part("Signal \(i + 1)", at: (mx, 4.2, mz), size: (0.8, 0.8, 0.8), color: "#22C55E", shape: .sphere, material: .neon, tags: ["signal", "n=\(i + 1)"],
               solid: false)
        m.part("Signal Line \(i + 1)", at: (x, 1.5, z), size: alongX ? (1, 3, 4.4) : (4.4, 3, 1), color: "#FFFFFF", behavior: .trigger,
               tags: ["sigline", "n=\(i + 1)"], solid: false, visible: false)
    }
    // The depot, where drivers start.
    m.slab("Depot Yard", x: -40, y: -0.02, z: -150, w: 60, h: 0.06, d: 26, color: "#A8A29E")
    m.spawnRing(-40, -150, radius: 4, count: 8, color: "#22C55E")
    m.shop("Depot", x: -40, z: -164, w: 18, d: 8, color: "#E2E8F0", sign: "#16A34A", facing: 1)
    m.pad("Depot Pad", x: -48, z: -142, size: 3.4, color: "#22C55E", tags: ["depot"])
    m.pad("Train Shop", x: -32, z: -142, size: 3.4, color: "#F59E0B", tags: ["trains"])
    // A resting train for the look, and the AI local train.
    m.slab("Old Train", x: -12, y: 0, z: -156, w: 14, h: 3, d: 3, color: "#B91C1C")
    m.movingHazard("Local Train", at: (-150, 1.6, -120), size: (10, 3, 3), color: "#0EA5E9", material: .metal, tags: ["local_train"])
    // Scenery: the harbour by みなと, hills, the zoo, the school, woods.
    var r = Seeded("railway")
    m.water(100, -160, w: 120, d: 30, name: "Harbour", color: "#2563EB", tags: ["scenery"])
    for q in 0..<3 { m.parkedCar("Boat", x: 70 + Float(q) * 25, z: -165, yaw: 90, color: "#F8FAFC") }
    m.part("Hill", at: (250, 8, 70), size: (40, 16, 80), color: "#4D7C0F", shape: .sphere, material: .grass, solid: false)
    for q in 0..<5 {
        m.slab("Zoo Pen", x: -140 + Float(q) * 16, y: 0, z: 150, w: 12, h: 1.2, d: 12, color: "#A16207", material: .wood)
        m.part("Zoo Animal", at: (-140 + Float(q) * 16, 1.8, 150), size: (2, 1.6, 3), color: ["#9CA3AF", "#FACC15", "#F97316", "#78716C", "#F8FAFC"][q],
               solid: false)
    }
    m.slab("School", x: 110, y: 0, z: 150, w: 30, h: 7, d: 14, color: "#FDE68A")
    m.slab("School Roof", x: 110, y: 7, z: 150, w: 32, h: 0.5, d: 16, color: "#B45309")
    for _ in 0..<60 {
        let x = r.range(-250, 250), z = r.range(-170, 170)
        if abs(abs(x) - 200) < 14 && abs(z) < 134 || abs(abs(z) - 120) < 14 && abs(x) < 214 { continue }
        if abs(x) < 170 && abs(z) < 90 && r.unit() < 0.5 { continue }
        if abs(z) > 136 && abs(x) < 150 { continue }
        m.tree(x, z, height: r.range(4, 7))
    }
    for q in 0..<6 {
        m.house("Town House", x: -60 + Float(q % 3) * 40, z: q < 3 ? -40 : 40, w: 9, d: 8, wall: r.pick(["#FEF3C7", "#E0F2FE", "#FCE7F3"]),
                roof: r.pick(["#B91C1C", "#1D4ED8", "#15803D"]), tags: ["house"], facing: q < 3 ? 1 : -1)
    }
    m.coverFocus(x: -100, y: 2, z: -120, yaw: 150, width: 50)
}

/// A point `s` metres along the line, and whether that stretch runs along x.
func railPoint(_ s: Float) -> (Float, Float, Bool) {
    var left = s
    for i in 0..<4 {
        let a = railCorners[i], b = railCorners[(i + 1) % 4]
        let length = abs(b.0 - a.0) + abs(b.1 - a.1)
        if left <= length {
            let t = left / length
            return (a.0 + (b.0 - a.0) * t, a.1 + (b.1 - a.1) * t, abs(b.0 - a.0) > 0)
        }
        left -= length
    }
    return (railCorners[0].0, railCorners[0].1, true)
}

// MARK: 104 Ice Cream Van (Ice Cream Van Simulator)

func iceCreamVan(_ m: MapBuilder) {
    m.day(ground: "#4D7C0F")
    m.environment.skyStyle = .clouds
    m.ground(380, 380, color: "#84CC16", material: .grass)
    // Roads: a ring and a cross.
    for v in [-110, 110] as [Float] {
        m.road(from: (-116, v), to: (116, v), width: 10, name: "Ring Road")
        m.road(from: (v, -116), to: (v, 116), width: 10, y: 0.025, name: "Ring Road")
    }
    m.road(from: (-160, 0), to: (116, 0), width: 10, name: "Main Street")
    m.road(from: (0, -116), to: (0, 116), width: 10, y: 0.025, name: "Main Street")
    // The factory, where vans restock and get better.
    m.slab("Factory Yard", x: -140, y: -0.02, z: 0, w: 40, h: 0.06, d: 50, color: "#E7E5E4")
    m.spawnRing(-140, 12, radius: 4, count: 8, color: "#F472B6")
    m.slab("Factory", x: -150, y: 0, z: -14, w: 18, h: 8, d: 14, color: "#FBCFE8")
    m.slab("Factory Roof", x: -150, y: 8, z: -14, w: 19, h: 0.5, d: 15, color: "#DB2777")
    m.part("Giant Cone", at: (-150, 11, -14), size: (3, 5, 3), color: "#D97706", shape: .cone, solid: false, rotation: (180, 0, 0))
    m.part("Giant Scoop", at: (-150, 14, -14), size: (3.6, 3.6, 3.6), color: "#F9A8D4", shape: .sphere, solid: false)
    m.pad("Restock Pad", x: -136, z: -6, size: 3.6, color: "#38BDF8", tags: ["restock"])
    m.pad("Garage Pad", x: -128, z: -6, size: 3.4, color: "#F59E0B", tags: ["upgrades"])
    for q in 0..<3 { m.parkedCar("Parked Van", x: -150 + Float(q) * 6, z: 18, yaw: 180, color: "#F9A8D4") }
    // Four neighbourhoods, each with places customers come from.
    let zones: [(String, Float, Float)] = [("park", -55, 55), ("beach", 55, 55), ("school", 55, -55), ("suburb", -55, -55)]
    var r = Seeded("icecream")
    for (i, z) in zones.enumerated() {
        let (kind, cx, cz) = z
        let k = i + 1
        m.part("Zone \(k)", at: (cx, 0.5, cz), size: (1, 1, 1), color: "#000000", tags: ["zone", "kind=\(kind)"], solid: false, visible: false)
        var spots: [(Float, Float)] = []
        switch kind {
        case "park":
            m.water(cx - 10, cz + 12, w: 22, d: 14, name: "Pond", color: "#38BDF8", tags: ["scenery"])
            for _ in 0..<12 { m.tree(cx + r.range(-44, 44), cz + r.range(-44, 44), height: r.range(4, 6)) }
            for q in 0..<4 { m.slab("Bench", x: cx - 30 + Float(q) * 18, y: 0, z: cz - 20, w: 3, h: 0.6, d: 1, color: "#92400E", material: .wood) }
            m.slab("Slide", x: cx + 22, y: 0, z: cz + 22, w: 2, h: 3, d: 6, color: "#EF4444")
            m.slab("Sandbox", x: cx + 30, y: 0, z: cz + 8, w: 8, h: 0.3, d: 8, color: "#FDE68A", material: .sand)
            spots = [(cx - 30, cz - 16), (cx - 12, cz - 16), (cx + 6, cz - 16), (cx + 22, cz + 16), (cx + 30, cz + 2), (cx - 30, cz + 30)]
        case "beach":
            m.slab("Sand", x: cx, y: -0.01, z: cz + 20, w: 96, h: 0.05, d: 60, color: "#FDE68A", material: .sand)
            m.water(cx, cz + 95, w: 120, d: 40, name: "Sea", color: "#0EA5E9", tags: ["scenery"])
            for q in 0..<5 {
                let ux = cx - 36 + Float(q) * 18
                m.part("Umbrella Pole", at: (ux, 1.3, cz + 30), size: (0.2, 2.6, 0.2), color: "#F8FAFC", solid: false)
                m.part("Umbrella", at: (ux, 2.7, cz + 30), size: (4, 1, 4), color: ["#EF4444", "#3B82F6", "#FACC15", "#22C55E", "#F472B6"][q], shape: .cone,
                       solid: false)
            }
            m.slab("Lifeguard Tower", x: cx + 40, y: 0, z: cz + 40, w: 3, h: 4, d: 3, color: "#F8FAFC")
            spots = [(cx - 36, cz + 26), (cx - 18, cz + 26), (cx, cz + 26), (cx + 18, cz + 26), (cx + 36, cz + 26), (cx - 20, cz + 6)]
        case "school":
            m.slab("School", x: cx, y: 0, z: cz - 16, w: 50, h: 9, d: 18, color: "#FDE68A")
            m.slab("School Roof", x: cx, y: 9, z: cz - 16, w: 52, h: 0.5, d: 20, color: "#B45309")
            m.slab("School Yard", x: cx, y: -0.01, z: cz + 16, w: 70, h: 0.05, d: 36, color: "#D97706")
            m.part("Goal", at: (cx + 28, 1.2, cz + 16), size: (0.3, 2.4, 6), color: "#F8FAFC", solid: false)
            m.part("Goal", at: (cx - 28, 1.2, cz + 16), size: (0.3, 2.4, 6), color: "#F8FAFC", solid: false)
            spots = [(cx - 20, cz - 5), (cx, cz - 5), (cx + 20, cz - 5), (cx - 10, cz + 20), (cx + 10, cz + 20), (cx + 30, cz + 30)]
        default:
            for q in 0..<6 {
                let hx = cx - 30 + Float(q % 3) * 30, hz = cz + (q < 3 ? -24 : 24)
                m.house("House", x: hx, z: hz, w: 10, d: 8, wall: r.pick(["#FEF3C7", "#E0F2FE", "#FCE7F3", "#DCFCE7"]), roof: r.pick(["#B91C1C", "#1D4ED8", "#15803D"]),
                        tags: ["house"], facing: q < 3 ? 1 : -1)
                spots.append((hx, hz + (q < 3 ? 7 : -7)))
            }
        }
        for (q, sp) in spots.enumerated() {
            m.part("Zone \(k) Spot \(q + 1)", at: (sp.0, 0.5, sp.1), size: (0.6, 0.2, 0.6), color: "#000000", solid: false, visible: false)
        }
        m.part("Zone Sign \(k)", at: (cx + (cx < 0 ? 42 : -42), 3, cz + (cz < 0 ? 42 : -42)), size: (0.3, 6, 0.3), color: "#F8FAFC", solid: false)
        m.part("Zone Flag \(k)", at: (cx + (cx < 0 ? 42 : -42), 5.4, cz + (cz < 0 ? 42.8 : -41.2)), size: (0.1, 1.2, 1.8),
               color: ["#22C55E", "#0EA5E9", "#F59E0B", "#A855F7"][i], material: .neon, solid: false)
    }
    for _ in 0..<30 {
        let x = r.range(-185, 185), z = r.range(-185, 185)
        if abs(x) < 125 && abs(z) < 125 || abs(z) < 30 && x < -110 { continue }
        m.tree(x, z, height: r.range(4, 7))
    }
    m.coverFocus(x: -30, y: 1, z: 40, yaw: 210, width: 60)
}

// MARK: 105 Cabin Crew Service (Cabin Crew Simulator)

func cabinCrewService(_ m: MapBuilder) {
    m.day(ground: "#6B7280")
    m.environment.skyStyle = .clouds
    // The cabin: floor, walls with windows, ceiling. The nose is at -z.
    let len: Float = 64, wide: Float = 7.6
    m.slab("Cabin Floor", x: 0, y: 0, z: 0, w: wide, h: 0.3, d: len, color: "#1E3A8A")
    m.part("Aisle Carpet", at: (0, 0.32, -2), size: (1.4, 0.02, 50), color: "#B91C1C", solid: false)
    for side in [-1, 1] as [Float] {
        let x = side * (wide / 2 + 0.2)
        // The left wall has the front door in it, from z -24 to -22.
        let doorA: Float = -24, doorB: Float = -22
        let pieces: [(Float, Float)] = side < 0 ? [(-len / 2, doorA), (doorB, len / 2)] : [(-len / 2, len / 2)]
        for (a, b) in pieces {
            let c = (a + b) / 2, d = b - a
            m.slab("Cabin Wall", x: x, y: 0.3, z: c, w: 0.4, h: 1.1, d: d, color: "#F1F5F9")
            m.slab("Cabin Wall", x: x, y: 2.1, z: c, w: 0.4, h: 1.2, d: d, color: "#F1F5F9")
            m.part("Window Strip", at: (x, 1.75, c), size: (0.3, 0.7, d), color: "#BAE6FD", material: .glass, opacity: 0.35)
        }
    }
    m.slab("Door Top", x: -(wide / 2 + 0.2), y: 2.9, z: -23, w: 0.4, h: 0.4, d: 2, color: "#F1F5F9")
    m.slab("Cabin Ceiling", x: 0, y: 3.3, z: 0, w: wide + 0.8, h: 0.3, d: len, color: "#E2E8F0")
    m.slab("Nose Wall", x: 0, y: 0.3, z: -len / 2, w: wide + 0.8, h: 3, d: 0.4, color: "#F1F5F9")
    m.slab("Tail Wall", x: 0, y: 0.3, z: len / 2, w: wide + 0.8, h: 3, d: 0.4, color: "#F1F5F9")
    for q in 0..<8 { m.part("Ceiling Light", at: (0, 3.25, -28 + Float(q) * 8), size: (1, 0.05, 3), color: "#FEF9C3", material: .neon, solid: false) }
    // The cockpit behind a door, and the front door where people board (left side).
    m.slab("Cockpit Wall", x: -2.2, y: 0.3, z: -27, w: 3.2, h: 3, d: 0.3, color: "#CBD5E1")
    m.slab("Cockpit Wall", x: 2.2, y: 0.3, z: -27, w: 3.2, h: 3, d: 0.3, color: "#CBD5E1")
    m.part("Cockpit Panel", at: (0, 1.2, -31), size: (5, 1, 0.6), color: "#111827", material: .metal, solid: false)
    m.part("Cockpit Screen", at: (0, 1.9, -31.2), size: (4.4, 0.6, 0.1), color: "#22D3EE", material: .neon, solid: false)
    m.pad("Captain Pad", x: 0, z: -29, y: 0.3, size: 2, color: "#FACC15", tags: ["captain"])
    m.group("door_closed", shown: false) {
        m.slab("Front Door", x: -(wide / 2 + 0.2), y: 0.3, z: -23, w: 0.5, h: 2.6, d: 2, color: "#CBD5E1")
    }
    // Seats: 12 rows, two by two, with a call light over each.
    var n = 0
    for row in 0..<12 {
        let z = -19 + Float(row) * 3
        for x in [-2.7, -1.6, 1.6, 2.7] as [Float] {
            n += 1
            m.part("Seat Base", at: (x, 0.55, z), size: (0.9, 0.5, 0.9), color: "#1D4ED8", solid: false)
            m.part("Seat Back", at: (x, 1.1, z + 0.45), size: (0.9, 1.3, 0.2), color: "#1D4ED8", solid: false)
            m.part("Seat \(n)", at: (x, 1, z), size: (1.3, 2, 1.4), color: "#FFFFFF", behavior: .trigger, tags: ["seat", "n=\(n)"], solid: false,
                   visible: false)
            m.part("Call \(n)", at: (x, 3.1, z), size: (0.4, 0.12, 0.4), color: "#475569", shape: .cylinder, material: .neon, tags: ["call", "n=\(n)"],
                   solid: false)
        }
    }
    // The galley at the back: drinks, food, blankets, the bin.
    m.slab("Galley Counter", x: 0, y: 0.3, z: 29.6, w: wide, h: 1.1, d: 1.4, color: "#94A3B8", material: .metal)
    let galley: [(String, Float, String)] = [("juice", -2.6, "#F97316"), ("coffee", -0.9, "#78350F"), ("meal", 0.9, "#22C55E"), ("blanket", 2.6, "#A855F7")]
    for g in galley {
        m.pad("Galley \(g.0)", x: g.1, z: 27.8, y: 0.3, size: 1.4, color: g.2, tags: ["galley", "item=\(g.0)"])
    }
    m.slab("Trash Bin", x: -3.2, y: 0.3, z: 24.5, w: 0.9, h: 1, d: 0.9, color: "#57534E")
    m.pad("Bin Pad", x: -2.3, z: 24.5, y: 0.3, size: 1.2, color: "#78716C", tags: ["bin"])
    // Crew spots: the safety demo in the aisle, jump seats by the doors.
    for (i, z) in [-14, 0, 14].enumerated() {
        m.pad("Demo Spot \(i + 1)", x: 0, z: Float(z), y: 0.3, size: 1.2, color: "#FACC15", tags: ["demo"])
    }
    for (i, p) in [(-2.8, -24.5), (2.8, -24.5), (-2.8, 22.5), (2.8, 22.5)].enumerated() {
        m.pad("Jump Seat \(i + 1)", x: Float(p.0), z: Float(p.1), y: 0.3, size: 1.3, color: "#38BDF8", tags: ["jump"])
    }
    m.spawnRing(0, 21, y: 0.3, radius: 1.2, count: 6, color: "#F472B6")
    m.part("Board Point", at: (0, 0.8, -23), size: (1, 0.2, 1), color: "#000000", solid: false, visible: false)
    // Outside at the airport: the terminal and a jet bridge (shown on the ground).
    m.group("airport", shown: true) {
        m.ground(260, 260, color: "#9CA3AF", material: .matte)
        m.slab("Jet Bridge", x: -12, y: 0, z: -23, w: 16, h: 3.2, d: 3, color: "#CBD5E1")
        m.slab("Terminal", x: -40, y: 0, z: -10, w: 30, h: 12, d: 60, color: "#E0F2FE")
        m.part("Terminal Glass", at: (-24.8, 6, -10), size: (0.2, 8, 56), color: "#7DD3FC", material: .glass, solid: false, opacity: 0.5)
        m.part("Tail Fin", at: (0, 6, 33), size: (0.4, 7, 5), color: "#1D4ED8", solid: false)
        m.part("Wing", at: (-12, 0.8, 4), size: (17, 0.4, 7), color: "#E2E8F0", solid: false)
        m.part("Wing", at: (12, 0.8, 4), size: (17, 0.4, 7), color: "#E2E8F0", solid: false)
        for q in 0..<6 { m.part("Apron Line", at: (20, 0.02, -30 + Float(q) * 12), size: (0.3, 0.02, 8), color: "#FACC15", solid: false) }
        m.parkedCar("Baggage Cart", x: 12, z: -10, yaw: 90, color: "#F59E0B")
        m.parkedCar("Fuel Truck", x: 14, z: 16, yaw: 0, color: "#DC2626")
    }
    // In the sky: clouds that stream past the windows (moved by the script).
    m.group("sky", shown: false) {
        var r = Seeded("cabin")
        for k in 0..<24 {
            let x = r.pick([r.range(-80, -12), r.range(12, 80)])
            m.part("Cloud \(k + 1)", at: (x, r.range(-25, 12), r.range(-150, 150)), size: (r.range(12, 26), r.range(3, 7), r.range(10, 20)),
                   color: "#FFFFFF", material: .matte, tags: ["cloud"], solid: false, opacity: 0.9)
        }
    }
    m.coverFocus(x: 0, y: 1.6, z: -6, yaw: 180, width: 12)
}

// MARK: 106 Lawn Mower Kings (Lawn Mowing Simulator)

/// The five lawns: centre (x, z), columns and rows of 4 m tiles.
let mowYards: [(Float, Float, Int, Int)] = [(-40, 0, 6, 6), (40, 0, 8, 8), (0, 56, 8, 10), (-66, 78, 10, 12), (66, 86, 12, 12)]

func lawnMowerKings(_ m: MapBuilder) {
    m.day(ground: "#A3A34A")
    m.environment.skyStyle = .clouds
    m.ground(260, 260, color: "#BEF264", z: 40, material: .grass)
    // The hub: shop, compost heap, and the path to every lawn.
    m.slab("Hub", x: 0, y: -0.02, z: -6, w: 30, h: 0.06, d: 22, color: "#D6D3D1")
    m.spawnRing(0, -4, radius: 3.5, count: 8, color: "#84CC16")
    m.shop("Mower Shop", x: -8, z: -20, w: 12, d: 7, color: "#FEF08A", sign: "#65A30D", facing: 1)
    m.pad("Shop Pad", x: -8, z: -12, size: 3.2, color: "#65A30D", tags: ["shop"])
    m.slab("Compost Heap", x: 10, y: 0, z: -20, w: 8, h: 2.2, d: 6, color: "#78350F")
    m.pad("Compost Pad", x: 10, z: -12, size: 3.2, color: "#A16207", tags: ["compost"])
    m.pad("Yards Pad", x: 0, z: -14, size: 3, color: "#0EA5E9", tags: ["yards"])
    for q in 0..<3 { m.parkedCar("Mower", x: -18 + Float(q) * 4, z: 2, yaw: 0, color: ["#16A34A", "#DC2626", "#FACC15"][q]) }
    let names = ["となりの庭", "公園", "学校の校庭", "サッカー場", "ゴルフ場"]
    for (k, y) in mowYards.enumerated() {
        let (cx, cz, cols, rows) = y
        let w = Float(cols) * 4, d = Float(rows) * 4
        m.road(from: (0, -6), to: (cx, cz - d / 2 - 3), width: 4, name: "Path", dashed: false, color: "#D6D3D1")
        m.slab("Lawn Soil \(k + 1)", x: cx, y: -0.01, z: cz, w: w, h: 0.05, d: d, color: "#65A30D")
        for c in 0..<cols {
            for r in 0..<rows {
                let x = cx - w / 2 + 2 + Float(c) * 4, z = cz - d / 2 + 2 + Float(r) * 4
                m.part("G \(k + 1)-\(c)-\(r)", at: (x, 0.35, z), size: (3.9, 0.6, 3.9), color: "#166534", material: .grass, tags: ["grass"], solid: false)
            }
        }
        // A low fence round each lawn, open on the path side.
        let x0 = cx - w / 2 - 0.6, x1 = cx + w / 2 + 0.6, z0 = cz - d / 2 - 0.6, z1 = cz + d / 2 + 0.6
        m.fence(from: (x0, z1), to: (x1, z1), color: "#F8FAFC")
        m.fence(from: (x0, z0), to: (x0, z1), color: "#F8FAFC")
        m.fence(from: (x1, z0), to: (x1, z1), color: "#F8FAFC")
        m.fence(from: (x0, z0), to: (cx - 3, z0), color: "#F8FAFC")
        m.fence(from: (cx + 3, z0), to: (x1, z0), color: "#F8FAFC")
        m.pad("Yard Sign \(k + 1)", x: cx + 5, z: z0 - 2.5, size: 2.4, color: ["#22C55E", "#0EA5E9", "#F59E0B", "#A855F7", "#EF4444"][k],
              tags: ["yard", "k=\(k + 1)"])
        m.part("Yard Name \(k + 1)", at: (cx + 5, 2.2, z0 - 3.8), size: (3.2, 1.2, 0.2), color: ["#22C55E", "#0EA5E9", "#F59E0B", "#A855F7", "#EF4444"][k],
               material: .neon, solid: false)
        _ = names[k]
    }
    // Things around each lawn that fit it.
    m.house("Neighbour", x: -40, z: -26, w: 10, d: 8, wall: "#FDE68A", roof: "#B91C1C", tags: ["house"], facing: 1)
    for q in 0..<4 { m.tree(40 + Float(q) * 8 - 12, 21, height: 5) }
    m.slab("School", x: 0, y: 0, z: 84, w: 30, h: 8, d: 10, color: "#FDE68A")
    for gz in [54, 102] as [Float] { m.part("Goal", at: (-66, 1.2, gz), size: (6, 2.4, 0.3), color: "#F8FAFC", solid: false) }
    m.part("Flag Pole", at: (70, 2, 90), size: (0.15, 4, 0.15), color: "#F8FAFC", solid: false)
    m.part("Golf Flag", at: (70.6, 3.6, 90), size: (1.2, 0.8, 0.05), color: "#EF4444", material: .neon, solid: false)
    m.part("Golf Hole", at: (70, 0.7, 90), size: (0.6, 0.05, 0.6), color: "#111827", shape: .cylinder, solid: false)
    var r = Seeded("mow")
    for _ in 0..<40 {
        let x = r.range(-125, 125), z = r.range(-85, 165)
        let near = mowYards.contains { abs($0.0 - x) < Float($0.2) * 2 + 8 && abs($0.1 - z) < Float($0.3) * 2 + 8 }
        if near || abs(x) < 22 && z < 10 { continue }
        m.tree(x, z, height: r.range(4, 7))
    }
    m.coverFocus(x: -40, y: 1, z: 0, yaw: 150, width: 34)
}

// MARK: 107 Grapple Cart Duo (Grapple Cart Obby)

func grappleCartDuo(_ m: MapBuilder) {
    m.sky("#7DD3FC", "#F0F9FF", light: 0.75, showGround: false, fall: -20)
    m.environment.skyStyle = .clouds
    let y: Float = 12
    // The start: a big platform with the duo pads.
    m.step("Start Deck", x: 0, y: y, z: -14, w: 30, d: 24, h: 1, color: "#E2E8F0")
    m.spawnRing(0, -18, y: y, radius: 3.5, count: 8, color: "#F472B6")
    m.pad("Duo A", x: -6, z: -8, y: y, size: 2.6, color: "#F472B6", tags: ["duo", "side=a"])
    m.pad("Duo B", x: 6, z: -8, y: y, size: 2.6, color: "#38BDF8", tags: ["duo", "side=b"])
    m.part("Duo Arch", at: (0, y + 4, -8), size: (14, 0.6, 0.6), color: "#FACC15", material: .neon, solid: false)
    let zoneColors = ["#22C55E", "#0EA5E9", "#F59E0B", "#A855F7", "#EF4444"]
    var z: Float = 0
    var anchors = 0, jumps = 0
    for n in 1...20 {
        let zone = (n - 1) / 4
        let color = zoneColors[zone]
        let w: Float = [9, 8, 7, 6, 5][zone]
        let walls = zone < 3
        m.stagePad(n, x: 0, y: y + 0.05, z: z + 2, size: w, color: color)
        // Every stage: a run of track, then one gimmick.
        func track(_ from: Float, _ to: Float, x: Float = 0) {
            m.step("Track", x: x, y: y, z: (from + to) / 2, w: w, d: to - from, h: 0.6, color: "#475569")
            if walls {
                for sx in [-1, 1] as [Float] {
                    m.part("Track Rail", at: (x + sx * (w / 2 + 0.2), y + 0.3, (from + to) / 2), size: (0.4, 0.6, to - from), color: color)
                }
            }
        }
        track(z + 4, z + 18)
        let kind = (n - 1) % 5
        switch kind {
        case 0:
            // A boost pad on a long straight.
            m.pad("Boost", x: 0, z: z + 12, y: y, size: 3, color: "#FACC15", tags: ["boost"])
            track(z + 18, z + 30)
            z += 30
        case 1, 3:
            // A gap only the grapple crosses.
            anchors += 1
            let gap: Float = 10 + Float(zone) * 2.5
            m.part("Anchor Post", at: (0, y + 4, z + 18 + gap / 2), size: (0.4, 8, 0.4), color: "#94A3B8", solid: false)
            m.part("Anchor \(anchors)", at: (0, y + 8.5, z + 18 + gap / 2), size: (1.6, 1.6, 1.6), color: "#F472B6", shape: .sphere, material: .neon,
                   tags: ["anchor", "k=\(anchors)"], solid: false)
            m.part("Land \(anchors)", at: (0, y + 0.5, z + 18 + gap + 3), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
            if kind == 3 {
                // With hammers after the landing.
                track(z + 18 + gap, z + 18 + gap + 16)
                for q in 0..<2 {
                    m.movingHazard("Hammer", at: (-w / 2 + 0.8, y + 1, z + 18 + gap + 6 + Float(q) * 6), size: (1.4, 2, 1.4), color: "#DC2626",
                                   material: .metal, tags: ["hammer", "dx=\(Int(w - 1.6))", "secs=\(q == 0 ? 1.4 : 1.1)"])
                }
                z += 18 + gap + 16
            } else {
                track(z + 18 + gap, z + 18 + gap + 8)
                z += 18 + gap + 8
            }
        case 2:
            // A jump pad over a wider gap.
            jumps += 1
            let gap: Float = 12 + Float(zone) * 3
            m.pad("Jump \(jumps)", x: 0, z: z + 17, y: y, size: w - 1, color: "#22D3EE", tags: ["jumppad", "k=\(jumps)"])
            m.part("Jump Land \(jumps)", at: (0, y + 0.5, z + 18 + gap + 3), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
            track(z + 18 + gap, z + 18 + gap + 10)
            z += 18 + gap + 10
        default:
            // A zigzag: turn left, turn right, with no rails later on.
            track(z + 18, z + 24, x: 0)
            m.step("Zig", x: w, y: y, z: z + 27, w: w * 3, d: 6, h: 0.6, color: "#64748B")
            track(z + 30, z + 42, x: w * 1.5)
            m.step("Zag", x: w * 0.75, y: y, z: z + 45, w: w * 2.5, d: 6, h: 0.6, color: "#64748B")
            track(z + 48, z + 56)
            z += 56
        }
    }
    m.step("Finish Deck", x: 0, y: y, z: z + 8, w: 20, d: 16, h: 1, color: "#FEF3C7")
    m.finishLine(x: 0, y: y + 0.05, z: z + 8, size: 8)
    // Clouds under the course.
    var r = Seeded("cartduo")
    for _ in 0..<40 {
        m.part("Cloud", at: (r.range(-60, 60), r.range(-6, 4), r.range(-40, z + 40)), size: (r.range(10, 24), r.range(2, 4), r.range(8, 18)),
               color: "#FFFFFF", material: .matte, solid: false, opacity: 0.9)
    }
    m.coverFocus(x: 0, y: y + 2, z: 40, yaw: 200, width: 40)
}

// MARK: 108 Blast Off Rockets (Blast Off Simulator)

func blastOffRockets(_ m: MapBuilder) {
    m.day(ground: "#65A30D")
    m.environment.skyStyle = .clouds
    m.ground(200, 200, color: "#84CC16", material: .grass)
    m.slab("Base", x: 0, y: -0.02, z: 0, w: 80, h: 0.06, d: 80, color: "#D6D3D1")
    m.spawnRing(0, 0, radius: 4, count: 8, color: "#F97316")
    m.shop("Rocket Lab", x: 0, z: -16, w: 16, d: 8, color: "#E0F2FE", sign: "#2563EB", facing: 1)
    m.pad("Lab Pad", x: -4, z: -9, size: 3, color: "#2563EB", tags: ["lab"])
    m.pad("Pump Pad", x: 4, z: -9, size: 3, color: "#F97316", tags: ["pump"])
    m.slab("Fuel Tank", x: 12, y: 0, z: -14, w: 4, h: 6, d: 4, color: "#F97316")
    // Eight launch pads in a ring, each with a tower and a rocket that grows as you build it.
    for k in 1...8 {
        let a = Float(k - 1) / 8 * 2 * .pi + .pi / 8
        let px = cos(a) * 30, pz = sin(a) * 30
        m.slab("Launch Base", x: px, y: 0, z: pz, w: 8, h: 0.4, d: 8, color: "#6B7280")
        m.pad("Launch Pad \(k)", x: px, z: pz, y: 0.4, size: 3.2, color: "#EF4444", tags: ["launch", "k=\(k)"])
        m.slab("Tower", x: px + 4.5, y: 0.4, z: pz, w: 1, h: 14, d: 1, color: "#9CA3AF", material: .metal)
        let rx = px, rz = pz + 5.5, y: Float = 0.4
        m.group("rk\(k)_body", shown: false) {
            m.part("Rocket Body", at: (rx, y + 4, rz), size: (1.8, 6, 1.8), color: "#F8FAFC", shape: .cylinder, solid: false)
        }
        m.group("rk\(k)_engine", shown: false) {
            m.part("Rocket Engine", at: (rx, y + 0.6, rz), size: (1.4, 1.2, 1.4), color: "#374151", shape: .cone, material: .metal, solid: false)
        }
        m.group("rk\(k)_tank", shown: false) {
            m.part("Rocket Tank", at: (rx, y + 8.2, rz), size: (1.9, 2.4, 1.9), color: "#F97316", shape: .cylinder, solid: false)
        }
        m.group("rk\(k)_boost", shown: false) {
            for sx in [-1.3, 1.3] as [Float] {
                m.part("Booster", at: (rx + sx, y + 2.5, rz), size: (0.7, 4, 0.7), color: "#EF4444", shape: .cylinder, solid: false)
            }
        }
        m.group("rk\(k)_nose", shown: false) {
            m.part("Rocket Nose", at: (rx, y + 10.6, rz), size: (1.8, 2.4, 1.8), color: "#DC2626", shape: .cone, solid: false)
        }
        m.group("rk\(k)_fins", shown: false) {
            m.part("Fin", at: (rx, y + 1.5, rz), size: (3.4, 1.4, 0.2), color: "#2563EB", solid: false)
            m.part("Fin", at: (rx, y + 1.5, rz), size: (0.2, 1.4, 3.4), color: "#2563EB", solid: false)
        }
        m.part("Pad Sign \(k)", at: (px + 4.5, 14.8, pz), size: (1.4, 1.4, 1.4), color: "#FFFFFF", shape: .sphere, material: .neon, tags: ["sign", "k=\(k)"],
               solid: false)
    }
    // Fuel crystals round the base.
    var r = Seeded("rockets")
    for q in 0..<16 {
        let a = Float(q) / 16 * 2 * .pi
        let d: Float = q % 2 == 0 ? 48 : 18
        m.part("Crystal", at: (cos(a) * d, 0.9, sin(a) * d), size: (0.9, 1.6, 0.9), color: "#22D3EE", shape: .cone, material: .neon, behavior: .trigger,
               tags: ["crystal"])
    }
    for _ in 0..<24 {
        let x = r.range(-95, 95), z = r.range(-95, 95)
        if abs(x) < 52 && abs(z) < 52 { continue }
        m.tree(x, z, height: r.range(4, 7))
    }
    // The sky above: a cloud layer, the space station, the moon.
    for _ in 0..<30 {
        m.part("High Cloud", at: (r.range(-120, 120), r.range(110, 180), r.range(-120, 120)), size: (r.range(16, 34), r.range(3, 6), r.range(12, 26)),
               color: "#FFFFFF", material: .matte, solid: false, opacity: 0.8)
    }
    for q in 0..<8 {
        let a = Float(q) / 8 * 2 * .pi
        m.part("Station Ring", at: (cos(a) * 70, 1000, sin(a) * 70), size: (26, 3, 3), color: "#CBD5E1", material: .metal, solid: false,
               rotation: (0, -Float(q) * 45 + 90, 0))
    }
    m.part("Station Panels", at: (0, 1000, 96), size: (40, 0.3, 10), color: "#1D4ED8", material: .glass, solid: false)
    m.part("Moon", at: (0, 2060, 0), size: (110, 110, 110), color: "#E5E7EB", shape: .sphere, material: .stone, solid: false)
    m.part("Moon Gate", at: (0, 2002, 0), size: (100, 6, 100), color: "#FFFFFF", behavior: .trigger, tags: ["moon"], solid: false, visible: false)
    for q in 0..<5 {
        m.part("Crater", at: (r.range(-40, 40), r.range(2020, 2100), r.range(-56, -50)), size: (10, 10, 2), color: "#9CA3AF", shape: .cylinder, solid: false,
               rotation: (90, 0, 0))
        _ = q
    }
    m.coverFocus(x: 20, y: 6, z: 20, yaw: 210, width: 40)
}

// MARK: 109 Taxi Town (Taxi Boss)

let taxiLines: [Float] = [-120, -60, 0, 60, 120]

func taxiTown(_ m: MapBuilder) {
    m.sky("#60A5FA", "#E0F2FE", light: 0.7, ground: "#475569")
    m.environment.skyStyle = .clouds
    m.ground(320, 320, color: "#64748B", material: .matte)
    for v in taxiLines {
        m.road(from: (-126, v), to: (126, v), width: 12, name: "Street")
        m.road(from: (v, -126), to: (v, 126), width: 12, y: 0.025, name: "Avenue")
    }
    // The sixteen blocks: twelve places to go, the taxi company, a park and offices.
    let places: [(String, String, Float, Float, Float)] = [
        ("🏨 ホテル", "#FDE68A", -90, -90, 30), ("🏥 病院", "#F8FAFC", -30, -90, 18), ("🏟 スタジアム", "#94A3B8", 30, -90, 14), ("🛍 デパート", "#F9A8D4", 90, -90, 24),
        ("🎡 遊園地", "#FB923C", -90, -30, 8), ("🚉 駅", "#A5B4FC", 30, -30, 12), ("🏢 会社", "#CBD5E1", 90, -30, 40),
        ("🏫 学校", "#FEF08A", -90, 30, 12), ("🏛 美術館", "#E7E5E4", -30, 30, 14), ("🍣 レストラン", "#FCA5A5", 90, 30, 10),
        ("🎬 映画館", "#C4B5FD", -90, 90, 16), ("✈️ 空港バス", "#7DD3FC", -30, 90, 8)
    ]
    for (i, pl) in places.enumerated() {
        let (_, color, bx, bz, h) = pl
        m.slab("Place Building \(i + 1)", x: bx, y: 0, z: bz + 4, w: 36, h: h, d: 30, color: color)
        m.part("Place Sign \(i + 1)", at: (bx, h + 2, bz - 11.2), size: (14, 2.4, 0.3), color: color, material: .neon, solid: false)
        for q in 0..<Int(h / 6) {
            m.part("Windows", at: (bx, 3 + Float(q) * 6, bz - 11.1), size: (30, 1.6, 0.1), color: "#BAE6FD", material: .glass, solid: false, opacity: 0.6)
        }
        m.pad("Place \(i + 1)", x: bx, z: bz - 20, size: 4, color: "#FACC15", tags: ["place", "n=\(i + 1)"])
    }
    // The taxi company.
    m.slab("Taxi HQ", x: -30, y: 0, z: -26, w: 30, h: 10, d: 22, color: "#FACC15")
    m.part("HQ Sign", at: (-30, 12, -37.2), size: (16, 3, 0.3), color: "#111827", material: .neon, solid: false)
    m.slab("HQ Lot", x: -30, y: -0.02, z: -44, w: 36, h: 0.06, d: 10, color: "#334155")
    m.spawnRing(-30, -45, radius: 3.5, count: 8, color: "#FACC15")
    m.pad("HQ Pad", x: -38, z: -46, size: 3.4, color: "#F59E0B", tags: ["hq"])
    m.pad("Garage Pad", x: -22, z: -46, size: 3.4, color: "#22C55E", tags: ["garage"])
    for q in 0..<4 { m.parkedCar("HQ Taxi", x: -42 + Float(q) * 5, z: -18, yaw: 180, color: "#FACC15") }
    // The park and the office towers.
    m.slab("Park", x: 30, y: -0.01, z: 30, w: 44, h: 0.05, d: 44, color: "#4ADE80", material: .grass)
    m.water(30, 30, w: 14, d: 10, name: "Park Pond", color: "#38BDF8", tags: ["scenery"])
    var r = Seeded("taxi")
    for _ in 0..<10 { m.tree(30 + r.pick([r.range(-20, -9), r.range(9, 20)]), 30 + r.range(-20, 20), height: r.range(4, 6)) }
    for (bx, bz) in [(30, 90), (90, 90)] as [(Float, Float)] {
        for q in 0..<2 {
            let h = r.range(30, 60)
            m.slab("Tower", x: bx - 9 + Float(q) * 18, y: 0, z: bz, w: 14, h: h, d: 26, color: r.pick(["#475569", "#1E293B", "#334155"]))
            m.part("Tower Lights", at: (bx - 9 + Float(q) * 18, h / 2, bz - 13.1), size: (10, h * 0.8, 0.1), color: "#7DD3FC", material: .glass,
                   solid: false, opacity: 0.45)
        }
    }
    // Where people wave for a taxi: the corners of each block.
    var k = 0
    for bx in [-90, -30, 30, 90] as [Float] {
        for bz in [-90, -30, 30, 90] as [Float] {
            k += 1
            m.part("Hail \(k)", at: (bx + 20, 0.5, bz + 21), size: (0.6, 0.2, 0.6), color: "#000000", solid: false, visible: false)
        }
    }
    // Traffic on the outer streets, and the company's own taxis (shown when drivers are hired).
    let loop: [(Float, Float)] = [(-120, -120), (120, -120), (120, 120), (-120, 120)]
    for (i, c) in loop.enumerated() {
        m.part("Loop \(i + 1)", at: (c.0, 0.9, c.1), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    }
    for i in 0..<6 {
        let c = loop[i % 4]
        m.movingHazard("Traffic \(i + 1)", at: (c.0, 0.9, c.1), size: (2.2, 1.6, 2.2), color: r.pick(["#E5E7EB", "#1D4ED8", "#B91C1C", "#0F766E"]),
                       material: .metal, tags: ["traffic", "lane=\(i % 2 == 0 ? 1 : -1)", "start=\(i % 4 + 1)"])
    }
    for i in 0..<6 {
        m.movingHazard("Company Taxi \(i + 1)", at: (-60, 0.9, -60 + Float(i) * 20), size: (2.2, 1.6, 2.2), color: "#FACC15", material: .metal,
                       tags: ["company_taxi"])
    }
    for _ in 0..<12 {
        let line = r.pick(taxiLines), along = r.range(-110, 110)
        if taxiLines.contains(where: { abs($0 - along) < 12 }) { continue }
        m.parkedCar("Parked", x: along, z: line + 8, yaw: 90, color: r.pick(["#64748B", "#F8FAFC", "#1E3A8A", "#991B1B"]))
    }
    m.coverFocus(x: 18, y: 2, z: 18, yaw: 225, width: 50)
}

// MARK: 110 Snow Plow Crew (Snow Plow Simulator)

/// The five places to clear: centre (x, z), columns (along x) and rows (along z) of 6 m tiles.
let plowZones: [(Float, Float, Int, Int)] = [(0, -40, 20, 2), (0, 30, 2, 20), (0, 96, 20, 2), (72, 24, 6, 6), (-92, 30, 3, 20)]

func snowPlowCrew(_ m: MapBuilder) {
    m.sky("#94A3B8", "#E2E8F0", light: 0.6, ground: "#F1F5F9")
    m.environment.skyStyle = .clouds
    m.environment.weather = .snow
    m.ground(280, 280, color: "#F8FAFC", z: 30, material: .ice)
    // The roads under the snow.
    m.road(from: (-66, -40), to: (66, -40), width: 12, name: "Road", color: "#334155")
    m.road(from: (0, -40), to: (0, 96), width: 12, y: 0.025, name: "Road", color: "#334155")
    m.road(from: (-66, 96), to: (66, 96), width: 12, name: "Road", color: "#334155")
    m.slab("Parking Lot", x: 72, y: -0.01, z: 24, w: 36, h: 0.05, d: 36, color: "#334155")
    m.road(from: (6, 24), to: (54, 24), width: 10, name: "Road", color: "#334155")
    m.slab("Runway", x: -92, y: -0.01, z: 30, w: 18, h: 0.05, d: 120, color: "#1E293B")
    m.road(from: (-66, -40), to: (-92, -32), width: 10, name: "Road", color: "#334155")
    for q in 0..<10 { m.part("Runway Mark", at: (-92, 0.05, -24 + Float(q) * 12), size: (0.6, 0.02, 5), color: "#F8FAFC", solid: false) }
    // Snow on every tile.
    for (k, zn) in plowZones.enumerated() {
        let (cx, cz, cols, rows) = zn
        let w = Float(cols) * 6, d = Float(rows) * 6
        for c in 0..<cols {
            for r in 0..<rows {
                let x = cx - w / 2 + 3 + Float(c) * 6, z = cz - d / 2 + 3 + Float(r) * 6
                m.part("S \(k + 1)-\(c)-\(r)", at: (x, 0.35, z), size: (5.9, 0.6, 5.9), color: "#FFFFFF", material: .matte, tags: ["snow"], solid: false)
            }
        }
    }
    // The depot: salt, the snow dump, the garage, the job board.
    m.slab("Depot Yard", x: -40, y: -0.02, z: -80, w: 60, h: 0.06, d: 34, color: "#475569")
    m.spawnRing(-40, -78, radius: 4, count: 8, color: "#F97316")
    m.shop("Plow Garage", x: -52, z: -92, w: 16, d: 8, color: "#FDBA74", sign: "#EA580C", facing: 1)
    m.pad("Garage Pad", x: -52, z: -84, size: 3.4, color: "#F97316", tags: ["garage"])
    m.pad("Jobs Pad", x: -40, z: -84, size: 3.4, color: "#0EA5E9", tags: ["jobs"])
    m.slab("Salt Dome", x: -24, y: 0, z: -92, w: 10, h: 5, d: 8, color: "#E2E8F0")
    m.pad("Salt Pad", x: -24, z: -84, size: 3.4, color: "#38BDF8", tags: ["salt"])
    m.slab("Snow Dump", x: -8, y: 0, z: -96, w: 12, h: 3, d: 10, color: "#F8FAFC", material: .ice)
    m.pad("Dump Pad", x: -8, z: -86, size: 3.4, color: "#A16207", tags: ["dump"])
    m.road(from: (-40, -63), to: (-40, -46), width: 10, name: "Depot Road", color: "#334155")
    // The town round the roads.
    var r = Seeded("plow")
    for q in 0..<6 {
        let x = -50 + Float(q) * 20
        m.house("House", x: x, z: -58, w: 10, d: 8, wall: r.pick(["#FEF3C7", "#E0F2FE", "#FCE7F3"]), roof: "#F8FAFC", tags: ["house"], facing: 1)
        m.house("House", x: x, z: -22, w: 10, d: 8, wall: r.pick(["#FEF3C7", "#E0F2FE", "#FCE7F3"]), roof: "#F8FAFC", tags: ["house"], facing: -1)
    }
    m.slab("School", x: 0, y: 0, z: 116, w: 50, h: 9, d: 16, color: "#FDE68A")
    m.slab("School Roof", x: 0, y: 9, z: 116, w: 52, h: 0.5, d: 18, color: "#F8FAFC")
    m.shop("Supermarket", x: 72, z: 50, w: 30, d: 12, color: "#BBF7D0", sign: "#16A34A", facing: -1)
    m.slab("Hospital", x: 30, y: 0, z: 60, w: 20, h: 12, d: 20, color: "#F8FAFC")
    m.part("Hospital Cross", at: (30, 13, 49.8), size: (4, 4, 0.2), color: "#EF4444", material: .neon, solid: false)
    m.slab("Control Tower", x: -112, y: 0, z: 40, w: 4, h: 18, d: 4, color: "#CBD5E1")
    m.slab("Tower Cab", x: -112, y: 18, z: 40, w: 7, h: 3, d: 7, color: "#7DD3FC", material: .glass, opacity: 0.6)
    for _ in 0..<50 {
        let x = r.range(-135, 135), z = r.range(-105, 165)
        let busy = plowZones.contains { abs($0.0 - x) < Float($0.2) * 3 + 8 && abs($0.1 - z) < Float($0.3) * 3 + 8 }
        if busy || abs(x + 40) < 34 && abs(z + 80) < 22 || abs(z + 58) < 10 && abs(x) < 70 || abs(z + 22) < 10 && abs(x) < 70 { continue }
        m.pine(x, z, height: r.range(5, 8), leaves: "#F1F5F9")
    }
    m.coverFocus(x: 0, y: 1, z: -40, yaw: 160, width: 50)
}
