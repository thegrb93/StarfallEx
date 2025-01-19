-- Global to all starfalls
local registerprivilege = SF.Permissions.registerPrivilege
local haspermission = SF.Permissions.hasAccess
local checkluatype = SF.CheckLuaType
local inputLockCooldown
if CLIENT then
	inputLockCooldown = CreateConVar("sf_input_lock_cooldown", 10, FCVAR_ARCHIVE, "Cooldown for input.lockControls() in seconds", 0)
end

-- This should manage the player button hooks for singleplayer games.
local PlayerButtonDown, PlayerButtonUp
if game.SinglePlayer() then
	PlayerButtonDown, PlayerButtonUp = "SF_PlayerButtonDown", "SF_PlayerButtonUp"
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
				hook.Run("SF_PlayerButtonDown", LocalPlayer(), key)
			else
				hook.Run("SF_PlayerButtonUp", LocalPlayer(), key)
			end
		end)
	end
else
	PlayerButtonDown, PlayerButtonUp = "PlayerButtonDown", "PlayerButtonUp"
end
if SERVER then
	util.AddNetworkString("starfall_lock_control")
	return function() end
end

registerprivilege("input", "Input", "Allows the user to see what buttons you're pressing.", { client = {} })
registerprivilege("input.chat", "Input", "Allows the user to see your chat keypresses.", { client = { default = 1 } })
registerprivilege("input.bindings", "Input", "Allows the user to see your bindings.", { client = { default = 1 } })
registerprivilege("input.emulate", "Input", "Allows starfall to emulate user input.", { client = { default = 1 } })

local controlsLocked = false
local function unlockControls(instance)
	instance.data.input.controlsLocked = false
	controlsLocked = false
	hook.Remove("PlayerBindPress", "sf_keyboard_blockinput")
	hook.Remove(PlayerButtonDown, "sf_keyboard_unblockinput")
end

local function lockControls(instance)
	instance.data.input.controlsLocked = true
	controlsLocked = true
	LocalPlayer():ChatPrint("Starfall locked your controls. Press 'Alt' to regain control.")

	hook.Add("PlayerBindPress", "sf_keyboard_blockinput", function(ply, bind, pressed)
		if bind ~= "+attack" and bind ~= "+attack2" then return true end
	end)
	hook.Add(PlayerButtonDown, "sf_keyboard_unblockinput", function(ply, but)
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

local isChatOpen = false
hook.Add("StartChat","SF_StartChat",function() isChatOpen=true end)
hook.Add("FinishChat","SF_StartChat",function() isChatOpen=false end)


local function CheckButtonPerms(instance, ply, button)
	if not IsFirstTimePredicted() and not game.SinglePlayer() then return false end
	if not haspermission(instance, nil, "input") then return false end
	if isChatOpen and not haspermission(instance, nil, "input.chat") then
		local notMouseButton = button < MOUSE_FIRST and button > MOUSE_LAST
		local notJoystick = button < JOYSTICK_FIRST and button > JOYSTICK_LAST
		if notMouseButton and notJoystick then return false end -- Mouse and joystick are allowed, they don't put text into the chat
	end

	return true, { button }
end

--- Called when a button is pressed
-- @client
-- @name InputPressed
-- @class hook
-- @param number button Number of the button
SF.hookAdd(PlayerButtonDown, "inputpressed", CheckButtonPerms)

--- Called when a button is released
-- @client
-- @name InputReleased
-- @class hook
-- @param number button Number of the button
SF.hookAdd(PlayerButtonUp, "inputreleased", CheckButtonPerms)

--- Called when a keybind is pressed
-- @client
-- @name InputBindPressed
-- @class hook
-- @param string bind Name of keybind pressed
SF.hookAdd("PlayerBindPress", "inputbindpressed", function(instance, ply, bind)
	if haspermission(instance, nil, "input") then
		return true, {bind}
	end
	return false
end)

--- Called when the mouse is moved
-- @client
-- @name MouseMoved
-- @class hook
-- @param number x X coordinate moved
-- @param number y Y coordinate moved
SF.hookAdd("InputMouseApply", "mousemoved", function(instance, _, x, y)
	if haspermission(instance, nil, "input") then
		if x~=0 or y~=0 then
			return true, { x, y }
		end
		return false
	end
	return false
end)

--- Called when the mouse wheel is rotated
-- @client
-- @name MouseWheeled
-- @class hook
-- @param number delta Rotate delta
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

local wpanel = vgui.GetWorldPanel()
local oldOnMouseWheeled = wpanel.OnMouseWheeled or function() end
function wpanel:OnMouseWheeled(delta)
	oldOnMouseWheeled(self, delta)
	for inst, _ in pairs(SF.allInstances) do
		if haspermission(inst, nil, "input") then
			inst:runScriptHook("mousewheeled", delta)
		end
	end
end

--- Input library.
-- @name input
-- @class library
-- @libtbl input_library
SF.RegisterLibrary("input")


return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local getent
local lockedControlCooldown = 0
instance.data.input = {controlsLocked = false}

instance:AddHook("initialize", function()
	getent = instance.Types.Entity.GetEntity
end)

instance:AddHook("deinitialize", function()
	if instance.data.cursorEnabled then
		gui.EnableScreenClicker(false)
	end
	if instance.data.input.controlsLocked then
		unlockControls(instance)
	end
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
-- @param string binding The name of the bind
-- @return number The id of the first key bound
-- @return string The name of the first key bound
function input_library.lookupBinding(binding)
	checkluatype(binding, TYPE_STRING)

	checkpermission(instance, nil, "input")

	local bind = input.LookupBinding(binding)
	if bind then
		bind = bind:upper()

		return instance.env.KEY[bind] or instance.env.MOUSE[bind], bind
	end
end

--- Gets the command bound to a key
-- @client
-- @param number key The key id, see input
-- @return string The command bound to the key
function input_library.lookupKeyBinding(key)
	checkluatype(key, TYPE_NUMBER)
	checkpermission(instance, nil, "input.bindings")
	return input.LookupKeyBinding(key)
end

--- Gets whether a key is down
-- @client
-- @param number key The key id, see input
-- @return boolean True if the key is down
function input_library.isKeyDown(key)
	checkluatype(key, TYPE_NUMBER)

	checkpermission(instance, nil, "input")
	if isChatOpen and not haspermission(instance, nil, "input.chat") then return false end

	return input.IsKeyDown(key)
end

--- Gets whether a mouse button is down
-- @client
-- @param number key The mouse button id, see input
-- @return boolean True if the key is down
function input_library.isMouseDown(key)
	checkluatype(key, TYPE_NUMBER)

	checkpermission(instance, nil, "input")

	return input.IsMouseDown(key)
end

--- Gets the name of a key from the id
-- @client
-- @param number key The key id, see input
-- @return string The name of the key
function input_library.getKeyName(key)
	checkluatype(key, TYPE_NUMBER)

	checkpermission(instance, nil, "input")

	return input.GetKeyName(key)
end

--- Gets whether the shift key is down
-- @client
-- @return boolean True if the shift key is down
function input_library.isShiftDown()
	checkpermission(instance, nil, "input")

	return input.IsShiftDown()
end

--- Gets whether the control key is down
-- @client
-- @return boolean True if the control key is down
function input_library.isControlDown()
	checkpermission(instance, nil, "input")

	return input.IsControlDown()
end

--- Gets the position of the mouse
-- @client
-- @return number The x position of the mouse
-- @return number The y position of the mouse
function input_library.getCursorPos()
	checkpermission(instance, nil, "input")

	return input.GetCursorPos()
end

--- Gets whether the cursor is visible on the screen
-- @client
-- @return boolean The cursor's visibility
function input_library.getCursorVisible()
	checkpermission(instance, nil, "input")

	return vgui.CursorVisible()
end

--- Translates position on player's screen to aim vector
-- @client
-- @param number x X coordinate on the screen
-- @param number y Y coordinate on the screen
-- @return Vector Aim vector
function input_library.screenToVector(x, y)
	checkpermission(instance, nil, "input")
	checkluatype(x, TYPE_NUMBER)
	checkluatype(y, TYPE_NUMBER)
	return vwrap(gui.ScreenToVector(x, y))
end

--- Sets the state of the mouse cursor
-- @client
-- @param boolean enabled Whether or not the cursor should be enabled
function input_library.enableCursor(enabled)
	checkluatype(enabled, TYPE_BOOL)
	checkpermission(instance, nil, "input")

	if not SF.IsHUDActive(instance.entity) then
		SF.Throw("No HUD component connected", 2)
	end

	instance.data.cursorEnabled = enabled
	gui.EnableScreenClicker(enabled)
end

--- Makes the local player select a weapon
-- @client
-- @param Weapon weapon The weapon entity to select
function input_library.selectWeapon(weapon)
	local ent = getent(weapon)
	if not (ent:IsWeapon() and ent:IsCarriedByLocalPlayer()) then SF.Throw("This weapon is not your own!", 2) end
	checkpermission(instance, nil, "input.emulate")
	input.SelectWeapon( ent )
end

--- Locks game controls for typing purposes. Alt will unlock the controls. Has a 10 second cooldown.
-- @client
-- @param boolean enabled Whether to lock or unlock the controls
function input_library.lockControls(enabled)
	checkluatype(enabled, TYPE_BOOL)
	checkpermission(instance, nil, "input")

	if not SF.IsHUDActive(instance.entity) and (enabled or not instance.data.input.controlsLocked) then
		SF.Throw("No HUD component connected", 2)
	end

	if enabled then
		if lockedControlCooldown + inputLockCooldown:GetFloat() > CurTime() then
			SF.Throw("Cannot lock the player's controls yet", 2)
		end
		lockedControlCooldown = CurTime()
		lockControls(instance)
	else
		unlockControls(instance)
	end
end

--- Gets whether the player's control is currently locked
-- @client
-- @return boolean Whether the player's control is locked
function input_library.isControlLocked()
	return controlsLocked
end

--- Gets whether the player's control can be locked
-- @client
-- @return boolean Whether the player's control can be locked
function input_library.canLockControls()
	return SF.IsHUDActive(instance.entity) and lockedControlCooldown + inputLockCooldown:GetFloat() <= CurTime()
end

--- Returns whether the game menu overlay ( main menu ) is open or not.
-- @client
-- @return boolean Whether the game menu overlay ( main menu ) is open or not
function input_library.isGameUIVisible()
	return gui.IsGameUIVisible()
end

--- Returns the digital value of an analog stick on the current (set up via convars) controller.
-- @name input_library.getAnalogValue
-- @class function
-- @client
-- @param number axis The analog axis to poll. See https://wiki.facepunch.com/gmod/Enums/ANALOG
-- @return number The digital value.
input_library.getAnalogValue = input.GetAnalogValue

end
