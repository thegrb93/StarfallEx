
local TabHandler = {
	ControlName = "sf_monaco_editor", -- Its name of vgui panel used by handler, there has to be one
	IsEditor = true,
	Description = "Monaco editor"
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

-----------------------
-- VGUI part (content)
-----------------------
function PANEL:Init() --That's init of VGUI like other PANEL:Methods(), separate for each tab

	local theme = SF.Editor.Themes.CurrentTheme

	--Background
	self:SetPaintBackground( true )
	self:SetBackgroundColor( theme.background )

	--Left Panel
	self.htmlPanel = vgui.Create("DHTML",self)
	self.htmlPanel:Dock(FILL)
	self.htmlPanel:SetHTML(
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
require.config({ paths: { "vs": "https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.29.1/min/vs/" }});

window.MonacoEnvironment = {
	getWorkerUrl: function(workerId, label) {
		return `data:text/javascript;charset=utf-8,${encodeURIComponent(`
			self.MonacoEnvironment = { baseUrl: "https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.29.1/min/" };
			importScripts("https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.29.1/min/vs/base/worker/workerMain.min.js");`
		)}`;
	}
};

window.sfGetCode = function() {};
window.sfSetCode = function() {};

require(["vs/editor/editor.main"], function () {
	const editorElement = document.getElementById("editor");

	var editor = monaco.editor.create(editorElement, {
		value: "",
		language: "lua",
		theme: "vs-dark"
	});

	window.addEventListener("resize", () => editor.layout({
		width: editorElement.offsetWidth,
		height: editorElement.offsetHeight
	}));

	window.sfSetCode = function(str) {editor.setValue(str);};
	window.sfGetCode = function() {sf.getCode(editor.getValue());};
	sf.doneLoadingCode();
});
</script>
</body>
</html>

]]
	)
	self.htmlPanel:AddFunction( "sf", "getCode", function( str )
		self.innerCode = str
	end)

	self.isLoaded = false
	self.htmlPanel:AddFunction( "sf", "doneLoadingCode", function( val )
		self.isLoaded = true
		self:SetCode(self.innerCode)
	end)
	self.innerCode = ""
end

function PANEL:OnThemeChange(theme)
end

function PANEL:OnFocusChanged(gained) -- When this tab is opened

end

function PANEL:Validate(movecarret) -- Validate request, has to return success,message

end

function PANEL:GetCode()
	if self.isLoaded then
		self.htmlPanel:RunJavascript("window.sfGetCode();")
	end
	return self.innerCode
end

function PANEL:SetCode(text)
	text = SF.Editor.normalizeCode(text)
	self.innerCode = text
	if self.isLoaded then
		self.htmlPanel:RunJavascript("window.sfSetCode(\""..string.JavascriptSafe(text).."\");")
	end
end

--------------
-- We're done
--------------
vgui.Register(TabHandler.ControlName, PANEL, "DPanel") -- Registering VGUI element of handler
return TabHandler -- Our file has to return table of handler
