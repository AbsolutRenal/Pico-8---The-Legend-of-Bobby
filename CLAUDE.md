# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this project is

A PICO-8 game cartridge — a Zelda-like adventure game written in Lua for the PICO-8 fantasy console. The entire game lives in a single file: [bobby.p8](bobby.p8).

## Running and editing

There are no build steps. Open the cartridge in PICO-8:

```
# From PICO-8's command line:
load bobby.p8
run
```

Edit code directly in `bobby.p8` or via PICO-8's built-in code editor. The `.p8` format has sections separated by headers: `__lua__` (game code), `__gfx__` (sprites), `__gff__` (sprite flags), `__map__` (tile map), `__sfx__` (sound), `__music__`. Only edit within `__lua__` unless you know what you're doing with the binary sections.

## Architecture

### Entry points
PICO-8 calls three functions automatically:
- `_init()` — called once at startup; calls `new_game()`
- `_update()` — called every frame; dispatches to the active game state handler
- `_draw()` — called every frame after update; dispatches to the active draw function

### Game states (`game_state` table)
| State | Meaning |
|---|---|
| `state_menu` | unused |
| `state_opening` | animated wipe-in on game start |
| `state_game` | main gameplay |
| `state_gps` | overhead map view (GPS item) |
| `state_dead` | bobby death animation |
| `state_loose` | game-over screen |

### World layout
- The outdoor map is `112×64` tiles; indoor areas are tiled at `map_x < -map_x_tiles * 8`.
- `map_x` / `map_y` are pixel offsets that scroll the world; bobby's `screen_position` stays near the center while the map moves.
- `is_indoor()` compares `map_x` against the threshold to distinguish outdoor vs dungeon rooms.
- Doors connect locations via the `doors` table (pairs of `{inn, out}` tile coords); teleport pads cycle via the `teleports` list.

### Sprite flags (terrain classification)
Flags are set on sprites in PICO-8's sprite editor and checked at runtime with `fget`. The `flag` table names them:

| bit | name | meaning |
|---|---|---|
| 0 | solid | blocks movement |
| 1 | water | shallow water |
| 2 | door | door/teleport tile |
| 3 | hole | fall hazard |
| 4 | treasure | treasure chest |
| 5 | destroyable | can be bombed |
| 6 | static | drawn in front of bobby |
| 7 | extended | combined with other flags for compound types |

`kind` table defines compound terrain types as flag bitmask combinations (e.g. `kind.deep_water = {1,7}`). Use `is_kind_of(sprite, kind.X)` to test for exact flag sets, and `has_trait_type(sprite, flag.X)` to test for a single flag.

### Coroutine-based timing
Cutscenes and multi-frame delays use PICO-8 coroutines:
- `delay_co = cocreate(some_function)` — holds a coroutine for the current frame's animation
- While `delay_co` is active, `_update()` resumes it each frame and skips normal game logic
- `delay(n)` yields for `n` frames; animation functions (teleport, treasure open, death) use this pattern

### Key global state
- `bobby` — player table: `screen_position`, `map_position`, `hitbox`, `speed`, `injured`, `dive`, `swimming`, `flip_x`
- `monsters` — list of active monster tables; spawned from `spawns` points detected at map load
- `items` — collected inventory; `selected_item` is the 1-based index of the active item
- `life` / `hearts` — HP is `hearts * 3`; `heart_value = 3`
- `tick` — frame counter (mod 3000), drives animations

### Collision
`collision_cells()` returns the 1–2 map tiles the player's hitbox will occupy after the next move. `collide_with(cells, flags)` tests those tiles against a flag or kind. `should_move()` evaluates swimming vs walking rules and returns whether the move is allowed.
