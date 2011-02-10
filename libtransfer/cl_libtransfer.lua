LibTransfer = LibTransfer or {}

-- If true, uses datastream to send stuff to client, otherwise uses
-- usermessages + glon.
LibTransfer.useDatastream = false
LibTransfer.queue_s2c = {}
LibTransfer.queue_c2s = {}

LibTransfer.callbacks = {}

function LibTransfer:QueueTask(name, data)
	RunConsoleCommand(
end

function LibTransfer:SetCallback(name, func)
	self.callbacks[name] = func
end


-- From E2Lib
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

local function pop_queue(queue)
	local t = queue[1]
	for i=2,#queue do
		queue[i-1] = queue[i]
	end
	queue[#queue] = nil
	return t
end

local function callback_concmd_timer()
	local job = LibTransfer.queue_c2s[1]
	if not job then return true end
	
	
end

local function callback_datastream(handler,id,encoded,decoded)
	local name = decoded[1]
	local data = decoded[2]
	LibTransfer.callbacks[name](data)
end
datastream.Hook("libtransfer_datastream_s2c",callback_datastream)

local function callback_umsg_start(data)
	local name = data:ReadString()
	LibTransfer.queue_s2c[#(LibTransfer.queue_s2c)+1] = {name,""}
end
local function callback_umsg_chunk(data)
	local job = LibTransfer.queue_s2c[1]
	job[2] = job[2] .. data.ReadString()
end
local function callback_umsg_end(data)
	local job = pop_queue(LibTransfer.queue_s2c)
	LibTransfer.callbacks[job[1]](glon.decode(job[2]))
end
usermessage.Hook("libtransfer_s2c_start",callback_umsg_start)
usermessage.Hook("libtransfer_s2c_chunk",callback_umsg_chunk)
usermessage.Hook("libtransfer_s2c_end",callback_umsg_end)