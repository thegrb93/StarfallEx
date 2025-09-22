include("shared.lua")

ENT.DefaultMaterial = Material( "models/wireframe" )
ENT.Material = ENT.DefaultMaterial

local Ent_IsValid = FindMetaTable("Entity").IsValid
local Phys_IsValid = FindMetaTable("PhysObj").IsValid
local Ent_GetTable = FindMetaTable("Entity").GetTable

function ENT:Initialize()
	self.sf_rendermesh = Mesh(self.Material)
	self.sf_meshapplied = false
	self:DrawShadow(false)
	self:EnableCustomCollisions( true )

	local mesh
	SF.CallOnRemove(self, "sf_prop",
	function() mesh = self.sf_rendermesh end,
	function() if mesh then mesh:Destroy() end end)
end

function ENT:BuildPhysics(ent_tbl, physmesh)
	ent_tbl.sf_physmesh = physmesh
	self:PhysicsInitMultiConvex(physmesh)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:EnableCustomCollisions(true)

	local phys = self:GetPhysicsObject()
	if Phys_IsValid(phys) then
		phys:SetMaterial(ent_tbl.GetPhysMaterial(self))
	end
end

function ENT:BuildRenderMesh(ent_tbl, rendermesh)
	local phys = self:GetPhysicsObject()
	if not Phys_IsValid(phys) then return end

	local convexes = phys:GetMeshConvexes()
	local rendermesh = convexes[1]
	for i=2, #convexes do
		for k, v in ipairs(convexes[i]) do
			rendermesh[#rendermesh+1] = v
		end
	end

	-- less than 3 can crash
	if #rendermesh < 3 then return end

	ent_tbl.sf_rendermesh:BuildFromTriangles(rendermesh)
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
		return { Mesh = ent_tbl.sf_rendermesh, Material = ent_tbl.Material--[[, Matrix = ent_tbl.render_matrix]] }
	end
end

local function streamToMesh(meshdata)
	local meshConvexes = {}
	local mins, maxs = Vector(math.huge, math.huge, math.huge), Vector(-math.huge, -math.huge, -math.huge)

	meshdata = SF.StringStream(util.Decompress(meshdata, 65536))
	local nConvexes = meshdata:readInt32()
	for iConvex = 1, nConvexes do
		local nVertices = meshdata:readInt32()
		local convex = {}
		for iVertex = 1, nVertices do
			local x, y, z = meshdata:readFloat(), meshdata:readFloat(), meshdata:readFloat()
			if x>maxs.x then maxs.x = x end
			if y>maxs.y then maxs.y = y end
			if z>maxs.z then maxs.z = z end
			if x<mins.x then mins.x = x end
			if y<mins.y then mins.y = y end
			if z<mins.z then mins.z = z end
			convex[iVertex] = Vector(x, y, z)
		end
		meshConvexes[iConvex] = convex
	end

	return meshConvexes, mins, maxs
end

net.Receive("starfall_custom_prop", function()

	local applyData = SF.WaitForAllArgs(2, function(self, data)
		if Ent_IsValid(self) and self:GetClass()~="starfall_prop" then return end
		local ent_tbl = Ent_GetTable(self)
		if not (ent_tbl and ent_tbl.sf_rendermesh:IsValid() and data and not ent_tbl.sf_meshapplied) then return end
		ent_tbl.sf_meshapplied = true

		local physmesh, mins, maxs = streamToMesh(data)
		ent_tbl.BuildPhysics(self, ent_tbl, physmesh)
		ent_tbl.BuildRenderMesh(self, ent_tbl)
		self:SetRenderBounds(mins, maxs)
		self:SetCollisionBounds(mins, maxs)
	end)

	net.ReadReliableEntity(function(self) applyData(self, nil) end)
	net.ReadStream(nil, function(data) applyData(nil, data) end)
end)

hook.Add("NetworkEntityCreated", "starfall_prop_physics", function(ent)
	local ent_tbl = Ent_GetTable(ent)
	local mesh = ent_tbl.sf_physmesh
	if mesh and not Phys_IsValid(ent:GetPhysicsObject()) then
		ent_tbl.BuildPhysics(ent, ent_tbl, mesh)
	end
end)

function ENT:OnPhysMaterialChanged(name, old, new)
	local phys = self:GetPhysicsObject()
	if Phys_IsValid(phys) then
		phys:SetMaterial(new)
	end
end
