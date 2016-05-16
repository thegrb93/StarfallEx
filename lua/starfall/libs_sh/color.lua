SF.Color = {}

--- Color type
--@shared
local color_methods, color_metatable = SF.Typedef( "Color" )

local function wrap_color( table )
	for i=1, 4 do if table[i] == nil then table[i] = 255 end end
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

local _p = color_metatable.__methods

--- __index metamethod
function color_metatable.__index ( t, k )
	if rgb[ k ] then
		return rawget( t, rgb[ k ] )
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
function color_metatable:__eq ( rhs )
	SF.CheckType( rhs, color_metatable )

	if #rhs ~= #self then return false end

	for k, v in pairs( rhs ) do
		if v ~= self[k] then return false end
	end

	return true
end

local function clamp( val ) -- static color clamp
	if val < 0 then return 0 end
	if val > 255 then return 255 end
	return val
end

--- addition metamethod
-- @param lhs Left side of equation
-- @param rhs Right side of equation
-- @return Added color.
function color_metatable:__add ( rhs )
	SF.CheckType( self, color_metatable )
	SF.CheckType( rhs, color_metatable )

	local a, b = self, rhs
	return wrap( { clamp( a.r + b.r ), clamp( a.g + b.g ), clamp( a.b + b.b ),
		clamp( a.a + b.a ) } )
end

--- subtraction metamethod
-- @param lhs Left side of equation
-- @param rhs Right side of equation
-- @return Subtracted color.
function color_metatable:__sub ( rhs )
	SF.CheckType( self, color_metatable )
	SF.CheckType( rhs, color_metatable )

	local a, b = self, rhs
	return wrap( { clamp( a.r - b.r ), clamp( a.g - b.g  ), clamp( a.b - b.b ),
		clamp( a.a - b.a ) } )
end

--- multiplication metamethod
-- @param lhs Left side of equation
-- @param rhs Right side of equation
-- @return Scaled color.
function color_metatable.__mul ( lhs, rhs )
	if dgetmeta( lhs ) == color_metatable then
		SF.CheckType( rhs, "number" )
		local c = lhs
		return wrap( { clamp( c.r * rhs ), clamp( c.g * rhs ),
			clamp( c.b * rhs ), clamp( c.a * rhs ) } )
	else
		SF.CheckType( lhs, "number" )
		local c = rhs
		return wrap( { clamp( c.r * lhs ), clamp( c.g * lhs ),
			clamp( c.b * lhs ), clamp( c.a * lhs ) } )
	end
end

--- division metamethod
-- @param rhs Right side of equation
-- @return Scaled color.
function color_metatable:__div ( rhs )
	SF.CheckType( rhs, "number" )
	local c = self
	return wrap( { clamp( c.r / rhs ), clamp( c.g / rhs ), clamp( c.b / rhs  ),
		clamp( c.a / rhs ) } )
end

--- Converts the color from RGB to HSV.
--@shared
--@return A color type (note: color types can be indexed by h, s, v!)
function color_methods:rgbToHSV ()
	local h, s, v = ColorToHSV( self )
	return wrap( { h, s, v, 255 } )
end

--- Converts the color from HSV to RGB.
--@shared
--@return A color type
function color_methods:hsvToRGB ()
	local rgb = HSVToColor( self.r, self.g, self.b )
	return wrap( { rgb.r, rgb.g, rgb.b, (rgb.a or 255) } )
end
