-- This is inspired by the landrush mod by Bremaweb

areas.hud = {}

local cnt = 0
local avgc = 0
local tsta = 0
local tstb = 0

minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local pos = vector.round(player:getpos())
		local areaStrings = {}
		local usta = minetest.get_us_time()
		local arlist = areas:getAreasAtPos(pos, true)
		usta =  minetest.get_us_time() - usta
		local ustb = minetest.get_us_time()
		areas:getAreasAtPos(pos, false)
		ustb =  minetest.get_us_time() - ustb
		tsta = tsta + usta
		tstb = tstb + ustb
		if minetest.get_us_time() - cnt > 1000000 then
			avgc = avgc + 1
			cnt = minetest.get_us_time()
			print("HEY " .. math.floor(tsta / avgc) .. " " .. math.floor(tstb / avgc))
		end
		for id, area in pairs(arlist) do
			table.insert(areaStrings, ("%s [%u] (%s%s)")
					:format(area.name, id, area.owner,
					area.open and ":open" or ""))
		end
		local areaString = "Areas:"
		if #areaStrings > 0 then
			areaString = areaString.."\n"..
				table.concat(areaStrings, "\n")
		end
		local hud = areas.hud[name]
		if not hud then
			hud = {}
			areas.hud[name] = hud
			hud.areasId = player:hud_add({
				hud_elem_type = "text",
				name = "Areas",
				number = 0xFFFFFF,
				position = {x=0, y=1},
				offset = {x=8, y=-8},
				text = areaString,
				scale = {x=200, y=60},
				alignment = {x=1, y=-1},
			})
			hud.oldAreas = areaString
			return
		elseif hud.oldAreas ~= areaString then
			player:hud_change(hud.areasId, "text", areaString)
			hud.oldAreas = areaString
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	areas.hud[player:get_player_name()] = nil
end)

