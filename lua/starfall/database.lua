SF.DB = {}

SF.DB.query = sql.Query
SF.DB.querySingleValue = sql.QueryValue

function SF.DB.querySingleRow ( query )
	return sql.QueryRow( query, 0 )
end

function SF.DB.escape ( str )
	return sql.SQLStr( str ):sub( 2, -2 )
end

local function queryMultiple ( statements )
	local ret = nil
	for k,v in pairs( statements ) do
		ret = sql.Query( v )
		if ret == false then break end
	end
	return ret
end

-- check whether the tables exist and, if not, import the schema
if sql.TableExists( "starfall_meta" ) then
	local version = sql.QueryValue(
			"SELECT value FROM starfall_meta WHERE key='schema_version'" )
	if not version then
		error( "starfall tables exists but couldn't get schema version" )
	elseif "0.1" ~= version then
		error( "starfall DB schema exists but is wrong version" )
	end
else
	sql.Begin()
	local result = queryMultiple( {
	[==[	-- bits of meta-information about Starfall
		CREATE TABLE starfall_meta (
			key TEXT NOT NULL PRIMARY KEY,
			value TEXT NOT NULL
		)]==],

	[==[	INSERT INTO starfall_meta VALUES ("schema_version", "0.1")]==],

	[==[	-- grants permissions to roles
		CREATE TABLE starfall_perms_grants (
			role INTEGER NOT NULL, -- 0 = user, 1 = admin, 2 = superadmin
			key TEXT NOT NULL,
			grant INTEGER CHECK (grant IN (0, 1, 2)), -- 0 = NEUTRAL, 1 = ALLOW, 2 = DENY
			PRIMARY KEY (role, key)
		)]==]
	} )
	sql.Commit()

	if result == false then
		error( "error importing Starfall schema " .. sql.LastError() )
	end
end