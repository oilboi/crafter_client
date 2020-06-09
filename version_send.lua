minetest.after(2,function() -- this needs a few seconds for the mod channel to open up
    version_channel:send_all("0.05006")
end)