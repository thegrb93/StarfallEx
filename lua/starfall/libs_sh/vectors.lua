SF.Vectors = {}

--- Vector type
-- @shared
local vec_methods, vec_metamethods = SF.Typedef( "Vector" )

local function wrap( tbl )
	return setmetatable( tbl, vec_metamethods )
end

local function unwrap( obj )
	return Vector( obj[1], obj[2], obj[3] )
end

local function vwrap( vec )
	return wrap( { vec.x, vec.y, vec.z } )
end

SF.AddObjectWrapper( debug.getregistry().Vector, vec_metamethods, vwrap )
SF.AddObjectUnwrapper( vec_metamethods, unwrap )

SF.DefaultEnvironment.Vector = function ( x, y, z )
	return wrap( { x or 0, y or 0, z or 0 } )
end

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
function vec_metamethods.__newindex ( t, k, v )
	if xyz[ k ] then
		rawset( t, xyz[ k ], v )
	else
		rawset( t, k, v )
	end
end

local _p = vec_metamethods.__methods

--- __index metamethod
function vec_metamethods.__index ( t, k )
	if xyz[ k ] then
		return rawget( t, xyz[ k ] )
	else
		return _p[k]
	end
end

local table_concat = table.concat

--- tostring metamethod
-- @return string representing the vector.
function vec_metamethods.__tostring ( a )
	return table_concat( a, ' ', 1, 3 )
end

--- multiplication metamethod
-- @param lhs Left side of equation
-- @param rhs Right side of equation
-- @return Scaled vector.
function vec_metamethods.__mul ( a, b )
	if dgetmeta( a ) == vec_metamethods then
		if dgetmeta( b ) == vec_metamethods then
			return wrap( { a[1]*b[1], a[2]*b[2], a[3]*b[3] } )
		end

		SF.CheckType( b, "number" )
		return wrap( { a[1]*b, a[2]*b, a[3]*b } )
	else
		SF.CheckType( a, "number" )
		return wrap( { b[1]*a, b[2]*a, b[3]*a } )
	end
end

--- division metamethod
-- @param n Scalar to divide the Vector by
-- @return Scaled vector.
function vec_metamethods.__div ( a, n )
	SF.CheckType( a, vec_metamethods )
	SF.CheckType( n, "number" )

	return wrap( { a[1]/n, a[2]/n, a[3]/n } )
end

--- add metamethod
-- @param v Vector to add
-- @return Resultant vector after addition operation.
function vec_metamethods.__add ( a, b )
	SF.CheckType( a, vec_metamethods )
	SF.CheckType( b, vec_metamethods )

	return wrap( { a[1]+b[1], a[2]+b[2], a[3]+b[3] } )
end

--- sub metamethod
-- @param v Vector to subtract
-- @return Resultant vector after subtraction operation.
function vec_metamethods.__sub ( a, b )
	SF.CheckType( a, vec_metamethods )
	SF.CheckType( b, vec_metamethods )

	return wrap( { a[1]-b[1], a[2]-b[2], a[3]-b[3] } )
end

--- unary minus metamethod
-- @return negated vector.
function vec_metamethods.__unm ( a )
	SF.CheckType( a, vec_metamethods )
	return wrap( { -a[1], -a[2], -a[3] } )
end

--- equivalence metamethod
-- @return bool if both sides are equal.
function vec_metamethods.__eq ( a, b )
	if dgetmeta(a) ~= vec_metamethods then return false end
	if dgetmeta(b) ~= vec_metamethods then return false end

	if #a ~= #b then return false end

	for k, v in pairs( a ) do
		if v ~= b[k] then return false end
	end

	return true
end

--- Add vector - Modifies self.
-- @param v Vector to add
-- @return nil
function vec_methods.add ( a, v )
	SF.CheckType( v, vec_metamethods )

	a[1] = a[1] + v[1]
	a[2] = a[2] + v[2]
	a[3] = a[3] + v[3]
end

--- Get the vector's angle.
-- @return Angle
function vec_methods.getAngle ( a )
	return SF.WrapObject( unwrap( a ):Angle() )
end

--- Returns the Angle between two vectors.
-- @param v Second Vector
-- @return Angle
function vec_methods.getAngleEx ( a, v )
	SF.CheckType( v, vec_metamethods )

	return SF.WrapObject( unwrap( a ):AngleEx( unwrap( v ) ) )
end

--- Calculates the cross product of the 2 vectors, creates a unique perpendicular vector to both input vectors.
-- @param v Second Vector
-- @return Vector
function vec_methods.cross ( a, v )
	SF.CheckType( v, vec_metamethods )

	return wrap( unwrap( a ):Cross( unwrap( v ) ) )
end

local math_sqrt = math.sqrt

--- Returns the pythagorean distance between the vector and the other vector.
-- @param v Second Vector
-- @return Number
function vec_methods.getDistance ( a, v )
	SF.CheckType( v, vec_metamethods )

	return math_sqrt( (v[1]-a[1])^2 + (v[2]-a[2])^2 + (v[3]-a[3])^2 )
end

--- Returns the squared distance of 2 vectors, this is faster Vector:getDistance as calculating the square root is an expensive process.
-- @param v Second Vector
-- @return Number
function vec_methods.getDistanceSqr ( a, v )
	SF.CheckType( v, vec_metamethods )

	return ((v[1]-a[1])^2 + (v[2]-a[2])^2 + (v[3]-a[3])^2)
end

--- Dot product is the cosine of the angle between both vectors multiplied by their lengths. A.B = ||A||||B||cosA.
-- @param v Second Vector
-- @return Number
function vec_methods.dot ( a, v )
	SF.CheckType( v, vec_metamethods )

	return ( a[1]*v[1] + a[2]*v[2] + a[3]*v[3] )
end

--- Returns a new vector with the same direction by length of 1.
-- @return Vector Normalised
function vec_methods.getNormalized ( a )
	local len = math_sqrt( a[1]^2 + a[2]^2 + a[3]^2 )

	return wrap( { a[1] / len, a[2] / len, a[3] / len } )
end

--- Is this vector and v equal within tolerance t.
-- @param v Second Vector
-- @param t Tolerance number.
-- @return bool True/False.
function vec_methods.isEqualTol ( a, v, t )
	SF.CheckType( v, vec_metamethods )
	SF.CheckType( t, "number" )

	return unwrap( a ):IsEqualTol( unwrap( v ), t )
end

--- Are all fields zero.
-- @return bool True/False
function vec_methods.isZero ( a )
	if a[1] ~= 0 then return false
	elseif a[2] ~= 0 then return false
	elseif a[3] ~= 0 then return false
	end

	return true
end

--- Get the vector's Length.
-- @return number Length.
function vec_methods.getLength ( a )
	return math_sqrt( a[1]^2 + a[2]^2 + a[3]^2 )
end

--- Get the vector's length squared ( Saves computation by skipping the square root ).
-- @return number length squared.
function vec_methods.getLengthSqr ( a )
	return ( a[1]^2 + a[2]^2 + a[3]^2 )
end

--- Returns the length of the vector in two dimensions, without the Z axis.
-- @return number length
function vec_methods.getLength2D ( a )
	return math_sqrt( a[1]^2 + a[2]^2 )
end

--- Returns the length squared of the vector in two dimensions, without the Z axis. ( Saves computation by skipping the square root )
-- @return number length squared.
function vec_methods.getLength2DSqr ( a )
	return ( a[1]^2 + a[2]^2 )
end

--- Scalar Multiplication of the vector. Self-Modifies.
-- @param n Scalar to multiply with.
-- @return nil
function vec_methods.mul ( a, n )
	SF.CheckType( n, "number" )

	a[1] = a[1] * n
	a[2] = a[2] * n
	a[3] = a[3] * n
end

--- "Scalar Division" of the vector. Self-Modifies.
-- @param n Scalar to divide by.
-- @return nil
function vec_methods.div ( a, n )
	SF.CheckType( n, "number" )

	a[1] = a[1] / n
	a[2] = a[2] / n
	a[3] = a[3] / n
end

--- Multiply self with a Vector. Self-Modifies. ( convenience function )
-- @param v Vector to multiply with
function vec_methods.vmul ( a, v )
	SF.CheckType( v, vec_metamethods )

	a[1] = a[1] * v[1]
	a[2] = a[2] * v[2]
	a[3] = a[3] * v[3]
end

--- Divide self by a Vector. Self-Modifies. ( convenience function )
-- @param v Vector to divide by
function vec_methods.vdiv ( a, v )
	SF.CheckType( v, vec_metamethods )

	a[1] = a[1] / v[1]
	a[2] = a[2] / v[2]
	a[3] = a[3] / v[3]
end

--- Set's all vector fields to 0.
-- @return nil
function vec_methods.setZero ( a )
	a[1] = 0
	a[2] = 0
	a[3] = 0
end

--- Normalise the vector, same direction, length 1. Self-Modifies.
-- @return nil
function vec_methods.normalize ( a )
	local len = math_sqrt( a[1]^2 + a[2]^2 + a[3]^2 )

	a[1] = a[1] / len
	a[2] = a[2] / len
	a[3] = a[3] / len
end

--- Rotate the vector by Angle a. Self-Modifies.
-- @param a Angle to rotate by.
-- @return nil.
function vec_methods.rotate ( a, b )
	SF.CheckType( b, SF.Types[ "Angle" ] )

	local vec = unwrap( a )
	vec:Rotate( SF.UnwrapObject( b ) )

	a[1] = vec.x
	a[2] = vec.y
	a[3] = vec.z
end

--- Return rotated vector by an axis
-- @param axis Axis the rotate around
-- @param degrees Angle to rotate by in degrees or nil if radians.
-- @param radians Angle to rotate by in radians or nil if degrees.
-- @return Rotated vector
function vec_methods.rotateAroundAxis( a, axis, degrees, radians )
	SF.CheckType( axis, vec_metamethods )

	if degrees then
		SF.CheckType( degrees, "number" )
		radians = math.rad(degrees)
	else
		SF.CheckType( radians, "number" )
	end

	local ca, sa = math.cos(radians), math.sin(radians)
	local x,y,z,x2,y2,z2 = axis[1], axis[2], axis[3], a[1], a[2], a[3]
	local length = (x*x+y*y+z*z)^0.5
	x,y,z = x/length, y/length, z/length

	return wrap( { (ca + (x^2)*(1-ca)) * x2 + (x*y*(1-ca) - z*sa) * y2 + (x*z*(1-ca) + y*sa) * z2,
			(y*x*(1-ca) + z*sa) * x2 + (ca + (y^2)*(1-ca)) * y2 + (y*z*(1-ca) - x*sa) * z2,
			(z*x*(1-ca) - y*sa) * x2 + (z*y*(1-ca) + x*sa) * y2 + (ca + (z^2)*(1-ca)) * z2 } )
end

--- Copies the values from the second vector to the first vector. Self-Modifies.
-- @param v Second Vector
-- @return nil
function vec_methods.set ( a, v )
	SF.CheckType( v, vec_metamethods )

	a[1] = v[1]
	a[2] = v[2]
	a[3] = v[3]
end

--- Subtract v from this Vector. Self-Modifies.
-- @param v Second Vector.
-- @return nil
function vec_methods.sub ( a, v )
	SF.CheckType( v, vec_metamethods )

	a[1] = a[1] - v[1]
	a[2] = a[2] - v[2]
	a[3] = a[3] - v[3]
end

--- Translates the vectors position into 2D user screen coordinates. Self-Modifies.
-- @return nil
function vec_methods.toScreen ( a )
	return unwrap( a ):ToScreen()
end

--- Returns whenever the given vector is in a box created by the 2 other vectors.
-- @param v1 Vector used to define AABox
-- @param v2 Second Vector to define AABox
-- @return bool True/False.
function vec_methods.withinAABox ( a, v1, v2 )
	SF.CheckType( v1, vec_metamethods )
	SF.CheckType( v2, vec_metamethods )

	if a[1] < v1[1] or a[1] > v2[1] then return false end
	if a[2] < v1[2] or a[2] > v2[2] then return false end
	if a[3] < v1[3] or a[3] > v2[3] then return false end

	return true
end
