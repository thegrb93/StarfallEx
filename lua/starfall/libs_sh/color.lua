-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check
local dgetmeta = debug.getmetatable

local math_Clamp = math.Clamp
local clamp = function(v) return math_Clamp(v, 0, 255) end


--- Color type
-- @name Color
-- @class type
-- @libtbl color_methods
-- @libtbl color_meta
SF.RegisterType("Color", nil, nil, debug.getregistry().Color, nil, function(checktype, color_meta)
	return function(clr)
		return setmetatable({ clr.r, clr.g, clr.b, clr.a }, color_meta)
	end,
	function(obj)
		checktype(obj, color_meta, 2)
		return Color((tonumber(obj[1]) or 255), (tonumber(obj[2]) or 255), (tonumber(obj[3]) or 255), (tonumber(obj[4]) or 255))
	end
end)


return function(instance)

local color_methods, color_meta, cwrap, unwrap = instance.Types.Color.Methods, instance.Types.Color, instance.Types.Color.Wrap, instance.Types.Color.Unwrap
local function wrap(tbl)
	return setmetatable(tbl, color_meta)
end

--- Creates a table struct that resembles a Color
-- @name builtins_library.Color
-- @class function
-- @param r - Red
-- @param g - Green
-- @param b - Blue
-- @param a - Alpha
-- @return New color
instance.env.Color = function (r, g, b, a)
	if r then checkluatype(r, TYPE_NUMBER) else r = 255 end
	if g then checkluatype(g, TYPE_NUMBER) else g = 255 end
	if b then checkluatype(b, TYPE_NUMBER) else b = 255 end
	if a then checkluatype(a, TYPE_NUMBER) else a = 255 end
	return wrap({ r, g, b, a })
end

-- Lookup table.
-- Index 1->4 have associative rgba for use in __index. Saves lots of checks
-- String based indexing returns string, just a pass through.
-- Think of rgb as a template for members of Color that are expected.
local rgb = { r = 1, g = 2, b = 3, a = 4, h = 1, s = 2, v = 3, l = 3 }

--- __newindex metamethod
function color_meta.__newindex(t, k, v)
	if rgb[k] then
		rawset(t, rgb[k], v)
	else
		rawset(t, k, v)
	end
end

--- __index metamethod
function color_meta.__index(t, k)
	local method = color_methods[k]
	if method then
		return method
	elseif rgb[k] then
		return rawget(t, rgb[k])
	end
end

--- __tostring metamethod
function color_meta.__tostring(c)
	return c[1] .. " " .. c[2] .. " " .. c[3] .. " " .. c[4]
end

--- __concat metamethod
function color_meta.__concat(...)
	local t = { ... }
	return tostring(t[1]) .. tostring(t[2])
end

--- __eq metamethod
function color_meta.__eq(a, b)
	return a[1]==b[1] and a[2]==b[2] and a[3]==b[3] and a[4]==b[4]
end

--- addition metamethod
-- @param lhs Left side of equation
-- @param rhs Right side of equation
-- @return Added color.
function color_meta.__add(a, b)

	return wrap({ clamp(a[1] + b[1]), clamp(a[2] + b[2]), clamp(a[3] + b[3]), clamp(a[4] + b[4]) })
end

--- subtraction metamethod
-- @param lhs Left side of equation
-- @param rhs Right side of equation
-- @return Subtracted color.
function color_meta.__sub(a, b)

	return wrap({ clamp(a[1]-b[1]), clamp(a[2]-b[2]), clamp(a[3]-b[3]), clamp(a[4]-b[4]) })
end

--- multiplication metamethod
-- @param b Number or Color to multiply by
-- @return Scaled color.
function color_meta.__mul(a, b)
	if isnumber(b) then
		return wrap({ clamp(a[1] * b), clamp(a[2] * b), clamp(a[3] * b), clamp(a[4] * b) })
	elseif isnumber(a) then
		return wrap({ clamp(b[1] * a), clamp(b[2] * a), clamp(b[3] * a), clamp(b[4] * a) })
	elseif dgetmeta(a) == color_meta and dgetmeta(b) == color_meta then
		return wrap({ clamp(a[1] * b[1]), clamp(a[2] * b[2]), clamp(a[3] * b[3]), clamp(a[4] * b[4]) })
	elseif dgetmeta(a) == color_meta then
		checkluatype(b, TYPE_NUMBER)
	else
		checkluatype(a, TYPE_NUMBER)
	end
end

--- division metamethod
-- @param b Number or Color to multiply by
-- @return Scaled color.
function color_meta.__div(a, b)
	if isnumber(b) then
		return wrap({ clamp(a[1] / b), clamp(a[2] / b), clamp(a[3] / b), clamp(a[4] / b) })
	elseif isnumber(a) then
		return wrap({ clamp(b[1] / a), clamp(b[2] / a), clamp(b[3] / a), clamp(b[4] / a) })
	elseif dgetmeta(a) == color_meta and dgetmeta(b) == color_meta then
		return wrap({ clamp(a[1] / b[1]), clamp(a[2] / b[2]), clamp(a[3] / b[3]), clamp(a[4] / b[4]) })
	elseif dgetmeta(a) == color_meta then
		checkluatype(b, TYPE_NUMBER)
	else
		checkluatype(a, TYPE_NUMBER)
	end
end

--- Converts the color from RGB to HSV.
--@shared
--@return A triplet of numbers representing HSV.
function color_methods:rgbToHSV()
	local h, s, v = ColorToHSV(self)
	return wrap({ h, s, v, 255 })
end

--- Converts the color from HSV to RGB.
--@shared
--@return A triplet of numbers representing HSV.
function color_methods:hsvToRGB()
	local rgb = HSVToColor(math.Clamp(self[1] % 360, 0, 360), math.Clamp(self[2], 0, 1), math.Clamp(self[3], 0, 1))
	return wrap({ rgb.r, rgb.g, rgb.b, (rgb.a or 255) })
end

--- Round the color values. Self-Modifies.
-- @param idp (Default 0) The integer decimal place to round to. 
-- @return nil
function color_methods:round(idp)
	self[1] = math.Round(self[1], idp)
	self[2] = math.Round(self[2], idp)
	self[3] = math.Round(self[3], idp)
	self[4] = math.Round(self[4], idp)
end

--- Copies r,g,b,a from color and returns a new color
-- @return The copy of the color
function color_methods:clone()
	return wrap({ self[1], self[2], self[3], self[4] })
end

--- Copies r,g,b,a from color to another.
-- @param b The color to copy from.
-- @return nil
function color_methods:set(b)
	self[1] = b[1]
	self[2] = b[2]
	self[3] = b[3]
	self[4] = b[4]
end

--- Set's the color's red channel and returns it.
-- @param r The red
-- @return The modified color
function color_methods:setR(r)
	self[1] = r
	return self
end

--- Set's the color's green and returns it.
-- @param g The green
-- @return The modified color
function color_methods:setG(g)
	self[2] = g
	return self
end

--- Set's the color's blue and returns it.
-- @param b The blue
-- @return The modified color
function color_methods:setB(b)
	self[3] = b
	return self
end

--- Set's the color's alpha and returns it.
-- @param a The alpha
-- @return The modified color
function color_methods:setA(a)
	self[4] = a
	return self
end

end
