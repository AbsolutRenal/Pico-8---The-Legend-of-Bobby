---
name: The Legend of Bobby — current game state
description: What mechanics are implemented vs what's missing/unfinished in the PICO-8 game
type: project
---

Single-file PICO-8 cartridge: bobby.p8 (~1546 lines of Lua + binary asset sections).
User developed this years ago and wants to finish it.

**Why:** They want to complete the game for release on the PICO-8 BBS.

**How to apply:** When making changes, be mindful of the 8192 token limit. Prefer compact code. Check PICO-8 API constraints (no standard Lua libs, fixed-point numbers, etc.)

## What IS implemented
- Full player movement: walk, run (boots), swim (flippers), diagonal
- Terrain system via sprite flags (solid, water, deep_water, door, hole, treasure, destroyable, static, extended)
- Outdoor world scrolling (map_x/map_y offsets, 112×64 tiles)
- Indoor dungeon rooms (map_x < -map_x_tiles*8 threshold)
- 7 bidirectional doors between outdoor↔indoor
- Teleport pads (cycle through teleports list)
- 17 treasures: empty chest, key, candle, big_candle, boots, bomb, flipper, 2×heart_increment, 4×heart_full, 2×heart_increment, 1×heart_full, GPS
- Monster system: random movement + player-tracking AI, spawn points, bomb kill
- Bomb mechanic (destroys breakable walls/floors, kills monsters, hurts player)
- Breakable floors (3-step countdown, restore when off-screen)
- Candle lighting in dark indoor rooms
- GPS map view (overhead pixel map of explored areas)
- HUD: heart display, item slots, key count
- Coroutine-based animations (teleport stretch, door wipe, death)
- Game states: state_opening (wipe-in animation), state_game, state_gps, state_dead, state_loose

## What is MISSING / unfinished
- **No win condition** — nothing checks if player has beaten the game
- **No title/menu screen** — state_menu=0 is defined but never reached; _init() jumps straight to state_opening
- Possibly incomplete map areas or story content
- No save/persist (CARTDATA not used)
