-- Global to all starfalls
local net = net
local checkluatype = SF.CheckLuaType

local streams = SF.EntityTable("playerStreams")
local netBurst = SF.BurstObject("net", "net message", 5, 10, "Regen rate of net message burst in kB/sec.", "The net message burst limit in kB.", 1000 * 8)
SF.NetBurst = netBurst

if SERVER then
	util.AddNetworkString("SF_netmessage")
end

net.Receive("SF_netmessage", function(len, ply)
	local ent = net.ReadEntity()
	if ent:IsValid() then
		local instance = ent.instance
		if instance and instance.runScriptHook then
			local name = net.ReadString()
			len = len - 16 - (#name + 1) * 8 -- This gets rid of the 2-byte entity, and the null-terminated string, making this now quantify the length of the user's net message
			instance.data.net.ply = ply
			if ply then ply = instance.Types.Player.Wrap(ply) end

			local recv = instance.data.net.receives[name]
			if recv then
				instance:runFunction(recv, len, ply)
			else
				instance:runScriptHook("net", name, len, ply)
			end
		end
	end
end)


--- Net message library. Used for sending data from the server to the client and back
-- @name net
-- @class library
-- @libtbl net_library
SF.RegisterLibrary("net")


return function(instance)

local getent
local netStarted = false
local netSize = 0
local netData
local netReceives = {}
instance.data.net = {receives = netReceives}
instance:AddHook("initialize", function()
	getent = instance.Types.Entity.GetEntity
end)

instance:AddHook("cleanup", function()
	netStarted = false
	netData = nil
end)


local net_library = instance.Libraries.net
local ents_methods, ent_meta, ewrap, eunwrap = instance.Types.Entity.Methods, instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local col_meta, cwrap, cunwrap = instance.Types.Color, instance.Types.Color.Wrap, instance.Types.Color.Unwrap
local mtx_meta, mwrap, munwrap = instance.Types.VMatrix, instance.Types.VMatrix.Wrap, instance.Types.VMatrix.Unwrap

local function write(func, size, ...)
	netSize = netSize + size
	netData[#netData + 1] = { func, { ... } }
end

--- Starts the net message
-- @shared
-- @param name The message name
function net_library.start(name)
	checkluatype (name, TYPE_STRING)
	if netStarted then SF.Throw("net message was already started", 2) end

	netStarted = true
	netSize = 8*8 -- 8 byte overhead
	netData = {}

	write(net.WriteString, (#name + 1) * 8, name) -- Include null character
end

--- Send a net message from client->server, or server->client.
--@shared
--@param target Optional target location to send the net message.
--@param unreliable Optional choose whether it's more important for the message to actually reach its destination (false) or reach it as fast as possible (true).
function net_library.send(target, unreliable)
	if target~=nil then checkluatype(target, TYPE_TABLE) end
	if unreliable~=nil then checkluatype(unreliable, TYPE_BOOL) end
	if not netStarted then SF.Throw("net message not started", 2) end

	local newtarget
	if SERVER then
		if target then
			newtarget = instance.UnwrapObject(target)
			if newtarget then
				if not (newtarget.IsValid and newtarget.IsPlayer and newtarget:IsValid() and newtarget:IsPlayer()) then SF.Throw("Invalid player", 2) end
			else
				if #target == 0 then SF.Throw("Send array is empty", 2) end
				newtarget = {}
				for i = 1, #target do
					local pl = eunwrap(target[i])
					if pl:IsValid() and pl:IsPlayer() then
						newtarget[i] = pl
					else
						SF.Throw("Invalid player inside send array", 2)
					end
				end
			end
		end
	end

	netBurst:use(instance.player, netSize)

	net.Start("SF_netmessage", unreliable)
	net.WriteEntity(instance.entity)
	local data = netData
	for i = 1, #data do
		local args = data[i][2]
		data[i][1](unpack(args, 1, table.maxn(args)))
	end
	if SERVER then
		if newtarget then
			net.Send(newtarget)
		else
			net.Broadcast()
		end
	else
		net.SendToServer()
	end

	netSize = 0
	netData = {}
	netStarted = false
end

--- Writes an object to a net message automatically typing it
-- @shared
-- @param v The object to write
function net_library.writeType(v)
	if not netStarted then SF.Throw("net message not started", 2) end

	local str = util.Compress(SF.TableToString({v}, instance))
	write(net.WriteUInt, 32, #str, 32)
	write(net.WriteData, #str*8, str, #str)
end

--- Reads an object from a net message automatically typing it
--- Will throw an error if invalid type is read. Make sure to pcall it
-- @shared
-- @return The object
function net_library.readType()
	return SF.StringToTable(util.Decompress(net.ReadData(net.ReadUInt(32))), instance)[1]
end

--- Writes a table to a net message automatically typing it.
-- @shared
-- @param v The object to write
function net_library.writeTable(t)
	if not netStarted then SF.Throw("net message not started", 2) end
	checkluatype(t, TYPE_TABLE)
	
	local str = util.Compress(SF.TableToString(t, instance))
	write(net.WriteUInt, 32, #str, 32)
	write(net.WriteData, #str*8, str, #str)
end

--- Reads an object from a net message automatically typing it
--- Will throw an error if invalid type is read. Make sure to pcall it
-- @shared
-- @return The object
function net_library.readTable()
	return SF.StringToTable(util.Decompress(net.ReadData(net.ReadUInt(32))), instance)
end

--- Writes a string to the net message. Null characters will terminate the string.
-- @shared
-- @param t The string to be written

function net_library.writeString(t)
	if not netStarted then SF.Throw("net message not started", 2) end

	checkluatype (t, TYPE_STRING)

	write(net.WriteString, (#t+1)*8, t)
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
	if not netStarted then SF.Throw("net message not started", 2) end

	checkluatype (t, TYPE_STRING)
	checkluatype (n, TYPE_NUMBER)

	n = math.Clamp(n, 0, 64000)
	write(net.WriteData, n*8, t, n)
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
-- @param compress Compress the data. True by default
function net_library.writeStream(str, compress)
	if not netStarted then SF.Throw("net message not started", 2) end

	checkluatype (str, TYPE_STRING)
	write(net.WriteStream, 8*8, str, nil, not compress)
	return true
end

--- Reads a large string stream from the net message.
-- @shared
-- @param cb Callback to run when the stream is finished. The first parameter in the callback is the data. Will be nil if transfer fails or is cancelled
function net_library.readStream(cb)
	checkluatype (cb, TYPE_FUNCTION)
	if streams[instance.player] then SF.Throw("The previous stream must finish before reading another.", 2) end
	
	local streamOwner, target
	if instance.player ~= SF.Superuser then
		streamOwner = instance.player
		target = instance.player
	else
		streamOwner = SF.Superuser
		target = instance.data.net.ply
	end
	streams[streamOwner] = net.ReadStream((SERVER and target or nil), function(data)
		instance:runFunction(cb, data)
		streams[streamOwner] = nil
	end)
end

--- Cancels a currently running readStream
-- @shared
function net_library.cancelStream()
	if not streams[instance.player] then SF.Throw("Not currently reading a stream.", 2) end
	streams[instance.player]:Remove()
end

--- Returns the progress of a running readStream
-- @shared
-- @return The progress ratio 0-1
function net_library.getStreamProgress()
	if not streams[instance.player] then SF.Throw("Not currently reading a stream.", 2) end
	return streams[instance.player]:GetProgress()
end

--- Writes an integer to the net message
-- @shared
-- @param t The integer to be written
-- @param n The amount of bits the integer consists of
function net_library.writeInt(t, n)
	if not netStarted then SF.Throw("net message not started", 2) end

	checkluatype (t, TYPE_NUMBER)
	checkluatype (n, TYPE_NUMBER)

	n = math.Clamp(n, 0, 32)
	write(net.WriteInt, n, t, n)
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
	if not netStarted then SF.Throw("net message not started", 2) end

	checkluatype (t, TYPE_NUMBER)
	checkluatype (n, TYPE_NUMBER)

	n = math.Clamp(n, 0, 32)
	write(net.WriteUInt, n, t, n)
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
-- @param t The bit to be written. (0 for false, 1 (or anything) for true)
function net_library.writeBit(t)
	if not netStarted then SF.Throw("net message not started", 2) end

	checkluatype (t, TYPE_NUMBER)

	write(net.WriteBit, 1, t~=0)
	return true
end

--- Reads a bit from the net message
-- @shared
-- @return The bit that was read. (0 for false, 1 for true)
function net_library.readBit()
	return net.ReadBit()
end

--- Writes a bool to the net message
-- @shared
-- @param t The bit to be written. (boolean)
function net_library.writeBool(t)
	if not netStarted then SF.Throw("net message not started", 2) end

	checkluatype (t, TYPE_BOOL)

	write(net.WriteBool, 1, t)
	return true
end

--- Reads a boolean from the net message
-- @shared
-- @return The boolean that was read.
function net_library.readBool()
	return net.ReadBool()
end

--- Writes a double to the net message
-- @shared
-- @param t The double to be written
function net_library.writeDouble(t)
	if not netStarted then SF.Throw("net message not started", 2) end

	checkluatype (t, TYPE_NUMBER)

	write(net.WriteDouble, 8*8, t)
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
	if not netStarted then SF.Throw("net message not started", 2) end

	checkluatype (t, TYPE_NUMBER)

	write(net.WriteFloat, 4*8, t)
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
	if not netStarted then SF.Throw("net message not started", 2) end
	write(net.WriteFloat, 4*8, t[1])
	write(net.WriteFloat, 4*8, t[2])
	write(net.WriteFloat, 4*8, t[3])
	return true
end

--- Reads an angle from the net message
-- @shared
-- @return The angle that was read
function net_library.readAngle()
	return awrap(Angle(net.ReadFloat(), net.ReadFloat(), net.ReadFloat()))
end

--- Writes an vector to the net message. Has significantly lower precision than writeFloat
-- @shared
-- @param t The vector to be written
function net_library.writeVector(t)
	if not netStarted then SF.Throw("net message not started", 2) end
	write(net.WriteFloat, 4*8, t[1])
	write(net.WriteFloat, 4*8, t[2])
	write(net.WriteFloat, 4*8, t[3])
	return true
end

--- Reads a vector from the net message
-- @shared
-- @return The vector that was read
function net_library.readVector()
	return vwrap(Vector(net.ReadFloat(), net.ReadFloat(), net.ReadFloat()))
end

--- Writes an matrix to the net message
-- @shared
-- @param t The matrix to be written
function net_library.writeMatrix(t)
	if not netStarted then SF.Throw("net message not started", 2) end
	local vals = {munwrap(t):Unpack()}
	for i=1, 16 do
		write(net.WriteFloat, 4*8, vals[i])
	end
	return true
end

--- Reads a matrix from the net message
-- @shared
-- @return The matrix that was read
function net_library.readMatrix()
	local m = Matrix()
	m:SetUnpacked(net.ReadFloat(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat())
	return mwrap(m)
end

--- Writes an color to the net message
-- @shared
-- @param t The color to be written
function net_library.writeColor(t)
	if not netStarted then SF.Throw("net message not started", 2) end
	write(net.WriteColor, 4*8, cunwrap(t))
	return true
end

--- Reads a color from the net message
-- @shared
-- @return The color that was read
function net_library.readColor()
	return cwrap(net.ReadColor())
end

--- Writes an entity to the net message
-- @shared
-- @param t The entity to be written
function net_library.writeEntity(t)
	if not netStarted then SF.Throw("net message not started", 2) end
	write(net.WriteUInt, 16, getent(t):EntIndex(), 16)
	return true
end

--- Reads a entity from the net message
-- @shared
-- @param callback (Client only) optional callback to be ran whenever the entity becomes valid; returns nothing if this is used. The callback passes the entity if it succeeds or nil if it fails.
-- @return The entity that was read
function net_library.readEntity(callback)
	local index = net.ReadUInt(16)
	if callback ~= nil and CLIENT then
		checkluatype(callback, TYPE_FUNCTION)
		SF.WaitForEntity(index, function(ent)
			if ent ~= nil then ent = instance.WrapObject(ent) end
			instance:runFunction(callback, ent)
		end)
	else
		return instance.WrapObject(Entity(index))
	end
end

--- Like glua net.Receive, adds a callback that is called when a net message with the matching name is received. If this happens, the net hook won't be called.
-- @shared
-- @param name The name of the net message
-- @param func The callback or nil to remove callback. (len - length of the net message, ply - player that sent it or nil if clientside)
function net_library.receive(name, func)
	checkluatype (name, TYPE_STRING)
	if func~=nil then checkluatype (func, TYPE_FUNCTION) end
	netReceives[name] = func
end

--- Returns available bandwidth in bytes
-- @return number of bytes that can be sent
function net_library.getBytesLeft()
	return math.floor((netBurst:check(instance.player) - netSize)/8)
end

--- Returns available bandwidth in bits
-- @return number of bits that can be sent
function net_library.getBitsLeft()
	return math.floor(netBurst:check(instance.player) - netSize) -- Flooring, because the value can be decimal
end

--- Returns whether or not the library is currently reading data from a stream
-- @return Boolean
function net_library.isStreaming()
	return streams[instance.player] ~= nil
end

end

--- Called when a net message arrives
-- @name net
-- @class hook
-- @param name Name of the arriving net message
-- @param len Length of the arriving net message in bits
-- @param ply On server, the player that sent the message. Nil on client.
