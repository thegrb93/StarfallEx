ENT.Type            = "anim"
ENT.Base            = "base_anim"

ENT.PrintName       = "Starfall Hologram"
ENT.Author          = "Starfall Organization"

ENT.Spawnable       = false
ENT.AdminSpawnable  = false

function ENT:SetupDataTables()

	self:NetworkVar( "Entity", 0, "HoloOwner" );
	self:NetworkVar( "Bool", 0, "SuppressEngineLighting" );

end
