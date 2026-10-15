// The time of day — DayCycle in AbloxCore/WorldFeatures.swift.
import type { ColorRGBA } from './color';
import type { EnvironmentSettings } from './world';

const wrap = (hour: number) => {
  if (!Number.isFinite(hour)) return 12;
  const w = hour % 24;
  return w < 0 ? w + 24 : w;
};

export function hourAt(start: number, dayLengthMinutes: number, elapsed: number): number {
  if (!(dayLengthMinutes > 0) || !Number.isFinite(elapsed)) return wrap(start);
  return wrap(start + (elapsed / 60 / dayLengthMinutes) * 24);
}

/** The hour now, on the wall clock, counted from when the world's day started. */
export function worldHour(env: EnvironmentSettings, wallClockSeconds: number): number | null {
  if (env.timeOfDay === undefined) return null;
  const elapsed = env.dayEpoch !== undefined ? Math.max(0, wallClockSeconds - env.dayEpoch) : 0;
  return hourAt(env.timeOfDay, env.dayLengthMinutes, elapsed);
}

export const sunHeight = (hour: number) => Math.cos(((wrap(hour) - 12) / 12) * Math.PI);

export function sunPitch(hour: number): number {
  const angle = (Math.asin(Math.min(1, Math.abs(sunHeight(hour)))) * 180) / Math.PI;
  return -Math.max(8, angle);
}

export const sunYaw = (hour: number) => (wrap(hour) / 24) * 360 - 90;

export function daylight(hour: number): number {
  return 0.25 + 0.75 * Math.max(0, Math.min(1, sunHeight(hour) * 2.2 + 0.25));
}

export const isNight = (hour: number) => sunHeight(hour) < -0.1;

const mix = (a: ColorRGBA, b: ColorRGBA, amount: number): ColorRGBA => {
  const t = Math.max(0, Math.min(1, amount));
  return { r: a.r + (b.r - a.r) * t, g: a.g + (b.g - a.g) * t, b: a.b + (b.b - a.b) * t, a: a.a + (b.a - a.a) * t };
};
export { mix as mixColor };

export function skyAt(hour: number, top: ColorRGBA, bottom: ColorRGBA): { top: ColorRGBA; bottom: ColorRGBA } {
  const h = sunHeight(hour);
  const night = { top: { r: 0.02, g: 0.03, b: 0.09, a: 1 }, bottom: { r: 0.05, g: 0.07, b: 0.16, a: 1 } };
  const dusk = { top: { r: 0.23, g: 0.2, b: 0.45, a: 1 }, bottom: { r: 0.98, g: 0.55, b: 0.3, a: 1 } };
  if (h >= 0.35) return { top, bottom };
  if (h >= 0) {
    const t = 1 - h / 0.35;
    return { top: mix(top, dusk.top, t * 0.8), bottom: mix(bottom, dusk.bottom, t * 0.85) };
  }
  const t = Math.min(1, -h / 0.3);
  return { top: mix(dusk.top, night.top, t), bottom: mix(dusk.bottom, night.bottom, t) };
}
