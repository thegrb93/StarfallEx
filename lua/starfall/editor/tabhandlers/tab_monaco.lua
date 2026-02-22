----------------------------------------------------
-- Monaco TabHandler
----------------------------------------------------

CreateClientConVar("sf_editor_monaco_wordwrap", 1, true, false)
CreateClientConVar("sf_editor_monaco_linenumbers", 1, true, false)
CreateClientConVar("sf_editor_monaco_invisiblecharacters", 0, true, false)
CreateClientConVar("sf_editor_monaco_indentguides", 1, true, false)
CreateClientConVar("sf_editor_monaco_autocompletion", 1, true, false)
CreateClientConVar("sf_editor_monaco_fixconsolebug", 1, true, false)
CreateClientConVar("sf_editor_monaco_disablelinefolding", 0, true, false)
CreateClientConVar("sf_editor_monaco_fontsize", 13, true, false)

----------------
-- Handler part
----------------

local TabHandler = {
	ControlName = "sf_tab_monaco",
	IsEditor = true,
	Description = "Monaco Editor",
	GenericUris = {},
	QueuedJavaScript = {}
}

function TabHandler:QueueJavascript(code)
	self.QueuedJavaScript[#self.QueuedJavaScript+1] = code
end

function TabHandler:UpdateSettings()
	self:QueueJavascript([[
		window.editor.updateOptions({
			lineNumbers: "]]..(GetConVarNumber("sf_editor_monaco_linenumbers")~=0 and "on" or "off")..[[",
		});
	]])
end

function TabHandler:AddSession(tab)
	local uri
	if tab.chosenfile then
		uri = "file:///"..tab.chosenfile
	else
		local i=1
		while self.GenericUris[i] do i=i+1 end
		self.GenericUris[i] = true
		uri = "inmemory://model/"..i
	end
	tab.uri = uri
	self:QueueJavascript([[window.editor.createModel("]]..string.JavascriptSafe(tab.code)..[[","lua",monaco.Uri.parse("]]..uri..[["));]])
end

function TabHandler:RemoveSession(tab)
	if self.html:GetParent() == tab then
		self.html:SetVisible(false)
		self.html:SetParent(nil)
	end
	if tab.uri then
		self:QueueJavascript([[var m=window.editor.getModel(monaco.Uri.parse("]]..tab.uri..[["));if(m){m.dispose();}]])
	end
end

function TabHandler:SetSession(tab)
	if not tab.uri then	self:AddSession(tab) end

	self.html:SetParent(tab)
	--self.html.OnShortcut = function(_, code) tab:OnShortcut(code) end

	tab:DockPadding(0, 0, 0, 0)
	self.html:DockMargin(0, 0, 0, 0)
	self.html:Dock(FILL)
	self.html:SetVisible(true)
	self.html:RequestFocus()
	self:QueueJavascript([[window.editor.setModel(window.editor.getModel("]]..tab.uri..[["))]])
end

function TabHandler:GetActiveTab()
	local tab = self.html:GetParent()
	return tab:IsValid() and tab or nil
end

function TabHandler:SetCode(tab)
	if not self.loaded then return end
	self.code = tab.code
	self.html:RunJavascript("window.sfSetCode(\""..string.JavascriptSafe(tab.code).."\");")
end

function TabHandler:GetCode(tab)
	if not self.loaded then return end
	self.html:RunJavascript("window.sfGetCode();")
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

	local function setDoClick(panel)
		panel:SetDark(false)
		panel.OnChange = function() self:UpdateSettings() end
		return panel
	end

	local function setWang(wang, label)
		wang.OnValueChanged = function() self:UpdateSettings() end
		wang:GetParent():DockPadding(10, 1, 10, 1)
		wang:Dock(RIGHT)
		label:SetDark(false)
		return wang, label
	end

	setWang(form:NumberWang("Font size", "sf_editor_monaco_fontsize", 5, 40))
	setDoClick(form:CheckBox("Enable word wrap", "sf_editor_monaco_wordwrap"))
	setDoClick(form:CheckBox("Show line numbers", "sf_editor_monaco_linenumbers"))
	setDoClick(form:CheckBox("Show invisible characters", "sf_editor_monaco_invisiblecharacters"))
	setDoClick(form:CheckBox("Show indenting guides", "sf_editor_monaco_indentguides"))
	setDoClick(form:CheckBox("Auto completion", "sf_editor_monaco_autocompletion"))
	setDoClick(form:CheckBox("Fix console bug", "sf_editor_monaco_fixconsolebug")):SetTooltip("Fix console opening when pressing ' or @ (UK Keyboad layout)")
	setDoClick(form:CheckBox("Disable line folding keybinds", "sf_editor_monaco_disablelinefolding"))

	return scrollPanel, "Monaco", "icon16/cog.png", "Monaco options."
end

function TabHandler:FinishedLoading()
	self.loaded = true

	for _, v in ipairs(self.QueuedJavaScript) do self.html:QueueJavascript(v) end
	self.QueuedJavaScript = nil
	function TabHandler:QueueJavascript(code)
		self.html:QueueJavascript(code)
	end

	self:UpdateSettings()
end

function TabHandler:DocsFinished()
	
end

function TabHandler:Init()
	self.loaded = false
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

	var editor = monaco.editor.create(editorElement, {
		value: "",
		language: "lua",
		theme: "vs-dark"
	});
	window.editor = editor;

	window.addEventListener("resize", () => editor.layout({
		width: editorElement.offsetWidth,
		height: editorElement.offsetHeight
	}));

	editor.addAction({
		id: "sf-save",
		label: "Save",
		keybindings: [ monaco.KeyMod.CtrlCmd | monaco.KeyCode.KeyS ],
		contextMenuGroupId: "File",
		run: () => sf.save(),
	});

	editor.addAction({
		id: "sf-save-as",
		label: "Save As",
		keybindings: [ monaco.KeyMod.CtrlCmd | monaco.KeyMod.Shift | monaco.KeyCode.KeyS ],
		contextMenuGroupId: "File",
		run: () => sf.saveAs(),
	});

	editor.addAction({
		id: "sf-validate",
		label: "Validate",
		keybindings: [ monaco.KeyMod.CtrlCmd | monaco.KeyMod.Shift | monaco.KeyCode.Space ],
		contextMenuGroupId: "Tasks",
		run: () => sf.validate(),
	});

	window.sfSetCode = function(str) {editor.setValue(str);};
	window.sfGetCode = function() {sf.getCode(editor.getValue());};
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
