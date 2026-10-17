// The AI helper ("Ablobo"), as in the iPad app (AbloxCore/AIHelper.swift):
// the help list answers first, in the browser; the AI only when a grown-up
// has switched it on in Family and typed their own key, which stays in this
// browser's storage and goes nowhere but the provider. Same guide, same
// limits, same answers.
import { L, language } from '../i18n';
import { ChatModerator } from '../core/model/chat';
import { el, openSheet } from './sheets';

export const AI = {
  endpoint: 'https://api.groq.com/openai/v1/chat/completions',
  model: 'llama-3.1-8b-instant',
  /** Tried in order: the next one only when the provider no longer has a model (404). */
  models: ['llama-3.1-8b-instant', 'llama-3.3-70b-versatile'],
  maximumTokens: 260,
  historyTurns: 2,
  maximumQuestionLength: 300,
  cooldownSeconds: 4,
  limits: [5, 10, 20, 50],
} as const;

export interface Turn { question: string; answer: string }

export type Refusal = 'empty' | 'tooLong' | 'personal' | 'unkind';

export function refusalMessage(r: Refusal): string {
  switch (r) {
    case 'empty': return L('Type a question first.');
    case 'tooLong': return L('That question is long. Try asking it in fewer words.');
    case 'personal': return L("Please don't write phone numbers, emails or addresses. Ask about the app instead!");
    case 'unkind': return L("Let's keep it kind. Ask me about Ablox!");
  }
}

export function looksPersonal(text: string): boolean {
  const digits = [...text].filter((c) => /[0-9０-９]/.test(c)).length;
  if (digits >= 8) return true;
  if (/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/.test(text)) return true;
  if (/\d+\s*[-ー−]\s*\d+\s*[-ー−]\s*\d+/.test(text)) return true;
  const lower = text.toLowerCase();
  return ['住所', '電話番号', 'でんわばんごう', 'じゅうしょ', 'address', 'phone number'].some((w) => lower.includes(w));
}

export function check(question: string, moderator = new ChatModerator()): Refusal | null {
  const q = question.trim();
  if (!q) return 'empty';
  if ([...q].length > AI.maximumQuestionLength) return 'tooLong';
  if (looksPersonal(q)) return 'personal';
  if (moderator.filter(q).wasFiltered) return 'unkind';
  return null;
}

export function isPlausibleKey(key: string): boolean {
  const k = key.trim();
  return k.length >= 20 && k.length <= 200 && !/\s/.test(k) && /^[\x21-\x7e]+$/.test(k);
}

export function systemPrompt(japanese: boolean): string {
  if (japanese) {
    return 'あなたは 子ども向けゲームアプリ「Ablox」の 案内係「アブロボ」です。小学生にも わかる やさしい日本語で、3〜4文で みじかく 答えます。むずかしい漢字は ひらがなにします。\n'
      + 'Ablox でできること: 「あそぶ」タブで ゲームをえらぶ／ルームを作る（ホスト）／コードで入る。同じWi-Fi・インターネット（おうちの人が 家族設定で オン）・Bluetooth で いっしょに あそべる。'
      + '「つくる」タブ（Ablox Studio）で ブロックを おいて ワールドを作り、.absc スクリプトで ルールを 書ける。「ミー」タブで アバター・クローゼット・アルバム・ごほうび。コインは ゲームや ミッションで もらえる。'
      + '設定: 音・グラフィック・操作・ことば。家族設定（パスコード）: 時間・チャット・ルーム・コイン。うまくいかないとき: アプリを 開きなおす、Wi-Fi を たしかめる、ゲームを ダウンロードしなおす。\n'
      + 'きまり: Ablox の使い方と ゲームの あそび方だけに 答える。名前・住所・学校・電話・写真など 個人のことは 聞かない・言わない。こわい話・らんぼうな話・おとなの話は しない。わからないことは 「おうちの人に きいてね」と言う。ほかのアプリや サイトへ さそわない。';
  }
  return 'You are "Ablobo", the guide inside Ablox, a building-and-games app for children. Answer in plain words a seven-year-old can follow, in three or four short sentences.\n'
    + 'Ablox: the Play tab lists games; host a room or join with a code. Play together on the same Wi-Fi, over the internet (a grown-up turns it on in Family settings) or over Bluetooth. '
    + 'The Create tab is Ablox Studio: place blocks to build a world and write rules in .absc scripts. The Me tab has the avatar, closet, album and rewards. Coins come from games and missions. '
    + 'Settings: sound, graphics, controls, language. Family settings (passcode): play time, chat, rooms, coins. If something breaks: reopen the app, check the Wi-Fi, download the game again.\n'
    + 'Rules: only help with using Ablox and playing its games. Never ask for or repeat names, addresses, schools, phone numbers or photos. Nothing scary, violent or grown-up. If unsure, say "ask a grown-up". Never send anyone to other apps or websites.';
}

export function requestBody(question: string, history: Turn[], japanese: boolean, model: string = AI.model): string {
  const messages: { role: string; content: string }[] = [{ role: 'system', content: systemPrompt(japanese) }];
  for (const t of history.slice(-AI.historyTurns)) {
    messages.push({ role: 'user', content: t.question.slice(0, AI.maximumQuestionLength) });
    messages.push({ role: 'assistant', content: t.answer.slice(0, 600) });
  }
  messages.push({ role: 'user', content: question.slice(0, AI.maximumQuestionLength) });
  return JSON.stringify({ model, messages, max_tokens: AI.maximumTokens, temperature: 0.3 });
}

export type Failure = 'badKey' | 'busy' | 'offline' | 'unreadable' | { server: number };

export function failureMessage(f: Failure): string {
  if (typeof f === 'object') return L('The AI had a problem ({}). Try again later.', f.server);
  switch (f) {
    case 'badKey': return L("The AI key doesn't work. Ask a grown-up to check it in Family settings.");
    case 'busy': return L('The AI is busy right now. Try again in a minute.');
    case 'offline': return L("Can't reach the AI. Check the internet connection.");
    case 'unreadable': return L("The AI's answer didn't make sense. Try asking again.");
  }
}

export function clean(text: string): string {
  let t = text.trim();
  for (const mark of ['**', '__', '```', '##', '#']) t = t.split(mark).join('');
  t = t.replace(/https?:\/\/\S+/g, '').trim();
  return [...t].length > 700 ? [...t].slice(0, 700).join('') + '…' : t;
}

export function reply(status: number, body: unknown, moderator = new ChatModerator()): { ok: true; text: string } | { ok: false; failure: Failure } {
  if (status === 401 || status === 403) return { ok: false, failure: 'badKey' };
  if (status === 429) return { ok: false, failure: 'busy' };
  if (status !== 200) return { ok: false, failure: { server: status } };
  const content = (body as { choices?: { message?: { content?: unknown } }[] } | null)?.choices?.[0]?.message?.content;
  if (typeof content !== 'string') return { ok: false, failure: 'unreadable' };
  const text = clean(content);
  if (!text) return { ok: false, failure: 'unreadable' };
  return { ok: true, text: moderator.filter(text).text };
}

// MARK: The help list

export interface Entry { keywords: string[]; answer: string }

export const FAQ: Entry[] = [
  { keywords: ['room', 'host', 'ルーム', 'へや', '部屋', 'ホスト', 'つくる部屋'], answer: 'Open the Play tab, choose a game and tap Host. Your room gets a code — tell it to your friends so they can join.' },
  { keywords: ['join', 'code', '入る', 'はいる', 'コード', 'さんか', '参加'], answer: 'Open the Play tab and tap Join. Type the room code your friend shows you, or pick a room nearby.' },
  { keywords: ['friend', 'together', '友だち', 'ともだち', '友達', 'いっしょ', '一緒'], answer: 'On the same Wi-Fi, one of you hosts and the others join. Over the internet, a grown-up turns it on in Family settings first.' },
  { keywords: ['internet', 'online', 'インターネット', 'オンライン', '遠く', 'とおく'], answer: 'Internet play is off until a grown-up turns it on in Settings → Family. Then rooms can be joined from anywhere with the code.' },
  { keywords: ['bluetooth', 'ブルートゥース'], answer: 'Turn on Rooms over Bluetooth in Settings. Then rooms nearby show up even without Wi-Fi.' },
  { keywords: ['coin', 'money', 'コイン', 'おかね', 'お金'], answer: 'You get coins by playing games, finishing missions and opening the daily reward. Spend them in the shop on looks for your avatar.' },
  { keywords: ['avatar', 'clothes', 'closet', 'hat', 'アバター', '服', 'ふく', 'クローゼット', 'きがえ', '着替え', 'ぼうし'], answer: 'Open the Me tab and tap Closet. Pick colours, hats, faces and pets, then tap Done.' },
  { keywords: ['build', 'studio', 'world', 'make', 'つくる', '作る', 'ワールド', 'スタジオ', 'ブロック'], answer: 'Open the Create tab to start Ablox Studio. Place blocks, paint them, and press Play to test your world.' },
  { keywords: ['script', 'absc', 'rule', 'code', 'スクリプト', 'プログラム', 'ルール'], answer: 'In Studio, open the Script tab. Try a sample game first, then change a number and press Test run to see what happens.' },
  { keywords: ['move', 'control', 'jump', 'walk', 'うごかし', '動かし', '操作', 'ジャンプ', 'あるく', '歩く'], answer: 'Use the stick on the left to walk and the button on the right to jump. Drag on the screen to look around. With a keyboard: WASD and space.' },
  { keywords: ['camera', 'first person', 'カメラ', '視点', 'してん', '一人称'], answer: 'Tap the eye button in a game to switch between first and third person. Pinch to zoom the camera.' },
  { keywords: ['chat', 'message', 'talk', 'チャット', 'メッセージ', '話す', 'はなす'], answer: 'Tap the chat bubble in a game to send a message or a ready-made phrase. Be kind — rude words are hidden.' },
  { keywords: ['download', 'update', 'ダウンロード', 'アップデート', '更新', 'こうしん'], answer: 'Games download when you open them. If one looks old or broken, open its page and download it again.' },
  { keywords: ['lag', 'slow', 'laggy', '重い', 'おもい', 'カクカク', 'おそい'], answer: 'Lower the graphics in Settings, close other apps, and stay close to the Wi-Fi router.' },
  { keywords: ['crash', 'broken', 'error', 'bug', 'バグ', 'エラー', 'こわれ', 'とまった', '止まった', '落ちる'], answer: 'Close Ablox and open it again. If it keeps happening, tell us in the suggestion box in Settings.' },
  { keywords: ['sound', 'music', 'volume', '音', 'おと', '音楽', 'おんがく'], answer: 'Settings has the sound, effects and music volumes. In a game, the pause menu has them too.' },
  { keywords: ['language', 'english', 'japanese', '言語', 'ことば', '英語', '日本語'], answer: 'Settings → Language switches Ablox between English and Japanese.' },
  { keywords: ['time', 'limit', 'play time', '時間', 'じかん', 'あとどれ'], answer: 'A grown-up can set how long you can play each day in Family settings. The app shows how many minutes are left.' },
  { keywords: ['suggest', 'idea', 'request', '目安箱', 'めやすばこ', 'アイデア', 'リクエスト', '要望'], answer: 'Settings has a suggestion box. Write your idea for a game or a feature — the team reads every one.' },
  { keywords: ['photo', 'picture', 'album', '写真', 'しゃしん', 'アルバム', 'スクショ'], answer: 'Tap the camera button in a game to take a picture. Your pictures are in the Album on the Me tab.' },
  { keywords: ['npc', 'bot', 'ボット', 'なかま', 'ひとり', '一人'], answer: 'Many games bring NPC friends when few people are playing. Say /npc in chat to turn them on or off.' },
  { keywords: ['web', 'browser', 'computer', 'ブラウザ', 'パソコン', 'ウェブ'], answer: "Ablox also runs in a web browser. You can join an iPad's internet room from there with the room code." },
];

export const SUGGESTIONS = ['How do I make a room?', 'How do I play with friends?', 'How do I get coins?',
  'How do I change my avatar?', 'How do I build a world?', 'The game is slow'];

export function faqAnswer(question: string): { text: string; score: number } | null {
  const q = question.toLowerCase();
  let best: Entry | null = null, bestHits = 0;
  for (const e of FAQ) {
    const hits = e.keywords.filter((k) => q.includes(k.toLowerCase())).length;
    if (hits > bestHits) { best = e; bestHits = hits; }
  }
  return best ? { text: L(best.answer), score: Math.min(1, 0.55 + bestHits * 0.2) } : null;
}

// MARK: This browser's settings, key and daily count

function store(): Storage | null {
  try { return typeof localStorage === 'undefined' ? null : localStorage; } catch { return null; }
}

export interface Settings { enabled: boolean; dailyLimit: number }

export function readSettings(): Settings {
  try {
    const v = JSON.parse(store()?.getItem('ablox.ai') ?? '{}') as Partial<Settings>;
    return { enabled: v.enabled === true, dailyLimit: AI.limits.includes(v.dailyLimit as never) ? v.dailyLimit! : 20 };
  } catch { return { enabled: false, dailyLimit: 20 }; }
}

export function writeSettings(s: Settings): void {
  try { store()?.setItem('ablox.ai', JSON.stringify(s)); } catch { /* private mode */ }
}

export function readKey(): string | null {
  try { const k = store()?.getItem('ablox.ai.key'); return k && k.length > 0 ? k : null; } catch { return null; }
}

export function saveKey(key: string | null): void {
  try { if (key) store()?.setItem('ablox.ai.key', key); else store()?.removeItem('ablox.ai.key'); } catch { /* private mode */ }
}

function dayKey(d = new Date()): string {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}

interface Usage { day: string; count: number; last: number }

function readUsage(): Usage {
  try { return { day: '', count: 0, last: 0, ...(JSON.parse(store()?.getItem('ablox.ai.usage') ?? '{}') as Partial<Usage>) }; } catch { return { day: '', count: 0, last: 0 }; }
}

export function questionsLeft(limit: number, now = new Date()): number {
  const u = readUsage();
  return u.day === dayKey(now) ? Math.max(0, limit - u.count) : limit;
}

function record(now = new Date()): void {
  const u = readUsage();
  const day = dayKey(now);
  const next: Usage = { day, count: (u.day === day ? u.count : 0) + 1, last: now.getTime() / 1000 };
  try { store()?.setItem('ablox.ai.usage', JSON.stringify(next)); } catch { /* private mode */ }
}

function coolingDown(now = Date.now() / 1000): boolean {
  return now - readUsage().last < AI.cooldownSeconds;
}

export async function askAI(question: string, history: Turn[], fetcher: typeof fetch = fetch): Promise<{ ok: true; text: string } | { ok: false; failure: Failure }> {
  const key = readKey();
  if (!key) return { ok: false, failure: 'badKey' };
  let result: { ok: true; text: string } | { ok: false; failure: Failure } = { ok: false, failure: 'unreadable' };
  for (const model of AI.models) {
    let status: number;
    try {
      const response = await fetcher(AI.endpoint, {
        method: 'POST',
        headers: { Authorization: `Bearer ${key}`, 'Content-Type': 'application/json' },
        body: requestBody(question, history, language() === 'ja', model),
      });
      status = response.status;
      let body: unknown = null;
      try { body = await response.json(); } catch { body = null; }
      result = reply(status, body);
    } catch {
      return { ok: false, failure: 'offline' };
    }
    // A model the provider no longer has: try the next one.
    if (status !== 404 && status !== 400) return result;
  }
  return result;
}

// MARK: The sheets

/** Settings → AI helper: the conversation. */
export function aiHelperSheet(): void {
  const sheet = openSheet(L('AI helper'));
  const b = sheet.body;
  b.classList.add('ab-ai');
  const log = el('div', 'ab-ai-log', b);
  const history: Turn[] = [];
  const settings = readSettings();
  const ready = () => settings.enabled && readKey() !== null;
  const say = (who: 'child' | 'list' | 'ai' | 'note', text: string) => {
    const bubble = el('div', `ab-ai-bubble ${who}`, log);
    if (who === 'list' || who === 'ai') el('small', '', bubble, who === 'ai' ? L('From the AI') : L('From the help list'));
    el('div', '', bubble, text);
    log.scrollTop = log.scrollHeight;
  };
  say('note', L("Hi! I'm Ablobo. Ask me how to use Ablox."));
  const chips = el('div', 'ab-ai-chips', b);
  const form = el('form', 'ab-ai-form', b);
  const input = el('input', '', form);
  input.placeholder = L('Ask about Ablox…');
  input.maxLength = AI.maximumQuestionLength;
  const send = el('button', 'ab-block', form, L('Ask'));
  send.type = 'submit';
  const status = el('small', 'ab-pad-note', b);
  const showStatus = () => {
    const left = questionsLeft(settings.dailyLimit);
    if (!ready()) status.textContent = L('A grown-up can turn on the AI in Family settings. Until then, answers come from the help list.');
    else if (left === 0) status.textContent = L('No AI questions left today. The help list still answers.');
    else status.textContent = L('{} AI questions left today', left) + ' · ' + L('AI answers can be wrong. If something seems odd, ask a grown-up.');
  };
  let thinking = false;
  const ask = async (raw: string) => {
    if (thinking) return;
    const q = raw.trim();
    const refusal = check(q);
    if (refusal) { if (refusal !== 'empty') say('note', refusalMessage(refusal)); return; }
    say('child', q);
    const known = faqAnswer(q);
    const left = questionsLeft(settings.dailyLimit);
    if (known && (known.score >= 0.75 || !ready() || left === 0)) { say('list', known.text); return; }
    if (!ready()) { say('note', L("I don't know that one yet. Try one of the buttons, or ask a grown-up.")); return; }
    if (left === 0) { say('note', L('No AI questions left today. The help list still answers.')); return; }
    if (coolingDown()) { say('note', L('Wait a moment before the next question.')); return; }
    thinking = true;
    send.disabled = true;
    const wait = el('div', 'ab-ai-bubble note', log, L('Thinking…'));
    record();
    const result = await askAI(q, history);
    wait.remove();
    thinking = false;
    send.disabled = false;
    if (result.ok) {
      say('ai', result.text);
      history.push({ question: q, answer: result.text });
    } else {
      say('note', failureMessage(result.failure));
      if (known) say('list', known.text);
    }
    showStatus();
  };
  for (const s of SUGGESTIONS) {
    const chip = el('button', 'ab-chip', chips, L(s));
    chip.type = 'button';
    chip.onclick = () => { void ask(L(s)); };
  }
  form.onsubmit = (e) => { e.preventDefault(); const q = input.value; input.value = ''; void ask(q); };
  showStatus();
  input.focus();
}

/** Family → AI helper: on or off, how many a day, and the grown-up's key. */
export function aiFamilySection(parent: HTMLElement, redraw: () => void): void {
  const settings = readSettings();
  el('h3', '', parent, L('AI helper (for grown-ups)'));
  const row = el('label', 'ab-field', parent);
  const box = el('input', '', row);
  box.type = 'checkbox';
  box.checked = settings.enabled;
  el('span', '', row, L("Use the AI for questions the help list can't answer"));
  box.onchange = () => { writeSettings({ ...readSettings(), enabled: box.checked }); };
  const limitRow = el('label', 'ab-field', parent);
  el('span', '', limitRow, L('Questions a day'));
  const select = el('select', '', limitRow);
  for (const n of AI.limits) {
    const o = el('option', '', select, String(n));
    o.value = String(n);
    if (n === settings.dailyLimit) o.selected = true;
  }
  select.onchange = () => { writeSettings({ ...readSettings(), dailyLimit: Number(select.value) }); };
  if (readKey()) {
    const keyRow = el('div', 'ab-actions', parent);
    el('span', 'ab-ok-note', keyRow, L('Key saved in this browser'));
    const remove = el('button', 'ab-block danger', keyRow, L('Remove key'));
    remove.onclick = () => { saveKey(null); redraw(); };
  } else {
    const keyRow = el('div', 'ab-actions', parent);
    const keyInput = el('input', '', keyRow);
    keyInput.type = 'password';
    keyInput.autocomplete = 'off';
    keyInput.placeholder = L('API key (Groq)');
    const save = el('button', 'ab-block', keyRow, L('Save key'));
    const note = el('small', 'ab-warning-note', parent);
    save.onclick = () => {
      const k = keyInput.value.trim();
      if (!isPlausibleKey(k)) { note.textContent = L("That doesn't look like a key."); return; }
      saveKey(k);
      redraw();
    };
  }
  el('small', 'ab-pad-note', parent, L('The key stays in this browser only. Questions go to the provider with it; nothing else is sent. Get a free key at console.groq.com.'));
}
