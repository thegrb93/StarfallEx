
local checktype = SF.CheckType
local checkluatype = SF.CheckLuaType

--- Mesh library.
-- @shared
local mesh_library = SF.RegisterLibrary("mesh")

local thread_meta, thread_lib
SF.AddHook("postload", function()
	thread_lib = SF.Libraries.coroutine
	thread_meta = SF.Coroutine.Metatable
end)

function SF.ParseObj(obj, thread, Vector, triangulate)
	local pos, norm, uv, face = {}, {}, {}, {}
	local map = {
		v = function(f) pos[#pos + 1] = Vector(tonumber(f()), tonumber(f()), tonumber(f())) end,
		vt = function(f) uv[#uv + 1] = tonumber(f()) uv[#uv + 1] = 1-tonumber(f()) end,
		vn = function(f) norm[#norm + 1] = Vector(tonumber(f()), tonumber(f()), tonumber(f())) end,
	}
	if triangulate then
		map.f = function(f) 
			local points = {}
			local c = 0
			for p in f do
				c = c + 1
				points[c] = p
			end
			for i = 2, c - 1 do
				local tri = #face
				face[tri + 3] = points[1]
				face[tri + 2] = points[i]
				face[tri + 1] = points[i+1]
			end
		end
	else
		map.f = function(f) local i = #face face[i + 3] = f() face[i + 2] = f() face[i + 1] = f() end
	end

	local ignore = { ["#"] = true, ["mtllib"] = true, ["usemtl"] = true, ["o"] = true, ["s"] = true, ["g"] = true }
	for line in string.gmatch(obj, "[^\r\n]+") do
		local components = {}
		local f = string.gmatch(line, "%S+")
		local tag = f()
		if tag and not ignore[tag] then
			local t = map[tag]
			if t then
				local ok, err = pcall(t, f)
				if not ok then SF.Throw("Failed to parse tag: ("..line..") "..err, 2) end
			else
				SF.Throw("Unknown tag in obj file: "..tag, 2)
			end
		end
		if thread then thread_lib.yield(thread) end
	end

	if #face<3 or #face%3~=0 then SF.Throw("Expected a multiple of 3 vertices for the mesh's triangles.", 2) end

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

	local v = Vector()
	local add = v.add or v.Add
	local dot = v.dot or v.Dot
	local cross = v.cross or v.Cross
	local normalize = v.normalize or v.Normalize

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

		add(tan1[i], sdir)
		add(tan1[i+1], sdir)
		add(tan1[i+2], sdir)

		add(tan2[i], tdir)
		add(tan2[i+1], tdir)
		add(tan2[i+2], tdir)
	end
	if thread then thread_lib.yield(thread) end

	for i = 1, #vertices do
		local n = vertices[i].normal
		local t = tan1[i]

		local tan = (t - n * dot(n, t))
		normalize(tan)

		local w = dot(cross(n, t), tan2[i]) < 0 and -1 or 1

		vertices[i].userdata = {tan[1], tan[2], tan[3], w}
	end
	if thread then thread_lib.yield(thread) end
	return vertices, {positions = pos, normals = norm, texturecoords = uv, faces = face}
end

--- Parses obj data into a table of vertices, normals, texture coordinates, colors, and tangents
-- @param obj The obj data
-- @param thread An optional thread object to gradually parse the data to prevent exceeding cpu
-- @param triangulate Whether to triangulate the faces
-- @return The table of vertices that can be passed to mesh.buildFromTriangles
function mesh_library.parseObj(obj, thread, triangulate)
	checkluatype (obj, TYPE_STRING)
	if thread ~= nil then checktype(thread, thread_meta) end
	if triangulate ~= nil then checkluatype(triangulate, TYPE_BOOL) end

	return SF.ParseObj(obj, thread, SF.DefaultEnvironment.Vector, triangulate)
end


