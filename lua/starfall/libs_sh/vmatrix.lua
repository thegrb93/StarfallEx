-- Credits to Radon & Xandaros
SF.VMatrix = {}

--- VMatrix type
local vmatrix_methods, vmatrix_metamethods = SF.Typedef( "VMatrix" )
local wrap, unwrap = SF.CreateWrapper( vmatrix_metamethods, true, false )
local vunwrap = SF.UnwrapObject

SF.VMatrix.Methods = vmatrix_methods
SF.VMatrix.Metatable = vmatrix_metamethods
SF.VMatrix.Wrap = wrap
SF.VMatrix.Unwrap = unwrap

--- Returns a new VMatrix
-- @return New VMatrix
SF.DefaultEnvironment.Matrix = function ()
	return wrap( Matrix() )
end

--- Returns angles
-- @return Angles
function vmatrix_methods:getAngles ()
	return SF.WrapObject( unwrap( self ):GetAngles() )
end

--- Returns scale
-- @return Scale
function vmatrix_methods:getScale ()
	return SF.WrapObject( unwrap( self ):GetScale() )
end

--- Returns translation
-- @return Translation
function vmatrix_methods:getTranslation ()
	return SF.WrapObject( unwrap( self ):GetTranslation() )
end

--- Rotate the matrix
-- @param ang Angle to rotate by
function vmatrix_methods:rotate ( ang )
	SF.CheckType( ang, SF.Types[ "Angle" ] )

	local v = unwrap( self )
	v:Rotate( SF.UnwrapObject( ang ) )

end

--- Scale the matrix
-- @param vec Vector to scale by
function vmatrix_methods:scale ( vec )
	SF.CheckType( vec, SF.Types[ "Vector" ] )
	local vec = vunwrap( vec )

	local v = unwrap( self )
	v:Scale( vec )
end

--- Scales the absolute translation
-- @param num Amount to scale by
function vmatrix_methods:scaleTranslation ( num )
	SF.CheckType( num, "number" )

	local v = unwrap( self )
	v:ScaleTranslation( num )
end

--- Sets the angles
-- @param ang New angles
function vmatrix_methods:setAngles ( ang )
	SF.CheckType( ang, SF.Types[ "Angle" ] )

	local v = unwrap( self )
	v:SetAngles( SF.UnwrapObject( ang ) )
end

--- Sets the translation
-- @param vec New translation
function vmatrix_methods:setTranslation ( vec )
	SF.CheckType( vec, SF.Types[ "Vector" ] )
	local vec = vunwrap( vec )

	local v = unwrap( self )
	v:SetTranslation( vec )
end

--- Translate the matrix
-- @param vec Vector to translate by
function vmatrix_methods:translate ( vec )
	SF.CheckType( vec, SF.Types[ "Vector" ] )
	local vec = vunwrap( vec )

	local v = unwrap( self )
	v:Translate( vec )
end

function vmatrix_metamethods.__mul ( lhs, rhs )
	SF.CheckType( rhs, vmatrix_metamethods )

	return wrap( unwrap( lhs ) * unwrap( rhs ) )
end
