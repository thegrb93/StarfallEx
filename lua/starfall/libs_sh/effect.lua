-- Global to all Starfalls
local clamp = math.Clamp
local floor = math.floor
local checkluatype = SF.CheckLuaType
local checknumber = SF.CheckNumber
local checkvector = SF.CheckVector

-- Register Privileges
SF.Permissions.registerPrivilege("effect.play", "Effect", "Allows the user to play effects", { client = {} })

local plyEffectBurst = SF.BurstObject("effects", "effects", 60, 5, "Rate effects can be spawned per second.", "Number of effects that can be spawned in a short time.")
SF.ResourceCounters.Effects = {icon = "icon16/bullet_star.png", count = function(ply) return plyEffectBurst.max - plyEffectBurst:check(ply) end}

-- Effect blacklist (keys are lowercase name).
local EFFECT_BLACKLIST = {
	dof_node = true, -- Material effect used by depth of field effect.
	smoke = true,   -- Creates a bunch of messed up smoke that can't be deleted, not recommended.
}


local EffectLimit
EffectLimit = {
	__index = {
		-- Helper checker for range properties
		checkRange = function(self, value)
			return value ~= value or value < limit.min or value > limit.max
		end,

		-- Helper checker for normal vector (validates and normalizes)
		checkNormal = function(self, value)
			-- As per GMod docs, effect's normal must be a normalized (length=1) vector for networking purposes
			local n = isvector(value) and value or Vector(value[1] or 0, value[2] or 0, value[3] or 0)
			-- Store as Vector for consistency with Effect object storage
			self[key] = n:LengthSqr() > 0 and n:GetNormalized() or Vector(0, 0, 1)
			return false
		end,

		-- Helper checker for position vectors (validates and clamps to world bounds)
		checkPos = function(self, value)
			-- Store as Vector for consistency with Effect object storage
			self[key] = isvector(value) and
				Vector(clamp(value[1], -16386, 16386), clamp(value[2], -16386, 16386), clamp(value[3], -16386, 16386))
				or
				Vector(clamp(value[1] or 0, -16386, 16386), clamp(value[2] or 0, -16386, 16386), clamp(value[3] or 0, -16386, 16386))
			return false
		end,
	},
	__call = function(t)
		
	end
}

local DEFAULT_LIMITS = {
	-- These limits are not made up, they are straight from Source Engine SDK
	-- https://github.com/ValveSoftware/source-sdk-2013/blob/master/src/game/shared/effect_dispatch_data.cpp
	attachment = { min = 0, max = 31, default = 0 },
	color = { min = 0, max = 255, default = 0 },
	damagetype = { min = 0, max = DMG_MISSILEDEFENSE, default = 0 },
	entindex = { min = -1, max = 8192, default = -1 },
	flags = { min = 0, max = 255, default = 0 },
	hitbox = { min = 0, max = 2047, default = 0 },
	magnitude = { min = 0, max = 1023, default = 0 },
	materialindex = { min = 0, max = 4095, default = 0 },
	normal = { default = Vector(0, 0, 1) },
	origin = { default = Vector() },
	radius = { min = 0, max = 1023, default = 0 },
	scale = { min = -1e6, max = 1e6, default = 1 }, -- full 32-bit float in engine, but we clamp it
	start = { default = Vector() },
	surfaceprop = { min = -1, max = 254, default = -1 },
}

local EFFECT_LIMITS = setmetatable({
	teslahitboxes = setmetatable({
		magnitude = { min = 0, max = 32, default = 0 },
		radius = { min = 0, max = 512, default = 0 },
		scale = { min = 0, max = 16, default = 1 },
	}, __index = DEFAULT_LIMITS)
}, __index = function() return DEFAULT_LIMITS end)


-- Exposed, so addons can modify these if needed.
SF.effect_blacklist = EFFECT_BLACKLIST
SF.effect_limits = EFFECT_LIMITS
SF.default_effect_limits = DEFAULT_LIMITS



-- Effect structure
local Effect = {

	-- Mapping of SF internal keys -> CEffectData setter methods
	setters = {
		angles = function(ed, v) ed:SetAngles(Angle(tonumber(v[1]) or 0, tonumber(v[2]) or 0, tonumber(v[3]) or 0)) end,
		attachment = function(ed, v) ed:SetAttachment(v) end,
		color = function(ed, v) ed:SetColor(v) end,
		damagetype = function(ed, v) ed:SetDamageType(v) end,
		entindex = function(ed, v) ed:SetEntIndex(v) end,
		entity = function(ed, v) ed:SetEntity(v or NULL) end,
		flags = function(ed, v) ed:SetFlags(v) end,
		hitbox = function(ed, v) ed:SetHitBox(v) end,
		magnitude = function(ed, v) ed:SetMagnitude(v) end,
		materialindex = function(ed, v) ed:SetMaterialIndex(v) end,
		normal = function(ed, v) ed:SetNormal(v) end,
		origin = function(ed, v) ed:SetOrigin(v) end,
		radius = function(ed, v) ed:SetRadius(v) end,
		scale = function(ed, v) ed:SetScale(v) end,
		start = function(ed, v) ed:SetStart(v) end,
		surfaceprop = function(ed, v) ed:SetSurfaceProp(v) end,
	},

	__index = {
		-- Validates effect data against limits for a specific effect name
		set = function(self, key, value)
			self.limits[key]:set(self.data, value)
		end,

		-- Plays the effect with full validation and burst checking
		play = function(self, eff)
			local ed = EffectData()
			for k, v in pairs(self.data) do
				Effect.setters[k](ed, v)
			end
			util.Effect(eff, ed)
		end,
	}

	__call = function(t, name)
		return setmetatable({name = name, data = {}, limits = EFFECT_LIMITS[name]}, t)
	end,
}
setmetatable(Effect, Effect)


--- Effects library.
-- See also https://wiki.facepunch.com/gmod/Default_Effects
-- @name effect
-- @class library
-- @libtbl effect_library
SF.RegisterLibrary("effect")

--- Effect type
-- @name Effect
-- @class type
-- @libtbl effect_methods
SF.RegisterType("Effect", true, false)


return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local effect_library = instance.Libraries.effect
local effect_methods, effect_meta, wrap, unwrap = instance.Types.Effect.Methods, instance.Types.Effect, instance.Types.Effect.Wrap, instance.Types.Effect.Unwrap
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local col_meta, cwrap, cunwrap = instance.Types.Color, instance.Types.Color.Wrap, instance.Types.Color.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap

local vunwrap1
local aunwrap1
instance:AddHook("initialize", function()
	vunwrap1 = vec_meta.QuickUnwrap1
	aunwrap1 = ang_meta.QuickUnwrap1
end)

----------------------------------------------------------------------
-- Library & Method Bindings
----------------------------------------------------------------------

--- Creates an effect data structure
-- @param string name The effect type name to play
-- @return Effect Effect object
function effect_library.create(name)
	checkluatype(name, TYPE_STRING)
	name = string.lower(name)
	if EFFECT_BLACKLIST[name] then
		SF.Throw("Effect (" .. name .. ") is blacklisted", 3)
	end
	return wrap(Effect(name))
end

--- Returns the number of effects that can still be created within the burst quota
-- @return number Number of remaining effects allowed by the burst quota
function effect_library.effectsLeft()
	return plyEffectBurst:check(instance.player)
end

--- Returns whether another effect can be created within the burst quota
-- @return boolean True if a new effect may be created, false otherwise
function effect_library.canCreate()
	return plyEffectBurst:check(instance.player) >= 1
end

--- Creates a "beam ring point" effect, like the AR2 orb explosion
-- @param Vector pos The origin position of the effect
-- @param number lifetime How long the effect will be drawing for, in seconds (clamped: 0 to 25.6)
-- @param number startRad Initial radius of the effect (clamped: -4096 to 4096)
-- @param number endRad Final radius of the effect (clamped: -4096 to 4096)
-- @param number width How thick the beam should be (clamped: 0 to 128)
-- @param number amplitude How noisy the beam should be (clamped: 0 to 64)
-- @param Color color Color
-- @param number? speed Causes the beam to start faded if set to any integer other than 0 (clamped: 0 to 255)
-- @param number? flags Beam flags
-- @param number? framerate Texture framerate (clamped: 0 to 255)
-- @param string? material The material to use instead of the default one
function effect_library.beamRingPoint(pos, lifetime, startRad, endRad, width, amplitude, color, speed, flags, framerate, material)
	pos = vunwrap1(pos)
	checkvector(pos)
	checkpermission(instance, nil, "effect.play")

	plyEffectBurst:use(instance.player, 1)

	lifetime = clamp(lifetime, 0, 25.6)
	startRad = clamp(startRad, -4096, 4096)
	endRad = clamp(endRad, -4096, 4096)
	width = clamp(width, 0, 128)
	amplitude = clamp(amplitude, 0, 64)

	effects.BeamRingPoint(pos, lifetime, startRad, endRad, width, amplitude, cunwrap(color), {
		speed = speed and clamp(speed, 0, 255),
		flags = flags,
		framerate = framerate and clamp(framerate, 0, 255),
		material = material,
	})
end

--- Plays the effect.
-- See also https://wiki.facepunch.com/gmod/Default_Effects
function effect_methods:play()
	checkpermission(instance, nil, "effect.play")
	local eff = unwrap(self)
	if hook.Run("Starfall_CanEffect", eff.name, instance) == false then
		SF.Throw("Effect (" .. eff.name .. ") has been blocked from running", 3)
	end
	plyEffectBurst:use(instance.player, 1)
	eff:play()
end

----------------------------------------------------------------------
-- Getters / Setters (bridge between SF types and OO internals)
----------------------------------------------------------------------

--- Returns the effect's angle
-- @return Angle The effect's angle
function effect_methods:getAngles()
	return awrap(unwrap(self):get("angles"))
end

--- Returns the effect's attachment
-- @return number The effect's attachment index (from 0 to 31)
function effect_methods:getAttachment()
	return unwrap(self):get("attachment")
end

--- Returns byte which represents the color of the effect
-- @return number The effect's color as a byte (from 0 to 255)
function effect_methods:getColor()
	return unwrap(self):get("color")
end

--- Returns the effect's damage type
-- @return number The effect's damage type (see DMG enum)
function effect_methods:getDamageType()
	return unwrap(self):get("damagetype")
end

--- Returns the effect's entindex
-- @return number The effect's entindex, or -1 if invalid
function effect_methods:getEntIndex()
	local data = unwrap(self)
	if data.useEntity then
		return IsValid(data.entity) and data.entity:EntIndex() or -1
	end
	local x = tonumber(data.entindex)
	if not x or x ~= x then
		x = -1 -- we treat -1 as invalid
	end
	return floor(x)
end

--- Returns the effect's entity
-- @return Entity The effect's entity, or NULL if invalid
function effect_methods:getEntity()
	local data = unwrap(self)
	if data.useEntity then
		return ewrap(data.entity or NULL)
	end
	local x = tonumber(data.entindex)
	if not x or x ~= x then
		return ewrap(NULL)
	end
	return ewrap(Entity(clamp(floor(x), -1, 8192))) -- -1 will yield NULL
end

--- Returns the effect's flags
-- What flags do depends entirely on the effect
-- See also https://wiki.facepunch.com/gmod/Default_Effects
-- @return number The effect's flags (each effect has their own flags)
function effect_methods:getFlags()
	return unwrap(self).flags
end

--- Returns the effect's hitbox index
-- @return number The effect's hitbox index (from 0 to 2047)
function effect_methods:getHitBox()
	return unwrap(self).hitbox
end

--- Returns the effect's magnitude
-- @return number The effect's magnitude (from 0 to 1023)
function effect_methods:getMagnitude()
	return unwrap(self).magnitude
end

--- Returns the effect's material index
-- @return number The effect's material index (from 0 to 4095)
function effect_methods:getMaterialIndex()
	return unwrap(self).materialindex
end

--- Returns the effect's normal
-- @return Vector The effect's normal
function effect_methods:getNormal()
	return vwrap(unwrap(self).normal)
end

--- Returns the effect's origin
-- @return Vector The effect's origin
function effect_methods:getOrigin()
	return vwrap(unwrap(self).origin)
end

--- Returns the effect's radius
-- @return number The effect's radius (from 0 to 1023)
function effect_methods:getRadius()
	return unwrap(self).radius
end

--- Returns the effect's scale
-- @return number The effect's scale (clamped: +-1e6)
function effect_methods:getScale()
	return unwrap(self).scale
end

--- Returns the effect's start position
-- @return Vector The effect's start position (limited to +-16386 on every axis)
function effect_methods:getStart()
	return vwrap(unwrap(self).start)
end

--- Returns the effect's surface property index
-- @return number The effect's surface property index (from -1 to 254)
function effect_methods:getSurfaceProp()
	return unwrap(self).surfaceprop
end

--- Sets the effect's angles
-- @param Angle ang The angles
function effect_methods:setAngles(ang)
	unwrap(self).angles = aunwrap1(ang)
end

--- Sets the effect's attachment index
-- @param number attachment The new attachment index of the effect (from 0 to 31)
function effect_methods:setAttachment(attachment)
	checkluatype(attachment, TYPE_NUMBER)
	unwrap(self).attachment = attachment
end

--- Sets the effect's color.
-- Internally stored as an integer, but only first 8 bits are networked (from 0 to 255).
-- What this will actually do will vary from effect to effect, depending on how a specific effect uses this given data, if at all.
-- @param number color The color represented by a byte (from 0 to 255)
function effect_methods:setColor(color)
	checkluatype(color, TYPE_NUMBER)
	unwrap(self).color = color
end

--- Sets the effect's damage type
-- @param number dmgtype The damage type (see DMG enum)
function effect_methods:setDamageType(dmgtype)
	checkluatype(dmgtype, TYPE_NUMBER)
	unwrap(self).damagetype = dmgtype
end

--- Sets the effect's entity index
-- @param number index The entity index
function effect_methods:setEntIndex(index)
	checkluatype(index, TYPE_NUMBER)
	local data = unwrap(self)
	data.useEntity = false
	data.entindex = index
end

--- Sets the effect's entity
-- @param Entity ent The entity
function effect_methods:setEntity(ent)
	local data = unwrap(self)
	data.useEntity = true
	data.entity = eunwrap(ent)
end

--- Sets the effect's flags.
-- What flags do depends entirely on the effect.
-- See also https://wiki.facepunch.com/gmod/Default_Effects
-- @param number flags The flags to set (each effect has their own flags; from 0 to 255)
function effect_methods:setFlags(flags)
	checkluatype(flags, TYPE_NUMBER)
	unwrap(self).flags = flags
end

--- Sets the effect's hitbox
-- @param number hitbox The hitbox index of the effect (from 0 to 2047)
function effect_methods:setHitBox(hitbox)
	checkluatype(hitbox, TYPE_NUMBER)
	unwrap(self).hitbox = hitbox
end

--- Sets the effect's magnitude
-- @param number magnitude The magnitude of the effect (from 0 to 1023)
function effect_methods:setMagnitude(magnitude)
	checkluatype(magnitude, TYPE_NUMBER)
	unwrap(self).magnitude = magnitude
end

--- Sets the effect's material index
-- @param number mat The material index of the effect (from 0 to 4095)
function effect_methods:setMaterialIndex(mat)
	checkluatype(mat, TYPE_NUMBER)
	unwrap(self).materialindex = mat
end

--- Sets the normalized (length=1) direction vector of the effect
-- This must be a normalized vector for networking purposes
-- @param Vector normal The normalized direction vector of the effect
function effect_methods:setNormal(normal)
	unwrap(self).normal = vunwrap1(normal)
end

--- Sets the effect's origin
-- Limited to world bounds (+-16386 on every axis), and has horrible networking precision (17 bit float per component).
-- @param Vector origin The origin of the effect
function effect_methods:setOrigin(origin)
	unwrap(self).origin = vunwrap1(origin)
end

--- Sets the effect's radius
-- @param number radius The radius of the effect (from 0 to 1023)
function effect_methods:setRadius(radius)
	checkluatype(radius, TYPE_NUMBER)
	unwrap(self).radius = radius
end

--- Sets the effect's scale
-- @param number scale The scale of the effect (clamped: +-1e6)
function effect_methods:setScale(scale)
	checkluatype(scale, TYPE_NUMBER)
	unwrap(self).scale = scale
end

--- Sets the effect's start position
-- Limited to world bounds (+-16386 on every axis), and has horrible networking precision (17 bit float per component).
-- @param Vector start The start position of the effect
function effect_methods:setStart(start)
	unwrap(self).start = vunwrap1(start)
end

--- Sets the effect's surface property
-- Internally stored as an integer, but only first 8 bits are networked (from -1 to 254, yes, that's not a mistake).
-- @param number prop The surface property index of the effect
function effect_methods:setSurfaceProp(prop)
	checkluatype(prop, TYPE_NUMBER)
	unwrap(self):set("surfaceprop", prop)
end

end
