--- Input library
-- @client
local input_library, _ = SF.Libraries.Register( "input" )

do
	local P = SF.Permissions
	P.registerPrivilege( "input", "Input", "Allows the user to use the input library" )
	P.registerPrivilege( "input.key", "Keyboard", "Allows the user to poll keyboard inputs" )
	P.registerPrivilege( "input.mouse", "Mouse", "Allows the user to poll mouse inputs" )
end

--- Gets the first key that is bound to the command passed
-- @param bind The name of the bind
-- @return The id of the first key bound
-- @return The name of the first key bound

function input_library.lookupBinding( binding )
	SF.CheckType( binding, "string" )

	if not SF.Permissions.check( SF.instance.player, nil, "input" ) then SF.throw( "Insufficient permissions", 2 ) end

	local bind = input.LookupBinding( binding )
	if bind then
		bind = bind:upper( )
		return input_library.KEY[ bind ] or input_library.MOUSE[ bind ], bind
	end
end

--- Gets whether a key is down
-- @param key The key id, see input.KEY
-- @return True if the key is down
function input_library.isKeyDown( key )
	SF.CheckType( key, "number" )

	if not SF.Permissions.check( SF.instance.player, nil, "input.key" ) then SF.throw( "Insufficient permissions", 2 ) end

	return input.IsKeyDown( key )
end

--- Gets the name of a key from the id
-- @param key The key id, see input.KEY
-- @return The name of the key
function input_library.getKeyName( key )
	SF.CheckType( key, "number" )

	if not SF.Permissions.check( SF.instance.player, nil, "input" ) then SF.throw( "Insufficient permissions", 2 ) end

	return input.GetKeyName( key )
end

--- Gets whether the shift key is down
-- @return True if the shift key is down
function input_library.isShiftDown( )
	if not SF.Permissions.check( SF.instance.player, nil, "input.key" ) then SF.throw( "Insufficient permissions", 2 ) end

	return input.IsShiftDown( )
end

--- Gets whether the control key is down
-- @return True if the control key is down
function input_library.isControlDown( )
	if not SF.Permissions.check( SF.instance.player, nil, "input.key" ) then SF.throw( "Insufficient permissions", 2 ) end

	return input.IsControlDown( )
end

--- Gets the position of the mouse
-- @return The x position of the mouse
-- @return The y position of the mouse
function input_library.getCursorPos( )
	if not SF.Permissions.check( SF.instance.player, nil, "input.mouse" ) then SF.throw( "Insufficient permissions", 2 ) end

	return input.GetCursorPos( )
end

--- Gets whether a mouse button is down
-- @param key The mouse button, see input.MOUSE
-- @return True if the mouse button is down
function input_library.isMBDown( key )
	SF.CheckType( key, "number" )

	if not SF.Permissions.check( SF.instance.player, nil, "input.mouse" ) then SF.throw( "Insufficient permissions", 2 ) end

	return input.IsMouseDown( key )
end

local lastState = { key = { }, mouse = { } }
local keystate = { key = { }, mouse = { } }

for i = KEY_FIRST, KEY_LAST do
	lastState.key[ i ] = false
	keystate.key[ i ] = {
		wasPressed = false,
		wasReleased = false
	}
end

local function runInputHook( hookname, scope, key )
	for instance,_ in pairs( SF.allInstances ) do
		if not SF.Permissions.check( instance.player, nil, "input." .. scope ) then SF.throw( "Insufficient permissions", 2 ) end
		
		
		instance:runScriptHook( hookname, key )
	end
end

hook.Add( "Think", "sf_keystate_key update", function( )
	for i = KEY_FIRST, KEY_LAST do
		local isKeyDown = input.IsKeyDown( i )

		local keyName = input.GetKeyName( i )

		keystate.key[ i ].wasPressed = isKeyDown and lastState.key[ i ] ~= isKeyDown or false
		if keyName and keystate.key[ i ] and keystate.key[ i ].wasPressed then
			runInputHook( "inputPressed", "key", input.GetKeyName( i ):upper( ) )
		end

		keystate.key[ i ].wasReleased = not isKeyDown and lastState.key[ i ] ~= isKeyDown or false
		if keyName and keystate.key[ i ] and keystate.key[ i ].wasReleased then
			runInputHook( "inputReleased", "key", input.GetKeyName( i ):upper( ) )
		end
		
		lastState.key[ i ] = isKeyDown
	end
end )

--- Gets whether the key was pressed this frame
-- @param key The key id, see input.KEY
-- @return True if the key was pressed
function input_library.wasKeyPressed( key )
	SF.CheckType( key, "number" )

	if not SF.Permissions.check( SF.instance.player, nil, "input.key" ) then SF.throw( "Insufficient permissions", 2 ) end

	return keystate.key[ key ] and keystate.key[ key ].wasPressed
end

--- Gets whether the key was released this frame
-- @param key The key id, see input.KEY
-- @return True if the key was released
function input_library.wasKeyReleased( key )
	SF.CheckType( key, "number" )

	if not SF.Permissions.check( SF.instance.player, nil, "input.key" ) then SF.throw( "Insufficient permissions", 2 ) end

	return keystate.key[ key ] and keystate.key[ key ].wasReleased
end


for i = MOUSE_FIRST, MOUSE_LAST do
	lastState.mouse[ i ] = false
	keystate.mouse[ i ] = {
		wasPressed = false,
		wasReleased = false
	}
end

local _MOUSENAMES = {
	[ 107 ] = "MOUSE1",
	[ 108 ] = "MOUSE2",
	[ 109 ] = "MOUSE3",
	[ 110 ] = "MOUSE4",
	[ 111 ] = "MOUSE5",
	[ 112 ] = "MWHEELUP",
	[ 113 ] = "MWHEELDOWN"
}

hook.Add( "Think", "sf_keystate_mouse update", function( )
	for i = MOUSE_FIRST, MOUSE_LAST do
		local isKeyDown = input.IsMouseDown( i )

		local keyName = _MOUSENAMES[ i ]

		keystate.mouse[ i ].wasPressed = isKeyDown and lastState.mouse[ i ] ~= isKeyDown or false
		if keyName and keystate.mouse[ i ] and keystate.mouse[ i ].wasPressed then
			runInputHook( "inputPressed", "mouse", _MOUSENAMES[ i ]:upper( ) )
		end

		keystate.mouse[ i ].wasReleased = not isKeyDown and lastState.mouse[ i ] ~= isKeyDown or false
		if keyName and keystate.mouse[ i ] and keystate.mouse[ i ].wasReleased then
			runInputHook( "inputReleased", "mouse", _MOUSENAMES[ i ]:upper( ) )
		end

		lastState.mouse[ i ] = isKeyDown
	end
end )

--- Called when a button is pressed
-- @name inputPressed
-- @class hook
-- @param name Name of the key

--- Called when a button is released
-- @name inputReleased
-- @class hook
-- @param name Name of the key

--- Gets whether the mouse button was pressed this frame
-- @param key The button id, see input.MOUSE
-- @return True if the button was pressed
function input_library.wasMBPressed( key )
	SF.CheckType( key, "number" )

	if not SF.Permissions.check( SF.instance.player, nil, "input.mouse" ) then SF.throw( "Insufficient permissions", 2 ) end

	return keystate.mouse[ key ] and keystate.mouse[ key ].wasPressed
end

--- Gets whether the mouse button was released this frame
-- @param key The key id, see input.MOUSE
-- @return True if the button was released
function input_library.wasMBReleased( key )
	SF.CheckType( key, "number" )

	if not SF.Permissions.check( SF.instance.player, nil, "input.mouse" ) then SF.throw( "Insufficient permissions", 2 ) end

	return keystate.mouse[ key ] and keystate.mouse[ key ].wasReleased
end

local _KEY = {
	[ "FIRST" ] = 0,
	[ "NONE" ] = 0,
	[ "0" ] = 1,
	[ "1" ] = 2,
	[ "2" ] = 3,
	[ "3" ] = 4,
	[ "4" ] = 5,
	[ "5" ] = 6,
	[ "6" ] = 7,
	[ "7" ] = 8,
	[ "8" ] = 9,
	[ "9" ] = 10,
	[ "A" ] = 11,
	[ "B" ] = 12,
	[ "C" ] = 13,
	[ "D" ] = 14,
	[ "E" ] = 15,
	[ "F" ] = 16,
	[ "G" ] = 17,
	[ "H" ] = 18,
	[ "I" ] = 19,
	[ "J" ] = 20,
	[ "K" ] = 21,
	[ "L" ] = 22,
	[ "M" ] = 23,
	[ "N" ] = 24,
	[ "O" ] = 25,
	[ "P" ] = 26,
	[ "Q" ] = 27,
	[ "R" ] = 28,
	[ "S" ] = 29,
	[ "T" ] = 30,
	[ "U" ] = 31,
	[ "V" ] = 32,
	[ "W" ] = 33,
	[ "X" ] = 34,
	[ "Y" ] = 35,
	[ "Z" ] = 36,
	[ "KP_INS" ] = 37,
	[ "PAD_0" ] = 37,
	[ "KP_END" ] = 38,
	[ "PAD_1" ] = 38,
	[ "KP_DOWNARROW " ] = 39,
	[ "PAD_2" ] = 39,
	[ "KP_PGDN" ] = 40,
	[ "PAD_3" ] = 40,
	[ "KP_LEFTARROW" ] = 41,
	[ "PAD_4" ] = 41,
	[ "KP_5 " ] = 42,
	[ "PAD_5" ] = 42,
	[ "KP_RIGHTARROW" ] = 43,
	[ "PAD_6" ] = 43,
	[ "KP_HOME" ] = 44,
	[ "PAD_7" ] = 44,
	[ "KP_UPARROW" ] = 45,
	[ "PAD_8" ] = 45,
	[ "KP_PGUP" ] = 46,
	[ "PAD_9" ] = 46,
	[ "PAD_DIVIDE" ] = 47,
	[ "KP_SLASH" ] = 47,
	[ "KP_MULTIPLY" ] = 48,
	[ "PAD_MULTIPLY" ] = 48,
	[ "KP_MINUS" ] = 49,
	[ "PAD_MINUS" ] = 49,
	[ "KP_PLUS" ] = 50,
	[ "PAD_PLUS" ] = 50,
	[ "KP_ENTER" ] = 51,
	[ "PAD_ENTER" ] = 51,
	[ "KP_DEL" ] = 52,
	[ "PAD_DECIMAL" ] = 52,
	[ "[" ] = 53,
	[ "LBRACKET" ] = 53,
	[ "]" ] = 54,
	[ "RBRACKET" ] = 54,
	[ "SEMICOLON" ] = 55,
	[ "'" ] = 56,
	[ "APOSTROPHE" ] = 56,
	[ "`" ] = 57,
	[ "BACKQUOTE" ] = 57,
	[ "," ] = 58,
	[ "COMMA" ] = 58,
	[ "." ] = 59,
	[ "PERIOD" ] = 59,
	[ "/" ] = 60,
	[ "SLASH" ] = 60,
	[ "\\" ] = 61,
	[ "BACKSLASH" ] = 61,
	[ "-" ] = 62,
	[ "MINUS" ] = 62,
	[ "=" ] = 63,
	[ "EQUAL" ] = 63,
	[ "ENTER" ] = 64,
	[ "SPACE" ] = 65,
	[ "BACKSPACE" ] = 66,
	[ "TAB" ] = 67,
	[ "CAPSLOCK" ] = 68,
	[ "NUMLOCK" ] = 69,
	[ "ESCAPE" ] = 70,
	[ "SCROLLLOCK" ] = 71,
	[ "INS" ] = 72,
	[ "INSERT" ] = 72,
	[ "DEL" ] = 73,
	[ "DELETE" ] = 73,
	[ "HOME" ] = 74,
	[ "END" ] = 75,
	[ "PGUP" ] = 76,
	[ "PAGEUP" ] = 76,
	[ "PGDN" ] = 77,
	[ "PAGEDOWN" ] = 77,
	[ "PAUSE" ] = 78,
	[ "BREAK" ] = 78,
	[ "SHIFT" ] = 79,
	[ "LSHIFT" ] = 79,
	[ "RSHIFT" ] = 80,
	[ "ALT" ] = 81,
	[ "LALT" ] = 81,
	[ "RALT" ] = 82,
	[ "CTRL" ] = 83,
	[ "LCONTROL" ] = 83,
	[ "RCTRL" ] = 84,
	[ "RCONTROL" ] = 84,
	[ "LWIN" ] = 85,
	[ "RWIN" ] = 86,
	[ "APP" ] = 87,
	[ "UPARROW" ] = 88,
	[ "UP" ] = 88,
	[ "LEFTARROW" ] = 89,
	[ "LEFT" ] = 89,
	[ "DOWNARROW" ] = 90,
	[ "DOWN" ] = 90,
	[ "RIGHTARROW" ] = 91,
	[ "RIGHT" ] = 91,
	[ "F1" ] = 92,
	[ "F2" ] = 93,
	[ "F3" ] = 94,
	[ "F4" ] = 95,
	[ "F5" ] = 96,
	[ "F6" ] = 97,
	[ "F7" ] = 98,
	[ "F8" ] = 99,
	[ "F9" ] = 100,
	[ "F10" ] = 101,
	[ "F11" ] = 102,
	[ "F12" ] = 103,
	[ "CAPSLOCKTOGGLE" ] = 104,
	[ "NUMLOCKTOGGLE" ] = 105,
	[ "SCROLLLOCKTOGGLE" ] = 106,
	[ "LAST" ] = 106,
	[ "COUNT" ] = 106
}

--- ENUMs of keyboard keys
-- @name input_library.KEY
-- @class table
input_library.KEY = setmetatable( {}, {
	__index = _KEY,
	__newindex = function( )
	end,
	__metatable = false
} )

local _MOUSE = {
	[ "MOUSE1" ] = 107,
	[ "LEFT" ] = 107,
	[ "MOUSE2" ] = 108,
	[ "RIGHT" ] = 108,
	[ "MOUSE3" ] = 109,
	[ "MIDDLE" ] = 109,
	[ "MOUSE4" ] = 110,
	[ "4" ] = 110,
	[ "MOUSE5"] = 111,
	[ "5" ] = 111,
	[ "MWHEELUP" ] = 112,
	[ "WHEEL_UP" ] = 112,
	[ "MWHEELDOWN" ] = 113,
	[ "WHEEL_DOWN" ] = 113,
	[ "COUNT" ] = 7,
	[ "FIRST" ] = 107,
	[ "LAST" ] = 113
}

--- ENUMs of mouse buttons
-- @name input_library.MOUSE
-- @class table
input_library.MOUSE = setmetatable( {}, {
	__index = _MOUSE,
	__newindex = function( )
	end,
	__metatable = false
} )

--- Gets the name of a mouse button from the id
-- @param key The button id, see input.MOUSE
-- @return The name of the mouse button
function input_library.getMBName( key )
	SF.CheckType( key, "number" )

	if not SF.Permissions.check( SF.instance.player, nil, "input" ) then SF.throw( "Insufficient permissions", 2 ) end

	return _MOUSENAMES[ key ]
end