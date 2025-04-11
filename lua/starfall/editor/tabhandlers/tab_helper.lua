local TabHandler = {
	ControlName = "sf_helper", -- Its name of vgui panel used by handler, there has to be one
	IsEditor = false, -- If it should be treated as editor of file, like ACE or Wire
 }
local PANEL = {} -- It's our VGUI

-------------------------------
-- Handler part (Tab Handler)
-------------------------------

function TabHandler:Init() -- It's called when editor is initalized, you can create library map there etc
	http.Fetch(SF.Editor.HelperURL:GetString(), function(data)
		self.htmldata = data
		self:RefreshHelper()
	end)
end

function TabHandler:RefreshHelper()
	if self.htmldata and SF.Docs then
		local editor = SF.Editor.editor
		for i = 1, editor:GetNumTabs() do
			local tab = editor:GetTabContent(i)
			if tab.RefreshHelper then
				tab:RefreshHelper(theme)
			end
		end
	end
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
		if SF.Docs then html:RunJavascript([[SF_DOC.BuildPages(]]..util.TableToJSON(SF.Docs)..[[);]]) end
	end
end

function TabHandler:RegisterTabMenu(menu, content)
	menu:AddOption("Undock",function()


		content:Undock()
	end)
end

function TabHandler:Cleanup() -- Called when editor is reloaded/removed
end

-----------------------
-- VGUI part (content)
-----------------------
function PANEL:Init() --That's init of VGUI like other PANEL:Methods(), separate for each tab
	local html = vgui.Create("DHTML", self)
	self.html = html

	local backButton = vgui.Create("StarfallButton", html)
	backButton:SetText("")
	backButton:SetImage("icon16/control_rewind_blue.png")
	backButton:SetTooltip("Back")
	backButton:SetSize(16, 16)
	backButton:SetPos(0, 0)

	local forwButton = vgui.Create("StarfallButton", html)
	forwButton:SetText("")
	forwButton:SetImage("icon16/control_fastforward_blue.png")
	forwButton:SetTooltip("Forward")
	forwButton:SetSize(16, 16)
	forwButton:SetPos(16, 0)

	-- HTML panel
	backButton.DoClick = function()
		html:GoBack()
	end
	forwButton.DoClick = function()
		html:GoForward()
	end

	html:Dock(FILL)
	html:DockMargin(0, 0, 0, 0)
	html:DockPadding(0, 0, 0, 0)
	html:SetKeyboardInputEnabled(true)
	html:SetMouseInputEnabled(true)
	if TabHandler.htmldata then html:SetHTML(TabHandler.htmldata) end
	htmlSetup(nil, self)
end

function PANEL:RefreshHelper()
	if self.html then
		self.html:SetHTML(TabHandler.htmldata)
	end
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
				local sheet = editor:CreateTab("helper")
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
