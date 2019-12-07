-------------------------------------------------------------------------------
-- The main Starfall library
-------------------------------------------------------------------------------
SF = SF or {}

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
							if SF.instance then return myMetaFunc(...) else return v(...) end
						end
					else
						meta[k] = function(...)
							if not SF.instance then return v(...) end
						end
					end
				elseif istable(v) and k=="__index" then
					local myMetaFunc = myMeta and myMeta[k]
					if myMetaFunc then
						meta[k] = function(t,k)
							if SF.instance then return myMetaFunc(t,k) else return rawget(t,k) end
						end
					else
						meta[k] = function(t,k)
							if not SF.instance then return rawget(t,k) end
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
	__call = function(p, data)
		local cache = {}
		return setmetatable({}, {
			__index = function(t, k)
				if cache[k] then
					return cache[k]
				else
					local ret = SF.WrapObject(data[k])
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
		if istable(k) then error("Tried to shallow copy a table!!") end
		if istable(v) then
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
-- @param level Level at which to error at. 2 is added to this value. Default is 1.
function SF.CheckType(val, typ, level)
	local meta = dgetmeta(val)
	if meta == typ or (meta and meta.__supertypes and meta.__supertypes[typ] and SF.Types[meta]) then
		return val
	else
		assert(istable(typ) and typ.__metatable and isstring(typ.__metatable))
		level = (level or 1) + 2
		SF.ThrowTypeError(typ.__metatable, SF.GetType(val), level)
	end
end

--- Gets the type of val.
-- @param val The value to be checked.
function SF.GetType(val)
	local mt = dgetmeta(val)
	return (mt and mt.__metatable and isstring(mt.__metatable)) and mt.__metatable or type(val)
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

-- ------------------------------------------------------------------------- --

local object_wrappers = {}
local object_unwrappers = {}
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
	if target_metatable ~= nil then
		object_wrappers[target_metatable] = wrap
	end

	local function unwrap(value)
		return sf2sensitive[value]
	end
	object_unwrappers[metatable] = unwrap

	return wrap, unwrap
end

--- Helper function for adding custom wrappers
-- @param object_meta metatable of object
-- @param sf_object_meta starfall metatable of object
-- @param wrapper function that wraps object
function SF.AddObjectWrapper(object_meta, sf_object_meta, wrapper)
	object_wrappers[object_meta] = wrapper
end

--- Helper function for adding custom unwrappers
-- @param object_meta metatable of object
-- @param unwrapper function that unwraps object
function SF.AddObjectUnwrapper(object_meta, unwrapper)
	object_unwrappers[object_meta] = unwrapper
end

--- Returns the wrapper table of a specified type
-- @param meta The type's metatable
-- @return The sf to sensitive wrapper table
-- @return The sensitive to sf wrapper table
function SF.GetWrapperTables(meta)
	return sensitive2sf_tables[meta], sf2sensitive_tables[meta]
end

-- A list of safe data types
local safe_types = {
	[TYPE_NUMBER] = true,
	[TYPE_STRING] = true,
	[TYPE_BOOL] = true,
	[TYPE_NIL] = true,
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
		else
			-- If the object is already an SF type
			local sf2sensitive = sf2sensitive_tables[metatable]
			if sf2sensitive and sf2sensitive[object] then
				return object
			end
		end
	end
	-- Do not elseif here because strings do have a metatable.
	if safe_types[TypeID(object)] then
		return object
	end
end

--- Takes a wrapped starfall object and returns the unwrapped version
-- @param object the wrapped starfall object, should work on any starfall
-- wrapped object.
-- @return the unwrapped starfall object
function SF.UnwrapObject(object)
	local metatable = dgetmeta(object)
	if metatable then
		local unwrap = object_unwrappers[metatable]
		if unwrap then
			return unwrap(object)
		end
	end
	if safe_types[TypeID(object)] then
		return object
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
function SF.Sanitize(original)
	local completed_tables = {}

	local function RecursiveSanitize(tbl)
		local return_list = {}
		completed_tables[tbl] = return_list
		for key, value in pairs(tbl) do
			local keyt = TypeID(key)
			local valuet = TypeID(value)
			if not safe_types[keyt] then
				key = SF.WrapObject(key) or (keyt == TYPE_TABLE and (completed_tables[key] or RecursiveSanitize(key)) or nil)
			end
			if not safe_types[valuet] then
				value = SF.WrapObject(value) or (valuet == TYPE_TABLE and (completed_tables[value] or RecursiveSanitize(value)) or nil)
			end
			return_list[key] = value
		end
		return return_list
	end

	return RecursiveSanitize(original)
end

--- Takes output from starfall and does it's best to make the output
-- fully usable outside of starfall environment
function SF.Unsanitize(original)
	local completed_tables = {}

	local function RecursiveUnsanitize(tbl)
		local return_list = {}
		completed_tables[tbl] = return_list
		for key, value in pairs(tbl) do
			if TypeID(key) == TYPE_TABLE then
				key = SF.UnwrapObject(key) or completed_tables[key] or RecursiveUnsanitize(key)
			end
			if TypeID(value) == TYPE_TABLE then
				value = SF.UnwrapObject(value) or completed_tables[value] or RecursiveUnsanitize(value)
			end
			return_list[key] = value
		end
		return return_list
	end

	return RecursiveUnsanitize(original)
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
	util.AddNetworkString("starfall_addnotify")
	util.AddNetworkString("starfall_console_print")
	util.AddNetworkString("starfall_chatprint")

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

	function SF.ChatPrint(ply, ...)
		local tbl = argsToChat(...)

		net.Start("starfall_chatprint")
		net.WriteUInt(#tbl, 32)
		for i, v in ipairs(tbl) do
			net.WriteType(v)
		end
		local ret = net.BytesWritten()
		net.Send(ply)
		return ret
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
				net.WriteString(path)
				net.WriteStream(file.Read(path, "LUA"))
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
			net.ReadStream(nil, function(file)
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
