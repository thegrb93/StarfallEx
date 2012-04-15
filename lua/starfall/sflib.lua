
if SF then return end -- Already loaded
SF = {}

-- Send files to client
if SERVER then
	AddCSLuaFile("sflib.lua")
	AddCSLuaFile("compiler.lua")
	AddCSLuaFile("instance.lua")
	AddCSLuaFile("libraries.lua")
	AddCSLuaFile("preprocessor.lua")
	AddCSLuaFile("permissions.lua")
	AddCSLuaFile("editor.lua")
	AddCSLuaFile("callback.lua")
end

-- Load files
include("compiler.lua")
include("instance.lua")
include("libraries.lua")
include("preprocessor.lua")
include("permissions.lua")
include("editor.lua")

SF.defaultquota = CreateConVar("sf_defaultquota", "100000", {FCVAR_ARCHIVE,FCVAR_REPLICATED},
	"The default number of Lua instructions to allow Starfall scripts to execute")

local dgetmeta = debug.getmetatable
local object_wrappers = {}
local object_unwrappers = {}

--- Creates a type that is safe for SF scripts to use. Instances of the type
-- cannot access the type's metatable or metamethods.
-- @return The table to store normal methods
-- @return The table to store metamethods
function SF.Typedef(name)
	local methods, metamethods = {}, {}
	metamethods.__metatable = name
	metamethods.__index = methods
	return methods, metamethods
end

-- Include this file after Typedef as this file relies on it.
include("callback.lua")

do
	local env, metatable = SF.Typedef("Environment")
	--- The default environment metatable
	SF.DefaultEnvironmentMT = metatable
	--- The default environment contents
	SF.DefaultEnvironment = env
end

--- A set of all instances that have been created. It has weak keys and values.
-- Instances are put here after initialization.
SF.allInstances = setmetatable({},{__mode="kv"})

--- Calls a script hook on all processors.
function SF.RunScriptHook(hook,...)
	for _,instance in pairs(SF.allInstances) do
		if not instance.error then instance:runScriptHook(hook,...) end
	end
end

--- Creates a new context. A context is used to define what scripts will have access to.
-- @param env The environment metatable to use for the script. Default is SF.DefaultEnvironmentMT
-- @param directives Additional Preprocessor directives to use. Default is an empty table
-- @param permissions The permissions manager to use. Default is SF.DefaultPermissions
-- @param ops Operations quota. Default is specified by the convar "sf_defaultquota"
-- @param libs Additional (local) libraries for the script to access. Default is an empty table.
function SF.CreateContext(env, directives, permissions, ops, libs)
	local context = {}
	context.env = env or SF.DefaultEnvironmentMT
	context.directives = directives or {}
	context.permissions = permissions or SF.Permissions
	context.ops = ops or SF.defaultquota:GetInt()
	context.libs = libs or {}
	return context
end

--- Checks the type of val. Errors if the types don't match
-- @param val The value to be checked.
-- @param typ A string type or metatable.
-- @param level Level at which to error at. 3 is added to this value. Default is 0.
-- @param default A value to return if val is nil.
function SF.CheckType(val, typ, level, default)
	if not val and default then return default
	elseif type(val) == typ then return val
	elseif dgetmeta(val) == typ then return val
	else
		level = (level or 0) + 3
		
		local typname
		if type(typ) == "table" then
			assert(typ.__metatable and type(typ.__metatable) == "string")
			typname = typ.__metatable
		else
			typname = typ
		end
		
		local funcname = debug.getinfo(level-1, "n").name or "<unnamed>"
		local mt = getmetatable(val)
		error("Type mismatch (Expected "..typname..", got "..(type(mt) == "string" and mt or type(val))..") in function "..funcname,level)
	end
	
end

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
function SF.CreateWrapper(metatable, weakwrapper, weaksensitive, 
			target_metatable )
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

	local sensitive2sf = setmetatable({},{__mode=s2sfmode})
	local sf2sensitive = setmetatable({},{__mode=sf2smode})
	
	local function wrap(value)
		if sensitive2sf[value] then return sensitive2sf[value] end
		local tbl = setmetatable({},metatable)
		sensitive2sf[value] = tbl
		sf2sensitive[tbl] = value
		return tbl
	end
	
	local function unwrap(value)
		return sf2sensitive[value]
	end
	
	if nil ~= target_metatable then
		object_wrappers[target_metatable] = wrap
	end
	
	object_unwrappers[metatable] = unwrap
	
	return wrap, unwrap
end

--- Wraps the given object so that it is safe to pass into starfall
-- It will wrap it as long as we have the metatable of the object that is
-- getting wrapped.
-- @param object the object needing to get wrapped as it's passed into starfall
-- @return returns nil if the object doesn't have a known wrapper,
-- or returns the wrapped object if it does have a wrapper.
function SF.WrapObject( object )
	local metatable = dgetmeta(object)
	
	local wrap = object_wrappers[metatable]
	return wrap and wrap(object)
end

--- Takes a wrapped starfall object and returns the unwrapped version
-- @param object the wrapped starfall object, should work on any starfall
-- wrapped object.
-- @return the unwrapped starfall object
function SF.UnwrapObject( object )
	local metatable = degetmeta(object)
	
	local unwrap = object_unwrappers[metatable]
	return unwrap and unwrap(object)
end

local wrappedfunctions = setmetatable({},{__mode="kv"})
local wrappedfunctions2instance = setmetatable({},{__mode="kv"})
--- Wraps the given starfall function so that it may called directly by GMLua
-- @param func The starfall function getting wrapped
-- @param instance The instance the function originated from
-- @return a function That when called will call the wrapped starfall function
function SF.WrapFunction( func, instance )
	if wrappedfunctions[func] then return wrappedfunctions[func] end
	
	local function returned_func( ... )
		return SF.Unsanitize( instance:runFunction( func, SF.Sanitize(...) ) )
	end
	wrappedfunctions[func] = returned_func
	wrappedfunctions2instance[func] = instance
	
	return returned_func
end

--- Gets the instance a wrapped function is bound to
-- @param func Function
-- @return Instance
function SF.WrappedFunctionInstance(func)
	return wrappedfunctions2instance[func]
end

-- A list of safe data types
local safe_types = {
	["number"  ] = true,
	["string"  ] = true,
	["Vector"  ] = true,
	["Angle"   ] = true,
	["Angle"   ] = true,
	["Matrix"  ] = true,
	["boolean" ] = true,
	["nil"     ] = true,
}

--- Sanitizes and returns its argument list.
-- Basic types are returned unchanged. Non-object tables will be
-- recursed into and their keys and values will be sanitized. Object
-- types will be wrapped if a wrapper is available. When a wrapper is
-- not available objects will be replaced with nil, so as to prevent
-- any possiblitiy of leakage. Functions will always be replaced with
-- nil as there is no way to verify that they are safe.
function SF.Sanitize( ... )
	-- Sanitize ALL the things.
	local return_list = {}
	if not args then args = {...} end
	
	for key, value in pairs(args) do
		local typ = type( value )
		if safe_types[ typ ] then
			return_list[key] = value
			
		elseif typ == "Entity" then
			return_list[key] = SF.Entities.Wrap(value)
			
		elseif typ == "function" then
			return_list[key] = nil
			
		elseif typ == "table" and dgetmeta(value) ~= nil then
			return_list[key] = SF.WrapObject(value)
			
		elseif typ == "table" then
			local table = {}
			for k,v in pairs(value) do
				table[SF.Sanitize(k)] = SF.Sanitize(v)
			end
			
			return_list[key] = table
			
		else 
			return_list[key] = nil
		end
	end
	
	return unpack(return_list)
end

--- Takes output from starfall and does it's best to make the output
-- fully usable outside of starfall environment
function SF.Unsanitize( ... )
	local return_list = {}
	
	local args = {...}
	
	for key, value in pairs( args ) do
		if type(value) == "table" and dgetmeta(value) then
			local unwrapped = SF.UnwrapObject(value)
			if nil == unwrapped then
				unwrapped = value
			end
			return_list[key] = unwrapped
		
		elseif type(value) == "table" then
			for k,v in pairs(value) do
				return_list[SF.Unsanitize(k)] = SF.Unsanitize(v)
			end
			
		elseif type(value) == "Entity" then
			local unwrap = SF.Entities.Unwrap(value)
			
			return_list[key] = unwrap
		
		else
			return_list[key] = value
		end
	end
end

-- Library loading
if SERVER then
	local l
	MsgN("-SF - Loading Libraries")

	MsgN("- Loading shared libraries")
	l = file.FindInLua("starfall/libs_sh/*.lua")
	for _,filename in pairs(l) do
		print("-  Loading "..filename)
		include("starfall/libs_sh/"..filename)
		AddCSLuaFile("starfall/libs_sh/"..filename)
	end
	MsgN("- End loading shared libraries")
	
	MsgN("- Loading SF server-side libraries")
	l = file.FindInLua("starfall/libs_sv/*.lua")
	for _,filename in pairs(l) do
		print("-  Loading "..filename)
		include("starfall/libs_sv/"..filename)
	end
	MsgN("- End loading server-side libraries")

	
	MsgN("- Adding client-side libraries to send list")
	l = file.FindInLua("starfall/libs_cl/*.lua")
	for _,filename in pairs(l) do
		print("-  Adding "..filename)
		AddCSLuaFile("starfall/libs_cl/"..filename)
	end
	MsgN("- End loading client-side libraries")
	
	MsgN("-End Loading SF Libraries")
else
	local l
	MsgN("-SF - Loading Libraries")

	MsgN("- Loading shared libraries")
	l = file.FindInLua("starfall/libs_sh/*.lua")
	for _,filename in pairs(l) do
		print("-  Loading "..filename)
		include("starfall/libs_sh/"..filename)
	end
	MsgN("- End loading shared libraries")
	
	MsgN("- Loading client-side libraries")
	l = file.FindInLua("starfall/libs_cl/*.lua")
	for _,filename in pairs(l) do
		print("-  Loading "..filename)
		include("starfall/libs_cl/"..filename)
	end
	MsgN("- End loading client-side libraries")

	
	MsgN("-End Loading SF Libraries")
end

SF.Libraries.CallHook("postload")
