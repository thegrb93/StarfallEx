-- Credits to Radon & Xandaros
SF.VMatrix = {}

--- VMatrix type
local vmatrix_methods, vmatrix_metamethods = SF.Typedef("VMatrix")
local wrap, unwrap = SF.CreateWrapper(vmatrix_metamethods, true, false, debug.getregistry().VMatrix)
local vec_meta, vwrap, vunwrap, ang_meta, awrap, aunwrap

SF.Libraries.AddHook("postload", function()
	vec_meta = SF.Vectors.Metatable
	vwrap = SF.Vectors.Wrap
	vunwrap = SF.Vectors.Unwrap
	
	ang_meta = SF.Angles.Metatable
	awrap = SF.Angles.Wrap
	aunwrap = SF.Angles.Unwrap
end)

SF.VMatrix.Methods = vmatrix_methods
SF.VMatrix.Metatable = vmatrix_metamethods
SF.VMatrix.Wrap = wrap
SF.VMatrix.Unwrap = unwrap

local dgetmeta = debug.getmetatable

SF.Libraries.AddHook("postload", function()
	--- Returns a new VMatrix
	-- @return New VMatrix
	SF.DefaultEnvironment.Matrix = function (t)
		return wrap(Matrix(t))
	end
end)

--- tostring metamethod
-- @return string representing the matrix.
function vmatrix_metamethods:__tostring ()
	return unwrap(self):__tostring()
end

--- Returns angles
-- @return Angles
function vmatrix_methods:getAngles ()
	return awrap(unwrap(self):GetAngles())
end

--- Returns scale
-- @return Scale
function vmatrix_methods:getScale ()
	return vwrap(unwrap(self):GetScale())
end

--- Returns translation
-- @return Translation
function vmatrix_methods:getTranslation ()
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
function vmatrix_methods:rotate (ang)
	SF.CheckType(ang, ang_meta)

	local v = unwrap(self)
	v:Rotate(aunwrap(ang))

end

--- Inverts the matrix
-- @return inverted matrix
function vmatrix_methods:getInverse ()

	local v = unwrap(self)
	return wrap(v:GetInverse())

end

--- Returns forward vector of matrix
-- @return Translation
function vmatrix_methods:getForward ()
	return vwrap(unwrap(self):GetForward())
end

--- Returns right vector of matrix
-- @return Translation
function vmatrix_methods:getRight ()
	return vwrap(unwrap(self):GetRight())
end

--- Returns up vector of matrix
-- @return Translation
function vmatrix_methods:getUp ()
	return vwrap(unwrap(self):GetUp())
end


--- Inverts the matrix efficiently for translations and rotations
-- @return inverted matrix
function vmatrix_methods:getInverseTR ()

	local v = unwrap(self)
	return wrap(v:GetInverseTR())

end

--- Sets the scale
-- @param vec New scale
function vmatrix_methods:setScale (vec)
	SF.CheckType(vec, vec_meta)
	local vec = vunwrap(vec)

	local v = unwrap(self)
	v:SetScale(vec)
end

--- Scale the matrix
-- @param vec Vector to scale by
function vmatrix_methods:scale (vec)
	SF.CheckType(vec, vec_meta)
	local vec = vunwrap(vec)

	local v = unwrap(self)
	v:Scale(vec)
end

--- Scales the absolute translation
-- @param num Amount to scale by
function vmatrix_methods:scaleTranslation (num)
	SF.CheckLuaType(num, TYPE_NUMBER)

	local v = unwrap(self)
	v:ScaleTranslation(num)
end

--- Sets the angles
-- @param ang New angles
function vmatrix_methods:setAngles (ang)
	SF.CheckType(ang, ang_meta)

	local v = unwrap(self)
	v:SetAngles(SF.UnwrapObject(ang))
end

--- Sets the translation
-- @param vec New translation
function vmatrix_methods:setTranslation (vec)
	SF.CheckType(vec, vec_meta)
	local vec = vunwrap(vec)

	local v = unwrap(self)
	v:SetTranslation(vec)
end

--- Sets a specific field in the matrix
-- @param row A number from 1 to 4
-- @param column A number from 1 to 4
-- @param value Value to set
function vmatrix_methods:setField(row, column, value)
	local v = unwrap(self)
	v:SetField(row, column, value)
end

--- Translate the matrix
-- @param vec Vector to translate by
function vmatrix_methods:translate (vec)
	SF.CheckType(vec, vec_meta)
	local vec = vunwrap(vec)

	local v = unwrap(self)
	v:Translate(vec)
end

function vmatrix_metamethods.__mul (lhs, rhs)
	SF.CheckType(lhs, vmatrix_metamethods)
	local rhsmeta = dgetmeta(rhs)
	if rhsmeta == vmatrix_metamethods then
		return wrap(unwrap(lhs) * unwrap(rhs))
	elseif rhsmeta == vec_meta then
		return vwrap(unwrap(lhs) * vunwrap(rhs))
	else
		SF.Throw("Matrix must be multiplied with another matrix or vector on right hand side", 2)
	end
end
