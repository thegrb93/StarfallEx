-------------------------------------------------------------------------------
-- SF Preprocessor.
-- Processes code for compile time directives.
-- @author Colonel Thirty Two
-------------------------------------------------------------------------------

-- TODO: Make an @include-only parser

SF.Preprocessor = {}
SF.Preprocessor.directives = {}

--- Sets a global preprocessor directive.
-- @param directive The directive to set.
-- @param func The callback. Takes the directive arguments, the file name, and instance.data
function SF.Preprocessor.SetGlobalDirective(directive, func)
	SF.Preprocessor.directives[directive] = func
end

local function FindComments( line )
	local ret, count, pos, found = {}, 0, 1
	repeat
		found = line:find( '["%-%[%]]', pos )
		if (found) then -- We found something
			local oldpos = pos
			
			local char = line:sub(found,found)
			if char == "-" then
				if line:sub(found,found+1) == "--" then
					-- Comment beginning
					if line:sub(found,found+3) == "--[[" then
						-- Block Comment beginning
						count = count + 1
						ret[count] = {type = "start", pos = found}
						pos = found + 4
					else
						-- Line comment beginning
						count = count + 1
						ret[count] = {type = "line", pos = found}
						pos = found + 2
					end
				else
					pos = found + 1
				end
			elseif char == "[" then
				if line:sub(found,found+1) == "[[" then
					-- Block string start
					count = count + 1
					ret[count] = {type = "stringblock", pos = found}
					pos = found + 2
				else
					pos = found + 1
				end
			elseif char == "]" then
				if line:sub(found,found+1) == "]]" then
					-- Ending
					count = count + 1
					ret[count] = {type = "end", pos = found}
					pos = found + 2
				else
					pos = found + 1
				end
			elseif char == "\"" and line:sub(found-1,found-1) ~= "\\" then
				-- String
				count = count + 1
				ret[count] = {type = "string", pos = found}
				pos = found + 1
			end
			
			if oldpos == pos then error("Regex found something, but nothing handled it") end
		end
	until not found
	return ret, count
end


--- Parses a source file for directives.
-- @param filename The file name of the source code
-- @param source The source code to parse.
-- @param directives A table of additional directives to use.
-- @param data The data table passed to the directives.
function SF.Preprocessor.ParseDirectives(filename, source, directives, data)
	local ending = nil
	
	local str = source
	while str ~= "" do
		local line
		line, str = string.match(str,"^([^\n]*)\n?(.*)$")
		
		for _,comment in ipairs(FindComments(line)) do
			if ending then
				if comment.type == ending then
					ending = nil
				end
			elseif comment.type == "start" then
				ending = "end"
			elseif comment.type == "string" then
				ending = "string"
			elseif comment.type == "stringblock" then
				ending = "end"
			elseif comment.type == "line" then
				local directive, args = string.match(line,"--@([^ ]+)%s*(.*)$")
				local func = directives[directive] or SF.Preprocessor.directives[directive]
				if func then
					func(args, filename, data)
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
	incl[#incl+1] = args
end
SF.Preprocessor.SetGlobalDirective("include",directive_include)

local function directive_name(args, filename, data)
	if not data.scriptnames then data.scriptnames = {} end
	data.scriptnames[filename] = args
end
SF.Preprocessor.SetGlobalDirective("name",directive_name)

local function directive_sharedscreen(args, filename, data)
	if not data.sharedscreen then data.sharedscreen = true end
	
end
SF.Preprocessor.SetGlobalDirective("sharedscreen",directive_sharedscreen)
