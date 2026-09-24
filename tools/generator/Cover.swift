import Foundation

/// Draws a game's cover picture from its own world.
///
/// Every cover is the game itself, seen from above at an angle with a few
/// players standing at the spawn — not a picture taken from somewhere else,
/// so it always matches what you get when you press Play, it is ours to
/// publish, and it follows the world whenever the map changes.
///
/// A small software renderer: triangles, a depth buffer, flat shading from
/// the world's own sun and sky, fog, outlines where depth jumps, and 2×
/// supersampling. The generator runs on Linux with no graphics stack, and
/// this needs nothing but arithmetic.
enum Cover {

    static let width = 800
    static let height = 450
    private static let supersample = 2

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

    static func render(_ world: WorldDocument, seed: String) -> Picture {
        var random = SeededRandom(seed: seed)
        let lookup = Dictionary(world.blocks.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

        var opaque: [Triangle] = []
        var clear: [Triangle] = []
        var centres: [Vec3] = []
        for block in world.blocks where block.isVisible && block.color.a > 0.03 && !isLid(block) {
            let t = WorldIndex.worldTransform(of: block, lookup: lookup)
            let unlit = block.material.isUnlit
            let alpha = block.color.a * block.material.alphaScale
            var color = block.color
            color.a = alpha
            let tris = mesh(block.shape).map { tri in
                Triangle(a: place(tri.0, t), b: place(tri.1, t), c: place(tri.2, t), color: color, unlit: unlit)
            }
            if alpha < 0.98 { clear += tris } else { opaque += tris }
            // What the camera frames: the built things, not the ground.
            let footprint = max(t.scale.x, t.scale.z)
            if footprint < 60 { centres.append(t.position) }
        }

        // A few players at the spawn, so the world looks lived in.
        let spawns = world.spawnBlocks
        let people = min(5, max(2, spawns.count))
        for k in 0..<people {
            guard !spawns.isEmpty else { break }
            let base = world.spawnPosition(forPlayerIndex: k)
            let around = Vec3(random.float(-2.2, 2.2), -1, random.float(-2.2, 2.2))
            opaque += avatar(at: base + around, yaw: random.float(0, 360), random: &random)
        }

        let environment = world.environment
        if environment.showGroundPlane {
            let g = environment.groundColor
            let s: Float = 3000
            let y: Float = -0.05
            opaque.append(Triangle(a: Vec3(-s, y, -s), b: Vec3(s, y, -s), c: Vec3(s, y, s), color: g, unlit: false))
            opaque.append(Triangle(a: Vec3(-s, y, -s), b: Vec3(s, y, s), c: Vec3(-s, y, s), color: g, unlit: false))
        }

        let camera = frame(centres: centres, spawn: spawns.isEmpty ? nil : world.spawnPosition(forPlayerIndex: 0))
        var canvas = Canvas(width: width * supersample, height: height * supersample, camera: camera, environment: environment)
        canvas.paintSky()
        for tri in opaque { canvas.draw(tri, blend: false) }
        // See-through things last, farthest first, without hiding what is behind.
        let eye = camera.eye
        let sorted = clear.sorted {
            (($0.a + $0.b + $0.c) * (1.0 / 3) - eye).lengthSquared > (($1.a + $1.b + $1.c) * (1.0 / 3) - eye).lengthSquared
        }
        for tri in sorted { canvas.draw(tri, blend: true) }
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
        /// Focal length in pixels at the supersampled size.
        var focal: Float = 0
    }

    /// Three-quarters from above, around the middle of what was built. The
    /// middle is taken from the middle 80% of the blocks, so one far-off
    /// marker or a lone pillar at the edge does not shrink everything else.
    private static func frame(centres: [Vec3], spawn: Vec3?) -> Camera {
        var target = spawn ?? .zero
        var radius: Float = 20
        if centres.count >= 3 {
            func range(_ values: [Float]) -> (Float, Float) {
                let s = values.sorted()
                let lo = s[Int(Float(s.count - 1) * 0.1)]
                let hi = s[Int(Float(s.count - 1) * 0.9)]
                return (lo, hi)
            }
            let (x0, x1) = range(centres.map(\.x))
            let (y0, y1) = range(centres.map(\.y))
            let (z0, z1) = range(centres.map(\.z))
            target = Vec3((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2)
            let size = Vec3(x1 - x0, y1 - y0, z1 - z0)
            radius = max(12, min(80, size.length * 0.42))
        }
        // Tall worlds (towers, obbies) are seen from lower down.
        let yawDegrees: Float = 35
        let pitchDegrees: Float = 24
        let yaw = yawDegrees * .pi / 180
        let pitch = pitchDegrees * .pi / 180
        let distance = radius / tan(26 * Float.pi / 180) * 0.95
        let back = Vec3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch))
        let eye = target + back * distance
        // Aim a little above the middle, so the sky shows along the top.
        let forward = (target + Vec3(0, radius * 0.18, 0) - eye).normalized
        let right = forward.cross(Vec3(0, 1, 0)).normalized
        let up = right.cross(forward).normalized
        return Camera(eye: eye, forward: forward, right: right, up: up)
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

    /// The blocky player, as the app draws one.
    private static func avatar(at feet: Vec3, yaw: Float, random: inout SeededRandom) -> [Triangle] {
        let shirts = ["#EF4444", "#3B82F6", "#22C55E", "#F59E0B", "#A855F7", "#EC4899", "#14B8A6"]
        let skins = ["#F5D0A9", "#E0AC69", "#8D5524", "#FFDBAC"]
        let shirt = ColorRGBA(hex: shirts[random.int(shirts.count)]) ?? .white
        let skin = ColorRGBA(hex: skins[random.int(skins.count)]) ?? .white
        let legs = ColorRGBA(hex: ["#1E3A8A", "#111827", "#78350F", "#334155"][random.int(4)]) ?? .white
        let turn = Quat.yaw(degrees: yaw)
        let parts: [(Vec3, Vec3, ColorRGBA)] = [
            (Vec3(0, 0.95, 0), Vec3(0.6, 0.7, 0.35), shirt),
            (Vec3(0, 1.53, 0), Vec3(0.45, 0.45, 0.45), skin),
            (Vec3(-0.39, 0.95, 0), Vec3(0.18, 0.6, 0.18), skin),
            (Vec3(0.39, 0.95, 0), Vec3(0.18, 0.6, 0.18), skin),
            (Vec3(-0.16, 0.3, 0), Vec3(0.22, 0.6, 0.22), legs),
            (Vec3(0.16, 0.3, 0), Vec3(0.22, 0.6, 0.22), legs)
        ]
        var out: [Triangle] = []
        for (offset, size, color) in parts {
            let t = Transform3D(position: feet + turn.act(offset), rotation: turn, scale: size)
            for tri in box() {
                out.append(Triangle(a: place(tri.0, t), b: place(tri.1, t), c: place(tri.2, t), color: color, unlit: false))
            }
        }
        return out
    }

    // MARK: Drawing

    private struct Canvas {
        let width: Int
        let height: Int
        var camera: Camera
        let environment: EnvironmentSettings
        var color: [Float]
        var depth: [Float]
        let toSun: Vec3
        let near: Float = 0.3

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
            let sun = Quat.euler(degrees: Vec3(environment.sunPitchDegrees, environment.sunYawDegrees, 0)).act(Vec3(0, 0, -1))
            var towardSun = sun * -1
            // A sun below the horizon (night maps) still lights the tops a little.
            if towardSun.y < 0.25 { towardSun.y = 0.25 }
            toSun = towardSun.normalized
        }

        mutating func paintSky() {
            let top = environment.skyTop, bottom = environment.skyBottom
            for y in 0..<height {
                let t = Float(y) / Float(height - 1)
                let r = top.r + (bottom.r - top.r) * t
                let g = top.g + (bottom.g - top.g) * t
                let b = top.b + (bottom.b - top.b) * t
                for x in 0..<width {
                    let i = (y * width + x) * 3
                    color[i] = r
                    color[i + 1] = g
                    color[i + 2] = b
                }
            }
        }

        /// Camera space: x right, y up, z forward (distance in front).
        private func view(_ p: Vec3) -> Vec3 {
            let d = p - camera.eye
            return Vec3(d.dot(camera.right), d.dot(camera.up), d.dot(camera.forward))
        }

        mutating func draw(_ tri: Triangle, blend: Bool) {
            let normal = (tri.b - tri.a).cross(tri.c - tri.a)
            let length = normal.length
            guard length > 1e-9 else { return }
            var n = normal * (1 / length)
            // Two-sided: light the face the camera sees.
            let centre = (tri.a + tri.b + tri.c) * (1.0 / 3)
            if n.dot(camera.eye - centre) < 0 { n = n * -1 }

            var shade: Float = 1
            if !tri.unlit {
                let ambient: Float = 0.42 + environment.ambientIntensity * 0.1
                let diffuse = max(0, n.dot(toSun))
                // Faces pointing up read a touch brighter, as under a sky.
                let sky = max(0, n.y) * 0.12
                shade = min(1.25, (ambient + diffuse * 0.62 + sky) * (0.55 + environment.ambientIntensity * 0.6))
            }
            var rgb = Vec3(tri.color.r * shade, tri.color.g * shade, tri.color.b * shade)
            if tri.unlit { rgb = Vec3(min(1, tri.color.r * 1.15), min(1, tri.color.g * 1.15), min(1, tri.color.b * 1.15)) }

            // Clip against the near plane, then fan into screen triangles.
            let polygon = clipNear([view(tri.a), view(tri.b), view(tri.c)])
            guard polygon.count >= 3 else { return }
            let screen = polygon.map { v -> Vec3 in
                Vec3(Float(width) / 2 + v.x / v.z * camera.focal, Float(height) / 2 - v.y / v.z * camera.focal, v.z)
            }
            for k in 1..<(screen.count - 1) {
                fill(screen[0], screen[k], screen[k + 1], rgb: rgb, alpha: blend ? tri.color.a : 1, writeDepth: !blend)
            }
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

        private mutating func fill(_ q0: Vec3, _ q1: Vec3, _ q2: Vec3, rgb: Vec3, alpha: Float, writeDepth: Bool) {
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
                    // Distance haze, melting into the sky at the horizon.
                    let fog = min(1, max(0, (z - 60) / 420))
                    let r = rgb.x + (fogColor.r - rgb.x) * fog
                    let g = rgb.y + (fogColor.g - rgb.y) * fog
                    let b = rgb.z + (fogColor.b - rgb.z) * fog
                    let i = index * 3
                    if alpha >= 0.999 {
                        color[i] = r; color[i + 1] = g; color[i + 2] = b
                    } else {
                        color[i] += (r - color[i]) * alpha
                        color[i + 1] += (g - color[i + 1]) * alpha
                        color[i + 2] += (b - color[i + 2]) * alpha
                    }
                }
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
            var rgb = [UInt8](repeating: 0, count: w * h * 3)
            let count = Float(factor * factor)
            for y in 0..<h {
                for x in 0..<w {
                    var r: Float = 0, g: Float = 0, b: Float = 0
                    for sy in 0..<factor {
                        for sx in 0..<factor {
                            let i = ((y * factor + sy) * width + (x * factor + sx)) * 3
                            r += color[i]; g += color[i + 1]; b += color[i + 2]
                        }
                    }
                    // A soft vignette pulls the eye to the middle.
                    let dx = (Float(x) / Float(w) - 0.5) * 2, dy = (Float(y) / Float(h) - 0.5) * 2
                    let v = 1 - 0.18 * min(1, (dx * dx + dy * dy) * 0.5)
                    let o = (y * w + x) * 3
                    rgb[o] = UInt8(max(0, min(255, (r / count) * v * 255 + 0.5)))
                    rgb[o + 1] = UInt8(max(0, min(255, (g / count) * v * 255 + 0.5)))
                    rgb[o + 2] = UInt8(max(0, min(255, (b / count) * v * 255 + 0.5)))
                }
            }
            return Picture(width: w, height: h, rgb: rgb)
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
