-- Global to all starfalls

return function(instance)

-- This function is called as a "pre-main-file" function by instance.lua if the "@tscm" directive is supplied.
function instance.enableTSCMCompatibility()
	-- For obvious safety reasons, all functions here should not perform any direct actions.
	-- This is effectively an emulation layer, though it might intervene when necessary.
	-- For reference, see https://teamscm.co.uk/sfdoc/libraries/ents.html
	local env = instance.env

	-- New libraries
	env.ents = env.ents or {}
	env.ents.entity = env.entity
	env.ents.owner = env.owner
	env.ents.player = env.player
	env.ents.self = env.chip

	env.time = env.time or {}
	env.time.curTime = env.timer.curtime
	env.time.destroyTimer = env.timer.remove
	env.time.exists = env.timer.exists
	env.time.frameTime = env.timer.frametime
	env.time.realTime = env.timer.realtime
	env.time.stimer = env.timer.simple
	env.time.sysTime = env.timer.systime
	env.time.timer = env.timer.create

	-- Entity
	local ents_methods, ent_meta, ewrap, eunwrap = instance.Types.Entity.Methods, instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
	ents_methods.class = ents_methods.getClass
	ents_methods.pos = ents_methods.getPos
	ents_methods.ang = ents_methods.getAngles
	ents_methods.owner = ents_methods.getOwner

end

end

