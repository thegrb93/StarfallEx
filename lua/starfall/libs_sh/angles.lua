SF.Angles = {}

--- Angle Type
-- @shared
local ang_methods, ang_metamethods = SF.Typedef( "Angle" )
local wrap, unwrap = SF.CreateWrapper( ang_metamethods, true, false, debug.getregistry().Angle )

SF.DefaultEnvironment.Angle = function ( ... )
	return wrap( Angle( ... ) )
end

SF.Angles.Wrap = wrap
SF.Angles.Unwrap = unwrap
SF.Angles.Methods = ang_methods
SF.Angles.Metatable = ang_metamethods

--- __newindex metamethod
function ang_metamethods.__newindex ( t, k, v )
	if type( k ) == "number" and k >= 1 and k <= 3 then
			SF.UnwrapObject( t ).__newindex( SF.UnwrapObject( t ), k, v )
	elseif k == "p" or k == "y" or k == "r" then
		SF.UnwrapObject( t ).__newindex( SF.UnwrapObject( t ), k, v )
	else
		rawset( t, k, v )
	end
end

--- __index metamethod
function ang_metamethods.__index ( t, k )
	if type( k ) == "number" and k >= 1 and k <= 3 then
			return unwrap( t )[ k ]
	elseif k == "p" or k == "y" or k == "r" then
		return unwrap( t )[ k ]
	end
	return ang_methods[ k ]
end

--- tostring metamethod.
-- @return string representing the angle.
function ang_metamethods:__tostring ()
	return unwrap( self ):__tostring()
end

--- __mul metamethod ang1 * n.
-- @param n Number to multiply by.
-- @return resultant angle.
function ang_metamethods:__mul ( n )
	SF.CheckType( n, "number" )
	return SF.WrapObject( unwrap( self ):__mul( n ) )
end

--- __div metamethod ang1 / n.
-- @param n Number to divided by.
-- @return resultant angle.
function ang_metamethods:__div ( n )
	SF.CheckType( n, "number" )
	return SF.WrapObject( unwrap( self ):__mul( 1/n ) )
end

--- __unm metamethod -ang.
-- @return resultant angle.
function ang_metamethods:__unm ()
	return SF.WrapObject( unwrap( self ):__unm() )
end

--- __eq metamethod ang1 == ang2.
-- @param a Angle to check against.
-- @return bool
function ang_metamethods:__eq ( a )
	SF.CheckType( a, SF.Types[ "Angle" ] )
	return SF.WrapObject( unwrap( self ):__eq( unwrap( a ) ) )
end

--- __add metamethod ang1 + ang2.
-- @param a Angle to add.
-- @return resultant angle.
function ang_metamethods:__add ( a )
	SF.CheckType( a, SF.Types[ "Angle" ] )
	return SF.WrapObject( unwrap( self ):__add( unwrap( a ) ) )
end

--- __sub metamethod ang1 - ang2.
-- @param a Angle to subtract.
-- @return resultant angle.
function ang_metamethods:__sub ( a )
	SF.CheckType( a, SF.Types[ "Angle" ] )
	return SF.WrapObject( unwrap( self ):__sub( unwrap( a ) ) )
end


--- Return the Forward Vector ( direction the angle points ).
-- @return vector normalised.
function ang_methods:getForward ()
	return SF.WrapObject( unwrap( self ):Forward() )
end

--- Returns if p,y,r are all 0.
-- @return boolean
function ang_methods:isZero ()
	return unwrap( self ):IsZero()
end

--- Normalise angles eg (0,181,1) -> (0,-179,1).
-- @return nil
function ang_methods:normalize ()
	unwrap( self ):Normalize()
end

--- Return the Right Vector relative to the angle dir.
-- @return vector normalised.
function ang_methods:getRight ()
	return SF.WrapObject( unwrap( self ):Right() )
end

--- Return Rotated angle around the specified axis.
-- @param v Vector axis
-- @param deg Number of degrees or nil if radians.
-- @param rad Number of radians or nil if degrees.
-- @return The modified angle
function ang_methods:rotateAroundAxis ( v, deg, rad )
	SF.CheckType( v, SF.Types[ "Vector" ] )
	if rad then
		SF.CheckType( rad, "number" )
		deg = math.deg( rad )
	else
		SF.CheckType( deg, "number" )
	end
	local ret = Angle()
	ret:Set( unwrap( self ) )
	ret:RotateAroundAxis( SF.UnwrapObject( v ), deg )
	return wrap( ret )
end

--- Copies p,y,r from second angle to the first.
-- @param a Angle to copy from.
-- @return nil
function ang_methods:set ( a )
	SF.CheckType( a, SF.Types[ "Angle" ] )
	unwrap( self ):Set( unwrap( a ) )
end

--- Return the Up Vector relative to the angle dir.
-- @return vector normalised.
function ang_methods:getUp ()
	return SF.WrapObject( unwrap( self ):Up() )
end

--- Sets p,y,r to 0. This is faster than doing it manually.
-- @return nil
function ang_methods:setZero ()
	unwrap( self ):Zero()
end
