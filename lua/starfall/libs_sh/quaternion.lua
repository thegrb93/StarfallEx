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


--- Quaternion type. Recently reworked library, for full changelist visit: https://github.com/thegrb93/StarfallEx/pull/953
-- @name Quaternion
-- @class type
-- @libtbl quat_methods
-- @libtbl quat_meta
SF.RegisterType("Quaternion", true, false, nil, nil, function(checktype, quat_meta)
	return function(q)
		return setmetatable({ q:Unpack() }, quat_meta)
	end,
	function(obj)
		checktype(obj, quat_meta, 2)
		return { obj[1], obj[2], obj[3], obj[4] }
	end	
end)


return function(instance)

local checktype = instance.CheckType
local quat_methods, quat_meta, qwrap, unwrap = instance.Types.Quaternion.Methods, instance.Types.Quaternion, instance.Types.Quaternion.Wrap, instance.Types.Quaternion.Unwrap
local ent_methods = instance.Types.Entity.Methods
local ang_methods, awrap, aunwrap = instance.Types.Angle.Methods, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local vec_methods, vec_meta, vwrap, vunwrap = instance.Types.Vector.Methods, instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local mwrap = instance.Types.VMatrix.Wrap
local math_library = instance.Libraries.math

local function wrap(tbl)
	return setmetatable(tbl, quat_meta)
end

local function qunpack(tbl)
	return self[1], self[2], self[3], self[4]
end

local getent
instance:AddHook("initialize", function()
	getent = instance.Types.Entity.GetEntity
end)

-------------------------------------

-- Following helper functions are strictly operating on tables, so be sure to wrap the return value

local function quatLen(q)
	return self[1] * self[1] + self[2] * self[2] + self[3] * self[3] + self[4] * self[4]
end

local function quatLenSqrt(q)
	return math_sqrt(quatLen(q))
end

local function quatImaginaryLen(q)
	return self[2] * self[2] + self[3] * self[3] + self[4] * self[4]
end

local function quatImaginaryLenSqrt(q)
	return math_sqrt(quatImaginaryLen(q))
end

local function quatMul(lhs, rhs)
	local lhs1, lhs2, lhs3, lhs4 = qunpack(lhs)
	local rhs1, rhs2, rhs3, rhs4 = qunpack(rhs)
	return {
		lhs1 * rhs1 - lhs2 * rhs2 - lhs3 * rhs3 - lhs4 * rhs4,
		lhs1 * rhs2 + lhs2 * rhs1 + lhs3 * rhs4 - lhs4 * rhs3,
		lhs1 * rhs3 + lhs3 * rhs1 + lhs4 * rhs2 - lhs2 * rhs4,
		lhs1 * rhs4 + lhs4 * rhs1 + lhs2 * rhs3 - lhs3 * rhs2
	}
end

local function quatExp(q)
	local ilen_sqrt = quatImaginaryLenSqrt(q)
	local real_exp = math_exp(q[1])
	
	if ilen_sqrt ~= 0 then
		local sin_ilen_sqrt = math_sin(ilen_sqrt)
		return {
			real_exp * math_cos(ilen_sqrt),
			real_exp * (q[2] * sin_ilen_sqrt / ilen_sqrt),
			real_exp * (q[3] * sin_ilen_sqrt / ilen_sqrt),
			real_exp * (q[4] * sin_ilen_sqrt / ilen_sqrt)}
	else
		return { real_exp, 0, 0, 0 }
	end
end

local function quatLog(q)
	local len_sqrt = quatLenSqrt(q)
	if len_sqrt == 0 then
		return { -1e+100, 0, 0, 0 }
	else
		local u = { q[1] / len_sqrt, q[2] / len_sqrt, q[3] / len_sqrt, q[4] / len_sqrt }
		local a = math_acos(u[1])
		local m = math_sqrt(u[2] * u[2] + u[3] * u[3] + u[4] * u[4])
		if m ~= 0 then
			return { math_log(len_sqrt), a * u[2] / m, a * u[3] / m, a * u[4] / m }
		else
			return { math_log(len_sqrt), 0, 0, 0 }
		end
	end
end

local function quatNorm(q)
	local len = quatLenSqrt(q)
	return { q[1] / len, q[2] / len, q[3] / len, q[4] / len }
end

local function quatDot(lhs, rhs)
	return lhs[1] * rhs[1] + lhs[2] * rhs[2] + lhs[3] * rhs[3] + lhs[4] * rhs[4]
end

local function quatFromAngle(ang)
	local p = math_rad(ang[1]) * 0.5
	local y = math_rad(ang[2]) * 0.5
	local r = math_rad(ang[3]) * 0.5
	
	local qr = { math_cos(r), math_sin(r), 0, 0 }
	local qp = { math_cos(p), 0, math_sin(p), 0 }
	local qy = { math_cos(y), 0, 0, math_sin(y) }
	
	return quatMul(qy, quatMul(qp, qr))
end

local function quatFromAngleComponents(p, y, r)
	p = math_rad(p) * 0.5
	y = math_rad(y) * 0.5
	r = math_rad(r) * 0.5
	
	local qr = { math_cos(r), math_sin(r), 0, 0 }
	local qp = { math_cos(p), 0, math_sin(p), 0 }
	local qy = { math_cos(y), 0, 0, math_sin(y) }
	
	return quatMul(qy, quatMul(qp, qr))
end

-------------------------------------

--- Creates a Quaternion
-- @name builtins_library.Quaternion
-- @class function
-- @param r - R
-- @param i - I
-- @param j - J
-- @param k - K
-- @return Quaternion object
function instance.env.Quaternion(r, i, j, k)
	if r ~= nil then checkluatype(r, TYPE_NUMBER) else r = 0 end
	if i ~= nil then checkluatype(i, TYPE_NUMBER) else i = 0 end
	if j ~= nil then checkluatype(j, TYPE_NUMBER) else j = 0 end
	if k ~= nil then checkluatype(k, TYPE_NUMBER) else k = 0 end
	
	return wrap({ r, i, j, k })
end


local rijk = { r = 1, i = 2, j = 3, k = 4 }

--- __newindex metamethod
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

--- __index metamethod
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
-- @return Quaternion product
function quat_meta.__mul(lhs, rhs)
	if isnumber(rhs) then -- Q * N
		return wrap({ lhs[1] * rhs, lhs[2] * rhs, lhs[3] * rhs, lhs[4] * rhs })
		
	elseif isnumber(lhs) then -- N * Q
		return wrap({ lhs * rhs[1], lhs * rhs[2], lhs * rhs[3], lhs * rhs[4] })
	end
	
	local lhs_meta = dgetmeta(lhs)
	local rhs_meta = dgetmeta(rhs)
	
	if lhs_meta == quat_meta and rhs_meta == quat_meta then -- Q * Q
		local lhs1, lhs2, lhs3, lhs4 = qunpack(lhs)
		local rhs1, rhs2, rhs3, rhs4 = qunpack(rhs)
		return wrap({
			lhs1 * rhs1 - lhs2 * rhs2 - lhs3 * rhs3 - lhs4 * rhs4,
			lhs1 * rhs2 + lhs2 * rhs1 + lhs3 * rhs4 - lhs4 * rhs3,
			lhs1 * rhs3 + lhs3 * rhs1 + lhs4 * rhs2 - lhs2 * rhs4,
			lhs1 * rhs4 + lhs4 * rhs1 + lhs2 * rhs3 - lhs3 * rhs2
		})
		
	elseif lhs_meta == quat_meta and rhs_meta == vec_meta then -- Q * V
		local lhs1, lhs2, lhs3, lhs4 = qunpack(lhs)
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

function quat_meta.__div(lhs, rhs)
	if isnumber(rhs) then -- Q / N
		return wrap({ lhs[1] / rhs, lhs[2] / rhs, lhs[3] / rhs, lhs[4] / rhs })
		
	elseif isnumber(lhs) then -- N / Q
		local rhs1, rhs2, rhs3, rhs4 = rhs[1], rhs[2], rhs[3], rhs[4]
		local len = rhs1 * rhs1 + rhs2 * rhs2 + rhs3 * rhs3 + rhs4 * rhs4
		return wrap({
			(lhs * rhs1) / len,
			(-lhs * rhs2) / len,
			(-lhs * rhs3) / len,
			(-lhs * rhs4) / len
		})
		
	elseif dgetmeta(lhs) == quat_meta and dgetmeta(rhs) == quat_meta then -- Q / Q
		local lhs1, lhs2, lhs3, lhs4 = qunpack(lhs)
		local rhs1, rhs2, rhs3, rhs4 = qunpack(rhs)
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

function quat_meta.__pow(lhs, rhs)
	if isnumber(rhs) then
		local log = quatLog(lhs)
		return wrap({ log[1] * rhs, log[2] * rhs, log[3] * rhs, log[4] * rhs })
		
	elseif isnumber(lhs) then
		if rhs == 0 then
			return wrap({ 0, 0, 0, 0 })
		end
		
		local log = math_log(lhs)
		return wrap(quatExp({ rhs[1] * log, rhs[2] * log, rhs[3] * log, rhs[4] * log }))
		
	elseif dgetmeta(lhs) == quat_meta then
		checkluatype(rhs, TYPE_NUMBER)
	else
		checkluatype(lhs, TYPE_NUMBER)
	end
end

function quat_meta.__add(lhs, rhs)
	if isnumber(rhs) then -- Q + N
		return wrap({ rhs + lhs[1], lhs[2], lhs[3], lhs[4] })
		
	elseif isnumber(lhs) then -- N + Q
		return wrap({ lhs + rhs[1], rhs[2], rhs[3], rhs[4] })
		
	elseif dgetmeta(lhs) == quat_meta and dgetmeta(rhs) == quat_meta then -- Q + Q
		return wrap({ lhs[1] + rhs[1], lhs[2] + rhs[2], lhs[3] + rhs[3], lhs[4] + rhs[4] })
		
	elseif dgetmeta(lhs) == quat_meta then
		checkluatype(rhs, TYPE_NUMBER)
	else
		checkluatype(lhs, TYPE_NUMBER)
	end
end

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

function quat_meta.__unm(q)
	return wrap({ -q[1], -q[2], -q[3], -q[4] })
end

function quat_meta.__eq(lhs, rhs)
	return lhs[1] == rhs[1] and lhs[2] == rhs[2] and lhs[3] == rhs[3] and lhs[4] == rhs[4]
end

function quat_meta.__tostring(q)
	return table.concat(unwrap(q), " ", 1, 4)
end

-------------------------------------

function quat_methods:unpack()
	return qunpack(self)
end

function quat_methods:clone()
	return wrap({ qunpack(self) })
end

function quat_methods:set(quat)
	self[1] = quat[1]
	self[2] = quat[2]
	self[3] = quat[3]
	self[4] = quat[4]
end

function quat_methods:setR(value)
	self[1] = value
end

function quat_methods:setI(value)
	self[2] = value
end

function quat_methods:setJ(value)
	self[3] = value
end

function quat_methods:setK(value)
	self[4] = value
end

-------------------------------------

function quat_methods:getExp()
	return wrap(quatExp(unwrap(self)))
end

function quat_methods:exp()
	local q = quatExp(unwrap(self))
	self[1] = q[1]
	self[2] = q[2]
	self[3] = q[3]
	self[4] = q[4]
end

function quat_methods:getLog()
	return wrap(quatLog(unwrap(self)))
end

function quat_methods:log()
	local q = quatLog(unwrap(self))
	self[1] = q[1]
	self[2] = q[2]
	self[3] = q[3]
	self[4] = q[4]
end

-------------------------------------

function quat_methods:getUp()
	local lhs1, lhs2, lhs3, lhs4 = qunpack(self)
	local t2, t3, t4 = lhs2 * 2, lhs3 * 2, lhs4 * 2
	return vwrap(Vector(
		t3 * lhs1 + t2 * lhs4,
		t3 * lhs4 - t2 * lhs1,
		lhs1 * lhs1 - lhs2 * lhs2 - lhs3 * lhs3 + lhs4 * lhs4
	))
end

function quat_methods:getRight()
	local lhs1, lhs2, lhs3, lhs4 = qunpack(self)
	local t2, t3, t4 = lhs2 * 2, lhs3 * 2, lhs4 * 2
	return vwrap(Vector(
		t4 * lhs1 - t2 * lhs3,
		lhs2 * lhs2 - lhs1 * lhs1 - lhs3 * lhs3 + lhs4 * lhs4,
		-t2 * lhs1 - t3 * lhs4
	))
end

function quat_methods:getForward()
	local lhs1, lhs2, lhs3, lhs4 = qunpack(self)
	local t2, t3, t4 = lhs2 * 2, lhs3 * 2, lhs4 * 2
	return vwrap(Vector(
		lhs1 * lhs1 + lhs2 * lhs2 - lhs3 * lhs3 - lhs4 * lhs4,
		t3 * lhs2 + t4 * lhs1,
		t4 * lhs2 - t3 * lhs1
	))
end

-------------------------------------

function quat_methods:getAbsolute()
	return quatLen(self)
end

function quat_methods:getConjecture()
	return wrap({ self[1], -self[2], -self[3], -self[4] })
end

-- TEST
function quat_methods:conjugate()
	self[2] = -self[2]
	self[3] = -self[3]
	self[4] = -self[4]
end

function quat_methods:getInverse()
	local len = quatLen(self)
	return wrap({ self[1] / len, self[2] / len, self[3] / len, self[4] / len })
end

function quat_methods:inverse()
	local len = quatLen(self)
	self[1] = self[1] / len
	self[2] = self[2] / len
	self[3] = self[3] / len
	self[4] = self[4] / len
end

function quat_methods:getMod() -- credits: https://github.com/coder0xff
	if self[1] < 0 then
		return wrap({ -self[1], -self[2], -self[3], -self[4] })
	else
		return wrap({ qunpack(self) })
	end
end

function quat_methods:mod()
	if self[1] < 0 then
		self[1] = -self[1]
		self[2] = -self[2]
		self[3] = -self[3]
		self[4] = -self[4]
	end
end

function quat_methods:getNormalized()
	return wrap(quatNorm(unwrap(self)))
end

function quat_methods:normalize()
	local len = quatLenSqrt(self)
	self[1] = self[1] / len
	self[2] = self[2] / len
	self[3] = self[3] / len
	self[4] = self[4] / len
end

function quat_methods:dot(quat)
	quat = unwrap(quat)
	return quatDot(self, quat)
end

-------------------------------------

function quat_methods:getVector()
	return vwrap(Vector(self[2], self[3], self[4]))
end

-- normalize: true = same as Q:getNormalized():getMatrix() // credits: https://stackoverflow.com/a/1556470
function quat_methods:getMatrix(normalize)
	local quat
	if normalize then
		checkluatype(normalize, BOOL)
		quat = quatNorm(self)
	else
		quat = unwrap(self)
	end
	
	local w, x, y, z = quat[1], quat[2], quat[3], quat[4]
	
	-- TEST
	local m = Matrix()
	return mwrap(m:SetUnpacked(
		1 - 2*y*y - 2*z*z,	2*x*y - 2*z*w,		2*x*z + 2*y*w,		0,
		2*x*y + 2*z*w,		1 - 2*x*y - 2*z*z,	2*y*z - 2*x*w,		0,
		2*x*z - 2*y*w,		2*y*z + 2*x*w,		1 - 2*x*x - 2*y*y,	0,
		0,					0,					0,					0))
	
	
	--[[
	return mwrap(Matrix({
		{ 1 - 2*y*y - 2*z*z,	2*x*y - 2*z*w,		2*x*z + 2*y*w,		0 },
		{ 2*x*y + 2*z*w,		1 - 2*x*y - 2*z*z,	2*y*z - 2*x*w,		0 },
		{ 2*x*z - 2*y*w,		2*y*z + 2*x*w,		1 - 2*x*x - 2*y*y,	0 },
		{ 0,					0,					0,					0 }
	}))]]--
end

-- quat_lib.rotationEulerAngle(q)
function quat_methods:getEulerAngle()
	local len_sqrt = quatLenSqrt(self)
	if len_sqrt == 0 then
		return awrap(Angle(0, 0, 0))
	else
		local q1, q2, q3, q4 = self[1] / len_sqrt, self[2] / len_sqrt, self[3] / len_sqrt, self[4] / len_sqrt
		local x = Vector(q1 * q1 + q2 * q2 - q3 * q3 - q4 * q4,
			2 * q3 * q2 + 2 * q4 * q1,
			2 * q4 * q2 - 2 * q3 * q1)
		local y = Vector(2 * q2 * q3 - 2 * q4 * q1,
			q1 * q1 - q2 * q2 + q3 * q3 - q4 * q4,
			2 * q2 * q1 + 2 * q3 * q4)
		
		local ang = x:Angle()
		if ang[1] > 180 then ang[1] = ang[1] - 360 end
		if ang[2] > 180 then ang[2] = ang[2] - 360 end
		
		local yaw = Vector(0, 1, 0)
		yaw:Rotate(Angle(0, ang[1], 0))
		
		ang[3] = math_deg(math_acos(math_clamp(y:Dot(yaw), -1, 1)))
		local dot = q1 * q2 + q3 * q4
		if dot < 0 then
			ang[3] = -ang[3]
		end
		
		return awrap(ang)
	end
end

-- full: true = [0..360]; false = [-180..180]
-- quat_lib.rotationAngle(q)
function quat_methods:getRotationAngle(full)
	local len = quatLen(self)
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

-- coder0xff
function quat_methods:getRotationAxis()
	local ilen = quatImaginaryLen(self)
	if ilen == 0 then
		return vwrap(Vector(0, 0, 1))
	else
		local ilen_sqrt = math_sqrt(ilen)
		return vwrap(Vector(self[2] / ilen_sqrt, self[3] / ilen_sqrt, self[4] / ilen_sqrt))
	end
end

function quat_methods:getRotationVector()
	local len = quatLen(self)
	local ilen_max = math_max(quatImaginaryLen(self), 0)
	
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
		up = vunwrap(up)
		local x = Vector(self[1], self[2], self[3])
		local z = Vector(up[1], up[2], up[3])
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

-- quat_lib.qRotation(axis, ang)
function vec_methods:getQuaternionFromAxis(ang)
	local axis = vunwrap(self):GetNormalized()
	local rang = math_rad(ang) * 0.5
	
	return wrap({ math_cos(rang), axis[1] * math_sin(rang), axis[2] * math_sin(rang), axis[3] * math_sin(rang) })
end

-- quat_lib.qRotation(rv1) // coder0xff (github)
function vec_methods:getQuaternionFromRotation()
	local vec_len = self[1] * self[1] + self[2] * self[2] + self[3] * self[3]
	if vec_len == 0 then
		return wrap({ 0, 0, 0, 0})
	else
		local vec_len_sqrt = math_sqrt(vec_len)
		local norm = (vec_len_sqrt + 180) % 360 - 180
		local ang = math_rad(norm) * 0.5
		local anglen = math_sin(ang) / vec_len_sqrt
		
		return wrap({ math_cos(ang), self[1] * anglen, self[2] * anglen, self[3] * anglen })
	end
end

function ang_methods:getQuaternion()
	return wrap(quatFromAngle(aunwrap(self)))
end

function ent_methods:getQuaternion()
	local ang = getent(self):GetAngles()
	return wrap(quatFromAngle(ang))
end

function math_library.slerpQuaternion(from, to, t)
	quat1 = unwrap(from)
	quat2 = unwrap(to)
	checkluatype(t, TYPE_NUMBER)
	
	local len = quat1[1] * quat1[1] + quat1[2] * quat1[2] + quat1[3] * quat1[3] + quat1[4] * quat1[4]
	if len == 0 then
		return wrap({ 0, 0, 0, 0})
	else
		local new
		if quatDot(quat1, quat2) < 0 then
			new = { -quat2[1], -quat2[2], -quat2[3], -quat2[4] }
		else
			new = quat2
		end
		
		local inv = { quat1[1] / len, -quat1[2] / len, -quat1[3] / len, -quat1[4] / len }
		local log = quatLog(quatMul(inv, new))
		local q = quatExp({ log[1] * t, log[2] * t, log[3] * t, log[4] * t })
		
		return wrap(quatMul(quat1, q))
	end
end

function math_library.nlerpQuaternion(from, to, t)
	quat1 = unwrap(from)
	quat2 = unwrap(to)
	checkluatype(t, TYPE_NUMBER)
		
	local t1 = 1 - t
	local new
	if quatDot(quat1, quat2) < 0 then
		new = { quat1[1] * t1 - quat2[1] * t, quat1[2] * t1 - quat2[2] * t, quat1[3] * t1 - quat2[3] * t, quat1[4] * t1 - quat2[4] * t }
	else
		new = { quat1[1] * t1 + quat2[1] * t, quat1[2] * t1 + quat2[2] * t, quat1[3] * t1 + quat2[3] * t, quat1[4] * t1 + quat2[4] * t }
	end
	
	return wrap(quatNorm(new))
end




end



--[[

TODO:

V Initialization - By definition one of the imaginary components has to be non-zero, maybe i, if not specified? Altho I might leave it 0,0,0,0 if it won't interfere with any of the MaThZ
V Setting
V Lookup
V Meta events
V Better name for qMod
V math.slerpQuaternion
V Replace rad2deg -> math.deg; deg2rad -> math.rad
V Make quatDot (qdot) and quatNormalize (qNorm) function
V Get rid of the unused parts of imported libs
V Write changelog (include which functions have transformed into methods) and link to it at the top of quat lib
Documentation
Credits
Compare all the calculations to E2 to ensure that there were no mistakes during original Starfall rewrite
Translate Fizyk's applyTorque example to SF
Blackmain Divran to test this
Remove quaternions.txt

TOOLAZYTODO:
Check if quatLong and other functions that use E2's `delta` thingy work correctly without it

]]

