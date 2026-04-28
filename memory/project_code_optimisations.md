---
name: Code optimisations — ready to implement
description: Token-saving code changes identified by analysis, with exact measurements. Not yet implemented.
type: project
---

**Status: Phase 1 COMPLETE. Phase 3 (kind bitmasks) pending.**
All token counts measured with count_tokens.py against the real codebase.
Starting budget: 588 tokens remaining (7604/8192 used).
After Phase 1: 681 remaining (7511/8192 used). Saved 93 tokens.
Estimated recovery remaining: ~30 tokens (Phase 3) → ~711+ remaining after Phase 3.
Combined with sprite rotation opt (Phase 2, costs 121 tokens): projected ~825 remaining total.

---

## 1. Free lunch — remove redundant code

### Remove `ceil` function (~10 tokens)
PICO-8 has `ceil()` as a built-in. The reimplementation at line 989 is unnecessary.
**Action:** delete the function body. The built-in takes over automatically.

### Remove `kind.monster_spawn` (~5 tokens)
`kind.monster_spawn = {6,7}` is identical to `kind.danger = {6,7}`.
**Action:** replace all uses of `kind.monster_spawn` with `kind.danger`, delete the entry.

### Remove `delays.treasure_opening` (~3 tokens)
Same value (45) as `delays.message`.
**Action:** replace all uses of `delays.treasure_opening` with `delays.message`, delete the entry.

### Remove `damage.sink` (~3 tokens)
Same value (1) as `damage.monster`.
**Action:** replace all uses of `damage.sink` with `damage.monster`, delete the entry.

---

## 2. PICO-8 floor division operator `\`

`flr(a/b)` is identical to `a\b`. Saves 2 tokens per use.
7 confirmed simple uses in the code (+ more complex ones in collision_cells).
**Total saving: ~14+ tokens.**

Examples:
```lua
-- before
cell_x = flr(map_x / -8)
cell_y = flr(map_y / -8)
-- after
cell_x = map_x\-8
cell_y = map_y\-8
```

Search for all `flr(` occurrences with a `/n)` pattern and replace.

---

## 3. Code pattern improvements

### `get_bobby_mid` (53 → 29 tokens, saves 24)
Hitbox is a constant `{x=2, y=6, width=4, height=1}` — hardcode it:
```lua
function get_bobby_mid()
 return {x=(bobby.map_position.x+4)\8,y=(bobby.map_position.y+6.5)\8}
end
```
Note: uses `+6.5` (not `+6`) to match `hitbox.y + hitbox.height*0.5 = 6.5` exactly.

### `update_map_position` (36 → 21 tokens, saves 15)
Hitbox sub-table never changes — mutate x/y only instead of recreating the whole table:
```lua
function update_map_position()
 bobby.map_position.x=bobby.screen_position.x-map_x
 bobby.map_position.y=bobby.screen_position.y-map_y
end
```
Requires `bobby.map_position` to be initialised with hitbox in `init_game` (already the case).

### `is_on_map` (48 → 38 tokens, saves 10)
Replace `if cond then return true else return false end` anti-pattern:
```lua
function is_on_map(x,y,t)
 return x>=-map_x-t and x<=-map_x+128+t and y>=-map_y-t and y<=-map_y+128+t
end
```
Also renames params to single letters (no token saving, but shorter).

### `delay` completion nil check (saves 2 tokens)
```lua
-- before
if completion != nil then
-- after
if completion then
```
nil is falsy in Lua — the check is equivalent.

---

## 4. Bigger refactor — precompute `kind` bitmasks (~30 tokens)

Replace table-of-flags with precomputed bitmasks. `is_kind_of` becomes a single comparison.

```lua
-- kind bitmask values (shl(1,flag) for each flag index)
kind = {
 hole=8,           -- {3}       → 2^3
 breakable_floor=136, -- {3,7}  → 2^3+2^7
 door=4,           -- {2}       → 2^2
 teleport=132,     -- {2,7}     → 2^2+2^7
 treasure=17,      -- {0,4}     → 2^0+2^4
 closed_treasure=145, -- {0,4,7}→ 2^0+2^4+2^7
 water=2,          -- {1}       → 2^1
 deep_water=130,   -- {1,7}     → 2^1+2^7
 behind=64,        -- {6}       → 2^6
 danger=192,       -- {6,7}     → 2^6+2^7
 bridge=202        -- {1,3,6,7} → 2^1+2^3+2^6+2^7
}

-- is_kind_of shrinks from 26 to 11 tokens
function is_kind_of(s,k) return fget(s)==k end
```

**IMPORTANT:** `is_on_terrain_type` currently routes to `is_kind_of` or `has_trait_type` based on
`type(t)=="table"`. With `kind` values now numbers, this routing breaks.
Needs updating — callers using `kind.X` need exact-bitmask path, callers using `flag.X` need single-bit path.
Simplest fix: split into two call patterns and remove the type-dispatch entirely.
This is the most involved change — do last, after all others are applied and tested.

---

## Summary table

| Optimisation | Tokens saved |
|---|---|
| Remove `ceil` | 10 |
| Remove duplicate kind/damage/delays entries | 11 |
| Floor division `\` (7+ uses) | 14+ |
| `get_bobby_mid` | 24 |
| `update_map_position` | 15 |
| `is_on_map` pattern | 10 |
| `delay` nil check | 2 |
| `kind` bitmasks + `is_kind_of` | ~30 |
| **Total** | **~116** |
