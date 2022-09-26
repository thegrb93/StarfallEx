-- Global to all starfalls
local checkluatype = SF.CheckLuaType

-- Register privileges
SF.Permissions.registerPrivilege("trace", "Trace", "Allows the user to start traces")
SF.Permissions.registerPrivilege("trace.decal", "Decal Trace", "Allows the user to apply decals with traces")

local plyDecalBurst = SF.BurstObject("decals", "decals", 50, 50, "Rate decals can be created per second.", "Number of decals that can be created in a short time.")

local function checkvector(pos)
	if pos[1] ~= pos[1] or pos[1] == math.huge or pos[1] == -math.huge then SF.Throw("Inf or nan vector in trace position", 3) end
	if pos[2] ~= pos[2] or pos[2] == math.huge or pos[2] == -math.huge then SF.Throw("Inf or nan vector in trace position", 3) end
	if pos[3] ~= pos[3] or pos[3] == math.huge or pos[3] == -math.huge then SF.Throw("Inf or nan vector in trace position", 3) end
end


--- Provides functions for doing line/AABB traces
-- @name trace
-- @class library
-- @libtbl trace_library
SF.RegisterLibrary("trace")

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
	checkpermission(instance, nil, "trace")
	checkvector(start)
	checkvector(endpos)

	local start, endpos = vunwrap(start), vunwrap(endpos)

	filter = convertFilter(filter)
	if mask ~= nil then checkluatype (mask, TYPE_NUMBER) end
	if colgroup ~= nil then checkluatype (colgroup, TYPE_NUMBER) end
	if ignworld ~= nil then checkluatype (ignworld, TYPE_BOOL) end

	local trace = {
		start = start,
		endpos = endpos,
		filter = filter,
		mask = mask,
		collisiongroup = colgroup,
		ignoreworld = ignworld,
	}

	return SF.StructWrapper(instance, util.TraceLine(trace), "TraceResult")
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
	checkpermission(instance, nil, "trace")
	checkvector(start)
	checkvector(endpos)
	checkvector(minbox)
	checkvector(maxbox)

	local start, endpos, minbox, maxbox = vunwrap(start), vunwrap(endpos), vunwrap(minbox), vunwrap(maxbox)

	filter = convertFilter(filter)
	if mask ~= nil then checkluatype (mask, TYPE_NUMBER) end
	if colgroup ~= nil then checkluatype (colgroup, TYPE_NUMBER) end
	if ignworld ~= nil then checkluatype (ignworld, TYPE_BOOL) end

	local trace = {
		start = start,
		endpos = endpos,
		filter = filter,
		mask = mask,
		collisiongroup = colgroup,
		ignoreworld = ignworld,
		mins = minbox,
		maxs = maxbox
	}

	return SF.StructWrapper(instance, util.TraceHull(trace), "TraceResult")
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
	local pos, normal, fraction = util.IntersectRayWithOBB(vunwrap(rayStart), vunwrap(rayDelta), vunwrap(boxOrigin), aunwrap(boxAngles), vunwrap(boxMins), vunwrap(boxMaxs))
	if pos then return vwrap(pos), vwrap(normal), fraction end
end

--- Does a ray plane intersection returning the position hit or nil if not hit
-- @param Vector rayStart The origin of the ray
-- @param Vector rayDelta The direction and length of the ray
-- @param Vector planeOrigin The origin of the plane
-- @param Vector planeNormal The normal of the plane
-- @return Vector? Hit position or nil if not hit
function trace_library.intersectRayWithPlane(rayStart, rayDelta, planeOrigin, planeNormal)
	local pos = util.IntersectRayWithPlane(vunwrap(rayStart), vunwrap(rayDelta), vunwrap(planeOrigin), vunwrap(planeNormal))
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

	local start, endpos = vunwrap(start), vunwrap(endpos)

	if filter ~= nil then checkluatype(filter, TYPE_TABLE) filter = convertFilter(filter) end

	plyDecalBurst:use(instance.player, 1)
	util.Decal( name, start, endpos, filter )
end

--- Returns the contents of the position specified.
-- @param Vector position The position to get the CONTENTS of
-- @return number Contents bitflag, see the CONTENTS enums
function trace_library.pointContents(position)
	return util.PointContents(vunwrap(position))
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
	return vwrap(util.AimVector(aunwrap(viewAngles), viewFOV, x, y, screenWidth, screenHeight))
end

end
