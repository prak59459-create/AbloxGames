import Foundation

/// One game in the catalogue: what the list says about it, and its map.
struct Game {
    let number: Int
    /// The folder under `games/`, and the listing's id.
    let id: String
    let title: String
    /// Japanese, one or two sentences: the people browsing the list read it.
    let summary: String
    let tags: [String]
    let maxPlayers: Int
    let build: (MapBuilder) -> Void

    var folder: String { "games/\(id)" }

    /// Every `.absc` in the game's folder, in the order they run: `data.absc`
    /// first (tables other files read), then the rest alphabetically, then
    /// `main.absc` last (it sets the game up with everything defined).
    func scriptPaths(root: URL) -> [String] {
        let dir = root.appendingPathComponent(folder)
        let names = ((try? FileManager.default.contentsOfDirectory(atPath: dir.path)) ?? [])
            .filter { $0.hasSuffix(".absc") }
        let middle = names.filter { $0 != "data.absc" && $0 != "main.absc" }.sorted()
        let ordered = (names.contains("data.absc") ? ["data.absc"] : []) + middle + (names.contains("main.absc") ? ["main.absc"] : [])
        return [Catalogue.kitPath] + ordered.map { "\(folder)/\($0)" }
    }
}

enum Catalogue {
    static let author = "Ablox Games"
    static let kitPath = "lib/kit.absc"
    /// Fixed, so regenerating does not change every file for nothing.
    static let date = ISO8601DateFormatter().date(from: "2026-09-24T00:00:00Z")!

    static var games: [Game] {
        (topGames + actionGames + lifeGames + horrorGames + idleGames + miniGames).sorted { $0.number < $1.number }
    }

    /// A UUID that is the same every run for the same text.
    static func stableID(_ text: String) -> UUID {
        var a: UInt64 = 0xcbf29ce484222325, b: UInt64 = 0x84222325cbf29ce4
        for byte in text.utf8 {
            a = (a ^ UInt64(byte)) &* 0x100000001b3
            b = (b ^ UInt64(byte)) &* 0x1000193 &+ 0x9E3779B97F4A7C15
        }
        var bytes = [UInt8](repeating: 0, count: 16)
        for i in 0..<8 {
            bytes[i] = UInt8((a >> (UInt64(i) * 8)) & 0xFF)
            bytes[8 + i] = UInt8((b >> (UInt64(i) * 8)) & 0xFF)
        }
        bytes[6] = (bytes[6] & 0x0F) | 0x40
        bytes[8] = (bytes[8] & 0x3F) | 0x80
        return UUID(uuid: (bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7],
                           bytes[8], bytes[9], bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]))
    }
}
