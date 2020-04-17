--first we join the necessary channels so the mod can "listen"  to what the server says and "talk" to it
weather_intake = minetest.mod_channel_join("weather_intake")
weather = minetest.mod_channel_join("weather_nodes")
weather_type = minetest.mod_channel_join("weather_type")
running_send = minetest.mod_channel_join("running_send")
player_movement_state = minetest.mod_channel_join("player.player_movement_state")


function initialize_all()
	--first we tell the server we're ready
	weather_intake:send_all("READY")
	weather_intake:leave()
	weather_intake = nil --leave the channel
	
	--next we load everything seperately because it's easier to work on individual files than have everything jammed into one file
	--not into seperate mods because that is unnecessary and cumbersome
	local path = minetest.get_modpath("crafter_client")
	dofile(path.."/player_input.lua")
	dofile(path.."/weather_handling.lua")
	dofile(path.."/environment_effects.lua")
end

--we must delay initialization until the player's camera exists in the world
--since there does not seem to be any client_loaded function
local initialize = false
minetest.register_globalstep(function(dtime)
	if not initialize and minetest.camera and not vector.equals(minetest.camera:get_pos(),vector.new(0,0,0)) then
		minetest.after(2, function()
			if weather_intake then
				initialize = true
				initialize_all()
			end
		end)
	end
end)
