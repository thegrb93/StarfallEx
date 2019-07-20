--- Provides permissions for entities based on CPPI if present

local isentity = isentity

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
					if isentity(target) and target:IsValid() then
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
					if isentity(target) and target:IsValid() then
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
					if isentity(target) and target:IsValid() then
						if target:CPPICanPhysgun(instance.player) then
							return true
						else
							return false, "You can't physgun this entity"
						end
					else
						return false, "Entity is invalid"
					end
				end,
				function() return true end
			}
		else
			P.checks = {
				function(instance, target)
					if isentity(target) and target:IsValid() then
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
					if isentity(target) and target:IsValid() then
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
					if isentity(target) and target:IsValid() then
						if target:CPPICanPhysgun(instance.player) then
							return true
						else
							return false, "You can't physgun this entity"
						end
					else
						return false, "Entity is invalid"
					end
				end,
				function() return true end
			}
			local entmeta = FindMetaTable("Entity")
			if not entmeta.CPPICanTool then P.checks[2] = P.checks[1] end
			if not entmeta.CPPICanPhysgun then P.checks[3] = P.checks[1] end
		end
	else
		if SERVER then
			local dumbtrace = {
				FractionLeftSolid = 0,
				HitNonWorld       = true,
				Fraction          = 0,
				Entity            = NULL,
				HitPos            = Vector(0, 0, 0),
				HitNormal         = Vector(0, 0, 0),
				HitBox            = 0,
				Normal            = Vector(1, 0, 0),
				Hit               = true,
				HitGroup          = 0,
				MatType           = 0,
				StartPos          = Vector(0, 0, 0),
				PhysicsBone       = 0,
				WorldToLocal      = Vector(0, 0, 0),
			}
			P.checks = {
				function(instance, target)
					if isentity(target) and target:IsValid() then
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
					if isentity(target) and target:IsValid() then
						local pos = target:GetPos()
						dumbtrace.Entity = target
						if hook.Run("CanTool", instance.player, dumbtrace, "starfall_ent_lib") ~= false then
							return true
						else
							return false, "Target doesn't have toolgun access"
						end
					else
						return false, "Entity is invalid"
					end
				end,
				function(instance, target)
					if isentity(target) and target:IsValid() then
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
				function() return true end
			}

			P.props = setmetatable({},{__mode="k"})
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
					if (ent and ent:IsValid()) and ply:IsPlayer() then
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
					if isentity(target) and target:IsValid() then
						if instance.player == target or LocalPlayer()==instance.player or instance.player:IsSuperAdmin() then return true end
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
				function() return true end
			}
			P.checks[2] = P.checks[1]
			P.checks[3] = P.checks[1]

			function SF.Permissions.getOwner(ent)
				return ent.SFHoloOwner or ent:GetNWEntity("SFPP")
			end
		end
	end
end)
