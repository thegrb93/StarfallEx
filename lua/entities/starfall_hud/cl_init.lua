include("shared.lua")

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	net.Start("starfall_processor_link")
		net.WriteUInt(self:EntIndex(), 16)
	net.SendToServer()
end

function ENT:Draw()
	self:DrawModel()
end
