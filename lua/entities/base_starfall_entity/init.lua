AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize ()
    baseclass.Get( "base_gmodentity" ).Initialize( self )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )

    self.tableCopy = function ( t, lookup_table )
		if ( t == nil ) then return nil end

		local copy = {}
		setmetatable( copy, debug.getmetatable( t ) )
		for i, v in pairs( t ) do
			if ( not istable( v ) ) then
				copy[ i ] = v
			else
				lookup_table = lookup_table or {}
				lookup_table[ t ] = copy
				if lookup_table[ v ] then
					copy[ i ] = lookup_table[ v ] -- we already copied this table. reuse the copy.
				else
					copy[ i ] = table.Copy( v, lookup_table ) -- not yet copied. copy it.
				end
			end
		end
		return copy
    end
end

function ENT:Error ( msg )
    ErrorNoHalt( "Processor of " .. self.owner:Nick() .. " errored: " .. msg .. "\n" )

    if self.instance then
        self.instance:deinitialize()
        self.instance = nil
    end

    SF.AddNotify( msg, NOTIFY_ERROR, 7, NOTIFYSOUND_ERROR1 )

end

function ENT:OnRemove ()
    if not self.instance then return end

    self.instance:deinitialize()
    self.instance = nil
end

function ENT:onRestore ()
end

function ENT:BuildDupeInfo ()
	-- Remove table.Copy fix when Garrysmod updates with @Xandaros patch.
	table.Copy = self.tableCopy
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
