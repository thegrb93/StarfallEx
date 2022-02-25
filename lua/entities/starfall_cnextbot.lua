AddCSLuaFile()

ENT.Base 			= "base_nextbot"
ENT.Spawnable		= true


-- Had to do some fuckery to get model to set on both realms when the bot is created from a chip
function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "NBModel" )
end

function ENT:Initialize()
	if SERVER then
		self.RagdollOnDeath = true
		self.WALKACT = ACT_WALk
		self.RUNACT = ACT_RUN
		self.IDLEACT = ACT_IDLE
		self.MoveSpeed = 200
		
		self.DeathCallbacks = SF.HookTable()
		self.InjuredCallbacks = SF.HookTable()
		self.LandCallbacks = SF.HookTable()
		self.JumpCallbacks = SF.HookTable()
		self.IgniteCallbacks = SF.HookTable()
		self.NavChangeCallbacks = SF.HookTable()
	end

	self:SetModel( self:GetNBModel() )
	self:ResetModel()
end

function ENT:ResetModel()
	self:SetModel(self:GetNBModel())
end

function ENT:ChasePos(options)
	local options = options or {}
	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	path:Compute( self, self.goTo )		-- Compute the path towards the enemy's position

	if ( !path:IsValid() ) then return "failed" end

	while ( path:IsValid() and self.goTo ) do
	
		if ( path:GetAge() > 0.1 ) then					-- Since we are following the player we have to constantly remake the path
			path:Compute(self, self.goTo)-- Compute the path towards the enemy's position again
		end
		path:Update( self )								-- This function moves the bot along the path
		
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
		end
		
		coroutine.wait( 1 )
		
		coroutine.yield()
	end
	
end

-- TO DO: Maybe look into caching the table counts as I don't know how expensive the counting function is
function ENT:OnInjured(dmginfo)
	if !self.InjuredCallbacks:isEmpty() then
		local inst = self.chip.instance
		for _, v in self.InjuredCallbacks:pairs() do
			inst:runFunction(v, inst.Types.NextBot.Wrap(self), dmginfo:GetDamage(), inst.Types.Entity.Wrap(dmginfo:GetAttacker()), inst.Types.Entity.Wrap(dmginfo:GetInflictor()), inst.Types.Vector.Wrap(dmginfo:GetDamagePosition()), 
			inst.Types.Vector.Wrap(dmginfo:GetDamageForce()), dmginfo:GetDamageType())
		end
	end
end

function ENT:OnKilled(dmginfo)
	if !self.DeathCallbacks:isEmpty() then
		local inst = self.chip.instance
		for _, v in self.DeathCallbacks:pairs() do
			inst:runFunction(v, inst.Types.NextBot.Wrap(self), dmginfo:GetDamage(), inst.Types.Entity.Wrap(dmginfo:GetAttacker()), inst.Types.Entity.Wrap(dmginfo:GetInflictor()), inst.Types.Vector.Wrap(dmginfo:GetDamagePosition()), 
			inst.Types.Vector.Wrap(dmginfo:GetDamageForce()), dmginfo:GetDamageType())
		end
	end
	if self.RagdollOnDeath then self:BecomeRagdoll(dmginfo) end
end

function ENT:OnLandOnGround(groundent)
	if !self.LandCallbacks:isEmpty() then
		local inst = self.chip.instance
		for _, v in self.LandCallbacks:pairs() do
			local wrappedgroundent = inst.Types.Entity.Wrap(groundent)
			inst:runFunction(v, inst.Types.NextBot.Wrap(self), wrappedgroundent)
		end
	end
end

function ENT:OnLeaveGround(groundent)
	if !self.JumpCallbacks:isEmpty() then
		local inst = self.chip.instance
		for _, v in self.JumpCallbacks:pairs() do
			local wrappedgroundent = self.chip.instance.Types.Entity.Wrap(groundent)
			inst:runFunction(v, inst.Types.NextBot.Wrap(self), wrappedgroundent)
		end
	end
end

function ENT:OnIgnite()
	if !self.IgniteCallbacks:isEmpty() then
		local inst = self.chip.instance
		for _, v in self.IgniteCallbacks:pairs() do
			inst:runFunction(v, inst.Types.NextBot.Wrap(self))
		end
	end
end

function ENT:OnNavAreaChanged(old, new)
	if !self.NavChangeCallbacks:isEmpty() then
		local inst = self.chip.instance
		local wrappedold = inst.Types.NavArea.Wrap(old)
		local wrappednew = inst.Types.NavArea.Wrap(new)
		for _, v in self.NavChangeCallbacks:pairs() do
			inst:runFunction(v, inst.Types.NextBot.Wrap(self), wrappedold, wrappednew)
		end
	end
end

-- Only 1 callback because I'm not sure about the performance implications of many callbacks running at once on every collision.
function ENT:OnContact(colent)
	if self.ContactCallback and self.chip.instance then
		local inst = self.chip.instance
		local wrappedcolent = inst.Types.Entity.Wrap(colent)
		self.chip.instance:runFunction(self.ContactCallback, inst.Types.NextBot.Wrap(self), wrappedcolent)
	end
end

function ENT:BodyUpdate()
	self:BodyMoveXY()
	
	local velForw = self:EyeAngles():Forward():Dot(self.loco:GetVelocity())
	local velRight = self:EyeAngles():Right():Dot(self.loco:GetVelocity())
	local range = math.atan2(-velRight, velForw) / math.pi
	local remappedRange = math.Remap(range, -1, 1, -180, 180)
	self:SetPoseParameter("move_yaw", remappedRange )
	
	if CLIENT then
	self:InvalidateBoneCache()
	end
end
