AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize ()
	baseclass.Get( "base_gmodentity" ).Initialize( self )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self.instance = nil
end

function ENT:OnRemove ()
	if not self.instance then return end

	hook.Run( "sf_deinitialize", self:EntIndex( ) )
	self:runScriptHook( "Removed" )

	if self.instance then self.instance:deinitialize() end
	self.instance = nil
end

function ENT:onRestore ()
end

function ENT:BuildDupeInfo ()
	return {}
end

function ENT:ApplyDupeInfo ()
	return {}
end

function ENT:PreEntityCopy ()
	local i = self:BuildDupeInfo()
	if i then
		duplicator.StoreEntityModifier( self, "SFDupeInfo", i )
	end
end

function ENT:PostEntityPaste ( ply, ent )
	if ent.EntityMods and ent.EntityMods.SFDupeInfo then
		ent:ApplyDupeInfo( ply, ent, ent.EntityMods.SFDupeInfo )
	end
end
