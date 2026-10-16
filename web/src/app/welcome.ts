// The first visit: hello, the language, a name, a look, and where things
// are. Four short steps; any can be skipped, and nothing here is needed to
// play.
import { ChatModerator } from '../core/model/chat';
import { itemsOf, isFree } from '../core/model/economy';
import { prefix, trimmed } from '../core/model/text';
import { cssColor } from '../core/model/color';
import { L, language, setLanguage } from '../i18n';
import { AvatarStage } from './avatarStage';
import { wearing } from './player';
import { icon, type ShellContext } from './shell';
import { el, openSheet } from './sheets';

const seenKey = 'ablox.welcomed';

export function hasBeenWelcomed(): boolean {
  try { return localStorage.getItem(seenKey) === '1'; } catch { return true; }
}

const nameIdeas = ['BlueFox', 'SunnyCat', 'StarPanda', 'LuckyDuck', 'MintBunny', 'RocketOwl', 'PixelBear', 'CloudFrog', 'TurboPenguin', 'MapleDog'];

export function welcome(ctx: ShellContext, done: () => void): void {
  let step = 0;
  let stage: AvatarStage | null = null;
  const sheet = openSheet(L('Welcome to Ablox!'), () => {
    stage?.dispose();
    try { localStorage.setItem(seenKey, '1'); } catch { /* private mode */ }
    done();
  });
  sheet.body.parentElement?.classList.add('ab-welcome');

  const draw = () => {
    stage?.dispose();
    stage = null;
    const b = sheet.body;
    b.innerHTML = '';
    const dots = el('div', 'ab-steps', b);
    for (let i = 0; i < 4; i++) el('span', i === step ? 'on' : i < step ? 'done' : '', dots);
    const next = (label = L('Next')) => {
      const row = el('div', 'ab-actions end', b);
      if (step > 0) {
        const back = el('button', 'ab-block secondary', row, L('Back'));
        back.onclick = () => { step -= 1; draw(); };
      }
      const go = el('button', 'ab-block green', row, label);
      go.onclick = () => {
        ctx.sound.play(step === 3 ? 'win' : 'click');
        if (step === 3) { sheet.close(); return; }
        step += 1;
        draw();
      };
      return go;
    };
    switch (step) {
      case 0: {
        const hero = el('div', 'ab-welcome-hero', b);
        icon('mascot', hero, 'mascot');
        el('p', '', hero, L('Play block games with friends, dress up your avatar, and make games of your own.'));
        el('h3', '', b, L('Language'));
        const seg = el('div', 'ab-seg big', b);
        for (const [key, text] of [['ja', '日本語'], ['en', 'English']] as const) {
          const button = el('button', key === language() ? 'on' : '', seg, text);
          button.onclick = () => { setLanguage(key); draw(); };
        }
        next().focus();
        break;
      }
      case 1: {
        el('p', 'ab-pad-title', b, L('What should we call you?'));
        el('p', 'ab-pad-note', b, L('Everyone in a room sees this name. Not your real name — make one up!'));
        const field = el('label', 'ab-field', b);
        el('span', '', field, L('Your name'));
        const input = el('input', '', field);
        input.maxLength = 24;
        input.autocomplete = 'off';
        input.value = ctx.profile().displayName === 'Player' ? '' : ctx.profile().displayName;
        input.placeholder = 'Player';
        const ideas = el('div', 'ab-tags', b);
        const shuffled = [...nameIdeas].sort(() => Math.random() - 0.5).slice(0, 4);
        for (const idea of shuffled) {
          const chip = el('button', 'ab-tag', ideas, idea);
          chip.onclick = () => { input.value = idea; ctx.sound.play('pop'); };
        }
        const save = () => {
          const name = prefix(trimmed(input.value), 24);
          if (name) ctx.setProfile({ ...ctx.profile(), displayName: ChatModerator.cleanName(name) });
        };
        const go = next();
        const original = go.onclick;
        go.onclick = (e) => { save(); (original as (e: MouseEvent) => void)?.call(go, e); };
        input.onkeydown = (e) => { if (e.key === 'Enter') go.click(); };
        setTimeout(() => input.focus(), 50);
        break;
      }
      case 2: {
        el('p', 'ab-pad-title', b, L('Pick your colours'));
        const look = el('div', 'ab-welcome-look', b);
        const box = el('div', 'stage', look);
        try { stage = new AvatarStage(box, ctx.profile(), { zoom: 1.1 }); } catch { /* no 3D: the swatches still work */ }
        const side = el('div', 'swatches', look);
        for (const kind of ['bodyColor', 'headColor', 'accentColor'] as const) {
          el('small', '', side, kind === 'bodyColor' ? L('Body') : kind === 'headColor' ? L('Head & arms') : L('Legs & hat'));
          const row = el('div', 'row', side);
          for (const item of itemsOf(kind).filter(isFree)) {
            const s = el('button', 'swatch', row);
            s.style.background = item.color ? cssColor(item.color) : '#888';
            s.setAttribute('aria-label', L(item.name));
            s.onclick = () => {
              const p = wearing(ctx.profile(), item);
              ctx.setProfile(p);
              stage?.show(p);
              stage?.play('hop');
              ctx.sound.play('pop');
            };
          }
        }
        el('p', 'ab-pad-note', b, L('Earn coins in games for more colours, hats, faces and pets in Me.'));
        next();
        break;
      }
      default: {
        el('p', 'ab-pad-title', b, L('Here is where everything is'));
        const tour = el('div', 'ab-tour', b);
        const rows: [string, string, string][] = [
          ['home', L('Home'), L('Your daily bonus and today’s missions.')],
          ['play', L('Play'), L('Every game, and rooms to play with friends.')],
          ['me', L('Me'), L('Your look, the shop, badges and records.')],
          ['create', L('Create'), L('Play worlds you made, and find sounds.')],
        ];
        for (const [name, title, text] of rows) {
          const row = el('div', 'ab-row', tour);
          icon(name, row, 'big');
          const t = el('div', 'text', row);
          el('b', '', t, title);
          el('small', '', t, text);
        }
        next(L("Let's go!")).focus();
      }
    }
  };
  draw();
}
