import Foundation

// Playing every game with nobody at the controls — and then with four very
// busy robots at the controls.
//
// `GameRuntime.testRun` (Studio's Test button) only waits. That catches a
// broken `on start` but not a broken `on button`. This presses every button on
// every screen, types into every text box, walks into every block a script
// listens to, taps blocks, shoots at whoever is nearest, chats, joins late and
// leaves early, for a few minutes of game time. A runtime error anywhere is a
// failure, reported with its file and line like the host would show it.

struct HarnessReport {
    var errors: [String] = []
    var buttonsPressed = Set<String>()
    var touches = 0
    var npcsSeen = 0
    var blocksAtEnd = 0
    var roundEnded = false
    var output: [String] = []
}

enum Harness {

    /// `rich` starts every robot with a fortune in `coins` (the kit's money),
    /// so the things that cost money — houses, cars, upgrades — get bought
    /// and used too, not only what a newcomer can afford.
    /// The world a few seconds into a round, with three players standing at
    /// the spawn: what the scripts built at the start (a tower, a track, the
    /// NPCs) is there too. The covers are drawn from this.
    static func settle(_ world: WorldDocument, seconds: Double = 6) -> (world: WorldDocument, characters: [PlayerSnapshot]) {
        let game = GameRuntime(world: world, seed: 5)
        for (i, name) in ["Aoi", "Ren", "Mika"].enumerated() {
            var profile = AvatarProfile.default
            profile.displayName = name
            _ = game.addPlayer(PlayerSnapshot(peerID: PeerID(), profile: profile, position: world.spawnPosition(forPlayerIndex: i)))
        }
        _ = game.handle(.roundStarted)
        var time = 0.0
        while time < seconds {
            time += 0.1
            _ = game.advance(to: time)
        }
        return (game.world, game.roster.filter { !$0.isHidden })
    }

    static func play(_ world: WorldDocument, seconds: Double = 150, seed: UInt64 = 11, rich: Bool = false) -> HarnessReport {
        var report = HarnessReport()
        var rng = Seeded("harness\(seed)\(world.name)")
        let game = GameRuntime(world: world, seed: seed)

        var people: [PeerID] = []
        func arrive(_ name: String) {
            var profile = AvatarProfile.default
            profile.displayName = name
            let peer = PeerID()
            people.append(peer)
            _ = game.addPlayer(PlayerSnapshot(peerID: peer, profile: profile, position: world.spawnPosition(forPlayerIndex: people.count - 1)))
            if rich { game.states[peer]?.custom["coins"] = .number(1_000_000) }
            // Each robot brings saved data, as an iPad does, so the kit's
            // restore and autosave run here too — a game keeping something
            // that cannot be saved fails the build instead of a player's
            // session. Mika is a returning player with a little saved.
            let saved: [String: SaveValue] = name == "Mika" ? ["coins": .number(500), "quests_done": .number(1)] : [:]
            _ = game.handle(.saved(SaveData(saved)), from: peer, at: 0)
        }
        arrive("Aoi")
        arrive("Ren")
        arrive("Mika")
        _ = game.handle(.roundStarted)

        let touchable = { game.world.blocks.filter { $0.behavior.needsTouchDetection && $0.isVisible } }
        let words = ["hi", "/help", "yes", "1", "shop", "こんにちは", "ready", "red", "sell", "go"]

        var time = 0.0
        // Rich robots are also patient: after walking up to something they
        // stay there a few seconds (still pressing buttons), so things that
        // need you to stand somewhere — a care spot, a capture point — happen.
        var stayUntil: [PeerID: Double] = [:]
        var lateJoined = false
        var left = false
        var restarts = 0
        while time < seconds {
            time += 0.1
            _ = game.advance(to: time)

            if !lateJoined, time > 20 {
                lateJoined = true
                arrive("Sora")
            }
            if !left, time > 100, people.count > 3 {
                left = true
                let peer = people.remove(at: 1)
                _ = game.removePlayer(peer)
            }
            if game.isRoundOver {
                report.roundEnded = true
                // The host would sit on the result; carry on with a fresh
                // round so the rest of the game still gets played.
                restarts += 1
                if restarts > 20 { break }
                _ = game.handle(.roundStarted)
                continue
            }

            // Every character does something, about three times a second.
            guard Int(time * 10) % 3 == 0 else { continue }
            for peer in people {
                guard let state = game.states[peer] else { continue }
                var roll = rng.int(0, 9)
                if let until = stayUntil[peer], time < until, roll >= 3 { roll = [0, 1, 2, 3, 8][roll % 5] }
                switch roll {
                case 0, 1, 2:
                    // Press a button that is on this player's screen.
                    let buttons = visible(game, state, kind: .button)
                    if let id = buttons.isEmpty ? nil : rng.pick(buttons) {
                        report.buttonsPressed.insert(id)
                        _ = game.handle(.button(id: id), from: peer, at: time)
                    }
                case 3:
                    let inputs = visible(game, state, kind: .input)
                    if let id = inputs.isEmpty ? nil : rng.pick(inputs) {
                        _ = game.handle(.text(id: id, value: rng.pick(words)), from: peer, at: time)
                    }
                case 4, 5:
                    // Walk to something a script listens to, and touch it.
                    let candidates = touchable()
                    if !candidates.isEmpty {
                        let block = rng.pick(candidates)
                        let spot = game.world.worldPosition(of: block.id)
                        game.updateTransform(PlayerTransformPayload(peerID: peer, position: spot, yawDegrees: rng.range(0, 360)))
                        report.touches += 1
                        _ = game.handle(.touched(peer: peer, blockID: block.id))
                        if rich { stayUntil[peer] = time + 9 }
                    }
                case 6:
                    let blocks = game.world.blocks
                    if !blocks.isEmpty {
                        _ = game.handle(.tapped(peer: peer, blockID: rng.pick(blocks).id))
                    }
                case 7:
                    // Shoot at the nearest other character, if holding anything.
                    if state.armed != nil, let me = game.position(of: state) {
                        let others = game.states.values.filter { $0.peer != peer && $0.isAlive }
                        if let target = others.min(by: { (game.position(of: $0) ?? me).distance(to: me) < (game.position(of: $1) ?? me).distance(to: me) }),
                           let there = game.position(of: target) {
                            let eyes = me + Vec3(0, 1.6 * state.profile.height, 0)
                            let aim = there + Vec3(0, 1.0, 0) - eyes
                            _ = game.handle(.fire(origin: eyes, direction: aim), from: peer, at: time)
                        }
                    } else {
                        _ = game.handle(.reload, from: peer, at: time)
                    }
                case 8:
                    _ = game.handleChat(from: peer, text: rng.pick(words))
                default:
                    // Wander, so distance checks and "nearest" see movement.
                    if let me = game.position(of: state) {
                        let next = me + Vec3(rng.range(-6, 6), 0, rng.range(-6, 6))
                        game.updateTransform(PlayerTransformPayload(peerID: peer, position: next, yawDegrees: rng.range(0, 360)))
                    }
                }
            }
            report.npcsSeen = max(report.npcsSeen, game.roster.filter(\.isNPC).count)
            _ = game.drainWorldDeltas()
            _ = game.drainNPCTransforms()
            for error in game.drainErrors() {
                let text = error.description
                if !report.errors.contains(text) { report.errors.append(text) }
            }
            if report.errors.count > 12 { break }
        }
        for error in game.drainErrors() where !report.errors.contains(error.description) {
            report.errors.append(error.description)
        }
        report.output = game.drainOutput()
        report.blocksAtEnd = game.world.blocks.count
        return report
    }

    private static func visible(_ game: GameRuntime, _ state: GameRuntime.PlayerState, kind: UIElement.Kind) -> [String] {
        var all = state.ui
        for (id, element) in game.globalUI where all[id] == nil { all[id] = element }
        // Only what the host would accept: shown, and not inside a hidden panel.
        func shown(_ element: UIElement) -> Bool {
            guard element.visible else { return false }
            guard let parent = element.parent else { return true }
            guard let up = all[parent] else { return false }
            return shown(up)
        }
        return all.values.filter { $0.kind == kind && shown($0) }.map(\.id).sorted()
    }
}
