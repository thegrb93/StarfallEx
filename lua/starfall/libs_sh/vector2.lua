-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local dgetmeta = debug.getmetatable

--- Vector2 type
-- @name Vector2
-- @class type
-- @libtbl vec2_methods
-- @libtbl vec2_meta
SF.RegisterType("Vector2", nil, nil, debug.getregistry().Vector, nil, function(checktype, vec2_meta)
	return function(vec)
		return setmetatable({ vec[1], vec[2] }, vec2_meta)
	end,
	function(obj)
		checktype(obj, vec2_meta, 2)
		return Vector(obj[1], obj[2], 0)
	end
end)

return function(instance)
	local checktype = instance.CheckType
	local vec2_methods, vec2_meta, unwrap = instance.Types.Vector2.Methods, instance.Types.Vector2, instance.Types.Vector2.Unwrap
	local function wrap(tbl)
		return setmetatable(tbl, vec2_meta)
	end

	--- Creates a Vector2 struct
	-- @name builtins_library.Vector2
	-- @class function
	-- @param number x X value
	-- @param number y Y value
	-- @return Vector2 Vector2
	function instance.env.Vector2(x, y)
		if x ~= nil then checkluatype(x, TYPE_NUMBER) else x = 0 end
		if y ~= nil then checkluatype(y, TYPE_NUMBER) else y = x end
		return wrap({ x, y })
	end

	-- Lookup table.
	-- Index 1->2 have associative xy for use in __index. Saves lots of checks
	-- String based indexing returns string, just a pass through
	local xy = { x = 1, y = 2 }

	--- Sets a value at a key in the vector
	-- @param number|string Key
	-- @param number Value
	function vec2_meta.__newindex(t, k, v)
		if xy[k] then
			rawset(t, xy[k], v)
		elseif (#k == 2 and xy[k[1]] and xy[k[2]])  then
			checktype(v, vec2_meta)

			rawset(t, xy[k[1]], rawget(v, 1))
			rawset(t, xy[k[2]], rawget(v, 2))
		else
			rawset(t, k, v)
		end
	end

	local math_min = math.min

	--- Gets a value at a key in the vector
	-- Can be indexed with: 1, 2, x, y, xx, xy, xx, xy, yx, etc.. 1, 2 is most efficient
	-- @param number|string key Key to get the value at
	-- @return number The value at the index
	function vec2_meta.__index(t, k)
		local method = vec2_methods[k]
		if method ~= nil then
			return method
		elseif xy[k] then
			return rawget(t, xy[k])
		else
			-- Swizzle support
			local v = {0, 0}
			for i = 1, math_min(#k, 2)do
				local vk = xy[k[i]]
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

	--- Turns a vector into a string
	-- @return string String representation of the vector
	function vec2_meta.__tostring(a)
		return table_concat(a, ' ', 1, 2)
	end

	--- Multiplication metamethod
	-- @param number|Vector2 a Number or Vector multiplicand
	-- @param number|Vector2 b Number or Vector multiplier
	-- @return Vector2 Multiplied vector
	function vec2_meta.__mul(a, b)
		if isnumber(b) then
			return wrap({ a[1] * b, a[2] * b })
		elseif isnumber(a) then
			return wrap({ b[1] * a, b[2] * a })
		elseif dgetmeta(a) == vec2_meta and dgetmeta(b) == vec2_meta then
			return wrap({ a[1] * b[1], a[2] * b[2] })
		elseif dgetmeta(a) == vec2_meta then
			checkluatype(b, TYPE_NUMBER)
		else
			checkluatype(a, TYPE_NUMBER)
		end
	end

	--- Division metamethod
	-- @param number|Vector2 a Number or Vector dividend
	-- @param number|Vector2 b Number or Vector divisor
	-- @return Vector2 Scaled vector
	function vec2_meta.__div(a, b)
		if isnumber(b) then
			return wrap({ a[1] / b, a[2] / b })
		elseif isnumber(a) then
			return wrap({ a / b[1], a / b[2] })
		elseif dgetmeta(a) == vec2_meta and dgetmeta(b) == vec2_meta then
			return wrap({ a[1] / b[1], a[2] / b[2] })
		elseif dgetmeta(a) == vec2_meta then
			checkluatype(b, TYPE_NUMBER)
		else
			checkluatype(a, TYPE_NUMBER)
		end
	end

	--- Addition metamethod
	-- @param Vector2 a Initial vector
	-- @param Vector2 b Vector to add to the first
	-- @return Vector2 Resultant vector after addition operation
	function vec2_meta.__add(a, b)
		return wrap({ a[1] + b[1], a[2] + b[2] })
	end

	--- Subtraction metamethod
	-- @param Vector2 a Initial Vector
	-- @param Vector2 b Vector to subtract
	-- @return Vector2 Resultant vector after subtraction operation
	function vec2_meta.__sub(a, b)
		return wrap({ a[1] - b[1], a[2] - b[2] })
	end

	--- Unary Minus metamethod (Negative)
	-- @return Vector2 Negative vector
	function vec2_meta.__unm(a)
		return wrap({ -a[1], -a[2] })
	end

	--- Equivalence metamethod
	-- @param Vector2 a Initial vector
	-- @param Vector2 b Vector to check against
	-- @return boolean Whether both sides are equal
	function vec2_meta.__eq(a, b)
		return a[1] == b[1] and a[2] == b[2]
	end

	--- Calculates the cross product of the 2 vectors, returns the area of the parallelogram made by them
	-- @param Vector2 v Second Vector
	-- @return number Cross product
	function vec2_methods:cross(v)
		return self[1] * v[2] - self[2] * v[1]
	end

	local math_sqrt = math.sqrt

	--- Returns the pythagorean distance between the vector and the other vector
	-- @param Vector2 v Second Vector
	-- @return number Vector distance from v
	function vec2_methods:getDistance(v)
		return math_sqrt((v[1]-self[1])^2 + (v[2]-self[2])^2)
	end

	--- Returns the squared distance of 2 vectors, this is faster Vector2:getDistance as calculating the square root is an expensive process
	-- @param Vector2 v Second Vector
	-- @return number Vector distance from v
	function vec2_methods:getDistanceSqr(v)
		return (v[1]-self[1])^2 + (v[2]-self[2])^2
	end

	--- Dot product is the cosine of the angle between both vectors multiplied by their lengths. A.B = ||A||||B||cosA
	-- @param Vector2 v Second Vector
	-- @return number Dot product result between the two vectors
	function vec2_methods:dot(v)
		return self[1] * v[1] + self[2] * v[2]
	end

	--- Returns a new vector with the same direction by length of 1
	-- @return Vector2 Normalized vector
	function vec2_methods:getNormalized()
		local len = math_sqrt(self[1]^2 + self[2]^2)

		return wrap({ self[1] / len, self[2] / len })
	end

	--- Is this vector and v equal within tolerance t
	-- @param Vector2 v Second Vector
	-- @param number t Tolerance number
	-- @return boolean Whether the vector is equal to v within the tolerance
	function vec2_methods:isEqualTol(v, t)
		checkluatype(t, TYPE_NUMBER)

		return unwrap(self):IsEqualTol(unwrap(v), t)
	end

	--- Returns whether all fields are zero
	-- @return boolean Whether all fields are zero
	function vec2_methods:isZero()
		return self[1]==0 and self[2]==0 and self[3]==0
	end

	--- Get the vector's Length
	-- @return number Length of the vector
	function vec2_methods:getLength()
		return math_sqrt(self[1]^2 + self[2]^2)
	end

	--- Get the vector's length squared (Saves computation by skipping the square root)
	-- @return number length squared
	function vec2_methods:getLengthSqr()
		return self[1]^2 + self[2]^2
	end

	--- Add v to this vector
	-- Self-Modifies. Does not return anything
	-- @param Vector2 v Vector to add
	function vec2_methods:add(v)
		self[1] = self[1] + v[1]
		self[2] = self[2] + v[2]
	end

	--- Subtract v from this Vector
	-- Self-Modifies. Does not return anything
	-- @param Vector2 v Vector to subtract
	function vec2_methods:sub(v)
		self[1] = self[1] - v[1]
		self[2] = self[2] - v[2]
	end

	--- Scalar Multiplication of the vector
	-- Self-Modifies. Does not return anything
	-- @param number n Scalar to multiply with
	function vec2_methods:mul(n)
		checkluatype(n, TYPE_NUMBER)

		self[1] = self[1] * n
		self[2] = self[2] * n
	end

	--- "Scalar Division" of the vector
	-- Self-Modifies. Does not return anything
	-- @param number n Scalar to divide by
	function vec2_methods:div(n)
		checkluatype(n, TYPE_NUMBER)

		self[1] = self[1] / n
		self[2] = self[2] / n
	end

	--- Multiply self with a Vector
	-- Self-Modifies. Does not return anything
	-- @param Vector2 v Vector to multiply with
	function vec2_methods:vmul(v)
		self[1] = self[1] * v[1]
		self[2] = self[2] * v[2]
	end

	--- Divide self by a Vector
	-- Self-Modifies. Does not return anything
	-- @param Vector2 v Vector to divide by
	function vec2_methods:vdiv(v)
		self[1] = self[1] / v[1]
		self[2] = self[2] / v[2]
	end

	--- Set's all vector fields to 0
	-- Self-Modifies. Does not return anything
	function vec2_methods:setZero()
		self[1] = 0
		self[2] = 0
	end

	--- Set's the vector's x coordinate and returns the vector after modifying
	-- @param number x The x coordinate
	-- @return Vector2 Modified vector after setting X
	function vec2_methods:setX(x)
		self[1] = x
		return self
	end

	--- Set's the vector's y coordinate and returns the vector after modifying
	-- @param number y The y coordinate
	-- @return Vector2 Modified vector after setting Y
	function vec2_methods:setY(y)
		self[2] = y
		return self
	end

	--- Normalise the vector, same direction, length 1
	-- Self-Modifies. Does not return anything
	function vec2_methods:normalize()
		local len = math_sqrt(self[1]^2 + self[2]^2)

		self[1] = self[1] / len
		self[2] = self[2] / len
	end

	--- Round the vector values
	-- Self-Modifies. Does not return anything
	-- @param number idp (Default 0) The integer decimal place to round to
	function vec2_methods:round(idp)
		self[1] = math.Round(self[1], idp)
		self[2] = math.Round(self[2], idp)
	end

	--- Copies x,y,z from a vector and returns a new vector
	-- @return Vector2 The copy of the vector
	function vec2_methods:clone()
		return wrap({ self[1], self[2] })
	end

	--- Copies the values from the second vector to the first vector
	-- Self-Modifies. Does not return anything
	-- @param Vector2 v Second Vector2
	function vec2_methods:set(v)
		self[1] = v[1]
		self[2] = v[2]
	end
end
