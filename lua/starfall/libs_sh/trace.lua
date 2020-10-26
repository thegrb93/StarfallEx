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
-- @param start Start position
-- @param endpos End position
-- @param filter Entity/array of entities to filter, or a function callback with an entity arguement that returns whether the trace should hit
-- @param mask Trace mask
-- @param colgroup The collision group of the trace
-- @param ignworld Whether the trace should ignore world
-- @return Result of the trace https://wiki.facepunch.com/gmod/Structures/TraceResult
function trace_library.trace(start, endpos, filter, mask, colgroup, ignworld)
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
-- @param start Start position
-- @param endpos End position
-- @param minbox Lower box corner
-- @param maxbox Upper box corner
-- @param filter Entity/array of entities to filter, or a function callback with an entity arguement that returns whether the trace should hit
-- @param mask Trace mask
-- @param colgroup The collision group of the trace
-- @param ignworld Whether the trace should ignore world
-- @return Result of the trace https://wiki.facepunch.com/gmod/Structures/TraceResult
function trace_library.traceHull(start, endpos, minbox, maxbox, filter, mask, colgroup, ignworld)
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
--@param rayStart The origin of the ray
--@param rayDelta The direction and length of the ray
--@param boxOrigin The origin of the box
--@param boxAngles The box's angles
--@param boxMins The box min bounding vector
--@param boxMaxs The box max bounding vector
--@return Hit position or nil if not hit
--@return Hit normal or nil if not hit
--@return Hit fraction or nil if not hit
function trace_library.intersectRayWithOBB(rayStart, rayDelta, boxOrigin, boxAngles, boxMins, boxMaxs)
	local pos, normal, fraction = util.IntersectRayWithOBB(vunwrap(rayStart), vunwrap(rayDelta), vunwrap(boxOrigin), aunwrap(boxAngles), vunwrap(boxMins), vunwrap(boxMaxs))
	if pos then return vwrap(pos), vwrap(normal), fraction end
end

--- Does a ray plane intersection returning the position hit or nil if not hit
--@param rayStart The origin of the ray
--@param rayDelta The direction and length of the ray
--@param planeOrigin The origin of the plane
--@param planeNormal The normal of the plane
--@return Hit position or nil if not hit
function trace_library.intersectRayWithPlane(rayStart, rayDelta, planeOrigin, planeNormal)
	local pos = util.IntersectRayWithPlane(vunwrap(rayStart), vunwrap(rayDelta), vunwrap(planeOrigin), vunwrap(planeNormal))
	if pos then return vwrap(pos) end
end

--- Does a line trace and applies a decal to wherever is hit
-- @param name The decal name, see https://wiki.facepunch.com/gmod/util.Decal
-- @param start Start position
-- @param endpos End position
-- @param filter (Optional) Entity/array of entities to filter
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
-- @param position The position to get the CONTENTS of
-- @return Contents bitflag, see the CONTENTS enums
function trace_library.pointContents(position)
	return util.PointContents(vunwrap(position))
end


-- Material Enumeration
-- @name trace.MAT
-- @class table
-- @field MAT_ANTLION
-- @field MAT_BLOODYFLESH
-- @field MAT_CONCRETE
-- @field MAT_DIRT
-- @field MAT_FLESH
-- @field MAT_GRATE
-- @field MAT_ALIENFLESH
-- @field MAT_CLIP
-- @field MAT_PLASTIC
-- @field MAT_METAL
-- @field MAT_SAND
-- @field MAT_FOLIAGE
-- @field MAT_COMPUTER
-- @field MAT_SLOSH
-- @field MAT_TILE
-- @field MAT_GRASS
-- @field MAT_VENT
-- @field MAT_WOOD
-- @field MAT_DEFAULT
-- @field MAT_GLASS
trace_library.MAT_ANTLION = MAT_ANTLION
trace_library.MAT_BLOODYFLESH = MAT_BLOODYFLESH
trace_library.MAT_CONCRETE = MAT_CONCRETE
trace_library.MAT_DIRT = MAT_DIRT
trace_library.MAT_FLESH = MAT_FLESH
trace_library.MAT_GRATE = MAT_GRATE
trace_library.MAT_ALIENFLESH = MAT_ALIENFLESH
trace_library.MAT_CLIP = MAT_CLIP
trace_library.MAT_PLASTIC = MAT_PLASTIC
trace_library.MAT_METAL = MAT_METAL
trace_library.MAT_SAND = MAT_SAND
trace_library.MAT_FOLIAGE = MAT_FOLIAGE
trace_library.MAT_COMPUTER = MAT_COMPUTER
trace_library.MAT_SLOSH = MAT_SLOSH
trace_library.MAT_TILE = MAT_TILE
trace_library.MAT_GRASS = MAT_GRASS
trace_library.MAT_VENT = MAT_VENT
trace_library.MAT_WOOD = MAT_WOOD
trace_library.MAT_DEFAULT = MAT_DEFAULT
trace_library.MAT_GLASS = MAT_GLASS

-- Hithroup Enumeration
-- @name trace.HITGROUP
-- @class table
-- @field HITGROUP_GENERIC
-- @field HITGROUP_HEAD
-- @field HITGROUP_CHEST
-- @field HITGROUP_STOMACH
-- @field HITGROUP_LEFTARM
-- @field HITGROUP_RIGHTARM
-- @field HITGROUP_LEFTLEG
-- @field HITGROUP_RIGHTLEG
-- @field HITGROUP_GEAR
trace_library.HITGROUP_GENERIC = HITGROUP_GENERIC
trace_library.HITGROUP_HEAD = HITGROUP_HEAD
trace_library.HITGROUP_CHEST = HITGROUP_CHEST
trace_library.HITGROUP_STOMACH = HITGROUP_STOMACH
trace_library.HITGROUP_LEFTARM = HITGROUP_LEFTARM
trace_library.HITGROUP_RIGHTARM = HITGROUP_RIGHTARM
trace_library.HITGROUP_LEFTLEG = HITGROUP_LEFTLEG
trace_library.HITGROUP_RIGHTLEG = HITGROUP_RIGHTLEG
trace_library.HITGROUP_GEAR = HITGROUP_GEAR

end
