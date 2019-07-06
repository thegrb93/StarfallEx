-------------------------------------------------------------------------------
-- Find functions
-------------------------------------------------------------------------------

--- Find library. Finds entities in various shapes.
-- @shared
local find_library = SF.RegisterLibrary("find")

local vunwrap = SF.UnwrapObject
local checktype = SF.CheckType
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check

-- Register privileges
do
	local P = SF.Permissions
	P.registerPrivilege("find", "Find", "Allows the user to access the find library")
end

local function convert(results, func)
	if func then checkluatype (func, TYPE_FUNCTION) end
	local wrap = SF.WrapObject

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
function find_library.inBox (min, max, filter)
	checkpermission(SF.instance, nil, "find")
	checktype(min, SF.Types["Vector"])
	checktype(max, SF.Types["Vector"])

	local min, max = vunwrap(min), vunwrap(max)

	return convert(ents.FindInBox(min, max), filter)
end

--- Finds entities in a sphere
-- @param center Center of the sphere
-- @param radius Sphere radius
-- @param filter Optional function to filter results
-- @return An array of found entities
function find_library.inSphere (center, radius, filter)
	checkpermission(SF.instance, nil, "find")
	checktype(center, SF.Types["Vector"])
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
function find_library.inCone (pos, dir, distance, radius, filter)
	checkpermission(SF.instance, nil, "find")
	checktype(pos, SF.Types["Vector"])
	checktype(dir, SF.Types["Vector"])
	checkluatype (distance, TYPE_NUMBER)
	checkluatype (radius, TYPE_NUMBER)

	local pos, dir = vunwrap(pos), vunwrap(dir)

	return convert(ents.FindInCone(pos, dir, distance, radius), filter)
end

--- Finds entities by class name
-- @param class The class name
-- @param filter Optional function to filter results
-- @return An array of found entities
function find_library.byClass(class, filter)
	checkpermission(SF.instance, nil, "find")
	checkluatype (class, TYPE_STRING)

	return convert(ents.FindByClass(class), filter)
end

--- Finds entities by model
-- @param model The model file
-- @param filter Optional function to filter results
-- @return An array of found entities
function find_library.byModel(model, filter)
	checkpermission(SF.instance, nil, "find")
	checkluatype (model, TYPE_STRING)

	return convert(ents.FindByModel(model), filter)
end

--- Finds all players (including bots)
-- @param filter Optional function to filter results
-- @return An array of found entities
function find_library.allPlayers(filter)
	checkpermission(SF.instance, nil, "find")

	return convert(player.GetAll(), filter)
end

--- Finds all entitites
-- @param filter Optional function to filter results
-- @return An array of found entities
function find_library.all(filter)
	checkpermission(SF.instance, nil, "find")

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

--- Sorts an array of entities by how close they are to a point
-- @param ents The array of entities
-- @param pos The position
-- @return A table of the closest entities
function find_library.sortByClosest(ents, pos)
	local distances = {}
	for k, v in pairs(ents) do
		distances[#distances+1] = {v:getPos():getDistanceSqr(pos), v}
	end
	table.sort(distances, function(a,b) return a[1]<b[1] end)
	local ret = {}
	for i=1, #distances do
		ret[i] = distances[i][2]
	end
	return ret
end

if SERVER then
	--- Finds entities that are in the PVS (Potentially Visible Set). See: https://developer.valvesoftware.com/wiki/PVS
	-- @server
	-- @param pos Vector view point
	-- @param filter Optional function to filter results
	-- @return An array of found entities
	function find_library.inPVS (pos, filter)
		checkpermission(SF.instance, nil, "find")
		checktype(pos, SF.Types["Vector"])
		
		local pos = vunwrap(pos)
		
		return convert(ents.FindInPVS(pos), filter)
	end
end
