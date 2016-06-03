
--- This should manage the player button hooks for singleplayer games.
local PlayerButtonDown, PlayerButtonUp
if game.SinglePlayer() then
	if SERVER then
		util.AddNetworkString("sf_relayinput")
		
		--- These should only get called if the game is singleplayer or listen
		hook.Add( "PlayerButtonDown", "SF_PlayerButtonDown", function(ply, but)
			net.Start("sf_relayinput")
			net.WriteBool(true)
			net.WriteInt(but, 16)
			net.Send(ply)
		end )
		
		hook.Add( "PlayerButtonUp", "SF_PlayerButtonUp", function(ply, but)
			net.Start("sf_relayinput")
			net.WriteBool(false)
			net.WriteInt(but, 16)
			net.Send(ply)
		end)
	else
		net.Receive( "sf_relayinput", function(len, ply)
			local down = net.ReadBool()
			local key = net.ReadInt(16)
			if down then
				PlayerButtonDown(LocalPlayer(), key)
			else
				PlayerButtonUp(LocalPlayer(), key)
			end
		end )
	end	
end
if SERVER then return end

---- Input library.
--- @client
local input_methods, input_metamethods = SF.Libraries.Register( "input" )

do
	local P = SF.Permissions
	P.registerPrivilege( "input", "Input", "Allows the user to use the input library" )
end

---- Gets the first key that is bound to the command passed
--- @param binding The name of the bind
--- @return The id of the first key bound
--- @return The name of the first key bound

function input_methods.lookupBinding( binding )
	SF.CheckType( binding, "string" )

	if not SF.Permissions.check( SF.instance.player, nil, "input" ) then SF.throw( "Insufficient permissions", 2 ) end

	local bind = input.LookupBinding( binding )
	if bind then
		bind = bind:upper( )
		return input_methods.KEY[ bind ] or input_methods.MOUSE[ bind ], bind
	end
end

---- Gets whether a key is down
--- @param key The key id, see input
--- @return True if the key is down
function input_methods.isKeyDown( key )
	SF.CheckType( key, "number" )

	if not SF.Permissions.check( SF.instance.player, nil, "input" ) then SF.throw( "Insufficient permissions", 2 ) end

	return input.IsKeyDown( key )
end

---- Gets the name of a key from the id
--- @param key The key id, see input
--- @return The name of the key
function input_methods.getKeyName( key )
	SF.CheckType( key, "number" )

	if not SF.Permissions.check( SF.instance.player, nil, "input" ) then SF.throw( "Insufficient permissions", 2 ) end

	return input.GetKeyName( key )
end

---- Gets whether the shift key is down
--- @return True if the shift key is down
function input_methods.isShiftDown( )
	if not SF.Permissions.check( SF.instance.player, nil, "input" ) then SF.throw( "Insufficient permissions", 2 ) end

	return input.IsShiftDown( )
end

---- Gets whether the control key is down
--- @return True if the control key is down
function input_methods.isControlDown( )
	if not SF.Permissions.check( SF.instance.player, nil, "input" ) then SF.throw( "Insufficient permissions", 2 ) end

	return input.IsControlDown( )
end

---- Gets the position of the mouse
--- @return The x position of the mouse
--- @return The y position of the mouse
function input_methods.getCursorPos( )
	if not SF.Permissions.check( SF.instance.player, nil, "input" ) then SF.throw( "Insufficient permissions", 2 ) end

	return input.GetCursorPos( )
end

local function runInputHook( hookname, key )
	for instance,_ in pairs( SF.allInstances ) do
		if SF.Permissions.check( instance.player, nil, "input" ) then
		
		
			local ok, err, tr = instance:runScriptHook( hookname, key )
			if not ok then
				instance:Error( "Hook 'input' errored with " .. err, tr )
			end
		end
	end
end

function PlayerButtonDown(ply, button)
	if IsFirstTimePredicted() then
		runInputHook( "inputPressed", button )
	end
end

function PlayerButtonUp(ply, button)
	if IsFirstTimePredicted() then
		runInputHook( "inputReleased", button )
	end
end

hook.Add( "PlayerButtonDown", "SF_PlayerButtonDown", PlayerButtonDown)
hook.Add( "PlayerButtonUp", "SF_PlayerButtonUp", PlayerButtonUp)

---- Called when a button is pressed
--- @name inputPressed
--- @class hook
--- @param button Number of the button

---- Called when a button is released
--- @name inputReleased
--- @class hook
--- @param button Number of the button
