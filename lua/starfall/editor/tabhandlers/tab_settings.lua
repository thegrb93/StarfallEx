local TabHandler = {
	ControlName = "sf_settings", -- Its name of vgui panel used by handler, there has to be one
	IsEditor = false, -- If it should be treated as editor of file, like ACE or Wire
	DefaultTitle = "Settings",
 }
local PANEL = {} -- It's our VGUI

-------------------------------
-- Handler part (Tab Handler)
-------------------------------

function TabHandler:Init() -- It's caled when editor is initalized, you can create library map there etc
end

function TabHandler:RegisterSettings() -- Setting panels should be registered there

end

function TabHandler:Cleanup() -- Called when editor is reloaded/removed
end

function TabHandler:OnThemeChange()
end

local EMPTY_FUNC = function() end
-----------------------
-- VGUI part (content)
-----------------------
function PANEL:Init() --That's init of VGUI like other PANEL:Methods(), separate for each tab

	local theme = SF.Editor.Themes.CurrentTheme
	local categories = SF.Editor.editor:GetSettings()

	--Background
	self:SetPaintBackground( true )
	self:SetBackgroundColor( theme.background )

	--Left Panel
	local leftMenu = vgui.Create("DListLayout",self)
	leftMenu:Dock(LEFT)
	leftMenu:SetWide(200)
	leftMenu:DockPadding(5,5,5,5)
	leftMenu:SetPaintBackground( true )
	leftMenu:SetBackgroundColor( theme.line_highlight )
	self.leftMenu = leftMenu

	--Tab Panel
	local tabPanel = vgui.Create("DListLayout",self)
	tabPanel:Dock(FILL)

	local function selectCat(cat)
		for name, data in pairs(categories) do
			data.panel:SetVisible(false)
			data.button.backgroundCol = nil
		end
		categories[cat].panel:SetVisible(true)
	end

	for name, data in SortedPairs(categories) do
		local data = categories[name] -- SortedPairs uses copy of the table
		local button = vgui.Create("StarfallButton")
		button.PerformLayout = EMPTY_FUNC
		button:SetSize(200,40)
		button:DockMargin(0,0,0,2)
		button:SetText(name)
		button:SetIcon(data.icon)
		button:SetToolTip(data.description)
		button.DoClick = function(self)
			selectCat(name)
			self.backgroundCol = SF.Editor.colors.med
		end

		data.button = button

		data.panel:SetParent(tabPanel)
		data.panel:Dock(FILL)
		data.panel:DockMargin(10,10,10,10)
		data.panel:SetVisible(false)

		leftMenu:Add(button)
	end
	selectCat(next(categories))
	leftMenu:PerformLayout()

end

function PANEL:OnThemeChange(theme)
	self:SetPaintBackground( true )
	self:SetBackgroundColor( theme.background )
	self.leftMenu:SetPaintBackground( true )
	self.leftMenu:SetBackgroundColor( theme.line_highlight )
end

function PANEL:OnFocusChanged(gained) -- When this tab is opened

end

function PANEL:Validate(movecarret) -- Validate request, has to return success,message

end

function PANEL:GetCode()
	return ""
end
--------------
-- We're done
--------------
vgui.Register(TabHandler.ControlName, PANEL, "DPanel") -- Registering VGUI element of handler
return TabHandler -- Our file has to return table of handler
