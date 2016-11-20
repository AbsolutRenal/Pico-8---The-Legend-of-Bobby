pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- the legend of bobbby
--  by absolut.renal (2016)

-- controls
controls = {
 up = 2,
 down = 3,
 left = 0,
 right = 1,
 btn_1 = 5,
 btn_2 = 4
}

-- game states
game_state = {
	state_menu = 0,
	state_opening = 1,
	state_game = 2,
	state_gps = 3,
	state_dead = 4,
	state_loose = 5
}

-- sprites
sprites = {
 front = 0,
 back = 2,
 side = 4,
 dive = 6,
 standing = 16,
 open_treasure = 17,
 swim_front = 18,
 swim_back = 20,
 swim_side = 22,
 water_walk = 12,
 water_standing = 44,
 dead = 63,
 water = 36,
 deep_water = 52,
 water2 = 37,
 deep_water2 = 53,
 sand = 51,
 small_tree = 34,
 rock1 = 50,
 rock2 = 55,
 rock2_broken = 56,
 rock3 = 47,
 rock4 = 8,
 rock4_broken = 9,
 tree1 = 32,
 tree2 = 33,
 tree3 = 48,
 tree4 = 49,
 treasure1 = 10,
 treasure2 = 11,
 treasure3 = 24,
 treasure4 = 25,
 treasure5 = 26,
 treasure6 = 27,
 treasure = 14,
 treasure7 = 28,
 treasure8 = 90,
 teleport1 = 64,
 teleport2 = 65,
 mud = 68,
 wall = 69,
 door = 70,
 stairs = 71,
 heart_full = 39,
 heart_empty = 42,
 big_treasure_opened1 = 14,
 big_treasure_opened2 = 15,
 big_treasure_opened3 = 30,
 big_treasure_opened4 = 31,
 treasure_opened = 25,
 treasure_sand_opened = 29,
 treasure_mud_opened = 91,
 selected_item = 43,
 boots = 38,
 flipper = 54,
 heart_increment = 45,
 gps = 46,
 bomb = 57,
 key = 62,
 candle = 66,
 big_candle = 67
}

-- flags
--- trait type
flag = {
 solid = 0,
 water = 1,
 deep_water = 2,
 behind = 3,
 treasure = 4,
 destroyable = 5,
 need_key = 6,
 teleport = 7
}
--- kind of
kind = {
 door = {4,7},
 teleport = {7},
 treasure = {0,4},
 closed_treasure = {0,4,6}
}


-- game config
alpha_color = 14
bomb_damage = 3
refresh_rate = 2
walking = 2
running = 3
max_diving_delay = 60
screen_offset = 8
map_x_tiles = 112
map_y_tiles = 64
map_max_x = (map_x_tiles-16) * 8 -- nb columns * column width
map_max_y = (map_y_tiles-16) * 8
map_move_offset = 32
heart_value = 3
candle_decay = 1
big_candle_decay = 4
treasures = {{x=1,y=20,sprite=sprites.key},{x=24,y=10,sprite=sprites.candle,descript={x=14,text="hum ... a candle, really ?"}},{x=124,y=1,sprite=sprites.big_candle,descript={x=14,text="hey, a lamp !! :)"}},{x=19,y=18,sprite=sprites.boots,descript={x=34,text="you can now run"}},{x=17,y=7,sprite=sprites.bomb,descript={x=20,text="you can now drop bombs"}},{x=11,y=23,sprite=sprites.flipper,descript={x=32,text="you can now swim"}},{x=11,y=28,sprite=sprites.heart_increment},{x=10,y=60,sprite=sprites.heart_full},{x=108,y=53,sprite=sprites.heart_increment},{x=109,y=53,sprite=sprites.heart_increment},{x=28,y=12,sprite=sprites.heart_full},{x=11,y=10,sprite=sprites.gps,descript={x=13,text="you now have access to map"}}}
doors = {{inn={x=21,y=10,offset_x=0,offset_y=1},out={x=120,y=0,offset_x=0,offset_y=1}}}

palette = {
 no_candle = {0,1,0,0,0,0,0,0,2,4,0,0,0,0,0,4},
 shadow = {0,0,1,0,5,1,5,6,0,0,0,0,1,1,2,15}
}

-- func
function _init()
 new_game()
end

function init_game()
	--poke(0x5f2c,7)
	move_speed = walking
	map_x = 0
	map_y = 0
	tick = 0
	current_spr = sprites.standing
	bobby = {dive=0,injured=0,sx=0,sy=0,hitbox={x=2,y=6,width=4,height=1},flip_x=false,x=96,y=96}
	background_color = 3
	move_count = 0
	btn_1_down = false
	btn_2_down = false
	items = {}
	delay_co= nil
 should_draw = true
 life = 9
 hearts = 3
 current_bomb = nil
 keys = 0
 selected_item = 1
 map_data = {}
 create_gps_map()
 detect_teleports()
end

function create_gps_map()
 for j=0,(map_y_tiles-1) do
  for i=0,(map_x_tiles-1) do
   add(map_data, 0)
  end
 end
end

function detect_teleports()
 teleports = {}
 local s
 for j=0,127 do
  for i=0,127 do
   s = mget(i,j)
   if is_kind_of(s, kind.teleport) then
    add(teleports,{x=i,y=j})
   end
  end
 end
end

function reinit_map_items()
 local s
 local items = {{from=sprites.big_treasure_opened1,to=sprites.treasure1},{from=sprites.big_treasure_opened2,to=sprites.treasure2},{from=sprites.big_treasure_opened3,to=sprites.treasure5},{from=sprites.big_treasure_opened4,to=sprites.treasure6},{from=sprites.treasure_opened,to=sprites.treasure3},{from=sprites.treasure_sand_opened,to=sprites.treasure7},{from=sprites.treasure_mud_opened,to=sprites.treasure8},{from=sprites.rock2_broken,to=sprites.rock2},{from=sprites.rock4_broken,to=sprites.rock4}}
 for j=0,127 do
  for i=0,127 do
   s = mget(i,j)
   for item in all(items) do
    if s == item.from then
     mset(i,j,item.to)
    end
   end
  end
 end
end

function update_gps_data()
 if not is_indoor() then
  min_x = flr(map_x/-8)
  min_y = flr(map_y/-8)
  for j=min_y,min_y +15 do
   for i=min_x,min_x +15 do
    map_data[i+j*map_x_tiles +1] = color_for_sprite(mget(i, j))
   end
  end
 end
end

function is_indoor(x)
 if x != nil then
  return x > map_x_tiles
 else
  return map_x <= -map_x_tiles * 8
 end
end

function color_for_sprite(sprite)
 local col = background_color
 if sprite == sprites.water or sprite == sprites.water2 then
  col = 13
 elseif sprite == sprites.deep_water or sprite == sprites.deep_water2 then
  col = 1
 elseif sprite == sprites.sand then
  col = 10
 elseif sprite == sprites.small_tree or sprite == sprites.tree1 or sprite == sprites.tree2 or sprite == sprites.tree3 or sprite == sprites.tree4 then
  col = 11
 elseif sprite == sprites.rock1 or sprite == sprites.rock2 or sprite == sprites.rock3 or sprite == sprites.rock4 then
  col = 5
 elseif sprite == sprites.treasure1 or sprite == sprites.treasure8 or sprite == sprites.treasure2 or sprite == sprites.treasure3 or sprite == sprites.treasure4 or sprite == sprites.treasure5 or sprite == sprites.treasure6 or sprite == sprites.treasure7 then
  col = 9
 elseif sprite == sprites.teleport1 or sprite == sprites.teleport2 then
  col = 2
 elseif sprite == sprites.mud then
  col = 4
 elseif sprite == sprites.wall then
  col = 5
 elseif sprite == sprites.door or sprite == sprites.stairs then
  col = 2
 end
 return col
end

function _update()
 if delay_co then
  if coresume(delay_co) then
   should_draw = false
   return
  else
   should_draw = true
   delay_co = nil
  end
 end
 if loose_co and not coresume(loose_co) then
  loose_co = nil
 end
 
 if state == game_state.state_game then
  handle_game_update()
 elseif state == game_state.state_gps then
  handle_gps_update()
 end
	tick = (tick +1)%3000
end

function handle_game_update()
	if tick%refresh_rate == 0 then
	 if is_on_terrain_type(flag.teleport) then
	  local bobby_mid = get_bobby_mid()
	  
	  if is_on_terrain_type(kind.teleport) then
 	  for i=1,count(teleports) do
 	   if bobby_mid.x == teleports[i].x and bobby_mid.y == teleports[i].y then
 	    local idx = i +1
 	    if idx > count(teleports) then
	      idx = 1
	     end
	     delay_co = cocreate(teleport_anim)
	     coresume(delay_co,idx)
	     return
	    end
	   end
	  elseif is_on_terrain_type(kind.door) then
	   local dest = destination_for_door_at(bobby_mid)
    teleport_bobby_to(dest, dest.offset_x, dest.offset_y)  
	   return
	  end
	 end
	 
		move_speed = walking
		if btn(controls.btn_2) then
			use_item()
		else
		 stop_item()
		end
		if btn(controls.btn_1) then
		 select_item()
		else
		 btn_1_down = false
		end
		move_bobby()
	end
end

function destination_for_door_at(cell)
 for door in all(doors) do
  if door.inn.x == cell.x and door.inn.y == cell.y then
   return {x=door.out.x, offset_x=door.out.offset_x, y=door.out.y, offset_y=door.out.offset_y}
  elseif door.out.x == cell.x and door.out.y == cell.y then
   return {x=door.inn.x, offset_x=door.inn.offset_x, y=door.inn.y, offset_y=door.inn.offset_y}
  end
 end
end

function teleport_anim(idx)
 sfx(0)
 teleport_bobby_stretch(true)
 teleport_bobby_to(teleports[idx], 1, 0)
 teleport_bobby_stretch(false)
end

function teleport_bobby_stretch(out)
 if out then
  anim={width=8,height=8}
  while anim.width > 0 do
	  anim.width -= 2
	  anim.height += 4
	  draw_teleport_anim()
	 end
	else
	 anim={width=0,height=24}
		while anim.width < 8 do
	  anim.width += 2
	  anim.height -= 4
	  draw_teleport_anim()
	 end
	end
end

function draw_teleport_anim()
 draw_map()
 handle_bombs()
 sspr(0,8,8,8,bobby.x + (8-anim.width)*0.5, bobby.y + 8 - anim.height, anim.width, anim.height)
 animate_textures()
 draw_hud()
 yield()
end

function teleport_bobby_to(p, offset_x, offset_y)
 if is_indoor(p.x) then
  local dest_x = (p.x+offset_x) * 8
  local dest_y = (p.y+offset_y) * 8
  local mod_x = dest_x % 128
  local mod_y = dest_y % 128
  map_x = -dest_x + mod_x
  map_y = -dest_y + mod_y
  bobby.x = mod_x
  bobby.y = mod_y
 else
  bobby.x = 64
  bobby.y = 64
  current_spr = sprites.standing
  map_x = 64 - (p.x+offset_x) * 8
  map_y = 64 - (p.y+offset_y) * 8
  if map_x > 0 then
   bobby.x -= map_x
   map_x = 0
  elseif map_x < (-128*7) then
   bobby.x += (-128*7) - map_x
   map_x = -128*7
  end
  if map_y > 0 then
   bobby.y -= map_y
   map_y = 0
  elseif map_y < (-64*8 +128) then
   bobby.y += (-64*8 + 128) - map_y
   map_y = -64*8 + 128
  end
 end
end

function handle_gps_update()
 if not btn(controls.btn_2) then
  state = game_state.state_game
 end
end

function select_item()
 if not is_on_terrain_type(flag.deep_water) and not btn_1_down then
  btn_1_down = true
  local nb = count(items)
  if nb > 1 then
   sfx(3)
   selected_item += 1
   if selected_item > nb then
    selected_item = 1
   end
  end
 end
end

function one_shot_item(item)
 return item == sprites.key or item == sprites.heart_full or item == sprites.heart_increment
end

function item_available(item)
 if count(items) > 0 and items[selected_item].sprite == item then
  return true
 end
 return false
end

function use_item()
 if item_available(sprites.boots) then
  move_speed = running
 elseif item_available(sprites.flipper) and is_on_terrain_type(flag.deep_water) and not btn_2_down then
  bobby.dive = max_diving_delay
 elseif item_available(sprites.bomb) and current_bomb == nil then
  current_bomb = {x=bobby.x - map_x, y=bobby.y - map_y, count_down=90, hitbox={x=0, y=0, width=8, height=8}}
 elseif item_available(sprites.gps) then
  state = game_state.state_gps
 end
 btn_2_down = true
end

function stop_item()
 bobby.dive = 0
 btn_2_down = false
end

function move_bobby()
	if btn(controls.down) then
		config_bobby(0,1)
	elseif btn(controls.up) then
		config_bobby(0,-1)
	elseif btn(controls.left) then
		config_bobby(-1,0)
	elseif btn(controls.right) then
		config_bobby(1,0)
	else
		stop_walking()
	end
end

function stop_walking()
	move_count = 0
	config_bobby(0,0)
end

function config_bobby(sx,sy)
 local orientation
 local water = (sx==0 and sy==0) and sprites.water_standing or sprites.water_walk
 if is_on_terrain_type(flag.deep_water) then
  move_speed = 1
  if bobby.dive > 0 then
   orientation = sprites.dive
  else
   orientation = swimming_sprite(sx,sy)
  end
 else
  bobby.dive = 0
  orientation = walking_sprite(sx,sy)
 end
 
 bobby.sx = sx
 bobby.sy = sy
	bobby.flip_x = sx == -1
	current_spr = set_current_spr(orientation)
	water_spr = water + (move_count%2)
	local dest_x = bobby.x + sx * move_speed
	local dest_y = bobby.y + sy * move_speed
	local min_x = 0
	local max_x = 128 - screen_offset
	local min_y = 0
	local max_y = 128 - screen_offset
	if should_move() then
		if not is_indoor() and ((dest_x <= map_move_offset and map_x < 0 and sx == -1) or (dest_x >= 128 - map_move_offset and map_x > -map_max_x and sx == 1)) then
			dest = map_x - sx * move_speed
			map_x = min(max(-map_max_x,dest),0)
		else
			bobby.x = min(max(dest_x,min_x),max_x)
		end
		if not is_indoor() and ((dest_y <= map_move_offset and map_y < 0 and sy == -1) or (dest_y >= 128 - map_move_offset and map_y > -map_max_y and sy == 1)) then
			dest = map_y - sy * move_speed
			map_y = min(max(-map_max_y,dest),0)
		else
			bobby.y = min(max(dest_y,min_y),max_y)
		end
	end
	move_count += 1
end

function walking_sprite(sx,sy)
 local sprite
 if not (sx == 0) then
  sprite = sprites.side
 elseif sy > 0 then
  sprite = sprites.front
 elseif sy < 0 then
  sprite = sprites.back
 else
  sprite = sprites.standing
 end
 return sprite
end

function swimming_sprite(sx,sy)
 local sprite
 if not (sx == 0) then
  sprite = sprites.swim_side
 elseif sy < 0 then
  sprite = sprites.swim_back
 else
  sprite = sprites.swim_front
 end
 return sprite
end

function set_current_spr(orientation)
 return orientation + (move_count%2)
end

function get_bobby_mid()
 local mid_x = flr((bobby.x + bobby.hitbox.x + (bobby.hitbox.width * 0.5) - map_x)/8)
 local mid_y = flr((bobby.y + bobby.hitbox.y + (bobby.hitbox.height * 0.5) - map_y)/8)
 return {x=mid_x,y=mid_y}
end

function is_kind_of(sprite, flags)
 local bit = 0
 for flag in all(flags) do
  bit += shl(1, flag)
 end
 return fget(sprite) == bit
end

function has_trait_type(sprite, flags)
 return fget(sprite, flags)
end

--[[
function is_terrain_type(sprite, flags)
 local b = true
 for flag in all(flags) do
  b = b and fget(sprite,flag)
 end
 return b
end
]]

function is_on_terrain_type(t)
 local bobby_mid = get_bobby_mid()
 local cell = mget(bobby_mid.x,bobby_mid.y)
 if type(t) == "number" then
  return has_trait_type(cell, t)
 elseif type(t) == "table" then
  return is_kind_of(cell, t)
 end
end

function should_move()
	local cells = collision_cells()
	return not collide_with(cells,flag.solid) and (not collide_with(cells,flag.deep_water) or item_available(sprites.flipper))
end

function collide_with(cells,flags)
 local is_colliding = false
 for cell in all(cells) do
  if type(flags) == "number" then
   is_colliding = is_colliding or has_trait_type(cell.sprite,flags)
  elseif type(flags) == "table" then
   is_colliding = is_colliding or is_kind_of(cell.sprite,flags)
  end
 end
 return is_colliding
end

function open_treasure_if_needed()
 if bobby.sy == -1 then
  local cells = collision_cells()
  for cell in all(cells) do
   if collide_with({cell},kind.closed_treasure) then
    if keys > 0 then
     sfx(2)
     if is_kind_of(mget(cell.x-1,cell.y), kind.closed_treasure) then
      spr(sprites.big_treasure_opened1, (cell.x-1) * 8 + map_x, (cell.y-1) * 8 + map_y)
    	 mset(cell.x-1,cell.y-1,sprites.big_treasure_opened1)
      spr(sprites.big_treasure_opened2, cell.x * 8 + map_x, (cell.y-1) * 8 + map_y)
    	 mset(cell.x,cell.y-1,sprites.big_treasure_opened2)
      spr(sprites.big_treasure_opened3, (cell.x-1) * 8 + map_x, cell.y * 8 + map_y)
    	 mset(cell.x-1,cell.y,sprites.big_treasure_opened3)
      spr(sprites.big_treasure_opened4, cell.x * 8 + map_x, cell.y * 8 + map_y)
    	 mset(cell.x,cell.y,sprites.big_treasure_opened4)
     else
      spr(sprites.big_treasure_opened1, cell.x * 8 + map_x, (cell.y-1) * 8 + map_y)
    	 mset(cell.x,cell.y-1,sprites.big_treasure_opened1)
      spr(sprites.big_treasure_opened2, (cell.x+1) * 8 + map_x, (cell.y-1) * 8 + map_y)
    	 mset(cell.x+1,cell.y-1,sprites.big_treasure_opened2)
      spr(sprites.big_treasure_opened3, cell.x * 8 + map_x, cell.y * 8 + map_y)
    	 mset(cell.x,cell.y,sprites.big_treasure_opened3)
      spr(sprites.big_treasure_opened4, (cell.x+1) * 8 + map_x, cell.y * 8 + map_y)
    	 mset(cell.x+1,cell.y,sprites.big_treasure_opened4)
     end
     keys -= 1
     move_count = 0
     current_spr = set_current_spr(sprites.open_treasure)
     water_spr = sprites.water_standing
     activate_treasure(cell)
     return
    else
     draw_text("hum... i need a key !",25,0,7)
     current_spr = sprites.standing
     draw_bobby()
     delay_co = cocreate(delay)
     coresume(delay_co,15)
     return
    end
   elseif collide_with({cell},kind.treasure) then
    sfx(2)
    mset(cell.x, cell.y, cell.sprite +1)
    spr(cell.sprite +1, cell.x * 8 + map_x, cell.y * 8 + map_y)
   	move_count = 0
    current_spr = set_current_spr(sprites.open_treasure)
    water_spr = sprites.water_standing
    activate_treasure(cell)
    return
   end
  end
 end
end

function activate_treasure(cell)
 for t in all(treasures) do
  if t.x == cell.x and t.y == cell.y then
   if not one_shot_item(t.sprite) then
    add(items,t)
   elseif t.sprite == sprites.heart_full then
    life = min(life + heart_value,hearts * heart_value)
   elseif t.sprite == sprites.heart_increment then
    hearts += 1
   elseif t.sprite == sprites.key then
    keys += 1
   end
   if t.sprite == sprites.candle then
    light_decay = candle_decay
   elseif t.sprite == sprites.big_candle then
    light_decay = big_candle_decay
    replace_candle_with(t)
   end
   spr(t.sprite,bobby.x, bobby.y - 10)
   if t.descript != nil then
    draw_text(t.descript.text,t.descript.x,0,7)
   end
   delay_co = cocreate(delay)
   coresume(delay_co,45)
   return
  end
 end
end

function replace_candle_with(t)
 for i in all(items) do
  if i.sprite == sprites.candle then
   del(items,i)
  end
 end
 sprites.candle = t.sprite
end

function draw_text(text,x,bg_col,col)
 rectfill(3,100,124,116,bg_col)
 print(text,x,106,col)
end

function delay(n,completion)
 for i=1,n do
  yield()
 end
 if completion != nil then
  completion()
 end
end

function current_overlaped_cells()
 local cells = {}
 local cell_x
 local cell_y
 for i=0,1 do
  for j=0,1 do
   cell_x = flr((bobby.x + (i * 8) - map_x)/8)
   cell_y = flr((bobby.y + bobby.hitbox.y + (j%2)*bobby.hitbox.height - map_y)/8)
   add(cells,{x=cell_x,y=cell_y,cell=mget(cell_x,cell_y)})
  end
 end
 return cells
end

function current_collided_cells()
 local cell_min_x = flr((bobby.x + bobby.hitbox.x - map_x)/8)
 local cell_max_x = flr((bobby.x + bobby.hitbox.x + bobby.hitbox.width - map_x)/8)
 local cell_min_y = flr((bobby.y + bobby.hitbox.y - map_y)/8)
 local cell_max_y = flr((bobby.y + bobby.hitbox.y + bobby.hitbox.height - map_y)/8)
 return {{x=cell_min_x,y=cell_min_y,cell=mget(cell_min_x,cell_min_y)},{x=cell_max_x,y=cell_min_y,cell=mget(cell_max_x,cell_min_y)},{x=cell_min_x,y=cell_max_y,cell=mget(cell_min_x,cell_max_y)},{x=cell_max_x,y=cell_max_y,cell=mget(cell_max_x,cell_max_y)}}
end

function collision_cells()
 local cell_min_x = 0
 local cell_max_x = 0
 local cell_min_y = 0
 local cell_max_y = 0
 
 if not (bobby.sy == 0) then
  cell_min_x = flr((bobby.x + bobby.hitbox.x - map_x)/8)
  cell_max_x = flr((bobby.x + bobby.hitbox.x + bobby.hitbox.width - map_x)/8)
  if bobby.sy > 0 then
   cell_min_y = flr((bobby.y + bobby.sy * move_speed + bobby.hitbox.y + bobby.hitbox.height - map_y)/8)
   cell_max_y = flr((bobby.y + bobby.sy * move_speed + bobby.hitbox.y + bobby.hitbox.height - map_y)/8)
  else
   cell_min_y = flr((bobby.y + bobby.sy * move_speed + bobby.hitbox.y - map_y)/8)
   cell_max_y = flr((bobby.y + bobby.sy * move_speed + bobby.hitbox.y - map_y)/8)
  end
 elseif not (bobby.sx == 0) then
  cell_min_y = flr((bobby.y + bobby.hitbox.y - map_y)/8)
  cell_max_y = flr((bobby.y + bobby.hitbox.y + bobby.hitbox.height - map_y)/8)
  if bobby.sx > 0 then
   cell_min_x = flr((bobby.x + bobby.sx * move_speed + bobby.hitbox.x + bobby.hitbox.width - map_x)/8)
   cell_max_x = flr((bobby.x + bobby.sx * move_speed + bobby.hitbox.x + bobby.hitbox.width - map_x)/8)
  else
   cell_min_x = flr((bobby.x + bobby.sx * move_speed + bobby.hitbox.x - map_x)/8)
   cell_max_x = flr((bobby.x + bobby.sx * move_speed + bobby.hitbox.x - map_x)/8)
  end
 end
 
 local cell_min = mget(cell_min_x,cell_min_y)
	local cell_max = mget(cell_max_x,cell_max_y)
 return {{x=cell_min_x,y=cell_min_y,sprite=cell_min},{x=cell_max_x,y=cell_max_y,sprite=cell_max}}
end

function collision_cells_with(a)
 min_x = flr((a.x + a.hitbox.x)/8)
 max_x = flr((a.x + a.hitbox.x + a.hitbox.width)/8)
 min_y = flr((a.y + a.hitbox.y)/8)
 max_y = flr((a.y + a.hitbox.y + a.hitbox.height)/8)
 return {{x=min_x,y=min_y,sprite=mget(min_x,min_y)},{x=max_x,y=min_y,sprite=mget(max_x,min_y)},{x=min_x,y=max_y,sprite=mget(min_x,max_y)},{x=max_x,y=max_y,sprite=mget(max_x,max_y)}}
end

function ceil(x)
	return -flr(-x)
end

function reset_palette()
 pal()
 palt(0,false)
	palt(alpha_color,true)
end

function _draw()
 reset_palette()
 if state == game_state.state_opening then
  draw_display(true,launch)
 elseif state == game_state.state_game then
  draw_game()
 elseif state == game_state.state_gps then
  draw_gps()
 elseif state == game_state.state_dead then
  draw_dead_state()
 elseif state == game_state.state_loose then
  draw_display(false,new_game)
 end
 update_gps_data()
end

function draw_dead_state()
	draw_map()
 handle_bombs()
 draw_bobby()
 animate_textures()
	draw_background_if_behind()
	draw_hud()
 draw_text("˜ you loose ˜",36,1,8)
end

function draw_gps()
 rectfill(0, 0, 127, 127, 1)
 local i = 0
 local m_offset_x = (128 - map_x_tiles)*0.5
 local m_offset_y = (128 - map_y_tiles)*0.5
 for col in all(map_data) do
  pset(m_offset_x + i%map_x_tiles, m_offset_y + flr(i/map_x_tiles), col)
  i	+= 1
 end
 if not is_indoor() then
  circ(m_offset_x + flr((bobby.x - map_x)/8), flr((bobby.y - map_y)/8) + m_offset_y, 2, 8)
 end
end

function draw_game()
 if not should_draw then
  return
 end
 dimm_screen_if_needed()
	draw_map()
	open_treasure_if_needed()
 --handle_bombs()
 bobby.injured = max(bobby.injured -1, 0)
 animate_textures()
 handle_indoor_display()
	draw_bobby()
 dimm_screen_if_needed()
 handle_bombs()
 draw_background_if_behind()
	reset_palette()
 draw_hud()
end

function handle_indoor_display()
 if is_indoor() then
  if item_available(sprites.candle) then
   dimm_screen(palette.shadow)
   draw_light(light_decay+1)
   reset_palette()
   draw_light(light_decay)
  else
   reset_palette()
   draw_exit()
  end
  if not item_available(sprites.candle) then
   dimm_screen(palette.no_candle)
  end
 end
end

function dimm_screen_if_needed()
 if is_indoor() then
	 dimm_screen(palette.no_candle)
	end
end

function draw_light(size)
 local p = get_bobby_mid()
 local bob
 local hitbox = {x=0,y=0,width=0,height=0}
 for j=p.y-size,p.y+size do
  for i=p.x-size,p.x+size do
   bob = {x=p.x,y=p.y,hitbox=hitbox}
   if distance(bob,{x=i,y=j,hitbox=hitbox}) <= size then
    spr(mget(i,j), i*8 + map_x, j*8 + map_y)
   end
  end
 end
end

function draw_exit()
 local k = ceil(-map_x/8)
 local n = ceil(-map_y/8)
 local s
 for j=n,n+16 do
  for i=k,k+16 do
   s = mget(i,j)
   if is_kind_of(s, kind.door) then
    spr(s, map_x + i*8, map_y + j*8)
   end
  end
 end
end

function dimm_screen(palette)
 local i=0
 while i < 16 do
  pal(i, palette[i+1], 0)
  i += 1
 end
end

function draw_map()
 rectfill(0, 0, 127, 127, background_color)
	cell_x = flr(map_x / -8)
	cell_y = flr(map_y / -8)
	mod_x = abs(map_x) % (cell_x * 8)
	mod_y = abs(map_y) % (cell_y * 8)
	map(cell_x,cell_y,-mod_x,-mod_y,17,17)
end

function draw_bobby()
 if bobby.dive > 0 then
  bobby.dive -= 1
 end
 if bobby.injured % 2 == 0 then
 	spr(current_spr, bobby.x, bobby.y, 1, 1, bobby.flip_x)
 end
	if is_on_terrain_type(flag.water) then
 	spr(water_spr, bobby.x, bobby.y, 1, 1)
	end
end

function animate_textures()
 local c
 local n = flr(-map_x/8)
 local m = flr(-map_y/8)
 for i=n,n+16 do
  for j=m,m+16 do
   c = mget(i,j)
   if (tick%21) == 0 then
    if has_trait_type(c,flag.water) then
     mset(i,j,sprites.water + tick%2)
    elseif has_trait_type(c,flag.deep_water) then
     mset(i,j,sprites.deep_water + tick%2)
    end
   elseif (tick%29) == 0 then
    if is_kind_of(c, kind.teleport) then
     mset(i,j,sprites.teleport1+ tick%2)
    end
   end
  end
 end
end

function draw_hud()
 local h
 for i=1,hearts do
  if ceil(life/heart_value) < i then
   h = sprites.heart_empty
  elseif life < (i * heart_value) then
   h = sprites.heart_full + (life - i * heart_value) % heart_value
  else
   h = sprites.heart_full
  end
  spr(h,i*7,120,1,1)
 end
 local n=1
 for item in all(items) do
   spr(item.sprite,128 - n*8,0)
  if n == selected_item then
   spr(sprites.selected_item,128 - n*8,0)
  end
  n += 1
 end
 if keys > 0 then
  spr(sprites.key,0,0)
  print("x"..keys,8,2,7)
 end
end

function draw_background_if_behind()
 local cells = current_overlaped_cells()
 for c in all(cells) do
  if has_trait_type(c.cell,flag.behind) then
   spr(c.cell,c.x*8+map_x,c.y*8+map_y,1,1)
  end
 end
end

function handle_bombs()
 if current_bomb != nil then
  current_bomb.count_down -= 1
  if current_bomb.count_down <= 0 then
   bomb_explode()
  else
   spr(sprites.bomb,current_bomb.x + map_x,current_bomb.y + map_y)
  end
 end
end

function bomb_explode()
 local sprite = sprites.bomb + flr(abs(current_bomb.count_down)/refresh_rate)
 spr(sprite,current_bomb.x + map_x,current_bomb.y + map_y)
 if current_bomb.count_down == 0 then 
  handle_bomb_damage()
  sfx(1)
 elseif current_bomb.count_down == -refresh_rate * 4 then
  current_bomb = nil
 end
end

function handle_bomb_damage()
 local bobby_map_position = {x=bobby.x - map_x, y=bobby.y - map_y, hitbox=bobby.hitbox}
 if distance(current_bomb,bobby_map_position) < 12 then
  injured(bomb_damage)
 end
 local cells = collision_cells_with(current_bomb)
 for cell in all(cells) do
  if has_trait_type(cell.sprite, flag.destroyable) then
   mset(cell.x, cell.y, cell.sprite +1)
  end
 end
end

function distance(a,b)
 ma={x=a.x + a.hitbox.x + a.hitbox.width * 0.5, y=a.y + a.hitbox.y + a.hitbox.height * 0.5}
 mb={x=b.x + b.hitbox.x + b.hitbox.width * 0.5, y=b.y + b.hitbox.y + b.hitbox.height * 0.5}
 return sqrt((mb.x - ma.x)*(mb.x - ma.x) + (mb.y - ma.y)*(mb.y - ma.y))
end

function injured(damage)
 life = max(life -damage, 0)
 if life == 0 then
  kill_bobby()
 else
  bobby.injured = 16
 end
end

function kill_bobby()
 current_spr = sprites.dead
 state = game_state.state_dead
 loose_co = cocreate(delay)
 coresume(loose_co,120,loose_game)
end

function loose_game()
 tick = 0
 state = game_state.state_loose
 sfx(3)
end

function draw_display(open,completion)
 draw_map()
 handle_bombs()
 draw_bobby()
 animate_textures()
	draw_background_if_behind()
	draw_hud()
 
 local colors = {10,12,8,1}
 local c = count(colors)
 local l = tick%32
 for i=15,0,-1 do
  for n=1,c do
   if open then
    rectfill((l-i+n-c)*8, i*8, 128, (i+1)*8, colors[n])
   else
    rectfill(0, i*8, (l-i-n+c)*8, (i+1)*8, colors[n])
   end
  end
 end
 if l == 31 then
  completion()
 end
end

function new_game()
 state = game_state.state_opening
 init_game()
 reinit_map_items()
end

function launch()
 state = game_state.state_game
end
__gfx__
ee9999eeee9999eeee9999eeee9999eeee9999eeee9999eeeeeeeeeeeeeeeeeeaafaaaaaaafaaaaaeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000ee
ee9ff9eeee9ff9eeee9999eeee9999eeee99feeeee99feeeeeeeeeeeeeeeeeeeaa55555aaaaaf7aaeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00aaa222aaa00e
eeeffeeeeeeffeeeeeeffeeeeeeffeeeeeeffeeeeeeffeeeeee555eeeee555ee71555d1a7aaad5aaeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0099aaaaaaa9900
ee88888ee88888eeee88888ee88888eeee888eeeeee88feeee55ee5eee5e555ea51511d5aa5aaddaeeeeeeeeeeeeeeeeeeeeeeee7eeeee7ee000000000000000
e88888feef88888ee88888feef88888eeef88feeeee8feeeee5e555eee55555ea551dd15adaaaaa7eeeeeeeeeeeeeeeee7eeeee7eeeeeeeee00000022200000e
ef1111eeee1111feef1111eeee1111feeee111eeeee11eeeeee555eeeee555eea5511551aa5a5aa5eee00000000000eeeeee7eeeee7eeeeeee0222222222220e
ee5ee1eeee1ee5eeee5ee1eeee1ee5eeeee1e5eee5111eeeeeeeeeeeeeeeeeeeaf15d15aafada5aaee00aaa222aaa00e7eceecceeceecceeee0222222222220e
eeeee5eeee5eeeeeeeeee5eeee5eeeeeeee5eeeeeeee5eeeeeeeeeeeeeeeeeeeaaaaf7aaaaaaf7aae0099aaaaaaa9900eedcddeeeecdddeeeee00222222200ee
ee9999eeee9999eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000ee000000000000000aafaaaaaa000000ae000000000000000
ee9ff9eeef9ff9feeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0a99a0ee0029aa000aa9200aaaaf7aaa0a99a0ae0029aa000aa9200
eeeffeeee8effe8eeee99eeeeee99eeeeee99eeeeee99eeeeee99eeeeee99eeee000000ee055550ee0029a02220a92007000000a7055550ae0029a02220a9200
ee8888eee888888eee9999eeee9999eeee9999eeee9999eeee9999eeee9999ee00a99a0000555500e0029a02220a920000a99a0000555500e0029a02220a9200
e888888eee8888eeee9ff9eeee9ff9eeee9999eeef9999feee99feeeee99feee0000000000000000e0029aa020aa92000000000000000000e0029aa020aa9200
ef1111feee1111eeee8ff8eeeeeffeeeeeeffeeeee8ff8eeeee8eeeeeee8efee09a00a9009a00a90e0029aa020aa920009a00a9009a00a90e0029aa020aa9200
ee1ee1eeee1ee1eeefeeeefeeefeefeeeeeeeeeeeeeeeeeeeeeefeeeeeeeeeee09aaaa9009aaaa90e00229a000a9220009aaaa9009aaaa90e00229a000a92200
ee5ee5eeee5ee5eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000ee0000000000000e0000000000000000ee0000000000000e
eeeeeeeeeeeeeeeeeeeeeeee33333333dddddddddddcdccdeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77eeee77eeeeeeeeee0e0eeeeee000eeaafaaaaa
eeeee555b5b5eeeeee5555ee33a33333dddcdddddddddddde000eeeeee0e0eeeee0e0eeeee0e0eeeee0e0eee7eeeeee7eeeeeeeee08080eeee05850eaaa117aa
eee553bbbbb55eeee5bb8b5e3a3a3333dccdcddddddddddde04d0eeee08080eee0e0e0eee0e0e0eee0e0e0eeeeeeeeeeeeeeeeee08e8e80ee0588850711dd11a
ee533bbbbbbbb5ee58bb78b533a33333ddddddddddcddddde04d0eeee08880eee0eee0eee08880eee0eee0eeeeeeeeeeeeeeeeee08eee80ee05777501d666d1a
e5333bbbbbbbbbeeb378bb7533333333ddddddddccdcdddde04d0eeeee080eeeee080eeeee080eeeee0e0eeeeeeeeeeeeeeeeeeee08e80eee40575041d666dd1
e533b3bbbbbbbb5ebbbb78b533333733dddddcdddddddddde04000eeeee0eeeeeee0eeeeeee0eeeeeee0eeeeeeeeeeeeeeeeeeeeee080eeeee40004e1dd66d11
e533bbbbbbbbbb5e58b8bbb533337373ddddcdccdddddddde044440eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7eeeeee7eecdcdeeeee0eeeeeee444eea111111a
e5333bbbbbbbbbbee5bbbb5e33333733ddddddddddddcddde000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee77eeee77eedcdceeeeeeeeeeeeeeeeeeaaaaf7aa
e533b3bbbbbbbb5eeeeeeeeeaafaaaaa11111111111c1cc1eeeeeeeeeeeeeeeeeeeeeeeeeeeeaeaeeeeeeeeeeeaeae6eeeaeae6e5e6ee5eeeeeeeeeeeeeeeeee
e5333b33b3bb35eeeee11eeeaaaaf7aa111c111111111111e5eeeeeeee55555eeeeeeeeeeeee09eeee7777eeea766ae6eae66ae6e66e5ee5eeeeeeeeeeeeeeee
ee553bb3333355eee11dd11e7aaaaaaa1cc1c111111111115d5eeeeee1555d1eeeeed5eeeee0eeaee777777ea679977aa6e99eeaeaeeee65eee555eeeeeeeeee
eeee53333b35eeee1d666d1eaaaaafaa1111111111c111115dd5eeeee51511d5ee5eeddeee555eeee777777ee977796ae9eee96aeeeeee6eeee5e5eeeeef8899
eeeee554455eeeee1d666dd1aaaaaaa711111111cc1c1111e55c5c5ce551dd15edeeeeeee57555eee777777ee697676ee69e6e6eee5eeeeeeeee5eeee5118899
eeeeeee24eeeeeee1dd66d11aa7aaaaa11111c1111111111eec5c5c5e5511551ee5e5ee5e57555eee777777ea767777eae6eeeeee6eeee6eeeee5eee51118899
eeeeeee24eeeeeeee111111eafaaaaaa1111c1cc11111111eeec5c5eee15d15eeeede5eee55575eeee7777eeae9799aeae9e99ae5eee6e5eeee55eeeeeeee8fe
eeeeee2222eeeeeeeeeeeeeeaaaaf7aa111111111111c111eeeec5eeeeeeeeeeeeeeeeeeee555eeeeeeeeeeeeae96aaeeae96aaeeeeaeeeeeeeeeeeeeeeeeeee
5555555555555555eeeeeeeeeeeeaeee444444440dd00dd00dd00dd0e555555e0dd00dd044444444000000000000000000000000000000000000000000000000
5000000550000005eeeeaeeeeeeaaaee44444444055d055d0550005d500000050005050044444445000000000000000000000000000000000000000000000000
50d2d205509a9a05eeeaaaeeeeaa9aae44444244055d055d0500000d500000050055500544544254000000000000000000000000000000000000000000000000
502d2d0550a9a905eeea9aeeeea999ae444444440000000000000000501111050000005544404445000000000000000000000000000000000000000000000000
50d2d205509a9a05eeee5eeeeea999ae444444440dd00dd000000000511551150dd5000d41444544000000000000000000000000000000000000000000000000
502d2d0550a9a905eeee6eeeeeeaaaee42444444055d055d0d00000d515665150500550d40414404000000000000000000000000000000000000000000000000
5000000550000005eeee6eeee5ee5ee544444424055d055d0d00200d55666655005d055044540455000000000000000000000000000000000000000000000000
5555555555555555eeee6eeeee55555e444444440000000000022200eeeeeeee0000000044444444000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000444444444000000400000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000004444444440a99a0400000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000400000044055550400000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000a99a000055550000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000009a00a9009a00a9000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000009aaaa9009aaaa9000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
43434343424242000073730000000000000000000000000000000000000000000000000000000000000073000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004343
43434343434242000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004343
43434343434242000212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004343
43434343430000000313000000000000000000000000000000000000000000000000000000000000007300000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004343
43434343430000000000000000000000000000000000000000000000000000000044440000000073000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004343
43434343000000000000000000000000000000000000000000000000000000004444440000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004343
43434343000000000000000000000000000000000000000000000000000000444444444400000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004343
43434343000000000000000000000000000000000000000000000000000000444444444444000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004343
43434343000000000000000000000000000000000000000000000000000000444444444444000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004343
43434300000000000000000000000000000000000000000000000000000000000000004400000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004343
43434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004343
43434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004343
43434300000000000000000000000000000000000000000000737300000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000212000000002200000000000000000000000000000000004343
43434343000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000313021200000022000000000000000000000000000000004343
43434343000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000002120000031302120000000000000000000000000000000000004343
43434343430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000003130212000003130000000000000000000000000000000000004343
43434343430000000000000000000000000000000000000000000000000000730000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000004242220313000032323232000000000000000000000000000000004343
43434343434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000424243424200000032323200320000000000000000000000000000004343
43434343434343000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000212424243434342423202123202123232320000000000000000000000004343
43434343434343430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000313737342434343424203133203133232000000000000000000000000004343
43434343434343434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000007304007342434342021232a0b0320000000032000000000000000000004343
43434343424243434343430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000007300007342424200031300a1b1000000000032000000000000000000004343
43434342424242434343434343000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000032737300000000000212323200323200000032320000000000000000004343
43434242333342424343434343430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000003232000000000000000313021202120000000000000000000000000000004343
43424233333333424243434343434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000003200000032320000003232031303130000000000000000000000000000004343
43423333333333334243434343434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000320000021200000000000000000000000000000000004343
43423333043333334243434343434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000003232000000031300000000000000000000000000000000004343
434242333333f2333343434343434343430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004343
43434242333333333380c14242434343430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004343
43434242424233338033334242424343434300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004343
43434342424242434342424242434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343
43434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343
43434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343
43434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343
__gff__
0000000000000000210008080000080800000000000000001101515111010101080801000202000000000000000000010101010004040021000000000000000080800000000190902100000000000000000000010808000000001101000000000000000001011000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
3434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434343434340000000000000000000000000034343434000000000000000000000000000000000000000000000000000000202145454545454545454645454545454545
343434343434342424242424243434343434343434343434343434343434343434343434242424243434343434343434343434343434242424242424242424242424000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030314545454545454544444545455a454545
3434343434242424242424242424242424343434343434343434343434343434343434242424242424242424243434343434342424242433333333333333332424242424240000000000000000000000000000000000000000000000000000000000000000000000000000000000000045454444444445444444454544444545
3434343424242424242424242424242424242424242424242424343434343434343434342424242424242424242424242424242424242433333300003333333333333333240000000000000000000000000000000000000000000000000000000000000000000000000000000000202145454444444445444444444545444545
3434343424242424243333333333333324242424242424242424242424243434343434343424242424242424242424242424242424243333000000000000000033333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000303145454444444545444444444545444545
3434342424243333333333333333333333333333333333242424242424242424343434343424242424242424242424242424242433333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000045454444444545444444444545444545
3434342424243333333333333300202100000037000033333324242424242424242434343434342424242424242424242424333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000202145454444444545454444444545444545
3434342424333333333333332021303122180000000000003333333324242424242424242434343434242424242424243333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000303145444444454545454444444545444445
3434242433333333333300323031232323230000000000000000003333333333242424242424243434342424242424333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000045444444444545444444444448444445
3434242433333333332021370000002323232323000000000000000000333333333324242424242424242424242424333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000045444444444544444444444445454545
3424242433333333333031180000232300232323324700001800000020210033333333333324242424242424242433333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000045444444444444444444444444454545
3424242433333333000000000000000000232300000000000000000030312021003333333333242433333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000045454444444444444444444444444545
3434242424333333000000232300000000002323232300000000202118003031202100333333333333333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000045454444444444444444444444444545
3434242424333333000040232323000000000000000022000000303100000000303100003333333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000045454444444444444444444444444545
3434343424243333330020210000000000000000000000000000000000000000000000000000333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000045454545454544444444444444454545
3434343424242433330030310000000000000000000000000000000000000000000000000000003333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000045454545454545454545454545454545
3434343434242433333300232323232300000020210000000000202100000000000000370000000000000020210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003434
3434343434242433333300000023230000000030312323000000303100000000370000000000000000000030310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003434
3434343434242433333300232323232323003218000000230000000000000000000000000000002200000020210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003434
2424243434242433333300232323232323230000002200000000000000000000000000000000220000320030310000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003434
2f1c243434243333333300000023230000230000000023000000000000000000000000320000002200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003434
3308243434243333330020210000000000000000000023000000000000000000002021320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003434
2424243434243333000030312200000000000000000000000000000000000000003031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003434
3434343434243333003232180000000000220000000000000000000022000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003434
3434343424243333000032000000000000000020210000000022000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003434
3434342424243333003200000000000000000030310000000000000000000000000000220000002021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003434
3434342424333300000000000000000000202100000000000000000000000000000000000000003031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003434
3434342424000000000000000023000000303100202100000000320000000000000000002200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003434
3434342424240023232323182323000000000000303100000000000000000000202100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003434
3434342424240023232322370023230000000000000000000000000000000000303100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003434
3434342424240020210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003434
3434343424240030310000000000000000000032000000000000003200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003434
__sfx__
000200001d5700557017570025700b57002570135600256018560035601b56002560195500255015550015500e550015400b5400353007520015100351001510025100450019500045000f500115001250015500
000400002667030670376703867039670306702b67026670206701d6701a670166701367012670106600c6600b650086400664004630026300162001610016100d6000a600096000760005600056000530005300
000700001a3701f36024350293403033037320363003a3002d3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000038570155001d500255002b500355002150000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344

