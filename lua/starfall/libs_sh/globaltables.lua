
--- Cross-instance tables
-- @shared
local gtables_library = SF.Libraries.Register("globaltables")

SF.GlobalTables = {}

SF.GlobalTables.Global = {}
SF.GlobalTables.Players = {}

--- Global table shared by all instances on the same side.
-- @name gtables_library.global
-- @class table
gtables_library.global = SF.GlobalTables.Global

--- Player-unique global table.
-- @name gtables_library.player
-- @class table

hook.Add("PlayerInitialSpawn", "SF_GlobalTables_cn", function(ply)
	SF.GlobalTables.Players[ply] = {}
end)

hook.Add("PlayerDisconnected", "SF_GlobalTables_dc", function(ply)
	SF.GlobalTables.Players[ply] = nil
end)

setmetatable(gtables_library, {__index = function(k)
	if k == "player" then
		return SF.GlobalTables.Players[SF.instance.player]
	end
end } )
