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

function vmatrix_methods:rotate( ang )
	SF.CheckType( self, vmatrix_metamethods )
	SF.CheckType( ang, "Angle")

	local v = unwrap(self)
	v:Rotate( ang )

end

function vmatrix_methods:translate( vec )
	SF.CheckType( self, vmatrix_metamethods )
	SF.CheckType( vec, "Vector" )

	local v = unwrap(self)
	v:Translate( vec )
end