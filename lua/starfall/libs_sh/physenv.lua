-------------------------------------------------------------------------------
-- Physenv library
-------------------------------------------------------------------------------

--- Physenv functions
-- @shared
local physenv_lib, _ = SF.Libraries.Register( "physenv" )

--- Gets the air density.
-- @return number Air Density
function physenv_lib.getAirDensity ()
	return physenv.GetAirDensity()
end

--- Gets the gravity vector
-- @return Vector Gravity Vector ( eg Vector(0,0,-600) )
function physenv_lib.getGravity ()
	return SF.WrapObject( physenv.GetGravity() )
end

--- Gets the performance settings.</br>
-- See <a href="http://wiki.garrysmod.com/page/Structures/PhysEnvPerformanceSettings">PhysEnvPerformance Settings Table Structure</a> for table structure.
-- @return table Performance Settings Table.
function physenv_lib.getPerformanceSettings ()
	return SF.Sanitize( table.Copy( physenv.GetPerformanceSettings() ) )
end
