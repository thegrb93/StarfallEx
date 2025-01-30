timer.Simple(0, function()
	if util.NetworkStringToID("sf_moneyrequest") ~= 0 then
		if SERVER then
			ErrorNoHalt("SF: loganlearner/starfall-darkrp-library is obsolete as StarfallEx now has a built-in DarkRP library. Please uninstall loganlearner/starfall-darkrp-library\n")
		else
			print("SF: This server has loganlearner/starfall-darkrp-library installed, which is obsolete as StarfallEx now has a built-in DarkRP library. The built-in library will be disabled. If you experience any problems with DarkRP-specific code, this might be why!")
		end
	end
end)

local checkluatype = SF.CheckLuaType
local checkpattern = SF.CheckPattern
local registerprivilege = SF.Permissions.registerPrivilege
local IsValid = FindMetaTable("Entity").IsValid

hook.Add("StarfallProcessDocs", "DarkRP", function(docs)
	if DarkRP then return end
	docs.Libraries.darkrp = nil
	docs.Hooks.moneyPrinterCatchFire = nil
	docs.Hooks.moneyPrinterPrinted = nil
	docs.Hooks.moneyPrinterPrintMoney = nil
	docs.Hooks.playerWalletChanged = nil
	docs.Hooks.lockdownEnded = nil
	docs.Hooks.lockdownStarted = nil
	docs.Hooks.addLaw = nil
	docs.Hooks.removeLaw = nil
	docs.Hooks.resetLaws = nil
	docs.Hooks.lockpickStarted = nil
	docs.Hooks.onLockpickCompleted = nil
end)

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

local givemoneyBurst, moneyrequestBurst, debugCvar
local function printDebug(msg, request)
	if not debugCvar:GetBool() then return end
	if request then
		print(msg, request)
	else
		print(msg) -- Avoid "nil" being printed
	end
end

local manager = {}
SF.MoneyRequestManager = manager -- Exposed so other addons can manage money requests
local requestClass = {}
requestClass.__index = requestClass
manager.requestClass = requestClass
function requestClass:new(sender, receiver, amount, message, expiry, instance, callbackSuccess, callbackFailure)
	return setmetatable({
		sender = sender,
		receiver = receiver,
		amount = amount,
		message = message,
		expiry = expiry,
		instance = instance,
		callbackSuccess = callbackSuccess,
		callbackFailure = callbackFailure
	}, self)
end
function requestClass:__tostring()
	return string.format(
		"%s from %s to %s, expiring in %.02f seconds",
		DarkRP.formatMoney(self.amount),
		IsValid(self.sender) and self.sender:SteamID() or "<INVALID>",
		IsValid(self.receiver) and self.receiver:SteamID() or "<INVALID>",
		self.expiry-CurTime()
	)
end

if SERVER then
	debugCvar = CreateConVar("sf_moneyrequest_verbose_sv", 1, FCVAR_ARCHIVE, "Prints information about money requests to console.", 0, 1)
	local timeoutCvar = CreateConVar("sf_moneyrequest_timeout", 30, FCVAR_ARCHIVE, "Amount of time in seconds until a StarfallEx money request expires.", 5, 600)

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
	
	manager.requests = SF.EntityTable("MoneyRequests")
	function requestClass:accept()
		local sender, receiver, amount, instance = self.sender, self.receiver, self.amount, self.instance
		if sender:canAfford(amount) then
			printDebug("SF: Accepted money request.", self)
			DarkRP.payPlayer(sender, receiver, amount)
			if self.callbackSuccess then
				instance:runFunction(self.callbackSuccess, self.message, instance.Types.Player.Wrap(sender), amount)
			end
		else
			printDebug("SF: Attempted to accept money request but the sender couldn't afford it.", self)
		end
	end
	function requestClass:decline()
		printDebug("SF: Declined money request.", self)
		if self.callbackFailure then
			self.instance:runFunction(self.callbackFailure, "REQUEST_DENIED")
		end
	end
	function requestClass:send()
		net.Start("sf_moneyrequest2")
			net.WriteEntity(self.receiver)
			net.WriteUInt(self.amount, 32)
			net.WriteFloat(self.expiry)
			if self.message then
				net.WriteUInt(#self.message, 8)
				net.WriteData(self.message)
			else
				net.WriteUInt(0, 8)
			end
		net.Send(self.sender)
	end
	
	function manager:exists(sender, receiver)
		return self.requests[sender] ~= nil and self.requests[sender][receiver] ~= nil
	end
	function manager:add(sender, receiver, amount, message, instance, callbackSuccess, callbackFailure)
		if next(self.requests) == nil then hook.Add("Think", "SF_DarkRpMoneyRequests", function() self:think() end) end

		local requestsForSender = self.requests[sender]
		if not requestsForSender then
			requestsForSender = {}
			self.requests[sender] = requestsForSender
		end

		local expiry = CurTime()+timeoutCvar:GetFloat()

		local request = requestClass:new(sender, receiver, amount, message, expiry, instance, callbackSuccess, callbackFailure)
		requestsForSender[receiver] = request
		
		request:send()
		printDebug("SF: Sent a money request.", request)
	end
	function manager:think()
		local now = CurTime()
		for sender, requestsForPlayer in pairs(self.requests) do
			if IsValid(sender) then
				for receiver, request in pairs(requestsForPlayer) do
					if not IsValid(receiver) then
						self:pop(sender, receiver, true)
						printDebug("SF: Removed money request because the receiver was invalid.", request)
						if request.callbackFailure then
							request.instance:runFunction(request.callbackFailure, "RECEIVER_INVALID")
						end
					elseif now >= request.expiry+5 then
						self:pop(sender, receiver, true)
						printDebug("SF: Removed money request because it expired.", request)
						if request.callbackFailure then
							request.instance:runFunction(request.callbackFailure, "REQUEST_TIMEOUT")
						end
					end
				end
			else
				for receiver, request in pairs(requestsForPlayer) do
					self:pop(sender, receiver, true)
					if request.callbackFailure then
						request.instance:runFunction(request.callbackFailure, "SENDER_INVALID")
					end
				end
			end
		end
	end
	function manager:pop(sender, receiver, force)
		local requestsForPlayer = self.requests[sender]
		if not requestsForPlayer then return end
		
		local request = requestsForPlayer[receiver]
		-- Don't pop an expired request
		if not force and (request and request.expiry < CurTime()) then return end
		requestsForPlayer[receiver] = nil
		
		if next(requestsForPlayer) == nil then
			self.requests[sender] = nil
			if next(self.requests) == nil then hook.Remove("Think", "SF_DarkRpMoneyRequests") end
		end
		
		if not request then return end
		if request.instance and request.instance.error then
			printDebug("SF: Attempted to pop money request but the instance was dead.", request)
			return
		end
		
		return request
	end

	-- Console commands for managing money requests
	local function chatPrint(ply, ...)
		local message = string.format(...)
		if IsValid(ply) and ply:IsPlayer() then
			ply:PrintMessage(HUD_PRINTCONSOLE, message)
		else
			print(message)
		end
	end
	concommand.Add("sf_moneyrequest", function(executor, command, args)
		local sender, action, receiver = tonumber(args[1]), args[2], tonumber(args[3])
		if not sender or not action or not receiver then
			return chatPrint(executor, "sf_moneyrequest: malformed parameters (do \"help sf_moneyrequest\")")
		end
		sender = sender == 0 and executor or Entity(sender)
		if not (IsValid(sender) and sender:IsPlayer()) then
			return chatPrint(executor, "sf_moneyrequest: invalid sender")
		end
		receiver = Entity(receiver)
		if not (IsValid(receiver) and receiver:IsPlayer()) then
			return chatPrint(executor, "sf_moneyrequest: invalid receiver")
		end
		if IsValid(executor) and sender ~= executor and not executor:IsSuperAdmin() then
			return chatPrint(executor, "sf_moneyrequest: only superadmins can interact with other people's money requests")
		end
		local request = manager:pop(sender, receiver)
		if request then
			if action == "accept" then
				request:accept()
			elseif action == "decline" then
				request:decline()
			elseif action == "info" then
				chatPrint(executor, tostring(request)) -- TODO: revise
			else
				chatPrint(executor, "sf_moneyrequest: invalid action")
			end
		else
			chatPrint(executor, "sf_moneyrequest: no such request")
		end
	end, nil, "Accept, decline, or view info about a StarfallEx money request. Usage: sf_moneyrequest <entindex or 0> <accept|decline|info> <request index>", FCVAR_CLIENTCMD_CAN_EXECUTE)
else
	debugCvar = CreateConVar("sf_moneyrequest_verbose_cl", 1, FCVAR_ARCHIVE, "Prints information about money requests to console.", 0, 1)

	-- Allow blocking/unblocking money requests from some players, to help mitigate abuse
	SF.BlockedMoneyRequests = SF.BlockedList("moneyrequest", "sending you money requests")

	-- The actual money request prompt itself
	local function createMoneyRequestPanel(receiver, amount, expiry, message)
		local self = vgui.Create("StarfallFrame")
		local w, h = 350, 250
		self:SetSize(w, h)
		self:Center()
		self:SetTitle("StarfallEx money request")
		self:MakePopup()

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
		btnDecline:SetWidth(w*0.5)

		-- In case they disconnect between now and the window closing
		local receiverSteamID = receiver:SteamID()
		local receiverIndex = receiver:EntIndex()

		function btnDecline.DoClick()
			RunConsoleCommand("sf_moneyrequest", 0, "decline", receiverIndex)
			self:Close()
		end
		local btnAccept = vgui.Create("StarfallButton", buttons)
		btnAccept:Dock(RIGHT)
		btnAccept:SetText("Accept (Wait XXX seconds)")
		btnAccept:SetAutoSize(false)
		btnAccept:SetWidth(w*0.5)
		function btnAccept.DoClick()
			RunConsoleCommand("sf_moneyrequest", 0, "accept", receiverIndex)
			self:Close()
		end
		function self:OnClose()
			if blockRequests:GetChecked() then
				SF.BlockedMoneyRequests:block(receiverSteamID)
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
	
	-- Display the money request prompt when notified
	function manager:receive()
		local receiver, amount, expiry, length = net.ReadEntity(), net.ReadUInt(32), net.ReadFloat(), net.ReadUInt(8)
		local message
		if length > 0 then
			message = net.ReadData(length)
		end
		return requestClass:new(LocalPlayer(), receiver, amount, message, expiry)
	end
	net.Receive("sf_moneyrequest2", function()
		local request = manager:receive()
		local receiver, amount, expiry, message = request.receiver, request.amount, request.expiry, request.message
		if not IsValid(receiver) or amount == 0 or expiry <= CurTime() then
			printDebug("SF: Ignoring malformed request.", request)
		end
		printDebug("SF: Received money request.", request)
		if SF.BlockedUsers:isBlocked(receiver:SteamID()) then
			RunConsoleCommand("sf_moneyrequest", 0, "decline", receiver:EntIndex())
			return printDebug("SF: Ignoring money request because the receiver is in \"SF.BlockedUsers\".", request)
		elseif SF.BlockedMoneyRequests:isBlocked(receiver:SteamID()) then
			RunConsoleCommand("sf_moneyrequest", 0, "decline", receiver:EntIndex())
			return printDebug("SF: Ignoring money request because the receiver is in \"SF.BlockedMoneyRequests\".", request)
		end
		createMoneyRequestPanel(receiver, amount, expiry, message)
	end)
end

if SERVER then
	--- Called when a money printer is about to catch fire. DarkRP only. Called between moneyPrinterPrintMoney and moneyPrinterPrinted.
	-- Not guaranteed to work for non-vanilla money printers.
	-- Only works if the owner of the chip also owns the money printer, or if the chip is running in superuser mode.
	-- @name MoneyPrinterCatchFire
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
	-- @name MoneyPrinterPrinted
	-- @class hook
	-- @server
	-- @param Entity moneyprinter The money printer
	-- @param Entity moneybag The moneybag produed by the printer.
	SF.hookAdd("moneyPrinterPrinted", nil, function(instance, moneyprinter, moneybag)
		if not moneyprinter or not moneybag then return false end
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
	-- @name MoneyPrinterPrintMoney
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
	-- @name PlayerWalletChanged
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
	-- @name LockdownEnded
	-- @class hook
	-- @server
	-- @param Player? actor The player who ended the lockdown, or nil.
	SF.hookAdd("lockdownEnded", nil, function(instance, actor)
		if instance.player ~= SF.Superuser and not SF.Permissions.hasAccess(instance, nil, "darkrp.lockdownHooks") then return false end
		return true, {actor and instance.Types.Player.Wrap(actor) or nil}
	end)

	--- Called when a lockdown has started. DarkRP only.
	-- @name LockdownStarted
	-- @class hook
	-- @server
	-- @param Player? actor The player who started the lockdown, or nil.
	SF.hookAdd("lockdownStarted", nil, function(instance, actor)
		if instance.player ~= SF.Superuser and not SF.Permissions.hasAccess(instance, nil, "darkrp.lockdownHooks") then return false end
		return true, {actor and instance.Types.Player.Wrap(actor) or nil}
	end)

	--- Called when a law is added. DarkRP only.
	-- @name AddLaw
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
	-- @name RemoveLaw
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
	-- @name ResetLaws
	-- @class hook
	-- @server
	-- @param Player? player The player resetting the laws.
	SF.hookAdd("resetLaws", nil, function(instance, player)
		if instance.player ~= SF.Superuser and not SF.Permissions.hasAccess(instance, nil, "darkrp.lawHooks") then return false end
		return true, {player and instance.Types.Player.Wrap(player) or nil}
	end)

	--- Called when a player is about to pick a lock. DarkRP only.
	-- Will only be called if the lockpicker is the owner of the chip, or if the chip is running in superuser mode.
	-- @name LockpickStarted
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
	-- @name OnLockpickCompleted
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

if util.NetworkStringToID("sf_moneyrequest") ~= 0 then
	if CLIENT and instance.player == LocalPlayer() then
		print("SF: This server has loganlearner/starfall-darkrp-library installed, which is obsolete as StarfallEx now has a built-in DarkRP library. The built-in library will be disabled. If you experience any problems with DarkRP-specific code, this might be why!")
	end
	return
end

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
	return SF.BlacklistedDarkRPVars[k]==true
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
		if amount <= 0 or amount >= (2^32) then SF.Throw("amount must be positive", 2) return end
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
	-- @param function? callbackSuccess Optional function to call if request succeeds. Args (string: The request message, player: The money sender, number: The amount)
	-- @param function? callbackFailure Optional function to call if request fails. Args (string: why it failed)
	-- @param Player? receiver The player who may or may not receive the money, or the owner of the chip if not specified. Superuser only.
	function darkrp_library.requestMoney(sender, amount, message, callbackSuccess, callbackFailure, receiver)
		checkluatype(amount, TYPE_NUMBER)
		if callbackSuccess ~= nil then checkluatype(callbackSuccess, TYPE_FUNCTION) end
		if callbackFailure ~= nil then checkluatype(callbackFailure, TYPE_FUNCTION) end
		if message ~= nil then
			checkluatype(message, TYPE_STRING)
			if #message > 60 then SF.Throw("Money request message may not exceed 60 bytes", 2) end
		end
		amount = math.ceil(amount)
		if amount <= 0 or amount >= (2^32) then SF.Throw("Amount must be positive", 2) end
		checkpermission(instance, nil, "darkrp.requestMoney")
		sender = getply(sender)

		if instance.player == SF.Superuser then
			receiver = getply(receiver)
		else
			if receiver ~= nil then SF.Throw("Cannot use receive argument if not superuser", 2) end
			receiver = instance.player
		end

		if manager:exists(sender, receiver) then SF.Throw("You already have a pending request for this sender", 2) end
		moneyrequestBurst:use(instance.player, 1)
		manager:add(sender, receiver, amount, message, instance, callbackSuccess, callbackFailure)
	end

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
	-- @param Player? sender Player you intend to ask for money from later (if nil, will only check your money request rate)
	-- @return boolean If you can make another money request
	function darkrp_library.canMakeMoneyRequest(sender)
		if moneyrequestBurst:check(instance.player) < 1 then return false end
		if sender ~= nil then
			if manager:exists(getply(sender), instance.player) then return false end
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
	-- @param Entity ent The door
	-- @return number? The door index, or nil if not a door.
	function darkrp_library.doorIndex(ent)
		return assertsafety(getent(ent):doorIndex())
	end

	--- Get whether this door/vehicle is locked. DarkRP only.
	-- @server
	-- @param Entity ent The door
	-- @return boolean Whether it's locked.
	function darkrp_library.isLocked(ent)
		return assertsafety(getent(ent):isLocked())
	end
end

--- Get the owner of a door. DarkRP only.
-- @param Entity ent The door
-- @return Player? The owner of the door, or nil if the door is unowned.
function darkrp_library.getDoorOwner(ent)
	local owner = getent(ent):getDoorOwner()
	if owner then return plywrap(owner) end
end

--- Get the title of this door or vehicle. DarkRP only.
-- If you don't know what this is referring to, that's because it's not a commonly used feature. Press F2 on a door and click "Set Door Title".
-- @param Entity ent The door
-- @return string? The title of the door or vehicle, or nil if none is set.
function darkrp_library.getKeysTitle(ent)
	return assertsafety(getent(ent):getKeysTitle())
end

--- Get whether this entity is considered a door by DarkRP.
-- @param Entity ent The entity
-- @return boolean Whether it's a door.
function darkrp_library.isDoor(ent)
	return assertsafety(getent(ent):isDoor())
end

--- Get whether this door is owned by someone.
-- @param Entity ent The door
-- @return boolean Whether it's owned.
function darkrp_library.isKeysOwned(ent)
	return assertsafety(getent(ent):isKeysOwned())
end

--- Get whether this door is owned or co-owned by this player.
-- @param Entity ent The door
-- @param Player ply The player to query.
-- @return boolean Whether this door is (co-)owned by the player.
function darkrp_library.isKeysOwnedBy(ent, ply)
	ply = getply(ply)
	return assertsafety(getent(ent):isKeysOwnedBy(ply))
end

--- Get whether this entity is a "money bag", i.e. dropped money from a money printer or /dropmoney. DarkRP only.
-- @param Entity ent The entity
-- @return boolean Whether this entity is a money bag.
function darkrp_library.isMoneyBag(ent)
	return assertsafety(getent(ent):isMoneyBag())
end

--- Get the amount of money in a "money bag" or cheque, or number of items in a dropped item stack. DarkRP only.
-- Equivalent to GLua Entity:Getamount.
-- @param Entity ent The money
-- @return number? Amount of money or number of items
function darkrp_library.getMoneyAmount(ent)
	ent = getent(ent)
	return ent.Getamount and assertsafety(ent:Getamount()) or nil
end

--- Get the number of items remaining in a shipment. DarkRP only.
-- Equivalent to GLua Entity:Getcount.
-- @param Entity ent The shipment
-- @return number? Number of items remaining, or nil if not a shipment
function darkrp_library.getShipmentCount(ent)
	ent = getent(ent)
	return ent.Getcount and assertsafety(ent:Getcount()) or nil
end

--- Get the index of the contents of the shipment, which should then be looked up in the output of "darkrp.getCustomShipments". DarkRP only.
-- Equivalent to GLua Entity:Getcontents.
-- You may prefer to use Entity:getShipmentContents instead, although that function is slightly slower.
-- @param Entity ent The shipment
-- @return number? Index of contents, or nil if not a shipment
function darkrp_library.getShipmentContentsIndex(ent)
	ent = getent(ent)
	return ent.Getcontents and assertsafety(ent:Getcontents()) or nil
end

--- Get the info for the contents of the shipment. DarkRP only.
-- Equivalent to "darkrp.getCustomShipments()[ent:getShipmentContentsIndex()]"
-- @param Entity ent The shipment
-- @return table? Contents, or nil if not a shipment
function darkrp_library.getShipmentContents(ent)
	ent = getent(ent)
	if not CustomShipments or not ent.Getcontents then return end
	return instance.Sanitize(CustomShipments[ent:Getcontents()])
end

-- Player methods

if SERVER then
	--- Unown every door and vehicle owned by this player. DarkRP only.
	-- @server
	-- @param Player ply The player
	function darkrp_library.keysUnOwnAll(ply)
		ply = getply(ply)
		if instance.player ~= SF.Superuser and instance.player ~= ply then SF.Throw("may not use this function on anyone other than owner", 2) return end
		assertsafety(ply:keysUnOwnAll())
	end
	
	--- Returns the time left on a player's team ban. DarkRP only.
	-- Only works if the player is the owner of the chip, or if the chip is running in superuser mode.
	-- @server
	-- @param Player ply The player
	-- @param number? team The number of the job (e.g. TEAM_MEDIC). Uses the player's team if nil.
	-- @return number? The time left on the team ban in seconds, or nil if not banned.
	function darkrp_library.teamBanTimeLeft(ply, team)
		if team ~= nil then checkluatype(team, TYPE_NUMBER) end
		ply = getply(ply)
		if instance.player ~= SF.Superuser and instance.player ~= ply then SF.Throw("may not use this function on anyone other than owner", 2) return end
		return assertsafety(ply:teamBanTimeLeft())
	end
	
	--- Give this player money.
	-- This is subject to a burst limit. Use the darkrp.canGiveMoney function to check if you can request money that tick.
	-- @server
	-- @param Player ply The player
	-- @param number amount The amount of money to give.
	function darkrp_library.giveMoney(ply, amount)
		checkluatype(amount, TYPE_NUMBER)
		amount = math.ceil(amount)
		if amount <= 0 then SF.Throw("amount must be positive", 2) return end
		checkpermission(instance, nil, "darkrp.giveMoney")
		if instance.player:canAfford(amount) then
			givemoneyBurst:use(instance.player, 1)
			DarkRP.payPlayer(instance.player, getply(ply), amount)
		else
			SF.Throw("you can't afford to pay "..DarkRP.formatMoney(amount), 2)
		end
	end
else
	--- Whether this player is in the same room as the LocalPlayer. DarkRP only.
	-- @client
	-- @param Player ply The player
	-- @return boolean Whether this player is in the same room.
	function darkrp_library.isInRoom(ply)
		local bool = getply(ply):isInRoom()
		instance:checkCpu() -- This function could potentially be expensive, so this check is a good idea.
		return assertsafety(bool)
	end
end

--- Get whether the player can afford the given amount of money. DarkRP only.
-- @param Player ply The player
-- @param number amount The amount of money
-- @return boolean Whether the player can afford it
function darkrp_library.canAfford(ply, amount)
	checkluatype(amount, TYPE_NUMBER)
	return assertsafety(getply(ply):canAfford(amount))
end

--- Get whether the player can lock a given door. DarkRP only.
-- @param Player ply The player
-- @param Entity door The door
-- @return boolean? Whether the player is allowed to lock the door. May be nil instead of false.
function darkrp_library.canKeysLock(ply, door)
	return assertsafety(getply(ply):canKeysLock(eunwrap(door)))
end

--- Get whether the player can unlock a given door. DarkRP only.
-- @param Player ply The player
-- @param Entity door The door
-- @return boolean? Whether the player is allowed to unlock the door. May be nil instead of false.
function darkrp_library.canKeysUnlock(ply, door)
	return assertsafety(getply(ply):canKeysUnlock(eunwrap(door)))
end

--- Get the value of a DarkRPVar, which is shared between server and client. Case-sensitive.
-- Possible variables include (but are not limited to): AFK, AFKDemoted, money, salaryRL, rpname, job, HasGunlicense, Arrested, wanted, wantedReason, agenda, zombieToggle, hitTarget, hitPrice, lastHitTime, Energy
-- For money specifically, you may optionally use Player:getMoney instead.
-- Some variables may be blacklisted so that you can't read their value.
-- @param Player ply The player
-- @param string var The name of the variable.
-- @return any The value of the DarkRP var.
function darkrp_library.getDarkRPVar(ply, k)
	checkluatype(k, TYPE_STRING)
	if instance.player ~= SF.Superuser and SF.BlacklistedDarkRPVars[k] then return end
	return assertsafety(getply(ply):getDarkRPVar(k))
end

--- Get the job table of a player. DarkRP only.
-- @param Player ply The player
-- @return table Table with the job information.
function darkrp_library.getJobTable(ply)
	return instance.Sanitize(getply(ply):getJobTable())
end

--- Get a player's pocket items. DarkRP only.
-- @param Player ply The player
-- @return table A table containing information about the items in the pocket.
function darkrp_library.getPocketItems(ply)
	return instance.Sanitize(getply(ply):getPocketItems())
end

--- Get the reason why someone is wanted. DarkRP only.
-- @param Player ply The player
-- @return string? The reason, or nil if not wanted
function darkrp_library.getWantedReason(ply)
	return assertsafety(getply(ply):getWantedReason())
end

--- Whether the player has a certain DarkRP privilege.
-- @param Player ply The player
-- @return boolean Whether the player has the privilege.
function darkrp_library.hasDarkRPPrivilege(ply, priv)
	checkluatype(priv, TYPE_STRING)
	return assertsafety(getply(ply):hasDarkRPPrivilege(priv))
end

--- Whether this player is arrested. DarkRP only.
-- @param Player ply The player
-- @return boolean? Whether this player is arrested. May be nil instead of false.
function darkrp_library.isArrested(ply)
	return assertsafety(getply(ply):isArrested())
end

--- Whether this player is a Chief. DarkRP only.
-- @param Player ply The player
-- @return boolean? Whether this player is a Chief. May be nil instead of false.
function darkrp_library.isChief(ply)
	return assertsafety(getply(ply):isChief())
end

--- Whether this player is a cook. DarkRP only. Only works if hungermod is enabled.
-- @param Player ply The player
-- @return boolean? Whether this player is a cook. May be nil instead of false.
function darkrp_library.isCook(ply)
	return assertsafety(getply(ply):isCook())
end

--- Whether this player is part of the police force (Mayor, CP, Chief). DarkRP only.
-- @param Player ply The player
-- @return boolean Whether this player is a part of the police force.
function darkrp_library.isCP(ply)
	return assertsafety(getply(ply):isCP())
end

--- Whether this player is a hitman. DarkRP only.
-- @param Player ply The player
-- @return boolean? Whether this player is a hitman. May be nil instead of false.
function darkrp_library.isHitman(ply)
	return assertsafety(getply(ply):isHitman())
end

--- Whether this player is the Mayor. DarkRP only.
-- @param Player ply The player
-- @return boolean? Whether this player is the Mayor. May be nil instead of false.
function darkrp_library.isMayor(ply)
	return assertsafety(getply(ply):isMayor())
end

--- Whether this player is a medic. DarkRP only.
-- @param Player ply The player
-- @return boolean? Whether this player is a medic. May be nil instead of false.
function darkrp_library.isMedic(ply)
	return assertsafety(getply(ply):isMedic())
end

--- Whether this player is wanted. DarkRP only. Use Player:getWantedReason if you want to know the reason.
-- @param Player ply The player
-- @return boolean? Whether this player is wanted. May be nil instead of false.
function darkrp_library.isWanted(ply)
	return assertsafety(getply(ply):isWanted())
end

--- Get the amount of money this player has. DarkRP only.
-- Equivalent to "ply:getDarkRPVar('money')"
-- @param Player ply The player
-- @return number? The amount of money, or nil if not accessible.
function darkrp_library.getMoney(ply)
	if instance.player ~= SF.Superuser and SF.BlacklistedDarkRPVars.money then return end
	return assertsafety(getply(ply):getDarkRPVar("money"))
end

end
