local minetest,name,vector,math,pairs = minetest,minetest.localplayer:get_name(),vector,math,pairs

local weather_intake = minetest.mod_channel_join("weather_intake")
local weather = minetest.mod_channel_join("weather_nodes")
local weather_type = minetest.mod_channel_join("weather_type")

local all_nodes = {}
local do_effects = false
local snow = false
local rain = false
local weather_update_timer = 0
local id_table = {}

local rain_sound_handle = nil



local y
local pos
local radius = 10
local particle_table
local area
local min
local max
local area_index
local spawn_table
local lightlevel
local null
local curr_light
local weather_effects = function(player,defined_type)
	pos = vector.round(player:get_pos())
	area = vector.new(10,10,10)
	min = vector.subtract(pos, area)
	max = vector.add(pos, area)
	area_index = minetest.find_nodes_in_area_under_air(min, max, all_nodes)
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

	if defined_type == "rain" then
	curr_light = minetest.get_node_light({x=pos.x,y=pos.y+1,z=pos.z},0.5)
	--rain sound effect
	if curr_light then
		if curr_light >= 15 then
			if not rain_sound_handle then
				rain_sound_handle = minetest.sound_play("rain", {loop=true,gain=0})
			end
			minetest.sound_fade(rain_sound_handle, 0.5, 1)
		elseif curr_light < 15 and rain_sound_handle then
			minetest.sound_fade(rain_sound_handle, -0.5, 0)
			rain_sound_handle = nil
		end
	end

	particle_table = {
		amount = 3,
		time = 0.5,
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
	}
	elseif defined_type == "snow" then
	particle_table = {
		amount = 1,
		time = 0.5,
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
	}
	elseif defined_type == "ichor" then
	particle_table = {
		amount = 1,
		time = 0.5,
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
	}
	end


	for x = min.x,max.x do
		for z = min.z,max.z do
			y = pos.y - 5
			if spawn_table[x] and spawn_table[x][z] then
				y = spawn_table[x][z]
			end
			if minetest.get_node_or_nil(vector.new(x,y+1,z)) ~= nil then
				lightlevel = minetest.get_node_light(vector.new(x,y+1,z), 0.5)
				if lightlevel >= 14 or defined_type == "ichor" then

					particle_table.minpos = vector.new(x-0.5,y,z-0.5)
					particle_table.maxpos = vector.new(x+0.5,y+20,z+0.5)

					null = minetest.add_particlespawner(particle_table)
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
	if not rain and rain_sound_handle then
		minetest.sound_fade(rain_sound_handle, -0.5, 0)
		rain_sound_handle = nil
	end
	--do again every half second
	minetest.after(0.5, function()
		update_weather()
	end)
end

minetest.register_on_modchannel_message(function(channel_name, sender, message)
	--receive the initial packet which tells the client which nodes
	--to spawn weather columns on
	if sender == "" and channel_name == "weather_nodes" then
		all_nodes = minetest.deserialize(message)
		do_effects = true
		weather:leave() --leave the channel
	end
	--receive the weather type
	if sender == "" and channel_name == "weather_type" then
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
end)


--We must tell the server that we're ready
minetest.after(0,function()
	weather_intake:send_all("READY")
	weather_intake:leave()
	weather_intake = nil --leave the channel
	
	--begin weather update
	update_weather()
end)
