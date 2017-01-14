
if file.Exists("bin/gmcl_joystick_win32.dll", "LUA") then
	if util.CRC(file.Read("bin/gmcl_joystick_win32.dll", "LUA"))=="2665158387" then
		require("joystick")
	else
		ErrorNoHalt("CRC check for gmcl_joystick_win32.dll failed.")
		return
	end
else
	return
end

--- Joystick library.
-- @client
local joystick_library, _ = SF.Libraries.Register("joystick")
local next_updates = {}

local function refresh( enum )
	enum = math.Clamp( enum, 0, 12 )
	local next_update = next_updates[ enum ] or 0
	if CurTime()>next_update then
		next_updates[ enum ] = CurTime() + 0.0303
		joystick.refresh( enum )
	end
end

--- Gets the axis data value.
-- @param enum Joystick number. Starts at 0
-- @param axis Joystick axis number. Ranges from 0 to 7.
-- @return 0 - 65535 where 32767 is the middle.
function joystick_library.getAxis( enum, axis )
	refresh( enum )
	return joystick.axis( enum, axis )
end

--- Gets the pov data value.
-- @param enum Joystick number. Starts at 0
-- @param pov Joystick pov number. Ranges from 0 to 7.
-- @return 0 - 65535 where 32767 is the middle.
function joystick_library.getPov( enum, pov )
	refresh( enum )
	return joystick.pov( enum, pov )
end

--- Returns if the button is pushed or not
-- @param enum Joystick number. Starts at 0
-- @param button Joystick button number. Starts at 0
-- @return 0 or 1
function joystick_library.getButton( enum, button )
	refresh( enum )
	return joystick.button( enum, button )
end

--- Gets the hardware name of the joystick
-- @param enum Joystick number. Starts at 0
-- @return Name of the device
function joystick_library.getName( enum )
	refresh( enum )
	return joystick.name( enum )
end

--- Gets the number of detected joysticks.
-- @return Number of joysticks
function joystick_library.numJoysticks( )
	return joystick.count( )
end

--- Gets the number of detected axes on a joystick
-- @param enum Joystick number. Starts at 0
-- @return Number of axes
function joystick_library.numAxes( enum )
	refresh( enum )
	return joystick.count( enum, 1 )
end

--- Gets the number of detected povs on a joystick
-- @param enum Joystick number. Starts at 0
-- @return Number of povs
function joystick_library.numPovs( enum )
	refresh( enum )
	return joystick.count( enum, 2 )
end

--- Gets the number of detected buttons on a joystick
-- @param enum Joystick number. Starts at 0
-- @return Number of buttons
function joystick_library.numButtons( enum )
	refresh( enum )
	return joystick.count( enum, 3 )
end

