local checkluatype = SF.CheckLuaType
local dgetmeta = debug.getmetatable

local math_sqrt = math.sqrt
local math_exp = math.exp
local math_log = math.log
local math_sin = math.sin
local math_cos = math.cos
local math_min = math.min
local math_acos = math.acos
local math_clamp = math.Clamp
local math_max = math.max
local math_rad = math.rad
local math_deg = math.deg

-------------------------------------

local function quatSet(q, r, i, j, k)
	q[1] = r
	q[2] = i
	q[3] = j
	q[4] = k
end

local function quatUnpack(q)
	return q[1], q[2], q[3], q[4]
end

-------------------------------------

local function getQuatLen(q)
	local q1, q2, q3, q4 = quatUnpack(q)
	return q1*q1 + q2*q2 + q3*q3 + q4*q4
end

local function getQuatLenSqrt(q)
	return math_sqrt(getQuatLen(q))
end

local function getQuatImaginaryLen(q)
	local _, q2, q3, q4 = quatUnpack(q)
	return q2*q2 + q3*q3 + q4*q4
end

local function getQuatImaginaryLenSqrt(q)
	return math_sqrt(getQuatImaginaryLen(q))
end

local function getQuatDot(lhs, rhs)
	return lhs[1] * rhs[1] + lhs[2] * rhs[2] + lhs[3] * rhs[3] + lhs[4] * rhs[4]
end

-------------------------------------

local function quatNorm(q)
	local len = getQuatLenSqrt(q)
	q[1] = q[1] / len
	q[2] = q[2] / len
	q[3] = q[3] / len
	q[4] = q[4] / len
end

local function quatDivNum(q, n)
	q[1] = q[1] / n
	q[2] = q[2] / n
	q[3] = q[3] / n
	q[4] = q[4] / n
end

local function quatMul(lhs, rhs)
	local lhs1, lhs2, lhs3, lhs4 = quatUnpack(lhs)
	local rhs1, rhs2, rhs3, rhs4 = quatUnpack(rhs)
	lhs[1] = lhs1 * rhs1 - lhs2 * rhs2 - lhs3 * rhs3 - lhs4 * rhs4
	lhs[2] = lhs1 * rhs2 + lhs2 * rhs1 + lhs3 * rhs4 - lhs4 * rhs3
	lhs[3] = lhs1 * rhs3 + lhs3 * rhs1 + lhs4 * rhs2 - lhs2 * rhs4
	lhs[4] = lhs1 * rhs4 + lhs4 * rhs1 + lhs2 * rhs3 - lhs3 * rhs2
end

-- just like quatMul, except the right side is getting modified
-- this is because of self-modifying nature of the lib while dealing with noncommutative multiplication
local function quatMulRight(lhs, rhs)
	local lhs1, lhs2, lhs3, lhs4 = quatUnpack(lhs)
	local rhs1, rhs2, rhs3, rhs4 = quatUnpack(rhs)
	rhs[1] = lhs1 * rhs1 - lhs2 * rhs2 - lhs3 * rhs3 - lhs4 * rhs4
	rhs[2] = lhs1 * rhs2 + lhs2 * rhs1 + lhs3 * rhs4 - lhs4 * rhs3
	rhs[3] = lhs1 * rhs3 + lhs3 * rhs1 + lhs4 * rhs2 - lhs2 * rhs4
	rhs[4] = lhs1 * rhs4 + lhs4 * rhs1 + lhs2 * rhs3 - lhs3 * rhs2
end

local function quatMulComponents(q, r, i, j, k)
	local q1, q2, q3, q4 = quatUnpack(q)
	q[1] = q1 * r - q2 * i - q3 * j - q4 * k
	q[2] = q1 * i + q2 * r + q3 * k - q4 * j
	q[3] = q1 * j + q3 * r + q4 * i - q2 * k
	q[4] = q1 * k + q4 * r + q2 * j - q3 * i
end

-- similarly to quatMulRight, the right side is getting modified
local function quatMulComponentsRight(r, i, j, k, q)
	local q1, q2, q3, q4 = quatUnpack(q)
	q[1] = r * q1 - i * q2 - j * q3 - k * q4
	q[2] = r * q2 + i * q1 + j * q4 - k * q3
	q[3] = r * q3 + j * q1 + k * q2 - i * q4
	q[4] = r * q4 + k * q1 + i * q3 - j * q2
end

local function quatMulNum(q, n)
	q[1] = q[1] * n
	q[2] = q[2] * n
	q[3] = q[3] * n
	q[4] = q[4] * n
end

local function quatExp(q)
	local ilen_sqrt = getQuatImaginaryLenSqrt(q)
	local real_exp = math_exp(q[1])
	
	if ilen_sqrt ~= 0 then
		local sin_ilen_sqrt = math_sin(ilen_sqrt)
		
		q[1] = real_exp * math_cos(ilen_sqrt)
		q[2] = real_exp * (q[2] * sin_ilen_sqrt / ilen_sqrt)
		q[3] = real_exp * (q[3] * sin_ilen_sqrt / ilen_sqrt)
		q[4] = real_exp * (q[4] * sin_ilen_sqrt / ilen_sqrt)
	else
		quatSet(q, real_exp, 0, 0, 0)
	end
end

local function quatLog(q)
	local len_sqrt = getQuatLenSqrt(q)
	if len_sqrt == 0 then
		quatSet(q, -1e+100, 0, 0, 0)
	else
		quatNorm(q)
		local q1, q2, q3, q4 = quatUnpack(q)
		
		local acos = math_acos(q1)
		local ilen = getQuatImaginaryLenSqrt(q)
		local ilen_log = math_log(len_sqrt)
		
		if ilen ~= 0 then
			quatSet(q, ilen_log, acos * q2 / ilen, acos * q3 / ilen, acos * q4 / ilen)
		else
			quatSet(q, ilen_log, 0, 0, 0)
		end
	end
end

local function quatInv(q)
	local len = getQuatLen(q)
	q[1] = q[1] / len
	q[2] = q[2] / len
	q[3] = q[3] / len
	q[4] = q[4] / len
end

local function quatConj(q)
	q[2] = -q[2]
	q[3] = -q[3]
	q[4] = -q[4]
end

local function quatFlip(q)
	q[1] = -q[1]
	q[2] = -q[2]
	q[3] = -q[3]
	q[4] = -q[4]
end

local function quatMod(q)
	if q[1] < 0 then
		quatFlip(q)
	end
end

local function quatFromAngle(ang)
	local p = math_rad(ang[1]) * 0.5
	local y = math_rad(ang[2]) * 0.5
	local r = math_rad(ang[3]) * 0.5
	
	local qp = { math_cos(p), 0, math_sin(p), 0 }
	quatMulComponents(qp, math_cos(r), math_sin(r), 0, 0)
	quatMulComponentsRight(math_cos(y), 0, 0, math_sin(y), qp)
	
	return qp
end

local function quatFromAngleComponents(p, y, r)
	p = math_rad(p) * 0.5
	y = math_rad(y) * 0.5
	r = math_rad(r) * 0.5
	
	local qp = { math_cos(p), 0, math_sin(p), 0 }
	quatMulComponents(qp, math_cos(r), math_sin(r), 0, 0)
	quatMulComponentsRight(math_cos(y), 0, 0, math_sin(y), qp)
	
	return qp
end


-- Based on Expression's 2 quaternion library: https://github.com/wiremod/wire/blob/master/lua/entities/gmod_wire_expression2/core/quaternion.lua
--- Quaternion type. Recently reworked, for full changelist visit: https://github.com/thegrb93/StarfallEx/pull/953
-- @name Quaternion
-- @class type
-- @libtbl quat_methods
-- @libtbl quat_meta
SF.RegisterType("Quaternion", true, false)


return function(instance)

local checktype = instance.CheckType
local quat_methods, quat_meta, qwrap, unwrap = instance.Types.Quaternion.Methods, instance.Types.Quaternion, instance.Types.Quaternion.Wrap, instance.Types.Quaternion.Unwrap
local ent_methods = instance.Types.Entity.Methods
local ang_methods, awrap, aunwrap = instance.Types.Angle.Methods, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local vec_methods, vec_meta, vwrap, vunwrap = instance.Types.Vector.Methods, instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local mwrap = instance.Types.VMatrix.Wrap
local math_library = instance.Libraries.math

local function wrap(q)
	return setmetatable(q, quat_meta)
end

local function cloneModify(func, original, ...)
	local new = original:clone()
	func(new, ...)
	return new
end

local getent
instance:AddHook("initialize", function()
	getent = instance.Types.Entity.GetEntity
end)
instance.Types.Quaternion.QuaternionMultiply = quatMul

-------------------------------------

--- Creates a Quaternion
-- @name builtins_library.Quaternion
-- @class function
-- @param r R (real) component
-- @param i I component
-- @param j J component
-- @param k K component
-- @return Quaternion object
function instance.env.Quaternion(r, i, j, k)
	if r ~= nil then checkluatype(r, TYPE_NUMBER) else r = 0 end
	if i ~= nil then checkluatype(i, TYPE_NUMBER) else i = 0 end
	if j ~= nil then checkluatype(j, TYPE_NUMBER) else j = 0 end
	if k ~= nil then checkluatype(k, TYPE_NUMBER) else k = 0 end
	
	return wrap({ r, i, j, k })
end


local rijk = { r = 1, i = 2, j = 3, k = 4 }

--- newindex metamethod
function quat_meta.__newindex(t, k, v)
	if rijk[k] then
		rawset(t, rijk[k], v)

	elseif (#k == 2 and rijk[k[1]] and rijk[k[2]])  then
		checktype(v, quat_meta)
		
		rawset(t, rijk[k[1]], rawget(v, 1))
		rawset(t, rijk[k[2]], rawget(v, 2))
		
	elseif (#k == 3 and rijk[k[1]] and rijk[k[2]] and rijk[k[3]]) then
		checktype(v, quat_meta)
		
		rawset(t, rijk[k[1]], rawget(v, 1))
		rawset(t, rijk[k[2]], rawget(v, 2))
		rawset(t, rijk[k[3]], rawget(v, 3))
		
	elseif (#k == 4 and rijk[k[1]] and rijk[k[2]] and rijk[k[3]] and rijk[k[4]]) then
		checktype(v, quat_meta)
		
		rawset(t, rijk[k[1]], rawget(v, 1))
		rawset(t, rijk[k[2]], rawget(v, 2))
		rawset(t, rijk[k[3]], rawget(v, 3))
		rawset(t, rijk[k[4]], rawget(v, 4))
		
	else
		rawset(t, k, v)
	end
end

--- index metamethod
-- Can be indexed with: 1, 2, 3, 4, r, i, j, k, rr, ri, rj, rk, rrr, rijk, kjir, etc. Numerical lookup is the most efficient
function quat_meta.__index(t, k)
	local method = quat_methods[k]
	if method ~= nil then
		return method
	elseif rijk[k] then
		return rawget(t, rijk[k])
	else 
		-- Swizzle support
		local q = { 0, 0, 0, 0 }
		for i = 1, math_min(#k, 4)do
			local vk = rijk[k[i]]
			if vk then
				q[i] = rawget(t, vk)
			else
				return nil -- Not a swizzle
			end
		end
		return wrap(q)
	end
end

-------------------------------------

--- multiplication metamethod
-- @param lhs Left side of equation
-- @param rhs Right side of equation
-- @return Product
function quat_meta.__mul(lhs, rhs)
	if isnumber(rhs) then -- Q * N
		return cloneModify(quatMulNum, lhs, rhs)
		
	elseif isnumber(lhs) then -- N * Q
		return cloneModify(quatMulNum, rhs, lhs)
	end
	
	local lhs_meta = dgetmeta(lhs)
	local rhs_meta = dgetmeta(rhs)
	
	if lhs_meta == quat_meta and rhs_meta == quat_meta then -- Q * Q
		return cloneModify(quatMul, lhs, rhs)
		
	elseif lhs_meta == quat_meta and rhs_meta == vec_meta then -- Q * V
		local lhs1, lhs2, lhs3, lhs4 = quatUnpack(lhs)
		local rhs2, rhs3, rhs4 = rhs[1], rhs[2], rhs[3]
		return wrap({
			-lhs2 * rhs2 - lhs3 * rhs3 - lhs4 * rhs4,
			lhs1 * rhs2 + lhs3 * rhs4 - lhs4 * rhs3,
			lhs1 * rhs3 + lhs4 * rhs2 - lhs2 * rhs4,
			lhs1 * rhs4 + lhs2 * rhs3 - lhs3 * rhs2
		})
		
	elseif lhs_meta == quat_meta then
		checkluatype(rhs, TYPE_NUMBER)
	else
		checkluatype(lhs, TYPE_NUMBER)
	end
end

--- division metamethod
-- @param lhs Left side of equation
-- @param rhs Right side of equation
-- @return Quotient
function quat_meta.__div(lhs, rhs)
	if isnumber(rhs) then -- Q / N
		return wrap({ lhs[1] / rhs, lhs[2] / rhs, lhs[3] / rhs, lhs[4] / rhs })
		
	elseif isnumber(lhs) then -- N / Q
		local len = getQuatLen(rhs)
		return wrap({
			(lhs * rhs[1]) / len,
			(-lhs * rhs[2]) / len,
			(-lhs * rhs[3]) / len,
			(-lhs * rhs[4]) / len
		})
		
	elseif dgetmeta(lhs) == quat_meta and dgetmeta(rhs) == quat_meta then -- Q / Q
		local lhs1, lhs2, lhs3, lhs4 = quatUnpack(lhs)
		local rhs1, rhs2, rhs3, rhs4 = quatUnpack(rhs)
		local len = rhs1 * rhs1 + rhs2 * rhs2 + rhs3 * rhs3 + rhs4 * rhs4
		return wrap({
			(lhs1 * rhs1 + lhs2 * rhs2 + lhs3 * rhs3 + lhs4 * rhs4) / len,
			(-lhs1 * rhs2 + lhs2 * rhs1 - lhs3 * rhs4 + lhs4 * rhs3) / len,
			(-lhs1 * rhs3 + lhs3 * rhs1 - lhs4 * rhs2 + lhs2 * rhs4) / len,
			(-lhs1 * rhs4 + lhs4 * rhs1 - lhs2 * rhs3 + lhs3 * rhs2) / len
		})
		
	elseif dgetmeta(lhs) == quat_meta then
		checkluatype(rhs, TYPE_NUMBER)
	else
		checkluatype(lhs, TYPE_NUMBER)
	end
end

--- involution metamethod
-- @param lhs Left side of equation
-- @param rhs Right side of equation
-- @return Power
function quat_meta.__pow(lhs, rhs)
	if isnumber(rhs) then -- Q ^ N
		local out = lhs:clone()
		quatLog(out)
		quatMulNum(out, rhs)
		quatExp(out)
		
		return out
		
	elseif isnumber(lhs) then -- N ^ Q
		if lhs == 0 then
			return wrap({ 0, 0, 0, 0 })
		end
		
		local out = rhs:clone()
		quatMulNum(out, math_log(lhs))
		quatExp(out)
		
		return out
		
	elseif dgetmeta(lhs) == quat_meta then
		checkluatype(rhs, TYPE_NUMBER)
	else
		checkluatype(lhs, TYPE_NUMBER)
	end
end

--- addition metamethod
-- @param lhs Left side of equation
-- @param rhs Right side of equation
-- @return Sum
function quat_meta.__add(lhs, rhs)
	if isnumber(rhs) then -- Q + N
		local out = lhs:clone()
		out[1] = out[1] + rhs
		
		return out
		
	elseif isnumber(lhs) then -- N + Q
		local out = rhs:clone()
		out[1] = out[1] + lhs
		
		return out
		
	elseif dgetmeta(lhs) == quat_meta and dgetmeta(rhs) == quat_meta then -- Q + Q
		return wrap({ lhs[1] + rhs[1], lhs[2] + rhs[2], lhs[3] + rhs[3], lhs[4] + rhs[4] })
		
	elseif dgetmeta(lhs) == quat_meta then
		checkluatype(rhs, TYPE_NUMBER)
	else
		checkluatype(lhs, TYPE_NUMBER)
	end
end

--- subtraction metamethod
-- @param lhs Left side of equation
-- @param rhs Right side of equation
-- @return Difference
function quat_meta.__sub(lhs, rhs)
	if isnumber(rhs) then -- Q - N
		return wrap({ lhs[1] - rhs, lhs[2], lhs[3], lhs[4] })
		
	elseif isnumber(lhs) then -- N - Q
		return wrap({ lhs - rhs[1], -rhs[2], -rhs[3], -rhs[4] })
		
	elseif dgetmeta(lhs) == quat_meta and dgetmeta(rhs) == quat_meta then -- Q - Q
		return wrap({ lhs[1] - rhs[1], lhs[2] - rhs[2], lhs[3] - rhs[3], lhs[4] - rhs[4] })
		
	elseif dgetmeta(lhs) == quat_meta then
		checkluatype(rhs, TYPE_NUMBER)
	else
		checkluatype(lhs, TYPE_NUMBER)
	end
end

--- unary minus metamethod
-- @param q Quaternion
-- @return Negated quaternion
function quat_meta.__unm(q)
	return wrap({ -q[1], -q[2], -q[3], -q[4] })
end

--- equivalence metamethod
-- @param lhs Left side of equation
-- @param rhs Right side of equation
-- @return True if both sides are equal
function quat_meta.__eq(lhs, rhs)
	return lhs[1] == rhs[1] and lhs[2] == rhs[2] and lhs[3] == rhs[3] and lhs[4] == rhs[4]
end

--- tostring metamethod
-- @param q Quaternion
-- @return Quaternion represented as a string
function quat_meta.__tostring(q)
	return table.concat(unwrap(q), " ", 1, 4)
end

-------------------------------------

--- Returns components of the quaternion
-- @return r, i, j, k
function quat_methods:unpack()
	return quatUnpack(self)
end

--- Creates a copy of the quaternion
-- @return Duplicate quaternion
function quat_methods:clone()
	return wrap({ quatUnpack(self) })
end

--- Copies components of the second quaternion to the first quaternion. Self-modifies
-- @param quat Quaternion to copy from
function quat_methods:set(quat)
	quatSet(self, quat[1], quat[2], quat[3], quat[4])
end

--- Sets R (real) component of the quaternion
-- @param r Value of the R component
function quat_methods:setR(r)
	self[1] = r
end

--- Sets I component of the quaternion
-- @param i Value of the I component
function quat_methods:setI(i)
	self[2] = i
end

--- Sets J component of the quaternion
-- @param j Value of the J component
function quat_methods:setJ(j)
	self[3] = j
end

--- Sets K component of the quaternion
-- @param k Value of the K component
function quat_methods:setK(k)
	self[4] = k
end

-------------------------------------

--- Raises Euler's constant e to the quaternion's power
-- @return Constant e raised to the quaternion
function quat_methods:getExp()
	return cloneModify(quatExp, self)
end

--- Raises Euler's constant e to the quaternion's power. Self-modifies
function quat_methods:exp()
	quatExp(self)
end

--- Calculates natural logarithm of the quaternion
-- @return Logarithmic quaternion
function quat_methods:getLog()
	return cloneModify(quatLog, self)
end

--- Calculates natural logarithm of the quaternion. Self-modifies
function quat_methods:log()
	quatLog(self)
end

-------------------------------------

--- Calculates upward direction of the quaternion
-- @return Vector pointing up
function quat_methods:getUp()
	local q1, q2, q3, q4 = quatUnpack(self)
	local t2, t3, t4 = q2 * 2, q3 * 2, q4 * 2
	return vwrap(Vector(
		t3 * q1 + t2 * q4,
		t3 * q4 - t2 * q1,
		q1 * q1 - q2 * q2 - q3 * q3 + q4 * q4
	))
end

--- Calculates right direction of the quaternion
-- @return Vector pointing right
function quat_methods:getRight()
	local q1, q2, q3, q4 = quatUnpack(self)
	local t2, t3, t4 = q2 * 2, q3 * 2, q4 * 2
	return vwrap(Vector(
		t4 * q1 - t2 * q3,
		q2 * q2 - q1 * q1 - q3 * q3 + q4 * q4,
		-t2 * q1 - t3 * q4
	))
end

--- Calculates forward direction of the quaternion
-- @return Vector pointing forward
function quat_methods:getForward()
	local q1, q2, q3, q4 = quatUnpack(self)
	local t2, t3, t4 = q2 * 2, q3 * 2, q4 * 2
	return vwrap(Vector(
		q1 * q1 + q2 * q2 - q3 * q3 - q4 * q4,
		t3 * q2 + t4 * q1,
		t4 * q2 - t3 * q1
	))
end

-------------------------------------

--- Returns absolute value of the quaternion
-- @return Absolute value
function quat_methods:getAbsolute()
	return getQuatLen(self)
end

--- Returns conjecture of the quaternion
-- @return Quaternion's conjecture
function quat_methods:getConjecture()
	return cloneModify(quatConj, self)
end

--- Conjugates the quaternion.
function quat_methods:conjugate()
	quatConj(self)
end

--- Calculates inverse of the quaternion
-- @return Inverse of the quaternion
function quat_methods:getInverse()
	return cloneModify(quatInv, self)
end

--- Calculates inverse of the quaternon. Self-modifies
function quat_methods:inverse()
	quatInv(self)
end

--- Gets the quaternion representing rotation contained within an angle between 0 and 180 degrees
-- @return Quaternion with contained rotation
function quat_methods:getMod()
	return cloneModify(quatMod, self)
end

--- Contains quaternion's represented rotation within an angle between 0 and 180 degrees. Self-modifies
function quat_methods:mod()
	quatMod(self)
end

--- Returns new normalized quaternion
-- @return Normalized quaternion
function quat_methods:getNormalized()
	return cloneModify(quatNorm, self)
end

--- Normalizes the quaternion. Self-modifies
function quat_methods:normalize()
	quatNorm(self)
end

--- Returns dot product of two quaternions
-- @param quat Second quaternion
-- @return The dot product
function quat_methods:dot(quat)
	quat = unwrap(quat)
	return getQuatDot(self, quat)
end

-------------------------------------

--- Converts quaternion to a vector by dropping the R (real) component
-- @return Vector from the quaternion
function quat_methods:getVector()
	return vwrap(Vector(self[2], self[3], self[4]))
end

-- credits: Malte Clasen (https://stackoverflow.com/a/1556470)
--- Converts quaternion to a matrix
-- @param Optional bool, normalizes the quaternion
-- @return Transformation matrix
function quat_methods:getMatrix(normalize)
	local quat
	if normalize then
		checkluatype(normalize, TYPE_BOOL)
		
		quat = self:clone()
		quatNorm(quat)
	else
		quat = self
	end
	
	local w, x, y, z = quatUnpack(quat)
	local m = Matrix()
	m:SetUnpacked(
		1 - 2*y*y - 2*z*z,	2*x*y - 2*z*w,		2*x*z + 2*y*w,		0,
		2*x*y + 2*z*w,		1 - 2*x*y - 2*z*z,	2*y*z - 2*x*w,		0,
		2*x*z - 2*y*w,		2*y*z + 2*x*w,		1 - 2*x*x - 2*y*y,	0,
		0,					0,					0,					0)
	
	return mwrap(m)
end

--- Returns the euler angle of rotation in degrees
-- @return Angle object
function quat_methods:getEulerAngle()
	local len_sqrt = getQuatLenSqrt(self)
	if len_sqrt == 0 then
		return awrap(Angle(0, 0, 0))
	else
		local q = cloneModify(quatNorm, self)
		local q1, q2, q3, q4 = quatUnpack(q)
		
		local x = Vector(q1*q1 + q2*q2 - q3*q3 - q4*q4, 2*q3*q2 + 2*q4*q1, 2*q4*q2 - 2*q3*q1)
		local y = Vector(2*q2*q3 - 2*q4*q1, q1*q1 - q2*q2 + q3*q3 - q4*q4, 2*q2*q1 + 2*q3*q4)
		
		local ang = x:Angle()
		if ang[1] > 180 then ang[1] = ang[1] - 360 end
		if ang[2] > 180 then ang[2] = ang[2] - 360 end
		
		local yaw = Vector(0, 1, 0)
		yaw:Rotate(Angle(0, ang[1], 0))
		
		ang[3] = math_deg(math_acos(math_clamp(y:Dot(yaw), -1, 1)))
		local dot = q1*q2 + q3*q4
		if dot < 0 then
			ang[3] = -ang[3]
		end
		
		return awrap(ang)
	end
end

-- credits: https://github.com/coder0xff
--- Returns the angle of rotation in degrees
-- @param full Optional bool, if true returned angle will be between -180 and 180, otherwise between 0 and 360
-- @return Angle number
function quat_methods:getRotationAngle(full)
	local len = getQuatLen(self)
	if len == 0 then
		return 0
	else
		local ang = math_deg(2 * math_acos(math_clamp(self[1] / math_sqrt(len), -1, 1)))
		
		if full then
			checkluatype(full, TYPE_BOOL)
			return ang
		else
			if ang > 180 then
				ang = ang - 360
			end
			return ang
		end
	end
end

-- credits: https://github.com/cder0xff
--- Returns the axis of rotation
-- @return Vector axis
function quat_methods:getRotationAxis()
	local ilen = getQuatImaginaryLen(self)
	if ilen == 0 then
		return vwrap(Vector(0, 0, 1))
	else
		local ilen_sqrt = math_sqrt(ilen)
		return vwrap(Vector(self[2] / ilen_sqrt, self[3] / ilen_sqrt, self[4] / ilen_sqrt))
	end
end

-- credits: https://github.com/cder0xff
--- Returns the rotation vector - rotation axis where magnitude is the angle of rotation in degrees
-- @return Rotation vector
function quat_methods:getRotationVector()
	local len = getQuatLen(self)
	local ilen_max = math_max(getQuatImaginaryLen(self), 0)
	
	if len == 0 or ilen_max == 0 then
		return vwrap(Vector(0, 0, 0))
	else
		local ang = math_deg(2 * math_acos(math_clamp(self[1] / math_sqrt(len), -1, 1)))
		if ang > 180 then
			ang = ang - 360
		end
		ang = ang / math_sqrt(ilen_max)
		
		return vwrap(Vector(self[2] * ang, self[3] * ang, self[4] * ang))
	end
end

-------------------------------------

--- Converts vector to quaternion
-- @param up Upward direction. If specified, the original vector will act like a forward pointing one
-- @return Quaternion from the given vector
function vec_methods:getQuaternion(up)
	if up then
		local x = vunwrap(self)
		local z = vunwrap(up)
		local y = z:Cross(x):GetNormalized()
		
		local ang = x:Angle()
		if ang[1] > 180 then ang[1] = ang[1] - 360 end
		if ang[2] > 180 then ang[2] = ang[2] - 360 end
		
		local yaw = Vector(0, 1, 0)
		yaw:Rotate(Angle(0, ang[2], 0))
		
		local roll = math_deg(math_acos(math_clamp(y:Dot(yaw), -1, 1)))
		if y[3] < 0 then
			roll = -roll
		end
		
		return wrap(quatFromAngleComponents(ang[1], ang[2], roll))
	else
		return wrap({ 0, self[1], self[2], self[3] })
	end
end

--- Returns quaternion for rotation about axis represented by the vector by an angle
-- @param ang Number rotation angle
-- @return Rotated quaternion
function vec_methods:getQuaternionFromAxis(ang)
	local axis = vunwrap(self):GetNormalized()
	local rang = math_rad(ang) * 0.5
	
	return wrap({ math_cos(rang), axis[1] * math_sin(rang), axis[2] * math_sin(rang), axis[3] * math_sin(rang) })
end

-- credits: https://github.com/cder0xff
--- Constructs a quaternion from the rotation vector. Vector direction is axis of rotation, it's magnitude is angle in degrees
-- @return Rotated quaternion
function vec_methods:getQuaternionFromRotation()
	local vec_len = self:getLengthSqr()
	if vec_len == 0 then
		return wrap({ 0, 0, 0, 0 })
	else
		local vec_len_sqrt = math_sqrt(vec_len)
		local norm = (vec_len_sqrt + 180) % 360 - 180
		local ang = math_rad(norm) * 0.5
		local anglen = math_sin(ang) / vec_len_sqrt
		
		return wrap({ math_cos(ang), self[1] * anglen, self[2] * anglen, self[3] * anglen })
	end
end

--- Converts angle to a quaternion
-- @return Constructed quaternion
function ang_methods:getQuaternion()
	return wrap(quatFromAngle(aunwrap(self)))
end

--- Converts entity angles to a quaternion
-- @return Constructed quaternion
function ent_methods:getQuaternion()
	local ang = getent(self):GetAngles()
	return wrap(quatFromAngle(ang))
end

--- Performs spherical linear interpolation between two quaternions
-- @param from Quaternion to start with
-- @param to Quaternion to end with
-- @param t Ratio, 0 = from; 1 = to
-- @return Interpolated quaternion
function math_library.slerpQuaternion(from, to, t)
	quat1 = unwrap(from)
	quat2 = unwrap(to)
	checkluatype(t, TYPE_NUMBER)
	
	if getQuatLen(quat1) == 0 then
		return wrap({ 0, 0, 0, 0})
	else
		local new = quat2:clone()
		if getQuatDot(quat1, quat2) < 0 then
			quatFlip(new)
		end
		
		-- Sparky made me do it! Blame him.
		local out = quat1:clone()
		quatInv(out)
		quatConj(out)
		quatMul(out, new)
		quatLog(out)
		quatMulNum(out, t)
		quatExp(out)
		quatMulRight(quat1, out)
		
		return out
	end
end

--- Performs normalized linear interpolation between two quaternions
-- @param from Quaternion to start with
-- @param to Quaternion to end with
-- @param t Ratio, 0 = from; 1 = to
-- @return Interpolated quaternion
function math_library.nlerpQuaternion(from, to, t)
	quat1 = unwrap(from)
	quat2 = unwrap(to)
	checkluatype(t, TYPE_NUMBER)
	
	local t1 = 1 - t
	local new
	if getQuatDot(quat1, quat2) < 0 then
		new = { quat1[1] * t1 - quat2[1] * t, quat1[2] * t1 - quat2[2] * t, quat1[3] * t1 - quat2[3] * t, quat1[4] * t1 - quat2[4] * t }
	else
		new = { quat1[1] * t1 + quat2[1] * t, quat1[2] * t1 + quat2[2] * t, quat1[3] * t1 + quat2[3] * t, quat1[4] * t1 + quat2[4] * t }
	end
	
	quatNorm(new)
	return wrap(new)
end

end
