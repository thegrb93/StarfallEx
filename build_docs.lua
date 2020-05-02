local lfs = require"lfs"
local json = require"json"

local outputdir = arg[1] or "../doc/"
local sourcecode = arg[2] or "../lua/starfall"

SF = {Modules = {}}
local function readModules(path)
    for file in lfs.dir(path) do
        local moduleTbl = SF.Modules[file]
        if not moduleTbl then moduleTbl = {} SF.Modules[file] = moduleTbl end
        
        local f = assert(lfs.open(path.."/"..file, "r"))
        moduleTbl[#moduleTbl+1] = f:read("*all")
        f:close()
    end
end
readModules(sourcecode.."/libs_cl")
readModules(sourcecode.."/libs_sh")
readModules(sourcecode.."/libs_sv")

require(sourcecode.."editor/docs")

local docout = assert(lfs.open(outputdir.."/sf_doc.json", "w"))
docout:write(json.encode(SF.Docs))
docout:close()
