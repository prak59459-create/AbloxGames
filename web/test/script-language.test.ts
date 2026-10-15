// AbloxScript, the language — Tests/AbloxCoreTests/ScriptLanguageTests.swift, line for line.
import { describe, expect, it } from 'vitest';
import { error, interpreter, run } from './helpers';

describe('values and arithmetic', () => {
  it('does arithmetic', () => {
    expect(run('print(1 + 2 * 3)')).toEqual(['7']);
    expect(run('print((1 + 2) * 3)')).toEqual(['9']);
    expect(run('print(7 / 2)')).toEqual(['3.5']);
    expect(run('print(-1 % 4)')).toEqual(['3']);
    expect(run('print(-(2 + 3))')).toEqual(['-5']);
  });

  it('prints whole numbers without a decimal point', () => {
    expect(run('print(10)')).toEqual(['10']);
    expect(run('print(0.1 + 0.2)')).toEqual(['0.3']);
  });

  it('joins text with + when either side is text', () => {
    expect(run('print("Score: " + 5)')).toEqual(['Score: 5']);
    expect(run('print(5 + " points")')).toEqual(['5 points']);
    expect(run('print("a" .. "b" .. 1)')).toEqual(['ab1']);
  });

  it('compares and does logic', () => {
    expect(run('print(1 < 2, 2 <= 2, 3 > 4, 1 == 1, 1 != 1)')).toEqual(['true true false true false']);
    expect(run('print(true and false, true or false, not true)')).toEqual(['false true false']);
  });

  it('gives a default with or', () => {
    expect(run('let name = nil\nprint(name or "Guest")')).toEqual(['Guest']);
  });

  it('treats only nil and false as false', () => {
    expect(run('if 0 then print("zero is true") end')).toEqual(['zero is true']);
    expect(run('if "" then print("empty text is true") end')).toEqual(['empty text is true']);
    expect(run('if nil then print("x") else print("nil is false") end')).toEqual(['nil is false']);
  });

  it('refuses to divide by zero', () => {
    expect(error('print(1 / 0)')?.kind).toBe('runtime');
    expect(error('print(1 % 0)')?.kind).toBe('runtime');
  });
});

describe('variables and scope', () => {
  it('has variables', () => {
    expect(run('let x = 1\nx = x + 1\nprint(x)')).toEqual(['2']);
  });

  it('refuses to assign to an undeclared name, and suggests the real one', () => {
    const failure = error('let score = 0\nscroe = 1');
    expect(failure?.line).toBe(2);
    expect(failure?.message).toContain('score');
  });

  it('suggests the real name when reading', () => {
    expect(error('let players = 3\nprint(palyers)')?.message).toContain('players');
  });

  it('suggests nothing unrelated', () => {
    const failure = error('print(zebra)');
    expect(failure).not.toBeNull();
    expect(failure?.message).not.toContain('Did you mean');
  });

  it('gives blocks their own scope', () => {
    expect(run('let x = 1\nif true then\n    let x = 2\n    print(x)\nend\nprint(x)')).toEqual(['2', '1']);
  });

  it('takes names in any script', () => {
    expect(run('let 体力 = 100\n体力 = 体力 - 30\nprint(体力)')).toEqual(['70']);
  });
});

describe('control flow', () => {
  it('does if, elif and else', () => {
    const source = [
      'func grade(n)',
      '    if n >= 90 then return "A"',
      '    elif n >= 50 then return "B"',
      '    else return "C" end',
      'end',
      'print(grade(95), grade(60), grade(10))',
    ].join('\n');
    expect(run(source)).toEqual(['A B C']);
  });

  it('loops with break and continue', () => {
    const source = [
      'let i = 0', 'let seen = []', 'while true do', '    i = i + 1',
      '    if i == 3 then continue end', '    if i > 5 then break end', '    append(seen, i)', 'end', 'print(seen)',
    ].join('\n');
    expect(run(source)).toEqual(['[1, 2, 4, 5]']);
  });

  it('counts inclusively and down on its own', () => {
    expect(run('for i in 1 to 3 do print(i) end')).toEqual(['1', '2', '3']);
    expect(run('for i in 3 to 1 do print(i) end')).toEqual(['3', '2', '1']);
    expect(run('for i in 0 to 10 step 5 do print(i) end')).toEqual(['0', '5', '10']);
  });

  it('refuses a step of zero', () => {
    expect(error('for i in 1 to 5 step 0 do end')?.kind).toBe('runtime');
  });

  it('goes over lists, maps and text', () => {
    expect(run('for x in [10, 20] do print(x) end')).toEqual(['10', '20']);
    expect(run('for k in { a: 1, b: 2 } do print(k) end')).toEqual(['a', 'b']);
    expect(run('for c in "hi" do print(c) end')).toEqual(['h', 'i']);
  });

  it('does not run forever when a loop adds to its own list', () => {
    expect(run('let items = [1, 2]\nfor x in items do append(items, x) end\nprint(len(items))')).toEqual(['4']);
  });
});

describe('functions', () => {
  it('recurses', () => {
    expect(run('func fact(n)\n    if n <= 1 then return 1 end\n    return n * fact(n - 1)\nend\nprint(fact(5))')).toEqual(['120']);
  });

  it('captures scope in closures', () => {
    const source = [
      'func counter()', '    let n = 0', '    return func()', '        n = n + 1', '        return n', '    end', 'end',
      'let next = counter()', 'next()', 'print(next())',
    ].join('\n');
    expect(run(source)).toEqual(['2']);
  });

  it('passes nil for missing arguments and drops extra ones', () => {
    expect(run('func f(a, b) print(a, b) end\nf(1)\nf(1, 2, 3)')).toEqual(['1 nil', '1 2']);
  });
});

describe('lists and maps', () => {
  it('counts lists from one', () => {
    expect(run('let l = [10, 20, 30]\nprint(l[1], l[3], l.length)')).toEqual(['10 30 3']);
  });

  it('reads nil past the end, and refuses to write there', () => {
    expect(run('let l = [1]\nprint(l[5])')).toEqual(['nil']);
    expect(error('let l = [1]\nl[5] = 2')?.message).toContain('append');
  });

  it('shares lists', () => {
    expect(run('func add(list) append(list, 3) end\nlet mine = [1, 2]\nadd(mine)\nprint(mine)')).toEqual(['[1, 2, 3]']);
  });

  it('has maps', () => {
    const source = 'let p = { hp: 100, name: "Mika" }\np.hp = p.hp - 25\np["team"] = "red"\nprint(p.hp, p.name, p.team, p.missing)';
    expect(run(source)).toEqual(['75 Mika red nil']);
  });

  it('removes an entry set to nil', () => {
    const source = 'let broken = { a: true, b: true }\nbroken["a"] = nil\nbroken.b = nil\nbroken.c = true\nprint(len(broken), join(keys(broken), ","), broken.a)';
    expect(run(source)).toEqual(['1 c nil']);
  });

  it('has a standard library', () => {
    expect(run('print(len([1,2,3]), floor(2.7), max(1, 9, 4), clamp(15, 0, 10))')).toEqual(['3 2 9 10']);
    expect(run('print(join(split("a,b,c", ","), "-"), upper("ab"), contains([1,2], 2))')).toEqual(['a-b-c AB true']);
    expect(run('print(num("12") + 1, num("twelve"))')).toEqual(['13 nil']);
  });

  it('rolls seeded random numbers in range', () => {
    const first = run('for i in 1 to 5 do print(random(1, 6)) end');
    const second = run('for i in 1 to 5 do print(random(1, 6)) end');
    expect(first).toEqual(second);
    for (const v of first) expect(Number(v) >= 1 && Number(v) <= 6).toBe(true);
  });
});

describe('the limits', () => {
  it('stops an infinite loop', () => {
    const failure = error('while true do end');
    expect(failure?.kind).toBe('limit');
    expect(failure?.line).toBe(1);
  });

  it('stops an infinite loop inside a function', () => {
    expect(error('func spin() while true do let x = 1 end end\nspin()')?.kind).toBe('limit');
  });

  it('stops infinite recursion and names the function', () => {
    const failure = error('func forever(n) return forever(n + 1) end\nforever(1)');
    expect(failure?.kind).toBe('limit');
    expect(failure?.message).toContain('forever');
  });

  it('stops a list growing without limit', () => {
    expect(error('let l = []\nwhile true do append(l, 1) end', { maximumCollectionSize: 100, stepsPerCall: 1_000_000 })?.kind).toBe('limit');
  });

  it('stops text growing without limit', () => {
    expect(error('let s = "x"\nwhile true do s = s .. s end', { maximumTextLength: 1000, stepsPerCall: 1_000_000 })?.kind).toBe('limit');
  });

  it('budgets per call, not per script', () => {
    const i = interpreter('on tick()\n    for i in 1 to 300 do let x = i end\nend', { stepsPerCall: 2000 });
    i.start();
    for (let n = 0; n < 20; n++) expect(() => i.fire('tick')).not.toThrow();
  });

  it('refuses deeply nested source in the parser', () => {
    const source = '('.repeat(500) + '1' + ')'.repeat(500);
    expect(error(`print(${source})`)?.kind).toBe('limit');
  });

  it('caps print output', () => {
    expect(run('for i in 1 to 100 do print(i) end', { maximumOutputLines: 10 }).length).toBe(10);
  });
});

describe('syntax errors that help', () => {
  it('names the block a missing end opened', () => {
    const failure = error('let x = 1\nif x > 0 then\n    print(x)');
    expect(failure?.line).toBe(2);
    expect(failure?.message).toContain('if');
  });

  it('names a single = in a condition', () => {
    expect(error('let hp = 0\nif hp = 0 then end')?.message).toContain('==');
  });

  it('names an extra end', () => {
    const failure = error('print(1)\nend');
    expect(failure?.line).toBe(2);
    expect(failure?.message).toContain('end');
  });

  it('names a reserved word used as a name', () => {
    expect(error('let end = 1')?.message).toContain('end');
  });

  it('points an unclosed string at its line', () => {
    expect(error('print(1)\nprint("oops)\nprint(2)')?.line).toBe(2);
  });

  it('flags a line that does nothing', () => {
    expect(error('let x = 1\nx + 1')).not.toBeNull();
  });

  it('takes comments in both styles', () => {
    expect(run('-- a comment\nprint(1) # another\n')).toEqual(['1']);
  });

  it('refuses return outside a function', () => {
    expect(error('return 5')).not.toBeNull();
    expect(error('if true then return 5 end')).not.toBeNull();
  });

  it('refuses break outside a loop', () => {
    expect(error('func f() break end\nf()')).not.toBeNull();
  });
});

describe('handlers', () => {
  it('calls handlers by name and keeps globals', () => {
    const i = interpreter('let total = 0\non add(n) total = total + n end\non report() print(total) end');
    i.start();
    i.fire('add', [3]);
    i.fire('add', [4]);
    i.fire('report');
    expect(i.drainOutput()).toEqual(['7']);
  });

  it('fires an event with no handler harmlessly', () => {
    expect(interpreter('print(1)').fire('nothing')).toBe(false);
  });

  it('refuses two handlers for one event in a file', () => {
    const failure = error('on tick() end\non tick() end');
    expect(failure?.line).toBe(2);
    expect(failure?.message).toContain('1');
  });

  it('refuses a handler inside a function', () => {
    expect(error('func f()\n on tick() end\nend')).not.toBeNull();
  });
});

describe('what an iPad keyboard types', () => {
  it('reads smart quotes as quotes', () => {
    expect(run('print(“hello”)')).toEqual(['hello']);
    expect(run('print(‘it’ + "s")')).toEqual(['its']);
    expect(run('print("mixed”)')).toEqual(['mixed']);
  });

  it('reads full-width symbols', () => {
    expect(run('let ｘ　＝　１２\nprint（ｘ　＋　１）')).toEqual(['13']);
    expect(run('print("（そのまま）")')).toEqual(['（そのまま）']);
  });
});
