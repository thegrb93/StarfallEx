include("shared.lua")
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.DefaultMaterial = Material( "models/wireframe" )
ENT.Material = ENT.DefaultMaterial

function ENT:Initialize()
	self.rendermesh = Mesh(self.Material)
	self:DrawShadow(false)
	self:EnableCustomCollisions( true )
end

function ENT:BuildPhysics(mesh)
	self:PhysicsInitMultiConvex(mesh)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:EnableCustomCollisions(true)
end

function ENT:Think()
	local physobj = self:GetPhysicsObject()
	if physobj:IsValid() then
		physobj:SetPos( self:GetPos() )
		physobj:SetAngles( self:GetAngles() )
		physobj:EnableMotion(false)
		physobj:Sleep()
	end
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:GetRenderMesh()
	if self.custom_mesh then
		if self.custom_mesh_data[self.custom_mesh] then
			return { Mesh = self.custom_mesh, Material = self.Material--[[, Matrix = self.render_matrix]] }
		else
			self.custom_mesh = nil
		end
	else
		return { Mesh = self.rendermesh, Material = self.Material--[[, Matrix = self.render_matrix]] }
	end
end

function ENT:OnRemove()
	-- This is required because snapshots can cause OnRemove to run even if it wasn't removed.
	if self.rendermesh then
		timer.Simple(0, function()
			if self.rendermesh and not self:IsValid() then
				self.rendermesh:Destroy()
				self.rendermesh = nil
			end
		end)
	end
end

net.Receive("starfall_custom_prop", function()
	local index = net.ReadUInt(16)
	local self, data

	local function applyData()
		if not (self and self:IsValid() and data) then return end
		local stream = SF.StringStream(data)
		local physmesh = {}
		local mins, maxs = Vector(math.huge, math.huge, math.huge), Vector(-math.huge, -math.huge, -math.huge)
		for i=1, stream:readUInt32() do
			local convex = {}
			for o=1, stream:readUInt32() do
				local x, y, z = stream:readFloat(), stream:readFloat(), stream:readFloat()
				if x>maxs.x then maxs.x = x end
				if y>maxs.y then maxs.y = y end
				if z>maxs.z then maxs.z = z end
				if x<mins.x then mins.x = x end
				if y<mins.y then mins.y = y end
				if z<mins.z then mins.z = z end
				convex[o] = Vector(x, y, z)
			end
			physmesh[i] = convex
		end
		self:BuildPhysics(physmesh)

		local convexes = self:GetPhysicsObject():GetMeshConvexes()
		local rendermesh = convexes[1]
		for i=2, #convexes do
			for k, v in ipairs(convexes[i]) do
				rendermesh[#rendermesh+1] = v
			end
		end

		self.rendermesh:BuildFromTriangles(rendermesh)
		self:SetRenderBounds(mins, maxs)
		self:SetCollisionBounds(mins, maxs)
	end

	SF.WaitForEntity(index, function(e)
		if e:GetClass()=="starfall_prop" then
			self = e
			applyData()
		end
	end)

	net.ReadStream(nil, function(data_)
		data = util.Decompress(data_)
		applyData()
	end)
end)
