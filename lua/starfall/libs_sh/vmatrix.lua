-- Credits to Radon & Xandaros
local checkluatype = SF.CheckLuaType
local dgetmeta = debug.getmetatable


--- VMatrix type
-- @name VMatrix
-- @class type
-- @libtbl vmatrix_methods
-- @libtbl vmatrix_meta
SF.RegisterType("VMatrix", true, false, FindMetaTable("VMatrix"))


return function(instance)

local vmatrix_methods, vmatrix_meta, wrap, unwrap = instance.Types.VMatrix.Methods, instance.Types.VMatrix, instance.Types.VMatrix.Wrap, instance.Types.VMatrix.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap

local vunwrap1
local aunwrap1
instance:AddHook("initialize", function()
	vunwrap1 = vec_meta.QuickUnwrap1
	aunwrap1 = ang_meta.QuickUnwrap1
end)

-- Only use this on normal tables
local function vwrap2(tbl)
	return setmetatable(tbl, vec_meta)
end

--- Returns a new VMatrix
-- @name builtins_library.Matrix
-- @class function
-- @param table|Angle|nil t Optional data or rotation angle to initialize the Matrix with.
-- @param Vector? v Optional translation to initialize the Matrix with.
-- @return VMatrix New VMatrix
function instance.env.Matrix(t, v)
	local m
	if t~=nil then
		checkluatype(t, TYPE_TABLE)
		if dgetmeta(t)==ang_meta then
			m = Matrix()
			m:SetAngles(aunwrap1(t))
		else
			m = Matrix(t)
		end
	else
		m = Matrix()
	end
	if v~=nil then
		m:SetTranslation(vunwrap1(v))
	end
	return wrap(m)
end

--- tostring metamethod
-- @return string String representing the matrix.
function vmatrix_meta:__tostring()
	return unwrap(self):__tostring()
end

--- Returns angles
-- @return Angle Angles
function vmatrix_methods:getAngles()
	return awrap(unwrap(self):GetAngles())
end

--- Returns scale
-- @return Vector Scale
function vmatrix_methods:getScale()
	return vwrap(unwrap(self):GetScale())
end

--- Returns translation
-- @return Vector Translation
function vmatrix_methods:getTranslation()
	return vwrap(unwrap(self):GetTranslation())
end

--- Returns a specific field in the matrix
-- @param number row A number from 1 to 4
-- @param number column A number from 1 to 4
-- @return number Value of the specified field
function vmatrix_methods:getField(row, column)
	return unwrap(self):GetField(row, column)
end

--- Rotate the matrix
-- Self-Modifies. Does not return anything
-- @param Angle ang Angle to rotate by
function vmatrix_methods:rotate(ang)
	unwrap(self):Rotate(aunwrap1(ang))
end

--- Returns the input matrix rotated by an axis
-- @param Vector axis Axis to rotate around
-- @param number ang Angle to rotate by in radians
-- @return VMatrix The rotated matrix
function vmatrix_methods:getRotatedAroundAxis(axis, ang)
	local r = wrap(Matrix())
	r:setAxisAngle(axis, ang)
	return r*self
end

--- Returns an inverted matrix. Inverting the matrix will fail if its determinant is 0 or close to 0
-- @return VMatrix Inverted matrix
function vmatrix_methods:getInverse()
	return wrap(unwrap(self):GetInverse())
end

--- Returns an inverted matrix. Efficiently for translations and rotations
-- @return VMatrix Inverted matrix
function vmatrix_methods:getInverseTR()
	return wrap(unwrap(self):GetInverseTR())
end

--- Returns forward vector of matrix. First matrix column
-- @return Vector Translation
function vmatrix_methods:getForward()
	return vwrap(unwrap(self):GetForward())
end

--- Returns right vector of matrix. Negated second matrix column
-- @return Vector Translation
function vmatrix_methods:getRight()
	return vwrap(unwrap(self):GetRight())
end

--- Returns up vector of matrix. Third matrix column
-- @return Vector Translation
function vmatrix_methods:getUp()
	return vwrap(unwrap(self):GetUp())
end

--- Sets the scale
-- Self-Modifies. Does not return anything
-- @param Vector vec New scale
function vmatrix_methods:setScale(vec)
	unwrap(self):SetScale(vunwrap1(vec))
end

--- Scale the matrix
-- Self-Modifies. Does not return anything
-- @param Vector vec Vector to scale by
function vmatrix_methods:scale(vec)
	unwrap(self):Scale(vunwrap1(vec))
end

--- Scales the absolute translation
-- Self-Modifies. Does not return anything
-- @param number num Amount to scale by
function vmatrix_methods:scaleTranslation(num)
	checkluatype (num, TYPE_NUMBER)
	unwrap(self):ScaleTranslation(num)
end

--- Sets the angles
-- Self-Modifies. Does not return anything
-- @param Angle ang New angles
function vmatrix_methods:setAngles(ang)
	unwrap(self):SetAngles(aunwrap1(ang))
end

--- Sets the translation
-- Self-Modifies. Does not return anything
-- @param Vector vec New translation
function vmatrix_methods:setTranslation(vec)
	unwrap(self):SetTranslation(vunwrap1(vec))
end

--- Sets the forward direction of the matrix. First column
-- Self-Modifies. Does not return anything
-- @param Vector forward The forward vector
function vmatrix_methods:setForward(forward)
	unwrap(self):SetForward(vunwrap1(forward))
end

--- Sets the right direction of the matrix. Negated second column
-- Self-Modifies. Does not return anything
-- @param Vector right The right vector
function vmatrix_methods:setRight(right)
	unwrap(self):SetRight(vunwrap1(right))
end

--- Sets the up direction of the matrix. Third column
-- Self-Modifies. Does not return anything
-- @param Vector up The up vector
function vmatrix_methods:setUp(up)
	unwrap(self):SetUp(vunwrap1(up))
end

--- Sets a specific field in the matrix
-- Self-Modifies. Does not return anything
-- @param number row A number from 1 to 4
-- @param number column A number from 1 to 4
-- @param number value Value to set
function vmatrix_methods:setField(row, column, value)
	unwrap(self):SetField(row, column, value)
end

--- Copies The matrix and returns a new matrix
-- @return VMatrix The copy of the matrix
function vmatrix_methods:clone()
	return wrap(Matrix(unwrap(self)))
end

--- Returns all 16 fields of the matrix in row-major order
-- @return ...number The 16 fields
function vmatrix_methods:unpack()
	return unwrap(self):Unpack()
end

--- Allows you to set all 16 fields in row-major order
-- Self-Modifies. Does not return anything
-- @param ...number fields The 16 fields
function vmatrix_methods:setUnpacked(...)
	unwrap(self):SetUnpacked(...)
end

--- Copies the values from the second matrix to the first matrix.
-- Self-Modifies. Does not return anything
-- @param VMatrix src Second matrix
function vmatrix_methods:set(src)
	unwrap(self):Set(unwrap(src))
end

--- Initializes the matrix as Identity matrix
-- Self-Modifies. Does not return anything
function vmatrix_methods:setIdentity()
	unwrap(self):Identity()
end

--- Returns whether the matrix is equal to Identity matrix or not
-- @return boolean True/False
function vmatrix_methods:isIdentity()
	return unwrap(self):IsIdentity()
end

--- Returns whether the matrix is a rotation matrix or not. Checks if the forward, right and up vectors are orthogonal and normalized.
-- @return boolean True/False
function vmatrix_methods:isRotationMatrix()
	return unwrap(self):IsRotationMatrix()
end

--- Inverts the matrix. Inverting the matrix will fail if its determinant is 0 or close to 0
-- Self-Modifies.
-- @return boolean Whether the matrix was inverted or not
function vmatrix_methods:invert()
	return unwrap(self):Invert()
end

--- Inverts the matrix efficiently for translations and rotations
-- Self-Modifies. Does not return anything
function vmatrix_methods:invertTR()
	unwrap(self):InvertTR()
end

--- Translate the matrix
-- @param Vector vec Vector to translate by
function vmatrix_methods:translate(vec)
	unwrap(self):Translate(vunwrap1(vec))
end

--- Converts the matrix to a 4x4 table
-- @return table The 4x4 table
function vmatrix_methods:toTable()
	return unwrap(self):ToTable()
end

--- Sets the rotation or the matrix to the rotation by an axis and angle
-- Self-Modifies. Does not return anything
-- @param Vector axis The normalized axis of rotation
-- @param number angle The angle of rotation in radians
function vmatrix_methods:setAxisAngle(axis, ang)
	local x, y, z = axis[1], axis[2], axis[3]
	local c = math.cos(ang)
	local s = math.sin(ang)
	local cinv = 1 - c

	local xycinv = x*y*cinv
	local xzcinv = x*z*cinv
	local yzcinv = y*z*cinv

	local xs = x*s
	local ys = y*s
	local zs = z*s

	unwrap(self):SetUnpacked(
		c + x^2*cinv, xycinv - zs, xzcinv + ys, 0,
		xycinv + zs, c + y^2*cinv, yzcinv - xs, 0,
		xzcinv - ys, yzcinv + xs, c + z^2*cinv, 0,
		0, 0, 0, 1)
end

--- Gets the rotation axis and angle of rotation of the rotation matrix
-- @return Vector The axis of rotation
-- @return number The angle of rotation
function vmatrix_methods:getAxisAngle()
	local epsilon = 0.00001

	local m00, m01, m02, m03,
		m10, m11, m12, m13,
		m20, m21, m22, m23 = unwrap(self):Unpack()

	if math.abs(m01-m10)< epsilon and math.abs(m02-m20)< epsilon and math.abs(m12-m21)< epsilon then
		-- singularity found
		if math.abs(m01+m10) < epsilon and math.abs(m02+m20) < epsilon and math.abs(m12+m21) < epsilon and math.abs(m00+m11+m22-3) < epsilon then
			return vwrap2({1,0,0}), 0
		end
		-- otherwise this singularity is angle = math.pi
		local xx = (m00+1)/2
		local yy = (m11+1)/2
		local zz = (m22+1)/2
		local xy = (m01+m10)/4
		local xz = (m02+m20)/4
		local yz = (m12+m21)/4
		if xx > yy and xx > zz then
			if xx < epsilon then
				return vwrap2({0, 0.7071, 0.7071}), math.pi
			else
				local x = math.sqrt(xx)
				return vwrap2({x, xy/x, xz/x}), math.pi
			end
		elseif yy > zz then
			if yy < epsilon then
				return vwrap2({0.7071, 0, 0.7071}), math.pi
			else
				local y = math.sqrt(yy)
				return vwrap2({y, xy/y, yz/y}), math.pi
			end
		else
			if zz < epsilon then
				return vwrap2({0.7071, 0.7071, 0}), math.pi
			else
				local z = math.sqrt(zz)
				return vwrap2({z, xz/z, yz/z}), math.pi
			end
		end
	end

	local axis = {m21 - m12, m02 - m20, m10 - m01}
	local s = math.sqrt(axis[1]^2 + axis[2]^2 + axis[3]^2)
	if math.abs(s) < epsilon then s=1 end
	axis[1] = axis[1]/s
	axis[2] = axis[2]/s
	axis[3] = axis[3]/s
	return vwrap2(axis), math.acos(math.max(math.min(( m00 + m11 + m22 - 1)/2, 1), -1))
end

--- Adds two matrices (why would you do this?)
-- @param VMatrix lhs Initial Matrix
-- @param VMatrix rhs Matrix to add to the first
-- @return VMatrix Added matrix
function vmatrix_meta.__add(lhs, rhs)
	return wrap(unwrap(lhs) + unwrap(rhs))
end

--- Subtracts two matrices (why would you do this?)
-- @param VMatrix lhs Initial Matrix
-- @param VMatrix rhs Matrix to subtract from the first
-- @return VMatrix Subtracted matrix
function vmatrix_meta.__sub(lhs, rhs)
	return wrap(unwrap(lhs) - unwrap(rhs))
end

--- Multiplies two matrices (Left must be a VMatrix)
-- @param VMatrix lhs Matrix multiplicand
-- @param VMatrix|Vector rhs Matrix or Vector multiplier
-- @return VMatrix Result matrix
function vmatrix_meta.__mul(lhs, rhs)
	local rhsmeta = dgetmeta(rhs)
	if rhsmeta == vmatrix_meta then
		return wrap(unwrap(lhs) * unwrap(rhs))
	elseif rhsmeta == vec_meta then
		return vwrap(unwrap(lhs) * vunwrap1(rhs))
	else
		SF.Throw("Matrix must be multiplied with another matrix or vector on right hand side", 2)
	end
end

end
