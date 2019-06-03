-------------------------------------------------------------------------------
-- Networking library.
-------------------------------------------------------------------------------

local net = net
local checktype = SF.CheckType
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check

--- Net message library. Used for sending data from the server to the client and back
local net_library = SF.RegisterLibrary("net")

local streams = SF.EntityTable("playerStreams")
local netBurst = SF.EntityTable("NetBurst")
local netBurstGen = SF.BurstGenObject("net", 5, 10, "Regen rate of net message burst in kB/sec.", "The net message burst limit in kB.", 1000)

local instances = {}
SF.AddHook("initialize", function(instance)
	instance.data.net = {
		started = false,
		size = 0,
		data = {},
		receives = {}
	}
	if not netBurst[instance.player] then
		netBurst[instance.player] = netBurstGen:create()
	end
end)

SF.AddHook("cleanup", function (instance)
	instance.data.net.started = false
	instance.data.net.data = {}
end)

if SERVER then
	util.AddNetworkString("SF_netmessage")
end

local function write(instance, func, size, ...)
	instance.data.net.size = instance.data.net.size + size
	instance.data.net.data[#instance.data.net.data + 1] = { func, { ... } }
end

--- Starts the net message
-- @shared
-- @param name The message name
function net_library.start(name)
	checkluatype (name, TYPE_STRING)
	local instance = SF.instance
	if instance.data.net.started then SF.Throw("net message was already started", 2) end

	instance.data.net.started = true
	instance.data.net.size = 8 -- 8 bytes overhead
	instance.data.net.data = {}

	write(instance, net.WriteString, #name, name)
end

--- Send a net message from client->server, or server->client.
--@shared
--@param target Optional target location to send the net message.
--@param unreliable Optional choose whether it's more important for the message to actually reach its destination (false) or reach it as fast as possible (true).
function net_library.send (target, unreliable)
	if unreliable then checkluatype (unreliable, TYPE_BOOL) end
	local instance = SF.instance
	if not instance.data.net.started then SF.Throw("net message not started", 2) end

	if not netBurst[instance.player]:use(instance.data.net.size) then
		SF.Throw("Net message exceeds limit!", 3)
	end

	local data = instance.data.net.data
	if #data == 0 then return false end
	net.Start("SF_netmessage", unreliable)
	net.WriteEntity(SF.instance.data.entity)
	for i = 1, #data do
		data[i][1](unpack(data[i][2]))
	end

	if SERVER then
		local sendfunc, newtarget

		if target then
			if target[1] then
				local nt = { }
				for i = 1, #target do
					local pl = SF.Entities.Unwrap(target[i])
					if IsValid(pl) and pl:IsPlayer() then
						nt[#nt + 1] = pl
					end
				end
				sendfunc, newtarget = net.Send, nt
			else
				sendfunc, newtarget = net.Send, SF.Entities.Unwrap(target)
				if not IsValid(newtarget) or not newtarget:IsPlayer() then SF.Throw("Invalid player", 2) end
			end
		else
			sendfunc = net.Broadcast
		end
		sendfunc(newtarget)
	else
		net.SendToServer()
	end

	instance.data.net.size = 0
	instance.data.net.data = {}
	instance.data.net.started = false
end

local netTypeSizes = {
	[TYPE_NIL]		= function(x) return 1 end,
	[TYPE_STRING]	= function(x) return 1+#x end,
	[TYPE_NUMBER]	= function(x) return 1+8 end,
	[TYPE_BOOL]		= function(x) return 1+1 end,
	[TYPE_ENTITY]	= function(x) return 1+2 end,
	[TYPE_VECTOR]	= function(x) return 1+12 end,
	[TYPE_ANGLE]	= function(x) return 1+12 end,
	[TYPE_MATRIX]	= function(x) return 1+64 end,
	[TYPE_COLOR]	= function(x) return 1+4 end,
}

--- Writes an object to a net message automatically typing it
-- @shared
-- @param v The object to write
function net_library.writeType(v)
	local instance = SF.instance
	if not instance.data.net.started then SF.Throw("net message not started", 2) end

	v = SF.UnwrapObject(v) or v

	local typeid = nil

	if IsColor(v) then
		typeid = TYPE_COLOR
	else
		typeid = TypeID(v)
	end

	local wv = net.WriteVars[typeid]
	if wv then
		if typeid == TYPE_TABLE then
			write(instance, net.WriteUInt, 1, typeid, 8)
			net_library.writeTable(v)
		else
			write(instance, wv, netTypeSizes[typeid](v), typeid, v)
		end
	else
		SF.Throw("net.WriteType: Couldn't write " .. type(v) .. " (type " .. typeid .. ")", 2)
	end
	return true
end

--- Reads an object from a net message automatically typing it
--- Will throw an error if invalid type is read. Make sure to pcall it
-- @shared
-- @return The object
function net_library.readType()
	local typeid = net.ReadUInt(8)

	if typeid == TYPE_TABLE then
		return net_library.readTable()
	else
		local rv = net.ReadVars[typeid]
		if rv then
			local v = rv()
			return SF.WrapObject(v) or v
		end
	end

	SF.Throw("net.readType: Couldn't read type " .. typeid, 2)
end

--- Writes a table to a net message automatically typing it.
-- @shared
-- @param v The object to write
function net_library.writeTable(t)
	for k, v in pairs(t) do
		net_library.writeType(k)
		net_library.writeType(v)
	end
	net_library.writeType(nil)
end

--- Reads an object from a net message automatically typing it
--- Will throw an error if invalid type is read. Make sure to pcall it
-- @shared
-- @return The object
function net_library.readTable()
	local tab = {}
	while true do
		local k = net_library.readType()
		if ( k == nil ) then return tab end
		tab[k] = net_library.readType()
	end
end

--- Writes a string to the net message. Null characters will terminate the string.
-- @shared
-- @param t The string to be written

function net_library.writeString(t)
	local instance = SF.instance
	if not instance.data.net.started then SF.Throw("net message not started", 2) end

	checkluatype (t, TYPE_STRING)

	write(instance, net.WriteString, #t, t)
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

function net_library.writeData(t, n)
	local instance = SF.instance
	if not instance.data.net.started then SF.Throw("net message not started", 2) end

	checkluatype (t, TYPE_STRING)
	checkluatype (n, TYPE_NUMBER)

	n = math.Clamp(n, 0, 64000)
	write(instance, net.WriteData, n, t, n)
	return true
end

--- Reads a string from the net message
-- @shared
-- @param n How many characters are in the data
-- @return The string that was read

function net_library.readData(n)
	checkluatype (n, TYPE_NUMBER)
	n = math.Clamp(n, 0, 64000)
	return net.ReadData(n)
end

--- Streams a large 20MB string.
-- @shared
-- @param str The string to be written
function net_library.writeStream(str)
	local instance = SF.instance
	if not instance.data.net.started then SF.Throw("net message not started", 2) end

	checkluatype (str, TYPE_STRING)
	write(instance, net.WriteStream, 8, str)
	return true
end

--- Reads a large string stream from the net message.
-- @shared
-- @param cb Callback to run when the stream is finished. The first parameter in the callback is the data. Will be nil if transfer fails or is cancelled
function net_library.readStream(cb)
	checkluatype (cb, TYPE_FUNCTION)
	local instance = SF.instance
	if streams[instance.player] then SF.Throw("The previous stream must finish before reading another.", 2) end
	
	streams[instance.player] = net.ReadStream((SERVER and instance.player or nil), function(data)
		instance:runFunction(cb, data)
		streams[instance.player] = nil
	end)
end

--- Cancels a currently running readStream
-- @shared
function net_library.cancelStream()
	local instance = SF.instance
	if not streams[instance.player] then SF.Throw("Not currently reading a stream.", 2) end
	streams[instance.player]:Remove()
end

--- Returns the progress of a running readStream
-- @shared
-- @return The progress ratio 0-1
function net_library.getStreamProgress()
	local instance = SF.instance
	if not streams[instance.player] then SF.Throw("Not currently reading a stream.", 2) end
	return streams[instance.player]:GetProgress()
end

--- Writes an integer to the net message
-- @shared
-- @param t The integer to be written
-- @param n The amount of bits the integer consists of

function net_library.writeInt(t, n)
	local instance = SF.instance
	if not instance.data.net.started then SF.Throw("net message not started", 2) end

	checkluatype (t, TYPE_NUMBER)
	checkluatype (n, TYPE_NUMBER)

	n = math.Clamp(n, 0, 32)
	write(instance, net.WriteInt, math.ceil(n / 8), t, n)
	return true
end

--- Reads an integer from the net message
-- @shared
-- @param n The amount of bits to read
-- @return The integer that was read

function net_library.readInt(n)
	checkluatype (n, TYPE_NUMBER)
	return net.ReadInt(n)
end

--- Writes an unsigned integer to the net message
-- @shared
-- @param t The integer to be written
-- @param n The amount of bits the integer consists of. Should not be greater than 32

function net_library.writeUInt(t, n)
	local instance = SF.instance
	if not instance.data.net.started then SF.Throw("net message not started", 2) end

	checkluatype (t, TYPE_NUMBER)
	checkluatype (n, TYPE_NUMBER)

	n = math.Clamp(n, 0, 32)
	write(instance, net.WriteUInt, math.ceil(n / 8), t, n)
	return true
end

--- Reads an unsigned integer from the net message
-- @shared
-- @param n The amount of bits to read
-- @return The unsigned integer that was read

function net_library.readUInt(n)
	checkluatype (n, TYPE_NUMBER)
	return net.ReadUInt(n)
end

--- Writes a bit to the net message
-- @shared
-- @param t The bit to be written. (boolean)

function net_library.writeBit(t)
	local instance = SF.instance
	if not instance.data.net.started then SF.Throw("net message not started", 2) end

	checkluatype (t, TYPE_BOOL)

	write(instance, net.WriteBit, 1, t)
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

function net_library.writeDouble(t)
	local instance = SF.instance
	if not instance.data.net.started then SF.Throw("net message not started", 2) end

	checkluatype (t, TYPE_NUMBER)

	write(instance, net.WriteDouble, 8, t)
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

function net_library.writeFloat(t)
	local instance = SF.instance
	if not instance.data.net.started then SF.Throw("net message not started", 2) end

	checkluatype (t, TYPE_NUMBER)

	write(instance, net.WriteFloat, 4, t)
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

function net_library.writeAngle(t)
	local instance = SF.instance
	if not instance.data.net.started then SF.Throw("net message not started", 2) end

	checktype(t, SF.Types["Angle"])

	write(instance, net.WriteAngle, 12, SF.Angles.Unwrap(t))
	return true
end

--- Reads an angle from the net message
-- @shared
-- @return The angle that was read

function net_library.readAngle()
	return SF.Angles.Wrap(net.ReadAngle())
end

--- Writes an vector to the net message
-- @shared
-- @param t The vector to be written

function net_library.writeVector(t)
	local instance = SF.instance
	if not instance.data.net.started then SF.Throw("net message not started", 2) end

	checktype(t, SF.Types["Vector"])

	write(instance, net.WriteVector, 12, SF.Vectors.Unwrap(t))
	return true
end

--- Reads a vector from the net message
-- @shared
-- @return The vector that was read

function net_library.readVector()
	return SF.Vectors.Wrap(net.ReadVector())
end

--- Writes an matrix to the net message
-- @shared
-- @param t The matrix to be written

function net_library.writeMatrix(t)
	local instance = SF.instance
	if not instance.data.net.started then SF.Throw("net message not started", 2) end

	checktype(t, SF.Types["VMatrix"])

	write(instance, net.WriteMatrix, 64, SF.VMatrix.Unwrap(t))
	return true
end

--- Reads a matrix from the net message
-- @shared
-- @return The matrix that was read

function net_library.readMatrix()
	return SF.VMatrix.Wrap(net.ReadMatrix())
end

--- Writes an color to the net message
-- @shared
-- @param t The color to be written

function net_library.writeColor(t)
	local instance = SF.instance
	if not instance.data.net.started then SF.Throw("net message not started", 2) end

	checktype(t, SF.Types["Color"])

	write(instance, net.WriteColor, 4, SF.Color.Unwrap(t))
	return true
end

--- Reads a color from the net message
-- @shared
-- @return The color that was read

function net_library.readColor()
	return SF.Color.Wrap(net.ReadColor())
end

--- Writes an entity to the net message
-- @shared
-- @param t The entity to be written

function net_library.writeEntity(t)
	local instance = SF.instance
	if not instance.data.net.started then SF.Throw("net message not started", 2) end

	checktype(t, SF.Types["Entity"])

	write(instance, net.WriteEntity, 2, SF.Entities.Unwrap(t))
	return true
end

--- Reads a entity from the net message
-- @shared
-- @return The entity that was read

function net_library.readEntity()
	return SF.WrapObject(net.ReadEntity())
end

--- Like glua net.Receive, adds a callback that is called when a net message with the matching name is received. If this happens, the net hook won't be called.
-- @shared
-- @param name The name of the net message
-- @param func The callback or nil to remove callback. (len - length of the net message, ply - player that sent it or nil if clientside)
function net_library.receive(name, func)
	checkluatype (name, TYPE_STRING)
	if func~=nil then checkluatype (func, TYPE_FUNCTION) end
	SF.instance.data.net.receives[name] = func
end

--- Returns available bandwidth in bytes
-- @return number of bytes that can be sent
function net_library.getBytesLeft()
	return netBurst[SF.instance.player]:check() - SF.instance.data.net.size
end

--- Returns whether or not the library is currently reading data from a stream
-- @return Boolean
function net_library.isStreaming()
	return streams[SF.instance.player] ~= nil
end

net.Receive("SF_netmessage", function(len, ply)
	local ent = net.ReadEntity()
	if ent:IsValid() and ent.instance and ent.instance.runScriptHook then
		local name = net.ReadString()
		if ply then ply = SF.WrapObject(ply) end

		local recv = ent.instance.data.net.receives[name]
		if recv then
			ent.instance:runFunction(recv, len, ply)
		else
			ent.instance:runScriptHook("net", name, len, ply)
		end
	end
end)

--- Called when a net message arrives
-- @name net
-- @class hook
-- @param name Name of the arriving net message
-- @param len Length of the arriving net message in bytes
-- @param ply On server, the player that sent the message. Nil on client.
