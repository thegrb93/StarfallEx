
local luadoc = require"luadoc"
local io = require"io"
local lfs = require"lfs"
local string = string
local pairs, ipairs = pairs, ipairs
local print = print
local assert = assert
local table = table
module "doclet_funclist"

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

function start(doc)
	local functions = {}
	for _,filename in ipairs(doc.files) do
		print("Parsing functions list from "..filename)
		local filedoc = doc.files[filename]
		for _, funcname in ipairs(filedoc.functions) do
			if funcname:sub(1,3) ~= "SF." then
				local fname = funcname:match("[%.:]?([^%.:]+)$")
				if fname:sub(1,2) ~= "__" and not functions[fname] then
					functions[#functions + 1] = fname
					functions[fname] = true
				end
			end
		end
	end
	
	local docout = assert(lfs.open(options.output_dir.."/funclist.txt","w"))
	docout:write(table.concat(functions,"\n"))
	docout:write("\n")
	docout:close()
end