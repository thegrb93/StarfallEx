local checkluatype = SF.CheckLuaType
local checkpattern = SF.CheckPattern
local registerprivilege = SF.Permissions.registerPrivilege

-- Under normal circumstances, an API change could introduce security
-- vulnerabilities. Suppose a DarkRP function changes to also return a Player
-- or Entity object, whereas before it only returned safe types like numbers
-- and strings. Starfall code unaware of the change might expose that function
-- in a way that ends in a tail call, which would result in all values being
-- returned as-is. That would be bad, as it would allow a guest to obtain
-- unwrapped objects.
-- checksafety and assertsafety resolve this by ensuring that unsafe values
-- don't make it to the guest. The way they are implemented have the downside
-- of those values not making it to the client at all, when they could be
-- wrapped. I could have done something like this to mitigate that:
--return unwrap(instance.Sanitize({...}))
-- ...but since nearly every single hook and function (in this file) is going
-- to be using these functions, I wanted to keep the added overhead as small
-- as possible.
local checksafety, assertsafety
do
	local whitelist = {
		["nil"] = true,
		["boolean"] = true,
		["number"] = true,
		["string"] = true,
	}
	local pairs = pairs
	local type = type
	function checksafety(...)
		for k, v in pairs({...}) do -- 'pairs' was determined to be faster than 'select'
			if not whitelist[type(v)] then
				return false
			end
		end
		return true
	end
	local table_remove = table.remove
	local unpack = unpack
	function assertsafety(...)
		local args = {...}
		for i=#args, 1, -1 do
			if not whitelist[type(args[i])] then
				table_remove(args, i)
			end
		end
		return unpack(args)
	end
end

-- Exposed so server owners and other addons can add/remove blacklist entries
SF.BlacklistedDarkRPVars = {
	hitTarget = true, -- The person a hitman has a hit on is generally not made visible to players (despite being accessible clientside).
}

local givemoneyBurst, moneyrequestBurst, requests, timeoutCvar, debugCvar
local function printDebug(...)
	if not debugCvar:GetBool() then return end
	return print(string.format(...))
end
if SERVER then
	debugCvar = CreateConVar("sf_moneyrequest_verbose_sv", 1, FCVAR_ARCHIVE, "Prints information about money requests to console.", 0, 1)
	
	util.AddNetworkString("sf_moneyrequest2")
	
	givemoneyBurst = SF.BurstObject("givemoney", "money giving", 0.5, 2, "The rate at which the cooldown for giving out that can be made for a single player decreases per second. Lower is longer, higher is shorter.", "Number of times a single player can give out money in a short time.")
	moneyrequestBurst = SF.BurstObject("moneyrequest", "money request", 0.5, 1, "The rate at which the cooldown for money requests that can be made for a single player decreases per second. Lower is longer, higher is shorter.", "Number of money requests that can be made by a single player in a short time.")
	
	registerprivilege("darkrp.moneyPrinterHooks", "Get own money printer info", "Allows the user to know when their own money printers catch fire or print money (and how much was printed)")
	registerprivilege("darkrp.playerWalletChanged", "Be notified of wallet changes", "Allows the user to know when their own wallet changes")
	registerprivilege("darkrp.lockdownHooks", "Know when lockdowns begin and end", "Allows the user to know when a lockdown begins or ends")
	registerprivilege("darkrp.lawHooks", "Know when laws change", "Allows the user to know when a law is added or removed, and when the laws are reset")
	registerprivilege("darkrp.lockpickHooks", "Know when they start picking a lock", "Allows the user to know when they start or finish lockpicking")
	registerprivilege("darkrp.requestMoney", "Ask players for money", "Allows the user to prompt other users for money (similar to E2 moneyRequest)")
	registerprivilege("darkrp.giveMoney", "Give players money", "Allows the user to give other users money")
	
	-- We need to keep track of money requests, so that they can be accepted and declined, as well as expire on their own.
	requests = setmetatable({}, {__mode="k"}) -- I'm pretty sure __mode doesn't work with Player keys, but let's use it anyway.
	SF.MoneyRequests = requests
	timeoutCvar = CreateConVar("sf_moneyrequest_timeout", 30, FCVAR_ARCHIVE, "Amount of time in seconds until a StarfallEx money request expires.", 5, 600)
	local requestsUpdateCvar = CreateConVar("sf_moneyrequest_updaterate", 1, FCVAR_ARCHIVE, "StarfallEx will traverse the table of money requests and discard expired or invalid ones every this many seconds. This should be a low value.", 0, 60)
	local function requestsUpdate()
		local now = CurTime()
		for player, requestsForPlayer in pairs(requests) do
			if IsValid(player) then
				for index, request in pairs(requestsForPlayer) do
					if request.timeToDie then
						if SysTime() >= request.timeToDie then
							-- The reason requests are given a "time to die" is to mitigate a potential
							-- vulnerability where if a player accepts a money request right as it
							-- expires, they could accidentally accept a different money request created
							-- immediately after the previous one expired, potentially resulting in a
							-- considerable sum of money being mistakenly sent to a malicious player.
							printDebug("SF: Removed damned money request with index %d for %s.", index, player:SteamID())
							requestsForPlayer[index] = nil
						end
					elseif not IsValid(request.receiver) then
						printDebug("SF: Damned money request with index %d for %s because the receiver was invalid.", index, player:SteamID())
						request.timeToDie = SysTime()+10
						if request.callbackFailure and request.instance and not request.instance.error then
							request.instance:runFunction(request.callbackFailure, "RECEIVER_INVALID")
						end
					elseif now >= request.expiry then
						printDebug("SF: Damned money request with index %d for %s because it expired %s second(s) ago.", index, player:SteamID(), now-request.expiry)
						request.timeToDie = SysTime()+10
						if request.callbackFailure and request.instance and not request.instance.error then
							request.instance:runFunction(request.callbackFailure, "REQUEST_TIMEOUT")
						end
					end
				end
				if not next(requestsForPlayer) then
					printDebug("SF: Purged money request table for %s because it was empty.", player:SteamID())
					requests[player] = nil
				end
			else
				printDebug("SF: Purged a mystery money request table because the player object used as its key was invalid.")
				requests[player] = nil
			end
		end
	end
	timer.Create("sf_moneyrequest_update", requestsUpdateCvar:GetFloat(), 0, requestsUpdate)
	cvars.AddChangeCallback("sf_moneyrequest_updaterate", function(name, old, new)
		timer.Adjust("sf_moneyrequest_update", new)
	end, "sf_updaterate")
	
	-- Console commands for managing money requests
	local function chatPrint(target, ...)
		local message = string.format(...)
		if IsValid(target) and target:IsPlayer() then
			target:PrintMessage(HUD_PRINTCONSOLE, message)
		else
			print(message)
		end
	end
	concommand.Add("sf_moneyrequest", function(executor, command, args)
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
		local receiver, amount, expiry, instance = request.receiver, request.amount, request.expiry, request.instance
		if not IsValid(receiver) then
			printDebug("SF: %s attempted to interact with money request %d for %s, but the receiver was invalid.", target:SteamID(), index, DarkRP.formatMoney(amount))
			requests[target][index] = nil
			return chatPrint(executor, "sf_moneyrequest: invalid receiver")
		end
		if action == "accept" then
			requests[target][index] = nil
			if not instance or instance.error then
				printDebug("SF: %s attempted to accept money request %d for %s from %s, but the instance was dead.", target:SteamID(), index, DarkRP.formatMoney(amount), receiver:SteamID())
				chatPrint(executor, "sf_moneyrequest: instance dead")
			elseif target:canAfford(amount) then
				printDebug("SF: %s accepted money request %d for %s from %s.", target:SteamID(), index, DarkRP.formatMoney(amount), receiver:SteamID())
				DarkRP.payPlayer(target, receiver, amount)
				if request.callbackSuccess then
					instance:runFunction(request.callbackSuccess, request.message, instance.Types.Player.Wrap(target), amount)
				end
			else
				printDebug("SF: %s attempted to accept money request %d for %s from %s, but the target couldn't afford it.", target:SteamID(), index, DarkRP.formatMoney(amount), receiver:SteamID())
			end
		elseif action == "decline" then
			requests[target][index] = nil
			if not instance or instance.error then
				printDebug("SF: %s attempted to decline money request %d for %s from %s, but the instance was dead.", target:SteamID(), index, DarkRP.formatMoney(amount), receiver:SteamID())
				chatPrint(executor, "sf_moneyrequest: instance dead")
			else
				printDebug("SF: %s declined money request %d for %s from %s.", target:SteamID(), index, DarkRP.formatMoney(amount), receiver:SteamID())
				if request.callbackFailure then
					instance:runFunction(request.callbackFailure, "REQUEST_DENIED")
				end
			end
		elseif action == "info" then
			chatPrint(executor, "sf_moneyrequest: %q requested %s from target, will expire at curtime %s (currently %s)", receiver:SteamID(), DarkRP.formatMoney(amount), expiry, CurTime())
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
	debugCvar = CreateConVar("sf_moneyrequest_verbose_cl", 1, FCVAR_ARCHIVE, "Prints information about money requests to console.", 0, 1)
	
	-- Allow blocking/unblocking money requests from some players, to help mitigate abuse
	local blocked = {}
	SF.BlockedMoneyRequests = blocked
	local function get_name(ply)
		-- DarkRP already forbids unsafe characters, and the "//" means injection
		-- shouldn't be possible anyway, but let's sanitize just to be safe.
		return ply:GetName():gsub('[%z\x01-\x1f\x7f;"\']', "")
	end
	concommand.Add("sf_moneyrequest_block", function(executor, cmd, args)
		if not args[1] then return print("sf_moneyrequest_block: missing steamid") end
		if not args[1]:find('[^%d]') then args[1] = util.SteamIDFrom64(args[1]) end
		if not args[1]:find('^STEAM_') then return print("sf_moneyrequest_block: invalid steamid") end
		blocked[args[1]] = true
	end, function(cmd)
		local tbl = {}
		for _, ply in pairs(player.GetHumans()) do
			table.insert(tbl, cmd.." \""..ply:SteamID().."\" // "..get_name(ply))
		end
		return tbl
	end, "Block a user from sending you money requests. Lasts until the end of your session, even if they relog.")
	concommand.Add("sf_moneyrequest_unblock", function(executor, cmd, args)
		if not args[1] then return print("sf_moneyrequest_unblock: missing steamid") end
		if not args[1]:find('[^%d]') then args[1] = util.SteamIDFrom64(args[1]) end
		if not args[1]:find('^STEAM_') then return print("sf_moneyrequest_unblock: invalid steamid") end
		blocked[args[1]] = nil
	end, function(cmd)
		local tbl = {}
		for steamid in pairs(blocked) do
			local target = player.GetBySteamID(steamid)
			table.insert(tbl, cmd.." \""..steamid..(IsValid(target) and "\" // "..get_name(target) or ""))
		end
		return tbl
	end, "Unblock a user from sending you money requests.")
	concommand.Add("sf_moneyrequest_blocklist", function(executor, cmd, args)
		local i = 0
		for steamid in pairs(blocked) do
			print(steamid)
			i = i+1
		end
		print(string.format("You have %d players on your block list.", i))
	end, nil, "List players you have blocked from sending you money requests.")
	
	-- Display the money request prompt when notified
	net.Receive("sf_moneyrequest2", function()
		local index = net.ReadUInt(32)
		local receiver = net.ReadEntity()
		local amount = net.ReadUInt(32)
		local expiry = net.ReadFloat()
		local length = net.ReadUInt(8)
		local message = length ~= 0 and net.ReadData(length) or nil
		if index == 0 or not IsValid(receiver) or amount == 0 or expiry <= CurTime() then
			return printDebug("SF: Ignoring money request with index of %d because it is malformed.", index)
		end
		printDebug("SF: Received money request (index %d) for %s to be sent to %s. It expires at CurTime %s.", index, DarkRP.formatMoney(amount), receiver:SteamID(), expiry)
		if SF.BlockedUsers[receiver:SteamID()] then
			return printDebug("SF: Ignoring money request because the receiver is in \"SF.BlockedUsers\".")
		elseif blocked[receiver:SteamID()] then
			return printDebug("SF: Ignoring money request because the receiver is in \"SF.BlockedMoneyRequests\".")
		end
		local mrf = vgui.Create("StarfallMoneyRequestFrame")
		mrf:Init2(index, receiver, amount, expiry, message)
	end)
	
	-- The actual money request prompt itself
	local PANEL = {}
	function PANEL:Init()
		self:SetSize(350, 250)
		self:Center()
		self:SetTitle("StarfallEx money request")
		self:MakePopup()
	end
	function PANEL:Init2(index, receiver, amount, expiry, message)
		if not IsValid(receiver) then
			self:Close()
			return
		end
		local startTime = SysTime()
		local desc = vgui.Create("DLabel", self)
		desc:SetText(string.format("A Starfall processor owned by %q (%s) is asking you for %s. Would you like to send them money?", receiver:GetName(), receiver:SteamID(), DarkRP.formatMoney(amount)))
		desc:SetAutoStretchVertical(true)
		desc:SetWrap(true)
		desc:Dock(TOP)
		if message then
			local descGivenDisclaimer = vgui.Create("DLabel", self)
			descGivenDisclaimer:SetText("The following reason was provided:")
			descGivenDisclaimer:SetAutoStretchVertical(true)
			descGivenDisclaimer:DockMargin(0, 5, 0, 0)
			descGivenDisclaimer:Dock(TOP)
			local descGiven = vgui.Create("DTextEntry", self)
			descGiven:SetHeight(60)
			descGiven:SetText(message)
			descGiven:SetEnabled(false)
			descGiven:DockMargin(0, 5, 0, 0)
			descGiven:Dock(TOP)
		end
		local descExpires = vgui.Create("DLabel", self)
		descExpires:SetText("This request expires in XXX seconds.")
		descExpires:SetWrap(true)
		descExpires:DockMargin(0, 5, 0, 0)
		descExpires:Dock(TOP)
		local blockRequests = vgui.Create("DCheckBoxLabel", self)
		blockRequests:SetText("Block future money requests from this user")
		blockRequests:SetWrap(true)
		blockRequests:DockMargin(0, 5, 0, 0)
		blockRequests:Dock(TOP)
		local buttons = vgui.Create('Panel', self)
		buttons:DockMargin(0, 5, 0, 0)
		buttons:Dock(BOTTOM)
		local btnDecline = vgui.Create("StarfallButton", buttons)
		btnDecline:Dock(LEFT)
		btnDecline:SetText("Decline")
		btnDecline:SetAutoSize(false)
		btnDecline:SetWidth(select(2, self:GetSize())/2)
		function btnDecline.DoClick()
			RunConsoleCommand("sf_moneyrequest", 0, "decline", index, expiry)
			self:Close()
		end
		local btnAccept = vgui.Create("StarfallButton", buttons)
		btnAccept:Dock(RIGHT)
		btnAccept:SetText("Accept (Wait XXX seconds)")
		btnAccept:SetAutoSize(false)
		btnAccept:SetWidth(select(2, self:GetSize())/2)
		function btnAccept.DoClick()
			RunConsoleCommand("sf_moneyrequest", 0, "accept", index, expiry)
			self:Close()
		end
		local receiverSteamID = receiver:SteamID() -- In case they disconnect between now and the window closing
		function self:OnClose()
			if blockRequests:GetChecked() then
				blocked[receiverSteamID] = true
			end
		end
		local me = LocalPlayer()
		local function updateAcceptEnabled(bool)
			local timeUntilSafe = 2-(SysTime()-startTime)
			if timeUntilSafe >= 0 then
				btnAccept:SetEnabled(false)
				btnAccept:SetText(string.format("Accept (Wait %s)", string.NiceTime(math.ceil(timeUntilSafe))))
			else
				btnAccept:SetText("Accept")
				if not me:canAfford(amount) then
					btnAccept:SetEnabled(false)
				else
					if bool == nil then
						bool = blockRequests:GetChecked()
					end
					btnAccept:SetEnabled(not bool)
				end
			end
		end
		blockRequests.OnChange = updateAcceptEnabled
		updateAcceptEnabled()
		function self:Think()
			updateAcceptEnabled()
			local remaining = expiry-CurTime()
			descExpires:SetText(string.format("This request expires in %s.", string.NiceTime(remaining)))
			if remaining <= 0 then
				self:Close()
			end
		end
		self:Open()
	end
	vgui.Register("StarfallMoneyRequestFrame", PANEL, "StarfallFrame")
end

if SERVER then
	--- Called when a money printer is about to catch fire. DarkRP only. Called between moneyPrinterPrintMoney and moneyPrinterPrinted.
	-- Not guaranteed to work for non-vanilla money printers.
	-- Only works if the owner of the chip also owns the money printer, or if the chip is running in superuser mode.
	-- @name moneyPrinterCatchFire
	-- @class hook
	-- @server
	-- @param Entity moneyprinter The money printer that is about to catch fire
	SF.hookAdd("moneyPrinterCatchFire", nil, function(instance, moneyprinter)
		if not moneyprinter then return false end
		if instance.player ~= SF.Superuser then
			if not moneyprinter.Getowning_ent or instance.player ~= moneyprinter:Getowning_ent() then return false end
			if not SF.Permissions.hasAccess(instance, nil, "darkrp.moneyPrinterHooks") then return false end
		end
		return true, {instance.Types.Entity.Wrap(moneyprinter)}
	end)

	--- Called after a money printer is has printed money. DarkRP only.
	-- Not guaranteed to work for non-vanilla money printers.
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
			if not SF.Permissions.hasAccess(instance, nil, "darkrp.moneyPrinterHooks") then return false end
		end
		return true, {instance.Types.Entity.Wrap(moneyprinter), instance.Types.Entity.Wrap(moneybag)}
	end)

	--- Called when a money printer is about to print money. DarkRP only.
	-- Not guaranteed to work for non-vanilla money printers.
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
			if not SF.Permissions.hasAccess(instance, nil, "darkrp.moneyPrinterHooks") then return false end
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
			if not SF.Permissions.hasAccess(instance, nil, "darkrp.playerWalletChanged") then return false end
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
		if instance.player ~= SF.Superuser and not SF.Permissions.hasAccess(instance, nil, "darkrp.lockdownHooks") then return false end
		return true, {actor and instance.Types.Player.Wrap(actor) or nil}
	end)

	--- Called when a lockdown has started. DarkRP only.
	-- @name lockdownStarted
	-- @class hook
	-- @server
	-- @param Player? actor The player who started the lockdown, or nil.
	SF.hookAdd("lockdownStarted", nil, function(instance, actor)
		if instance.player ~= SF.Superuser and not SF.Permissions.hasAccess(instance, nil, "darkrp.lockdownHooks") then return false end
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
		if instance.player ~= SF.Superuser and not SF.Permissions.hasAccess(instance, nil, "darkrp.lawHooks") then return false end
		return true, {index, law, player and instance.Types.Player.Wrap(player) or nil}
	end)

	--- Called when a law is removed. DarkRP only. Not usually called when /resetlaws is used.
	-- @name removeLaw
	-- @class hook
	-- @server
	-- @param number index Index of the law
	-- @param string law Law string
	-- @param Player? player The player who removed the law.
	SF.hookAdd("removeLaw", nil, function(instance, index, law, player)
		if not checksafety(index, law) then return false end
		if instance.player ~= SF.Superuser and not SF.Permissions.hasAccess(instance, nil, "darkrp.lawHooks") then return false end
		return true, {index, law, player and instance.Types.Player.Wrap(player) or nil}
	end)

	--- Called when laws are reset. DarkRP only. Usually the only hook called when /resetlaws is used.
	-- @name resetLaws
	-- @class hook
	-- @server
	-- @param Player? player The player resetting the laws.
	SF.hookAdd("resetLaws", nil, function(instance, player)
		if instance.player ~= SF.Superuser and not SF.Permissions.hasAccess(instance, nil, "darkrp.lawHooks") then return false end
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
			if not SF.Permissions.hasAccess(instance, nil, "darkrp.lockpickHooks") then return false end
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
			if not SF.Permissions.hasAccess(instance, nil, "darkrp.lockpickHooks") then return false end
			if instance.player ~= ply then return false end
		end
		return true, {
			ply and instance.Types.Player.Wrap(ply) or nil,
			success,
			ent and instance.Types.Entity.Wrap(ent) or nil
		}
	end)
end

--- Functions relating to DarkRP. These functions WILL NOT EXIST if DarkRP is not in use.
-- @name darkrp
-- @class library
-- @libtbl darkrp_library
SF.RegisterLibrary("darkrp")

return function(instance)

if not DarkRP then return end

local darkrp_library = instance.Libraries.darkrp
local ply_meta = instance.Types.Player
local player_methods, plywrap, plyunwrap, getply = ply_meta.Methods, ply_meta.Wrap, ply_meta.Unwrap
local ent_meta = instance.Types.Entity
local ents_methods, ewrap, eunwrap, getent = ent_meta.Methods, ent_meta.Wrap, ent_meta.Unwrap
instance:AddHook("initialize", function()
	getent = instance.Types.Entity.GetEntity
	getply = instance.Types.Player.GetPlayer
end)
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

--- Get a list of possible shipments.
-- @return table? A table with the contents of the GLua global "CustomShipments", or nil if it doesn't exist.
function darkrp_library.getCustomShipments()
	return CustomShipments and instance.Sanitize(CustomShipments) or nil
end

--- Get whether a DarkRPVar is blacklisted from being read by Starfall.
-- @param string var The name of the variable
-- @return boolean If the variable is blacklisted
function darkrp_library.isDarkRPVarBlacklisted(k)
	checkluatype(k, TYPE_STRING)
	return not not SF.BlacklistedDarkRPVars[k]
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
	-- This is subject to a burst limit. Use "darkrp.canGiveMoney" to check if you can give out money that tick.
	-- Only works if the sender is the owner of the chip, or if the chip is running in superuser mode.
	-- @server
	-- @param Player sender The player who gives the money.
	-- @param Player receiver The player who receives the money.
	-- @param number amount The amount of money.
	function darkrp_library.payPlayer(sender, receiver, amount)
		checkluatype(amount, TYPE_NUMBER)
		amount = math.ceil(amount)
		if amount <= 0 then SF.Throw("amount must be positive", 2) return end
		checkpermission(instance, nil, "darkrp.giveMoney")
		sender = getply(sender)
		if instance.player ~= SF.Superuser and instance.player ~= sender then SF.Throw("may not transfer money from player other than owner", 2) return end
		if sender:canAfford(amount) then
			givemoneyBurst:use(instance.player, 1)
			DarkRP.payPlayer(sender, getply(receiver), amount)
		else
			SF.Throw("sender can't afford to pay "..DarkRP.formatMoney(amount), 2)
		end
	end
	
	--- Request money from a player.
	-- This is subject to a burst limit, and a limit of one money request per sender per receiver at a time. Use "darkrp.canMakeMoneyRequest" to check if you can request money that tick for that player.
	-- @server
	-- @param Player sender The player who may or may not send the money.
	-- @param number amount The amount of money to ask for.
	-- @param string? message An optional custom message that will be shown in the money request prompt. May not exceed 60 bytes in length.
	-- @param function? callbackSuccess Optional function to call if request succeeds.
	-- @param function? callbackFailure Optional function to call if request fails.
	-- @param Player? receiver The player who may or may not receive the money, or the owner of the chip if not specified. Superuser only.
	function darkrp_library.requestMoney(sender, amount, message, callbackSuccess, callbackFailure, receiver)
		checkluatype(amount, TYPE_NUMBER)
		if callbackSuccess ~= nil then checkluatype(callbackSuccess, TYPE_FUNCTION) end
		if callbackFailure ~= nil then checkluatype(callbackFailure, TYPE_FUNCTION) end
		if message ~= nil then
			checkluatype(message, TYPE_STRING)
			if #message > 60 then SF.Throw("money request message may not exceed 60 bytes", 2) return end
		end
		amount = math.ceil(amount)
		if amount <= 0 then SF.Throw("amount must be positive", 2) return end
		checkpermission(instance, nil, "darkrp.requestMoney")
		sender = getply(sender)
		receiver = receiver ~= nil and getply(receiver) or instance.player
		local requestsForSender = requests[sender]
		if instance.player ~= SF.Superuser then
			if receiver ~= instance.player then SF.Throw("receiver must be chip owner if not superuser", 2) return end
			-- In theory, measuring the time it takes for this function to execute could
			-- allow a malicious chip to determine how many pending requests exist for a
			-- particular player. In testing, I was unable to come to any conclusions
			-- based on timing, even in extreme cases like having 1,000 pending requests.
			-- Even if such an attack is possible, it is not a particularly major issue.
			-- One should be aware that it may be possible, however.
			for _, request in pairs(requestsForSender or {}) do
				if request.receiver == receiver then SF.Throw("you already have a pending request for this sender", 2) return end
			end
		end
		moneyrequestBurst:use(instance.player, 1)
		if not requestsForSender then
			requestsForSender = {}
			requests[sender] = requestsForSender
		end
		local expiry = CurTime()+timeoutCvar:GetFloat()
		local request = {
			receiver = receiver,
			amount = amount,
			expiry = expiry,
			message = message,
			instance = instance,
			callbackSuccess = callbackSuccess,
			callbackFailure = callbackFailure
		}
		local index = table.insert(requestsForSender, request)
		request.index = index
		printDebug("SF: %s sent a money request for %s to %s (index %d).", receiver:SteamID(), DarkRP.formatMoney(amount), sender:SteamID(), index)
		net.Start("sf_moneyrequest2")
			net.WriteUInt(index, 32)
			net.WriteEntity(receiver)
			net.WriteUInt(amount, 32)
			net.WriteFloat(expiry)
			if message then
				net.WriteUInt(#message, 8)
				net.WriteData(message)
			else
				net.WriteUInt(0, 8)
			end
		net.Send(sender)
	end
	instance.guestRequestMoney = darkrp_library.requestMoney

	--- Returns number of money requests left.
	-- By default, this replenishes at a rate of 1 every 2 seconds, up to a maximum of 1.
	-- In other words, you can make a maximum of 1 money request every 2 seconds. May vary from server to server.
	-- @server
	-- @return number Number of money requests able to be created. This could be a decimal, so floor it first
	function darkrp_library.moneyRequestsLeft()
		return moneyrequestBurst:check(instance.player)
	end

	--- Returns whether you can make another money request this tick.
	-- If a player is provided as a parameter, will also check if you can request money from that particular player this tick.
	-- @server
	-- @param Player? sender Player you intend to ask for money from later
	-- @return boolean If you can make another money request
	function darkrp_library.canMakeMoneyRequest(sender)
		if moneyrequestBurst:check(instance.player) < 1 then return false end
		if sender ~= nil then
			local requestsForSender = requests[getply(sender)]
			for _, request in pairs(requestsForSender or {}) do
				if request.receiver == instance.player then return false end
			end
		end
		return true
	end

	--- Returns number of times you can give someone money.
	-- By default, this replenishes at a rate of 1 every 2 seconds, up to a maximum of 2.
	-- In other words, you can give out money two times at once, then you have to wait two seconds. May vary from server to server.
	-- @server
	-- @return number Number of money requests able to be created. This could be a decimal, so floor it first
	function darkrp_library.moneyGivingsLeft()
		return givemoneyBurst:check(instance.player)
	end

	--- Returns whether you can give someone money this tick.
	-- @server
	-- @return boolean If you can give someone money
	function darkrp_library.canGiveMoney()
		return givemoneyBurst:check(instance.player) >= 1
	end
else
	--- Open the F1 help menu. Roughly equivalent to pressing F1 (or running gm_showhelp), but won't close it if it's already open.
	-- Only works if the local player is the owner of the chip, or if the chip is running in superuser mode.
	-- @client
	function darkrp_library.openF1Menu()
		if instance.player ~= SF.Superuser and instance.player ~= LocalPlayer() then SF.Throw("may not use this function on anyone other than owner", 2) return end
		DarkRP.openF1Menu()
	end
	
	--- Close the F1 help menu.
	-- Only works if the local player is the owner of the chip, or if the chip is running in superuser mode.
	-- @client
	function darkrp_library.closeF1Menu()
		if instance.player ~= SF.Superuser and instance.player ~= LocalPlayer() then SF.Throw("may not use this function on anyone other than owner", 2) return end
		DarkRP.closeF1Menu()
	end
	
	--- Open the F4 menu (the one where you can choose your job, buy shipments, ammo, money printers, etc). Roughly equivalent to pressing F4 (or running gm_showspare2), but won't close it if it's already open.
	-- Only works if the local player is the owner of the chip, or if the chip is running in superuser mode.
	-- @client
	function darkrp_library.openF4Menu()
		if instance.player ~= SF.Superuser and instance.player ~= LocalPlayer() then SF.Throw("may not use this function on anyone other than owner", 2) return end
		DarkRP.openF4Menu()
	end
	
	--- Close the F4 menu (the one where you can choose your job, buy shipments, ammo, money printers, etc).
	-- Only works if the local player is the owner of the chip, or if the chip is running in superuser mode.
	-- @client
	function darkrp_library.closeF4Menu()
		if instance.player ~= SF.Superuser and instance.player ~= LocalPlayer() then SF.Throw("may not use this function on anyone other than owner", 2) return end
		DarkRP.closeF4Menu()
	end
	
	--- Toggle the state of the F4 menu (open or closed). Equivalent to pressing F4 (or running gm_showspare2).
	-- Only works if the local player is the owner of the chip, or if the chip is running in superuser mode.
	-- @client
	function darkrp_library.toggleF4Menu()
		if instance.player ~= SF.Superuser and instance.player ~= LocalPlayer() then SF.Throw("may not use this function on anyone other than owner", 2) return end
		DarkRP.toggleF4Menu()
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
end

-- Entity methods

if SERVER then
	--- Get the DarkRP door index of a door. Use this to store door information in the database.
	-- @server
	-- @return number? The door index, or nil if not a door.
	function ents_methods:doorIndex()
		return assertsafety(getent(self):doorIndex())
	end

	--- Get whether this door/vehicle is locked. DarkRP only.
	-- @server
	-- @return boolean Whether it's locked.
	function ents_methods:isLocked()
		return assertsafety(getent(self):isLocked())
	end
end

--- Get the owner of a door. DarkRP only.
-- @return Player? The owner of the door, or nil if the door is unowned.
function ents_methods:getDoorOwner()
	local owner = getent(self):getDoorOwner()
	if owner then return plywrap(owner) end
end

--- Get the title of this door or vehicle. DarkRP only.
-- If you don't know what this is referring to, that's because it's not a commonly used feature. Press F2 on a door and click "Set Door Title".
-- @return string? The title of the door or vehicle, or nil if none is set.
function ents_methods:getKeysTitle()
	return assertsafety(getent(self):getKeysTitle())
end

--- Get whether this entity is considered a door by DarkRP.
-- @return boolean Whether it's a door.
function ents_methods:isDoor()
	return assertsafety(getent(self):isDoor())
end

--- Get whether this door is owned by someone.
-- @return boolean Whether it's owned.
function ents_methods:isKeysOwned()
	return assertsafety(getent(self):isKeysOwned())
end

--- Get whether this door is owned or co-owned by this player.
-- @param Player ply The player to query.
-- @return boolean Whether this door is (co-)owned by the player.
function ents_methods:isKeysOwnedBy(ply)
	ply = getply(ply)
	return assertsafety(getent(self):isKeysOwnedBy(ply))
end

--- Get whether this entity is a "money bag", i.e. dropped money from a money printer or /dropmoney. DarkRP only.
-- @return boolean Whether this entity is a money bag.
function ents_methods:isMoneyBag()
	return assertsafety(getent(self):isMoneyBag())
end

--- Get the amount of money in a "money bag" or cheque, or number of items in a dropped item stack. DarkRP only.
-- Equivalent to GLua Entity:Getamount.
-- @return number? Amount of money or number of items
function ents_methods:getAmount()
	self = getent(self)
	return self.Getamount and assertsafety(self:Getamount()) or nil
end

--- Get the number of items remaining in a shipment. DarkRP only.
-- Equivalent to GLua Entity:Getcount.
-- @return number? Number of items remaining, or nil if not a shipment
function ents_methods:getCount()
	self = getent(self)
	return self.Getcount and assertsafety(self:Getcount()) or nil
end

--- Get the index of the contents of the shipment, which should then be looked up in the output of "darkrp.getCustomShipments". DarkRP only.
-- Equivalent to GLua Entity:Getcontents.
-- You may prefer to use Entity:getShipmentContents instead, although that function is slightly slower.
-- @return number? Index of contents, or nil if not a shipment
function ents_methods:getShipmentContentsIndex()
	self = getent(self)
	return self.Getcontents and assertsafety(self:Getcontents()) or nil
end

--- Get the info for the contents of the shipment. DarkRP only.
-- Equivalent to "darkrp.getCustomShipments()[ent:getShipmentContentsIndex()]"
-- @return table? Contents, or nil if not a shipment
function ents_methods:getShipmentContents()
	self = getent(self)
	if not CustomShipments or not self.Getcontents then return end
	return instance.Sanitize(CustomShipments[self:Getcontents()])
end

-- Player methods

if SERVER then
	--- Unown every door and vehicle owned by this player. DarkRP only.
	-- @server
	function player_methods:keysUnOwnAll()
		self = getply(self)
		if instance.player ~= SF.Superuser and instance.player ~= self then SF.Throw("may not use this function on anyone other than owner", 2) return end
		assertsafety(self:keysUnOwnAll())
	end
	player_methods.keysUnownAll = player_methods.keysUnOwnAll
	
	--- Returns the time left on a player's team ban. DarkRP only.
	-- Only works if the player is the owner of the chip, or if the chip is running in superuser mode.
	-- @server
	-- @param number? team The number of the job (e.g. TEAM_MEDIC). Uses the player's team if nil.
	-- @return number? The time left on the team ban in seconds, or nil if not banned.
	function player_methods:teamBanTimeLeft(team)
		if team ~= nil then checkluatype(team, TYPE_NUMBER) end
		self = getply(self)
		if instance.player ~= SF.Superuser and instance.player ~= self then SF.Throw("may not use this function on anyone other than owner", 2) return end
		return assertsafety(self:teamBanTimeLeft())
	end
	
	--- Request money from a player.
	-- This is subject to a burst limit. Use the darkrp.canMakeMoneyRequest function to check if you can request money that tick.
	-- @server
	-- @param string? message An optional custom message that will be shown in the money request prompt. May not exceed 60 bytes in length.
	-- @param number amount The amount of money to ask for.
	-- @param function? callbackSuccess Optional function to call if request succeeds.
	-- @param function? callbackFailure Optional function to call if request fails.
	-- @param Player? receiver The player who may or may not receive the money, or the owner of the chip if not specified. Superuser only.
	function player_methods:requestMoney(message, amount, callbackSuccess, callbackFailure, receiver)
		-- Argument order is different for purposes of compatibility with loganlearner/starfall-darkrp-library
		return instance.guestRequestMoney(self, amount, message, callbackSuccess, callbackFailure, receiver)
	end
	
	--- Give this player money.
	-- This is subject to a burst limit. Use the darkrp.canGiveMoney function to check if you can request money that tick.
	-- @server
	-- @param number amount The amount of money to give.
	function player_methods:giveMoney(amount)
		checkluatype(amount, TYPE_NUMBER)
		amount = math.ceil(amount)
		if amount <= 0 then SF.Throw("amount must be positive", 2) return end
		checkpermission(instance, nil, "darkrp.giveMoney")
		if instance.player:canAfford(amount) then
			givemoneyBurst:use(instance.player, 1)
			DarkRP.payPlayer(instance.player, getply(self), amount)
		else
			SF.Throw("you can't afford to pay "..DarkRP.formatMoney(amount), 2)
		end
	end
else
	--- Whether this player is in the same room as the LocalPlayer. DarkRP only.
	-- @client
	-- @return boolean Whether this player is in the same room.
	function player_methods:isInRoom()
		local bool = getply(self):isInRoom()
		instance:checkCpu() -- This function could potentially be expensive, so this check is a good idea.
		return assertsafety(bool)
	end
end

--- Get whether the player can afford the given amount of money. DarkRP only.
-- @param number amount The amount of money
-- @return boolean Whether the player can afford it
function player_methods:canAfford(amount)
	checkluatype(amount, TYPE_NUMBER)
	return assertsafety(getply(self):canAfford(amount))
end

--- Get whether the player can lock a given door. DarkRP only.
-- @param Entity door The door
-- @return boolean? Whether the player is allowed to lock the door. May be nil instead of false.
function player_methods:canKeysLock(door)
	return assertsafety(getply(self):canKeysLock(eunwrap(door)))
end

--- Get whether the player can unlock a given door. DarkRP only.
-- @param Entity door The door
-- @return boolean? Whether the player is allowed to unlock the door. May be nil instead of false.
function player_methods:canKeysUnlock(door)
	return assertsafety(getply(self):canKeysUnlock(eunwrap(door)))
end

--- Get the value of a DarkRPVar, which is shared between server and client. Case-sensitive.
-- Possible variables include (but are not limited to): AFK, AFKDemoted, money, salaryRL, rpname, job, HasGunlicense, Arrested, wanted, wantedReason, agenda, zombieToggle, hitTarget, hitPrice, lastHitTime, Energy
-- For money specifically, you may optionally use Player:getMoney instead.
-- Some variables may be blacklisted so that you can't read their value.
-- @param string var The name of the variable.
-- @return any The value of the DarkRP var.
function player_methods:getDarkRPVar(k)
	checkluatype(k, TYPE_STRING)
	if instance.player ~= SF.Superuser and SF.BlacklistedDarkRPVars[k] then return end
	return assertsafety(getply(self):getDarkRPVar(k))
end

--- Get the job table of a player. DarkRP only.
-- @return table Table with the job information.
function player_methods:getJobTable()
	return instance.Sanitize(getply(self):getJobTable())
end

--- Get a player's pocket items. DarkRP only.
-- @return table A table containing information about the items in the pocket.
function player_methods:getPocketItems()
	return instance.Sanitize(getply(self):getPocketItems())
end

--- Get the reason why someone is wanted. DarkRP only.
-- @return string? The reason, or nil if not wanted
function player_methods:getWantedReason()
	return assertsafety(getply(self):getWantedReason())
end

--- Whether the player has a certain DarkRP privilege.
-- @return boolean Whether the player has the privilege.
function player_methods:hasDarkRPPrivilege(priv)
	checkluatype(priv, TYPE_STRING)
	return assertsafety(getply(self):hasDarkRPPrivilege(priv))
end

--- Whether this player is arrested. DarkRP only.
-- @return boolean? Whether this player is arrested. May be nil instead of false.
function player_methods:isArrested()
	return assertsafety(getply(self):isArrested())
end

--- Whether this player is a Chief. DarkRP only.
-- @return boolean? Whether this player is a Chief. May be nil instead of false.
function player_methods:isChief()
	return assertsafety(getply(self):isChief())
end

--- Whether this player is a cook. DarkRP only. Only works if hungermod is enabled.
-- @return boolean? Whether this player is a cook. May be nil instead of false.
function player_methods:isCook()
	return assertsafety(getply(self):isCook())
end

--- Whether this player is part of the police force (Mayor, CP, Chief). DarkRP only.
-- @return boolean Whether this player is a part of the police force.
function player_methods:isCP()
	return assertsafety(getply(self):isCP())
end

--- Whether this player is a hitman. DarkRP only.
-- @return boolean? Whether this player is a hitman. May be nil instead of false.
function player_methods:isHitman()
	return assertsafety(getply(self):isHitman())
end

--- Whether this player is the Mayor. DarkRP only.
-- @return boolean? Whether this player is the Mayor. May be nil instead of false.
function player_methods:isMayor()
	return assertsafety(getply(self):isMayor())
end

--- Whether this player is a medic. DarkRP only.
-- @return boolean? Whether this player is a medic. May be nil instead of false.
function player_methods:isMedic()
	return assertsafety(getply(self):isMedic())
end

--- Whether this player is wanted. DarkRP only. Use Player:getWantedReason if you want to know the reason.
-- @return boolean? Whether this player is wanted. May be nil instead of false.
function player_methods:isWanted()
	return assertsafety(getply(self):isWanted())
end

--- Get the amount of money this player has. DarkRP only.
-- Equivalent to "ply:getDarkRPVar('money')"
-- @return number? The amount of money, or nil if not accessible.
function player_methods:getMoney()
	if instance.player ~= SF.Superuser and SF.BlacklistedDarkRPVars.money then return end
	return assertsafety(getply(self):getDarkRPVar("money"))
end

end
