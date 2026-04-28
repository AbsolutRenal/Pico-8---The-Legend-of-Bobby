---
name: Pixel-perfect hitbox investigation
description: TODO #15 — improve hit detection from square AABB to pixel-accurate using sget()
type: project
originSessionId: 2a1e81d4-f649-4c11-a7d4-c41c591f168a
---
Monster→Bobby damage currently uses `distance_from_centers < 6` (circular, not square). The visible sprites are rounded, so square bounding box corners cause phantom hits. Two approaches were analyzed:

**Why:** Sprites are visually round but hitboxes are 8×8 squares, causing hits that don't match what the player sees on screen.

**How to apply:** When resuming this task, the plan is:
1. First try tuning the radius (6 → 4 or 5) since the math is already circular — quick win.
2. If that's not enough, implement pixel-perfect collision via `sget()`:
   - `sget(x, y)` reads a pixel from the sprite sheet directly
   - Sprite `n` is at `(n%16*8, flr(n/16)*8)` on the sheet
   - Algorithm: AABB fast-reject first, then scan overlap region pixel by pixel
   - Handle `flip_x` by mirroring the dx offset (`7 - adx`)
   - Transparent color = **14 (pink)**
   - Performance: ~64 sget calls per monster worst case, early-exits on first hit — fine at 5 monsters
   - Token cost: ~30 tokens of new code
   - Need to thread current sprite index per entity: monsters use `sprite_for_monster()`, Bobby uses `current_spr`
