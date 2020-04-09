--first we join the necessary channels so the mod can "listen" to what the server says
local weather = minetest.mod_channel_join("weather_nodes")
local weather_type = minetest.mod_channel_join("weather_type")
local running_send = minetest.mod_channel_join("running_send")
local running_receive = minetest.mod_channel_join("running_receive")


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

--attempt to tell the server to allow us to run
local send_server_run_state = function(state)
	running_send:send_all(state)
end

--receive the server states
minetest.register_on_modchannel_message(function(channel_name, sender, message)
	if channel_name == "running_receive" then
		running = (message == "true")
	end
end)

--check player's input on the "up" key
minetest.register_globalstep(function(dtime)
	local input = minetest.get_control_bits(minetest.localplayer)
	
	--reset the run flag
	if running == true and (input.up == false or input.sneak == true or input.down == true) then
		running = false
		--print("running toggle off")
		send_server_run_state("false")
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
			send_server_run_state("true")
		end
	end
	--check if new input of walking forwards
	if input.up and input.down == false and input.sneak == false and old_up == false and running == false and run_discharge_timer <= 0 then
		run_discharge_timer = 0.5
	end
	--save old value
	old_up = input.up
end)


