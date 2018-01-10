--- Provides permissions for entities based on CPPI if present

local P = {}
P.id = "entities"
P.name = "Entity Permissions"
P.settingsoptions = { "Owner Only", "Can Tool", "Can Physgun", "Anything" }
P.defaultsetting = 1

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

if SERVER then
	P.checks = {
		function(instance, target)
			if IsValid(target) then
				if instance.player:IsSuperAdmin() then return true end
				return P.props[target]==instance.player
			else
				return false
			end
		end,
		function(instance, target)
			if IsValid(target) then
				local pos = target:GetPos()
				dumbtrace.Entity = target		
				return hook.Run("CanTool", instance.player, dumbtrace, "starfall_ent_lib") ~= false
			else
				return false
			end
		end,
		function(instance, target)
			if IsValid(target) then
				if hook.Run("PhysgunPickup", instance.player, target) ~= false then
					-- Some mods expect a release when there's a pickup involved.
					hook.Run("PhysgunDrop", instance.player, target)
					return true
				else
					return false
				end
			else
				return false
			end
		end,
		function() return true end
	}
else
	P.checks = {
		function(instance, target)
			if IsValid(target) then
				if instance.player:IsSuperAdmin() then return true end
				return target:GetNWEntity("SFPP")==instance.player
			else
				return false
			end
		end,
		function() return false end,
		function() return false end,
		function() return true end
	}
end

if SERVER then
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
	
	--[[net.Receive("SFPPTransmit", function(len, pl)
		local e = net.ReadEntity()
		if P.props[e] then
			net.Start("SFPPTransmit")
			net.WriteEntity(P.props[e])
			net.WriteEntity(e)
			net.Send(pl)
		end
	end)]]
else
	--[[hook.Add("NetworkEntityCreated", "SFPP.RequestOwner", function(ent)
		net.Start("SFPPTransmit")
		net.WriteEntity(ent)
		net.SendToServer()
	end)
	
	net.Receive("SFPPTransmit", function()
		local ply, ent = net.ReadEntity(), net.ReadEntity()
		P.props[ent] = ply
	end)]]
	
	function SF.Permissions.getOwner(ent)
		return ent:GetNWEntity("SFPP")
	end
end

SF.Permissions.registerProvider(P)
