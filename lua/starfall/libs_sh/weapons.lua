-------------------------------------------------------------------------------
-- Weapon functions.
-------------------------------------------------------------------------------

SF.Weapons = {}
--- Weapon type
local weapon_methods, weapon_metamethods = instance:RegisterType("Weapon")

local checktype = instance.CheckType
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check

SF.Weapons.Methods = weapon_methods
SF.Weapons.Metatable = weapon_metamethods

local checktype = instance.CheckType
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check

local wrap, unwrap
instance:AddHook("postload", function()
	SF.ApplyTypeDependencies(weapon_methods, weapon_metamethods, instance.Types.Entity.Metatable)
	wrap, unwrap = instance:CreateWrapper(weapon_metamethods, true, false, debug.getregistry().Weapon, instance.Types.Entity.Metatable)

	SF.Weapons.Wrap = wrap
	SF.Weapons.Unwrap = unwrap
end)

--- To string
-- @shared
function weapon_metamethods:__tostring()
	local ent = unwrap(self)
	if not ent then return "(null entity)"
	else return tostring(ent) end
end


-- ------------------------------------------------------------------------- --
--- Returns Ammo in primary clip
-- @shared
-- @return amount of ammo
function weapon_methods:clip1 ()
	checktype(self, weapon_metamethods)
	local ent = unwrap(self)
	return ent:Clip1()
end

--- Returns Ammo in secondary clip
-- @shared
-- @return amount of ammo
function weapon_methods:clip2 ()
	checktype(self, weapon_metamethods)
	local ent = unwrap(self)
	return ent:Clip2()
end

--- Returns the sequence enumeration number that the weapon is playing. Must be used on a view model.
-- @shared
-- @return number Current activity
function weapon_methods:getActivity ()
	checktype(self, weapon_metamethods)
	local ent = unwrap(self)
	return ent:GetActivity()
end

--- Returns the hold type of the weapon.
-- @shared
-- @return string Holdtype
function weapon_methods:getHoldType ()
	checktype(self, weapon_metamethods)
	local ent = unwrap(self)
	return ent:GetHoldType()
end

--- Gets the next time the weapon can primary fire.
-- @shared
-- @return The time, relative to CurTime
function weapon_methods:getNextPrimaryFire ()
	checktype(self, weapon_metamethods)
	local ent = unwrap(self)
	return ent:GetNextPrimaryFire()
end

--- Gets the next time the weapon can secondary fire.
-- @shared
-- @return The time, relative to CurTime
function weapon_methods:getNextSecondaryFire ()
	checktype(self, weapon_metamethods)
	local ent = unwrap(self)
	return ent:GetNextSecondaryFire()
end

--- Gets the primary ammo type of the given weapon.
-- @shared
-- @return Ammo number type
function weapon_methods:getPrimaryAmmoType ()
	checktype(self, weapon_metamethods)
	local ent = unwrap(self)
	return ent:GetPrimaryAmmoType()
end

--- Gets the secondary ammo type of the given weapon.
-- @shared
-- @return Ammo number type
function weapon_methods:getSecondaryAmmoType ()
	checktype(self, weapon_metamethods)
	local ent = unwrap(self)
	return ent:GetSecondaryAmmoType()
end

--- Returns whether the weapon is visible
-- @shared
-- @return Whether the weapon is visble or not
function weapon_methods:isWeaponVisible ()
	checktype(self, weapon_metamethods)
	local ent = unwrap(self)
	return ent:IsWeaponVisible()
end

--- Returns the time since a weapon was last fired at a float variable
-- @shared
-- @return Time the weapon was last shot
function weapon_methods:lastShootTime ()
	checktype(self, weapon_metamethods)
	local ent = unwrap(self)
	return ent:LastShootTime()
end

--- Returns the tool mode of the toolgun
-- @shared
-- @return The tool mode of the toolgun
function weapon_methods:getToolMode ()
	checktype(self, weapon_metamethods)
	local ent = unwrap(self)
	return ent:GetClass()=="gmod_tool" and ent.Mode or ""
end

if CLIENT then
	--- Gets Display name of weapon
	-- @client
	-- @return string Display name of weapon
	function weapon_methods:getPrintName ()
		checktype(self, weapon_metamethods)
		local ent = unwrap(self)
		return ent:GetPrintName()
	end

	--- Returns if the weapon is carried by the local player.
	-- @client
	-- @return whether or not the weapon is carried by the local player
	function weapon_methods:isCarriedByLocalPlayer ()
		checktype(self, weapon_metamethods)
		local ent = unwrap(self)
		return ent:IsCarriedByLocalPlayer()
	end
end
