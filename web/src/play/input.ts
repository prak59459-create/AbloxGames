// What the player is asking for: a stick, jump, run and where the camera
// looks — from a keyboard and mouse, a touch screen or a game controller,
// all at once. PlayControls / GameViewport on the iPad.
import type { Vec3 } from '../core/model/math';

export interface CameraLook { yaw: number; pitch: number; zoom: number }

export class PlayInput {
  /** Stick in -1…1, z forward. */
  stick: Vec3 = { x: 0, y: 0, z: 0 };
  jumpHeld = false;
  running = false;
  firing = false;
  look: CameraLook = { yaw: 0, pitch: -18, zoom: 1 };
  /** Set by the player turning the camera, for the follow camera to wait. */
  lastLookAt = 0;
  invertX = false;
  lookSpeed = 1;
  enabled = true;

  private keys = new Set<string>();
  private touchStick: { id: number; ox: number; oy: number; x: number; y: number } | null = null;
  private touchLook: { id: number; x: number; y: number } | null = null;
  private pinch: { a: number; b: number; distance: number; zoom: number } | null = null;
  private mouseDrag: { x: number; y: number } | null = null;
  private stickEl: HTMLDivElement | null = null;
  private knobEl: HTMLDivElement | null = null;
  private cleanup: (() => void)[] = [];
  onKey: (key: string) => void = () => {};
  onTap: (x: number, y: number) => void = () => {};

  attach(surface: HTMLElement): void {
    const on = <K extends keyof HTMLElementEventMap>(el: HTMLElement | Window, type: K, fn: (e: HTMLElementEventMap[K]) => void,
      opts?: AddEventListenerOptions) => {
      el.addEventListener(type, fn as EventListener, opts);
      this.cleanup.push(() => el.removeEventListener(type, fn as EventListener, opts));
    };
    const typing = (e: Event) => {
      const t = e.target as HTMLElement | null;
      return !!t && (t.tagName === 'INPUT' || t.tagName === 'TEXTAREA' || t.isContentEditable);
    };
    on(window, 'keydown', (e: KeyboardEvent) => {
      if (typing(e) || !this.enabled) return;
      const k = e.key.toLowerCase();
      this.keys.add(k);
      if (k === ' ') { this.jumpHeld = true; e.preventDefault(); }
      this.onKey(k);
    });
    on(window, 'keyup', (e: KeyboardEvent) => {
      const k = e.key.toLowerCase();
      this.keys.delete(k);
      if (k === ' ') this.jumpHeld = false;
    });
    on(window, 'blur', () => { this.keys.clear(); this.jumpHeld = false; });

    on(surface, 'pointerdown', (e: PointerEvent) => {
      if (!this.enabled) return;
      if (e.pointerType === 'mouse') {
        this.mouseDrag = { x: e.clientX, y: e.clientY };
        surface.setPointerCapture(e.pointerId);
        this.tapStart = { x: e.clientX, y: e.clientY, t: performance.now() };
        return;
      }
      const rect = surface.getBoundingClientRect();
      const x = e.clientX - rect.left, y = e.clientY - rect.top;
      if (x < rect.width * 0.42 && !this.touchStick) {
        this.touchStick = { id: e.pointerId, ox: x, oy: y, x, y };
        this.showStick(x, y);
      } else if (!this.touchLook) {
        this.touchLook = { id: e.pointerId, x: e.clientX, y: e.clientY };
        this.tapStart = { x: e.clientX, y: e.clientY, t: performance.now() };
      } else if (!this.pinch) {
        const a = this.touchLook;
        this.pinch = { a: a.id, b: e.pointerId, distance: Math.hypot(a.x - e.clientX, a.y - e.clientY), zoom: this.look.zoom };
        this.pinchPoints.set(e.pointerId, { x: e.clientX, y: e.clientY });
        this.pinchPoints.set(a.id, { x: a.x, y: a.y });
      }
      surface.setPointerCapture(e.pointerId);
    });
    on(surface, 'pointermove', (e: PointerEvent) => {
      if (e.pointerType === 'mouse' && this.mouseDrag) {
        this.turn(e.clientX - this.mouseDrag.x, e.clientY - this.mouseDrag.y, 0.3);
        this.mouseDrag = { x: e.clientX, y: e.clientY };
        return;
      }
      if (this.pinch && (e.pointerId === this.pinch.a || e.pointerId === this.pinch.b)) {
        this.pinchPoints.set(e.pointerId, { x: e.clientX, y: e.clientY });
        const a = this.pinchPoints.get(this.pinch.a), b = this.pinchPoints.get(this.pinch.b);
        if (a && b) {
          const d = Math.hypot(a.x - b.x, a.y - b.y);
          this.look.zoom = Math.max(0.4, Math.min(2.2, this.pinch.zoom * (this.pinch.distance / Math.max(20, d))));
        }
        return;
      }
      if (this.touchStick && e.pointerId === this.touchStick.id) {
        const rect = surface.getBoundingClientRect();
        this.touchStick.x = e.clientX - rect.left;
        this.touchStick.y = e.clientY - rect.top;
        this.moveKnob();
      } else if (this.touchLook && e.pointerId === this.touchLook.id) {
        this.turn(e.clientX - this.touchLook.x, e.clientY - this.touchLook.y, 0.42);
        this.touchLook.x = e.clientX;
        this.touchLook.y = e.clientY;
      }
    });
    const end = (e: PointerEvent) => {
      if (this.tapStart && Math.hypot(e.clientX - this.tapStart.x, e.clientY - this.tapStart.y) < 8
        && performance.now() - this.tapStart.t < 350) {
        const rect = surface.getBoundingClientRect();
        this.onTap(e.clientX - rect.left, e.clientY - rect.top);
      }
      this.tapStart = null;
      if (e.pointerType === 'mouse') { this.mouseDrag = null; return; }
      if (this.pinch && (e.pointerId === this.pinch.a || e.pointerId === this.pinch.b)) {
        this.pinch = null;
        this.pinchPoints.clear();
      }
      if (this.touchStick?.id === e.pointerId) {
        this.touchStick = null;
        this.hideStick();
      }
      if (this.touchLook?.id === e.pointerId) this.touchLook = null;
    };
    on(surface, 'pointerup', end);
    on(surface, 'pointercancel', end);
    on(surface, 'wheel', (e: WheelEvent) => {
      e.preventDefault();
      this.look.zoom = Math.max(0.4, Math.min(2.2, this.look.zoom * Math.exp(e.deltaY * 0.0015)));
    }, { passive: false });
    on(surface, 'contextmenu', (e: Event) => e.preventDefault());

    this.stickEl = document.createElement('div');
    this.stickEl.className = 'ab-stick';
    this.knobEl = document.createElement('div');
    this.knobEl.className = 'ab-stick-knob';
    this.stickEl.appendChild(this.knobEl);
    surface.appendChild(this.stickEl);
  }

  private pinchPoints = new Map<number, { x: number; y: number }>();
  private tapStart: { x: number; y: number; t: number } | null = null;

  detach(): void {
    for (const c of this.cleanup) c();
    this.cleanup = [];
    this.stickEl?.remove();
  }

  private turn(dx: number, dy: number, speed: number): void {
    const x = this.invertX ? -dx : dx;
    this.look.yaw -= x * speed;
    this.look.pitch -= dy * speed * this.lookSpeed;
    this.look.pitch = Math.max(-80, Math.min(80, this.look.pitch));
    this.lastLookAt = performance.now();
  }

  private showStick(x: number, y: number): void {
    if (!this.stickEl) return;
    this.stickEl.style.display = 'block';
    this.stickEl.style.left = `${x}px`;
    this.stickEl.style.top = `${y}px`;
    this.moveKnob();
  }

  private hideStick(): void {
    if (this.stickEl) this.stickEl.style.display = 'none';
  }

  private moveKnob(): void {
    if (!this.touchStick || !this.knobEl) return;
    const radius = 56;
    let dx = this.touchStick.x - this.touchStick.ox, dy = this.touchStick.y - this.touchStick.oy;
    const d = Math.hypot(dx, dy);
    if (d > radius) { dx *= radius / d; dy *= radius / d; }
    this.knobEl.style.transform = `translate(${dx}px, ${dy}px)`;
  }

  /** Reads the keyboard, the touch stick and any game controller for this frame. */
  poll(): void {
    let x = 0, z = 0;
    const k = this.keys;
    if (k.has('w') || k.has('arrowup')) z += 1;
    if (k.has('s') || k.has('arrowdown')) z -= 1;
    if (k.has('a') || k.has('arrowleft')) x -= 1;
    if (k.has('d') || k.has('arrowright')) x += 1;
    if (k.has('q')) this.look.yaw += 2;
    if (k.has('e')) this.look.yaw -= 2;
    let jump = this.jumpHeld;
    let run = k.has('shift');
    if (this.touchStick) {
      const radius = 56;
      const dx = (this.touchStick.x - this.touchStick.ox) / radius, dy = (this.touchStick.y - this.touchStick.oy) / radius;
      x += Math.max(-1, Math.min(1, dx));
      z -= Math.max(-1, Math.min(1, dy));
      if (Math.hypot(dx, dy) > 1.15) run = true;
    }
    const pads = typeof navigator !== 'undefined' && navigator.getGamepads ? navigator.getGamepads() : [];
    for (const pad of pads) {
      if (!pad) continue;
      const dead = (v: number) => (Math.abs(v) < 0.15 ? 0 : v);
      x += dead(pad.axes[0] ?? 0);
      z -= dead(pad.axes[1] ?? 0);
      const lx = dead(pad.axes[2] ?? 0), ly = dead(pad.axes[3] ?? 0);
      if (lx || ly) this.turn(lx * 14, ly * 10, 0.5);
      if (pad.buttons[0]?.pressed) jump = true;
      if (pad.buttons[10]?.pressed || pad.buttons[4]?.pressed) run = true;
      if (pad.buttons[7]?.pressed) this.firing = true;
    }
    const m = Math.hypot(x, z);
    if (m > 1) { x /= m; z /= m; }
    this.stick = this.enabled ? { x, y: 0, z } : { x: 0, y: 0, z: 0 };
    this.running = this.enabled && run;
    this.jumpWanted = this.enabled && jump;
  }

  jumpWanted = false;
}
