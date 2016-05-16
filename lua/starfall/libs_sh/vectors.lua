SF.Vectors = {}

--- Vector type
-- @shared

local vec_methods, vec_metamethods = SF.Typedef( "Vector" )

local function wrap_vector( table )
	for i=1, 3 do if type( table[i] ) ~= "number" then table[i] = 0 end end
	return setmetatable( table, vec_metamethods )
end

local function unwrap_vector( obj )
	return Vector( (obj[1] or 0), (obj[2] or 0), (obj[3] or 0) )
end

local wrap, unwrap = wrap_vector, unwrap_vector

SF.DefaultEnvironment.Vector = function ( ... )
	return wrap( { ... } )
end

SF.Vectors.Wrap = wrap
SF.Vectors.Unwrap = unwrap
SF.Vectors.Methods = vec_methods
SF.Vectors.Metatable = vec_metamethods
SF.Vectors.Verbose = verbose

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
		return _p[ k ]
	end
end

--- tostring metamethod
-- @return string representing the vector.
function vec_metamethods:__tostring ()
	return "[" .. tostring( self.x ) .. ", " .. tostring( self.y ) .. ", " ..
		tostring( self.z ) .. "]"
end

--- multiplication metamethod
-- @param lhs Left side of equation
-- @param rhs Right side of equation
-- @return Scaled vector.
function vec_metamethods.__mul ( lhs, rhs )
	if dgetmeta( lhs ) == vec_metamethods then
		if dgetmeta( rhs ) == vec_metamethods then
			return wrap( { lhs[1] * rhs[1], lhs[2] * rhs[2],
				lhs[3] * rhs[3] } )
		end

		SF.CheckType( rhs, "number" )
		return wrap( { lhs[1] * rhs, lhs[2] * rhs, lhs[3] * rhs } )
	else
		if dgetmeta( lhs ) == vec_metamethods then
			return wrap( { lhs[1] * rhs[1], lhs[2] * rhs[2],
				lhs[3] * rhs[3] } )
		end

		SF.CheckType( lhs, "number" )
		return wrap( unwrap( rhs ) * lhs )
	end
end

--- division metamethod
-- @param n Scalar to divide the Vector by
-- @return Scaled vector.
function vec_metamethods:__div ( rhs )
	SF.CheckType( self, vec_metamethods )
	SF.CheckType( rhs, "number" )

	return wrap( { self[1] / rhs, self[2] / rhs, self[3] / rhs } )
end

--- add metamethod
-- @param v Vector to add
-- @return Resultant vector after addition operation.
function vec_metamethods:__add ( rhs )
	SF.CheckType( self, vec_metamethods )
	SF.CheckType( rhs, vec_metamethods )

	return wrap( { self[1] + rhs[1], self[2] + rhs[2], self[3] + rhs[3] } )
end

--- sub metamethod
-- @param v Vector to subtract
-- @return Resultant vector after subtraction operation.
function vec_metamethods:__sub ( rhs )
	SF.CheckType( self, vec_metamethods )
	SF.CheckType( rhs, vec_metamethods )

	return wrap( { self[1] - rhs[1], self[2] - rhs[2], self[3] - rhs[3] } )
end

--- unary minus metamethod
-- @return negated vector.
function vec_metamethods:__unm ()
	SF.CheckType( self, vec_metamethods )

	return wrap( { self[1] * -1, self[2] * -1, self[3] * -1 } )
end

--- equivalence metamethod
-- @return bool if both sides are equal.
function vec_metamethods:__eq ( rhs )
	SF.CheckType( self, vec_metamethods )
	SF.CheckType( rhs, vec_metamethods )

	if #rhs ~= #self then return false end

	for k, v in pairs( rhs ) do
		if v ~= self[k] then return false end
	end

	return true
end

--- Add vector - Modifies self.
-- @param v Vector to add
-- @return nil
function vec_methods:add ( v )
	SF.CheckType( v, vec_metamethods )

	for k, p in pairs( self ) do
		self[k] = p + v[k]
	end
end

--- Get the vector's angle.
-- @return Angle
function vec_methods:getAngle ()
	return SF.WrapObject( unwrap( self ):Angle() )
end

--- Returns the Angle between two vectors.
-- @param v Second Vector
-- @return Angle
function vec_methods:getAngleEx ( v )
	SF.CheckType( v, vec_metamethods )
	return SF.WrapObject( unwrap( self ):AngleEx( unwrap( v ) ) )
end

--- Calculates the cross product of the 2 vectors, creates a unique perpendicular vector to both input vectors.
-- @param v Second Vector
-- @return Vector
function vec_methods:cross ( v )
	SF.CheckType( v, vec_metamethods )
	return wrap( unwrap( self ):Cross( unwrap( v ) ) )
end

--- Returns the pythagorean distance between the vector and the other vector.
-- @param v Second Vector
-- @return Number
function vec_methods:getDistance ( v )
	SF.CheckType( v, vec_metamethods )
	return unwrap( self ):Distance( unwrap( v ) )
end

--- Returns the squared distance of 2 vectors, this is faster Vector:getDistance as calculating the square root is an expensive process.
-- @param v Second Vector
-- @return Number
function vec_methods:getDistanceSqr ( v )
	SF.CheckType( v, vec_metamethods )
	return unwrap( self ):DistToSqr( unwrap( v ) )
end

--- Dot product is the cosine of the angle between both vectors multiplied by their lengths. A.B = ||A||||B||cosA.
-- @param v Second Vector
-- @return Number
function vec_methods:dot ( v )
	SF.CheckType( v, vec_metamethods )
	return unwrap( self ):Dot( unwrap( v ) )
end

--- Returns a new vector with the same direction by length of 1.
-- @return Vector Normalised
function vec_methods:getNormalized ()
	return wrap( unwrap( self ):GetNormalized() )
end

--- Is this vector and v equal within tolerance t.
-- @param v Second Vector
-- @param t Tolerance number.
-- @return bool True/False.
function vec_methods:isEqualTol ( v, t )
	SF.CheckType( v, vec_metamethods )
	SF.CheckType( t, "number" )
	return unwrap( self ):IsEqualTol( unwrap( v ), t )
end

--- Are all fields zero.
-- @return bool True/False
function vec_methods:isZero ()
	return unwrap( self ):IsZero()
end

--- Get the vector's Length.
-- @return number Length.
function vec_methods:getLength ()
	return unwrap( self ):Length()
end

--- Get the vector's length squared ( Saves computation by skipping the square root ).
-- @return number length squared.
function vec_methods:getLengthSqr ()
	return unwrap( self ):LengthSqr()
end

--- Returns the length of the vector in two dimensions, without the Z axis.
-- @return number length
function vec_methods:getLength2D ()
	return unwrap( self ):Length2D()
end

--- Returns the length squared of the vector in two dimensions, without the Z axis. ( Saves computation by skipping the square root )
-- @return number length squared.
function vec_methods:getLength2DSqr ()
	return unwrap( self ):Length2DSqr()
end

--- Scalar Multiplication of the vector. Self-Modifies.
-- @param n Scalar to multiply with.
-- @return nil
function vec_methods:mul ( n )
	SF.CheckType( n, "number" )

	for k, p in pairs( self ) do
		self[k] = p * n
	end
end

--- Scalar Division of the vector. Self-Modifies.
-- @param n Scalar to divide by.
-- @return nil
function vec_methods:div ( n )
	SF.CheckType( n, "number" )

	for k, p in pairs( self ) do
		self[k] = p / n
	end
end

--- Set's all vector fields to 0.
-- @return nil
function vec_methods:setZero ()
	unwrap( self ):Zero()
end

--- Normalise the vector, same direction, length 1. Self-Modifies.
-- @return nil
function vec_methods:normalize ()
	unwrap( self ):Normalize()
end

--- Rotate the vector by Angle a. Self-Modifies.
-- @param a Angle to rotate by.
-- @return nil.
function vec_methods:rotate ( a )
	SF.CheckType( a, SF.Types[ "Angle" ] )
	unwrap( self ):Rotate( SF.UnwrapObject( a ) )
end

--- Return rotated vector by an axis
-- @param axis Axis the rotate around
-- @param degrees Angle to rotate by in degrees or nil if radians.
-- @param radians Angle to rotate by in radians or nil if degrees.
-- @return Rotated vector
function vec_methods:rotateAroundAxis(axis, degrees, radians)
	SF.CheckType( self, vec_metamethods )
	SF.CheckType( axis, vec_metamethods )

	if degrees then
		SF.CheckType( degrees, "number" )
		radians = math.rad(degrees)
	else
		SF.CheckType( radians, "number" )
	end

	local ca, sa = math.cos(radians), math.sin(radians)
	local x,y,z,x2,y2,z2 = axis.x, axis.y, axis.z, self.x, self.y, self.z
	local length = (x*x+y*y+z*z)^0.5
	x,y,z = x/length, y/length, z/length

	return wrap( Vector((ca + (x^2)*(1-ca)) * x2 + (x*y*(1-ca) - z*sa) * y2 + (x*z*(1-ca) + y*sa) * z2,
			(y*x*(1-ca) + z*sa) * x2 + (ca + (y^2)*(1-ca)) * y2 + (y*z*(1-ca) - x*sa) * z2,
			(z*x*(1-ca) - y*sa) * x2 + (z*y*(1-ca) + x*sa) * y2 + (ca + (z^2)*(1-ca)) * z2) )
end

--- Copies the values from the second vector to the first vector. Self-Modifies.
-- @param v Second Vector
-- @return nil
function vec_methods:set( v )
	SF.CheckType( v, vec_metamethods )

	for k, p in pairs( self ) do
		self[k] = v[k]
	end
end

--- Subtract v from this Vector. Self-Modifies.
-- @param v Second Vector.
-- @return nil
function vec_methods:sub ( v )
	SF.CheckType( v, vec_metamethods )

	for k, p in pairs( self ) do
		self[k] = p - v[k]
	end
end

--- Translates the vectors position into 2D user screen coordinates. Self-Modifies.
-- @return nil
function vec_methods:toScreen ()
	return unwrap( self ):ToScreen()
end

--- Returns whenever the given vector is in a box created by the 2 other vectors.
-- @param v1 Vector used to define AABox
-- @param v2 Second Vector to define AABox
-- @return bool True/False.
function vec_methods:withinAABox ( v1, v2 )
	SF.CheckType( v1, vec_metamethods )
	SF.CheckType( v2, vec_metamethods )
	return unwrap( self ):WithinAABox( unwrap( v1 ), unwrap( v2 ) )
end
