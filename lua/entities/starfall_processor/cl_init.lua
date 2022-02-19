include("shared.lua")

DEFINE_BASECLASS("base_gmodentity")

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
	self.name = "Generic ( No-Name )"
	self.OverlayFade = 0
	self.ActiveHuds = {}
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
	
	local authorstr =  self.author and self.author:Trim() != "" and "\nAuthor: " .. self.author or ""
	
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

