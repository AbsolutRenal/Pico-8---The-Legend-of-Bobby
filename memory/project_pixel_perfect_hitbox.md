---
name: Pixel-perfect hitbox investigation
description: TODO #15 — improve hit detection from square AABB to pixel-accurate using sget()
type: project
originSessionId: 2a1e81d4-f649-4c11-a7d4-c41c591f168a
---
**IMPLEMENTED (2026-04-29).** The real issue was terrain feel, not monster damage. Trees (32/33/48/49), rocks (50/55/47/8), and bush (34) have round/irregular sprites but the full 8×8 tile was treated as solid, blocking Bobby on invisible corners.

**Solution chosen:** Shrink Bobby's terrain hitbox from `{x=2, y=6, width=4, height=1}` to `{x=3, y=6, width=2, height=1}` (bobby.p8:209). The collision strip narrows from 4px to 2px (centered on Bobby's feet), giving 1px extra clearance on each side before a tile boundary triggers. Adjacent solid tiles still block normally since both cells are checked.

Pixel-perfect via `sget()` was tried first but caused stuck moves on irregular shapes and let Bobby slip through visual gaps between rocks — too granular for the tile-based system.
