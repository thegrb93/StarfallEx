-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local ENT_META = FindMetaTable("Entity")
local WEP_META = FindMetaTable("Weapon")


--- Weapon type
-- @name Weapon
-- @class type
-- @libtbl weapon_methods
-- @libtbl weapon_meta
SF.RegisterType("Weapon", false, true, WEP_META, "Entity")


return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end
local Ent_GetClass,Ent_GetTable,Ent_IsValid = ENT_META.GetClass,ENT_META.GetTable,ENT_META.IsValid
local Wep_Clip1,Wep_Clip2,Wep_GetActivity,Wep_GetHoldType,Wep_GetMaxClip1,Wep_GetMaxClip2,Wep_GetNextPrimaryFire,Wep_GetNextSecondaryFire,Wep_GetPrimaryAmmoType,Wep_GetPrintName,Wep_GetSecondaryAmmoType,Wep_GetWeaponViewModel,Wep_GetWeaponWorldModel,Wep_IsCarriedByLocalPlayer,Wep_IsWeaponVisible,Wep_LastShootTime = WEP_META.Clip1,WEP_META.Clip2,WEP_META.GetActivity,WEP_META.GetHoldType,WEP_META.GetMaxClip1,WEP_META.GetMaxClip2,WEP_META.GetNextPrimaryFire,WEP_META.GetNextSecondaryFire,WEP_META.GetPrimaryAmmoType,WEP_META.GetPrintName,WEP_META.GetSecondaryAmmoType,WEP_META.GetWeaponViewModel,WEP_META.GetWeaponWorldModel,WEP_META.IsCarriedByLocalPlayer,WEP_META.IsWeaponVisible,WEP_META.LastShootTime

local weapon_methods, weapon_meta, wrap, unwrap = instance.Types.Weapon.Methods, instance.Types.Weapon, instance.Types.Weapon.Wrap, instance.Types.Weapon.Unwrap
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap

instance:AddHook("initialize", function()
	weapon_meta.__tostring = ent_meta.__tostring
end)

local function getwep(self)
	local ent = weapon_meta.sf2sensitive[self]
	if Ent_IsValid(ent) then
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
	return Wep_Clip1(getwep(self))
end

--- Returns Maximum ammo in primary clip
-- @shared
-- @return number Amount of ammo
function weapon_methods:maxClip1()
	return Wep_GetMaxClip1(getwep(self))
end

--- Returns Ammo in secondary clip
-- @shared
-- @return number Amount of ammo
function weapon_methods:clip2()
	return Wep_Clip2(getwep(self))
end

--- Returns Maximum ammo in secondary clip
-- @shared
-- @return number Amount of ammo
function weapon_methods:maxClip2()
	return Wep_GetMaxClip2(getwep(self))
end

--- Returns the sequence enumeration number that the weapon is playing. Must be used on a view model.
-- @shared
-- @return number Current activity
function weapon_methods:getActivity()
	return Wep_GetActivity(getwep(self))
end

--- Returns the hold type of the weapon.
-- @shared
-- @return string Holdtype
function weapon_methods:getHoldType()
	return Wep_GetHoldType(getwep(self))
end

--- Gets the next time the weapon can primary fire.
-- @shared
-- @return number The time, relative to CurTime
function weapon_methods:getNextPrimaryFire()
	return Wep_GetNextPrimaryFire(getwep(self))
end

--- Gets the next time the weapon can secondary fire.
-- @shared
-- @return number The time, relative to CurTime
function weapon_methods:getNextSecondaryFire()
	return Wep_GetNextSecondaryFire(getwep(self))
end

--- Gets the primary ammo type of the given weapon.
-- @shared
-- @return number Ammo number type
function weapon_methods:getPrimaryAmmoType()
	return Wep_GetPrimaryAmmoType(getwep(self))
end

--- Gets the secondary ammo type of the given weapon.
-- @shared
-- @return number Ammo number type
function weapon_methods:getSecondaryAmmoType()
	return Wep_GetSecondaryAmmoType(getwep(self))
end

--- Returns whether the weapon is visible
-- @shared
-- @return boolean Whether the weapon is visible or not
function weapon_methods:isWeaponVisible()
	return Wep_IsWeaponVisible(getwep(self))
end

--- Returns the time since a weapon was last fired at a float variable
-- @shared
-- @return number Time the weapon was last shot
function weapon_methods:lastShootTime()
	return Wep_LastShootTime(getwep(self))
end

--- Returns the tool mode of the toolgun
-- @shared
-- @return string The tool mode of the toolgun
function weapon_methods:getToolMode()
	local ent = getwep(self)
	return Ent_GetClass(ent)=="gmod_tool" and Ent_GetTable(ent).Mode or ""
end

--- Returns the view model of the weapon.
-- @shared
-- @return string The view model of the weapon.
function weapon_methods:getViewModel()
	return Wep_GetWeaponViewModel(getwep(self))
end

--- Returns the world model of the weapon.
-- @shared
-- @return string The world model of the weapon.
function weapon_methods:getWorldModel()
	return Wep_GetWeaponWorldModel(getwep(self))
end

if CLIENT then
	--- Gets Display name of weapon
	-- @client
	-- @return string Display name of weapon
	function weapon_methods:getPrintName()
		return Wep_GetPrintName(getwep(self))
	end

	--- Returns if the weapon is carried by the local player.
	-- @client
	-- @return boolean Whether or not the weapon is carried by the local player
	function weapon_methods:isCarriedByLocalPlayer()
		return Wep_IsCarriedByLocalPlayer(getwep(self))
	end
end

end
