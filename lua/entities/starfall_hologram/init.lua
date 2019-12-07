AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self.BaseClass.Initialize()
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NOCLIP)
	self:DrawShadow(false)

	self.clips = {}
	self.clipdata = ""
	self.scale = Vector(1,1,1)

	self.update = false
	self.updateScale = false
	self.updateSuppressEngineLighting = false
	self.AutomaticFrameAdvance = false
end

util.AddNetworkString("starfall_hologram")

function ENT:SetScale(scale)
	self.update = true
	self.updateScale = true
	self.scale = scale
end

function ENT:SetSuppressEngineLighting(suppress)
	self.update = true
	self.updateSuppressEngineLighting = true
	self.suppressEngineLighting = suppress
end

function ENT:Think()
	if self.update then
		self.update = false

		net.Start("starfall_hologram")
		net.WriteUInt(self:EntIndex(), 16)

		if self.updateScale then
			self.updateScale = false
			net.WriteBool(true)
			--net.WriteVector has bad precision
			net.WriteFloat(self.scale.x)
			net.WriteFloat(self.scale.y)
			net.WriteFloat(self.scale.z)
		else
			net.WriteBool(false)
		end

		if self.updateSuppressEngineLighting then
			self.updateSuppressEngineLighting = false
			net.WriteBool(true)
			net.WriteBool(self.suppressEngineLighting)
		else
			net.WriteBool(false)
		end

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
			
			net.WriteBool(true)
			net.WriteUInt(#self.clipdata, 32)
			net.WriteData(self.clipdata, #self.clipdata)
		else
			net.WriteBool(false)
		end

		net.Broadcast()
	end
	if self.AutomaticFrameAdvance then
		self:NextThink(CurTime())
		return true
	end
end

function ENT:SetClip(index, enabled, normal, origin, entity)
	self.update = true
	self.updateClip = true
	if enabled then
		self.clips[index] = {normal = normal, origin = origin, entity = entity}
	else
		self.clips[index] = nil
	end
end

net.Receive("starfall_hologram", function(len, ply)
	local self = net.ReadEntity()
	if self:IsValid() and self.IsSFHologram then
		net.Start("starfall_hologram")
		net.WriteUInt(16, self:EntIndex())

		if self.scale.x~=1 or self.scale.y~=1 or self.scale.z~=1 then
			net.WriteBool(true)
			--net.WriteVector has bad precision
			net.WriteFloat(self.scale.x)
			net.WriteFloat(self.scale.y)
			net.WriteFloat(self.scale.z)
		else
			net.WriteBool(false)
		end

		if self.suppressEngineLighting then
			net.WriteBool(true)
			net.WriteBool(self.suppressEngineLighting)
		else
			net.WriteBool(false)
		end

		if self.clipdata~="" then
			net.WriteBool(true)
			net.WriteStream(self.clipdata)
		else
			net.WriteBool(false)
		end

		net.Send(ply)
	end
end)

