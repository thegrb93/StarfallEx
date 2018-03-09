
--- Taglet for SF, mostly copied from LuaDoc's standard taglet.

local assert, pairs, tostring, type = assert, pairs, tostring, type
local io = require "io"
local lfs = require "lfs"
local luadoc = require "luadoc"
local util = require "luadoc.util"
local tags = require "tagletsftags"
local string = require "string"
local table = require "table"

local print = print

module 'tagletsf'

-- Trims out the initial directory in file paths.
-- ex. if we say "document /home/user/code/*" we don't want
-- files to be named '/home/user/code/myfile.lua', we just
-- want 'myfile.lua'
-- Requires options.basepath to be set
local function fix_filepath(fname)
	return options.basepath and fname:match("^"..options.basepath:gsub("[/\\]", "[/\\]").."[/\\]?(.*)$") or fname
	--fname:match("^..[/\\]lua[/\\]starfall[/\\]?(.*)$") or fname
end

-------------------------------------------------------------------------------
-- Creates an iterator for an array base on a class type.
-- @param t array to iterate over
-- @param class name of the class to iterate over

function class_iterator (t, class)
	return function ()
		local i = 1
		return function ()
			while t[i] and t[i].class ~= class do
				i = i + 1
			end
			local v = t[i]
			i = i + 1
			return v
		end
	end
end

-- Patterns for function recognition
local identifiers_list_pattern = "%s*(.-)%s*"
local identifier_pattern = "[^%(%s]+"
local function_patterns = {
	"^()%s*function%s*("..identifier_pattern..")%s*%("..identifiers_list_pattern.."%)",
	"^%s*(local%s)%s*function%s*("..identifier_pattern..")%s*%("..identifiers_list_pattern.."%)",
	"^()%s*("..identifier_pattern..")%s*%=%s*function%s*%("..identifiers_list_pattern.."%)",
}

-------------------------------------------------------------------------------
-- Checks if the line contains a function definition
-- @param line string with line text
-- @return function information or nil if no function definition found

local function check_function (line)
	line = util.trim(line)

	local info = table.foreachi(function_patterns, function (_, pattern)
		local r, _, l, id, param = string.find(line, pattern)
		if r ~= nil then
			return {
				name = id,
				private = (l == "local"),
				param = util.split("%s*,%s*", param),
			}
		end
	end)

	-- TODO: remove these assert's?
	if info ~= nil then
		assert(info.name, "function name undefined")
		assert(info.param, string.format("undefined parameter list for function `%s'", info.name))
	end

	return info
end

--- Checks if the line contains a library registration
-- (call to SF.Libraries.Register)
-- @param line string with line text
-- @return the library name or nil if not found
-- @return the table name used to store the library
local function check_library (line)
	line = util.trim(line)

	-- Global library
	return line:match("^%s*local%s+([%w_]+).-=%s*SF%.Libraries%.Register%(%s*\"([^\"]+)\".-%)$")
end

--- Checks if the line contains a class creation
local function check_class (line)
	line = util.trim(line)

	return line:match("^%s*local%s+([%w_]+).-=%s*SF.Typedef%(%s*[\"']([^\"']+)[\"'].-%)$")
end

-------------------------------------------------------------------------------
-- Extracts summary information from a description. The first sentence of each 
-- doc comment should be a summary sentence, containing a concise but complete 
-- description of the item. It is important to write crisp and informative 
-- initial sentences that can stand on their own
-- @param description text with item description
-- @return summary string or nil if description is nil

local function parse_summary (description)
	-- summary is never nil...
	description = description or ""
	
	-- append an " " at the end to make the pattern work in all cases
	description = description.." "

	-- read until the first period followed by a space or tab	
	local summary = string.match(description, "(.-%.)[%s\t]")
	
	-- if pattern did not find the first sentence, summary is the whole description
	summary = summary or description
	
	return summary
end

-------------------------------------------------------------------------------
-- @param f file handle
-- @param line current line being parsed
-- @param modulename module already found, if any
-- @return current line
-- @return code block
-- @return modulename if found

local function parse_code (f, line, modulename)
	local code = {}
	while line ~= nil do
		if string.find(line, "^[\t ]*%-%-%-") then
			-- reached another luadoc block, end this parsing
			return line, code, modulename
		else
			-- look for a module definition
			--modulename = check_module(line, modulename)

			table.insert(code, line)
			line = f:read()
		end
	end
	-- reached end of file
	return line, code, modulename
end

-------------------------------------------------------------------------------
-- Parses the information inside a block comment
-- @param block block with comment field
-- @return block parameter

local function parse_comment (block, first_line, libs, classes)

	-- get the first non-empty line of code
	local code = table.foreachi(block.code, function(_, line)
		if not util.line_empty(line) then
			-- `local' declarations are ignored in two cases:
			-- when the `nolocals' option is turned on; and
			-- when the first block of a file is parsed (this is
			--	necessary to avoid confusion between the top
			--	local declarations and the `module' definition.
			if (options.nolocals or first_line) and line:find"^%s*local" then
				return
			end
			return line
		end
	end)
	
	-- parse first line of code
	if code ~= nil then
		local func_info = check_function(code)
		local libtbl, libname = check_library(code)
		local typtbl, typname = check_class(code)

		if func_info then
			block.class = "function"
			block.name = func_info.name
			block.param = func_info.param
			block.private = func_info.private
		elseif libname then
			block.class = "library"
			block.name = libname
			block.libtbl = libtbl
			block.fields = {}
			block.functions = {}
			block.tables = {}
		elseif typname then
			block.class = "class"
			block.name = typname
			block.typtbl = typtbl
			block.fields = block.fields or {}
			block.methods = block.methods or {}
		else
			block.param = {}
		end
	else
		-- TODO: comment without any code. Does this means we are dealing
		-- with a file comment?
	end

	-- parse @ tags
	local currenttag = "description"
	local currenttext
	
	table.foreachi(block.comment, function (_, line)
		line = util.trim_comment(line)
		
		local r, _, tag, text = string.find(line, "^@([_%w%.]+)%s*(.*)")
		if r ~= nil then
			-- found new tag, add previous one, and start a new one
			-- TODO: what to do with invalid tags? issue an error? or log a warning?
			tags.handle(currenttag, block, currenttext)
			
			currenttag = tag
			currenttext = text
		else
			line = line:gsub("^\\", "")
			currenttext = util.concat(currenttext, "\n" .. line)
			assert(string.sub(currenttext, 1, 1) ~= " ", string.format("`%s', `%s'", currenttext, line))
		end
	end)
	tags.handle(currenttag, block, currenttext)
	
	-- Add library to table
	if block.class == "library" then
		assert(block.name, "Unnamed library")
		assert(block.libtbl, "No library table for "..block.name)
		libs[block.libtbl] = block
		block.fields = block.fields or {}
		block.functions = block.functions or {}
		block.tables = block.tables or {}
	elseif block.class == "function" then
		local libtbl, fname = block.name:match("(.*)[%.:]([^%.:]+)$")
		
		if libtbl and not block.library then
			if libs[libtbl] then
				block.library = libtbl
			elseif classes[libtbl] then
				block.classlib = libtbl
			end
		end
		if block.library then
			local lib = libs[block.library]
			assert(lib, "no such library: "..block.library)
			block.fname = fname
			block.library = lib.name
			table.insert(lib.functions, fname)
			lib.functions[fname] = block
		elseif block.classlib then
			local class = classes[block.classlib]
			assert(class, "no such class: " .. block.classlib)
			block.fname = fname
			block.classlib = class.name
			table.insert(class.methods, fname)
			class.methods[fname] = block
		end
	elseif block.class == "table" then
		local libtbl, tname = block.name:match("(.*)%.([^%.]+)$")
		
		if libtbl and not block.library and libs[libtbl] then
			block.library = libtbl
		end
		if block.library then
			local lib = libs[block.library]
			assert(lib, "no such library: "..block.library)
			block.library = lib.name
			table.insert(lib.tables, tname)
			lib.tables[tname] = block
		end
	elseif block.class == "field" then
		local libtbl, fname = block.name:match("(.*)[%.:]([^%.:]+)$")
		
		if libtbl and not block.library then
			if libs[libtbl] then
				block.library = libtbl
			elseif classes[libtbl] then
				block.classlib = libtbl
			end
		end
		if block.library then
			local lib = libs[block.library]
			assert(lib, "no such library: " .. block.library)
			block.library = lib.name
			table.insert(lib.fields, fname)
			lib.fields[fname] = block
		elseif block.classlib then
			local class = classes[block.library]
			assert(class, "no such class: " .. block.classlib)
			block.classlib = class.name
			table.insert(class.fields, fname)
			class.fields[fname] = block
		end
	elseif block.class == "class" then
		assert(block.name, "Unnamed class")
		assert(block.typtbl, "No type table for " .. block.name)
		classes[block.typtbl] = block
		block.fields = block.fields or {}
		block.methods = block.methods or {}
	end

	-- extracts summary information from the description
	block.summary = parse_summary(block.description)
	assert(block.summary)
	--assert(string.sub(block.description, 1, 1) ~= " ", string.format("`%s'", block.description))
	--We do not want to save the code.
	block.code = nil
	block.comment = nil
	return block
end

-------------------------------------------------------------------------------
-- Parses a block of comment, started with ---. Read until the next block of
-- comment.
-- @param f file handle
-- @param line being parsed
-- @param libs table of libraries
-- @return line
-- @return block parsed
-- @return modulename if found

local function parse_block (f, line, libs, classes, first)
	local block = {
		comment = {},
		code = {},
	}

	while line ~= nil do
		if string.find(line, "^[\t ]*%-%-") == nil then
			-- reached end of comment, read the code below it
			-- TODO: allow empty lines
			line, block.code, modulename = parse_code(f, line, modulename)
			
			-- parse information in block comment
			block = parse_comment(block, first, libs, classes)

			return line, block, modulename
		else
			table.insert(block.comment, line)
			line = f:read()
		end
	end
	-- reached end of file
	
	-- parse information in block comment
	block = parse_comment(block, first, libs)
	
	return line, block, modulename
end

-------------------------------------------------------------------------------
-- Parses a file documented following luadoc format.
-- @param filepath full path of file to parse
-- @param doc table with documentation
-- @return table with documentation

function parse_file (filepath, doc)
	local blocks = {}
	local libs = {}
	local classes = {}
	local modulename = nil
	
	-- read each line
	local f = io.open(filepath, "r")
	local i = 1
	local line = f:read()
	local first = true
	while line ~= nil do
		if string.find(line, "^[\t ]*%-%-%-") then
			-- reached a luadoc block
			local block
			line, block, modulename = parse_block(f, line, libs, classes, first)
			table.insert(blocks, block)
		else
			-- look for a module definition
			--modulename = check_module(line, modulename)
			
			-- TODO: keep beginning of file somewhere
			
			line = f:read()
		end
		first = false
		i = i + 1
	end
	f:close()
	-- store blocks in file hierarchy
	local filepath = fix_filepath(filepath)
	assert(doc.files[filepath] == nil, string.format("doc for file `%s' already defined", filepath))
	table.insert(doc.files, filepath)
	doc.files[filepath] = {
		type = "file",
		name = filepath,
		doc = blocks,
		--functions = class_iterator(blocks, "function"),
		--tables = class_iterator(blocks, "table"),
	}

	local realm = filepath:sub(6, 7)
	
	local first = doc.files[filepath].doc[1]
	if first then
		doc.files[filepath].author = first.author
		doc.files[filepath].copyright = first.copyright
		doc.files[filepath].description = first.description
		doc.files[filepath].release = first.release
		doc.files[filepath].summary = first.summary
	end
	
	-- make functions table
	doc.files[filepath].functions = {}
	for f in class_iterator(blocks, "function")() do
		table.insert(doc.files[filepath].functions, f.name)
		doc.files[filepath].functions[f.name] = f
		if f.client and f.server then
			f.realm = "sh"
		elseif f.client then
			f.realm = "cl"
		elseif f.server then
			f.realm = "sv"
		else
			f.realm = realm
		end
	end
	
	-- make tables table
	doc.files[filepath].tables = {}
	for t in class_iterator(blocks, "table")() do
		table.insert(doc.files[filepath].tables, t.name)
		doc.files[filepath].tables[t.name] = t
	end
	
	-- make libraries table
	doc.files[filepath].libraries = {}
	for t in class_iterator(blocks, "library")() do
		table.insert(doc.files[filepath].libraries, t.name)
		doc.files[filepath].libraries[t.name] = t
		table.insert(doc.libraries, t.name)
		doc.libraries[t.name] = t
	end
	
	for t in class_iterator(blocks, "hook")() do
		table.insert(doc.hooks, t.name)
		doc.hooks[t.name] = t
		t.realm = realm
	end

	for t in class_iterator(blocks, "directive")() do
		table.insert(doc.directives, t.name)
		doc.directives[t.name] = t
	end

	local function union (tbl1, tbl2)
		for k, v in pairs(tbl2) do
			if type(k) == "number" then
				table.insert(tbl1, v)
			else
				tbl1[k] = v
			end
		end
	end

	for t in class_iterator(blocks, "class")() do
		if not doc.classes[t.name] then
			table.insert(doc.classes, t.name)
			doc.classes[t.name] = t
		else
			local class = doc.classes[t.name]
			union(class.fields, t.fields)
			union(class.methods, t.methods)
		end
	end

	return doc
end

-------------------------------------------------------------------------------
-- Checks if the file is terminated by ".lua" or ".luadoc" and calls the 
-- function that does the actual parsing
-- @param filepath full path of the file to parse
-- @param doc table with documentation
-- @return table with documentation
-- @see parse_file

function file (filepath, doc)
	local patterns = { "%.lua$", "%.luadoc$" }
	local valid = table.foreachi(patterns, function (_, pattern)
		if string.find(filepath, pattern) ~= nil then
			return true
		end
	end)
	
	if valid then
		-- Check if the file is an example file
		if string.find(filepath, "/examples/") then
			local name = fix_filepath(filepath):sub(10)
			local f = io.open(filepath, "r")
			doc.examples[name] = f:read("*all")
		else
			logger:info(string.format("processing file `%s'", filepath))
			doc = parse_file(filepath, doc)
		end
	end
	
	return doc
end

-------------------------------------------------------------------------------
-- Recursively iterates through a directory, parsing each file
-- @param path directory to search
-- @param doc table with documentation
-- @return table with documentation

function directory (path, doc)
	for f in lfs.dir(path) do
		local fullpath = path .. "/" .. f
		local attr = lfs.attributes(fullpath)
		assert(attr, string.format("error stating file `%s'", fullpath))
		
		if attr.mode == "file" then
			doc = file(fullpath, doc)
		elseif attr.mode == "directory" and f ~= "." and f ~= ".." then
			doc = directory(fullpath, doc)
		end
	end
	return doc
end

-- Recursively sorts the documentation table
local function recsort (tab)
	table.sort (tab)
	-- sort list of functions by name alphabetically
	for f, doc in pairs(tab) do
		if doc.functions then
			table.sort(doc.functions)
		end
		if doc.methods then
			table.sort(doc.methods)
		end
		if doc.tables then
			table.sort(doc.tables)
		end
	end
end

-------------------------------------------------------------------------------

function start (files, doc)
	assert(files, "file list not specified")
	
	-- Create an empty document, or use the given one
	doc = doc or {
		files = {},
		libraries = {},
		hooks = {},
		directives = {},
		classes = {},
		examples = {}
	}
	assert(doc.files, "undefined `files' field")
	assert(doc.libraries, "undefined `libraries' field")
	assert(doc.hooks, "undefined `hooks' field")
	assert(doc.directives, "undefined `directives' field")
	assert(doc.classes, "undefined `classes' field")
	assert(doc.examples, "undefined `examples' field")
	
	table.foreachi(files, function (_, path)
		local mode, err = lfs.attributes(path, "mode")
		assert(mode, string.format("error stating path '%s': %s", path, err or "unknown error"))
		
		if mode == "file" then
			doc = file(path, doc)
		elseif mode == "directory" then
			doc = directory(path, doc)
		else
			error(string.format("error stating path '%s': unknown file mode", path))
		end
	end)
	
	-- order arrays alphabetically
	recsort(doc.files)
	recsort(doc.libraries)
	recsort(doc.hooks)
	recsort(doc.directives)
	recsort(doc.classes)
	recsort(doc.examples)

	return doc
end
