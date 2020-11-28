include("shared.lua")

DEFINE_BASECLASS("base_gmodentity")

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
	self.name = "Generic ( No-Name )"
	self.OverlayFade = 0
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
	if self:GetColor().a == 0 then return "" end
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
		if not self.CustomOverlay then
			AddWorldTip( self:EntIndex(), self:GetOverlayText(), 0.5, self:GetPos(), self )
		end
		halo.Add( { self }, color_white, 1, 1, 1, true, true )
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

	local owner, proc, sfdata
	local function setupFiles()
		if not (owner and (owner:IsValid() or owner:IsWorld())) then return end
		if not (proc and proc:IsValid()) then return end
		if not sfdata then return end
		proc:SetupFiles(sfdata)
	end

	local sfdata = net.ReadStarfall(nil, function(ok, sfdata_)
		if ok then
			sfdata = sfdata_
			setupFiles()
		end
	end)

	SF.WaitForEntity(sfdata.procindex, function(proc_)
		if not (proc.SetupFiles and proc.Destroy) then return end
		proc = proc_
		proc:Destroy()
		setupFiles()
	end)

	SF.WaitForEntity(sfdata.ownerindex, function(owner_)
		owner = owner_
		setupFiles()
	end)

end)

net.Receive("starfall_processor_link", function()
	local component, proc
	
	local function link()
		if IsValid(component) and IsValid(proc) then
			-- https://github.com/Facepunch/garrysmod-issues/issues/3127
			local linkEnt = baseclass.Get(component:GetClass()).LinkEnt
			if linkEnt and proc:GetClass()=="starfall_processor" then
				linkEnt(component, proc)
			end
		end
	end
	
	SF.WaitForEntity(net.ReadUInt(16), function(ent) component = ent link() end)
	SF.WaitForEntity(net.ReadUInt(16), function(ent) proc = ent link() end)
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

	if activator == LocalPlayer() and instance.player ~= SF.Superuser and instance.permissionRequest and instance.permissionRequest.showOnUse and not SF.Permissions.permissionRequestSatisfied( instance ) then
		local pnl = vgui.Create("SFChipPermissions")
		if pnl then pnl:OpenForChip( chip ) end
	end
end)

