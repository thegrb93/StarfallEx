
-- Net extension stuff
function net.ReadStarfall(ply, callback)
	local sfdata = {files = {}}
	if CLIENT then
		sfdata.proc = net.ReadEntity()
		sfdata.owner = net.ReadEntity()
	end
	sfdata.mainfile = net.ReadString()

	local headers = {}
	for I=1, net.ReadUInt(8) do
		headers[#headers + 1] = {name = net.ReadString(), size = net.ReadUInt(32)}
	end

	local crc = net.ReadString()
	net.ReadStream(ply, function(data)
		if data and util.CRC(data)==crc then
			local pos = 1
			for k, v in pairs(headers) do
				sfdata.files[v.name] = string.sub(data, pos, pos+v.size-1)
				pos = pos + v.size
			end
			callback(true, sfdata)
		else
			callback(false, sfdata)
		end
	end)
end

function net.WriteStarfall(sfdata)
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

		net.WriteString(filename)
		net.WriteUInt(#code, 32)
		filecodes[#filecodes + 1] = code
	end
	local data = table.concat(filecodes)
	net.WriteString(util.CRC(data))
	net.WriteStream(data)
end

if SERVER then
	util.AddNetworkString("starfall_upload")

	function SF.SendStarfall(msg, sfdata, recipient)
		net.Start(msg)
		net.WriteStarfall(sfdata)
		if recipient then net.Send(recipient) else net.Broadcast() end
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
			ErrorNoHalt("SF: Player "..ply:GetName().." tried to upload code without being requested.\n")
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
					SF.AddNotify(ply, "There was a problem uploading your code. Try again in a second.", "ERROR", 7, "ERROR1")
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
		SF.Editor.BuildIncludesTable(mainfile,
			function(list)
				SF.SendStarfall("starfall_upload", {files = list.files, mainfile = list.mainfile})
			end,
			function(err)
				SF.SendStarfall("starfall_upload", {files = {}, mainfile = ""})
				SF.AddNotify(LocalPlayer(), err, "ERROR", 7, "ERROR1")
			end
		)
	end)
end


