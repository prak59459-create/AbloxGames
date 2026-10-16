// Talking to the Firebase Realtime Database over plain HTTPS, exactly as the
// iPads do (Net/CloudDatabase.swift): an anonymous sign-in (Firebase
// Authentication's REST interface), reads and writes (the database's REST
// interface) and streamed changes (its server-sent events). The data is the
// iPads' data, under the same rules, so a browser and an iPad see the same
// list of rooms and can pass the same relay between them.
import { CloudEventParser, type CloudConfig, type CloudEvent, type Json, jsonChild } from '../core/model/cloud';
import { L } from '../i18n';

export type CloudErrorKind = 'notConfigured' | 'refused' | 'denied' | 'http' | 'badResponse';

export class CloudError extends Error {
  constructor(readonly kind: CloudErrorKind, readonly detail: string | number = '') {
    super(CloudError.describe(kind, detail));
  }

  static describe(kind: CloudErrorKind, detail: string | number): string {
    switch (kind) {
      case 'notConfigured': return L("The internet settings aren't filled in yet.");
      case 'refused': return L('The database refused to sign in: {}', detail);
      case 'denied': return L("The database's rules don't allow that. Check the rules in Settings → Family → Internet.");
      case 'http': return L('The database answered with an error ({}).', detail);
      case 'badResponse': return L("The database sent something Ablox didn't understand.");
    }
  }
}

type Fetcher = (input: string, init?: RequestInit) => Promise<Response>;
const defaultFetch: Fetcher = (input, init) => fetch(input, init);

function browserStorage(): Storage | null {
  try { return typeof localStorage === 'undefined' ? null : localStorage; } catch { return null; }
}

const sleep = (ms: number, signal?: AbortSignal) => new Promise<void>((resolve) => {
  if (signal?.aborted) return resolve();
  const t = setTimeout(resolve, ms);
  signal?.addEventListener('abort', () => { clearTimeout(t); resolve(); }, { once: true });
});

async function readJSON(response: Response): Promise<unknown> {
  const text = await response.text();
  if (!text) return null;
  try { return JSON.parse(text); } catch { return null; }
}

// MARK: - Signing in

interface Stored { uid: string; idToken: string; refreshToken: string; expires: number }

/**
 * Signs this browser in as an anonymous user and keeps it signed in: the
 * refresh token is kept in this browser's storage, so the same browser is
 * the same user from one visit to the next.
 */
export class CloudAuth {
  private stored: Stored | null;
  private inFlight: Promise<Stored> | null = null;
  private readonly storageKey: string;

  constructor(readonly config: CloudConfig, private readonly storage: Storage | null = browserStorage(), private readonly fetcher: Fetcher = defaultFetch) {
    this.storageKey = 'ablox.cloud.' + (config.baseURL ? new URL(config.baseURL).hostname : 'none');
    this.stored = this.load();
  }

  get uid(): string | null { return this.stored?.uid ?? null; }

  private load(): Stored | null {
    try {
      const v = JSON.parse(this.storage?.getItem(this.storageKey) ?? 'null') as Partial<Stored> | null;
      if (v && typeof v.uid === 'string' && typeof v.idToken === 'string' && typeof v.refreshToken === 'string' && typeof v.expires === 'number') {
        return v as Stored;
      }
    } catch { /* nothing kept */ }
    return null;
  }

  private keep(s: Stored | null): void {
    try {
      if (s) this.storage?.setItem(this.storageKey, JSON.stringify(s));
      else this.storage?.removeItem(this.storageKey);
    } catch { /* private mode: signed in for this visit only */ }
  }

  /** A token good for a few more minutes. */
  async token(): Promise<string> {
    if (this.stored && this.stored.expires - Date.now() > 300_000) return this.stored.idToken;
    if (!this.inFlight) {
      const previous = this.stored;
      this.inFlight = (async () => {
        if (previous) {
          try {
            return await this.refresh(previous.refreshToken);
          } catch (e) {
            // Removed from the console: start again. Anything else (no network) is passed on.
            if (!(e instanceof CloudError && e.kind === 'refused')) throw e;
          }
        }
        return this.signUp();
      })();
      this.inFlight.then((fresh) => { this.stored = fresh; this.keep(fresh); }, () => {}).finally(() => { this.inFlight = null; });
    }
    return (await this.inFlight).idToken;
  }

  /** Makes sure there is a user, and says who. */
  async signIn(): Promise<string> {
    await this.token();
    if (!this.stored) throw new CloudError('badResponse');
    return this.stored.uid;
  }

  /** The database said the token is no longer good (auth_revoked): the next request gets a new one. */
  invalidate(): void {
    if (this.stored) this.stored = { ...this.stored, expires: 0 };
  }

  /** Forgets this browser's user. */
  forget(): void {
    this.stored = null;
    this.keep(null);
  }

  /** Removes this browser's user from the database's sign-ins altogether (tests, and "forget me"). */
  async deleteAccount(): Promise<void> {
    if (!this.stored || !this.config.isUsable) return;
    const idToken = await this.token();
    await this.fetcher(`https://identitytoolkit.googleapis.com/v1/accounts:delete?key=${encodeURIComponent(this.config.apiKey)}`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ idToken }),
    });
    this.forget();
  }

  private async signUp(): Promise<Stored> {
    if (!this.config.isUsable) throw new CloudError('notConfigured');
    const body = await this.send(`https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${encodeURIComponent(this.config.apiKey)}`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{"returnSecureToken":true}',
    });
    const uid = jsonChild(body, 'localId'), idToken = jsonChild(body, 'idToken'), refreshToken = jsonChild(body, 'refreshToken');
    if (typeof uid !== 'string' || typeof idToken !== 'string' || typeof refreshToken !== 'string') throw new CloudError('badResponse');
    const seconds = Number(jsonChild(body, 'expiresIn')) || 3600;
    return { uid, idToken, refreshToken, expires: Date.now() + seconds * 1000 };
  }

  private async refresh(refreshToken: string): Promise<Stored> {
    if (!this.config.isUsable) throw new CloudError('notConfigured');
    const form = new URLSearchParams({ grant_type: 'refresh_token', refresh_token: refreshToken });
    const body = await this.send(`https://securetoken.googleapis.com/v1/token?key=${encodeURIComponent(this.config.apiKey)}`, {
      method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: form.toString(),
    });
    const uid = jsonChild(body, 'user_id'), idToken = jsonChild(body, 'id_token'), refresh = jsonChild(body, 'refresh_token');
    if (typeof uid !== 'string' || typeof idToken !== 'string' || typeof refresh !== 'string') throw new CloudError('badResponse');
    const seconds = Number(jsonChild(body, 'expires_in')) || 3600;
    return { uid, idToken, refreshToken: refresh, expires: Date.now() + seconds * 1000 };
  }

  private async send(url: string, init: RequestInit): Promise<unknown> {
    const response = await this.fetcher(url, { ...init, signal: AbortSignal.timeout(20_000) });
    const body = await readJSON(response);
    if (!response.ok) {
      // "ADMIN_ONLY_OPERATION": anonymous sign-in is switched off.
      const message = jsonChild(jsonChild(body, 'error'), 'message');
      throw new CloudError('refused', typeof message === 'string' ? message : `HTTP ${response.status}`);
    }
    return body;
  }
}

// MARK: - Reading and writing

/** A streamed location: stop it when done. */
export interface CloudStream { stop(): void }

export class CloudDatabase {
  readonly base: string;

  constructor(readonly auth: CloudAuth, private readonly fetcher: Fetcher = defaultFetch) {
    const base = auth.config.baseURL;
    if (!base) throw new CloudError('notConfigured');
    this.base = base;
  }

  private url(path: string, query: Record<string, string>, token: string): string {
    const steps = path.split('/').filter((s) => s.length).map(encodeURIComponent).join('/');
    const params = new URLSearchParams({ ...query, auth: token });
    return `${this.base}/${steps}.json?${params.toString()}`;
  }

  private async perform(method: string, path: string, query: Record<string, string> = {}, body?: Json, keepalive = false): Promise<Json> {
    const token = await this.auth.token();
    const init: RequestInit = { method, signal: AbortSignal.timeout(20_000), keepalive };
    if (body !== undefined) {
      init.headers = { 'Content-Type': 'application/json' };
      init.body = JSON.stringify(body);
    }
    const response = await this.fetcher(this.url(path, query, token), init);
    if (response.status === 401 || response.status === 403) {
      await response.body?.cancel().catch(() => {});
      throw new CloudError('denied');
    }
    if (!response.ok) {
      await response.body?.cancel().catch(() => {});
      throw new CloudError('http', response.status);
    }
    return (await readJSON(response)) as Json;
  }

  get(path: string, query: Record<string, string> = {}): Promise<Json> { return this.perform('GET', path, query); }

  async put(path: string, value: Json): Promise<void> { await this.perform('PUT', path, { print: 'silent' }, value); }

  /** Several children at once; a null value removes that child. */
  async update(path: string, values: Record<string, Json>): Promise<void> { await this.perform('PATCH', path, { print: 'silent' }, values); }

  /** Adds under a new key that sorts after everything before it. */
  async add(path: string, value: Json): Promise<string> {
    const answer = await this.perform('POST', path, {}, value);
    const name = jsonChild(answer, 'name');
    if (typeof name !== 'string') throw new CloudError('badResponse');
    return name;
  }

  async delete(path: string): Promise<void> { await this.perform('DELETE', path, { print: 'silent' }); }

  /**
   * Deletes that still go out while the page is closing (`keepalive`), with
   * the token already in hand: a tab that is shut does not get to wait.
   */
  deleteWhileLeaving(paths: string[]): void {
    void this.auth.token().then((token) => {
      for (const path of paths) {
        this.fetcher(this.url(path, { print: 'silent' }, token), { method: 'DELETE', keepalive: true }).catch(() => {});
      }
    }).catch(() => {});
  }

  /**
   * Every change under `path`, its whole value first, until stopped.
   * Reconnects by itself — a token lasts an hour, a network comes back —
   * each time starting with the whole value again.
   */
  stream(path: string, onEvent: (event: CloudEvent) => void): CloudStream {
    const stop = new AbortController();
    void (async () => {
      let failures = 0;
      while (!stop.signal.aborted) {
        const attempt = new AbortController();
        const abortAttempt = () => attempt.abort();
        stop.signal.addEventListener('abort', abortAttempt, { once: true });
        // Firebase says something at least every thirty seconds; silence for ninety means the line is dead.
        let idle: ReturnType<typeof setTimeout> | null = null;
        const touch = () => {
          if (idle) clearTimeout(idle);
          idle = setTimeout(() => attempt.abort(), 90_000);
        };
        try {
          const token = await this.auth.token();
          touch();
          const response = await this.fetcher(this.url(path, {}, token), { headers: { Accept: 'text/event-stream' }, signal: attempt.signal });
          if (response.status === 401 || response.status === 403) {
            await response.body?.cancel().catch(() => {});
            onEvent({ kind: 'cancel', path: [], data: null });
            throw new CloudError('denied');
          }
          if (!response.ok || !response.body) {
            await response.body?.cancel().catch(() => {});
            throw new CloudError('http', response.status);
          }
          failures = 0;
          const parser = new CloudEventParser();
          const reader = response.body.getReader();
          const decoder = new TextDecoder();
          let pending = '';
          streaming: for (;;) {
            const { value, done } = await reader.read();
            if (done) break;
            touch();
            pending += decoder.decode(value, { stream: true });
            let newline = pending.indexOf('\n');
            while (newline >= 0) {
              const line = pending.slice(0, newline);
              pending = pending.slice(newline + 1);
              newline = pending.indexOf('\n');
              const event = parser.feed(line);
              if (!event) continue;
              if (event.kind === 'cancel') {
                // No longer allowed to read it (deleted, or the rules changed): say so.
                onEvent(event);
                await reader.cancel().catch(() => {});
                break streaming;
              }
              if (event.kind === 'auth_revoked') {
                this.auth.invalidate();
                await reader.cancel().catch(() => {});
                break streaming;
              }
              if (event.kind === 'put' || event.kind === 'patch') {
                if (stop.signal.aborted) break streaming;
                onEvent(event);
              }
            }
          }
        } catch {
          failures += 1;
        } finally {
          if (idle) clearTimeout(idle);
          stop.signal.removeEventListener('abort', abortAttempt);
          attempt.abort();
        }
        if (stop.signal.aborted) break;
        // A short wait, longer after each failure, before trying again.
        await sleep(Math.min(30, 2 ** Math.min(failures, 5)) * 1000, stop.signal);
      }
    })();
    return { stop: () => stop.abort() };
  }
}
