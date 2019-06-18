if file.Exists("lua/bin/gmcl_xinput_win32.dll", "GAME") or file.Exists("lua/bin/gmcl_xinput_win64.dll", "GAME") then
	require("xinput")
else
	return
end

--- A simpler, hook-based, and more-powerful controller input library. Inputs are not lost between rendered frames, and there is support for rumble. Note: the client must have the XInput lua binary module installed in order to access this library. See more at https://github.com/mitterdoo/garrysmod-xinput
-- @client
local xinput_library = SF.RegisterLibrary("xinput")

--- Gets the state of the controller.
-- @param id Controller number. Starts at 0
-- @return Table containing all input data of the controller, or false if the controller is not connected. The table uses this struct: https://github.com/mitterdoo/garrysmod-xinput#xinput_gamepad
function xinput_library.getState(id)
	return xinput.getState(id)
end

--- Gets whether the button on the controller is currently pushed down.
-- @param id Controller number. Starts at 0
-- @param button The button to check for. See https://github.com/mitterdoo/garrysmod-xinput#xinput_gamepad_
-- @return bool
function xinput_library.getButton(id, button)
	return xinput.getButton(id, button)
end

--- Gets the current position of the trigger on the controller.
-- @param id Controller number. Starts at 0
-- @param trigger Which trigger to use. 0 is left
-- @return 0-255 inclusive
function xinput_library.getTrigger(id, trigger)
	return xinput.getTrigger(id, trigger)
end

--- Gets the current coordinates of the stick on the controller.
-- @param id Controller number. Starts at 0
-- @param stick Which stick to use. 0 is left
-- @return Two numbers for the X and Y coordinates, respectively, each being between -32768 - 32767 inclusive
function xinput_library.getStick(id, stick)
	return xinput.getStick(id, stick)
end

--- Attempts to check the battery level of the controller.
-- @param id Controller number. Starts at 0
-- @return If successful: a number between 0.0-1.0 inclusive. If unsuccessful: false, and a string error message
function xinput_library.getBatteryLevel(id)
	return xinput.getBatteryLevel(id)
end

--- Gets all of the connected controllers.
-- @return A table where each key is the ID of the controller that is connected. Disconnected controllers are not placed in the table.
function xinput_library.getControllers()
	return xinput.getControllers()
end

--- Sets the rumble on the controller.
-- @param id Controller number. Starts at 0
-- @param softPercent A number between 0.0-1.0 for how much the soft rumble motor should vibrate.
-- @param hardPercent A number between 0.0-1.0 for how much the hard rumble motor should vibrate.
function xinput_library.setRumble(id, softPercent, hardPercent)
	-- This longer function makes sure that the rumble doesn't continue when the instance is gone.
	SF.CheckLuaType(id, TYPE_NUMBER)
	if id % 1 ~= 0 then
		SF.Throw("Controller ID must be an integer")
	end
	xinput.setRumble(id, softPercent, hardPercent) -- Does the rest of the type checking
	SF.instance.data.xinputRumble[id][1] = softPercent
	SF.instance.data.xinputRumble[id][2] = hardPercent
end

SF.AddHook("initialize", function(inst)
	inst.data.xinputRumble = {}
	for i = 0, 3 do
		inst.data.xinputRumble[i] = {0, 0}
	end
end)

SF.AddHook("deinitialize", function(inst)
	for i = 0, 3 do
		local rumble = inst.data.xinputRumble[i]
		if rumble[1] > 0 or rumble[2] > 0 then
			xinput.setRumble(i, 0, 0)
		end
	end
end)

SF.hookAdd("xinputConnected", "xinputconnected")
SF.hookAdd("xinputDisconnected", "xinputdisconnected")
SF.hookAdd("xinputPressed", "xinputpressed")
SF.hookAdd("xinputReleased", "xinputreleased")
SF.hookAdd("xinputTrigger", "xinputtrigger")
SF.hookAdd("xinputStick", "xinputstick")

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
-- @param id The button that was released. See https://github.com/mitterdoo/garrysmod-xinput#xinput_gamepad_
-- @param when The timer.realtime() at which this event occurred.

--- Called when a trigger on the controller has moved. Client must have XInput Lua binary installed.
-- @client
-- @name xinputTrigger
-- @class hook
-- @param id Controller number. Starts at 0
-- @param trigger The trigger that was moved. 0 is left
-- @param value The position of the trigger. 0-255 inclusive
-- @param when The timer.realtime() at which this event occurred.

--- Called when a stick on the controller has moved. Client must have XInput Lua binary installed.
-- @client
-- @name xinputStick
-- @class hook
-- @param id Controller number. Starts at 0
-- @param stick The stick that was moved. 0 is left
-- @param x The X coordinate of the trigger. -32768 - 32767 inclusive
-- @param y The Y coordinate of the trigger. -32768 - 32767 inclusive
-- @param when The timer.realtime() at which this event occurred.
