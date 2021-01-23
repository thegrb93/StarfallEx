local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege

-- Register Priveleges
registerprivilege("notification", "Create notifications", "Allows the user to create notifications on their screen", { client = { default = 1 } })
registerprivilege("notification.hud", "Create notifications with HUD connected", "Allows a user to create notifications on the player's screen if connected to a HUD", { client = {} })


--- Notification library. Allows the user to display hints on the bottom right of their screen
-- @name notification
-- @class library
-- @libtbl notification_library
SF.RegisterLibrary("notification")

return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end


instance:AddHook("initialize", function()
	instance.data.notifications = {}
end)

instance:AddHook("deinitialize", function()
	for n, _ in pairs(instance.data.notifications) do
		notification.Kill( n )
	end
end)


local notification_library = instance.Libraries.notification

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
	if instance.entity:IsHUDActive() then
		checkpermission(instance, nil, "notification.hud")
	else
		checkpermission(instance, nil, "notification")
	end
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
	if instance.entity:IsHUDActive() then
		checkpermission(instance, nil, "notification.hud")
	else
		checkpermission(instance, nil, "notification")
	end
	checkluatype(id, TYPE_STRING)
	checkluatype(text, TYPE_STRING)

	if #id > 256 then SF.Throw("ID is greater than 256 limit!", 2) end
	if #text > 256 then SF.Throw("Text is greater than 256 limit!", 2) end

	--Keep the ID unique to each player
	if instance.player == SF.Superuser then
		id = "SF:Superuser"..id
	elseif instance.player:IsValid() then
		id = "SF:"..instance.player:SteamID64()..id
	else
		SF.Throw("Invalid chip owner", 2)
	end

	notification.AddProgress( id, text )
	instance.data.notifications[id] = true
end

--- Removes the notification with the given index after 0.8 seconds
-- @param id String index of the notification to kill
function notification_library.kill(id)
	if instance.entity:IsHUDActive() then
		checkpermission(instance, nil, "notification.hud")
	else
		checkpermission(instance, nil, "notification")
	end
	checkluatype(id, TYPE_STRING)

	id = "SF:"..instance.player:SteamID64()..id

	if instance.data.notifications[id] then
		notification.Kill( id )
		instance.data.notifications[id] = nil
	end
end

end
