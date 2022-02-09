local checkluatype = SF.CheckLuaType
local checkpattern = SF.CheckPattern
local registerprivilege = SF.Permissions.registerPrivilege
local checksafety = SF.CheckSafety
local assertsafety = SF.AssertSafety

local requests, timeoutCvar
local debugCvar = CreateConVar("sf_moneyrequest_verbose", 0, FCVAR_REPLICATED, "Prints extra information to server console. Intended for debugging.", 0, 1)
local function printDebug(...)
	if not debugCvar:GetBool() then return end
	return print(string.format(...))
end
if SERVER then
	registerprivilege("darkrp.moneyPrinterHooks", "Get own money printer info", "Allows the user to know when their own money printers catch fire or print money (and how much was printed)")
	registerprivilege("darkrp.playerWalletChanged", "Be notified of wallet changes", "Allows the user to know when their own wallet changes")
	registerprivilege("darkrp.lockdownHooks", "Know when lockdowns begin and end", "Allows the user to know when a lockdown begins or ends")
	registerprivilege("darkrp.lawHooks", "Know when laws change", "Allows the user to know when a law is added or removed, and when the laws are reset")
	registerprivilege("darkrp.lockpickHooks", "Know when they start picking a lock", "Allows the user to know when they start picking a lock")
	registerprivilege("darkrp.requestMoney", "Ask players for money", "Allows the user to prompt other users for money (similar to E2 moneyRequest)")
	
	requests = setmetatable({}, {__mode="k"}) -- Pretty sure this doesn't work with Player keys, but let's do it anyway.
	SF.MoneyRequests = requests
	timeoutCvar = CreateConVar("sf_moneyrequest_timeout", 30, FCVAR_ARCHIVE, "Amount of time in seconds until a StarfallEx money request expires.", 1, 600)
	local function requestsUpdate()
		local now = CurTime()
		for player, requestsForPlayer in pairs(requests) do
			if IsValid(player) then
				for index, request in pairs(requestsForPlayer) do
					if now >= request.expiry or not IsValid(request.receiver) then
						printDebug("invalidated request #%d of steamid %q (now: %s, expiry: %s)", index, player:SteamID(), now, request.expiry)
						requestsForPlayer[index] = nil
					end
				end
				if not next(requestsForPlayer) then
					printDebug("purged table for steamid %q because it had no requests", player:SteamID())
					requests[player] = nil
				end
			else
				printDebug("purged... someone's table because the key was invalid")
				requests[player] = nil
			end
		end
	end
	timer.Create("sf_moneyrequest_timeout", timeoutCvar:GetFloat()/2, 0, requestsUpdate)
	cvars.AddChangeCallback("sf_moneyrequest_timeout", function(name, old, new)
		timer.Adjust("sf_moneyrequest_timeout", math.max(new/2, 0.5))
	end, "sf_timer_update")
	util.AddNetworkString("sf_moneyrequest")
	
	local function chatPrint(target, ...)
		local message = string.format(...)
		if IsValid(target) and target:IsPlayer() then
			target:PrintMessage(HUD_PRINTCONSOLE, message)
		else
			print(message)
		end
	end
	concommand.Add("sf_moneyrequest", function(executor, command, args)
		if not DarkRP then
			return chatPrint(executor, "sf_moneyrequest: DarkRP not present")
		end
		local target, action, index, maxAge = tonumber(args[1]), args[2], tonumber(args[3]), tonumber(args[4])
		if not target or not action or not index then
			return chatPrint(executor, "sf_moneyrequest: malformed parameters (do \"help sf_moneyrequest\")")
		end
		if maxAge and CurTime() >= maxAge then
			return chatPrint(executor, "sf_moneyrequest: exceeded max age")
		end
		target = target == 0 and executor or Entity(target)
		if not IsValid(target) or not target:IsPlayer() then
			return chatPrint(executor, "sf_moneyrequest: invalid target")
		end
		if IsValid(executor) and target ~= executor and not executor:IsSuperAdmin() then
			return chatPrint(executor, "sf_moneyrequest: only superadmins can interact with other people's money requests")
		end
		local request = (requests[target] or {})[index]
		if not request then
			return chatPrint(executor, "sf_moneyrequest: no such request at given index")
		end
		local receiver, amount, expiry = request.receiver, request.amount, request.expiry
		if action == "accept" then
			printDebug("target %q accepted request for %s from receiver %q", target:SteamID(), DarkRP.formatMoney(amount), receiver:SteamID())
			requests[target][index] = nil
			DarkRP.payPlayer(target, receiver, amount)
		elseif action == "decline" then
			printDebug("target %q declined request for %s from receiver %q", target:SteamID(), DarkRP.formatMoney(amount), receiver:SteamID())
			requests[target][index] = nil
		elseif action == "info" then
			chatPrint(executor, "sf_moneyrequest: %q requested %s from target, will expire at curtime %s", receiver:SteamID(), DarkRP.formatMoney(amount), expiry)
		else
			chatPrint(executor, "sf_moneyrequest: invalid action")
		end
	end, nil, "Accept, decline, or view info about a StarfallEx money request. Usage: sf_moneyrequest <entindex or 0> <accept|decline|info> <request index>", FCVAR_CLIENTCMD_CAN_EXECUTE)
	concommand.Add("sf_moneyrequest_update", function(executor)
		if IsValid(executor) and not executor:IsSuperAdmin() then
			return
		end
		requestsUpdate()
		chatPrint(executor, "sf_moneyrequest_update: done")
	end, nil, "Manually trigger a purge of expired/invalid money requests. Superadmin/RCON only.", FCVAR_UNREGISTERED)
	concommand.Add("sf_moneyrequest_purge", function(executor)
		if IsValid(executor) and not executor:IsSuperAdmin() then
			return
		end
		for k in pairs(requests) do
			requests[k] = nil
		end
		chatPrint(executor, "sf_moneyrequest_purge: done")
	end, nil, "Manually trigger a purge of all money requests. Superadmin/RCON only.", FCVAR_UNREGISTERED)
else
	local blocked = {}
	SF.BlockedMoneyRequests = blocked
	concommand.Add("sf_moneyrequest_block", function(executor, cmd, args)
		if not args[1] then return print("sf_moneyrequest_block: missing steamid") end
		if not args[1]:find('[^%d]') then args[1] = util.SteamIDFrom64(args[1]) end
		if not args[1]:find('^STEAM_') then return print("sf_moneyrequest_block: invalid steamid") end
		blocked[args[1]] = true
	end, function(cmd)
		local tbl = {}
		for _, player in pairs(player.GetHumans()) do
			table.insert(tbl, cmd.." \""..player:SteamID().."\" // "..player:GetName())
		end
		return tbl
	end, "Block a user from sending you money requests. Lasts until the remainder of your session, even if they relog.")
	concommand.Add("sf_moneyrequest_unblock", function(executor, cmd, args)
		if not args[1] then return print("sf_moneyrequest_unblock: missing steamid") end
		if not args[1]:find('[^%d]') then args[1] = util.SteamIDFrom64(args[1]) end
		if not args[1]:find('^STEAM_') then return print("sf_moneyrequest_unblock: invalid steamid") end
		blocked[args[1]] = nil
	end, function(cmd)
		local tbl = {}
		for steamid in pairs(blocked) do
			local target = player.GetBySteamID(steamid)
			table.insert(tbl, cmd.." \""..steamid..(IsValid(target) and "\" // "..target:GetName() or ""))
		end
		return tbl
	end, "Unblock a user from sending you money requests.")
	concommand.Add("sf_moneyrequest_blocklist", function(executor, cmd, args)
		for steamid in pairs(blocked) do
			print(steamid)
		end
	end, nil, "List players you have blocked from sending you money requests.")
	net.Receive("sf_moneyrequest", function()
		local index = net.ReadUInt(32)
		local receiver = net.ReadEntity()
		local amount = net.ReadUInt(32)
		local expiry = net.ReadFloat()
		if index == 0 or not IsValid(receiver) or amount == 0 or expiry <= CurTime() then
			return printDebug("rejecting request #%d because it is malformed", index)
		end
		printDebug("received request #%d for %s to be sent to %s (expires %s)", index, DarkRP.formatMoney(amount), receiver:SteamID(), expiry)
		if SF.BlockedUsers[receiver:SteamID()] then
			return printDebug("ignoring because the user is in SF.BlockedUsers")
		elseif blocked[receiver:SteamID()] then
			return printDebug("ignoring because the user is in SF.BlockedMoneyRequests")
		end
		local mrf = vgui.Create("StarfallMoneyRequestFrame")
		mrf:Init2(index, receiver, amount, expiry)
	end)
	local PANEL = {}
	function PANEL:Init()
		self:SetSize(300, 200)
		self:Center()
		self:SetTitle("StarfallEx money request")
		self:MakePopup()
	end
	function PANEL:Init2(index, receiver, amount, expiry)
		if not IsValid(receiver) then
			self:Close()
			return
		end
		local desc = vgui.Create("DLabel", self)
		desc:SetText(string.format("%q (%s)'s StarfallEx chip is asking you for %s. Would you like to send them money?", receiver:GetName(), receiver:SteamID(), DarkRP.formatMoney(amount)))
		--desc:SizeToContents()
		desc:SetHeight(60) -- hacky
		desc:SetWrap(true)
		desc:Dock(TOP)
		local descExpires = vgui.Create("DLabel", self)
		descExpires:SetText("This request expires in XXX seconds.")
		--descExpires:SizeToContents()
		descExpires:SetWrap(true)
		descExpires:DockMargin(0, 5, 0, 0)
		descExpires:Dock(TOP)
		function self:Think()
			local remaining = expiry-CurTime()
			descExpires:SetText(string.format("This request expires in %s.", string.NiceTime(remaining)))
			if remaining <= 0 then
				self:Close()
			end
		end
		local blockRequests = vgui.Create("DCheckBoxLabel", self)
		blockRequests:SetText("Block future money requests from this user")
		--blockRequests:SizeToContents()
		blockRequests:SetWrap(true)
		blockRequests:DockMargin(0, 5, 0, 0)
		blockRequests:Dock(TOP)
		local buttons = vgui.Create('Panel', self)
		buttons:DockMargin(0, 5, 0, 0)
		buttons:Dock(TOP)
		local btnDecline = vgui.Create("DButton", buttons)
		btnDecline:Dock(LEFT)
		btnDecline:SetText("Decline")
		function btnDecline.DoClick()
			RunConsoleCommand("sf_moneyrequest", 0, "decline", index, expiry)
			self:Close()
		end
		local btnAccept = vgui.Create("DButton", buttons)
		btnAccept:Dock(RIGHT)
		btnAccept:SetText("Accept")
		function btnAccept.DoClick()
			RunConsoleCommand("sf_moneyrequest", 0, "accept", index, expiry)
			self:Close()
		end
		function blockRequests:OnChange(bool)
			btnAccept:SetEnabled(not bool)
		end
		local receiverSteamID = receiver:SteamID() -- In case they disconnect between now and the window closing
		function self:OnClose()
			if blockRequests:GetChecked() then
				blocked[receiverSteamID] = true
			end
		end
	end
	vgui.Register("StarfallMoneyRequestFrame", PANEL, "DFrame")
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
	
	--- Request money from a player. Receiver must be owner of chip if chip is not running in superuser mode.
	-- This function will be subject to a ratelimit, so don't abuse it.
	-- @server
	-- @param Player sender The player who may or may not send the money.
	-- @param number amount The amount of money to ask for.
	-- @param Player? receiver The player who may or may not receive the money, or the owner of the chip if not specified.
	function darkrp_library.requestMoney(sender, amount, receiver)
		-- TODO: add ratelimiting (IMPORTANT)
		checkluatype(amount, TYPE_NUMBER)
		amount = math.ceil(amount)
		checkpermission(instance, nil, "darkrp.requestMoney")
		sender = getply(sender)
		receiver = receiver ~= nil and getply(receiver) or instance.player
		if instance.player ~= SF.Superuser and receiver ~= instance.player then SF.Throw("receiver must be chip owner if not superuser", 2) return end
		printDebug("player %q is requesting %s from player %q", receiver:SteamID(), DarkRP.formatMoney(amount), sender:SteamID())
		local requestsForSender = requests[sender]
		if not requestsForSender then
			requestsForSender = {}
			requests[sender] = requestsForSender
		end
		local expiry = CurTime()+timeoutCvar:GetFloat()
		local request = {
			receiver = receiver,
			amount = amount,
			expiry = expiry
		}
		local index = table.insert(requestsForSender, request)
		request.index = index
		net.Start("sf_moneyrequest")
			net.WriteUInt(index, 32)
			net.WriteEntity(receiver)
			net.WriteUInt(amount, 32)
			net.WriteFloat(expiry)
		net.Send(sender)
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
