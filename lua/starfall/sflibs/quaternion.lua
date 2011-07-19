
-- Module
local quat_module = {}

-- Quaternion metatable
local quaternion = {}
quaternion.__index = quaternion
quaternion.type = "Quaternion"

-- Convenience functions
local sin = math.sin
local cos = math.cos
local nlog = math.log
local exp = math.exp
local abs = math.abs
local sqrt = math.sqrt
local deg2rad = math.pi/180
local rad2deg = 180/math.pi

local function newQuat(r, i, j, k)
	local q = setmetatable({},quaternion)
	q.r = r
	q.i = i
	q.j = j
	q.k = k
	return q
end

--------------------------------- Module Functions ---------------------------------

-- Constructor
function quat_module.Quaternion(r, i, j, k)
	if r == nil then r = 0 end -- So that Quaternion() = {0,0,0,0}
	
	local typ = type(r)
	
	if typ == "number" then
		i = SF_Compiler.CheckType(i or 0, "number")
		j = SF_Compiler.CheckType(j or 0, "number")
		k = SF_Compiler.CheckType(k or 0, "number")
		return newQuat(r,i,j,k)
	elseif typ == "Vector" then
		return newQuat(0,r.x,r.y,r.z)
	elseif SF_Entities.IsWrappedEntity(r) then
		return quat_module.Quaternion(r:GetAngles())
	elseif typ == "Angle" then
		local p = r.p * deg2rad * 0.5
		local y = r.y * deg2rad * 0.5
		local r = r.r * deg2rad * 0.5
		
		local qr = newQuat(cos(r),sin(r),0,0)
		local qp = newQuat(cos(p),0,sin(p),0)
		local qy = newQuat(cos(y),0,0,sin(y))
		return qy*(qp*qr)
	else
		SF_Compiler.ThrowTypeError(r,"one of (number(s),Vector,Entity,Angle)")
	end
end

--------------------------------- Operations ---------------------------------

-- Unary Minus
function quaternion:__unm()
	return newQuat(-self.r, -self.i, -self.j, -self.k)
end

-- Multiplication
function quaternion.__mul(op1, op2)
	SF_Compiler.CheckType(op1,quaternion)
	SF_Compiler.CheckType(op2,quaternion)
	
	-- The fun part
	return newQuat(
		op1.r * op2.r - op1.i * op2.i - op1.j * op2.j - op1.k * op2.k,
		op1.r * op2.i + op1.i * op2.r + selk.j * op2.k - op1.k * op2.j,
		op1.r * op2.j + op1.j * op2.r + op1.k * op2.i - op1.i * op2.k,
		op1.r * op2.k + op1.k * op2.r + op1.i * op2.j - op1.j * op2.i
	)
end

-- Division
function quaternion.__div(op1, op2)
	SF_Compiler.CheckType(op1,quaternion)
	SF_Compiler.CheckType(op2,quaternion)

	local l = op2.r*op2.r + op2.i*op2.i + op2.j*op2.j + op2.k*rhs
	return newQuat(
		( op1.r * op2.r + op1.i * op2.i + op1.j * op2.j + op1.k * op2.k)/l,
		(-op1.r * op2.i + op1.i * op2.r - op1.j * op2.k + op1.k * op2.j)/l,
		(-op1.r * op2.j + op1.j * op2.r - op1.k * op2.i + op1.i * op2.k)/l,
		(-op1.r * op2.k + op1.k * op2.r - op1.i * op2.j + op1.j * op2.i)/l
	)
end

function quaternion:__tostring()
	return string.format("(%f+%fi+%fj+%fk)",self.r,self.i,self.j,self.k)
end

--------------------------------- Methods ---------------------------------

function quaternion:clone()
	return newQuat(self.r, self.i, self.j, self.k)
end

function quaternion:abs()
	return sqrt(self.r*self.r + self.i*self.i + self.j*self.k + self.k*self.k)
end

function quaternion:abs2()
	return self.r*self.r + self.i*self.i + self.j*self.k + self.k*self.k
end

function quaternion:conj()
	return newQuat(self.r, -self.i, -self.j, -self.k)
end

function quaternion:inv()
	local l = self:abs2()
	return newQuat(self.r/l, -self.i/l, -self.j/l, -self.k/l)
end

function quaternion:log()
	local l = self:abs()
	if l == 0 then return { -1e+100, 0, 0, 0 } end
	local u = newQuat( self.r/l, self.i/l, self.j/l, self.k/l )
	local a = acos(u.r)
	u.r = 0
	local m = u:abs()
	if abs(m) > delta then
		return newQuat( nlog(l), a*u.i/m, a*u.j/m, a*u.k/m )
	else
		return newQuat( nlog(l), 0, 0, 0 )  --when m is 0, u[2], u[3] and u[4] are 0 too
	end
end

function quaternion:exp()
	local m = sqrt(self.i*self.i + self.j*self.j + self.k*self.k)
	local u
	if m ~= 0 then
		u = { self.i*sin(m)/m, self.j*sin(m)/m, self.k*sin(m)/m }
	else
		u = { 0, 0, 0 }
	end
	local r = exp(self.r)
	return { r*cos(m), r*u[1], r*u[2], r*u[3] }
end

function quat_module.slerp(op1, op2, value)
	SF_Compiler.CheckType(op1,quaternion)
	SF_Compiler.CheckType(op1,quaternion)
	SF_Compiler.CheckType(value,"number")
	
	local dot = op1.r*op2.r + op1.i*op2.i + op1.j*op2.j + op1.k*op2.k
	local q11
	if dot<0 then
		q11 = -op1
	else
		q11 = op1
	end
	
	local invop1 = op1:inv()
	local log = (invop1*q11):log()
	local q = newQuat(log.r*value, log.i*value, log.j*value, log.k*value):exp()
	return op1*q
end

function quaternion:toVector()
	return Vector(self.i, self.j, self.k)
end

function quaternion:toAngle()
	local l = self:abs()
	local q1, q2, q3, q4 = self.r/l, self.i/l, self.j/l, self.k/l
	
	local x = Vector(q1*q1 + q2*q2 - q3*q3 - q4*q4,
		2*q3*q2 + 2*q4*q1,
		2*q4*q2 - 2*q3*q1)
		
	local y = Vector(2*q2*q3 - 2*q4*q1,
		q1*q1 - q2*q2 + q3*q3 - q4*q4,
		2*q2*q1 + 2*q3*q4)
		
	local ang = x:Angle()
	if ang.p > 180 then ang.p = ang.p - 360 end
	if ang.y > 180 then ang.y = ang.y - 360 end
	
	local yyaw = Vector(0,1,0)
	yyaw:Rotate(Angle(0,ang.y,0))
	
	local roll = acos(y:Dot(yyaw))*rad2deg
	
	local dot = q2*q1 + q3*q4
	if dot < 0 then roll = -roll end
	
	return Angle(ang.p, ang.y, roll)
end