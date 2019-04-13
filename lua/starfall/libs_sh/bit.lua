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
            mantissa = math.huge
            exponent = 0x7F
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

--- Returns little endian bytes (A B) (all 32 bits)
function bit_library.getInt32BytesLE(n)
	local a,b,c,d = ByterizeInt(n)
	return string.char(d,c,b,a)
end

--- Returns little endian bytes (A B) (first two bytes, 16 bits, of number )
function bit_library.getInt16BytesLE(n)
	local a,b  = ByterizeShort(n)
	return string.char(b,a)
end

--- Returns big endian bytes (A B) (all 32 bits)
function bit_library.getInt32BytesBE(n)
	local a,b,c,d = ByterizeInt(n)
	return string.char(a,b,c,d)
end

--- Returns big endian bytes (A B) (first two bytes, 16 bits, of number )
function bit_library.getInt16BytesBE(n)
	local a,b  = ByterizeShort(n)
	return string.char(a,b)
end

local function twos_compliment(x,bits)
    local mask = 2^(bits - 1)
    return -(bit.band(x,mask)) + (bit.band(x,bit.bnot(mask)))
end

function ss_metamethods:__tostring()
	return string.format("StarfallBinaryReader [%u,%u]",0,self.Position)
end

--- Sets internal position to i. The position will be clamped to 1-buffersize
function ss_methods:seek(i)
	self.pos = math.Clamp(i, 1, #self.buffer + 1)
end

--- Move the internal pointer by amount i
function ss_methods:skip(i)
	self.pos = self.pos + i
end

--- Tells the size of the byte stream.
function ss_methods:size()
	return #self.buffer
end

--- Reads an unsigned 8-bit (one byte) integer from the byte stream and advances the buffer pointer.
function ss_methods:readUInt8()
	local ret = self.buffer[self.pos]
	self.pos = self.pos + 1
	return ret
end

--- Reads an unsigned 16 bit (two byte) integer from the byte stream and advances the buffer pointer.
function ss_methods:readUInt16()
	return self:readUInt8() + self:readUInt8() * 0x100
end

--- Reads an unsigned 32 bit (four byte) integer from the byte stream and advances the buffer pointer.
function ss_methods:readUInt32() 
	return self:readUInt16() + self:readUInt16() * 0x10000
end

--- Reads a signed 8-bit (one byte) integer from the byte stream and advances the buffer pointer.
function ss_methods:readInt8()
	return twos_compliment(self:readUInt8(),8)
end

--- Reads a signed 16-bit (two byte) integer from the byte stream and advances the buffer pointer.
function ss_methods:readInt16()
	return twos_compliment(self:readUInt16(),16)
end

--- Reads a signed 32-bit (four byte) integer from the byte stream and advances the buffer pointer.
function ss_methods:readInt32()
	return twos_compliment(self:readUInt32(),32)
end

--- Reads a 4 byte IEEE754 float from the byte stream and advances the buffer pointer.
function ss_methods:readFloat()
	local ret = UnpackIEEE754Float(self.buffer[self.pos], self.buffer[self.pos+1], self.buffer[self.pos+2], self.buffer[self.pos+3])
	self.pos = self.pos + 4
	return ret
end

--- Returns the internal position of the byte reader.
function ss_methods:tell()
	return self.pos
end

--- Reads the specified number of bytes from the buffer and advances the buffer pointer.
function ss_methods:read(n)
	n = math.max(n, 0)
	local str = string.char(unpack(self.buffer, self.pos, self.pos+n-1))
	self.pos = self.pos + n
	return str
end

--- Writes the given string and advances the buffer pointer.
function ss_methods:write(bytes)
	local buffer = {string.byte(bytes, 1, #bytes)}
	for i=1, #buffer do
		self.buffer[self.pos+i-1] = buffer[i]
	end
	self.pos = self.pos + #buffer
end

--- Reads until the given byte and advances the buffer pointer.
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
function ss_methods:readString()
	return self:readUntil(0)
end

--- Writes a byte to the buffer and advances the buffer pointer.
function ss_methods:writeInt8(x)
	self.buffer[self.pos] = ByterizeByte(x)
	self.pos = self.pos + 1
end

--- Writes a short to the buffer and advances the buffer pointer.
function ss_methods:writeInt16(x)
	self.buffer[self.pos+1], self.buffer[self.pos] = ByterizeShort(x)
	self.pos = self.pos + 2
end

--- Writes an int to the buffer and advances the buffer pointer.
function ss_methods:writeInt32(x)
	self.buffer[self.pos+3], self.buffer[self.pos+2], self.buffer[self.pos+1], self.buffer[self.pos] = ByterizeInt(x)
	self.pos = self.pos + 4
end

--- Writes a 4 byte IEEE754 float to the byte stream and advances the buffer pointer.
--@param x The float to write
function ss_methods:writeFloat(x)
	self.buffer[self.pos], self.buffer[self.pos+1], self.buffer[self.pos+2], self.buffer[self.pos+3] = PackIEEE754Float(x)
	self.pos = self.pos + 4
end

--- Writes a string to the buffer putting a null at the end and advances the buffer pointer.
function ss_methods:writeString(string)
	self:write(string)
	self:writeInt8(0)
end

--- Returns the buffer as a string
function ss_methods:getString()
   return string.char(unpack(self.buffer))
end

--- Returns the internal buffer
function ss_methods:getBuffer()
   return self.buffer
end
