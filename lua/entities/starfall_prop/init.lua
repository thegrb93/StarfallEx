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

	self:AddEFlags( EFL_FORCE_CHECK_TRANSMIT )
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:TransmitData(recip)
	net.Start("starfall_custom_prop")
	net.WriteUInt(self:EntIndex(), 16)
	local stream = net.WriteStream(self.streamdata, nil, true)
	if recip then net.Send(recip) else net.Broadcast() end
	return stream
end

SF.WaitForPlayerInit(function(ply)
	for k, v in ipairs(ents.FindByClass("starfall_prop")) do
		v:TransmitData(ply)
	end
end)
