--Here a stream library by thegrb93 which allows sending large streams of data without overflowing the reliable channel
net.Stream = {}
net.Stream.Queues = {}            --This holds a queue for each player, or one queue for the server if running on the CLIENT
net.Stream.Data = {}            --This holds the data to send        
net.Stream.MaxSendSize = 20000            --This is the maximum size of each stream to send
net.Stream.Timeout = 30            --How long the data should exist in the store without being used before being destroyed
net.Stream.MaxServerQueues = 128  --The maximum number of keep-alives to have queued. This should prevent naughty players from flooding the network with keep-alive messages.
net.Stream.MaxServerStreams = 3200 --Maximum number of streams the player can send to the server. 64 MB

--Send the data sender a request for data
function net.Stream:Request( ply )

	net.Start( "StreamRequest" )
	net.WriteBit( false )
	net.WriteUInt( self.identifier, 32 )
	net.WriteUInt( #self.data, 32 )
	
	--print("Requesting",self.identifier,#self.data)
	
	if CLIENT then net.SendToServer() else net.Send( ply or self.player ) end
	
	timer.Create( "StreamDlTimeout" .. self.identifier, net.Stream.Timeout, 1, function() self:Remove() end )
	
end

--Begin requesting data
function net.Stream:Start( ply )

	if not self.active then
	
		timer.Remove( "StreamKeepAlive" .. self.identifier )
		self.active = true
		self:Request( ply )
		
	end
	
end

--Received data so process it
function net.Stream:Read( len, ply )

	local size = math.floor( len / 8 )
	
	if size == 0 then self:Remove() return end
	--print("Got", size)
	
	self.data[ #self.data + 1 ] = net.ReadData( size )
	if #self.data == self.numstreams then
		self.returndata = util.Decompress( table.concat( self.data ) )
		self:Remove()
	else
		self:Request( ply )
	end

end

--Pop the queue and start the next task
function net.Stream:Remove()
	
	pcall( self.callback, self.returndata )
	
	timer.Remove( "StreamDlTimeout" .. self.identifier )
	table.remove( self.queue, 1 )
	
	if self.queue[ 1 ] then
		self.queue[ 1 ]:Start()
	else
		net.Stream.Queues[ self.player ] = nil
	end
	
end

net.Stream.__index = net.Stream

--Store the data and write the file info so receivers can request it.
function net.WriteStream( data )

	if type( data ) ~= "string" then
		error( "bad argument #1 to 'WriteStream' (string expected, got " .. type( data ) .. ")", 2 )
	end
		
	local compressed = util.Compress( data )
	local identifier = 1
	
	while net.Stream.Data[ identifier ] do
		identifier = identifier + 1
	end
	
	net.Stream.Data[ identifier ] = compressed
	timer.Create( "StreamUlTimeout" .. identifier, net.Stream.Timeout, 1, function() net.Stream.Data[ identifier ] = nil end )
	
	net.WriteUInt( math.ceil( #compressed / net.Stream.MaxSendSize ), 32 )
	net.WriteUInt( identifier, 32 )
	
end

--If the receiver is a player then add it to a queue.
--If the receiver is the server then add it to a queue for each individual player
function net.ReadStream( ply, callback )

	if CLIENT then 
		ply = NULL
	else
		if type( ply ) ~= "Player" then
			error( "bad argument #1 to 'ReadStream' (Player expected, got " .. type( ply ) .. ")", 2 )
		elseif not ply:IsValid() then
			error( "bad argument #1 to 'ReadStream' (Tried to use a NULL entity!)", 2 )
		end
	end
	if type( callback ) ~= "function" then
		error( "bad argument #2 to 'ReadStream' (function expected, got " .. type( callback ) .. ")", 2 )
	end
	
	local queue = net.Stream.Queues[ ply ]
	
	local numstreams = net.ReadUInt( 32 )
	local identifier = net.ReadUInt( 32 )
	--print("Got info", numstreams, identifier)
	
	if SERVER and queue and #queue == net.Stream.MaxServerQueues then
		ErrorNoHalt( "Receiving too many ReadStream requests from ", ply )
		return
	end
		
	if SERVER and numstreams > net.Stream.MaxServerStreams then
		ErrorNoHalt( "ReadStream requests from ", ply, " is too large! ", numstreams * net.Stream.MaxSendSize, "MB" )
		return
	end
		
	if not queue then queue = {} net.Stream.Queues[ ply ] = queue end
		
	local stream = {
		numstreams = numstreams,
		identifier = identifier,
		data = {},
		active = false,
		callback = callback,
		queue = queue,
		player = ply
	}
		
	queue[ #queue + 1 ] = setmetatable( stream, net.Stream )
	if #queue > 1 then
		timer.Create( "StreamKeepAlive" .. identifier, net.Stream.Timeout / 2, 0, function() 
			net.Start( "StreamRequest" )
			net.WriteBit( true )
			net.WriteUInt( identifier, 32 )
		end )
	end
	queue[ 1 ]:Start( ply )
	
end

if SERVER then

	util.AddNetworkString( "StreamRequest" )
	util.AddNetworkString( "StreamDownload" )
	
end

--Stream data is requested
net.Receive( "StreamRequest", function( len, ply )

	local keepalive = net.ReadBit() == 1
	local identifier = net.ReadUInt( 32 )
	local data = net.Stream.Data[ identifier ]
	
	if data then
		timer.Adjust( "StreamUlTimeout" .. identifier, net.Stream.Timeout, 1 )
	end
	
	if not keepalive then

		local index = net.ReadUInt( 32 )
		
		net.Start( "StreamDownload" )
			
		if data then
		
			local start = math.min( index * net.Stream.MaxSendSize + 1, #data )
			local endpos = math.min( start + net.Stream.MaxSendSize - 1, #data )
			local senddata = data:sub( start, endpos )
			
			--print("Responding",#senddata,start,endpos)
			
			net.WriteData( senddata, #senddata )
			
		end
	
		if CLIENT then net.SendToServer() else net.Send( ply ) end
	end
	
end )

--Download the stream data
net.Receive( "StreamDownload", function( len, ply )

	ply = ply or NULL
	local queue = net.Stream.Queues[ ply ]
	if queue and queue[ 1 ] then
	
		queue[ 1 ]:Read( len, ply )
	
	end
	
end )

