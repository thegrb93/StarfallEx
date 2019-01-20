include("shared.lua")
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.DefaultMaterial = Material( "hunter/myplastic" )
ENT.Material = ENT.DefaultMaterial

function ENT:Initialize()
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
	self:DrawModel()
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
