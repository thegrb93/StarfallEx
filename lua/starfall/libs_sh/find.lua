-------------------------------------------------------------------------------
-- Find functions
-------------------------------------------------------------------------------

--- Find library. Finds entities in various shapes.
-- @shared
local find_library, _ = SF.Libraries.Register("find")

local find_cooldown
if SERVER then
	find_cooldown = CreateConVar("sf_find_cooldown_sv", "0.01", {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_DONTRECORD})
else
	find_cooldown = CreateConVar("sf_find_cooldown_cl", "0.01", {FCVAR_ARCHIVE, FCVAR_DONTRECORD})
end

local function updateCooldown(instance)
	if not instance.data.findcooldown then instance.data.findcooldown = 0 end
	local time = CurTime()
	
	if instance.data.findcooldown > time then return false end
	instance.data.findcooldown = time + find_cooldown:GetFloat()
	return true
end

local function convert(results, func)
	if func then SF.CheckType(func,"function",1) end
	local wrap = SF.Entities.Wrap
	
	local t = {}
	local count = 1
	for i=1,#results do
		local e = wrap(results[i])
		if not func or func(e) then
			t[count] = e
			count = count + 1
		end
	end
	return t
end

--- Checks if a find function can be performed
function find_library.canFind()
	local data = SF.instance.data
	if not data.findcooldown then data.findcooldown = 0 end
	return data.findcooldown <= CurTime()
end

--- Finds entities in a box
-- @param min Bottom corner
-- @param max Top corner
-- @param filter Optional function to filter results
-- @return An array of found entities
function find_library.inBox(min, max, filter)
	SF.CheckType(min,"Vector")
	SF.CheckType(max,"Vector")
	if filter then SF.CheckType(filter,"function") end
	
	local instance = SF.instance
	if not updateCooldown(instance) then return end
	
	return convert(ents.FindInBox(min, max), filter)
end

--- Finds entities in a sphere
-- @param center Center of the sphere
-- @param radius Sphere radius
-- @param filter Optional function to filter results
-- @return An array of found entities
function find_library.inSphere(center, radius, filter)
	SF.CheckType(center,"Vector")
	SF.CheckType(radius,"number")
	
	local instance = SF.instance
	if not updateCooldown(instance) then return end
	
	return convert(ents.FindInSphere(center, radius), filter)
end

--- Finds entities in a cone
-- @param pos The cone vertex position
-- @param dir The direction to project the cone
-- @param distance The length to project the cone
-- @param radius The angle of the cone
-- @param filter Optional function to filter results
-- @return An array of found entities
function find_library.inCone(pos, dir, distance, radius, filter)
	SF.CheckType(pos,"Vector")
	SF.CheckType(dir,"Vector")
	SF.CheckType(distance,"number")
	SF.CheckType(radius,"number")
	
	local instance = SF.instance
	if not updateCooldown(instance) then return end
	
	return convert(ents.FindInCone(pos,dir,distance,radius), filter)
end

--- Finds entities by class name
-- @param class The class name
-- @param filter Optional function to filter results
-- @return An array of found entities
function find_library.byClass(class, filter)
	SF.CheckType(class,"string")
	
	local instance = SF.instance
	if not updateCooldown(instance) then return end
	
	return convert(ents.FindByClass(class), filter)
end

--- Finds entities by model
-- @param model The model file
-- @param filter Optional function to filter results
-- @return An array of found entities
function find_library.byModel(model, filter)
	SF.CheckType(model,"string")
	
	local instance = SF.instance
	if not updateCooldown(instance) then return end
	
	return convert(ents.FindByModel(model), filter)
end

--- Finds all players (including bots)
-- @param filter Optional function to filter results
-- @return An array of found entities
function find_library.allPlayers(filter)
	local instance = SF.instance
	if not updateCooldown(instance) then return end
	
	return convert(player.GetAll(), filter)
end

--- Finds all entitites
-- @param filter Optional function to filter results
-- @return An array of found entities
function find_library.all(filter)
	local instance = SF.instance
	if not updateCooldown(instance) then return end
	
	return convert(ents.GetAll(), filter)
end
