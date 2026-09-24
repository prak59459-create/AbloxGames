import Foundation

// Builds every game's world, checks and plays every game, and writes the
// catalogue: `games/<id>/world.ablox`, `games/<id>/listing.json` and
// `index.json`. The `.absc` files are written by hand and only read here.
//
//   tools/build.sh              build, check, play, write
//   tools/build.sh --only 12    one game
//   tools/build.sh --quick      skip the long robot play

let arguments = CommandLine.arguments
let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let quick = arguments.contains("--quick")
let verbose = arguments.contains("--verbose")
let reachOnly = arguments.contains("--reach")
let only: Int? = arguments.firstIndex(of: "--only").flatMap { i in i + 1 < arguments.count ? Int(arguments[i + 1]) : nil }

func read(_ path: String) -> String? {
    try? String(contentsOf: root.appendingPathComponent(path), encoding: .utf8)
}

func write(_ data: Data, to path: String) {
    let url = root.appendingPathComponent(path)
    try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    do { try data.write(to: url, options: .atomic) } catch { fatalError("could not write \(path): \(error)") }
}

guard let kit = read(Catalogue.kitPath) else { fatalError("missing \(Catalogue.kitPath)") }

var listings: [GameListing] = []
var failures = 0
var seenIDs = Set<String>()
let wireEncoder = WorldDocument.makeWireEncoder()

for game in Catalogue.games {
    precondition(seenIDs.insert(game.id).inserted, "duplicate id \(game.id)")
    let builder = MapBuilder()
    game.build(builder)
    let world = builder.build(name: game.title, author: Catalogue.author)

    let paths = game.scriptPaths(root: root)
    guard paths.contains("\(game.folder)/main.absc") else {
        print("✗ \(game.number) \(game.id): no main.absc")
        failures += 1
        continue
    }
    var playable = world
    playable.scripts = paths.map { path in
        let name = String(path.split(separator: "/").last ?? "main.absc")
        return ScriptFile(name: name, source: path == Catalogue.kitPath ? kit : (read(path) ?? ""))
    }

    let listing = GameListing(
        id: game.id, title: game.title, author: Catalogue.author, summary: game.summary,
        world: "\(game.folder)/world.ablox", cover: nil, scripts: paths,
        tags: game.tags, blockCount: world.blocks.count, maxPlayers: game.maxPlayers,
        schemaVersion: WorldDocument.currentSchemaVersion, updatedAt: Catalogue.date
    )
    listings.append(listing)

    if let only, only != game.number { continue }

    var problems: [String] = []
    if let rejection = listing.rejection() { problems.append("listing: \(rejection)") }
    if world.spawnBlocks.isEmpty { problems.append("no spawn pad") }
    if world.blocks.count > GameCatalogue.Limits.maximumBlocks { problems.append("\(world.blocks.count) blocks") }
    // Pads nobody can walk to are reported, not failed: a few are meant to
    // be reached only by a script's teleport (an exam hall, a jail cell).
    let unreachable = Reach.unreachablePads(in: world)
    problems += GameRuntime.check(playable.scripts).map { "check: \($0.description)" }

    // The world file carries no scripts: the listing's `.absc` files are the
    // only copy, so editing one on GitHub changes the game.
    let data = try! wireEncoder.encode(world)
    if data.count > GameCatalogue.Limits.maximumWorldBytes { problems.append("world is \(data.count) bytes") }
    if let decoded = try? WorldDocument.decoded(from: data) {
        if decoded.blocks.count != listing.blockCount { problems.append("block count mismatch") }
    } else {
        problems.append("world does not decode")
    }

    if reachOnly {
        if !unreachable.isEmpty { print("⚠ \(game.number) \(game.id): " + unreachable.joined(separator: ", ")) }
        continue
    }

    var note = ""
    if problems.isEmpty {
        let report = Harness.play(playable, seconds: quick ? 40 : 150)
        problems += report.errors.map { "play: \($0)" }
        // Again with rich robots, who can buy everything.
        let rich = Harness.play(playable, seconds: quick ? 40 : 150, seed: 29, rich: true)
        problems += rich.errors.filter { !report.errors.contains($0) }.map { "play (rich): \($0)" }
        if verbose {
            for line in report.output.prefix(40) { print("    print: \(line)") }
            print("    buttons: " + report.buttonsPressed.union(rich.buttonsPressed).sorted().joined(separator: " "))
        }
        let lines = playable.scripts.dropFirst().reduce(0) { $0 + $1.source.split(separator: "\n", omittingEmptySubsequences: false).count }
        note = "\(playable.scripts.count - 1) files, \(lines) lines, \(world.blocks.count) blocks, \(report.buttonsPressed.count) buttons, \(report.touches) touches, "
            + "\(report.npcsSeen) npcs max, \(report.blocksAtEnd) blocks after" + (report.roundEnded ? ", round ended" : "")
    }

    write(data, to: "\(game.folder)/world.ablox")
    write(Data((listing.indexEntryJSON() + "\n").utf8), to: "\(game.folder)/listing.json")

    if problems.isEmpty {
        print("✓ \(String(format: "%2d", game.number)) \(game.id) — \(note)")
        if !unreachable.isEmpty { print("    ⚠ no walking route from a spawn to: " + unreachable.joined(separator: ", ")) }
    } else {
        failures += 1
        print("✗ \(String(format: "%2d", game.number)) \(game.id)")
        for problem in problems.prefix(12) { print("    \(problem)") }
    }
}

// The index, checked the way the app will check it.
let catalogue = GameCatalogue(updatedAt: Catalogue.date, games: listings)
let encoder = JSONEncoder()
encoder.dateEncodingStrategy = .iso8601
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
let index = try! encoder.encode(catalogue)
let decoded = try! GameCatalogue.decode(indexData: index)
let validated = decoded.validated()
if !validated.rejected.isEmpty {
    failures += validated.rejected.count
    for (id, reason) in validated.rejected { print("✗ index rejects \(id): \(reason)") }
}
if only == nil {
    write(index + Data("\n".utf8), to: "index.json")
}
print("\(listings.count) games, \(validated.accepted.count) accepted, \(failures) with problems")
exit(failures == 0 ? 0 : 1)
