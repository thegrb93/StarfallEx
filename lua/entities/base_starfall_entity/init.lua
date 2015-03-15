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

	self.instance:deinitialize()
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

local function EntityLookup(CreatedEntities)
	return function(id, default)
		if id == nil then return default end
		if id == 0 then return game.GetWorld() end
		local ent = CreatedEntities[id] or (isnumber(id) and ents.GetByIndex(id))
		if IsValid(ent) then return ent else return default end
	end
end

function ENT:PostEntityPaste ( ply, ent, CreatedEntities )
	if ent.EntityMods and ent.EntityMods.SFDupeInfo then
		ent:ApplyDupeInfo( ply, ent, ent.EntityMods.SFDupeInfo, EntityLookup(CreatedEntities) )
	end
end
