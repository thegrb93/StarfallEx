ENT.Type            = "anim"
ENT.Base            = "base_anim"

ENT.PrintName       = "Starfall Hologram"
ENT.Author          = "Starfall Organization"

ENT.Spawnable       = false

function ENT:SetupDataTables()

	self:NetworkVar("Bool", 0, "SuppressEngineLighting")
	self:NetworkVar("Vector", 0, "Scale")

end
