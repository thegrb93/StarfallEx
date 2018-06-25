local checktype = SF.CheckType
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check
-------------------------------------------------------------------------------
-- Vehicle functions.
-------------------------------------------------------------------------------

SF.Vehicles = {}
--- Vehicle type
local vehicle_methods, vehicle_metamethods = SF.RegisterType("Vehicle")

SF.Vehicles.Methods = vehicle_methods
SF.Vehicles.Metatable = vehicle_metamethods

local wrap, unwrap, pwrap
SF.AddHook("postload", function()
	pwrap = SF.Players.Wrap

	SF.ApplyTypeDependencies(vehicle_methods, vehicle_metamethods, SF.Entities.Metatable)
	wrap, unwrap = SF.CreateWrapper(vehicle_metamethods, true, false, debug.getregistry().Vehicle, SF.Entities.Metatable)

	SF.Vehicles.Wrap = wrap
	SF.Vehicles.Unwrap = unwrap
end)

-- Register privileges
do
	local P = SF.Permissions
	P.registerPrivilege("vehicle.eject", "Vehicle eject", "Removes a driver from vehicle")
	P.registerPrivilege("vehicle.kill", "Vehicle kill", "Kills a driver in vehicle", { entities = {} })
end

--- To string
-- @shared
function vehicle_metamethods:__tostring()
	local ent = unwrap(self)
	if not ent then return "(null entity)"
	else return tostring(ent) end
end

if SERVER then
	--- Returns the driver of the vehicle
	-- @server
	-- @return Driver of vehicle
	function vehicle_methods:getDriver ()
		checktype(self, vehicle_metamethods)
		local ent = unwrap(self)
		if not IsValid(ent) then SF.Throw("Invalid entity", 2) end
		return pwrap(ent:GetDriver())
	end

	--- Ejects the driver of the vehicle
	-- @server
	function vehicle_methods:ejectDriver ()
		checktype(self, vehicle_metamethods)
		local ent = unwrap(self)
		if not IsValid(ent) then SF.Throw("Invalid entity", 2) end
		local driver = ent:GetDriver()
		if driver:IsValid() then
			driver:ExitVehicle()
		end
	end

	--- Returns a passenger of a vehicle
	-- @server
	-- @param n The index of the passenger to get
	-- @return amount of ammo
	function vehicle_methods:getPassenger (n)
		checktype(self, vehicle_metamethods)
		checkluatype(n, TYPE_NUMBER)
		local ent = unwrap(self)
		if not IsValid(ent) then SF.Throw("Invalid entity", 2) end
		return pwrap(ent:GetPassenger(n))
	end

	-- Kills the driver of the vehicle
	-- @server
	function vehicle_methods:killDriver ()
		checktype(self, vehicle_metamethods)
		local ent = unwrap(self)
		if not IsValid(ent) then SF.Throw("Invalid entity", 2) end
		checkpermission(SF.instance, ent, "vehicle.kill")
		local driver = ent:GetDriver()
		if driver:IsValid() then
			driver:Kill()
		end
	end


end
