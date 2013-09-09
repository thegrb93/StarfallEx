-------------------------------------------------------------------------------
-- Hook library
-------------------------------------------------------------------------------

--- Deals with hooks
-- @shared
local hook_library, _ = SF.Libraries.Register("hook")
local registered_instances = {}

--- Sets a hook function
function hook_library.add(hookname, name, func)
	SF.CheckType(hookname,"string")
	SF.CheckType(name,"string")
	if func then SF.CheckType(func,"function") else return end
	
	local inst = SF.instance
	local hooks = inst.hooks[hookname:lower()]
	if not hooks then
		hooks = {}
		inst.hooks[hookname:lower()] = hooks
	end
	
	hooks[name] = func
	registered_instances[inst] = true
end

--- Run a hook
-- @shared
-- @param hookname The hook name
-- @param ... arguments
function hook_library.run(hookname, ...)
	SF.CheckType(hookname,"string")
	
	local instance = SF.instance
	local lower = hookname:lower()
	if instance.hooks[lower] then
		for k,v in pairs( instance.hooks[lower] ) do
			local ok, tbl, traceback = instance:runWithOps(v, ...)--instance:runFunction( v )
			if not ok and instance.runOnError then
				instance.runOnError( tbl[1] )
				hook_library.remove( hookname, k )
			elseif next(tbl) ~= nil then
				return unpack( tbl )
			end
		end		
	end
end

--- Remove a hook
-- @shared
-- @param hookname The hook name
-- @param name The unique name for this hook
function hook_library.remove( hookname, name )
	SF.CheckType(hookname,"string")
	SF.CheckType(name,"string")
	local instance = SF.instance
	
	local lower = hookname:lower()
	if instance.hooks[lower] then
		instance.hooks[lower][name] = nil
		
		if not next(instance.hooks[lower]) then
			instance.hooks[lower] = nil
		end
	end
	
	if not next(instance.hooks) then
		registered_instances[instance] = nil
	end
end

SF.Libraries.AddHook("deinitialize",function(instance)
	registered_instances[instance] = nil
end)

SF.Libraries.AddHook("cleanup",function(instance)
	if instance.error then
		registered_instances[instance] = nil
		instance.hooks = {}
	end
end)

--[[
local blocked_types = {
	PhysObj = true,
	NPC = true,
}
local function wrap( value )
	if type(value) == "table" then
		return setmetatable( {}, {__metatable = "table", __index = value, __newindex = function() end} )
	elseif blocked_types[type(value)] then
		return nil
	else
		return SF.WrapObject( value ) or value
	end
end

-- Helper function for hookAdd
local function wrapArguments( ... )
	local t = {...}
	return wrap(t[1]), wrap(t[2]), wrap(t[3]), wrap(t[4]), wrap(t[5]), wrap(t[6])
end
]]

local wrapArguments = SF.Sanitize

--local run = SF.RunScriptHook

local function run( hookname, customfunc, ... )
	for instance,_ in pairs( registered_instances ) do
		if instance.hooks[hookname] then
			for name, func in pairs( instance.hooks[hookname] ) do
				local ok, ret = instance:runFunctionT( func, ... )
				if ok and customfunc then
					return customfunc( instance, ret )
				end
			end
		end
	end
end


local hooks = {}
--- Add a GMod hook so that SF gets access to it
-- @shared
-- @param hookname The hook name. In-SF hookname will be lowercased
-- @param customfunc Optional custom function
function SF.hookAdd( hookname, customfunc )
	hooks[#hooks+1] = hookname
	local lower = hookname:lower()
	hook.Add( hookname, "SF_" .. hookname, function(...)
		return run( lower, customfunc, wrapArguments( ... ) )
	end)
end


--- Gets a list of all available hooks
-- @shared
function hook_library.getList()
	return setmetatable({},{__metatable = "table", __index = hooks, __newindex = function() end})
end

local add = SF.hookAdd


if SERVER then
	-- Server hooks
	add( "GravGunOnPickedUp" )
	add( "GravGunOnDropped" )
	add( "OnPhysgunFreeze" )
	add( "OnPhysgunReload" )
	add( "PlayerDeath" )
	add( "PlayerDisconnected" )
	add( "PlayerInitialSpawn" )
	add( "PlayerSpawn" )
	add( "PlayerLeaveVehicle" )
	add( "PlayerSay", function( instance, args ) if args then return args[1] end end )
	add( "PlayerSpray" )
	add( "PlayerUse" )
	add( "PlayerSwitchFlashlight" )
else
	-- Client hooks
	-- todo
end

-- Shared hooks

-- Player hooks
add( "PlayerHurt" )
add( "PlayerNoClip" )
add( "KeyPress" )
add( "KeyRelease" )
add( "GravGunPunt" )
add( "PhysgunPickup" )
add( "PhysgunDrop" )

-- Entity hooks
add( "OnEntityCreated" )
add( "EntityRemoved" )

-- Other
add( "EndEntityDriving" )
add( "StartEntityDriving" )
