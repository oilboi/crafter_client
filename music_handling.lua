local song_playing = nil
local song_tick = 0
local song_index = nil

local song_table ={
    [-1] = {name="uh_oh",length=10},

    [18900]={name="bedtime",length=22},
    [5000]={name="morning",length=15},
    [12000]={name="simple",length=36},
    [23999]={name="day",length=96}
}

minetest.register_globalstep(function(dtime)
    local time_of_day = math.floor((minetest.get_timeofday() * 24000)+0.5)
    --print(time_of_day)
    if song_table[time_of_day] and not song_playing then
        song_playing = song_table[time_of_day].name
        --print("playing "..song_table[time_of_day].name)
        minetest.sound_play(song_table[time_of_day].name,{gain=0.3})
        song_index = time_of_day
    elseif song_playing then
        song_tick = song_tick + dtime
        --print(song_tick)
        if song_tick > song_table[song_index].length then
            --print("resetting the song variable")
            song_playing = nil
            song_index = nil
            song_tick = 0
        end
    end
end)
--[[
minetest.register_on_death(function()
    if not song_playing then
        song_playing = song_table[-1].name
        print("playing "..song_table[-1].name)
        minetest.sound_play(song_table[-1].name,{gain=0.6})
        song_index = -1
    end
end)
]]--