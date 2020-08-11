local checkluatype = SF.CheckLuaType
local dgetmeta = debug.getmetatable

--- Quaternion object
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
		return {obj[1], obj[2], obj[3], obj[4]}
	end	
end)


return function(instance)

local checktype = instance.CheckType
local quat_methods, quat_meta, qwrap, unwrap = instance.Types.Quaternion.Methods, instance.Types.Quaternion, instance.Types.Quaternion.Wrap, instance.Types.Quaternion.Unwrap
local ent_methods, ent_meta, ewrap, eunwrap = instance.Types.Entity.Methods, instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local ang_methods, ang_meta, awrap, aunwrap = instance.Types.Angle.Methods, instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local vec_methods, vec_meta, vwrap, vunwrap = instance.Types.Vector.Methods, instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap

local function wrap(tbl)
	return setmetatable(tbl, quat_meta)
end

local getent
instance:AddHook("initialize", function()
	getent = instance.Types.Entity.GetEntity
end)

-------------------------------------

local math_sqrt = math.sqrt
local math_exp = math.exp
local math_log = math.log
local math_sin = math.sin
local math_cos = math.cos
local math_acos = math.acos

local deg2rad = math.pi / 180
local rad2deg = 180 / math.pi

local function quatMul(lhs, rhs)
	local lhs1, lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3], lhs[4]
	local rhs1, rhs2, rhs3, rhs4 = rhs[1], rhs[2], rhs[3], rhs[4]
	return {
		lhs1 * rhs1 - lhs2 * rhs2 - lhs3 * rhs3 - lhs4 * rhs4,
		lhs1 * rhs2 + lhs2 * rhs1 + lhs3 * rhs4 - lhs4 * rhs3,
		lhs1 * rhs3 + lhs3 * rhs1 + lhs4 * rhs2 - lhs2 * rhs4,
		lhs1 * rhs4 + lhs4 * rhs1 + lhs2 * rhs3 - lhs3 * rhs2
	}
end

local function quatExp(q)
	local m = math_sqrt(q[2] * q[2] + q[3] * q[3] + q[4] * q[4])
	local r = math_exp(q[1])
	
	if m ~= 0 then
		local sin_m = math_sin(m)
		return { r * math_cos(m), r * (q[2] * sin_m / m), r * (q[3] * sin_m / m), r * (q[4] * sin_m / m) }
	else
		return { r * math_cos(m), 0, 0, 0 }
	end
end

local function quatLog(q)
	local len = math_sqrt(q[1] * q[1] + q[2] * q[2] + q[3] * q[3] + q[4] * q[4])
	if len == 0 then
		return { -1e+100, 0, 0, 0 }
	else
		local u = { q[1] / len, q[2] / len, q[3] / len, q[4] / len }
		local a = math_acos(u[1])
		local m = math_sqrt(u[2] * u[2] + u[3] * u[3] + u[4] * u[4])
		if m ~= 0 then
			return { math_log(len), a * u[2] / m, a * u[3] / m, a * u[4] / m }
		else
			return { math_log(len), 0, 0, 0 }
		end
	end
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

local math_min = math.min
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
		local q = { 0,0,0,0 }
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
		local lhs1, lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3], lhs[4]
		local rhs1, rhs2, rhs3, rhs4 = rhs[1], rhs[2], rhs[3], rhs[4]
		return wrap({
			lhs1 * rhs1 - lhs2 * rhs2 - lhs3 * rhs3 - lhs4 * rhs4,
			lhs1 * rhs2 + lhs2 * rhs1 + lhs3 * rhs4 - lhs4 * rhs3,
			lhs1 * rhs3 + lhs3 * rhs1 + lhs4 * rhs2 - lhs2 * rhs4,
			lhs1 * rhs4 + lhs4 * rhs1 + lhs2 * rhs3 - lhs3 * rhs2
		})
		
	elseif lhs_meta == quat_meta and rhs_meta == vec_meta then -- Q * V
		local lhs1, lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3], lhs[4]
		local rhs2, rhs3, rhs4 = rhs[1], rhs[2], rhs[3]
		return wrap({
			-lhs2 * rhs2 - lhs3 * rhs3 - lhs4 * rhs4,
			lhs1 * rhs2 + lhs3 * rhs4 - lhs4 * rhs3,
			lhs1 * rhs3 + lhs4 * rhs2 - lhs2 * rhs4,
			lhs1 * rhs4 + lhs2 * rhs3 - lhs3 * rhs2
		})
		
	elseif lhs_meta == vec_meta and rhs_meta == quat_meta then -- V * Q
		local lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3]
		local rhs1, rhs2, rhs3, rhs4 = rhs[1], rhs[2], rhs[3], rhs[4]
		return wrap({
			-lhs2 * rhs2 - lhs3 * rhs3 - lhs4 * rhs4,
			lhs2 * rhs1 + lhs3 * rhs4 - lhs4 * rhs3,
			lhs3 * rhs1 + lhs4 * rhs2 - lhs2 * rhs4,
			lhs4 * rhs1 + lhs2 * rhs3 - lhs3 * rhs2
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
		local lhs1, lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3], lhs[4]
		local rhs1, rhs2, rhs3, rhs4 = rhs[1], rhs[2], rhs[3], rhs[4]
		local len = rhs1 * rhs1 + rhs2 * rhs2 + rhs3 * rhs3 + rhs4 * rhs4
		return wrap({
			(lhs1 * rhs1 + lhs2 * rhs2 + lhs3 * rhs3 + lhs4 * rhs4) / len,
			(-lhs1 * rhs2 + lhs2 * rhs1 - lhs3 * rhs4 + lhs4 * rhs3) / len,
			(-lhs1 * rhs3 + lhs3 * rhs1 - lhs4 * rhs2 + lhs2 * rhs4) / len,
			(-lhs1 * rhs4 + lhs4 * rhs1 - lhs2 * rhs3 + lhs3 * rhs2) / len
		})
		
	elseif lhs_meta == quat_meta then
		checkluatype(rhs, TYPE_NUMBER)
	else
		checkluatype(lhs, TYPE_NUMBER)
	end
end

function quat_meta.__pow(lhs, rhs)
	if isnumber(rhs) then
		local m = math.log(rhs)
		return wrap(quatExp({ lhs[1] * m, lhs[2] * m, lhs[3] * m, lhs[4] * m }))
	elseif isnumber(lhs) then
		local m = quatLog(rhs)
		return wrap(quatExp({ rhs[1] * m, rhs[2] * m, rhs[3] * m, rhs[4] * m }))
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
		
	elseif lhs_meta == quat_meta then
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
		
	elseif lhs_meta == quat_meta then
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

function quat_methods:clone()
	return wrap({ self[1], self[2], self[3], self[4] })
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
	local lhs1, lhs2, lhs3, lhs4 = self[1], self[2], self[3], self[4]
	local t2, t3, t4 = lhs2 * 2, lhs3 * 2, lhs4 * 2
	return vwrap(Vector(
		t3 * lhs1 + t2 * lhs4,
		t3 * lhs4 - t2 * lhs1,
		lhs1 * lhs1 - lhs2 * lhs2 - lhs3 * lhs3 + lhs4 * lhs4
	))
end

function quat_methods:getRight()
	local lhs1, lhs2, lhs3, lhs4 = self[1], self[2], self[3], self[4]
	local t2, t3, t4 = lhs2 * 2, lhs3 * 2, lhs4 * 2
	return vwrap(Vector(
		t4 * lhs1 - t2 * lhs3,
		lhs2 * lhs2 - lhs1 * lhs1 - lhs3 * lhs3 + lhs4 * lhs4,
		-t2 * lhs1 - t3 * lhs4
	))
end

function quat_methods:getForward()
	local lhs1, lhs2, lhs3, lhs4 = self[1], self[2], self[3], self[4]
	local t2, t3, t4 = lhs2 * 2, lhs3 * 2, lhs4 * 2
	return vwrap(Vector(
		lhs1 * lhs1 + lhs2 * lhs2 - lhs3 * lhs3 - lhs4 * lhs4,
		t3 * lhs2 + t4 * lhs1,
		t4 * lhs2 - t3 * lhs1
	))
end

-------------------------------------

function quat_methods:getAbsolute()
	return sqrt(self[1] * self[1] + self[2] * self[2] + self[3] * self[3] + self[4] * self[4])
end

function quat_methods:getConjecture()
	return wrap({ self[1], -self[2], -self[3], -self[4] })
end

function quat_methods:conjecture()
	self[2] = -self[2]
	self[3] = -self[3]
	self[4] = -self[4]
end

function quat_methods:getInverse()
	local len = self[1] * self[1] + self[2] * self[2] + self[3] * self[3] + self[4] * self[4]
	return wrap({ self[1] / len, self[2] / len, self[3] / len, self[4] / len })
end

function quat_methods:inverse()
	local len = self[1] * self[1] + self[2] * self[2] + self[3] * self[3] + self[4] * self[4]
	self[1] = self[1] / len
	self[2] = self[2] / len
	self[3] = self[3] / len
	self[4] = self[4] / len
end

function quat_methods:getMod() -- credits: https://github.com/coder0xff
	if self[1] < 0 then
		return wrap({ -self[1], -self[2], -self[3], -self[4] })
	else
		return wrap({ self[1], self[2], self[3], self[4] })
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

-------------------------------------

function quat_methods:getVector()
	return vwrap(Vector(self[2], self[3], self[4]))
end

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
		
		local yyaw = Vector(0, 1, 0)
		yyaw:Rotate(Angle(0, ang[2], 0))
		
		local roll = math_acos(math.Clamp(y:Dot(yyaw), -1, 1)) * rad2deg
		if y.z < 0 then
			roll = -roll
		end
		
		local p = ang[1] * deg2rad * 0.5
		local y = ang[2] * deg2rad * 0.5
		local r = roll * deg2rad * 0.5
		
		local qr = { math_cos(r), math_sin(r), 0, 0 }
		local qp = { math_cos(p), 0, math_sin(p), 0 }
		local qy = { math_cos(y), 0, 0, math_sin(y) }
		
		return wrap(quatMul(qy, quatMul(qp, qr)))
	else
		return wrap({ 0, self[1], self[2], self[3] })
	end
end

function ang_methods:getQuaternion()
	local p = self[1] * deg2rad * 0.5
	local y = self[2] * deg2rad * 0.5
	local r = self[3] * deg2rad * 0.5
	
	local qr = { math_cos(r), math_sin(r), 0, 0 }
	local qp = { math_cos(p), 0, math_sin(p), 0 }
	local qy = { math_cos(y), 0, 0, math_sin(y) }
	
	return wrap(quatMul(qy, quatMul(qp, qr)))
end

function ent_methods:getQuaternion()
	local ang = getent(self):GetAngles()
	
	local p = ang[1] * deg2rad * 0.5
	local y = ang[2] * deg2rad * 0.5
	local r = ang[3] * deg2rad * 0.5
	
	local qr = { math_cos(r), math_sin(r), 0, 0 }
	local qp = { math_cos(p), 0, math_sin(p), 0 }
	local qy = { math_cos(y), 0, 0, math_sin(y) }
	
	return wrap(quatMul(qy, quatMul(qp, qr)))
end





end



--[[

TODO:

V Initialization - By definition one of the imaginary components has to be non-zero, maybe i, if not specified? Altho I might leave it 0,0,0,0 if it won't interfere with any of the MaThZ
V Setting
V Lookup
V Meta events
V Better name for qMod
~ Documentation
Credits
Compare all the calculations to E2 to ensure that there were no mistakes during original Starfall rewrite
Check if quatLong and other functions that use E2's `delta` thingy work correctly without it
Blackmain Divran to test this
Remove quaternions.txt

]]

