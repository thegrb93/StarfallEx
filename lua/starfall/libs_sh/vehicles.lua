-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege
local ENT_META = FindMetaTable("Entity")
local PLY_META = FindMetaTable("Player")
local VEH_META = FindMetaTable("Vehicle")

if SERVER then
	-- Register privileges
	registerprivilege("vehicle.eject", "Vehicle eject", "Removes a driver from vehicle", { entities = {} })
	registerprivilege("vehicle.kill", "Vehicle kill", "Kills a driver in vehicle", { entities = {} })
	registerprivilege("vehicle.strip", "Vehicle strip", "Strips weapons from a driver in vehicle", { entities = {} })
	registerprivilege("vehicle.lock", "Vehicle lock", "Allow vehicle locking/unlocking", { entities = {} })
end


--- Vehicle type
-- @name Vehicle
-- @class type
-- @libtbl vehicle_methods
-- @libtbl vehicle_meta
SF.RegisterType("Vehicle", false, true, VEH_META, "Entity")

return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end
local Ent_Fire,Ent_IsValid = ENT_META.Fire,ENT_META.IsValid
local Ply_ExitVehicle,Ply_Kill,Ply_StripWeapon,Ply_StripWeapons = PLY_META.ExitVehicle,PLY_META.Kill,PLY_META.StripWeapon,PLY_META.StripWeapons
local Veh_GetDriver,Veh_GetPassenger = VEH_META.GetDriver,VEH_META.GetPassenger

local vehicle_methods, vehicle_meta, wrap, unwrap = instance.Types.Vehicle.Methods, instance.Types.Vehicle, instance.Types.Vehicle.Wrap, instance.Types.Vehicle.Unwrap
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local pwrap = instance.Types.Player.Wrap

instance:AddHook("initialize", function()
	vehicle_meta.__tostring = ent_meta.__tostring
end)

local function getveh(self)
	local ent = vehicle_meta.sf2sensitive[self]
	if Ent_IsValid(ent) then
		return ent
	else
		SF.Throw("Entity is not valid.", 3)
	end
end

--- Returns the driver of the vehicle
-- @return Player Driver of vehicle
function vehicle_methods:getDriver()
	return pwrap(Veh_GetDriver(getveh(self)))
end

--- Returns a passenger of a vehicle
-- @param number n The index of the passenger to get
-- @return Player The passenger or NULL if empty
function vehicle_methods:getPassenger(n)
	checkluatype(n, TYPE_NUMBER)
	return pwrap(Veh_GetPassenger(getveh(self), n))
end

if SERVER then
	--- Ejects the driver of the vehicle
	-- @server
	function vehicle_methods:ejectDriver()
		local driver = getveh(self):GetDriver()
		if Ent_IsValid(driver) then
			Ply_ExitVehicle(driver)
		end
	end

	--- Kills the driver of the vehicle
	-- @server
	function vehicle_methods:killDriver()
		local ent = getveh(self)
		checkpermission(instance, ent, "vehicle.kill")
		local driver = Veh_GetDriver(ent)
		if Ent_IsValid(driver) then
			Ply_Kill(driver)
		end
	end

	--- Strips weapons of the driver
	-- @param string? class Optional weapon class to strip. Otherwise all are stripped.
	-- @server
	function vehicle_methods:stripDriver(class)
		if class ~= nil then checkluatype(class, TYPE_STRING) end
		local ent = getveh(self)
		checkpermission(instance, ent, "vehicle.strip")
		local driver = Veh_GetDriver(ent)
		if Ent_IsValid(driver) then
			if class then
				Ply_StripWeapon(driver, class)
			else
				Ply_StripWeapons(driver)
			end
		end
	end

	--- Will lock the vehicle preventing players from entering or exiting the vehicle.
	-- @server
	function vehicle_methods:lock()
		local ent = getveh(self)
		checkpermission(instance, ent, "vehicle.lock")
		local n = "SF_CanExitVehicle"..ent:EntIndex()
		hook.Add("CanExitVehicle", n, function(v) if v==ent then return false end end)
		SF.CallOnRemove(ent, n, function() hook.Remove("CanExitVehicle", n) end)
		Ent_Fire(ent, "Lock")
	end

	--- Will unlock the vehicle.
	-- @server
	function vehicle_methods:unlock()
		local ent = getveh(self)
		checkpermission(instance, ent, "vehicle.lock")
		hook.Remove("CanExitVehicle", "SF_CanExitVehicle"..ent:EntIndex())
		Ent_Fire(ent, "Unlock")
	end
end

end
