--- JSON library

--- JSON library
-- @shared
local json_library = SF.RegisterLibrary("json")
local util = util

--- Convert table to JSON string
--@param tbl Table to encode
--@param prettyPrint Optional. If true, formats and indents the resulting JSON
--@return JSON encoded string representation of the table
function json_library.encode (tbl, prettyPrint)
	SF.CheckLuaType(tbl, TYPE_TABLE)
	return util.TableToJSON(SF.Unsanitize(tbl), prettyPrint)
end

--- Convert JSON string to table
-- @param s String to decode
-- @return Table representing the JSON object
function json_library.decode (s)
	SF.CheckLuaType(s, TYPE_STRING)
	return SF.Sanitize(util.JSONToTable(s))
end
