-- Global to all starfalls
local registerprivilege = SF.Permissions.registerPrivilege
local haspermission = SF.Permissions.hasAccess
local checkluatype = SF.CheckLuaType

-- This should manage the player button hooks for singleplayer games.
local PlayerButtonDown, PlayerButtonUp
if game.SinglePlayer() then
	if SERVER then
		util.AddNetworkString("sf_relayinput")

		-- These should only get called if the game is singleplayer or listen
		hook.Add("PlayerButtonDown", "SF_PlayerButtonDown", function(ply, but)
			net.Start("sf_relayinput")
			net.WriteBool(true)
			net.WriteInt(but, 16)
			net.Send(ply)
		end)

		hook.Add("PlayerButtonUp", "SF_PlayerButtonUp", function(ply, but)
			net.Start("sf_relayinput")
			net.WriteBool(false)
			net.WriteInt(but, 16)
			net.Send(ply)
		end)
	else
		net.Receive("sf_relayinput", function(len, ply)
			local down = net.ReadBool()
			local key = net.ReadInt(16)
			if down then
				hook.Run("PlayerButtonDown", LocalPlayer(), key)
			else
				hook.Run("PlayerButtonUp", LocalPlayer(), key)
			end
		end)
	end
end
if SERVER then
	util.AddNetworkString("starfall_lock_control")
	return function() end
end

registerprivilege("input", "Input", "Allows the user to see what buttons you're pressing.", { client = {} })
registerprivilege("input.emulate", "Input", "Allows starfall to emulate user input.", { client = { default = 1 } })

local controlsLocked = false
local function unlockControls(instance)
	instance.data.input.controlsLocked = false
	controlsLocked = false
	hook.Remove("PlayerBindPress", "sf_keyboard_blockinput")
	hook.Remove("PlayerButtonDown", "sf_keyboard_unblockinput")
end

local function lockControls(instance)
	instance.data.input.controlsLocked = true
	controlsLocked = true
	LocalPlayer():ChatPrint("Starfall locked your controls. Press 'Alt' to regain control.")

	hook.Add("PlayerBindPress", "sf_keyboard_blockinput", function(ply, bind, pressed)
		if bind ~= "+attack" and bind ~= "+attack2" then return true end
	end)
	hook.Add("PlayerButtonDown", "sf_keyboard_unblockinput", function(ply, but)
		if but == KEY_LALT or but == KEY_RALT then
			unlockControls(instance)
		end
	end)
end

net.Receive("starfall_lock_control", function()
	local ent = net.ReadEntity()
	if ent:IsValid() then
		local instance = ent.instance
		if instance and not instance.error then
			if net.ReadBool() then
				lockControls(instance)
			else
				unlockControls(instance)
			end
		end
	end
end)


local function CheckButtonPerms(instance, ply, button)
	if (IsFirstTimePredicted() or game.SinglePlayer()) and haspermission(instance, nil, "input") then
		return true, { button }
	end
	return false
end

SF.hookAdd("PlayerButtonDown", "inputpressed", CheckButtonPerms)
SF.hookAdd("PlayerButtonUp", "inputreleased", CheckButtonPerms)

SF.hookAdd("StartCommand", "mousemoved", function(instance, ply, cmd)
	if haspermission(instance, nil, "input") then
		local x, y = cmd:GetMouseX(), cmd:GetMouseY()
		if x~=0 or y~=0 then
			return true, { x, y }
		end
		return false
	end
	return false
end)

SF.hookAdd("StartCommand", "mousewheeled", function(instance, ply, cmd)
	if haspermission(instance, nil, "input") then
		local delta = cmd:GetMouseWheel()
		if delta ~= 0 then
			return true, {delta}
		end
		return false
	end
	return false
end)


--- Input library.
-- @name input
-- @class library
-- @libtbl input_library
SF.RegisterLibrary("input")


return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local getent
instance:AddHook("initialize", function()
	getent = instance.Types.Entity.GetEntity
	instance.data.input = {controlsLocked = false}
end)

instance:AddHook("deinitialize", function()
	if instance.data.cursorEnabled then
		gui.EnableScreenClicker(false)
	end
	unlockControls(instance)
end)

instance:AddHook("starfall_hud_disconnected", function()
	if instance.data.cursorEnabled then
		gui.EnableScreenClicker(false)
	end
end)


local input_library = instance.Libraries.input
local vwrap = instance.Types.Vector.Wrap

--- Gets the first key that is bound to the command passed
-- @client
-- @param binding The name of the bind
-- @return The id of the first key bound
-- @return The name of the first key bound

function input_library.lookupBinding(binding)
	checkluatype(binding, TYPE_STRING)

	checkpermission(instance, nil, "input")

	local bind = input.LookupBinding(binding)
	if bind then
		bind = bind:upper()

		return instance.env.KEY[bind] or instance.env.MOUSE[bind], bind
	end
end

--- Gets whether a key is down
-- @client
-- @param key The key id, see input
-- @return True if the key is down
function input_library.isKeyDown(key)
	checkluatype(key, TYPE_NUMBER)

	checkpermission(instance, nil, "input")

	return input.IsKeyDown(key)
end

--- Gets whether a mouse button is down
-- @client
-- @param key The mouse button id, see input
-- @return True if the key is down
function input_library.isMouseDown(key)
	checkluatype(key, TYPE_NUMBER)

	checkpermission(instance, nil, "input")

	return input.IsMouseDown(key)
end

--- Gets the name of a key from the id
-- @client
-- @param key The key id, see input
-- @return The name of the key
function input_library.getKeyName(key)
	checkluatype(key, TYPE_NUMBER)

	checkpermission(instance, nil, "input")

	return input.GetKeyName(key)
end

--- Gets whether the shift key is down
-- @client
-- @return True if the shift key is down
function input_library.isShiftDown()
	checkpermission(instance, nil, "input")

	return input.IsShiftDown()
end

--- Gets whether the control key is down
-- @client
-- @return True if the control key is down
function input_library.isControlDown()
	checkpermission(instance, nil, "input")

	return input.IsControlDown()
end

--- Gets the position of the mouse
-- @client
-- @return The x position of the mouse
-- @return The y position of the mouse
function input_library.getCursorPos()
	checkpermission(instance, nil, "input")

	return input.GetCursorPos()
end

--- Gets whether the cursor is visible on the screen
-- @client
-- @return The cursor's visibility
function input_library.getCursorVisible()
	checkpermission(instance, nil, "input")

	return vgui.CursorVisible()
end

---Translates position on player's screen to aim vector
-- @client
-- @param x X coordinate on the screen
-- @param y Y coordinate on the screen
-- @return Aim vector
function input_library.screenToVector(x, y)
	checkpermission(instance, nil, "input")
	checkluatype(x, TYPE_NUMBER)
	checkluatype(y, TYPE_NUMBER)
	return vwrap(gui.ScreenToVector(x, y))
end

--- Sets the state of the mouse cursor
-- @client
-- @param enabled Whether or not the cursor should be enabled
function input_library.enableCursor(enabled)
	checkluatype(enabled, TYPE_BOOL)
	checkpermission(instance, nil, "input")

	if not instance.entity:IsHUDActive() then
		SF.Throw("No HUD component connected", 2)
	end

	instance.data.cursorEnabled = enabled
	gui.EnableScreenClicker(enabled)
end

--- Makes the local player select a weapon
-- @client
-- @param weapon The weapon entity to select
function input_library.selectWeapon(weapon)
	local ent = getent(weapon)
	if not (ent:IsWeapon() and ent:IsCarriedByLocalPlayer()) then SF.Throw("This weapon is not your own!", 2) end
	checkpermission(instance, nil, "input.emulate")
	input.SelectWeapon( ent ) 
end

--- Locks game controls for typing purposes. Alt will unlock the controls. Has a 10 second cooldown.
-- @client
-- @param enabled Whether to lock or unlock the controls
function input_library.lockControls(enabled)
	checkluatype(enabled, TYPE_BOOL)
	checkpermission(instance, nil, "input")

	if not instance.entity:IsHUDActive() and (enabled or not instance.data.input.controlsLocked) then
		SF.Throw("No HUD component connected", 2)
	end

	if enabled then
		if instance.data.lockedControlCooldown and instance.data.lockedControlCooldown > CurTime() then
			SF.Throw("Cannot lock the player's controls yet", 2)
		end
		instance.data.lockedControlCooldown = CurTime() + 10
		lockControls(instance)
	else
		unlockControls(instance)
	end
end

--- Gets whether the player's control is currenty locked
-- @client
-- @return Whether the player's control is locked
function input_library.isControlLocked()
	return controlsLocked
end

--- Gets whether the player's control can be locked
-- @client
-- @return Whether the player's control can be locked
function input_library.canLockControls()
	return instance.entity:IsHUDActive() and
		(not instance.data.lockedControlCooldown or instance.data.lockedControlCooldown <= CurTime())
end


end


--- Called when a button is pressed
-- @client
-- @name inputPressed
-- @class hook
-- @param button Number of the button

--- Called when a button is released
-- @client
-- @name inputReleased
-- @class hook
-- @param button Number of the button

--- Called when the mouse is moved
-- @client
-- @name mousemoved
-- @class hook
-- @param x X coordinate moved
-- @param y Y coordinate moved

--- Called when the mouse wheel is rotated
-- @client
-- @name mouseWheeled
-- @class hook
-- @param delta Rotate delta

