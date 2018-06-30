include("shared.lua")

DEFINE_BASECLASS("base_gmodentity")

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
	self.name = "Generic ( No-Name )"
end

function ENT:OnRemove ()
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
	return "- Starfall Processor -\n[ " .. self.name .. " ]\nServer CPU: " .. serverstr .. "\nClient CPU: " .. clientstr
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

net.Receive("starfall_processor_download", function (len)

	net.ReadStarfall(nil, function(ok, sfdata)
		if sfdata.proc:IsValid() and sfdata.owner:IsValid() then
		    if ok then
			    sfdata.proc:SetupFiles(sfdata)
		    end
		end
	end)

end)

net.Receive("starfall_processor_link", function()
	local component = net.ReadEntity()
	local proc = net.ReadEntity()
	if IsValid(component) and component.LinkEnt then
		component:LinkEnt(proc)
	end
end)

net.Receive( 'starfall_processor_used', function ( len )
	local chip = net.ReadEntity()
	local activator = net.ReadEntity()
	if not IsValid( chip ) then return end
	if chip.link then chip = chip.link end

	if IsValid( chip ) then

		if not chip.instance then return end
		chip.instance:runScriptHook( 'starfallused', SF.WrapObject( activator ) )

		if activator == LocalPlayer() then
			if chip.instance.permissionRequest and chip.instance.permissionRequest.showOnUse and not SF.Permissions.permissionRequestSatisfied( chip.instance ) then
				local pnl = vgui.Create( 'SFChipPermissions' )
				if pnl then pnl:OpenForChip( chip ) end
			end
		end
	end
end )

hook.Add("NetworkEntityCreated", "starfall_chip_reset", function(ent)
	-- Entity may not have its lua table yet so the only way is to check its class
	if not ent.instance and ent:GetClass()=="starfall_processor" then
		net.Start("starfall_processor_download")
		net.WriteEntity(ent)
		net.SendToServer()
	end
end)

