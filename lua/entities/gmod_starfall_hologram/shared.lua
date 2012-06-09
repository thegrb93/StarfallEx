ENT.Type            = "anim"
ENT.Base            = "base_anim"

ENT.PrintName       = "Starfall Hologram"
ENT.Author          = "Starfall Organization"

ENT.Spawnable       = false
ENT.AdminSpawnable  = false

function ENT:HoloSetOwner(ply)
	self:SetNWEntity("Owner", ply)
end

function ENT:HoloGetOwner()
	return self:GetNWEntity("Owner")
end
