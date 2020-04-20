local all_nodes = {}
local do_effects = false
local snow = false
local rain = false
local weather_update_timer = 0
local id_table = {}

local rain_sound_handle = nil

local spawn_snow = function(player)
	local pos = player:get_pos()
	local radius = 10
	local particle_table = {}
	
	local area = vector.new(10,10,10)
	
	local min = vector.subtract(pos, area)
	local max = vector.add(pos, area)
	
	
	local area_index = minetest.find_nodes_in_area_under_air(min, max, all_nodes)
	
	local spawn_table = {}
	--find the highest y value
	for _,index in pairs(area_index) do
		if not spawn_table[index.x] then spawn_table[index.x] = {} end
		if not spawn_table[index.x][index.z] then
			spawn_table[index.x][index.z] = index.y
		elseif spawn_table[index.x][index.z] < index.y then
			spawn_table[index.x][index.z] = index.y
		end
	end
	
	for x,x_index in pairs(spawn_table) do
		for z,y in pairs(x_index) do
			if minetest.get_node_or_nil(vector.new(x,y+1,z)) ~= nil then
				local pos = vector.new(x,y+1,z)
				local lightlevel = minetest.get_node_light(pos, 0.5)
				if lightlevel >= 14 then
					minetest.add_particlespawner({
						amount = 1,
						time = 0.5,
						minpos = vector.new(x-0.5,y,z-0.5),
						maxpos = vector.new(x+0.5,y+20,z+0.5),
						minvel = {x=-0.2, y=-0.2, z=-0.2},
						maxvel = {x=0.2, y=-0.5, z=0.2},
						minacc = {x=0, y=0, z=0},
						maxacc = {x=0, y=0, z=0},
						minexptime = 1,
						maxexptime = 1,
						minsize = 1,
						maxsize = 1,
						collisiondetection = true,
						collision_removal = true,
						object_collision = false,
						texture = "snowflake_"..math.random(1,2)..".png",
						playername = player:get_name(),
					})
				end
			end
		end
	end
end

local spawn_ichor = function(player)
	local pos = player:get_pos()
	local radius = 10
	local particle_table = {}
	
	local area = vector.new(10,10,10)
	
	local min = vector.subtract(pos, area)
	local max = vector.add(pos, area)
	
	
	local area_index = minetest.find_nodes_in_area_under_air(min, max, all_nodes)
	
	local spawn_table = {}
	--find the highest y value
	for _,index in pairs(area_index) do
		if not spawn_table[index.x] then spawn_table[index.x] = {} end
		if not spawn_table[index.x][index.z] then
			spawn_table[index.x][index.z] = index.y
		elseif spawn_table[index.x][index.z] < index.y then
			spawn_table[index.x][index.z] = index.y
		end
	end
	
	for x,x_index in pairs(spawn_table) do
		for z,y in pairs(x_index) do
			if minetest.get_node_or_nil(vector.new(x,y+1,z)) ~= nil then
				local pos = vector.new(x,y+1,z)
				minetest.add_particlespawner({
					amount = 1,
					time = 0.5,
					minpos = vector.new(x-0.5,y,z-0.5),
					maxpos = vector.new(x+0.5,y+20,z+0.5),
					minvel = {x=-0.2, y=0.2, z=-0.2},
					maxvel = {x=0.2, y=0.5, z=0.2},
					minacc = {x=0, y=0, z=0},
					maxacc = {x=0, y=0, z=0},
					minexptime = 1,
					maxexptime = 1,
					minsize = 1,
					maxsize = 1,
					collisiondetection = true,
					collision_removal = true,
					object_collision = false,
					texture = "ichor_"..math.random(1,2)..".png",
					playername = player:get_name(),
				})
			end
		end
	end
end

local spawn_rain = function(player)
	local pos = player:get_pos()
	local radius = 10
	local particle_table = {}
	
	local area = vector.new(10,10,10)
	
	local min = vector.subtract(pos, area)
	local max = vector.add(pos, area)
	
	
	local area_index = minetest.find_nodes_in_area_under_air(min, max, all_nodes)
	
	local spawn_table = {}
	--find the highest y value
	for _,index in pairs(area_index) do
		if not spawn_table[index.x] then spawn_table[index.x] = {} end
		if not spawn_table[index.x][index.z] then
			spawn_table[index.x][index.z] = index.y
		elseif spawn_table[index.x][index.z] < index.y then
			spawn_table[index.x][index.z] = index.y
		end
	end
	
	for x,x_index in pairs(spawn_table) do
		for z,y in pairs(x_index) do
			if minetest.get_node_or_nil(vector.new(x,y+1,z)) ~= nil then
				local pos = vector.new(x,y+1,z)
				local lightlevel = minetest.get_node_light(pos, 0.5)
				if lightlevel >= 14 then
					minetest.add_particlespawner({
						amount = 3,
						time = 0.5,
						minpos = vector.new(x-0.5,y,z-0.5),
						maxpos = vector.new(x+0.5,y+20,z+0.5),
						minvel = {x=0, y=-20, z=0},
						maxvel = {x=0, y=-20, z=0},
						minacc = {x=0, y=0, z=0},
						maxacc = {x=0, y=0, z=0},
						minexptime = 1,
						maxexptime = 2,
						minsize = 1,
						maxsize = 1,
						collisiondetection = true,
						collision_removal = true,
						object_collision = false,
						vertical = true,
						texture = "raindrop.png",
						playername = player:get_name(),
					})
				end
			end
		end
	end
end

--client runs through spawning weather particles
local player_pos
minetest.register_globalstep(function(dtime)
	player_pos = minetest.localplayer:get_pos()
	if do_effects then
		if snow or rain then
			weather_update_timer = weather_update_timer + dtime
			if weather_update_timer >= 0.5 then
				weather_update_timer = 0
				--do normal weather
				if player_pos.y > -10033 then
					if snow == true then
						spawn_snow(minetest.localplayer)
					elseif rain == true then
						spawn_rain(minetest.localplayer)
					end
				--rain blood upwards in the nether
				else
					if snow == true or rain == true then
						spawn_ichor(minetest.localplayer)
					end
				
					--stop the rain sound effect
					if rain_sound_handle then
						minetest.sound_fade(rain_sound_handle, -0.5, 0)
						rain_sound_handle = nil
					end
				end
			end
		end
	end
end)



minetest.register_on_modchannel_message(function(channel_name, sender, message)
	--receive the initial packet which tells the client which nodes
	--to spawn weather columns on
	if channel_name == "weather_nodes" then
		all_nodes = minetest.deserialize(message)
		do_effects = true
		weather:leave() --leave the channel
	end
	--receive the weather type
	if channel_name == "weather_type" then
		if message == "1" then
			rain = false
			snow = true
		elseif message == "2" then
			rain = true
			snow = false
		else
			rain = false
			snow = false
		end
	end
	--rain sound effect
	if not rain_sound_handle and rain == true then
		rain_sound_handle = minetest.sound_play("rain", {loop=true,gain=0})
		minetest.sound_fade(rain_sound_handle, 0.5, 0.5)
	elseif rain_sound_handle and rain == false then
		minetest.sound_fade(rain_sound_handle, -0.5, 0)
		rain_sound_handle = nil
	end
end)


--We must tell the server that we're ready
minetest.after(0,function()
	weather_intake:send_all("READY")
	weather_intake:leave()
	weather_intake = nil --leave the channel
end)
