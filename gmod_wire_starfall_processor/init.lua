AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

CreateConVar("wire_starfall_unlimited", "0")
CreateConVar("wire_starfall_quotasoft", "5000")
CreateConVar("wire_starfall_quotahard", "100000")
CreateConVar("wire_starfall_quotatick", "25000")

ENT.OverlayDelay = 0
ENT.WireDebugName = "Starfall Processor"

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	self.Inputs = WireLib.CreateInputs(self.Entity, {})
	self.Outputs = WireLib.CreateOutputs(self.Entity, {})
	
	self:SetOverlayText("Starfall Processor\n(No Program)")
	local r,g,b,a = self:GetColor()
	self:SetColor(255, 255, 255, a)
end

function ENT:Execute()
	
end

function ENT:Load(code)
	
end