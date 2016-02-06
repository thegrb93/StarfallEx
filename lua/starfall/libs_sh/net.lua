-------------------------------------------------------------------------------
-- Networking library.
-------------------------------------------------------------------------------

local net = net

--- Net message library. Used for sending data from the server to the client and back
local net_library, _ = SF.Libraries.Register("net")

local burst_limit = CreateConVar( "sf_net_burst_limit", "10", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
					"The net message burst limit in kB." )

local burst_interval = CreateConVar( "sf_net_burst_interval", "0.1", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
						"The interval of the timer that adds 1kB more available net message." )


local function write( instance, type, size, ... )
	instance.data.net.burst = instance.data.net.burst - size
	if instance.data.net.burst < 0 then
		SF.throw( "Net message exceeds limit!", 3 )
	end
	instance.data.net.data[#instance.data.net.data+1] = { "Write" .. type, {...} }
end

local instances = {}
SF.Libraries.AddHook( "initialize", function( instance )
	instance.data.net = {
		started = false,
		burst = burst_limit:GetInt()*1000,
		last_send = CurTime(),
		data = {},
	}
end)

SF.Libraries.AddHook( "cleanup", function ( instance )
	instance.data.net.started = false
	instance.data.net.data = {}
end )

if SERVER then
	util.AddNetworkString( "SF_netmessage" )
end

--- Starts the net message
-- @shared
-- @param name The message name
function net_library.start( name )
	SF.CheckType( name, "string" )
	local instance = SF.instance
	if instance.data.net.started then SF.throw( "net message was already started", 2) end
	
	instance.data.net.started = true
	instance.data.net.burst = math.min( burst_limit:GetFloat()*1000, instance.data.net.burst + ( CurTime() - instance.data.net.last_send ) / burst_interval:GetFloat() * 1000 )
	instance.data.net.last_send = CurTime()
	instance.data.net.data = {}
	
	write( instance, "String", #name, name )
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
		net[ data[ i ][ 1 ] ]( unpack( data[ i ][ 2 ] ) )
	end

	
	if SERVER then
		local sendfunc, newtarget

		if target then
			if target[1] then
				local nt = { }
				for i = 1, #target do
					local pl = SF.Entities.Unwrap( target[ i ] )
					if IsValid( pl ) and pl:IsPlayer() then
						nt[ #nt + 1 ] = pl
					end
				end
				sendfunc, newtarget = net.Send, nt
			else
				sendfunc, newtarget = net.Send, SF.Entities.Unwrap( target )
				if not IsValid( newtarget ) or not newtarget:IsPlayer() then SF.throw( "Invalid player", 2 ) end
			end
		else
			sendfunc = net.Broadcast
		end
		sendfunc( newtarget )
	else
		net.SendToServer()
	end
	
	instance.data.net.started = false
end

--- Writes a string to the net message. Null characters will terminate the string.
-- @shared
-- @param t The string to be written

function net_library.writeString( t )
	local instance = SF.instance
	if not instance.data.net.started then SF.throw( "net message not started", 2 ) end

	SF.CheckType( t, "string" )

	write( instance, "String", #t, t )
	return true
end

--- Reads a string from the net message
-- @shared
-- @return The string that was read

function net_library.readString()
	return net.ReadString()
end

--- Writes string containing null characters to the net message
-- @shared
-- @param t The string to be written
-- @param n How much of the string to write

function net_library.writeData( t, n )
	local instance = SF.instance
	if not instance.data.net.started then SF.throw( "net message not started", 2 ) end

	SF.CheckType( t, "string" )
	SF.CheckType( n, "number" )

	write( instance, "Data", n, t, n )
	return true
end

--- Reads a string from the net message
-- @shared
-- @param n How many characters are in the data
-- @return The string that was read

function net_library.readData( n )
	SF.CheckType( n, "number" )
	n = math.Clamp( n, 0, 64000 )
	return net.ReadData( n )
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

	write( instance, "Int", math.ceil(n/8), t, n )
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

	write( instance, "UInt", math.ceil(n/8), t, n )
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

	write( instance, "Bit", 1, t )
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

	write( instance, "Double", 8, t )
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

	write( instance, "Float", 4, t )
	return true
end

--- Reads a float from the net message
-- @shared
-- @return The float that was read

function net_library.readFloat()
	return net.ReadFloat()
end

--- Writes an angle to the net message
-- @shared
-- @param t The angle to be written

function net_library.writeAngle( t )
	local instance = SF.instance
	if not instance.data.net.started then SF.throw( "net message not started", 2 ) end

	SF.CheckType( t, SF.Types["Angle"] )

	write( instance, "Angle", 12, SF.Angles.Unwrap( t ) )
	return true
end

--- Reads an angle from the net message
-- @shared
-- @return The angle that was read

function net_library.readAngle()
	return SF.Angles.Wrap( net.ReadAngle() )
end

--- Writes an vector to the net message
-- @shared
-- @param t The vector to be written

function net_library.writeVector( t )
	local instance = SF.instance
	if not instance.data.net.started then SF.throw( "net message not started", 2 ) end

	SF.CheckType( t, SF.Types["Vector"] )

	write( instance, "Vector", 12, SF.Vectors.Unwrap( t ) )
	return true
end

--- Reads a vector from the net message
-- @shared
-- @return The vector that was read

function net_library.readVector()
	return SF.Vectors.Wrap( net.ReadVector() )
end

--- Writes an matrix to the net message
-- @shared
-- @param t The matrix to be written

function net_library.writeMatrix( t )
	local instance = SF.instance
	if not instance.data.net.started then SF.throw( "net message not started", 2 ) end

	SF.CheckType( t, SF.Types["VMatrix"] )

	write( instance, "Matrix", 64, SF.VMatrix.Unwrap( t ) )
	return true
end

--- Reads a matrix from the net message
-- @shared
-- @return The matrix that was read

function net_library.readMatrix()
	return SF.VMatrix.Wrap( net.ReadMatrix() )
end

--- Writes an color to the net message
-- @shared
-- @param t The color to be written

function net_library.writeColor( t )
	local instance = SF.instance
	if not instance.data.net.started then SF.throw( "net message not started", 2 ) end

	SF.CheckType( t, SF.Types["Color"] )

	write( instance, "Color", 4, SF.Color.Unwrap( t ) )
	return true
end

--- Reads a color from the net message
-- @shared
-- @return The color that was read

function net_library.readColor()
	return SF.Color.Wrap( net.ReadColor() )
end

--- Writes an entity to the net message
-- @shared
-- @param t The entity to be written

function net_library.writeEntity( t )
	local instance = SF.instance
	if not instance.data.net.started then SF.throw( "net message not started", 2 ) end

	SF.CheckType( t, SF.Types["Entity"] )

	write( instance, "Entity", 2, SF.UnwrapObject( t ) )
	return true
end

--- Reads a entity from the net message
-- @shared
-- @return The entity that was read

function net_library.readEntity()
	return SF.WrapObject( net.ReadEntity() )
end

--- Returns available bandwidth in bytes
-- @return number of bytes that can be sent
function net_library.getBytesLeft()
	return SF.instance.data.net.burst
end

net.Receive( "SF_netmessage", function( len, ply )
	local ent = net.ReadEntity()
	if ent:IsValid() and ent.runScriptHook then
		if ent.instance then
			ent:runScriptHook( "net", net.ReadString(), len, ply and SF.WrapObject( ply ) )
		else
			ent:Error( "Received net message before instance was initialized." )
		end
	end
end)

--- Called when a net message arrives
-- @name net
-- @class hook
-- @param name Name of the arriving net message
-- @param len Length of the arriving net message in bytes
-- @param ply On server, the player that sent the message. Nil on client.
