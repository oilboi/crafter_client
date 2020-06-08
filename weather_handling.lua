local all_nodes = {}
local do_effects = false
local snow = false
local rain = false
local weather_update_timer = 0
local id_table = {}

local rain_sound_handle = nil


--this is rice but it boosts the FPS slightly
local y
local find_em = minetest.find_nodes_in_area_under_air
local pos
local radius = 10
local particle_table
local area
local min
local max
local round_it = vector.round
local new_vec  = vector.new
local add_it   = vector.add
local sub_it   = vector.subtract
local area_index
local spawn_table
local get_the_node = minetest.get_node_or_nil
local get_the_light = minetest.get_node_light
local lightlevel
local add_ps = minetest.add_particlespawner
local l_name = name
-------
local weather_effects = function(player,defined_type)
	pos = round_it(player:get_pos())
	particle_table = {}
	area = new_vec(10,10,10)
	min = sub_it(pos, area)
	max = add_it(pos, area)
	area_index = find_em(min, max, all_nodes)
	spawn_table = nil -- this has to be terminated before reassignment
	spawn_table = {}
	--find the highest y value
	for _,index in pairs(area_index) do
		if not spawn_table[index.x] then spawn_table[index.x] = {} end
		if not spawn_table[index.x][index.z] then
			spawn_table[index.x][index.z] = index.y
		elseif spawn_table[index.x][index.z] < index.y then
			spawn_table[index.x][index.z] = index.y
		end
	end
	for x = min.x,max.x do
		for z = min.z,max.z do
			y = pos.y - 5
			if spawn_table[x] and spawn_table[x][z] then
				y = spawn_table[x][z]
			end
			if get_the_node(new_vec(x,y+1,z)) ~= nil then
				lightlevel = get_the_light(new_vec(x,y+1,z), 0.5)
				if lightlevel >= 14 or defined_type == "ichor" then
					if defined_type == "rain" then
						add_ps({
							amount = 3,
							time = 0.5,
							minpos = new_vec(x-0.5,y,z-0.5),
							maxpos = new_vec(x+0.5,y+20,z+0.5),
							minvel = {x=0, y=-20, z=0},
							maxvel = {x=0, y=-20, z=0},
							minacc = {x=0, y=0, z=0},
							maxacc = {x=0, y=0, z=0},
							minexptime = 0.5,
							maxexptime = 0.5,
							minsize = 4,
							maxsize = 4,
							collisiondetection = true,
							collision_removal = true,
							object_collision = false,
							vertical = true,
							texture = "raindrop.png^[opacity:80",
							playername = l_name,
						})
					elseif defined_type == "snow" then
						add_ps({
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
							playername = l_name,
						})
					elseif defined_type == "ichor" then
						add_ps({
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
	end
end



--client runs through spawning weather particles
local player_pos
local function update_weather()
	player_pos = minetest.localplayer:get_pos()
	if do_effects then
		if snow or rain then
			--do normal weather
			if player_pos.y > -10033 then
				if snow == true then
					weather_effects(minetest.localplayer, "snow")
				elseif rain == true then
					weather_effects(minetest.localplayer, "rain")
				end
			--rain blood upwards in the nether
			else
				if snow == true or rain == true then
					weather_effects(minetest.localplayer, "ichor")
				end
			
				--stop the rain sound effect
				if rain_sound_handle then
					minetest.sound_fade(rain_sound_handle, -0.5, 0)
					rain_sound_handle = nil
				end
			end
		end
	end
	--do again every half second
	minetest.after(0.5, function()
		update_weather()
	end)
end



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
	
	--begin weather update
	update_weather()
end)
