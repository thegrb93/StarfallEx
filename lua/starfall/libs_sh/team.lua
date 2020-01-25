
--- Library for retreiving information about teams
-- @name team
-- @class library
-- @libtbl team_library
SF.RegisterLibrary("team")


return function(instance)


local team_library = instance.Libraries.team
local col_meta, cwrap, cunwrap = instance.Types.Color, instance.Types.Color.Wrap, instance.Types.Color.Unwrap

--- Returns a table containing team information
-- @return table containing team information
function team_library.getAllTeams()
	return instance.Sanitize(team.GetAllTeams())
end

--- Returns the color of a team
-- @param ind Index of the team
-- @return Color of the team
function team_library.getColor(ind)
	return cwrap(team.GetColor(ind))
end

--- Returns the table of players on a team
-- @param ind Index of the team
-- @return Table of players
function team_library.getPlayers(ind)
	return instance.Sanitize(team.GetPlayers(ind))
end

--- Returns team with least players
-- @name team_library.bestAutoJoinTeam
-- @class function
-- @return index of the best team to join
team_library.bestAutoJoinTeam = team.BestAutoJoinTeam

--- Returns the name of a team
-- @name team_library.getName
-- @class function
-- @param ind Index of the team
-- @return String name of the team
team_library.getName = team.GetName

--- Returns the score of a team
-- @name team_library.getScore
-- @class function
-- @param ind Index of the team
-- @return Number score of the team
team_library.getScore =  team.GetScore

--- Returns whether or not a team can be joined
-- @name team_library.getJoinable
-- @class function
-- @param ind Index of the team
-- @return boolean
team_library.getJoinable = team.Joinable

--- Returns number of players on a team
-- @name team_library.getNumPlayers
-- @class function
-- @param ind Index of the team
-- @return number of players
team_library.getNumPlayers = team.NumPlayers

--- Returns number of deaths of all players on a team
-- @name team_library.getNumDeaths
-- @class function
-- @param ind Index of the team
-- @return number of deaths
team_library.getNumDeaths = team.TotalDeaths

--- Returns number of frags of all players on a team
-- @name team_library.getNumFrags
-- @class function
-- @param ind Index of the team
-- @return number of frags
team_library.getNumFrags = team.TotalFrags

--- Returns whether or not the team exists
-- @name team_library.exists
-- @class function
-- @param ind Index of the team
-- @return boolean
team_library.exists = team.Valid

end
