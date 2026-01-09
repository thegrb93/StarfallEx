--- Provides permissions for entities based on CPPI if present

local owneraccess
if SERVER then
	owneraccess = CreateConVar("sf_permissions_entity_owneraccess", "0", { FCVAR_ARCHIVE }, "Allows starfall chip's owner to access their player entity")
end
local cacheLifetime = CreateConVar("sf_permissions_entity_cachelife", "5", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "How long to store successful prop permission checks before checking again")

local ENT_META,PLY_META = FindMetaTable("Entity"),FindMetaTable("Player")
local Ent_GetNWEntity,Ent_GetTable,Ent_IsValid,Ent_SetNWEntity = ENT_META.GetNWEntity,ENT_META.GetTable,ENT_META.IsValid,ENT_META.SetNWEntity
local Ply_IsSuperAdmin,Ply_SteamID64 = PLY_META.IsSuperAdmin,PLY_META.SteamID64

local checkOwner, checkCanTool, checkCanPhysgun

if CPPI then
	function SF.Permissions.getOwner(ent)
		return ent:CPPIGetOwner()
	end

	if SERVER then
		function checkOwner(instance, ent)
			if ent == instance.player and owneraccess:GetBool() then return true end
			if ent:CPPIGetOwner()==instance.player then return true end
			return false, "You're not the owner of this prop"
		end
		function checkCanTool(instance, ent)
			if ent == instance.player and owneraccess:GetBool() then return true end
			if ent:CPPICanTool(instance.player, "starfall_ent_lib") then return true end
			return false, "You can't toolgun this entity"
		end
		function checkCanPhysgun(instance, ent)
			if ent == instance.player and owneraccess:GetBool() then return true end
			if ent:CPPICanPhysgun(instance.player) then return true end
			return false, "You can't physgun this entity"
		end
	else
		function checkOwner(instance, ent)
			if ent==instance.player or LocalPlayer()==instance.player then return true end
			if ent:CPPIGetOwner()==instance.player then return true end
			return false, "You're not the owner of this prop"
		end
		function checkCanTool(instance, ent)
			if ent==instance.player or LocalPlayer()==instance.player then return true end
			if ent:CPPICanTool(instance.player, "starfall_ent_lib") then return true end
			return false, "You can't toolgun this entity"
		end
		function checkCanPhysgun(instance, ent)
			if ent==instance.player or LocalPlayer()==instance.player then return true end
			if ent:CPPICanPhysgun(instance.player) then return true end
			return false, "You can't physgun this entity"
		end
		if not ENT_META.CPPICanTool then checkCanTool = checkOwner end
		if not ENT_META.CPPICanPhysgun then checkCanPhysgun = checkOwner end
	end
else
	if SERVER then
		local PropOwners = SF.EntityTable("PropProtection")
		local PropOwnersDisconnected = SF.EntityTable("PropProtectionReconnect")
		SF.PropOwners = PropOwners

		function SF.Permissions.getOwner(ent)
			return PropOwners[ent] or NULL
		end

		function checkOwner(instance, ent)
			if ent == instance.player and owneraccess:GetBool() then return true end
			if PropOwners[ent]==instance.player then return true end
			return false, "You're not the owner of this prop"
		end
		function checkCanTool(instance, ent)
			if ent == instance.player and owneraccess:GetBool() then return true end
			if hook.Run("CanTool", instance.player, SF.dumbTrace(ent), "starfall_ent_lib") ~= false then return true end
			return false, "You can't toolgun this entity"
		end
		function checkCanPhysgun(instance, ent)
			if ent == instance.player and owneraccess:GetBool() then return true end

			if hook.Run("PhysgunPickup", instance.player, ent) ~= false then
				-- Some mods expect a release when there's a pickup involved.
				hook.Run("PhysgunDrop", instance.player, ent)
				return true
			end

			return false, "You can't physgun this entity"
		end


		local function PropOwn(ply,ent)
			PropOwners[ent] = ply
			Ent_SetNWEntity(ent, "SFPP", ply)
		end

		if(cleanup) then
			local backupcleanupAdd = cleanup.Add
			function cleanup.Add(ply, enttype, ent)
				if Ent_IsValid(ent) and ply:IsPlayer() then
					PropOwn(ply, ent)
				end
				backupcleanupAdd(ply, enttype, ent)
			end
		end
		local metaply = FindMetaTable("Player")
		if(metaply.AddCount) then
			local backupAddCount = metaply.AddCount
			function metaply:AddCount(enttype, ent)
				PropOwn(self, ent)
				backupAddCount(self, enttype, ent)
			end
		end
		hook.Add("PlayerSpawnedSENT", "SFPP.PlayerSpawnedSENT", PropOwn)
		hook.Add("PlayerSpawnedVehicle", "SFPP.PlayerSpawnedVehicle", PropOwn)
		hook.Add("PlayerSpawnedSWEP", "SFPP.PlayerSpawnedSWEP", PropOwn)
		hook.Add("PlayerInitialSpawn","SFPP.PlayerInitialSpawn", function(ply)
			local steamid = Ply_SteamID64(ply)
			for k, v in pairs(PropOwnersDisconnected) do
				if v==steamid then
					PropOwn(ply,k)
				end
			end
		end)
		hook.Add("PlayerDisconnected","SFPP.PlayerDisconnected", function(ply)
			local steamid = Ply_SteamID64(ply)
			for k, v in pairs(PropOwners) do
				if v==ply then
					PropOwnersDisconnected[k] = steamid
					PropOwners[k] = nil
				end
			end
		end)

	else
		function SF.Permissions.getOwner(ent)
			return Ent_GetTable(ent).SFHoloOwner or Ent_GetNWEntity(ent, "SFPP")
		end

		function checkOwner(instance, ent)
			if ent==instance.player or LocalPlayer()==instance.player then return true end
			if Ent_GetNWEntity(ent, "SFPP")==instance.player or Ent_GetTable(ent).SFHoloOwner==instance.player then return true end
			return false, "You're not the owner of this prop"
		end
		checkCanTool = checkOwner
		checkCanPhysgun = checkOwner
	end
end

local overridesMeta = {__mode = "k"}

local EntityPermissionCache = {
	__index = {
		checkNormal = function(self, instance, ent, checkfunc)
			local t = CurTime()
			if t < self.timeout then return true end

			local result, reason = checkfunc(instance, ent)
			if result then self.timeout = t + cacheLifetime:GetFloat() end
			return result, reason
		end,
		checkOverrides = function(self, instance, ent, checkfunc)
			local t = CurTime()
			if t < self.timeout then return true end

			if table.IsEmpty(self.overrides) then
				self.check = self.checkNormal
				return self:check(instance, ent, checkfunc)
			end
			local result, reason
			for overrideInst in pairs(self.overrides) do
				result, reason = checkfunc(overrideInst, ent)
				if result then self.timeout = t + cacheLifetime:GetFloat() return true end
				self.overrides[overrideInst] = nil
			end
			return result, reason
		end,
		addOverride = function(self, instance)
			self.overrides[instance] = true
			self.check = self.checkOverrides
		end,
		removeOverride = function(self, instance)
			self.overrides[instance] = nil
			if table.IsEmpty(self.overrides) then
				self.check = self.checkNormal
			end
		end
	},
	__call = function(t)
		local ret = setmetatable({
			timeout = 0,
			overrides = setmetatable({}, overridesMeta)
		}, t)
		ret.check = ret.checkNormal
		return ret
	end
}
setmetatable(EntityPermissionCache, EntityPermissionCache)

local cacheMeta = {__mode="k", __index = function(t,k) local r=EntityPermissionCache() t[k]=r return r end}

local entPermCaches = SF.EntityTable("entPermCache")
getmetatable(entPermCaches).__index = function(t, k) local r=setmetatable({}, cacheMeta) t[k]=r return r end

local function check(instance, ent, checkfunc)
	if not Ent_IsValid(ent) then return false, "Entity is invalid" end
	if Ply_IsSuperAdmin(instance.player) then return true end
	return entPermCaches[ent][instance]:check(instance, ent, checkfunc)
end

SF.Permissions.registerProvider({
	id = "entities",
	name = "Entity Permissions",
	settingsoptions = { "Owner Only", "Can Tool", "Can Physgun", "Anything" },
	defaultsetting = 2,
	checks = {
		function(instance, ent)
			return check(instance, ent, checkOwner)
		end,
		function(instance, ent)
			return check(instance, ent, checkCanTool)
		end,
		function(instance, ent)
			return check(instance, ent, checkCanPhysgun)
		end,
		"allow"
	}
})

