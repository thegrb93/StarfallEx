-- FastLZ library

--- FastLZ library
-- @shared
local fastlz_library = SF.Libraries.Register("fastlz")
local util = util

--- Compress string using FastLZ
--@param s String to compress
--@return FastLZ compressed string
function fastlz_library.compress (s)
	SF.CheckLuaType(s, TYPE_STRING)
	return util.Compress(s)
end

--- Decompress using FastLZ
-- @param s FastLZ compressed string to decode
-- @return Decompressed string
function fastlz_library.decompress (s)
	SF.CheckLuaType(s, TYPE_STRING)
	return util.Decompress(s)
end
