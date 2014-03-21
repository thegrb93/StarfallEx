--- Sf Provider Interface
-- TODO: Need to document the shit out of this.
--
SF.Permissions.Provider = {}

local P = SF.Permissions.Provider
P.__index = P

-- localize the Result enum
local NEUTRAL = SF.Permissions.Result.NEUTRAL

--- Checks whether this provider knows who the server owners are.
-- @return boolean whether this provider supports the isOwner method
function P:supportsOwner ()
	return false
end

--- Checks whether a player is considered the owner of the server.
-- @param principal the player to examine
-- @return boolean whether the player is in the owners group
function P:isOwner ( principal )
	return false
end

--- Checks whether a player may perform an action.
-- @param principal the player performing the action to be authorized
-- @param target the object on which the action is being performed
-- @param key a string identifying the action being performed
-- @return one of the SF.Permissions.Role values
function P:check ( principal, target, key )
	return NEUTRAL
end
