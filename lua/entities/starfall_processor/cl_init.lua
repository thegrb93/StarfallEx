include("shared.lua")

DEFINE_BASECLASS("base_gmodentity")

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
	self.name = "Generic ( No-Name )"
	self.OverlayFade = 0
	self.ActiveHuds = {}
	self.reuploadOnReload = false
end

function ENT:OnRemove()
	if self.instance then
		self.instance:runScriptHook("removed")
	end

	-- This is required because snapshots can cause OnRemove to run even if it wasn't removed.
	local instance = self.instance
	if instance then
		timer.Simple(0, function()
			if not self:IsValid() then
				instance:deinitialize()
			end
		end)
	end

	-- This should remove the hook if it existed
	self:SetReuploadOnReload(false)
end

function ENT:GetOverlayText()
	local state = self:GetNWInt("State", 1)
	local clientstr, serverstr
	if self.instance then
		local bufferAvg = self.instance.cpu_average
		clientstr = tostring(math.Round(bufferAvg * 1000000)) .. "us. (" .. tostring(math.floor(bufferAvg / self.instance.cpuQuota * 100)) .. "%)"
	elseif self.error then
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

	local authorstr =  self.author and self.author:Trim() ~= "" and "\nAuthor: " .. self.author or ""

	return "- Starfall Processor -\n[ " .. self.name .. " ]"..authorstr.."\nServer CPU: " .. serverstr .. "\nClient CPU: " .. clientstr
end

function ENT:Think()
	local lookedAt = self:BeingLookedAtByLocalPlayer()
	self.lookedAt = lookedAt

	if lookedAt then
		if self.CustomOverlay then
			halo.Add( { self }, color_white, 1, 1, 1, true, true )
		elseif not self:GetNoDraw() and self:GetColor().a > 0 then
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
	if self.lookedAt then
		self.OverlayFade = math.min(self.OverlayFade + FrameTime()*2, 1)
	else
		self.OverlayFade = math.max(self.OverlayFade - FrameTime()*2, 0)
	end
	if self.OverlayFade > 0 then
		local pos = self:GetPos():ToScreen()

		SF.RT_Material:SetTexture("$basetexture", self.CustomOverlay)
		render.SetMaterial( SF.RT_Material )
		render.DrawQuad( Vector(pos.x-128,pos.y-300,0), Vector(pos.x+128,pos.y-300,0), Vector(pos.x+128,pos.y-44,0), Vector(pos.x-128,pos.y-44,0), Color(255,255,255,self.OverlayFade*255) )
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
		hook.Add("StarfallEditorFileReload", self, function(_, mainfile)
			if not self:DependsOnFile(mainfile) then return end

			SF.Editor.BuildIncludesTable(self.sfdata.mainfile, function(list)
				SF.PushStarfall(self, {files = list.files, mainfile = list.mainfile})
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
	function ENT:DrawTranslucent()
		self:DrawModel()
		Wire_Render(self)
	end
else
	function ENT:DrawTranslucent()
		self:DrawModel()
	end
end

hook.Add("StarfallError", "StarfallErrorReport", function(_, owner, client, main_file, message, traceback, should_notify)
	if not (owner and owner:IsValid()) then return end
	local local_player = LocalPlayer()
	if owner == local_player then
		if not client or client == owner then
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
	net.ReadStarfall(nil, function(ok, sfdata)
		if ok then
			SF.WaitForConditions(function(timedout)
				local proc, owner = Entity(sfdata.procindex), Entity(sfdata.ownerindex)
				if SF.EntIsReady(proc) and proc:GetClass()=="starfall_processor" and SF.EntIsReady(owner) and (owner:IsPlayer() or owner:IsWorld()) then
					sfdata.owner = owner
					proc:Destroy()
					proc:SetupFiles(sfdata)
					return true
				end
			end, 10)
		end
	end)
end)

net.Receive("starfall_processor_link", function()
	local componenti = net.ReadUInt(16)
	local proci = net.ReadUInt(16)
	SF.WaitForConditions(function(timedout)
		local component, proc = Entity(componenti), Entity(proci)
		if SF.EntIsReady(component) and SF.EntIsReady(proc) then
			SF.LinkEnt(component, proc)
			return true
		end
	end, 10)
end)

net.Receive("starfall_processor_kill", function()
	local target = net.ReadEntity()
	if target:IsValid() and target:GetClass()=="starfall_processor" then
		target:Error({message = "Killed by admin", traceback = ""})
	end
end)

net.Receive("starfall_processor_used", function(len)
	local chip = net.ReadEntity()
	local used = net.ReadEntity()
	local activator = net.ReadEntity()
	if not (chip and chip:IsValid()) then return end
	if not (used and used:IsValid()) then return end
	local instance = chip.instance
	if not instance then return end

	instance:runScriptHook("starfallused", instance.WrapObject( activator ), instance.WrapObject( used ))

	if activator == LocalPlayer() and instance.player ~= SF.Superuser and instance.permissionRequest and instance.permissionRequest.showOnUse and not SF.Permissions.permissionRequestSatisfied( instance ) and not IsValid(SF.permPanel) then
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
	if SF.playerInstances[ply] then
		for instance, _ in pairs( SF.playerInstances[ply] ) do
			net.Start( "starfall_processor_kill" )
			net.WriteEntity( instance.entity )
			net.SendToServer()
		end
	end
end, "Admin Only. Terminate a user's starfall chips.", true )
