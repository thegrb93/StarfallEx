AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString "starfall_hologram_clip"

function ENT:Initialize()
	self.BaseClass.Initialize()
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NOCLIP) -- TODO: custom movetype hook?
	self:DrawShadow(false)

	self:SetScale(Vector(1,1,1))
	self.clips = {}
	self.lastClipUpdate = {}
end

function ENT:UpdateClip(index, enabled, origin, normal, islocal, entity)
	if self.lastClipUpdate[index] == CurTime() then return end
	if enabled then
		self.clips[index] = { origin = origin, normal = normal, islocal = islocal, entity = IsValid(entity) and entity or self }
		self.lastClipUpdate[index] = CurTime()
		self:SendClip(index)
	elseif self.clips[index] then
		self.clips[index] = nil
		self.lastClipUpdate[index] = nil
		self:SendClip(index)
	end
end

function ENT:SendClip(index, ply)
	local clip = self.clips[index]
	net.Start("starfall_hologram_clip")
	if clip then
		net.WriteUInt(self:EntIndex(), 16)
		net.WriteUInt(index, 16)
		net.WriteBit(true)
		net.WriteVector(clip.origin)
		net.WriteVector(clip.normal)
		net.WriteBit(clip.islocal)
		net.WriteUInt(clip.entity:EntIndex(), 16)
	else
		net.WriteUInt(self:EntIndex(), 16)
		net.WriteUInt(index, 16)
		net.WriteBit(false)
		net.WriteVector(vector_origin)
		net.WriteVector(vector_origin)
		net.WriteBit(false)
		net.WriteUInt(0, 16)
	end
	if ply then net.Send(ply) else net.Broadcast() end
end

net.Receive("starfall_hologram_clip", function(len, ply)
	local holo = Entity(net.ReadUInt(16))
	if IsValid(holo) and holo.clips then
		for index, clip in pairs(holo.clips) do
			holo:SendClip(index, ply)
		end
	end
end)

function ENT:CanTool(pl, tr, tool)
	return pl == SF.Permissions.getOwner(self) and tool == "starfall_ent_lib"
end
