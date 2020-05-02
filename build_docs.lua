function string.Explode(separator, str, withpattern)
	if ( withpattern == nil ) then withpattern = false end

	local ret = {}
	local current_pos = 1

	for i = 1, #str do
		local start_pos, end_pos = string.find( str, separator, current_pos, not withpattern )
		if ( not start_pos ) then break end
		ret[ i ] = string.sub( str, current_pos, start_pos - 1 )
		current_pos = end_pos + 1
	end

	ret[ #ret + 1 ] = string.sub( str, current_pos )

	return ret
end
ErrorNoHalt = print


local lfs = require"lfs"
local json = require"json"

local outputdir = "."
local sourcecode = "../lua/starfall"

SF = {Modules = {}}
local function readModules(path)
    for file in lfs.dir(path) do
        if string.match(file,".+%.lua") then
            local moduleTbl = SF.Modules[file]
            if not moduleTbl then moduleTbl = {} SF.Modules[file] = moduleTbl end
            
            local filen = path.."/"..file
            local f = assert(io.open(filen, "r"))
            moduleTbl[filen] = {source = f:read("*all")}
            f:close()
        end
    end
end
readModules(sourcecode.."/libs_cl")
readModules(sourcecode.."/libs_sh")
readModules(sourcecode.."/libs_sv")

require"docs"

local docout = assert(io.open(outputdir.."/sf_doc.json", "w"))
docout:write(json.encode(SF.Docs))
docout:close()
