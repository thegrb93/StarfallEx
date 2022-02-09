local checkluatype = SF.CheckLuaType
local checkpattern = SF.CheckPattern
local registerprivilege = SF.Permissions.registerPrivilege
local checksafety = SF.CheckSafety
local assertsafety = SF.AssertSafety

if SERVER then
	registerprivilege("darkrp.moneyPrinterHooks", "Get own money printer info", "Allows the user to know when their own money printers catch fire or print money (and how much was printed)")
	registerprivilege("darkrp.playerWalletChanged", "Be notified of wallet changes", "Allows the user to know when their own wallet changes")
	registerprivilege("darkrp.lockdownHooks", "Know when lockdowns begin and end", "Allows the user to know when a lockdown begins or ends")
	registerprivilege("darkrp.lawHooks", "Know when laws change", "Allows the user to know when a law is added or removed, and when the laws are reset")
	registerprivilege("darkrp.lockpickHooks", "Know when they start picking a lock", "Allows the user to know when they start picking a lock")
end

if SERVER then
	--- Called when a money printer is about to catch fire. DarkRP only. Called between moneyPrinterPrintMoney and moneyPrinterPrinted.
	-- Only works if the owner of the chip also owns the money printer, or if the chip is running in superuser mode.
	-- @name moneyPrinterCatchFire
	-- @class hook
	-- @server
	-- @param Entity moneyprinter The money printer that is about to catch fire
	SF.hookAdd("moneyPrinterCatchFire", nil, function(instance, moneyprinter)
		if not moneyprinter then return false end
		if instance.player ~= SF.Superuser then
			if not moneyprinter.Getowning_ent or instance.player ~= moneyprinter:Getowning_ent() then return false end
			if not SF.Permissions.checkSafe(instance, nil, "darkrp.moneyPrinterHooks") then return false end
		end
		return true, {instance.Types.Entity.Wrap(moneyprinter)}
	end)

	--- Called after a money printer is has printed money. DarkRP only.
	-- Only works if the owner of the chip also owns the money printer, or if the chip is running in superuser mode.
	-- @name moneyPrinterPrinted
	-- @class hook
	-- @server
	-- @param Entity moneyprinter The money printer
	-- @param Entity moneybag The moneybag produed by the printer.
	SF.hookAdd("moneyPrinterPrinted", nil, function(instance, moneyprinter, moneybag)
		if not moneyprinter then return false end
		if instance.player ~= SF.Superuser then
			if not moneyprinter.Getowning_ent or instance.player ~= moneyprinter:Getowning_ent() then return false end
			if not SF.Permissions.checkSafe(instance, nil, "darkrp.moneyPrinterHooks") then return false end
		end
		return true, {instance.Types.Entity.Wrap(moneyprinter), instance.Types.Entity.Wrap(moneybag)}
	end)

	--- Called when a money printer is about to print money. DarkRP only.
	-- You should use moneyPrinterPrinted instead, as the printer is not guaranteed to print money even if this hook is called.
	-- Only works if the owner of the chip also owns the money printer, or if the chip is running in superuser mode.
	-- @name moneyPrinterPrintMoney
	-- @class hook
	-- @server
	-- @param Entity moneyprinter The money printer
	-- @param number amount The amount to be printed
	SF.hookAdd("moneyPrinterPrintMoney", nil, function(instance, moneyprinter, amount)
		if not checksafety(amount) then return false end
		if not moneyprinter then return false end
		if instance.player ~= SF.Superuser then
			if not moneyprinter.Getowning_ent or instance.player ~= moneyprinter:Getowning_ent() then return false end
			if not SF.Permissions.checkSafe(instance, nil, "darkrp.moneyPrinterHooks") then return false end
		end
		return true, {instance.Types.Entity.Wrap(moneyprinter), amount}
	end)
	
	--- Called when a player receives money. DarkRP only.
	-- Will only be called if the recipient is the owner of the chip, or if the chip is running in superuser mode.
	-- @name playerWalletChanged
	-- @class hook
	-- @server
	-- @param Player ply The player who is getting money.
	-- @param number amount The amount of money given to the player.
	-- @param number wallet How much money the player had before receiving the money.
	SF.hookAdd("playerWalletChanged", nil, function(instance, ply, amount, wallet)
		if not checksafety(amount, wallet) then return false end
		if instance.player ~= SF.Superuser then
			if not SF.Permissions.checkSafe(instance, nil, "darkrp.playerWalletChanged") then return false end
			if instance.player ~= ply then return false end
		end
		return true, {ply and instance.Types.Player.Wrap(ply) or nil, amount, wallet}
	end)
	
	--- Called when a lockdown has ended. DarkRP only.
	-- @name lockdownEnded
	-- @class hook
	-- @server
	-- @param Player? actor The player who ended the lockdown, or nil.
	SF.hookAdd("lockdownEnded", nil, function(instance, actor)
		if instance.player ~= SF.Superuser and not SF.Permissions.checkSafe(instance, nil, "darkrp.lockdownHooks") then return false end
		return true, {actor and instance.Types.Player.Wrap(actor) or nil}
	end)

	--- Called when a lockdown has started. DarkRP only.
	-- @name lockdownStarted
	-- @class hook
	-- @server
	-- @param Player? actor The player who started the lockdown, or nil.
	SF.hookAdd("lockdownStarted", nil, function(instance, actor)
		if instance.player ~= SF.Superuser and not SF.Permissions.checkSafe(instance, nil, "darkrp.lockdownHooks") then return false end
		return true, {actor and instance.Types.Player.Wrap(actor) or nil}
	end)

	--- Called when a law is added. DarkRP only.
	-- @name addLaw
	-- @class hook
	-- @param number index Index of the law
	-- @param string law Law string
	-- @param Player? player The player who added the law.
	SF.hookAdd("addLaw", nil, function(instance, index, law, player)
		if not checksafety(index, law) then return false end
		if instance.player ~= SF.Superuser and not SF.Permissions.checkSafe(instance, nil, "darkrp.lawHooks") then return false end
		return true, {index, law, player and instance.Types.Player.Wrap(player) or nil}
	end)

	--- Called when a law is removed. DarkRP only.
	-- @name addLaw
	-- @class hook
	-- @server
	-- @param number index Index of the law
	-- @param string law Law string
	-- @param Player? player The player who removed the law.
	SF.hookAdd("removeLaw", nil, function(instance, index, law, player)
		if not checksafety(index, law) then return false end
		if instance.player ~= SF.Superuser and not SF.Permissions.checkSafe(instance, nil, "darkrp.lawHooks") then return false end
		return true, {index, law, player and instance.Types.Player.Wrap(player) or nil}
	end)

	--- Called when laws are reset. DarkRP only. This is the only hook called when /resetlaws is used.
	-- @name addLaw
	-- @class hook
	-- @server
	-- @param Player? player The player resetting the laws.
	SF.hookAdd("resetLaws", nil, function(instance, player)
		if instance.player ~= SF.Superuser and not SF.Permissions.checkSafe(instance, nil, "darkrp.lawHooks") then return false end
		return true, {player and instance.Types.Player.Wrap(player) or nil}
	end)

	--- Called when a player is about to pick a lock. DarkRP only.
	-- Will only be called if the lockpicker is the owner of the chip, or if the chip is running in superuser mode.
	-- @name lockpickStarted
	-- @class hook
	-- @server
	-- @param Player ply The player that is about to pick a lock.
	-- @param Entity ent The entity being lockpicked.
	-- @param table trace The trace result.
	SF.hookAdd("lockpickStarted", nil, function(instance, ply, ent, trace)
		if instance.player ~= SF.Superuser then
			if not SF.Permissions.checkSafe(instance, nil, "darkrp.lockpickHooks") then return false end
			if instance.player ~= ply then return false end
		end
		return true, {
			ply and instance.Types.Player.Wrap(ply) or nil,
			ent and instance.Types.Entity.Wrap(ent) or nil,
			trace and SF.StructWrapper(instance, trace, "TraceResult") or nil
		}
	end)

	--- Called when a player has finished picking a lock, successfully or otherwise. DarkRP only.
	-- Will only be called if the lockpicker is the owner of the chip, or if the chip is running in superuser mode.
	-- @name onLockpickCompleted
	-- @class hook
	-- @server
	-- @param Player ply The player attempting to lockpick the entity.
	-- @param boolean success Whether the player succeeded in lockpicking the entity.
	-- @param Entity ent The entity that was lockpicked.
	SF.hookAdd("onLockpickCompleted", nil, function(instance, ply, success, ent)
		if not checksafety(success) then return false end
		if instance.player ~= SF.Superuser then
			if not SF.Permissions.checkSafe(instance, nil, "darkrp.lockpickHooks") then return false end
			if instance.player ~= ply then return false end
		end
		return true, {
			ply and instance.Types.Player.Wrap(ply) or nil,
			success,
			ent and instance.Types.Entity.Wrap(ent) or nil
		}
	end)
end

--- Functions relating to DarkRP.
-- @name darkrp
-- @class library
-- @libtbl darkrp_library
SF.RegisterLibrary("darkrp")

return function(instance)

if not DarkRP then return end

local darkrp_library = instance.Libraries.darkrp
local ply_meta = instance.Types.Player
local plywrap, plyunwrap = ply_meta.Wrap, ply_meta.Unwrap
local ent_meta = instance.Types.Entity
local ewrap, eunwrap = ent_meta.Wrap, ent_meta.Unwrap
local function getply(self)
	local ent = plyunwrap(self)
	if ent:IsValid() then
		return ent
	else
		SF.Throw("Entity is not valid.", 3)
	end
end
local checkpermission = instance.player == SF.Superuser and function() end or SF.Permissions.check

--- Format a number as a money value. Includes currency symbol.
-- @param number amount The money to format, e.g. 100000.
-- @return string The money as a nice string, e.g. "$100,000".
function darkrp_library.formatMoney(n)
	checkluatype(n, TYPE_NUMBER)
	return assertsafety(DarkRP.formatMoney(n))
end

--- Get the available vehicles that DarkRP supports.
-- @return table Names, models and classnames of all supported vehicles.
function darkrp_library.getAvailableVehicles()
	return instance.Sanitize(DarkRP.getAvailableVehicles())
end

--- Get all categories for all F4 menu tabs, including all jobs and every entity available for purchase.
-- @return table All categories.
function darkrp_library.getCategories()
	return instance.Sanitize(DarkRP.getCategories())
end

--- Get all food items.
-- @return table? Table with food items, or nil if there are none.
function darkrp_library.getFoodItems()
	local tbl = DarkRP.getFoodItems()
	return tbl and instance.Sanitize(tbl) or nil
end

--- Get the table of all current laws.
-- @return table A table of all current laws.
function darkrp_library.getLaws()
	return instance.Sanitize(DarkRP.getLaws())
end

--- Get a list of possible shipments. DarkRP only.
-- @return table? A table with the contents of the GLua global "CustomShipments", or nil if it doesn't exist.
function darkrp_library.getCustomShipments()
	return CustomShipments and instance.Sanitize(CustomShipments) or nil
end

if SERVER then
	--- Get the entity corresponding to a door index. Note: The door MUST have been created by the map!
	-- @server
	-- @param number doorIndex The door index
	-- @return Entity? The door entity, or nil if the index is invalid or the door was removed.
	function darkrp_library.doorIndexToEnt(doorIndex)
		checkluatype(doorIndex, TYPE_NUMBER)
		local entIndex = DarkRP.doorToEntIndex(doorIndex)
		if entIndex and entIndex ~= 0 then
			return ewrap(Entity(entIndex))
		end
	end
	
	--- Get the number of jail positions in the current map.
	-- @server
	-- @return number The number of jail positions in the current map.
	function darkrp_library.jailPosCount()
		return assertsafety(DarkRP.jailPosCount())
	end
	
	--- Make one player give money to the other player.
	-- Only works if the sender is the owner of the chip, or if the chip is running in superuser mode.
	-- @server
	-- @param Player sender The player who gives the money.
	-- @param Player receiver The player who receives the money.
	-- @param number amount The amount of money.
	function darkrp_library.payPlayer(sender, receiver, amount)
		checkluatype(amount, TYPE_NUMBER)
		sender = getply(sender)
		if instance.player ~= SF.Superuser and instance.player ~= sender then SF.Throw("may not transfer money from player other than owner", 2) return end
		DarkRP.payPlayer(sender, getply(receiver), amount)
	end
else
	--- Open the F1 help menu. Roughly equivalent to pressing F1 (or running gm_showhelp), but won't close it if it's already open.
	-- Only works if the local player is the owner of the chip, or if the chip is running in superuser mode.
	-- @client
	function darkrp_library.openF1Menu()
		if instance.player ~= SF.Superuser and instance.player ~= LocalPlayer() then SF.Throw("may not use this function on anyone other than owner", 2) return end
		DarkRP.openF1Menu()
	end
	
	--- Open the F4 menu (the one where you can choose your job, buy shipments, ammo, money printers, etc). Roughly equivalent to pressing F4 (or running gm_showspare2), but won't close it if it's already open.
	-- Only works if the local player is the owner of the chip, or if the chip is running in superuser mode.
	-- @client
	function darkrp_library.openF4Menu()
		if instance.player ~= SF.Superuser and instance.player ~= LocalPlayer() then SF.Throw("may not use this function on anyone other than owner", 2) return end
		DarkRP.openF4Menu()
	end
	
	--- Open the menu that requests a hit.
	-- Only works if the local player is the owner of the chip, or if the chip is running in superuser mode.
	-- @client
	-- @param Player hitman The hitman to request the hit to.
	function darkrp_library.openHitMenu(hitman)
		if instance.player ~= SF.Superuser and instance.player ~= LocalPlayer() then SF.Throw("may not use this function on anyone other than owner", 2) return end
		DarkRP.openHitMenu(getply(hitman))
	end
	
	--- Buy the door the local player is looking at, or open the menu if it's already bought. Equivalent to pressing F2 (or running gm_showteam).
	-- Only works if the local player is the owner of the chip, or if the chip is running in superuser mode.
	-- @client
	function darkrp_library.openKeysMenu()
		if instance.player ~= SF.Superuser and instance.player ~= LocalPlayer() then SF.Throw("may not use this function on anyone other than owner", 2) return end
		DarkRP.openKeysMenu()
	end
	
	--- Open the DarkRP pocket menu. This refers to DarkRP's built-in "pocket", and probably not your server's custom inventory system.
	-- Only works if the local player is the owner of the chip, or if the chip is running in superuser mode.
	-- @client
	function darkrp_library.openPocketMenu()
		if instance.player ~= SF.Superuser and instance.player ~= LocalPlayer() then SF.Throw("may not use this function on anyone other than owner", 2) return end
		DarkRP.openPocketMenu()
	end
	
	--- Toggle the state of the F4 menu (open or closed). Equivalent to pressing F4 (or running gm_showspare2).
	-- Only works if the local player is the owner of the chip, or if the chip is running in superuser mode.
	-- @client
	function darkrp_library.toggleF4Menu()
		if instance.player ~= SF.Superuser and instance.player ~= LocalPlayer() then SF.Throw("may not use this function on anyone other than owner", 2) return end
		DarkRP.toggleF4Menu()
	end
end

-- DarkRP-related Player and Entity methods are in libs_sh/players.lua and libs_sh/entities.lua

end
