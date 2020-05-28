--declare globals
weather_intake = nil
weather = nil
weather_type = nil
player_movement_state = nil
nether = nil
aether = nil
name = nil

function initialize_all()
	--declare globals for now
	weather_intake = minetest.mod_channel_join("weather_intake")
	weather = minetest.mod_channel_join("weather_nodes")
	weather_type = minetest.mod_channel_join("weather_type")
	player_movement_state = minetest.mod_channel_join(name..":player_movement_state")
	nether = minetest.mod_channel_join(name..":nether_teleporters")
	aether = minetest.mod_channel_join(name..":aether_teleporters")
		
	--next we load everything seperately because it's easier to work on individual files than have everything jammed into one file
	--not into seperate mods because that is unnecessary and cumbersome
	local path = minetest.get_modpath("crafter_client")
	dofile(path.."/player_input.lua")
	dofile(path.."/weather_handling.lua")
	dofile(path.."/environment_effects.lua")
	dofile(path.."/nether.lua")
	dofile(path.."/aether.lua")
	dofile(path.."/waila.lua")
	dofile(path.."/music_handling.lua")
end

--we must delay initialization until the player exists in the world
local function recursive_startup_attempt()
	local ready_to_go = minetest.localplayer
	if ready_to_go and minetest.get_node_or_nil(minetest.localplayer:get_pos()) then
		name = minetest.localplayer:get_name()
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
