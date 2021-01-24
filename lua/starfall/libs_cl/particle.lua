-- Global to all starfalls
local checkluatype = SF.CheckLuaType


-- Register Privileges
SF.Permissions.registerPrivilege("particle.create", "Particle", "Allows the user to create particles", { client = {} })

local plyEmitterCount = SF.LimitObject("particleemitters", "particle emitters", 8, "The number of created particle emitters via Starfall per client at once")
local cv_particle_count = CreateConVar("sf_particles_max", "100", { FCVAR_ARCHIVE }, "The max number of created particles per emitter at once")

SF.ResourceCounters.ParticleEmitters = {icon = "icon16/asterisk_yellow.png", count = function(ply) return plyEmitterCount:get(ply).val end}

--- Particles library.
-- @name effect
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

local emitters = {}
instance:AddHook("deinitialize", function()
	for emitter in pairs(emitters) do
		emitter:Finish()
		plyEmitterCount:free(instance.player, 1)
	end
end)

--- Creates a ParticleEmitter data structure
-- @param position vector The particle emitter's position
-- @param use3D boolean Create the emitter in 3D mode
-- @return ParticleEmitter Object
function particle_library.create(position, use3D)
	checkluatype(use3D, TYPE_BOOL)
	checkpermission(instance, nil, "particle.create")
	plyEmitterCount:use(instance.player, 1)
	local emitter = ParticleEmitter(vunwrap(position), use3D)
	emitters[emitter] = true
	return pewrap(emitter)
end

--- Returns number of particle emitters left able to be created
-- @return number
function particle_library.particleEmittersLeft()
	return plyEmitterCount:check()
end

--- Creates a new Particle with the given material and position.
-- @param material The material object to set the particle
-- @param position The position to create the particle
-- @param startSize number Sets the initial size value of the particle.
-- @param endSize number Sets the size of the particle that it will reach when it dies.
-- @param startLength number Sets the initial length value of the particle.
-- @param endLength number Sets the length of the particle that it will reach when it dies.
-- @param startAlpha number Sets the initial alpha value of the particle.
-- @param endAlpha number Sets the alpha value of the particle that it will reach when it dies.
-- @param dieTime number Sets the time where the particle will be removed.
-- @return A Particle object
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

	local particle = self:Add(munwrap(material), vunwrap(position))

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
	if not instance.render.data.isRendering then SF.Throw("Not in rendering hook.", 2) end
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
-- @return number
function particleem_methods:getNumActiveParticles()
	return peunwrap(self):GetNumActiveParticles()
end

--- Returns number of particles left able to be created from the emitter
-- @return number
function particleem_methods:getParticlesLeft()
	return cv_particle_count:GetInt() - peunwrap(self):GetNumActiveParticles()
end

--- Returns the position of this emitter. This is set when creating the emitter with ParticleEmitter.
-- @return vector
function particleem_methods:getPos()
	return vwrap(unwrap(self):GetPos())
end

--- Returns whether this emitter is 3D or not. This is set when creating the emitter with ParticleEmitter.
-- @return boolean
function particleem_methods:is3D()
	return peunwrap(self):Is3D()
end

--- Returns whether this object is valid or not.
-- @return boolean
function particleem_methods:isValid()
	return peunwrap(self):IsValid()
end

--- Sets the bounding box for this emitter. Usually the bounding box is automatically determined by the particles, but this function overrides it.
-- @param mins vector
-- @param maxs vector
function particleem_methods:setBBox(mins, maxs)
	peunwrap(self):SetBBox(vunwrap(mins), vunwrap(maxs))
end

--- This function sets the the distance between the render camera and the emitter at which the particles should start fading and at which distance fade ends ( alpha becomes 0 ).
-- @param distanceMin number
-- @param distanceMax number
function particleem_methods:setNearClip(distanceMin, distanceMax)
	checkluatype(distanceMin, TYPE_NUMBER)
	checkluatype(distanceMax, TYPE_NUMBER)
	peunwrap(self):SetNearClip(distanceMin, distanceMax)
end

--- Prevents all particles of the emitter from automatically drawing. They can be manually drawn with draw()
-- @param noDraw boolean
function particleem_methods:setNoDraw(noDraw)
	checkluatype(noDraw, TYPE_BOOL)
	peunwrap(self):SetNoDraw(noDraw)
end

--- The function name has not much in common with its actual function, it applies a radius to every particles that affects the building of the bounding box, as it, usually is constructed by the particle that has the lowest x, y and z and the highest x, y and z, this function just adds/subtracts the radius and inflates the bounding box.
-- @param radius number
function particleem_methods:setParticleCullRadius(radius)
	checkluatype(radius, TYPE_NUMBER)
	peunwrap(self):SetPos(vunwrap(position))
end

--- Sets the position of the particle emitter.
-- @param position The position
function particleem_methods:setPos( position )
	 peunwrap(self):SetPos(vunwrap(position))
end




--- Returns the current orientation of the particle.
-- @return angle
function particle_methods:getAngles()
	return awrap(punwrap(self):GetAngles())
end

--- Returns the angular velocity of the particle
-- @return angle
function particle_methods:getAngleVelocity()
	return awrap(punwrap(self):GetAngleVelocity())
end

--- Returns the color of the particle.
-- @return color
function particle_methods:getColor()
	return cwrap(Color(punwrap(self):GetColor()))
end

--- Returns the absolute position of the particle.
-- @return vector
function particle_methods:getPos()
	return vwrap(punwrap(self):GetPos())
end

--- Returns the current rotation of the particle in radians, this should only be used for 2D particles.
-- @return number
function particle_methods:getRoll()
	return punwrap(self):GetRoll()
end

--- Returns the current velocity of the particle.
-- @return vector
function particle_methods:getVelocity()
	return vwrap(punwrap(self):GetVelocity())
end

--- Sets the angles of the particle.
-- @param ang angle
function particle_methods:setAngles(ang)
	punwrap(self):SetAngles(aunwrap(ang))
end

--- Sets the angular velocity of the the particle.
-- @param angVel angle
function particle_methods:setAngleVelocity(angVel)
	punwrap(self):SetAngleVelocity(aunwrap(angVel))
end

--- Sets the 'bounciness' of the the particle.
-- @param bounce number
function particle_methods:setBounce(bounce)
	checkluatype(bounce, TYPE_NUMBER)
	punwrap(self):SetBounce(bounce)
end

--- Sets the whether the particle should collide with the world or not.
-- @param shouldCollide boolean
function particle_methods:setCollide(shouldCollide)
	checkluatype(shouldCollide, TYPE_BOOL)
	punwrap(self):SetCollide(shouldCollide)
end

--- Sets the color of the particle.
-- @param col color
function particle_methods:setColor(col)
	col = cunwrap(col)
	punwrap(self):SetColor(col[1], col[2], col[3])
end

--- Sets whether the particle should be affected by lighting.
-- @param useLighting boolean
function particle_methods:setLighting(useLighting)
	checkluatype(useLighting, TYPE_BOOL)
	punwrap(self):SetLighting(useLighting)
end

--- Sets the material of the particle.
-- @param mat material
function particle_methods:setMaterial(mat)
	punwrap(self):SetMaterial(munwrap(mat))
end

--- Sets the absolute position of the particle.
-- @param pos vector
function particle_methods:setPos(pos)
	punwrap(self):SetPos(vunwrap(pos))
end

--- Sets the roll of the particle in radians. This should only be used for 2D particles.
-- @param roll number
function particle_methods:setRoll(roll)
	checkluatype(roll, TYPE_NUMBER)
	punwrap(self):SetRoll(roll)
end

--- Sets the rotation speed of the particle in radians. This should only be used for 2D particles.
-- @param rollDelta number
function particle_methods:setRollDelta(rollDelta)
	checkluatype(rollDelta, TYPE_NUMBER)
	punwrap(self):SetRollDelta(rollDelta)
end

--- Sets the velocity of the particle.
-- @param vel vector
function particle_methods:setVelocity(vel)
	punwrap(self):SetVelocity(vunwrap(vel))
end

--- Sets the air resistance of the the particle.
-- @param airResistance number
function particle_methods:setAirResistance(airResistance)
	checkluatype(airResistance, TYPE_NUMBER)
	punwrap(self):SetAirResistance(airResistance)
end

--- Sets the directional gravity aka. acceleration of the particle.
-- @param gravity vector
function particle_methods:setGravity(gravity)
	punwrap(self):SetGravity(vunwrap(gravity))
end

--- Scales the velocity based on the particle speed.
-- @param doScale boolean
function particle_methods:setVelocityScale(doScale)
	checkluatype(doScale, TYPE_BOOL)
	punwrap(self):SetVelocityScale(doScale)
end



end
