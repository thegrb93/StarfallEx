--- TODO: Permissions System before fixing this.
--- TODO: Add VON encoding of any table's that are passed, work on 'universal' serializer and deserializer
-------------------------------------------------------------------------------
-- File functions
-------------------------------------------------------------------------------

--- File functions. Allows modification of files.
-- @shared
local files_library, _ = SF.Libraries.Register("files")

--- Access Files permission
-- @name Access Files Permission
-- @class table
-- @field name "Access Files"
-- @field desc "Allows access to data/starfallscriptdata/"
-- @field level 1
-- @field value True if clientside, false if serverside

SF.Permissions:registerPermission({
	name = "Access Files",
	desc = "Allows access to data/starfallscriptdata/",
	level = 1,
	value = 1,
})

file.CreateDir("starfallscriptdata/")

--- Reads a file from path
-- @param path Filepath relative to data/starfallscriptdata/. Cannot contain '..'
-- @return Contents, or nil if error
-- @return Error message if applicable
function files_library.read(path)
	SF.CheckType(path, "string")
	if path:find("..",1,true) then error("path contains '..'") return end
	if not SF.instance.permissions:checkPermission("Access Files") then error("access denied") return end
	local contents = file.Read("starfallscriptdata/"..path, "DATA")
	if contents then return contents else error("file not found") return end
end

--- Writes to a file
-- @param path Filepath relative to data/starfallscriptdata/. Cannot contain '..'
-- @return True if OK, nil if error
-- @return Error message if applicable
function files_library.write(path, data)
	SF.CheckType(path, "string")
	SF.CheckType(data, "string")
	if path:find("..",1,true) then error("path contains '..'") return end
	if not SF.instance.permissions:checkPermission("Access Files") then error("access denied") return end
	file.Write("starfallscriptdata/"..path, data)
	return true
end

--- Appends a string to the end of a file
-- @param path Filepath relative to data/starfallscriptdata/. Cannot contain '..'
-- @param data String that will be appended to the file.
-- @return Error message if applicable
function files_library.append(path,data)
	SF.CheckType(path, "string")
	SF.CheckType(data, "string")
	if path:find("..",1,true) then error("path contains '..'") return end
	if not SF.instance.permissions:checkPermission("Access Files") then error("access denied") return end
	file.Append("starfallscriptdata/"..path, data)
	return true
end

--- Checks if a file exists
-- @param path Filepath relative to data/starfallscriptdata/. Cannot contain '..'
-- @return True if exists, false if not, nil if error
-- @return Error message if applicable
function files_library.exists(path)
	SF.CheckType(path, "string")
	if path:find("..",1,true) then error("path contains '..'") return end
	if not SF.instance.permissions:checkPermission("Access Files") then error("access denied") return end
	return file.Exists("starfallscriptdata/"..path, "DATA")
end

--- Deletes a file
-- @param path Filepath relative to data/starfallscriptdata/. Cannot contain '..'
-- @return True if successful, nil if error
-- @return Error message if applicable
function files_library.delete(path)
	SF.CheckType(path, "string")
	if path:find("..",1,true) then error("path contains '..'") return end
	if not SF.instance.permissions:checkPermission("Access Files") then error("access denied") return end
	if not file.Exists("starfallscriptdata/"..path, "DATA") then error("doesn't exist") return end
	file.Delete(path)
	return true
end
