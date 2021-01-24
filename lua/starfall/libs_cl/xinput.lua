if not SF.Require("xinput") then return function() end end

local checkluatype = SF.CheckLuaType

SF.hookAdd("xinputConnected", "xinputconnected")
SF.hookAdd("xinputDisconnected", "xinputdisconnected")
SF.hookAdd("xinputPressed", "xinputpressed")
SF.hookAdd("xinputReleased", "xinputreleased")
SF.hookAdd("xinputTrigger", "xinputtrigger")
SF.hookAdd("xinputStick", "xinputstick")

--- A simpler, hook-based, and more-powerful controller input library. Inputs are not lost between rendered frames, and there is support for rumble. Note: the client must have the XInput lua binary module installed in order to access this library. See more at https://github.com/mitterdoo/garrysmod-xinput
-- @name xinput
-- @class library
-- @libtbl xinput_library
SF.RegisterLibrary("xinput")


return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local xinputRumble = {}
for i = 0, 3 do
	xinputRumble[i] = {0, 0}
end

instance:AddHook("deinitialize", function()
	for i = 0, 3 do
		local rumble = xinputRumble[i]
		if rumble[1] > 0 or rumble[2] > 0 then
			xinput.setRumble(i, 0, 0)
		end
	end
end)


local xinput_library = instance.Libraries.xinput

--- Gets the state of the controller.
-- @name xinput_library.getState
-- @class function
-- @param id Controller number. Starts at 0
-- @return Table containing all input data of the controller, or false if the controller is not connected. The table uses this struct: https://github.com/mitterdoo/garrysmod-xinput#xinput_gamepad
xinput_library.getState = xinput.getState

--- Gets whether the button on the controller is currently pushed down.
-- @name xinput_library.getButton
-- @class function
-- @param id Controller number. Starts at 0
-- @param button The button to check for. See https://github.com/mitterdoo/garrysmod-xinput#xinput_gamepad_
-- @return bool
xinput_library.getButton = xinput.getButton

--- Gets the current position of the trigger on the controller.
-- @name xinput_library.getTrigger
-- @class function
-- @param id Controller number. Starts at 0
-- @param trigger Which trigger to use. 0 is left
-- @return 0-255 inclusive
xinput_library.getTrigger = xinput.getTrigger

--- Gets the current coordinates of the stick on the controller.
-- @name xinput_library.getStick
-- @class function
-- @param id Controller number. Starts at 0
-- @param stick Which stick to use. 0 is left
-- @return Two numbers for the X and Y coordinates, respectively, each being between -32768 - 32767 inclusive
xinput_library.getStick = xinput.getStick

--- Attempts to check the battery level of the controller.
-- @name xinput_library.getBatteryLevel
-- @class function
-- @param id Controller number. Starts at 0
-- @return If successful: a number between 0.0-1.0 inclusive. If unsuccessful: false, and a string error message
xinput_library.getBatteryLevel = xinput.getBatteryLevel

--- Gets all of the connected controllers.
-- @name xinput_library.getControllers
-- @class function
-- @return A table where each key is the ID of the controller that is connected. Disconnected controllers are not placed in the table.
xinput_library.getControllers = xinput.getControllers

--- Sets the rumble on the controller.
-- @param id Controller number. Starts at 0
-- @param softPercent A number between 0.0-1.0 for how much the soft rumble motor should vibrate.
-- @param hardPercent A number between 0.0-1.0 for how much the hard rumble motor should vibrate.
function xinput_library.setRumble(id, softPercent, hardPercent)
	-- This longer function makes sure that the rumble doesn't continue when the instance is gone.
	checkluatype(id, TYPE_NUMBER)
	id = math.floor(id)
	xinput.setRumble(id, softPercent, hardPercent) -- Does the rest of the type checking
	xinputRumble[id][1] = softPercent
	xinputRumble[id][2] = hardPercent
end

end

--- Called when a controller has been connected. Client must have XInput Lua binary installed.
-- @client
-- @name xinputConnected
-- @class hook
-- @param id Controller number. Starts at 0
-- @param when The timer.realtime() at which this event occurred.

--- Called when a controller has been disconnected. Client must have XInput Lua binary installed.
-- @client
-- @name xinputDisconnected
-- @class hook
-- @param id Controller number. Starts at 0
-- @param when The timer.realtime() at which this event occurred.

--- Called when a controller button has been pressed. Client must have XInput Lua binary installed.
-- @client
-- @name xinputPressed
-- @class hook
-- @param id Controller number. Starts at 0
-- @param button The button that was pushed. See https://github.com/mitterdoo/garrysmod-xinput#xinput_gamepad_
-- @param when The timer.realtime() at which this event occurred.

--- Called when a controller button has been released. Client must have XInput Lua binary installed.
-- @client
-- @name xinputReleased
-- @class hook
-- @param id Controller number. Starts at 0
-- @param button The button that was released. See https://github.com/mitterdoo/garrysmod-xinput#xinput_gamepad_
-- @param when The timer.realtime() at which this event occurred.

--- Called when a trigger on the controller has moved. Client must have XInput Lua binary installed.
-- @client
-- @name xinputTrigger
-- @class hook
-- @param id Controller number. Starts at 0
-- @param value The position of the trigger. 0-255 inclusive
-- @param trigger The trigger that was moved. 0 is left
-- @param when The timer.realtime() at which this event occurred.

--- Called when a stick on the controller has moved. Client must have XInput Lua binary installed.
-- @client
-- @name xinputStick
-- @class hook
-- @param id Controller number. Starts at 0
-- @param x The X coordinate of the trigger. -32768 - 32767 inclusive
-- @param y The Y coordinate of the trigger. -32768 - 32767 inclusive
-- @param stick The stick that was moved. 0 is left
-- @param when The timer.realtime() at which this event occurred.
