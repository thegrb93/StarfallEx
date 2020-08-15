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
	SF.CheckLuaType(s, TYPE_STRING)
	return util.Compress(s)
end

--- Decompress using FastLZ
-- @param s FastLZ compressed string to decode
-- @return Decompressed string
function fastlz_library.decompress(s)
	SF.CheckLuaType(s, TYPE_STRING)
	return util.Decompress(s)
end

end
