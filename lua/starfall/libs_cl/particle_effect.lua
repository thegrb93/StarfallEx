local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege
local IsValid = IsValid

-- Create permission types.
registerprivilege("particleEffect.attach", "Allow users to create particle effect", { client = {}, entities = {} })

local plyCount = SF.LimitObject("particleeffects", "particle effects", 16, "The number of created particle effects via Starfall per client at once")
SF.ResourceCounters.ParticleEffects = {icon = "icon16/asterisk_orange.png", count = function(ply) return plyCount:get(ply).val end}

--- ParticleEffect library.
-- @name particleEffect
-- @class library
-- @libtbl particleef_library
SF.RegisterLibrary("particleEffect")

--- ParticleEffect type
-- @name ParticleEffect
-- @class type
-- @libtbl particleef_methods
SF.RegisterType("ParticleEffect", false, false)


return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local getent
local particleEffects = {}
instance:AddHook("initialize", function()
	getent = instance.Types.Entity.GetEntity
end)

instance:AddHook("deinitialize", function()
	-- Remove all
	for p in pairs(particleEffects) do
		if p:IsValid() then
			p:StopEmissionAndDestroyImmediately()
		end
		plyCount:free(instance.player, 1)
	end
end)

local particleef_library = instance.Libraries.particleEffect
local particleef_methods = instance.Types.ParticleEffect.Methods

local particle_meta, wrap, unwrap = instance.Types.ParticleEffect, instance.Types.ParticleEffect.Wrap, instance.Types.ParticleEffect.Unwrap
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap


local function badParticle(flags) -- implemented for future use in case anything is found to be unfriendly.
	return false
end

local function checkValid(emitter)
	if not (emitter and emitter:IsValid()) then
		SF.Throw("ParticleEffect emitter is no longer valid.", 2)
	end
end


--- Attaches a particleEffect to an entity.
-- @param Entity entity Entity to attach to
-- @param string name Name of the particle effect
-- @param number pattach PATTACH enum
-- @param table options Table of options
-- @return ParticleEffect ParticleEffect type.
function particleef_library.attach(entity, name, pattach, options)
	checkpermission(instance, entity, "particleEffect.attach")

	checkluatype (name, TYPE_STRING)
	checkluatype (pattach, TYPE_NUMBER)
	checkluatype (options, TYPE_TABLE)

	local entity = getent(entity)

	if badParticle(name) then
		SF.Throw("Invalid particle effect path: " .. name, 2)
	end
	plyCount:use(instance.player, 1)


	local PEffect = entity:CreateParticleEffect(name,pattach,options)

	if not (PEffect and PEffect:IsValid()) then
		SF.Throw("Invalid particle effect system.", 2)
	end

	particleEffects[PEffect] = true

	return wrap(PEffect)

end


--- Gets if the particle effect is valid or not.
-- @return boolean Is valid or not
function particleef_methods:isValid()
	local uw = unwrap(self)

	return uw and uw:IsValid()
end

--- Starts emission of the particle effect.
function particleef_methods:startEmission()
	local uw = unwrap(self)

	checkValid(uw)

	uw:StartEmission()
end


--- Stops emission of the particle effect.
function particleef_methods:stopEmission()
	local uw = unwrap(self)

	checkValid(uw)

	uw:StopEmission()
end

--- Stops emission of the particle effect and destroys the object.
function particleef_methods:destroy()
	local uw = unwrap(self)

	if uw and particleEffects[uw] then
		if uw:IsValid() then
			uw:StopEmissionAndDestroyImmediately()
		end
		particleEffects[uw] = nil
		plyCount:free(instance.player, 1)
	end
end

--- Restarts emission of the particle effect.
function particleef_methods:restart()
	local uw = unwrap(self)

	checkValid(uw)

	uw:Restart()
end


--- Returns if the particle effect is finished
-- @return boolean If the particle effect is finished
function particleef_methods:isFinished()
	local uw = unwrap(self)

	if (uw and uw:IsValid()) then
		return uw:isFinished()
	end

	return true
end


--- Sets the sort origin for given particle effect system. This is used as a helper to determine which particles are in front of which.
-- @param Vector origin Sort Origin
function particleef_methods:setSortOrigin(origin)
	local uw = unwrap(self)

	checkValid(uw)

	uw:SetSortOrgin(vunwrap(origin))
end


--- Sets a value for given control point.
-- @param number id Control Point ID (0-63)
-- @param Vector value Value
function particleef_methods:setControlPoint(id,value)
	local uw = unwrap(self)

	checkluatype (id, TYPE_NUMBER)

	checkValid(uw)

	uw:SetControlPoint(id,vunwrap(value))
end


--- Essentially makes child control point follow the parent entity.
-- @param number id Child Control Point ID (0-63)
-- @param Entity entity Entity parent
function particleef_methods:setControlPointEntity(id,entity)
	local uw = unwrap(self)
	local entity = getent(entity)

	checkluatype (id, TYPE_NUMBER)

	checkValid(uw)

	uw:SetControlPointEntity(id,entity)
end


--- Sets the forward direction for given control point.
-- @param number id Control Point ID (0-63)
-- @param Vector fwd Forward vector
function particleef_methods:setForwardVector(id,value)
	local uw = unwrap(self)

	checkluatype (id, TYPE_NUMBER)

	checkValid(uw)

	uw:SetControlPointForwardVector(id,vunwrap(value))
end

--- Sets the right direction for given control point.
-- @param number id Control Point ID (0-63)
-- @param Vector right Right vector
function particleef_methods:setRightVector(id,value)
	local uw = unwrap(self)

	checkluatype (id, TYPE_NUMBER)

	checkValid(uw)

	uw:SetControlPointRightVector(id,vunwrap(value))
end


--- Sets the up direction for given control point.
-- @param number id Control Point ID (0-63)
-- @param Vector up Up vector
function particleef_methods:setUpVector(id,value)
	local uw = unwrap(self)

	checkluatype (id, TYPE_NUMBER)

	checkValid(uw)

	uw:SetControlPointUpVector(id,vunwrap(value))

end


--- Sets the parent for given control point.
-- @param number id Child Control Point ID (0-63)
-- @param number parentid Parent control point ID (0-63)
function particleef_methods:setControlPointParent(id,parentid)
	local uw = unwrap(self)

	checkluatype (id, TYPE_NUMBER)
	checkluatype (parentid, TYPE_NUMBER)

	checkValid(uw)

	uw:SetControlPointParent(id,parentid)

end

end
