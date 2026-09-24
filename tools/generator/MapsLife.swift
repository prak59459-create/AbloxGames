import Foundation

// 33–45: roleplay, life and simulation.

let lifeGames: [Game] = [
    Game(number: 33, id: "pom-town", title: "Pom Town",
         summary: "家を家具でかざって★5のおうちに。タマゴからかえる15種類のポムをお世話して伝説まで育てよう。釣り・配達・水やりでスターを集めて、パーティーとおうちコンテスト！",
         tags: ["rp", "house", "pets"], maxPlayers: 12, build: pomTown),
    Game(number: 34, id: "cherry-lane-rp", title: "Cherry Lane RP",
         summary: "学校と家族とお仕事のロールプレイ。チャイムで授業（クイズ・音楽・体育）に出て通知表で進級・卒業。家族をつくって赤ちゃんのお世話、カフェ店員や美容師でお給料、服と乗り物も。",
         tags: ["rp", "school", "family"], maxPlayers: 16, build: cherryLane),
    Game(number: 35, id: "pizza-shift", title: "Pizza Shift",
         summary: "ピザ屋でみんなで働こう。レジで注文、レシピどおりに具をのせて、こげる前にオーブンから出して手わたし・配達！ ★評価と店のお金で店を強化、昇進で給料アップ。",
         tags: ["jobs", "coop", "classic"], maxPlayers: 12, build: pizzaShift),
    Game(number: 36, id: "neo-city-life", title: "Neo City Life",
         summary: "未来都市のRP。6つの仕事（修理・救助・逮捕・料理・空の配達・ハッキング）でかせぎ、乗り物を集めて空の家をスマートホームに。指名手配と刑務所、ドローンレース、ネオンナイトも。",
         tags: ["rp", "city", "future"], maxPlayers: 16, build: neoCity),
    Game(number: 37, id: "club-hangout", title: "Club Hangout",
         summary: "空き地に20種類のパーツで家を建て、家族といっしょに作ろう。クラブではDJがジャンルを選び、リズムに合わせておどってコインを。家の見学といいね、ハウスツアーも。",
         tags: ["rp", "social", "build"], maxPlayers: 16, build: clubHangout),
    Game(number: 38, id: "ridgeport-cops", title: "Ridgeport Cops & Robbers",
         summary: "警察と強盗の街アクション。ガソスタ・宝石店・銀行の暗証番号・銃砲店・現金輸送車をねらう強盗と、テーザーと手錠で追う警察。階級・武器・車・脱獄・保釈も！",
         tags: ["cops", "robbers", "teams"], maxPlayers: 16, build: ridgeport),
    Game(number: 39, id: "dinner-rush-tycoon", title: "Dinner Rush Tycoon",
         summary: "レストランを経営。19の設備で6品のメニューを増やし、シェフとウェイターをやとって自動化。評判と料理評論家、2号店（リバース）で永久ボーナス！",
         tags: ["tycoon", "cooking", "business"], maxPlayers: 8, build: dinnerRush),
    Game(number: 40, id: "coaster-park-tycoon", title: "Coaster Park Tycoon",
         summary: "遊園地を作ろう。14のアトラクションと屋台、お客さんの楽しさ・空腹・のど・トイレ、入場料、故障の修理とゴミそうじ、スタッフ、ベストパーク賞。自分でも乗れる！",
         tags: ["tycoon", "theme-park", "build"], maxPlayers: 8, build: coasterPark),
    Game(number: 41, id: "life-ville", title: "Life Ville",
         summary: "5つのゲージと気分を整えながらくらすライフシム。オフィス・キッチン・公園・ジムの4つの仕事と昇進、料理・体力・創作・頭脳のスキル、家具のグレードアップ、お祭りも。",
         tags: ["life", "sim", "needs"], maxPlayers: 12, build: lifeVille),
    Game(number: 42, id: "metro-response", title: "Metro Response",
         summary: "警察・消防・救急・市民・犯罪者に分かれる街のRP。出動指令を受けて、火事を消し（水タンクと消火栓）、けが人を病院へ、犯人を手錠で確保。倒れた仲間の蘇生、タクシー、金庫やぶりも。",
         tags: ["rp", "emergency", "teams"], maxPlayers: 16, build: metroResponse),
    Game(number: 43, id: "academy-days", title: "Academy Days",
         summary: "4つの寮に分かれる学園生活。チャイムで6つの教室へ（算数・美術・音楽・体育・ポーション学・図書館）。宿題と部活で寮ポイント、寮杯と生徒会選挙も！",
         tags: ["school", "rp", "minigames"], maxPlayers: 16, build: academyDays),
    Game(number: 44, id: "willow-hospital", title: "Willow Hospital RP",
         summary: "病院のお仕事RP。医者・看護師・外科医・薬剤師・救急隊・患者に。トリアージ、バイタル、12の病気の診断、薬の調合、手術、救急車の出動。病院の資金でベッドや設備を強化！",
         tags: ["rp", "hospital", "jobs"], maxPlayers: 12, build: willowHospital),
    Game(number: 45, id: "street-drive-empire", title: "Street Drive Empire",
         summary: "車を集めて街を走るドライブゲーム。16台の車を買って色とパーツをカスタム。4つのレース（サーキット・ドラッグ・市街地・ラリー）でライバルと勝負、配達とタクシーでかせいでライセンスを上げよう！",
         tags: ["cars", "driving", "collect"], maxPlayers: 12, build: streetDrive),
]

// MARK: Shared town pieces

/// A row of claimable houses with plots of garden in front: "Home N Floor",
/// "Home N Door" and "Home N Sign" (a pad to claim it).
func homesRow(_ m: MapBuilder, count: Int, x: Float, z: Float, spacing: Float, facing: Float, first: Int = 1,
              walls: [String] = ["#FDE2E4", "#E0F2FE", "#FEF9C3", "#DCFCE7", "#EDE9FE", "#FFE4E6"]) {
    for i in 0..<count {
        let n = first + i
        let hx = x + Float(i) * spacing
        m.house("Home \(n)", x: hx, z: z, w: 12, d: 10, h: 3.8, wall: walls[n % walls.count], roof: "#9F1239", floor: "#D6B98C",
                tags: ["home", "h\(n)"], facing: facing)
        m.pad("Home \(n) Sign", x: hx + 5, z: z + facing * 8, size: 1.6, color: "#FDE047", tags: ["claim"])
    }
}

// MARK: 33 Pom Town

func pomTown(_ m: MapBuilder) {
    m.day(ground: "#86EFAC")
    m.ground(180, 180, color: "#A3E635")
    m.part("Plaza", at: (0, 0.03, 0), size: (24, 0.06, 24), color: "#FDE68A", shape: .cylinder, material: .matte)
    m.spawnRing(0, 0, radius: 6, count: 8, color: "#F9A8D4")
    m.part("Plaza Fountain", at: (0, 0.5, 0), size: (3, 1, 3), color: "#7DD3FC", shape: .cylinder, material: .glass)
    m.road(from: (-90, 18), to: (90, 18), width: 6)
    homesRow(m, count: 6, x: -60, z: 36, spacing: 24, facing: -1)
    homesRow(m, count: 6, x: -60, z: -40, spacing: 24, facing: 1, first: 7)
    m.shop("Furniture Store", x: -30, z: 0, w: 12, d: 8, color: "#F472B6", sign: "#FFFFFF", facing: -1)
    m.pad("Furniture Counter", x: -30, z: 2, size: 2.4, color: "#EC4899", tags: ["furniture"])
    m.shop("Pom Shop", x: 30, z: 0, w: 12, d: 8, color: "#A78BFA", sign: "#FFFFFF", facing: -1)
    m.pad("Pom Counter", x: 30, z: 2, size: 2.4, color: "#8B5CF6", tags: ["pomshop"])
    // Places that meet a pom's needs.
    m.pad("Food Bowl", x: 24, z: -8, size: 2, color: "#F97316", tags: ["need_food"])
    m.pad("Pom Bed", x: 36, z: -8, size: 2.4, color: "#818CF8", tags: ["need_sleep"])
    m.slab("Pom Park", x: -30, y: 0, z: -20, w: 18, h: 0.1, d: 9, color: "#4ADE80")
    m.pad("Play Spot", x: -30, z: -20, y: 0.1, size: 3, color: "#FACC15", tags: ["need_play"])
    for p in [(-38, -23), (-22, -17)] { m.tree(Float(p.0), Float(p.1), height: 4, leaves: "#22C55E") }
    m.part("Pom Bath", at: (58, 0.4, -2), size: (4, 0.8, 3), color: "#E0F2FE", shape: .cylinder, material: .glass)
    m.pad("Bath Water", x: 58, z: -2, y: 0.8, size: 2.6, color: "#38BDF8", tags: ["need_bath"])
    // The post office (deliveries) and the flower beds (gardening).
    m.shop("Post Office", x: -62, z: 2, w: 10, d: 8, color: "#FB923C", sign: "#FFFFFF", facing: 1)
    m.pad("Parcel Counter", x: -62, z: 0, size: 2.4, color: "#F59E0B", tags: ["parcel"])
    m.pad("Garden Shed", x: 14, z: -14, size: 2.2, color: "#65A30D", tags: ["garden"])
    for (i, p) in ring(8, radius: 16, phase: 0.2).enumerated() {
        m.slab("Flower Bed \(i + 1)", x: p.0, y: 0, z: p.1, w: 3, h: 0.3, d: 1.6, color: "#78350F")
    }
    // The fishing pond.
    m.part("Pond", at: (70, 0.02, -8), size: (22, 0.05, 16), color: "#38BDF8", shape: .cylinder, material: .glass, solid: false)
    m.slab("Pond Dock", x: 70, y: 0, z: 2, w: 3, h: 0.3, d: 6, color: "#A16207")
    m.pad("Fishing Spot", x: 70, z: -1, y: 0.3, size: 1.6, color: "#0EA5E9", tags: ["fish"])
    for p in ring(10, radius: 80) { m.tree(p.0, p.1, height: 5, leaves: "#4ADE80") }
}

// MARK: 34 Cherry Lane RP

func cherryLane(_ m: MapBuilder) {
    m.day(ground: "#BBF7D0")
    m.ground(200, 200, color: "#D9F99D")
    m.road(from: (-100, 0), to: (100, 0), width: 8)
    m.road(from: (0, -100), to: (0, 100), width: 8)
    m.spawnRing(8, 8, radius: 4, count: 8, color: "#FBCFE8")
    homesRow(m, count: 5, x: -80, z: 26, spacing: 18, facing: -1, walls: ["#FCE7F3", "#E0E7FF", "#FEF3C7", "#F5F5F4", "#ECFCCB"])
    homesRow(m, count: 5, x: 16, z: -26, spacing: 18, facing: 1, first: 6)
    // The school: three classrooms along the back wall and a doorway at the front.
    m.slab("School Floor", x: 50, y: 0, z: 50, w: 44, h: 0.2, d: 26, color: "#E5E7EB")
    m.slab("School Wall", x: 50, y: 0.2, z: 63, w: 45, h: 5, d: 1, color: "#F59E0B")
    m.slab("School Wall", x: 28, y: 0.2, z: 50, w: 1, h: 5, d: 26, color: "#F59E0B")
    m.slab("School Wall", x: 72, y: 0.2, z: 50, w: 1, h: 5, d: 26, color: "#F59E0B")
    m.slab("School Wall", x: 38, y: 0.2, z: 37, w: 21, h: 5, d: 1, color: "#F59E0B")
    m.slab("School Wall", x: 62, y: 0.2, z: 37, w: 21, h: 5, d: 1, color: "#F59E0B")
    m.slab("School Wall", x: 50, y: 3.2, z: 37, w: 4, h: 2, d: 1, color: "#F59E0B")
    m.slab("School Roof", x: 50, y: 5.2, z: 50, w: 45, h: 0.4, d: 27, color: "#B45309")
    m.part("School Clock", at: (50, 4.4, 36.4), size: (1.6, 1.6, 0.2), color: "#FFFFFF", shape: .cylinder, rotation: (90, 0, 0))
    for (i, name) in ["Class Math", "Class Art", "Class Music"].enumerated() {
        let cx = 36 + Float(i) * 14
        m.pad(name, x: cx, z: 52, y: 0.2, size: 6, color: ["#60A5FA", "#F472B6", "#A78BFA"][i], tags: ["class"], shape: .box)
        m.slab("\(name) Board", x: cx, y: 1, z: 62.4, w: 8, h: 2.5, d: 0.2, color: "#14532D")
    }
    m.pad("Homeroom", x: 50, z: 42, y: 0.2, size: 5, color: "#FDE68A", tags: ["class"], shape: .box)
    // The science lab and the sports field.
    m.house("Science Lab", x: 88, z: 50, w: 12, d: 10, h: 4, wall: "#E0F2FE", roof: "#0369A1", floor: "#F1F5F9", tags: ["lab"], facing: -1)
    m.pad("Class Science", x: 88, z: 52, size: 5, color: "#22D3EE", tags: ["class"], shape: .box)
    m.slab("Sports Field", x: 50, y: 0, z: 84, w: 40, h: 0.1, d: 18, color: "#16A34A")
    m.pad("Class PE", x: 50, z: 84, y: 0.1, size: 5, color: "#FACC15", tags: ["class"], shape: .box)
    m.markers("Lap", points: [(34, 78), (66, 78), (66, 90), (34, 90)], y: 0.1, color: "#F97316", tags: ["lap"], size: 2.4)
    // Shops and places for jobs.
    m.shop("Boutique", x: -50, z: -50, w: 12, d: 10, color: "#F9A8D4", sign: "#FFFFFF")
    m.pad("Wardrobe", x: -50, z: -48, size: 2.4, color: "#EC4899", tags: ["wardrobe"])
    m.markers("Salon Seat", points: [(-54, -46), (-46, -46)], color: "#000000", visible: false, behavior: .none)
    m.shop("Cafe", x: -20, z: -50, w: 10, d: 8, color: "#D97706", sign: "#FEF3C7")
    m.pad("Cafe Counter", x: -20, z: -48, size: 2.4, color: "#F59E0B", tags: ["cafe"])
    m.markers("Cafe Seat", points: [(-23, -41), (-20, -40), (-17, -41)], color: "#000000", visible: false, behavior: .none)
    m.pad("Car Lot", x: -80, z: -14, size: 3, color: "#0EA5E9", tags: ["carlot"])
    m.slab("Nursery", x: -70, y: 0, z: 60, w: 12, h: 0.1, d: 10, color: "#FBCFE8")
    m.pad("Nursery Mat", x: -70, z: 60, y: 0.1, size: 3, color: "#F9A8D4", tags: ["nursery"])
    m.part("Nursery Slide", at: (-66, 1, 62), size: (1.2, 2, 4), color: "#38BDF8", rotation: (30, 0, 0))
    for p in ring(16, radius: 90) where !(abs(p.0 - 50) < 26 && abs(p.1 - 84) < 14) {
        m.tree(p.0, p.1, height: 5, leaves: "#F9A8D4")
    }
}

// MARK: 35 Pizza Shift

func pizzaShift(_ m: MapBuilder) {
    m.day(ground: "#65A30D")
    m.ground(160, 160, color: "#84CC16")
    m.road(from: (-80, 20), to: (80, 20), width: 8)
    // The restaurant: kitchen at the back, the counter in the middle, a
    // dining room at the front and a doorway on the right of the front wall.
    m.slab("Pizza Floor", x: 0, y: 0, z: -5.5, w: 30, h: 0.2, d: 27, color: "#FEF3C7")
    m.slab("Pizza Wall", x: 0, y: 0.2, z: -19, w: 31, h: 4.5, d: 1, color: "#DC2626")
    m.slab("Pizza Wall", x: -15, y: 0.2, z: -5.5, w: 1, h: 4.5, d: 27, color: "#DC2626")
    m.slab("Pizza Wall", x: 15, y: 0.2, z: -5.5, w: 1, h: 4.5, d: 27, color: "#DC2626")
    m.slab("Pizza Wall", x: -4.5, y: 0.2, z: 8, w: 21, h: 4.5, d: 1, color: "#DC2626")
    m.slab("Pizza Wall", x: 12.5, y: 0.2, z: 8, w: 5, h: 4.5, d: 1, color: "#DC2626")
    m.slab("Pizza Wall", x: 8, y: 3, z: 8, w: 4, h: 1.7, d: 1, color: "#DC2626")
    m.slab("Pizza Roof", x: 0, y: 4.7, z: -5.5, w: 31, h: 0.4, d: 28, color: "#7F1D1D")
    m.part("Pizza Sign", at: (0, 5.6, 8.4), size: (10, 1.2, 0.3), color: "#FDE047", material: .neon, solid: false)
    m.part("Window", at: (-6, 2.2, 8.52), size: (6, 1.6, 0.05), color: "#9ED8FF", material: .glass, solid: false)
    m.spawnRing(0, 15, radius: 3.5, count: 8, color: "#FCA5A5")
    // Stations.
    let stations: [(String, Float, Float, String, String)] = [
        ("Register", -8, 0, "#22C55E", "register"), ("Dough Table", -10, -12, "#FDE68A", "dough"),
        ("Sauce Station", -5, -12, "#EF4444", "sauce"), ("Cheese Station", 0, -12, "#FACC15", "cheese"),
        ("Topping Station", 5, -12, "#16A34A", "topping"), ("Oven", 10, -12, "#F97316", "oven"),
        ("Box Station", 10, -4, "#A16207", "box"), ("Supply Shelf", -12, -17, "#64748B", "shelf")
    ]
    for s in stations {
        m.slab("\(s.0) Counter", x: s.1, y: 0.2, z: s.2 - 1.2, w: 3, h: 1, d: 1.2, color: "#9CA3AF")
        m.pad(s.0, x: s.1, z: s.2, y: 0.2, size: 2, color: s.3, tags: ["station", s.4])
    }
    m.slab("Customer Counter", x: -8, y: 0.2, z: 1.8, w: 5, h: 1.1, d: 0.8, color: "#B91C1C")
    m.part("Customer Spot", at: (-8, 0.5, 5), size: (1, 0.1, 1), color: "#FFFFFF", visible: false)
    m.pad("Manager Office", x: 12, z: -17, y: 0.2, size: 2, color: "#7C3AED", tags: ["station", "office"])
    m.pad("Break Room", x: 3, z: -17, y: 0.2, size: 2, color: "#0EA5E9", tags: ["station", "locker"])
    // The dining room.
    for (i, x) in [Float(1), 6, 11].enumerated() {
        m.slab("Dining Table \(i + 1)", x: x, y: 0.2, z: 3, w: 2, h: 0.9, d: 2, color: "#FFFFFF")
    }
    m.markers("Seat", points: [(1, 5), (6, 5), (11, 5), (1, 0.8), (11, 0.8)], y: 0.2, color: "#000000", visible: false, behavior: .none)
    // The supply truck out back.
    m.slab("Supply Truck", x: -30, y: 0, z: -14, w: 4, h: 3, d: 8, color: "#FFFFFF")
    m.pad("Truck Unload", x: -26, z: -14, size: 2.4, color: "#0EA5E9", tags: ["station", "truck"])
    m.pad("Scooter Rack", x: 20, z: 12, size: 2.4, color: "#F43F5E", tags: ["station", "scooter"])
    // Houses to deliver to.
    for i in 0..<6 {
        let x = -60 + Float(i) * 24
        m.house("House \(i + 1)", x: x, z: 40, w: 10, d: 9, h: 3.4, wall: ["#FEF9C3", "#DBEAFE", "#FCE7F3"][i % 3], roof: "#57534E",
                floor: "#D6D3D1", tags: ["delivery"], facing: -1)
    }
}

// MARK: 36 Neo City Life

func neoCity(_ m: MapBuilder) {
    m.sky("#0F172A", "#7C3AED", light: 0.7, ground: "#111827")
    m.ground(220, 220, color: "#1F2937", name: "Neo Street")
    for i in -2...2 {
        m.part("Neon Line \(i + 3)", at: (Float(i) * 40, 0.03, 0), size: (1, 0.04, 220), color: "#22D3EE", material: .neon, solid: false)
        m.part("Neon Cross \(i + 3)", at: (0, 0.03, Float(i) * 40), size: (220, 0.04, 1), color: "#F472B6", material: .neon, solid: false)
    }
    m.spawnRing(0, 0, radius: 6, count: 8, color: "#A78BFA")
    // Places the scripts use, kept clear of the towers.
    let keepClear: [(Float, Float)] = [(30, 30), (-30, 30), (30, -30), (-30, -30), (60, 0), (-60, 0), (0, 60), (0, -60), (-70, -70),
                                       (70, 70), (-70, 70), (70, -70), (40, 80), (-40, -80)]
    var r = Seeded("neo")
    var towers = 0
    for _ in 0..<40 where towers < 18 {
        let x = r.range(-95, 95), z = r.range(-95, 95)
        let h = r.range(12, 50)
        let body = r.pick(["#1E293B", "#312E81", "#0F766E"])
        let glow = r.pick(["#22D3EE", "#F472B6", "#A3E635"])
        if abs(x) < 15 && abs(z) < 15 { continue }
        if keepClear.contains(where: { abs($0.0 - x) < 13 && abs($0.1 - z) < 13 }) { continue }
        // Sky homes sit on a ring of radius 70 at 30 m: keep towers out from under them.
        if abs(hypot(x, z) - 70) < 12 { continue }
        towers += 1
        m.slab("Tower \(towers)", x: x, y: 0, z: z, w: 10, h: h, d: 10, color: body, material: .metal)
        m.part("Tower \(towers) Glow", at: (x, h + 0.2, z), size: (10.2, 0.4, 10.2), color: glow, material: .neon)
    }
    let jobs: [(String, Float, Float, String)] = [("Job Engineer", 30, 30, "#22D3EE"), ("Job Medic", -30, 30, "#F87171"),
                                                ("Job Officer", 30, -30, "#60A5FA"), ("Job Chef", -30, -30, "#FBBF24"),
                                                ("Job Pilot", 60, 0, "#A78BFA"), ("Job Hacker", 0, -60, "#A3E635")]
    for j in jobs {
        m.slab("\(j.0) Base", x: j.1, y: 0, z: j.2, w: 8, h: 0.3, d: 8, color: "#334155")
        m.pad(j.0, x: j.1, z: j.2, y: 0.3, size: 5, color: j.3, tags: ["job"])
    }
    m.pad("Vehicle Bay", x: -60, z: 0, size: 6, color: "#F97316", tags: ["vehicle"])
    m.pad("Neo Kitchen", x: -36, z: -24, size: 2.4, color: "#F59E0B", tags: ["kitchen"])
    m.pad("Race Start", x: 0, z: 60, size: 5, color: "#E879F9", tags: ["race"])
    m.pad("Phone Shop", x: 36, z: 24, size: 2.4, color: "#38BDF8", tags: ["phone"])
    // Machines that break (engineers), street spots (medics, hackers' ATMs).
    for (i, p) in [(20, 0), (-20, 0), (0, 20), (0, -20), (45, 45), (-45, 45), (45, -45), (-45, -45)].enumerated() {
        m.part("Machine \(i + 1)", at: (Float(p.0), 1, Float(p.1)), size: (1.6, 2, 1.6), color: "#475569", material: .metal, tags: ["machine"])
    }
    for (i, p) in [(70, 70), (-70, 70), (70, -70), (-40, -80)].enumerated() {
        m.part("ATM \(i + 1)", at: (Float(p.0), 1.1, Float(p.1)), size: (1.2, 2.2, 0.8), color: "#16A34A", material: .neon, tags: ["atm"])
    }
    m.markers("Street Spot", points: ring(10, radius: 50, phase: 0.3), color: "#000000", visible: false, behavior: .none)
    // The jail, where officers send wanted hackers.
    m.slab("Jail Floor", x: -70, y: 0, z: -70, w: 14, h: 0.2, d: 14, color: "#111827")
    m.walls(-70, -70, w: 14, d: 14, h: 5, y: 0.2, color: "#64748B", thickness: 0.4, name: "Jail Wall", opacity: 0.6)
    m.markers("Jail Cell", points: [(-70, -70)], y: 0.2, color: "#F87171", visible: true, size: 2, behavior: .none)
    m.markers("Jail Exit", points: [(-60, -60)], color: "#000000", visible: false, behavior: .none)
    // Sky homes, reached by the lift pads; a down pad inside each brings you back.
    for i in 0..<6 {
        let a = Float(i) / 6 * 2 * .pi
        let x = cos(a) * 70, z = sin(a) * 70
        m.slab("Sky Home \(i + 1) Floor", x: x, y: 30, z: z, w: 12, h: 0.4, d: 12, color: "#E0E7FF", material: .glass, tags: ["skyhome"])
        m.walls(x, z, w: 12, d: 12, h: 3, y: 30.4, color: "#A5B4FC", thickness: 0.2, name: "Sky Home \(i + 1) Wall", opacity: 0.5)
        m.pad("Sky Home \(i + 1) Lift", x: x * 0.8, z: z * 0.8, size: 2.4, color: "#E879F9", tags: ["lift"])
        m.pad("Sky Home \(i + 1) Down", x: x + 4, z: z + 4, y: 30.4, size: 1.6, color: "#E879F9", tags: ["down"])
    }
}

// MARK: 37 Club Hangout

func clubHangout(_ m: MapBuilder) {
    m.sunset(ground: "#A3A3A3")
    m.ground(180, 180, color: "#A8A29E", name: "Town")
    m.spawnRing(0, 0, radius: 6, count: 8, color: "#FDE68A")
    // Empty lots where families build.
    for i in 0..<8 {
        let a = Float(i) / 8 * 2 * .pi
        let x = cos(a) * 55, z = sin(a) * 55
        m.slab("Lot \(i + 1)", x: x, y: 0, z: z, w: 20, h: 0.2, d: 20, color: "#65A30D", tags: ["lot"])
        m.pad("Lot \(i + 1) Sign", x: x * 0.78, z: z * 0.78, size: 2, color: "#FDE047", tags: ["claim"])
    }
    // The club, with a doorway in the south wall facing the plaza.
    m.slab("Club Floor", x: 0, y: 0, z: -20, w: 26, h: 0.3, d: 18, color: "#111827")
    m.slab("Club Wall", x: 0, y: 0.3, z: -29, w: 27, h: 6, d: 1, color: "#4C1D95")
    m.slab("Club Wall", x: -13, y: 0.3, z: -20, w: 1, h: 6, d: 18, color: "#4C1D95")
    m.slab("Club Wall", x: 13, y: 0.3, z: -20, w: 1, h: 6, d: 18, color: "#4C1D95")
    m.slab("Club Wall", x: -7.75, y: 0.3, z: -11, w: 11.5, h: 6, d: 1, color: "#4C1D95")
    m.slab("Club Wall", x: 7.75, y: 0.3, z: -11, w: 11.5, h: 6, d: 1, color: "#4C1D95")
    m.slab("Club Wall", x: 0, y: 3.3, z: -11, w: 4, h: 3, d: 1, color: "#4C1D95")
    m.part("Club Sign", at: (0, 5.4, -10.4), size: (8, 1, 0.2), color: "#F472B6", material: .neon, solid: false)
    m.slab("Club Roof", x: 0, y: 6.3, z: -20, w: 27, h: 0.3, d: 19, color: "#1E1B4B")
    for (i, p) in grid(4, 3, spacing: 4, cx: 0, cz: -20).enumerated() {
        m.part("Dance Tile \(i + 1)", at: (p.0, 0.32, p.1), size: (3.8, 0.05, 3.8), color: "#EC4899", material: .neon, tags: ["tile"], solid: false)
    }
    m.part("Disco Ball", at: (0, 5.2, -20), size: (1.4, 1.4, 1.4), color: "#E5E7EB", shape: .sphere, material: .metal)
    m.slab("DJ Stage", x: 0, y: 0.3, z: -27, w: 8, h: 0.4, d: 3, color: "#312E81")
    m.pad("DJ Booth", x: 0, z: -27, y: 0.7, size: 2.4, color: "#22D3EE", tags: ["dj"])
    m.pad("Juice Bar", x: 10, z: -14, y: 0.3, size: 2.2, color: "#F59E0B", tags: ["bar"])
    m.slab("Bar Counter", x: 10, y: 0.3, z: -16, w: 4, h: 1.1, d: 0.8, color: "#78350F")
    m.shop("Home Store", x: 30, z: -10, w: 12, d: 8, color: "#0EA5E9", sign: "#FFFFFF")
    m.pad("Home Store Counter", x: 30, z: -8, size: 2.4, color: "#38BDF8", tags: ["store"])
}

// MARK: 38 Ridgeport Cops & Robbers

func ridgeport(_ m: MapBuilder) {
    m.day(ground: "#57534E")
    m.ground(200, 200, color: "#78716C", name: "Ridgeport")
    m.road(from: (-100, 0), to: (100, 0), width: 10)
    m.road(from: (0, -100), to: (0, 100), width: 10)
    m.road(from: (-100, 50), to: (100, 50), width: 8, name: "Hill Road")
    // Police station, its garage and the jail.
    m.shop("Police HQ", x: -40, z: -30, w: 18, d: 12, color: "#1E3A8A", sign: "#93C5FD")
    m.spawnRing(-40, -30, radius: 3, count: 6, name: "Police Spawn", color: "#60A5FA")
    m.pad("Police Garage", x: -28, z: -18, size: 3, color: "#2563EB", tags: ["garage", "police"])
    m.pad("Police Armory", x: -46, z: -32, size: 2, color: "#93C5FD", tags: ["armory"])
    m.slab("Jail Floor", x: -70, y: 0, z: -30, w: 14, h: 0.3, d: 14, color: "#44403C")
    m.walls(-70, -30, w: 14, d: 14, h: 5, y: 0.3, color: "#A1A1AA", name: "Jail Bars", opacity: 0.6)
    m.part("Jail Cell", at: (-70, 1, -30), size: (1, 0.1, 1), color: "#000000", visible: false)
    m.pad("Jail Exit", x: -60, z: -30, size: 2, color: "#FDE047", tags: ["exit"])
    // Criminal hideout, its garage and the black market.
    m.shop("Hideout", x: 60, z: 70, w: 14, d: 10, color: "#3F3F46", sign: "#F87171")
    m.spawnRing(60, 70, radius: 3, count: 6, name: "Criminal Spawn", color: "#F87171")
    m.pad("Hideout Stash", x: 60, z: 68, size: 2.4, color: "#22C55E", tags: ["stash"])
    m.pad("Criminal Garage", x: 76, z: 80, size: 3, color: "#DC2626", tags: ["garage", "criminal"])
    m.pad("Black Market", x: 54, z: 72, size: 2, color: "#FCA5A5", tags: ["armory"])
    // Places to rob.
    let targets: [(String, Float, Float, String)] = [("Gas Station", 40, -30, "#F97316"), ("Jewelry Store", -40, 30, "#EC4899"),
                                                    ("Bank", 40, 30, "#EAB308"), ("Gun Shop", -80, 70, "#57534E")]
    for t in targets {
        m.shop(t.0, x: t.1, z: t.2, w: 14, d: 10, color: t.3, sign: "#FFFFFF")
    }
    m.pad("Gas Station Safe", x: 40, z: -32, size: 2.4, color: "#FACC15", tags: ["safe"])
    m.pad("Bank Safe", x: 40, z: 28, size: 2.4, color: "#FACC15", tags: ["safe"])
    m.pad("Gun Shop Safe", x: -80, z: 68, size: 2.4, color: "#FACC15", tags: ["safe"])
    for (i, p) in [(-44, 28), (-40, 27), (-36, 28), (-43, 31), (-37, 31)].enumerated() {
        m.pad("Jewel \(i + 1)", x: Float(p.0), z: Float(p.1), size: 1.4, color: "#F0ABFC", tags: ["jewel"])
    }
    // The armoured truck drives the main road now and then.
    m.markers("Truck Route", points: [(-92, -3), (92, -3)], color: "#000000", visible: false, behavior: .none)
    m.pad("Team Police", x: -8, z: 8, size: 3, color: "#3B82F6", tags: ["team"])
    m.pad("Team Criminal", x: 8, z: 8, size: 3, color: "#EF4444", tags: ["team"])
    m.spawnRing(0, 14, radius: 3, count: 6, color: "#E5E7EB")
    for i in 0..<10 { m.lamp(-90 + Float(i) * 20, 6) }
}

// MARK: 39 Dinner Rush Tycoon

/// A tycoon plot: a floor, and "Plot N Buy K" pads with hidden "Plot N Item K"
/// blocks that appear when bought.
func tycoonPlot(_ m: MapBuilder, n: Int, x: Float, z: Float, color: String, items: [(String, Float, Float, V, String, BlockShape)],
                lifts: [Float] = [], padRow: Bool = false) {
    m.slab("Plot \(n) Floor", x: x, y: 0, z: z, w: 30, h: 0.2, d: 30, color: "#E7E5E4", tags: ["plot"])
    m.pad("Plot \(n) Claim", x: x, z: z + 17, size: 2.4, color: color, tags: ["claim"])
    for (k, item) in items.enumerated() {
        let lift = k < lifts.count ? lifts[k] : 0
        m.part("Plot \(n) Item \(k + 1)", at: (x + item.1, 0.2 + lift + item.3.1 / 2, z + item.2), size: item.3, color: item.4, shape: item.5,
               tags: ["item"], solid: false, visible: false)
        if padRow {
            // One row along the front edge, so items stacked on the same
            // spot still get a pad each.
            let px = x - 13 + Float(k) * (26 / Float(max(1, items.count - 1)))
            m.pad("Plot \(n) Buy \(k + 1)", x: px, z: z + 13.5, y: 0.2, size: 1.4, color: "#22C55E", tags: ["buy"])
        } else {
            m.pad("Plot \(n) Buy \(k + 1)", x: x + item.1, z: z + item.2 + item.3.2 / 2 + 1.2, y: 0.2, size: 1.4, color: "#22C55E", tags: ["buy"])
        }
    }
}

func dinnerRush(_ m: MapBuilder) {
    m.day(ground: "#A3A3A3")
    m.ground(200, 200, color: "#D6D3D1", name: "Food Street")
    m.spawnRing(0, 0, radius: 5, count: 8, color: "#FB923C")
    // Bought in order; the script names them. Kitchen along the back, the
    // pass in the middle, tables at the front.
    let items: [(String, Float, Float, V, String, BlockShape)] = [
        ("Stove", -10, -10, (3, 1.2, 2), "#78716C", .box), ("Table 1", -4, 2, (2.4, 1, 2.4), "#92400E", .cylinder),
        ("Table 2", 4, 2, (2.4, 1, 2.4), "#92400E", .cylinder), ("Pass Counter", 0, -5, (6, 1, 1), "#E5E7EB", .box),
        ("Table 3", -4, 9, (2.4, 1, 2.4), "#92400E", .cylinder), ("Noodle Pot", -5, -10, (2, 1.4, 2), "#F59E0B", .cylinder),
        ("Table 4", 4, 9, (2.4, 1, 2.4), "#92400E", .cylinder), ("Grill", 4, -10, (3, 1.1, 2), "#44403C", .box),
        ("Drink Machine", 12, -5, (1.4, 2, 1.4), "#38BDF8", .box), ("Table 5", -10, 5, (2.4, 1, 2.4), "#B45309", .cylinder),
        ("Dessert Bar", 9, -10, (3, 1.2, 2), "#F9A8D4", .box), ("Table 6", 10, 2, (2.4, 1, 2.4), "#B45309", .cylinder),
        ("Second Stove", 0, -10, (3, 1.2, 2), "#57534E", .box), ("Fountain", 10, 9, (2, 2, 2), "#38BDF8", .sphere),
        ("Table 7", -10, 11, (2.4, 1, 2.4), "#7C2D12", .cylinder), ("Sushi Bar", -12, -4, (1.6, 1.2, 4), "#FEF3C7", .box),
        ("Table 8", -10, -1, (2.4, 1, 2.4), "#7C2D12", .cylinder), ("Neon Sign", 0, 13, (8, 1.4, 0.3), "#F472B6", .box),
        ("Piano", 11, 13, (2.5, 1.2, 1.5), "#111827", .box)
    ]
    for (i, p) in [(-50, -40), (50, -40), (-50, 40), (50, 40)].enumerated() {
        tycoonPlot(m, n: i + 1, x: Float(p.0), z: Float(p.1), color: ["#EF4444", "#3B82F6", "#22C55E", "#F59E0B"][i], items: items)
        m.part("Plot \(i + 1) Door", at: (Float(p.0), 0.5, Float(p.1) + 14), size: (1, 0.1, 1), color: "#000000", visible: false)
        m.pad("Plot \(i + 1) Staff", x: Float(p.0) - 13, z: Float(p.1) + 13, y: 0.2, size: 1.6, color: "#A855F7", tags: ["staff"])
    }
}

// MARK: 40 Coaster Park Tycoon

func coasterPark(_ m: MapBuilder) {
    m.day(ground: "#4ADE80")
    m.ground(220, 220, color: "#86EFAC", name: "Park Land")
    m.spawnRing(0, 0, radius: 5, count: 8, color: "#FDE047")
    // Bought in order; the script names them. The path runs down the middle.
    let items: [(String, Float, Float, V, String, BlockShape)] = [
        ("Path", 0, 0, (4, 0.05, 26), "#D6D3D1", .box), ("Carousel", -8, -6, (6, 3, 6), "#F472B6", .cylinder),
        ("Snack Stand", 8, -8, (3, 2.5, 3), "#FBBF24", .box), ("Restroom", 12, -12, (2.5, 2.5, 2.5), "#E0F2FE", .box),
        ("Ferris Wheel", -8, 7, (1, 10, 10), "#60A5FA", .cylinder), ("Bumper Cars", 8, 5, (7, 0.6, 7), "#A78BFA", .box),
        ("Drink Stand", -12, -12, (2.5, 2.5, 2.5), "#22D3EE", .box), ("Pirate Ship", -7, -13, (5, 4, 2.5), "#92400E", .box),
        ("Drop Tower", 11, -1, (2, 16, 2), "#EF4444", .cylinder), ("Haunted House", 6, -12, (4, 4, 4), "#4C1D95", .box),
        ("Roller Coaster", -13.5, 3, (2, 7, 18), "#F97316", .box), ("Log Flume", 12, 12, (4, 1.5, 5), "#0EA5E9", .box),
        ("Fountain", 0, 11, (3, 2, 3), "#38BDF8", .sphere), ("Fireworks Tower", -4, 12, (1.2, 6, 1.2), "#F43F5E", .cylinder)
    ]
    for (i, p) in [(-55, -55), (55, -55), (-55, 55), (55, 55)].enumerated() {
        tycoonPlot(m, n: i + 1, x: Float(p.0), z: Float(p.1), color: ["#EF4444", "#3B82F6", "#22C55E", "#F59E0B"][i], items: items)
        m.part("Plot \(i + 1) Gate", at: (Float(p.0), 0.5, Float(p.1) + 14), size: (1, 0.1, 1), color: "#000000", visible: false)
        m.pad("Plot \(i + 1) Office", x: Float(p.0) - 13, z: Float(p.1) + 13, y: 0.2, size: 1.6, color: "#A855F7", tags: ["office"])
    }
}

// MARK: 41 Life Ville

func lifeVille(_ m: MapBuilder) {
    m.day(ground: "#A3E635")
    m.ground(180, 180, color: "#BEF264", name: "Village")
    m.road(from: (-90, 0), to: (90, 0), width: 7)
    m.spawnRing(0, 8, radius: 4, count: 8, color: "#FDE68A")
    for i in 0..<8 {
        let x = -63 + Float(i % 4) * 42
        let z: Float = i < 4 ? 28 : -28
        let facing: Float = i < 4 ? -1 : 1
        let n = i + 1
        m.house("Home \(n)", x: x, z: z, w: 14, d: 12, h: 3.6, wall: ["#FEF3C7", "#E0F2FE", "#FCE7F3", "#DCFCE7"][i % 4], roof: "#7C2D12",
                floor: "#D6B98C", tags: ["home", "h\(n)"], facing: facing)
        m.pad("Home \(n) Sign", x: x + 6, z: z + facing * 9, size: 1.6, color: "#FDE047", tags: ["claim"])
        // Furniture that fills needs, and an easel for painting.
        m.pad("Home \(n) Fridge", x: x - 5, z: z - facing * 4, y: 0.15, size: 1.4, color: "#E5E7EB", tags: ["need", "hunger"], shape: .box)
        m.pad("Home \(n) Bed", x: x + 4, z: z - facing * 4, y: 0.15, size: 2.2, color: "#93C5FD", tags: ["need", "energy"], shape: .box)
        m.pad("Home \(n) TV", x: x - 5, z: z + facing * 2, y: 0.15, size: 1.4, color: "#111827", tags: ["need", "fun"], shape: .box)
        m.pad("Home \(n) Shower", x: x + 5, z: z + facing * 2, y: 0.15, size: 1.4, color: "#67E8F9", tags: ["need", "hygiene"], shape: .box)
        m.pad("Home \(n) Easel", x: x - 1, z: z - facing * 4, y: 0.15, size: 1.2, color: "#F472B6", tags: ["skill", "creative"], shape: .box)
    }
    // Workplaces.
    m.shop("Office", x: 70, z: -60, w: 14, d: 10, color: "#64748B", sign: "#FFFFFF")
    m.pad("Work Desk", x: 70, z: -58, size: 3, color: "#0EA5E9", tags: ["job", "office"])
    m.shop("Diner", x: -70, z: -60, w: 12, d: 10, color: "#EF4444", sign: "#FEF3C7")
    m.pad("Diner Table", x: -70, z: -58, size: 3, color: "#F97316", tags: ["need", "hunger", "public"])
    m.pad("Diner Kitchen", x: -70, z: -63, size: 2, color: "#FBBF24", tags: ["job", "chef"])
    m.shop("Gym", x: 0, z: -60, w: 12, d: 10, color: "#1E293B", sign: "#22D3EE")
    m.pad("Treadmill 1", x: -3, z: -62, size: 1.8, color: "#22D3EE", tags: ["skill", "fitness"])
    m.pad("Treadmill 2", x: 3, z: -62, size: 1.8, color: "#22D3EE", tags: ["skill", "fitness"])
    m.pad("Gym Coach", x: 0, z: -57, size: 2, color: "#A3E635", tags: ["job", "trainer"])
    // The park: swings, chess and the ranger hut.
    m.slab("Park", x: 0, y: 0, z: 70, w: 30, h: 0.1, d: 20, color: "#4ADE80")
    m.pad("Park Swing", x: 0, z: 70, y: 0.1, size: 4, color: "#F472B6", tags: ["need", "fun", "public"])
    m.pad("Chess Table", x: 9, z: 74, y: 0.1, size: 2, color: "#FEF3C7", tags: ["skill", "logic"])
    m.pad("Ranger Hut", x: -11, z: 64, y: 0.1, size: 2, color: "#16A34A", tags: ["job", "ranger"])
    m.pad("Festival Stage", x: 0, z: 78, y: 0.1, size: 5, color: "#FDE047", tags: ["festival"])
    m.markers("Litter Spot", points: ring(10, radius: 12, cx: 0, cz: 70), y: 0.1, color: "#000000", visible: false, behavior: .none)
}

// MARK: 42 Metro Response

func metroResponse(_ m: MapBuilder) {
    m.day(ground: "#57534E")
    m.ground(220, 220, color: "#6B7280", name: "Metro")
    m.road(from: (-110, 0), to: (110, 0), width: 10)
    m.road(from: (0, -110), to: (0, 110), width: 10)
    m.road(from: (-110, 60), to: (110, 60), width: 8, name: "North Ave")
    m.road(from: (-110, -60), to: (110, -60), width: 8, name: "South Ave")
    m.spawnRing(0, 0, radius: 5, count: 8, color: "#E5E7EB")
    let stations: [(String, Float, Float, String)] = [("Police Station", -40, -30, "#1E40AF"), ("Fire Station", 40, -30, "#B91C1C"),
                                                     ("Hospital", 40, 30, "#F8FAFC"), ("City Hall", -40, 30, "#A16207")]
    for s in stations {
        m.shop(s.0, x: s.1, z: s.2, w: 16, d: 12, color: s.3, sign: "#FFFFFF")
    }
    m.pad("Team Police", x: -40, z: -26, size: 3, color: "#3B82F6", tags: ["team"])
    m.pad("Team Fire", x: 40, z: -26, size: 3, color: "#EF4444", tags: ["team"])
    m.pad("Team Medic", x: 40, z: 34, size: 3, color: "#F472B6", tags: ["team"])
    m.pad("Team Civilian", x: -40, z: 34, size: 3, color: "#A3A3A3", tags: ["team"])
    m.pad("Team Criminal", x: 90, z: 90, size: 3, color: "#111827", tags: ["team"])
    m.pad("Hospital Bed", x: 44, z: 30, size: 2.4, color: "#FCA5A5", tags: ["hospital"])
    m.pad("Jail Door", x: -44, z: -30, size: 2.4, color: "#93C5FD", tags: ["jail"])
    m.markers("Jail Exit", points: [(-40, -18)], color: "#000000", visible: false, behavior: .none)
    m.pad("Hydrant", x: 33, z: -21, size: 1.6, color: "#DC2626", tags: ["hydrant"])
    m.pad("City Hall Vault", x: -44, z: 27, size: 2, color: "#FACC15", tags: ["vault"])
    m.pad("Hideout Stash", x: 84, z: 86, size: 2.4, color: "#22C55E", tags: ["stash"])
    m.pad("Taxi Stand", x: 10, z: 10, size: 2.4, color: "#FDE047", tags: ["taxi"])
    for (i, p) in [(20, 70), (-60, -70)].enumerated() {
        m.part("ATM \(i + 1)", at: (Float(p.0), 1.1, Float(p.1)), size: (1.2, 2.2, 0.8), color: "#16A34A", material: .neon, tags: ["atm"])
    }
    m.markers("Emergency Spot", points: [(70, 80), (-70, 80), (80, -80), (-80, -80), (20, 85), (-90, 20), (90, -20), (-20, -90)],
              color: "#000000", visible: false, behavior: .none)
    // Buildings, kept off the emergency spots, ATMs and the hideout.
    let keepClear: [(Float, Float)] = [(70, 80), (-70, 80), (80, -80), (-80, -80), (20, 85), (-90, 20), (90, -20), (-20, -90),
                                       (20, 70), (-60, -70), (86, 88)]
    var r = Seeded("metro")
    var built = 0
    for _ in 0..<30 where built < 12 {
        let x = r.range(-100, 100), z = r.range(-100, 100)
        let h = r.range(6, 24)
        let color = r.pick(["#9CA3AF", "#78716C", "#A8A29E"])
        if abs(x) < 20 || abs(z) < 20 { continue }
        if abs(abs(z) - 60) < 11 { continue }
        if keepClear.contains(where: { abs($0.0 - x) < 13 && abs($0.1 - z) < 13 }) { continue }
        built += 1
        m.slab("Building \(built)", x: x, y: 0, z: z, w: 12, h: h, d: 12, color: color)
    }
}

// MARK: 43 Academy Days

func academyDays(_ m: MapBuilder) {
    m.day(ground: "#A3E635")
    m.ground(160, 160, color: "#84CC16", name: "Campus")
    m.slab("Hallway", x: 0, y: 0, z: 0, w: 70, h: 0.2, d: 10, color: "#E5E7EB")
    m.spawnRing(0, 0, y: 0.2, radius: 3, count: 8, color: "#FDE68A")
    // Six classrooms, each with a doorway facing the hallway.
    let rooms: [(String, String, Float, Float)] = [("Math Room", "#60A5FA", -24, -15), ("Art Room", "#F472B6", 0, -15),
                                                   ("Music Room", "#A78BFA", 24, -15), ("Cafeteria", "#FBBF24", -24, 15),
                                                   ("Potion Lab", "#22D3EE", 0, 15), ("Library", "#34D399", 24, 15)]
    for r in rooms {
        let front: Float = r.3 < 0 ? r.3 + 9 : r.3 - 9
        let back: Float = r.3 < 0 ? r.3 - 9 : r.3 + 9
        m.slab("\(r.0) Floor", x: r.2, y: 0, z: r.3, w: 20, h: 0.2, d: 18, color: "#F3F4F6")
        m.slab("\(r.0) Wall", x: r.2, y: 0.2, z: back, w: 20.4, h: 4, d: 0.4, color: r.1, opacity: 0.85)
        m.slab("\(r.0) Wall", x: r.2 - 10, y: 0.2, z: r.3, w: 0.4, h: 4, d: 18, color: r.1, opacity: 0.85)
        m.slab("\(r.0) Wall", x: r.2 + 10, y: 0.2, z: r.3, w: 0.4, h: 4, d: 18, color: r.1, opacity: 0.85)
        m.slab("\(r.0) Wall", x: r.2 - 5.75, y: 0.2, z: front, w: 8.5, h: 4, d: 0.4, color: r.1, opacity: 0.85)
        m.slab("\(r.0) Wall", x: r.2 + 5.75, y: 0.2, z: front, w: 8.5, h: 4, d: 0.4, color: r.1, opacity: 0.85)
        m.slab("\(r.0) Wall", x: r.2, y: 2.9, z: front, w: 3, h: 1.3, d: 0.4, color: r.1, opacity: 0.85)
        m.pad(r.0, x: r.2, z: r.3, y: 0.2, size: 10, color: r.1, tags: ["room"], shape: .box)
    }
    m.markers("Book Spot", points: [(17, 20), (20, 21), (24, 21), (28, 21), (31, 20), (24, 18)], y: 0.2, color: "#A16207",
              tags: ["book"], size: 0.9)
    // The four dorm crests at the ends of the hallway.
    let dorms: [(String, String, Float, Float)] = [("Dorm Blaze", "#EF4444", -32, -3), ("Dorm Tide", "#3B82F6", -32, 3),
                                                   ("Dorm Forest", "#22C55E", 32, -3), ("Dorm Volt", "#FACC15", 32, 3)]
    for d in dorms {
        m.pad(d.0, x: d.2, z: d.3, y: 0.2, size: 2.4, color: d.1, tags: ["dorm"])
        m.part("\(d.0) Banner", at: (d.2 + (d.2 < 0 ? -2.5 : 2.5), 2.5, d.3), size: (0.2, 3, 2), color: d.1, material: .neon, solid: false)
    }
    m.pad("Ballot Box", x: 0, z: -4, y: 0.2, size: 1.6, color: "#F8FAFC", tags: ["ballot"])
    // Gym: a running track outside, with hurdles.
    m.slab("Gym Track", x: 0, y: 0, z: 55, w: 60, h: 0.1, d: 20, color: "#DC2626")
    m.pad("Gym", x: -26, z: 55, y: 0.1, size: 4, color: "#FFFFFF", tags: ["room"])
    m.pad("Track Finish", x: 26, z: 55, y: 0.1, size: 4, color: "#22C55E", tags: ["finish"])
    for x in [Float(-14), -2, 10] {
        m.slab("Hurdle", x: x, y: 0.1, z: 55, w: 0.3, h: 0.7, d: 18, color: "#FFFFFF")
    }
    for p in ring(10, radius: 72) { m.tree(p.0, p.1, height: 5, leaves: "#65A30D") }
}

// MARK: 44 Willow Hospital RP

func willowHospital(_ m: MapBuilder) {
    m.day(ground: "#A3E635")
    m.ground(120, 120, color: "#BEF264", name: "Lawn")
    m.slab("Hospital Floor", x: 0, y: 0, z: 0, w: 50, h: 0.2, d: 36, color: "#F8FAFC")
    // Walls with a five-metre entrance in the front (south) wall.
    m.slab("Hospital Wall", x: 0, y: 0.2, z: -18, w: 51, h: 5, d: 1, color: "#E0F2FE")
    m.slab("Hospital Wall", x: -25, y: 0.2, z: 0, w: 1, h: 5, d: 36, color: "#E0F2FE")
    m.slab("Hospital Wall", x: 25, y: 0.2, z: 0, w: 1, h: 5, d: 36, color: "#E0F2FE")
    m.slab("Hospital Wall", x: -13.75, y: 0.2, z: 18, w: 23.5, h: 5, d: 1, color: "#E0F2FE")
    m.slab("Hospital Wall", x: 13.75, y: 0.2, z: 18, w: 23.5, h: 5, d: 1, color: "#E0F2FE")
    m.slab("Hospital Wall", x: 0, y: 3.2, z: 18, w: 5, h: 2, d: 1, color: "#E0F2FE")
    m.slab("Hospital Roof", x: 0, y: 5.2, z: 0, w: 51, h: 0.4, d: 37, color: "#0EA5E9")
    m.part("Hospital Sign", at: (0, 4.6, 18.6), size: (8, 1, 0.2), color: "#EF4444", material: .neon, solid: false)
    m.spawnRing(0, 24, radius: 4, count: 8, color: "#FCA5A5")
    m.pad("Reception", x: 0, z: 12, y: 0.2, size: 3, color: "#22C55E", tags: ["reception"])
    m.pad("Pharmacy", x: -18, z: 10, y: 0.2, size: 3, color: "#A855F7", tags: ["pharmacy"])
    m.pad("Staff Room", x: 18, z: 10, y: 0.2, size: 3, color: "#0EA5E9", tags: ["staff"])
    for i in 0..<9 {
        let x: Float = [-18, 0, 18, -18, 0, 18, -18, -9, 0][i]
        let z: Float = i < 3 ? -6 : (i < 6 ? -13 : 2)
        m.slab("Bed \(i + 1) Frame", x: x, y: 0.2, z: z, w: 2.4, h: 0.6, d: 4, color: "#CBD5E1")
        m.pad("Bed \(i + 1)", x: x, z: z, y: 0.8, size: 2, color: "#BFDBFE", tags: ["bed"], shape: .box)
    }
    // The operating theatre.
    m.slab("OR Floor", x: 14, y: 0.2, z: 1, w: 10, h: 0.05, d: 8, color: "#A7F3D0")
    m.slab("OR Table Frame", x: 14, y: 0.25, z: 1, w: 2.4, h: 0.8, d: 4, color: "#94A3B8")
    m.pad("OR Table", x: 14, z: 1, y: 1.05, size: 2, color: "#34D399", tags: ["or"], shape: .box)
    m.part("OR Light", at: (14, 4.2, 1), size: (2, 0.3, 2), color: "#FEF9C3", shape: .cylinder, material: .neon, solid: false)
    // The ambulance bay and places where accidents happen.
    m.slab("Ambulance", x: 30, y: 0, z: 26, w: 3, h: 2.6, d: 6, color: "#FFFFFF")
    m.part("Ambulance Light", at: (30, 2.8, 26), size: (1, 0.3, 0.6), color: "#EF4444", material: .neon)
    m.pad("ER Bay", x: 30, z: 20, size: 3, color: "#F87171", tags: ["erbay"])
    m.part("Patient Door", at: (0, 0.5, 20), size: (1, 0.1, 1), color: "#000000", visible: false)
    m.markers("Accident Spot", points: [(-45, 40), (45, -40), (-45, -45), (48, 48)], color: "#000000", visible: false, behavior: .none)
}

// MARK: 45 Street Drive Empire

func streetDrive(_ m: MapBuilder) {
    m.day(ground: "#4D7C0F")
    m.ground(420, 420, color: "#65A30D", name: "Countryside")

    // The highway ring (the circuit) and a grid of city streets inside it.
    let ring: [(Float, Float)] = [(-120, -120), (120, -120), (120, 120), (-120, 120)]
    for i in 0..<ring.count {
        m.road(from: ring[i], to: ring[(i + 1) % ring.count], width: 14, name: "Highway \(i + 1)")
    }
    m.road(from: (-120, 0), to: (120, 0), width: 11, name: "Main Street")
    m.road(from: (0, -120), to: (0, 120), width: 11, name: "Center Avenue")
    for v: Float in [-60, 60] {
        m.road(from: (v, -120), to: (v, 120), width: 9, name: "Street", dashed: false)
        m.road(from: (-120, v), to: (120, v), width: 9, name: "Street", dashed: false)
    }
    for i in 0..<12 { m.lamp(-110 + Float(i) * 20, 7) }
    for i in 0..<12 { m.lamp(7, -110 + Float(i) * 20) }

    // Downtown: the spawn and the car meet plaza.
    m.spawnRing(30, 22, radius: 5, count: 8, color: "#F97316")
    m.slab("Meet Plaza", x: 30, y: 0, z: 36, w: 30, h: 0.06, d: 14, color: "#1E1B4B", material: .matte)
    m.pad("Car Meet", x: 30, z: 36, size: 8, color: "#A855F7", tags: ["meet"])
    m.part("Meet Sign", at: (30, 6, 44), size: (16, 1.6, 0.3), color: "#F0ABFC", material: .neon, solid: false)
    m.parkedCar("Meet Car 1", x: 20, z: 36, yaw: 90, color: "#F43F5E", sporty: true)
    m.parkedCar("Meet Car 2", x: 40, z: 36, yaw: -90, color: "#22D3EE", sporty: true)

    // The dealership: a glass showroom with a doorway, and a lot of cars for sale.
    m.slab("Showroom Floor", x: -30, y: 0, z: 30, w: 44, h: 0.15, d: 44, color: "#E5E7EB")
    let glass = "#93C5FD"
    m.slab("Showroom Glass", x: -30, y: 0, z: 14, w: 30, h: 5, d: 0.4, color: glass, material: .glass, opacity: 0.35)
    m.slab("Showroom Glass", x: -45, y: 0, z: 22, w: 0.4, h: 5, d: 16, color: glass, material: .glass, opacity: 0.35)
    m.slab("Showroom Glass", x: -15, y: 0, z: 22, w: 0.4, h: 5, d: 16, color: glass, material: .glass, opacity: 0.35)
    m.slab("Showroom Glass", x: -39.5, y: 0, z: 30, w: 11, h: 5, d: 0.4, color: glass, material: .glass, opacity: 0.35)
    m.slab("Showroom Glass", x: -20.5, y: 0, z: 30, w: 11, h: 5, d: 0.4, color: glass, material: .glass, opacity: 0.35)
    m.part("Dealer Sign", at: (-30, 6.5, 30.4), size: (18, 1.6, 0.3), color: "#FACC15", material: .neon, solid: false)
    m.pad("Dealer Counter", x: -30, z: 22, size: 4, color: "#FACC15", tags: ["dealer"])
    m.parkedCar("Showroom Car 1", x: -39, z: 21, yaw: 150, color: "#DC2626", sporty: true)
    m.parkedCar("Showroom Car 2", x: -21, z: 21, yaw: -150, color: "#F8FAFC", sporty: true)
    let lot = ["#3B82F6", "#FACC15", "#10B981", "#111827", "#A855F7", "#F97316", "#EC4899", "#64748B"]
    for (i, color) in lot.enumerated() {
        let x = -48 + Float(i % 4) * 12
        let z: Float = i < 4 ? 40 : 50
        m.parkedCar("Lot Car \(i + 1)", x: x, z: z, yaw: i < 4 ? 180 : 0, color: color, sporty: i % 3 == 1)
    }

    // Garage row: paint booth and tuning shop.
    m.shop("Paint Shop", x: -42, z: -30, w: 14, d: 12, color: "#7C3AED", sign: "#F0ABFC", facing: 1)
    m.pad("Paint Booth", x: -42, z: -22, size: 4, color: "#E879F9", tags: ["paint"])
    m.shop("Tuning Shop", x: -18, z: -30, w: 14, d: 12, color: "#0F172A", sign: "#38BDF8", facing: 1)
    m.pad("Tuning Bay", x: -18, z: -22, size: 4, color: "#38BDF8", tags: ["tuning"])
    m.pad("Garage", x: -30, z: -14, size: 4, color: "#F97316", tags: ["garage"])

    // Gas stations.
    for (i, p) in [(30, -30), (-90, 90)].enumerated() {
        let (x, z) = (Float(p.0), Float(p.1))
        m.slab("Gas Canopy \(i + 1)", x: x, y: 4, z: z, w: 16, h: 0.4, d: 10, color: "#DC2626")
        for sx: Float in [-1, 1] { m.pillar("Gas Post", x: x + sx * 6, z: z, height: 4, radius: 0.3, color: "#F8FAFC") }
        m.pad("Gas Station \(i + 1)", x: x, z: z, size: 6, color: "#22C55E", tags: ["gas"])
    }

    // The depot where deliveries start.
    m.slab("Depot Floor", x: 90, y: 0, z: 30, w: 34, h: 0.12, d: 26, color: "#A8A29E")
    m.walls(90, 26, w: 26, d: 14, h: 6, color: "#78716C", name: "Depot Wall")
    m.slab("Depot Door", x: 90, y: 0, z: 33, w: 8, h: 0.02, d: 1, color: "#A8A29E", solid: false)
    for k in 0..<6 { m.crate(80 + Float(k % 3) * 3, 22 + Float(k / 3) * 3, color: "#B45309") }
    m.pad("Depot", x: 90, z: 38, size: 5, color: "#F59E0B", tags: ["depot"])

    // Houses to deliver to, each with its own drop-off pad by the street.
    let homes: [(Float, Float, Float)] = [(-90, -90, 1), (-90, -30, 1), (90, -90, 1), (90, -30, 1),
                                          (-90, 30, 1), (30, 90, 1), (-30, 90, 1), (90, 90, 1)]
    let roofs = ["#B5453B", "#1D4ED8", "#15803D", "#7C3AED", "#B45309", "#0F766E", "#BE185D", "#334155"]
    for (i, h) in homes.enumerated() {
        m.house("Home \(i + 1)", x: h.0, z: h.1 - 6, w: 10, d: 8, roof: roofs[i], door: false, tags: ["home"])
        m.pad("Address \(i + 1)", x: h.0, z: h.1 + 4, size: 3.4, color: "#FDE68A", tags: ["address"])
    }
    m.markers("Taxi Stand", points: [(10, -50), (-50, 10), (70, 50), (-70, -50), (50, -70), (-10, 70)], color: "#FACC15",
              tags: ["taxistand"], size: 2.4)

    // Race tracks. The circuit runs round the highway ring.
    m.pad("Circuit Start", x: -110, z: -128, size: 6, color: "#22C55E", tags: ["racestart"])
    let circuit: [(Float, Float)] = [(0, -120), (120, -120), (120, 0), (120, 120), (0, 120), (-120, 120), (-120, 0), (-120, -120)]
    for (i, p) in circuit.enumerated() {
        m.part("Circuit CP \(i + 1)", at: (p.0, 3, p.1), size: (16, 6, 16), color: "#FFFFFF", shape: .cylinder,
               behavior: .trigger, tags: ["racecp"], solid: false, opacity: 0.12)
    }
    // A drag strip south of the ring: 220 m, flat out.
    m.road(from: (-110, -150), to: (110, -150), width: 16, name: "Drag Strip", dashed: false, color: "#1F2937")
    m.pad("Drag Start", x: -112, z: -150, size: 6, color: "#22C55E", tags: ["racestart"])
    m.part("Drag CP 1", at: (108, 3, -150), size: (16, 6, 16), color: "#FFFFFF", shape: .cylinder,
           behavior: .trigger, tags: ["racecp"], solid: false, opacity: 0.12)
    for k in 0..<3 {
        m.part("Drag Light \(k + 1)", at: (-104, 4 + Float(k) * 1.1, -160), size: (1, 1, 0.4), color: ["#EF4444", "#FACC15", "#22C55E"][k],
               shape: .sphere, material: .neon, solid: false)
    }
    m.pillar("Drag Tree", x: -104, z: -160.6, height: 7, radius: 0.25, color: "#334155")
    // The city sprint through the streets.
    m.pad("City Start", x: 8, z: -14, size: 5, color: "#22C55E", tags: ["racestart"])
    let sprint: [(Float, Float)] = [(0, -60), (60, -60), (60, 60), (-60, 60), (-60, -60), (0, 0)]
    for (i, p) in sprint.enumerated() {
        m.part("Sprint CP \(i + 1)", at: (p.0, 3, p.1), size: (12, 6, 12), color: "#FFFFFF", shape: .cylinder,
               behavior: .trigger, tags: ["racecp"], solid: false, opacity: 0.12)
    }
    // A dirt rally loop out in the countryside to the north.
    let rally: [(Float, Float)] = [(-80, 150), (0, 185), (80, 150), (140, 175), (80, 200), (-60, 200), (-140, 175)]
    for i in 0..<rally.count {
        m.road(from: rally[i], to: rally[(i + 1) % rally.count], width: 10, name: "Dirt Road", dashed: false, color: "#92400E")
        m.part("Rally CP \(i + 1)", at: (rally[i].0, 3, rally[i].1), size: (14, 6, 14), color: "#FFFFFF", shape: .cylinder,
               behavior: .trigger, tags: ["racecp"], solid: false, opacity: 0.12)
    }
    m.pad("Rally Start", x: -90, z: 140, size: 6, color: "#22C55E", tags: ["racestart"])
    var r = Seeded("drive")
    for _ in 0..<26 { m.pine(r.range(-170, 170), r.range(135, 205), height: r.range(6, 11)) }
    for _ in 0..<10 { m.rock(r.range(-150, 150), r.range(140, 200), size: r.range(1.5, 3)) }

    // Speed cameras over long straights, and a stunt park with jump pads.
    let cams: [(Float, Float, Float)] = [(120, -60, 0), (-60, 120, 90), (-80, 0, 90)]
    for (i, c) in cams.enumerated() {
        let along = c.2 == 0
        m.part("Speed Cam \(i + 1)", at: (c.0, 2.5, c.1), size: along ? (16, 5, 1) : (1, 5, 16), color: "#FFFFFF",
               behavior: .trigger, tags: ["speedcam"], solid: false, opacity: 0.08)
        m.part("Speed Cam Beam", at: (c.0, 5.4, c.1), size: along ? (16, 0.4, 0.4) : (0.4, 0.4, 16), color: "#38BDF8", material: .neon, solid: false)
    }
    m.slab("Stunt Park", x: 90, y: 0, z: -90, w: 50, h: 0.1, d: 50, color: "#334155", material: .matte)
    for k in 0..<3 {
        m.part("Stunt Ramp \(k + 1)", at: (72 + Float(k) * 18, 0.4, -100), size: (6, 0.8, 6), color: "#F97316",
               material: .neon, behavior: .bounce, tags: ["stunt"])
    }
    m.pad("Landing Zone", x: 90, z: -76, size: 10, color: "#0EA5E9", tags: ["landing"])

    // Trees along the ring and a few parked cars on the streets.
    for _ in 0..<24 {
        let side: Float = r.range(0, 1) > 0.5 ? 1 : -1
        m.tree(side * r.range(128, 145), r.range(-140, 120), height: 5)
    }
    let parked: [(Float, Float, Float, String)] = [(66, 20, 0, "#64748B"), (-66, -20, 180, "#0EA5E9"), (54, -90, 90, "#F59E0B"),
                                                   (-54, 90, -90, "#84CC16"), (16, 66, 90, "#E11D48")]
    for (i, c) in parked.enumerated() { m.parkedCar("Parked Car \(i + 1)", x: c.0, z: c.1, yaw: c.2, color: c.3) }
}
