local minetest,name = minetest,minetest.localplayer:get_name()
local fire_handling_channel = minetest.mod_channel_join(name..":fire_state")

local on_fire = 0
local fire_id = nil
local fire_animation_timer = 0
local fire_animation_tile = 0
--receive the server states
minetest.register_on_modchannel_message(function(channel_name, sender, message)
	if sender == "" and channel_name == name..":fire_state" then
        on_fire = tonumber(message)
	end
end)

minetest.register_globalstep(function(dtime)
    if on_fire == 0 then 
        if fire_id then
            minetest.localplayer:hud_remove(fire_id)
            fire_id = nil
        end
    elseif on_fire == 1 then
        if fire_id == nil then
            fire_id = minetest.localplayer:hud_add({
				hud_elem_type = "image", -- see HUD element types, default "text"
				position = {x=0.5, y=0.5},
				name = "",    -- default ""
				scale = {x=-100, y=-100}, -- default {x=0,y=0}
				text = "fire.png^[opacity:180^[verticalframe:8:"..fire_animation_tile,
            })
        else
            fire_animation_timer = fire_animation_timer + dtime
            if fire_animation_timer >= 0.05 then
                fire_animation_timer = 0
                fire_animation_tile = fire_animation_tile + 1
                if fire_animation_tile > 7 then
                    fire_animation_tile = 0
                end
                minetest.localplayer:hud_change(fire_id, "text", "fire.png^[opacity:180^[verticalframe:8:"..fire_animation_tile)
            end
        end
    end
end)