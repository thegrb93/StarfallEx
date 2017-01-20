AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')


function ENT:Initialize ()
	self.BaseClass.Initialize( self )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
end

-- Sends a net message to all clients about the use.
function ENT:Use( activator )
	if not self.link then return end
	
	if activator:IsPlayer() then
		net.Start( "starfall_processor_used" )
			net.WriteEntity( self )
			net.WriteEntity( activator )
		net.Broadcast()
	end
	
	self.link:runScriptHook( "starfallused", SF.Entities.Wrap( activator ) )
end

function ENT:LinkEnt ( ent, ply )
	self.link = ent
	net.Start("starfall_processor_link")
		net.WriteEntity(self)
		net.WriteEntity(ent)
	if ply then net.Send(ply) else net.Broadcast() end
end

function ENT:PreEntityCopy ()
	if self.EntityMods then self.EntityMods.SFLink = nil end
	if IsValid(self.link) then
		duplicator.StoreEntityModifier( self, "SFLink", { link = self.link:EntIndex() } )
	end
end

function ENT:PostEntityPaste ( ply, ent, CreatedEntities )
	if ent.EntityMods and ent.EntityMods.SFLink then
		local info = ent.EntityMods.SFLink
		if info.link then
			local e = CreatedEntities[ info.link ]
			if IsValid( e ) then
				self:LinkEnt( e )
			end
		end
	end
end
