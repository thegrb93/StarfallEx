-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check
local registerprivilege = SF.Permissions.registerPrivilege

if SERVER then
	-- Register privileges
	registerprivilege("vehicle.eject", "Vehicle eject", "Removes a driver from vehicle", { entities = {} })
	registerprivilege("vehicle.kill", "Vehicle kill", "Kills a driver in vehicle", { entities = {} })
	registerprivilege("vehicle.strip", "Vehicle strip", "Strips weapons from a driver in vehicle", { entities = {} })
	registerprivilege("vehicle.lock", "Vehicle lock", "Allow vehicle locking/unlocking", { entities = {} })
end


-- Local to each starfall
return { function(instance) -- Called for library declarations


--- Vehicle type
local vehicle_methods, vehicle_meta = instance:RegisterType("Vehicle")


end, function(instance) -- Called for library definitions


local checktype = instance.CheckType
local vehicle_methods, vehicle_meta = instance.Types.Vehicle.Methods, instance.Types.Vehicle

instance:ApplyTypeDependencies(vehicle_methods, vehicle_meta, instance.Types.Entity)
local wrap, unwrap = instance:CreateWrapper(vehicle_meta, true, false, debug.getregistry().Vehicle, instance.Types.Entity)


--- To string
-- @shared
function vehicle_meta:__tostring()
	local ent = unwrap(self)
	if not ent then return "(null entity)"
	else return tostring(ent) end
end

if SERVER then
	--- Returns the driver of the vehicle
	-- @server
	-- @return Driver of vehicle
	function vehicle_methods:getDriver ()
		checktype(self, vehicle_meta)
		local ent = unwrap(self)
		if not (ent and ent:IsValid()) then SF.Throw("Invalid entity", 2) end
		return instance.Types.Player.Wrap(ent:GetDriver())
	end

	--- Ejects the driver of the vehicle
	-- @server
	function vehicle_methods:ejectDriver ()
		checktype(self, vehicle_meta)
		local ent = unwrap(self)
		if not (ent and ent:IsValid()) then SF.Throw("Invalid entity", 2) end
		local driver = ent:GetDriver()
		if driver:IsValid() then
			driver:ExitVehicle()
		end
	end

	--- Returns a passenger of a vehicle
	-- @server
	-- @param n The index of the passenger to get
	-- @return The passenger or NULL if empty
	function vehicle_methods:getPassenger (n)
		checktype(self, vehicle_meta)
		checkluatype(n, TYPE_NUMBER)
		local ent = unwrap(self)
		if not (ent and ent:IsValid()) then SF.Throw("Invalid entity", 2) end
		return instance.Types.Player.Wrap(ent:GetPassenger(n))
	end

	--- Kills the driver of the vehicle
	-- @server
	function vehicle_methods:killDriver ()
		checktype(self, vehicle_meta)
		local ent = unwrap(self)
		if not (ent and ent:IsValid()) then SF.Throw("Invalid entity", 2) end
		checkpermission(instance, ent, "vehicle.kill")
		local driver = ent:GetDriver()
		if driver:IsValid() then
			driver:Kill()
		end
	end

	--- Strips weapons of the driver
	-- @param class Optional weapon class to strip. Otherwise all are stripped.
	-- @server
	function vehicle_methods:stripDriver (class)
		checktype(self, vehicle_meta)
		if class ~= nil then checkluatype(class, TYPE_STRING) end
		local ent = unwrap(self)
		if not (ent and ent:IsValid()) then SF.Throw("Invalid entity", 2) end
		checkpermission(instance, ent, "vehicle.strip")
		local driver = ent:GetDriver()
		if driver:IsValid() then
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
		checktype(self, vehicle_meta)
		local ent = unwrap(self)
		if not (ent and ent:IsValid()) then SF.Throw("Invalid entity", 2) end
		checkpermission(instance, ent, "vehicle.lock")
		local n = "SF_CanExitVehicle"..ent:EntIndex()
		hook.Add("CanExitVehicle", n, function(v) if v==ent then return false end end)
		ent:CallOnRemove(n, function() hook.Remove("CanExitVehicle", n) end) 
		ent:Fire("Lock")
	end

	--- Will unlock the vehicle.
	-- @server
	function vehicle_methods:unlock()
		checktype(self, vehicle_meta)
		local ent = unwrap(self)
		if not (ent and ent:IsValid()) then SF.Throw("Invalid entity", 2) end
		checkpermission(instance, ent, "vehicle.lock")
		hook.Remove("CanExitVehicle", "SF_CanExitVehicle"..ent:EntIndex())
		ent:Fire("Unlock")
	end
end

end}
