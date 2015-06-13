-------------------------------------------------------------------------------
-- Vehicle functions.
-------------------------------------------------------------------------------

SF.Vehicles = {}
--- Vehicle type
local vehicle_methods, vehicle_metamethods = SF.Typedef("Vehicle", SF.Entities.Metatable)

SF.Vehicles.Methods = vehicle_methods
SF.Vehicles.Metatable = vehicle_metamethods

--- Custom wrapper/unwrapper is necessary for vehicle objects
-- wrapper
local dsetmeta = debug.setmetatable
local function wrap( object )
	object = SF.Entities.Wrap( object )
	dsetmeta( object, vehicle_metamethods )
	return object
end

SF.AddObjectWrapper( debug.getregistry().Vehicle, vehicle_metamethods, wrap )
SF.AddObjectUnwrapper( vehicle_metamethods, SF.Entities.Unwrap )

--- To string
-- @shared
function vehicle_metamethods:__tostring()
	local ent = SF.Entities.Unwrap(self)
	if not ent then return "(null entity)"
	else return tostring(ent) end
end

if SERVER then
	--- Returns the driver of the vehicle
	-- @server
	-- @return Driver of vehicle
	function vehicle_methods:getDriver ()
		SF.CheckType( self, vehicle_metamethods )
		local ent = SF.Entities.Unwrap( self )
		return SF.WrapObject( ent:GetDriver() )
	end

	--- Returns a passenger of a vehicle
	-- @server
	-- @param passenger The number of the passenger to get
	-- @return amount of ammo
	function vehicle_methods:getPassenger ( n )
		SF.CheckType( self, vehicle_metamethods )
		SF.CheckType( n, "number" )
		local ent = SF.Entities.Unwrap( self )
		return SF.WrapObject( ent:GetPassenger( n ) )
	end

end
