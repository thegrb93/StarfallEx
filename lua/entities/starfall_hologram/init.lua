AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local VECTOR_PLAYER_COLOR_DISABLED = Vector(-1, -1, -1)

function ENT:Initialize()
	self.BaseClass.Initialize()
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NOCLIP)
	self:DrawShadow(false)

	self:AddEFlags( EFL_FORCE_CHECK_TRANSMIT )

	self.clips = {}
	self.clipdata = ""

	self:SetScale(Vector(1,1,1))
	self:SetPlayerColorInternal(VECTOR_PLAYER_COLOR_DISABLED)
	self:SetSuppressEngineLighting(false)

	self.updateClip = false
	self.AutomaticFrameAdvance = false
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

util.AddNetworkString("starfall_hologram_clips")

function ENT:Think()
	if self.updateClip then
		self.updateClip = false

		local clipdata = SF.StringStream()
		for k, v in pairs(self.clips) do
			clipdata:writeDouble(k)
			clipdata:writeFloat(v.normal[1])
			clipdata:writeFloat(v.normal[2])
			clipdata:writeFloat(v.normal[3])
			clipdata:writeFloat(v.origin[1])
			clipdata:writeFloat(v.origin[2])
			clipdata:writeFloat(v.origin[3])
			clipdata:writeInt16(v.entity and v.entity:EntIndex() or 0)
		end
		self.clipdata = clipdata:getString()

		self:TransmitClips()
	end

	if self.AutomaticFrameAdvance then
		self:NextThink(CurTime())
		return true
	end
end

function ENT:SetClip(index, enabled, normal, origin, entity)
	self.updateClip = true
	if enabled then
		self.clips[index] = {normal = normal, origin = origin, entity = entity}
	else
		self.clips[index] = nil
	end
end

function ENT:TransmitClips(recip)
	net.Start("starfall_hologram_clips")
	net.WriteUInt(self:EntIndex(), 16)
	net.WriteUInt(#self.clipdata, 32)
	net.WriteData(self.clipdata, #self.clipdata)
	if recip then net.Send(recip) else net.Broadcast() end
end

net.Receive("starfall_hologram_clips", function(len, ply)
	local self = net.ReadEntity()
	if self:IsValid() and self.IsSFHologram and #self.clipdata>0 then
		self:TransmitClips(ply)
	end
end)

