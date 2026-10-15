// Words over the world: names over heads, labels over blocks, chat bubbles
// and emoji stamps — Engine/NameTagOverlay.swift, BlockLabelOverlay.swift and
// ChatBubbleOverlay.swift. Drawn as HTML over the 3D view, so text is sharp
// at any size, with the same sizes and fades as on the iPad.
import { cssColor } from '../core/model/color';
import { bubbleColours, namePlateColours, type BubbleStyle, type NamePlate } from '../core/model/avatar';
import type { BlockLabel } from '../core/model/world';

export interface ScreenPoint { x: number; y: number; distance: number }

export interface NameTag { id: string; name: string; title: string; plate: NamePlate; isNPC: boolean; at: ScreenPoint }
export interface LabelItem { id: string; label: BlockLabel; at: ScreenPoint }
export interface Speaker { id: string; lines: string[]; style: BubbleStyle; at: ScreenPoint }

function element(className: string, parent: HTMLElement): HTMLDivElement {
  const div = document.createElement('div');
  div.className = className;
  parent.appendChild(div);
  return div;
}

export class Overlays {
  readonly root: HTMLDivElement;
  private tags = new Map<string, { el: HTMLDivElement; key: string }>();
  private labels = new Map<string, { el: HTMLDivElement; key: string }>();
  private bubbles = new Map<string, { el: HTMLDivElement; key: string }>();
  private stamps = new Map<string, { el: HTMLDivElement; emoji: string; since: number }>();
  sizeFactor = 1;
  showNames = true;

  constructor(parent: HTMLElement) {
    this.root = element('ab-overlays', parent);
  }

  showStamp(id: string, emoji: string): void {
    const existing = this.stamps.get(id);
    if (existing) existing.el.remove();
    const el = element('ab-stamp', this.root);
    el.textContent = emoji;
    this.stamps.set(id, { el, emoji, since: performance.now() });
  }

  updateNames(tags: NameTag[]): void {
    const seen = new Set<string>();
    const now = performance.now();
    for (const tag of tags) {
      seen.add(tag.id);
      const scale = Math.max(0.55, Math.min(1.1, 14 / Math.max(tag.at.distance, 1))) * this.sizeFactor;
      const visible = this.showNames && tag.name !== '' && tag.at.distance < (tag.isNPC ? 18 : 45);
      let entry = this.tags.get(tag.id);
      if (visible) {
        if (!entry) {
          entry = { el: element('ab-nametag', this.root), key: '' };
          this.tags.set(tag.id, entry);
        }
        const key = tag.name + '|' + tag.title + '|' + tag.plate;
        if (entry.key !== key) {
          entry.key = key;
          const c = namePlateColours[tag.plate];
          entry.el.style.background = cssColor(c.background);
          entry.el.style.color = cssColor(c.text);
          entry.el.style.border = c.border ? `2px solid ${cssColor(c.border)}` : 'none';
          entry.el.innerHTML = '';
          const name = document.createElement('div');
          name.className = 'ab-nametag-name';
          name.textContent = tag.name;
          entry.el.appendChild(name);
          if (tag.title) {
            const title = document.createElement('div');
            title.className = 'ab-nametag-title';
            title.textContent = tag.title;
            title.style.color = cssColor(c.accent);
            entry.el.appendChild(title);
          }
        }
        entry.el.style.transform = `translate3d(${tag.at.x}px, ${tag.at.y}px, 0) translate(-50%, -100%) scale(${scale})`;
        entry.el.style.zIndex = String(1000 - Math.round(tag.at.distance));
      } else if (entry) {
        entry.el.remove();
        this.tags.delete(tag.id);
      }
      const stamp = this.stamps.get(tag.id);
      if (stamp) {
        const age = (now - stamp.since) / 1000;
        if (age > 2.6) {
          stamp.el.remove();
          this.stamps.delete(tag.id);
        } else {
          const pop = Math.min(1, age / 0.18);
          stamp.el.style.opacity = String(Math.min(1, (2.6 - age) / 0.5));
          stamp.el.style.transform = `translate3d(${tag.at.x}px, ${tag.at.y - 44 * scale - age * 18}px, 0) translate(-50%, -100%) scale(${pop * scale})`;
        }
      }
    }
    for (const [id, entry] of this.tags) if (!seen.has(id)) { entry.el.remove(); this.tags.delete(id); }
    for (const [id, stamp] of this.stamps) if (!seen.has(id)) { stamp.el.remove(); this.stamps.delete(id); }
  }

  updateLabels(items: LabelItem[], maximum = 48): void {
    const nearest = items.sort((a, b) => a.at.distance - b.at.distance).slice(0, maximum);
    const seen = new Set<string>();
    for (const item of nearest) {
      seen.add(item.id);
      let entry = this.labels.get(item.id);
      if (!entry) {
        entry = { el: element('ab-label', this.root), key: '' };
        this.labels.set(item.id, entry);
      }
      const key = JSON.stringify(item.label.lines);
      if (entry.key !== key) {
        entry.key = key;
        entry.el.innerHTML = '';
        for (const line of item.label.lines) {
          const div = document.createElement('div');
          div.textContent = line.text;
          div.style.color = cssColor(line.color);
          entry.el.appendChild(div);
        }
      }
      const fade = Math.max(0.5, Math.min(1.25, 16 / Math.max(item.at.distance, 1)));
      const scale = fade * item.label.size;
      const fadeLength = Math.max(item.label.range * 0.15, 1);
      const alpha = Math.min(1, Math.max(0, (item.label.range - item.at.distance) / fadeLength));
      entry.el.style.opacity = String(alpha);
      entry.el.style.zIndex = String(500 - Math.round(item.at.distance));
      entry.el.style.transform = `translate3d(${item.at.x}px, ${item.at.y}px, 0) translate(-50%, -100%) scale(${scale})`;
    }
    for (const [id, entry] of this.labels) if (!seen.has(id)) { entry.el.remove(); this.labels.delete(id); }
  }

  updateBubbles(speakers: Speaker[]): void {
    const seen = new Set<string>();
    for (const s of speakers) {
      seen.add(s.id);
      let entry = this.bubbles.get(s.id);
      if (!entry) {
        entry = { el: element('ab-bubbles', this.root), key: '' };
        this.bubbles.set(s.id, entry);
      }
      const key = s.style + '|' + s.lines.join('\n');
      if (entry.key !== key) {
        entry.key = key;
        const c = bubbleColours[s.style];
        entry.el.innerHTML = '';
        s.lines.forEach((line, i) => {
          const b = document.createElement('div');
          b.className = 'ab-bubble' + (i === s.lines.length - 1 ? ' ab-bubble-last' : '');
          b.textContent = line;
          b.style.background = cssColor(c.background);
          b.style.color = cssColor(c.text);
          b.style.setProperty('--tail', cssColor(c.background));
          if (c.border) b.style.border = `2px solid ${cssColor(c.border)}`;
          entry!.el.appendChild(b);
        });
      }
      const scale = Math.max(0.6, Math.min(1.1, 14 / Math.max(s.at.distance, 1))) * this.sizeFactor;
      entry.el.style.transform = `translate3d(${s.at.x}px, ${s.at.y - 28 * scale}px, 0) translate(-50%, -100%) scale(${scale})`;
      entry.el.style.zIndex = String(2000 - Math.round(s.at.distance));
    }
    for (const [id, entry] of this.bubbles) if (!seen.has(id)) { entry.el.remove(); this.bubbles.delete(id); }
  }

  clear(): void {
    this.root.innerHTML = '';
    this.tags.clear();
    this.labels.clear();
    this.bubbles.clear();
    this.stamps.clear();
  }
}
