--- Provides permissions for clients

local P = {}
P.id = "whitelist"
P.name = "Whitelist"
P.settingsoptions = { "Enabled", "Disabled" }
P.defaultsetting = 1

P.checks = {
	function(instance, target, key)
		return SF.CheckUrl(target)
	end,
	function() return true end,
}

SF.Permissions.registerProvider(P)
