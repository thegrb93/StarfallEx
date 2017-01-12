--- Provides permissions for entities based on CPPI if present

local P = {}
P.id = "usergroups"
P.name = "Usergroup Permissions"
P.settings = {}
P.settingsoptions = {"Admin Only", "Anyone", "No one"}

function P.registered ( id, name, description, arg )
	if not P.settings[ id ] then
		P.settings[ id ] = 2
	end
end

P.checks = {
	function( principal, target, key )
		return principal:IsAdmin()
	end,
	function() return true end,
	function() return false end
}

SF.Permissions.registerProvider( P )
