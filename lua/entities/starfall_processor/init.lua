AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize ()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	self:SetNWInt("State", self.States.None)
	self:SetColor(Color(255, 0, 0, self:GetColor().a))
end

-- Sends a net message to all clients about the use.
function ENT:Use(activator)
	if activator:IsPlayer() then
		net.Start("starfall_processor_used")
			net.WriteEntity(self)
			net.WriteEntity(activator)
		net.Broadcast()
	end
end

function ENT:OnRemove ()
	if not self.instance then return end

	self.instance:runScriptHook("removed")
	--removed hook can cause instance to become nil
	if self.instance then
		self.instance:deinitialize()
		self.instance = nil
	end
end

function ENT:GetGateName()
	return self.name
end

function ENT:Think ()
	if self.instance then
		local bufferAvg = self.instance.cpu_average
		self:SetNWInt("CPUus", math.Round(bufferAvg * 1000000))
		self:SetNWFloat("CPUpercent", math.floor(bufferAvg / self.instance.cpuQuota * 100))
	end
end

function ENT:SendCode(recipient)
	local sfdata = {
		proc = self,
		owner = self.owner,
		mainfile = self.mainfile,
		files = self.files,
		-- times = self.times,
		-- netfiles = self.netfiles
	}
	if self.instance and self.instance.ppdata and self.instance.ppdata.serverorclient then
		-- sfdata.times = {}
		sfdata.files = {}
		for filename, code in pairs(self.files) do
			if self.instance.ppdata.serverorclient[filename] ~= "server" then
				sfdata.files[filename] = code
			end
		end
	end
	SF.SendStarfall("starfall_processor_download", sfdata, recipient)
end

function ENT:PreEntityCopy ()
	if self.EntityMods then self.EntityMods.SFDupeInfo = nil end

	if self.instance then
		local info = WireLib and WireLib.BuildDupeInfo(self) or {}
		info.starfall = SF.SerializeCode(self.files, self.mainfile)
		info.starfalluserdata = self.instance.data.userdata
		duplicator.StoreEntityModifier(self, "SFDupeInfo", info)
	end
end

local function EntityLookup(CreatedEntities)
	return function(id, default)
		if id == nil then return default end
		if id == 0 then return game.GetWorld() end
		local ent = CreatedEntities[id] or (isnumber(id) and ents.GetByIndex(id))
		if IsValid(ent) then return ent else return default end
	end
end
function ENT:PostEntityPaste (ply, ent, CreatedEntities)
	if ent.EntityMods and ent.EntityMods.SFDupeInfo then
		local info = ent.EntityMods.SFDupeInfo

		if WireLib then
			WireLib.ApplyDupeInfo(ply, ent, info, EntityLookup(CreatedEntities))
		end

		if info.starfall then
			local files, mainfile = SF.DeserializeCode(info.starfall)
			self.starfalluserdata = info.starfalluserdata
			self:SetupFiles({owner = ply, files = files, mainfile = mainfile})
		end
	end
end

local function dupefinished(TimedPasteData, TimedPasteDataCurrent)
	for k, v in pairs(TimedPasteData[TimedPasteDataCurrent].CreatedEntities) do
		if IsValid(v) and v:GetClass() == "starfall_processor" and v.instance then
			v.instance:runScriptHook("initialize")
		end
	end
end
hook.Add("AdvDupe_FinishPasting", "SF_dupefinished", dupefinished)

util.AddNetworkString("starfall_processor_download")
util.AddNetworkString("starfall_processor_used")
util.AddNetworkString("starfall_processor_link")
util.AddNetworkString("starfall_processor_update_links")

-- Request code from the chip. If the chip doesn't have code yet add player to list to send when there is code.
net.Receive("starfall_processor_download", function(len, ply)
	local proc = net.ReadEntity()
	if ply:IsValid() and proc:IsValid() then
		if proc.mainfile and proc.files then
			proc:SendCode(ply)
		else
			proc.SendQueue = proc.SendQueue or {}
			proc.SendQueue[#proc.SendQueue + 1] = ply
		end
	end
end)

net.Receive("starfall_processor_update_links", function(len, ply)
	local linked = net.ReadEntity()
	if IsValid(linked.link) then
		linked:LinkEnt(linked.link, ply)
	end
end)

