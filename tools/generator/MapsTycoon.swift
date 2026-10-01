import Foundation

// Games 126–140: tycoons, each after a tycoon popular on Roblox
// (docs/research-150.md). They run on lib/kit_tycoon.absc: claim a plot,
// step on pads to buy the next building, collect what it earns.

let tycoonGames: [Game] = [
    Game(number: 132, id: "build-a-zoo-park", title: "Build a Zoo Park",
         summary: "どうぶつ園をつくろう！ サバンナ・ジャングル・こおりの国・海のゾーンを建てて、たまごから どうぶつをかえそう。レアなどうぶつほど お客さんがよろこぶ。売店やおみやげ屋さんも！",
         tags: ["tycoon", "animals", "building"], maxPlayers: 6, libs: ["tycoon"], build: buildAZooPark),
    Game(number: 131, id: "cruise-ship-tycoon", title: "Cruise Ship Tycoon",
         summary: "自分だけの豪華客船をつくろう！ 客室・プール・レストラン・劇場をふやすと、お客さんがよろこんで乗ってくる。ときどき船が出航して、航海のボーナス！ 世界いちの客船へ。",
         tags: ["tycoon", "ships", "building"], maxPlayers: 6, libs: ["tycoon"], build: cruiseShipTycoon),
    Game(number: 130, id: "build-your-island", title: "Build Your Island",
         summary: "小さな島から はじめよう！ 木や石をとって 売ったり 加工したり。島を広げると 鉄や金も出てくる。自動のきかいで どんどん ふやして、自分だけの大きな島をつくろう！",
         tags: ["tycoon", "island", "crafting"], maxPlayers: 6, libs: ["tycoon"], build: buildYourIsland),
    Game(number: 129, id: "oil-baron-empire", title: "Oil Baron Empire",
         summary: "石油王になろう！ やぐらで石油をくみ上げて タンクにためる。石油のねだんは 上がったり下がったり。高いときに売るのがコツ！ 製油所・パイプライン・ガソリンスタンドで 大帝国へ。",
         tags: ["tycoon", "market", "industry"], maxPlayers: 6, libs: ["tycoon"], build: oilBaronEmpire),
    Game(number: 128, id: "ore-factory-haven", title: "Ore Factory Haven",
         summary: "鉱石の工場をつくろう！ マインから出た鉱石が ベルトコンベアで流れて、アップグレーダーで ねうちアップ、かまどで お金に。ときどき落ちてくる なぞの箱もさがそう。最強の工場へ！",
         tags: ["tycoon", "factory", "idle"], maxPlayers: 6, libs: ["tycoon"], build: oreFactoryHaven),
    Game(number: 127, id: "corner-store-tycoon", title: "Corner Store Tycoon",
         summary: "自分のお店をひらこう！ たなを買って品物をならべると お客さんがやってくる。レジでお会計、へった品物は 倉庫から補充。店員をやとって、お菓子屋さんから ゲームや宝石のお店へ！",
         tags: ["tycoon", "shop", "roleplay"], maxPlayers: 6, libs: ["tycoon"], build: cornerStoreTycoon),
    Game(number: 126, id: "lumber-valley-tycoon", title: "Lumber Valley Tycoon",
         summary: "森で木をきって、トラックで自分の土地へ。製材所で板にすると お金になる。のこぎり・かま・家具工房をふやして、丸太小屋も建てよう。金の木やクリスタルの木もあるよ！",
         tags: ["tycoon", "building", "forest"], maxPlayers: 6, libs: ["tycoon"], build: lumberValleyTycoon),
]

/// Lays out `count` plots in a row along x, fronts at z = 0 facing -z (the road),
/// each `w` wide and `d` deep. Every plot gets a claim pad, a collector, and for
/// every item a hidden building group "ty<k>_<id>" and a hidden buy pad
/// "tyb<k>_<id>". `draw(id, cx)` draws item `id` for the plot whose centre is at x = cx.
func tycoonPlots(_ m: MapBuilder, count: Int, w: Float, d: Float, gap: Float = 8, floor: String, padColor: String = "#22C55E",
                 items: [(String, Float, Float)], collector: (Float, Float), showcase: Bool = true, draw: (String, Float) -> Void) {
    // A finished plot at the end of the row, to show what you can build (and for the cover).
    if showcase {
        let sx = (Float(count + 1) - Float(count + 1) / 2) * (w + gap)
        m.slab("Showcase Floor", x: sx, y: -0.02, z: d / 2, w: w, h: 0.08, d: d, color: floor)
        m.part("Showcase Sign", at: (sx, 4, -3), size: (10, 1.6, 0.3), color: "#F472B6", material: .neon, solid: false)
        for (id, _, _) in items { draw(id, sx) }
    }
    for k in 1...count {
        let cx = (Float(k) - Float(count + 1) / 2) * (w + gap)
        m.slab("Plot \(k) Floor", x: cx, y: -0.02, z: d / 2, w: w, h: 0.08, d: d, color: floor)
        m.pad("Claim \(k)", x: cx, z: -2.5, size: 3.4, color: "#FFFFFF", tags: ["ty_claim", "k=\(k)"])
        m.part("Plot \(k) Sign", at: (cx, 3, -4.5), size: (6, 1.2, 0.2), color: "#FACC15", material: .neon, solid: false)
        m.slab("Collector Box \(k)", x: cx + collector.0, y: 0, z: collector.1 + 1.6, w: 3, h: 1.4, d: 1.4, color: "#16A34A", material: .metal)
        m.pad("Collector \(k)", x: cx + collector.0, z: collector.1, size: 2.6, color: "#22C55E", tags: ["ty_collect", "k=\(k)"])
        for (id, px, pz) in items {
            m.group("tyb\(k)_\(id)", shown: false) {
                m.pad("Buy \(k) \(id)", x: cx + px, z: pz, size: 2.4, color: padColor, tags: ["ty_buy", "k=\(k)", "item=\(id)"])
            }
            m.group("ty\(k)_\(id)", shown: false) {
                draw(id, cx)
            }
        }
    }
}

// MARK: 126 Lumber Valley Tycoon (Lumber Tycoon 2)

func lumberValleyTycoon(_ m: MapBuilder) {
    m.day(ground: "#4D7C0F")
    m.environment.skyStyle = .clouds
    m.ground(380, 300, color: "#65A30D", x: 22, z: 70, material: .grass)
    m.road(from: (-150, -10), to: (200, -10), width: 10, name: "Valley Road", dashed: false, color: "#78716C")
    m.spawnRing(0, -14, radius: 4, count: 6, color: "#F59E0B")
    // Shops along the road: axes, trucks, the wood buyer.
    m.shop("Axe Shop", x: -40, z: -26, w: 12, d: 8, color: "#FDBA74", sign: "#B45309", facing: 1)
    m.pad("Axe Pad", x: -40, z: -18, size: 3, color: "#F59E0B", tags: ["axes"])
    m.shop("Truck Shop", x: 0, z: -26, w: 12, d: 8, color: "#BAE6FD", sign: "#0284C7", facing: 1)
    m.pad("Truck Pad", x: 0, z: -18, size: 3, color: "#0EA5E9", tags: ["trucks"])
    m.shop("Wood Buyer", x: 40, z: -26, w: 12, d: 8, color: "#FDE68A", sign: "#CA8A04", facing: 1)
    m.pad("Wood Buyer Pad", x: 40, z: -18, size: 3, color: "#FACC15", tags: ["woodsell"])
    let items: [(String, Float, Float)] = [("saw1", -2.5, 6), ("fence", 2.5, 6), ("cabin1", -2.5, 11), ("saw2", 2.5, 11), ("cabin2", -2.5, 16),
                                           ("kiln", 2.5, 16), ("cabin3", -2.5, 21), ("saw3", 2.5, 21), ("porch", -2.5, 26), ("shop", 2.5, 26), ("saw4", 0, 31)]
    tycoonPlots(m, count: 6, w: 36, d: 40, floor: "#A3A34A", padColor: "#F59E0B", items: items, collector: (13, 3)) { id, cx in
        switch id {
        case "saw1":
            m.slab("Small Saw", x: cx - 12, y: 0, z: 10, w: 4, h: 1.2, d: 2, color: "#78716C", material: .metal)
            m.part("Saw Blade", at: (cx - 12, 1.6, 10), size: (1.6, 0.1, 1.6), color: "#E5E7EB", shape: .cylinder, material: .metal, tags: ["ty_drop", "drop=#D97706"],
                   solid: false, rotation: (90, 0, 0))
        case "fence":
            m.fence(from: (cx - 18, 0.5), to: (cx - 18, 40), color: "#92400E")
            m.fence(from: (cx + 18, 0.5), to: (cx + 18, 40), color: "#92400E")
            m.fence(from: (cx - 18, 40), to: (cx + 18, 40), color: "#92400E")
        case "cabin1":
            m.slab("Cabin Floor", x: cx - 10, y: 0, z: 32, w: 12, h: 0.4, d: 8, color: "#A16207", material: .wood)
        case "saw2":
            m.slab("Conveyor Saw", x: cx + 11, y: 0, z: 12, w: 3, h: 1, d: 8, color: "#475569", material: .metal)
            m.part("Big Blade", at: (cx + 11, 1.8, 12), size: (2.2, 0.1, 2.2), color: "#E5E7EB", shape: .cylinder, material: .metal, tags: ["ty_drop", "drop=#B45309"],
                   solid: false, rotation: (0, 0, 90))
        case "cabin2":
            m.slab("Cabin Wall", x: cx - 13, y: 0.4, z: 28.2, w: 6, h: 3.6, d: 0.4, color: "#92400E", material: .wood)
            m.slab("Cabin Wall", x: cx - 5, y: 0.4, z: 28.2, w: 2, h: 3.6, d: 0.4, color: "#92400E", material: .wood)
            m.slab("Cabin Wall", x: cx - 15.8, y: 0.4, z: 32, w: 0.4, h: 3.6, d: 8, color: "#92400E", material: .wood)
            m.slab("Cabin Wall", x: cx - 4.2, y: 0.4, z: 32, w: 0.4, h: 3.6, d: 8, color: "#92400E", material: .wood)
            m.slab("Cabin Wall", x: cx - 10, y: 0.4, z: 35.8, w: 12, h: 3.6, d: 0.4, color: "#92400E", material: .wood)
        case "kiln":
            m.slab("Kiln", x: cx + 11, y: 0, z: 20, w: 4, h: 3.2, d: 4, color: "#9A3412", material: .brick)
            m.part("Kiln Fire", at: (cx + 11, 1, 17.9), size: (1.6, 1, 0.1), color: "#F97316", material: .neon, solid: false)
            m.part("Kiln Chimney", at: (cx + 12, 4.4, 21), size: (0.8, 2.4, 0.8), color: "#57534E", tags: ["ty_drop", "drop=#78350F"], solid: false)
        case "cabin3":
            m.part("Cabin Roof", at: (cx - 10, 5.2, 32), size: (14, 2.6, 10), color: "#7C2D12", shape: .cone, material: .wood, solid: false)
        case "saw3":
            m.slab("Big Mill", x: cx + 11, y: 0, z: 28, w: 7, h: 4, d: 7, color: "#334155", material: .metal)
            m.part("Mill Wheel", at: (cx + 14.8, 2.5, 28), size: (4, 0.4, 4), color: "#64748B", shape: .cylinder, material: .metal, tags: ["ty_drop", "drop=#FBBF24"],
                   solid: false, rotation: (0, 0, 90))
        case "porch":
            m.slab("Porch", x: cx - 10, y: 0, z: 26.5, w: 12, h: 0.4, d: 3, color: "#B45309", material: .wood)
            m.part("Lantern", at: (cx - 6.5, 3, 27.6), size: (0.5, 0.7, 0.5), color: "#FDE68A", material: .neon, solid: false)
        case "shop":
            m.slab("Furniture Shop", x: cx - 12, y: 0, z: 18, w: 7, h: 3.6, d: 6, color: "#FDE68A", material: .wood)
            m.part("Shop Sign", at: (cx - 12, 4.2, 14.9), size: (5, 0.8, 0.2), color: "#F59E0B", material: .neon, tags: ["ty_drop", "drop=#FDE68A"], solid: false)
        default:
            m.slab("Laser Mill", x: cx + 11, y: 0, z: 37, w: 8, h: 2, d: 4, color: "#1E1B4B", material: .metal)
            m.part("Laser", at: (cx + 11, 3, 37), size: (7, 0.2, 0.2), color: "#22D3EE", material: .neon, tags: ["ty_drop", "drop=#22D3EE"], solid: false)
        }
    }
    // Log deposit pads on each plot (always there).
    for k in 1...6 {
        let cx = (Float(k) - 3.5) * 44
        m.pad("Deposit \(k)", x: cx - 13, z: 3, size: 2.8, color: "#92400E", tags: ["deposit", "k=\(k)"])
        m.slab("Log Pile \(k)", x: cx - 13, y: 0, z: 6, w: 3, h: 0.9, d: 1.6, color: "#78350F", material: .wood)
    }
    // The forests behind the plots: oak, then birch and pine, then the gold grove and crystal trees.
    var r = Seeded("lumber")
    var n = 0
    let kinds: [(String, Float, Float, String, String)] = [("oak", 60, 100, "#78350F", "#15803D"), ("birch", 100, 140, "#F5F5F4", "#65A30D"),
                                                           ("pine", 140, 175, "#57534E", "#14532D"), ("gold", 175, 200, "#A16207", "#FACC15"),
                                                           ("crystal", 200, 215, "#7DD3FC", "#A855F7")]
    for (kind, z0, z1, trunk, leaves) in kinds {
        let count = kind == "crystal" ? 8 : (kind == "gold" ? 12 : 28)
        for _ in 0..<count {
            n += 1
            let x = r.range(-150, 150), z = r.range(z0, z1)
            let h = r.range(4, 7)
            m.part("Tree \(n)", at: (x, h / 2, z), size: (0.9, h, 0.9), color: trunk, shape: .cylinder, material: .wood, tags: ["ltree", "kind=\(kind)"])
            m.part("Tree \(n) Top", at: (x, h + 1.6, z), size: (4, 4, 4), color: leaves, shape: kind == "pine" ? .cone : .sphere,
                   material: kind == "crystal" ? .glass : .matte, solid: false)
        }
    }
    m.coverFocus(x: 154, y: 2, z: 22, yaw: 210, width: 40)
}

// MARK: 127 Corner Store Tycoon (Retail Tycoon 2)

/// The shelves in a store, by id, with their spot (x offset, z) and colour.
let storeShelves: [(String, Float, Float, String)] = [("snack", -10, 14, "#F59E0B"), ("drink", -10, 22, "#0EA5E9"), ("fruit", 0, 14, "#22C55E"),
                                                      ("toy", 0, 22, "#EC4899"), ("tech", 10, 14, "#6366F1"), ("gold", 10, 22, "#FACC15")]

func cornerStoreTycoon(_ m: MapBuilder) {
    m.day(ground: "#94A3B8")
    m.environment.skyStyle = .clouds
    m.ground(360, 160, color: "#A3A3A3", x: 22, z: 30, material: .matte)
    m.road(from: (-160, -12), to: (200, -12), width: 10, name: "Shopping Street")
    m.slab("Sidewalk", x: 22, y: -0.01, z: -4, w: 360, h: 0.05, d: 6, color: "#D6D3D1")
    m.spawnRing(0, -18, radius: 4, count: 6, color: "#22D3EE")
    let items: [(String, Float, Float)] = [("floor", -3, 4), ("register", 3, 4), ("snack", -3, 8), ("walls", 3, 8), ("drink", -3, 12), ("lights", 3, 12),
                                           ("fruit", -3, 16), ("cashier", 3, 16), ("toy", -3, 20), ("sign", 3, 20), ("clerk", -3, 24),
                                           ("tech", 3, 24), ("aircon", -3, 28), ("gold", 3, 28)]
    tycoonPlots(m, count: 6, w: 36, d: 34, floor: "#E7E5E4", padColor: "#22C55E", items: items, collector: (14, 3)) { id, cx in
        if let sh = storeShelves.first(where: { $0.0 == id }) {
            let (_, ox, z, c) = sh
            m.slab("Shelf", x: cx + ox, y: 0, z: z, w: 5, h: 2.2, d: 1.4, color: "#78350F", material: .wood)
            for q in 0..<3 {
                m.part("Goods", at: (cx + ox - 1.6 + Float(q) * 1.6, 2.5, z), size: (1, 0.6, 1), color: c, material: .neon, solid: false)
            }
            m.part("Shelf Spot \(id)", at: (cx + ox, 0.6, z - 2), size: (1, 1, 1), color: "#000000", tags: ["shelfspot", "item=\(id)"], solid: false,
                   visible: false)
            return
        }
        switch id {
        case "floor":
            m.slab("Store Floor", x: cx, y: 0, z: 18, w: 32, h: 0.2, d: 26, color: "#FEF3C7", material: .wood)
        case "register":
            m.slab("Counter", x: cx + 12, y: 0.2, z: 10, w: 6, h: 1.2, d: 1.6, color: "#475569")
            m.part("Register", at: (cx + 12, 1.7, 10), size: (1, 0.6, 0.8), color: "#111827", material: .metal, tags: ["ty_drop", "drop=#FACC15"], solid: false)
            m.part("Register Spot", at: (cx + 12, 0.6, 12.6), size: (1, 1, 1), color: "#000000", tags: ["regspot"], solid: false, visible: false)
            m.pad("Register Pad", x: cx + 12, z: 7.4, y: 0.2, size: 1.8, color: "#FACC15", tags: ["register"])
        case "walls":
            m.slab("Store Wall", x: cx - 16, y: 0.2, z: 18, w: 0.5, h: 5, d: 26, color: "#FDE68A")
            m.slab("Store Wall", x: cx + 16, y: 0.2, z: 18, w: 0.5, h: 5, d: 26, color: "#FDE68A")
            m.slab("Store Wall", x: cx, y: 0.2, z: 31, w: 32, h: 5, d: 0.5, color: "#FDE68A")
            m.slab("Store Front", x: cx - 11, y: 0.2, z: 5, w: 10, h: 5, d: 0.5, color: "#BAE6FD", material: .glass, opacity: 0.5)
            m.slab("Store Front", x: cx + 11, y: 0.2, z: 5, w: 10, h: 5, d: 0.5, color: "#BAE6FD", material: .glass, opacity: 0.5)
            m.slab("Store Lintel", x: cx, y: 4.2, z: 5, w: 12, h: 1, d: 0.5, color: "#FDE68A")
        case "lights":
            for q in 0..<3 { m.part("Ceiling Light", at: (cx - 10 + Float(q) * 10, 4.8, 18), size: (4, 0.2, 1), color: "#FEF9C3", material: .neon, solid: false) }
        case "cashier":
            m.part("Cashier Spot", at: (cx + 14.4, 0.6, 7.6), size: (1, 1, 1), color: "#000000", tags: ["cashier_spot"], solid: false, visible: false)
            m.part("Cashier Mat", at: (cx + 14.4, 0.25, 7.6), size: (1.4, 0.05, 1.4), color: "#16A34A", solid: false)
        case "sign":
            m.part("Store Sign", at: (cx, 6, 4.6), size: (14, 2, 0.4), color: "#EF4444", material: .neon, solid: false)
        case "clerk":
            m.slab("Stockroom", x: cx - 13, y: 0.2, z: 28, w: 5, h: 3, d: 4, color: "#A8A29E")
            m.part("Clerk Spot", at: (cx - 13, 0.6, 25), size: (1, 1, 1), color: "#000000", tags: ["clerk_spot"], solid: false, visible: false)
        default:
            m.slab("Air Conditioner", x: cx + 13, y: 3.4, z: 30.4, w: 4, h: 1.2, d: 0.8, color: "#F8FAFC")
            m.part("Cool Air", at: (cx + 13, 2.4, 29.5), size: (3.6, 0.6, 0.2), color: "#BAE6FD", material: .neon, solid: false, opacity: 0.5)
        }
    }
    // Stockroom pads (restock) and the entrance spots, on every plot.
    for k in 1...6 {
        let cx = (Float(k) - 3.5) * 44
        m.pad("Restock \(k)", x: cx - 13, z: 3, size: 2.6, color: "#A16207", tags: ["restock", "k=\(k)"])
        m.part("Entrance \(k)", at: (cx, 0.6, -2), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    }
    var r = Seeded("store")
    for q in 0..<10 { m.lamp(-150 + Float(q) * 38, -8, glow: "#FDE68A") }
    for _ in 0..<6 { m.parkedCar("Parked", x: r.range(-150, 190), z: -17, yaw: 90, color: r.pick(["#EF4444", "#3B82F6", "#F8FAFC"])) }
    m.coverFocus(x: 154, y: 2, z: 16, yaw: 200, width: 40)
}

// MARK: 128 Ore Factory Haven (Miner's Haven)

func oreFactoryHaven(_ m: MapBuilder) {
    m.sky("#1E293B", "#475569", light: 0.55, ground: "#334155")
    m.environment.skyStyle = .gradient
    m.ground(380, 200, color: "#334155", x: 22, z: 40, material: .stone)
    m.road(from: (-160, -12), to: (200, -12), width: 10, name: "Factory Road", dashed: false, color: "#1E293B")
    m.spawnRing(0, -18, radius: 4, count: 6, color: "#F97316")
    let items: [(String, Float, Float)] = [("belt1", -3, 5), ("furnace", 3, 5), ("iron", -3, 10), ("copper", 3, 10), ("heat", -3, 15), ("gold", 3, 15),
                                           ("belt2", -3, 20), ("polish", 3, 20), ("diamond", -3, 25), ("magic", 3, 25), ("star", -3, 30), ("furnace2", 3, 30)]
    let mines: [String: (Float, String)] = ["iron": (-12, "#A8A29E"), "copper": (-6, "#EA580C"), "gold": (0, "#FACC15"), "diamond": (6, "#22D3EE"),
                                            "star": (12, "#F0ABFC")]
    tycoonPlots(m, count: 6, w: 36, d: 40, floor: "#475569", padColor: "#F97316", items: items, collector: (14, 3)) { id, cx in
        if let mine = mines[id] {
            let (ox, c) = mine
            m.slab("Mine", x: cx + ox, y: 0, z: 34, w: 4, h: 4, d: 4, color: "#1F2937", material: .metal)
            m.part("Mine Core", at: (cx + ox, 2.4, 31.9), size: (2, 2, 0.2), color: c, material: .neon, solid: false)
            m.part("Mine Chute", at: (cx + ox, 3, 31), size: (1, 0.6, 1), color: c, tags: ["ty_drop", "drop=\(c)"], solid: false)
            return
        }
        switch id {
        case "belt1":
            m.slab("Conveyor", x: cx, y: 0, z: 28, w: 30, h: 0.6, d: 2.4, color: "#111827", material: .metal)
            for q in 0..<10 { m.part("Belt Stripe", at: (cx - 13.5 + Float(q) * 3, 0.62, 28), size: (0.3, 0.02, 2.2), color: "#FACC15", solid: false) }
        case "furnace":
            m.slab("Furnace", x: cx + 15, y: 0, z: 24, w: 4, h: 4, d: 6, color: "#7F1D1D", material: .brick)
            m.part("Furnace Fire", at: (cx + 12.9, 1.6, 24), size: (0.1, 1.8, 3), color: "#F97316", material: .neon, solid: false)
        case "heat":
            m.part("Heat Upgrader", at: (cx - 4, 2.2, 28), size: (1.6, 3.4, 3.6), color: "#EF4444", material: .neon, solid: false, opacity: 0.55)
        case "belt2":
            m.slab("Conveyor 2", x: cx + 13, y: 0, z: 18, w: 2.4, h: 0.6, d: 18, color: "#111827", material: .metal)
            m.part("Belt Arrow", at: (cx + 13, 0.62, 18), size: (0.6, 0.02, 14), color: "#22D3EE", solid: false)
        case "polish":
            m.part("Polish Upgrader", at: (cx + 4, 2.2, 28), size: (1.6, 3.4, 3.6), color: "#38BDF8", material: .neon, solid: false, opacity: 0.55)
        case "magic":
            m.part("Magic Upgrader", at: (cx + 9, 2.4, 28), size: (2, 3.8, 3.8), color: "#A855F7", shape: .sphere, material: .neon, solid: false, opacity: 0.5)
        default:
            m.slab("Golden Furnace", x: cx + 15, y: 4, z: 24, w: 4.4, h: 2, d: 6.4, color: "#FACC15", material: .metal)
            m.part("Golden Flame", at: (cx + 15, 6.6, 24), size: (2, 1.6, 2), color: "#FDE047", shape: .cone, material: .neon, solid: false)
        }
    }
    // Spots where mystery boxes can fall.
    var r = Seeded("orefactory")
    for q in 0..<16 {
        m.part("Box Spot \(q + 1)", at: (r.range(-140, 180), 0.6, r.pick([r.range(-40, -20), r.range(48, 120)])), size: (1, 1, 1), color: "#000000", solid: false,
               visible: false)
    }
    for _ in 0..<12 {
        m.part("Smokestack", at: (r.range(-150, 190), 8, r.range(60, 130)), size: (3, 16, 3), color: "#57534E", shape: .cylinder, material: .brick, solid: false)
    }
    m.coverFocus(x: 154, y: 2, z: 22, yaw: 210, width: 40)
}

// MARK: 129 Oil Baron Empire (Oil Empire)

func oilBaronEmpire(_ m: MapBuilder) {
    m.sky("#F59E0B", "#FDE68A", light: 0.75, ground: "#D6B77A")
    m.environment.skyStyle = .sunset
    m.ground(380, 200, color: "#E3C58D", x: 22, z: 40, material: .sand)
    m.road(from: (-160, -12), to: (200, -12), width: 10, name: "Desert Highway")
    m.spawnRing(0, -20, radius: 4, count: 6, color: "#111827")
    // The oil exchange, where everyone sells.
    m.slab("Exchange", x: 0, y: 0, z: -34, w: 20, h: 8, d: 10, color: "#1E293B")
    m.part("Exchange Board", at: (0, 6, -28.8), size: (16, 3, 0.3), color: "#22C55E", material: .neon, tags: ["price_board"], solid: false)
    m.pad("Market Pad", x: 0, z: -26, size: 4, color: "#22C55E", tags: ["market"])
    let items: [(String, Float, Float)] = [("rig1", -3, 5), ("tank1", 3, 5), ("rig2", -3, 10), ("pipe", 3, 10), ("tank2", -3, 15), ("refinery", 3, 15),
                                           ("rig3", -3, 20), ("station", 3, 20), ("tank3", -3, 25), ("rig4", 3, 25), ("refinery2", -3, 30), ("rig5", 3, 30)]
    let rigs: [String: Float] = ["rig1": -12, "rig2": -6, "rig3": 6, "rig4": 12, "rig5": 0]
    tycoonPlots(m, count: 6, w: 36, d: 40, floor: "#C2A878", padColor: "#111827", items: items, collector: (14, 3)) { id, cx in
        if let ox = rigs[id] {
            m.slab("Rig Base", x: cx + ox, y: 0, z: 34, w: 4, h: 0.6, d: 4, color: "#44403C")
            for (dx, dz) in [(-1.4, -1.4), (1.4, -1.4), (-1.4, 1.4), (1.4, 1.4)] as [(Float, Float)] {
                m.part("Rig Leg", at: (cx + ox + dx * 0.6, 4, 34 + dz * 0.6), size: (0.3, 8, 0.3), color: "#57534E", material: .metal, solid: false)
            }
            m.part("Rig Top", at: (cx + ox, 8.4, 34), size: (1.2, 1, 1.2), color: "#DC2626", material: .metal, tags: ["ty_drop", "drop=#111827"], solid: false)
            m.part("Pump Head", at: (cx + ox, 1.6, 31.6), size: (2.4, 0.6, 0.6), color: "#1F2937", material: .metal, solid: false)
            return
        }
        switch id {
        case "tank1":
            m.part("Oil Tank", at: (cx + 13, 2.5, 22), size: (5, 5, 5), color: "#E5E7EB", shape: .cylinder, material: .metal)
        case "tank2":
            m.part("Oil Tank", at: (cx + 13, 3, 14), size: (5.5, 6, 5.5), color: "#CBD5E1", shape: .cylinder, material: .metal)
        case "tank3":
            m.part("Big Oil Tank", at: (cx - 13, 3.5, 16), size: (7, 7, 7), color: "#94A3B8", shape: .cylinder, material: .metal)
        case "pipe":
            m.slab("Pipeline", x: cx, y: 0.4, z: 30, w: 30, h: 0.8, d: 0.8, color: "#78716C", material: .metal)
            m.slab("Pipeline", x: cx + 15, y: 0.4, z: 20, w: 0.8, h: 0.8, d: 20, color: "#78716C", material: .metal)
        case "refinery":
            m.slab("Refinery", x: cx - 12, y: 0, z: 26, w: 7, h: 5, d: 5, color: "#475569", material: .metal)
            m.part("Refinery Stack", at: (cx - 10, 7, 26), size: (1, 4, 1), color: "#A8A29E", shape: .cylinder, solid: false)
            m.part("Refinery Flame", at: (cx - 10, 9.4, 26), size: (0.8, 1, 0.8), color: "#F97316", shape: .cone, material: .neon, solid: false)
        case "refinery2":
            m.slab("Cracking Tower", x: cx - 12, y: 0, z: 8, w: 4, h: 12, d: 4, color: "#334155", material: .metal)
            m.part("Tower Light", at: (cx - 12, 12.4, 8), size: (0.8, 0.8, 0.8), color: "#EF4444", shape: .sphere, material: .neon, solid: false)
        default:
            m.slab("Gas Station", x: cx + 11, y: 0, z: 8, w: 8, h: 3, d: 5, color: "#F8FAFC")
            m.slab("Gas Canopy", x: cx + 11, y: 4, z: 4, w: 9, h: 0.4, d: 4, color: "#DC2626")
        }
    }
    var r = Seeded("oil")
    for _ in 0..<16 {
        m.pillar("Cactus", x: r.range(-150, 190), z: r.pick([r.range(-60, -40), r.range(55, 130)]), height: r.range(2, 4), radius: 0.4, color: "#3F6212")
    }
    m.coverFocus(x: 154, y: 3, z: 22, yaw: 210, width: 40)
}

// MARK: 130 Build Your Island (Build An Island!)

func buildYourIsland(_ m: MapBuilder) {
    m.ocean()
    m.environment.skyStyle = .clouds
    m.ground(380, 200, color: "#0EA5E9", x: 22, z: 30, material: .glass)
    // The harbour on the mainland strip in front of the islands.
    m.slab("Harbour", x: 22, y: 0, z: -14, w: 380, h: 0.4, d: 14, color: "#D6D3D1", material: .wood)
    m.spawnRing(0, -16, radius: 4, count: 6, color: "#F59E0B")
    let items: [(String, Float, Float)] = [("land1", -2, 9), ("bench", 2, 9), ("lumberbot", -2, 13), ("land2", 2, 13), ("kiln", -2, 17), ("quarry", 2, 17),
                                           ("land3", -2, 21), ("forge", 2, 21), ("mine", -2, 25), ("goldmine", 2, 25), ("castle", 0, 28)]
    tycoonPlots(m, count: 6, w: 36, d: 40, floor: "#38BDF8", padColor: "#F59E0B", items: items, collector: (13, 3)) { id, cx in
        let c: (Float, Float) = (cx, 20)
        switch id {
        case "land1":
            m.slab("Island Ring 1", x: c.0, y: 0.02, z: c.1, w: 22, h: 0.36, d: 22, color: "#FDE68A", material: .sand)
            for (i, q) in [(-8, -6), (8, 6), (-6, 8)].enumerated() {
                m.part("Node Tree", at: (c.0 + Float(q.0), 2.2, c.1 + Float(q.1)), size: (0.8, 4, 0.8), color: "#78350F", shape: .cylinder, material: .wood,
                       tags: ["rnode", "res=wood", "ring=1", "id=t1\(i)"])
            }
            m.part("Node Rock", at: (c.0 + 7, 0.9, c.1 - 7), size: (2, 1.6, 2), color: "#78716C", shape: .sphere, material: .stone, tags: ["rnode", "res=stone", "ring=1", "id=r1"])
        case "land2":
            m.slab("Island Ring 2", x: c.0, y: 0.04, z: c.1, w: 30, h: 0.36, d: 30, color: "#FCD34D", material: .sand)
            m.slab("Island Grass 2", x: c.0, y: 0.06, z: c.1, w: 18, h: 0.36, d: 18, color: "#4ADE80", material: .grass)
            for (i, q) in [(-12, -12), (12, -11), (-12, 12)].enumerated() {
                m.part("Node Rock", at: (c.0 + Float(q.0), 0.9, c.1 + Float(q.1)), size: (2.2, 1.8, 2.2), color: "#57534E", shape: .sphere, material: .stone,
                       tags: ["rnode", "res=stone", "ring=2", "id=r2\(i)"])
            }
            m.part("Node Iron", at: (c.0 + 12, 0.9, c.1 + 12), size: (2, 1.6, 2), color: "#D6D3D1", shape: .sphere, material: .metal, tags: ["rnode", "res=iron", "ring=2", "id=i2"])
        case "land3":
            m.slab("Island Ring 3", x: c.0, y: 0.08, z: c.1, w: 36, h: 0.36, d: 38, color: "#FDE68A", material: .sand)
            m.slab("Island Grass 3", x: c.0, y: 0.1, z: c.1, w: 26, h: 0.36, d: 26, color: "#22C55E", material: .grass)
            for (i, q) in [(-16, -16), (16, 16)].enumerated() {
                m.part("Node Gold", at: (c.0 + Float(q.0), 0.9, c.1 + Float(q.1)), size: (1.8, 1.4, 1.8), color: "#FACC15", shape: .sphere, material: .metal,
                       tags: ["rnode", "res=gold", "ring=3", "id=g3\(i)"])
            }
            m.part("Node Iron", at: (c.0 - 16, 0.9, c.1 + 16), size: (2, 1.6, 2), color: "#D6D3D1", shape: .sphere, material: .metal, tags: ["rnode", "res=iron", "ring=3", "id=i3"])
            m.pine(c.0 + 16, c.1 - 16, y: 0.4, height: 5, leaves: "#15803D")
        case "bench":
            m.slab("Workbench", x: c.0 - 6, y: 0.4, z: c.1 + 2, w: 3, h: 1, d: 1.6, color: "#A16207", material: .wood)
        case "lumberbot":
            m.part("Lumber Bot", at: (c.0 - 9, 1.6, c.1 - 2), size: (1.6, 2.4, 1.6), color: "#F59E0B", shape: .cylinder, material: .metal, tags: ["ty_drop", "drop=#92400E"],
                   solid: false)
        case "kiln":
            m.slab("Kiln", x: c.0 + 6, y: 0.4, z: c.1 + 2, w: 3, h: 2.6, d: 3, color: "#B91C1C", material: .brick)
        case "quarry":
            m.part("Quarry Drill", at: (c.0 + 9, 2, c.1 - 3), size: (1.2, 3.4, 1.2), color: "#64748B", material: .metal, tags: ["ty_drop", "drop=#A8A29E"], solid: false)
        case "forge":
            m.slab("Forge", x: c.0, y: 0.4, z: c.1 + 8, w: 4, h: 2.4, d: 3, color: "#1F2937", material: .metal)
            m.part("Forge Fire", at: (c.0, 1.6, c.1 + 6.4), size: (2, 0.8, 0.1), color: "#F97316", material: .neon, solid: false)
        case "mine":
            m.slab("Iron Mine", x: c.0 - 12, y: 0.4, z: c.1 + 4, w: 4, h: 3, d: 4, color: "#44403C", material: .stone)
            m.part("Mine Cart", at: (c.0 - 12, 3.8, c.1 + 4), size: (1, 0.8, 1), color: "#D6D3D1", tags: ["ty_drop", "drop=#D6D3D1"], solid: false)
        case "goldmine":
            m.slab("Gold Mine", x: c.0 + 12, y: 0.4, z: c.1 + 4, w: 4, h: 3, d: 4, color: "#78350F", material: .stone)
            m.part("Gold Glow", at: (c.0 + 12, 3.8, c.1 + 4), size: (1, 0.8, 1), color: "#FACC15", material: .neon, tags: ["ty_drop", "drop=#FACC15"], solid: false)
        default:
            m.slab("Castle", x: c.0, y: 0.4, z: c.1 + 14, w: 12, h: 6, d: 6, color: "#E7E5E4", material: .stone)
            for x in [-6, 6] as [Float] {
                m.part("Castle Tower", at: (c.0 + x, 4.5, c.1 + 14), size: (3, 9, 3), color: "#D6D3D1", shape: .cylinder, material: .stone)
                m.part("Castle Flag", at: (c.0 + x, 10, c.1 + 14), size: (1.4, 1, 0.1), color: "#EF4444", material: .neon, solid: false)
            }
        }
    }
    // Every island has a small grass start, a trader and a first tree.
    for k in 1...6 {
        let cx = (Float(k) - 3.5) * 44
        m.slab("Island Start \(k)", x: cx, y: 0.1, z: 20, w: 12, h: 0.4, d: 12, color: "#4ADE80", material: .grass)
        m.part("Start Tree \(k)", at: (cx - 3, 2.4, 22), size: (0.8, 4, 0.8), color: "#78350F", shape: .cylinder, material: .wood,
               tags: ["rnode", "res=wood", "ring=0", "id=t0"])
        m.part("Start Rock \(k)", at: (cx + 3, 1.1, 18), size: (1.6, 1.3, 1.6), color: "#78716C", shape: .sphere, material: .stone,
               tags: ["rnode", "res=stone", "ring=0", "id=r0"])
        m.pad("Trader \(k)", x: cx - 13, z: 3, size: 2.8, color: "#22D3EE", tags: ["trade", "k=\(k)"])
        m.part("Trader Boat", at: (cx - 13, 0.6, -2), size: (3, 1, 6), color: "#A16207", material: .wood, solid: false)
    }
    m.coverFocus(x: 154, y: 2, z: 20, yaw: 210, width: 40)
}

// MARK: 131 Cruise Ship Tycoon (Cruise Line Tycoon)

func cruiseShipTycoon(_ m: MapBuilder) {
    m.ocean()
    m.environment.skyStyle = .clouds
    m.slab("Pier", x: 22, y: -0.4, z: -10, w: 380, h: 0.5, d: 20, color: "#A8A29E", material: .wood)
    m.spawnRing(0, -14, radius: 4, count: 6, color: "#0EA5E9")
    m.shop("Ticket Office", x: -30, z: -16, w: 12, d: 6, color: "#E0F2FE", sign: "#0284C7", facing: 1)
    let items: [(String, Float, Float)] = [("deck", -2, 6), ("cabins", 2, 6), ("pool", -2, 11), ("restaurant", 2, 11), ("deck2", -2, 16), ("slide", 2, 16),
                                           ("theater", -2, 21), ("spa", 2, 21), ("bridge", -2, 26), ("engine", 2, 26), ("helipad", 0, 31)]
    tycoonPlots(m, count: 6, w: 22, d: 46, gap: 22, floor: "#F8FAFC", padColor: "#0EA5E9", items: items, collector: (8, 3)) { id, cx in
        switch id {
        case "deck":
            m.slab("Wood Deck", x: cx, y: 0.04, z: 23, w: 20, h: 0.2, d: 40, color: "#D6A77A", material: .wood)
        case "cabins":
            for q in 0..<4 {
                m.slab("Cabin", x: cx - 8, y: 0.2, z: 8 + Float(q) * 8, w: 4, h: 3, d: 6, color: "#E0F2FE")
                m.part("Cabin Window", at: (cx - 10.05, 1.8, 8 + Float(q) * 8), size: (0.1, 1, 1.4), color: "#38BDF8", material: .glass, solid: false)
            }
        case "pool":
            m.slab("Pool Edge", x: cx + 5, y: 0.2, z: 18, w: 8, h: 0.6, d: 10, color: "#F8FAFC")
            m.part("Pool Water", at: (cx + 5, 0.82, 18), size: (7, 0.1, 9), color: "#38BDF8", material: .glass, solid: false, opacity: 0.8)
        case "restaurant":
            m.slab("Restaurant", x: cx + 5, y: 0.2, z: 8, w: 7, h: 3, d: 7, color: "#FDE68A")
            m.part("Restaurant Sign", at: (cx + 5, 3.6, 4.4), size: (5, 0.8, 0.2), color: "#F97316", material: .neon, tags: ["ty_drop", "drop=#F97316"], solid: false)
        case "deck2":
            m.slab("Upper Deck", x: cx, y: 3.2, z: 30, w: 20, h: 0.4, d: 14, color: "#F8FAFC")
            for (x, z) in [(-9, 24), (9, 24), (-9, 36), (9, 36)] as [(Float, Float)] {
                m.slab("Deck Post", x: cx + x, y: 0.2, z: z, w: 0.5, h: 3, d: 0.5, color: "#CBD5E1")
            }
        case "slide":
            m.part("Water Slide", at: (cx + 6, 5, 34), size: (1.4, 0.4, 12), color: "#F472B6", material: .neon, solid: false, rotation: (25, 0, 0))
            m.part("Slide Tower", at: (cx + 6, 5.5, 39), size: (2, 3, 2), color: "#EC4899", solid: false)
        case "theater":
            m.slab("Theater", x: cx - 5, y: 3.6, z: 30, w: 8, h: 3.4, d: 10, color: "#7C3AED")
            m.part("Theater Lights", at: (cx - 5, 7.2, 25), size: (6, 0.4, 0.2), color: "#FACC15", material: .neon, tags: ["ty_drop", "drop=#A855F7"], solid: false)
        case "spa":
            m.part("Hot Tub", at: (cx + 5, 3.9, 27), size: (3, 0.6, 3), color: "#2DD4BF", shape: .cylinder, material: .glass, solid: false, opacity: 0.8)
        case "bridge":
            m.slab("Captain Bridge", x: cx, y: 3.6, z: 40, w: 12, h: 3, d: 4, color: "#F8FAFC")
            m.part("Bridge Glass", at: (cx, 5.2, 42.05), size: (10, 1.2, 0.1), color: "#7DD3FC", material: .glass, solid: false)
        case "engine":
            m.part("Funnel", at: (cx, 9, 36), size: (3, 5, 3), color: "#DC2626", shape: .cylinder, solid: false)
            m.part("Funnel Top", at: (cx, 11.6, 36), size: (3.2, 0.6, 3.2), color: "#111827", shape: .cylinder, tags: ["ty_drop", "drop=#E5E7EB"], solid: false)
        default:
            m.part("Helipad", at: (cx, 7.1, 41), size: (7, 0.2, 7), color: "#1F2937", shape: .cylinder, solid: false)
            m.part("Helipad H", at: (cx, 7.25, 41), size: (2, 0.05, 3), color: "#FACC15", solid: false)
        }
    }
    // The hulls under every ship (and the showcase).
    for k in 1...7 {
        let cx = (Float(k) - 3.5) * 44
        m.slab("Hull", x: cx, y: -3, z: 23, w: 22, h: 3, d: 46, color: "#1E3A8A")
        m.part("Bow", at: (cx, -1.5, 48), size: (22, 3, 6), color: "#1E3A8A", shape: .cone, solid: false, rotation: (90, 0, 0))
        m.part("Hull Stripe", at: (cx, -0.4, 23), size: (22.1, 0.4, 46.1), color: "#DC2626", solid: false)
    }
    m.coverFocus(x: 154, y: 3, z: 20, yaw: 210, width: 36)
}

// MARK: 132 Build a Zoo Park (Build A Zoo)

/// The four habitats in a zoo plot: id, centre offset (x, z), floor colour.
let zooHabitats: [(String, Float, Float, String)] = [("savanna", -9, 12, "#FCD34D"), ("jungle", 9, 12, "#16A34A"), ("ice", -9, 30, "#E0F2FE"), ("ocean", 9, 30, "#0EA5E9")]

/// Body and head colours of the animals standing in the showcase zoo.
let zooShowcase: [String: (String, String)] = ["savanna": ("#FBBF24", "#B45309"), "jungle": ("#78350F", "#D6A77A"), "ice": ("#1E293B", "#F8FAFC"),
                                               "ocean": ("#64748B", "#94A3B8")]

func buildAZooPark(_ m: MapBuilder) {
    m.day(ground: "#4D7C0F")
    m.environment.skyStyle = .clouds
    m.ground(380, 200, color: "#65A30D", x: 22, z: 40, material: .grass)
    m.road(from: (-160, -12), to: (200, -12), width: 10, name: "Zoo Road", dashed: false, color: "#A8A29E")
    m.spawnRing(0, -16, radius: 4, count: 6, color: "#F59E0B")
    m.shop("Egg House", x: 0, z: -28, w: 14, d: 8, color: "#FEF3C7", sign: "#F59E0B", facing: 1)
    m.pad("Egg Pad", x: 0, z: -20, size: 3.4, color: "#F59E0B", tags: ["zooeggs"])
    let items: [(String, Float, Float)] = [("gate", 0, 5), ("path", -2, 4), ("savanna", 2, 4), ("jungle", 0, 21), ("snack", -2, 22.5), ("ice", 2, 22.5),
                                           ("ocean", 0, 24), ("gift", -2, 25.5), ("fountain", 2, 25.5), ("tunnel", 0, 27)]
    tycoonPlots(m, count: 6, w: 36, d: 42, floor: "#86EFAC", padColor: "#F59E0B", items: items, collector: (14, 3)) { id, cx in
        if let h = zooHabitats.first(where: { $0.0 == id }) {
            let (_, ox, oz, color) = h
            let x = cx + ox, z = oz
            m.slab("Habitat Floor", x: x, y: 0.04, z: z, w: 14, h: 0.2, d: 14, color: color, material: id == "ice" ? .ice : (id == "ocean" ? .glass : .grass))
            m.fence(from: (x - 7, z - 7), to: (x + 7, z - 7), color: "#92400E")
            m.fence(from: (x - 7, z + 7), to: (x + 7, z + 7), color: "#92400E")
            m.fence(from: (x - 7, z - 7), to: (x - 7, z + 7), color: "#92400E")
            m.fence(from: (x + 7, z - 7), to: (x + 7, z + 7), color: "#92400E")
            switch id {
            case "savanna": m.tree(x + 4, z + 4, y: 0.2, height: 4, leaves: "#65A30D")
            case "jungle": m.pine(x - 4, z + 4, y: 0.2, height: 5, leaves: "#14532D")
            case "ice": m.part("Iceberg", at: (x + 4, 1.2, z + 4), size: (3, 2.4, 3), color: "#F8FAFC", shape: .cone, material: .ice, solid: false)
            default: m.part("Tank Glass", at: (x, 1.5, z - 7), size: (14, 3, 0.2), color: "#7DD3FC", material: .glass, solid: false, opacity: 0.4)
            }
            return
        }
        switch id {
        case "gate":
            m.part("Zoo Arch", at: (cx, 5, 1), size: (12, 1.2, 1), color: "#F59E0B", material: .neon, solid: false)
            for x in [-6, 6] as [Float] { m.slab("Arch Post", x: cx + x, y: 0, z: 1, w: 0.8, h: 5, d: 0.8, color: "#92400E", material: .wood) }
        case "path":
            m.slab("Zoo Path", x: cx, y: 0.03, z: 21, w: 4, h: 0.1, d: 40, color: "#D6D3D1")
            m.slab("Zoo Path", x: cx, y: 0.03, z: 21, w: 32, h: 0.1, d: 3, color: "#D6D3D1")
        case "snack":
            m.slab("Snack Bar", x: cx - 15, y: 0, z: 21, w: 4, h: 3, d: 4, color: "#F87171")
            m.part("Snack Sign", at: (cx - 15, 3.4, 18.9), size: (3, 0.6, 0.1), color: "#FDE68A", material: .neon, tags: ["ty_drop", "drop=#F87171"], solid: false)
        case "gift":
            m.slab("Gift Shop", x: cx + 15, y: 0, z: 21, w: 4, h: 3, d: 4, color: "#C4B5FD")
            m.part("Gift Sign", at: (cx + 15, 3.4, 18.9), size: (3, 0.6, 0.1), color: "#F472B6", material: .neon, tags: ["ty_drop", "drop=#A855F7"], solid: false)
        case "fountain":
            m.part("Zoo Fountain", at: (cx, 0.5, 21), size: (3, 1, 3), color: "#7DD3FC", shape: .cylinder, material: .glass, solid: false, opacity: 0.7)
        default:
            m.part("Aquarium Tunnel", at: (cx + 9, 2, 38.5), size: (4, 14, 4), color: "#38BDF8", shape: .cylinder, material: .glass, solid: false,
                   rotation: (0, 0, 90), opacity: 0.4)
        }
    }
    // Animal figures: three spots in every habitat of every plot, shown by the script.
    for k in 1...7 {
        let cx = (Float(k) - 3.5) * 44
        for (hid, ox, oz, _) in zooHabitats {
            for s in 0..<3 {
                let x = cx + ox - 4 + Float(s) * 4, z = oz - 2 + Float(s % 2) * 2
                let shown = k == 7
                // The showcase zoo wears real colours; the others are recoloured by the script.
                let look = shown ? (zooShowcase[hid] ?? ("#A16207", "#A16207")) : ("#A16207", "#A16207")
                m.group("zoo\(k)_\(hid)_\(s + 1)", shown: shown) {
                    m.part("Animal Body", at: (x, 1, z), size: (1.8, 1.2, 2.4), color: look.0, shape: .sphere, tags: ["animal_body"], solid: false)
                    m.part("Animal Head", at: (x, 1.9, z + 1.2), size: (0.9, 0.9, 0.9), color: look.1, shape: .sphere, tags: ["animal_head"], solid: false)
                }
            }
        }
    }
    m.coverFocus(x: 154, y: 2, z: 20, yaw: 210, width: 40)
}
