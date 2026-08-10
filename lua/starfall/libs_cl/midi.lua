if not SF.Require("midi") then return function() end end

local checkluatype = SF.CheckLuaType

--- MIDI Library
-- Polls MIDI event information from MIDI devices.
-- Requires a custom binary -> https://github.com/FPtje/gmcl_midi/releases/latest
-- GNU/Linux and MacOS users will have to compile their own binaries.
-- Instructions here -> https://github.com/FPtje/gmcl_midi/blob/master/Compiling.md
-- @name midi
-- @class library
-- @libtbl midi_library
SF.RegisterLibrary("midi")

return function(instance)
-- Only usable by the owner of the Starfall chip
if LocalPlayer() ~= instance.player then return end

local midi_library = instance.Libraries.midi

-- Close all ports when SF chip is deleted
-- Ensures that the MIDI port can still be used in other applications after the SF chip is deleted
instance:AddHook("deinitialize", function()
	midi_library.closeAllPorts()
end)

--- Event hook for MIDI devices.
-- Everytime a MIDI device outputs a signal, the callback function on the hook is called.
-- Read up on the MIDI protocol to make better sense of everything -> https://ccrma.stanford.edu/~craig/articles/linuxmidi/misc/essenmidi.html
-- Commands and their parameters:
-- 0x80 NOTE_OFF              : param1 = key;                         param2 = velocity
-- 0x90 NOTE_ON               : param1 = key;                         param2 = velocity
-- 0xA0 AFTERTOUCH            : param1 = key;                         param2 = touch
-- 0xB0 CONTINUOUS_CONTROLLER : param1 = button_number;               param2 = button_value
-- 0xC0 PATCH_CHANGE          : param1 = patch number;
-- 0xD0 CHANNEL_PRESSURE      : param1 = pressure;
-- 0xE0 PITCH_BEND            : param1 = lsb(least signifigant bit);  param2 = msb(most signifigant bit)
-- @name MIDI
-- @class hook
-- @client
-- @libtbl midi_library
-- @param number time The exact systime at which the event occurred
-- @param number command The command code of the event. First 4 bits are the command code and last 4 are the channel
-- @param number param1 Each command has their own set of parameters, see above
-- @param number param2 Each command has their own set of parameters, see above
SF.hookAdd("MIDI", "midi")

--- Opens the MIDI port to make it available to grab events from.
-- This must be called before the hook.
-- @param number? port The MIDI port to open (default: 0)
-- @return string The name of the MIDI device opened at the given port
function midi_library.openPort(port)
	if port then checkluatype(port, TYPE_NUMBER) else port = 0 end
	if midi_library.isPortOpen(port) then
		SF.Throw("This port is already open!")
	end
	return midi.Open(port)
end

--- Checks if the specified MIDI port is currently opened.
-- @param number port The port number
-- @return boolean True if the port is open
function midi_library.isPortOpen(port)
	checkluatype(port, TYPE_NUMBER)
	return midi.IsOpened(port)
end

--- Closes all MIDI ports.
function midi_library.closeAllPorts()
	for k, v in pairs(midi_library.getPorts()) do
		if not midi_library.isPortOpen(k) then continue end
		midi_library.closePort(k)
	end
end

--- Gets a table of all MIDI devices' ports.
-- @name midi_library.getPorts
-- @class function
-- @return table The table of MIDI ports (index starts at 0)
midi_library.getPorts = midi.GetPorts

--- Closes the specified MIDI port.
-- @name midi_library.closePort
-- @class function
-- @param number port The MIDI port to close.
-- @return string The name of the MIDI device closed at the given port
midi_library.closePort = midi.Close

--- Grabs the MIDI command code from the command.
-- @name midi_library.getCode
-- @class function
-- @param number command The command number
-- @return number The command code
midi_library.getCode = midi.GetCommandCode

--- Grabs the MIDI channel from the command.
-- @name midi_library.getChannel
-- @class function
-- @param number command The command number
-- @return number The MIDI channel
midi_library.getChannel = midi.GetCommandChannel

--- Grabs the command code in a readable name.
-- @name midi_library.getName
-- @class function
-- @param number command The command number
-- @return string The command name
midi_library.getName = midi.GetCommandName

end
