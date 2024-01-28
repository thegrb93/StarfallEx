ENT.Type            = "anim"
ENT.Base            = "base_anim"

ENT.PrintName       = "Starfall Hologram"
ENT.Author          = "Starfall Organization"

ENT.Spawnable       = false
ENT.AdminSpawnable  = false

ENT.IsSFHologram = true

function ENT:SetupDataTables()
	self:NetworkVar( "Vector", 0, "Scale" )
	self:NetworkVar( "Vector", 1, "PlayerColorInternal" )
	self:NetworkVar( "Bool", 0, "SuppressEngineLighting" )

	if CLIENT then
		self:NetworkVarNotify( "Scale", self.OnScaleChanged )
		self:NetworkVarNotify( "PlayerColorInternal", self.OnPlayerColorChanged )
	end
end
