AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

util.AddNetworkString "starfall_hologram_scale"
util.AddNetworkString "starfall_hologram_clip"

function ENT:Initialize()
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NOCLIP) -- TODO: custom movetype hook?
	self:DrawShadow( false )
end

function ENT:SetScale(scale)
	net.Start("starfall_hologram_scale")
		net.WriteEntity(self)
		net.WriteDouble(scale.x)
		net.WriteDouble(scale.y)
		net.WriteDouble(scale.z)
	net.Broadcast()
end

function ENT:UpdateClip(index, enabled, origin, normal, islocal)
	net.Start("starfall_hologram_clip")
		net.WriteEntity(self)
		net.WriteUInt(index,16)
		net.WriteBit(enabled)
		net.WriteDouble(origin.x)
		net.WriteDouble(origin.y)
		net.WriteDouble(origin.z)
		net.WriteDouble(normal.x)
		net.WriteDouble(normal.y)
		net.WriteDouble(normal.z)
		net.WriteBit(islocal)
	net.Broadcast()
end
