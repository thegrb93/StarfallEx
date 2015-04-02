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
	CreateClientConVar( "sf_fileviewer_height", 600, true, false )
	CreateClientConVar( "sf_fileviewer_posx", ScrW()/2-1100/2-263, true, false )
	CreateClientConVar( "sf_fileviewer_posy", ScrH()/2-600/2, true, false )
	CreateClientConVar( "sf_fileviewer_locked", 1, true, false )

	CreateClientConVar( "sf_editor_widgets", 1, true, false )
	CreateClientConVar( "sf_editor_linenumbers", 1, true, false )
	CreateClientConVar( "sf_editor_gutter", 1, true, false )
	CreateClientConVar( "sf_editor_invisiblecharacters", 0, true, false )
	CreateClientConVar( "sf_editor_indentguides", 1, true, false )
	CreateClientConVar( "sf_editor_activeline", 1, true, false )
	CreateClientConVar( "sf_editor_autocompletion", 1, true, false )
	CreateClientConVar( "sf_editor_fixkeys", system.IsLinux() and 1 or 0, true, false ) --maybe osx too? need someone to check

	local aceFiles = {}
	local htmlEditorCode = nil

	function SF.Editor.init()
		if SF.Editor.initialized or #aceFiles == 0 or htmlEditorCode == nil or not SF.Editor.safeToInit then return end

		if not file.Exists( "starfall", "DATA" ) then
			file.CreateDir( "starfall" )
		end

		SF.Editor.editor = SF.Editor.createEditor()
		SF.Editor.fileViewer = SF.Editor.createFileViewer()
		SF.Editor.fileViewer:close()
		SF.Editor.settingsWindow = SF.Editor.createSettingsWindow()
		SF.Editor.settingsWindow:close()

		SF.Editor.updateSettings()

		SF.Editor.initialized = true
		SF.Editor.editor:open()

		SF.Editor.addTab()
	end

	function SF.Editor.open()
		if not SF.Editor.initialized then 
			SF.Editor.init()
			return
		end

		SF.Editor.editor:open()

		if CanRunConsoleCommand() then
			RunConsoleCommand( "starfall_event", "editor_open" )
		end
	end

	function SF.Editor.close()
		SF.Editor.editor:close()

		if CanRunConsoleCommand() then
			RunConsoleCommand( "starfall_event", "editor_close" )
		end
	end

	function SF.Editor.updateCode() -- Incase anyone needs to force update the code
		SF.Editor.editor.components[ "htmlPanel" ]:QueueJavascript( "console.log(\"RUNLUA:SF.Editor.getActiveTab().code = \\\"\" + addslashes(editor.getValue()) + \"\\\"\")" )
	end

	function SF.Editor.getCode()
		if not SF.Editor.initialized then -- stops someone trying to place a chip before editor is initialized 
			SF.Editor.init()
			return ""
		end
		return SF.Editor.getActiveTab().code
	end

	function SF.Editor.getOpenFile()
		return SF.Editor.getActiveTab():GetText()
	end

	function SF.Editor.getTabHolder()
		return SF.Editor.editor.components[ "tabHolder" ]
	end

	function SF.Editor.getActiveTab()
		return SF.Editor.getTabHolder():getActiveTab()
	end

	function SF.Editor.selectTab( tab )
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

		SF.Editor.editor.components[ "htmlPanel" ]:QueueJavascript( "selectEditSession("..tabHolder:getTabIndex( tab )..")" )
	end

	function SF.Editor.addTab( filename, code, name )
		filename = filename or "generic"
		code = code or defaultCode

		SF.Editor.editor.components[ "htmlPanel" ]:QueueJavascript( "newEditSession(\""..string.JavascriptSafe( code or defaultCode ).."\")" )

		local tab = SF.Editor.getTabHolder():addTab( filename )
		tab.code = code
		tab.name = name
		SF.Editor.selectTab( tab )
	end

	function SF.Editor.removeTab( tab )
		local tabHolder = SF.Editor.getTabHolder()
		if type( tab ) == "number" then
			tab = tabHolder.tabs[ tab ]  
		end
		if tab == nil then return end

		tabHolder:removeTab( tab )
	end

	function SF.Editor.saveActiveTab()
		if string.GetExtensionFromFilename( SF.Editor.getOpenFile() ) ~= "txt" then return end
		local saveFile = "starfall/"..SF.Editor.getOpenFile()
		file.Write( saveFile, SF.Editor.getActiveTab().code )
		SF.AddNotify( LocalPlayer(), "Starfall code saved as " .. saveFile .. ".", NOTIFY_GENERIC, 7, NOTIFYSOUND_DRIP3 )
	end

	function SF.Editor.createEditor()
		local editor = vgui.Create( "StarfallFrame" )
		editor:SetSize( 800, 600 )
		editor:SetTitle( "Starfall Code Editor" )
		editor:Center()

		local buttonHolder = editor.components[ "buttonHolder" ]

		local buttonSaveExit = vgui.Create( "StarfallButton", buttonHolder )
		buttonSaveExit:SetText( "Save and Exit" )
		function buttonSaveExit:DoClick()
			SF.Editor.saveActiveTab()
			SF.Editor.close()
		end
		buttonHolder:addButton( buttonSaveExit )

		local buttonSettings = vgui.Create( "StarfallButton", buttonHolder )
		buttonSettings:SetText( "Settings" )
		function buttonSettings:DoClick()
			SF.Editor.settingsWindow:open()
		end
		buttonHolder:addButton( buttonSettings )

		local buttonHelper = vgui.Create( "StarfallButton", buttonHolder )	
		buttonHelper:SetText( "SF Helper" )
		function buttonHelper:DoClick()
			SF.Helper.show()
		end
		buttonHolder:addButton( buttonHelper )

		local buttonFiles = vgui.Create( "StarfallButton", buttonHolder )
		buttonFiles:SetText( "Files" )
		function buttonFiles:DoClick()
			SF.Editor.fileViewer:open()
		end
		buttonHolder:addButton( buttonFiles )

		local buttonSaveAs = vgui.Create( "StarfallButton", buttonHolder )
		buttonSaveAs:SetText( "Save As" )
		function buttonSaveAs:DoClick()
			Derma_StringRequestNoBlur(
				"Save File",
				"",
				string.StripExtension( SF.Editor.getOpenFile() ),
				function( text )
					if text == "" then return end
					text = string.gsub( text, ".", invalid_filename_chars )
					local saveFile = "starfall/"..text..".txt"
					file.Write( saveFile, SF.Editor.getActiveTab().code )
					SF.Editor.getActiveTab():SetText( text .. ".txt" )
					SF.AddNotify( LocalPlayer(), "Starfall code saved as " .. saveFile .. ".", NOTIFY_GENERIC, 7, NOTIFYSOUND_DRIP3 )
					SF.Editor.fileViewer.components["tree"]:reloadTree()
				end
			)
		end
		buttonHolder:addButton( buttonSaveAs )

		local buttonSave = vgui.Create( "StarfallButton", buttonHolder )
		buttonSave:SetText( "Save" )
		function buttonSave:DoClick()
			SF.Editor.saveActiveTab()
		end
		buttonHolder:addButton( buttonSave )

		local buttonNewFile = vgui.Create( "StarfallButton", buttonHolder )
		buttonNewFile:SetText( "New tab" )
		function buttonNewFile:DoClick()
			SF.Editor.addTab()
		end
		buttonHolder:addButton( buttonNewFile )

		local buttonCloseTab = vgui.Create( "StarfallButton", buttonHolder )
		buttonCloseTab:SetText( "Close tab" )
		function buttonCloseTab:DoClick()
			SF.Editor.removeTab( SF.Editor.getActiveTab() )
		end
		buttonHolder:addButton( buttonCloseTab )

		local html = vgui.Create( "DHTML", editor )
		html:SetPos( 5, 54 )
		htmlEditorCode = htmlEditorCode:Replace( "<script>//replace//</script>", table.concat( aceFiles ) )
		html:SetHTML( htmlEditorCode )

		html:SetAllowLua( true )

		html:QueueJavascript( "createStarfallMode(\"" .. table.concat( table.GetKeys( SF.DefaultEnvironment ), "|" ) .. "\")")

		function html:PerformLayout( ... )
		 	self:SetSize( editor:GetWide() - 10, editor:GetTall() - 59 )
		end
		function html:OnKeyCodePressed( key, notfirst )

			local function repeatKey()
				timer.Create( "repeatKey"..key, not notfirst and 0.5 or 0.02, 1, function() self:OnKeyCodePressed( key, true ) end )
			end

			if GetConVarNumber( "sf_editor_fixkeys" ) == 0 then return end
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
				repeatKey()
				self:QueueJavascript( "editor.toggleOverwrite()" )
			elseif key == KEY_TAB and input.IsKeyDown( key ) then
				repeatKey()
				self:QueueJavascript( "editor.indent()" )
			end
		end
		editor:AddComponent( "htmlPanel", html )

		local tabHolder = vgui.Create( "StarfallTabHolder", editor )
		tabHolder:SetPos( 5, 30 )
		tabHolder.menuoptions[ #tabHolder.menuoptions + 1 ] = { "", "SPACER" }
		tabHolder.menuoptions[ #tabHolder.menuoptions + 1 ] = { "Save", function()
			if not tabHolder.targetTab then return end
			local fileName = tabHolder.targetTab:GetText()

			if string.GetExtensionFromFilename( fileName ) ~= "txt" then return end
			local saveFile = "starfall/"..fileName
			file.Write( saveFile, tabHolder.targetTab.code )
			SF.AddNotify( LocalPlayer(), "Starfall code saved as " .. saveFile .. ".", NOTIFY_GENERIC, 7, NOTIFYSOUND_DRIP3 )
			tabHolder.targetTab = nil
		end }
		tabHolder.menuoptions[ #tabHolder.menuoptions + 1 ] = { "Save As", function()
			if not tabHolder.targetTab then return end
			local fileName = tabHolder.targetTab:GetText()

			Derma_StringRequestNoBlur(
				"Save File",
				"",
				string.StripExtension( fileName ),
				function( text )
					if text == "" then return end
					text = string.gsub( text, ".", invalid_filename_chars )
					local saveFile = "starfall/"..text..".txt"
					file.Write( saveFile, tabHolder.targetTab.code )
					tabHolder.targetTab:SetText( text .. ".txt" )
					SF.AddNotify( LocalPlayer(), "Starfall code saved as " .. saveFile .. ".", NOTIFY_GENERIC, 7, NOTIFYSOUND_DRIP3 )
					SF.Editor.fileViewer.components["tree"]:reloadTree()
					tabHolder.targetTab = nil
				end
			)
		end }
		function tabHolder:OnRemoveTab( tabIndex )
			SF.Editor.editor.components[ "htmlPanel" ]:QueueJavascript( "removeEditSession("..tabIndex..")" )

			if #self.tabs == 0 then
				SF.Editor.addTab()
			end
			SF.Editor.selectTab( tabIndex )
		end
		editor:AddComponent( "tabHolder", tabHolder )

		return editor
	end

	function SF.Editor.createFileViewer()
		local fileViewer = vgui.Create( "StarfallFrame" )
		fileViewer:SetSize( 200, 600 )
		fileViewer:SetTitle( "Starfall File Viewer" )
		fileViewer:Center()

		local searchBox = vgui.Create( "DTextEntry", fileViewer )
		searchBox:Dock( TOP )
		searchBox:DockMargin( 0, 5, 0, 0 )
		searchBox:SetValue( "Search..." )

		searchBox._OnGetFocus = searchBox.OnGetFocus
		function searchBox:OnGetFocus()
			if self:GetValue() == "Search..." then
				self:SetValue( "" )
			end
			searchBox:_OnGetFocus()
		end

		searchBox._OnLoseFocus = searchBox.OnLoseFocus
		function searchBox:OnLoseFocus()
			if self:GetValue() == "" then
				self:SetText( "Search..." )
			end
			searchBox:_OnLoseFocus()
		end

		function searchBox:OnChange()
			local tree = fileViewer.components[ "tree" ]

			if self:GetValue() == "" then
				tree:reloadTree()
				return
			end

			tree.Root.ChildNodes:Clear()
			local function addFiles( search, dir, node, makenode )
				if makenode then
					local folder = string.Trim( string.reverse( string.match( string.reverse( dir ), ".-/" ) ), "/" )
					node = node:AddNode( folder )
					node:SetExpanded( true )
				end
				search = string.lower( search )
				local allFiles, allFolders = file.Find( dir .. "/*", "DATA" )
				for k, v in pairs( allFolders ) do
					addFiles( search, dir.."/"..v, node, true )
				end
				for k, v in pairs( allFiles ) do
					if string.find( string.lower( v ), search ) then
						node:AddNode( v, "icon16/page_white.png" )
					end
				end
				if not node.ChildNodes then
					node:Remove()
				end
			end
			addFiles( self:GetValue(), "starfall", tree.Root )
			tree.Root:SetExpanded( true )
		end

		fileViewer:AddComponent( "searchBox", searchBox )

		local tree = vgui.Create( "StarfallFileBrowser", fileViewer )
		tree:setup( "starfall" )
		tree:Dock( FILL )
		function tree:OnNodeSelected( node )
			if not node:GetFileName() or string.GetExtensionFromFilename( node:GetFileName() ) ~= "txt" then return end
			local fileName = string.gsub( node:GetFileName(), "starfall/", "", 1 )
			local code = file.Read( node:GetFileName(), "DATA" )

			for k, v in pairs( SF.Editor.getTabHolder().tabs ) do
				if v:GetText() == fileName and v.code == code then
					SF.Editor.selectTab( v )
					return
				end
			end

			local data = {}
			SF.Preprocessor.ParseDirectives( "file", code, {}, data )
			SF.Editor.addTab( fileName, code, data.scriptnames and data.scriptnames.file or "" )
		end
		fileViewer:AddComponent( "tree", tree )

		local buttonHolder  = fileViewer.components[ "buttonHolder" ]
		local buttonRefresh = vgui.Create( "StarfallButton", buttonHolder )
		buttonRefresh:SetText( "Refresh" )
		buttonRefresh:SetHoverColor( Color( 7, 70, 0 ) )
		buttonRefresh:SetColor( Color( 26, 104, 17 ) )
		buttonRefresh:SetLabelColor( Color( 103, 155, 153 ) )
		function buttonRefresh:DoClick()
			tree:reloadTree()
			searchBox:SetValue( "Search..." )
		end
		buttonHolder:addButton( buttonRefresh )

		return fileViewer
	end

	function SF.Editor.createSettingsWindow()
		local frame = vgui.Create( "StarfallFrame" )
		frame:SetSize( 200, 400 )
		frame:SetTitle( "Starfall Settings" )
		frame:Center()
		frame:SetVisible( true )
		frame:MakePopup( true )

		local panel = vgui.Create( "StarfallPanel", frame )
		panel:SetPos( 5, 40 )
		function panel:PerformLayout()
			self:SetSize( frame:GetWide() - 10, frame:GetTall() - 45 )
		end
		frame:AddComponent( "panel", panel )

		local function setDoClick( panel )
			function panel:OnChange()
				SF.Editor.updateSettings()
			end

			return panel
		end

		local form = vgui.Create( "DForm", panel )	
		form:Dock( FILL )
		form.Header:SetVisible( false )
		form.Paint = function() end
		setDoClick(form:CheckBox( "Show fold widgets", "sf_editor_widgets" ))
		setDoClick(form:CheckBox( "Show line numbers", "sf_editor_linenumbers" ))
		setDoClick(form:CheckBox( "Show gutter", "sf_editor_gutter" ))
		setDoClick(form:CheckBox( "Show invisible characters", "sf_editor_invisiblecharacters" ))
		setDoClick(form:CheckBox( "Show indenting guides", "sf_editor_indentguides" ))
		setDoClick(form:CheckBox( "Highlight active line", "sf_editor_activeline" ))
		setDoClick(form:CheckBox( "Auto completion (Ctrl-Space)", "sf_editor_autocompletion" )):SetTooltip( "Doesn't work with Linux for some reason" )
		setDoClick(form:CheckBox( "Fix keys not working on Linux", "sf_editor_fixkeys" )):SetTooltip( "Some keys don't work with the editor on Linux\nEg. Enter, Tab, Backspace, Arrow keys etc..." )

		return frame
	end

	function SF.Editor.saveSettings()
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

	function SF.Editor.updateSettings()
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
		if frame.locked then
			frame.buttonLock.active = true
			frame.buttonLock:SetText( "Locked" )
		end

		local html = SF.Editor.editor.components[ "htmlPanel" ]
		local js = html.QueueJavascript
		js( html, "editor.setOption(\"showFoldWidgets\", " .. GetConVarNumber( "sf_editor_widgets" ) .. ")" )
		js( html, "editor.setOption(\"showLineNumbers\", " .. GetConVarNumber( "sf_editor_linenumbers" ) .. ")" )
		js( html, "editor.setOption(\"showGutter\", " .. GetConVarNumber( "sf_editor_gutter" ) .. ")" )
		js( html, "editor.setOption(\"showInvisibles\", " .. GetConVarNumber( "sf_editor_invisiblecharacters" ) .. ")" )
		js( html, "editor.setOption(\"displayIndentGuides\", " .. GetConVarNumber( "sf_editor_indentguides" ) .. ")" )
		js( html, "editor.setOption(\"highlightActiveLine\", " .. GetConVarNumber( "sf_editor_activeline" ) .. ")" )
		js( html, "editor.setOption(\"highlightGutterLine\", " .. GetConVarNumber( "sf_editor_activeline" ) .. ")" )
		js( html, "editor.setOption(\"enableBasicAutocompletion\", " .. GetConVarNumber( "sf_editor_autocompletion" ) .. ")" )
	end

	--- (Client) Builds a table for the compiler to use
	-- @param maincode The source code for the main chunk
	-- @param codename The name of the main chunk
	-- @return True if ok, false if a file was missing
	-- @return A table with mainfile = codename and files = a table of filenames and their contents, or the missing file path.
	function SF.Editor.BuildIncludesTable( maincode, codename )
		local tbl = {}
		maincode = maincode or SF.Editor.getCode()
		codename = codename or SF.Editor.getOpenFile() or "main"
		tbl.mainfile = codename
		tbl.files = {}
		tbl.filecount = 0
		tbl.includes = {}

		local loaded = {}
		local ppdata = {}

		local function recursiveLoad( path )
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
		if ok then
			return true, tbl
		elseif msg:sub( 1, 13 ) == "Bad include: " then
			return false, msg
		else
			error( msg, 0 )
		end
	end

	net.Receive( "starfall_editor_getacefiles", function( len )
		local index = net.ReadInt( 8 )
		aceFiles[ index ] = net.ReadString()
		
		if not tobool( net.ReadBit() ) then 
			net.Start( "starfall_editor_getacefiles" )
			net.SendToServer()
		else
			SF.Editor.safeToInit = true
		end
	end )
	net.Receive( "starfall_editor_geteditorcode", function( len )
		htmlEditorCode = net.ReadString()
	end )

	-- CLIENT ANIMATION

	local busy_players = { }
	hook.Add( "EntityRemoved", "starfall_busy_animation", function( ply )
		busy_players[ ply ] = nil
	end )

	local emitter = ParticleEmitter( vector_origin )

	net.Receive( "starfall_editor_status", function( len )
		local ply = net.ReadEntity()
		local status = net.ReadBit() ~= 0 -- net.ReadBit returns 0 or 1, despite net.WriteBit taking a boolean
		if not ply:IsValid() or ply == LocalPlayer() then return end

		busy_players[ ply ] = status or nil
	end )

	local rolldelta = math.rad( 80 )
	timer.Create( "starfall_editor_status", 1 / 3, 0, function( )
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

	local function getFiles( dir, dir2 )
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

		--out:Replace( "workerPath:null", "workerPath:\"\"" )
		--out:Replace( "suffix:\".js\"", "suffix:\".txt\"" )

		for i = 1, math.ceil( out:len() / netSize ) do
			acefiles[i] = out:sub( (i - 1)*netSize + 1, i*netSize )
		end
	end


	local plyIndex = {}
	local function sendAceFile( len, ply )
		local index = plyIndex[ ply ]
		net.Start( "starfall_editor_getacefiles" )
			net.WriteInt( index, 8 )
			net.WriteString( acefiles[ index ] )
			net.WriteBit( index == #acefiles )
		net.Send( ply )
		plyIndex[ ply ] = index + 1
	end

	hook.Add( "PlayerInitialSpawn", "starfall_file_init", function( ply )
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

	concommand.Add( "starfall_event", function( ply, command, args )
		local handler = starfall_event[ args[ 1 ] ]
		if not handler then return end
		return handler( ply, args )
	end )

	function starfall_event.editor_open( ply, args )
		net.Start( "starfall_editor_status" )
		net.WriteEntity( ply )
		net.WriteBit( true )
		net.Broadcast()
	end

	function starfall_event.editor_close( ply, args )
		net.Start( "starfall_editor_status" )
		net.WriteEntity( ply )
		net.WriteBit( false )
		net.Broadcast()
	end
end
