

--- Game functions
-- @name game
-- @class library
-- @libtbl game_library
SF.RegisterLibrary("game")

return function(instance)

local game_library = instance.Libraries.game
local vwrap, ewrap = instance.Types.Vector.Wrap, instance.Types.Entity.Wrap

--- Returns the map name
-- @name game_library.getMap
-- @class function
-- @return string The name of the current map
game_library.getMap = game.GetMap

--- Returns The hostname
-- @name game_library.getHostname
-- @class function
-- @return string The hostname of the server
game_library.getHostname = GetHostName

--- Returns true if the server is on a LAN
-- @return boolean True if the game is a lan game
function game_library.isLan()
	return GetConVar("sv_lan"):GetBool()
end

--- Returns whether or not the current game is single player
-- @name game_library.isSinglePlayer
-- @class function
-- @return boolean True if the game is singleplayer
game_library.isSinglePlayer = game.SinglePlayer

--- Returns whether or not the server is a dedicated server
-- @name game_library.isDedicated
-- @class function
-- @return boolean True if the game is a dedicated server
game_library.isDedicated = game.IsDedicated

--- Returns the maximum player limit
-- @name game_library.getMaxPlayers
-- @class function
-- @return number The max players allowed by the server
game_library.getMaxPlayers = game.MaxPlayers

--- Checks whether the specified game is mounted
-- @name game_library.isMounted
-- @class function
-- @param str String identifier of the game, eg. 'cstrike'
-- @return True if the game is mounted
game_library.isMounted = IsMounted

--- Returns the game time scale
-- @name game_library.getTimeScale
-- @class function
-- @return number time scale
game_library.getTimeScale = game.GetTimeScale

--- Returns the number of seconds between each gametick
-- @name game_library.getTickInterval
-- @class function
-- @return number interval
game_library.getTickInterval = engine.TickInterval

--- Returns AmmoData for given id
-- @param number id, see https://wiki.facepunch.com/gmod/Default_Ammo_Types
-- @return table AmmoData, see https://wiki.facepunch.com/gmod/Structures/AmmoData
function game_library.getAmmoData(id)
	return game.GetAmmoData(id)
end

--- Returns the worldspawn entity
-- @return entity world
function game_library.getWorld()
	return ewrap(game.GetWorld())
end

if CLIENT then
	--- Returns if the game has focus or not, i.e. will return false if the game is minimized
	-- @name game_library.hasFocus
	-- @client
	-- @class function
	-- @return boolean True if the game is focused
	game_library.hasFocus = system.HasFocus
	
	--- Returns the direction and how obstructed the map's sun is or nil if it doesn't exist
	-- @client
	-- @return vector The direction of the sun
	-- @return number How obstructed the sun is 0 to 1.
	function game_library.getSunInfo()
		local info = util.GetSunInfo()
		if info then return vwrap(info.direction), info.obstruction end
	end
end

end
