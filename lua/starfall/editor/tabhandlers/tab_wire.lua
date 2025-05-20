--[[
Modified version of Wire Editor, you can find original code and it's licence on link below.
https://github.com/wiremod/wire
File in use: https://github.com/wiremod/wire/blob/3cf67a781006886fb76619c23ea55fa1c661ae90/lua/wire/client/text_editor/texteditor.lua
]]

--
-- Expression 2 Text Editor for Garry's Mod
-- Andreas "Syranide" Svensson, me@syranide.com
--

local string_Explode = string.Explode
local table_concat = table.concat
local string_sub = string.sub
local table_remove = table.remove
local math_floor = math.floor
local math_Clamp = math.Clamp
local math_ceil = math.ceil
local string_match = string.match
local string_gmatch = string.gmatch
local string_gsub = string.gsub
local string_rep = string.rep
local string_byte = string.byte
local string_format = string.format
local string_Trim = string.Trim
local string_reverse = string.reverse
local math_min = math.min
local table_insert = table.insert
local table_sort = table.sort
local surface_SetDrawColor = surface.SetDrawColor
local surface_DrawRect = surface.DrawRect
local surface_SetFont = surface.SetFont
local surface_GetTextSize = surface.GetTextSize
local surface_PlaySound = surface.PlaySound
local surface_SetTextPos = surface.SetTextPos
local surface_SetTextColor = surface.SetTextColor
local surface_DrawText = surface.DrawText
local draw_SimpleText = draw.SimpleText
local surface_DrawTexturedRect = surface.DrawTexturedRect
local surface_DrawTexturedRectUV = surface.DrawTexturedRectUV
local surface_SetMaterial = surface.SetMaterial
local draw_WordBox = draw.WordBox
local draw_RoundedBox = draw.RoundedBox
local matGrid = Material( "gui/alpha_grid.png", "nocull noclamp" )

local TabHandler = {
	Modes = {},
	ControlName = "TabHandler_wire",
	IsEditor = true,
	Description = "Wire-based editor"
}
TabHandler.Modes.Text = { SyntaxColorLine = function(self, row) return { { self.Rows[row][1], { Color(255, 255, 255, 255), false } } } end }
---------------------
-- Fonts
---------------------
TabHandler.Fonts = {} --Font descriptions for settings
TabHandler.Fonts["Courier New"] = "Font used in expression2 editor"
TabHandler.Fonts["DejaVu Sans Mono"] = "Default SF Editor font"
TabHandler.Fonts["Consolas"] = ""
TabHandler.Fonts["Fixedsys"] = ""
TabHandler.Fonts["Lucida Console"] = ""
TabHandler.Fonts["Monaco"] = "Mac standard font"
TabHandler.Fonts["Roboto Mono"] = "Custom Font shipped with starfall"
TabHandler.Tabs = {}
local defaultFont = "DejaVu Sans Mono" -- We ship that with starfall, linux has it by default

TabHandler.FontConVar = CreateClientConVar("sf_editor_wire_fontname", defaultFont, true, false)
TabHandler.FontSizeConVar = CreateClientConVar("sf_editor_wire_fontsize", 16, true, false)
TabHandler.BlockCommentStyleConVar = CreateClientConVar("sf_editor_wire_block_comment_style", 1, true, false)
TabHandler.PigmentsConVar = CreateClientConVar("sf_editor_wire_pigments", 1, true, false)
TabHandler.EnlightenColorsConVar = CreateClientConVar("sf_editor_wire_enlightencolors", 0, true, false) --off by default
TabHandler.HighlightOnDoubleClickConVar = CreateClientConVar("sf_editor_wire_highlight_on_double_click", "1", true, false)
TabHandler.DisplayCaretPosConVar = CreateClientConVar("sf_editor_wire_display_caret_pos", "0", true, false)
TabHandler.AutoIndentConVar = CreateClientConVar("sf_editor_wire_auto_indent", "1", true, false)
TabHandler.EnableAntialiasing = CreateClientConVar("sf_editor_wire_enable_antialiasing", "1", true, false)
TabHandler.ScrollSpeedConVar = CreateClientConVar("sf_editor_wire_scrollmultiplier", "4", true, false)
TabHandler.LinesHiddenFormatConVar = CreateClientConVar("sf_editor_wire_lines_hidden_format", "< %d lines hidden >", true, false)
TabHandler.AutoValidateConVar = CreateClientConVar("sf_editor_wire_validateontextchange", "0", true, false)
TabHandler.CacheDebug = CreateClientConVar("sf_editor_wire_cachedebug", "0", true, false)
TabHandler.HtmlBackgroundConvar = CreateClientConVar("sf_editor_wire_htmlbackground", "", true, false)
TabHandler.HtmlBackgroundOpacityConvar = CreateClientConVar("sf_editor_wire_htmlbackgroundopacity", "5", true, false)
TabHandler.ACControlStyle = CreateClientConVar( "sf_editor_wire_ac_controlstyle", "2", true, false )
TabHandler.ACAuto = CreateClientConVar( "sf_editor_wire_ac_auto", "1", true, false )
TabHandler.ACWithParams = CreateClientConVar( "sf_editor_wire_ac_withparams", "1", true, false )

cvars.AddChangeCallback("sf_editor_wire_htmlbackground",function(_,_,url)
	TabHandler:UpdateHtmlBackground()
end)



---------------------
-- Colors
---------------------

local colors = { }

function TabHandler:LoadSyntaxColors()
	colors = {}
	for k,v in pairs(SF.Editor.Themes.CurrentTheme) do
		if not istable(v) then continue end
		if not v["r"] then
			local mult = TabHandler.EnlightenColorsConVar:GetBool() and 1 or 1.2 -- For some reason gmod seems to render text darker than html
			colors[k] = {
				v[1] and Color(v[1].r*mult,v[1].g*mult,v[1].b*mult,v[1]["a"] or 255) or nil,
				v[2] and Color(v[2].r*mult,v[2].g*mult,v[2].b*mult,v[2]["a"] or 255) or nil,
				v[3]
			}
		else
			colors[k] = Color(v.r,v.g,v.b,v["a"])
		end

	end
end

function TabHandler:GetSyntaxColor(name)
	return colors[name]
end

---------------------
local function createWireLibraryMap()
	local libMap = TabHandler.LibMap or {}
	libMap.Methods = {}
	libMap.Environment = {}

	if not SF.Docs then return libMap end

	for typename, tbl in pairs(SF.Docs.Types) do
		for methodname, val in pairs(tbl.methods) do
			libMap.Methods[methodname] = true
		end
	end
	for methodname, val in pairs(SF.Docs.Libraries.string.methods) do
		libMap.Methods[methodname] = true
	end
	for libname, lib in pairs(SF.Docs.Libraries) do
		local tbl
		if libname == "builtins" then
			tbl = libMap.Environment
		else
			tbl = {}
			libMap[libname] = tbl
		end
		for name, val in pairs(lib.methods) do
			tbl[name] = val.class
		end
		for name, val in pairs(lib.fields) do
			tbl[name] = val.class
		end
	end
	for name, val in pairs(SF.Docs.Libraries.builtins.tables) do
		local tbl = {}
		libMap[name] = tbl
		if val.fields then
			for _, fielddata in pairs(val.fields) do
				tbl[fielddata.name] = "field"
			end
		end
	end

	return libMap
end

function TabHandler:Init()
	TabHandler.LibMap = createWireLibraryMap()

	TabHandler.Modes.Starfall = include("starfall/editor/syntaxmodes/starfall.lua")
	colors = SF.Editor.Themes.CurrentTheme
	self:LoadSyntaxColors()
	self:UpdateHtmlBackground()
end

function TabHandler:UpdateHtmlBackground()
	local url = self.HtmlBackgroundConvar:GetString()
	if url=="" then self.HtmlBackground = false return end
	self.HtmlBackground = true

	if not self.HtmlBackgroundMaterial then
		self.HtmlBackgroundRT = GetRenderTarget("starfall_editor_background_rt", 1024, 1024)
		self.HtmlBackgroundMaterial = CreateMaterial("starfall_editor_html_background", "UnlitGeneric", {
			["$translucent"] = 1,
  			["$vertexalpha"] = 1,
			["$basetexture"] = "starfall_editor_background_rt"
		})
	end
	SF.G_HttpTextureLoader:request(SF.HttpTextureRequest(url,nil,self.HtmlBackgroundRT,function(_,_,fn) if fn then fn(0,0,1024,1024) end end))
end

function TabHandler:RegisterTabMenu(menu, content)
	local coloring = menu:AddSubMenu("Coloring")
	for k,v in pairs(TabHandler.Modes) do
		local mode = v
		coloring:AddOption(k, function()
			content.CurrentMode = mode
			content:OnThemeChange(SF.Editor.Themes.CurrentTheme) -- It recaches everything
		end)
	end
end

function TabHandler:RegisterSettings()

	local form = vgui.Create("DForm")
	form:Dock(FILL)
	form.Header:SetVisible(false)
	form.Paint = function () end
	local _old = form.AddItem
	form.PerformLayout = function() end
	form.AddItem = function(form, left, right)
		_old(form,left,right)
		if left then
			if left.SetDark then left:SetDark(false) end
			left:SetWide(160)
		end
		if right then
			if right.SetDark then right:SetDark(false) end
			if right.OnSelect then -- Combo
				form.Items[#form.Items]:SetSizeY(false)
				form.Items[#form.Items]:SetSize(120,30)
			end
		end

		return left,right
	end
	local function FakeThemeChange()
		local editor = SF.Editor.editor
		for i = 1, editor:GetNumTabs() do
			local tab = editor:GetTabContent(i)
			if not tab then continue end
			if tab.OnThemeChange then tab:OnThemeChange(SF.Editor.Themes.CurrentTheme) end
		end
	end

	--- - FONTS
	if system.IsLinux() then
		local label = vgui.Create("DLabel")
		label:SetWrap(true)
		label:SetText("Warning: You are running linux, you should make sure font is installed in your system or you wont be able to see it!")
		label:SetPos(10, 0)
		form:AddItem(label)
	end

	local FontSelect = form:ComboBox( "Font")
	-- dlist:AddItem( FontSelect )
	FontSelect.OnSelect = function(panel, index, value)
		if value == "Custom..." then
			Derma_StringRequestNoBlur("Enter custom font:", "", "", function(value)
				RunConsoleCommand("sf_editor_wire_fontname", value)
				FontSelect:SetFontInternal(SF.Editor.editor:GetFont(value, 16, TabHandler.EnableAntialiasing:GetBool()))
				timer.Simple(0, FakeThemeChange)
			end)
		else
			value = value:gsub(" %b()", "") -- Remove description
			RunConsoleCommand("sf_editor_wire_fontname", value)
			FontSelect:SetFontInternal(SF.Editor.editor:GetFont(value, 16, TabHandler.EnableAntialiasing:GetBool()))
			timer.Simple(0, FakeThemeChange)
		end
	end
	for k, v in pairs(self.Fonts) do
		FontSelect:AddChoice(k .. (v ~= "" and " (" .. v .. ")" or ""))
	end
	FontSelect:AddChoice("Custom...")
	FontSelect:SetValue(TabHandler.FontConVar:GetString())
	FontSelect:SetFontInternal(SF.Editor.editor:GetFont(TabHandler.FontConVar:GetString(), 16, TabHandler.EnableAntialiasing:GetBool()))



	local FontSizeSelect =  form:ComboBox( "Font Size")
	FontSizeSelect.OnSelect = function(panel, index, value)
		value = value:gsub(" %b()", "")
		RunConsoleCommand("sf_editor_wire_fontsize", value)
		timer.Simple(0, FakeThemeChange)
	end
	for i = 11, 26 do
		FontSizeSelect:AddChoice(i .. (i == 16 and " (Default)" or ""))
	end
	FontSizeSelect:SetValue(TabHandler.FontSizeConVar:GetString())


	local usePigments = form:ComboBox( "Pigments", nil )
	usePigments:SetSortItems(false)
	usePigments:AddChoice("Disabled")
	usePigments:AddChoice("Stripe under Color()")
	usePigments:AddChoice("Background of Color()")
	usePigments:ChooseOptionID(TabHandler.PigmentsConVar:GetInt() + 1)
	usePigments:SetTooltip("Enable/disable custom coloring of Color(r,g,b)")
	usePigments.OnSelect = function(_, val)
		RunConsoleCommand("sf_editor_wire_pigments", val-1)
		timer.Simple(0, FakeThemeChange)
	end
	local linesHiddenFormat = form:TextEntry( "Format of hidden lines text", "sf_editor_wire_lines_hidden_format" )

	local commentStyle = form:ComboBox( "Comment Style", "sf_editor_wire_block_comment_style" )
	commentStyle:AddChoice("Block (New Line)", 0)
	commentStyle:AddChoice("Block", 1)
	commentStyle:AddChoice("Each Line", 2)

	local autoIndent = form:CheckBox( "Auto indent", "sf_editor_wire_auto_indent" )

	local autoValidate = form:CheckBox( "Automatically validate", "sf_editor_wire_validateontextchange" )

	local enlightenColors = form:CheckBox( "Use brighter colors", "sf_editor_wire_enlightencolors" )
	local displayCaret = form:CheckBox( "Display caret position", "sf_editor_wire_display_caret_pos" )

	local enableAntialiasing = form:CheckBox( "Enable font antialiasing", "sf_editor_wire_enable_antialiasing" )

	local scrollSpeed = form:NumSlider("Scroll Speed","sf_editor_wire_scrollmultiplier", 0.01, 4, 4)
	scrollSpeed:SetPaintBackgroundEnabled( true )
	scrollSpeed.TextArea.m_colText = Color(255,255,255)

	local htmlbackground = form:TextEntry("Custom background image url:", "sf_editor_wire_htmlbackground")
	local htmlbackgroundopacity = form:NumSlider("Custom background image opacity","sf_editor_wire_htmlbackgroundopacity", 0, 255, 1)

	local AutoCompleteControlOptions = form:ComboBox("Auto completion control style")

	local modes = {
		{ "Off", "Turn off autocomplete." },
		{ "Expression2 Style", "Current mode:\nTab/CTRL+Tab to choose item;\nEnter/Space to use;\nArrow keys to abort." },
		{ "Visual Studio Style", "Current mode:\nArrow keys to choose item;\nTab use.\nSpace to abort." },
		{ "Eclipse Style", "Current mode:\nArrow keys to choose item;\nEnter to use;\nSpace to abort." },
	}

	AutoCompleteControlOptions:SetSortItems(false)
	for k, v in ipairs(modes) do
		AutoCompleteControlOptions:AddChoice(v[1])
	end
	local curmode = math.Clamp(TabHandler.ACControlStyle:GetInt()+1, 1, #modes)
	AutoCompleteControlOptions:SetValue(modes[curmode][1])
	AutoCompleteControlOptions:SetToolTip(modes[curmode][2])

	AutoCompleteControlOptions.OnSelect = function(panel, index)
		panel:SetToolTip(modes[index][2])
		RunConsoleCommand("sf_editor_wire_ac_controlstyle", index-1)
	end

	form:CheckBox( "Autocomplete while typing. (Use ctrl+space otherwise)", "sf_editor_wire_ac_auto" )
	form:CheckBox( "Autocomplete adds function parameters.", "sf_editor_wire_ac_withparams" )

	return form, "Wire", "icon16/pencil.png", "Options for wire tabs."
end

local PANEL = {}
function PANEL:OnValidate(s, r, m, go_to)
	if s or not go_to then return end
	self:SetCaret({ r, 0 })
end


function PANEL:Init()
	self:SetCursor("beam")

	self.TabHandler = TabHandler

	self.Rows = { {"",false,false} }
	self.RowTexts = {}
	self.Caret = { 1, 1 }
	self.Start = { 1, 1 }
	self.Scroll = { 1, 1 }
	self.Size = { 1, 1 }
	self.Undo = {}
	self.Redo = {}
	self.RowOffset = {}
	self.RealLine = {}
	self.GlobalOffset = {}
	self.VisibleRows = 0

	self.CurrentMode = assert(TabHandler.Modes.Text)

	self.LineNumberWidth = 2

	self.Blink = RealTime()

	self.ScrollBar = vgui.Create("DVScrollBar", self)


	self.ScrollBar:SetUp(1, 1)
	self.ScrollBar.SetScrollFix = function(bar,scroll,diff)
		diff = diff or 0
		local vis = 0
		local prev_vis = 0
		for k,v in ipairs(self.Rows) do

			if k == scroll then
				if v[3] then
					return bar:SetScroll(vis+diff)
				end
				return bar:SetScroll(vis)
			end
			if not v[3] then
				vis = vis + 1
			end
			prev_vis = k
		end
	end
	self.ScrollBar.Paint = function(_, w, h)
		surface_SetDrawColor(colors.gutter_background)
		surface_DrawRect(0, 0, w, h)
	end
	self.ScrollBar.btnGrip.Paint = function(_, w, h)
		surface_SetDrawColor(colors.gutter_foreground)
		draw.RoundedBox(4, 0, 0, w, h, Color(234, 234, 234))
	end
	self.ScrollBar:SetHideButtons( true )

	self.TextEntry = vgui.Create("TextEntry", self)
	self.TextEntry:SetMultiline(true)
	self.TextEntry:SetSize(0, 0)

	self.TextEntry.OnLoseFocus = function (self) self.Parent:_OnLoseFocus() end
	self.TextEntry.OnTextChanged = function (self) self.Parent:_OnTextChanged() end
	self.TextEntry.OnKeyCodeTyped = function (self, code) return self.Parent:_OnKeyCodeTyped(code) end

	self.TextEntry.Parent = self

	self.LastClick = 0

	self.e2fs_functions = {}

	self:SetMode("Starfall")
	self.CurrentMode:LoadSyntaxColors()

	self.CurrentFont, self.FontWidth, self.FontHeight = SF.Editor.editor:GetFont(TabHandler.FontConVar:GetString(), TabHandler.FontSizeConVar:GetInt(), TabHandler.EnableAntialiasing:GetBool())
	self.CurrentFontSmall, self.FontSmallWidth, self.FontSmallHeight = SF.Editor.editor:GetFont(TabHandler.FontConVar:GetString(), math_floor(TabHandler.FontSizeConVar:GetInt()*0.9), TabHandler.EnableAntialiasing:GetBool())
	table.insert(TabHandler.Tabs, self)

end

function PANEL:GetRowText(line)
	if line > #self.Rows then
		return ""
	end
	return self.Rows[line][1]
end
function PANEL:GetRowCache(line)
	return self.Rows[line][2]
end
function PANEL:UnfoldHidden(line)
	local row = self.Rows[line]
	if not row then return end
	if row[3] then
		local start = line - row.hiddenBy
		local hides = self.Rows[start].hides
		self.Rows[start].hides = nil
		for I = start + 1, start + hides do
			self:ShowRow(I)
		end
	elseif row.hides then
		local start = line
		local hides = row.hides
		row.hides = nil
		for I = start + 1, start + hides do
			self:ShowRow(I)
		end
	end
end
function PANEL:RemoveRowAt(line)
	table_remove(self.Rows,line)
	table_remove(self.RowTexts,line)
	self:InvalidateLayout()
	self:OnMouseWheeled(0)
	self:ScrollCaret()
end
function PANEL:SetRowText(line, text)
	if line > #self.Rows then
		table.insert(self.Rows, {
			text, --Text
			false, --Cache
			false, --Hidden
		})
		table.insert(self.RowTexts, text)
		self.VisibleRows = self.VisibleRows + 1
		return
	end
	self.Rows[line][1] = text
	self.RowTexts[line] = text
	self:UnfoldHidden(line)
	self:RecacheLine(line)
	if TabHandler.AutoValidateConVar:GetBool() then
		SF.Editor.editor:Validate(false)
	end
end

function PANEL:InsertRowAt(line, text)
	if line > 2 and line < #self.Rows then
		if self.Rows[line-1].hides or self.Rows[line][3] then -- pasted INSIDE hidden area, show it
			self:UnfoldHidden(line)
		end
	end
	table.insert(self.Rows,line, {
		text, --Text
		false, --Cache
		false, --Hidden
	})
	table.insert(self.RowTexts, line, text)
	self.VisibleRows = self.VisibleRows + 1
	if TabHandler.AutoValidateConVar:GetBool() then
		SF.Editor.editor:Validate(false)
	end
	self:InvalidateLayout()
end

function PANEL:HideRow(row)
	if self.Caret[1] == row then
		self.Caret[1] = self.Caret[1] + 1
	end
	if not self.Rows[row][3] then
		self.Rows[row][3] = true
		self.VisibleRows = self.VisibleRows - 1
	end
	self:InvalidateLayout()
end

function PANEL:ShowRow(row)
	if not self.Rows[row][3] then
		return
	end
	self.VisibleRows = self.VisibleRows + 1
	self.Rows[row][3] = false
	self.Rows[row].hides = nil
	self.Rows[row].hiddenBy = nil
	self:InvalidateLayout()
end

function PANEL:GetRowOffset(row)
	return self.RowOffset[row] or 0
end

function PANEL:OnThemeChange()
	colors = SF.Editor.Themes.CurrentTheme
	self:DoAction("LoadSyntaxColors")
	for k,v in ipairs(self.Rows) do
		v[2] = false
	end
	self.CurrentFont, self.FontWidth, self.FontHeight = SF.Editor.editor:GetFont(TabHandler.FontConVar:GetString(), TabHandler.FontSizeConVar:GetInt(), TabHandler.EnableAntialiasing:GetBool())
	self.CurrentFontSmall, self.FontSmallWidth, self.FontSmallHeight = SF.Editor.editor:GetFont(TabHandler.FontConVar:GetString(), TabHandler.FontSizeConVar:GetInt()*0.7, TabHandler.EnableAntialiasing:GetBool())

end

function PANEL:OnRemove()
	table.RemoveByValue(TabHandler.Tabs, self)
end

function PANEL:SetMode(mode_name)
	self.CurrentMode = TabHandler.Modes[mode_name or "Text"]
	if not self.CurrentMode then
		Msg("Couldn't find text editor mode '".. tostring(mode_name) .. "'")
		self.CurrentMode = assert(TabHandler.Modes.Text, "Couldn't find default text editor mode")
	end
end

function PANEL:DoAction(name, ...)
	if not self.CurrentMode then return end
	local f = assert(self.CurrentMode, "No current mode set")[name]
	if not f then f = TabHandler.Modes.Text[name] end
	if f then return f(self, ...) end
end

function PANEL:GetParent()
	return self.parentpanel
end

function PANEL:RequestFocus()
	self.TextEntry:RequestFocus()
end

function PANEL:OnGetFocus()
	self.TextEntry:RequestFocus()
end

function PANEL:CursorToCaret()
	local x, y = self:CursorPos()
	local lines = #self.Rows
	x = x - (self.LineNumberWidth + 6)
	if x < 0 then x = 0 end
	if y < 0 then y = 0 end

	local line = math_floor(y / self.FontHeight)
	local char = math_floor(x / self.FontWidth + 0.5)
	if line > self.VisibleRows then line = self.VisibleRows - 1 end

	line = self.RealLine[line] or lines

	char = char + self.Scroll[2]
	local length = #self:GetRowText(line)
	if char > length + 1 then char = length + 1 end
	return { line, char }
end

function PANEL:ToggleFold(y)
	local lines = #self.Rows
	local row = self.Rows[y]
	row[2]  = self:SyntaxColorLine(y)
	local cols = row[2]
	local sum = 0
	if not cols.foldable then return end
	--[[Hiding then/do -> end]]
	local adds = {
		["then"] = true,
		["function"] = true,
		["do"] = true
	}
	local removes = {
		["end"] = true,
		["else"] = true,
		["elseif"] = true,
	}
	for k,v in ipairs(cols) do
		local text = v[1]
		::redo::
		if adds[text] then
			sum = sum + 1
		end
		if removes[text] and (sum > 0 or text == "end") then
			sum = sum - 1
		end
		if text == "else" then
			text = "then"
			goto redo
		end
		cols.test = sum
	end
	if sum > 0 and not row.hides then
		local line = y + 1
		local sum = sum -- Change scope
		while line < lines do
			self.Rows[line][2]  = self:SyntaxColorLine(line)
			cols = self.Rows[line][2]
			for k,v in ipairs(cols) do
				local text = v[1]
				::redo::
				if adds[text] then
					sum = sum + 1
				else
				end
				if removes[text] then
					sum = sum - 1
				end
				cols.test = sum
				local fullcollapse =text == "end"
				if sum <= 0 then
					row.hides = 0
					for I = y + 1, fullcollapse and line or line -1 do
						self:HideRow(I)
						self.Rows[I].hiddenBy = I-y
						row.hides = row.hides + 1
						row.fullcollapse = fullcollapse
					end
					return
				end
				if text == "else" then
					text = "then"
					goto redo
				end
			end

			line = line + 1
		end
	end
	--[[Hiding { -> }]]
	sum = 0
	for k,v in ipairs(cols) do
		if v[1] == "{" then
			sum = sum + 1
		end
		if v[1] == "}" then
			sum = sum - 1
		end
		cols.test = sum
	end
	if sum > 0 and not row.hides then
		local sum = sum -- Change scope
		local line = y
		local sum = 0

		while line < lines do
			self.Rows[line][2]  = self:SyntaxColorLine(line)
			cols = self.Rows[line][2]
			for k,v in ipairs(cols) do
				if v[1] == "{" then
					sum = sum + 1
				end
				if v[1] == "}" then
					sum = sum - 1
				end
				cols.test = sum
			end
			if sum <= 0 then
				row.hides = 0
				for I = y + 1, line do
					self:HideRow(I)
					self.Rows[I].hiddenBy = I-y
					row.hides = row.hides + 1
				end
				return
			end
			line = line + 1
		end
	end

	if row.hides then
		cols.foldable = true
		for I = y + 1, y + row.hides do
			self:ShowRow(I)
		end
		row.hides = nil
	end
end
function PANEL:OpenContextMenu()
	local menu = DermaMenu()

	self:DoAction("PopulateContextMenu", menu)
	menu:AddSpacer()

	if self:CanUndo() then
		menu:AddOption("Undo", function()
				self:DoUndo()
			end)
	end
	if self:CanRedo() then
		menu:AddOption("Redo", function()
				self:DoRedo()
			end)
	end

	if self:CanUndo() or self:CanRedo() then
		menu:AddSpacer()
	end

	if self:HasSelection() then
		menu:AddOption("Cut", function()
			self:Cut()
		end)
		menu:AddOption("Copy", function()
			self:Copy()
		end)
	end

	menu:AddOption("Paste", function()
			if self.clipboard then
				self:SetSelection(self.clipboard)
			else
				self:SetSelection()
			end
		end)

	if self:HasSelection() then
		menu:AddOption("Delete", function()
				self:SetSelection()
			end)
	end

	menu:AddSpacer()

	menu:AddOption("Select all", function()
			self:SelectAll()
		end)

	menu:AddSpacer()

	menu:AddOption("Indent", function()
			self:Indent(false)
		end)
	menu:AddOption("Outdent", function()
			self:Indent(true)
		end)

	if self:HasSelection() then
		menu:AddSpacer()

		menu:AddOption("Comment Block", function()
				self:CommentSelection(false)
			end)
		menu:AddOption("Uncomment Block", function()
				self:CommentSelection(true)
			end)

		menu:AddOption("Comment Selection", function()
				self:BlockCommentSelection(false)
			end)
		menu:AddOption("Uncomment Selection", function()
				self:BlockCommentSelection(true)
			end)
	end

	self:DoAction("PopulateMenu", menu)

	menu:AddSpacer()

	menu:AddOption("Copy with BBCode colors", function()
			local str = string_format("[code][font=%s]", TabHandler.FontConVar)

			local prev_colors
			local first_loop = true

			for i = 1, #self.Rows do
				local colors = self:SyntaxColorLine(i)

				for k, v in ipairs(colors) do
					local color = v[2][1]

					if (prev_colors and prev_colors == color) or string_Trim(v[1]) == "" then
						str = str .. v[1]
					else
						prev_colors = color

						if first_loop then
							str = str .. string_format('[color="#%x%x%x"]', color.r - 50, color.g - 50, color.b - 50) .. v[1]
							first_loop = false
						else
							str = str .. string_format('[/color][color="#%x%x%x"]', color.r - 50, color.g - 50, color.b - 50) .. v[1]
						end
					end
				end

				str = str .. "\r\n"

			end

			str = str .. "[/color][/font][/code]"

			self.clipboard = str
			SetClipboardText(str)
		end)

	menu:Open()
	return menu
end

function PANEL:OnMousePressed(code)
	if self.acPanel then self.acPanel:SetVisible(false) end
	if code == MOUSE_LEFT then
		local x,y = self:CursorPos()
		if x > self.LineNumberWidth - 10 and x < self.LineNumberWidth then
			if x < 0 then x = 0 end
			if y < 0 then y = 0 end
			local line = math_floor(y / self.FontHeight)
			if line > #self.Rows or line > self.VisibleRows - 1 then return end
			line = self.RealLine[line] or line

			self:ToggleFold(line)
			return
		end
		local cursor = self:CursorToCaret()
		if (CurTime() - self.LastClick) < 1 and self.tmp and cursor[1] == self.Caret[1] and cursor[2] == self.Caret[2] then
			self.Start = self:getWordStart(self.Caret)
			self.Caret = self:getWordEnd(self.Caret)
			self.tmp = false

			if TabHandler.HighlightOnDoubleClickConVar:GetBool() then
				self.HighlightedAreasByDoubleClick = {}
				local all_finds = self:FindAllWords(self:GetSelection())
				if all_finds then
					all_finds[0] = { 1, 1 } -- Set [0] so the [i-1]'s don't fail on the first iteration
					self.HighlightedAreasByDoubleClick[0] = { { 1, 1 }, { 1, 1 } }
					for i = 1, #all_finds do
						-- Instead of finding the caret by searching from the beginning every time, start searching from the previous caret
						local start = all_finds[i][1] - all_finds[i-1][1]
						local stop = all_finds[i][2] - all_finds[i-1][2]
						local caretstart = self:MovePosition(self.HighlightedAreasByDoubleClick[i-1][1], start)
						local caretstop = self:MovePosition(self.HighlightedAreasByDoubleClick[i-1][2], stop)
						self.HighlightedAreasByDoubleClick[i] = { caretstart, caretstop }

						-- This checks if it's NOT the word the user just highlighted
						if caretstart[1] ~= self.Start[1] or caretstart[2] ~= self.Start[2] or
						caretstop[1] ~= self.Caret[1] or caretstop[2] ~= self.Caret[2] then
							local c = colors.word_highlight
							self:HighlightArea({ caretstart, caretstop }, c.r, c.g, c.b, 100)
						end
					end
				end
			end
			return
		elseif self.HighlightedAreasByDoubleClick then
			for i = 1, #self.HighlightedAreasByDoubleClick do
				self:HighlightArea(self.HighlightedAreasByDoubleClick[i])
			end
			self.HighlightedAreasByDoubleClick = nil
		end

		self.tmp = true

		self.LastClick = CurTime()
		self:RequestFocus()
		self.Blink = RealTime()
		self.MouseDown = true

		self.Caret = self:CopyPosition(cursor)
		if not input.IsKeyDown(KEY_LSHIFT) and not input.IsKeyDown(KEY_RSHIFT) then
			self.Start = self:CopyPosition(cursor)
		end
		self:SetCaret(self.Caret)
	elseif code == MOUSE_RIGHT then
		self:OpenContextMenu()
	end
end

function PANEL:OnMouseReleased(code)
	if not self.MouseDown then return end

	if code == MOUSE_LEFT then
		self.MouseDown = nil
		if not self.tmp then return end
		self.Caret = self:CursorToCaret()
	end
end

function PANEL:SetCode(text)
	text = SF.Editor.normalizeCode(text)
	if text == self:GetCode() then return end
	self.Rows = {}
	self.RowTexts = {}
	self.VisibleRows = 0
	local rows = string_Explode("\n", text)
	for k,v in ipairs(rows) do
		self:SetRowText(k,v)
	end
	local lines = #self.Rows


	self.Caret = { 1, 1 }
	self.Start = { 1, 1 }
	self.Scroll = { 1, 1 }
	self.Undo = {}
	self.Redo = {}
	self.ScrollBar:SetUp(self.Size[1], self.VisibleRows -1)
end

function PANEL:GetCode()
	local code = table_concat(self.RowTexts,"\n")
	return string_gsub(code, "\r", "")
end

function PANEL:GetLinesAsText(startingat, endingat)
	local lines = endingat or #self.Rows
	local code = table_concat(self.RowTexts,"\n", startingat, endingat)
	return string_gsub(code, "\r", "")
end

function PANEL:HighlightLine(line, r, g, b, a)
	if not self.HighlightedLines then self.HighlightedLines = {} end
	if not r and self.HighlightedLines[line] then
		self.HighlightedLines[line] = nil
		return true
	elseif r and g and b and a then
		self.HighlightedLines[line] = { r, g, b, a }
		return true
	end
	return false
end
function PANEL:ClearHighlightedLines() self.HighlightedLines = nil end

function PANEL:PaintLine(row, drawpos, leftOffset, drawonlytext)
	local lines = #self.Rows
	local lineLen = #self:GetRowText(row)

	local usePigments = TabHandler.PigmentsConVar:GetInt()
	if row > lines then return end
	local width, height = self.FontWidth, self.FontHeight
	local startX, startY = self.LineNumberWidth + 5, drawpos*height
	local offset = leftOffset or -self.Scroll[2] + 1
	local rowdata = self.Rows[row]

	if not self:GetRowCache(row) then

		local colored = self:SyntaxColorLine(row)
		self.Rows[row][2] = colored

		local newrow = row+1
		--Let's find end of string/comment
		while colored.unfinished do
			if newrow > lines then break end -- End of file
			if newrow - row < 50 then
				colored = self:SyntaxColorLine(newrow)
				self.Rows[newrow][2] = colored
			else -- If string/comment is above 50 lines long invalidate rest of cache so it gets rebuilt later instead of doing it now
				self.Rows[newrow][2] = false
			end
			newrow = newrow + 1
		end
		if TabHandler.CacheDebug:GetBool() then
			surface_SetDrawColor(Color(255,0,0))
			surface_DrawRect(startX, startY, self:GetWide() - (self.LineNumberWidth + 5), height)
		end
	end
	local cells = self:GetRowCache(row)

	if not drawonlytext then

		if row == self.Caret[1] and self.TextEntry:HasFocus() then
			surface_SetDrawColor(colors.line_highlight)
			surface_DrawRect(startX, startY, self:GetWide() - (self.LineNumberWidth + 5), height)
		end

		if self.HighlightedLines and self.HighlightedLines[row] then
			local color = self.HighlightedLines[row]
			surface_SetDrawColor(color[1], color[2], color[3], color[4])
			surface_DrawRect(startX, startY, self:GetWide() - (self.LineNumberWidth + 5), height)
		end

		if self:HasSelection() then
			local start, stop = self:MakeSelection(self:Selection())
			local line, char = start[1], start[2]
			local endline, endchar = stop[1], stop[2]

			surface_SetDrawColor(colors.selection)
			local length = lineLen - self.Scroll[2] + 1

			char = char - self.Scroll[2]
			endchar = endchar - self.Scroll[2]
			if char < 0 then char = 0 end
			if endchar < 0 then endchar = 0 end

			if row == line and line == endline then
				surface_DrawRect(char * width + startX, startY, width * (endchar - char), height)
			elseif row == line then
				surface_DrawRect(char * width + startX, startY, width * (length - char + 1), height)
			elseif row == endline then
				surface_DrawRect(startX, startY, width * endchar, height)
			elseif row > line and row < endline then
				surface_DrawRect(startX, startY, width * (length + 1), height)
			end
		end

		draw_SimpleText(tostring(row), self.CurrentFont, self.LineNumberWidth - 10, startY, colors.gutter_foreground, TEXT_ALIGN_RIGHT)

		--draw_SimpleText(tostring(cells.test or ""), self.CurrentFont, self.LineNumberWidth + 5, startY, colors.word_highlight, TEXT_ALIGN_LEFT)

		if cells.foldable then
			if rowdata.hides then
				draw_SimpleText("▶", self.CurrentFontSmall, self.LineNumberWidth - 3, startY + height/2, colors.gutter_foreground, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
			else
				draw_SimpleText("▼", self.CurrentFontSmall, self.LineNumberWidth - 3, startY + height/2, colors.gutter_foreground, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER )
			end
		end

	end


	local nonwhitespace = false
	for i, cell in ipairs(cells) do
		if cell[3] == "whitespace" and not nonwhitespace and drawonlytext then -- Skip whitespaces at beginning if its text only
			continue
		end
		nonwhitespace = true
		if offset > self.Size[2] then return end
		if offset < 0 then -- When there is part of line horizontally begining before our scrolled area
			local length = cell[1]:len()
			if length > -offset then
				local line = cell[1]:sub(1-offset)
				offset = line:len()

				if cell[2][2] then --has background
					if usePigments == 1 and cell[3]:sub(1, 5) == "color" then
						surface_SetMaterial( matGrid )
						surface_SetDrawColor(Color(255, 255, 255))
						surface_DrawTexturedRectUV(startX, startY + height-2, width * offset, 2, 0, 0, width * offset / 2, 1)
						surface_SetDrawColor(cell[2][2])
						surface_DrawRect(startX, startY + height-2, width * offset, 2)
					else
						if cell[3]:sub(1, 5) == "color" then
							surface_SetMaterial( matGrid )
							surface_SetDrawColor(Color(255, 255, 255))
							surface_DrawTexturedRectUV(startX, startY, width * offset, height, 0, 0, width * offset, height)
						end
						surface_SetDrawColor(cell[2][2])
						surface_DrawRect(startX, startY, width * offset, height)
					end
				end

				if cell[2][2] then
					draw_SimpleText(line .. " ", self.CurrentFont .. "_Bold", startX, startY, cell[2][1])
				else
					draw_SimpleText(line .. " ", self.CurrentFont, startX, startY, cell[2][1])
				end
			else
				offset = offset + length
			end
		else
			local length = cell[1]:len()
			if cell[2][2] then --has background
				if usePigments == 1 and cell[3]:sub(1, 5) == "color" then
					surface_SetMaterial( matGrid )
					surface_SetDrawColor(Color(255, 255, 255))
					surface_DrawTexturedRectUV(startX + offset * width, startY + height-2, width * length, 2, 0, 0, width * length / 2, 1)
					surface_SetDrawColor(cell[2][2])
					surface_DrawRect(startX + offset * width, startY + height-2, width * length, 2)
				else
					if cell[3]:sub(1, 5) == "color" then
						surface_SetMaterial( matGrid )
						surface_SetDrawColor(Color(255, 255, 255))
						surface_DrawTexturedRectUV(startX + offset * width, startY, width * length, height,0 ,0, width * length / height, 1)
					end
					surface_SetDrawColor(cell[2][2])
					surface_DrawRect(startX + offset * width, startY, width * length, height)
				end
			end
			if cell[2][3] == 2 then
				draw_SimpleText(cell[1] .. " ", self.CurrentFont .. "_Bold", offset * width + startX, startY, cell[2][1])
			elseif cell[2][3] == 1 then
				draw_SimpleText(cell[1] .. " ", self.CurrentFont .. "_Italic", offset * width + startX, startY, cell[2][1])
			else
				draw_SimpleText(cell[1] .. " ", self.CurrentFont, offset * width + startX, startY, cell[2][1])
			end

			offset = offset + length
		end
	end
	if not drawonlytext then
		if row < lines and rowdata.hides then
			local text = string.format(TabHandler.LinesHiddenFormatConVar:GetString(),rowdata.hides)
			local nextlineoff = offset + #text
			draw_SimpleText(text, self.CurrentFontSmall, offset * width + startX + (nextlineoff-offset)*width/2, startY + height/2 ,colors.word_highlight, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			if self.RealLine[drawpos+1] and rowdata.fullcollapse then
				self:PaintLine(self.RealLine[drawpos+1]-1, drawpos, nextlineoff, true)
			end
		end
	end
--[[	if cells.foldable then
		surface_SetDrawColor(Color(0,222,0,20))
		surface_DrawRect(startX, startY, self:GetWide() - (self.LineNumberWidth + 5), height)
	end
	if cells.test then
		draw_SimpleText(tostring(cells.test), self.CurrentFont, startX, startY, Color(32,32,255))
	end]]
end

function PANEL:PerformLayout()
	self.ScrollBar:SetSize(16, self:GetTall())
	self.ScrollBar:SetPos(self:GetWide() - 16, 0)

	self.Size[1] = math_floor(self:GetTall() / self.FontHeight) - 1
	self.Size[2] = math_floor((self:GetWide() - (self.LineNumberWidth + 6) - 16) / self.FontWidth) - 1

	self.ScrollBar:SetUp(self.Size[1], self.VisibleRows -1)
end

function PANEL:HighlightArea(area, r, g, b, a)
	if not self.HighlightedAreas then self.HighlightedAreas = {} end
	if not r then
		local _start, _stop = area[1], area[2]
		for k, v in pairs(self.HighlightedAreas) do
			local start = v[1][1]
			local stop = v[1][2]
			if start[1] == _start[1] and start[2] == _start[2] and stop[1] == _stop[1] and stop[2] == _stop[2] then
				table_remove(self.HighlightedAreas, k)
				break
			end
		end
		return true
	elseif r and g and b and a then
		self.HighlightedAreas[#self.HighlightedAreas + 1] = { area, r, g, b, a }
		return true
	end
	return false
end
function PANEL:ClearHighlightedAreas() self.HighlightedAreas = nil end


function PANEL:PaintTextOverlay()
	if self.TextEntry:HasFocus() and self.Caret[2] - self.Scroll[2] >= 0 then
		local lines = #self.RowTexts
		local width, height = self.FontWidth, self.FontHeight

		if (RealTime() - self.Blink) % 0.8 < 0.4 then
			surface_SetDrawColor(colors.caret)
			local y = self.Caret[1]
			y = (self.Caret[1] - self:GetRowOffset(y) - self.Scroll[1]) * height
			surface_DrawRect((self.Caret[2] - self.Scroll[2]) * width + self.LineNumberWidth + 6, y, 1, height)
		end
		if self.HighlightedAreas then
			local xofs = self.LineNumberWidth + 6
			for key, data in pairs(self.HighlightedAreas) do
				local area, r, g, b, a = data[1], data[2], data[3], data[4], data[5]
				surface_SetDrawColor(r, g, b, a)
				local start, stop = self:MakeSelection(area)
				if start[1] > lines then
					start[1] = lines
				end
				if stop[1] > lines then
					stop[1] = lines
				end
				if self.Rows[start[1]][3] or self.Rows[stop[1]][3] then continue end -- Row is hidden
				local startY = start[1] - self:GetRowOffset(start[1]) - self.Scroll[1]
				local stopY = stop[1] - self:GetRowOffset(stop[1]) - self.Scroll[1]
				if start[1] == stop[1] then -- On the same line
					surface_DrawRect(xofs + (start[2]-self.Scroll[2]) * width, (startY * height) + 1, (stop[2]-start[2]) * width, 1)
					surface_DrawRect(xofs + (start[2]-self.Scroll[2]) * width, (startY * height) + height - 2, (stop[2]-start[2]) * width, 1)

					surface_DrawRect(xofs + (start[2]-self.Scroll[2]) * width + (stop[2]-start[2]) * width - 1, startY * height + 1, 1, height-2)
					surface_DrawRect(xofs + (start[2]-self.Scroll[2]) * width, (startY * height) + 1, 1, height-2)

				elseif start[1] < stop[1] then -- Ends below start
					for i = start[1], stop[1] do
						if i == start[1] then
							surface_DrawRect(xofs + (start[2]-self.Scroll[2]) * width, (self:GetRowOffset(i)-self.Scroll[1]) * height, (#self.Rows[start[1]]-start[2]) * width, height)
						elseif i == stop[1] then
							surface_DrawRect(xofs + (self.Scroll[2]-1) * width, (self:GetRowOffset(i)-self.Scroll[1]) * height, (#self.Rows[stop[1]]-stop[2]) * width, height)
						else
							surface_DrawRect(xofs + (self.Scroll[2]-1) * width, (self:GetRowOffset(i)-self.Scroll[1]) * height, #self.Rows[i] * width, height)
						end
					end
				end
			end
		end
	end
	self:DoAction("PaintTextOverlay")
end
local prevScroll = 1
function PANEL:Paint()
	self.LineNumberWidth = self.FontWidth * math.max(#tostring(self.Scroll[1] + self.Size[1] + 1),3) + 20

	if not input.IsMouseDown(MOUSE_LEFT) then
		self:OnMouseReleased(MOUSE_LEFT)
	end

	if self.MouseDown then
		self.Caret = self:CursorToCaret()
	end


	surface_SetDrawColor(colors.gutter_background)
	surface_DrawRect(0, 0, self.LineNumberWidth + 4, self:GetTall())

	surface_SetDrawColor(colors.gutter_divider)
	surface_DrawRect(self.LineNumberWidth + 4, 0, 1, self:GetTall())

	surface_SetDrawColor(colors.background)
	surface_DrawRect(self.LineNumberWidth + 5, 0, self:GetWide() - (self.LineNumberWidth + 5), self:GetTall())

	if TabHandler.HtmlBackground then
		surface_SetMaterial(TabHandler.HtmlBackgroundMaterial)
		surface_SetDrawColor(Color(255,255,255,TabHandler.HtmlBackgroundOpacityConvar:GetInt()))
		surface_DrawTexturedRect(self.LineNumberWidth + 5, 0, self:GetWide() - (self.LineNumberWidth + 5), self:GetTall())
	end

	local scr  = math_floor(self.ScrollBar:GetScroll() + 1)
	if scr ~= prevScroll then
		local cScroll = 0

		for k,v in ipairs(self.Rows) do
			if not v[3] then
				cScroll = cScroll + 1
			end
			if scr == cScroll then
				self.Scroll[1] = k
				break
			end
		end
	end
	prevScroll = scr

	--self.Scroll[1] = self:GetRowOffset(self.Scroll[1])
	local i = self.Scroll[1]
	local drawn = 0
	local offset = 0
	local lines =  #self.Rows
	while drawn < self.Size[1] + 4 do
		if i > lines then break end
		if self.Rows[i][3] then
			i = i + 1
			offset = offset + 1
			continue
		end
		self.RealLine[drawn] = i
		self.RowOffset[i] = offset
		self:PaintLine(i,drawn)
		drawn = drawn + 1
		i = i+1
	end

	-- Paint the overlay of the text (bracket highlighting and carret postition)
	self:PaintTextOverlay()

	if TabHandler.DisplayCaretPosConVar:GetBool() then
		local str = "Length: " .. #self.Rows .. " Lines: " ..lines .. " Ln: " .. self.Caret[1] .. " Col: " .. self.Caret[2].." Visible Rows:"..self.VisibleRows
		if self:HasSelection() then
			str = str .. " Sel: " .. #self:GetSelection()
		end
		surface_SetFont("Default")
		local w, h = surface_GetTextSize(str)
		local _w, _h = self:GetSize()
		draw_WordBox(4, _w - w - (self.ScrollBar:IsVisible() and 16 or 0) - 10, _h - h - 10, str, "Default", Color(0, 0, 0, 100), Color(255, 255, 255, 255))
	end

	self:DoAction("Paint")

	return true
end

-- Moves the caret to a new position. Optionally also collapses the selection
-- into a single caret. If maintain_selection is nil, then the selection will
-- be maintained only if Shift is pressed.
function PANEL:SetCaret(caret, maintain_selection)
	self.Caret = self:CopyPosition(caret)
	local rowNum = #self.Rows
	self.Caret[1] = math.Clamp(self.Caret[1], 1, rowNum)
	self.Caret[2] = math.Clamp(self.Caret[2], 1, #self:GetRowText(self.Caret[1]) + 1)

	if maintain_selection == nil then
		maintain_selection = input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT)
	end

	if not maintain_selection then
		self.Start = self:CopyPosition(self.Caret)
	end

	self:ScrollCaret()
end

function PANEL:CopyPosition(caret)
	return { caret[1], caret[2] }
end

function PANEL:MovePosition(caret, offset)
	local row, col = caret[1], caret[2]
	if offset > 0 then
		local numRows = #self.Rows
		while true do
			local length = #(self:GetRowText(row)) - col + 2
			if self.Rows[row][3] then
				offset = offset - length
				row = row + 1
				col = 1
			elseif offset < length then
				col = col + offset
				break
			elseif row >= numRows then
				break
			else
				offset = offset - length
				row = row + 1
				col = 1
			end
		end
	elseif offset < 0 then
		offset = -offset

		while true and row >= 1 do
			if self.Rows[row] and self.Rows[row][3] then
				offset = offset - col
				row = row - 1
				col = #(self:GetRowText(row)) + 1
			elseif offset < col then
				col = col - offset
				break
			elseif row == 1 then
				col = 1
				break
			else
				offset = offset - col
				row = row - 1
				col = #(self:GetRowText(row)) + 1
			end
		end
	end

	return { row, col }
end

function PANEL:HasSelection()
	return self.Caret[1] ~= self.Start[1] or self.Caret[2] ~= self.Start[2]
end

function PANEL:Selection()
	return { { self.Caret[1], self.Caret[2] }, { self.Start[1], self.Start[2] } }
end

function PANEL:MakeSelection(selection)
	local start, stop = selection[1], selection[2]

	if start[1] < stop[1] or (start[1] == stop[1] and start[2] < stop[2]) then
		return start, stop
	else
		return stop, start
	end
end

function PANEL:GetArea(selection)
	local start, stop = self:MakeSelection(selection)

	if start[1] == stop[1] then
		return string_sub(self:GetRowText(start[1]), start[2], stop[2] - 1)
	else
		local text = string_sub(self:GetRowText(start[1]), start[2])

		for i = start[1] + 1, stop[1]-1 do
			text = text .. "\n" .. self:GetRowText(i)
		end

		return text .. "\n" .. string_sub(self:GetRowText(stop[1]), 1, stop[2] - 1)
	end
end
function PANEL:RecacheLine(line)
	local rows = #self.Rows
	if line > rows then return end
	while self.Rows[line][2] and self.Rows[line][2]["unfinished"] do
		self.Rows[line][2] = false
		line = line + 1
		if line > rows then return end
	end
	self.Rows[line][2] = false
end
function PANEL:SetArea(selection, text, isundo, isredo, before, after)
	text = string_gsub(text or "", "\r", "")
	local start, stop = self:MakeSelection(selection)

	local buffer = self:GetArea(selection)
	if start[1] ~= stop[1] or start[2] ~= stop[2] then
		self:SetRowText(start[1], string_sub(self:GetRowText(start[1]), 1, start[2] - 1) .. string_sub(self:GetRowText(stop[1]), stop[2]))
		self:RecacheLine(start[1])

		for i = start[1] + 1, stop[1] do
			self:UnfoldHidden(i)
			self:RemoveRowAt(start[1] + 1)
			self.VisibleRows = self.VisibleRows - 1
		end
	end

	if not text or text == "" then
		self:UnfoldHidden(start[1])

		if isredo then
			self.Undo[#self.Undo + 1] = { { self:CopyPosition(start), self:CopyPosition(start) }, buffer, after, before }
			return before
		elseif isundo then
			self.Redo[#self.Redo + 1] = { { self:CopyPosition(start), self:CopyPosition(start) }, buffer, after, before }
			return before
		else
			self.Redo = {}
			self.Undo[#self.Undo + 1] = { { self:CopyPosition(start), self:CopyPosition(start) }, buffer, self:CopyPosition(selection[1]), self:CopyPosition(start) }
			return start
		end
	end
	-- insert text
	local rows = string_Explode("\n", text)

	local remainder = string_sub(self:GetRowText(start[1]), start[2])
	self:SetRowText(start[1], string_sub(self:GetRowText(start[1]), 1, start[2] - 1) .. rows[1])
	self:RecacheLine(start[1])

	for i = 2, #rows do
		self:InsertRowAt(start[1] + i - 1, rows[i])

	end

	stop = { start[1] + #rows - 1, #(self:GetRowText(start[1] + #rows - 1)) + 1 }

	self:SetRowText(stop[1],self:GetRowText(stop[1]) .. remainder)
	self:RecacheLine(stop[1])

	if isredo then
		self.Undo[#self.Undo + 1] = { { self:CopyPosition(start), self:CopyPosition(stop) }, buffer, after, before }
		return before
	elseif isundo then
		self.Redo[#self.Redo + 1] = { { self:CopyPosition(start), self:CopyPosition(stop) }, buffer, after, before }
		return before
	else
		self.Redo = {}
		self.Undo[#self.Undo + 1] = { { self:CopyPosition(start), self:CopyPosition(stop) }, buffer, self:CopyPosition(selection[1]), self:CopyPosition(stop) }
		return stop
	end
end

function PANEL:GetSelection()
	return self:GetArea(self:Selection())
end

function PANEL:SetSelection(text)
	self:SetCaret(self:SetArea(self:Selection(), text), false)
end

function PANEL:_OnLoseFocus()
	if self.TabFocus then
		self:RequestFocus()
		self.TabFocus = nil
	end
end

-- removes the first 0-4 spaces from a string and returns it
local function unindent(line)
	--local i = line:find("%S")
	--if i == nil or i > 5 then i = 5 end
	--return line:sub(i)
	return line:match("^ ? ? ? ?(.*)$")
end

function PANEL:_OnTextChanged()
	local ctrlv = false
	local text = self.TextEntry:GetText()
	self.TextEntry:SetText("")

	local unIndentedLast = self.justUnIndented
	self.justUnIndented = nil

	if (input.IsKeyDown(KEY_LCONTROL) or input.IsKeyDown(KEY_RCONTROL)) and not (input.IsKeyDown(KEY_LALT) or input.IsKeyDown(KEY_RALT)) then
		-- ctrl+[shift+]key
		if input.IsKeyDown(KEY_V) then
			-- ctrl+[shift+]V
			ctrlv = true

			if self.lastEmptySelectionCopy
				and text == string_gsub(self.lastEmptySelectionCopy, "\r\n", "\n")
				and self.Caret[1] == self.Start[1]
				and self.Caret[2] == self.Start[2]  then
				self.Caret[2] = 1
				self.Start = self:CopyPosition(self.Caret)
			end
		else
			-- ctrl+[shift+]key with key ~= V
			return
		end
	end

	if text == "" then return end
	if not ctrlv then
		if text == "\n" or text == "`" then return end
		if TabHandler.AutoIndentConVar:GetBool() then
			local row = self:GetRowText(self.Caret[1])

			local function doIndent(shift)
				local caret = self:Selection()[1]
				self:Indent(shift)
				self.Caret = caret
				self.Caret[2] = #self:GetRowText(caret[1]) + 1
				self.Start[2] = self.Caret[2]
			end

			if text == "}" then
				-- un-indent on }
				self:SetSelection(text)
				if string.match(row,"^%s*$") then
					doIndent(true)
				end
				return
			else
				local unIndentOn = {"end","else","elseif","until"}
				local rowText = row..text
				-- un-indent if the user types one of these four things
				for i=1,#unIndentOn do
					if string.match(rowText, "^%s*" .. unIndentOn[i] .. "$") then
						self:SetSelection(text)
						doIndent(true)
						self.justUnIndented = {self.Caret[1],self.Caret[2]}
						return
					end
				end
				if unIndentedLast and
				   unIndentedLast[1] == self.Caret[1] and 
				   unIndentedLast[2] == self.Caret[2] and 
				   string.match(text,"[%s%(%)]") == nil then
					-- re-indent if the user types something else after those four things, but not if that's a space character or a '(' character
					self:SetSelection(text)
					doIndent(false)
					return
				end
			end
		end
	end

	self:SetSelection(text)
	if not ctrlv and TabHandler.ACAuto:GetBool() then
		self:AutocompleteOpen()
	end

	if self.OnTextChanged then self:OnTextChanged() end
end

function PANEL:OnMouseWheeled(delta)
	if self.acPanel and self.acPanel:IsVisible() then
		self.acPanel:RequestFocus()
		return
	end

	self.ScrollBar:OnMouseWheeled(delta/self.Size[1] * TabHandler.ScrollSpeedConVar:GetFloat())
end

function PANEL:OnShortcut()
end

function PANEL:ScrollCaret()
	local visCaret = self.Caret[1] - self:GetRowOffset(self.Caret[1])
	if visCaret - self.Scroll[1] < 3 then
		local line = self.Caret[1]-3
		while line > 1 and (self.Rows[line][3] or visCaret-line < 3)  do
			line = line - 1
		end
		self.ScrollBar:SetScrollFix(math.max(line,1))
	end
	if visCaret - self.Scroll[1] > self.Size[1] - 2 then
		local line = self.Scroll[1]
		local lines = #self.Rows
		while line <= lines and (self.Rows[line][3] or visCaret - line > self.Size[1] - 2) do
			line = line + 1
		end
		self.ScrollBar:SetScrollFix(math.max(line,1))
	end


	if self.Caret[2] - self.Scroll[2] < 4 then
		self.Scroll[2] = self.Caret[2] - 4
		if self.Scroll[2] < 1 then self.Scroll[2] = 1 end
	end

	if self.Caret[2] - 1 - self.Scroll[2] > self.Size[2] - 4 then
		self.Scroll[2] = self.Caret[2] - 1 - self.Size[2] + 4
		if self.Scroll[2] < 1 then self.Scroll[2] = 1 end
	end


end

-- Initialize find settings
local wire_expression2_editor_find_use_patterns = CreateClientConVar("wire_expression2_editor_find_use_patterns", "0", true, false)
local wire_expression2_editor_find_ignore_case = CreateClientConVar("wire_expression2_editor_find_ignore_case", "0", true, false)
local wire_expression2_editor_find_whole_word_only = CreateClientConVar("wire_expression2_editor_find_whole_word_only", "0", true, false)
local wire_expression2_editor_find_wrap_around = CreateClientConVar("wire_expression2_editor_find_wrap_around", "0", true, false)
local wire_expression2_editor_find_dir = CreateClientConVar("wire_expression2_editor_find_dir", "1", true, false)

function PANEL:HighlightFoundWord(caretstart, start, stop)
	caretstart = caretstart or self:CopyPosition(self.Start)
	if istable(start) then
		self.Start = self:CopyPosition(start)
	elseif isnumber(start) then
		self.Start = self:MovePosition(caretstart, start)
	end
	if istable(stop) then
		self.Caret = { stop[1], stop[2] + 1 }
	elseif isnumber(stop) then
		self.Caret = self:MovePosition(caretstart, stop + 1)
	end
	self:UnfoldHidden(self.Caret[1])
	self:ScrollCaret()
end

function PANEL:Find(str, looped)
	if looped and looped >= 2 then return end
	if str == "" then return end
	local _str = str

	local use_patterns = wire_expression2_editor_find_use_patterns:GetBool()
	local ignore_case = wire_expression2_editor_find_ignore_case:GetBool()
	local whole_word_only = wire_expression2_editor_find_whole_word_only:GetBool()
	local wrap_around = wire_expression2_editor_find_wrap_around:GetBool()
	local dir = wire_expression2_editor_find_dir:GetBool()

	-- Check if the match exists anywhere at all
	local temptext = self:GetCode()
	if ignore_case then
		temptext = temptext:lower()
		str = str:lower()
	end
	local _start, _stop = temptext:find(str, 1, not use_patterns)
	if not _start or not _stop then return false end

	if dir then -- Down
		local line = self:GetRowText(self.Start[1])
		local text = line:sub(self.Start[2]) .. "\n"
		text = text .. self:GetLinesAsText(self.Start[1] + 1)
 		if ignore_case then text = text:lower() end
 
		if not use_patterns then
			str = string.PatternSafe(str)
		end
 
		if whole_word_only then
			str = "%f[%w_]" .. str .. "%f[^%w_]"
		end

		local start, stop = text:find(str, 2)
		if start and stop then
 			self:HighlightFoundWord(nil, start - 1, stop - 1)
 			return true
 		end
 
 		if wrap_around then
 			self:SetCaret({1, 1}, false)
			return self:Find(_str, (looped or 0) + 1)
 		end

		return false
 	else -- Up
		local text = self:GetLinesAsText(1, self.Start[1]-1)
		local line = self:GetRowText(self.Start[1])
		text = text .. "\n" .. line:sub(1, self.Start[2]-1)

		str = string_reverse(str)
		text = string_reverse(text)

 		if ignore_case then text = text:lower() end
 
		if not use_patterns then
			str = string.PatternSafe(str)
		end
 
 		if whole_word_only then
			str = "%f[%w_]" .. str .. "%f[^%w_]"
 		end

		local start, stop = text:find(str, 2)
		if start and stop then
 			self:HighlightFoundWord( nil, -(start-1), -(stop+1) )
 			return true
 		end
 
 		if wrap_around then
 			self:SetCaret( { #self.Rows,#self.Rows[#self.Rows] }, false )
			return self:Find( _str, (looped or 0) + 1 )
 		end

 		return false
 	end
end

function PANEL:Replace(str, replacewith)
	if str == "" or str == replacewith then return end

	local use_patterns = wire_expression2_editor_find_use_patterns:GetBool()

	local selection = self:GetSelection()

	local _str = str
	if not use_patterns then
		str = string.PatternSafe(str)
	end

	if selection:match(str) ~= nil then
		self:SetSelection(selection:gsub(str, replacewith))
		return self:Find(_str)
	else
		return self:Find(_str)
	end
end

function PANEL:ReplaceAll(str, replacewith)
	if str == "" then return end

	local whole_word_only = wire_expression2_editor_find_whole_word_only:GetBool()
	local ignore_case = wire_expression2_editor_find_ignore_case:GetBool()
	local use_patterns = wire_expression2_editor_find_use_patterns:GetBool()

	if not use_patterns then
		str = string.PatternSafe(str)
		if ignore_case then
			str = str:lower()
		end
	end

	local pattern
	if whole_word_only then
		pattern = "%f[%w_]()" .. str .. "%f[^%w_]()"
	else
		pattern = "()" .. str .. "()"
	end

	local txt = self:GetCode()

	if ignore_case then
		local txt2 = txt -- Store original cased copy
		txt = txt:lower() -- Lowercase everything

		local positions = {}

		for startpos, endpos in string_gmatch(txt, pattern) do
			positions[#positions + 1] = { startpos, endpos }
		end

		-- Do the replacing backwards, or it won't work
		for i = #positions, 1, -1 do
			local startpos, endpos = positions[i][1], positions[i][2]
			txt2 = string_sub(txt2, 1, startpos-1) .. replacewith .. string_sub(txt2, endpos)
		end

		-- Replace everything with the edited copy
		self:SelectAll()
		self:SetSelection(txt2)
	else
		txt = string_gsub( txt, pattern, replacewith )

		self:SelectAll()
		self:SetSelection(txt)
	end
end

function PANEL:CountFinds(str)
	if str == "" then return 0 end

	local whole_word_only = wire_expression2_editor_find_whole_word_only:GetBool()
	local ignore_case = wire_expression2_editor_find_ignore_case:GetBool()
	local use_patterns = wire_expression2_editor_find_use_patterns:GetBool()

	if not use_patterns then
		str = string.PatternSafe(str)
	end

	local txt = self:GetCode()

	if ignore_case then
		txt = txt:lower()
		str = str:lower()
	end

	if whole_word_only then
		str = "%f[%w_]()" .. str .. "%f[^%w_]()"
	end

	return select(2, string_gsub(txt, str, ""))
end

function PANEL:FindAllWords(str)
	if str == "" then return end

	local txt = self:GetCode()
	-- %f[set] is a 'frontier' pattern - it matches an empty string at a position such that the
	-- next character belongs to set and the previous character does not belong to set.
	-- The beginning and the end of the string are handled as if they were the character '\0'.
	-- As a special case, the empty capture () captures the current string position (a number).
	--   - https://www.lua.org/manual/5.3/manual.html#6.4.1
	local pattern = "%f[%w_]()" .. string.PatternSafe(str) .. "%f[^%w_]()"

	local ret = {}
	for start, stop in txt:gmatch(pattern) do
		ret[#ret + 1] = { start, stop }
	end

	return ret
end

function PANEL:CreateFindWindow()
	self.FindWindow = vgui.Create("DFrame", self)

	local pnl = self.FindWindow
	pnl:SetSize(322, 201)
	pnl:ShowCloseButton(true)
	pnl:SetDeleteOnClose(false) -- No need to create a new window every time
	pnl:MakePopup() -- Make it separate from the editor itself
	pnl:SetVisible(false) -- but hide it for now
	pnl:SetTitle("Find")
	pnl:SetScreenLock(true)

	local old = pnl.Close
	function pnl.Close()
		self.ForceDrawCursor = false
		old(pnl)
	end

	-- Center it above the editor
	local x, y = self:GetParent():GetPos()
	local w, h = self:GetSize()
	pnl:SetPos(x + w / 2-150, y + h / 2-100)

	pnl.TabHolder = vgui.Create("DPropertySheet", pnl)
	pnl.TabHolder:StretchToParent(1, 23, 1, 1)

	-- Options
	local common_panel = vgui.Create("DPanel", pnl)
	common_panel:SetSize(225, 60)
	common_panel:SetPos(10, 130)
	common_panel.Paint = function()
		local w, h = common_panel:GetSize()
		draw_RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 150))
	end

	local use_patterns = vgui.Create("DCheckBoxLabel", common_panel)
	use_patterns:SetText("Use Patterns")
	use_patterns:SetToolTip("Use/Don't use Lua patterns in the find.")
	use_patterns:SizeToContents()
	use_patterns:SetConVar("wire_expression2_editor_find_use_patterns")
	use_patterns:SetPos(4, 4)
	local old = use_patterns.Button.SetValue
	use_patterns.Button.SetValue = function(pnl, b)
		if wire_expression2_editor_find_whole_word_only:GetBool() then return end
		old(pnl, b)
	end

	local case_sens = vgui.Create("DCheckBoxLabel", common_panel)
	case_sens:SetText("Ignore Case")
	case_sens:SetToolTip("Ignore/Don't ignore case in the find.")
	case_sens:SizeToContents()
	case_sens:SetConVar("wire_expression2_editor_find_ignore_case")
	case_sens:SetPos(4, 24)

	local whole_word = vgui.Create("DCheckBoxLabel", common_panel)
	whole_word:SetText("Match Whole Word")
	whole_word:SetToolTip("Match/Don't match the entire word in the find.")
	whole_word:SizeToContents()
	whole_word:SetConVar("wire_expression2_editor_find_whole_word_only")
	whole_word:SetPos(4, 44)
	local old = whole_word.Button.Toggle
	whole_word.Button.Toggle = function(pnl)
		old(pnl)
		if pnl:GetValue() then use_patterns:SetValue(false) end
	end

	local wrap_around = vgui.Create("DCheckBoxLabel", common_panel)
	wrap_around:SetText("Wrap Around")
	wrap_around:SetToolTip("Start/Don't start from the top after reaching the bottom, or the bottom after reaching the top.")
	wrap_around:SizeToContents()
	wrap_around:SetConVar("wire_expression2_editor_find_wrap_around")
	wrap_around:SetPos(130, 4)

	local dir_down = vgui.Create("DCheckBoxLabel", common_panel)
	local dir_up = vgui.Create("DCheckBoxLabel", common_panel)

	dir_up:SetText("Up")
	dir_up:SizeToContents()
	dir_up:SetPos(130, 24)
	dir_up:SetTooltip("Note: Most patterns won't work when searching up because the search function reverses the string to search backwards.")
	dir_up:SetValue(not wire_expression2_editor_find_dir:GetBool())
	dir_down:SetText("Down")
	dir_down:SizeToContents()
	dir_down:SetPos(130, 44)
	dir_down:SetValue(wire_expression2_editor_find_dir:GetBool())

	function dir_up.Button:Toggle()
		dir_up:SetValue(true)
		dir_down:SetValue(false)
		RunConsoleCommand("wire_expression2_editor_find_dir", "0")
	end
	function dir_down.Button:Toggle()
		dir_down:SetValue(true)
		dir_up:SetValue(false)
		RunConsoleCommand("wire_expression2_editor_find_dir", "1")
	end

	-- Find tab
	local findtab = vgui.Create("DPanel")

	-- Label
	local FindLabel = vgui.Create("DLabel", findtab)
	FindLabel:SetText("Find:")
	FindLabel:SetPos(4, 4)
	FindLabel:SetTextColor(Color(0, 0, 0, 255))

	-- Text entry
	local FindEntry = vgui.Create("DTextEntry", findtab)
	FindEntry:SetPos(30, 4)
	FindEntry:SetSize(200, 20)
	FindEntry:RequestFocus()
	FindEntry.OnEnter = function(pnl)
		self:Find(pnl:GetValue())
		pnl:RequestFocus()
	end

	-- Find next button
	local FindNext = vgui.Create("DButton", findtab)
	FindNext:SetText("Find Next")
	FindNext:SetToolTip("Find the next match and highlight it.")
	FindNext:SetPos(233, 4)
	FindNext:SetSize(70, 20)
	FindNext.DoClick = function(pnl)
		self:Find(FindEntry:GetValue())
	end

	-- Find button
	local Find = vgui.Create("DButton", findtab)
	Find:SetText("Find")
	Find:SetToolTip("Find the next match, highlight it, and close the Find window.")
	Find:SetPos(233, 29)
	Find:SetSize(70, 20)
	Find.DoClick = function(pnl)
		self.FindWindow:Close()
		self:Find(FindEntry:GetValue())
	end

	-- Count button
	local Count = vgui.Create("DButton", findtab)
	Count:SetText("Count")
	Count:SetPos(233, 95)
	Count:SetSize(70, 20)
	Count:SetTooltip("Count the number of matches in the file.")
	Count.DoClick = function(pnl)
		Derma_Message(self:CountFinds(FindEntry:GetValue()) .. " matches found.", "", "Ok")
	end

	-- Cancel button
	local Cancel = vgui.Create("DButton", findtab)
	Cancel:SetText("Cancel")
	Cancel:SetPos(233, 120)
	Cancel:SetSize(70, 20)
	Cancel.DoClick = function(pnl)
		self.FindWindow:Close()
	end

	pnl.FindTab = pnl.TabHolder:AddSheet("Find", findtab, "icon16/page_white_find.png", false, false)
	pnl.FindTab.Entry = FindEntry

	-- Replace tab
	local replacetab = vgui.Create("DPanel")

	-- Label
	local FindLabel = vgui.Create("DLabel", replacetab)
	FindLabel:SetText("Find:")
	FindLabel:SetPos(4, 4)
	FindLabel:SetTextColor(Color(0, 0, 0, 255))

	-- Text entry
	local FindEntry = vgui.Create("DTextEntry", replacetab)
	local ReplaceEntry
	FindEntry:SetPos(30, 4)
	FindEntry:SetSize(200, 20)
	FindEntry:RequestFocus()
	FindEntry.OnEnter = function(pnl)
		self:Replace(pnl:GetValue(), ReplaceEntry:GetValue())
		ReplaceEntry:RequestFocus()
	end

	-- Label
	local ReplaceLabel = vgui.Create("DLabel", replacetab)
	ReplaceLabel:SetText("Replace With:")
	ReplaceLabel:SetPos(4, 32)
	ReplaceLabel:SizeToContents()
	ReplaceLabel:SetTextColor(Color(0, 0, 0, 255))

	-- Replace entry
	ReplaceEntry = vgui.Create("DTextEntry", replacetab)
	ReplaceEntry:SetPos(75, 29)
	ReplaceEntry:SetSize(155, 20)
	ReplaceEntry:RequestFocus()
	ReplaceEntry.OnEnter = function(pnl)
		self:Replace(FindEntry:GetValue(), pnl:GetValue())
		pnl:RequestFocus()
	end

	-- Find next button
	local FindNext = vgui.Create("DButton", replacetab)
	FindNext:SetText("Find Next")
	FindNext:SetToolTip("Find the next match and highlight it.")
	FindNext:SetPos(233, 4)
	FindNext:SetSize(70, 20)
	FindNext.DoClick = function(pnl)
		self:Find(FindEntry:GetValue())
	end

	-- Replace next button
	local ReplaceNext = vgui.Create("DButton", replacetab)
	ReplaceNext:SetText("Replace")
	ReplaceNext:SetToolTip("Replace the current selection if it matches, else find the next match.")
	ReplaceNext:SetPos(233, 29)
	ReplaceNext:SetSize(70, 20)
	ReplaceNext.DoClick = function(pnl)
		self:Replace(FindEntry:GetValue(), ReplaceEntry:GetValue())
	end

	-- Replace all button
	local ReplaceAll = vgui.Create("DButton", replacetab)
	ReplaceAll:SetText("Replace All")
	ReplaceAll:SetToolTip("Replace all occurences of the match in the entire file, and close the Find window.")
	ReplaceAll:SetPos(233, 54)
	ReplaceAll:SetSize(70, 20)
	ReplaceAll.DoClick = function(pnl)
		self.FindWindow:Close()
		self:ReplaceAll(FindEntry:GetValue(), ReplaceEntry:GetValue())
	end

	-- Count button
	local Count = vgui.Create("DButton", replacetab)
	Count:SetText("Count")
	Count:SetPos(233, 95)
	Count:SetSize(70, 20)
	Count:SetTooltip("Count the number of matches in the file.")
	Count.DoClick = function(pnl)
		Derma_Message(self:CountFinds(FindEntry:GetValue()) .. " matches found.", "", "Ok")
	end

	-- Cancel button
	local Cancel = vgui.Create("DButton", replacetab)
	Cancel:SetText("Cancel")
	Cancel:SetPos(233, 120)
	Cancel:SetSize(70, 20)
	Cancel.DoClick = function(pnl)
		self.FindWindow:Close()
	end

	pnl.ReplaceTab = pnl.TabHolder:AddSheet("Replace", replacetab, "icon16/page_white_wrench.png", false, false)
	pnl.ReplaceTab.Entry = FindEntry

	-- Go to line tab
	local gototab = vgui.Create("DPanel")

	-- Label
	local GotoLabel = vgui.Create("DLabel", gototab)
	GotoLabel:SetText("Go to Line:")
	GotoLabel:SetPos(4, 4)
	GotoLabel:SetTextColor(Color(0, 0, 0, 255))

	-- Text entry
	local GoToEntry = vgui.Create("DTextEntry", gototab)
	GoToEntry:SetPos(57, 4)
	GoToEntry:SetSize(173, 20)
	GoToEntry:SetNumeric(true)

	-- Goto Button
	local Goto = vgui.Create("DButton", gototab)
	Goto:SetText("Go to Line")
	Goto:SetPos(233, 4)
	Goto:SetSize(70, 20)

	-- Action
	local function GoToAction(panel)
		local val = tonumber(GoToEntry:GetValue())
		if val then
			val = math_Clamp(val, 1, #self.Rows)
			self:SetCaret({ val, #self:GetRowText(val) + 1 }, false)
		end
		GoToEntry:SetText(tostring(val))
		self.FindWindow:Close()
	end
	GoToEntry.OnEnter = GoToAction
	Goto.DoClick = GoToAction

	pnl.GoToLineTab = pnl.TabHolder:AddSheet("Go to Line", gototab, "icon16/page_white_go.png", false, false)
	pnl.GoToLineTab.Entry = GoToEntry

	-- Tab buttons
	local old = pnl.FindTab.Tab.OnMousePressed
	pnl.FindTab.Tab.OnMousePressed = function(...)
		pnl.FindTab.Entry:SetText(pnl.ReplaceTab.Entry:GetValue() or "")
		local active = pnl.TabHolder:GetActiveTab()
		if active == pnl.GoToLineTab.Tab then
			pnl:SetHeight(200)
			pnl.TabHolder:StretchToParent(1, 23, 1, 1)
		end
		old(...)
	end

	local old = pnl.ReplaceTab.Tab.OnMousePressed
	pnl.ReplaceTab.Tab.OnMousePressed = function(...)
		pnl.ReplaceTab.Entry:SetText(pnl.FindTab.Entry:GetValue() or "")
		local active = pnl.TabHolder:GetActiveTab()
		if active == pnl.GoToLineTab.Tab then
			pnl:SetHeight(200)
			pnl.TabHolder:StretchToParent(1, 23, 1, 1)
		end
		old(...)
	end

	local old = pnl.GoToLineTab.Tab.OnMousePressed
	pnl.GoToLineTab.Tab.OnMousePressed = function(...)
		pnl:SetHeight(86)
		pnl.TabHolder:StretchToParent(1, 23, 1, 1)
		pnl.GoToLineTab.Entry:SetText(self.Caret[1])
		old(...)
	end
end

function PANEL:OpenFindWindow(mode)
	if not self.FindWindow then self:CreateFindWindow() end
	self.FindWindow:SetVisible(true)
	self.FindWindow:MakePopup() -- This will move it above the E2 editor if it is behind it.
	self.ForceDrawCursor = true

	local selection = self:GetSelection():Left(100)

	if mode == "find" then
		if selection and selection ~= "" then self.FindWindow.FindTab.Entry:SetText(selection) end
		self.FindWindow.TabHolder:SetActiveTab(self.FindWindow.FindTab.Tab)
		self.FindWindow.FindTab.Entry:RequestFocus()
		self.FindWindow:SetHeight(201)
		self.FindWindow.TabHolder:StretchToParent(1, 23, 1, 1)
	elseif mode == "find and replace" then
		if selection and selection ~= "" then self.FindWindow.ReplaceTab.Entry:SetText(selection) end
		self.FindWindow.TabHolder:SetActiveTab(self.FindWindow.ReplaceTab.Tab)
		self.FindWindow.ReplaceTab.Entry:RequestFocus()
		self.FindWindow:SetHeight(201)
		self.FindWindow.TabHolder:StretchToParent(1, 23, 1, 1)
	elseif mode == "go to line" then
		self.FindWindow.TabHolder:SetActiveTab(self.FindWindow.GoToLineTab.Tab)
		local caretPos = self.Caret[1]
		self.FindWindow.GoToLineTab.Entry:SetText(caretPos)
		self.FindWindow.GoToLineTab.Entry:RequestFocus()
		self.FindWindow.GoToLineTab.Entry:SelectAllText()
		self.FindWindow.GoToLineTab.Entry:SetCaretPos(tostring(caretPos):len())
		self.FindWindow:SetHeight(83)
		self.FindWindow.TabHolder:StretchToParent(1, 23, 1, 1)
	end
end

function PANEL:CanUndo()
	return #self.Undo > 0
end

function PANEL:DoUndo()
	if #self.Undo > 0 then
		local undo = self.Undo[#self.Undo]
		self.Undo[#self.Undo] = nil

		self:SetCaret(self:SetArea(undo[1], undo[2], true, false, undo[3], undo[4]), false)
		
		if self.OnTextChanged then self:OnTextChanged() end
	end
end

function PANEL:CanRedo()
	return #self.Redo > 0
end

function PANEL:DoRedo()
	if #self.Redo > 0 then
		local redo = self.Redo[#self.Redo]
		self.Redo[#self.Redo] = nil

		self:SetCaret(self:SetArea(redo[1], redo[2], false, true, redo[3], redo[4]), false)
		if self.OnTextChanged then self:OnTextChanged() end
	end
end

function PANEL:SelectAll()
	self.Caret = { #self.Rows, #(self:GetRowText(#self.Rows)) + 1 }
	self.Start = { 1, 1 }
	self:ScrollCaret()
end

function PANEL:PasteCode(code)
	local tab_scroll = self:CopyPosition(self.Scroll)
	local tab_start, tab_caret = self:MakeSelection(self:Selection())
	self:SetSelection(code)

	self.Scroll = self:CopyPosition(tab_scroll)
	-- trigger scroll bar update (TODO: find a better way)
	self:ScrollCaret()
end

function PANEL:Indent(shift)
	-- TAB with a selection --
	-- remember scroll position
	local tab_scroll = self:CopyPosition(self.Scroll)

	-- normalize selection, so it spans whole lines
	local tab_start, tab_caret = self:MakeSelection(self:Selection())
	tab_start[2] = 1

	if tab_caret[2] ~= 1 then
		tab_caret[1] = tab_caret[1] + 1
		tab_caret[2] = 1
	end

	-- remember selection
	self.Caret = self:CopyPosition(tab_caret)
	self.Start = self:CopyPosition(tab_start)
	-- (temporarily) adjust selection, so there is no empty line at its end.
	if self.Caret[2] == 1 then
		self.Caret = self:MovePosition(self.Caret, -1)
	end
	if shift then
		-- shift-TAB with a selection --
		local tmp = self:GetSelection():gsub("\n ? ? ? ?", "\n")

		-- makes sure that the first line is outdented
		self:SetSelection(unindent(tmp))
	else
		-- plain TAB with a selection --
		self:SetSelection("    " .. self:GetSelection():gsub("\n", "\n    "))
	end
	-- restore selection
	self.Caret = self:CopyPosition(tab_caret)
	self.Start = self:CopyPosition(tab_start)
	-- restore scroll position
	self.Scroll = self:CopyPosition(tab_scroll)
	-- trigger scroll bar update (TODO: find a better way)
	self:ScrollCaret()
end

-- Comment the currently selected area
function PANEL:BlockCommentSelection(removecomment)
	if not self:HasSelection() then return end

	local scroll = self:CopyPosition(self.Scroll)

	local new_selection = self:DoAction("BlockCommentSelection", removecomment)
	if not new_selection then return end

	self.Start, self.Caret = self:MakeSelection(new_selection)
	-- restore scroll position
	self.Scroll = scroll
	-- trigger scroll bar update (TODO: find a better way)
	self:ScrollCaret()
end

-- CommentSelection
-- Idea by Jeremydeath
-- Rewritten by Divran to use block comment
function PANEL:CommentSelection(removecomment)
	if not self:HasSelection() then return end

	-- Remember scroll position
	local scroll = self:CopyPosition(self.Scroll)

	-- Normalize selection, so it spans whole lines
	local sel_start, sel_caret = self:MakeSelection(self:Selection())
	sel_start[2] = 1

	if sel_caret[2] ~= 1 then
		sel_caret[1] = sel_caret[1] + 1
		sel_caret[2] = 1
	end

	-- Remember selection
	self.Caret = self:CopyPosition(sel_caret)
	self.Start = self:CopyPosition(sel_start)
	-- (temporarily) adjust selection, so there is no empty line at its end.
	if self.Caret[2] == 1 then
		self.Caret = self:MovePosition(self.Caret, -1)
	end
	local new_selection = self:DoAction("CommentSelection", removecomment)
	if not new_selection then return end

	self.Start, self.Caret = self:MakeSelection(new_selection)

	-- restore scroll position
	self.Scroll = scroll
	-- trigger scroll bar update (TODO: find a better way)
	self:ScrollCaret()
end

function PANEL:ContextHelp()
	local word
	if self:HasSelection() then
		word = self:GetSelection()
	else
		local row, col = unpack(self.Caret)
		local line = self:GetRowText(row)
		if not line:sub(col, col):match("^[a-zA-Z0-9_]$") then
			col = col - 1
		end
		if not line:sub(col, col):match("^[a-zA-Z0-9_]$") then
			surface_PlaySound("buttons/button19.wav")
			return
		end

		-- TODO substitute this for getWordStart, if it fits.
		local startcol = col
		while startcol > 1 and line:sub(startcol-1, startcol-1):match("^[a-zA-Z0-9_]$") do
			startcol = startcol - 1
		end

		-- TODO substitute this for getWordEnd, if it fits.
		local _, endcol = line:find("[^a-zA-Z0-9_]", col)
		endcol = (endcol or 0) - 1

		word = line:sub(startcol, endcol)
	end

	self:DoAction("ShowContextHelp", word)
end

function PANEL:Copy()
	if not self:HasSelection() then 
		local oldCaret = self:CopyPosition(self.Caret)

		self.Start = { self.Caret[1], 1 }
		self.Caret = { self.Caret[1], #self.Rows[self.Caret[1]][1] + 1 }

		self.clipboard = self:GetSelection() .. "\r\n"

		self.Caret = oldCaret
		self.Start = self:CopyPosition(oldCaret)

		self.lastEmptySelectionCopy = self.clipboard

		return SetClipboardText(self.clipboard)
	end

	self.lastEmptySelectionCopy = nil
	self.clipboard = string_gsub(self:GetSelection(), "\n", "\r\n")
	return SetClipboardText(self.clipboard)
end

function PANEL:Cut()
	self:Copy()

	if not self:HasSelection() then
		self.Start = { self.Caret[1], 1 }
		
		if self.Caret[1] < #self.Rows then
			self.Caret = { self.Caret[1] + 1, 1 }
		else
			self.Caret = { self.Caret[1], #self.Rows[self.Caret[1]][1] + 1 }
		end
	end

	return self:SetSelection("")
end

-- TODO these two functions have no place in here
function PANEL:PreviousTab()
	local parent = self:GetParent()

	local currentTab = parent:GetActiveTabIndex() - 1
	if currentTab < 1 then currentTab = currentTab + parent:GetNumTabs() end

	parent:SetActiveTabIndex(currentTab)
end

function PANEL:NextTab()
	local parent = self:GetParent()

	local currentTab = parent:GetActiveTabIndex() + 1
	local numTabs = parent:GetNumTabs()
	if currentTab > numTabs then currentTab = currentTab - numTabs end

	parent:SetActiveTabIndex(currentTab)
end

function PANEL:DuplicateLine()
	-- Save current selection
	local old_start = self:CopyPosition(self.Start)
	local old_end = self:CopyPosition(self.Caret)
	local old_scroll = self:CopyPosition(self.Scroll)

	local str = self:GetSelection()
	if str ~= "" then -- If you have a selection
		self:SetSelection(str:rep(2)) -- Repeat it
	else -- If you don't
		-- Select the current line
		self.Start = { self.Start[1], 1 }
		self.Caret = { self.Start[1], #self.Rows[self.Start[1]][1] + 1 }
		-- Get the text
		local str = self:GetSelection()
		-- Repeat it
		self:SetSelection(str .. "\n" .. str)
	end

	-- Restore selection
	self.Caret = old_end
	self.Start = old_start
	self.Scroll = old_scroll
	self:ScrollCaret()
end

function PANEL:MoveSelection(dir)
	local startPos = self:CopyPosition(self.Start)
	local endPos = self:CopyPosition(self.Caret)

	if (dir == -1 and startPos[1] > 1) or (dir == 1 and endPos[1] < #self.Rows) then
		if endPos[1] < startPos[1] or (endPos[1] == startPos[1] and endPos[2] < startPos[2]) then
			startPos, endPos = endPos, startPos
		end

		self.Start = { startPos[1], 1 }
		self.Caret = { endPos[1], #self.Rows[endPos[1]][1] + 1 }
		local thisString = self:GetSelection()

		local nextRow = (dir == -1 and self.Start[1] or self.Caret[1]) + dir
		self.Start = { nextRow , 1 }
		self.Caret = { nextRow, #self.Rows[nextRow][1] + 1 }
		local otherString = self:GetSelection()
		
		if dir == -1 then
			self.Start = { startPos[1] + dir, 1 }
			self.Caret = { endPos[1], #self.Rows[endPos[1]][1] + 1 }
			self:SetSelection(thisString .. "\n" .. otherString)
		else
			self.Start = { startPos[1], 1 }
			self.Caret = { endPos[1] + dir, #self.Rows[endPos[1] + dir][1] + 1 }
			self:SetSelection(otherString .. "\n" .. thisString)
		end
		
		startPos[1] = startPos[1] + dir
		endPos[1] = endPos[1] + dir
		self.Start = self:CopyPosition(startPos)
		self.Caret = self:CopyPosition(endPos)
	end
end

function PANEL:_OnKeyCodeTyped(code)
	local handled = true
	self.Blink = RealTime()

	local alt = input.IsKeyDown(KEY_LALT) or input.IsKeyDown(KEY_RALT)

	local shift = input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT)
	local control = input.IsKeyDown(KEY_LCONTROL) or input.IsKeyDown(KEY_RCONTROL)

	-- allow ctrl-ins and shift-del (shift-ins, like ctrl-v, is handled by vgui)
	if not shift and control and code == KEY_INSERT then
		shift, control, code = true, false, KEY_C
	elseif shift and not control and code == KEY_DELETE then
		shift, control, code = false, true, KEY_X
	end

	if control then

		if code == KEY_A then
			self:SelectAll()
		elseif code == KEY_Z then
			self:DoUndo()
		elseif code == KEY_Y then
			self:DoRedo()
		elseif code == KEY_X then
			self:Cut()
		elseif code == KEY_C then
			self:Copy()
			-- pasting is now handled by the textbox that is used to capture input
			--[[
		elseif code == KEY_V then
			if self.clipboard then
				self:SetSelection(self.clipboard)
			end
			]]
		elseif code == KEY_F then
			self:OpenFindWindow("find")
		elseif code == KEY_H then
			self:OpenFindWindow("find and replace")
		elseif code == KEY_G then
			self:OpenFindWindow("go to line")
		elseif code == KEY_K then
			self:CommentSelection(shift)
		elseif code == KEY_Q then
			self:GetParent():Close()
		elseif code == KEY_T then
			self:GetParent():NewTab()
		elseif code == KEY_W then
			self:GetParent():CloseTab()
		elseif code == KEY_PAGEUP then
			self:PreviousTab()
		elseif code == KEY_PAGEDOWN then
			self:NextTab()
		elseif code == KEY_UP then
			self:OnMouseWheeled(1)
		elseif code == KEY_DOWN then
			self:OnMouseWheeled(-1)
		elseif code == KEY_LEFT then
			self:SetCaret(self:wordLeft(self.Caret))
		elseif code == KEY_RIGHT then
			self:SetCaret(self:wordRight(self.Caret))
		elseif code == KEY_BACKSPACE then
			if self:HasSelection() then
				self:SetSelection()
			else
				self:SetCaret(self:SetArea({ self.Caret, self:wordLeft(self.Caret) }))
				if self.OnTextChanged then self:OnTextChanged() end
			end
			if TabHandler.ACAuto:GetBool() then
				self:AutocompleteOpen()
			end
		elseif code == KEY_DELETE then
			if self:HasSelection() then
				self:SetSelection()
			else
				self:SetCaret(self:SetArea({ self.Caret, self:wordRight(self.Caret) }))
				if self.OnTextChanged then self:OnTextChanged() end
			end
		elseif code == KEY_HOME then
			self:SetCaret({ 1, 1 })
		elseif code == KEY_END then
			self:SetCaret({ #self.Rows, 1 })
		elseif code == KEY_D then
			self:DuplicateLine()
		elseif code == KEY_SPACE then
			self:AutocompleteOpen()
		else
			handled = false
		end

	elseif alt then

		if code == KEY_UP then
			self:MoveSelection(-1)
		elseif code == KEY_DOWN then
			self:MoveSelection(1)
		else
			handled = false
		end

	else
		
		if code == KEY_ENTER then
			if self:AutocompleteKeybind(code) then return end
			local row = self:GetRowText(self.Caret[1]):sub(1, self.Caret[2]-1)
			local diff = (row:find("%S") or (row:len() + 1))-1
			local tabs = string_rep("    ", math_floor(diff / 4))
			if TabHandler.AutoIndentConVar:GetBool() then
				local function countMatches(s,open,close)
					-- add spaces to string to detect whole word
					s = " " .. s .. " "
					local n = 0
					for i=1,#open do
						local _, temp = string_gsub(s,open[i],"")
						n = n + temp
					end
					local _, temp = string_gsub(s,close,"")
					return n - temp
				end
				local row = string_gsub(row,'%b""',"") -- erase strings on this line
				if countMatches(row,{"{"},"}") > 0 or 
					countMatches(row,{"%sthen%s","%sdo%s","[,%s%(]function[%s%(]","%selse%s"},"%send[%s%p]") > 0 or 
					countMatches(row,{"%srepeat%s"},"%suntil%s") > 0 then 
						tabs = tabs .. "    "
				end
			end
			self:SetSelection("\n" .. tabs)
			if self.OnTextChanged then self:OnTextChanged() end
		elseif code == KEY_UP then
			if self:AutocompleteKeybind(code) then return end
			if self.Caret[1] <= 1 then return end
			self.Caret[1] = self.Caret[1] - 1
			while self.Rows[self.Caret[1]][3] do
				self.Caret[1] = self.Caret[1] - 1
			end
			self:SetCaret(self.Caret)
		elseif code == KEY_DOWN then
			if self:AutocompleteKeybind(code) then return end
			if self.Caret[1] >= #self.Rows then 
					self.Caret[2] = #self.Rows[self.Caret[1]][1]
					self:SetCaret(self.Caret)
				return
			end
			self.Caret[1] = self.Caret[1] + 1
			while self.Rows[self.Caret[1]][3] do
				self.Caret[1] = self.Caret[1] + 1
			end
			self:SetCaret(self.Caret)
		elseif code == KEY_LEFT then
			if self:HasSelection() and not shift then
				self:SetCaret(self.Caret, false)
			else
				local buffer = self:GetArea({ self.Caret, { self.Caret[1], 1 } })
				local delta = -1
				if self.Caret[2] % 4 == 1 and #(buffer) > 0 and string_rep(" ", #(buffer)) == buffer then
					delta = -4
				end
				self:SetCaret(self:MovePosition(self.Caret, delta))
			end
		elseif code == KEY_RIGHT then
			if self:HasSelection() and not shift then
				self:SetCaret(self.Caret, false)
			else
				local buffer = self:GetArea({ { self.Caret[1], self.Caret[2] + 4 }, { self.Caret[1], 1 } })
				local delta = 1
				if self.Caret[2] % 4 == 1 and string_rep(" ", #(buffer)) == buffer and #(self.Rows[self.Caret[1]][1]) >= self.Caret[2] + 4 - 1 then
					delta = 4
				end
				self:SetCaret(self:MovePosition(self.Caret, delta))
			end
		elseif code == KEY_PAGEUP then
			self.Caret[1] = self.Caret[1] - math_ceil(self.Size[1] / 2)
			self:SetCaret(self.Caret)
			self:ScrollCaret()
		elseif code == KEY_PAGEDOWN then
			self.Caret[1] = self.Caret[1] + math_ceil(self.Size[1] / 2)
			self:SetCaret(self.Caret)
			self:ScrollCaret()
		elseif code == KEY_HOME then
			local row = self.Rows[self.Caret[1]][1]
			local first_char = row:find("%S") or row:len() + 1
			if self.Caret[2] == first_char then
				self.Caret[2] = 1
			else
				self.Caret[2] = first_char
			end
			self:SetCaret(self.Caret)
		elseif code == KEY_END then
			local length = #(self.Rows[self.Caret[1]][1])
			self.Caret[2] = length + 1
			self:SetCaret(self.Caret)
		elseif code == KEY_BACKSPACE then
			if self:HasSelection() then
				self:SetSelection()
			else
				local buffer = self:GetArea({ self.Caret, { self.Caret[1], 1 } })
				local delta = -1
				if self.Caret[2] % 4 == 1 and #(buffer) > 0 and string_rep(" ", #(buffer)) == buffer then
					delta = -4
				end
				self:SetCaret(self:SetArea({ self.Caret, self:MovePosition(self.Caret, delta) }))
				if self.OnTextChanged then self:OnTextChanged() end
			end
			if TabHandler.ACAuto:GetBool() then
				self:AutocompleteOpen()
			end
		elseif code == KEY_DELETE then
			if self:HasSelection() then
				self:SetSelection()
			else
				local buffer = self:GetArea({ { self.Caret[1], self.Caret[2] + 4 }, { self.Caret[1], 1 } })
				local delta = 1
				if self.Caret[2] % 4 == 1 and string_rep(" ", #(buffer)) == buffer and #(self.Rows[self.Caret[1]][1]) >= self.Caret[2] + 4 - 1 then
					delta = 4
				end
				self:SetCaret(self:SetArea({ self.Caret, self:MovePosition(self.Caret, delta) }))
				if self.OnTextChanged then self:OnTextChanged() end
			end
		elseif code == KEY_F1 then
			self:ContextHelp()
		else
			handled = false
		end
	end

	if code == KEY_TAB or (control and (code == KEY_I or code == KEY_O)) then
		if code == KEY_O then shift = not shift end
		if code == KEY_TAB and control then shift = not shift end
		if self:AutocompleteKeybind(code) then return end
		if self:HasSelection() then
			self:Indent(shift)
		else
			-- TAB without a selection --
			if shift then
				local newpos = self.Caret[2]-4
				if newpos < 1 then newpos = 1 end
				self.Start = { self.Caret[1], newpos }
				if self:GetSelection():find("%S") then
					-- TODO: what to do if shift-tab is pressed within text?
					self.Start = self:CopyPosition(self.Caret)
				else
					self:SetSelection("")
				end
			else
				local count = (self.Caret[2] + 2) % 4 + 1
				self:SetSelection(string_rep(" ", count))
			end
		end
		-- signal that we want our focus back after (since TAB normally switches focus)
		if code == KEY_TAB then self.TabFocus = true end
		handled = true
	end

	if control and not handled then
		handled = self:OnShortcut(code, shift)
	end

	return handled
end

local function currentGroup(s, idx)
	if string.match(s, "^[%w_]", idx) then return "[%w_]", "[^%w_]" end
	if string.match(s, "^%s", idx) then return "%s", "%S" end
	return "[^%w_%s]", "[%w_%s]"
end

-- helpers for ctrl-left/right
function PANEL:wordLeft(caret)
	caret = self:CopyPosition(caret)
	local row = self:GetRowText(caret[1])
	if caret[2] == 1 then
		if caret[1] == 1 then return caret end
		caret = { caret[1]-1, #self:GetRowText(caret[1]-1) }
		row = self:GetRowText(caret[1])
	end
	local group, antigroup = currentGroup(row, caret[2]-1)
	local pos = string.match(string.sub(row, 1, caret[2]-1), antigroup.."()"..group.."+"..antigroup.."*$")
	caret[2] = pos or 1
	return caret
end

function PANEL:wordRight(caret)
	caret = self:CopyPosition(caret)
	local row = self:GetRowText(caret[1])
	if caret[2] > #row then
		if caret[1] == #self.Rows then return caret end
		caret = { caret[1] + 1, 1 }
		row = self:GetRowText(caret[1])
		if row:sub(1, 1) ~= " " then return caret end
	end
	local group, antigroup = currentGroup(row, caret[2])
	local pos = string.match(row, "()"..antigroup, caret[2])
	caret[2] = pos or (#row + 1)
	return caret
end

function PANEL:GetTokenAtPosition(caret)
	local column = caret[2]
	if caret[1] > #self.RowTexts then return end
	local line = self.Rows[caret[1]]
	if not line then return nil end
	line = line[2]
	if line then
		local startindex = 0
		for index, data in ipairs(line) do
			startindex = startindex + #data[1]
			if startindex >= column then return data, index end
		end
	end
end

-- Syntax highlighting --------------------------------------------------------

function PANEL:ResetTokenizer(row)
	self.line = self:GetRowText(row)
	self.position = 0
	self.character = ""
	self.tokendata = ""

	self:DoAction("ResetTokenizer", row)
end

function PANEL:NextCharacter()
	if not self.character then return end

	self.tokendata = self.tokendata .. self.character
	self.position = self.position + 1

	if self.position <= self.line:len() then
		self.character = self.line:sub(self.position, self.position)
	else
		self.character = nil
	end
end

function PANEL:PrevCharacter()
	if not self.character then return end

	self.tokendata = self.tokendata:sub(1, #self.tokendata - 1)
	self.position = self.position - 1

	if self.position >= 1 then
		self.character = self.line:sub(self.position, self.position)
	else
		self.character = nil
	end
end

function PANEL:SkipPattern(pattern)
	-- TODO: share code with NextPattern
	if not self.character then return nil end
	local startpos, endpos, text = self.line:find(pattern, self.position)

	if startpos ~= self.position then return nil end
	local buf = self.line:sub(startpos, endpos)
	if not text then text = buf end

	--self.tokendata = self.tokendata .. text

	self.position = endpos + 1
	if self.position <= #self.line then
		self.character = self.line:sub(self.position, self.position)
	else
		self.character = nil
	end
	return text
end

function PANEL:getWordStart(caret, getword, pattern)
	local line = self:GetRowText(caret[1])
	if pattern == nil then pattern = "()[%w_]+()" end -- "()%w+()"

	for startpos, endpos in string.gmatch(line, pattern) do
		if startpos <= caret[2] and endpos >= caret[2] then
			return { caret[1], startpos }, getword and string.sub(line, startpos, endpos-1) or nil
		end
	end

	return { caret[1], 1 }
end

function PANEL:getWordEnd(caret, getword, pattern)
	local line = self:GetRowText(caret[1])
	if pattern == nil then pattern = "()[%w_]+()" end -- "()%w+()"

	for startpos, endpos in string.gmatch(line, pattern) do
		if startpos <= caret[2] and endpos >= caret[2] then
			return { caret[1], endpos }, getword and string.sub(line, startpos, endpos-1) or nil
		end
	end
	return { caret[1], #line + 1 }
end


function PANEL:getWordPrevious()
	local ln, col = self.Caret[1], self.Caret[2]
	local row = self:GetRowText(ln)
	local startpos, _, word = string.find(string.sub(row, 1, col - 1), "(%w+)[^%w%.:_]+(%w*)$", 1)
	if not startpos then startpos, word = 1, "" end

	return word, self:GetArea({ { ln, startpos - 1 }, { ln, startpos } })
end

local AC_CONTROL_OFF = 0
local AC_CONTROL_E2 = 1
local AC_CONTROL_VSCODE = 2
local AC_CONTROL_ECLIPSE = 3

local AC_COLOR_CONSTANT = Color(86, 156, 214)
local AC_COLOR_LIBRARY = Color(100, 50, 230)
local AC_COLOR_FIELD = Color(100, 230, 100)
local AC_COLOR_FUNCTION = Color(150, 40, 40)
local AC_COLOR_HOOK = Color(206, 145, 120)

local function concatParameters(params)
	if not params then return "()" end

	local t = {}
	for _, param in ipairs(params) do
		if string.find(param.type or "", "%.%.%.") then
			t[#t + 1] = "..." .. param.name
		else
			t[#t + 1] = param.name
		end
	end
	return "(" .. table.concat(t, ", ") .. ")"
end

local function WrapText(txt, width)
	local ret = {}
	local prev_end, prev_newline = 0, 0
	for cur_end in string.gmatch(txt, "%S+()") do
		local w, _ = surface_GetTextSize(string.sub(txt, prev_newline, cur_end))
		if w > width then
			ret[#ret+1] = string.Trim(string.sub(txt, prev_newline, prev_end))
			prev_newline = prev_end + 1
		end
		prev_end = cur_end
	end
	ret[#ret+1] = string.Trim(string.sub(txt, prev_newline))
	return table.concat(ret, "\n")
end

local function levenshteinDistance(a,b)
	a = {string.byte(a, 1, #a)}
	b = {string.byte(b, 1, #b)}

	local m = #a+1
	local n = #b+1
	local mat = {}
	for i=1, m*n do mat[i] = 0 end
	for i=1, m do mat[i] = i-1 end
	for i=1, n do mat[m*(i-1)+1] = i-1 end
	for j=1, n-1 do
		for i=1, m-1 do
			local preva = mat[m*j + i]
			local prevb = mat[m*(j-1) + i + 1]
			local prevc = mat[m*(j-1) + i]
			mat[m*j + i + 1] = math.min(preva+1, prevb+0.05, prevc+(a[i]~=b[j] and 1 or 0))
		end
	end

	return mat[m*n]
end
local AutoCompleteSuggestion = {
	__call = function(t, writing, compare, name, desc, color, replace, replacelength, reopen)
		if not replace then replace = name end
		local distance = levenshteinDistance(writing, compare)
		return setmetatable({
			name = name,
			desc = desc,
			color = color,
			replace = replace,
			distance = distance,
			replacelength = replacelength,
			reopen = reopen
		}, t)
	end,
	__lt = function(a,b)
		return a.distance < b.distance
	end
}
setmetatable(AutoCompleteSuggestion, AutoCompleteSuggestion)

function PANEL:AutocompletePopulate()
	local suggestions = {}

	repeat
		local line = string.sub(self:GetRowText(self.Caret[1]), 1, self.Caret[2]-1)

		local dirTyped = string.match(line, "--@(%w*)$")
		if dirTyped then
			dirTyped = string.lower(dirTyped)
			for dirName, directive in pairs(SF.Docs.Directives) do
				suggestions[#suggestions + 1] = AutoCompleteSuggestion(dirTyped, string.lower(dirName), "--@"..dirName, directive.description or ("The directive " .. dirName), AC_COLOR_CONSTANT, dirName, #dirTyped)
			end
			break
		end

		local hookDef = string.match(line, "hook%.add%s*%(%s*[\"'](%w*)$")
		if hookDef then
			hookDef = string.lower(hookDef)
			for hookName, hookInfo in pairs(SF.Docs.Hooks) do
				local hookNamel = string.lower(hookName)
				if string.StartsWith(hookNamel, hookDef) then
					local replacement = TabHandler.ACWithParams:GetBool() and (hookName.."\", \"\", function"..concatParameters(hookInfo.params).." end)") or (hookName.."\"")
					suggestions[#suggestions + 1] = AutoCompleteSuggestion(hookDef, hookNamel, hookName, hookInfo.description or ("The hook " .. hookName), AC_COLOR_HOOK, replacement, #hookDef)
				end
			end
			break
		end
		
		local prevWord = self:getWordPrevious()
		if prevWord == "function" or prevWord == "local" then return end

		local typing = string.match(line, "[%w%.:_]+$")
		if typing == nil then return end
		if typing == self.LastAutocompleteTyped then return true end
		self.LastAutocompleteTyped = typing

		local selfCall = string.match(typing, "%:([%w_]+)")
		if selfCall then
			selfCall = string.lower(selfCall)
			for typeName, typeData in pairs(SF.Docs.Types) do
				if typeData.methods then
					for funcName, funcMethod in pairs(typeData.methods) do
						local funcNamel = string.lower(funcName)
						if string.StartsWith(funcNamel, selfCall) then
							local fullfunc = funcName..concatParameters(funcMethod.params)
							local replacement = TabHandler.ACWithParams:GetBool() and (fullfunc) or (funcName.."(")
							suggestions[#suggestions + 1] = AutoCompleteSuggestion(selfCall, funcNamel, typeName..":"..fullfunc, funcMethod.description, AC_COLOR_FUNCTION, replacement, #selfCall)
						end
					end
				end
			end
			break
		end

		local dotCall = string.match(typing, "%.([%w_]*)")
		if dotCall then
			dotCall = string.lower(dotCall)
			local libName = string.match(typing, "([^%.]+)[%.]")
			local libData = SF.Docs.Libraries[libName]
			if libName ~= "builtins" and libData and libData.methods then
				for funcName, funcMethod in pairs(libData.methods) do
					local fullfunc = funcName..concatParameters(funcMethod.params)
					local replacement = TabHandler.ACWithParams:GetBool() and (fullfunc) or (funcName.."(")
					suggestions[#suggestions + 1] = AutoCompleteSuggestion(dotCall, string.lower(funcName), fullfunc, funcMethod.description, AC_COLOR_FUNCTION, replacement, #dotCall)
				end
				break
			end
			local tables = SF.Docs.Libraries.builtins.tables[libName]
			if tables then
				for _, fieldData in pairs(tables.fields) do
					local fieldName = fieldData.name
					suggestions[#suggestions + 1] = AutoCompleteSuggestion(dotCall, string.lower(fieldName), fieldName, fieldData.description, AC_COLOR_FIELD, fieldName, #dotCall)
				end
				break
			end
		end

		local typingl = string.lower(typing)
		for funcName, funcMethod in pairs(SF.Docs.Libraries.builtins.methods) do
			local funcNamel = string.lower(funcName)
			if string.StartsWith(funcNamel, typingl) then
				local fullfunc = funcName..concatParameters(funcMethod.params)
				local replacement = TabHandler.ACWithParams:GetBool() and (fullfunc) or (funcName.."(")
				suggestions[#suggestions + 1] = AutoCompleteSuggestion(typingl, funcNamel, fullfunc, funcMethod.description, AC_COLOR_FUNCTION, replacement, #typing)
			end
		end

		for libName, libData in pairs(SF.Docs.Libraries) do
			local libNamel = string.lower(libName)
			if string.StartsWith(libNamel, typingl) and libName ~= "builtins" then
				suggestions[#suggestions + 1] = AutoCompleteSuggestion(typingl, libNamel, libName, "The library " .. libName, AC_COLOR_LIBRARY, libName..".", #typing, true)
			end
		end
		for fieldName, fieldData in pairs(SF.Docs.Libraries.builtins.tables) do
			local fieldNamel = string.lower(fieldName)
			if string.StartsWith(fieldNamel, typingl) then
				suggestions[#suggestions + 1] = AutoCompleteSuggestion(typingl, fieldNamel, fieldName, fieldData.description, AC_COLOR_FIELD, fieldName..".", #typing, true)
			end
		end

	until true
	if suggestions[1]==nil then return end

	table.sort(suggestions)

	local acPanel = self.acPanel
	for i, item in ipairs(acPanel.suggestionlist:GetCanvas():GetChildren()) do
		local suggestion = suggestions[i]
		acPanel.suggestions[i] = suggestion
		item:SetVisible(suggestion ~= nil)
	end
	acPanel.suggestionlist:InvalidateLayout()

	acPanel.numitems = math.min(#suggestions, 64)
	acPanel:UpdateSelection(1)

	return true
end

function PANEL:AutocompleteApply()
	local selection = self.acPanel:GetSelected()
	self:SetCaret(self:SetArea({{self.Caret[1], math.max(1, self.Caret[2]-selection.replacelength)}, self.Caret }, selection.replace ))
	if selection.reopen then
		self:AutocompleteOpen()
	else
		self:AutocompleteClose()
	end
end

function PANEL:AutocompleteClose()
	self.acPanel:SetVisible(false)
	self:RequestFocus()
end

function PANEL:AutocompleteCreate()
	local acPanel = vgui.Create( "StarfallPanel", self )
	acPanel:SetBackgroundColor(Color(0,0,0,200))

	acPanel.keyWait = 0
	acPanel.keyHolding = false
	acPanel.selection = 1
	acPanel.numitems = 0
	acPanel.suggestions = {}

	function acPanel:UpdateSelection(select)
		self.selection = select
		self:UpdateInfo()
	end

	function acPanel:ScrollSelect(delta)
		self:UpdateSelection((self.selection + delta - 1)%self.numitems + 1)
	end

	function acPanel:GetSelected()
		return self.suggestions[self.selection]
	end

	local editorCanvas = self
	function acPanel:UpdateInfo()
		local suggestion = self:GetSelected()
		local desctxt = self.suggestioninfo.desc

		if not (suggestion and suggestion.desc) then
			desctxt:SetText("")
			return
		end

		desctxt:SetSize(self.suggestioninfo:GetSize())
		surface.SetFont(editorCanvas.CurrentFont)
		desctxt:SetText( WrapText(suggestion.desc, 300) )
		desctxt:SizeToContents()
	end

	local function WaitForKeyUp(t, pnl)
		if input.IsKeyDown( KEY_TAB ) or input.IsKeyDown( KEY_ENTER ) or input.IsKeyDown( KEY_SPACE ) or input.IsKeyDown( KEY_UP ) or input.IsKeyDown( KEY_DOWN ) or input.IsKeyDown( KEY_LEFT ) or input.IsKeyDown( KEY_RIGHT ) then
			if t < pnl.keyWait then
				return true
			elseif pnl.keyWait~=0 then
				pnl.keyHolding = true
			end
		else
			pnl.keyWait = 0
			pnl.keyHolding = false
		end
	end

	local controlSchemes = setmetatable({
		[AC_CONTROL_E2] = function( pnl )
			local t = CurTime()
			if WaitForKeyUp(t, pnl) then return end
			if input.IsKeyDown( KEY_ENTER ) or input.IsKeyDown( KEY_SPACE ) then
				self:AutocompleteApply()
			elseif input.IsKeyDown( KEY_TAB ) then
				pnl:ScrollSelect( input.IsKeyDown( KEY_LCONTROL ) and -1 or 1 )
				pnl.keyWait = t + (pnl.keyHolding and 0.1 or 0.5)
			elseif input.IsKeyDown( KEY_UP ) or input.IsKeyDown( KEY_DOWN ) or input.IsKeyDown( KEY_LEFT ) or input.IsKeyDown( KEY_RIGHT ) then
				pnl:SetVisible(false)
			end
		end,
		[AC_CONTROL_VSCODE] = function( pnl )
			local t = CurTime()
			if WaitForKeyUp(t, pnl) then return end
			if input.IsKeyDown( KEY_SPACE ) then
				self:AutocompleteClose()
			elseif input.IsKeyDown( KEY_TAB ) then
				self:AutocompleteApply()
			elseif input.IsKeyDown( KEY_DOWN ) then
				pnl:ScrollSelect( 1 )
				pnl.keyWait = t + (pnl.keyHolding and 0.1 or 0.5)
			elseif input.IsKeyDown( KEY_UP ) then
				pnl:ScrollSelect( -1 )
				pnl.keyWait = t + (pnl.keyHolding and 0.1 or 0.5)
			end
		end,
		[AC_CONTROL_ECLIPSE] = function( pnl )
			local t = CurTime()
			if WaitForKeyUp(t, pnl) then return end
			if input.IsKeyDown( KEY_SPACE ) then
				self:AutocompleteClose()
			elseif input.IsKeyDown( KEY_ENTER ) then
				self:AutocompleteApply()
			elseif input.IsKeyDown( KEY_DOWN ) then
				pnl:ScrollSelect( 1 )
				pnl.keyWait = t + (pnl.keyHolding and 0.1 or 0.5)
			elseif input.IsKeyDown( KEY_UP ) then
				pnl:ScrollSelect( -1 )
				pnl.keyWait = t + (pnl.keyHolding and 0.1 or 0.5)
			end
		end,
	}, {__index = function() return function() end end})

	local function setThink() acPanel.Think = controlSchemes[TabHandler.ACControlStyle:GetInt()] end
	setThink()
	cvars.RemoveChangeCallback(TabHandler.ACControlStyle:GetName(), "autocompletestyle")
	cvars.AddChangeCallback(TabHandler.ACControlStyle:GetName(), setThink, "autocompletestyle")

	local suggestionlist = vgui.Create( "DPanelList", acPanel )
	suggestionlist:DockMargin(6, 6, 6, 6)
	suggestionlist:SetSize(400, 300)
	suggestionlist:Dock(LEFT)
	suggestionlist:EnableVerticalScrollbar( true )
	suggestionlist.Paint = function() end

	surface.SetFont(self.CurrentFont)
	local _, labelH = surface.GetTextSize( "H" )

	for i=1, 64 do
		local txt = vgui.Create("DLabel")
		txt:SetText("")
		txt:SetCursor("hand")
		txt:SetSize(300, labelH)
		txt:SetVisible(false)
		txt.index = i

		-- Enable mouse presses
		txt.OnMousePressed = function( pnl, code )
			if code == MOUSE_LEFT then
				acPanel.selection = pnl.index
				self:AutocompleteApply( pnl.index )
			end
		end

		txt.Paint = function( pnl, w, h )
			local suggestion = acPanel.suggestions[pnl.index]
			if suggestion==nil then return end

			surface_SetDrawColor(30, 30, 30, 150)
			surface_DrawRect(0, 0, w, h)

			surface_SetDrawColor(suggestion.color:Unpack())
			surface_DrawRect(0, 0, 4, h)

			if acPanel.selection == pnl.index then
				surface_SetDrawColor(255, 255, 255, 50)
				surface_DrawRect(0, 0, w, h)
			end

			surface.SetFont(self.CurrentFont)
			surface.SetTextPos( 6, 0 )
			surface.SetTextColor( 255,255,255,255 )
			surface.DrawText( suggestion.name )
		end

		-- Enable mouse hovering
		txt.OnCursorEntered = function( pnl )
			acPanel:UpdateSelection(pnl.index)
		end

		suggestionlist:AddItem( txt )
	end
	acPanel.suggestionlist = suggestionlist

	local suggestioninfo = vgui.Create( "DPanelList", acPanel )
	suggestioninfo:DockMargin(6,6,6,6)
	suggestioninfo:SetSize(300, 300)
	suggestioninfo:EnableVerticalScrollbar( true )
	suggestioninfo:Dock(LEFT)
	suggestioninfo.Paint = function() end
	acPanel.suggestioninfo = suggestioninfo

	local desc = vgui.Create("DLabel")
	desc:SetText("")
	desc:SetFont(self.CurrentFont)
	suggestioninfo:AddItem(desc)
	suggestioninfo.desc = desc
	
	acPanel:SetSize(700, 300)

	self.acPanel = acPanel
	return acPanel
end

function PANEL:AutocompleteOpen()
	local acPanel = self.acPanel

	if not SF.Docs or TabHandler.ACControlStyle:GetInt()==AC_CONTROL_OFF then
		if acPanel then self:AutocompleteClose() end
		return
	end

	if not acPanel then acPanel = self:AutocompleteCreate() end

	if self:AutocompletePopulate() then

		-- Calculate its position
		local caret = self:CopyPosition( self.Caret )
		local wordStart = self:getWordStart({ self.Caret[1], self.Caret[2] - 1 })

		local x = self.FontWidth * (wordStart[2] - self.Scroll[2] + 1) + 48
		local y = self.FontHeight * (wordStart[1] - self.Scroll[1] + 1) + 2

		acPanel.keyWait = CurTime()+0.5
		acPanel:SetVisible( true )
		local sw, sh = self:GetSize()
		local w, h = acPanel:GetSize()
		acPanel:SetPos(math.Clamp(sw-w, 0, x), math.Clamp(sh-h, 0, y))
	else
		acPanel:SetVisible( false )
		self:RequestFocus()
	end
end

function PANEL:AutocompleteKeybind(code)
	if not (self.acPanel and self.acPanel:IsVisible()) then return end
	local mode = TabHandler.ACControlStyle:GetInt()

	if code == KEY_ENTER then
		if mode == AC_CONTROL_ECLIPSE or mode == AC_CONTROL_E2 then
			self:AutocompleteApply()
			return true
		else
			self:AutocompleteClose()
		end
	elseif code == KEY_SPACE then
		if mode == AC_CONTROL_E2 then
			self:AutocompleteApply()
			return true
		end
	elseif code == KEY_UP then
		if mode == AC_CONTROL_VSCODE or mode == AC_CONTROL_ECLIPSE then
			self.acPanel:RequestFocus()
			return true
		end
	elseif code == KEY_DOWN then
		if mode == AC_CONTROL_VSCODE or mode == AC_CONTROL_ECLIPSE then
			self.acPanel:RequestFocus()
			return true
		end
	elseif code == KEY_TAB then
		if mode == AC_CONTROL_VSCODE then
			self:AutocompleteApply()
			self.TabFocus = true
			return true
		elseif mode == AC_CONTROL_E2 then
			self.acPanel:RequestFocus()
			return true
		end
	end
end

function PANEL:NextPattern(pattern)
	if not self.character then return false end
	local startpos, endpos, text = self.line:find(pattern, self.position)

	if startpos ~= self.position then return false end
	local buf = self.line:sub(startpos, endpos)
	if not text then text = buf end

	self.tokendata = self.tokendata .. text

	self.position = endpos + 1
	if self.position <= #self.line then
		self.character = self.line:sub(self.position, self.position)
	else
		self.character = nil
	end
	return true
end

function PANEL:GetSyntaxColor(name)
	return self:DoAction("GetSyntaxColor", name)
end

function PANEL:SyntaxColorLine(line)
	prev = prev or {}
	if #self.Rows[line] > 2048 then -- Too long to parse
		local cols = TabHandler.Modes.Text.SyntaxColorLine(self, line)
		for k,v in pairs(prev) do -- Pass along unfinished etc
			if isnumber(k) then continue end
			cols[k] = v
		end
		return cols
	end
	local cols = self:DoAction("SyntaxColorLine", line)

	local sum = 0
	--[[Hiding then/do -> end]]
	local adds = {
		["then"] = true,
		["function"] = true,
		["do"] = true
	}
	local removes = {
		["end"] = true,
		["else"] = true,
		["elseif"] = true,
	}
	for k,v in ipairs(cols) do 
		local text = v[1]
		::redo::
		if adds[text] then
			sum = sum + 1
		end
		if removes[text] and (sum > 0 or text == "end") then
			sum = sum - 1
		end
		if text == "else" then
			text = "then"
			goto redo
		end
		cols.test = sum
	end
	if sum > 0 then
		cols.foldable = true
	else
		sum = 0
		for k,v in ipairs(cols) do
			if v[1] == "{" then
				sum = sum + 1
			end
			if v[1] == "}" then
				sum = sum - 1
			end
			--cols.test = sum
		end
		cols.foldable = sum > 0 or nil
	end
	return cols
end

function PANEL:Think()
	if not self.LineNumberWidth then return end
	local x,y = self:CursorPos()
	local right_cursor = false
	if x > self.LineNumberWidth - 10 and x < self.LineNumberWidth then
		local lines = self.Rows
		if x < 0 then x = 0 end
		if y < 0 then y = 0 end
		local line = math_floor(y / self.FontHeight)
		line = lines[self.RealLine[line]] or lines[line]

		if line and line[2] and line[2].foldable then
			if self.cur ~= "pointer" then
				self:SetCursor("hand")
				self.cur = "pointer"
			end
			right_cursor = true
		end
	end
	if self.cur == "pointer" and not right_cursor then
		self:SetCursor("beam")
		self.cur = "beam"
	end
	self:DoAction("Think")
end
-- register editor panel
vgui.Register(TabHandler.ControlName, PANEL, "Panel");
return TabHandler
