--double tap running

--set up our initial values
local state = 0
local old_state = 0
local running = false
local run_discharge_timer = 0
local old_up = false
local sneak = false
local old_sneak = false
local bunny_hop = false
local old_bunny_hop = false



--attempt to tell the server to allow us to run
local send_server_movement_state = function(state)
	player_movement_state:send_all(state)
	--print(state)
end

--receive the server states
--minetest.register_on_modchannel_message(function(channel_name, sender, message)
--	if channel_name == name..":receive_player_movement_state" then
--		running = message
--	end
--end)

--check player's input on the "up" key
minetest.register_globalstep(function(dtime)

	if not minetest.localplayer then
		return
	end
	
	local input = minetest.localplayer:get_control()
	local vel = minetest.localplayer:get_velocity()
	local oldvel = minetest.localplayer:get_last_velocity()
	
	--cancel running if the player bumps into something
	if running == true and ((vel.x == 0 and oldvel.x ~= 0) or (vel.z == 0 and oldvel.z ~= 0)) then
		running = false
		bunny_hop = false
		run_discharge_timer = 0
		state = 0
	end
	
	--reset the run flag
	if running == true and (input.up == false or input.sneak == true or input.down == true) then
		running = false
		bunny_hop = false
		state = 0
	end
	
	
	--check if need to tell server to bunnyhop
	if running == true and vel.y > 0 and input.jump == true and bunny_hop == false then
		state = 2
		bunny_hop = true
	end
	
	--stop bunny hopping
	if bunny_hop == true and input.jump == false and running == true and vel.y == 0 then
		bunny_hop = false
		state = 1
	end
	
	
	--half second window to double tap running
	if run_discharge_timer > 0 then
		run_discharge_timer = run_discharge_timer - dtime
		if run_discharge_timer <= 0 then
			run_discharge_timer = 0
		end
		--initialize double tap run
		if old_up == false and input.up == true and vel.x ~= 0 and vel.z ~= 0 then
			run_discharge_timer = 0
			running = true
			state = 1
		end
	end
	
	
	--check if new input of walking forwards
	if input.up and input.down == false and input.sneak == false and old_up == false and running == false and run_discharge_timer <= 0 then
		run_discharge_timer = 0.2
	end
	
	--add this here so the player can sneak
	if input.sneak == true then
		run_discharge_timer = 0
		sneak = true
		bunny_hop = false
		run = false
	end
	

	--set the sneak state
	if sneak == true and old_sneak == false then
		state = 3
	elseif input.sneak == false and old_sneak == true then
		sneak = false
		state = 0
	end
	
	--only send if state has changed
	if state ~= old_state then
		send_server_movement_state(tostring(state))
	end
	
	--save old value
	old_up = input.up
	old_sneak = input.sneak
	old_bunny_hop = bunny_hop
	old_state = state
end)
