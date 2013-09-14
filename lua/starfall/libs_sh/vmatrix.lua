-- Credits to Radon & Xandaros
SF.VMatrix = {}

local vmatrix_methods, vmatrix_metamethods = SF.Typedef("VMatrix") -- Define our own VMatrix based off of standard VMatrix
local wrap, unwrap = SF.CreateWrapper( vmatrix_metamethods, true, false )

SF.VMatrix.Methods = vmatrix_methods
SF.VMatrix.Metatable = vmatrix_metamethods
SF.VMatrix.Wrap = wrap
SF.VMatrix.Unwrap = unwrap

SF.DefaultEnvironment.Matrix = function()
	return wrap(Matrix())
end

function vmatrix_methods:getAngles()
	SF.CheckType( self, vmatrix_metamethods )
	return unwrap(self):GetAngles()
end

function vmatrix_methods:getScale()
	SF.CheckType( self, vmatrix_metamethods )
	return unwrap(self):GetScale()
end

function vmatrix_methods:getTranslation()
	SF.CheckType( self, vmatrix_metamethods )
	return unwrap(self):GetTranslation()
end

function vmatrix_methods:rotate( ang )
	SF.CheckType( self, vmatrix_metamethods )
	SF.CheckType( ang, "Angle")

	local v = unwrap(self)
	v:Rotate( ang )

end

function vmatrix_methods:scale( vec )
	SF.CheckType( self, vmatrix_metamethods )
	SF.CheckType( vec, "Vector" )

	local v = unwrap(self)
	v:Scale( vec )
end

function vmatrix_methods:scaleTranslation( num )
	SF.CheckType( self, vmatrix_metamethods )
	SF.CheckType( num, "Number" )

	local v = unwrap(self)
	v:ScaleTranslation( num )
end

function vmatrix_methods:setAngles( ang )
	SF.CheckType( self, vmatrix_metamethods )
	SF.CheckType( ang, "Angle" )

	local v = unwrap(self)
	v:SetAngles( ang )
end

function vmatrix_methods:setTranslation( vec )
	SF.CheckType( self, vmatrix_metamethods )
	SF.CheckType( vec, "Vector" )

	local v = unwrap(self)
	v:SetTranslation( vec )
end

function vmatrix_methods:translate( vec )
	SF.CheckType( self, vmatrix_metamethods )
	SF.CheckType( vec, "Vector" )

	local v = unwrap(self)
	v:Translate( vec )
end

function vmatrix_metamethods.__mul( lhs, rhs )
	SF.CheckType( lhs, vmatrix_metamethods )
	SF.CheckType( rhs, vmatrix_metamethods )

	return wrap(unwrap(rhs) * unwrap(rhs))
end
