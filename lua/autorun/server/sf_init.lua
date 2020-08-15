AddCSLuaFile("starfall/sflib.lua")
AddCSLuaFile("starfall/instance.lua")
AddCSLuaFile("starfall/preprocessor.lua")
AddCSLuaFile("starfall/permissions/core.lua")
AddCSLuaFile("starfall/netstream.lua")
AddCSLuaFile("starfall/transfer.lua")
AddCSLuaFile("starfall/editor/editor.lua")

resource.AddFile("materials/models/spacecode/glass.vmt")
resource.AddFile("materials/models/spacecode/sfchip.vmt")
resource.AddFile("materials/models/spacecode/sfpcb.vmt")
resource.AddFile("materials/radon/starfall2.vmt")
resource.AddFile("materials/radon/arrow_left.png")
resource.AddFile("materials/radon/arrow_right.png")
resource.AddFile("models/spacecode/sfchip.mdl")
resource.AddFile("models/spacecode/sfchip_medium.mdl")
resource.AddFile("models/spacecode/sfchip_small.mdl")
resource.AddFile("resource/fonts/DejaVuSansMono.ttf")
resource.AddFile("resource/fonts/RobotoMono.ttf")
resource.AddFile("resource/fonts/FontAwesome.ttf")

local files = file.Find("html/starfalleditor*", "GAME")
if files[1] then 
	local version = tonumber(string.match(files[1], "starfalleditor(%d+)%.html") or "0")
	for k, file in pairs(files) do -- Looking for oldest
		local ver = tonumber(string.match(file, "starfalleditor(%d+)%.html") or "0")
	
		if ver > version then version = ver end
	end
	if version then
		resource.AddSingleFile("html/starfalleditor"..version..".html")
		resource.AddSingleFile("html/ace"..version.."/ace.js")
		resource.AddSingleFile("html/ace"..version.."/ext-beautify.js")
		resource.AddSingleFile("html/ace"..version.."/ext-chromevox.js")
		resource.AddSingleFile("html/ace"..version.."/ext-elastic_tabstops_lite.js")
		resource.AddSingleFile("html/ace"..version.."/ext-emmet.js")
		resource.AddSingleFile("html/ace"..version.."/ext-error_marker.js")
		resource.AddSingleFile("html/ace"..version.."/ext-keybinding_menu.js")
		resource.AddSingleFile("html/ace"..version.."/ext-language_tools.js")
		resource.AddSingleFile("html/ace"..version.."/ext-linking.js")
		resource.AddSingleFile("html/ace"..version.."/ext-modelist.js")
		resource.AddSingleFile("html/ace"..version.."/ext-old_ie.js")
		resource.AddSingleFile("html/ace"..version.."/ext-searchbox.js")
		resource.AddSingleFile("html/ace"..version.."/ext-settings_menu.js")
		resource.AddSingleFile("html/ace"..version.."/ext-spellcheck.js")
		resource.AddSingleFile("html/ace"..version.."/ext-split.js")
		resource.AddSingleFile("html/ace"..version.."/ext-static_highlight.js")
		resource.AddSingleFile("html/ace"..version.."/ext-statusbar.js")
		resource.AddSingleFile("html/ace"..version.."/ext-textarea.js")
		resource.AddSingleFile("html/ace"..version.."/ext-themelist.js")
		resource.AddSingleFile("html/ace"..version.."/ext-whitespace.js")
		resource.AddSingleFile("html/ace"..version.."/keybinding-emacs.js")
		resource.AddSingleFile("html/ace"..version.."/keybinding-vim.js")
		resource.AddSingleFile("html/ace"..version.."/mode-lua.js")
		resource.AddSingleFile("html/ace"..version.."/theme-monokai.js")
		resource.AddSingleFile("html/ace"..version.."/worker-lua.js")
	end
end

SF = {}
SF.Version = "StarfallEx"
local files, directories = file.Find( "addons/*", "GAME" )
local sf_dir = nil
for k,v in pairs(directories) do
	if file.Exists("addons/"..v.."/lua/starfall/sflib.lua", "GAME") then
		sf_dir = "addons/"..v.."/"
		break
	end
end
if sf_dir then
	local head = file.Read(sf_dir..".git/HEAD","GAME") -- Where head points to
	if head then
		head = head:sub(6,-2) -- skipping ref: and new line
		local lastCommit = file.Read( sf_dir..".git/"..head, "GAME")

		if lastCommit then
			SF.Version = SF.Version .. "_" .. lastCommit:sub(1,7) -- We need only first 7 to be safely unique
		end
	end
end
SetGlobalString("SF.Version", SF.Version)


include("starfall/sflib.lua")
