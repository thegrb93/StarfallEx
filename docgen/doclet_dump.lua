
local lfs = require"lfs"

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

doclet_dump = {}

function doclet_dump.start(doc)
	local docout = assert(lfs.open(doclet_dump.options.output_dir.."/doc.txt","w"))
	writeTable(doc,docout)
	docout:close()
	docout = nil
end

return doclet_dump