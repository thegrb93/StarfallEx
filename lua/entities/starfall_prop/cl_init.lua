include("shared.lua")
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.IsHologram = true
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

net.Receive("starfall_custom_prop", function()
	local index = net.ReadUInt(16)
	local self

	local function getEnt(e)
		if e:IsValid() and e:GetClass()=="starfall_prop" then
			self = e
			return true
		end
		return false
	end

	local function findEnt(f)
		local timeout = CurTime()+5
		local name = "SF_CustomPropUpdate"..index
		hook.Add("Think", name, function()
			if getEnt(Entity(index)) then
				f()
				hook.Remove("Think", name)
			elseif CurTime()>timeout then
				hook.Remove("Think", name)
			end
		end)
	end
	findEnt(function() end)

	local function applyData(data)
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
		for i=2, #rendermesh do
			for k, v in ipairs(rendermesh[i]) do
				rendermesh[#rendermesh+1] = {pos = v}
			end
		end

		self.rendermesh:BuildFromTriangles(rendermesh)
		self:SetRenderBounds(mins, maxs)
		self:SetCollisionBounds(mins, maxs)
	end

	net.ReadStream(nil, function(data)
		if data then
			if self then
				if self:IsValid() then
					applyData(data)
				end
			else
				findEnt(function() applyData(data) end)
			end
		end
	end)
end)
