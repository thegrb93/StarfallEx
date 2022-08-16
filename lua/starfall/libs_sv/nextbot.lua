local registerprivilege = SF.Permissions.registerPrivilege
local checkluatype = SF.CheckLuaType

--- NextBot type
-- @name NextBot
-- @class type
-- @server
-- @libtbl nb_methods
-- @libtbl nb_meta
SF.RegisterType("NextBot", false, true, debug.getregistry().NextBot, "Entity")

--- Library for spawning NextBots.
-- @name nextbot
-- @server
-- @class library
-- @libtbl nextbot_library
SF.RegisterLibrary("nextbot")

registerprivilege("nextbot.create", "Create nextbot", "Allows the user to create nextbots.")
registerprivilege("nextbot.setGotoPos", "Set nextbot goto pos", "Allows the user to set a vector pos for the nextbot to try and go to.", {entites = {}})
registerprivilege("nextbot.removeGotoPos", "Remove nextbot goto pos", "Allows the user to remove the goto pos from a nextbot.", {entites = {}})
registerprivilege("nextbot.playSequence", "Play nextbot sequence", "Allows the user to set an animation for the nextbot to play.", {entites = {}})
registerprivilege("nextbot.faceTowards", "Face nextbot towards", "Allows the user to make a nextbot face a position.", {entities = {}})
registerprivilege("nextbot.setRunAct", "Set nextbot run activity", "Allows the user to set nextbot's run animation.", {entities = {}})
registerprivilege("nextbot.setIdleAct", "Set nextbot idle activity", "Allows the user to set nextbot's idle animation.", {entities = {}})
registerprivilege("nextbot.setVelocity", "Set nextbot velocity", "Allows the user to set nextbot's velocity.", {entities = {}})
registerprivilege("nextbot.jump", "Nextbot jump", "Allows the user to force a nextbot to jump.", {entities = {}})
registerprivilege("nextbot.addDeathCallback", "Add nextbot death callback", "Allows the user to add a callback function to run when the nextbot dies.", {entities = {}})
registerprivilege("nextbot.removeDeathCallback", "Remove nextbot death callback", "Allows the user to remove a death callback function from the nextbot.", {entities = {}})
registerprivilege("nextbot.addInjuredCallback", "Add nextbot injured callback", "Allows the user to add a callback function to run when the nextbot is injured.", {entities = {}})
registerprivilege("nextbot.removeInjuredCallback", "Remove nextbot injured callback", "Allows the user to remove an on injured callback function from the nextbot.", {entities = {}})
registerprivilege("nextbot.addLandCallback", "Add nextbot land callback", "Allows the user to add a callback function to run when the nextbot lands on the ground.", {entities = {}})
registerprivilege("nextbot.removeLandCallback", "Remove nextbot land callback", "Allows the user to remove an on land callback function from the nextbot.", {entities = {}})
registerprivilege("nextbot.addLeaveGroundCallback", "Add nextbot jump callback", "Allows the user to add a callback function to run when the nextbot leaves the ground.", {entities = {}})
registerprivilege("nextbot.removeLeaveGroundCallback", "Remove nextbot jump callback", "Allows the user to remove an on jump callback function from the nextbot.", {entities = {}})
registerprivilege("nextbot.addContactCallback", "Add contact callback", "Allows the user to add a collision callback to the entity which is called every tick when touched.", {entities = {}, usergroups = {default = 1} } )
registerprivilege("nextbot.removeContactCallback", "Remove nextbot contact callback", "Allows the user to remove the on contact callback from the nextbot.", {entities = {}})
registerprivilege("nextbot.addIgniteCallback", "Add nextbot ignite callback", "Allows the user to add a callback function to run when the nextbot gets set on fire.", {entities = {}})
registerprivilege("nextbot.removeIgniteCallback", "Remove nextbot ignite callback", "Allows the user to remove an on ignite callback function from the nextbot.", {entities = {}})
registerprivilege("nextbot.addNavChangeCallback", "Add nextbot nav change callback", "Allows the user to add a callback function to run when the nextbot changes nav areas.", {entities = {}})
registerprivilege("nextbot.removeNavChangeCallback", "Remove nextbot nav change callback", "Allows the user to remove an on nav change callback function from the nextbot.", {entities = {}})
registerprivilege("nextbot.ragdollOnDeath", "Ragdoll nextbot on death", "Allows the user to set whether the nextbot will ragdoll on death.", {entities = {}})
registerprivilege("nextbot.setMoveSpeed", "Set nextbot movespeed", "Allows the user to set the nextbot's movespeed.", {entities = {}})
registerprivilege("nextbot.setAcceleration", "Set nextbot acceleration", "Allows the user to set the nextbot's acceleration value", {entities = {}})
registerprivilege("nextbot.setDeceleration", "Set nextbot deceleration", "Allows the user to set the nextbot's deceleration value", {entities = {}})
registerprivilege("nextbot.setMaxYawRate", "Set nextbot max yaw rate", "Allows the user to set nextbot's visual turning speed.", {entities = {}})
registerprivilege("nextbot.setGravity", "Set nextbot gravity", "Allows the user to set the nextbot's gravity", {entities = {}})
registerprivilege("nextbot.setDeathDropHeight", "Set nextbot death drop height", "Allows the user to set the height the nextbot is scared to fall from.", {entities = {}})
registerprivilege("nextbot.setJumpHeight", "Set nextbot jump height", "Allows the user to set the nextbot's jump height", {entities = {}})
registerprivilege("nextbot.setStepHeight", "Set nextbot step height", "Allows the user to set the nextbot's step height", {entities = {}})
registerprivilege("nextbot.jumpAcrossGap", "Nextbot jump across gap", "Allows the user to make a nextbot jump across a gap.", {entities = {}})
registerprivilege("nextbot.setClimbAllowed", "Nextbot allow climb", "Allows the user to set whether the nextbot can climb nav ladders.", {entities = {}})
registerprivilege("nextbot.setAvoidAllowed", "Nextbot allow avoid", "Allows the user to set whether the nextbot can try to avoid obstacles.", {entities = {}})
registerprivilege("nextbot.setJumpGapsAllowed", "Nextbot allow jump gaps", "Allows the user to set whether the nextbot can jump gaps.", {entities = {}})

local nbCount = SF.LimitObject("nextbots", "nextbots", 30, "The number of props allowed to spawn via Starfall")

return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local nextbots = {}

local nextbot_library, nb_meta, nb_methods = instance.Libraries.nextbot, instance.Types.NextBot, instance.Types.NextBot.Methods
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local navarea_methods, navarea_meta, navwrap, navunwrap = instance.Types.NavArea.Methods, instance.Types.NavArea, instance.Types.NavArea.Wrap, instance.Types.NavArea.Unwrap
local nbwrap, nbunwrap = instance.Types.NextBot.Wrap, instance.Types.NextBot.Unwrap

local function nextbotOnDestroy(ent)
	local ply = instance.player
	nbCount:free(ply, 1)
	nextbots[ent] = nil
end

local function register(ent)
	ent:CallOnRemove("starfall_nextbot_delete", nextbotOnDestroy)
	nbCount:free(instance.player, -1)
	nextbots[ent] = true
end

instance:AddHook("deinitialize", function()
	for nextbot in pairs(nextbots) do
		nextbot:Remove()
	end
end)

function nb_meta:__tostring()
	return "NextBot"
end

--- Creates a customizable NextBot
-- @server
-- @param Vector spawnpos The position the nextbot will be spawned at.
-- @param string model The model the nextbot will use.
-- @return NextBot The nextbot.
function nextbot_library.create(pos, mdl)
	checkpermission(instance, nil, "nextbot.create")
	checkluatype(mdl, TYPE_STRING)
	local upos = vunwrap(pos)

	local ply = instance.player
	mdl = SF.CheckModel(mdl, ply)
	nbCount:checkuse(ply, 1)

	local nb = ents.Create("starfall_cnextbot")
	register(nb, instance)
	nb:SetPos(upos)
	nb:SetModel(mdl)
	nb.chip = instance.entity
	nb:Spawn()
	nb:SetCreator(ply)
	nextbots[nb] = true

	if CPPI then nb:CPPISetOwner(ply) end

	return nbwrap(nb)
end
	
--- Checks if a user can spawn anymore nextbots.
-- @server
-- @return boolean True if user can spawn nextbots, False if not.
function nextbot_library.canSpawn()
	if not SF.Permissions.hasAccess(instance, nil, "nextbot.create") then return false end
	return nbCount:check(instance.player) > 0
end
	

--- Makes the nextbot try to go to a specified position.
-- @server
-- @param Vector gotopos The position the nextbot will continuosly try to go to.
function nb_methods:setGotoPos(pos)
		local nb = nbunwrap(self)
		checkpermission(instance, nb, "nextbot.setGotoPos")
		nb.goTo = vunwrap(pos)
end

--- Removes the "go to" position from the NextBot.
-- @server
function nb_methods:removeGotoPos()
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.removeGotoPos")
	nb.goTo = nil
end

--- Returns the Vector the nextbot is trying to go to, set by setGotoPos
-- @server
-- @return Vector? Where the nextbot is trying to go to if it exists, else returns nil.
function nb_methods:getGotoPos()
	local nb = nbunwrap(self)
	if nb.goTo then
		return vwrap(nb.goTo)
	else return nil 
	end
end

--- Makes the nextbot play a sequence. This takes priority over movement. Will go to set pos after animation plays.
-- @server
-- @param string seqtoplay The name of the sequence to play.
function nb_methods:playSequence(seq)
	checkluatype(seq, TYPE_STRING)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.playSequence")
	nb.playSeq = seq
end

--- Makes the nextbot face towards a specified position. Has to be called continuously to be effective.
-- @server
-- @param Vector facepos Position to face towards.
function nb_methods:faceTowards(pos)	
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.faceTowards")
	nb.loco:FaceTowards(vunwrap(pos))
end

--- Sets the activity the nextbot uses for running.
-- @server
-- @param number runact The activity the nextbot will use.
function nb_methods:setRunAct(act)
	checkluatype(act, TYPE_NUMBER)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setRunAct")
	nb.RUNACT = act
end

--- Gets the activity the nextbot uses for running.
-- @server
-- @return number The run activity.
function nb_methods:getRunAct()
	local nb = nbunwrap(self)
	return nb.RUNACT
end

--- Sets the activity the nextbot uses for idling.
-- @server
-- @param number runact The activity the nextbot will use.
function nb_methods:setIdleAct(act)
	checkluatype(act, TYPE_NUMBER)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setIdleAct")
	nb.IDLEACT = act
end

--- Gets the activity the nextbot uses for idling.
-- @server
-- @return number The idle activity.
function nb_methods:getIdleAct()
	local nb = nbunwrap(self)
	return nb.IDLEACT
end

--- Sets the nextbot's velocity. Seems to work only when used if nextbot is in air after using nextbot:jump()
-- @server
-- @param Vector newvel Velocity.
function nb_methods:setVelocity(vel)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setVelocity")
	nb.loco:SetVelocity(vunwrap(vel))
end

--- Gets the nextbot's velocity as a vector.
-- @server
-- @return Vector NB's velocity.
function nb_methods:getVelocity()
	local nb = nbunwrap(self)
	return vwrap(nb.loco:GetVelocity())
end

--- Forces the nextbot to jump. Requires the model to have an ACT_JUMP for proper animation.
-- @server
function nb_methods:jump()
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.jump")
	nb.loco:Jump()
end

--- Adds a callback function that will be run when this nextbot dies.
-- @server
-- @param string callbackid The unique ID this callback will use.
-- @param function callback The function to run when the NB dies. The arguments are: (Damage, Attacker, Inflictor, Damage Pos, Damage Force, Damage Type)
function nb_methods:addDeathCallback(id, func)
	checkluatype(id, TYPE_STRING)
	checkluatype(func, TYPE_FUNCTION)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.addDeathCallback")
	nb.DeathCallbacks:add(id, func)
end

--- Removes a death callback function from the NextBot.
-- @server
-- @param string callbackid The unique ID of the callback to remove.
function nb_methods:removeDeathCallback(id)
	checkluatype(id, TYPE_STRING)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.removeDeathCallback")
	nb.DeathCallbacks:remove(id)
end

--- Adds a callback function that will be run when this nextbot is injured.
-- @server
-- @param string callbackid The unique ID this callback will use.
-- @param function callback The function to run when the NB gets injured. The arguments are: (Damage, Attacker, Inflictor, Damage Pos, Damage Force, Damage Type)
function nb_methods:addInjuredCallback(id, func)
	checkluatype(id, TYPE_STRING)
	checkluatype(func, TYPE_FUNCTION)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.addInjuredCallback")
	nb.InjuredCallbacks:add(id, func)
end

--- Removes a injury callback function from the NextBot.
-- @server
-- @param string callbackid The unique ID of the callback to remove.
function nb_methods:removeInjuredCallback(id)
	checkluatype(id, TYPE_STRING)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.removeInjuredCallback")
	nb.InjuredCallbacks:remove(id)
end

--- Adds a callback function that will be run when this nextbot lands on the ground.
-- @server
-- @param string callbackid The unique ID this callback will use.
-- @param function callback The function to run when the NB lands on the ground. The arguments are: (The entity the NB landed on.)
function nb_methods:addLandCallback(id, func)
	checkluatype(id, TYPE_STRING)
	checkluatype(func, TYPE_FUNCTION)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.addLandCallback")
	nb.LandCallbacks:add(id, func)
end

--- Removes a landing callback function from the NextBot.
-- @server
-- @param string callbackid The unique ID of the callback to remove.
function nb_methods:removeLandCallback(id)
	checkluatype(id, TYPE_STRING)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.removeLandCallback")
	nb.LandCallbacks:remove(id)
end

--- Adds a callback function that will be run when this nextbot leaves the ground.
-- @server
-- @param string callbackid The unique ID this callback will use.
-- @param function callback The function to run when the NB leaves the ground. The arguments are: (The entity the NB "jumped" from.)
function nb_methods:addLeaveGroundCallback(id, func)
	checkluatype(id, TYPE_STRING)
	checkluatype(func, TYPE_FUNCTION)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.addLeaveGroundCallback")
	nb.JumpCallbacks:add(id, func)
end

--- Removes a landing callback function from the NextBot.
-- @server
-- @param string callbackid The unique ID of the callback to remove.
function nb_methods:removeLeaveGroundCallback(id)
	checkluatype(id, TYPE_STRING)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.removeLeaveGroundCallback")
	nb.JumpCallbacks:remove(id)
end

--- Adds a callback function that will be run when this nextbot gets ignited.
-- @server
-- @param string callbackid The unique ID this callback will use.
-- @param function callback The function to run when the NB gets ignited.
function nb_methods:addIgniteCallback(id, func)
	checkluatype(id, TYPE_STRING)
	checkluatype(func, TYPE_FUNCTION)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.addIgniteCallback")
	nb.IgniteCallbacks:add(id, func)
end

--- Removes a ignite callback function from the NextBot.
-- @server
-- @param string callbackid The unique ID of the callback to remove.
function nb_methods:removeIgniteCallback(id)
	checkluatype(id, TYPE_STRING)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.removeIgniteCallback")
	nb.IgniteCallbacks:remove(id)
end

--- Adds a callback function that will be run when the nextbot enters a new nav area.
-- @server
-- @param string callbackid The unique ID this callback will use.
-- @param function callback The function to run when the NB enters a new nav area. The arguments are: (Old Nav Area, New Nav Area)
function nb_methods:addNavChangeCallback(id, func)
	checkluatype(id, TYPE_STRING)
	checkluatype(func, TYPE_FUNCTION)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.addNavChangeCallback")
	nb.NavChangeCallbacks:add(id, func)
end

--- Removes a nav area change callback function from the NextBot.
-- @server
-- @param string callbackid The unique ID of the callback to remove.
function nb_methods:removeNavChangeCallback(id)
	checkluatype(id, TYPE_STRING)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.removeNavChangeCallback")
	nb.NavChangeCallbacks:remove(id)
end

--- Sets a callback function that will be run when this nextbot touches another entity. Only 1 per NB. Setting a new callback will replace the old one.
-- @server
-- @param string callbackid The unique ID this callback will use.
-- @param function callback The function to run when the NB touches another entity. The arguments are: (The entity the NB touched.)
function nb_methods:addContactCallback(id, func)
	checkluatype(id, TYPE_STRING)
	checkluatype(func, TYPE_FUNCTION)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.addContactCallback")
	nb.ContactCallbacks:add(id, func)
end

--- Removes the contact callback function from the NextBot if present.
-- @server
-- @param string callbackid The unique ID of the callback to remove.
function nb_methods:removeContactCallback(id)
	checkluatype(id, TYPE_STRING)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.removeContactCallback")
	nb.ContactCallbacks:remove(id)
end

--- Enable or disable ragdolling on death for the NextBot.
-- @server
-- @param boolean ragdollondeath Whether the nextbot should ragdoll on death.
function nb_methods:ragdollOnDeath(bool)
	checkluatype(bool, TYPE_BOOL)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.ragdollOnDeath")
	nb.RagdollOnDeath = bool
end

--- Sets the move speed of the NextBot.
-- @server
-- @param number newmovespeed NB's new move speed. Default is 200.
function nb_methods:setMoveSpeed(val)
	checkluatype(val, TYPE_NUMBER)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setMoveSpeed")
	nb.MoveSpeed = val
end

--- Gets the move speed of the NextBot.
-- @server
-- @return number NB's move speed.
function nb_methods:getMoveSpeed()	
	local nb = nbunwrap(self)
	return nb.MoveSpeed
end

--- Sets the acceleration speed of the NextBot.
-- @server
-- @param number newaccel NB's new acceleration. Default is 400
function nb_methods:setAcceleration(val)
	checkluatype(val, TYPE_NUMBER)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setAcceleration")
	nb.loco:SetAcceleration(val)
end

--- Gets the acceleration speed of the NextBot.
-- @server
-- @return number NB's acceleration value.
function nb_methods:getAcceleration()
	local nb = nbunwrap(self)
	return nb.loco:GetAcceleration()
end

--- Sets the deceleration speed of the NextBot.
-- @server
-- @param number newaccel NB's new deceleration. Default is 400
function nb_methods:setDeceleration(val)
	checkluatype(val, TYPE_NUMBER)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setDeceleration")
	nb.loco:SetDeceleration(val)
end

--- Gets the deceleration speed of the NextBot.
-- @server
-- @return number NB's deceleration value.
function nb_methods:getDeceleration()
	local nb = nbunwrap(self)
	return nb.loco:GetDeceleration()
end

--- Gets the max rate at which the NextBot can visually rotate.
-- @server
-- @param number The NextBot's max yaw rate.
function nb_methods:getMaxYawRate()
	local nb = nbunwrap(self)
	return nb.loco:GetMaxYawRate()
end

--- Sets the max rate at which the NextBot can visually rotate. This will not affect moving or pathing.
-- @server
-- @param number newmaxyawrate Desired new maximum yaw rate
function nb_methods:setMaxYawRate(val)
	checkluatype(val, TYPE_NUMBER)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setMaxYawRate")
	nb.loco:SetMaxYawRate(val)
end

--- Gets the gravity of the NextBot.
-- @server
-- @return number The nextbot's current gravity value.
function nb_methods:getGravity()
	local nb = nbunwrap(self)
	return nb.loco:GetGravity()
end

--- Sets the gravity of the NextBot.
-- @server
-- @param number newgravity NB's new gravity. Default is 1000
function nb_methods:setGravity(val)
	checkluatype(val, TYPE_NUMBER)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setGravity")
	nb.loco:SetGravity(val)
end

--- Sets the height the nextbot is scared to fall from.
-- @server
-- @param number newdeathdropheight New height nextbot is afraid of. Default is 200.
function nb_methods:setDeathDropHeight(val)
	checkluatype(val, TYPE_NUMBER)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setDeathDropHeight")
	nb.loco:SetDeathDropHeight(val)
end

--- Gets the height the nextbot is scared to fall from.
-- @server
-- @return number Height nextbot is afraid of.
function nb_methods:getDeathDropHeight()
	local nb = nbunwrap(self)
	return nb.loco:GetDeathDropHeight()
end

--- Sets the max height the bot can step up.
-- @server
-- @param number stepheight Height (default is 18)
function nb_methods:setStepHeight(val)
	checkluatype(val, TYPE_NUMBER)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setStepHeight")
	nb.loco:SetStepHeight(val)
end

--- Gets the max height the bot can step up.
-- @server
-- @return number The max height the bot can step up.
function nb_methods:getStepHeight()
	local nb = nbunwrap(self)
	return nb.loco:GetStepHeight()
end

--- Return unit vector in XY plane describing our direction of motion - even if we are currently not moving
-- @server
-- @return Vector A vector representing the X and Y movement.
function nb_methods:getGroundMotionVector()
	local nb = nbunwrap(self)
	return vwrap(nb.loco:GetGroundMotionVector())
end

--- Returns whether the nextbot this locomotion is attached to is on ground or not.
-- @server
-- @return boolean Whether the nextbot is on ground or not.
function nb_methods:isOnGround()
	local nb = nbunwrap(self)
	return nb.loco:IsOnGround()
end

--- Returns whether this nextbot can reach and/or traverse/move in given NavArea.
-- @server
-- @param NavArea NavArea to check.
-- @return boolean Whether this nextbot can traverse given NavArea.
function nb_methods:isAreaTraversable(nav)
	local nb = nbunwrap(self)
	local unav = navunwrap(nav)
	
	return nb.loco:IsAreaTraversable(unav)
end

--- Sets whether the Nextbot is allowed try to to avoid obstacles or not. This is used during path generation. Works similarly to nb_allow_avoiding convar. By default bots are allowed to try to avoid obstacles.
-- @server
-- @param boolean avoidallowed Whether this bot should be allowed to try to avoid obstacles.
function nb_methods:setAvoidAllowed(val)
	checkluatype(val, TYPE_BOOL)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setAvoidAllowed")
	nb.loco:SetAvoidAllowed(val)
end

--- Returns whether the Nextbot is allowed to avoid obstacles or not.
-- @server
-- @return boolean Whether this bot is allowed to try to avoid obstacles.
function nb_methods:getAvoidAllowed()
	local nb = nbunwrap(self)
	return nb.loco:GetAvoidAllowed()
end

--- Sets whether the Nextbot is allowed to climb or not. This is used during path generation. Works similarly to nb_allow_climbing convar. By default bots are allowed to climb.
-- @server
-- @param boolean climballowed Whether this bot should be allowed to climb.
function nb_methods:setClimbAllowed(val)
	checkluatype(val, TYPE_BOOL)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setClimbAllowed")
	nb.loco:SetClimbAllowed(val)
end

--- Returns whether the Nextbot is allowed to climb or not.
-- @server
-- @return boolean Whether this bot is allowed to climb.
function nb_methods:getClimbAllowed()
	local nb = nbunwrap(self)
	return nb.loco:GetClimbAllowed()
end

--- Sets whether the Nextbot is allowed to jump gaps or not. This is used during path generation. Works similarly to nb_allow_gap_jumping convar. By default bots are allowed to jump gaps.
-- @server
-- @param boolean jumpgapsallowed Whether this bot should be allowed to jump gaps.
function nb_methods:setJumpGapsAllowed(val)
	checkluatype(val, TYPE_BOOL)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setJumpGapsAllowed")
	nb.loco:SetJumpGapsAllowed(val)
end

--- Returns whether the Nextbot is allowed to jump gaps or not.
-- @server
-- @return boolean Whether this bot is allowed to jump gaps.
function nb_methods:getJumpGapsAllowed()
	local nb = nbunwrap(self)
	return nb.loco:GetJumpGapsAllowed()
end

--- Sets the height of the bot's jump
-- @server
-- @param number jumpheight Height (default is 58)
function nb_methods:setJumpHeight(val)
	checkluatype(val, TYPE_NUMBER)
	local nb = nbunwrap(self)
	checkpermission(instance, nb, "nextbot.setJumpHeight")
	nb.loco:SetJumpHeight(val)
end

--- Gets the height of the bot's jump
-- @server
-- @return number Jump height
function nb_methods:getJumpHeight()
	local nb = nbunwrap(self)
	return nb.loco:GetJumpHeight()
end

--- Makes the bot jump across a gap. The bot must be on ground (Entity:isOnGround). Its model must have the ACT_JUMP activity for proper animation.
-- @server
-- @param Vector landGoal The goal the nextbot should aim for.
-- @param Vector landForward Presumably the direction vector the entity should be aiming in when landing.
function nb_methods:jumpAcrossGap(landGoal, landForward)
	local nb = nbunwrap(self)
	local v1, v2 = vunwrap(landGoal), vunwrap(landForward)
	checkpermission(instance, nb, "nextbot.jumpAcrossGap")
	nb.loco:JumpAcrossGap(v1, v2)
end

end
