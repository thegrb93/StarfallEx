-------------------------------------------------------------------------------
-- Networking library.
-------------------------------------------------------------------------------

local net = net

--- Net message library. Used for sending data from the server to the client and back
local net_library, _ = SF.Libraries.Register("net")

local burst_limit = CreateConVar( "sf_net_burst_limit", "10", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
					"The net message burst limit." )

local burst_interval = CreateConVar( "sf_net_burst_interval", "0.1", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
						"The interval of the timer that adds one more available net message. Requires a map reload to update." )

local function can_send( instance, noupdate )
	if instance.data.net.burst > 0 then
		if not noupdate then instance.data.net.burst = instance.data.net.burst - 1 end
		return true
	else
		return false
	end
end

local function write( instance, type, value, setting )
	instance.data.net.data[#instance.data.net.data+1] = { "Write" .. type, value, setting }
end

local instances = {}
SF.Libraries.AddHook( "initialize", function( instance )
	instance.data.net = {
		started = false,
		burst = burst_limit:GetInt(),
		data = {},
	}
	
	instances[instance] = true
end)

SF.Libraries.AddHook( "deinitialize", function( instance )
	if instance.data.net.started then
		instance.data.net.started = false
	end
	
	instances[instance] = nil
end)

timer.Create( "SF_Net_BurstCounter", burst_interval:GetFloat(), 0, function()
	for instance, b in pairs( instances ) do
		if instance.data.net.burst < burst_limit:GetInt() then
			instance.data.net.burst = instance.data.net.burst + 1
		end
	end
end)

if SERVER then
	util.AddNetworkString( "SF_netmessage" )
end

--- Send a net message from client->server, or server->client.
--@shared
--@param target Optional target location to send the net message.
function net_library.send ( target )
	local instance = SF.instance
	if not instance.data.net.started then SF.throw( "net message not started", 2 ) end

	local data = instance.data.net.data
	if #data == 0 then return false end
	net.Start( "SF_netmessage" )
	net.WriteEntity( SF.instance.data.entity )
	for i = 1, #data do
		local writefunc = data[ i ][ 1 ]
		local writevalue = data[ i ][ 2 ]
		local writesetting = data[ i ][ 3 ]

		net[ writefunc ]( writevalue, writesetting )
	end

	if SERVER then
		local sendfunc
		local newtarget

		if target then
			if SF.GetType( target ) == "table" then
				local nt = { }
				for i = 1, #target do
					SF.CheckType( SF.Entities.Unwrap( target[ i ] ), "Player", 1 )
					nt[ i ] = SF.Entities.Unwrap( target[ i ] )
				end
				sendfunc, newtarget = net.Send, nt
			else
				SF.CheckType( SF.Entities.Unwrap( target ), "Player", 1 ) -- TODO: unhacky this
				sendfunc, newtarget = net.Send, SF.Entities.Unwrap( target )
			end
		else
			sendfunc = net.Broadcast
		end

		sendfunc( newtarget )
	else
		net.SendToServer()
	end
end

--- Starts the net message
-- @shared
-- @param name The message name
function net_library.start( name )
	SF.CheckType( name, "string" )
	local instance = SF.instance
	if not can_send( instance ) then return SF.throw( "can't send net messages that often", 2 ) end
	
	instance.data.net.started = true
	instance.data.net.data = {}
	write( instance, "String", name )
end

--- Blacklist for net messages.
-- If an item with the same type as the key is found, then it will throw an error.
-- Key must be exactly as is reported by type( var ) otherwise it won't catch it.
local blacklist = {
	[ "VMatrix" ] = true
}

local function checkTblForBlacklist ( t )
	for _, v in pairs( t ) do
		if type( v ) == "table" and not SF.UnwrapObject( v ) then
			checkTblForBlacklist( v )
		else
			local typmeta = getmetatable( v )
			local typ = type( typmeta ) == "string" and typmeta or type( v )
			if blacklist[ typ ] then
				SF.throw( "Item of type " .. typ .. " cannot be sent through a net message", 3 )
			end
		end
	end
end

--- Writes a table to the net message
-- @shared
-- @param t The table to be written. This will be checked for blacklisted types. eg VMatrix.
function net_library.writeTable( t )
	local instance = SF.instance
	if not instance.data.net.started then SF.throw( "net message not started", 2 ) end
	
	SF.CheckType( t, "table" )

	checkTblForBlacklist( t )

	write( instance, "Table", SF.Unsanitize(t) )
	return true
end

--- Reads a table from the net message
-- @shared
-- @return The table that was read

function net_library.readTable()
	return SF.Sanitize(net.ReadTable())
end

--- Writes a string to the net message
-- @shared
-- @param t The string to be written

function net_library.writeString( t )
	local instance = SF.instance
	if not instance.data.net.started then SF.throw( "net message not started", 2 ) end

	SF.CheckType( t, "string" )

	write( instance, "String", t )
	return true
end

--- Reads a string from the net message
-- @shared
-- @return The string that was read

function net_library.readString()
	return net.ReadString()
end

--- Writes an integer to the net message
-- @shared
-- @param t The integer to be written
-- @param n The amount of bits the integer consists of

function net_library.writeInt( t, n )
	local instance = SF.instance
	if not instance.data.net.started then SF.throw( "net message not started", 2 ) end

	SF.CheckType( t, "number" )
	SF.CheckType( n, "number" )

	write( instance, "Int", t, n )
	return true
end

--- Reads an integer from the net message
-- @shared
-- @param n The amount of bits to read
-- @return The integer that was read

function net_library.readInt(n)
	SF.CheckType( n, "number" )
	return net.ReadInt(n)
end

--- Writes an unsigned integer to the net message
-- @shared
-- @param t The integer to be written
-- @param n The amount of bits the integer consists of. Should not be greater than 32

function net_library.writeUInt( t, n )
	local instance = SF.instance
	if not instance.data.net.started then SF.throw( "net message not started", 2 ) end

	SF.CheckType( t, "number" )
	SF.CheckType( n, "number" )

	write( instance, "UInt", t, n )
	return true
end

--- Reads an unsigned integer from the net message
-- @shared
-- @param n The amount of bits to read
-- @return The unsigned integer that was read

function net_library.readUInt(n)
	SF.CheckType( n, "number" )
	return net.ReadUInt(n)
end

--- Writes a bit to the net message
-- @shared
-- @param t The bit to be written. (boolean)

function net_library.writeBit( t )
	local instance = SF.instance
	if not instance.data.net.started then SF.throw( "net message not started", 2 ) end

	SF.CheckType( t, "boolean" )

	write( instance, "Bit", t )
	return true
end

--- Reads a bit from the net message
-- @shared
-- @return The bit that was read. (0 for false, 1 for true)

function net_library.readBit()
	return net.ReadBit()
end

--- Writes a double to the net message
-- @shared
-- @param t The double to be written

function net_library.writeDouble( t )
	local instance = SF.instance
	if not instance.data.net.started then SF.throw( "net message not started", 2 ) end

	SF.CheckType( t, "number" )

	write( instance, "Double", t )
	return true
end

--- Reads a double from the net message
-- @shared
-- @return The double that was read

function net_library.readDouble()
	return net.ReadDouble()
end

--- Writes a float to the net message
-- @shared
-- @param t The float to be written

function net_library.writeFloat( t )
	local instance = SF.instance
	if not instance.data.net.started then SF.throw( "net message not started", 2 ) end

	SF.CheckType( t, "number" )

	write( instance, "Float", t )
	return true
end

--- Reads a float from the net message
-- @shared
-- @return The float that was read

function net_library.readFloat()
	return net.ReadFloat()
end

--- Gets the amount of bytes written so far
-- @return The amount of bytes written so far

function net_library.bytesWritten()
	local instance = SF.instance
	if not instance.data.net.started then SF.throw( "net message not started", 2 ) end

	return net.BytesWritten()
end

--- Checks whether you can currently send a net message
-- @return A boolean that states whether or not you can currently send a net message

function net_library.canSend()
	return can_send(SF.instance, true)
end

net.Receive( "SF_netmessage", function( len, ply )
	local ent = net.ReadEntity()
	if ent:IsValid() and ent:GetClass() == "starfall_screen" then
		ent:runScriptHook( "net", net.ReadString(), len, ply and SF.WrapObject( ply ) )
	end
end)

--- Called when a net message arrives
-- @name net
-- @class hook
-- @param name Name of the arriving net message
-- @param len Length of the arriving net message in bytes
-- @param ply On server, the player that sent the message. Nil on client.
