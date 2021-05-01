--- Provides permissions for usergroups

local P = {}
P.id = "usergroups"
P.name = "Usergroup Permissions"
P.settingsoptions = { "Admin Only", "Anyone", "No one" }
P.defaultsetting = 2

P.checks = {
	function(instance, target, key)
		local ply = instance.player:Get()
		return ply:IsValid() and ply:IsAdmin(), "This function is admin only"
	end,
	"allow",
	"block"
}

SF.Permissions.registerProvider(P)
