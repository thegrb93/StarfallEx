-------------------------------------------------------------------------------
-- The main Starfall library
-------------------------------------------------------------------------------
SF = SF or {}
SF.Modules = {}

local dgetmeta = debug.getmetatable

-------------------------------------------------------------------------------
-- Some basic initialization
-------------------------------------------------------------------------------

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
	SetGlobalString("SF.Version", SF.Version)
end

-- Make sure this is done after metatables have been set
hook.Add("InitPostEntity","SF_SanitizeTypeMetatables",function()
	local function sanitizeTypeMeta(theType, myMeta)
		local meta = debug.getmetatable(theType)
		if meta then
			for k, v in pairs(meta) do
				if isfunction(v) then
					local myMetaFunc = myMeta and myMeta[k]
					if myMetaFunc then
						meta[k] = function(...)
							if SF.runningOps then return myMetaFunc(...) else return v(...) end
						end
					else
						meta[k] = function(...)
							if not SF.runningOps then return v(...) end
						end
					end
				elseif istable(v) and k=="__index" then
					local myMetaFunc = myMeta and myMeta[k]
					if myMetaFunc then
						meta[k] = function(t,k)
							if SF.runningOps then return myMetaFunc(t,k) else return rawget(t,k) end
						end
					else
						meta[k] = function(t,k)
							if not SF.runningOps then return rawget(t,k) end
						end
					end
				end
			end
		end
	end

	sanitizeTypeMeta(nil)
	sanitizeTypeMeta(true)
	sanitizeTypeMeta(0)
	sanitizeTypeMeta(function() end)
	sanitizeTypeMeta(coroutine.create(function() end))

	local string_methods_copy = table.Copy(SF.Libraries.string)
	local function sf_string_index(self, key)
		local val = string_methods_copy[key]
		if (val) then
			return val
		elseif (tonumber(key)) then
			return self:sub(key, key)
		else
			SF.Throw("attempt to index a string value with bad key ('" .. tostring(key) .. "' is not part of the string library)", 2)
		end
	end
	sanitizeTypeMeta("", {__index = sf_string_index})
	
	if not WireLib then WireLib = {} end
	if not WireLib.PatchedDuplicator then
		WireLib.PatchedDuplicator = true

		local localPos

		local oldSetLocalPos = duplicator.SetLocalPos
		function duplicator.SetLocalPos(pos, ...)
			localPos = pos
			return oldSetLocalPos(pos, ...)
		end

		local oldPaste = duplicator.Paste
		function duplicator.Paste(player, entityList, constraintList, ...)
			local result = { oldPaste(player, entityList, constraintList, ...) }
			local createdEntities, createdConstraints = result[1], result[2]
			local data = {
				EntityList = entityList, ConstraintList = constraintList,
				CreatedEntities = createdEntities, CreatedConstraints = createdConstraints,
				Player = player, HitPos = localPos,
			}
			hook.Run("AdvDupe_FinishPasting", {data}, 1)
			return unpack(result)
		end
	end
end)

-------------------------------------------------------------------------------
-- Declare Basic Starfall Types
-------------------------------------------------------------------------------

local EntityTable = {
	__newindex = function(t, e, v)
		rawset(t, e, v)
		if t.wait then
			e:CallOnRemove("SF_" .. t.key, function()
				timer.Simple(0, function()
					if t[e] and not e:IsValid() then
						t[e] = nil
						if t.destructor then t.destructor(e, v) end
					end
				end)
			end)
		else
			e:CallOnRemove("SF_" .. t.key, function()
				if t[e] then
					t[e] = nil
					if t.destructor then t.destructor(e, v) end
				end
			end)
		end
	end
}
-- Returns a class that manages a table of entity keys
function SF.EntityTable(key, destructor, dontwait)
	local t = {
		key = key,
		destructor = destructor,
		wait = CLIENT and not dontwait
	}
	return setmetatable(t, EntityTable)
end

--- Returns a class that wraps a structure and caches indexes
SF.StructWrapper = {
	__call = function(p, instance, data)
		local cache = {}
		return setmetatable({}, {
			__index = function(t, k)
				if cache[k] then
					return cache[k]
				else
					local ret = instance.WrapObject(data[k])
					cache[k] = ret
					return ret
				end
			end,
			__newindex = function(t, k, v)
				cache[k] = v
			end,
			__metatable = ""
		})
	end
}
setmetatable(SF.StructWrapper, SF.StructWrapper)

--- Returns a class that can manage burst objects
SF.BurstObject = {
	__index = {
		use = function(self, ply, amount)
			if ply:IsValid() then
				local obj = self:get(ply)
				local new = math.min(obj.val + (CurTime() - obj.lasttick) * self.rate, self.max) - amount
				if new < 0 then
					SF.Throw("The ".. self.name .." burst limit has been exceeded.", 3)
				end
				obj.lasttick = CurTime()
				obj.val = new
			else
				SF.Throw("Invalid starfall user", 3)
			end
		end,
		check = function(self, ply)
			if ply:IsValid() then
				local obj = self:get(ply)
				obj.val = math.min(obj.val + (CurTime() - obj.lasttick) * self.rate, self.max)
				obj.lasttick = CurTime()
				return obj.val
			else
				SF.Throw("Invalid starfall user", 3)
			end
		end,
		get = function(self, ply)
			local obj = self.objects[ply]
			if not obj then
				obj = {
					val = self.max,
					lasttick = 0
				}
				self.objects[ply] = obj
			end
			return obj
		end,
	},
	__call = function(p, cvarname, limitname, rate, max, ratehelp, maxhelp, scale)
		scale = scale or 1

		local t = {
			name = limitname,
			objects = SF.EntityTable("burst"..cvarname)
		}

		local ratename = "sf_"..cvarname.."_burstrate"..(CLIENT and "_cl" or "")
		local ratecvar = CreateConVar(ratename, tostring(rate), FCVAR_ARCHIVE, ratehelp)
		t.rate = ratecvar:GetFloat()*scale
		cvars.AddChangeCallback(ratename, function() t.rate = ratecvar:GetFloat()*scale end)

		local maxname = "sf_"..cvarname.."_burstmax"..(CLIENT and "_cl" or "")
		local maxcvar = CreateConVar(maxname, tostring(max), FCVAR_ARCHIVE, maxhelp)
		t.max = maxcvar:GetFloat()*scale
		cvars.AddChangeCallback(maxname, function() t.max = maxcvar:GetFloat()*scale end)

		return setmetatable(t, p)
	end
}
setmetatable(SF.BurstObject, SF.BurstObject)

--- Returns a class that limits the number of something per player
SF.LimitObject = {
	__index = {
		use = function(self, ply, amount)
			if ply:IsValid() then
				local obj = self:get(ply)
				local new = obj.val + amount
				if new > self.max then
					SF.Throw("The ".. self.name .." limit has been reached. (".. self.max ..")", 3)
				end
				obj.val = new
			else
				SF.Throw("Invalid starfall user", 3)
			end
		end,
		checkuse = function(self, ply, amount)
			if ply:IsValid() then
				local obj = self:get(ply)
				if obj.val + amount > self.max then
					SF.Throw("The ".. self.name .." limit has been reached. (".. self.max ..")", 3)
				end
			else
				SF.Throw("Invalid starfall user", 3)
			end
		end,
		check = function(self, ply)
			if ply:IsValid() then
				return self.max - self:get(ply).val
			else
				SF.Throw("Invalid starfall user", 3)
			end
		end,
		free = function(self, ply, amount)
			local obj = self.objects[ply]
			if obj then
				obj.val = math.Clamp(obj.val - amount, 0, self.max)
			end
		end,
		get = function(self, ply)
			local obj = self.objects[ply]
			if not obj then
				obj = {
					val = 0,
				}
				self.objects[ply] = obj
			end
			return obj
		end,
	},
	__call = function(p, cvarname, limitname, max, maxhelp, scale)
		local t = {
			name = limitname,
			objects = SF.EntityTable("limit"..cvarname)
		}

		local maxname = "sf_"..cvarname.."_max"..(CLIENT and "_cl" or "")
		local maxcvar = CreateConVar(maxname, tostring(max), FCVAR_ARCHIVE, maxhelp)
		scale = scale or 1
		local function calcMax()
			t.max = maxcvar:GetFloat()*scale
			if t.max<0 then t.max = math.huge end
		end
		calcMax()
		cvars.AddChangeCallback(maxname, calcMax)

		return setmetatable(t, p)
	end
}
setmetatable(SF.LimitObject, SF.LimitObject)

--- Returns a class that can limit per player and recycle a indestructable resource
SF.ResourceHandler = {
	__index = {
		use = function(self, ply, t)
			if self:check(ply) then
				self.objects[t] = self.objects[t] or {}
				local obj = next(self.objects[t])
				if obj then
					self.objects[t][obj] = nil
				else
					self.n = self.n + 1
					obj = self.allocator(t, self.n)
				end
				if self.initializer then self.initializer(t, obj) end
				self.players[ply] = self.players[ply] + 1
				return obj
			end
		end,
		check = function(self, ply)
			self.players[ply] = self.players[ply] or 0
			return self.players[ply] < self.max
		end,
		free = function(self, ply, object)
			local t = self.typer(object)
			if not self.objects[t][object] then
				if ply then self.players[ply] = self.players[ply] - 1 end
				self.objects[t][object] = true
				if self.destructor then self.destructor(object) end
			end
		end
	},
	__call = function(p, max, allocator, initializer, typer, destructor)
		local t = {
			n = 0,
			allocator = allocator,
			initializer = initializer,
			destructor = destructor,
			typer = typer,
			objects = {},
			players = setmetatable({},{__mode="k"}),
			max = max,
		}
		return setmetatable(t, p)
	end
}
setmetatable(SF.ResourceHandler, SF.ResourceHandler)


--- Returns a class that can whitelist/blacklist strings
SF.StringRestrictor = {
	__index = {
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
		end
	},
	__call = function(p, allowbydefault)
		local t = {
			whitelist = {}, -- patterns
			blacklist = {}, -- patterns
			default = allowbydefault or false,
		}
		return setmetatable(t, p)
	end
}
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
	if not isstring(msg) then msg = "(error object is not a string)" end

	local traceback = debug.traceback("", level)
	local lines = {}
	for v in string.gmatch(traceback, "[^\n]+") do
		if string.find(v, "[C]: in function 'xpcall'", 1, true) then break end
		lines[#lines+1] = v
	end
	traceback = table.concat(lines, "\n")

	return setmetatable({
		uncatchable = false,
		file = info.short_src,
		line = info.currentline,
		message = prependinfo and (info.short_src..":"..info.currentline..": "..msg) or msg,
		uncatchable = uncatchable,
		traceback = traceback
	}, SF.Errormeta)
end


-------------------------------------------------------------------------------
-- Utility functions
-------------------------------------------------------------------------------

function SF.CompileString(str, name, handle)
	if string.find(str, "repeat.*continue.*until") then
		return "Due to a glua bug. Use of the string 'continue' in repeat-until loops has been banned"
	end
	return CompileString(str, name, handle)
end

--- Throws an error like the throw function in builtins
-- @param msg Message
-- @param level Which level in the stacktrace to blame
-- @param uncatchable Makes this exception uncatchable
function SF.Throw (msg, level, uncatchable)
	local level = 1 + (level or 1)
	error(SF.MakeError(msg, level, uncatchable, true), level)
end

--- Throws a type error
function SF.ThrowTypeError(expected, got, level)
	local level = 1 + (level or 1)
	local funcname = debug.getinfo(level-1, "n").name or "<unnamed>"
	SF.Throw("Type mismatch (Expected " .. expected .. ", got " .. got .. ") in function " .. funcname, level)
end

--- Checks the lua type of val. Errors if the types don't match
-- @param val The value to be checked.
-- @param typ A string type or metatable.
-- @param level Level at which to error at. 2 is added to this value. Default is 1.
function SF.CheckLuaType(val, typ, level)
	local valtype = TypeID(val)
	if valtype == typ then
		return val
	else
		-- Failed, throw error
		assert(isnumber(typ))
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

		level = (level or 1) + 2
		SF.ThrowTypeError(typeLookup[typ], SF.GetType(val), level)
	end
end

function SF.WaitForEntity(index, callback)
	local ent = Entity(index)
	if ent:IsValid() then
		callback(ent)
	else
		local timeout = CurTime()+5
		local name = "SF_WaitForEntity"..index
		hook.Add("Think", name, function()
			local ent = Entity(index)
			if ent:IsValid() then
				callback(ent)
				hook.Remove("Think", name)
			elseif CurTime()>timeout then
				hook.Remove("Think", name)
			end
		end)
	end
end

function SF.WaitForPlayerInit(ply, func)
	local n = "SF_WaitForPlayerInit"..ply:EntIndex()
	hook.Add("SetupMove", n, function(ply2)
		if ply:IsValid() then
			if ply == ply2 then
				func()
				hook.Remove("SetupMove", n)
			end
		else
			hook.Remove("SetupMove", n)
		end
	end)
end

local shaderBlacklist = {
	["LightmappedGeneric"] = true,
}
local materialBlacklist = {
	["pp/copy"] = true,
	["effects/ar2_altfire1"] = true,
}
--- Checks that the material isn't malicious
-- @param material The path to the material
-- @return The material object or false if it's invalid
function SF.CheckMaterial(material)
	if material == "" then return end
	if #material > 260 then return false end
	material = string.StripExtension(SF.NormalizePath(string.lower(material)))
	if materialBlacklist[material] then return false end
	local mat = Material(material)
	if shaderBlacklist[mat:GetShader() or ""] then return false end
	return mat
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

local dumbtrace = {
	FractionLeftSolid = 0,
	HitNonWorld       = true,
	Fraction          = 0,
	Entity            = NULL,
	HitPos            = Vector(0, 0, 0),
	HitNormal         = Vector(0, 0, 0),
	HitBox            = 0,
	Normal            = Vector(1, 0, 0),
	Hit               = true,
	HitGroup          = 0,
	MatType           = 0,
	StartPos          = Vector(0, 0, 0),
	PhysicsBone       = 0,
	WorldToLocal      = Vector(0, 0, 0),
}
function SF.dumbTrace(entity, pos)
	if entity then dumbtrace.Entity = entity end
	if pos then dumbtrace.HitPos = pos end
	return dumbtrace
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

if SERVER then
	util.AddNetworkString("starfall_addnotify")
	util.AddNetworkString("starfall_console_print")

	function SF.AddNotify (ply, msg, notifyType, duration, sound)
		if not (ply and ply:IsValid()) then return end

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
		if ply then net.Send(ply) else net.Broadcast() end
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
	local function addModule(name, tbl)
		local t = SF.Modules[name]
		if t then
			t[#t+1] = tbl
		else
			SF.Modules[name] = {tbl}
		end
	end
	local function getMergedModule(tbl)
		if #tbl == 1 then
			return tbl[1]
		elseif #tbl == 2 then
			local a, b, c, d = tbl[1][1], tbl[1][2], tbl[2][1], tbl[2][2]
			return {function() a() c() end, function() b() d() end}
		else
			error("This shouldn't happen!")
		end
	end

	if SERVER then
		local l

		l = file.Find("starfall/libs_sh/*.lua", "LUA")
		for _, filename in pairs(l) do
			addModule(string.StripExtension(filename), include("starfall/libs_sh/"..filename))
			AddCSLuaFile("starfall/libs_sh/"..filename)
		end

		l = file.Find("starfall/libs_sv/*.lua", "LUA")
		for _, filename in pairs(l) do
			addModule(string.StripExtension(filename), include("starfall/libs_sv/"..filename))
			AddCSLuaFile("starfall/libs_sv/"..filename)
		end

		l = file.Find("starfall/libs_cl/*.lua", "LUA")
		for _, filename in pairs(l) do
			AddCSLuaFile("starfall/libs_cl/"..filename)
		end
	else
		local l

		l = file.Find("starfall/libs_sh/*.lua", "LUA")
		for _, filename in pairs(l) do
			addModule(string.StripExtension(filename), include("starfall/libs_sh/"..filename))
		end

		l = file.Find("starfall/libs_cl/*.lua", "LUA")
		for _, filename in pairs(l) do
			addModule(string.StripExtension(filename), include("starfall/libs_cl/"..filename))
		end
	end

	for k, v in pairs(SF.Modules) do
		SF.Modules[k] = getMergedModule(v)
	end
	SF.Permissions.loadPermissionOptions()
end

do
	if SERVER then
		local function sendToClient(name, tbl)
			if #tbl==0 then return end
			local files = {}
			for k, path in pairs(tbl) do
				files[path] = file.Read(path, "LUA")
			end
			net.Start("sf_reloadlibrary")
			net.WriteStarfall({files = files, mainfile = name, proc = Entity(0), owner = Entity(0)})
			net.Broadcast()
		end

		-- Command to reload the libraries
		util.AddNetworkString("sf_reloadlibrary")
		concommand.Add("sf_reloadlibrary", function(ply, com, arg)
			if ply:IsValid() and not ply:IsSuperAdmin() then return end
			local filename = arg[1]
			if not filename then return end
			filename = string.lower(filename)

			local sv_filename = "starfall/libs_sv/"..filename..".lua"
			local sh_filename = "starfall/libs_sh/"..filename..".lua"
			local cl_filename = "starfall/libs_cl/"..filename..".lua"

			local sendToClientTbl = {}
			if file.Exists(sh_filename, "LUA") or file.Exists(sv_filename, "LUA") then
				print("Reloaded library: " .. filename)
				SF.Modules[filename] = nil

				if file.Exists(sh_filename, "LUA") then
					addModule(filename, include(sh_filename))
					sendToClientTbl[#sendToClientTbl+1] = sh_filename
				end
				if file.Exists(sv_filename, "LUA") then
					addModule(filename, include(sv_filename))
				end

				SF.Modules[filename] = getMergedModule(SF.Modules[filename])
				xpcall(SF.Modules[filename][1], debug.traceback)
			end
			if file.Exists(cl_filename, "LUA") then
				sendToClientTbl[#sendToClientTbl+1] = cl_filename
			end
			sendToClient(filename, sendToClientTbl)
		end)

	else
		local root_path = SF.NormalizePath(string.GetPathFromFilename(debug.getinfo(1, "S").short_src).."../")
		net.Receive("sf_reloadlibrary", function(len)
			net.ReadStarfall(nil, function(ok, data)
				if ok then
					print("Reloaded library: " .. data.mainfile)
					for path, code in pairs(data.files) do
						SF.Modules[data.mainfile] = nil
						local ok, tbl = xpcall(CompileString, debug.traceback, file, root_path .. path, false)
						if ok then
							addModule(data.mainfile, tbl)
						end
					end
					SF.Modules[data.mainfile] = getMergedModule(SF.Modules[data.mainfile])
				end
			end)
		end)

	end
end
