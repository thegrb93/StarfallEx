local checkluatype = SF.CheckLuaType
local checkpattern = SF.CheckPattern

--- Functions relating to DarkRP.
-- @name darkrp
-- @class library
-- @libtbl darkrp_library
SF.RegisterLibrary("darkrp")

--- Called when a law is added. DarkRP only.
-- @name addLaw
-- @class hook
-- @param number index Index of the law
-- @param string law Law string
-- @param Player? player The player who added the law, or nil if clientside for some reason
SF.hookAdd("addLaw", "addlaw", function(instance, index, law, player)
	return true, {index, law, player and instance.Types.Player.Wrap(player) or nil}
end)

--- Called when a lockdown has ended. DarkRP only.
-- @name lockdownEnded
-- @class hook
-- @server
-- @param Entity actor The player who ended the lockdown. Could also be the world entity, because that makes perfect sense.
SF.hookAdd("lockdownEnded", "lockdownended", function(instance, actor)
	return true, {actor and instance.Types.Player.Wrap(actor) or nil}
end)

--- Called when a lockdown has started. DarkRP only.
-- @name lockdownStarted
-- @class hook
-- @server
-- @param Entity actor The player who started the lockdown. Could also be the world entity, because that makes perfect sense.
SF.hookAdd("lockdownStarted", "lockdownstarted", function(instance, actor)
	return true, {actor and instance.Types.Player.Wrap(actor) or nil}
end)

--- Called when a player is about to pick a lock. DarkRP only.
-- Will only be called if the lockpicker is the owner of the chip, or if the chip is running in superuser mode.
-- @name lockpickStarted
-- @class hook
-- @param Player ply The player that is about to pick a lock.
-- @param Entity ent The entity being lockpicked.
-- @param table trace The trace result.
SF.hookAdd("lockpickStarted", "lockpickstarted", function(instance, ply, ent, trace)
	if instance.player ~= SF.Superuser and instance.player ~= ply then return false end
	return true, {
		ply and instance.Types.Player.Wrap(ply) or nil,
		ent and instance.Types.Entity.Wrap(ent) or nil,
		trace and SF.StructWrapper(instance, trace, "TraceResult") or nil
	}
end)

if SERVER then
	--- Called when a money printer is about to catch fire. DarkRP only. Called between moneyPrinterPrintMoney and moneyPrinterPrinted.
	-- Will only be called if the owner of the chip also owns the money printer, or if the chip is running in superuser mode.
	-- @name moneyPrinterCatchFire
	-- @class hook
	-- @server
	-- @param Entity moneyprinter The money printer that is about to catch fire
	-- @return boolean? Set to true to prevent the money printer from catching fire (superuser only)
	SF.hookAdd("moneyPrinterCatchFire", "moneyprintercatchfire", function(instance, moneyprinter)
		if instance.player ~= SF.Superuser and instance.player ~= moneyprinter:Getowning_ent() then return false end
		return true, {instance.Types.Entity.Wrap(moneyprinter)}
	end, function(instance, args)
		if args[1] and instance.player == SF.Superuser then
			return true
		end
	end)

	--- Called after a money printer is has printed money. DarkRP only.
	-- Will only be called if the owner of the chip also owns the money printer, or if the chip is running in superuser mode.
	-- @name moneyPrinterPrinted
	-- @class hook
	-- @server
	-- @param Entity moneyprinter The money printer
	-- @param Entity moneybag The moneybag produed by the printer.
	SF.hookAdd("moneyPrinterPrinted", "moneyprinterprinted", function(instance, moneyprinter, moneybag)
		if instance.player ~= SF.Superuser and instance.player ~= moneyprinter:Getowning_ent() then return false end
		return true, {instance.Types.Entity.Wrap(moneyprinter), instance.Types.Entity.Wrap(moneybag)}
	end)

	--- Called when a money printer is about to print money. DarkRP only.
	-- Will only be called if the owner of the chip also owns the money printer, or if the chip is running in superuser mode.
	-- @name moneyPrinterPrintMoney
	-- @class hook
	-- @server
	-- @param Entity moneyprinter The money printer
	-- @param number amount The amount to be printed
	-- @return boolean? Set to true to prevent the money printer from printing the money. Superuser only.
	-- @return number? Optionally override the amount of money that will be printed. Superuser only.
	SF.hookAdd("moneyPrinterPrintMoney", "moneyprinterprintmoney", function(instance, moneyprinter, amount)
		if instance.player ~= SF.Superuser and instance.player ~= moneyprinter:Getowning_ent() then return false end
		return true, {instance.Types.Entity.Wrap(moneyprinter), amount}
	end, function(instance, args)
		if instance.player ~= SF.Superuser then
			return
		end
		if args[1] then
			return true
		elseif type(args[2]) == 'number' then
			return nil, args[2]
		end
	end)
end

--- Called when a law is removed. DarkRP only.
-- @name addLaw
-- @class hook
-- @param number index Index of the law
-- @param string law Law string
-- @param Player? player The player who removed the law, or nil if clientside for some reason
SF.hookAdd("removeLaw", "removelaw", function(instance, index, law, player)
	return true, {index, law, player and instance.Types.Player.Wrap(player) or nil}
end)

--- Called when laws are reset. DarkRP only.
-- Serverside, this is the only hook called when /resetlaws is used.
-- Clientside, the addLaw hook is run 3 times (once for each of the default laws), then this hook runs.
-- @name addLaw
-- @class hook
-- @param Player? player The player resetting the laws, or nil if clientside for some reason.
SF.hookAdd("resetLaws", "resetlaws", function(instance, player)
	return true, {player and instance.Types.Player.Wrap(player) or nil}
end)

return function(instance)

if not DarkRP then return end

instance:AddHook("deinitialize", function()
	-- TODO
end)

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
	return DarkRP.formatMoney(n)
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

if SERVER then
	--- Get the entity corresponding to a door index. Note: The door MUST have been created by the map!
	-- @server
	-- @param number doorIndex The door index
	-- @return Entity? The door entity, or nil if door index is invalid
	function darkrp_library.doorIndexToEnt(doorIndex)
		checkluatype(doorIndex, TYPE_NUMBER)
		local entIndex = DarkRP.doorToEntIndex(doorIndex)
		if entIndex and entIndex ~= 0 then
			return ewrap(Entity(entIndex))
		end
	end
	
	--- The number of jail positions in the current map.
	-- @server
	-- @return number The number of jail positions in the current map.
	function darkrp_library.jailPosCount()
		return DarkRP.jailPosCount()
	end
	
	--- Make one player give money to the other player.
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
	--- Open the F1 help menu.
	-- @client
	function darkrp_library.openF1Menu()
		if instance.player ~= SF.Superuser and instance.player ~= LocalPlayer() then SF.Throw("may not use this function on anyone other than owner", 2) return end
		DarkRP.openF1Menu()
	end
	
	--- Open the F4 menu (the one where you can choose your job, buy shipments, ammo, money printers, etc).
	-- @client
	function darkrp_library.openF4Menu()
		if instance.player ~= SF.Superuser and instance.player ~= LocalPlayer() then SF.Throw("may not use this function on anyone other than owner", 2) return end
		DarkRP.openF4Menu()
	end
	
	--- Open the menu that requests a hit.
	-- @client
	-- @param Player hitman The hitman to request the hit to.
	function darkrp_library.openHitMenu(hitman)
		if instance.player ~= SF.Superuser and instance.player ~= LocalPlayer() then SF.Throw("may not use this function on anyone other than owner", 2) return end
		DarkRP.openHitMenu(getply(hitman))
	end
	
	--- Buy the door the local player is looking at, or open the menu if it's already bought. Equivalent to pressing F2.
	-- @client
	function darkrp_library.openKeysMenu()
		if instance.player ~= SF.Superuser and instance.player ~= LocalPlayer() then SF.Throw("may not use this function on anyone other than owner", 2) return end
		DarkRP.openKeysMenu()
	end
	
	--- Open the DarkRP pocket menu.
	-- @client
	function darkrp_library.openPocketMenu()
		if instance.player ~= SF.Superuser and instance.player ~= LocalPlayer() then SF.Throw("may not use this function on anyone other than owner", 2) return end
		DarkRP.openPocketMenu()
	end
	
	--- Wrap a text around when reaching a certain width.
	-- Note: Long input strings may cause a "Regex too complex!" error.
	-- @client
	-- @param string text The text to wrap.
	-- @param string font The font of the text.
	-- @param number width The maximum width in pixels.
	-- @return string The wrapped string.
	function darkrp_library.textWrap(text, font, width)
		checkpattern(text, "(%s?[%S]+)") -- Pattern used by DarkRP internally
		if not SF.DefinedFonts[font] then SF.Throw("Font does not exist.", 2) return end
		return DarkRP.textWrap(text, font, width)
	end
	
	--- Toggle the state of the F4 menu (open or closed).
	-- @client
	function darkrp_library.toggleF4Menu()
		if instance.player ~= SF.Superuser and instance.player ~= LocalPlayer() then SF.Throw("may not use this function on anyone other than owner", 2) return end
		DarkRP.toggleF4Menu()
	end
end

-- DarkRP-related Player and Entity methods are in libs_sh/players.lua and libs_sh/entities.lua

end
