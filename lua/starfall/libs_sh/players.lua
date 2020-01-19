-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check


-- Local to each starfall
return { function(instance) -- Called for library declarations


--- Player type
local player_methods, player_meta = instance:RegisterType("Player")

if SERVER then
	instance:AddHook("deinitialize", function()
		for k, pl in pairs(player.GetAll()) do
			if pl.sfhudenabled and pl.sfhudenabled.link == instance.data.entity then
				pl:SetViewEntity()
			end
		end
	end)
end


end, function(instance) -- Called for library definitions


local checktype = instance.CheckType
local player_methods, player_meta = instance.Types.Player.Methods, instance.Types.Player
local owrap, ounwrap = instance.WrapObject, instance.UnwrapObject
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap

instance:ApplyTypeDependencies(player_methods, player_meta, ent_meta)
local wrap, unwrap = instance:CreateWrapper(player_meta, true, false, debug.getregistry().Player, ent_meta)

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

--- To string
-- @shared
function player_meta:__tostring()
	local ent = unwrap(self)
	if not ent then return "(null entity)"
	else return tostring(ent) end
end


-- ------------------------------------------------------------------------- --
--- Returns whether the player is alive
-- @shared
-- @return True if player alive
function player_methods:isAlive()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and ent:Alive()
end

--- Returns the players armor
-- @shared
-- @return Armor
function player_methods:getArmor()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and ent:Armor()
end

--- Returns whether the player is crouching
-- @shared
-- @return True if player crouching
function player_methods:isCrouching()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and ent:Crouching()
end

--- Returns the amount of deaths of the player
-- @shared
-- @return Amount of deaths
function player_methods:getDeaths()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and ent:Deaths()
end

--- Returns whether the player's flashlight is on
-- @shared
-- @return True if player has flashlight on
function player_methods:isFlashlightOn()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and ent:FlashlightIsOn()
end

--- Returns true if the player is noclipped
-- @shared
-- @return true if the player is noclipped
function player_methods:isNoclipped()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and ent:GetMoveType() == MOVETYPE_NOCLIP
end

--- Returns the amount of kills of the player
-- @shared
-- @return Amount of kills
function player_methods:getFrags()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and ent:Frags()
end

--- Returns the name of the player's active weapon
-- @shared
-- @return The weapon
function player_methods:getActiveWeapon()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and instance.Types.Weapon.Wrap(ent:GetActiveWeapon())
end

--- Returns the player's aim vector
-- @shared
-- @return Aim vector
function player_methods:getAimVector()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and owrap(ent:GetAimVector())
end

--- Returns the player's field of view
-- @shared
-- @return Field of view
function player_methods:getFOV()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and ent:GetFOV()
end

--- Returns the player's jump power
-- @shared
-- @return Jump power
function player_methods:getJumpPower()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and ent:GetJumpPower()
end

--- Returns the player's maximum speed
-- @shared
-- @return Maximum speed
function player_methods:getMaxSpeed()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and ent:GetMaxSpeed()
end

--- Returns the player's name
-- @shared
-- @return Name
function player_methods:getName()
	checktype(self, player_meta)
	local ent = unwrap(self)
	if not (ent and ent:IsValid()) then SF.Throw("Invalid Entity!", 2) end
	return ent:GetName()
end

--- Returns the player's running speed
-- @shared
-- @return Running speed
function player_methods:getRunSpeed()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and ent:GetRunSpeed()
end

--- Returns the player's shoot position
-- @shared
-- @return Shoot position
function player_methods:getShootPos()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and owrap(ent:GetShootPos())
end

--- Returns whether the player is in a vehicle
-- @shared
-- @return True if player in vehicle
function player_methods:inVehicle()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and ent:InVehicle()
end

--- Returns the vehicle the player is driving
-- @shared
-- @return Vehicle if player in vehicle or nil
function player_methods:getVehicle()
	checktype(self, player_meta)
	local ent = unwrap(self)
	if not (ent and ent:IsValid()) then return end
	return instance.Types.Vehicle.Wrap(ent:GetVehicle())
end

--- Returns whether the player is an admin
-- @shared
-- @return True if player is admin
function player_methods:isAdmin()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and ent:IsAdmin()
end

--- Returns whether the player is a bot
-- @shared
-- @return True if player is a bot
function player_methods:isBot()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and ent:IsBot()
end

--- Returns whether the player is connected
-- @shared
-- @return True if player is connected
function player_methods:isConnected()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and ent:IsConnected()
end

--- Returns whether the player is frozen
-- @shared
-- @return True if player is frozen
function player_methods:isFrozen()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and ent:IsFrozen()
end

--- Returns whether the player is an NPC
-- @shared
-- @return True if player is an NPC
function player_methods:isNPC()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and ent:IsNPC()
end

--- Returns whether the player is a player
-- @shared
-- @return True if player is player
function player_methods:isPlayer()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and ent:IsPlayer()
end

--- Returns whether the player is a super admin
-- @shared
-- @return True if player is super admin
function player_methods:isSuperAdmin()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and ent:IsSuperAdmin()
end

--- Returns whether the player belongs to a usergroup
-- @shared
-- @param group Group to check against
-- @return True if player belongs to group
function player_methods:isUserGroup(group)
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and ent:IsUserGroup(group)
end

--- Returns the player's current ping
-- @shared
-- @return ping
function player_methods:getPing()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and ent:Ping()
end

--- Returns the player's steam ID
-- @shared
-- @return steam ID
function player_methods:getSteamID()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and ent:SteamID()
end

--- Returns the player's community ID
-- @shared
-- @return community ID
function player_methods:getSteamID64()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and ent:SteamID64()
end

--- Returns the player's current team
-- @shared
-- @return team
function player_methods:getTeam()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and ent:Team()
end

--- Returns the name of the player's current team
-- @shared
-- @return team name
function player_methods:getTeamName()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and team.GetName(ent:Team())
end

--- Returns the player's unique ID
-- @shared
-- @return unique ID
function player_methods:getUniqueID()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and ent:UniqueID()
end

--- Returns the player's user ID
-- @shared
-- @return user ID
function player_methods:getUserID()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and ent:UserID()
end

--- Returns a table with information of what the player is looking at
-- @shared
-- @return table trace data https://wiki.garrysmod.com/page/Structures/TraceResult
function player_methods:getEyeTrace()
	checkpermission(instance, nil, "trace")

	return SF.StructWrapper(instance, unwrap(self):GetEyeTrace())
end

--- Returns the player's current view entity
-- @shared
-- @return Player's current view entity
function player_methods:getViewEntity()
	checktype(self, player_meta)
	return owrap(unwrap(self):GetViewEntity())
end

--- Returns a table of weapons the player is carrying
-- @shared
-- @return Table of weapons
function player_methods:getWeapons()
	checktype(self, player_meta)
	return instance.Sanitize(unwrap(self):GetWeapons())
end

--- Returns the specified weapon or nil if the player doesn't have it
-- @shared
-- @param wep String weapon class
-- @return weapon
function player_methods:getWeapon(wep)
	checktype(self, player_meta)
	checkluatype(wep, TYPE_STRING)
	return instance.Types.Weapon.Wrap(unwrap(self):GetWeapon(wep))
end

--- Returns the entity that the player is standing on
-- @shared
-- @return Ground entity
function player_methods:getGroundEntity()
	checktype(self, player_meta)
	return owrap(unwrap(self):GetGroundEntity())
end

--- Gets the amount of ammo the player has.
-- @shared
-- @param id The string or number id of the ammo
-- @return The amount of ammo player has in reserve.
function player_methods:getAmmoCount(id)
	checktype(self, player_meta)
	if not isnumber(id) and not isstring(id) then SF.ThrowTypeError("number or string", SF.GetType(id), 2) end

	local ent = unwrap(self)
	return ent:GetAmmoCount(id)
end

--- Returns whether the player is typing in their chat
-- @shared
-- @return bool true/false
function player_methods:isTyping()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return ent and ent:IsValid() and ent:IsTyping()
end

--- Returns whether the player is sprinting
-- @shared
-- @return bool true/false
function player_methods:isSprinting()
	checktype(self, player_meta)
	local ent = unwrap(self)
	return (ent and ent:IsValid()) and ent:IsSprinting()
end

if SERVER then
	--- Sets the view entity of the player. Only works if they are linked to a hud.
	-- @server
	-- @param ent Entity to set the player's view entity to, or nothing to reset it
	function player_methods:setViewEntity(ent)
		local pl = unwrap(self)
		if not (pl and pl:IsValid()) then SF.Throw("Invalid Player", 2) end

		if ent~=nil then
			ent = unwrap(ent)
			if not (ent and ent:IsValid()) then SF.Throw("Invalid Entity", 2) end
		end

		if (pl.sfhudenabled and pl.sfhudenabled:IsValid()) and pl.sfhudenabled.link == instance.data.entity then
			pl:SetViewEntity(ent)
		end
	end

	--- Returns whether or not the player has godmode
	-- @server
	-- @return True if the player has godmode
	function player_methods:hasGodMode()
		checktype(self, player_meta)
		local ent = unwrap(self)
		return (ent and ent:IsValid()) and ent:HasGodMode() or false
	end
end

--- Returns whether or not the player is pushing the key.
-- @shared
-- @param key Key to check.
---IN_KEY.ALT1
---IN_KEY.ALT2
---IN_KEY.ATTACK
---IN_KEY.ATTACK2
---IN_KEY.BACK
---IN_KEY.DUCK
---IN_KEY.FORWARD
---IN_KEY.JUMP
---IN_KEY.LEFT
---IN_KEY.MOVELEFT
---IN_KEY.MOVERIGHT
---IN_KEY.RELOAD
---IN_KEY.RIGHT
---IN_KEY.SCORE
---IN_KEY.SPEED
---IN_KEY.USE
---IN_KEY.WALK
---IN_KEY.ZOOM
---IN_KEY.GRENADE1
---IN_KEY.GRENADE2
---IN_KEY.WEAPON1
---IN_KEY.WEAPON2
---IN_KEY.BULLRUSH
---IN_KEY.CANCEL
---IN_KEY.RUN
-- @return True or false
function player_methods:keyDown(key)
	checktype(self, player_meta)
	checkluatype(key, TYPE_NUMBER)

	local ent = unwrap(self)
	if not (ent and ent:IsValid()) then return false end

	return ent:KeyDown(key)
end

if CLIENT then
	--- Returns the relationship of the player to the local client
	-- @return One of: "friend", "blocked", "none", "requested"
	function player_methods:getFriendStatus()
		checktype(self, player_meta)
		local ent = unwrap(self)
		return ent and ent:GetFriendStatus()
	end

	--- Returns whether the local player has muted the player
	-- @return True if the player was muted
	function player_methods:isMuted()
		checktype(self, player_meta)
		local ent = unwrap(self)
		return ent and ent:IsValid() and ent:IsMuted()
	end
	
	--- Returns whether the player is heard by the local player.
	-- @client
	-- @return bool true/false
	function player_methods:isSpeaking()
		checktype(self, player_meta)
		local ent = unwrap(self)
		return ent and ent:IsValid() and ent:IsSpeaking()
	end

	--- Returns the voice volume of the player
	-- @client
	-- @return Returns the players voice volume, how loud the player's voice communication currently is, as a normal number. Doesn't work on local player unless the voice_loopback convar is set to 1.
	function player_methods:voiceVolume()
		checktype(self, player_meta)
		local ent = unwrap(self)
		return ent and ent:IsValid() and ent:VoiceVolume()
	end
end

end}

--- ENUMs of in_keys for use with player:keyDown:
-- ALT1,
-- ALT2,
-- ATTACK,
-- ATTACK2,
-- BACK,
-- DUCK,
-- FORWARD,
-- JUMP,
-- LEFT,
-- MOVELEFT,
-- MOVERIGHT,
-- RELOAD,
-- RIGHT,
-- SCORE,
-- SPEED,
-- USE,
-- WALK,
-- ZOOM,
-- GRENADE1,
-- GRENADE2,
-- WEAPON1,
-- WEAPON2,
-- BULLRUSH,
-- CANCEL,
-- RUN
-- @name Environment.IN_KEY
-- @class table
