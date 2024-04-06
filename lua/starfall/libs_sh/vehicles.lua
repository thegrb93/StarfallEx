-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege
local IsValid = FindMetaTable("Entity").IsValid

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
SF.RegisterType("Vehicle", false, true, FindMetaTable("Vehicle"), "Entity")

return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local vehicle_methods, vehicle_meta, wrap, unwrap = instance.Types.Vehicle.Methods, instance.Types.Vehicle, instance.Types.Vehicle.Wrap, instance.Types.Vehicle.Unwrap
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local pwrap = instance.Types.Player.Wrap

instance:AddHook("initialize", function()
	vehicle_meta.__tostring = ent_meta.__tostring
end)

local function getveh(self)
	local ent = unwrap(self)
	if IsValid(ent) then
		return ent
	else
		SF.Throw("Entity is not valid.", 3)
	end
end

--- Returns the driver of the vehicle
-- @return Player Driver of vehicle
function vehicle_methods:getDriver()
	return pwrap(getveh(self):GetDriver())
end

--- Returns a passenger of a vehicle
-- @param number n The index of the passenger to get
-- @return Player The passenger or NULL if empty
function vehicle_methods:getPassenger(n)
	checkluatype(n, TYPE_NUMBER)
	return pwrap(getveh(self):GetPassenger(n))
end

if SERVER then
	--- Ejects the driver of the vehicle
	-- @server
	function vehicle_methods:ejectDriver()
		local driver = getveh(self):GetDriver()
		if IsValid(driver) then
			driver:ExitVehicle()
		end
	end

	--- Kills the driver of the vehicle
	-- @server
	function vehicle_methods:killDriver()
		local ent = getveh(self)
		checkpermission(instance, ent, "vehicle.kill")
		local driver = ent:GetDriver()
		if IsValid(driver) then
			driver:Kill()
		end
	end

	--- Strips weapons of the driver
	-- @param string? class Optional weapon class to strip. Otherwise all are stripped.
	-- @server
	function vehicle_methods:stripDriver(class)
		if class ~= nil then checkluatype(class, TYPE_STRING) end
		local ent = getveh(self)
		checkpermission(instance, ent, "vehicle.strip")
		local driver = ent:GetDriver()
		if IsValid(driver) then
			if class then
				driver:StripWeapon(class)
			else
				driver:StripWeapons()
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
		ent:Fire("Lock")
	end

	--- Will unlock the vehicle.
	-- @server
	function vehicle_methods:unlock()
		local ent = getveh(self)
		checkpermission(instance, ent, "vehicle.lock")
		hook.Remove("CanExitVehicle", "SF_CanExitVehicle"..ent:EntIndex())
		ent:Fire("Unlock")
	end
end

end
