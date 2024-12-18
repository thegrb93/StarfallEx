-- Global to all starfalls
local checkluatype = SF.CheckLuaType


-- Register Privileges
SF.Permissions.registerPrivilege("effect.play", "Effect", "Allows the user to play effects", { client = {} })

local plyEffectBurst = SF.BurstObject("effects", "effects", 60, 5, "Rate effects can be spawned per second.", "Number of effects that can be spawned in a short time.")

SF.ResourceCounters.Effects = {icon = "icon16/bullet_star.png", count = function(ply) return plyEffectBurst.max-plyEffectBurst:check(ply) end}

local effect_blacklist = {
	dof_node = true
}


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

local getent
local vunwrap1
local aunwrap1
instance:AddHook("initialize", function()
	getent = instance.Types.Entity.GetEntity
	vunwrap1 = vec_meta.QuickUnwrap1
	aunwrap1 = ang_meta.QuickUnwrap1
end)

--- Creates an effect data structure
-- @return Effect Effect Object
function effect_library.create()
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
	return plyEffectBurst:check(instance.player)>=1
end

--- Plays the effect
-- @param string eff The effect type name to play
function effect_methods:play(eff)
	checkluatype(eff, TYPE_STRING)

	checkpermission(instance, nil, "effect.play")
	plyEffectBurst:use(instance.player, 1)

	eff = eff:lower()
	if effect_blacklist[eff] then SF.Throw("Effect ("..eff..") is blacklisted", 2) end
	if hook.Run( "Starfall_CanEffect", eff, instance ) == false then SF.Throw("Effect ("..eff..") has been blocked from running", 2) end

	util.Effect(eff,unwrap(self))
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
	unwrap(self):SetAttachment(attachment)
end

--- Sets the effect's color
-- Internally stored as an integer, but only first 8 bits are networked, effectively limiting this function to 0-255 range.
-- @param number color The color represented by a byte 0-255.
function effect_methods:setColor(color)
	checkluatype(color, TYPE_NUMBER)
	unwrap(self):SetColor(color)
end

--- Sets the effect's damage type
-- @param number dmgtype The damage type, see the DMG enums
function effect_methods:setDamageType(dmgtype)
	checkluatype(dmgtype, TYPE_NUMBER)
	unwrap(self):SetDamageType(dmgtype)
end

--- Sets the effect's entity index
-- @param number index The entity index
function effect_methods:setEntIndex(index)
	checkluatype(index, TYPE_NUMBER)
	unwrap(self):SetEntIndex(index)
end

--- Sets the effect's entity
-- @param Entity ent The entity
function effect_methods:setEntity(ent)
	unwrap(self):SetEntity(getent(ent))
end

--- Sets the effect's flags
-- @param number flags The flags
function effect_methods:setFlags(flags)
	checkluatype(flags, TYPE_NUMBER)
	unwrap(self):SetFlags(flags)
end

--- Sets the effect's hitbox
-- @param number hitbox The hitbox
function effect_methods:setHitBox(hitbox)
	checkluatype(hitbox, TYPE_NUMBER)
	unwrap(self):SetHitBox(hitbox)
end

--- Sets the effect's magnitude
-- @param number magnitude The magnitude
function effect_methods:setMagnitude(magnitude)
	checkluatype(magnitude, TYPE_NUMBER)
	unwrap(self):SetMagnitude(magnitude)
end

--- Sets the effect's material index
-- @param number mat The material index
function effect_methods:setMaterialIndex(mat)
	checkluatype(mat, TYPE_NUMBER)
	unwrap(self):SetMaterialIndex(mat)
end

--- Sets the effect's normal
-- @param Vector normal The vector normal
function effect_methods:setNormal(normal)
	unwrap(self):SetNormal(vunwrap1(normal))
end

--- Sets the effect's origin
-- @param Vector origin The vector origin
function effect_methods:setOrigin(origin)
	unwrap(self):SetOrigin(vunwrap1(origin))
end

--- Sets the effect's radius
-- @param number radius The radius
function effect_methods:setRadius(radius)
	checkluatype(radius, TYPE_NUMBER)
	unwrap(self):SetRadius(radius)
end

--- Sets the effect's scale
-- @param number scale The number scale
function effect_methods:setScale(scale)
	checkluatype(scale, TYPE_NUMBER)
	unwrap(self):SetScale(scale)
end

--- Sets the effect's start pos
-- Limited to world bounds (+-16386 on every axis) and has horrible networking precision. (17 bit float per component)
-- @param Vector start The vector start
function effect_methods:setStart(start)
	unwrap(self):SetStart(vunwrap1(start))
end

--- Sets the effect's surface property
-- Internally stored as an integer, but only first 8 bits are networked, effectively limiting this function to -1-254 range.(yes, that's not a mistake)
-- @param number prop The surface property index
function effect_methods:setSurfaceProp(prop)
	checkluatype(prop, TYPE_NUMBER)
	unwrap(self):SetSurfaceProp(prop)
end

end
