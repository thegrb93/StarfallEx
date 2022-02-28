--- Provides permissions for hud enabling

local P = {}
P.id = "enablehud"
P.name = "Enable Hud Permissions"
P.settingsoptions = { "Only in vehicle", "Anytime" }
P.defaultsetting = 1

P.checks = {
	function(instance, vehicle, key)
		if vehicle:IsValid() and SF.Permissions.getOwner(vehicle)==instance.player then
			return true
		else
			return false, "Player must be sitting in owner's vehicle or be owner of the chip!"
		end
	end,
	"allow"
}

SF.Permissions.registerProvider(P)
