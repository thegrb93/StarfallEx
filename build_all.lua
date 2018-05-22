local function prequire(m) 
    local ok, err = pcall(require, m) 
    if not ok then return nil, err end
    return err
end
local pkg = prequire 'pkg'
if not pkg then
    print("Not running using ULUA");
else
    package.path = package.path .. ";?.lua"
    print("Installing lua doc")
    pkg.add("luadoc")
    pkg.update()
end
require "build_docs"
require "build_docs_json"
require "build_docs_lua"
