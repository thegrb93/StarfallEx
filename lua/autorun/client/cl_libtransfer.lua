LibTransfer = LibTransfer or {}

--------------------------------- Variables ---------------------------------

-- If true, uses datastream to send stuff to client, otherwise uses
-- usermessages + glon.
LibTransfer.useDatastream = false

-- Turns on debugging messages
LibTransfer.debug = false

LibTransfer.queue_s2c = {}
LibTransfer.queue_c2s = {} -- Job structure: {name, encoded, original, accepted, cursor}

LibTransfer.callbacks = {}

--------------------------------- Methods ---------------------------------

function LibTransfer:QueueTask(name, data)
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

function LibTransfer:SetCallback(name, func)
	self.callbacks[name] = func
end


--------------------------------- Encoding ---------------------------------
-- Modified from E2Lib
do
	local enctbl = {}
	local dectbl = {}
	
	do
		-- generate encode/decode lookup tables
		local valid_chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 +-*/#^!?~=@&|.,:(){}[]<>" -- list of "normal" chars that can be transferred without problems
		--local invalid_chars = "'\"\n\\%"
		local hex = { '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F' }
		
		
		for i = 1,valid_chars:len() do
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

local function pop_queue(queue,index)
	if not index then index = 1 end
	local t = queue[index]
	for i=index+1,#queue do
		queue[i-1] = queue[i]
	end
	queue[#queue] = nil
	return t
end

--------------------------------- Client to Server (Sending) ---------------------------------

local min = math.min

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

--------------------------------- Server to Client (Recieving) ---------------------------------

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