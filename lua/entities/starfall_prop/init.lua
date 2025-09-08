AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

util.AddNetworkString("starfall_custom_prop")

local ENT_META = FindMetaTable("Entity")
local Ent_GetTable = ENT_META.GetTable

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	self:PhysicsInitMultiConvex(self.sf_physmesh) self.sf_physmesh = nil
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:EnableCustomCollisions(true)
	self:DrawShadow(false)

	self.customForceMode = 0
	self.customForceLinear = Vector()
	self.customForceAngular = Vector()
	self.customShadowForce = {
		pos = Vector(),
		angle = Angle(),
		secondstoarrive = 1,
		dampfactor = 0.2,
		maxangular = 1000,
		maxangulardamp = 1000,
		maxspeed = 1000,
		maxspeeddamp = 1000,
		teleportdistance = 1000,
	}

	self:AddEFlags( EFL_FORCE_CHECK_TRANSMIT )
end

function ENT:EnableCustomPhysics(mode)
	local ent_tbl = Ent_GetTable(self)
	if mode then
		ent_tbl.customPhysicsMode = mode
		if not ent_tbl.hasMotionController then
			self:StartMotionController()
			ent_tbl.hasMotionController = true
		end
	else
		ent_tbl.customPhysicsMode = nil
		if ent_tbl.hasMotionController then
			self:StopMotionController()
			ent_tbl.hasMotionController = false
		end
	end
end

function ENT:PhysicsSimulate(physObj, dt)
	local ent_tbl = Ent_GetTable(self)
	local mode = ent_tbl.customPhysicsMode
	if mode == 1 then
		return ent_tbl.customForceAngular, ent_tbl.customForceLinear, ent_tbl.customForceMode
	elseif mode == 2 then
		ent_tbl.customShadowForce.deltatime = dt
		physObj:ComputeShadowControl(ent_tbl.customShadowForce)
		return SIM_NOTHING
	else
		return SIM_NOTHING
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:TransmitData(recip)
	net.Start("starfall_custom_prop")
	net.WriteReliableEntity(self)
	local stream = net.WriteStream(self.sfmeshdata, nil, true)
	if recip then net.Send(recip) else net.Broadcast() end
	return stream
end

SF.WaitForPlayerInit(function(ply)
	for k, v in ipairs(ents.FindByClass("starfall_prop")) do
		v:TransmitData(ply)
	end
end)


local maxCustomSize = CreateConVar("sf_props_custom_maxsize", "2048", FCVAR_ARCHIVE, "The max hull size of a custom prop")
local minVertexDistance = CreateConVar("sf_props_custom_minvertexdistance", "0.2", FCVAR_ARCHIVE, "The min distance between two vertices in a custom prop")
local maxVerticesPerConvex = CreateConVar("sf_props_custom_maxverticesperconvex", "300", FCVAR_ARCHIVE, "The max vertices allowed per convex")
local maxConvexesPerProp = CreateConVar("sf_props_custom_maxconvexesperprop", "10", FCVAR_ARCHIVE, "The max convexes per prop")

local customPropVertexLimit = SF.LimitObject("props_custom_vertices", "custom prop vertices", 14400, "The max vertices allowed to spawn custom props per player")

local function streamToMesh(meshdata)
	local maxConvexesPerProp = maxConvexesPerProp:GetInt()
	local maxVerticesPerConvex = maxVerticesPerConvex:GetInt()

	local meshConvexes = {}

	meshdata = SF.StringStream(util.Decompress(meshdata, 65536))
	local nConvexes = meshdata:readInt32()
	if nConvexes > maxConvexesPerProp then SF.Throw("Exceeded the max convexes per prop (" .. maxConvexesPerProp .. ")", 2) end
	for iConvex = 1, nConvexes do
		local nVertices = meshdata:readInt32()
		if nVertices>maxVerticesPerConvex then SF.Throw("Exceeded the max vertices per convex (" .. maxVerticesPerConvex .. ")", 2) end
		local convex = {}
		for iVertex = 1, nVertices do
			convex[iVertex] = Vector(meshdata:readFloat(), meshdata:readFloat(), meshdata:readFloat())
		end
		meshConvexes[iConvex] = convex
	end

	return meshConvexes
end

local function meshToStream(meshConvexes)
	local meshdata = SF.StringStream()
	meshdata:writeInt32(#meshConvexes)
	for _, convex in ipairs(meshConvexes) do
		meshdata:writeInt32(#convex)
		for _, vertex in ipairs(convex) do
			meshdata:writeFloat(vertex[1]) meshdata:writeFloat(vertex[2]) meshdata:writeFloat(vertex[3])
		end
	end
	return util.Compress(meshdata:getString())
end

local function checkMesh(ply, meshConvexes)
	local max = maxCustomSize:GetFloat()
	local mindist = minVertexDistance:GetFloat()^2
	local maxConvexesPerProp = maxConvexesPerProp:GetInt()
	local maxVerticesPerConvex = maxVerticesPerConvex:GetInt()

	if #meshConvexes > maxConvexesPerProp then SF.Throw("Exceeded the max convexes per prop (" .. maxConvexesPerProp .. ")", 2) end
	if #meshConvexes <= 0 then SF.Throw("Invalid number of convexes (" .. #meshConvexes .. ")", 2) end

	local totalVertices = 0
	for _, convex in ipairs(meshConvexes) do
		if #convex > maxVerticesPerConvex then SF.Throw("Exceeded the max vertices per convex (" .. maxVerticesPerConvex .. ")", 2) end
		if #convex < 4 then SF.Throw("Invalid number of vertices (" .. #convex .. ")", 2) end

		totalVertices = totalVertices + #convex
		customPropVertexLimit:checkuse(ply, totalVertices)

		for k, vertex in ipairs(convex) do
			if math.abs(vertex[1])>max or math.abs(vertex[2])>max or math.abs(vertex[3])>max then SF.Throw("The custom prop cannot exceed a hull size of " .. max, 2) end
			if vertex[1]~=vertex[1] or vertex[2]~=vertex[2] or vertex[3]~=vertex[3] then SF.Throw("Your mesh contains nan values!", 2) end
			for i=1, k-1 do
				if convex[i]:DistToSqr(vertex) < mindist then
					SF.Throw("No two vertices can have a distance less than " .. minVertexDistance:GetFloat(), 2)
				end
			end
		end
	end
end


local function createCustomProp(ply, pos, ang, sfmeshdata)
	local meshConvexes
	if isstring(sfmeshdata) then
		meshConvexes = streamToMesh(sfmeshdata)
	elseif istable(sfmeshdata) then
		meshConvexes = sfmeshdata
		sfmeshdata = meshToStream(meshConvexes)
	else
		SF.Throw("Invalid sfmeshdata", 2)
	end

	checkMesh(ply, meshConvexes)
	SF.NetBurst:use(ply, #sfmeshdata*8)

	local propent = ents.Create("starfall_prop")
	propent.sf_physmesh = meshConvexes

	propent.sfmeshdata = sfmeshdata
	propent:Spawn()
	
	local physobj = propent:GetPhysicsObject()
	if not physobj:IsValid() then
		propent:Remove()
		SF.Throw("Custom prop has invalid physics!", 2)
	end
	
	propent:SetPos(pos)
	propent:SetAngles(ang)
	propent:TransmitData()

	physobj:EnableCollisions(true)
	physobj:EnableDrag(true)
	physobj:Wake()

	local totalVertices = 0
	for k, v in ipairs(meshConvexes) do
		totalVertices = totalVertices + #v
	end
	customPropVertexLimit:free(ply, -totalVertices)
	propent:CallOnRemove("cleanupVertexLimit", function()
		customPropVertexLimit:free(ply, totalVertices)
	end)

	return propent
end
duplicator.RegisterEntityClass("starfall_prop", createCustomProp, "Pos", "Ang", "sfmeshdata")
SF.createCustomProp = createCustomProp
