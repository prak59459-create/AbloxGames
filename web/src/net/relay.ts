// Internet rooms: a game's own encrypted stream, passed through the
// database in numbered pieces (Net/CloudRelay.swift).
//
// Nothing about a game changes for the internet. An iPad host listens as it
// always does and its relay hands each guest's pieces to that listener; an
// iPad guest connects to a door on itself that hands its bytes to the
// database. A browser sits straight on the pieces instead: its TLS (tls13.ts)
// reads and writes them directly, as a guest or as a host. The bytes are the
// TLS stream keyed by the room code, so the database carries only what it
// cannot read.
//
//   guest ⇄ relay/<room>/up|down/<link> ⇄ host
//
// One "link" per connection; a reconnect is simply a new link.
import { CloudIDs, CloudMirror, CloudPath, RelayInbox, RelayOutbox, jsonObject, serverTime, type Json } from '../core/model/cloud';
import type { CloudDatabase, CloudStream } from './cloud';

/** Bytes both ways between two ends, however they travel. */
export interface BytePipe {
  write(bytes: Uint8Array): void;
  /** Bytes from the other end, in order. */
  onData: (bytes: Uint8Array) => void;
  close(): void;
  /** Called once, when the pipe ends (either end, or a write that would not go). */
  whenClosed(handler: () => void): void;
  readonly isClosed: boolean;
}

/**
 * One connection's two directions through the database. Pieces go up a few
 * at a time — the other end puts them back in order by their numbers, so
 * there is no need to wait for each before sending the next — and pieces
 * read are deleted.
 */
export class RelayPipe implements BytePipe {
  private receiver: ((bytes: Uint8Array) => void) | null = null;
  /** Bytes that came before anyone was listening (the room's key takes a moment to make). */
  private early: Uint8Array[] = [];
  private outbox = new RelayOutbox();
  private inbox = new RelayInbox();
  private inFlight = 0;
  private started = false;
  private closed = false;
  private handlers: (() => void)[] = [];

  constructor(private readonly database: CloudDatabase, readonly outPath: string, readonly inPath: string, private readonly maximumInFlight = 3) {}

  get isClosed(): boolean { return this.closed; }
  get bytesWaiting(): number { return this.outbox.pendingBytes; }
  /** Everything written has reached the database. */
  get isIdle(): boolean { return this.inFlight === 0 && this.outbox.isEmpty; }

  get onData(): (bytes: Uint8Array) => void { return this.receiver ?? (() => {}); }
  set onData(handler: (bytes: Uint8Array) => void) {
    this.receiver = handler;
    for (const bytes of this.early.splice(0)) handler(bytes);
  }

  /** Writes are held until the link is claimed. */
  start(): void {
    this.started = true;
    this.flush();
  }

  write(bytes: Uint8Array): void {
    if (this.closed) return;
    this.outbox.append(bytes);
    this.flush();
  }

  private flush(): void {
    while (this.started && !this.closed && this.inFlight < this.maximumInFlight) {
      const piece = this.outbox.take();
      if (!piece) return;
      this.inFlight += 1;
      void this.send(this.outPath + '/' + piece.key, piece.base64).finally(() => {
        this.inFlight -= 1;
        this.flush();
      });
    }
  }

  private async send(path: string, base64: string): Promise<void> {
    for (let tries = 1; ; tries++) {
      try {
        await this.database.put(path, base64);
        return;
      } catch {
        if (this.closed) return;
        if (tries >= 5) { this.close(); return; }
        await new Promise((r) => setTimeout(r, tries * 400));
      }
    }
  }

  /** Everything waiting under this link in the database, to this end; then the pieces read are deleted. */
  deliver(pieces: Record<string, Json>): void {
    if (this.closed) return;
    const ready = this.inbox.receive(pieces);
    if (ready.length) {
      if (this.receiver) this.receiver(ready); else this.early.push(ready);
    }
    const consumed = this.inbox.takeConsumed();
    if (!consumed.length || this.closed) return;
    const removals: Record<string, Json> = {};
    for (const key of consumed) removals[key] = null;
    this.database.update(this.inPath, removals).catch(() => {});
  }

  whenClosed(handler: () => void): void {
    if (this.closed) handler(); else this.handlers.push(handler);
  }

  close(): void {
    if (this.closed) return;
    this.closed = true;
    for (const h of this.handlers.splice(0)) {
      try { h(); } catch { /* one listener's trouble is not the others' */ }
    }
  }
}

// MARK: - A guest's side

/**
 * A browser joining an internet room: claims a link (the rules let only its
 * guest write it), then reads what the host sends down it and writes what it
 * sends up. The host ending the connection removes the link, which ends it here too.
 */
export async function openGuestLink(database: CloudDatabase, room: string): Promise<RelayPipe> {
  if (!CloudPath.isSafeKey(room)) throw new Error('not a room');
  const uid = await database.auth.signIn();
  const link = CloudIDs.newLinkID();
  await database.put(CloudPath.link(room, link), { guest: uid, at: serverTime });
  const pipe = new RelayPipe(database, CloudPath.up(room, link), CloudPath.down(room, link));
  const streams: CloudStream[] = [];
  pipe.whenClosed(() => {
    for (const s of streams) s.stop();
    void (async () => {
      await database.delete(CloudPath.up(room, link)).catch(() => {});
      await database.delete(CloudPath.down(room, link)).catch(() => {});
      await database.delete(CloudPath.link(room, link)).catch(() => {});
    })();
  });

  const down = new CloudMirror();
  streams.push(database.stream(CloudPath.down(room, link), (event) => {
    down.apply(event);
    pipe.deliver(jsonObject(down.value) ?? {});
  }));
  const claim = new CloudMirror();
  let seen = false;
  let closing: ReturnType<typeof setTimeout> | null = null;
  streams.push(database.stream(CloudPath.link(room, link), (event) => {
    claim.apply(event);
    if (claim.value !== null) seen = true;
    // The host ended the connection. Its last pieces come on the other stream, which is not
    // in step with this one, so they are given a moment to arrive before the pipe closes.
    if ((event.kind === 'cancel' || (seen && claim.value === null)) && !closing) closing = setTimeout(() => pipe.close(), 1500);
  }));
  pipe.whenClosed(() => { if (closing) clearTimeout(closing); });
  pipe.start();
  return pipe;
}

// MARK: - The host's side

/**
 * A browser hosting an internet room: each guest's link becomes a pipe,
 * handed to `onLink` for the room's TLS to listen on.
 */
export class RelayHost {
  /** A new guest's connection. */
  onLink: (link: string, pipe: RelayPipe) => void = () => {};
  static readonly maximumLinks = 64;

  private pipes = new Map<string, RelayPipe>();
  /** Links that have ended, never reopened by a late piece. */
  private finished = new Set<string>();
  /** Links the list has shown: only one that was listed and is gone has ended. */
  private listed = new Set<string>();
  private streams: CloudStream[] = [];
  private stopped = false;

  constructor(private readonly database: CloudDatabase, readonly room: string) {}

  get linkCount(): number { return this.pipes.size; }

  start(): void {
    const up = new CloudMirror();
    this.streams.push(this.database.stream(CloudPath.upAll(this.room), (event) => {
      up.apply(event);
      this.update(jsonObject(up.value) ?? {});
    }));
    // A guest who leaves removes their link: their connection here goes too.
    const links = new CloudMirror();
    this.streams.push(this.database.stream(CloudPath.links(this.room), (event) => {
      links.apply(event);
      this.closeLinks(new Set(Object.keys(jsonObject(links.value) ?? {})));
    }));
  }

  /**
   * Stops taking new links and closes every one. With `drain`, what is
   * still on its way out (the news that the room is moving, a goodbye) is
   * given up to that many seconds to reach the database first.
   */
  async stop(drain = 0): Promise<void> {
    if (this.stopped) return;
    this.stopped = true;
    if (drain > 0) {
      // A moment for the last messages to be sealed and handed to the pipes.
      await new Promise((r) => setTimeout(r, 300));
      const deadline = Date.now() + drain * 1000;
      while (Date.now() < deadline && [...this.pipes.values()].some((p) => !p.isClosed && !p.isIdle)) {
        await new Promise((r) => setTimeout(r, 50));
      }
    }
    for (const s of this.streams.splice(0)) s.stop();
    for (const pipe of [...this.pipes.values()]) pipe.close();
    this.pipes.clear();
  }

  private closeLinks(open: Set<string>): void {
    // The two streams are not in step, so an old list can arrive after a new guest's first piece.
    for (const [link, pipe] of this.pipes) if (this.listed.has(link) && !open.has(link)) pipe.close();
    this.listed = new Set([...this.listed].filter((l) => this.pipes.has(l)));
    for (const l of open) this.listed.add(l);
  }

  private update(links: Record<string, Json>): void {
    if (this.stopped) return;
    for (const [link, pieces] of Object.entries(links)) {
      if (!CloudPath.isSafeKey(link) || this.finished.has(link)) continue;
      const pipe = this.pipes.get(link) ?? this.open(link);
      pipe?.deliver(jsonObject(pieces) ?? {});
    }
  }

  private open(link: string): RelayPipe | null {
    if (this.pipes.size >= RelayHost.maximumLinks) return null;
    const pipe = new RelayPipe(this.database, CloudPath.down(this.room, link), CloudPath.up(this.room, link));
    pipe.whenClosed(() => {
      this.pipes.delete(link);
      this.finished.add(link);
      const room = this.room, database = this.database;
      void (async () => {
        await database.delete(CloudPath.down(room, link)).catch(() => {});
        await database.delete(CloudPath.up(room, link)).catch(() => {});
        await database.delete(CloudPath.link(room, link)).catch(() => {});
      })();
    });
    this.pipes.set(link, pipe);
    pipe.start();
    this.onLink(link, pipe);
    return pipe;
  }
}
