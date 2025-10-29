ENT.Type            = "anim"
ENT.Base            = "base_anim"
ENT.PhysicsSounds   = true

ENT.PrintName       = "Starfall Custom Prop"
ENT.Author          = "Sparky OvO"

ENT.Spawnable       = false
ENT.AdminSpawnable  = false

ENT.IsSFProp = true

function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "PhysMaterial" )

	if CLIENT then
		self:NetworkVarNotify( "PhysMaterial", self.OnPhysMaterialChanged )
	end
end

