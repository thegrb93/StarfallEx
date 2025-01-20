AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local IsValid = FindMetaTable("Entity").IsValid
local IsWorld = FindMetaTable("Entity").IsWorld

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	self:AddEFlags( EFL_FORCE_CHECK_TRANSMIT )

	self:SetNWInt("State", self.States.None)
	self:SetColor4Part(255, 0, 0, select(4, self:GetColor4Part()))
	self.ErroredPlayers = {}
	self.ActiveHuds = {}
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:SetCustomModel(model)
	if self:GetModel() == model then return end
	if IsValid(self:GetParent()) then
		self:SetModel(model)
	else
		local constraints = constraint.GetTable(self)
		local entities = {}
		for k, v in pairs(constraints) do
			for o, p in pairs(v.Entity) do
				entities[p.Index] = p.Entity
			end
		end
		local movable = self:GetPhysicsObject():IsMoveable()
		constraint.RemoveAll(self)
		self:PhysicsDestroy()
		self:SetModel(model)
		self:PhysicsInit(SOLID_VPHYSICS)
		local function remakeConstraints()
			for k, v in pairs(constraints) do
				duplicator.CreateConstraintFromTable(v, entities)
			end
			self:GetPhysicsObject():EnableMotion(movable)
		end
		self:GetPhysicsObject():EnableMotion(false)
		timer.Simple(0, remakeConstraints) -- Need timer or wont work
	end
end

-- Sends a net message to all clients about the use.
function ENT:Use(activator)
	if activator:IsPlayer() then
		net.Start("starfall_processor_used")
			net.WriteEntity(self)
			net.WriteEntity(self)
			net.WriteEntity(activator)
		net.Broadcast()
	end

	local instance = self.instance
	if instance then
		instance:runScriptHook("starfallused", instance.WrapObject(activator), instance.WrapObject(self))
	end
end

function ENT:OnRemove()
	self:Destroy()
end

function ENT:Think()
	if self.instance then
		local bufferAvg = self.instance.cpu_average
		self:SetNWInt("CPUus", math.Round(bufferAvg * 1000000))
		self:SetNWFloat("CPUpercent", math.floor(bufferAvg / self.instance.cpuQuota * 100))
		self:NextThink(CurTime() + 0.25)
		return true
	end
end

function ENT:SendCode(recipient)
	if not (IsValid(self.owner) or IsWorld(self.owner)) then return end
	if not self.sfsenddata then return end
	local others = {}
	for _, ply in ipairs(recipient and (istable(recipient) and recipient or { recipient }) or player.GetHumans()) do
		if ply:GetInfoNum("sf_enabled_cl", 0)==0 then continue end
		if ply==self.owner and self.sfownerdata then
			SF.SendStarfall("starfall_processor_download", self.sfownerdata, self.owner)
		else
			others[#others+1] = ply
		end
	end
	if #others > 0 then
		SF.SendStarfall("starfall_processor_download", self.sfsenddata, others)
	end
end

function ENT:PreEntityCopy()
	duplicator.ClearEntityModifier(self, "SFDupeInfo")
	if self.sfdata then
		local info = WireLib and WireLib.BuildDupeInfo(self) or {}
		info.starfall = {mainfile = self.sfdata.mainfile, files = SF.CompressFiles(self.sfdata.files), udata = self.starfalluserdata, ver = 4.3}
		duplicator.StoreEntityModifier(self, "SFDupeInfo", info)
	end

	-- Stupid hack to prevent garry dupe from copying everything
	SF.Copying = {self.sfdata, self.instance}
	self.sfdata = nil
	self.instance = nil
end
function ENT:PostEntityCopy()
	self.sfdata = SF.Copying[1]
	self.instance = SF.Copying[2]
	SF.Copying = nil
end

local function EntityLookup(CreatedEntities)
	return function(id, default)
		if id == nil then return default end
		if id == 0 then return game.GetWorld() end
		local ent = CreatedEntities[id]
		if IsValid(ent) then return ent else return default end
	end
end
function ENT:PostEntityPaste(ply, ent, CreatedEntities)
	if ent.EntityMods and ent.EntityMods.SFDupeInfo then
		local info = ent.EntityMods.SFDupeInfo
		if not ply then ply = game.GetWorld() end

		if WireLib then
			WireLib.ApplyDupeInfo(ply, ent, info, EntityLookup(CreatedEntities))
		end

		if info.starfall then
			local ver = tonumber(info.starfall.ver)
			if ver then
				if ver > 4.3 then
					error("This server's starfall is too out of date to paste")
				else
					-- 4.3 case
					local files = SF.DecompressFiles(info.starfall.files)
					self.starfalluserdata = info.starfall.udata
					self.sfdata = {owner = ply, files = files, mainfile = info.starfall.mainfile, proc = self}
				end
			else
				-- Legacy duplications
				local files, mainfile = SF.LegacyDeserializeCode(info.starfall)
				self.starfalluserdata = info.starfalluserdata
				self.sfdata = {owner = ply, files = files, mainfile = mainfile, proc = self}
			end
		end
	end
end

local function dupefinished(TimedPasteData, TimedPasteDataCurrent)
	local entList = TimedPasteData[TimedPasteDataCurrent].CreatedEntities
	local starfalls = {}
	for k, v in pairs(entList) do
		if isentity(v) and IsValid(v) and v:GetClass() == "starfall_processor" and v.sfdata then
			starfalls[#starfalls+1] = v
		end
	end
	for k, v in pairs(starfalls) do
		v:Compile(v.sfdata)
		local instance = v.instance
		if instance then
			instance:runScriptHook("dupefinished", instance.Sanitize(entList))
		end
	end
end
hook.Add("AdvDupe_FinishPasting", "SF_dupefinished", dupefinished)

util.AddNetworkString("starfall_processor_download")
util.AddNetworkString("starfall_processor_used")
util.AddNetworkString("starfall_processor_link")
util.AddNetworkString("starfall_processor_kill")
util.AddNetworkString("starfall_processor_clinit")

-- Request code from the chip. If the chip doesn't have code yet add player to list to send when there is code.
net.Receive("starfall_processor_download", function(len, ply)
	local proc = net.ReadEntity()
	if IsValid(ply) and IsValid(proc) then
		proc:SendCode(ply)
	end
end)

net.Receive("starfall_processor_link", function(len, ply)
	local linked = Entity(net.ReadUInt(16))
	if IsValid(linked.link) then
		SF.LinkEnt(linked, linked.link, ply)
	end
end)

net.Receive("starfall_processor_kill", function(len, ply)
	local target = net.ReadEntity()
	if ply:IsAdmin() and IsValid(target) and target:GetClass()=="starfall_processor" then
		target:Error({message = "Killed by admin", traceback = ""})
		net.Start("starfall_processor_kill")
		net.WriteEntity(target)
		net.Broadcast()
	end
end)

net.Receive("starfall_processor_clinit", function(len, ply)
	local proc = net.ReadEntity()
	if IsValid(ply) and IsValid(proc) then
		local instance = proc.instance
		if instance then
			instance:runScriptHook("clientinitialized", instance.Types.Player.Wrap(ply))
		end
	end
end)

SF.WaitForPlayerInit(function(ply)
	for k, v in ipairs(ents.FindByClass("starfall_processor")) do
		v:SendCode(ply)
	end
end)

