AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

util.AddNetworkString "starfall_hologram_scale"
util.AddNetworkString "starfall_hologram_clip"

function ENT:Initialize()
	self.BaseClass.Initialize()
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NOCLIP) -- TODO: custom movetype hook?
	self:DrawShadow( false )
end

function ENT:SetScale ( scale )
	net.Start( "starfall_hologram_scale" )
		net.WriteUInt( self:EntIndex(), 32 )
		net.WriteDouble( scale.x )
		net.WriteDouble( scale.y )
		net.WriteDouble( scale.z )
	net.Broadcast()
end

function ENT:UpdateClip(index, enabled, origin, normal, islocal)
	net.Start( "starfall_hologram_clip" )
		net.WriteUInt( self:EntIndex(), 32 )
		net.WriteUInt( index, 16 )
		net.WriteBit( enabled )
		net.WriteVector( origin )
		net.WriteVector( normal )
		net.WriteBit( islocal )
	net.Broadcast()
end
