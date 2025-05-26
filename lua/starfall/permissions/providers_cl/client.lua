--- Provides permissions for clients

local IsValid = FindMetaTable("Entity").IsValid

local P = {}
P.id = "client"
P.name = "Client Permissions"
P.settingsoptions = { "Only You", "Friends Only", "Anyone", "Disabled", "HudEnabled" }
P.defaultsetting = 3
P.overridable = true

P.checks = {
	function(instance, target, key)
		return LocalPlayer()==instance.player, "This function can only be used on the player's own chip"
	end,
	function(instance, target, key)
		local owner = instance.player
		return LocalPlayer()==owner or (IsValid(owner) and owner:GetFriendStatus()=="friend"), "This function can only be used on the player's or their friends' chips"
	end,
	"allow",
	"block",
	function(instance, target, key)
		return SF.IsHUDActive(instance.entity), "No HUD connected"
	end,
}

SF.Permissions.registerProvider(P)
