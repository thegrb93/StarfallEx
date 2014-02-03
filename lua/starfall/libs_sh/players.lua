-------------------------------------------------------------------------------
-- Player functions.
-------------------------------------------------------------------------------

SF.Players = {}
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
function player_methods:alive( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:Alive()
end

function player_methods:armor( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:Armor()
end

function player_methods:crouching( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:Crouching()
end

function player_methods:deaths( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:Deaths()
end

function player_methods:flashlightIsOn( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:FlashlightIsOn()
end

function player_methods:frags( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:Frags()
end

function player_methods:activeWeapon( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:GetActiveWeapon():ClassName()
end

function player_methods:aimVector( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:GetAimVector()
end

function player_methods:fov()
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:GetFOV()
end

function player_methods:jumpPower( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:GetJumpPower()
end

function player_methods:maxSpeed( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:GetMaxSpeed()
end

function player_methods:name( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:GetName()
end

function player_methods:runSpeed( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:GetRunSpeed()
end

function player_methods:shootPos( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:GetShootPos()
end

function player_methods:inVehicle( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:InVehicle()
end

function player_methods:isAdmin( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:IsAdmin( )
end

function player_methods:isBot( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:IsBot( )
end

function player_methods:isConnected( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:IsConnected( )
end

function player_methods:isFrozen( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:IsFrozen( )
end

function player_methods:isNPC( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:IsNPC( )
end

function player_methods:isPlayer( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:IsPlayer()
end

function player_methods:isSuperAdmin( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:IsSuperAdmin( )
end

function player_methods:isUserGroup( group )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:IsUserGroup( group )
end

function player_methods:name()
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:Name()
end

function player_methods:nick()
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:Nick()
end

function player_methods:ping()
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:Ping()
end

function player_methods:steamID( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:SteamID()
end

function player_methods:steamID64( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:SteamID64( )
end

function player_methods:team( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:Team()
end

function player_methods:teamName( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and team.GetName(ent:Team())
end

function player_methods:uniqueID( )
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:UniqueID()
end

function player_methods:userID()
	SF.CheckType( self, player_metamethods )
	local ent = SF.Entities.Unwrap( self )
	return ent and ent:UserID()
end

if CLIENT then
	function player_methods:getFriendStatus( )
		SF.CheckType( self, player_metamethods )
		local ent = SF.Entities.Unwrap( self )
		return ent and ent:GetFriendStatus( )
	end
	
	function player_methods:isMuted( )
		SF.CheckType( self, player_metamethods )
		local ent = SF.Entities.Unwrap( self )
		return ent and ent:IsMuted( )
	end
end
