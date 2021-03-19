local checkluatype = SF.CheckLuaType

SF.Permissions.registerPrivilege("sql", "Perform actions on the local SQLite database.", "Allows users to perform actions on the local SQLite database.", { client = { default = 1 } })

--- SQL library.
-- @name sql
-- @class library
-- @libtbl sql_library
SF.RegisterLibrary("sql")


return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local sql_library = instance.Libraries.sql

--- Performs a query on the local SQLite database.
-- @param string query The query to execute.
-- @return table? Query results as a table, nil if the query returned no data.
function sql_library.query(query)
	checkpermission(instance, nil, "sql")
	checkluatype(query, TYPE_STRING)

	local query = sql.Query(query)

	if query == false then
		SF.Throw("Error running query: " .. sql.LastError(), 2)
	end
	return query
end

--- Checks if a table exists within the local SQLite database.
-- @param string tabname The table to check for.
-- @return boolean False if the table does not exist, true if it does.
function sql_library.tableExists(tabname)
	checkpermission(instance, nil, "sql")
	checkluatype(tabname, TYPE_STRING)
	
	return sql.TableExists(tabname)
end

--- Removes a table within the local SQLite database.
-- @param string tabname The table to remove.
-- @return boolean True if the table was successfully removed, false if not.
function sql_library.tableRemove(tabname)
	checkpermission(instance, nil, "sql")
	checkluatype(tabname, TYPE_STRING)
	
	if not sql.TableExists(tabname) then return false end
	sql.Query("DROP TABLE " .. tabname)
	return true
end

--- Escapes dangerous characters and symbols from user input used in an SQLite SQL Query.
-- @param string str The string to be escaped.
-- @param boolean bNoQuotes Set this as true, and the function will not wrap the input string in apostrophes.
-- @return string The escaped input.
function sql_library.SQLStr(str, bNoQuotes)
	checkpermission(instance, nil, "sql")
	checkluatype(str, TYPE_STRING)
	checkluatype(bNoQuotes, TYPE_BOOL)
	
	return sql.SQLStr(str, bNoQuotes)
end

end
