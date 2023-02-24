-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local dgetmeta = debug.getmetatable


function SF.ParseObj(obj, thread_yield, Vector, triangulate)
	local meshes = {}
	local name, nextname
	local lines = string.gmatch(obj, "[^\r\n]+")

	local pos, norm, uv, faces = {}, {}, {}, {}
	local map = {
		v = function(f) pos[#pos + 1] = Vector(tonumber(f()), tonumber(f()), tonumber(f())) end,
		vt = function(f) uv[#uv + 1] = tonumber(f()) uv[#uv + 1] = 1-tonumber(f()) end,
		vn = function(f) norm[#norm + 1] = Vector(tonumber(f()), tonumber(f()), tonumber(f())) end,
	}
	local ignore = { ["#"] = true, ["mtllib"] = true, ["usemtl"] = true, ["s"] = true }

	while true do
		local timeToStop = false

		local face = {}
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

		local linen = 1
		for line in lines do
			local components = {}
			local f = string.gmatch(line, "%S+")
			local tag = f()
			if tag and not ignore[tag] then
				local t = map[tag]
				if t then
					local ok, err = pcall(t, f)
					if not ok then SF.Throw("Failed to parse tag: ("..line..") "..err, 3) end
				else
					if tag=="g" or tag=="o" then
						if name then
							nextname = f()
							goto KeepGoing
						end
						name = f()
					else
						SF.Throw("Unknown tag in obj file: "..tag, 3)
					end
				end
			end
			if thread_yield and linen%100==0 then thread_yield() end
			linen = linen + 1
		end
		timeToStop = true
		::KeepGoing::

		if not name then SF.Throw("The .obj group/object name is missing!", 3) end
		if #face<3 or #face%3~=0 then SF.Throw("Expected a multiple of 3 vertices for the mesh's triangles.", 3) end

		local vertices = {}
		for k, v in ipairs(face) do
			local vert = {}
			local f = string.gmatch(v, "([^/]*)/?")
			local posv = tonumber(f())
			if posv then
				vert.pos = pos[posv] or SF.Throw("Invalid face position index: "..tostring(posv), 3)
			else
				SF.Throw("Invalid face position index: "..tostring(posv), 3)
			end
			local texv = tonumber(f())
			if texv then
				local j = texv * 2
				vert.u = uv[j-1] or SF.Throw("Invalid face texture coordinate index: "..tostring(texv), 3)
				vert.v = uv[j] or SF.Throw("Invalid face texture coordinate index: "..tostring(texv), 3)
			else
				SF.Throw("Invalid face texture coordinate index: "..tostring(texv), 3)
			end
			local normv = tonumber(f())
			if normv then
				vert.normal = norm[normv] or SF.Throw("Invalid face normal index: "..tostring(normv), 3)
			else
				SF.Throw("Invalid face normal index: "..tostring(normv), 3)
			end
			vertices[k] = vert
			if thread_yield and k%100==0 then thread_yield() end
		end

		SF.GenerateTangents(vertices, thread_yield, Vector)

		if thread_yield then thread_yield() end
		meshes[name] = vertices
		faces[name] = face
		if timeToStop then break end
		name = nextname
		nextname = nil
	end
	return meshes, {positions = pos, normals = norm, texturecoords = uv, faces = faces}
end

function SF.GenerateTangents(vertices, thread_yield, Vector)
	-- Lengyel, Eric. “Computing Tangent Space Basis Vectors for an Arbitrary Mesh”. Terathon Software, 2001. http://terathon.com/code/tangent.html
	-- GLua version credit @willox https://github.com/CapsAdmin/pac3/pull/578/commits/43fa75c262cde661713cdaa9d1b09bc29ec796b4
	local tan1, tan2 = {}, {}
	for i = 1, #vertices do
		tan1[i] = Vector(0, 0, 0)
		tan2[i] = Vector(0, 0, 0)
		if thread_yield and i%100==0 then thread_yield() end
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
		if thread_yield and i%100==0 then thread_yield() end
	end
	if thread_yield then thread_yield() end

	for i = 1, #vertices do
		local n = vertices[i].normal
		local t = tan1[i]

		local tan = (t - n * dot(n, t))
		normalize(tan)

		local w = dot(cross(n, t), tan2[i]) < 0 and -1 or 1

		vertices[i].userdata = {tan[1], tan[2], tan[3], w}
		if thread_yield and i%100==0 then thread_yield() end
	end
end

function SF.GenerateUV(vertices, scale, Vector, Angle, worldtolocal)
	local v = Vector()
	local a = Angle()
	local cross = v.cross or v.Cross
	local getangle = v.getAngle or v.Angle

	local function uv(vertex, ang)
		local p = worldtolocal(vertex.pos, a, v, ang)
		vertex.u = p.y * scale
		vertex.v = p.z * scale
	end

	for i = 1, #vertices - 2, 3 do
		local a = vertices[i]
		local b = vertices[i + 1]
		local c = vertices[i + 2]
		local ang = getangle(cross(b.pos - a.pos, c.pos - a.pos))

		uv(a, ang)
		uv(b, ang)
		uv(c, ang)
	end
end

function SF.GenerateNormals(vertices, inverted, smoothrad, Vector)
	local v = Vector()
	local cross = v.cross or v.Cross
	local normalize = v.normalize or v.Normalize
	local dot = v.dot or v.Dot
	local add = v.add or v.Add
	local div = v.div or v.Div
	smoothrad = math.cos(smoothrad)

	if inverted then
		local org = cross
		cross = function(a, b)
			return org(b, a)
		end
	end

	for i = 1, #vertices - 2, 3 do
		local a = vertices[i]
		local b = vertices[i + 1]
		local c = vertices[i + 2]
		local norm = cross(b.pos - a.pos, c.pos - a.pos)
		normalize(norm)

		a.normal = norm
		b.normal = norm
		c.normal = norm
	end

	if smoothrad ~= 1 then
		local norms = setmetatable({},{__index = function(t,k) local r=setmetatable({},{__index=function(t,k) local r=setmetatable({},{__index=function(t,k) local r={} t[k]=r return r end}) t[k]=r return r end}) t[k]=r return r end})
		for _, vertex in ipairs(vertices) do
			local pos = vertex.pos
			local norm = norms[pos[1]][pos[2]][pos[3]]
			norm[#norm+1] = vertex.normal
		end

		for _, vertex in ipairs(vertices) do
			local normal = Vector()
			local count = 0
			local pos = vertex.pos

			for _, norm in ipairs(norms[pos[1]][pos[2]][pos[3]]) do
				if dot(vertex.normal, norm) >= smoothrad then
					add(normal, norm)
					count = count + 1
				end
			end

			if count > 1 then
				div(normal, count)
				vertex.normal = normal
			end
		end
	end
end


local quickhull
do
	local update_points
	local dist_to_line
	local dist_to_plane
	local face_vertices
	local create_initial_simplex3
	local wrap_points
	local find_lightfaces
	local next_horizon_edge
	local face_to_mesh_vertex

	function update_points( points )
		local changed = false
		for k, point in pairs( points ) do
			if not isValid(point.ent) then continue end
			local cur_pos = point.ent:getPos()
			if not changed and ( not point.vec or point.vec ~= cur_pos ) then changed = true end

			point.vec = cur_pos
			point.x = point.vec.x
			point.y = point.vec.y
			point.z = point.vec.z
			point.face = nil
		end
		return changed
	end

	function dist_to_line( point, line_p1, line_p2 )
		local d = (line_p2.vec - line_p1.vec) / line_p2.vec:getDistance(line_p1.vec)
		local v = point.vec - line_p1.vec
		local t = v:dot(d)
		local p = line_p1.vec + t * d;
		return p:getDistance(point.vec);
	end

	function dist_to_plane( point, plane )
		local d = point.vec:dot(plane.n) - plane.d
		if math.abs(d) < 5e-5 then return 0 end
		return d
	end

	function find_plane( p1, p2, p3 )
		local normal = (p3.vec - p1.vec):cross(p2.vec - p1.vec):getNormalized()
		local dist = normal:dot( p1.vec )
		return {a=normal.x,b=normal.y,c=normal.z,d=dist,n=normal}
	end

	function face_vertices( face )
		local first_edge = face.edge
		local cur_edge = first_edge

		local vertices = {}
		repeat
			vertices[#vertices + 1] = cur_edge.vert
			cur_edge = cur_edge.next
		until cur_edge == first_edge

		return unpack(vertices)
	end

	function create_initial_simplex3( points )
		-- Find base line
		local base_line_dist = 0
		local point1 = nil
		local point2 = nil
		for i=1,#points do
			local p1 = points[i]
			for j=i+1,#points do
				local p2 = points[j]
				local tmp_dist = p1.vec:getDistanceSqr(p2.vec)
				if tmp_dist > base_line_dist then
					base_line_dist = tmp_dist
					point1 = p1
					point2 = p2
				end
			end
		end

		-- Find 3rd point of base triangle
		local point3_dist = 0
		local point3 = nil
		for i=1,#points do
			local p = points[i]
			if p == point1 or p == point2 then continue end

			local tmp_dist = dist_to_line(p, point1, point2)
			if tmp_dist > point3_dist then
				point3_dist = tmp_dist
				point3 = p
			end
		end

		-- First face
		local he_face1 = {plane = find_plane( point1, point2, point3 ), points = {}}
		local he_f1_edge1 = {face = he_face1}
		local he_f1_edge2 = {face = he_face1}
		local he_f1_edge3 = {face = he_face1}
		he_f1_edge1.vert = {vec=point1.vec, point=point1}
		he_f1_edge2.vert = {vec=point2.vec, point=point2}
		he_f1_edge3.vert = {vec=point3.vec, point=point3}
		he_f1_edge1.next = he_f1_edge2
		he_f1_edge2.next = he_f1_edge3
		he_f1_edge3.next = he_f1_edge1
		he_f1_edge1.vert.edge = he_f1_edge1
		he_f1_edge2.vert.edge = he_f1_edge2
		he_f1_edge3.vert.edge = he_f1_edge3
		he_face1.edge = he_f1_edge1

		-- Second face
		local he_face2 = {plane = find_plane( point2, point1, point3 ), points = {}}
		local he_f2_edge1 = {face = he_face2}
		local he_f2_edge2 = {face = he_face2}
		local he_f2_edge3 = {face = he_face2}
		he_f2_edge1.vert = {vec=point2.vec, point=point2}
		he_f2_edge2.vert = {vec=point1.vec, point=point1}
		he_f2_edge3.vert = {vec=point3.vec, point=point3}
		he_f2_edge1.next = he_f2_edge2
		he_f2_edge2.next = he_f2_edge3
		he_f2_edge3.next = he_f2_edge1
		he_f2_edge1.vert.edge = he_f2_edge1
		he_f2_edge2.vert.edge = he_f2_edge2
		he_f2_edge3.vert.edge = he_f2_edge3
		he_face2.edge = he_f2_edge1

		-- Join faces
		he_f1_edge1.twin = he_f2_edge1
		he_f1_edge2.twin = he_f2_edge3
		he_f1_edge3.twin = he_f2_edge2
		he_f2_edge1.twin = he_f1_edge1
		he_f2_edge2.twin = he_f1_edge3
		he_f2_edge3.twin = he_f1_edge2

		point1.ignore = true
		point2.ignore = true
		point3.ignore = true
		return {he_face1,he_face2}
	end

	function wrap_points( points )
		local ret = {}
		for k, p in pairs( points ) do
			ret[#ret + 1] = {
				vec = p,
				face = nil
			}
		end
		return ret
	end

	function find_lightfaces( point, face, ret )
		if not ret then ret = {} end

		if face.lightface or dist_to_plane( point, face.plane ) <= 0 then
			return ret
		end

		face.lightface = true
		ret[#ret + 1] = face

		find_lightfaces( point, face.edge.twin.face, ret )
		find_lightfaces( point, face.edge.next.twin.face, ret )
		find_lightfaces( point, face.edge.next.next.twin.face, ret )

		return ret
	end

	function next_horizon_edge( horizon_edge )
		local cur_edge = horizon_edge.next
		while cur_edge.twin.face.lightface do
			cur_edge = cur_edge.twin.next
		end
		return cur_edge
	end

	function quickhull( points )
		local points = wrap_points( points )
		local faces = create_initial_simplex3( points )

		-- Assign points to faces
		for k, point in pairs(points) do
			if point.ignore then continue end
			for k1, face in pairs(faces) do
				face.points = face.points or {}
				if dist_to_plane( point, face.plane ) > 0 then
					face.points[#face.points + 1] = point
					point.face = face
					break
				end
			end
		end

		local face_list = {}  -- (linked list) Faces that been processed (although they can still be removed from list)
		local face_stack = {} -- Faces to be processed

		-- Push faces onto stack
		for k1, face in pairs(faces) do
			face_stack[#face_stack + 1] = face
		end

		while #face_stack > 0 do
			-- Pop face from stack
			local curface = face_stack[#face_stack]
			face_stack[#face_stack] = nil

			-- Ignore previous lightfaces
			if curface.lightface then continue end

			-- If no points, the face is processed
			if #curface.points == 0 then
				curface.list_parent = face_list
				face_list = {next=face_list, value=curface}

				continue
			end

			-- Find distant point
			local point_dist = 0
			local point = nil

			for _, p in pairs(curface.points) do
				local tmp_dist = dist_to_plane(p, curface.plane)
				if tmp_dist > point_dist then
					point_dist = tmp_dist
					point = p
				end
			end

			-- Find all faces visible to point
			local light_faces = find_lightfaces( point, curface )

			-- Find first horizon edge
			local first_horizon_edge = nil
			for k, face in pairs(light_faces) do
				if not face.edge.twin.face.lightface then
					first_horizon_edge = face.edge
				elseif not face.edge.next.twin.face.lightface then
					first_horizon_edge = face.edge.next
				elseif not face.edge.next.next.twin.face.lightface then
					first_horizon_edge = face.edge.next.next
				else continue end
				break
			end

			-- Find all horizon edges
			local horizon_edges = {}
			local current_horizon_edge = first_horizon_edge
			repeat
				current_horizon_edge = next_horizon_edge( current_horizon_edge )
				horizon_edges[#horizon_edges + 1] = current_horizon_edge
			until current_horizon_edge == first_horizon_edge

			-- Assign new faces
			for i=1, #horizon_edges do
				local cur_edge = horizon_edges[i]

				local he_face = {edge=cur_edge}

				local he_vert1 = {vec=cur_edge.vert.vec     , point=cur_edge.vert.point}
				local he_vert2 = {vec=cur_edge.next.vert.vec, point=cur_edge.next.vert.point}
				local he_vert3 = {vec=point.vec             , point=point}

				local he_edge1 = cur_edge
				local he_edge2 = {}
				local he_edge3 = {}

				he_edge1.next = he_edge2
				he_edge2.next = he_edge3
				he_edge3.next = he_edge1

				he_edge1.vert = he_vert1
				he_edge2.vert = he_vert2
				he_edge3.vert = he_vert3

				he_edge1.face = he_face
				he_edge2.face = he_face
				he_edge3.face = he_face

				he_vert1.edge = he_edge1
				he_vert2.edge = he_edge2
				he_vert3.edge = he_edge3

				he_face.plane = find_plane( he_vert1, he_vert2, he_vert3 )
				he_face.points = {}

				-- Assign points to new faces
				for k, lface in pairs(light_faces) do
					for k1, p in pairs(lface.points) do
						if dist_to_plane( p, he_face.plane ) > 0 then
							he_face.points[#he_face.points+1] = p
							p.face = he_face
							lface.points[k1] = nil -- This is ok since we are not adding new keys
						end
					end
				end
			end

			-- Connect new faces
			for i=1, #horizon_edges do
				local prev_i = (i-1-1)%#horizon_edges + 1
				local next_i = (i-1+1)%#horizon_edges + 1
				local prev_edge1 = horizon_edges[prev_i]
				local cur_edge1 = horizon_edges[i]
				local next_edge1 = horizon_edges[next_i]

				local prev_edge2 = prev_edge1.next

				local cur_edge2 = cur_edge1.next
				local cur_edge3 = cur_edge2.next

				local next_edge3 = next_edge1.next.next

				cur_edge2.twin = next_edge3
				cur_edge3.twin = prev_edge2
				face_stack[#face_stack + 1] = cur_edge1.face
			end
		end

		-- Convert linked list into array
		local ret_points_added = {}
		local ret_points = {}
		local ret_faces = {}
		local l = face_list
		while l.value do
			local face = l.value
			l = l.next
			if face.lightface then continue end -- Filter out invalid faces

			for k,vert in pairs({face_vertices(face)}) do
				local point = vert.point
				if ret_points_added[point] then continue end
				ret_points_added[point] = true
				ret_points[#ret_points + 1] = vert.point
			end
			ret_faces[#ret_faces+1] = face
		end

		return ret_faces, ret_points
	end

	local function findUV(point, textureVecs, texSizeX, texSizeY)
		local x,y,z = point.x, point.y, point.z
		local u = textureVecs[1].x * x + textureVecs[1].y * y + textureVecs[1].z * z + textureVecs[1].offset
		local v = textureVecs[2].x * x + textureVecs[2].y * y + textureVecs[2].z * z + textureVecs[2].offset
		return u/texSizeX, v/texSizeY
	end

	COLOR_WHITE = Color(255,255,255)
	function face_to_mesh_vertex(face, color, offset)
		local norm = face.plane.n

		local tv1 = ( norm:cross( math.abs( norm:dot( Vector(0,0,1) ) ) == 1 and Vector(0,1,0) or Vector(0,0,-1) ) ):cross( norm )
		local tv2 = norm:cross( tv1 )
		local textureVecs = {{x=tv2.x,y=tv2.y,z=tv2.z,offset=0},
							{x=tv1.x,y=tv1.y,z=tv1.z,offset=0}}-- texinfo.textureVecs

		local p1, p2, p3 = face_vertices(face)


		local u1,v1 = findUV(p1.vec, textureVecs, 32, 32)
		local u2,v2 = findUV(p2.vec, textureVecs, 32, 32)
		local u3,v3 = findUV(p3.vec, textureVecs, 32, 32)

		return  {pos=p1.vec-offset,color=color or COLOR_WHITE,normal=norm,u=u1,v=v1},
				{pos=p2.vec-offset,color=color or COLOR_WHITE,normal=norm,u=u2,v=v2},
				{pos=p3.vec-offset,color=color or COLOR_WHITE,normal=norm,u=u3,v=v3}
	end
end

SF.QuickHull = quickhull


-- Register privileges
SF.Permissions.registerPrivilege("mesh", "Create custom mesh", "Allows users to create custom meshes for rendering.", { client = {} })

-- 1M triangles is about 195.4M VRAM
local plyTriangleCount = SF.LimitObject("mesh_triangles", "total mesh triangles", 1000000, "How many triangles total can be loaded for meshes.")
local plyTriangleRenderBurst = SF.BurstObject("mesh_triangles", "rendered triangles", 50000, 50000, "Number of triangles that can be rendered per frame", "Number of triangles that can be drawn in a short period of time")
local plyMeshCount = SF.LimitObject("mesh", "total meshes", 1000, "How many meshes total can be loaded.")

function plyTriangleRenderBurst:calc(obj)
	local t = RealTime()
	local ret = math.min(obj.val + (t - obj.lasttick)/RealFrameTime() * self.rate, self.max)
	obj.lasttick = t
	return ret
end

--- Mesh library.
-- @name mesh
-- @class library
-- @libtbl mesh_library
SF.RegisterLibrary("mesh")

if CLIENT then
	--- Mesh type
	-- @name Mesh
	-- @class type
	-- @client
	-- @libtbl mesh_methods
	SF.RegisterType("Mesh", true, false)
end


return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end


local mesh_library = instance.Libraries.mesh
local thread_yield
local vector, angle, worldtolocal
instance:AddHook("initialize", function()
	vector = instance.env.Vector
	angle = instance.env.Angle
	worldtolocal = instance.env.worldToLocal
	thread_yield = instance.Libraries.coroutine.yield
end)

--- Parses obj data into a table of vertices, normals, texture coordinates, colors, and tangents
-- @param string obj The obj data
-- @param boolean? threaded Optional bool, use threading object that can be used to load the mesh over time to prevent hitting quota limit
-- @param boolean? triangulate Whether to triangulate the faces
-- @return table Table of Mesh tables. The keys correspond to the objs object names, and the values are tables of vertices that can be passed to mesh.createFromTable
-- @return table Table of Mesh data. {positions = positionData, normals = normalData, texturecoords = texturecoordData, faces = faceData}
function mesh_library.parseObj(obj, threaded, triangulate)
	checkluatype (obj, TYPE_STRING)
	if threaded ~= nil then checkluatype(threaded, TYPE_BOOL) if threaded and not coroutine.running() then SF.Throw("Tried to use threading while not in a thread!", 2) end end
	if triangulate ~= nil then checkluatype(triangulate, TYPE_BOOL) end

	return SF.ParseObj(obj, threaded and thread_yield, vector, triangulate)
end

--- Generates normal vectors for the provided vertices table
-- @param table vertices The table of vertices
-- @param boolean? inverted Optional bool, invert the normal
-- @param number? smooth_limit Optional number, smooths the normal based on the limit in radians
function mesh_library.generateNormals(vertices, inverted, smooth_limit)
	checkluatype(vertices, TYPE_TABLE)
	if inverted ~= nil then checkluatype(inverted, TYPE_BOOL) else inverted = false end
	if smooth_limit ~= nil then checkluatype(smooth_limit, TYPE_NUMBER) else smooth_limit = 0 end
	local nvertices = #vertices
	if nvertices<3 or nvertices%3~=0 then SF.Throw("Expected a multiple of 3 vertices.", 2) end

	SF.GenerateNormals(vertices, inverted, smooth_limit, vector)
end

--- Generates the uv for the provided vertices table
-- @param table vertices The table of vertices
-- @param number scale The scale of the uvs
function mesh_library.generateUV(vertices, scale)
	checkluatype(vertices, TYPE_TABLE)
	checkluatype(scale, TYPE_NUMBER)
	local nvertices = #vertices
	if nvertices<3 or nvertices%3~=0 then SF.Throw("Expected a multiple of 3 vertices.", 2) end

	SF.GenerateUV(vertices, scale, vector, angle, worldtolocal)
end

--- Generates the tangents for the provided vertices table
-- @param table vertices The table of vertices
function mesh_library.generateTangents(vertices)
	checkluatype(vertices, TYPE_TABLE)
	local nvertices = #vertices
	if nvertices<3 or nvertices%3~=0 then SF.Throw("Expected a multiple of 3 vertices.", 2) end

	SF.GenerateTangents(vertices, nil, vector)
end

if CLIENT then
	local meshData = {}
	instance.data.meshes = meshData

	local function destroyMesh(ply, mesh)
		plyTriangleCount:free(ply, meshData[mesh].ntriangles)
		plyMeshCount:free(ply, 1)
		mesh:Destroy()
		meshData[mesh] = nil
	end

	instance:AddHook("deinitialize", function()
		for mesh in pairs(meshData) do
			destroyMesh(instance.player, mesh)
		end
	end)

	local mesh_methods, mesh_meta, wrap, unwrap = instance.Types.Mesh.Methods, instance.Types.Mesh, instance.Types.Mesh.Wrap, instance.Types.Mesh.Unwrap
	local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
	local col_meta, cwrap, cunwrap = instance.Types.Color, instance.Types.Color.Wrap, instance.Types.Color.Unwrap
	local mwrap = instance.Types.VMatrix.Wrap

	local vertexCheck = {
		color = function(v) return dgetmeta(v) == col_meta end,
		normal = function(v) return dgetmeta(v) == vec_meta end,
		tangent = function(v) return dgetmeta(v) == vec_meta end,
		binormal = function(v) return dgetmeta(v) == vec_meta end,
		pos = function(v) return dgetmeta(v) == vec_meta end,
		u = isnumber,
		v = isnumber,
		userdata = function(v) return istable(v) and isnumber(v[1]) and isnumber(v[2]) and isnumber(v[3]) and isnumber(v[4]) end
	}

	local vertexUnwrap = {
		color = cunwrap,
		normal = vunwrap,
		tangent = vunwrap,
		binormal = vunwrap,
		pos = vunwrap,
		u = function(x) return x end,
		v = function(x) return x end,
		userdata = function(x) return x end
	}

	--- Creates a mesh from vertex data.
	-- @param table vertices Table containing vertex data. http://wiki.facepunch.com/gmod/Structures/MeshVertex
	-- @param boolean? threaded Optional bool, use threading object that can be used to load the mesh over time to prevent hitting quota limit. The thread will yield with number of vertices remaining to be processed. After 0 is yielded, the final expensive phase starts.
	-- @return Mesh Mesh object
	-- @client
	function mesh_library.createFromTable(vertices, threaded)
		checkpermission (instance, nil, "mesh")
		checkluatype (vertices, TYPE_TABLE)
		if threaded ~= nil then checkluatype(threaded, TYPE_BOOL) if threaded and not coroutine.running() then SF.Throw("Tried to use threading while not in a thread!", 2) end end

		local nvertices = #vertices
		if nvertices<3 or nvertices%3~=0 then SF.Throw("Expected a multiple of 3 vertices for the mesh's triangles.", 2) end
		if nvertices > 65535 then SF.Throw("The max number of vertices for a mesh is 65535.", 2) end
		local ntriangles = nvertices / 3

		plyTriangleCount:checkuse(instance.player, ntriangles)
		plyMeshCount:checkuse(instance.player, 1)

		local unwrapped = {}
		for i, vertex in ipairs(vertices) do
			local vert = {}
			for k, v in pairs(vertex) do
				if vertexCheck[k] and vertexCheck[k](v) then
					vert[k] = vertexUnwrap[k](v)
				else
					SF.Throw("Invalid vertex keyvalue: "..tostring(k).." "..tostring(v), 2)
				end
			end
			unwrapped[i] = vert
			if threaded and i%100==0 and i<#vertices then thread_yield(#vertices - i) end
		end

		if threaded then thread_yield(0) end
		local mesh = Mesh()
		mesh:BuildFromTriangles(unwrapped)
		meshData[mesh] = { ntriangles = ntriangles }
		plyTriangleCount:use(instance.player, ntriangles)
		plyMeshCount:use(instance.player, 1)
		return wrap(mesh)
	end

	--- Creates a mesh from an obj file. Only supports triangular meshes with normals and texture coordinates.
	-- @param string obj The obj file data
	-- @param boolean? threaded Optional bool, use threading object that can be used to load the mesh over time to prevent hitting quota limit
	-- @param boolean? triangulate Whether to triangulate faces. (Consumes more CPU)
	-- @return table Table of Mesh objects. The keys correspond to the objs object names
	-- @client
	function mesh_library.createFromObj(obj, threaded, triangulate)
		checkluatype (obj, TYPE_STRING)
		if threaded ~= nil then checkluatype(threaded, TYPE_BOOL) if threaded and not coroutine.running() then SF.Throw("Tried to use threading while not in a thread!", 2) end end
		if triangulate ~= nil then checkluatype(triangulate, TYPE_BOOL) end

		checkpermission (instance, nil, "mesh")

		local meshes = SF.ParseObj(obj, threaded and thread_yield, Vector, triangulate)
		for name, vertices in pairs(meshes) do
			if #vertices > 65535 then SF.Throw("The max number of vertices for a mesh is 65535.", 2) end
			local ntriangles = #vertices / 3
			plyTriangleCount:use(instance.player, ntriangles)
			plyMeshCount:use(instance.player, 1)

			local mesh = Mesh()
			mesh:BuildFromTriangles(vertices)
			meshData[mesh] = { ntriangles = ntriangles }
			meshes[name] = wrap(mesh)
			if threaded then thread_yield() end
		end
		return meshes
	end

	--- Creates a mesh without any vertex data.
	-- @return Mesh Mesh object
	-- @client
	function mesh_library.createEmpty()
		checkpermission(instance, nil, "mesh")

		plyMeshCount:use(instance.player, 1)

		local mesh = Mesh()
		meshData[mesh] = { ntriangles = 0 }
		return wrap(mesh)
	end

	local function wrapVertex(p)
		local tri = {}
		if p.color then tri.color = cwrap(p.color) end
		tri.normal = vwrap(p.normal)
		tri.tangent = vwrap(p.tangent)
		if p.binormal then tri.binormal = vwrap(p.binormal) end
		tri.pos = vwrap(p.pos)
		tri.u = p.u
		tri.v = p.v
		tri.userdata = p.userdata
		tri.weights = p.weights
		return tri
	end

	--- Returns a table of visual meshes of given model or nil if the model is invalid
	-- @param string model The full path to a model to get the visual meshes of.
	-- @param number? lod The lod of the model to use. Default 0.
	-- @param number? bodygroupMask The bodygroupMask of the model to use. Default 0.
	-- @return table A table of tables with the following format:  string material - The material of the specific mesh table triangles - A table of MeshVertex structures ready to be fed into IMesh:BuildFromTriangles table verticies - A table of MeshVertex structures representing all the vertexes of the mesh. This table is used internally to generate the "triangles" table. Each MeshVertex structure returned also has an extra table of tables field called "weights" with the following data:  number boneID - The bone this vertex is attached to number weight - How "strong" this vertex is attached to the bone. A vertex can be attached to multiple bones at once.
	-- @return table A table of tables with bone id keys with the following format:  number parent - The parent bone id Matrix matrix - pretransformed bone matrix
	-- @client
	function mesh_library.getModelMeshes(model, lod, bodygroupMask)
		checkluatype(model, TYPE_STRING)
		if lod~=nil then checkluatype(lod, TYPE_NUMBER) end
		if bodygroupMask~=nil then checkluatype(bodygroupMask, TYPE_NUMBER) end

		local mesh, bind_pose = util.GetModelMeshes( model, lod, bodygroupMask )
		local out_mesh, out_bind = {}, {}
		if mesh then
			for k, v in ipairs(mesh) do
				local triangles = {}
				local verts = {}
				out_mesh[k] = {triangles = triangles, material = v.material, verticies = verts}
				for o, p in ipairs(v.triangles) do
					triangles[o] = wrapVertex(p)
				end
				for o, p in ipairs(v.verticies) do
					verts[o] = wrapVertex(p)
				end
			end
		end

		if bind_pose then
			for bone, v in pairs(bind_pose) do
				out_bind[bone] = { parent = v.parent, matrix = mwrap(v.matrix) }
			end
		end
		return out_mesh, out_bind
	end

	--- Returns how many triangles can be created
	-- @return number Number of triangles that can be created
	-- @client
	function mesh_library.trianglesLeft()
		return plyTriangleCount:check(instance.player)
	end

	--- Returns how many triangles can be rendered
	-- @return number Number of triangles that can be rendered
	-- @client
	function mesh_library.trianglesLeftRender()
		return plyTriangleRenderBurst:check(instance.player)
	end

	local meshgenerating = false
	local prim_triangles = {
		[MATERIAL_LINES] = function(count) return (count * 2) / 3 end,
		[MATERIAL_LINE_LOOP] = function(count) return count / 3 end,
		[MATERIAL_LINE_STRIP] = function(count) return (count + 1) / 3 end,
		-- Disabled since it seems to crash the game
		-- [MATERIAL_POINTS] = function(count) return count / 3 end,
		[MATERIAL_POLYGON] = function(count) return count - 2 end,
		[MATERIAL_QUADS] = function(count) return count * 2 end,
		[MATERIAL_TRIANGLES] = function(count) return count end,
		[MATERIAL_TRIANGLE_STRIP] = function(count) return count end
	}
	--- Generates mesh data. If an Mesh object is passed, it will populate that mesh with the data. Otherwise, it will render directly to renderer.
	-- @param Mesh? mesh_obj Optional Mesh object, mesh to build. (default: nil)
	-- @param number prim_type Int, primitive type, see MATERIAL
	-- @param number prim_count Int, the amount of primitives
	-- @param function func The function provided that will generate the mesh vertices
	-- @client
	function mesh_library.generate(mesh_obj, prim_type, prim_count, func)
		if meshgenerating then SF.Throw("Dynamic mesh was already started.", 2) end

		checkpermission(instance, nil, "mesh")

		checkluatype(prim_type, TYPE_NUMBER)
		checkluatype(prim_count, TYPE_NUMBER)
		checkluatype(func, TYPE_FUNCTION)

		local prim_trifunc = prim_triangles[prim_type]
		if not prim_trifunc then SF.Throw("Invalid Primitive.", 2) end

		if prim_count<1 then SF.Throw("Can't generate with less than 1 primitive", 2) end
		if prim_count>8192 then SF.Throw("Can't generate more than 8192 primitives", 2) end
		prim_count = math.floor(prim_count)

		local tri_count = math.max(1, math.ceil(prim_trifunc(prim_count)))
		if mesh_obj == nil then
			if not instance.data.render.isRendering then SF.Throw("Not in rendering hook.", 2) end
			plyTriangleRenderBurst:use(instance.player, tri_count)
			meshgenerating = true
			mesh.Begin(prim_type, prim_count)
		else
			mesh_obj = unwrap(mesh_obj)
			local mesh_tbl = meshData[mesh_obj]
			if not mesh_tbl then SF.Throw("Tried to use invalid mesh.", 2) end
			-- Garrysmod bug, crash if mesh isn't empty
			if mesh_tbl.ntriangles ~= 0 then SF.Throw("mesh.generate requires an empty mesh to populate.", 2) end
			plyTriangleCount:use(instance.player, tri_count)
			mesh_tbl.ntriangles = tri_count
			meshgenerating = mesh_obj
			mesh.Begin(mesh_obj, prim_type, prim_count)
		end

		instance.canyield = false
		local ok, err = pcall(func)
		instance.canyield = true
		mesh.End()
		meshgenerating = false
		if not ok then error(err) end
	end

	--- Sets the vertex color by RGBA values
	-- @param number r Number, red value
	-- @param number g Number, green value
	-- @param number b Number, blue value
	-- @param number a Number, alpha value
	-- @client
	function mesh_library.writeColor(r, g, b, a)
		mesh.Color(r, g, b, a)
	end

	--- Sets the vertex normal
	-- @param Vector normal Normal
	-- @client
	function mesh_library.writeNormal(normal)
		mesh.Normal(vunwrap(normal))
	end

	--- Sets the vertex position
	-- @param Vector position Position
	-- @client
	function mesh_library.writePosition(pos)
		mesh.Position(vunwrap(pos))
	end

	--- Sets the vertex texture coordinates
	-- @param number stage Stage of the texture coordinate
	-- @param number u U coordinate
	-- @param number v V coordinate
	-- @client
	function mesh_library.writeUV(stage, u, v)
		mesh.TexCoord(stage, u, v)
	end

	--- Sets the vertex tangent user data
	-- @param number x x
	-- @param number y y
	-- @param number z z
	-- @param number handedness
	-- @client
	function mesh_library.writeUserData(x, y, z, handedness)
		mesh.UserData(x, y, z, handedness)
	end

	--- Draws a quad using 4 vertices
	-- @param Vector v1 Vertex1 position
	-- @param Vector v2 Vertex2 position
	-- @param Vector v3 Vertex3 position
	-- @param Vector v4 Vertex4 position
	-- @client
	function mesh_library.writeQuad(v1, v2, v3, v4)
		mesh.Quad(vunwrap(v1), vunwrap(v2), vunwrap(v3), vunwrap(v4))
	end

	--- Draws a quad using a position, normal and size
	-- @param Vector position
	-- @param Vector normal
	-- @param number w
	-- @param number h
	-- @client
	function mesh_library.writeQuadEasy(position, normal, w, h)
		mesh.QuadEasy(vunwrap(position), vunwrap(normal), w, h)
	end

	--- Pushes the vertex data onto the render stack
	-- @client
	function mesh_library.advanceVertex()
		mesh.AdvanceVertex()
	end

	--- Draws the mesh. Must be in a 3D rendering context.
	-- @client
	function mesh_methods:draw()
		local mesh = unwrap(self)
		local meshdata = meshData[mesh]
		if not meshdata then SF.Throw("Tried to use invalid mesh.", 2) end
		if not instance.data.render.isRendering then SF.Throw("Not in rendering hook.", 2) end
		plyTriangleRenderBurst:use(instance.player, meshdata.ntriangles)
		mesh:Draw()
	end

	--- Frees the mesh from memory
	-- @client
	function mesh_methods:destroy()
		local mesh = unwrap(self)
		if not meshData[mesh] then SF.Throw("Tried to use invalid mesh.", 2) end
		if meshgenerating == mesh then SF.Throw("Cannot destroy mesh currently being generated.", 2) end
		destroyMesh(instance.player, mesh)
	end
end

end

