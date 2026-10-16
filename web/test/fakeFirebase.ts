// A small Firebase in memory, reached through `fetch`, for testing the
// browser's internet rooms without the internet: anonymous sign-in, the
// database's REST reads and writes, its event stream, and the parts of
// CloudRules.swift the lobby and the relay rely on — so a guest writing
// before claiming its link, or a guest reading the host's side, is refused
// here as it would be there. Every answer and event comes a little late,
// in order, as over a network.
import { jsonObject, jsonSetting, type Json } from '../src/core/model/cloud';

type Listener = { path: string[]; uid: string; controller: ReadableStreamDefaultController<Uint8Array>; queue: Promise<void>; closed: boolean };

const encoder = new TextEncoder();
const steps = (path: string) => path.split('/').filter((s) => s.length).map(decodeURIComponent);

function valueAt(tree: Json, path: string[]): Json {
  let v: Json = tree;
  for (const s of path) {
    const o = jsonObject(v);
    if (!o) return null;
    v = o[s] ?? null;
  }
  return v;
}

const isPrefix = (a: string[], b: string[]) => a.length <= b.length && a.every((s, i) => b[i] === s);

export class FakeFirebase {
  tree: Json = null;
  private tokens = new Map<string, string>();
  private refreshTokens = new Map<string, string>();
  private listeners = new Set<Listener>();
  private nextUser = 1;
  private pushCounter = 0;
  /** What was refused, for tests to look at. */
  refusals: string[] = [];
  /** Refusals that matter: a delete of something already gone is refused by the real rules too, and harmless. */
  get realRefusals(): string[] { return this.refusals.filter((r) => !r.includes('(nothing there)')); }
  /** Writes by path, for tests to count. */
  writes: string[] = [];
  latency = () => 1 + Math.random() * 8;

  readonly fetch = async (input: string, init: RequestInit = {}): Promise<Response> => {
    await new Promise((r) => setTimeout(r, this.latency()));
    const url = new URL(input);
    if (url.hostname === 'identitytoolkit.googleapis.com' || url.hostname === 'securetoken.googleapis.com') return this.auth(url, init);
    return this.database(url, init);
  };

  // MARK: Signing in

  private auth(url: URL, init: RequestInit): Response {
    if (url.pathname.endsWith('accounts:signUp')) {
      const uid = 'user' + String(this.nextUser++).padStart(4, '0');
      const idToken = 'id-' + uid + '-' + Math.random().toString(36).slice(2);
      const refreshToken = 'rt-' + uid;
      this.tokens.set(idToken, uid);
      this.refreshTokens.set(refreshToken, uid);
      return Response.json({ localId: uid, idToken, refreshToken, expiresIn: '3600' });
    }
    if (url.pathname.endsWith('/token')) {
      const form = new URLSearchParams(String(init.body ?? ''));
      const uid = this.refreshTokens.get(form.get('refresh_token') ?? '');
      if (!uid) return Response.json({ error: { message: 'INVALID_REFRESH_TOKEN' } }, { status: 400 });
      const idToken = 'id-' + uid + '-' + Math.random().toString(36).slice(2);
      this.tokens.set(idToken, uid);
      return Response.json({ user_id: uid, id_token: idToken, refresh_token: 'rt-' + uid, expires_in: '3600' });
    }
    if (url.pathname.endsWith('accounts:delete')) return Response.json({});
    return new Response('not found', { status: 404 });
  }

  // MARK: The rules (the lobby's and the relay's)

  private canRead(path: string[], uid: string): boolean {
    const [top, room, place, link] = path;
    if (top === 'lobby') return true;
    if (top !== 'relay' || !room) return false;
    const hostOf = valueAt(this.tree, ['lobby', room, 'host']);
    const guestOf = (l: string) => valueAt(this.tree, ['relay', room, 'links', l, 'guest']);
    if (place === 'links') return link ? guestOf(link) === uid || hostOf === uid : hostOf === uid;
    if (place === 'up') return hostOf === uid;
    if (place === 'down') return !!link && guestOf(link) === uid;
    return false;
  }

  private canWrite(path: string[], uid: string, value: Json): boolean {
    const [top, room, place, link, piece] = path;
    const exists = valueAt(this.tree, path) !== null;
    if (top === 'lobby' && room && path.length === 2) {
      const host = valueAt(this.tree, ['lobby', room, 'host']);
      const o = jsonObject(value);
      if (value === null) return host === uid;
      const shaped = !!o && ['host', 'hostName', 'world', 'worldID', 'players', 'capacity', 'protocol', 'code', 'salt', 'at'].every((k) => k in o)
        && o.host === uid && String(o.hostName).length <= 40 && String(o.world).length <= 60 && Number(o.capacity) <= 50 && String(o.code).length <= 12;
      return shaped && (!exists || host === uid);
    }
    if (top !== 'relay' || !room) return false;
    const hostOf = valueAt(this.tree, ['lobby', room, 'host']);
    const guestOf = (l: string) => valueAt(this.tree, ['relay', room, 'links', l, 'guest']);
    if (path.length === 2) return value === null && hostOf === uid;
    if (place === 'links' && link && path.length === 4) {
      const o = jsonObject(value);
      if (!exists) return !!o && o.guest === uid && valueAt(this.tree, ['lobby', room]) !== null;
      return value === null && (guestOf(link) === uid || hostOf === uid);
    }
    if ((place === 'up' || place === 'down') && link) {
      if (!(guestOf(link) === uid || hostOf === uid)) return false;
      if (piece !== undefined) return value === null || (/^[0-9]{10}$/.test(piece) && typeof value === 'string' && value.length <= 360000);
      return true;
    }
    return false;
  }

  // MARK: The database

  private resolve(value: Json): Json {
    if (Array.isArray(value)) return value.map((v) => this.resolve(v));
    if (value && typeof value === 'object') {
      if ((value as Record<string, Json>)['.sv'] === 'timestamp') return Date.now();
      const out: Record<string, Json> = {};
      for (const [k, v] of Object.entries(value)) out[k] = this.resolve(v);
      return out;
    }
    return value;
  }

  private async database(url: URL, init: RequestInit): Promise<Response> {
    const path = steps(url.pathname.replace(/\.json$/, ''));
    const uid = this.tokens.get(url.searchParams.get('auth') ?? '');
    if (!uid) return Response.json({ error: 'Permission denied' }, { status: 401 });
    const method = (init.method ?? 'GET').toUpperCase();
    const headers = new Headers(init.headers);
    const silent = url.searchParams.get('print') === 'silent';
    const denied = (why: string) => {
      this.refusals.push(`${method} ${path.join('/')} by ${uid}: ${why}`);
      return Response.json({ error: 'Permission denied' }, { status: 401 });
    };

    if (method === 'GET' && headers.get('Accept') === 'text/event-stream') {
      if (!this.canRead(path, uid)) return denied('read');
      return this.stream(path, uid, init.signal ?? undefined);
    }
    if (method === 'GET') {
      if (!this.canRead(path, uid)) return denied('read');
      let value = valueAt(this.tree, path);
      const limit = Number(url.searchParams.get('limitToLast') ?? 0);
      const orderBy = url.searchParams.get('orderBy');
      if (limit && orderBy === '"at"') {
        const entries = Object.entries(jsonObject(value) ?? {}).sort((a, b) => Number(jsonObject(a[1])?.at ?? 0) - Number(jsonObject(b[1])?.at ?? 0));
        value = Object.fromEntries(entries.slice(-limit));
      }
      return Response.json(value);
    }
    const body = init.body ? (JSON.parse(String(init.body)) as Json) : null;
    if (method === 'PUT' || method === 'DELETE') {
      const value = method === 'DELETE' ? null : this.resolve(body);
      if (!this.canWrite(path, uid, value)) return denied(value === null && valueAt(this.tree, path) === null ? 'write (nothing there)' : 'write');
      this.set(path, value);
      return silent ? new Response(null, { status: 204 }) : Response.json(value);
    }
    if (method === 'PATCH') {
      const children = jsonObject(body) ?? {};
      for (const [k, v] of Object.entries(children)) if (!this.canWrite([...path, ...steps(k)], uid, this.resolve(v))) return denied('patch ' + k);
      for (const [k, v] of Object.entries(children)) this.set([...path, ...steps(k)], this.resolve(v), false);
      this.notifyPatch(path, this.resolve(body));
      return silent ? new Response(null, { status: 204 }) : Response.json(body);
    }
    if (method === 'POST') {
      const key = '-N' + String(Date.now()).padStart(14, '0') + String(this.pushCounter++).padStart(6, '0');
      if (!this.canWrite([...path, key], uid, this.resolve(body))) return denied('post');
      this.set([...path, key], this.resolve(body));
      return Response.json({ name: key });
    }
    return new Response('bad method', { status: 405 });
  }

  private set(path: string[], value: Json, notify = true): void {
    this.writes.push(path.join('/'));
    this.tree = jsonSetting(this.tree, path, value);
    if (notify) this.notifyPut(path);
  }

  // MARK: The stream

  private stream(path: string[], uid: string, signal?: AbortSignal): Response {
    let listener!: Listener;
    const body = new ReadableStream<Uint8Array>({
      start: (controller) => {
        listener = { path, uid, controller, queue: Promise.resolve(), closed: false };
        this.listeners.add(listener);
        this.send(listener, 'put', '/', valueAt(this.tree, path));
      },
      cancel: () => this.drop(listener),
    });
    signal?.addEventListener('abort', () => this.drop(listener), { once: true });
    return new Response(body, { status: 200, headers: { 'Content-Type': 'text/event-stream' } });
  }

  private drop(l: Listener): void {
    if (!l || l.closed) return;
    l.closed = true;
    this.listeners.delete(l);
    try { l.controller.close(); } catch { /* already */ }
  }

  private send(l: Listener, event: string, path: string, data: Json): void {
    const text = `event: ${event}\ndata: ${JSON.stringify({ path, data })}\n\n`;
    l.queue = l.queue.then(async () => {
      await new Promise((r) => setTimeout(r, this.latency()));
      if (l.closed) return;
      // Cut into uneven pieces, as a network delivers them.
      const bytes = encoder.encode(text);
      const cut = Math.min(bytes.length, 1 + Math.floor(Math.random() * bytes.length));
      l.controller.enqueue(bytes.subarray(0, cut));
      if (cut < bytes.length) l.controller.enqueue(bytes.subarray(cut));
    });
  }

  private revoke(l: Listener): void {
    l.queue = l.queue.then(() => {
      if (l.closed) return;
      l.controller.enqueue(encoder.encode('event: cancel\ndata: null\n\n'));
      this.drop(l);
    });
  }

  private notifyPut(write: string[]): void {
    for (const l of [...this.listeners]) {
      if (!this.canRead(l.path, l.uid)) { this.revoke(l); continue; }
      if (isPrefix(l.path, write)) this.send(l, 'put', '/' + write.slice(l.path.length).join('/'), valueAt(this.tree, write));
      else if (isPrefix(write, l.path)) this.send(l, 'put', '/', valueAt(this.tree, l.path));
    }
  }

  private notifyPatch(at: string[], children: Json): void {
    for (const l of [...this.listeners]) {
      if (!this.canRead(l.path, l.uid)) { this.revoke(l); continue; }
      if (isPrefix(l.path, at)) this.send(l, 'patch', '/' + at.slice(l.path.length).join('/'), children);
      else if (isPrefix(at, l.path)) this.send(l, 'put', '/', valueAt(this.tree, l.path));
    }
  }

  /** Every stream still open, for tests that check nothing was left behind. */
  get openStreams(): number { return this.listeners.size; }
}
