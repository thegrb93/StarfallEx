if not SF.Require("xinput") then return function() end end

local checkluatype = SF.CheckLuaType

--- Called when a controller has been connected. Client must have XInput Lua binary installed.
-- @client
-- @name XInputConnected
-- @class hook
-- @param number id Controller number. Starts at 0
-- @param number when The timer.realtime() at which this event occurred.
SF.hookAdd("xinputConnected", "xinputconnected")

--- Called when a controller has been disconnected. Client must have XInput Lua binary installed.
-- @client
-- @name XInputDisconnected
-- @class hook
-- @param number id Controller number. Starts at 0
-- @param number when The timer.realtime() at which this event occurred.
SF.hookAdd("xinputDisconnected", "xinputdisconnected")

--- Called when a controller button has been pressed. Client must have XInput Lua binary installed.
-- @client
-- @name XInputPressed
-- @class hook
-- @param number id Controller number. Starts at 0
-- @param number button The button that was pushed. See https://github.com/mitterdoo/garrysmod-xinput#xinput_gamepad_
-- @param number when The timer.realtime() at which this event occurred.
SF.hookAdd("xinputPressed", "xinputpressed")

--- Called when a controller button has been released. Client must have XInput Lua binary installed.
-- @client
-- @name XInputReleased
-- @class hook
-- @param number id Controller number. Starts at 0
-- @param number button The button that was released. See https://github.com/mitterdoo/garrysmod-xinput#xinput_gamepad_
-- @param number when The timer.realtime() at which this event occurred.
SF.hookAdd("xinputReleased", "xinputreleased")

--- Called when a trigger on the controller has moved. Client must have XInput Lua binary installed.
-- @client
-- @name XInputTrigger
-- @class hook
-- @param number id Controller number. Starts at 0
-- @param number value The position of the trigger. 0-255 inclusive
-- @param number trigger The trigger that was moved. 0 is left
-- @param number when The timer.realtime() at which this event occurred.
SF.hookAdd("xinputTrigger", "xinputtrigger")

--- Called when a stick on the controller has moved. Client must have XInput Lua binary installed.
-- @client
-- @name XInputStick
-- @class hook
-- @param number id Controller number. Starts at 0
-- @param number x The X coordinate of the trigger. -32768 - 32767 inclusive
-- @param number y The Y coordinate of the trigger. -32768 - 32767 inclusive
-- @param number stick The stick that was moved. 0 is left
-- @param number when The timer.realtime() at which this event occurred.
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
-- @param number id Controller number. Starts at 0
-- @return table Table containing all input data of the controller, or false if the controller is not connected. The table uses this struct: https://github.com/mitterdoo/garrysmod-xinput#xinput_gamepad
xinput_library.getState = xinput.getState

--- Gets whether the button on the controller is currently pushed down.
-- @name xinput_library.getButton
-- @class function
-- @param number id Controller number. Starts at 0
-- @param number button The button to check for. See https://github.com/mitterdoo/garrysmod-xinput#xinput_gamepad_
-- @return boolean
xinput_library.getButton = xinput.getButton

--- Gets the current position of the trigger on the controller.
-- @name xinput_library.getTrigger
-- @class function
-- @param number id Controller number. Starts at 0
-- @param number trigger Which trigger to use. 0 is left
-- @return number 0-255 inclusive
xinput_library.getTrigger = xinput.getTrigger

--- Gets the current coordinates of the stick on the controller.
-- @name xinput_library.getStick
-- @class function
-- @param number id Controller number. Starts at 0
-- @param number stick Which stick to use. 0 is left
-- @return number X Coordinate, Between -32768 - 32767 inclusive
-- @return number Y Coordinate, Between -32768 - 32767 inclusive
xinput_library.getStick = xinput.getStick

--- Attempts to check the battery level of the controller.
-- @name xinput_library.getBatteryLevel
-- @class function
-- @param number id Controller number. Starts at 0
-- @return number|boolean If successful: a number between 0.0-1.0 inclusive.
-- @return string? If last return was a false boolean (errored), this will be the error message.
xinput_library.getBatteryLevel = xinput.getBatteryLevel

--- Gets all of the connected controllers.
-- @name xinput_library.getControllers
-- @class function
-- @return table A table where each key is the ID of the controller that is connected. Disconnected controllers are not placed in the table.
xinput_library.getControllers = xinput.getControllers

--- Sets the rumble on the controller.
-- @param number id Controller number. Starts at 0
-- @param number softPercent A number between 0.0-1.0 for how much the soft rumble motor should vibrate.
-- @param number hardPercent A number between 0.0-1.0 for how much the hard rumble motor should vibrate.
function xinput_library.setRumble(id, softPercent, hardPercent)
	-- This longer function makes sure that the rumble doesn't continue when the instance is gone.
	checkluatype(id, TYPE_NUMBER)
	id = math.floor(id)
	xinput.setRumble(id, softPercent, hardPercent) -- Does the rest of the type checking
	xinputRumble[id][1] = softPercent
	xinputRumble[id][2] = hardPercent
end

end
