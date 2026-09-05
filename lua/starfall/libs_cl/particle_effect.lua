local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege
local IsValid = IsValid

-- Create permission types.
registerprivilege("particleEffect.attach", "Attach a particle effect", "Allows users to attach particle effects to entities", { client = {}, entities = {} })

local plyCount = SF.LimitObject("particleeffects", "particle effects", 16, "The number of created particle effects via Starfall per client at once")
SF.ResourceCounters.ParticleEffects = {icon = "icon16/asterisk_orange.png", count = function(ply) return plyCount:get(ply) end}

--- ParticleEffect library.
-- @name particleEffect
-- @class library
-- @libtbl particleef_library
SF.RegisterLibrary("particleEffect")

--- ParticleEffect type
-- Created with `particleEffect.attach` function
-- @name ParticleEffect
-- @class type
-- @libtbl particleef_methods
SF.RegisterType("ParticleEffect", false, false)

-- Must precache particle systems, otherwise this library won't work (error: unknown particle system).
-- This has to be done in order for this library to work, otherwise particles from those files won't be usable.
-- We precache all builtin and TF2 PCF since there aren't *that* many, because we can precache any amount on client-side.
-- All works fine even if some of these are missing (e.g. HL Episodes), such as if you don't have the game installed.
-- TODO: Use file.Find? But not sure how to find TF2 PCFs...
for _, name in next, {
	-- Source Engine base (all are on-demand)
	"antlion_blood",
	"blood_impact",
	"burning_fx",
	"combineball",
	"error",
	"fire_01",
	"rocket_fx",
	"train_steam",
	"vortigaunt_fx",
	"water_impact",
	-- GMod specific (all are on-demand)
	"gmod_effects",
	"precipitation",
	-- HL Episodes (all are on-demand)
	"antlion_gib_01",
	"antlion_gib_02",
	"antlion_worker",
	"grub_blood",
	"hunter_flechette",
	"hunter_projectile",
	"striderbuster",
	"vehicle",
	"weapon_fx",
	-- Team Fortress 2 (all are globally precached except level_fx)
	"bigboom",
	"bl_killtaunt",
	"blood_trail",
	"bombinomicon",
	"buildingdamage",
	"bullet_tracers",
	"burningplayer",
	"cig_smoke",
	"cinefx",
	"class_fx",
	"coin_spin",
	"conc_stars",
	"crit",
	"dirty_explode",
	"disguise",
	"doomsday_fx",
	"drg_bison",
	"drg_cowmangler",
	"drg_engineer",
	"drg_pyro",
	"dxhr_fx",
	"explosion",
	"eyeboss",
	"firstperson_weapon_fx",
	"flag_particles",
	"flamethrower",
	"flamethrower_mvm",
	"halloween",
	"halloween2015_unusuals",
	"halloween2016_unusuals",
	"halloween2018_unusuals",
	"halloween2019_unusuals",
	"halloween2020_unusuals",
	"halloween2021_unusuals",
	"halloween2022_unusuals",
	"halloween2023_unusuals",
	"halloween2024_unusuals",
	"halloween2025_unusuals",
	"harbor_fx",
	"impact_fx",
	"invasion_ray_gun_fx",
	"invasion_unusuals",
	"item_fx",
	"items_demo",
	"items_engineer",
	"killstreak",
	--"level_fx", -- marked as on-demand in TF2, so leaving this one out
	"medicgun_attrib",
	"medicgun_beam",
	"muzzle_flash",
	"mvm",
	"nailtrails",
	"nemesis",
	"npc_fx",
	"passtime",
	"passtime_beam",
	"passtime_tv_projection",
	"player_recent_teleport",
	"powerups",
	"rain_custom",
	"rankup",
	"rocketbackblast",
	"rocketjumptrail",
	"rocketpack",
	"rockettrail",
	"rps",
	"scary_ghost",
	"shellejection",
	"smissmas2019_unusuals",
	"smissmas2020_unusuals",
	"smissmas2021_unusuals",
	"smissmas2022_unusuals",
	"smissmas2023_unusuals",
	"smissmas2024_unusuals",
	"smissmas2025_unusuals",
	"smoke_blackbillow",
	"smoke_blackbillow_hoodoo",
	"smoke_island_volcano",
	"soldierbuff",
	"sparks",
	"speechbubbles",
	"stamp_spin",
	"stickybomb",
	"stormfront",
	"summer2020_unusuals",
	"summer2021_unusuals",
	"summer2022_unusuals",
	"summer2023_unusuals",
	"summer2024_unusuals",
	"summer2025_unusuals",
	"summer2026_unusuals",
	"taunt_fx",
	"teleport_status",
	"teleported_fx",
	"training",
	"urban_fx",
	"vgui_menu_particles",
	"water",
	"weapon_unusual_cool",
	"weapon_unusual_energyorb",
	"weapon_unusual_hot",
	"weapon_unusual_isotope",
	"xms",
}
do game.AddParticles("particles/" .. name .. ".pcf") end

-- Blacklist for bad/expensive particle effects (keys are lowercased name).
local particle_effect_blacklist = {
	-- none, yet
}

-- Exposed, so addons can modify it if needed.
-- For example to block all (in case of emergency):
--   setmetatable(SF.particle_effect_blacklist, { __index = function() return true end })
SF.particle_effect_blacklist = particle_effect_blacklist

local function checkValid(peff)
	if not peff:IsValid() then
		SF.Throw("ParticleEffect emitter is no longer valid.", 3)
	end
	return peff -- for method chaining (simpler code)
end

return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local particleef_library = instance.Libraries.particleEffect
local particleef_methods = instance.Types.ParticleEffect.Methods

local particle_meta, wrap, unwrap = instance.Types.ParticleEffect, instance.Types.ParticleEffect.Wrap, instance.Types.ParticleEffect.Unwrap
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap

local vunwrap1
local particleEffects = {}
instance:AddHook("initialize", function()
	vunwrap1 = vec_meta.QuickUnwrap1
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


--- Creates a particle effect (and attaches it to an entity).
-- @param Entity entity The entity to attach the particle effect to (can be world)
-- @param string name The name of the effect to create (e.g. "generic_smoke")
-- @param number pattach See PATTACH enum
-- @param table? options Optional table of tables (indexes 1 to 64) having the following structure:
-- number attachtype - The particle attach type (see PATTACH enum, default: `PATTACH.ABSORIGIN`).
-- `Entity` entity - The parent entity (default: NULL).
-- `Vector` position - The offset position for the given control point (default: nil).
-- This only affects the control points of the particle effects, and will do nothing if the effect doesn't use control points.
-- @return ParticleEffect ParticleEffect object.
function particleef_library.attach(entity, name, pattach, options)
	entity = eunwrap(entity)
	checkluatype(name, TYPE_STRING)
	checkluatype(pattach, TYPE_NUMBER)

	checkpermission(instance, entity, "particleEffect.attach")
	plyCount:checkuse(instance.player, 1)

	name = string.gsub(string.lower(name), "\x00.*", "")

	if instance.player ~= SF.Superuser then
		if particle_effect_blacklist[name] then SF.Throw("Tried to use blacklisted particle effect: "..name, 2) end
		if hook.Run("Starfall_CanParticleEffect", name, instance) == false then SF.Throw("Effect hook blocked using "..name, 2) end
	end

	-- NOTE: There is no precache limit on client-side, but still must precache it!
	PrecacheParticleSystem(name)

	-- Sanitize the options table.
	local cleanOptions
	if options then
		checkluatype(options, TYPE_TABLE)
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

	plyCount:free(instance.player, -1)
	particleEffects[pEffect] = true
	return wrap(pEffect)
end

--- Determines whether the particle effect is valid or not.
-- @return boolean Is valid or not
function particleef_methods:isValid()
	return IsValid(particle_meta.sf2sensitive[self])
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
	if particleEffects[peff] then
		if peff:IsValid() then
			peff:StopEmissionAndDestroyImmediately()
		end
		particleEffects[peff] = nil
		plyCount:free(instance.player, 1)
		particle_meta.sf2sensitive[self] = nil -- make sure that future unwrap throws an error
	end
end

--- Restarts emission of the particle effect.
function particleef_methods:restart()
	checkValid(unwrap(self)):Restart()
end

--- Determines if the particle effect is finished.
-- @return boolean True if the particle effect is finished
function particleef_methods:isFinished()
	local peff = unwrap(self)
	return not peff:IsValid() or peff:IsFinished()
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
