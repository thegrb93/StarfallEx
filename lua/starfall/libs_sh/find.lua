-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check

-- Register privileges
SF.Permissions.registerPrivilege("find", "Find", "Allows the user to access the find library")

--- Find library. Finds entities in various shapes.
-- @name find
-- @class library
-- @libtbl find_library
SF.RegisterLibrary("find")

return function(instance)

local find_library = instance.Libraries.find
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local plywrap = instance.Types.Player.Wrap

local function convert(results, func)
	if func then checkluatype (func, TYPE_FUNCTION) end
	local wrap = instance.WrapObject

	local t = {}
	if func then
		for i = 1, #results do
			local e = wrap(results[i])
			if e and func(e) then
				t[#t + 1] = e
			end
		end
	else
		for i = 1, #results do
			local e = wrap(results[i])
			if e then
				t[#t + 1] = e
			end
		end
	end
	return t
end

--- Finds entities in a box
-- @param min Bottom corner
-- @param max Top corner
-- @param filter Optional function to filter results
-- @return An array of found entities
function find_library.inBox(min, max, filter)
	checkpermission(instance, nil, "find")

	local min, max = vunwrap(min), vunwrap(max)

	return convert(ents.FindInBox(min, max), filter)
end

--- Finds entities in a sphere
-- @param center Center of the sphere
-- @param radius Sphere radius
-- @param filter Optional function to filter results
-- @return An array of found entities
function find_library.inSphere(center, radius, filter)
	checkpermission(instance, nil, "find")
	checkluatype (radius, TYPE_NUMBER)

	local center = vunwrap(center)

	return convert(ents.FindInSphere(center, radius), filter)
end

--- Finds entities in a cone
-- @param pos The cone vertex position
-- @param dir The direction to project the cone
-- @param distance The length to project the cone
-- @param radius The cosine of angle of the cone. 1 makes a 0° cone, 0.707 makes approximately 90°, 0 makes 180°, and so on.
-- @param filter Optional function to filter results
-- @return An array of found entities
function find_library.inCone(pos, dir, distance, radius, filter)
	checkpermission(instance, nil, "find")
	checkluatype (distance, TYPE_NUMBER)
	checkluatype (radius, TYPE_NUMBER)

	local pos, dir = vunwrap(pos), vunwrap(dir)

	return convert(ents.FindInCone(pos, dir, distance, radius), filter)
end

--- Finds entities in a ray
-- @param startpos The ray start
-- @param endpos The ray end
-- @param mins If not null, will define a lower bound of the ray's hull
-- @param maxs If not null, will define a upper bound of the ray's hull
-- @param filter Optional function to filter results
-- @return An array of found entities
function find_library.inRay(startpos, endpos, mins, maxs, filter)
	checkpermission(instance, nil, "find")

	startpos = vunwrap(startpos)
	endpos = vunwrap(endpos)

	if mins ~= nil or maxs ~= nil then
		mins = vunwrap(mins)
		maxs = vunwrap(maxs)
	end

	return convert(ents.FindAlongRay(startpos, endpos, mins, maxs), filter)
end

--- Finds entities by class name
-- @param class The class name
-- @param filter Optional function to filter results
-- @return An array of found entities
function find_library.byClass(class, filter)
	checkpermission(instance, nil, "find")
	checkluatype (class, TYPE_STRING)

	return convert(ents.FindByClass(class), filter)
end

--- Finds entities by their targetname
-- @param name The targetname
-- @param filter Optional function to filter results
-- @return An array of found entities
function find_library.byName(name, filter)
	checkpermission(instance, nil, "find")
	checkluatype (name, TYPE_STRING)

	return convert(ents.FindByName(name), filter)
end

--- Finds entities by model
-- @param model The model file
-- @param filter Optional function to filter results
-- @return An array of found entities
function find_library.byModel(model, filter)
	checkpermission(instance, nil, "find")
	checkluatype (model, TYPE_STRING)

	return convert(ents.FindByModel(model), filter)
end

if SERVER then
	--- Finds entities that are in the PVS (Potentially Visible Set). See: https://developer.valvesoftware.com/wiki/PVS
	-- @server
	-- @param pos Vector view point
	-- @param filter Optional function to filter results
	-- @return An array of found entities
	function find_library.inPVS(pos, filter)
		checkpermission(instance, nil, "find")
		
		return convert(ents.FindInPVS(vunwrap(pos)), filter)
	end
end

--- Finds all players (including bots)
-- @param filter Optional function to filter results
-- @return An array of found entities
function find_library.allPlayers(filter)
	checkpermission(instance, nil, "find")

	return convert(player.GetAll(), filter)
end

--- Finds all entitites
-- @param filter Optional function to filter results
-- @return An array of found entities
function find_library.all(filter)
	checkpermission(instance, nil, "find")

	return convert(ents.GetAll(), filter)
end

--- Finds the closest entity to a point
-- @param ents The array of entities
-- @param pos The position
-- @return The closest entity
function find_library.closest(ents, pos)
	local closest = math.huge
	local closestent

	for k, v in pairs(ents) do
		local d = v:getPos():getDistanceSqr(pos)
		if d<closest then
			closest = d
			closestent = v
		end
	end

	return closestent
end

--- Returns a sorted array of entities by how close they are to a point
-- @param ents The array of entities
-- @param pos The position
-- @param furthest Whether to have the further entities first
-- @return A table of the closest entities
function find_library.sortByClosest(ents, pos, furthest)
	local distances = {}
	for i=1, #ents do
		distances[i] = {ents[i]:getPos():getDistanceSqr(pos), ents[i]}
	end
	local sortfunc
	if furthest then
		sortfunc = function(a,b) return a[1]>b[1] end
	else
		sortfunc = function(a,b) return a[1]<b[1] end
	end
	table.sort(distances, sortfunc)
	local ret = {}
	for i=1, #distances do
		ret[i] = distances[i][2]
	end
	return ret
end

--- Finds the first player with the given name
-- @param name Name to search for
-- @param casesensitive Boolean should the match be case sensitive?
-- @param exact Boolean should the name match exactly
-- @return Table of found players
function find_library.playersByName(name, casesensitive, exact)
	checkpermission(instance, nil, "find")
	checkluatype(name, TYPE_STRING)
	if casesensitive~=nil then checkluatype(casesensitive, TYPE_BOOL) end
	if exact~=nil then checkluatype(exact, TYPE_BOOL) end

	local ret = {}
	local getName
	if casesensitive then
		getName = function(ply) return ply:GetName() end
	else
		name = string.lower(name)
		getName = function(ply) return string.lower(ply:GetName()) end
	end

	if exact then
		for k, ply in ipairs(player.GetAll()) do
			if getName(ply) == name then
				ret[#ret+1] = plywrap(ply)
			end
		end
	else
		for k, ply in ipairs(player.GetAll()) do
			if string.find(getName(ply), name, 1, true) then
				ret[#ret+1] = plywrap(ply)
			end
		end
	end

	return ret
end

end
