-------------------------------------------------------------------------------
-- Player functions.
-------------------------------------------------------------------------------

SF.Players = {}
--- Player type
local player_methods, player_metamethods = SF.Typedef("Player", SF.Entities.Metatable)

local vwrap = SF.WrapObject

SF.Players.Methods = player_methods
SF.Players.Metatable = player_metamethods


local dsetmeta = debug.setmetatable

local ewrap, eunwrap, ents_metatable

SF.Libraries.AddHook("postload", function()
	ewrap = SF.Entities.Wrap
	eunwrap = SF.Entities.Unwrap
	ents_metatable = SF.Entities.Metatable
	
	SF.AddObjectWrapper(debug.getregistry().Player, player_metamethods, function(object)
		object = ewrap(object)
		dsetmeta(object, player_metamethods)
		return object
	end)
	SF.AddObjectUnwrapper(player_metamethods, eunwrap)
	
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
	-- @name SF.DefaultEnvironment.IN_KEY
	-- @class table
	SF.DefaultEnvironment.IN_KEY = {
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
end)

--- To string
-- @shared
function player_metamethods:__tostring()
	local ent = eunwrap(self)
	if not ent then return "(null entity)"
	else return tostring(ent) end
end


-- ------------------------------------------------------------------------- --
--- Returns whether the player is alive
-- @shared
-- @return True if player alive
function player_methods:isAlive ()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and ent:Alive()
end

--- Returns the players armor
-- @shared
-- @return Armor
function player_methods:getArmor ()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and ent:Armor()
end

--- Returns whether the player is crouching
-- @shared
-- @return True if player crouching
function player_methods:isCrouching ()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and ent:Crouching()
end

--- Returns the amount of deaths of the player
-- @shared
-- @return Amount of deaths
function player_methods:getDeaths ()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and ent:Deaths()
end

--- Returns whether the player's flashlight is on
-- @shared
-- @return True if player has flashlight on
function player_methods:isFlashlightOn()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and ent:FlashlightIsOn()
end

--- Returns true if the player is noclipped
-- @shared
-- @return true if the player is noclipped
function player_methods:isNoclipped()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and ent:GetMoveType() == MOVETYPE_NOCLIP
end

--- Returns the amount of kills of the player
-- @shared
-- @return Amount of kills
function player_methods:getFrags ()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and ent:Frags()
end

--- Returns the name of the player's active weapon
-- @shared
-- @return The weapon
function player_methods:getActiveWeapon ()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and SF.Weapons.Wrap(ent:GetActiveWeapon())
end

--- Returns the player's aim vector
-- @shared
-- @return Aim vector
function player_methods:getAimVector ()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and vwrap(ent:GetAimVector())
end

--- Returns the player's field of view
-- @shared
-- @return Field of view
function player_methods:getFOV ()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and ent:GetFOV()
end

--- Returns the player's jump power
-- @shared
-- @return Jump power
function player_methods:getJumpPower ()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and ent:GetJumpPower()
end

--- Returns the player's maximum speed
-- @shared
-- @return Maximum speed
function player_methods:getMaxSpeed ()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and ent:GetMaxSpeed()
end

--- Returns the player's name
-- @shared
-- @return Name
function player_methods:getName ()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and ent:GetName()
end

--- Returns the player's running speed
-- @shared
-- @return Running speed
function player_methods:getRunSpeed ()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and ent:GetRunSpeed()
end

--- Returns the player's shoot position
-- @shared
-- @return Shoot position
function player_methods:getShootPos ()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and vwrap(ent:GetShootPos())
end

--- Returns whether the player is in a vehicle
-- @shared
-- @return True if player in vehicle
function player_methods:inVehicle()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and ent:InVehicle()
end

--- Returns whether the player is an admin
-- @shared
-- @return True if player is admin
function player_methods:isAdmin()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and ent:IsAdmin()
end

--- Returns whether the player is a bot
-- @shared
-- @return True if player is a bot
function player_methods:isBot()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and ent:IsBot()
end

--- Returns whether the player is connected
-- @shared
-- @return True if player is connected
function player_methods:isConnected()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and ent:IsConnected()
end

--- Returns whether the player is frozen
-- @shared
-- @return True if player is frozen
function player_methods:isFrozen()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and ent:IsFrozen()
end

--- Returns whether the player is an NPC
-- @shared
-- @return True if player is an NPC
function player_methods:isNPC()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and ent:IsNPC()
end

--- Returns whether the player is a player
-- @shared
-- @return True if player is player
function player_methods:isPlayer()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and ent:IsPlayer()
end

--- Returns whether the player is a super admin
-- @shared
-- @return True if player is super admin
function player_methods:isSuperAdmin()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and ent:IsSuperAdmin()
end

--- Returns whether the player belongs to a usergroup
-- @shared
-- @param group Group to check against
-- @return True if player belongs to group
function player_methods:isUserGroup(group)
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and ent:IsUserGroup(group)
end

--- Returns the player's current ping
-- @shared
-- @return ping
function player_methods:getPing ()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and ent:Ping()
end

--- Returns the player's steam ID
-- @shared
-- @return steam ID
function player_methods:getSteamID ()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and ent:SteamID()
end

--- Returns the player's community ID
-- @shared
-- @return community ID
function player_methods:getSteamID64 ()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and ent:SteamID64()
end

--- Returns the player's current team
-- @shared
-- @return team
function player_methods:getTeam ()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and ent:Team()
end

--- Returns the name of the player's current team
-- @shared
-- @return team name
function player_methods:getTeamName ()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and team.GetName(ent:Team())
end

--- Returns the player's unique ID
-- @shared
-- @return unique ID
function player_methods:getUniqueID ()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and ent:UniqueID()
end

--- Returns the player's user ID
-- @shared
-- @return user ID
function player_methods:getUserID ()
	SF.CheckType(self, player_metamethods)
	local ent = eunwrap(self)
	return ent and ent:UserID()
end

--- Returns a table with information of what the player is looking at
-- @shared
-- @return table trace data https://wiki.garrysmod.com/page/Structures/TraceResult
function player_methods:getEyeTrace ()
	SF.Permissions.check(SF.instance.player, eunwrap(self), "trace")
	
	local data = eunwrap(self):GetEyeTrace()
	return setmetatable({}, {
		__index = function(t, k)
			return vwrap(data[k])
		end,
		__metatable = ""
	})
end

--- Returns the player's current view entity
-- @shared
-- @return Player's current view entity
function player_methods:getViewEntity ()
	SF.CheckType(self, player_metamethods)
	return ewrap(eunwrap(self):GetViewEntity())
end

--- Returns a table of weapons the player is carrying
-- @shared
-- @return Table of weapons
function player_methods:getWeapons()
	SF.CheckType(self, player_metamethods)
	return SF.Sanitize(eunwrap(self):GetWeapons())
end

--- Returns the specified weapon or nil if the player doesn't have it
-- @shared
-- @param wep String weapon class
-- @return weapon
function player_methods:getWeapon(wep)
	SF.CheckType(self, player_metamethods)
	SF.CheckLuaType(wep, TYPE_STRING)
	return SF.Weapons.Wrap(eunwrap(self):GetWeapon(wep))
end

-- Returns the entity that the player is standing on
-- @shared
-- @return Ground entity
function player_methods:getGroundEntity()
	SF.CheckType(self, player_metamethods)
	return ewrap(eunwrap(self):GetGroundEntity())
end

-- Gets the amount of ammo the player has.
-- @shared
-- @param id The string or number id of the ammo
-- @return The amount of ammo player has in reserve.
function player_methods:getAmmoCount(id)
	SF.CheckType(self, player_metamethods)
	local tid = type(id)
	if tid~="number" and tid~="string" then
		SF.Throw("Type mismatch (Expected number or string, got " .. tid .. ") in function getAmmoCount", 2)
	end
	
	local ent = eunwrap(self)
	return ent:GetAmmoCount(id)
end

if SERVER then
	--- Sets the view entity of the player. Only works if they are linked to a hud.
	-- @server
	-- @param ent Entity to set the player's view entity to, or nothing to reset it
	function player_methods:setViewEntity (ent)
		local pl = eunwrap(self)
		if not IsValid(pl) then SF.Throw("Invalid Player", 2) end
		
		if ent~=nil then
			ent = eunwrap(ent)
			if not IsValid(ent) then SF.Throw("Invalid Entity", 2) end
		end

		if IsValid(pl.sfhudenabled) and pl.sfhudenabled.link == SF.instance.data.entity then
			pl:SetViewEntity(ent)
		end
	end
	
	--- Returns whether or not the player has godmode
	-- @server
	-- @return True if the player has godmode
	function player_methods:hasGodMode()
		SF.CheckType(self, player_metamethods)
		local ent = eunwrap(self)
		return IsValid(ent) and ent:HasGodMode() or false
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
function player_methods:keyDown (key)
	SF.CheckType(self, player_metamethods)
	SF.CheckLuaType(key, TYPE_NUMBER)
	
	local ent = eunwrap(self)
	if not IsValid(ent) then return false end
	
	return ent:KeyDown(key)
end

if CLIENT then
	--- Returns the relationship of the player to the local client
	-- @return One of: "friend", "blocked", "none", "requested"
	function player_methods:getFriendStatus()
		SF.CheckType(self, player_metamethods)
		local ent = eunwrap(self)
		return ent and ent:GetFriendStatus()
	end
	
	--- Returns whether the local player has muted the player
	-- @return True if the player was muted
	function player_methods:isMuted()
		SF.CheckType(self, player_metamethods)
		local ent = eunwrap(self)
		return ent and ent:IsMuted()
	end
end
