AddCSLuaFile()

ENT.Base 		= "base_nextbot"
ENT.Spawnable		= false

local ENT_META = FindMetaTable("Entity")
local Ent_GetTable = ENT_META.GetTable

function ENT:BodyUpdate()
	self:BodyMoveXY()

	local localVel = self:WorldToLocal(self.loco:GetVelocity() + self:GetPos())
	self:SetPoseParameter("move_yaw", math.deg(math.atan2(localVel.y, localVel.x)))

	if CLIENT then
		self:InvalidateBoneCache()
	end
end

if CLIENT then return end

function ENT:Initialize()
	local ent_tbl = Ent_GetTable(self)
	ent_tbl.RagdollOnDeath = true
	ent_tbl.WALKACT = ACT_WALK
	ent_tbl.RUNACT = ACT_RUN
	ent_tbl.IDLEACT = ACT_IDLE
	ent_tbl.MoveSpeed = 200
	
	ent_tbl.DeathCallbacks = SF.HookTable()
	ent_tbl.InjuredCallbacks = SF.HookTable()
	ent_tbl.LandCallbacks = SF.HookTable()
	ent_tbl.JumpCallbacks = SF.HookTable()
	ent_tbl.IgniteCallbacks = SF.HookTable()
	ent_tbl.NavChangeCallbacks = SF.HookTable()
	ent_tbl.ContactCallbacks = SF.HookTable()
	ent_tbl.ReachCallbacks = SF.HookTable()
end

local function addPerf(instance, startPerfTime)
	instance.cpu_total = instance.cpu_total + (SysTime() - startPerfTime)
end

function ENT:ChasePos(options)
	local ent_tbl = Ent_GetTable(self)
	local startPerfTime = SysTime()

	local options = options or {}
	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	-- Compute the path towards the enemy's position
	path:Compute( self, ent_tbl.goTo )

	addPerf(ent_tbl.instance, startPerfTime)
	if ( !path:IsValid() ) then return "failed" end

	while ( path:IsValid() and ent_tbl.goTo ) do
		startPerfTime = SysTime()

		-- Since we are following the player we have to constantly remake the path
		if ( path:GetAge() > 0.1 ) then
			-- Compute the path towards the enemy's position again
			path:Compute(self, ent_tbl.goTo)
		end
		-- This function moves the bot along the path
		path:Update( self )
		
		if ( options.draw ) then path:Draw() end
		-- If we're stuck then call the HandleStuck function and abandon
		if ( ent_tbl.loco:IsStuck() ) then
			self:HandleStuck()
			addPerf(ent_tbl.instance, startPerfTime)
			return "stuck"
		end

		addPerf(ent_tbl.instance, startPerfTime)
		coroutine.yield()
	end

	return "ok"
end

function ENT:RunBehaviour()
	local ent_tbl = Ent_GetTable(self)
	while true do
		if ent_tbl.playSeq then
			self:PlaySequenceAndWait( ent_tbl.playSeq )
			ent_tbl.playSeq = nil
		elseif ent_tbl.goTo then
			ent_tbl.loco:SetDesiredSpeed(ent_tbl.MoveSpeed)
			self:StartActivity(ent_tbl.RUNACT)
			self:ChasePos()
			self:StartActivity(ent_tbl.IDLEACT)
			ent_tbl.goTo = nil
			ent_tbl.ReachCallbacks:run(ent_tbl.instance)
		elseif ent_tbl.approachPos then
			ent_tbl.loco:SetDesiredSpeed(ent_tbl.MoveSpeed)
			self:StartActivity(ent_tbl.RUNACT)
			while ent_tbl.approachPos and self:GetPos():DistToSqr(ent_tbl.approachPos) > 500 do
				ent_tbl.loco:Approach(ent_tbl.approachPos, 1)
				coroutine.yield()
			end
			self:StartActivity(ent_tbl.IDLEACT)
			ent_tbl.approachPos = nil
			ent_tbl.ReachCallbacks:run(ent_tbl.instance)
		end
		coroutine.wait( 1 )
		coroutine.yield()
	end
end

function ENT:OnInjured(dmginfo)
	local ent_tbl = Ent_GetTable(self)
	if ent_tbl.InjuredCallbacks:isEmpty() then return end
	local inst = ent_tbl.instance
	ent_tbl.InjuredCallbacks:run(inst,
		dmginfo:GetDamage(),
		inst.WrapObject(dmginfo:GetAttacker()),
		inst.WrapObject(dmginfo:GetInflictor()),
		inst.Types.Vector.Wrap(dmginfo:GetDamagePosition()), 
		inst.Types.Vector.Wrap(dmginfo:GetDamageForce()),
		dmginfo:GetDamageType())
end

function ENT:OnKilled(dmginfo)
	local ent_tbl = Ent_GetTable(self)
	if not ent_tbl.DeathCallbacks:isEmpty() then
		local inst = ent_tbl.instance
		ent_tbl.DeathCallbacks:run(inst,
			dmginfo:GetDamage(),
			inst.WrapObject(dmginfo:GetAttacker()),
			inst.WrapObject(dmginfo:GetInflictor()),
			inst.Types.Vector.Wrap(dmginfo:GetDamagePosition()),
			inst.Types.Vector.Wrap(dmginfo:GetDamageForce()),
			dmginfo:GetDamageType())
	end
	if ent_tbl.RagdollOnDeath then self:BecomeRagdoll(dmginfo) end
end

function ENT:OnLandOnGround(groundent)
	local ent_tbl = Ent_GetTable(self)
	if ent_tbl.LandCallbacks:isEmpty() then return end
	local inst = ent_tbl.instance
	ent_tbl.LandCallbacks:run(inst, inst.WrapObject(groundent))
end

function ENT:OnLeaveGround(groundent)
	local ent_tbl = Ent_GetTable(self)
	if ent_tbl.JumpCallbacks:isEmpty() then return end
	local inst = ent_tbl.instance
	ent_tbl.JumpCallbacks:run(inst, inst.WrapObject(groundent))
end

function ENT:OnIgnite()
	local ent_tbl = Ent_GetTable(self)
	if ent_tbl.IgniteCallbacks:isEmpty() then return end
	ent_tbl.IgniteCallbacks:run(ent_tbl.instance)
end

function ENT:OnNavAreaChanged(old, new)
	local ent_tbl = Ent_GetTable(self)
	if ent_tbl.NavChangeCallbacks:isEmpty() then return end
	local inst = ent_tbl.instance
	ent_tbl.NavChangeCallbacks:run(inst,
		inst.Types.NavArea.Wrap(old),
		inst.Types.NavArea.Wrap(new))
end

function ENT:OnContact(colent)
	local ent_tbl = Ent_GetTable(self)
	if ent_tbl.ContactCallbacks:isEmpty() then return end
	local inst = ent_tbl.instance
	ent_tbl.ContactCallbacks:run(inst, inst.WrapObject(colent))
end
