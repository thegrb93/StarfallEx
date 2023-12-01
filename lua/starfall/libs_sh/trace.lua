-- Global to all starfalls
local checkluatype = SF.CheckLuaType

-- Register privileges
SF.Permissions.registerPrivilege("trace.decal", "Decal Trace", "Allows the user to apply decals with traces")

local plyDecalBurst = SF.BurstObject("decals", "decals", 50, 50, "Rate decals can be created per second.", "Number of decals that can be created in a short time.")

local math_huge = math.huge
local function checkvector(pos)
	local pos1 = pos[1]
	if pos1 ~= pos1 or pos1 == math_huge or pos1 == -math_huge then SF.Throw("Inf or nan vector in trace position", 3) end
	local pos2 = pos[2]
	if pos2 ~= pos2 or pos2 == math_huge or pos2 == -math_huge then SF.Throw("Inf or nan vector in trace position", 3) end
	local pos3 = pos[3]
	if pos3 ~= pos3 or pos3 == math_huge or pos3 == -math_huge then SF.Throw("Inf or nan vector in trace position", 3) end
end

--- Provides functions for doing line/AABB traces
-- @name trace
-- @class library
-- @libtbl trace_library
SF.RegisterLibrary("trace")

local structWrapper, util_TraceLine, util_TraceHull, util_IntersectRayWithOBB, util_IntersectRayWithPlane, util_Decal, util_PointContents, util_AimVector = SF.StructWrapper, util.TraceLine, util.TraceHull, util.IntersectRayWithOBB, util.IntersectRayWithPlane, util.Decal, util.PointContents, util.AimVector

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
		if ent_meta.sf2sensitive[filter]==nil then
			local l = {}
			for i, v in ipairs(filter) do
				l[i] = eunwrap(v)
			end
			return l
		else
			return eunwrap(filter)
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

--- Does a line trace
-- @param Vector start Start position
-- @param Vector endpos End position
-- @param Entity|table|function|nil filter Entity/array of entities to filter, or a function callback with an entity argument that returns whether the trace should hit
-- @param number? mask Trace mask
-- @param number? colgroup The collision group of the trace
-- @param boolean? ignworld Whether the trace should ignore world
-- @return table Result of the trace https://wiki.facepunch.com/gmod/Structures/TraceResult
function trace_library.line(start, endpos, filter, mask, colgroup, ignworld)
	return structWrapper(instance, util_TraceLine({
		start = vunwrap(start),
		endpos = vunwrap(endpos),
		filter = convertFilter(filter),
		mask = mask,
		collisiongroup = colgroup,
		ignoreworld = ignworld,
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
-- @return table Result of the trace https://wiki.facepunch.com/gmod/Structures/TraceResult
function trace_library.hull(start, endpos, minbox, maxbox, filter, mask, colgroup, ignworld)
	return structWrapper(instance, util_TraceHull({
		start = vunwrap(start),
		endpos = vunwrap(endpos),
		filter = convertFilter(filter),
		mask = mask,
		collisiongroup = colgroup,
		ignoreworld = ignworld,
		mins = vunwrap(minbox),
		maxs = vunwrap(maxbox),
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
	local pos, normal, fraction = util_IntersectRayWithOBB(vunwrap(rayStart), vunwrap(rayDelta), vunwrap(boxOrigin), aunwrap(boxAngles), vunwrap(boxMins), vunwrap(boxMaxs))
	if pos then return vwrap(pos), vwrap(normal), fraction end
end

--- Does a ray plane intersection returning the position hit or nil if not hit
-- @param Vector rayStart The origin of the ray
-- @param Vector rayDelta The direction and length of the ray
-- @param Vector planeOrigin The origin of the plane
-- @param Vector planeNormal The normal of the plane
-- @return Vector? Hit position or nil if not hit
function trace_library.intersectRayWithPlane(rayStart, rayDelta, planeOrigin, planeNormal)
	local pos = util_IntersectRayWithPlane(vunwrap(rayStart), vunwrap(rayDelta), vunwrap(planeOrigin), vunwrap(planeNormal))
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
	checkvector(start)
	checkvector(endpos)

	if filter ~= nil then checkluatype(filter, TYPE_TABLE) filter = convertFilter(filter) end

	plyDecalBurst:use(instance.player, 1)
	util_Decal(name, vunwrap(start), vunwrap(endpos), filter)
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
	return util_PointContents(vunwrap(position))
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
	return vwrap(util_AimVector(aunwrap(viewAngles), viewFOV, x, y, screenWidth, screenHeight))
end

end
