// Little celebrations in the menu: coins flying from a button to the coin
// count, and confetti for something big. Skipped when the system asks for
// less motion.
import { iconURL } from '../play/hud';

const reduced = () => typeof matchMedia === 'function' && matchMedia('(prefers-reduced-motion: reduce)').matches;

/** Coins from `from` to the coin count at the top. */
export function coinBurst(from: HTMLElement, count = 9): void {
  if (reduced()) return;
  const target = document.querySelector('.ab-bar .ab-pill.coins img') as HTMLElement | null;
  const a = from.getBoundingClientRect();
  const b = target?.getBoundingClientRect() ?? { left: innerWidth - 80, top: 20, width: 24, height: 24 };
  const x0 = a.left + a.width / 2, y0 = a.top + a.height / 2;
  const x1 = b.left + b.width / 2, y1 = b.top + b.height / 2;
  for (let i = 0; i < count; i++) {
    const coin = document.createElement('img');
    coin.src = iconURL('coin');
    coin.className = 'ab-flying-coin';
    document.body.appendChild(coin);
    const spread = 70;
    const mx = x0 + (Math.random() - 0.5) * spread * 2, my = y0 - 40 - Math.random() * spread;
    const delay = i * 45;
    const anim = coin.animate([
      { transform: `translate(${x0 - 14}px, ${y0 - 14}px) scale(0.4)`, opacity: 0 },
      { transform: `translate(${mx - 14}px, ${my - 14}px) scale(1.1)`, opacity: 1, offset: 0.35 },
      { transform: `translate(${x1 - 14}px, ${y1 - 14}px) scale(0.7)`, opacity: 0.9 },
    ], { duration: 720, delay, easing: 'cubic-bezier(.5,0,.4,1)', fill: 'both' });
    anim.onfinish = () => {
      coin.remove();
      if (i === count - 1 && target) {
        target.animate([{ transform: 'scale(1)' }, { transform: 'scale(1.35)' }, { transform: 'scale(1)' }], { duration: 260 });
      }
    };
  }
}

/** Confetti over the whole page: a level, a big buy. */
export function confetti(pieces = 60): void {
  if (reduced()) return;
  const colors = ['#22d3ee', '#f472b6', '#ffc93c', '#4ade80', '#a855f7', '#ff9f1c'];
  for (let i = 0; i < pieces; i++) {
    const p = document.createElement('div');
    p.className = 'ab-confetti';
    p.style.background = colors[i % colors.length];
    document.body.appendChild(p);
    const x = Math.random() * innerWidth;
    const drift = (Math.random() - 0.5) * 240;
    const spin = (Math.random() - 0.5) * 1080;
    const anim = p.animate([
      { transform: `translate(${x}px, -20px) rotate(0deg)`, opacity: 1 },
      { transform: `translate(${x + drift}px, ${innerHeight + 30}px) rotate(${spin}deg)`, opacity: 0.8 },
    ], { duration: 1400 + Math.random() * 1200, delay: Math.random() * 300, easing: 'cubic-bezier(.2,.6,.4,1)', fill: 'both' });
    anim.onfinish = () => p.remove();
  }
}
