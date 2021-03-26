-- Global to all starfalls
local checkluatype = SF.CheckLuaType
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
	add("OnPlayerPhysicsPickup")
	add("OnPlayerPhysicsDrop")
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
		if instance.player == SF.Superuser or haspermission(instance, nil, "input") then
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
	return true, { instance.WrapObject(ent), SF.StructWrapper(instance, data, "Bullet") }
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
-- @param string hookname Name of the event
-- @param string name Unique identifier
-- @param function func Function to run
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

--- Run a hook and return the result
-- @shared
-- @param string hookname The hook name
-- @param ... arguments Arguments to pass to the hook
-- @return ... returns Return result(s) of the hook ran
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
-- @param Entity sender The entity that caused the hook to run
-- @param Player owner The owner of the sender
-- @param ... payload The payload that was supplied when calling the hook

local hookrun = hook_library.run

--- Run a hook remotely.
-- This will call the hook "remote" on either a specified entity or all instances on the server/client
-- @shared
-- @param Entity? recipient Starfall entity to call the hook on. Nil to run on every starfall entity
-- @param ... payload Payload. These parameters will be used to call the hook functions
-- @return table A list of the resultset of each called hook
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
			result = { true, hookrun("remote", ewrap(instance.entity), pwrap(instance.player), ...) }
		else
			result = k:runScriptHookForResult("remote", k.Types.Entity.Wrap(instance.entity), k.Types.Player.Wrap(instance.player), unpack(k.Sanitize(unsanitized), 1, argn))
		end

		if result[1] and result[2]~=nil then
			results[#results + 1] = { unpack(result, 2) }
		end

	end
	return results
end

--- Remove a hook
-- @shared
-- @param string hookname The hook name
-- @param string name The unique name for this hook
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
-- @param Player ply Player picking up an object
-- @param Entity ent Entity being picked up

--- Called when an entity is being dropped by a gravity gun
-- @name GravGunOnDropped
-- @class hook
-- @server
-- @param Player ply Player dropping the object
-- @param Entity ent Entity being dropped

--- Called when an entity is being picked up by +use
-- @name OnPlayerPhysicsPickup
-- @class hook
-- @server
-- @param Player ply Player picking up an object
-- @param Entity ent Entity being picked up

--- Called when an entity is being dropped or thrown by +use
-- @name OnPlayerPhysicsDrop
-- @class hook
-- @server
-- @param Player ply Player dropping the object
-- @param Entity ent Entity being dropped
-- @param boolean thrown Whether the entity was thrown or dropped

--- Called when an entity is being frozen
-- @name OnPhysgunFreeze
-- @class hook
-- @server
-- @param Entity physgun Entity of the physgun
-- @param PhysObj physobj PhysObj of the entity
-- @param Entity ent Entity being frozen
-- @param Player ply Player freezing the entity

--- Called when a player reloads his physgun
-- @name OnPhysgunReload
-- @class hook
-- @server
-- @param Entity physgun Entity of the physgun
-- @param Player ply Player reloading the physgun

--- Called when a player dies
-- @name PlayerDeath
-- @class hook
-- @server
-- @param Player ply Player who died
-- @param Entity inflictor Entity used to kill the player
-- @param Entity attacker Entity that killed the player

--- Called when a player disconnects
-- @name PlayerDisconnected
-- @class hook
-- @server
-- @param Player ply Player that disconnected

--- Called when a player spawns for the first time
-- @name PlayerInitialSpawn
-- @class hook
-- @server
-- @param Player ply Player who spawned

--- Called when a player spawns
-- @name PlayerSpawn
-- @class hook
-- @server
-- @param Player ply Player who spawned

--- Called when a players enters a vehicle
-- @name PlayerEnteredVehicle
-- @class hook
-- @server
-- @param Player ply Player who entered a vehicle
-- @param Vehicle vehicle Vehicle that was entered
-- @param number num Role. The seat number

--- Called when a players leaves a vehicle
-- @name PlayerLeaveVehicle
-- @class hook
-- @server
-- @param Player ply Player who left a vehicle
-- @param Vehicle vehicle Vehicle that was left

--- Called when a player sends a chat message
-- @name PlayerSay
-- @class hook
-- @server
-- @param Player ply Player that sent the message
-- @param string text Content of the message
-- @param boolean teamChat True if team chat
-- @return string? New text. "" to stop from displaying. Nil to keep original.

--- Called when a players sprays his logo
-- @name PlayerSpray
-- @class hook
-- @server
-- @param Player ply Player that sprayed

--- Called when a player holds their use key and looks at an entity.
-- Will continuously run.
-- @name PlayerUse
-- @server
-- @class hook
-- @param Player ply Player using the entity
-- @param Entity ent Entity being used

--- Called when a players turns their flashlight on or off
-- @name PlayerSwitchFlashlight
-- @class hook
-- @server
-- @param Player ply Player switching flashlight
-- @param boolean state New flashlight state. True if on.

--- Called when a wants to pick up a weapon
-- @name PlayerCanPickupWeapon
-- @class hook
-- @server
-- @param Player ply Player
-- @param Weapon wep Weapon

--- Called when a player gets hurt
-- @name PlayerHurt
-- @class hook
-- @shared
-- @param Player ply Player being hurt
-- @param Entity attacker Entity causing damage to the player
-- @param number newHealth New health of the player
-- @param number damageTaken Amount of damage the player has taken

--- Called when a player toggles noclip
-- @name PlayerNoClip
-- @class hook
-- @shared
-- @param Player ply Player toggling noclip
-- @param boolean newState New noclip state. True if on.

--- Called when a player presses a key
-- @name KeyPress
-- @class hook
-- @shared
-- @param Player ply Player pressing the key
-- @param number key The key being pressed

--- Called when a player releases a key
-- @name KeyRelease
-- @class hook
-- @shared
-- @param Player ply Player releasing the key
-- @param number key The key being released

--- Called when a player punts with the gravity gun
-- @name GravGunPunt
-- @class hook
-- @shared
-- @param Player ply Player punting the gravgun
-- @param Entity ent Entity being punted

--- Called when an entity gets picked up by a physgun
-- @name PhysgunPickup
-- @class hook
-- @shared
-- @param Player ply Player picking up the entity
-- @param Entity ent Entity being picked up

--- Called when an entity being held by a physgun gets dropped
-- @name PhysgunDrop
-- @class hook
-- @shared
-- @param Player ply Player dropping the entity
-- @param Entity ent Entity being dropped

--- Called when a player switches their weapon
-- @name PlayerSwitchWeapon
-- @class hook
-- @shared
-- @param Player ply Player changing weapon
-- @param Weapon oldwep Old weapon
-- @param Weapon newweapon New weapon

--- Called when an entity gets created
-- @name OnEntityCreated
-- @class hook
-- @shared
-- @param Entity ent New entity

--- Called when a clientside entity gets created or re-created via lag/PVS
-- @name NetworkEntityCreated
-- @class hook
-- @client
-- @param Entity ent New entity

--- Called when a clientside entity transmit state is changed. Usually when changing PVS
-- If you want clientside render changes to persist on an entity you have to re-apply them
-- each time it begins transmitting again
-- @name NotifyShouldTransmit
-- @class hook
-- @client
-- @param Entity ent The entity
-- @param boolean shouldtransmit Whether it is now transmitting or not

--- Called when an entity is removed
-- @name EntityRemoved
-- @class hook
-- @shared
-- @param Entity ent Entity being removed

--- Called when an entity is broken
-- @name PropBreak
-- @class hook
-- @shared
-- @param Player ply Player who broke it
-- @param Entity ent Entity broken

--- Called every time a bullet is fired from an entity
-- @name EntityFireBullets
-- @class hook
-- @shared
-- @param Entity ent The entity that fired the bullet
-- @param table data The bullet data. See http://wiki.facepunch.com/gmod/Structures/Bullet

--- Called when an entity is damaged
-- @name EntityTakeDamage
-- @class hook
-- @server
-- @param Entity target Entity that is hurt
-- @param Entity attacker Entity that attacked
-- @param Entity inflictor Entity that inflicted the damage
-- @param number amount How much damage
-- @param number type Type of the damage
-- @param Vector position Position of the damage
-- @param Vector force Force of the damage

--- Called when a player stops driving an entity
-- @name EndEntityDriving
-- @class hook
-- @shared
-- @param Entity ent Entity that had been driven
-- @param Player ply Player that drove the entity

--- Called when a player starts driving an entity
-- @name StartEntityDriving
-- @class hook
-- @shared
-- @param Entity ent Entity being driven
-- @param Player ply Player that is driving the entity

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
-- @param table entTbl A table of entities duped with the chip mapped to their previous indices.

--- Called after a client's starfall has initialized. Use this to know when it's safe to send net messages to the client.
-- @name ClientInitialized
-- @class hook
-- @server
-- @param Player ply The player that initialized

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
-- @param Player ply Player that said the message
-- @param string text The message
-- @param boolean team Whether the message was team only
-- @param boolean isdead Whether the message was send from a dead player

--- Called when starfall chip errors
-- @name StarfallError
-- @class hook
-- @shared
-- @param Entity ent Starfall chip that errored
-- @param Player ply Owner of the chip on server or player that script errored for on client
-- @param string err Error message

--- Called when a component is linked to the starfall
-- @name ComponentLinked
-- @class hook
-- @shared
-- @param Entity ent The component entity

--- Called when a component is unlinked to the starfall
-- @name ComponentUnlinked
-- @class hook
-- @shared
-- @param Entity ent The component entity
