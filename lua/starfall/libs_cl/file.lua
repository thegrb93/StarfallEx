-------------------------------------------------------------------------------
-- File functions
-------------------------------------------------------------------------------

--- File functions. Allows modification of files.
-- @client
local file_library = SF.Libraries.Register("file")

--- File type
-- @client
local file_methods, file_metamethods = SF.Typedef("File")
local wrap, unwrap = SF.CreateWrapper(file_metamethods, true, false)
local checktype = SF.CheckType
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check

-- Register privileges
do
	local P = SF.Permissions
	P.registerPrivilege("file.read", "Read files", "Allows the user to read files from data/sf_filedata directory", { client = { default = 1 } })
	P.registerPrivilege("file.write", "Write files", "Allows the user to write files to data/sf_filedata directory", { client = { default = 1 } })
	P.registerPrivilege("file.exists", "File existence check", "Allows the user to determine whether a file in data/sf_filedata exists", { client = { default = 1 } })
	P.registerPrivilege("file.open", "Get a file object", "Allows the user to use a file object", { client = { default = 1 } })
end

file.CreateDir("sf_filedata/")

-- Register functions to be called when the chip is initialised and deinitialised
SF.Libraries.AddHook("initialize", function (inst)
	inst.data.files = {}
end)

SF.Libraries.AddHook("deinitialize", function (inst)
	local files = inst.data.files
	local file = next(files)
	while file do
		file:Close()
		file = next(files)
	end
end)

--- Opens and returns a file
-- @param path Filepath relative to data/sf_filedata/. Cannot contain '..'
-- @param mode The file mode to use. See lua manual for explaination
-- @return File object or nil if it failed
function file_library.open (path, mode)
	checkpermission (SF.instance, path, "file.open")
	checkluatype (path, TYPE_STRING)
	checkluatype (mode, TYPE_STRING)
	local f = file.Open("sf_filedata/" .. SF.NormalizePath(path), mode, "DATA")
	if f then
		SF.instance.data.files[f] = true
		return wrap(f)
	else
		SF.Throw("Failed to open file", 2)
	end
end

--- Reads a file from path
-- @param path Filepath relative to data/sf_filedata/. Cannot contain '..'
-- @return Contents, or nil if error
function file_library.read (path)
	checkpermission (SF.instance, path, "file.read")
	checkluatype (path, TYPE_STRING)
	local contents = file.Read("sf_filedata/" .. SF.NormalizePath(path), "DATA")
	if contents then return contents else SF.Throw("file not found", 2) return end
end

--- Writes to a file
-- @param path Filepath relative to data/sf_filedata/. Cannot contain '..'
-- @return True if OK, nil if error
function file_library.write (path, data)
	checkpermission (SF.instance, path, "file.write")
	checkluatype (path, TYPE_STRING)
	checkluatype (data, TYPE_STRING)

	local f = file.Open("sf_filedata/" .. SF.NormalizePath(path), "wb", "DATA")
	if not f then SF.Throw("Couldn't open file for writing.", 2) return end
	f:Write(data)
	f:Close()
end

--- Appends a string to the end of a file
-- @param path Filepath relative to data/sf_filedata/. Cannot contain '..'
-- @param data String that will be appended to the file.
function file_library.append (path, data)
	checkpermission (SF.instance, path, "file.write")
	checkluatype (path, TYPE_STRING)
	checkluatype (data, TYPE_STRING)

	local f = file.Open("sf_filedata/" .. SF.NormalizePath(path), "ab", "DATA")
	if not f then SF.Throw("Couldn't open file for writing.", 2) return end
	f:Write(data)
	f:Close()
end

--- Checks if a file exists
-- @param path Filepath relative to data/sf_filedata/. Cannot contain '..'
-- @return True if exists, false if not, nil if error
function file_library.exists (path)
	checkpermission (SF.instance, path, "file.exists")
	checkluatype (path, TYPE_STRING)
	return file.Exists("sf_filedata/" .. SF.NormalizePath(path), "DATA")
end

--- Deletes a file
-- @param path Filepath relative to data/sf_filedata/. Cannot contain '..'
-- @return True if successful, nil if error
function file_library.delete (path)
	checkpermission (SF.instance, path, "file.write")
	checkluatype (path, TYPE_STRING)
	path = "sf_filedata/" .. SF.NormalizePath(path)
	if not file.Exists(path, "DATA") then SF.Throw("file not found", 2) return end
	file.Delete(path)
	return true
end

--- Creates a directory
-- @param path Filepath relative to data/sf_filedata/. Cannot contain '..'
function file_library.createDir (path)
	checkpermission (SF.instance, path, "file.write")
	checkluatype (path, TYPE_STRING)
	file.CreateDir("sf_filedata/" .. SF.NormalizePath(path))
end

--- Enumerates a directory
-- @param path The folder to enumerate, relative to data/sf_filedata/. Cannot contain '..'
-- @param sorting Optional sorting arguement. Either nameasc, namedesc, dateasc, datedesc
-- @return Table of file names
-- @return Table of directory names
function file_library.find (path, sorting)
	checkpermission (SF.instance, path, "file.exists")
	checkluatype (path, TYPE_STRING)
	if sorting then checkluatype (sorting, TYPE_STRING) end
	return file.Find("sf_filedata/" .. SF.NormalizePath(path), "DATA", sorting)
end

--- Wait until all changes to the file are complete
function file_methods:flush()
	checktype(self, file_metamethods)
	unwrap(self):Flush()
end

--- Flushes and closes the file. The file must be opened again to use a new file object.
function file_methods:close()
	checktype(self, file_metamethods)
	local f = unwrap(self)
	SF.instance.data.files[f] = nil
	f:Close()
end

--- Sets the file position
-- @param n The position to set it to
function file_methods:seek(n)
	checktype(self, file_metamethods)
	checkluatype (n, TYPE_NUMBER)
	unwrap(self):Seek(n)
end

--- Moves the file position relative to its current position
-- @param n How much to move the position
-- @return The resulting position
function file_methods:skip(n)
	checktype(self, file_metamethods)
	checkluatype (n, TYPE_NUMBER)
	return unwrap(self):Skip(n)
end

--- Returns the current file position
-- @return The current file position
function file_methods:tell()
	checktype(self, file_metamethods)
	return unwrap(self):Tell()
end

--- Returns the file's size in bytes
-- @return The file's size
function file_methods:size()
	checktype(self, file_metamethods)
	return unwrap(self):Size()
end

--- Reads a certain length of the file's bytes
-- @param n The length to read
-- @return The data
function file_methods:read(n)
	checktype(self, file_metamethods)
	return unwrap(self):Read(n)
end

--- Reads a boolean and advances the file position
-- @return The data
function file_methods:readBool()
	checktype(self, file_metamethods)
	return unwrap(self):ReadBool()
end

--- Reads a byte and advances the file position
-- @return The data
function file_methods:readByte()
	checktype(self, file_metamethods)
	return unwrap(self):ReadByte()
end

--- Reads a double and advances the file position
-- @return The data
function file_methods:readDouble()
	checktype(self, file_metamethods)
	return unwrap(self):ReadDouble()
end

--- Reads a float and advances the file position
-- @return The data
function file_methods:readFloat()
	checktype(self, file_metamethods)
	return unwrap(self):ReadFloat()
end

--- Reads a line and advances the file position
-- @return The data
function file_methods:readLine()
	checktype(self, file_metamethods)
	return unwrap(self):ReadLine()
end

--- Reads a long and advances the file position
-- @return The data
function file_methods:readLong()
	checktype(self, file_metamethods)
	return unwrap(self):ReadLong()
end

--- Reads a short and advances the file position
-- @return The data
function file_methods:readShort()
	checktype(self, file_metamethods)
	return unwrap(self):ReadShort()
end

--- Writes a string to the file and advances the file position
-- @param str The data to write
function file_methods:write(str)
	checktype(self, file_metamethods)
	checkluatype (str, TYPE_STRING)
	unwrap(self):Write(str)
end

--- Writes a boolean and advances the file position
-- @param x The boolean to write
function file_methods:writeBool(x)
	checktype(self, file_metamethods)
	checkluatype (x, TYPE_BOOL)
	unwrap(self):WriteBool(x)
end

--- Writes a byte and advances the file position
-- @param x The byte to write
function file_methods:writeByte(x)
	checktype(self, file_metamethods)
	checkluatype (x, TYPE_NUMBER)
	unwrap(self):WriteByte(x)
end

--- Writes a double and advances the file position
-- @param x The double to write
function file_methods:writeDouble(x)
	checktype(self, file_metamethods)
	checkluatype (x, TYPE_NUMBER)
	unwrap(self):WriteDouble(x)
end

--- Writes a float and advances the file position
-- @param x The float to write
function file_methods:writeFloat(x)
	checktype(self, file_metamethods)
	checkluatype (x, TYPE_NUMBER)
	unwrap(self):WriteFloat(x)
end

--- Writes a long and advances the file position
-- @param x The long to write
function file_methods:writeLong(x)
	checktype(self, file_metamethods)
	checkluatype (x, TYPE_NUMBER)
	unwrap(self):WriteLong(x)
end

--- Writes a short and advances the file position
-- @param x The short to write
function file_methods:writeShort(x)
	checktype(self, file_metamethods)
	checkluatype (x, TYPE_NUMBER)
	unwrap(self):WriteShort(x)
end
