-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local dgetmeta = debug.getmetatable


--- Vector type
-- @name Vector
-- @class type
-- @libtbl vec_methods
-- @libtbl vec_meta
SF.RegisterType("Vector", nil, nil, debug.getregistry().Vector, nil, function(checktype, vec_meta)
	return function(vec)
		return setmetatable({ vec:Unpack() }, vec_meta)
	end,
	function(obj)
		checktype(obj, vec_meta, 2)
		return Vector(obj[1], obj[2], obj[3])
	end
end)



return function(instance)

local checktype = instance.CheckType
local vec_methods, vec_meta, vwrap, unwrap = instance.Types.Vector.Methods, instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local function wrap(tbl)
	return setmetatable(tbl, vec_meta)
end

--- Creates a Vector struct.
-- @name builtins_library.Vector
-- @class function
-- @param x - X
-- @param y - Y
-- @param z - Z
-- @return Vector
function instance.env.Vector(x, y, z)
	if x then checkluatype(x, TYPE_NUMBER) else x = 0 end
	if z then checkluatype(z, TYPE_NUMBER) else z = (y and 0 or x) end
	if y then checkluatype(y, TYPE_NUMBER) else y = x end
	return wrap({ x, y, z })
end


-- Lookup table.
-- Index 1->3 have associative xyz for use in __index. Saves lots of checks
-- String based indexing returns string, just a pass through.
local xyz = { x = 1, y = 2, z = 3 }

--- __newindex metamethod
function vec_meta.__newindex(t, k, v)
	if xyz[k] then
		rawset(t, xyz[k], v)

	elseif (#k == 2 and xyz[k[1]] and xyz[k[2]])  then
		checktype(v, vec_meta)

		rawset(t, xyz[k[1]], rawget(v, 1))
		rawset(t, xyz[k[2]], rawget(v, 2))
	elseif (#k == 3 and xyz[k[1]] and xyz[k[2]] and xyz[k[3]]) then
		checktype(v, vec_meta)

		rawset(t, xyz[k[1]], rawget(v, 1))
		rawset(t, xyz[k[2]], rawget(v, 2))
		rawset(t, xyz[k[3]], rawget(v, 3))
	else
		rawset(t, k, v)
	end
end

local math_min = math.min

--- __index metamethod
-- Can be indexed with: 1, 2, 3, x, y, z, xx, xy, xz, xxx, xyz, zyx, etc.. 1,2,3 is most efficient.
function vec_meta.__index(t, k)
	local method = vec_methods[k]
	if method ~= nil then
		return method
	elseif xyz[k] then
		return rawget(t, xyz[k])
	else 
		-- Swizzle support
		local v = {0,0,0}
		for i = 1, math_min(#k,3)do
			local vk = xyz[k[i]]
			if vk then
				v[i] = rawget(t, vk)
			else
				return nil -- Not a swizzle
			end
		end
		return wrap(v)
	end
end

local table_concat = table.concat

--- tostring metamethod
-- @return string representing the vector.
function vec_meta.__tostring(a)
	return table_concat(a, ' ', 1, 3)
end

--- multiplication metamethod
-- @param lhs Left side of equation
-- @param rhs Right side of equation
-- @return Scaled vector.
function vec_meta.__mul(a, b)
	if isnumber(b) then
		return wrap({ a[1] * b, a[2] * b, a[3] * b })
	elseif isnumber(a) then
		return wrap({ b[1] * a, b[2] * a, b[3] * a })
	elseif dgetmeta(a) == vec_meta and dgetmeta(b) == vec_meta then
		return wrap({ a[1] * b[1], a[2] * b[2], a[3] * b[3] })
	elseif dgetmeta(a) == vec_meta then
		checkluatype(b, TYPE_NUMBER)
	else
		checkluatype(a, TYPE_NUMBER)
	end
end

--- division metamethod
-- @param b Scalar or vector to divide the scalar or vector by
-- @return Scaled vector.
function vec_meta.__div(a, b)
	if isnumber(b) then
		return wrap({ a[1] / b, a[2] / b, a[3] / b })
	elseif isnumber(a) then
		return wrap({ a / b[1], a / b[2], a / b[3] })
	elseif dgetmeta(a) == vec_meta and dgetmeta(b) == vec_meta then
		return wrap({ a[1] / b[1], a[2] / b[2], a[3] / b[3] })
	elseif dgetmeta(a) == vec_meta then
		checkluatype(b, TYPE_NUMBER)
	else
		checkluatype(a, TYPE_NUMBER)
	end
end

--- add metamethod
-- @param v Vector to add
-- @return Resultant vector after addition operation.
function vec_meta.__add(a, b)
	return wrap({ a[1] + b[1], a[2] + b[2], a[3] + b[3] })
end

--- sub metamethod
-- @param v Vector to subtract
-- @return Resultant vector after subtraction operation.
function vec_meta.__sub(a, b)
	return wrap({ a[1]-b[1], a[2]-b[2], a[3]-b[3] })
end

--- unary minus metamethod
-- @return negated vector.
function vec_meta.__unm(a)
	return wrap({ -a[1], -a[2], -a[3] })
end

--- equivalence metamethod
-- @return bool if both sides are equal.
function vec_meta.__eq(a, b)
	return a[1]==b[1] and a[2]==b[2] and a[3]==b[3]
end

--- Get the vector's angle.
-- @return Angle
function vec_methods:getAngle()
	return awrap(unwrap(self):Angle())
end

--- Returns the vector's euler angle with respect to the other vector as if it were the new vertical axis.
-- @param v Second Vector
-- @return Angle
function vec_methods:getAngleEx(v)
	return awrap(unwrap(self):AngleEx(unwrap(v)))
end

--- Calculates the cross product of the 2 vectors, creates a unique perpendicular vector to both input vectors.
-- @param v Second Vector
-- @return Vector
function vec_methods:cross(v)
	return wrap({ self[2] * v[3] - self[3] * v[2], self[3] * v[1] - self[1] * v[3], self[1] * v[2] - self[2] * v[1] })
end

local math_sqrt = math.sqrt

--- Returns the pythagorean distance between the vector and the other vector.
-- @param v Second Vector
-- @return Number
function vec_methods:getDistance(v)
	return math_sqrt((v[1]-self[1])^2 + (v[2]-self[2])^2 + (v[3]-self[3])^2)
end

--- Returns the squared distance of 2 vectors, this is faster Vector:getDistance as calculating the square root is an expensive process.
-- @param v Second Vector
-- @return Number
function vec_methods:getDistanceSqr(v)
	return ((v[1]-self[1])^2 + (v[2]-self[2])^2 + (v[3]-self[3])^2)
end

--- Dot product is the cosine of the angle between both vectors multiplied by their lengths. A.B = ||A||||B||cosA.
-- @param v Second Vector
-- @return Number
function vec_methods:dot(v)
	return (self[1] * v[1] + self[2] * v[2] + self[3] * v[3])
end

--- Returns a new vector with the same direction by length of 1.
-- @return Vector Normalised
function vec_methods:getNormalized()
	local len = math_sqrt(self[1]^2 + self[2]^2 + self[3]^2)

	return wrap({ self[1] / len, self[2] / len, self[3] / len })
end

--- Is this vector and v equal within tolerance t.
-- @param v Second Vector
-- @param t Tolerance number.
-- @return bool True/False.
function vec_methods:isEqualTol(v, t)
	checkluatype(t, TYPE_NUMBER)

	return unwrap(self):IsEqualTol(unwrap(v), t)
end

--- Are all fields zero.
-- @return bool True/False
function vec_methods:isZero()
	return self[1]==0 and self[2]==0 and self[3]==0
end

--- Get the vector's Length.
-- @return number Length.
function vec_methods:getLength()
	return math_sqrt(self[1]^2 + self[2]^2 + self[3]^2)
end

--- Get the vector's length squared ( Saves computation by skipping the square root ).
-- @return number length squared.
function vec_methods:getLengthSqr()
	return (self[1]^2 + self[2]^2 + self[3]^2)
end

--- Returns the length of the vector in two dimensions, without the Z axis.
-- @return number length
function vec_methods:getLength2D()
	return math_sqrt(self[1]^2 + self[2]^2)
end

--- Returns the length squared of the vector in two dimensions, without the Z axis. ( Saves computation by skipping the square root )
-- @return number length squared.
function vec_methods:getLength2DSqr()
	return (self[1]^2 + self[2]^2)
end

--- Add vector - Modifies self.
-- @param v Vector to add
-- @return nil
function vec_methods:add(v)
	self[1] = self[1] + v[1]
	self[2] = self[2] + v[2]
	self[3] = self[3] + v[3]
end

--- Subtract v from this Vector. Self-Modifies.
-- @param v Second Vector.
-- @return nil
function vec_methods:sub(v)
	self[1] = self[1] - v[1]
	self[2] = self[2] - v[2]
	self[3] = self[3] - v[3]
end

--- Scalar Multiplication of the vector. Self-Modifies.
-- @param n Scalar to multiply with.
-- @return nil
function vec_methods:mul(n)
	checkluatype(n, TYPE_NUMBER)

	self[1] = self[1] * n
	self[2] = self[2] * n
	self[3] = self[3] * n
end

--- "Scalar Division" of the vector. Self-Modifies.
-- @param n Scalar to divide by.
-- @return nil
function vec_methods:div(n)
	checkluatype(n, TYPE_NUMBER)

	self[1] = self[1] / n
	self[2] = self[2] / n
	self[3] = self[3] / n
end

--- Multiply self with a Vector. Self-Modifies. ( convenience function )
-- @param v Vector to multiply with
function vec_methods:vmul(v)
	self[1] = self[1] * v[1]
	self[2] = self[2] * v[2]
	self[3] = self[3] * v[3]
end

--- Divide self by a Vector. Self-Modifies. ( convenience function )
-- @param v Vector to divide by
function vec_methods:vdiv(v)
	self[1] = self[1] / v[1]
	self[2] = self[2] / v[2]
	self[3] = self[3] / v[3]
end

--- Set's all vector fields to 0.
-- @return nil
function vec_methods:setZero()
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
function vec_methods:normalize()
	local len = math_sqrt(self[1]^2 + self[2]^2 + self[3]^2)

	self[1] = self[1] / len
	self[2] = self[2] / len
	self[3] = self[3] / len
end

--- Rotate the vector by Angle b. Self-Modifies.
-- @param b Angle to rotate by.
-- @return nil.
function vec_methods:rotate(b)
	local vec = unwrap(self)
	vec:Rotate(aunwrap(b))

	self[1] = vec.x
	self[2] = vec.y
	self[3] = vec.z
end

--- Returns Rotated vector by Angle b
-- @param b Angle to rotate by.
-- @return Rotated Vector
function vec_methods:getRotated(b)
	local vec = unwrap(self)
	vec:Rotate(aunwrap(b))

	return wrap({ vec.x, vec.y, vec.z })
end

--- Returns an arbitrary orthogonal basis from the direction of the vector. Input must be a normalized vector
-- @return Basis 1
-- @return Basis 2
function vec_methods:getBasis()
	if self[3] < -0.9999999 then
		return wrap({0.0, -1.0, 0.0}), wrap({-1.0, 0.0, 0.0})
	end
	local a = 1.0/(1.0 + self[3])
	local b = -self[1]*self[2]*a

	return wrap({ 1.0 - self[1]*self[1]*a, b, -self[1] }), wrap({ b, 1.0 - self[2]*self[2]*a, -self[2] })
end

--- Return rotated vector by an axis
-- @param axis Axis the rotate around
-- @param degrees Angle to rotate by in degrees or nil if radians.
-- @param radians Angle to rotate by in radians or nil if degrees.
-- @return Rotated vector
function vec_methods:rotateAroundAxis(axis, degrees, radians)
	if degrees then
		checkluatype(degrees, TYPE_NUMBER)
		radians = math.rad(degrees)
	else
		checkluatype(radians, TYPE_NUMBER)
	end

	local ca, sa = math.cos(radians), math.sin(radians)
	local x, y, z, x2, y2, z2 = axis[1], axis[2], axis[3], self[1], self[2], self[3]
	local length = (x * x + y * y + z * z)^0.5
	x, y, z = x / length, y / length, z / length

	return wrap({ (ca + (x^2) * (1-ca)) * x2 + (x * y * (1-ca) - z * sa) * y2 + (x * z * (1-ca) + y * sa) * z2,
			(y * x * (1-ca) + z * sa) * x2 + (ca + (y^2) * (1-ca)) * y2 + (y * z * (1-ca) - x * sa) * z2,
			(z * x * (1-ca) - y * sa) * x2 + (z * y * (1-ca) + x * sa) * y2 + (ca + (z^2) * (1-ca)) * z2 })
end

--- Round the vector values. Self-Modifies.
-- @param idp (Default 0) The integer decimal place to round to. 
-- @return nil
function vec_methods:round(idp)
	self[1] = math.Round(self[1], idp)
	self[2] = math.Round(self[2], idp)
	self[3] = math.Round(self[3], idp)
end

--- Copies x,y,z from a vector and returns a new vector
-- @return The copy of the vector
function vec_methods:clone()
	return wrap({ self[1], self[2], self[3] })
end

--- Copies the values from the second vector to the first vector. Self-Modifies.
-- @param v Second Vector
-- @return nil
function vec_methods:set(v)
	self[1] = v[1]
	self[2] = v[2]
	self[3] = v[3]
end

--- Translates the vectors position into 2D user screen coordinates.
-- @return A table {x=screenx,y=screeny,visible=visible}
function vec_methods:toScreen()
	return unwrap(self):ToScreen()
end

--- Returns whenever the given vector is in a box created by the 2 other vectors.
-- @param v1 Vector used to define AABox
-- @param v2 Second Vector to define AABox
-- @return bool True/False.
function vec_methods:withinAABox(v1, v2)
	if self[1] < math.min(v1[1], v2[1]) or self[1] > math.max(v1[1], v2[1]) then return false end
	if self[2] < math.min(v1[2], v2[2]) or self[2] > math.max(v1[2], v2[2]) then return false end
	if self[3] < math.min(v1[3], v2[3]) or self[3] > math.max(v1[3], v2[3]) then return false end

	return true
end

if SERVER then
	--- Returns whether the vector is in world
	-- @server
	-- @return bool True/False.
	function vec_methods:isInWorld()
		return util.IsInWorld(unwrap(self))
	end
end

end
