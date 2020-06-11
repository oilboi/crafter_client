local minetest,name = minetest,minetest.localplayer:get_name()
local version_channel = minetest.mod_channel_join(name..":client_version_channel")
minetest.after(2,function() -- this needs a few seconds for the mod channel to open up
    version_channel:send_all("0.05008")
end)