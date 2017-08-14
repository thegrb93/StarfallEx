AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString "starfall_hologram_init"
util.AddNetworkString "starfall_hologram_scale"
util.AddNetworkString "starfall_hologram_clip"

function ENT:Initialize()
	self.BaseClass.Initialize()
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NOCLIP) -- TODO: custom movetype hook?
	self:DrawShadow(false)
	
	self.scale = Vector()
	self.clips = {}
end

function ENT:SetScale (scale)
	if self.lastScaleUpdate == CurTime() then return end
	self.lastScaleUpdate = CurTime()
	
	self.scale = scale
	self:SendScale()
end

function ENT:UpdateClip(index, enabled, origin, normal, islocal)
	if self.lastClipUpdate == CurTime() then return end
	self.lastClipUpdate = CurTime()
	
	if enabled then
		self.clips[index] = { origin = origin, normal = normal, islocal = islocal }
	else
		self.clips[index] = nil
	end
	self:SendClip(index)	
end

function ENT:SendScale(ply)
	net.Start("starfall_hologram_scale")
		net.WriteUInt(self:EntIndex(), 32)
		net.WriteFloat(self.scale.x)
		net.WriteFloat(self.scale.y)
		net.WriteFloat(self.scale.z)
	if ply then net.Send(ply) else net.Broadcast() end
end

function ENT:SendClip(index, ply)
	local clip = self.clips[index]
	net.Start("starfall_hologram_clip")
	if clip then
		net.WriteUInt(self:EntIndex(), 32)
		net.WriteUInt(index, 16)
		net.WriteBit(true)
		net.WriteVector(clip.origin)
		net.WriteVector(clip.normal)
		net.WriteBit(clip.islocal)
	else
		net.WriteUInt(self:EntIndex(), 32)
		net.WriteUInt(index, 16)
		net.WriteBit(false)
		net.WriteVector(vector_origin)
		net.WriteVector(vector_origin)
		net.WriteBit(false)
	end
	if ply then net.Send(ply) else net.Broadcast() end
end

net.Receive("starfall_hologram_init", function(len, ply)
	local holo = net.ReadEntity()
	if IsValid(holo) and holo.SendScale then
		holo:SendScale(ply)
		for index, clip in pairs(holo.clips) do
			holo:SendClip(index, ply)
		end
	end
end)

function ENT:CanTool(pl, tr, tool)
	return pl == self:GetHoloOwner() and tool == "starfall_ent_lib"
end
