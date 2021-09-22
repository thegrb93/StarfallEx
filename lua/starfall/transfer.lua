
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
	local header = SF.StringStream()
	header:writeInt32(table.Count(files))

	local filecodes = {}
	for filename, code in pairs(files) do
		if #filename > 255 then error("File name too large: " .. #filename .. " (max is 255)") end
		header:writeInt32(#filename)
		header:write(filename)
		header:writeInt32(#code)
		filecodes[#filecodes + 1] = code
	end
	local headerdata = header:getString()
	local headersize = SF.StringStream()
	headersize:writeInt32(#headerdata)
	table.insert(filecodes, 1, headersize:getString())
	table.insert(filecodes, 2, headerdata)
	filecodes = table.concat(filecodes)
	if #filecodes > 64000000 then error("Too much file data!") end
	return util.Compress(filecodes)
end

function SF.DecompressFiles(data)
	local files = {}
	data = util.Decompress(data)
	local headersize = SF.StringStream(string.sub(data, 1, 4))
	headersize = headersize:readUInt32()
	local header = SF.StringStream(string.sub(data, 5, 4+headersize))
	local headers = {}
	for i=1, header:readUInt32() do
		headers[#headers + 1] = {name = header:read(header:readUInt32()), size = header:readUInt32()}
	end
	local pos = headersize+5
	for k, v in pairs(headers) do
		files[v.name] = string.sub(data, pos, pos+v.size-1)
		pos = pos + v.size
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

	-- Note: Current implementation does not care about comments/strings, therefore it will end up searching/replacing everywhere.
	local GetUsingURLs, IterateUsingURLs
	do
		local string_find, usingPattern = string.find, "%-%-@using ([^%s]*)"
		GetUsingURLs, IterateUsingURLs = function(code)
			local data, endPos, startPos, url = {}, 1
			do
				-- goto is actually beneficial (in JIT), when you know how to use it sparingly
				-- this code can still be optimized, but it is fine for now
				::loop_begin::
				startPos, endPos, url = string_find(code, usingPattern, endPos)
				if startPos then
					data[#data + 1], endPos = url, endPos + 1
					goto loop_begin
				end
			end
			return data
		end, function(code)
			local endPos, startPos, url = 1
			return function()
				startPos, endPos, url = string_find(code, usingPattern, endPos)
				if startPos then
					endPos = endPos + 1
					return url
				end
			end
		end
	end

	local HTTP, string_Replace = HTTP, string.Replace
	net.Receive("starfall_upload", function()
		local mainfile = net.ReadString()
		if #mainfile==0 then mainfile = nil end
		SF.Editor.BuildIncludesTable(mainfile,
			function(list)
				-- TODO: Figure out how to access ppdata here (... or not, since we scan for --@using ourselves)
				local files, pendingRequestCount = list.files, 0
				local usings = {} -- a temporary HTTP in-memory cache
				-- First stage: Scan for "--@using <url>" lines in all files, and assemble a HTTP queue structure.
				for fileName, code in next, files do
					for url in IterateUsingURLs(code) do
						if usings[url] == nil then -- must strictly check against nil (because false means existing request has failed)
							usings[url] = true -- prevents duplicate requests to the same URL
							pendingRequestCount = pendingRequestCount + 1
						end
					end
				end
				print("[SF] pendingRequestCount: " .. pendingRequestCount)
				-- Second stage: Once we know the total amount of requests and URLs, we fetch all URLs as HTTP resources.
				--               Then we wait for all HTTP requests to complete.
				local function CheckAndUploadIfReady()
					pendingRequestCount = pendingRequestCount - 1
					timer.Simple(0, function()
						-- required to ensure our loop below has run to finish, postpone upload onto next tick
						-- (it will take more than one tick to fetch HTTP anyways, so this should be fine)
						if pendingRequestCount > 0 then return end
						-- The following should run only once, at the end when there are no more pending HTTP requests:
						-- Final stage: Substitute "--@using <url>" lines in all files with the contents of their HTTP response.
						for fileName, code in next, files do
							for url, result in next, usings do
								if result then -- if HTTP request succeeded, we have a string (otherwise, result is false)
									code = string_Replace(code, "--@using " .. url, result)
									print("[SF] fileName: " .. fileName .. "  url: " .. url)
									print(code)
									files[fileName] = code
								end
							end
						end
						SF.SendStarfall("starfall_upload", {files = files, mainfile = list.mainfile})
					end)
				end
				for url in next, usings do
					print("[SF] using URL: " .. url)
					HTTP {
						method = "GET";
						url = url;
						success = function(_, contents)
							print("[SF] HTTP success - " .. url)
							print(contents)
							usings[url] = contents
							CheckAndUploadIfReady()
						end;
						failed = function(err)
							print("[SF] HTTP failed - " .. url)
							print(err)
							usings[url] = false -- preserves original code (directive line)
							CheckAndUploadIfReady()
						end;
					}
				end
			end,
			function(err)
				SF.SendStarfall("starfall_upload", {files = {}, mainfile = ""})
				SF.AddNotify(LocalPlayer(), err, "ERROR", 7, "ERROR1")
			end
		)
	end)
end
