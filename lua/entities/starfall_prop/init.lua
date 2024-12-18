AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

util.AddNetworkString("starfall_custom_prop")

local ENT_META = FindMetaTable("Entity")
local Ent_GetTable = ENT_META.GetTable

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:PhysicsInitMultiConvex(self.Mesh)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:EnableCustomCollisions(true)
	self:DrawShadow(false)

	self.customForceMode = 0
	self.customForceLinear = Vector()
	self.customForceAngular = Vector()
	self.customShadowForce = {
		pos = Vector(),
		angle = Angle(),
		secondstoarrive = 1,
		dampfactor = 0.2,
		maxangular = 1000,
		maxangulardamp = 1000,
		maxspeed = 1000,
		maxspeeddamp = 1000,
		teleportdistance = 1000,
	}

	self:AddEFlags( EFL_FORCE_CHECK_TRANSMIT )
end

function ENT:EnableCustomPhysics(mode)
	local ent_tbl = Ent_GetTable(self)
	if mode then
		ent_tbl.customPhysicsMode = mode
		if not ent_tbl.hasMotionController then
			self:StartMotionController()
			ent_tbl.hasMotionController = true
		end
	else
		ent_tbl.customPhysicsMode = nil
		if ent_tbl.hasMotionController then
			self:StopMotionController()
			ent_tbl.hasMotionController = false
		end
	end
end

function ENT:PhysicsSimulate(physObj, dt)
	local ent_tbl = Ent_GetTable(self)
	local mode = ent_tbl.customPhysicsMode
	if mode == 1 then
		return ent_tbl.customForceAngular, ent_tbl.customForceLinear, ent_tbl.customForceMode
	elseif mode == 2 then
		ent_tbl.customShadowForce.deltatime = dt
		physObj:ComputeShadowControl(ent_tbl.customShadowForce)
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
	net.WriteReliableEntity(self)
	local stream = net.WriteStream(self.streamdata, nil, true)
	if recip then net.Send(recip) else net.Broadcast() end
	return stream
end

SF.WaitForPlayerInit(function(ply)
	for k, v in ipairs(ents.FindByClass("starfall_prop")) do
		v:TransmitData(ply)
	end
end)
