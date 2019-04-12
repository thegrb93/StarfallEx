--Here a stream library by thegrb93 which allows sending large streams of data without overflowing the reliable channel
net.Stream = {}
net.Stream.ReadStreamQueues = {}            --This holds a read stream for each player, or one read stream for the server if running on the CLIENT
net.Stream.WriteStreams = {}            --This holds the write streams
net.Stream.SendSize = 20000            --This is the maximum size of each stream to send
net.Stream.Timeout = 30            --How long the data should exist in the store without being used before being destroyed
net.Stream.MaxServerReadStreams = 128  --The maximum number of keep-alives to have queued. This should prevent naughty players from flooding the network with keep-alive messages.
net.Stream.MaxServerChunks = 3200 --Maximum number of pieces the stream can send to the server. 64 MB

net.Stream.ReadStream = {}
--Send the data sender a request for data
function net.Stream.ReadStream:Request()

	net.Start("NetStreamRequest")
	net.WriteBit(false)
	net.WriteBit(false)
	net.WriteUInt(self.identifier, 32)
	net.WriteUInt(#self.data, 32)

	--print("Requesting",self.identifier,#self.data)

	if CLIENT then net.SendToServer() else net.Send(self.player) end

	timer.Create("NetStreamReadTimeout" .. self.identifier, net.Stream.Timeout, 1, function() self:Remove() end)

end

--Received data so process it
function net.Stream.ReadStream:Read(len)

	local size = math.floor(len / 8)
	--print("Got", size)

	if size == 0 then self:Remove() return end

	self.data[#self.data + 1] = net.ReadData(size)
	if #self.data == self.numchunks then
		self.returndata = util.Decompress(table.concat(self.data))
		self:Remove()
	else
		self:Request()
	end

end

--Gets the download progress
function net.Stream.ReadStream:GetProgress()
	return #self.data/self.numchunks
end

--Pop the queue and start the next task
function net.Stream.ReadStream:Remove()

	local ok, err = xpcall(self.callback, debug.traceback, self.returndata)
	if not ok then ErrorNoHalt(err) end

	net.Start("NetStreamRequest")
	net.WriteBit(false)
	net.WriteBit(true)
	net.WriteUInt(self.identifier, 32)
	if CLIENT then net.SendToServer() else net.Send(self.player) end

	timer.Remove("NetStreamReadTimeout" .. self.identifier)
	table.remove(self.queue, 1)

	local nextInQueue = self.queue[1]
	if nextInQueue then
		timer.Remove("NetStreamKeepAlive" .. nextInQueue.identifier)
		nextInQueue:Request()
	else
		net.Stream.ReadStreamQueues[self.player] = nil
	end

end

net.Stream.ReadStream.__index = net.Stream.ReadStream

net.Stream.WriteStream = {}

function net.Stream.WriteStream:Write(ply, index)
	self.progress[ply] = index

	net.Start("NetStreamDownload")

	local start = math.min(index * net.Stream.SendSize + 1, #self.data)
	local endpos = math.min(start + net.Stream.SendSize - 1, #self.data)
	local senddata = string.sub(self.data, start, endpos)

	--print("Responding",#senddata,start,endpos)

	net.WriteData(senddata, #senddata)

	if CLIENT then net.SendToServer() else net.Send(ply) end
end

function net.Stream.WriteStream:Finished(ply)
	self.finished[ply] = true
	if self.callback then
		local ok, err = xpcall(self.callback, debug.traceback, ply)
		if not ok then ErrorNoHalt(err) end
	end
end

function net.Stream.WriteStream:GetProgress(ply)
	return (self.progress[ply] or 0) * net.Stream.SendSize / #self.data
end

function net.Stream.WriteStream:Remove()
	net.Stream.WriteStreams[self.identifier] = nil
end

net.Stream.WriteStream.__index = net.Stream.WriteStream

--Store the data and write the file info so receivers can request it.
function net.WriteStream(data, callback)

	if not isstring(data) then
		error("bad argument #1 to 'WriteStream' (string expected, got " .. type(data) .. ")", 2)
	end
	if callback ~= nil and not isfunction(callback) then
		error("bad argument #2 to 'WriteStream' (function expected, got " .. type(callback) .. ")", 2)
	end

	local compressed = util.Compress(data) or ""
	local numchunks = math.ceil(#compressed / net.Stream.SendSize)
	
	if CLIENT and numchunks > net.Stream.MaxServerChunks then
		ErrorNoHalt("net.WriteStream request is too large! ", #compressed/1048576, "MiB")
		net.WriteUInt(0, 32)
		net.WriteUInt(0, 32)
		return
	end
	
	local identifier = 1
	while net.Stream.WriteStreams[identifier] do
		identifier = identifier + 1
	end

	local stream = {
		identifier = identifier,
		data = compressed,
		callback = callback,
		progress = {},
		finished = {}
	}

	net.Stream.WriteStreams[identifier] = setmetatable(stream, net.Stream.WriteStream)
	timer.Create("NetStreamWriteTimeout" .. identifier, net.Stream.Timeout, 1, function() stream:Remove() end)

	net.WriteUInt(numchunks, 32)
	net.WriteUInt(identifier, 32)

end

--If the receiver is a player then add it to a queue.
--If the receiver is the server then add it to a queue for each individual player
function net.ReadStream(ply, callback)

	if CLIENT then
		ply = NULL
	else
		if type(ply) ~= "Player" then
			error("bad argument #1 to 'ReadStream' (Player expected, got " .. type(ply) .. ")", 2)
		elseif not ply:IsValid() then
			error("bad argument #1 to 'ReadStream' (Tried to use a NULL entity!)", 2)
		end
	end
	if not isfunction(callback) then
		error("bad argument #2 to 'ReadStream' (function expected, got " .. type(callback) .. ")", 2)
	end

	local queue = net.Stream.ReadStreamQueues[ply]

	local numchunks = net.ReadUInt(32)
	if numchunks == nil then return end
	local identifier = net.ReadUInt(32)
	--print("Got info", numchunks, identifier)

	if SERVER and queue and #queue == net.Stream.MaxServerReadStreams then
		ErrorNoHalt("Receiving too many ReadStream requests from ", ply)
		return
	end

	if SERVER and numchunks > net.Stream.MaxServerChunks then
		ErrorNoHalt("ReadStream requests from ", ply, " is too large! ", numchunks * net.Stream.SendSize / 1048576, "MiB")
		return
	end

	if not queue then queue = {} net.Stream.ReadStreamQueues[ply] = queue end

	local stream = {
		numchunks = numchunks,
		identifier = identifier,
		data = {},
		callback = callback,
		queue = queue,
		player = ply
	}

	queue[#queue + 1] = setmetatable(stream, net.Stream.ReadStream)
	if #queue > 1 then
		timer.Create("NetStreamKeepAlive" .. identifier, net.Stream.Timeout / 2, 0, function()
			net.Start("NetStreamRequest")
			net.WriteBit(true)
			net.WriteBit(false)
			net.WriteUInt(identifier, 32)
			if CLIENT then net.SendToServer() else net.Send(ply) end
		end)
	else
		queue[1]:Request()
	end

end

if SERVER then

	util.AddNetworkString("NetStreamRequest")
	util.AddNetworkString("NetStreamDownload")

end

--Stream data is requested
net.Receive("NetStreamRequest", function(len, ply)

	local keepalive = net.ReadBit() == 1
	local completed = net.ReadBit() == 1
	local identifier = net.ReadUInt(32)
	local stream = net.Stream.WriteStreams[identifier]

	ply = ply or NULL
	if stream and not stream.finished[ply] then
		timer.Adjust("NetStreamWriteTimeout" .. identifier, net.Stream.Timeout, 1)

		if not keepalive then
			if completed then
				stream:Finished(ply)
			else
				local index = net.ReadUInt(32)
				stream:Write(ply, index)
			end

		end
	end
	
end)

--Download the stream data
net.Receive("NetStreamDownload", function(len, ply)

	ply = ply or NULL
	local queue = net.Stream.ReadStreamQueues[ply]
	if queue and queue[1] then

		queue[1]:Read(len)

	end

end)
