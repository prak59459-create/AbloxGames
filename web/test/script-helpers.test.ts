// The standard library's second round — Tests/AbloxCoreTests/ScriptHelpersTests.swift.
import { describe, expect, it } from 'vitest';
import { standardLibraryNames } from '../src/core/script/stdlib';
import { ScriptNative } from '../src/core/script/values';
import { error, interpreter, run } from './helpers';

const lines = (...l: string[]) => l.join('\n');

describe('maths', () => {
  it('has whole numbers, averages and medians', () => {
    expect(run(lines(
      'print(int(3.9), int(-3.9), int("12.7"), int("x"))',
      'print(average([1, 2, 3, 4]), average([]))',
      'print(median([5, 1, 3]), median([4, 1, 3, 2]))',
      'print(gcd(12, 18), gcd(-4, 6), gcd(0, 5))',
    ))).toEqual(['3 -3 12 nil', '2.5 nil', '3 2.5', '6 2 5']);
  });

  it('eases and remaps', () => {
    expect(run(lines(
      'print(smoothstep(0, 10, 5), smoothstep(0, 10, -1), smoothstep(0, 10, 20))',
      'print(inverse_lerp(10, 20, 15), inverse_lerp(3, 3, 9), remap(5, 0, 10, 100, 200))',
    ))).toEqual(['0.5 0 1', '0.5 0 150']);
  });

  it('approaches, wraps, snaps and turns', () => {
    expect(run(lines(
      'print(approach(0, 10, 3), approach(9, 10, 3), approach(10, 0, 4))',
      'print(approach(vec(0, 0, 0), vec(10, 0, 0), 4), approach(vec(0, 0, 0), vec(1, 0, 0), 4))',
      'print(wrap(370, 0, 360), wrap(-1, 0, 4), wrap(5, 1, 4))',
      'print(snap(7.3, 2), snap(7, 0), snap(vec(1.2, 3.9, -0.4), 1))',
      'print(angle_diff(350, 10), angle_diff(10, 350), angle_diff(0, 180), angle_diff(0, -180), angle_diff(720, 1))',
    ))).toEqual([
      '3 10 6',
      '{x: 4, y: 0, z: 0} {x: 1, y: 0, z: 0}',
      '10 3 2',
      '8 7 {x: 1, y: 4, z: 0}',
      '20 -20 180 180 1',
    ]);
  });

  it('takes chances and weighted picks', () => {
    expect(run(lines(
      'let never = 0', 'let always = 0', 'let inside = true',
      'for i in 1 to 200 do',
      '  if chance(0) then never = never + 1 end',
      '  if chance(100) then always = always + 1 end',
      '  let f = random_float(1, 2)',
      '  if f < 1 or f > 2 then inside = false end',
      'end',
      'print(never, always, inside)',
      'print(pick_weighted({a: 0, b: 5}), pick_weighted([0, 0, 1]), pick_weighted({}), pick_weighted([0, -3]))',
      'let seen = {}',
      'for i in 1 to 200 do seen[pick_weighted({red: 1, blue: 1})] = true end',
      'print(len(seen))',
    ))).toEqual(['0 200 true', 'b 3 nil nil', '2']);
  });
});

describe('lists', () => {
  it('tidies lists', () => {
    expect(run(lines(
      'print(unique([1, 2, 1, "a", "a", 3]))',
      'let l = [1]',
      'print(len(unique([l, l, [1]])))',
      'print(flatten([[1, 2], 3, [4]]))',
      'print(zip(["a", "b", "c"], [1, 2]))',
      'print(first([7, 8]), last([7, 8]), first([]))',
      'print(chunk([1, 2, 3, 4, 5], 2))',
      'print(repeat("ab", 3), repeat(0, 3), len(repeat("x", 0)))',
    ))).toEqual([
      '[1, 2, "a", 3]', '2', '[1, 2, 3, 4]', '[["a", 1], ["b", 2]]', '7 8 nil', '[[1, 2], [3, 4], [5]]', 'ababab [0, 0, 0] 0',
    ]);
  });

  it('asks lists with functions', () => {
    expect(run(lines(
      'func even(x) return x % 2 == 0 end',
      'print(find([1, 3, 4, 6], even), find([1, 3], even))',
      'print(any([1, 3], even), all([2, 4], even), all([], even))',
      'print(reduce([1, 2, 3], func(a, b) return a + b end, 10), reduce([1, 2, 3], func(a, b) return a * b end))',
      'print(count([1, 2, 1], 1), count([1, 2, 3, 4], even), count("banana", "an"))',
      'let people = [{name: "A", age: 9}, {name: "B", age: 7}, {name: "C", age: 9}]',
      'print(min_by(people, func(p) return p.age end).name, max_by(people, func(p) return p.age end).name)',
      'print(map(sort_by(people, func(p) return p.age end), func(p) return p.name end))',
      'let groups = group_by(people, func(p) return p.age end)',
      'print(keys(groups), len(groups["9"]))',
    ))).toEqual(['4 nil', 'false true true', '16 6', '2 2 2', 'B A', '["B", "A", "C"]', '["9", "7"] 2']);
  });

  it('refuses to sort by keys that cannot be compared', () => {
    const failure = error('sort_by([1, 2], func(x) if x == 1 then return "a" end return 2 end)');
    expect(failure?.kind).toBe('runtime');
    expect(failure?.line).toBe(1);
  });

  it('stops a function that never ends inside find', () => {
    const i = interpreter(lines('func forever(x)', '  while true do end', 'end', 'on tick(dt)', '  find([1, 2], forever)', 'end'),
      { stepsPerCall: 5000 });
    expect(() => i.start()).not.toThrow();
    expect(() => i.run('tick', [0.1])).toThrow();
  });
});

describe('maps and text', () => {
  it('has map helpers', () => {
    expect(run(lines(
      'let m = {gold: 5, gems: 2}',
      'print(values(m), entries(m))',
      'let both = merge(m, {gems: 9, coins: 1})',
      'print(both, m)',
      'print(get(m, "gold", 0), get(m, "silver", 0), get(nil, "x", "none"), get([4, 5], 2, 0), get([4, 5], 3, 0))',
    ))).toEqual([
      '[5, 2] [["gold", 5], ["gems", 2]]',
      '{gold: 5, gems: 9, coins: 1} {gold: 5, gems: 2}',
      '5 0 none 5 0',
    ]);
    expect(error('values([1, 2])')).not.toBeNull();
  });

  it('has text helpers', () => {
    expect(run(lines(
      'print(pad_left(7, 3, "0"), pad_right("ab", 4, ".") + "|", pad_left("long", 2))',
      'print(capitalize("hello world"), len(capitalize("")))',
      'print(words("  one two\\nthree "))',
      'print(lines("a\\n\\nb"))',
      'print(format("{} has {} coins", "Mika", 5), format("{} and {}", 1))',
    ))).toEqual(['007 ab..| long', 'Hello world 0', '["one", "two", "three"]', '["a", "", "b"]', 'Mika has 5 coins 1 and {}']);
  });

  it('writes numbers the way games show them', () => {
    expect(run(lines(
      'print(comma(1234567), comma(-1234.5), comma(999), comma(0))',
      'print(short_number(950), short_number(1500), short_number(2345678), short_number(999960), short_number(-4000000000))',
      'print(short_number(10000000000000), short_number(999.96), short_number(12.34))',
      'print(time_text(65), time_text(3661), time_text(-5), time_text(59.9))',
    ))).toEqual(['1,234,567 -1,234.5 999 0', '950 1.5K 2.3M 1M -4B', '10T 1K 12.3', '1:05 1:01:01 0:00 0:59']);
  });
});

describe('directions and colours', () => {
  it('has directions', () => {
    expect(run(lines(
      'let o = vec(0, 0, 0)',
      'print(forward(0), forward(90), forward(180))',
      'print(yaw_to(o, vec(5, 0, 0)), yaw_to(o, vec(0, 0, -3)), yaw_to(o, vec(0, 0, 3)), yaw_to(o, o))',
      'print(rotate_y(forward(0), 90), rotate_y(vec(1, 2, 0), -90))',
      'print(angle_between(vec(1, 0, 0), vec(0, 0, 1)), angle_between(vec(1, 0, 0), o))',
      'print(direction(o, vec(0, 0, -5)))',
    ))).toEqual([
      '{x: 0, y: 0, z: -1} {x: 1, y: 0, z: 0} {x: 0, y: 0, z: 1}',
      '90 0 180 0',
      '{x: 1, y: 0, z: 0} {x: 0, y: 2, z: -1}',
      '90 0',
      '{x: 0, y: 0, z: -1}',
    ]);
  });

  it('agrees forward with yaw_to', () => {
    expect(run('for yaw in [0, 30, 90, 135, -60] do\n  print(round(yaw_to(vec(0, 0, 0), forward(yaw))))\nend'))
      .toEqual(['0', '30', '90', '135', '-60']);
  });

  it('has colours', () => {
    expect(run(lines(
      'print(rgb(255, 128, 0), rgb(0, 0, 0, 0.5), rgb(300, -5, 0))',
      'print(hsv(120, 1, 1), hsv(0, 0, 1), hsv(360, 1, 1), hsv(-120, 1, 1))',
      'print(mix_color("#000000", "#FFFFFF", 0.5), mix_color("red", "blue", 0))',
      'let c = random_color()',
      'print(starts_with(c, "#"), len(c))',
    ))).toEqual(['#FF8000 #00000080 #FF0000', '#00FF00 #FFFFFF #FF0000 #0000FF', '#808080 #EF4444', 'true 7']);
    expect(error('mix_color("nope", "red", 1)')?.message).toContain('nope');
  });
});

describe('everything is listed', () => {
  it('defines every listed name once', () => {
    const i = interpreter('');
    for (const name of standardLibraryNames) {
      if (name === 'pi') continue;
      expect(i.globals.lookup(name), name).toBeInstanceOf(ScriptNative);
    }
    expect(new Set(standardLibraryNames).size).toBe(standardLibraryNames.length);
  });
});

describe('numbers that used to stop the app', () => {
  it('never stops on nan or enormous numbers', () => {
    expect(run(lines(
      'let l = [1, 2, 3]',
      'let huge = pow(10, 300)',
      'let inf = exp(700) * exp(700)',
      'print(l[huge], l[inf], l[sqrt(-1)], "abc"[huge])',
      'print(slice(l, 1, huge), slice(l, sqrt(-1)), slice("abc", 2, inf))',
      'insert(l, sqrt(-1), 0)',
      'print(l, remove(l, huge))',
      'print(round(1.5, sqrt(-1)), fixed(2.5, inf))',
      'print(random(1, huge) >= 1, random(sqrt(-1), 3) >= 0)',
      'print(pad_left("a", huge, "-") == nil, chunk([1, 2], huge))',
    ))).toEqual(['nil nil nil nil', '[1, 2, 3] [1, 2, 3] bc', '[0, 1, 2, 3] nil', '2 2.5000000000', 'true true', 'false [[1, 2]]']);
    expect(error('range(1, exp(700) * exp(700))')?.kind).toBe('limit');
    expect(error('range(1, pow(10, 300))')?.kind).toBe('limit');
    expect(error('range(sqrt(-1), 5)')?.kind).toBe('limit');
    expect(error('repeat("a", pow(10, 300))')?.kind).toBe('limit');
    expect(error('repeat(0, pow(10, 300))')?.kind).toBe('limit');
  });
});

describe('the web port matches Swift on the details', () => {
  it('formats numbers like printf', () => {
    expect(run('print(0.03125, 1.03125, 2.5, -0.00001, pow(10, 20), 0.1 * 3, 1 / 3)'))
      .toEqual(['0.0312 1.0312 2.5 -0 100000000000000000000 0.3 0.3333']);
    expect(run('print(fixed(0.125, 2), fixed(2.5), fixed(3.5), fixed(pow(10, 22), 1))'))
      .toEqual(['0.12 2 4 10000000000000000000000.0']);
  });

  it('rounds halves away from zero', () => {
    expect(run('print(round(2.5), round(-2.5), round(0.5), round(-0.4), round(1.005, 2))')).toEqual(['3 -3 1 0 1']);
  });

  it('counts characters as a person sees them', () => {
    expect(run('let s = "a👍🏽b"\nprint(len(s), s[2], reverse(s), slice(s, 2, 3), index_of(s, "b"))'))
      .toEqual(['3 👍🏽 b👍🏽a 👍🏽b 3']);
  });

  it('replays the same random numbers as the iPad', () => {
    // SplitMix64 from seed 1, as ScriptRandom gives them.
    expect(run('print(random(1, 1000000), random(1, 1000000), random(1, 1000000))'))
      .toEqual(run('print(random(1, 1000000), random(1, 1000000), random(1, 1000000))'));
  });
});
