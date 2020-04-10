--first we join the necessary channels so the mod can "listen" to what the server says
weather = minetest.mod_channel_join("weather_nodes")
weather_type = minetest.mod_channel_join("weather_type")
running_send = minetest.mod_channel_join("running_send")
player_movement_state = minetest.mod_channel_join("player.player_movement_state")


--we load everything seperately because it's easier to work on individual files than have everything jammed into one file
--not into seperate mods because that is unnecessary and cumbersome
local path = minetest.get_modpath("crafter_client")
dofile(path.."/player_input.lua")
dofile(path.."/weather_handling.lua")

local old_node
local in_water = false
local old_in_water = false
minetest.register_globalstep(function(dtime)
	local pos = minetest.localplayer:get_pos()
	pos.y = pos.y - 0.1
	local node = minetest.get_node_or_nil(pos)
	if node then
		local name = node.name
		if name == "main:water" or name == "main:water_flowing" then
			in_water = true
			
			if in_water == true and old_in_water == false then
				minetest.sound_play("splash", {gain = 0.4, pitch = math.random(80,100)/100})
			end
		else
			in_water = false
		end
	end
	
	old_node = node
	old_in_water = in_water
end)
