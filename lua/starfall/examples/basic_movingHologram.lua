--@name Basic Moving Hologram
--@author Name
--@server

-- Example showcasing basic ways of creating and manipulating a hologram, it's meant for absolute beginners
-- Stuff like variables, function definitions, etc. are explained here: https://github.com/thegrb93/StarfallEx/wiki/Lua-Starfall-Crash-Course

-- Functions from the `builtin` library can be called directly, the following gives us the chip entity
local c = chip()

-- To create a hologram, we make use of the `holograms` library and call it's `create` function
-- The function can take up to 4 parameters: `position`, `angle`, `model` and optionally `scale` (not used here)
-- `position`: The `getPos` method will return entity's world position as a vector object
-- `angle`: The `Angle` constructor will give us an angle object with all axis set to 0, unless specified otherwise
-- `model`: The string describing path to the model, you can use spawn menu item's context menu to obtain it, in this case it's a G-Man
local holo = holograms.create(c:getPos(), Angle(), "models/gman_high.mdl")

-- Since holograms are just entities, the entity methods can also be used on them
-- Note how the Starfall's documentation only specifies `Entity.setColor` variant, but omits the unnecessary `Hologram.setColor`
-- This function expects a color object, we can create one using `Color` which in turn expects R,G,B and optionally alpha values in range 0-255
holo:setColor(Color(128,0,255))

-- We can also set the hologram's velocity using the dedicated `setAngVel` method
-- Note that the rotation of the hologram caused by this is controlled by the game engine and won't cost us any CPU time
holo:setAngVel(Angle(0,100,0))

-- Let's create a function which we will be responsible for updating our hologram
local function update_hologram()
	-- Grab current position of the hologram and add to it a newly constructed vector object with the `X` axis set to 1
	-- Most vector operations like adding, multiplying, etc. will not modify the components, but instead create a new object
	local target_position = holo:getPos() + Vector(1, 0, 0)
	
	-- Set the hologram's position to the previously calculated vector `target_position`
	holo:setPos(target_position)
end

-- Starfall has a couple of ways to refresh or execute code. What we wrote so far will only ever be executed once - when the chip is initialized
-- The hologram will get created, it's color will be set, and we tell the engine that we want it to rotate, but what about executing the `update_hologram` function?
-- The most common way to update parts of your code are events, or so called `hooks`.
-- As one of their arguments they take a function to execute when something happens, that function is commonly referred to as a `callback`
-- There are many types of hooks. Some will run when a player enters a vehicle or presses a key.
-- The `Tick` event will execute every game update (by default rougly 33.3 times per second) and each time that happens, it will call the `callback` we provided
-- Note that multiple `callbacks`, can be attached to the same event by making use of the second parameter (unique name), if the name is the same, it will be overriden
hook.add("Tick", "UpdateHologram", update_hologram)

-- Another common way to update parts of your code are `timers` accessible via the `timer` library.
-- There's two main types of timers, ones that execute a certain amount of times (or forever), and the `simple` timers that only execute once after a certain delay
-- The following is a `simple` timer that will wait `2` seconds and then execute the provided `callback` (this time we pass in an anonymous function as the callback)
timer.simple(2, function()
	-- Detach the `update_hologram` function from the `Tick` event by targeting it with it's unique name, meaning it's `callback` will no longer be executed by this event
	hook.remove("Tick", "UpdateHologram")
	
	-- Stop rotating the hologram by setting it's velocity back to the default 0,0,0
	holo:setAngVel(Angle())
	
	-- One more timer for good measure, because it's a good thing to expose you to the jokingly called `callback hell`
	-- As mentioned above, this is the other type that will execute the `callback` a certain amount of times (in this case `6`, while `0` would be infinite)
	-- Remember that `timers` will always delay first, which means that the `callback` will be executed for the first time after a `1.2` second initial delay
	timer.create("PlayAnimation", 1.2, 6, function(...)
		-- Tell the game engine to set set a non-looping swinging animation to the G-Man's hologram and also play an adequate sound effect
		holo:setAnimation("swing")
		holo:emitSound("npc/zombie/claw_miss1.wav")
	end)
end)
