-------------------------------------------------------------------------------
-- The main Starfall library
-------------------------------------------------------------------------------
SF = SF or {}

local dgetmeta = debug.getmetatable

-------------------------------------------------------------------------------
-- Some basic initialization
-------------------------------------------------------------------------------

if SERVER then
	SF.cpuQuota = CreateConVar("sf_timebuffer", 0.005, FCVAR_ARCHIVE, "The max average the CPU time can reach.")
	SF.cpuBufferN = CreateConVar("sf_timebuffersize", 100, FCVAR_ARCHIVE, "The window width of the CPU time quota moving average.")
else
	SF.cpuQuota = CreateClientConVar("sf_timebuffer_cl", 0.006, true, false, "The max average the CPU time can reach.")
	SF.cpuOwnerQuota = CreateClientConVar("sf_timebuffer_cl_owner", 0.015, true, false, "The max average the CPU time can reach for your own chips.")
	SF.cpuBufferN = CreateClientConVar("sf_timebuffersize_cl", 100, true, false, "The window width of the CPU time quota moving average.")
end

if SERVER then
	SF.Version = "StarfallEx"
	local files, directories = file.Find( "addons/*", "GAME" )
	local sf_dir = nil
	for k,v in pairs(directories) do
		if file.Exists("addons/"..v.."/lua/starfall/sflib.lua", "GAME") then
			sf_dir = "addons/"..v.."/"
			break
		end
	end
	if sf_dir then
		local head = file.Read(sf_dir..".git/HEAD","GAME") -- Where head points to
		if head then
			head = head:sub(6,-2) -- skipping ref: and new line
			local lastCommit = file.Read( sf_dir..".git/"..head, "GAME")

			if lastCommit then
				SF.Version = SF.Version .. "_" .. lastCommit:sub(1,7) -- We need only first 7 to be safely unique
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Declare Basic Starfall Types
-------------------------------------------------------------------------------

function SF.EntityTable(key)
	return setmetatable({},
	{ __newindex = function(t, e, v)
		rawset(t, e, v)
		e:CallOnRemove("SF_" .. key, function() t[e] = nil end)
	end })
end


--- Returns a class that can keep track of burst
SF.BurstObject = {
	use = function(self, amount)
		self:check()
		if self.val>= amount then
			self.val = self.val - amount
			return true
		end
		return false
	end,
	check = function(self)
		self.val = math.min(self.val + (CurTime() - self.lasttick) * self.rate, self.max)
		self.lasttick = CurTime()
		return self.val
	end,
	__call = function(p, rate, max)
		local t = {
			rate = rate,
			max = max,
			val = max,
			lasttick = 0
		}
		return setmetatable(t, p)
	end
}
SF.BurstObject.__index = SF.BurstObject
setmetatable(SF.BurstObject, SF.BurstObject)


--- Returns a class that can whitelist/blacklist strings
SF.StringRestrictor = {
	check = function(self, value)
		for k,v in pairs(self.blacklist) do
			if string.match(value, v) then
				return false
			end
		end
		for k,v in pairs(self.whitelist) do
			if string.match(value, v) then
				return  true
			end
		end
		return self.default
	end,
	addWhitelistEntry = function(self, value)
		table.insert(self.whitelist, value)
	end,
	addBlacklistEntry = function(self, value)
		table.insert(self.blacklist, value)
	end,
	__call = function(p, allowbydefault)
		local t = {
			whitelist = {}, -- patterns
			blacklist = {}, -- patterns
			default = allowbydefault or false,
		}
		return setmetatable(t, p)
	end
}
SF.StringRestrictor.__index = SF.StringRestrictor
setmetatable(SF.StringRestrictor, SF.StringRestrictor)


-- Error type containing error info
SF.Errormeta = {
	__tostring = function(t) return t.message end,
	__metatable = "SFError"
}


--- Builds an error type to that contains line numbers, file name, and traceback
-- @param msg Message
-- @param level Which level in the stacktrace to blame
-- @param uncatchable Makes this exception uncatchable
-- @param prependinfo The error message needs file and line number info
function SF.MakeError (msg, level, uncatchable, prependinfo)
	level = 1 + (level or 1)
	local info = debug.getinfo(level, "Sl")
	if not info then
		info = { short_src = "", currentline = 0 }
		prependinfo = false
	end
	if type(msg) ~= "string" then msg = "(error object is not a string)" end
	return setmetatable({
		uncatchable = false,
		file = info.short_src,
		line = info.currentline,
		message = prependinfo and (info.short_src..":"..info.currentline..": "..msg) or msg,
		uncatchable = uncatchable,
		traceback = debug.traceback("", level)
	}, SF.Errormeta)
end


-------------------------------------------------------------------------------
-- Utility functions
-------------------------------------------------------------------------------


--- Throws an error like the throw function in builtins
-- @param msg Message
-- @param level Which level in the stacktrace to blame
-- @param uncatchable Makes this exception uncatchable
function SF.Throw (msg, level, uncatchable)
	local level = 1 + (level or 1)
	error(SF.MakeError(msg, level, uncatchable, true), level)
end

SF.Libraries = {}
SF.Types = {}
SF.Hooks = {}

--- Creates and registers a library.
-- @param name The library name
function SF.RegisterLibrary(name)
	local methods = {}
	SF.Libraries[name] = methods
	return methods
end

--- Creates and registers a type.
-- @param name The library name
-- @return methods The type's methods
-- @return metamethods The type's metamethods
function SF.RegisterType(name)
	local methods, metamethods = {}, {}
	SF.Types[name] = metamethods
	SF.Types[metamethods] = true
	metamethods.__index = methods
	metamethods.__methods = methods
	metamethods.__metatable = name
	return methods, metamethods
end

--- Gets a starfall type. ACF uses this so can't remove it. (otherwise it's useless)
function SF.GetTypeDef(name)
	return SF.Types[name]
end

--- Applies inheritance to a derived type.
-- @param methods The type's methods table
-- @param metamethods The type's metamethods table
-- @param supermeta The meta of the inherited type
function SF.ApplyTypeDependencies(methods, metamethods, supermeta)
	local supermethods = supermeta.__methods

	setmetatable(methods, {__index = supermethods})

	metamethods.__supertypes = { [supermeta] = true }
	if supermeta.__supertypes then
		for k, _ in pairs(supermeta.__supertypes) do
			metamethods.__supertypes[k] = true
		end
	end
end

function SF.DeepDeepCopy(src, dst, done)
	-- Copy the values
	for k, v in pairs(src) do
		if type(k)=="table" then error("Tried to shallow copy a table!!") end
		if type(v)=="table" then
			if done[v] then
				dst[k] = done[v]
			else
				local t = {}
				done[v] = t
				SF.DeepDeepCopy(v, t, done)
				dst[k] = t
			end
		else
			dst[k] = v
		end
	end

	-- Copy the metatable
	local meta = dgetmeta(src)
	if meta then
		local t = {}
		SF.DeepDeepCopy(meta, t, done)
		setmetatable(dst, t)
	end
end

--- Builds an environment table
-- @return The environment
function SF.BuildEnvironment()
	local env = {}
	SF.DeepDeepCopy(SF.DefaultEnvironment, env, {})
	for name, methods in pairs(SF.Libraries) do
		env[name] = {}
		SF.DeepDeepCopy(methods, env[name], {})
	end
	return env
end

--- Registers a library hook. These hooks are only available to SF libraries,
-- and are called by Libraries.CallHook.
-- @param hookname The name of the hook.
-- @param func The function to call
function SF.AddHook(hookname, func)
	local hook = SF.Hooks[hookname]
	if not hook then
		hook = {}
		SF.Hooks[hookname] = hook
	end

	hook[#hook + 1] = func
end

--- Calls a library hook.
-- @param hookname The name of the hook.
-- @param ... The arguments to the functions that are called.
function SF.CallHook(hookname, ...)
	local hook = SF.Hooks[hookname]
	if not hook then return end

	for i = 1, #hook do
		hook[i](...)
	end
end

--- Checks the starfall type of val. Errors if the types don't match
-- @param val The value to be checked.
-- @param typ A metatable.
-- @param level Level at which to error at. 3 is added to this value. Default is 0.
function SF.CheckType(val, typ, level)
	local meta = dgetmeta(val)
	if meta == typ or (meta and meta.__supertypes and meta.__supertypes[typ] and SF.Types[meta]) then
		return val
	else
		-- Failed, throw error
		assert(type(typ) == "table" and typ.__metatable and type(typ.__metatable) == "string")

		level = (level or 0) + 3
		local funcname = debug.getinfo(level-1, "n").name or "<unnamed>"
		local mt = getmetatable(val)
		SF.Throw("Type mismatch (Expected " .. typ.__metatable .. ", got " .. (type(mt) == "string" and mt or type(val)) .. ") in function " .. funcname, level)
	end
end

--- Gets the type of val.
-- @param val The value to be checked.
function SF.GetType(val)
	local mt = dgetmeta(val)
	return (mt and mt.__metatable and type(mt.__metatable) == "string") and mt.__metatable or type(val)
end

--- Checks the lua type of val. Errors if the types don't match
-- @param val The value to be checked.
-- @param typ A string type or metatable.
-- @param level Level at which to error at. 3 is added to this value. Default is 0.
function SF.CheckLuaType(val, typ, level)
	local valtype = TypeID(val)
	if valtype == typ then
		return val
	else
		-- Failed, throw error
		assert(type(typ) == "number")
		local typeLookup = {
			[TYPE_BOOL] = "boolean",
			[TYPE_FUNCTION] = "function",
			[TYPE_NIL] = "nil",
			[TYPE_NUMBER] = "number",
			[TYPE_STRING] = "string",
			[TYPE_TABLE] = "table",
			[TYPE_THREAD] = "thread",
			[TYPE_USERDATA] = "userdata"
		}

		level = (level or 0) + 3
		local funcname = debug.getinfo(level-1, "n").name or "<unnamed>"
		local mt = getmetatable(val)
		SF.Throw("Type mismatch (Expected " .. typeLookup[typ] .. ", got " .. (type(mt) == "string" and mt or typeLookup[valtype]) .. ") in function " .. funcname, level)
	end
end

--- Gets the type of val.
-- @param val The value to be checked.
function SF.GetType(val)
	local mt = dgetmeta(val)
	return (mt and mt.__metatable and type(mt.__metatable) == "string") and mt.__metatable or type(val)
end

-- ------------------------------------------------------------------------- --

local object_wrappers = {}
local sensitive2sf_tables = {}
local sf2sensitive_tables = {}

--- Creates wrap/unwrap functions for sensitive values, by using a lookup table
-- (which is set to have weak keys and values)
-- @param metatable The metatable to assign the wrapped value.
-- @param weakwrapper Make the wrapper weak inside the internal lookup table. Default: True
-- @param weaksensitive Make the sensitive data weak inside the internal lookup table. Default: True
-- @param target_metatable (optional) The metatable of the object that will get
-- 		wrapped by these wrapper functions.  This is required if you want to
-- 		have the object be auto-recognized by the generic SF.WrapObject
--		function.
-- @return The function to wrap sensitive values to a SF-safe table
-- @return The function to unwrap the SF-safe table to the sensitive table
function SF.CreateWrapper(metatable, weakwrapper, weaksensitive, target_metatable, shared_meta)
	local sensitive2sf, sf2sensitive
	if shared_meta then
		sensitive2sf = sensitive2sf_tables[shared_meta]
		sf2sensitive = sf2sensitive_tables[shared_meta]
	else
		local s2sfmode = ""
		local sf2smode = ""
		if weakwrapper == nil or weakwrapper then
			sf2smode = "k"
			s2sfmode = "v"
		end
		if weaksensitive then
			sf2smode = sf2smode.."v"
			s2sfmode = s2sfmode.."k"
		end
		sensitive2sf = setmetatable({}, { __mode = s2sfmode })
		sf2sensitive = setmetatable({}, { __mode = sf2smode })
		sensitive2sf_tables[metatable] = sensitive2sf
		sf2sensitive_tables[metatable] = sf2sensitive
	end

	local function wrap(value)
		if value == nil then return nil end
		if sensitive2sf[value] then return sensitive2sf[value] end
		local tbl = setmetatable({}, metatable)
		sensitive2sf[value] = tbl
		sf2sensitive[tbl] = value
		return tbl
	end

	local function unwrap(value)
		return sf2sensitive[value]
	end

	if target_metatable ~= nil then
		object_wrappers[target_metatable] = wrap
		metatable.__wrap = wrap
	end

	metatable.__unwrap = unwrap

	return wrap, unwrap
end

--- Helper function for adding custom wrappers
-- @param object_meta metatable of object
-- @param sf_object_meta starfall metatable of object
-- @param wrapper function that wraps object
function SF.AddObjectWrapper(object_meta, sf_object_meta, wrapper)
	sf_object_meta.__wrap = wrapper
	object_wrappers[object_meta] = wrapper
end

--- Helper function for adding custom unwrappers
-- @param object_meta metatable of object
-- @param unwrapper function that unwraps object
function SF.AddObjectUnwrapper(object_meta, unwrapper)
	object_meta.__unwrap = unwrapper
end

-- A list of safe data types
local safe_types = {
	["number"] = true,
	["string"] = true,
	["boolean"] = true,
	["nil"] = true,
}

--- Wraps the given object so that it is safe to pass into starfall
-- It will wrap it as long as we have the metatable of the object that is
-- getting wrapped.
-- @param object the object needing to get wrapped as it's passed into starfall
-- @return returns nil if the object doesn't have a known wrapper,
-- or returns the wrapped object if it does have a wrapper.
function SF.WrapObject(object)
	local metatable = dgetmeta(object)
	if metatable then
		local wrap = object_wrappers[metatable]
		if wrap then
			return wrap(object)
		end
	end
	-- Do not elseif here because strings do have a metatable.
	if safe_types[type(object)] then
		return object
	end
end

--- Takes a wrapped starfall object and returns the unwrapped version
-- @param object the wrapped starfall object, should work on any starfall
-- wrapped object.
-- @return the unwrapped starfall object
function SF.UnwrapObject(object)
	local metatable = dgetmeta(object)

	if metatable and metatable.__unwrap then
		return metatable.__unwrap(object)
	end
end

--- Returns a path with all .. accounted for
function SF.NormalizePath(path)
	local tbl = string.Explode("[/\\]+", path, true)
	if #tbl == 1 then return path end
	local i = 1
	while i <= #tbl do
		if tbl[i] == "." or tbl[i]=="" then
			table.remove(tbl, i)
		elseif tbl[i] == ".." then
			table.remove(tbl, i)
			if i>1 then
				i = i - 1
				table.remove(tbl, i)
			end
		else
			i = i + 1
		end
	end
	return table.concat(tbl, "/")
end

--- Sanitizes and returns its argument list.
-- Basic types are returned unchanged. Non-object tables will be
-- recursed into and their keys and values will be sanitized. Object
-- types will be wrapped if a wrapper is available. When a wrapper is
-- not available objects will be replaced with nil, so as to prevent
-- any possiblitiy of leakage. Functions will always be replaced with
-- nil as there is no way to verify that they are safe.
function SF.Sanitize(...)
	local return_list = {}
	local args = { ... }

	for key, value in pairs(args) do
		local typmeta = getmetatable(value)
		local typ = type(typmeta) == "string" and typmeta or type(value)
		if safe_types[typ] then
			return_list[key] = value
		elseif SF.WrapObject(value) then
			return_list[key] = SF.WrapObject(value)
		elseif typ == "table" then
			local tbl = {}
			for k, v in pairs(value) do
				tbl[SF.Sanitize(k)] = SF.Sanitize(v)
			end
			return_list[key] = tbl
		else
			return_list[key] = nil
		end
	end

	return unpack(return_list)
end

--- Takes output from starfall and does it's best to make the output
-- fully usable outside of starfall environment
function SF.Unsanitize(...)
	local return_list = {}

	local args = { ... }

	for key, value in pairs(args) do
		local typ = type(value)
		if typ == "table" and SF.UnwrapObject(value) then
			return_list[key] = SF.UnwrapObject(value)
		elseif typ == "table" then
			return_list[key] = {}

			for k, v in pairs(value) do
				return_list[key][SF.Unsanitize(k)] = SF.Unsanitize(v)
			end
		else
			return_list[key] = value
		end
	end

	return unpack(return_list)
end

-- ------------------------------------------------------------------------- --


-- This function clamps the position before moving the entity
local minx, miny, minz = -16384, -16384, -16384
local maxx, maxy, maxz = 16384, 16384, 16384
local clamp = math.Clamp
function SF.clampPos(pos)
	pos.x = clamp(pos.x, minx, maxx)
	pos.y = clamp(pos.y, miny, maxy)
	pos.z = clamp(pos.z, minz, maxz)
	return pos
end

-- ------------------------------------------------------------------------- --

local serialize_replace_regex = "[\"\n]"
local serialize_replace_tbl = { ["\n"] = string.char(5), ['"'] = string.char(4) }

--- Serializes an instance's code in a format compatible with the duplicator library
-- @param sources The table of filename = source entries. Ususally instance.source
-- @param mainfile The main filename. Usually instance.mainfile
function SF.SerializeCode(sources, mainfile)
	local rt = { source = {} }
	for filename, source in pairs(sources) do
		rt.source[filename] = string.gsub(source, serialize_replace_regex, serialize_replace_tbl)
	end
	rt.mainfile = mainfile
	return rt
end

local deserialize_replace_regex = "[" .. string.char(5) .. string.char(4) .. "]"
local deserialize_replace_tbl = { [string.char(5)[1]] = "\n", [string.char(4)[1]] = '"' }
--- Deserializes an instance's code.
-- @return The table of filename = source entries
-- @return The main filename
function SF.DeserializeCode(tbl)
	local sources = {}
	for filename, source in pairs(tbl.source) do
		sources[filename] = string.gsub(source, deserialize_replace_regex, deserialize_replace_tbl)
	end
	return sources, tbl.mainfile
end

local soundsMap = {
	["DRIP1"] = 0, [0] = "ambient/water/drip1.wav",
	["DRIP2"] = 1,	[1] = "ambient/water/drip2.wav",
	["DRIP3"] = 2,	[2] = "ambient/water/drip3.wav",
	["DRIP4"] = 3,	[3] = "ambient/water/drip4.wav",
	["DRIP5"] = 4,	[4] = "ambient/water/drip5.wav",
	["ERROR1"] = 5,	[5] = "buttons/button10.wav",
	["CONFIRM1"] = 6,	[6] = "buttons/button3.wav",
	["CONFIRM2"] = 7,	[7] = "buttons/button14.wav",
	["CONFIRM3"] = 8,	[8] = "buttons/button15.wav",
	["CONFIRM4"] = 9,	[9] = "buttons/button17.wav",
}
local notificationsMap = {
	["GENERIC"] = 0,
	["ERROR"] = 1,
	["UNDO"] = 2,
	["HINT"] = 3,
	["CLEANUP"] = 4,
}
-- ------------------------------------------------------------------------- --

local function argsToChat(...)
	local n = select('#', ...)
	local input = { ... }
	local output = {}
	local color = false
	for i = 1, n do
		local add
		if dgetmeta(input[i]) == SF.Types["Color"] then
			color = true
			add = SF.Color.Unwrap(input[i])
		else
			add = tostring(input[i])
		end
		output[i] = add
	end
	-- Combine the strings with tabs
	local processed = {}
	if not color then processed[1] = Color(151, 211, 255) end
	local i = 1
	while i <= n do
		if type(output[i])=="string" then
			local j = i + 1
			while j <= n and type(output[j])=="string" do
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
	util.AddNetworkString("starfall_addnotify")
	util.AddNetworkString("starfall_console_print")
	util.AddNetworkString("starfall_chatprint")

	function SF.AddNotify (ply, msg, notifyType, duration, sound)
		if not IsValid(ply) then return end

		net.Start("starfall_addnotify")
		net.WriteString(msg)
		net.WriteUInt(notificationsMap[notifyType], 8)
		net.WriteFloat(duration)
		net.WriteUInt(soundsMap[sound], 8)
		if ply then
			net.Send(ply)
		else
			net.Broadcast()
		end
	end

	function SF.Print (ply, msg)
		net.Start("starfall_console_print")
			net.WriteString(msg)
		net.Send(ply)
	end

	function SF.ChatPrint(ply, ...)
		local tbl = argsToChat(...)

		net.Start("starfall_chatprint")
		net.WriteUInt(#tbl, 32)
		for i, v in ipairs(tbl) do
			net.WriteType(v)
		end
		net.Send(ply)
	end

else

	function SF.AddNotify (ply, msg, type, duration, sound)
		if ply == LocalPlayer() then
			print(msg)
			GAMEMODE:AddNotify(msg, notificationsMap[type], duration)
			if soundsMap[sound] then
				surface.PlaySound(soundsMap[soundsMap[sound]])
			end
		end
	end

	net.Receive("starfall_addnotify", function ()
		local msg, type, duration, sound = net.ReadString(), net.ReadUInt(8), net.ReadFloat(), net.ReadUInt(8)
		print(msg)
		GAMEMODE:AddNotify(msg, type, duration)
		if soundsMap[sound] then
			surface.PlaySound(soundsMap[sound])
		end
	end)

	function SF.HTTPNotify(ply, url)
		MsgC(Color(255, 255, 0), "SF HTTP: " .. ply:Nick() .. " [" .. ply:SteamID() .. "]: requested url ", Color(255,255,255), url, "\n")
	end

	net.Receive("starfall_console_print", function ()
		print(net.ReadString())
	end)

	net.Receive("starfall_chatprint", function ()
		local recv = {}
		local n = net.ReadUInt(32)
		for i = 1, n do
			recv[i] = net.ReadType()
		end
		chat.AddText(unpack(recv))
	end)

	function SF.ChatPrint(...)
		chat.AddText(unpack(argsToChat(...)))
	end
end

-------------------------------------------------------------------------------
-- Includes
-------------------------------------------------------------------------------

if SERVER then
	AddCSLuaFile("sflib.lua")
	AddCSLuaFile("instance.lua")
	AddCSLuaFile("preprocessor.lua")
	AddCSLuaFile("permissions/core.lua")
	AddCSLuaFile("netstream.lua")
	AddCSLuaFile("transfer.lua")

	AddCSLuaFile("editor/editor.lua")
end

include("instance.lua")
include("preprocessor.lua")
include("permissions/core.lua")
include("editor/editor.lua")
include("netstream.lua")
include("transfer.lua")

do
	if SERVER then
		local l

		l = file.Find("starfall/libs_sh/*.lua", "LUA")
		for _, filename in pairs(l) do
			include("starfall/libs_sh/"..filename)
			AddCSLuaFile("starfall/libs_sh/"..filename)
		end

		l = file.Find("starfall/libs_sv/*.lua", "LUA")
		for _, filename in pairs(l) do
			include("starfall/libs_sv/"..filename)
		end

		l = file.Find("starfall/libs_cl/*.lua", "LUA")
		for _, filename in pairs(l) do
			AddCSLuaFile("starfall/libs_cl/"..filename)
		end

	else
		local l

		l = file.Find("starfall/libs_sh/*.lua", "LUA")
		for _, filename in pairs(l) do
			include("starfall/libs_sh/"..filename)
		end

		l = file.Find("starfall/libs_cl/*.lua", "LUA")
		for _, filename in pairs(l) do
			include("starfall/libs_cl/"..filename)
		end
	end
end

do
	local function cleanHooks(path)
		for k, v in pairs(SF.Hooks) do
			local i = 1
			while i <= #v do
				local hookfile = debug.getinfo(v[i], "S").short_src
				if string.find(hookfile, path, 1, true) then
					table.remove(v, i)
				else
					i = i + 1
				end
			end
		end
	end

	if SERVER then

		-- Command to reload the libraries
		util.AddNetworkString("sf_reloadlibrary")
		concommand.Add("sf_reloadlibrary", function(ply, com, arg)
			if ply:IsValid() and not ply:IsSuperAdmin() then return end
			local filename = arg[1]
			if not filename then return end
			filename = string.lower(filename)

			local function sendToClient(path)
				net.Start("sf_reloadlibrary")
				local data = util.Compress(file.Read(path, "LUA"))
				net.WriteString(path)
				net.WriteStream(data)
				net.Broadcast()
			end

			local sv_filename = "starfall/libs_sv/"..filename..".lua"
			local sh_filename = "starfall/libs_sh/"..filename..".lua"
			local cl_filename = "starfall/libs_cl/"..filename..".lua"

			cleanHooks(filename)

			local postload
			if file.Exists(sh_filename, "LUA") then
				print("Reloaded library: " .. filename)
				include(sh_filename)
				sendToClient(sh_filename)
				postload = true
			end
			if file.Exists(sv_filename, "LUA") then
				print("Reloaded library: " .. filename)
				include(sv_filename)
				postload = true
			end
			if file.Exists(cl_filename, "LUA") then
				sendToClient(cl_filename)
			end
			if postload then
				SF.CallHook("postload")
			end
		end)

	else
		local root_path = SF.NormalizePath(string.GetPathFromFilename(debug.getinfo(1, "S").short_src).."../")
		net.Receive("sf_reloadlibrary", function(len)
			local path = net.ReadString()
			net.ReadStream(nil, function(data)
				local file = util.Decompress(data)
				if file then
					print("Reloaded library: " .. string.StripExtension(string.GetFileFromFilename(path)))
					cleanHooks(path)
					local func = CompileString(file, root_path .. path)
					func()
					SF.CallHook("postload")
				end
			end)
		end)

	end
end

SF.CallHook("postload")
