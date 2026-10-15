// Blocks that move: trips by `move`/`move_to` (BlockTravel.swift, BlockTrips.swift)
// and moving platforms on everyone's clock (MovingParts.swift).
import { add, distance, scale, sub, v3, type Vec3 } from './math';
import type { GimmickSettings } from './world';

export interface BlockTravel { from: Vec3; offset: Vec3; start: number; duration: number }

export const travelEnd = (t: BlockTravel) => t.start + t.duration;

export function travelProgress(t: BlockTravel, clock: number): number {
  if (!(t.duration > 0)) return 1;
  return Math.min(Math.max((clock - t.start) / t.duration, 0), 1);
}

/** Long trips go at a steady speed; short ones speed up and slow down. */
export const steadyFrom = 2;

export function drawnPosition(t: BlockTravel, clock: number): Vec3 {
  const p = travelProgress(t, clock);
  const eased = t.duration >= steadyFrom ? p : p * p * (3 - 2 * p);
  return add(t.from, scale(t.offset, eased));
}

export function travelPosition(t: BlockTravel, clock: number): Vec3 {
  return add(t.from, scale(t.offset, travelProgress(t, clock)));
}

export class BlockTrips {
  trips = new Map<string, BlockTravel>();
  private waiting = new Map<string, { offset: Vec3; start: number; duration: number }>();
  static patience = 5;

  get isEmpty(): boolean { return this.trips.size === 0 && this.waiting.size === 0; }

  start(id: string, current: Vec3, offset: Vec3, duration: number, clock: number): void {
    let end = add(current, offset);
    const trip = this.trips.get(id);
    if (trip && travelEnd(trip) > clock) end = add(add(trip.from, trip.offset), offset);
    this.waiting.delete(id);
    this.trips.set(id, { from: current, offset: sub(end, current), start: clock, duration: Math.max(duration, 0) });
  }

  hold(id: string, offset: Vec3, duration: number, clock: number): void {
    this.waiting.set(id, { offset, start: clock, duration: Math.max(duration, 0) });
  }

  appeared(id: string, position: Vec3, clock: number): boolean {
    const held = this.waiting.get(id);
    if (!held) return false;
    this.waiting.delete(id);
    if (clock > held.start + held.duration + BlockTrips.patience) return false;
    this.trips.set(id, { from: position, offset: held.offset, start: held.start, duration: held.duration });
    return true;
  }

  /** The map has the block at `position` now: keep the trip if that is where it set off or is going. */
  mapHas(id: string, position: Vec3, previously?: Vec3): boolean {
    const trip = this.trips.get(id);
    if (!trip) return false;
    if (previously && distance(position, previously) < 0.001) return true;
    for (const kept of [trip.from, add(trip.from, trip.offset)]) if (distance(position, kept) < 0.001) return true;
    this.trips.delete(id);
    return false;
  }

  position(id: string, clock: number): Vec3 | null {
    const t = this.trips.get(id);
    return t ? drawnPosition(t, clock) : null;
  }

  advance(clock: number): { id: string; position: Vec3 }[] {
    for (const [id, w] of this.waiting) if (clock > w.start + w.duration + BlockTrips.patience) this.waiting.delete(id);
    const placed: { id: string; position: Vec3 }[] = [];
    for (const [id, trip] of this.trips) {
      placed.push({ id, position: drawnPosition(trip, clock) });
      if (travelEnd(trip) <= clock) this.trips.delete(id);
    }
    return placed;
  }

  forget(id: string): void {
    this.trips.delete(id);
    this.waiting.delete(id);
  }

  clear(): void {
    this.trips.clear();
    this.waiting.clear();
  }
}

/** Where a moving platform is, from where it was built, at `time` (seconds since 1970). */
export function movingOffset(g: GimmickSettings, time: number): Vec3 {
  const travel = Math.max(0.2, g.moveSeconds);
  const pause = Math.max(0, g.movePause);
  const cycle = 2 * (travel + pause);
  if (!Number.isFinite(time) || !(cycle > 0)) return v3();
  const t = time % cycle;
  const local = t < 0 ? t + cycle : t;
  const ease = (x: number) => { const c = Math.max(0, Math.min(1, x)); return c * c * (3 - 2 * c); };
  let amount: number;
  if (local < pause) amount = 0;
  else if (local < pause + travel) amount = ease((local - pause) / travel);
  else if (local < 2 * pause + travel) amount = 1;
  else amount = 1 - ease((local - 2 * pause - travel) / travel);
  return scale(g.moveOffset, amount);
}
