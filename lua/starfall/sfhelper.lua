-------------------------------------------------------------------------------
-- SF Helper for Starfall
-- By Jazzelhawk
-------------------------------------------------------------------------------

--- TO DO ---
--- search page

SF.Helper = {}
SF.Docs = {}
local helper = SF.Helper
local docs_set = false
local settings_set = false

if CLIENT then
	function helper.getDocs()
		http.Fetch( "http://jazzelhawk.zapto.org/doc.json", function( body, len, headers, code )
			SF.Docs = util.JSONToTable( body )
			docs_set = true
		end, function( error ) print("Starfall failed to load documentation, Error: ", error) end )
	end
	helper.getDocs()

	helper.Settings = {}
	if file.Exists( "sfhelpersettings.txt", "DATA" ) then
		helper.Settings = util.JSONToTable( file.Read( "sfhelpersettings.txt", "DATA" ) )
	else
		helper.Settings.FrameWidth, helper.Settings.FrameHeight = 930, 615
		helper.Settings.FrameX, helper.Settings.FrameY = ( ScrW() - 930 ) / 2, ( ScrH() - 615 ) / 2
		helper.Settings.DivHeight = 400
	end
end

local function saveSettings()
	file.Write( "sfhelpersettings.txt", util.TableToJSON( helper.Settings ) )
end

function helper.create()

	helper.Views = {}

	helper.Frame = vgui.Create( "DFrame" )
	helper.Frame:SetSize( 930, 615 )
	helper.Frame:Center( )
	helper.Frame:SetSizable( true )
	helper.Frame:SetScreenLock( true )
	helper.Frame:SetDeleteOnClose( false )
	helper.Frame:SetVisible( false )
	helper.Frame:SetTitle( "SF Helper - By Jazzelhawk" )
	helper.Frame._PerformLayout = helper.Frame.PerformLayout
	function helper.Frame:PerformLayout( ... )
		local w, h = helper.Frame:GetSize()
		if w < 620 then w = 620 end
		if h < 410 then h = 410 end
		helper.Frame:SetSize( w, h )

		self:_PerformLayout( ... )
		helper.resize( )
	end   
	function helper.Frame:OnClose()
		saveSettings()
	end           

	helper.ScrollPanel = vgui.Create( "DScrollPanel", helper.Frame )
	helper.ScrollPanel:SetPos( 5, 30 )

	helper.CatList = vgui.Create( "DCategoryList", helper.ScrollPanel )

	local lists = {}
	local panels = {}

	local function createList( name, listfunc )
		local Cat = helper.CatList:Add( name )
		if name ~= "SF Helper" then Cat:SetExpanded( false ) end
		local DPanel = vgui.Create( "DPanel", Cat )
		DPanel:SetPos( 2, 22 )

		local List = vgui.Create( "DListView", DPanel )
		List:SetHideHeaders( true )
		List:SetMultiSelect( false )
		List:DisableScrollbar()
		List:AddColumn( "" )

		local height = listfunc( List ) - 15

		DPanel:SetSize( 113, height )
		List:SetSize( 113, height )

		List._OnRowSelected = List.OnRowSelected
		function List:OnRowSelected( LineID, Line )
			for k, v in pairs( lists ) do
				if v ~= List then
					v:ClearSelection()
				end
			end
			List:_OnRowSelected( LineID, Line )
		end

		lists[ name ] = List
		table.insert( panels, DPanel )
	end

	helper.CatList._PerformLayout = helper.CatList.PerformLayout
	function helper.CatList:PerformLayout( ... )
		self:_PerformLayout( ... )
		for k, v in pairs( panels ) do
			v:SetSize( self:GetCanvas():GetWide() - 8, v:GetTall() )
		end
		for k, v in pairs( lists ) do
			v:SetSize( self:GetCanvas():GetWide() - 8, v:GetTall() )
		end
	end

	createList( "SF Helper", function( List ) 
		local height = 16;
		List:AddLine( "Index" )
		height = height + 17
		List:AddLine( "About" )
		height = height + 17
		List:SelectFirstItem()

		function List:OnRowSelected( LineID, Line )
			if LineID == 1 then
				helper.openView( "Index" )
			else
				helper.openView( "About" )
			end
		end

		return height
	end )

	createList( "Preprocessor directives", function( List )
		local height = 16
		for _, directive in ipairs(SF.Docs.directives) do
			List:AddLine( "--@" .. directive )
			height = height + 17
		end

		function List:OnRowSelected( LineID, Line )
			helper.openView( "Doc" )
			helper.updateDocView( Line, 4 )
			helper.DocView.DirectivesList:SelectItem( helper.DocView.DirectivesList:GetLine( LineID ) )
		end

		return height
	end )

	createList( "Libraries", function( List )
		local height = 16
		for _, modulename in ipairs(SF.Docs.libraries) do
			List:AddLine( modulename )
			height = height + 17
		end

		function List:OnRowSelected( LineID, Line )
			helper.openView( "Doc" )
			helper.updateDocView( Line, 1 )
		end

		return height
	end )
	
	createList( "Types", function( List )
		local height = 16
		for _, typename in ipairs(SF.Docs.classes) do
			List:AddLine( typename )
			height = height + 17
		end

		function List:OnRowSelected( LineID, Line )
			helper.openView( "Doc" )
			helper.updateDocView( Line, 2 )
		end

		return height
	end )
	
	createList( "Hooks", function( List )
		local height = 16
		for _, hookname in ipairs(SF.Docs.hooks) do
			List:AddLine( hookname )
			height = height + 17
		end

		function List:OnRowSelected( LineID, Line )
			helper.openView( "Doc" )
			helper.updateDocView( Line, 3 )
			helper.DocView.HooksList:SelectItem( helper.DocView.HooksList:GetLine( LineID ) )
		end

		return height
	end )

	function helper.clearViews()
		for _, View in pairs( helper.Views ) do
			View:SetVisible( false )
			if View.Info then
				View.Info:SetVisible( false )
				View.Div:SetVisible( false )
			end
		end
	end

	function helper.openView( view )
		helper.clearViews()
		if helper.Views[ view ] then
			helper.Views[ view ]:SetVisible( true )
			if helper.Views[ view ].Info then
				helper.Views[ view ].Info:SetVisible( true )
				helper.Views[ view ].Div:SetVisible( true )
			end
		end
	end

	surface.CreateFont( "HelperTitle", {
		font = "Tahoma",
		size = 30,
		weight = 1000
	} )

	surface.CreateFont( "HelperText", {
		font = "Tahoma",
		size = 22,
		weight = 500
	} )

	surface.CreateFont( "HelperTextBold", {
		font = "Tahoma",
		size = 22,
		weight = 1000
	} )

	surface.CreateFont( "CodeBlock", {
		font = "Courier New",
		size = 16,
		weight = 540
	} )

	---- Index View ----
	--------------------
	helper.IndexView = vgui.Create( "DPanel", helper.Frame )
	helper.IndexView:SetPos( 166, 30 )
	helper.Views.Index = helper.IndexView

	helper.IndexLibs = vgui.Create( "DListView", helper.IndexView )
	helper.IndexLibs:SetPos( 5, 5 )
	helper.IndexLibs:SetMultiSelect( false )
	helper.IndexLibs:AddColumn( "Libraries" ):SetFixedWidth( 100 )
	helper.IndexLibs:AddColumn( "Description" )
	for _, modulename in ipairs( SF.Docs.libraries ) do
		helper.IndexLibs:AddLine( modulename, string.Trim( SF.Docs.libraries[ modulename ].summary ) )
	end
	function helper.IndexLibs:OnRowSelected( LineID, Line )
		helper.IndexHooks:ClearSelection()
		lists[ "Libraries" ]:GetParent():GetParent():DoExpansion( true )
		lists[ "Libraries" ]:SelectItem( lists[ "Libraries" ]:GetLine( LineID ) )
	end

	helper.IndexHooks = vgui.Create( "DListView", helper.IndexView )
	helper.IndexHooks:SetMultiSelect( false )
	helper.IndexHooks:AddColumn( "Hooks" ):SetFixedWidth( 100 )
	helper.IndexHooks:AddColumn( "Description" )
	for _, hookname in ipairs(SF.Docs.hooks) do
		helper.IndexHooks:AddLine( hookname, string.Trim( SF.Docs.hooks[ hookname ].summary ) )
	end
	function helper.IndexHooks:OnRowSelected( LineID, Line )
		helper.IndexLibs:ClearSelection()
		lists[ "Hooks" ]:GetParent():GetParent():DoExpansion( true )
		lists[ "Hooks" ]:SelectItem( lists[ "Hooks" ]:GetLine( LineID ) )
	end

	---- Doc View ----
	------------------
	function helper.updateDocView( Line, Type )
		local view = helper.DocView
		view.DocName = Line:GetColumnText( 1 )

		view:GetVBar():SetScroll( 0 )

		if Type == 1 then
			view.Title:SetText( "Library - " .. view.DocName )
			view.Doc = SF.Docs.libraries[ view.DocName ]
		elseif Type == 2 then
			view.Title:SetText( "Type - " .. view.DocName )
			view.Doc = SF.Docs.classes[ view.DocName ]
		elseif Type == 3 then
			view.Title:SetText( "Hooks" )
			view.Doc = {}
			view.Doc.hooks = SF.Docs.hooks
			view.Doc.description = "List of hooks available to SF scripts"
		elseif Type == 4 then
			view.Title:SetText( "Preprocessor directives" )
			view.Doc = {}
			view.Doc.directives = SF.Docs.directives
			view.Doc.description = "List of preprocessor directives"
		end
		local doc = view.Doc
		view.Title:SizeToContents()

		view.Description:SetText( string.Replace( doc.description, "\n", "" ) )
		view.Description:SizeToContents()
		view.Description:SetWrap( true )
		view.Description:SetAutoStretchVertical( true )

		if doc.deprecated then
			view.Deprecated:SetVisible( true )
			view.Deprecated.Enabled = true
		else
			view.Deprecated:SetVisible( false )
			view.Deprecated.Enabled = false
		end
		for _, labellist in pairs( helper.LabelLists ) do
			if doc[ labellist.name ] and #doc[ labellist.name ] > 0 then
				labellist.label:SetVisible( true )
				labellist.label.Enabled = true
				labellist.label:SizeToContents()
				labellist.list:SetVisible( true )
				labellist.list:Clear()
				local height = labellist.func( view, doc )
				labellist.list:SetTall( height )
			else
				labellist.label:SetVisible( false )
				labellist.label.Enabled = false
				labellist.list:SetVisible( false )
			end
		end

		timer.Create( "update", 0.1, 1, helper.resize )
	end

	helper.DocView = vgui.Create( "DScrollPanel", helper.Frame )
	helper.DocView:SetPos( 166, 30 )
	helper.DocView:SetVisible( false )
	helper.Views.Doc = helper.DocView

	helper.DocView.Panel = vgui.Create( "DPanel", helper.DocView )

	helper.DocView.Title = Label( "", helper.DocView.Panel )
	helper.DocView.Title:SetPos( 10, 5 )
	helper.DocView.Title:SetFont( "HelperTitle" )
	helper.DocView.Title.m_colText = Color( 60, 60, 60 )

	helper.DocView.Description = Label( "", helper.DocView.Panel )
	helper.DocView.Description:SetPos( 25, 40 )
	helper.DocView.Description:SetFont( "HelperText" )
	helper.DocView.Description.m_colText = Color( 60, 60, 60 )

	helper.DocView.Deprecated = Label( "", helper.DocView.Panel )
	helper.DocView.Deprecated:SetText( "This library/type has been deprecated and will be removed in the future for the following reason: Pure Lua implementation. This can be done with a user library." )
	helper.DocView.Deprecated:SetPos( 25, 40 )
	helper.DocView.Deprecated:SetFont( "HelperTextBold" )
	helper.DocView.Deprecated:SizeToContents()
	helper.DocView.Deprecated:SetWrap( true )
	helper.DocView.Deprecated:SetAutoStretchVertical( true )
	helper.DocView.Deprecated.m_colText = Color( 210, 0, 0 )

	helper.LabelLists = {}
	local function createDocList( name, func, update )
		local label = Label( name, helper.DocView.Panel )
		label:SetPos( 10, 40 )
		label:SetFont( "HelperTitle" )
		label.m_colText = Color( 60, 60, 60 )
		helper.DocView[ name .. "Label" ] = label

		local list = vgui.Create( "DListView", helper.DocView.Panel )
		list:SetPos( 25, 40 )
		list:SetMultiSelect( false )
		list:AddColumn( name ):SetFixedWidth( 150 )
		list:AddColumn( "Description" )
		helper.DocView[ name .. "List" ] = list
		helper.LabelLists[ #helper.LabelLists + 1 ] = { label=label, list=list, func=func, name=string.lower( name ) }

		function list:OnRowSelected( LineID, Line )
			for _, labellist in pairs( helper.LabelLists ) do 
				if labellist.list ~= list then
					labellist.list:ClearSelection()
				end
			end
			update( LineID, Line )
		end
	end
	createDocList( "Functions", function( view, doc )
		local height = 16
		for _, func in ipairs( doc.functions ) do
			local func_data = doc.functions[ func ]
			local description = string.Replace( string.Trim( func_data.summary ), "\n", "" )
			description = string.Replace( description, "<a href=\"", "( " )
			description = string.Replace( description, "\">", ", " )
			description = string.Replace( description, "</br>", "" )
			description = string.Replace( description, "</a>", " )" )
			local line = view.FunctionsList:AddLine( func .. " (" .. table.concat( func_data.param, ", " ) .. ")" , description )
			line.func = func
			height = height + 17
		end
		return height
	end, function( LineID, Line )
		helper.updateInfoPanel( helper.DocView.Doc.functions[ Line.func ] )
	end )
	createDocList( "Tables", function( view, doc )
		local height = 16
		for _, table in ipairs( doc.tables ) do
			local table_data = doc.tables[ table ]
			local line = view.TablesList:AddLine( table , string.Replace( string.Trim( table_data.summary ), "\n", "" ) )
			line.table = table
			height = height + 17
		end
		return height
	end, function( LineID, Line )
		helper.updateInfoPanel( helper.DocView.Doc.tables[ Line.table ] )
	end  )
	createDocList( "Fields", function( view, doc )
		local height = 16
		for _, field in ipairs( doc.fields ) do
			local field_data = doc.fields[ field ]
			view.FieldsList:AddLine( field , string.Replace( string.Trim( field_data.summary ), "\n", "" ) )
			height = height + 17
		end
		return height
	end, function( LineID, Line)  end )
	createDocList( "Methods", function( view, doc )
		local height = 16
		for _, func in ipairs( doc.methods ) do
			local func_data = doc.methods[ func ]
			local description = string.Replace( string.Trim( func_data.summary ), "\n", "" )
			description = string.Replace( description, "<a href=\"", "( " )
			description = string.Replace( description, "\">", ", " )
			description = string.Replace( description, "</br>", "" )
			description = string.Replace( description, "</a>", " )" )
			local line = view.MethodsList:AddLine( func .. " (" .. table.concat( func_data.param, ", " ) .. ")" , description )
			line.func = func
			height = height + 17
		end
		return height
	end, function( LineID, Line )
		helper.updateInfoPanel( helper.DocView.Doc.methods[ Line.func ] )
	end  )
	createDocList( "Hooks", function( view, doc )
		local height = 16
		for _, hook in ipairs( doc.hooks ) do
			local hook_data = doc.hooks[ hook ]
			local line = view.HooksList:AddLine( hook , string.Replace( string.Trim( hook_data.summary ), "\n", "" ) )
			line.hook = hook
			height = height + 17
		end
		return height
	end, function( LineID, Line )
		helper.updateInfoPanel( helper.DocView.Doc.hooks[ Line.hook ] )
	end  )
	createDocList( "Directives", function( view, doc )
		local height = 16
		for _, directive in ipairs( doc.directives ) do
			local directive_data = doc.directives[ directive ]
			local line = view.DirectivesList:AddLine( directive , string.Replace( string.Trim( directive_data.summary ), "\n", "" ) )
			line.directive = directive
			height = height + 17
		end
		return height
	end, function( LineID, Line )
		helper.updateInfoPanel( helper.DocView.Doc.directives[ Line.directive ], true )
	end  )


	---- InfoPanel ----
	-------------------
	function helper.updateInfoPanel( func, directive )
		local infopanel = helper.DocView.InfoPanel
		helper.DocView.Info:GetVBar():SetScroll( 0 )

		directive = nil or directive 

		if not directive then
			infopanel.funcName:SetText( string.Replace( func.name .. "( " .. table.concat( func.param, ", " ) .. " )", "\n", "" ) )
		else
			infopanel.funcName:SetText( string.Replace( "--@" .. func.name .. " " .. table.concat( func.param, ", " ), "\n", "" ) )
		end
		infopanel.funcName.Enabled = true

		infopanel.description:SetText( string.Replace( func.description or "", "\n", "" ) )
		infopanel.description.Enabled = true

		if func.deprecated then 
			infopanel.deprecated:SetText( "Deprecated: " .. string.Replace( func.deprecated, "\n", "" ) ) 
			infopanel.deprecated.Enabled = true
		else 
			infopanel.deprecated.Enabled = false
		end

		if type( func.param ) == "table" and #func.param > 0 then
			local params = ""
			for p = 1, #func.param do
				params = params .. "» " .. func.param[ p ] .. ": " .. ( func.param[ func.param[ p ] ] or "" ) .. ( p ~= #func.param and "\n" or "" ) 
			end
			infopanel.parameters:SetText( "Parameters: " )
			infopanel.parameterList:SetText( params )
			infopanel.parameters.Enabled = true
			infopanel.parameterList.Enabled = true
		elseif #func.param == 0 then
			infopanel.parameters.Enabled = false
			infopanel.parameterList.Enabled = false
		end

		if type( func.ret ) == "string" then
			infopanel.returnvalue:SetText( "Return value: " )
			infopanel.returnvalueList:SetText( func.ret )
			infopanel.returnvalue.Enabled = true
			infopanel.returnvalueList.Enabled = true
		elseif type( func.ret ) == "table" then
			infopanel.returnvalue:SetText( "Return values: " )
			local rets = ""
			local count = 1
			for _, ret in ipairs( func.ret ) do
				rets = rets .. count .. ". " .. ret .. "\n"
				count = count + 1
			end
			infopanel.returnvalueList:SetText( rets )
			infopanel.returnvalue.Enabled = true
			infopanel.returnvalueList.Enabled = true
		else
			infopanel.returnvalue.Enabled = false
			infopanel.returnvalueList.Enabled = false
		end

		if type( func.usage ) == "string" then
			infopanel.usage:SetText( "Usage:" )
			infopanel.usage.Enabled = true
			infopanel.usageBlock:SetText( string.gsub( string.Replace( func.usage , string.char( 9 ), "    " ), "\n", "", 1 ) )
			infopanel.usageBlock.Enabled = true
		elseif not func.usage then
			infopanel.usage.Enabled = false
			infopanel.usageBlock.Enabled = false
		end

		for _, label in pairs( infopanel.labels ) do		
			label:SizeToContents()
			label:SetWrap( true )
			label:SetAutoStretchVertical( true )	
		end	
		timer.Create( "update", 0.1, 1, helper.resize )
	end

	helper.DocView.Info = vgui.Create( "DScrollPanel", helper.Frame )
	helper.DocView.Info:SetTall( 150 )
	helper.DocView.Info:SetVisible( false )

	helper.DocView.InfoPanel = vgui.Create( "DPanel", helper.DocView.Info )
	helper.DocView.InfoPanel:SetSize( 200, 100 )
	local infopanel = helper.DocView.InfoPanel

	helper.DocView.Div = vgui.Create( "DVerticalDivider", helper.Frame )
	helper.DocView.Div:SetPos( 166, 30 )
	helper.DocView.Div:SetTop( helper.DocView )
	helper.DocView.Div:SetBottom( helper.DocView.Info )
	helper.DocView.Div:SetTopMin( 100 )
	helper.DocView.Div:SetBottomMin( 100 )
	helper.DocView.Div:SetDividerHeight( 5 )
	helper.DocView.Div:SetVisible( false )
	helper.DocView.Div._PerformLayout = helper.DocView.Div.PerformLayout
	function helper.DocView.Div:PerformLayout()
		helper.DocView.Div:_PerformLayout()
		helper.resize()
	end

	infopanel.labels = {}

	infopanel.funcName = Label( "Nothing selected", infopanel )
	infopanel.funcName:SetFont( "HelperTextBold" )
	infopanel.funcName:SizeToContents()
	infopanel.funcName.m_colText = Color( 60, 60, 60 )
	infopanel.funcName.indent = 0
	infopanel.labels[ #infopanel.labels + 1 ] = infopanel.funcName

	infopanel.description = Label( "", infopanel )
	infopanel.description:SetFont( "HelperText" )
	infopanel.description.m_colText = Color( 60, 60, 60 )
	infopanel.description.indent = 1
	infopanel.labels[ #infopanel.labels + 1 ] = infopanel.description

	infopanel.deprecated = Label( "", infopanel )
	infopanel.deprecated:SetText( "" )
	infopanel.deprecated:SetFont( "HelperTextBold" )
	infopanel.deprecated:SizeToContents()
	infopanel.deprecated:SetWrap( true )
	infopanel.deprecated:SetAutoStretchVertical( true )
	infopanel.deprecated.m_colText = Color( 210, 0, 0 )
	infopanel.deprecated.indent = 1
	infopanel.labels[ #infopanel.labels + 1 ] = infopanel.deprecated

	infopanel.parameters = Label( "Parameters:", infopanel )
	infopanel.parameters:SetFont( "HelperTextBold" )
	infopanel.parameters.m_colText = Color( 60, 60, 60 )
	infopanel.parameters.indent = 1
	infopanel.labels[ #infopanel.labels + 1 ] = infopanel.parameters

	infopanel.parameterList = Label( "", infopanel )
	infopanel.parameterList:SetFont( "HelperText" )
	infopanel.parameterList.m_colText = Color( 60, 60, 60 )
	infopanel.parameterList.indent = 2
	infopanel.labels[ #infopanel.labels + 1 ] = infopanel.parameterList

	infopanel.returnvalue = Label( "Return Value:", infopanel )
	infopanel.returnvalue:SetFont( "HelperTextBold" )
	infopanel.returnvalue.m_colText = Color( 60, 60, 60 )
	infopanel.returnvalue.indent = 1
	infopanel.labels[ #infopanel.labels + 1 ] = infopanel.returnvalue

	infopanel.returnvalueList = Label( "", infopanel )
	infopanel.returnvalueList:SetFont( "HelperText" )
	infopanel.returnvalueList.m_colText = Color( 60, 60, 60 )
	infopanel.returnvalueList.indent = 2
	infopanel.labels[ #infopanel.labels + 1 ] = infopanel.returnvalueList

	infopanel.usage = Label( "Usage:", infopanel )
	infopanel.usage:SetFont( "HelperTextBold" )
	infopanel.usage.m_colText = Color( 60, 60, 60 )
	infopanel.usage.indent = 1
	infopanel.labels[ #infopanel.labels + 1 ] = infopanel.usage

	infopanel.usageBlock = Label( "", infopanel )
	infopanel.usageBlock:SetFont( "CodeBlock" )
	infopanel.usageBlock.m_colText = Color( 60, 60, 60 )
	infopanel.usageBlock.indent = 3
	infopanel.labels[ #infopanel.labels + 1 ] = infopanel.usageBlock

	---- About View ----
	--------------------
	helper.AboutView = vgui.Create( "DScrollPanel", helper.Frame )
	helper.AboutView:SetPos( 166, 30 )
	helper.AboutView:SetVisible( false )
	helper.Views.About = helper.AboutView

	helper.AboutView.Panel = vgui.Create( "DPanel", helper.AboutView )

	helper.AboutView.About = Label( "Starfall is a Lua sandbox for Garry's mod. It allows players to write Lua scripts for the server without exposing server functionality that could be used maliciously. Since it works with Lua code directly, it's much faster than similar projects like E2 or Lemongate.\n\nStarfall by default includes a 'processor' entity, which is a purely server-side environment with an entity representation, and can have Wiremod inputs/outputs. It also includes a 'screen' entity, which runs code both on the server and each client to allow for fast, lag-free drawing that was previously only possible with GPU.\n\nThis Starfall helper was made by Jazzelhawk.", helper.AboutView.Panel )
	helper.AboutView.About:SetPos( 10, 10 )
	helper.AboutView.About:SetFont( "HelperText" )
	helper.AboutView.About:SizeToContents()
	helper.AboutView.About:SetWrap( true )
	helper.AboutView.About:SetAutoStretchVertical( true )
	helper.AboutView.About.m_colText = Color( 60, 60, 60 )

end

function helper.show()
	if not docs_set then
		helper.getDocs()
		return
	end

	if not helper.Frame then helper.create() end
	helper.Frame:MakePopup()
	helper.Frame:SetVisible(true)
end

local lastw, lasth = 0, 0
settings = helper.Settings
function helper.resize()
	local w, h = helper.Frame:GetSize()

	local changew, changeh = w - lastw, h - lasth

	helper.CatList:SetSize( 155, 375 + h - 410)
	helper.ScrollPanel:SetSize( 155, 375 + h - 410)

	helper.IndexView:SetSize( w - 173, h - 37 )
	helper.IndexLibs:SetSize( w - 183, h / 2 - 26 )
	helper.IndexHooks:SetPos( 5, 10 + helper.IndexLibs:GetTall() )
	helper.IndexHooks:SetSize( w - 183, h / 2 - 27 )

	helper.DocView:SetSize( w - 173, h - 37 - helper.DocView.Info:GetTall() - 5 )
	local w2 = helper.DocView:GetCanvas():GetWide()
	helper.DocView.Description:SetWide( w2 - 50 )
	helper.DocView.Deprecated:SetWide( w2 - 50 )

	--helper.DocView.Info:SetPos( 166, 30 + helper.DocView:GetTall() + 6 )
	helper.DocView.Info:SetWide( w - 173 )
	helper.DocView.InfoPanel:SetWide( w - 173 )

	helper.DocView.Div:SetSize( w - 173, h - 37 )
	helper.DocView.Div:SetTopHeight( helper.DocView.Div:GetTopHeight() + changeh )

	helper.AboutView:SetSize( w - 173, h - 37 )
	helper.AboutView.About:SetWide( helper.AboutView:GetWide() - 20 )
	helper.AboutView.Panel:SetSize( helper.AboutView:GetWide(), math.max( helper.AboutView.About:GetTall() + 10, helper.AboutView:GetTall() ) )

	local runningHeight = 40
	runningHeight = runningHeight + helper.DocView.Description:GetTall() + 10
	if helper.DocView.Deprecated.Enabled then
		helper.DocView.Deprecated:SetPos( 25, runningHeight )
		runningHeight = runningHeight + helper.DocView.Deprecated:GetTall() + 10
	end
	for _, labellist in pairs( helper.LabelLists ) do 
		labellist.list:SetWide( w2 - 50 )
		if labellist.label.Enabled then
			labellist.label:SetPos( 10, runningHeight )
			runningHeight = runningHeight + labellist.label:GetTall() + 10
			labellist.list:SetPos( 25, runningHeight )
			runningHeight = runningHeight + labellist.list:GetTall() + 10
		end
	end

	helper.DocView.Panel:SetSize( helper.DocView:GetWide(), math.max( runningHeight, helper.DocView:GetTall() ) )

	local infopanel = helper.DocView.InfoPanel
	local runningHeight = 10
	for _, label in pairs( infopanel.labels ) do
		label:SetWide( w2 - 50 )
		if label.Enabled then
			label:SetVisible( true )
			label:SetPos( 10 + label.indent*20, runningHeight )
			runningHeight = runningHeight + label:GetTall() + 10
		else
			label:SetVisible( false )
		end
	end

	infopanel:SetSize( infopanel:GetWide(), math.max( runningHeight, helper.DocView.Info:GetTall() ) )

	helper.DocView:GetVBar():SetScroll( helper.DocView:GetVBar():GetScroll() )
	helper.CatList:GetVBar():SetScroll( helper.CatList:GetVBar():GetScroll() )
	helper.IndexLibs.VBar:SetScroll( helper.IndexLibs.VBar:GetScroll() )
	helper.IndexHooks.VBar:SetScroll( helper.IndexHooks.VBar:GetScroll() )
	helper.DocView.Info.VBar:SetScroll( helper.DocView.Info.VBar:GetScroll() )
	helper.AboutView.VBar:SetScroll( helper.AboutView.VBar:GetScroll() )

	if not settings_set then
		helper.Frame:SetSize( settings.FrameWidth, settings.FrameHeight )
		helper.Frame:SetPos( settings.FrameX, settings.FrameY )
		helper.DocView.Div:SetTopHeight( settings.DivHeight )
		settings_set = true
	end

	settings.FrameWidth, settings.FrameHeight = w, h
	settings.FrameX, settings.FrameY = helper.Frame:GetPos()
	settings.DivHeight = helper.DocView.Div:GetTopHeight()

	lastw, lasth = w, h
end