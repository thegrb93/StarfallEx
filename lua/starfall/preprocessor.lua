-------------------------------------------------------------------------------
-- SF Preprocessor.
-- Processes code for compile time directives.
-------------------------------------------------------------------------------

SF.PreprocessData = {
	directives = {
		include = function(self, args)
			if #args == 0 then return "Empty include directive" end
			if string.match(args, "^https?://") then
				-- HTTP approach
				local httpUrl, httpName = string.match(args, "^(.+)%s+as%s+(.+)$")
				if not httpUrl then return "Bad include format - Expected '--@include http://url as filename'" end
				self.httpincludes[#self.httpincludes + 1] = { httpUrl, httpName }
			else
				-- Standard/Filesystem approach
				self.includes[#self.includes + 1] = args
			end
		end,

		includedata = function(self, args)
			if #args == 0 then return "Empty includedata directive" end
			self.includesdata[#self.includesdata + 1] = args
			SF.PreprocessData.directives.include(self, args)
		end,
		
		includedir = function(self, args)
			if #args == 0 then return "Empty includedir directive" end
			self.includedirs[#self.includedirs + 1] = args
		end,

		model = function(self, args)
			if #args == 0 then return "Empty model directive" end
			self.model = args
		end,

		precachemodel = function(self, args)
			if #args == 0 then return "Empty precachemodel directive" end
			self.precachemodels[#self.precachemodels + 1] = args
		end,

		name = function(self, args) self.scriptname = string.sub(args, 1, 64) end,
		author = function(self, args) self.scriptauthor = string.sub(args, 1, 64) end,
		server = function(self, args) self.serverorclient = "server" end,
		client = function(self, args) self.serverorclient = "client" end,
		shared = function(self, args) self.serverorclient = nil end,
		clientmain = function(self, args) self.clientmain = args end,
		superuser = function(self, args) self.superuser = true end,
		owneronly = function(self, args) self.owneronly = true end,
	},
	__index = {
		FindError = function(self, err, args)
			for lineN, line in SF.GetLines(self.code) do
				if string.find(line, args, 1, true) then
					return tostring(lineN)
				end
			end
			return "?"
		end,
		Preprocess = function(self)
			for wholedirective, directive, args in string.gmatch(self.code, "(%-%-@(%w+)([^\r\n]*))") do
				local func = SF.PreprocessData.directives[directive]
				if func then
					local err = func(self, string.Trim(args))
					if err then error("In file "..self.path..":"..self:FindError(err, wholedirective)..", "..err) end
				end
			end
		end,
		Postprocess = function(self, processor)
			if self.clientmain then
				self.clientmain = processor:ResolvePath(self.clientmain, self.path) or error("Bad --@clientmain "..self.clientmain.." in file "..self.path)
			end
			
			for _, incdata in ipairs(self.includesdata) do
				incdata = processor:ResolvePath(incdata, self.path) or error("Bad --@includedata "..incdata.." in file "..self.path)
				processor.files[incdata].datafile = true
			end
		end
	},
	__call = function(t, path, code)
		return setmetatable({
			path = path,
			code = code,
			includes = {},
			includedirs = {},
			includesdata = {},
			httpincludes = {},
			precachemodels = {},
		}, t)
	end
}
setmetatable(SF.PreprocessData, SF.PreprocessData)

SF.Preprocessor = {
	__index = {
		ResolvePath = function(self, path, callingfile)
			return SF.ChoosePath(path, string.GetPathFromFilename(callingfile), function(testpath)
				return rawget(self.files, testpath)
			end)
		end,

		GetSendData = function(self, sfdata)
			local senddata = {
				owner = sfdata.owner,
				mainfile = self.files[sfdata.mainfile].clientmain or sfdata.mainfile,
				proc = sfdata.proc
			}
			local ownersenddata

			local files = {} for k, v in pairs(sfdata.files) do files[k] = v end

			for path, fdata in pairs(self.files) do
				if fdata.owneronly then ownersenddata = true end
				if fdata.serverorclient == "server" then
					files[path] = table.concat({
						"--@name " .. (fdata.scriptname or ""),
						"--@author " .. (fdata.scriptauthor or ""),
						"--@server",
						""
					}, "\n")
				end
			end

			if ownersenddata then
				local ownerfiles = {} for k, v in pairs(files) do ownerfiles[k] = v end

				for path, fdata in pairs(self.files) do
					if fdata.owneronly then
						files[path] = table.concat({
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
		end,
	},

	__call = function(t, files)
		local self = setmetatable({
			files = setmetatable({}, {__index = function(t,k) error("Invalid file: "..k) end}),
			mainfile = ""
		}, t)

		if files then
			for path, code in pairs(files) do
				local fdata = SF.PreprocessData(path, code)
				fdata:Preprocess()
				self.files[path] = fdata
			end
			for path, fdata in pairs(self.files) do
				fdata:Postprocess(self)
			end
		end

		return self
	end
}
setmetatable(SF.Preprocessor, SF.Preprocessor)

SF.FileLoader = {
	__index = {
		GetInclude = function(self, path)
			return self.openfiles[path] or file.Read("starfall/" .. path, "DATA") or error("Failed to read: " .. path)
		end,

		GetIncludePath = function(self, path, curfile)
			return SF.ChoosePath(path, string.GetPathFromFilename(curfile), function(testpath)
				return self.openfiles[testpath] or file.Exists("starfall/" .. testpath, "DATA")
			end) or error("Bad include in "..curfile..": " .. path)
		end,

		AddFileToLoad = function(self, path)
			if self.files[path] then return end
			local fdata = SF.PreprocessData(path, self:GetInclude(path))
			self.filesToLoad[#self.filesToLoad + 1] = fdata
			self.files[path] = fdata
		end,

		LoadUrl = function(self, url, name)
			if self.files[name] then return end

			local cache = self.httpCache[url]
			if cache then
				self.files[name] = cache
				return
			end
			
			local fdata = SF.PreprocessData(name)
			self.files[name] = fdata
			self.httpCache[url] = fdata
			self.httpRequests = self.httpRequests + 1

			HTTP {
				method = "GET",
				url = url,
				success = function(_, contents)
					fdata.code = contents
					self.filesToLoad[#self.filesToLoad + 1] = fdata
					self.httpRequests = self.httpRequests - 1
					self:Start()
				end,
				failed = function(reason)
					if self.errored then return end
					self.errored=true
					self.onfail(string.format("Could not fetch --@include link (%s): %s", url, reason))
				end,
			}
		end,

		LoadFile = function(self, fdata)
			if self.dontParseTbl[fdata.path] then return end

			fdata:Preprocess()

			for _, v in ipairs(fdata.includesdata) do
				self.dontParseTbl[self:GetIncludePath(v, fdata.path)] = true
			end
			for _, v in ipairs(fdata.includes) do
				self:AddFileToLoad(self:GetIncludePath(v, fdata.path))
			end
			for _, v in ipairs(fdata.includedirs) do
				local dir = self:GetIncludePath(v, fdata.path)
				local files = file.Find("starfall/" .. dir .. "/*", "DATA")
				for k, v in ipairs(files) do
					self:AddFileToLoad(dir.."/"..v)
				end
			end
			for _, v in ipairs(fdata.httpincludes) do
				self:LoadUrl(unpack(v))
			end
		end,

		Start = function(self, mainfile)
			if self.errored then return end

			local ok, err = pcall(function()
				if mainfile then
					self:AddFileToLoad(mainfile)
				end
				while #self.filesToLoad>0 do
					self:LoadFile(table.remove(self.filesToLoad))
				end
			end)
			if ok then
				self:Finish()
			else
				self.errored=true
				self.onfail(err)
			end
		end,

		Finish = function(self)
			if self.httpRequests > 0 then return end
			self.errored=true

			local ok, err = pcall(function()
				local files = {}
				local postprocessor = SF.Preprocessor()
				postprocessor.files = self.files
				for path, fdata in pairs(self.files) do
					fdata:Postprocess(postprocessor)
					files[path] = fdata.code
				end
				self.onsuccess(files, self.mainfile)
			end)
			if not ok then self.onfail(err) return end
		end,
	},
	__call = function(t, mainfile, openfiles, onsuccess, onfail)
		setmetatable({
			files = {},
			mainfile = mainfile,
			openfiles = openfiles,
			filesToLoad = {},
			dontParseTbl = {},
			httpRequests = 0,
			httpCache = {},
			errored = false,
			onsuccess = onsuccess,
			onfail = onfail,
		}, t):Start(mainfile)
	end
}
setmetatable(SF.FileLoader, SF.FileLoader)
