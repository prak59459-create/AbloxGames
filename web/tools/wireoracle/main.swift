import Foundation

// The iPad's own wire format, as a reference for the web version.
//
//   WireOracle emit <games dir> <out.json>
//     One packet of every kind and case, encoded by PacketCodec, with the
//     JSON Swift reads back out of it.
//   WireOracle check <in.json> <out.json>
//     Packets written by the web version: each decoded with the iPad's types
//     and written again, or the error Swift gave.

func L(_ s: String, _ args: Any...) -> String { s }

let me = PeerID(UUID(uuidString: "AAAAAAAA-0000-4000-8000-00000000000A")!)
let guest = PeerID(UUID(uuidString: "BBBBBBBB-0000-4000-8000-00000000000B")!)
let blockID = UUID(uuidString: "CCCCCCCC-0000-4000-8000-00000000000C")!

let encoder: JSONEncoder = {
    let e = JSONEncoder()
    e.outputFormatting = [.sortedKeys]
    e.dateEncodingStrategy = .iso8601
    return e
}()
let decoder: JSONDecoder = {
    let d = JSONDecoder()
    d.dateDecodingStrategy = .iso8601
    return d
}()

func canonical<T: Encodable>(_ value: T) -> String {
    String(decoding: try! encoder.encode(value), as: UTF8.self)
}

/// Reads a payload by kind with the iPad's types and writes it again.
func reencode(kind: PacketKind, payload: Data, name: String) throws -> String {
    func read<T: Codable>(_ type: T.Type) throws -> String { canonical(try decoder.decode(type, from: payload)) }
    switch kind {
    case .handshake: return try read(HandshakePayload.self)
    case .worldSnapshot: return try read(WorldDocument.self)
    case .worldDelta: return try read(WorldDelta.self)
    case .playerTransform: return try read(PlayerTransformPayload.self)
    case .roster: return try read(RosterPayload.self)
    case .eventTrigger: return try read(EventTriggerPayload.self)
    case .eventEffect: return try read(EventEffectPayload.self)
    case .chat: return try read(ChatPayload.self)
    case .ping, .pong: return try read(PingPayload.self)
    case .leave: return payload.isEmpty ? "null" : try read(LeavePayload.self)
    case .playerInput: return try read(PlayerInputPayload.self)
    case .room: return try read(RoomMessage.self)
    }
}

let mode = CommandLine.arguments[1]

if mode == "missions" {
    // Today's missions and pick for every day of two years, as the iPad
    // works them out, for the web's own sums to be compared with.
    let out = CommandLine.arguments[2]
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    var days: [[String: Any]] = []
    var date = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!
    let listings = (1...37).map { GameListing(id: "game-\($0)", title: "Game \($0)", world: "games/game-\($0)/world.ablox", tags: [], blockCount: 1, maxPlayers: 4) }
    for _ in 0..<730 {
        let key = PlaytimeLog.dayKey(date, calendar: calendar)
        var book = MissionBook()
        let missions = book.missions(on: key)
        let swapped = missions.count > 1 ? book.swap(missions[1], on: key) : nil
        days.append([
            "day": key,
            "missions": missions.map { ["kind": $0.kind.rawValue, "target": $0.target, "reward": $0.reward] },
            "swap": swapped.map { ["kind": $0.kind.rawValue, "target": $0.target, "reward": $0.reward] } ?? NSNull(),
            "pick": CatalogueShelf.dailyPick(from: listings, on: date, calendar: calendar)?.id ?? "",
        ])
        date = calendar.date(byAdding: .day, value: 1, to: date)!
    }
    let data = try! JSONSerialization.data(withJSONObject: ["days": days], options: [.sortedKeys])
    try! data.write(to: URL(fileURLWithPath: out))
    print("wrote \(days.count) days")
    exit(0)
}

if mode == "emit" {
    let games = CommandLine.arguments[2]
    let out = CommandLine.arguments[3]
    let codec = PacketCodec(localPeerID: me)
    var items: [[String: Any]] = []
    func add<T: Encodable>(_ name: String, _ kind: PacketKind, _ payload: T) {
        let packet = try! codec.encode(kind, payload)
        let bytes = packet.header.encoded() + packet.payload
        items.append(["name": name, "kind": Int(kind.rawValue), "bytes": bytes.base64EncodedString(),
                      "json": try! reencode(kind: kind, payload: packet.payload, name: name),
                      "sequence": Int(packet.header.sequence)])
    }

    var profile = AvatarProfile.default
    profile.displayName = "Mika"
    profile.hat = .crown
    profile.pet = .dog
    profile.height = 1.1
    add("handshake", .handshake, HandshakePayload(peerID: me, profile: profile, worldName: "Meme Heist", isHost: true, capacity: 8))
    add("handshake-guest", .handshake, HandshakePayload(peerID: guest, profile: .default))

    let worldData = try! Data(contentsOf: URL(fileURLWithPath: games + "/maple-bay-life/world.ablox"))
    var world = try! decoder.decode(WorldDocument.self, from: worldData)
    world.scripts = [ScriptFile(name: "main", source: "on start()\n  announce(\"hi\", 2)\nend")]
    // A slice of the world with one of every kind of part in it, so the sample stays small.
    let featured = world.blocks.filter { $0.label != nil || $0.light != nil || $0.animation != nil || $0.particles != nil || $0.behavior != .none || $0.parentID != nil }
    var picked: [BlockData] = Array(world.blocks.prefix(30))
    for b in featured where picked.count < 90 && !picked.contains(where: { $0.id == b.id }) { picked.append(b) }
    let ids = Set(picked.map(\.id))
    world.blocks = picked.map { var b = $0; if let p = b.parentID, !ids.contains(p) { b.parentID = nil }; return b }
    add("world-maple", .worldSnapshot, world)
    var blank = WorldDocument.blank(named: "Blank", author: "Ablox")
    blank.rules = [EventRule(name: "r", trigger: .proximity(blockID: blank.blocks[0].id, radius: 4), actions: [.playSound(name: "coin"), .awardPoints(3)])]
    add("world-blank", .worldSnapshot, blank)

    let block = world.blocks.first { $0.label != nil } ?? world.blocks[0]
    add("delta-insert", .worldDelta, WorldDelta.insert(block))
    add("delta-update", .worldDelta, WorldDelta.update(world.blocks[1]))
    add("delta-remove", .worldDelta, WorldDelta.remove(blockID: blockID))
    add("delta-reparent", .worldDelta, WorldDelta.reparent(blockID: blockID, newParent: world.blocks[2].id))
    add("delta-unparent", .worldDelta, WorldDelta.reparent(blockID: blockID, newParent: nil))
    add("delta-environment", .worldDelta, WorldDelta.environment(world.environment))
    add("delta-rules", .worldDelta, WorldDelta.rulesReplaced(blank.rules))
    add("delta-scripts", .worldDelta, WorldDelta.scriptsReplaced(world.scripts))
    add("delta-source", .worldDelta, WorldDelta.scriptSourceChanged(ScriptSource(repository: "prak59459-create/AbloxGames", branch: "main", folder: "games/x", updatesOnPlay: true)))
    add("delta-source-none", .worldDelta, WorldDelta.scriptSourceChanged(nil))
    add("delta-images", .worldDelta, WorldDelta.imagesReplaced([]))

    add("transform", .playerTransform, PlayerTransformPayload(peerID: me, position: Vec3(1.25, 0.1, -3.3), yawDegrees: 91.5, velocity: Vec3(0.1, -2, 4.4), isGrounded: false))
    add("roster", .roster, RosterPayload(players: [
        PlayerSnapshot(peerID: me, profile: profile, position: Vec3(0, 1, 2), yawDegrees: 45, score: 12, isReady: true, team: "Red"),
        PlayerSnapshot(peerID: guest, profile: .default, isNPC: true, isHidden: true),
    ]))
    add("trigger-touched", .eventTrigger, EventTriggerPayload(peerID: me, blockID: blockID, cause: .touched))
    add("trigger-tapped", .eventTrigger, EventTriggerPayload(peerID: me, blockID: blockID, cause: .tapped))
    add("trigger-near", .eventTrigger, EventTriggerPayload(peerID: me, blockID: blockID, cause: .proximityEntered))

    var board = Leaderboard(title: "Best")
    _ = board.submit(name: "Mika", value: 12.5)
    var save = SaveData()
    _ = save.set("coins", .number(120))
    _ = save.set("hats", .list([.string("crown"), .null, .bool(true)]))
    _ = save.set("pet", .map(["name": .string("Rex")]))
    let scriptEffects: [ScriptEffect] = [
        .ui(UIElement(id: "score", kind: .text, text: "Coins: 3", x: 0.1, width: 120, color: .white, background: ColorRGBA(r: 0, g: 0, b: 0, a: 0.5), bold: true, layer: 2)),
        .ui(UIElement(id: "bar", kind: .bar, parent: "panel", value: 30, maximum: 60)),
        .removeUI(id: "score"),
        .clearUI,
        .camera(CameraSettings(mode: .firstPerson, distance: 4, fieldOfView: 80)),
        .camera(CameraSettings(mode: .fixed, position: Vec3(1, 2, 3), target: Vec3(0, 0, 0))),
        .shake(strength: 0.5, seconds: 0.4),
        .fade(color: .white, seconds: 1),
        .fade(color: nil, seconds: 0.5),
        .interface(controls: false, defaultUI: true),
        .equip(WeaponSpec(name: "Rifle", damage: 25, fireRate: 8, range: 80, magazine: 30, reloadTime: 2, spread: 0.5, model: "rifle")),
        .equip(nil),
        .ammo(current: 5, magazine: 30, reloading: false),
        .health(current: 80, maximum: 100),
        .movement(MovementScale(speed: 1.5, jump: 2, gravity: 0.5, frozen: true)),
        .launch(Vec3(0, 20, 5)),
        .face(yawDegrees: 180),
        .hitMarker(killed: true),
        .damageFlash,
        .tracer(from: Vec3(0, 1.6, 0), to: Vec3(0, 1, -10)),
        .chat("Hello from the game"),
        .say(speaker: guest, name: "Nurse", text: "Next, please!"),
        .store(save),
        .gesture(speaker: me, wire: "wave"),
        .gesture(speaker: me, wire: "stamp:🎉"),
        .waypoint(Waypoint(position: Vec3(10, 0, -5), label: "Exit", color: ColorRGBA(r: 1, g: 0, b: 0, a: 1))),
        .waypoint(nil),
        .inventory([InventoryItem(name: "Apple", icon: "🍎", count: 3)]),
        .dialog(DialogBox(id: "0", speaker: "Mika", text: "Hi!", choices: ["Yes", "No"])),
        .dialog(nil),
        .shop(ShopPanel(id: "1", title: "Shop", currency: "coins", balance: 120, offers: [ShopOffer(name: "Sword", price: 50, icon: "⚔️")])),
        .shop(nil),
        .countdown(CountdownDisplay(label: "Round", seconds: 90)),
        .countdown(nil),
        .leaderboard(LeaderboardPanel(board)),
        .leaderboard(nil),
        .particles(ParticleBurst(kind: .confetti, position: Vec3(0, 3, 0), amount: 40, seconds: 1, color: nil)),
        .sound(SoundPlay(name: "retro-game-coin-08", volume: 0.5, pitch: 2)),
        .music(MusicPlay(track: "boss", volume: 0.8)),
        .music(nil),
        .speak("Welcome"),
        .vehicle(true),
    ]
    let actions: [EventAction] = [
        .tint(blockID: blockID, color: ColorRGBA(r: 1, g: 0.5, b: 0.25, a: 1), duration: 1),
        .move(blockID: blockID, offset: Vec3(1, 2, 3), duration: 0.5),
        .setVisible(blockID: blockID, visible: false),
        .setCollision(blockID: blockID, enabled: true),
        .teleportPlayer(to: Vec3(0, 5, 0)),
        .awardPoints(-3),
        .announce(message: "Checkpoint reached", duration: 2),
        .playSound(name: "collect"),
        .endRound(message: "Round over"),
        .bouncePlayer(speed: 14),
    ] + scriptEffects.map { EventAction.script($0) }
    add("effects-broadcast", .eventEffect, EventEffectPayload(ruleID: blockID, actions: actions))
    add("effects-targeted", .eventEffect, EventEffectPayload(targetPeerID: guest, actions: [.awardPoints(1)]))

    add("chat", .chat, ChatPayload(senderName: "Mika", text: "こんにちは！"))
    add("chat-stamped", .chat, ChatPayload(senderName: "Mika", text: "hi", senderID: guest))
    add("ping", .ping, PingPayload(nonce: 7, sentAtMilliseconds: 1_790_000_000_123))
    add("pong", .pong, PingPayload(nonce: 4_000_000_000, sentAtMilliseconds: 99))
    add("leave", .leave, LeavePayload(peerID: me, reason: "bye"))

    let inputs: [PlayerInputPayload.Input] = [
        .fire(origin: Vec3(0, 1.6, 0), direction: Vec3(0, 0, -1)),
        .button(id: "buy"),
        .reload,
        .text(id: "name", value: "Rex"),
        .saved(save),
        .gesture("dance"),
    ]
    for (i, input) in inputs.enumerated() { add("input-\(i)", .playerInput, PlayerInputPayload(peerID: me, input: input)) }

    var state = RoomState()
    state.ready = [me, guest]
    state.quieted = [guest]
    state.allowsWarp = false
    state.needsApproval = true
    state.clock = 12.5
    var poll = Poll(question: "Play again?", options: ["Yes", "No"], closesAt: 40, id: blockID)!
    poll.vote(me, choice: 0)
    poll.vote(guest, choice: 1)
    state.poll = poll
    let move = HostMove(newHost: guest, newHostName: "Kai", roomCode: "ABCDEF", isPublic: true, capacity: 8, needsApproval: false, members: [me, guest])
    let rooms: [RoomMessage] = [
        .ready(true), .vote(poll: blockID, choice: 1), .whisper(to: guest, text: "psst"), .state(state), .state(RoomState()),
        .whispered(from: me, name: "Mika", text: "hello"), .waitingForHost, .refused, .removed, .moving(move),
    ]
    for (i, message) in rooms.enumerated() { add("room-\(i)", .room, message) }

    let empty = codec.encodeEmpty(.leave)
    items.append(["name": "leave-empty", "kind": Int(PacketKind.leave.rawValue), "bytes": (empty.header.encoded() + empty.payload).base64EncodedString(), "json": "null", "sequence": Int(empty.header.sequence)])

    let data = try! JSONSerialization.data(withJSONObject: ["sender": me.raw.uuidString, "items": items], options: [.sortedKeys])
    try! data.write(to: URL(fileURLWithPath: out))
    print("emitted \(items.count) packets")
} else {
    let input = try! JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[2]))) as! [String: Any]
    var results: [[String: Any]] = []
    for item in input["items"] as! [[String: Any]] {
        let name = item["name"] as! String
        let bytes = Data(base64Encoded: item["bytes"] as! String)!
        var reassembler = StreamReassembler()
        do {
            let packets = try reassembler.append(bytes)
            guard packets.count == 1 else { throw WireError.decodingFailed("\(packets.count) packets") }
            let packet = packets[0]
            results.append(["name": name, "ok": true, "kind": Int(packet.kind.rawValue), "sender": packet.senderID.raw.uuidString,
                            "json": try reencode(kind: packet.kind, payload: packet.payload, name: name)])
        } catch {
            results.append(["name": name, "ok": false, "error": "\(error)"])
        }
    }
    let data = try! JSONSerialization.data(withJSONObject: ["items": results], options: [.sortedKeys])
    try! data.write(to: URL(fileURLWithPath: CommandLine.arguments[3]))
    print("checked \(results.count) packets, \(results.filter { $0["ok"] as? Bool == false }.count) failed")
}
