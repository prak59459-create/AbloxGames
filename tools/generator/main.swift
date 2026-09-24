import Foundation

// Builds every game's world, checks and plays every game, and writes the
// catalogue: `games/<id>/world.ablox`, `games/<id>/listing.json` and
// `index.json`. The `.absc` files are written by hand and only read here.
//
//   tools/build.sh              build, check, play, write
//   tools/build.sh --only 12    one game
//   tools/build.sh --quick      skip the long robot play
//   tools/build.sh --covers     draw every cover again, write the index, no play

let arguments = CommandLine.arguments
let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let quick = arguments.contains("--quick")
let verbose = arguments.contains("--verbose")
let reachOnly = arguments.contains("--reach")
let only: Int? = arguments.firstIndex(of: "--only").flatMap { i in i + 1 < arguments.count ? Int(arguments[i + 1]) : nil }
let coversOnly = arguments.contains("--covers")

func read(_ path: String) -> String? {
    try? String(contentsOf: root.appendingPathComponent(path), encoding: .utf8)
}

func write(_ data: Data, to path: String) {
    let url = root.appendingPathComponent(path)
    try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    do { try data.write(to: url, options: .atomic) } catch { fatalError("could not write \(path): \(error)") }
}

guard let kit = read(Catalogue.kitPath) else { fatalError("missing \(Catalogue.kitPath)") }

/// The cover already in the game's folder, if any: `cover-<fingerprint>.png`.
func existingCover(in folder: String) -> String? {
    let names = (try? FileManager.default.contentsOfDirectory(atPath: root.appendingPathComponent(folder).path)) ?? []
    return names.filter { $0.hasPrefix("cover-") && $0.hasSuffix(".png") }.sorted().first.map { "\(folder)/\($0)" }
}

/// Draws the cover and saves it under a name that changes with the picture,
/// so the app — which keeps covers it has fetched — sees a new file instead
/// of its old copy. Older covers in the folder are removed.
func drawCover(_ world: WorldDocument, id: String, folder: String) -> String? {
    let settled = Harness.settle(world)
    let picture = Cover.render(settled.world, characters: settled.characters, seed: id)
    let path = "\(folder)/cover-\(picture.fingerprint).png"
    if FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path) { return path }
    let raw = FileManager.default.temporaryDirectory.appendingPathComponent("ablox-cover-\(id).rgb")
    do { try Data(picture.rgb).write(to: raw) } catch { return nil }
    defer { try? FileManager.default.removeItem(at: raw) }
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["python3", root.appendingPathComponent("tools/png.py").path, raw.path,
                         String(picture.width), String(picture.height), root.appendingPathComponent(path).path]
    do { try process.run() } catch { return nil }
    process.waitUntilExit()
    guard process.terminationStatus == 0 else { return nil }
    let names = (try? FileManager.default.contentsOfDirectory(atPath: root.appendingPathComponent(folder).path)) ?? []
    for name in names where name.hasPrefix("cover-") && name.hasSuffix(".png") && "\(folder)/\(name)" != path {
        try? FileManager.default.removeItem(at: root.appendingPathComponent(folder).appendingPathComponent(name))
    }
    return path
}

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

    // Drawn again for the game being worked on, for every game with
    // --covers, and for any game that has none yet.
    var cover = existingCover(in: game.folder)
    if coversOnly || only == game.number || cover == nil {
        var scripted = world
        scripted.scripts = paths.map { path in
            let name = String(path.split(separator: "/").last ?? "main.absc")
            return ScriptFile(name: name, source: path == Catalogue.kitPath ? kit : (read(path) ?? ""))
        }
        cover = drawCover(scripted, id: game.id, folder: game.folder) ?? cover
    }

    let listing = GameListing(
        id: game.id, title: game.title, author: Catalogue.author, summary: game.summary,
        world: "\(game.folder)/world.ablox", cover: cover, scripts: paths,
        tags: game.tags, blockCount: world.blocks.count, maxPlayers: game.maxPlayers,
        schemaVersion: WorldDocument.currentSchemaVersion, updatedAt: Catalogue.date
    )
    listings.append(listing)

    if coversOnly {
        write(Data((listing.indexEntryJSON() + "\n").utf8), to: "\(game.folder)/listing.json")
        print("🖼 \(String(format: "%2d", game.number)) \(game.id) — \(cover ?? "no cover")")
        continue
    }
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
    writeReadmeList(listings)
}

/// The game list in README.md, with each cover, between the two markers.
func writeReadmeList(_ listings: [GameListing]) {
    guard var readme = read("README.md"),
          let start = readme.range(of: "<!-- games:start -->"),
          let end = readme.range(of: "<!-- games:end -->"), start.upperBound <= end.lowerBound else { return }
    let sections: [(String, ClosedRange<Int>)] = [
        ("🔥 人気の定番", 1...20), ("⚔️ アクション・バトル", 21...32), ("🏡 ロールプレイ・生活", 33...45),
        ("👻 ホラー・サバイバル", 46...58), ("🏗️ 放置・ガチャ・タイクーン", 59...70), ("🏃 アスレチック・ミニゲーム", 71...80)
    ]
    var text = "\n"
    for (heading, numbers) in sections {
        text += "### \(heading)\n\n| | # | ゲーム | 内容 |\n|---|---|---|---|\n"
        for game in Catalogue.games where numbers.contains(game.number) {
            guard let listing = listings.first(where: { $0.id == game.id }) else { continue }
            let picture = listing.cover.map { "<img src=\"\($0)\" width=\"200\">" } ?? ""
            let summary = listing.summary.replacingOccurrences(of: "|", with: "｜")
            text += "| \(picture) | \(game.number) | **\(listing.title)** | \(summary) |\n"
        }
        text += "\n"
    }
    readme.replaceSubrange(start.upperBound..<end.lowerBound, with: text)
    write(Data(readme.utf8), to: "README.md")
}
print("\(listings.count) games, \(validated.accepted.count) accepted, \(failures) with problems")
exit(failures == 0 ? 0 : 1)
