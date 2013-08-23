-------------------------------------------------------------------------------
-- Networking library.
-------------------------------------------------------------------------------

local net = net

--- Net message library. Used for sending data from the server to the client and back
local net_library, _ = SF.Libraries.Register("net")

local function can_send( instance )
	if instance.data.net.lasttime < CurTime() - 1 then
		instance.data.net.lasttime = CurTime()
		return true
	else
		return false
	end
end

local function write( instance, type, value, setting )
	instance.data.net.data[#instance.data.net.data+1] = { "Write" .. type, value, setting }
end

if SERVER then
	util.AddNetworkString( "SF_netmessage" )

	SF.Libraries.AddHook( "initialize", function( instance )
		instance.data.net = {
			started = false,
			lasttime = 0,
			data = {},
		}
	end)
	
	SF.Libraries.AddHook( "deinitialize", function( instance )
		if instance.data.net.started then
			instance.data.net.started = false
		end
	end)
	
	local function checktargets( target )
		if target then
			if type(target) == "table" then
				local newtarget = {}
				for i=1,#target do
					SF.CheckType( SF.Unwrap(target[i]), "Player" )
					newtarget[i] = SF.Unwrap(target[i])
				end
				return net.Send, newtarget
			else
				SF.CheckType( SF.Unwrap(target), "Player" )
				return net.Send, SF.Unwrap(target)
			end
		else
			return net.Broadcast
		end
	end
	
	function net_library.send( target )
		local instance = SF.instance
		if not instance.data.net.started then error("net message not started",2) end
		
		local sendfunc, newtarget = checktargets( target )
		
		local data = instance.data.net.data
		if #data == 0 then return false end
		net.Start( "SF_netmessage" )
		for i=1,#data do
			local writefunc = data[i][1]
			local writevalue = data[i][2]
			local writesetting = data[i][3]
			
			net[writefunc]( writevalue, writesetting )
		end
		
		sendfunc( newtarget )
	end
else
	function net_library.send()
		local instance = SF.instance
		if not instance.data.net.started then error("net message not started",2) end
		
		local data = instance.data.net.data
		if #data == 0 then return false end
		net.Start( "SF_netmessage" )
		for i=1,#data do
			local writefunc = data[i][1]
			local writevalue = data[i][2]
			local writesetting = data[i][3]
			
			net[writefunc]( writevalue, writesetting )
		end
		
		net.SendToServer()
	end
end

function net_library.start( name )
	SF.CheckType( name, "string" )
	local instance = SF.instance
	if not can_send( instance ) then return error("can't send net messages that often",2) end
	
	instance.data.net.started = true
	instance.data.net.data = {}
	write( instance, "String", name )
end

function net_library.writeTable( t )
	local instance = SF.instance
	if not instance.data.net.started then error("net message not started",2) end
	
	SF.CheckType( t, "table" )
	
	--write( instance, "Table", SF.Unsanitize(t) )
	write( instance, "Table", t )
	return true
end

function net_library.readTable()
	--return SF.Sanitize(net.ReadTable())
	return net.ReadTable()
end

net.Receive( "SF_netmessage", function( len )
	SF.RunScriptHook( "net", net.ReadString(), len )
end)

--[[
--- Called when a usermessage is recieved
-- @name umsg
-- @class hook
-- @param data The umsg object

if SERVER then
	-- -------------------------------------------------------------- --
	-- SERVER
	
	SF.Libraries.AddHook("initialize",function(inst)
		inst.data.umsg = {
			used = false,
			amount = 0,
			entering = false,
		}
	end)
	
	SF.Libraries.AddHook("deinitialize",function(inst,iserr,msg)
		if inst.data.umsg.entering then
			umsg.End()
			inst.data.umsg.entering = false
		end
	end)
	
	SF.Libraries.AddHook("resetOps",function(inst)
		inst.data.umsg.used = false
		inst.data.umsg.amount = 0
	end)
	
	local function incrBytes(umsgd, bytes)
		local used = umsgd.amount
		used = used + bytes
		if used > 255 then return false end
		umsgd.amount = used
		return true
	end
	
	--- Starts a usermessage
	-- @param recipients nil for all players, or a player/array of players to send umsg to
	-- @server
	function umsg_library.start(recipients)
		local umsgdata = SF.instance.data.umsg
		if umsgdata.used then return false, "umsg quota exceeded" end
		
		local filter
		if not recipients then
			filter = nil
		elseif SF.Entities.Unwrap(recipients) then
			local ent = SF.Entities.Unwrap(recipients)
			if not ent:IsPlayer() then return false, "entity is not player" end
			filter = ent
		elseif type(recipients) == "table" then
			filter = CRecipientFilter()
			for i=1,#recipients do
				local ent = SF.Entities.Unwrap(recipients[i])
				if isValid(ent) and ent:IsPlayer() then
					filter:AddPlayer(ent)
				end
			end
		else
			SF.CheckType(recipients,"nil, player, or table")
		end
		
		umsgdata.entering = true
		umsgdata.used = true
		umsg.Start("sf_umsg_extension",filter)
	end
	
	--- Fetches the number of bytes used. Maximum is 255.
	-- @return Bytes used or -1 if not in a umsg
	-- @server
	function umsg_library.getBytesUsed()
		local umsgdata = SF.instance.data.umsg
		return umsgdata.entering and umsgdata.amount or -1
	end
	
	--- Adds a boolean. Takes up 1 byte.
	-- @param val Value
	-- @server
	function umsg_library.bool(val)
		SF.CheckType(val,"boolean")
		local umsgdata = SF.instance.data.umsg
		if not umsgdata.entering then
			error("umsg not started",2)
		end
		if not incrBytes(umsgdata,1) then error("byte limit exceeded",2) end
		umsg.Bool(val)
	end
	
	--- Adds a char. Takes up 1 byte.
	-- @param val Value
	-- @server
	function umsg_library.char(val)
		SF.CheckType(val,"number")
		local umsgdata = SF.instance.data.umsg
		if not umsgdata.entering then
			error("umsg not started",2)
		end
		if not incrBytes(umsgdata,1) then error("byte limit exceeded",2) end
		umsg.Char(val)
	end
	
	--- Adds a short. Takes up 2 bytes.
	-- @param val Value
	-- @server
	function umsg_library.short(val)
		SF.CheckType(val,"number")
		local umsgdata = SF.instance.data.umsg
		if not umsgdata.entering then
			error("umsg not started",2)
		end
		if not incrBytes(umsgdata,2) then error("byte limit exceeded",2) end
		umsg.Short(val)
	end
	
	--- Adds a long. Takes up 4 bytes.
	-- @param val Value
	-- @server
	function umsg_library.long(val)
		SF.CheckType(val,"number")
		local umsgdata = SF.instance.data.umsg
		if not umsgdata.entering then
			error("umsg not started",2)
		end
		if not incrBytes(umsgdata,4) then error("byte limit exceeded",2) end
		umsg.Long(val)
	end
	
	--- Adds a float. Takes up 4 bytes.
	-- @param val Value
	-- @server
	function umsg_library.float(val)
		SF.CheckType(val,"number")
		local umsgdata = SF.instance.data.umsg
		if not umsgdata.entering then
			error("umsg not started",2)
		end
		if not incrBytes(umsgdata,4) then error("byte limit exceeded",2) end
		umsg.Float(val)
	end
	
	--- Adds a vector. Takes up 12 bytes.
	-- @param val Value
	-- @server
	function umsg_library.vector(val)
		SF.CheckType(val,"Vector")
		local umsgdata = SF.instance.data.umsg
		if not umsgdata.entering then
			error("umsg not started",2)
		end
		if not incrBytes(umsgdata,12) then error("byte limit exceeded",2) end
		umsg.Vector(val)
	end
	
	--- Adds an angle. Takes up 12 bytes.
	-- @param val Value
	-- @server
	function umsg_library.angle(val)
		SF.CheckType(val,"Angle")
		local umsgdata = SF.instance.data.umsg
		if not umsgdata.entering then
			error("umsg not started",2)
		end
		if not incrBytes(umsgdata,12) then error("byte limit exceeded",2) end
		umsg.Angle(val)
	end
	
	--- Adds a string. Takes up 1 + val:len()
	-- @param val Value
	-- @server
	function umsg_library.string(val)
		SF.CheckType(val,"string")
		local umsgdata = SF.instance.data.umsg
		if not umsgdata.entering then
			error("umsg not started",2)
		end
		if not incrBytes(umsgdata,1+val:len()) then error("byte limit exceeded",2) end
		umsg.String(val)
	end
	
	--- Stops umsg parsing and sends the umsg. Errors if a umsg hasn't been started.
	-- @server
	function umsg_library.stop()
		local umsgdata = SF.instance.data.umsg
		if not umsgdata.entering then error("umsg not started",2) end
		umsgdata.entering = false
		umsg.End()
	end
	
	
	
else
	-- -------------------------------------------------------------- --
	-- CLIENT
	
	local umsg_methods, umsg_metamethods = SF.Typedef("usermessage")
	local wrapumsg, unwrapumsg = SF.CreateWrapper(umsg_methods)
	
	--- Reads a char
	-- @client
	function umsg_methods:char()
		SF.CheckType(self,umsg_metamethods)
		local msg = unwrapumsg(self)
		return msg and msg:ReadChar()
	end
	
	--- Reads a bool
	-- @client
	function umsg_methods:bool()
		SF.CheckType(self,umsg_metamethods)
		local msg = unwrapumsg(self)
		return msg and msg:ReadBool()
	end
	
	--- Reads a short
	-- @client
	function umsg_methods:short()
		SF.CheckType(self,umsg_metamethods)
		local msg = unwrapumsg(self)
		return msg and msg:ReadShort()
	end
	
	--- Reads a long
	-- @client
	function umsg_methods:long()
		SF.CheckType(self,umsg_metamethods)
		local msg = unwrapumsg(self)
		return msg and msg:ReadLong()
	end
	
	--- Reads a vector
	-- @client
	function umsg_methods:vector()
		SF.CheckType(self,umsg_metamethods)
		local msg = unwrapumsg(self)
		return msg and msg:ReadVector()
	end
	
	--- Reads an angle
	-- @client
	function umsg_methods:angle()
		SF.CheckType(self,umsg_metamethods)
		local msg = unwrapumsg(self)
		return msg and msg:ReadAngle()
	end
	
	--- Reads a string
	-- @client
	function umsg_methods:string()
		SF.CheckType(self,umsg_metamethods)
		local msg = unwrapumsg(self)
		return msg and msg:ReadString()
	end
	
	--- Resets the position in the umsg
	-- @client
	function umsg_methods:reset()
		SF.CheckType(self,umsg_metamethods)
		local msg = unwrapumsg(self)
		if msg then msg:Reset() end
	end
	
	usermessage.Hook("sf_umsg_extension", function(msg)
		local wrapped = wrapumsg(msg)
		SF.RunScriptHook("umsg",wrapped)
	end)
end
]]