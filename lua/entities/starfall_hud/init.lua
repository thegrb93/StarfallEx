AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

util.AddNetworkString("starfall_hud_set_enabled")

local vehiclelinks = SF.EntityTable("vehicleLinks")
SF.HudVehicleLinks = vehiclelinks

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	self.enabled = false
	self:AddEFlags( EFL_FORCE_CHECK_TRANSMIT )
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:SetHudEnabled(ply, enabled)
	self.enabled = enabled

	net.Start("starfall_hud_set_enabled")
		net.WriteEntity(self)
		net.WriteInt(enabled, 8)
	net.Send(ply)

	local function connect()
		if (self.link and self.link:IsValid()) then
			local instance = self.link.instance
			if instance then
				instance:runScriptHook("hudconnected", instance.WrapObject(self))
			end
			
			if self.locksControls then
				net.Start("starfall_lock_control")
					net.WriteEntity(self.link)
					net.WriteBool(true)
				net.Send(ply)
			end
		end
	end

	local function disconnect()
		if (self.link and self.link:IsValid()) then
			local instance = self.link.instance
			if instance then
				instance:runScriptHook("huddisconnected", instance.WrapObject(self))
			end

			if self.locksControls then
				net.Start("starfall_lock_control")
					net.WriteEntity(self.link)
					net.WriteBool(false)
				net.Send(ply)
			end
		end
		ply:SetViewEntity()
	end

	if enabled then
		connect()
	else
		disconnect()
	end
end

function ENT:Use(ply)
	if not (self.link and self.link:IsValid()) then ply:ChatPrint("This hud isn't linked to a chip!") return end
	self:SetHudEnabled(ply, not self.enabled)
end

function ENT:LinkVehicle(ent)
	if ent then
		vehiclelinks[ent] = self
	else
		--Clear links
		for k, v in pairs(vehiclelinks) do
			if self == v then
				vehiclelinks[k] = nil
			end
		end
	end
end

hook.Add("PlayerEnteredVehicle", "Starfall_HUD_PlayerEnteredVehicle", function(ply, vehicle)
	for k, v in pairs(vehiclelinks) do
		if vehicle == k and v:IsValid() then
			vehicle:CallOnRemove("remove_sf_hud"..v:EntIndex(), function()
				if v:IsValid() and ply:IsValid() then
					v:SetHudEnabled(ply, 0)
				end
			end)
			v:SetHudEnabled(ply, 1)
		end
	end
end)

hook.Add("PlayerLeaveVehicle", "Starfall_HUD_PlayerLeaveVehicle", function(ply, vehicle)
	for k, v in pairs(vehiclelinks) do
		if vehicle == k and v:IsValid() then
			v:SetHudEnabled(ply, 0)
		end
	end
end)

function ENT:PreEntityCopy()
	if self.EntityMods then self.EntityMods.SFLink = nil end
	local info = {}
	if (self.link and self.link:IsValid()) then
		info.link = self.link:EntIndex()
	end
	local linkedvehicles = {}
	for k, v in pairs(vehiclelinks) do
		if v == self and k:IsValid() then
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
			if (e and e:IsValid()) then
				SF.LinkEnt(self, e)
			end
		end

		if info.linkedvehicles then
			for k, v in pairs(info.linkedvehicles) do
				local e = CreatedEntities[v]
				if (e and e:IsValid()) then
					self:LinkVehicle(e)
				end
			end
		end
	end
end
