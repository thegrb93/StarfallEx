local registerprivilege = SF.Permissions.registerPrivilege
local checkluatype = SF.CheckLuaType
local ENT_META = FindMetaTable("Entity")

--- NextBot type
-- @name NextBot
-- @class type
-- @server
-- @libtbl nb_methods
-- @libtbl nb_meta
SF.RegisterType("NextBot", "entity", nil, FindMetaTable("NextBot"), "Entity")

--- Library for spawning NextBots.
-- @name nextbot
-- @server
-- @class library
-- @libtbl nextbot_library
SF.RegisterLibrary("nextbot")

registerprivilege("nextbot.create", "Create a NextBot", "Allows the user to create a NextBot.")
registerprivilege("nextbot.remove", "Remove a NextBot", "Allows the user to remove a NextBot.", {entities = {}})
registerprivilege("nextbot.setGotoPos", "Set NextBot goto pos", "Allows the user to set a vector pos for the NextBot to try and go to.", {entities = {}})
registerprivilege("nextbot.setApproachPos", "NextBot approach goal", "Allows the user to make a NextBot approach a specified Vector.", {entities = {}})
registerprivilege("nextbot.removeApproachPos", "NextBot approach goal", "Allows the user to remove the approach pos from a NextBot.", {entities = {}})
registerprivilege("nextbot.removeGotoPos", "Remove NextBot goto pos", "Allows the user to remove the goto pos from a NextBot.", {entities = {}})
registerprivilege("nextbot.playSequence", "Play NextBot sequence", "Allows the user to set an animation for the NextBot to play.", {entities = {}})
registerprivilege("nextbot.startActivity", "Play NextBot activity", "Allows the user to set an activity for the NextBot to play.", {entities = {}})
registerprivilege("nextbot.faceTowards", "Face NextBot towards", "Allows the user to make a NextBot face a position.", {entities = {}})
registerprivilege("nextbot.setRunAct", "Set NextBot run activity", "Allows the user to set NextBot's run animation.", {entities = {}})
registerprivilege("nextbot.setIdleAct", "Set NextBot idle activity", "Allows the user to set NextBot's idle animation.", {entities = {}})
registerprivilege("nextbot.setVelocity", "Set NextBot velocity", "Allows the user to set NextBot's velocity.", {entities = {}})
registerprivilege("nextbot.jump", "NextBot jump", "Allows the user to force a NextBot to jump.", {entities = {}})
registerprivilege("nextbot.addReachCallback", "Add NextBot approach callback", "Allows the user to add a callback function to run when the NextBot reaches its destination set by setApproachPos.", {entities = {}})
registerprivilege("nextbot.removeReachCallback", "Remove NextBot approach callback", "Allows the user to remove an approach callback function from the NextBot.", {entities = {}})
registerprivilege("nextbot.addDeathCallback", "Add NextBot death callback", "Allows the user to add a callback function to run when the NextBot dies.", {entities = {}})
registerprivilege("nextbot.removeDeathCallback", "Remove NextBot death callback", "Allows the user to remove a death callback function from the NextBot.", {entities = {}})
registerprivilege("nextbot.addRagdollCreationCallback", "Add NextBot ragdoll creation callback", "Allows the user to add a callback function to run when the NextBot create a ragdoll.", {entities = {}})
registerprivilege("nextbot.removeRagdollCreationCallback", "Remove NextBot ragdoll creation callback", "Allows the user to remove a ragdoll creation function from the NextBot.", {entities = {}})
registerprivilege("nextbot.addInjuredCallback", "Add NextBot injured callback", "Allows the user to add a callback function to run when the NextBot is injured.", {entities = {}})
registerprivilege("nextbot.removeInjuredCallback", "Remove NextBot injured callback", "Allows the user to remove an on injured callback function from the NextBot.", {entities = {}})
registerprivilege("nextbot.addLandCallback", "Add NextBot land callback", "Allows the user to add a callback function to run when the NextBot lands on the ground.", {entities = {}})
registerprivilege("nextbot.removeLandCallback", "Remove NextBot land callback", "Allows the user to remove an on land callback function from the NextBot.", {entities = {}})
registerprivilege("nextbot.addLeaveGroundCallback", "Add NextBot jump callback", "Allows the user to add a callback function to run when the NextBot leaves the ground.", {entities = {}})
registerprivilege("nextbot.removeLeaveGroundCallback", "Remove NextBot jump callback", "Allows the user to remove an on jump callback function from the NextBot.", {entities = {}})
registerprivilege("nextbot.addContactCallback", "Add contact callback", "Allows the user to add a collision callback to the entity which is called every tick when touched.", {entities = {}, usergroups = {default = 1} } )
registerprivilege("nextbot.removeContactCallback", "Remove NextBot contact callback", "Allows the user to remove the on contact callback from the NextBot.", {entities = {}})
registerprivilege("nextbot.addIgniteCallback", "Add NextBot ignite callback", "Allows the user to add a callback function to run when the NextBot gets set on fire.", {entities = {}})
registerprivilege("nextbot.removeIgniteCallback", "Remove NextBot ignite callback", "Allows the user to remove an on ignite callback function from the NextBot.", {entities = {}})
registerprivilege("nextbot.addNavChangeCallback", "Add NextBot nav change callback", "Allows the user to add a callback function to run when the NextBot changes nav areas.", {entities = {}})
registerprivilege("nextbot.removeNavChangeCallback", "Remove NextBot nav change callback", "Allows the user to remove an on nav change callback function from the NextBot.", {entities = {}})
registerprivilege("nextbot.ragdollOnDeath", "Ragdoll NextBot on death", "Allows the user to set whether the NextBot will ragdoll on death.", {entities = {}})
registerprivilege("nextbot.setMoveSpeed", "Set NextBot movespeed", "Allows the user to set the NextBot's movespeed.", {entities = {}})
registerprivilege("nextbot.setAcceleration", "Set NextBot acceleration", "Allows the user to set the NextBot's acceleration value", {entities = {}})
registerprivilege("nextbot.setDeceleration", "Set NextBot deceleration", "Allows the user to set the NextBot's deceleration value", {entities = {}})
registerprivilege("nextbot.setMaxYawRate", "Set NextBot max yaw rate", "Allows the user to set NextBot's visual turning speed.", {entities = {}})
registerprivilege("nextbot.setGravity", "Set NextBot gravity", "Allows the user to set the NextBot's gravity", {entities = {}})
registerprivilege("nextbot.setDeathDropHeight", "Set NextBot death drop height", "Allows the user to set the height the NextBot is scared to fall from.", {entities = {}})
registerprivilege("nextbot.setJumpHeight", "Set NextBot jump height", "Allows the user to set the NextBot's jump height", {entities = {}})
registerprivilege("nextbot.setStepHeight", "Set NextBot step height", "Allows the user to set the NextBot's step height", {entities = {}})
registerprivilege("nextbot.jumpAcrossGap", "NextBot jump across gap", "Allows the user to make a NextBot jump across a gap.", {entities = {}})
registerprivilege("nextbot.setClimbAllowed", "NextBot allow climb", "Allows the user to set whether the NextBot can climb nav ladders.", {entities = {}})
registerprivilege("nextbot.setAvoidAllowed", "NextBot allow avoid", "Allows the user to set whether the NextBot can try to avoid obstacles.", {entities = {}})
registerprivilege("nextbot.setJumpGapsAllowed", "NextBot allow jump gaps", "Allows the user to set whether the NextBot can jump gaps.", {entities = {}})

local entList = SF.EntManager("nextbots", "nextbots", 30, "The number of NextBots allowed to spawn via Starfall")

return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end
local Ent_GetTable,Ent_IsValid = ENT_META.GetTable,ENT_META.IsValid

local ents_methods, ent_meta, ewrap, eunwrap = instance.Types.Entity.Methods, instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local nextbot_library, nb_meta, nb_methods = instance.Libraries.nextbot, instance.Types.NextBot, instance.Types.NextBot.Methods
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local navarea_methods, navarea_meta, navwrap, navunwrap = instance.Types.NavArea.Methods, instance.Types.NavArea, instance.Types.NavArea.Wrap, instance.Types.NavArea.Unwrap
local nbwrap, nbunwrap = instance.Types.NextBot.Wrap, instance.Types.NextBot.Unwrap

local vunwrap1, vunwrap2
instance:AddHook("initialize", function()
	nb_meta.__tostring = ent_meta.__tostring
	vunwrap1, vunwrap2 = vec_meta.QuickUnwrap1, vec_meta.QuickUnwrap2
end)

instance:AddHook("deinitialize", function()
	entList:deinitialize(instance, true)
	SF.NextBotRagdolls:deinitialize(instance, true)
end)

--- Creates a customizable NextBot
-- @server
-- @param Vector pos The position the NextBot will be spawned at.
-- @param string mdl The model the NextBot will use.
-- @return NextBot The NextBot.
function nextbot_library.create(pos, mdl)
	checkpermission(instance, nil, "nextbot.create")
	checkluatype(mdl, TYPE_STRING)
	pos = SF.clampPos(vunwrap1(pos))

	local ply = instance.player
	mdl = SF.CheckModel(mdl, ply)
	entList:checkuse(ply, 1)

	local nb
	local ok, err = instance:runExternal(function()
		nb = ents.Create("starfall_cnextbot")
		nb:SetPos(pos)
		nb:SetModel(mdl)
		nb.instance = instance
		nb:Spawn()

		if ply ~= SF.Superuser then
			nb:SetCreator(ply)
		end

		if CPPI then nb:CPPISetOwner(ply == SF.Superuser and NULL or ply) end
	end)
	if not ok then
		if Ent_IsValid(nb) then nb:Remove() end
		SF.Throw("Failed to create entity (" .. tostring(err) .. ")", 2)
	end

	entList:register(instance, nb)
	instance:checkCpu()

	return nbwrap(nb)
end

--- Checks if you can spawn any more nextbots
-- @server
-- @return boolean Returns true if you can spawn NextBots, false if not
function nextbot_library.canSpawn()
	if not SF.Permissions.hasAccess(instance, nil, "nextbot.create") then return false end
	return entList:check(instance.player) > 0
end

--- Checks how many NextBots can be spawned
-- @server
-- @return number Number of NextBots able to be spawned
function nextbot_library.nextbotsLeft()
	if not SF.Permissions.hasAccess(instance,  nil, "nextbot.create") then return 0 end
	return entList:check(instance.player)
end

--- Checks if you can spawn any more NextBot ragdolls
-- @server
-- @return boolean Returns true if you can spawn NextBot ragdolls, false if not
function nextbot_library.canSpawnRagdoll()
	if not SF.Permissions.hasAccess(instance, nil, "nextbot.ragdollOnDeath") then return false end
	return SF.NextBotRagdolls:check(instance.player) > 0
end

--- Returns how many NextBot ragdolls you can spawn
-- @server
-- @return number Amount of NextBot ragdolls that can be spawned
function nextbot_library.ragdollsLeft()
	if not SF.Permissions.hasAccess(instance,  nil, "nextbot.ragdollOnDeath") then return 0 end
	return SF.NextBotRagdolls:check(instance.player)
end

--- Removes the given nextbot.
-- @server
function nb_methods:remove()
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.remove")
	entList:remove(nb)
end

--- Makes the nextbot try to go to a specified position without using navmesh pathfinding (in a straight line).
--- setGotoPos takes priority.
-- @server
-- @param Vector pos The vector we want to get to.
function nb_methods:setApproachPos(pos)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setApproachPos")
	local approachPos = Ent_GetTable(nb).approachPos
	if approachPos then
		approachPos:SetUnpacked(pos[1], pos[2], pos[3])
	else
		Ent_GetTable(nb).approachPos = vunwrap(pos)
	end
end

--- Removes the "approach" position from the NextBot.
-- @server
function nb_methods:removeApproachPos()
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.removeApproachPos")
	Ent_GetTable(nb).approachPos = nil
end

--- Returns the Vector the NextBot is trying to go to, set by setApproachPos
-- @server
-- @return Vector? Where the NextBot is trying to go to if it exists, else returns nil.
function nb_methods:getApproachPos()
	local approachPos = Ent_GetTable(nbunwrap(self)).approachPos
	if approachPos then return vwrap(approachPos) end
end

--- Makes the NextBot try to go to a specified position using navmesh pathfinding.
-- @server
-- @param Vector pos The position the NextBot will continuosly try to go to.
function nb_methods:setGotoPos(pos)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setGotoPos")
	local goTo = Ent_GetTable(nb).goTo
	if goTo then
		goTo:SetUnpacked(pos[1], pos[2], pos[3])
	else
		Ent_GetTable(nb).goTo = vunwrap(pos)
	end
end

--- Removes the "go to" position from the NextBot.
-- @server
function nb_methods:removeGotoPos()
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.removeGotoPos")
	Ent_GetTable(nb).goTo = nil
end

--- Returns the Vector the NextBot is trying to go to, set by setGotoPos
-- @server
-- @return Vector? Where the NextBot is trying to go to if it exists, else returns nil.
function nb_methods:getGotoPos()
	local goTo = Ent_GetTable(nbunwrap(self)).goTo
	if goTo then return vwrap(goTo) end
end

--- Makes the NextBot play a sequence.
-- This takes priority over movement.
-- Will go to set pos after animation plays.
-- @server
-- @param string seq The name of the sequence to play.
function nb_methods:playSequence(seq)
	checkluatype(seq, TYPE_STRING)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.playSequence")
	nb.playSeq = seq
end

--- Start doing an activity (animation).
-- @server
-- @param number act The ACT enum to play.
function nb_methods:startActivity(act)
	checkluatype(act, TYPE_NUMBER)
	checkpermission(instance, nb, "nextbot.startActivity")
	nbunwrap(self):StartActivity(act)
end

--- Makes the NextBot face towards a specified position. Has to be called continuously to be effective.
-- @server
-- @param Vector pos Position to face towards.
function nb_methods:faceTowards(pos)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.faceTowards")
	Ent_GetTable(nb).loco:FaceTowards(vunwrap1(pos))
end

--- Sets the activity the NextBot uses for running.
-- @server
-- @param number act The activity the NextBot will use.
function nb_methods:setRunAct(act)
	checkluatype(act, TYPE_NUMBER)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setRunAct")
	nb.RUNACT = act
	if not (nb.goTo or nb.approachPos) then return end
	nb:StartActivity(act)
end

--- Gets the activity the NextBot uses for running.
-- @server
-- @return number The run activity.
function nb_methods:getRunAct()
	local nb = nbunwrap(self)
	return nb.RUNACT
end

--- Sets the activity the NextBot uses for idling.
-- @server
-- @param number act The activity the NextBot will use.
function nb_methods:setIdleAct(act)
	checkluatype(act, TYPE_NUMBER)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setIdleAct")
	nb.IDLEACT = act
	if nb.goTo or nb.approachPos then return end
	nb:StartActivity(act)
end

--- Gets the activity the NextBot uses for idling.
-- @server
-- @return number The idle activity.
function nb_methods:getIdleAct()
	local nb = nbunwrap(self)
	return nb.IDLEACT
end

--- Sets the NextBot's velocity. Seems to work only when used if NextBot is in air after using NextBot:jump()
-- @server
-- @param Vector vel Velocity.
function nb_methods:setVelocity(vel)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setVelocity")
	Ent_GetTable(nb).loco:SetVelocity(vunwrap1(vel))
end

--- Gets the NextBot's velocity as a vector.
-- @server
-- @return Vector NextBot's velocity.
function nb_methods:getVelocity()
	local nb = nbunwrap(self)
	return vwrap(Ent_GetTable(nb).loco:GetVelocity())
end

--- Forces the NextBot to jump.
-- @server
-- @param number? act The activity ID of the anim to play when jumping.
function nb_methods:jump(act)
	if act ~= nil then checkluatype(act, TYPE_NUMBER) end
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.jump")
	Ent_GetTable(nb).loco:Jump(act)
end

--- Adds a callback function that will be run when this NextBot reaches a destination set by setApproachPos or setGotoPos.
-- @server
-- @param string id The unique ID this callback will use.
-- @param function func The function to run when the NextBot reaches its destination.
function nb_methods:addReachCallback(id, func)
	checkluatype(id, TYPE_STRING)
	checkluatype(func, TYPE_FUNCTION)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.addReachCallback")
	nb.ReachCallbacks:add(id, func)
end

--- Removes a reach callback function from the NextBot.
-- @server
-- @param string id The unique ID of the callback to remove.
function nb_methods:removeReachCallback(id)
	checkluatype(id, TYPE_STRING)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.removeReachCallback")
	nb.ReachCallbacks:remove(id)
end

--- Adds a callback function that will be run when this NextBot dies.
-- @server
-- @param string id The unique ID this callback will use.
-- @param function func The function to run when the NextBot dies. The arguments are:
-- 1. Damage
-- 2. Attacker
-- 3. Inflictor
-- 4. Damage Pos
-- 5. Damage Force
-- 6. Damage Type
function nb_methods:addDeathCallback(id, func)
	checkluatype(id, TYPE_STRING)
	checkluatype(func, TYPE_FUNCTION)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.addDeathCallback")
	nb.DeathCallbacks:add(id, func)
end

--- Removes a death callback function from the NextBot.
-- @server
-- @param string id The unique ID of the callback to remove.
function nb_methods:removeDeathCallback(id)
	checkluatype(id, TYPE_STRING)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.removeDeathCallback")
	nb.DeathCallbacks:remove(id)
end

--- Adds a callback function that will be run when this NextBot is injured.
-- @server
-- @param string id The unique ID this callback will use.
-- @param function func The function to run when the NextBot gets injured. The arguments are:
-- 1. Damage
-- 2. Attacker
-- 3. Inflictor
-- 4. Damage Pos
-- 5. Damage Force
-- 6. Damage Type
function nb_methods:addInjuredCallback(id, func)
	checkluatype(id, TYPE_STRING)
	checkluatype(func, TYPE_FUNCTION)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.addInjuredCallback")
	nb.InjuredCallbacks:add(id, func)
end

--- Removes a injury callback function from the NextBot.
-- @server
-- @param string id The unique ID of the callback to remove.
function nb_methods:removeInjuredCallback(id)
	checkluatype(id, TYPE_STRING)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.removeInjuredCallback")
	nb.InjuredCallbacks:remove(id)
end

--- Adds a callback function that will be run when this NextBot lands on the ground.
-- @server
-- @param string id The unique ID this callback will use.
-- @param function func The function to run when the NextBot lands on the ground. The arguments are:
-- 1. The entity the NextBot landed on.
function nb_methods:addLandCallback(id, func)
	checkluatype(id, TYPE_STRING)
	checkluatype(func, TYPE_FUNCTION)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.addLandCallback")
	nb.LandCallbacks:add(id, func)
end

--- Removes a landing callback function from the NextBot.
-- @server
-- @param string id The unique ID of the callback to remove.
function nb_methods:removeLandCallback(id)
	checkluatype(id, TYPE_STRING)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.removeLandCallback")
	nb.LandCallbacks:remove(id)
end

--- Adds a callback function that will be run when this NextBot leaves the ground.
-- @server
-- @param string id The unique ID this callback will use.
-- @param function func The function to run when the NextBot leaves the ground. The arguments are:
-- 1. The entity the NextBot "jumped" from
function nb_methods:addLeaveGroundCallback(id, func)
	checkluatype(id, TYPE_STRING)
	checkluatype(func, TYPE_FUNCTION)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.addLeaveGroundCallback")
	nb.JumpCallbacks:add(id, func)
end

--- Removes a landing callback function from the NextBot.
-- @server
-- @param string id The unique ID of the callback to remove.
function nb_methods:removeLeaveGroundCallback(id)
	checkluatype(id, TYPE_STRING)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.removeLeaveGroundCallback")
	nb.JumpCallbacks:remove(id)
end

--- Adds a callback function that will be run when this NextBot gets ignited.
-- @server
-- @param string id The unique ID this callback will use.
-- @param function func The function to run when the NextBot gets ignited.
function nb_methods:addIgniteCallback(id, func)
	checkluatype(id, TYPE_STRING)
	checkluatype(func, TYPE_FUNCTION)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.addIgniteCallback")
	nb.IgniteCallbacks:add(id, func)
end

--- Removes a ignite callback function from the NextBot.
-- @server
-- @param string id The unique ID of the callback to remove.
function nb_methods:removeIgniteCallback(id)
	checkluatype(id, TYPE_STRING)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.removeIgniteCallback")
	nb.IgniteCallbacks:remove(id)
end

--- Adds a callback function that will be run when the NextBot enters a new nav area.
-- @server
-- @param string id The unique ID this callback will use.
-- @param function func The function to run when the NextBot enters a new nav area. The arguments are:
-- 1. Old Nav Area
-- 2. New Nav Area
function nb_methods:addNavChangeCallback(id, func)
	checkluatype(id, TYPE_STRING)
	checkluatype(func, TYPE_FUNCTION)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.addNavChangeCallback")
	nb.NavChangeCallbacks:add(id, func)
end

--- Removes a nav area change callback function from the NextBot.
-- @server
-- @param string id The unique ID of the callback to remove.
function nb_methods:removeNavChangeCallback(id)
	checkluatype(id, TYPE_STRING)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.removeNavChangeCallback")
	nb.NavChangeCallbacks:remove(id)
end

--- Sets a callback function that will be run when this NextBot touches another entity. Only 1 per NB.
-- Setting a new callback will replace the old one.
-- @server
-- @param string id The unique ID this callback will use.
-- @param function func The function to run when the NextBot touches another entity. The argument is:
-- 1. The entity the NextBot touched.
function nb_methods:addContactCallback(id, func)
	checkluatype(id, TYPE_STRING)
	checkluatype(func, TYPE_FUNCTION)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.addContactCallback")
	nb.ContactCallbacks:add(id, func)
end

--- Removes the contact callback function from the NextBot if present.
-- @server
-- @param string id The unique ID of the callback to remove.
function nb_methods:removeContactCallback(id)
	checkluatype(id, TYPE_STRING)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.removeContactCallback")
	nb.ContactCallbacks:remove(id)
end

--- Adds a callback function that will be run when the NextBot create a ragdoll.
-- Note: this will be called only if nb:ragdollOnDeath() is set to True
-- @server
-- @param string id The unique ID this callback will use.
-- @param function func The function to run when the NextBot create a ragdoll. The argument is:
-- 1. The ragdoll entity the NextBot created.
function nb_methods:addRagdollCreationCallback(id, func)
	checkluatype(id, TYPE_STRING)
	checkluatype(func, TYPE_FUNCTION)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.addRagdollCreationCallback")
	nb.RagdollCreationCallbacks:add(id, func)
end

--- Removes the ragdoll creation callback function from the NextBot if present.
-- @server
-- @param string id The unique ID of the callback to remove.
function nb_methods:removeRagdollCreationCallback(id)
	checkluatype(id, TYPE_STRING)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.removeRagdollCreationCallback")
	nb.RagdollCreationCallbacks:remove(id)
end

--- Enable or disable ragdolling on death for the NextBot.
-- @server
-- @param boolean bool Whether the NextBot should ragdoll on death.
function nb_methods:ragdollOnDeath(bool)
	checkluatype(bool, TYPE_BOOL)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.ragdollOnDeath")
	nb.RagdollOnDeath = bool
end

--- Sets the move speed of the NextBot.
-- @server
-- @param number val NextBot's new move speed (default: 200)
function nb_methods:setMoveSpeed(val)
	checkluatype(val, TYPE_NUMBER)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setMoveSpeed")
	nb.MoveSpeed = val
	Ent_GetTable(nb).loco:SetDesiredSpeed(val)
end

--- Gets the move speed of the NextBot.
-- @server
-- @return number NextBot's move speed.
function nb_methods:getMoveSpeed()
	local nb = nbunwrap(self)
	return nb.MoveSpeed
end

--- Sets the acceleration speed of the NextBot.
-- @server
-- @param number val NextBot's new acceleration (default: 400)
function nb_methods:setAcceleration(val)
	checkluatype(val, TYPE_NUMBER)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setAcceleration")
	Ent_GetTable(nb).loco:SetAcceleration(val)
end

--- Gets the acceleration speed of the NextBot.
-- @server
-- @return number NextBot's acceleration value.
function nb_methods:getAcceleration()
	local nb = nbunwrap(self)
	return Ent_GetTable(nb).loco:GetAcceleration()
end

--- Sets the deceleration speed of the NextBot.
-- @server
-- @param number val NextBot's new deceleration (default: 400)
function nb_methods:setDeceleration(val)
	checkluatype(val, TYPE_NUMBER)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setDeceleration")
	Ent_GetTable(nb).loco:SetDeceleration(val)
end

--- Gets the deceleration speed of the NextBot.
-- @server
-- @return number NextBot's deceleration value.
function nb_methods:getDeceleration()
	local nb = nbunwrap(self)
	return Ent_GetTable(nb).loco:GetDeceleration()
end

--- Gets the max rate at which the NextBot can visually rotate.
-- @server
-- @return number The NextBot's current maximum yaw rate.
function nb_methods:getMaxYawRate()
	local nb = nbunwrap(self)
	return Ent_GetTable(nb).loco:GetMaxYawRate()
end

--- Sets the max rate at which the NextBot can visually rotate. This will not affect moving or pathing.
-- @server
-- @param number val Desired new maximum yaw rate
function nb_methods:setMaxYawRate(val)
	checkluatype(val, TYPE_NUMBER)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setMaxYawRate")
	Ent_GetTable(nb).loco:SetMaxYawRate(val)
end

--- Gets the gravity of the NextBot.
-- @server
-- @return number The NextBot's current gravity value.
function nb_methods:getGravity()
	local nb = nbunwrap(self)
	return Ent_GetTable(nb).loco:GetGravity()
end

--- Sets the gravity of the NextBot.
-- @server
-- @param number val NextBot's new gravity (default: 1000)
function nb_methods:setGravity(val)
	checkluatype(val, TYPE_NUMBER)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setGravity")
	Ent_GetTable(nb).loco:SetGravity(val)
end

--- Sets the height the NextBot is scared to fall from.
-- @server
-- @param number val New height NextBot is afraid of (default: 200)
function nb_methods:setDeathDropHeight(val)
	checkluatype(val, TYPE_NUMBER)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setDeathDropHeight")
	Ent_GetTable(nb).loco:SetDeathDropHeight(val)
end

--- Gets the height the NextBot is scared to fall from.
-- @server
-- @return number The height the NextBot is afraid of.
function nb_methods:getDeathDropHeight()
	local nb = nbunwrap(self)
	return Ent_GetTable(nb).loco:GetDeathDropHeight()
end

--- Sets the max height the NextBot can step up.
-- @server
-- @param number val Height (default: 18)
function nb_methods:setStepHeight(val)
	checkluatype(val, TYPE_NUMBER)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setStepHeight")
	Ent_GetTable(nb).loco:SetStepHeight(val)
end

--- Gets the max height the NextBot can step up.
-- @server
-- @return number The max height the NextBot can step up.
function nb_methods:getStepHeight()
	local nb = nbunwrap(self)
	return Ent_GetTable(nb).loco:GetStepHeight()
end

--- Return unit vector in XY plane describing our direction of motion - even if we are currently not moving
-- @server
-- @return Vector A vector representing the X and Y movement.
function nb_methods:getGroundMotionVector()
	local nb = nbunwrap(self)
	return vwrap(Ent_GetTable(nb).loco:GetGroundMotionVector())
end

--- Returns whether the NextBot this locomotion is attached to is on ground or not.
-- @server
-- @return boolean Whether the NextBot is on ground or not.
function nb_methods:isOnGround()
	local nb = nbunwrap(self)
	return Ent_GetTable(nb).loco:IsOnGround()
end

--- Returns whether this NextBot can reach and/or traverse/move in given NavArea.
-- @server
-- @param NavArea nav NavArea to check.
-- @return boolean Whether this NextBot can traverse given NavArea.
function nb_methods:isAreaTraversable(nav)
	local nb = nbunwrap(self)
	local unav = navunwrap(nav)

	return Ent_GetTable(nb).loco:IsAreaTraversable(unav)
end

--- Sets whether the NextBot is allowed try to to avoid obstacles or not. This is used during path generation.
-- Works similarly to nb_allow_avoiding convar. By default bots are allowed to try to avoid obstacles.
-- @server
-- @param boolean val Whether this NextBot should be allowed to try to avoid obstacles.
function nb_methods:setAvoidAllowed(val)
	checkluatype(val, TYPE_BOOL)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setAvoidAllowed")
	Ent_GetTable(nb).loco:SetAvoidAllowed(val)
end

--- Returns whether the NextBot is allowed to avoid obstacles or not.
-- @server
-- @return boolean Whether this NextBot is allowed to try to avoid obstacles.
function nb_methods:getAvoidAllowed()
	local nb = nbunwrap(self)
	return Ent_GetTable(nb).loco:GetAvoidAllowed()
end

--- Sets whether the NextBot is allowed to climb or not. This is used during path generation.
-- Works similarly to nb_allow_climbing convar. By default bots are allowed to climb.
-- @server
-- @param boolean val Whether this NextBot should be allowed to climb.
function nb_methods:setClimbAllowed(val)
	checkluatype(val, TYPE_BOOL)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setClimbAllowed")
	Ent_GetTable(nb).loco:SetClimbAllowed(val)
end

--- Returns whether the NextBot is allowed to climb or not.
-- @server
-- @return boolean Whether this NextBot is allowed to climb.
function nb_methods:getClimbAllowed()
	local nb = nbunwrap(self)
	return Ent_GetTable(nb).loco:GetClimbAllowed()
end

--- Sets whether the NextBot is allowed to jump gaps or not. This is used during path generation.
-- Works similarly to nb_allow_gap_jumping convar. By default bots are allowed to jump gaps.
-- @server
-- @param boolean val Whether this NextBot should be allowed to jump gaps.
function nb_methods:setJumpGapsAllowed(val)
	checkluatype(val, TYPE_BOOL)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setJumpGapsAllowed")
	Ent_GetTable(nb).loco:SetJumpGapsAllowed(val)
end

--- Returns whether the NextBot is allowed to jump gaps or not.
-- @server
-- @return boolean Whether this NextBot is allowed to jump gaps.
function nb_methods:getJumpGapsAllowed()
	local nb = nbunwrap(self)
	return Ent_GetTable(nb).loco:GetJumpGapsAllowed()
end

--- Sets the height of the bot's jump
-- @server
-- @param number val Height (default: 58)
function nb_methods:setJumpHeight(val)
	checkluatype(val, TYPE_NUMBER)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setJumpHeight")
	Ent_GetTable(nb).loco:SetJumpHeight(val)
end

--- Gets the height of the bot's jump
-- @server
-- @return number Jump height
function nb_methods:getJumpHeight()
	local nb = nbunwrap(self)
	return Ent_GetTable(nb).loco:GetJumpHeight()
end

--- Makes the NextBot jump across a gap. The NextBot must be on ground (Entity:isOnGround).
-- Its model must have the ACT_JUMP activity for proper animation.
-- @server
-- @param Vector landGoal The goal the NextBot should aim for.
-- @param Vector landForward Presumably the direction vector the entity should be aiming in when landing.
function nb_methods:jumpAcrossGap(landGoal, landForward)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.jumpAcrossGap")
	Ent_GetTable(nb).loco:JumpAcrossGap(vunwrap1(landGoal), vunwrap2(landForward))
end

end
