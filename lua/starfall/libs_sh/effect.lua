-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check


-- Register Privileges
SF.Permissions.registerPrivilege("effect.play", "Effect", "Allows the user to play effects", { client = {} })

local plyEffectBurst = SF.BurstObject("effects", "effects", 60, 5, "Rate effects can be spawned per second.", "Number of effects that can be spawned in a short time.")

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

local checktype = instance.CheckType
local effect_library = instance.Libraries.effect
local effect_methods, effect_meta, wrap, unwrap = instance.Types.Effect.Methods, instance.Types.Effect, instance.Types.Effect.Wrap, instance.Types.Effect.Unwrap
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local col_meta, cwrap, cunwrap = instance.Types.Color, instance.Types.Color.Wrap, instance.Types.Color.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap

local getent
instance:AddHook("initialize", function()
	getent = instance.Types.Entity.GetEntity
end)

--- Creates an effect data structure
-- @return Effect Object
function effect_library.create()
	return wrap(EffectData())
end

--- Returns number of effects able to be created
-- @return number of effects able to be created
function effect_library.effectsLeft()
	return instance.data.effects.burst:check()
end

--- Plays the effect
-- @param eff The effect type to play
function effect_methods:play(eff)
	checktype(self, effect_meta)
	checkluatype(eff, TYPE_STRING)
	
	checkpermission(instance, nil, "effect.play")
	plyEffectBurst:use(instance.player, 1)
	
	if effect_blacklist[eff] then SF.Throw("Effect ("..eff..") is blacklisted", 2) end

	util.Effect(eff,unwrap(self))
end

--- Returns the effect's angle
-- @return the effect's angle
function effect_methods:getAngles()
	checktype(self, effect_meta)
	return awrap(unwrap(self):GetAngles())
end

--- Returns the effect's attachment
-- @return the effect's attachment
function effect_methods:getAttachment()
	checktype(self, effect_meta)
	return unwrap(self):GetAttachment()
end

--- Returns the effect's color
-- @return the effect's color
function effect_methods:getColor()
	checktype(self, effect_meta)
	return unwrap(self):GetColor()
end

--- Returns the effect's damagetype
-- @return the effect's damagetype
function effect_methods:getDamageType()
	checktype(self, effect_meta)
	return unwrap(self):GetDamageType()
end

--- Returns the effect's entindex
-- @return the effect's entindex
function effect_methods:getEntIndex()
	checktype(self, effect_meta)
	return unwrap(self):GetEntIndex()
end

--- Returns the effect's entity
-- @return the effect's entity
function effect_methods:getEntity()
	checktype(self, effect_meta)
	return ewrap(unwrap(self):GetEntity())
end

--- Returns the effect's flags
-- @return the effect's flags
function effect_methods:getFlags()
	checktype(self, effect_meta)
	return unwrap(self):GetFlags()
end

--- Returns the effect's hitbox
-- @return the effect's hitbox
function effect_methods:getHitBox()
	checktype(self, effect_meta)
	return unwrap(self):GetHitBox()
end

--- Returns the effect's magnitude
-- @return the effect's magnitude
function effect_methods:getMagnitude()
	checktype(self, effect_meta)
	return unwrap(self):GetMagnitude()
end

--- Returns the effect's material index
-- @return the effect's material index
function effect_methods:getMaterialIndex()
	checktype(self, effect_meta)
	return unwrap(self):GetMaterialIndex()
end

--- Returns the effect's normal
-- @return the effect's normal
function effect_methods:getNormal()
	checktype(self, effect_meta)
	return vwrap(unwrap(self):GetNormal())
end

--- Returns the effect's origin
-- @return the effect's origin
function effect_methods:getOrigin()
	checktype(self, effect_meta)
	return vwrap(unwrap(self):GetOrigin())
end

--- Returns the effect's radius
-- @return the effect's radius
function effect_methods:getRadius()
	checktype(self, effect_meta)
	return unwrap(self):GetRadius()
end

--- Returns the effect's scale
-- @return the effect's scale
function effect_methods:getScale()
	checktype(self, effect_meta)
	return unwrap(self):GetScale()
end

--- Returns the effect's start position
-- @return the effect's start position
function effect_methods:getStart()
	checktype(self, effect_meta)
	return vwrap(unwrap(self):GetStart())
end

--- Returns the effect's surface prop
-- @return the effect's surface prop
function effect_methods:getSurfaceProp()
	checktype(self, effect_meta)
	return unwrap(self):GetSurfaceProp()
end

--- Sets the effect's angles
-- @param ang The angles
function effect_methods:setAngles(ang)
	checktype(self, effect_meta)
	checktype(ang, ang_meta)
	unwrap(self):SetAngles(aunwrap(ang))
end

--- Sets the effect's attachment
-- @param attachment The attachment
function effect_methods:setAttachment(attachment)
	checktype(self, effect_meta)
	checkluatype(attachment, TYPE_NUMBER)
	unwrap(self):SetAttachment(attachment)
end

--- Sets the effect's color
-- @param color The color represented by a byte 0-255. wtf?
function effect_methods:setColor(color)
	checktype(self, effect_meta)
	checkluatype(color, TYPE_NUMBER)
	unwrap(self):SetColor(color)
end

--- Sets the effect's damage type
-- @param dmgtype The damage type
function effect_methods:setDamageType(dmgtype)
	checktype(self, effect_meta)
	checkluatype(dmgtype, TYPE_NUMBER)
	unwrap(self):SetDamageType(dmgtype)
end

--- Sets the effect's entity index
-- @param index The entity index
function effect_methods:setEntIndex(index)
	checktype(self, effect_meta)
	checkluatype(index, TYPE_NUMBER)
	unwrap(self):SetEntIndex(index)
end

--- Sets the effect's entity
-- @param ent The entity
function effect_methods:setEntity(ent)
	checktype(self, effect_meta)
	unwrap(self):SetEntity(getent(ent))
end

--- Sets the effect's flags
-- @param flags The flags
function effect_methods:setFlags(flags)
	checktype(self, effect_meta)
	checkluatype(flags, TYPE_NUMBER)
	unwrap(self):SetFlags(flags)
end

--- Sets the effect's hitbox
-- @param hitbox The hitbox
function effect_methods:setHitBox(hitbox)
	checktype(self, effect_meta)
	checkluatype(hitbox, TYPE_NUMBER)
	unwrap(self):SetHitBox(hitbox)
end

--- Sets the effect's magnitude
-- @param magnitude The magnitude
function effect_methods:setMagnitude(magnitude)
	checktype(self, effect_meta)
	checkluatype(magnitude, TYPE_NUMBER)
	unwrap(self):SetMagnitude(magnitude)
end

--- Sets the effect's material index
-- @param mat The material index
function effect_methods:setMaterialIndex(mat)
	checktype(self, effect_meta)
	checkluatype(mat, TYPE_NUMBER)
	unwrap(self):SetMaterialIndex(mat)
end

--- Sets the effect's normal
-- @param normal The vector normal
function effect_methods:setNormal(normal)
	checktype(self, effect_meta)
	checktype(normal, vec_meta)
	unwrap(self):SetNormal(vunwrap(normal))
end

--- Sets the effect's origin
-- @param origin The vector origin
function effect_methods:setOrigin(origin)
	checktype(self, effect_meta)
	checktype(origin, vec_meta)
	unwrap(self):SetOrigin(vunwrap(origin))
end

--- Sets the effect's radius
-- @param radius The radius
function effect_methods:setRadius(radius)
	checktype(self, effect_meta)
	checkluatype(radius, TYPE_NUMBER)
	unwrap(self):SetRadius(radius)
end

--- Sets the effect's scale
-- @param scale The number scale
function effect_methods:setScale(scale)
	checktype(self, effect_meta)
	checkluatype(scale, TYPE_NUMBER)
	unwrap(self):SetScale(scale)
end

--- Sets the effect's start
-- @param start The vector start
function effect_methods:setStart(start)
	checktype(self, effect_meta)
	checktype(start, vec_meta)
	unwrap(self):SetStart(vunwrap(start))
end

--- Sets the effect's surface property
-- @param prop The surface property
function effect_methods:setSurfaceProp(prop)
	checktype(self, effect_meta)
	checkluatype(prop, TYPE_NUMBER)
	unwrap(self):SetSurfaceProp(prop)
end

end
