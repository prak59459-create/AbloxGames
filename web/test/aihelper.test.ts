import { describe, expect, it, beforeEach } from 'vitest';
import { AI, askAI, check, clean, faqAnswer, isPlausibleKey, looksPersonal, questionsLeft, readSettings, reply, requestBody,
  saveKey, SUGGESTIONS, writeSettings } from '../src/app/aihelper';
import { useLanguageForTests } from '../src/i18n';

class MemoryStorage {
  private map = new Map<string, string>();
  getItem(k: string) { return this.map.get(k) ?? null; }
  setItem(k: string, v: string) { this.map.set(k, v); }
  removeItem(k: string) { this.map.delete(k); }
  clear() { this.map.clear(); }
  key() { return null; }
  get length() { return this.map.size; }
}

beforeEach(() => {
  (globalThis as unknown as { localStorage: MemoryStorage }).localStorage = new MemoryStorage();
  useLanguageForTests('en');
});

describe('AI helper (as AbloxCore/AIHelper.swift)', () => {
  it('refuses empty, long, personal and unkind questions before sending', () => {
    expect(check('  ')).toBe('empty');
    expect(check('あ'.repeat(AI.maximumQuestionLength + 1))).toBe('tooLong');
    expect(check('my number is 090 1234 5678')).toBe('personal');
    expect(check('mail sam@example.com')).toBe('personal');
    expect(looksPersonal('住所は 1-2-3 です')).toBe(true);
    expect(check('you are stupid')).toBe('unkind');
    expect(check('How do I make a room?')).toBeNull();
    expect(check('code ABC-123 and level 12')).toBeNull();
  });

  it('sends a small request with only the last turns and no key', () => {
    const history = [1, 2, 3, 4].map((n) => ({ question: `q${n}`, answer: `a${n}` }));
    const body = JSON.parse(requestBody('How do I join?', history, false));
    expect(body.model).toBe(AI.model);
    expect(body.max_tokens).toBe(AI.maximumTokens);
    expect(body.messages).toHaveLength(1 + AI.historyTurns * 2 + 1);
    expect(body.messages[0].role).toBe('system');
    expect(body.messages[1].content).toBe('q3');
    expect(JSON.stringify(body)).not.toContain('Bearer');
  });

  it('reads answers and failures, and tidies the text', () => {
    expect(reply(200, { choices: [{ message: { content: '**Tap** Host. https://x.example/y' } }] })).toEqual({ ok: true, text: 'Tap Host.' });
    expect(reply(401, null)).toEqual({ ok: false, failure: 'badKey' });
    expect(reply(429, null)).toEqual({ ok: false, failure: 'busy' });
    expect(reply(500, null)).toEqual({ ok: false, failure: { server: 500 } });
    expect(reply(200, {})).toEqual({ ok: false, failure: 'unreadable' });
    expect(clean('## Hi')).toBe('Hi');
  });

  it('answers the common questions from the list, in both languages', () => {
    for (const s of SUGGESTIONS) expect(faqAnswer(s)).not.toBeNull();
    expect(faqAnswer('コインの あつめかたは？')).not.toBeNull();
    expect(faqAnswer('zzzz')).toBeNull();
    useLanguageForTests('ja');
    expect(faqAnswer('ルームの 作りかたは？')?.text).toContain('ホスト');
  });

  it('keeps the settings, the key and the day\'s count in this browser', async () => {
    expect(readSettings()).toEqual({ enabled: false, dailyLimit: 20 });
    writeSettings({ enabled: true, dailyLimit: 5 });
    expect(readSettings()).toEqual({ enabled: true, dailyLimit: 5 });
    expect(isPlausibleKey('short')).toBe(false);
    expect(await askAI('hi', [], (async () => { throw new Error('not called'); }) as unknown as typeof fetch)).toEqual({ ok: false, failure: 'badKey' });
    saveKey('k'.repeat(30));
    let sent: RequestInit | undefined;
    const fake = (async (_url: string, init: RequestInit) => {
      sent = init;
      return new Response(JSON.stringify({ choices: [{ message: { content: 'Tap Host.' } }] }), { status: 200 });
    }) as unknown as typeof fetch;
    expect(await askAI('How do I host?', [], fake)).toEqual({ ok: true, text: 'Tap Host.' });
    expect((sent?.headers as Record<string, string>).Authorization).toBe('Bearer ' + 'k'.repeat(30));
    expect(questionsLeft(5)).toBe(5);
    const tried: string[] = [];
    const gone = (async (_url: string, init: RequestInit) => {
      tried.push(JSON.parse(String(init.body)).model);
      return tried.length === 1 ? new Response('{}', { status: 404 }) : new Response(JSON.stringify({ choices: [{ message: { content: 'Hi.' } }] }), { status: 200 });
    }) as unknown as typeof fetch;
    expect(await askAI('hello', [], gone)).toEqual({ ok: true, text: 'Hi.' });
    expect(tried).toEqual(AI.models);
    const offline = (async () => { throw new TypeError('fetch failed'); }) as unknown as typeof fetch;
    expect(await askAI('x', [], offline)).toEqual({ ok: false, failure: 'offline' });
  });
});
