-------------------------------------------------------------------------------
-- Weapon functions.
-------------------------------------------------------------------------------

SF.Weapons = {}
--- Weapon type
local weapon_methods, weapon_metamethods = SF.Typedef("Weapon", SF.Entities.Metatable)

local vwrap = SF.WrapObject

SF.Weapons.Methods = weapon_methods
SF.Weapons.Metatable = weapon_metamethods

--- Custom wrapper/unwrapper is necessary for weapon objects
-- wrapper
local dsetmeta = debug.setmetatable
local function wrap(object)
	object = SF.Entities.Wrap(object)
	dsetmeta(object, weapon_metamethods)
	return object
end
SF.Weapons.Wrap = wrap
SF.AddObjectWrapper(debug.getregistry().Weapon, weapon_metamethods, wrap)
SF.AddObjectUnwrapper(weapon_metamethods, SF.Entities.Unwrap)

--- To string
-- @shared
function weapon_metamethods:__tostring()
	local ent = SF.Entities.Unwrap(self)
	if not ent then return "(null entity)"
	else return tostring(ent) end
end


-- ------------------------------------------------------------------------- --
--- Returns Ammo in primary clip
-- @shared
-- @return amount of ammo
function weapon_methods:clip1 ()
	SF.CheckType(self, weapon_metamethods)
	local ent = SF.Entities.Unwrap(self)
	return ent:Clip1()
end

--- Returns Ammo in secondary clip
-- @shared
-- @return amount of ammo
function weapon_methods:clip2 ()
	SF.CheckType(self, weapon_metamethods)
	local ent = SF.Entities.Unwrap(self)
	return ent:Clip2()
end

--- Returns the sequence enumeration number that the weapon is playing. Must be used on a view model.
-- @shared
-- @return number Current activity
function weapon_methods:getActivity ()
	SF.CheckType(self, weapon_metamethods)
	local ent = SF.Entities.Unwrap(self)
	return ent:GetActivity()
end

--- Returns the hold type of the weapon.
-- @shared
-- @return string Holdtype
function weapon_methods:getHoldType ()
	SF.CheckType(self, weapon_metamethods)
	local ent = SF.Entities.Unwrap(self)
	return ent:GetHoldType()
end

--- Gets the next time the weapon can primary fire.
-- @shared
-- @return The time, relative to CurTime
function weapon_methods:getNextPrimaryFire ()
	SF.CheckType(self, weapon_metamethods)
	local ent = SF.Entities.Unwrap(self)
	return ent:GetNextPrimaryFire()
end

--- Gets the next time the weapon can secondary fire.
-- @shared
-- @return The time, relative to CurTime
function weapon_methods:getNextSecondaryFire ()
	SF.CheckType(self, weapon_metamethods)
	local ent = SF.Entities.Unwrap(self)
	return ent:GetNextSecondaryFire()
end

--- Gets the primary ammo type of the given weapon.
-- @shared
-- @return Ammo number type
function weapon_methods:getPrimaryAmmoType ()
	SF.CheckType(self, weapon_metamethods)
	local ent = SF.Entities.Unwrap(self)
	return ent:GetPrimaryAmmoType()
end

--- Gets the secondary ammo type of the given weapon.
-- @shared
-- @return Ammo number type
function weapon_methods:getSecondaryAmmoType ()
	SF.CheckType(self, weapon_metamethods)
	local ent = SF.Entities.Unwrap(self)
	return ent:GetSecondaryAmmoType()
end

--- Returns whether the weapon is visible
-- @shared
-- @return Whether the weapon is visble or not
function weapon_methods:isWeaponVisible ()
	SF.CheckType(self, weapon_metamethods)
	local ent = SF.Entities.Unwrap(self)
	return ent:IsWeaponVisible()
end

--- Returns the time since a weapon was last fired at a float variable
-- @shared
-- @return Time the weapon was last shot
function weapon_methods:lastShootTime ()
	SF.CheckType(self, weapon_metamethods)
	local ent = SF.Entities.Unwrap(self)
	return ent:LastShootTime()
end

if CLIENT then
	--- Gets Display name of weapon
	-- @client
	-- @return string Display name of weapon
	function weapon_methods:getPrintName ()
		SF.CheckType(self, weapon_metamethods)
		local ent = SF.Entities.Unwrap(self)
		return ent:GetPrintName()
	end

	--- Returns if the weapon is carried by the local player.
	-- @client
	-- @return whether or not the weapon is carried by the local player
	function weapon_methods:isCarriedByLocalPlayer ()
		SF.CheckType(self, weapon_metamethods)
		local ent = SF.Entities.Unwrap(self)
		return ent:IsCarriedByLocalPlayer()
	end
end
