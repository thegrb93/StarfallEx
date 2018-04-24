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
-- @param radius The angle of the cone
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
