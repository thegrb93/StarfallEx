--- Provides permissions for entities based on CPPI if present

local P = {}
P.id = "entities"
P.name = "Entity Permissions"
P.settingsoptions = { "Owner Only", "Can Tool", "Can Physgun", "Anything" }
P.defaultsetting = 1

local function dumbtrace(ent)
	local pos = ent:GetPos()
	return {
		FractionLeftSolid = 0,
		HitNonWorld       = true,
		Fraction          = 0,
		Entity            = ent,
		HitPos            = pos,
		HitNormal         = Vector(0, 0, 0),
		HitBox            = 0,
		Normal            = Vector(1, 0, 0),
		Hit               = true,
		HitGroup          = 0,
		MatType           = 0,
		StartPos          = pos,
		PhysicsBone       = 0,
		WorldToLocal      = Vector(0, 0, 0),
	}
end

P.checks = {
	function(instance, target)
		return P.props[target]==instance.player
	end,
	function(instance, target)
		if not IsValid(target) or CLIENT then return false end
		return hook.Run("CanTool", instance.player, dumbtrace(target), "starfall_ent_lib") ~= false
	end,
	function(instance, target)
		if not IsValid(target) or CLIENT then return false end
		if hook.Run("PhysgunPickup", instance.player, target) ~= false then
			-- Some mods expect a release when there's a pickup involved.
			hook.Run("PhysgunDrop", instance.player, target)
			return true
		else
			return false
		end
	end,
	function() return true end
}

P.props = setmetatable({},{__mode="k"})

function SF.Permissions.getOwner(ent)
	return P.props[ent]
end

if SERVER then
	util.AddNetworkString("SFPPTransmit")
	
	local function PropOwn(ply,ent)
		P.props[ent] = ply
		net.Start("SFPPTransmit")
		net.WriteEntity(ply)
		net.WriteEntity(ent)
		net.Broadcast()
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
	end)]]
	
	net.Receive("SFPPTransmit", function()
		local ply, ent = net.ReadEntity(), net.ReadEntity()
		P.props[ent] = ply
	end)
end

SF.Permissions.registerProvider(P)
