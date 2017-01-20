SF.Color = {}

--- Color type
--@shared
local color_methods, color_metatable = SF.Typedef( "Color", {} )

local function wrap( tbl )
	return setmetatable( tbl, color_metatable )
end

local function unwrap( obj )
	return Color( (tonumber(obj[1]) or 255), (tonumber(obj[2]) or 255), (tonumber(obj[3]) or 255), (tonumber(obj[4]) or 255) )
end

local function cwrap( clr )
	return wrap( { clr.r, clr.g, clr.b, clr.a } )
end

SF.AddObjectWrapper( debug.getregistry().Color, color_metatable, cwrap )
SF.AddObjectUnwrapper( color_metatable, unwrap )

SF.Color.Methods = color_methods
SF.Color.Metatable = color_metatable
SF.Color.Wrap = cwrap
SF.Color.Unwrap = unwrap

local dgetmeta = debug.getmetatable
--- Creates a table struct that resembles a Color/
-- @name SF.DefaultEnvironment.Color
-- @class function
-- @param r - Red
-- @param g - Green
-- @param b - Blue
-- @param a - Alpha
-- @return New color
SF.DefaultEnvironment.Color = function ( r, g, b, a )
	return wrap( { r or 255, g or 255, b or 255, a or 255 } )
end

-- Lookup table.
-- Index 1->4 have associative rgba for use in __index. Saves lots of checks
-- String based indexing returns string, just a pass through.
-- Think of rgb as a template for members of Color that are expected.
local rgb = { r = 1, g = 2, b = 3, a = 4, h = 1, s = 2, v = 3, l = 3 }

--- __newindex metamethod
function color_metatable.__newindex ( t, k, v )
	if rgb[ k ] then
		rawset( t, rgb[ k ], v )
	else
		rawset( t, k, v )
	end
end

local _p = color_metatable.__methods

--- __index metamethod
function color_metatable.__index ( t, k )
	if rgb[ k ] then
		return rawget( t, rgb[ k ] )
	else
		return _p[k]
	end
end

--- __tostring metamethod
function color_metatable.__tostring ( c )
	return c[1] .. " " .. c[2] .. " " .. c[3] .. " " .. c[4]
end

--- __concat metamethod
function color_metatable.__concat ( ... )
	local t = { ... }
	return tostring( t[ 1 ] ) .. tostring( t[ 2 ] )
end

--- __eq metamethod
function color_metatable.__eq ( a, b )
	return a[1]==b[1] and a[2]==b[2] and a[3]==b[3] and a[4]==b[4]
end

local math_Clamp = math.Clamp
local clamp = function(v) return math_Clamp( v, 0, 255 ) end

--- addition metamethod
-- @param lhs Left side of equation
-- @param rhs Right side of equation
-- @return Added color.
function color_metatable.__add ( a, b )
	SF.CheckType( a, color_metatable )
	SF.CheckType( b, color_metatable )

	return wrap( { clamp( a[1]+b[1] ), clamp( a[2]+b[2] ), clamp( a[3]+b[3] ), clamp( a[4]+b[4] ) } )
end

--- subtraction metamethod
-- @param lhs Left side of equation
-- @param rhs Right side of equation
-- @return Subtracted color.
function color_metatable.__sub ( a, b )
	SF.CheckType( a, color_metatable )
	SF.CheckType( b, color_metatable )

	return wrap( { clamp( a[1]-b[1] ), clamp( a[2]-b[2] ), clamp( a[3]-b[3] ), clamp( a[4]-b[4] ) } )
end

--- multiplication metamethod
-- @param lhs Left side of equation
-- @param rhs Right side of equation
-- @return Scaled color.
function color_metatable.__mul ( a, b )
	if dgetmeta( a ) == color_metatable then
		SF.CheckType( b, "number" )

		return wrap( { clamp( a[1]*b ), clamp( a[2]*b ), clamp( a[3]*b ), clamp( a[4]*b ) } )
	else
		SF.CheckType( a, "number" )

		return wrap( { clamp( b[1]*a ), clamp( b[2]*a ), clamp( b[3]*a ), clamp( b[4]*a ) } )
	end
end

--- division metamethod
-- @param rhs Right side of equation
-- @return Scaled color.
function color_metatable.__div ( a, b )
	SF.CheckType( a, color_metatable )
	SF.CheckType( b, "number" )

	return wrap( { clamp( a[1]/b ), clamp( a[2]/b ), clamp( a[3]/b ), clamp( a[4]/b ) } )
end

--- Converts the color from RGB to HSV.
--@shared
--@return A triplet of numbers representing HSV.
function color_methods:rgbToHSV ()
	local h, s, v = ColorToHSV( self )
	return wrap( { h, s, v, 255 } )
end

--- Converts the color from HSV to RGB.
--@shared
--@return A triplet of numbers representing HSV.
function color_methods:hsvToRGB ()
	local rgb = HSVToColor( self[1], self[2], self[3] )
	return wrap( { rgb.r, rgb.g, rgb.b, (rgb.a or 255) } )
end

--- Set's the color's red channel and returns it.
-- @param r The red
-- @return The modified color
function color_methods:setR( r )
	self[1] = r
	return self
end

--- Set's the color's green and returns it.
-- @param g The green
-- @return The modified color
function color_methods:setG( g )
	self[2] = g
	return self
end

--- Set's the color's blue and returns it.
-- @param b The blue
-- @return The modified color
function color_methods:setB( b )
	self[3] = b
	return self
end

--- Set's the color's alpha and returns it.
-- @param a The alpha
-- @return The modified color
function color_methods:setA( a )
	self[4] = a
	return self
end
