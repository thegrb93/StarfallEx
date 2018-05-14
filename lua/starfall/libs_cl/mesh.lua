SF.Mesh = {}

-- Register privileges
SF.Permissions.registerPrivilege("mesh", "Create custom mesh", "Allows users to create custom meshes for rendering.", { client = {} })

local maxtriangles = CreateClientConVar("sf_mesh_maxtriangles", "200000", true, "How many triangles total can be loaded for meshes.")
local maxrendertriangles = CreateClientConVar("sf_mesh_maxrendertriangles", "50000", true, "How many triangles total can be rendered with meshes per frame.")

--- Mesh type
-- @client
local mesh_methods, mesh_metamethods = SF.RegisterType("Mesh")
local wrap, unwrap = SF.CreateWrapper(mesh_metamethods, true, false, debug.getregistry().IMesh)
local checktype = SF.CheckType
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check

--- Mesh library.
-- @client
local mesh_library = SF.RegisterLibrary("mesh")

SF.Mesh.Wrap = wrap
SF.Mesh.Unwrap = unwrap
SF.Mesh.Methods = mesh_methods
SF.Mesh.Metatable = mesh_metamethods

local dgetmeta = debug.getmetatable
local col_meta, vec_meta, thread_meta, thread_lib
local vwrap, vunwrap, cwrap, cunwraplocal, tunwrap
local vertexCheck, vertexUnwrap
SF.AddHook("postload", function()
	thread_lib = SF.Coroutine.Library
	vec_meta = SF.Vectors.Metatable
	col_meta = SF.Color.Metatable
	thread_meta = SF.Coroutine.Metatable

	vwrap = SF.Vectors.Wrap
	vunwrap = SF.Vectors.Unwrap
	cwrap = SF.Color.Wrap
	cunwrap = SF.Color.Unwrap
	tunwrap = SF.Coroutine.Unwrap

	vertexCheck = {
		color = function(v) return dgetmeta(v) == col_meta end,
		normal = function(v) return dgetmeta(v) == vec_meta end,
		tangent = function(v) return dgetmeta(v) == vec_meta end,
		binormal = function(v) return dgetmeta(v) == vec_meta end,
		pos = function(v) return dgetmeta(v) == vec_meta end,
		u = function(v) return type(v) == "number" end,
		v = function(v) return type(v) == "number" end,
		userdata = function(v) return type(v) == "table" and type(v[1]) == "number" and type(v[2]) == "number" and type(v[3]) == "number" and type(v[4]) == "number" end
	}
	vertexUnwrap = {
		color = cunwrap,
		normal = vunwrap,
		tangent = vunwrap,
		binormal = vunwrap,
		pos = vunwrap,
		u = function(x) return x end,
		v = function(x) return x end,
		userdata = function(x) return x end
	}
end)

local plyTriangleCount = SF.EntityTable("MeshTriangles")
local plyTriangleRenderBurst = SF.EntityTable("MeshBurst")

cvars.AddChangeCallback( "sf_mesh_maxrendertriangles", function()
	for k, v in pairs(plyTriangleRenderBurst) do
		local max = maxrendertriangles:GetFloat()*60
		v.max = max
		v.rate = max
	end
end)

local function canAddTriangles(inst, triangles)
	local ply = inst.player
	if plyTriangleCount[ply] then
		if plyTriangleCount[ply] + triangles>maxtriangles:GetInt() then
			SF.Throw("The triangle limit has been reached.", 3)
		end
	end
end

local function destroyMesh(ply, mesh, meshdata)
	plyTriangleCount[ply] = plyTriangleCount[ply] - meshdata[mesh].ntriangles

	mesh:Destroy()
	meshdata[mesh] = nil
end

-- Register functions to be called when the chip is initialised and deinitialised
SF.AddHook("initialize", function(inst)
	inst.data.meshes = {}
	if not plyTriangleCount[inst.player] then
		plyTriangleCount[inst.player] = 0
	end
	if not plyTriangleRenderBurst[inst.player] then
		plyTriangleRenderBurst[inst.player] = SF.BurstObject(maxrendertriangles:GetFloat() * 60, maxrendertriangles:GetFloat() * 60)
	end
end)

SF.AddHook("deinitialize", function(inst)
	local meshes = inst.data.meshes
	local mesh = next(meshes)
	while mesh do
		destroyMesh(inst.player, mesh, meshes)
		mesh = next(meshes)
	end
end)

--- Creates a mesh from vertex data.
-- @param verteces Table containing vertex data. http://wiki.garrysmod.com/page/Structures/MeshVertex
-- @param thread An optional thread object that can be used to load the mesh over time to prevent hitting quota limit
-- @return Mesh object
function mesh_library.createFromTable(verteces, thread)
	checkpermission (SF.instance, nil, "mesh")
	checkluatype (verteces, TYPE_TABLE)
	if thread ~= nil then checktype(thread, thread_meta) end

	local nvertices = #verteces
	if nvertices<3 or nvertices%3~=0 then SF.Throw("Expected a multiple of 3 vertices for the mesh's triangles.", 2) end
	local ntriangles = nvertices / 3

	local instance = SF.instance
	canAddTriangles(instance, ntriangles)

	local unwrapped = {}
	for i, vertex in ipairs(verteces) do
		local vert = {}
		for k, v in pairs(vertex) do
			if vertexCheck[k] and vertexCheck[k](v) then
				vert[k] = vertexUnwrap[k](v)
			else
				SF.Throw("Invalid vertex keyvalue: "..tostring(k).." "..tostring(v), 2)
			end
		end
		unwrapped[i] = vert
		if thread then thread_lib.yield(thread) end
	end

	plyTriangleCount[instance.player] = (plyTriangleCount[instance.player] or 0) + ntriangles

	local mesh = Mesh()
	mesh:BuildFromTriangles(unwrapped)
	instance.data.meshes[mesh] = { ntriangles = ntriangles }
	return wrap(mesh)
end

--- Creates a mesh from an obj file. Only supports triangular meshes with normals and texture coordinates.
-- @param obj The obj file data
-- @param thread An optional thread object that can be used to load the mesh over time to prevent hitting quota limit
-- @return Mesh object
function mesh_library.createFromObj(obj, thread)
	checkpermission (SF.instance, nil, "mesh")
	checkluatype (obj, TYPE_STRING)
	if thread ~= nil then checktype(thread, thread_meta) end
	local instance = SF.instance

	local pos, norm, uv, face = {}, {}, {}, {}
	local map = {
		v = function(f) pos[#pos + 1] = Vector(tonumber(f()), tonumber(f()), tonumber(f())) end,
		vt = function(f) uv[#uv + 1] = tonumber(f()) uv[#uv + 1] = 1-tonumber(f()) end,
		vn = function(f) norm[#norm + 1] = Vector(tonumber(f()), tonumber(f()), tonumber(f())) end,
		f = function(f) local i = #face face[i + 3] = f() face[i + 2] = f() face[i + 1] = f() end
	}
	local ignore = { ["#"] = true, ["mtllib"] = true, ["usemtl"] = true, ["o"] = true, ["s"] = true, ["g"] = true }
	for line in string.gmatch(obj, "[^\r\n]+") do
		local components = {}
		local f = string.gmatch(line, "%S+")
		local tag = f()
		if tag and not ignore[tag] then
			local t = map[tag]
			if t then
				local ok = pcall(t, f)
				if not ok then SF.Throw("Failed to parse tag: "..tag..". ("..line..")", 2) end
			else
				SF.Throw("Unknown tag in obj file: "..tag, 2)
			end
		end
		if thread then thread_lib.yield(thread) end
	end

	if #face<3 or #face%3~=0 then SF.Throw("Expected a multiple of 3 vertices for the mesh's triangles.", 2) end
	local ntriangles = #face / 3
	canAddTriangles(instance, ntriangles)

	local vertices = {}
	for _, v in ipairs(face) do
		local vert = {}
		local f = string.gmatch(v, "([^/]*)/?")
		local posv = tonumber(f())
		if posv then
			vert.pos = pos[posv] or SF.Throw("Invalid face position index: "..tostring(posv), 2)
		else
			SF.Throw("Invalid face position index: "..tostring(posv), 2)
		end
		local texv = tonumber(f())
		if texv then
			local j = texv * 2
			vert.u = uv[j-1] or SF.Throw("Invalid face texture coordinate index: "..tostring(texv), 2)
			vert.v = uv[j] or SF.Throw("Invalid face texture coordinate index: "..tostring(texv), 2)
		else
			SF.Throw("Invalid face texture coordinate index: "..tostring(texv), 2)
		end
		local normv = tonumber(f())
		if normv then
			vert.normal = norm[normv] or SF.Throw("Invalid face normal index: "..tostring(normv), 2)
		else
			SF.Throw("Invalid face normal index: "..tostring(normv), 2)
		end
		vertices[_] = vert
		if thread then thread_lib.yield(thread) end
	end

	plyTriangleCount[instance.player] = (plyTriangleCount[instance.player] or 0) + ntriangles

	local mesh = Mesh()
	mesh:BuildFromTriangles(vertices)
	instance.data.meshes[mesh] = { ntriangles = ntriangles }
	return wrap(mesh)
end

--- Returns how many triangles can be created
-- @return Number of triangles that can be created
function mesh_library.trianglesLeft ()
	if SF.Permissions.hasAccess(SF.instance, nil, "mesh") then
		return maxtriangles:GetInt() - (plyTriangleCount[SF.instance.player] or 0)
	else
		return 0
	end
end

--- Returns how many triangles can be rendered
-- @return Number of triangles that can be rendered
function mesh_library.trianglesLeftRender ()
	if SF.Permissions.hasAccess(SF.instance, nil, "mesh") then
		return plyTriangleRenderBurst[SF.instance.player]:check()
	else
		return 0
	end
end

--- Draws the mesh. Must be in a 3D rendering context.
function mesh_methods:draw()
	checktype(self, mesh_metamethods)
	local mesh = unwrap(self)
	local data = SF.instance.data
	local meshdata = data.meshes[mesh]
	if not meshdata then SF.Throw("Tried to use invalid mesh.", 2) end
	if not data.render.isRendering then SF.Throw("Not in rendering hook.", 2) end
	if not plyTriangleRenderBurst[SF.instance.player]:use(meshdata.ntriangles) then
		SF.Throw("Exceeded render limit!", 2)
	end
	mesh:Draw()
end

--- Frees the mesh from memory
function mesh_methods:destroy()
	checktype(self, mesh_metamethods)
	local mesh = unwrap(self)
	local instance = SF.instance
	if not instance.data.meshes[mesh] then SF.Throw("Tried to use invalid mesh.", 2) end
	destroyMesh(instance.player, mesh, instance.data.meshes)
end
