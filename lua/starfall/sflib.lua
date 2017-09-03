-------------------------------------------------------------------------------
-- The main Starfall library
-------------------------------------------------------------------------------

if SF ~= nil then return end
SF = {}

-- Send files to client
if SERVER then
	AddCSLuaFile("sflib.lua")
	AddCSLuaFile("instance.lua")
	AddCSLuaFile("libraries.lua")
	AddCSLuaFile("preprocessor.lua")
	AddCSLuaFile("permissions/core.lua")
	AddCSLuaFile("netstream.lua")
	
	AddCSLuaFile("editor/editor.lua")
end

-- Load files
include("instance.lua")
include("libraries.lua")
include("preprocessor.lua")
include("permissions/core.lua")
include("editor/editor.lua")
include("netstream.lua")

if SERVER then
	SF.cpuQuota = CreateConVar("sf_timebuffer", 0.005, FCVAR_ARCHIVE, "The max average the CPU time can reach.")
	SF.cpuBufferN = CreateConVar("sf_timebuffersize", 100, FCVAR_ARCHIVE, "The window width of the CPU time quota moving average.")
else
	SF.cpuQuota = CreateClientConVar("sf_timebuffer_cl", 0.006, true, false, "The max average the CPU time can reach.")
	SF.cpuOwnerQuota = CreateClientConVar("sf_timebuffer_cl_owner", 0.015, true, false, "The max average the CPU time can reach for your own chips.")
	SF.cpuBufferN = CreateClientConVar("sf_timebuffersize_cl", 100, true, false, "The window width of the CPU time quota moving average.")
end


local dgetmeta = debug.getmetatable

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

--- Throws an error like the throw function in builtins
-- @param msg Message
-- @param level Which level in the stacktrace to blame
-- @param uncatchable Makes this exception uncatchable
function SF.Throw (msg, level, uncatchable)
	local level = 1 + (level or 1)
	error(SF.MakeError(msg, level, uncatchable, true), level)
end

SF.Types = {}
local typemetatables = {}
--- Creates a type that is safe for SF scripts to use. Instances of the type
-- cannot access the type's metatable or metamethods.
-- @param name Name of table
-- @param supermeta The metatable to inheret from
-- @return The table to store normal methods
-- @return The table to store metamethods
function SF.Typedef(name, supermeta)
	--Keep the original type so we don't screw up inheritance
	if SF.Types[name] then
		return SF.Types[name].__methods, SF.Types[name]
	end

	local methods, metamethods = {}, {}
	metamethods.__metatable = name
	metamethods.__index = methods
	metamethods.__methods = methods
		
	if supermeta then
		setmetatable(methods, { __index = supermeta.__index })
		metamethods.__supertypes = { [supermeta] = true }
		if supermeta.__supertypes then
			for k, _ in pairs(supermeta.__supertypes) do
				metamethods.__supertypes[k] = true
			end
		end
	end

	SF.Types[name] = metamethods
	typemetatables[metamethods] = true
	return methods, metamethods
end

function SF.GetTypeDef(name)
	return SF.Types[name]
end

--- Checks the starfall type of val. Errors if the types don't match
-- @param val The value to be checked.
-- @param typ A string type or metatable.
-- @param level Level at which to error at. 3 is added to this value. Default is 0.
-- @param default A value to return if val is nil.
function SF.CheckType(val, typ, level, default)
	local meta = dgetmeta(val)
	if meta == typ or (meta and typemetatables[meta] and meta.__supertypes and meta.__supertypes[typ]) then 
		return val
	elseif val == nil and default then
		return default
	else
		-- Failed, throw error
		assert(type(typ) == "table" and typ.__metatable and type(typ.__metatable) == "string")

		level = (level or 0) + 3
		local funcname = debug.getinfo(level-1, "n").name or "<unnamed>"
		local mt = getmetatable(val)
		SF.Throw("Type mismatch (Expected " .. typ.__metatable .. ", got " .. (type(mt) == "string" and mt or type(val)) .. ") in function " .. funcname, level)
	end
end

--- Checks the lua type of val. Errors if the types don't match
-- @param val The value to be checked.
-- @param typ A string type or metatable.
-- @param level Level at which to error at. 3 is added to this value. Default is 0.
-- @param default A value to return if val is nil.
function SF.CheckLuaType(val, typ, level, default)
	local valtype = TypeID(val)
	if valtype==typ then 
		return val
	elseif val == nil and default then
		return default
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

	local sensitive2sf, sf2sensitive
	if shared_meta then
		sensitive2sf = sensitive2sf_tables[shared_meta]
		sf2sensitive = sf2sensitive_tables[shared_meta]
	else
		-- Check if the wrapper already exists for this metatable and recycle it or shared wrappers won't work.
		if sensitive2sf_tables[metatable] then
			sensitive2sf = sensitive2sf_tables[metatable]
			sf2sensitive = sf2sensitive_tables[metatable]
		else
			sensitive2sf = setmetatable({}, { __mode = s2sfmode })
			sf2sensitive = setmetatable({}, { __mode = sf2smode })
			sensitive2sf_tables[metatable] = sensitive2sf
			sf2sensitive_tables[metatable] = sf2sensitive
		end
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

--- Manages data tied to entities so that the data is cleaned when the entity is removed
function SF.EntityTable(key)
	return setmetatable({}, 
	{ __newindex = function(t, e, v)
		rawset(t, e, v)
		e:CallOnRemove("SF_" .. key, function() t[e] = nil end)
	end })
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
				table.remove(tbl, i-1)
			end
		else
			i = i + 1
		end
	end
	return table.concat(tbl, "/")
end


--- Returns a class that can keep track of burst
function SF.BurstObject(rate, max)
	local burstclass = {
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
		end
	}
	local t = {
		rate = rate, 
		max = max,
		val = max,
		lasttick = 0
	}
	return setmetatable(t, { __index = burstclass })
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

local function isnan(n)
	return n ~= n
end

-- Taken from E2Lib

-- This function clamps the position before moving the entity
local minx, miny, minz = -16384, -16384, -16384
local maxx, maxy, maxz = 16384, 16384, 16384
local clamp = math.Clamp
local function clampPos(pos)
	pos.x = clamp(pos.x, minx, maxx)
	pos.y = clamp(pos.y, miny, maxy)
	pos.z = clamp(pos.z, minz, maxz)
	return pos
end

function SF.setPos(ent, pos)
	if isnan(pos.x) or isnan(pos.y) or isnan(pos.z) then return end
	return ent:SetPos(clampPos(pos))
end

local huge, abs = math.huge, math.abs
function SF.setAng(ent, ang)
	if isnan(ang.pitch) or isnan(ang.yaw) or isnan(ang.roll) then return end
	if abs(ang.pitch) == huge or abs(ang.yaw) == huge or abs(ang.roll) == huge then return false end -- SetAngles'ing inf crashes the server
	return ent:SetAngles(ang)
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
	util.AddNetworkString("starfall_requpload")
	util.AddNetworkString("starfall_upload")
	util.AddNetworkString("starfall_addnotify")
	util.AddNetworkString("starfall_console_print")
	util.AddNetworkString("starfall_openeditor")
	util.AddNetworkString("starfall_chatprint")
	
	local uploaddata = SF.EntityTable("sfTransfer")

	--- Requests a player to send whatever code they have open in his/her editor to
	-- the server.
	-- @server
	-- @param ply Player to request code from
	-- @param callback Called when all of the code is recieved. Arguments are either the main filename and a table
	-- of filename->code pairs, or nil if the client couldn't handle the request (due to bad includes, etc)
	-- @return True if the code was requested, false if an incomplete request is still in progress for that player
	function SF.RequestCode(ply, callback)
		if uploaddata[ply] and uploaddata[ply].timeout > CurTime() then return false end
		
		net.Start("starfall_requpload")
		net.Send(ply)

		uploaddata[ply] = {
			files = {},
			mainfile = nil,
			needHeader = true,
			callback = callback,
			timeout = CurTime() + 1
		}
		return true
	end
	
	net.Receive("starfall_upload", function(len, ply)
		local updata = uploaddata[ply]
		if not updata then
			ErrorNoHalt("SF: Player "..ply:GetName().." tried to upload code without being requested (expect this message multiple times)\n")
			return
		end
		
		updata.mainfile = net.ReadString()
		
		local I = 0
		while I < 256 do
			if net.ReadBit() ~= 0 then break end
			local filename = net.ReadString()

			net.ReadStream(ply, function(data)
				if not data and uploaddata[ply]==updata then
					SF.AddNotify(ply, "There was a problem uploading your code. Try again in a second.", "ERROR", 7, "ERROR1")
					uploaddata[ply] = nil
					return
				end
				updata.Completed = updata.Completed + 1
				updata.files[filename] = data
				if updata.Completed == updata.NumFiles then
					updata.callback(updata.mainfile, updata.files)
					uploaddata[ply] = nil
				end
			end)
			I = I + 1
		end

		updata.Completed = 0
		updata.NumFiles = I
		
		if I == 0 then
			uploaddata[ply] = nil
		end
	end)

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
	net.Receive("starfall_openeditor", function(len)		
		SF.Editor.open()
		
		local gate = net.ReadEntity()
		
		hook.Add("Think", "WaitForEditor", function()
			if SF.Editor.initialized then
				if IsValid(gate) and gate.files then
					for name, code in pairs(gate.files) do
						SF.Editor.openWithCode(name, code)
					end
				end
				hook.Remove("Think", "WaitForEditor")
			end
		end)
	end)
	
	net.Receive("starfall_requpload", function(len)
		local ok, list = SF.Editor.BuildIncludesTable()
		if ok then
			--print("Uploading SF code")
			net.Start("starfall_upload")
			net.WriteString(list.mainfile)
			
			for name, data in pairs(list.files) do
				net.WriteBit(false)
				net.WriteString(name)
				net.WriteStream(data)
			end

			net.WriteBit(true)
			net.SendToServer()
			--print("Done sending")
		else
			net.Start("starfall_upload")
			net.WriteString("")
			net.WriteBit(true)
			net.SendToServer()
			if list then
				SF.AddNotify(LocalPlayer(), list, "ERROR", 7, "ERROR1")
			end
		end
	end)

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

-----------------------------------------------------------------------------

do
	
	MsgN("-SF - Loading Libraries")
	
	local print = function(...)
		if SF_VERBOSE_INIT ~= false then return print(...) end
	end
	local MsgN = function(...)
		if SF_VERBOSE_INIT ~= false then return MsgN(...) end
	end
	
	if SERVER then
		local l

		MsgN("- Loading shared libraries")
		l = file.Find("starfall/libs_sh/*.lua", "LUA")
		for _, filename in pairs(l) do
			print("-  Loading "..filename)
			include("starfall/libs_sh/"..filename)
			AddCSLuaFile("starfall/libs_sh/"..filename)
		end
		MsgN("- End loading shared libraries")

		MsgN("- Loading SF server-side libraries")
		l = file.Find("starfall/libs_sv/*.lua", "LUA")
		for _, filename in pairs(l) do
			print("-  Loading "..filename)
			include("starfall/libs_sv/"..filename)
		end
		MsgN("- End loading server-side libraries")


		MsgN("- Adding client-side libraries to send list")
		l = file.Find("starfall/libs_cl/*.lua", "LUA")
		for _, filename in pairs(l) do
			print("-  Adding "..filename)
			AddCSLuaFile("starfall/libs_cl/"..filename)
		end
		MsgN("- End loading client-side libraries")

		MsgN("-End Loading SF Libraries")

	else
		local l

		MsgN("- Loading shared libraries")
		l = file.Find("starfall/libs_sh/*.lua", "LUA")
		for _, filename in pairs(l) do
			print("-  Loading "..filename)
			include("starfall/libs_sh/"..filename)
		end
		MsgN("- End loading shared libraries")

		MsgN("- Loading client-side libraries")
		l = file.Find("starfall/libs_cl/*.lua", "LUA")
		for _, filename in pairs(l) do
			print("-  Loading "..filename)
			include("starfall/libs_cl/"..filename)
		end
		MsgN("- End loading client-side libraries")


		MsgN("-End Loading SF Libraries")

	end
end

do
	local function cleanHooks(path)
		for k, v in pairs(SF.Libraries.hooks) do
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
				SF.Libraries.CallHook("postload")
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
					SF.Libraries.CallHook("postload")
				end
			end)
		end)
		
	end
end

SF.Libraries.CallHook("postload")
