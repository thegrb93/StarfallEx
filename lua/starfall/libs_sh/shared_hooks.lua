---------------------------------------------------------------------
-- SF Shared Gamemode Hooks
-- Hooks onto most Shared Gamemode Hooks which are of use to the users
-- And calls RunScriptHook on them so that players may use from within SF
-- Feel free to redefine how these are added
---------------------------------------------------------------------

--- GM:EndEntityDriving( Entity ent, Player ply )
-- Called right before an entity stops driving. Overriding this hook will cause it to not call drive/End and the player will not stop driving.
hook.Add("EndEntityDriving", "runScriptHook_EndEntityDriving", function(...)

	SF.RunScriptHook("EndEntityDriving", ...)
end)

--- GM:EntityRemoved( Entity ent )
-- Called right before the removal of an entity.
hook.Add("EntityRemoved", "runScriptHook_EntityRemoved", function(...)

	SF.RunScriptHook("EntityRemoved", ...)
end)

--- GM:FinishMove( Player ply, CMoveData moveData )
-- Called after Move.
hook.Add("FinishMove", "runScriptHook_FinishMove", function(...)

	SF.RunScriptHook("FinishMove", ...)
end)

--- GM:GrabEarAnimation( Player ply )
-- Called when a player opens chat and grabs their ear
--- TODO DOESN'T APPEAR TO WORK
hook.Add("GrabEarAnimation", "runScriptHook_GrabEarAnimation", function(...)

	SF.RunScriptHook("GrabEarAnimation", ...)
end)

--- GM:KeyRelease( Entity player, number key )
-- Runs when a IN key was released by a player.
--- TODO REMOVE AS POTENTIALLY VERY ABUSIVE
hook.Add("KeyRelease", "runScriptHook_KeyRelease", function(...)

	SF.RunScriptHook("KeyRelease", ...)
end)

--- GM:MouthMoveAnimation( Player ply )
-- Called when a player uses voice chat and moves their mouth
--- TODO DOESN'T APPEAR TO WORK
hook.Add("MouthMoveAnimation", "runScriptHook_MouthMoveAnimation", function(...)

	SF.RunScriptHook("MouthMoveAnimation", ...)
end)

--- GM:OnEntityCreated( Entity entity )
-- Called right after the Entity has been made visible to Lua.
hook.Add("OnEntityCreated", "runScriptHook_OnEntityCreated", function(...)

	SF.RunScriptHook("OnEntityCreated", ...)
end)

--- GM:PlayerConnect( string name, string ip )
-- commands to run when a player connects
hook.Add("PlayerConnect", "runScriptHook_PlayerConnect", function(...)

	SF.RunScriptHook("PlayerConnect", ...)
end)

--- GM:PlayerHurt( Player victim, Entity attacker, number healthRemaining, number damageTaken )
-- Called when a player gets hurt.
hook.Add("PlayerHurt", "runScriptHook_PlayerHurt", function(...)

	SF.RunScriptHook("PlayerHurt", ...)
end)

--- GM:PlayerNoClip( )
-- Called when a player tries to switch noclip mode
hook.Add("PlayerNoClip", "runScriptHook_PlayerNoClip", function(...)

	SF.RunScriptHook("PlayerNoClip", ...)
end)

--- GM:StartEntityDriving( Entity ent, Player ply )
-- Called right before an entity starts driving. Overriding this hook will cause it to not call drive/Start and the player will not begin driving the entity.
hook.Add("StartEntityDriving", "runScriptHook_StartEntityDriving", function(...)

	SF.RunScriptHook("StartEntityDriving", ...)
end)