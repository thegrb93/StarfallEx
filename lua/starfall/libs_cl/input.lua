
--- Input library.
-- @client
local input_methods, input_metamethods = SF.Libraries.Register( "input" )

do
	local P = SF.Permissions
	P.registerPrivilege( "input", "Input", "Allows the user to use the input library" )
	P.registerPrivilege( "input.key", "Keyboard", "Allows the user to poll keyboard inputs" )
	P.registerPrivilege( "input.mouse", "Mouse", "Allows the user to poll mouse inputs" )
end

--- Gets the first key that is bound to the command passed
-- @param binding The name of the bind
-- @return The id of the first key bound
-- @return The name of the first key bound

function input_methods.lookupBinding( binding )
	SF.CheckType( binding, "string" )

	if not SF.Permissions.check( SF.instance.player, nil, "input" ) then SF.throw( "Insufficient permissions", 2 ) end

	local bind = input.LookupBinding( binding )
	if bind then
		bind = bind:upper( )
		return input_methods.KEY[ bind ] or input_methods.MOUSE[ bind ], bind
	end
end

--- Gets whether a key is down
-- @param key The key id, see input.KEY
-- @return True if the key is down
function input_methods.isKeyDown( key )
	SF.CheckType( key, "number" )

	if not SF.Permissions.check( SF.instance.player, nil, "input.key" ) then SF.throw( "Insufficient permissions", 2 ) end

	return input.IsKeyDown( key )
end

--- Gets the name of a key from the id
-- @param key The key id, see input.KEY
-- @return The name of the key
function input_methods.getKeyName( key )
	SF.CheckType( key, "number" )

	if not SF.Permissions.check( SF.instance.player, nil, "input" ) then SF.throw( "Insufficient permissions", 2 ) end

	return input.GetKeyName( key )
end

--- Gets whether the shift key is down
-- @return True if the shift key is down
function input_methods.isShiftDown( )
	if not SF.Permissions.check( SF.instance.player, nil, "input.key" ) then SF.throw( "Insufficient permissions", 2 ) end

	return input.IsShiftDown( )
end

--- Gets whether the control key is down
-- @return True if the control key is down
function input_methods.isControlDown( )
	if not SF.Permissions.check( SF.instance.player, nil, "input.key" ) then SF.throw( "Insufficient permissions", 2 ) end

	return input.IsControlDown( )
end

--- Gets the position of the mouse
-- @return The x position of the mouse
-- @return The y position of the mouse
function input_methods.getCursorPos( )
	if not SF.Permissions.check( SF.instance.player, nil, "input.mouse" ) then SF.throw( "Insufficient permissions", 2 ) end

	return input.GetCursorPos( )
end

--- Gets whether a mouse button is down
-- @param key The mouse button, see input.MOUSE
-- @return True if the mouse button is down
function input_methods.isMBDown( key )
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
		
		
		local ok, err, tr = instance:runScriptHook( hookname, key )
		if not ok then
			instance:Error( "Hook 'input' errored with " .. err, tr )
		end
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
function input_methods.wasKeyPressed( key )
	SF.CheckType( key, "number" )

	if not SF.Permissions.check( SF.instance.player, nil, "input.key" ) then SF.throw( "Insufficient permissions", 2 ) end

	return keystate.key[ key ] and keystate.key[ key ].wasPressed
end

--- Gets whether the key was released this frame
-- @param key The key id, see input.KEY
-- @return True if the key was released
function input_methods.wasKeyReleased( key )
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
function input_methods.wasMBPressed( key )
	SF.CheckType( key, "number" )

	if not SF.Permissions.check( SF.instance.player, nil, "input.mouse" ) then SF.throw( "Insufficient permissions", 2 ) end

	return keystate.mouse[ key ] and keystate.mouse[ key ].wasPressed
end

--- Gets whether the mouse button was released this frame
-- @param key The key id, see input.MOUSE
-- @return True if the button was released
function input_methods.wasMBReleased( key )
	SF.CheckType( key, "number" )

	if not SF.Permissions.check( SF.instance.player, nil, "input.mouse" ) then SF.throw( "Insufficient permissions", 2 ) end

	return keystate.mouse[ key ] and keystate.mouse[ key ].wasReleased
end

--- Gets the name of a mouse button from the id
-- @param key The button id, see input.MOUSE
-- @return The name of the mouse button
function input_methods.getMBName( key )
	SF.CheckType( key, "number" )

	if not SF.Permissions.check( SF.instance.player, nil, "input" ) then SF.throw( "Insufficient permissions", 2 ) end

	return _MOUSENAMES[ key ]
end