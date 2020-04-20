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
		
	--next we load everything seperately because it's easier to work on individual files than have everything jammed into one file
	--not into seperate mods because that is unnecessary and cumbersome
	local path = minetest.get_modpath("crafter_client")
	dofile(path.."/player_input.lua")
	dofile(path.."/weather_handling.lua")
	dofile(path.."/environment_effects.lua")
	dofile(path.."/nether.lua")
end

--we must delay initialization until the server tells us it's ready to begin
local function recursive_startup_attempt()
	local initialize_client_modchannels = minetest.mod_channel_join("initializer")
	
	local ready_to_go = initialize_client_modchannels:is_writeable()
	if ready_to_go == true then
		--good to begin
		initialize_all()
		initialize_client_modchannels:leave()
	else
	
		
		--try again
		minetest.after(0,function()
			recursive_startup_attempt()
		end)
	end
end

--begin initial attempt
recursive_startup_attempt()
