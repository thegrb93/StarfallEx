----------------------------------------------------
-- ACE TabHandler
----------------------------------------------------

local TabHandler = {
	ControlName = "sf_tab_ace", -- Its name of vgui panel used by handler, there has to be one
	IsEditor = true, -- If it should be treated as editor of file, like ACE or Wire
	Loaded = false,
}
local PANEL = {} -- It's our VGUI

----------------
-- Handler part
----------------
TabHandler.SessionTabs = {}
local currentSession

local runJS = function ( ... )
	TabHandler.html:QueueJavascript( ... )
end

local function saveSettings()
	
end

local function updateSettings()

	runJS( [[
		editSessions.forEach( function( session ) {
				session.setUseWrapMode( ]] .. GetConVarNumber( "sf_editor_ace_wordwrap" ) .. [[ )
			} )
		]] )
	runJS( "editor.setOption(\"showFoldWidgets\", " .. GetConVarNumber( "sf_editor_ace_widgets" ) .. ");" )
	runJS( "editor.setOption(\"showLineNumbers\", " .. GetConVarNumber( "sf_editor_ace_linenumbers" ) .. ");" )
	runJS( "editor.setOption(\"showGutter\", " .. GetConVarNumber( "sf_editor_ace_gutter" ) .. ");" )
	runJS( "editor.setOption(\"showInvisibles\", " .. GetConVarNumber( "sf_editor_ace_invisiblecharacters" ) .. ");" )
	runJS( "editor.setOption(\"displayIndentGuides\", " .. GetConVarNumber( "sf_editor_ace_indentguides" ) .. ");" )
	runJS( "editor.setOption(\"highlightActiveLine\", " .. GetConVarNumber( "sf_editor_ace_activeline" ) .. ");" )
	runJS( "editor.setOption(\"highlightGutterLine\", " .. GetConVarNumber( "sf_editor_ace_activeline" ) .. ");" )
	runJS( "editor.setOption(\"enableLiveAutocompletion\", " .. GetConVarNumber( "sf_editor_ace_liveautocompletion" ) .. ");" )
	runJS( "editor.setOption(\"enableBasicAutocompletion\", " .. GetConVarNumber( "sf_editor_ace_autocompletion" ) .. ");" )
	runJS( "setFoldKeybinds( " .. GetConVarNumber( "sf_editor_ace_disablelinefolding" ) .. ");" )
	runJS( "editor.setKeyboardHandler(\"ace/keyboard/" .. GetConVarString( "sf_editor_ace_keybindings") .. "\");" )
	runJS( "editor.setFontSize(" .. GetConVarNumber( "sf_editor_ace_fontsize" ) .. ");" )

end

local function getSessionID(tab)
	return table.KeyFromValue( TabHandler.SessionTabs, tab )
end

local function createSession(tab)
	local settings = util.TableToJSON({
			wrap = GetConVarNumber( "sf_editor_ace_wordwrap" )
		}):JavascriptSafe()
	if TabHandler.Loaded then
		runJS( "newEditSession(\"" .. string.JavascriptSafe( tab.code or "" ) .. "\", JSON.parse(\"" .. settings .. "\"))" )
	end

	table.insert(TabHandler.SessionTabs,tab)
end

local function removeSession(tab)

	local id = getSessionID(tab)
	if TabHandler.Loaded then
		runJS( "removeEditSession("..id..")" )
	end
	table.remove(TabHandler.SessionTabs,id)

end

local function selectSession(tab)
	if TabHandler.Loaded then
		runJS( "selectEditSession("..getSessionID(tab)..")" )
	end
	currentSession = tab
end

local function setSessionValue(tab, text)
	runJS( "setEditSessionValue("..getSessionID(tab)..",\""..string.JavascriptSafe(text).."\")" )
end

local function loadSessions()
	local settings = util.TableToJSON({
			wrap = GetConVarNumber( "sf_editor_ace_wordwrap" )
		}):JavascriptSafe()
	for k,v in pairs(TabHandler.SessionTabs) do
		runJS( "newEditSession(\"" .. string.JavascriptSafe( v.code or "" ) .. "\", JSON.parse(\"" .. settings .. "\"))" )
	end
	if currentSession then
		selectSession(currentSession)
	end
end

local function createLibraryMap ()

	local libMap, libs = {}, {}

	libMap[ "Environment" ] = {}
	for name, val in pairs( SF.DefaultEnvironment ) do
		table.insert( libMap[ "Environment" ], name )
		table.insert( libs, name )
	end

	for lib, tbl in pairs( SF.Libraries.libraries ) do
		libMap[ lib ] = {}
		for name, val in pairs( tbl ) do
			table.insert( libMap[ lib ], name )
			table.insert( libs, lib.."\\."..name )
		end
	end

	for lib, tbl in pairs( SF.Types ) do
		if type( tbl.__index ) == "table" then
			for name, val in pairs( tbl.__index ) do
				table.insert( libs, "\\:"..name )
			end
		end
	end

	return libMap, table.concat( libs, "|" )
end
local function fixConsole(key)
	if key == 57 then -- EN-US
		gui.ActivateGameUI()
	end
	--TODO: Add @ for some layouts
end

local function fixKeys(key, notfirst)
	
	local function repeatKey ()
		timer.Create( "repeatKey"..key, not notfirst and 0.5 or 0.02, 1, function () TabHandler.html:OnKeyCodePressed( key, true ) end )
	end
		
	if ( input.IsKeyDown( KEY_LSHIFT ) or input.IsKeyDown( KEY_RSHIFT ) ) and
	( input.IsKeyDown( KEY_LCONTROL ) or input.IsKeyDown( KEY_RCONTROL ) ) and
	not input.IsKeyDown( KEY_LALT ) then
		if key == KEY_UP and input.IsKeyDown( key ) then
			runJS( "editor.modifyNumber(1)" )
			repeatKey()
		elseif key == KEY_DOWN and input.IsKeyDown( key ) then
			runJS( "editor.modifyNumber(-1)" )
			repeatKey()
		elseif key == KEY_LEFT and input.IsKeyDown( key ) then
			runJS( "editor.selection.selectWordLeft()" )
			repeatKey()
		elseif key == KEY_RIGHT and input.IsKeyDown( key ) then
			runJS( "editor.selection.selectWordRight()" )
			repeatKey()
		end
	elseif input.IsKeyDown( KEY_LSHIFT ) or input.IsKeyDown( KEY_RSHIFT ) then
		if key == KEY_LEFT and input.IsKeyDown( key ) then
			runJS( "editor.selection.selectLeft()" )
			repeatKey()
		elseif key == KEY_RIGHT and input.IsKeyDown( key ) then
			runJS( "editor.selection.selectRight()" )
			repeatKey()
		elseif key == KEY_UP and input.IsKeyDown( key ) then
			runJS( "editor.selection.selectUp()" )
			repeatKey()
		elseif key == KEY_DOWN and input.IsKeyDown( key ) then
			runJS( "editor.selection.selectDown()" )
			repeatKey()
		elseif key == KEY_HOME and input.IsKeyDown( key ) then
			runJS( "editor.selection.selectLineStart()" )
			repeatKey()
		elseif key == KEY_END and input.IsKeyDown( key ) then
			runJS( "editor.selection.selectLineEnd()" )
			repeatKey()
		end
	elseif input.IsKeyDown( KEY_LCONTROL ) or input.IsKeyDown( KEY_RCONTROL ) and not input.IsKeyDown( KEY_LALT ) then
		if key == KEY_LEFT and input.IsKeyDown( key ) then
			runJS( "editor.navigateWordLeft()" )
			repeatKey()
		elseif key == KEY_RIGHT and input.IsKeyDown( key ) then
			runJS( "editor.navigateWordRight()" )
			repeatKey()
		elseif key == KEY_BACKSPACE and input.IsKeyDown( key ) then
			runJS( "editor.removeWordLeft()" )
			repeatKey()
		elseif key == KEY_DELETE and input.IsKeyDown( key ) then
			runJS( "editor.removeWordRight()" )
			repeatKey()
		elseif key == KEY_SPACE and input.IsKeyDown( key ) then
			SF.Editor.doValidation( true )
		elseif key == KEY_C and input.IsKeyDown( key ) then
			runJS( "console.copyClipboard(editor.getSelectedText())" )
		end
	elseif input.IsKeyDown( KEY_LALT ) or input.IsKeyDown( KEY_RALT ) then
		if key == KEY_UP and input.IsKeyDown( key ) then
			runJS( "editor.moveLinesUp()" )
			repeatKey()
		elseif key == KEY_DOWN and input.IsKeyDown( key ) then
			runJS( "editor.moveLinesDown()" )
			repeatKey()
		end
	else
		if key == KEY_LEFT and input.IsKeyDown( key ) then
			runJS( "editor.navigateLeft(1)" )
			repeatKey()
		elseif key == KEY_RIGHT and input.IsKeyDown( key ) then
			runJS( "editor.navigateRight(1)" )
			repeatKey()
		elseif key == KEY_UP and input.IsKeyDown( key ) then
			runJS( "editor.navigateUp(1)" )
			repeatKey()
		elseif key == KEY_DOWN and input.IsKeyDown( key ) then
			runJS( "editor.navigateDown(1)" )
			repeatKey()
		elseif key == KEY_HOME and input.IsKeyDown( key ) then
			runJS( "editor.navigateLineStart()" )
			repeatKey()
		elseif key == KEY_END and input.IsKeyDown( key ) then
			runJS( "editor.navigateLineEnd()" )
			repeatKey()
		elseif key == KEY_PAGEUP and input.IsKeyDown( key ) then
			runJS( "editor.navigateFileStart()" )
			repeatKey()
		elseif key == KEY_PAGEDOWN and input.IsKeyDown( key ) then
			runJS( "editor.navigateFileEnd()" )
			repeatKey()
		elseif key == KEY_BACKSPACE and input.IsKeyDown( key ) then
			runJS( "editor.remove('left')" )
			repeatKey()
		elseif key == KEY_DELETE and input.IsKeyDown( key ) then
			runJS( "editor.remove('right')" )
			repeatKey()
		elseif key == KEY_ENTER and input.IsKeyDown( key ) then
			runJS( "editor.splitLine(); editor.navigateDown(1); editor.navigateLineStart()" )
			repeatKey()
		elseif key == KEY_INSERT and input.IsKeyDown( key ) then
			runJS( "editor.toggleOverwrite()" )
			repeatKey()
		elseif key == KEY_TAB and input.IsKeyDown( key ) then
			runJS( "editor.indent()" )
			repeatKey()
		end
	end

end

function TabHandler:registerSettings()	

	--Adding settings
	local sheet = SF.Editor.editor:AddControlPanelTab("Ace", "icon16/cog.png", "ACE options.")
	local panel = sheet.Panel
	
	local scrollPanel = vgui.Create( "DScrollPanel", panel )
	scrollPanel:Dock( FILL )
	scrollPanel:SetPaintBackgroundEnabled( false )

	local form = vgui.Create( "DForm", scrollPanel )	
	form:Dock( FILL )
	form:DockPadding( 0, 10, 0, 10 )
	form.Header:SetVisible( false )
	form.Paint = function () end

	local function setDoClick ( panel )
		panel:SetDark(false)
		function panel:OnChange ()
			saveSettings()
			timer.Simple( 0.1, function () updateSettings() end )
		end

		return panel
	end
	local function setWang( wang, label )
		function wang:OnValueChanged()
			saveSettings()
			timer.Simple( 0.1, function () updateSettings() end )
		end
		wang:GetParent():DockPadding( 10, 1, 10, 1 )
		wang:Dock( RIGHT )
		label:SetDark(false)
		return wang, label
	end
	
	setWang( form:NumberWang( "Font size", "sf_editor_ace_fontsize", 5, 40 ) )
	local combobox, label = form:ComboBox( "Keybinding", "sf_editor_ace_keybindings" )
	label:SetDark(false)
	combobox:AddChoice( "ace" )
	combobox:AddChoice( "vim" )
	combobox:AddChoice( "emacs" )
	
	setDoClick( form:CheckBox( "Enable word wrap", "sf_editor_ace_wordwrap" ) )
	setDoClick( form:CheckBox( "Show fold widgets", "sf_editor_ace_widgets" ) )
	setDoClick( form:CheckBox( "Show line numbers", "sf_editor_ace_linenumbers" ) )
	setDoClick( form:CheckBox( "Show gutter", "sf_editor_ace_gutter" ) )
	setDoClick( form:CheckBox( "Show invisible characters", "sf_editor_ace_invisiblecharacters" ) )
	setDoClick( form:CheckBox( "Show indenting guides", "sf_editor_ace_indentguides" ) )
	setDoClick( form:CheckBox( "Highlight active line", "sf_editor_ace_activeline" ) )
	setDoClick( form:CheckBox( "Auto completion", "sf_editor_ace_autocompletion" ) )
	setDoClick( form:CheckBox( "Live Auto completion", "sf_editor_ace_liveautocompletion" ) )
	setDoClick( form:CheckBox( "Fix keys not working on Linux", "sf_editor_ace_fixkeys" ) ):SetTooltip( "Some keys don't work with the editor on Linux\nEg. Enter, Tab, Backspace, Arrow keys etc..." )
	setDoClick( form:CheckBox( "Fix console bug", "sf_editor_ace_fixconsolebug" ) ):SetTooltip( "Fix console opening when pressing ' or @ (UK Keyboad layout)" )
	setDoClick( form:CheckBox( "Disable line folding keybinds", "sf_editor_ace_disablelinefolding" ) )	
	--
	
end

function TabHandler:init() -- It's caled when editor is initalized, you can create library map there etc

	local html = vgui.Create( "DHTML" )
	html:Dock( FILL )
	html:DockMargin( 5, 59, 5, 5 )
	html:SetKeyboardInputEnabled( true )
	html:SetMouseInputEnabled( true )
	local files = file.Find("html/starfalleditor*","GAME")
	local version if files[1] then version = string.match(files[1], "starfalleditor(%d+)%.html") end
	if version then
		html:OpenURL( "asset://garrysmod/html/starfalleditor"..version..".html" )
	else
		--Files failed to send, use github
		html:OpenURL( "http://thegrb93.github.io/StarfallEx/starfall/starfalleditor1.html" )
	end

	html:AddFunction( "console", "copyCode", function( code )
			currentSession.code = code
		end)
	html:AddFunction( "console", "copyClipboard", function( code )
			timer.Simple(0, function() SetClipboardText( code ) end)
		end)

	html:AddFunction( "console", "doValidation", SF.Editor.doValidation)

	local function FinishedLoadingEditor()
		local libMap, libs = createLibraryMap()
		html:QueueJavascript( "libraryMap = " .. util.TableToJSON( libMap ) )
		html:QueueJavascript( "createStarfallMode(\"" .. libs .. "\")" )
		function html:OnKeyCodePressed ( key, notfirst )

			if input.IsKeyDown(KEY_LCONTROL) then
				self:OnShortcut(key)
			end
			
			if tobool( GetConVarNumber( "sf_editor_ace_fixconsolebug" ) ) then --Additional fix for some layouts
				fixConsole(key)
			end
			
			if tobool(GetConVarNumber( "sf_editor_ace_fixkeys" )) then 
				fixKeys( key, notfirst )
			end
		end
		TabHandler.Loaded = true
		loadSessions()
		updateSettings()
	end
	local readyTime
	hook.Add("Think","SF_LoadingAce",function()
			if not html:IsLoading() then
				if not readyTime then readyTime = CurTime()+0.1 end
				if CurTime() > readyTime then
					hook.Remove("Think", "SF_LoadingAce")
					FinishedLoadingEditor()
				end
			end
		end)
	TabHandler.html = html
	TabHandler.html:SetVisible(false)
end

function TabHandler:cleanup() -- It's caled when editor is marked for disposal
	print("Cleanup called!")
	TabHandler.html:Remove()
	TabHandler.html = nil -- Getting rid of old dhtml
	TabHandler.SessionTabs = {} -- Clearing tabs
	TabHandler.Loaded = false -- Well, it wont be loaded anymore
	currentSession = nil
	hook.Remove("Think", "SF_LoadingAce") -- Just in case it didnt even fully load yet
end
-------------
-- VGUI part
-------------

function PANEL:Init() --That's init of VGUI like other PANEL:Methods(), separate for each tab
	createSession(self)
	self:SetBackgroundColor(Color(39, 40, 34))
end

function PANEL:getCode() -- Return name of hanlder or code if it's editor
	return self.code or ""
end

function PANEL:setCode(code)
	self.code = code
	if TabHandler.Loaded then
		setSessionValue(self, code)
	end
end

function PANEL:OnFocusChanged(gained) -- When this tab is opened
	if gained then
		selectSession(self)
		TabHandler.html:SetParent(self)
		TabHandler.html.OnShortcut = function(_, code) self:OnShortcut(code) end -- Catching shortcuts from DHTML

		self:DockPadding(0, 0, 0, 0)
		TabHandler.html:DockMargin(0, 0, 0, 0)
		TabHandler.html:Dock(FILL)
		TabHandler.html:SetVisible(true)
		TabHandler.html:RequestFocus()
	end --We dont do anything when lost, because it loses focus even when child is interacted
end

function PANEL:OnRemove() -- We dont want html to get removed with tab as its shared
	removeSession(self)
	if TabHandler.html:GetParent() == self then
		TabHandler.html:SetVisible(false)
		TabHandler.html:SetParent(nil)
	end
end

--------------
-- We're done
--------------
vgui.Register(TabHandler.ControlName, PANEL, "DPanel") -- Registering VGUI element of handler
return TabHandler -- Our file has to return table of handler
