LibTransfer = LibTransfer or {}

LibTransfer.useDatastream = true
LibTransfer.jobs = {}

local function get_add(tbl, key)
	local t = tbl[key]
	if t then return t
	else
		tbl[key] = {}
		return tbl[key]
	end
end

LibTransfer:QueueTask(ply, name, data)
	local queue = get_add(self.jobs, ply)
	queue[#queue+1] = {name, "download", data}
end