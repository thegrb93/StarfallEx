-------------------------------------------------------------------------------
-- SF Preprocessor.
-- Processes code for compile time directives.
-------------------------------------------------------------------------------

-- TODO: Make an @include-only parser

SF.Preprocessor = {}
SF.Preprocessor.directives = {}

--- Sets a global preprocessor directive.
-- @param directive The directive to set.
-- @param func The callback. Takes the directive arguments, the file name, and instance.data
-- @param argPattern Lua pattern to be combined and used for more accurate matching the rest of the line (after directive name).
function SF.Preprocessor.SetGlobalDirective(directive, func, argPattern)
	SF.Preprocessor.directives[directive] = { func, argPattern }
end

local function FindComments(line)
	-- TODO: Add support to find Garry's C-style comments // and /* */
	local ret, count, pos, found = {}, 0, 1
	repeat
		found = line:find('["%-%[%]]', pos)
		if (found) then -- We found something
			local oldpos = pos

			local char = line:sub(found, found)
			if char == "-" then
				if line:sub(found, found + 1) == "--" then
					-- Comment beginning
					if line:sub(found, found + 3) == "--[[" then
						-- Block Comment beginning
						count = count + 1
						ret[count] = { type = "start", pos = found }
						pos = found + 4
					else
						-- Line comment beginning
						count = count + 1
						ret[count] = { type = "line", pos = found }
						pos = found + 2
					end
				else
					pos = found + 1
				end
			elseif char == "[" then
				local level = line:sub(found + 1):match("^(=*)")
				if level then level = string.len(level) else level = 0 end

				if line:sub(found + level + 1, found + level + 1) == "[" then
					-- Block string start
					count = count + 1
					ret[count] = { type = "stringblock", pos = found, level = level }
					pos = found + level + 2
				else
					pos = found + 1
				end
			elseif char == "]" then
				local level = line:sub(found + 1):match("^(=*)")
				if level then level = string.len(level) else level = 0 end

				if line:sub(found + level + 1, found + level + 1) == "]" then
					-- Ending
					count = count + 1
					ret[count] = { type = "end", pos = found, level = level }
					pos = found + level + 2
				else
					pos = found + 1
				end
			elseif char == "\"" then
				if line:sub(found-1, found-1) == "\\" and line:sub(found-2, found-1) ~= "\\\\" then
					-- Escaped character
					pos = found + 1
				else
					-- String
					count = count + 1
					ret[count] = { type = "string", pos = found }
					pos = found + 1
				end
			end

			if oldpos == pos then error("Regex found something, but nothing handled it") end
		end
	until not found
	return ret, count
end

local directivePattern = "%-%-@(%w+)"
--- Parses a source file for directives.
-- @param filename The file name of the source code (or "file" if being run by SF editor).
-- @param source The source code to parse.
-- @param data The data table passed to the directives.
function SF.Preprocessor.ParseDirectives(filename, source, data)
	local includesdata = data.includesdata
	if includesdata and includesdata[filename] then
		return
	end
	local ending = nil
	local endingLevel = nil
	local lines = string.Explode("\r?\n", source, true)
	for _, line in next, lines do
		for _, comment in ipairs(FindComments(line)) do
			if ending then
				if comment.type == ending then
					if endingLevel then
						if comment.level and comment.level == endingLevel then
							ending = nil
							endingLevel = nil
						end
					else
						ending = nil
					end
				end
			elseif comment.type == "start" then
				ending = "end"
			elseif comment.type == "string" then
				ending = "string"
			elseif comment.type == "stringblock" then
				ending = "end"
				endingLevel = comment.level
			elseif comment.type == "line" then
				local directive = string.match(line, directivePattern)
				if directive then
					local obj = SF.Preprocessor.directives[directive]
					if obj then
						local func, argPattern = obj[1], obj[2]
						argPattern = "(" .. directivePattern .. "[\t ]" .. (argPattern and ("+(" .. argPattern .. ")") or "*(.*)") .. ")"
						local fullMatch, _, args = string.match(line, argPattern)
						func(args, filename, data, fullMatch)
					end
				end
			end
		end

		if ending == "newline" then ending = nil end
	end
end

local function directive_include(args, filename, data)
	if not data.includes then data.includes = {} end
	if not data.includes[filename] then data.includes[filename] = {} end

	local incl = data.includes[filename]
	incl[#incl + 1] = string.Trim(args)
end
SF.Preprocessor.SetGlobalDirective("include", directive_include)

local function directive_includedir(args, filename, data)
	if not data.includedirs then data.includedirs = {} end
	if not data.includedirs[filename] then data.includedirs[filename] = {} end

	local incl = data.includedirs[filename]
	incl[#incl + 1] = string.Trim(args)
end
SF.Preprocessor.SetGlobalDirective("includedir", directive_includedir)

SF.Preprocessor.SetGlobalDirective("includedata", function(args, filename, data)
	if not data.includesdata then data.includesdata = {} end
	if not data.includesdata[filename] then data.includesdata[filename] = {} end

	local incl = data.includesdata[filename]
	incl[#incl + 1] = string.Trim(args)

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

SF.Preprocessor.SetGlobalDirective("using", function(args, fileName, data, fullMatch)
	if not args then return end -- silently continue, because there are no args (no URL at all)
	local using = data.using or {}
	local fileUsing = using[fileName] or {}
	args = string.Trim(args)
	local url, name = string.match(args, "^(.+)[\t ]+as[\t ]+(.+)$")
	fileUsing[#fileUsing + 1] = { fullMatch, url or args, name }
	using[fileName] = fileUsing
	data.using = using
end, "https?://.+")
