
local assert, getfenv, ipairs, loadstring, pairs, setfenv, tostring, tonumber, type = assert, getfenv, ipairs, loadstring, pairs, setfenv, tostring, tonumber, type
local io = require "io"
local lfs = require "lfs"
local lp = require "luadoc.lp"
local luadoc = require "luadoc"
local package = package
local string = require "string"
local table = require "table"

module "docletsfhtml"

-------------------------------------------------------------------------------
-- Looks for a file `name' in given path. Removed from compat-5.1
-- @param path String with the path.
-- @param name String with the name to look for.
-- @return String with the complete path of the file found
--	or nil in case the file is not found.

local function search (path, name)
	for c in string.gfind(path, "[^;]+") do
		c = string.gsub(c, "%?", name)
		local f = io.open(c)
		if f then   -- file exist?
			f:close()
			return c
		end
	end
	return nil    -- file not found
end

-------------------------------------------------------------------------------
-- Calls iterator function on every file in directory.
-- @param path String with the path to directory.
-- @param iterator Function that is called on every file, with file name and full path as arguments.

local function dirfiles (path, ff)
	for file in lfs.dir(path) do
		local f = path .. '/' .. file
		local attr = lfs.attributes (f)
		if attr.mode == "file" then ff(file, f) end
	end
end

-------------------------------------------------------------------------------
-- Include the result of a lp template into the current stream.

function include (template, env)
	local templatepath = "./html/" .. template
	
	env = env or {}
	env.table = table
	env.io = io
	env.lp = lp
	env.pairs = pairs
	env.ipairs = ipairs
	env.tonumber = tonumber
	env.tostring = tostring
	env.type = type
	env.luadoc = luadoc
	env.options = options
	env.docletsfhtml = _M
	
	return lp.include(templatepath, env)
end

-------------------------------------------------------------------------------
-- Returns a link to a html file, appending "../" to the link to make it right.
-- @param html Name of the html file to link to
-- @return link to the html file

function link (html, from)
	local h = html
	from = from or ""
	string.gsub(from, "/", function () h = "../" .. h end)
	return h
end

-------------------------------------------------------------------------------
-- Returns the name of the html file to be generated from a module.
-- Files with "lua" or "luadoc" extensions are replaced by "html" extension.
-- @param modulename Name of the module to be processed, may be a .lua file or
-- a .luadoc file.
-- @return name of the generated html file for the module

function module_link (modulename, doc, from)
	-- TODO: replace "." by "/" to create directories?
	-- TODO: how to deal with module names with "/"?
	assert(modulename)
	assert(doc)
	from = from or ""
	
	if doc.libraries[modulename] == nil then
--		logger:error(string.format("unresolved reference to module `%s'", modulename))
		return
	end
	
	local href = "libraries/" .. modulename .. ".html"
	string.gsub(from, "/", function () href = "../" .. href end)
	return href
end

function class_link (typename, doc, from)
	assert(typename)
	assert(doc)
	from = from or ""

	if doc.classes[typename] == nil then
		return
	end

	local href = "classes/" .. typename .. ".html"
	string.gsub(from, "/", function () href = "../" .. href end)
	return href
end

function hook_link(hookname, doc, from)
	assert(hookname)
	assert(doc)
	from = from or ""
	
	if doc.hooks[hookname] == nil then
--		logger:error(string.format("unresolved reference to hook `%s'", hookname))
		return
	end
	
	local href = "hooks.html#" .. hookname
	string.gsub(from, "/", function () href = "../" .. href end)
	return href
end

function directive_link (dirname, doc, from)
	assert(dirname)
	assert(doc)
	from = from or ""

	if doc.directives[dirname] == nil then return end

	local href = "directives.html#" .. dirname
	string.gsub(from, "/", function () href = "../" .. href end)
	return href
end

function example_link (name, doc, from)
	assert(name)
	assert(doc)
	from = from or ""

	if doc.examples[name] == nil then return end

	local href = "examples/" .. name .. ".html"
	string.gsub(from, "/", function () href = "../" .. href end)
	return href
end

-------------------------------------------------------------------------------
-- Returns the name of the html file to be generated from a lua(doc) file.
-- Files with "lua" or "luadoc" extensions are replaced by "html" extension.
-- @param to Name of the file to be processed, may be a .lua file or
-- a .luadoc file.
-- @param from path of where am I, based on this we append ..'s to the
-- beginning of path
-- @return name of the generated html file

function file_link (to, from)
	assert(to)
	from = from or ""
	
	local href = to
	href = string.gsub(href, "lua$", "html")
	href = string.gsub(href, "luadoc$", "html")
	href = "files/" .. href
	string.gsub(from, "/", function () href = "../" .. href end)
	return href
end

-------------------------------------------------------------------------------
-- Returns a link to a function or to a table
-- @param fname name of the function or table to link to.
-- @param doc documentation table
-- @param kind String specying the kinf of element to link ("functions" or "tables").

function link_to (fname, doc, module_doc, file_doc, from, kind)
	assert(fname)
	assert(doc)
	from = from or ""
	kind = kind or "functions"
	
	if file_doc then
		for _, func_name in pairs(file_doc[kind]) do
			if func_name == fname then
				return file_link(file_doc.name, from) .. "#" .. fname
			end
		end
	end
	
	local _, _, modulename, fname = string.find(fname, "^(.-)[%.%:]?([^%.%:]*)$")
	assert(fname)

	-- if fname does not specify a module, use the module_doc
	if string.len(modulename) == 0 and module_doc then
		modulename = module_doc.name
	end

	local module_doc = doc.modules[modulename]
	if not module_doc then
--		logger:error(string.format("unresolved reference to function `%s': module `%s' not found", fname, modulename))
		return
	end
	
	for _, func_name in pairs(module_doc[kind]) do
		if func_name == fname then
			return module_link(modulename, doc, from) .. "#" .. fname
		end
	end
	
--	logger:error(string.format("unresolved reference to function `%s' of module `%s'", fname, modulename))
end

-------------------------------------------------------------------------------
-- Make a link to a file, module or function

function symbol_link (symbol, doc, module_doc, file_doc, from)
	assert(symbol)
	assert(doc)
	
	local href = 
--		file_link(symbol, from) or
		module_link(symbol, doc, from) or 
		link_to(symbol, doc, module_doc, file_doc, from, "functions") or
		link_to(symbol, doc, module_doc, file_doc, from, "tables")
	
	if not href then
		logger:error(string.format("unresolved reference to symbol `%s'", symbol))
	end
	
	return href or ""
end

-------------------------------------------------------------------------------
-- Assembly the output filename for an input file.
-- TODO: change the name of this function
function out_file (filename)
	filename = string.gsub(string.gsub(filename, "luadoc$", "html"), "lua$", "html")
	return string.format("%sfiles/%s", options.output_dir, filename)
end

-------------------------------------------------------------------------------
-- Assembly the output filename for a module.
-- TODO: change the name of this function
function out_module (modulename)
	return string.format("%slibraries/%s.html", options.output_dir, modulename)
end

-------------------------------------------------------------------------------
-- Assembly the output filename for a module.
-- TODO: change the name of this function
function out_class (typename)
	return string.format("%sclasses/%s.html", options.output_dir, typename)
end

function out_example (typename)
	return string.format("%sexamples/%s.html", options.output_dir, typename)
end

-----------------------------------------------------------------
-- Generate the output.
-- @param doc Table with the structured documentation.

function start (doc)
	-- Generate index file
	if (#doc.files > 0 or #doc.libraries > 0) and (not options.noindexpage) then
		local filename = options.output_dir .. "index.html"
		logger:info(string.format("generating file `%s'", filename))
		local f = lfs.open(filename, "w")
		assert(f, string.format("could not open `%s' for writing", filename))
		io.output(f)
		include("index.lp", { doc = doc })
		f:close()
	end
	
	-- Process modules
	if not options.nomodules then
		for _, modulename in ipairs(doc.libraries) do
			local module_doc = doc.libraries[modulename]
			-- assembly the filename
			local filename = out_module(modulename)
			logger:info(string.format("generating file `%s'", filename))
			
			local f = lfs.open(filename, "w")
			assert(f, string.format("could not open `%s' for writing", filename))
			io.output(f)
			include("library.lp", { doc = doc, module_doc = module_doc })
			f:close()
		end
	end

	-- Process files
	if not options.nofiles then
		for _, filepath in ipairs(doc.files) do
			local file_doc = doc.files[filepath]
			-- assembly the filename
			local filename = out_file(file_doc.name)
			logger:info(string.format("generating file `%s'", filename))
			
			local f = lfs.open(filename, "w")
			assert(f, string.format("could not open `%s' for writing", filename))
			io.output(f)
			include("file.lp", { doc = doc, file_doc = file_doc })
			f:close()
		end
	end
	
	-- Process classes
	for _, classname in ipairs(doc.classes) do
		local class_doc = doc.classes[classname]
		-- assembly the filename
		local filename = out_class(classname)
		logger:info(string.format("generating file `%s'", filename))

		local f = lfs.open(filename, "w")
		assert(f, string.format("could not open `%s' for writing", filename))
		io.output(f)
		include("class.lp", { doc = doc, class_doc = class_doc })
		f:close()
	end
	
	-- Process examples
	for name, example in pairs(doc.examples) do
		-- assembly the filename
		local filename = out_example(name)
		logger:info(string.format("generating file `%s'", filename))

		local f = lfs.open(filename, "w")
		assert(f, string.format("could not open `%s' for writing", filename))
		io.output(f)
		include("examples.lp", { doc = doc, example_doc = { name = name, code = example, path = filename } })
		f:close()
	end

	local filename = options.output_dir .. "hooks.html"
	logger:info("generating file `%s'", filename)
	local f = lfs.open(filename, "w")
	assert(f, string.format("could not open `%s' for writing", filename))
	io.output(f)
	include("hooks.lp", { doc = doc, hook_doc = doc })
	f:close()
	
	local filename = options.output_dir .. "directives.html"
	logger:info("generating file `%s'", filename)
	local f = lfs.open(filename, "w")
	assert(f, string.format("could not open `%s' for writing", filename))
	io.output(f)
	include("directives.lp", { doc = doc, dir_doc = doc })
	f:close()

	-- Copy assets

	lfs.mkdir(options.output_dir .. "assets")
	dirfiles(options.output_dir .. "assets", function(fname, fpath)
		local f = lfs.open(fpath, "w")
		io.output(f)
		include("assets/" .. fname)
		f:close()
	end)
	lfs.mkdir(options.output_dir .. "assets/js")
	dirfiles(options.output_dir .. "assets/js", function(fname, fpath)
		local f = lfs.open(fpath, "w")
		io.output(f)
		include("assets/js/" .. fname)
		f:close()
	end)
	lfs.mkdir(options.output_dir .. "assets/images")
	dirfiles(options.output_dir .. "assets/images", function(fname, fpath)
		local f = lfs.open(fpath, "w")
		io.output(f)
		include("assets/images/" .. fname)
		f:close()
	end)
end
