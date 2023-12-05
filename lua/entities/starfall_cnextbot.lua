AddCSLuaFile()

ENT.Base 		= "base_nextbot"
ENT.Spawnable		= true

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
	self.RagdollOnDeath = true
	self.WALKACT = ACT_WALK
	self.RUNACT = ACT_RUN
	self.IDLEACT = ACT_IDLE
	self.MoveSpeed = 200
	
	self.DeathCallbacks = SF.HookTable()
	self.InjuredCallbacks = SF.HookTable()
	self.LandCallbacks = SF.HookTable()
	self.JumpCallbacks = SF.HookTable()
	self.IgniteCallbacks = SF.HookTable()
	self.NavChangeCallbacks = SF.HookTable()
	self.ContactCallbacks = SF.HookTable()
	self.ReachCallbacks = SF.HookTable()
end

function ENT:ChasePos(options)
	local options = options or {}
	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	-- Compute the path towards the enemy's position
	path:Compute( self, self.goTo )

	if ( !path:IsValid() ) then return "failed" end

	while ( path:IsValid() and self.goTo ) do
		-- Since we are following the player we have to constantly remake the path
		if ( path:GetAge() > 0.1 ) then
			-- Compute the path towards the enemy's position again
			path:Compute(self, self.goTo)
		end
		-- This function moves the bot along the path
		path:Update( self )
		
		if ( options.draw ) then path:Draw() end
		-- If we're stuck then call the HandleStuck function and abandon
		if ( self.loco:IsStuck() ) then
			self:HandleStuck()
			return "stuck"
		end
		coroutine.yield()
	end

	return "ok"
end

function ENT:RunBehaviour()
	while true do
		if self.playSeq then
			self:PlaySequenceAndWait( self.playSeq )
			self.playSeq = nil
		elseif self.goTo then
			self.loco:SetDesiredSpeed(self.MoveSpeed)
			self:StartActivity(self.RUNACT)
			self:ChasePos()
			self:StartActivity(self.IDLEACT)
			self.goTo = nil
			self.ReachCallbacks:run(self.chip.instance)
		elseif self.approachPos then
			self.loco:SetDesiredSpeed(self.MoveSpeed)
			self:StartActivity(self.RUNACT)
			while self.approachPos and self:GetPos():DistToSqr(self.approachPos) > 500 do
				self.loco:Approach(self.approachPos, 1)
				coroutine.yield()
			end
			self:StartActivity(self.IDLEACT)
			self.approachPos = nil
			self.ReachCallbacks:run(self.chip.instance)
		end
		coroutine.wait( 1 )
		coroutine.yield()
	end
end

function ENT:OnInjured(dmginfo)
	if self.InjuredCallbacks:isEmpty() then return end
	local inst = self.chip.instance
	self.InjuredCallbacks:run(inst,
		dmginfo:GetDamage(),
		inst.WrapObject(dmginfo:GetAttacker()),
		inst.WrapObject(dmginfo:GetInflictor()),
		inst.Types.Vector.Wrap(dmginfo:GetDamagePosition()), 
		inst.Types.Vector.Wrap(dmginfo:GetDamageForce()),
		dmginfo:GetDamageType())
end

function ENT:OnKilled(dmginfo)
	if not self.DeathCallbacks:isEmpty() then
		local inst = self.chip.instance
		self.DeathCallbacks:run(inst,
			dmginfo:GetDamage(),
			inst.WrapObject(dmginfo:GetAttacker()),
			inst.WrapObject(dmginfo:GetInflictor()),
			inst.Types.Vector.Wrap(dmginfo:GetDamagePosition()),
			inst.Types.Vector.Wrap(dmginfo:GetDamageForce()),
			dmginfo:GetDamageType())
	end
	if self.RagdollOnDeath then self:BecomeRagdoll(dmginfo) end
end

function ENT:OnLandOnGround(groundent)
	if self.LandCallbacks:isEmpty() then return end
	local inst = self.chip.instance
	self.LandCallbacks:run(inst, inst.WrapObject(groundent))
end

function ENT:OnLeaveGround(groundent)
	if self.JumpCallbacks:isEmpty() then return end
	local inst = self.chip.instance
	self.JumpCallbacks:run(inst, inst.WrapObject(groundent))
end

function ENT:OnIgnite()
	if self.IgniteCallbacks:isEmpty() then return end
	self.IgniteCallbacks:run(self.chip.instance)
end

function ENT:OnNavAreaChanged(old, new)
	if self.NavChangeCallbacks:isEmpty() then return end
	local inst = self.chip.instance
	self.NavChangeCallbacks:run(inst,
		inst.Types.NavArea.Wrap(old),
		inst.Types.NavArea.Wrap(new))
end

function ENT:OnContact(colent)
	if self.ContactCallbacks:isEmpty() then return end
	local inst = self.chip.instance
	self.ContactCallbacks:run(inst, inst.WrapObject(colent))
end
