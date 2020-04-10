--first we join the necessary channels so the mod can "listen" to what the server says
local weather = minetest.mod_channel_join("weather_nodes")
local weather_type = minetest.mod_channel_join("weather_type")
local running_send = minetest.mod_channel_join("running_send")
local player_movement_state = minetest.mod_channel_join("player.player_movement_state")


--we load everything seperately because it's easier to work on individual files than have everything jammed into one file
--not into seperate mods because that is unnecessary and cumbersome
local path = minetest.get_modpath("crafter_client")
dofile(path.."/weather_handling.lua")

--0 is nothing
--1 is up
--2 is down
--4 is left
--8 is right
--16 is jump
--32 is auxilary
--64 is sneak
--128 is left click
--256 is right click

--make the data from get_key_pressed usable
--Thanks Thou shalt use my mods!
function minetest.get_control_bits(player)
	local input = player:get_key_pressed()
	local input_table = {}
	--iterate through the table using the highest value first
	local keys = {"rightclick","leftclick","sneak","aux","jump","right","left","down","up"}
	for index,data in pairs(keys) do
		local modifier = math.pow(2, 9-index)
		if input >= modifier then
			input_table[data] = true
			input = input - modifier
		else
			input_table[data] = false
		end
	end
	return(input_table)
end

--double tap running

--set up our initial values
local running = false
local run_discharge_timer = 0
local old_up = false
local sneak = false
local old_sneak = false
bunny_hop = false

--attempt to tell the server to allow us to run
local send_server_movement_state = function(state)
	player_movement_state:send_all(state)
end

--receive the server states
minetest.register_on_modchannel_message(function(channel_name, sender, message)
	if channel_name == "player.player_movement_state" then
		running = message
	end
end)

--check player's input on the "up" key
minetest.register_globalstep(function(dtime)
	local input = minetest.get_control_bits(minetest.localplayer)
	local vel = minetest.localplayer:get_velocity().y
	local oldvel = minetest.localplayer:get_last_velocity().y
	
	--reset the run flag
	if running == true and (input.up == false or input.sneak == true or input.down == true) then
		running = false
		bunny_hop = false
		send_server_movement_state("0")
	end
	
	--add this here so the player can sneak
	if input.sneak == true then
		sneak = true
	end
	
	--stop bunnyhopping on land
	if bunny_hop == true and vel == 0 and oldvel < 0 then
		bunny_hop = false
	end
	
	--check if need to tell server to bunnyhop
	if running == true and vel > 0 and input.jump == true and bunny_hop == false then
		send_server_movement_state("2")
		bunny_hop = true
	elseif bunny_hop == false then
		if running == true then
			send_server_movement_state("1")
			bunny_hop = false
		elseif sneak == true then
			send_server_movement_state("3")
			bunny_hop = false
		else
			send_server_movement_state("0")
		end
	end
	
	
	
	
	--set the sneak state
	if sneak == true and old_sneak == false then
		send_server_movement_state("3")
	elseif input.sneak == false and old_sneak == true then
		sneak = false
		send_server_movement_state("0")
	end
	
	--half second window to double tap running
	if run_discharge_timer > 0 then
		run_discharge_timer = run_discharge_timer - dtime
		if run_discharge_timer <= 0 then
			run_discharge_timer = 0
		end
		--initialize double tap run
		if old_up == false and input.up == true then
			run_discharge_timer = 0
			running = true
			--print("running toggle on")
			send_server_movement_state("1")
		end
	end
	--check if new input of walking forwards
	if input.up and input.down == false and input.sneak == false and old_up == false and running == false and run_discharge_timer <= 0 then
		run_discharge_timer = 0.2
	end
	--save old value
	old_up = input.up
	old_sneak = input.sneak
end)


