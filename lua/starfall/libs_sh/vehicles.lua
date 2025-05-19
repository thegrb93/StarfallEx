-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege
local dgetmeta = debug.getmetatable
local ENT_META,PLY_META,VEH_META = FindMetaTable("Entity"),FindMetaTable("Player"),FindMetaTable("Vehicle")

local sf_max_driveruse_dist
if SERVER then
	-- Register privileges
	registerprivilege("vehicle.eject", "Vehicle eject", "Removes a driver from vehicle", { entities = {} })
	registerprivilege("vehicle.kill", "Vehicle kill", "Kills a driver in vehicle", { entities = {} })
	registerprivilege("vehicle.strip", "Vehicle strip", "Strips weapons from a driver in vehicle", { entities = {} })
	registerprivilege("vehicle.lock", "Vehicle lock", "Allow vehicle locking/unlocking", { entities = {} })

	sf_max_driveruse_dist = CreateConVar("sf_vehicle_use_distance", 100, FCVAR_ARCHIVE, "The max reach distance allowed for Vehicle:driverUse function.")
end


--- Vehicle type
-- @name Vehicle
-- @class type
-- @libtbl vehicle_methods
-- @libtbl vehicle_meta
SF.RegisterType("Vehicle", false, true, VEH_META, "Entity")

return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end
local Ent_Fire,Ent_GetPos,Ent_IsValid,Ent_Use = ENT_META.Fire,ENT_META.GetPos,ENT_META.IsValid,ENT_META.Use
local Ply_ExitVehicle,Ply_GetShootPos,Ply_Kill,Ply_StripWeapon,Ply_StripWeapons = PLY_META.ExitVehicle,PLY_META.GetShootPos,PLY_META.Kill,PLY_META.StripWeapon,PLY_META.StripWeapons
local Veh_GetDriver,Veh_GetPassenger = VEH_META.GetDriver,VEH_META.GetPassenger

local function Ent_IsVehicle(ent) return dgetmeta(ent)==VEH_META end

local vehicle_methods, vehicle_meta, wrap, unwrap = instance.Types.Vehicle.Methods, instance.Types.Vehicle, instance.Types.Vehicle.Wrap, instance.Types.Vehicle.Unwrap
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local pwrap = instance.Types.Player.Wrap

local getent
instance:AddHook("initialize", function()
	getent = ent_meta.GetEntity
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

	--- Simulate a Use action on the entity by the driver
	-- @param Entity ent The entity to be used.
	-- @param number? usetype The USE_ enum use type. (Default: USE_ON)
	-- @param number? value The use value (Default: 0)
	function vehicle_methods:driverUse(ent, usetype, value)
		ent = getent(ent)
		if Ent_IsVehicle(ent) then return end -- Prevent source engine bug when using vehicle while in a vehicle
		local driver = Veh_GetDriver(getveh(self))
		if not Ent_IsValid(driver) then return end
		if usetype~=nil then checkluatype(usetype, TYPE_NUMBER) end
		if value~=nil then checkluatype(value, TYPE_NUMBER) end

		if Ply_GetShootPos(driver):DistToSqr(Ent_GetPos(ent)) > sf_max_driveruse_dist:GetFloat()^2 then SF.Throw("Entity is greater than "..sf_max_driveruse_dist:GetFloat().." units from the player", 2) end

		checkpermission(instance, ent, "entities.use")

		Ent_Use(ent, driver, instance.entity, usetype, value)
	end

end

end
