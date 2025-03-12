--[[
Modified version of Wire Editor, you can find original code and it's licence on link below.
https://github.com/wiremod/wire
File in use: https://github.com/wiremod/wire/blob/master/lua/wire/client/text_editor/sf_editor.lua
]]

if not Derma_StringRequestNoBlur then
	--Part of WireLib
	function Derma_StringRequestNoBlur(...)
		local f = math.max

		function math.max(...)
			local ret = f(...)

			for i = 1,20 do
				local name, value = debug.getlocal(2, i)
				if name == "Window" then
					value:SetBackgroundBlur( false )
					break
				end
			end

			return ret
		end
		local ok, ret = xpcall(Derma_StringRequest, debug.traceback, ...)
		math.max = f

		if not ok then error(ret, 0) end
		return ret
	end
end

local function Derma_QueryNoBlur(...)
	local f = math.max

	function math.max(...)
		local ret = f(...)

		for i = 1,20 do
			local name, value = debug.getlocal(2, i)
			if name == "Window" then
				value:SetBackgroundBlur( false )
				break
			end
		end

		return ret
	end
	local ok, ret = xpcall(Derma_Query, debug.traceback, ...)
	math.max = f

	if not ok then error(ret, 0) end
	return ret
end

local Editor = {}

local function GetTabHandler(name)
	if name then return SF.Editor.TabHandlers[name] end
	local handler = SF.Editor.TabHandlers[SF.Editor.CurrentTabHandler:GetString()]
	if not handler then
		local handlern
		for k, v in pairs(SF.Editor.TabHandlers) do if v.IsEditor then handlern, handler = k, v break end end
		if not handlern then error("No editors found!") end
		SF.Editor.CurrentTabHandler:SetString(handlern)
	end
	return handler
end
-- ----------------------------------------------------------------------
-- Fonts
-- they are shared for all tabhandlers
-- ----------------------------------------------------------------------
--ConVars
Editor.SaveTabsVar = CreateClientConVar("sf_editor_savetabs", "1", true, false)
Editor.NewTabOnOpenVar = CreateClientConVar("sf_editor_new_tab_on_open", "1", true, false)
Editor.OpenOldTabsVar = CreateClientConVar("sf_editor_openoldtabs", "1", true, false)
Editor.WorldClickerVar = CreateClientConVar("sf_editor_worldclicker", "0", true, false)
Editor.LayoutVar = CreateClientConVar("sf_editor_layout", "0", true, false)
Editor.StartHelperUndocked = CreateClientConVar("sf_helper_startundocked", "0", true, false)
Editor.EditorFileAutoReload = CreateClientConVar("sf_editor_file_auto_reload", "0", true, false, "Controls the auto reload functionality of Starfall's Editor")
Editor.EditorFileAutoReloadInterval = CreateClientConVar("sf_editor_file_auto_reload_interval", "1", true, false, "Controls the polling interval of the auto reload functionality of Starfall's Editor")

function SF.DefaultCode()
	if file.Exists("starfall/default.txt", "DATA") then
		return file.Read("starfall/default.txt", "DATA")
	elseif file.Exists("starfall/default.lua", "DATA") then
		return file.Read("starfall/default.lua", "DATA")
	else
		local code = [=[
--@name Untitled
--@author ]=] .. string.gsub(LocalPlayer():Nick(), "[^%w%s%p_]", "") ..[=[

--@shared

--[[
Starfall Scripting Environment

StarfallEx Addon: https://github.com/thegrb93/StarfallEx
Documentation: http://thegrb93.github.io/StarfallEx

This default code can be edited via the 'default.txt' file
]]
]=]
		code = string.gsub(code, "\r", "")
		file.Write("starfall/default.txt", code)
		return code
	end
end

cvars.AddChangeCallback("sf_editor_layout", function()
	RunConsoleCommand("sf_editor_restart")
end)

Editor.CreatedFonts = {}
local function createFont(name, fontName, size, antialiasing)
	local fontTable =
	{
		font = fontName,
		size = size,
		weight = 400,
		antialias = antialiasing,
		additive = false,
		italic = false,
		extended = true,
	}
	surface.CreateFont(name, fontTable)
	fontTable.weight = 800
	surface.CreateFont(name.."_Bold", fontTable)
	fontTable.weight = 400
	fontTable.italic = false--true
	surface.CreateFont(name.."_Italic", fontTable)

end
function Editor:GetFont(fontName, size, antialiasing)
	if not fontName or fontName == "" or not size then return end
	local name = "sf_" .. fontName .. "_" .. size .. "_" .. (antialiasing and 1 or 0)

	-- If font is not already created, create it.
	if not self.CreatedFonts[name] then
		self.CreatedFonts[name] = true
		createFont(name, fontName, size, antialiasing)
		timer.Simple(0, function() createFont(name, fontName, size, antialiasing) end) --Fix for bug explained there https://wiki.facepunch.com/gmod/surface.CreateFont
	end

	surface.SetFont(name)
	local width, height = surface.GetTextSize("_")
	return name, width, height
end


------------------------------------------------------------------------

local invalid_filename_chars = {
	["*"] = "",
	["?"] = "",
	[">"] = "",
	["<"] = "",
	["|"] = "",
	["\\"] = "",
	['"'] = "",
	[" "] = "_",
}

-- overwritten commands
function Editor:Init()
	-- don't use any of the default DFrame UI components
	for _, v in pairs(self:GetChildren()) do v:Remove() end
	self.Title = ""
	self.subTitle = ""
	self.LastClick = 0
	self.GuiClick = 0
	self.SimpleGUI = false
	self.Location = ""
	self.closePopups = {}
	self.reloadPopups = {}

	self.C = {}
	self.Components = {}

	-- Controls the auto reload functionality
	self.autoReloadEnabled = Editor.EditorFileAutoReload:GetBool()
	self.autoReloadInterval = Editor.EditorFileAutoReloadInterval:GetFloat()
	cvars.AddChangeCallback(Editor.EditorFileAutoReload:GetName(), function() self:setFileAutoReload(Editor.EditorFileAutoReload:GetBool()) end)
	cvars.AddChangeCallback(Editor.EditorFileAutoReloadInterval:GetName(), function() self:setFileAutoReloadInterval(Editor.EditorFileAutoReloadInterval:GetFloat()) end)


	-- Load border colors, position, & size
	self:LoadEditorSettings()

	local fontTable = {
		font = "default",
		size = 11,
		weight = 300,
		antialias = false,
		additive = false,
	}
	surface.CreateFont("E2SmallFont", fontTable)
	self.logo = surface.GetTextureID("radon/starfall2")

	self:InitComponents()

	-- This turns off the engine drawing
	self:SetPaintBackgroundEnabled(false)
	self:SetPaintBorderEnabled(false)

	self:SetV(false)

	self:InitShutdownHook()

	-- This should create the timers
	if self.EditorFileAutoReload then
		self:setFileAutoReload(true)
	end
end

local size = CreateClientConVar("sf_editor_size", "800_600", true, false)
local pos = CreateClientConVar("sf_editor_pos", "-1_-1", true, false)

function Editor:LoadEditorSettings()

	-- Position & Size
	local w, h = size:GetString():match("(%d+)_(%d+)")
	w = tonumber(w)
	h = tonumber(h)

	self:SetSize(w, h)

	local x, y = pos:GetString():match("(%-?%d+)_(%-?%d+)")
	x = tonumber(x)
	y = tonumber(y)

	if x == -1 and y == -1 then
		self:Center()
	else
		self:SetPos(x, y)
	end

	if x < 0 or y < 0 or x + w > ScrW() or y + h > ScrH() then -- If the editor is outside the screen, reset it
		local width, height = math.min(surface.ScreenWidth() - 200, 800), math.min(surface.ScreenHeight() - 200, 620)
		self:SetPos((surface.ScreenWidth() - width) / 2, (surface.ScreenHeight() - height) / 2)
		self:SetSize(width, height)

		self:SaveEditorSettings()
	end
end

function Editor:SaveEditorSettings()
	-- Position & Size
	if not self.fs then
		local w, h = self:GetSize()
		RunConsoleCommand("sf_editor_size", w .. "_" .. h)

		local x, y = self:GetPos()
		RunConsoleCommand("sf_editor_pos", x .. "_" .. y)
	end
end
function Editor:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, SF.Editor.colors.dark)
end
function Editor:PaintOver()
	local w, h = self:GetSize()

	surface.SetFont("SFTitle")
	surface.SetTextColor(255, 255, 255, 255)
	surface.SetTextPos(10, 6)
	surface.DrawText(self.Title .. self.subTitle)

	-- surface.SetTexture(self.logo)
	-- surface.SetDrawColor( 255, 255, 255, 128 )
	-- surface.DrawTexturedRect( w-148, h-158, 128, 128)

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetTextPos(0, 0)
	surface.SetFont("Default")
	return true
end

function Editor:PerformLayout()
	local w, h = self:GetSize()

	for i = 1, #self.Components do
		local c = self.Components[i]
		local c_x, c_y, c_w, c_h = c.Bounds.x, c.Bounds.y, c.Bounds.w, c.Bounds.h
		if (c_x < 0) then c_x = w + c_x end
		if (c_y < 0) then c_y = h + c_y end
		if (c_w < 0) then c_w = w + c_w - c_x end
		if (c_h < 0) then c_h = h + c_h - c_y end
		c:SetPos(c_x, c_y)
		c:SetSize(c_w, c_h)
	end
end

function Editor:OnMousePressed(mousecode)
	if mousecode ~= 107 then return end -- do nothing if mouseclick is other than left-click
	if not self.pressed then
		self.pressed = true
		self.p_x, self.p_y = self:GetPos()
		self.p_w, self.p_h = self:GetSize()
		self.p_mx = gui.MouseX()
		self.p_my = gui.MouseY()
		self.p_mode = self:GetMode()
		if self.p_mode == "drag" then
			if self.GuiClick > CurTime() - 0.4 then
				self:Fullscreen()
				self.pressed = false
				self.GuiClick = 0
			else
				self.GuiClick = CurTime()
			end
		end
	end
end

function Editor:OnMouseReleased(mousecode)
	if mousecode ~= 107 then return end -- do nothing if mouseclick is other than left-click
	self.pressed = false
end

function Editor:Think()
	if self.fs then return end
	if self.pressed then
		if not input.IsMouseDown(MOUSE_LEFT) then -- needs this if you let go of the mouse outside the panel
			self.pressed = false
		end
		local movedX = gui.MouseX() - self.p_mx
		local movedY = gui.MouseY() - self.p_my
		if self.p_mode == "drag" then
			local x = self.p_x + movedX
			local y = self.p_y + movedY
			if (x < 10 and x > -10) then x = 0 end
			if (y < 10 and y > -10) then y = 0 end
			if (x + self.p_w < surface.ScreenWidth() + 10 and x + self.p_w > surface.ScreenWidth() - 10) then x = surface.ScreenWidth() - self.p_w end
			if (y + self.p_h < surface.ScreenHeight() + 10 and y + self.p_h > surface.ScreenHeight() - 10) then y = surface.ScreenHeight() - self.p_h end
			self:SetPos(x, y)
		end
		if self.p_mode == "sizeBR" then
			local w = self.p_w + movedX
			local h = self.p_h + movedY
			if (self.p_x + w < surface.ScreenWidth() + 10 and self.p_x + w > surface.ScreenWidth() - 10) then w = surface.ScreenWidth() - self.p_x end
			if (self.p_y + h < surface.ScreenHeight() + 10 and self.p_y + h > surface.ScreenHeight() - 10) then h = surface.ScreenHeight() - self.p_y end
			if (w < 300) then w = 300 end
			if (h < 200) then h = 200 end
			self:SetSize(w, h)
		end
		if self.p_mode == "sizeR" then
			local w = self.p_w + movedX
			if (w < 300) then w = 300 end
			self:SetWide(w)
		end
		if self.p_mode == "sizeB" then
			local h = self.p_h + movedY
			if (h < 200) then h = 200 end
			self:SetTall(h)
		end
	end
	if not self.pressed then
		local cursor = "arrow"
		local mode = self:GetMode()
		if (mode == "sizeBR") then cursor = "sizenwse"
		elseif (mode == "sizeR") then cursor = "sizewe"
		elseif (mode == "sizeB") then cursor = "sizens"
		end
		if cursor ~= self.cursor then
			self.cursor = cursor
			self:SetCursor(self.cursor)
		end
	end

	local x, y = self:GetPos()
	local w, h = self:GetSize()

	if w < 518 then w = 518 end
	if h < 200 then h = 200 end
	if x < 0 then x = 0 end
	if y < 0 then y = 0 end
	if x + w > surface.ScreenWidth() then x = surface.ScreenWidth() - w end
	if y + h > surface.ScreenHeight() then y = surface.ScreenHeight() - h end
	if y < 0 then y = 0 end
	if x < 0 then x = 0 end
	if w > surface.ScreenWidth() then w = surface.ScreenWidth() end
	if h > surface.ScreenHeight() then h = surface.ScreenHeight() end

	self:SetPos(x, y)
	self:SetSize(w, h)
end

-- special functions

function Editor:Fullscreen()
	if self.fs then
		self:SetPos(self.preX, self.preY)
		self:SetSize(self.preW, self.preH)
		self.fs = false
	else
		self.preX, self.preY = self:GetPos()
		self.preW, self.preH = self:GetSize()
		self:SetPos(0, 0)
		self:SetSize(surface.ScreenWidth(), surface.ScreenHeight())
		self.fs = true
	end
end

function Editor:GetMode()
	local x, y = self:GetPos()
	local w, h = self:GetSize()
	local ix = gui.MouseX() - x
	local iy = gui.MouseY() - y

	if (ix < 0 or ix > w or iy < 0 or iy > h) then return end -- if the mouse is outside the box
	if (iy < 22) then
		return "drag"
	end
	if (iy > h - 10) then
		if (ix > w - 20) then return "sizeBR" end
		return "sizeB"
	end
	if (ix > w - 10) then
		if (iy > h - 20) then return "sizeBR" end
		return "sizeR"
	end
end

function Editor:AddComponent(panel, x, y, w, h)
	assert(not panel.Bounds)
	panel.Bounds = { x = x, y = y, w = w, h = h }
	self.Components[#self.Components + 1] = panel
	return panel
end

-- TODO: Fix this function
local function extractNameFromCode(str)
	return str:match("@name +([^\r\n]+)")
end

local function getPreferredTitles(Line, code)
	local title
	local tabtext

	local str = Line
	if str and str ~= "" then
		title = str
		tabtext = str
	end

	local str = extractNameFromCode(code)
	if str and str ~= "" then
		if not title then
			title = str
		end
		tabtext = str
	end

	return title, tabtext
end

function Editor:GetLastTab() return self.LastTab end

function Editor:SetLastTab(Tab) self.LastTab = Tab end

function Editor:GetActiveTab() return self.C.TabHolder:GetActiveTab() end

function Editor:GetNumTabs() return #self.C.TabHolder.Items end

function Editor:UpdateTabText(tab, title)
	-- Editor subtitle and tab text
	local ed = tab.content
	local _, text = getPreferredTitles(ed.chosenfile, ed.GetCode and ed:GetCode() or "")

	title = title or ed.DefaultTitle
	local tabtext = title or text
	tab:SetToolTip(ed.chosenfile)
	tabtext = tabtext or "Generic"
	if not ed:IsSaved() and tabtext:sub(-1) ~= "*" then
		tabtext = tabtext.." *"
	end

	if tab:GetText() ~= tabtext then
		tab:SetText(tabtext)
		self.C.TabHolder.tabScroller:InvalidateLayout()
	end
end
function Editor:SetActiveTab(val)
	if self:GetActiveTab() == val then
		self:RequestFocus()
		val:GetPanel():RequestFocus()
		return
	end
	self:SetLastTab(self:GetActiveTab())
	if isnumber(val) then
		self.C.TabHolder:SetActiveTab(self.C.TabHolder.Items[val].Tab)
		self:GetCurrentTabContent():RequestFocus()
	elseif val and val:IsValid() then
		self.C.TabHolder:SetActiveTab(val)
		val:GetPanel():RequestFocus()
	end
	self:Validate()

	-- Editor subtitle and tab text
	local title = getPreferredTitles(self:GetChosenFile(), self:GetCode())

	if title then self:SubTitle("Editing: " .. title) else self:SubTitle() end
	self:UpdateTabText(self:GetActiveTab())
end

function Editor:GetActiveTabIndex()
	local tab = self:GetActiveTab()
	for k, v in pairs(self.C.TabHolder.Items) do
		if tab == v.Tab then
			return k
		end
	end
	return -1
end

---Gets the index of the tab with the file at `filepath` opened
---@param filepath string The filepath of the tab to find
---@return number index # The index of the tab, if found
---@return boolean found # Boolean indicating if we found the tab
function Editor:GetTabIndexByFilePath(filepath)
	for i = 1, self:GetNumTabs() do
		if self:GetTabContent(i).chosenfile == filepath then
			return i, true
		end
	end
	return -1, false
end

function Editor:SetActiveTabIndex(index)
	if not self.C.TabHolder.Items[index] then return end
	local tab = self.C.TabHolder.Items[index].Tab

	if not tab then return end

	self:SetActiveTab(tab)
end

local function extractNameFromFilePath(str)
	local found = str:reverse():find("/", 1, true)
	if found then
		return str:Right(found - 1)
	else
		return str
	end
end

local old
function Editor:FixTabFadeTime()
	if old ~= nil then return end -- It's already being fixed
	local old = self.C.TabHolder:GetFadeTime()
	self.C.TabHolder:SetFadeTime(0)
	timer.Simple(old, function() self.C.TabHolder:SetFadeTime(old) old = nil end)
end

function Editor:CreateTab(chosenfile, forcedTabHandler)
	local th = GetTabHandler(forcedTabHandler)
	local content = vgui.Create(th.ControlName)
	content.parentpanel = self -- That's going to be Deprecated
	content.GetTabHandler = function() return th end -- add :GetTabHandler()
	content.IsSaved = function(self) return (not th.IsEditor) or self:GetCode() == self.savedCode or self:GetCode() == SF.DefaultCode() or self:GetCode() == "" end
	local sheet = self.C.TabHolder:AddSheet(extractNameFromFilePath(chosenfile), content)
	content.chosenfile = chosenfile
	sheet.Tab.content = content -- For easy access

	sheet.Tab.Paint = function(button, w, h)

		if button.Hovered then
			draw.RoundedBox(0, 0, 0, w-1, h, button.backgroundHoverCol or SF.Editor.colors.med)
		else
			draw.RoundedBox(0, 0, 0, w-1, h, button.backgroundCol or SF.Editor.colors.meddark)
		end

	end
	--sheet.Tab.UpdateColours = function() end
	sheet.Tab.GetTabHeight = function() return 20 end

	content.DefaultTitle = th.DefaultTitle
	content.UpdateTitle = function(_, text)
		return self:UpdateTabText(sheet.Tab, text)
	end
	content.CloseTab = function(_, text)
		return self:CloseTab(sheet.Tab, true)
	end
	local _old = sheet.Tab.OnMousePressed
	sheet.Tab.OnMousePressed = function(pnl, keycode, ...)
		if keycode == MOUSE_MIDDLE then
			--self:FixTabFadeTime()
			self:CloseTab(pnl)
			return
		elseif keycode == MOUSE_RIGHT then
			local menu = DermaMenu()
			menu:AddOption("Close", function()
					--self:FixTabFadeTime()
					self:CloseTab(pnl)
				end)
			menu:AddOption("Close all others", function()
					self:FixTabFadeTime()
					self:SetActiveTab(pnl)
					for i = self:GetNumTabs(), 1, -1 do
						if self.C.TabHolder.Items[i] ~= sheet then
							self:CloseTab(i)
						end
					end
				end)
			if th.IsEditor then
				menu:AddSpacer()
				menu:AddOption("Save", function()
						self:FixTabFadeTime()
						local old = self:GetLastTab()
						local active = self:GetActiveTab()
						self:SetActiveTab(pnl)
						self:SaveFile(self:GetChosenFile(), false, false, function(strTextOut)
							self:SetActiveTab(pnl)
							self:SaveFile(strTextOut, false, false)
							self:SetActiveTab(active)
							self:SetLastTab(old)
						end)
						self:SetActiveTab(active)
						self:SetLastTab(old)
					end)
				menu:AddOption("Save As", function()
						self:FixTabFadeTime()
						local old = self:GetLastTab()
						local active = self:GetActiveTab()
						self:SaveFile(self:GetChosenFile(), false, true, function(strTextOut)
							self:SetActiveTab(pnl)
							self:SaveFile(strTextOut, false, false)
							self:SetActiveTab(active)
							self:SetLastTab(old)
						end)
					end)
				menu:AddOption("Reload", function()
						self:FixTabFadeTime()
						local old = self:GetLastTab()
						local active = self:GetActiveTab()
						self:SetActiveTab(pnl)
						self:LoadFile(content.chosenfile, false)
						self:SetActiveTab(active)
						self:SetLastTab(old)
					end)
				menu:AddSpacer()
				menu:AddOption("Copy file path to clipboard", function()
						if content.chosenfile and content.chosenfile ~= "" then
							SetClipboardText(content.chosenfile)
						end
					end)
				menu:AddOption("Copy all file paths to clipboard", function()
						local str = ""
						for i = 1, self:GetNumTabs() do
							local chosenfile = self:GetTabContent(i).chosenfile
							if chosenfile and chosenfile ~= "" then
								str = str .. chosenfile .. ";"
							end
						end
						str = str:sub(1, -2)
						SetClipboardText(str)
					end)
			end
			menu:Open()
			menu:AddSpacer()
			if th.RegisterTabMenu then
				th:RegisterTabMenu(menu, content)
			end
			return
		end
		_old(pnl, keycode, ...)

		self:SetActiveTab(pnl)
	end
	if content.GetTabHandler().IsEditor then
		content.OnTextChanged = function()
			self:UpdateTabText(sheet.Tab)
		end
		content.OnShortcut = function(_, code, shift)
			if code == KEY_S then
				self:SaveFile(self:GetChosenFile(), false, shift)
				self:Validate()
			end
		end
	end
	content:RequestFocus()

	self:OnTabCreated(sheet) -- Call a function that you can override to do custom stuff to each tab.

	return sheet
end

function Editor:OnTabCreated(sheet) end

-- This function is made to be overwritten

function Editor:GetNextAvailableTab()
	local activetab = self:GetActiveTab()
	for k, v in pairs(self.C.TabHolder.Items) do
		if v.Tab and v.Tab:IsValid() and v.Tab ~= activetab then
			return v.Tab
		end
	end
end

function Editor:NewTab()
	local sheet = self:CreateTab("Generic")
	self:SetActiveTab(sheet.Tab)
	self:NewScript(true)
end

function Editor:CloseTab(_tab,dontask)
	local activetab, sheetindex
	if _tab then
		if isnumber(_tab) then
			local temp = self.C.TabHolder.Items[_tab]
			if temp then
				activetab = temp.Tab
				sheetindex = _tab
			else
				return
			end
		else
			activetab = _tab
			-- Find the sheet index
			for k, v in pairs(self.C.TabHolder.Items) do
				if activetab == v.Tab then
					sheetindex = k
					break
				end
			end
		end
	else
		activetab = self:GetActiveTab()
		-- Find the sheet index
		for k, v in pairs(self.C.TabHolder.Items) do
			if activetab == v.Tab then
				sheetindex = k
				break
			end
		end
	end

	if not IsValid(activetab) then return end

	local ed = activetab:GetPanel()
	if not ed:IsSaved() and not dontask and not ed.IsOnline then

		local popup = self.closePopups[activetab]
		if not IsValid(popup) then
			local newPopup = SF.Editor.Query("Unsaved changes!", string.format("Do you want to close <color=255,30,30>%q</color> ?", activetab:GetText()), "Close", function()
				self:CloseTab(activetab, true)
				self.closePopups[activetab] = nil
			end, "Cancel", function()
				self.closePopups[activetab] = nil
			end)
			self.closePopups[activetab] = newPopup
		end

		if IsValid(popup) then
			popup:Center()
			popup:MakePopup()
		end

		return
	end

	self:SaveTabs()

	-- Find the panel (for the scroller)
	local tabscroller_sheetindex
	for k, v in pairs(self.C.TabHolder.tabScroller.Panels) do
		if v == activetab then
			tabscroller_sheetindex = k
			break
		end
	end

	self:FixTabFadeTime()

	if activetab == self:GetActiveTab() then -- We're about to close the current tab
		if self:GetLastTab() and self:GetLastTab():IsValid() then -- If the previous tab was saved
			if activetab == self:GetLastTab() then -- If the previous tab is equal to the current tab
				local othertab = self:GetNextAvailableTab() -- Find another tab
				if othertab and othertab:IsValid() then -- If that other tab is valid, use it
					self:SetActiveTab(othertab)
					self:SetLastTab()
				else -- Reset the current tab (backup)
					self:NewTab()
				end
			else -- Change to the previous tab
				self:SetActiveTab(self:GetLastTab())
				self:SetLastTab()
			end
		else -- If the previous tab wasn't saved
			local othertab = self:GetNextAvailableTab() -- Find another tab
			if othertab and othertab:IsValid() then -- If that other tab is valid, use it
				self:SetActiveTab(othertab)
			else -- Reset the current tab (backup)
				self.C.TabHolder:InvalidateLayout()
				self:NewTab()
			end
		end
	end

	self:OnTabClosed(activetab) -- Call a function that you can override to do custom stuff to each tab.

	activetab:GetPanel():Remove()
	activetab:Remove()
	table.remove(self.C.TabHolder.Items, sheetindex)
	table.remove(self.C.TabHolder.tabScroller.Panels, tabscroller_sheetindex)

	self.C.TabHolder.tabScroller:InvalidateLayout()
	local w, h = self.C.TabHolder:GetSize()
	self.C.TabHolder:SetSize(w + 1, h) -- +1 so it updates
end

function Editor:OnTabClosed(sheet) end

-- This function is made to be overwritten

-- initialization commands
function Editor:InitComponents()
	self.Components = {}
	self.C = {}

	local function PaintFlatButton(panel, w, h)
		if not (panel:IsHovered() or panel:IsDown()) then return end
		derma.SkinHook("Paint", "Button", panel, w, h)
	end

	local DMenuButton = vgui.RegisterTable({
			Init = function(panel)
				panel:SetText("")
				panel:SetSize(24, 20)
				panel:Dock(LEFT)
			end,
			Paint = PaintFlatButton,
			DoClick = function(panel)
				local name = panel:GetName()
				local f = name and name ~= "" and self[name] or nil
				if f then f(self) end
			end
		}, "DButton")

	self.C.ButtonHolder = self:AddComponent(vgui.Create("DPanel", self), -400-4, 4, 400, 22) -- Upper menu
	self.C.ButtonHolder.Paint = function() end
	-- AddComponent( panel, x, y, w, h )
	-- if x, y, w, h is minus, it will stay relative to right or buttom border
	self.C.Close = vgui.Create("StarfallButton", self.C.ButtonHolder) -- Close button
	-- self.C.Inf = self:AddComponent(vgui.CreateFromTable(DMenuButton, self), -45-4-26, 0, 24, 22) -- Info button
	-- self.C.ConBut = self:AddComponent(vgui.CreateFromTable(DMenuButton, self), -45-4-24-26, 0, 24, 22) -- Control panel open/close

	self.C.Divider = vgui.Create("DHorizontalDivider", self)

	self.C.Browser = vgui.Create("StarfallFileBrowser", self.C.Divider)
	self.C.Browser:Dock(NODOCK)

	self.C.MainPane = vgui.Create("DPanel", self.C.Divider)
	self.C.Menu = vgui.Create("DPanel", self.C.MainPane)
	self.C.Val = vgui.Create("Button", self.C.MainPane) -- Validation line
	self.C.TabHolder = vgui.Create("DPropertySheet", self.C.MainPane)
	self.C.TabHolder.tabScroller:MakeDroppable( "sf_tab" )
	self.C.TabHolder.tabScroller:SetUseLiveDrag( true )

	self.C.TabHolder.Paint = DoNothing

	self.C.Btoggle = vgui.CreateFromTable(DMenuButton, self.C.Menu) -- Toggle Browser being shown
	self.C.Sav = vgui.CreateFromTable(DMenuButton, self.C.Menu) -- Save button
	self.C.SavAs = vgui.CreateFromTable(DMenuButton, self.C.Menu) -- Save button
	self.C.NewTab = vgui.CreateFromTable(DMenuButton, self.C.Menu, "NewTab") -- New tab button
	self.C.CloseTab = vgui.CreateFromTable(DMenuButton, self.C.Menu, "CloseTab") -- Close tab button
	self.C.Reload = vgui.CreateFromTable(DMenuButton, self.C.Menu) -- Reload tab button

	self.C.Inf = vgui.CreateFromTable(DMenuButton, self.C.Menu) -- Info button
	self.C.ConBut = vgui.CreateFromTable(DMenuButton, self.C.Menu) -- Control panel button

	self.C.Credit = self:AddComponent(vgui.Create("DTextEntry", self), -160, 52, 150, 200) -- Credit box

	-- extra component options
	if Editor.LayoutVar:GetInt() == 1 then -- Browser on right
		self.C.Divider:SetRight(self.C.Browser)
		self.C.Divider:SetLeft(self.C.MainPane)
	else --Browser on left(Default)
		self.C.Divider:SetLeft(self.C.Browser)
		self.C.Divider:SetRight(self.C.MainPane)
	end
	self.C.Divider:Dock(FILL)
	self.C.Divider:SetDividerWidth(4)
	self.C.Divider:SetCookieName("sf_editor_divider")
	self.C.Divider:SetLeftMin(0)

	local DoNothing = function() end
	self.C.MainPane.Paint = DoNothing
	--self.C.Menu.Paint = DoNothing

	self.C.Menu:Dock(TOP)
	self.C.TabHolder:Dock(FILL)
	self.C.TabHolder.tabScroller:DockMargin(0, 0, 3, 0) -- We dont want default offset
	self.C.TabHolder.tabScroller:SetOverlap(-1)
	self.C.TabHolder:SetPadding(0)
	self.C.Menu.Paint = function(_, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(234, 234, 234))
	end
	self.C.TabHolder.tabScroller:SetPaintBackgroundEnabled(false)
	self.C.TabHolder:SetPaintBackgroundEnabled(false)

	self.C.Val:Dock(BOTTOM)

	self.C.Menu:SetHeight(24)
	self.C.Menu:DockPadding(2, 2, 2, 2)
	self.C.Val:SetHeight(22)

	self.C.Close:SetText("Close")
	self.C.Close:DockMargin(10, 0, 0, 0)
	self.C.Close:Dock(RIGHT)
	self.C.Close.DoClick = function(btn) self:Close() end

	self.C.ConBut:SetImage("icon16/cog.png")
	self.C.ConBut:Dock(RIGHT)
	self.C.ConBut:SetText("")
	self.C.ConBut.Paint = PaintFlatButton
	self.C.ConBut.DoClick = function()
		self:OpenTabOnlyOnce("settings")
	end

	self.C.Inf:SetImage("icon16/information.png")
	self.C.Inf:Dock(RIGHT)
	self.C.Inf.Paint = PaintFlatButton
	self.CreditCount = 0
	self.C.Inf.DoClick = function(btn)
		self.C.Credit:SetVisible(not self.C.Credit:IsVisible())
		self.CreditCount = self.CreditCount + 1

		if self.CreditCount == 6 then

		http.Fetch( "https://api.github.com/repos/thegrb93/StarfallEx/contributors",
			function( body, len, headers, code )
				local data = util.JSONToTable(body)

				local awesomePeople = "List of awesome people that contributed to StarfallEx:\n";
				for k,v in ipairs(data) do
					if v.login ~= "web-flow" then
						awesomePeople = awesomePeople .. "\n" .. v.login
					end
				end
				awesomePeople = awesomePeople .. "\n \nThanks!"
				SF.Editor.openWithCode("Awesome people!", awesomePeople)

			end,
			function( error )
			end
		 )

		end

	end

	self.C.Sav:SetImage("icon16/disk.png")
	self.C.Sav.DoClick = function(button) self:SaveFile(self:GetChosenFile()) end
	self.C.Sav:SetToolTip("Save")

	self.C.SavAs:SetImage("icon16/disk_multiple.png")
	self.C.SavAs:SetToolTip("Save As")
	self.C.SavAs.DoClick = function(button) self:SaveFile(self:GetChosenFile(), false, true) end

	self.C.NewTab:SetImage("icon16/page_white_add.png")
	self.C.NewTab.DoClick = function(button) self:NewTab() end
	self.C.NewTab:SetToolTip("New tab")

	self.C.CloseTab:SetImage("icon16/page_white_delete.png")
	self.C.CloseTab.DoClick = function(button)
		self:CloseTab()
	end
	self.C.CloseTab:SetToolTip("Close tab")

	self.C.Reload:SetImage("icon16/page_refresh.png")
	self.C.Reload:SetToolTip("Refresh file")
	self.C.Reload.DoClick = function(button)
		self:ReloadFile(self:GetChosenFile(), true)
	end

	self.C.Browser.tree.OnNodeSelected = function(tree, node)
		if node.FileURL then
			SF.AddNotify(LocalPlayer(), "Downloading example..", "GENERIC" , 4, "DRIP2")
			http.Fetch( node.FileURL,
				function( body, len, headers, code )
					self:Open(node:GetText(), body, false)
					self:GetActiveTab():GetPanel().IsOnline = true
				end,
				function(err)
						SF.AddNotify(LocalPlayer(), "There was a problem in downloading example.", "ERROR", 7, "ERROR1")
				end)
		end
		if not node:GetFileName() or not (string.GetExtensionFromFilename(node:GetFileName()) == "txt" or string.GetExtensionFromFilename(node:GetFileName()) == "lua") then return end
		self:Open(node:GetFileName(), nil, false)
	end

	self.C.Val:SetText(" Click to validate...")
	self.C.Val.UpdateColours = function(button, skin)
		return button:SetTextStyleColor(skin.Colours.Button.Down)
	end
	self.C.Val.SetBGColor = function(button, r, g, b, a)
		self.C.Val.bgcolor = Color(r, g, b, a)
	end
	self.C.Val.bgcolor = Color(255, 255, 255)
	self.C.Val.Paint = function(button)
		local w, h = button:GetSize()
		draw.RoundedBox(1, 0, 0, w, h, button.bgcolor)
		if button.Hovered then draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(0, 0, 0, 128)) end
	end
	self.C.Val.OnMousePressed = function(panel, btn)
		if btn == MOUSE_RIGHT then
			local menu = DermaMenu()
			menu:AddOption("Copy to clipboard", function()
					SetClipboardText(self.C.Val:GetValue():sub(4))
				end)
			menu:Open()
		else
			self:Validate(true)
		end
	end
	self.C.Btoggle:SetImage("icon16/application_side_contract.png")
	function self.C.Btoggle.DoClick(button)
		if button.hide then
			self.C.Divider:LoadCookies()
		else
			self.C.Divider:SetLeftWidth(0)
		end
		self.C.Divider:InvalidateLayout()
		button:InvalidateLayout()
	end

	local oldBtoggleLayout = self.C.Btoggle.PerformLayout
	function self.C.Btoggle.PerformLayout(button)
		oldBtoggleLayout(button)
		if self.C.Divider:GetLeftWidth() > 0 then
			button.hide = false
			button:SetImage("icon16/application_side_contract.png")
		else
			button.hide = true
			button:SetImage("icon16/application_side_expand.png")
		end
	end

	self.C.Credit:SetTextColor(Color(0, 0, 0, 255))
	self.C.Credit:SetText("\t\tCREDITS\n\n\tEditor by: \tSyranide and Shandolum\n\n\tTabs (and more) added by Divran.\n\n\tFixed for GMod13 By Ninja101\n\n\tModified for starfall by D.ツ") -- Sure why not ;)
	self.C.Credit:SetMultiline(true)
	self.C.Credit:SetVisible(false)
	self.C.Credit:SetEditable(false)
end

function Editor:GetSettings()

	local categories = {}
	local function AddCategory(panel, name, icon, description)
		if not name then return end
		categories[name] = {
			panel = panel,
			icon = icon,
			description = description
		}
	end
	-- ------------------------------------------- EDITOR TAB
	-- WINDOW BORDER COLORS
	local label
	local dlist = vgui.Create("DPanelList")
	dlist.Paint = function() end
	dlist:EnableVerticalScrollbar(true)

	label = vgui.Create("DLabel")
	dlist:AddItem(label)
	label:SetText("Current Editor:")
	label:SizeToContents()

	local box = vgui.Create("DComboBox")
	dlist:AddItem(box)
	box:SetValue(SF.Editor.CurrentTabHandler:GetString())
	box.OnSelect = function (self, index, value, data)
		value = value:gsub(" %b()", "") -- Remove description
		RunConsoleCommand("sf_editor_tab_editor", value)
		RunConsoleCommand("sf_editor_restart")
	end

	for k, v in pairs(SF.Editor.TabHandlers) do
		if v.IsEditor then
			local description = v.Description and " ( "..v.Description.." )" or "Addon"
			box:AddChoice(k..description)
		end
	end


	label = vgui.Create("DLabel")
	dlist:AddItem(label)
	label:SetText("\nOther settings:")
	label:SizeToContents()

	local NewTabOnOpen = vgui.Create("DCheckBoxLabel")
	dlist:AddItem(NewTabOnOpen)
	NewTabOnOpen:SetConVar("sf_editor_new_tab_on_open")
	NewTabOnOpen:SetText("New tab on open")
	NewTabOnOpen:SizeToContents()
	NewTabOnOpen:SetTooltip("Enable/disable loaded files opening in a new tab.\nIf disabled, loaded files will be opened in the current tab.")

	local SaveTabsOnClose = vgui.Create("DCheckBoxLabel")
	dlist:AddItem(SaveTabsOnClose)
	SaveTabsOnClose:SetConVar("sf_editor_savetabs")
	SaveTabsOnClose:SetText("Save tabs on close")
	SaveTabsOnClose:SizeToContents()
	SaveTabsOnClose:SetTooltip("Save the currently opened tab file paths on shutdown.\nOnly saves tabs whose files are saved.")

	local OpenOldTabs = vgui.Create("DCheckBoxLabel")
	dlist:AddItem(OpenOldTabs)
	OpenOldTabs:SetConVar("sf_editor_openoldtabs")
	OpenOldTabs:SetText("Open old tabs on load")
	OpenOldTabs:SizeToContents()
	OpenOldTabs:SetTooltip("Open the tabs from the last session on load.\nOnly tabs whose files were saved before disconnecting from the server are stored.")

	local WorldClicker = vgui.Create("DCheckBoxLabel")
	dlist:AddItem(WorldClicker)
	WorldClicker:SetConVar("sf_editor_worldclicker")
	WorldClicker:SetText("Enable Clicking Outside Editor")
	WorldClicker:SizeToContents()
	function WorldClicker.OnChange(pnl, bVal)
		self:GetParent():SetWorldClicker(bVal)
	end

	local UndockHelper = vgui.Create("DCheckBoxLabel")
	dlist:AddItem(UndockHelper)
	UndockHelper:SetConVar("sf_helper_startundocked")
	UndockHelper:SetText("Undock helper on open")
	UndockHelper:SizeToContents()

	local EditorFileAutoReloadCheckbox = vgui.Create("DCheckBoxLabel")
	dlist:AddItem(EditorFileAutoReloadCheckbox)
	EditorFileAutoReloadCheckbox:SetConVar(Editor.EditorFileAutoReload:GetName())
	EditorFileAutoReloadCheckbox:SetText("Auto reload files")
	EditorFileAutoReloadCheckbox:SizeToContents()

	AddCategory(dlist, "Editor", "icon16/application_side_tree.png", "Options for the editor itself.")

	------ Client Permissions panel
	local perms = SF.Editor.createGlobalPermissionsPanel(true, false)
	AddCategory(perms, "Permissions [Client]", "icon16/tick.png", "Permission settings.")

	------ Server Permissions panel
	if LocalPlayer():IsSuperAdmin() then
		local perms = SF.Editor.createGlobalPermissionsPanel(false, true)
		AddCategory(perms, "Permissions [Server]", "icon16/tick.png", "Permission settings.")
	end
	------ Themes panel
	local themesPanel = self:CreateThemesPanel()
	themesPanel:Refresh()


	AddCategory(themesPanel, "Themes", "icon16/page_white_paintbrush.png", "Theme settings.")

	----- Tab settings
	for k, v in pairs(SF.Editor.TabHandlers) do -- We let TabHandlers register their settings but only if they are current editor or arent editor at all
		if v.RegisterSettings and (not v.IsEditor or (v.IsEditor and SF.Editor.CurrentTabHandler:GetString() == k)) then
			AddCategory(v:RegisterSettings())
		end
	end

	return categories
end

function Editor:CreateThemesPanel()
	-- Main panel list

	local panel = vgui.Create("DPanelList")
	panel:Dock(FILL)
	panel:DockMargin(4, 8, 4, 4)
	panel.Paint = function() end

	-- Themes label

	local label = vgui.Create("DLabel")
	panel:AddItem(label)
	label:DockMargin(0, 0, 0, 0)
	label:SetText("Starfall editor supports TextMate themes.\n" ..
		"You can import them by pressing \"Add\" button.\n")
	label:SetWrap(true)

	-- Theme list

	local themeList = vgui.Create("DListView")
	panel:AddItem(themeList)
	themeList:SetMultiSelect(false)
	themeList:AddColumn("Theme")
	themeList:AddColumn("")
	themeList:SetHeight(300)

	function themeList:Populate()
		themeList:Clear()

		local curTheme = SF.Editor.Themes.ThemeConVar:GetString()

		for k, v in pairs(SF.Editor.Themes.Themes) do
			local rowPanel = themeList:AddLine(v.Name, v.Version == SF.Editor.Themes.Version and "" or "Not compatible!")
			rowPanel.theme = k

			if k == curTheme then
				themeList:SelectItem(rowPanel)
			end
		end

		function themeList:OnRowSelected(index, rowPanel)
			SF.Editor.Themes.SwitchTheme(rowPanel.theme)
		end
	end

	themeList:Populate()

	-- Button dock panel

	local btnPanel = vgui.Create("EditablePanel")
	panel:AddItem(btnPanel)
	btnPanel:SetHeight(24)

	-- Add button

	local addBtn = btnPanel:Add("StarfallButton")
	addBtn:SetText("Add")
	addBtn:Dock(LEFT)
	addBtn:DockMargin(0, 2, 2, 2)
	function addBtn:DoClick()
		local menu = DermaMenu()

		menu:AddOption("From URL", function()
			Derma_StringRequestNoBlur("Load theme from URL", "Paste the URL to a TextMate theme to the text box",
				"", function(text)
				http.Fetch(text, function(body)
					local parsed, strId, error = SF.Editor.Themes.ParseTextMate(body)

					if not parsed then
						Derma_Message("A problem occured during parsing the XML file: " .. error, "SF Themes", "Close")
						return
					end

					print("Added theme with id " .. strId) -- DEBUG

					SF.Editor.Themes.AddTheme(strId, parsed)

					themeList:Populate()
				end, function(err)
					Derma_Message("Downloading the theme failed! Error: " .. err, "SF Themes", "Close")
				end)
			end)
		end)

		menu:AddOption("From text", function()
			local window = Derma_StringRequestNoBlur("Load theme from text", "Paste the contents of a TextMate theme file below",
				"", function(text)
				local parsed, strId, error = SF.Editor.Themes.ParseTextMate(text)

				if not parsed then
					Derma_Message("A problem occured during parsing the XML file: " .. error, "SF Themes", "Close")
					return
				end

				print("Added theme with id " .. strId) -- DEBUG

				SF.Editor.Themes.AddTheme(strId, parsed)

				themeList:Populate()
			end)

			-- Enable text entry multiline and resize with a hacky method,
			-- because why design a new derma panel just for this?
			for k1, v1 in pairs(window:GetChildren()) do
				for k2, v2 in pairs(v1:GetChildren()) do
					if v2:GetName() == "DTextEntry" then
						v2:SetMultiline(true)
						v2:SetHeight(30)
						break
					end
				end
			end
		end)

		menu:Open()
	end

	-- Remove button

	local removeBtn = btnPanel:Add("StarfallButton")
	removeBtn:SetText("Remove")
	removeBtn:Dock(FILL)
	removeBtn:DockMargin(0, 2, 2, 2)
	function removeBtn:DoClick()
		local lineId = themeList:GetSelectedLine()

		if not lineId then
			return
		end

		local rowPanel = themeList:GetLine(lineId)

		if rowPanel.theme == "default" then
			Derma_Message("You can't remove the default theme!", "SF Themes", "Close")
			return
		end

		SF.Editor.Themes.RemoveTheme(rowPanel.theme)

		themeList:Populate()
	end

	function btnPanel:PerformLayout()
		label:SizeToContents()
		addBtn:SetWidth(btnPanel:GetWide() / 2)
	end

	local label = vgui.Create("DLabel")
	panel:AddItem(label)
	label:DockMargin(0, 0, 0, 0)
	label:SetFont("SFTitle")
	label:SetColor(Color(255,32,32))
	label:SetText("If your theme doesn't work or looks different than it should you can report it by clicking on this text.")
	label:SetWrap(true)
	label.DoClick = function()
		gui.OpenURL( "https://github.com/thegrb93/StarfallEx/issues/307" )
	end
	return panel
end

-- used with color-circles
function Editor:TranslateValues(panel, x, y)
	x = x - 0.5
	y = y - 0.5
	local angle = math.atan2(x, y)
	local length = math.sqrt(x * x + y * y)
	length = math.Clamp(length, 0, 0.5)
	x = 0.5 + math.sin(angle) * length
	y = 0.5 + math.cos(angle) * length
	panel:SetHue(math.deg(angle) + 270)
	panel:SetSaturation(length * 2)
	panel:SetRGB(HSVToColor(panel:GetHue(), panel:GetSaturation(), 1))
	panel:SetFrameColor()
	return x, y
end

function Editor:NewScript(incurrent)
	if not incurrent and self.NewTabOnOpenVar:GetBool() then
		self:NewTab()
	else
		self:SaveTabs()
		self:ChosenFile()
		-- Set title
		self:GetActiveTab():SetText("Generic")
		self.C.TabHolder:InvalidateLayout()

		self:SetCode(SF.DefaultCode())
		self:GetCurrentTabContent().savedCode = self:GetCurrentTabContent():GetCode() -- It may return different line endings etc
	end
end

function Editor:InitShutdownHook()
	-- save code when shutting down
	hook.Add("ShutDown", "sf_editor_shutdown", function()
			if Editor.SaveTabsVar:GetBool() then
				self:SaveTabs()
			end
		end)
end

function Editor:SaveTabs()
	if not SF.Editor.initialized or not SF.Editor.editor then return end
	if not self.TabsLoaded then return end
	local tabs = {}
	local activeTab = self:GetActiveTabIndex()
	tabs.selectedTab = activeTab
	for i = 1, self:GetNumTabs() do
		local tabContent = SF.Editor.editor.C.TabHolder.tabScroller.Panels[i]:GetPanel()
		if not tabContent:GetTabHandler().IsEditor then
			if tabs.selectedTab == i then
				tabs.selectedTab = 1
			end
			continue
		end
		tabs[i] = {}
		local filename = tabContent.chosenfile
		local filedatapath = "sf_filedata/"
		if filename then
			if filename:sub(1, #filedatapath) == filedatapath then -- Temporary fix before we update sf_tabs.txt format
				filename = nil
			else
				filename =  filename:sub(#self.Location + 2)
			end
		end
		tabs[i].filename = filename
		tabs[i].code = tabContent:GetCode()
	end

	file.Write("sf_tabs.txt", util.TableToJSON(tabs))
end

function Editor:OpenOldTabs()
	if not file.Exists("sf_tabs.txt", "DATA") then 	self.TabsLoaded = true; return end

	local tabs = util.JSONToTable(file.Read("sf_tabs.txt") or "")
	if not tabs or #tabs == 0 then self.TabsLoaded = true; return end

	-- Temporarily remove fade time
	self:FixTabFadeTime()

	local is_first = true
	for k, v in pairs(tabs) do
		if not istable(v) then continue end
		if v.filename then v.filename = "starfall/"..v.filename end
		if is_first then -- Remove initial tab
			timer.Simple(0, function()
				self:CloseTab(1, true)
				self:SetActiveTabIndex(tabs.selectedTab or 1)
			end)
			is_first = false
		end
		self:NewTab()
		self:ChosenFile(v.filename)
		self:SetCode(v.code)
		self:UpdateTabText(self:GetActiveTab())
		self.C.TabHolder:InvalidateLayout()

	end
	self.TabsLoaded = true

end

function Editor:Validate(gotoerror)
	if not self:GetCurrentTabContent():GetTabHandler().IsEditor then --Dont validate for non-editors
		self:SetValidatorStatus("")
		return
	end

	local code = self:GetCode()
	if #code < 1 then return true end -- We wont validate empty scripts
	local err = SF.CompileString(code , "Validation", false)
	local success = not isstring(err)
	local row, message
	if success then
		self:SetValidatorStatus("Validation successful!", 0, 110, 20, 255)
	else
		row = tonumber(err:match("%d+")) or 0
		message = err:match(": .+$")
		message = message and message:sub(3) or "Unknown"
		message = "Line "..row..":"..message
		self.C.Val:SetBGColor(110, 0, 20, 255)
		self.C.Val:SetText(" " .. message)
	end

	if self:GetCurrentTabContent().OnValidate then
		self:GetCurrentTabContent():OnValidate(success, row, message, gotoerror)
	end
	return true
end

function Editor:SetValidatorStatus(text, r, g, b, a)
	self.C.Val:SetBGColor(r or 0, g or 180, b or 0, a or 180)
	self.C.Val:SetText(" " .. text)
end

function Editor:SubTitle(sub)
	if not sub then self.subTitle = ""
	else self.subTitle = " - " .. sub
	end
end

function Editor:SetV(bool)
	if bool then
		self:MakePopup()
		self:InvalidateLayout(true)
	end
	self:SetVisible(bool)
	self:SetKeyBoardInputEnabled(bool)
	self:GetParent():SetWorldClicker(Editor.WorldClickerVar:GetBool() and bool) -- Enable this on the background so we can update E2's without closing the editor
end

function Editor:GetChosenFile()
	return self:GetCurrentTabContent().chosenfile
end

function Editor:ChosenFile(Line, code)
	self:GetCurrentTabContent().chosenfile = Line
	if not code then
		code = Line and file.Read(Line)
		if code then
			code = SF.Editor.normalizeCode(code)
		end
	end
	self:GetCurrentTabContent().savedCode = code

	if Line then
		self:SubTitle("Editing: " .. Line)
	else
		self:SubTitle()
	end
end

function Editor:OnThemeChange(theme)
	for i = 1, self:GetNumTabs() do
		local ed = self:GetTabContent(i)
		if ed.OnThemeChange then
			ed:OnThemeChange(theme)
		end
	end
end

--Opens tab with specified tabhandler, if it already exists sets it to active instead
function Editor:OpenTabOnlyOnce(name)
	local tab = nil
	for i = 1, self:GetNumTabs() do
		local ed = self:GetTabContent(i)
		if ed:GetTabHandler() == GetTabHandler(name) then
			tab = i
		end
	end
	if tab then
		self:SetActiveTabIndex(tab)
	else
		local sheet = self:CreateTab("", name)
		self:SetActiveTab(sheet.Tab)
	end
	return self:GetActiveTab()
end

function Editor:FindOpenFile(FilePath)
	for i = 1, self:GetNumTabs() do
		local ed = self:GetTabContent(i)
		if ed.chosenfile == FilePath then
			return ed
		end
	end
end

function Editor:ExtractName()
	local code = self:GetCode()
	local name = extractNameFromCode(code)
	if name and name ~= "" then
		self.savefilefn = name
	else
		self.savefilefn = "filename"
	end
end

function Editor:SetCode(code)
	self:GetCurrentTabContent():SetCode(code)
	self:Validate()
	self:ExtractName()
end

function Editor:PasteCode(code)
	local content = self:GetCurrentTabContent()
	if not content:GetTabHandler().IsEditor or not content.PasteCode then return end
	content:PasteCode(code)
end

function Editor:GetTabContent(n)
	if self.C.TabHolder.Items[n] then
		return self.C.TabHolder.Items[n].Panel
	end
end

---Returns the associated `DTab` for the tab at index `n`
---@param n number Tab index
---@return DTab # DTab of the associated tab
---https://wiki.facepunch.com/gmod/DPropertySheet:GetItems
function Editor:GetTab(n)
	if self.C.TabHolder.Items[n] then
		return self.C.TabHolder.Items[n].Tab
	end
end

function Editor:GetCurrentTabContent()
	return self:GetActiveTab():GetPanel()
end

function Editor:GetCode()
	if self:GetCurrentTabContent().GetCode then
		return self:GetCurrentTabContent():GetCode() or ""
	else
		return ""
	end
end

function Editor:Open(Line, code, forcenewtab, checkFileExists)
	timer.Create("sfautosave", 5, 0, function()
		self:SaveTabs()
	end)
	if self:IsVisible() and not Line and not code then self:Close() end
	self:SetV(true)
	if code then
		if not forcenewtab then
			local normalizedCode = SF.Editor.normalizeCode(code)
			for i = 1, self:GetNumTabs() do
				if self:GetTabContent(i):GetCode() == normalizedCode then
					self:SetActiveTab(i)
					return
				end
			end
			if checkFileExists and file.Exists("starfall/" .. Line, "DATA") and file.Read("starfall/" .. Line, "DATA")==code then
				return
			end
		end
		local title, tabtext = getPreferredTitles(Line, code)
		local tab
		if self.NewTabOnOpenVar:GetBool() or forcenewtab then
			tab = self:CreateTab(tabtext).Tab
		else
			tab = self:GetActiveTab()
			self:UpdateTabText(tab)
			self.C.TabHolder:InvalidateLayout()
		end
		self:SetActiveTab(tab)

		self:ChosenFile()
		self:SetCode(code)
		if Line then self:SubTitle("Editing: " .. Line) end
		return
	end
	if Line then self:LoadFile(Line, forcenewtab) return end
	hook.Run("StarfallEditorOpen")
end

function Editor:SaveFile(Line, close, SaveAs, Func)
	self:ExtractName()

	if not Line or SaveAs or Line == self.Location .. "/" .. ".txt" then
		local str
		if self.C.Browser.File then
			str = self.C.Browser.File.FileDir -- Get FileDir
			if str and str ~= "" then -- Check if not nil

				-- Remove "expression2/" or "cpuchip/" etc
				local n, _ = str:find("/", 1, true)
				str = str:sub(n + 1, -1)

				if str and str ~= "" then -- Check if not nil
					if str:Right(4) == ".txt" then -- If it's a file
						str = string.GetPathFromFilename(str):Left(-2) -- Get the file path instead
						if not str or str == "" then
							str = nil
						end
					end
				else
					str = nil
				end
			else
				str = nil
			end
		end

		Derma_StringRequestNoBlur("Save to New File", "", (str ~= nil and str .. "/" or "") .. self.savefilefn,
			function(strTextOut)
				strTextOut = self.Location .. "/" .. string.gsub(strTextOut, ".", invalid_filename_chars)
				if not string.match(strTextOut, "%.txt$") then strTextOut = strTextOut .. ".txt" end
				local function save()
					if Func then
						Func(strTextOut)
					else
						self:SaveFile(strTextOut, close)
					end
				end

				if file.Exists(strTextOut, "DATA") then
					Derma_QueryNoBlur("File " .. strTextOut .. " already exists!", "File exists!", "Override", save, "Cancel")
				else
					save()
				end
			end)

		return
	end

	if SF.FileWrite(Line, self:GetCode()) then
		local panel = self.C.Val
		timer.Simple(0, function() panel.SetText(panel, " Saved as " .. Line) end)
		surface.PlaySound("ambient/water/drip3.wav")

		self:ChosenFile(Line, self:GetCode())
		self:UpdateTabText(self:GetActiveTab())
		if close then

			GAMEMODE:AddNotify("Source code saved as " .. Line .. ".", NOTIFY_GENERIC, 7)
			self:Close()
		end
	else
		SF.AddNotify(LocalPlayer(), "Failed to save " .. Line, "ERROR", 7, "ERROR1")
	end
end

function Editor:LoadFile(Line, forcenewtab)
	if not Line or file.IsDir(Line, "DATA") then return end

	local f = file.Open(Line, "rb", "DATA")
	if not f then
		SF.AddNotify(LocalPlayer(), "Erroring opening file: " .. Line, "ERROR", 7, "ERROR1")
		return
	end

	local str = f:Read(f:Size()) or ""
	f:Close()
	self:SaveTabs()
	if not forcenewtab then
		for i = 1, self:GetNumTabs() do
			if self:GetTabContent(i).chosenfile == Line then
				self:SetActiveTab(i)
				if forcenewtab ~= nil then
					self:SetCode(str)
					self:GetCurrentTabContent().savedCode = SF.Editor.normalizeCode(str)
				end
				return
			end
		end
	end
	local title, tabtext = getPreferredTitles(Line, str)
	local tab
	if self.NewTabOnOpenVar:GetBool() or forcenewtab then
		tab = self:CreateTab(tabtext).Tab
	else
		tab = self:GetActiveTab()
	end
	self:SetActiveTab(tab)
	self:SetCode(str)
	self:ChosenFile(Line, self:GetCode())
	self:UpdateTabText(tab)
	self.C.TabHolder:InvalidateLayout()
end

---Returns the value of the settings `ReloadBeforeUpload` of the editor.
---@return boolean
function Editor:ShouldReloadBeforeUpload()
    return self.autoReloadEnabled
end

---Reloads the tab associated to the file at `filepath`, if there is one.
---@param tabIndex number The index of the tab to reload
---@param interactive boolean If the file has unsaved changed and interactive is true
---then prompt the user to overwrite the current unsaved changes, otherwise dont reload the file.
function Editor:ReloadTab(tabIndex, interactive)
	local activeTabIndex = self:GetActiveTabIndex()
	local tab = self:GetTab(tabIndex)
	local tabContent = self:GetTabContent(tabIndex)
	if not tabContent:GetTabHandler().IsEditor then return end

	local filepath = tabContent.chosenfile
	if filepath == nil then
		-- Some tabs can have this field set to nil
		-- At least the default "Generic" tab seems to have
		return
	end

	local fileLastModified = file.Time(filepath, "DATA")
	if fileLastModified == 0 then return end

	-- This `autoReloadLastModified` variable is only assigned and read here, other places in the code should not use
	-- it since they can just call one of the editor's functions.
	if tabContent.autoReloadLastModified ~= nil and tabContent.autoReloadLastModified >= fileLastModified and tabContent:IsSaved() then
		return
	end

	local executeReload = function()
		local fileContent = file.Read(filepath)
		if fileContent == nil then
			SF.AddNotify(LocalPlayer(), "Error while reloading, failed to read file: "..filepath, 7, "ERROR1")
			return
		end

		tabContent:SetCode(fileContent)
		tabContent.savedCode = SF.Editor.normalizeCode(fileContent)
		tabContent.autoReloadLastModified = fileLastModified
		self:UpdateTabText(tab)
		if tabIndex == activeTabIndex then
			self:Validate()
		end

		local mainfile = string.match(filepath, "starfall/(.*)")
		hook.Run("StarfallEditorFileReload", mainfile)
	end

	if tabContent:IsSaved() then
		executeReload()
	elseif interactive then
		local popup = self.reloadPopups[tab]
		if not IsValid(popup) then
			popup = SF.Editor.Query("Unsaved changes!", string.format("Do you want to reload <color=255,30,30>%q</color> ?", tab:GetText()), "Reload", function()
			executeReload()
			self.reloadPopups[tab] = nil
			end, "Cancel", function()
			self.reloadPopups[tab] = nil
			end)
			self.reloadPopups[tab] = popup
		end

		if IsValid(popup) then
			popup:Center()
			popup:MakePopup()
		end
	end
end

---Reloads the tab associated to the file at `filepath`, if there is one.
---@param filepath string The filepath of the file to reload
---@param interactive boolean See `Editor:ReloadTab`
function Editor:ReloadFile(filepath, interactive)
	local tabIndex, tabFound = self:GetTabIndexByFilePath(filepath)
	if not tabFound then return end
	self:ReloadTab(tabIndex, interactive)
end

---Reload all tabs in the editor.
---@param interactive boolean See `Editor:ReloadTab`
function Editor:ReloadTabs(interactive)
	for i = 1, self:GetNumTabs() do
		self:ReloadTab(i, interactive)
	end
end

---Enables or disables the auto reload functionality of the editor.
---This should only be called by EditorFileAutoReload's change callback and the init function.
---@param enabled boolean Enable/Disable auto reload
function Editor:setFileAutoReload(enabled)
	self.autoReloadEnabled = enabled
	if enabled then
		timer.Create(Editor.EditorFileAutoReload:GetName(), self.autoReloadInterval, 0, function(_, _, newValue)
			self:ReloadTabs(false)
		end)
	else
		timer.Remove(Editor.EditorFileAutoReload:GetName())
	end
end

---Sets the polling interval of the file auto reload
---This should only be called by EditorFileAutoReloadInterval's change callback.
---@param interval number Polling interval in seconds
function Editor:setFileAutoReloadInterval(interval)
	self.autoReloadInterval = interval
	if self.autoReloadEnabled then
		self:setFileAutoReload(false)
		self:setFileAutoReload(true)
	end
end

function Editor:Close()
	RunConsoleCommand("starfall_event", "editor_close")
	timer.Stop("sfautosave")
	self:SaveTabs()

	self:ExtractName()
	self:SetV(false)

	self:SaveEditorSettings()
	local activeWep = LocalPlayer():GetActiveWeapon()
	if activeWep:IsValid() and activeWep:GetClass() == "gmod_tool" and activeWep.Mode == "starfall_processor" then
		local model = nil
		local ppdata = SF.PreprocessData("", self:GetCode())
		pcall(ppdata.Preprocess, ppdata)
		RunConsoleCommand("starfall_processor_ScriptModel", ppdata.model or "")
	end
	hook.Run("StarfallEditorClose")
end

function Editor:Setup(nTitle, nLocation, nEditorType)

	self.Title = nTitle
	self.Location = nLocation
	self.EditorType = nEditorType
	self.C.Browser.tree:Setup(nLocation)

	local SFHelp = vgui.Create("StarfallButton", self.C.ButtonHolder)
	SFHelp:DockMargin(2, 0, 0, 0)
	SFHelp:Dock(RIGHT)
	SFHelp:SetText("SFHelper")
	SFHelp.DoClick = function()
		if BRANCH == "unknown" then
			gui.OpenURL(SF.Editor.HelperURL:GetString())
		else
			local th = GetTabHandler("helper")
			if th.htmldata then
				local sheet = self:CreateTab("", "helper")
				self:SetActiveTab(sheet.Tab)
				if Editor.StartHelperUndocked:GetBool() then
					sheet.Tab.content:Undock()
				end
			else
				gui.OpenURL(SF.Editor.HelperURL:GetString())
			end
		end
	end
	self.C.SFHelp = SFHelp

	-- Add "Sound Browser" button
	local SoundBrw = vgui.Create("StarfallButton", self.C.ButtonHolder)
	SoundBrw:DockMargin(2, 0, 0, 0)
	SoundBrw:Dock(RIGHT)
	SoundBrw:SetText("Sound Browser")
	SoundBrw.DoClick = function() RunConsoleCommand("wire_sound_browser_open") end
	self.C.SoundBrw = SoundBrw

	--Add "Model Viewer" button
	local ModelViewer = vgui.Create("StarfallButton", self.C.ButtonHolder)
	ModelViewer:DockMargin(2, 0, 0, 0)
	ModelViewer:Dock(RIGHT)
	ModelViewer:SetText("Model Viewer")
	ModelViewer.DoClick = function()
		if SF.Editor.modelViewer:IsVisible() then
			SF.Editor.modelViewer:Close()
		else
			SF.Editor.modelViewer:Open()
		end
	end
	self.C.ModelViewer = ModelViewer

	--Add "Model Viewer" button
	local FontEditor = vgui.Create("StarfallButton", self.C.ButtonHolder)
	FontEditor:DockMargin(2, 0, 0, 0)
	FontEditor:Dock(RIGHT)
	FontEditor:SetText("Font Editor")
	FontEditor.DoClick = function()
		if self.fontEditor and self.fontEditor:IsValid() then
			self.fontEditor:MakePopup() -- bring to front
			return
		end

		self.fontEditor = vgui.Create("StarfallFontPicker")
		self.fontEditor:SetTitle( "Font Editor" )
		self.fontEditor:SetSizable(true)
		self.fontEditor:SetDeleteOnClose(true)
		self.fontEditor:Open()
	end
	self.C.FontEditor = FontEditor


	self:NewTab()
	if Editor.OpenOldTabsVar:GetBool() then
		self:OpenOldTabs()
	end
	self:InvalidateLayout()

end

vgui.Register("StarfallEditorFrame", Editor, "DFrame")

-- Starfall Users
PANEL  = {}

function PANEL:UpdatePlayers(players)
	local sortedplayers = {}
	for ply in pairs(self.players) do
		local plyname = ply:GetName()
		sortedplayers[#sortedplayers+1] = {ply = ply, name = plyname, namel = string.lower(plyname)}
	end
	table.sort(sortedplayers, function(a,b) return a.namel<b.namel end)

	self.scrollPanel:Clear()
	for _, tbl in ipairs(sortedplayers) do
		local ply = tbl.ply
		local steamid = ply:SteamID()

		local header = vgui.Create("StarfallPanel")
		header:DockMargin(0, 5, 0, 0)
		header:SetSize(0, 32)
		header:Dock(TOP)
		header:SetBackgroundColor(Color(0,0,0,20))
		header:SetTooltip(tbl.name)

		local blocked = SF.BlockedUsers:isBlocked(steamid)
		local button = vgui.Create("StarfallButton", header)
		button.active = blocked
		button:SetText(blocked and "Unblock" or "Block")
		button:DockMargin(0, 0, 3, 0)
		button:Dock(LEFT)

		button.DoClick = function()
			if blocked then
				SF.BlockedUsers:unblock(steamid)
			else
				SF.BlockedUsers:block(steamid)
			end
			blocked = not blocked
			button:SetText(blocked and "Unblock" or "Block")
		end
		button:DockMargin(0, 0, 3, 0)
		button:Dock(LEFT)

		local avatar = vgui.Create("AvatarImage", header)
		avatar:SetPlayer(ply)
		avatar:SetSize(32, 32)
		avatar:DockMargin(0, 0, 3, 0)
		avatar:Dock(LEFT)

		local nametext = vgui.Create("DLabel", header)
		nametext:SetFont("DermaDefault")
		nametext:SetColor(Color(255, 255, 255))
		nametext:SetText(tbl.name)
		nametext:DockMargin(5, 0, 5, 0)
		nametext:Dock(LEFT)
		nametext:SetSize(80, 13)

		local counters = {}
		for k, v in pairs(SF.ResourceCounters) do
			local counter = vgui.Create("StarfallPanel", header)
			counter:DockMargin(3, 0, 0, 0)
			counter:SetSize(20, 32)
			counter:Dock(LEFT)
			counter:SetBackgroundColor(Color(0,0,0,20))
			counter:SetTooltip(k)

			local icon = vgui.Create("DImage", counter)
			icon:SetImage(v.icon)
			icon:SetSize(20, 20)
			icon:Dock(TOP)

			local count = vgui.Create("DLabel", counter)
			count:SetFont("DermaDefault")
			count:SetColor(Color(255, 255, 255))
			count:Dock(BOTTOM)
			count:SetSize(20, 13)

			counter.nextThink = 0
			function counter:Think()
				local t = CurTime()
				if t < self.nextThink then return end
				self.nextThink = t + 0.1

				if blocked then
					count:SetText("0")
				else
					count:SetText(tostring(v.count(ply)))
				end
			end
		end

		local cpuManager = vgui.Create("StarfallPanel", header)
		cpuManager:DockMargin(15, 0, 0, 0)
		cpuManager:SetSize(160, 32)
		cpuManager:Dock(LEFT)
		cpuManager:SetBackgroundColor(Color(0,0,0,20))

		local cpuServer = vgui.Create("StarfallPanel", cpuManager)
		cpuServer:SetSize(150, 16)
		cpuServer:Dock(TOP)
		cpuServer:SetBackgroundColor(Color(0,0,0,20))

		local cpuServerText = vgui.Create("DLabel", cpuServer)
		cpuServerText:SetFont("DermaDefault")
		cpuServerText:SetColor(Color(255, 255, 255))
		cpuServerText:Dock(LEFT)
		cpuServerText:SetText("SV CPU: 0.0 us")
		cpuServerText:SetSize(100,16)

		if LocalPlayer():IsAdmin() then
			local killserver = vgui.Create("StarfallButton", cpuServer)
			killserver:SetText("Admin Kill")
			killserver.DoClick = function()
				RunConsoleCommand( "sf_kill", steamid )
			end
			killserver:Dock(LEFT)
		end

		local cpuClient = vgui.Create("StarfallPanel", cpuManager)
		cpuClient:SetSize(150, 16)
		cpuClient:Dock(TOP)
		cpuClient:SetBackgroundColor(Color(0,0,0,20))

		local cpuClientText = vgui.Create("DLabel", cpuClient)
		cpuClientText:SetFont("DermaDefault")
		cpuClientText:SetColor(Color(255, 255, 255))
		cpuClientText:Dock(LEFT)
		cpuClientText:SetText("CL CPU: 0.0 us")
		cpuClientText:SetSize(100,16)

		local killclient = vgui.Create("StarfallButton", cpuClient)
		killclient:SetText("Kill all")
		killclient.DoClick = function()
			RunConsoleCommand( "sf_kill_cl", steamid )
		end
		killclient:Dock(LEFT)

		header.nextThink = 0
		function header:Think()
			local t = CurTime()
			if t < self.nextThink then return end
			self.nextThink = t + 0.1

			local svtotal = 0
			local cltotal = 0
			for instance, _ in pairs(SF.playerInstances[ply]) do
				svtotal = svtotal + (instance.entity:IsValid() and instance.entity:GetNWInt("CPUus") or 0)
				cltotal = cltotal + instance.cpu_average
			end
			cpuServerText:SetText(string.format("SV CPU: %3.1f us", svtotal))
			cpuClientText:SetText(string.format("CL CPU: %3.1f us", cltotal*1e6))
		end

		self.scrollPanel:AddItem(header)
	end
end

function PANEL:CheckPlayersChanged()
	local players = {}
	for k, v in pairs(player.GetAll()) do
		if not table.IsEmpty(SF.playerInstances[v]) or SF.BlockedUsers:isBlocked(v:SteamID()) then
			players[v] = true
		end
	end
	for v in pairs(self.players) do
		if not players[v] then
			self.players = players
			self:UpdatePlayers()
			return
		end
	end
	for v in pairs(players) do
		if not self.players[v] then
			self.players = players
			self:UpdatePlayers()
			return
		end
	end
end

function PANEL:Think()
	self:CheckPlayersChanged()
end

function PANEL:Init()
	self.players = {}
	self.scrollPanel = vgui.Create("DScrollPanel", self)
	self.scrollPanel:Dock(FILL)
	self.scrollPanel:SetPaintBackgroundEnabled(false)
end

vgui.Register( "StarfallUsers", PANEL, "StarfallFrame" )

local userPanel
list.Set( "DesktopWindows", "StarfallUsers", {

	title		= "Starfall List",
	icon		= "radon/starfall2",
	width		= 520,
	height		= 700,
	onewindow	= true,
	init		= function( icon, window )
		window:Remove()
		RunConsoleCommand("sf_userlist")
	end
} )

concommand.Add("sf_userlist", function()
	if userPanel and userPanel:IsValid() then return end

	userPanel = vgui.Create("StarfallUsers")
	userPanel:SetTitle( "Starfall List" )
	userPanel:SetSize( 520, ScrH()*0.5 )
	userPanel:SetSizable(true)
	userPanel:Center()
	userPanel:SetDeleteOnClose(true)
	userPanel:Open()
end)

