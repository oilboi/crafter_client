local old_node
local in_water = false
local old_in_water = false
--this is to check if the player is exploring a cave
--if exploring cave not near an open shaft then play a scary noise
--every 5-7 minutes
local scary_sound_player_timer = math.random(-120,0)


--this is used for the water trickling effect
local water_trickling_timer = 0
local water_sound_handle = nil

local function splash_effect()
	if minetest.localplayer then		
		local vel = minetest.localplayer:get_velocity().y
		local pos = minetest.localplayer:get_pos()
		local node = minetest.get_node_or_nil(pos)
		
		if node then
			local name = node.name
			if name == "main:water" or name == "main:waterflow" then
				in_water = true
				if in_water == true and old_in_water == false and vel < 0 then
					minetest.sound_play("splash", {gain = 0.4, pitch = math.random(80,100)/100, gain = 0.05})
				end
			else
				in_water = false
			end
		end
		
		old_node = node
		old_in_water = in_water
	end
	minetest.after(0.01, function()
		splash_effect()
	end)
end
splash_effect()


	
---------------------------------------------


local function scary_sound_timer()
	--print(scary_sound_player_timer)
	--try to play every 5-7 minutes
	if minetest.localplayer then
		local pos = minetest.localplayer:get_pos()
		pos.y = pos.y + 1.625
		local light = minetest.get_node_light(pos)
		if pos.y < 0 and light <= 13 then
			minetest.sound_play("scary_noise",{gain=0.4,pitch=math.random(70,100)/100})
		end
	end
	minetest.after(300+math.random(0,120), function()
		scary_sound_timer()
	end)
end

minetest.after(300+math.random(0,120), function()
	scary_sound_timer()
end)


------------------------------------------------------

local function water_trickle()
	if minetest.localplayer then
		local pos = minetest.localplayer:get_pos()
		local is_water_near = minetest.find_node_near(pos, 3, {"main:waterflow"})
		if is_water_near and not water_sound_handle then
			water_sound_handle = minetest.sound_play("stream", {loop=true,gain=0})
			minetest.sound_fade(water_sound_handle, 0.25, 0.1)
		elseif not is_water_near and water_sound_handle then
			minetest.sound_fade(water_sound_handle, -0.25, 0)
			water_sound_handle = nil
		end
	end
	minetest.after(0.1, function()
		water_trickle()
	end)
end

water_trickle()
