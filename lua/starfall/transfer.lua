
local IsValid = FindMetaTable("Entity").IsValid
local IsWorld = FindMetaTable("Entity").IsWorld

function net.WriteReliableEntity(ent)
	net.WriteUInt(ent:EntIndex(), 16)
	net.WriteUInt(ent:GetCreationID(), 32)
end

function net.ReadReliableEntity(cb)
	SF.WaitForEntity:add(net.ReadUInt(16), net.ReadUInt(32), cb)
end

-- Net extension stuff
function net.ReadStarfall(ply, callback)
	local sfdata = {}

	local setup = SF.WaitForAllArgs(3, function(proc, owner, files)
		if isentity(proc) then sfdata.proc = proc end
		if isentity(owner) then sfdata.owner = owner end
		if istable(files) then sfdata.files = files end

		if not proc then callback(false, sfdata, "Invalid starfall processor entity") return end
		if not owner then callback(false, sfdata, "Invalid starfall owner entity") return end
		if not files then callback(false, sfdata, "Error transferring files") return end
		callback(true, sfdata)
	end)

	if CLIENT then
		if net.ReadBool() then
			net.ReadReliableEntity(function(proc) setup(proc or false, nil, nil) end)
		else
			setup(true, nil, nil)
		end
		if net.ReadBool() then
			net.ReadReliableEntity(function(owner) setup(nil, owner or false, nil) end)
		else
			setup(nil, true, nil)
		end
	else
		setup(true, true, nil)
	end

	sfdata.mainfile = net.ReadString()

	net.ReadStream(ply, function(data)
		if data==nil then setup(nil, nil, false) return end
		local ok, files = pcall(SF.DecompressFiles, data)
		if not ok then setup(nil, nil, false) return end
		setup(nil, nil, files)
	end)
end

function net.WriteStarfall(sfdata, callback)
	if #sfdata.mainfile > 255 then error("Main file name too large: " .. #sfdata.mainfile .. " (max is 255)") end
	if SERVER then
		if IsValid(sfdata.proc) then
			net.WriteBool(true)
			net.WriteReliableEntity(sfdata.proc)
		else
			net.WriteBool(false)
		end
		if IsValid(sfdata.owner) or IsWorld(sfdata.owner) then
			net.WriteBool(true)
			net.WriteReliableEntity(sfdata.owner)
		else
			net.WriteBool(false)
		end
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
		if not IsValid(chip.owner) then return end

		-- The chip owner gets more data
		if client~=chip.owner then
			net.Start("starfall_error")
				net.WriteReliableEntity(chip)
				net.WriteReliableEntity(chip.owner)
				net.WriteString(string.sub(chip.sfdata.mainfile, 1, 1024))
				net.WriteString(string.sub(message, 1, 1024))
				net.WriteString(string.sub(traceback, 1, 1024))
			if client~=nil and should_notify~=nil then
				net.WriteReliableEntity(client)
				net.WriteBool(should_notify)
			else
				net.WriteReliableEntity(Entity(0))
				net.WriteBool(false)
			end
			net.Send(chip.owner)
		end

		net.Start("starfall_error")
			net.WriteReliableEntity(chip)
			net.WriteReliableEntity(chip.owner)
			net.WriteString(string.sub(chip.sfdata.mainfile, 1, 128))
			net.WriteString(string.sub(message, 1, 128))
			net.WriteString("")
		if client~=nil and should_notify~=nil then
			net.WriteReliableEntity(client)
			net.WriteBool(should_notify)
			net.SendOmit({client, chip.owner})
		else
			net.WriteReliableEntity(Entity(0))
			net.WriteBool(false)
			net.SendOmit(chip.owner)
		end
	end

	net.Receive("starfall_error", function(_, ply)
		local chip = Entity(net.ReadUInt(16))
		if not IsValid(chip) then return end
		if not chip.ErroredPlayers or chip.ErroredPlayers[ply] then return end
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

		net.ReadStarfall(ply, function(ok, sfdata, err)
			if ok then
				if #sfdata.mainfile > 0 then
					sfdata.owner = ply
					updata.callback(sfdata)
				end
			else
				if uploaddata[ply] == updata then
					SF.AddNotify(ply, "There was a problem uploading your code (" .. err .. "). Try again in a second.", "ERROR", 7, "ERROR1")
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
			sf:Compile(sfdata)
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
			net.WriteUInt(chip:EntIndex(), 16)
			net.WriteString(string.sub(message, 1, 1024))
			net.WriteString(string.sub(traceback, 1, 1024))
			net.WriteBool(GetConVarNumber("sf_timebuffer_cl") > 0 and not is_blocked)
		net.SendToServer()
	end

	net.Receive("starfall_error", function()
		local chip, owner, client, mainfile, message, traceback, should_notify
		local callback = 4

		local function doError()
			callback = callback - 1
			if callback>0 then return end
			if chip and owner and client then
				hook.Run("StarfallError", chip, owner, client, mainfile, message, traceback, should_notify)
			end
		end

		net.ReadReliableEntity(function(e) chip=e doError() end)
		net.ReadReliableEntity(function(e) owner=e doError() end)
		mainfile = net.ReadString()
		message = net.ReadString()
		traceback = net.ReadString()
		net.ReadReliableEntity(function(e) client=e doError() end)
		should_notify = net.ReadBool()
		doError()
	end)

	net.Receive("starfall_upload", function()
		local mainfile = net.ReadString()
		if #mainfile==0 then mainfile = nil end
		SF.Editor.BuildIncludesTable(mainfile,
			function(files, mainfile)
				SF.SendStarfall("starfall_upload", {files = files, mainfile = mainfile})
			end,
			function(err)
				SF.SendStarfall("starfall_upload", {files = {}, mainfile = ""})
				SF.AddNotify(LocalPlayer(), err, "ERROR", 7, "ERROR1")
			end
		)
	end)
end
