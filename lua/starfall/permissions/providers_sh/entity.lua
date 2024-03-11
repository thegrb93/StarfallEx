--- Provides permissions for entities based on CPPI if present

local IsValid = FindMetaTable("Entity").IsValid


local owneraccess
if SERVER then
	owneraccess = CreateConVar("sf_permissions_entity_owneraccess", "0", { FCVAR_ARCHIVE }, "Allows starfall chip's owner to access their player entity")
end

local P = {}
P.id = "entities"
P.name = "Entity Permissions"
P.settingsoptions = { "Owner Only", "Can Tool", "Can Physgun", "Anything" }
P.defaultsetting = 2
local truefunc = function() return true end
P.checks = {truefunc, truefunc, truefunc, truefunc}
SF.Permissions.registerProvider(P)

hook.Add("Initialize","SF_PPInitialize",function()
	if CPPI then
		function SF.Permissions.getOwner(ent)
			return ent:CPPIGetOwner()
		end

		if SERVER then
			P.checks = {
				function(instance, target)
					if IsValid(target) then
						if target == instance.player and owneraccess:GetBool() then return true end
						if instance.player:IsSuperAdmin() then return true end
						if target:CPPIGetOwner()==instance.player then
							return true
						else
							return false, "You're not the owner of this prop"
						end
					else
						return false, "Entity is invalid"
					end
				end,
				function(instance, target)
					if IsValid(target) then
						if target == instance.player and owneraccess:GetBool() then return true end
						if target:CPPICanTool(instance.player, "starfall_ent_lib") then
							return true
						else
							return false, "You can't toolgun this entity"
						end
					else
						return false, "Entity is invalid"
					end
				end,
				function(instance, target)
					if IsValid(target) then
						if target == instance.player and owneraccess:GetBool() then return true end
						if target:CPPICanPhysgun(instance.player) then
							return true
						else
							return false, "You can't physgun this entity"
						end
					else
						return false, "Entity is invalid"
					end
				end,
				"allow"
			}
		else
			P.checks = {
				function(instance, target)
					if IsValid(target) then
						if target==instance.player or LocalPlayer()==instance.player or instance.player:IsSuperAdmin() then return true end
						if target:CPPIGetOwner()==instance.player then
							return true
						else
							return false, "You're not the owner of this prop"
						end
					else
						return false, "Entity is invalid"
					end
				end,
				function(instance, target)
					if IsValid(target) then
						if target==instance.player or LocalPlayer()==instance.player or instance.player:IsSuperAdmin() then return true end
						if target:CPPICanTool(instance.player, "starfall_ent_lib") then
							return true
						else
							return false, "You can't toolgun this entity"
						end
					else
						return false, "Entity is invalid"
					end
				end,
				function(instance, target)
					if IsValid(target) then
						if target==instance.player or LocalPlayer()==instance.player or instance.player:IsSuperAdmin() then return true end
						if target:CPPICanPhysgun(instance.player) then
							return true
						else
							return false, "You can't physgun this entity"
						end
					else
						return false, "Entity is invalid"
					end
				end,
				"allow"
			}
			local entmeta = FindMetaTable("Entity")
			if not entmeta.CPPICanTool then P.checks[2] = P.checks[1] end
			if not entmeta.CPPICanPhysgun then P.checks[3] = P.checks[1] end
		end
	else
		if SERVER then
			P.checks = {
				function(instance, target)
					if IsValid(target) then
						if target == instance.player and owneraccess:GetBool() then return true end
						if instance.player:IsSuperAdmin() then return true end
						if P.props[target]==instance.player then
							return true
						else
							return false, "You're not the owner of this prop"
						end
					else
						return false, "Entity is invalid"
					end
				end,
				function(instance, target)
					if IsValid(target) then
						if target == instance.player and owneraccess:GetBool() then return true end
						local pos = target:GetPos()
						if hook.Run("CanTool", instance.player, SF.dumbTrace(target), "starfall_ent_lib") ~= false then
							return true
						else
							return false, "Target doesn't have toolgun access"
						end
					else
						return false, "Entity is invalid"
					end
				end,
				function(instance, target)
					if IsValid(target) then
						if target == instance.player and owneraccess:GetBool() then return true end
						if hook.Run("PhysgunPickup", instance.player, target) ~= false then
							-- Some mods expect a release when there's a pickup involved.
							hook.Run("PhysgunDrop", instance.player, target)
							return true
						else
							return false, "Target doesn't have physgun access"
						end
					else
						return false, "Entity is invalid"
					end
				end,
				"allow"
			}

			P.props = SF.EntityTable("PropProtection")
			function SF.Permissions.getOwner(ent)
				return P.props[ent] or NULL
			end

			local function PropOwn(ply,ent)
				P.props[ent] = ply
				ent:SetNWEntity("SFPP", ply)
			end

			if(cleanup) then
				local backupcleanupAdd = cleanup.Add
				function cleanup.Add(ply, enttype, ent)
					if IsValid(ent) and ply:IsPlayer() then
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
				local steamid = ply:SteamID64()
				for k, v in pairs(P.props) do
					if v==steamid then
						PropOwn(ply,k)
					end
				end
			end)
			hook.Add("PlayerDisconnected","SFPP.PlayerDisconnected", function(ply)
				local steamid = ply:SteamID64()
				for k, v in pairs(P.props) do
					if v==ply then
						P.props[k] = steamid
					end
				end
			end)

		else
			P.checks = {
				function(instance, target)
					if IsValid(target) then
						if target==instance.player or LocalPlayer()==instance.player or instance.player:IsSuperAdmin() then return true end
						local owner = target:GetNWEntity("SFPP")
						if owner ~= NULL then
							if owner==instance.player then
								return true
							else
								return false, "You're not the owner of this prop"
							end
						else
							return false, "The entity's owner hasn't been transmitted yet or doesn't exist"
						end
					else
						return false, "Entity is invalid"
					end
				end,
				nil,
				nil,
				"allow"
			}
			P.checks[2] = P.checks[1]
			P.checks[3] = P.checks[1]

			function SF.Permissions.getOwner(ent)
				return ent.SFHoloOwner or ent:GetNWEntity("SFPP")
			end
		end
	end
	
	for privilegeid, privilege in pairs(SF.Permissions.privileges) do
		if privilege.providerconfig.entities then
			privilege:buildcheck()
		end
	end
end)
