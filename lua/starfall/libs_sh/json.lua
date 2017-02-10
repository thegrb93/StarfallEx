--- JSON library

--- JSON library
-- @shared
local json_library = SF.Libraries.Register( "json" )
local util = util

--- Convert table to JSON string
--@param tbl Table to encode
--@return JSON encoded string representation of the table
function json_library.encode ( tbl )
	SF.CheckType( tbl, "table" )
	return util.TableToJSON( SF.Unsanitize( tbl ) )
end

--- Convert JSON string to table
-- @param s String to decode
-- @return Table representing the JSON object
function json_library.decode ( s )
	SF.CheckType( s, "string" )
	return SF.Sanitize( util.JSONToTable( s ) )
end
