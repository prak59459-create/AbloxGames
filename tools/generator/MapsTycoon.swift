import Foundation

// Games 126–140: tycoons, each after a tycoon popular on Roblox
// (docs/research-150.md). They run on lib/kit_tycoon.absc: claim a plot,
// step on pads to buy the next building, collect what it earns.

let tycoonGames: [Game] = [
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
