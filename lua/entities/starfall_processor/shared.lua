ENT.Type            = "anim"
ENT.Base            = "base_gmodentity"

ENT.PrintName       = "Starfall"
ENT.Author          = "Colonel Thirty Two"
ENT.Contact         = "initrd.gz@gmail.com"
ENT.Purpose         = ""
ENT.Instructions    = ""

ENT.Spawnable       = false

ENT.Starfall        = true
ENT.States          = {
	Normal = 1,
	Error = 2,
	None = 3,
}


function ENT:Compile()
	if self.instance then
		self:Destroy()
	end

	self.error = nil

	if not (self.sfdata and self.sfdata.files and self.sfdata.files[self.sfdata.mainfile]) then return end
	local ok, instance = SF.Instance.Compile(self.sfdata.files, self.sfdata.mainfile, self.owner, self)
	if not ok then self:Error(instance) return end

	if instance.ppdata.scriptnames and instance.mainfile and instance.ppdata.scriptnames[instance.mainfile] then
		self.name = string.sub(tostring(instance.ppdata.scriptnames[instance.mainfile]), 1, 64)
	else
		self.name = "Generic ( No-Name )"
	end

	if instance.ppdata.scriptauthors and instance.mainfile and instance.ppdata.scriptauthors[instance.mainfile] then
		self.author = string.sub(tostring(instance.ppdata.scriptauthors[instance.mainfile]), 1, 64)
	else
		self.author = nil
	end


	self.instance = instance
	instance.runOnError = function(err)
		-- Have to make sure it's valid because the chip can be deleted before deinitialization and trigger errors
		if self:IsValid() then
			self:Error(err)
		end
	end

	local ok, msg, traceback = instance:initialize()
	if not ok then return end

	if SERVER then
		self.ErroredPlayers = {}
		local clr = self:GetColor()
		self:SetColor(Color(255, 255, 255, clr.a))
		self:SetNWInt("State", self.States.Normal)

		if self.Inputs then
			for k, v in pairs(self.Inputs) do
				self:TriggerInput(k, v.Value)
			end
		end
	else
		net.Start("starfall_processor_clinit")
		net.WriteEntity(self)
		net.SendToServer()
	end

	for k, v in ipairs(ents.FindByClass("starfall_screen")) do
		if v.link == self then instance:runScriptHook("componentlinked", instance.WrapObject(v)) end
	end
	for k, v in ipairs(ents.FindByClass("starfall_hud")) do
		if v.link == self then instance:runScriptHook("componentlinked", instance.WrapObject(v)) end
	end
end

function ENT:Destroy()
	local instance = self.instance
	if instance then
		instance:runScriptHook("removed")
		instance:deinitialize()
		self.instance = nil
	end
end

function ENT:SetupFiles(sfdata)
	self.sfdata = sfdata
	self.owner = sfdata.owner
	sfdata.proc = self

	self:Compile()

	if SERVER and self.instance then
		self.sfsenddata = self:GetSendData()
		self.sfownerdata = self.instance and self.instance.ppdata and self.instance.ppdata.owneronly and self:GetSendData(true) or nil

		if self.instance and self.instance.ppdata.models and self.instance.mainfile then
			local model = self.instance.ppdata.models[self.instance.mainfile]
			if model then
				pcall(function() self:SetCustomModel(SF.CheckModel(model, self.owner, true)) end)
			end
		end

		self:SendCode()
	end
end

---Does this chip depend on the script with name `filename`
---@param filename string This is a name like `script1.txt`
---@return boolean depends Does it depend on `filename`
function ENT:DependsOnFile(filename)
	return self.sfdata.files[filename] ~= nil
end

function ENT:GetGateName()
	return self.name
end

function ENT:Error(err)
	self.error = err

	local msg = err.message
	local traceback = err.traceback

	if SERVER then
		self:SetNWInt("State", self.States.Error)
		self:SetColor(Color(255, 0, 0, 255))
		self:SetDTString(0, traceback or msg)
	end

	local newline = string.find(msg, "\n")
	if newline then
		msg = string.sub(msg, 1, newline - 1)
	end

	hook.Run("StarfallError", self, self.owner, CLIENT and LocalPlayer() or false, self.sfdata.mainfile, msg, traceback)
	SF.SendError(self, msg, traceback)

	if self.instance then
		self.instance:deinitialize()
		self.instance = nil
	end

	for inst, _ in pairs(SF.allInstances) do
		inst:runScriptHook("starfallerror", inst.Types.Entity.Wrap(self), inst.Types.Player.Wrap(SERVER and self.owner or LocalPlayer()), msg)
	end
end

local function MenuOpen( ContextMenu, Option, Entity, Trace )
	local ent = Entity
	if Entity:GetClass() == 'starfall_screen' or Entity:GetClass() == "starfall_hud" then
		if not ent.link then return end
		ent = ent.link
	end
	local SubMenu = Option:AddSubMenu()
	SubMenu:AddOption("Restart Clientside", function ()
		ent:Compile()
	end)
	SubMenu:AddOption("Terminate Clientside", function ()
		ent:Error({message = "Terminated", traceback = ""})
	end)
	SubMenu:AddOption("Open Global Permissions", function ()
		SF.Editor.openPermissionsPopup()
	end)

	if ent:GetReuploadOnReload() then
		SubMenu:AddOption("Disable reupload on reload", function ()
			ent:SetReuploadOnReload(false)
		end)
	else
		SubMenu:AddOption("Enable reupload on reload", function ()
			ent:SetReuploadOnReload(true)
		end)
	end

	local instance = ent.instance
	if instance and instance.player ~= SF.Superuser and (instance.permissionRequest and instance.permissionRequest.overrides and table.Count(instance.permissionRequest.overrides) > 0
				or instance.permissionOverrides and table.Count(instance.permissionOverrides) > 0) then
		SubMenu:AddOption("Overriding Permissions", function ()
			local pnl = vgui.Create("SFChipPermissions")
			if pnl then pnl:OpenForChip(ent) end
		end)
	end
end

properties.Add( "starfall", {
	MenuLabel = "StarfallEx",
	Order = 999,
	MenuIcon = "icon16/wrench.png", -- We should create an icon
	Filter = function( self, ent, ply )
		if not (ent and ent:IsValid()) then return false end
		if not gamemode.Call( "CanProperty", ply, "starfall", ent ) then return false end
		return ent.Starfall or ent.link and ent.link.Starfall
	end,
	MenuOpen = MenuOpen,
	Action = function ( self, ent ) end
} )

local hudsToSync = setmetatable({},{__index=function(t,k) local r={} t[k]=r return r end})
local function syncHud(ply, chip, activator, enabled)
	if next(hudsToSync)==nil then
		hook.Add("Think","SF_SyncHud",function()
			for ply, v in pairs(hudsToSync) do
				for chip, tbl in pairs(v) do
					net.Start("starfall_hud_set_enabled")
					net.WriteEntity(ply)
					net.WriteEntity(chip)
					net.WriteEntity(tbl[1])
					net.WriteBool(tbl[2])
					if SERVER then net.Send(ply) else net.SendToServer() end
				end
				hudsToSync[ply] = nil
			end
			hook.Remove("Think","SF_SyncHud")
		end)
	end
	hudsToSync[ply][chip] = {activator or game.GetWorld(), enabled}
end

net.Receive("starfall_hud_set_enabled" , function()
	local ply = net.ReadEntity()
	local chip = net.ReadEntity()
	local activator = net.ReadEntity()
	local enabled = net.ReadBool()
	if ply:IsValid() and ply:IsPlayer() and chip:IsValid() and chip.ActiveHuds then
		SF.EnableHud(ply, chip, activator, enabled, true)
	end
end)

local function runHudHooks(ply, chip, activator, enabled)
	local instance = chip.instance
	if instance then
		instance:runScriptHook(enabled and "hudconnected" or "huddisconnected", instance.WrapObject(activator), instance.WrapObject(ply))
		instance:RunHook(enabled and "starfall_hud_connected" or "starfall_hud_disconnected", activator)
	end
end

local function isVehicleOrHudControlsLocked(activator)
	if activator.locksControls then
		return activator
	end
	activator = SF.HudVehicleLinks[activator]
	if activator then
		for v in pairs(activator) do
			if v.locksControls then
				return v
			end
		end
	end
end

if SERVER then
	function SF.EnableHud(ply, chip, activator, enabled, dontsync)
		local huds = chip.ActiveHuds
		if activator and activator:IsValid() then
			local n = "SF_HUD"..ply:EntIndex()..":"..activator:EntIndex()
			local lockController = isVehicleOrHudControlsLocked(activator)
			local function disconnect(sync)
				huds[ply] = nil
				hook.Remove("EntityRemoved", n)
				ply:SetViewEntity()
				if lockController and lockController:IsValid() and lockController.link and lockController.link:IsValid() then
					net.Start("starfall_lock_control")
						net.WriteEntity(lockController.link)
						net.WriteBool(false)
					net.Send(ply)
				end
				if sync then
					runHudHooks(ply, chip, activator, false)
					syncHud(ply, chip, activator, false)
				end
			end
			if enabled then
				huds[ply] = true
				hook.Add("EntityRemoved",n,function(e) if e==ply or e==activator then disconnect(true) end end)
				if lockController and lockController:IsValid() and lockController.link and lockController.link:IsValid() then
					net.Start("starfall_lock_control")
						net.WriteEntity(lockController.link)
						net.WriteBool(true)
					net.Send(ply)
				end
			else
				disconnect(false)
			end
		else
			if not enabled then ply:SetViewEntity() end
			huds[ply] = enabled or nil
		end
		runHudHooks(ply, chip, activator, enabled)
		if not dontsync then syncHud(ply, chip, activator, enabled) end
	end
else
	local Hint_FirstPrint = true
	function SF.EnableHud(ply, chip, activator, enabled, dontsync)
		enabled = enabled or nil
		local changed = chip.ActiveHuds[ply] ~= enabled
		chip.ActiveHuds[ply] = enabled

		if changed then
			local enabledBy = chip.owner and chip.owner:IsValid() and (" by "..chip.owner:Nick()) or ""
			if enabled then
				if (Hint_FirstPrint) then
					LocalPlayer():ChatPrint("Starfall HUD enabled"..enabledBy..". NOTE: Type 'sf_hud_unlink' in the console to disconnect yourself from all HUDs.")
					Hint_FirstPrint = nil
				else
					LocalPlayer():ChatPrint("Starfall HUD enabled"..enabledBy..".")
				end
			else
				LocalPlayer():ChatPrint("Starfall HUD disconnected"..enabledBy..".")
			end
			runHudHooks(ply, chip, activator, enabled)
			if not dontsync then syncHud(ply, chip, activator, enabled) end
		end
	end

	concommand.Add("sf_hud_unlink", function()
		local ply = LocalPlayer()
		for k, v in ipairs(ents.FindByClass("starfall_processor")) do
			if v.ActiveHuds[ply] then
				SF.EnableHud(ply, v, nil, false)

				if v.instance.permissionOverrides then
					v.instance.permissionOverrides.enablehud = nil
				end
			end
		end
		ply:ChatPrint("Disconnected from all Starfall HUDs.")
	end)
end

function SF.LinkEnt(self, ent, transmit)
	local changed = self.link ~= ent
	if changed then
		local oldlink = self.link
		self.link = ent

		if oldlink and oldlink:IsValid() then
			local instance = oldlink.instance
			if instance then
				instance:runScriptHook("componentunlinked", instance.WrapObject(self))
			end
		end
		if ent and ent:IsValid() then
			local instance = ent.instance
			if instance then
				instance:runScriptHook("componentlinked", instance.WrapObject(self))
			end
		end
	end
	if SERVER and (changed or transmit) then
		net.Start("starfall_processor_link")
		net.WriteUInt(self:EntIndex(), 16)
		net.WriteUInt(ent and ent:IsValid() and ent:EntIndex() or 0, 16)
		if transmit then net.Send(transmit) else net.Broadcast() end
	end
end

