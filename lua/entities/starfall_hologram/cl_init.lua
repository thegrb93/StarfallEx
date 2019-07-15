include("shared.lua")
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.IsHologram = true
ENT.DefaultMaterial = Material( "hunter/myplastic" )
ENT.Material = ENT.DefaultMaterial

function ENT:Initialize()
	self.clips = {}
	self.suppressEngineLighting = false
end

function ENT:Draw()
	local clipCount = 0
	if next(self.clips) then
		render.EnableClipping(true)
		for _, clip in pairs(self.clips) do
			render.PushCustomClipPlane(clip.normal, clip.normal:Dot(clip.origin))
			clipCount = clipCount + 1
		end
	end

	local filter_mag, filter_min = self.filter_mag, self.filter_min
	if filter_mag then render.PushFilterMag(filter_mag) end
	if filter_min then render.PushFilterMin(filter_min) end
	
	if self.suppressEngineLighting then
		render.SuppressEngineLighting(true)
		self:DrawModel()
		render.SuppressEngineLighting(false)
	else
		self:DrawModel()
	end
	
	if filter_mag then render.PopFilterMag() end
	if filter_min then render.PopFilterMin() end

	for i=1, clipCount do
		render.PopCustomClipPlane()
	end
	render.EnableClipping(false)
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

-- For when the hologram matrix gets cleared
hook.Add("NetworkEntityCreated", "starfall_hologram_rescale", function(holo)
	if holo.HoloMatrix then
		holo:EnableMatrix("RenderMultiply", holo.HoloMatrix)
	end
end)

local function ShowHologramOwners()
	for _, ent in pairs(ents.GetAll()) do
		if ent.IsSFHologram then
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
