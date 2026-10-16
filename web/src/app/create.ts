// Create: for players who make games. Worlds are built in Ablox Studio on an
// iPad; here a world file from Studio (or any .ablox) can be played in the
// browser, alone or with friends, and the sound library can be heard and
// its names copied into scripts.
import { decodeWorld, WorldFormatError, type WorldDocument } from '../core/model/world';
import { language, L } from '../i18n';
import { fileURL } from '../net/catalogue';
import { card, icon, type ShellContext, type ShellPage } from './shell';
import { el } from './sheets';

interface SoundFamily { id: string; name: string; keywords: string; category: string; sounds: { id: string; title: string; ms: number }[] }
interface SoundCategory { id: string; name: string }

let library: Promise<{ categories: SoundCategory[]; families: SoundFamily[] }> | null = null;

/** The game list's sound library, grouped as it is on the iPad. */
function loadLibrary(): Promise<{ categories: SoundCategory[]; families: SoundFamily[] }> {
  library ??= fetch(fileURL('sounds/index.json')).then((r) => {
    if (!r.ok) throw new Error(`HTTP ${r.status}`);
    return r.json();
  }).then((json: { version?: number; categories?: unknown[]; families?: unknown[] }) => {
    if (json?.version !== 1) throw new Error(L('The sound list needs a newer Ablox.'));
    const ja = language() === 'ja';
    const text = (v: unknown, max = 80) => (typeof v === 'string' ? v.slice(0, max) : '');
    const categories: SoundCategory[] = (json.categories ?? []).flatMap((c) => {
      const o = c as Record<string, unknown>;
      return typeof o?.id === 'string' ? [{ id: o.id, name: (ja && text(o.ja)) || text(o.en) || o.id }] : [];
    });
    const families: SoundFamily[] = (json.families ?? []).flatMap((f) => {
      const o = f as Record<string, unknown>;
      if (typeof o?.id !== 'string' || typeof o.c !== 'string' || !Array.isArray(o.s)) return [];
      const sounds = o.s.flatMap((row) => (Array.isArray(row) && typeof row[0] === 'string'
        ? [{ id: row[0], ms: Number(row[1]) || 0, title: text(row[4]) || row[0] }] : []));
      return [{ id: o.id, name: (ja && text(o.ja)) || text(o.en) || o.id, keywords: `${text(o.en)} ${text(o.ja)} ${text(o.k, 200)}`.toLowerCase(), category: o.c, sounds }];
    });
    return { categories, families };
  }).catch((e: unknown) => { library = null; throw e; });
  return library;
}

/** A world from a file: Studio's .ablox, or the same thing as .json. */
export async function readWorldFile(file: File): Promise<WorldDocument> {
  if (file.size > 40 * 1024 * 1024) throw new Error(L('That file is too big to open.'));
  let json: unknown;
  try {
    json = JSON.parse(await file.text());
  } catch {
    throw new Error(L('That is not an Ablox world file.'));
  }
  try {
    const world = decodeWorld(json);
    if (world.blocks.length > 20000) throw new Error(L('That world has too many parts to open safely.'));
    return world;
  } catch (e) {
    if (e instanceof WorldFormatError) throw new Error(e.message === 'not a world' ? L('That is not an Ablox world file.') : e.message);
    throw e;
  }
}

export class CreatePage implements ShellPage {
  readonly root: HTMLElement;
  private category = 'ui';
  private query = '';
  private soundBox: HTMLElement | null = null;

  constructor(parent: HTMLElement, private readonly ctx: ShellContext) {
    this.root = el('div', 'ab-tab ab-create', parent);
    this.build();
  }

  private build(): void {
    const root = this.root;
    const hero = el('section', 'ab-create-hero', root);
    icon('create', hero, 'big');
    const text = el('div', 'text', hero);
    el('h1', '', text, L('Make your own games'));
    el('p', '', text, L('Build worlds with blocks and scripts in Ablox Studio on an iPad. Here you can play what you made, with friends too, and find sounds for your games.'));

    const tools = el('div', 'ab-tools', root);
    // Play a world file.
    const open = this.tool(tools, 'create-world', L('Play a world file'), L('Open a world saved from Ablox Studio (.ablox) and play it here.'));
    const input = el('input', '', open);
    input.type = 'file';
    input.accept = '.ablox,.json,application/json';
    input.hidden = true;
    const row = el('div', 'row', open);
    const solo = el('button', 'ab-block green', row);
    icon('tool-play', solo);
    el('span', '', solo, L('Choose a file'));
    let openRoom = false;
    solo.onclick = () => { openRoom = false; input.click(); };
    if (this.ctx.internet.allowsInternetPlay) {
      const host = el('button', 'ab-block', row);
      icon('friends', host);
      el('span', '', host, L('Play it with friends'));
      host.onclick = () => { openRoom = true; input.click(); };
    }
    el('small', 'ab-note', open, L('Or drop a world file anywhere on this page.'));
    input.onchange = () => {
      const file = input.files?.[0];
      input.value = '';
      if (file) void this.openFile(file, openRoom);
    };

    this.tool(tools, 'create-studio', L('Ablox Studio'), L('The building app: blocks, colours, lights, moving parts and rules. Worlds you publish there join the game list for everyone.'));
    this.tool(tools, 'create-script', L('Scripts'), L('Games come alive with Ablox script: on join, on touch, timers, scores, shops and more. Every game in the list is a script you can read.'));
    this.tool(tools, 'create-template', L('Templates'), L('Studio starts you off with an obby, a battle arena, a tycoon or an empty plate. Try the games here for ideas.'));

    // The sound library.
    const { body, head } = card(root, L('Sound library'), 'create-sound', 'ab-sounds');
    el('span', 'ab-box-side', head, 'CC0');
    el('p', 'ab-note', body, L('Tap a sound to hear it. Copy its name into a script: p.sound("name").'));
    const search = el('label', 'ab-search small', body);
    el('span', '', search, '🔍');
    const field = el('input', '', search);
    field.type = 'search';
    field.placeholder = L('Search sounds');
    field.oninput = () => { this.query = field.value; void this.drawSounds(); };
    this.soundBox = el('div', 'ab-sound-list', body);
    void this.drawSounds();
  }

  private tool(parent: HTMLElement, iconName: string, title: string, text: string): HTMLElement {
    const t = el('section', 'ab-tool', parent);
    const head = el('div', 'head', t);
    icon(iconName, head);
    el('h3', '', head, title);
    el('p', '', t, text);
    return t;
  }

  async openFile(file: File, openRoom: boolean): Promise<void> {
    try {
      const world = await readWorldFile(file);
      this.ctx.playWorld(world, openRoom);
    } catch (e) {
      this.ctx.sound.play('lose');
      this.ctx.toast(String((e as Error)?.message ?? e));
    }
  }

  private async drawSounds(): Promise<void> {
    const box = this.soundBox;
    if (!box) return;
    let data: Awaited<ReturnType<typeof loadLibrary>>;
    try {
      data = await loadLibrary();
    } catch (e) {
      box.innerHTML = '';
      el('div', 'ab-note', box, L('The sound list could not be loaded: {}', String((e as Error)?.message ?? e)));
      return;
    }
    if (!box.isConnected) return;
    box.innerHTML = '';
    const q = this.query.trim().toLowerCase();
    if (!q) {
      const chips = el('div', 'ab-tags', box);
      for (const c of data.categories) {
        const b = el('button', 'ab-tag' + (c.id === this.category ? ' on' : ''), chips, c.name);
        b.onclick = () => { this.category = c.id; void this.drawSounds(); };
      }
    }
    const families = q
      ? data.families.filter((f) => f.keywords.includes(q) || f.sounds.some((s) => s.id.includes(q))).slice(0, 40)
      : data.families.filter((f) => f.category === this.category);
    if (!families.length) { el('div', 'ab-note', box, L('No sounds match that.')); return; }
    for (const f of families) {
      const group = el('div', 'ab-sound-family', box);
      el('b', '', group, f.name);
      const row = el('div', 'sounds', group);
      for (const s of f.sounds.slice(0, 24)) {
        const chip = el('span', 'ab-sound', row);
        const b = el('button', 'play', chip);
        el('span', '', b, '▶');
        el('span', 'id', b, s.id.replace(f.id + '-', '#'));
        b.title = s.id;
        b.onclick = () => this.ctx.sound.play(s.id);
        const copy = el('button', 'copy', chip, '⧉');
        copy.title = L('Copy the name');
        copy.setAttribute('aria-label', L('Copy the name') + ': ' + s.id);
        copy.onclick = () => {
          void navigator.clipboard?.writeText(s.id).then(() => this.ctx.toast(L('Copied “{}”', s.id)), () => this.ctx.toast(s.id));
        };
      }
    }
  }

  redraw(): void { /* nothing here changes with the player's record */ }

  dispose(): void { this.root.remove(); }
}
