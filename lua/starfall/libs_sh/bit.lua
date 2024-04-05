-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local math_huge = math.huge
local math_frexp = math.frexp
local math_ldexp = math.ldexp
local math_floor = math.floor
local math_min = math.min
local math_max = math.max
local bit_rshift = bit.rshift

--- StringStream type
-- @name StringStream
-- @class type
-- @libtbl ss_methods

local ss_methods = {}
local ss_meta = {
	__index = ss_methods,
	__metatable = "StringStream",
	__tostring = function(self)
		return string.format("Stringstream [%u,%u]", self:tell(), self:size())
	end
}
local ss_methods_big = setmetatable({},{__index=ss_methods})
local ss_meta_big = {
	__index = ss_methods_big,
	__metatable = "StringStream",
	__tostring = function(self)
		return string.format("Stringstream [%u,%u]", self:tell(), self:size())
	end
}

function SF.StringStream(stream, i, endian)
	local ret = setmetatable({
		index = 1,
		subindex = 1
	}, ss_meta)

	if stream ~= nil then
		checkluatype(stream, TYPE_STRING)
		ret:write(stream)
		if i~=nil then checkluatype(i, TYPE_NUMBER) ret:seek(i) else ret:seek(1) end
	end
	if endian ~= nil then
		checkluatype(endian, TYPE_STRING)
		ret:setEndian(endian)
	end

	return ret
end

--Credit https://stackoverflow.com/users/903234/rpfeltz
--Bugfixes and IEEE754Double credit to me
local function PackIEEE754Float(number)
	if number == 0 then
		return 0x00, 0x00, 0x00, 0x00
	elseif number == math_huge then
		return 0x00, 0x00, 0x80, 0x7F
	elseif number == -math_huge then
		return 0x00, 0x00, 0x80, 0xFF
	elseif number ~= number then
		return 0x00, 0x00, 0xC0, 0xFF
	else
		local sign = 0x00
		if number < 0 then
			sign = 0x80
			number = -number
		end
		local mantissa, exponent = math_frexp(number)
		exponent = exponent + 0x7F
		if exponent <= 0 then
			mantissa = math_ldexp(mantissa, exponent - 1)
			exponent = 0
		elseif exponent > 0 then
			if exponent >= 0xFF then
				return 0x00, 0x00, 0x80, sign + 0x7F
			elseif exponent == 1 then
				exponent = 0
			else
				mantissa = mantissa * 2 - 1
				exponent = exponent - 1
			end
		end
		mantissa = math_floor(math_ldexp(mantissa, 23) + 0.5)
		return mantissa % 0x100,
				bit_rshift(mantissa, 8) % 0x100,
				(exponent % 2) * 0x80 + bit_rshift(mantissa, 16),
				sign + bit_rshift(exponent, 1)
	end
end
local function UnpackIEEE754Float(b4, b3, b2, b1)
	local exponent = (b1 % 0x80) * 0x02 + bit_rshift(b2, 7)
	local mantissa = math_ldexp(((b2 % 0x80) * 0x100 + b3) * 0x100 + b4, -23)
	if exponent == 0xFF then
		if mantissa > 0 then
			return 0 / 0
		else
			if b1 >= 0x80 then
				return -math_huge
			else
				return math_huge
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
	return math_ldexp(mantissa, exponent - 0x7F)
end
local function PackIEEE754Double(number)
	if number == 0 then
		return 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	elseif number == math_huge then
		return 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF0, 0x7F
	elseif number == -math_huge then
		return 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF0, 0xFF
	elseif number ~= number then
		return 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF8, 0xFF
	else
		local sign = 0x00
		if number < 0 then
			sign = 0x80
			number = -number
		end
		local mantissa, exponent = math_frexp(number)
		exponent = exponent + 0x3FF
		if exponent <= 0 then
			mantissa = math_ldexp(mantissa, exponent - 1)
			exponent = 0
		elseif exponent > 0 then
			if exponent >= 0x7FF then
				return 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xF0, sign + 0x7F
			elseif exponent == 1 then
				exponent = 0
			else
				mantissa = mantissa * 2 - 1
				exponent = exponent - 1
			end
		end
		mantissa = math_floor(math_ldexp(mantissa, 52) + 0.5)
		return mantissa % 0x100,
				math_floor(mantissa / 0x100) % 0x100,  --can only rshift up to 32 bit numbers. mantissa is too big
				math_floor(mantissa / 0x10000) % 0x100,
				math_floor(mantissa / 0x1000000) % 0x100,
				math_floor(mantissa / 0x100000000) % 0x100,
				math_floor(mantissa / 0x10000000000) % 0x100,
				(exponent % 0x10) * 0x10 + math_floor(mantissa / 0x1000000000000),
				sign + bit_rshift(exponent, 4)
	end
end
local function UnpackIEEE754Double(b8, b7, b6, b5, b4, b3, b2, b1)
	local exponent = (b1 % 0x80) * 0x10 + bit_rshift(b2, 4)
	local mantissa = math_ldexp(((((((b2 % 0x10) * 0x100 + b3) * 0x100 + b4) * 0x100 + b5) * 0x100 + b6) * 0x100 + b7) * 0x100 + b8, -52)
	if exponent == 0x7FF then
		if mantissa > 0 then
			return 0 / 0
		else
			if b1 >= 0x80 then
				return -math_huge
			else
				return math_huge
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
	return math_ldexp(mantissa, exponent - 0x3FF)
end

--- Sets the endianness of the string stream
-- @param string endian The endianness of number types. "big" or "little" (default "little")
function ss_methods:setEndian(endian)
	if endian == "little" then
		debug.setmetatable(self, ss_meta)
	elseif endian == "big" then
		debug.setmetatable(self, ss_meta_big)
	else
		error("Invalid endian specified", 2)
	end
end

--- Writes the given string and advances the buffer pointer.
-- @param string data A string of data to write
function ss_methods:write(data)
	if self.index > #self then -- Most often case
		self[self.index] = data
		self.index = self.index + 1
		self.subindex = 1
	else
		local i = 1
		local length = #data
		while length > 0 do
			if self.index > #self then -- End of buffer
				self[self.index] = string.sub(data, i)
				self.index = self.index + 1
				self.subindex = 1
				break
			else
				local cur = self[self.index]
				local sublength = math_min(#cur - self.subindex + 1, length)
				self[self.index] = string.sub(cur,1,self.subindex-1) .. string.sub(data,i,i+sublength-1) .. string.sub(cur,self.subindex+sublength)
				length = length - sublength
				i = i + sublength
				if length > 0 then
					self.index = self.index + 1
					self.subindex = 1
				else
					self.subindex = self.subindex + sublength
				end
			end
		end
	end
end

--- Reads the specified number of bytes from the buffer and advances the buffer pointer.
-- @param number length How many bytes to read
-- @return string A string containing the bytes
function ss_methods:read(length)
	local ret = {}
	while length > 0 do
		local cur = self[self.index]
		if cur then
			if self.subindex == 1 and length >= #cur then
				ret[#ret+1] = cur
				self.index = self.index + 1
				length = length - #cur
			else
				local sublength = math_min(#cur - self.subindex + 1, length)
				ret[#ret+1] = string.sub(cur, self.subindex, self.subindex + sublength - 1)
				length = length - sublength
				if length > 0 then
					self.index = self.index + 1
					self.subindex = 1
				else
					self.subindex = self.subindex + sublength
				end
			end
		else
			break
		end
	end
	return table.concat(ret)
end

--- Sets internal pointer to pos. The position will be clamped to [1, buffersize+1]
-- @param number pos Position to seek to
function ss_methods:seek(pos)
	if pos < 1 then error("Index must be 1 or greater", 2) end
	self.index = #self+1
	self.subindex = 1

	local length = 0
	for i, v in ipairs(self) do
		length = length + #v
		if length >= pos then
			self.index = i
			self.subindex = pos - (length - #v)
			break
		end
	end
end

--- Move the internal pointer by amount i
-- @param number length The offset
function ss_methods:skip(length)
	while length>0 do
		local cur = self[self.index]
		if cur then
			local sublength = math_min(#cur - self.subindex + 1, length)
			length = length - sublength
			self.subindex = self.subindex + sublength
			if self.subindex>#cur then
				self.index = self.index + 1
				self.subindex = 1
			end
		else
			self.index = self.index + 1
			self.subindex = 1
			break
		end
	end
	while length<0 do
		local cur = self[self.index]
		if cur then
			local sublength = math_max(-self.subindex, length)
			length = length - sublength
			self.subindex = self.subindex + sublength
			if self.subindex<1 then
				self.index = self.index - 1
				self.subindex = self[self.index] and #self[self.index] or 1
			end
		else
			self.index = 1
			self.subindex = 1
			break
		end
	end
end

--- Returns the internal position of the byte reader.
-- @return number The buffer position
function ss_methods:tell()
	local length = 0
	for i=1, self.index-1 do
		length = length + #self[i]
	end
	return length + self.subindex
end

--- Tells the size of the byte stream.
-- @return number The buffer size
function ss_methods:size()
	local length = 0
	for i, v in ipairs(self) do
		length = length + #v
	end
	return length
end

--- Reads an unsigned 8-bit (one byte) integer from the byte stream and advances the buffer pointer.
-- @return number UInt8 at this position
function ss_methods:readUInt8()
	return string.byte(self:read(1))
end
function ss_methods_big:readUInt8()
	return string.byte(self:read(1))
end

--- Reads an unsigned 16 bit (two byte) integer from the byte stream and advances the buffer pointer.
-- @return number UInt16 at this position
function ss_methods:readUInt16()
	local a,b = string.byte(self:read(2), 1, 2)
	return b * 0x100 + a
end
function ss_methods_big:readUInt16()
	local a,b = string.byte(self:read(2), 1, 2)
	return a * 0x100 + b
end

--- Reads an unsigned 32 bit (four byte) integer from the byte stream and advances the buffer pointer.
-- @return number UInt32 at this position
function ss_methods:readUInt32()
	local a,b,c,d = string.byte(self:read(4), 1, 4)
	return d * 0x1000000 + c * 0x10000 + b * 0x100 + a
end
function ss_methods_big:readUInt32()
	local a,b,c,d = string.byte(self:read(4), 1, 4)
	return a * 0x1000000 + b * 0x10000 + c * 0x100 + d
end

--- Reads a signed 8-bit (one byte) integer from the byte stream and advances the buffer pointer.
-- @return number Int8 at this position
function ss_methods:readInt8()
	local x = self:readUInt8()
	if x>=0x80 then x = x - 0x100 end
	return x
end

--- Reads a signed 16-bit (two byte) integer from the byte stream and advances the buffer pointer.
-- @return number Int16 at this position
function ss_methods:readInt16()
	local x = self:readUInt16()
	if x>=0x8000 then x = x - 0x10000 end
	return x
end

--- Reads a signed 32-bit (four byte) integer from the byte stream and advances the buffer pointer.
-- @return number Int32 at this position
function ss_methods:readInt32()
	local x = self:readUInt32()
	if x>=0x80000000 then x = x - 0x100000000 end
	return x
end

--- Reads a 4 byte IEEE754 float from the byte stream and advances the buffer pointer.
-- @return number Float32 at this position
function ss_methods:readFloat()
	return UnpackIEEE754Float(string.byte(self:read(4), 1, 4))
end
function ss_methods_big:readFloat()
	local a,b,c,d = string.byte(self:read(4), 1, 4)
	return UnpackIEEE754Float(d, c, b, a)
end

--- Reads a 8 byte IEEE754 double from the byte stream and advances the buffer pointer.
-- @return number Double at this position
function ss_methods:readDouble()
	return UnpackIEEE754Double(string.byte(self:read(8), 1, 8))
end
function ss_methods_big:readDouble()
	local a,b,c,d,e,f,g,h = string.byte(self:read(8), 1, 8)
	return UnpackIEEE754Double(h, g, f, e, d, c, b, a)
end

--- Reads until the given byte and advances the buffer pointer.
-- @param number byte The byte to read until (in number form)
-- @return string The string of bytes read
function ss_methods:readUntil(byte)
	byte = string.char(byte)
	local ret = {}
	for i=self.index, #self do
		local cur = self[self.index]
		local find = string.find(cur, byte, self.subindex, true)
		if find then
			ret[#ret+1] = string.sub(cur, self.subindex, find)
			self.subindex = find+1
			if self.subindex > #cur then
				self.index = self.index + 1
				self.subindex = 1
			end
			break
		else
			if self.subindex == 1 then
				ret[#ret+1] = cur
			else
				ret[#ret+1] = string.sub(cur, self.subindex)
			end
			self.index = self.index + 1
			self.subindex = 1
		end
	end
	return table.concat(ret)
end

--- Returns a null terminated string, reads until "\x00" and advances the buffer pointer.
-- @return string The string of bytes read
function ss_methods:readString()
	local s = self:readUntil(0)
	return string.sub(s, 1, #s-1)
end

--- Writes a byte to the buffer and advances the buffer pointer.
-- @param number x Int8 to write
function ss_methods:writeInt8(x)
	if x==math_huge or x==-math_huge or x~=x then error("Can't convert error float to integer!", 2) end
	if x < 0 then x = x + 0x100 end
	self:write(string.char(x%0x100))
end

--- Writes a unsigned byte to the buffer and advances the buffer pointer.
-- @name ss_methods.writeUInt8
-- @class function
-- @param number x UInt8 to write
ss_methods.writeUInt8 = ss_methods.writeInt8

--- Writes a short to the buffer and advances the buffer pointer.
-- @param number x Int16 to write
function ss_methods:writeInt16(x)
	if x==math_huge or x==-math_huge or x~=x then error("Can't convert error float to integer!", 2) end
	if x < 0 then x = x + 0x10000 end
	self:write(string.char(x%0x100, bit_rshift(x, 8)%0x100))
end
function ss_methods_big:writeInt16(x)
	if x==math_huge or x==-math_huge or x~=x then error("Can't convert error float to integer!", 2) end
	if x < 0 then x = x + 0x10000 end
	self:write(string.char(bit_rshift(x, 8)%0x100, x%0x100))
end

--- Writes a unsigned short to the buffer and advances the buffer pointer.
-- @name ss_methods.writeUInt16
-- @class function
-- @param number x UInt16 to write
ss_methods.writeUInt16 = ss_methods.writeInt16

--- Writes an int to the buffer and advances the buffer pointer.
-- @param number x Int32 to write
function ss_methods:writeInt32(x)
	if x==math_huge or x==-math_huge or x~=x then error("Can't convert error float to integer!", 2) end
	if x < 0 then x = x + 0x100000000 end
	self:write(string.char(x%0x100, bit_rshift(x, 8)%0x100, bit_rshift(x, 16)%0x100, bit_rshift(x, 24)%0x100))
end
function ss_methods_big:writeInt32(x)
	if x==math_huge or x==-math_huge or x~=x then error("Can't convert error float to integer!", 2) end
	if x < 0 then x = x + 0x100000000 end
	self:write(string.char(bit_rshift(x, 24)%0x100, bit_rshift(x, 16)%0x100, bit_rshift(x, 8)%0x100, x%0x100))
end

--- Writes a unsigned long to the buffer and advances the buffer pointer.
-- @name ss_methods.writeUInt32
-- @class function
-- @param number x UInt32 to write
ss_methods.writeUInt32 = ss_methods.writeInt32

--- Writes a 4 byte IEEE754 float to the byte stream and advances the buffer pointer.
-- @param number x The float to write
function ss_methods:writeFloat(x)
	self:write(string.char(PackIEEE754Float(x)))
end
function ss_methods_big:writeFloat(x)
	local a,b,c,d = PackIEEE754Float(x)
	self:write(string.char(d,c,b,a))
end

--- Writes a 8 byte IEEE754 double to the byte stream and advances the buffer pointer.
-- @param number x The double to write
function ss_methods:writeDouble(x)
	self:write(string.char(PackIEEE754Double(x)))
end
function ss_methods_big:writeDouble(x)
	local a,b,c,d,e,f,g,h = PackIEEE754Double(x)
	self:write(string.char(h,g,f,e,d,c,b,a))
end

--- Writes a string to the buffer putting a null at the end and advances the buffer pointer.
-- @param string str The string of bytes to write
function ss_methods:writeString(str)
	self:write(str)
	self:write("\0")
end

--- Writes an entity to the buffer and advances the buffer pointer.
-- @name ss_methods.writeEntity
-- @class function
-- @param Entity e The entity to be written
local function writeEntity(self, instance, e)
	local ent = instance.Types.Entity.GetEntity(e)
	self:writeInt16(ent:EntIndex())
	self:writeInt32(ent:GetCreationID())
end
	
--- Reads an entity from the byte stream and advances the buffer pointer.
-- @name ss_methods.readEntity
-- @class function
-- @param function? callback (Client only) optional callback to be ran whenever the entity becomes valid; returns nothing if this is used. The callback passes the entity if it succeeds or nil if it fails.
-- @return Entity The entity that was read
local function readEntity(self, instance, callback)
	local index = self:readUInt16()
	local creationindex = self:readUInt32()
	if callback ~= nil and CLIENT then
		checkluatype(callback, creationindex, TYPE_FUNCTION)
		SF.WaitForEntity(index, function(ent)
			if ent ~= nil then ent = instance.WrapObject(ent) end
			instance:runFunction(callback, ent)
		end)
	else
		return instance.WrapObject(Entity(index))
	end
end

--- Returns the buffer as a string
-- @return string The buffer as a string
function ss_methods:getString()
	return table.concat(self)
end


--- Bit library http://wiki.facepunch.com/gmod/Category:bit
-- @name bit
-- @class library
-- @libtbl bit_library
SF.RegisterLibrary("bit")


return function(instance)

local bit_library = instance.Libraries.bit
--- Returns the arithmetically shifted value.
-- @class function
-- @param number value The value to be manipulated.
-- @param number shiftCount Amount of bits to shift
-- @return number shiftedValue
bit_library.arshift = bit.arshift

--- Performs the bitwise "and" for all values specified.
-- @class function
-- @param number value The value to be manipulated.
-- @param ...number otherValues Values bit to perform bitwise "and" with. Optional.
-- @return number Result of bitwise "and" operation.
bit_library.band = bit.band

--- Returns the bitwise not of the value.
-- @class function
-- @param number value The value to be inverted.
-- @return number Return value of bitwise not operation
bit_library.bnot = bit.bnot

--- Returns the bitwise OR of all values specified.
-- @class function
-- @param number value1 The first value.
-- @param ...number Extra values to be evaluated. (must all be numbers)
-- @return number The bitwise OR result between all numbers.
bit_library.bor = bit.bor

--- Swaps the byte order.
-- @class function
-- @param number value The value to be byte swapped.
-- @return number Bit swapped value
bit_library.bswap = bit.bswap

--- Returns the bitwise xor of all values specified.
-- @class function
-- @param number value The value to be manipulated.
-- @param ...number otherValues Values to bit xor with. Optional.
-- @return number Return value of bitwiseXOr operation
bit_library.bxor = bit.bxor

--- Returns the left shifted value.
-- @class function
-- @param number value The value to be manipulated.
-- @param number shiftCount Amounts of bits to shift left by.
-- @return number Return of bitwise lshift operation
bit_library.lshift = bit.lshift

--- Returns the left rotated value.
-- @class function
-- @param number value The value to be manipulated.
-- @param number shiftCount Amounts of bits to rotate left by.
-- @return number Left rotated value
bit_library.rol = bit.rol

--- Returns the right rotated value.
-- @class function
-- @param number value The value to be manipulated.
-- @param number shiftCount Amounts of bits to rotate right by.
-- @return number Right rotated value
bit_library.ror = bit.ror

--- Returns the right shifted value.
-- @class function
-- @param number value The value to be manipulated.
-- @param number shiftCount Amounts of bits to shift right by.
-- @return number Right shifted value
bit_library.rshift = bit_rshift

--- Normalizes the specified value and clamps it in the range of a signed 32bit integer.
-- @class function
-- @param number value The value to be normalized.
-- @return number Bit swapped value
bit_library.tobit = bit.tobit

--- Returns the hexadecimal representation of the number with the specified digits.
-- @class function
-- @param number value The value to be normalized.
-- @param number? digits The number of digits. Optional. (default 8)
-- @return string Hex string.
bit_library.tohex = bit.tohex


--- Creates a StringStream object
-- @name bit_library.stringstream
-- @class function
-- @param string stream String to set the initial buffer to (default "")
-- @param number i The initial buffer pointer (default 1)
-- @param string endian The endianness of number types. "big" or "little" (default "little")
-- @return StringStream StringStream object
function bit_library.stringstream(stream, i, endian)
	local ret = SF.StringStream(stream, i, endian)
	function ret:writeEntity(e)
		writeEntity(self, instance, e)
	end
	function ret:readEntity(callback)
		return readEntity(self, instance, callback)
	end
	return ret
end

--- Converts a table to string serializing data types as best as it can
-- @param table t The table to serialize
-- @return string Serialized data
function bit_library.tableToString(t)
	checkluatype(t, TYPE_TABLE)
	return SF.TableToString(t, instance)
end

--- Converts serialized string data to table
-- @param string s The serialized string data
-- @return table The deserialized table
function bit_library.stringToTable(s)
	checkluatype(s, TYPE_STRING)
	return SF.StringToTable(s, instance)
end

--- Compresses a string using LZMA.
-- @param string s String to compress
-- @return string? Compressed string, or nil if compression failed
function bit_library.compress(s)
	checkluatype(s, TYPE_STRING)
	if #s > 1e8 then SF.Throw("String is too long!") end
	local ret = util.Compress(s)
	instance:checkCpu()
	return ret
end

--- Decompresses a string using LZMA.
-- XZ Utils will always produce streamed (i.e. the decompressed size is not specified in the header) LZMA data. If you're trying to compress data from outside of GMod and then decompress it inside of GMod, it probably won't work unless you use the older, deprecated 'LZMA Utils', or util.Compress.
-- @param string s String to decompress
-- @param number? maxSize Maximum allowed size of decompressed data
-- @return string? Decompressed string, or nil if decompression failed
function bit_library.decompress(s, maxSize)
	checkluatype(s, TYPE_STRING)
	if maxSize ~= nil then
		checkluatype(maxSize, TYPE_NUMBER)
		if maxSize > 1e8 then
			SF.Throw("specified maximum size is too large")
		end
	else
		maxSize = 1e8
	end
	if #s > 1e8 then SF.Throw("String is too long!") end
	if #s <= 13 then return nil end -- Size of header is 13 bytes, so it can't possibly have any data if it's that size or smaller.
	if string.sub(s, 6, 13) == '\xff\xff\xff\xff\xff\xff\xff\xff' then
		return nil--, "streamed LZMA is not supported"
	end
	local ret = util.Decompress(s, maxSize)
	instance:checkCpu()
	return ret
end

--- Generates the MD5 Checksum of the specified string.
-- @param string s The string to calculate the checksum of.
-- @return string The MD5 hex string of the checksum.
function bit_library.md5(s)
	checkluatype(s, TYPE_STRING)
	if #s > 1e8 then SF.Throw("String is too long!") end
	local ret = util.MD5(s)
	instance:checkCpu()
	return ret
end

--- Generates the SHA-256 Checksum of the specified string.
-- @param string s The string to calculate the checksum of.
-- @return string The SHA-256 hex string of the checksum.
function bit_library.sha256(s)
	checkluatype(s, TYPE_STRING)
	if #s > 1e8 then SF.Throw("String is too long!") end
	local ret = util.SHA256(s)
	instance:checkCpu()
	return ret
end

--- Generates the SHA-1 Checksum of the specified string.
-- @param string s The string to calculate the checksum of.
-- @return string The SHA-1 hex string of the checksum.
function bit_library.sha1(s)
	checkluatype(s, TYPE_STRING)
	if #s > 1e8 then SF.Throw("String is too long!") end
	local ret = util.SHA1(s)
	instance:checkCpu()
	return ret
end

end
