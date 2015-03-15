-------------------------------------------------------------------------------
-- Hook library
-------------------------------------------------------------------------------

--- Deals with hooks
-- @shared
local hook_library, _ = SF.Libraries.Register("hook")
local registered_instances = {}

--- Sets a hook function
-- @param hookname Name of the event
-- @param name Unique identifier
-- @param func Function to run
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

--- Remote hook.
-- This hook can be called from other instances
-- @name remote
-- @class hook
-- @shared
-- @param sender The entity that caused the hook to run
-- @param owner The owner of the sender
-- @param ... The payload that was supplied when calling the hook

--- Run a hook remotely.
-- This will call the hook "remote" on either a specified entity or all instances on the server/client
-- @shared
-- @param recipient Starfall entity to call the hook on. Nil to run on every starfall entity
-- @param ... Payload. These parameters will be used to call the hook functions
-- @return tbl A list of the resultset of each called hook
function hook_library.runRemote ( recipient, ... )
	if recipient then SF.CheckType( recipient, SF.Entities.Metatable ) end

	local recipients
	if recipient then
		local ent = SF.Entities.Unwrap( recipient )
		if not ent.instance then SF.throw( "Entity has no starfall instance", 2 ) end
		recipients = {
			[ ent.instance ] = true
		}
	else
		recipients = registered_instances
	end

	local instance = SF.instance

	for k, _ in pairs( recipients ) do
		SF.instance = nil
		local result = { k:runScriptHookForResult( "remote", instance.data.entity, instance.player, ... ) }

		local ok = table.remove( result, 1 )
		if not ok then
			if not result[1] then return end -- Call failed because of non-existent hook. Ignore
			k:Error( "Hook 'remote' errored with " .. result[1], result[2] )
			-- Their fault - don't return
		end
	end

	SF.instance = instance
	return result
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
	local result = {}
	for instance,_ in pairs( registered_instances ) do
		local ret = { instance:runScriptHookForResult( hookname, wrapArguments( ... ) ) }
		
		local ok = table.remove( ret, 1 )
		if ok then
			if customfunc then
				local sane = customfunc( instance, ret, ... )
				result = sane ~= nil and { sane } or result
			end
		else
			instance:Error( "Hook '" .. hookname .. "' errored with " .. ret[1], ret[2] )
		end
	end
	return unpack( result )
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
		return run( lower, customfunc, ... )
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
	add( "PlayerSay", function( instance, args, ply )
		if instance.player ~= ply then return end
		if args then return args[1] end
	end )
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

--- Called when an entity is being picked up by a gravity gun
-- @name GravGunOnPickedUp
-- @class hook
-- @server
-- @param ply Player picking up an object
-- @param ent Entity being picked up

--- Called when an entity is being dropped by a gravity gun
-- @name GravGunOnDropped
-- @class hook
-- @server
-- @param ply Player dropping the object
-- @param ent Entity being dropped

--- Called when an entity is being frozen
-- @name OnPhysgunFreeze
-- @class hook
-- @server
-- @param physgun Entity of the physgun
-- @param physobj PhysObj of the entity
-- @param ent Entity being frozen
-- @param ply Player freezing the entity

--- Called when a player reloads his physgun
-- @name OnPhysgunReload
-- @class hook
-- @server
-- @param physgun Entity of the physgun
-- @param ply Player reloading the physgun

--- Called when a player dies
-- @name PlayerDeath
-- @class hook
-- @server
-- @param ply Player who died
-- @param inflictor Entity used to kill the player
-- @param attacker Entity that killed the player

--- Called when a player disconnects
-- @name PlayerDisconnected
-- @class hook
-- @server
-- @param ply Player that disconnected

--- Called when a player spawns for the first time
-- @name PlayerInitialSpawn
-- @param player Player who spawned
-- @server

--- Called when a player spawns
-- @name PlayerSpawn
-- @class hook
-- @server
-- @param player Player who spawned

--- Called when a players leaves a vehicle
-- @name PlayerLeaveVehicle
-- @class hook
-- @server
-- @param ply Player who left a vehicle
-- @param vehicle Vehicle that was left

--- Called when a player sends a chat message
-- @name PlayerSay
-- @class hook
-- @server
-- @param ply Player that sent the message
-- @param text Content of the message
-- @param teamChat True if team chat
-- @return New text. "" to stop from displaying. Nil to keep original.

--- Called when a players sprays his logo
-- @name PlayerSpray
-- @class hook
-- @server
-- @param ply Player that sprayed

--- Called when a player holds their use key and looks at an entity.
-- Will continuously run.
-- @name PlayerUse
-- @server
-- @class hook
-- @param ply Player using the entity
-- @param ent Entity being used

--- Called when a players turns their flashlight on or off
-- @name PlayerSwitchFlashlight
-- @class hook
-- @server
-- @param ply Player switching flashlight
-- @param state New flashlight state. True if on.

--- Called when a player gets hurt
-- @name PlayerHurt
-- @class hook
-- @shared
-- @param ply Player being hurt
-- @param attacker Entity causing damage to the player
-- @param newHealth New health of the player
-- @param damageTaken Amount of damage the player has taken

--- Called when a player toggles noclip
-- @name PlayerNoClip
-- @class hook
-- @shared
-- @param ply Player toggling noclip
-- @param newState New noclip state. True if on.

--- Called when a player presses a key
-- @name KeyPress
-- @class hook
-- @shared
-- @param ply Player pressing the key
-- @param key The key being pressed

--- Called when a player releases a key
-- @name KeyRelease
-- @class hook
-- @shared
-- @param ply Player releasing the key
-- @param key The key being released

--- Called when a player punts with the gravity gun
-- @name GravGunPunt
-- @class hook
-- @shared
-- @param ply Player punting the gravgun
-- @param ent Entity being punted

--- Called when an entity gets picked up by a physgun
-- @name PhysgunPickup
-- @class hook
-- @shared
-- @param ply Player picking up the entity
-- @param ent Entity being picked up

--- Called when an entity being held by a physgun gets dropped
-- @name PhysgunDrop
-- @class hook
-- @shared
-- @param ply Player droppig the entity
-- @param ent Entity being dropped

--- Called when an entity gets created
-- @name OnEntityCreated
-- @class hook
-- @shared
-- @param ent New entity

--- Called when an entity is removed
-- @name EntityRemoved
-- @class hook
-- @shared
-- @param ent Entity being removed

--- Called when a player stops driving an entity
-- @name EndEntityDriving
-- @class hook
-- @shared
-- @param ent Entity that had been driven
-- @param ply Player that drove the entity

--- Called when a player starts driving an entity
-- @name StartEntityDriving
-- @class hook
-- @shared
-- @param ent Entity being driven
-- @param Player that is driving the entity

--- Called when the starfall chip is removed
-- @name Removed
-- @class hook
-- @server
