
local luadoc = require"luadoc"
local io = require"io"
local xml = require"xml"
local lfs = require"lfs"
local coroutine = coroutine
local string = string
local tostring = tostring
local pairs, ipairs = pairs, ipairs
local type = type
local print = print
local assert = assert
module "doclet_xml"

--[[
options
	template_dir	=	luadoc/doclet/html/
	doclet	=	doclet_xml
	nomodules	=	false
	taglet	=	taglet_sf
	nofiles	=	false
	verbose	=	true
	output_dir	=	../doc/
]]

local function printTable(tbl, tabs, printed)
	tabs = tabs or 0
	printed = printed or {}
	local indention = string.rep("\t",tabs)
	for k,v in pairs(tbl) do
		if type(v) == "table" then
			if not printed[v] then
				print(indention..tostring(k))
				print(indention.."{")
				printed[v] = k
				printTable(v,tabs+1,printed)
				printed[v] = nil
				print(indention.."}")
			else
				print(indentation..tostring(k),"=","[table:"..printed[v].."]")
			end
		else
			print(indention..tostring(k),"=",v)
		end
	end
end

local function writeTable(tbl, out, tabs, printed)
	tabs = tabs or 0
	printed = printed or {}
	local indention = string.rep("\t",tabs)
	for k,v in pairs(tbl) do
		if type(v) == "table" then
			if not printed[v] then
				out:write(indention,tostring(k),"\n")
				out:write(indention,"{\n")
				printed[v] = k
				writeTable(v,out,tabs+1,printed)
				printed[v] = nil
				out:write(indention,"}\n")
			else
				out:write(indentation,tostring(k),"\t=\t[table:",printed[v],"]\n")
			end
		else
			out:write(indention,tostring(k),"\t=\t",tostring(v),"\n")
		end
	end
end

-- ------------------------------------------------------------------ --

local function dociter(tbl)
	return coroutine.wrap(function()
		for _,name in ipairs(tbl) do
			coroutine.yield(name, tbl[name])
		end
		return nil
	end)
end

local function fix_filename(name)
	return name:gsub("\\","/"):gsub("%.%./","")
end

local function short_filename(name)
	return name:match("[\\/]([^\\/]+)%.lua$")
end

local function writexml(filepath, xmlf, xsltpath)
	local f = assert(lfs.open(options.output_dir.."/"..filepath,"w"))
	f:write("<?xml version=\"1.0\"?>\n")
	if xsltpath then
		f:write(string.format('<?xml-stylesheet type="text/xsl" href="%s"?>\n',xsltpath))
	end
	f:write(tostring(xmlf))
	f:close()
end

local function count_dir_levels(path)
	path = fix_filename(path)
	local c = 0
	string.gsub(path, "[\\/]", function () c = c + 1 end)
	return c
end

local function docpath_file(path)
	return ("files/"..fix_filename(path)):gsub("%.lua$",".xml")
end

local function docpath_library(name)
	return "libraries/"..name..".xml"
end

local function document_function(funcdoc)
	local fxml = xml.new("function")
	fxml:append("name")[1] = funcdoc.name 
	fxml:append("summary")[1] = funcdoc.summary
	fxml:append("description")[1] = funcdoc.description or funcdoc.summary
	
	if funcdoc.depreciated then fxml:append("depreciated")[1] = funcdoc.depreciated end
	if funcdoc.library then fxml:append("library")[1] = funcdoc.library end
	if funcdoc.client then fxml:append("clientside") end
	if funcdoc.server then fxml:append("serverside") end
	
	local params = fxml:append("params")
	for name, desc in dociter(funcdoc.param) do
		local param = params:append("param")
		param:append("name")[1] = name 
		param:append("desc")[1] = desc
	end
	
	return fxml
end

local function document_table(tbldoc)
	local txml = xml.new("table")
	
	txml:append("name")[1] = tbldoc.name 
	txml:append("summary")[1] = tbldoc.summary
	txml:append("description")[1] = tbldoc.description or tbldoc.summary
	if tbldoc.depreciated then txml:append("depreciated")[1] = tbldoc.depreciated end
	if tbldoc.library then txml:append("library")[1] = tbldoc.library end
	if tbldoc.client then txml:append("clientside") end
	if tbldoc.server then txml:append("serverside") end
	
	local fields = txml:append("fields")
	for name, desc in dociter(tbldoc.field or {}) do
		local field = fields:append("field")
		field:append("name")[1] = name 
		field:append("desc")[1] = desc
	end
	
	return txml
end

local function document_file(fdoc)
	local docpath = docpath_file(fdoc.name)

	local fxml = xml.new("file")
	fxml:append("name")[1] = short_filename(fdoc.name) or fdoc.name
	fxml:append("summary")[1] = fdoc.summary
	fxml:append("description")[1] = fdoc.description or fdoc.summary
	fxml:append("path")[1] = fix_filename(fdoc.name)
	
	local funcsxml = fxml:append("functions")
	for fname, funcdoc in dociter(fdoc.functions) do
		funcsxml:append(document_function(funcdoc))
	end
	
	local tablexml = fxml:append("tables")
	for tname, tdoc in dociter(fdoc.tables) do
		tablexml:append(document_table(tdoc))
	end
	
	local levels = count_dir_levels(fdoc.name)+1
	writexml(docpath, fxml, string.rep("../",levels).."page.xsl")
end

local function document_library(ldoc)
	local docpath = docpath_library(ldoc.name)
	
	local lxml = xml.new("library")
	lxml:append("name")[1] = ldoc.name 
	lxml:append("summary")[1] = ldoc.summary
	lxml:append("description")[1] = ldoc.description or ldoc.summary
	
	local funcsxml = lxml:append("functions")
	for fname, funcdoc in dociter(ldoc.functions) do
		funcsxml:append(document_function(funcdoc))
	end
	
	local tablexml = lxml:append("tables")
	for tname, tdoc in dociter(ldoc.tables or {}) do
		tablexml:append(document_table(tdoc))
	end

	writexml(docpath, lxml, "../page.xsl")
end

function start(doc)
	-- DEBUG
	local docout = assert(lfs.open(options.output_dir.."/doc.txt","w"))
	writeTable(doc,docout)
	docout:close()
	docout = nil
	
	-- Create index for the sidebar
	local index = xml.new("index")
	do
		print("Creating index...")
		-- Files
		local files = index:append("files")
		for file, fdoc in dociter(doc.files) do
			local fdoc = doc.files[file]
			local fxml = files:append("file")
			
			fxml:append("name")[1] = short_filename(file)
			fxml:append("path")[1] = fix_filename(file)
			fxml:append("docpath")[1] = docpath_file(file)
			if fdoc.summary then
				fxml:append("summary")[1] = fdoc.summary
			end
		end
		
		-- Libraries
		local libraries = index:append("libraries")
		for lib, libdoc in dociter(doc.libraries) do
			local libdoc = doc.libraries[lib]
			
			local lxml = libraries:append("library")
			lxml:append("name")[1] = libdoc.name
			lxml:append("summary")[1] = libdoc.summary
			if libdoc.depreciated then
				lxml:append("depreciated")
			end
			if libdoc.client then
				lxml:append("clientside")
			end
			if libdoc.server then
				lxml:append("serverside")
			end
		end
	end
	
	-- Create index xml file
	do
		local index_xml = xml.new("index-page")
		index_xml:append(index)
		writexml("index.xml",index_xml,"page.xsl")
	end
	
	-- Create file documentation
	for filename, fdoc in dociter(doc.files) do
		print("Creating file documentation "..filename.."...")
		document_file(fdoc)
	end
	
	-- Create file documentation
	for filename, fdoc in dociter(doc.libraries) do
		print("Creating library documentation "..filename.."...")
		document_library(fdoc)
	end
end
