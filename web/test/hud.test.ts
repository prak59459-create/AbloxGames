import { describe, expect, it } from 'vitest';
import { scriptUIScale } from '../src/play/hud';

describe("a game's screen on a small screen", () => {
  it('keeps its size on an iPad or a laptop', () => {
    expect(scriptUIScale(1280, 736)).toBe(1);
    expect(scriptUIScale(820, 1116)).toBe(1);
    expect(scriptUIScale(600, 450)).toBe(1);
  });

  it('is shown smaller on a phone, but never too small to read', () => {
    expect(scriptUIScale(430, 780)).toBeCloseTo(0.717, 3);
    expect(scriptUIScale(844, 326)).toBeCloseTo(0.724, 3);
    expect(scriptUIScale(390, 780)).toBe(0.65);
  });
});
