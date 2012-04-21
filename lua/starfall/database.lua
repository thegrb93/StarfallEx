
SF.DB = {};

SF.DB.escape = sql.SQLStr
SF.DB.query = sql.Query
SF.DB.querySingleValue = sql.QueryValue

function SF.DB.querySingleRow (query)
	return sql.QueryRow( query, 0 )
end

-- check whether the tables exist and, if not, import the schema
if sql.TableExists( "starfall_meta" ) then
	local version = sql.QueryValue(
			"SELECT value FROM starfall_meta WHERE key='schema_version'" )
	if not version then
		error( "starfall tables exist but couldn't get schema version" )
	elseif "0.1" ~= version then
		error( "starfall DB schema exists but is wrong version" )
	end
else
	local result = sql.Query( [==[
		-- bits of meta-information about Starfall
		CREATE TABLE starfall_meta (
			key TEXT NOT NULL PRIMARY KEY,
			value TEXT NOT NULL
		);
		INSERT INTO starfall_meta ('schema_version', '0.1');
		
		-- the roles used by the default permissions provider
		CREATE TABLE starfall_perms_roles (
			id INTEGER PRIMARY KEY,
			name TEXT NOT NULL,
			description TEXT
		);
		
		-- maps players (identified by their Steam ID) into roles
		CREATE TABLE starfall_perms_player_roles (
			player TEXT NOT NULL,
			role INTEGER NOT NULL,
			PRIMARY KEY (player, role),
			FOREIGN KEY (role) REFERENCES starfall_perms_roles (id)
				ON DELETE CASCADE ON UPDATE CASCADE
		);
		
		-- grants permissions to roles
		CREATE TABLE starfall_perms_grants (
			role INTEGER NOT NULL,
			key TEXT NOT NULL,
			target TEXT,
			grant INTEGER CHECK (grant IN (0, 1)),
			PRIMARY KEY (role, key, target),
			FOREIGN KEY (role) REFERENCES starfall_perms_roles (id)
				ON DELETE CASCADE ON UPDATE CASCADE
		);
	]==] )
	
	if not result then
		error( "error importing Starfall schema " .. sql.LastError() )
	end
end