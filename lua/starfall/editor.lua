-------------------------------------------------------------------------------
--	SF Editor
--	Originally created by Jazzelhawk
--	
--	To do:
--	Find new icons
-------------------------------------------------------------------------------

SF.Editor = {}

local addon_path = nil

do
	local tbl = debug.getinfo( 1 )
	local file = tbl.short_src
	addon_path = string.TrimRight( string.match( file, ".-/.-/" ), "/" )
end

if CLIENT then

	include( "sfderma.lua" )

	-- Colors
	SF.Editor.colors = {}
	SF.Editor.colors.dark 		= Color( 36, 41, 53 )
	SF.Editor.colors.meddark 	= Color( 48, 57, 92 )
	SF.Editor.colors.med 		= Color( 78, 122, 199 )
	SF.Editor.colors.medlight 	= Color( 127, 178, 240 )
	SF.Editor.colors.light 		= Color( 173, 213, 247 )

	-- Icons
	SF.Editor.icons = {}
	SF.Editor.icons.arrowr 		= Material( "radon/arrow_right.png", "noclamp smooth" )
	SF.Editor.icons.arrowl 		= Material( "radon/arrow_left.png", "noclamp smooth" )

	local defaultCode = [[--@name 
--@author 

--[[
	Starfall Scripting Environment

	More info: http://inpstarfall.github.io/Starfall
	Github: http://github.com/INPStarfall/Starfall
	Reference Page: http://sf.inp.io
	Development Thread: http://www.wiremod.com/forum/developers-showcase/22739-starfall-processor.html

	Default Keyboard shortcuts: https://github.com/ajaxorg/ace/wiki/Default-Keyboard-Shortcuts
]].."]]"

	local invalid_filename_chars = {
		["*"] = "",
		["?"] = "",
		[">"] = "",
		["<"] = "",
		["|"] = "",
		["\\"] = "",
		['"'] = "",
	}

	CreateClientConVar( "sf_editor_width", 1100, true, false )
	CreateClientConVar( "sf_editor_height", 760, true, false )
	CreateClientConVar( "sf_editor_posx", ScrW()/2-1100/2, true, false )
	CreateClientConVar( "sf_editor_posy", ScrH()/2-760/2, true, false )

	CreateClientConVar( "sf_fileviewer_width", 263, true, false )
	CreateClientConVar( "sf_fileviewer_height", 760, true, false )
	CreateClientConVar( "sf_fileviewer_posx", ScrW()/2-1100/2-263, true, false )
	CreateClientConVar( "sf_fileviewer_posy", ScrH()/2-760/2, true, false )
	CreateClientConVar( "sf_fileviewer_locked", 1, true, false )

	CreateClientConVar( "sf_editor_widgets", 1, true, false )
	CreateClientConVar( "sf_editor_linenumbers", 1, true, false )
	CreateClientConVar( "sf_editor_gutter", 1, true, false )
	CreateClientConVar( "sf_editor_invisiblecharacters", 0, true, false )
	CreateClientConVar( "sf_editor_indentguides", 1, true, false )
	CreateClientConVar( "sf_editor_activeline", 1, true, false )
	CreateClientConVar( "sf_editor_autocompletion", 1, true, false )
	CreateClientConVar( "sf_editor_fixkeys", system.IsLinux() and 1 or 0, true, false ) --maybe osx too? need someone to check
	CreateClientConVar( "sf_editor_fixconsolebug", 0, true, false )

	local aceFiles = {}
	local htmlEditorCode = nil

	function SF.Editor.init ()
		if not SF.Editor.safeToInit then 
			SF.AddNotify( LocalPlayer(), "Starfall is downloading editor files, please wait.", NOTIFY_GENERIC, 5, NOTIFYSOUND_DRIP3 ) 
			return 
		end
		if SF.Editor.initialized or #aceFiles == 0 or htmlEditorCode == nil then 
			SF.AddNotify( LocalPlayer(), "Failed to initialize Starfall editor.", NOTIFY_GENERIC, 5, NOTIFYSOUND_DRIP3 )
			return
		end

		if not file.Exists( "starfall", "DATA" ) then
			file.CreateDir( "starfall" )
		end

		SF.Editor.editor = SF.Editor.createEditor()
		SF.Editor.fileViewer = SF.Editor.createFileViewer()
		SF.Editor.fileViewer:close()
		SF.Editor.settingsWindow = SF.Editor.createSettingsWindow()
		SF.Editor.settingsWindow:close()

		SF.Editor.runJS = function ( ... ) 
			SF.Editor.editor.components.htmlPanel:QueueJavascript( ... )
		end

		SF.Editor.updateSettings()

		local tabs = util.JSONToTable( file.Read( "sf_tabs.txt" ) or "" )
		if tabs ~= nil and #tabs ~= 0 then
			for k, v in pairs( tabs ) do
				if type( v ) ~= "number" then
					SF.Editor.addTab( v.filename, v.code )
				end
			end
			SF.Editor.selectTab( tabs.selectedTab or 1 )
		else
			SF.Editor.addTab()
		end

		SF.Editor.editor:close()

		SF.Editor.initialized = true

		return true
	end

	function SF.Editor.open ()
		if not SF.Editor.initialized then 
			SF.Editor.init()
		end

		SF.Editor.editor:open()

		if CanRunConsoleCommand() then
			RunConsoleCommand( "starfall_event", "editor_open" )
		end
	end

	function SF.Editor.close ()
		SF.Editor.editor:close()

		if CanRunConsoleCommand() then
			RunConsoleCommand( "starfall_event", "editor_close" )
		end
	end

	function SF.Editor.updateCode () -- Incase anyone needs to force update the code
		SF.Editor.runJS( "console.log(\"RUNLUA:SF.Editor.getActiveTab().code = \\\"\" + addslashes(editor.getValue()) + \"\\\"\")" )
	end

	function SF.Editor.getCode ()
		return SF.Editor.getActiveTab().code
	end

	function SF.Editor.getOpenFile ()
		return SF.Editor.getActiveTab().filename
	end

	function SF.Editor.getTabHolder ()
		return SF.Editor.editor.components[ "tabHolder" ]
	end

	function SF.Editor.getActiveTab ()
		return SF.Editor.getTabHolder():getActiveTab()
	end

	function SF.Editor.selectTab ( tab )
		local tabHolder = SF.Editor.getTabHolder()
		if type( tab ) == "number" then
			tab = math.min( tab, #tabHolder.tabs )
			tab = tabHolder.tabs[ tab ]  
		end
		if tab == nil then
			SF.Editor.selectTab( 1 )
			return
		end

		tabHolder:selectTab( tab )

		SF.Editor.runJS( "selectEditSession("..tabHolder:getTabIndex( tab )..")" )
	end

	function SF.Editor.addTab ( filename, code )

		local name = filename or "generic"

		if code then
			local ppdata = {}
			SF.Preprocessor.ParseDirectives( "file", code, {}, ppdata )
			if ppdata.scriptnames and ppdata.scriptnames.file ~= "" then 
				name = ppdata.scriptnames.file
			end
		end

		code = code or defaultCode

		SF.Editor.runJS( "newEditSession(\""..string.JavascriptSafe( code or defaultCode ).."\")" )

		local tab = SF.Editor.getTabHolder():addTab( name )
		tab.code = code
		tab.name = name
		tab.filename = filename

		function tab:DoClick ()
			SF.Editor.selectTab( self )
		end

		SF.Editor.selectTab( tab )
	end

	function SF.Editor.removeTab ( tab )
		local tabHolder = SF.Editor.getTabHolder()
		if type( tab ) == "number" then
			tab = tabHolder.tabs[ tab ]  
		end
		if tab == nil then return end

		tabHolder:removeTab( tab )
	end

	function SF.Editor.saveTab ( tab )
		if not tab.filename then SF.Editor.saveTabAs( tab ) return end
		local saveFile = "starfall/" .. tab.filename
		file.Write( saveFile, tab.code )
		SF.Editor.updateTabName( tab )
		SF.AddNotify( LocalPlayer(), "Starfall code saved as " .. saveFile .. ".", NOTIFY_GENERIC, 5, NOTIFYSOUND_DRIP3 )
	end

	function SF.Editor.saveTabAs ( tab )

		SF.Editor.updateTabName( tab )

		local saveName = ""
		if tab.filename then
			saveName = string.StripExtension( tab.filename )
		else
			saveName = tab.name or "generic"
		end

		Derma_StringRequestNoBlur(
				"Save File",
				"",
				saveName,
				function ( text )
					if text == "" then return end
					text = string.gsub( text, ".", invalid_filename_chars )
					local saveFile = "starfall/" .. text .. ".txt"
					file.Write( saveFile, tab.code )
					SF.AddNotify( LocalPlayer(), "Starfall code saved as " .. saveFile .. ".", NOTIFY_GENERIC, 5, NOTIFYSOUND_DRIP3 )
					SF.Editor.fileViewer.components[ "browser" ].tree:reloadTree()
					tab.filename = text .. ".txt"
					SF.Editor.updateTabName( tab )
				end
			)
	end

	function SF.Editor.doValidation ( forceShow )

		local function valid ()
			local code = SF.Editor.getActiveTab().code

			local err = CompileString( code, "Validation", false )

			if type( err ) ~= "string" then 
				if forceShow then SF.AddNotify( LocalPlayer(), "Validation successful", NOTIFY_GENERIC, 3, NOTIFYSOUND_DRIP3 ) end
				SF.Editor.runJS( "editor.session.clearAnnotations(); clearErrorLines()" )
				return 
			end

			local row = tonumber( err:match( "%d+" ) ) - 1
			local message = err:match( ": .+$" ):sub( 3 )

			SF.Editor.runJS( string.format( "editor.session.setAnnotations([{row: %d, text: \"%s\", type: \"error\"}])", row, message:JavascriptSafe() ) )
			SF.Editor.runJS( [[
				clearErrorLines();

				var Range = ace.require("ace/range").Range;
				var range = new Range(]] .. row .. [[, 1, ]] .. row .. [[, Infinity);

				editor.session.addMarker(range, "ace_error", "screenLine");

			]] )
			
			if not forceShow then return end

			SF.Editor.runJS( "editor.session.unfold({row: " .. row .. ", column: 0})" )
			SF.Editor.runJS( "editor.scrollToLine( " .. row .. ", true )" )


		end
		if forceShow then valid() return end
		if not timer.Exists( "validationTimer" ) or ( timer.Exists( "validationTimer") and not timer.Adjust( "validationTimer", 0.5, 1, valid ) ) then
			timer.Remove( "validationTimer" )
			timer.Create( "validationTimer", 0.5, 1, valid )
		end

	end

	local function createLibraryMap ()

		local map = {}

		for lib, tbl in pairs( SF.Types ) do
			if ( lib == "Environment" or lib:find( "Library: " ) ) and type( tbl.__index ) == "table" then
				lib = lib:Replace( "Library: ", "" )
				map[ lib ] = {}
				for name, val in pairs( tbl.__index ) do
					table.insert( map[ lib ], name )
				end
			end
		end

		map.Angle = {}
		for name, val in pairs( SF.Angles.Methods ) do
			table.insert( map.Angle, name )
		end
		map.Color = {}
		for name, val in pairs( SF.Color.Methods ) do
			table.insert( map.Color, name )
		end
		map.Entity = {}
		for name, val in pairs( SF.Entities.Methods ) do
			table.insert( map.Entity, name )
		end
		map.Player = {}
		for name, val in pairs( SF.Players.Methods ) do
			table.insert( map.Player, name )
		end
		map.Sound = {}
		for name, val in pairs( SF.Sounds.Methods ) do
			table.insert( map.Sound, name )
		end
		map.VMatrix = {}
		for name, val in pairs( SF.VMatrix.Methods ) do
			table.insert( map.VMatrix, name )
		end
		map.Vector = {}
		for name, val in pairs( SF.Vectors.Methods ) do
			table.insert( map.Vector, name )
		end

		return map
	end

	function SF.Editor.refreshTab ( tab )

		local tabHolder = SF.Editor.getTabHolder()
		if type( tab ) == "number" then
			tab = tabHolder.tabs[ tab ]  
		end
		if tab == nil then return end

		SF.Editor.updateTabName( tab )

		local fileName = tab.filename
		local tabIndex = tabHolder:getTabIndex( tab )

		if not fileName or not file.Exists( "starfall/" .. fileName, "DATA" ) then 
			SF.AddNotify( LocalPlayer(), "Unable to refresh tab as file doesn't exist", NOTIFY_GENERIC, 5, NOTIFYSOUND_DRIP3 )
			return 
		end

		local fileData = file.Read( "starfall/" .. fileName, "DATA" )

		SF.Editor.runJS( "editSessions[ " .. tabIndex .. " - 1 ].setValue( \"" .. fileData:JavascriptSafe() .. "\" )" )

		SF.Editor.updateTabName( tab )

		SF.AddNotify( LocalPlayer(), "Refreshed tab: " .. fileName, NOTIFY_GENERIC, 5, NOTIFYSOUND_DRIP3 )
	end

	function SF.Editor.updateTabName ( tab )
		local ppdata = {}
		SF.Preprocessor.ParseDirectives( "tab", tab.code, {}, ppdata )
		if ppdata.scriptnames and ppdata.scriptnames.tab ~= "" then 
			tab.name = ppdata.scriptnames.tab
		else
			tab.name = tab.filename or "generic"
		end
		tab:SetText( tab.name )
	end

	function SF.Editor.createEditor ()
		local editor = vgui.Create( "StarfallFrame" )
		editor:SetSize( 800, 600 )
		editor:SetTitle( "Starfall Code Editor" )
		editor:Center()

		function editor:OnKeyCodePressed ( keyCode )
			if keyCode == KEY_S and ( input.IsKeyDown( KEY_LCONTROL ) or input.IsKeyDown( KEY_RCONTROL ) ) then
				SF.Editor.saveTab( SF.Editor.getActiveTab() )
			elseif keyCode == KEY_Q and ( input.IsKeyDown( KEY_LCONTROL ) or input.IsKeyDown( KEY_RCONTROL ) ) then
				SF.Editor.close()
			end
		end

		local buttonHolder = editor.components[ "buttonHolder" ]

		buttonHolder:getButton( "Close" ).DoClick = function ( self )
			SF.Editor.close()
		end

		buttonHolder:removeButton( "Lock" )

		local buttonSaveExit = vgui.Create( "StarfallButton", buttonHolder )
		buttonSaveExit:SetText( "Save and Exit" )
		function buttonSaveExit:DoClick ()
			SF.Editor.saveTab( SF.Editor.getActiveTab() )
			SF.Editor.close()
		end
		buttonHolder:addButton( "SaveExit", buttonSaveExit )

		local buttonSettings = vgui.Create( "StarfallButton", buttonHolder )
		buttonSettings:SetText( "Settings" )
		function buttonSettings:DoClick ()
			if SF.Editor.settingsWindow:IsVisible() then
				SF.Editor.settingsWindow:close()
			else
				SF.Editor.settingsWindow:open()
			end
		end
		buttonHolder:addButton( "Settings", buttonSettings )

		local buttonHelper = vgui.Create( "StarfallButton", buttonHolder )	
		buttonHelper:SetText( "SF Helper" )
		function buttonHelper:DoClick ()
			SF.Helper.show()
		end
		buttonHolder:addButton( "Helper", buttonHelper )

		local buttonFiles = vgui.Create( "StarfallButton", buttonHolder )
		buttonFiles:SetText( "Files" )
		function buttonFiles:DoClick ()
			if SF.Editor.fileViewer:IsVisible() then
				SF.Editor.fileViewer:close()
			else
				SF.Editor.fileViewer:open()
			end
		end
		buttonHolder:addButton( "Files", buttonFiles )

		local buttonSaveAs = vgui.Create( "StarfallButton", buttonHolder )
		buttonSaveAs:SetText( "Save As" )
		function buttonSaveAs:DoClick ()
			SF.Editor.saveTabAs( SF.Editor.getActiveTab() )
		end
		buttonHolder:addButton( "SaveAs", buttonSaveAs )

		local buttonSave = vgui.Create( "StarfallButton", buttonHolder )
		buttonSave:SetText( "Save" )
		function buttonSave:DoClick ()
			SF.Editor.saveTab( SF.Editor.getActiveTab() )
		end
		buttonHolder:addButton( "Save", buttonSave )

		local buttonNewFile = vgui.Create( "StarfallButton", buttonHolder )
		buttonNewFile:SetText( "New tab" )
		function buttonNewFile:DoClick ()
			SF.Editor.addTab()
		end
		buttonHolder:addButton( "NewFile", buttonNewFile )

		local buttonCloseTab = vgui.Create( "StarfallButton", buttonHolder )
		buttonCloseTab:SetText( "Close tab" )
		function buttonCloseTab:DoClick ()
			SF.Editor.removeTab( SF.Editor.getActiveTab() )
		end
		buttonHolder:addButton( "CloseTab", buttonCloseTab )

		local html = vgui.Create( "DHTML", editor )
		html:SetPos( 5, 54 )
		htmlEditorCode = htmlEditorCode:Replace( "<script>//replace//</script>", table.concat( aceFiles ) )
		html:SetHTML( htmlEditorCode )

		html:SetAllowLua( true )

		local map = createLibraryMap()

		html:QueueJavascript( "libraryMap = JSON.parse(\"" .. util.TableToJSON( map ):JavascriptSafe() .. "\")" )

		local libs = {}
		local functions = {}
		table.ForEach( map, function ( lib, vals )
			if lib == "Environment" or lib:GetChar( 1 ):upper() ~= lib:GetChar( 1 ) then
				table.insert( libs, lib )
			end
			table.ForEach( vals, function ( key, val )
				table.insert( functions, val )
			end )
		end )

		html:QueueJavascript( "createStarfallMode(\"" .. table.concat( libs, "|" ) .. "\", \"" .. table.concat( table.Add( table.Copy( functions ), libs ), "|" ) .. "\")" )

		function html:PerformLayout ( ... )
		 	self:SetSize( editor:GetWide() - 10, editor:GetTall() - 59 )
		end
		function html:OnKeyCodePressed ( key, notfirst )

			local function repeatKey ()
				timer.Create( "repeatKey"..key, not notfirst and 0.5 or 0.02, 1, function () self:OnKeyCodePressed( key, true ) end )
			end

			if GetConVarNumber( "sf_editor_fixkeys" ) == 0 then return end
			if ( input.IsKeyDown( KEY_LSHIFT ) or input.IsKeyDown( KEY_RSHIFT ) ) and 
				( input.IsKeyDown( KEY_LCONTROL ) or input.IsKeyDown( KEY_RCONTROL ) ) then
				if key == KEY_UP and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.modifyNumber(1)" )
					repeatKey()
				elseif key == KEY_DOWN and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.modifyNumber(-1)" )
					repeatKey()
				elseif key == KEY_LEFT and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.selection.selectWordLeft()" )
					repeatKey()
				elseif key == KEY_RIGHT and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.selection.selectWordRight()" )
					repeatKey()
				end
			elseif input.IsKeyDown( KEY_LSHIFT ) or input.IsKeyDown( KEY_RSHIFT ) then
				if key == KEY_LEFT and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.selection.selectLeft()" )
					repeatKey()
				elseif key == KEY_RIGHT and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.selection.selectRight()" )
					repeatKey()
				elseif key == KEY_UP and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.selection.selectUp()" )
					repeatKey()
				elseif key == KEY_DOWN and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.selection.selectDown()" )
					repeatKey()
				elseif key == KEY_HOME and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.selection.selectLineStart()" )
					repeatKey()
				elseif key == KEY_END and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.selection.selectLineEnd()" )
					repeatKey()
				end
			elseif input.IsKeyDown( KEY_LCONTROL ) or input.IsKeyDown( KEY_RCONTROL ) then
				if key == KEY_LEFT and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.navigateWordLeft()" )
					repeatKey()
				elseif key == KEY_RIGHT and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.navigateWordRight()" )
					repeatKey()
				elseif key == KEY_BACKSPACE and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.removeWordLeft()" )
					repeatKey()
				elseif key == KEY_DELETE and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.removeWordRight()" )
					repeatKey()
				elseif key == KEY_SPACE and input.IsKeyDown( key ) then
					SF.Editor.doValidation( true )
				elseif key == KEY_C and input.IsKeyDown( key ) then
					self:QueueJavascript( "console.log(\"RUNLUA:SetClipboardText(\\\"\"+ addslashes(editor.getSelectedText()) +\"\\\")\")" )
				end
			elseif input.IsKeyDown( KEY_LALT ) or input.IsKeyDown( KEY_RALT ) then
				if key == KEY_UP and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.moveLinesUp()" )
					repeatKey()
				elseif key == KEY_DOWN and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.moveLinesDown()" )
					repeatKey()
				end
			else
				if key == KEY_LEFT and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.navigateLeft(1)" )
					repeatKey()
				elseif key == KEY_RIGHT and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.navigateRight(1)" )
					repeatKey()
				elseif key == KEY_UP and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.navigateUp(1)" )
					repeatKey()
				elseif key == KEY_DOWN and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.navigateDown(1)" )
					repeatKey()
				elseif key == KEY_HOME and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.navigateLineStart()" )
					repeatKey()
				elseif key == KEY_END and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.navigateLineEnd()" )
					repeatKey()
				elseif key == KEY_PAGEUP and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.navigateFileStart()" )
					repeatKey()
				elseif key == KEY_PAGEDOWN and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.navigateFileEnd()" )
					repeatKey()
				elseif key == KEY_BACKSPACE and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.remove('left')" )
					repeatKey()
				elseif key == KEY_DELETE and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.remove('right')" )
					repeatKey()
				elseif key == KEY_ENTER and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.splitLine(); editor.navigateDown(1); editor.navigateLineStart()" )
					repeatKey()
				elseif key == KEY_INSERT and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.toggleOverwrite()" )
					repeatKey()
				elseif key == KEY_TAB and input.IsKeyDown( key ) then
					self:QueueJavascript( "editor.indent()" )
					repeatKey()
				end
			end
		end
		editor:AddComponent( "htmlPanel", html )

		function editor:OnOpen ()
			html:Call( "editor.focus()" )
			html:RequestFocus()
		end

		local tabHolder = vgui.Create( "StarfallTabHolder", editor )
		tabHolder:SetPos( 5, 30 )
		tabHolder.menuoptions[ #tabHolder.menuoptions + 1 ] = { "", "SPACER" }
		tabHolder.menuoptions[ #tabHolder.menuoptions + 1 ] = { "Save", function ()
			if not tabHolder.targetTab then return end
			SF.Editor.saveTab( tabHolder.targetTab )
			tabHolder.targetTab = nil
		end }
		tabHolder.menuoptions[ #tabHolder.menuoptions + 1 ] = { "Save As", function ()
			if not tabHolder.targetTab then return end
			SF.Editor.saveTabAs( tabHolder.targetTab )
			tabHolder.targetTab = nil
		end }
		tabHolder.menuoptions[ #tabHolder.menuoptions + 1 ] = { "", "SPACER" }
		tabHolder.menuoptions[ #tabHolder.menuoptions + 1 ] = { "Refresh", function ()
			if not tabHolder.targetTab then return end
			
			SF.Editor.refreshTab( tabHolder.targetTab )

			tabHolder.targetTab = nil
		end }

		function tabHolder:OnRemoveTab ( tabIndex )
			SF.Editor.runJS( "removeEditSession("..tabIndex..")" )

			if #self.tabs == 0 then
				SF.Editor.addTab()
			end
			SF.Editor.selectTab( tabIndex )
		end
		editor:AddComponent( "tabHolder", tabHolder )
		
		function editor:OnClose ()
			local tabs = {}
			for k, v in pairs( tabHolder.tabs ) do
				tabs[ k ] = {}
				tabs[ k ].filename = v.filename
				tabs[ k ].code = v.code
			end
			tabs.selectedTab = SF.Editor.getTabHolder():getTabIndex( SF.Editor.getActiveTab() )
			file.Write( "sf_tabs.txt", util.TableToJSON( tabs ) )
		end

		function editor:OnThink ()
			if self.Dragged or self.Resized then
				SF.Editor.saveSettings()
			end
		end

		return editor
	end

	function SF.Editor.createFileViewer ()
		local fileViewer = vgui.Create( "StarfallFrame" )
		fileViewer:SetSize( 200, 600 )
		fileViewer:SetTitle( "Starfall File Viewer" )
		fileViewer:Center()

		local browser = vgui.Create( "StarfallFileBrowser", fileViewer )

		local searchBox, tree = browser:getComponents()
		tree:setup( "starfall" )
		function tree:OnNodeSelected ( node )
			if not node:GetFileName() or string.GetExtensionFromFilename( node:GetFileName() ) ~= "txt" then return end
			local fileName = string.gsub( node:GetFileName(), "starfall/", "", 1 )
			local code = file.Read( node:GetFileName(), "DATA" )

			for k, v in pairs( SF.Editor.getTabHolder().tabs ) do
				if v.filename == fileName and v.code == code then
					SF.Editor.selectTab( v )
					return
				end
			end

			SF.Editor.addTab( fileName, code )
		end

		fileViewer:AddComponent( "browser", browser )

		local buttonHolder = fileViewer.components[ "buttonHolder" ]

		local buttonLock = buttonHolder:getButton( "Lock" )
		buttonLock._DoClick = buttonLock.DoClick
		buttonLock.DoClick = function ( self )
			self:_DoClick()
			SF.Editor.saveSettings()
		end

		local buttonRefresh = vgui.Create( "StarfallButton", buttonHolder )
		buttonRefresh:SetText( "Refresh" )
		buttonRefresh:SetHoverColor( Color( 7, 70, 0 ) )
		buttonRefresh:SetColor( Color( 26, 104, 17 ) )
		buttonRefresh:SetLabelColor( Color( 103, 155, 153 ) )
		function buttonRefresh:DoClick ()
			tree:reloadTree()
			searchBox:SetValue( "Search..." )
		end
		buttonHolder:addButton( "Refresh", buttonRefresh )

		function fileViewer:OnThink ()
			if self.Dragged or self.Resized then
				SF.Editor.saveSettings()
			end
		end

		function fileViewer:OnOpen ()
			SF.Editor.editor.components[ "buttonHolder" ]:getButton( "Files" ).active = true
		end

		function fileViewer:OnClose ()
			SF.Editor.editor.components[ "buttonHolder" ]:getButton( "Files" ).active = false
		end

		return fileViewer
	end

	function SF.Editor.createSettingsWindow ()
		local frame = vgui.Create( "StarfallFrame" )
		frame:SetSize( 200, 400 )
		frame:SetTitle( "Starfall Settings" )
		frame:Center()
		frame:SetVisible( true )
		frame:MakePopup( true )

		local panel = vgui.Create( "StarfallPanel", frame )
		panel:SetPos( 5, 40 )
		function panel:PerformLayout ()
			self:SetSize( frame:GetWide() - 10, frame:GetTall() - 45 )
		end
		frame:AddComponent( "panel", panel )

		local function setDoClick ( panel )
			function panel:OnChange ()
				SF.Editor.updateSettings()
			end

			return panel
		end

		local form = vgui.Create( "DForm", panel )	
		form:Dock( FILL )
		form.Header:SetVisible( false )
		form.Paint = function () end
		setDoClick(form:CheckBox( "Show fold widgets", "sf_editor_widgets" ))
		setDoClick(form:CheckBox( "Show line numbers", "sf_editor_linenumbers" ))
		setDoClick(form:CheckBox( "Show gutter", "sf_editor_gutter" ))
		setDoClick(form:CheckBox( "Show invisible characters", "sf_editor_invisiblecharacters" ))
		setDoClick(form:CheckBox( "Show indenting guides", "sf_editor_indentguides" ))
		setDoClick(form:CheckBox( "Highlight active line", "sf_editor_activeline" ))
		setDoClick(form:CheckBox( "Auto completion", "sf_editor_autocompletion" ))
		setDoClick(form:CheckBox( "Fix keys not working on Linux", "sf_editor_fixkeys" )):SetTooltip( "Some keys don't work with the editor on Linux\nEg. Enter, Tab, Backspace, Arrow keys etc..." )
		setDoClick(form:CheckBox( "Fix console bug", "sf_editor_fixconsolebug" )):SetTooltip( "Fix console opening when pressing ' or @ (UK Keyboad layout)" )

		function frame:OnOpen ()
			SF.Editor.editor.components[ "buttonHolder" ]:getButton( "Settings" ).active = true
		end

		function frame:OnClose ()
			SF.Editor.editor.components[ "buttonHolder" ]:getButton( "Settings" ).active = false
		end

		return frame
	end

	function SF.Editor.saveSettings ()
		local frame = SF.Editor.editor
		RunConsoleCommand( "sf_editor_width", frame:GetWide() )
		RunConsoleCommand( "sf_editor_height", frame:GetTall() )
		local x, y = frame:GetPos()
		RunConsoleCommand( "sf_editor_posx", x )
		RunConsoleCommand( "sf_editor_posy", y )

		local frame = SF.Editor.fileViewer
		RunConsoleCommand( "sf_fileviewer_width", frame:GetWide() )
		RunConsoleCommand( "sf_fileviewer_height", frame:GetTall() )
		local x, y = frame:GetPos()
		RunConsoleCommand( "sf_fileviewer_posx", x )
		RunConsoleCommand( "sf_fileviewer_posy", y )
		RunConsoleCommand( "sf_fileviewer_locked", frame.locked and 1 or 0 )
	end

	function SF.Editor.updateSettings ()
		local frame = SF.Editor.editor
		frame:SetWide( GetConVarNumber( "sf_editor_width" ) )
		frame:SetTall( GetConVarNumber( "sf_editor_height" ) )
		frame:SetPos( GetConVarNumber( "sf_editor_posx" ), GetConVarNumber( "sf_editor_posy" ) )

		local frame = SF.Editor.fileViewer
		frame:SetWide( GetConVarNumber( "sf_fileviewer_width" ) )
		frame:SetTall( GetConVarNumber( "sf_fileviewer_height" ) )
		frame:SetPos( GetConVarNumber( "sf_fileviewer_posx" ), GetConVarNumber( "sf_fileviewer_posy" ) )
		frame:lock( SF.Editor.editor )
		frame.locked = tobool(GetConVarNumber( "sf_fileviewer_locked" ))

		local buttonLock = frame.components[ "buttonHolder" ]:getButton( "Lock" )
		buttonLock.active = frame.locked
		buttonLock:SetText( frame.locked and "Locked" or "Unlocked" )

		local js = SF.Editor.runJS
		js( "editor.setOption(\"showFoldWidgets\", " .. GetConVarNumber( "sf_editor_widgets" ) .. ")" )
		js( "editor.setOption(\"showLineNumbers\", " .. GetConVarNumber( "sf_editor_linenumbers" ) .. ")" )
		js( "editor.setOption(\"showGutter\", " .. GetConVarNumber( "sf_editor_gutter" ) .. ")" )
		js( "editor.setOption(\"showInvisibles\", " .. GetConVarNumber( "sf_editor_invisiblecharacters" ) .. ")" )
		js( "editor.setOption(\"displayIndentGuides\", " .. GetConVarNumber( "sf_editor_indentguides" ) .. ")" )
		js( "editor.setOption(\"highlightActiveLine\", " .. GetConVarNumber( "sf_editor_activeline" ) .. ")" )
		js( "editor.setOption(\"highlightGutterLine\", " .. GetConVarNumber( "sf_editor_activeline" ) .. ")" )
		js( "editor.setOption(\"enableLiveAutocompletion\", " .. GetConVarNumber( "sf_editor_autocompletion" ) .. ")" )
	end

	--- (Client) Builds a table for the compiler to use
	-- @param maincode The source code for the main chunk
	-- @param codename The name of the main chunk
	-- @return True if ok, false if a file was missing
	-- @return A table with mainfile = codename and files = a table of filenames and their contents, or the missing file path.
	function SF.Editor.BuildIncludesTable ( maincode, codename )
		if not SF.Editor.initialized then
			if not SF.Editor.init() then return end
		end
		local tbl = {}
		maincode = maincode or SF.Editor.getCode()
		codename = codename or SF.Editor.getOpenFile() or "main"
		tbl.mainfile = codename
		tbl.files = {}
		tbl.filecount = 0
		tbl.includes = {}

		local loaded = {}
		local ppdata = {}

		local function recursiveLoad ( path )
			if loaded[ path ] then return end
			loaded[ path ] = true
			
			local code
			if path == codename and maincode then
				code = maincode
			else
				code = file.Read( "starfall/"..path, "DATA" ) or error( "Bad include: " .. path, 0 )
			end
			
			tbl.files[ path ] = code
			SF.Preprocessor.ParseDirectives( path, code, {}, ppdata )
			
			if ppdata.includes and ppdata.includes[ path ] then
				local inc = ppdata.includes[ path ]
				if not tbl.includes[ path ] then
					tbl.includes[ path ] = inc
					tbl.filecount = tbl.filecount + 1
				else
					assert( tbl.includes[ path ] == inc )
				end
				
				for i = 1, #inc do
					recursiveLoad( inc[i] )
				end
			end
		end
		local ok, msg = pcall( recursiveLoad, codename )

		local function findCycle ( file, visited, recStack )
			if not visited[ file ] then
				--Mark the current file as visited and part of recursion stack
				visited[ file ] = true
				recStack[ file ] = true

				--Recurse for all the files included in this file
				for k, v in pairs( ppdata.includes[ file ] or {} ) do
					if recStack[ v ] then
						return true, file
					elseif not visited[ v ] then
						local cyclic, cyclicFile = findCycle( v, visited, recStack )
						if cyclic then return true, cyclicFile end
					end
				end
			end
			
			--Remove this file from the recursion stack
			recStack[ file ] = false
			return false, nil
		end

		local isCyclic = false
		local cyclicFile = nil
		for k, v in pairs( ppdata.includes or {} ) do
			local cyclic, file = findCycle( k, {}, {} )
			if cyclic then
				isCyclic = true
				cyclicFile = file
				break
			end
		end
		
		if isCyclic then
			return false, "Loop in includes from: " .. cyclicFile
		end

		if ok then
			return true, tbl
		elseif msg:sub( 1, 13 ) == "Bad include: " then
			return false, msg
		else
			error( msg, 0 )
		end
	end

	net.Receive( "starfall_editor_getacefiles", function ( len )
		local index = net.ReadInt( 8 )
		aceFiles[ index ] = net.ReadString()
		
		if not tobool( net.ReadBit() ) then 
			net.Start( "starfall_editor_getacefiles" )
			net.SendToServer()
		else
			SF.Editor.safeToInit = true
			SF.Editor.init()
		end
	end )
	net.Receive( "starfall_editor_geteditorcode", function ( len )
		htmlEditorCode = net.ReadString()
	end )

	-- CLIENT ANIMATION

	local busy_players = { }
	hook.Add( "EntityRemoved", "starfall_busy_animation", function ( ply )
		busy_players[ ply ] = nil
	end )

	local emitter = ParticleEmitter( vector_origin )

	net.Receive( "starfall_editor_status", function ( len )
		local ply = net.ReadEntity()
		local status = net.ReadBit() ~= 0 -- net.ReadBit returns 0 or 1, despite net.WriteBit taking a boolean
		if not ply:IsValid() or ply == LocalPlayer() then return end

		busy_players[ ply ] = status or nil
	end )

	local rolldelta = math.rad( 80 )
	timer.Create( "starfall_editor_status", 1 / 3, 0, function ()
		rolldelta = -rolldelta
		for ply, _ in pairs( busy_players ) do
			local BoneIndx = ply:LookupBone( "ValveBiped.Bip01_Head1" ) or ply:LookupBone( "ValveBiped.HC_Head_Bone" ) or 0
			local BonePos, BoneAng = ply:GetBonePosition( BoneIndx )
			local particle = emitter:Add( "radon/starfall2", BonePos + Vector( math.random( -10, 10 ), math.random( -10, 10 ), 60 + math.random( 0, 10 ) ) )
			if particle then
				particle:SetColor( math.random( 30, 50 ), math.random( 40, 150 ), math.random( 180, 220 ) )
				particle:SetVelocity( Vector( 0, 0, -40 ) )

				particle:SetDieTime( 1.5 )
				particle:SetLifeTime( 0 )

				particle:SetStartSize( 10 )
				particle:SetEndSize( 5 )

				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )

				particle:SetRollDelta( rolldelta )
			end
		end
	end )

elseif SERVER then

	util.AddNetworkString( "starfall_editor_status" )
	util.AddNetworkString( "starfall_editor_getacefiles" )
	util.AddNetworkString( "starfall_editor_geteditorcode" )

	local function getFiles ( dir, dir2 )
		local files = {}
		local dir2 = dir2 or ""
		local f, directories = file.Find( dir .. "/" .. dir2 .. "/*", "GAME" )
		for k, v in pairs( f ) do
			files[ #files + 1 ] = dir2 .. "/" .. v
		end
		for k, v in pairs( directories ) do
			table.Add( files, getFiles( dir, dir2 .. "/" .. v ) )
		end
		return files
	end

	local acefiles = {}

	do
		local netSize = 64000

		local files = file.Find( addon_path .. "/html/starfall/ace/*", "GAME" )

		local out = ""

		for k, v in pairs( files ) do
			out = out .. "<script>\n" .. file.Read( addon_path .. "/html/starfall/ace/" .. v, "GAME" ) .. "</script>\n"
		end

		for i = 1, math.ceil( out:len() / netSize ) do
			acefiles[i] = out:sub( (i - 1)*netSize + 1, i*netSize )
		end
	end


	local plyIndex = {}
	local function sendAceFile ( len, ply )
		local index = plyIndex[ ply ]
		net.Start( "starfall_editor_getacefiles" )
			net.WriteInt( index, 8 )
			net.WriteString( acefiles[ index ] )
			net.WriteBit( index == #acefiles )
		net.Send( ply )
		plyIndex[ ply ] = index + 1
	end

	hook.Add( "PlayerInitialSpawn", "starfall_file_init", function ( ply )
		net.Start( "starfall_editor_geteditorcode" )
			net.WriteString( file.Read( addon_path .. "/html/starfall/editor.html", "GAME" ) )
		net.Send( ply )

		plyIndex[ ply ] = 1
		sendAceFile( nil, ply )
	end )

	net.Receive( "starfall_editor_getacefiles", sendAceFile )

	for k, v in pairs( getFiles( addon_path, "materials/radon" ) ) do
		resource.AddFile( v )
	end

	local starfall_event = {}

	concommand.Add( "starfall_event", function ( ply, command, args )
		local handler = starfall_event[ args[ 1 ] ]
		if not handler then return end
		return handler( ply, args )
	end )

	function starfall_event.editor_open ( ply, args )
		net.Start( "starfall_editor_status" )
		net.WriteEntity( ply )
		net.WriteBit( true )
		net.Broadcast()
	end

	function starfall_event.editor_close ( ply, args )
		net.Start( "starfall_editor_status" )
		net.WriteEntity( ply )
		net.WriteBit( false )
		net.Broadcast()
	end
end
