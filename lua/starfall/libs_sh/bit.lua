--- Bitwise library

--- Bitwise library
-- @shared
local bit_library, _ = SF.Libraries.Register( "bit" )
local bit = bit

--- Arithmetic shift right
-- @param value Value to be modified
-- @param shiftCount Amounts of bits to shift
-- @return Shifted value
function bit_library.arshift ( value, shiftCount )
	SF.CheckType( value, "number" )
	SF.CheckType( shiftCount, "number" )

	return bit.arshift( value, shiftCount )
end

--- Bitwise and
-- @param value1 First value
-- @param ... More values
-- @return Bitwise and of all values
function bit_library.band ( value1, ... )
	SF.CheckType( value1, "number" )
	for _, v in ipairs( { ... } ) do
		SF.CheckType( v, "number" )
	end

	return bit.band( value1, ... )
end

--- Bitwise not
-- Negates every bit
-- @param value Value to be modified
-- @return Negated value
function bit_library.bnot ( value )
	SF.CheckType( value, "number" )

	return bit.bnot( value )
end

--- Bitwise or
-- @param value1 First value
-- @param ... More values
-- @return Bitwise or of all values
function bit_library.bor ( value1, ... )
	SF.CheckType( value1, "number" )
	for _, v in ipairs( { ... } ) do
		SF.CheckType( v, "number" )
	end

	return bit.bor( value1, ... )
end

--- Swaps byte order
-- @param value Value to be modified
-- @return Value with swapped byte order
function bit_library.bswap ( value )
	SF.CheckType( value, "number" )

	return bit.bswap( value )
end

--- Bitwise xor
-- @param value1 First value
-- @param ... More values
-- @return Bitwise xor of all values
function bit_library.bxor ( value1, ... )
	SF.CheckType( value1, "number" )
	for _, v in ipairs( { ... } ) do
		SF.CheckType( v, "number" )
	end

	return bit.bxor( value1, ... )
end

--- Shift left
-- @param value Value to be modified
-- @param shiftCount Amounts of bits to shift
-- @return Shifted value
function bit_library.lshift ( value, shiftCount )
	SF.CheckType( value, "number" )
	SF.CheckType( shiftCount, "number" )

	return bit.lshift( value, shiftCount )
end

--- Rotate left
-- @param value Value to be modified
-- @param shiftCount Amounts of bits to shift
-- @return Rotated value
function bit_library.rol ( value, shiftCount )
	SF.CheckType( value, "number" )
	SF.CheckType( shiftCount, "number" )

	return bit.rol( value, shiftCount )
end

--- Rotate right
-- @param value Value to be modified
-- @param shiftCount Amounts of bits to shift
-- @return Rotated value
function bit_library.ror ( value, shiftCount )
	SF.CheckType( value, "number" )
	SF.CheckType( shiftCount, "number" )

	return bit.ror( value, shiftCount )
end

--- Shift right
-- @param value Value to be modified
-- @param shiftCount Amounts of bits to shift
-- @return Shifted value
function bit_library.rshift ( value, shiftCount )
	SF.CheckType( value, "number" )
	SF.CheckType( shiftCount, "number" )

	return bit.rshift( value, shiftCount )
end

--- Clamps to 32-bit integer
-- @param value Value to be modified
-- @return Clamped value
function bit_library.tobit ( value )
	SF.CheckType( value, "number" )

	return bit.tobit( value )
end

--- Returns the hexadecimal representation of the value
-- @param value Value
-- @param digits Amounts of digits. Optional.
-- @return Hexadecimal representation
function bit_library.tohex ( value, digits )
	SF.CheckType( value, "number" )
	SF.CheckType( digits, "number" )

	return bit.tohex( value, digits )
end
