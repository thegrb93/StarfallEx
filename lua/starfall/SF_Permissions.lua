-- Permissions system for Starfall

-- Developers should hook these functions for their own use.

SF_Permissions = SF_Permissions or {}

--------------------------------- Access Permissions ---------------------------------

-- Attempt to affect an entity's state (applyForce, etc)
function SF_Permissions.CanModifyEntity(ent)
	local ply = SF_Compiler.currentChip.ply
	
	if not SF_Entities.IsValid(ent) then return false end
	if ply:IsSuperAdmin() then return true end
	
	local owner = SF_Entities.GetOwner(ent)
	if not SF_Entities.IsValid(owner) then return false end
	if owner == ply then return true end
	
	if _R.Player.CPPIGetFriends then
		local friends = owner:CPPIGetFriends()
		if type( friends ) != "table" then return false end

		for _,friend in pairs(friends) do
			if ply == friend then return true end
		end
	end
	
	return false
end

-- Attempt to load a module
function SF_Permissions.CanLoadModule(name)
	return true
end
