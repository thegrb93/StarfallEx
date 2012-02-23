
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

include("starfall/SFLib.lua")
include("libtransfer/libtransfer.lua")
assert(SF, "Starfall didn't load correctly!")

local context = SF.CreateContext()

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	self.Inputs = WireLib.CreateInputs(self, {})
	self.Outputs = WireLib.CreateOutputs(self, {})
	
	self:UpdateName("Inactive (No code)")
	local r,g,b,a = self:GetColor()
	self:SetColor(255, 0, 0, a)
end

function ENT:UpdateName(state)
	if state ~= "" then state = "\n"..state end
	
	if self.instance and self.instance.ppdata.scriptnames and self.instance.mainfile and self.instance.ppdata.scriptnames[self.instance.mainfile] then
		self:SetOverlayText("Starfall Processor\n"..tostring(self.instance.ppdata.scriptnames[self.instance.mainfile])..state)
	else
		self:SetOverlayText("Starfall Processor"..state)
	end
end

function ENT:OnRestore()
end

function ENT:Compile(codetbl, mainfile)
	local ok, instance = SF.Compiler.Compile(codetbl,context,mainfile,self.owner)
	if not ok then self:Error(instance) return end
	self.instance = instance
	instance.data.entity = self
	
	local ok, msg = instance:initialize()
	if not ok then
		self:Error(msg)
		return
	end
	
	self:UpdateName("")
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
	
	self:UpdateName("Inactive (Error)")
	local r,g,b,a = self:GetColor()
	self:SetColor(255, 0, 0, a)
end

function ENT:CodeSent(ply, task)
	if ply ~= self.owner then return end
	self:Compile(task.files, task.mainfile)
end

function ENT:Think()
	self.BaseClass.Think(self)
	self:NextThink(CurTime())
	
	if self.instance and not self.instance.error then
		self.instance:resetOps()
		self:RunScriptHook("think")
	end
	
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

function ENT:BuildDupeInfo()
	-- TODO Fix duplication doesnt work
	--local info = self.BaseClass.BuildDupeInfo(self) or {}
	return {}
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID, GetConstByID)
	self.BaseClass.ApplyDupeInfo(self, ply, ent, info, GetEntByID, GetConstByID)
end
