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
	
	SF.instance = nil -- Pretend we're not running an instance
	local ret = {instance:runScriptHookForResult( lower, ... )}
	SF.instance = instance -- Set it back
	
	local ok = table.remove( ret, 1 )
	if not ok then
		instance:Error( "Hook '" .. lower .. "' errored with " .. ret[1], ret[2] )
		return
	end
	
	return unpack(ret)
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

SF.Libraries.AddHook("cleanup",function(instance,name,func,err)
	if name == "_runFunction" and err == true then
		registered_instances[instance] = nil
		instance.hooks = {}
	end
end)

local wrapArguments = SF.Sanitize

local function run( hookname, customfunc, ... )
	for instance,_ in pairs( registered_instances ) do
		local ret = {instance:runScriptHookForResult( hookname, ... )}
		
		local ok = table.remove( ret, 1 )
		if not ok then
			instance:Error( "Hook '" .. hookname .. "' errored with " .. ret[1], ret[2] )
		elseif customfunc then
			local a,b,c,d,e,f,g,h = customfunc( instance, ret )
			if a ~= nil then
				return a,b,c,d,e,f,g,h
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
