-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local dgetmeta = debug.getmetatable

SF.Permissions.registerPrivilege("console.command", "Console command", "Allows the starfall to run console commands", { client = { default = 4 } })

local userdataLimit, printBurst
if SERVER then
	util.AddNetworkString("starfall_chatprint")
	userdataLimit = CreateConVar("sf_userdata_max", "1048576", { FCVAR_ARCHIVE }, "The maximum size of userdata (in bytes) that can be stored on a Starfall chip (saved in duplications).")
	printBurst = SF.BurstObject("print", "print", 3000, 10000, "The print burst regen rate in Bytes/sec.", "The print burst limit in Bytes")
end


--- Lua os library https://wiki.garrysmod.com/page/Category:os
-- @name os
-- @class library
-- @libtbl os_library
SF.RegisterLibrary("os")

return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local owrap, ounwrap = instance.WrapObject, instance.UnwrapObject
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local col_meta, cwrap, cunwrap = instance.Types.Color, instance.Types.Color.Wrap, instance.Types.Color.Unwrap

local builtins_library = instance.env

--- Built in values. These don't need to be loaded; they are in the default builtins_library.
-- @name builtins
-- @shared
-- @class library
-- @libtbl builtins_library

--- Returns the entity representing a processor that this script is running on.
-- @return Starfall entity
function builtins_library.chip()
	return ewrap(instance.data.entity)
end

--- Returns whoever created the chip
-- @return Owner entity
function builtins_library.owner()
	return instance.Types.Player.Wrap(instance.player)
end

--- Same as owner() on the server. On the client, returns the local player
-- @return Returns player with given UserID or if none specified then returns either the owner (server) or the local player (client)
function builtins_library.player(num)
	if num~=nil then
		checkluatype(num, TYPE_NUMBER)
		return instance.Types.Player.Wrap(Player(num))
	end

	return SERVER and builtins_library.owner() or instance.Types.Player.Wrap(LocalPlayer())
end


--- Returns the entity with index 'num'
-- @param num Entity index
-- @return entity
function builtins_library.entity(num)
	checkluatype(num, TYPE_NUMBER)
	return owrap(Entity(num))
end


--- Used to select single values from a vararg or get the count of values in it.
-- @name builtins_library.select
-- @class function
-- @param parameter
-- @param vararg
-- @return Returns a number or vararg, depending on the select method.
builtins_library.select = select

--- Attempts to convert the value to a string.
-- @name builtins_library.tostring
-- @class function
-- @param obj
-- @return obj as string
builtins_library.tostring = tostring

--- Attempts to convert the value to a number.
-- @name builtins_library.tonumber
-- @class function
-- @param obj
-- @return obj as number
builtins_library.tonumber = tonumber

--- Returns an iterator function for a for loop, to return ordered key-value pairs from a table.
-- @name builtins_library.ipairs
-- @class function
-- @param tbl Table to iterate over
-- @return Iterator function
-- @return Table tbl
-- @return 0 as current index
builtins_library.ipairs = ipairs

--- Returns an iterator function for a for loop that will return the values of the specified table in an arbitrary order.
-- @name builtins_library.pairs
-- @class function
-- @param tbl Table to iterate over
-- @return Iterator function
-- @return Table tbl
-- @return nil as current index
builtins_library.pairs = pairs

--- Returns a string representing the name of the type of the passed object.
-- @name builtins_library.type
-- @param obj Object to get type of
-- @return The name of the object's type.
function builtins_library.type(obj)
	local tp = getmetatable(obj)
	return isstring(tp) and tp or type(obj)
end

--- Returns the next key and value pair in a table.
-- @name builtins_library.next
-- @class function
-- @param tbl Table to get the next key-value pair of
-- @param k Previous key (can be nil)
-- @return Key or nil
-- @return Value or nil
builtins_library.next = next

--- This function takes a numeric indexed table and return all the members as a vararg.
-- @name builtins_library.unpack
-- @class function
-- @param tbl
-- @return Elements of tbl
builtins_library.unpack = unpack

--- Sets, changes or removes a table's metatable. Doesn't work on most internal metatables
-- @name builtins_library.setmetatable
-- @class function
-- @param tbl The table to set the metatable of
-- @param meta The metatable to use
-- @return tbl with metatable set to meta
builtins_library.setmetatable = setmetatable

--- Returns the metatable of an object. Doesn't work on most internal metatables
-- @param tbl Table to get metatable of
-- @return The metatable of tbl
builtins_library.getmetatable = function(tbl)
	checkluatype(tbl, TYPE_TABLE)
	return getmetatable(tbl)
end

--- Generates the CRC checksum of the specified string. (https://en.wikipedia.org/wiki/Cyclic_redundancy_check)
-- @name builtins_library.crc
-- @class function
-- @param stringToHash The string to calculate the checksum of
-- @return The unsigned 32 bit checksum as a string
builtins_library.crc = util.CRC

--- Constant that denotes whether the code is executed on the client
-- @name builtins_library.CLIENT
-- @class field
builtins_library.CLIENT = CLIENT

--- Constant that denotes whether the code is executed on the server
-- @name builtins_library.SERVER
-- @class field
builtins_library.SERVER = SERVER

--- Returns if this is the first time this hook was predicted.
-- @name builtins_library.isFirstTimePredicted
-- @class function
-- @return Boolean
builtins_library.isFirstTimePredicted = IsFirstTimePredicted

--- Returns the current count for this Think's CPU Time.
-- This value increases as more executions are done, may not be exactly as you want.
-- If used on screens, will show 0 if only rendering is done. Operations must be done in the Think loop for them to be counted.
-- @return Current quota used this Think
function builtins_library.quotaUsed()
	return instance.cpu_total
end

--- Gets the Average CPU Time in the buffer
-- @return Average CPU Time of the buffer.
function builtins_library.quotaAverage()
	return instance:movingCPUAverage()
end

--- Gets the current ram usage of the gmod lua environment
-- @return The ram used in kilobytes
function builtins_library.ramUsed()
	return SF.Instance.Ram
end

--- Gets the moving average of ram usage of the gmod lua environment
-- @return The ram used in kilobytes
function builtins_library.ramAverage()
	return SF.Instance.RamAvg
end

--- Gets the max allowed ram usage of the gmod lua environment
-- @return The max ram usage in kilobytes
function builtins_library.ramMax()
	return SF.RamCap:GetInt()
end

--- Gets the starfall version
-- @return Starfall version
function builtins_library.version()
	if SERVER then
		return SF.Version
	else
		return GetGlobalString("SF.Version")
	end
end

--- Returns the total used time for all chips by the player.
-- @return Total used CPU time of all your chips.
function builtins_library.quotaTotalUsed()
	local total = 0
	for instance, _ in pairs(SF.playerInstances[instance.player]) do
		total = total + instance.cpu_total
	end
	return total
end

--- Returns the total average time for all chips by the player.
-- @return Total average CPU Time of all your chips.
function builtins_library.quotaTotalAverage()
	local total = 0
	for instance, _ in pairs(SF.playerInstances[instance.player]) do
		total = total + instance:movingCPUAverage()
	end
	return total
end

--- Gets the CPU Time max.
-- CPU Time is stored in a buffer of N elements, if the average of this exceeds quotaMax, the chip will error.
-- @return Max SysTime allowed to take for execution of the chip in a Think.
function builtins_library.quotaMax()
	return instance.cpuQuota
end

--- Sets a CPU soft quota which will trigger a catchable error if the cpu goes over a certain amount.
-- @param quota The threshold where the soft error will be thrown. Ratio of current cpu to the max cpu usage. 0.5 is 50%
function builtins_library.setSoftQuota(quota)
	checkluatype(quota, TYPE_NUMBER)
	instance.cpu_softquota = quota
end

--- Checks if the chip is capable of performing an action.
--@param perm The permission id to check
--@param obj Optional object to pass to the permission system.
function builtins_library.hasPermission(perm, obj)
	checkluatype(perm, TYPE_STRING)
	if not SF.Permissions.permissionchecks[perm] then SF.Throw("Permission doesn't exist", 2) end
	return SF.Permissions.hasAccess(instance, ounwrap(obj), perm)
end

if CLIENT then

	--- Called when local client changed instance permissions
	-- @name permissionrequest
	-- @class hook
	-- @client

	--- Setups request for overriding permissions.
	--@param perms Table of overridable permissions' names.
	--@param desc Description attached to request.
	--@param showOnUse Whether request will popup when player uses chip or linked screen.
	--@client
	function builtins_library.setupPermissionRequest( perms, desc, showOnUse )
		checkluatype( desc, TYPE_STRING )
		checkluatype( perms, TYPE_TABLE )
		local c = #perms
		if #desc > 400 then
			SF.Throw( "Description too long." )
		end
		local privileges = SF.Permissions.privileges
		local overrides = {}
		for I = 1, c do
			local v = perms[I]
			if isstring(v) then
				if not privileges[v] then
					SF.Throw("Invalid permission name: "..v)
				end
				if not privileges[v][3].client then
					SF.Throw("Permission isn't requestable: "..v)
				end
				overrides[v] = true
			end
		end
		instance.permissionRequest = {}
		instance.permissionRequest.overrides = overrides
		instance.permissionRequest.description = string.gsub( desc, '%s+$', '' )
		instance.permissionRequest.showOnUse = showOnUse == true

	end

	--- Is permission request fully satisfied.
	--@return Boolean of whether the client gave all permissions specified in last request or not.
	--@client
	function builtins_library.permissionRequestSatisfied()
		return SF.Permissions.permissionRequestSatisfied( instance )
	end

end


local os_library = instance.Libraries.os

--- Returns the approximate cpu time the application ran.
-- This function has different precision on Linux (1/100).
-- @class function
-- @return The runtime
os_library.clock = os.clock

--- Returns the date/time as a formatted string or in a table.
-- See https://wiki.facepunch.com/gmod/Structures/DateData for the table structure
-- @class function
-- @param format The format string. If starts with an '!', it will use UTC timezone rather than the local timezone
-- @param time Time to use for the format
-- @return If format is equal to '*t' or '!*t' then it will return a table with DateData structure, otherwise a string
os_library.date = function(format, time)
	if format~=nil and string.find(format, "%%[^%%aAbBcCdDSHeUmMjIpwxXzZyY]") then SF.Throw("Bad date format", 2) end
	return os.date(format, time)
end

--- Subtracts the second of the first value and rounds the result
-- @class function
-- @param timeA The first value
-- @param timeB The value to subtract
-- @return Time difference
os_library.difftime = os.difftime

--- Returns the system time in seconds past the unix epoch.
-- If a table is supplied, the function attempts to build a system time with the specified table members
-- @class function
-- @param dateData Optional table to generate the time from. This table's data is interpreted as being in the local timezone
-- @return Seconds passed since Unix epoch
os_library.time = os.time


-- ------------------------- Functions ------------------------- --

--- Gets all libraries
-- @return Table where each key is the library name and value is table of the library
function builtins_library.getLibraries()
	return instance.Libraries
end

--- Set the value of a table index without invoking a metamethod
--@param table The table to modify
--@param key The index of the table
--@param value The value to set the index equal to
function builtins_library.rawset(table, key, value)
    checkluatype(table, TYPE_TABLE)

    rawset(table, key, value)
end

--- Gets the value of a table index without invoking a metamethod
--@param table The table to get the value from
--@param key The index of the table
--@return The value of the index
function builtins_library.rawget(table, key, value)
    checkluatype(table, TYPE_TABLE)

    return rawget(table, key)
end

local function printTableX(t, indent, alreadyprinted)
	local ply = instance.player
	if next(t) then
		for k, v in builtins_library.pairs(t) do
			if SF.GetType(v) == "table" and not alreadyprinted[v] then
				alreadyprinted[v] = true
				local s = string.rep("\t", indent) .. tostring(k) .. ":"
				if SERVER then printBurst:use(ply, #s) end
				ply:ChatPrint(s)
				printTableX(v, indent + 1, alreadyprinted)
			else
				local s = string.rep("\t", indent) .. tostring(k) .. "\t=\t" .. tostring(v)
				if SERVER then printBurst:use(ply, #s) end
				ply:ChatPrint(s)
			end
		end
	else
		local s = string.rep("\t", indent).."{}"
		if SERVER then printBurst:use(ply, #s) end
		ply:ChatPrint(s)
	end
end

local function argsToChat(...)
	local n = select('#', ...)
	local input = { ... }
	local output = {}
	local color = false
	for i = 1, n do
		local val = input[i]
		local add
		if dgetmeta(val) == col_meta then
			color = true
			add = Color(val[1], val[2], val[3])
		else
			add = tostring(val)
		end
		output[i] = add
	end
	-- Combine the strings with tabs
	local processed = {}
	if not color then processed[1] = Color(151, 211, 255) end
	local i = 1
	while i <= n do
		if isstring(output[i]) then
			local j = i + 1
			while j <= n and isstring(output[j]) do
				j = j + 1
			end
			if i==(j-1) then
				processed[#processed + 1] = output[i]
			else
				processed[#processed + 1] = table.concat({ unpack(output, i, j) }, "\t")
			end
			i = j
		else
			processed[#processed + 1] = output[i]
			i = i + 1
		end
	end
	return processed
end

if SERVER then
	--- Prints a message to the player's chat.
	-- @shared
	-- @param ... Values to print
	function builtins_library.print(...)
		local tbl = argsToChat(...)

		net.Start("starfall_chatprint")
		net.WriteUInt(#tbl, 32)
		for i, v in ipairs(tbl) do
			net.WriteType(v)
		end
		local bytes = net.BytesWritten()
		net.Send(instance.player)
	
		printBurst:use(instance.player, bytes)
	end

	--- Prints a table to player's chat
	-- @param tbl Table to print
	function builtins_library.printTable(tbl)
		checkluatype(tbl, TYPE_TABLE)
		printTableX(tbl, 0, { tbl = true })
	end

	--- Execute a console command
	-- @shared
	-- @param cmd Command to execute
	function builtins_library.concmd(cmd)
		checkluatype(cmd, TYPE_STRING)
		if #cmd > 512 then SF.Throw("Console command is too long!", 2) end
		checkpermission(instance, nil, "console.command")
		instance.player:ConCommand(cmd)
	end

	--- Sets the chip's userdata that the duplicator tool saves. max 1MiB; can be changed with convar sf_userdata_max
	-- @server
	-- @param str String data
	function builtins_library.setUserdata(str)
		checkluatype(str, TYPE_STRING)
		local max = userdataLimit:GetInt()
		if #str>max then
			SF.Throw("The userdata limit is " .. string.Comma(max) .. " bytes", 2)
		end
		instance.data.entity.starfalluserdata = str
	end

	--- Gets the chip's userdata that the duplicator tool loads
	-- @server
	-- @return String data
	function builtins_library.getUserdata()
		return instance.data.entity.starfalluserdata or ""
	end
else
	--- Sets the chip's display name
	-- @client
	-- @param name Name
	function builtins_library.setName(name)
		checkluatype(name, TYPE_STRING)
		local e = instance.data.entity
		if (e and e:IsValid()) then
			e.name = string.sub(name, 1, 256)
		end
	end

	--- Sets clipboard text. Only works on the owner of the chip.
	-- @client
	-- @param txt Text to set to the clipboard
	function builtins_library.setClipboardText(txt)
		if instance.player ~= LocalPlayer() then return end
		checkluatype(txt, TYPE_STRING)
		SetClipboardText(txt)
	end

	--- Prints a message to your chat, console, or the center of your screen.
	-- @client
	-- @param mtype How the message should be displayed. See http://wiki.facepunch.com/gmod/Enums/HUD
	-- @param text The message text.
	function builtins_library.printMessage(mtype, text)
		if instance.player ~= LocalPlayer() then return end
		checkluatype(text, TYPE_STRING)
		instance.player:PrintMessage(mtype, text)
	end

	function builtins_library.print(...)
		if instance.player == LocalPlayer() then
			chat.AddText(unpack(argsToChat(...)))
		end
	end

	function builtins_library.printTable(tbl)
		checkluatype(tbl, TYPE_TABLE)
		if instance.player == LocalPlayer() then
			printTableX(tbl, 0, { tbl = true })
		end
	end

	function builtins_library.concmd(cmd)
		checkluatype(cmd, TYPE_STRING)
		checkpermission(instance, nil, "console.command")
		LocalPlayer():ConCommand(cmd)
	end

	--- Returns the local player's camera angles
	-- @client
	-- @return The local player's camera angles
	function builtins_library.eyeAngles()
		return awrap(LocalPlayer():EyeAngles())
	end

	--- Returns the local player's camera position
	-- @client
	-- @return The local player's camera position
	function builtins_library.eyePos()
		return vwrap(LocalPlayer():EyePos())
	end

	--- Returns the local player's camera forward vector
	-- @client
	-- @return The local player's camera forward vector
	function builtins_library.eyeVector()
		return vwrap(LocalPlayer():GetAimVector())
	end
end

--- Returns the table of scripts used by the chip
-- @return Table of scripts used by the chip
function builtins_library.getScripts()
	return instance.Sanitize(instance.source)
end

--- Runs an included script and caches the result.
-- Works pretty much like standard Lua require()
-- @param file The file to include. Make sure to --@include it
-- @return Return value of the script
function builtins_library.require(file)
	checkluatype(file, TYPE_STRING)
	local loaded = instance.requires

	local path
	if string.sub(file, 1, 1)=="/" then
		path = SF.NormalizePath(file)
	else
		path = SF.NormalizePath(string.GetPathFromFilename(instance.requirestack[#instance.requirestack]) .. file)
		if not instance.scripts[path] then
			path = SF.NormalizePath(file)
		end
	end

	if loaded[path] then
		return loaded[path]
	else
		local func = instance.scripts[path]
		if not func then SF.Throw("Can't find file '" .. path .. "' (did you forget to --@include it?)", 2) end

		if table.HasValue(instance.requirestack, path) then
			SF.Throw("Cyclic require dependency", 2)
		end

		local stacklen = #instance.requirestack + 1
		instance.requirestack[stacklen] = path
		local ok, ret = pcall(func)
		instance.requirestack[stacklen] = nil

		if ok then
			loaded[path] = ret or true
			return loaded[path]
		else
			error(ret)
		end
	end
end

--- Runs an included script and caches the result.
-- Works pretty much like standard Lua require()
-- @param dir The directory to include. Make sure to --@includedir it
-- @param loadpriority Table of files that should be loaded before any others in the directory
-- @return Table of return values of the scripts
function builtins_library.requiredir(dir, loadpriority)
	checkluatype(dir, TYPE_STRING)
	if loadpriority~=nil then checkluatype(loadpriority, TYPE_TABLE) end

	local path
	if string.sub(dir, 1, 1)=="/" then
		path = SF.NormalizePath(dir)
	else
		path = SF.NormalizePath(string.GetPathFromFilename(instance.requirestack[#instance.requirestack]) .. dir)
		
		-- If no scripts found in relative dir, try the root dir.
		local foundScript = false
		for file, _ in pairs(instance.scripts) do
			if string.match(file, "^"..path.."/[^/]+%.txt$") or string.match(file, "^"..path.."/[^/]+%.lua$") then
				foundScript = true
				break
			end
		end
		if not foundScript then
			path = SF.NormalizePath(dir)
		end
	end

	local returns = {}
	local alreadyRequired = {}

	if loadpriority then
		for i = 1, #loadpriority do
			local file = path .. "/" .. loadpriority[i]
			if instance.scripts[file] and not table.HasValue(instance.requirestack, file) then
				returns[file] = builtins_library.require("/"..file)
				alreadyRequired[file] = true
			end
		end
	end

	for file, _ in pairs(instance.scripts) do
		if not alreadyRequired[file] and (string.match(file, "^"..path.."/[^/]+%.txt$") or string.match(file, "^"..path.."/[^/]+%.lua$")) and not table.HasValue(instance.requirestack, file) then
			returns[file] = builtins_library.require("/"..file)
		end
	end

	return returns
end

--- Runs an included script, but does not cache the result.
-- Pretty much like standard Lua dofile()
-- @param file The file to include. Make sure to --@include it
-- @return Return value of the script
function builtins_library.dofile(file)
	checkluatype(file, TYPE_STRING)
	local path
	if string.sub(file, 1, 1)=="/" then
		path = SF.NormalizePath(file)
	else
		path = SF.NormalizePath(string.GetPathFromFilename(string.sub(debug.getinfo(2, "S").source, 5)) .. file)
		if not instance.scripts[path] then
			path = SF.NormalizePath(file)
		end
	end
	local func = instance.scripts[path]
	if not func then SF.Throw("Can't find file '" .. path .. "' (did you forget to --@include it?)", 2) end
	return func()
end

--- Runs an included directory, but does not cache the result.
-- @param dir The directory to include. Make sure to --@includedir it
-- @param loadpriority Table of files that should be loaded before any others in the directory
-- @return Table of return values of the scripts
function builtins_library.dodir(dir, loadpriority)
	checkluatype(dir, TYPE_STRING)
	if loadpriority~=nil then checkluatype(loadpriority, TYPE_TABLE) end

	local returns = {}
	local alreadyRequired = {}

	if loadpriority then
		for i = 1, #loadpriority do
			for file, _ in pairs(instance.scripts) do
				if string.find(file, dir .. "/" .. loadpriority[i] , 1) == 1 then
					returns[file] = builtins_library.dofile(file)
					alreadyRequired[file] = true
				end
			end
		end
	end

	for file, _ in pairs(instance.scripts) do
		if not alreadyRequired[file] and string.find(file, dir, 1) == 1 then
			returns[file] = builtins_library.dofile(file)
		end
	end

	return returns
end

--- GLua's loadstring
-- Works like loadstring, except that it executes by default in the main builtins_library
-- @param str String to execute
-- @return Function of str
function builtins_library.loadstring(str, name)
	name = "SF:" .. (name or tostring(instance.env))
	local func = SF.CompileString(str, name, false)

	-- CompileString returns an error as a string, better check before setfenv
	if isfunction(func) then
		return setfenv(func, instance.env)
	end

	return func
end

--- Lua's setfenv
-- Works like setfenv, but is restricted on functions
-- @param func Function to change builtins_library of
-- @param tbl New builtins_library
-- @return func with builtins_library set to tbl
function builtins_library.setfenv(func, tbl)
	if not isfunction(func) or getfenv(func) == _G then SF.Throw("Main Thread is protected!", 2) end
	return setfenv(func, tbl)
end

--- Gets an SF type's methods table
-- @param sfType Name of SF type
-- @return Table of the type's methods which can be edited or iterated
function builtins_library.getMethods(sfType)
	checkluatype(sfType, TYPE_STRING)
	local typemeta = instance.Types[sfType]
	if typemeta then
		return typemeta.Methods
	end
end

--- Simple version of Lua's getfenv
-- Returns the current builtins_library
-- @return Current builtins_library
function builtins_library.getfenv()
	local fenv = getfenv(2)
	if fenv ~= _G then return fenv end
end

--- GLua's debug.getinfo()
-- Returns a DebugInfo structure containing the passed function's info https://wiki.facepunch.com/gmod/Structures/DebugInfo
-- @param funcOrStackLevel Function or stack level to get info about. Defaults to stack level 0.
-- @param fields A string that specifies the information to be retrieved. Defaults to all (flnSu).
-- @return DebugInfo table
function builtins_library.debugGetInfo(funcOrStackLevel, fields)
	if not isfunction(funcOrStackLevel) and not isnumber(funcOrStackLevel) then SF.ThrowTypeError("function or number", SF.GetType(TfuncOrStackLevel), 2) end
	if fields~=nil then checkluatype(fields, TYPE_STRING) end

	local ret = debug.getinfo(funcOrStackLevel, fields)
	if ret then
		ret.func = nil
		return ret
	end
end

--- GLua's debug.getlocal()
-- Returns the name of a function or stack's locals
-- @param funcOrStackLevel Function or stack level to get info about. Defaults to stack level 0.
-- @param index The index of the local to get
-- @return The name of the local
function builtins_library.debugGetLocal(funcOrStackLevel, index)
	if not isfunction(funcOrStackLevel) and not isnumber(funcOrStackLevel) then SF.ThrowTypeError("function or number", SF.GetType(TfuncOrStackLevel), 2) end
	checkluatype(index, TYPE_NUMBER)

	local name = debug.getlocal(funcOrStackLevel, index)
	-- debug.getlocal returns two values, make sure we only return the first
	return name
end

local uncatchable = {
	["not enough memory"] = true,
	["stack overflow"] = true
}

--- Lua's pcall with SF throw implementation
-- Calls a function and catches an error that can be thrown while the execution of the call.
-- @param func Function to be executed and of which the errors should be caught of
-- @param arguments Arguments to call the function with.
-- @return If the function had no errors occur within it.
-- @return If an error occurred, this will be a string containing the error message. Otherwise, this will be the return values of the function passed in.
function builtins_library.pcall(func, ...)
	local vret = { pcall(func, ...) }
	local ok, err = vret[1], vret[2]

	if ok then return unpack(vret) end

	if istable(err) then
		if err.uncatchable then
			error(err)
		end
	elseif uncatchable[err] then
		SF.Throw(err, 2, true)
	end

	return false, instance.Sanitize({err})[1]
end

local function xpcall_Callback(err)
	return {err, debug.traceback(tostring(err), 2)} -- only way to return 2 values; level 2 to branch 
end

--- Lua's xpcall with SF throw implementation, and a traceback for debugging.
-- Attempts to call the first function. If the execution succeeds, this returns true followed by the returns of the function.
-- If execution fails, this returns false and the second function is called with the error message, and the stack trace.
-- @param func The function to call initially.
-- @param callback The function to be called if execution of the first fails; the error message and stack trace are passed.
-- @param ... Varargs to pass to the initial function.
-- @return Status of the execution; true for success, false for failure.
-- @return The returns of the first function if execution succeeded, otherwise the return values of the error callback.
function builtins_library.xpcall(func, callback, ...)
	local vret = { xpcall(func, xpcall_Callback, ...) }
	local ok, errData = vret[1], vret[2]

	if ok then return unpack(vret) end

	local err, traceback = errData[1], errData[2]
	if istable(err) then
		if err.uncatchable then
			error(err)
		end
	elseif uncatchable[err] then
		SF.Throw(err, 2, true)
	end

	return false, callback(instance.Sanitize({err})[1], traceback)
end

--- Try to execute a function and catch possible exceptions
-- Similar to xpcall, but a bit more in-depth
-- @param func Function to execute
-- @param catch Optional function to execute in case func fails
function builtins_library.try(func, catch)
	local ok, err = pcall(func)
	if ok then return end

	if istable(err) then
		if err.uncatchable then
			error(err)
		end
	elseif uncatchable[err] then
		SF.Throw(err, 2, true)
	end
	if catch then catch(instance.Sanitize({err})[1]) end
end


--- Throws an exception
-- @param msg Message string
-- @param level Which level in the stacktrace to blame. Defaults to 1
-- @param uncatchable Makes this exception uncatchable
function builtins_library.throw(msg, level, uncatchable)
	SF.Throw(msg, 1 + (level or 1), uncatchable)
end

--- Throws an exception. Alias of 'throw'
-- @name builtins_library.error
-- @class function
-- @param msg Message string
-- @param level Which level in the stacktrace to blame. Defaults to 1
-- @param uncatchable Makes this exception uncatchable
builtins_library.error = builtins_library.throw

--- If the result of the first argument is false or nil, an error is thrown with the second argument as the message.
-- @name builtins_library.assert
-- @class function
-- @param condition
-- @param msg
builtins_library.assert = assert

--- Returns if the table has an isValid function and isValid returns true.
--@param object Table to check
--@return If it is valid
function builtins_library.isValid(object)

	if (not object) then return false end
	if (not object.isValid) then return false end

	return object:isValid()

end

--- Translates the specified position and angle into the specified coordinate system
-- @param pos The position that should be translated from the current to the new system
-- @param ang The angles that should be translated from the current to the new system
-- @param newSystemOrigin The origin of the system to translate to
-- @param newSystemAngles The angles of the system to translate to
-- @return localPos
-- @return localAngles
function builtins_library.worldToLocal(pos, ang, newSystemOrigin, newSystemAngles)

	local localPos, localAngles = WorldToLocal(
		vunwrap(pos),
		aunwrap(ang),
		vunwrap(newSystemOrigin),
		aunwrap(newSystemAngles)
	)

	return vwrap(localPos), awrap(localAngles)
end

--- Translates the specified position and angle from the specified local coordinate system
-- @param localPos The position vector that should be translated to world coordinates
-- @param localAng The angle that should be converted to a world angle
-- @param originPos The origin point of the source coordinate system, in world coordinates
-- @param originAngle The angles of the source coordinate system, as a world angle
-- @return worldPos
-- @return worldAngles
function builtins_library.localToWorld(localPos, localAng, originPos, originAngle)

	local worldPos, worldAngles = LocalToWorld(
		vunwrap(localPos),
		aunwrap(localAng),
		vunwrap(originPos),
		aunwrap(originAngle)
	)

	return vwrap(worldPos), awrap(worldAngles)
end

--- Creates a 'middleclass' class object that can be used similarly to Java/C++ classes. See https://github.com/kikito/middleclass for examples.
-- @name builtins_library.class
-- @class function
-- @param name The string name of the class
-- @param super The (optional) parent class to inherit from
builtins_library.class = SF.Class

end

--- Mark a file to be included in the upload.
-- This is required to use the file in require() and dofile()
-- @name include
-- @class directive
-- @param path Path to the file

--- Mark a directory to be included in the upload.
-- This is optional to include all files in the directory in require() and dofile()
-- @name includedir
-- @class directive
-- @param path Path to the directory

--- Set the name of the script.
-- This will become the name of the tab and will show on the overlay of the processor. --@name Awesome script
-- @name name
-- @class directive
-- @param name Name of the script

--- Set the author of the script.
-- This will set the author that will be shown on the overlay of the processor. --@author TheAuthor
-- @name author
-- @class directive
-- @param author Author of the script

--- Set the model of the processor entity. --@model models/props_junk/watermelon01.mdl
-- @name model
-- @class directive
-- @param model String of the model

--- Set the current file to only run on the server. Shared is default. --@server
-- @name server
-- @class directive

--- Set the current file to only run on the client. Shared is default. --@client
-- @name client
-- @class directive

--- Set the client file to run as main. Can only be used in the main file. The client file must be --@include'ed. The main file will not be sent to the client if you use this directive.
-- --@include somefile.txt
-- --@clientmain somefile.txt
-- @name clientmain
-- @class directive
-- @param filename The file to run as main on client

--- Lets the chip run with no restrictions and the chip owner becomes SF.Superuser. Can only be used in the main file. --@superuser
-- @name superuser
-- @class directive

