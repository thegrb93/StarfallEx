-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local IsValid = FindMetaTable("Entity").IsValid


--- Weapon type
-- @name Weapon
-- @class type
-- @libtbl weapon_methods
-- @libtbl weapon_meta
SF.RegisterType("Weapon", false, true, FindMetaTable("Weapon"), "Entity")


return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local weapon_methods, weapon_meta, wrap, unwrap = instance.Types.Weapon.Methods, instance.Types.Weapon, instance.Types.Weapon.Wrap, instance.Types.Weapon.Unwrap
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap

instance:AddHook("initialize", function()
	weapon_meta.__tostring = ent_meta.__tostring
end)

local function getwep(self)
	local ent = weapon_meta.sf2sensitive[self]
	if IsValid(ent) then
		return ent
	else
		SF.Throw("Entity is not valid.", 3)
	end
end

-- ------------------------------------------------------------------------- --
--- Returns Ammo in primary clip
-- @shared
-- @return number Amount of ammo
function weapon_methods:clip1()
	return getwep(self):Clip1()
end

--- Returns Maximum ammo in primary clip
-- @shared
-- @return number Amount of ammo
function weapon_methods:maxClip1()
	return getwep(self):GetMaxClip1()
end

--- Returns Ammo in secondary clip
-- @shared
-- @return number Amount of ammo
function weapon_methods:clip2()
	return getwep(self):Clip2()
end

--- Returns Maximum ammo in secondary clip
-- @shared
-- @return number Amount of ammo
function weapon_methods:maxClip2()
	return getwep(self):GetMaxClip2()
end

--- Returns the sequence enumeration number that the weapon is playing. Must be used on a view model.
-- @shared
-- @return number Current activity
function weapon_methods:getActivity()
	return getwep(self):GetActivity()
end

--- Returns the hold type of the weapon.
-- @shared
-- @return string Holdtype
function weapon_methods:getHoldType()
	return getwep(self):GetHoldType()
end

--- Gets the next time the weapon can primary fire.
-- @shared
-- @return number The time, relative to CurTime
function weapon_methods:getNextPrimaryFire()
	return getwep(self):GetNextPrimaryFire()
end

--- Gets the next time the weapon can secondary fire.
-- @shared
-- @return number The time, relative to CurTime
function weapon_methods:getNextSecondaryFire()
	return getwep(self):GetNextSecondaryFire()
end

--- Gets the primary ammo type of the given weapon.
-- @shared
-- @return number Ammo number type
function weapon_methods:getPrimaryAmmoType()
	return getwep(self):GetPrimaryAmmoType()
end

--- Gets the secondary ammo type of the given weapon.
-- @shared
-- @return number Ammo number type
function weapon_methods:getSecondaryAmmoType()
	return getwep(self):GetSecondaryAmmoType()
end

--- Returns whether the weapon is visible
-- @shared
-- @return boolean Whether the weapon is visible or not
function weapon_methods:isWeaponVisible()
	return getwep(self):IsWeaponVisible()
end

--- Returns the time since a weapon was last fired at a float variable
-- @shared
-- @return number Time the weapon was last shot
function weapon_methods:lastShootTime()
	return getwep(self):LastShootTime()
end

--- Returns the tool mode of the toolgun
-- @shared
-- @return string The tool mode of the toolgun
function weapon_methods:getToolMode()
	local ent = getwep(self)
	return ent:GetClass()=="gmod_tool" and ent.Mode or ""
end

if CLIENT then
	--- Gets Display name of weapon
	-- @client
	-- @return string Display name of weapon
	function weapon_methods:getPrintName()
		return getwep(self):GetPrintName()
	end

	--- Returns if the weapon is carried by the local player.
	-- @client
	-- @return boolean Whether or not the weapon is carried by the local player
	function weapon_methods:isCarriedByLocalPlayer()
		return getwep(self):IsCarriedByLocalPlayer()
	end
end

end
