-------------------------------------------------------------------------------
-- SF Preprocessor.
-- Processes code for compile time directives.
-------------------------------------------------------------------------------

SF.Preprocessor = {
	directives = {},
	SetGlobalDirective = function(directive, func)
		SF.Preprocessor.directives[directive] = func
	end,
	__index = {
		Get = function(self, filename, key)
			return self.files[filename] and self.files[filename][key]
		end,
		ProcessFile = function(self, filename, code)
			local data = self.files[filename]
			data.filename = filename
			data.code = code
			for _, func in pairs(SF.Preprocessor.directives) do
				if func.init then func.init(self, data) end
			end
			for directive, args in string.gmatch(code, "%-%-@(%w+)([^\r\n]*)") do
				local func = SF.Preprocessor.directives[directive]
				if func then
					func.process(self, data, string.Trim(args))
				end
			end
			return data
		end,
		PostProcessFiles = function(self)
			for _, func in pairs(SF.Preprocessor.directives) do
				local postprocess = func.postprocess
				if postprocess then
					for _, data in pairs(self.files) do
						postprocess(self, data)
					end
				end
			end
		end,
		ProcessFiles = function(self, code)
			for filename, source in pairs(code) do
				self:ProcessFile(filename, source)
			end
			self:PostProcessFiles()
		end,
		LoadFiles = function(self, openfiles, onSuccessSignal, onErrorSignal)
			local function getInclude(path)
				return openfiles[path] or file.Read("starfall/" .. path, "DATA") or error("Bad include: " .. path)
			end
			local function getIncludePath(path, curdir)
				local path = SF.ChoosePath(path, curdir, function(testpath)
					return openfiles[testpath] or file.Exists("starfall/" .. testpath, "DATA")
				end) or error("Bad include: " .. path)
				return path, string.GetPathFromFilename(path)
			end

			local pendingRequestCount = 1
			local function checkAndUploadIfReady()
				pendingRequestCount = pendingRequestCount - 1
				if pendingRequestCount > 0 then return end
				onSuccessSignal(self)
			end

			local dontParseTbl = {}
			local filesToLoad = {}
			local httpCache = {}
			local errored = false
			local function addFileToLoad(codepath, codedir, code)
				if rawget(self.files, codepath) then return end
				filesToLoad[#filesToLoad + 1] = {codepath, codedir, code}
			end

			local function loadFiles(name, codedir, code)
				if errored then return end
				addFileToLoad(name, codedir, code)

				local ok, err = pcall(function()
				while #filesToLoad>0 do
					codepath, codedir, code = unpack(table.remove(filesToLoad))

					local fdata = self.files[codepath]
					if code==nil then code = getInclude(codepath) end
					fdata.code = code

					if dontParseTbl[codepath] then continue end

					self:ProcessFile(codepath, code)

					if fdata.includesdata then
						for _, v in ipairs(fdata.includesdata) do
							local datapath = getIncludePath(v, codedir)
							if datapath then dontParseTbl[datapath] = true end
						end
					end

					if fdata.includes then
						for k, v in ipairs(fdata.includes) do
							addFileToLoad(getIncludePath(v, codedir))
						end
					end

					if fdata.includedirs then
						for _, origdir in ipairs(fdata.includedirs) do
							local dir = origdir
							local files
							if string.sub(dir, 1, 1)~="/" then
								dir = SF.NormalizePath(codedir .. origdir)
								files = file.Find("starfall/" .. dir .. "/*", "DATA")
							end
							if not files or #files==0 then
								dir = SF.NormalizePath(origdir)
								files = file.Find("starfall/" .. dir .. "/*", "DATA")
							end
							for k, v in ipairs(files) do
								addFileToLoad(getIncludePath(v, dir.."/"))
							end
						end
					end

					if fdata.httpincludes then
						for _, data in ipairs(fdata.httpincludes) do
							local url, name = unpack(data)
							if not httpCache[url] then
								if rawget(self.files, name) then error("--@httpinclude file name conflicting with already included filename: "..name) end
								httpCache[url] = name or true -- prevents duplicate requests to the same URL
								pendingRequestCount = pendingRequestCount + 1
								HTTP {
									method = "GET",
									url = url,
									success = function(_, contents)
										httpCache[url]=contents
										loadFiles(name, codedir, contents)
									end,
									failed = function(reason)
										errored=true
										onErrorSignal(string.format("Could not fetch --@include link (%s): %s", reason, url))
									end,
								}
							end
						end
					end
				end
				end)
				if ok then
					checkAndUploadIfReady()
				else
					errored=true
					onErrorSignal(err)
				end
			end

			loadFiles(getIncludePath(mainfile, string.GetPathFromFilename(mainfile)))

		end,
		ResolvePath = function(self, callingfile, path)
			local curdir = string.GetPathFromFilename(callingfile)
			return SF.ChoosePath(path, curdir, function(testpath)
				return rawget(self.files, testpath)
			end)
		end,
		GetSendData = function(sfdata)
			local senddata = {
				owner = sfdata.owner,
				mainfile = ppdata:Get(sfdata.mainfile, "clientmain") or sfdata.mainfile,
				proc = sfdata.proc
			}
			local ownersenddata

			local files = {} for k, v in pairs(sfdata.files) do files[k] = v end

			for filename, fdata in pairs(self.files) do
				if fdata.owneronly then ownersenddata = true end
				if fdata.serverorclient == "server" then
					files[filename] = table.concat({
						"--@name " .. (fdata.scriptname or ""),
						"--@author " .. (fdata.scriptauthor or ""),
						"--@server",
						""
					}, "\n")
				end
			end

			if ownersenddata then
				local ownerfiles = {} for k, v in pairs(files) do ownerfiles[k] = v end

				for filename, fdata in pairs(self.files) do
					if fdata.owneronly then
						files[filename] = table.concat({
							"--@name " .. (fdata.scriptname or ""),
							"--@author " .. (fdata.scriptauthor or ""),
							"--@owneronly",
							""
						}, "\n")
					end
				end

				ownersenddata = {
					owner = sfdata.owner,
					mainfile = senddata.mainfile,
					proc = sfdata.proc,
					files = ownerfiles,
					compressed = SF.CompressFiles(ownerfiles)
				}
			end

			senddata.files = files
			senddata.compressed = SF.CompressFiles(files)

			return senddata, ownersenddata
		end
	},
	__call = function(t)
		return setmetatable({
			files = setmetatable({}, {__index = function(t,k) local r={} t[k]=r return r end}),
			mainfile = ""
		}, t)
	end
}
setmetatable(SF.Preprocessor, SF.Preprocessor)

local directives = SF.Preprocessor.directives
local postprocess = SF.Preprocessor.postprocess

directives.include = {
	init = function(self, data)
		data.httpincludes = {}
		data.includes = {}
	end,
	process = function(self, data, args)
		if #args == 0 then error("Empty include directive") end
		if string.match(args, "^https?://") then
			-- HTTP approach
			local httpUrl, httpName = string.match(args, "^(.+)%s+as%s+(.+)$")
			if httpUrl then
				data.httpincludes[#data.httpincludes + 1] = { httpUrl, httpName }
			else
				error("Bad include format - Expected '--@include http://url as filename'")
			end
		else
			-- Standard/Filesystem approach
			data.includes[#data.includes + 1] = args
		end
	end,
	postprocess = function(self, data)
		local serverorclient = data.serverorclient
		if serverorclient then
			for _, inc in ipairs(data.includes) do
				local incdata = self.files[inc]
				if incdata.serverorclient and serverorclient ~= incdata.serverorclient then
					return err("Incompatible client/server realm: \""..filename.."\" trying to include \""..inc.."\"")
				end
			end
		end
	end
}

directives.includedir = {
	init = function(self, data)
		data.includedirs = {}
	end,
	process = function(self, data, args)
		if #args == 0 then error("Empty includedir directive") end
		data.includedirs[#data.includedirs + 1] = args
	end
}

directives.includedata = {
	init = function(self, data)
		data.includesdata = {}
	end,
	process = function(self, data, args)
		if #args == 0 then error("Empty includedata directive") end
		data.includesdata[#data.includesdata + 1] = args
		directives.include.process(self, data, args)
	end,
	postprocess = function(self, data)
		for i, incdata in ipairs(data.includesdata) do
			incdata = self:ResolvePath(data.filename, incdata) or error("Bad --@includedata "..incdata.." in file "..data.filename)
			self.files[incdata].datafile = true
		end
	end
}

directives.name = {
	process = function(self, data, args)
		data.scriptname = string.sub(args, 1, 64)
	end
}

directives.author = {
	process = function(self, data, args)
		data.scriptauthor = string.sub(args, 1, 64)
	end
}

directives.model = {
	process = function(self, data, args)
		if #args == 0 then error("Empty model directive") end
		data.model = args
	end
}

directives.server = {
	process = function(self, data, args)
		data.serverorclient = "server"
	end
}

directives.client = {
	process = function(self, data, args)
		data.serverorclient = "client"
	end
}

directives.shared = {
	process = function(self, data, args)
		data.serverorclient = nil
	end
}

directives.clientmain = {
	process = function(self, data, args)
		data.clientmain = args
	end,
	postprocess = function(self, data)
		if data.clientmain then
			data.clientmain = self:ResolvePath(data.filename, data.clientmain) or error("Bad --@clientmain "..data.clientmain.." in file "..data.filename)
		end
	end
}

directives.superuser = {
	process = function(self, data, args)
		data.superuser = true
	end
}

directives.owneronly = {
	process = function(self, data, args)
		data.owneronly = true
	end
}
