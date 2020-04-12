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
dofile(path.."/environment_effects.lua")

