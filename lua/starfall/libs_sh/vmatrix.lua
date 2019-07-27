-- Credits to Radon & Xandaros
SF.VMatrix = {}

--- VMatrix type
local vmatrix_methods, vmatrix_metamethods = SF.RegisterType("VMatrix")
local wrap, unwrap = SF.CreateWrapper(vmatrix_metamethods, true, false, debug.getregistry().VMatrix)
local vec_meta, vwrap, vunwrap, ang_meta, awrap, aunwrap

local dgetmeta = debug.getmetatable
local checktype = SF.CheckType
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check

SF.AddHook("postload", function()
	vec_meta = SF.Vectors.Metatable
	vwrap = SF.Vectors.Wrap
	vunwrap = SF.Vectors.Unwrap

	ang_meta = SF.Angles.Metatable
	awrap = SF.Angles.Wrap
	aunwrap = SF.Angles.Unwrap

	--- Returns a new VMatrix
	-- @return New VMatrix
	SF.DefaultEnvironment.Matrix = function (t)
		return wrap(Matrix(t))
	end
end)

SF.VMatrix.Methods = vmatrix_methods
SF.VMatrix.Metatable = vmatrix_metamethods
SF.VMatrix.Wrap = wrap
SF.VMatrix.Unwrap = unwrap

--- tostring metamethod
-- @return string representing the matrix.
function vmatrix_metamethods:__tostring()
	return unwrap(self):__tostring()
end

--- Returns angles
-- @return Angles
function vmatrix_methods:getAngles()
	return awrap(unwrap(self):GetAngles())
end

--- Returns scale
-- @return Scale
function vmatrix_methods:getScale()
	return vwrap(unwrap(self):GetScale())
end

--- Returns translation
-- @return Translation
function vmatrix_methods:getTranslation()
	return vwrap(unwrap(self):GetTranslation())
end

--- Returns a specific field in the matrix
-- @param row A number from 1 to 4
-- @param column A number from 1 to 4
-- @return Value of the specified field
function vmatrix_methods:getField(row, column)
	return unwrap(self):GetField(row, column)
end

--- Rotate the matrix
-- @param ang Angle to rotate by
function vmatrix_methods:rotate(ang)
	checktype(ang, ang_meta)
	unwrap(self):Rotate(aunwrap(ang))
end

--- Returns an inverted matrix. Inverting the matrix will fail if its determinant is 0 or close to 0
-- @return Inverted matrix
function vmatrix_methods:getInverse()
	return wrap(unwrap(self):GetInverse())
end

--- Returns an inverted matrix. Efficiently for translations and rotations
-- @return Inverted matrix
function vmatrix_methods:getInverseTR()
	return wrap(unwrap(self):GetInverseTR())
end

--- Returns forward vector of matrix. First matrix column
-- @return Translation
function vmatrix_methods:getForward()
	return vwrap(unwrap(self):GetForward())
end

--- Returns right vector of matrix. Negated second matrix column
-- @return Translation
function vmatrix_methods:getRight()
	return vwrap(unwrap(self):GetRight())
end

--- Returns up vector of matrix. Third matrix column
-- @return Translation
function vmatrix_methods:getUp()
	return vwrap(unwrap(self):GetUp())
end

--- Sets the scale
-- @param vec New scale
function vmatrix_methods:setScale(vec)
	checktype(vec, vec_meta)
	unwrap(self):SetScale(vunwrap(vec))
end

--- Scale the matrix
-- @param vec Vector to scale by
function vmatrix_methods:scale(vec)
	checktype(vec, vec_meta)
	unwrap(self):Scale(vunwrap(vec))
end

--- Scales the absolute translation
-- @param num Amount to scale by
function vmatrix_methods:scaleTranslation(num)
	checkluatype (num, TYPE_NUMBER)
	unwrap(self):ScaleTranslation(num)
end

--- Sets the angles
-- @param ang New angles
function vmatrix_methods:setAngles(ang)
	checktype(ang, ang_meta)
	unwrap(self):SetAngles(SF.UnwrapObject(ang))
end

--- Sets the translation
-- @param vec New translation
function vmatrix_methods:setTranslation(vec)
	checktype(vec, vec_meta)
	unwrap(self):SetTranslation(vunwrap(vec))
end

--- Sets the forward direction of the matrix. First column
-- @param forward The forward vector
function vmatrix_methods:setForward(forward)
	checktype(forward, vec_meta)
	unwrap(self):SetForward(vunwrap(forward))
end

--- Sets the right direction of the matrix. Negated second column
-- @param right The right vector
function vmatrix_methods:setRight(right)
	checktype(right, vec_meta)
	unwrap(self):SetRight(vunwrap(right))
end

--- Sets the up direction of the matrix. Third column
-- @param up The up vector
function vmatrix_methods:setUp(up)
	checktype(up, vec_meta)
	unwrap(self):SetUp(vunwrap(up))
end

--- Sets a specific field in the matrix
-- @param row A number from 1 to 4
-- @param column A number from 1 to 4
-- @param value Value to set
function vmatrix_methods:setField(row, column, value)
	unwrap(self):SetField(row, column, value)
end

--- Copies The matrix and returns a new matrix
-- @return The copy of the matrix
function vmatrix_methods:clone()
	return wrap(Matrix(unwrap(self)))
end

--- Copies the values from the second matrix to the first matrix. Self-Modifies
-- @param src Second matrix
function vmatrix_methods:set(src)
	checktype(src, vmatrix_metamethods)
	unwrap(self):Set(unwrap(src))
end

--- Initializes the matrix as Identity matrix
function vmatrix_methods:setIdentity()
	unwrap(self):Identity()
end

--- Returns whether the matrix is equal to Identity matrix or not
-- @return bool True/False
function vmatrix_methods:isIdentity()
	return unwrap(self):IsIdentity()
end

--- Returns whether the matrix is a rotation matrix or not. Checks if the forward, right and up vectors are orthogonal and normalized.
-- @return bool True/False
function vmatrix_methods:isRotationMatrix()
	return unwrap(self):IsRotationMatrix()
end

--- Inverts the matrix. Inverting the matrix will fail if its determinant is 0 or close to 0
-- @return bool Whether the matrix was inverted or not
function vmatrix_methods:invert()
	return unwrap(self):Invert()
end

--- Inverts the matrix efficiently for translations and rotations
function vmatrix_methods:invertTR()
	unwrap(self):InvertTR()
end

--- Translate the matrix
-- @param vec Vector to translate by
function vmatrix_methods:translate(vec)
	checktype(vec, vec_meta)
	unwrap(self):Translate(vunwrap(vec))
end

--- Converts the matrix to a 4x4 table
-- @return The 4x4 table
function vmatrix_methods:toTable()
	return unwrap(self):ToTable()
end

--- Gets the rotation axis and angle of rotation of the rotation matrix
-- @return The axis of rotation
-- @return The angle of rotation
function vmatrix_methods:getAxisAngle()
	local epsilon = 0.00001

	local m = unwrap(self):ToTable()
	local m00, m01, m02 = unpack(m[1])
	local m10, m11, m12 = unpack(m[2])
	local m20, m21, m22 = unpack(m[3])

	if math.abs(m01-m10)< epsilon and math.abs(m02-m20)< epsilon and math.abs(m12-m21)< epsilon then
		// singularity found
		if math.abs(m01+m10) < epsilon and math.abs(m02+m20) < epsilon and math.abs(m12+m21) < epsilon and math.abs(m00+m11+m22-3) < epsilon then
			return vwrap(Vector(1,0,0)), 0
		end
		// otherwise this singularity is angle = math.pi
		local xx = (m00+1)/2
		local yy = (m11+1)/2
		local zz = (m22+1)/2
		local xy = (m01+m10)/4
		local xz = (m02+m20)/4
		local yz = (m12+m21)/4
		if xx > yy and xx > zz then
			if xx < epsilon then
				return vwrap(Vector(0, 0.7071, 0.7071)), math.pi
			else
				local x = math.sqrt(xx)
				return vwrap(Vector(x, xy/x, xz/x)), math.pi
			end
		elseif yy > zz then
			if yy < epsilon then
				return vwrap(Vector(0.7071, 0, 0.7071)), math.pi
			else
				local y = math.sqrt(yy)
				return vwrap(Vector(y, xy/y, yz/y)), math.pi
			end
		else
			if zz < epsilon then
				return vwrap(Vector(0.7071, 0.7071, 0)), math.pi
			else
				local z = math.sqrt(zz)
				return vwrap(Vector(z, xz/z, yz/z)), math.pi
			end
		end
	end

	local axis = Vector(m21 - m12, m02 - m20, m10 - m01)
	local s = axis:Length()
	if math.abs(s) < epsilon then s=1 end
	return vwrap(axis/s), math.acos(math.max(math.min(( m00 + m11 + m22 - 1)/2, 1), -1))
end


local function transposeMatrix(mat, destination)
	local mat_tbl = mat:ToTable()

	destination:SetForward( Vector(unpack(mat_tbl[1])) )
	destination:SetRight( -Vector(unpack(mat_tbl[2])) ) -- SetRight negates the vector
	destination:SetUp( Vector(unpack(mat_tbl[3])) )
	destination:SetTranslation( Vector(unpack(mat_tbl[4])) )

	destination:SetField(4, 1, mat_tbl[1][4])
	destination:SetField(4, 2, mat_tbl[2][4])
	destination:SetField(4, 3, mat_tbl[3][4])
	destination:SetField(4, 4, mat_tbl[4][4])
end

--- Returns the transposed matrix
-- @return Transposed matrix
function vmatrix_methods:getTransposed()
	local result = Matrix()
	transposeMatrix(unwrap(self), result)

	return wrap(result)
end

--- Transposes the matrix
function vmatrix_methods:transpose()
	local m = unwrap(self)
	transposeMatrix(m, m)
end

function vmatrix_metamethods.__add(lhs, rhs)
	checktype(lhs, vmatrix_metamethods)
	checktype(rhs, vmatrix_metamethods)

	return wrap(unwrap(lhs) + unwrap(rhs))
end

function vmatrix_metamethods.__sub(lhs, rhs)
	checktype(lhs, vmatrix_metamethods)
	checktype(rhs, vmatrix_metamethods)

	return wrap(unwrap(lhs) - unwrap(rhs))
end

function vmatrix_metamethods.__mul(lhs, rhs)
	checktype(lhs, vmatrix_metamethods)
	local rhsmeta = dgetmeta(rhs)
	if rhsmeta == vmatrix_metamethods then
		return wrap(unwrap(lhs) * unwrap(rhs))
	elseif rhsmeta == vec_meta then
		return vwrap(unwrap(lhs) * vunwrap(rhs))
	else
		SF.Throw("Matrix must be multiplied with another matrix or vector on right hand side", 2)
	end
end
