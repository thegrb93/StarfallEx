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
--@shared 

--[[
	Starfall Scripting Environment

	Github: https://github.com/thegrb93/StarfallEx
	Reference Page: http://thegrb93.github.io/Starfall/

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
	CreateClientConVar( "sf_editor_posx", ScrW() / 2 - 1100 / 2, true, false )
	CreateClientConVar( "sf_editor_posy", ScrH() / 2 - 760 / 2, true, false )

	CreateClientConVar( "sf_fileviewer_width", 263, true, false )
	CreateClientConVar( "sf_fileviewer_height", 760, true, false )
	CreateClientConVar( "sf_fileviewer_posx", ScrW() / 2 - 1100 / 2 - 263, true, false )
	CreateClientConVar( "sf_fileviewer_posy", ScrH() / 2 - 760 / 2, true, false )
	CreateClientConVar( "sf_fileviewer_locked", 1, true, false )

	CreateClientConVar( "sf_modelviewer_width", 930, true, false )
	CreateClientConVar( "sf_modelviewer_height", 615, true, false )
	CreateClientConVar( "sf_modelviewer_posx", ScrW() / 2 - 930 / 2, true, false )
	CreateClientConVar( "sf_modelviewer_posy", ScrH() / 2 - 615 / 2, true, false )

	CreateClientConVar( "sf_editor_wordwrap", 1, true, false )
	CreateClientConVar( "sf_editor_widgets", 1, true, false )
	CreateClientConVar( "sf_editor_linenumbers", 1, true, false )
	CreateClientConVar( "sf_editor_gutter", 1, true, false )
	CreateClientConVar( "sf_editor_invisiblecharacters", 0, true, false )
	CreateClientConVar( "sf_editor_indentguides", 1, true, false )
	CreateClientConVar( "sf_editor_activeline", 1, true, false )
	CreateClientConVar( "sf_editor_autocompletion", 1, true, false )
	CreateClientConVar( "sf_editor_liveautocompletion", 0, true, false )
	CreateClientConVar( "sf_editor_fixkeys", system.IsLinux() and 1 or 0, true, false ) --maybe osx too? need someone to check
	CreateClientConVar( "sf_editor_fixconsolebug", 0, true, false )
	CreateClientConVar( "sf_editor_disablelinefolding", 0, true, false )
	CreateClientConVar( "sf_editor_keybindings", "ace", true, false )
	CreateClientConVar( "sf_editor_fontsize", 13, true, false )

	local editorUrl = "http://thegrb93.github.io/StarfallEx/starfall/editor.html"

	function SF.Editor.init ()

		if not file.Exists( "starfall", "DATA" ) then
			file.CreateDir( "starfall" )
		end
		if SF.Editor.editor then return end

		SF.Editor.createEditor()
		SF.Editor.fileViewer = SF.Editor.createFileViewer()
		SF.Editor.settingsWindow = SF.Editor.createSettingsWindow()
		SF.Editor.modelViewer = SF.Editor.createModelViewer()
		SF.Editor.permissionsWindow = SF.Editor.createPermissionsWindow()

		SF.Editor.runJS = function ( ... ) 
			SF.Editor.editor.components.htmlPanel:QueueJavascript( ... )
		end
		
		SF.Editor.updateSettings ()
	end

	function SF.Editor.open ()
		if not SF.Editor.initialized then
			SF.Editor.init ()
		end
		
		SF.Editor.editor:open()
		RunConsoleCommand( "starfall_event", "editor_open" )
	end

	function SF.Editor.close ()
		SF.Editor.editor:close()
		RunConsoleCommand( "starfall_event", "editor_close" )
	end

	function SF.Editor.updateCode () -- Incase anyone needs to force update the code
		SF.Editor.runJS( "console.log(\"RUNLUA:SF.Editor.getActiveTab().code = \\\"\" + addslashes(editor.getValue()) + \"\\\"\")" )
	end

	function SF.Editor.getCode ()
		if SF.Editor.getActiveTab() then
			return SF.Editor.getActiveTab().code
		end
		return ""
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

		if SF.Editor.initialized then
			SF.Editor.runJS( "selectEditSession("..tabHolder:getTabIndex( tab )..")" )
		end
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

		-- Settings to pass to editor when creating a new session
		local settings = util.TableToJSON({
			wrap = GetConVarNumber( "sf_editor_wordwrap" )
		}):JavascriptSafe()

		if SF.Editor.initialized then
			SF.Editor.runJS( "newEditSession(\"" .. string.JavascriptSafe( code or defaultCode ) .. "\", JSON.parse(\"" .. settings .. "\"))" )
		end

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
		SF.AddNotify( LocalPlayer(), "Starfall code saved as " .. saveFile .. ".", "GENERIC", 5, "DRIP3" )
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
					SF.AddNotify( LocalPlayer(), "Starfall code saved as " .. saveFile .. ".", "GENERIC", 5, "DRIP3" )
					SF.Editor.fileViewer.components[ "browser" ].tree:reloadTree()
					tab.filename = text .. ".txt"
					SF.Editor.updateTabName( tab )
				end
			)
	end

	function SF.Editor.doValidation ( forceShow )

		local function valid ()
			local code = SF.Editor.getActiveTab().code
			if code and code == "" then SF.Editor.runJS( "editor.session.clearAnnotations(); clearErrorLines()" ) return end

			local err = CompileString( code, "Validation", false )

			if type( err ) ~= "string" then 
				if forceShow then SF.AddNotify( LocalPlayer(), "Validation successful", "GENERIC", 3, "DRIP3" ) end
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
			SF.AddNotify( LocalPlayer(), "Unable to refresh tab as file doesn't exist", "GENERIC", 5, "DRIP3" )
			return 
		end

		local fileData = file.Read( "starfall/" .. fileName, "DATA" )

		SF.Editor.runJS( "editSessions[ " .. tabIndex .. " - 1 ].setValue( \"" .. fileData:JavascriptSafe() .. "\" )" )

		SF.Editor.updateTabName( tab )

		SF.AddNotify( LocalPlayer(), "Refreshed tab: " .. fileName, "GENERIC", 5, "DRIP3" )
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
		editor:DockPadding( 0, 0, 0, 0 )
		editor:SetTitle( "Starfall Code Editor" )
		editor:Center()

		SF.Editor.editor = editor

		function editor:OnKeyCodePressed ( keyCode )
			if keyCode == KEY_S and ( input.IsKeyDown( KEY_LCONTROL ) or input.IsKeyDown( KEY_RCONTROL ) ) and not input.IsKeyDown( KEY_LALT ) then
				SF.Editor.saveTab( SF.Editor.getActiveTab() )
			elseif keyCode == KEY_Q and ( input.IsKeyDown( KEY_LCONTROL ) or input.IsKeyDown( KEY_RCONTROL ) ) and not input.IsKeyDown( KEY_LALT ) then
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
			if SF.Helper.Frame and SF.Helper.Frame:IsVisible() then
				SF.Helper.Frame:close()
			else
				SF.Helper.show()
			end
		end
		buttonHolder:addButton( "Helper", buttonHelper )

		local buttonModels = vgui.Create( "StarfallButton", buttonHolder )	
		buttonModels:SetText( "Model Viewer" )
		function buttonModels:DoClick ()
			if SF.Editor.modelViewer:IsVisible() then
				SF.Editor.modelViewer:close()
			else
				SF.Editor.modelViewer:open()
			end
		end
		buttonHolder:addButton( "Model Viewer", buttonModels )

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
		html:Dock( FILL )
		html:DockMargin( 5, 59, 5, 5 )
		html:SetKeyboardInputEnabled( true )
		html:SetMouseInputEnabled( true )
		html:SetAllowLua( true )
		html:OpenURL( editorUrl )
		html:AddFunction( "console", "copyCode", function( code )
			SF.Editor.getActiveTab().code = code
			SF.Editor.doValidation()
		end)
		
		local tabs = util.JSONToTable( file.Read( "sf_tabs.txt" ) or "" )
			
		local function FinishedLoadingEditor()
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

			function html:OnKeyCodePressed ( key, notfirst )

				local function repeatKey ()
					timer.Create( "repeatKey"..key, not notfirst and 0.5 or 0.02, 1, function () self:OnKeyCodePressed( key, true ) end )
				end

				if GetConVarNumber( "sf_editor_fixkeys" ) == 0 then return end
				if ( input.IsKeyDown( KEY_LSHIFT ) or input.IsKeyDown( KEY_RSHIFT ) ) and 
					( input.IsKeyDown( KEY_LCONTROL ) or input.IsKeyDown( KEY_RCONTROL ) ) and
					not input.IsKeyDown( KEY_LALT ) then
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
				elseif input.IsKeyDown( KEY_LCONTROL ) or input.IsKeyDown( KEY_RCONTROL ) and not input.IsKeyDown( KEY_LALT )  then
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
			
			SF.Editor.updateSettings( true )
			
			local tabHolder = SF.Editor.getTabHolder()
			local wrapsetting = util.TableToJSON({
				wrap = GetConVarNumber( "sf_editor_wordwrap" )
			}):JavascriptSafe()
			for _, tab in pairs(tabHolder.tabs) do
				SF.Editor.runJS( "newEditSession(\"" .. string.JavascriptSafe( tab.code or defaultCode ) .. "\", JSON.parse(\"" .. wrapsetting .. "\"))" )
			end
			SF.Editor.runJS( "selectEditSession("..tabHolder:getTabIndex( SF.Editor.getActiveTab() )..")" )
			
			SF.Editor.initialized = true
		end
		
		local readyTime
		hook.Add("Think","SF_LoadingEditor",function()
			if not html:IsLoading() then
				if not readyTime then readyTime = CurTime()+0.1 end
				if CurTime() > readyTime then
					hook.Remove("Think","SF_LoadingEditor")
					FinishedLoadingEditor()
				end
			end
		end)
		
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

			SF.Editor.saveSettings()

			local activeWep = LocalPlayer():GetActiveWeapon()
			if IsValid( activeWep ) and activeWep:GetClass() == "gmod_tool" and activeWep.Mode == "starfall_processor" then
				local model = nil
				local ppdata = {}
				SF.Preprocessor.ParseDirectives( "file", SF.Editor.getCode(), {}, ppdata )
				if ppdata.models and ppdata.models.file ~= "" then
					model = ppdata.models.file 
				end

				RunConsoleCommand("starfall_processor_ScriptModel", model or "")
			end 
		end

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

		function fileViewer:OnOpen ()
			SF.Editor.editor.components[ "buttonHolder" ]:getButton( "Files" ).active = true
		end

		function fileViewer:OnClose ()
			SF.Editor.editor.components[ "buttonHolder" ]:getButton( "Files" ).active = false
			SF.Editor.saveSettings()
		end

		return fileViewer
	end

	function SF.Editor.createSettingsWindow ()
		local frame = vgui.Create( "StarfallFrame" )
		frame:SetSize( 200, 400 )
		frame:SetTitle( "Starfall Settings" )
		frame:Center()

		local panel = vgui.Create( "StarfallPanel", frame )
		panel:Dock( FILL )
		panel:DockMargin( 0, 5, 0, 0 )
		frame:AddComponent( "panel", panel )

		local scrollPanel = vgui.Create( "DScrollPanel", panel )
		scrollPanel:Dock( FILL )
		scrollPanel:SetPaintBackgroundEnabled( false )

		local form = vgui.Create( "DForm", scrollPanel )	
		form:Dock( FILL )
		form:DockPadding( 0, 10, 0, 10 )
		form.Header:SetVisible( false )
		form.Paint = function () end

		local buttonPermissions = vgui.Create( "StarfallButton" )
		buttonPermissions:SetText( "Permissions" )
		function buttonPermissions:DoClick ()
			if SF.Editor.permissionsWindow:IsVisible() then
				SF.Editor.permissionsWindow:close()
			else
				SF.Editor.permissionsWindow:open()
			end
		end
		form:AddItem( buttonPermissions )

		local function setDoClick ( panel )
			function panel:OnChange ()
				SF.Editor.saveSettings()
				timer.Simple( 0.1, function () SF.Editor.updateSettings( true ) end )
			end

			return panel
		end
		local function setWang( wang, label )
			function wang:OnValueChanged()
				SF.Editor.saveSettings()
				timer.Simple( 0.1, function () SF.Editor.updateSettings( true ) end )
			end
			wang:GetParent():DockPadding( 10, 1, 10, 1 )
			wang:Dock( RIGHT )

			return wang, label
		end
		
		setWang( form:NumberWang( "Font size", "sf_editor_fontsize", 5, 40 ) )
		local combobox, label = form:ComboBox( "Keybinding", "sf_editor_keybindings" )
		combobox:AddChoice( "ace" )
		combobox:AddChoice( "vim" )
		combobox:AddChoice( "emacs" )
		
		setDoClick( form:CheckBox( "Enable word wrap", "sf_editor_wordwrap" ) )
		setDoClick( form:CheckBox( "Show fold widgets", "sf_editor_widgets" ) )
		setDoClick( form:CheckBox( "Show line numbers", "sf_editor_linenumbers" ) )
		setDoClick( form:CheckBox( "Show gutter", "sf_editor_gutter" ) )
		setDoClick( form:CheckBox( "Show invisible characters", "sf_editor_invisiblecharacters" ) )
		setDoClick( form:CheckBox( "Show indenting guides", "sf_editor_indentguides" ) )
		setDoClick( form:CheckBox( "Highlight active line", "sf_editor_activeline" ) )
		setDoClick( form:CheckBox( "Auto completion", "sf_editor_autocompletion" ) )
		setDoClick( form:CheckBox( "Live Auto completion", "sf_editor_liveautocompletion" ) )
		setDoClick( form:CheckBox( "Fix keys not working on Linux", "sf_editor_fixkeys" ) ):SetTooltip( "Some keys don't work with the editor on Linux\nEg. Enter, Tab, Backspace, Arrow keys etc..." )
		setDoClick( form:CheckBox( "Fix console bug", "sf_editor_fixconsolebug" ) ):SetTooltip( "Fix console opening when pressing ' or @ (UK Keyboad layout)" )
		setDoClick( form:CheckBox( "Disable line folding keybinds", "sf_editor_disablelinefolding" ) )

		function frame:OnOpen ()
			SF.Editor.editor.components[ "buttonHolder" ]:getButton( "Settings" ).active = true
		end

		function frame:OnClose ()
			SF.Editor.editor.components[ "buttonHolder" ]:getButton( "Settings" ).active = false
		end

		return frame
	end

	function SF.Editor.createPermissionsWindow ()
		local frame = vgui.Create( "StarfallFrame" )
		frame:SetSize( 400, 600 )
		frame:SetTitle( "Starfall Permissions" )
		frame:Center()

		local panel = vgui.Create( "StarfallPanel", frame )
		panel:Dock( FILL )
		panel:DockMargin( 0, 5, 0, 0 )

		local scrollPanel = vgui.Create( "DScrollPanel", panel )
		scrollPanel:Dock( FILL )
		scrollPanel:SetPaintBackgroundEnabled( false )
			
		frame.OnOpen = function()			
			local clientProviders = {}
			for i, v in ipairs(SF.Permissions.providers) do
				local provider = {id = v.id, name = v.name, settings = {}, options = {}}
				local options = provider.options
				local settings = provider.settings
				for i, option in ipairs(v.settingsoptions) do
					options[i] = option
				end
				for id, setting in pairs(v.settings) do
					settings[id] = {v.settingsdesc[id][1],v.settingsdesc[id][2],setting}
				end
				clientProviders[i] = provider
			end
			
			local function createPermissions( providers, server )	
				for _, p in ipairs( providers ) do
					local header = vgui.Create( "DLabel", header )
					header:SetFont( "DermaLarge" )
					header:SetColor( SF.Editor.colors.meddark )
					header:SetText( p.name )
					header:SetSize(0, 40)
					header:Dock( TOP )
					scrollPanel:AddItem( header )
					
					for id, setting in SortedPairs( p.settings ) do
						
						local header = vgui.Create( "StarfallPanel" )
						header:DockMargin( 0, 5, 0, 0 )
						header:SetSize( 0, 20 )
						header:Dock( TOP )
						
						local settingtext = vgui.Create( "DLabel", header )
						settingtext:SetFont( "DermaDefault" )
						settingtext:SetColor( SF.Editor.colors.meddark )
						settingtext:SetText( id )
						settingtext:DockMargin( 5, 0, 0, 0 )
						settingtext:Dock( FILL )
						
						local buttons = {}
						for i=#p.options, 1, -1 do
							local button = vgui.Create( "StarfallButton", header )
							button:SetText( p.options[i] )
							button:SetTooltip( setting[2] )
							button:DockMargin( 0, 0, 3, 0 )
							button:Dock( RIGHT )
							button.active = setting[3]==i
							button.DoClick = function(self)
								RunConsoleCommand(server and "sf_permission" or "sf_permission_cl", p.id, id, i)
								for _, b in ipairs(buttons) do
									b.active = false
								end
								self.active = true
							end
							buttons[i]=button
						end
						
						scrollPanel:AddItem( header )
						
					end
				end
			end
			
			if LocalPlayer():IsSuperAdmin() then
				SF.Permissions.requestPermissions( function(serverProviders)
					if frame:IsVisible() then
						createPermissions( serverProviders, true )
						createPermissions( clientProviders )
					end
				end)
			else
				createPermissions( clientProviders )
			end
		end

		frame.OnClose = function()
			scrollPanel:Clear()
		end
		
		return frame
	end

	function SF.Editor.createModelViewer ()
		local frame = vgui.Create( "StarfallFrame" )
		frame:SetTitle( "Model Viewer - Click an icon to insert model filename into editor" )
		frame:SetVisible( false )
		frame:Center()

		function frame:OnOpen ()
			SF.Editor.editor.components[ "buttonHolder" ]:getButton( "Model Viewer" ).active = true
			if not self.initialized then
				self:Initialize()
			end
		end

		function frame:OnClose ()
			SF.Editor.editor.components[ "buttonHolder" ]:getButton( "Model Viewer" ).active = false
			SF.Editor.saveSettings()
		end

		function frame:Initialize()
			local sidebarPanel = vgui.Create( "StarfallPanel", frame )
			sidebarPanel:Dock( LEFT )
			sidebarPanel:SetSize( 190, 10 )
			sidebarPanel:DockMargin( 0, 0, 4, 0 )
			sidebarPanel.Paint = function () end

			frame.ContentNavBar = vgui.Create( "ContentSidebar", sidebarPanel )
			frame.ContentNavBar:Dock( FILL )
			frame.ContentNavBar:DockMargin( 0, 0, 0, 0 )
			frame.ContentNavBar.Tree:SetBackgroundColor( Color( 240, 240, 240 ) )
			frame.ContentNavBar.Tree.OnNodeSelected = function ( self, node ) 
				if not IsValid( node.propPanel ) then return end

				if IsValid( frame.PropPanel.selected ) then
					frame.PropPanel.selected:SetVisible( false )
					frame.PropPanel.selected = nil
				end

				frame.PropPanel.selected = node.propPanel

				frame.PropPanel.selected:Dock( FILL )
				frame.PropPanel.selected:SetVisible( true )
				frame.PropPanel:InvalidateParent()
				
				frame.HorizontalDivider:SetRight( frame.PropPanel.selected )
			end

			frame.PropPanel = vgui.Create( "StarfallPanel", frame )
			frame.PropPanel:Dock( FILL )
			function frame.PropPanel:Paint ( w, h )
				draw.RoundedBox( 0, 0, 0, w, h, Color( 240, 240, 240 ) )
			end

			frame.HorizontalDivider = vgui.Create( "DHorizontalDivider", frame )
			frame.HorizontalDivider:Dock( FILL )
			frame.HorizontalDivider:SetLeftWidth( 175 )
			frame.HorizontalDivider:SetLeftMin( 175 )
			frame.HorizontalDivider:SetRightMin( 450 )
			
			frame.HorizontalDivider:SetLeft( sidebarPanel )
			frame.HorizontalDivider:SetRight( frame.PropPanel )

			local root = frame.ContentNavBar.Tree:AddNode( "Your Spawnlists" )
			root:SetExpanded( true )
			root.info = {}
			root.info.id = 0

			local function hasGame ( name )
				for k, v in pairs( engine.GetGames() ) do
					if v.folder == name and v.mounted then
						return true
					end
				end
				return false
			end

			local function addModel ( container, obj )

				local icon = vgui.Create( "SpawnIcon", container )
				
				if ( obj.body ) then
					obj.body = string.Trim( tostring(obj.body), "B" )
				end
				
				if ( obj.wide ) then
					icon:SetWide( obj.wide )
				end
				
				if ( obj.tall ) then
					icon:SetTall( obj.tall )
				end
				
				icon:InvalidateLayout( true )
				
				icon:SetModel( obj.model, obj.skin or 0, obj.body )
				
				icon:SetTooltip( string.Replace( string.GetFileFromFilename( obj.model ), ".mdl", "" ) )

				icon.DoClick = function ( icon ) 
					SF.Editor.runJS( "editor.insert(\"" .. string.gsub( obj.model, "\\", "/" ):JavascriptSafe() .. "\")" ) 
					SF.AddNotify( LocalPlayer(), "\"" .. string.gsub( obj.model, "\\", "/" ) .. "\" inserted into editor.", "GENERIC", 5, "DRIP1" )
					frame:close()
				end
				icon.OpenMenu = function ( icon )

					local menu = DermaMenu()
					local submenu = menu:AddSubMenu( "Re-Render", function () icon:RebuildSpawnIcon() end )
						submenu:AddOption( "This Icon", function () icon:RebuildSpawnIcon() end )
						submenu:AddOption( "All Icons", function () container:RebuildAll() end )
				
					local ChangeIconSize = function ( w, h )
						
						icon:SetSize( w, h )
						icon:InvalidateLayout( true )
						container:OnModified()
						container:Layout()
						icon:SetModel( obj.model, obj.skin or 0, obj.body )
					
					end

					local submenu = menu:AddSubMenu( "Resize", function () end )
						submenu:AddOption( "64 x 64 (default)", function () ChangeIconSize( 64, 64 ) end )
						submenu:AddOption( "64 x 128", function () ChangeIconSize( 64, 128 ) end )
						submenu:AddOption( "64 x 256", function () ChangeIconSize( 64, 256 ) end )
						submenu:AddOption( "64 x 512", function () ChangeIconSize( 64, 512 ) end )
						submenu:AddSpacer()
						submenu:AddOption( "128 x 64", function () ChangeIconSize( 128, 64 ) end )
						submenu:AddOption( "128 x 128", function () ChangeIconSize( 128, 128 ) end )
						submenu:AddOption( "128 x 256", function () ChangeIconSize( 128, 256 ) end )
						submenu:AddOption( "128 x 512", function () ChangeIconSize( 128, 512 ) end )
						submenu:AddSpacer()
						submenu:AddOption( "256 x 64", function () ChangeIconSize( 256, 64 ) end )
						submenu:AddOption( "256 x 128", function () ChangeIconSize( 256, 128 ) end )
						submenu:AddOption( "256 x 256", function () ChangeIconSize( 256, 256 ) end )
						submenu:AddOption( "256 x 512", function () ChangeIconSize( 256, 512 ) end )
						submenu:AddSpacer()
						submenu:AddOption( "512 x 64", function () ChangeIconSize( 512, 64 ) end )
						submenu:AddOption( "512 x 128", function () ChangeIconSize( 512, 128 ) end )
						submenu:AddOption( "512 x 256", function () ChangeIconSize( 512, 256 ) end )
						submenu:AddOption( "512 x 512", function () ChangeIconSize( 512, 512 ) end )

					menu:AddSpacer()
					menu:AddOption( "Delete", function () icon:Remove() end )
					menu:Open()
					
				end

				icon:InvalidateLayout( true )
				
				if ( IsValid( container ) ) then
					container:Add( icon )
				end

				return icon

			end

			local function addBrowseContent ( viewPanel, node, name, icon, path, pathid )
				local models = node:AddFolder( name, path .. "models", pathid, false )
				models:SetIcon( icon )

				models.OnNodeSelected = function ( self, node )

					if viewPanel and viewPanel.currentNode and viewPanel.currentNode == node then return end

					viewPanel:Clear( true )
					viewPanel.currentNode = node
					
					local path = node:GetFolder()
					local searchString = path .. "/*.mdl"

					local Models = file.Find( searchString, node:GetPathID() )
					for k, v in pairs( Models ) do
						if not IsUselessModel( v ) then
							addModel( viewPanel, { model = path .. "/" .. v } )
						end
					end

					node.propPanel = viewPanel
					frame.ContentNavBar.Tree:OnNodeSelected( node )

					viewPanel.currentNode = node

				end
			end

			local function addAddonContent ( panel, folder, path )
				local files, folders = file.Find( folder .. "*", path )

				for k, v in pairs( files ) do
					if string.EndsWith( v, ".mdl" ) then
						addModel( panel, { model = folder .. v } )
					end
				end

				for k, v in pairs( folders ) do
					addAddonContent( panel, folder .. v .. "/", path )
				end
			end

			local function fillNavBar ( propTable, parentNode )
				for k, v in SortedPairs( propTable ) do
					if v.parentid == parentNode.info.id and ( v.needsapp ~= "" and hasGame( v.needsapp ) or v.needsapp == "" ) then
						local node = parentNode:AddNode( v.name, v.icon )
						node:SetExpanded( true )
						node.info = v

						node.propPanel = vgui.Create( "ContentContainer", frame.PropPanel )
						node.propPanel:DockMargin( 5, 0, 0, 0 )
						node.propPanel:SetVisible( false )

						for i, object in SortedPairs( node.info.contents ) do
							if object.type == "model" then
								addModel( node.propPanel, object )
							elseif object.type == "header" then
								if not object.text or type( object.text ) ~= "string" then return end

								local label = vgui.Create( "ContentHeader", node.propPanel )
								label:SetText( object.text )
								
								node.propPanel:Add( label )
							end
						end

						fillNavBar( propTable, node )
					end
				end
			end

			if table.Count( spawnmenu.GetPropTable() ) == 0 then
				hook.Call( "PopulatePropMenu", GAMEMODE )
			end

			fillNavBar( spawnmenu.GetPropTable(), root )
			frame.OldSpawnlists = frame.ContentNavBar.Tree:AddNode( "#spawnmenu.category.browse", "icon16/cog.png" )
			frame.OldSpawnlists:SetExpanded( true )

			-- Games
			local gamesNode = frame.OldSpawnlists:AddNode( "#spawnmenu.category.games", "icon16/folder_database.png" )

			local viewPanel = vgui.Create( "ContentContainer", frame.PropPanel )
			viewPanel:DockMargin( 5, 0, 0, 0 )
			viewPanel:SetVisible( false )

			local games = engine.GetGames()
			table.insert( games, {
				title = "All",
				folder = "GAME",
				icon = "all",
				mounted = true
			} )
			table.insert( games, {
				title = "Garry's Mod",
				folder = "garrysmod",
				mounted = true
			} )
			
			for _, game in SortedPairsByMemberValue( games, "title" ) do
				
				if game.mounted then
					addBrowseContent( viewPanel, gamesNode, game.title, "games/16/" .. ( game.icon or game.folder ) .. ".png", "", game.folder )
				end
			end

			-- Addons
			local addonsNode = frame.OldSpawnlists:AddNode( "#spawnmenu.category.addons", "icon16/folder_database.png" )

			local viewPanel = vgui.Create( "ContentContainer", frame.PropPanel )
			viewPanel:DockMargin( 5, 0, 0, 0 )
			viewPanel:SetVisible( false )

			function addonsNode:OnNodeSelected ( node )
				if node == addonsNode then return end
				viewPanel:Clear( true )
				addAddonContent( viewPanel, "models/", node.addon.title )
				node.propPanel = viewPanel
				frame.ContentNavBar.Tree:OnNodeSelected( node )
			end
			for _, addon in SortedPairsByMemberValue( engine.GetAddons(), "title" ) do
				if addon.downloaded and addon.mounted and addon.models > 0 then
					local node = addonsNode:AddNode( addon.title .. " ("..addon.models..")", "icon16/bricks.png" )
					node.addon = addon
				end
			end

			-- Search box
			local viewPanel = vgui.Create( "ContentContainer", frame.PropPanel )
			viewPanel:DockMargin( 5, 0, 0, 0 )
			viewPanel:SetVisible( false )

			frame.searchBox = vgui.Create( "DTextEntry", sidebarPanel )
			frame.searchBox:Dock( TOP )
			frame.searchBox:SetValue( "Search..." )
			frame.searchBox:SetTooltip( "Press enter to search" )
			frame.searchBox.propPanel = viewPanel

			frame.searchBox._OnGetFocus = frame.searchBox.OnGetFocus
			function frame.searchBox:OnGetFocus ()
				if self:GetValue() == "Search..." then
					self:SetValue( "" )
				end
				frame.searchBox:_OnGetFocus()
			end

			frame.searchBox._OnLoseFocus = frame.searchBox.OnLoseFocus
			function frame.searchBox:OnLoseFocus ()
				if self:GetValue() == "" then
					self:SetText( "Search..." )
				end
				frame.searchBox:_OnLoseFocus()
			end

			function frame.searchBox:updateHeader ()
				self.header:SetText( frame.searchBox.results .. " Results for \"" .. self.search .. "\"" )
			end

			local searchTime = nil

			function frame.searchBox:getAllModels ( time, folder, extension, path )
				if searchTime and time ~= searchTime then return end
				if self.results and self.results >= 256 then return end
				self.load = self.load + 1
				local files, folders = file.Find( folder .. "/*", path )

				for k, v in pairs( files ) do
					local file = folder .. v
					if v:EndsWith( extension ) and file:find( self.search:PatternSafe() ) and not IsUselessModel( file ) then
						addModel( self.propPanel, { model = file } )
						self.results = self.results + 1
						self:updateHeader()
					end
					if self.results >= 256 then break end
				end

				for k, v in pairs( folders ) do
					timer.Simple( k * 0.02, function()
						if searchTime and time ~= searchTime then return end
						if self.results >= 256 then return end
						self:getAllModels( time, folder .. v .. "/", extension, path )
					end )
				end
				timer.Simple( 1, function () 
					if searchTime and time ~= searchTime then return end
					self.load = self.load - 1 
				end )
			end

			function frame.searchBox:OnEnter ()
				if self:GetValue() == "" then return end

				self.propPanel:Clear()

				self.results = 0
				self.load = 1
				self.search = self:GetText()

				self.header = vgui.Create( "ContentHeader", self.propPanel )
				self.loading = vgui.Create( "ContentHeader", self.propPanel )
				self:updateHeader()
				self.propPanel:Add( self.header )
				self.propPanel:Add( self.loading )

				searchTime = CurTime()
				self:getAllModels( searchTime, "models/", ".mdl", "GAME" )
				self.load = self.load - 1

				frame.ContentNavBar.Tree:OnNodeSelected( self )
			end
			hook.Add( "Think", "sf_header_update", function ()
				if frame.searchBox.loading and frame.searchBox.propPanel:IsVisible() then
					frame.searchBox.loading:SetText( "Loading" .. string.rep( ".", math.floor( CurTime() ) % 4 ) )
				end
				if frame.searchBox.load and frame.searchBox.load <= 0 then
					frame.searchBox.loading:Remove()
					frame.searchBox.loading = nil
					frame.searchBox.load = nil
				end
			end )
			
			self.initialized = true
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

		local frame = SF.Editor.modelViewer
		RunConsoleCommand( "sf_modelviewer_width", frame:GetWide() )
		RunConsoleCommand( "sf_modelviewer_height", frame:GetTall() )
		local x, y = frame:GetPos()
		RunConsoleCommand( "sf_modelviewer_posx", x )
		RunConsoleCommand( "sf_modelviewer_posy", y )
	end

	function SF.Editor.updateSettings ( ace )
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

		local frame = SF.Editor.modelViewer
		frame:SetWide( GetConVarNumber( "sf_modelviewer_width" ) )
		frame:SetTall( GetConVarNumber( "sf_modelviewer_height" ) )
		frame:SetPos( GetConVarNumber( "sf_modelviewer_posx" ), GetConVarNumber( "sf_modelviewer_posy" ) )

		if ace then
			local js = SF.Editor.runJS
			js( [[
				editSessions.forEach( function( session ) {
					session.setUseWrapMode( ]] .. GetConVarNumber( "sf_editor_wordwrap" ) .. [[ )
				} )
			]] )
			js( "editor.setOption(\"showFoldWidgets\", " .. GetConVarNumber( "sf_editor_widgets" ) .. ");" )
			js( "editor.setOption(\"showLineNumbers\", " .. GetConVarNumber( "sf_editor_linenumbers" ) .. ");" )
			js( "editor.setOption(\"showGutter\", " .. GetConVarNumber( "sf_editor_gutter" ) .. ");" )
			js( "editor.setOption(\"showInvisibles\", " .. GetConVarNumber( "sf_editor_invisiblecharacters" ) .. ");" )
			js( "editor.setOption(\"displayIndentGuides\", " .. GetConVarNumber( "sf_editor_indentguides" ) .. ");" )
			js( "editor.setOption(\"highlightActiveLine\", " .. GetConVarNumber( "sf_editor_activeline" ) .. ");" )
			js( "editor.setOption(\"highlightGutterLine\", " .. GetConVarNumber( "sf_editor_activeline" ) .. ");" )
			js( "editor.setOption(\"enableLiveAutocompletion\", " .. GetConVarNumber( "sf_editor_liveautocompletion" ) .. ");" )
			js( "editor.setOption(\"enableBasicAutocompletion\", " .. GetConVarNumber( "sf_editor_autocompletion" ) .. ");" )
			js( "setFoldKeybinds( " .. GetConVarNumber( "sf_editor_disablelinefolding" ) .. ");" )
			js( "editor.setKeyboardHandler(\"ace/keyboard/" .. GetConVarString( "sf_editor_keybindings") .. "\");" )
			js( "editor.setFontSize(" .. GetConVarNumber( "sf_editor_fontsize" ) .. ");" )
		end
	end

	--- (Client) Builds a table for the compiler to use
	-- @param maincode The source code for the main chunk
	-- @param codename The name of the main chunk
	-- @return True if ok, false if a file was missing
	-- @return A table with mainfile = codename and files = a table of filenames and their contents, or the missing file path.
	function SF.Editor.BuildIncludesTable ( maincode, codename )
		if not SF.Editor.editor then SF.Editor.init() end
		local tbl = {}
		maincode = maincode or SF.Editor.getCode()
		codename = codename or SF.Editor.getOpenFile() or "main"
		tbl.mainfile = codename
		tbl.files = {}
		tbl.filecount = 0
		tbl.includes = {}

		local loaded = {}
		local ppdata = {}

		local function recursiveLoad ( path, curdir )
			if loaded[ path ] then return end
			loaded[ path ] = true
			
			local code
			local codedir
			local codepath
			if path == codename and maincode then
				code = maincode
				codedir = curdir
				codepath = path
			else
				if string.sub(path,1,1)~="/" then
					codepath = SF.NormalizePath( curdir .. path )
					code = file.Read( "starfall/" .. codepath, "DATA" )
				end
				if not code then
					codepath = SF.NormalizePath( path )
					code = file.Read( "starfall/" .. codepath, "DATA" )
				end
				codedir = string.GetPathFromFilename( codepath )
			end
			if not code then
				print( "Bad include: " .. path )
				return
			end
			
			tbl.files[ codepath ] = code
			SF.Preprocessor.ParseDirectives( codepath, code, {}, ppdata )
			
			if ppdata.includes and ppdata.includes[ codepath ] then
				local inc = ppdata.includes[ codepath ]
				if not tbl.includes[ codepath ] then
					tbl.includes[ codepath ] = inc
					tbl.filecount = tbl.filecount + 1
				else
					assert( tbl.includes[ codepath ] == inc )
				end
				
				for i = 1, #inc do
					recursiveLoad( inc[i], codedir )
				end
			end
		end
		local ok, msg = pcall( recursiveLoad, codename, string.GetPathFromFilename( codename ) )

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
