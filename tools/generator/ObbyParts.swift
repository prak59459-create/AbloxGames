import Foundation

// Parts for obbies (games 81–95), on top of MapBuilder: numbered checkpoints
// the obby engine (lib/kit_obby.absc) counts, and the gimmicks that work with
// no script — kill bricks, moving platforms, trampolines, vanishing tiles.
//
// Sizes follow what a character can do: a jump rises about 1 m and carries
// about 3 m walking (6 m running), so a gap of 2.5 m is easy, 3.5 m needs a
// run-up, and a step of more than 1 m needs a trampoline or a ladder.

extension MapBuilder {

    /// The checkpoint "Stage n" (or "`prefix` n"), a pad whose top is at `y`.
    @discardableResult
    func stagePad(_ n: Int, x: Float, y: Float, z: Float, size: Float = 4, color: String = "#22C55E",
                  prefix: String = "Stage") -> UUID {
        part("\(prefix) \(n)", at: (x, y - 0.25, z), size: (size, 0.5, size), color: color, material: .neon,
             behavior: .checkpoint)
    }

    /// The "Finish" pad and an arch over it.
    func finishLine(x: Float, y: Float, z: Float, size: Float = 8, color: String = "#FACC15", name: String = "Finish") {
        part(name, at: (x, y - 0.25, z), size: (size, 0.5, size), color: color, material: .neon, behavior: .trigger)
        part("\(name) Arch", at: (x - size / 2, y + 2.5, z), size: (0.5, 5, 0.5), color: color, material: .neon)
        part("\(name) Arch", at: (x + size / 2, y + 2.5, z), size: (0.5, 5, 0.5), color: color, material: .neon)
        part("\(name) Arch Top", at: (x, y + 5.2, z), size: (size + 0.5, 0.5, 0.5), color: color, material: .neon)
    }

    /// A platform whose top is at `y`.
    @discardableResult
    func step(_ name: String = "Step", x: Float, y: Float, z: Float, w: Float = 3, d: Float = 3, h: Float = 0.6,
              color: String, material: MaterialKind = .plastic, tags: [String] = [], rotation: V? = nil) -> UUID {
        part(name, at: (x, y - h / 2, z), size: (w, h, d), color: color, material: material, tags: tags, rotation: rotation)
    }

    /// Touching it sends you back to your checkpoint.
    @discardableResult
    func killBrick(_ name: String = "Kill Brick", at p: V, size s: V, color: String = "#EF4444", shape: BlockShape = .box,
                   rotation: V? = nil, tags: [String] = []) -> UUID {
        part(name, at: p, size: s, color: color, shape: shape, material: .neon, behavior: .hazard, tags: tags, rotation: rotation)
    }

    /// A platform that slides by `offset` and back for ever, carrying whoever stands on it.
    @discardableResult
    func mover(_ name: String = "Mover", at p: V, size s: V, color: String, offset: V, seconds: Double = 3, pause: Double = 1,
               material: MaterialKind = .plastic, tags: [String] = []) -> UUID {
        var g = GimmickSettings.default
        g.moveOffset = Vec3(offset.0, offset.1, offset.2)
        g.moveSeconds = seconds
        g.movePause = pause
        return part(name, at: p, size: s, color: color, material: material, behavior: .elevator, tags: tags, gimmick: g)
    }

    /// A trampoline: `speed` m/s upward (14 clears about 5 m).
    @discardableResult
    func bouncer(_ name: String = "Trampoline", at p: V, size s: V, color: String = "#38BDF8", speed: Float = 16,
                 shape: BlockShape = .cylinder) -> UUID {
        var g = GimmickSettings.default
        g.bounceSpeed = speed
        g.cooldown = 0.6
        return part(name, at: p, size: s, color: color, shape: shape, material: .neon, behavior: .bounce, gimmick: g)
    }

    /// A tile that fades soon after you step on it, and comes back.
    @discardableResult
    func vanishing(_ name: String = "Vanishing Tile", at p: V, size s: V, color: String = "#FDE68A", delay: Double = 0.45,
                   back: Double = 2.5) -> UUID {
        var g = GimmickSettings.default
        g.disappearDelay = delay
        g.respawnDelay = back
        return part(name, at: p, size: s, color: color, material: .glass, behavior: .disappear, opacity: 0.85, gimmick: g)
    }

    /// Something to climb.
    @discardableResult
    func ladder(_ name: String = "Ladder", at p: V, size s: V, color: String = "#A16207", rotation: V? = nil) -> UUID {
        part(name, at: p, size: s, color: color, material: .wood, behavior: .ladder, rotation: rotation)
    }

    /// A row of `count` stepping stones from `a` to `b` (tops), each `size` square.
    func stones(from a: V, to b: V, count: Int, size: Float = 2.4, color: String, alternate: String? = nil,
                name: String = "Stone") {
        for i in 0..<count {
            let t = count == 1 ? 0.5 : Float(i) / Float(count - 1)
            let x = a.0 + (b.0 - a.0) * t, y = a.1 + (b.1 - a.1) * t, z = a.2 + (b.2 - a.2) * t
            step(name, x: x, y: y, z: z, w: size, d: size, color: (i % 2 == 1 ? alternate : nil) ?? color)
        }
    }

    /// A beam to walk along, from `a` to `b` (tops at their heights).
    ///
    /// The collider sees each block's upright bounding box, so a sloped beam
    /// would be a tall block you cannot step onto, and one turned at an
    /// angle would be a wide invisible floor. A sloped beam is built from
    /// flat pieces stepping up at most 0.3 m (a character steps 0.45 m), and
    /// a diagonal one from a chain of small tiles.
    func beam(from a: V, to b: V, width: Float = 1, color: String, name: String = "Beam") {
        let dx = b.0 - a.0, dy = b.1 - a.1, dz = b.2 - a.2
        let flat = (dx * dx + dz * dz).squareRoot()
        guard flat > 0.01 else { return }
        if abs(dx) > 0.01 && abs(dz) > 0.01 {
            let tile = max(width, 0.8)
            let count = max(2, Int((flat / (tile * 0.8)).rounded(.up)))
            for i in 0...count {
                let t = Float(i) / Float(count)
                step(name, x: a.0 + dx * t, y: a.1 + dy * t, z: a.2 + dz * t, w: tile, d: tile, color: color)
            }
            return
        }
        let yaw = atan2(dx, dz) * 180 / .pi
        let pieces = max(1, Int((abs(dy) / 0.3).rounded(.up)))
        let length = flat / Float(pieces)
        for i in 0..<pieces {
            let tm = (Float(i) + 0.5) / Float(pieces)
            let top = pieces == 1 ? a.1 + dy / 2 : a.1 + dy * Float(i + 1) / Float(pieces)
            part(name, at: (a.0 + dx * tm, top - 0.3, a.2 + dz * tm), size: (width, 0.6, length + 0.02), color: color,
                 rotation: (0, yaw, 0))
        }
    }

    /// A low rail round a rectangle with a gap `gap` wide in the middle of
    /// one side (+x, -x, +z or -z), so people can walk out.
    func rail(_ cx: Float, _ cz: Float, w: Float, d: Float, h: Float = 1.2, y: Float = 0, color: String, gapSide: String = "+x",
              gap: Float = 6, name: String = "Rail") {
        let t: Float = 0.5
        for side in ["+x", "-x", "+z", "-z"] {
            let alongX = side.hasSuffix("z")
            let length = alongX ? w : d
            let sx: Float = side == "+x" ? cx + w / 2 : (side == "-x" ? cx - w / 2 : cx)
            let sz: Float = side == "+z" ? cz + d / 2 : (side == "-z" ? cz - d / 2 : cz)
            if side == gapSide {
                let piece = (length - gap) / 2
                for k: Float in [-1, 1] {
                    let off = k * (gap / 2 + piece / 2)
                    slab(name, x: alongX ? sx + off : sx, y: y, z: alongX ? sz : sz + off, w: alongX ? piece : t, h: h,
                         d: alongX ? t : piece, color: color)
                }
            } else {
                slab(name, x: sx, y: y, z: sz, w: alongX ? length + t : t, h: h, d: alongX ? t : length + t, color: color)
            }
        }
    }

    /// Water to swim in, its surface at `y`.
    @discardableResult
    func pool(_ name: String = "Water", x: Float, y: Float, z: Float, w: Float, d: Float, depth: Float = 2,
              color: String = "#38BDF8", tags: [String] = ["water"]) -> UUID {
        part(name, at: (x, y - depth / 2, z), size: (w, depth, d), color: color, material: .water, tags: tags, solid: false,
             opacity: 0.7)
    }

    /// Something a script moves about and checks for touches itself
    /// (lib/kit_move.absc): not solid, since the iPad only moves its picture.
    @discardableResult
    func movingHazard(_ name: String, at p: V, size s: V, color: String, shape: BlockShape = .box, material: MaterialKind = .neon,
                      tags: [String] = [], opacity: Float = 1) -> UUID {
        part(name, at: p, size: s, color: color, shape: shape, material: material, tags: tags, solid: false, opacity: opacity)
    }

    /// An invisible block the cover camera looks at, from `yaw` degrees.
    func coverFocus(x: Float, y: Float, z: Float, yaw: Float, width: Float = 60) {
        part("Cover Focus", at: (x, y, z), size: (width, 1, 1), color: "#000000", tags: ["yaw=\(Int(yaw))"], solid: false, visible: false)
    }
}
