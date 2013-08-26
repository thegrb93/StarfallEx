---------------------------------------------------------------------
-- SF Server Gamemode Hooks
-- Hooks onto most Server Gamemode Hooks which are of use to the users
-- And calls RunScriptHook on them so that players may use from within SF
-- Feel free to redefine how these are added
---------------------------------------------------------------------

--- GM:AllowPlayerPickup( Player player, Entity Entity )
-- Called when a player tries to pick up something using the "use" key, return to override.
hook.Add("AllowPlayerPickup", "runScriptHook_AllowPlayerPickup", function(...)

	SF.RunScriptHook("AllowPlayerPickup", ...)
end)

--- GM:PlayerDisconnected( Player ply )
-- Called when a player leaves the server
hook.Add("PlayerDisconnected", "runScriptHook_PlayerDisconnect", function(...)

	SF.RunScriptHook("PlayerDisconnected", ...)
end)


--- GM:PlayerDeath( Player ply, CTakeDamageInfo inflictor, Entity attacker )
-- Called when a player dies.
hook.Add("PlayerDeath", "runScriptHook_PlayerDeath", function(...)

	SF.RunScriptHook("PlayerDeath", ...)
end)


--- GM:PlayerInitialSpawn( Player player )
-- Called when the player spawns for the first time.
hook.Add("PlayerInitialSpawn", "runScriptHook_PlayerInitialSpawn", function(...)

	SF.RunScriptHook("PlayerInitialSpawn", ...)
end)

--- GM:PlayerLeaveVehicle( Player ply, Vehicle ent )
-- Called when a player leaves a vehicle.
hook.Add("PlayerLeaveVehicle", "runScriptHook_PlayerLeaveVehicle", function(...)

	SF.RunScriptHook("PlayerLeaveVehicle", ...)
end)

--- GM:PlayerSay( Player sender, string messageContent, boolean isTeamChat )
-- Called when a player dispatched a chat message.
hook.Add("PlayerSay", "runScriptHook_PlayerSay", function(...)

	SF.RunScriptHook("PlayerSay", ...)
end)

--- GM:PlayerSpawn( Player player )
-- Called whenever a player spawned.
hook.Add("PlayerSpawn", "runScriptHook_PlayerSpawn", function(...)

	SF.RunScriptHook("PlayerSpawn", ...)
end)

--- GM:PlayerSpray( Player sprayer )
-- Called whenever a player sprayed his logo, return true to prevent the spray.
hook.Add("PlayerSpray", "runScriptHook_PlayerSpray", function(...)

	SF.RunScriptHook("PlayerSpray", ...)
end)

--- GM:PlayerSwitchFlashlight( Player player, boolean state )
-- Called whenever a player attempts to either turn on or off their flashlight, returning false will deny the change.
hook.Add("PlayerSwitchFlashlight", "runScriptHook_PlayerSwitchFlashlight", function(...)

	SF.RunScriptHook("PlayerSwitchFlashlight", ...)
end)

--- GM:PlayerUse( Player player, Entity Entity )
-- Called when a player tries to "use" an entity.
hook.Add("PlayerUse", "runScriptHook_PlayerUse", function(...)

	SF.RunScriptHook("PlayerUse", ...)
end)
