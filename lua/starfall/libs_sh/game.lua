-------------------------------------------------------------------------------
-- Game library
-------------------------------------------------------------------------------

--- Game functions
-- @shared
local game_lib, _ = SF.Libraries.Register( "game" )

--- Returns the map name
function game_lib.getMap ()
	return game.GetMap()
end

--- Returns The hostname
-- @deprecated Possibly add ConVar retrieval for users in future. Could implement with SF Script.
function game_lib.getHostname ()
	return GetConVar( "hostname" ):GetString()
end

--- Returns true if the server is on a LAN
-- @deprecated Possibly add ConVar retrieval for users in future. Could implement with SF Script.
function game_lib.isLan ()
	return GetConVar( "sv_lan" ):GetBool()
end

--- Returns the gamemode as a String
function game_lib.getGamemode ()
	local rtn = {}
	local t = gmod.GetGamemode()
	for k, v in pairs( t ) do
		if type( v ) ~= "function" and type( v ) ~= "table" then
			rtn[ k:gsub( "^%u", string.lower ) ] = v
		end
	end
	return SF.Sanitize( rtn )
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
