AddCSLuaFile()

ENT.Base 		= "base_nextbot"
ENT.Spawnable		= false

local ENT_META = FindMetaTable("Entity")
local Ent_GetPos,Ent_GetTable,Ent_InvalidateBoneCache,Ent_SetPoseParameter,Ent_WorldToLocal = ENT_META.GetPos,ENT_META.GetTable,ENT_META.InvalidateBoneCache,ENT_META.SetPoseParameter,ENT_META.WorldToLocal

function ENT:BodyUpdate()
	self:BodyMoveXY()

	local localVel = Ent_WorldToLocal(self, self.loco:GetVelocity() + Ent_GetPos(self))
	Ent_SetPoseParameter(self, "move_yaw", math.deg(math.atan2(localVel.y, localVel.x)))

	if CLIENT then
		Ent_InvalidateBoneCache(self)
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

function ENT:GotoBehavior()
	local ent_tbl = Ent_GetTable(self)

	local startPerfTime = SysTime()
	
	self:StartActivity(ent_tbl.RUNACT)
	ent_tbl.loco:SetDesiredSpeed(ent_tbl.MoveSpeed)

	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( 300 )
	path:SetGoalTolerance( 20 )
	-- Compute the path towards the enemy's position
	path:Compute( self, ent_tbl.goTo )
	addPerf(ent_tbl.instance, startPerfTime)

	if path:IsValid() then
		while ( path:IsValid() and ent_tbl.goTo ) do
			startPerfTime = SysTime()

			if ( path:GetAge() > 1 ) then
				-- Compute the path towards the enemy's position again
				path:Compute(self, ent_tbl.goTo)
			end

			-- This function moves the bot along the path
			path:Update( self )
			addPerf(ent_tbl.instance, startPerfTime)

			-- If we're stuck then call the HandleStuck function and abandon
			if ( ent_tbl.loco:IsStuck() ) then break end
			coroutine.yield()
		end
	end

	self:StartActivity(ent_tbl.IDLEACT)
end

function ENT:ApproachBehavior()
	local ent_tbl = Ent_GetTable(self)

	self:StartActivity(ent_tbl.RUNACT)
	ent_tbl.loco:SetDesiredSpeed(ent_tbl.MoveSpeed)

	while ent_tbl.approachPos and Ent_GetPos(self):DistToSqr(ent_tbl.approachPos) > 20 do
		ent_tbl.loco:Approach(ent_tbl.approachPos, 1)
		coroutine.yield()
	end

	self:StartActivity(ent_tbl.IDLEACT)
end

function ENT:RunBehaviour()
	local ent_tbl = Ent_GetTable(self)
	while true do
		if ent_tbl.playSeq then
			self:PlaySequenceAndWait(ent_tbl.playSeq)
			ent_tbl.playSeq = nil
		elseif ent_tbl.goTo then
			ent_tbl.GotoBehavior(self)
			ent_tbl.goTo = nil
			ent_tbl.ReachCallbacks:run(ent_tbl.instance)
		elseif ent_tbl.approachPos then
			ent_tbl.ApproachBehavior(self)
			ent_tbl.approachPos = nil
			ent_tbl.ReachCallbacks:run(ent_tbl.instance)
		end
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
