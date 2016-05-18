SF.Color = {}

--- Color type
--@shared
local color_methods, color_metatable = SF.Typedef( "Color", {} )

local function wrap( tbl )
	return setmetatable( { (tonumber(tbl[1]) or 255), (tonumber(tbl[2]) or 255), (tonumber(tbl[3]) or 255), (tonumber(tbl[4]) or 255) }, color_metatable )
end

local function unwrap( obj )
	return Color( (obj[1] or 255), (obj[2] or 255), (obj[3] or 255), (obj[4] or 255) )
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
SF.DefaultEnvironment.Color = function ( ... )
	return wrap( { ... } )
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
	return c.r .. " " .. c.g .. " " .. c.b .. " " .. c.a
end

--- __concat metamethod
function color_metatable.__concat ( ... )
	local t = { ... }
	return tostring( t[ 1 ] ) .. tostring( t[ 2 ] )
end

--- __eq metamethod
function color_metatable.__eq ( a, b )
	if dgetmeta(a) ~= color_metatable then return false end
	if dgetmeta(b) ~= color_metatable then return false end

	if #a ~= #b then return false end

	for k, v in pairs( a ) do
		if v ~= b[k] then return false end
	end

	return true
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

	return wrap( { clamp( a.r+b.r ), clamp( a.g+b.g ), clamp( a.b+b.b ), clamp( a.a+b.a ) } )
end

--- subtraction metamethod
-- @param lhs Left side of equation
-- @param rhs Right side of equation
-- @return Subtracted color.
function color_metatable.__sub ( a, b )
	SF.CheckType( a, color_metatable )
	SF.CheckType( b, color_metatable )

	return wrap( { clamp( a.r-b.r ), clamp( a.g-b.g ), clamp( a.b-b.b ), clamp( a.a-b.a ) } )
end

--- multiplication metamethod
-- @param lhs Left side of equation
-- @param rhs Right side of equation
-- @return Scaled color.
function color_metatable.__mul ( a, b )
	if dgetmeta( a ) == color_metatable then
		SF.CheckType( b, "number" )

		return wrap( { clamp( a.r*b ), clamp( a.g*b ), clamp( a.b*b ), clamp( a.a*b ) } )
	else
		SF.CheckType( a, "number" )

		return wrap( { clamp( b.r*a ), clamp( b.g*a ), clamp( b.b*a ), clamp( b.a*a ) } )
	end
end

--- division metamethod
-- @param rhs Right side of equation
-- @return Scaled color.
function color_metatable.__div ( a, b )
	SF.CheckType( a, color_metatable )
	SF.CheckType( b, "number" )

	return wrap( { clamp( a.r/b ), clamp( a.g/b ), clamp( a.b/b ), clamp( a.a/b ) } )
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
	local rgb = HSVToColor( self.r, self.g, self.b )
	return wrap( { rgb.r, rgb.g, rgb.b, (rgb.a or 255) } )
end
