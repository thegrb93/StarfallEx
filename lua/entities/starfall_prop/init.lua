AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

util.AddNetworkString("starfall_custom_prop")

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:PhysicsInitMultiConvex(self.Mesh)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:EnableCustomCollisions(true)
	self:DrawShadow(false)

	local convexes = self:GetPhysicsObject():GetMeshConvexes()
	local stream = SF.StringStream(data)
	stream:writeInt32(#convexes)
	for k, v in ipairs(convexes) do
		stream:writeInt32(#v)
		for o, p in ipairs(v) do
			local pos = p.pos
			stream:writeFloat(pos.x)
			stream:writeFloat(pos.y)
			stream:writeFloat(pos.z)
		end
	end
	self.Mesh = nil
	self.Data = stream:getString()

	net.Start("starfall_custom_prop")
	net.WriteUInt(self:EntIndex(), 16)
	net.WriteStream(self.Data)
	net.Broadcast()
end

function ENT:PreEntityCopy()
	-- if self.EntityMods then self.EntityMods.SFLink = nil end
	-- local info = {}
	-- if IsValid(self.link) then
		-- info.link = self.link:EntIndex()
	-- end
	-- local linkedvehicles = {}
	-- for k, v in pairs(vehiclelinks) do
		-- if v == self and k:IsValid() then
			-- linkedvehicles[#linkedvehicles + 1] = k:EntIndex()
		-- end
	-- end
	-- if #linkedvehicles > 0 then
		-- info.linkedvehicles = linkedvehicles
	-- end
	-- if info.link or info.linkedvehicles then
		-- duplicator.StoreEntityModifier(self, "SFLink", info)
	-- end
end

function ENT:PostEntityPaste (ply, ent, CreatedEntities)
	-- if ent.EntityMods and ent.EntityMods.SFLink then
		-- local info = ent.EntityMods.SFLink
		-- if info.link then
			-- local e = CreatedEntities[info.link]
			-- if IsValid(e) then
				-- self:LinkEnt(e)
			-- end
		-- end

		-- if info.linkedvehicles then
			-- for k, v in pairs(info.linkedvehicles) do
				-- local e = CreatedEntities[v]
				-- if IsValid(e) then
					-- self:LinkVehicle(e)
				-- end
			-- end
		-- end
	-- end
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
			if not changed and ( not point.vec or point.vec != cur_pos ) then changed = true end
			
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

	local function wrap_points( points )
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
