
--- Cross-instance tables
-- @shared
local gtables_library = SF.Libraries.Register("globaltables")

SF.GlobalTables = {}
SF.GlobalTables.Global = {}
SF.GlobalTables.Players = {}

SF.Libraries.AddHook("initialize",function(inst)
	if not SF.GlobalTables.Players[inst.player] then
		SF.GlobalTables.Players[inst.player] = {}
	end
	inst.env.globaltables.global = SF.GlobalTables.Global
	inst.env.globaltables.player = SF.GlobalTables.Players[inst.player]
end)

SF.Libraries.AddHook("deinitialize", function(inst)
	local clean = true
	for _, inst2 in pairs(SF.allInstances) do
		if inst!=inst2 then
			clean = false
			break
		end
	end
	if clean then
		SF.GlobalTables.Players[inst.player] = nil
	end
end)

--- Global table shared by all instances on the same side.
-- @name gtables_library.global
-- @class table

--- Player-unique global table.
-- @name gtables_library.player
-- @class table

