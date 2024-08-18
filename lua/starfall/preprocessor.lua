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
		ProcessFile = function(self, filename, source)
			local data = self.files[filename]
			data.filename = filename
			for _, func in pairs(SF.Preprocessor.directives) do
				if func.init then func.init(self, data) end
			end
			for directive, args in string.gmatch(source, "%-%-@(%w+)([^\r\n]*)") do
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
		LoadFiles = function(self, openfiles)
			local tbl = {}
			tbl.mainfile = mainfile
			tbl.files = {}

			local function getInclude(path)
				return openfiles[path] or file.Read("starfall/" .. path, "DATA") or error("Bad include: " .. path)
			end
			local function getIncludePath(path, curdir)
				local path = SF.ChoosePath(path, curdir, function(testpath)
					return openfiles[testpath] or file.Exists("starfall/" .. testpath, "DATA")
				end) or error("Bad include: " .. path)
				return path, string.GetPathFromFilename(path)
			end

			local function recursiveLoad(codepath, codedir, code, dontParse)
				if tbl.files[codepath] then return end
				tbl.files[codepath] = code

				if dontParse then return end

				local ppfiledata = self:ProcessFile(codepath, code)

				local clientmain = ppfiledata.clientmain
				if clientmain then
					clientmain = getIncludePath(clientmain, codedir)
					if clientmain then ppdata:Set(codepath, "clientmain", clientmain) end
				end

				local dontParseTbl = {}
				local dataincludes = ppfiledata.includesdata
				if dataincludes then
					for k, v in ipairs(dataincludes) do
						local datapath = getIncludePath(v, codedir)
						if datapath then dontParseTbl[datapath] = true end
					end
				end

				local includes = ppfiledata.includes
				if includes then
					for k, v in ipairs(includes) do
						local codepath, codedir = getIncludePath(v, codedir)
						local code = getInclude(codepath)
						recursiveLoad(codepath, codedir, code, dontParseTbl[codepath])
					end
				end

				local includedirs = ppfiledata.includedirs
				if includedirs then
					for i = 1, #includedirs do
						local origdir = includedirs[i]
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
							local codepath, codedir = getIncludePath(v, dir.."/")
							local code = getInclude(codepath)
							recursiveLoad(codepath, codedir, code, dontParseTbl[codepath])
						end
					end
				end
			end

			local ok, msg = pcall(function()
				local codepath, codedir = getIncludePath(mainfile, string.GetPathFromFilename(mainfile))
				local code = getInclude(codepath)
				recursiveLoad(codepath, codedir, code)
			end)

			if not ok then
				local file = string.match(msg, "(Bad include%: .*)")
				return err(file or msg)
			end

			local clientmain = ppdata.clientmain and ppdata.clientmain[tbl.mainfile]
			if clientmain and not tbl.files[clientmain] then
				return err("Clientmain not found: " .. clientmain)
			end

			local includes = ppdata.includes
			local serverorclient = ppdata.serverorclient
			if includes and serverorclient then
				for filename, files in pairs(includes) do
					for _, inc in ipairs(files) do
						if serverorclient[inc] and serverorclient[filename] and serverorclient[filename] ~= serverorclient[inc] then
							return err("Incompatible client/server realm: \""..filename.."\" trying to include \""..inc.."\"")
						end
					end
				end
			end

			if not ppdata.httpincludes then onSuccessSignal(list) return end
			local files = list.files
			local usingCache, pendingRequestCount = {}, 0 -- a temporary HTTP in-memory cache
			-- First stage: Iterate through all http --@include directives in all files and prepare our HTTP queue structure.
			for fileName, fileUsing in next, ppdata.httpincludes do
				for _, data in next, fileUsing do
					local url, name = data[1], data[2]
					if not usingCache[url] then
						usingCache[url] = name or true -- prevents duplicate requests to the same URL
						pendingRequestCount = pendingRequestCount + 1
					end
				end
			end
			-- Second stage: Once we know the total amount of requests and URLs, we fetch all URLs as HTTP resources.
			--               Then we wait for all HTTP requests to complete.
			local function CheckAndUploadIfReady()
				pendingRequestCount = pendingRequestCount - 1
				if pendingRequestCount > 0 then return end
				-- The following should run only once, at the end when there are no more pending HTTP requests:
				-- Final stage: Substitute all http --@include directives with the contents of their HTTP response.
				for fileName, fileUsing in next, ppdata.httpincludes do
					local code = files[fileName]
					for _, data in next, fileUsing do
						local url, name = data[1], data[2]
						local result = usingCache[url]
						files[name] = result
					end
				end
				onSuccessSignal(list)
			end
			for url in next, usingCache do
				HTTP {
					method = "GET";
					url = url;
					success = function(_, contents)
						usingCache[url] = contents
						CheckAndUploadIfReady()
					end;
					failed = function(reason)
						onErrorSignal(string.format("Could not fetch --@include link (due %s): %s", reason, url))
					end;
				}
			end
		end,
		ResolvePath = function(self, callingfile, path)
			local curdir = string.GetPathFromFilename(callingfile)
			return SF.ChoosePath(path, curdir, function(testpath)
				return self.files[testpath]
			end)
		end

	},
	__call = function(t)
		return setmetatable({
			files = setmetatable({}, {__index = function(t,k) local r={} t[k]=r return r end})
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
