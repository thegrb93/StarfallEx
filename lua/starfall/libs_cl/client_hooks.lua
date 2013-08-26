---------------------------------------------------------------------
-- SF Client Gamemode Hooks
-- Hooks onto most Client Gamemode Hooks which are of use to the users
-- And calls RunScriptHook on them so that players may use from within SF
-- Feel free to redefine how these are added
--
-- NOTE: Currently not working as clientside SF func/hooks calls appear
-- 		 to be broken
--
---------------------------------------------------------------------

--- GM:FinishChat( )
-- Runs when user cancels/finishes typing.
hook.Add("FinishChat", "runScriptHook_FinishChat", function(...)

	print("DIE YOU WHORE!")
	SF.RunScriptHook("FinishChat", ...)
end)

-- Look into how to get RunScriptHook working from the client :/