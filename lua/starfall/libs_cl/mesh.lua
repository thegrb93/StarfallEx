SF.Mesh = {}

-- Register privileges
SF.Permissions.registerPrivilege("mesh", "Create custom mesh", "Allows users to create custom meshes for rendering.", { ["Client"] = {} })

local maxtriangles = CreateClientConVar("sf_mesh_maxtriangles", "50000", true, "How many triangles total can be used for meshes")

--- Mesh type
-- @client
local mesh_methods, mesh_metamethods = SF.Typedef("Mesh")
local wrap, unwrap = SF.CreateWrapper(mesh_metamethods, true, false, debug.getregistry().IMesh)

--- Mesh library.
-- @client
local mesh_library = SF.Libraries.Register("mesh")

SF.Mesh.Wrap = wrap
SF.Mesh.Unwrap = unwrap
SF.Mesh.Methods = mesh_methods
SF.Mesh.Metatable = mesh_metamethods

local dgetmeta = debug.getmetatable
local col_meta, vec_meta
local vwrap, vunwrap, cwrap, cunwraplocal
local vertexCheck, vertexUnwrap
SF.Libraries.AddHook("postload", function()
	vec_meta = SF.Vectors.Metatable
	col_meta = SF.Color.Metatable

	vwrap = SF.Vectors.Wrap
	vunwrap = SF.Vectors.Unwrap
	cwrap = SF.Color.Wrap
	cunwrap = SF.Color.Unwrap

	vertexCheck = {
		color = col_meta,
		normal = vec_meta,
		tangent = vec_meta,
		binormal = vec_meta,
		pos = vec_meta,
		u = "number",
		v = "number"
	}
	vertexUnwrap = {
		color = cunwrap,
		normal = vunwrap,
		tangent = vunwrap,
		binormal = vunwrap,
		pos = vunwrap,
		u = function(x) return x end,
		v = function(x) return x end
	}
end)

local plyTriangleCount = {}

local function canAddTriangles(inst, triangles)
	local id = inst.playerid
	if plyTriangleCount[id] then
		if plyTriangleCount[id] + triangles>maxtriangles:GetInt() then
			SF.Throw("The triangle limit has been reached.", 3)
		end
	end
end

local function destroyMesh(id, mesh, meshdata)
	plyTriangleCount[id] = plyTriangleCount[id] - meshdata[mesh].ntriangles
	
	mesh:Destroy()
	meshdata[mesh] = nil
	
	if plyTriangleCount[id]==0 then plyTriangleCount[id] = nil end
end

-- Register functions to be called when the chip is initialised and deinitialised
SF.Libraries.AddHook("initialize", function (inst)
	inst.data.meshes = {}
end)

SF.Libraries.AddHook("deinitialize", function (inst)
	local meshes = inst.data.meshes
	local mesh = next(meshes)
	while mesh do
		destroyMesh(inst.playerid, mesh, meshes)
		mesh = next(meshes)
	end
end)

--- Creates a mesh from vertex data.
-- @param verteces Table containing vertex data. http://wiki.garrysmod.com/page/Structures/MeshVertex
-- @return Mesh object
function mesh_library.createFromTable (verteces)
	SF.Permissions.check(SF.instance.player, nil, "mesh")
	SF.CheckLuaType(verteces, TYPE_TABLE)
	
	local nvertices = #verteces
	if nvertices<3 or nvertices%3~=0 then SF.Throw("Expected a multiple of 3 vertices for the mesh's triangles.", 2) end
	local ntriangles = nvertices / 3
	
	local instance = SF.instance
	canAddTriangles(instance, ntriangles)
	
	local unwrapped = {}
	for i, vertex in ipairs(verteces) do
		local vert = {}
		for k, v in pairs(vertex) do
			if vertexCheck[k] and (dgetmeta(v)==vertexCheck[k] or type(v)==vertexCheck[k]) then
				vert[k] = vertexUnwrap[k](v)
			else
				SF.Throw("Invalid vertex keyvalue: "..tostring(k).." "..tostring(v), 2)
			end
		end
		unwrapped[i] = vert
	end
	
	plyTriangleCount[instance.playerid] = (plyTriangleCount[instance.playerid] or 0) + ntriangles
	
	local mesh = Mesh()
	mesh:BuildFromTriangles(unwrapped)
	instance.data.meshes[mesh] = { ntriangles = ntriangles }
	return wrap(mesh)
end

--- Creates a mesh from an obj file. Only supports triangular meshes with normals and texture coordinates.
-- @param obj The obj file data
-- @return Mesh object
function mesh_library.createFromObj (obj)
	SF.Permissions.check(SF.instance.player, nil, "mesh")
	SF.CheckLuaType(obj, TYPE_STRING)
	local instance = SF.instance
	
	local pos, norm, uv, face = {}, {}, {}, {}
	local map = {
		v = function(f) pos[#pos + 1] = Vector(tonumber(f()), tonumber(f()), tonumber(f())) end,
		vt = function(f) uv[#uv + 1] = tonumber(f()) uv[#uv + 1] = tonumber(f()) end,
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
	end
	
	plyTriangleCount[instance.playerid] = (plyTriangleCount[instance.playerid] or 0) + ntriangles
	
	local mesh = Mesh()
	mesh:BuildFromTriangles(vertices)
	instance.data.meshes[mesh] = { ntriangles = ntriangles }
	return wrap(mesh)
end

--- Returns how many triangles can be created
-- @return Number of triangles that can be created
function mesh_library.trianglesLeft ()
	if SF.Permissions.hasAccess(SF.instance.player, nil, "mesh") then
		return maxtriangles:GetInt() - (plyTriangleCount[SF.instance.playerid] or 0)
	else
		return 0
	end
end

--- Draws the mesh. Must be in a 3D rendering context.
function mesh_methods:draw()
	SF.CheckType(self, mesh_metamethods)
	local mesh = unwrap(self)
	local data = SF.instance.data
	if not data.meshes[mesh] then SF.Throw("Tried to use invalid mesh.", 2) end
	if not data.render.isRendering then SF.Throw("Not in rendering hook.", 2) end
	mesh:Draw()
end

--- Frees the mesh from memory
function mesh_methods:destroy()
	SF.CheckType(self, mesh_metamethods)
	local mesh = unwrap(self)
	local instance = SF.instance
	if not instance.data.meshes[mesh] then SF.Throw("Tried to use invalid mesh.", 2) end
	destroyMesh(instance.playerid, mesh, instance.data.meshes)
end


