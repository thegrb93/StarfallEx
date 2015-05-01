
require "luadoc"

local outputdir = arg[1] or "../doc/"
local sourcecode = arg[2] or "../lua/starfall"

return luadoc.main({sourcecode}, {
	output_dir = outputdir,
	basepath = sourcecode,
	--template_dir = "luadoc/doclet/html/",
	nomodules = false,
	nofiles = true,
	verbose = false,
	taglet = "tagletsf",
	doclet = "doclet_json",
})
