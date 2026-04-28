---
name: Sprite rotation optimization — ready to implement
description: Implementation plan to free 18 sprite slots by replacing rotated terrain sprites with flip-based rendering
type: project
---

**Status: Code IMPLEMENTED (Step 2 done). User still needs to clear sprite slots in PICO-8 editor (Step 1).**

## What to do (two steps)

**Step 1 — User does in PICO-8 sprite editor:**
Clear pixel data in sprite slots 97–99, 101–103, 105–107, 113–115, 117–119, 121–123.
Leave map data untouched — those indices still used in the map.

**Step 2 — Code to add to bobby.p8:**
Cost: 121 tokens. Frees 18 sprite slots. Remaining after: 467 tokens.

```lua
rot_bases={96,100,104,112,116,120}

function get_rot_spr(s)
 for b in all(rot_bases) do
  if s>b and s<b+4 then
   local r=s-b
   return b,r==1 or r==2,r==2 or r==3
  end
 end
end

function draw_rot_tiles()
 local cx=flr(map_x/-8)
 local cy=flr(map_y/-8)
 for j=cy,cy+16 do
  for i=cx,cx+16 do
   local s=mget(i,j)
   local b,fx,fy=get_rot_spr(s)
   if b then
    spr(b,i*8+map_x,j*8+map_y,1,1,fx,fy)
   end
  end
 end
end
```

Add `draw_rot_tiles()` call inside `draw_map()`, after the `map(...)` call.

## Rotation → flip mapping
- base+1 (90° CCW) → flip_x=true,  flip_y=false
- base+2 (180°)    → flip_x=true,  flip_y=true
- base+3 (270° CCW)→ flip_x=false, flip_y=true

## Groups confirmed by user
| Base | Freed slots |
|---|---|
| 96  | 97, 98, 99  |
| 100 | 101, 102, 103 |
| 104 | 105, 106, 107 |
| 112 | 113, 114, 115 |
| 116 | 117, 118, 119 |
| 120 | 121, 122, 123 |

User confirmed flip is visually acceptable for these sprites.
