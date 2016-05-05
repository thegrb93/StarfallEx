SF.Color = {}

--- Color type
--@shared
local color_methods, color_metatable = SF.Typedef( "Color", {} )

local function wrap_color( table )
	return setmetatable( table, color_metatable )
end

local function unwrap_color( obj )
	return Color( (obj[1] or 255), (obj[2] or 255),
		(obj[3] or 255), (obj[4] or 255) )
end

local wrap, unwrap = wrap_color, unwrap_color

SF.Color.Methods = color_methods
SF.Color.Metatable = color_metatable
SF.Color.Wrap = wrap
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

local _p = color_metatable.__index

--- __index metamethod
function color_metatable.__index ( t, k )
	if rgb[ k ] then
		return rawget( t, rgb[ k ] )
	else
		return rawget( t, k )
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
	return ( unwrap(self):__eq(unwrap(c)) )
end

local clamp = math.Clamp

--- addition metamethod
-- @param lhs Left side of equation
-- @param rhs Right side of equation
-- @return Added color.
function color_metatable.__add ( lhs, rhs )
	SF.CheckType( lhs, color_metatable )
	SF.CheckType( rhs, color_metatable )
	local a, b = lhs, rhs
	return wrap( { clamp( a.r + b.r, 0, 255 ), clamp( a.g + b.g, 0, 255 ), clamp( a.b + b.b, 0, 255 ), clamp( a.a + b.a, 0, 255 ) } )
end

--- subtraction metamethod
-- @param lhs Left side of equation
-- @param rhs Right side of equation
-- @return Subtracted color.
function color_metatable.__sub ( lhs, rhs )
	SF.CheckType( lhs, color_metatable )
	SF.CheckType( rhs, color_metatable )
	local a, b = lhs, rhs
	return wrap( { clamp( a.r - b.r, 0, 255 ), clamp( a.g - b.g, 0, 255 ), clamp( a.b - b.b, 0, 255 ), clamp( a.a - b.a, 0, 255 ) } )
end

--- multiplication metamethod
-- @param lhs Left side of equation
-- @param rhs Right side of equation
-- @return Scaled color.
function color_metatable.__mul ( lhs, rhs )
	if dgetmeta( lhs ) == color_metatable then
		SF.CheckType( rhs, "number" )
		local c = lhs
		return wrap( { clamp( c.r * rhs, 0, 255 ), clamp( c.g * rhs, 0, 255 ), clamp( c.b * rhs, 0, 255 ), clamp( c.a * rhs, 0, 255 ) } )
	else
		SF.CheckType( lhs, "number" )
		local c = rhs
		return wrap( { clamp( c.r * lhs, 0, 255 ), clamp( c.g * lhs, 0, 255 ), clamp( c.b * lhs, 0, 255 ), clamp( c.a * lhs, 0, 255 ) } )
	end
end

--- division metamethod
-- @param rhs Right side of equation
-- @return Scaled color.
function color_metatable:__div ( rhs )
	SF.CheckType( rhs, "number" )
	local c = self
	return wrap( { clamp( c.r / rhs, 0, 255 ), clamp( c.g / rhs, 0, 255 ), clamp( c.b / rhs, 0, 255 ), clamp( c.a / rhs, 0, 255 ) } )
end

--- Converts the color from RGB to HSV.
--@shared
--@return A triplet of numbers representing HSV.
function color_methods:rgbToHSV ()
	local hsv = ColorToHSV( unwrap( self ) )
	return wrap( { hsv.r, hsv.g, hsv.b, (hsv.a or 255) } )
end

--- Converts the color from HSV to RGB.
--@shared
--@return A triplet of numbers representing HSV.
function color_methods:hsvToRGB ()
	local rgb = HSVToColor( self.r, self.g, self.b )
	return wrap( { rgb.r, rgb.g, rgb.b, (rgb.a or 255) } )
end
