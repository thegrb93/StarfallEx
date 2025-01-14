local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege

-- Register privileges
registerprivilege("file.read", "Read files", "Allows the user to read files from data/sf_filedata directory", { client = { default = 1 } })
registerprivilege("file.write", "Write files", "Allows the user to write files to data/sf_filedata directory", { client = { default = 1 } })
registerprivilege("file.writeTemp", "Write temporary files", "Allows the user to write temp files to data/sf_filedatatemp directory", { client = {} })
registerprivilege("file.exists", "File existence check", "Allows the user to determine whether a file in data/sf_filedata exists", { client = { default = 1 } })
registerprivilege("file.existsInGame", "File existence check", "Allows the user to determine whether a file in game dir exists", { client = { default = 1 } })
registerprivilege("file.isDir", "Directory check", "Allows the user to determine whether a file in data/sf_filedata is a directory", { client = { default = 1 } })
registerprivilege("file.find", "File find", "Allows the user to see what files are in data/sf_filedata", { client = { default = 1 } })
registerprivilege("file.findInGame", "File find in garrysmod", "Allows the user to see what files are in garrysmod", { client = { default = 1 } })
registerprivilege("file.open", "Get a file object", "Allows the user to use a file object", { client = { default = 1 } })
registerprivilege("file.time", "Get time modified", "Allows the user to see the last time a file was modified", { client = { default = 1 } })

file.CreateDir("sf_filedata/")
file.CreateDir("sf_filedatatemp/")

local cv_temp_maxfiles = CreateConVar("sf_file_tempmax", "256", { FCVAR_ARCHIVE }, "The max number of files a player can store in temp")
local cv_temp_maxusersize = CreateConVar("sf_file_tempmaxusersize", "64", { FCVAR_ARCHIVE }, "The max total of megabytes a player can store in temp")
local cv_temp_maxsize = CreateConVar("sf_file_tempmaxsize", "128", { FCVAR_ARCHIVE }, "The max total of megabytes allowed in temp")
local cv_max_concurrent_reads = CreateConVar("sf_file_asyncmax", "10", { FCVAR_ARCHIVE }, "The max concurrent async reads allowed")

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


-- Temp file cache class
local TempFileCache = {}
do
	function TempFileCache:Initialize()
		local entries = {}
		local files, dirs = file.Find("sf_filedatatemp/*", "DATA")
		for k, plyid in ipairs(dirs) do
			local dir = "sf_filedatatemp/"..plyid
			files = file.Find(dir.."/*", "DATA")
			if next(files)==nil then SF.DeleteFolder(dir) else
				for k, filen in ipairs(files) do
					local path = dir.."/"..filen
					local time, size = file.Time(path, "DATA"), file.Size(path, "DATA")
					entries[path] = {path = path, plyid = plyid, time = time, size = size}
				end
			end
		end
		self.entries = entries
	end

	function TempFileCache:Write(ply, filename, data)
		local plyid = ply:SteamID64()
		local dir = "sf_filedatatemp/"..plyid
		local path = dir.."/"..filename
		local ok, reason = self:CheckSize(plyid, path, #data)
		if ok then
			if self.entries[path] then
				file.Delete(path)
				if file.Exists(path, "DATA") then SF.Throw("The existing file is currently locked!", 3) end
			end
			self.entries[path] = {path = path, plyid = plyid, time = os.time(), size = #data}
			file.CreateDir(dir)
			print("[SF owner=\""..tostring(ply).."\"] Writing temp file: " .. path)
			local f = file.Open(path, "wb", "DATA")
			if not f then SF.Throw("Couldn't open file for writing!", 3) end
			f:Write(data)
			f:Close()
			return "data/"..path
		else
			SF.Throw(reason, 3)
		end
	end

	function TempFileCache:CheckSize(plyid, path, size)
		local plyentries = {}
		local plysize = size
		local plycount = 1
		local totalsize = size
		for k, v in pairs(self.entries) do
			if k~=path then
				if v.plyid == plyid then
					plycount = plycount + 1
					plysize = plysize + v.size
					plyentries[#plyentries+1] = v
				end
				totalsize = totalsize + v.size
			end
		end

		local check = {plyentries = plyentries, plysize = plysize, plycount = plycount, totalsize = totalsize}
		if check.plycount >= cv_temp_maxfiles:GetInt() then
			self:CleanPly(check)
			if check.plycount >= cv_temp_maxfiles:GetInt() then
				return false, "Reached the file count limit!"
			end
		end
		if check.plysize >= cv_temp_maxusersize:GetFloat()*1e6 then
			self:CleanPly(check)
			if check.plysize >= cv_temp_maxusersize:GetFloat()*1e6 then
				return false, "Your temp file folder is full!"
			end
		end
		if check.totalsize >= cv_temp_maxsize:GetFloat()*1e6 then
			self:CleanAll(check)
			if check.totalsize >= cv_temp_maxsize:GetFloat()*1e6 then
				return false, "The temp file cache has reached its limit!"
			end
		end
		return true
	end

	-- Clean based on the file count and per player size limit
	function TempFileCache:CleanPly(check)
		-- Sort by time
		table.sort(check.plyentries, function(a,b) return a.time>b.time end)

		while (check.plycount >= cv_temp_maxfiles:GetInt() or check.plysize >= cv_temp_maxusersize:GetFloat()*1e6) and #check.plyentries>0 do
			local entry = table.remove(check.plyentries)
			file.Delete(entry.path)
			if not file.Exists(entry.path, "DATA") then
				check.plysize = check.plysize - entry.size
				check.plycount = check.plycount - 1
				self.entries[entry.path] = nil
			end
		end
	end

	-- Clean based on the total size limit
	function TempFileCache:CleanAll(check)
		-- First sort by players not connected
		local connectedplys = {}
		local disconnectedplys = {}
		for path, v in pairs(self.entries) do
			if player.GetBySteamID64(v.plyid) then
				connectedplys[#connectedplys+1] = v
			else
				disconnectedplys[#disconnectedplys+1] = v
			end
		end
		-- Sort by time
		table.sort(connectedplys, function(a,b) return a.time>b.time end)
		table.sort(disconnectedplys, function(a,b) return a.time>b.time end)
		local sorted = table.Add(connectedplys, disconnectedplys)

		while check.totalsize >= cv_temp_maxsize:GetFloat()*1e6 and #sorted>0 do
			local entry = table.remove(sorted)
			file.Delete(entry.path)
			if not file.Exists(entry.path, "DATA") then
				check.totalsize = check.totalsize - entry.size
				self.entries[entry.path] = nil
			end
		end
	end

	TempFileCache:Initialize()
end


return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local files = {}
local tempfilewrites = 0
local concurrentreads = 0
instance:AddHook("deinitialize", function()
	for file in pairs(files) do
		file:Close()
	end
end)


local file_library = instance.Libraries.file
local file_methods, file_meta, wrap, unwrap = instance.Types.File.Methods, instance.Types.File, instance.Types.File.Wrap, instance.Types.File.Unwrap


--- Opens and returns a file
-- @param string path Filepath relative to data/sf_filedata/.
-- @param string mode The file mode to use. See lua manual for explanation
-- @return File? File object or nil if it failed
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
-- @param string path Filepath relative to data/sf_filedata/.
-- @return string? Contents, or nil if error
function file_library.read(path)
	checkpermission (instance, path, "file.read")
	checkluatype (path, TYPE_STRING)
	return file.Read("sf_filedata/" .. SF.NormalizePath(path), "DATA")
end

--- Reads a file from path relative to base GMod directory
-- @param string path Filepath relative to GarrysMod/garrysmod/.
-- @return string? Contents or nil if error
function file_library.readInGame(path)
	if instance.player ~= LocalPlayer() then SF.Throw("Only chip owner can read game files") end
	checkluatype (path, TYPE_STRING)
	return file.Read(SF.NormalizePath(path), "GAME")
end

--- Reads a file asynchronously. Can only read 'sf_file_asyncmax' files at a time
-- @param string path Filepath relative to data/sf_filedata/.
-- @param function callback A callback function for when the read operation finishes. It has 3 arguments: `filename` string, `status` number and `data` string
function file_library.asyncRead(path, callback)
	checkpermission (instance, path, "file.read")
	checkluatype (path, TYPE_STRING)
	checkluatype (callback, TYPE_FUNCTION)
	if concurrentreads == cv_max_concurrent_reads:GetInt() then SF.Throw("Reading too many files asynchronously!", 2) end
	concurrentreads = concurrentreads + 1
	file.AsyncRead("sf_filedata/" .. SF.NormalizePath(path), "DATA", function(_, _, status, data)
		concurrentreads = concurrentreads - 1
		instance:runFunction(callback, path, status, data)
	end)
end


local allowedExtensions = {["txt"]=true,["dat"]=true,["json"]=true,["xml"]=true,["csv"]=true,["jpg"]=true,["jpeg"]=true,["png"]=true,["vtf"]=true,["vmt"]=true,["mp3"]=true,["wav"]=true,["ogg"]=true}
local function checkExtension(filename)
	if not allowedExtensions[string.GetExtensionFromFilename(filename)] then SF.Throw("Invalid file extension!", 3) end
end

--- Writes to a file. Throws an error if it failed to write
-- @param string path Filepath relative to data/sf_filedata/.
-- @param string data The data to write
function file_library.write(path, data)
	checkpermission (instance, path, "file.write")
	checkluatype (path, TYPE_STRING)
	checkluatype (data, TYPE_STRING)

	checkExtension(path)

	local f = file.Open("sf_filedata/" .. SF.NormalizePath(path), "wb", "DATA")
	if not f then SF.Throw("Couldn't open file for writing.", 2) return end
	f:Write(data)
	f:Close()
end

--- Reads a temp file's data if it exists. Otherwise returns nil
-- @param string filename The temp file name. Must be only a file and not a path
-- @return string? The data of the temp file or nil if it doesn't exist
function file_library.readTemp(filename)
	checkluatype(filename, TYPE_STRING)

	if #filename > 128 then SF.Throw("Filename is too long!", 2) end
	checkExtension(filename)
	filename = string.lower(string.GetFileFromFilename(filename))

	return file.Read("sf_filedatatemp/"..instance.player:SteamID64().."/"..filename, "DATA")
end

--- Writes a temporary file. Throws an error if it is unable to.
-- @param string filename The name to give the file. Must be only a file and not a path
-- @param string data The data to write
-- @return string The generated path for your temp file
function file_library.writeTemp(filename, data)
	checkluatype(filename, TYPE_STRING)
	checkluatype(data, TYPE_STRING)

	checkpermission (instance, nil, "file.writeTemp")
	if tempfilewrites >= cv_temp_maxfiles:GetInt() then SF.Throw("Exceeded max number of files allowed to write!", 2) end

	if #filename > 128 then SF.Throw("Filename is too long!", 2) end
	checkExtension(filename)
	filename = string.lower(string.GetFileFromFilename(filename))

	local path = TempFileCache:Write(instance.player, filename, data)
	tempfilewrites = tempfilewrites + 1
	return path
end

--- Returns the path of a temp file if it exists. Otherwise returns nil
-- @param string filename The temp file name. Must be only a file and not a path
-- @return string? The path to the temp file or nil if it doesn't exist
function file_library.existsTemp(filename)
	checkluatype(filename, TYPE_STRING)

	if #filename > 128 then SF.Throw("Filename is too long!", 2) end
	checkExtension(filename)
	filename = string.lower(string.GetFileFromFilename(filename))

	local path = "sf_filedatatemp/"..instance.player:SteamID64().."/"..filename
	if file.Exists(path, "DATA") then
		return "data/"..path
	end
end

--- Appends a string to the end of a file
-- @param string path Filepath relative to data/sf_filedata/.
-- @param string data String that will be appended to the file.
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
-- @param string path Filepath relative to data/sf_filedata/.
-- @return boolean? True if exists, false if not, nil if error
function file_library.exists(path)
	checkpermission (instance, path, "file.exists")
	checkluatype (path, TYPE_STRING)
	return file.Exists("sf_filedata/" .. SF.NormalizePath(path), "DATA")
end

--- Checks if a file exists in path relative to gmod
-- @param string path Filepath in game folder
-- @return boolean? True if exists, false if not, nil if error
function file_library.existsInGame(path)
	checkpermission (instance, path, "file.existsInGame")
	checkluatype (path, TYPE_STRING)
	return file.Exists(SF.NormalizePath(path), "GAME")
end

--- Checks if a given file is a directory or not
-- @param string path Filepath relative to data/sf_filedata/.
-- @return boolean True if given path is a directory, false if it's a file
function file_library.isDir(path)
	checkpermission (instance, path, "file.isDir")
	checkluatype (path, TYPE_STRING)
	return file.IsDir("sf_filedata/" .. SF.NormalizePath(path), "DATA")
end

--- Deletes a file
-- @param string path Filepath relative to data/sf_filedata/.
-- @return boolean? True if successful, nil if it wasn't found
function file_library.delete(path)
	checkpermission (instance, path, "file.write")
	checkluatype (path, TYPE_STRING)
	path = "sf_filedata/" .. SF.NormalizePath(path)
	if file.Exists(path, "DATA") then
		file.Delete(path)
		return true
	end
end

--- Deletes a temp file
-- @param string filename The temp file name. Must be only a file and not a path
-- @return boolean? True if successful, nil if it wasn't found
function file_library.deleteTemp(filename)
	checkpermission (instance, nil, "file.writeTemp")
	checkluatype (filename, TYPE_STRING)
	
	if #filename > 128 then SF.Throw("Filename is too long!", 2) end
	checkExtension(filename)
	filename = string.lower(string.GetFileFromFilename(filename))

	local path = "sf_filedatatemp/"..instance.player:SteamID64().."/"..filename
	if file.Exists(path, "DATA") then
		file.Delete(path)
		return true
	end
end

--- Creates a directory
-- @param string path Filepath relative to data/sf_filedata/.
function file_library.createDir(path)
	checkpermission (instance, path, "file.write")
	checkluatype (path, TYPE_STRING)
	file.CreateDir("sf_filedata/" .. SF.NormalizePath(path))
end

--- Enumerates a directory
-- @param string path The folder to enumerate, relative to data/sf_filedata/.
-- @param string? sorting Optional sorting argument. Either nameasc, namedesc, dateasc, datedesc
-- @return table Table of file names
-- @return table Table of directory names
function file_library.find(path, sorting)
	checkpermission (instance, path, "file.find")
	checkluatype (path, TYPE_STRING)
	if sorting~=nil then checkluatype (sorting, TYPE_STRING) end
	return file.Find("sf_filedata/" .. SF.NormalizePath(path), "DATA", sorting)
end

--- Enumerates a directory relative to gmod
-- @param string path The folder to enumerate, relative to garrysmod.
-- @param string? sorting Optional sorting argument. Either nameasc, namedesc, dateasc, datedesc
-- @return table Table of file names
-- @return table Table of directory names
function file_library.findInGame(path, sorting)
	checkpermission (instance, path, "file.findInGame")
	checkluatype (path, TYPE_STRING)
	if sorting~=nil then checkluatype (sorting, TYPE_STRING) end
	return file.Find(SF.NormalizePath(path), "GAME", sorting)
end

--- Returns when the file or folder was last modified in Unix time.
--- Can then be used with something like os.date for a human-readable date.
-- @param string path Filepath relative to data/sf_filedata/.
-- @return number Last modified time in Unix time
function file_library.time(path)
	checkpermission (instance, path, "file.time")
	checkluatype (path, TYPE_STRING)
	return file.Time("sf_filedata/" .. SF.NormalizePath(path), "DATA")
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
-- @param number n The position to set it to
function file_methods:seek(n)
	checkluatype (n, TYPE_NUMBER)
	unwrap(self):Seek(n)
end

--- Moves the file position relative to its current position
-- @param number n How much to move the position
-- @return number The resulting position
function file_methods:skip(n)
	checkluatype (n, TYPE_NUMBER)
	return unwrap(self):Skip(n)
end

--- Returns the current file position
-- @return number The current file position
function file_methods:tell()
	return unwrap(self):Tell()
end

--- Returns the file's size in bytes
-- @return number The file's size
function file_methods:size()
	return unwrap(self):Size()
end

--- Reads a certain length of the file's bytes
-- @param number n The length to read
-- @return string The data
function file_methods:read(n)
	return unwrap(self):Read(n)
end

--- Reads a boolean and advances the file position
-- @return boolean Boolean
function file_methods:readBool()
	return unwrap(self):ReadBool()
end

--- Reads a byte and advances the file position
-- @return number UInt8 number
function file_methods:readByte()
	return unwrap(self):ReadByte()
end

--- Reads a double and advances the file position
-- @return number Float64 number
function file_methods:readDouble()
	return unwrap(self):ReadDouble()
end

--- Reads a float and advances the file position
-- @return number Float32 number
function file_methods:readFloat()
	return unwrap(self):ReadFloat()
end

--- Reads a line and advances the file position
-- @return string Line contents
function file_methods:readLine()
	return unwrap(self):ReadLine()
end

--- Reads a long and advances the file position
-- @return number Int32 number
function file_methods:readLong()
	return unwrap(self):ReadLong()
end

--- Reads an unsigned long and advances the file position
-- @return number UInt32 number
function file_methods:readULong()
	return unwrap(self):ReadULong()
end

--- Reads a short and advances the file position
-- @return number Int16 number
function file_methods:readShort()
	return unwrap(self):ReadShort()
end

--- Reads an unsigned short and advances the file position
-- @return number UInt16 number
function file_methods:readUShort()
	return unwrap(self):ReadUShort()
end

--- Reads an unsigned 64-bit integer and advances the file position
--- Note: Since Lua cannot store full 64-bit integers, this function returns a string.
-- @return string UInt64 number
function file_methods:readUInt64()
	return unwrap(self):ReadUInt64()
end

--- Writes a string to the file and advances the file position
-- @param string str The data to write
function file_methods:write(str)
	checkluatype (str, TYPE_STRING)
	unwrap(self):Write(str)
end

--- Writes a boolean and advances the file position
-- @param boolean x The boolean to write
function file_methods:writeBool(x)
	checkluatype (x, TYPE_BOOL)
	unwrap(self):WriteBool(x)
end

--- Writes a byte and advances the file position
-- @param number x The byte to write
function file_methods:writeByte(x)
	checkluatype (x, TYPE_NUMBER)
	unwrap(self):WriteByte(x)
end

--- Writes a double and advances the file position
-- @param number x The double to write
function file_methods:writeDouble(x)
	checkluatype (x, TYPE_NUMBER)
	unwrap(self):WriteDouble(x)
end

--- Writes a float and advances the file position
-- @param number x The float to write
function file_methods:writeFloat(x)
	checkluatype (x, TYPE_NUMBER)
	unwrap(self):WriteFloat(x)
end

--- Writes a long and advances the file position
-- @param number x The long to write
function file_methods:writeLong(x)
	checkluatype (x, TYPE_NUMBER)
	unwrap(self):WriteLong(x)
end

--- Writes an unsigned long and advances the file position
-- @param number x The unsigned long to write
function file_methods:writeULong(x)
	checkluatype (x, TYPE_NUMBER)
	unwrap(self):WriteULong(x)
end

--- Writes a short and advances the file position
-- @param number x The short to write
function file_methods:writeShort(x)
	checkluatype (x, TYPE_NUMBER)
	unwrap(self):WriteShort(x)
end

--- Writes an unsigned short and advances the file position
-- @param number x The unsigned short to write
function file_methods:writeUShort(x)
	checkluatype (x, TYPE_NUMBER)
	unwrap(self):WriteUShort(x)
end

--- Writes an unsigned 64-bit integer and advances the file position
--- Note: Since Lua cannot store full 64-bit integers, this function takes a string.
-- @param string x The unsigned 64-bit integer to write
function file_methods:writeUInt64(x)
	checkluatype (x, TYPE_STRING)
	unwrap(self):WriteUInt64(x)
end

end
