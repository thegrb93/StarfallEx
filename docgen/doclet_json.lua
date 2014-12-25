
local lfs = require"lfs"
local json = require"json"

doclet_dump = {}

function doclet_dump.start(doc)
	local docout = assert(lfs.open(doclet_dump.options.output_dir.."/doc.json","w"))
	docout:write(json.encode(doc))
	docout:close()
	docout = nil
end

return doclet_dump
