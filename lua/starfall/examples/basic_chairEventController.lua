--@name Basic event chair controller
--@author Name
--@server

-- USAGE:
-- Place chip on the ground, a chair will spawn, sit in it and press W or S to move the hologram

-- Create a frozen SENT `Seat_Jeep` 20 units above the chip
local chair = prop.createSent(chip():getPos() + chip():getUp() * 20, Angle(), "Seat_Jeep", true)
-- Create a hologram in front of the chair with a scale of 0.75 on all axis
local holo = holograms.create(chair:getPos() + chair:getForward() * 40, Angle(), "models/props_phx/games/chess/white_rook.mdl", Vector(0.75))

-- Player that's currently sitting in the chair
local driver
-- Due to the fact that `PlayerEnteredVehicle` has a `role` parameter, but `PlayerLeaveVehicle` doesn't we can easily distinguish between the 2 hooks.
-- If a `role` argument is present, set the `driver` variable to the provided player, otherwise set it to `role` (which will be `nil`)
local function set_driver(ply, vehicle, role)
	if vehicle ~= chair then return end -- If the vehicle in question isn't our chair, exit without doing anything
	driver = role and ply -- If role is "Truthy" (any number value is, even `0`) then store `ply` in our `driver` variable
end
-- Attach the `set_driver` function to the appropriate hooks
hook.add("PlayerEnteredVehicle", "SetDriver", set_driver)
hook.add("PlayerLeaveVehicle", "SetDriver", set_driver)


-- Variables responsible for the movement of the hologram
local velocity = 0
local acceleration = 0

-- Map of inputs and their acceleration values / forces
local inputs = {
	[IN_KEY.FORWARD] = 10,
	[IN_KEY.BACK] = -8,
}

-- Attach a callback to the `KeyPress` hook so we can detect when players press their binds
hook.add("KeyPress", "KeyPress", function(ply, key)
	if ply ~= driver then return end -- If the player isn't our driver then we don't care 
	if inputs[key] then -- If the key is present in our input map...
		acceleration = inputs[key] -- then set acceleration to that value
	end
end)

-- Attach a callback to the `KeyRelease` hook so we can detect when players release their binds
hook.add("KeyRelease", "KeyRelease", function(ply, key)
	if ply ~= driver then return end -- If the player isn't our driver then we don't care 
	if inputs[key] then -- Check if the key is one of allowed ones from the input map
		
		-- Without this snippet, when player decides to press W and S at once, then release only one of them, the hologram will stop
		-- This will simply check whether any other keys from our input map are pressed, if so, set the `acceleration` to the first found one:
		for input_key, force in pairs(inputs) do
			if ply:keyDown(input_key) then
				acceleration = force
				return -- Return from the whole function so that `acceleration = 0` doesn't get executed
			end
		end
		
		-- If the code above didn't detect any pressed keys, set the acceleration to 0
		acceleration = 0
	end
end)

-- Attach a callback responsible for the movement of the hologram to the `Tick` event
hook.add("Tick", "Update", function()
	-- Add acceleration from user input to the velocity
	velocity = velocity + acceleration
	-- Create a new vector with Y axis based on the `velocity` and apply that to the hologram
	holo:setVel(Vector(0, velocity, 0))
	-- Decrease the velocity, otherwise hologram will never stop
	velocity = velocity * 0.9
end)
