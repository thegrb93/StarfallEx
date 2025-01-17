if not SF.Require("midi") then return function() end end

local checkluatype = SF.CheckLuaType

--- Midi Library
-- Polls midi event information from midi devices.
-- Requires a custom binary -> https://github.com/FPtje/gmcl_midi/releases/tag/v0.2.0
-- GNU/Linux and MacOS users will have to compile their own binaries.
-- Instructions here -> https://github.com/FPtje/gmcl_midi/blob/master/Compiling.md
-- @name midi
-- @class library
-- @libtbl midi_library
SF.RegisterLibrary("midi")

return function(instance)
-- Only usable by the owner of the starfall chip
if LocalPlayer() ~= instance.player then return end

local midi_library = instance.Libraries.midi

-- Close all ports when SF chip is deleted
-- Ensures that the midi port can still be used in other applications after the SF chip is deleted
instance:AddHook("deinitialize", function()
	midi_library.closeAllPorts()
end)

--- Event hook for midi devices.  
-- Everytime a midi device outputs a signal, the callback function on the hook is called.
-- Read up on the MIDI protocol to make better sense of everything -> https://ccrma.stanford.edu/~craig/articles/linuxmidi/misc/essenmidi.html
-- @name MIDI
-- @class hook
-- @client
-- @libtbl midi_library
-- @param number time the exact systime which the event occured
-- @param number command the command code of the event.  First 4 bits are the command code and last 4 are the channel
-- @param number param1 Each command has their own set of parameters, see above
-- @param number param2 Each command has their own set of parameters, see above
-- Commands and their parameters:
-- 0x80 NOTE_OFF              : param1 = key;                         param2 = velocity
-- 0x90 NOTE_ON               : param1 = key;                         param2 = velocity
-- 0xA0 AFTERTOUCH            : param1 = key;                         param2 = touch
-- 0xB0 CONTINUOUS_CONTROLLER : param1 = button_number;               param2 = button_value
-- 0xC0 PATCH_CHANGE          : param1 = patch number;
-- 0xD0 CHANNEL_PRESSURE      : param1 = pressure;
-- 0xE0 PITCH_BEND            : param1 = lsb(least signifigant bit);  param2 = msb(most signifigant bit)
SF.hookAdd("MIDI", "midi")

--- Opens the midi port to make it available to grab events from.  This must be called before the hook.
-- @param number port the midi port to open. Passing nothing defaults to 0.
-- @return string the name of the midi device opened at the given port.
function midi_library.openPort(port)
	checkluatype(port, TYPE_NUMBER)
	if midi_library.isPortOpen(port) then 
		SF.Throw("This port is already open!")
	end
	return midi.Open(port)
end

--- Checks if the specified midi port is currently opened.
-- @return boolean if the port is open
function midi_library.isPortOpen(port)
	checkluatype(port, TYPE_NUMBER)
	return midi.IsOpened(port)
end

--- Closes all midi ports.
function midi_library.closeAllPorts()
	for k, v in pairs(midi_library.getPorts()) do
		if not midi_library.isPortOpen(k) then continue end
		midi_library.closePort(k)
	end
end

--- Gets a table of all midi devices' ports.
-- @name midi_library.getPorts
-- @class function
-- @return table the table of midi ports.  Starts at index 0
midi_library.getPorts = midi.GetPorts

--- Closes the specified midi port.
-- @name midi_library.closePort
-- @class function
-- @param number port the midi port to close.
-- @return string the name of the midi device closed at the given port.
midi_library.closePort = midi.Close

--- Grabs the midi command code from the command.
-- @name midi_library.getCode
-- @class function
-- @param number command the command
-- @return number the command code
midi_library.getCode = midi.GetCommandCode

--- Grabs the midi channel from the command.
-- @name midi_library.getChannel
-- @class function
-- @param number command the command
-- @return number the midi channel
midi_library.getChannel = midi.GetCommandChannel

--- Grabs the command code in a readable name.
-- @name midi_library.getName
-- @class function
-- @param number command the command
-- @return string command name
midi_library.getName = midi.GetCommandName

end