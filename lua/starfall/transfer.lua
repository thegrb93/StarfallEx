
-- Net extension stuff
function net.ReadStarfall(ply, callback)
	local sfdata = {files = {}}
	if CLIENT then
		sfdata.procindex = net.ReadUInt(16)
		sfdata.proc = Entity(sfdata.procindex)
		sfdata.ownerindex = net.ReadUInt(16)
		sfdata.owner = Entity(sfdata.ownerindex)
	end
	sfdata.mainfile = net.ReadString()

	net.ReadStream(ply, function(data)
		if data then
			sfdata.files = SF.DecompressFiles(data)
			if sfdata.files then
				callback(true, sfdata)
			else
				callback(false, sfdata)
			end
		else
			callback(false, sfdata)
		end
	end)

	return sfdata
end

function net.WriteStarfall(sfdata, callback)
	if #sfdata.mainfile > 255 then error("Main file name too large: " .. #sfdata.mainfile .. " (max is 255)") end
	if SERVER then
		net.WriteUInt(sfdata.proc:EntIndex(), 16)
		net.WriteUInt(sfdata.owner:EntIndex(), 16)
	end
	net.WriteString(sfdata.mainfile)

	if sfdata.compressed then
		return net.WriteStream(sfdata.compressed, callback, true)
	else
		local data = SF.CompressFiles(sfdata.files)
		return net.WriteStream(data, callback, true)
	end
end

function SF.CompressFiles(files)
	local data = SF.StringStream()
	data:writeInt16(table.Count(files))
	for filename, code in pairs(files) do
		if #filename > 255 then error("File name too large: " .. #filename .. " (max is 255)") end
		data:writeInt8(#filename)
		data:write(filename)
		data:writeInt32(#code)
		data:write(code)
	end
	data = data:getString()
	if #data > 64000000 then error("Too much file data!") end
	return util.Compress(data)
end

function SF.DecompressFiles(data)
	data = util.Decompress(data)
	if not data then return end
	if #data < 8 then return end
	data = SF.StringStream(data)
	local files = {}
	for i=1, data:readUInt16() do
		local name = data:read(data:readUInt8())
		local code = data:read(data:readUInt32())
		files[name] = code
	end
	return files
end

if SERVER then
	util.AddNetworkString("starfall_upload")

	function SF.SendStarfall(msg, sfdata, recipient, callback)
		net.Start(msg)
		net.WriteStarfall(sfdata, callback)
		if recipient then
			net.Send(recipient)
		else
			net.Broadcast()
		end
	end

	local uploaddata = SF.EntityTable("PlayerUploads")
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
	function SF.SendStarfall(msg, sfdata, callback)
		net.Start(msg)
		net.WriteStarfall(sfdata, callback)
		net.SendToServer()
	end

	net.Receive("starfall_upload", function()
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
