local checkluatype = SF.CheckLuaType
local util = util

--- FastLZ library
-- @name fastlz
-- @class library
-- @libtbl fastlz_library
SF.RegisterLibrary("fastlz")


return function(instance)


local fastlz_library = instance.Libraries.fastlz

--- Compress string using FastLZ
--@param s String to compress
--@return FastLZ compressed string
function fastlz_library.compress(s)
	checkluatype(s, isstring)
	return util.Compress(s)
end

--- Decompress using FastLZ
-- @param s FastLZ compressed string to decode
-- @return Decompressed string
function fastlz_library.decompress(s)
	checkluatype(s, isstring)
	return util.Decompress(s)
end

end
