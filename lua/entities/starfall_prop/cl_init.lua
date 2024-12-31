include("shared.lua")

ENT.DefaultMaterial = Material( "models/wireframe" )
ENT.Material = ENT.DefaultMaterial

local Ent_IsValid = FindMetaTable("Entity").IsValid
local Phys_IsValid = FindMetaTable("PhysObj").IsValid
local Ent_GetTable = FindMetaTable("Entity").GetTable

function ENT:Initialize()
	self.rendermesh = Mesh(self.Material)
	self.rendermeshloaded = false
	self:DrawShadow(false)
	self:EnableCustomCollisions( true )

	local mesh
	SF.CallOnRemove(self, "sf_prop",
	function() mesh = self.rendermesh end,
	function() if mesh then mesh:Destroy() end end)
end

function ENT:BuildPhysics(mesh)
	self:PhysicsInitMultiConvex(mesh)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:EnableCustomCollisions(true)
end

function ENT:Think()
	local physobj = self:GetPhysicsObject()
	if Phys_IsValid(physobj) then
		physobj:SetPos( self:GetPos() )
		physobj:SetAngles( self:GetAngles() )
		physobj:EnableMotion(false)
		physobj:Sleep()
	end
end

function ENT:Draw(flags)
	self:DrawModel(flags)
end

function ENT:GetRenderMesh()
	local ent_tbl = Ent_GetTable(self)
	if ent_tbl.custom_mesh then
		if ent_tbl.custom_mesh_data[ent_tbl.custom_mesh] then
			return { Mesh = ent_tbl.custom_mesh, Material = ent_tbl.Material--[[, Matrix = ent_tbl.render_matrix]] }
		else
			ent_tbl.custom_mesh = nil
		end
	else
		return { Mesh = ent_tbl.rendermesh, Material = ent_tbl.Material--[[, Matrix = ent_tbl.render_matrix]] }
	end
end

net.Receive("starfall_custom_prop", function()
	local self, data

	local function applyData()
		local ent_tbl = Ent_GetTable(self)
		if not (ent_tbl and ent_tbl.rendermesh:IsValid() and data and not ent_tbl.rendermeshloaded) then return end
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
		ent_tbl.sf_physmesh = physmesh
		ent_tbl.BuildPhysics(self, physmesh)

		local phys = self:GetPhysicsObject()
		if Phys_IsValid(phys) then
			local convexes = phys:GetMeshConvexes()
			local rendermesh = convexes[1]
			for i=2, #convexes do
				for k, v in ipairs(convexes[i]) do
					rendermesh[#rendermesh+1] = v
				end
			end

			-- less than 3 can crash
			if #rendermesh >= 3 then
				ent_tbl.rendermesh:BuildFromTriangles(rendermesh)
			end
			self:SetRenderBounds(mins, maxs)
			self:SetCollisionBounds(mins, maxs)
		end
		ent_tbl.rendermeshloaded = true
	end

	net.ReadReliableEntity(function(e)
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

hook.Add("NetworkEntityCreated", "starfall_prop_physics", function(ent)
	local ent_tbl = Ent_GetTable(ent)
	local mesh = ent_tbl.sf_physmesh
	if mesh and not Phys_IsValid(ent:GetPhysicsObject()) then
		ent_tbl.BuildPhysics(ent, mesh)
	end
end)
