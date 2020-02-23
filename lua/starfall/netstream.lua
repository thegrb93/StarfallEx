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

	--print("Requesting",self.identifier,#self.data)

	net.Start("NetStreamRequest")
	net.WriteUInt(self.identifier, 32)
	net.WriteBit(false)
	net.WriteBit(false)
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
		self.returndata = table.concat(self.data)
		if self.compressed then
			self.returndata = util.Decompress(self.returndata)
		end
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
	net.WriteUInt(self.identifier, 32)
	net.WriteBit(false)
	net.WriteBit(true)
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

-- The player wants some data
function net.Stream.WriteStream:Write(ply)
	local progress = self.progress[ply] or 0
	if progress < self.numchunks then
		self.progress[ply] = progress + 1

		net.Start("NetStreamDownload")

		local start = math.min(progress * net.Stream.SendSize + 1, #self.data)
		local endpos = math.min(start + net.Stream.SendSize - 1, #self.data)
		local senddata = string.sub(self.data, start, endpos)

		--print("Responding",#senddata,start,endpos)

		net.WriteData(senddata, #senddata)

		if CLIENT then net.SendToServer() else net.Send(ply) end
	end
end

-- The player notified us they finished downloading or cancelled
function net.Stream.WriteStream:Finished(ply)
	self.progress[ply] = nil
	self.finished[ply] = true
	if self.callback then
		local ok, err = xpcall(self.callback, debug.traceback, ply)
		if not ok then ErrorNoHalt(err) end
	end
end

-- Get player's download progress
function net.Stream.WriteStream:GetProgress(ply)
	return (self.progress[ply] or 0) * net.Stream.SendSize / #self.data
end

-- If the stream owner cancels it, notify everyone who is subscribed
function net.Stream.WriteStream:Remove()
	if SERVER then
		local sendTo = {}
		for ply, _ in pairs(self.progress) do
			self.progress[ply] = nil
			self.finished[ply] = true
			if ply:IsValid() then sendTo[#sendTo+1] = ply end
		end
		net.Start("NetStreamDownload")
		net.Send(sendTo)
	else
		if self.progress[NULL] then
			self.progress[NULL] = nil
			self.finished[NULL] = true
			net.Start("NetStreamDownload")
			net.SendToServer()
		end
	end
	net.Stream.WriteStreams[self.identifier] = nil
end

net.Stream.WriteStream.__index = net.Stream.WriteStream

--Store the data and write the file info so receivers can request it.
function net.WriteStream(data, callback, dontcompress)

	if not isstring(data) then
		error("bad argument #1 to 'WriteStream' (string expected, got " .. type(data) .. ")", 2)
	end
	if callback ~= nil and not isfunction(callback) then
		error("bad argument #2 to 'WriteStream' (function expected, got " .. type(callback) .. ")", 2)
	end

	local compressed = not dontcompress
	if compressed then
		data = util.Compress(data) or ""
	end

	local numchunks = math.ceil(#data / net.Stream.SendSize)
	if numchunks == 0 then
		net.WriteUInt(0, 32)
		return
	end
	
	if CLIENT and numchunks > net.Stream.MaxServerChunks then
		ErrorNoHalt("net.WriteStream request is too large! ", #data/1048576, "MiB")
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
		data = data,
		compressed = compressed,
		numchunks = numchunks,
		callback = callback,
		progress = {},
		finished = {}
	}
	setmetatable(stream, net.Stream.WriteStream)

	net.Stream.WriteStreams[identifier] = stream
	timer.Create("NetStreamWriteTimeout" .. identifier, net.Stream.Timeout, 1, function() stream:Remove() end)

	net.WriteUInt(numchunks, 32)
	net.WriteUInt(identifier, 32)
	net.WriteBool(compressed)

	return stream
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
	if numchunks == nil then
		return
	elseif numchunks == 0 then
		local ok, err = xpcall(callback, debug.traceback, "")
		if not ok then ErrorNoHalt(err) end
		return
	end
	local identifier = net.ReadUInt(32)
	local compressed = net.ReadBool()
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
		identifier = identifier,
		data = {},
		compressed = compressed,
		numchunks = numchunks,
		callback = callback,
		queue = queue,
		player = ply
	}
	setmetatable(stream, net.Stream.ReadStream)

	queue[#queue + 1] = stream
	if #queue > 1 then
		timer.Create("NetStreamKeepAlive" .. identifier, net.Stream.Timeout / 2, 0, function()
			net.Start("NetStreamRequest")
			net.WriteUInt(identifier, 32)
			net.WriteBit(true)
			net.WriteBit(false)
			if CLIENT then net.SendToServer() else net.Send(ply) end
		end)
	else
		stream:Request()
	end

	return stream
end

if SERVER then

	util.AddNetworkString("NetStreamRequest")
	util.AddNetworkString("NetStreamDownload")

end

--Stream data is requested
net.Receive("NetStreamRequest", function(len, ply)

	local identifier = net.ReadUInt(32)
	local keepalive = net.ReadBit() == 1
	local completed = net.ReadBit() == 1
	local stream = net.Stream.WriteStreams[identifier]

	ply = ply or NULL
	if stream and not stream.finished[ply] then
		timer.Adjust("NetStreamWriteTimeout" .. identifier, net.Stream.Timeout, 1)

		if not keepalive then
			if completed then
				stream:Finished(ply)
			else
				stream:Write(ply)
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
