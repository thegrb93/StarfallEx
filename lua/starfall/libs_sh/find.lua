-- Global to all starfalls
local checkluatype = SF.CheckLuaType

-- Register privileges
SF.Permissions.registerPrivilege("find", "Find", "Allows the user to access the find library")

--- Find library. Finds entities in various shapes.
-- @name find
-- @class library
-- @libtbl find_library
SF.RegisterLibrary("find")

return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local find_library = instance.Libraries.find
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local plywrap = instance.Types.Player.Wrap

local function convert(results, func)
	if func~=nil then checkluatype (func, TYPE_FUNCTION) end
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
-- @param Vector min Bottom corner
-- @param Vector max Top corner
-- @param function? filter Optional function to filter results
-- @return table An array of found entities
function find_library.inBox(min, max, filter)
	checkpermission(instance, nil, "find")

	local min, max = vunwrap(min), vunwrap(max)

	return convert(ents.FindInBox(min, max), filter)
end

--- Finds entities in a sphere
-- @param Vector center Center of the sphere
-- @param number radius Sphere radius
-- @param function? filter Optional function to filter results
-- @return table An array of found entities
function find_library.inSphere(center, radius, filter)
	checkpermission(instance, nil, "find")
	checkluatype (radius, TYPE_NUMBER)

	local center = vunwrap(center)

	return convert(ents.FindInSphere(center, radius), filter)
end

--- Finds entities in a cone
-- @param Vector pos The cone vertex position
-- @param Vector dir The direction to project the cone
-- @param number distance The length to project the cone
-- @param number radius The cosine of angle of the cone. 1 makes a 0° cone, 0.707 makes approximately 90°, 0 makes 180°, and so on.
-- @param function? filter Optional function to filter results
-- @return table An array of found entities
function find_library.inCone(pos, dir, distance, radius, filter)
	checkpermission(instance, nil, "find")
	checkluatype (distance, TYPE_NUMBER)
	checkluatype (radius, TYPE_NUMBER)

	local pos, dir = vunwrap(pos), vunwrap(dir)

	return convert(ents.FindInCone(pos, dir, distance, radius), filter)
end

--- Finds entities in a ray
-- @param Vector startpos The ray start
-- @param Vector endpos The ray end
-- @param Vector? mins If not nil, will define a lower bound of the ray's hull
-- @param Vector? maxs If not nil, will define a upper bound of the ray's hull
-- @param function? filter Optional function to filter results
-- @return table An array of found entities
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
-- @param string class The class name
-- @param function? filter Optional function to filter results
-- @return table An array of found entities
function find_library.byClass(class, filter)
	checkpermission(instance, nil, "find")
	checkluatype (class, TYPE_STRING)

	return convert(ents.FindByClass(class), filter)
end

--- Finds entities by their targetname
-- @param string name The targetname
-- @param function? filter Optional function to filter results
-- @return table An array of found entities
function find_library.byName(name, filter)
	checkpermission(instance, nil, "find")
	checkluatype (name, TYPE_STRING)

	return convert(ents.FindByName(name), filter)
end

--- Finds entities by model
-- @param string model The model file
-- @param function? filter Optional function to filter results
-- @return table An array of found entities
function find_library.byModel(model, filter)
	checkpermission(instance, nil, "find")
	checkluatype (model, TYPE_STRING)

	return convert(ents.FindByModel(model), filter)
end

if SERVER then
	--- Finds entities that are in the PVS (Potentially Visible Set). See: https://developer.valvesoftware.com/wiki/PVS
	-- @server
	-- @param Vector pos Vector view point
	-- @param function? filter Optional function to filter results
	-- @return table An array of found entities
	function find_library.inPVS(pos, filter)
		checkpermission(instance, nil, "find")

		return convert(ents.FindInPVS(vunwrap(pos)), filter)
	end
end

--- Finds all players (including bots)
-- @param function? filter Optional function to filter results
-- @return table An array of found entities
function find_library.allPlayers(filter)
	checkpermission(instance, nil, "find")

	return convert(player.GetAll(), filter)
end

--- Finds all entities
-- @param function? filter Optional function to filter results
-- @return table An array of found entities
function find_library.all(filter)
	checkpermission(instance, nil, "find")

	return convert(ents.GetAll(), filter)
end

--- Finds the closest entity to a point
-- @param table ents The array of entities
-- @param Vector pos The position
-- @return Entity The closest entity
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
-- @param table ents The array of entities
-- @param Vector pos The position
-- @param boolean furthest Whether to have the further entities first
-- @return table A table of the closest entities
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
-- @param string name Name to search for
-- @param boolean? casesensitive Boolean should the match be case sensitive?
-- @param boolean? exact Boolean should the name match exactly
-- @return table Table of found players
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

--- Finds the player with the given a steamid. Returns nil if not found
-- @param string steamid Steam Id to search for
-- @return Player? The player with matching steamid
function find_library.playerBySteamID(steamid)
	local found = player.GetBySteamID(steamid)
	if found then return plywrap(found) end
end

--- Finds the player with the given a 64-bit steamid. Returns nil if not found
-- @param string steamid 64-bit steam id to search for
-- @return Player? The player with matching steamid
function find_library.playerBySteamID64(steamid)
	local found = player.GetBySteamID64(steamid)
	if found then return plywrap(found) end
end

end
