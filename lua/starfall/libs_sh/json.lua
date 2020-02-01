local checkluatype = SF.CheckLuaType
local util = util


--- JSON library
-- @name json
-- @class library
-- @libtbl json_library
SF.RegisterLibrary("json")


return function(instance)


local json_library = instance.Libraries.json

--- Convert table to JSON string
--@param tbl Table to encode
--@param prettyPrint Optional. If true, formats and indents the resulting JSON
--@return JSON encoded string representation of the table
function json_library.encode(tbl, prettyPrint)
	checkluatype(tbl, istable)
	return util.TableToJSON(instance.Unsanitize(tbl), prettyPrint)
end

--- Convert JSON string to table
-- @param s String to decode
-- @return Table representing the JSON object
function json_library.decode(s)
	checkluatype(s, isstring)
	return instance.Sanitize(util.JSONToTable(s))
end

end
