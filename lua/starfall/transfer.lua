
-- Net extension stuff
function net.ReadStarfall(callback)
	local files = {}
	local times = {}
	local numFiles = 0
	local completedFiles = 0
	local proc = net.ReadEntity()
	local owner = net.ReadEntity()
	local main = net.ReadString()
	local err = false

	local I = 0
	while I < 256 do
		if net.ReadBit() ~= 0 then break end

		local filename = net.ReadString()
		times[filename] = net.ReadDouble()

		net.ReadStream(nil, function(data)
			if data == nil then err = true end
			completedFiles = completedFiles + 1
			files[filename] = data
			if completedFiles == numFiles then
				callback(proc, owner, files, times, main, err)
			end
		end)

		numFiles = numFiles + 1
	end

	if numFiles == 0 then
		callback(proc, owner, files, times, main, err)
	end
end

function net.WriteStarfall(proc, owner, files, times, main)
	net.WriteEntity(proc)
	net.WriteEntity(owner)
	net.WriteString(main)

	for filename, code in pairs(files) do
		net.WriteBit(false)
		net.WriteString(filename)
		net.WriteDouble(times[filename])
		net.WriteStream(code)
	end

	net.WriteBit(true)
end

SF.Cache = setmetatable({},{__mode="k"})

if SERVER then
	util.AddNetworkString("starfall_requpload")
	util.AddNetworkString("starfall_upload")

	SF.CacheList = setmetatable({},{__mode="k"})
	-- Sends starfall files to clients utilizing a cache
	function SF.SendCachedStarfall(msg, proc, owner, files, times, mainfile, recipient)
		if recipient then
			if type(recipient)~="table" then recipient = {recipient} end
		else
			recipient = player.GetAll()
		end

		for k, ply in pairs(recipient)
			net.Start(msg)

			local cache = SF.Cache[owner]
			if not cache then cache = {} SF.Cache[owner] = cache end
			local validCache = SF.CacheList[ply]
			if not validCache then validCache = setmetatable({},{__mode="k"}) SF.CacheList[ply] = validCache end
			local validCacheO = validCache[owner]
			if not validCacheO then validCacheO = {} validCache[owner] = validCacheO end

			local sendfiles = {}
			for filename, code in pairs(files) do
				local time = times[filename]
				if cache[filename] and cache[filename].time == time then
					if validCacheO[filename] == time then
						sendfiles[filename] = " "
					else
						sendfiles[filename] = cache[filename].code or ""
						validCacheO[filename] = time
					end
				else
					-- Anything received should be in the cache. If not, something bad happened.
					sendfiles[filename] = code
					times[filename] = "error"
				end
			end

			net.WriteStarfall(proc, owner, sendfiles, times, mainfile)
			net.Send(ply)
		end
	end

	-- Receives starfall files from clients utilizing a cache
	function SF.ReceiveCachedStarfall(owner, files, times)
		local cache = SF.Cache[owner]
		if not cache then cache = {} SF.Cache[owner] = cache end

		local recvfiles = {}
		for filename, code in pairs(files) do
			local time = times[filename]
			if cache[filename] and cache[filename].time == time then
				recvfiles[filename] = cache[filename].code or ""
			else
				recvfiles[filename] = code
				cache[filename] = {code = code, time = time}
			end
		end
		return recvfiles
	end

	local uploaddata = SF.EntityTable("sfTransfer")

	--- Requests a player to send whatever code they have open in his/her editor to
	-- the server.
	-- @server
	-- @param ply Player to request code from
	-- @param callback Called when all of the code is recieved. Arguments are either the main filename and a table
	-- of filename->code pairs, or nil if the client couldn't handle the request (due to bad includes, etc)
	-- @return True if the code was requested, false if an incomplete request is still in progress for that player
	function SF.RequestCode(ply, sfEntity, callback)
		if uploaddata[ply] and uploaddata[ply].timeout > CurTime() then return false end

		net.Start("starfall_requpload")
		net.Send(ply)

		uploaddata[ply] = {
			callback = callback,
			timeout = CurTime() + 120,
		}
		return true
	end

	net.Receive("starfall_upload", function(len, ply)
		local updata = uploaddata[ply]
		if not updata or updata.reading then
			ErrorNoHalt("SF: Player "..ply:GetName().." tried to upload code without being requested (expect this message multiple times)\n")
			return
		end

		updata.reading = true

		net.ReadStarfall(function(proc, owner, files, main, err)
			if err then
				if uploaddata[ply]==updata then
					SF.AddNotify(ply, "There was a problem uploading your code. Try again in a second.", "ERROR", 7, "ERROR1")
				end
			else
				updata.callback(main, files)
			end
			uploaddata[ply] = nil
		end)
	end)

else

	-- Sends starfall code to the server utilizing the cache
	function SF.SendCachedStarfall(msg, proc, owner, files, mainfile)
		net.Start(msg)

			local cache = SF.Cache[LocalPlayer()]
			if not cache then cache = {} SF.Cache[LocalPlayer()] = cache end

			local sendfiles, times = {}, {}
			for filename, code in pairs(files) do
				if cache[filename] and cache[filename].code == code then
					sendfiles[filename] = " "
					times[filename] = cache[filename].time
				else
					local time = SysTime()
					sendfiles[filename] = code
					times[filename] = time
					cache[filename] = {code = code, time = time}
				end
			end
			net.WriteStarfall(proc, owner, sendfiles, times, mainfile)

		net.SendToServer()
	end

	-- Receives starfall files from the server utilizing a cache
	function SF.ReceiveCachedStarfall(owner, files, times)
		local cache = SF.Cache[owner]
		if not cache then cache = {} SF.Cache[owner] = cache end

		local recvfiles = {}
		for filename, code in pairs(files) do
			if filename2 then
				recvfiles[filename] = cache[filename] or ""
			else
				recvfiles[filename] = code
				cache[filename] = code
			end
		end
		return recvfiles
	end

	net.Receive("starfall_requpload", function(len)
		local ok, list = SF.Editor.BuildIncludesTable()
		if ok then
			SF.SendCachedStarfall("starfall_upload", NULL, NULL, list.files, list.mainfile)
		else
			SF.SendCachedStarfall("starfall_upload", NULL, NULL, {}, "")
			if list then
				SF.AddNotify(LocalPlayer(), list, "ERROR", 7, "ERROR1")
			end
		end
	end)

end


