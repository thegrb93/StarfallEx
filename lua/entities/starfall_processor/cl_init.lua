include("shared.lua")

DEFINE_BASECLASS("base_gmodentity")

local Ent_GetTable = FindMetaTable("Entity").GetTable
local Ent_IsValid = FindMetaTable("Entity").IsValid
local Ent_IsWorld = FindMetaTable("Entity").IsWorld

function ENT:Initialize()
	self.name = "Generic ( No-Name )"
	self.OverlayFade = 0
	self.ActiveHuds = {}
	self.reuploadOnReload = false

	local instance
	SF.CallOnRemove(self, "sf_processor", function()
		instance = self.instance
		self:SetReuploadOnReload(false)
	end,
	function()
		if instance then
			instance:runScriptHook("removed")
			instance:deinitialize()
		end
	end)
end

function ENT:GetOverlayText()
	local ent_tbl = Ent_GetTable(self)
	local state = self:GetNWInt("State", 1)

	local clientstr, serverstr
	if ent_tbl.instance then
		local bufferAvg = ent_tbl.instance.cpu_average
		clientstr = tostring(math.Round(bufferAvg * 1000000)) .. "us. (" .. tostring(math.floor(bufferAvg / ent_tbl.instance.cpuQuota * 100)) .. "%)"
	elseif ent_tbl.error then
		clientstr = "Errored / Terminated"
	else
		clientstr = "None"
	end
	if state == 1 then
		serverstr = tostring(self:GetNWInt("CPUus", 0)) .. "us. (" .. tostring(self:GetNWFloat("CPUpercent", 0)) .. "%)"
	elseif state == 2 then
		serverstr = "Errored"
	else
		serverstr = "None"
	end

	local authorstr =  ent_tbl.author and string.Trim(ent_tbl.author) ~= "" and "\nAuthor: " .. ent_tbl.author or ""

	return "- Starfall Processor -\n[ " .. ent_tbl.name .. " ]"..authorstr.."\nServer CPU: " .. serverstr .. "\nClient CPU: " .. clientstr
end

function ENT:Think()
	local ent_tbl = Ent_GetTable(self)
	local lookedAt = ent_tbl.BeingLookedAtByLocalPlayer(self)
	ent_tbl.lookedAt = lookedAt

	if lookedAt then
		if ent_tbl.CustomOverlay then
			halo.Add( { self }, color_white, 1, 1, 1, true, true )
		elseif not self:GetNoDraw() and select(4, self:GetColor4Part()) > 0 then
			AddWorldTip( self:EntIndex(), self:GetOverlayText(), 0.5, self:GetPos(), self )
			halo.Add( { self }, color_white, 1, 1, 1, true, true )
		end
	end
end

function ENT:SetCustomOverlay(rt)
	self.CustomOverlay = rt

	if rt then
		hook.Add("HUDPaint", self, self.DrawCustomOverlay)
	else
		hook.Remove("HUDPaint", self)
	end
end

function ENT:DrawCustomOverlay()
	local ent_tbl = Ent_GetTable(self)
	if ent_tbl.lookedAt then
		ent_tbl.OverlayFade = math.min(ent_tbl.OverlayFade + FrameTime()*2, 1)
	else
		ent_tbl.OverlayFade = math.max(ent_tbl.OverlayFade - FrameTime()*2, 0)
	end
	if ent_tbl.OverlayFade > 0 then
		local pos = self:GetPos():ToScreen()

		SF.RT_Material:SetTexture("$basetexture", ent_tbl.CustomOverlay)
		render.SetMaterial( SF.RT_Material )
		render.DrawQuad( Vector(pos.x-128,pos.y-300,0), Vector(pos.x+128,pos.y-300,0), Vector(pos.x+128,pos.y-44,0), Vector(pos.x-128,pos.y-44,0), Color(255,255,255,ent_tbl.OverlayFade*255) )
	end
end

---Does this processor reupload on file reload
---@return boolean
function ENT:GetReuploadOnReload()
	return self.reuploadOnReload
end

---Enables/Disables reupload on reload
---@param enabled boolean
function ENT:SetReuploadOnReload(enabled)
	if enabled and not self.reuploadOnReload then
		hook.Add("StarfallEditorFileReload", self, function(_, reloaded_file)
			if not self:DependsOnFile(reloaded_file) then return end
			SF.Editor.BuildIncludesTable(self.sfdata.mainfile, function(files, mainfile)
				SF.PushStarfall(self, {files = files, mainfile = mainfile})
			end,
			function(err)
				SF.AddNotify(LocalPlayer(), err, "ERROR", 7, "ERROR1")
			end)
		end)
	elseif not enabled and self.reuploadOnReload then
		hook.Remove("StarfallEditorFileReload", self)
	end
	self.reuploadOnReload = enabled
end

if WireLib then
	function ENT:DrawTranslucent(flags)
		self:DrawModel(flags)
		Wire_Render(self)
	end
else
	function ENT:DrawTranslucent(flags)
		self:DrawModel(flags)
	end
end

hook.Add("StarfallError", "StarfallErrorReport", function(_, owner, client, main_file, message, traceback, should_notify)
	if not Ent_IsValid(owner) then return end
	local local_player = LocalPlayer()
	if owner == local_player then
		if Ent_IsWorld(client) or client == owner then
			SF.AddNotify(owner, message, "ERROR", 7, "ERROR1")
		elseif client then
			if should_notify then
				SF.AddNotify(owner, string.format("Starfall '%s' errored for player %s", main_file, client:Nick()), "ERROR", 7, "SILENT")
				print(message)
			else
				print(string.format("Starfall '%s' errored for player %s: %s", main_file, client:Nick(), message))
			end
		end

		if #traceback > 0 then
			print(traceback)
		end
	elseif client == local_player then
		print(string.format("Starfall '%s' owned by %s has errored: %s", main_file, owner:Nick(), message))
	end
end)

net.Receive("starfall_processor_download", function(len)
	net.ReadStarfall(nil, function(ok, sfdata, err)
		if ok and Ent_IsValid(sfdata.proc) and (Ent_IsValid(sfdata.owner) or Ent_IsWorld(sfdata.owner)) then
			sfdata.proc:Compile(sfdata)
		elseif Ent_IsValid(sfdata.proc) and Ent_IsValid(sfdata.owner) then
			sfdata.proc.owner = sfdata.owner
			sfdata.proc:Error({message = "Failed to download and initialize client: " .. tostring(err), traceback = "" })
		end
	end)
end)

net.Receive("starfall_processor_link", function()
	local component, proc
	local function link()
		if component and proc then
			SF.LinkEnt(component, proc)
		end
	end
	net.ReadReliableEntity(function(e) component=e link() end)
	net.ReadReliableEntity(function(e) proc=e link() end)
end)

net.Receive("starfall_processor_kill", function()
	local target = net.ReadEntity()
	if Ent_IsValid(target) and target:GetClass()=="starfall_processor" then
		target:Error({message = "Killed", traceback = ""})
	end
end)

net.Receive("starfall_processor_used", function(len)
	local chip = net.ReadEntity()
	local used = net.ReadEntity()
	local activator = net.ReadEntity()
	if not Ent_IsValid(chip) then return end
	if not Ent_IsValid(used) then return end
	local instance = chip.instance
	if not instance then return end

	instance:runScriptHook("starfallused", instance.WrapObject( activator ), instance.WrapObject( used ))

	if activator == LocalPlayer() and instance.player ~= SF.Superuser and instance.permissionRequest and instance.permissionRequest.showOnUse and not SF.Permissions.permissionRequestSatisfied( instance ) and not (SF.permPanel and SF.permPanel:IsValid()) then
		local pnl = vgui.Create("SFChipPermissions")
		if pnl then
			pnl:OpenForChip( chip )
			SF.permPanel = pnl
		end
	end
end)

SF.BlockedUsers = SF.BlockedList("user", "running clientside starfall code", "sf_blockedusers.txt",
	function(steamid)
		local ply = player.GetBySteamID(steamid)
		if not ply then return end
		for k, v in pairs(ents.FindByClass("starfall_processor")) do
			if v.owner == ply and v.instance then
				v:Error({message = "Blocked by user", traceback = ""})
			end
		end
	end,
	function(steamid)
		local ply = player.GetBySteamID(steamid)
		if not ply then return end
		for k, v in pairs(ents.FindByClass("starfall_processor")) do
			if v.owner == ply then
				v:Compile()
			end
		end
	end
)

SF.SteamIDConcommand("sf_kill_cl", function( executor, ply )
	for instance, _ in pairs( SF.playerInstances[ply] ) do
		instance:Error( { message = "Killed by user", traceback = "" } )
	end
end, "Terminates a user's starfall chips clientside.", true)

---Terminates a user's starfall chips. Admin only
SF.SteamIDConcommand("sf_kill", function( executor, ply )
	if not executor:IsAdmin() then return end
	for instance, _ in pairs( SF.playerInstances[ply] ) do
		net.Start( "starfall_processor_kill" )
		net.WriteEntity( instance.entity )
		net.SendToServer()
	end
end, "Admin Only. Terminate a user's starfall chips.", true )
