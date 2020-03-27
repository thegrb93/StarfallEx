-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check
local haspermission = SF.Permissions.hasAccess

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
	add("PlayerSay", nil, nil, returnOnlyOnYourself, true)
	add("PlayerSpray")
	add("PlayerUse")
	add("PlayerSwitchFlashlight")
	add("PlayerCanPickupWeapon", nil, nil, returnOnlyOnYourselfFalse)

	add("EntityTakeDamage", nil, function(instance, target, dmg)
		return true, { instance.WrapObject(target), instance.WrapObject(dmg:GetAttacker()),
			instance.WrapObject(dmg:GetInflictor()),
			dmg:GetDamage(),
			dmg:GetDamageType(),
			instance.Types.Vector.Wrap(dmg:GetDamagePosition()),
			instance.Types.Vector.Wrap(dmg:GetDamageForce()) }
	end)

else
	-- Client hooks
	add("StartChat")
	add("FinishChat")
	add("OnPlayerChat", "playerchat")
	add("ChatTextChanged", nil, function(instance, txt)
		if haspermission(instance, nil, "input") then
			return true, { txt }
		end
		return false
	end)
	add("NetworkEntityCreated")
	add("NotifyShouldTransmit")
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
		instance:runScriptHook("onentitycreated", instance.WrapObject(ent))
	end)
	return false
end)
add("EntityRemoved")
add("PropBreak")
add("EntityFireBullets", nil, function(instance, ent, data)
	return true, { instance.WrapObject(ent), SF.StructWrapper(instance, data) }
end)

-- Other
add("EndEntityDriving")
add("StartEntityDriving")
add("Tick")


--- Deals with hooks
-- @name hook
-- @class library
-- @libtbl hook_library
SF.RegisterLibrary("hook")


return function(instance)

local getent
instance:AddHook("initialize", function()
	getent = instance.Types.Entity.GetEntity
end)

instance:AddHook("deinitialize", function()
	SF.HookDestroyInstance(instance)
end)

local hook_library = instance.Libraries.hook
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local pwrap = instance.Types.Player.Wrap

--- Sets a hook function
-- @param hookname Name of the event
-- @param name Unique identifier
-- @param func Function to run
function hook_library.add(hookname, name, func)
	checkluatype (hookname, TYPE_STRING)
	checkluatype (name, TYPE_STRING)
	checkluatype (func, TYPE_FUNCTION)

	hookname = string.lower(hookname)
	local hooks = instance.hooks[hookname]
	if not hooks then
		hooks = SF.HookTable()
		instance.hooks[hookname] = hooks
	end
	hooks:add(name, func)

	SF.HookAddInstance(instance, hookname)
end

--- Run a hook
-- @shared
-- @param hookname The hook name
-- @param ... arguments
function hook_library.run(hookname, ...)
	checkluatype (hookname, TYPE_STRING)

	hookname = string.lower(hookname)
	local hooks = instance.hooks[hookname]
	if hooks then
		local tbl
		for name, func in hooks:pairs() do
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

local hookrun = hook_library.run

--- Run a hook remotely.
-- This will call the hook "remote" on either a specified entity or all instances on the server/client
-- @shared
-- @param recipient Starfall entity to call the hook on. Nil to run on every starfall entity
-- @param ... Payload. These parameters will be used to call the hook functions
-- @return tbl A list of the resultset of each called hook
function hook_library.runRemote(recipient, ...)
	local recipients
	if recipient then
		local ent = getent(recipient)
		if not ent.instance then SF.Throw("Entity has no starfall instance", 2) end
		recipients = {
			[ent.instance] = true
		}
	else
		recipients = SF.allInstances
	end

	local argn = select("#", ...)
	local unsanitized = instance.Unsanitize({...})
	local results = {}
	for k, _ in pairs(recipients) do
		local result
		if k==instance then
			result = { true, hookrun("remote", ewrap(instance.data.entity), pwrap(instance.player), ...) }
		else
			result = k:runScriptHookForResult("remote", k.Types.Entity.Wrap(instance.data.entity), k.Types.Player.Wrap(instance.player), unpack(k.Sanitize(unsanitized), 1, argn))
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
function hook_library.remove(hookname, name)
	checkluatype (hookname, TYPE_STRING)
	checkluatype (name, TYPE_STRING)

	hookname = string.lower(hookname)
	local hooks = instance.hooks[hookname]
	if hooks then
		hooks:remove(name)
		if hooks:isEmpty() then
			instance.hooks[hookname] = nil
			SF.HookRemoveInstance(instance, hookname)
		end
	end
end

end

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

--- Called when a clientside entity gets created or re-created via lag/PVS
-- @name NetworkEntityCreated
-- @class hook
-- @client
-- @param ent New entity

--- Called when a clientside entity transmit state is changed. Usually when changing PVS
-- If you want clientside render changes to persist on an entity you have to re-apply them
-- each time it begins transmitting again
-- @name NotifyShouldTransmit
-- @class hook
-- @client
-- @param ent The entity
-- @param shouldtransmit Whether it is now transmitting or not

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

--- Called every time a bullet is fired from an entity
-- @name EntityFireBullets
-- @class hook
-- @shared
-- @param ent The entity that fired the bullet
-- @param data The bullet data. See http://wiki.garrysmod.com/page/Structures/Bullet

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

--- Called after the starfall chip is duplicated and the duplication is finished.
-- @name DupeFinished
-- @class hook
-- @server
-- @param entTbl A table of entities duped with the chip mapped to their previous indices.

--- Called after a client's starfall has initialized. Use this to know when it's safe to send net messages to the client.
-- @name ClientInitialized
-- @class hook
-- @server
-- @param ply The player that initialized

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
-- @param ply Player that said the message
-- @param text The message
-- @param team Whether the message was team only
-- @param isdead Whether the message was send from a dead player

--- Called when starfall chip errors
-- @name StarfallError
-- @class hook
-- @shared
-- @param ent Starfall chip that errored
-- @param ply Owner of the chip on server or player that script errored for on client
-- @param err Error message
