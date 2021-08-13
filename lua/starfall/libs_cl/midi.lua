if not SF.Require("midi") then return function() end end

--Midi Library
-- @name midi
-- @class library
-- @libtbl midi_library
SF.RegisterLibrary("midi")

return function(instance)
-- Only usable by the owner of the starfal chip
if LocalPlayer() ~= instance.player then return end

local midi_library = instance.Libraries.midi

-- Event hook for midi
-- @class hook
-- @client
-- @lib_tbl midi_library
-- @param number time the exact systime which the event occured
-- @param number command the command code of the event.  First 4 bits are the command code and last 4 are the channel
-- @param varargs the different parameters of the midi event.  Can have 1 or more.
SF.hookAdd("MIDI", "midi")

-- Gets a table of all midi devices' ports.
-- @return table table of all midi ports.
function midi_library.getPorts()
    return midi.GetPorts()
end

-- Opens the midi port to make it available to grab events from.  This must be called before the hook.
-- @param number portNumber the midi port to open.
-- @return string the name of the midi device opened at the given port.
function midi_library.openPort(portNumber)
    local portNumber = portNumber or 0
    if midi.IsOpened(portNumber) then
        midi.Close(portNumber)
    end
    return midi.Open(portNumber)
end

-- Checks if the midi port is currently opened.
-- @return boolean if the port is open
function midi_library.isPortOpened(portNumber)
    return midi.IsOpened(portNumber)
end

-- Closes the midi port
-- @param number portNumber the midi port to close.
-- @return string the name of the midi device closed at the given port.
function midi_library.closePort(portNumber)
    return midi.Close(portNumber)
end

-- Closes all midi ports.  Only closes them if they are open.
function midi_library.closeAllPorts()
    local midiPorts = midi.GetPorts()
    for k, v in pairs(midiPorts) do
        if midi.IsOpened(k) then
            midi.Close(k)
        end
    end
end

-- Grabs the current midi command code from the command. Essentially does: bit.band(command, 0xF0)
-- @return number the command code
function midi_library.getCommandCode(command)
    return midi.GetCommandCode(command)
end

-- Grabs the current midi channel from the command. Essentially does: bit.band(command, 0x0F)
-- @return number the midi channel
function midi_library.getCommandChannel(command)
    return midi.GetCommandChannel(command)
end

-- Grabs the command code in a readable name.
-- @return string command name
function midi_library.getCommandName(command)
    return midi.GetCommandName(command)
end

end