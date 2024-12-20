-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local dgetmeta = debug.getmetatable
local Unpack = FindMetaTable("Vector").Unpack
local SetUnpacked = FindMetaTable("Vector").SetUnpacked

--- Vector type
-- @name Vector
-- @class type
-- @field x The x value of the vector. Can also be indexed with [1]
-- @field y The y value of the vector. Can also be indexed with [2]
-- @field z The z value of the vector. Can also be indexed with [3]
-- @libtbl vec_methods
-- @libtbl vec_meta
SF.RegisterType("Vector", nil, nil, FindMetaTable("Vector"), nil, function(checktype, vec_meta)
	return function(vec)
		return setmetatable({ Unpack(vec) }, vec_meta)
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
local col_meta, cwrap, cunwrap = instance.Types.Color, instance.Types.Color.Wrap, instance.Types.Color.Unwrap
local quat_meta, qwrap = instance.Types.Quaternion, instance.Types.Quaternion.Wrap
local function wrap(tbl)
	return setmetatable(tbl, vec_meta)
end

local quatMul
instance:AddHook("initialize", function()
	quatMul = instance.Types.Quaternion.QuaternionMultiply
end)

local function QuickUnwrapper()
	local Vec = Vector()
	return function(v) SetUnpacked(Vec, v[1], v[2], v[3]) return Vec end
end
vec_meta.QuickUnwrap1 = QuickUnwrapper()
vec_meta.QuickUnwrap2 = QuickUnwrapper()
vec_meta.QuickUnwrap3 = QuickUnwrapper()
vec_meta.QuickUnwrap4 = QuickUnwrapper()


--- Creates a Vector struct.
-- @name builtins_library.Vector
-- @class function
-- @param number? x X value
-- @param number? y Y value
-- @param number? z Z value
-- @return Vector Vector
function instance.env.Vector(x, y, z)
	if x~=nil then checkluatype(x, TYPE_NUMBER) else x = 0 end
	if z~=nil then checkluatype(z, TYPE_NUMBER) else z = (y and 0 or x) end
	if y~=nil then checkluatype(y, TYPE_NUMBER) else y = x end
	return wrap({ x, y, z })
end


-- Lookup table.
-- Index 1->3 have associative xyz for use in __index. Saves lots of checks
-- String based indexing returns string, just a pass through.
local xyz = { x = 1, y = 2, z = 3 }

--- Sets a value at a key in the vector
-- @param Vector Vec
-- @param number|string Key
-- @param number Value
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

--- Gets a value at a key in the vector
-- Can be indexed with: 1, 2, 3, x, y, z, xx, xy, xz, xxx, xyz, zyx, etc.. 1,2,3 is most efficient.
-- @param number|string Key to get the value at
-- @return number The value at the index
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

--- Turns a vector into a string.
-- @return string String representation of the vector.
function vec_meta.__tostring(a)
	return table_concat(a, ' ', 1, 3)
end

--- Multiplication metamethod
-- @param number|Vector a Number or Vector multiplicand.
-- @param number|Vector b Number or Vector multiplier.
-- @return Vector Multiplied vector.
function vec_meta.__mul(a, b)
	if isnumber(b) then
		return wrap({ a[1] * b, a[2] * b, a[3] * b })
	elseif isnumber(a) then
		return wrap({ b[1] * a, b[2] * a, b[3] * a })
	elseif dgetmeta(a) == vec_meta and dgetmeta(b) == vec_meta then
		return wrap({ a[1] * b[1], a[2] * b[2], a[3] * b[3] })
	elseif dgetmeta(a) == vec_meta and dgetmeta(b) == quat_meta then -- Vector * Quaternion
		local quat_vec = { 0, a[1], a[2], a[3] }
		local conj = { b[1], -b[2], -b[3], -b[4] }
		return wrap(quatMul(quatMul(b, quat_vec), conj))
	elseif dgetmeta(a) == vec_meta then
		checkluatype(b, TYPE_NUMBER)
	else
		checkluatype(a, TYPE_NUMBER)
	end
end

--- Division metamethod
-- @param number|Vector v1 Number or Vector dividend.
-- @param number|Vector v2 Number or Vector divisor.
-- @return Vector Scaled vector.
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

--- Addition metamethod
-- @param Vector v1 Initial vector.
-- @param Vector v2 Vector to add to the first.
-- @return Vector Resultant vector after addition operation.
function vec_meta.__add(a, b)
	return wrap({ a[1] + b[1], a[2] + b[2], a[3] + b[3] })
end

--- Subtraction metamethod
-- @param Vector v1 Initial Vector
-- @param Vector v2 Vector to subtract
-- @return Vector Resultant vector after subtraction operation.
function vec_meta.__sub(a, b)
	return wrap({ a[1]-b[1], a[2]-b[2], a[3]-b[3] })
end

--- Unary Minus metamethod (Negative)
-- @return Vector Negative vector.
function vec_meta.__unm(a)
	return wrap({ -a[1], -a[2], -a[3] })
end

--- Equivalence metamethod
-- @param Vector v1 Initial vector.
-- @param Vector v2 Vector to check against.
-- @return boolean Whether both sides are equal.
function vec_meta.__eq(a, b)
	return a[1]==b[1] and a[2]==b[2] and a[3]==b[3]
end

local math_asin, math_atan2, math_sqrt = math.asin, math.atan2, math.sqrt
local rad2deg = 180 / math.pi

--- Get the vector's angle.
-- @return Angle Angle representing the vector
function vec_methods:getAngle()
	local n = math_sqrt(self[1]^2 + self[2]^2 + self[3]^2)
	if n == 0 then return setmetatable({0, 0, 0}, ang_meta) end

	return setmetatable({
		rad2deg * math_asin(-self[3] / n) % 360,
		rad2deg * math_atan2(self[2], self[1]) % 360,
		0
	}, ang_meta)
end

--- Returns the vector's euler angle with respect to the other vector as if it were the new vertical axis.
-- @param Vector v Second Vector
-- @return Angle Angle
function vec_methods:getAngleEx(v)
	return awrap(unwrap(self):AngleEx(unwrap(v)))
end

--- Calculates the cross product of the 2 vectors, creates a unique perpendicular vector to both input vectors.
-- @param Vector v Second Vector
-- @return Vector Vector from cross product
function vec_methods:cross(v)
	return wrap({ self[2] * v[3] - self[3] * v[2], self[3] * v[1] - self[1] * v[3], self[1] * v[2] - self[2] * v[1] })
end

--- Returns the pythagorean distance between the vector and the other vector.
-- @param Vector v Second Vector
-- @return number Vector distance from v
function vec_methods:getDistance(v)
	return math_sqrt((v[1]-self[1])^2 + (v[2]-self[2])^2 + (v[3]-self[3])^2)
end

--- Returns the squared distance of 2 vectors, this is faster Vector:getDistance as calculating the square root is an expensive process.
-- @param Vector v Second Vector
-- @return number Vector distance from v
function vec_methods:getDistanceSqr(v)
	return ((v[1]-self[1])^2 + (v[2]-self[2])^2 + (v[3]-self[3])^2)
end

--- Dot product is the cosine of the angle between both vectors multiplied by their lengths. A.B = ||A||||B||cosA.
-- @param Vector v Second Vector
-- @return number Dot product result between the two vectors
function vec_methods:dot(v)
	return (self[1] * v[1] + self[2] * v[2] + self[3] * v[3])
end

--- Returns a new vector with the same direction by length of 1.
-- @return Vector Normalized vector
function vec_methods:getNormalized()
	local len = math_sqrt(self[1]^2 + self[2]^2 + self[3]^2)

	return wrap({ self[1] / len, self[2] / len, self[3] / len })
end

--- Is this vector and v equal within tolerance t.
-- @param Vector v Second Vector
-- @param number t Tolerance number.
-- @return boolean Whether the vector is equal to v within the tolerance.
function vec_methods:isEqualTol(v, t)
	checkluatype(t, TYPE_NUMBER)

	return unwrap(self):IsEqualTol(unwrap(v), t)
end

--- Returns whether all fields are zero
-- @return boolean Whether all fields are zero
function vec_methods:isZero()
	return self[1]==0 and self[2]==0 and self[3]==0
end

--- Get the vector's Length.
-- @return number Length of the vector.
function vec_methods:getLength()
	return math_sqrt(self[1]^2 + self[2]^2 + self[3]^2)
end

--- Get the vector's length squared ( Saves computation by skipping the square root ).
-- @return number length squared.
function vec_methods:getLengthSqr()
	return (self[1]^2 + self[2]^2 + self[3]^2)
end

--- Returns the length of the vector in two dimensions, without the Z axis.
-- @return number Vector length
function vec_methods:getLength2D()
	return math_sqrt(self[1]^2 + self[2]^2)
end

--- Returns the length squared of the vector in two dimensions, without the Z axis. ( Saves computation by skipping the square root )
-- @return number Length squared.
function vec_methods:getLength2DSqr()
	return (self[1]^2 + self[2]^2)
end

--- Add v to this vector
-- Self-Modifies. Does not return anything
-- @param Vector v Vector to add
function vec_methods:add(v)
	self[1] = self[1] + v[1]
	self[2] = self[2] + v[2]
	self[3] = self[3] + v[3]
end

--- Subtract v from this Vector.
-- Self-Modifies. Does not return anything
-- @param Vector v Vector to subtract.
function vec_methods:sub(v)
	self[1] = self[1] - v[1]
	self[2] = self[2] - v[2]
	self[3] = self[3] - v[3]
end

--- Scalar Multiplication of the vector.
-- Self-Modifies. Does not return anything
-- @param number n Scalar to multiply with.
function vec_methods:mul(n)
	checkluatype(n, TYPE_NUMBER)

	self[1] = self[1] * n
	self[2] = self[2] * n
	self[3] = self[3] * n
end

--- "Scalar Division" of the vector.
-- Self-Modifies. Does not return anything
-- @param number n Scalar to divide by.
function vec_methods:div(n)
	checkluatype(n, TYPE_NUMBER)

	self[1] = self[1] / n
	self[2] = self[2] / n
	self[3] = self[3] / n
end

--- Multiply self with a Vector.
-- Self-Modifies. Does not return anything
-- @param Vector v Vector to multiply with
function vec_methods:vmul(v)
	self[1] = self[1] * v[1]
	self[2] = self[2] * v[2]
	self[3] = self[3] * v[3]
end

--- Divide self by a Vector.
-- Self-Modifies. Does not return anything
-- @param Vector v Vector to divide by
function vec_methods:vdiv(v)
	self[1] = self[1] / v[1]
	self[2] = self[2] / v[2]
	self[3] = self[3] / v[3]
end

--- Set's all vector fields to 0.
-- Self-Modifies. Does not return anything
function vec_methods:setZero()
	self[1] = 0
	self[2] = 0
	self[3] = 0
end

--- Set's the vector's x coordinate and returns the vector after modifying.
-- @param number x The x coordinate
-- @return Vector Modified vector after setting X.
function vec_methods:setX(x)
	self[1] = x
	return self
end

--- Set's the vector's y coordinate and returns the vector after modifying.
-- @param number y The y coordinate
-- @return Vector Modified vector after setting Y.
function vec_methods:setY(y)
	self[2] = y
	return self
end

--- Set's the vector's z coordinate and returns the vector after modifying.
-- @param number z The z coordinate
-- @return Vector Modified vector after setting Z.
function vec_methods:setZ(z)
	self[3] = z
	return self
end

--- Normalise the vector, same direction, length 1.
-- Self-Modifies. Does not return anything
function vec_methods:normalize()
	local len = math_sqrt(self[1]^2 + self[2]^2 + self[3]^2)

	self[1] = self[1] / len
	self[2] = self[2] / len
	self[3] = self[3] / len
end

local math_sin, math_cos = math.sin, math.cos
local deg2rad = math.pi/180

--- Rotate the vector by Angle b.
-- Self-Modifies. Does not return anything
-- @param Angle b Angle to rotate by.
function vec_methods:rotate(b)
	checktype(b, ang_meta)
	local p, y, r = b[1] * deg2rad, b[2] * deg2rad, b[3] * deg2rad
	local ysin, ycos, psin, pcos, rsin, rcos = math_sin(y), math_cos(y), math_sin(p), math_cos(p), math_sin(r), math_cos(r)
	local psin_rsin, psin_rcos = psin*rsin, psin*rcos
	local x, y, z = self[1], self[2], self[3]

	self[1] = x * (ycos * pcos) + y * (ycos * psin_rsin - ysin * rcos) + z * (ycos * psin_rcos + ysin * rsin)
	self[2] = x * (ysin * pcos) + y * (ysin * psin_rsin + ycos * rcos) + z * (ysin * psin_rcos - ycos * rsin)
	self[3] = x * (-psin) + y * (pcos * rsin) + z * (pcos * rcos)
end

--- Returns Rotated vector by Angle b
-- @param Angle b Angle to rotate by.
-- @return Vector Rotated Vector
function vec_methods:getRotated(b)
	checktype(b, ang_meta)
	local v = wrap({self[1], self[2], self[3]})
	vec_methods.rotate(v, b)
	return v
end

--- Returns an arbitrary orthogonal basis from the direction of the vector. Input must be a normalized vector
-- @return number Basis 1
-- @return number Basis 2
function vec_methods:getBasis()
	if self[3] < -0.9999999 then
		return wrap({0.0, -1.0, 0.0}), wrap({-1.0, 0.0, 0.0})
	end
	local a = 1.0/(1.0 + self[3])
	local b = -self[1]*self[2]*a

	return wrap({ 1.0 - self[1]*self[1]*a, b, -self[1] }), wrap({ b, 1.0 - self[2]*self[2]*a, -self[2] })
end

--- Return rotated vector by an axis
-- @param Vector axis Axis the rotate around
-- @param number? degrees Angle to rotate by in degrees or nil if radians.
-- @param number? radians Angle to rotate by in radians or nil if degrees.
-- @return Vector Rotated vector
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

--- Round the vector values.
-- Self-Modifies. Does not return anything
-- @param number idp (Default 0) The integer decimal place to round to.
function vec_methods:round(idp)
	self[1] = math.Round(self[1], idp)
	self[2] = math.Round(self[2], idp)
	self[3] = math.Round(self[3], idp)
end

--- Copies x,y,z from a vector and returns a new vector
-- @return Vector The copy of the vector
function vec_methods:clone()
	return wrap({ self[1], self[2], self[3] })
end

--- Copies the values from the second vector to the first vector.
-- Self-Modifies. Does not return anything
-- @param Vector v Second Vector
function vec_methods:set(v)
	self[1] = v[1]
	self[2] = v[2]
	self[3] = v[3]
end

--- Converts vector to color
-- @return Color New color object
function vec_methods:getColor()
	return cwrap(unwrap(self):ToColor())
end

--- Returns whenever the given vector is in a box created by the 2 other vectors.
-- @param Vector v1 Vector used to define AABox
-- @param Vector v2 Second Vector to define AABox
-- @return boolean True/False.
function vec_methods:withinAABox(v1, v2)
	if self[1] < math.min(v1[1], v2[1]) or self[1] > math.max(v1[1], v2[1]) then return false end
	if self[2] < math.min(v1[2], v2[2]) or self[2] > math.max(v1[2], v2[2]) then return false end
	if self[3] < math.min(v1[3], v2[3]) or self[3] > math.max(v1[3], v2[3]) then return false end

	return true
end

if SERVER then
	--- Returns whether the vector is in world
	-- @server
	-- @return boolean True/False.
	function vec_methods:isInWorld()
		return util.IsInWorld(unwrap(self))
	end
else
	--- Translates the vectors position into 2D user screen coordinates.
	-- @client
	-- @return table A table {x=screenx,y=screeny,visible=visible}
	function vec_methods:toScreen()
		return unwrap(self):ToScreen()
	end
end

end
