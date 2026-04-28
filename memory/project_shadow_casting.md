---
name: Shadow casting — branch analysis & implementation plan
description: Analysis of raycast-shadows and improve-performance-2 branches; recommended approach for low-cost, good-performance indoor shadows
type: project
---

## What was tried

### `origin/feature/raycast-shadows`

Implements `cast_shadows()` — a pixel-level raycast from Bobby's center outward.

**How it works:**
- Gets Bobby's pixel-center `p = get_bobby_mid_px()`
- `shadow_decay = floor(light_decay / 3)` — adds a soft penumbra radius
- Outer loop: 100 angles from 0→1 in steps of 0.01
- Inner loop: radius steps 0 to `light_decay + shadow_decay` (pixels)
  - `light_decay = 10` (candle) or `20` (big candle/lamp)
  - Total per frame: **100 × 13 = ~1300 iterations** at candle level
- Per iteration: reads tile with `mget()`, checks solid flag, reads sprite sheet pixel with `sget()`, paints result with `pset()`
- If `r > light_decay`: applies shadow palette mapping → penumbra effect
- If pixel color is pink (14): substitutes brown (4)
- If tile is solid: ray breaks early → that's the LoS occlusion

**Visually:** produces a textured light cone that shows real floor colors through `sget()`, with genuine shadow occlusion behind walls. Looks good.

**Why performance was bad:**

| Problem | Cost | Fix |
|---|---|---|
| `cos(a)` + `sin(a)` called **inside** inner loop | 2600 trig calls/frame | hoist above inner loop |
| `sget()` per pixel step | 1300 sprite-sheet reads/frame | see options below |
| `pset()` per pixel step | 1300 pixel writes/frame | unavoidable if painting |
| `mget()` + `fget()` per step | 2600 map/flag reads/frame | unavoidable |

The single biggest bug is trig in the inner loop. `cos(a)` and `sin(a)` are constant for a given angle — they're recomputed 13× per angle instead of once.

---

### `origin/tech/improve-performance-2`

Single change: caches `mget(bobby.bobby_mid.x, bobby.bobby_mid.y)` into `bobby.current_cell` once per frame update, so `is_on_terrain_type()` doesn't call `mget()` every time it's invoked.

**Status:** Clean, small, ready to apply to master. ~1 token cost. Not related to shadows.

---

## Recommended implementation plan

### Step 0 — cherry-pick the mget cache (free win)

Apply `improve-performance-2` diff first regardless of shadow approach.

### Step 1 — fix the sin/cos bug (minimal tokens, ~3× speedup on trig)

Hoist direction vectors out of the inner loop:

```lua
function cast_shadows()
 reset_palette()
 local p = get_bobby_mid_px()
 shadow_decay = flr(light_decay / 3)
 local max_r = light_decay + shadow_decay
 for a=0,1,0.01 do
  local dx = cos(a)       -- computed ONCE per angle
  local dy = sin(a)
  local x = p.x
  local y = p.y
  for r=1,max_r do
   x += dx               -- incremental — no trig in inner loop
   y += dy
   local fx = flr(x)
   local fy = flr(y)
   local cell = mget(flr(fx/8), flr(fy/8))
   if has_trait_type(cell, flag.solid) then break end
   local col = sget(flr(cell%16)*8 + fx%8, flr(cell/16)*8 + fy%8)
   if r > light_decay then col = palette.shadow[col+1]
   elseif col == 14 then col = 4 end
   pset(fx + map_x, fy + map_y, col)
  end
 end
end
```

Token cost delta: near zero (removes a few redundant ops). Speedup: 10× on trig alone.

### Step 2 — reduce angle resolution

Increase step from `0.01` to `0.02` (50 rays instead of 100). At a 10px radius the arc between adjacent rays is `2π × 10 × 0.01 ≈ 0.6px` — well below pixel resolution, so 0.02 still gives solid coverage with no visible gaps. Cuts all inner-loop ops in half.

### Step 3 (optional, bigger win) — drop `sget()` texturing

If performance is still tight, skip reading sprite-sheet colors and instead just `pset` with a fixed warm color for the lit zone. This removes 1300 `sget()` calls at the cost of a flat (non-textured) light circle. Use the existing shadow palette on the penumbra.

Alternatively: keep the existing `draw_light()` approach for the lit zone (redraws real tiles) and combine with the raycast only for occlusion marking — but this requires two passes.

### Step 4 — token budget check

Before merging: run `count_tokens.py`. The raycast branch is already at an unknown but possibly high token count. Master is at ~7481. Budget is 8192. The shadow code in the branch is ~35 lines / ~80–100 tokens. Should be viable.

---

## If Step 1+2 is still too slow: tile-level LoS fallback

If pixel-level raycast is unacceptable even after optimization, fall back to tile-level shadows:

1. Dim entire screen with `dimm_screen(palette.shadow)` as before
2. For each tile within `light_decay` tile-radius of Bobby, check LoS with a fast Bresenham walk:

```lua
function has_los(ax,ay,bx,by)
 local dx=abs(bx-ax) local dy=abs(by-ay)
 local sx=bx>ax and 1 or -1 local sy=by>ay and 1 or -1
 local err=dx-dy
 while ax!=bx or ay!=by do
  local e2=2*err
  if e2>-dy then err-=dy ax+=sx end
  if e2<dx then err+=dx ay+=sy end
  if fget(mget(ax,ay),flag.solid) then return false end
 end
 return true
end
```

3. Tiles with LoS: redraw normally with `spr()`. Tiles without: leave dimmed.

Cost: ~12 tiles radius → ~450 tiles × ~8 Bresenham steps = 3600 `mget/fget` — no trig, no sget, no pset.
Shadow granularity: tile-sized (8×8px), not pixel-exact. Less smooth but correct occlusion.
Token cost: ~25 tokens for `has_los` + small changes to `draw_light`.

---

## Summary / recommended order

1. Apply `improve-performance-2` mget cache → master
2. Port `cast_shadows()` from raycast branch with sin/cos hoisted + step 0.02
3. Run in-game with debug stats to measure CPU%
4. If CPU% is acceptable → done
5. If still slow → drop `sget()` texturing (Step 3) or switch to tile LoS (fallback)
