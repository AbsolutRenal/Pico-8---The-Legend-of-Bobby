---
name: Master todo list — ordered work plan
description: Full ordered plan combining optimisations and features, ordered by impact/cost. Update status as work progresses.
type: project
---

Optimisations come first to recover budget before spending it on features.
Token budget at start: 588 remaining (7604/8192 used).
After Phase 1 complete: 681 remaining (7511/8192 used). Saved 93 tokens.
After Phase 2 complete: 564 remaining (7628/8192 used). Spent 117 tokens, freed 18 sprite slots.
After Phase 3 complete: 711 remaining (7481/8192 used). Recovered 147 tokens.
All optimisation phases done.

Legend: [ ] pending  [x] done  [~] in progress

---

## Phase 1 — Code optimisations (recover ~86 tokens, zero risk)
Do these first. Each is self-contained and safe to apply independently.

- [x] **1. Remove `ceil` function** — saves 10 tokens. PICO-8 has built-in `ceil()`. Deleted.
- [x] **2. Remove duplicate table entries** — saves 11 tokens.
  - `kind.monster_spawn` (= `kind.danger`): removed, uses replaced
  - `delays.treasure_opening` (= `delays.message`): removed, uses replaced
  - `damage.sink` (= `damage.monster`): removed, uses replaced
- [x] **3. Floor division operator `\`** — saved ~19 tokens (8 uses replaced). Replaced all simple `flr(x/n)` with `x\n`.
- [x] **4. `is_on_map` return pattern** — saves 10 tokens. Replaced with `return cond`.
- [x] **5. `delay` nil check** — saves 2 tokens. `if completion != nil then` → `if completion then`.
- [x] **6. `get_bobby_mid` hardcode constants** — saves 24 tokens. Replaced hitbox lookups with known constants.
- [x] **7. `update_map_position` mutate table** — saves 15 tokens. Now mutates x/y fields only.

## Phase 2 — Sprite optimisation (recover 18 sprite slots, costs 117 tokens)
After Phase 2 code added: 564 remaining (7628/8192 used).

- [x] **8. User: clear sprite slots in PICO-8 editor** — clear pixel data for sprites 97–99, 101–103, 105–107, 113–115, 117–119, 121–123. Leave map data untouched.
- [x] **9. Add `get_rot_spr` + `draw_rot_tiles`** — 117 tokens (saved 4 via \ operator). rot_bases global + two functions added before draw_map. draw_rot_tiles() called after map() in draw_map().

## Phase 3 — `kind` bitmask refactor (recovered 147 tokens)
After Phase 3 complete: 711 remaining (7481/8192 used).

- [x] **10. Precompute `kind` bitmasks + simplify `is_kind_of`** — saved 147 tokens (vs ~30 estimated). kind table → bitmasks, is_kind_of → 1 line, is_on_terrain_type + collide_with → no type-dispatch, has_traits + has_trait_type + is_none_of_type deleted, can_move_to unrolled.

---

## Phase 4 — Must-have features (game cannot ship without these)

- [ ] **11. Title screen** — ~20 tokens. Use `state_menu` (already defined, unused). Draw title text + "press ❎ to start". Wire title music once SFX is composed.
- [ ] **12. Win condition** — ~30 tokens. Define trigger (collect all key items? reach final room?). Add `state_win` + end screen. Decide trigger with user before implementing.

---

## Phase 5 — Bug fixes (high impact, low cost)

- [ ] **13. Monster cap** — ~8 tokens. Add `count(monsters) < MAX` guard in `spawn_monster_if_needed`.
- [x] **14. Diagonal slide** — ~55 tokens. When diagonal move blocked, retry horizontal-only then vertical-only in `config_bobby`.
- [ ] **15. Tree hitbox** — ~15 tokens. Skip solid collision for tree sprites on the horizontal axis (trunk is narrow, full tile box is too wide).

---

## Phase 6 — Audio (nearly free, content made in PICO-8 editors)
SFX/music data = 0 tokens. Only the `sfx()`/`music()` call sites cost tokens (~2–3 each).

- [ ] **16. Wire background music** — ~3 tokens. `music(0)` call at game start.
- [ ] **17. Wire title screen music** — ~3 tokens. Separate pattern, switch on game start.
- [ ] **18. Wire win fanfare** — ~2 tokens. `music(n)` in win state.
- [ ] **19. Wire additional SFX** — ~10 tokens total. Door open, NPC dialogue, sword swing (when implemented).
*User composes sounds in PICO-8 SFX/music editors independently.*

---

## Phase 7 — Gameplay additions

- [ ] **20. Monster memory per room** — ~45 tokens. Persist monster list keyed by room/area. Restore on re-entry instead of fresh spawns.
- [ ] **21. Sword item** — ~60 tokens. Needs 1–2 free sprite slots (available after phase 2). Swing animation, directional hitbox, monster damage.
- [ ] **22. NPC text triggers** — ~8 tokens each. Invisible map trigger zones that show a text message. No sprite needed. Add entries to a new `npcs` table.

---

## Phase 8 — Map content (ongoing, mostly user work in editor)
Code cost: ~10–15 tokens per new treasure entry, ~10 per new door pair.

- [ ] **23. Design map areas** — user work in PICO-8 map editor.
- [ ] **24. Add treasure/story entries** — code: extend `treasures` table with new entries and messages.
- [ ] **25. Add new door pairs** — code: extend `doors` table for new indoor areas.

---

## Phase 9 — Stretch goals (implement only if budget allows)

- [ ] **26. Boss enemy** — ~45 tokens. Tougher monster guarding final area, gates win condition. Reuses monster system.
- [ ] **27. Pause screen** — ~15 tokens. Freeze update loop, show overlay on button press.
- [ ] **28. Dynamic wall shadows** — ~100 tokens. Raycast from lantern, occlude behind walls. Expensive — cut if budget is tight.
- [ ] **29. Monster pathfinding improvement** — ~70 tokens. Light improvement over random movement. Cut if budget is tight.
