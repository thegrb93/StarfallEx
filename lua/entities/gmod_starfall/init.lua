
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
	
	self:SetOverlayText("Starfall\nInactive (No code)")
	local r,g,b,a = self:GetColor()
	self:SetColor(255, 0, 0, a)
end

function ENT:OnRestore()
end

function ENT:Compile(task)
	if self.context and not self.error then
		SF_Compiler.RunInternalHook("deinit",self.context,false)
	end
	
	self.error = false
	self.context = SF_Compiler.CreateContext(self, self.player, task.includes, task.mainpath)
	
	self.context.data.inputs = {}
	self.context.data.outputs = {}
	
	SF_Compiler.RunInternalHook("init",self.context)
	
	SF_Compiler.RunInternalHook("preexec",self.context,nil)
	local ok, msg = SF_Compiler.Compile(self)
	SF_Compiler.RunInternalHook("postexec",self.context,msg)
	
	if not ok then
		self:Error(msg)
		return
	end
	
	self:SetOverlayText("Starfall\nActive")
end

function ENT:SendCode(ply, task)
	if ply ~= self.player then return end
	self:Compile(task)
end

function ENT:Think()
	self.BaseClass.Think(self)
	self:NextThink(CurTime())
	
	self:RunHook("Think")
	
	return true
end

function ENT:Error(msg)
	self.error = true
	if self.context then
		SF_Compiler.RunInternalHook("deinit",self.context,true,msg)
	end
	ErrorNoHalt(msg.." (from processor of "..self.player:Nick()..")\n")
	WireLib.ClientError(msg, self.player)
	self:SetOverlayText("Starfall\nInactive (Error)")
end

function ENT:OnRemove()
	if not self.error or not self.context then
		SF_Compiler.RunInternalHook("deinit",self.context,false)
	end
	self.error = true
	self.context = nil
end

function ENT:RunHook(name, ...)
	if not self.context or self.error then return end
	
	SF_Compiler.RunInternalHook("preexec",self.context,name)
	local ok, msg = SF_Compiler.CallHook(name, self.context, ...)
	SF_Compiler.RunInternalHook("postexec",self.context,name)
	if ok == false then
		self:Error(msg)
	end
	return msg
end

function ENT:TriggerInput(key, value)
	SF_Compiler.RunInternalHook("WireInputChanged",self,key,value)
end

function ENT:ReadCell(address)
	if self.error or not self.context then return 0 end

	local ret = self:RunHook("ReadCell",address)
	if type(ret) ~= "number" then
		self:Error("Returned "..type(ret).." to hook ReadCell (expected number)")
		return 0
	end
	return ret
end

function ENT:WriteCell(address, data)
	self:RunHook("WriteCell",address,data)
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID, GetConstByID)
	self.BaseClass.ApplyDupeInfo(self, ply, ent, info, GetEntByID, GetConstByID)
end