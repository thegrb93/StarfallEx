
local lfs = require"lfs"
package.path = package.path .. ";../table_show.lua"

local showtable = require("table_show")
doclet_dump = {}
function cleanup(doc)
	doc["code"] = nil
	doc["comment"] = nil
	doc["files"] = nil
	doc["examples"] = nil
 	for k, v in pairs(doc) do
		if type(v) == "table" then
			cleanup(v)
		end
	end
end
function doclet_dump.start(doc)
	local docout = assert(lfs.open(doclet_dump.options.output_dir.."/docs.lua", "w"))
	cleanup(doc)
	docout:write(showtable(doc, "SF.Docs"))
	docout:close()
	docout = nil
end

return doclet_dump
