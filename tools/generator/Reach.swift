import Foundation

// Finds the pads on the ground that nobody can walk to from a spawn point.
//
// A building drawn with `walls` has no doorway, so a counter pad inside it
// looks fine in Studio and in the robot play (robots are teleported about by
// scripts) but a person can never reach it. This walks the ground from every
// spawn on a half-metre grid, treating anything solid between knee and head
// height as a wall, and lists the touchable pads it never gets to.

enum Reach {
    /// Names of ground-level pads that cannot be walked to, at most `limit`.
    static func unreachablePads(in world: WorldDocument, limit: Int = 8) -> [String] {
        let spawns = world.spawnBlocks.map { world.worldPosition(of: $0.id) }.filter { $0.y < 1.6 }
        guard !spawns.isEmpty else { return [] }

        struct Obstacle {
            let transform: Transform3D
            let half: Vec3
            let box: BoundingBox
        }
        var obstacles: [Obstacle] = []
        var minX: Float = .infinity, maxX: Float = -.infinity, minZ: Float = .infinity, maxZ: Float = -.infinity
        for block in world.blocks {
            guard let box = world.worldBounds(of: block.id) else { continue }
            minX = min(minX, box.min.x); maxX = max(maxX, box.max.x)
            minZ = min(minZ, box.min.z); maxZ = max(maxZ, box.max.z)
            // In the way: solid the way the game's collider sees it (visible,
            // colliding, not a walk-through behaviour), between knee and head height.
            let passThrough: Set<BlockBehavior> = [.collectible, .checkpoint, .spawn, .trigger]
            guard block.isVisible, block.hasCollision, !passThrough.contains(block.behavior),
                  box.max.y > 0.75, box.min.y < 1.7 else { continue }
            obstacles.append(Obstacle(transform: world.worldTransform(of: block.id), half: block.shape.unitBounds.size * 0.5, box: box))
        }
        minX = max(minX, -300); maxX = min(maxX, 300); minZ = max(minZ, -300); maxZ = min(maxZ, 300)
        guard minX < maxX, minZ < maxZ else { return [] }

        let cell: Float = 0.5
        let nx = Int((maxX - minX) / cell) + 1
        let nz = Int((maxZ - minZ) / cell) + 1
        func index(_ x: Float, _ z: Float) -> (Int, Int) {
            (Int(((x - minX) / cell).rounded()), Int(((z - minZ) / cell).rounded()))
        }
        var blocked = [Bool](repeating: false, count: nx * nz)
        let radius: Float = 0.3
        for o in obstacles {
            let (i0, j0) = index(o.box.min.x - radius, o.box.min.z - radius)
            let (i1, j1) = index(o.box.max.x + radius, o.box.max.z + radius)
            let y = min(max(1.2, o.box.min.y + 0.01), o.box.max.y - 0.01)
            let scale = o.transform.scale
            let (ilo, ihi, jlo, jhi) = (max(0, i0), min(nx - 1, i1), max(0, j0), min(nz - 1, j1))
            guard ilo <= ihi, jlo <= jhi else { continue }
            for i in ilo...ihi {
                for j in jlo...jhi {
                    let point = Vec3(minX + Float(i) * cell, y, minZ + Float(j) * cell)
                    let local = o.transform.inverseTransform(point: point)
                    // Inside the (possibly turned) box, grown by a body's radius.
                    if abs(local.x * scale.x) <= o.half.x * abs(scale.x) + radius,
                       abs(local.z * scale.z) <= o.half.z * abs(scale.z) + radius {
                        blocked[i * nz + j] = true
                    }
                }
            }
        }

        var seen = [Bool](repeating: false, count: nx * nz)
        var queue: [(Int, Int)] = []
        for s in spawns {
            let (i, j) = index(s.x, s.z)
            guard i >= 0, i < nx, j >= 0, j < nz, !seen[i * nz + j] else { continue }
            seen[i * nz + j] = true
            queue.append((i, j))
        }
        var head = 0
        while head < queue.count {
            let (i, j) = queue[head]
            head += 1
            for (di, dj) in [(1, 0), (-1, 0), (0, 1), (0, -1)] {
                let a = i + di, b = j + dj
                guard a >= 0, a < nx, b >= 0, b < nz else { continue }
                let k = a * nz + b
                if seen[k] || blocked[k] { continue }
                seen[k] = true
                queue.append((a, b))
            }
        }

        var missing: [String] = []
        for block in world.blocks where block.behavior != .none && block.behavior != .spawn && block.isVisible {
            guard let box = world.worldBounds(of: block.id), box.max.y < 1.0 else { continue }
            let (i0, j0) = index(box.min.x - 0.5, box.min.z - 0.5)
            let (i1, j1) = index(box.max.x + 0.5, box.max.z + 0.5)
            var reached = false
            let (ilo, ihi, jlo, jhi) = (max(0, i0), min(nx - 1, i1), max(0, j0), min(nz - 1, j1))
            guard ilo <= ihi, jlo <= jhi else { continue }
            for i in ilo...ihi where !reached {
                for j in jlo...jhi where seen[i * nz + j] {
                    reached = true
                    break
                }
            }
            if !reached { missing.append(block.name) }
            if missing.count >= limit { break }
        }
        return missing
    }
}
