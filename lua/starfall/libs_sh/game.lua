

--- Game functions
-- @shared
SF.RegisterLibrary("game")

return function(instance)

local game_lib = instance.Libraries.game
local vwrap = instance.Types.Vector.Wrap

--- Returns the map name
-- @name game_lib.getMap
-- @class function
-- @return string The name of the current map
game_lib.getMap = game.GetMap

--- Returns The hostname
-- @name game_lib.getHostname
-- @class function
-- @return string The hostname of the se`rver
game_lib.getHostname = GetHostName

--- Returns true if the server is on a LAN
-- @return boolean True if the game is a lan game
function game_lib.isLan ()
	return GetConVar("sv_lan"):GetBool()
end

--- Returns whether or not the current game is single player
-- @name game_lib.isSinglePlayer
-- @class function
-- @return boolean True if the game is singleplayer
game_lib.isSinglePlayer = game.SinglePlayer

--- Returns whether or not the server is a dedicated server
-- @name game_lib.isDedicated
-- @class function
-- @return boolean True if the game is a dedicated server
game_lib.isDedicated = game.IsDedicated

--- Returns the maximum player limit
-- @name game_lib.getMaxPlayers
-- @class function
-- @return number The max players allowed by the server
game_lib.getMaxPlayers = game.MaxPlayers

if CLIENT then
	--- Returns if the game has focus or not, i.e. will return false if the game is minimized
	-- @name game_lib.hasFocus
	-- @client
	-- @class function
	-- @return boolean True if the game is focused
	game_lib.hasFocus = system.HasFocus
	
	--- Returns the direction and how obstructed the map's sun is
	-- @client
	-- @return vector The direction of the sun
	-- @return number How obstructed the sun is 0 to 1.
	function game_lib.getSunInfo()
		local info = util.GetSunInfo()
		return vwrap(info.direction), info.obstruction
	end
end

end
