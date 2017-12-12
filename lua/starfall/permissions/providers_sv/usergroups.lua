--- Provides permissions for usergroups

local P = {}
P.id = "usergroups"
P.name = "Usergroup Permissions"
P.settingsoptions = { "Admin Only", "Anyone", "No one" }
P.defaultsetting = 2

P.checks = {
	function(instance, target, key)
		return instance.player:IsAdmin()
	end,
	function() return true end,
	function() return false end
}

SF.Permissions.registerProvider(P)
