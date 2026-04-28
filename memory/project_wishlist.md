---
name: The Legend of Bobby — feature wish list
description: Prioritized list of improvements the user wants to make to the game
type: project
---

Wish list. Always check token budget with `python3 count_tokens.py` before implementing anything.
Budget: 588 tokens remaining as of session start (7604/8192 used).

## Must-haves (game cannot ship without these)
- **Title screen**: `state_menu` already defined but unused. Draw title + "press ❎ to start", then transition to `state_opening`. Can reuse `animate_open_close` infrastructure. ~20 tokens.
- **Win condition**: no win state exists. Options: collect all key items, open a final chest, reach a specific map tile. Needs a `state_win` and a short end screen. ~25–35 tokens.
- **Map content**: fill the world with actual rooms, paths, story, danger. Free in tiles; costs tokens per treasure entry (~8–12 each) and per door pair (~10 each).
- **Story text**: messages in chests and events. Strings are 1 token each; table structure adds up.

## Bug fixes (user-reported)
- **Diagonal slide**: when diagonal move is blocked, retry horizontal-only then vertical-only instead of full stop. ~15–25 tokens.
- **Tree hitbox**: tree trunk is narrow but collision uses full 8×8 tile. Need per-sprite hitbox override for tree sprites on horizontal axis. ~10–20 tokens.

## Gameplay improvements (user-requested)
- **Monster cap**: guard `spawn_monster_if_needed` with `count(monsters) < N`. ~5–8 tokens.
- **Monster memory**: monsters cleared on screen exit. Persist monster list per cavern/room, restore on re-entry. ~35–55 tokens.
- **Monster behavior**: near-random now. Light improvement: patrol bias or wall-hugging. Real A* pathfinding too expensive (~200+ tokens). ~20–40 tokens for light improvement.
- **Dynamic shadows**: `draw_light()` is a flat radius. User wants wall-occlusion shadows from the lantern. Raycasting: ~80–120 tokens.
- **Sword**: melee weapon. Swing animation (directional), hit detection on monsters in range. ~50–70 tokens.

## Audio (nearly free in tokens — content made in PICO-8 editors)
SFX/music data costs 0 Lua tokens. Each `sfx()` or `music()` call costs ~2–3 tokens.
Currently used: sfx(0)=teleport, sfx(1)=bomb, sfx(2)=chest, sfx(3)=select/gameover.
60 SFX slots and all 64 music pattern slots are free.

- **Background music**: one `music(0)` call at game start, loops automatically. ~3 tokens.
- **Title screen music**: separate music pattern, switch to gameplay track on start. ~3 tokens.
- **Win fanfare**: triggered in win state. ~2 tokens.
- **Footsteps**: soft tick per terrain type (water splash, stone). ~5–10 tokens total.
- **Sword swing SFX**: on sword use. ~2 tokens.
- **Door / dungeon enter SFX**: ~2 tokens.
- **NPC dialogue jingle**: small sound when text box appears. ~2 tokens.
Audio content itself is composed in PICO-8's SFX/music editors — no code work.

## Ideas to consider (suggested)
- **NPCs / hint characters**: villagers that give text hints on interaction — same mechanism as treasure messages, very cheap. ~5–10 tokens each.
- **Boss enemy**: a single large/tough monster guarding a key area. Could gate the win condition. Reuses existing monster system with higher HP and different sprite. ~30–50 tokens.
- **Pause menu**: `btn` check for pause, freeze update loop, show "paused" overlay. ~15 tokens.
- **More SFX triggers**: walking on water/sand/stone, NPC interaction, win jingle. 0 tokens if SFX slots already exist in the sound editor — just add `sfx()` calls.
- **Animated title / logo**: draw Bobby sprite on the title screen walking around. Cheap if reusing existing sprite draw code. ~10 tokens.

## Token budget triage (rough)
Available: 588 tokens

| Feature | Est. tokens | Priority |
|---|---|---|
| Title screen | ~20 | Must |
| Win condition | ~30 | Must |
| Monster cap | ~8 | Easy win |
| Diagonal slide fix | ~20 | Easy win |
| Tree hitbox fix | ~15 | Easy win |
| Map story content (per room) | ~15–20 | Must, repeated |
| Monster memory | ~45 | Nice |
| Sword | ~60 | Nice |
| Boss | ~45 | Nice |
| NPC hints | ~8 each | Nice |
| Dynamic shadows | ~100 | Expensive |
| Monster pathfinding | ~70 | Expensive |
| Pause | ~15 | Nice |

## Sprite constraint (CRITICAL)
- Effective limit: 128 sprites (0–127). Sprites 128–255 share memory with map rows 32–63; full 64-row map makes those unusable.
- Highest used index: sprite 126 (monster.side). Only sprite 127 may be free.
- Sword swing animation: NOT feasible without free sprite slots. Sword as hitbox-only effect (flash/screen shake) can work with 0 new sprites.
- NPCs with character art: NOT feasible. NPCs as invisible map triggers with text only: free.
- Boss: NOT feasible unless it reuses monster sprites.
- Must check PICO-8 sprite editor for any gaps between 0–127 that may be free.

## Realistic scope
588 tokens + ~1 free sprite slot:
All must-haves + all easy wins + monster memory + audio wiring + NPC text triggers (no art) + sword as hitbox-only effect.
Dynamic shadows and pathfinding are likely to be cut.
