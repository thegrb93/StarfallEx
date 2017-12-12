--- Provides permissions for clients

local P = {}
P.id = "client"
P.name = "Client Permissions"
P.settingsoptions = { "Only You", "Friends Only", "Anyone", "No one" }
P.defaultsetting = 3

P.checks = {
	function(instance, target, key)
		return LocalPlayer()==instance.player
	end,
	function(instance, target, key)
		local owner = instance.player
		return LocalPlayer()==owner or (IsValid(owner) and owner:GetFriendStatus()=="friend")
	end,
	function() return true end,
	function() return false end
}

SF.Permissions.registerProvider(P)
