include("shared.lua")

DEFINE_BASECLASS("base_gmodentity")

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
	self.CPUpercent = 0
	self.CPUus = 0
	self.name = "Generic ( No-Name )"
end

function ENT:Terminate()
	if self.instance then
		self.instance:deinitialize()
		self.instance = nil
	end
	self.CPUpercent = 0
	self.CPUus = 0
end

function ENT:Restart()
	self:Terminate()
	self.restarting = true
	timer.Simple(0,function()
		net.Start("starfall_processor_download")
			net.WriteEntity(self)
		net.SendToServer()
	end)
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

hook.Add("NetworkEntityCreated", "starfall_chip_reset", function(ent)
	if ent:GetClass()=="starfall_processor" and not ent.instance then
		net.Start("starfall_processor_download")
		net.WriteEntity(ent)
		net.SendToServer()
	end
end)

function ENT:GetOverlayText()
	local state = self:GetNWInt("State", 1)
	local clientstr, serverstr
	if self.instance then
		local bufferAvg = self.instance.cpu_average
		clientstr = tostring(math.Round(bufferAvg * 1000000)) .. "us. (" .. tostring(math.floor(bufferAvg / self.instance.cpuQuota * 100)) .. "%)"
	else
		clientstr = "Errored / Terminated"
	end
	if self.restarting then
			clientstr = "Restarting.."
	end
	if state == 1 then
		serverstr = tostring(self:GetNWInt("CPUus", 0)) .. "us. (" .. tostring(self:GetNWFloat("CPUpercent", 0)) .. "%)"
	elseif state == 2 then
		serverstr = "Errored"
	end
	if serverstr then
		return "- Starfall Processor -\n[ " .. self.name .. " ]\nServer CPU: " .. serverstr .. "\nClient CPU: " .. clientstr
	else
		return "(None)"
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

net.Receive("starfall_processor_download", function (len)

	local dlFiles = {}
	local dlNumFiles = {}
	local dlProc = net.ReadEntity()
	local dlOwner = net.ReadEntity()
	local dlMain = net.ReadString()

	if not dlProc:IsValid() or not dlOwner:IsValid() then return end
	dlProc.owner = dlOwner

	local I = 0
	while I < 256 do
		if net.ReadBit() ~= 0 then break end

		local filename = net.ReadString()

		net.ReadStream(nil, function(data)
			dlNumFiles.Completed = dlNumFiles.Completed + 1
			dlFiles[filename] = data or ""
			if dlProc:IsValid() and dlNumFiles.Completed == dlNumFiles.NumFiles then
				dlProc:Compile(dlOwner, dlFiles, dlMain)
				dlProc.restarting = false
			end
		end)

		I = I + 1
	end

	dlNumFiles.Completed = 0
	dlNumFiles.NumFiles = I
end)

net.Receive("starfall_processor_link", function()
	local component = net.ReadEntity()
	local proc = net.ReadEntity()
	if IsValid(component) and component.LinkEnt then
		component:LinkEnt(proc)
	end
end)
