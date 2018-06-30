
-- Net extension stuff
function net.ReadStarfall(recipient, callback)
	local sfdata = {files = {}}
	if CLIENT then
		sfdata.proc = net.ReadEntity()
		sfdata.owner = net.ReadEntity()
	end
	sfdata.mainfile = net.ReadString()

	local headers = {}
	for I=1, net.ReadUInt(8) do
		headers[#headers + 1] = {name = net.ReadString(), hash = net.ReadString(), size = net.ReadUInt(32)}
	end

	net.ReadStream(recipient, function(data)
		if data then
			local pos = 1
			for k, v in pairs(headers) do
				local ok, code = pcall(SF.RecvingCache, v.name, v.hash, string.sub(data, pos, pos+v.size-1), recipient)
				if ok then
					sfdata.files[name] = code
					pos = pos + v.size
				else
					callback(false, code)
					return
				end
			end
			callback(true, sfdata)
		else
			callback(false, "Transfer timed out.")
		end
	end)
end

function net.WriteStarfall(sfdata, recipient)
	if #sfdata.mainfile > 255 then error("Main file name too large: " .. #sfdata.mainfile .. " (max is 255)") end
	if SERVER then
		net.WriteEntity(sfdata.proc)
		net.WriteEntity(sfdata.owner)
	end
	net.WriteString(sfdata.mainfile)

	local numfiles = table.Count(sfdata.files)
	if numfiles > 255 then error("Number of files exceeds the current maximum (256)") end
	net.WriteUInt(numfiles, 8)

	local filecodes = {}
	for filename, code in pairs(sfdata.files) do
		if #filename > 255 then error("File name too large: " .. #filename .. " (max is 255)") end
		local hash, code = SF.SendingCache(filename, code, recipient)
		net.WriteString(filename)
		net.WriteString(hash)
		net.WriteUInt(#code, 32)
		filecodes[#filecodes + 1] = code
	end
	net.WriteStream(table.concat(filecodes))
end

do -- Cache system
	local max_cache_size = 67108864 --64MB
	local max_cache_threshold = 33554432 --32MB
	local recv_cache = {}
	local recv_cache_size = 0
	local send_cache = {}
	local send_cache_size = 0

	local function ResetCache(hash, recipient)
		net.Start("sf_resetcache")
			net.WriteString(hash)
		if SERVER then net.Send(recipient) else net.SendToServer() end
	end

	net.Receive("sf_resetcache",function(len, ply)
		local hash = net.ReadString()
		for k, v in pairs(send_cache) do
			if v.hash == hash then
				if SERVER then
					v.recipients[ply] = nil
				else
					send_cache[k] = nil
				end
			end
		end
	end)

	local function CleanRecvCache(recipient)
		local last_use_tbl = {}
		for k, v in pairs(recv_cache) do
			last_use_tbl[#last_use_tbl + 1] = {v.last_use, k, #v.code}
		end
		table.sort(last_use_tbl, function(a, b) return a[1]>b[1] end)
		for i = 1, #last_use_tbl do
			if recv_cache_size < max_cache_threshold then break end
			ResetCache(last_use_tbl[2], recv_cache[last_use_tbl[2]].owner)
			recv_cache[last_use_tbl[2]] = nil
			recv_cache_size = recv_cache_size - last_use_tbl[3]
		end
	end

	local function CleanSendCache()
		local last_use_tbl = {}
		for k, v in pairs(send_cache) do
			last_use_tbl[#last_use_tbl + 1] = {v.last_use, k, #k}
		end
		table.sort(last_use_tbl, function(a, b) return a[1]>b[1] end)
		for i = 1, #last_use_tbl do
			if send_cache_size < max_cache_threshold then break end
			send_cache[last_use_tbl[2]] = nil
			send_cache_size = send_cache_size - last_use_tbl[3]
		end
	end

	function SF.RecvingCache(filename, hash, code, recipient)
		if code == "" then
			local cache = recv_cache[hash]
			if cache then
				cache.last_use = CurTime()
				return cache.code
			else
				ResetCache(hash, recipient)
				error("Cache file doesn't exist. Failed prior download?")
			end
		else
			recv_cache[hash] = {
				code = code,
				last_use = CurTime(),
				owner = recipient
			}
			recv_cache_size = recv_cache_size + #code
			if recv_cache_size > max_cache_size then
				CleanRecvCache(recipient)
			end
			return code
		end
	end


	function SF.SendingCache(filename, code, recipient)
		local cache = send_cache[code]
		if cache then
			cache.last_use = CurTime()
			if cache.recipients[recipient] then
				return cache.hash, ""
			else
				cache.recipients[recipient] = true
				return cache.hash, code
			end
		else
			local new_entry = {
				hash = tostring(CurTime()).."_"..util.CRC(filename..code),
				last_use = CurTime()
			}
			if recipient then
				new_entry.recipients = setmetatable({
					[recipient] = true
				},{__mode="k"})
			end
			send_cache[code] = new_entry
			send_cache_size = send_cache_size + #code
			if send_cache_size > max_cache_size then
				CleanSendCache()
			end
			return new_entry.hash, code
		end
	end
end

if SERVER then
	util.AddNetworkString("starfall_upload")
	util.AddNetworkString("sf_resetcache")

	-- Sends starfall files to clients
	function SF.SendStarfall(msg, sfdata, recipient)
		if recipient then
			if type(recipient)~="table" then recipient = {recipient} end
		else
			recipient = player.GetAll()
		end

		for k, ply in pairs(recipient) do
			net.Start(msg)
			net.WriteStarfall(sfdata, ply)
			net.Send(ply)
		end
	end


	local uploaddata = setmetatable({},{__mode="k"})

	function SF.RequestCode(ply, callback, mainfile)
		if uploaddata[ply] and uploaddata[ply].timeout > CurTime() then return false end

		net.Start("starfall_upload")
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

		net.ReadStarfall(ply, function(ok, sfdata)
			if ok then
				if #sfdata.mainfile > 0 then
					sfdata.owner = ply
					updata.callback(sfdata)
				end
			else
				if uploaddata[ply]==updata then
					SF.AddNotify(ply, "Error uploading your code: "..sfdata, "ERROR", 7, "ERROR1")
				end
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

	net.Receive("starfall_upload", function(len)
		local mainfile = net.ReadString()
		if #mainfile==0 then mainfile = nil end
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


