include("shared.lua")
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
	self.clips = {}

	--Hack to make scale work because self:EnableMatrix("RenderMultiply", self.render_matrix) doesn't work on join
	timer.Simple(1, function() self.scale = nil end)
end

function ENT:setupRenderGroup()
	if self:GetColor().a ~= 255 then
		self.RenderGroup = RENDERGROUP_BOTH
	else
		self.RenderGroup = RENDERGROUP_OPAQUE
	end
end

function ENT:Draw()
	self:setupRenderGroup()
	self:setupClip()
	self:setupScale()

	if self:GetSuppressEngineLighting() then
		render.SuppressEngineLighting(true)
		self:DrawModel()
		render.SuppressEngineLighting(false)
	else
		self:DrawModel()
	end

	self:finishClip()
end

function ENT:GetRenderMesh()
	if self.custom_mesh then
		if self.custom_meta_data[self.custom_mesh] then
			return { Mesh = self.custom_mesh, nil--[[Material = self.Material]], Matrix = self.render_matrix }
		else
			self.custom_mesh = nil
		end
	end
end

-- ------------------------ CLIPPING ------------------------ --

function ENT:setupClip()
	if next(self.clips) then
		render.EnableClipping(true)
		for _, clip in pairs(self.clips) do
			local norm, origin
			if clip.islocal then
				norm = self:LocalToWorld(clip.normal) - self:GetPos()
				origin = self:LocalToWorld(clip.origin)
			else
				norm = clip.normal
				origin = clip.origin
			end
			render.PushCustomClipPlane(norm, norm:Dot(origin))
		end
	end
end

function ENT:finishClip()
	for _, clip in pairs(self.clips) do
		render.PopCustomClipPlane()
	end
	render.EnableClipping(false)
end

--- Updates a clip plane definition.
function ENT:UpdateClip(index, enabled, origin, normal, islocal)
	if enabled then
		local clip = self.clips[index]
		if not clip then
			clip = {}
			self.clips[index] = clip
		end

		clip.normal = normal
		clip.origin = origin
		clip.islocal = islocal
	else
		self.clips[index] = nil
	end
end

net.Receive("starfall_hologram_clip", function ()
	local entid = net.ReadUInt(16)
	local clipid = net.ReadUInt(16)
	local enabled = net.ReadBit() ~= 0
	local origin = net.ReadVector()
	local normal = net.ReadVector()
	local islocal = net.ReadBit() ~= 0

	local holoent = Entity(entid)
	if holoent:IsValid() and holoent.UpdateClip then
		holoent:UpdateClip(clipid, enabled, origin, normal, islocal)
	else
		local timeout = CurTime()+0.5
		local hookname = "SF_HoloClip"..entid
		hook.Add("Think", hookname, function()
			if CurTime() < timeout then
				local holoent = Entity(entid)
				if holoent:IsValid() and holoent.UpdateClip then
					holoent:UpdateClip(clipid, enabled, origin, normal, islocal)
					hook.Remove("Think", hookname)
				end
			else
				net.Start("starfall_hologram_clip")
				net.WriteUInt(entid, 16)
				net.SendToServer()
				hook.Remove("Think", hookname)
			end
		end)
	end
end)

-- ------------------------ SCALING ------------------------ --

function ENT:setupScale()
	local scale = self:GetScale()
	if self.scale ~= scale then
		self.scale = scale
		if scale == Vector(1, 1, 1) then
			self.render_matrix = Matrix()
			self:DisableMatrix("RenderMultiply")
		else
			self.render_matrix = Matrix()
			self.render_matrix:Scale(scale)
			self:EnableMatrix("RenderMultiply", self.render_matrix)
		end

		local propmax = self:OBBMaxs()
		local propmin = self:OBBMins()

		propmax.x = scale.x * propmax.x
		propmax.y = scale.y * propmax.y
		propmax.z = scale.z * propmax.z
		propmin.x = scale.x * propmin.x
		propmin.y = scale.y * propmin.y
		propmin.z = scale.z * propmin.z

		self:SetRenderBounds(propmax, propmin)
	end
end

hook.Add("NetworkEntityCreated", "starfall_hologram_rescale", function(ent)
	-- Entity may not have its lua table yet so the only way is to check its class
	if not ent.clips and ent:GetClass()=="starfall_hologram" then
		net.Start("starfall_hologram_clip")
		net.WriteUInt(ent:EntIndex(), 16)
		net.SendToServer()
	end
end)

local function ShowHologramOwners()
	for _, ent in pairs(ents.FindByClass("starfall_hologram")) do
		local name = "No Owner"
		local steamID = ""
		local ply = SF.Permissions.getOwner(ent)
		if ply:IsValid() then
			name = ply:Name()
			steamID = ply:SteamID()
		end

		local vec = ent:GetPos():ToScreen()

		draw.DrawText(name .. "\n" .. steamID, "DermaDefault", vec.x, vec.y, Color(255, 0, 0, 255), 1)
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
