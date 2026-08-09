-- Global to all starfalls
local clamp = math.Clamp
local floor = math.floor
local checkluatype = SF.CheckLuaType
local checknumber = SF.CheckNumber
local checkvector = SF.CheckVector
local clampPos = SF.clampPos

-- Register Privileges
SF.Permissions.registerPrivilege("effect.play", "Effect", "Allows the user to play effects", { client = {} })

local plyEffectBurst = SF.BurstObject("effects", "effects", 30, 5, "The rate at which effects can be spawned per second.", "Number of effects that can be spawned in a short time.")

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

-- Hard per-frame effect limit.
-- This prevents one chip from flooding the frame with expensive effects.
local MAX_EFFECTS_PER_FRAME = 8

-- Client-side convar to tune the per-frame limit (if desired).
local EFFECT_FRAME_LIMIT_CONVAR
if CLIENT then
	EFFECT_FRAME_LIMIT_CONVAR = CreateConVar("sf_effect_frame_limit", tostring(MAX_EFFECTS_PER_FRAME), FCVAR_ARCHIVE, "Maximum number of effects a single Starfall chip can spawn per frame")
end

-- Weak-keyed table mapping EffectData userdata -> effect name string.
-- C++ userdata cannot have Lua fields attached, so we store the name here.
local effectNames = setmetatable({}, { __mode = "k" })

-- Instance-local effect frame counters, keyed by instance.
-- Weak keys allow GC when instances are removed.
local instanceEffectData = setmetatable({}, { __mode = "k" })

if CLIENT then
	hook.Add("PreRender", "SF_PreRender_ResetEffectFrameCount", function()
		for _, d in next, instanceEffectData do
			d.frameCount = 0
		end
	end)
end


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
local effectdata

local function getLimits(eff)
	local name
	if type(eff) == "string" then
		name = eff
	else
		local ed = unwrap(eff)
		name = effectNames[ed] or ""
	end
	local limits = EFFECT_LIMITS[string.lower(name)]
	if limits then return limits end
	return DEFAULT_LIMITS
end

local function checkRange(value, min, max, field)
	if value ~= value or value < min or value > max then
		SF.Throw("Effect " .. field .. " must be between " .. min .. " and " .. max, 3)
	end
	return value
end

local function checkEffectField(eff, value, field)
	local r = getLimits(eff)[field]
	return checkRange(value, r[1], r[2], field)
end

local function clampInt(x, min, max)
	checknumber(x)
	x = floor(x)
	return clamp(x, min, max)
end

local function clampNormal(raw)
	local n = Vector(raw.x, raw.y, raw.z)
	if n:LengthSqr() > 0 then
		n:Normalize()
	else
		n = Vector(0, 0, 1)
	end
	return n
end

-- Sanitize all fields on an EffectData object before calling util.Effect.
-- This is the critical crash-prevention step.
local function sanitizeEffectData(ed, eff)
	checkEffectField(eff, ed:GetMagnitude(), "magnitude")
	checkEffectField(eff, ed:GetRadius(), "radius")
	checkEffectField(eff, ed:GetScale(), "scale")

	ed:SetDamageType(clampInt(ed:GetDamageType(), 0, GLOBAL_EFFECT_LIMITS.damage))
	ed:SetSurfaceProp(clampInt(ed:GetSurfaceProp(), GLOBAL_EFFECT_LIMITS.surfaceprop_min, GLOBAL_EFFECT_LIMITS.surfaceprop_max))
	ed:SetFlags(clampInt(ed:GetFlags(), 0, GLOBAL_EFFECT_LIMITS.flags))
	ed:SetColor(clampInt(ed:GetColor(), 0, 255))

	ed:SetAttachment(clampInt(ed:GetAttachment(), 0, 31))
	ed:SetEntIndex(clampInt(ed:GetEntIndex(), 0, 8192))
	ed:SetHitBox(clampInt(ed:GetHitBox(), 0, 2047))
	ed:SetMaterialIndex(clampInt(ed:GetMaterialIndex(), 0, 4095))

	ed:SetOrigin(clampPos(ed:GetOrigin()))
	ed:SetStart(clampPos(ed:GetStart()))
	ed:SetNormal(clampNormal(ed:GetNormal()))
end

instance:AddHook("initialize", function()
	vunwrap1 = vec_meta.QuickUnwrap1
	aunwrap1 = ang_meta.QuickUnwrap1
	effectdata = { frameCount = 0 }
	instanceEffectData[instance] = effectdata
end)

instance:AddHook("deinitialize", function()
	instanceEffectData[instance] = nil
end)

--- Creates an effect data structure
-- @return Effect Effect Object
function effect_library.create()
	if CLIENT then
		local limit = EFFECT_FRAME_LIMIT_CONVAR and EFFECT_FRAME_LIMIT_CONVAR:GetInt() or MAX_EFFECTS_PER_FRAME
		if effectdata.frameCount >= limit then
			SF.Throw("Too many effects spawned in one frame", 2)
		end
		effectdata.frameCount = effectdata.frameCount + 1
	end
	return wrap(EffectData())
end

--- Returns number of effects able to be created
-- @return number Number of effects able to be created
function effect_library.effectsLeft()
	return plyEffectBurst:check(instance.player)
end

--- Returns whether there are any effects able to be played
-- @return boolean If an effect can be played
function effect_library.canCreate()
	if plyEffectBurst:check(instance.player) < 1 then return false end
	if CLIENT then
		local limit = EFFECT_FRAME_LIMIT_CONVAR and EFFECT_FRAME_LIMIT_CONVAR:GetInt() or MAX_EFFECTS_PER_FRAME
		if effectdata.frameCount >= limit then return false end
	end
	return true
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
	plyEffectBurst:use(instance.player, 1)

	lifetime = math.Clamp(lifetime, 0, 25.6)
	startRad = math.Clamp(startRad, -4096, 4096)
	endRad = math.Clamp(endRad, -4096, 4096)
	width = math.Clamp(width, 0, 128)
	amplitude = math.Clamp(amplitude, 0, 64)

	effects.BeamRingPoint(pos, lifetime, startRad, endRad, width, amplitude, cunwrap(color), {
		speed = speed and math.Clamp(speed, 0, 255) or nil,
		flags = flags,
		framerate = framerate and math.Clamp(framerate, 0, 255) or nil,
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

	if instance.player ~= SF.Superuser and hook.Run("PlayerSpawnEffect", instance.player, eff) == false then
		SF.Throw("Cannot spawn effect (" .. eff .. ")", 2)
	end

	if CLIENT then
		local limit = EFFECT_FRAME_LIMIT_CONVAR and EFFECT_FRAME_LIMIT_CONVAR:GetInt() or MAX_EFFECTS_PER_FRAME
		if limit > 0 and effectdata.frameCount >= limit then
			SF.Throw("Too many effects spawned in one frame", 2)
		end
	end

	local ed = unwrap(self)
	if not IsValid(ed) then
		SF.Throw("Invalid effect data", 2)
	end

	effectNames[ed] = eff

	-- Sanitize before using burst so invalid data does not consume burst quota.
	sanitizeEffectData(ed, eff)

	plyEffectBurst:use(instance.player, 1)

	if CLIENT then
		effectdata.frameCount = effectdata.frameCount + 1
	end

	util.Effect(eff, ed)
end

--- Returns the effect's angle
-- @return Angle The effect's angle
function effect_methods:getAngles()
	return awrap(unwrap(self):GetAngles())
end

--- Returns the effect's attachment
-- @return number The effect's attachment ID
function effect_methods:getAttachment()
	return unwrap(self):GetAttachment()
end

--- Returns byte which represents the color of the effect.
-- @return number The effect's color as a byte
function effect_methods:getColor()
	return unwrap(self):GetColor()
end

--- Returns the effect's damagetype
-- @return number The effect's damagetype
function effect_methods:getDamageType()
	return unwrap(self):GetDamageType()
end

--- Returns the effect's entindex
-- @return number The effect's entindex
function effect_methods:getEntIndex()
	return unwrap(self):GetEntIndex()
end

--- Returns the effect's entity
-- @return Entity The effect's entity
function effect_methods:getEntity()
	return ewrap(unwrap(self):GetEntity())
end

--- Returns the effect's flags
-- @return number The effect's flags
function effect_methods:getFlags()
	return unwrap(self):GetFlags()
end

--- Returns the effect's hitbox ID
-- @return number The effect's hitbox ID
function effect_methods:getHitBox()
	return unwrap(self):GetHitBox()
end

--- Returns the effect's magnitude
-- @return number The effect's magnitude
function effect_methods:getMagnitude()
	return unwrap(self):GetMagnitude()
end

--- Returns the effect's material index
-- @return number The effect's material index
function effect_methods:getMaterialIndex()
	return unwrap(self):GetMaterialIndex()
end

--- Returns the effect's normal
-- @return Vector The effect's normal
function effect_methods:getNormal()
	return vwrap(unwrap(self):GetNormal())
end

--- Returns the effect's origin
-- @return Vector The effect's origin
function effect_methods:getOrigin()
	return vwrap(unwrap(self):GetOrigin())
end

--- Returns the effect's radius
-- @return number The effect's radius
function effect_methods:getRadius()
	return unwrap(self):GetRadius()
end

--- Returns the effect's scale
-- @return number The effect's scale
function effect_methods:getScale()
	return unwrap(self):GetScale()
end

--- Returns the effect's start position
-- @return Vector The effect's start position
function effect_methods:getStart()
	return vwrap(unwrap(self):GetStart())
end

--- Returns the effect's surface prop
-- @return number The effect's surface property index
function effect_methods:getSurfaceProp()
	return unwrap(self):GetSurfaceProp()
end

--- Sets the effect's angles
-- @param Angle ang The angles
function effect_methods:setAngles(ang)
	unwrap(self):SetAngles(aunwrap1(ang))
end

--- Sets the effect's attachment
-- @param number attachment The new attachment ID of the effect
function effect_methods:setAttachment(attachment)
	checkluatype(attachment, TYPE_NUMBER)
	unwrap(self):SetAttachment(clampInt(attachment, 0, 31))
end

--- Sets the effect's color
-- Internally stored as an integer, but only first 8 bits are networked, effectively limiting this function to 0-255 range.
-- @param number color The color represented by a byte 0-255.
function effect_methods:setColor(color)
	checkluatype(color, TYPE_NUMBER)
	unwrap(self):SetColor(clampInt(color, 0, 255))
end

--- Sets the effect's damage type
-- @param number dmgtype The damage type, see the DMG enums
function effect_methods:setDamageType(dmgtype)
	checkluatype(dmgtype, TYPE_NUMBER)
	unwrap(self):SetDamageType(clampInt(dmgtype, 0, GLOBAL_EFFECT_LIMITS.damage))
end

--- Sets the effect's entity index
-- @param number index The entity index
function effect_methods:setEntIndex(index)
	checkluatype(index, TYPE_NUMBER)
	unwrap(self):SetEntIndex(clampInt(index, 0, 8192))
end

--- Sets the effect's entity
-- @param Entity ent The entity
function effect_methods:setEntity(ent)
	unwrap(self):SetEntity(eunwrap(ent))
end

--- Sets the effect's flags
-- @param number flags The flags
function effect_methods:setFlags(flags)
	checkluatype(flags, TYPE_NUMBER)
	unwrap(self):SetFlags(clampInt(flags, 0, GLOBAL_EFFECT_LIMITS.flags))
end

--- Sets the effect's hitbox
-- @param number hitbox The hitbox
function effect_methods:setHitBox(hitbox)
	checkluatype(hitbox, TYPE_NUMBER)
	unwrap(self):SetHitBox(clampInt(hitbox, 0, 2047))
end

--- Sets the effect's magnitude
-- @param number magnitude The magnitude
function effect_methods:setMagnitude(magnitude)
	checkluatype(magnitude, TYPE_NUMBER)
	unwrap(self):SetMagnitude(checkEffectField(self, magnitude, "magnitude"))
end

--- Sets the effect's material index
-- @param number mat The material index
function effect_methods:setMaterialIndex(mat)
	checkluatype(mat, TYPE_NUMBER)
	unwrap(self):SetMaterialIndex(clampInt(mat, 0, 4095))
end

--- Sets the effect's normal
-- @param Vector normal The vector normal
function effect_methods:setNormal(normal)
	unwrap(self):SetNormal(clampNormal(vunwrap1(normal)))
end

--- Sets the effect's origin
-- @param Vector origin The vector origin
function effect_methods:setOrigin(origin)
	unwrap(self):SetOrigin(clampPos(vunwrap1(origin)))
end

--- Sets the effect's radius
-- @param number radius The radius
function effect_methods:setRadius(radius)
	checkluatype(radius, TYPE_NUMBER)
	unwrap(self):SetRadius(checkEffectField(self, radius, "radius"))
end

--- Sets the effect's scale
-- @param number scale The number scale
function effect_methods:setScale(scale)
	checkluatype(scale, TYPE_NUMBER)
	unwrap(self):SetScale(checkEffectField(self, scale, "scale"))
end

--- Sets the effect's start pos
-- Limited to world bounds (+-16386 on every axis) and has horrible networking precision. (17 bit float per component)
-- @param Vector start The vector start
function effect_methods:setStart(start)
	unwrap(self):SetStart(clampPos(vunwrap1(start)))
end

--- Sets the effect's surface property
-- Internally stored as an integer, but only first 8 bits are networked, effectively limiting this function to -1-254 range.(yes, that's not a mistake)
-- @param number prop The surface property index
function effect_methods:setSurfaceProp(prop)
	checkluatype(prop, TYPE_NUMBER)
	unwrap(self):SetSurfaceProp(clampInt(prop, GLOBAL_EFFECT_LIMITS.surfaceprop_min, GLOBAL_EFFECT_LIMITS.surfaceprop_max))
end

end
