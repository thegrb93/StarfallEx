---------------------------------------------------------------------
-- SF Shared Gamemode Hooks
-- Hooks onto most Shared Gamemode Hooks which are of use to the users
-- And calls RunScriptHook on them so that players may use from within SF
-- Feel free to redefine how these are added
---------------------------------------------------------------------

local wrap = SF.Entities.Wrap
local unpack = unpack

--- GM:EndEntityDriving( Entity ent, Player ply )
-- Called right before an entity stops driving. Overriding this hook will cause it to not call drive/End and the player will not stop driving.
hook.Add("EndEntityDriving", "runScriptHook_EndEntityDriving", function( e, p)
	local args = {}
	args[1] = wrap(e)
	args[2] = wrap(p)

	SF.RunScriptHook("EndEntityDriving", unpack( args ) )
end)

--- GM:EntityRemoved( Entity ent )
-- Called right before the removal of an entity.
hook.Add("EntityRemoved", "runScriptHook_EntityRemoved", function(e)

	SF.RunScriptHook("EntityRemoved", wrap(e) )
end)

--- GM:OnEntityCreated( Entity entity )
-- Called right after the Entity has been made visible to Lua.
hook.Add("OnEntityCreated", "runScriptHook_OnEntityCreated", function(e)

	SF.RunScriptHook("OnEntityCreated", wrap(e) )
end)

--- GM:PlayerHurt( Player victim, Entity attacker, number healthRemaining, number damageTaken )
-- Called when a player gets hurt.
hook.Add("PlayerHurt", "runScriptHook_PlayerHurt", function( v, a, h, d)
	local args = {}
	args[1] = wrap(v)
	args[2] = wrap(a)
	args[3] = h
	args[4] = d

	SF.RunScriptHook("PlayerHurt", unpack( args ) )
end)

--- GM:PlayerNoClip( )
-- Called when a player tries to switch noclip mode
hook.Add("PlayerNoClip", "runScriptHook_PlayerNoClip", function(p,b)
	local args = { wrap(p), b}

	SF.RunScriptHook("PlayerNoClip", unpack( args ) )
end)

--- GM:StartEntityDriving( Entity ent, Player ply )
-- Called right before an entity starts driving. Overriding this hook will cause it to not call drive/Start and the player will not begin driving the entity.
hook.Add("StartEntityDriving", "runScriptHook_StartEntityDriving", function(e, p)
	local args = { wrap(e), wrap(p) }

	SF.RunScriptHook("StartEntityDriving", unpack( args ) )
end)