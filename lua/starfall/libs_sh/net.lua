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

if SERVER then
	util.AddNetworkString( "SF_netmessage" )
	
	local function checktargets( target )
		if target then
			if SF.GetType(target) == "table" then
				local newtarget = {}
				for i=1,#target do
					SF.CheckType( SF.Entities.Unwrap(target[i]), "Player", 1 )
					newtarget[i] = SF.Entities.Unwrap(target[i])
				end
				return net.Send, newtarget
			else
				SF.CheckType( SF.Entities.Unwrap(target), "Player", 1 ) -- TODO: unhacky this
				return net.Send, SF.Entities.Unwrap(target)
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
	
	write( instance, "Table", SF.Unsanitize(t) )
	return true
end

function net_library.readTable()
	return SF.Sanitize(net.ReadTable())
end

net.Receive( "SF_netmessage", function( len )
	SF.RunScriptHook( "net", net.ReadString(), len )
end)
