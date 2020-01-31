-- Global to all starfalls
local checkluatype = SF.CheckLuaType

--- StringStream type
-- @name StringStream
-- @class type
-- @libtbl ss_methods

local ss_methods = {}
local ss_meta = {
	__index = ss_methods,
	__metatable = "StringStream",
	__tostring = function(self)
		return string.format("Stringstream [%u,%u]",self.pos, #self.buffer)
	end
}
function SF.StringStream(stream, i, endian)
	if stream~=nil then checkluatype(stream, TYPE_STRING) else stream = "" end
	if i~=nil then checkluatype(i, TYPE_NUMBER) else i = 1 end
	
	local ret = setmetatable({
		buffer = {},
		pos = 1
	}, ss_meta)
	
	ret:write(stream)
	ret:seek(i)
	ret:setEndian(endian or "little")
	
	return ret
end

local function checkErr(n)
	if n==math.huge or n==-math.huge or n~=n then
		SF.Throw("Can't convert error float to integer!", 4)
	end
end

local function ByterizeInt(n)
	checkErr(n)
	n = (n < 0) and (4294967296 + n) or n
	return math.floor(n/16777216)%256, math.floor(n/65536)%256, math.floor(n/256)%256, n%256
end

local function ByterizeShort(n)
	checkErr(n)
	n = (n < 0) and (65536 + n) or n
	return math.floor(n/256)%256, n%256
end

local function ByterizeByte(n)
	checkErr(n)
	n = (n < 0) and (256 + n) or n
	return n%256
end

local function twos_compliment(x,bits)
	local limit = math.ldexp(1, bits - 1)
	if x>limit then return x - limit*2 else return x end
end

local function toString(buffer, start, stop)
	-- Max unpack is 7997
	local chartbl = {}
	for i=start, stop, 7997 do
		chartbl[#chartbl + 1] = string.char(unpack(buffer, i, math.min(i+7997-1, stop)))
	end
	return table.concat(chartbl)
end

local function fromString(str, buffer, p)
	-- Max string.byte is 8000
	for i=1, #str, 8000 do
		local b = {string.byte(str, i, math.min(i+8000-1, #str))}
		for o=1, #b do
			buffer[p] = b[o]
			p = p + 1
		end
	end
end

--Credit https://stackoverflow.com/users/903234/rpfeltz
--Bugfixes and IEEE754Double credit to me
local function PackIEEE754Float(number)
	if number == 0 then
		return 0x00, 0x00, 0x00, 0x00
	elseif number == math.huge then
		return 0x7F, 0x80, 0x00, 0x00
	elseif number == -math.huge then
		return 0xFF, 0x80, 0x00, 0x00
	elseif number ~= number then
		return 0xFF, 0xC0, 0x00, 0x00
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
				return sign + 0x7F, 0x80, 0x00, 0x00
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
	elseif number == math.huge then
		return 0x7F, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	elseif number == -math.huge then
		return 0xFF, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	elseif number ~= number then
		return 0xFF, 0xF8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	else
		local sign = 0x00
		if number < 0 then
			sign = 0x80
			number = -number
		end
		local mantissa, exponent = math.frexp(number)
		exponent = exponent + 0x3FF
		if exponent <= 0 then
			mantissa = math.ldexp(mantissa, exponent - 1)
			exponent = 0
		elseif exponent > 0 then
			if exponent >= 0x7FF then
				return sign + 0x7F, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
			elseif exponent == 1 then
				exponent = 0
			else
				mantissa = mantissa * 2 - 1
				exponent = exponent - 1
			end
		end
		mantissa = math.floor(math.ldexp(mantissa, 52) + 0.5)
		return sign + math.floor(exponent / 0x10),
				(exponent % 0x10) * 0x10 + math.floor(mantissa / 0x1000000000000),
				math.floor(mantissa / 0x10000000000) % 0x100,
				math.floor(mantissa / 0x100000000) % 0x100,
				math.floor(mantissa / 0x1000000) % 0x100,
				math.floor(mantissa / 0x10000) % 0x100,
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

--- Sets the endianness of the string stream
--@param endian The endianness of number types. "big" or "little" (default "little")
function ss_methods:setEndian(endian)
	if endian == "little" then
		function self:readBytesEndian(start, stop)
			local t = {}
			for i=stop, start, -1 do
				t[#t+1] = self.buffer[i]
			end
			return t
		end
		function self:writeBytesEndian(start, stop, t)
			local o = #t
			for i=start, stop do
				self.buffer[i] = t[o]
				o = o - 1
			end
		end
	elseif endian == "big" then
		function self:readBytesEndian(start, stop)
			local t = {}
			for i=start, stop do
				t[#t+1] = self.buffer[i]
			end
			return t
		end
		function self:writeBytesEndian(start, stop, t)
			local o = 1
			for i=start, stop do
				self.buffer[i] = t[o]
				o = o + 1
			end
		end
	else
		SF.Throw("Invalid endian specified", 2)
	end
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
	local str = toString(self.buffer, self.pos, self.pos+n-1)
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
	local t = self:readBytesEndian(self.pos, self.pos+1)
	self.pos = self.pos + 2
	return t[1] * 0x100 + t[2]
end

--- Reads an unsigned 32 bit (four byte) integer from the byte stream and advances the buffer pointer.
--@return The uint32 at this position
function ss_methods:readUInt32()
	local t = self:readBytesEndian(self.pos, self.pos+3)
	self.pos = self.pos + 4
	return t[1] * 0x1000000 + t[2] * 0x10000 + t[3] * 0x100 + t[4]
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
	local t = self:readBytesEndian(self.pos, self.pos+3)
	self.pos = self.pos + 4
	return UnpackIEEE754Float(t[1], t[2], t[3], t[4])
end

--- Reads a 4 byte IEEE754 float from the byte stream and advances the buffer pointer.
--@return The float32 at this position
function ss_methods:readDouble()
	local t = self:readBytesEndian(self.pos, self.pos+7)
	self.pos = self.pos + 8
	return UnpackIEEE754Double(t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8])
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
	local str = toString(self.buffer, self.pos, endpos)
	self.pos = endpos + 1
	return str
end

--- returns a null terminated string, reads until "\x00" and advances the buffer pointer.
--@return The string of bytes read
function ss_methods:readString()
	local s = self:readUntil(0)
	return string.sub(s, 1, #s-1)
end

--- Writes the given string and advances the buffer pointer.
--@param bytes A string of bytes to write
function ss_methods:write(bytes)
	fromString(bytes, self.buffer, self.pos)
	self.pos = self.pos + #bytes
end

--- Writes a byte to the buffer and advances the buffer pointer.
--@param x An int8 to write
function ss_methods:writeInt8(x)
	self.buffer[self.pos] = ByterizeByte(x)
	self.pos = self.pos + 1
end

--- Writes a short to the buffer and advances the buffer pointer.
--@param x An int16 to write
function ss_methods:writeInt16(x)
	self:writeBytesEndian(self.pos, self.pos + 1, { ByterizeShort(x) })
	self.pos = self.pos + 2
end

--- Writes an int to the buffer and advances the buffer pointer.
--@param x An int32 to write
function ss_methods:writeInt32(x)
	self:writeBytesEndian(self.pos, self.pos + 3, { ByterizeInt(x) })
	self.pos = self.pos + 4
end

--- Writes a 4 byte IEEE754 float to the byte stream and advances the buffer pointer.
--@param x The float to write
function ss_methods:writeFloat(x)
	self:writeBytesEndian(self.pos, self.pos + 3, { PackIEEE754Float(x) })
	self.pos = self.pos + 4
end

--- Writes a 8 byte IEEE754 double to the byte stream and advances the buffer pointer.
--@param x The double to write
function ss_methods:writeDouble(x)
	self:writeBytesEndian(self.pos, self.pos + 7, { PackIEEE754Double(x) })
	self.pos = self.pos + 8
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
	return toString(self.buffer, 1, #self.buffer)
end

--- Returns the internal buffer
--@return The buffer table
function ss_methods:getBuffer()
	return self.buffer
end


--- Bit library http://wiki.garrysmod.com/page/Category:bit
-- @name bit
-- @class library
-- @libtbl bit_library
SF.RegisterLibrary("bit")


return function(instance)

local bit_library = instance.Libraries.bit
---
-- @class function
bit_library.arshift = bit.arshift
---
-- @class function
bit_library.band = bit.band
---
-- @class function
bit_library.bnot = bit.bnot
---
-- @class function
bit_library.bor = bit.bor
---
-- @class function
bit_library.bswap = bit.bswap
---
-- @class function
bit_library.bxor = bit.bxor
---
-- @class function
bit_library.lshift = bit.lshift
---
-- @class function
bit_library.rol = bit.rol
---
-- @class function
bit_library.ror = bit.ror
---
-- @class function
bit_library.rshift = bit.rshift
---
-- @class function
bit_library.tobit = bit.tobit
---
-- @class function
bit_library.tohex = bit.tohex


--- Creates a StringStream object
--@name bit_library.stringstream
--@class function
--@param stream A string to set the initial buffer to (default "")
--@param i The initial buffer pointer (default 1)
--@param endian The endianness of number types. "big" or "little" (default "little")
bit_library.stringstream = SF.StringStream

end
