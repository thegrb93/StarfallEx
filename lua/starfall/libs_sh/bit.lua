--- Bit library http://wiki.garrysmod.com/page/Category:bit
-- @shared

local checkluatype = SF.CheckLuaType

local bit_methods = SF.RegisterLibrary("bit")
bit_methods.arshift = bit.arshift
bit_methods.band = bit.band
bit_methods.bnot = bit.bnot
bit_methods.bor = bit.bor
bit_methods.bswap = bit.bswap
bit_methods.bxor = bit.bxor
bit_methods.lshift = bit.lshift
bit_methods.rol = bit.rol
bit_methods.ror = bit.ror
bit_methods.rshift = bit.rshift
bit_methods.tobit = bit.tobit
bit_methods.tohex = bit.tohex


--- StringStream type
local ss_methods, ss_metamethods = SF.RegisterType("StringStream")

--- Creates a StringStream object
--@param stream A string to set the initial buffer to (default "")
--@param i The initial buffer pointer (default 1)
function bit_methods.stringstream(stream, i)
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

--- Returns little endian bytes (A B) (all 32 bits)
function bit_methods.GetInt32BytesLE(n)
	local a,b,c,d = ByterizeInt(n)
	return string.char(d,c,b,a)
end

--- Returns little endian bytes (A B) (first two bytes, 16 bits, of number )
function bit_methods.getInt16BytesLE(n)
	local a,b  = ByterizeShort(n)
	return string.char(b,a)
end

--- Returns big endian bytes (A B) (all 32 bits)
function bit_methods.GetInt32BytesBE(n)
	local a,b,c,d = ByterizeInt(n)
	return string.char(a,b,c,d)
end

--- Returns big endian bytes (A B) (first two bytes, 16 bits, of number )
function bit_methods.GetInt16BytesLE(n)
	local a,b  = ByterizeShort(n)
	return string.char(a,b)
end

local function twos_compliment(int,bits)
    local mask = 2^(bits - 1)
    return -(bit.band(int,mask)) + (bit.band(int,bit.bnot(mask)))
end

function ss_metamethods:__tostring()
	return string.format("StarfallBinaryReader [%u,%u]",0,self.Position)
end

--- Sets internal position to i. The position will be clamped to 1-buffersize
function ss_methods:seek(i)
	self.pos = math.Clamp(i, 1, #self.buffer)
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
function ss_methods:writeInt8(int)
	self.buffer[self.pos] = ByterizeByte(int)
	self.pos = self.pos + 1
end

--- Writes a short to the buffer and advances the buffer pointer.
function ss_methods:writeInt16(int)
	self:write(bytestream.GetInt16BytesLE(int))
end

--- Writes an int to the buffer and advances the buffer pointer.
function ss_methods:writeInt32(int)
	self:write(bytestream.GetInt32BytesLE(int))
end

--- Writes a null terminated string to the buffer and advances the buffer pointer.
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
