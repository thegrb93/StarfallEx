
local joystick_library, _ = SF.Libraries.Register("joystick")


if file.Exists("lua/bin/gmcl_joystick_win32.dll", "GAME") then
	require("joystick")
end

local next_updates = {}

local function refresh( enum )
	local next_update = next_updates[ enum ] or 0
	if CurTime()>next_update then
		next_updates[ enum ] = CurTime() + 0.0303
		joystick.refresh( enum )
	end
end

--- Gets the axis data value.
-- @param enum Joystick number. Starts at 0
-- @param axis Joystick axis number. Ranges from 0 to 7.
-- @return 0 - 32767 where 16383 is the middle.
function joystick_library.getAxis( enum, axis )
	if joystick then
		refresh( enum )
		return joystick.axis( enum, axis )
	end
end

--- Gets the pov data value.
-- @param enum Joystick number. Starts at 0
-- @param pov Joystick pov number. Ranges from 0 to 7.
-- @return 0 - 32767 where 16383 is the middle.
function joystick_library.getPov( enum, pov )
	if joystick then
		refresh( enum )
		return joystick.pov( enum, pov )
	end
end

--- Returns if the button is pushed or not
-- @param enum Joystick number. Starts at 0
-- @param button Joystick button number. Starts at 0
-- @return 0 or 1
function joystick_library.getButton( enum, button )
	if joystick then
		refresh( enum )
		return joystick.button( enum, button )
	end
end

--- Gets the hardware name of the joystick
-- @param enum Joystick number. Starts at 0
-- @return Name of the device
function joystick_library.getName( enum )
	if joystick then
		refresh( enum )
		return joystick.name( enum )
	end
end

--- Gets the number of detected joysticks.
-- @return Number of joysticks
function joystick_library.numJoysticks( )
	if joystick then
		return joystick.count( )
	end
end

--- Gets the number of detected axes on a joystick
-- @param enum Joystick number. Starts at 0
-- @return Number of axes
function joystick_library.numAxes( enum )
	if joystick then
		refresh( enum )
		return joystick.count( enum, 1 )
	end
end

--- Gets the number of detected povs on a joystick
-- @param enum Joystick number. Starts at 0
-- @return Number of povs
function joystick_library.numPovs( enum )
	if joystick then
		refresh( enum )
		return joystick.count( enum, 2 )
	end
end

--- Gets the number of detected buttons on a joystick
-- @param enum Joystick number. Starts at 0
-- @return Number of buttons
function joystick_library.numButtons( enum )
	if joystick then
		refresh( enum )
		return joystick.count( enum, 3 )
	end
end

