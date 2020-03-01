local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check
local registerprivilege = SF.Permissions.registerPrivilege
local IsValid = IsValid

-- Create permission types.
registerprivilege("particle.attach", "Allow users to create particle", { client = {}, entities = {} })


--- Particle library.
-- @name particle
-- @class library
-- @libtbl particle_library
SF.RegisterLibrary("particle")

--- Particle type
-- @name Particle
-- @class type
-- @libtbl particle_methods
SF.RegisterType("Particle", false, false)


return function(instance)

local getent
instance:AddHook("initialize", function()
	instance.data.particle = {
		particles = {},
	}

	getent = instance.Types.Entity.GetEntity
end)

instance:AddHook("deinitialize", function()
	local particles = instance.data.particle.particles
	local p = next(particles)
	-- Remove all
	while p do
		if p:IsValid() then
			p:StopEmissionAndDestroyImmediately()
		end
		particles[p] = nil
		p = next(particles)
	end
end)

local particle_library = instance.Libraries.particle
local particle_methods = instance.Types.Particle.Methods

local particle_meta, wrap, unwrap = instance.Types.Particle, instance.Types.Particle.Wrap, instance.Types.Particle.Unwrap
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap


-- Add PATTACH enum
local _PATTACH = {
	["ABSORIGIN"] = PATTACH_ABSORIGIN,
	["ABSORIGIN_FOLLOW"] =  PATTACH_ABSORIGIN_FOLLOW,
	["CUSTOMORIGIN"] =  PATTACH_CUSTOMORIGIN,
	["POINT"] = PATTACH_POINT,
	["POINT_FOLLOW"] = PATTACH_POINT_FOLLOW,
	["WORLDORIGIN"] =  PATTACH_WORLDORIGIN,
}
instance.env.PATTACH = _PATTACH


local function badParticle(flags) -- implemented for future use in case anything is found to be unfriendly.
	return false
end

local function checkValid(emitter)
	if not (emitter and emitter:IsValid()) then
		SF.Throw("Particle emitter is no longer valid.", 2)
	end
end


--- Attaches a particle to an entity.
-- @param entity Entity to attach to
-- @param particle Name of the particle
-- @param pattach PATTACH enum
-- @param options Table of options
-- @return Particle type.
function particle_library.attach(entity, particle, pattach, options)
	checkpermission (instance.player, entity, "particle.attach")

	checkluatype (particle, TYPE_STRING)
	checkluatype (pattach, TYPE_NUMBER)
	checkluatype (options, TYPE_TABLE)

	local entity = getent(entity)

	if badParticle(particle) then
		SF.Throw("Invalid particle path: " .. particle, 2)
	end



	local PEffect = entity:CreateParticleEffect(particle,pattach,options)

	if not (PEffect and PEffect:IsValid()) then
		SF.Throw("Invalid particle system.", 2)
	end

	instance.data.particle.particles[PEffect] = true

	return wrap(PEffect)

end


--- Gets if the particle is valid or not.
-- @return Is valid or not
function particle_methods:isValid()
	local uw = unwrap(self)

	return uw and uw:IsValid()

end

--- Starts emission of the particle.
function particle_methods:startEmission()
	local uw = unwrap(self)

	checkValid(uw)

	uw:StartEmission()


end


--- Stops emission of the particle.
function particle_methods:stopEmission()
	local uw = unwrap(self)

	checkValid(uw)

	uw:StopEmission()


end

--- Stops emission of the particle and destroys the object.
function particle_methods:destroy()
	local uw = unwrap(self)

	if (uw and uw:IsValid()) then
		uw:StopEmissionAndDestroyImmediately()
	end

end

--- Restarts emission of the particle.
function particle_methods:restart()
	local uw = unwrap(self)

	checkValid(uw)

	uw:Restart()


end


--- Restarts emission of the particle.
-- @return bool finished
function particle_methods:isFinished()
	local uw = unwrap(self)

	if (uw and uw:IsValid()) then
		return uw:isFinished()
	end

	return true

end


--- Sets the sort origin for given particle system. This is used as a helper to determine which particles are in front of which.
-- @param vector Sort Origin
function particle_methods:setSortOrigin(origin)
	local uw = unwrap(self)

	checkValid(uw)

	uw:SetSortOrgin(vunwrap(origin))


end


--- Sets a value for given control point.
-- @param number Control Point ID (0-63)
-- @param vector Value
function particle_methods:setControlPoint(id,value)
	local uw = unwrap(self)

	checkluatype (id, TYPE_NUMBER)

	checkValid(uw)

	uw:SetControlPoint(id,vunwrap(value))


end


--- Essentially makes child control point follow the parent entity.
-- @param number Child Control Point ID (0-63)
-- @param entity Entity parent
function particle_methods:setControlPointEntity(id,entity)
	local uw = unwrap(self)
	local entity = getent(entity)

	checkluatype (id, TYPE_NUMBER)

	checkValid(uw)

	uw:SetControlPointEntity(id,entity)


end


--- Sets the forward direction for given control point.
-- @param number Control Point ID (0-63)
-- @param vector Forward
function particle_methods:setForwardVector(id,value)
	local uw = unwrap(self)

	checkluatype (id, TYPE_NUMBER)

	checkValid(uw)

	uw:SetControlPointForwardVector(id,vunwrap(value))


end

--- Sets the right direction for given control point.
-- @param number Control Point ID (0-63)
-- @param vector Right
function particle_methods:setRightVector(id,value)
	local uw = unwrap(self)

	checkluatype (id, TYPE_NUMBER)

	checkValid(uw)

	uw:SetControlPointRightVector(id,vunwrap(value))


end


--- Sets the right direction for given control point.
-- @param number Control Point ID (0-63)
-- @param vector Right
function particle_methods:setUpVector(id,value)
	local uw = unwrap(self)

	checkluatype (id, TYPE_NUMBER)

	checkValid(uw)

	uw:SetControlPointUpVector(id,vunwrap(value))

end


--- Sets the forward direction for given control point.
-- @param number Child Control Point ID (0-63)
-- @param number Parent
function particle_methods:setControlPointParent(id,value)
	local uw = unwrap(self)

	checkluatype (id, TYPE_NUMBER)
	checkluatype (value, TYPE_NUMBER)

	checkValid(uw)

	uw:SetControlPointParent(id,value)

end

end
