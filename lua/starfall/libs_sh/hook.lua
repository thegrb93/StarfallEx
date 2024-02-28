-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local haspermission = SF.Permissions.hasAccess
local registerprivilege = SF.Permissions.registerPrivilege

--Can only return if you are the first argument
local function returnOnlyOnYourself(instance, args, ply)
	if args[1] and instance.player == ply then return args[2] end
end

--Can only return false on yourself
local function returnOnlyOnYourselfFalse(instance, args, ply)
	if args[1] and instance.player == ply and args[2]==false then return false end
end

local add = SF.hookAdd

if SERVER then
	-- Server hooks

	--- Called when an entity is being picked up by a gravity gun
	-- @name GravGunOnPickedUp
	-- @class hook
	-- @server
	-- @param Player ply Player picking up an object
	-- @param Entity ent Entity being picked up
	add("GravGunOnPickedUp")

	--- Called when an entity is being dropped by a gravity gun
	-- @name GravGunOnDropped
	-- @class hook
	-- @server
	-- @param Player ply Player dropping the object
	-- @param Entity ent Entity being dropped
	add("GravGunOnDropped")

	--- Called when an entity is being picked up by +use
	-- @name OnPlayerPhysicsPickup
	-- @class hook
	-- @server
	-- @param Player ply Player picking up an object
	-- @param Entity ent Entity being picked up
	add("OnPlayerPhysicsPickup")

	--- Called when an entity is being dropped or thrown by +use
	-- @name OnPlayerPhysicsDrop
	-- @class hook
	-- @server
	-- @param Player ply Player dropping the object
	-- @param Entity ent Entity being dropped
	-- @param boolean thrown Whether the entity was thrown or dropped
	add("OnPlayerPhysicsDrop")

	--- Called when an entity is being frozen
	-- Note this is not called for players or NPCs held with the physgun (bug)
	-- @name OnPhysgunFreeze
	-- @class hook
	-- @server
	-- @param Weapon physgun The Physgun freezing the entity
	-- @param PhysObj physobj PhysObj of the entity
	-- @param Entity ent Entity being frozen
	-- @param Player ply Player freezing the entity
	add("OnPhysgunFreeze")

	--- Called when a player reloads their physgun
	-- @name OnPhysgunReload
	-- @class hook
	-- @server
	-- @param Weapon physgun The Physgun the player is reloading with
	-- @param Player ply Player reloading the physgun
	add("OnPhysgunReload")

	--- Called when a player has successfully picked up an entity with their Physics Gun.
	-- Not to be confused with PhysgunPickup which is a predicted hook
	-- @name OnPhysgunPickup
	-- @class hook
	-- @server
	-- @param Player ply The player that has picked up something using the physics gun.
	-- @param Entity ent The entity that was picked up
	add("OnPhysgunPickup")

	--- Called when a player unfreezes an object
	-- @name PlayerUnfrozeObject
	-- @class hook
	-- @server
	-- @param Player ply The player who has unfrozen an entity
	-- @param Entity ent The unfrozen entity
	-- @param PhysObj physobj The physics object of the unfrozen entity 
	add("PlayerUnfrozeObject")

	--- Called when a player dies
	-- @name PlayerDeath
	-- @class hook
	-- @server
	-- @param Player ply Player who died
	-- @param Entity inflictor Entity used to kill the player
	-- @param Entity attacker Entity that killed the player
	add("PlayerDeath")

	--- Called when a player disconnects
	-- @name PlayerDisconnected
	-- @class hook
	-- @server
	-- @param Player ply Player that disconnected
	add("PlayerDisconnected")

	--- Called when a player gets hurt, uses the player_hurt game event clientside.
	-- @name PlayerHurt
	-- @class hook
	-- @shared
	-- @param Player ply Player being hurt
	-- @param Entity attacker Entity causing damage to the player
	-- @param number newHealth New health of the player
	-- @param number damageTaken On server, Amount of damage the player has taken, nil on client.
	add("PlayerHurt")

	--- Called when a player spawns for the first time
	-- @name PlayerInitialSpawn
	-- @class hook
	-- @server
	-- @param Player ply Player who spawned
	-- @param boolean transition If true, the player just spawned from a map transition.
	add("PlayerInitialSpawn")

	--- Called when a player spawns
	-- @name PlayerSpawn
	-- @class hook
	-- @server
	-- @param Player ply Player who spawned
	add("PlayerSpawn")

	--- Called when a player has changed team using Player:SetTeam
	-- @name PlayerChangedTeam
	-- @class hook
	-- @server
	-- @param Player ply Player whose team has changed
	-- @param number oldTeam Index of the team the player was originally in. See team.getName and the team library
	-- @param number newTeam Index of the team the player has changed to.
	add("PlayerChangedTeam")

	--- Called when a players enters a vehicle
	-- @name PlayerEnteredVehicle
	-- @class hook
	-- @server
	-- @param Player ply Player who entered a vehicle
	-- @param Vehicle vehicle Vehicle that was entered
	-- @param number num Role. The seat number
	add("PlayerEnteredVehicle")

	--- Called when a players leaves a vehicle
	-- @name PlayerLeaveVehicle
	-- @class hook
	-- @server
	-- @param Player ply Player who left a vehicle
	-- @param Vehicle vehicle Vehicle that was left
	add("PlayerLeaveVehicle")


	--- Called when a player sends a chat message
	-- @name PlayerSay
	-- @class hook
	-- @server
	-- @param Player ply Player that sent the message
	-- @param string text Content of the message
	-- @param boolean teamChat True if team chat
	-- @return string? New text. "" to stop from displaying. Nil to keep original.
	add("PlayerSay", nil, nil, returnOnlyOnYourself, true)

	--- Called when a players sprays their logo
	-- @name PlayerSpray
	-- @class hook
	-- @server
	-- @param Player ply Player that sprayed
	add("PlayerSpray")

	--- Called when a player holds their use key and looks at an entity.
	-- Will continuously run.
	-- @name PlayerUse
	-- @server
	-- @class hook
	-- @param Player ply Player using the entity
	-- @param Entity ent Entity being used
	add("PlayerUse")

	--- Called when a players turns their flashlight on or off
	-- @name PlayerSwitchFlashlight
	-- @class hook
	-- @server
	-- @param Player ply Player switching flashlight
	-- @param boolean state New flashlight state. True if on.
	add("PlayerSwitchFlashlight")

	--- Called when a wants to pick up a weapon
	-- @name PlayerCanPickupWeapon
	-- @class hook
	-- @server
	-- @param Player ply Player
	-- @param Weapon wep Weapon
	add("PlayerCanPickupWeapon", nil, nil, returnOnlyOnYourselfFalse)

	-- Register privileges
	registerprivilege("entities.blockDamage", "Block Damage", "Allows the user to block incoming entity damage", { entities = {} })

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
	-- @return boolean? Return true to prevent the entity from taking damage
	add("EntityTakeDamage", nil, function(instance, target, dmg)
		return true, {
			instance.WrapObject(target),
			instance.WrapObject(dmg:GetAttacker()),
			instance.WrapObject(dmg:GetInflictor()),
			dmg:GetDamage(),
			dmg:GetDamageType(),
			instance.Types.Vector.Wrap(dmg:GetDamagePosition()),
			instance.Types.Vector.Wrap(dmg:GetDamageForce())
		}
	end, function(instance, args, target)
		if args[1] and args[2] == true and (instance.player == SF.Superuser or haspermission(instance, target, "entities.blockDamage")) then
			return true
		end
	end)

	--- Called whenever an NPC is killed.
	-- @name OnNPCKilled
	-- @class hook
	-- @server
	-- @param Npc npc NPC that was killed
	-- @param Entity attacker The NPCs attacker, the entity that gets the kill credit, for example a player or an NPC.
	-- @param Entity inflictor Entity that did the killing
	add("OnNPCKilled")

	--- Called when the Entity:getWaterLevel of an entity is changed.
	-- @name OnEntityWaterLevelChanged
	-- @class hook
	-- @server
	-- @param Entity ent The entity
	-- @param number old Previous water level
	-- @param number new New water level
	add("OnEntityWaterLevelChanged")
else
	-- Client hooks

	--- Called when the local player opens their chat window.
	-- @name StartChat
	-- @class hook
	-- @client
	-- @param boolean isTeamChat Whether they're typing in team chat
	add("StartChat")
	
	--- Called when the local player closes their chat window.
	-- @name FinishChat
	-- @class hook
	-- @client
	add("FinishChat")

	--- Called when a player's chat message is printed to the chat window
	-- @name PlayerChat
	-- @class hook
	-- @client
	-- @param Player ply Player that said the message
	-- @param string text The message
	-- @param boolean team Whether the message was team only
	-- @param boolean isdead Whether the message was send from a dead player
	add("OnPlayerChat", "playerchat")

	--- Called when the player's chat box text changes.
	-- Requires the 'input' permission.
	-- @name ChatTextChanged
	-- @class hook
	-- @client
	-- @param string txt Text it was changed to
	add("ChatTextChanged", nil, function(instance, txt)
		if instance.player == SF.Superuser or haspermission(instance, nil, "input.chat") then
			return true, { txt }
		end
		return false
	end)

	--- Called when a clientside entity gets created or re-created via lag/PVS
	-- @name NetworkEntityCreated
	-- @class hook
	-- @client
	-- @param Entity ent New entity
	add("NetworkEntityCreated")

	--- Called when a clientside entity transmit state is changed. Usually when changing PVS
	-- If you want clientside render changes to persist on an entity you have to re-apply them
	-- each time it begins transmitting again
	-- @name NotifyShouldTransmit
	-- @class hook
	-- @client
	-- @param Entity ent The entity
	-- @param boolean shouldtransmit Whether it is now transmitting or not
	add("NotifyShouldTransmit")

	-- Check serverside playerhurt for docs
	gameevent.Listen("player_hurt")
	SF.hookAdd("player_hurt", "playerhurt", function(instance, data)
		return true, {instance.WrapObject(Player(data.userid)), instance.WrapObject(Player(data.attacker)), data.health}
	end)

	--- Called when a player starts using voice chat.
	-- @name PlayerStartVoice
	-- @class hook
	-- @client
	-- @param Player ply Player who started using voice chat
	-- @return boolean? Return true to hide CHudVoiceStatus (Voice Chat HUD Element).
	add("PlayerStartVoice", nil, nil, function(instance, args, ply)
		if args[1] and args[2] == true and SF.IsHUDActive(instance.entity) then
			return true
		end
	end)

	--- Called when a player stops using voice chat.
	-- @name PlayerEndVoice
	-- @class hook
	-- @client
	-- @param Player ply Player who stopped talking
	add("PlayerEndVoice")

	--- Called when the player opens the context menu
	-- @name OnContextMenuOpen
	-- @class hook
	-- @client
	add("OnContextMenuOpen")

	--- Called when the player closes the context menu
	-- @name OnContextMenuClose
	-- @class hook
	-- @client
	add("OnContextMenuClose")
end

-- Shared hooks

-- Player hooks

--- Called when a player toggles noclip
-- @name PlayerNoClip
-- @class hook
-- @shared
-- @param Player ply Player toggling noclip
-- @param boolean newState New noclip state. True if on.
add("PlayerNoClip")

--- Called when a player presses a key
-- @name KeyPress
-- @class hook
-- @shared
-- @param Player ply Player pressing the key
-- @param number key The key being pressed
add("KeyPress")

--- Called when a player releases a key
-- @name KeyRelease
-- @class hook
-- @shared
-- @param Player ply Player releasing the key
-- @param number key The key being released
add("KeyRelease")

--- Called when a player punts with the gravity gun
-- @name GravGunPunt
-- @class hook
-- @shared
-- @param Player ply Player punting the gravgun
-- @param Entity ent Entity being punted
add("GravGunPunt")

--- Called when an entity gets picked up by a physgun
-- This hook is predicted.
-- @name PhysgunPickup
-- @class hook
-- @shared
-- @param Player ply Player picking up the entity
-- @param Entity ent Entity being picked up
add("PhysgunPickup")

--- Called when an entity being held by a physgun gets dropped
-- @name PhysgunDrop
-- @class hook
-- @shared
-- @param Player ply Player dropping the entity
-- @param Entity ent Entity being dropped
add("PhysgunDrop")

--- Called when a player switches their weapon
-- @name PlayerSwitchWeapon
-- @class hook
-- @shared
-- @param Player ply Player changing weapon
-- @param Weapon oldwep Old weapon
-- @param Weapon newweapon New weapon
add("PlayerSwitchWeapon", nil, nil, returnOnlyOnYourselfFalse)

--- Called when a player's reserve ammo count changes.
-- @name PlayerAmmoChanged
-- @class hook
-- @shared
-- @param Player ply The player whose ammo is being affected.
-- @param number ammoID The ammo type ID
-- @param number oldcount Previous ammo count
-- @param number newcount The new ammo count
add("PlayerAmmoChanged")

--- Called when a player animation event occurs
-- @name DoAnimationEvent
-- @class hook
-- @shared
-- @param Player ply The player being animated
-- @param number event The event id
-- @param number data The event data
add("DoAnimationEvent")

-- Entity hooks

--- Called when an entity gets created
-- @name OnEntityCreated
-- @class hook
-- @shared
-- @param Entity ent New entity
add("OnEntityCreated", nil, function(instance, ent)
	timer.Simple(0, function()
		instance:runScriptHook("onentitycreated", instance.WrapObject(ent))
	end)
	return false
end)

--- Called when an entity is removed
-- @name EntityRemoved
-- @class hook
-- @shared
-- @param Entity ent Entity being removed
add("EntityRemoved")

--- Called when an entity is broken
-- @name PropBreak
-- @class hook
-- @shared
-- @param Player ply Player who broke it
-- @param Entity ent Entity broken
add("PropBreak")

--- Called every time a bullet is fired from an entity
-- @name EntityFireBullets
-- @class hook
-- @shared
-- @param Entity ent The entity that fired the bullet
-- @param table data The bullet data. See http://wiki.facepunch.com/gmod/Structures/Bullet
-- @return function? Optional callback to called as if it were the Bullet structure's Callback. Called before the bullet deals damage with attacker, traceResult.
add("EntityFireBullets", nil, function(instance, ent, data)
	return true, { instance.WrapObject(ent), SF.StructWrapper(instance, data, "Bullet") }
end, function(instance, ret, ent, data)
	if ret[1] and isfunction(ret[2]) then
		data.Callback = function(attacker, tr, dmginfo)
			instance:runFunction(ret[2], instance.WrapObject(attacker), SF.StructWrapper(instance, tr, "TraceResult"))
		end
		return true
	end
end, true)

--- Called after a bullet is fired and it's trace has been calculated
-- @name PostEntityFireBullets
-- @class hook
-- @shared
-- @param Entity ent The entity that fired the bullet
-- @param table data A table containing Trace (See http://wiki.facepunch.com/gmod/Structures/TraceResult) and AmmoType, Tracer, Damage, Force, Attacker, TracerName (see http://wiki.facepunch.com/gmod/Structures/Bullet)
add("PostEntityFireBullets", nil, function(instance, ent, data)
	local ret = SF.StructWrapper(instance, data, "Bullet")
	ret.Trace = SF.StructWrapper(instance, data.Trace, "TraceResult")
	return true, {instance.WrapObject(ent), ret}
end)

--- Called whenever a sound has been played. This will not be called clientside if the server played the sound without the client also calling Entity:EmitSound.
-- @name EntityEmitSound
-- @class hook
-- @shared
-- @param table data Information about the played sound. Changes done to this table can be applied by returning true from this hook. See https://wiki.facepunch.com/gmod/Structures/EmitSoundInfo.
-- @return boolean? Return false to prevent the sound from playing or nothing to play the sound without altering it.
add("EntityEmitSound", nil, function(instance, data)
	return true, {SF.StructWrapper(instance, data, "EmitSoundInfo")}
end, function(instance, ret, data)
	if ret[1] and ret[2]==false and (instance.player == SF.Superuser or haspermission(instance, data.Entity, "entities.emitSound")) then
		return ret[2]
	end
end)

-- Other

--- Called when a player stops driving an entity
-- @name EndEntityDriving
-- @class hook
-- @shared
-- @param Entity ent Entity that had been driven
-- @param Player ply Player that drove the entity
add("EndEntityDriving")

--- Called when a player starts driving an entity
-- @name StartEntityDriving
-- @class hook
-- @shared
-- @param Entity ent Entity being driven
-- @param Player ply Player that is driving the entity
add("StartEntityDriving")

--- Tick hook. Called each game tick on both the server and client.
-- @name tick
-- @class hook
-- @shared
add("Tick")

-- Game Events

--- Called when a player changes their Steam name. (Game Event)
-- @name PlayerChangename
-- @class hook
-- @shared
-- @param Player player Player entity of the player.
-- @param string oldname Name before change.
-- @param string newname Name after change.
gameevent.Listen("player_changename")
add("player_changename", "playerchangename", function(instance, data)
	return true, {instance.WrapObject(Player(data.userid)), data.oldname, data.newname}
end)

--- Called when a player connects to the server. (Game Event)
-- @name PlayerConnect
-- @class hook
-- @shared
-- @param string networkid The SteamID the player had. Will be "BOT" for bots and "STEAM_0:0:0" in single-player.
-- @param string name The name the player had.
-- @param number userid The UserID the player has.
-- @param boolean isbot False if the player isn't a bot, true if they are.
gameevent.Listen("player_connect")
add("player_connect", "playerconnect", function(instance, data)
	return true, {data.networkid, data.name, data.userid, data.bot == 1}
end)

--- Called when a player disconnects from the server. (Game Event)
-- @name PlayerDisconnect
-- @class hook
-- @shared
-- @param string networkid The SteamID the player had. Will be "BOT" for bots and "STEAM_0:0:0" in single-player.
-- @param string name The name the player had.
-- @param Player player Player entity the player had.
-- @param string reason Reason for disconnecting.
-- @param boolean isbot False if the player isn't a bot, true if they are.
gameevent.Listen("player_disconnect")
add("player_disconnect", "playerdisconnect", function(instance, data)
	return true, {data.networkid, data.name, instance.WrapObject(Player(data.userid)), data.reason, data.bot == 1}
end)

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
-- @param ... payload Parameters that will be passed when calling hook functions
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
			results[#results + 1] = instance.Sanitize(k.Unsanitize({unpack(result, 2)}))
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

-- Hooks below are not simple gmod hooks and are called by other events in other files.

--- Think hook. Called each frame on the client and each game tick on the server.
-- @name think
-- @class hook
-- @shared

--- Called when the starfall chip is removed
-- @name Removed
-- @class hook
-- @shared

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

--- Called when the player disconnects from a HUD component linked to the Starfall Chip
-- @name huddisconnected
-- @class hook
-- @shared
-- @param Entity ent The hud component entity
-- @param Player ply The player who disconnected

--- Called when the player connects to a HUD component linked to the Starfall Chip
-- @name hudconnected
-- @class hook
-- @shared
-- @param Entity ent The hud component entity
-- @param Player ply The player who connected

--- Called when a player uses the screen
-- @name starfallUsed
-- @class hook
-- @param Player activator Player who used the screen or chip
-- @param Entity used The screen or chip entity that was used

--- Called when a frame is requested to be drawn on screen. (2D/3D Context)
-- @name render
-- @class hook
-- @client

