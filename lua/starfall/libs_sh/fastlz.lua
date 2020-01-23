local util = util

-- Local to each starfall
return { function(instance) -- Called for library declarations


--- FastLZ library
-- @shared
local fastlz_library = instance:RegisterLibrary("fastlz")


end, function(instance) -- Called for library definitions


local fastlz_library = instance.Libraries.fastlz

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

end}
