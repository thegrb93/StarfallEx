-------------------------------------------------------------------------------
-- File functions
-------------------------------------------------------------------------------

--- File functions. Allows modification of files.
-- @shared
local file_library, _ = SF.Libraries.Register( "file" )

-- Register privileges
do
	local P = SF.Permissions
	P.registerPrivilege( "file.read", "Read files", "Allows the user to read files from data/sf_scriptdata directory" )
	P.registerPrivilege( "file.write", "Write files", "Allows the user to write files to data/sf_scriptdata directory" )
	P.registerPrivilege( "file.exists", "File existence check", "Allows the user to determine whether a file in data/sf_scriptdata exists" )
end

file.CreateDir( "sf_filedata/" )

--- Reads a file from path
-- @param path Filepath relative to data/sf_filedata/. Cannot contain '..'
-- @return Contents, or nil if error
-- @return Error message if applicable
function file_library.read ( path )
	if not SF.Permissions.check( SF.instance.player, path, "file.read" ) then SF.throw( "Insufficient permissions", 2 ) end
	SF.CheckType( path, "string" )
	if path:find( "..", 1, true ) then error( "path contains '..'" ) return end
	local contents = file.Read( "sf_filedata/" .. path, "DATA" )
	if contents then return contents else error( "file not found" ) return end
end

--- Writes to a file
-- @param path Filepath relative to data/sf_filedata/. Cannot contain '..'
-- @return True if OK, nil if error
-- @return Error message if applicable
function file_library.write ( path, data )
	if not SF.Permissions.check( SF.instance.player, path, "file.write" ) then SF.throw( "Insufficient permissions", 2 ) end
	SF.CheckType( path, "string" )
	SF.CheckType( data, "string" )
	if path:find( "..", 1, true ) then error( "path contains '..'" ) return end
	file.Write( "sf_filedata/" .. path, data )
	return true
end

--- Appends a string to the end of a file
-- @param path Filepath relative to data/sf_filedata/. Cannot contain '..'
-- @param data String that will be appended to the file.
-- @return Error message if applicable
function file_library.append ( path, data )
	if not SF.Permissions.check( SF.instance.player, path, "file.write" ) then SF.throw( "Insufficient permissions", 2 ) end
	SF.CheckType( path, "string" )
	SF.CheckType( data, "string" )
	if path:find( "..", 1, true ) then error( "path contains '..'" ) return end
	file.Append( "sf_filedata/" .. path, data )
	return true
end

--- Checks if a file exists
-- @param path Filepath relative to data/sf_filedata/. Cannot contain '..'
-- @return True if exists, false if not, nil if error
-- @return Error message if applicable
function file_library.exists ( path )
	if not SF.Permissions.check( SF.instance.player, path, "file.exists" ) then SF.throw( "Insufficient permissions", 2 ) end
	SF.CheckType( path, "string" )
	if path:find( "..", 1, true ) then error( "path contains '..'" ) return end
	return file.Exists( "sf_filedata/" .. path, "DATA" )
end

--- Deletes a file
-- @param path Filepath relative to data/sf_filedata/. Cannot contain '..'
-- @return True if successful, nil if error
-- @return Error message if applicable
function file_library.delete ( path )
	if not SF.Permissions.check( SF.instance.player, path, "file.write" ) then SF.throw( "Insufficient permissions", 2 ) end
	SF.CheckType( path, "string" )
	if path:find( "..", 1, true ) then error( "path contains '..'" ) return end
	if not file.Exists( "sf_filedata/" .. path, "DATA" ) then error( "doesn't exist" ) return end
	file.Delete( path )
	return true
end

--- Creates a directory
-- @param path Filepath relative to data/sf_filedata/. Cannot contain '..'
function file_library.createDir ( path )
	if not SF.Permissions.check( SF.instance.player, path, "file.write" ) then SF.throw( "Insufficient permissions", 2 ) end
	SF.CheckType( path, "string" )
	if path:find( "..", 1, true ) then SF.throw( "path contains '..'" ) return end
	file.CreateDir( "sf_filedata/" .. path )
end
