include("shared.lua")
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.IsHologram = true
ENT.DefaultMaterial = Material( "hunter/myplastic" )
ENT.Material = ENT.DefaultMaterial

function ENT:Initialize()
	self.clips = {}
	self.suppressEngineLighting = false
	self.scale = Vector(1,1,1)
	self.userrenderbounds = false

	net.Start("starfall_hologram")
	net.WriteEntity(self)
	net.SendToServer()
end

function ENT:SetClip(index, enabled, normal, origin, entity)
	if enabled then
		self.clips[index] = {normal = normal, origin = origin, entity = entity}
	else
		self.clips[index] = nil
	end
end

function ENT:Draw()
	local clipCount = 0
	if next(self.clips) then
		render.EnableClipping(true)
		for _, clip in pairs(self.clips) do
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

	local filter_mag, filter_min = self.filter_mag, self.filter_min
	if filter_mag then render.PushFilterMag(filter_mag) end
	if filter_min then render.PushFilterMin(filter_min) end
	
	if self.suppressEngineLighting then
		render.SuppressEngineLighting(true)
		self:DrawHologram()
		render.SuppressEngineLighting(false)
	else
		self:DrawHologram()
	end
	
	if filter_mag then render.PopFilterMag() end
	if filter_min then render.PopFilterMin() end

	for i=1, clipCount do
		render.PopCustomClipPlane()
	end
	render.EnableClipping(false)
end

function ENT:DrawHologram()
	self:DrawModel()
end

function ENT:DrawCLHologram()
	local data = self:GetRenderMesh()
	
	if data then
		if self.HoloMatrix then
			cam.PushModelMatrix(self:GetWorldTransformMatrix() * self.HoloMatrix)
		else
			cam.PushModelMatrix(self:GetWorldTransformMatrix())
		end
		
		render.SetMaterial(data.Material)
		data.Mesh:Draw()
		cam.PopModelMatrix()
	else
		self:DrawModel()
	end
end

function ENT:GetRenderMesh()
	if self.custom_mesh then
		if self.custom_mesh_data[self.custom_mesh] then
			return { Mesh = self.custom_mesh, Material = self.Material--[[, Matrix = self.render_matrix]] }
		else
			self.custom_mesh = nil
		end
	end
end

net.Receive("starfall_hologram", function()
	local index = net.ReadUInt(16)
	local updateScale, scale = net.ReadBool()
	if updateScale then scale = Vector(net.ReadFloat(), net.ReadFloat(), net.ReadFloat()) end
	local updateSuppressEngineLighting, suppressEngineLighting = net.ReadBool()
	if updateSuppressEngineLighting then suppressEngineLighting = net.ReadBool() end
	local updateClips, clipdata = net.ReadBool()
	if updateClips then clipdata = SF.StringStream(net.ReadData(net.ReadUInt(32))) end

	local function applyHologram(self)
		if self.IsSFHologram then
			if updateScale then
				SF.SetHologramScale(self, scale)
			end
			if updateSuppressEngineLighting then
				self.suppressEngineLighting = suppressEngineLighting
			end
			if updateClips then
				local clips = {}
				for i=1, math.Round(#clipdata.buffer/34) do
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
	end

	SF.WaitForEntity(index, applyHologram)
end)

-- For when the hologram matrix gets cleared
hook.Add("NetworkEntityCreated", "starfall_hologram_rescale", function(holo)
	if holo.IsSFHologram and holo.HoloMatrix then
		holo:EnableMatrix("RenderMultiply", holo.HoloMatrix)
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
