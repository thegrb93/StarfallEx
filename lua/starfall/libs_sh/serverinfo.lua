--- Server info functions. 
-- @shared
local serverinfo_library, _ = SF.Libraries.Register("serverinfo")

--- Same as Glua's physenv.GetPerformanceSettings()
--@return Table containing physics environment settings 
function serverinfo_library.GetPerformanceSettings()
	return physenv.GetPerformanceSettings()
end

--- Same as Glua's physenv.GetGravity()
--@return Vector describing acceleration due to gravity setting
function serverinfo_library.GetGravity()
	return physenv.GetGravity()
end

--- Same as Glua's physenv.GetAirDensity()
--@return Number describing air density setting
function serverinfo_library.GetAirDensity()
	return physenv.GetAirDensity()
end

--- Same as Glua's game.GetMap()
--@return The map name as a string
function serverinfo_library.GetMap()
	return game.GetMap()
end

--- Returns The hostname convar
--@return The hostname convar
function serverinfo_library.GetHostname() 
	return GetConVar("hostname"):GetString()
end

--- Returns true if the server is on a LAN
function serverinfo_library.isLan()
	return GetConVar("sv_lan"):GetBool() 
end

--- Returns the gamemode as a String
--@return The name of the gamemode
function serverinfo_library.GetGamemode()
	return gmod.GetGamemode().Name
end

--- Same as GLua's SinglePlayer()
function serverinfo_library.SinglePlayer()
	return SinglePlayer()
end

--- Same as GLua's isDedicatedServer()
function serverinfo_library.isDedicatedServer()
	return isDedicatedServer()
end

--- Returns the number of players on the server
--@return The number of players on the server
function serverinfo_library.numPlayers()
	return #player.GetAll()
end

--- Same as GLua's MaxPlayers()
function serverinfo_library.MaxPlayers()
	return MaxPlayers()
end