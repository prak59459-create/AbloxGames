import Foundation

/// Draws a game's cover picture from its own world.
///
/// Every cover is the game itself, seen from above at an angle with a few
/// players standing at the spawn — not a picture taken from somewhere else,
/// so it always matches what you get when you press Play, it is ours to
/// publish, and it follows the world whenever the map changes.
///
/// A small software renderer: triangles, a depth buffer, shading from the
/// world's own sun and sky with shadows cast by that sun, soft darkening in
/// corners, a glow around neon, fog, outlines where depth jumps, and 3×
/// supersampling. The generator runs on Linux with no graphics stack, and
/// this needs nothing but arithmetic.
enum Cover {

    static let width = 800
    static let height = 450
    private static let supersample = 3

    struct Picture {
        let width: Int
        let height: Int
        /// RGB, 8 bits a channel, rows top to bottom.
        let rgb: [UInt8]

        /// A short name that changes whenever the picture does, so the file
        /// name can carry it and the app's cache never shows a stale cover.
        var fingerprint: String {
            var hash: UInt64 = 0xcbf2_9ce4_8422_2325
            for byte in rgb { hash = (hash ^ UInt64(byte)) &* 0x1000_0000_01b3 }
            return String(format: "%08llx", hash & 0xffff_ffff)
        }
    }

    // MARK: Scene

    private struct Triangle {
        var a: Vec3
        var b: Vec3
        var c: Vec3
        var color: ColorRGBA
        var unlit: Bool
    }

    static func render(_ world: WorldDocument, characters: [PlayerSnapshot], seed: String) -> Picture {
        var random = SeededRandom(seed: seed)
        let lookup = Dictionary(world.blocks.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

        var opaque: [Triangle] = []
        var clear: [Triangle] = []
        var centres: [Vec3] = []
        // Triggers drawn almost clear (checkpoint rings, zones) are all but
        // invisible in the game too; in a still picture they read as smudges.
        for block in world.blocks where block.isVisible && block.color.a > 0.2 && !isLid(block) {
            let t = WorldIndex.worldTransform(of: block, lookup: lookup)
            let unlit = block.material.isUnlit
            let alpha = block.color.a * block.material.alphaScale
            var color = block.color
            color.a = alpha
            let tris = mesh(block.shape).map { tri in
                Triangle(a: place(tri.0, t), b: place(tri.1, t), c: place(tri.2, t), color: color, unlit: unlit)
            }
            if alpha < 0.98 { clear += tris } else { opaque += tris }
            // What the camera frames: the built things, not the ground, and
            // not what hangs in the sky (a moon) either.
            let footprint = max(t.scale.x, t.scale.z)
            if footprint < 60 && !block.tags.contains("sky") { centres.append(t.position) }
        }

        // Everyone in the world a few seconds in: the players at the spawn,
        // spread out a little, and whatever the scripts made — shopkeepers,
        // zombies, cars in traffic.
        let spawns = world.spawnBlocks
        for character in characters {
            var feet = character.position
            var yaw = character.yawDegrees
            if !character.isNPC {
                feet = feet + Vec3(random.float(-2.4, 2.4), -1, random.float(-2.4, 2.4))
                yaw = random.float(0, 360)
            }
            opaque += avatar(character.profile, at: feet, yaw: yaw)
        }

        let environment = world.environment
        if environment.showGroundPlane {
            let g = environment.groundColor
            let s: Float = 3000
            let y: Float = -0.05
            opaque.append(Triangle(a: Vec3(-s, y, -s), b: Vec3(s, y, -s), c: Vec3(s, y, s), color: g, unlit: false))
            opaque.append(Triangle(a: Vec3(-s, y, -s), b: Vec3(s, y, s), c: Vec3(-s, y, s), color: g, unlit: false))
        }

        let tops = world.blocks.filter { $0.isVisible && !isLid($0) && !$0.tags.contains("sky") }.map { block -> Float in
            let t = WorldIndex.worldTransform(of: block, lookup: lookup)
            return t.position.y + t.scale.y / 2
        }
        // A map can say what to show: an invisible block named "Cover Focus"
        // is the middle of the picture, its width how much to fit in, and a
        // "yaw=…" tag the side it is seen from.
        var camera = frame(centres: centres, tops: tops, spawn: spawns.isEmpty ? nil : world.spawnPosition(forPlayerIndex: 0))
        if let focus = world.blocks.first(where: { $0.name == "Cover Focus" }) {
            let yaw = focus.tags.compactMap { $0.hasPrefix("yaw=") ? Float($0.dropFirst(4)) : nil }.first ?? 35
            // "pitch=…" looks down more steeply: into a corridor, a maze.
            let pitch = focus.tags.compactMap { $0.hasPrefix("pitch=") ? Float($0.dropFirst(6)) : nil }.first ?? 24
            let middle = focus.transform.position
            let radius = focus.transform.scale.x / 2
            // The width is the most to fit in; if what is inside it sits
            // closer together, the camera comes in to it.
            let inside = centres.filter { c in
                let dx = c.x - middle.x, dz = c.z - middle.z
                return dx * dx + dz * dz < radius * radius
            }
            let tallest = inside.map(\.y).max() ?? middle.y
            camera = inside.count >= 3
                ? fitted(at: middle, radius: radius, yawDegrees: yaw, pitchDegrees: pitch, points: inside,
                         summit: Vec3(middle.x, tallest, middle.z), widest: 1)
                : look(at: middle, radius: radius, yawDegrees: yaw, pitchDegrees: pitch)
        }
        var canvas = Canvas(width: width * supersample, height: height * supersample, camera: camera, environment: environment)
        // The sun's view first: everything solid casts a shadow.
        var shadows = ShadowMap(toSun: canvas.toSun, focus: camera.focus, radius: camera.radius)
        for tri in opaque { shadows.add(tri) }
        canvas.shadows = shadows
        canvas.paintSky()
        for tri in opaque { canvas.draw(tri, blend: false) }
        // See-through things last, farthest first, without hiding what is behind.
        let eye = camera.eye
        let sorted = clear.sorted {
            (($0.a + $0.b + $0.c) * (1.0 / 3) - eye).lengthSquared > (($1.a + $1.b + $1.c) * (1.0 / 3) - eye).lengthSquared
        }
        for tri in sorted { canvas.draw(tri, blend: true) }
        canvas.occlusion()
        canvas.outline()
        return canvas.downsampled(by: supersample)
    }

    /// Roofs and ceilings are left off, dollhouse-style: the inside of a
    /// hospital or a school is the part worth showing.
    private static func isLid(_ block: BlockData) -> Bool {
        let name = block.name.lowercased()
        return name.contains("roof") || name.contains("ceiling")
    }

    private static func place(_ v: Vec3, _ t: Transform3D) -> Vec3 {
        t.position + t.rotation.act(v * t.scale)
    }

    // MARK: Framing

    struct Camera {
        let eye: Vec3
        let forward: Vec3
        let right: Vec3
        let up: Vec3
        /// What the picture is about, and how much of it — the shadow map
        /// covers this much rather than the whole 3 km ground.
        let focus: Vec3
        let radius: Float
        /// Focal length in pixels at the supersampled size.
        var focal: Float = 0
    }

    /// Three-quarters from above, around the middle of what was built. The
    /// middle is taken from the middle 80% of the blocks, so one far-off
    /// marker or a lone pillar at the edge does not shrink everything else.
    private static func frame(centres all: [Vec3], tops: [Float], spawn: Vec3?) -> Camera {
        var target = spawn ?? .zero
        var radius: Float = 20
        // A world made of several far-apart areas (stages, islands) is drawn
        // around its busiest one, not as specks across an empty plain.
        var centres = all
        if all.count >= 12 {
            var cells: [String: (count: Int, sum: Vec3)] = [:]
            for c in all {
                let key = "\(Int((c.x / 50).rounded(.down))),\(Int((c.z / 50).rounded(.down)))"
                let cell = cells[key] ?? (0, .zero)
                cells[key] = (cell.count + 1, cell.sum + c)
            }
            if let busiest = cells.values.max(by: { $0.count < $1.count }) {
                let middle = busiest.sum * (1 / Float(busiest.count))
                let near = all.filter { c -> Bool in
                    let dx: Float = c.x - middle.x
                    let dz: Float = c.z - middle.z
                    return dx * dx + dz * dz < 9025
                }
                if near.count >= 3 { centres = near }
            }
        }
        if centres.count >= 3 {
            func range(_ values: [Float]) -> (Float, Float) {
                let s = values.sorted()
                let lo = s[Int(Float(s.count - 1) * 0.18)]
                let hi = s[Int(Float(s.count - 1) * 0.82)]
                return (lo, hi)
            }
            let (x0, x1) = range(centres.map(\.x))
            let (z0, z1) = range(centres.map(\.z))
            // Height is taken whole: a tower is the point of a tower game,
            // and there are few blocks at the top to vote for it.
            let ys = centres.map(\.y).sorted()
            let y0 = ys[Int(Float(ys.count - 1) * 0.05)]
            let y1 = max(ys[ys.count - 1], tops.max() ?? 0)
            target = Vec3((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2)
            let across = Vec3(x1 - x0, 0, z1 - z0).length * 0.42
            let tall = (y1 - y0) * 0.62
            radius = max(12, min(95, max(across, tall)))
            // The top of the tallest thing is in the picture too.
            let summit = Vec3(target.x, y1, target.z)
            return fitted(at: target, radius: radius, yawDegrees: 35, points: centres, summit: summit, widest: 1.2)
        }
        return look(at: target, radius: radius, yawDegrees: 35)
    }

    /// The camera moved in (or back) until what was built fills the picture:
    /// nine in ten of its blocks inside the frame, with room left for the
    /// sky along the top. The estimate above goes by how far apart things
    /// are; this looks at where they actually land on the screen, so a
    /// long, thin map or one seen end-on is not drawn as a speck.
    private static func fitted(at target: Vec3, radius: Float, yawDegrees: Float, pitchDegrees: Float = 24, points: [Vec3], summit: Vec3,
                               widest: Float) -> Camera {
        let halfHeight = tan(26 * Float.pi / 180)
        let halfWidth = halfHeight * Float(width) / Float(height)
        func shows(_ p: Vec3, _ camera: Camera) -> Bool {
            let d = p - camera.eye
            let z = d.dot(camera.forward)
            guard z > 1 else { return false }
            let sx = d.dot(camera.right) / z / halfWidth
            let sy = d.dot(camera.up) / z / halfHeight
            return abs(sx) < 0.9 && sy > -0.92 && sy < 0.6
        }
        var scale: Float = 0.4
        while scale < widest {
            let camera = look(at: target, radius: radius * scale, yawDegrees: yawDegrees, pitchDegrees: pitchDegrees)
            let inside = points.filter { shows($0, camera) }.count
            if shows(summit, camera) && Float(inside) >= Float(points.count) * 0.9 { return camera }
            scale += 0.04
        }
        return look(at: target, radius: radius * widest, yawDegrees: yawDegrees, pitchDegrees: pitchDegrees)
    }

    /// Three-quarters from above, `radius` metres around `target` in view.
    private static func look(at target: Vec3, radius: Float, yawDegrees: Float, pitchDegrees: Float = 24) -> Camera {
        let yaw = yawDegrees * .pi / 180
        let pitch = pitchDegrees * .pi / 180
        let distance = radius / tan(26 * Float.pi / 180) * 0.95
        let back = Vec3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch))
        let eye = target + back * distance
        // Aim a little above the middle, so the sky shows along the top.
        let forward = (target + Vec3(0, radius * 0.18, 0) - eye).normalized
        let right = forward.cross(Vec3(0, 1, 0)).normalized
        let up = right.cross(forward).normalized
        return Camera(eye: eye, forward: forward, right: right, up: up, focus: target, radius: radius)
    }

    // MARK: Shapes

    private typealias Tri = (Vec3, Vec3, Vec3)

    private static var meshes: [BlockShape: [Tri]] = [:]

    private static func mesh(_ shape: BlockShape) -> [Tri] {
        if let cached = meshes[shape] { return cached }
        let made: [Tri]
        switch shape {
        case .box: made = box()
        case .plane:
            let a = Vec3(-0.5, 0, -0.5), b = Vec3(0.5, 0, -0.5), c = Vec3(0.5, 0, 0.5), d = Vec3(-0.5, 0, 0.5)
            made = [(a, c, b), (a, d, c)]
        case .sphere: made = sphere()
        case .cylinder: made = lathe(top: 0.5, bottom: 0.5)
        case .cone: made = lathe(top: 0, bottom: 0.5)
        }
        meshes[shape] = made
        return made
    }

    private static func box() -> [Tri] {
        let p = [
            Vec3(-0.5, -0.5, -0.5), Vec3(0.5, -0.5, -0.5), Vec3(0.5, 0.5, -0.5), Vec3(-0.5, 0.5, -0.5),
            Vec3(-0.5, -0.5, 0.5), Vec3(0.5, -0.5, 0.5), Vec3(0.5, 0.5, 0.5), Vec3(-0.5, 0.5, 0.5)
        ]
        let quads = [[4, 5, 6, 7], [1, 0, 3, 2], [0, 4, 7, 3], [5, 1, 2, 6], [7, 6, 2, 3], [0, 1, 5, 4]]
        return quads.flatMap { q in [(p[q[0]], p[q[1]], p[q[2]]), (p[q[0]], p[q[2]], p[q[3]])] }
    }

    private static func sphere() -> [Tri] {
        let rings = 8, segments = 14
        func point(_ i: Int, _ j: Int) -> Vec3 {
            let theta = Float(i) / Float(rings) * .pi
            let phi = Float(j) / Float(segments) * 2 * .pi
            return Vec3(0.5 * sin(theta) * cos(phi), 0.5 * cos(theta), 0.5 * sin(theta) * sin(phi))
        }
        var out: [Tri] = []
        for i in 0..<rings {
            for j in 0..<segments {
                let a = point(i, j), b = point(i + 1, j), c = point(i + 1, j + 1), d = point(i, j + 1)
                out.append((a, b, c))
                out.append((a, c, d))
            }
        }
        return out
    }

    private static func lathe(top: Float, bottom: Float) -> [Tri] {
        let segments = 16
        var out: [Tri] = []
        for j in 0..<segments {
            let a0 = Float(j) / Float(segments) * 2 * .pi
            let a1 = Float(j + 1) / Float(segments) * 2 * .pi
            let b0 = Vec3(bottom * cos(a0), -0.5, bottom * sin(a0)), b1 = Vec3(bottom * cos(a1), -0.5, bottom * sin(a1))
            let t0 = Vec3(top * cos(a0), 0.5, top * sin(a0)), t1 = Vec3(top * cos(a1), 0.5, top * sin(a1))
            out.append((b0, t0, t1))
            out.append((b0, t1, b1))
            out.append((Vec3(0, -0.5, 0), b0, b1))
            if top > 0 { out.append((Vec3(0, 0.5, 0), t1, t0)) }
        }
        return out
    }

    /// A character as the app draws one, in whatever they ride.
    private static func avatar(_ profile: AvatarProfile, at feet: Vec3, yaw: Float) -> [Triangle] {
        let turn = Quat.yaw(degrees: yaw)
        let h = profile.height
        let seat: Float
        switch profile.ride {
        case .car: seat = -0.45
        case .sports, .kart: seat = -0.55
        case .truck: seat = -0.1
        case .bike: seat = 0.15
        case .scooter: seat = 0.1
        case .hoverboard: seat = 0.18
        case .none, .jetpack: seat = 0
        }
        var parts: [(Vec3, Vec3, ColorRGBA)] = [
            (Vec3(0, 0.95 + seat, 0), Vec3(0.6, 0.7, 0.35), profile.bodyColor),
            (Vec3(0, 1.53 + seat, 0), Vec3(0.45, 0.45, 0.45), profile.headColor),
            (Vec3(-0.39, 0.95 + seat, 0), Vec3(0.18, 0.6, 0.18), profile.headColor),
            (Vec3(0.39, 0.95 + seat, 0), Vec3(0.18, 0.6, 0.18), profile.headColor)
        ]
        // Two eyes on the front of the head, so a crowd reads as people.
        let eye = ColorRGBA(r: 0.08, g: 0.08, b: 0.1)
        parts.append((Vec3(-0.1, 1.57 + seat, -0.226), Vec3(0.07, 0.1, 0.02), eye))
        parts.append((Vec3(0.1, 1.57 + seat, -0.226), Vec3(0.07, 0.1, 0.02), eye))
        if !profile.ride.isSeated {
            parts.append((Vec3(-0.16, 0.3 + seat, 0), Vec3(0.22, 0.6, 0.22), profile.accentColor))
            parts.append((Vec3(0.16, 0.3 + seat, 0), Vec3(0.22, 0.6, 0.22), profile.accentColor))
        }
        let paint = profile.rideColor
        let dark = ColorRGBA(r: 0.12, g: 0.13, b: 0.16)
        switch profile.ride {
        case .car:
            parts.append((Vec3(0, 0.5, 0), Vec3(1.9, 0.6, 3.6), paint))
            parts.append((Vec3(0, 0.95, 0.55), Vec3(1.5, 0.45, 0.14), dark))
        case .sports:
            parts.append((Vec3(0, 0.42, 0), Vec3(1.9, 0.45, 4.0), paint))
            parts.append((Vec3(0, 0.98, 1.8), Vec3(1.8, 0.07, 0.4), paint))
        case .truck:
            parts.append((Vec3(0, 0.75, 0), Vec3(2.2, 0.8, 4.4), paint))
            parts.append((Vec3(0, 1.42, 1.25), Vec3(2.2, 0.55, 1.8), dark))
        case .kart:
            parts.append((Vec3(0, 0.3, 0), Vec3(1.3, 0.3, 2.0), paint))
        case .bike, .scooter:
            parts.append((Vec3(0, 0.45, 0), Vec3(0.12, 0.5, 1.4), paint))
        case .hoverboard:
            parts.append((Vec3(0, 0.12, 0), Vec3(0.8, 0.1, 1.6), paint))
        case .jetpack:
            parts.append((Vec3(0, 1.0, 0.32), Vec3(0.5, 0.6, 0.25), paint))
        case .none:
            break
        }
        if [.car, .sports, .truck, .kart].contains(profile.ride) {
            let x: Float = profile.ride == .kart ? 0.72 : 1.0
            let z: Float = profile.ride == .kart ? 0.72 : (profile.ride == .truck ? 1.5 : 1.2)
            let r: Float = profile.ride == .truck ? 0.5 : (profile.ride == .kart ? 0.25 : 0.36)
            for sx in [Float(-1), 1] {
                for sz in [Float(-1), 1] { parts.append((Vec3(sx * x, r, sz * z), Vec3(0.3, r * 2, r * 2), dark)) }
            }
        }
        var out: [Triangle] = []
        for (offset, size, color) in parts {
            let t = Transform3D(position: feet + turn.act(offset * h), rotation: turn, scale: size * h)
            for tri in box() {
                out.append(Triangle(a: place(tri.0, t), b: place(tri.1, t), c: place(tri.2, t), color: color, unlit: false))
            }
        }
        return out
    }

    // MARK: Drawing

    // MARK: Shadows

    /// Depth as seen from the sun, straight down its rays: a point further
    /// along a ray than what the sun sees first is in shadow.
    private struct ShadowMap {
        let size = 2048
        let right: Vec3
        let up: Vec3
        let forward: Vec3
        let minX: Float
        let minY: Float
        /// Texels per metre.
        let scale: Float
        var depth: [Float]

        init(toSun: Vec3, focus: Vec3, radius: Float) {
            forward = (toSun * -1).normalized
            let side = abs(forward.y) > 0.98 ? Vec3(1, 0, 0) : forward.cross(Vec3(0, 1, 0)).normalized
            right = side
            up = side.cross(forward).normalized
            // Enough around the focus for everything in frame, with room for
            // the long shadows of a low sun.
            let half = max(20, radius * 2.4)
            minX = focus.dot(right) - half
            minY = focus.dot(up) - half
            scale = Float(size) / (2 * half)
            depth = [Float](repeating: .infinity, count: size * size)
        }

        private func project(_ p: Vec3) -> Vec3 {
            Vec3((p.dot(right) - minX) * scale, (p.dot(up) - minY) * scale, p.dot(forward))
        }

        mutating func add(_ tri: Triangle) {
            let a = project(tri.a), b = project(tri.b), c = project(tri.c)
            let lo = Float(0), hi = Float(size - 1)
            let minX = max(lo, min(a.x, b.x, c.x).rounded(.down)), maxX = min(hi, max(a.x, b.x, c.x).rounded(.up))
            let minY = max(lo, min(a.y, b.y, c.y).rounded(.down)), maxY = min(hi, max(a.y, b.y, c.y).rounded(.up))
            guard minX <= maxX, minY <= maxY else { return }
            let area = (b.x - a.x) * (c.y - a.y) - (c.x - a.x) * (b.y - a.y)
            guard abs(area) > 1e-7 else { return }
            let inverse = 1 / area
            for y in Int(minY)...Int(maxY) {
                let py = Float(y) + 0.5
                for x in Int(minX)...Int(maxX) {
                    let px = Float(x) + 0.5
                    let w0 = ((b.x - px) * (c.y - py) - (c.x - px) * (b.y - py)) * inverse
                    let w1 = ((c.x - px) * (a.y - py) - (a.x - px) * (c.y - py)) * inverse
                    let w2 = 1 - w0 - w1
                    guard w0 >= -1e-4, w1 >= -1e-4, w2 >= -1e-4 else { continue }
                    let d = w0 * a.z + w1 * b.z + w2 * c.z
                    let i = y * size + x
                    if d < depth[i] { depth[i] = d }
                }
            }
        }

        /// 1 in full sun, 0 in full shadow, soft at the edges (3×3 samples).
        func light(at p: Vec3) -> Float {
            let q = project(p)
            let bias: Float = 0.06 + 1.6 / scale
            var lit: Float = 0
            for dy in -1...1 {
                for dx in -1...1 {
                    let x = Int(q.x) + dx, y = Int(q.y) + dy
                    guard x >= 0, y >= 0, x < size, y < size else {
                        lit += 1
                        continue
                    }
                    if depth[y * size + x] >= q.z - bias { lit += 1 }
                }
            }
            return lit / 9
        }
    }

    // MARK: Drawing

    private struct Canvas {
        let width: Int
        let height: Int
        var camera: Camera
        let environment: EnvironmentSettings
        var color: [Float]
        var depth: [Float]
        /// How much of each pixel glows (neon), for the bloom.
        var glow: [Float]
        let toSun: Vec3
        let near: Float = 0.3
        var shadows: ShadowMap?
        /// How dark a shadow is: deep in daylight, gentle at night.
        let shadowStrength: Float

        init(width: Int, height: Int, camera: Camera, environment: EnvironmentSettings) {
            self.width = width
            self.height = height
            var camera = camera
            // 52° across the height, like the app's camera a little zoomed.
            camera.focal = Float(height) / 2 / tan(26 * Float.pi / 180)
            self.camera = camera
            self.environment = environment
            color = [Float](repeating: 0, count: width * height * 3)
            depth = [Float](repeating: .infinity, count: width * height)
            glow = [Float](repeating: 0, count: width * height)
            let sun = Quat.euler(degrees: Vec3(environment.sunPitchDegrees, environment.sunYawDegrees, 0)).act(Vec3(0, 0, -1))
            var towardSun = sun * -1
            // A sun below the horizon (night maps) still lights the tops a little.
            if towardSun.y < 0.25 { towardSun.y = 0.25 }
            toSun = towardSun.normalized
            shadowStrength = min(0.5, max(0.22, environment.ambientIntensity * 0.6))
        }

        /// The sky's gradient, and a warm glow around the sun when it is in view.
        mutating func paintSky() {
            let top = environment.skyTop, bottom = environment.skyBottom
            let sunUp = -Quat.euler(degrees: Vec3(environment.sunPitchDegrees, environment.sunYawDegrees, 0)).act(Vec3(0, 0, -1)).y > 0.02
            for y in 0..<height {
                let t = Float(y) / Float(height - 1)
                let r = top.r + (bottom.r - top.r) * t
                let g = top.g + (bottom.g - top.g) * t
                let b = top.b + (bottom.b - top.b) * t
                for x in 0..<width {
                    var glow: Float = 0
                    if sunUp {
                        let ray = (camera.forward * camera.focal + camera.right * (Float(x) - Float(width) / 2)
                            + camera.up * (Float(height) / 2 - Float(y))).normalized
                        let facing = max(0, ray.dot(toSun))
                        glow = pow(facing, 60) * 0.35 + pow(facing, 6) * 0.08
                    }
                    let i = (y * width + x) * 3
                    color[i] = min(1, r + glow)
                    color[i + 1] = min(1, g + glow * 0.9)
                    color[i + 2] = min(1, b + glow * 0.7)
                }
            }
        }

        /// Camera space: x right, y up, z forward (distance in front).
        private func view(_ p: Vec3) -> Vec3 {
            let d = p - camera.eye
            return Vec3(d.dot(camera.right), d.dot(camera.up), d.dot(camera.forward))
        }

        /// A pixel and its depth, back in the world.
        private func world(px: Double, py: Double, z: Float) -> Vec3 {
            let vx = (Float(px) - Float(width) / 2) * z / camera.focal
            let vy = (Float(height) / 2 - Float(py)) * z / camera.focal
            return camera.eye + camera.right * vx + camera.up * vy + camera.forward * z
        }

        mutating func draw(_ tri: Triangle, blend: Bool) {
            let normal = (tri.b - tri.a).cross(tri.c - tri.a)
            let length = normal.length
            guard length > 1e-9 else { return }
            var n = normal * (1 / length)
            // Two-sided: light the face the camera sees.
            let centre = (tri.a + tri.b + tri.c) * (1.0 / 3)
            if n.dot(camera.eye - centre) < 0 { n = n * -1 }

            // Shade = (ambient + sky + sun × shadow) × exposure, split so the
            // sun part can be shadowed pixel by pixel.
            var ambient: Float = 1, sunPart: Float = 0
            let exposure: Float = 0.55 + environment.ambientIntensity * 0.6
            if !tri.unlit {
                ambient = (0.42 + environment.ambientIntensity * 0.1 + max(0, n.y) * 0.12) * exposure
                // A face turned from the sun is already in its own shade.
                sunPart = max(0, n.dot(toSun)) * 0.62 * exposure
            }
            let base = tri.unlit
                ? Vec3(min(1, tri.color.r * 1.15), min(1, tri.color.g * 1.15), min(1, tri.color.b * 1.15))
                : Vec3(tri.color.r, tri.color.g, tri.color.b)

            // Clip against the near plane, then fan into screen triangles.
            let polygon = clipNear([view(tri.a), view(tri.b), view(tri.c)])
            guard polygon.count >= 3 else { return }
            let screen = polygon.map { v -> Vec3 in
                Vec3(Float(width) / 2 + v.x / v.z * camera.focal, Float(height) / 2 - v.y / v.z * camera.focal, v.z)
            }
            let fragment = Fragment(base: base, ambient: ambient, sun: sunPart, unlit: tri.unlit,
                                    alpha: blend ? tri.color.a : 1, shadowed: !tri.unlit && sunPart > 0.001)
            for k in 1..<(screen.count - 1) {
                fill(screen[0], screen[k], screen[k + 1], fragment, writeDepth: !blend)
            }
        }

        private struct Fragment {
            let base: Vec3
            let ambient: Float
            let sun: Float
            let unlit: Bool
            let alpha: Float
            /// Whether a shadow can fall on it at all.
            let shadowed: Bool
        }

        private func clipNear(_ points: [Vec3]) -> [Vec3] {
            var out: [Vec3] = []
            for i in 0..<points.count {
                let a = points[i], b = points[(i + 1) % points.count]
                let aIn = a.z >= near, bIn = b.z >= near
                if aIn { out.append(a) }
                if aIn != bIn {
                    let t = (near - a.z) / (b.z - a.z)
                    out.append(a + (b - a) * t)
                }
            }
            return out
        }

        private mutating func fill(_ q0: Vec3, _ q1: Vec3, _ q2: Vec3, _ fragment: Fragment, writeDepth: Bool) {
            // Doubles: a ground plane clipped at the near plane puts corners
            // far off screen, and in Float the edge maths loses the pixels.
            let x0 = Double(q0.x), y0 = Double(q0.y), x1 = Double(q1.x), y1 = Double(q1.y), x2 = Double(q2.x), y2 = Double(q2.y)
            let minX = max(0, Int(min(x0, x1, x2).rounded(.down)))
            let maxX = min(width - 1, Int(max(x0, x1, x2).rounded(.up)))
            let minY = max(0, Int(min(y0, y1, y2).rounded(.down)))
            let maxY = min(height - 1, Int(max(y0, y1, y2).rounded(.up)))
            guard minX <= maxX, minY <= maxY else { return }
            let area = (x1 - x0) * (y2 - y0) - (x2 - x0) * (y1 - y0)
            guard abs(area) > 1e-9 else { return }
            let inverseArea = 1 / area
            // Depth interpolates as 1/z across the screen.
            let iz0 = 1 / Double(q0.z), iz1 = 1 / Double(q1.z), iz2 = 1 / Double(q2.z)
            let fogColor = environment.skyBottom
            let alpha = fragment.alpha
            for y in minY...maxY {
                let py = Double(y) + 0.5
                for x in minX...maxX {
                    let px = Double(x) + 0.5
                    var w0 = ((x1 - px) * (y2 - py) - (x2 - px) * (y1 - py)) * inverseArea
                    var w1 = ((x2 - px) * (y0 - py) - (x0 - px) * (y2 - py)) * inverseArea
                    var w2 = 1 - w0 - w1
                    guard w0 >= -1e-6, w1 >= -1e-6, w2 >= -1e-6 else { continue }
                    w0 = max(0, w0); w1 = max(0, w1); w2 = max(0, w2)
                    let z = Float(1 / (w0 * iz0 + w1 * iz1 + w2 * iz2))
                    let index = y * width + x
                    guard z < depth[index] else { continue }
                    if writeDepth { depth[index] = z }

                    var shade = fragment.ambient + fragment.sun
                    if fragment.shadowed, writeDepth, let shadows {
                        let lit = shadows.light(at: world(px: px, py: py, z: z))
                        shade = fragment.ambient + fragment.sun * (1 - shadowStrength * 2 * (1 - lit))
                    }
                    shade = fragment.unlit ? 1 : min(1.25, shade)
                    let rgb = fragment.base * shade
                    // Distance haze, melting into the sky at the horizon.
                    let fog = min(1, max(0, (z - 60) / 420))
                    let r = rgb.x + (fogColor.r - rgb.x) * fog
                    let g = rgb.y + (fogColor.g - rgb.y) * fog
                    let b = rgb.z + (fogColor.b - rgb.z) * fog
                    let i = index * 3
                    let glowing: Float = fragment.unlit ? (1 - fog) : 0
                    if alpha >= 0.999 {
                        color[i] = r; color[i + 1] = g; color[i + 2] = b
                        glow[index] = glowing
                    } else {
                        color[i] += (r - color[i]) * alpha
                        color[i + 1] += (g - color[i + 1]) * alpha
                        color[i + 2] += (b - color[i + 2]) * alpha
                        glow[index] += (glowing - glow[index]) * alpha
                    }
                }
            }
        }

        /// Soft darkening where surfaces meet — the foot of a wall, the
        /// inside of a doorway — read from the depth buffer alone.
        mutating func occlusion() {
            let offsets: [(Int, Int)] = [(4, 0), (-4, 0), (0, 4), (0, -4), (3, 3), (-3, 3), (3, -3), (-3, -3),
                                         (10, 0), (-10, 0), (0, 10), (0, -10), (7, 7), (-7, 7), (7, -7), (-7, -7)]
            var dark = [Float](repeating: 0, count: width * height)
            for y in 10..<(height - 10) {
                for x in 10..<(width - 10) {
                    let i = y * width + x
                    let d = depth[i]
                    guard d.isFinite else { continue }
                    var occluded: Float = 0
                    for (dx, dy) in offsets {
                        let s = depth[i + dy * width + dx]
                        guard s.isFinite else { continue }
                        let closer = (d - s) / d
                        // In front, but not so far in front that it is just
                        // another object's silhouette.
                        if closer > 0.004 && closer < 0.12 { occluded += min(1, closer * 40) }
                    }
                    dark[i] = min(0.32, occluded / Float(offsets.count) * 0.7)
                }
            }
            for i in 0..<(width * height) where dark[i] > 0 {
                let k = 1 - dark[i]
                color[i * 3] *= k; color[i * 3 + 1] *= k; color[i * 3 + 2] *= k
            }
        }

        /// Darkens pixels where the depth jumps, the thin dark edge that
        /// makes blocky scenes read at a glance.
        mutating func outline() {
            var edges = [Float](repeating: 0, count: width * height)
            for y in 1..<(height - 1) {
                for x in 1..<(width - 1) {
                    let i = y * width + x
                    let d = depth[i]
                    guard d.isFinite else { continue }
                    let neighbours = [depth[i - 1], depth[i + 1], depth[i - width], depth[i + width]]
                    var jump: Float = 0
                    for n in neighbours {
                        let other = n.isFinite ? n : d * 3
                        jump = max(jump, (other - d) / d)
                    }
                    if jump > 0.06 { edges[i] = min(1, (jump - 0.06) * 6) }
                }
            }
            for i in 0..<(width * height) where edges[i] > 0 {
                let k = 1 - 0.35 * edges[i]
                color[i * 3] *= k; color[i * 3 + 1] *= k; color[i * 3 + 2] *= k
            }
        }

        func downsampled(by factor: Int) -> Picture {
            let w = width / factor, h = height / factor
            let count = Float(factor * factor)
            var image = [Float](repeating: 0, count: w * h * 3)
            var bloom = [Float](repeating: 0, count: w * h * 3)
            for y in 0..<h {
                for x in 0..<w {
                    var r: Float = 0, g: Float = 0, b: Float = 0, gr: Float = 0, gg: Float = 0, gb: Float = 0
                    for sy in 0..<factor {
                        for sx in 0..<factor {
                            let p = (y * factor + sy) * width + (x * factor + sx)
                            let i = p * 3
                            r += color[i]; g += color[i + 1]; b += color[i + 2]
                            let k = glow[p]
                            gr += color[i] * k; gg += color[i + 1] * k; gb += color[i + 2] * k
                        }
                    }
                    let o = (y * w + x) * 3
                    image[o] = r / count; image[o + 1] = g / count; image[o + 2] = b / count
                    bloom[o] = gr / count; bloom[o + 1] = gg / count; bloom[o + 2] = gb / count
                }
            }
            // Neon glows: its light, blurred wide, added back on top.
            bloom = Self.blurred(bloom, width: w, height: h, radius: 7)
            bloom = Self.blurred(bloom, width: w, height: h, radius: 7)

            // A night map is dark on purpose, but a cover still has to show
            // what is there: a dark picture is brought up (never a bright
            // one down) as an eye adjusts, keeping it a night scene.
            var logSum: Double = 0
            for p in 0..<(w * h) {
                let l = image[p * 3] * 0.299 + image[p * 3 + 1] * 0.587 + image[p * 3 + 2] * 0.114
                logSum += log(Double(l) + 0.001)
            }
            let key = Float(exp(logSum / Double(w * h)))
            let gain = min(2.2, max(1, 0.26 / max(key, 0.01)))
            func exposed(_ c: Float) -> Float {
                let y = c * gain
                guard y > 0.75 else { return y }
                return 0.75 + (y - 0.75) / (1 + (y - 0.75) / 0.25)
            }

            var rgb = [UInt8](repeating: 0, count: w * h * 3)
            for y in 0..<h {
                for x in 0..<w {
                    let o = (y * w + x) * 3
                    var r = exposed(image[o] + bloom[o] * 0.55)
                    var g = exposed(image[o + 1] + bloom[o + 1] * 0.55)
                    var b = exposed(image[o + 2] + bloom[o + 2] * 0.55)
                    // A little more colour and contrast than flat shading gives.
                    let l = r * 0.299 + g * 0.587 + b * 0.114
                    r = l + (r - l) * 1.12; g = l + (g - l) * 1.12; b = l + (b - l) * 1.12
                    r = Self.curve(r); g = Self.curve(g); b = Self.curve(b)
                    // A soft vignette pulls the eye to the middle.
                    let dx = (Float(x) / Float(w) - 0.5) * 2, dy = (Float(y) / Float(h) - 0.5) * 2
                    let v = 1 - 0.18 * min(1, (dx * dx + dy * dy) * 0.5)
                    rgb[o] = UInt8(max(0, min(255, r * v * 255 + 0.5)))
                    rgb[o + 1] = UInt8(max(0, min(255, g * v * 255 + 0.5)))
                    rgb[o + 2] = UInt8(max(0, min(255, b * v * 255 + 0.5)))
                }
            }
            return Picture(width: w, height: h, rgb: rgb)
        }

        /// A gentle S: darks a touch deeper, lights a touch brighter.
        private static func curve(_ c: Float) -> Float {
            let x = max(0, min(1, c))
            return x + 0.16 * x * (1 - x) * (2 * x - 1)
        }

        /// A box blur in both directions.
        private static func blurred(_ source: [Float], width: Int, height: Int, radius: Int) -> [Float] {
            var horizontal = [Float](repeating: 0, count: source.count)
            let span = Float(radius * 2 + 1)
            for y in 0..<height {
                for c in 0..<3 {
                    var sum: Float = 0
                    for x in -radius...radius { sum += source[(y * width + max(0, min(width - 1, x))) * 3 + c] }
                    for x in 0..<width {
                        horizontal[(y * width + x) * 3 + c] = sum / span
                        let out = max(0, min(width - 1, x - radius))
                        let into = max(0, min(width - 1, x + radius + 1))
                        sum += source[(y * width + into) * 3 + c] - source[(y * width + out) * 3 + c]
                    }
                }
            }
            var result = [Float](repeating: 0, count: source.count)
            for x in 0..<width {
                for c in 0..<3 {
                    var sum: Float = 0
                    for y in -radius...radius { sum += horizontal[(max(0, min(height - 1, y)) * width + x) * 3 + c] }
                    for y in 0..<height {
                        result[(y * width + x) * 3 + c] = sum / span
                        let out = max(0, min(height - 1, y - radius))
                        let into = max(0, min(height - 1, y + radius + 1))
                        sum += horizontal[(into * width + x) * 3 + c] - horizontal[(out * width + x) * 3 + c]
                    }
                }
            }
            return result
        }
    }
}

/// The same people on the same cover every build.
struct SeededRandom {
    private var state: UInt64

    init(seed: String) {
        var hash: UInt64 = 0xcbf2_9ce4_8422_2325
        for byte in seed.utf8 { hash = (hash ^ UInt64(byte)) &* 0x1000_0000_01b3 }
        state = hash | 1
    }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }

    mutating func float(_ lo: Float, _ hi: Float) -> Float {
        lo + (hi - lo) * Float(next() % 10_000) / 10_000
    }

    mutating func int(_ upperBound: Int) -> Int {
        Int(next() % UInt64(max(1, upperBound)))
    }
}
