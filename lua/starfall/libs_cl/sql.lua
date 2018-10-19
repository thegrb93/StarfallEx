--- SQL library.
-- @client

do
	local P = SF.Permissions
	P.registerPrivilege("sql", "Perform actions on the local SQLite database.", "Allows users to perform actions on the local SQLite database.", { client = { default = 1 } })
end

local checktype = SF.CheckType
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check

local sql_library = SF.RegisterLibrary("sql")

--- Performs a query on the local SQLite database.
-- @param query The query to execute.
-- @return Table, false if there is an error, nil if the query returned no data.
function sql_library.query( query )
	local instance = SF.instance
	checkpermission(SF.instance, nil, "sql")
	checkluatype(query, TYPE_STRING)

	local query = sql.Query( query )

	if query == false then return false end
	return query
end

--- Checks if a table exists within the local SQLite database.
-- @param tabname The table to check for.
-- @return False if the table does not exist, true if it does.
function sql_library.tableExists( tabname )
	checkpermission(SF.instance, nil, "sql")
	checkluatype(tabname, TYPE_STRING)
	
	return sql.TableExists( tabname )
end

--- Removes a table within the local SQLite database.
-- @param tabname The table to remove.
-- @return True if the table was successfully removed, false if not.
function sql_library.tableRemove( tabname )
	checkpermission(SF.instance, nil, "sql")
	checkluatype(tabname, TYPE_STRING)
	
	if not sql.TableExists( tabname ) then return false end
	sql.Query("DROP TABLE " .. tabname)
	return true
end
