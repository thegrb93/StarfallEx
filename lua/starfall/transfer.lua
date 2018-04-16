
-- Net extension stuff
function net.ReadStarfall(callback)
	local files = {}
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

		net.ReadStream(nil, function(data)
			if data == nil then err = true end
			completedFiles = completedFiles + 1
			files[filename] = data
			if completedFiles == numFiles then
				callback(proc, owner, files, main, err)
			end
		end)

		numFiles = numFiles + 1
	end

	if numFiles == 0 then
		callback(proc, owner, files, main, err)
	end
end

function net.WriteStarfall(proc, owner, files, main)
	net.WriteEntity(proc)
	net.WriteEntity(owner)
	net.WriteString(main)

	for filename, code in pairs(files) do
		net.WriteBit(false)
		net.WriteString(filename)
		net.WriteStream(code)
	end

	net.WriteBit(true)
end

function SF.SendStarfall(msg, proc, owner, files, mainfile, recipient)
	net.Start(msg)
		net.WriteStarfall(proc, owner, files, mainfile)

	if SERVER then
		if recipient then net.Send(recipient) else net.Broadcast() end
	else
		net.SendToServer()
	end
end

if SERVER then
	util.AddNetworkString("starfall_reqcache")
	util.AddNetworkString("starfall_requpload")
	util.AddNetworkString("starfall_upload")
	util.AddNetworkString("starfall_cache_invalid")
	util.AddNetworkString("starfall_getcache")

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
		net.WriteEntity(sfEntity)
		net.Send(ply)

		uploaddata[ply] = {
			needHeader = true,
			callback = callback,
			timeout = CurTime() + 120,
			entity = sfEntity
		}
		return true
	end

	local getfiledata = {}

	function getFilesFromChip(chip, callback)
		getfiledata[chip] = callback
		excludeFiles = excludeFiles or {}

		net.Start("starfall_reqcache")
		net.WriteEntity(chip)
		net.SendToServer()
	end

	net.Receive("starfall_getcache", function()
		net.ReadStarfall(function(proc, owner, files, main, err)
			if not proc:IsValid() or not owner:IsValid() or err then return end
				if getfiledata[chip] then
					getfiledata[chip](files, mainfile, owner)
				end
				getfiledata[chip] = nil
		end)
	end)

	-- Send cached files on player to new players
	net.Receive("starfall_reqcache", function(len, ply)
		SF.SendStarfall("starfall_getcache", chip, chip.owner, chip.files, chip.mainfile, ply)
	end)

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
				ply.sf_latest_chip = updata.entity
				updata.callback(main, files)
			end
			uploaddata[ply] = nil
		end)
	end)
else

	net.Receive("starfall_cache_invalid", function()
		LocalPlayer().sf_cache = {}
	end)

	net.Receive("starfall_requpload", function(len)
		local ok, list = SF.Editor.BuildIncludesTable()
		local sf = net.ReadEntity()
		local cache = LocalPlayer().sf_cache or {}

		local function shouldUseCache()
			for filename, code in pairs(list.files) do
				if cache[filename] then return true end
			end

			return false
		end

		local function getFilesToRemoveOnCache()
			local diff = {}

			for filename, code in pairs(cache) do
				if not list.files[filename] then
					diff[filename] = "-removed-"
				end
			end

			return diff
		end

		local function getCacheDiff()
			local diff = {}

			for filename, code in pairs(list.files) do
				if not cache[filename] or cache[filename] ~= code then
					diff[filename] = code
				end
			end

			diff = table.Merge(diff, getFilesToRemoveOnCache())
			return diff
		end

		if ok then
			local updatedFiles = {}

			if sf:IsValid() and sf.instance then
				for filename, code in pairs(list.files) do
					if sf.files[filename] ~= code then
						updatedFiles[filename] = code
					end
				end
				for filename, code in pairs(sf.files) do
					if not list.files[filename] then
						updatedFiles[filename] = "-removed-"
					end
				end
			else
				if shouldUseCache() then
					updatedFiles = getCacheDiff()
					updatedFiles["*use-cache*"] = tostring(SysTime())
				else
					updatedFiles = list.files
				end
			end

			SF.SendStarfall("starfall_upload", NULL, NULL, updatedFiles, list.mainfile)
		else
			SF.SendStarfall("starfall_upload", NULL, NULL, {}, "")
			if list then
				SF.AddNotify(LocalPlayer(), list, "ERROR", 7, "ERROR1")
			end
		end
	end)
end


