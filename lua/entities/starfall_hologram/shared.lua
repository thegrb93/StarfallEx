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
	self:NetworkVar( "Bool", 1, "CullMode" )
	self:NetworkVar( "Int", 0, "RenderGroupInternal" )

	if CLIENT then
		self:NetworkVarNotify( "Scale", self.OnScaleChanged )
		self:NetworkVarNotify( "PlayerColorInternal", self.OnPlayerColorChanged )
		self:NetworkVarNotify( "SuppressEngineLighting", self.OnSuppressEngineLightingChanged )
		self:NetworkVarNotify( "CullMode", self.OnCullModeChanged )
		self:NetworkVarNotify( "RenderGroupInternal", self.OnRenderGroupChanged )
	end
end
