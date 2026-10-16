// Test worlds for looking at every part of the play screen while building
// the web version (#lab/1, #lab/2; development only). Each one is a floor,
// a few blocks and a script that switches the parts on.
import { colorFromHex } from '../core/model/color';
import { v3 } from '../core/model/math';
import { emptyWorld, makeBlock, placed, type WorldDocument } from '../core/model/world';

const hex = (h: string) => colorFromHex(h)!;

function floorWorld(name: string): WorldDocument {
  const world = emptyWorld(name, 'Ablox web');
  world.id = '7E57AB10-0000-4000-8000-00000000000' + (name.length % 10);
  world.blocks = [
    makeBlock({ name: 'Floor', transform: placed(v3(0, -0.5, 0), v3(60, 1, 60)), color: hex('#4ADE80'), material: 'matte', tags: ['ground'] }),
    makeBlock({ name: 'Spawn', shape: 'cylinder', transform: placed(v3(0, 0.1, 0), v3(2, 0.2, 2)), color: hex('#22D3EE'), material: 'neon', behavior: 'spawn' }),
    makeBlock({ name: 'Goal', transform: placed(v3(18, 1, -24), v3(3, 2, 3)), color: hex('#A855F7'), material: 'glass' }),
    makeBlock({ name: 'Wall', transform: placed(v3(-6, 1.5, -10), v3(8, 3, 1)), color: hex('#F59E0B') }),
    makeBlock({ name: 'Coin', shape: 'sphere', transform: placed(v3(3, 1, -4), v3(0.8, 0.8, 0.8)), color: hex('#FFD54F'), material: 'neon', behavior: 'collectible', scoreValue: 10 }),
  ];
  return world;
}

export function labWorld(n: string): WorldDocument {
  if (n === '2') {
    const world = floorWorld('Lab: shop and talk');
    world.scripts = [{ id: 'A0000000-0000-4000-8000-000000000002', name: 'main.absc', isEnabled: true, source: `
on join(p)
  p.coins = 120
  p.dialog("Mika", "Welcome to the shop! Would you like to look?", ["Yes please", "Not now"])
  ui_text("hello", "Shop test", {at: "top", size: 22, bold: true})
end

on choice(p, answer, n)
  if n == 1 then
    p.shop("Mika's shop", [{name: "Sword", price: 50, icon: "⚔️"}, {name: "Cake", price: 0, icon: "🎂"}, {name: "Crown", price: 500, icon: "👑"}])
  end
end

on buy(p, item, price)
  announce("Bought " + item, 2)
end
` }];
    return world;
  }
  const world = floorWorld('Lab: shooter');
  world.scripts = [{ id: 'A0000000-0000-4000-8000-000000000001', name: 'main.absc', isEnabled: true, source: `
on join(p)
  p.give("rifle")
  p.give_item("Apple", 3, "🍎")
  p.give_item("Key", 1, "🔑")
  p.countdown(90, "Round")
  leaderboard("Best", p, 120)
  p.show_leaderboard("Best")
  p.waypoint(block("Goal"), "Goal")
  ui_bar("power", 70, 100, {at: "bottom_left", w: 180})
  ui_button("hi", "Say hi", {at: "left"})
  for i in 1 to 3 do
    create_npc({name: "Target " + i, position: {x: i * 4 - 8, y: 0.2, z: -12}, color: "#EF4444", health: 60})
  end
end

on button(p, id)
  if id == "hi" then chat("Hi " + p.name + "!") end
end

on hit(p, victim, damage)
  p.message("Hit " + victim.name, 1)
end
` }];
  return world;
}
