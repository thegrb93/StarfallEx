if not SF.Require("midi") then return function() end end

local checkluatype = SF.CheckLuaType

-- Midi Library
-- Polls midi event information from midi devices.
-- @name midi
-- @class library
-- @libtbl midi_library
SF.RegisterLibrary("midi")

return function(instance)
-- Only usable by the owner of the starfall chip
if LocalPlayer() ~= instance.player then return end

local midi_library = instance.Libraries.midi

-- Event hook for midi devices.  Everytime a midi device outputs a signal, the callback function on the hook is called.
-- @class hook
-- @client
-- @libtbl midi_library
-- @param number time the exact systime which the event occured
-- @param number command the command code of the event.  First 4 bits are the command code and last 4 are the channel
-- @param ...number parameters Each command has their own set of parameters, see below
-- Commands and their parameters:
-- 0x80 "NOTE_OFF"              : param1 = key                         param2 = velocity
-- 0x90 "NOTE_ON"               : param1 = key                         param2 = velocity
-- 0xA0 "AFTERTOUCH"            : param1 = key                         param2 = touch
-- 0xB0 "CONTINUOUS_CONTROLLER" : param1 = button_number               param2 = button_value
-- 0xC0 "PATCH_CHANGE"          : param1 = patch number
-- 0xD0 "CHANNEL_PRESSURE"      : param1 = pressure
-- 0xE0 "PITCH_BEND"            : param1 = lsb(least signifigant bit)  param2 = msb(most signifigant bit)
SF.hookAdd("MIDI", "midi")

-- Opens the midi port to make it available to grab events from.  This must be called before the hook.
-- @param number port the midi port to open. Passing nothing defaults to 0.
-- @return string the name of the midi device opened at the given port.
function midi_library.openPort(port)
    checkluatype(port, TYPE_NUMBER)
    if midi_library.isPortOpen(port) then
        midi_library.closePort(port)
    end
    return midi.Open(port)
end

-- Checks if the midi port is currently opened.
-- @return boolean if the port is open
function midi_library.isPortOpen(port)
    checkluatype(port, TYPE_NUMBER)
    return midi.IsOpened(port)
end

-- Closes the midi port. Checks if they are open to prevent binary library failure.
-- @param number port the midi port to close.
-- @return string the name of the midi device closed at the given port.
function midi_library.closePort(port)
    if not midi_library.isPortOpen(port) then return end
    return midi.Close(port)
end

-- Closes all midi ports.
function midi_library.closeAllPorts()
    for k, v in pairs(midi_library.getPorts()) do
        midi_library.closePort(k)
    end
end

-- Gets a table of all midi devices' ports.
-- @return table the table of midi ports.  Starts at index 0
midi_library.getPorts = midi.GetPorts

-- Grabs the current midi command code from the command. Essentially does: bit.band(command, 0xF0)
-- @return number the command code
midi_library.getCommandCode = midi.GetCommandCode

-- Grabs the current midi channel from the command. Essentially does: bit.rshift(command, 8)
-- @return number the midi channel
midi_library.getCommandChannel = midi.GetCommandChannel

-- Grabs the command code in a readable name.
-- @return string command name
midi_library.getCommandName = midi.GetCommandName

end