local TabHandler = {
	ControlName = "sf_helper", -- Its name of vgui panel used by handler, there has to be one
	IsEditor = false, -- If it should be treated as editor of file, like ACE or Wire
 }
local PANEL = {} -- It's our VGUI

-------------------------------
-- Handler part (Tab Handler)
-------------------------------

function TabHandler:Init() -- It's caled when editor is initalized, you can create library map there etc
end

function TabHandler:RegisterSettings() -- Setting panels should be registered there

end

local function htmlSetup(old, new)
	if old then
		if (new.html and new.html:IsValid()) then
			new.html:Remove()
		end
		new.html = old.html
	end
	local html = new.html


	html:SetParent(new)
	html.OnChangeTitle = function(_,title)
		if not (new and new:IsValid()) then return end
		new:UpdateTitle(title or "SF Helper")
	end

	html.OnDocumentReady = function(_, url )
		if not (new and new:IsValid()) then return end
		_.loaded = true
		new.url = url
	end
end

function TabHandler:RegisterTabMenu(menu, content)
	menu:AddOption("Undock",function()


		content:Undock()
	end)
end

function TabHandler:Cleanup() -- Called when editor is reloaded/removed
end

function initDoc(html)
	function addPage(name, class, iconType, icon, data, parent)
		html:RunJavascript([[SF_DOC.AddPage("]]..name..[[", "]]..class..[[", "]]..iconType..[[", "]]..icon..[[", {}, "]]..parent..[[")]])
	end
	addPage("Libraries", "category", "", "", {}, "")
	addPage("Types", "category", "", "", {}, "")
	addPage("Hooks", "category", "", "", {}, "")

	--Libraries
	
	for _, lib in pairs(SF.Docs.Libraries) do

		addPage(lib.name, "library", "realm", lib.realm, {}, "Libraries")
		local path = "Libraries."..lib.name
		
		for _, method in pairs(lib.methods) do
			addPage(method.name, "library", "realm", method.realm, {}, path)
		
		end
	
	end

	for _, hook in pairs(SF.Docs.Hooks) do

		addPage(hook.name, "hook", "realm", hook.realm, {}, "Hooks")
	
	end

	for _, t in pairs(SF.Docs.Types) do

		addPage(t.name, "type", "realm", t.realm, {}, "Types")
	
	end


	html:RunJavascript("SF_DOC.FinishSetup()")
end



-----------------------
-- VGUI part (content)
-----------------------
function PANEL:Init() --That's init of VGUI like other PANEL:Methods(), separate for each tab
	local html = vgui.Create("DHTML", self)
	html:Dock(FILL)
	html:DockMargin(0, 0, 0, 0)
	html:DockPadding(0, 0, 0, 0)
	html:SetKeyboardInputEnabled(true)
	html:SetMouseInputEnabled(true)
	html:OpenURL("asset://garrysmod/html/sf_doc.html")
	timer.Simple(1, function() initDoc(html) end)
	self.html = html
	htmlSetup(nil, self)
end

function PANEL:Undock()
	local helper = vgui.Create("StarfallFrame")
	helper:SetSize(1280, 615)
	helper:Center()
	helper:SetTitle("SF Helper")
	helper.UpdateTitle = helper.SetTitle
	htmlSetup(self,helper)

	local _mpressed = helper.OnMousePressed
	helper.OnMousePressed = function(pnl, keycode, ...)
		if keycode == MOUSE_RIGHT then
			local menu = DermaMenu()
			menu:AddOption("Dock",function()
				local editor = SF.Editor.editor
				local sheet = editor:CreateTab("","helper")
				local content = sheet.Tab.content
				editor:SetActiveTab(sheet.Tab)
				htmlSetup(helper, content)
				helper:Remove()
			end)
			menu:AddOption("Close",function() helper:Remove() end)
			menu:Open()
		end
		_mpressed(pnl, keycode, ...)
	end
	helper:Open()
	self:CloseTab()
end

function PANEL:GetCode() -- Return name of hanlder or code if it's editor
	return "--@name "..(self.title or "StarfallEx Reference")
end

function PANEL:SetCode()

end

function PANEL:OnFocusChanged(gained) -- When this tab is opened

end

function PANEL:Validate(movecarret) -- Validate request, has to return success,message

end
--------------
-- We're done
--------------
vgui.Register(TabHandler.ControlName, PANEL, "DPanel") -- Registering VGUI element of handler
return TabHandler -- Our file has to return table of handler
