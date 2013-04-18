
local wpp = {}
wpp.run_player = {}
wpp.data = {}
-- - playername
--     - p1
--     - p2
--     - node
--     - action
--     - status ("wating", "running", "paused", "")
--     - p

local NODES_PER_STEP = 255

local function minmaxp(p1, p2)
	return 
		{x=math.min(p1.x,p2.x), y=math.min(p1.y,p2.y), z=math.min(p1.z,p2.z)},
		{x=math.max(p1.x,p2.x), y=math.max(p1.y,p2.y), z=math.max(p1.z,p2.z)}
end

local function send_player(playername, text)
	--minetest.chat_send_player(playername, "Wordledit++ -!- "..text, true) TODO
	minetest.chat_send_player(playername, text)
end

minetest.register_globalstep(function(dtime)
	if not wpp.dtime then
		wpp.dtime = dtime
	else
		wpp.dtime = (wpp.dtime + dtime) / 2
	end
		
	local playername = wpp.run_player[1]
	if playername then
		if playername == "" then
			table.remove(wpp.run_player, 1)
		end
		
		if wpp.data[playername].action == "set" then
			local minp, maxp = minmaxp(wpp.data[playername].p1, wpp.data[playername].p2)
			
			if wpp.data[playername].status ~= "running" then
				local eta = (maxp.x-minp.x)*(maxp.y-minp.y)*(maxp.z-minp.z)/NODES_PER_STEP * wpp.dtime
				eta = math.floor(eta)
				send_player(playername, "Starting your command; ETA: "..eta.." seconds (based on average server speed)")
				wpp.data[playername].status = "running"
			end
			
			if not wpp.data[playername].p then
				wpp.data[playername].p = {x=minp.x, y=minp.y, z=minp.z}
			end
			
			local i = 0
			while
				wpp.data[playername].p.x ~= maxp.x or
				wpp.data[playername].p.y ~= maxp.y or
				wpp.data[playername].p.z ~= maxp.z
			do
				minetest.env:set_node(wpp.data[playername].p, {name=wpp.data[playername].node})
				
				wpp.data[playername].p.z = wpp.data[playername].p.z+1
				if wpp.data[playername].p.z > maxp.z then
					wpp.data[playername].p.z = minp.z
					wpp.data[playername].p.y = wpp.data[playername].p.y+1
					if wpp.data[playername].p.y > maxp.y then
						wpp.data[playername].p.y = minp.y
						wpp.data[playername].p.x = wpp.data[playername].p.x+1
						if wpp.data[playername].p.x > maxp.x then
							break
						end
					end
				end
				
				i = i+1
				if i >= NODES_PER_STEP then
					return
				end
			end
			send_player(playername, "Command finished")
			wpp.data[playername].status = ""
			wpp.data[playername].p = nil
			table.remove(wpp.run_player, 1)
		else
			wpp.data[playername].status = ""
			send_player(playername, "Error occured: Unknonw action")
			table.remove(wpp.run_player, 1)
			wpp.data[playername].p = nil
		end
	end
end)

local function init_player(playername)
	if not wpp.data[playername] then
		wpp.data[playername] = {status = ""}
	end
end

local function check_running(playername)
	if wpp.data[playername].status == "waiting" then
		send_player(playername, "Your last command is waiting for execution; use /stop to abort")
		return true
	end
	if wpp.data[playername].status == "running" then
		send_player(playername, "Your last command is executing; use /stop to abort or /pause to pause")
		return true
	end
	if wpp.data[playername].status == "paused" then
		send_player(playername, "Your last command is stopped; use /stop to abort or /continue to finish")
		return true
	end
	return false
end

minetest.register_privilege("worldedit", "Can use worldedit++")

minetest.register_chatcommand("wpp", {
	params = "<none>",
	description = "Prints the status of Worldedit++ for the player",
	privs = {worldedit = true},
	func = function(playername, param)
		init_player(playername)
		
		--send_player(playername, dump(wpp.data[playername]))
		if wpp.data[playername].p1 then
			send_player(playername, "Position 1: "..minetest.pos_to_string(wpp.data[playername].p1))
		else
			send_player(playername, "Position 1 not set")
		end
		if wpp.data[playername].p2 then
			send_player(playername, "Position 2: "..minetest.pos_to_string(wpp.data[playername].p2))
		else
			send_player(playername, "Position 2 not set")
		end
		if wpp.data[playername].node then
			send_player(playername, "Selected node: "..wpp.data[playername].node)
		else
			send_player(playername, "No node slected")
		end
		if wpp.data[playername].status == "running" then
			send_player(playername, "Running command "..wpp.data[playername].action)
			--TODO
		elseif wpp.data[playername].status == "paused" then
			send_player(playername, "Command "..wpp.data[playername].action.." paused")
		elseif wpp.data[playername].status == "waiting" then
			send_player(playername, "Command "..wpp.data[playername].action.." waiting in serverqueue")
		else
			send_player(playername, "No command running/waiting/paused")
		end
	end,
})

minetest.register_chatcommand("p1", {
	params = "<none> | <X>,<Y>,<Z>",
	description = "Sets position 1",
	privs = {worldedit = true},
	func = function(playername, param)
		init_player(playername)
		if check_running(playername) then return end
		
		local p = minetest.env:get_player_by_name(playername):getpos()
		if param ~= "" then
			p.x, p.y, p.z = string.match(param, "^([%d.-]+)[, ] *([%d.-]+)[, ] *([%d.-]+)$")
			if not p.x or not p.y or not p.z then
				send_player(playername, "Invalid parameters (\""..param.."\") (see /help p1)")
				return
			end
		end
		wpp.data[playername].p1 = {x=math.floor(0.5+p.x), y=math.floor(0.5+p.y), z=math.floor(0.5+p.z)}
		send_player(playername, "Position 1 set to "..minetest.pos_to_string(wpp.data[playername].p1))
	end,
})

minetest.register_chatcommand("p2", {
	params = "<none> | <X>,<Y>,<Z>",
	description = "Sets position 2",
	privs = {worldedit = true},
	func = function(playername, param)
		init_player(playername)
		if check_running(playername) then return end
		
		local p = minetest.env:get_player_by_name(playername):getpos()
		if param ~= "" then
			p.x, p.y, p.z = string.match(param, "^([%d.-]+)[, ] *([%d.-]+)[, ] *([%d.-]+)$")
			if not p.x or not p.y or not p.z then
				send_player(playername, "Invalid parameters (\""..param.."\") (see /help p2)")
				return
			end
		end
		wpp.data[playername].p2 = {x=math.floor(0.5+p.x), y=math.floor(0.5+p.y), z=math.floor(0.5+p.z)}
		send_player(playername, "Position 2 set to "..minetest.pos_to_string(wpp.data[playername].p2))
	end,
})

minetest.register_chatcommand("select", {
	params = "<none> | <nodename>",
	description = "Selects node",
	privs = {worldedit = true},
	func = function(playername, param)
		init_player(playername)
		if check_running(playername) then return end
		
		if param ~= "" then
			if not minetest.registered_nodes[param] then
				send_player(playername, "Unknonwn node: \""..param.."\"")
				return
			end
			wpp.data[playername].node = param
		else
			local item = minetest.env:get_player_by_name(playername):get_wielded_item():get_name()
			if minetest.registered_nodes[item] then
				wpp.data[playername].node = item
			else
				send_player(playername, "Wielditem is not a node")
				return
			end
		end
		send_player(playername, "Node selected: "..wpp.data[playername].node)
	end,
})

minetest.register_chatcommand("set", {
	params = "<none>",
	description = "Sets nodes in area",
	privs = {worldedit = true},
	func = function(playername, param)
		init_player(playername)
		if check_running(playername) then return end
		
		if not wpp.data[playername].node then
			send_player(playername, "No node selected. Please select one with /select")
			return
		end
		if not wpp.data[playername].p1 then
			send_player(playername, "No position 1 set. Please set one with /p1")
			return
		end
		if not wpp.data[playername].p2 then
			send_player(playername, "No position 2 set. Please set one with /p2")
			return
		end
		wpp.data[playername].action = "set"
		wpp.data[playername].status = "waiting"
		table.insert(wpp.run_player, playername)
		send_player(playername, "Command enqueued")
	end,
})

minetest.register_chatcommand("stop", {
	params = "<none>",
	description = "Stops running command or removes it from server queue",
	privs = {worldedit = true},
	func = function(playername, param)
		init_player(playername)
		
		if wpp.data[playername].status == "paused" then
			wpp.data[playername].status = ""
			table.remove(wpp.run_player, 1)
			wpp.data[playername].p = nil
			send_player(playername, "Paused command aborted")
		elseif wpp.data[playername].status == "waiting" then
			wpp.data[playername].status = ""
			table.remove(wpp.run_player, 1)
			wpp.data[playername].p = nil
			send_player(playername, "Command from serverqueue removed")
		elseif wpp.data[playername].status == "running" then
			wpp.data[playername].status = ""
			table.remove(wpp.run_player, 1)
			wpp.data[playername].p = nil
			send_player(playername, "Command aborted")
		else
			send_player(playername, "No command for you found")
		end
	end,
})

minetest.register_chatcommand("pause", {
	params = "<none>",
	description = "Pauses a running command",
	privs = {worldedit = true},
	func = function(playername, param)
		init_player(playername)
		
		if wpp.data[playername].status == "paused" then
			send_player(playername, "Command is already paused")
		elseif wpp.data[playername].status == "running" then
			wpp.data[playername].status = "paused"
			table.remove(wpp.run_player, 1)
			send_player(playername, "Command paused")
		else
			send_player(playername, "No running command for you found")
		end
	end,
})

minetest.register_chatcommand("continue", {
	params = "<none>",
	description = "Continues a paused command",
	privs = {worldedit = true},
	func = function(playername, param)
		init_player(playername)
		
		if wpp.data[playername].status == "paused" then
			wpp.data[playername].status = "waiting"
			table.insert(wpp.run_player, playername)
			send_player(playername, "Command enqueued")
		else
			send_player(playername, "No paused command for you found")
		end
	end,
})
