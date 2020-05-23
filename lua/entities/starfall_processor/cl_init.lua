include("shared.lua")

DEFINE_BASECLASS("base_gmodentity")

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
	self.name = "Generic ( No-Name )"
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
		if sfdata.proc:IsValid() then
			if ok then
				if sfdata.owner:IsValid() or sfdata.owner==NULL then
					sfdata.proc:SetupFiles(sfdata)
					if sfdata.proc.instance then
						net.Start("starfall_processor_download")
						net.WriteEntity(sfdata.proc)
						net.WriteBool(false)
						net.SendToServer()
					end
				end
			else
				net.Start("starfall_processor_download")
				net.WriteEntity(sfdata.proc)
				net.WriteBool(true)
				net.SendToServer()
			end
		end
	end)

end)

net.Receive("starfall_processor_link", function()
	local component, proc
	
	local function link()
		if IsValid(component) and IsValid(proc) then
			-- https://github.com/Facepunch/garrysmod-issues/issues/3127
			local linkEnt = baseclass.Get(component:GetClass()).LinkEnt
			linkEnt(component, proc)
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

	if activator == LocalPlayer() and chip.owner ~= NULL and instance.permissionRequest and instance.permissionRequest.showOnUse and not SF.Permissions.permissionRequestSatisfied( instance ) then
		local pnl = vgui.Create("SFChipPermissions")
		if pnl then pnl:OpenForChip( chip ) end
	end
end)

net.Receive("starfall_processor_destroy", function(len)
	local proc = net.ReadEntity()
	if proc:IsValid() then
		proc:Destroy()
	end
end)

