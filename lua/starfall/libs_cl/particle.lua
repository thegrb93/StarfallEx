SF.Particle = {}

-- Create permission types.

do

	local P = SF.Permissions
	--------------------------
	P.registerPrivilege("particle.attach", "Allow users to create particle", { client = {}, entities = {} })

end

local TYPE_ENTITY,TYPE_VECTOR
local unwrap_entity
local IsValid = IsValid


SF.Libraries.AddHook("postload", function()
	TYPE_ENTITY = SF.Entities.Metatable
	TYPE_VECTOR = SF.Types["Vector"]

	unwrap_entity = SF.Entities.Unwrap
end)


--- Particle type
-- @client
local particle_methods, particle_metamethods = SF.Typedef("Particle")
local wrap, unwrap = SF.CreateWrapper(particle_metamethods, false, false, debug.getregistry().CNewParticleEffect)

--- Particle library.
-- @client
local particle_library = SF.Libraries.Register("particle")

SF.Particle.Wrap = wrap
SF.Particle.Unwrap = unwrap
SF.Particle.Methods = particle_methods
SF.Particle.Metatable = particle_metamethods

-- Add PATTACH enum
SF.Libraries.AddHook("postload", function()
	local _PATTACH = {
		["ABSORIGIN"] = PATTACH_ABSORIGIN,
		["ABSORIGIN_FOLLOW"] =  PATTACH_ABSORIGIN_FOLLOW,
		["CUSTOMORIGIN"] =  PATTACH_CUSTOMORIGIN,
		["POINT"] = PATTACH_POINT,
		["POINT_FOLLOW"] = PATTACH_POINT_FOLLOW,
		["WORLDORIGIN"] =  PATTACH_WORLDORIGIN,
	}
	SF.DefaultEnvironment.PATTACH = _PATTACH
end)

-- Create the storage for the metamethods
SF.Libraries.AddHook("initialize", function (inst)
	inst.data.particle = {
		particles = {},
	}
end)

SF.Libraries.AddHook("deinitialize", function (inst)
	local particles = inst.data.particle.particles
	local p = next(particles)
	-- Remove all
	while p do
		if IsValid(p) then
			p:StopEmission() -- Technically should be using
			-- p:StopEmissionAndDestroyImmediately()
			-- but https://github.com/Facepunch/garrysmod-issues/issues/2700
		end
		particles[p] = nil
		p = next(particles)
	end
end)

local function badParticle(flags) -- implemented for future use in case anything is found to be unfriendly.
	return false
end

local function checkValid(emitter)
	if not IsValid(emitter) then
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
	SF.Permissions.check(SF.instance.player, entity, "particle.attach")

	SF.CheckType(entity, TYPE_ENTITY)
	SF.CheckLuaType(particle, TYPE_STRING)
	SF.CheckLuaType(pattach, TYPE_NUMBER)
	SF.CheckLuaType(options, TYPE_TABLE)

	local entity = unwrap_entity(entity)

	if badParticle(particle) then
		SF.Throw("Invalid particle path: " .. particle, 2)
	end

	local instance = SF.instance


	local PEffect = entity:CreateParticleEffect(particle,pattach,options)

	if not IsValid(PEffect) then
		SF.Throw("Invalid particle system.", 2)
	end

	instance.data.particle.particles[PEffect] = true

	return wrap(PEffect)

end


--- Gets if the particle is valid or not.
-- @return Is valid or not
function particle_methods:isValid()
	SF.CheckType(self, particle_metamethods)
	local uw = unwrap(self)

	return IsValid(uw)

end

--- Starts emission of the particle.
function particle_methods:startEmission()
	SF.CheckType(self, particle_metamethods)
	local uw = unwrap(self)

	checkValid(uw)

	uw:StartEmission()


end


--- Stops emission of the particle.
function particle_methods:stopEmission()
	SF.CheckType(self, particle_metamethods)
	local uw = unwrap(self)

	checkValid(uw)

	uw:StopEmission()


end

--[[

fix it god damn it
--- Stops emission of the particle and destroys the object.
function particle_methods:destroy()
	SF.CheckType(self, particle_metamethods)
	local uw = unwrap(self)

	if IsValid(uw) then
		uw:StopEmissionAndDestroyImmediately()
	end

end
--]]

--- Restarts emission of the particle.
function particle_methods:restart()
	SF.CheckType(self, particle_metamethods)
	local uw = unwrap(self)

	checkValid(uw)

	uw:Restart()


end


--- Restarts emission of the particle.
-- @return bool finished
function particle_methods:isFinished()
	SF.CheckType(self, particle_metamethods)
	local uw = unwrap(self)

	if IsValid(uw) then
		return uw:isFinished()
	end

	return true

end


--- Sets the sort origin for given particle system. This is used as a helper to determine which particles are in front of which.
-- @param vector Sort Origin
function particle_methods:setSortOrigin(origin)
	SF.CheckType(self, particle_metamethods)
	local uw = unwrap(self)
	SF.CheckType(origin, TYPE_VECTOR)

	checkValid(uw)

	uw:SetSortOrgin(origin)


end


--- Sets a value for given control point.
-- @param number Control Point ID (0-63)
-- @param vector Value
function particle_methods:setControlPoint(id,value)
	SF.CheckType(self, particle_metamethods)
	local uw = unwrap(self)

	SF.CheckLuaType(id, TYPE_NUMBER)
	SF.CheckType(value, TYPE_VECTOR)

	checkValid(uw)

	uw:SetControlPoint(id,value)


end


--- Essentially makes child control point follow the parent entity.
-- @param number Child Control Point ID (0-63)
-- @param entity Entity parent
function particle_methods:setControlPointEntity(id,entity)
	SF.CheckType(self, particle_metamethods)
	local uw = unwrap(self)
	local entity = unwrap_entity(entity)

	SF.CheckLuaType(id, TYPE_NUMBER)
	SF.CheckType(entity, TYPE_ENTITY)

	checkValid(uw)

	uw:SetControlPointEntity(id,entity)


end


--- Sets the forward direction for given control point.
-- @param number Control Point ID (0-63)
-- @param vector Forward
function particle_methods:setForwardVector(id,value)
	SF.CheckType(self, particle_metamethods)
	local uw = unwrap(self)

	SF.CheckLuaType(id, TYPE_NUMBER)
	SF.CheckType(value, TYPE_VECTOR)

	checkValid(uw)

	uw:SetControlPointForwardVector(id,value)


end

--- Sets the right direction for given control point.
-- @param number Control Point ID (0-63)
-- @param vector Right
function particle_methods:setRightVector(id,value)
	SF.CheckType(self, particle_metamethods)
	local uw = unwrap(self)

	SF.CheckLuaType(id, TYPE_NUMBER)
	SF.CheckType(value, TYPE_VECTOR)

	checkValid(uw)

	uw:SetControlPointRightVector(id,value)


end


--- Sets the right direction for given control point.
-- @param number Control Point ID (0-63)
-- @param vector Right
function particle_methods:setUpVector(id,value)
	SF.CheckType(self, particle_metamethods)
	local uw = unwrap(self)

	SF.CheckLuaType(id, TYPE_NUMBER)
	SF.CheckType(value, TYPE_VECTOR)

	checkValid(uw)

	uw:SetControlPointUpVector(id,value)

end


--- Sets the forward direction for given control point.
-- @param number Child Control Point ID (0-63)
-- @param number Parent
function particle_methods:setControlPointParent(id,value)
	SF.CheckType(self, particle_metamethods)
	local uw = unwrap(self)

	SF.CheckLuaType(id, TYPE_NUMBER)
	SF.CheckLuaType(value, TYPE_NUMBER)

	checkValid(uw)

	uw:SetControlPointParent(id,value)

end
