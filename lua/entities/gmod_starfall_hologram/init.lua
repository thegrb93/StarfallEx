AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
	self:SetSolid( SOLID_NONE )
	self:SetMoveType( MOVETYPE_NONE ) -- TODO: custom movetype hook?
	self:DrawShadow( false )
end
