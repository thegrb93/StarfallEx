include("shared.lua")

ENT.DefaultMaterial = Material( "hunter/myplastic" )
ENT.Material = ENT.DefaultMaterial

local VECTOR_PLAYER_COLOR_DISABLED = Vector(-1, -1, -1)
local IsValid = FindMetaTable("Entity").IsValid

local HoloRenderStack = SF.RenderStack({
	"return function(self, flags)",
	"self:DrawModel(flags)",
	"end"
},
{
	function(data)
		if data:GetCullMode() then
			return "render.CullMode(MATERIAL_CULLMODE_CW)", "render.CullMode(MATERIAL_CULLMODE_CCW)"
		end
	end,
	function(data)
		if data:GetSuppressEngineLighting() then
			return "render.SuppressEngineLighting(true)", "render.SuppressEngineLighting(false)"
		end
	end,
	function(data)
		if data.filter_min then
			return "render.PushFilterMin("..data.filter_min..")", "render.PopFilterMin()"
		end
	end,
	function(data)
		if data.filter_mag then
			return "render.PushFilterMag("..data.filter_mag..")", " render.PopFilterMag()"
		end
	end,
	function(data)
		if next(data.clips) then
			return 
[[local clipCount = 0
local prevClip = render.EnableClipping(true)
for _, clip in pairs(self.clips) do
	local clipent = clip.entity
	if IsValid(clipent) then
		local norm = clipent:LocalToWorld(clip.normal) - clipent:GetPos()
		render.PushCustomClipPlane(norm, norm:Dot(clipent:LocalToWorld(clip.origin)))
	else
		render.PushCustomClipPlane(clip.normal, clip.normal:Dot(clip.origin))
	end
	clipCount = clipCount + 1
end]],
[[for i=1, clipCount do
	render.PopCustomClipPlane()
end
render.EnableClipping(prevClip)]]
		end
	end,
	function(data)
		if data.AutomaticFrameAdvance then
			return nil, "self:FrameAdvance(0)"
		end
	end
})

function ENT:Initialize()
	self.clips = {}
	self.sf_userrenderbounds = false
	self:SetupBones()
	self:OnScaleChanged(nil, nil, self:GetScale())

	if self:EntIndex() == -1 then
		self:SetPlayerColorInternal(VECTOR_PLAYER_COLOR_DISABLED)
		-- Hack to fix parenting issues
		self:SetParent(Entity(0))
		self:SetParent()
	else
		self:OnPlayerColorChanged(nil, nil, self:GetPlayerColorInternal())
	end

	self.renderstack = HoloRenderStack:create(self)
end

function ENT:SetClip(index, enabled, normal, origin, entity)
	local clips = self.clips
	local prevempty = table.IsEmpty(clips)
	if enabled then
		clips[index] = {normal = normal, origin = origin, entity = entity}
	else
		clips[index] = nil
	end
	if prevempty~=table.IsEmpty(clips) then
		self.renderstack:makeDirty()
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
	self:SetupBones()
	if not self.sf_userrenderbounds then
		local mins, maxs = self:GetModelBounds()
		if mins then
			self:SetRenderBounds(mins * scale, maxs * scale)
		end
	end
end

function ENT:OnPlayerColorChanged(name, old, color)
	if color == VECTOR_PLAYER_COLOR_DISABLED then
		self.GetPlayerColor = nil -- The material proxy will break if this is not removed when disabling player color.
	else
		-- Having this function is what causes player color to actually be applied.
		-- https://github.com/garrynewman/garrysmod/blob/master/garrysmod/lua/matproxy/player_color.lua
		function self:GetPlayerColor()
			return color
		end
	end
end

function ENT:OnSuppressEngineLightingChanged()
	self.renderstack:makeDirty()
end

function ENT:OnCullModeChanged()
	self.renderstack:makeDirty()
end

function ENT:OnRenderGroupChanged(name, old, group)
	if group == -1 then
		self.RenderGroup = nil
	elseif SF.allowedRenderGroups[group] then
		self.RenderGroup = group
	end
end

function ENT:Draw(flags)
	self.renderstack:run(flags)
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
	local creationindex = net.ReadUInt(32)
	local clipdata = SF.StringStream(net.ReadData(net.ReadUInt(32)))

	local function applyHologramClips(self)
		if self and self.IsSFHologram then
			local clips = {}
			while clipdata:tell() <= clipdata:size() do
				local index = clipdata:readDouble()
				local clip = {
					normal = Vector(clipdata:readFloat(), clipdata:readFloat(), clipdata:readFloat()),
					origin = Vector(clipdata:readFloat(), clipdata:readFloat(), clipdata:readFloat()),
				}
				local entind = clipdata:readUInt16()
				if entind~=0 then
					local creationid = clipdata:readUInt32()
					SF.WaitForEntity(entind, creationid, function(e) clip.entity = e end)
				end
				clips[index] = clip
			end
			if table.IsEmpty(self.clips) ~= table.IsEmpty(clips) then
				self.renderstack:makeDirty()
			end
			self.clips = clips
		end
	end

	SF.WaitForEntity(index, creationindex, applyHologramClips)
end)

-- For when the hologram matrix gets cleared
hook.Add("NetworkEntityCreated", "starfall_hologram_rescale", function(holo)
	local sf_userrenderbounds = holo.sf_userrenderbounds
	if holo.IsSFHologram then
		if holo.HoloMatrix then
			holo:EnableMatrix("RenderMultiply", holo.HoloMatrix)
		end

		if not sf_userrenderbounds then        
			local mins, maxs = holo:GetModelBounds()
			if mins then
				local scale = holo:GetScale()
				holo:SetRenderBounds(mins * scale, maxs * scale)
			end
		end
	end

	if sf_userrenderbounds then
		holo:SetRenderBounds(sf_userrenderbounds[1], sf_userrenderbounds[2])
	end
end)

local function ShowHologramOwners()
	for _, ent in ents.Iterator() do
		if ent.IsSFHologram then
			local name = "No Owner"
			local steamID = ""
			local ply = SF.Permissions.getOwner(ent)
			if IsValid(ply) then
				name = ply:Name()
				steamID = ply:SteamID()
			else
				ply = ent.SFHoloOwner
				if IsValid(ply) then
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
