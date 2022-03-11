--@name Basic Closest Chair Finder
--@author Name
--@server

-- USAGE:
-- Place the chip, if a suitable chair based on the below criteria is found, it will turn red

local origin = chip():getPos() -- Chip's world position will act as the origin
local distance = 200 -- Maximum distance from the origin point
local models = { -- List of allowed chair models
	["models/nova/jeep_seat.mdl"] = true,
	["models/nova/airboat_seat.mdl"] = true,
}

-- Making use of the `find` library, search for all chairs (entities with `prop_vehicle_prisoner_pod` class)
-- Using the `filter` callback we can only allow certain results in our list
local found_entities = find.byClass("prop_vehicle_prisoner_pod", function(ent)
	-- Return nothing (dismiss) if the entity isn't owned by us it's model isn't allowed
	if ent:getOwner() ~= owner() then return end
	if not models[ent:getModel()] then return end
	-- Return `true` to accept any entities that passed the tests above
	return true
end)

-- From the list, grab one that's closest to the origin (if any)
local chair = find.closest(found_entities, origin)

-- Check whether the entity has been found and if it's distance is within limits
if chair and chair:getPos():getDistance(origin) < distance then
	-- Set chair's color to red and print out a confirmation
	chair:setColor(Color(255, 0, 0))
	print("Suitable chair found.")
else
	print("No suitable chair found!")
end
