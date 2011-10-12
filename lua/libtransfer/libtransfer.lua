--- LibTransfer
-- @author Colonel Thirty Two
-- A faster/better datastream


if LibTransfer then return end
LibTransfer = {}
if SERVER then AddCSLuaFile("libtransfer.lua") end

-- Helper functions
local function get_add(tbl, key)
	local t = tbl[key]
	if t then return t
	else
		tbl[key] = {}
		return tbl[key]
	end
end

local function pop_queue(queue)
	local t = queue[1]
	for i=2,#queue do
		queue[i-1] = queue[i]
	end
	queue[#queue] = nil
	return t
end

local min = math.min

-- ------------------------------- Variables ------------------------------- --

-- If true, uses datastream to send stuff to client, otherwise uses
-- usermessages + glon.
LibTransfer.useDatastream = false

-- Turns on debugging messages
LibTransfer.debug = false

if CLIENT then
	LibTransfer.queue_s2c = {}
	LibTransfer.queue_c2s = {} -- Job structure: {name, encoded, original, accepted, cursor}
else
	LibTransfer.jobs_s2c = {}
	LibTransfer.jobs_c2s = {}
end

LibTransfer.callbacks = {}

-- ------------------------------- Encoding ------------------------------- --
-- Modified from E2Lib
do
	local enctbl = {}
	local dectbl = {}
	
	do
		-- generate encode/decode lookup tables
		local valid_chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 +-*/#^!?~=@&|.,:(){}[]<>" -- list of "normal" chars that can be transferred without problems
		--local invalid_chars = "'\"\n\\%"
		local hex = { '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F' }
		
		
		for i = 1,#valid_chars do
			local char = valid_chars:sub(i, i)
			enctbl[char] = true
		end
		for byte = 1,255 do
			dectbl[hex[(byte - byte % 16) / 16 + 1] .. hex[byte % 16 + 1]] = string.char(byte)
			if not enctbl[string.char(byte)] then
				enctbl[string.char(byte)] = "%" .. hex[(byte - byte % 16) / 16 + 1] .. hex[byte % 16 + 1]
			else
				enctbl[string.char(byte)] = string.char(byte)
			end
		end
		
		--for i = 1,valid_chars:len() do
		--	local char = valid_chars:sub(i, i)
		--	enctbl[char] = char
		--end
	end
	
	-- escapes special characters
	function LibTransfer.encode(str)
		return str:gsub(".", enctbl)
	end
	
	-- decodes escaped characters
	function LibTransfer.decode(encoded)
		return encoded:gsub("%%(..)", dectbl)
	end
end

function LibTransfer.Hook(name, func)
	LibTransfer.callbacks[name] = func
end

if SERVER then
	-- --------------------------- SERVER --------------------------- --
	function LibTransfer.QueueTask(ply, name, data)
		local queue = get_add(LibTransfer.jobs_s2c, ply:UniqueID())
		
		if LibTransfer.useDatastream then
			if LibTransfer.debug then MsgN("LibTransfer: Beginning datastream S2C download, name = "..name..", ply = "..ply:Nick()) PrintTable(data) end
			datasream.StreamToClients(ply, "libtransfer_s2c_start", {name, data})
		else
			if LibTransfer.debug then MsgN("LibTransfer: Beginning Umsg S2C download, name = "..name..", ply = "..ply:Nick()) PrintTable(data) end
			queue[#queue+1] = {name, glon.encode(data), 0}
			umsg.Start("libtransfer_s2c_start",ply)
				umsg.String(name)
			umsg.End()
		end
	end
	
	-- S2C (Sending)

	local function umsg_send_timer()
		for pid, queue in pairs(LibTransfer.jobs_s2c) do
			local job = queue[1]
			if job then
				local stepend = min(job[3]+251, #job[2])
				
				if LibTransfer.debug then MsgN("LibTransfer: Sending chunk: "..job[2]:sub(job[3]+1,stepend)) end
				
				umsg.Start("libtransfer_s2c_chunk",player.GetByUniqueID(pid))
				umsg.String(job[2]:sub(job[3]+1,stepend))
				umsg.End()
				
				if stepend == #job[2] then
					if LibTransfer.debug then MsgN("LibTransfer: End job "..player.GetByUniqueID(pid):Nick()) end
					umsg.Start("libtransfer_s2c_end",player.GetByUniqueID(pid))
					umsg.End()
					pop_queue(queue)
				end
			end
		end
		return true
	end
	timer.Create("libtransfer_s2c_umsg",0.001,0,umsg_send_timer)

	-- C2S (Recieving)

	-- Console Commands

	local function callback_concmd_begin(ply,cmd,args)
	--	if not LibTransfer.acceptCallbacks[args[1]] then
		if not LibTransfer.callbacks[args[1]] then
			if LibTransfer.debug then MsgN("LibTransfer: Not accepting C2S transfer from player "..ply:Nick().." - no callback for "..args[1]) end
			SendUserMessage("libtransfer_c2s_accepted", ply, args[1], false)
			return
		end
		
		if LibTransfer.debug then MsgN("LibTransfer: Accepting C2S transfer from player "..ply:Nick()..", name = "..args[1]) end
		SendUserMessage("libtransfer_c2s_accepted", ply, args[1], true)
		local queue = get_add(LibTransfer.jobs_c2s, ply:UniqueID())
		queue[#queue+1] = {ply,args[1],""}
	end

	local function callback_concmd_chunk(ply,cmd,args)
		local pid = ply:UniqueID()
		if LibTransfer.jobs_c2s[pid] == nil then
			ErrorNoHalt("LibTransfer Error: Player "..ply:GetName().." sent data but has no queue!")
			return
		end
		if LibTransfer.jobs_c2s[pid][1] == nil then
			ErrorNoHalt("LibTransfer Error: Player "..ply:GetName().." sent data but queue is empty!")
			return
		end
		
		if LibTransfer.debug then MsgN("LibTransfer: Recieved chunk from "..ply:GetName()..": \""..args[1].."\"") end
		local job = LibTransfer.jobs_c2s[pid][1]
		job[3] = job[3] .. args[1]
	end

	local function callback_concmd_end(ply,cmd,args)
		local pid = ply:UniqueID()
		if LibTransfer.jobs_c2s[pid] == nil then
			ErrorNoHalt("LibTransfer Error: Player "..ply:GetName().." tried to end job but has no queue!")
			return
		end
		if LibTransfer.jobs_c2s[pid][1] == nil then
			ErrorNoHalt("LibTransfer Error: Player "..ply:GetName().." tried to end job but queue is empty!")
			return
		end
		
		local job = pop_queue(LibTransfer.jobs_c2s[pid])
		if LibTransfer.debug then
			MsgN("LibTransfer: Finished job from player "..ply:GetName())
			MsgN("Encoded: \""..job[3].."\"")
		end
		LibTransfer.callbacks[job[2]](ply,glon.decode(LibTransfer.decode(job[3])))
	end
	concommand.Add("libtransfer_c2s_begin",callback_concmd_begin)
	concommand.Add("libtransfer_c2s_chunk",callback_concmd_chunk)
	concommand.Add("libtransfer_c2s_end",callback_concmd_end)

	-- Datastream

	local function callback_datastream_accept(ply,handler,id)
		return true
	end
	local function callback_datastream(ply,handler,id,encoded,decoded)
		LibTransfer.callbacks[decoded[1]](ply,decoded[2])
	end
	datastream.Hook("libtransfer_c2s",callback_datastream)
	hook.Add("AcceptStream","libtransfer_c2s_accept",callback_datastream_accept)

	local function callback_erase_queue(ply)
		LibTransfer.jobs_s2c[ply:UniqueID()] = nil
		LibTransfer.jobs_c2s[ply:UniqueID()] = nil
	end

else
	-- --------------------------- CLIENT --------------------------- --
	function LibTransfer.QueueTask(name, data)
		if LibTransfer.useDatastream then
			if LibTransfer.debug then MsgN("LibTransfer:Beginning C2S transfer via datastream, name = "..name) PrintTable(data) end
			datastream.StreamToServer("libtransfer_c2s",data)
		else
			local encoded = LibTransfer.encode(glon.encode(data))
			if LibTransfer.debug then
				MsgN("LibTransfer:Beginning C2S transfer via console commands, name = "..name)
				PrintTable(data)
				MsgN("Encoded: \""..encoded.."\"")
			end
			LibTransfer.queue_c2s[#LibTransfer.queue_c2s+1] = {name, encoded, data, false, 1}
			RunConsoleCommand("libtransfer_c2s_begin", name)
		end
	end
	
	-- C2S ( Sending )

	-- Console commands
	local function callback_concmd_timer()
		local job = LibTransfer.queue_c2s[1]
		if not job or not job[4] then return true end
		
		local newcursor = min(job[5] + 450, #job[2]+1)
		local chunk = job[2]:sub(job[5], newcursor-1)
		
		if LibTransfer.debug then MsgN("LibTransfer:Sending chunk: \""..chunk.."\"") end
		
		job[5] = newcursor
		RunConsoleCommand("libtransfer_c2s_chunk", chunk)
		
		if newcursor == #job[2]+1 then
			RunConsoleCommand("libtransfer_c2s_end")
			pop_queue(LibTransfer.queue_c2s)
		end
		
		return true
	end
	timer.Create("libtransfer_c2s_concommand",0.001,0,callback_concmd_timer)

	local function callback_umsg_accept(data)
		local name = data:ReadString()
		local accepted = data:ReadBool()
		for index,job in ipairs(LibTransfer.queue_c2s) do
			if job[1] == name then
				if accepted then
					if LibTransfer.debug then MsgN("LibTransfer: Job accepted: "..name) end
					job[4] = true
				else
					if LibTransfer.debug then MsgN("LibTransfer: Job rejected: "..name) end
					pop_queue(LibTransfer.queue_c2s,index)
				end
				return
			end
		end
		ErrorNoHalt("LibTransfer Error: Server accepted nonexistant job: "..name)
	end
	usermessage.Hook("libtransfer_c2s_accepted",callback_umsg_accept)

	-- S2C (Recieveing)

	-- Usermessages
	local function callback_umsg_start(data)
		local name = data:ReadString()
		LibTransfer.queue_s2c[#(LibTransfer.queue_s2c)+1] = {name,""}
		
		if LibTransfer.debug then MsgN("LibTransfer: Starting S2C Transfer via usermessages, name = "..name) end
	end
	local function callback_umsg_chunk(data)
		local job = LibTransfer.queue_s2c[1]
		local chunk = data:ReadString()
		job[2] = job[2] .. chunk
		
		if LibTransfer.debug then MsgN("LibTransfer: Read Umsg chunk: "..chunk) end
	end
	local function callback_umsg_end(data)
		local job = pop_queue(LibTransfer.queue_s2c)
		if LibTransfer.debug then MsgN("LibTransfer: End Umsg job") end
		if LibTransfer.callbacks[job[1]] then LibTransfer.callbacks[job[1]](glon.decode(job[2])) end
	end
	usermessage.Hook("libtransfer_s2c_start",callback_umsg_start)
	usermessage.Hook("libtransfer_s2c_chunk",callback_umsg_chunk)
	usermessage.Hook("libtransfer_s2c_end",callback_umsg_end)

	-- Datastream
	local function callback_datastream(handler,id,encoded,decoded)
		local name = decoded[1]
		local data = decoded[2]
		
		if LibTransfer.debug then MsgN("LibTransfer:Recieved datastream job, name = "..data) PrintTable(data) end
		
		LibTransfer.callbacks[name](data)
	end
	datastream.Hook("libtransfer_datastream_s2c",callback_datastream)
end
