local CUSERCMD_META = FindMetaTable("CUserCmd")
local CMOVEDATA_META = FindMetaTable("CMoveData")

--- CUserCmd type
-- @name CUserCmd
-- @class type
-- @libtbl usercmd_methods
-- @libtbl usercmd_meta
SF.RegisterType("CUserCmd", true, true, CUSERCMD_META)

--- CMoveData type
-- @name CMoveData
-- @class type
-- @libtbl movedata_methods
-- @libtbl movedata_meta
SF.RegisterType("CMoveData", true, true, CMOVEDATA_META)

return function(instance)
    local usercmd_methods, usercmd_meta, cwrap, cunwrap = instance.Types.CUserCmd.Methods, instance.Types.CUserCmd, instance.Types.CUserCmd.Wrap, instance.Types.CUserCmd.Unwrap
    local awrap, aunwrap = instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
    local vwrap, vunwrap = instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap

    usercmd_meta.__tostring = function(self)
        return "CUserCmd [" .. cunwrap(self):CommandNumber() .. "]"
    end

    --- Returns an increasing number representing the index of the user cmd.
    -- @return number The command number
    function usercmd_methods:getCommandNumber()
        return cunwrap(self):CommandNumber()
    end

    --- Returns a bitflag indicating which buttons are pressed.
    -- @return number The button bitflag
    function usercmd_methods:getButtons()
        return cunwrap(self):GetButtons()
    end

    --- The speed the client wishes to move forward with, negative if the clients wants to move backwards.
    -- @return number The forward move speed
    function usercmd_methods:getForwardMove()
        return cunwrap(self):GetForwardMove()
    end

    --- Gets the current impulse from the client, usually 0. See impulses list https://developer.valvesoftware.com/wiki/Impulse and some GMod specific impulses https://gmodwiki.com/CUserCmd:GetImpulse
    -- @return number The impulse
    function usercmd_methods:getImpulse()
        return cunwrap(self):GetImpulse()
    end

    --- Returns the scroll delta as whole number.
    -- @return number The scroll delta
    function usercmd_methods:getMouseWheel()
        return cunwrap(self):GetMouseWheel()
    end

    --- Returns the delta of the angular horizontal mouse movement of the player.
    -- @return number The mouse X delta
    function usercmd_methods:getMouseX()
        return cunwrap(self):GetMouseX()
    end

    --- Returns the delta of the angular vertical mouse movement of the player.
    -- @return number The mouse Y delta
    function usercmd_methods:getMouseY()
        return cunwrap(self):GetMouseY()
    end

    --- The speed the client wishes to move sideways with, positive if it wants to move right, negative if it wants to move left.
    -- @return number The side move speed
    function usercmd_methods:getSideMove()
        return cunwrap(self):GetSideMove()
    end

    --- The speed the client wishes to move up with, negative if the clients wants to move down.
    -- @return number The up move speed
    function usercmd_methods:getUpMove()
        return cunwrap(self):GetUpMove()
    end

    --- Gets the direction the player is looking in.
    -- @return Angle The view angles
    function usercmd_methods:getViewAngles()
        return awrap(cunwrap(self):GetViewAngles())
    end

    --- When players are not sending usercommands to the server (often due to lag), their last usercommand will be executed multiple times as a backup. This function returns true if that is happening. This will never return true on the client.
    -- @return boolean true if the usercmd is faked, false if not
    function usercmd_methods:isForced()
        return cunwrap(self):IsForced()
    end

    --- Returns true if the specified button(s) is pressed.
    -- @param number buttons The button(s) to check, see https://wiki.facepunch.com/gmod/Enums/IN for the button enums
    -- @return boolean true if the button(s) is pressed, false if not
    function usercmd_methods:keyDown(buttons)
        checkluatype(buttons, TYPE_NUMBER)
        return cunwrap(self):KeyDown(buttons)
    end

    --- Returns tick count since joining the server.
    -- @return number The amount of ticks passed since joining the server.
    function usercmd_methods:getTickCount()
        return cunwrap(self):TickCount()
    end

    local movedata_methods, movedata_meta, mwrap, munwrap = instance.Types.CMoveData.Methods, instance.Types.CMoveData, instance.Types.CMoveData.Wrap, instance.Types.CMoveData.Unwrap
    movedata_meta.__tostring = function(self)
        return "CMoveData"
    end

    --- Gets the aim angle. On client is the same as Entity:getAngles.
    -- @return Angle The aim angle
    function movedata_methods:getAimAngle()
        return awrap(munwrap(self):GetAngles())
    end

    --- Gets which buttons are down
    -- @return number The button bitflag
    function movedata_methods:getButtons()
        return munwrap(self):GetButtons()
    end

    --- Returns the players forward speed.
    -- @return number The forward speed
    function movedata_methods:getForwardSpeed()
        return munwrap(self):GetForwardSpeed()
    end

    --- Gets the number passed to "impulse" console command
    -- @return number The impulse
    function movedata_methods:getImpulse()
        return munwrap(self):GetImpulse()
    end

    -- Returns the maximum client speed of the player
    -- @return number The max speed
    function movedata_methods:getMaxClientSpeed()
        return munwrap(self):GetMaxClientSpeed()
    end

    --- Returns the maximum speed of the player.
    -- @return number The max speed
    function movedata_methods:getMaxSpeed()
        return munwrap(self):GetMaxSpeed()
    end

    --- Get which buttons were down last frame
    -- @return number The button bitflag
    function movedata_methods:getOldButtons()
        return munwrap(self):GetOldButtons()
    end

    --- Gets the player's position.
    -- @return Vector The player's position
    function movedata_methods:getOrigin()
        return vwrap(munwrap(self):GetOrigin())
    end

    --- Returns the strafe speed of the player.
    -- @return number The strafe speed
    function movedata_methods:getSideSpeed()
        return munwrap(self):GetSideSpeed()
    end

    --- Returns the vertical speed of the player. ( Z axis of CMoveData:getVelocity )
    -- @return number The vertical speed
    function movedata_methods:getUpSpeed()
        return munwrap(self):GetUpSpeed()
    end

    --- Gets the players velocity.
    -- @return Vector The player's velocity
    function movedata_methods:getVelocity()
        return vwrap(munwrap(self):GetVelocity())
    end

    --- Returns whether the key is down or not
    -- @param number buttons The button(s) to check, see https://wiki.facepunch.com/gmod/Enums/IN for the button enums
    -- @return boolean true if the button(s) is down, false if not
    function movedata_methods:keyDown(buttons)
        checkluatype(buttons, TYPE_NUMBER)
        return munwrap(self):KeyDown(buttons)
    end

    --- Returns whether the key was pressed. If you want to check if the key is held down, try CMoveData:keyDown instead.
    -- @param number buttons The button(s) to check, see https://wiki.facepunch.com/gmod/Enums/IN for the button enums
    -- @return boolean true if the button(s) was pressed, false if not
    function movedata_methods:keyPressed(buttons)
        checkluatype(buttons, TYPE_NUMBER)
        return munwrap(self):KeyPressed(buttons)
    end

    --- Returns whether the key was released
    -- @param number buttons The button(s) to check, see https://wiki.facepunch.com/gmod/Enums/IN for the button enums
    -- @return boolean true if the button(s) was released, false if not
    function movedata_methods:keyReleased(buttons)
        checkluatype(buttons, TYPE_NUMBER)
        return munwrap(self):KeyReleased(buttons)
    end

    --- Returns whether the key was down or not. Unlike CMoveData:keyDown, it will return false if CMoveData:keyPressed is true and it will return true if CMoveData:keyReleased is true.
    -- @param number buttons The button(s) to check, see https://wiki.facepunch.com/gmod/Enums/IN for the button enums
    -- @return boolean true if the button(s) is down, false if not
    function movedata_methods:keyDownLast(buttons)
        checkluatype(buttons, TYPE_NUMBER)
        return munwrap(self):KeyDownLast(buttons)
    end
end
