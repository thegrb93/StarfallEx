AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

util.AddNetworkString("starfall_hud_set_enabled")

local vehiclelinks = SF.EntityTable("vehicleLinks")
SF.HudVehicleLinks = vehiclelinks

local IsValid = FindMetaTable("Entity").IsValid

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	self:AddEFlags( EFL_FORCE_CHECK_TRANSMIT )
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:Use(ply)
	if not IsValid(self.link) then ply:ChatPrint("This hud isn't linked to a chip!") return end
	SF.EnableHud(ply, self.link, self, not SF.IsHUDActive(self.link, ply))
end

function ENT:LinkVehicle(ent)
	if ent then
		if not vehiclelinks[ent] then vehiclelinks[ent] = {} end
		vehiclelinks[ent][self] = true
	else
		for k, huds in pairs(vehiclelinks) do
			huds[self] = nil
		end
	end
end

local function vehicleEnableHud(ply, vehicle, enabled)
	local huds = vehiclelinks[vehicle]
	if huds then
		for v in pairs(huds) do
			if IsValid(v) then
				if IsValid(v.link) then
					SF.EnableHud(ply, v.link, vehicle, enabled)
				end
			else
				huds[v] = nil
			end
		end
	end
end

hook.Add("PlayerEnteredVehicle", "Starfall_HUD", function(ply, vehicle) vehicleEnableHud(ply, vehicle, true) end)
hook.Add("PlayerLeaveVehicle", "Starfall_HUD", function(ply, vehicle) vehicleEnableHud(ply, vehicle, false) end)

function ENT:PreEntityCopy()
	if self.EntityMods then self.EntityMods.SFLink = nil end
	local info = {}
	if IsValid(self.link) then
		info.link = self.link:EntIndex()
	end
	local linkedvehicles = {}
	for k, huds in pairs(vehiclelinks) do
		if huds[self] and IsValid(k) then
			linkedvehicles[#linkedvehicles + 1] = k:EntIndex()
		end
	end
	if #linkedvehicles > 0 then
		info.linkedvehicles = linkedvehicles
	end
	if info.link or info.linkedvehicles then
		duplicator.StoreEntityModifier(self, "SFLink", info)
	end
end

function ENT:PostEntityPaste(ply, ent, CreatedEntities)
	if ent.EntityMods and ent.EntityMods.SFLink then
		local info = ent.EntityMods.SFLink
		if info.link then
			local e = CreatedEntities[info.link]
			if IsValid(e) then
				SF.LinkEnt(self, e)
			end
		end

		if info.linkedvehicles then
			for k, v in pairs(info.linkedvehicles) do
				local e = CreatedEntities[v]
				if IsValid(e) then
					self:LinkVehicle(e)
				end
			end
		end
	end
end
