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
| `src/app` | The pages around the game: the list, a game's page, Settings, Family |

The games are read from this repository (`main`), the same files the iPads
read. Translations come from the iPad app's own table (`npm run strings`).

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

- `test/oracle.test.ts` and `test/wire.test.ts` compare against the iPad's own
  Swift code (AbloxCore built on Linux; see `tools/wireoracle/build.sh`).
- `test/internet.test.ts` runs rooms through a Firebase in memory that keeps
  the relay's rules; `ABLOX_LIVE=1 npx vitest run test/live.test.ts` runs one
  against the real database and removes what it made.
