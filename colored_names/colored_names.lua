-- Backwards compatibility for 0.4.x
if not core.register_on_receiving_chat_message then
	core.register_on_receiving_chat_message = core.register_on_receiving_chat_messages
end

local color_reset = "\x1b(c@#FFF)"
local c_pattern = "\x1b%(c@#[0-9a-fA-F]+%)"

core.register_on_receiving_chat_message(function(line)
	local myname_l = "~[CAPS£"
	if core.localplayer then
		myname_l = core.localplayer:get_name():lower()
	end

	-- Detect color to still do the name mentioning effect
	local color, line_nc = line:match("^(" .. c_pattern .. ")(.*)")
	line = line_nc or line

	local prefix
	local chat_line = false

	local name, color_end, message = line:match("^%<(%S+)%>%s*(" .. c_pattern .. ")%s*(.*)")
	if not message then
		name, message = line:match("^%<(%S+)%> (.*)")
		if name then
			name = name:gsub(c_pattern, "")
		end
	end

	if message then
		-- To keep the <Name> notation
		chat_line = true
	else
		-- Server messages, actions
		prefix, name, message = line:match("^(%*+ )(%S+) (.*)")
	end
	if not message then
		-- Colored prefix
		prefix, name, message = line:match("^(.* )%<(%S+)%> (.*)")
		if color and message and prefix:len() > 0 then
			prefix = color .. prefix .. color_reset
			color = nil
		end
		chat_line = true
	end
	if not message then
		-- Skip unknown chat line
		return
	end

	prefix = prefix or ""
	local name_wrap = name

	-- No color yet? We need color.
	if not color then
		local color = core.sha1(name, true)
		local R = color:byte( 1) % 0x10
		local G = color:byte(10) % 0x10
		local B = color:byte(20) % 0x10
		if R + G + B < 24 then
			R = 15 - R
			G = 15 - G
			B = 15 - B
		end
		if chat_line then
			name_wrap = "<" .. name .. ">"
		end
		name_wrap = minetest.colorize(string.format("#%X%X%X", R, G, B), name_wrap)
	elseif chat_line then
		name_wrap = "<" .. name .. ">"
	end

	if (chat_line or prefix == "* ") and name:lower() ~= myname_l
			and message:lower():find(myname_l) then
		prefix = minetest.colorize("#F33", "[!] ") .. prefix
	end

	return minetest.display_chat_message(prefix .. (color or "")
		.. name_wrap .. (color_end or "") .. " " .. message)
end)