import Foundation

// Building maps in code.
//
// Every world in this catalogue is built here rather than by hand in Studio,
// so that eighty maps share one set of parts (a house, a tree, an arena wall)
// and a fix to a part fixes every map that uses it. The output is an ordinary
// `WorldDocument`: open any game in Studio and it is plain blocks.

typealias V = (Float, Float, Float)

final class MapBuilder {
    private(set) var blocks: [BlockData] = []
    var environment = EnvironmentSettings()

    // MARK: Primitives

    /// One block. `at` is the centre, `size` the full extent.
    @discardableResult
    func part(_ name: String, at p: V, size s: V, color: String, shape: BlockShape = .box,
              material: MaterialKind = .plastic, behavior: BlockBehavior = .none, tags: [String] = [],
              solid: Bool = true, visible: Bool = true, rotation r: V? = nil, opacity: Float = 1,
              score: Int = 0, gimmick: GimmickSettings = .default) -> UUID {
        var block = BlockData(
            name: name,
            shape: shape,
            transform: Transform3D(position: Vec3(p.0, p.1, p.2),
                                   rotation: r.map { Quat.euler(degrees: Vec3($0.0, $0.1, $0.2)) } ?? .identity,
                                   scale: Vec3(s.0, s.1, s.2)),
            color: Self.color(color).withAlpha(opacity),
            material: material,
            hasCollision: solid,
            isVisible: visible,
            behavior: behavior,
            scoreValue: score,
            tags: tags,
            gimmick: gimmick
        )
        block.isAnchored = true
        blocks.append(block)
        return block.id
    }

    /// A box sitting on `y` (its bottom face), rather than centred on it.
    @discardableResult
    func slab(_ name: String, x: Float, y: Float, z: Float, w: Float, h: Float, d: Float, color: String,
              material: MaterialKind = .plastic, behavior: BlockBehavior = .none, tags: [String] = [],
              solid: Bool = true, opacity: Float = 1, rotation: V? = nil) -> UUID {
        part(name, at: (x, y + h / 2, z), size: (w, h, d), color: color, material: material,
             behavior: behavior, tags: tags, solid: solid, rotation: rotation, opacity: opacity)
    }

    static func color(_ text: String) -> ColorRGBA {
        if let named = ScriptColor.named[text.lowercased()], let c = ColorRGBA(hex: named) { return c }
        guard let c = ColorRGBA(hex: text) else { fatalError("bad colour \(text)") }
        return c
    }

    func block(named name: String) -> BlockData? { blocks.first { $0.name == name } }

    /// Everything built inside `build` gets `tag`, and starts hidden and
    /// walk-through unless `shown` — scenery a script swaps in and out.
    /// Blocks that were solid also get "solid", so the script knows which to
    /// make solid again when it shows them.
    func group(_ tag: String, shown: Bool, _ build: () -> Void) {
        let before = blocks.count
        build()
        for i in before..<blocks.count {
            blocks[i].tags.append(tag)
            if blocks[i].hasCollision { blocks[i].tags.append("solid") }
            if !shown {
                blocks[i].isVisible = false
                blocks[i].hasCollision = false
            }
        }
    }

    func setTeleport(from source: UUID, to target: UUID) {
        guard let i = blocks.firstIndex(where: { $0.id == source }) else { return }
        blocks[i].gimmick.teleportTargetID = target
    }

    // MARK: Ground and sky

    /// The floor everything stands on: its top face at y = 0.
    @discardableResult
    func ground(_ w: Float, _ d: Float, color: String, name: String = "Ground", y: Float = 0,
                x: Float = 0, z: Float = 0, material: MaterialKind = .matte, tags: [String] = ["ground"]) -> UUID {
        part(name, at: (x, y - 0.5, z), size: (w, 1, d), color: color, material: material, tags: tags)
    }

    func sky(_ top: String, _ bottom: String, light: Float = 0.6, ground: String? = nil, showGround: Bool = true,
             sunPitch: Float = -45, gravity: Float = -9.81, fall: Float = -40) {
        environment.skyTop = Self.color(top)
        environment.skyBottom = Self.color(bottom)
        environment.ambientIntensity = light
        environment.sunPitchDegrees = sunPitch
        environment.gravity = gravity
        environment.killPlaneHeight = fall
        environment.showGroundPlane = showGround
        if let ground { environment.groundColor = Self.color(ground) }
    }

    func day(ground: String = "#4C8C4A") { sky("#5AB2FF", "#CDEBFF", light: 0.75, ground: ground) }
    func sunset(ground: String = "#6B4F3A") { sky("#FF8A5B", "#FFD29D", light: 0.6, ground: ground, sunPitch: -15) }
    func night(ground: String = "#1E2A22") { sky("#060A1A", "#1B2340", light: 0.25, ground: ground, sunPitch: -20) }
    func dusk(ground: String = "#2A2233") { sky("#2B1B4A", "#6B3E7A", light: 0.4, ground: ground, sunPitch: -12) }
    func indoor(ground: String = "#222222") { sky("#101014", "#202028", light: 0.55, ground: ground, showGround: false) }
    func space() { sky("#02030A", "#0B1030", light: 0.5, showGround: false, fall: -60) }
    func ocean() { sky("#4FB6FF", "#D4F1FF", light: 0.75, ground: "#1D6FB8") }

    // MARK: Spawn

    /// A spawn pad whose top is at `y`.
    @discardableResult
    func spawn(_ x: Float, _ z: Float, y: Float = 0, name: String = "Spawn", color: String = "#22D3EE") -> UUID {
        part(name, at: (x, y + 0.1, z), size: (2.4, 0.2, 2.4), color: color, shape: .cylinder,
             material: .neon, behavior: .spawn)
    }

    /// Several spawn pads in a ring, so a full lobby does not stack up.
    func spawnRing(_ cx: Float, _ cz: Float, y: Float = 0, radius: Float = 4, count: Int = 6, name: String = "Spawn",
                   color: String = "#22D3EE") {
        for i in 0..<count {
            let a = Float(i) / Float(count) * 2 * .pi
            spawn(cx + cos(a) * radius, cz + sin(a) * radius, y: y, name: count == 1 ? name : "\(name) \(i + 1)", color: color)
        }
    }

    // MARK: Scenery

    func tree(_ x: Float, _ z: Float, y: Float = 0, height: Float = 4, leaves: String = "#2E8B3E",
              trunk: String = "#7A4A24", tags: [String] = ["tree"], name: String = "Tree") {
        part("\(name) Trunk", at: (x, y + height / 2, z), size: (0.6, height, 0.6), color: trunk, shape: .cylinder, tags: tags)
        part(name, at: (x, y + height + 0.8, z), size: (2.8, 2.6, 2.8), color: leaves, shape: .sphere, material: .matte, tags: tags)
    }

    func pine(_ x: Float, _ z: Float, y: Float = 0, height: Float = 6, leaves: String = "#1F5E3A", tags: [String] = ["tree"],
              name: String = "Pine") {
        part("\(name) Trunk", at: (x, y + 0.8, z), size: (0.5, 1.6, 0.5), color: "#5A3A1E", shape: .cylinder, tags: tags)
        part(name, at: (x, y + 1.6 + height / 2, z), size: (2.6, height, 2.6), color: leaves, shape: .cone, material: .matte, tags: tags)
    }

    func rock(_ x: Float, _ z: Float, y: Float = 0, size: Float = 1.5, color: String = "#7C7C84", name: String = "Rock") {
        part(name, at: (x, y + size * 0.35, z), size: (size, size * 0.7, size * 0.9), color: color, shape: .sphere, material: .matte)
    }

    func lamp(_ x: Float, _ z: Float, y: Float = 0, glow: String = "#FFE9A8", name: String = "Lamp") {
        part("\(name) Post", at: (x, y + 1.6, z), size: (0.2, 3.2, 0.2), color: "#3A3A44", shape: .cylinder, material: .metal)
        part(name, at: (x, y + 3.4, z), size: (0.6, 0.6, 0.6), color: glow, shape: .sphere, material: .neon, solid: false)
    }

    func water(_ x: Float, _ z: Float, w: Float, d: Float, y: Float = 0, name: String = "Water", color: String = "#2F8FE0",
               depth: Float = 0.2, tags: [String] = ["water"]) {
        part(name, at: (x, y - depth / 2, z), size: (w, depth, d), color: color, material: .glass,
             behavior: .trigger, tags: tags, solid: false, opacity: 0.8)
    }

    /// A road strip with dashed centre marks.
    func road(from a: (Float, Float), to b: (Float, Float), width: Float = 6, y: Float = 0.02, name: String = "Road",
              dashed: Bool = true, color: String = "#34353B") {
        let dx = b.0 - a.0, dz = b.1 - a.1
        let length = (dx * dx + dz * dz).squareRoot()
        let yaw = atan2(dx, dz) * 180 / .pi
        part(name, at: ((a.0 + b.0) / 2, y, (a.1 + b.1) / 2), size: (width, 0.04, length), color: color,
             material: .matte, rotation: (0, yaw, 0))
        let dashes = dashed ? Int(length / 5) : 0
        if dashes > 0 {
            for i in 0..<dashes {
                let t = (Float(i) + 0.5) / Float(dashes)
                part("\(name) Line", at: (a.0 + dx * t, y + 0.03, a.1 + dz * t), size: (0.25, 0.02, 2), color: "#F5D547",
                     material: .neon, solid: false, rotation: (0, yaw, 0))
            }
        }
    }

    /// A parked car made of blocks, the same shape as the car a player rides:
    /// body, windshield, seats, wheels, lights. Front toward `yaw`.
    func parkedCar(_ name: String, x: Float, z: Float, yaw: Float = 0, color: String, sporty: Bool = false) {
        let turn = Quat.yaw(degrees: yaw)
        func at(_ dx: Float, _ dy: Float, _ dz: Float) -> V {
            let p = turn.act(Vec3(dx, dy, dz))
            return (x + p.x, p.y, z + p.z)
        }
        let length: Float = sporty ? 4 : 3.6
        let height: Float = sporty ? 0.45 : 0.6
        part("\(name) Body", at: at(0, sporty ? 0.42 : 0.5, 0), size: (1.9, height, length), color: color, rotation: (0, yaw, 0))
        part("\(name) Glass", at: at(0, sporty ? 0.78 : 1.0, sporty ? -0.5 : -0.6), size: (1.7, 0.45, 0.08), color: "#BAE6FD",
             solid: false, rotation: (sporty ? -40 : -26, yaw, 0))
        part("\(name) Seat", at: at(0, sporty ? 0.75 : 0.95, 0.55), size: (1.5, 0.45, 0.14), color: "#1F2937", solid: false, rotation: (0, yaw, 0))
        for sx in [Float(-1), 1] {
            for sz in [Float(-1), 1] {
                part("\(name) Wheel", at: at(sx * 0.95, 0.36, sz * (sporty ? 1.3 : 1.15)), size: (0.72, 0.32, 0.72), color: "#1F2023",
                     shape: .cylinder, solid: false, rotation: (0, yaw, 90))
            }
        }
        part("\(name) Lights", at: at(0, sporty ? 0.5 : 0.62, -length / 2 - 0.02), size: (1.5, 0.14, 0.05), color: "#FEF9C3",
             material: .neon, solid: false, rotation: (0, yaw, 0))
        if sporty {
            part("\(name) Spoiler", at: at(0, 0.98, length / 2 - 0.2), size: (1.8, 0.07, 0.4), color: color, solid: false, rotation: (0, yaw, 0))
        }
    }

    func fence(from a: (Float, Float), to b: (Float, Float), y: Float = 0, color: String = "#C8A06A") {
        let dx = b.0 - a.0, dz = b.1 - a.1
        let length = (dx * dx + dz * dz).squareRoot()
        let yaw = atan2(dx, dz) * 180 / .pi
        part("Fence", at: ((a.0 + b.0) / 2, y + 0.9, (a.1 + b.1) / 2), size: (0.15, 0.2, length), color: color, rotation: (0, yaw, 0))
        part("Fence", at: ((a.0 + b.0) / 2, y + 0.4, (a.1 + b.1) / 2), size: (0.15, 0.2, length), color: color, rotation: (0, yaw, 0))
    }

    /// Four walls around a rectangle, open at the top.
    func walls(_ cx: Float, _ cz: Float, w: Float, d: Float, h: Float, y: Float = 0, color: String,
               thickness t: Float = 1, material: MaterialKind = .plastic, name: String = "Wall", opacity: Float = 1) {
        slab(name, x: cx, y: y, z: cz - d / 2, w: w + t, h: h, d: t, color: color, material: material, opacity: opacity)
        slab(name, x: cx, y: y, z: cz + d / 2, w: w + t, h: h, d: t, color: color, material: material, opacity: opacity)
        slab(name, x: cx - w / 2, y: y, z: cz, w: t, h: h, d: d, color: color, material: material, opacity: opacity)
        slab(name, x: cx + w / 2, y: y, z: cz, w: t, h: h, d: d, color: color, material: material, opacity: opacity)
    }

    /// A small house with a doorway on the +z side and a trigger in it, named
    /// "`name` Door", so a script can notice someone walking in.
    func house(_ name: String, x: Float, z: Float, w: Float = 8, d: Float = 8, h: Float = 3.4, y: Float = 0,
               wall: String = "#F2E6D8", roof: String = "#B5453B", floor: String = "#A8784E", door: Bool = true,
               tags: [String] = ["house"], facing: Float = 1) {
        let t: Float = 0.4
        slab("\(name) Floor", x: x, y: y, z: z, w: w, h: 0.15, d: d, color: floor, tags: tags)
        // Back and sides.
        slab("\(name) Wall", x: x, y: y, z: z - facing * d / 2, w: w, h: h, d: t, color: wall, tags: tags)
        slab("\(name) Wall", x: x - w / 2, y: y, z: z, w: t, h: h, d: d, color: wall, tags: tags)
        slab("\(name) Wall", x: x + w / 2, y: y, z: z, w: t, h: h, d: d, color: wall, tags: tags)
        // Front, with a 2 m doorway.
        let side = (w - 2) / 2
        slab("\(name) Wall", x: x - 1 - side / 2, y: y, z: z + facing * d / 2, w: side, h: h, d: t, color: wall, tags: tags)
        slab("\(name) Wall", x: x + 1 + side / 2, y: y, z: z + facing * d / 2, w: side, h: h, d: t, color: wall, tags: tags)
        slab("\(name) Wall", x: x, y: y + 2.4, z: z + facing * d / 2, w: 2, h: h - 2.4, d: t, color: wall, tags: tags)
        // Roof.
        slab("\(name) Roof", x: x, y: y + h, z: z, w: w + 1, h: 0.4, d: d + 1, color: roof, tags: tags)
        part("\(name) Roof Top", at: (x, y + h + 1.2, z), size: (w * 0.9, 1.6, d * 0.9), color: roof, shape: .cone, material: .matte)
        // Windows.
        part("\(name) Window", at: (x - w / 4 - 0.4, y + 1.7, z + facing * (d / 2 + 0.22)), size: (1.2, 1, 0.05), color: "#9ED8FF",
             material: .glass, solid: false)
        part("\(name) Window", at: (x + w / 4 + 0.4, y + 1.7, z + facing * (d / 2 + 0.22)), size: (1.2, 1, 0.05), color: "#9ED8FF",
             material: .glass, solid: false)
        if door {
            part("\(name) Door", at: (x, y + 1.1, z + facing * d / 2), size: (1.8, 2.2, 0.6), color: "#6B3F1F",
                 behavior: .trigger, tags: tags + ["door"], opacity: 0.35)
        }
    }

    /// A flat-roofed shop front with a counter.
    func shop(_ name: String, x: Float, z: Float, y: Float = 0, w: Float = 10, d: Float = 8, color: String, sign: String = "#FFFFFF",
              facing: Float = 1) {
        house(name, x: x, z: z, w: w, d: d, h: 4, y: y, wall: color, roof: "#2B2B33", floor: "#DDD6CC", tags: ["shop"], facing: facing)
        slab("\(name) Counter", x: x, y: y, z: z - facing * 1, w: w * 0.6, h: 1.1, d: 0.8, color: "#8A5A36")
        part("\(name) Sign", at: (x, y + 4.6, z + facing * (d / 2 + 0.3)), size: (w * 0.7, 0.9, 0.2), color: sign, material: .neon, solid: false)
    }

    /// Stairs going up along +x from (x, y, z).
    func stairs(_ x: Float, _ z: Float, y: Float = 0, steps: Int, rise: Float = 0.5, run: Float = 1, width: Float = 3,
                color: String, name: String = "Step") {
        for i in 0..<steps {
            slab("\(name) \(i + 1)", x: x + Float(i) * run, y: y, z: z, w: run, h: rise * Float(i + 1), d: width, color: color)
        }
    }

    /// A square arena: floor, walls and a spawn ring.
    func arena(size: Float, floor: String, wall: String, wallHeight: Float = 4, spawns: Int = 8) {
        ground(size, size, color: floor, name: "Arena Floor")
        walls(0, 0, w: size, d: size, h: wallHeight, color: wall, name: "Arena Wall")
        spawnRing(0, 0, radius: size * 0.35, count: spawns)
    }

    func crate(_ x: Float, _ z: Float, y: Float = 0, size: Float = 1.6, color: String = "#9A6B3E", name: String = "Crate") {
        slab(name, x: x, y: y, z: z, w: size, h: size, d: size, color: color)
    }

    /// A glowing pad a script listens to.
    @discardableResult
    func pad(_ name: String, x: Float, z: Float, y: Float = 0, size: Float = 3, color: String, tags: [String] = [],
             shape: BlockShape = .cylinder) -> UUID {
        part(name, at: (x, y + 0.1, z), size: (size, 0.2, size), color: color, shape: shape, material: .neon,
             behavior: .trigger, tags: tags)
    }

    /// A tall column a script can use as a marker or a target.
    @discardableResult
    func pillar(_ name: String, x: Float, z: Float, y: Float = 0, height: Float = 4, radius: Float = 0.8, color: String,
                material: MaterialKind = .plastic, tags: [String] = []) -> UUID {
        part(name, at: (x, y + height / 2, z), size: (radius * 2, height, radius * 2), color: color, shape: .cylinder,
             material: material, tags: tags)
    }

    /// A counted row of named markers, "`name` 1" … "`name` n", for scripts to
    /// find with block().
    func markers(_ name: String, points: [(Float, Float)], y: Float = 0, color: String, tags: [String] = [],
                 visible: Bool = true, size: Float = 1.2, behavior: BlockBehavior = .trigger) {
        for (i, p) in points.enumerated() {
            part("\(name) \(i + 1)", at: (p.0, y + 0.1, p.1), size: (size, 0.2, size), color: color, shape: .cylinder,
                 material: .neon, behavior: behavior, tags: tags, solid: false, visible: visible)
        }
    }

    func build(name: String, author: String) -> WorldDocument {
        var world = WorldDocument(name: name, authorName: author,
                                  createdAt: Catalogue.date, modifiedAt: Catalogue.date,
                                  environment: environment, blocks: blocks)
        world.id = Catalogue.stableID(name)
        // Stable block ids too, so regenerating a map does not churn every
        // line of its file in the repository.
        for i in world.blocks.indices {
            world.blocks[i].id = Catalogue.stableID("\(name)#\(i)")
        }
        // Teleport targets were recorded against the old ids.
        let remap = Dictionary(uniqueKeysWithValues: zip(blocks.map(\.id), world.blocks.map(\.id)))
        for i in world.blocks.indices {
            if let target = world.blocks[i].gimmick.teleportTargetID {
                world.blocks[i].gimmick.teleportTargetID = remap[target]
            }
        }
        return world
    }
}

// MARK: - Small helpers

func ring(_ count: Int, radius: Float, cx: Float = 0, cz: Float = 0, phase: Float = 0) -> [(Float, Float)] {
    (0..<count).map { i in
        let a = phase + Float(i) / Float(count) * 2 * .pi
        return (cx + cos(a) * radius, cz + sin(a) * radius)
    }
}

func grid(_ columns: Int, _ rows: Int, spacing: Float, cx: Float = 0, cz: Float = 0) -> [(Float, Float)] {
    var points: [(Float, Float)] = []
    for r in 0..<rows {
        for c in 0..<columns {
            points.append((cx + (Float(c) - Float(columns - 1) / 2) * spacing, cz + (Float(r) - Float(rows - 1) / 2) * spacing))
        }
    }
    return points
}

/// A repeatable pseudo-random sequence, so a regenerated map is identical.
struct Seeded {
    private var state: UInt64
    init(_ seed: String) {
        var h: UInt64 = 1469598103934665603
        for b in seed.utf8 { h = (h ^ UInt64(b)) &* 1099511628211 }
        state = h | 1
    }
    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
    mutating func unit() -> Float { Float(next() % 1_000_000) / 1_000_000 }
    mutating func range(_ a: Float, _ b: Float) -> Float { a + (b - a) * unit() }
    mutating func int(_ a: Int, _ b: Int) -> Int { a + Int(next() % UInt64(b - a + 1)) }
    mutating func pick<T>(_ list: [T]) -> T { list[int(0, list.count - 1)] }
}
