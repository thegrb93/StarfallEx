AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

local IsValid = FindMetaTable("Entity").IsValid

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	self:AddEFlags( EFL_FORCE_CHECK_TRANSMIT )
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

-- Sends a net message to all clients about the use.
function ENT:Use(activator)
	if not self.link then return end
	
	if activator:IsPlayer() then
		net.Start("starfall_processor_used")
			net.WriteEntity(self.link)
			net.WriteEntity(self)
			net.WriteEntity(activator)
		net.Broadcast()
		
		if self.locksControls then
			net.Start("starfall_lock_control")
				net.WriteEntity(self.link)
				net.WriteBool(true)
			net.Send(activator)
		end
	end
	
	local instance = self.link.instance
	if instance then
		instance:runScriptHook("starfallused", instance.WrapObject(activator), instance.WrapObject(self))
	end
end

function ENT:PreEntityCopy()
	if self.EntityMods then self.EntityMods.SFLink = nil end
	if IsValid(self.link) then
		duplicator.StoreEntityModifier(self, "SFLink", { link = self.link:EntIndex() })
	end
end

function ENT:PostEntityPaste(ply, ent, CreatedEntities)
	if ent.EntityMods and ent.EntityMods.SFLink then
		local info = ent.EntityMods.SFLink
		if info.link then
			local e = CreatedEntities[info.link]
			if IsValid(e) then
				SF.LinkEnt(self, e)
			end
		end
	end
end
