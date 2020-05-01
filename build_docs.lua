local lfs = require"lfs"
local json = require"json"

local outputdir = arg[1] or "../doc/"
local sourcecode = arg[2] or "../lua/starfall"

local docout = assert(lfs.open(outputdir.."/sf_doc.json", "w"))
docout:write(json.encode(doc))
docout:close()
