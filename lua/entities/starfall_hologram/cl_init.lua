include("shared.lua")
ENT.RenderGroup = RENDERGROUP_OPAQUE

ENT.IsHologram = true
ENT.DefaultMaterial = Material( "hunter/myplastic" )
ENT.Material = ENT.DefaultMaterial

function ENT:Initialize()
	self.clips = {}
	self.sf_userrenderbounds = false
	self:SetupBones()
	self:OnScaleChanged(nil, nil, self:GetScale())
end

function ENT:SetClip(index, enabled, normal, origin, entity)
	if enabled then
		self.clips[index] = {normal = normal, origin = origin, entity = entity}
	else
		self.clips[index] = nil
	end
end

function ENT:OnScaleChanged(name, old, scale)
	if scale == Vector(1, 1, 1) then
		self.HoloMatrix = nil
		self:DisableMatrix("RenderMultiply")
	else
		local scalematrix = Matrix()
		scalematrix:Scale(scale)
		self.HoloMatrix = scalematrix
		self:EnableMatrix("RenderMultiply", scalematrix)
	end
	if not self.sf_userrenderbounds then
		local mins, maxs = self:GetModelBounds()
		if mins then
			self:SetRenderBounds(mins * scale, maxs * scale)
		end
	end
end

function ENT:Draw(flags)
	local selfTbl = self:GetTable()
	if self:GetColor().a ~= 255 then
		selfTbl.RenderGroup = RENDERGROUP_BOTH
	else
		selfTbl.RenderGroup = RENDERGROUP_OPAQUE
	end

	local clipCount = 0
	local prevClip
	if next(selfTbl.clips) then
		prevClip = render.EnableClipping(true)
		for _, clip in pairs(selfTbl.clips) do
			local clipent = clip.entity
			if clipent and clipent:IsValid() then
				local norm = clipent:LocalToWorld(clip.normal) - clipent:GetPos()
				render.PushCustomClipPlane(norm, norm:Dot(clipent:LocalToWorld(clip.origin)))
			else
				render.PushCustomClipPlane(clip.normal, clip.normal:Dot(clip.origin))
			end
			clipCount = clipCount + 1
		end
	end

	local filter_mag, filter_min = selfTbl.filter_mag, selfTbl.filter_min
	if filter_mag then render.PushFilterMag(filter_mag) end
	if filter_min then render.PushFilterMin(filter_min) end
	
	if self:GetSuppressEngineLighting() then
		render.SuppressEngineLighting(true)
		self:DrawModel(flags)
		render.SuppressEngineLighting(false)
	else
		self:DrawModel(flags)
	end
	
	if filter_mag then render.PopFilterMag() end
	if filter_min then render.PopFilterMin() end

	if next(selfTbl.clips) then
		for i=1, clipCount do
			render.PopCustomClipPlane()
		end
		render.EnableClipping(prevClip)
	end
	
	if selfTbl.AutomaticFrameAdvance then
		self:FrameAdvance(0)
	end
end

function ENT:GetRenderMesh()
	local selfTbl = self:GetTable()
	if selfTbl.custom_mesh then
		if selfTbl.custom_mesh_data[selfTbl.custom_mesh] then
			return { Mesh = selfTbl.custom_mesh, Material = selfTbl.Material--[[, Matrix = self.HoloMatrix]] }
		else
			selfTbl.custom_mesh = nil
		end
	end
end

net.Receive("starfall_hologram_clips", function()
	local index = net.ReadUInt(16)
	local clipdata = SF.StringStream(net.ReadData(net.ReadUInt(32)))

	local function applyHologram(self)
		if self and self.IsSFHologram then
			local clips = {}
			for i=1, math.Round(clipdata:size()/34) do
				local index = clipdata:readDouble()
				local clip = {
					normal = Vector(clipdata:readFloat(), clipdata:readFloat(), clipdata:readFloat()),
					origin = Vector(clipdata:readFloat(), clipdata:readFloat(), clipdata:readFloat()),
				}
				local entind = clipdata:readUInt16()
				if entind~=0 then
					SF.WaitForEntity(entind, function(e) clip.entity = e end)
				end
				clips[index] = clip
			end
			self.clips = clips
		end
	end

	SF.WaitForEntity(index, applyHologram)
end)

-- For when the hologram matrix gets cleared
hook.Add("NetworkEntityCreated", "starfall_hologram_rescale", function(holo)
	if holo.IsSFHologram and holo.HoloMatrix then
		holo:EnableMatrix("RenderMultiply", holo.HoloMatrix)
	end
	local sf_userrenderbounds = holo.sf_userrenderbounds
	if sf_userrenderbounds then
		holo:SetRenderBounds(sf_userrenderbounds[1], sf_userrenderbounds[2])
	end
end)

local function ShowHologramOwners()
	for _, ent in pairs(ents.GetAll()) do
		if ent.IsSFHologram then
			local name = "No Owner"
			local steamID = ""
			local ply = SF.Permissions.getOwner(ent)
			if ply and ply:IsValid() then
				name = ply:Name()
				steamID = ply:SteamID()
			else
				ply = ent.SFHoloOwner
				if ply and ply:IsValid() then
					name = ply:Name()
					steamID = ply:SteamID()
				end
			end

			local vec = ent:GetPos():ToScreen()

			draw.DrawText(name .. "\n" .. steamID, "DermaDefault", vec.x, vec.y, Color(255, 0, 0, 255), 1)
		end
	end
end

local display_owners = false
concommand.Add("sf_holograms_display_owners", function()
	display_owners = not display_owners

	if display_owners then
		hook.Add("HUDPaint", "sf_holograms_showowners", ShowHologramOwners)
	else
		hook.Remove("HUDPaint", "sf_holograms_showowners")
	end
end)
