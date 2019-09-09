-------------------------------------------------------------------------------
-- Notification functions
-------------------------------------------------------------------------------

--- Notification functions. Allows the user to display hints on the bottom right of their screen
-- @client
local notification_library = SF.RegisterLibrary("notification")
SF.AddHook("postload", function()
	-- @name SF.DefaultEnvironment.NOTIFY
	-- @class table
	SF.DefaultEnvironment.NOTIFY = {
		["GENERIC"] = NOTIFY_GENERIC,
		["ERROR"] = NOTIFY_ERROR,
		["UNDO"] = NOTIFY_UNDO,
		["HINT"] = NOTIFY_HINT,
    	["CLEANUP"] = NOTIFY_CLEANUP,
    }
end)

--- Displays a standard notification.
-- @param text The text to display
-- @param type Determines the notification method.
---NOTIFY.GENERIC
---NOTIFY.ERROR
---NOTIFY.UNDO
---NOTIFY.HINT
---NOTIFY.CLEANUP
-- @param length Time in seconds to display the notification
function notification_library.addLegacy(text, type, length)
	notification.AddLegacy( text, type, length )
end

--- Displays a notification with an animated progress bar, will persist unless killed.
-- @param id Index of the notification
-- @param text The text to display
function notification_library.addProgress(id, text)
	notification.AddProgress( id, text )
end

--- Removes the notification with the given index after 0.8 seconds
-- @param id Index of the notification to kill
function notification_library.kill(id)
	notification.Kill( id )
end
