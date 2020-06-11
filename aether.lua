local minetest,name = minetest,minetest.localplayer:get_name()
local aether = minetest.mod_channel_join(name..":aether_teleporters")

--nether teleporters are animation based
--the animation must finish before the teleport is initialized
local hud_bg_id = nil --aether portal bg
local aether_cool_off_timer = 0 --use this to stop players teleporting back and forth
local init_sound = nil
local teleport_sound = nil
local opacity = 0

minetest.register_globalstep(function(dtime)
	if not minetest.localplayer or not minetest.camera then
		return
	end
	--use this for player cooloff timer also to not overload server
	if aether_cool_off_timer > 0 then
		aether_cool_off_timer = aether_cool_off_timer - dtime
		if aether_cool_off_timer <= 0 then
			aether_cool_off_timer = 0
		end
	end
	
	local pos = minetest.localplayer:get_pos()
	pos.y = pos.y + 0.1
	
	local node = minetest.get_node_or_nil(pos)
	
	if node and node.name == "aether:portal" and aether_cool_off_timer == 0 then
		if init_sound == nil then
			init_sound = minetest.sound_play("aether_teleport",{gain=0})
			minetest.sound_fade(init_sound, 0.34, 1)
		end
		if hud_bg_id == nil then
			hud_bg_id = minetest.localplayer:hud_add({
				hud_elem_type = "image", -- see HUD element types, default "text"
				position = {x=0.5, y=0.5},
				name = "",    -- default ""
				scale = {x=-100, y=-100}, -- default {x=0,y=0}
				text = "aether_portal_gui.png^[opacity:"..opacity,    -- default ""
			})
			
		elseif opacity < 255 then
			--make the hud fade in
			opacity = opacity + (dtime*100)
			
			minetest.localplayer:hud_change(hud_bg_id, "text", "aether_portal_gui.png^[opacity:"..opacity)
		end
	elseif hud_bg_id then
		--play heavenly sounds
		
		if init_sound and node and node.name == "aether:portal" then
			minetest.sound_fade(init_sound, -0.4, 0)
			init_sound = nil
			teleport_sound = minetest.sound_play("aether_teleport_complete",{gain=1})
			minetest.sound_fade(teleport_sound, -0.1, 0)
			teleport_sound = nil
		end
		
		--player left portal before teleporting
		if aether_cool_off_timer == 0 then
			opacity = opacity  - (dtime*100)			
			minetest.localplayer:hud_change(hud_bg_id, "text", "aether_portal_gui.png^[opacity:"..opacity)
			
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
		elseif aether_cool_off_timer > 0 then
		
			opacity = opacity  - (dtime*100)			
			minetest.localplayer:hud_change(hud_bg_id, "text", "aether_portal_gui.png^[opacity:"..opacity)
			
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
	if hud_bg_id and aether_cool_off_timer == 0 then
		if opacity >= 255 then
			aether:send_all("teleport me")
			--can't use any portal for 7 seconds
			aether_cool_off_timer = 7  --if you read this, you'll notice the nether cool off timer is 6 and this is 7 ;)
		end
	end
end)
