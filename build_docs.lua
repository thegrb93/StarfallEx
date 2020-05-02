local lfs = require"lfs"
local json = require"json"

local outputdir = arg[1] or "."
local sourcecode = arg[2] or "../lua/starfall"

SF = {Modules = {}}
local function readModules(path)
    for file in lfs.dir(path) do
        local moduleTbl = SF.Modules[file]
        if not moduleTbl then moduleTbl = {} SF.Modules[file] = moduleTbl end
        
        local filen = path.."/"..file
        local f = assert(io.open(filen, "r"))
        moduleTbl[filen] = {source = f:read("*all")}
        f:close()
    end
end
readModules(sourcecode.."/libs_cl")
readModules(sourcecode.."/libs_sh")
readModules(sourcecode.."/libs_sv")

require(sourcecode.."/editor/docs")

local docout = assert(io.open(outputdir.."/sf_doc.json", "w"))
docout:write(json.encode(SF.Docs))
docout:close()
