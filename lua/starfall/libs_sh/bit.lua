-------------------------------------------------------------------------------
-- Bit functions
-------------------------------------------------------------------------------

--- Bit library http://wiki.garrysmod.com/page/Category:bit
-- @shared
local bit_library = SF.RegisterLibrary("bit")
bit_library.arshift = bit.arshift
bit_library.band = bit.band
bit_library.bnot = bit.bnot
bit_library.bor = bit.bor
bit_library.bswap = bit.bswap
bit_library.bxor = bit.bxor
bit_library.lshift = bit.lshift
bit_library.rol = bit.rol
bit_library.ror = bit.ror
bit_library.rshift = bit.rshift
bit_library.tobit = bit.tobit
bit_library.tohex = bit.tohex

local checkluatype = SF.CheckLuaType

--- StringStream type
local ss_methods, ss_metamethods = SF.RegisterType("StringStream")

--- Creates a StringStream object
--@param stream A string to set the initial buffer to (default "")
--@param i The initial buffer pointer (default 1)
function bit_library.stringstream(stream, i)
	if stream~=nil then checkluatype(stream, TYPE_STRING) else stream = "" end
	if i~=nil then checkluatype(i, TYPE_NUMBER) else i = 1 end
	
	local ret = setmetatable({
		buffer = {},
		pos = 1
	}, ss_metamethods)
	
	ret:write(stream)
	ret:seek(i)
	
	return ret
end

local function ByterizeInt(n)
	n = (n < 0) and (4294967296 + n) or n
	return math.floor(n/16777216)%256, math.floor(n/65536)%256, math.floor(n/256)%256, n%256
end

local function ByterizeShort(n)
	n = (n < 0) and (65536 + n) or n
	return math.floor(n/256)%256, n%256
end

local function ByterizeByte(n)
	n = (n < 0) and (256 + n) or n
	return n%256
end

--Credit https://stackoverflow.com/users/903234/rpfeltz
local function PackIEEE754Float(number)
    if number == 0 then
        return 0x00, 0x00, 0x00, 0x00
    elseif number ~= number then
        return 0xFF, 0xFF, 0xFF, 0xFF
    else
        local sign = 0x00
        if number < 0 then
            sign = 0x80
            number = -number
        end
        local mantissa, exponent = math.frexp(number)
        exponent = exponent + 0x7F
        if exponent <= 0 then
            mantissa = math.ldexp(mantissa, exponent - 1)
            exponent = 0
        elseif exponent > 0 then
            if exponent >= 0xFF then
                return string.char(sign + 0x7F, 0x80, 0x00, 0x00)
            elseif exponent == 1 then
                exponent = 0
            else
                mantissa = mantissa * 2 - 1
                exponent = exponent - 1
            end
        end
        mantissa = math.floor(math.ldexp(mantissa, 23) + 0.5)
        return sign + math.floor(exponent / 2),
                (exponent % 2) * 0x80 + math.floor(mantissa / 0x10000),
                math.floor(mantissa / 0x100) % 0x100,
                mantissa % 0x100
    end
end
local function UnpackIEEE754Float(b1, b2, b3, b4)
    local exponent = (b1 % 0x80) * 0x02 + math.floor(b2 / 0x80)
    local mantissa = math.ldexp(((b2 % 0x80) * 0x100 + b3) * 0x100 + b4, -23)
    if exponent == 0xFF then
        if mantissa > 0 then
            return 0 / 0
        else
            if b1 >= 0x80 then
                return -math.huge
            else
                return math.huge
            end
        end
    elseif exponent > 0 then
        mantissa = mantissa + 1
    else
        exponent = exponent + 1
    end
    if b1 >= 0x80 then
        mantissa = -mantissa
    end
    return math.ldexp(mantissa, exponent - 0x7F)
end
local function PackIEEE754Double(number)
    if number == 0 then
        return 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    elseif number ~= number then
        return 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
    else
        local sign = 0x00
        if number < 0 then
            sign = 0x80
            number = -number
        end
        local mantissa, exponent = math.frexp(number)
        exponent = exponent + 0xFFFF
        if exponent <= 0 then
            mantissa = math.ldexp(mantissa, exponent - 1)
            exponent = 0
        elseif exponent > 0 then
            if exponent >= 0x7FF then
                return string.char(sign + 0x7F, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)
            elseif exponent == 1 then
                exponent = 0
            else
                mantissa = mantissa * 2 - 1
                exponent = exponent - 1
            end
        end
        mantissa = math.floor(math.ldexp(mantissa, 52) + 0.5)
        return sign + math.floor(exponent / 16),
                (exponent % 16) * 0x10 + math.floor(mantissa / 0x1000000000000),
                math.floor(mantissa / 0x10000000000) % 0x10000000000,
                math.floor(mantissa / 0x100000000) % 0x100000000,
                math.floor(mantissa / 0x1000000) % 0x1000000,
                math.floor(mantissa / 0x10000) % 0x10000,
                math.floor(mantissa / 0x100) % 0x100,
                mantissa % 0x100
    end
end
local function UnpackIEEE754Double(b1, b2, b3, b4, b5, b6, b7, b8)
    local exponent = (b1 % 0x80) * 0x10 + math.floor(b2 / 0x10)
    local mantissa = math.ldexp(((((((b2 % 0x10) * 0x100 + b3) * 0x100 + b4) * 0x100 + b5) * 0x100 + b6) * 0x100 + b7) * 0x100 + b8, -52)
    if exponent == 0x7FF then
        if mantissa > 0 then
            return 0 / 0
        else
            if b1 >= 0x80 then
                return -math.huge
            else
                return math.huge
            end
        end
    elseif exponent > 0 then
        mantissa = mantissa + 1
    else
        exponent = exponent + 1
    end
    if b1 >= 0x80 then
        mantissa = -mantissa
    end
    return math.ldexp(mantissa, exponent - 0x3FF)
end

--- Returns little endian bytes (A B) (all 32 bits)
--@param n The number to pack
--@return The packed bytes
function bit_library.getInt32BytesLE(n)
	local a,b,c,d = ByterizeInt(n)
	return string.char(d,c,b,a)
end

--- Returns little endian bytes (A B) (first two bytes, 16 bits, of number )
--@param n The number to pack
--@return The packed bytes
function bit_library.getInt16BytesLE(n)
	local a,b  = ByterizeShort(n)
	return string.char(b,a)
end

--- Returns big endian bytes (A B) (all 32 bits)
--@param n The number to pack
--@return The packed bytes
function bit_library.getInt32BytesBE(n)
	local a,b,c,d = ByterizeInt(n)
	return string.char(a,b,c,d)
end

--- Returns big endian bytes (A B) (first two bytes, 16 bits, of number )
--@param n The number to pack
--@return The packed bytes
function bit_library.getInt16BytesBE(n)
	local a,b  = ByterizeShort(n)
	return string.char(a,b)
end

local function twos_compliment(x,bits)
    local mask = 2^(bits - 1)
    return -(bit.band(x,mask)) + (bit.band(x,bit.bnot(mask)))
end

function ss_metamethods:__tostring()
	return string.format("Stringstream [%u,%u]",self.pos, #self.buffer)
end

--- Sets internal pointer to i. The position will be clamped to [1, buffersize+1]
--@param i The position
function ss_methods:seek(i)
	self.pos = math.Clamp(i, 1, #self.buffer + 1)
end

--- Move the internal pointer by amount i
--@param i The offset
function ss_methods:skip(i)
	self.pos = self.pos + i
end

--- Returns the internal position of the byte reader.
--@return The buffer position
function ss_methods:tell()
	return self.pos
end

--- Tells the size of the byte stream.
--@return The buffer size
function ss_methods:size()
	return #self.buffer
end

--- Reads the specified number of bytes from the buffer and advances the buffer pointer.
--@param n How many bytes to read
--@return A string containing the bytes
function ss_methods:read(n)
	n = math.max(n, 0)
	local str = string.char(unpack(self.buffer, self.pos, self.pos+n-1))
	self.pos = self.pos + n
	return str
end

--- Reads an unsigned 8-bit (one byte) integer from the byte stream and advances the buffer pointer.
--@return The uint8 at this position
function ss_methods:readUInt8()
	local ret = self.buffer[self.pos]
	self.pos = self.pos + 1
	return ret
end

--- Reads an unsigned 16 bit (two byte) integer from the byte stream and advances the buffer pointer.
--@return The uint16 at this position
function ss_methods:readUInt16()
	return self:readUInt8() + self:readUInt8() * 0x100
end

--- Reads an unsigned 32 bit (four byte) integer from the byte stream and advances the buffer pointer.
--@return The uint32 at this position
function ss_methods:readUInt32() 
	return self:readUInt16() + self:readUInt16() * 0x10000
end

--- Reads a signed 8-bit (one byte) integer from the byte stream and advances the buffer pointer.
--@return The int8 at this position
function ss_methods:readInt8()
	return twos_compliment(self:readUInt8(),8)
end

--- Reads a signed 16-bit (two byte) integer from the byte stream and advances the buffer pointer.
--@return The int16 at this position
function ss_methods:readInt16()
	return twos_compliment(self:readUInt16(),16)
end

--- Reads a signed 32-bit (four byte) integer from the byte stream and advances the buffer pointer.
--@return The int32 at this position
function ss_methods:readInt32()
	return twos_compliment(self:readUInt32(),32)
end

--- Reads a 4 byte IEEE754 float from the byte stream and advances the buffer pointer.
--@return The float32 at this position
function ss_methods:readFloat()
	local ret = UnpackIEEE754Float(self.buffer[self.pos], self.buffer[self.pos+1], self.buffer[self.pos+2], self.buffer[self.pos+3])
	self.pos = self.pos + 4
	return ret
end

--- Reads until the given byte and advances the buffer pointer.
--@param byte The byte to read until (in number form)
--@return The string of bytes read
function ss_methods:readUntil(byte)
	local endpos = nil
	for i=self.pos, #self.buffer do
		if self.buffer[i] == byte then endpos = i break end
	end
	endpos = endpos or #self.buffer
	local str = string.char(unpack(self.buffer, self.pos, endpos))
	self.pos = endpos + 1
	return str
end

--- returns a null terminated string, reads until "\x00" and advances the buffer pointer.
--@return The string of bytes read
function ss_methods:readString()
	return self:readUntil(0)
end


--- Writes the given string and advances the buffer pointer.
--@param bytes A string of bytes to write
function ss_methods:write(bytes)
	local buffer = {string.byte(bytes, 1, #bytes)}
	for i=1, #buffer do
		self.buffer[self.pos+i-1] = buffer[i]
	end
	self.pos = self.pos + #buffer
end

--- Writes a byte to the buffer and advances the buffer pointer.
--@param x An int8 to write
function ss_methods:writeInt8(x)
	self.buffer[self.pos] = ByterizeByte(x)
	self.pos = self.pos + 1
end

--- Writes a short in little endian to the buffer and advances the buffer pointer.
--@param x An int16 to write
function ss_methods:writeInt16(x)
	self.buffer[self.pos+1], self.buffer[self.pos] = ByterizeShort(x)
	self.pos = self.pos + 2
end

--- Writes an int in little endian to the buffer and advances the buffer pointer.
--@param x An int32 to write
function ss_methods:writeInt32(x)
	self.buffer[self.pos+3], self.buffer[self.pos+2], self.buffer[self.pos+1], self.buffer[self.pos] = ByterizeInt(x)
	self.pos = self.pos + 4
end

--- Writes a 4 byte IEEE754 float in little endian to the byte stream and advances the buffer pointer.
--@param x The float to write
function ss_methods:writeFloat(x)
	self.buffer[self.pos], self.buffer[self.pos+1], self.buffer[self.pos+2], self.buffer[self.pos+3] = PackIEEE754Float(x)
	self.pos = self.pos + 4
end

--- Writes a string to the buffer putting a null at the end and advances the buffer pointer.
--@param string The string of bytes to write
function ss_methods:writeString(string)
	self:write(string)
	self:writeInt8(0)
end

--- Returns the buffer as a string
--@return The buffer as a string
function ss_methods:getString()
   return string.char(unpack(self.buffer))
end

--- Returns the internal buffer
--@return The buffer table
function ss_methods:getBuffer()
   return self.buffer
end
