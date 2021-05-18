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

--- Lua debug library https://wiki.garrysmod.com/page/Category:debug
-- @name debug
-- @class library
-- @libtbl debug_library
SF.RegisterLibrary("debug")

return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local owrap, ounwrap = instance.WrapObject, instance.UnwrapObject
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local col_meta, cwrap, cunwrap = instance.Types.Color, instance.Types.Color.Wrap, instance.Types.Color.Unwrap

local builtins_library = instance.env

local getent
local getply
instance:AddHook("initialize", function()
	getent = instance.Types.Entity.GetEntity
	getply = instance.Types.Player.GetPlayer
end)

--- Built in values. These don't need to be loaded; they are in the default builtins_library.
-- @name builtins
-- @shared
-- @class library
-- @libtbl builtins_library

--- Returns the entity representing a processor that this script is running on.
-- @return Entity Starfall chip entity
function builtins_library.chip()
	return ewrap(instance.entity)
end

--- Returns whoever created the chip
-- @return Player Owner of the chip
function builtins_library.owner()
	return instance.Types.Player.Wrap(instance.player)
end

--- Same as owner() on the server. On the client, returns the local player
-- @param number? num UserID to get the player with.
-- @return Player Returns player with given UserID or if none specified then returns either the owner (server) or the local player (client)
function builtins_library.player(num)
	if num~=nil then
		checkluatype(num, TYPE_NUMBER)
		return instance.Types.Player.Wrap(Player(num))
	end

	return SERVER and builtins_library.owner() or instance.Types.Player.Wrap(LocalPlayer())
end


--- Returns the entity with index 'num'
-- @param number num Entity index
-- @return Entity Entity at the index
function builtins_library.entity(num)
	checkluatype(num, TYPE_NUMBER)
	return owrap(Entity(num))
end


--- Used to select single values from a vararg or get the count of values in it.
-- @name builtins_library.select
-- @class function
-- @param any parameter
-- @param ... vararg Args to select from
-- @return any Returns a number or vararg, depending on the select method.
builtins_library.select = select

--- Attempts to convert the value to a string.
-- @name builtins_library.tostring
-- @class function
-- @param any obj Object to turn into a string
-- @return string Object as a string
builtins_library.tostring = tostring

--- Attempts to convert the value to a number.
-- @name builtins_library.tonumber
-- @class function
-- @param any obj Object to turn into a number
-- @return number? The object as a number or nil if it couldn't be converted
builtins_library.tonumber = tonumber

--- Returns an iterator function for a for loop, to return ordered key-value pairs from a table.
-- @name builtins_library.ipairs
-- @class function
-- @param table tbl Table to iterate over
-- @return function Iterator function
-- @return table Table being iterated over
-- @return number Origin index. Equals 0.
builtins_library.ipairs = ipairs

--- Returns an iterator function for a for loop that will return the values of the specified table in an arbitrary order.
-- @name builtins_library.pairs
-- @class function
-- @param table tbl Table to iterate over
-- @return function Iterator function
-- @return table Table being iterated over
-- @return any Nil as current index (for the constructor)
builtins_library.pairs = pairs

--- Returns a string representing the name of the type of the passed object.
-- @name builtins_library.type
-- @param any obj Object to get type of
-- @return string The name of the object's type.
function builtins_library.type(obj)
	local tp = getmetatable(obj)
	return isstring(tp) and tp or type(obj)
end

--- Returns the next key and value pair in a table.
-- @name builtins_library.next
-- @class function
-- @param table tbl Table to get the next key-value pair of
-- @param any k Previous key (can be nil)
-- @return any Key or nil
-- @return any Value or nil
builtins_library.next = next

--- This function takes a numeric indexed table and return all the members as a vararg.
-- @name builtins_library.unpack
-- @class function
-- @param table tbl To get elements out of
-- @return ... Elements of tbl
builtins_library.unpack = unpack

--- Sets, changes or removes a table's metatable. Doesn't work on most internal metatables
-- @name builtins_library.setmetatable
-- @class function
-- @param table tbl The table to set the metatable of
-- @param table meta The metatable to use
-- @return table tbl with metatable set to meta
builtins_library.setmetatable = setmetatable

--- Returns the metatable of an object. Doesn't work on most internal metatables
-- @param table tbl Table to get metatable of
-- @return table The metatable of tbl
builtins_library.getmetatable = function(tbl)
	checkluatype(tbl, TYPE_TABLE)
	return getmetatable(tbl)
end

--- Generates the CRC checksum of the specified string. (https://en.wikipedia.org/wiki/Cyclic_redundancy_check)
-- @name builtins_library.crc
-- @class function
-- @param string stringToHash The string to calculate the checksum of
-- @return string The unsigned 32 bit checksum as a string
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
-- @return boolean Whether this is the first time this hook was predicted
builtins_library.isFirstTimePredicted = IsFirstTimePredicted

--- Returns the current count for this Think's CPU Time.
-- This value increases as more executions are done, may not be exactly as you want.
-- If used on screens, will show 0 if only rendering is done. Operations must be done in the Think loop for them to be counted.
-- @return number Current quota used this Think
function builtins_library.quotaUsed()
	return instance.cpu_total
end

--- Gets the Average CPU Time in the buffer
-- @return number Average CPU Time of the buffer.
function builtins_library.quotaAverage()
	return instance:movingCPUAverage()
end

--- Gets the current ram usage of the gmod lua environment
-- @return number The ram used in kilobytes
function builtins_library.ramUsed()
	return SF.Instance.Ram
end

--- Gets the moving average of ram usage of the gmod lua environment
-- @return number The ram used in kilobytes
function builtins_library.ramAverage()
	return SF.Instance.RamAvg
end

--- Gets the max allowed ram usage of the gmod lua environment
-- @return number The max ram usage in kilobytes
function builtins_library.ramMax()
	return SF.RamCap:GetInt()
end

--- Gets the starfall version
-- @return string Starfall version
function builtins_library.version()
	if SERVER then
		return SF.Version
	else
		return GetGlobalString("SF.Version")
	end
end

--- Returns the total used time for all chips by the player.
-- @return number Total used CPU time of all your chips.
function builtins_library.quotaTotalUsed()
	local total = 0
	for instance, _ in pairs(SF.playerInstances[instance.player]) do
		total = total + instance.cpu_total
	end
	return total
end

--- Returns the total average time for all chips by the player.
-- @return number Total average CPU Time of all your chips.
function builtins_library.quotaTotalAverage()
	local total = 0
	for instance, _ in pairs(SF.playerInstances[instance.player]) do
		total = total + instance:movingCPUAverage()
	end
	return total
end

--- Gets the CPU Time max.
-- CPU Time is stored in a buffer of N elements, if the average of this exceeds quotaMax, the chip will error.
-- @return number Max SysTime allowed to take for execution of the chip in a Think.
function builtins_library.quotaMax()
	return instance.cpuQuota
end

--- Sets a CPU soft quota which will trigger a catchable error if the cpu goes over a certain amount.
-- @param number quota The threshold where the soft error will be thrown. Ratio of current cpu to the max cpu usage. 0.5 is 50%
function builtins_library.setSoftQuota(quota)
	checkluatype(quota, TYPE_NUMBER)
	instance.cpu_softquota = quota
end

--- Checks if the chip is capable of performing an action.
-- @param string perm The permission id to check
-- @param any obj Optional object to pass to the permission system.
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
	-- @param table perms Table of overridable permissions' names.
	-- @param string desc Description attached to request.
	-- @param boolean showOnUse Whether request will popup when player uses chip or linked screen.
	-- @client
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
	-- @return boolean Whether the client gave all permissions specified in last request or not.
	-- @client
	function builtins_library.permissionRequestSatisfied()
		return SF.Permissions.permissionRequestSatisfied( instance )
	end

	local sentPermRequest = false
	--- Opens the permission request dialogue if the player is connected to HUD. setupPermissionRequest must be called first
	-- @client
	function builtins_library.sendPermissionRequest()
		if not SF.IsHUDActive(instance.entity) then SF.Throw("Player isn't connected to HUD!", 2) end
		if sentPermRequest then SF.Throw("Can only send the permission request once!", 2) end
		if instance.permissionRequest and not SF.Permissions.permissionRequestSatisfied( instance ) and not IsValid(SF.permPanel) then
			sentPermRequest = true
			local pnl = vgui.Create("SFChipPermissions")
			if pnl then
				pnl:OpenForChip(instance.entity)
				SF.permPanel = pnl
			end
		end
	end

end


local os_library = instance.Libraries.os

--- Returns the approximate cpu time the application ran.
-- This function has different precision on Linux (1/100).
-- @class function
-- @return number The runtime
os_library.clock = os.clock

--- Returns the date/time as a formatted string or in a table.
-- See https://wiki.facepunch.com/gmod/Structures/DateData for the table structure
-- @class function
-- @param string format The format string. If starts with an '!', it will use UTC timezone rather than the local timezone
-- @param number? time Time to use for the format. Default os.time()
-- @return string|table If format is equal to '*t' or '!*t' then it will return a table with DateData structure, otherwise a string
os_library.date = function(format, time)
	if format~=nil then
		for v in string.gmatch(format, "%%(.?)") do if not string.match(v, "[%%aAbBcCdDSHeUmMjIpwxXzZyY]") then SF.Throw("Bad date format", 2) end end
	end
	return os.date(format, time)
end

--- Subtracts the second of the first value and rounds the result
-- @class function
-- @param number timeA The first value
-- @param number timeB The value to subtract
-- @return number Time difference
os_library.difftime = os.difftime

--- Returns the system time in seconds past the unix epoch.
-- If a table is supplied, the function attempts to build a system time with the specified table members
-- @class function
-- @param table? dateData Optional table to generate the time from. This table's data is interpreted as being in the local timezone
-- @return number Seconds passed since Unix epoch
os_library.time = os.time


-- ------------------------- Functions ------------------------- --

--- Gets all libraries
-- @return table Table where each key is the library name and value is table of the library
function builtins_library.getLibraries()
	return instance.Libraries
end

--- Set the value of a table index without invoking a metamethod
-- @param table tbl The table to modify
-- @param any key The index of the table
-- @param any value The value to set the index equal to
function builtins_library.rawset(tbl, key, value)
    checkluatype(tbl, TYPE_TABLE)
    rawset(tbl, key, value)
end

--- Gets the value of a table index without invoking a metamethod
-- @param table table The table to get the value from
-- @param any key The index of the table
-- @return any The value of the index
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
				builtins_library.print(string.rep("\t", indent) .. tostring(k) .. ":")
				printTableX(v, indent + 1, alreadyprinted)
			else
				builtins_library.print(string.rep("\t", indent) .. tostring(k) .. "\t=\t" .. tostring(v))
			end
		end
	else
		builtins_library.print(string.rep("\t", indent).."{}")
	end
end

local function argsToChat(...)
	local n = select('#', ...)
	local input = {...}
	local defaultColor = true
	local length = 0
	local size = 0
	for i = 1, n do
		local val = input[i]
		local add
		if dgetmeta(val) == col_meta then
			defaultColor = false
			add = Color(val[1], val[2], val[3])
		else
			add = tostring(val)
		end
		input[i] = add
	end
	-- Combine the strings with tabs
	local processed = {}
	if defaultColor then processed[1] = SERVER and Color(151, 211, 255) or Color(231, 219, 116) size = 4 end
	local i = 1
	while i <= n do
		if isstring(input[i]) then
			local j = i + 1
			while j <= n and isstring(input[j]) do
				j = j + 1
			end
			if i==(j-1) then
				local result = input[i]
				length = length + #result
				size = size + #result + 2
				processed[#processed + 1] = result
			else
				local result = table.concat(input, "\t", i, j-1)
				length = length + #result
				size = size + #result + 2
				processed[#processed + 1] = result
			end
			i = j
		else
			processed[#processed + 1] = input[i]
			i = i + 1
			size = size + 4 + 2
		end
	end
	return processed, length, size
end

if SERVER then
	local function sendPrintToPlayer(ply, data)
		net.Start("starfall_chatprint")
		net.WriteUInt(#data, 32)
		for i, v in ipairs(data) do
			net.WriteType(v)
		end
		net.Send(ply)
	end

	--- Prints a message to the player's chat.
	-- @shared
	-- @param ... printArgs Values to print. Colors before text will set the text color
	function builtins_library.print(...)
		local data, strlen, size = argsToChat(...)
		printBurst:use(instance.player, size)
		sendPrintToPlayer(instance.player, data)
	end

	--- Prints a message to a target player's chat as long as they're connected to a hud.
	-- @shared
	-- @param Player ply The target player. If in CLIENT, then ply is the client player and this param is omitted
	-- @param ... printArgs Values to print. Colors before text will set the text color
	function builtins_library.printHud(ply, ...)
		ply = getply(ply)
		if not ply:IsPlayer() then SF.Throw("Expected a target player!", 2) end
		if not SF.IsHUDActive(instance.entity, ply) then SF.Throw("Player isn't connected to a hud!", 2) end

		local data, strlen, size = argsToChat(builtins_library.Color(5,125,222), "[SF] ", builtins_library.Color(255,255,255), ...)
		if strlen > 52 then SF.Throw("The max printHud string size is 52 chars!", 2) end
		printBurst:use(instance.player, size)
		for k, v in ipairs(data) do
			if isstring(v) then
				data[k] = string.gsub(v, "[\r\n%z\t]", "")
			end
		end
		sendPrintToPlayer(ply, data)
	end

	--- Prints a table to player's chat
	-- @param table tbl Table to print
	function builtins_library.printTable(tbl)
		checkluatype(tbl, TYPE_TABLE)
		printTableX(tbl, 0, { tbl = true })
	end

	--- Execute a console command
	-- @shared
	-- @param string cmd Command to execute
	function builtins_library.concmd(cmd)
		checkluatype(cmd, TYPE_STRING)
		if #cmd > 512 then SF.Throw("Console command is too long!", 2) end
		checkpermission(instance, nil, "console.command")
		instance.player:ConCommand(cmd)
	end

	--- Sets the chip's userdata that the duplicator tool saves. max 1MiB; can be changed with convar sf_userdata_max
	-- @server
	-- @param string str String data
	function builtins_library.setUserdata(str)
		checkluatype(str, TYPE_STRING)
		local max = userdataLimit:GetInt()
		if #str>max then
			SF.Throw("The userdata limit is " .. string.Comma(max) .. " bytes", 2)
		end
		instance.entity.starfalluserdata = str
	end

	--- Gets the chip's userdata that the duplicator tool loads
	-- @server
	-- @return string String data
	function builtins_library.getUserdata()
		return instance.entity.starfalluserdata or ""
	end
else
	--- Sets the chip's display name
	-- @client
	-- @param string name Name to set the chip's name to
	function builtins_library.setName(name)
		checkluatype(name, TYPE_STRING)
		local e = instance.entity
		if (e and e:IsValid()) then
			e.name = string.sub(name, 1, 256)
		end
	end

	--- Sets clipboard text. Only works on the owner of the chip.
	-- @client
	-- @param string txt Text to set to the clipboard
	function builtins_library.setClipboardText(txt)
		if instance.player ~= LocalPlayer() then return end
		checkluatype(txt, TYPE_STRING)
		SetClipboardText(txt)
	end

	--- Prints a message to your chat, console, or the center of your screen.
	-- @client
	-- @param number mtype How the message should be displayed. See http://wiki.facepunch.com/gmod/Enums/HUD
	-- @param string text The message text.
	function builtins_library.printMessage(mtype, text)
		if instance.player ~= LocalPlayer() then return end
		checkluatype(text, TYPE_STRING)
		instance.player:PrintMessage(mtype, text)
	end

	function builtins_library.print(...)
		if instance.player == LocalPlayer() then
			chat.AddText(unpack((argsToChat(...))))
		end
	end

	function builtins_library.printHud(...)
		if not SF.IsHUDActive(instance.entity) then SF.Throw("Player isn't connected to a hud!", 2) end
		local data, strlen, size = argsToChat(builtins_library.Color(5,125,222), "[SF] ", builtins_library.Color(255,255,255), ...)
		if strlen > 52 then SF.Throw("The max printHud string size is 52 chars!", 2) end
		for k, v in ipairs(data) do
			if isstring(v) then
				data[k] = string.gsub(v, "[\r\n%z\t]", "")
			end
		end
		chat.AddText(unpack(data))
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
	-- @return Angle The local player's camera angles
	function builtins_library.eyeAngles()
		return awrap(LocalPlayer():EyeAngles())
	end

	--- Returns the local player's camera position
	-- @client
	-- @return Vector The local player's camera position
	function builtins_library.eyePos()
		return vwrap(LocalPlayer():EyePos())
	end

	--- Returns the local player's camera forward vector
	-- @client
	-- @return Vector The local player's camera forward vector
	function builtins_library.eyeVector()
		return vwrap(LocalPlayer():GetAimVector())
	end
end

--- Returns the table of scripts used by the chip
-- @param Entity? ent Optional target entity. Default: chip()
-- @return table Table of scripts used by the chip
function builtins_library.getScripts(ent)
	if ent~=nil then
		ent = getent(ent)
		local oinstance = ent.instance
		if not (ent.Starfall and oinstance and (oinstance.player == instance.player or oinstance.shareScripts)) then SF.Throw("Invalid starfall chip", 2) end
		return instance.Sanitize(oinstance.source)
	else
		return instance.Sanitize(instance.source)
	end
end

--- Sets the chip to allow other chips to view its sources
-- @param boolean enable If true, allow sharing scripts
function builtins_library.shareScripts(enable)
	instance.shareScripts = (enable == true) or nil
end

--- Runs an included script and caches the result.
-- Works pretty much like standard Lua require()
-- @param string file The file path to include. Make sure to --@include it
-- @return ... Return value(s) of the script
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
-- @param string dir The directory to include. Make sure to --@includedir it
-- @param table loadpriority Table of files that should be loaded before any others in the directory
-- @return table Table of return values of the scripts
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
-- @param string file The file to include. Make sure to --@include it
-- @return ... Return value(s) of the script
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
-- @param string dir The directory to include. Make sure to --@includedir it
-- @param table loadpriority Table of files that should be loaded before any others in the directory
-- @return table Table of return values of the scripts
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
-- @param string str String to execute
-- @return function Function of str
function builtins_library.loadstring(str, name)
	name = "SF:" .. (name or tostring(instance.env))
	local func = SF.CompileString(str, name, false)

	-- CompileString returns an error as a string, better check before setfenv
	if isfunction(func) then
		return setfenv(func, instance.env)
	end

	return func
end

-- Used for getfenv and setfenv.
local whitelistedEnvs = setmetatable({
	[instance.env] = true
}, {__mode = 'k'})
instance.whitelistedEnvs = whitelistedEnvs

--- Lua's setfenv
-- Sets the environment of either the stack level or the function specified.
-- Note that this function will throw an error if you try to use it on anything outside of your sandbox.
-- @param function|number funcOrStackLevel Function or stack level to set the environment of
-- @param table tbl New environment
-- @return function Function with environment set to tbl
function builtins_library.setfenv(location, environment)
	if location == nil then
		location = 2
	elseif isnumber(location) then
		location = location+1 -- This makes setfenv appear as though it's not detoured.
	elseif not isfunction(location) then
		SF.ThrowTypeError("function or number", SF.GetType(location), 2)
	end
	if whitelistedEnvs[getfenv(location)] then
		whitelistedEnvs[environment] = true
		return setfenv(location, environment)
	end
	SF.Throw("cannot change environment of given object", 2)
end

--- Lua's getfenv
-- Returns the environment of either the stack level or the function specified.
-- Note that this function will return nil if the return value would be anything other than builtins_library or an environment you have passed to setfenv.
-- @param function|number funcOrStackLevel Function or stack level to get the environment of
-- @return table? Environment table (or nil, if restricted)
function builtins_library.getfenv(location)
	if location == nil then
		location = 2
	elseif isnumber(location) then
		location = location+1 -- This makes getfenv appear as though it's not detoured.
	elseif not isfunction(location) then
		SF.ThrowTypeError("function or number", SF.GetType(location), 2)
	end
	local fenv = getfenv(location)
	if whitelistedEnvs[fenv] then
		return fenv
	end
end

--- Gets an SF type's methods table
-- @param string sfType Name of SF type
-- @return table Table of the type's methods which can be edited or iterated
function builtins_library.getMethods(sfType)
	checkluatype(sfType, TYPE_STRING)
	local typemeta = instance.Types[sfType]
	if typemeta then
		return typemeta.Methods
	end
end


local debug_library = instance.Libraries.debug

--- GLua's debug.traceback()
-- Returns a string containing traceback info
-- @param thread? A thread to get the stacktrace of. Otherwise uses current thread and uses this arg as the message.
-- @param string? message A message to be included in the stack trace. Default: ""
-- @return number? stacklevel How far up to start the stack level. Default: 1
function debug_library.traceback(thread, message, stacklevel)
	local ok, t = pcall(instance.Types.thread.Unwrap, thread)
	if ok then
		thread = t.thread
	else
		stacklevel = message
		message = thread
		thread = nil
	end
	if message~=nil then checkluatype(message, TYPE_STRING) end
	if stacklevel~=nil then checkluatype(stacklevel, TYPE_NUMBER) end

	if thread then
		return debug.traceback(thread, message, stacklevel)
	elseif message then
		return debug.traceback(message, stacklevel)
	else
		return debug.traceback("", stacklevel)
	end
end

--- GLua's debug.getinfo()
-- Returns a DebugInfo structure containing the passed function's info https://wiki.facepunch.com/gmod/Structures/DebugInfo
-- @param function|number funcOrStackLevel Function or stack level to get info about. Defaults to stack level 0.
-- @param string? fields A string that specifies the information to be retrieved. Defaults to all (flnSu).
-- @return table DebugInfo table
function debug_library.getinfo(funcOrStackLevel, fields)
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
-- @param function|number funcOrStackLevel Function or stack level to get info about. Defaults to stack level 0.
-- @param number index The index of the local to get
-- @return string The name of the local
function debug_library.getlocal(funcOrStackLevel, index)
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
-- @param function func Function to be executed and of which the errors should be caught of
-- @param ... arguments Arguments to call the function with.
-- @return boolean If the function had no errors occur within it.
-- @return ... If an error occurred, this will be a string containing the error message. Otherwise, this will be the return values of the function passed in.
function builtins_library.pcall(func, ...)
	local vret = { pcall(func, ...) }
	local ok, err = vret[1], vret[2]

	if ok then return unpack(vret) end

	if dgetmeta(err)==SF.Errormeta then
		if err.userdata~=nil then
			err = err.userdata
		elseif err.uncatchable or uncatchable[err.msg] then
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
-- @param function func The function to call initially.
-- @param function callback The function to be called if execution of the first fails; the error message and stack trace are passed.
-- @param ... passArgs Varargs to pass to the initial function.
-- @return boolean Status of the execution; true for success, false for failure.
-- @return ... The returns of the first function if execution succeeded, otherwise the return values of the error callback.
function builtins_library.xpcall(func, callback, ...)
	local vret = { xpcall(func, xpcall_Callback, ...) }
	local ok, errData = vret[1], vret[2]

	if ok then return unpack(vret) end

	local err, traceback = errData[1], errData[2]
	if dgetmeta(err)==SF.Errormeta then
		if err.userdata~=nil then
			err = err.userdata
		elseif err.uncatchable or uncatchable[err.msg] then
			error(err)
		end
	elseif uncatchable[err] then
		SF.Throw(err, 2, true)
	end

	return false, callback(instance.Sanitize({err})[1], traceback)
end

--- Try to execute a function and catch possible exceptions
-- Similar to xpcall, but a bit more in-depth
-- @param function func Function to execute
-- @param function? catch Optional function to execute in case func fails
function builtins_library.try(func, catch)
	local ok, err = pcall(func)
	if ok then return end

	if dgetmeta(err)==SF.Errormeta then
		if err.userdata~=nil then
			err = err.userdata
		elseif err.uncatchable or uncatchable[err.msg] then
			error(err)
		end
	elseif uncatchable[err] then
		SF.Throw(err, 2, true)
	end
	if catch then catch(instance.Sanitize({err})[1]) end
end


--- Throws an exception
-- @param string msg Message string
-- @param number? level Which level in the stacktrace to blame. Defaults to 1
-- @param boolean uncatchable Makes this exception uncatchable
function builtins_library.throw(msg, level, uncatchable)
	SF.Throw(msg, 1 + (level or 1), uncatchable)
end

--- Throws an error. Similar to 'throw' but throws whatever you want instead of an SF Error.
-- @name builtins_library.error
-- @class function
-- @param string msg Message string
-- @param number? level Which level in the stacktrace to blame. Defaults to 1. 0 for no stacktrace.
function builtins_library.error(msg, level)
	SF.Throw(msg, 1 + (level or 1), false, msg)
end

--- If the result of the first argument is false or nil, an error is thrown with the second argument as the message.
-- @name builtins_library.assert
-- @class function
-- @param any expression Anything that will be evaluated to be true or false
-- @param string? msg Error message. Default "assertion failed!"
-- @param ... args Any arguments to return if the assertion is successful
builtins_library.assert = assert

--- Returns if the table has an isValid function and isValid returns true.
-- @param any object Table to check
-- @return boolean If it is valid
function builtins_library.isValid(object)

	if (not object) then return false end
	if (not object.isValid) then return false end

	return object:isValid()

end

--- Translates the specified position and angle into the specified coordinate system
-- @param Vector pos The position that should be translated from the current to the new system
-- @param Angle ang The angles that should be translated from the current to the new system
-- @param Vector newSystemOrigin The origin of the system to translate to
-- @param Angle newSystemAngles The angles of the system to translate to
-- @return Vector localPos
-- @return Angle localAngles
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
-- @param Vector localPos The position vector that should be translated to world coordinates
-- @param Angle localAng The angle that should be converted to a world angle
-- @param Vector originPos The origin point of the source coordinate system, in world coordinates
-- @param Angle originAngle The angles of the source coordinate system, as a world angle
-- @return Vector worldPos
-- @return Angle worldAngles
function builtins_library.localToWorld(localPos, localAng, originPos, originAngle)

	local worldPos, worldAngles = LocalToWorld(
		vunwrap(localPos),
		aunwrap(localAng),
		vunwrap(originPos),
		aunwrap(originAngle)
	)

	return vwrap(worldPos), awrap(worldAngles)
end

--- Sets the current instance to allow HUD drawing. Only works if player is in your vehicle or
-- if it's ran on yourself or if the player is connected to your hud and you want to disconnect them
-- @param Player ply The player to enable the hud on. If CLIENT, will be forced to player()
-- @param boolean active Whether hud hooks should be active. true to force on, false to force off.
function builtins_library.enableHud(ply, active)
	ply = SERVER and getply(ply) or LocalPlayer()
	checkluatype(active, TYPE_BOOL)

	if ply==instance.player or (instance.player==SF.Superuser) or (not active and SF.IsHUDActive(instance.entity, ply)) then
		SF.EnableHud(ply, instance.entity, nil, active)
	else
		local vehicle = ply:GetVehicle()
		if vehicle:IsValid() and SF.Permissions.getOwner(vehicle)==instance.player then
			SF.EnableHud(ply, instance.entity, vehicle, active)
		else
			SF.Throw("Player must be sitting in owner's vehicle or be owner of the chip!", 2)
		end
	end
end

--- Creates a 'middleclass' class object that can be used similarly to Java/C++ classes. See https://github.com/kikito/middleclass for examples.
-- @name builtins_library.class
-- @class function
-- @param string name The string name of the class
-- @param table? super The (optional) parent class to inherit from
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

--- Mark a file to be included in the upload.
-- Different from include in that the file does not have to have valid syntax.
-- Cannot be used with require() or dofile(), can only be used with getScripts().
-- @name includedata
-- @class directive
-- @param path Path to the file

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

--- Set the current file to run on both the server and client. This is enabled by default. --@shared
-- @name shared
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

