local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check
local registerprivilege = SF.Permissions.registerPrivilege
local IsValid = IsValid

-- Create permission types.
registerprivilege("particle.attach", "Allow users to create particle", { client = {}, entities = {} })


-- Local to each starfall
return { function(instance) -- Called for library declarations


--- Particle type
-- @client
local particle_methods, particle_meta = instance:RegisterType("Particle")
local wrap, unwrap = instance:CreateWrapper(particle_meta, false, false)

--- Particle library.
-- @client
local particle_library = instance:RegisterLibrary("particle")

-- Create the storage for the metamethods
instance:AddHook("initialize", function()
	instance.data.particle = {
		particles = {},
	}
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


end, function(instance) -- Called for library definitions

local particle_library = instance.Libraries.particle
local particle_methods = instance.Types.Particle.Methods

local checktype = instance.CheckType
local particle_meta, wrap, unwrap = instance.Types.Particle, instance.Types.Particle.Wrap, instance.Types.Particle.Unwrap
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local getent = instance.Types.Entity.GetEntity


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
function particle_library.attach (entity, particle, pattach, options)
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
	checktype(self, particle_meta)
	local uw = unwrap(self)

	return uw and uw:IsValid()

end

--- Starts emission of the particle.
function particle_methods:startEmission()
	checktype(self, particle_meta)
	local uw = unwrap(self)

	checkValid(uw)

	uw:StartEmission()


end


--- Stops emission of the particle.
function particle_methods:stopEmission()
	checktype(self, particle_meta)
	local uw = unwrap(self)

	checkValid(uw)

	uw:StopEmission()


end

--- Stops emission of the particle and destroys the object.
function particle_methods:destroy()
	checktype(self, particle_meta)
	local uw = unwrap(self)

	if (uw and uw:IsValid()) then
		uw:StopEmissionAndDestroyImmediately()
	end

end

--- Restarts emission of the particle.
function particle_methods:restart()
	checktype(self, particle_meta)
	local uw = unwrap(self)

	checkValid(uw)

	uw:Restart()


end


--- Restarts emission of the particle.
-- @return bool finished
function particle_methods:isFinished()
	checktype(self, particle_meta)
	local uw = unwrap(self)

	if (uw and uw:IsValid()) then
		return uw:isFinished()
	end

	return true

end


--- Sets the sort origin for given particle system. This is used as a helper to determine which particles are in front of which.
-- @param vector Sort Origin
function particle_methods:setSortOrigin(origin)
	checktype(self, particle_meta)
	local uw = unwrap(self)
	checktype(origin, vec_meta)

	checkValid(uw)

	uw:SetSortOrgin(unwrap_vector(origin))


end


--- Sets a value for given control point.
-- @param number Control Point ID (0-63)
-- @param vector Value
function particle_methods:setControlPoint(id,value)
	checktype(self, particle_meta)
	local uw = unwrap(self)

	checkluatype (id, TYPE_NUMBER)
	checktype(value, vec_meta)

	checkValid(uw)

	uw:SetControlPoint(id,unwrap_vector(value))


end


--- Essentially makes child control point follow the parent entity.
-- @param number Child Control Point ID (0-63)
-- @param entity Entity parent
function particle_methods:setControlPointEntity(id,entity)
	checktype(self, particle_meta)
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
	checktype(self, particle_meta)
	local uw = unwrap(self)

	checkluatype (id, TYPE_NUMBER)
	checktype(value, vec_meta)

	checkValid(uw)

	uw:SetControlPointForwardVector(id,unwrap_vector(value))


end

--- Sets the right direction for given control point.
-- @param number Control Point ID (0-63)
-- @param vector Right
function particle_methods:setRightVector(id,value)
	checktype(self, particle_meta)
	local uw = unwrap(self)

	checkluatype (id, TYPE_NUMBER)
	checktype(value, vec_meta)

	checkValid(uw)

	uw:SetControlPointRightVector(id,unwrap_vector(value))


end


--- Sets the right direction for given control point.
-- @param number Control Point ID (0-63)
-- @param vector Right
function particle_methods:setUpVector(id,value)
	checktype(self, particle_meta)
	local uw = unwrap(self)

	checkluatype (id, TYPE_NUMBER)
	checktype(value, vec_meta)

	checkValid(uw)

	uw:SetControlPointUpVector(id,unwrap_vector(value))

end


--- Sets the forward direction for given control point.
-- @param number Child Control Point ID (0-63)
-- @param number Parent
function particle_methods:setControlPointParent(id,value)
	checktype(self, particle_meta)
	local uw = unwrap(self)

	checkluatype (id, TYPE_NUMBER)
	checkluatype (value, TYPE_NUMBER)

	checkValid(uw)

	uw:SetControlPointParent(id,value)

end

end}
