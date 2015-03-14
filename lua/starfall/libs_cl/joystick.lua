
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

function joystick_library.getAxis( enum, axis )
	if joystick then
		refresh( enum )
		return joystick.axis( enum, axis )
	end
end

function joystick_library.getPov( enum, pov )
	if joystick then
		refresh( enum )
		return joystick.pov( enum, pov )
	end
end

function joystick_library.getButton( enum, button )
	if joystick then
		refresh( enum )
		return joystick.button( enum, button )
	end
end

function joystick_library.getName( enum )
	if joystick then
		refresh( enum )
		return joystick.name( enum )
	end
end

function joystick_library.numJoysticks( )
	if joystick then
		return joystick.count( )
	end
end

function joystick_library.numAxes( enum )
	if joystick then
		refresh( enum )
		return joystick.count( enum, 1 )
	end
end

function joystick_library.numPovs( enum )
	if joystick then
		refresh( enum )
		return joystick.count( enum, 2 )
	end
end

function joystick_library.numButtons( enum )
	if joystick then
		refresh( enum )
		return joystick.count( enum, 3 )
	end
end

