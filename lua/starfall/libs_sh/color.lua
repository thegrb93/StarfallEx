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

--- __newindex metamethod
function color_metatable.__newindex ( t, k, v )
	rawset( t, k, v )
end

local _p = color_metatable.__index

--- __index metamethod
function color_metatable.__index ( t, k )
	if k == "r" or k == "g" or k == "b" or k == "a" then
		return unwrap( t )[ k ]
	end
	return _p[ k ]
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
