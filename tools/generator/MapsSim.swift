import Foundation

// Games 111–125: simulators, each after a simulator popular on Roblox
// (docs/research-150.md). They run on lib/kit_sim.absc: tap to train or
// collect, sell, buy better tools, hatch pets, be reborn.

let simGames: [Game] = [
    Game(number: 123, id: "dig-it-deep", title: "Dig It Deep",
         summary: "どこでもほれる宝ほり！ ⛏をおすタイミングが みどりのときだと ザクザクほれる。化石・宝石・むかしの道具…なにが出るかな？ 図かんをうめて、のはら・はまべ・どうくつ・かざんへ！",
         tags: ["simulator", "treasure", "collect"], maxPlayers: 10, libs: ["sim"], build: digItDeep),
    Game(number: 122, id: "gym-league-stars", title: "Gym League Stars",
         summary: "うで・あし・むね・せなか、4つのマシンでバランスよくきたえよう！ スタミナがへったらプロテイン。3分ごとの大会では、しんぱんの言うポーズをすばやく決めろ！ ブロンズからダイヤリーグへ。",
         tags: ["simulator", "training", "contest"], maxPlayers: 12, libs: ["sim"], build: gymLeagueStars),
    Game(number: 121, id: "snowball-shovel-sim", title: "Snowball Shovel Sim",
         summary: "スコップで雪山をほって、雪をためて売ろう！ 雪で自分の雪だるまをつくると、ずっとボーナス。村・こおった湖・氷の山へ。スコップ・そり・ペットで、雪の王さまになろう！",
         tags: ["simulator", "winter", "pets"], maxPlayers: 8, libs: ["sim"], build: snowballShovelSim),
    Game(number: 120, id: "saber-swing-sim", title: "Saber Swing Sim",
         summary: "セイバーをふって力をためよう！ DNAびんがいっぱいになったら 売ってお金に。力がつくほど体が大きくなる。ときどきあらわれるボスに みんなでいどめ！ セイバー・DNA・ペットで最強の騎士へ。",
         tags: ["simulator", "boss", "pets"], maxPlayers: 12, libs: ["sim"], build: saberSwingSim),
    Game(number: 119, id: "mega-magnet-sim", title: "Mega Magnet Sim",
         summary: "マグネットでコインをすいよせろ！ 歩くだけで近くのコインがあつまる。リュックがいっぱいになったら銀行へ。強いマグネットほど遠くまで、大きなコイン。公園・町・金庫の部屋へ！",
         tags: ["simulator", "idle", "pets"], maxPlayers: 12, libs: ["sim"], build: megaMagnetSim),
    Game(number: 118, id: "sand-treasure-hunt", title: "Sand Treasure Hunt",
         summary: "スコップで砂をほって、うまっている宝箱をさがそう！ 🔎たんちきが近いほど ピピピ。砂はリュックにためて売る。ビーチ・ジャングル・さばくへ、伝説の宝箱をほりあてろ！",
         tags: ["simulator", "treasure", "pets"], maxPlayers: 10, libs: ["sim"], build: sandTreasureHunt),
    Game(number: 117, id: "deep-mine-simulator", title: "Deep Mine Simulator",
         summary: "つるはしで地下をほり進もう！ 深くなるほど かたい岩と レアな鉱石。リュックがいっぱいになったら地上で売る。つるはし・リュック・ペットで、いちばん下のマグマの宝石まで！",
         tags: ["simulator", "mining", "pets"], maxPlayers: 10, libs: ["sim"], build: deepMineSimulator),
    Game(number: 116, id: "arm-wrestle-champions", title: "Arm Wrestle Champions",
         summary: "うでずもうチャンピオンをめざせ！ にぎる道具でうでをきたえて、テーブルのライバルに勝負。💪を連打して押しかえせ！ ボスに勝つと次のエリアへ。友だちとの対戦テーブルも。",
         tags: ["simulator", "battle", "pets"], maxPlayers: 12, libs: ["sim"], build: armWrestleChampions),
    Game(number: 115, id: "tap-race-clicker", title: "Tap Race Clicker",
         summary: "タップタイムに いっぱいタップして速さをためて、レースで いっきに走れ！ 50mごとのゲートをくぐるたびに ごほうび。ペットと生まれかわりで、1500mのコースを走りきろう。",
         tags: ["simulator", "clicker", "racing"], maxPlayers: 12, libs: ["sim", "rounds"], build: tapRaceClicker),
    Game(number: 114, id: "speed-legends-city", title: "Speed Legends City",
         summary: "走れば走るほど速くなる！ 町を走ってステップをため、光る玉とリングを集めよう。くつを強くしてもっと速く、さばくの町・ようがんの谷へ。🏁レースで1位をねらえ！",
         tags: ["simulator", "running", "racing"], maxPlayers: 12, libs: ["sim"], build: speedLegendsCity),
    Game(number: 113, id: "shadow-ninja-legends", title: "Shadow Ninja Legends",
         summary: "刀をふって にんじゅつ をためよう！ 帯がいっぱいになったら ほこらで売ってお金に。ランクが上がると空中ジャンプの回数がふえて、空の修行島へ。刀・帯・ペットで、影の忍者をめざせ！",
         tags: ["simulator", "ninja", "pets"], maxPlayers: 12, libs: ["sim"], build: shadowNinjaLegends),
    Game(number: 112, id: "mega-muscle-legends", title: "Mega Muscle Legends",
         summary: "タップでトレーニング、きんにくムキムキ！ パワーがつくほど体が大きくなる。浜辺のジムから、氷・神話・永遠のジムへ。岩をこわしてお金、アリーナでパンチ勝負。ペットと生まれかわりで最強へ！",
         tags: ["simulator", "training", "pets"], maxPlayers: 12, libs: ["sim"], build: megaMuscleLegends),
    Game(number: 111, id: "bubble-gum-legends", title: "Bubble Gum Legends",
         summary: "ガムをかんで大きなあわをふくらませて売ろう！ あわが大きいほどお金に。空にうかぶ島へバブルジャンプで上がると、もっと高く売れる。たまごからペット、生まれかわってもっと大きく！",
         tags: ["simulator", "pets", "idle"], maxPlayers: 12, libs: ["sim", "ride"], build: bubbleGumLegends),
]

// MARK: 111 Bubble Gum Legends (Bubble Gum Simulator INFINITY)

/// The five islands: centre (x, y, z) and radius. The first is the ground.
let bubbleIslands: [(Float, Float, Float, Float)] = [(0, 0, 0, 60), (40, 30, 40, 20), (-40, 60, 40, 20), (-40, 90, -30, 20), (30, 120, -40, 22)]

func bubbleGumLegends(_ m: MapBuilder) {
    m.sky("#F9A8D4", "#FDF2F8", light: 0.75, showGround: false, fall: -20)
    m.environment.skyStyle = .clouds
    let colors = ["#86EFAC", "#E0F2FE", "#C4B5FD", "#FBCFE8", "#312E81"]
    let tops = ["#4ADE80", "#F8FAFC", "#A78BFA", "#F472B6", "#1E1B4B"]
    for (i, isl) in bubbleIslands.enumerated() {
        let (x, y, z, r) = isl
        let k = i + 1
        m.part("Island \(k)", at: (x, y - 3, z), size: (r * 2, 6, r * 2), color: colors[i], shape: .cylinder, material: i == 0 ? .grass : .matte)
        m.part("Island \(k) Top", at: (x, y + 0.02, z), size: (r * 2 - 2, 0.04, r * 2 - 2), color: tops[i], shape: .cylinder, solid: false)
        m.part("Island \(k) Rock", at: (x, y - 9, z), size: (r * 1.2, 8, r * 1.2), color: colors[i], shape: .cone, solid: false, rotation: (180, 0, 0))
        // Sell pad (worth more higher up), a chest, candies.
        m.pad("Sell \(k)", x: x - r * 0.45, z: z, y: y, size: 4, color: "#FACC15", tags: ["bsell", "k=\(k)"])
        m.part("Sell Sign \(k)", at: (x - r * 0.45, y + 3, z - 2.4), size: (4, 1.2, 0.2), color: "#FACC15", material: .neon, solid: false)
        m.slab("Chest \(k)", x: x + r * 0.45, y: y, z: z - r * 0.3, w: 2.4, h: 1.6, d: 1.6, color: "#B45309", material: .wood)
        m.pad("Chest Pad \(k)", x: x + r * 0.45, z: z - r * 0.3 + 2.2, y: y, size: 2.4, color: "#F59E0B", tags: ["chest", "k=\(k)"])
        for q in 0..<5 {
            let a = Float(q) / 5 * 2 * .pi + 0.4
            m.part("Candy", at: (x + cos(a) * r * 0.7, y + 1, z + sin(a) * r * 0.7), size: (1, 1, 1), color: ["#F472B6", "#38BDF8", "#FACC15", "#4ADE80", "#A78BFA"][q],
                   shape: .sphere, material: .neon, behavior: .trigger, tags: ["candy", "k=\(k)"])
        }
        // A bubble-jump pad to the next island, and where it lands.
        if k < bubbleIslands.count {
            let next = bubbleIslands[k]
            let dx = next.0 - x, dz = next.2 - z
            let len = (dx * dx + dz * dz).squareRoot()
            m.pad("Jump \(k)", x: x + dx / len * r * 0.6, z: z + dz / len * r * 0.6, y: y, size: 3.4, color: "#EC4899", tags: ["bjump", "k=\(k)"])
            m.part("Jump Bubble \(k)", at: (x + dx / len * r * 0.6, y + 2.2, z + dz / len * r * 0.6), size: (2.6, 2.6, 2.6), color: "#F9A8D4", shape: .sphere,
                   material: .glass, solid: false, opacity: 0.45)
            m.part("Land \(k + 1)", at: (next.0 - dx / len * next.3 * 0.5, next.1 + 0.8, next.2 - dz / len * next.3 * 0.5), size: (1, 1, 1), color: "#000000",
                   solid: false, visible: false)
        }
    }
    // The ground island: spawn, the gum machine, the shop and eggs.
    m.spawnRing(0, 8, radius: 4, count: 8, color: "#F472B6")
    m.part("Gum Machine Globe", at: (0, 7, -14), size: (8, 8, 8), color: "#F9A8D4", shape: .sphere, material: .glass, solid: false, opacity: 0.6)
    for q in 0..<12 {
        let a = Float(q) / 12 * 2 * .pi
        m.part("Gumball", at: (cos(a) * 2.2, 6 + Float(q % 3), -14 + sin(a) * 2.2), size: (1.2, 1.2, 1.2), color: ["#EF4444", "#FACC15", "#3B82F6", "#22C55E"][q % 4],
               shape: .sphere, solid: false)
    }
    m.slab("Gum Machine Base", x: 0, y: 0, z: -14, w: 6, h: 3, d: 6, color: "#DC2626")
    m.pad("Shop Pad", x: -8, z: -6, size: 3.4, color: "#3B82F6", tags: ["shop"])
    m.pad("Egg Pad", x: 8, z: -6, size: 3.4, color: "#A855F7", tags: ["eggs"])
    for (i, ex) in [4, 8, 12].enumerated() {
        m.part("Egg Display", at: (Float(ex), 1.2, -10), size: (1.6, 2.2, 1.6), color: ["#F8FAFC", "#FBCFE8", "#312E81"][i], shape: .sphere, solid: false)
    }
    var r = Seeded("bubble")
    for _ in 0..<18 {
        let a = r.range(0, 2 * .pi), d = r.range(30, 55)
        m.tree(cos(a) * d, sin(a) * d, height: r.range(4, 6), leaves: r.pick(["#F472B6", "#4ADE80", "#FACC15"]))
    }
    for _ in 0..<30 {
        m.part("Cloud", at: (r.range(-120, 120), r.range(10, 140), r.range(-120, 120)), size: (r.range(10, 24), r.range(3, 5), r.range(8, 18)),
               color: "#FFFFFF", material: .matte, solid: false, opacity: 0.8)
    }
    m.coverFocus(x: 0, y: 3, z: -8, yaw: 200, width: 30)
}

// MARK: 112 Mega Muscle Legends (Muscle Legends)

/// The four gyms: centre (x, z), size, and colours.
let muscleGyms: [(Float, Float, Float, String, String)] = [(-50, -40, 36, "#FDE68A", "#F59E0B"), (50, -40, 36, "#E0F2FE", "#38BDF8"),
                                                           (50, 50, 36, "#F5D0FE", "#A855F7"), (-50, 50, 36, "#FEF3C7", "#EAB308")]

func megaMuscleLegends(_ m: MapBuilder) {
    m.day(ground: "#FDE68A")
    m.environment.skyStyle = .clouds
    m.ground(260, 260, color: "#FDE68A", material: .sand)
    m.water(0, 125, w: 260, d: 20, name: "Sea", color: "#0EA5E9", tags: ["scenery"])
    m.spawnRing(0, 0, radius: 4, count: 8, color: "#EF4444")
    m.pad("Shop Pad", x: -8, z: 8, size: 3.2, color: "#3B82F6", tags: ["shop"])
    m.pad("Egg Pad", x: 8, z: 8, size: 3.2, color: "#A855F7", tags: ["eggs"])
    m.part("Statue", at: (0, 4, -8), size: (2.4, 8, 2.4), color: "#94A3B8", shape: .cylinder, material: .stone, solid: true)
    m.part("Statue Arms", at: (0, 7.2, -8), size: (6, 1.2, 1.2), color: "#94A3B8", material: .stone, solid: false)
    for (i, g) in muscleGyms.enumerated() {
        let (cx, cz, size, floor, trim) = g
        let k = i + 1
        m.slab("Gym Floor \(k)", x: cx, y: -0.02, z: cz, w: size, h: 0.1, d: size, color: floor)
        // Walls with the doorway facing the middle of the map.
        let h: Float = 3.2, half = size / 2
        let doorZ: Float = cz < 0 ? half : -half
        m.slab("Gym Wall", x: cx, y: 0, z: cz - doorZ, w: size, h: h, d: 0.6, color: trim)
        m.slab("Gym Wall", x: cx - half, y: 0, z: cz, w: 0.6, h: h, d: size, color: trim)
        m.slab("Gym Wall", x: cx + half, y: 0, z: cz, w: 0.6, h: h, d: size, color: trim)
        m.slab("Gym Wall", x: cx - half / 2 - 2.5, y: 0, z: cz + doorZ, w: half - 5, h: h, d: 0.6, color: trim)
        m.slab("Gym Wall", x: cx + half / 2 + 2.5, y: 0, z: cz + doorZ, w: half - 5, h: h, d: 0.6, color: trim)
        m.part("Gate \(k)", at: (cx, 1.8, cz + doorZ), size: (10, 3.6, 1.6), color: trim, material: .neon, behavior: .trigger,
               tags: ["sim_gate", "n=\(k)"], solid: false, opacity: 0.35)
        m.part("Gym Sign \(k)", at: (cx, 4.4, cz + doorZ), size: (10, 1.4, 0.3), color: trim, material: .neon, solid: false)
        // Equipment: benches, racks, a treadmill, big dumbbells.
        for q in 0..<3 {
            let ex = cx - 10 + Float(q) * 10
            m.slab("Bench", x: ex, y: 0, z: cz - doorZ * 0.4, w: 1.4, h: 0.8, d: 3.4, color: "#1F2937")
            m.part("Barbell", at: (ex, 1.6, cz - doorZ * 0.4 - 0.8), size: (4, 0.2, 0.2), color: "#94A3B8", material: .metal, solid: false)
            for sx in [-1.9, 1.9] as [Float] {
                m.part("Plate", at: (ex + sx, 1.6, cz - doorZ * 0.4 - 0.8), size: (0.3, 1.2, 1.2), color: "#111827", shape: .cylinder, solid: false,
                       rotation: (0, 0, 90))
            }
        }
        m.slab("Treadmill", x: cx - 12, y: 0, z: cz + doorZ * 0.2, w: 2.4, h: 0.4, d: 4, color: "#374151")
        m.part("Giant Dumbbell", at: (cx + 12, 1, cz + doorZ * 0.2), size: (5, 1, 1), color: trim, material: .metal, solid: false)
        m.part("Zone \(k)", at: (cx, 0.5, cz), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    }
    // Rocks to smash, stronger ones further out.
    let rocks: [(Float, Float, Float)] = [(-14, -18, 2), (14, -18, 2.6), (-22, 20, 3.2), (22, 20, 3.8), (0, -80, 4.6), (0, 86, 5.5)]
    for (i, rk) in rocks.enumerated() {
        m.part("Rock \(i + 1)", at: (rk.0, rk.2 / 2, rk.1), size: (rk.2 * 1.3, rk.2, rk.2 * 1.3), color: ["#A8A29E", "#78716C", "#57534E", "#7C2D12", "#1E3A8A", "#581C87"][i],
               shape: .sphere, material: .stone)
        m.pad("Rock Pad \(i + 1)", x: rk.0, z: rk.1 + rk.2 * 0.9 + 1.2, size: 2.4, color: "#EF4444", tags: ["rock", "n=\(i + 1)"])
    }
    // The arena.
    m.part("Arena", at: (0, 0.05, 50), size: (26, 0.1, 26), color: "#DC2626", shape: .cylinder, solid: false)
    m.part("Arena Ring", at: (0, 0.3, 50), size: (27, 0.6, 27), color: "#F8FAFC", shape: .cylinder, solid: false, opacity: 0.3)
    m.part("Arena Mark", at: (0, 0.5, 50), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    var r = Seeded("muscle")
    for _ in 0..<20 {
        let x = r.range(-125, 125), z = r.range(-120, 110)
        if abs(x) < 72 && abs(z) < 72 { continue }
        m.pine(x, z, height: r.range(6, 9), leaves: "#16A34A")
    }
    m.coverFocus(x: -50, y: 1.5, z: -40, yaw: 20, width: 36)
}

// MARK: 113 Shadow Ninja Legends (Ninja Legends)

/// The sky islands: centre (x, top y, z) and radius. Higher ones need more air jumps.
let ninjaIslands: [(Float, Float, Float, Float)] = [(10, 10, 6, 7), (-2, 26, 16, 7), (-14, 46, 6, 7), (-4, 72, -8, 8), (12, 104, 2, 9)]

func shadowNinjaLegends(_ m: MapBuilder) {
    m.dusk(ground: "#3F3F46")
    m.environment.skyStyle = .sunset
    m.ground(220, 220, color: "#57534E", material: .stone)
    m.slab("Courtyard", x: 0, y: -0.02, z: 0, w: 70, h: 0.06, d: 70, color: "#D6D3D1", material: .stone)
    m.spawnRing(0, -20, radius: 4, count: 8, color: "#DC2626")
    // The dojo and the shrine where ninjitsu is sold.
    m.slab("Dojo", x: 0, y: 0, z: -34, w: 24, h: 6, d: 12, color: "#7C2D12", material: .wood)
    m.part("Dojo Roof", at: (0, 8, -34), size: (28, 3, 16), color: "#1C1917", shape: .cone, solid: false)
    m.slab("Shrine", x: -26, y: 0, z: -12, w: 8, h: 4, d: 6, color: "#DC2626")
    m.part("Torii", at: (-26, 5.5, -6), size: (9, 0.6, 0.6), color: "#DC2626", solid: false)
    for x in [-29.5, -22.5] as [Float] { m.slab("Torii Post", x: x, y: 0, z: -6, w: 0.6, h: 5.5, d: 0.6, color: "#DC2626") }
    m.pad("Sell 1", x: -26, z: -3, size: 3.6, color: "#FACC15", tags: ["nsell", "k=1"])
    m.pad("Shop Pad", x: 20, z: -12, size: 3.2, color: "#3B82F6", tags: ["shop"])
    m.pad("Egg Pad", x: 26, z: -12, size: 3.2, color: "#A855F7", tags: ["eggs"])
    // Training dummies round the courtyard.
    for q in 0..<8 {
        let a = Float(q) / 8 * 2 * .pi
        m.part("Dummy", at: (cos(a) * 26, 1.2, 10 + sin(a) * 12), size: (0.8, 2.4, 0.8), color: "#A16207", shape: .cylinder, material: .wood)
    }
    // A bamboo grove.
    var r = Seeded("ninja")
    for _ in 0..<60 {
        let x = r.range(-100, 100), z = r.range(-100, 100)
        if abs(x) < 40 && abs(z) < 44 { continue }
        m.part("Bamboo", at: (x, 5, z), size: (0.5, 10, 0.5), color: "#65A30D", shape: .cylinder, solid: false)
    }
    // Sky islands, each with a training ground, a shrine to sell at, and a chest.
    let colors = ["#A3E635", "#38BDF8", "#F472B6", "#FACC15", "#A78BFA"]
    for (i, isl) in ninjaIslands.enumerated() {
        let (x, y, z, rad) = isl
        let k = i + 1
        m.part("Sky Island \(k)", at: (x, y - 1, z), size: (rad * 2, 2, rad * 2), color: "#78716C", shape: .cylinder, material: .stone)
        m.part("Sky Island \(k) Top", at: (x, y + 0.02, z), size: (rad * 2 - 1, 0.04, rad * 2 - 1), color: colors[i], shape: .cylinder, solid: false)
        m.part("Sky Island \(k) Root", at: (x, y - 5, z), size: (rad * 1.3, 6, rad * 1.3), color: "#57534E", shape: .cone, solid: false,
               rotation: (180, 0, 0))
        m.pad("Sell \(k + 1)", x: x - rad * 0.45, z: z, y: y, size: 2.6, color: "#FACC15", tags: ["nsell", "k=\(k + 1)"])
        m.pad("Chest \(k)", x: x + rad * 0.45, z: z, y: y, size: 2.4, color: "#F59E0B", tags: ["nchest", "k=\(k)"])
        m.slab("Chest Box", x: x + rad * 0.45, y: y, z: z + 1.8, w: 1.8, h: 1.2, d: 1.2, color: "#B45309", material: .wood)
        m.part("Island Lantern", at: (x, y + 1.2, z - rad * 0.5), size: (0.8, 1.4, 0.8), color: colors[i], material: .neon, solid: false)
        m.part("Train \(k)", at: (x, y + 0.5, z), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    }
    m.coverFocus(x: 0, y: 3, z: -24, yaw: 200, width: 40)
}

// MARK: 114 Speed Legends City (Legends of Speed)

func speedLegendsCity(_ m: MapBuilder) {
    m.sky("#60A5FA", "#E0F2FE", light: 0.75, showGround: false, fall: -25)
    m.environment.skyStyle = .clouds
    // Three separate lands: the city, the desert (north) and the magma valley (east). Pads carry you between them.
    m.ground(340, 300, color: "#A3A3A3", z: -20, material: .matte)
    m.ground(220, 180, color: "#FCD34D", name: "Desert", z: 300, material: .sand)
    m.ground(200, 200, color: "#7F1D1D", name: "Magma Land", x: 380, z: 0, material: .stone)
    for v in [-80, -40, 0, 40, 80] as [Float] {
        m.road(from: (-100, v), to: (100, v), width: 10, name: "Street")
        m.road(from: (v, -100), to: (v, 100), width: 10, y: 0.025, name: "Street")
    }
    var r = Seeded("speed")
    for bx in [-60, -20, 20, 60] as [Float] {
        for bz in [-60, -20, 20, 60] as [Float] where !(abs(bx) == 20 && abs(bz) == 20) {
            let h = r.range(10, 40)
            m.slab("Tower", x: bx, y: 0, z: bz, w: 22, h: h, d: 22, color: r.pick(["#CBD5E1", "#94A3B8", "#E2E8F0", "#FDE68A", "#BFDBFE"]))
            m.part("Tower Windows", at: (bx, h / 2, bz - 11.1), size: (18, h * 0.8, 0.1), color: "#7DD3FC", material: .glass, solid: false, opacity: 0.5)
        }
    }
    m.slab("Plaza", x: 0, y: -0.01, z: 0, w: 58, h: 0.05, d: 58, color: "#E5E7EB")
    m.spawnRing(0, 0, radius: 4, count: 8, color: "#22D3EE")
    m.pad("Shop Pad", x: -10, z: 10, size: 3.2, color: "#3B82F6", tags: ["shop"])
    m.pad("Egg Pad", x: 10, z: 10, size: 3.2, color: "#A855F7", tags: ["eggs"])
    m.part("Speed Statue", at: (0, 3, -12), size: (2, 6, 2), color: "#FACC15", shape: .cylinder, material: .metal)
    // Travel pads.
    m.pad("Go 2", x: -14, z: -10, size: 3.2, color: "#F59E0B", tags: ["goto", "n=2"])
    m.pad("Go 3", x: 14, z: -10, size: 3.2, color: "#EF4444", tags: ["goto", "n=3"])
    m.part("Arrive 1", at: (0, 0.6, 6), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    m.part("Arrive 2", at: (0, 0.6, 240), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    m.part("Arrive 3", at: (300, 0.6, 0), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    m.pad("Back 2", x: 0, z: 232, size: 3.2, color: "#22D3EE", tags: ["goto", "n=1"])
    m.pad("Back 3", x: 292, z: 0, size: 3.2, color: "#22D3EE", tags: ["goto", "n=1"])
    for _ in 0..<14 { m.part("Lava Pool", at: (r.range(300, 470), 0.05, r.range(-90, 90)), size: (r.range(6, 14), 0.1, r.range(6, 14)), color: "#F97316",
                             shape: .cylinder, material: .neon, solid: false) }
    for _ in 0..<16 { m.pillar("Cactus", x: r.range(-100, 100), z: r.range(230, 380), height: r.range(2, 4), radius: 0.4, color: "#3F6212") }
    for _ in 0..<5 { m.part("Pyramid", at: (r.pick([r.range(-100, -60), r.range(60, 100)]), 8, r.range(260, 370)), size: (18, 16, 18), color: "#D97706", shape: .cone,
                            material: .sand, solid: false) }
    // Orbs to collect in each land, and hoops.
    for (area, cx, cz, w, d) in [(1, Float(0), Float(0), Float(190), Float(190)), (2, 0, 300, 200, 160), (3, 380, 0, 180, 180)] {
        for _ in 0..<(area == 1 ? 40 : 30) {
            let x = cx + r.range(-w / 2, w / 2), z = cz + r.range(-d / 2, d / 2)
            let kind = r.unit() < 0.75 ? "step" : "gem"
            m.part("Orb", at: (x, 1.2, z), size: (1.2, 1.2, 1.2), color: kind == "step" ? ["#EF4444", "#F97316", "#A855F7"][area - 1] : "#22D3EE", shape: .sphere,
                   material: .neon, behavior: .trigger, tags: ["orb", "kind=\(kind)", "area=\(area)"], solid: false)
        }
        for q in 0..<5 {
            let x = cx + r.range(-w / 2 + 10, w / 2 - 10), z = cz + r.range(-d / 2 + 10, d / 2 - 10)
            m.part("Hoop", at: (x, 2.5, z), size: (5, 0.5, 5), color: "#FACC15", shape: .cylinder, material: .neon, behavior: .trigger,
                   tags: ["hoop", "area=\(area)"], solid: false, rotation: (90, Float(q) * 36, 0), opacity: 0.6)
        }
    }
    // The race track: a straight 300 m sprint south of the city.
    m.slab("Race Track", x: 0, y: -0.01, z: -150, w: 320, h: 0.05, d: 16, color: "#B91C1C")
    for q in 0..<9 { m.part("Track Line", at: (-150 + Float(q) * 37.5, 0.05, -150), size: (0.4, 0.02, 16), color: "#F8FAFC", solid: false) }
    m.pad("Race Pad", x: 0, z: -112, size: 4, color: "#EF4444", tags: ["race_join"])
    m.part("Race Start", at: (-150, 0.6, -150), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    m.part("Race Finish", at: (150, 2, -150), size: (2, 4, 16), color: "#FACC15", material: .neon, behavior: .trigger, tags: ["race_finish"], solid: false,
           opacity: 0.4)
    m.part("Finish Arch", at: (150, 6, -150), size: (1, 1, 18), color: "#FACC15", material: .neon, solid: false)
    m.coverFocus(x: 0, y: 2, z: -30, yaw: 200, width: 60)
}

// MARK: 115 Tap Race Clicker (Race Clicker)

func tapRaceClicker(_ m: MapBuilder) {
    m.day(ground: "#65A30D")
    m.environment.skyStyle = .clouds
    // The lobby where everyone taps.
    m.ground(90, 70, color: "#84CC16", z: -40, material: .grass)
    m.slab("Lobby", x: 0, y: -0.01, z: -40, w: 60, h: 0.05, d: 44, color: "#E5E7EB")
    m.spawnRing(0, -46, radius: 5, count: 10, color: "#F97316")
    m.pad("Shop Pad", x: -14, z: -30, size: 3.2, color: "#3B82F6", tags: ["shop"])
    m.pad("Egg Pad", x: 14, z: -30, size: 3.2, color: "#A855F7", tags: ["eggs"])
    m.part("Big Button", at: (0, 1, -60), size: (8, 2, 8), color: "#EF4444", shape: .cylinder, material: .neon)
    m.part("Big Button Base", at: (0, 0.3, -60), size: (10, 0.6, 10), color: "#1F2937", shape: .cylinder)
    // The track: 1500 m straight, a gate every 50 m, a new colour every 250 m.
    m.ground(40, 1540, color: "#65A30D", name: "Track Ground", z: 760, material: .grass)
    m.slab("Track", x: 0, y: -0.01, z: 760, w: 16, h: 0.05, d: 1530, color: "#B91C1C")
    m.part("Start Line", at: (0, 0.05, 0), size: (16, 0.02, 1), color: "#F8FAFC", solid: false)
    m.part("Race Start", at: (0, 0.6, -4), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    let zoneColors = ["#22C55E", "#0EA5E9", "#F59E0B", "#A855F7", "#EF4444", "#FACC15"]
    for k in 1...30 {
        let z = Float(k) * 50
        let c = zoneColors[min(5, (k - 1) / 5)]
        m.part("Gate \(k)", at: (0, 3, z), size: (16, 6, 1.5), color: c, material: .neon, behavior: .trigger, tags: ["rgate", "n=\(k)"], solid: false,
               opacity: 0.25)
        for x in [-8.5, 8.5] as [Float] { m.part("Gate Post", at: (x, 3.5, z), size: (1, 7, 1), color: c, material: .neon, solid: false) }
        m.part("Gate Top", at: (0, 7, z), size: (18, 1, 1), color: c, material: .neon, solid: false)
    }
    var r = Seeded("taprace")
    for q in 0..<60 {
        let side: Float = q % 2 == 0 ? -1 : 1
        m.tree(side * r.range(11, 18), Float(q) * 25 + r.range(0, 20), height: r.range(4, 6))
    }
    m.coverFocus(x: 0, y: 2, z: 30, yaw: 200, width: 30)
}

// MARK: 116 Arm Wrestle Champions (Arm Wrestle Simulator)

func armWrestleChampions(_ m: MapBuilder) {
    m.indoor(ground: "#1F2937")
    m.environment.skyStyle = .gradient
    let floors = ["#FDE68A", "#FCD34D", "#BAE6FD", "#FCA5A5"]
    let trims = ["#B45309", "#0EA5E9", "#38BDF8", "#DC2626"]
    // A long hall of four zones along +z; walls between them have a gate.
    m.slab("Hall Floor", x: 0, y: -0.5, z: 130, w: 64, h: 0.5, d: 340, color: "#374151")
    for side in [-1, 1] as [Float] { m.slab("Hall Wall", x: side * 32, y: 0, z: 130, w: 1, h: 6, d: 340, color: "#111827") }
    m.slab("Hall End", x: 0, y: 0, z: -40, w: 64, h: 6, d: 1, color: "#111827")
    m.slab("Hall End", x: 0, y: 0, z: 300, w: 64, h: 6, d: 1, color: "#111827")
    for k in 0..<4 {
        let cz = Float(k) * 80
        m.slab("Zone Floor \(k + 1)", x: 0, y: -0.02, z: cz, w: 62, h: 0.06, d: 78, color: floors[k])
        m.part("Zone \(k + 1)", at: (0, 0.5, cz), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
        // Three rivals' tables and the boss table.
        for t in 0..<4 {
            let tx: Float = t < 3 ? -20 + Float(t) * 20 : 0
            let tz: Float = t < 3 ? cz + 14 : cz + 30
            let big = t == 3
            m.slab("Table", x: tx, y: 0, z: tz, w: big ? 4 : 3, h: 1.1, d: big ? 2.4 : 2, color: big ? "#7C2D12" : "#92400E", material: .wood)
            m.part("Rival Spot \(k + 1)-\(t + 1)", at: (tx, 0.6, tz + (big ? 2.4 : 2)), size: (1, 0.2, 1), color: "#000000", solid: false, visible: false)
            m.pad("Wrestle \(k + 1)-\(t + 1)", x: tx, z: tz - (big ? 2.6 : 2.2), size: 2.2, color: big ? "#DC2626" : trims[k],
                  tags: ["wrestle", "z=\(k + 1)", "t=\(t + 1)"])
        }
        // Training weights along the side.
        for q in 0..<4 {
            m.part("Weight", at: (-26, 0.6, cz - 24 + Float(q) * 10), size: (3, 1.2, 1.2), color: trims[k], material: .metal, solid: false)
        }
        if k > 0 {
            let wz = cz - 40
            m.slab("Zone Wall", x: -18.5, y: 0, z: wz, w: 27, h: 6, d: 1, color: trims[k])
            m.slab("Zone Wall", x: 18.5, y: 0, z: wz, w: 27, h: 6, d: 1, color: trims[k])
            m.part("Zone Gate \(k + 1)", at: (0, 3, wz), size: (10, 6, 1.6), color: trims[k], material: .neon, behavior: .trigger,
                   tags: ["zgate", "n=\(k + 1)"], solid: false, opacity: 0.35)
        }
    }
    // Start area: spawn, shop, eggs, and the table for playing a friend.
    m.spawnRing(0, -26, radius: 4, count: 8, color: "#F59E0B")
    m.pad("Shop Pad", x: -12, z: -18, size: 3.2, color: "#3B82F6", tags: ["shop"])
    m.pad("Egg Pad", x: 12, z: -18, size: 3.2, color: "#A855F7", tags: ["eggs"])
    m.slab("Duel Table", x: 22, y: 0, z: -28, w: 3, h: 1.1, d: 2, color: "#F8FAFC", material: .wood)
    m.pad("Duel A", x: 22, z: -30.4, size: 2, color: "#EC4899", tags: ["duel", "side=a"])
    m.pad("Duel B", x: 22, z: -25.6, size: 2, color: "#38BDF8", tags: ["duel", "side=b"])
    for q in 0..<6 { m.part("Hall Light", at: (0, 5.8, -30 + Float(q) * 60), size: (20, 0.2, 2), color: "#FEF9C3", material: .neon, solid: false) }
    m.coverFocus(x: 0, y: 1.5, z: 12, yaw: 200, width: 30)
}

// MARK: 117 Deep Mine Simulator (Mining Simulator 2)

/// Ores, top to bottom: name, colour, the first layer it shows in, and how often (in 100).
let mineOres: [(String, String, Int, Int)] = [("coal", "#1C1917", 2, 18), ("copper", "#EA580C", 3, 14), ("iron", "#D6D3D1", 4, 12), ("gold", "#FACC15", 6, 9),
                                              ("ruby", "#DC2626", 7, 7), ("diamond", "#22D3EE", 9, 5), ("crystal", "#A855F7", 10, 4), ("magma", "#F97316", 12, 6)]

func deepMineSimulator(_ m: MapBuilder) {
    // No ground plane: it would cover the mine, which is all below y = 0.
    m.sky("#5AB2FF", "#CDEBFF", light: 0.75, showGround: false, fall: -60)
    m.environment.skyStyle = .clouds
    let cell: Float = 3, cols = 8, layers = 12
    let half = Float(cols) * cell / 2
    // The surface, with a square hole for the mine.
    let outer: Float = 100
    m.slab("Surface", x: 0, y: -1, z: -(half + (outer - half) / 2), w: outer * 2, h: 1, d: outer - half, color: "#4D7C0F", material: .grass)
    m.slab("Surface", x: 0, y: -1, z: half + (outer - half) / 2, w: outer * 2, h: 1, d: outer - half, color: "#4D7C0F", material: .grass)
    m.slab("Surface", x: -(half + (outer - half) / 2), y: -1, z: 0, w: outer - half, h: 1, d: half * 2, color: "#4D7C0F", material: .grass)
    m.slab("Surface", x: half + (outer - half) / 2, y: -1, z: 0, w: outer - half, h: 1, d: half * 2, color: "#4D7C0F", material: .grass)
    // Walls of the pit and the bedrock floor.
    let depth = Float(layers) * cell
    for (x, z, w, d) in [(0, -half - 0.5, half * 2 + 2, Float(1)), (0, half + 0.5, half * 2 + 2, 1), (-half - 0.5, 0, 1, half * 2), (half + 0.5, 0, 1, half * 2)] as [(Float, Float, Float, Float)] {
        m.slab("Pit Wall", x: x, y: -depth - 1, z: z, w: w, h: depth, d: d, color: "#44403C", material: .stone)
    }
    m.slab("Bedrock", x: 0, y: -depth - 2, z: 0, w: half * 2 + 2, h: 1, d: half * 2 + 2, color: "#0C0A09", material: .stone)
    // The blocks to dig: deterministic ores, more and better further down.
    var r = Seeded("deepmine")
    for l in 0..<layers {
        let y = -1 - cell / 2 - Float(l) * cell
        for c in 0..<cols {
            for rr in 0..<cols {
                var ore = l < 2 ? "dirt" : "stone"
                var color = l < 2 ? "#92400E" : (l < 6 ? "#78716C" : (l < 10 ? "#57534E" : "#292524"))
                let roll = r.int(1, 100)
                var acc = 0
                for o in mineOres.reversed() where l + 1 >= o.2 {
                    acc += o.3
                    if roll <= acc {
                        ore = o.0
                        color = o.1
                        break
                    }
                }
                let x = -half + cell / 2 + Float(c) * cell, z = -half + cell / 2 + Float(rr) * cell
                m.part("M \(c)-\(rr)-\(l)", at: (x, y, z), size: (cell, cell, cell), color: color, material: ore == "dirt" ? .matte : .stone,
                       tags: ["mine", "ore=\(ore)"])
            }
        }
    }
    // The mining camp.
    m.spawnRing(0, -26, radius: 4, count: 8, color: "#FACC15")
    m.slab("Camp", x: 0, y: -0.02, z: -30, w: 40, h: 0.06, d: 14, color: "#D6D3D1")
    m.shop("Ore Shop", x: -10, z: -40, w: 12, d: 8, color: "#FDE68A", sign: "#CA8A04", facing: 1)
    m.pad("Sell Pad", x: -10, z: -32, size: 3.6, color: "#FACC15", tags: ["sim_sell"])
    m.pad("Shop Pad", x: 4, z: -32, size: 3.2, color: "#3B82F6", tags: ["shop"])
    m.pad("Egg Pad", x: 12, z: -32, size: 3.2, color: "#A855F7", tags: ["eggs"])
    m.part("Mine Sign", at: (0, 4, -half - 1.5), size: (10, 2, 0.3), color: "#FACC15", material: .neon, solid: false)
    for x in [-half - 1, half + 1] as [Float] { m.slab("Mine Post", x: x, y: 0, z: -half - 1.5, w: 0.6, h: 5, d: 0.6, color: "#78350F", material: .wood) }
    m.slab("Mine Beam", x: 0, y: 5, z: -half - 1.5, w: half * 2 + 3, h: 0.6, d: 0.6, color: "#78350F", material: .wood)
    for q in 0..<3 { m.parkedCar("Mine Cart", x: 22 + Float(q) * 5, z: -28, yaw: 90, color: "#78716C") }
    for _ in 0..<30 {
        let x = r.range(-95, 95), z = r.range(-95, 95)
        if abs(x) < 30 && abs(z) < 48 { continue }
        m.pine(x, z, height: r.range(5, 8))
    }
    m.coverFocus(x: 0, y: -2, z: 0, yaw: 200, width: 30)
}

// MARK: 118 Sand Treasure Hunt (Treasure Hunt Simulator)

/// The three digging fields along x: centre x, sand colour, ground colour.
let treasureFields: [(Float, String, String)] = [(0, "#FDE68A", "#FEF3C7"), (90, "#A16207", "#4D7C0F"), (180, "#F59E0B", "#FCD34D")]

func sandTreasureHunt(_ m: MapBuilder) {
    m.sky("#38BDF8", "#E0F2FE", light: 0.8, showGround: false, fall: -20)
    m.environment.skyStyle = .clouds
    m.ground(320, 140, color: "#FEF3C7", x: 90, z: 0, material: .sand)
    m.water(90, 95, w: 320, d: 50, name: "Sea", color: "#0EA5E9", tags: ["scenery"])
    let cols = 10, cell: Float = 4
    for (k, f) in treasureFields.enumerated() {
        let (cx, sand, edge) = f
        m.slab("Field Edge \(k + 1)", x: cx, y: -0.02, z: 0, w: 46, h: 0.05, d: 46, color: edge, material: k == 1 ? .grass : .sand)
        for c in 0..<cols {
            for r in 0..<cols {
                let x = cx - 18 + Float(c) * cell, z = -18 + Float(r) * cell
                m.part("T \(k + 1)-\(c)-\(r)", at: (x, 0.45, z), size: (3.95, 0.9, 3.95), color: sand, material: .sand, tags: ["sandtile"], solid: false)
            }
        }
        m.part("Field \(k + 1)", at: (cx, 0.5, 0), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
        if k > 0 {
            let gx = cx - 45
            m.slab("Field Wall", x: gx, y: 0, z: -42, w: 2, h: 5, d: 56, color: "#78350F", material: .wood)
            m.slab("Field Wall", x: gx, y: 0, z: 42, w: 2, h: 5, d: 56, color: "#78350F", material: .wood)
            m.part("Gate \(k + 1)", at: (gx, 2.5, 0), size: (2, 5, 28), color: ["#22C55E", "#F59E0B"][k - 1], material: .neon, behavior: .trigger,
                   tags: ["sim_gate", "n=\(k + 1)"], solid: false, opacity: 0.35)
        }
    }
    // Decorations: palms on the beach, jungle trees, desert pyramids.
    var r = Seeded("treasure")
    for _ in 0..<10 { m.pine(r.range(-40, 40), r.pick([r.range(-62, -28), r.range(28, 62)]), height: 6, leaves: "#65A30D") }
    for _ in 0..<16 { m.tree(90 + r.range(-40, 40), r.pick([r.range(-62, -28), r.range(28, 62)]), height: r.range(6, 9), leaves: "#166534") }
    for _ in 0..<4 { m.part("Pyramid", at: (180 + r.range(-35, 35), 6, r.pick([-50, 50])), size: (16, 12, 16), color: "#D97706", shape: .cone, material: .sand, solid: false) }
    // The camp: sell, shop, eggs.
    m.spawnRing(-38, 0, radius: 3.5, count: 8, color: "#F97316")
    m.pad("Sell Pad", x: -36, z: -12, size: 3.6, color: "#FACC15", tags: ["sim_sell"])
    m.pad("Shop Pad", x: -36, z: 12, size: 3.2, color: "#3B82F6", tags: ["shop"])
    m.pad("Egg Pad", x: -44, z: 12, size: 3.2, color: "#A855F7", tags: ["eggs"])
    m.shop("Treasure Shop", x: -46, z: -12, w: 10, d: 8, color: "#FDBA74", sign: "#EA580C", facing: 1)
    m.coverFocus(x: 0, y: 1, z: 0, yaw: 220, width: 36)
}

// MARK: 119 Mega Magnet Sim (Magnet Simulator)

/// The three areas along x: centre x, floor colour.
let magnetAreas: [(Float, String)] = [(0, "#86EFAC"), (80, "#CBD5E1"), (160, "#FDE68A")]

func megaMagnetSim(_ m: MapBuilder) {
    m.day(ground: "#4D7C0F")
    m.environment.skyStyle = .clouds
    m.ground(280, 120, color: "#65A30D", x: 70, z: 0, material: .grass)
    for (k, a) in magnetAreas.enumerated() {
        let (cx, floor) = a
        m.slab("Area Floor \(k + 1)", x: cx, y: -0.02, z: 0, w: 74, h: 0.06, d: 74, color: floor, material: k == 0 ? .grass : .matte)
        m.part("Area \(k + 1)", at: (cx, 0.5, 0), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
        if k > 0 {
            let gx = cx - 40
            m.slab("Area Wall", x: gx, y: 0, z: -34, w: 2, h: 5, d: 52, color: "#475569")
            m.slab("Area Wall", x: gx, y: 0, z: 34, w: 2, h: 5, d: 52, color: "#475569")
            m.part("Gate \(k + 1)", at: (gx, 2.5, 0), size: (2, 5, 16), color: ["#38BDF8", "#FACC15"][k - 1], material: .neon, behavior: .trigger,
                   tags: ["sim_gate", "n=\(k + 1)"], solid: false, opacity: 0.35)
        }
    }
    for x in [-37, 197] as [Float] { m.slab("End Wall", x: x, y: 0, z: 0, w: 2, h: 5, d: 120, color: "#475569") }
    for z in [-60, 60] as [Float] { m.slab("Side Wall", x: 80, y: 0, z: z, w: 236, h: 5, d: 2, color: "#475569") }
    // The park: trees and a fountain. The city: towers. The vault: gold bars.
    var r = Seeded("magnet")
    for _ in 0..<10 { m.tree(r.range(-30, 30), r.pick([r.range(-34, -26), r.range(26, 34)]), height: 5) }
    m.part("Fountain", at: (0, 0.5, 0), size: (6, 1, 6), color: "#7DD3FC", shape: .cylinder, material: .glass, opacity: 0.7)
    for q in 0..<6 {
        let h = r.range(10, 24)
        m.slab("City Tower", x: 60 + Float(q % 3) * 20, y: 0, z: q < 3 ? -30 : 30, w: 10, h: h, d: 8, color: r.pick(["#94A3B8", "#64748B", "#CBD5E1"]))
    }
    for q in 0..<10 {
        m.slab("Gold Bars", x: 135 + Float(q % 5) * 12, y: 0, z: q < 5 ? -30 : 30, w: 4, h: 1.2 + Float(q % 3) * 0.6, d: 2, color: "#FACC15", material: .metal)
    }
    m.part("Vault Door", at: (160, 6, -36), size: (14, 12, 1), color: "#A8A29E", shape: .cylinder, material: .metal, solid: false, rotation: (90, 0, 0))
    // The bank (sell), shop, eggs at the start.
    m.spawnRing(-24, 0, radius: 3.5, count: 8, color: "#EF4444")
    m.shop("Bank", x: -28, z: -22, w: 12, d: 8, color: "#E5E7EB", sign: "#16A34A", facing: 1)
    m.pad("Sell Pad", x: -28, z: -14, size: 3.6, color: "#FACC15", tags: ["sim_sell"])
    m.pad("Shop Pad", x: -28, z: 12, size: 3.2, color: "#3B82F6", tags: ["shop"])
    m.pad("Egg Pad", x: -20, z: 12, size: 3.2, color: "#A855F7", tags: ["eggs"])
    m.part("Giant Magnet", at: (-30, 4, 24), size: (2, 8, 2), color: "#DC2626", solid: false)
    m.part("Giant Magnet", at: (-24, 4, 24), size: (2, 8, 2), color: "#DC2626", solid: false)
    m.part("Giant Magnet Top", at: (-27, 8.5, 24), size: (8, 2, 2), color: "#DC2626", solid: false)
    m.part("Magnet Tips", at: (-27, 0.6, 24), size: (8, 1.2, 2.2), color: "#E5E7EB", solid: false)
    m.coverFocus(x: 0, y: 1, z: 0, yaw: 210, width: 40)
}

// MARK: 120 Saber Swing Sim (Saber Simulator)

func saberSwingSim(_ m: MapBuilder) {
    m.dusk(ground: "#3F3F46")
    m.environment.skyStyle = .sunset
    m.ground(200, 200, color: "#52525B", material: .stone)
    // The castle courtyard.
    m.slab("Courtyard", x: 0, y: -0.02, z: -20, w: 70, h: 0.06, d: 50, color: "#A8A29E", material: .stone)
    // Castle walls, with a gateway north to the boss arena.
    m.slab("Castle Wall", x: 0, y: 0, z: -46, w: 74, h: 6, d: 2, color: "#57534E", material: .stone)
    m.slab("Castle Wall", x: -36, y: 0, z: -20, w: 2, h: 6, d: 52, color: "#57534E", material: .stone)
    m.slab("Castle Wall", x: 36, y: 0, z: -20, w: 2, h: 6, d: 52, color: "#57534E", material: .stone)
    m.slab("Castle Wall", x: -20, y: 0, z: 6, w: 34, h: 6, d: 2, color: "#57534E", material: .stone)
    m.slab("Castle Wall", x: 20, y: 0, z: 6, w: 34, h: 6, d: 2, color: "#57534E", material: .stone)
    m.slab("Gateway Arch", x: 0, y: 5, z: 6, w: 8, h: 1.4, d: 2.4, color: "#44403C", material: .stone)
    for (x, z) in [(-36, -46), (36, -46), (-36, 6), (36, 6)] as [(Float, Float)] {
        m.part("Castle Tower", at: (x, 6, z), size: (6, 12, 6), color: "#44403C", shape: .cylinder, material: .stone)
        m.part("Tower Roof", at: (x, 13.5, z), size: (7, 3, 7), color: "#7F1D1D", shape: .cone, solid: false)
    }
    m.spawnRing(0, -30, radius: 4, count: 8, color: "#A855F7")
    m.pad("Sell Pad", x: -14, z: -40, size: 3.6, color: "#FACC15", tags: ["sim_sell"])
    m.part("DNA Altar", at: (-14, 2, -44), size: (2, 4, 2), color: "#22D3EE", shape: .cylinder, material: .neon, solid: false, opacity: 0.6)
    m.pad("Shop Pad", x: 0, z: -40, size: 3.2, color: "#3B82F6", tags: ["shop"])
    m.pad("Egg Pad", x: 14, z: -40, size: 3.2, color: "#A855F7", tags: ["eggs"])
    for q in 0..<6 {
        m.part("Training Dummy", at: (-24 + Float(q) * 9.6, 1.2, -12), size: (0.9, 2.4, 0.9), color: "#A16207", shape: .cylinder, material: .wood)
    }
    // The boss arena, beyond the castle.
    m.part("Arena", at: (0, 0.05, 40), size: (44, 0.1, 44), color: "#7F1D1D", shape: .cylinder, material: .stone, solid: false)
    m.part("Arena Ring", at: (0, 0.2, 40), size: (46, 0.4, 46), color: "#F59E0B", shape: .cylinder, material: .neon, solid: false, opacity: 0.3)
    for q in 0..<8 {
        let a = Float(q) / 8 * 2 * .pi
        m.part("Arena Pillar", at: (cos(a) * 24, 4, 40 + sin(a) * 24), size: (1.6, 8, 1.6), color: "#57534E", shape: .cylinder, material: .stone)
        m.part("Pillar Fire", at: (cos(a) * 24, 8.6, 40 + sin(a) * 24), size: (1.2, 1.2, 1.2), color: "#F97316", shape: .sphere, material: .neon, solid: false)
    }
    m.part("Boss Spot", at: (0, 0.6, 44), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    m.road(from: (0, 6), to: (0, 18), width: 6, name: "Arena Path", dashed: false, color: "#78716C")
    var r = Seeded("saber")
    for _ in 0..<30 {
        let x = r.range(-95, 95), z = r.range(-95, 95)
        if abs(x) < 42 && z > -50 && z < 66 { continue }
        m.pine(x, z, height: r.range(6, 10), leaves: "#14532D")
    }
    m.coverFocus(x: 0, y: 2, z: -24, yaw: 200, width: 40)
}

// MARK: 121 Snowball Shovel Sim (Snow Shoveling Simulator)

/// The three snowfields along z: centre z, ground colour.
let snowFields: [(Float, String)] = [(40, "#F8FAFC"), (120, "#BAE6FD"), (200, "#E0E7FF")]

func snowballShovelSim(_ m: MapBuilder) {
    m.sky("#94A3B8", "#F1F5F9", light: 0.65, ground: "#F8FAFC")
    m.environment.skyStyle = .clouds
    m.environment.weather = .snow
    m.ground(200, 320, color: "#F8FAFC", z: 90, material: .ice)
    var r = Seeded("snowball")
    for (k, f) in snowFields.enumerated() {
        let (cz, color) = f
        m.slab("Field \(k + 1) Floor", x: 0, y: -0.01, z: cz, w: 80, h: 0.05, d: 70, color: color, material: k == 1 ? .ice : .matte)
        m.part("Field \(k + 1)", at: (0, 0.5, cz), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
        for q in 0..<20 {
            let x = r.range(-34, 34), z = cz + r.range(-28, 28)
            let s = r.range(2.2, 3.4)
            m.part("Pile \(k + 1)-\(q + 1)", at: (x, s * 0.35, z), size: (s, s * 0.7, s), color: ["#FFFFFF", "#E0F2FE", "#EDE9FE"][k], shape: .sphere,
                   material: .matte, tags: ["pile", "k=\(k + 1)"], solid: false)
        }
        if k > 0 {
            let gz = cz - 40
            m.slab("Ice Wall", x: -28, y: 0, z: gz, w: 44, h: 5, d: 2, color: "#7DD3FC", material: .ice)
            m.slab("Ice Wall", x: 28, y: 0, z: gz, w: 44, h: 5, d: 2, color: "#7DD3FC", material: .ice)
            m.part("Gate \(k + 1)", at: (0, 2.5, gz), size: (12, 5, 2), color: ["#38BDF8", "#A78BFA"][k - 1], material: .neon, behavior: .trigger,
                   tags: ["sim_gate", "n=\(k + 1)"], solid: false, opacity: 0.35)
        }
    }
    for x in [-51, 51] as [Float] { m.slab("Side Wall", x: x, y: 0, z: 120, w: 2, h: 5, d: 240, color: "#7DD3FC", material: .ice) }
    m.slab("End Wall", x: 0, y: 0, z: 240, w: 104, h: 5, d: 2, color: "#7DD3FC", material: .ice)
    m.part("Ice Mountain", at: (0, 22, 260), size: (90, 44, 40), color: "#E0E7FF", shape: .cone, material: .ice, solid: false)
    // The village: spawn, sell, shop, eggs, and eight snowman plots.
    m.spawnRing(0, -14, radius: 4, count: 8, color: "#38BDF8")
    m.shop("Snow Shop", x: -24, z: -24, w: 12, d: 8, color: "#E0F2FE", sign: "#0284C7", facing: 1)
    m.pad("Sell Pad", x: -24, z: -16, size: 3.6, color: "#FACC15", tags: ["sim_sell"])
    m.pad("Shop Pad", x: -12, z: -6, size: 3.2, color: "#3B82F6", tags: ["shop"])
    m.pad("Egg Pad", x: 12, z: -6, size: 3.2, color: "#A855F7", tags: ["eggs"])
    for k in 1...8 {
        let px = -42 + Float(k - 1) * 12, pz: Float = -36
        m.slab("Plot \(k)", x: px, y: -0.01, z: pz, w: 10, h: 0.05, d: 10, color: "#CBD5E1")
        m.pad("Snowman Pad \(k)", x: px, z: pz + 6, size: 2.4, color: "#38BDF8", tags: ["snowman", "k=\(k)"])
        m.group("sm\(k)_1", shown: false) {
            m.part("Snowman Base", at: (px, 1.4, pz), size: (2.8, 2.8, 2.8), color: "#FFFFFF", shape: .sphere, material: .matte, solid: false)
        }
        m.group("sm\(k)_2", shown: false) {
            m.part("Snowman Body", at: (px, 3.6, pz), size: (2.1, 2.1, 2.1), color: "#FFFFFF", shape: .sphere, material: .matte, solid: false)
        }
        m.group("sm\(k)_3", shown: false) {
            m.part("Snowman Head", at: (px, 5.3, pz), size: (1.5, 1.5, 1.5), color: "#FFFFFF", shape: .sphere, material: .matte, solid: false)
            m.part("Snowman Nose", at: (px, 5.3, pz + 0.85), size: (0.25, 0.25, 0.6), color: "#F97316", shape: .cone, solid: false, rotation: (90, 0, 0))
        }
        m.group("sm\(k)_4", shown: false) {
            m.part("Snowman Hat", at: (px, 6.4, pz), size: (1.1, 0.9, 1.1), color: "#111827", shape: .cylinder, solid: false)
            m.part("Snowman Scarf", at: (px, 4.6, pz), size: (1.7, 0.35, 1.7), color: "#DC2626", shape: .cylinder, solid: false)
        }
        m.part("Plot Sign \(k)", at: (px + 4, 1.5, pz + 4), size: (0.8, 0.8, 0.8), color: "#FFFFFF", shape: .sphere, material: .neon, tags: ["plotsign", "k=\(k)"],
               solid: false)
    }
    for _ in 0..<26 {
        let x = r.range(-95, 95), z = r.range(-45, 250)
        if abs(x) < 54 && z > -46 { continue }
        m.pine(x, z, height: r.range(6, 9), leaves: "#F1F5F9")
    }
    for q in 0..<4 { m.house("Cabin", x: -66 + Float(q) * 44, z: -60, w: 9, d: 7, wall: "#92400E", roof: "#F8FAFC", tags: ["house"], facing: 1) }
    m.coverFocus(x: 0, y: 1.5, z: 30, yaw: 200, width: 40)
}

// MARK: 122 Gym League Stars (Gym League)

func gymLeagueStars(_ m: MapBuilder) {
    m.indoor(ground: "#1F2937")
    m.slab("Gym Floor", x: 0, y: -0.5, z: 0, w: 90, h: 0.5, d: 90, color: "#374151")
    m.walls(0, 0, w: 90, d: 90, h: 8, color: "#111827", thickness: 1)
    for q in 0..<5 { m.part("Gym Light", at: (-36 + Float(q) * 18, 7.8, 0), size: (2, 0.2, 80), color: "#FEF9C3", material: .neon, solid: false) }
    // Four machines, each training one part of the body.
    let machines: [(String, String, Float, Float, String)] = [("arms", "💪", -30, -24, "#EF4444"), ("legs", "🦵", -10, -24, "#3B82F6"),
                                                             ("chest", "🫁", 10, -24, "#22C55E"), ("back", "🔙", 30, -24, "#F59E0B")]
    for (id, _, x, z, c) in machines {
        m.slab("Machine Base", x: x, y: 0, z: z - 4, w: 6, h: 0.6, d: 4, color: "#1F2937")
        m.part("Machine Frame", at: (x - 2.5, 2.5, z - 4), size: (0.4, 5, 0.4), color: c, material: .metal, solid: false)
        m.part("Machine Frame", at: (x + 2.5, 2.5, z - 4), size: (0.4, 5, 0.4), color: c, material: .metal, solid: false)
        m.part("Machine Bar", at: (x, 4.2, z - 4), size: (5.4, 0.3, 0.3), color: "#94A3B8", material: .metal, solid: false)
        for k in 0..<3 {
            m.pad("Machine \(id) \(k + 1)", x: x - 2 + Float(k) * 2, z: z + 0.5, size: 1.8, color: c, tags: ["machine", "stat=\(id)"])
        }
        m.part("Machine Sign", at: (x, 6, z - 6.2), size: (5, 1.2, 0.2), color: c, material: .neon, solid: false)
    }
    // Protein bar, shop, eggs.
    m.slab("Protein Bar", x: -36, y: 0, z: 14, w: 8, h: 1.2, d: 3, color: "#F472B6")
    m.pad("Protein Pad", x: -36, z: 18, size: 3, color: "#EC4899", tags: ["protein"])
    m.pad("Shop Pad", x: -36, z: 30, size: 3, color: "#3B82F6", tags: ["shop"])
    m.pad("Egg Pad", x: -28, z: 30, size: 3, color: "#A855F7", tags: ["eggs"])
    m.spawnRing(0, 4, radius: 4, count: 8, color: "#FACC15")
    // The contest stage, with the judge's desk.
    m.slab("Stage", x: 20, y: 0, z: 30, w: 34, h: 1.2, d: 12, color: "#7C3AED")
    m.slab("Stage Steps", x: 20, y: 0, z: 23.5, w: 8, h: 0.6, d: 1, color: "#6D28D9")
    for k in 0..<8 {
        m.pad("Stage Spot \(k + 1)", x: 6 + Float(k) * 4, z: 30, y: 1.2, size: 2.2, color: "#FACC15", tags: ["stage"])
    }
    m.part("Stage Back", at: (20, 6, 36.4), size: (34, 10, 0.4), color: "#4C1D95", solid: false)
    m.part("Stage Lights", at: (20, 10.5, 36), size: (30, 0.5, 0.5), color: "#F472B6", material: .neon, solid: false)
    m.slab("Judge Desk", x: 20, y: 0, z: 12, w: 10, h: 1.2, d: 2, color: "#78350F", material: .wood)
    m.part("Judge Spot", at: (20, 0.6, 10), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
    for k in 0..<3 { m.part("Rival Spot \(k + 1)", at: (28 + Float(k) * 4, 1.8, 33), size: (1, 1, 1), color: "#000000", solid: false, visible: false) }
    m.coverFocus(x: 0, y: 2, z: -20, yaw: 200, width: 50)
}

// MARK: 123 Dig It Deep (Dig)

/// The four digging grounds in a ring round the town: centre (x, z), colour, material.
let digGrounds: [(Float, Float, String)] = [(-60, 0, "#84CC16"), (0, 60, "#FDE68A"), (60, 0, "#57534E"), (0, -60, "#7F1D1D")]

func digItDeep(_ m: MapBuilder) {
    m.day(ground: "#4D7C0F")
    m.environment.skyStyle = .clouds
    m.ground(220, 220, color: "#65A30D", material: .grass)
    // The town in the middle: merchant, museum, shop, eggs.
    m.slab("Town", x: 0, y: -0.01, z: 0, w: 44, h: 0.05, d: 44, color: "#D6D3D1")
    m.spawnRing(0, 0, radius: 4, count: 8, color: "#F59E0B")
    m.shop("Merchant", x: -12, z: -12, w: 10, d: 7, color: "#FDBA74", sign: "#EA580C", facing: 1)
    m.pad("Sell Pad", x: -12, z: -6, size: 3.2, color: "#FACC15", tags: ["sim_sell"])
    m.shop("Museum", x: 12, z: -12, w: 12, d: 8, color: "#E7E5E4", sign: "#57534E", facing: 1)
    m.pad("Museum Pad", x: 12, z: -6, size: 3.2, color: "#A8A29E", tags: ["museum"])
    m.pad("Shop Pad", x: -12, z: 12, size: 3.2, color: "#3B82F6", tags: ["shop"])
    m.pad("Egg Pad", x: 12, z: 12, size: 3.2, color: "#A855F7", tags: ["eggs"])
    m.part("Dino Skeleton", at: (12, 3, -14), size: (8, 2, 1), color: "#F5F5F4", solid: false)
    // Four digging grounds, fenced, each with a gate from the town.
    var r = Seeded("dig")
    for (i, g) in digGrounds.enumerated() {
        let (cx, cz, color) = g
        let k = i + 1
        m.slab("Dig Ground \(k)", x: cx, y: -0.02, z: cz, w: 46, h: 0.06, d: 46, color: color, material: i == 1 ? .sand : (i == 0 ? .grass : .stone))
        m.part("Ground \(k)", at: (cx, 0.5, cz), size: (1, 1, 1), color: "#000000", solid: false, visible: false)
        // Fence round it with an opening toward the town, and the gate there.
        let toTown: (Float, Float) = (-cx / 60, -cz / 60)
        let h: Float = 23.5
        for (sx, sz) in [(Float(1), Float(0)), (-1, 0), (0, 1), (0, -1)] {
            let isGate = sx == toTown.0 && sz == toTown.1
            let wx = cx + sx * h, wz = cz + sz * h
            let along = sx == 0
            if isGate {
                m.slab("Ground Wall", x: along ? cx - 15 : wx, y: 0, z: along ? wz : cz - 15, w: along ? 17 : 1, h: 3, d: along ? 1 : 17, color: "#78350F", material: .wood)
                m.slab("Ground Wall", x: along ? cx + 15 : wx, y: 0, z: along ? wz : cz + 15, w: along ? 17 : 1, h: 3, d: along ? 1 : 17, color: "#78350F", material: .wood)
                m.part("Gate \(k)", at: (wx, 1.5, wz), size: along ? (13, 3, 1.6) : (1.6, 3, 13), color: ["#22C55E", "#F59E0B", "#94A3B8", "#EF4444"][i],
                       material: .neon, behavior: .trigger, tags: ["sim_gate", "n=\(k)"], solid: false, opacity: 0.35)
            } else {
                m.slab("Ground Wall", x: wx, y: 0, z: wz, w: along ? 48 : 1, h: 3, d: along ? 1 : 48, color: "#78350F", material: .wood)
            }
        }
        // Scenery for each ground.
        for _ in 0..<8 {
            let x = cx + r.range(-19, 19), z = cz + r.range(-19, 19)
            switch i {
            case 0: m.part("Flower", at: (x, 0.3, z), size: (0.6, 0.6, 0.6), color: r.pick(["#F472B6", "#FACC15", "#F8FAFC"]), shape: .sphere, solid: false)
            case 1: m.part("Shell", at: (x, 0.2, z), size: (0.8, 0.3, 0.6), color: "#FBCFE8", shape: .sphere, solid: false)
            case 2: m.rock(x, z, size: r.range(1, 2.4), color: "#44403C")
            default: m.part("Lava Crack", at: (x, 0.05, z), size: (r.range(2, 5), 0.06, 0.6), color: "#F97316", material: .neon, solid: false)
            }
        }
    }
    m.part("Volcano", at: (0, 16, -110), size: (60, 32, 40), color: "#57534E", shape: .cone, material: .stone, solid: false)
    for _ in 0..<24 {
        let x = r.range(-105, 105), z = r.range(-105, 105)
        if abs(x) < 86 && abs(z) < 86 { continue }
        m.tree(x, z, height: r.range(4, 7))
    }
    m.coverFocus(x: -40, y: 1, z: 0, yaw: 230, width: 36)
}
