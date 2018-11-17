-------------------------------------------------------------------------------
-- Game library
-------------------------------------------------------------------------------

--- Game functions
-- @shared
local game_lib = SF.RegisterLibrary("game")

--- Returns the map name
function game_lib.getMap ()
	return game.GetMap()
end

--- Returns The hostname
function game_lib.getHostname ()
	return GetHostName()
end

--- Returns true if the server is on a LAN
-- @deprecated Possibly add ConVar retrieval for users in future. Could implement with SF Script.
function game_lib.isLan ()
	return GetConVar("sv_lan"):GetBool()
end

--- Returns whether or not the current game is single player
function game_lib.isSinglePlayer ()
	return game.SinglePlayer()
end

--- Returns whether or not the server is a dedicated server
function game_lib.isDedicated ()
	return game.IsDedicated()
end

--- Returns the maximum player limit
function game_lib.getMaxPlayers ()
	return game.MaxPlayers()
end
