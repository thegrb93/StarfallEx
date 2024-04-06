include("shared.lua")
ENT.RenderGroup = RENDERGROUP_OPAQUE

ENT.DefaultMaterial = Material( "models/wireframe" )
ENT.Material = ENT.DefaultMaterial

local IsValid = FindMetaTable("Entity").IsValid
local IsValidPhys = FindMetaTable("PhysObj").IsValid

function ENT:Initialize()
	self.rendermesh = Mesh(self.Material)
	self.rendermeshloaded = false
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
	if IsValidPhys(physobj) then
		physobj:SetPos( self:GetPos() )
		physobj:SetAngles( self:GetAngles() )
		physobj:EnableMotion(false)
		physobj:Sleep()
	end
end

function ENT:Draw()
	if self:GetColor().a ~= 255 then
		self.RenderGroup = RENDERGROUP_BOTH
	else
		self.RenderGroup = RENDERGROUP_OPAQUE
	end
	
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

function ENT:OnRemove(fullsnapshot)
	if fullsnapshot then return end
	local mesh = self.rendermesh
	if mesh then
		mesh:Destroy()
	end
end

net.Receive("starfall_custom_prop", function()
	local index = net.ReadUInt(16)
	local creationindex = net.ReadUInt(32)
	local self, data

	local function applyData()
		if not (IsValid(self) and data and not self.rendermeshloaded) then return end
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

		local phys = self:GetPhysicsObject()
		if IsValidPhys(phys) then
			local convexes = phys:GetMeshConvexes()
			local rendermesh = convexes[1]
			for i=2, #convexes do
				for k, v in ipairs(convexes[i]) do
					rendermesh[#rendermesh+1] = v
				end
			end

			-- less than 3 can crash
			if #rendermesh >= 3 then
				self.rendermesh:BuildFromTriangles(rendermesh)
			end
			self:SetRenderBounds(mins, maxs)
			self:SetCollisionBounds(mins, maxs)
		end
		self.rendermeshloaded = true
	end

	SF.WaitForEntity(index, creationindex, function(e)
		if e and e:GetClass()=="starfall_prop" then
			self = e
			applyData()
		end
	end)

	net.ReadStream(nil, function(data_)
		if data_ then
			data = util.Decompress(data_)
			applyData()
		end
	end)
end)
