// The sheets over the game list: Settings (your name, the language, the
// family's choices) and the number pad that guards Family — the family
// passcode when there is one, a grown-up's question when there is not.
import { ChatModerator } from '../core/model/chat';
import { CloudSettings } from '../core/model/cloud';
import { prefix, trimmed } from '../core/model/text';
import type { AvatarProfile } from '../core/model/avatar';
import { L, language, setLanguage } from '../i18n';
import type { InternetRooms } from '../net/internet';
import { FamilyLock, grownUpQuestion } from './family';

export function el<K extends keyof HTMLElementTagNameMap>(tag: K, className = '', parent?: HTMLElement, text?: string): HTMLElementTagNameMap[K] {
  const e = document.createElement(tag);
  if (className) e.className = className;
  if (text !== undefined) e.textContent = text;
  parent?.appendChild(e);
  return e;
}

/** A sheet in the middle of the screen; closes on the scrim, ✕ or Escape. */
export function openSheet(title: string, onClose: () => void = () => {}): { body: HTMLElement; close: () => void } {
  const scrim = el('div', 'ab-sheet-scrim', document.body);
  const card = el('div', 'ab-sheet ab-panel', document.body);
  card.setAttribute('role', 'dialog');
  card.setAttribute('aria-label', title);
  const head = el('div', 'panel-head', card);
  el('h2', '', head, title);
  const x = el('button', 'close', head, '✕');
  x.setAttribute('aria-label', L('Close'));
  const body = el('div', 'body', card);
  let closed = false;
  const close = () => {
    if (closed) return;
    closed = true;
    scrim.remove();
    card.remove();
    document.removeEventListener('keydown', escape, true);
    onClose();
  };
  const escape = (e: KeyboardEvent) => { if (e.key === 'Escape') { e.stopPropagation(); close(); } };
  document.addEventListener('keydown', escape, true);
  scrim.onclick = close;
  x.onclick = close;
  return { body, close };
}

/** Digits on a big pad; `check` says whether what was typed is right. Wrong answers shake and clear. */
function numberPad(parent: HTMLElement, length: { min: number; max: number }, check: (typed: string) => Promise<boolean> | boolean): void {
  const dots = el('div', 'ab-pad-dots', parent);
  const pad = el('div', 'ab-pad', parent);
  let typed = '';
  const draw = () => {
    dots.innerHTML = '';
    for (let i = 0; i < Math.max(length.min, typed.length); i++) el('span', i < typed.length ? 'on' : '', dots);
    ok.disabled = typed.length < length.min;
  };
  const press = async (key: string) => {
    if (key === '⌫') typed = typed.slice(0, -1);
    else if (key === '✓') {
      if (typed.length < length.min) return;
      const right = await check(typed);
      if (!right) {
        dots.classList.remove('wrong');
        void dots.offsetWidth;
        dots.classList.add('wrong');
        typed = '';
      }
    } else if (typed.length < length.max) typed += key;
    draw();
  };
  let ok!: HTMLButtonElement;
  for (const key of ['1', '2', '3', '4', '5', '6', '7', '8', '9', '⌫', '0', '✓']) {
    const b = el('button', key === '✓' ? 'ok' : '', pad, key);
    b.onclick = () => void press(key);
    if (key === '✓') ok = b;
  }
  const keys = (e: KeyboardEvent) => {
    if (!pad.isConnected) { document.removeEventListener('keydown', keys); return; }
    if (/^[0-9]$/.test(e.key)) void press(e.key);
    else if (e.key === 'Backspace') void press('⌫');
    else if (e.key === 'Enter') void press('✓');
  };
  document.addEventListener('keydown', keys);
  draw();
}

/** Opens Family once a grown-up has shown they are one. */
export function askGrownUp(lock: FamilyLock, then: () => void): void {
  if (lock.isLocked) {
    const sheet = openSheet(L('Family'));
    el('p', 'ab-pad-title', sheet.body, lock.hint ? L('Enter the family passcode (hint: {})', lock.hint) : L('Enter the family passcode'));
    numberPad(sheet.body, { min: 4, max: 8 }, async (typed) => {
      if (!(await lock.accepts(typed))) return false;
      sheet.close();
      then();
      return true;
    });
    return;
  }
  const q = grownUpQuestion();
  const sheet = openSheet(L('For a grown-up'));
  el('p', 'ab-pad-title', sheet.body, L('What is {} × {}?', q.a, q.b));
  el('p', 'ab-pad-note', sheet.body, L('Family settings are for a grown-up. A family passcode can be set inside.'));
  numberPad(sheet.body, { min: 1, max: 3 }, (typed) => {
    if (Number(typed) !== q.answer) return false;
    sheet.close();
    then();
    return true;
  });
}

function toggleRow(parent: HTMLElement, label: string, detail: string, on: boolean, set: (v: boolean) => void): void {
  const row = el('div', 'ab-row', parent);
  const text = el('div', 'text', row);
  el('b', '', text, label);
  if (detail) el('small', '', text, detail);
  const t = el('button', 'ab-toggle' + (on ? ' on' : ''), row);
  t.setAttribute('role', 'switch');
  t.setAttribute('aria-checked', String(on));
  t.setAttribute('aria-label', label);
  t.onclick = () => {
    const next = !t.classList.contains('on');
    t.classList.toggle('on', next);
    t.setAttribute('aria-checked', String(next));
    set(next);
  };
}

/** Settings → Family: what the family decided, after `askGrownUp`. */
export function familySheet(lock: FamilyLock, internet: InternetRooms, onChange: () => void): void {
  let unsubscribe = () => {};
  const sheet = openSheet(L('Family'), () => { unsubscribe(); onChange(); });
  const draw = () => {
    const b = sheet.body;
    b.innerHTML = '';
    el('h3', '', b, L('Internet'));
    toggleRow(b, L('Internet rooms'), L('Play with anyone who has Ablox, on an iPad or in a browser. Games go through the internet, encrypted with the room code.'),
      internet.cloudSettings.allowInternetPlay, (v) => {
        const s = CloudSettings.decode(internet.cloudSettings.toJSON());
        s.allowInternetPlay = v;
        internet.configure(s);
        onChange();
      });
    const state = internet.state;
    if (state.kind === 'failed') el('div', 'ab-warning-note', b, state.message);
    el('h3', '', b, L('Passcode'));
    const row = el('div', 'ab-actions', b);
    if (lock.isLocked) {
      const change = el('button', 'ab-block secondary', row, L('Change the passcode'));
      change.onclick = () => choosePasscode(lock, draw);
      const remove = el('button', 'ab-block secondary', row, L('Remove the passcode'));
      remove.onclick = async () => { await lock.set(null); draw(); };
    } else {
      const set = el('button', 'ab-block', row, L('Lock with a passcode'));
      set.onclick = () => choosePasscode(lock, draw);
      el('small', 'ab-pad-note', b, L('With a passcode, Family needs it to open. Without one, a grown-up’s question guards it.'));
    }
    if (internet.uid) {
      el('h3', '', b, L('This browser'));
      const forget = el('button', 'ab-block danger', el('div', 'ab-actions', b), L('Forget this browser on the internet'));
      forget.onclick = async () => {
        await internet.forget();
        draw();
        onChange();
      };
    }
  };
  unsubscribe = internet.subscribe(() => { if (sheet.body.isConnected) draw(); });
  draw();
}

function choosePasscode(lock: FamilyLock, done: () => void): void {
  const sheet = openSheet(L('Lock with a passcode'));
  el('p', 'ab-pad-title', sheet.body, L('Choose a passcode (4–8 digits)'));
  let first: string | null = null;
  const title = sheet.body.querySelector('.ab-pad-title') as HTMLElement;
  numberPad(sheet.body, { min: 4, max: 8 }, async (typed) => {
    if (first === null) {
      first = typed;
      title.textContent = L('Type it again');
      return false;
    }
    if (typed !== first) {
      first = null;
      title.textContent = L("They didn't match. Choose a passcode (4–8 digits)");
      return false;
    }
    await lock.set(typed);
    sheet.close();
    done();
    return true;
  });
}

export interface SettingsHooks {
  profile: () => AvatarProfile;
  saveProfile: (p: AvatarProfile) => void;
  /** The page's words changed (the language). */
  redraw: () => void;
}

/** Settings: your name, the language, Family. */
export function settingsSheet(lock: FamilyLock, internet: InternetRooms, hooks: SettingsHooks, onClose: () => void): void {
  const sheet = openSheet(L('Settings'), onClose);
  const draw = () => {
    const b = sheet.body;
    b.innerHTML = '';
    el('h3', '', b, L('You'));
    const nameRow = el('label', 'ab-field', b);
    el('span', '', nameRow, L('Your name'));
    const input = el('input', '', nameRow);
    input.maxLength = 24;
    input.value = hooks.profile().displayName;
    input.autocomplete = 'off';
    const save = () => {
      const name = prefix(trimmed(input.value), 24);
      if (!name) { input.value = hooks.profile().displayName; return; }
      // A name others can see: the same filter as chat.
      const clean = ChatModerator.cleanName(name);
      if (clean !== name) input.value = clean;
      hooks.saveProfile({ ...hooks.profile(), displayName: clean });
    };
    input.onchange = save;
    input.onkeydown = (e) => { if (e.key === 'Enter') { save(); input.blur(); } };

    el('h3', '', b, L('Language'));
    const seg = el('div', 'ab-seg big', b);
    for (const [key, text] of [['ja', '日本語'], ['en', 'English']] as const) {
      const button = el('button', key === language() ? 'on' : '', seg, text);
      button.onclick = () => { setLanguage(key); hooks.redraw(); draw(); };
    }

    el('h3', '', b, L('Family'));
    const family = el('div', 'ab-row', b);
    const text = el('div', 'text', family);
    el('b', '', text, internet.cloudSettings.allowInternetPlay ? L('Internet rooms are on') : L('Internet rooms are off'));
    el('small', '', text, lock.isLocked ? L('Locked with a family passcode') : L('For a grown-up'));
    const open = el('button', 'ab-block secondary', family, L('Family settings'));
    open.onclick = () => askGrownUp(lock, () => familySheet(lock, internet, draw));
  };
  draw();
}
