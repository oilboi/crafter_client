local minetest,name = minetest,minetest.localplayer:get_name()
local sleep_channel = minetest.mod_channel_join(name..":sleep_channel")
local sleeping = 0
local sleep_fade = 0
local sleep_id = nil

minetest.register_on_modchannel_message(function(channel_name, sender, message)
	if sender == "" and channel_name == name..":sleep_channel" then
        sleeping = tonumber(message)
	end
end)



minetest.register_globalstep(function(dtime)
    if sleeping == 0 and sleep_fade == 0 then
        if sleep_id then
            sleep_id = nil
        end
        return
    elseif sleeping == 1 and sleep_fade < 255 then
        if not sleep_id then
            sleep_id = minetest.localplayer:hud_add({
                hud_elem_type = "image", -- see HUD element types, default "text"
                position = {x=0.5, y=0.5},
                name = "",    -- default ""
                scale = {x=-100, y=-100}, -- default {x=0,y=0}
                text = "sleep.png^[opacity:"..sleep_fade,
            })
        else
            sleep_fade = sleep_fade + (dtime*100)
            if sleep_fade >= 255 then
                sleep_fade = 255
                sleep_channel:send_all("true")
            end
            minetest.localplayer:hud_change(sleep_id, "text", "sleep.png^[opacity:"..sleep_fade)
        end
    elseif sleeping == 0 and sleep_fade > 0 then
        if sleep_id then
            sleep_fade = sleep_fade - (dtime*500)
            if sleep_fade < 0 then
                sleep_fade = 0
            end
            minetest.localplayer:hud_change(sleep_id, "text", "sleep.png^[opacity:"..sleep_fade)
            if sleep_fade == 0 then
                minetest.localplayer:hud_remove(sleep_id)
                sleep_id = nil
            end
        end
    end
end)