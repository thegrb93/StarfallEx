local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege

-- Register privileges
registerprivilege("file.read", "Read files", "Allows the user to read files from data/sf_filedata directory", { client = { default = 1 } })
registerprivilege("file.write", "Write files", "Allows the user to write files to data/sf_filedata directory", { client = { default = 1 } })
registerprivilege("file.exists", "File existence check", "Allows the user to determine whether a file in data/sf_filedata exists", { client = { default = 1 } })
registerprivilege("file.find", "File find", "Allows the user to see what files are in data/sf_filedata", { client = { default = 1 } })
registerprivilege("file.findInGame", "File find in garrysmod", "Allows the user to see what files are in garrysmod", { client = { default = 1 } })
registerprivilege("file.open", "Get a file object", "Allows the user to use a file object", { client = { default = 1 } })

file.CreateDir("sf_filedata/")

--- File functions. Allows modification of files.
-- @name file
-- @class library
-- @libtbl file_library
SF.RegisterLibrary("file")

--- File type
-- @name File
-- @class type
-- @libtbl file_methods
SF.RegisterType("File", true, false)


return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local files = {}
instance:AddHook("deinitialize", function()
	for file, _ in pairs(files) do
		file:Close()
	end
end)


local file_library = instance.Libraries.file
local file_methods, file_meta, wrap, unwrap = instance.Types.File.Methods, instance.Types.File, instance.Types.File.Wrap, instance.Types.File.Unwrap


--- Opens and returns a file
-- @param path Filepath relative to data/sf_filedata/.
-- @param mode The file mode to use. See lua manual for explaination
-- @return File object or nil if it failed
function file_library.open(path, mode)
	checkpermission (instance, path, "file.open")
	checkluatype (path, TYPE_STRING)
	checkluatype (mode, TYPE_STRING)
	local f = file.Open("sf_filedata/" .. SF.NormalizePath(path), mode, "DATA")
	if f then
		files[f] = true
		return wrap(f)
	end
end

--- Reads a file from path
-- @param path Filepath relative to data/sf_filedata/.
-- @return Contents, or nil if error
function file_library.read(path)
	checkpermission (instance, path, "file.read")
	checkluatype (path, TYPE_STRING)
	return file.Read("sf_filedata/" .. SF.NormalizePath(path), "DATA")
end

--- Writes to a file
-- @param path Filepath relative to data/sf_filedata/.
-- @param data The data to write
-- @return True if OK, nil if error
function file_library.write(path, data)
	checkpermission (instance, path, "file.write")
	checkluatype (path, TYPE_STRING)
	checkluatype (data, TYPE_STRING)

	local f = file.Open("sf_filedata/" .. SF.NormalizePath(path), "wb", "DATA")
	if not f then SF.Throw("Couldn't open file for writing.", 2) return end
	f:Write(data)
	f:Close()
end

--- Appends a string to the end of a file
-- @param path Filepath relative to data/sf_filedata/.
-- @param data String that will be appended to the file.
function file_library.append(path, data)
	checkpermission (instance, path, "file.write")
	checkluatype (path, TYPE_STRING)
	checkluatype (data, TYPE_STRING)

	local f = file.Open("sf_filedata/" .. SF.NormalizePath(path), "ab", "DATA")
	if not f then SF.Throw("Couldn't open file for writing.", 2) return end
	f:Write(data)
	f:Close()
end

--- Checks if a file exists
-- @param path Filepath relative to data/sf_filedata/.
-- @return True if exists, false if not, nil if error
function file_library.exists(path)
	checkpermission (instance, path, "file.exists")
	checkluatype (path, TYPE_STRING)
	return file.Exists("sf_filedata/" .. SF.NormalizePath(path), "DATA")
end

--- Deletes a file
-- @param path Filepath relative to data/sf_filedata/.
-- @return True if successful, nil if it wasn't found
function file_library.delete(path)
	checkpermission (instance, path, "file.write")
	checkluatype (path, TYPE_STRING)
	path = "sf_filedata/" .. SF.NormalizePath(path)
	if file.Exists(path, "DATA") then
		file.Delete(path)
		return true
	end
end

--- Creates a directory
-- @param path Filepath relative to data/sf_filedata/.
function file_library.createDir(path)
	checkpermission (instance, path, "file.write")
	checkluatype (path, TYPE_STRING)
	file.CreateDir("sf_filedata/" .. SF.NormalizePath(path))
end

--- Enumerates a directory
-- @param path The folder to enumerate, relative to data/sf_filedata/.
-- @param sorting Optional sorting arguement. Either nameasc, namedesc, dateasc, datedesc
-- @return Table of file names
-- @return Table of directory names
function file_library.find(path, sorting)
	checkpermission (instance, path, "file.find")
	checkluatype (path, TYPE_STRING)
	if sorting~=nil then checkluatype (sorting, TYPE_STRING) end
	return file.Find("sf_filedata/" .. SF.NormalizePath(path), "DATA", sorting)
end

--- Enumerates a directory relative to gmod
-- @param path The folder to enumerate, relative to garrysmod.
-- @param sorting Optional sorting arguement. Either nameasc, namedesc, dateasc, datedesc
-- @return Table of file names
-- @return Table of directory names
function file_library.findInGame(path, sorting)
	checkpermission (instance, path, "file.findInGame")
	checkluatype (path, TYPE_STRING)
	if sorting~=nil then checkluatype (sorting, TYPE_STRING) end
	return file.Find(SF.NormalizePath(path), "GAME", sorting)
end

--- Wait until all changes to the file are complete
function file_methods:flush()
	unwrap(self):Flush()
end

--- Flushes and closes the file. The file must be opened again to use a new file object.
function file_methods:close()
	local f = unwrap(self)
	files[f] = nil
	f:Close()
end

--- Sets the file position
-- @param n The position to set it to
function file_methods:seek(n)
	checkluatype (n, TYPE_NUMBER)
	unwrap(self):Seek(n)
end

--- Moves the file position relative to its current position
-- @param n How much to move the position
-- @return The resulting position
function file_methods:skip(n)
	checkluatype (n, TYPE_NUMBER)
	return unwrap(self):Skip(n)
end

--- Returns the current file position
-- @return The current file position
function file_methods:tell()
	return unwrap(self):Tell()
end

--- Returns the file's size in bytes
-- @return The file's size
function file_methods:size()
	return unwrap(self):Size()
end

--- Reads a certain length of the file's bytes
-- @param n The length to read
-- @return The data
function file_methods:read(n)
	return unwrap(self):Read(n)
end

--- Reads a boolean and advances the file position
-- @return The data
function file_methods:readBool()
	return unwrap(self):ReadBool()
end

--- Reads a byte and advances the file position
-- @return The data
function file_methods:readByte()
	return unwrap(self):ReadByte()
end

--- Reads a double and advances the file position
-- @return The data
function file_methods:readDouble()
	return unwrap(self):ReadDouble()
end

--- Reads a float and advances the file position
-- @return The data
function file_methods:readFloat()
	return unwrap(self):ReadFloat()
end

--- Reads a line and advances the file position
-- @return The data
function file_methods:readLine()
	return unwrap(self):ReadLine()
end

--- Reads a long and advances the file position
-- @return The data
function file_methods:readLong()
	return unwrap(self):ReadLong()
end

--- Reads a short and advances the file position
-- @return The data
function file_methods:readShort()
	return unwrap(self):ReadShort()
end

--- Writes a string to the file and advances the file position
-- @param str The data to write
function file_methods:write(str)
	checkluatype (str, TYPE_STRING)
	unwrap(self):Write(str)
end

--- Writes a boolean and advances the file position
-- @param x The boolean to write
function file_methods:writeBool(x)
	checkluatype (x, TYPE_BOOL)
	unwrap(self):WriteBool(x)
end

--- Writes a byte and advances the file position
-- @param x The byte to write
function file_methods:writeByte(x)
	checkluatype (x, TYPE_NUMBER)
	unwrap(self):WriteByte(x)
end

--- Writes a double and advances the file position
-- @param x The double to write
function file_methods:writeDouble(x)
	checkluatype (x, TYPE_NUMBER)
	unwrap(self):WriteDouble(x)
end

--- Writes a float and advances the file position
-- @param x The float to write
function file_methods:writeFloat(x)
	checkluatype (x, TYPE_NUMBER)
	unwrap(self):WriteFloat(x)
end

--- Writes a long and advances the file position
-- @param x The long to write
function file_methods:writeLong(x)
	checkluatype (x, TYPE_NUMBER)
	unwrap(self):WriteLong(x)
end

--- Writes a short and advances the file position
-- @param x The short to write
function file_methods:writeShort(x)
	checkluatype (x, TYPE_NUMBER)
	unwrap(self):WriteShort(x)
end

end
