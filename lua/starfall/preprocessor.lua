-------------------------------------------------------------------------------
-- SF Preprocessor.
-- Processes code for compile time directives.
-------------------------------------------------------------------------------

SF.Preprocessor = {}
SF.Preprocessor.directives = {}

--- Sets a global preprocessor directive.
-- @param directive The directive to set.
-- @param func The callback. Takes the directive arguments, the file name, and instance.data
function SF.Preprocessor.SetGlobalDirective(directive, func)
	SF.Preprocessor.directives[directive] = func
end

--- Parses a source file for directives.
-- @param filename The file name of the source code (or "file" if being run by SF editor).
-- @param source The source code to parse.
-- @param data The data table passed to the directives.
function SF.Preprocessor.ParseDirectives(filename, source, data)
	if data.includesdata and data.includesdata[filename] then return end

	for directive, args in string.gmatch(source, "%-%-@(%w+)([^\r\n]*)") do
		local func = SF.Preprocessor.directives[directive]
		if func then
			func(string.Trim(args), filename, data)
		end
	end
end

local function directive_include(args, fileName, data)
	if #args == 0 then error("Empty include directive") end
	if string.match(args, "^https?://") then
		-- HTTP approach
		local httpUrl, httpName = string.match(args, "^(.+)%s+as%s+(.+)$")
		if httpUrl then
			if not data.httpincludes then data.httpincludes = {} end
			if not data.httpincludes[fileName] then data.httpincludes[fileName] = {} end
			local incl = data.httpincludes[fileName]
			incl[#incl + 1] = { httpUrl, httpName }
		else
			error("Bad include format - Expected '--@include http://url as filename'")
		end
	else
		-- Standard/Filesystem approach
		if not data.includes then data.includes = {} end
		if not data.includes[fileName] then data.includes[fileName] = {} end
		local incl = data.includes[fileName]
		incl[#incl + 1] = args
	end
end
SF.Preprocessor.SetGlobalDirective("include", directive_include)

local function directive_includedir(args, filename, data)
	if #args == 0 then error("Empty includedir directive") end
	if not data.includedirs then data.includedirs = {} end
	if not data.includedirs[filename] then data.includedirs[filename] = {} end

	local incl = data.includedirs[filename]
	incl[#incl + 1] = args
end
SF.Preprocessor.SetGlobalDirective("includedir", directive_includedir)

SF.Preprocessor.SetGlobalDirective("includedata", function(args, filename, data)
	if #args == 0 then error("Empty includedata directive") end
	if not data.includesdata then data.includesdata = {} end
	if not data.includesdata[filename] then data.includesdata[filename] = {} end

	local incl = data.includesdata[filename]
	incl[#incl + 1] = args

	directive_include(args, filename, data)
end)

local function directive_name(args, filename, data)
	if not data.scriptnames then data.scriptnames = {} end
	data.scriptnames[filename] = args
end
SF.Preprocessor.SetGlobalDirective("name", directive_name)

local function directive_author(args, filename, data)
	if not data.scriptauthors then data.scriptauthors = {} end
	data.scriptauthors[filename] = args
end
SF.Preprocessor.SetGlobalDirective("author", directive_author)

local function directive_model(args, filename, data)
	if not data.models then data.models = {} end
	data.models[filename] = args
end
SF.Preprocessor.SetGlobalDirective("model", directive_model)

SF.Preprocessor.SetGlobalDirective("server", function(args, filename, data)
	if not data.serverorclient then data.serverorclient = {} end
	data.serverorclient[filename] = "server"
end)

SF.Preprocessor.SetGlobalDirective("client", function(args, filename, data)
	if not data.serverorclient then data.serverorclient = {} end
	data.serverorclient[filename] = "client"
end)

SF.Preprocessor.SetGlobalDirective("shared", function() end)

SF.Preprocessor.SetGlobalDirective("clientmain", function(args, filename, data)
	if not data.clientmain then data.clientmain = {} end
	data.clientmain[filename] = args
end)

SF.Preprocessor.SetGlobalDirective("superuser", function(args, filename, data)
	if not data.superuser then data.superuser = {} end
	data.superuser[filename] = true
end)

SF.Preprocessor.SetGlobalDirective("owneronly", function(args, filename, data)
	if not data.owneronly then data.owneronly = {} end
	data.owneronly[filename] = true
end)