LibTransfer = LibTransfer or {}

--------------------------------- Variables ---------------------------------

-- If true, uses datastream to send stuff to client, otherwise uses
-- usermessages + glon.
LibTransfer.useDatastream = false
LibTransfer.jobs_s2c = {}
LibTransfer.jobs_c2s = {}

LibTransfer.callbacks = {}

--------------------------------- Methods ---------------------------------
-- Developers should look here

-- Adds a send task to the queue.
-- ply  = Recipient
-- name = Task name
-- data = A table of data to send
function LibTransfer:QueueTask(ply, name, data)
	local queue = get_add(self.jobs_s2c, ply:UniqueID())
	
	if self.useDatastream then
		datasream.StreamToClients(ply, "libtransfer_s2c_start", {name, data})
	else
		queue[#queue+1] = {name, glon.encode(data), 0}
	end
end

-- Sets the function to be called when a task with the specified name is completed.
function LibTransfer:SetCallback(name, func)
	self.callbacks[name] = func
end

--------------------------------- Encoding ---------------------------------
-- Copied from E2Lib
do
	local enctbl = {}
	local dectbl = {}
	
	do
		-- generate encode/decode lookup tables
		--local valid_chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 +-*/#^!?~=@&|.,:(){}[]<>" -- list of "normal" chars that can be transferred without problems
		local invalid_chars = "'\"\n\\%"
		local hex = { '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F' }
		
		
		for i = 1,invalid_chars:len() do
			local char = invalid_chars:sub(i, i)
			enctbl[char] = true
		end
		for byte = 1,255 do
			dectbl[hex[(byte - byte % 16) / 16 + 1] .. hex[byte % 16 + 1]] = string.char(byte)
			if enctbl[string.char(byte)] then
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

--------------------------------- Server To Client (Sending) ---------------------------------

local min = math.min
local function umsg_send_timer()
	for pid, queue in pairs(jobs_s2c) do
		local job = queue[1]
		if job then
			local stepend = min(job[3]+251, #job[2])
			
			umsg.Start("libtransfer_s2c_chunk",player.GetByUniqueID(pid))
			umsg.String(job[2]:sub(job[3]+1,stepend))
			umsg.End()
			
			if stepend == #job[2] then
				umsg.Start("libtransfer_s2c_end",player.GetByUniqueID(pid))
				umsg.End()
				pop_queue(queue)
			end
		end
	end
	return true
end
timer.Create("libtransfer_s2c_umsg",0.001,0,umsg_send_timer)

--------------------------------- Client To Server (Recieving) ---------------------------------

-- Console Commands

local fucntion callback_concmd_begin(ply,cmd,args)
--	if not LibTransfer.acceptCallbacks[args[0]] then
	if not LibTransfer.callbacks[args[0]] then
		SendUserMessage("libtransfer_c2s_accepted", args[0], ply, false)
		return
	end
	
	SendUserMessage("libtransfer_c2s_accepted", args[0], ply, true)
	local queue = get_add(LibTransfer.jobs_c2s, ply:UniqueID())
	queue[#queue+1] = {ply,args[0],""}
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
	LibTransfer.callbacks[job[2]](ply,job[3])
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
