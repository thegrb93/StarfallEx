-------------------------------------------------------------------------------
-- Hook library
-------------------------------------------------------------------------------

--- Deals with hooks
-- @shared
local hook_library = SF.Libraries.Register("hook")
local registered_instances = {}
local gmod_hooks = {}
local wrapArguments = SF.Sanitize

--- Sets a hook function
-- @param hookname Name of the event
-- @param name Unique identifier
-- @param func Function to run
function hook_library.add (hookname, name, func)
	SF.CheckLuaType(hookname, TYPE_STRING)
	SF.CheckLuaType(name, TYPE_STRING)
	SF.CheckLuaType(func, TYPE_FUNCTION)

	hookname = hookname:lower()
	local inst = SF.instance
	local hooks = inst.hooks[hookname]
	if not hooks then
		hooks = {}
		inst.hooks[hookname] = hooks
	end
	hooks[name] = func

	local instances = registered_instances[hookname]
	if not instances then
		instances = {}
		registered_instances[hookname] = instances
	
		local gmod_hook = gmod_hooks[hookname]
		if gmod_hook then
			local realname, customargfunc, customretfunc = unpack(gmod_hook)
			--- There are 4 varients of hookfunc depending on if there are custom callbacks
			local hookfunc
			if customargfunc then
				if customretfunc then
					hookfunc = function(...)
						local result
						for instance, _ in pairs(instances) do
							local canrun, customargs = customargfunc(instance, ...)
							if canrun then
								local tbl = instance:runScriptHookForResult(hookname, wrapArguments(unpack(customargs)))
								if tbl[1] then
									local sane = customretfunc(instance, tbl, ...)
									if sane ~= nil then result = sane end
								end
							end
						end
						return result
					end
				else
					hookfunc = function(...)
						for instance, _ in pairs(instances) do
							local canrun, customargs = customargfunc(instance, ...)
							if canrun then
								instance:runScriptHook(hookname, wrapArguments(unpack(customargs)))
							end
						end
					end
				end
			else
				if customretfunc then
					hookfunc = function(...)
						local result
						for instance, _ in pairs(instances) do
							local tbl = instance:runScriptHookForResult(hookname, wrapArguments(...))
							if tbl[1] then
								local sane = customretfunc(instance, tbl, ...)
								if sane ~= nil then result = sane end
							end
						end
						return result
					end
				else
					hookfunc = function(...)
						for instance, _ in pairs(instances) do
							instance:runScriptHook(hookname, wrapArguments(...))
						end
					end
				end
			end
			hook.Add(realname, "SF_Hook_"..realname, hookfunc)
		end
	end
	instances[inst] = true
end

--- Run a hook
-- @shared
-- @param hookname The hook name
-- @param ... arguments
function hook_library.run (hookname, ...)
	SF.CheckLuaType(hookname, TYPE_STRING)

	local instance = SF.instance
	local hook = hookname:lower()

	if instance.hooks and instance.hooks[hook] then
		local tbl
		for name, func in pairs(instance.hooks[hook]) do
			tbl = { func(...) }
			if tbl[1]~=nil then
				return unpack(tbl)
			end
		end
	end
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
function hook_library.runRemote (recipient, ...)
	if recipient then SF.CheckType(recipient, SF.Entities.Metatable) end

	local recipients
	if recipient then
		local ent = SF.Entities.Unwrap(recipient)
		if not ent.instance then SF.Throw("Entity has no starfall instance", 2) end
		recipients = {
			[ent.instance] = true
		}
	else
		recipients = registered_instances["remote"] or {}
	end

	local instance = SF.instance

	local results = {}
	for k, _ in pairs(recipients) do
		local result
		if k==instance then
			result = { true, hook_library.run("remote", SF.WrapObject(instance.data.entity), SF.WrapObject(instance.player), ...) }
		else
			result = k:runScriptHookForResult("remote", SF.WrapObject(instance.data.entity), SF.WrapObject(instance.player), ...)
		end
		
		if result[1] and result[2]~=nil then
			results[#results + 1] = { unpack(result, 2) }
		end

	end
	return results
end

--- Remove a hook
-- @shared
-- @param hookname The hook name
-- @param name The unique name for this hook
function hook_library.remove (hookname, name)
	SF.CheckLuaType(hookname, TYPE_STRING)
	SF.CheckLuaType(name, TYPE_STRING)
	local instance = SF.instance

	local lower = hookname:lower()
	if instance.hooks[lower] then
		instance.hooks[lower][name] = nil

		if not next(instance.hooks[lower]) then
			instance.hooks[lower] = nil
			registered_instances[lower][instance] = nil
			if not next(registered_instances[lower]) then
				registered_instances[lower] = nil
				if gmod_hooks[lower] then
					hook.Remove(gmod_hooks[lower][1], "SF_Hook_" .. gmod_hooks[lower][1])
				end
			end
		end
	end
end

SF.Libraries.AddHook("deinitialize", function (instance)
	for k, v in pairs(registered_instances) do
		v[instance] = nil
		if not next(v) then
			registered_instances[k] = nil
			if gmod_hooks[k] then
				hook.Remove(gmod_hooks[k][1], "SF_Hook_" .. gmod_hooks[k][1])
			end
		end
	end
end)

--- Add a GMod hook so that SF gets access to it
-- @shared
-- @param hookname The hook name. In-SF hookname will be lowercased
-- @param customargfunc Optional custom function
-- Returns true if the hook should be called, then extra arguements to be passed to the starfall hooks
-- @param customretfunc Optional custom function
-- Takes values returned from starfall hook and returns what should be passed to the gmod hook
function SF.hookAdd (hookname, customhookname, customargfunc, customretfunc)
	gmod_hooks[customhookname or hookname:lower()] = { hookname, customargfunc, customretfunc }
end

--Can only return if you are the first argument
local function returnOnlyOnYourself(instance, args, ply)
	if instance.player ~= ply then return end
	return args[2]
end

--Can only return false on yourself
local function returnOnlyOnYourselfFalse(instance, args, ply)
	if instance.player ~= ply then return end
	if args[2]==false then return false end
end

local add = SF.hookAdd

if SERVER then
	-- Server hooks
	add("GravGunOnPickedUp")
	add("GravGunOnDropped")
	add("OnPhysgunFreeze")
	add("OnPhysgunReload")
	add("PlayerDeath")
	add("PlayerDisconnected")
	add("PlayerInitialSpawn")
	add("PlayerSpawn")
	add("PlayerEnteredVehicle")
	add("PlayerLeaveVehicle")
	add("PlayerSay", nil, nil, returnOnlyOnYourself)
	add("PlayerSpray")
	add("PlayerUse")
	add("PlayerSwitchFlashlight")
	add("PlayerCanPickupWeapon", nil, nil, returnOnlyOnYourselfFalse)

	add("EntityTakeDamage", nil, function(instance, target, dmg)
		return true, { target, dmg:GetAttacker(),
			dmg:GetInflictor(),
			dmg:GetDamage(),
			dmg:GetDamageType(),
			dmg:GetDamagePosition(),
			dmg:GetDamageForce() }
	end)

else
	-- Client hooks
	add("StartChat")
	add("FinishChat")
	add("OnPlayerChat", "playerchat")
	add("PostDrawHUD", "renderoffscreen", function(instance)
		return SF.Permissions.hasAccess(instance.player, nil, "render.offscreen"), {}
	end)
end

-- Shared hooks

-- Player hooks
add("PlayerHurt")
add("PlayerNoClip")
add("KeyPress")
add("KeyRelease")
add("GravGunPunt")
add("PhysgunPickup")
add("PhysgunDrop")
add("PlayerSwitchWeapon", nil, nil, returnOnlyOnYourselfFalse)

-- Entity hooks
add("OnEntityCreated", nil, function(instance, ent)
	timer.Simple(0, function()
		instance:runScriptHook("onentitycreated", SF.WrapObject(ent))
	end)
	return false
end)
add("EntityRemoved")
add("PropBreak")

-- Other
add("EndEntityDriving")
add("StartEntityDriving")
add("Tick")

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
-- @class hook
-- @server
-- @param ply Player who spawned

--- Called when a player spawns
-- @name PlayerSpawn
-- @class hook
-- @server
-- @param ply Player who spawned

--- Called when a players enters a vehicle
-- @name PlayerEnteredVehicle
-- @class hook
-- @server
-- @param ply Player who entered a vehicle
-- @param vehicle Vehicle that was entered
-- @param num Role

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

--- Called when a wants to pick up a weapon
-- @name PlayerCanPickupWeapon
-- @class hook
-- @server
-- @param ply Player
-- @param wep Weapon

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

--- Called when a player switches their weapon
-- @name PlayerSwitchWeapon
-- @class hook
-- @shared
-- @param ply Player droppig the entity
-- @param oldwep Old weapon
-- @param newweapon New weapon

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

--- Called when an entity is broken
-- @name PropBreak
-- @class hook
-- @shared
-- @param ply Player who broke it
-- @param ent Entity broken

--- Called when an entity is damaged
-- @name EntityTakeDamage
-- @class hook
-- @server
-- @param target Entity that is hurt
-- @param attacker Entity that attacked
-- @param inflictor Entity that inflicted the damage
-- @param amount How much damage
-- @param type Type of the damage
-- @param position Position of the damage
-- @param force Force of the damage

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
-- @param ply Player that is driving the entity

--- Think hook. Called each frame on the client and each game tick on the server.
-- @name think
-- @class hook
-- @shared

--- Tick hook. Called each game tick on both the server and client.
-- @name tick
-- @class hook
-- @shared

--- Called when the starfall chip is removed
-- @name Removed
-- @class hook
-- @server

--- Called after the starfall chip is placed/reloaded with the toolgun or duplicated and the duplication is finished.
-- @name Initialize
-- @class hook
-- @server

--- Called when the local player opens their chat window.
-- @name StartChat
-- @class hook
-- @client

--- Called when the local player closes their chat window.
-- @name FinishChat
-- @class hook
-- @client

--- Called when a player's chat message is printed to the chat window
-- @name PlayerChat
-- @class hook
-- @client
