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

	-- Lengyel, Eric. “Computing Tangent Space Basis Vectors for an Arbitrary Mesh”. Terathon Software, 2001. http://terathon.com/code/tangent.html
	-- GLua version credit @willox https://github.com/CapsAdmin/pac3/pull/578/commits/43fa75c262cde661713cdaa9d1b09bc29ec796b4
	local tan1, tan2 = {}, {}
	for i = 1, #vertices do
		tan1[i] = Vector(0, 0, 0)
		tan2[i] = Vector(0, 0, 0)
	end

	for i = 1, #vertices - 2, 3 do
		local vert1, vert2, vert3 = vertices[i], vertices[i+1], vertices[i+2]

		local p1, p2, p3 = vert1.pos, vert2.pos, vert3.pos
		local u1, u2, u3 = vert1.u, vert2.u, vert3.u
		local v1, v2, v3 = vert1.v, vert2.v, vert3.v

		local x1 = p2.x - p1.x;
		local x2 = p3.x - p1.x;
		local y1 = p2.y - p1.y;
		local y2 = p3.y - p1.y;
		local z1 = p2.z - p1.z;
		local z2 = p3.z - p1.z;

		local s1 = u2 - u1;
		local s2 = u3 - u1;
		local t1 = v2 - v1;
		local t2 = v3 - v1;

		local r = 1 / (s1 * t2 - s2 * t1)
		local sdir = Vector((t2 * x1 - t1 * x2) * r, (t2 * y1 - t1 * y2) * r, (t2 * z1 - t1 * z2) * r);
		local tdir = Vector((s1 * x2 - s2 * x1) * r, (s1 * y2 - s2 * y1) * r, (s1 * z2 - s2 * z1) * r);

		tan1[i]:Add(sdir)
		tan1[i+1]:Add(sdir)
		tan1[i+2]:Add(sdir)

		tan2[i]:Add(tdir)
		tan2[i+1]:Add(tdir)
		tan2[i+2]:Add(tdir)
	end
	if thread then thread_lib.yield(thread) end

	for i = 1, #vertices do
		local n = vertices[i].normal
		local t = tan1[i]

		local tan = (t - n * n:Dot(t))
		tan:Normalize()

		local w = (n:Cross(t)):Dot(tan2[i]) < 0 and -1 or 1

		vertices[i].userdata = {tan[1], tan[2], tan[3], w}
	end
	if thread then thread_lib.yield(thread) end

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
