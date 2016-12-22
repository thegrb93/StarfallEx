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
				local level = line:sub(found+1):match("^(=*)")
				if level then level = string.len(level) else level = 0 end
				
				if line:sub(found+level+1, found+level+1) == "[" then
					-- Block string start
					count = count + 1
					ret[count] = {type = "stringblock", pos = found, level = level}
					pos = found + level + 2
				else
					pos = found + 1
				end
			elseif char == "]" then
				local level = line:sub(found+1):match("^(=*)")
				if level then level = string.len(level) else level = 0 end
				
				if line:sub(found+level+1,found+level+1) == "]" then
					-- Ending
					count = count + 1
					ret[count] = {type = "end", pos = found, level = level}
					pos = found + level + 2
				else
					pos = found + 1
				end
			elseif char == "\"" then
				if line:sub(found-1,found-1) == "\\" and line:sub(found-2,found-1) ~= "\\\\" then
					-- Escaped character
					pos = found+1
				else
					-- String
					count = count + 1
					ret[count] = {type = "string", pos = found}
					pos = found + 1
				end
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
	local endingLevel = nil
	local lines = string.Explode("\r?\n",source,true)
	for _, line in ipairs(lines) do		
		for _,comment in ipairs(FindComments(line)) do
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
				local directive, args = string.match(line,"--@(%S+)%s*(.*)")
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

local function directive_includedir( args, filename, data )
	if not data.includes then data.includes = {} end
	if not data.includes[filename] then data.includes[filename] = {} end

	local incl = data.includes[filename]

	local files = file.Find( "starfall/" ..args.. "/*", "DATA" )
	if files then
		for _, v in pairs( files ) do
			incl[ #incl+1 ] = args .. "/" .. v
		end
	end
end
SF.Preprocessor.SetGlobalDirective( "includedir", directive_includedir )

local function directive_name(args, filename, data)
	if not data.scriptnames then data.scriptnames = {} end
	data.scriptnames[filename] = args
end
SF.Preprocessor.SetGlobalDirective("name",directive_name)

local function directive_sharedscreen(args, filename, data)
	if not data.sharedscreen then data.sharedscreen = true end
	
end
SF.Preprocessor.SetGlobalDirective("sharedscreen",directive_sharedscreen)

local function directive_model( args, filename, data )
	if not data.models then data.models = {} end
	data.models[ filename ] = args
end
SF.Preprocessor.SetGlobalDirective( "model", directive_model )

SF.Preprocessor.SetGlobalDirective( "server", function( args, filename, data )
	if not data.serverorclient then data.serverorclient = {} end
	data.serverorclient[ filename ] = "server"
end)

SF.Preprocessor.SetGlobalDirective( "client", function( args, filename, data )
	if not data.serverorclient then data.serverorclient = {} end
	data.serverorclient[ filename ] = "client"
end)

--- Mark a file to be included in the upload.
-- This is required to use the file in require() and dofile()
-- @name include
-- @class directive
-- @param path Path to the file
-- @usage
-- \--@include lib/someLibrary.txt
-- 
-- require( "lib/someLibrary.txt" )
-- -- CODE

--- Mark a directory to be included in the upload.
-- This is optional to include all files in the directory in require() and dofile()
-- @name includedir
-- @class directive
-- @param path Path to the directory
-- @usage
-- \--@includedir lib
--
-- require( "lib/someLibraryInLib.txt" )
-- require( "lib/someOtherLibraryInLib.txt" )
-- -- CODE

--- Set the name of the script.
-- This will become the name of the tab and will show on the overlay of the processor
-- @name name
-- @class directive
-- @param name Name of the script
-- @usage
-- \--@name Awesome script
-- -- CODE

--
-- if SERVER then
-- \	-- Do important calculations
-- \	-- Send net message
-- else
-- \	-- Display result of important calculations
-- end

--- Set the model of the processor entity.
-- This does not set the model of the screen entity
-- @name model
-- @class directive
-- @param model String of the model
-- @usage
-- \--@model models/props_junk/watermelon01.mdl
-- -- CODE

--- Set the processor to only run on the server. Shared is default
-- @name server
-- @class directive
-- @usage
-- \--@server
-- -- CODE

--- Set the processor to only run on the client. Shared is default
-- @name client
-- @class directive
-- @usage
-- \--@client
-- -- CODE
