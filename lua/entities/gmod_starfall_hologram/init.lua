AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NOCLIP) -- TODO: custom movetype hook?
	self:DrawShadow( false )
end

function ENT:SetScale(scale)
	umsg.Start("starfall_hologram_scale")
		umsg.Entity(self)
		umsg.Vector(scale)
	umsg.End()
end

function ENT:UpdateClip(index, enabled, origin, normal, islocal)
	umsg.Start("starfall_hologram_clip")
		umsg.Entity(self)
		umsg.Short(index)
		umsg.Bool(enabled)
		umsg.Vector(origin)
		umsg.Vector(normal)
		umsg.Bool(islocal)
	umsg.End()
end