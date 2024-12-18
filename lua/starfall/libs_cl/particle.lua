-- Global to all starfalls
local checkluatype = SF.CheckLuaType


-- Register Privileges
SF.Permissions.registerPrivilege("particle.create", "Particle", "Allows the user to create particles", { client = {} })

local plyEmitterCount = SF.LimitObject("particleemitters", "particle emitters", 8, "The number of created particle emitters via Starfall per client at once")
local cv_particle_count = CreateConVar("sf_particles_max", "100", { FCVAR_ARCHIVE }, "The max number of created particles per emitter at once")

SF.ResourceCounters.ParticleEmitters = {icon = "icon16/asterisk_yellow.png", count = function(ply) return plyEmitterCount:get(ply) end}

--- Particles library.
-- @name particle
-- @class library
-- @libtbl particle_library
SF.RegisterLibrary("particle")

--- ParticleEmitter type
-- @name ParticleEmitter
-- @class type
-- @libtbl particleem_methods
SF.RegisterType("ParticleEmitter", true, false)

--- Particle type
-- @name Particle
-- @class type
-- @libtbl particle_methods
SF.RegisterType("Particle", true, false)


return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local particle_library = instance.Libraries.particle
local particleem_methods, pewrap, peunwrap = instance.Types.ParticleEmitter.Methods, instance.Types.ParticleEmitter.Wrap, instance.Types.ParticleEmitter.Unwrap
local particle_methods, pwrap, punwrap = instance.Types.Particle.Methods, instance.Types.Particle.Wrap, instance.Types.Particle.Unwrap
local mat_meta, mwrap, munwrap = instance.Types.LockedMaterial, instance.Types.LockedMaterial.Wrap, instance.Types.LockedMaterial.Unwrap
local col_meta, cwrap, cunwrap = instance.Types.Color, instance.Types.Color.Wrap, instance.Types.Color.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap

local vunwrap1, vunwrap2
local aunwrap1
instance:AddHook("initialize", function()
	vunwrap1, vunwrap2 = vec_meta.QuickUnwrap1, vec_meta.QuickUnwrap2
	aunwrap1 = ang_meta.QuickUnwrap1
end)

local emitters = {}
instance:AddHook("deinitialize", function()
	for emitter in pairs(emitters) do
		emitter:Finish()
		plyEmitterCount:free(instance.player, 1)
	end
end)

--- Creates a ParticleEmitter data structure
-- @param Vector position The particle emitter's position
-- @param boolean use3D Create the emitter in 3D mode
-- @return ParticleEmitter ParticleEmitter Object
function particle_library.create(position, use3D)
	checkluatype(use3D, TYPE_BOOL)
	checkpermission(instance, nil, "particle.create")
	plyEmitterCount:use(instance.player, 1)
	local emitter = ParticleEmitter(vunwrap1(position), use3D)
	emitters[emitter] = true
	return pewrap(emitter)
end

--- Returns number of particle emitters left able to be created
-- @return number Number of particle emitters left
function particle_library.particleEmittersLeft()
	return plyEmitterCount:check(instance.player)
end

--- Creates a new Particle with the given material and position.
-- @param Material material The material object to set the particle
-- @param Vector position The position to create the particle
-- @param number startSize Sets the initial size value of the particle.
-- @param number endSize Sets the size of the particle that it will reach when it dies.
-- @param number startLength Sets the initial length value of the particle.
-- @param number endLength Sets the length of the particle that it will reach when it dies.
-- @param number startAlpha Sets the initial alpha value of the particle.
-- @param number endAlpha Sets the alpha value of the particle that it will reach when it dies.
-- @param number dieTime Sets the time where the particle will be removed. (0-60)
-- @return Particle A Particle object
function particleem_methods:add(material, position, startSize, endSize, startLength, endLength, startAlpha, endAlpha, dieTime)
	self = peunwrap(self)
	if not emitters[self] then SF.Throw("Tried to use invalid emitter!", 2) end

	if self:GetNumActiveParticles() > cv_particle_count:GetInt() then
		SF.Throw("Exeeded the maximum number of particles for this emitter!", 2)
	end
	checkluatype(startSize, TYPE_NUMBER)
	checkluatype(endSize, TYPE_NUMBER)
	checkluatype(startLength, TYPE_NUMBER)
	checkluatype(endLength, TYPE_NUMBER)
	checkluatype(startAlpha, TYPE_NUMBER)
	checkluatype(endAlpha, TYPE_NUMBER)
	checkluatype(dieTime, TYPE_NUMBER)
	if dieTime < 0 or dieTime > 60 then SF.Throw("Die time must be between 0 and 60", 2) end

	local particle = self:Add(munwrap(material), vunwrap1(position))

	particle:SetStartSize(startSize)
	particle:SetEndSize(endSize)
	particle:SetStartLength(startLength)
	particle:SetEndLength(endLength)
	particle:SetStartAlpha(startAlpha)
	particle:SetEndAlpha(endAlpha)
	particle:SetDieTime(dieTime)

	return pwrap(particle)
end

--- Manually renders all particles the emitter has created.
function particleem_methods:draw()
	if not instance.data.render.isRendering then SF.Throw("Not in rendering hook.", 2) end
	peunwrap(self):Draw()
end

--- Removes the emitter, making it no longer usable from Lua. If particles remain, the emitter will be removed when all particles die.
function particleem_methods:destroy()
	local emitter = peunwrap(self)
	emitter:Finish()
	emitters[emitter] = nil
	plyEmitterCount:free(instance.player, 1)
end

--- Returns the amount of active particles of this emitter.
-- @return number Number of active particles
function particleem_methods:getNumActiveParticles()
	return peunwrap(self):GetNumActiveParticles()
end

--- Returns number of particles left able to be created from the emitter
-- @return number Number of particles left
function particleem_methods:getParticlesLeft()
	return cv_particle_count:GetInt() - peunwrap(self):GetNumActiveParticles()
end

--- Returns the position of this emitter. This is set when creating the emitter with ParticleEmitter.
-- @return Vector Position of the Emitter
function particleem_methods:getPos()
	return vwrap(unwrap(self):GetPos())
end

--- Returns whether this emitter is 3D or not. This is set when creating the emitter with ParticleEmitter.
-- @return boolean If it's 3D
function particleem_methods:is3D()
	return peunwrap(self):Is3D()
end

--- Returns whether this object is valid or not.
-- @return boolean If it's valid
function particleem_methods:isValid()
	return peunwrap(self):IsValid()
end

--- Sets the bounding box for this emitter. Usually the bounding box is automatically determined by the particles, but this function overrides it.
-- @param Vector mins Min vector
-- @param Vector maxs Max vector
function particleem_methods:setBBox(mins, maxs)
	peunwrap(self):SetBBox(vunwrap1(mins), vunwrap2(maxs))
end

--- This function sets the the distance between the render camera and the emitter at which the particles should start fading and at which distance fade ends ( alpha becomes 0 ).
-- @param number distanceMin
-- @param number distanceMax
function particleem_methods:setNearClip(distanceMin, distanceMax)
	checkluatype(distanceMin, TYPE_NUMBER)
	checkluatype(distanceMax, TYPE_NUMBER)
	peunwrap(self):SetNearClip(distanceMin, distanceMax)
end

--- Prevents all particles of the emitter from automatically drawing. They can be manually drawn with draw()
-- @param boolean noDraw Whether not to draw
function particleem_methods:setNoDraw(noDraw)
	checkluatype(noDraw, TYPE_BOOL)
	peunwrap(self):SetNoDraw(noDraw)
end

--- The function name has not much in common with its actual function.
-- It applies a radius to every particles that affects the building of the bounding box, as it usually is constructed by the particle that has the lowest x, y and z and the highest x, y and z.
-- This function just adds/subtracts the radius and inflates the bounding box.
-- @param number radius Particle radius
function particleem_methods:setParticleCullRadius(radius)
	checkluatype(radius, TYPE_NUMBER)
	peunwrap(self):SetParticleCullRadius(radius)
end

--- Sets the position of the particle emitter.
-- @param Vector position The position
function particleem_methods:setPos( position )
	 peunwrap(self):SetPos(vunwrap1(position))
end


--- Returns the current orientation of the particle.
-- @return Angle Angles of the particle
function particle_methods:getAngles()
	return awrap(punwrap(self):GetAngles())
end

--- Returns the angular velocity of the particle
-- @return Angle Angular velocity of the particle
function particle_methods:getAngleVelocity()
	return awrap(punwrap(self):GetAngleVelocity())
end

--- Returns the color of the particle.
-- @return Color Color of the particle
function particle_methods:getColor()
	return cwrap(Color(punwrap(self):GetColor()))
end

--- Returns the absolute position of the particle.
-- @return Vector Position of the particle
function particle_methods:getPos()
	return vwrap(punwrap(self):GetPos())
end

--- Returns the current rotation of the particle in radians, this should only be used for 2D particles.
-- @return number Roll
function particle_methods:getRoll()
	return punwrap(self):GetRoll()
end

--- Returns the current velocity of the particle.
-- @return Vector Velocity
function particle_methods:getVelocity()
	return vwrap(punwrap(self):GetVelocity())
end

--- Sets the angles of the particle.
-- @param Angle ang Angles to set the particle's angles to
function particle_methods:setAngles(ang)
	punwrap(self):SetAngles(aunwrap1(ang))
end

--- Sets the angular velocity of the the particle.
-- @param Angle angVel Angular velocity to set the particle's to
function particle_methods:setAngleVelocity(angVel)
	punwrap(self):SetAngleVelocity(aunwrap1(angVel))
end

--- Sets the 'bounciness' of the the particle.
-- @param number bounce Bounciness to set to
function particle_methods:setBounce(bounce)
	checkluatype(bounce, TYPE_NUMBER)
	punwrap(self):SetBounce(bounce)
end

--- Sets the whether the particle should collide with the world or not.
-- @param boolean shouldCollide Whether it should collide
function particle_methods:setCollide(shouldCollide)
	checkluatype(shouldCollide, TYPE_BOOL)
	punwrap(self):SetCollide(shouldCollide)
end

--- Sets the color of the particle.
-- @param Color col Color to set to
function particle_methods:setColor(col)
	col = cunwrap(col)
	punwrap(self):SetColor(col.r, col.g, col.b)
end

--- Sets whether the particle should be affected by lighting.
-- @param boolean useLighting Whether the particle should be affected by lighting
function particle_methods:setLighting(useLighting)
	checkluatype(useLighting, TYPE_BOOL)
	punwrap(self):SetLighting(useLighting)
end

--- Sets the material of the particle.
-- @param Material mat Material to set
function particle_methods:setMaterial(mat)
	punwrap(self):SetMaterial(munwrap(mat))
end

--- Sets the absolute position of the particle.
-- @param Vector pos Vector position to set to
function particle_methods:setPos(pos)
	punwrap(self):SetPos(vunwrap1(pos))
end

--- Sets the roll of the particle in radians. This should only be used for 2D particles.
-- @param number roll Roll
function particle_methods:setRoll(roll)
	checkluatype(roll, TYPE_NUMBER)
	punwrap(self):SetRoll(roll)
end

--- Sets the rotation speed of the particle in radians. This should only be used for 2D particles.
-- @param number rollDelta Rolldelta
function particle_methods:setRollDelta(rollDelta)
	checkluatype(rollDelta, TYPE_NUMBER)
	punwrap(self):SetRollDelta(rollDelta)
end

--- Sets the velocity of the particle.
-- @param Vector vel Velocity to set to
function particle_methods:setVelocity(vel)
	punwrap(self):SetVelocity(vunwrap1(vel))
end

--- Sets the air resistance of the the particle.
-- @param number airResistance AirResistance to set to
function particle_methods:setAirResistance(airResistance)
	checkluatype(airResistance, TYPE_NUMBER)
	punwrap(self):SetAirResistance(airResistance)
end

--- Sets the directional gravity aka. acceleration of the particle.
-- @param Vector gravity Directional gravity
function particle_methods:setGravity(gravity)
	punwrap(self):SetGravity(vunwrap1(gravity))
end

--- Scales the velocity based on the particle speed.
-- @param boolean doScale Whether it should scale
function particle_methods:setVelocityScale(doScale)
	checkluatype(doScale, TYPE_BOOL)
	punwrap(self):SetVelocityScale(doScale)
end



end
