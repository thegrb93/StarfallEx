----------------------------------------------------
-- Monaco TabHandler
----------------------------------------------------

local TabHandler = {
	ControlName = "sf_tab_monaco",
	IsEditor = true,
	Description = "Monaco Editor",
	Uri = 1,
	Tabs = {}
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
		self:apply()
	end,
	apply = function(self)
		if not (IsValid(TabHandler.html) and TabHandler.loaded) then return end
		TabHandler.html:RunJavascript([[sfeditor.updateOptions({]]..self.js..[[});]])
	end
},
__call = function(t,jvar,cvarname,default)
	local self = setmetatable({
		jvar = jvar,
		default = default,
		type = TypeID(default)
	}, t)

	SF.CvarCallback(CreateClientConVar(cvarname, self:toCvar(default), true, false), function(val) self:update(val) end, "string")

	return self
end,
} setmetatable(MonacoSetting, MonacoSetting)
MonacoSetting.settings = {
	MonacoSetting("fontSize", "sf_editor_monaco_fontsize", 13),
	MonacoSetting("lineNumbers", "sf_editor_monaco_linenumbers", "on"),
	MonacoSetting("quickSuggestions", "sf_editor_monaco_suggestions", true),
	MonacoSetting("tabSize", "sf_editor_monaco_tabsize", 4),
	MonacoSetting("renderWhitespace", "sf_editor_monaco_whitespace", "all"),
	MonacoSetting("wordWrap", "sf_editor_monaco_wordwrap", "off"),
}
function MonacoSetting:applyAll()
	local settings = {}
	for k, v in ipairs(self.settings) do settings[k]=v.js end
	
	TabHandler.html:RunJavascript([[
	sfeditor.updateOptions({
		autoDetectHighContrast: false,
		detectIndentation: false,
		insertSpaces: false,
		wordBasedSuggestions: "off",
		]]..table.concat(settings, ",\n")..[[
	});]])
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
__call = function(t,cvarUrlName,cvarOpacityName)
	local self = setmetatable({}, t)

	SF.CvarCallback(CreateClientConVar(cvarUrlName, "", true, false), function(val) self.url=val self:apply() end, "string")

	SF.CvarCallback(CreateClientConVar(cvarOpacityName, "200", true, false), function(val) self.opacity=math.Clamp(val/255, 0, 1) self:apply() end, "number")

	return self
end
} setmetatable(ImageBackgroundSetting, ImageBackgroundSetting)
TabHandler.ImageBackground = ImageBackgroundSetting("sf_editor_monaco_htmlbackground", "sf_editor_monaco_htmlbackgroundopacity")

function TabHandler:AddSession(tab)
	tab.uri = "sf://session/"..self.Uri
	self.Tabs[tab.uri] = tab
	self.Uri = self.Uri + 1

	-- Lua can't retreive data from javascript directly so we have to update the tab's code any time if changes
	self.html:RunJavascript([[
	{
		let uri="]]..tab.uri..[[";
		let m=monaco.editor.createModel("]]..string.JavascriptSafe(tab.code)..[[", "starfall", uri);
		m.pushEOL(monaco.editor.EndOfLineSequence.LF);
		m.onDidChangeContent((event) => sf.updateCode(uri, m.getValue()));
	}
]])
end

function TabHandler:RemoveSession(tab)
	self.Tabs[tab.uri] = nil
	if not IsValid(self.html) then return end

	if self.html:GetParent() == tab then
		self.html:SetVisible(false)
		self.html:SetParent(nil)
	end

	if tab.uri then
		self.html:RunJavascript([[{let m=monaco.editor.getModel("]]..tab.uri..[[");if(m){m.dispose();}}]])
	end
end

function TabHandler:SetSession(tab)
	self.html:SetParent(tab)

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

function TabHandler:GetCode(uri, code)
	local tab = self.Tabs[uri]
	if not IsValid(tab) then return end
	tab.code = code
	tab:OnTextChanged()
end

function TabHandler:SaveTab(saveas)
	local tab = self:GetActiveTab()
	if not tab then return end
	SF.Editor.editor:SaveFile(tab.chosenfile, false, saveas)
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
	setCombo({form:ComboBox("Whitespace style", "sf_editor_monaco_whitespace")}, {"all","boundary","selection","trailing","none"})
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

	MonacoSetting:applyAll()
	TabHandler:ApplyTheme(SF.Editor.Themes.CurrentTheme)
	TabHandler:DocsFinished()

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

local DocGenerator
DocGenerator = {
	-- Escapes a string for safe inclusion inside a double-quoted JS string
	jsEscape = function(s)
		return (s:gsub("[%z\1-\31\\\"]", function(c)
			return string.format("\\u%04x", string.byte(c))
		end))
	end,

	__index = {
		generate = function(self)
			-- Starfall types and their methods (also covers `:` calls)
			for typeName, typeData in pairs(SF.Docs.Types) do
				self:add(typeName, nil, typeData)
				if typeData.methods then
					for methodName, methodData in pairs(typeData.methods) do self:add(methodName, "\1", methodData) end
				end
			end
			-- Libraries, their methods and fields
			for libName, lib in pairs(SF.Docs.Libraries) do
				if libName ~= "builtins" then
					self:add(libName, nil, lib)
					for methodName, methodData in pairs(lib.methods) do self:add(methodName, "\2"..libName..".", methodData) end
					for fieldName, fieldData in pairs(lib.fields) do self:add(fieldName, "\2"..libName..".", fieldData) end
				else
					for methodName, methodData in pairs(lib.methods) do self:add(methodName, nil, methodData) end
					for fieldName, fieldData in pairs(lib.fields) do self:add(fieldName, nil, fieldData) end
				end
			end
			-- Builtin tables (e.g. player.getAll) and their fields
			for tableName, tbl in pairs(SF.Docs.Libraries.builtins.tables) do
				self:add(tableName, nil, tbl)
				if tbl.fields then
					for _, fieldData in pairs(tbl.fields) do self:add(fieldData.name, "\2"..tableName..".", fieldData) end
				end
			end
			-- Hooks and directives
			for hookName, hookData in pairs(SF.Docs.Hooks) do self:add(hookName, nil, hookData) end
			for dirName, dirData in pairs(SF.Docs.Directives) do self:add(dirName, nil, dirData) end

			return table.concat(self.parts, ",")
		end,

		add = function(self, name, tag, data)
			local key = (tag or "") .. name
			if self.seen[key] then return end
			self.seen[key] = true
			local entry = data and self:buildSignature(key, data) or (key.."\3\3")
			self.parts[#self.parts+1] = '"'..DocGenerator.jsEscape(entry)..'"'
		end,

		-- Builds a compact docs payload (keywords + completions) from SF.Docs and pushes it to Monaco
		-- Each entry is: tag .. name .. "\3" .. signature .. "\3" .. description
		-- tag is "", "\1" (type method, suggested after `:`) or "\2lib." (library member)
		buildSignature = function(self, key, data)
			local sig = {"("}
			local doc = {data.description or ""}
			if data.params then
				local params = {}
				for i, param in ipairs(data.params) do
					params[i] = (param.name or "?") .. (param.type and (": " .. param.type) or "")
					if param.description and param.description ~= "" then
						doc[#doc+1] = "**" .. (param.name or "?") .. "**" .. (param.type and " (" .. param.type .. ")" or "") .. " — " .. param.description
					end
				end
				sig[#sig+1] = table.concat(params, ", ")
			end
			sig[#sig+1] = ")"
			if data.returns and data.returns[1] then
				local rets = {}
				for i, ret in ipairs(data.returns) do
					rets[i] = ret.type or "any"
					if ret.description and ret.description ~= "" then
						doc[#doc+1] = "**Returns**" .. (ret.type and " (" .. ret.type .. ")" or "") .. " — " .. ret.description
					end
				end
				sig[#sig+1] = " → " .. table.concat(rets, ", ")
			end
			return table.concat({key, table.concat(sig), table.concat(doc, "\n\n")}, "\3")
		end,
	},
	__call = function(t)
		return setmetatable({parts = {}, seen = {}}, t)
	end
}
setmetatable(DocGenerator, DocGenerator)
function TabHandler:DocsFinished()
	if not (SF.Docs and IsValid(self.html) and self.loaded) then return end
	
	self.html:RunJavascript("if(window.sfApplyDocs){sfApplyDocs(["..DocGenerator():generate().."]);}")
end

-- Converts a Starfall editor theme (SF.Editor.Themes) into Monaco theme rules and pushes them to Monaco
local function colorHex(c)
	return c and string.format("%02X%02X%02X", c.r, c.g, c.b) or nil
end

-- theme token name -> Monaco Monarch token type(s)
local themeTokenMap = {
	keyword = "keyword",
	storageType = "keyword",
	directive = "constant",
	comment = "comment",
	string = "string",
	number = "number",
	["function"] = "variable", -- function calls use the `variable` Monarch token
	method = "variable",
	library = "type", -- libraries/types use the `type` Monarch token
	userfunction = "variable",
	constant = "constant",
	identifier = "identifier",
	operator = "delimiter",
	bracket = "delimiter.bracket",
	notfound = ""
}

function TabHandler:ApplyTheme(theme)
	if not (IsValid(self.html) and self.loaded) then return end
	if not theme then return end

	local rules, n = {}, 0
	for sfName, monarchName in pairs(themeTokenMap) do
		local entry = theme[sfName]
		local hex = entry and colorHex(entry[1])
		if hex then
			n = n + 1
			rules[n] = '{token:"'..monarchName..'",foreground:"'..hex..'"}'
		end
	end

	local colors = {}
	if theme.background then colors[#colors+1] = '"editor.background":"#'..colorHex(theme.background)..'"' end
	if theme.line_highlight then colors[#colors+1] = '"editor.lineHighlightBackground":"#'..colorHex(theme.line_highlight)..'"' end
	if theme.caret then colors[#colors+1] = '"editorCursor.foreground":"#'..colorHex(theme.caret)..'"' end
	if theme.selection then colors[#colors+1] = '"editor.selectionBackground":"#'..colorHex(theme.selection)..'"' end
	if theme.gutter_foreground then colors[#colors+1] = '"editorLineNumber.foreground":"#'..colorHex(theme.gutter_foreground)..'"' end

	self.html:RunJavascript("if(window.sfApplyTheme){sfApplyTheme(["..table.concat(rules, ",").."],{"..table.concat(colors, ",").."});}")
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

	self.html = vgui.Create("DHTML")
	self.html:Dock(FILL)
	self.html:DockMargin(5, 59, 5, 5)
	self.html:SetKeyboardInputEnabled(true)
	self.html:SetMouseInputEnabled(true)
	self.html:SetHTML(
[=====[
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
		language: "starfall",
		theme: "vs-dark",
		wordBasedSuggestions: "off"
	});

	window.addEventListener("resize", () => sfeditor.layout({
		width: editorElement.offsetWidth,
		height: editorElement.offsetHeight
	}));

	// --- Starfall highlighting + docs integration ---
	const sfData = { keywords: [], items: [], methodItems: [] };
	monaco.languages.register({ id: "starfall" });
	monaco.languages.setLanguageConfiguration("starfall", {
		comments: { lineComment: "--", blockComment: ["--[[", "]" + "]"] },
		brackets: [["{", "}"], ["[", "]"], ["(", ")"]],
		autoClosingPairs: [{open:"{",close:"}"},{open:"[",close:"]"},{open:"(",close:")"},{open:'"',close:'"'},{open:"'",close:"'"}],
		surroundingPairs: [{open:"{",close:"}"},{open:"[",close:"]"},{open:"(",close:")"},{open:'"',close:'"'},{open:"'",close:"'"}]
	});
	const sfTokenizer = {
		defaultToken: "",
		tokenPostfix: ".lua",
		keywords: ["and","break","continue","do","else","elseif","end","false","for","function","goto","if","in","local","nil","not","or","repeat","return","then","true","until","while"],
		sfkeywords: [],
		brackets: [{token:"delimiter.bracket",open:"{",close:"}"},{token:"delimiter.array",open:"[",close:"]"},{token:"delimiter.parenthesis",open:"(",close:")"}],
		operators: ["+","-","*","/","%","^","#","==","~=","!=","<=",">=","<",">","=",";",":",",",".","..","...","&&","||","!"],
		symbols: /[=><!~?:&|+\-*\/\^%]+/,
		escapes: /\\(?:[abfnrtv\\"']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})/,
		tokenizer: {
			root: [
				[/--@\w+/, "keyword"],
				[/[a-zA-Z_]\w*(?=\s*\()/, { cases: { "@keywords": "keyword", "@default": "variable" } }],
				[/[a-zA-Z_]\w*/, { cases: { "@sfkeywords": "type", "@keywords": "keyword", "@default": "identifier" } }],
				{ include: "@whitespace" },
				[/(,)(\s*)([a-zA-Z_]\w*)(\s*)(:)(?!:)/, ["delimiter", "", "key", "", "delimiter"]],
				[/({)(\s*)([a-zA-Z_]\w*)(\s*)(:)(?!:)/, ["@brackets", "", "key", "", "delimiter"]],
				[/[{}()\[\]]/, "@brackets"],
				[/@symbols/, { cases: { "@operators": "delimiter", "@default": "" } }],
				[/\d*\.\d+([eE][\-+]?\d+)?/, "number.float"],
				[/0[xX][0-9a-fA-F_]*[0-9a-fA-F]/, "number.hex"],
				[/\d+?/, "number"],
				[/[;,.]/, "delimiter"],
				[/"([^"\\]|\\.)*$/, "string.invalid"],
				[/'([^'\\]|\\.)*$/, "string.invalid"],
				[/"/, "string", '@string."'],
				[/'/, "string", "@string.'"]
			],
			whitespace: [
				[/[ \t\r\n]+/, ""],
				[/--\[([=]*)\[/, "comment", "@comment.$1"],
				[/--.*$/, "comment"],
				[/\/\*/, "comment", "@gluacomment"],
				[/\/\/.*$/, "comment"]
			],
			comment: [
				[/[^\]]+/, "comment"],
				[/\]([=]*)\]/, { cases: { "$1==$S2": { token: "comment", next: "@pop" }, "@default": "comment" } }],
				[/./, "comment"]
			],
			gluacomment: [
				[/[^\*]+/, "comment"],
				[/\*\//, "comment", "@pop"],
				[/./, "comment"]
			],
			string: [
				[/[^\\"']+/, "string"],
				[/@escapes/, "string.escape"],
				[/\\./, "string.escape.invalid"],
				[/["']/, { cases: { "$#==$S2": { token: "string", next: "@pop" }, "@default": "string" } }]
			]
		}
	};
	monaco.languages.setMonarchTokensProvider("starfall", sfTokenizer);
	const sfApplyLang = () => {
		// Update keywords in the tokenizer and re-register
		if (sfTokenizer) {
			sfTokenizer.sfkeywords = sfData.keywords;
			monaco.languages.setMonarchTokensProvider("starfall", sfTokenizer);
		}
		// Force re-tokenization
		monaco.editor.getModels().forEach(m => {
			if (m.getLanguageId() === "starfall") {
				const v = m.getValue();
				m.setValue("");
				m.setValue(v);
			}
		});
	};
	// Applies a generated Starfall theme (rules + colors JSON from Lua)
	window.sfApplyTheme = (rules, colors) => {
		monaco.editor.defineTheme("starfall", {
			base: "vs-dark",
			inherit: true,
			rules: rules,
			colors: colors
		});
		monaco.editor.setTheme("starfall");
	};
	// Scans the document for user-defined functions and local variables
	const sfScanLocals = model => {
		const text = model.getValue();
		const items = [];
		const seen = {};
		const K = monaco.languages.CompletionItemKind;
		const add = (name, kind, detail) => {
			if (seen[name]) return;
			seen[name] = true;
			const item = { label: name, kind: kind, insertText: name, filterText: name, sortText: "0" + name };
			if (detail) item.detail = detail;
			items.push(item);
		};
		let m;
		// function foo(a, b) / local function foo(a, b)
		const reFunc = /(?:^|[^\w.:])function\s+([A-Za-z_]\w*)\s*\(([^)]*)\)/g;
		while ((m = reFunc.exec(text)) !== null) add(m[1], K.Function, "(" + m[2].trim() + ")");
		// foo = function(a, b) / local foo = function(a, b)
		const reFuncAssign = /(?:^|[^\w.:])([A-Za-z_]\w*)\s*=\s*function\s*\(([^)]*)\)/g;
		while ((m = reFuncAssign.exec(text)) !== null) add(m[1], K.Function, "(" + m[2].trim() + ")");
		// local x = ... / local x, y = ...
		const reLocal = /(?:^|[^\w.:])local\s+([A-Za-z_]\w*(?:\s*,\s*[A-Za-z_]\w*)*)\s*=(?!=)/g;
		while ((m = reLocal.exec(text)) !== null) {
			const names = m[1].split(/\s*,\s*/);
			for (const name of names) add(name, K.Variable);
		}
		return items;
	};
	monaco.languages.registerCompletionItemProvider("starfall", {
		triggerCharacters: [".", ":"],
		provideCompletionItems: (model, position) => {
			const word = model.getWordUntilPosition(position);
			const range = new monaco.Range(position.lineNumber, word.startColumn, position.lineNumber, word.endColumn);
			const line = model.getLineContent(position.lineNumber).substring(0, word.startColumn - 1);
			let items;
			if (/:\w*$/.test(line)) {
				// After `:` only type methods make sense
				items = sfData.methodItems;
			} else {
				// After `lib.` only that library's members make sense
				const libMatch = line.match(/([A-Za-z_]\w*)\.(\w*)$/);
				if (libMatch && sfData.libItems[ libMatch[1] ]) {
					items = sfData.libItems[ libMatch[1] ];
				} else if (libMatch) {
					items = []; // Unknown table, don't suggest anything
				} else {
					// Bare word: user-defined locals first, then docs
					items = sfScanLocals(model).concat(sfData.items);
				}
			}
			return { suggestions: items.map(c => Object.assign({ range: range }, c)) };
		}
	});
	monaco.languages.registerHoverProvider("starfall", {
		provideHover: (model, position) => {
			const word = model.getWordAtPosition(position);
			if (!word) return null;
			const name = word.word;
			const line = model.getLineContent(position.lineNumber).substring(0, word.startColumn - 1);
			let entry;
			// `lib.member` hover: resolve against that library first
			const libMatch = line.match(/([A-Za-z_]\w*)\.$/);
			if (libMatch && sfData.libHover[libMatch[1]]) {
				entry = sfData.libHover[libMatch[1]][name];
			}
			if (!entry) entry = sfData.hover[name];
			if (!entry) return null;
			const contents = [{ value: "```lua\n" + (libMatch ? libMatch[1] + "." : "") + name + entry.sig + "\n```" }];
			if (entry.doc !== "") contents.push({ value: entry.doc });
			return {
				contents: contents,
				range: new monaco.Range(position.lineNumber, word.startColumn, position.lineNumber, word.endColumn)
			};
		}
	});
	window.sfApplyDocs = words => {
		sfData.keywords = [];
		sfData.items = [];
		sfData.methodItems = [];
		sfData.libItems = {};
		sfData.hover = {};
		sfData.libHover = {};
		const K = monaco.languages.CompletionItemKind;
		const seen = {};
		for (const w of words) {
			const fields = w.split("\3");
			const tagged = fields[0];
			const signature = fields[1] || "";
			const description = fields[2] || "";
			const tag = tagged.charCodeAt(0);
			let name, kind, lib;
			if (tag === 1) { // Type method
				name = tagged.slice(1);
				kind = K.Method;
			} else if (tag === 2) { // Library member "lib.name"
				const dot = tagged.indexOf(".", 1);
				lib = tagged.slice(1, dot);
				name = tagged.slice(dot + 1);
				kind = K.Function;
			} else { // Global
				name = tagged;
				kind = K.Function;
			}
			const item = {
				label: name,
				kind: kind,
				insertText: name,
				filterText: name,
				sortText: "1" + name,
				detail: signature !== "" ? signature : undefined,
				documentation: description !== "" ? { value: description } : undefined
			};
			const hoverEntry = { sig: signature, doc: description };
			if (tag === 1) {
				sfData.methodItems.push(item);
				if (!sfData.hover[name]) sfData.hover[name] = hoverEntry;
			} else if (tag === 2) {
				(sfData.libItems[lib] = sfData.libItems[lib] || []).push(item);
				(sfData.libHover[lib] = sfData.libHover[lib] || {})[name] = hoverEntry;
			}
			if (!seen[name]) {
				seen[name] = true;
				sfData.keywords.push(name);
				sfData.items.push(item);
				if (!sfData.hover[name]) sfData.hover[name] = hoverEntry;
			}
		}
		// Re-apply Monarch so the new keyword table takes effect
		sfApplyLang();
	};

	sfeditor.addAction({
		id: "sf-new-tab",
		label: "New Tab",
		keybindings: [ monaco.KeyMod.CtrlCmd | monaco.KeyCode.KEY_N ],
		contextMenuGroupId: "File",
		run: () => sf.newTab(),
	});

	sfeditor.addAction({
		id: "sf-save",
		label: "Save",
		keybindings: [ monaco.KeyMod.CtrlCmd | monaco.KeyCode.KEY_S ],
		contextMenuGroupId: "File",
		run: () => sf.save(false),
	});

	sfeditor.addAction({
		id: "sf-save-as",
		label: "Save As",
		keybindings: [ monaco.KeyMod.CtrlCmd | monaco.KeyMod.Shift | monaco.KeyCode.KEY_S ],
		contextMenuGroupId: "File",
		run: () => sf.save(true),
	});

	sfeditor.addAction({
		id: "sf-close-tab",
		label: "Close Tab",
		keybindings: [ monaco.KeyMod.CtrlCmd | monaco.KeyCode.KEY_W ],
		contextMenuGroupId: "File",
		run: () => sf.closeTab(),
	});

	sfeditor.addAction({
		id: "sf-close-editor",
		label: "Close Editor",
		keybindings: [ monaco.KeyMod.CtrlCmd | monaco.KeyCode.KEY_Q ],
		contextMenuGroupId: "Tasks",
		run: () => sf.close(),
	});

	sfeditor.addAction({
		id: "sf-validate",
		label: "Validate",
		keybindings: [ monaco.KeyMod.CtrlCmd | monaco.KeyMod.Shift | monaco.KeyCode.Space ],
		contextMenuGroupId: "Tasks",
		run: () => sf.validate(),
	});

	sfeditor.addCommand(monaco.KeyMod.CtrlCmd | monaco.KeyCode.Tab, () => sfeditor.trigger('CtrlOutdent', 'editor.action.outdentLines'));

	sf.doneLoading();
});
</script>
</body>
</html>

]=====])

	self.html:AddFunction("sf", "newTab", function() SF.Editor.editor:NewTab() end)
	self.html:AddFunction("sf", "save", function(saveas) self:SaveTab(saveas) end)
	self.html:AddFunction("sf", "closeTab", function() SF.Editor.editor:CloseTab() end)
	self.html:AddFunction("sf", "close", function() SF.Editor.editor:Close() end)
	self.html:AddFunction("sf", "validate", function() SF.Editor.editor:Validate() end)
	self.html:AddFunction("sf", "updateCode", function(uri, code) self:GetCode(uri, code) end)
	self.html:AddFunction("sf", "doneLoading", function() self:FinishedLoading() end)

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
	TabHandler:AddSession(self)
end

function PANEL:GetCode()
	return self.code
end

function PANEL:SetCode(code)
	self.code = code
	TabHandler:SetCode(self)
end

function PANEL:OnThemeChange(theme)
	TabHandler:ApplyTheme(theme)
end

function PANEL:OnFocusChanged(gained)
	if gained then TabHandler:SetSession(self) end
end

function PANEL:OnRemove()
	TabHandler:RemoveSession(self)
end

vgui.Register(TabHandler.ControlName, PANEL, "DPanel")
return TabHandler
