SF.Color = {}

--- Color type
--@shared
local color_methods, color_metatable = SF.Typedef( "Color" )

local wrap, unwrap = SF.CreateWrapper( color_metatable, true, false, debug.getregistry().Color )

SF.Color.Methods = color_methods
SF.Color.Metatable = color_metatable
SF.Color.Wrap = wrap
SF.Color.Unwrap = unwrap

--- Same as the Gmod Color type
-- @name SF.DefaultEnvironment.Color
-- @class function
-- @param r - Red
-- @param g - Green
-- @param b - Blue
-- @param a - Alpha
-- @return New color
SF.DefaultEnvironment.Color = function ( ... )
	return wrap( Color( ... ) )
end

-- Lookup table.
-- Index 1->4 have associative rgba for use in __index. Saves lots of checks
-- String based indexing returns string, just a pass through.
-- Think of rgb as a template for members of Color that are expected.
local rgb = { [ 1 ] = "r", [ 2 ] = "g", [ 3 ] = "b", [ 4 ] = "a", r = "r", g = "g", b = "b", a = "a" }

--- __newindex metamethod
function color_metatable.__newindex ( t, k, v )
	if rgb[ k ] then
		rawset( SF.UnwrapObject( t ), rgb[ k ], v )
	else
		rawset( t, k, v )
	end
end

local _p = color_metatable.__index

--- __index metamethod
function color_metatable.__index ( t, k )
	if rgb[ k ] then
		return rawget( SF.UnwrapObject( t ), rgb[ k ] )
	else
		return _p[ k ]
	end
end

--- __tostring metamethod
function color_metatable:__tostring ()
	return unwrap( self ):__tostring()
end

--- __concat metamethod
function color_metatable.__concat ( ... )
	local t = { ... }
	return tostring( t[ 1 ] ) .. tostring( t[ 2 ] )
end

--- __eq metamethod
function color_metatable:__eq ( c )
	SF.CheckType( self, color_metatable )
	SF.CheckType( c, color_metatable )
	return unwrap( self ):__eq( unwrap( c ) )
end

--- Converts the color from RGB to HSV.
--@shared
--@return A triplet of numbers representing HSV.
function color_methods:toHSV ()
	return ColorToHSV( unwrap( self ) )
end
