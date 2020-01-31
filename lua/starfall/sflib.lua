-------------------------------------------------------------------------------
-- The main Starfall library
-------------------------------------------------------------------------------
SF.Modules = {}
SF.Types = {}
SF.Libraries = {}
local dgetmeta = debug.getmetatable

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

	local string_methods = SF.SafeStringLib
	local function sf_string_index(self, key)
		local val = string_methods[key]
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
function SF.MakeError(msg, level, uncatchable, prependinfo)
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
-- Starfall instance hook management
-------------------------------------------------------------------------------

do
	local registered_instances = {}
	local gmod_hooks = {}

	local function getHookFunc(instances, hookname, customargfunc, customretfunc)
		--- There are 4 varients of hookfunc depending on if there are custom callbacks
		if customargfunc then
			if customretfunc then
				return function(...)
					local result
					for instance, _ in pairs(instances) do
						local canrun, customargs = customargfunc(instance, ...)
						if canrun then
							local tbl = instance:runScriptHookForResult(hookname, unpack(customargs))
							if tbl[1] then
								local sane = customretfunc(instance, tbl, ...)
								if sane ~= nil then result = sane end
							end
						end
					end
					return result
				end
			else
				return function(...)
					for instance, _ in pairs(instances) do
						local canrun, customargs = customargfunc(instance, ...)
						if canrun then
							instance:runScriptHook(hookname, unpack(customargs))
						end
					end
				end
			end
		else
			if customretfunc then
				return function(...)
					local result
					for instance, _ in pairs(instances) do
						local tbl = instance:runScriptHookForResult(hookname, unpack(instance.Sanitize({...})))
						if tbl[1] then
							local sane = customretfunc(instance, tbl, ...)
							if sane ~= nil then result = sane end
						end
					end
					return result
				end
			else
				return function(...)
					for instance, _ in pairs(instances) do
						instance:runScriptHook(hookname, unpack(instance.Sanitize({...})))
					end
				end
			end
		end
	end

	--- Add a GMod hook so that SF gets access to it
	-- @shared
	-- @param hookname The hook name. In-SF hookname will be lowercased
	-- @param customargfunc Optional custom function
	-- Returns true if the hook should be called, then extra arguements to be passed to the starfall hooks
	-- @param customretfunc Optional custom function
	-- Takes values returned from starfall hook and returns what should be passed to the gmod hook
	-- @param gmoverride Whether this hook should override the gamemode function (makes the hook run last, but adds a little overhead)
	function SF.hookAdd(realname, hookname, customargfunc, customretfunc, gmoverride)
		hookname = hookname or realname:lower()
		registered_instances[hookname] = {}
		if gmoverride then
			local function override(again)
				local hookfunc = getHookFunc(registered_instances[hookname], hookname, customargfunc, customretfunc)

				local gmfunc
				if again then
					gmfunc = GAMEMODE["SF"..realname]
				else
					gmfunc = GAMEMODE[realname]
					GAMEMODE["SF"..realname] = gmfunc
				end

				if gmfunc then
					GAMEMODE[realname] = function(gm, ...)
						local a,b,c,d,e,f = hookfunc(...)
						if a~= nil then return a,b,c,d,e,f
						else return gmfunc(gm, ...) end
					end
				else
					GAMEMODE[realname] = function(gm, ...)
						return hookfunc(...)
					end
				end
			end
			if GAMEMODE then
				override(true)
			else
				hook.Add("Initialize", "SF_Hook_Override"..hookname, override)
			end
		else
			gmod_hooks[hookname] = { realname, customargfunc, customretfunc }
		end
	end

	function SF.HookAddInstance(instance, hookname)
		local instances = registered_instances[hookname]
		if instances then
			if next(instances)==nil then
				local gmod_hook = gmod_hooks[hookname]
				if gmod_hook then
					local realname, customargfunc, customretfunc = unpack(gmod_hook)
					local hookfunc = getHookFunc(instances, hookname, customargfunc, customretfunc)
					hook.Add(realname, "SF_Hook_"..hookname, hookfunc)
				end
			end
			instances[instance] = true
		end
	end
	
	function SF.HookRemoveInstance(instance, hookname)
		local instances = registered_instances[hookname]
		if instances then
			instances[instance] = nil
			if not next(instances) then
				local gmod_hook = gmod_hooks[hookname]
				if gmod_hook then
					hook.Remove(gmod_hook[1], "SF_Hook_" .. hookname)
				end
			end
		end
	end

	function SF.HookDestroyInstance(instance)
		for hookname, instances in pairs(registered_instances) do
			instances[instance] = nil
			if not next(instances) then
				local gmod_hook = gmod_hooks[hookname]
				if gmod_hook then
					hook.Remove(gmod_hook[1], "SF_Hook_" .. hookname)
				end
			end
		end
	end
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
function SF.Throw(msg, level, uncatchable)
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

if SERVER then
	local initplayers = setmetatable({},{__mode="k"})
	concommand.Add("_sf_plyinit",function(ply)
		if initplayers[ply] then
			for k, v in ipairs(initplayers[ply]) do
				v()
			end
			initplayers[ply] = nil
		end
	end)
	function SF.WaitForPlayerInit(ply, func)
		local t = initplayers[ply]
		if not t then t = {} initplayers[ply] = t end
		t[#t+1] = func
	end
else
	hook.Add("HUDPaint","SF_Init",function()
		RunConsoleCommand("_sf_plyinit")
		hook.Remove("HUDPaint","SF_Init")
	end)
end

--- Gets the type of val.
-- @param val The value to be checked.
function SF.GetType(val)
	local meta = dgetmeta(val)
	return meta and isstring(meta.__metatable) and meta.__metatable or type(val)
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

	function SF.AddNotify(ply, msg, notifyType, duration, sound)
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

	function SF.Print(ply, msg)
		net.Start("starfall_console_print")
			net.WriteString(msg)
		if ply then net.Send(ply) else net.Broadcast() end
	end

else

	function SF.AddNotify(ply, msg, type, duration, sound)
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


do
	local middleclass = {
		_VERSION     = 'middleclass v4.1.1',
		_DESCRIPTION = 'Object Orientation for Lua',
		_URL         = 'https://github.com/kikito/middleclass',
		_LICENSE     = [[
		MIT LICENSE

		Copyright (c) 2011 Enrique García Cota

		Permission is hereby granted, free of charge, to any person obtaining a
		copy of this software and associated documentation files (the
		"Software"), to deal in the Software without restriction, including
		without limitation the rights to use, copy, modify, merge, publish,
		distribute, sublicense, and/or sell copies of the Software, and to
		permit persons to whom the Software is furnished to do so, subject to
		the following conditions:

		The above copyright notice and this permission notice shall be included
		in all copies or substantial portions of the Software.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
		OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
		MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
		IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
		CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
		TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
		SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
		]]
	}

	local function _createIndexWrapper(aClass, f)
		if f == nil then
		return aClass.__instanceDict
		else
		return function(self, name)
			local value = aClass.__instanceDict[name]

			if value ~= nil then
			return value
			elseif isfunction(f) then
			return (f(self, name))
			else
			return f[name]
			end
		end
		end
	end

	local function _propagateInstanceMethod(aClass, name, f)
		f = name == "__index" and _createIndexWrapper(aClass, f) or f
		aClass.__instanceDict[name] = f

		for subclass in pairs(aClass.subclasses) do
		if rawget(subclass.__declaredMethods, name) == nil then
			_propagateInstanceMethod(subclass, name, f)
		end
		end
	end

	local function _declareInstanceMethod(aClass, name, f)
		aClass.__declaredMethods[name] = f

		if f == nil and aClass.super then
		f = aClass.super.__instanceDict[name]
		end

		_propagateInstanceMethod(aClass, name, f)
	end

	local function _tostring(self) return "class " .. self.name end
	local function _call(self, ...) return self:new(...) end

	local function _createClass(name, super)
		local dict = {}
		dict.__index = dict

		local aClass = { name = name, super = super, static = {},
						 __instanceDict = dict, __declaredMethods = {},
						 subclasses = setmetatable({}, {__mode='k'})  }

		if super then
		setmetatable(aClass.static, {
			__index = function(_,k)
			local result = rawget(dict,k)
			if result == nil then
				return super.static[k]
			end
			return result
			end
		})
		else
		setmetatable(aClass.static, { __index = function(_,k) return rawget(dict,k) end })
		end

		setmetatable(aClass, { __index = aClass.static, __tostring = _tostring,
							 __call = _call, __newindex = _declareInstanceMethod })

		return aClass
	end

	local function _includeMixin(aClass, mixin)
		assert(istable(mixin), "mixin must be a table")

		for name,method in pairs(mixin) do
		if name ~= "included" and name ~= "static" then aClass[name] = method end
		end

		for name,method in pairs(mixin.static or {}) do
		aClass.static[name] = method
		end

		if isfunction(mixin.included) then mixin:included(aClass) end
		return aClass
	end

	local DefaultMixin = {
		__tostring   = function(self) return "instance of " .. tostring(self.class) end,

		initialize   = function(self, ...) end,

		isInstanceOf = function(self, aClass)
		return istable(aClass)
			 and istable(self)
			 and (self.class == aClass
				or istable(self.class)
				and isfunction(self.class.isSubclassOf)
				and self.class:isSubclassOf(aClass))
		end,

		static = {
		allocate = function(self)
			assert(istable(self), "Make sure that you are using 'Class:allocate' instead of 'Class.allocate'")
			return setmetatable({ class = self }, self.__instanceDict)
		end,

		new = function(self, ...)
			assert(istable(self), "Make sure that you are using 'Class:new' instead of 'Class.new'")
			local instance = self:allocate()
			instance:initialize(...)
			return instance
		end,

		subclass = function(self, name)
			assert(istable(self), "Make sure that you are using 'Class:subclass' instead of 'Class.subclass'")
			assert(isstring(name), "You must provide a name(string) for your class")

			local subclass = _createClass(name, self)

			for methodName, f in pairs(self.__instanceDict) do
			_propagateInstanceMethod(subclass, methodName, f)
			end
			subclass.initialize = function(instance, ...) return self.initialize(instance, ...) end

			self.subclasses[subclass] = true
			self:subclassed(subclass)

			return subclass
		end,

		subclassed = function(self, other) end,

		isSubclassOf = function(self, other)
			return istable(other) and
				istable(self.super) and
				( self.super == other or self.super:isSubclassOf(other) )
		end,

		include = function(self, ...)
			assert(istable(self), "Make sure you that you are using 'Class:include' instead of 'Class.include'")
			for _,mixin in ipairs({...}) do _includeMixin(self, mixin) end
			return self
		end
		}
	}

	local checkluatype = SF.CheckLuaType
	function SF.Class(name, super)
		checkluatype(name, TYPE_STRING)
		if super~=nil then checkluatype(super, TYPE_TABLE) end
		return super and super:subclass(name) or _includeMixin(_createClass(name), DefaultMixin)
	end
end


do
	local checkluatype = SF.CheckLuaType
	local string_methods = {}
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
		checkluatype(str, TYPE_STRING)
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
		checkluatype(str, TYPE_STRING)
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
	SF.SafeStringLib = string_methods
end


-------------------------------------------------------------------------------
-- Includes
-------------------------------------------------------------------------------

include("instance.lua")
include("preprocessor.lua")
include("permissions/core.lua")
include("editor/editor.lua")
include("netstream.lua")
include("transfer.lua")

do
	local function compileModule(source, path)
		local ok, init = xpcall(function() return CompileString(source, path)() end, debug.traceback)
		if ok then
			if not isfunction(init) then
				ErrorNoHalt("[SF] Attempt to load bad module: " .. path .. "\n")
				init = nil
			end
		else
			ErrorNoHalt(init .. "\n")
			init = nil
		end
		return init
	end
	
	local function addModule(source, name, path, shouldrun)
		local init
		if shouldrun then
			init = compileModule(source, path)
		end
		local tbl = SF.Modules[name]
		if not tbl then tbl = {} SF.Modules[name] = tbl end
		tbl[path] = {source = source, init = init}
	end

	local function loadModules(folder, shouldrun)
		local l = file.Find(folder.."*.lua", "LUA")
		for _, filename in pairs(l) do
			local path = folder..filename
			local source = file.Read(path, "LUA")
			addModule(source, string.StripExtension(filename), path, shouldrun)
		end
	end

	if SERVER then
		util.AddNetworkString("sf_receivelibrary")

		loadModules("starfall/libs_sh/", SERVER or CLIENT)
		loadModules("starfall/libs_sv/", SERVER)
		loadModules("starfall/libs_cl/", CLIENT)
		
		SF.Permissions.loadPermissionOptions()

		hook.Add("PlayerInitialSpawn","SF_Initialize_Libraries",function(ply)
			SF.WaitForPlayerInit(ply, function()
				local files = {}
				for name, mod in pairs(SF.Modules) do
					for path, val in pairs(mod) do
						files[name..":"..path] = val.source
					end
				end
				net.Start("sf_receivelibrary")
				net.WriteBool(true)
				net.WriteStarfall({files = files, mainfile = "", proc = Entity(0), owner = Entity(0)})
				net.Broadcast()
			end)
		end)
	end

	if SERVER then
		-- Command to reload the libraries
		concommand.Add("sf_reloadlibrary", function(ply, com, arg)
			if ply:IsValid() and not ply:IsSuperAdmin() then return end
			local name = arg[1]
			if not name then return end
			name = string.lower(name)

			local sv_filename = "starfall/libs_sv/"..name..".lua"
			local sh_filename = "starfall/libs_sh/"..name..".lua"
			local cl_filename = "starfall/libs_cl/"..name..".lua"

			local sendToClientTbl = {}
			if file.Exists(sh_filename, "LUA") or file.Exists(sv_filename, "LUA") then
				print("Reloaded library: " .. name)
				SF.Modules[name] = {}
				if file.Exists(sh_filename, "LUA") then
					local source = file.Read(sh_filename, "LUA")
					addModule(source, name, sh_filename, true)
					sendToClientTbl[#sendToClientTbl+1] = sh_filename
				end
				if file.Exists(sv_filename, "LUA") then
					local source = file.Read(sv_filename, "LUA")
					addModule(source, name, sv_filename, true)
				end
			end
			if file.Exists(cl_filename, "LUA") then
				local source = file.Read(cl_filename, "LUA")
				addModule(source, name, cl_filename, false)
				sendToClientTbl[#sendToClientTbl+1] = cl_filename
			end
			if #sendToClientTbl>0 then
				local files = {}
				for k, path in pairs(sendToClientTbl) do
					files[name..":"..path] = SF.Modules[name][path].source
				end
				net.Start("sf_receivelibrary")
				net.WriteBool(false)
				net.WriteStarfall({files = files, mainfile = name, proc = Entity(0), owner = Entity(0)})
				net.Broadcast()
			end
		end)

	else
		net.Receive("sf_receivelibrary", function(len)
			local init = net.ReadBool()
			net.ReadStarfall(nil, function(ok, data)
				if ok then
					if not init then
						SF.Modules[data.mainfile] = {}
						print("Reloaded library: " .. data.mainfile)
					end
					for k, code in pairs(data.files) do
						local modname, path = string.match(k, "(.+):(.+)")
						local t = SF.Modules[modname]
						if not t then t = {} SF.Modules[modname] = t end
						local shouldrun
						if string.find(path, "starfall/libs_sv", 1, true) then
							shouldrun = SERVER
						elseif string.find(path, "starfall/libs_sh", 1, true) then
							shouldrun = true
						elseif string.find(path, "starfall/libs_cl", 1, true) then
							shouldrun = CLIENT
						end
						SF.Modules[modname][path] = {source = code, init = shouldrun and compileModule(code, path) or nil}
					end
					if init then
						SF.Permissions.loadPermissionOptions()
						include("starfall/editor/docs.lua")
					end
				end
			end)
		end)
	end
end

include("editor/editor.lua")
