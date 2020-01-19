AddCSLuaFile()

if SERVER then
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
else
	-- Use the same system as wiremod to make it easier for addons to add new models
	list.Set("Starfall_gate_Models", "models/spacecode/sfchip.mdl", true)
	list.Set("Starfall_gate_Models", "models/spacecode/sfchip_medium.mdl", true)
	list.Set("Starfall_gate_Models", "models/spacecode/sfchip_small.mdl", true)
end

include("starfall/SFLib.lua")
