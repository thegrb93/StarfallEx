

--- Physenv functions
-- @name physenv
-- @class library
-- @libtbl physenv_lib
SF.RegisterLibrary("physenv")


return function(instance)

local physenv_lib = instance.Libraries.physenv
local vwrap = instance.Types.Vector.Wrap

--- Gets the air density.
-- @return number Air Density
function physenv_lib.getAirDensity()
	return physenv.GetAirDensity()
end

--- Gets the gravity vector
-- @return Vector Gravity Vector ( eg Vector(0,0,-600) )
function physenv_lib.getGravity()
	return vwrap(physenv.GetGravity())
end

--- Gets the performance settings.
-- See http://wiki.facepunch.com/gmod/Structures/PhysEnvPerformanceSettings for table structure.
-- @return table Performance Settings Table.
function physenv_lib.getPerformanceSettings()
	return instance.Sanitize(physenv.GetPerformanceSettings())
end

end
