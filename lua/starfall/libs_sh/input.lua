
--- This should manage the player button hooks for singleplayer games.
local PlayerButtonDown, PlayerButtonUp
if game.SinglePlayer() then
	if SERVER then
		util.AddNetworkString("sf_relayinput")

		--- These should only get called if the game is singleplayer or listen
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
if SERVER then return end

---- Input library.
--- @client
local input_methods = SF.Libraries.Register("input")

SF.Permissions.registerPrivilege("input", "Input", "Allows the user to see what buttons you're pressing.", { ["Client"] = {} })

---- Gets the first key that is bound to the command passed
--- @param binding The name of the bind
--- @return The id of the first key bound
--- @return The name of the first key bound

function input_methods.lookupBinding(binding)
	SF.CheckLuaType(binding, TYPE_STRING)

	SF.Permissions.check(SF.instance.player, nil, "input")

	local bind = input.LookupBinding(binding)
	if bind then
		bind = bind:upper()

		return SF.DefaultEnvironment.KEY[bind] or SF.DefaultEnvironment.MOUSE[bind], bind
	end
end

---- Gets whether a key is down
--- @param key The key id, see input
--- @return True if the key is down
function input_methods.isKeyDown(key)
	SF.CheckLuaType(key, TYPE_NUMBER)

	SF.Permissions.check(SF.instance.player, nil, "input")

	return input.IsKeyDown(key)
end

---- Gets the name of a key from the id
--- @param key The key id, see input
--- @return The name of the key
function input_methods.getKeyName(key)
	SF.CheckLuaType(key, TYPE_NUMBER)

	SF.Permissions.check(SF.instance.player, nil, "input")

	return input.GetKeyName(key)
end

---- Gets whether the shift key is down
--- @return True if the shift key is down
function input_methods.isShiftDown()
	SF.Permissions.check(SF.instance.player, nil, "input")

	return input.IsShiftDown()
end

---- Gets whether the control key is down
--- @return True if the control key is down
function input_methods.isControlDown()
	SF.Permissions.check(SF.instance.player, nil, "input")

	return input.IsControlDown()
end

---- Gets the position of the mouse
--- @return The x position of the mouse
--- @return The y position of the mouse
function input_methods.getCursorPos()
	SF.Permissions.check(SF.instance.player, nil, "input")

	return input.GetCursorPos()
end

----Translates position on player's screen to aim vector
--- @param x X coordinate on the screen
--- @param y Y coordinate on the screen
--- @return Aim vector
function input_methods.screenToVector(x, y)
	SF.Permissions.check(SF.instance.player, nil, "input")
	SF.CheckLuaType(x, TYPE_NUMBER)
	SF.CheckLuaType(y, TYPE_NUMBER)
	return SF.WrapObject(gui.ScreenToVector(x, y))
end

---- Sets the state of the mouse cursor
--- @param enabled Whether or not the cursor should be enabled
function input_methods.enableCursor(enabled)
	SF.CheckLuaType(enabled, TYPE_BOOL)
	SF.Permissions.check(SF.instance.player, nil, "input")

	if not SF.instance:isHUDActive() then
		SF.Throw("No HUD component connected", 2)
	end

	gui.EnableScreenClicker(enabled)
end

SF.Libraries.AddHook("starfall_hud_disconnected", function(inst)
	if not inst:isHUDActive() then
		gui.EnableScreenClicker(false)
	end
end)

function CheckButtonPerms(instance, ply, button)
	if (IsFirstTimePredicted() or game.SinglePlayer()) and SF.Permissions.hasAccess(instance.player, nil, "input") then
		return true, { button }
	end
	return false
end

SF.hookAdd("PlayerButtonDown", "inputpressed", CheckButtonPerms)
SF.hookAdd("PlayerButtonUp", "inputreleased", CheckButtonPerms)


SF.hookAdd("StartCommand", "mousemoved", function(instance, ply, cmd)
	if SF.Permissions.hasAccess(instance.player, nil, "input") then
		local x, y = cmd:GetMouseX(), cmd:GetMouseY()
		if x~=0 or y~=0 then
			return true, { x, y }
		end
		return false
	end
	return false
end)

--- Called when a button is pressed
-- @name inputPressed
-- @class hook
-- @param button Number of the button

--- Called when a button is released
-- @name inputReleased
-- @class hook
-- @param button Number of the button

--- Called when the mouse is moved
-- @name mousemoved
-- @class hook
-- @param x X coordinate moved
-- @param y Y coordinate moved


SF.Libraries.AddHook("postload", function()
	local _KEY = {
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
	-- @name SF.DefaultEnvironment.KEY
	-- @class table
	SF.DefaultEnvironment.KEY = _KEY

	local _MOUSE = {
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
	-- @name SF.DefaultEnvironment.MOUSE
	-- @class table
	SF.DefaultEnvironment.MOUSE = _MOUSE
end)
