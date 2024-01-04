-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local dgetmeta = debug.getmetatable

--- Angle Type
-- @name Angle
-- @class type
-- @field p The -90 to 90 pitch value of the euler angle. Can also be indexed with [1]
-- @field y The -180 to 180 yaw value of the euler angle. Can also be indexed with [2]
-- @field r The -180 to 180 roll value of the euler angle. Can also be indexed with [3]
-- @libtbl ang_methods
-- @libtbl ang_meta
SF.RegisterType("Angle", nil, nil, FindMetaTable("Angle"), nil, function(checktype, ang_meta)
	return function(ang)
		return setmetatable({ ang:Unpack() }, ang_meta)
	end,
	function(obj)
		checktype(obj, ang_meta, 2)
		return Angle(obj[1], obj[2], obj[3])
	end
end)


return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local ang_methods, ang_meta, awrap, unwrap = instance.Types.Angle.Methods, instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local function wrap(tbl)
	return setmetatable(tbl, ang_meta)
end

--- Creates an Angle struct.
-- @name builtins_library.Angle
-- @class function
-- @param number? p Pitch
-- @param number? y Yaw
-- @param number? r Roll
-- @return Angle Angle struct
instance.env.Angle = function (p, y, r)
	if p~=nil then checkluatype(p, TYPE_NUMBER) else p = 0 end
	if y~=nil then checkluatype(y, TYPE_NUMBER) else y = p end
	if r~=nil then checkluatype(r, TYPE_NUMBER) else r = p end
	return wrap({ p, y, r })
end

-- Lookup table.
-- Index 1->6 have associative pyr for use in __index. Saves lots of checks
-- String based indexing returns string, just a pass through.
local pyr = { p = 1, y = 2, r = 3, pitch = 1, yaw = 2, roll = 3 }

--- Sets a value at a key in the angle
-- @param Angle Ang
-- @param number|string Key
-- @param number Value
function ang_meta.__newindex(t, k, v)
	if pyr[k] then
		rawset(t, pyr[k], v)
	else
		rawset(t, k, v)
	end
end

--- Gets a value at a key in the angle
-- Can be indexed with: 1, 2, 3, p, y, r, pitch, yaw, roll. 1,2,3 is most efficient.
-- @param number|string Key
-- @return number Value
function ang_meta.__index(t, k)
	local method = ang_methods[k]
	if method then
		return method
	elseif pyr[k] then
		return rawget(t, pyr[k])
	end
end

local table_concat = table.concat

--- Turns an angle into a string.
-- @return string String representing the angle.
function ang_meta.__tostring(a)
	return table_concat(a, ' ', 1, 3)
end

--- Multiplication metamethod
-- @param number|Angle a1 Number or Angle multiplicand.
-- @param number|Angle a2 Number or Angle multiplier.
-- @return Angle Resultant angle.
function ang_meta.__mul(a, b)
	if isnumber(b) then
		return wrap({ a[1] * b, a[2] * b, a[3] * b })
	elseif isnumber(a) then
		return wrap({ b[1] * a, b[2] * a, b[3] * a })
	elseif dgetmeta(a) == ang_meta and dgetmeta(b) == ang_meta then
		return wrap({ a[1] * b[1], a[2] * b[2], a[3] * b[3] })
	elseif dgetmeta(a) == ang_meta then
		checkluatype(b, TYPE_NUMBER)
	else
		checkluatype(a, TYPE_NUMBER)
	end
end

--- Division metamethod
-- @param number|Angle a1 Number or Angle dividend.
-- @param number|Angle a2 Number or Angle divisor.
-- @return Angle Resultant angle.
function ang_meta.__div(a, b)
	if isnumber(b) then
		return wrap({ a[1] / b, a[2] / b, a[3] / b })
	elseif isnumber(a) then
		return wrap({ a / b[1], a / b[2], a / b[3] })
	elseif dgetmeta(a) == ang_meta and dgetmeta(b) == ang_meta then
		return wrap({ a[1] / b[1], a[2] / b[2], a[3] / b[3] })
	elseif dgetmeta(a) == ang_meta then
		checkluatype(b, TYPE_NUMBER)
	else
		checkluatype(a, TYPE_NUMBER)
	end
end

--- Unary Minus metamethod (Negative)
-- @return Angle Negative angle.
function ang_meta.__unm(a)
	return wrap({ -a[1], -a[2], -a[3] })
end

--- Equivalence metamethod
-- @param Angle a1 Initial angle.
-- @param Angle a2 Angle to check against.
-- @return boolean Whether their fields are equal
function ang_meta.__eq(a, b)
	return a[1]==b[1] and a[2]==b[2] and a[3]==b[3]
end

--- Addition metamethod
-- @param Angle a1 Initial angle.
-- @param Angle a2 Angle to add to the first.
-- @return Angle Resultant angle.
function ang_meta.__add(a, b)
	return wrap({ a[1] + b[1], a[2] + b[2], a[3] + b[3] })
end

--- Subtraction metamethod
-- @param Angle a1 Initial angle.
-- @param Angle a2 Angle to subtract.
-- @return Angle Resultant angle.
function ang_meta.__sub(a, b)
	return wrap({ a[1]-b[1], a[2]-b[2], a[3]-b[3] })
end

--- Returns if p,y,r are all 0.
-- @return boolean If they are all zero
function ang_methods:isZero()
	return self[1]==0 and self[2]==0 and self[3]==0
end

--- Return the Forward Vector ( direction the angle points ).
-- @return Vector Forward direction.
function ang_methods:getForward()
	return vwrap(unwrap(self):Forward())
end

--- Return the Right Vector relative to the angle dir.
-- @return Vector Right direction.
function ang_methods:getRight()
	return vwrap(unwrap(self):Right())
end

--- Return the Up Vector relative to the angle dir.
-- @return Vector Up direction.
function ang_methods:getUp()
	return vwrap(unwrap(self):Up())
end

--- Return Rotated angle around the specified axis.
-- @param Vector v Vector axis
-- @param number? deg Number of degrees or nil if radians.
-- @param number? rad Number of radians or nil if degrees.
-- @return Angle The modified angle
function ang_methods:rotateAroundAxis(v, deg, rad)

	if rad then
		checkluatype (rad, TYPE_NUMBER)
		deg = math.deg(rad)
	else
		checkluatype (deg, TYPE_NUMBER)
	end

	local ret = Angle()

	ret:Set(unwrap(self))
	ret:RotateAroundAxis(vunwrap(v), deg)

	return awrap(ret)
end

--- Round the angle values.
-- Self-Modifies. Does not return anything
-- @param number? idp (Default 0) The integer decimal place to round to.
function ang_methods:round(idp)
	self[1] = math.Round(self[1], idp)
	self[2] = math.Round(self[2], idp)
	self[3] = math.Round(self[3], idp)
end

--- Copies p,y,r from angle and returns a new angle
-- @return Angle The copy of the angle
function ang_methods:clone()
	return wrap({ self[1], self[2], self[3] })
end

--- Copies p,y,r from angle to another.
-- Self-Modifies. Does not return anything
-- @param Angle b The angle to copy from.
function ang_methods:set(b)
	self[1] = b[1]
	self[2] = b[2]
	self[3] = b[3]
end

--- Sets p,y,r to 0. This is faster than doing it manually.
-- Self-Modifies. Does not return anything
function ang_methods:setZero()
	self[1] = 0
	self[2] = 0
	self[3] = 0
end

--- Set's the angle's pitch and returns self.
-- @param number p The pitch
-- @return Angle Angle after modification
function ang_methods:setP(p)
	self[1] = p
	return self
end

--- Set's the angle's yaw and returns self.
-- @param number y The yaw
-- @return Angle Angle after modification
function ang_methods:setY(y)
	self[2] = y
	return self
end

--- Set's the angle's roll and returns self.
-- @param number r The roll
-- @return Angle Angle after modification
function ang_methods:setR(r)
	self[3] = r
	return self
end

end
