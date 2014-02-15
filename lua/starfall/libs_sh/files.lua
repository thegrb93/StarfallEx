--- TODO: fix this.
--- TODO: Add VON encoding of any table's that are passed, work on 'universal' serializer and deserializer
-------------------------------------------------------------------------------
-- File functions
-------------------------------------------------------------------------------

-- File functions. Allows modification of files.
-- @shared
local files_library, _ = SF.Libraries.Register("files")

-- Register privileges
do
	local P = SF.Permissions
	P.registerPrivilege( "file.read", "Read files", "Allows the user to read files from data/starfallscript directory" )
	P.registerPrivilege( "file.write", "Write files", "Allows the user to write files to data/starfallscript directory" )
	P.registerPrivilege( "file.exists", "efile xistence check", "Allows the user to determine whether a file data/starfallscript exists" )
end

file.CreateDir("starfallscriptdata/")

--- Reads a file from path
-- @param path Filepath relative to data/starfallscriptdata/. Cannot contain '..'
-- @return Contents, or nil if error
-- @return Error message if applicable
function files_library.read(path)
	if not SF.Permissions.check( SF.instance.player, path, "file.read" ) then return end
	SF.CheckType(path, "string")
	if path:find("..",1,true) then error("path contains '..'") return end
	local contents = file.Read("starfallscriptdata/"..path, "DATA")
	if contents then return contents else error("file not found") return end
end

--- Writes to a file
-- @param path Filepath relative to data/starfallscriptdata/. Cannot contain '..'
-- @return True if OK, nil if error
-- @return Error message if applicable
function files_library.write(path, data)
	if not SF.Permissions.check( SF.instance.player, path, "file.write" ) then return end
	SF.CheckType(path, "string")
	SF.CheckType(data, "string")
	if path:find("..",1,true) then error("path contains '..'") return end
	file.Write("starfallscriptdata/"..path, data)
	return true
end

--- Appends a string to the end of a file
-- @param path Filepath relative to data/starfallscriptdata/. Cannot contain '..'
-- @param data String that will be appended to the file.
-- @return Error message if applicable
function files_library.append(path,data)
	if not SF.Permissions.check( SF.instance.player, path, "file.write" ) then return end
	SF.CheckType(path, "string")
	SF.CheckType(data, "string")
	if path:find("..",1,true) then error("path contains '..'") return end
	file.Append("starfallscriptdata/"..path, data)
	return true
end

--- Checks if a file exists
-- @param path Filepath relative to data/starfallscriptdata/. Cannot contain '..'
-- @return True if exists, false if not, nil if error
-- @return Error message if applicable
function files_library.exists(path)
	if not SF.Permissions.check( SF.instance.player, path, "file.exists" ) then return end
	SF.CheckType(path, "string")
	if path:find("..",1,true) then error("path contains '..'") return end
	return file.Exists("starfallscriptdata/"..path, "DATA")
end

--- Deletes a file
-- @param path Filepath relative to data/starfallscriptdata/. Cannot contain '..'
-- @return True if successful, nil if error
-- @return Error message if applicable
function files_library.delete(path)
	if not SF.Permissions.check( SF.instance.player, path, "file.write" ) then return end
	SF.CheckType(path, "string")
	if path:find("..",1,true) then error("path contains '..'") return end
	if not file.Exists("starfallscriptdata/"..path, "DATA") then error("doesn't exist") return end
	file.Delete(path)
	return true
end
