local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege
local IsValid = IsValid

-- Create permission types.
registerprivilege("particleEffect.attach", "Attach a particle effect", "Allows users to attach particle effects to entities", { client = {}, entities = {} })

local plyCount = SF.LimitObject("particleeffects", "particle effects", 16, "The number of created particle effects via Starfall per client at once")
SF.ResourceCounters.ParticleEffects = { icon = "icon16/asterisk_orange.png", count = function(ply) return plyCount:get(ply) end }

--- ParticleEffect library.
-- @name particleEffect
-- @shared
-- @class library
-- @libtbl particleef_library
SF.RegisterLibrary("particleEffect")

if CLIENT then
--- ParticleEffect type
-- @name ParticleEffect
-- @client
-- @class type
-- @libtbl particleef_methods
SF.RegisterType("ParticleEffect", false, false)
end

-- Must precache particle effects (on server-side!), otherwise this library won't work (Emitter tool does this as well).
game.AddParticles("particles/gmod_effects.pcf")
-- NOTE: Only 4096 can be precached on server-side; no limit on client-side.
PrecacheParticleSystem("generic_smoke")

-- Blacklist for bad/expensive particle effects (keys are lowercased name).
local particle_effect_blacklist = {
	-- none,                  yet
}

-- Exposed, so addons can modify it if needed.
--   For example to block all (in case of emergency):
--     setmetatable(SF.particle_effect_blacklist, { __index = function() return true end })
SF.particle_effect_blacklist = particle_effect_blacklist

local function isBadParticleEffect(name, instance)
	name = string.lower(name)
	if particle_effect_blacklist[name] then return true end
	if hook.Run("Starfall_CanParticleEffect", name, instance) == false then return true end
	return false
end

local function checkValid(peff)
	if not IsValid(peff) then
		SF.Throw("ParticleEffect emitter is no longer valid.", 2)
	end
	return peff -- for method chaining (simpler code)
end


return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local particleef_library = instance.Libraries.particleEffect

-- The ParticleEffect type is only registered on the client (see the `if CLIENT`
-- block near the top of the file). On a dedicated server this shared library only
-- exists to precache particle systems, so the type-dependent bindings below must
-- only be resolved when they actually exist.
local particleef_methods
local particle_meta, wrap, unwrap
local vec_meta, vwrap, vunwrap

local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap

if CLIENT then
	particleef_methods = instance.Types.ParticleEffect.Methods
	particle_meta, wrap, unwrap = instance.Types.ParticleEffect, instance.Types.ParticleEffect.Wrap, instance.Types.ParticleEffect.Unwrap
	vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
end

local vunwrap1
instance:AddHook("initialize", function()
	vunwrap1 = vec_meta and vec_meta.QuickUnwrap1
end)

local particle_effects = {} -- setmetatable({}, { __mode = "k" })

instance:AddHook("deinitialize", function()
	-- Remove all
	for peff in next, particle_effects do
		if IsValid(peff) then
			peff:StopEmissionAndDestroyImmediately()
		end
		plyCount:free(instance.player, 1)
		particle_effects[peff] = nil
	end
end)


--- Creates a particle effect (and attaches it to an entity).
-- CRITICAL NOTE: You must call this on server-side and client-side (to precache the particle effect)!
-- @param Entity entity The entity to attach the particle effect to
-- @param string name The name of the effect to create (e.g. "generic_smoke")
-- @param number pattach See PATTACH enum
-- @param table? options Optional table of tables (indexes 1 to 64) having the following structure:
-- number attachtype - The particle attach type (see PATTACH enum, default: `PATTACH.ABSORIGIN`).
-- Entity entity - The parent entity (default: NULL).
-- Vector position - The offset position for the given control point (default: nil).
-- This only affects the control points of the particle effects, and will do nothing if the effect doesn't use control points.
-- @return ParticleEffect? On client-side: ParticleEffect object.
-- On server-side: no value (only precaching).
function particleef_library.attach(entity, name, pattach, options)
	checkluatype(name, TYPE_STRING)
	checkluatype(pattach, TYPE_NUMBER)
	if options ~= nil then checkluatype(options, TYPE_TABLE) end

	entity = eunwrap(entity)
	-- No need to validate entity; allow attaching to the world entity (which has IsValid = false)

	checkpermission(instance, entity, "particleEffect.attach")

	-- Superusers bypass the limits.
	if instance.player ~= SF.Superuser then
		if isBadParticleEffect(name, instance) then
			SF.Throw("Bad particle effect: " .. name, 2)
		end
		plyCount:use(instance.player, 1)
	end

	-- NOTE: Only 4096 can be precached on server-side; no limit on client-side.
	PrecacheParticleSystem(name)
	-- Exit early on server-side, we only care about precaching on server-side.
	if SERVER then return end

	-- Sanitize the options table.
	local cleanOptions
	if options then
		cleanOptions = {}
		for i = 1, math.min(#options, 64) do
			local cp = options[i]
			if cp then
				checkluatype(cp, TYPE_TABLE)
				local clean = {}
				-- All fields are optional
				if cp.attachtype ~= nil then
					checkluatype(cp.attachtype, TYPE_NUMBER)
					clean.attachtype = cp.attachtype
				end
				if cp.entity ~= nil then
					clean.entity = eunwrap(cp.entity)
				end
				if cp.position ~= nil then
					clean.position = vunwrap1(cp.position)
				end
				cleanOptions[i] = clean
			end
		end
	end

	local pEffect = entity:CreateParticleEffect(name, pattach, cleanOptions)
	if not IsValid(pEffect) then
		SF.Throw("Invalid particle effect system.", 2)
	end

	particle_effects[pEffect] = true

	return wrap(pEffect)
end

if CLIENT then
--- Determines whether the particle effect is valid or not.
-- @return boolean Is valid or not
function particleef_methods:isValid()
	local peff = unwrap(self)
	return peff and IsValid(peff) or false
end

--- Starts emission of the particle effect.
function particleef_methods:startEmission()
	checkValid(unwrap(self)):StartEmission()
end

--- Stops emission of the particle effect.
function particleef_methods:stopEmission()
	checkValid(unwrap(self)):StopEmission()
end

--- Stops emission of the particle effect and destroys the object.
function particleef_methods:destroy()
	local peff = unwrap(self)
	if peff and particle_effects[peff] then
		if IsValid(peff) then
			peff:StopEmissionAndDestroyImmediately()
		end
		particle_effects[peff] = nil
		plyCount:free(instance.player, 1)
	end
end

--- Restarts emission of the particle effect.
function particleef_methods:restart()
	checkValid(unwrap(self)):Restart()
end

--- Determines if the particle effect is finished (or is invalid).
-- @return boolean True if the particle effect is finished (or is invalid)
function particleef_methods:isFinished()
	local peff = unwrap(self)
	return peff and IsValid(peff) and peff:IsFinished() or false
end

--- Sets the sort origin for the given particle effect system.
-- This is used as a helper to determine which particles are in front of which.
-- @param Vector origin Sort origin
function particleef_methods:setSortOrigin(origin)
	checkValid(unwrap(self)):SetSortOrigin(vunwrap1(origin))
end

--- Sets a value for the given control point.
-- @param number id Control point index (from 0 to 63)
-- @param Vector value Value
function particleef_methods:setControlPoint(id, value)
	checkluatype(id, TYPE_NUMBER)
	checkValid(unwrap(self)):SetControlPoint(id, vunwrap1(value))
end

--- Essentially makes child control point follow the parent entity.
-- @param number id Child control point index (from 0 to 63)
-- @param Entity entity Entity parent
function particleef_methods:setControlPointEntity(id, entity)
	checkluatype(id, TYPE_NUMBER)
	checkValid(unwrap(self)):SetControlPointEntity(id, eunwrap(entity))
end

--- Sets the forward direction for the given control point.
-- @param number id Control point index (from 0 to 63)
-- @param Vector value Forward vector
function particleef_methods:setForwardVector(id, value)
	checkluatype(id, TYPE_NUMBER)
	checkValid(unwrap(self)):SetControlPointForwardVector(id, vunwrap1(value))
end

--- Sets the right direction for the given control point.
-- @param number id Control point index (from 0 to 63)
-- @param Vector value Right vector
function particleef_methods:setRightVector(id, value)
	checkluatype(id, TYPE_NUMBER)
	checkValid(unwrap(self)):SetControlPointRightVector(id, vunwrap1(value))
end

--- Sets the up direction for the given control point.
-- @param number id Control point index (from 0 to 63)
-- @param Vector value Up vector
function particleef_methods:setUpVector(id, value)
	checkluatype(id, TYPE_NUMBER)
	checkValid(unwrap(self)):SetControlPointUpVector(id, vunwrap1(value))
end

--- Sets the parent for the given control point.
-- @param number id Child control point index (from 0 to 63)
-- @param number parentid Parent control point index (from 0 to 63)
function particleef_methods:setControlPointParent(id, parentid)
	checkluatype(id, TYPE_NUMBER)
	checkluatype(parentid, TYPE_NUMBER)
	checkValid(unwrap(self)):SetControlPointParent(id, parentid)
end

end

end
