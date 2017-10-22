SF.Particle = {}

-- Create permission types.

do

	local P = SF.Permissions
	--------------------------
	P.registerPrivilege("particle.attach", "Allow users to create particle", { ["Client"] = {} })
	
end

local TYPE_ENTITY,TYPE_VECTOR  
local unwrap_entity 

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

--- Attaches a particle to an entity.
-- @param entity to attach to 
-- @param string particle name 
-- @param number PATTACH_ enum 
-- @param table options 
-- @return Particle type. 
function particle_library.attach (entity, particle, pattach, options)
	SF.Permissions.check(SF.instance.player, nil, "particle.attach")

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
	
	if IsValid(uw) then 
		uw:StartEmission()
	end 
	
end


--- Stops emission of the particle.
function particle_methods:stopEmission()
	SF.CheckType(self, particle_metamethods)
	local uw = unwrap(self)
	
	if IsValid(uw) then 
		uw:StopEmission()
	end 
	
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
	
	if IsValid(uw) then 
		uw:Restart()
	end 
	
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
	
	if IsValid(uw) then 
		uw:SetSortOrgin(origin)
	end 
	
end


--- Sets a value for given control point.
-- @param number Control Point ID (0-63)
-- @param vector Value
function particle_methods:setControlPoint(id,value)
	SF.CheckType(self, particle_metamethods)
	local uw = unwrap(self)
	
	SF.CheckLuaType(id, TYPE_NUMBER)
	SF.CheckType(value, TYPE_VECTOR)
	
	if IsValid(uw) then 
		uw:SetControlPoint(id,value)
	end 
	
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
	
	if IsValid(uw) then 
		uw:SetControlPointEntity(id,entity)
	end 
	
end


--- Sets the forward direction for given control point.
-- @param number Control Point ID (0-63)
-- @param vector Forward
function particle_methods:setForwardVector(id,value)
	SF.CheckType(self, particle_metamethods)
	local uw = unwrap(self)
	
	SF.CheckLuaType(id, TYPE_NUMBER)
	SF.CheckType(value, TYPE_VECTOR)
	
	if IsValid(uw) then 
		uw:SetControlPointForwardVector(id,value)
	end 
	
end

--- Sets the right direction for given control point.
-- @param number Control Point ID (0-63)
-- @param vector Right
function particle_methods:setRightVector(id,value)
	SF.CheckType(self, particle_metamethods)
	local uw = unwrap(self)
	
	SF.CheckLuaType(id, TYPE_NUMBER)
	SF.CheckType(value, TYPE_VECTOR)
	
	if IsValid(uw) then 
		uw:SetControlPointRightVector(id,value)
	end 
	
end

	
--- Sets the right direction for given control point.
-- @param number Control Point ID (0-63)
-- @param vector Right
function particle_methods:setUpVector(id,value)
	SF.CheckType(self, particle_metamethods)
	local uw = unwrap(self)
	
	SF.CheckLuaType(id, TYPE_NUMBER)
	SF.CheckType(value, TYPE_VECTOR)
	
	if IsValid(uw) then 
		uw:SetControlPointRightVector(id,value)
	end 
	
end


--- Sets the forward direction for given control point.
-- @param number Child Control Point ID (0-63)
-- @param number Parent
function particle_methods:setControlPointParent(id,value)
	SF.CheckType(self, particle_metamethods)
	local uw = unwrap(self)
	
	SF.CheckLuaType(id, TYPE_NUMBER)
	SF.CheckLuaType(value, TYPE_NUMBER)
	
	if IsValid(uw) then 
		uw:SetControlPointParent(id,value)
	end 
	
end
