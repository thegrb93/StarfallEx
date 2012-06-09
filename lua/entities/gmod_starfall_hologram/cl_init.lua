include( "shared.lua" )

ENT.RenderGroup = RENDERGROUP_BOTH

-- ------------------------ MAIN FUNCTIONS ------------------------ --

function ENT:Initialize( )
	self.clips = {}
	self.unlit = false
	
	self:SetScale(Vector(1,1,1))
end

function ENT:Draw()
	self:SetupClipping()
	render.SuppressEngineLighting(self.unlit)
	
	self:DrawModel()
	
	render.SuppressEngineLighting( false )
	self:FinishClipping()
end

-- ------------------------ CLIPPING ------------------------ --

--- Updates a clip plane definition.
function ENT:UpdateClip(index, enabled, origin, normal, islocal)
	local clip = self.clips[index]
	if not clip then
		clip = {}
		self.clips[index] = clip
	end
	
	clip.enabled = enabled
	clip.normal = normal
	clip.origin = origin
	clip.islocal = islocal
end

--- Draw utility; do not call. Gets ready to render clipping
function ENT:SetupClipping()
	local l = #self.clips
	if l > 0 then
		render.EnableClipping( true )

		for i=1,l do
			local clip = self.clips[i]
			if clip.enabled then
				local norm = clip.normal
				local origin = clip.origin
				
				if clip.islocal then
					norm = self:LocalToWorld(norm) - self:GetPos()
					origin = self:LocalToWorld(origin)
				end
				
				render.PushCustomClipPlane(norm, norm:Dot(origin))
			end
		end
	end
end

--- Draw utility; do not call. Undo's ENT:SetupClipping
function ENT:FinishClipping()
	for i=1,#self.clips do render.PopCustomClipPlane() end
end

-- ------------------------ SCALING ------------------------ --

--- Sets the hologram scale
-- @param scale Vector scale
function ENT:SetScale(scale)
	self.scale = scale
	self:SetModelScale(scale)

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
