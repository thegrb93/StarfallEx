--@name Basic Wire Entity Connection
--@author Name
--@server

-- USAGE:
-- Place the chip, using the `Wire` tool, click on the chip, then on an entity

-- An initialization function that will be executed when the entity changes (and is valid)
local function init(ent)
	print("Connected to: ", ent)
end

-- Setup inputs for the Wire interface, in this case only one called `Ent` of the type `entity`
wire.adjustPorts { ["Ent"] = "entity" }
-- The `Input` hook is called on input changes and when the Wire interface is set up (eg. `wire.adjustPorts`)
hook.add("Input", "HandleEntityInput", function(name, value)
	-- In this example `name` will always be `Ent`, since there's only one input so I don't bother checking it
	if value:isValid() then
		-- When I'm sure everything is OK with the provided entity, I can call my initialization function
		init(value)
	end
end)
