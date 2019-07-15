AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self.BaseClass.Initialize()
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NOCLIP)
	self:DrawShadow(false)

	self.update = false
	self.updateScale = false
	self.updateSuppressEngineLighting = false
end

util.AddNetworkString("starfall_hologram")

function ENT:SetScale(scale)
	self.update = true
	self.updateScale = true
	self.scale = scale
end

function ENT:SetSuppressEngineLighting(suppress)
	self.update = true
	self.updateSuppressEngineLighting = true
	self.suppressEngineLighting = suppress
end

function ENT:Think()
	if self.update then
		self.update = false

		net.Start("starfall_hologram")
		net.WriteUInt(self:EntIndex(), 16)
		if self.updateScale then
			self.updateScale = false
			net.WriteBool(true)
			net.WriteVector(self.scale)
		else
			net.WriteBool(false)
		end

		if self.updateSuppressEngineLighting then
			self.updateSuppressEngineLighting = false
			net.WriteBool(true)
			net.WriteBool(self.suppressEngineLighting)
		else
			net.WriteBool(false)
		end
		net.Broadcast()
	end
end

net.Receive("starfall_hologram", function(len, ply)
	local self = net.ReadEntity()
	if self:IsValid() and self.IsSFHologram then
		net.Start("starfall_hologram")
		net.WriteUInt(16, self:EntIndex())
		if self.scale then
			net.WriteBool(true)
			net.WriteVector(self.scale)
		else
			net.WriteBool(false)
		end

		if self.suppressEngineLighting then
			net.WriteBool(true)
			net.WriteBool(self.suppressEngineLighting)
		else
			net.WriteBool(false)
		end
		net.Send(ply)
	end
end)

