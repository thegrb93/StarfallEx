local util = util

local max_json = CreateConVar("sf_json_maxsize", 16, FCVAR_ARCHIVE, "The max megabytes of json data able to be encoded/decoded.")

--- JSON library
-- @name json
-- @class library
-- @libtbl json_library
SF.RegisterLibrary("json")


return function(instance)
local json_library = instance.Libraries.json

local function CheckCyclic(tbl, parents)
    parents[tbl] = true
    for _, v in pairs(tbl) do
        if type(v) == "table" then
            if parents[v] then SF.Throw("Cannot encode a table with cyclic references", 2) end
            CheckCyclic(v, parents)
        end
    end
    parents[tbl] = nil
end
--- Convert table to JSON string
-- @param table tbl Table to encode
-- @param boolean? prettyPrint Optional. If true, formats and indents the resulting JSON
-- @return string JSON encoded string representation of the table
function json_library.encode(tbl, prettyPrint)
	SF.CheckLuaType(tbl, TYPE_TABLE)
	if #SF.TableToString(tbl, instance) > max_json:GetInt()*1e6 then SF.Throw("Input table data size exceeds max allowed!", 2) end
	CheckCyclic(tbl, {}) --https://github.com/Facepunch/garrysmod-issues/issues/6259

	return util.TableToJSON(instance.Unsanitize(tbl), prettyPrint)
end

--- Convert JSON string to table
-- @param string s String to decode
-- @return table Table representing the JSON object
function json_library.decode(s)
	SF.CheckLuaType(s, TYPE_STRING)
	if #s > max_json:GetInt()*1e6 then SF.Throw("Input json data exceeds max allowed!", 2) end
	return instance.Sanitize(util.JSONToTable(s))
end

end
