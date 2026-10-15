// A bare page for looking at a world while building the web version.
import { defaultProfile } from './core/model/avatar';
import { loadCatalogue, loadGame } from './net/catalogue';
import { LiveWorld } from './core/model/liveWorld';
import { PlayView } from './play/view';

const params = new URLSearchParams(location.search);
const games = await loadCatalogue();
const id = params.get('game') ?? games[0].id;
const listing = games.find((g) => g.id === id) ?? games[0];
const world = await loadGame(listing);
const live = new LiveWorld(world);
const profile = { ...defaultProfile(), displayName: 'Web', hat: 'crown' as const, pet: 'dog' as const };
const view = new PlayView(document.getElementById('stage')!, live, 'LOCAL', profile, { level: (params.get('q') as 'high') ?? 'high' });
if (params.get('yaw')) view.input.look.yaw = Number(params.get('yaw'));
if (params.get('pitch')) view.input.look.pitch = Number(params.get('pitch'));
if (params.get('zoom')) view.input.look.zoom = Number(params.get('zoom'));
for (const k of ['sun', 'hemi', 'env', 'exposure'] as const) if (params.get(k)) view.scene.lighting[k] = Number(params.get(k));
if (params.get('tone')) view.scene.lighting.toneMapping = params.get('tone') as 'aces';
view.start();
const info = document.getElementById('info')!;
setInterval(() => {
  info.textContent = `${listing.title} · ${world.blocks.length} parts · ${view.scene.blocks.drawCalls} groups · ${view.fps.toFixed(0)} fps`;
}, 500);
(window as unknown as { view: PlayView }).view = view;
