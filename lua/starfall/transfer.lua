
-- Net extension stuff
function net.ReadStarfall(ply, callback)
	local sfdata = {
		netfiles = {},
		times = {},
		proc = net.ReadEntity(),
		owner = net.ReadEntity(),
		mainfile = net.ReadString(),
	}

	local numFiles = 0
	local completedFiles = 0
	local err = false

	local I = 0
	while I < 256 do
		if net.ReadBit() ~= 0 then break end

		local filename = net.ReadString()
		sfdata.times[filename] = net.ReadDouble()

		net.ReadStream(ply, function(data)
			if data == nil then err = true end
			completedFiles = completedFiles + 1
			sfdata.netfiles[filename] = data
			if completedFiles == numFiles then
				callback(sfdata, err)
			end
		end)

		numFiles = numFiles + 1
	end

	if numFiles == 0 then
		callback(sfdata, err)
	end
end

function net.WriteStarfall(sfdata)
	net.WriteEntity(sfdata.proc)
	net.WriteEntity(sfdata.owner)
	net.WriteString(sfdata.mainfile)

	for filename, code in pairs(sfdata.netfiles) do
		net.WriteBit(false)
		net.WriteString(filename)
		net.WriteDouble(sfdata.times[filename] or 0)
		net.WriteStream(code)
	end

	net.WriteBit(true)
end

SF.Cache = setmetatable({},{__mode="k"})

if SERVER then
	util.AddNetworkString("starfall_requpload")
	util.AddNetworkString("starfall_upload")

	SF.CacheList = setmetatable({},{__mode="k"})
	function SF.GetCacheListing(owner, ply)
		local cacheList1 = SF.CacheList[ply]
		if not cacheList1 then cacheList1 = setmetatable({},{__mode="k"}) SF.CacheList[ply] = cacheList1 end
		local cacheList2 = cacheList1[owner]
		if not cacheList2 then cacheList2 = {} cacheList1[owner] = cacheList2 end
		return cacheList2
	end

	-- Sends starfall files to clients utilizing a cache
	function SF.SendCachedStarfall(msg, sfdata, recipient)
		if recipient then
			if type(recipient)~="table" then recipient = {recipient} end
		else
			recipient = player.GetAll()
		end

		for k, ply in pairs(recipient) do
			net.Start(msg)

			local cache = SF.Cache[sfdata.owner]
			if not cache then cache = {} SF.Cache[sfdata.owner] = cache end
			local cacheList = SF.GetCacheListing(sfdata.owner, ply)

			for filename, code in pairs(sfdata.netfiles) do
				if sfdata.times[filename] and cache[filename] then
					if cacheList[filename] == sfdata.times[filename] then
						sfdata.netfiles[filename] = " "
					else
						sfdata.netfiles[filename] = cache[filename] and cache[filename].code or code
						cacheList[filename] = sfdata.times[filename]
					end
				else
					sfdata.netfiles[filename] = code
				end
			end

			net.WriteStarfall(sfdata)
			net.Send(ply)
		end
	end

	-- Receives starfall files from clients utilizing a cache
	function SF.ReceiveCachedStarfall(sfdata)
		local cache = SF.Cache[sfdata.owner]
		if not cache then cache = {} SF.Cache[sfdata.owner] = cache end
		local cacheList = SF.GetCacheListing(sfdata.owner, sfdata.owner)

		sfdata.files = {}
		for filename, code in pairs(sfdata.netfiles) do
			if cache[filename] and cache[filename].time == sfdata.times[filename] then
				sfdata.files[filename] = cache[filename].code or ""
			else
				sfdata.files[filename] = code
				cache[filename] = {code = code, time = time}
				cacheList[filename] = sfdata.times[filename]
			end
		end
	end

	local uploaddata = setmetatable({},{__mode="k"})

	--- Requests a player to send whatever code they have open in his/her editor to
	-- the server.
	-- @server
	-- @param ply Player to request code from
	-- @param callback Called when all of the code is recieved. Arguments are either the main filename and a table
	-- of filename->code pairs, or nil if the client couldn't handle the request (due to bad includes, etc)
	-- @return True if the code was requested, false if an incomplete request is still in progress for that player
	function SF.RequestCode(ply, callback)
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

		net.ReadStarfall(ply, function(sfdata, err)
			if err then
				if uploaddata[ply]==updata then
					SF.AddNotify(ply, "There was a problem uploading your code. Try again in a second.", "ERROR", 7, "ERROR1")
				end
			else
				updata.callback(sfdata)
			end
			uploaddata[ply] = nil
		end)
	end)

else

	-- Sends starfall code to the server utilizing the cache
	function SF.SendCachedStarfall(msg, files, mainfile)
		net.Start(msg)

			local cache = SF.Cache[LocalPlayer()]
			if not cache then cache = {} SF.Cache[LocalPlayer()] = cache end

			local netfiles, times = {}, {}
			for filename, code in pairs(files) do
				if cache[filename] and cache[filename].code == code then
					netfiles[filename] = " "
					times[filename] = cache[filename].time
				else
					local time = SysTime()
					netfiles[filename] = code
					times[filename] = time
					cache[filename] = {code = code, time = time}
				end
			end
			net.WriteStarfall({proc = NULL, owner = NULL, netfiles = netfiles, mainfile = mainfile, times = times})

		net.SendToServer()
	end

	-- Receives starfall files from the server utilizing a cache
	function SF.ReceiveCachedStarfall(sfdata)
		local cache = SF.Cache[sfdata.owner]
		if not cache then cache = {} SF.Cache[sfdata.owner] = cache end

		sfdata.files = {}
		for filename, code in pairs(sfdata.netfiles) do
			if cache[filename] and cache[filename].time == sfdata.times[filename] then
				sfdata.files[filename] = cache[filename].code or ""
			else
				sfdata.files[filename] = code
				if sfdata.times[filename]>0 then
					cache[filename] = {code = code, time = sfdata.times[filename]}
				end
			end
		end
	end

	net.Receive("starfall_requpload", function(len)
		local ok, list = SF.Editor.BuildIncludesTable()
		if ok then
			SF.SendCachedStarfall("starfall_upload", list.files, list.mainfile)
		else
			SF.SendCachedStarfall("starfall_upload", {}, "")
			if list then
				SF.AddNotify(LocalPlayer(), list, "ERROR", 7, "ERROR1")
			end
		end
	end)

end


