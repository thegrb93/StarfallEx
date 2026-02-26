----------------------------------------------------
-- Monaco TabHandler
----------------------------------------------------

CreateClientConVar("sf_editor_monaco_fontsize", 13, true, false)
CreateClientConVar("sf_editor_monaco_linenumbers", "on", true, false)
CreateClientConVar("sf_editor_monaco_suggestions", 1, true, false)
CreateClientConVar("sf_editor_monaco_tabsize", 4, true, false)
CreateClientConVar("sf_editor_monaco_theme", "vs-dark", true, false)
CreateClientConVar("sf_editor_monaco_whitespace", "all", true, false)
CreateClientConVar("sf_editor_monaco_wordsuggestion", "currentDocument", true, false)
CreateClientConVar("sf_editor_monaco_wordwrap", "off", true, false)

----------------
-- Handler part
----------------

local TabHandler = {
	ControlName = "sf_tab_monaco",
	IsEditor = true,
	Description = "Monaco Editor",
	GenericUris = {},
}

function TabHandler:UpdateSettings()
    local function stringSetting(setting, cvar) return setting..": \""..string.JavascriptSafe(GetConVarString(cvar)).."\"" end
    local function numberSetting(setting, cvar) return setting..": "..GetConVarNumber(cvar) end
    local function boolSetting(setting, cvar) return setting..": "..(GetConVarNumber(cvar)~=0 and "true" or "false") end

	self.html:RunJavascript([[
		sfeditor.updateOptions({]]..
            table.concat({
                "autoDetectHighContrast: false"
                "detectIndentation: false",
                "insertSpaces: false",
                stringSetting("lineNumbers", "sf_editor_monaco_linenumbers"),
                stringSetting("renderWhitespace", "sf_editor_monaco_whitespace"),
                boolSetting("quickSuggestions", "sf_editor_monaco_suggestions"),
                numberSetting("tabSize", "sf_editor_monaco_tabsize"),
                stringSetting("theme", "sf_editor_monaco_theme"),
                stringSetting("wordBasedSuggestions", "sf_editor_monaco_wordsuggestion"),
                stringSetting("wordWrap", "sf_editor_monaco_wordwrap"),
            }, ",")..
[[		});
	]])
end

function TabHandler:AddSession(tab)
	local uri
	if tab.chosenfile then
		uri = "file:///"..string.JavascriptSafe(tab.chosenfile)
	else
		local i=1
		while self.GenericUris[i] do i=i+1 end
		self.GenericUris[i] = true
		uri = "sf://generic/"..i
		tab.generic = i
	end
	tab.uri = uri
	self.html:RunJavascript([[monaco.editor.createModel("]]..string.JavascriptSafe(tab.code)..[[", "lua", "]]..uri..[[");]])
end

function TabHandler:RemoveSession(tab)
	if not IsValid(self.html) then return end
	if self.html:GetParent() == tab then
		self.html:SetVisible(false)
		self.html:SetParent(nil)
	end
	if tab.uri then
		self.html:RunJavascript([[var m=monaco.editor.getModel("]]..tab.uri..[[");if(m){m.dispose();}]])
		if tab.generic then self.GenericUris[tab.generic] = nil end
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

	self.html:RunJavascript([[sfeditor.setModel(monaco.editor.getModel("]]..tab:GetURI()..[["));]])
end

function TabHandler:SetCode(tab)
	self.html:RunJavascript([[monaco.editor.getModel("]]..tab:GetURI()..[[").setValue("]]..string.JavascriptSafe(tab.code)..[[");]])
end

function TabHandler:GetCode(tab)
	self.html:RunJavascript([[sf.getCode(monaco.editor.getModel("]]..tab:GetURI()..[[").getValue());]])
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
		wang.OnValueChanged = function() self:UpdateSettings() end
		wang:GetParent():DockPadding(10, 1, 10, 1)
		wang:Dock(RIGHT)
		label:SetDark(false)
		return wang, label
	end
    local function setCombo(panelLabel, options)
        panelLabel[2]:SetDark(false)
        for _, v in ipairs(options) do panelLabel[1]:AddChoice(v) end
    end,
	local function setDoClick(panel, tip)
		panel:SetDark(false)
		panel.OnChange = function() self:UpdateSettings() end
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

	return scrollPanel, "Monaco", "icon16/cog.png", "Monaco options."
end

function TabHandler:FinishedLoading()
	self.loaded = true
	for k, v in pairs(self.disabledFuncs) do self[k] = v end
	self.disabledFuncs = nil

	self:UpdateSettings()

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
#editor { flex-grow: 1; border: solid 1px gray; overflow: hidden; }
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
	self.code = ""
end

function PANEL:GetURI()
	if not self.uri then TabHandler:AddSession(self) end
	return self.uri
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
