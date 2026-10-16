// SocialTests.swift, ChatExtrasTests.swift and FamilySafetyTests.swift: the
// word filter, tidying and the flood guard.
import { describe, expect, it } from 'vitest';
import { ChatModerator, ChatRateLimiter, ChatTidy, MuteList } from '../src/core/model/chat';

const moderator = new ChatModerator();

describe('the word filter', () => {
  it('masks blocked words, keeping the length', () => {
    expect(moderator.filter('you are stupid')).toEqual({ text: 'you are ******', wasFiltered: true });
    expect(moderator.filter('idiot').text).toBe('*****');
  });

  it('leaves clean lines and ordinary words alone', () => {
    expect(moderator.filter('want to build a castle?')).toEqual({ text: 'want to build a castle?', wasFiltered: false });
    for (const innocent of ['classic', 'assignment', 'Scunthorpe', 'crapulence']) {
      expect(moderator.filter(innocent), innocent).toEqual({ text: innocent, wasFiltered: false });
    }
  });

  it('matches in any case, phrases whole, every time', () => {
    expect(moderator.filter('STUPID').wasFiltered).toBe(true);
    expect(moderator.filter('StUpId').wasFiltered).toBe(true);
    const phrase = moderator.filter('just shut up');
    expect(phrase.wasFiltered).toBe(true);
    expect(phrase.text).not.toContain('shut');
    expect(phrase.text).not.toContain('up');
    expect(moderator.filter('stupid stupid stupid').text).toBe('****** ****** ******');
  });

  it('can be extended, made strict or turned off', () => {
    expect(new ChatModerator(['banana']).filter('banana').wasFiltered).toBe(true);
    expect(moderator.filter('banana').wasFiltered).toBe(false);
    expect(new ChatModerator([], false).filter('stupid')).toEqual({ text: 'stupid', wasFiltered: false });
    expect(moderator.filter('what a noob').text).toBe('what a noob');
    expect(new ChatModerator([], true, true).filter('what a noob').text).toBe('what a ****');
    expect(new ChatModerator([], true, true).filter('やくそくだよ').text).toBe('やくそくだよ');
    expect(new ChatModerator(['banana']).filter('I like banana').text).toBe('I like ******');
  });

  it('handles empty, spaces and long input, and Japanese', () => {
    expect(moderator.filter('').wasFiltered).toBe(false);
    expect(moderator.filter('   ').wasFiltered).toBe(false);
    const long = 'stupid '.repeat(200);
    const result = moderator.filter(long);
    expect(result.wasFiltered).toBe(true);
    expect(result.text.length).toBe(long.length);
    expect(moderator.filter('おまえ死ねよ').wasFiltered).toBe(true);
    expect(moderator.filter('それだけばかりだ').wasFiltered).toBe(false);
  });

  it('checks names even with filtering off', () => {
    expect(ChatModerator.cleanName('Stupid Sam')).toBe('Player');
    expect(ChatModerator.cleanName('Aoi')).toBe('Aoi');
    expect(ChatModerator.cleanName('キモい人')).toBe('Player');
  });
});

describe('tidying', () => {
  it('hides personal details but keeps scores and times', () => {
    expect(ChatTidy.personalInfoHidden('call me 090-1234-5678 ok')).toBe('call me ••• ok');
    expect(ChatTidy.personalInfoHidden('０９０１２３４５６７８')).toBe('•••');
    expect(ChatTidy.personalInfoHidden('mail kai@example.com')).toBe('mail •••');
    expect(ChatTidy.personalInfoHidden('see https://example.com/x now')).toBe('see ••• now');
    expect(ChatTidy.personalInfoHidden('go to youtube.com')).toBe('go to •••');
    expect(ChatTidy.personalInfoHidden('I got 125000 points in 3:45')).toBe('I got 125000 points in 3:45');
    expect(ChatTidy.personalInfoHidden('room 12, level 7')).toBe('room 12, level 7');
  });

  it('softens shouting, squashes repeats and finds mentions', () => {
    expect(ChatTidy.shoutingSoftened('COME HERE EVERYONE')).toBe('Come here everyone');
    expect(ChatTidy.shoutingSoftened('OK GG')).toBe('OK GG');
    expect(ChatTidy.shoutingSoftened('すごい WOW')).toBe('すごい WOW');
    expect(ChatTidy.repeatsSquashed('hiiiiiiii!!!!!!')).toBe('hiii!!!');
    expect(ChatTidy.repeatsSquashed('wwwwwww')).toBe('www');
    expect(ChatTidy.repeatsSquashed('book')).toBe('book');
    expect(ChatTidy.mentions('Kai', 'hey kai, over here')).toBe(true);
    expect(ChatTidy.mentions('Kai', '@Kai!')).toBe(true);
    expect(ChatTidy.mentions('Kai', 'kaiju attack')).toBe(false);
    expect(ChatTidy.mentions('K', 'k')).toBe(false);
    expect(ChatTidy.tidy('CALL 09012345678 NOWWWWWW', { hidePersonalInfo: true, softenShouting: false, squashRepeats: true })).toBe('CALL ••• NOWWW');
  });
});

describe('the flood guard and mutes', () => {
  it('allows five lines in ten seconds, not the same line twice in five', () => {
    const limiter = new ChatRateLimiter();
    expect(limiter.allow('hi', 0)).toEqual({ kind: 'ok' });
    expect(limiter.allow('HI ', 1)).toEqual({ kind: 'repeated' });
    expect(limiter.allow('hi', 6)).toEqual({ kind: 'ok' });
    expect(limiter.allow('a', 7)).toEqual({ kind: 'ok' });
    expect(limiter.allow('b', 7.5)).toEqual({ kind: 'ok' });
    expect(limiter.allow('c', 8)).toEqual({ kind: 'ok' });
    const fast = limiter.allow('d', 8.5);
    expect(fast.kind).toBe('tooFast');
    expect(fast.kind === 'tooFast' && fast.seconds > 0).toBe(true);
    expect(limiter.allow('d', 16.5)).toEqual({ kind: 'ok' });
  });

  it('never mutes our own lines', () => {
    const mutes = new MuteList();
    expect(mutes.toggle('B')).toBe(true);
    expect(mutes.allows('B', 'A')).toBe(false);
    expect(mutes.allows('A', 'A')).toBe(true);
    mutes.mute('A');
    expect(mutes.allows('A', 'A')).toBe(true);
    expect(mutes.toggle('B')).toBe(false);
    expect(mutes.allows('B', 'A')).toBe(true);
  });
});
