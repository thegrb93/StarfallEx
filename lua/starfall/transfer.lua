
local IsValid = FindMetaTable("Entity").IsValid

-- Net extension stuff
function net.ReadStarfall(ply, callback)
	local sfdata = {files = {}}
	if CLIENT then
		sfdata.procindex = net.ReadUInt(16)
		sfdata.proccreateindex = net.ReadUInt(32)
		sfdata.proc = Entity(sfdata.procindex)
		sfdata.ownerindex = net.ReadUInt(16)
		sfdata.ownercreateindex = net.ReadUInt(32)
		sfdata.owner = Entity(sfdata.ownerindex)
	end
	sfdata.mainfile = net.ReadString()

	net.ReadStream(ply, function(data)
		if data then
			local ok, files = pcall(SF.DecompressFiles, data)
			if ok then
				sfdata.files = files
				callback(true, sfdata)
			else
				callback(false, files)
			end
		else
			callback(false, "Net timeout")
		end
	end)

	return sfdata
end

function net.WriteStarfall(sfdata, callback)
	if #sfdata.mainfile > 255 then error("Main file name too large: " .. #sfdata.mainfile .. " (max is 255)") end
	if SERVER then
		net.WriteUInt(sfdata.proc:EntIndex(), 16)
		net.WriteUInt(sfdata.proc:GetCreationID(), 32)
		net.WriteUInt(sfdata.owner:EntIndex(), 16)
		net.WriteUInt(sfdata.owner:GetCreationID(), 32)
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
	local header = SF.StringStream()
	header:writeInt32(0) --Legacy
	header:writeInt32(table.Count(files))
	local filecodes = {""}
	for filename, code in pairs(files) do
		if #filename > 255 then error("File name too large: " .. #filename .. " (max is 255)") end
		header:writeInt32(#filename)
		header:write(filename)
		header:writeInt32(#code)
		filecodes[#filecodes + 1] = code
	end
	filecodes[1] = header:getString()
	filecodes = table.concat(filecodes)
	if #filecodes > 64000000 then error("Too much file data!") end
	return util.Compress(filecodes)
end

-- Legacy decoder
function SF.DecompressFiles(data)
	data = util.Decompress(data)
	if not data or #data < 8 then error("Error decompressing starfall data!") end
	local buff = SF.StringStream(data, 5)
	local headers = {}
	for i=1, buff:readUInt32() do
		headers[#headers + 1] = {name = buff:read(buff:readUInt32()), size = buff:readUInt32()}
	end
	local files = {}
	for k, v in ipairs(headers) do
		files[v.name] = buff:read(v.size)
	end
	return files
end

if SERVER then
	util.AddNetworkString("starfall_upload")
	util.AddNetworkString("starfall_upload_push")
	util.AddNetworkString("starfall_error")

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

	function SF.SendError(chip, message, traceback, client, should_notify)
		net.Start("starfall_error")
			net.WriteEntity(chip)
			net.WriteEntity(chip.owner)
			net.WriteString(string.sub(chip.sfdata.mainfile, 1, 1024))
			net.WriteString(string.sub(message, 1, 1024))
			net.WriteString(string.sub(traceback, 1, 1024))
		if client~=nil and should_notify~=nil then
			net.WriteBool(true)
			net.WriteEntity(client)
			net.WriteBool(should_notify)
			net.SendOmit(client)
		else
			net.WriteBool(false)
			net.Broadcast()
		end
	end

	net.Receive("starfall_error", function(_, ply)
		local chip = net.ReadEntity()
		if not IsValid(chip) then return end
		if chip.ErroredPlayers[ply] then return end
		chip.ErroredPlayers[ply] = true

		local message, traceback, should_notify = net.ReadString(), net.ReadString(), net.ReadBool()
		hook.Run("StarfallError", chip, chip.owner, ply, chip.sfdata.mainfile, message, traceback, should_notify)
		SF.SendError(chip, message, traceback, ply, should_notify)
	end)

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
					SF.AddNotify(ply, "There was a problem uploading your code ("..sfdata.."). Try again in a second.", "ERROR", 7, "ERROR1")
				end
			end
			uploaddata[ply] = nil
		end)
	end)

	net.Receive("starfall_upload_push", function(len, ply)
		local sf = net.ReadEntity()
		net.ReadStarfall(ply, function(ok, sfdata)
			if not ok then return end

			if not (IsValid(sf) and sf:GetClass() == "starfall_processor" and sf.sfdata) then return end
			if sf.sfdata.mainfile ~= sfdata.mainfile or sf.sfdata.owner ~= ply then return end
			sfdata.owner = ply
			sf:SetupFiles(sfdata)
		end)
	end)

else

	-- Sends starfall files to server
	function SF.SendStarfall(msg, sfdata, callback)
		net.Start(msg)
		net.WriteStarfall(sfdata, callback)
		net.SendToServer()
	end

	---Push code to a starfall chip owned by this user
	---@param sf Entity The starfall chip entity
	---@param sfdata any
	function SF.PushStarfall(sf, sfdata)
		net.Start("starfall_upload_push")
			net.WriteEntity(sf)
			net.WriteStarfall(sfdata)
		net.SendToServer()
	end

	
	function SF.SendError(chip, message, traceback)
		local owner, is_blocked = chip.owner, false
		if IsValid(owner) then
			is_blocked = SF.BlockedUsers:isBlocked(owner:SteamID())
		end
		net.Start("starfall_error")
			net.WriteEntity(chip)
			net.WriteString(string.sub(message, 1, 1024))
			net.WriteString(string.sub(traceback, 1, 1024))
			net.WriteBool(GetConVarNumber("sf_timebuffer_cl") > 0 and not is_blocked)
		net.SendToServer()
	end

	net.Receive("starfall_error", function()
		local chip = net.ReadEntity()
		if not IsValid(chip) then return end
		local owner = net.ReadEntity()
		if not IsValid(owner) then return end
		local mainfile = net.ReadString()
		local message = net.ReadString()
		local traceback = net.ReadString()
		local client, should_notify
		if net.ReadBool() then
			client = net.ReadEntity()
			if not IsValid(client) then return end
			should_notify = net.ReadBool()
		end
		hook.Run("StarfallError", chip, owner, client, mainfile, message, traceback, should_notify)
	end)

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
