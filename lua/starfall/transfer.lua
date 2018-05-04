
-- Net extension stuff
function net.ReadStarfall(ply, callback)
	local sfdata = {files = {}}

	if CLIENT then
		sfdata.proc = net.ReadEntity()
		sfdata.owner = net.ReadEntity()
	end
	sfdata.mainfile = net.ReadString()

	local numFiles = 0
	local completedFiles = 0
	local err = false

	local I = 0
	while I < 256 do
		local code = net.ReadUInt(8)

		-- if code == 2 then

			-- local filename = net.ReadString()
			-- sfdata.times[filename] = net.ReadDouble()

		if code == 1 then

			local filename = net.ReadString()
			-- sfdata.times[filename] = net.ReadDouble()

			net.ReadStream(ply, function(data)
				if data == nil then err = true end
				completedFiles = completedFiles + 1
				sfdata.files[filename] = data
				if completedFiles == numFiles then
					callback(sfdata, err)
				end
			end)

			numFiles = numFiles + 1

		else
			break
		end
	end

	if numFiles == 0 then
		callback(sfdata, err)
	end
end

function net.WriteStarfall(sfdata)
	if #sfdata.mainfile > 255 then error("Main file name too large: " .. #sfdata.mainfile .. " (max is 255)") end
	if SERVER then
		net.WriteEntity(sfdata.proc)
		net.WriteEntity(sfdata.owner)
	end
	net.WriteString(sfdata.mainfile)

	local I = 0
	for filename, code in pairs(sfdata.files) do
		if I > 255 then error("Number of files exceeds the current maximum (256)") end
		if #filename > 255 then error("File name too large: " .. #filename .. " (max is 255)") end

		-- local code = sfdata.netfiles[filename] and 1 or 2
		net.WriteUInt(1, 8)
		net.WriteString(filename)
		-- net.WriteDouble(time)
		-- if code == 1 then
			net.WriteStream(code)
		-- end
		I = I + 1
	end

	net.WriteUInt(0, 8)
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

	-- Sends starfall files to clients
	function SF.SendStarfall(msg, sfdata, recipient)
		net.Start(msg)
		net.WriteStarfall(sfdata)
		if recipient then net.Send(recipient) else net.Broadcast() end
	end

	function SF.SendCachedStarfall(msg, sfdata, recipient)
		--[[if recipient then
			if type(recipient)~="table" then recipient = {recipient} end
		else
			recipient = player.GetAll()
		end

		for k, ply in pairs(recipient) do
			net.Start(msg)

			local cache = SF.Cache[sfdata.owner]
			if not cache then cache = {} SF.Cache[sfdata.owner] = cache end
			local cacheList = SF.GetCacheListing(sfdata.owner, ply)

			sfdata.netfiles = {}
			for filename, time in pairs(sfdata.times) do
				if time~=0 then
					if cacheList[filename] == time then
						sfdata.netfiles[filename] = nil
					else
						sfdata.netfiles[filename] = cache[filename] and cache[filename].code or sfdata.files[filename]
						cacheList[filename] = time
					end
				else
					sfdata.netfiles[filename] = sfdata.files[filename]
				end
			end

			net.WriteStarfall(sfdata)
			net.Send(ply)
		end]]
		net.Start(msg)
		net.WriteStarfall(sfdata)
		if recipient then net.Send(recipient) else net.Broadcast() end
	end

	-- Receives starfall files from clients utilizing a cache
	function SF.ReceiveCachedStarfall(sfdata)
		-- local cache = SF.Cache[sfdata.owner]
		-- if not cache then cache = {} SF.Cache[sfdata.owner] = cache end
		-- local cacheList = SF.GetCacheListing(sfdata.owner, sfdata.owner)

		-- sfdata.files = {}
		-- for filename, time in pairs(sfdata.times) do
			-- if cache[filename] and cache[filename].time == time then
				-- sfdata.files[filename] = cache[filename].code or ""
			-- else
				-- sfdata.files[filename] = sfdata.netfiles[filename]
				-- cache[filename] = {code = sfdata.netfiles[filename], time = time}
				-- cacheList[filename] = time
			-- end
		-- end
		sfdata.files = sfdata.netfiles
	end

	local uploaddata = setmetatable({},{__mode="k"})

	--- Requests a player to send whatever code they have open in his/her editor to
	-- the server.
	-- @server
	-- @param ply Player to request code from
	-- @param callback Called when all of the code is recieved. Arguments are either the main filename and a table
	-- of filename->code pairs, or nil if the client couldn't handle the request (due to bad includes, etc)
	-- @param mainfile Request code using this file as the main file rather than the current editor file.
	-- @return True if the code was requested, false if an incomplete request is still in progress for that player
	function SF.RequestCode(ply, callback, mainfile)
		if uploaddata[ply] and uploaddata[ply].timeout > CurTime() then return false end

		net.Start("starfall_requpload")
		net.WriteString(mainfile or "")
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
				sfdata.owner = ply
				updata.callback(sfdata)
			end
			uploaddata[ply] = nil
		end)
	end)

else

	-- Sends starfall files to server
	function SF.SendStarfall(msg, sfdata)
		net.Start(msg)
		net.WriteStarfall(sfdata)
		net.SendToServer()
	end

	-- Sends starfall code to the server utilizing the cache
	function SF.SendCachedStarfall(msg, sfdata)
		net.Start(msg)

			local cache = SF.Cache[LocalPlayer()]
			if not cache then cache = {} SF.Cache[LocalPlayer()] = cache end

			local netfiles, times = {}, {}
			for filename, code in pairs(files) do
				-- if cache[filename] and cache[filename].code == code then
					-- times[filename] = cache[filename].time
				-- else
					local time = SysTime()
					netfiles[filename] = code
					times[filename] = time
					-- cache[filename] = {code = code, time = time}
				-- end
			end
			net.WriteStarfall({netfiles = netfiles, mainfile = mainfile, times = times})

		net.SendToServer()
	end

	-- Receives starfall files from the server utilizing a cache
	function SF.ReceiveCachedStarfall(sfdata)
		--[[local cache = SF.Cache[sfdata.owner]
		if not cache then cache = {} SF.Cache[sfdata.owner] = cache end

		sfdata.files = {}
		for filename, time in pairs(sfdata.times) do
			if cache[filename] and cache[filename].time == sfdata.times[filename] then
				sfdata.files[filename] = cache[filename].code or ""
			else
				sfdata.files[filename] = sfdata.netfiles[filename]
				if time>0 then
					cache[filename] = {code = sfdata.netfiles[filename], time = time}
				end
			end
		end]]
		sfdata.files = sfdata.netfiles
	end

	net.Receive("starfall_requpload", function(len)
		local mainfile = net.ReadString()
		local ok, list = SF.Editor.BuildIncludesTable(mainfile)
		if ok then
			SF.SendStarfall("starfall_upload", {files = list.files, mainfile = list.mainfile})
		else
			SF.SendStarfall("starfall_upload", {files = {}, mainfile = ""})
			if list then
				SF.AddNotify(LocalPlayer(), list, "ERROR", 7, "ERROR1")
			end
		end
	end)
end


