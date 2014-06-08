--- Quaternion library

--- Quaternion library
-- @deprecated Pure Lua implementation. This can be done with a user library.
local quat_lib, quat_lib_metamethods = SF.Libraries.Register("quaternion")

local vwrap, vunwrap = SF.WrapObject, SF.UnwrapObject

--[[
-- Quaternion Support
-- Converted from Wiremod's E2 Quaternion library for general lua use
-- Original code for use by Bubbus
-- Permission received for use from Bubbus by Radon
-- http:\\wiki.wiremod.com/?title=Expression2#Quaternion
--
-- Credits to Radon for addition to Starfall
-- Credits to Divran for painful amounts of testing
]]

-- faster access to some math library functions
local math = math -- Because global lookups suck
local setmetatable = setmetatable
local abs   = math.abs
local Round = math.Round
local sqrt  = math.sqrt
local exp   = math.exp
local log   = math.log
local sin   = math.sin
local cos   = math.cos
local sinh  = math.sinh
local cosh  = math.cosh
local acos  = math.acos
local min 	= math.min

local delta = wire_expression2_delta or 0.0000001000000

local isValid = SF.Entities.IsValid -- For checking shit

local deg2rad = math.pi/180
local rad2deg = 180/math.pi

--- Quaternion type
-- @deprecated Pure Lua implementation. This can be done with a user library.
local quat_methods, quat_metamethods = SF.Typedef("Quaternion")
--[[quat_metamethods = {__index = quat_lib}
quat_lib.__metatable = quat_metamethods
quat_metamethods.__type = "Quaternion"
setmetatable(quat_lib, quat_metamethods)]]

--****************************** Helper functions ******************************--

local function quicknew(r, i, j, k)
	local new = {r, i, j, k}
	setmetatable( new, quat_metamethods )
	return new
end

local function qmul(lhs, rhs)
	local lhs1, lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3], lhs[4]
	local rhs1, rhs2, rhs3, rhs4 = rhs[1], rhs[2], rhs[3], rhs[4]
	return quicknew(
		lhs1 * rhs1 - lhs2 * rhs2 - lhs3 * rhs3 - lhs4 * rhs4,
		lhs1 * rhs2 + lhs2 * rhs1 + lhs3 * rhs4 - lhs4 * rhs3,
		lhs1 * rhs3 + lhs3 * rhs1 + lhs4 * rhs2 - lhs2 * rhs4,
		lhs1 * rhs4 + lhs4 * rhs1 + lhs2 * rhs3 - lhs3 * rhs2
	)
end

local function qexp(q)
	local m = sqrt(q[2]*q[2] + q[3]*q[3] + q[4]*q[4])
	local u
	if m ~= 0 then
		u = { q[2]*sin(m)/m, q[3]*sin(m)/m, q[4]*sin(m)/m }
	else
		u = { 0, 0, 0 }
	end
	local r = exp(q[1])
	return quicknew( r*cos(m), r*u[1], r*u[2], r*u[3] )
end

local function qlog(q)
	local l = sqrt(q[1]*q[1] + q[2]*q[2] + q[3]*q[3] + q[4]*q[4])
	if l == 0 then return { -1e+100, 0, 0, 0 } end
	local u = { q[1]/l, q[2]/l, q[3]/l, q[4]/l }
	local a = acos(u[1])
	local m = sqrt(u[2]*u[2] + u[3]*u[3] + u[4]*u[4])
	if abs(m) > delta then
		return quicknew( log(l), a*u[2]/m, a*u[3]/m, a*u[4]/m )
	else
		return quicknew( log(l), 0, 0, 0 )  --when m is 0, u[2], u[3] and u[4] are 0 too
	end
end

--******************************************************************************--

local argTypesToQuat = {}
--- Converts a number to a Quaternion format for generation
-- @param args
argTypesToQuat["number"] = function(num)
	return quicknew(num, 0, 0, 0)
end

--- Converts 4 numbers to a Quaternion format for generation
-- @param args
argTypesToQuat["numbernumbernumbernumber"] = function(a,b,c,d)
	return quicknew(a,b,c,d)
end

--- Converts a Vector to a Quaternion format for generation
-- @param args
argTypesToQuat["Vector"] = function(vec)
	return quicknew(0, vec.x, vec.y, vec.z)
end

--- Converts an Angle to a Quaternion format for generation
-- @param args
argTypesToQuat["Angle"] = function(ang)
	local p, y, r = ang.p, ang.y, ang.r
	p = p*deg2rad*0.5
	y = y*deg2rad*0.5
	r = r*deg2rad*0.5
	local qr = {cos(r), sin(r), 0, 0}
	local qp = {cos(p), 0, sin(p), 0}
	local qy = {cos(y), 0, 0, sin(y)}
	return qmul(qy,qmul(qp,qr))
end

--- Converts a Number/Vector combination to a Quaternion format for generation
-- @param args
argTypesToQuat["numberVector"] = function(num,vec)
	return quicknew(num, vec.x, vec.y, vec.z) -- TODO Cannot change protect metatable? fix this
end

--- Converts two Vectors to a Quaternion format for generation using Cross product and the angle between them
-- @param args
argTypesToQuat["VectorVector"] = function(forward,up)
	local x = Vector(forward.x, forward.y, forward.z)
	local z = Vector(up.x, up.y, up.z)
	local y = z:Cross(x):GetNormalized() --up x forward = left

	local ang = x:Angle()
	if ang.p > 180 then ang.p = ang.p - 360 end
	if ang.y > 180 then ang.y = ang.y - 360 end

	local yyaw = Vector(0,1,0)
	yyaw:Rotate(Angle(0,ang.y,0))

	local roll = acos(math.Clamp(y:Dot(yyaw), -1, 1))*rad2deg

	local dot = y.z
	if dot < 0 then roll = -roll end

	local p, y, r = ang.p, ang.y, roll
	p = p*deg2rad*0.5
	y = y*deg2rad*0.5
	r = r*deg2rad*0.5
	local qr = {cos(r), sin(r), 0, 0}
	local qp = {cos(p), 0, sin(p), 0}
	local qy = {cos(y), 0, 0, sin(y)}
	return qmul(qy,qmul(qp,qr))
end

--- Converts an Entity to a Quaternion format for generation
-- @param args Table, containing an Entity to be used at the first index.
argTypesToQuat["Entity"] = function(ent)
	ent = SF.UnwrapObject( ent )
	
	if not isValid( ent ) then
		return quicknew( 0, 0, 0, 0 )
	end

	local ang = ent:GetAngles()
	local p, y, r = ang.p, ang.y, ang.r
	p = p*deg2rad*0.5
	y = y*deg2rad*0.5
	r = r*deg2rad*0.5
	local qr = {cos(r), sin(r), 0, 0}
	local qp = {cos(p), 0, sin(p), 0}
	local qy = {cos(y), 0, 0, sin(y)}
	return qmul(qy,qmul(qp,qr))
end



--- Creates a new Quaternion given a variety of inputs
-- @param ... A series of arguments which lead to valid generation of a quaternion.
-- See argTypesToQuat table for examples of acceptable inputs.
function quat_lib.New( self, ...)
	local args = {...}
	
	local argtypes = ""
	for i=1,min(#args,4) do
		argtypes = argtypes .. SF.GetType( args[i] )
	end
	
	return argTypesToQuat[argtypes] and argTypesToQuat[argtypes](...) or quicknew(0,0,0,0)
end

quat_lib_metamethods.__call = quat_lib.New


local function format(value)
	local r,i,j,k,dbginfo

	r = ""
	i = ""
	j = ""
	k = ""

	if abs(value[1]) > 0.0005 then
		r = Round(value[1]*1000)/1000
	end

	dbginfo = r

	if abs(value[2]) > 0.0005 then
		i = tostring(Round(value[2]*1000)/1000)

		if string.sub(i,1,1) ~= "-" and dbginfo ~= "" then i = "+"..i end

		i = i .. "i"
	end

	dbginfo = dbginfo .. i

	if abs(value[3]) > 0.0005 then
		j = tostring(Round(value[3]*1000)/1000)

		if string.sub(j,1,1) ~= "-" and dbginfo ~= "" then j = "+"..j end

		j = j .. "j"
	end

	dbginfo = dbginfo .. j

	if abs(value[4]) > 0.0005 then
		k = tostring(Round(value[4]*1000)/1000)

		if string.sub(k,1,1) ~= "-" and dbginfo ~= "" then k = "+"..k end

		k = k .. "k"
	end

	dbginfo = dbginfo .. k

	if dbginfo == "" then dbginfo = "0 LAWL" end

	return dbginfo
end


quat_metamethods.__tostring = format




--- Returns Quaternion <n>*i
function quat_lib.qi(n)
	return quicknew(0, n or 1, 0, 0)
end

--- Returns Quaternion <n>*j
function quat_lib.qj(n)
	return quicknew(0, 0, n or 1, 0)
end

--- Returns Quaternion <n>*k
function quat_lib.qk(n)
	return quicknew(0, 0, 0, n or 1)
end




quat_metamethods.__unm = function(q)
	return quicknew( -q[1], -q[2], -q[3], -q[4] )
end


quat_metamethods.__add = function(lhs, rhs)

	SF.CheckType(lhs, quat_metamethods)
	SF.CheckType(rhs, quat_metamethods)

	local ltype = SF.GetType(lhs)
	local rtype = SF.GetType(rhs)

	if ltype == "Quaternion" then
		if rtype == "Quaternion" then
			return quicknew( lhs[1] + rhs[1], lhs[2] + rhs[2], lhs[3] + rhs[3], lhs[4] + rhs[4] )
		elseif rtype == "number" then
			return quicknew( lhs[1] + rhs, lhs[2], lhs[3], lhs[4] )
		end
	elseif ltype == "number" and rtype == "Quaternion" then
		return quicknew( lhs + rhs[1], rhs[2], rhs[3], rhs[4] )
	end

	Error("Tried to add a " .. ltype .. " to a " .. rtype .. "not ")
end


quat_metamethods.__sub = function(lhs, rhs)
	local ltype = SF.GetType(lhs)
	local rtype = SF.GetType(rhs)

	if ltype == "Quaternion" then
		if rtype == "Quaternion" then
			return quicknew( lhs[1] - rhs[1], lhs[2] - rhs[2], lhs[3] - rhs[3], lhs[4] - rhs[4] )
		elseif rtype == "number" then
			return quicknew( lhs[1] - rhs, lhs[2], lhs[3], lhs[4] )
		end
	elseif ltype == "number" and rtype == "Quaternion" then
		return quicknew( lhs - rhs[1], -rhs[2], -rhs[3], -rhs[4] )
	end

	Error("Tried to subtract a " .. ltype .. " from a " .. rtype .. "not ")
end


quat_metamethods.__mul = function(lhs, rhs)
	local ltype = SF.GetType(lhs)
	local rtype = SF.GetType(rhs)

	if ltype == "Quaternion" then
		if rtype == "Quaternion" then
			local lhs1, lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3], lhs[4]
			local rhs1, rhs2, rhs3, rhs4 = rhs[1], rhs[2], rhs[3], rhs[4]
			return quicknew(
			lhs1 * rhs1 - lhs2 * rhs2 - lhs3 * rhs3 - lhs4 * rhs4,
			lhs1 * rhs2 + lhs2 * rhs1 + lhs3 * rhs4 - lhs4 * rhs3,
			lhs1 * rhs3 + lhs3 * rhs1 + lhs4 * rhs2 - lhs2 * rhs4,
			lhs1 * rhs4 + lhs4 * rhs1 + lhs2 * rhs3 - lhs3 * rhs2
			)
		elseif rtype == "number" then
			return quicknew( lhs[1] * rhs, lhs[2] * rhs, lhs[3] * rhs, lhs[4] * rhs )
		elseif rtype == "Vector" then
			local lhs1, lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3], lhs[4]
			local rhs2, rhs3, rhs4 = rhs[1], rhs[2], rhs[3]
			return quicknew(
			-lhs2 * rhs2 - lhs3 * rhs3 - lhs4 * rhs4,
			lhs1 * rhs2 + lhs3 * rhs4 - lhs4 * rhs3,
			lhs1 * rhs3 + lhs4 * rhs2 - lhs2 * rhs4,
			lhs1 * rhs4 + lhs2 * rhs3 - lhs3 * rhs2
			)
		end
	elseif rtype == "Quaternion" then
		if ltype == "number" then
			return quicknew( lhs * rhs[1], lhs * rhs[2], lhs * rhs[3], lhs * rhs[4] )
		elseif ltype == "Vector" then
			local lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3]
			local rhs1, rhs2, rhs3, rhs4 = rhs[1], rhs[2], rhs[3], rhs[4]
			return quicknew(
			-lhs2 * rhs2 - lhs3 * rhs3 - lhs4 * rhs4,
			lhs2 * rhs1 + lhs3 * rhs4 - lhs4 * rhs3,
			lhs3 * rhs1 + lhs4 * rhs2 - lhs2 * rhs4,
			lhs4 * rhs1 + lhs2 * rhs3 - lhs3 * rhs2
			)
		end
	end

	Error("Tried to multiply a " .. ltype .. " with a " .. rtype .. "not \n")
end


quat_metamethods.__div = function(lhs, rhs)
	SF.CheckType(lhs, quat_metamethods)
	SF.CheckType(rhs, quat_metamethods)

	local ltype = SF.GetType(lhs)
	local rtype = SF.GetType(rhs)

	if ltype == "Quaternion" then
		if rtype == "Quaternion" then
			local lhs1, lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3], lhs[4]
			local rhs1, rhs2, rhs3, rhs4 = rhs[1], rhs[2], rhs[3], rhs[4]
			local l = rhs1*rhs1 + rhs2*rhs2 + rhs3*rhs3 + rhs4*rhs4
			return quicknew(
			( lhs1 * rhs1 + lhs2 * rhs2 + lhs3 * rhs3 + lhs4 * rhs4)/l,
			(-lhs1 * rhs2 + lhs2 * rhs1 - lhs3 * rhs4 + lhs4 * rhs3)/l,
			(-lhs1 * rhs3 + lhs3 * rhs1 - lhs4 * rhs2 + lhs2 * rhs4)/l,
			(-lhs1 * rhs4 + lhs4 * rhs1 - lhs2 * rhs3 + lhs3 * rhs2)/l
			)
		elseif rtype == "number" then
			local lhs1, lhs2, lhs3, lhs4 = lhs[1], lhs[2], lhs[3], lhs[4]
			return quicknew(
			lhs1/rhs,
			lhs2/rhs,
			lhs3/rhs,
			lhs4/rhs
			)
		end
	elseif rtype == "Quaternion" then
		if ltype == "number" then
			local rhs1, rhs2, rhs3, rhs4 = rhs[1], rhs[2], rhs[3], rhs[4]
			local l = rhs1*rhs1 + rhs2*rhs2 + rhs3*rhs3 + rhs4*rhs4
			return quicknew(
			( lhs * rhs1)/l,
			(-lhs * rhs2)/l,
			(-lhs * rhs3)/l,
			(-lhs * rhs4)/l
			)
		end
	end

	error("Tried to divide a " .. ltype .. " with a " .. rtype)
end


quat_metamethods.__pow = function(lhs, rhs)
	SF.CheckType(lhs, quat_metamethods)
	SF.CheckType(rhs, quat_metamethods)


	local ltype = SF.GetType(lhs)
	local rtype = SF.GetType(rhs)

	if ltype == "Quaternion" and rtype == "number" then
		if lhs == 0 then return { 0, 0, 0, 0 } end

		local l = log(lhs)
		return qexp({ l*rhs[1], l*rhs[2], l*rhs[3], l*rhs[4] })
	elseif rtype == "Quaternion" and ltype == "number" then
		local l = qlog(lhs)
		return qexp({ l[1]*rhs, l[2]*rhs, l[3]*rhs, l[4]*rhs })
	end

	Error("Tried to exponentiate a " .. ltype .. " with a " .. rtype .. "not ")
end


--[[****************************************************************************]]

quat_metamethods.__eq = function(lhs, rhs)
	local ltype = SF.GetType(lhs)
	local rtype = SF.GetType(rhs)

	if ltype == "Quaternion" and rtype == "Quaternion" then
		local rvd1, rvd2, rvd3, rvd4 = lhs[1] - rhs[1], lhs[2] - rhs[2], lhs[3] - rhs[3], lhs[4] - rhs[4]
		if rvd1 <= delta and rvd1 >= -delta and
			rvd2 <= delta and rvd2 >= -delta and
			rvd3 <= delta and rvd3 >= -delta and
			rvd4 <= delta and rvd4 >= -delta
		then
			return 1
		else
			return 0
		end
	end

	Error("Tried to compare a " .. ltype .. " with a " .. rtype .. "not ")
end

--- Returns absolute value of <q>
function quat_lib.abs(q)
	return sqrt(q[1]*q[1] + q[2]*q[2] + q[3]*q[3] + q[4]*q[4])
end

--- Returns the conjugate of <q>
function quat_lib.conj(q)
	return quicknew(q[1], -q[2], -q[3], -q[4])
end

--- Returns the inverse of <q>
function quat_lib.inv(q)
	local l = q[1]*q[1] + q[2]*q[2] + q[3]*q[3] + q[4]*q[4]
	return quicknew( q[1]/l, -q[2]/l, -q[3]/l, -q[4]/l )
end

--- Returns the conj of self
function quat_methods:conj()
	return quat_lib.conj( self )
end

function quat_methods:inv()
	return quat_lib.inv( self )
end

--- Returns the real component of the quaternion
function quat_methods:real()
	return self[1]
end

--- Alias for :real() as r is easier
function quat_methods:r()
	return self:real()
end


--- Returns the i component of the quaternion
function quat_methods:i()
	return self[2]
end

--- Returns the j component of the quaternion
function quat_methods:j()
	return self[3]
end

--- Returns the k component of the quaternion
function quat_methods:k()
	return self[4]
end

--[[****************************************************************************]]

--- Raises Euler's constant e to the power <q>
function quat_lib.exp(q)
	return qexp(q)
end

--- Calculates natural logarithm of <q>
function quat_lib.log(q)
	return qlog(q)
end

--- Changes quaternion <q> so that the represented rotation is by an angle between 0 and 180 degrees (by coder0xff)
function quat_lib.qMod(q)
	if q[1]<0 then return quicknew(-q[1], -q[2], -q[3], -q[4]) else return quicknew(q[1], q[2], q[3], q[4]) end
end

--- Performs spherical linear interpolation between <q0> and <q1>. Returns <q0> for <t>=0, <q1> for <t>=1
function quat_lib.slerp(q0, q1, t)
	local dot = q0[1]*q1[1] + q0[2]*q1[2] + q0[3]*q1[3] + q0[4]*q1[4]
	local q11
	if dot<0 then
		q11 = {-q1[1], -q1[2], -q1[3], -q1[4]}
	else
		q11 = { q1[1], q1[2], q1[3], q1[4] }  -- dunno if just q11 = q1 works
	end

	local l = q0[1]*q0[1] + q0[2]*q0[2] + q0[3]*q0[3] + q0[4]*q0[4]

	if l==0 then return quicknew( 0, 0, 0, 0 ) end

	local invq0 = { q0[1]/l, -q0[2]/l, -q0[3]/l, -q0[4]/l }
	local logq = qlog(qmul(invq0,q11))
	local q = qexp( { logq[1]*t, logq[2]*t, logq[3]*t, logq[4]*t } )

	return qmul(q0,q)
end

--[[****************************************************************************]]

--- Returns vector pointing forward for <this>
function quat_methods:forward()
	local this1, this2, this3, this4 = self[1], self[2], self[3], self[4]
	local t2, t3, t4 = this2 * 2, this3 * 2, this4 * 2

	return vwrap( Vector(
	this1 * this1 + this2 * this2 - this3 * this3 - this4 * this4,
	t3 * this2 + t4 * this1,
	t4 * this2 - t3 * this1
	) )
end

--- Returns vector pointing right for <this>
function quat_methods:right()
	local this1, this2, this3, this4 = self[1], self[2], self[3], self[4]
	local t2, t3, t4 = this2 * 2, this3 * 2, this4 * 2

	return vwrap( Vector(
	t4 * this1 - t2 * this3,
	this2 * this2 - this1 * this1 + this4 * this4 - this3 * this3,
	- t2 * this1 - t3 * this4
	) )
end

--- Returns vector pointing up for <this>
function quat_methods:up()
	local this1, this2, this3, this4 = self[1], self[2], self[3], self[4]
	local t2, t3, t4 = this2 * 2, this3 * 2, this4 * 2

	return vwrap( Vector(
	t3 * this1 + t2 * this4,
	t3 * this4 - t2 * this1,
	this1 * this1 - this2 * this2 - this3 * this3 + this4 * this4
	) )
end

--[[****************************************************************************]]

--- Returns quaternion for rotation about axis <axis> by angle <ang>
function quat_lib.qRotation(axis, ang)
	local ax = axis
	ax:Normalize()
	local ang2 = ang*deg2rad*0.5

	return quicknew( cos(ang2), ax.x*sin(ang2), ax.y*sin(ang2), ax.z*sin(ang2) )
end

--- Construct a quaternion from the rotation vector <rv1>. Vector direction is axis of rotation, magnitude is angle in degress (by coder0xff)
function quat_lib.qRotation(rv1)
	local angSquared = rv1.x * rv1.x + rv1.y * rv1.y + rv1.z * rv1.z

	if angSquared == 0 then return quicknew( 1, 0, 0, 0 ) end

	local len = sqrt(angSquared)
	local ang = (len + 180) % 360 - 180
	local ang2 = ang*deg2rad*0.5
	local sang2len = sin(ang2) / len

	return quicknew( cos(ang2), rv1.x * sang2len , rv1.y * sang2len, rv1.z * sang2len )
end

--- Returns the angle of rotation in degrees (by coder0xff)
function quat_lib.rotationAngle(q)
	local l2 = q[1]*q[1] + q[2]*q[2] + q[3]*q[3] + q[4]*q[4]

	if l2 == 0 then return 0 end

	local l = sqrt(l2)
	local ang = 2*acos(math.Clamp(q[1]/l, -1, 1))*rad2deg  --this returns angle from 0 to 360

	if ang > 180 then ang = ang - 360 end  -- make it -180 - 180

	return ang
end

--- Returns the axis of rotation (by coder0xff)
function quat_lib.rotationAxis(q)
	local m2 = q[2] * q[2] + q[3] * q[3] + q[4] * q[4]

	if m2 == 0 then return vwrap( Vector( 0, 0, 1 ) ) end

	local m = sqrt(m2)
	return vwrap( Vector( q[ 2 ] / m, q[ 3 ] / m, q[ 4 ] / m ) )
end

--- Returns the rotation vector - rotation axis where magnitude is the angle of rotation in degress (by coder0xff)
function quat_lib.rotationVector(q)
	SF.CheckType( q, quat_metamethods )
	local l2 = q[1]*q[1] + q[2]*q[2] + q[3]*q[3] + q[4]*q[4]
	local m2 = math.max( q[2]*q[2] + q[3]*q[3] + q[4]*q[4], 0 )

	if l2 == 0 or m2 == 0 then return vwrap( Vector( 0, 0, 0 ) ) end

	local s = 2 * acos( math.Clamp( q[1] / sqrt(l2), -1, 1 ) ) * rad2deg

	if s > 180 then s = s - 360 end

	s = s / sqrt(m2)
	return vwrap( Vector( q[ 2 ] * s, q[ 3 ] * s, q[ 4 ] * s ) )
end

--[[****************************************************************************]]

--- Converts <q> to a vector by dropping the real component
function quat_lib.vec(q)
	return vwrap( Vector( q[ 2 ], q[ 3 ], q[ 4 ] ) )
end

--[[****************************************************************************]]
