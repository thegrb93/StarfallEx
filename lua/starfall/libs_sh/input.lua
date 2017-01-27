
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
				hook.Run("PlayerButtonDown", LocalPlayer(), key)
			else
				hook.Run("PlayerButtonUp", LocalPlayer(), key)
			end
		end )
	end	
end
if SERVER then return end

---- Input library.
--- @client
local input_methods, input_metamethods = SF.Libraries.Register( "input" )

SF.Permissions.registerPrivilege( "input", "Input", "Allows the user to see what buttons you're pressing.", {"Client"} )

---- Gets the first key that is bound to the command passed
--- @param binding The name of the bind
--- @return The id of the first key bound
--- @return The name of the first key bound

function input_methods.lookupBinding( binding )
	SF.CheckType( binding, "string" )

	SF.Permissions.check( SF.instance.player, nil, "input" )

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

	SF.Permissions.check( SF.instance.player, nil, "input" )

	return input.IsKeyDown( key )
end

---- Gets the name of a key from the id
--- @param key The key id, see input
--- @return The name of the key
function input_methods.getKeyName( key )
	SF.CheckType( key, "number" )

	SF.Permissions.check( SF.instance.player, nil, "input" )

	return input.GetKeyName( key )
end

---- Gets whether the shift key is down
--- @return True if the shift key is down
function input_methods.isShiftDown( )
	SF.Permissions.check( SF.instance.player, nil, "input" )

	return input.IsShiftDown( )
end

---- Gets whether the control key is down
--- @return True if the control key is down
function input_methods.isControlDown( )
	SF.Permissions.check( SF.instance.player, nil, "input" )

	return input.IsControlDown( )
end

---- Gets the position of the mouse
--- @return The x position of the mouse
--- @return The y position of the mouse
function input_methods.getCursorPos( )
	SF.Permissions.check( SF.instance.player, nil, "input" )

	return input.GetCursorPos( )
end

function CheckButtonPerms(instance, ply, button)
	if (IsFirstTimePredicted() or game.SinglePlayer()) and SF.Permissions.hasAccess( instance.player, nil, "input" ) then
		return true, {button}
	end
	return false
end

SF.hookAdd( "PlayerButtonDown", "inputpressed", CheckButtonPerms)
SF.hookAdd( "PlayerButtonUp", "inputreleased", CheckButtonPerms)

---- Called when a button is pressed
--- @name inputPressed
--- @class hook
--- @param button Number of the button

---- Called when a button is released
--- @name inputReleased
--- @class hook
--- @param button Number of the button
