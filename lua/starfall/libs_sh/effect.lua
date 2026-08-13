-- Global to all starfalls
local clamp = math.Clamp
local floor = math.floor
local checkluatype = SF.CheckLuaType
local checknumber = SF.CheckNumber
local checkvector = SF.CheckVector
local clampPos = SF.clampPos

-- Register Privileges
SF.Permissions.registerPrivilege("effect.play", "Effect", "Allows the user to play effects", { client = {} })

local plyEffectBurst = SF.BurstObject("effects", "effects", 60, 5, "The rate at which effects can be spawned per second.", "Number of effects that can be spawned in a short time.")

SF.ResourceCounters.Effects = { icon = "icon16/bullet_star.png", count = function(ply) return plyEffectBurst.max - plyEffectBurst:check(ply) end }

-- Effect blacklist (must be lowercase).
local EFFECT_BLACKLIST = {
	dof_node = true,
	--teslahitboxes = true,
}

-- Global hard caps for effect data. Values outside these ranges can crash the engine.
local GLOBAL_EFFECT_LIMITS = {
	damage = DMG_MISSILEDEFENSE,
	flags = 255,
	surfaceprop_min = -1,
	surfaceprop_max = 254,
}

-- Effect-specific overrides for known expensive/dangerous effects.
-- Index: effect name (lowercase) -> { magnitude = {min,max}, scale = {min,max}, radius = {min,max} }
local EFFECT_LIMITS = {
	teslahitboxes = {
		magnitude = { 0, 32 },
		radius    = { 0, 512 },
		scale     = { 0, 16 },
	},
}

-- Default min/max for fields not listed in EFFECT_LIMITS.
local DEFAULT_LIMITS = {
	magnitude = { 0, 1023 },
	radius    = { 0, 1023 },
	scale     = { -1e7, 1e7 },
}

-- Exposed, so addons can modify these if needed.
SF.effect_blacklist = EFFECT_BLACKLIST
SF.global_effect_limits = GLOBAL_EFFECT_LIMITS
SF.effect_limits = EFFECT_LIMITS
SF.default_effect_limits = DEFAULT_LIMITS

-- Convar to limit the number of effects a single Starfall chip can create per frame/tick.
-- Set to 0 to disable the limit (not recommended).
-- Not enforced for superusers.
-- This is intentionally set to 1 to conform to Garry design; read more in the effect_library.create function.
local EFFECT_CREATE_LIMIT_CONVAR = CreateConVar("sf_effect_create_limit" .. (CLIENT and "_cl" or ""), "1", FCVAR_ARCHIVE, "Maximum number of effects a single Starfall chip can create per frame/tick. Set to 0 to disable the limit (not recommended). Not enforced for superusers.")

-- Convar to tune the per-frame limit value.
-- This prevents one chip from flooding the frame with expensive effects.
-- Set to 0 to disable the per-frame limit (not recommended).
local EFFECT_FRAME_LIMIT_CONVAR = CreateConVar("sf_effect_frame_limit" .. (CLIENT and "_cl" or ""), "10", FCVAR_ARCHIVE, "Maximum number of effects a single Starfall chip can play per frame/tick. Set to 0 to disable the limit (not recommended). Not enforced for superusers.")

-- Instance-local effect frame counters, keyed by instance.
-- Weak keys allow GC when instances are removed.
local instanceEffectData = setmetatable({}, { __mode = "k" })

-- Reset effect frame counters every frame on client, or every tick on server.
hook.Add(CLIENT and "PreRender" or "Tick", "SF_ResetEffectFrameCount", function()
	for _, d in next, instanceEffectData do
		d.createCount, d.frameCount = 0, 0
	end
end)


--- Effects library.
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

-- Effect data for this instance
local effectdata

instance:AddHook("initialize", function()
	vunwrap1 = vec_meta.QuickUnwrap1
	aunwrap1 = ang_meta.QuickUnwrap1
	effectdata = { createCount = 0, frameCount = 0 }
	instanceEffectData[instance] = effectdata
end)

instance:AddHook("deinitialize", function()
	instanceEffectData[instance] = nil
end)

local function getLimitsForName(name)
	return EFFECT_LIMITS[string.lower(name)] or DEFAULT_LIMITS
end

local function checkRange(value, min, max, field)
	checknumber(value)
	if value ~= value or value < min or value > max then
		SF.Throw("Effect " .. field .. " must be between " .. min .. " and " .. max, 3)
	end
	return value
end

local function clampInt(x, min, max)
	checknumber(x)
	if x ~= x then
		x = min
	end
	x = floor(x)
	if x ~= x then
		x = min
	end
	return clamp(x, min, max)
end

local function clampNormal(raw)
	checkvector(raw)
	local n = Vector(raw[1], raw[2], raw[3])
	if n:LengthSqr() > 0 then
		n:Normalize()
	else
		n = Vector(0, 0, 1)
	end
	return n
end

local function checkEffectData(self)
	local data = unwrap(self)
	if not istable(data) or not data.__sfeffect then
		SF.Throw("Invalid effect data", 3)
	end
	return data
end

local function newEffectData()
	return {
		__sfeffect = true, -- special field for validation/debugging purposes, leave it alone
		angles = Angle(),
		attachment = 0,
		color = 0,
		damagetype = 0,
		useEntity = false, -- whether to call SetEntity or SetEntIndex
		entindex = -1, -- -1 means invalid (because 0 is the world); skipping SetEntIndex
		entity = NULL,
		flags = 0,
		hitbox = 0,
		magnitude = 0,
		materialindex = 0,
		normal = Vector(0, 0, 1),
		origin = Vector(),
		radius = 0,
		scale = 1,
		start = Vector(),
		surfaceprop = 0,
	}
end

-- Exposed, so addons can use it too.
SF.newEffectData = newEffectData

--- Creates an effect data structure
-- @return Effect Effect object
function effect_library.create()
	-- Superusers can create any number of effects.
	if instance.player ~= SF.Superuser then
		effectdata.createCount = effectdata.createCount + 1
		local limit = EFFECT_CREATE_LIMIT_CONVAR:GetInt()
		if limit > 0 and effectdata.createCount > limit then
			SF.Throw("Effect create limit reached", 2)
		end
	end

	return wrap(newEffectData())
end

--- Returns number of effects able to be created (global burst quota)
-- @return number Number of effects able to be created
function effect_library.effectsLeft()
	return plyEffectBurst:check(instance.player)
end

--- Returns whether a new effect can be created (passes both global burst and lifetime creation limits)
-- @return boolean True if an effect can be created, false otherwise
function effect_library.canCreate()
	-- Superusers can create any number of effects.
	if instance.player == SF.Superuser then return true end
	if plyEffectBurst:check(instance.player) < 1 then return false end
	local limit = EFFECT_CREATE_LIMIT_CONVAR:GetInt()
	return limit <= 0 or effectdata.createCount < limit
end

--- Returns whether a new effect can be played (passes both global burst and per-frame limits)
-- @return boolean True if an effect can be played, false otherwise
function effect_library.canPlay()
	-- Superusers bypass the frame limit.
	if instance.player == SF.Superuser then return true end
	if plyEffectBurst:check(instance.player) < 1 then return false end
	local limit = EFFECT_FRAME_LIMIT_CONVAR:GetInt()
	return limit <= 0 or effectdata.frameCount < limit
end

--- Creates a "beam ring point" effect, like the AR2 orb explosion
-- @param Vector pos The origin position of the effect
-- @param number lifetime How long the effect will be drawing for, in seconds
-- @param number startRad Initial radius of the effect
-- @param number endRad Final radius of the effect
-- @param number width How thick the beam should be
-- @param number amplitude How noisy the beam should be
-- @param Color color Color
-- @param number? speed Causes the beam to start faded if set to any integer other than 0
-- @param number? flags Beam flags
-- @param number? framerate Texture framerate
-- @param string? material The material to use instead of the default one
function effect_library.beamRingPoint(pos, lifetime, startRad, endRad, width, amplitude, color, speed, flags, framerate, material)
	pos = vunwrap1(pos)
	checkvector(pos)

	checkpermission(instance, nil, "effect.play")

	-- Superusers bypass the limits.
	if instance.player ~= SF.Superuser then
		local limit = EFFECT_FRAME_LIMIT_CONVAR:GetInt()
		if limit > 0 and effectdata.frameCount >= limit then
			SF.Throw("Too many effects spawned in one frame", 2)
		end
		plyEffectBurst:use(instance.player, 1)
		if limit > 0 then
			effectdata.frameCount = effectdata.frameCount + 1
		end
	end

	lifetime = math.Clamp(lifetime, 0, 25.6)
	startRad = math.Clamp(startRad, -4096, 4096)
	endRad = math.Clamp(endRad, -4096, 4096)
	width = math.Clamp(width, 0, 128)
	amplitude = math.Clamp(amplitude, 0, 64)

	effects.BeamRingPoint(pos, lifetime, startRad, endRad, width, amplitude, cunwrap(color), {
		speed = speed and math.Clamp(speed, 0, 255),
		flags = flags,
		framerate = framerate and math.Clamp(framerate, 0, 255),
		material = material
	})
end

--- Plays the effect
-- @param string eff The effect type name to play
function effect_methods:play(eff)
	checkluatype(eff, TYPE_STRING)
	checkpermission(instance, nil, "effect.play")

	eff = string.lower(eff)

	if EFFECT_BLACKLIST[eff] then
		SF.Throw("Effect (" .. eff .. ") is blacklisted", 2)
	end

	if hook.Run("Starfall_CanEffect", eff, instance) == false then
		SF.Throw("Effect (" .. eff .. ") has been blocked from running", 2)
	end

	local limit = EFFECT_FRAME_LIMIT_CONVAR:GetInt()

	-- Superusers bypass the frame limit.
	if instance.player ~= SF.Superuser then
		if limit > 0 and effectdata.frameCount >= limit then
			SF.Throw("Too many effects spawned in one frame", 2)
		end
	end

	-- Clamp/Sanitize our SF EffectData structure *before* creating Garry's CEffectData.
	-- (To prevent heap memory exhaustion, GC/JIT mem pressure, etc.)
	local data = checkEffectData(self)
	local limits = getLimitsForName(eff)

	local magnitude = checkRange(data.magnitude, limits.magnitude[1], limits.magnitude[2], "magnitude")
	local radius = checkRange(data.radius, limits.radius[1], limits.radius[2], "radius")
	local scale = checkRange(data.scale, limits.scale[1], limits.scale[2], "scale")

	local attachment = clampInt(data.attachment, 0, 31)
	local color = clampInt(data.color, 0, 255)
	local damagetype = clampInt(data.damagetype, 0, GLOBAL_EFFECT_LIMITS.damage)
	local flags = clampInt(data.flags, 0, GLOBAL_EFFECT_LIMITS.flags)
	local hitbox = clampInt(data.hitbox, 0, 2047)
	local materialindex = clampInt(data.materialindex, 0, 4095)
	local surfaceprop = clampInt(data.surfaceprop, GLOBAL_EFFECT_LIMITS.surfaceprop_min, GLOBAL_EFFECT_LIMITS.surfaceprop_max)

	local angles = Angle(
		tonumber(data.angles[1]) or 0,
		tonumber(data.angles[2]) or 0,
		tonumber(data.angles[3]) or 0
	)

	local normal = clampNormal(data.normal)

	local origin = clampPos(Vector(
		tonumber(data.origin[1]) or 0,
		tonumber(data.origin[2]) or 0,
		tonumber(data.origin[3]) or 0
	))

	local start = clampPos(Vector(
		tonumber(data.start[1]) or 0,
		tonumber(data.start[2]) or 0,
		tonumber(data.start[3]) or 0
	))

	-- Create Garry's CEffectData, feed it with sanitized values, and then play it immediately.
	-- CEffectData is by-Garry-design a 'static singleton' (realloced every time with `EffectData()`).
	-- This means you are not allowed to create multiple instances of it, such as storing them in a table.
	-- Any setters, like SetMagnitude, will only modify the last created instance.
	-- This was probably done for performance reasons.
	-- The intended usage is to call `EffectData()`, followed by setters, and then call `util.Effect`.
	-- Thanks Garry.
	local ed = EffectData()
	-- Ensure C++ object is valid just in case; better be safe than sorry.
	if not IsValid(ed) then
		SF.Throw("Invalid effect data", 2)
	end

	if data.useEntity then
		ed:SetEntity(data.entity or NULL)
	else
		local entIndex = clampInt(data.entindex, -1, 8192)
		if entIndex >= 0 then -- skip if -1
			ed:SetEntIndex(entIndex)
		end
	end

	ed:SetAngles(angles)
	ed:SetAttachment(attachment)
	ed:SetColor(color)
	ed:SetDamageType(damagetype)
	ed:SetFlags(flags)
	ed:SetHitBox(hitbox)
	ed:SetMagnitude(magnitude)
	ed:SetMaterialIndex(materialindex)
	ed:SetNormal(normal)
	ed:SetOrigin(origin)
	ed:SetRadius(radius)
	ed:SetScale(scale)
	ed:SetStart(start)
	ed:SetSurfaceProp(surfaceprop)

	-- Superusers bypass burst/frame quota.
	if instance.player ~= SF.Superuser then
		plyEffectBurst:use(instance.player, 1)

		if limit > 0 then
			effectdata.frameCount = effectdata.frameCount + 1
		end
	end

	util.Effect(eff, ed)
end

--- Returns the effect's angle
-- @return Angle The effect's angle
function effect_methods:getAngles()
	local data = checkEffectData(self)
	return awrap(Angle(data.angles[1], data.angles[2], data.angles[3]))
end

--- Returns the effect's attachment
-- @return number The effect's attachment index
function effect_methods:getAttachment()
	return checkEffectData(self).attachment
end

--- Returns byte which represents the color of the effect
-- @return number The effect's color as a byte (from 0 to 255)
function effect_methods:getColor()
	return checkEffectData(self).color
end

--- Returns the effect's damagetype
-- @return number The effect's damagetype
function effect_methods:getDamageType()
	return checkEffectData(self).damagetype
end

--- Returns the effect's entindex
-- @return number The effect's entindex, or -1 if invalid
function effect_methods:getEntIndex()
	local data = checkEffectData(self)
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
	local data = checkEffectData(self)
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
-- @return number The effect's flags
function effect_methods:getFlags()
	return checkEffectData(self).flags
end

--- Returns the effect's hitbox index
-- @return number The effect's hitbox index
function effect_methods:getHitBox()
	return checkEffectData(self).hitbox
end

--- Returns the effect's magnitude
-- @return number The effect's magnitude
function effect_methods:getMagnitude()
	return checkEffectData(self).magnitude
end

--- Returns the effect's material index
-- @return number The effect's material index
function effect_methods:getMaterialIndex()
	return checkEffectData(self).materialindex
end

--- Returns the effect's normal
-- @return Vector The effect's normal
function effect_methods:getNormal()
	local data = checkEffectData(self)
	return vwrap(Vector(data.normal[1], data.normal[2], data.normal[3]))
end

--- Returns the effect's origin
-- @return Vector The effect's origin
function effect_methods:getOrigin()
	local data = checkEffectData(self)
	return vwrap(Vector(data.origin[1], data.origin[2], data.origin[3]))
end

--- Returns the effect's radius
-- @return number The effect's radius
function effect_methods:getRadius()
	return checkEffectData(self).radius
end

--- Returns the effect's scale
-- @return number The effect's scale
function effect_methods:getScale()
	return checkEffectData(self).scale
end

--- Returns the effect's start position
-- @return Vector The effect's start position
function effect_methods:getStart()
	local data = checkEffectData(self)
	return vwrap(Vector(data.start[1], data.start[2], data.start[3]))
end

--- Returns the effect's surface prop
-- @return number The effect's surface property index (from -1 to 254)
function effect_methods:getSurfaceProp()
	return checkEffectData(self).surfaceprop
end

--- Sets the effect's angles
-- @param Angle ang The angles
function effect_methods:setAngles(ang)
	local a = aunwrap1(ang)
	checkEffectData(self).angles = Angle(a[1], a[2], a[3])
end

--- Sets the effect's attachment index
-- @param number attachment The new attachment index of the effect
function effect_methods:setAttachment(attachment)
	checkluatype(attachment, TYPE_NUMBER)
	checkEffectData(self).attachment = attachment
end

--- Sets the effect's color
-- Internally stored as an integer, but only first 8 bits are networked, effectively limiting this function to 0-255 range.
-- @param number color The color represented by a byte (from 0 to 255).
function effect_methods:setColor(color)
	checkluatype(color, TYPE_NUMBER)
	checkEffectData(self).color = color
end

--- Sets the effect's damage type
-- @param number dmgtype The damage type (see DMG enum)
function effect_methods:setDamageType(dmgtype)
	checkluatype(dmgtype, TYPE_NUMBER)
	checkEffectData(self).damagetype = dmgtype
end

--- Sets the effect's entity index
-- @param number index The entity index
function effect_methods:setEntIndex(index)
	checkluatype(index, TYPE_NUMBER)
	local data = checkEffectData(self)
	data.useEntity = false
	data.entindex = index
end

--- Sets the effect's entity
-- @param Entity ent The entity
function effect_methods:setEntity(ent)
	local data = checkEffectData(self)
	data.useEntity = true
	data.entity = eunwrap(ent)
end

--- Sets the effect's flags
-- @param number flags The flags
function effect_methods:setFlags(flags)
	checkluatype(flags, TYPE_NUMBER)
	checkEffectData(self).flags = flags
end

--- Sets the effect's hitbox
-- @param number hitbox The hitbox index
function effect_methods:setHitBox(hitbox)
	checkluatype(hitbox, TYPE_NUMBER)
	checkEffectData(self).hitbox = hitbox
end

--- Sets the effect's magnitude
-- @param number magnitude The magnitude
function effect_methods:setMagnitude(magnitude)
	checkluatype(magnitude, TYPE_NUMBER)
	checkEffectData(self).magnitude = magnitude
end

--- Sets the effect's material index
-- @param number mat The material index
function effect_methods:setMaterialIndex(mat)
	checkluatype(mat, TYPE_NUMBER)
	checkEffectData(self).materialindex = mat
end

--- Sets the effect's normal
-- @param Vector normal The vector normal
function effect_methods:setNormal(normal)
	local v = vunwrap1(normal)
	checkEffectData(self).normal = Vector(v[1], v[2], v[3])
end

--- Sets the effect's origin
-- @param Vector origin The vector origin
function effect_methods:setOrigin(origin)
	local v = vunwrap1(origin)
	checkEffectData(self).origin = Vector(v[1], v[2], v[3])
end

--- Sets the effect's radius
-- @param number radius The radius
function effect_methods:setRadius(radius)
	checkluatype(radius, TYPE_NUMBER)
	checkEffectData(self).radius = radius
end

--- Sets the effect's scale
-- @param number scale The number scale
function effect_methods:setScale(scale)
	checkluatype(scale, TYPE_NUMBER)
	checkEffectData(self).scale = scale
end

--- Sets the effect's start position
-- Limited to world bounds (+-16386 on every axis), and has horrible networking precision (17 bit float per component).
-- @param Vector start The vector start
function effect_methods:setStart(start)
	local v = vunwrap1(start)
	checkEffectData(self).start = Vector(v[1], v[2], v[3])
end

--- Sets the effect's surface property
-- Internally stored as an integer, but only first 8 bits are networked (from -1 to 254, yes, that's not a mistake).
-- @param number prop The surface property index
function effect_methods:setSurfaceProp(prop)
	checkluatype(prop, TYPE_NUMBER)
	checkEffectData(self).surfaceprop = prop
end

end
