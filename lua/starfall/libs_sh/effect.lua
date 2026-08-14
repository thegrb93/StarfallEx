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

-- Helper checker for range properties
local function checkRange(self, value)
	return value ~= value or value < limit.min or value > limit.max
end,

-- Helper checker for normal vector (validates and normalizes)
local function checkNormal(self, value)
	-- As per GMod docs, effect's normal must be a normalized (length=1) vector for networking purposes
	local n = isvector(value) and value or Vector(value[1] or 0, value[2] or 0, value[3] or 0)
	-- Store as Vector for consistency with Effect object storage
	self[key] = n:LengthSqr() > 0 and n:GetNormalized() or Vector(0, 0, 1)
	return false
end,

-- Helper checker for position vectors (validates and clamps to world bounds)
local function checkPos(self, value)
	-- Store as Vector for consistency with Effect object storage
	self[key] = isvector(value) and
		Vector(clamp(value[1], -16386, 16386), clamp(value[2], -16386, 16386), clamp(value[3], -16386, 16386))
		or
		Vector(clamp(value[1] or 0, -16386, 16386), clamp(value[2] or 0, -16386, 16386), clamp(value[3] or 0, -16386, 16386))
	return false
end

local EFFECT_LIMITS = {
	teslahitboxes = {
		magnitude = { min = 0, max = 32, default = 0 },
		radius = { min = 0, max = 512, default = 0 },
		scale = { min = 0, max = 16, default = 1 },
	}
}

local EFFECT_SETTERS = {
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
}

-- Exposed, so addons can modify these if needed.
SF.effect_blacklist = EFFECT_BLACKLIST
SF.effect_limits = EFFECT_LIMITS


--- Effects library.
-- See also https://wiki.facepunch.com/gmod/Default_Effects
-- @name effect
-- @class library
-- @libtbl effect_library
SF.RegisterLibrary("effect")


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
-- @param table data The effect data table with keys:
-- angles - Angle angle of the effect
-- attachment - number Entity attachment id to attach to
-- color - Color The color to set the effect
-- damagetype - number The damage type of the effect
-- entindex - number The entity index to set the effect to
-- entity - Entity entity to set the effect to
-- flags - number Flags to add to the effect
-- hitbox - number The hitbox id of the effect
-- magnitude - number A magnitude value of the effect
-- materialindex - number The material index of the effect
-- normal - Vector A normal vector of the effect
-- origin - Vector The origin vector of the effect
-- radius - number The radius value of the effect
-- scale - number The scale value of the effect
-- start - Vector the start vector of the effect
-- surfaceprop - number The surfaceprop id of the effect
function effect_library.play(name, data)
	checkluatype(name, TYPE_STRING)
	checkluatype(data, TYPE_TABLE)
	checkpermission(instance, nil, "effect.play")

	name = string.lower(name)
	if EFFECT_BLACKLIST[name] then
		SF.Throw("Effect (" .. name .. ") is blacklisted", 3)
	end

	if hook.Run("Starfall_CanEffect", name, instance) == false then
		SF.Throw("Effect (" .. name .. ") has been blocked from running", 3)
	end

	plyEffectBurst:use(instance.player, 1)

	local limit = EFFECT_LIMITS[name]

	local eff = EffectData()
	if limit then
		for k, v in pairs(limit) do
			local val = data[k] or v.default
			v:check(val)
			local setter = EFFECT_SETTERS[k] or SF.Throw("Invalid data key: "..k, 2)
			setter(eff, val)
		end
		for k, v in pairs(data) do
			if limit[k] then continue end
			local setter = EFFECT_SETTERS[k] or SF.Throw("Invalid data key: "..k, 2)
			setter(eff, v)
		end
	else
		for k, v in pairs(data) do
			local setter = EFFECT_SETTERS[k] or SF.Throw("Invalid data key: "..k, 2)
			setter(eff, v)
		end
	end
	util.Effect(name, eff)
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

end
