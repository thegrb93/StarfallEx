AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

SF.CreationPhysics

function ENT:Initialize()
	self.BaseClass.Initialize()
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NOCLIP) -- TODO: custom movetype hook?
	self:DrawShadow(false)

	self:SetScale(Vector(1,1,1))
	self.clips = {}
	self.lastClipUpdate = {}
end
