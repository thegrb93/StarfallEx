-- Global to all starfalls
local registerprivilege = SF.Permissions.registerPrivilege
local haspermission = SF.Permissions.hasAccess

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
	SF.CheckLuaType(binding, TYPE_STRING)

	SF.Permissions.check(instance, nil, "input")

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
	SF.CheckLuaType(key, TYPE_NUMBER)

	SF.Permissions.check(instance, nil, "input")

	return input.IsKeyDown(key)
end

--- Gets the name of a key from the id
-- @client
-- @param key The key id, see input
-- @return The name of the key
function input_library.getKeyName(key)
	SF.CheckLuaType(key, TYPE_NUMBER)

	SF.Permissions.check(instance, nil, "input")

	return input.GetKeyName(key)
end

--- Gets whether the shift key is down
-- @client
-- @return True if the shift key is down
function input_library.isShiftDown()
	SF.Permissions.check(instance, nil, "input")

	return input.IsShiftDown()
end

--- Gets whether the control key is down
-- @client
-- @return True if the control key is down
function input_library.isControlDown()
	SF.Permissions.check(instance, nil, "input")

	return input.IsControlDown()
end

--- Gets the position of the mouse
-- @client
-- @return The x position of the mouse
-- @return The y position of the mouse
function input_library.getCursorPos()
	SF.Permissions.check(instance, nil, "input")

	return input.GetCursorPos()
end

--- Gets whether the cursor is visible on the screen
-- @client
-- @return The cursor's visibility
function input_library.getCursorVisible()
	SF.Permissions.check(instance, nil, "input")

	return vgui.CursorVisible()
end

---Translates position on player's screen to aim vector
-- @client
-- @param x X coordinate on the screen
-- @param y Y coordinate on the screen
-- @return Aim vector
function input_library.screenToVector(x, y)
	SF.Permissions.check(instance, nil, "input")
	SF.CheckLuaType(x, TYPE_NUMBER)
	SF.CheckLuaType(y, TYPE_NUMBER)
	return vwrap(gui.ScreenToVector(x, y))
end

--- Sets the state of the mouse cursor
-- @client
-- @param enabled Whether or not the cursor should be enabled
function input_library.enableCursor(enabled)
	SF.CheckLuaType(enabled, TYPE_BOOL)
	SF.Permissions.check(instance, nil, "input")

	if not instance:isHUDActive() then
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
	SF.Permissions.check(instance, nil, "input.emulate")
	input.SelectWeapon( ent ) 
end

--- Locks game controls for typing purposes. Alt will unlock the controls. Has a 10 second cooldown.
-- @client
-- @param enabled Whether to lock or unlock the controls
function input_library.lockControls(enabled)
	SF.CheckLuaType(enabled, TYPE_BOOL)
	SF.Permissions.check(instance, nil, "input")

	if not instance:isHUDActive() and (enabled or not instance.data.input.controlsLocked) then
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
	return instance:isHUDActive() and
		(not instance.data.lockedControlCooldown or instance.data.lockedControlCooldown <= CurTime())
end

instance.env.KEY = {
	["FIRST"] = 0,
	["NONE"] = 0,
	["0"] = 1,
	["1"] = 2,
	["2"] = 3,
	["3"] = 4,
	["4"] = 5,
	["5"] = 6,
	["6"] = 7,
	["7"] = 8,
	["8"] = 9,
	["9"] = 10,
	["A"] = 11,
	["B"] = 12,
	["C"] = 13,
	["D"] = 14,
	["E"] = 15,
	["F"] = 16,
	["G"] = 17,
	["H"] = 18,
	["I"] = 19,
	["J"] = 20,
	["K"] = 21,
	["L"] = 22,
	["M"] = 23,
	["N"] = 24,
	["O"] = 25,
	["P"] = 26,
	["Q"] = 27,
	["R"] = 28,
	["S"] = 29,
	["T"] = 30,
	["U"] = 31,
	["V"] = 32,
	["W"] = 33,
	["X"] = 34,
	["Y"] = 35,
	["Z"] = 36,
	["KP_INS"] = 37,
	["PAD_0"] = 37,
	["KP_END"] = 38,
	["PAD_1"] = 38,
	["KP_DOWNARROW "] = 39,
	["PAD_2"] = 39,
	["KP_PGDN"] = 40,
	["PAD_3"] = 40,
	["KP_LEFTARROW"] = 41,
	["PAD_4"] = 41,
	["KP_5 "] = 42,
	["PAD_5"] = 42,
	["KP_RIGHTARROW"] = 43,
	["PAD_6"] = 43,
	["KP_HOME"] = 44,
	["PAD_7"] = 44,
	["KP_UPARROW"] = 45,
	["PAD_8"] = 45,
	["KP_PGUP"] = 46,
	["PAD_9"] = 46,
	["PAD_DIVIDE"] = 47,
	["KP_SLASH"] = 47,
	["KP_MULTIPLY"] = 48,
	["PAD_MULTIPLY"] = 48,
	["KP_MINUS"] = 49,
	["PAD_MINUS"] = 49,
	["KP_PLUS"] = 50,
	["PAD_PLUS"] = 50,
	["KP_ENTER"] = 51,
	["PAD_ENTER"] = 51,
	["KP_DEL"] = 52,
	["PAD_DECIMAL"] = 52,
	["["] = 53,
	["LBRACKET"] = 53,
	["]"] = 54,
	["RBRACKET"] = 54,
	["SEMICOLON"] = 55,
	["'"] = 56,
	["APOSTROPHE"] = 56,
	["`"] = 57,
	["BACKQUOTE"] = 57,
	[","] = 58,
	["COMMA"] = 58,
	["."] = 59,
	["PERIOD"] = 59,
	["/"] = 60,
	["SLASH"] = 60,
	["\\"] = 61,
	["BACKSLASH"] = 61,
	["-"] = 62,
	["MINUS"] = 62,
	["="] = 63,
	["EQUAL"] = 63,
	["ENTER"] = 64,
	["SPACE"] = 65,
	["BACKSPACE"] = 66,
	["TAB"] = 67,
	["CAPSLOCK"] = 68,
	["NUMLOCK"] = 69,
	["ESCAPE"] = 70,
	["SCROLLLOCK"] = 71,
	["INS"] = 72,
	["INSERT"] = 72,
	["DEL"] = 73,
	["DELETE"] = 73,
	["HOME"] = 74,
	["END"] = 75,
	["PGUP"] = 76,
	["PAGEUP"] = 76,
	["PGDN"] = 77,
	["PAGEDOWN"] = 77,
	["PAUSE"] = 78,
	["BREAK"] = 78,
	["SHIFT"] = 79,
	["LSHIFT"] = 79,
	["RSHIFT"] = 80,
	["ALT"] = 81,
	["LALT"] = 81,
	["RALT"] = 82,
	["CTRL"] = 83,
	["LCONTROL"] = 83,
	["RCTRL"] = 84,
	["RCONTROL"] = 84,
	["LWIN"] = 85,
	["RWIN"] = 86,
	["APP"] = 87,
	["UPARROW"] = 88,
	["UP"] = 88,
	["LEFTARROW"] = 89,
	["LEFT"] = 89,
	["DOWNARROW"] = 90,
	["DOWN"] = 90,
	["RIGHTARROW"] = 91,
	["RIGHT"] = 91,
	["F1"] = 92,
	["F2"] = 93,
	["F3"] = 94,
	["F4"] = 95,
	["F5"] = 96,
	["F6"] = 97,
	["F7"] = 98,
	["F8"] = 99,
	["F9"] = 100,
	["F10"] = 101,
	["F11"] = 102,
	["F12"] = 103,
	["CAPSLOCKTOGGLE"] = 104,
	["NUMLOCKTOGGLE"] = 105,
	["SCROLLLOCKTOGGLE"] = 106,
	["LAST"] = 106,
	["COUNT"] = 106
}

instance.env.MOUSE = {
	["MOUSE1"] = 107,
	["LEFT"] = 107,
	["MOUSE2"] = 108,
	["RIGHT"] = 108,
	["MOUSE3"] = 109,
	["MIDDLE"] = 109,
	["MOUSE4"] = 110,
	["4"] = 110,
	["MOUSE5"] = 111,
	["5"] = 111,
	["MWHEELUP"] = 112,
	["WHEEL_UP"] = 112,
	["MWHEELDOWN"] = 113,
	["WHEEL_DOWN"] = 113,
	["COUNT"] = 7,
	["FIRST"] = 107,
	["LAST"] = 113
}


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


--- ENUMs of keyboard keys for use with input library:
-- FIRST,
-- NONE,
-- 0,
-- 1,
-- 2,
-- 3,
-- 4,
-- 5,
-- 6,
-- 7,
-- 8,
-- 9,
-- A,
-- B,
-- C,
-- D,
-- E,
-- F,
-- G,
-- H,
-- I,
-- J,
-- K,
-- L,
-- M,
-- N,
-- O,
-- P,
-- Q,
-- R,
-- S,
-- T,
-- U,
-- V,
-- W,
-- X,
-- Y,
-- Z,
-- KP_INS,
-- PAD_0,
-- KP_END,
-- PAD_1,
-- KP_DOWNARROW ,
-- PAD_2,
-- KP_PGDN,
-- PAD_3,
-- KP_LEFTARROW,
-- PAD_4,
-- KP_5 ,
-- PAD_5,
-- KP_RIGHTARROW,
-- PAD_6,
-- KP_HOME,
-- PAD_7,
-- KP_UPARROW,
-- PAD_8,
-- KP_PGUP,
-- PAD_9,
-- PAD_DIVIDE,
-- KP_SLASH,
-- KP_MULTIPLY,
-- PAD_MULTIPLY,
-- KP_MINUS,
-- PAD_MINUS,
-- KP_PLUS,
-- PAD_PLUS,
-- KP_ENTER,
-- PAD_ENTER,
-- KP_DEL,
-- PAD_DECIMAL,
-- LBRACKET,
-- RBRACKET,
-- SEMICOLON,
-- APOSTROPHE,
-- BACKQUOTE,
-- COMMA,
-- PERIOD,
-- SLASH,
-- BACKSLASH,
-- MINUS,
-- EQUAL,
-- ENTER,
-- SPACE,
-- BACKSPACE,
-- TAB,
-- CAPSLOCK,
-- NUMLOCK,
-- ESCAPE,
-- SCROLLLOCK,
-- INS,
-- INSERT,
-- DEL,
-- DELETE,
-- HOME,
-- END,
-- PGUP,
-- PAGEUP,
-- PGDN,
-- PAGEDOWN,
-- PAUSE,
-- BREAK,
-- SHIFT,
-- LSHIFT,
-- RSHIFT,
-- ALT,
-- LALT,
-- RALT,
-- CTRL,
-- LCONTROL,
-- RCTRL,
-- RCONTROL,
-- LWIN,
-- RWIN,
-- APP,
-- UPARROW,
-- UP,
-- LEFTARROW,
-- LEFT,
-- DOWNARROW,
-- DOWN,
-- RIGHTARROW,
-- RIGHT,
-- F1,
-- F2,
-- F3,
-- F4,
-- F5,
-- F6,
-- F7,
-- F8,
-- F9,
-- F10,
-- F11,
-- F12,
-- CAPSLOCKTOGGLE,
-- NUMLOCKTOGGLE,
-- SCROLLLOCKTOGGLE,
-- LAST,
-- COUNT
-- @name builtins_library.KEY
-- @class table

--- ENUMs of mouse buttons for use with input library:
-- MOUSE1,
-- LEFT,
-- MOUSE2,
-- RIGHT,
-- MOUSE3,
-- MIDDLE,
-- MOUSE4,
-- 4,
-- MOUSE5,
-- 5,
-- MWHEELUP,
-- WHEEL_UP,
-- MWHEELDOWN,
-- WHEEL_DOWN,
-- COUNT,
-- FIRST,
-- LAST
-- @name builtins_library.MOUSE
-- @class table
