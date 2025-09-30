-- Global to all starfalls
local checkluatype = SF.CheckLuaType

-- Register privileges
SF.Permissions.registerPrivilege("trace.decal", "Decal Trace", "Allows the user to apply decals with traces")

local plyDecalBurst = SF.BurstObject("decals", "decals", 50, 50, "Rate decals can be created per second.", "Number of decals that can be created in a short time.")

local math_huge = math.huge

--- Provides functions for doing line/AABB traces
-- @name trace
-- @class library
-- @libtbl trace_library
SF.RegisterLibrary("trace")

local structWrapper, util_TraceLine, util_TraceHull, util_IntersectRayWithOBB, util_IntersectRayWithPlane, util_Decal, util_PointContents, util_AimVector = SF.StructWrapper, util.TraceLine, util.TraceHull, util.IntersectRayWithOBB, util.IntersectRayWithPlane, util.Decal, util.PointContents, util.AimVector

local vec_SetUnpacked = getmetatable(Vector(0, 0, 0)).SetUnpacked
local ang_SetUnpacked = getmetatable(Angle(0, 0, 0)).SetUnpacked

return function(instance)

local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local trace_library = instance.Libraries.trace
local owrap, ounwrap = instance.WrapObject, instance.UnwrapObject
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap

local function convertFilter(filter)
	if filter == nil then
		return nil
	elseif istable(filter) then
		local meta = debug.getmetatable(filter)
		if meta==ent_meta or (meta and meta.supertype==ent_meta) then
			return eunwrap(filter)
		else
			local l = {}
			for i, v in ipairs(filter) do
				l[i] = eunwrap(v)
			end
			return l
		end
	elseif isfunction(filter) then
		return function(ent)
			local ret = instance:runFunction(filter, owrap(ent))
			if ret[1] then return ret[2] end
		end
	else
		SF.ThrowTypeError("table or function", SF.GetType(filter), 3)
	end
end

local start_vec, endpos_vec, minbox_vec, maxbox_vec, origin_vec, angles_ang, normal_vec 
	= Vector(0, 0, 0), Vector(0, 0, 0), Vector(0, 0, 0), Vector(0, 0, 0), Vector(0, 0, 0), Angle(0, 0, 0), Vector(0, 0, 0)

--- Does a line trace
-- @param Vector start Start position
-- @param Vector endpos End position
-- @param Entity|table|function|nil filter Entity/array of entities to filter, or a function callback with an entity argument that returns whether the trace should hit
-- @param number? mask Trace mask
-- @param number? colgroup The collision group of the trace
-- @param boolean? ignworld Whether the trace should ignore world
-- @param boolean? whitelist Make 'filter' param array act as a hit whitelist instead of blacklist
-- @return table Result of the trace https://wiki.facepunch.com/gmod/Structures/TraceResult
function trace_library.line(start, endpos, filter, mask, colgroup, ignworld, whitelist)
	vec_SetUnpacked(start_vec, start[1], start[2], start[3])
	vec_SetUnpacked(endpos_vec, endpos[1], endpos[2], endpos[3])

	return structWrapper(instance, util_TraceLine({
		start = start_vec,
		endpos = endpos_vec,
		filter = convertFilter(filter),
		mask = mask,
		collisiongroup = colgroup,
		ignoreworld = ignworld,
		whitelist = whitelist,
	}), "TraceResult")
end

--- Does a swept-AABB trace
-- @param Vector start Start position
-- @param Vector endpos End position
-- @param Vector minbox Lower box corner
-- @param Vector maxbox Upper box corner
-- @param Entity|table|function|nil filter Entity/array of entities to filter, or a function callback with an entity argument that returns whether the trace should hit
-- @param number? mask Trace mask
-- @param number? colgroup The collision group of the trace
-- @param boolean? ignworld Whether the trace should ignore world
-- @param boolean? whitelist Make 'filter' param array act as a hit whitelist instead of blacklist
-- @return table Result of the trace https://wiki.facepunch.com/gmod/Structures/TraceResult
function trace_library.hull(start, endpos, minbox, maxbox, filter, mask, colgroup, ignworld, whitelist)
	vec_SetUnpacked(start_vec, start[1], start[2], start[3])
	vec_SetUnpacked(endpos_vec, endpos[1], endpos[2], endpos[3])
	vec_SetUnpacked(minbox_vec, minbox[1], minbox[2], minbox[3])
	vec_SetUnpacked(maxbox_vec, maxbox[1], maxbox[2], maxbox[3])

	OrderVectors(minbox_vec, maxbox_vec)

	return structWrapper(instance, util_TraceHull({
		start = start_vec,
		endpos = endpos_vec,
		filter = convertFilter(filter),
		mask = mask,
		collisiongroup = colgroup,
		ignoreworld = ignworld,
		mins = minbox_vec,
		maxs = maxbox_vec,
		whitelist = whitelist,
	}), "TraceResult")
end

--- Does a ray box intersection returning the position hit, normal, and trace fraction, or nil if not hit.
-- @param Vector rayStart The origin of the ray
-- @param Vector rayDelta The direction and length of the ray
-- @param Vector boxOrigin The origin of the box
-- @param Angle boxAngles The box's angles
-- @param Vector boxMins The box min bounding vector
-- @param Vector boxMaxs The box max bounding vector
-- @return Vector? Hit position or nil if not hit
-- @return Vector? Hit normal or nil if not hit
-- @return number? Hit fraction or nil if not hit
function trace_library.intersectRayWithOBB(rayStart, rayDelta, boxOrigin, boxAngles, boxMins, boxMaxs)
	vec_SetUnpacked(start_vec, rayStart[1], rayStart[2], rayStart[3])
	vec_SetUnpacked(endpos_vec, rayDelta[1], rayDelta[2], rayDelta[3])
	vec_SetUnpacked(origin_vec, boxOrigin[1], boxOrigin[2], boxOrigin[3])
	ang_SetUnpacked(angles_ang, boxAngles[1], boxAngles[2], boxAngles[3])
	vec_SetUnpacked(minbox_vec, boxMins[1], boxMins[2], boxMins[3])
	vec_SetUnpacked(maxbox_vec, boxMaxs[1], boxMaxs[2], boxMaxs[3])

	local pos, normal, fraction = util_IntersectRayWithOBB(start_vec, endpos_vec, origin_vec, angles_ang, minbox_vec, maxbox_vec)
	if pos then return vwrap(pos), vwrap(normal), fraction end
end

--- Performs a box-sphere intersection and returns whether there was an intersection or not.
-- @param Vector boxMins The minimum extents of the World Axis-Aligned box.
-- @param Vector boxMaxs The maximum extents of the World Axis-Aligned box.
-- @param Vector spherePos Position of the sphere.
-- @param number sphereRadius The radius of the sphere.
-- @return boolean true if there is an intersection, false otherwise.
function trace_library.isBoxIntersectingSphere(boxMins, boxMaxs, spherePos, sphereRadius)
	vec_SetUnpacked(minbox_vec, boxMins[1], boxMins[2], boxMins[3])
	vec_SetUnpacked(maxbox_vec, boxMaxs[1], boxMaxs[2], boxMaxs[3])
	vec_SetUnpacked(origin_vec, spherePos[1], spherePos[2], spherePos[3])
	return util.IsBoxIntersectingSphere(minbox_vec, maxbox_vec, origin_vec, sphereRadius)
end

--- Does a ray plane intersection returning the position hit or nil if not hit
-- @param Vector rayStart The origin of the ray
-- @param Vector rayDelta The direction and length of the ray
-- @param Vector planeOrigin The origin of the plane
-- @param Vector planeNormal The normal of the plane
-- @return Vector? Hit position or nil if not hit
function trace_library.intersectRayWithPlane(rayStart, rayDelta, planeOrigin, planeNormal)
	vec_SetUnpacked(start_vec, rayStart[1], rayStart[2], rayStart[3])
	vec_SetUnpacked(endpos_vec, rayDelta[1], rayDelta[2], rayDelta[3])
	vec_SetUnpacked(origin_vec, planeOrigin[1], planeOrigin[2], planeOrigin[3])
	vec_SetUnpacked(normal_vec, planeNormal[1], planeNormal[2], planeNormal[3])

	local pos = util_IntersectRayWithPlane(start_vec, endpos_vec, origin_vec, normal_vec)
	if pos then return vwrap(pos) end
end

--- Does a line trace and applies a decal to wherever is hit
-- @param string name The decal name, see https://wiki.facepunch.com/gmod/util.Decal
-- @param Vector start Start position
-- @param Vector endpos End position
-- @param Entity|table|nil filter (Optional) Entity/array of entities to filter
function trace_library.decal(name, start, endpos, filter)
	checkpermission(instance, nil, "trace.decal")
	checkluatype(name, TYPE_STRING)

	if filter ~= nil then checkluatype(filter, TYPE_TABLE) filter = convertFilter(filter) end

	vec_SetUnpacked(start_vec, start[1], start[2], start[3])
	vec_SetUnpacked(endpos_vec, endpos[1], endpos[2], endpos[3])

	plyDecalBurst:use(instance.player, 1)
	util_Decal(name, start_vec, endpos_vec, filter)
end

--- Returns True if player is allowed to use trace.decal
-- @return boolean Whether the decal trace can be used
function trace_library.canCreateDecal()
	return plyDecalBurst:check(instance.player) > 0
end

--- Returns the number of decals player is allowed to use
-- @return number The number of decals left
function trace_library.decalsLeft()
	return plyDecalBurst:check(instance.player)
end

--- Returns the contents of the position specified.
-- @param Vector position The position to get the CONTENTS of
-- @return number Contents bitflag, see the CONTENTS enums
function trace_library.pointContents(position)
	vec_SetUnpacked(endpos_vec, position[1], position[2], position[3])
	return util_PointContents(endpos_vec)
end

--- Calculates the aim vector from a 2D screen position. This is essentially a generic version of input.screenToVector, where you can define the view angles and screen size manually.
-- @param Angle viewAngles View angles
-- @param number viewFOV View field of view
-- @param number x X position on the screen
-- @param number y Y position on the screen
-- @param number screenWidth Screen width
-- @param number screenHeight Screen height
-- @return Vector The aim vector
function trace_library.aimVector(viewAngles, viewFOV, x, y, screenWidth, screenHeight)
	checkluatype(viewFOV, TYPE_NUMBER)
	checkluatype(x, TYPE_NUMBER)
	checkluatype(y, TYPE_NUMBER)
	checkluatype(screenWidth, TYPE_NUMBER)
	checkluatype(screenHeight, TYPE_NUMBER)
	ang_SetUnpacked(angles_ang, viewAngles[1], viewAngles[2], viewAngles[3])
	return vwrap(util_AimVector(angles_ang, viewFOV, x, y, screenWidth, screenHeight))
end

end
