SF.Angles = {}

--- Angle Type
-- @shared
local ang_methods, ang_metamethods = SF.RegisterType("Angle")
local checktype = SF.CheckType
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check

local function wrap(tbl)
	return setmetatable(tbl, ang_metamethods)
end

local function unwrap(obj)
	return Angle(obj[1], obj[2], obj[3])
end

local function awrap(ang)
	return wrap({ ang[1], ang[2], ang[3] })
end

SF.AddObjectWrapper(debug.getregistry().Angle, ang_metamethods, awrap)
SF.AddObjectUnwrapper(ang_metamethods, unwrap)

local vwrap
SF.AddHook("postload", function()
	vwrap = SF.Vectors.Wrap

	SF.DefaultEnvironment.Angle = function (p, y, r)
		p = p or 0
		return wrap({ p, y or p, r or p })
	end
end)

SF.Angles.Wrap 	= awrap
SF.Angles.Unwrap = unwrap
SF.Angles.Methods = ang_methods
SF.Angles.Metatable = ang_metamethods

local dgetmeta = debug.getmetatable

-- Lookup table.
-- Index 1->6 have associative pyr for use in __index. Saves lots of checks
-- String based indexing returns string, just a pass through.
local pyr = { p = 1, y = 2, r = 3, pitch = 1, yaw = 2, roll = 3 }

--- __newindex metamethod
function ang_metamethods.__newindex (t, k, v)
	if pyr[k] then
		rawset(t, pyr[k], v)
	else
		rawset(t, k, v)
	end
end

--- __index metamethod
function ang_metamethods.__index (t, k)
	if pyr[k] then
		return rawget(t, pyr[k])
	else
		return ang_methods[k]
	end
end

local table_concat = table.concat

local math_nAng = math.NormalizeAngle
local function normalizedAngTable(tbl)
	return { math_nAng(tbl[1]), math_nAng(tbl[2]), math_nAng(tbl[3]) }
end

--- tostring metamethod
-- @return string representing the angle.
function ang_metamethods.__tostring (a)
	return table_concat(a, ' ', 1, 3)
end

--- __mul metamethod ang1 * n.
-- @param n Number to multiply by.
-- @return resultant angle.
function ang_metamethods.__mul (a, n)
	checkluatype (n, TYPE_NUMBER)

	return wrap({ a[1] * n, a[2] * n, a[3] * n })
end

--- __div metamethod ang1 / n.
-- @param n Number to divided by.
-- @return resultant angle.
function ang_metamethods.__div (a, n)
	checktype(a, ang_metamethods)
	checkluatype (n, TYPE_NUMBER)

	return wrap({ a[1] / n, a[2] / n, a[3] / n })
end

--- __unm metamethod -ang.
-- @return resultant angle.
function ang_metamethods.__unm (a)
	return wrap({ -a[1], -a[2], -a[3] })
end

--- __eq metamethod ang1 == ang2.
-- @param a Angle to check against.
-- @return bool
function ang_metamethods.__eq (a, b)
	return a[1]==b[1] and a[2]==b[2] and a[3]==b[3]
end

--- __add metamethod ang1 + ang2.
-- @param a Angle to add.
-- @return resultant angle.
function ang_metamethods.__add (a, b)
	checktype(a, ang_metamethods)
	checktype(b, ang_metamethods)

	return wrap({ a[1] + b[1], a[2] + b[2], a[3] + b[3] })
end

--- __sub metamethod ang1 - ang2.
-- @param a Angle to subtract.
-- @return resultant angle.
function ang_metamethods.__sub (a, b)
	checktype(a, ang_metamethods)
	checktype(b, ang_metamethods)

	return wrap({ a[1]-b[1], a[2]-b[2], a[3]-b[3] })
end

--- Returns if p,y,r are all 0.
-- @return boolean
function ang_methods:isZero ()
	if self[1] ~= 0 then return false
	elseif self[2] ~= 0 then return false
	elseif self[3] ~= 0 then return false
	end

	return true
end

--- Normalise angles eg (0,181,1) -> (0,-179,1).
-- @return nil
function ang_methods:normalize ()
	self[1] = math_nAng(self[1])
	self[2] = math_nAng(self[2])
	self[3] = math_nAng(self[3])
end

--- Returnes a normalized angle
-- @return Normalized angle table
function ang_methods:getNormalized ()
	checktype(self, ang_metamethods)
	return wrap(normalizedAngTable(self))
end

--- Return the Forward Vector ( direction the angle points ).
-- @return vector normalised.
function ang_methods:getForward ()
	return vwrap(unwrap(self):Forward())
end

--- Return the Right Vector relative to the angle dir.
-- @return vector normalised.
function ang_methods:getRight ()
	return vwrap(unwrap(self):Right())
end

--- Return the Up Vector relative to the angle dir.
-- @return vector normalised.
function ang_methods:getUp ()
	return vwrap(unwrap(self):Up())
end

--- Return Rotated angle around the specified axis.
-- @param v Vector axis
-- @param deg Number of degrees or nil if radians.
-- @param rad Number of radians or nil if degrees.
-- @return The modified angle
function ang_methods:rotateAroundAxis (v, deg, rad)
	checktype(v, SF.Types["Vector"])

	if rad then
		checkluatype (rad, TYPE_NUMBER)
		deg = math.deg(rad)
	else
		checkluatype (deg, TYPE_NUMBER)
	end

	local ret = Angle()

	ret:Set(unwrap(self))
	ret:RotateAroundAxis(SF.UnwrapObject(v), deg)

	return awrap(ret)
end

--- Copies p,y,r from angle and returns a new angle
-- @return The copy of the angle
function ang_methods:clone()
	return wrap({ self[1], self[2], self[3] })
end

--- Copies p,y,r from angle to another.
-- @param b The angle to copy from.
-- @return nil
function ang_methods:set(b)
	self[1] = b[1]
	self[2] = b[2]
	self[3] = b[3]
end

--- Sets p,y,r to 0. This is faster than doing it manually.
-- @return nil
function ang_methods:setZero ()
	self[1] = 0
	self[2] = 0
	self[3] = 0
end

--- Set's the angle's pitch and returns it.
-- @param p The pitch
-- @return The modified angle
function ang_methods:setP(p)
	self[1] = p
	return self
end

--- Set's the angle's yaw and returns it.
-- @param y The yaw
-- @return The modified angle
function ang_methods:setY(y)
	self[2] = y
	return self
end

--- Set's the angle's roll and returns it.
-- @param r The roll
-- @return The modified angle
function ang_methods:setR(r)
	self[3] = r
	return self
end
