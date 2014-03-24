-------------------------------------------------------------------------------
-- Player functions.
-------------------------------------------------------------------------------

SF.Players = {}
--- Player type
local player_methods, player_metamethods = SF.Typedef("Player", SF.Entities.Metatable)

SF.Players.Methods = player_methods
SF.Players.Metatable = player_metamethods

--- Custom wrapper/unwrapper is necessary for player objects
-- wrapper
local dsetmeta = debug.setmetatable
local function wrap( object )
	object = SF.Entities.Wrap( object )
	dsetmeta( object, player_metamethods )
	return object
end

SF.AddObjectWrapper( debug.getregistry().Player, player_metamethods, wrap )

-- unwrapper
SF.AddObjectUnwrapper( player_metamethods, SF.Entities.Unwrap )

--- To string
-- @shared
function player_metamethods:__tostring()
	local ent = SF.Entities.Unwrap(self)
	if not ent then return "(null entity)"
	else return tostring(ent) end
end


-- ------------------------------------------------------------------------- --
--- Returns whether the player is alive
-- @shared
-- @return True if player alive
function player_methods:isAlive ()
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:Alive()
end

--- Returns the players armor
-- @shared
-- @return Armor
function player_methods:getArmor ()
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:Armor()
end

--- Returns whether the player is crouching
-- @shared
-- @return True if player crouching
function player_methods:isCrouching ()
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:Crouching()
end

--- Returns the amount of deaths of the player
-- @shared
-- @return Amount of deaths
function player_methods:getDeaths ()
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:Deaths()
end

--- Returns whether the player's flashlight is on
-- @shared
-- @return True if player has flashlight on
function player_methods:isFlashlightOn( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:FlashlightIsOn()
end

--- Returns the amount of kills of the player
-- @shared
-- @return Amount of kills
function player_methods:getFrags ()
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:Frags()
end

--- Returns the name of the player's active weapon
-- @shared
-- @return Name of weapon
function player_methods:getActiveWeapon ()
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:GetActiveWeapon():ClassName()
end

--- Returns the player's aim vector
-- @shared
-- @return Aim vector
function player_methods:getAimVector ()
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:GetAimVector()
end

--- Returns the player's field of view
-- @shared
-- @return Field of view
function player_methods:getFOV ()
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:GetFOV()
end

--- Returns the player's jump power
-- @shared
-- @return Jump power
function player_methods:getJumpPower ()
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:GetJumpPower()
end

--- Returns the player's maximum speed
-- @shared
-- @return Maximum speed
function player_methods:getMaxSpeed ()
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:GetMaxSpeed()
end

--- Returns the player's name
-- @shared
-- @return Name
function player_methods:getName ()
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:GetName()
end

--- Returns the player's running speed
-- @shared
-- @return Running speed
function player_methods:getRunSpeed ()
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:GetRunSpeed()
end

--- Returns the player's shoot position
-- @shared
-- @return Shoot position
function player_methods:getShootPos ()
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:GetShootPos()
end

--- Returns whether the player is in a vehicle
-- @shared
-- @return True if player in vehicle
function player_methods:inVehicle( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:InVehicle()
end

--- Returns whether the player is an admin
-- @shared
-- @return True if player is admin
function player_methods:isAdmin( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:IsAdmin( )
end

--- Returns whether the player is a bot
-- @shared
-- @return True if player is a bot
function player_methods:isBot( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:IsBot( )
end

--- Returns whether the player is connected
-- @shared
-- @return True if player is connected
function player_methods:isConnected( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:IsConnected( )
end

--- Returns whether the player is frozen
-- @shared
-- @return True if player is frozen
function player_methods:isFrozen( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:IsFrozen( )
end

--- Returns whether the player is an NPC
-- @shared
-- @return True if player is an NPC
function player_methods:isNPC( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:IsNPC( )
end

--- Returns whether the player is a player
-- @shared
-- @return True if player is player
function player_methods:isPlayer( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:IsPlayer()
end

--- Returns whether the player is a super admin
-- @shared
-- @return True if player is super admin
function player_methods:isSuperAdmin( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:IsSuperAdmin( )
end

--- Returns whether the player belongs to a usergroup
-- @shared
-- @param group Group to check against
-- @return True if player belongs to group
function player_methods:isUserGroup( group )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:IsUserGroup( group )
end

--- Returns the player's current ping
-- @shared
-- @return ping
function player_methods:getPing ()
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:Ping()
end

--- Returns the player's steam ID
-- @shared
-- @return steam ID
function player_methods:getSteamID ()
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:SteamID()
end

--- Returns the player's community ID
-- @shared
-- @return community ID
function player_methods:getSteamID64 ()
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:SteamID64( )
end

--- Returns the player's current team
-- @shared
-- @return team
function player_methods:getTeam ()
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:Team()
end

--- Returns the name of the player's current team
-- @shared
-- @return team name
function player_methods:getTeamName ()
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and team.GetName(ent:Team())
end

--- Returns the player's unique ID
-- @shared
-- @return unique ID
function player_methods:getUniqueID ()
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:UniqueID()
end

--- Returns the player's user ID
-- @shared
-- @return user ID
function player_methods:getUserID ()
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:UserID()
end

if CLIENT then
	--- Returns the relationship of the player to the local client
	-- @return One of: "friend", "blocked", "none", "requested"
	function player_methods:getFriendStatus( )
		SF.CheckType( self, player_metamethods )
		local ent = SF.Entities.Unwrap( self )
		return ent and ent:GetFriendStatus( )
	end
	
	--- Returns whether the local player has muted the player
	-- @return True if the player was muted
	function player_methods:isMuted( )
		SF.CheckType( self, player_metamethods )
		local ent = SF.Entities.Unwrap( self )
		return ent and ent:IsMuted( )
	end
end
