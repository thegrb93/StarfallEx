-------------------------------------------------------------------------------
-- Trace library
-------------------------------------------------------------------------------

local dgetmeta = debug.getmetatable

local checktype = SF.CheckType
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check
--[[
-- Here's a neat little script to convert enumerations wiki.gmod.com-style
-- into something usable in code

local lines = <copy+paste enumeration with trailing \n here>

for line in lines:gmatch("([^\n]*)\n") do
 local v = line:match("^.*|%s*(.*)$")
 print("trace_library."..v.." = "..v)
end
]]

--- Provides functions for doing line/AABB traces
-- @shared
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
-- @field HITGROUP_GENERIC
-- @field HITGROUP_HEAD
-- @field HITGROUP_CHEST
-- @field HITGROUP_STOMACH
-- @field HITGROUP_LEFTARM
-- @field HITGROUP_RIGHTARM
-- @field HITGROUP_LEFTLEG
-- @field HITGROUP_RIGHTLEG
-- @field HITGROUP_GEAR
-- @field MASK_SPLITAREAPORTAL
-- @field MASK_SOLID_BRUSHONLY
-- @field MASK_WATER
-- @field MASK_BLOCKLOS
-- @field MASK_OPAQUE
-- @field MASK_VISIBLE
-- @field MASK_DEADSOLID
-- @field MASK_PLAYERSOLID_BRUSHONLY
-- @field MASK_NPCWORLDSTATIC
-- @field MASK_NPCSOLID_BRUSHONLY
-- @field MASK_CURRENT
-- @field MASK_SHOT_PORTAL
-- @field MASK_SOLID
-- @field MASK_BLOCKLOS_AND_NPCS
-- @field MASK_OPAQUE_AND_NPCS
-- @field MASK_VISIBLE_AND_NPCS
-- @field MASK_PLAYERSOLID
-- @field MASK_NPCSOLID
-- @field MASK_SHOT_HULL
-- @field MASK_SHOT
-- @field MASK_ALL
-- @field CONTENTS_EMPTY
-- @field CONTENTS_SOLID
-- @field CONTENTS_WINDOW
-- @field CONTENTS_AUX
-- @field CONTENTS_GRATE
-- @field CONTENTS_SLIME
-- @field CONTENTS_WATER
-- @field CONTENTS_BLOCKLOS
-- @field CONTENTS_OPAQUE
-- @field CONTENTS_TESTFOGVOLUME
-- @field CONTENTS_TEAM4
-- @field CONTENTS_TEAM3
-- @field CONTENTS_TEAM1
-- @field CONTENTS_TEAM2
-- @field CONTENTS_IGNORE_NODRAW_OPAQUE
-- @field CONTENTS_MOVEABLE
-- @field CONTENTS_AREAPORTAL
-- @field CONTENTS_PLAYERCLIP
-- @field CONTENTS_MONSTERCLIP
-- @field CONTENTS_CURRENT_0
-- @field CONTENTS_CURRENT_90
-- @field CONTENTS_CURRENT_180
-- @field CONTENTS_CURRENT_270
-- @field CONTENTS_CURRENT_UP
-- @field CONTENTS_CURRENT_DOWN
-- @field CONTENTS_ORIGIN
-- @field CONTENTS_MONSTER
-- @field CONTENTS_DEBRIS
-- @field CONTENTS_DETAIL
-- @field CONTENTS_TRANSLUCENT
-- @field CONTENTS_LADDER
-- @field CONTENTS_HITBOX
local trace_library = SF.RegisterLibrary("trace")

-- Material Enumeration
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
trace_library.HITGROUP_GENERIC = HITGROUP_GENERIC
trace_library.HITGROUP_HEAD = HITGROUP_HEAD
trace_library.HITGROUP_CHEST = HITGROUP_CHEST
trace_library.HITGROUP_STOMACH = HITGROUP_STOMACH
trace_library.HITGROUP_LEFTARM = HITGROUP_LEFTARM
trace_library.HITGROUP_RIGHTARM = HITGROUP_RIGHTARM
trace_library.HITGROUP_LEFTLEG = HITGROUP_LEFTLEG
trace_library.HITGROUP_RIGHTLEG = HITGROUP_RIGHTLEG
trace_library.HITGROUP_GEAR = HITGROUP_GEAR

-- Mask Enumerations
trace_library.MASK_SPLITAREAPORTAL = MASK_SPLITAREAPORTAL
trace_library.MASK_SOLID_BRUSHONLY = MASK_SOLID_BRUSHONLY
trace_library.MASK_WATER = MASK_WATER
trace_library.MASK_BLOCKLOS = MASK_BLOCKLOS
trace_library.MASK_OPAQUE = MASK_OPAQUE
trace_library.MASK_VISIBLE = MASK_VISIBLE
trace_library.MASK_DEADSOLID = MASK_DEADSOLID
trace_library.MASK_PLAYERSOLID_BRUSHONLY = MASK_PLAYERSOLID_BRUSHONLY
trace_library.MASK_NPCWORLDSTATIC = MASK_NPCWORLDSTATIC
trace_library.MASK_NPCSOLID_BRUSHONLY = MASK_NPCSOLID_BRUSHONLY
trace_library.MASK_CURRENT = MASK_CURRENT
trace_library.MASK_SHOT_PORTAL = MASK_SHOT_PORTAL
trace_library.MASK_SOLID = MASK_SOLID
trace_library.MASK_BLOCKLOS_AND_NPCS = MASK_BLOCKLOS_AND_NPCS
trace_library.MASK_OPAQUE_AND_NPCS = MASK_OPAQUE_AND_NPCS
trace_library.MASK_VISIBLE_AND_NPCS = MASK_VISIBLE_AND_NPCS
trace_library.MASK_PLAYERSOLID = MASK_PLAYERSOLID
trace_library.MASK_NPCSOLID = MASK_NPCSOLID
trace_library.MASK_SHOT_HULL = MASK_SHOT_HULL
trace_library.MASK_SHOT = MASK_SHOT
trace_library.MASK_ALL = MASK_ALL

-- Content Enumerations
trace_library.CONTENTS_EMPTY = CONTENTS_EMPTY
trace_library.CONTENTS_SOLID = CONTENTS_SOLID
trace_library.CONTENTS_WINDOW = CONTENTS_WINDOW
trace_library.CONTENTS_AUX = CONTENTS_AUX
trace_library.CONTENTS_GRATE = CONTENTS_GRATE
trace_library.CONTENTS_SLIME = CONTENTS_SLIME
trace_library.CONTENTS_WATER = CONTENTS_WATER
trace_library.CONTENTS_BLOCKLOS = CONTENTS_BLOCKLOS
trace_library.CONTENTS_OPAQUE = CONTENTS_OPAQUE
trace_library.CONTENTS_TESTFOGVOLUME = CONTENTS_TESTFOGVOLUME
trace_library.CONTENTS_TEAM4 = CONTENTS_TEAM4
trace_library.CONTENTS_TEAM3 = CONTENTS_TEAM3
trace_library.CONTENTS_TEAM1 = CONTENTS_TEAM1
trace_library.CONTENTS_TEAM2 = CONTENTS_TEAM2
trace_library.CONTENTS_IGNORE_NODRAW_OPAQUE = CONTENTS_IGNORE_NODRAW_OPAQUE
trace_library.CONTENTS_MOVEABLE = CONTENTS_MOVEABLE
trace_library.CONTENTS_AREAPORTAL = CONTENTS_AREAPORTAL
trace_library.CONTENTS_PLAYERCLIP = CONTENTS_PLAYERCLIP
trace_library.CONTENTS_MONSTERCLIP = CONTENTS_MONSTERCLIP
trace_library.CONTENTS_CURRENT_0 = CONTENTS_CURRENT_0
trace_library.CONTENTS_CURRENT_90 = CONTENTS_CURRENT_90
trace_library.CONTENTS_CURRENT_180 = CONTENTS_CURRENT_180
trace_library.CONTENTS_CURRENT_270 = CONTENTS_CURRENT_270
trace_library.CONTENTS_CURRENT_UP = CONTENTS_CURRENT_UP
trace_library.CONTENTS_CURRENT_DOWN = CONTENTS_CURRENT_DOWN
trace_library.CONTENTS_ORIGIN = CONTENTS_ORIGIN
trace_library.CONTENTS_MONSTER = CONTENTS_MONSTER
trace_library.CONTENTS_DEBRIS = CONTENTS_DEBRIS
trace_library.CONTENTS_DETAIL = CONTENTS_DETAIL
trace_library.CONTENTS_TRANSLUCENT = CONTENTS_TRANSLUCENT
trace_library.CONTENTS_LADDER = CONTENTS_LADDER
trace_library.CONTENTS_HITBOX = CONTENTS_HITBOX

-- Register privileges
do
	local P = SF.Permissions
	P.registerPrivilege("trace", "Trace", "Allows the user to start traces")
end

-- Local functions

local owrap, ounwrap = SF.WrapObject, SF.UnwrapObject
local wrap, vwrap, awrap
local unwrap, vunwrap, aunwrap
local vecmeta, angmeta

local function postload()
	wrap = SF.Entities.Wrap
	vwrap = SF.Vectors.Wrap
	awrap = SF.Angles.Wrap
	unwrap = SF.Entities.Unwrap
	vunwrap = SF.Vectors.Unwrap
	aunwrap = SF.Angles.Unwrap
	vecmeta = SF.Vectors.Metatable
	angmeta = SF.Angles.Metatable
end
SF.AddHook("postload", postload)

local function convertFilter(filter)
	local filterType = TypeID(filter)
	if filterType == TYPE_NIL then
		return nil
	elseif filterType == TYPE_TABLE then
		local unwrapped = unwrap(filter)
		if unwrapped then
			return unwrapped
		else
			local l = {}
			for i = 1, #filter do
				local unwrapped = unwrap(filter[i])
				if unwrapped then
					l[#l + 1] = unwrapped
				end
			end
			return l
		end
	elseif filterType == TYPE_FUNCTION then
		return function(ent)
			local ret = SF.instance:runFunction(filter, SF.WrapObject(ent))
			if ret[1] then return ret[2] end
		end
	else
		SF.ThrowTypeError("table or function", SF.GetType(filter), 3)
	end
end

local function checkvector(pos)
	if pos.x ~= pos.x or pos.x == math.huge or pos.x == -math.huge then SF.Throw("Inf or nan vector in trace position", 3) end
	if pos.y ~= pos.y or pos.y == math.huge or pos.y == -math.huge then SF.Throw("Inf or nan vector in trace position", 3) end
	if pos.z ~= pos.z or pos.z == math.huge or pos.z == -math.huge then SF.Throw("Inf or nan vector in trace position", 3) end
end

--- Does a line trace
-- @param start Start position
-- @param endpos End position
-- @param filter Entity/array of entities to filter, or a function callback with an entity arguement that returns whether the trace should hit
-- @param mask Trace mask
-- @param colgroup The collision group of the trace
-- @param ignworld Whether the trace should ignore world
-- @return Result of the trace https://wiki.garrysmod.com/page/Structures/TraceResult
function trace_library.trace (start, endpos, filter, mask, colgroup, ignworld)
	checkpermission(SF.instance, nil, "trace")
	checktype(start, vecmeta)
	checktype(endpos, vecmeta)

	local start, endpos = vunwrap(start), vunwrap(endpos)
	checkvector(start)
	checkvector(endpos)

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

	return SF.StructWrapper(util.TraceLine(trace))
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
-- @return Result of the trace https://wiki.garrysmod.com/page/Structures/TraceResult
function trace_library.traceHull (start, endpos, minbox, maxbox, filter, mask, colgroup, ignworld)
	checkpermission(SF.instance, nil, "trace")
	checktype(start, vecmeta)
	checktype(endpos, vecmeta)
	checktype(minbox, vecmeta)
	checktype(maxbox, vecmeta)

	local start, endpos, minbox, maxbox = vunwrap(start), vunwrap(endpos), vunwrap(minbox), vunwrap(maxbox)
	checkvector(start)
	checkvector(endpos)
	checkvector(minbox)
	checkvector(maxbox)

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

	return SF.StructWrapper(util.TraceHull(trace))
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
	checktype(rayStart, vecmeta)
	checktype(rayDelta, vecmeta)
	checktype(boxOrigin, vecmeta)
	checktype(boxAngles, angmeta)
	checktype(boxMins, vecmeta)
	checktype(boxMaxs, vecmeta)
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
	checktype(rayStart, vecmeta)
	checktype(rayDelta, vecmeta)
	checktype(planeOrigin, vecmeta)
	checktype(planeNormal, vecmeta)
	local pos = util.IntersectRayWithPlane(vunwrap(rayStart), vunwrap(rayDelta), vunwrap(planeOrigin), vunwrap(planeNormal))
	if pos then return vwrap(pos) end
end
