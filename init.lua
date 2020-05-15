--declare globals
weather_intake = nil
weather = nil
weather_type = nil
running_send = nil
player_movement_state = nil
nether = nil

function initialize_all()
	--declare globals for now
	weather_intake = minetest.mod_channel_join("weather_intake")
	weather = minetest.mod_channel_join("weather_nodes")
	weather_type = minetest.mod_channel_join("weather_type")
	running_send = minetest.mod_channel_join("running_send")
	player_movement_state = minetest.mod_channel_join("player.player_movement_state")
	nether = minetest.mod_channel_join("nether_teleporters")
	aether = minetest.mod_channel_join("aether_teleporters")
		
	--next we load everything seperately because it's easier to work on individual files than have everything jammed into one file
	--not into seperate mods because that is unnecessary and cumbersome
	local path = minetest.get_modpath("crafter_client")
	dofile(path.."/player_input.lua")
	dofile(path.."/weather_handling.lua")
	dofile(path.."/environment_effects.lua")
	dofile(path.."/nether.lua")
	dofile(path.."/aether.lua")
	dofile(path.."/waila.lua")
end

--we must delay initialization until the player exists in the world
local function recursive_startup_attempt()
	local ready_to_go = minetest.localplayer
	if ready_to_go then
		--good to begin
		initialize_all()
	else
		--try again
		minetest.after(0,function()
			recursive_startup_attempt()
		end)
	end
end

--begin initial attempt
recursive_startup_attempt()
