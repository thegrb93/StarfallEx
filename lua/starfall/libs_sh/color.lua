SF.Color = {}

--- Color type
--@shared
local color_methods, color_metatable = SF.Typedef( "Color" )

local wrap, unwrap = SF.CreateWrapper( color_metatable, true, false, debug.getregistry().Color )

SF.Color.Methods = color_methods
SF.Color.Metatable = color_metatable
SF.Color.Wrap = wrap
SF.Color.Unwrap = unwrap

local dgetmeta = debug.getmetatable
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
	return self.r .. " " .. self.g .. " " .. self.b .. " " .. self.a
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

local clamp = math.Clamp

--- addition metamethod
-- @param lhs Left side of equation
-- @param rhs Right side of equation
-- @return Added color.
function color_metatable.__add ( lhs, rhs )
	SF.CheckType( lhs, color_metatable )
	SF.CheckType( rhs, color_metatable )
	local a, b = unwrap( lhs ), unwrap( rhs )
	return wrap( Color( clamp( a.r + b.r, 0, 255 ), clamp( a.g + b.g, 0, 255 ), clamp( a.b + b.b, 0, 255 ), clamp( a.a + b.a, 0, 255 ) ) )
end

--- subtraction metamethod
-- @param lhs Left side of equation
-- @param rhs Right side of equation
-- @return Subtracted color.
function color_metatable.__sub ( lhs, rhs )
	SF.CheckType( lhs, color_metatable )
	SF.CheckType( rhs, color_metatable )
	local a, b = unwrap( lhs ), unwrap( rhs )
	return wrap( Color( clamp( a.r - b.r, 0, 255 ), clamp( a.g - b.g, 0, 255 ), clamp( a.b - b.b, 0, 255 ), clamp( a.a - b.a, 0, 255 ) ) )
end

--- multiplication metamethod
-- @param lhs Left side of equation
-- @param rhs Right side of equation
-- @return Scaled color.
function color_metatable.__mul ( lhs, rhs )
	if dgetmeta( lhs ) == color_metatable then
		SF.CheckType( rhs, "number" )
		local c = unwrap( lhs )
		return wrap( Color( clamp( c.r * rhs, 0, 255 ), clamp( c.g * rhs, 0, 255 ), clamp( c.b * rhs, 0, 255 ), clamp( c.a * rhs, 0, 255 ) ) )
	else
		SF.CheckType( lhs, "number" )
		local c = unwrap( rhs )
		return wrap( Color( clamp( c.r * lhs, 0, 255 ), clamp( c.g * lhs, 0, 255 ), clamp( c.b * lhs, 0, 255 ), clamp( c.a * lhs, 0, 255 ) ) )
	end
end

--- division metamethod
-- @param rhs Right side of equation
-- @return Scaled color.
function color_metatable:__div ( rhs )
	SF.CheckType( rhs, "number" )
	local c = unwrap( self )
	return wrap( Color( clamp( c.r / rhs, 0, 255 ), clamp( c.g / rhs, 0, 255 ), clamp( c.b / rhs, 0, 255 ), clamp( c.a / rhs, 0, 255 ) ) )
end

--- Converts the color from RGB to HSV.
--@shared
--@return A triplet of numbers representing HSV.
function color_methods:rgbToHSV ()
	return wrap( ColorToHSV( unwrap( self ) ) )
end

--- Converts the color from HSV to RGB.
--@shared
--@return A triplet of numbers representing HSV.
function color_methods:hsvToRGB ()
	return wrap( HSVToColor( self.r, self.g, self.b ) )
end
