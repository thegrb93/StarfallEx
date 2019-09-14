-------------------------------------------------------------------------------
-- Notification functions
-------------------------------------------------------------------------------

-- Register Priveleges
SF.Permissions.registerPrivilege("notification", "Create notifications", "Allows the user to create notifications on their screen", { client = { default = 1 } })

local checktype = SF.CheckType
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check

--- Notification library. Allows the user to display hints on the bottom right of their screen
-- @client
local notification_library = SF.RegisterLibrary("notification")

SF.AddHook("initialize", function(instance)
	instance.data.notifications = {}
end)

SF.AddHook("deinitialize", function(instance)
	for n, _ in pairs(instance.data.notifications) do
		notification.Kill( n )
	end
end)

SF.AddHook("postload", function()
	-- @name SF.DefaultEnvironment.NOTIFY
	-- @class table
	SF.DefaultEnvironment.NOTIFY = {
		["GENERIC"] = NOTIFY_GENERIC,
		["ERROR"] = NOTIFY_ERROR,
		["UNDO"] = NOTIFY_UNDO,
		["HINT"] = NOTIFY_HINT,
		["CLEANUP"] = NOTIFY_CLEANUP
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
-- @param length Time in seconds to display the notification (Max length of 30)
function notification_library.addLegacy(text, type, length)
	checkpermission(SF.instance, nil, "notification")
	checkluatype(text, TYPE_STRING)
	checkluatype(type, TYPE_NUMBER)
	checkluatype(length, TYPE_NUMBER)
	length = math.Clamp(length,1,30)
	notification.AddLegacy( text, type, length )
end


--- Displays a notification with an animated progress bar, will persist unless killed or chip is removed.
-- @param id String index of the notification
-- @param text The text to display
function notification_library.addProgress(id, text)
	checkpermission(SF.instance, nil, "notification")
	checkluatype(id, TYPE_STRING)
	checkluatype(text, TYPE_STRING)
	local instance = SF.instance

	if #id > 256 then SF.Throw("ID is greater than 256 limit!", 2) end
	if #text > 256 then SF.Throw("Text is greater than 256 limit!", 2) end

	--Keep the ID unique to each player
	id = "SF:"..instance.player:SteamID64()..id

	notification.AddProgress( id, text )
	instance.data.notifications[id] = true
end

--- Removes the notification with the given index after 0.8 seconds
-- @param id String index of the notification to kill
function notification_library.kill(id)
	checkpermission(SF.instance, nil, "notification")
	checkluatype(id, TYPE_STRING)
	local instance = SF.instance

	id = "SF:"..instance.player:SteamID64()..id

	if instance.data.notifications[id] then
		notification.Kill( id )
		instance.data.notifications[id] = nil
	end
end
