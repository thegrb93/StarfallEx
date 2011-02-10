local module_builtins = {}

-- ------------------------------------ --
-- Number Type                          --
-- ------------------------------------ --
-- Nothing fancy here

local Number = {}
Number.type = "Number"
function Number:__construct(data)
	return tonumber(data) or error("<ArgumentError> Can't convert "..SFLib.GetType(data).." to number.")
end

-- Operators --
-- Built into Lua's number type

module_builtins.Number = Number

-- ------------------------------------ --
-- String Type                          --
-- ------------------------------------ --
local String = {}
String.type = "String"

-- Operators --
-- Need to alias .. with +
String.__alias_concat = true

-- ------------------------------------ --
-- Vector Type                          --
-- ------------------------------------ --

local sfvector = {}
sfvector.__index = sfvector
sfvector.type = "Vector"

function sfvector:__construct(x,y,z)
	local v = setmetatable({},sfvector)
	v.x = tonumber(x) or error("<ArugmentError> Can't convert "..SFLib.GetType(x).."to number.")
	v.y = tonumber(y) or error("<ArugmentError> Can't convert "..SFLib.GetType(x).."to number.")
	v.z = tonumber(z) or error("<ArugmentError> Can't convert "..SFLib.GetType(x).."to number.")
	return v
end

-- Operators --

function sfvector:__add(other)
	if SFLib.GetType(other) == "Vector" then
		return sfvector:__construct(self.x+other.x, self.y+other.y, self.z+other.z)
	else
		error("<ArgumentError> Can't add Vector and "..SFLib.GetType(other))
	end
end

function sfvector:__sub(other)
	if SFLib.GetType(other) == "Vector" then
		return sfvector:__construct(self.x-other.x, self.y-other.y, self.z-other.z)
	else
		error("<ArgumentError> Can't subtract Vector and "..SFLib.GetType(other))
	end
end

function sfvector:__mul(other)
	local num = tonumber(other) or error("<ArgumentError> Can't multiply Vector and "..SFLib.GetType(other))
	return sfvector:__construct(self.x*num, self.y*num, self.y*num)
end

function sfvector:__div(other)
	local num = tonumber(other) or error("<ArgumentError> Can't divide Vector and "..SFLib.GetType(other))
	return sfvector:__construct(self.x/num, self.y/num, self.y/num)
end

-- Methods --

function sfvector:x()
	return self.x
end

function sfvector:y()
	return self.y
end

function sfvector:z()
	return self.z()
end

local sqrt = math.sqrt
function sfvector:length()
	return sqrt(self.x*self.x + self.y*self.y + self.z*self.z)
end

function sfvector:length2()
	return self.x*self.x + self.y*self.y + self.z*self.z
end

module_builtins.Vector = sfvector