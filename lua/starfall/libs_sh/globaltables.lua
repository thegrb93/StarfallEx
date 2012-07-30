
--- Cross-instance tables
-- @shared
local gtables_library, gtables_metamethods = SF.Libraries.Register("globaltables")

SF.GlobalTables = {}

SF.GlobalTables.Global = {}
SF.GlobalTables.Players = {}

gtables_library.global = SF.GlobalTables.Global
local player_tables = SF.GlobalTables.Players

hook.Add("PlayerInitialSpawn", "SF_GlobalTables_cn", function(ply)
	SF.GlobalTables.Players[ply] = {}
end)

hook.Add("PlayerDisconnected", "SF_GlobalTables_dc", function(ply)
	SF.GlobalTables.Players[ply] = nil
end)

local oldindex = gtables_metamethods.__index
function gtables_metamethods:__index(k)
	if k == "player" then
		return SF.GlobalTables.Players[SF.instance.player]
	else
		return oldindex[k]
	end
end
