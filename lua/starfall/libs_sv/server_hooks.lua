---------------------------------------------------------------------
-- SF Server Gamemode Hooks
-- Hooks onto most Server Gamemode Hooks which are of use to the users
-- And calls RunScriptHook on them so that players may use from within SF
-- Feel free to redefine how these are added
---------------------------------------------------------------------

local wrap = SF.Entities.Wrap
local unpack = unpack

--- GM:AllowPlayerPickup( Player player, Entity Entity )
-- Called when a player tries to pick up something using the "use" key, return to override.
hook.Add("AllowPlayerPickup", "runScriptHook_AllowPlayerPickup", function(p, e)
	local args = { wrap(p), wrap(e) }

	SF.RunScriptHook("AllowPlayerPickup", unpack( args ) )
end)

--- GM:PlayerDisconnected( Player ply )
-- Called when a player leaves the server
hook.Add("PlayerDisconnected", "runScriptHook_PlayerDisconnect", function(p)

	SF.RunScriptHook("PlayerDisconnected", wrap(p) )
end)


--- GM:PlayerDeath( Player ply, CTakeDamageInfo inflictor, Entity attacker )
-- Called when a player dies.
hook.Add("PlayerDeath", "runScriptHook_PlayerDeath", function(p, i, a)
	local args = { wrap(p), wrap(i), wrap(a) }

	SF.RunScriptHook("PlayerDeath", unpack( args ) )
end)


--- GM:PlayerInitialSpawn( Player player )
-- Called when the player spawns for the first time.
hook.Add("PlayerInitialSpawn", "runScriptHook_PlayerInitialSpawn", function(p)

	SF.RunScriptHook("PlayerInitialSpawn", wrap(p) )
end)

--- GM:PlayerLeaveVehicle( Player ply, Vehicle ent )
-- Called when a player leaves a vehicle.
hook.Add("PlayerLeaveVehicle", "runScriptHook_PlayerLeaveVehicle", function(p, e)
	local args = { wrap(p), wrap(e) }

	SF.RunScriptHook("PlayerLeaveVehicle", unpack( args ) )
end)

--- GM:PlayerSay( Player sender, string messageContent, boolean isTeamChat )
-- Called when a player dispatched a chat message.
hook.Add("PlayerSay", "runScriptHook_PlayerSay", function(s, m, b)
	local args = { wrap(s), m, b }

	SF.RunScriptHook("PlayerSay", unpack( args ) )
end)

--- GM:PlayerSpawn( Player player )
-- Called whenever a player spawned.
hook.Add("PlayerSpawn", "runScriptHook_PlayerSpawn", function(p)

	SF.RunScriptHook("PlayerSpawn", wrap(p) )
end)

--- GM:PlayerSpray( Player sprayer )
-- Called whenever a player sprayed his logo, return true to prevent the spray.
hook.Add("PlayerSpray", "runScriptHook_PlayerSpray", function(s)

	SF.RunScriptHook("PlayerSpray", wrap(s) )
end)

--- GM:PlayerSwitchFlashlight( Player player, boolean state )
-- Called whenever a player attempts to either turn on or off their flashlight, returning false will deny the change.
hook.Add("PlayerSwitchFlashlight", "runScriptHook_PlayerSwitchFlashlight", function(p, b)

	local args = { wrap(p), b }

	SF.RunScriptHook("PlayerSwitchFlashlight", unpack( args ) )
end)

--- GM:PlayerUse( Player player, Entity Entity )
-- Called when a player tries to "use" an entity.
hook.Add("PlayerUse", "runScriptHook_PlayerUse", function(p, e)
	local args = { wrap(p), wrap(e) }

	SF.RunScriptHook("PlayerUse", unpack( args ) )
end)
