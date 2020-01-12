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
end

function ENT:TransmitData(recip)
	net.Start("starfall_custom_prop")
	net.WriteUInt(self:EntIndex(), 16)
	local stream = net.WriteStream(self.streamdata)
	if recip then net.Send(recip) else net.Broadcast() end
	return stream
end

function ENT:OnRemove() --cleanup potential collision listener
    if self.PhysicsCollide then
        self.PhysicsCollide = nil
    end
end

hook.Add("PlayerInitialSpawn","SF_Initialize_Custom_Props",function(ply)
	SF.WaitForPlayerInit(ply, function()
		for k, v in ipairs(ents.FindByClass("starfall_prop")) do
			v:TransmitData(ply)
		end
	end)
end)
