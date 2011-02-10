AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

local sf_soft = CreateConVar("wire_starfall_quotasoft", "13000")
local sf_hard = CreateConVar("wire_starfall_quotahard", "15000")

ENT.OverlayDelay = 0
ENT.WireDebugName = "Starfall Processor"

--[[
Starfall:

=Functions:
-Load(code)
-Error(msg)
-IncrementOps(amount)

=Variables:
-useroverlay
-ops
-ops_avg
-ops_soft
-ops_last
-errored
-inputs
-intypes
-outputs
-outtypes
-extdata

]]
function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	self.Inputs = WireLib.CreateInputs(self.Entity, {})
	self.Outputs = WireLib.CreateOutputs(self.Entity, {})
	
	self:SetOverlayText("Starfall Processor\n(No Program)")
	local r,g,b,a = self:GetColor()
	self:SetColor(255, 255, 255, a)
	
	self.ops = 0
	self.ops_last = 0
end

function ENT:Think()
	self.BaseClass.Think(self)
	self.Entity:NextThink(CurTime())
	
	if not self.errored then
		self.ops_avg = self.ops_avg * 0.95 + self.ops * 0.05
		self.ops_soft = self.ops_soft + math.max(self.ops - sf_soft:GetInt(),0)
		
		if self.ops_soft then
			self:SetOverlayText("Starfall Processor\n" .. self.name .. "\n" .. tostring(math.Round(self.ops_avg)) .. " ops, " .. tostring(math.Round(self.ops_avg / sf_soft:GetInt() * 100)) .. "% (+" .. tostring(math.Round(self.ops_soft / (sf_hard:GetInt()-sf_soft:GetInt()) * 100)).. "%)")
		else
			self:SetOverlayText("Starfall Processor\n" .. self.name .. "\n" .. tostring(math.Round(self.ops_avg)) .. " ops, " .. tostring(math.Round(self.ops_avg / sf_soft:GetInt() * 100)) .. "%")
		end
		
		
		--SFLib.ops[self.player] = SFLib.ops[self.player] - self.ops_last + self.ops
		--self.ops_last = self.ops
		self.ops = 0
	end
end

function ENT:Load(code)
	
end

function ENT:IncrementOps(amount)
	self.ops = self.ops + amount
end