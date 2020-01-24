-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check
local dgetmeta = debug.getmetatable

SF.Permissions.registerPrivilege("console.command", "Console command", "Allows the starfall to run console commands", { client = { default = 4 } })

local userdataLimit, printBurst
if SERVER then
	util.AddNetworkString("starfall_chatprint")
	userdataLimit = CreateConVar("sf_userdata_max", "1048576", { FCVAR_ARCHIVE }, "The maximum size of userdata (in bytes) that can be stored on a Starfall chip (saved in duplications).")
	printBurst = SF.BurstObject("print", "print", 3000, 10000, "The print burst regen rate in Bytes/sec.", "The print burst limit in Bytes")
end


SF.RegisterLibrary("string")
SF.RegisterLibrary("math")
SF.RegisterLibrary("os")
SF.RegisterLibrary("table")


return function(instance)

instance.Libraries.string = table.Copy(SF.SafeStringLib)

local checktype = instance.CheckType
local owrap, ounwrap = instance.WrapObject, instance.UnwrapObject
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local col_meta, cwrap, cunwrap = instance.Types.Color, instance.Types.Color.Wrap, instance.Types.Color.Unwrap

local Environment = instance.env

--- Built in values. These don't need to be loaded; they are in the default environment.
-- @name builtin
-- @shared
-- @class library
-- @libtbl Environment

--- Returns the entity representing a processor that this script is running on.
-- @name Environment.chip
-- @return Starfall entity
function Environment.chip()
	return ewrap(instance.data.entity)
end

--- Returns whoever created the chip
-- @class function
-- @return Owner entity
function Environment.owner()
	return instance.Types.Player.Wrap(instance.player)
end

--- Same as owner() on the server. On the client, returns the local player
-- @name Environment.player
-- @return Returns player with given UserID or if none specified then returns either the owner (server) or the local player (client)
function Environment.player(num)
	if num then
		checkluatype(num, TYPE_NUMBER)
		return instance.Types.Player.Wrap(Player(num))
	end

	return SERVER and Environment.owner() or instance.Types.Player.Wrap(LocalPlayer())
end


--- Returns the entity with index 'num'
-- @name Environment.entity
-- @param num Entity index
-- @return entity
function Environment.entity(num)
	checkluatype(num, TYPE_NUMBER)
	return owrap(Entity(num))
end


--- Used to select single values from a vararg or get the count of values in it.
-- @name Environment.select
-- @class function
-- @param parameter
-- @param vararg
-- @return Returns a number or vararg, depending on the select method.
Environment.select = select

--- Attempts to convert the value to a string.
-- @name Environment.tostring
-- @class function
-- @param obj
-- @return obj as string
Environment.tostring = tostring

--- Attempts to convert the value to a number.
-- @name Environment.tonumber
-- @class function
-- @param obj
-- @return obj as number
Environment.tonumber = tonumber

--- Returns an iterator function for a for loop, to return ordered key-value pairs from a table.
-- @name Environment.ipairs
-- @class function
-- @param tbl Table to iterate over
-- @return Iterator function
-- @return Table tbl
-- @return 0 as current index
Environment.ipairs = ipairs

--- Returns an iterator function for a for loop that will return the values of the specified table in an arbitrary order.
-- @name Environment.pairs
-- @class function
-- @param tbl Table to iterate over
-- @return Iterator function
-- @return Table tbl
-- @return nil as current index
Environment.pairs = pairs

--- Returns a string representing the name of the type of the passed object.
-- @name Environment.type
-- @class function
-- @param obj Object to get type of
-- @return The name of the object's type.
Environment.type = function(obj)
	local tp = getmetatable(obj)
	return isstring(tp) and tp or type(obj)
end

--- Returns the next key and value pair in a table.
-- @name Environment.next
-- @class function
-- @param tbl Table to get the next key-value pair of
-- @param k Previous key (can be nil)
-- @return Key or nil
-- @return Value or nil
Environment.next = next

--- If the result of the first argument is false or nil, an error is thrown with the second argument as the message.
-- @name Environment.assert
-- @class function
-- @param condition
-- @param msg
Environment.assert = function(condition, msg) if not condition then SF.Throw(msg or "assertion failed!", 2) else return condition end end

--- This function takes a numeric indexed table and return all the members as a vararg.
-- @name Environment.unpack
-- @class function
-- @param tbl
-- @return Elements of tbl
Environment.unpack = unpack

--- Sets, changes or removes a table's metatable. Doesn't work on most internal metatables
-- @name Environment.setmetatable
-- @class function
-- @param tbl The table to set the metatable of
-- @param meta The metatable to use
-- @return tbl with metatable set to meta
Environment.setmetatable = setmetatable

--- Returns the metatable of an object. Doesn't work on most internal metatables
-- @param tbl Table to get metatable of
-- @return The metatable of tbl
Environment.getmetatable = function(tbl)
	checkluatype(tbl, TYPE_TABLE)
	return getmetatable(tbl)
end

--- Generates the CRC checksum of the specified string. (https://en.wikipedia.org/wiki/Cyclic_redundancy_check)
-- @name Environment.crc
-- @class function
-- @param stringToHash The string to calculate the checksum of
-- @return The unsigned 32 bit checksum as a string
Environment.crc = util.CRC

--- Constant that denotes whether the code is executed on the client
-- @name Environment.CLIENT
-- @class field
Environment.CLIENT = CLIENT

--- Constant that denotes whether the code is executed on the server
-- @name Environment.SERVER
-- @class field
Environment.SERVER = SERVER

--- Returns if this is the first time this hook was predicted.
-- @name Environment.isFirstTimePredicted
-- @class function
-- @return Boolean
Environment.isFirstTimePredicted = IsFirstTimePredicted

--- Returns the current count for this Think's CPU Time.
-- This value increases as more executions are done, may not be exactly as you want.
-- If used on screens, will show 0 if only rendering is done. Operations must be done in the Think loop for them to be counted.
-- @return Current quota used this Think
function Environment.quotaUsed()
	return instance.cpu_total
end

--- Gets the Average CPU Time in the buffer
-- @return Average CPU Time of the buffer.
function Environment.quotaAverage()
	return instance:movingCPUAverage()
end

--- Gets the current ram usage of the lua environment
-- @return The ram used in bytes
function Environment.ramUsed()
	return SF.Instance.Ram
end

--- Gets the moving average of ram usage of the lua environment
-- @return The ram used in bytes
function Environment.ramAverage()
	return SF.Instance.RamAvg
end

--- Gets the starfall version
-- @return Starfall version
function Environment.version()
	if SERVER then
		return SF.Version
	else
		return GetGlobalString("SF.Version")
	end
end

--- Returns the total used time for all chips by the player.
-- @return Total used CPU time of all your chips.
function Environment.quotaTotalUsed()
	local total = 0
	for instance, _ in pairs(SF.playerInstances[instance.player]) do
		total = total + instance.cpu_total
	end
	return total
end

--- Returns the total average time for all chips by the player.
-- @return Total average CPU Time of all your chips.
function Environment.quotaTotalAverage()
	local total = 0
	for instance, _ in pairs(SF.playerInstances[instance.player]) do
		total = total + instance:movingCPUAverage()
	end
	return total
end

--- Gets the CPU Time max.
-- CPU Time is stored in a buffer of N elements, if the average of this exceeds quotaMax, the chip will error.
-- @return Max SysTime allowed to take for execution of the chip in a Think.
function Environment.quotaMax()
	return instance.cpuQuota
end

--- Sets a CPU soft quota which will trigger a catchable error if the cpu goes over a certain amount.
-- @param quota The threshold where the soft error will be thrown. Ratio of current cpu to the max cpu usage. 0.5 is 50%
function Environment.setSoftQuota(quota)
	checkluatype(quota, TYPE_NUMBER)
	instance.cpu_softquota = quota
end

--- Checks if the chip is capable of performing an action.
--@param perm The permission id to check
--@param obj Optional object to pass to the permission system.
function Environment.hasPermission(perm, obj)
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
	function Environment.setupPermissionRequest( perms, desc, showOnUse )
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
	function Environment.permissionRequestSatisfied()
		return SF.Permissions.permissionRequestSatisfied( instance )
	end

end

-- String library
local string_methods = instance.Libraries.string
function string_methods.fromColor(color)
	return string.FromColor(cunwrap(color))
end
function string_methods.toColor(str)
	return cwrap(string.ToColor(str))
end
--- String library http://wiki.garrysmod.com/page/Category:string
-- @name Environment.string
-- @class table
Environment.string = nil



local math_methods = instance.Libraries.math
math_methods.abs = math.abs
math_methods.acos = math.acos
math_methods.angleDifference = math.AngleDifference
math_methods.approach = math.Approach
math_methods.approachAngle = math.ApproachAngle
math_methods.asin = math.asin
math_methods.atan = math.atan
math_methods.atan2 = math.atan2
math_methods.binToInt = math.BinToInt
math_methods.calcBSplineN = math.calcBSplineN
math_methods.ceil = math.ceil
math_methods.clamp = math.Clamp
math_methods.cos = math.cos
math_methods.cosh = math.cosh
math_methods.deg = math.deg
math_methods.dist = math.Dist
math_methods.distance = math.Distance
math_methods.easeInOut = math.EaseInOut
math_methods.exp = math.exp
math_methods.floor = math.floor
math_methods.fmod = math.fmod
math_methods.frexp = math.frexp
math_methods.huge = math.huge
math_methods.intToBin = math.IntToBin
math_methods.ldexp = math.ldexp
math_methods.log = math.log
math_methods.log10 = math.log10
math_methods.max = math.max
math_methods.min = math.Min
math_methods.mod = math.mod
math_methods.modf = math.modf
math_methods.normalizeAngle = math.NormalizeAngle
math_methods.pi = math.pi
math_methods.pow = math.pow
math_methods.rad = math.rad
math_methods.rand = math.Rand
math_methods.random = math.random
math_methods.remap = math.Remap
math_methods.round = math.Round
math_methods.sin = math.sin
math_methods.sinh = math.sinh
math_methods.sqrt = math.sqrt
math_methods.tan = math.tan
math_methods.tanh = math.tanh
math_methods.timeFraction = math.TimeFraction
math_methods.truncate = math.Truncate
function math_methods.bSplinePoint(tDiff, tPoints, tMax)
	return vwrap(math.BSplinePoint(tDiff, instance.Unsanitize(tPoints), tMax))
end
function math_methods.lerp(percent, from, to)
	checkluatype(percent, TYPE_NUMBER)
	checkluatype(from, TYPE_NUMBER)
	checkluatype(to, TYPE_NUMBER)

	return Lerp(percent, from, to)
end
function math_methods.lerpAngle(percent, from, to)
	checkluatype(percent, TYPE_NUMBER)
	checktype(from, ang_meta)
	checktype(to, ang_meta)

	return awrap(LerpAngle(percent, aunwrap(from), aunwrap(to)))
end
function math_methods.lerpVector(percent, from, to)
	checkluatype(percent, TYPE_NUMBER)
	checktype(from, vec_meta)
	checktype(to, vec_meta)

	return vwrap(LerpVector(percent, vunwrap(from), vunwrap(to)))
end
--- The math library. http://wiki.garrysmod.com/page/Category:math
-- @name Environment.math
-- @class table
Environment.math = nil



local os_methods = instance.Libraries.os
os_methods.clock = os.clock
os_methods.date = function(format, time)
	if format~=nil and string.find(format, "%%[^%%aAbBcCdDSHeUmMjIpwxXzZyY]") then SF.Throw("Bad date format", 2) end
	return os.date(format, time)
end
os_methods.difftime = os.difftime
os_methods.time = os.time
--- The os library. http://wiki.garrysmod.com/page/Category:os
-- @name Environment.os
-- @class table
Environment.os = nil



local table_methods = instance.Libraries.table
table_methods.add = table.Add
table_methods.clearKeys = table.ClearKeys
table_methods.collapseKeyValue = table.CollapseKeyValue
table_methods.concat = table.concat
table_methods.copyFromTo = table.CopyFromTo
table_methods.count = table.Count
table_methods.empty = table.Empty
table_methods.findNext = table.FindNext
table_methods.findPrev = table.FindPrev
table_methods.forceInsert = table.ForceInsert
table_methods.forEach = table.ForEach
table_methods.foreachi = table.foreachi
table_methods.getFirstKey = table.GetFirstKey
table_methods.getFirstValue = table.GetFirstValue
table_methods.getKeys = table.GetKeys
table_methods.getLastKey = table.GetLastKey
table_methods.getLastValue = table.GetLastValue
table_methods.getn = table.getn
table_methods.getWinningKey = table.GetWinningKey
table_methods.hasValue = table.HasValue
table_methods.inherit = table.Inherit
table_methods.insert = function(a,b,c) if c~=nil then b = math.Clamp(b, 1, 2^31-1) return table.insert(a,b,c) else return table.insert(a,b) end end
table_methods.isSequential = table.IsSequential
table_methods.keyFromValue = table.KeyFromValue
table_methods.keysFromValue = table.KeysFromValue
table_methods.lowerKeyNames = table.LowerKeyNames
table_methods.maxn = table.maxn
table_methods.random = table.Random
table_methods.remove = table.remove
table_methods.removeByValue = table.RemoveByValue
table_methods.reverse = table.Reverse
table_methods.sort = table.sort
table_methods.sortByKey = table.SortByKey
table_methods.sortByMember = table.SortByMember
table_methods.sortDesc = table.SortDesc
table_methods.toString = table.ToString

function table_methods.copy( t, lookup_table )
	if ( t == nil ) then return nil end

	local meta = dgetmeta( t )
	if meta and instance.object_unwrappers[meta] then return t end
	local copy = {}
	setmetatable( copy, meta )
	for i, v in pairs( t ) do
		if ( !istable( v ) ) then
			copy[ i ] = v
		else
			lookup_table = lookup_table or {}
			lookup_table[ t ] = copy
			if ( lookup_table[ v ] ) then
				copy[ i ] = lookup_table[ v ] -- we already copied this table. reuse the copy.
			else
				copy[ i ] = table_methods.copy( v, lookup_table ) -- not yet copied. copy it.
			end
		end
	end
	return copy
end

function table.merge( dest, source )

	for k, v in pairs( source ) do
		local meta = dgetmeta( t )
		if ( istable( v ) and not (meta and instance.object_unwrappers[meta]) and istable( dest[ k ] ) ) then
			table.Merge( dest[ k ], v )
		else
			dest[ k ] = v
		end
	end

	return dest

end

--- Table library. http://wiki.garrysmod.com/page/Category:table
-- @name Environment.table
-- @class table
Environment.table = nil


-- ------------------------- Functions ------------------------- --

--- Gets all libraries
-- @return Table where each key is the library name and value is table of the library
function Environment.getLibraries()
	return instance.Libraries
end

--- Set the value of a table index without invoking a metamethod
--@param table The table to modify
--@param key The index of the table
--@param value The value to set the index equal to
function Environment.rawset(table, key, value)
    checkluatype(table, TYPE_TABLE)

    rawset(table, key, value)
end

--- Gets the value of a table index without invoking a metamethod
--@param table The table to get the value from
--@param key The index of the table
--@return The value of the index
function Environment.rawget(table, key, value)
    checkluatype(table, TYPE_TABLE)

    return rawget(table, key)
end

local function printTableX(t, indent, alreadyprinted)
	local ply = instance.player
	if next(t) then
		for k, v in Environment.pairs(t) do
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
	-- Prints a message to the player's chat.
	-- @shared
	-- @param ... Values to print
	function Environment.print(...)
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
	function Environment.printTable(tbl)
		checkluatype(tbl, TYPE_TABLE)
		printTableX(tbl, 0, { tbl = true })
	end

	--- Execute a console command
	-- @shared
	-- @param cmd Command to execute
	function Environment.concmd(cmd)
		checkluatype(cmd, TYPE_STRING)
		if #cmd > 512 then SF.Throw("Console command is too long!", 2) end
		checkpermission(instance, nil, "console.command")
		instance.player:ConCommand(cmd)
	end

	--- Sets the chip's userdata that the duplicator tool saves. max 1MiB; can be changed with convar sf_userdata_max
	-- @server
	-- @param str String data
	function Environment.setUserdata(str)
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
	function Environment.getUserdata()
		return instance.data.entity.starfalluserdata or ""
	end
else
	--- Sets the chip's display name
	-- @client
	-- @param name Name
	function Environment.setName(name)
		checkluatype(name, TYPE_STRING)
		local e = instance.data.entity
		if (e and e:IsValid()) then
			e.name = string.sub(name, 1, 256)
		end
	end

	--- Sets clipboard text. Only works on the owner of the chip.
	-- @param txt Text to set to the clipboard
	function Environment.setClipboardText(txt)
		if instance.player ~= LocalPlayer() then return end
		checkluatype(txt, TYPE_STRING)
		SetClipboardText(txt)
	end

	--- Prints a message to your chat, console, or the center of your screen.
	-- @param mtype How the message should be displayed. See http://wiki.garrysmod.com/page/Enums/HUD
	-- @param text The message text.
	function Environment.printMessage(mtype, text)
		if instance.player ~= LocalPlayer() then return end
		checkluatype(text, TYPE_STRING)
		instance.player:PrintMessage(mtype, text)
	end

	function Environment.print(...)
		if instance.player == LocalPlayer() then
			chat.AddText(unpack(argsToChat(...)))
		end
	end

	function Environment.printTable(tbl)
		checkluatype(tbl, TYPE_TABLE)
		if instance.player == LocalPlayer() then
			printTableX(tbl, 0, { tbl = true })
		end
	end

	function Environment.concmd(cmd)
		checkluatype(cmd, TYPE_STRING)
		checkpermission(instance, nil, "console.command")
		LocalPlayer():ConCommand(cmd)
	end

	--- Returns the local player's camera angles
	-- @client
	-- @return The local player's camera angles
	function Environment.eyeAngles()
		return awrap(LocalPlayer():EyeAngles())
	end

	--- Returns the local player's camera position
	-- @client
	-- @return The local player's camera position
	function Environment.eyePos()
		return vwrap(LocalPlayer():EyePos())
	end

	--- Returns the local player's camera forward vector
	-- @client
	-- @return The local player's camera forward vector
	function Environment.eyeVector()
		return vwrap(LocalPlayer():GetAimVector())
	end
end

--- Returns the table of scripts used by the chip
-- @return Table of scripts used by the chip
function Environment.getScripts()
	return instance.Sanitize(instance.source)
end

--- Runs an included script and caches the result.
-- Works pretty much like standard Lua require()
-- @param file The file to include. Make sure to --@include it
-- @return Return value of the script
function Environment.require(file)
	checkluatype(file, TYPE_STRING)
	local loaded = instance.requires

	local path
	if string.sub(file, 1, 1)=="/" then
		path = SF.NormalizePath(file)
	else
		path = SF.NormalizePath(instance.requirestack[#instance.requirestack] .. file)
		if not instance.scripts[path] then
			path = SF.NormalizePath(file)
		end
	end

	if loaded[path] then
		return loaded[path]
	else
		local func = instance.scripts[path]
		if not func then SF.Throw("Can't find file '" .. path .. "' (did you forget to --@include it?)", 2) end

		local stacklen = #instance.requirestack + 1
		instance.requirestack[stacklen] = string.GetPathFromFilename(path)
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
function Environment.requiredir(dir, loadpriority)
	checkluatype(dir, TYPE_STRING)
	if loadpriority then checkluatype(loadpriority, TYPE_TABLE) end

	local path
	if string.sub(dir, 1, 1)=="/" then
		path = SF.NormalizePath(dir)
	else
		path = SF.NormalizePath(instance.requirestack[#instance.requirestack] .. dir)
		
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

	if loadpriority then
		for i = 1, #loadpriority do
			for file, _ in pairs(instance.scripts) do
				if file == path .. "/" .. loadpriority[i] then
					returns[file] = Environment.require("/"..file)
				end
			end
		end
	end

	for file, _ in pairs(instance.scripts) do
		if not returns[file] and (string.match(file, "^"..path.."/[^/]+%.txt$") or string.match(file, "^"..path.."/[^/]+%.lua$")) then
			returns[file] = Environment.require("/"..file)
		end
	end

	return returns
end

--- Runs an included script, but does not cache the result.
-- Pretty much like standard Lua dofile()
-- @param file The file to include. Make sure to --@include it
-- @return Return value of the script
function Environment.dofile(file)
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
function Environment.dodir(dir, loadpriority)
	checkluatype(dir, TYPE_STRING)
	if loadpriority then checkluatype(loadpriority, TYPE_TABLE) end

	local returns = {}

	if loadpriority then
		for i = 0, #loadpriority do
			for file, _ in pairs(instance.scripts) do
				if string.find(file, dir .. "/" .. loadpriority[i] , 1) == 1 then
					returns[file] = Environment.dofile(file)
				end
			end
		end
	end

	for file, _ in pairs(instance.scripts) do
		if string.find(file, dir, 1) == 1 then
			returns[file] = Environment.dofile(file)
		end
	end

	return returns
end

--- GLua's loadstring
-- Works like loadstring, except that it executes by default in the main environment
-- @param str String to execute
-- @return Function of str
function Environment.loadstring(str, name)
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
-- @param func Function to change environment of
-- @param tbl New environment
-- @return func with environment set to tbl
function Environment.setfenv(func, tbl)
	if not isfunction(func) or getfenv(func) == _G then SF.Throw("Main Thread is protected!", 2) end
	return setfenv(func, tbl)
end

--- Gets an SF type's methods table
-- @param sfType Name of SF type
-- @return Table of the type's methods which can be edited or iterated
function Environment.getMethods(sfType)
	checkluatype(sfType, TYPE_STRING)
	local typemeta = instance.Types[sfType]
	if not typemeta then SF.Throw("Invalid type") end
	return typemeta.Methods
end

--- Simple version of Lua's getfenv
-- Returns the current environment
-- @return Current environment
function Environment.getfenv()
	local fenv = getfenv(2)
	if fenv ~= _G then return fenv end
end

--- GLua's getinfo()
-- Returns a DebugInfo structure containing the passed function's info (https://wiki.garrysmod.com/page/Structures/DebugInfo)
-- @param funcOrStackLevel Function or stack level to get info about. Defaults to stack level 0.
-- @param fields A string that specifies the information to be retrieved. Defaults to all (flnSu).
-- @return DebugInfo table
function Environment.debugGetInfo(funcOrStackLevel, fields)
	if not isfunction(funcOrStackLevel) and not isnumber(funcOrStackLevel) then SF.ThrowTypeError("function or number", SF.GetType(TfuncOrStackLevel), 2) end
	if fields then checkluatype(fields, TYPE_STRING) end

	local ret = debug.getinfo(funcOrStackLevel, fields)
	if ret then
		ret.func = nil
		return ret
	end
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
function Environment.pcall(func, ...)
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
function Environment.xpcall(func, callback, ...)
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
function Environment.try(func, catch)
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
function Environment.throw(msg, level, uncatchable)
	SF.Throw(msg, 1 + (level or 1), uncatchable)
end

--- Throws a raw exception.
-- @param msg Exception message
-- @param level Which level in the stacktrace to blame. Defaults to 1
function Environment.error(msg, level)
	error(msg or "an unspecified error occured", 1 + (level or 1))
end

--- Returns if the table has an isValid function and isValid returns true.
--@param object Table to check
--@return If it is valid
function Environment.isValid(object)

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
function Environment.worldToLocal(pos, ang, newSystemOrigin, newSystemAngles)
	checktype(pos, vec_meta)
	checktype(ang, ang_meta)
	checktype(newSystemOrigin, vec_meta)
	checktype(newSystemAngles, ang_meta)

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
function Environment.localToWorld(localPos, localAng, originPos, originAngle)
	checktype(localPos, vec_meta)
	checktype(localAng, ang_meta)
	checktype(originPos, vec_meta)
	checktype(originAngle, ang_meta)

	local worldPos, worldAngles = LocalToWorld(
		vunwrap(localPos),
		aunwrap(localAng),
		vunwrap(originPos),
		aunwrap(originAngle)
	)

	return vwrap(worldPos), awrap(worldAngles)
end

--- Creates a 'middleclass' class object that can be used similarly to Java/C++ classes. See https://github.com/kikito/middleclass for examples.
-- @name Environment.class
-- @class function
-- @param name The string name of the class
-- @param super The (optional) parent class to inherit from
Environment.class = SF.Class

end
