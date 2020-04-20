-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check
local registerprivilege = SF.Permissions.registerPrivilege

if SERVER then
	-- Register privileges
	registerprivilege("player.dropweapon", "DropWeapon", "Drops a weapon from the player", { entities = {} })
end

--- Player type
-- @name Player
-- @class type
-- @libtbl player_methods
SF.RegisterType("Player", false, true, debug.getregistry().Player, "Entity")


return function(instance)


local getent
instance:AddHook("initialize", function()
	getent = instance.Types.Entity.GetEntity
end)

if SERVER then
	instance:AddHook("deinitialize", function()
		for k, pl in pairs(player.GetAll()) do
			if pl.sfhudenabled and pl.sfhudenabled.link == instance.data.entity then
				pl:SetViewEntity()
			end
		end
	end)
end


local player_methods, player_meta, wrap, unwrap = instance.Types.Player.Methods, instance.Types.Player, instance.Types.Player.Wrap, instance.Types.Player.Unwrap
local owrap, ounwrap = instance.WrapObject, instance.UnwrapObject
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local wep_meta, wwrap, wunwrap = instance.Types.Weapon, instance.Types.Weapon.Wrap, instance.Types.Weapon.Unwrap
local veh_meta, vhwrap, vhunwrap = instance.Types.Vehicle, instance.Types.Vehicle.Wrap, instance.Types.Vehicle.Unwrap


local function getply(self)
	local ent = unwrap(self)
	if ent:IsValid() then
		return ent
	else
		SF.Throw("Entity is not valid.", 3)
	end
end


function player_meta:__tostring()
	local ent = unwrap(self)
	if not ent:IsValid() then return "(null entity)"
	else return tostring(ent) end
end


-- ------------------------------------------------------------------------- --
--- Returns whether the player is alive
-- @shared
-- @return True if player alive
function player_methods:isAlive()
	return getply(self):Alive()
end

--- Returns the players armor
-- @shared
-- @return Armor
function player_methods:getArmor()
	return getply(self):Armor()
end

--- Returns whether the player is crouching
-- @shared
-- @return True if player crouching
function player_methods:isCrouching()
	return getply(self):Crouching()
end

--- Returns the amount of deaths of the player
-- @shared
-- @return Amount of deaths
function player_methods:getDeaths()
	return getply(self):Deaths()
end

--- Returns whether the player's flashlight is on
-- @shared
-- @return True if player has flashlight on
function player_methods:isFlashlightOn()
	return getply(self):FlashlightIsOn()
end

--- Returns true if the player is noclipped
-- @shared
-- @return true if the player is noclipped
function player_methods:isNoclipped()
	return getply(self):GetMoveType() == MOVETYPE_NOCLIP
end

--- Returns the amount of kills of the player
-- @shared
-- @return Amount of kills
function player_methods:getFrags()
	return getply(self):Frags()
end

--- Returns the name of the player's active weapon
-- @shared
-- @return The weapon
function player_methods:getActiveWeapon()
	return wwrap(getply(self):GetActiveWeapon())
end

--- Returns the player's aim vector
-- @shared
-- @return Aim vector
function player_methods:getAimVector()
	return vwrap(getply(self):GetAimVector())
end

--- Returns the player's field of view
-- @shared
-- @return Field of view
function player_methods:getFOV()
	return getply(self):GetFOV()
end

--- Returns the player's jump power
-- @shared
-- @return Jump power
function player_methods:getJumpPower()
	return getply(self):GetJumpPower()
end

--- Returns the player's maximum speed
-- @shared
-- @return Maximum speed
function player_methods:getMaxSpeed()
	return getply(self):GetMaxSpeed()
end

--- Returns the player's name
-- @shared
-- @return Name
function player_methods:getName()
	return getply(self):GetName()
end

--- Returns the player's running speed
-- @shared
-- @return Running speed
function player_methods:getRunSpeed()
	return getply(self):GetRunSpeed()
end

--- Returns the player's shoot position
-- @shared
-- @return Shoot position
function player_methods:getShootPos()
	return vwrap(getply(self):GetShootPos())
end

--- Returns whether the player is in a vehicle
-- @shared
-- @return True if player in vehicle
function player_methods:inVehicle()
	return getply(self):InVehicle()
end

--- Returns the vehicle the player is driving
-- @shared
-- @return Vehicle if player in vehicle or nil
function player_methods:getVehicle()
	return vhwrap(getply(self):GetVehicle())
end

--- Returns whether the player is an admin
-- @shared
-- @return True if player is admin
function player_methods:isAdmin()
	return getply(self):IsAdmin()
end

--- Returns whether the player is a bot
-- @shared
-- @return True if player is a bot
function player_methods:isBot()
	return getply(self):IsBot()
end

--- Returns whether the player is connected
-- @shared
-- @return True if player is connected
function player_methods:isConnected()
	return getply(self):IsConnected()
end

--- Returns whether the player is frozen
-- @shared
-- @return True if player is frozen
function player_methods:isFrozen()
	return getply(self):IsFrozen()
end

--- Returns whether the player is an NPC
-- @shared
-- @return True if player is an NPC
function player_methods:isNPC()
	return getply(self):IsNPC()
end

--- Returns whether the player is a player
-- @shared
-- @return True if player is player
function player_methods:isPlayer()
	return getply(self):IsPlayer()
end

--- Returns whether the player is a super admin
-- @shared
-- @return True if player is super admin
function player_methods:isSuperAdmin()
	return getply(self):IsSuperAdmin()
end

--- Returns whether the player belongs to a usergroup
-- @shared
-- @param group Group to check against
-- @return True if player belongs to group
function player_methods:isUserGroup(group)
	return getply(self):IsUserGroup(group)
end

--- Returns the player's current ping
-- @shared
-- @return ping
function player_methods:getPing()
	return getply(self):Ping()
end

--- Returns the player's steam ID
-- @shared
-- @return steam ID
function player_methods:getSteamID()
	return getply(self):SteamID()
end

--- Returns the player's community ID
-- @shared
-- @return community ID
function player_methods:getSteamID64()
	return getply(self):SteamID64()
end

--- Returns the player's current team
-- @shared
-- @return team
function player_methods:getTeam()
	return getply(self):Team()
end

--- Returns the name of the player's current team
-- @shared
-- @return team name
function player_methods:getTeamName()
	return team.GetName(getply(self):Team())
end

--- Returns the player's unique ID
-- @shared
-- @return unique ID
function player_methods:getUniqueID()
	return getply(self):UniqueID()
end

--- Returns the player's user ID
-- @shared
-- @return user ID
function player_methods:getUserID()
	return getply(self):UserID()
end

--- Returns a table with information of what the player is looking at
-- @shared
-- @return table trace data https://wiki.garrysmod.com/page/Structures/TraceResult
function player_methods:getEyeTrace()
	checkpermission(instance, nil, "trace")

	return SF.StructWrapper(instance, getply(self):GetEyeTrace())
end

--- Returns the player's current view entity
-- @shared
-- @return Player's current view entity
function player_methods:getViewEntity()
	return owrap(getply(self):GetViewEntity())
end

--- Returns the player's view model
-- In the Client realm, other players' viewmodels are not available unless they are being spectated
-- @shared
-- @return Player's view model
function player_methods:getViewModel()
	return owrap(getply(self):GetViewModel(0))
end

--- Returns a table of weapons the player is carrying
-- @shared
-- @return Table of weapons
function player_methods:getWeapons()
	return instance.Sanitize(getply(self):GetWeapons())
end

--- Returns the specified weapon or nil if the player doesn't have it
-- @shared
-- @param wep String weapon class
-- @return weapon
function player_methods:getWeapon(wep)
	checkluatype(wep, TYPE_STRING)
	return wwrap(getply(self):GetWeapon(wep))
end

--- Returns the entity that the player is standing on
-- @shared
-- @return Ground entity
function player_methods:getGroundEntity()
	return owrap(getply(self):GetGroundEntity())
end

--- Gets the amount of ammo the player has.
-- @shared
-- @param id The string or number id of the ammo
-- @return The amount of ammo player has in reserve.
function player_methods:getAmmoCount(id)
	if not isnumber(id) and not isstring(id) then SF.ThrowTypeError("number or string", SF.GetType(id), 2) end

	return getply(self):GetAmmoCount(id)
end

--- Returns whether the player is typing in their chat
-- @shared
-- @return bool true/false
function player_methods:isTyping()
	return getply(self):IsTyping()
end

--- Returns whether the player is sprinting
-- @shared
-- @return bool true/false
function player_methods:isSprinting()
	return getply(self):IsSprinting()
end

if SERVER then
	--- Sets the view entity of the player. Only works if they are linked to a hud.
	-- @server
	-- @param ent Entity to set the player's view entity to, or nothing to reset it
	function player_methods:setViewEntity(ent)
		local pl = getply(self)
		if ent~=nil then
			ent = getent(ent)
		end

		if (pl.sfhudenabled and pl.sfhudenabled:IsValid()) and pl.sfhudenabled.link == instance.data.entity then
			pl:SetViewEntity(ent)
		end
	end

	--- Returns whether or not the player has godmode
	-- @server
	-- @return True if the player has godmode
	function player_methods:hasGodMode()
		return getply(self):HasGodMode()
	end

	--- Drops the players' weapon
	-- @server
	-- @param weapon The weapon entity or class to drop
	-- @param target If set, launches the weapon at the given position
	-- @param velocity If set and target is unset, launches the weapon with the given velocity
	function player_methods:dropWeapon(weapon, target, velocity)
		local ply = getply(self)
		checkpermission(instance, ply, "player.dropweapon")
		
		if target~=nil then target = vunwrap(target) end
		if velocity~=nil then velocity = vunwrap(velocity) end
		
		if isstring(weapon) then
			ply:DropNamedWeapon(weapon, target, velocity)
		else
			weapon = wunwrap(weapon)
			ply:DropWeapon(weapon, target, velocity)
		end
	end
	
	--- Returns the hitgroup where the player was last hit.
	-- @server
	-- @return Hitgroup, see https://wiki.facepunch.com/gmod/Enums/HITGROUP
	function player_methods:lastHitGroup()
		return getply(self):LastHitGroup()
	end
end

--- Returns whether or not the player is pushing the key.
-- @shared
-- @param key Key to check. IN_KEY table values
-- @return True or false
function player_methods:keyDown(key)
	checkluatype(key, TYPE_NUMBER)

	return getply(self):KeyDown(key)
end

if CLIENT then
	--- Returns the relationship of the player to the local client
	-- @return One of: "friend", "blocked", "none", "requested"
	function player_methods:getFriendStatus()
		getply(self):GetFriendStatus()
	end

	--- Returns whether the local player has muted the player
	-- @return True if the player was muted
	function player_methods:isMuted()
		getply(self):IsMuted()
	end
	
	--- Returns whether the player is heard by the local player.
	-- @client
	-- @return bool true/false
	function player_methods:isSpeaking()
		getply(self):IsSpeaking()
	end

	--- Returns the voice volume of the player
	-- @client
	-- @return Returns the players voice volume, how loud the player's voice communication currently is, as a normal number. Doesn't work on local player unless the voice_loopback convar is set to 1.
	function player_methods:voiceVolume()
		getply(self):VoiceVolume()
	end
	
	--- Plays gesture animations on a player
	-- @client
	-- @param animation sequence string or act number. https://wiki.facepunch.com/gmod/Enums/ACT
	-- @param loop Optional bool (Default true), should the gesture loop
	-- @param slot Optional int (Default GESTURE_SLOT.CUSTOM), the gesture slot to use. GESTURE_SLOT table values
	-- @param weight Optional float (Default 1), the weight of the gesture. Ranging from 0-1
	function player_methods:playGesture(animation, loop, slot, weight)
		if slot == nil then
			slot = GESTURE_SLOT_CUSTOM
		else
			checkluatype(slot, TYPE_NUMBER)
		end
		
		if weight == nil then
			weight = 1
		else
			checkluatype(weight, TYPE_NUMBER)
		end
		
		local ply = getply(self)
		checkpermission(instance, ply, "entities.setPlayerRenderProperty")
		
		if isstring(animation) then
			animation = ply:GetSequenceActivity(ply:LookupSequence(animation))
		elseif not isnumber(animation) then
			SF.ThrowTypeError("number or string", SF.GetType(animation), 2)
		end
		
		ply:AnimResetGestureSlot(slot)
		ply:AnimRestartGesture(slot, animation, not loop)
		ply:AnimSetGestureWeight(slot, weight)
	end

	--- Resets gesture animations on a player
	-- @client
	-- @param slot Optional int (Default GESTURE_SLOT.CUSTOM), the gesture slot to use. GESTURE_SLOT table values
	function player_methods:resetGesture(slot)
		if slot == nil then
			slot = GESTURE_SLOT_CUSTOM
		else
			checkluatype(slot, TYPE_NUMBER)
		end
		
		local ply = getply(self)
		checkpermission(instance, ply, "entities.setPlayerRenderProperty")
		
		ply:AnimResetGestureSlot(slot)
	end
	
	-- Sets the weight of the gesture animation in the given gesture slot
	-- @client
	-- @param slot Optional int (Default GESTURE_SLOT.CUSTOM), the gesture slot to use. GESTURE_SLOT table values
	-- @param weight Optional float (Default 1), the weight of the gesture. Ranging from 0-1
	function player_methods:setGestureWeight(slot, weight)
		if slot == nil then
			slot = GESTURE_SLOT_CUSTOM
		else
			checkluatype(slot, TYPE_NUMBER)
		end
		
		if weight == nil then
			weight = 1
		else
			checkluatype(weight, TYPE_NUMBER)
		end
		
		local ply = getply(self)
		checkpermission(instance, ply, "entities.setPlayerRenderProperty")
		
		ply:AnimSetGestureWeight(slot, weight)
	end
end

--- ENUMs of in_keys for use with player:keyDown
-- @name builtins_library.IN_KEY
-- @class table
-- @field ALT1
-- @field ALT2
-- @field ATTACK
-- @field ATTACK2
-- @field BACK
-- @field DUCK
-- @field FORWARD
-- @field JUMP
-- @field LEFT
-- @field MOVELEFT
-- @field MOVERIGHT
-- @field RELOAD
-- @field RIGHT
-- @field SCORE
-- @field SPEED
-- @field USE
-- @field WALK
-- @field ZOOM
-- @field GRENADE1
-- @field GRENADE2
-- @field WEAPON1
-- @field WEAPON2
-- @field BULLRUSH
-- @field CANCEL
-- @field RUN
instance.env.IN_KEY = {
	["ALT1"] = IN_ALT1,
	["ALT2"] = IN_ALT2,
	["ATTACK"] = IN_ATTACK,
	["ATTACK2"] = IN_ATTACK2,
	["BACK"] = IN_BACK,
	["DUCK"] = IN_DUCK,
	["FORWARD"] = IN_FORWARD,
	["JUMP"] = IN_JUMP,
	["LEFT"] = IN_LEFT,
	["MOVELEFT"] = IN_MOVELEFT,
	["MOVERIGHT"] = IN_MOVERIGHT,
	["RELOAD"] = IN_RELOAD,
	["RIGHT"] = IN_RIGHT,
	["SCORE"] = IN_SCORE,
	["SPEED"] = IN_SPEED,
	["USE"] = IN_USE,
	["WALK"] = IN_WALK,
	["ZOOM"] = IN_ZOOM,
	["GRENADE1"] = IN_GRENADE1,
	["GRENADE2"] = IN_GRENADE2,
	["WEAPON1"] = IN_WEAPON1,
	["WEAPON2"] = IN_WEAPON2,
	["BULLRUSH"] = IN_BULLRUSH,
	["CANCEL"] = IN_CANCEL,
	["RUN"] = IN_RUN,
}

--- ENUMs of gesture_slot for use with player:playGesture player:resetGesture
-- @name builtins_library.GESTURE_SLOT
-- @class table
-- @field ATTACK_AND_RELOAD
-- @field GRENADE
-- @field JUMP
-- @field SWIM
-- @field FLINCH
-- @field VCD
-- @field CUSTOM
instance.env.GESTURE_SLOT = {
	["ATTACK_AND_RELOAD"] = GESTURE_SLOT_ATTACK_AND_RELOAD,
	["GRENADE"] = GESTURE_SLOT_GRENADE,
	["JUMP"] = GESTURE_SLOT_JUMP,
	["SWIM"] = GESTURE_SLOT_SWIM,
	["FLINCH"] = GESTURE_SLOT_FLINCH,
	["VCD"] = GESTURE_SLOT_VCD,
	["CUSTOM"] = GESTURE_SLOT_CUSTOM
}

end
