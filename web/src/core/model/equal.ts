// Swift's `==` on plain data: structs and enums compare field by field. Here
// that is a deep comparison of plain objects and arrays, with a missing key
// and `undefined` the same thing (as an absent optional is in Swift).

export function deepEqual(a: unknown, b: unknown): boolean {
  if (a === b) return true;
  if (typeof a === 'number' && typeof b === 'number') return a === b || (Number.isNaN(a) && Number.isNaN(b));
  if (!a || !b || typeof a !== 'object' || typeof b !== 'object') return false;
  if (Array.isArray(a) !== Array.isArray(b)) return false;
  if (Array.isArray(a)) {
    const y = b as unknown[];
    if (a.length !== y.length) return false;
    for (let i = 0; i < a.length; i++) if (!deepEqual(a[i], y[i])) return false;
    return true;
  }
  const x = a as Record<string, unknown>, y = b as Record<string, unknown>;
  for (const key in x) {
    if (x[key] === undefined) { if (y[key] !== undefined) return false; continue; }
    if (!deepEqual(x[key], y[key])) return false;
  }
  for (const key in y) if (y[key] !== undefined && x[key] === undefined) return false;
  return true;
}

/** A copy of plain data, deep. */
export function clone<T>(value: T): T {
  return structuredClone(value);
}
