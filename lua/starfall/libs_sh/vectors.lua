SF.Vectors = {}

--- Vector type
-- @shared
local vec_methods, vec_metamethods = SF.Typedef("Vector")

local function wrap(tbl)
	return setmetatable(tbl, vec_metamethods)
end

local function unwrap(obj)
	return Vector(obj[1], obj[2], obj[3])
end

local function vwrap(vec)
	return wrap({ vec[1], vec[2], vec[3] })
end

SF.AddObjectWrapper(debug.getregistry().Vector, vec_metamethods, vwrap)
SF.AddObjectUnwrapper(vec_metamethods, unwrap)

SF.Libraries.AddHook("postload", function()
	SF.DefaultEnvironment.Vector = function (x, y, z)
		x = x or 0
		return wrap({ x, y or x, z or (y and 0 or x) })
	end
end)

SF.Vectors.Wrap = vwrap
SF.Vectors.Unwrap = unwrap
SF.Vectors.Methods = vec_methods
SF.Vectors.Metatable = vec_metamethods

local dgetmeta = debug.getmetatable

-- Lookup table.
-- Index 1->3 have associative xyz for use in __index. Saves lots of checks
-- String based indexing returns string, just a pass through.
local xyz = { x = 1, y = 2, z = 3 }

--- __newindex metamethod
function vec_metamethods.__newindex (t, k, v)
	if xyz[k] then
		rawset(t, xyz[k], v)
	else
		rawset(t, k, v)
	end
end

local _p = vec_metamethods.__methods

--- __index metamethod
function vec_metamethods.__index (t, k)
	if xyz[k] then
		return rawget(t, xyz[k])
	else
		return _p[k]
	end
end

local table_concat = table.concat

--- tostring metamethod
-- @return string representing the vector.
function vec_metamethods.__tostring (a)
	return table_concat(a, ' ', 1, 3)
end

--- multiplication metamethod
-- @param lhs Left side of equation
-- @param rhs Right side of equation
-- @return Scaled vector.
function vec_metamethods.__mul (a, b)
	if dgetmeta(a) == vec_metamethods then
		if dgetmeta(b) == vec_metamethods then
			return wrap({ a[1] * b[1], a[2] * b[2], a[3] * b[3] })
		end

		SF.CheckLuaType(b, TYPE_NUMBER)
		return wrap({ a[1] * b, a[2] * b, a[3] * b })
	else
		SF.CheckLuaType(a, TYPE_NUMBER)
		return wrap({ b[1] * a, b[2] * a, b[3] * a })
	end
end

--- division metamethod
-- @param b Scalar or vector to divide the scalar or vector by
-- @return Scaled vector.
function vec_metamethods.__div (a, b)
	if dgetmeta(a) == vec_metamethods then
		if dgetmeta(b) == vec_metamethods then
			return wrap({ a[1] / b[1], a[2] / b[2], a[3] / b[3] })
		else
			SF.CheckLuaType(b, TYPE_NUMBER)
			return wrap({ a[1] / b, a[2] / b, a[3] / b })
		end
	else
		SF.CheckLuaType(a, TYPE_NUMBER)
		return wrap({ a / b[1], a / b[2], a / b[3] })
	end
end

--- add metamethod
-- @param v Vector to add
-- @return Resultant vector after addition operation.
function vec_metamethods.__add (a, b)
	SF.CheckType(a, vec_metamethods)
	SF.CheckType(b, vec_metamethods)

	return wrap({ a[1] + b[1], a[2] + b[2], a[3] + b[3] })
end

--- sub metamethod
-- @param v Vector to subtract
-- @return Resultant vector after subtraction operation.
function vec_metamethods.__sub (a, b)
	SF.CheckType(a, vec_metamethods)
	SF.CheckType(b, vec_metamethods)

	return wrap({ a[1]-b[1], a[2]-b[2], a[3]-b[3] })
end

--- unary minus metamethod
-- @return negated vector.
function vec_metamethods.__unm (a)
	SF.CheckType(a, vec_metamethods)
	return wrap({ -a[1], -a[2], -a[3] })
end

--- equivalence metamethod
-- @return bool if both sides are equal.
function vec_metamethods.__eq (a, b)
	return a[1]==b[1] and a[2]==b[2] and a[3]==b[3]
end

--- Add vector - Modifies self.
-- @param v Vector to add
-- @return nil
function vec_methods:add (v)
	SF.CheckType(v, vec_metamethods)

	self[1] = self[1] + v[1]
	self[2] = self[2] + v[2]
	self[3] = self[3] + v[3]
end

--- Get the vector's angle.
-- @return Angle
function vec_methods:getAngle ()
	return SF.WrapObject(unwrap(self):Angle())
end

--- Returns the Angle between two vectors.
-- @param v Second Vector
-- @return Angle
function vec_methods:getAngleEx (v)
	SF.CheckType(v, vec_metamethods)

	return SF.WrapObject(unwrap(self):AngleEx(unwrap(v)))
end

--- Calculates the cross product of the 2 vectors, creates a unique perpendicular vector to both input vectors.
-- @param v Second Vector
-- @return Vector
function vec_methods:cross (v)
	SF.CheckType(v, vec_metamethods)

	return wrap({ self[2] * v[3] - self[3] * v[2], self[3] * v[1] - self[1] * v[3], self[1] * v[2] - self[2] * v[1] })
end

local math_sqrt = math.sqrt

--- Returns the pythagorean distance between the vector and the other vector.
-- @param v Second Vector
-- @return Number
function vec_methods:getDistance (v)
	SF.CheckType(v, vec_metamethods)

	return math_sqrt((v[1]-self[1])^2 + (v[2]-self[2])^2 + (v[3]-self[3])^2)
end

--- Returns the squared distance of 2 vectors, this is faster Vector:getDistance as calculating the square root is an expensive process.
-- @param v Second Vector
-- @return Number
function vec_methods:getDistanceSqr (v)
	SF.CheckType(v, vec_metamethods)

	return ((v[1]-self[1])^2 + (v[2]-self[2])^2 + (v[3]-self[3])^2)
end

--- Dot product is the cosine of the angle between both vectors multiplied by their lengths. A.B = ||A||||B||cosA.
-- @param v Second Vector
-- @return Number
function vec_methods:dot (v)
	SF.CheckType(v, vec_metamethods)

	return (self[1] * v[1] + self[2] * v[2] + self[3] * v[3])
end

--- Returns a new vector with the same direction by length of 1.
-- @return Vector Normalised
function vec_methods:getNormalized ()
	local len = math_sqrt(self[1]^2 + self[2]^2 + self[3]^2)

	return wrap({ self[1] / len, self[2] / len, self[3] / len })
end

--- Is this vector and v equal within tolerance t.
-- @param v Second Vector
-- @param t Tolerance number.
-- @return bool True/False.
function vec_methods:isEqualTol (v, t)
	SF.CheckType(v, vec_metamethods)
	SF.CheckLuaType(t, TYPE_NUMBER)

	return unwrap(self):IsEqualTol(unwrap(v), t)
end

--- Are all fields zero.
-- @return bool True/False
function vec_methods:isZero ()
	if self[1] ~= 0 then return false
	elseif self[2] ~= 0 then return false
	elseif self[3] ~= 0 then return false
	end

	return true
end

--- Get the vector's Length.
-- @return number Length.
function vec_methods:getLength ()
	return math_sqrt(self[1]^2 + self[2]^2 + self[3]^2)
end

--- Get the vector's length squared ( Saves computation by skipping the square root ).
-- @return number length squared.
function vec_methods:getLengthSqr ()
	return (self[1]^2 + self[2]^2 + self[3]^2)
end

--- Returns the length of the vector in two dimensions, without the Z axis.
-- @return number length
function vec_methods:getLength2D ()
	return math_sqrt(self[1]^2 + self[2]^2)
end

--- Returns the length squared of the vector in two dimensions, without the Z axis. ( Saves computation by skipping the square root )
-- @return number length squared.
function vec_methods:getLength2DSqr ()
	return (self[1]^2 + self[2]^2)
end

--- Scalar Multiplication of the vector. Self-Modifies.
-- @param n Scalar to multiply with.
-- @return nil
function vec_methods:mul (n)
	SF.CheckLuaType(n, TYPE_NUMBER)

	self[1] = self[1] * n
	self[2] = self[2] * n
	self[3] = self[3] * n
end

--- "Scalar Division" of the vector. Self-Modifies.
-- @param n Scalar to divide by.
-- @return nil
function vec_methods:div (n)
	SF.CheckLuaType(n, TYPE_NUMBER)

	self[1] = self[1] / n
	self[2] = self[2] / n
	self[3] = self[3] / n
end

--- Multiply self with a Vector. Self-Modifies. ( convenience function )
-- @param v Vector to multiply with
function vec_methods:vmul (v)
	SF.CheckType(v, vec_metamethods)

	self[1] = self[1] * v[1]
	self[2] = self[2] * v[2]
	self[3] = self[3] * v[3]
end

--- Divide self by a Vector. Self-Modifies. ( convenience function )
-- @param v Vector to divide by
function vec_methods:vdiv (v)
	SF.CheckType(v, vec_metamethods)

	self[1] = self[1] / v[1]
	self[2] = self[2] / v[2]
	self[3] = self[3] / v[3]
end

--- Set's all vector fields to 0.
-- @return nil
function vec_methods:setZero ()
	self[1] = 0
	self[2] = 0
	self[3] = 0
end

--- Set's the vector's x coordinate and returns it.
-- @param x The x coordinate
-- @return The modified vector
function vec_methods:setX(x)
	self[1] = x
	return self
end

--- Set's the vector's y coordinate and returns it.
-- @param y The y coordinate
-- @return The modified vector
function vec_methods:setY(y)
	self[2] = y
	return self
end

--- Set's the vector's z coordinate and returns it.
-- @param z The z coordinate
-- @return The modified vector
function vec_methods:setZ(z)
	self[3] = z
	return self
end

--- Normalise the vector, same direction, length 1. Self-Modifies.
-- @return nil
function vec_methods:normalize ()
	local len = math_sqrt(self[1]^2 + self[2]^2 + self[3]^2)

	self[1] = self[1] / len
	self[2] = self[2] / len
	self[3] = self[3] / len
end

--- Rotate the vector by Angle b. Self-Modifies.
-- @param b Angle to rotate by.
-- @return nil.
function vec_methods:rotate (b)
	SF.CheckType(b, SF.Types["Angle"])

	local vec = unwrap(self)
	vec:Rotate(SF.UnwrapObject(b))

	self[1] = vec.x
	self[2] = vec.y
	self[3] = vec.z
end

--- Return rotated vector by an axis
-- @param axis Axis the rotate around
-- @param degrees Angle to rotate by in degrees or nil if radians.
-- @param radians Angle to rotate by in radians or nil if degrees.
-- @return Rotated vector
function vec_methods:rotateAroundAxis(axis, degrees, radians)
	SF.CheckType(axis, vec_metamethods)

	if degrees then
		SF.CheckLuaType(degrees, TYPE_NUMBER)
		radians = math.rad(degrees)
	else
		SF.CheckLuaType(radians, TYPE_NUMBER)
	end

	local ca, sa = math.cos(radians), math.sin(radians)
	local x, y, z, x2, y2, z2 = axis[1], axis[2], axis[3], self[1], self[2], self[3]
	local length = (x * x + y * y + z * z)^0.5
	x, y, z = x / length, y / length, z / length

	return wrap({ (ca + (x^2) * (1-ca)) * x2 + (x * y * (1-ca) - z * sa) * y2 + (x * z * (1-ca) + y * sa) * z2,
			(y * x * (1-ca) + z * sa) * x2 + (ca + (y^2) * (1-ca)) * y2 + (y * z * (1-ca) - x * sa) * z2,
			(z * x * (1-ca) - y * sa) * x2 + (z * y * (1-ca) + x * sa) * y2 + (ca + (z^2) * (1-ca)) * z2 })
end

--- Copies the values from the second vector to the first vector. Self-Modifies.
-- @param v Second Vector
-- @return nil
function vec_methods:set (v)
	SF.CheckType(v, vec_metamethods)

	self[1] = v[1]
	self[2] = v[2]
	self[3] = v[3]
end

--- Subtract v from this Vector. Self-Modifies.
-- @param v Second Vector.
-- @return nil
function vec_methods:sub (v)
	SF.CheckType(v, vec_metamethods)

	self[1] = self[1] - v[1]
	self[2] = self[2] - v[2]
	self[3] = self[3] - v[3]
end

--- Translates the vectors position into 2D user screen coordinates.
-- @return A table {x=screenx,y=screeny,visible=visible}
function vec_methods:toScreen ()
	return unwrap(self):ToScreen()
end

--- Returns whenever the given vector is in a box created by the 2 other vectors.
-- @param v1 Vector used to define AABox
-- @param v2 Second Vector to define AABox
-- @return bool True/False.
function vec_methods:withinAABox (v1, v2)
	SF.CheckType(v1, vec_metamethods)
	SF.CheckType(v2, vec_metamethods)

	if self[1] < v1[1] or self[1] > v2[1] then return false end
	if self[2] < v1[2] or self[2] > v2[2] then return false end
	if self[3] < v1[3] or self[3] > v2[3] then return false end

	return true
end
