
--[[

SF Entity
{
	Inputs
	Outputs
	context
	player
}

]]

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	self.Inputs = WireLib.CreateInputs(self, {})
	self.Outputs = WireLib.CreateOutputs(self, {})
	
	self:SetOverlayText("Starfall\n(none)")
	local r,g,b,a = self:GetColor()
	self:SetColor(255, 0, 0, a)
end

function ENT:OnRestore()
end

function ENT:Compile(code)
	local ok, context = SF_Compiler.Compile(code,self.player,self)
	if not ok then
		ErrorNoHalt(context.."\n")
		WireLib.ClientError(context, self.player)
		return
	end
	
	self.context = context
	context.data.inputs = {}
	context.data.inputVals = {}
	context.data.outputs = {}
	local ok, msg = SF_Compiler.RunStarfallFunction(self.context, self.context.func)
	if not ok then
		ErrorNoHalt(msg.."\n")
		WireLib.ClientError(msg, self.player)
		return
	end
end

function ENT:SendCode(ply, code)
	if ply ~= self.player then return end
	self:Compile(code)
end

function ENT:Think()
	self.BaseClass.Think(self)
	self:NextThink(CurTime())
	
	if self.context then
		if self.context.environment.think and type(self.context.environment.think) == "function" then
			local ok, msg = SF_Compiler.RunStarfallFunction(self.context, self.context.environment.think)
			if not ok then
				ErrorNoHalt(msg.."\n")
				WireLib.ClientError(msg, self.player)
			end
		end
	end
	
	return true
end

function ENT:TriggerInput(key, value)
	self.context.data.inputVals[key] = value
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID, GetConstByID)
	self.BaseClass.ApplyDupeInfo(self, ply, ent, info, GetEntByID, GetConstByID)
end