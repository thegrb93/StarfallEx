-- Global to all Starfalls
local clamp = math.Clamp
local checkluatype = SF.CheckLuaType
local checknumber = SF.CheckNumber
local checkvector = SF.CheckVector

-- Register Privileges
SF.Permissions.registerPrivilege("effect.create", "Effect", "Allows the user to create effects", { client = {} })

local plyEffectBurst = SF.BurstObject("effects", "effects", 60, 5, "The rate at which effects can be spawned per second.", "Number of effects that can be spawned in a short time.")
SF.ResourceCounters.Effects = {icon = "icon16/bullet_star.png", count = function(ply) return plyEffectBurst.max - plyEffectBurst:check(ply) end}

-- Effect blacklist (keys are lowercase name).
local EFFECT_BLACKLIST = {
	dof_node = true, -- Material effect used by depth of field effect.
	smoke = true,   -- Creates a bunch of messed up smoke that can't be deleted, not recommended.
}

-- Helper checker for range properties
local function checkNumberRange(min, max)
	return function(val)
		if val ~= val or val < min or val > max then
			error("Value is out of bounds! (min = "..min..", max = "..max..", val = "..val..")")
		end
	end
end

local EFFECT_LIMITS = {
	teslahitboxes = {
		magnitude = checkNumberRange(0, 32),
		radius = checkNumberRange(0, 512),
		scale = checkNumberRange(0, 16),
	}
}

-- Exposed, so addons can modify these if needed.
SF.effect_blacklist = EFFECT_BLACKLIST
SF.effect_limits = EFFECT_LIMITS

local EffectMember = {
	__index = {
		setDefault = function(self, eff)
			eff[self.setfunc](eff, self.default)
		end,

		setLimited = function(self, eff, limitfunc, val)
			val = self.unwrapfunc(val)
			limitfunc(val)
			eff[self.setfunc](eff, val)
		end,

		set = function(self, eff, val)
			eff[self.setfunc](eff, self.unwrapfunc(val))
		end,
	},
	__call = function(t, default, setfunc, unwrapfunc)
		return setmetatable({
			default = default,
			setfunc = setfunc,
			unwrapfunc = unwrapfunc or function(v) return v end,
		}, t)
	end
}
setmetatable(EffectMember, EffectMember)


--- Effects library.
-- See also https://wiki.facepunch.com/gmod/Default_Effects
-- @name effect
-- @class library
-- @libtbl effect_library
SF.RegisterLibrary("effect")


return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local effect_library = instance.Libraries.effect
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local col_meta, cwrap, cunwrap = instance.Types.Color, instance.Types.Color.Wrap, instance.Types.Color.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap

local vunwrap1, aunwrap1
instance:AddHook("initialize", function()
	vunwrap1 = vec_meta.QuickUnwrap1
	aunwrap1 = ang_meta.QuickUnwrap1
end)

----------------------------------------------------------------------
-- Library & Method Bindings
----------------------------------------------------------------------

local EFFECT_MEMBERS = {
	angles = EffectMember(angle_origin, "SetAngles", function(v) v=aunwrap1(v) checkvector(v) return v end),
	attachment = EffectMember(0, "SetAttachment"),
	color = EffectMember(0, "SetColor"),
	damagetype = EffectMember(0, "SetDamageType"),
	entindex = SERVER and EffectMember(0, "SetEntIndex") or nil,
	entity = EffectMember(NULL, "SetEntity", eunwrap),
	flags = EffectMember(0, "SetFlags"),
	hitbox = EffectMember(0, "SetHitBox"),
	magnitude = EffectMember(0, "SetMagnitude"),
	materialindex = EffectMember(0, "SetMaterialIndex"),
	normal = EffectMember(Vector(1, 0, 0), "SetNormal", function(v) v=vunwrap1(v) checkvector(v) return v end),
	origin = EffectMember(vector_origin, "SetOrigin", function(v) v=vunwrap1(v) checkvector(v) return v end),
	radius = EffectMember(0, "SetRadius"),
	scale = EffectMember(0, "SetScale"),
	start = EffectMember(vector_origin, "SetStart", function(v) v=vunwrap1(v) checkvector(v) return v end),
	surfaceprop = EffectMember(0, "SetSurfaceProp"),
}

--- Creates an effect data structure
-- @param string name The effect type name to create
-- @param table data The effect data table with the following structure:
-- `Angle` angles: The angles of the effect
-- number attachment: The entity attachment index to attach to
-- number color: The color to set the effect (this is an 8 bit color integer specific to the effect implementation)
-- number damagetype: The damage type of the effect
-- number entindex: The entity index to set the effect to (SERVER only)
-- `Entity` entity: The entity to set the effect to
-- number flags: The flags to add to the effect
-- number hitbox: The hitbox index of the effect
-- number magnitude: The magnitude value of the effect
-- number materialindex: The material index of the effect
-- `Vector` normal: The normal vector of the effect
-- `Vector` origin: The origin vector of the effect
-- number radius: The radius value of the effect
-- number scale: The scale value of the effect
-- `Vector` start: The start vector of the effect
-- number surfaceprop: The surfaceprop index of the effect
function effect_library.create(name, data)
	checkluatype(name, TYPE_STRING)
	checkluatype(data, TYPE_TABLE)
	checkpermission(instance, nil, "effect.create")

	name = string.gsub(string.lower(name), "\x00.*", "")
	if EFFECT_BLACKLIST[name] then
		SF.Throw("Effect (" .. name .. ") is blacklisted", 2)
	end

	if hook.Run("Starfall_CanEffect", name, instance) == false then
		SF.Throw("Effect (" .. name .. ") has been blocked from running", 2)
	end

	local settingMember
	local ok, ret = pcall(function()
		local eff = EffectData()
		local limit = EFFECT_LIMITS[name]
		if limit then
			for k, limitfunc in pairs(limit) do
				settingMember = k
				local member = EFFECT_MEMBERS[k] or error("Invalid data key")
				local v = data[k]
				if v then
					member:setLimited(eff, limitfunc, v)
				else
					member:setDefault(eff)
				end
			end
			for k, v in pairs(data) do
				if limit[k] then continue end
				settingMember = k
				local member = EFFECT_MEMBERS[k] or error("Invalid data key")
				member:set(eff, v)
			end
		else
			for k, v in pairs(data) do
				settingMember = k
				local member = EFFECT_MEMBERS[k] or error("Invalid data key")
				member:set(eff, v)
			end
		end
		return eff
	end)
	if not ok then SF.Throw("Error setting member '"..settingMember.."': "..tostring(ret), 2) end

	plyEffectBurst:use(instance.player, 1)
	util.Effect(name, ret)
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
	checkpermission(instance, nil, "effect.create")

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
