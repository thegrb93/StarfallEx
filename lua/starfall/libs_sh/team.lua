
--- Library for retreiving information about teams
-- @shared
local team_library, team_library_metamethods = SF.Libraries.Register("team")
local cwrap, cunwrap
SF.Libraries.AddHook("postload", function()
	cwrap = SF.Color.Wrap
	cunwrap = SF.Color.Unwrap
end)

--- Returns team with least players
-- @return index of the best team to join
function team_library.bestAutoJoinTeam()
end
team_library.bestAutoJoinTeam = team.BestAutoJoinTeam

--- Returns a table containing team information
-- @return table containing team information
function team_library.getAllTeams()
	return SF.Sanitize(team.GetAllTeams())
end

--- Returns the color of a team
-- @param ind Index of the team
-- @return Color of the team
function team_library.getColor(ind)
	return cwrap(team.GetColor(ind)) 
end

--- Returns the name of a team
-- @param ind Index of the team
-- @return String name of the team
function team_library.getName(ind)
end
team_library.getName = team.GetName

--- Returns the table of players on a team
-- @param ind Index of the team
-- @return Table of players
function team_library.getPlayers(ind)
	return SF.Sanitize(team.GetPlayers(ind))
end

--- Returns the score of a team
-- @param ind Index of the team
-- @return Number score of the team
function team_library.getScore(ind)
end
team_library.getScore =  team.GetScore

--- Returns whether or not a team can be joined
-- @param ind Index of the team
-- @return boolean
function team_library.getJoinable(ind)
end
team_library.getJoinable = team.Joinable

--- Returns number of players on a team
-- @param ind Index of the team
-- @return number of players
function team_library.getNumPlayers(ind)
end
team_library.getNumPlayers = team.NumPlayers

--- Returns number of deaths of all players on a team
-- @param ind Index of the team
-- @return number of deaths
function team_library.getNumDeaths(ind)
end
team_library.getNumDeaths = team.TotalDeaths

--- Returns number of frags of all players on a team
-- @param ind Index of the team
-- @return number of frags
function team_library.getNumFrags(ind)
end
team_library.getNumFrags = team.TotalFrags

--- Returns number of frags of all players on a team
-- @param ind Index of the team
-- @return number of frags
function team_library.getNumFrags(ind)
end
team_library.getNumFrags = team.TotalFrags

--- Returns whether or not the team exists
-- @param ind Index of the team
-- @return boolean
function team_library.exists(ind)
end
team_library.exists = team.Valid

