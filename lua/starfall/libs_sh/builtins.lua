local checktype = SF.CheckType
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check

-------------------------------------------------------------------------------
-- Builtins.
-- Functions built-in to the default environment
-------------------------------------------------------------------------------

SF.DefaultEnvironment = {}

--- Built in values. These don't need to be loaded; they are in the default environment.
-- @name builtin
-- @shared
-- @class library
-- @libtbl SF.DefaultEnvironment

--- Returns the entity representing a processor that this script is running on.
-- @name SF.DefaultEnvironment.chip
-- @class function
-- @return Starfall entity
SF.DefaultEnvironment.chip = nil

--- Returns whoever created the chip
-- @name SF.DefaultEnvironment.owner
-- @class function
-- @return Owner entity
SF.DefaultEnvironment.owner = nil

--- Same as owner() on the server. On the client, returns the local player
-- @name SF.DefaultEnvironment.player
-- @class function
-- @return Returns player with given UserID or if none specified then returns either the owner (server) or the local player (client)
SF.DefaultEnvironment.player = nil

--- Returns the entity with index 'num'
-- @name SF.DefaultEnvironment.entity
-- @class function
-- @param num Entity index
-- @return entity
SF.DefaultEnvironment.entity = nil

--- Used to select single values from a vararg or get the count of values in it.
-- @name SF.DefaultEnvironment.select
-- @class function
-- @param parameter
-- @param vararg
-- @return Returns a number or vararg, depending on the select method.
SF.DefaultEnvironment.select = select

--- Attempts to convert the value to a string.
-- @name SF.DefaultEnvironment.tostring
-- @class function
-- @param obj
-- @return obj as string
SF.DefaultEnvironment.tostring = tostring

--- Attempts to convert the value to a number.
-- @name SF.DefaultEnvironment.tonumber
-- @class function
-- @param obj
-- @return obj as number
SF.DefaultEnvironment.tonumber = tonumber

--- Returns an iterator function for a for loop, to return ordered key-value pairs from a table.
-- @name SF.DefaultEnvironment.ipairs
-- @class function
-- @param tbl Table to iterate over
-- @return Iterator function
-- @return Table tbl
-- @return 0 as current index
SF.DefaultEnvironment.ipairs = ipairs

--- Returns an iterator function for a for loop that will return the values of the specified table in an arbitrary order.
-- @name SF.DefaultEnvironment.pairs
-- @class function
-- @param tbl Table to iterate over
-- @return Iterator function
-- @return Table tbl
-- @return nil as current index
SF.DefaultEnvironment.pairs = pairs

--- Returns a string representing the name of the type of the passed object.
-- @name SF.DefaultEnvironment.type
-- @class function
-- @param obj Object to get type of
-- @return The name of the object's type.
SF.DefaultEnvironment.type = function(obj)
	local tp = getmetatable(obj)
	return isstring(tp) and tp or type(obj)
end

--- Returns the next key and value pair in a table.
-- @name SF.DefaultEnvironment.next
-- @class function
-- @param tbl Table to get the next key-value pair of
-- @param k Previous key (can be nil)
-- @return Key or nil
-- @return Value or nil
SF.DefaultEnvironment.next = next

--- If the result of the first argument is false or nil, an error is thrown with the second argument as the message.
-- @name SF.DefaultEnvironment.assert
-- @class function
-- @param condition
-- @param msg
SF.DefaultEnvironment.assert = function (condition, msg) if not condition then SF.Throw(msg or "assertion failed!", 2) else return condition end end

--- This function takes a numeric indexed table and return all the members as a vararg.
-- @name SF.DefaultEnvironment.unpack
-- @class function
-- @param tbl
-- @return Elements of tbl
SF.DefaultEnvironment.unpack = unpack

--- Sets, changes or removes a table's metatable. Doesn't work on most internal metatables
-- @name SF.DefaultEnvironment.setmetatable
-- @class function
-- @param tbl The table to set the metatable of
-- @param meta The metatable to use
-- @return tbl with metatable set to meta
SF.DefaultEnvironment.setmetatable = setmetatable

--- Returns the metatable of an object. Doesn't work on most internal metatables
-- @param tbl Table to get metatable of
-- @return The metatable of tbl
SF.DefaultEnvironment.getmetatable = function(tbl)
	checkluatype (tbl, TYPE_TABLE)
	return getmetatable(tbl)
end

--- Generates the CRC checksum of the specified string. (https://en.wikipedia.org/wiki/Cyclic_redundancy_check)
-- @name SF.DefaultEnvironment.crc
-- @class function
-- @param stringToHash The string to calculate the checksum of
-- @return The unsigned 32 bit checksum as a string
SF.DefaultEnvironment.crc = util.CRC

--- Constant that denotes whether the code is executed on the client
-- @name SF.DefaultEnvironment.CLIENT
-- @class field
SF.DefaultEnvironment.CLIENT = CLIENT

--- Constant that denotes whether the code is executed on the server
-- @name SF.DefaultEnvironment.SERVER
-- @class field
SF.DefaultEnvironment.SERVER = SERVER

--- Returns if this is the first time this hook was predicted.
-- @name SF.DefaultEnvironment.isFirstTimePredicted
-- @class function
-- @return Boolean
SF.DefaultEnvironment.isFirstTimePredicted = IsFirstTimePredicted

--- Returns the current count for this Think's CPU Time.
-- This value increases as more executions are done, may not be exactly as you want.
-- If used on screens, will show 0 if only rendering is done. Operations must be done in the Think loop for them to be counted.
-- @return Current quota used this Think
function SF.DefaultEnvironment.quotaUsed ()
	return SF.instance.cpu_total
end

--- Gets the Average CPU Time in the buffer
-- @return Average CPU Time of the buffer.
function SF.DefaultEnvironment.quotaAverage ()
	return SF.instance:movingCPUAverage()
end

--- Gets the starfall version
-- @return Starfall version
function SF.DefaultEnvironment.version ()
	return SF.Version
end

--- Returns the total used time for all chips by the player.
-- @return Total used CPU time of all your chips.
function SF.DefaultEnvironment.quotaTotalUsed ()
	local total = 0
	for instance, _ in pairs(SF.playerInstances[SF.instance.player]) do
		total = total + instance.cpu_total
	end
	return total
end

--- Returns the total average time for all chips by the player.
-- @return Total average CPU Time of all your chips.
function SF.DefaultEnvironment.quotaTotalAverage ()
	local total = 0
	for instance, _ in pairs(SF.playerInstances[SF.instance.player]) do
		total = total + instance:movingCPUAverage()
	end
	return total
end

--- Gets the CPU Time max.
-- CPU Time is stored in a buffer of N elements, if the average of this exceeds quotaMax, the chip will error.
-- @return Max SysTime allowed to take for execution of the chip in a Think.
function SF.DefaultEnvironment.quotaMax ()
	return SF.instance.cpuQuota
end

--- Sets a CPU soft quota which will trigger a catchable error if the cpu goes over a certain amount.
-- @param quota The threshold where the soft error will be thrown. Ratio of current cpu to the max cpu usage. 0.5 is 50%
function SF.DefaultEnvironment.setSoftQuota (quota)
	checkluatype (quota, TYPE_NUMBER)
	SF.instance.cpu_softquota = quota
end

--- Checks if the chip is capable of performing an action.
--@param perm The permission id to check
--@param obj Optional object to pass to the permission system.
function SF.DefaultEnvironment.hasPermission(perm, obj)
	checkluatype (perm, TYPE_STRING)
	if not SF.Permissions.permissionchecks[perm] then SF.Throw("Permission doesn't exist", 2) end
	return SF.Permissions.hasAccess(SF.instance, SF.UnwrapObject(obj), perm)
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
	function SF.DefaultEnvironment.setupPermissionRequest( perms, desc, showOnUse )
		checkluatype ( desc, TYPE_STRING )
		checkluatype ( perms, TYPE_TABLE )
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
		SF.instance.permissionRequest = {}
		SF.instance.permissionRequest.overrides = overrides
		SF.instance.permissionRequest.description = string.gsub( desc, '%s+$', '' )
		SF.instance.permissionRequest.showOnUse = showOnUse == true

	end

	--- Is permission request fully satisfied.
	--@return Boolean of whether the client gave all permissions specified in last request or not.
	--@client
	function SF.DefaultEnvironment.permissionRequestSatisfied()
		return SF.Permissions.permissionRequestSatisfied( SF.instance )
	end

end

-- String library
local string_methods = SF.RegisterLibrary("string")
string_methods.byte = string.byte string_methods.byte = string.byte
string_methods.char = string.char
string_methods.comma = string.Comma string_methods.Comma = string.Comma
string_methods.dump = string.dump
string_methods.endsWith = string.EndsWith string_methods.EndsWith = string.EndsWith
string_methods.explode = string.Explode string_methods.Explode = string.Explode
string_methods.find = string.find
string_methods.format = string.format
string_methods.formattedTime = string.FormattedTime string_methods.FormattedTime = string.FormattedTime
string_methods.getChar = string.GetChar string_methods.GetChar = string.GetChar
string_methods.getExtensionFromFilename = string.GetExtensionFromFilename string_methods.GetExtensionFromFilename = string.GetExtensionFromFilename
string_methods.getFileFromFilename = string.GetFileFromFilename string_methods.GetFileFromFilename = string.GetFileFromFilename
string_methods.getPathFromFilename = string.GetPathFromFilename string_methods.GetPathFromFilename = string.GetPathFromFilename
string_methods.gfind = string.gfind
string_methods.gmatch = string.gmatch
string_methods.gsub = string.gsub
string_methods.implode = string.Implode string_methods.Implode = string.Implode
local function javascriptSafe(str)
	checkluatype (str, TYPE_STRING)
	return string.JavascriptSafe(str)
end
string_methods.javascriptSafe = javascriptSafe string_methods.JavascriptSafe = javascriptSafe
string_methods.left = string.Left string_methods.Left = string.Left
string_methods.len = string.len
string_methods.lower = string.lower
string_methods.match = string.match
string_methods.niceSize = string.NiceSize string_methods.NiceSize = string.NiceSize
string_methods.niceTime = string.NiceTime string_methods.NiceTime = string.NiceTime
local function patternSafe(str)
	checkluatype (str, TYPE_STRING)
	return string.PatternSafe(str)
end
string_methods.patternSafe = patternSafe string_methods.PatternSafe = patternSafe
string_methods.replace = string.Replace string_methods.Replace = string.Replace
string_methods.reverse = string.reverse
string_methods.right = string.Right string_methods.Right = string.Right
string_methods.setChar = string.SetChar string_methods.SetChar = string.SetChar
string_methods.split = string.Split string_methods.Split = string.Split
string_methods.startWith = string.StartWith string_methods.StartWith = string.StartWith
string_methods.stripExtension = string.StripExtension string_methods.StripExtension = string.StripExtension
string_methods.sub = string.sub
string_methods.toMinutesSeconds = string.ToMinutesSeconds string_methods.ToMinutesSeconds = string.ToMinutesSeconds
string_methods.toMinutesSecondsMilliseconds = string.ToMinutesSecondsMilliseconds string_methods.ToMinutesSecondsMilliseconds = string.ToMinutesSecondsMilliseconds
string_methods.toTable = string.ToTable string_methods.ToTable = string.ToTable
string_methods.trim = string.Trim string_methods.Trim = string.Trim
string_methods.trimLeft = string.TrimLeft string_methods.TrimLeft = string.TrimLeft
string_methods.trimRight = string.TrimRight string_methods.TrimRight = string.TrimRight
string_methods.upper = string.upper
string_methods.normalizePath = SF.NormalizePath

--UTF8 part
string_methods.utf8char = utf8.char
string_methods.utf8codepoint = utf8.codepoint
string_methods.utf8codes = utf8.codes
string_methods.utf8force = utf8.force
string_methods.utf8len = utf8.len
string_methods.utf8offset = utf8.offset

local rep_chunk = 1000000
function string_methods.rep(str, rep, sep)
	if rep < 0.5 then return "" end

	local ret = {}
	for i = 1, rep / rep_chunk do
		ret[#ret + 1] = string.rep(str, rep_chunk, sep)
	end

	local r = rep%rep_chunk
	if r>0.5 then
		ret[#ret + 1] = string.rep(str, r, sep)
	end

	return table.concat(ret, sep)
end
function string_methods.fromColor(color)
	return string.FromColor(SF.UnwrapObject(color))
end
function string_methods.toColor(str)
	return SF.WrapObject(string.ToColor(str))
end
--- String library http://wiki.garrysmod.com/page/Category:string
-- @name SF.DefaultEnvironment.string
-- @class table
SF.DefaultEnvironment.string = nil



local math_methods = SF.RegisterLibrary("math")
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
	return SF.WrapObject(math.BSplinePoint(tDiff, SF.Unsanitize(tPoints), tMax))
end
function math_methods.lerp(percent, from, to)
	checkluatype (percent, TYPE_NUMBER)
	checkluatype (from, TYPE_NUMBER)
	checkluatype (to, TYPE_NUMBER)

	return Lerp(percent, from, to)
end
function math_methods.lerpAngle(percent, from, to)
	checkluatype (percent, TYPE_NUMBER)
	checktype(from, SF.Types["Angle"])
	checktype(to, SF.Types["Angle"])

	return SF.WrapObject(LerpAngle(percent, SF.UnwrapObject(from), SF.UnwrapObject(to)))
end
function math_methods.lerpVector(percent, from, to)
	checkluatype (percent, TYPE_NUMBER)
	checktype(from, SF.Types["Vector"])
	checktype(to, SF.Types["Vector"])

	return SF.WrapObject(LerpVector(percent, SF.UnwrapObject(from), SF.UnwrapObject(to)))
end
--- The math library. http://wiki.garrysmod.com/page/Category:math
-- @name SF.DefaultEnvironment.math
-- @class table
SF.DefaultEnvironment.math = nil



local os_methods = SF.RegisterLibrary("os")
os_methods.clock = os.clock
os_methods.date = function(format, time)
	if format~=nil and string.find(format, "%%[^%%aAbBcCdDSHeUmMjIpwxXzZyY]") then SF.Throw("Bad date format", 2) end
	return os.date(format, time)
end
os_methods.difftime = os.difftime
os_methods.time = os.time
--- The os library. http://wiki.garrysmod.com/page/Category:os
-- @name SF.DefaultEnvironment.os
-- @class table
SF.DefaultEnvironment.os = nil



local table_methods = SF.RegisterLibrary("table")
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
table_methods.insert = table.insert
table_methods.isSequential = table.IsSequential
table_methods.keyFromValue = table.KeyFromValue
table_methods.keysFromValue = table.KeysFromValue
table_methods.lowerKeyNames = table.LowerKeyNames
table_methods.maxn = table.maxn
table_methods.merge = table.Merge
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

	local meta = debug.getmetatable( t )
	if SF.Types[meta] then return t end
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

--- Table library. http://wiki.garrysmod.com/page/Category:table
-- @name SF.DefaultEnvironment.table
-- @class table
SF.DefaultEnvironment.table = nil


-- ------------------------- Functions ------------------------- --

--- Gets a list of all libraries
-- @return Table containing the names of each available library
function SF.DefaultEnvironment.getLibraries()
	local ret = {}
	for k, v in pairs(SF.Libraries) do
		ret[#ret + 1] = k
	end
	return ret
end

--- Set the value of a table index without invoking a metamethod
--@param table The table to modify
--@param key The index of the table
--@param value The value to set the index equal to
function SF.DefaultEnvironment.rawset(table, key, value)
    checkluatype (table, TYPE_TABLE)

    rawset(table, key, value)
end

--- Gets the value of a table index without invoking a metamethod
--@param table The table to get the value from
--@param key The index of the table
--@return The value of the index
function SF.DefaultEnvironment.rawget(table, key, value)
    checkluatype (table, TYPE_TABLE)

    return rawget(table, key)
end

local luaTypes = {
	nil,
	true,
	0,
	function() end,
	coroutine.create(function() end)
}
for i = 1, 5 do
	local luaType = luaTypes[i]
	local meta = debug.getmetatable(luaType)
	if meta then
		SF.AddHook("prepare", function()
			debug.setmetatable(luaType, nil)
		end)
		SF.AddHook("cleanup", function()
			debug.setmetatable(luaType, meta)
		end)
	end
end
local gluastr = debug.getmetatable("")
local string_methods_copy = table.Copy(string_methods)
SF.AddHook("prepare", function()
	debug.setmetatable("", { __index = function(self, key)
		local val = string_methods_copy[key]
		if (val) then
			return val
		elseif (tonumber(key)) then
			return self:sub(key, key)
		else
			SF.Throw("attempt to index a string value with bad key ('" .. tostring(key) .. "' is not part of the string library)", 2)
		end
	end })
end)
SF.AddHook("cleanup", function()
	debug.setmetatable("", gluastr)
end)

SF.Permissions.registerPrivilege("console.command", "Console command", "Allows the starfall to run console commands", { client = { default = 4 } })
local function printTableX (t, indent, alreadyprinted)
	if next(t) then
		for k, v in SF.DefaultEnvironment.pairs(t) do
			if SF.GetType(v) == "table" and not alreadyprinted[v] then
				alreadyprinted[v] = true
				SF.instance.player:ChatPrint(string.rep("\t", indent) .. tostring(k) .. ":")
				printTableX(v, indent + 1, alreadyprinted)
			else
				SF.instance.player:ChatPrint(string.rep("\t", indent) .. tostring(k) .. "\t=\t" .. tostring(v))
			end
		end
	else
		SF.instance.player:ChatPrint(string.rep("\t", indent).."{}")
	end
end

if SERVER then
	local userdataLimit = CreateConVar("sf_userdata_max", "1048576", { FCVAR_ARCHIVE }, "The maximum size of userdata (in bytes) that can be stored on a Starfall chip (saved in duplications).")

	-- Prints a message to the player's chat.
	-- @shared
	-- @param ... Values to print
	function SF.DefaultEnvironment.print(...)
		SF.ChatPrint(SF.instance.player, ...)
	end

	--- Prints a table to player's chat
	-- @param tbl Table to print
	function SF.DefaultEnvironment.printTable (tbl)
		checkluatype (tbl, TYPE_TABLE)
		printTableX(tbl, 0, { tbl = true })
	end

	--- Execute a console command
	-- @shared
	-- @param cmd Command to execute
	function SF.DefaultEnvironment.concmd (cmd)
		checkluatype (cmd, TYPE_STRING)
		if #cmd > 512 then SF.Throw("Console command is too long!", 2) end
		checkpermission(SF.instance, nil, "console.command")
		SF.instance.player:ConCommand(cmd)
	end

	--- Sets the chip's userdata that the duplicator tool saves. max 1MiB; can be changed with convar sf_userdata_max
	-- @server
	-- @param str String data
	function SF.DefaultEnvironment.setUserdata(str)
		checkluatype (str, TYPE_STRING)
		local max = userdataLimit:GetInt()
		if #str>max then
			SF.Throw("The userdata limit is " .. string.Comma(max) .. " bytes", 2)
		end
		SF.instance.data.entity.starfalluserdata = str
	end

	--- Gets the chip's userdata that the duplicator tool loads
	-- @server
	-- @return String data
	function SF.DefaultEnvironment.getUserdata()
		return SF.instance.data.entity.starfalluserdata or ""
	end
else
	--- Sets the chip's display name
	-- @client
	-- @param name Name
	function SF.DefaultEnvironment.setName(name)
		checkluatype (name, TYPE_STRING)
		local e = SF.instance.data.entity
		if IsValid(e) then
			e.name = string.sub(name, 1, 256)
		end
	end

	--- Sets clipboard text. Only works on the owner of the chip.
	-- @param txt Text to set to the clipboard
	function SF.DefaultEnvironment.setClipboardText(txt)
		if SF.instance.player ~= LocalPlayer() then return end
		checkluatype (txt, TYPE_STRING)
		SetClipboardText(txt)
	end

	--- Prints a message to your chat, console, or the center of your screen.
	-- @param mtype How the message should be displayed. See http://wiki.garrysmod.com/page/Enums/HUD
	-- @param text The message text.
	function SF.DefaultEnvironment.printMessage(mtype, text)
		if SF.instance.player ~= LocalPlayer() then return end
		checkluatype (text, TYPE_STRING)
		SF.instance.player:PrintMessage(mtype, text)
	end

	function SF.DefaultEnvironment.print(...)
		if SF.instance.player == LocalPlayer() then
			SF.ChatPrint(...)
		end
	end

	function SF.DefaultEnvironment.printTable (tbl)
		checkluatype (tbl, TYPE_TABLE)
		if SF.instance.player == LocalPlayer() then
			printTableX(tbl, 0, { tbl = true })
		end
	end

	function SF.DefaultEnvironment.concmd (cmd)
		checkluatype (cmd, TYPE_STRING)
		checkpermission(SF.instance, nil, "console.command")
		LocalPlayer():ConCommand(cmd)
	end

	--- Returns the local player's camera angles
	-- @client
	-- @return The local player's camera angles
	function SF.DefaultEnvironment.eyeAngles ()
		return SF.WrapObject(LocalPlayer():EyeAngles())
	end

	--- Returns the local player's camera position
	-- @client
	-- @return The local player's camera position
	function SF.DefaultEnvironment.eyePos()
		return SF.WrapObject(LocalPlayer():EyePos())
	end

	--- Returns the local player's camera forward vector
	-- @client
	-- @return The local player's camera forward vector
	function SF.DefaultEnvironment.eyeVector()
		return SF.WrapObject(LocalPlayer():GetAimVector())
	end
end

--- Runs an included script and caches the result.
-- Works pretty much like standard Lua require()
-- @param file The file to include. Make sure to --@include it
-- @return Return value of the script
function SF.DefaultEnvironment.require(file)
	checkluatype (file, TYPE_STRING)
	local loaded = SF.instance.requires

	local path
	if string.sub(file, 1, 1)=="/" then
		path = SF.NormalizePath(file)
	else
		path = SF.NormalizePath(SF.instance.requirestack[#SF.instance.requirestack] .. file)
		if not SF.instance.scripts[path] then
			path = SF.NormalizePath(file)
		end
	end

	if loaded[path] then
		return loaded[path]
	else
		local func = SF.instance.scripts[path]
		if not func then SF.Throw("Can't find file '" .. path .. "' (did you forget to --@include it?)", 2) end

		local stacklen = #SF.instance.requirestack + 1
		SF.instance.requirestack[stacklen] = string.GetPathFromFilename(path)
		local ok, ret = pcall(func)
		SF.instance.requirestack[stacklen] = nil

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
function SF.DefaultEnvironment.requiredir(dir, loadpriority)
	checkluatype (dir, TYPE_STRING)
	if loadpriority then checkluatype (loadpriority, TYPE_TABLE) end

	local path
	if string.sub(dir, 1, 1)=="/" then
		path = SF.NormalizePath(dir)
	else
		path = SF.NormalizePath(SF.instance.requirestack[#SF.instance.requirestack] .. dir)
		
		-- If no scripts found in relative dir, try the root dir.
		local foundScript = false
		for file, _ in pairs(SF.instance.scripts) do
			if string.match(file, "^"..path.."/[^/]+%.txt$") then
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
			for file, _ in pairs(SF.instance.scripts) do
				if file == path .. "/" .. loadpriority[i] then
					returns[file] = SF.DefaultEnvironment.require("/"..file)
				end
			end
		end
	end

	for file, _ in pairs(SF.instance.scripts) do
		if not returns[file] and string.match(file, "^"..path.."/[^/]+%.txt$") then
			returns[file] = SF.DefaultEnvironment.require("/"..file)
		end
	end

	return returns
end

--- Runs an included script, but does not cache the result.
-- Pretty much like standard Lua dofile()
-- @param file The file to include. Make sure to --@include it
-- @return Return value of the script
function SF.DefaultEnvironment.dofile(file)
	checkluatype (file, TYPE_STRING)
	local path
	if string.sub(file, 1, 1)=="/" then
		path = SF.NormalizePath(file)
	else
		path = SF.NormalizePath(string.GetPathFromFilename(string.sub(debug.getinfo(2, "S").source, 5)) .. file)
		if not SF.instance.scripts[path] then
			path = SF.NormalizePath(file)
		end
	end
	local func = SF.instance.scripts[path]
	if not func then SF.Throw("Can't find file '" .. path .. "' (did you forget to --@include it?)", 2) end
	return func()
end

--- Runs an included directory, but does not cache the result.
-- @param dir The directory to include. Make sure to --@includedir it
-- @param loadpriority Table of files that should be loaded before any others in the directory
-- @return Table of return values of the scripts
function SF.DefaultEnvironment.dodir(dir, loadpriority)
	checkluatype (dir, TYPE_STRING)
	if loadpriority then checkluatype (loadpriority, TYPE_TABLE) end

	local returns = {}

	if loadpriority then
		for i = 0, #loadpriority do
			for file, _ in pairs(SF.instance.scripts) do
				if string.find(file, dir .. "/" .. loadpriority[i] , 1) == 1 then
					returns[file] = SF.DefaultEnvironment.dofile(file)
				end
			end
		end
	end

	for file, _ in pairs(SF.instance.scripts) do
		if string.find(file, dir, 1) == 1 then
			returns[file] = SF.DefaultEnvironment.dofile(file)
		end
	end

	return returns
end

--- GLua's loadstring
-- Works like loadstring, except that it executes by default in the main environment
-- @param str String to execute
-- @return Function of str
function SF.DefaultEnvironment.loadstring (str, name)
	name = "SF:" .. (name or tostring(SF.instance.env))
	local func = SF.CompileString(str, name, false)

	-- CompileString returns an error as a string, better check before setfenv
	if isfunction(func) then
		return setfenv(func, SF.instance.env)
	end

	return func
end

--- Lua's setfenv
-- Works like setfenv, but is restricted on functions
-- @param func Function to change environment of
-- @param tbl New environment
-- @return func with environment set to tbl
function SF.DefaultEnvironment.setfenv (func, tbl)
	if not isfunction(func) or getfenv(func) == _G then SF.Throw("Main Thread is protected!", 2) end
	return setfenv(func, tbl)
end

--- Simple version of Lua's getfenv
-- Returns the current environment
-- @return Current environment
function SF.DefaultEnvironment.getfenv ()
	local fenv = getfenv(2)
	if fenv ~= _G then return fenv end
end

--- GLua's getinfo()
-- Returns a DebugInfo structure containing the passed function's info (https://wiki.garrysmod.com/page/Structures/DebugInfo)
-- @param funcOrStackLevel Function or stack level to get info about. Defaults to stack level 0.
-- @param fields A string that specifies the information to be retrieved. Defaults to all (flnSu).
-- @return DebugInfo table
function SF.DefaultEnvironment.debugGetInfo (funcOrStackLevel, fields)
	if not isfunction(funcOrStackLevel) and not isnumber(funcOrStackLevel) then SF.ThrowTypeError("function or number", SF.GetType(TfuncOrStackLevel), 2) end
	if fields then checkluatype (fields, TYPE_STRING) end

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
function SF.DefaultEnvironment.pcall (func, ...)
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

	return false, SF.Sanitize({err})[1]
end

local function xpcall_Callback (err)
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
function SF.DefaultEnvironment.xpcall (func, callback, ...)
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

	return false, callback(SF.Sanitize({err})[1], traceback)
end

--- Try to execute a function and catch possible exceptions
-- Similar to xpcall, but a bit more in-depth
-- @param func Function to execute
-- @param catch Optional function to execute in case func fails
function SF.DefaultEnvironment.try (func, catch)
	local ok, err = pcall(func)
	if ok then return end

	if istable(err) then
		if err.uncatchable then
			error(err)
		end
	elseif uncatchable[err] then
		SF.Throw(err, 2, true)
	end
	if catch then catch(SF.Sanitize({err})[1]) end
end


--- Throws an exception
-- @param msg Message string
-- @param level Which level in the stacktrace to blame. Defaults to 1
-- @param uncatchable Makes this exception uncatchable
function SF.DefaultEnvironment.throw (msg, level, uncatchable)
	SF.Throw (msg, 1 + (level or 1), uncatchable)
end

--- Throws a raw exception.
-- @param msg Exception message
-- @param level Which level in the stacktrace to blame. Defaults to 1
function SF.DefaultEnvironment.error (msg, level)
	error(msg or "an unspecified error occured", 1 + (level or 1))
end

--- Returns if the table has an isValid function and isValid returns true.
--@param object Table to check
--@return If it is valid
function SF.DefaultEnvironment.isValid(object)

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
function SF.DefaultEnvironment.worldToLocal(pos, ang, newSystemOrigin, newSystemAngles)
	checktype(pos, SF.Types["Vector"])
	checktype(ang, SF.Types["Angle"])
	checktype(newSystemOrigin, SF.Types["Vector"])
	checktype(newSystemAngles, SF.Types["Angle"])

	local localPos, localAngles = WorldToLocal(
		SF.UnwrapObject(pos),
		SF.UnwrapObject(ang),
		SF.UnwrapObject(newSystemOrigin),
		SF.UnwrapObject(newSystemAngles)
	)

	return SF.WrapObject(localPos), SF.WrapObject(localAngles)
end

--- Translates the specified position and angle from the specified local coordinate system
-- @param localPos The position vector that should be translated to world coordinates
-- @param localAng The angle that should be converted to a world angle
-- @param originPos The origin point of the source coordinate system, in world coordinates
-- @param originAngle The angles of the source coordinate system, as a world angle
-- @return worldPos
-- @return worldAngles
function SF.DefaultEnvironment.localToWorld(localPos, localAng, originPos, originAngle)
	checktype(localPos, SF.Types["Vector"])
	checktype(localAng, SF.Types["Angle"])
	checktype(originPos, SF.Types["Vector"])
	checktype(originAngle, SF.Types["Angle"])

	local worldPos, worldAngles = LocalToWorld(
		SF.UnwrapObject(localPos),
		SF.UnwrapObject(localAng),
		SF.UnwrapObject(originPos),
		SF.UnwrapObject(originAngle)
	)

	return SF.WrapObject(worldPos), SF.WrapObject(worldAngles)
end
