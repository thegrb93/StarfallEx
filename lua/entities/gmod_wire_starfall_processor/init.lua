
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

include("starfall/SFLib.lua")
include("libtransfer/libtransfer.lua")
assert(SF, "Starfall didn't load correctly!")

ENT.WireDebugName = "Starfall Processor"
ENT.OverlayDelay = 0

local context = SF.CreateContext()
local name = nil

function ENT:UpdateState(state)
	if name then
		self:SetOverlayText("Starfall Processor\n"..name.."\n"..state)
	else
		self:SetOverlayText("Starfall Processor\n"..state)
	end
end

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	self.Inputs = WireLib.CreateInputs(self, {})
	self.Outputs = WireLib.CreateOutputs(self, {})
	
	self:UpdateState("Inactive (No code)")
	local r,g,b,a = self:GetColor()
	self:SetColor(255, 0, 0, a)
end

function ENT:Compile(codetbl, mainfile)
	if self.instance then self.instance:deinitialize() end
	
	local ok, instance = SF.Compiler.Compile(codetbl,context,mainfile,self.owner)
	if not ok then self:Error(instance) return end
	self.instance = instance
	instance.data.entity = self
	
	local ok, msg = instance:initialize()
	if not ok then
		self:Error(msg)
		return
	end

	if self.instance.ppdata.scriptnames and self.instance.mainfile and self.instance.ppdata.scriptnames[self.instance.mainfile] then
		name = tostring(self.instance.ppdata.scriptnames[self.instance.mainfile])
	end

	if not name or string.len(name) <= 0 then
		name = "generic"
	end

	self:UpdateState("(None)")
	local r,g,b,a = self:GetColor()
	self:SetColor(255, 255, 255, a)
end

function ENT:Error(msg, override)
	ErrorNoHalt("Processor of "..self.owner:Nick().." errored: "..msg.."\n")
	WireLib.ClientError(msg, self.owner)
	
	if self.instance then
		self.instance:deinitialize()
		self.instance = nil
	end
	
	self:UpdateState("Inactive (Error)")
	local r,g,b,a = self:GetColor()
	self:SetColor(255, 0, 0, a)
end

function ENT:CodeSent(ply, task)
	if ply ~= self.owner then return end
	self:Compile(task.files, task.mainfile)
end

function ENT:Think()
	self.BaseClass.Think(self)
	
	if self.instance and not self.instance.error then
		self:UpdateState(tostring(self.instance.ops).." ops, "..tostring(math.floor(self.instance.ops / self.instance.context.ops * 100)).."%")

		self.instance:resetOps()
		self:RunScriptHook("think")
	end

	self:NextThink(CurTime())
	return true
end

function ENT:OnRemove()
	if not self.instance then return end
	self.instance:deinitialize()
	self.instance = nil
end

function ENT:TriggerInput(key, value)
	self:RunScriptHook("input",key, SF.Wire.InputConverters[self.Inputs[key].Type](value))
end

function ENT:ReadCell(address)
	return tonumber(self:RunScriptHookForResult("readcell",address)) or 0
end

function ENT:WriteCell(address, data)
	self:RunScriptHook("writecell",address,data)
end

function ENT:RunScriptHook(hook, ...)
	if self.instance and not self.instance.error and self.instance.hooks[hook:lower()] then
		local ok, rt = self.instance:runScriptHook(hook, ...)
		if not ok then self:Error(rt) end
	end
end

function ENT:RunScriptHookForResult(hook,...)
	if self.instance and not self.instance.error and self.instance.hooks[hook:lower()] then
		local ok, rt = self.instance:runScriptHookForResult(hook, ...)
		if not ok then self:Error(rt)
		else return rt end
	end
end

function ENT:OnRestore()
end

function ENT:BuildDupeInfo()
	local info = self.BaseClass.BuildDupeInfo(self) or {}
	if self.instance then
		info.starfall = SF.SerializeCode(self.instance.source, self.instance.mainfile)
	end
	return info
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
	self.BaseClass.ApplyDupeInfo(self, ply, ent, info, GetEntByID)
	self.owner = ply
	
	if info.starfall then
		local code, main = SF.DeserializeCode(info.starfall)
		self:Compile(code, main)
	end
end
