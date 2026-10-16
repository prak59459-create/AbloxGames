// The room, on the play screen: what PlayScreen.swift's room bar, join
// requests, vote card and "Reconnecting…" banner show on an iPad. A pill
// says which room this is and how full; it opens the room card (who is
// here, ready, and for the host: asking first, quieting, taking someone
// out). Joining shows its own screen until the host's world has arrived.
import { RoomCode } from '../core/model/reliability';
import { pollTally } from '../net/packets';
import { L } from '../i18n';
import type { PlaySession } from './session';

function el<K extends keyof HTMLElementTagNameMap>(tag: K, className = '', parent?: HTMLElement, text?: string): HTMLElementTagNameMap[K] {
  const e = document.createElement(tag);
  if (className) e.className = className;
  if (text !== undefined) e.textContent = text;
  parent?.appendChild(e);
  return e;
}

export interface RoomUIHost {
  leave(): void;
  /** The room is the host's, on the internet: what the list calls it. */
  roomTitle(): string;
}

export class RoomOverlay {
  private pill: HTMLButtonElement;
  private card: HTMLDivElement;
  private requests: HTMLDivElement;
  private pollCard: HTMLDivElement;
  private banner: HTMLDivElement;
  private cover: HTMLDivElement;
  private coverNote: HTMLDivElement;
  private errorCard: HTMLDivElement;
  private showCard = false;
  private keys = { pill: '', card: '', requests: '', poll: '', status: '' };
  private pollTimer: ReturnType<typeof setInterval> | null = null;
  private unsubscribe: () => void;

  constructor(root: HTMLElement, private session: PlaySession, private host: RoomUIHost) {
    this.pill = el('button', 'ab-room-pill ab-glass ab-hidden', root);
    this.pill.onclick = () => { this.showCard = !this.showCard; this.keys.card = ''; this.render(); };
    this.card = el('div', 'ab-card ab-glass ab-room-card ab-hidden', root);
    this.requests = el('div', 'ab-room-requests', root);
    this.pollCard = el('div', 'ab-card ab-glass ab-poll ab-hidden', root);
    this.banner = el('div', 'ab-room-banner ab-glass ab-hidden', root);

    // Joining: the host's world is on its way.
    this.cover = el('div', 'ab-loading ab-room-cover ab-hidden', root);
    const cube = el('img', 'cube', this.cover);
    cube.src = new URL('icons/friends.webp', document.baseURI).href;
    cube.alt = '';
    el('div', 'title', this.cover, L('Joining {}…', host.roomTitle()));
    this.coverNote = el('div', 'note', this.cover, L('Connecting…'));
    const cancel = el('button', 'ab-block secondary', this.cover, L('Cancel'));
    cancel.onclick = () => this.host.leave();

    this.errorCard = el('div', 'ab-error ab-hidden', root);
    this.unsubscribe = session.subscribe(() => this.render());
    this.pollTimer = setInterval(() => { if (this.session.roomState.poll && !this.session.roomState.poll.isClosed) { this.keys.poll = ''; this.renderPoll(); } }, 1000);
    this.render();
  }

  get isCovering(): boolean { return !this.cover.classList.contains('ab-hidden') || !this.errorCard.classList.contains('ab-hidden'); }

  render(): void {
    this.renderStatus();
    this.renderPill();
    this.renderCard();
    this.renderRequests();
    this.renderPoll();
  }

  private renderStatus(): void {
    const s = this.session;
    const st = s.status;
    const key = JSON.stringify(st) + s.role + s.isWaitingForHost;
    if (key === this.keys.status) return;
    this.keys.status = key;
    // Before the first world: the joining screen. After it, a banner keeps the game in view.
    const beforeWorld = s.role !== 'joined' && s.role !== 'hosting';
    this.cover.classList.toggle('ab-hidden', !(beforeWorld && (st.kind === 'connecting' || st.kind === 'reconnecting')));
    this.coverNote.textContent = s.isWaitingForHost ? L('Waiting for the host to let you in…')
      : st.kind === 'reconnecting' ? st.text : L('Connecting…');
    const showBanner = !beforeWorld && st.kind === 'reconnecting';
    this.banner.classList.toggle('ab-hidden', !showBanner);
    if (showBanner) this.banner.textContent = '📡 ' + st.text;
    this.errorCard.classList.toggle('ab-hidden', st.kind !== 'error');
    if (st.kind === 'error') {
      this.errorCard.innerHTML = '';
      el('b', '', this.errorCard, L('The game ended'));
      el('span', '', this.errorCard, st.text);
      const back = el('button', 'ab-block', this.errorCard, L('Back to the games'));
      back.onclick = () => this.host.leave();
      back.focus();
    }
  }

  private renderPill(): void {
    const s = this.session;
    const inRoom = s.isInRoom && s.status.kind !== 'error';
    const people = s.people.length;
    const capacity = s.roomCapacity;
    const ping = s.pingMilliseconds;
    const key = [inRoom, s.roomCode, people, capacity, ping === null ? '' : Math.round(ping / 10), s.role, s.isReady].join('|');
    if (key === this.keys.pill) return;
    this.keys.pill = key;
    this.pill.classList.toggle('ab-hidden', !inRoom);
    if (!inRoom) return;
    this.pill.innerHTML = '';
    el('span', 'globe', this.pill, '🌐');
    if (s.role === 'hosting') el('span', 'code', this.pill, RoomCode.formatted(s.roomCode));
    el('span', 'count', this.pill, capacity ? `${people}/${capacity}` : String(people));
    if (ping !== null) {
      const p = el('span', 'ping' + (ping > 400 ? ' slow' : ''), this.pill, `${Math.round(ping)} ms`);
      p.title = L('Round trip to the host');
    }
    this.pill.setAttribute('aria-label', L('Room'));
    this.pill.classList.toggle('on', this.showCard);
  }

  private renderCard(): void {
    const s = this.session;
    const room = s.roomState;
    const visible = this.showCard && s.isInRoom && s.status.kind !== 'error';
    const key = [visible, s.role, s.roomCode, [...room.ready].join(','), [...room.quieted].join(','), room.needsApproval, room.allowsWarp,
      s.people.map((p) => p.peerID + p.profile.displayName).join(',')].join('|');
    this.card.classList.toggle('ab-hidden', !visible);
    if (!visible || key === this.keys.card) return;
    this.keys.card = key;
    const c = this.card;
    c.innerHTML = '';
    const head = el('div', 'head', c);
    el('h3', '', head, L('Room'));
    const close = el('button', 'ab-close', head, '✕');
    close.setAttribute('aria-label', L('Close'));
    close.onclick = () => { this.showCard = false; this.render(); };

    if (s.role === 'hosting') {
      const code = el('div', 'ab-room-code', c);
      el('small', '', code, L('Room code'));
      el('b', '', code, RoomCode.formatted(s.roomCode));
      el('div', 'hint', c, L('Friends find this room in Ablox under Internet rooms.'));
    }

    const list = el('div', 'people', c);
    for (const p of s.people) {
      const row = el('div', 'ab-player' + (p.peerID === s.localPeerID ? ' me' : ''), list);
      const dot = el('span', 'dot', row);
      const color = p.profile.bodyColor;
      dot.style.background = `rgb(${Math.round(color.r * 255)}, ${Math.round(color.g * 255)}, ${Math.round(color.b * 255)})`;
      el('span', 'name', row, p.profile.displayName + (p.peerID === s.localPeerID ? ' ' + L('(you)') : ''));
      if (room.ready.has(p.peerID)) el('span', 'ready', row, '✓');
      if (room.quieted.has(p.peerID)) el('span', 'quiet', row, '🔇');
      if (p.peerID === s.localPeerID) continue;
      if (s.role === 'hosting') {
        const quiet = el('button', 'small', row, room.quieted.has(p.peerID) ? L('Let them chat again') : L('Quiet'));
        quiet.onclick = () => s.setQuieted(p.peerID, !room.quieted.has(p.peerID));
        const out = el('button', 'small danger', row, L('Remove from room'));
        out.onclick = () => {
          if (out.dataset.sure) { s.removeFromRoom(p.peerID); return; }
          out.dataset.sure = '1';
          out.textContent = L('Sure?');
          setTimeout(() => { delete out.dataset.sure; out.textContent = L('Remove from room'); }, 3000);
        };
      } else if (room.allowsWarp) {
        const go = el('button', 'small', row, L('Go to them'));
        go.onclick = () => { s.warp(p.peerID); this.showCard = false; this.render(); };
      }
    }

    const actions = el('div', 'actions', c);
    const toggle = (label: string, on: boolean, set: (v: boolean) => void) => {
      const row = el('div', 'ab-setting', actions);
      el('label', '', row, label);
      const t = el('button', 'ab-toggle' + (on ? ' on' : ''), row);
      t.setAttribute('role', 'switch');
      t.setAttribute('aria-checked', String(on));
      t.setAttribute('aria-label', label);
      t.onclick = () => set(!on);
    };
    toggle(L("I'm ready"), s.isReady, (v) => s.setReady(v));
    if (s.role === 'hosting') {
      toggle(L('Ask me before anyone joins'), room.needsApproval, (v) => s.setNeedsApproval(v));
      toggle(L('Players may jump to their friends'), room.allowsWarp, (v) => s.setAllowsWarp(v));
    }
  }

  private renderRequests(): void {
    const s = this.session;
    const key = s.joinRequests.map((r) => r.id).join(',');
    if (key === this.keys.requests) return;
    this.keys.requests = key;
    this.requests.innerHTML = '';
    for (const r of s.joinRequests) {
      const card = el('div', 'ab-card ab-glass ab-request', this.requests);
      el('div', 'who', card, L('{} wants to join', r.name));
      const row = el('div', 'row', card);
      const yes = el('button', 'ab-block green', row, L('Let in'));
      yes.onclick = () => s.answerJoinRequest(r, true);
      const no = el('button', 'ab-block secondary', row, L('Not this time'));
      no.onclick = () => s.answerJoinRequest(r, false);
    }
  }

  private renderPoll(): void {
    const s = this.session;
    const poll = s.roomState.poll;
    const left = s.pollEndsAt === null ? null : Math.max(0, Math.ceil((s.pollEndsAt - Date.now()) / 1000));
    const mine = poll?.votes.get(s.localPeerID);
    const key = poll ? [poll.id, poll.isClosed, pollTally(poll).join(','), mine, left].join('|') : '';
    if (key === this.keys.poll) return;
    this.keys.poll = key;
    this.pollCard.classList.toggle('ab-hidden', !poll);
    if (!poll) return;
    const c = this.pollCard;
    c.innerHTML = '';
    el('h3', '', c, poll.isClosed ? L('The vote is over') : left !== null ? L('Vote · {}s', left) : L('Vote'));
    el('div', 'question', c, poll.question);
    const tally = pollTally(poll);
    const total = Math.max(1, tally.reduce((a, b) => a + b, 0));
    poll.options.forEach((option, i) => {
      const b = el('button', 'option' + (mine === i ? ' mine' : ''), c);
      const fill = el('span', 'fill', b);
      fill.style.width = `${(tally[i] / total) * 100}%`;
      el('span', 'text', b, option);
      el('span', 'n', b, String(tally[i]));
      b.disabled = poll.isClosed;
      b.onclick = () => s.vote(i);
    });
    if (s.role === 'hosting') {
      const row = el('div', 'row', c);
      if (!poll.isClosed) { const end = el('button', 'ab-block secondary', row, L('End the vote')); end.onclick = () => s.endPoll(); }
      const clear = el('button', 'ab-block secondary', row, L('Close'));
      clear.onclick = () => s.clearPoll();
    }
  }

  dispose(): void {
    this.unsubscribe();
    if (this.pollTimer) clearInterval(this.pollTimer);
    for (const e of [this.pill, this.card, this.requests, this.pollCard, this.banner, this.cover, this.errorCard]) e.remove();
  }
}
