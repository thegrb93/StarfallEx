AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

util.AddNetworkString("starfall_custom_prop")

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:PhysicsInitMultiConvex(self.Mesh)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:EnableCustomCollisions(true)
	self:DrawShadow(false)

	local physobj = self:GetPhysicsObject()
	physobj:EnableCollisions( true )
	physobj:EnableDrag( true )
end
