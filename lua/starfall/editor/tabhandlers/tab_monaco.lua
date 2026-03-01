----------------------------------------------------
-- Monaco TabHandler
----------------------------------------------------

local TabHandler = {
	ControlName = "sf_tab_monaco",
	IsEditor = true,
	Description = "Monaco Editor",
	Uri = 1,
}

local MonacoSetting = {
__index = {
	toJs = function(self, var)
		if self.type == TYPE_STRING then
			return "\""..string.JavascriptSafe(var).."\""
		elseif self.type == TYPE_NUMBER then
			return tonumber(var) or self.default
		elseif self.type == TYPE_BOOL then
			return tonumber(var)~=0 and "true" or "false"
		else
			error("Unknown var type: "..tostring(var))
		end
	end,
	toCvar = function(self, var)
		if self.type == TYPE_STRING then
			return var
		elseif self.type == TYPE_NUMBER then
			return tostring(var)
		elseif self.type == TYPE_BOOL then
			return var and "1" or "0"
		else
			error("Unknown var type: "..tostring(var))
		end
	end,
	update = function(self, new)
		self.js = self.jvar..": "..self:toJs(new)
	end,
	apply = function(self)
		if not (IsValid(TabHandler.html) and TabHandler.loaded) then return end
		TabHandler.html:RunJavascript([[sfeditor.updateOptions({]]..self.js..[[});]])
	end
},
__call = function(t,jvar,cvar,default)
	local self = setmetatable({
		jvar = jvar,
		default = default,
		type = TypeID(default)
	}, t)

	CreateClientConVar(cvar, self:toCvar(default), true, false)
	cvars.AddChangeCallback(cvar, function(_, _, new) self:update(new) self:apply() end)
	self:update(GetConVarString(cvar))

	return self
end,
__tostring = function(self) return self.js end
} setmetatable(MonacoSetting, MonacoSetting)
MonacoSetting.settings = {
	MonacoSetting("fontSize", "sf_editor_monaco_fontsize", 13),
	MonacoSetting("lineNumbers", "sf_editor_monaco_linenumbers", "on"),
	MonacoSetting("quickSuggestions", "sf_editor_monaco_suggestions", true),
	MonacoSetting("tabSize", "sf_editor_monaco_tabsize", 4),
	MonacoSetting("theme", "sf_editor_monaco_theme", "vs-dark"),
	MonacoSetting("renderWhitespace", "sf_editor_monaco_whitespace", "all"),
	MonacoSetting("wordBasedSuggestions", "sf_editor_monaco_wordsuggestion", "currentDocument"),
	MonacoSetting("wordWrap", "sf_editor_monaco_wordwrap", "off"),
}
function MonacoSetting:concat()
	local s = {}
	for k, v in ipairs(self.settings) do s[k]=tostring(v) end
	return table.concat(s, ",\n")
end

local ImageBackgroundSetting = {
__index = {
	apply = function(self)
		if not (IsValid(TabHandler.html) and TabHandler.loaded) then return end
		if self.url ~= "" then
			TabHandler.html:RunJavascript([[document.getElementById('editor').style.setProperty('background-image', 'url(\']]..self.url..[[\')');]])
		else
			TabHandler.html:RunJavascript([[document.getElementById('editor').style.removeProperty('background-image');]])
		end
	end
},
__call = function(t,cvarUrl,cvarOpacity)
	local self = setmetatable({}, t)

	CreateClientConVar(cvarUrl, "", true, false)
	cvars.AddChangeCallback(cvarUrl, function(_, _, new) self.url=new self:apply() end)
	self.url = GetConVarString(cvarUrl)

	CreateClientConVar(cvarOpacity, "200", true, false)
	cvars.AddChangeCallback(cvarOpacity, function(_, _, new) self.opacity=(tonumber(new) or 0)/255 self:apply() end)
	self.opacity = GetConVarNumber(cvarOpacity)/255

	return self
end
} setmetatable(ImageBackgroundSetting, ImageBackgroundSetting)
TabHandler.ImageBackground = ImageBackgroundSetting("sf_editor_monaco_htmlbackground", "sf_editor_monaco_htmlbackgroundopacity")

function TabHandler:AddSession(tab)
	tab.uri = "sf://session/"..self.Uri
	self.Uri = self.Uri + 1
	self.html:RunJavascript([[monaco.editor.createModel("", "lua", "]]..tab.uri..[[");]])
end

function TabHandler:RemoveSession(tab)
	if not IsValid(self.html) then return end
	if self.html:GetParent() == tab then
		self.html:SetVisible(false)
		self.html:SetParent(nil)
	end
	if tab.uri then
		self.html:RunJavascript([[var m=monaco.editor.getModel("]]..tab.uri..[[");if(m){m.dispose();}]])
	end
end

function TabHandler:SetSession(tab)
	self.html:SetParent(tab)
	--self.html.OnShortcut = function(_, code) tab:OnShortcut(code) end

	tab:DockPadding(0, 0, 0, 0)
	self.html:DockMargin(0, 0, 0, 0)
	self.html:Dock(FILL)
	self.html:SetVisible(true)
	self.html:RequestFocus()

	self.html:RunJavascript([[sfeditor.setModel(monaco.editor.getModel("]]..tab.uri..[["));]])
end

function TabHandler:SetCode(tab)
	self.html:RunJavascript([[monaco.editor.getModel("]]..tab.uri..[[").setValue("]]..string.JavascriptSafe(tab.code)..[[");]])
end

function TabHandler:GetCode(tab)
	self.html:RunJavascript([[sf.getCode(monaco.editor.getModel("]]..tab.uri..[[").getValue());]])
	tab.code = self.code
end

function TabHandler:SaveTab(saveas)
end

function TabHandler:RegisterSettings()
	local scrollPanel = vgui.Create("DScrollPanel")
	scrollPanel:Dock(FILL)
	scrollPanel:SetPaintBackgroundEnabled(false)

	local form = vgui.Create("DForm", scrollPanel)
	form:Dock(FILL)
	form:DockPadding(0, 10, 0, 10)
	form.Header:SetVisible(false)
	form.Paint = function () end

	local function setWang(wang, label)
		wang:GetParent():DockPadding(10, 1, 10, 1)
		wang:Dock(RIGHT)
		label:SetDark(false)
		return wang, label
	end
	local function setCombo(panelLabel, options)
		panelLabel[2]:SetDark(false)
		for _, v in ipairs(options) do panelLabel[1]:AddChoice(v) end
	end
	local function setDoClick(panel, tip)
		panel:SetDark(false)
		if tip then panel:SetTooltip(tip) end
		return panel
	end

	setWang(form:NumberWang("Font size", "sf_editor_monaco_fontsize", 5, 40))
	setWang(form:NumberWang("Tab size", "sf_editor_monaco_tabsize", 1, 16))

	setDoClick(form:CheckBox("Quick Suggestions", "sf_editor_monaco_suggestions"))

	setCombo({form:ComboBox("Line number style", "sf_editor_monaco_linenumbers")}, {"on","relative","off"})
	setCombo({form:ComboBox("Theme", "sf_editor_monaco_theme")}, {"vs","vs-dark","hc-black","hc-light"})
	setCombo({form:ComboBox("Whitespace style", "sf_editor_monaco_whitespace")}, {"all","boundary","selection","trailing","none"})
	setCombo({form:ComboBox("Word suggestions", "sf_editor_monaco_wordsuggestion")}, {"currentDocument","allDocuments","off"})
	setCombo({form:ComboBox("Word wrap style", "sf_editor_monaco_wordwrap")}, {"on","off"})

	select(2, form:TextEntry("Custom background image url:", "sf_editor_monaco_htmlbackground")):SetDark(false)
	form:NumSlider("Custom background image opacity","sf_editor_monaco_htmlbackgroundopacity", 0, 255, 1):SetDark(false)

	return scrollPanel, "Monaco", "icon16/cog.png", "Monaco options."
end

function TabHandler:FinishedLoading()
	self.loaded = true
	for k, v in pairs(self.disabledFuncs) do self[k] = v end
	self.disabledFuncs = nil

	if TabHandler.ImageBackground.url ~= "" then
		TabHandler.ImageBackground:apply()
	end

	self.html:RunJavascript([[
		sfeditor.updateOptions({
			autoDetectHighContrast: false,
			detectIndentation: false,
			insertSpaces: false,
			]]..MonacoSetting:concat()..[[
		});]])

	for i = 1, SF.Editor.editor:GetNumTabs() do
		local tab = SF.Editor.editor:GetTabContent(i)
		if tab:GetTabHandler() == self then
			self:AddSession(tab)
		end
	end
	local tab = SF.Editor.editor:GetActiveTab().content
	if tab and tab:GetTabHandler() == self then
		self:SetSession(tab)
	end
end

function TabHandler:DocsFinished()
	
end

function TabHandler:GetActiveTab()
	local tab = self.html:GetParent()
	return tab:IsValid() and tab or nil
end

function TabHandler:Init()
	self.loaded = false
	self.disabledFuncs = {}
	for v in pairs{
		UpdateSettings = true,
		AddSession = true,
		RemoveSession = true,
		SetSession = true,
		SetCode = true,
		GetCode = true,
		SaveTab = true,
		RegisterSettings = true
	} do
		self.disabledFuncs[v] = self[v]
		self[v] = function() end
	end

	self.code = ""
	self.html = vgui.Create("DHTML")
	self.html:Dock(FILL)
	self.html:DockMargin(5, 59, 5, 5)
	self.html:SetKeyboardInputEnabled(true)
	self.html:SetMouseInputEnabled(true)
	self.html:SetHTML(
[[
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8" />
<style>
html, body { height: 100%; margin: 0; overflow: hidden; }
body { display: flex; flex-direction: column; }
#editor { flex-grow: 1; border: solid 1px gray; overflow: hidden; background-size: cover; background-repeat: no-repeat; }
</style>
</head>
<body>
<div id="editor"></div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.29.1/min/vs/loader.min.js"></script>
<script>
require.config({ paths: { "vs": "https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.29.1/min/vs" }});

require(["vs/editor/editor.main"], function () {
	const editorElement = document.getElementById("editor");

	window.sfeditor = monaco.editor.create(editorElement, {
		value: "",
		language: "lua",
		theme: "vs-dark"
	});

	window.addEventListener("resize", () => sfeditor.layout({
		width: editorElement.offsetWidth,
		height: editorElement.offsetHeight
	}));

	sfeditor.addAction({
		id: "sf-save",
		label: "Save",
		keybindings: [ monaco.KeyMod.CtrlCmd | monaco.KeyCode.KeyS ],
		contextMenuGroupId: "File",
		run: () => sf.save(),
	});

	sfeditor.addAction({
		id: "sf-save-as",
		label: "Save As",
		keybindings: [ monaco.KeyMod.CtrlCmd | monaco.KeyMod.Shift | monaco.KeyCode.KeyS ],
		contextMenuGroupId: "File",
		run: () => sf.saveAs(),
	});

	sfeditor.addAction({
		id: "sf-validate",
		label: "Validate",
		keybindings: [ monaco.KeyMod.CtrlCmd | monaco.KeyMod.Shift | monaco.KeyCode.Space ],
		contextMenuGroupId: "Tasks",
		run: () => sf.validate(),
	});

	sf.doneLoading();
});
</script>
</body>
</html>

]])

	self.html:AddFunction("sf", "save", function() self:SaveTab() end)
	self.html:AddFunction("sf", "saveAs", function() self:SaveTab(true) end)
	self.html:AddFunction("sf", "validate", SF.Editor.doValidation)
	self.html:AddFunction("sf", "getCode", function(code) self.code = code end)
	self.html:AddFunction("sf", "doneLoading", function() self:FinishedLoading() end)

	self.html.OnKeyCodePressed = function(_, key, notfirst)
		--[[if input.IsKeyDown(KEY_LCONTROL) then
			self:OnShortcut(key)
		end]]
		if key == 57 and tobool(GetConVarNumber("sf_editor_monaco_fixconsolebug")) then
			gui.ActivateGameUI()
		end
	end

	self.html:SetVisible(false)
end

function TabHandler:Cleanup()
	self.html:Remove()
	self.html = nil
	self.loaded = false
end

-------------
-- VGUI part
-------------

local PANEL = {}

function PANEL:Init()
	self:SetBackgroundColor(Color(39, 40, 34))
	self:OnThemeChange(SF.Editor.Themes.CurrentTheme)
	TabHandler:AddSession(self)
	self.code = ""
end

function PANEL:GetCode()
	TabHandler:GetCode(self)
	return self.code
end

function PANEL:SetCode(code)
	self.code = code
	TabHandler:SetCode(self)
end

function PANEL:OnThemeChange(theme)
end

function PANEL:OnFocusChanged(gained)
	if gained then TabHandler:SetSession(self) end
end

function PANEL:OnRemove()
	TabHandler:RemoveSession(self)
end

vgui.Register(TabHandler.ControlName, PANEL, "DPanel")
return TabHandler
