import { describe, expect, it } from 'vitest';
import { ScriptRandom } from '../src/core/script/values';

describe('ScriptRandom', () => {
  it('is SplitMix64', () => {
    // The reference outputs of SplitMix64 from seed 0.
    const r = new ScriptRandom(0);
    expect(r.next().toString(16)).toBe('e220a8397b1dcdaf');
    expect(r.next().toString(16)).toBe('6e789e6aa1b965f4');
    expect(r.next().toString(16)).toBe('6c45d188009454f');
  });
});
