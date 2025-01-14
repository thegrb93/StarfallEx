-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local dgetmeta = debug.getmetatable
local COL_META = FindMetaTable("Color")
local Col_SetUnpacked,Col_Unpack = COL_META.SetUnpacked,COL_META.Unpack

local math_Clamp = math.Clamp
local clamp = function(v) return math_Clamp(v, 0, 255) end

local bit_rshift = bit.rshift
local hex_to_rgb = {
	[3] = function(v) return {
		bit_rshift(v, 8) % 0x10 * 0x11,
		bit_rshift(v, 4) % 0x10 * 0x11,
		v % 0x10 * 0x11,
		0xFF
	} end,
	[4] = function(v) return {
		bit_rshift(v, 12) % 0x10 * 0x11,
		bit_rshift(v, 8) % 0x10 * 0x11,
		bit_rshift(v, 4) % 0x10 * 0x11,
		v % 0x10 * 0x11,
	} end,
	[6] = function(v) return {
		bit_rshift(v, 16) % 0x100,
		bit_rshift(v, 8) % 0x100,
		v % 0x100,
		0xFF
	} end,
	[8] = function(v) return {
		bit_rshift(v, 24) % 0x100,
		bit_rshift(v, 16) % 0x100,
		bit_rshift(v, 8) % 0x100,
		v % 0x100
	} end,
}

--- Color type
-- @name Color
-- @class type
-- @field r The 0-255 red value of the color. Can also be indexed with [1]
-- @field g The 0-255 green value of the color. Can also be indexed with [2]
-- @field b The 0-255 blue value of the color. Can also be indexed with [3]
-- @field a The 0-255 alpha value of the color. Can also be indexed with [4]
-- @libtbl color_methods
-- @libtbl color_meta
SF.RegisterType("Color", nil, nil, FindMetaTable("Color"), nil, function(checktype, color_meta)
	return function(clr)
		-- Colors don't sanitize their member types so tonumber needed
		-- https://github.com/Facepunch/garrysmod-issues/issues/6131
		local r,g,b,a = Col_Unpack(clr)
		return setmetatable({tonumber(r) or 255, tonumber(g) or 255, tonumber(b) or 255, tonumber(a) or 255}, color_meta)
	end,
	function(obj)
		checktype(obj, color_meta, 2)
		return Color((tonumber(obj[1]) or 255), (tonumber(obj[2]) or 255), (tonumber(obj[3]) or 255), (tonumber(obj[4]) or 255))
	end
end)


return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local color_methods, color_meta, cwrap, unwrap = instance.Types.Color.Methods, instance.Types.Color, instance.Types.Color.Wrap, instance.Types.Color.Unwrap
local function wrap(tbl)
	return setmetatable(tbl, color_meta)
end

local function QuickUnwrapper()
	-- Colors don't sanitize their member types so tonumber needed
	-- https://github.com/Facepunch/garrysmod-issues/issues/6131
	local Col = Color(255,255,255)
	return function(v) Col_SetUnpacked(Col, tonumber(v[1]) or 255, tonumber(v[2]) or 255, tonumber(v[3]) or 255, tonumber(v[4]) or 255) return Col end
end
color_meta.QuickUnwrap1 = QuickUnwrapper()

--- Creates a table struct that resembles a Color
-- E.g. Color(255,0,0) Color("#FF0000") Color()
-- @name builtins_library.Color
-- @class function
-- @param number|string|nil r Red component or string hexadecimal color. Defaults to 255.
-- @param number? g Green component. Defaults to 255.
-- @param number? b Blue component. Defaults to 255.
-- @param number? a Alpha component. Defaults to 255.
-- @return Color New color
function instance.env.Color(r, g, b, a)
	if isstring(r) then
		local hex = string.match(r, "^#?(%x+)$") or SF.Throw("Invalid hexadecimal color", 2)
		local h2r = hex_to_rgb[#hex]
		if h2r then
			return wrap(h2r(tonumber(hex, 16)))
		else
			SF.Throw("Invalid hexadecimal color length", 2)
		end
	else
		if r~=nil then checkluatype(r, TYPE_NUMBER) else r = 255 end
		if g~=nil then checkluatype(g, TYPE_NUMBER) else g = 255 end
		if b~=nil then checkluatype(b, TYPE_NUMBER) else b = 255 end
		if a~=nil then checkluatype(a, TYPE_NUMBER) else a = 255 end
		return wrap({ r, g, b, a })
	end
end

-- Lookup table.
-- Index 1->4 have associative rgba for use in __index. Saves lots of checks
-- String based indexing returns string, just a pass through.
-- Think of rgb as a template for members of Color that are expected.
local rgb = { r = 1, g = 2, b = 3, a = 4, h = 1, s = 2, v = 3, l = 3 }

--- Sets a value at a key in the color
-- @param number|string k Key. Number or string
-- @param number v Value.
function color_meta.__newindex(t, k, v)
	if rgb[k] then
		rawset(t, rgb[k], v)
	else
		rawset(t, k, v)
	end
end

--- Gets a value at a key in the color
-- @param number|string k Key. Number or string
-- @return number Value at the index
function color_meta.__index(t, k)
	local method = color_methods[k]
	if method then
		return method
	elseif rgb[k] then
		return rawget(t, rgb[k])
	end
end

--- Turns the color into a string
-- @return string String representation of the color
function color_meta.__tostring(c)
	return c[1] .. " " .. c[2] .. " " .. c[3] .. " " .. c[4]
end

--- Concatenation metamethod
-- @return string Adds two colors into one string-representation
function color_meta.__concat(a, b)
	return tostring(a) .. tostring(b)
end

--- Equivalence metamethod
-- @param Color c1 Initial color.
-- @param Color c2 Color to check against.
-- @return boolean Whether their fields are equal
function color_meta.__eq(a, b)
	return a[1]==b[1] and a[2]==b[2] and a[3]==b[3] and a[4]==b[4]
end

--- Addition metamethod
-- @param Color c1 Initial color.
-- @param Color c2 Color to add to the first.
-- @return Color Resultant color.
function color_meta.__add(a, b)
	return wrap({ a[1] + b[1], a[2] + b[2], a[3] + b[3], a[4] + b[4] })
end

--- Subtraction metamethod
-- @param Color c1 Initial color.
-- @param Color c2 Color to subtract.
-- @return Color Resultant color.
function color_meta.__sub(a, b)
	return wrap({ a[1]-b[1], a[2]-b[2], a[3]-b[3], a[4]-b[4] })
end

--- Multiplication metamethod
-- @param number|Color a Number or Color multiplicant
-- @param number|Color b Number or Color multiplier
-- @return Color Multiplied color.
function color_meta.__mul(a, b)
	if isnumber(b) then
		return wrap({ a[1] * b, a[2] * b, a[3] * b, a[4] * b })
	elseif isnumber(a) then
		return wrap({ b[1] * a, b[2] * a, b[3] * a, b[4] * a })
	elseif dgetmeta(a) == color_meta and dgetmeta(b) == color_meta then
		return wrap({ a[1] * b[1], a[2] * b[2], a[3] * b[3], a[4] * b[4] })
	elseif dgetmeta(a) == color_meta then
		checkluatype(b, TYPE_NUMBER)
	else
		checkluatype(a, TYPE_NUMBER)
	end
end

--- Division metamethod
-- @param number|Color a Number or Color dividend
-- @param number|Color b Number or Color divisor
-- @return Color Scaled color.
function color_meta.__div(a, b)
	if isnumber(b) then
		return wrap({ a[1] / b, a[2] / b, a[3] / b, a[4] / b })
	elseif isnumber(a) then
		return wrap({ b[1] / a, b[2] / a, b[3] / a, b[4] / a })
	elseif dgetmeta(a) == color_meta and dgetmeta(b) == color_meta then
		return wrap({ a[1] / b[1], a[2] / b[2], a[3] / b[3], a[4] / b[4] })
	elseif dgetmeta(a) == color_meta then
		checkluatype(b, TYPE_NUMBER)
	else
		checkluatype(a, TYPE_NUMBER)
	end
end

--- Converts the color from RGB to HSV.
-- @shared
-- @return Color A triplet of numbers representing HSV.
function color_methods:rgbToHSV()
	local h, s, v = ColorToHSV(self)
	return wrap({ h, s, v, 255 })
end

--- Converts the color from HSV to RGB.
-- @shared
-- @return Color A triplet of numbers representing HSV.
function color_methods:hsvToRGB()
	local rgb = HSVToColor(math.Clamp(self[1] % 360, 0, 360), math.Clamp(self[2], 0, 1), math.Clamp(self[3], 0, 1))
	return wrap({ rgb.r, rgb.g, rgb.b, (rgb.a or 255) })
end

--- Returns a hexadecimal string representation of the color
-- @param boolean? alpha Optional boolean whether to include the alpha channel, False by default
-- @return string String hexadecimal color
function color_methods:toHex(alpha)
	if alpha~=nil then checkluatype(alpha, TYPE_BOOL) end
	if alpha then
		return string.format("%02x%02x%02x%02x", self[1], self[2], self[3], self[4])
	else
		return string.format("%02x%02x%02x", self[1], self[2], self[3])
	end
end

--- Round the color values.
-- Self-Modifies. Does not return anything
-- @param number? idp (Default 0) The integer decimal place to round to.
function color_methods:round(idp)
	self[1] = math.Round(self[1], idp)
	self[2] = math.Round(self[2], idp)
	self[3] = math.Round(self[3], idp)
	self[4] = math.Round(self[4], idp)
end

--- Copies r,g,b,a from color and returns a new color
-- @return Color The copy of the color
function color_methods:clone()
	return wrap({ self[1], self[2], self[3], self[4] })
end

--- Copies r,g,b,a from color to another.
-- Self-Modifies. Does not return anything
-- @param Color b The color to copy from.
function color_methods:set(b)
	self[1] = b[1]
	self[2] = b[2]
	self[3] = b[3]
	self[4] = b[4]
end

--- Set's the color's red channel and returns self.
-- @param number r The red
-- @return Color Color after modification
function color_methods:setR(r)
	self[1] = r
	return self
end

--- Set's the color's green and returns self.
-- @param number g The green
-- @return Color Color after modification
function color_methods:setG(g)
	self[2] = g
	return self
end

--- Set's the color's blue and returns self.
-- @param number b The blue
-- @return Color Color after modification
function color_methods:setB(b)
	self[3] = b
	return self
end

--- Set's the color's alpha and returns it.
-- @param number a The alpha
-- @return Color Color after modification
function color_methods:setA(a)
	self[4] = a
	return self
end

end
