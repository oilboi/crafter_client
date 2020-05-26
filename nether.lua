--nether teleporters are animation based
--the animation must finish before the teleport is initialized
local hud_bg_id = nil --aether portal bg
local nether_cool_off_timer = 0 --use this to stop players teleporting back and forth
local init_sound = nil
local teleport_sound = nil
local opacity = 0

minetest.register_globalstep(function(dtime)
	if not minetest.localplayer or not minetest.camera then
		return
	end
	--use this for player cooloff timer also to not overload server
	if nether_cool_off_timer > 0 then
		nether_cool_off_timer = nether_cool_off_timer - dtime
		if nether_cool_off_timer <= 0 then
			nether_cool_off_timer = 0
		end
	end
	
	local pos = minetest.localplayer:get_pos()
	pos.y = pos.y + 0.1
	
	local node = minetest.get_node_or_nil(pos)
	
	if node and node.name == "nether:portal" and nether_cool_off_timer == 0 then
		if init_sound == nil then
			init_sound = minetest.sound_play("portal_initialize",{gain=0})
			minetest.sound_fade(init_sound, 0.34, 1)
		end
		if hud_bg_id == nil then
			hud_bg_id = minetest.localplayer:hud_add({
				hud_elem_type = "image", -- see HUD element types, default "text"
				position = {x=0.5, y=0.5},
				name = "",    -- default ""
				scale = {x=-100, y=-100}, -- default {x=0,y=0}
				text = "nether_portal_gui.png^[opacity:"..opacity,    -- default ""
			})
			
		elseif opacity < 255 then
			--make the hud fade in
			opacity = opacity + (dtime*100)
			
			minetest.localplayer:hud_change(hud_bg_id, "text", "nether_portal_gui.png^[opacity:"..opacity)
		end
	elseif hud_bg_id then
		--play heavenly sounds
		
		if init_sound and node and node.name == "nether:portal" then
			minetest.sound_fade(init_sound, -0.4, 0)
			init_sound = nil
			teleport_sound = minetest.sound_play("portal_teleported",{gain=1})
			minetest.sound_fade(teleport_sound, -0.1, 0)
			teleport_sound = nil
		end
		
		--player left portal before teleporting
		if nether_cool_off_timer == 0 then
			opacity = opacity  - (dtime*100)			
			minetest.localplayer:hud_change(hud_bg_id, "text", "nether_portal_gui.png^[opacity:"..opacity)
			
			if init_sound then
				minetest.sound_fade(init_sound, -0.4, 0)
				init_sound = nil
			end
			
			if opacity <= 0 then
				minetest.localplayer:hud_remove(hud_bg_id)
				hud_bg_id = nil
				opacity = 0
			end
		--teleport complete animation
		elseif nether_cool_off_timer > 0 then
		
			opacity = opacity  - (dtime*100)			
			minetest.localplayer:hud_change(hud_bg_id, "text", "nether_portal_gui.png^[opacity:"..opacity)
			
			if opacity <= 0 then
				minetest.localplayer:hud_remove(hud_bg_id)
				hud_bg_id = nil
				opacity = 0
			end
		else
			init_sound = nil
		end
	elseif hud_bg_id then
		minetest.localplayer:hud_remove(hud_bg_id)
		hud_bg_id = nil
		opacity = 0
	end
	
	--initialize teleport command to server
	if hud_bg_id and nether_cool_off_timer == 0 then
		if opacity >= 255 then
			nether:send_all("teleport me")
			--can't use any portal for 7 seconds
			nether_cool_off_timer = 6  --if you read this, you'll notice the nether cool off timer is 6 and this is 7 ;)
			minetest.after(1,function()
				local after_newpos = minetest.localplayer:get_pos().y
				if after_newpos < -10000 and after_newpos > -20000 then
					--cancel old songs
					if current_song then
						minetest.sound_fade(current_song,-0.4,0)
					end

					minetest.after(math.random(3,5)+math.random(),function()
						if after_newpos < -10000 and after_newpos > -20000 then
							--backup in case server lags out
							if current_song then
								minetest.sound_fade(current_song,-0.4,0)
							end
							local song = 90000+math.random(0,1)
							--print(song)
							song_playing = song_table[song].name
							current_song = minetest.sound_play(song_table[song].name,{gain=song_volume})
							song_index = song
							
						end
					end)
				elseif song_playing and (song_index == 90000 or song_index == 90001) then
					minetest.sound_fade(current_song,-0.4,0)
					song_playing = nil
					song_index = nil
					song_tick = 0
				end
			end)
		end
	end
end)
