AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

util.AddNetworkString("starfall_custom_prop")

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:PhysicsInitMultiConvex(self.Mesh)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:EnableCustomCollisions(true)
	self:DrawShadow(false)

	self:AddEFlags( EFL_FORCE_CHECK_TRANSMIT )
end

function ENT:EnableCustomPhysics(mode)
	if mode then
		self.customPhysicsMode = mode
		if not self.hasMotionController then
			self:StartMotionController()
			self.hasMotionController = true
		end
	else
		self.customPhysicsMode = nil
		self.customForceMode = nil
		self.customForceLinear = nil
		self.customForceAngular = nil
		self.customShadowForce = nil
		if self.hasMotionController then
			self:StopMotionController()
			self.hasMotionController = false
		end
	end
end

function ENT:PhysicsSimulate(physObj, dt)
	local mode = self.customPhysicsMode
	if mode == 1 then
		return self.customForceAngular, self.customForceLinear, self.customForceMode
	elseif mode == 2 then
		self.customShadowForce.deltatime = dt
		physObj:ComputeShadowControl(self.customShadowForce)
		return SIM_NOTHING
	else
		return SIM_NOTHING
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:TransmitData(recip)
	net.Start("starfall_custom_prop")
	net.WriteUInt(self:EntIndex(), 16)
	net.WriteUInt(self:GetCreationID(), 32)
	local stream = net.WriteStream(self.streamdata, nil, true)
	if recip then net.Send(recip) else net.Broadcast() end
	return stream
end

SF.WaitForPlayerInit(function(ply)
	for k, v in ipairs(ents.FindByClass("starfall_prop")) do
		v:TransmitData(ply)
	end
end)
