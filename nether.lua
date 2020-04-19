--nether teleporters are animation based
--the animation must finish before the teleport is initialized

local hud_id = nil --foreground (portal)
local hud_bg_id = nil --black background
local nether_id = nil --the nether incoming
local cool_off_timer = 0 --use this to stop players teleporting back and forth
local init_sound = nil
local teleport_sound = nil
minetest.register_globalstep(function(dtime)
	if not minetest.localplayer or not minetest.camera then
		return
	end
	--use this for player cooloff timer also to not overload server
	if cool_off_timer > 0 then
		cool_off_timer = cool_off_timer - dtime
		if cool_off_timer <= 0 then
			cool_off_timer = 0
		end
	end
	
	local pos = minetest.localplayer:get_pos()
	pos.y = pos.y + 0.1
	
	local node = minetest.get_node_or_nil(pos)
	
	if node and node.name == "nether:portal" and cool_off_timer == 0 then
		if hud_bg_id == nil then
			hud_bg_id = minetest.localplayer:hud_add({
				hud_elem_type = "image", -- see HUD element types, default "text"
				position = {x=0.5, y=0.5},
				name = "",    -- default ""
				scale = {x=-100, y=-100}, -- default {x=0,y=0}
				text = "darkness.png",    -- default ""
			})
			hud_id = minetest.localplayer:hud_add({
				hud_elem_type = "image", -- see HUD element types, default "text"
				position = {x=0.5, y=0.5},
				name = "",    -- default ""
				scale = {x=-1, y=-1}, -- default {x=0,y=0}
				text = "nether_portal_gui.png",    -- default ""
			})
			nether_id = minetest.localplayer:hud_add({
				hud_elem_type = "image", -- see HUD element types, default "text"
				position = {x=0.5, y=0.5},
				name = "",    -- default ""
				scale = {x=0, y=0}, -- default {x=0,y=0}
				text = "darkness.png",    -- default ""
			})
			init_sound = minetest.sound_play("portal_initialize",{gain=0,pitch=math.random(70,90)/100})
			minetest.sound_fade(init_sound, 0.34, 1)
			
		else
			--make the hud zoom in
			local scale = minetest.localplayer:hud_get(hud_id).scale.x
			if scale > -100 then
				scale = scale - ((scale/-(1/dtime))*2)
			elseif scale < -100 then	
				scale = -100
			end
			minetest.localplayer:hud_change(hud_id, "scale", {x=scale,y=scale})
		end
	elseif hud_bg_id and hud_id then
		--play spooky sounds
		if init_sound then
			minetest.sound_fade(init_sound, -0.25, 0)
			init_sound = nil
			teleport_sound = minetest.sound_play("portal_teleported",{gain=1,pitch=math.random(70,90)/100})
			minetest.sound_fade(teleport_sound, -0.1, 0)
			teleport_sound = nil
		end
		--player left portal before teleporting
		if cool_off_timer == 0 then
			--make the hud zoom out
			local scale = minetest.localplayer:hud_get(hud_id).scale.x
			if scale < -1 then
				scale = scale + ((scale/-(1/dtime))*2)
			elseif scale > -1 then	
				scale = -1
			end
			minetest.localplayer:hud_change(hud_id, "scale", {x=scale,y=scale})
			
			if scale == -1 then
				minetest.localplayer:hud_remove(hud_bg_id)
				minetest.localplayer:hud_remove(hud_id)
				minetest.localplayer:hud_remove(nether_id)
				nether_id = nil
				hud_bg_id = nil
				hud_id = nil
			end
		--teleport complete animation
		else
			local scale = minetest.localplayer:hud_get(nether_id).scale.x
			if scale == 0 then scale = -1 end
			if scale > -100 then
				scale = scale - ((scale/-(1/dtime))*2)
			elseif scale < -100 then	
				scale = -100
			end
			minetest.localplayer:hud_change(nether_id, "scale", {x=scale,y=scale})
			if scale == -100 then
				minetest.localplayer:hud_remove(hud_bg_id)
				minetest.localplayer:hud_remove(hud_id)
				minetest.localplayer:hud_remove(nether_id)
				nether_id = nil
				hud_bg_id = nil
				hud_id = nil
			end
		end
	elseif hud_bg_id and hud_id then
		minetest.localplayer:hud_remove(hud_bg_id)
		minetest.localplayer:hud_remove(hud_id)
		minetest.localplayer:hud_remove(nether_id)
		nether_id = nil
		hud_bg_id = nil
		hud_id = nil
	end
	
	--initialize teleport command to server
	if hud_bg_id and hud_id and cool_off_timer == 0 then
		local scale = minetest.localplayer:hud_get(hud_id).scale.x
		if scale == -100 then
			nether:send_all("teleport me")
			--can't use any portal for 6 seconds
			cool_off_timer = 6
		end
	end
end)
