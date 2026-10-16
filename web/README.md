# Ablox in the browser

The same games as the Ablox iPad app, played in a web browser — alone, or
together with iPads and other browsers over the internet.

**Play:** https://prak59459-create.github.io/AbloxGames/

## What it is

A port of the iPad app's engine to TypeScript, kept identical on purpose:

| | |
|---|---|
| `src/core/script` | AbloxScript: lexer, parser, interpreter, standard library |
| `src/core/model`, `src/core/physics`, `src/core/runtime` | Worlds, collision, the rule engine and `GameRuntime` with the whole game API |
| `src/engine` | three.js rendering: blocks, avatars, sky and weather, particles, sound |
| `src/play` | The play screen: the host that runs a game, the session, the HUD |
| `src/net` | The catalogue, the wire format, TLS 1.3 keyed by the room code, Firebase |
| `src/app` | The menu around the game (below), Settings and Family |

The games are read from this repository (`main`), the same files the iPads
read. Translations come from the iPad app's own table (`npm run strings`).

## The menu

A dock of four tabs, with your coins and level along the top:

- **Home** — a greeting and your avatar on a little stage, the daily bonus
  (more for days in a row), today's three missions (the same three as on an
  iPad that day, with one swap), the badges you are nearest to, today's pick,
  the games you were playing and the internet rooms open now.
- **Play** — every game by kind, a search, the games you liked, internet rooms.
- **Me** — your avatar on a stage you can spin, and everything it can wear:
  colours, hats, faces, pets, trails, auras, name cards and chat bubbles.
  Pictures of hats, faces, pets and auras are drawn from your own avatar.
  Anything not yet yours can be tried on before it is bought with coins.
  Then the emotes, the badges, the title under your name and your records.
- **Create** — play a world file from Ablox Studio (or drop one on the page),
  alone or with friends, and the sound library, with names to copy into scripts.

The **Plaza** is a small world to walk around in between games: a ring of
doors with game covers on them (today's pick, what you played last, the most
popular), and doors to your closet and the whole list. Walking into a door
opens what is behind it.

While playing, the menu has a **screen layout** (easy: big buttons and fewer
of them; normal; pro: small buttons with frames a second and ping), **Invite
a friend** (a `#join/<room>` link) in an internet room, and, for a host,
**Take everyone to another game**: a party. The room tells everyone it is
moving to this host under a new code — the message a hand-over sends — and
opens the next game there, so iPads in the room come along too.

Coins, missions, levels and badges follow the iPad's rules (`PlayerProgress`,
`DailyMissions`, `Economy`): a coin a point and a bonus for finishing a round,
10 for the first visit to a game, play time counted only while the game is in
front. They are kept in this browser (`ablox.player`). Nothing in the shop
changes how a game plays — only how you look.

## Playing together

Internet rooms go through Ablox's Firebase Realtime Database, exactly as the
iPads' do (`Net/Cloud*.swift`): a browser signs in anonymously, lists rooms
in `lobby/`, and passes the game's own encrypted stream through `relay/` in
numbered pieces. The stream is TLS 1.3 with a key made from the room code,
so the database carries only what it cannot read — and an iPad and a
browser can each host the other.

Internet rooms start **off**. Turning them on takes the family passcode, or,
when there is none, a grown-up's question (Settings → Family).

## Working on it

```sh
npm install
npm run dev        # http://localhost:5173 — the catalogue is the repository beside it
npx vitest run     # every test
npm run build      # dist/, what GitHub Pages serves
```

## Publishing

`.github/workflows/web-pages.yml` tests and builds the site on every push
that touches `web/`, and publishes it from the default branch or from the
branch the web version is made on. It publishes `web/dist` and nothing else
— never the repository itself, whose `index.json` would then be the home
page — together with a copy of the games as they are on the default branch
(`catalogue/`: `index.json`, `games/`, `lib/`, about 75 MB).

The page reads the game list from GitHub, and each game from that copy
when its listing is the same, word for word, as when the site was
published; a game changed since is read from GitHub, all its files. That
keeps a classroom on one connection from being turned away by
raw.githubusercontent.com, and the list still works when GitHub cannot be
reached. Every file is tried up to three times (a dropped connection, 429,
5xx), gives up after 20 seconds with nothing arriving, and a game's scripts
are fetched six at a time.

- `test/oracle.test.ts` and `test/wire.test.ts` compare against the iPad's own
  Swift code (AbloxCore built on Linux; see `tools/wireoracle/build.sh`).
- `test/internet.test.ts` runs rooms through a Firebase in memory that keeps
  the relay's rules; `ABLOX_LIVE=1 npx vitest run test/live.test.ts` runs one
  against the real database and removes what it made.
