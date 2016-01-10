-- Starfall Derma
-- This is for easily creating derma ui in the style of the Starfall Editor
-- Any derma added should not have anything to do with SF.Editor table apart from design elements e.g. colours, icons

-- Starfall Frame
PANEL = {}

PANEL.windows = {}

function PANEL:Init ()
	self.windows[ #self.windows + 1 ] = self

	self.lockParent = nil
	self.lockChildren = {}
	self.locked = false

	local frame = self
	self:ShowCloseButton( false )
	self:SetDraggable( true )
	self:SetSizable( true )
	self:SetScreenLock( true )
	self:SetDeleteOnClose( false )
	self:MakePopup()
	self:SetVisible( false )

	self.components = {}

	self._PerformLayout = self.PerformLayout
	function self:PerformLayout ( ... )
		local w, h = self:GetSize()
		if w < 105 + self.components[ "buttonHolder" ]:GetWide() then w = 105 + self.components[ "buttonHolder" ]:GetWide() end
		if h < 315 then h = 315 end
		self:SetSize( w, h )

		self:_PerformLayout( ... )
	end

	-- Button Holder
	local buttonHolder = vgui.Create( "DPanel", self )
	buttonHolder.buttons = {}
	buttonHolder.Paint = function () end
	buttonHolder:SetHeight( 22 )
	local spacing = 3
	function buttonHolder:PerformLayout ( ... )
		local wide = 0
		for k, v in pairs( self.buttons ) do
			wide = wide + v.button:GetWide() + spacing
		end
		self:SetWide( wide )

		self:SetPos( frame:GetWide() - 5 - self:GetWide(), 5 )
		local pos = self:GetWide() + spacing
		for k, v in pairs( self.buttons ) do
			pos = pos - spacing - v.button:GetWide()
			v.button:SetPos( pos, 0 )
		end
	end
	function buttonHolder:addButton ( name, button )
		self.buttons[ #self.buttons + 1 ] = { name = name, button = button }
		button:PerformLayout()
		self:PerformLayout()
	end
	function buttonHolder:getButton ( buttonName )
		for k, v in pairs( self.buttons ) do
			if v.name == buttonName then return v.button end
		end
	end
	function buttonHolder:removeButton ( button )
		if button == nil then return end
		for k, v in pairs( self.buttons ) do
			if v.button == button or v.name == button then
				v.button:Remove()
				self.buttons[ k ] = nil
			end
		end
	end
	self:AddComponent( "buttonHolder", buttonHolder )
	-- End Button Holder

	local buttonClose = vgui.Create( "StarfallButton", buttonHolder )
	buttonClose:SetText( "Close" )
	function buttonClose:DoClick ()
		frame:close()
	end
	buttonHolder:addButton( "Close", buttonClose )

	local buttonLock = vgui.Create( "StarfallButton", buttonHolder )
	buttonLock:SetText( "Unlocked" )
	function buttonLock:DoClick ()
		if self.active then
			self.active = false
			self:SetText( "Unlocked" )
			frame.locked = false
		else
			if frame.lockParent then
				self.active = true
				self:SetText( "Locked" )
				frame.locked = true
			end
		end
	end
	buttonHolder:addButton( "Lock", buttonLock )
end
function PANEL:Think ()
	-- Overwriting default think function, mostly copied from default function
	local mousex = math.Clamp( gui.MouseX(), 1, ScrW() - 1 )
	local mousey = math.Clamp( gui.MouseY(), 1, ScrH() - 1 )
	
	self.Dragged = false
	self.Resized = false

	if self.Dragging and not self.locked then

		self.Dragged = true

		local x = mousex - self.Dragging[ 1 ]
		local y = mousey - self.Dragging[ 2 ]

		-- Lock to screen bounds if screenlock is enabled
		if self:GetScreenLock() then
			x = math.Clamp( x, 0, ScrW() - self:GetWide() )
			y = math.Clamp( y, 0, ScrH() - self:GetTall() )
		end
		
		-- Edge snapping
		local minChildX = ScrW()
		local minX = 0
		for k, v in pairs( self.lockChildren ) do
			if v.locked then
				if v:GetPos() < minChildX then
					minChildX = v:GetPos()
					minX = v:GetWide()
				end
			end
		end
		if minChildX > x then minX = 0 end

		local maxChildX = 0
		local maxX = 0
		for k, v in pairs( self.lockChildren ) do
			if v.locked then
				if v:GetPos() + v:GetWide() > maxChildX then
					maxChildX = v:GetPos() + v:GetWide()
					maxX = v:GetWide()
				end
			end
		end
		if maxChildX < x + self:GetWide() then maxX = 0 end

		if x < 10 and x > -10 then
			x = 0
		elseif x + self:GetWide() > ScrW() - 10 and x + self:GetWide() < ScrW() + 10 then
			x = ScrW() - self:GetWide()
		elseif x < minX + 10 and x > minX - 10 then
			x = minX
		elseif x + self:GetWide() > ScrW() - maxX - 10 and x + self:GetWide() < ScrW() - maxX + 10 then
			x = ScrW() - maxX - self:GetWide()
		end 
		if y < 10 then
			y = 0
		elseif y + self:GetTall() > ScrH() - 10 then
			y = ScrH() - self:GetTall()
		end
		for k, v in pairs( self.windows ) do
			if v == self or not v:IsVisible() or table.HasValue( self.lockChildren, v ) and v.locked then goto skip end
			local vx, vy = v:GetPos()
			local snapped = false
			self.lockParent = nil
			v:removeLockChild( self )

			-- Not very easy to read but it works
			if y >= vy and y <= vy + v:GetTall() or y + self:GetTall() >= vy and y + self:GetTall() <= vy + v:GetTall() or y <= vy and y + self:GetTall() >= vy + v:GetTall() then
				if x > vx - 10 and x < vx + 10 then
					x = vx
					self:lock( v )
					snapped = true
				elseif x > vx + v:GetWide() - 10 and x < vx + v:GetWide() + 10 then
					x = vx + v:GetWide()
					self:lock( v )
					snapped = true
				elseif x + self:GetWide() > vx - 10 and x + self:GetWide() < vx + 10 then
					x = vx - self:GetWide()
					self:lock( v )
					snapped = true
				elseif x + self:GetWide() > vx + v:GetWide() - 10 and x + self:GetWide() < vx + v:GetWide() + 10 then
					x = vx + v:GetWide() - self:GetWide()
					self:lock( v )
					snapped = true
				end
			end

			if x >= vx and x <= vx + v:GetWide() or x + self:GetWide() >= vx and x + self:GetWide() <= vx + v:GetWide() or x <= vx and x + self:GetWide() >= vx + v:GetWide() then
				if y > vy - 10 and y < vy + 10 then
					y = vy
					self:lock( v )
					snapped = true
				elseif y > vy + v:GetTall() - 10 and y < vy + v:GetTall() + 10 then
					y = vy + v:GetTall()
					self:lock( v )
					snapped = true
				elseif y + self:GetTall() > vy - 10 and y + self:GetTall() < vy + 10 then
					y = vy - self:GetTall()
					self:lock( v )
					snapped = true
				elseif y + self:GetTall() > vy + v:GetTall() - 10 and y + self:GetTall() < vy + v:GetTall() + 10 then
					y = vy + v:GetTall() - self:GetTall()
					self:lock( v )
					snapped = true
				end
			end

			if snapped then break end

			::skip::
		end

		local dx, dy = self:GetPos()
		dx = x - dx
		dy = y - dy

		self:SetPos( x, y )

		self:moveLockChildren( dx, dy )
	end
	
	if self.Sizing then
		
		self.Resized = true

		local x = self.Sizing[ 1 ] and mousex - self.Sizing[ 1 ] or self:GetWide()
		local y = self.Sizing[ 2 ] and mousey - self.Sizing[ 2 ] or self:GetTall()	
		local px, py = self:GetPos()
		
		if x < self.m_iMinWidth then x = self.m_iMinWidth elseif x > ScrW() - px and self:GetScreenLock() then x = ScrW() - px end
		if y < self.m_iMinHeight then y = self.m_iMinHeight elseif y > ScrH() - py and self:GetScreenLock() then y = ScrH() - py end
	
		for k, v in pairs( self.windows ) do
			if v == self or not v:IsVisible() then goto skip end
			local vx, vy = v:GetPos()

			-- Not very easy to read but it works
			if py >= vy and py <= vy + v:GetTall() or py + y >= vy and py + y <= vy + v:GetTall() or py <= vy and py + y >= vy + v:GetTall() then
				if px + x > vx - 10 and px + x < vx + 10 then
					x = vx - px
				elseif px + x > vx + v:GetWide() - 10 and px + x < vx + v:GetWide() + 10 then
					x = vx + v:GetWide() - px
				end
			end

			if px >= vx and px <= vx + v:GetWide() or px + x >= vx and px + x <= vx + v:GetWide() or px <= vx and px + x >= vx + v:GetWide() then
				if py + y > vy - 10 and py + y < vy + 10 then
					y = vy - py
				elseif py + y > vy + v:GetTall() - 10 and py + y < vy + v:GetTall() + 10 then
					y = vy + v:GetTall() - py
				end
			end

			::skip::
		end

		self:SetSize( x, y )
	end
	
	if self.Hovered and self.m_bSizable and 
	 	mousex > ( self.x + self:GetWide() - 20 ) and mousey > ( self.y + self:GetTall() - 20 ) then

		self:SetCursor( "sizenwse" )
	elseif self.Hovered and self.m_bSizable and
		mousex > ( self.x + self:GetWide() - 5 ) then
		
		self:SetCursor( "sizewe" )
	elseif self.Hovered and self.m_bSizable and
		mousey > ( self.y + self:GetTall() - 5 ) then
		
		self:SetCursor( "sizens" )
	elseif self.Hovered and self:GetDraggable() and mousey < ( self.y + 24 ) and not self.locked then
		self:SetCursor( "sizeall" )
	else
		self:SetCursor( "arrow" )
	end

	-- Don't allow the frame to go higher than 0
	if self.y < 0 then
		self:SetPos( self.x, 0 )
	end

	self:OnThink()

	self.Dragged = nil
	self.Resized = nil
end
function PANEL:OnThink ()

end
function PANEL:OnMousePressed ()
	-- Pretty much copied from default function again
	if self.m_bSizable then
		if gui.MouseX() > ( self.x + self:GetWide() - 20 ) and
			gui.MouseY() > ( self.y + self:GetTall() - 20 ) then			
	
			self.Sizing = { gui.MouseX() - self:GetWide(), gui.MouseY() - self:GetTall() }
			self:MouseCapture( true )
			return
		end
		if gui.MouseX() > ( self.x + self:GetWide() - 5 ) then	
			self.Sizing = { gui.MouseX() - self:GetWide(), nil }
			self:MouseCapture( true )
			return
		end
		if gui.MouseY() > ( self.y + self:GetTall() - 5 ) then
			self.Sizing = { nil, gui.MouseY() - self:GetTall() }
			self:MouseCapture( true )
			return
		end
	end
	
	if self:GetDraggable() and gui.MouseY() < ( self.y + 24 ) then
		self.Dragging = { gui.MouseX() - self.x, gui.MouseY() - self.y }
		self:MouseCapture( true )
		return
	end
end
function PANEL:AddComponent ( name, component )
	self.components[ name ] = component
end
function PANEL:addLockChild ( frame )
	if table.HasValue( self.lockChildren, frame ) then return end
	self.lockChildren[ #self.lockChildren + 1 ] = frame
end
function PANEL:removeLockChild ( frame )
	if not table.HasValue( self.lockChildren, frame ) then return end
	table.RemoveByValue( self.lockChildren, frame )
end
function PANEL:setLockParent ( frame )
	self.lockParent = frame
end
function PANEL:lock ( frame )
	self:setLockParent( frame )
	frame:addLockChild( self )
end
function PANEL:moveLockChildren ( x, y )
	for k, v in pairs( self.lockChildren ) do
		if v.locked then 
			local vx, vy = v:GetPos()
			v:SetPos( vx + x, vy + y )
			v:moveLockChildren( x, y )
		end
	end
end
PANEL.Paint = function ( panel, w, h )
	draw.RoundedBox( 0, 0, 0, w, h, SF.Editor.colors.dark )
end
function PANEL:open ()

	for k, v in pairs( self.lockChildren ) do
		if v.locked then
			v:open()
		end
	end

	self:SetVisible( true )
	self:SetKeyBoardInputEnabled( true )
	self:MakePopup()
	self:InvalidateLayout( true )

	self:OnOpen()
end
function PANEL:close ()
	for k, v in pairs( self.lockChildren ) do
		if v.locked then
			v:close()
		end
	end

	self:OnClose()

	self:SetKeyBoardInputEnabled( false )
	self:Close()
end
function PANEL:OnOpen ()
	
end
function PANEL:OnClose ()

end
vgui.Register( "StarfallFrame", PANEL, "DFrame" )
-- End Starfall Frame

--------------------------------------------------------------
--------------------------------------------------------------

-- Starfall Button
PANEL = {}

function PANEL:Init ()
	self:SetText( "" )
	self:SetSize( 22, 22 )
end
function PANEL:SetIcon ( icon )
	self.icon = SF.Editor.icons[ icon ]
end
function PANEL:PerformLayout ()
	if self:GetText() ~= "" then
		self:SizeToContentsX()
		self:SetWide( self:GetWide() + 14 )
	end
end
PANEL.Paint = function ( button, w, h )
	if button.Hovered or button.active then
		draw.RoundedBox( 0, 0, 0, w, h, button.backgroundHoverCol or SF.Editor.colors.med )
	else
		draw.RoundedBox( 0, 0, 0, w, h, button.backgroundCol or SF.Editor.colors.meddark )
	end
	if button.icon then
		surface.SetDrawColor( SF.Editor.colors.medlight )
		surface.SetMaterial( button.icon )
		surface.DrawTexturedRect( 2, 2, w - 4, h - 4 )
	end
end
function PANEL:UpdateColours ( skin )
	return self:SetTextStyleColor( self.labelCol or SF.Editor.colors.light )
end
function PANEL:SetHoverColor ( col )
	self.backgroundHoverCol = col
end
function PANEL:SetColor ( col )
	self.backgroundCol = col
end
function PANEL:SetLabelColor ( col )
	self.labelCol = col
end
function PANEL:DoClick ()

end

vgui.Register( "StarfallButton", PANEL, "DButton" )
-- End Starfall Button

--------------------------------------------------------------
--------------------------------------------------------------

-- Starfall Panel
PANEL = {}
PANEL.Paint = function ( panel, w, h )
	draw.RoundedBox( 0, 0, 0, w, h, SF.Editor.colors.light )
end
vgui.Register( "StarfallPanel", PANEL, "DPanel" )
-- End Starfall Panel

--------------------------------------------------------------
--------------------------------------------------------------

-- Tab Holder
PANEL = {}

function PANEL:Init ()
	self:SetTall( 22 )
	self.offsetTabs = 0
	self.tabs = {}

	local parent = self

	self.offsetRight = vgui.Create( "StarfallButton", self )
	self.offsetRight:SetVisible( false )
	self.offsetRight:SetSize( 22, 22 )
	self.offsetRight:SetIcon( "arrowr" )
	function self.offsetRight:PerformLayout ()
		local wide = 0
		if parent.offsetLeft:IsVisible() then 
			wide = parent.offsetLeft:GetWide() + 2 
		end
		for i = parent.offsetTabs + 1, #parent.tabs do
			if wide + parent.tabs[ i ]:GetWide() > parent:GetWide() - self:GetWide() - 2 then 
				break 
			else
				wide = wide + parent.tabs[ i ]:GetWide() + 2
			end
		end
		self:SetPos( wide, 0 )
	end
	function self.offsetRight:DoClick ()
		parent.offsetTabs = parent.offsetTabs + 1
		if parent.offsetTabs > #parent.tabs - 1 then
			parent.offsetTabs = #parent.tabs - 1
		end
		parent:InvalidateLayout()
	end

	self.offsetLeft = vgui.Create( "StarfallButton", self )
	self.offsetLeft:SetVisible( false )
	self.offsetLeft:SetSize( 22, 22 )
	self.offsetLeft:SetIcon( "arrowl" )
	function self.offsetLeft:DoClick ()
		parent.offsetTabs = parent.offsetTabs - 1
		if parent.offsetTabs < 0 then
			parent.offsetTabs = 0
		end
		parent:InvalidateLayout()
	end

	self.menuoptions = {}

	self.menuoptions[ #self.menuoptions + 1 ] = { "Close", function ()
		if not self.targetTab then return end
		self:removeTab( self.targetTab )
		self.targetTab = nil
	end }
	self.menuoptions[ #self.menuoptions + 1 ] = { "Close Other Tabs", function ()
		if not self.targetTab then return end
		local n = 1
		while #self.tabs ~= 1 do
			v = self.tabs[ n ]
			if v ~= self.targetTab then 
				self:removeTab( v )
			else
				n = 2
			end
		end
		self.targetTab = nil
	end }
end 
PANEL.Paint = function () end
function PANEL:PerformLayout ()
	local parent = self:GetParent()
	self:SetWide( parent:GetWide() - 10 )
	self.offsetRight:PerformLayout()
	self.offsetLeft:PerformLayout()

	local offset = 0
	if self.offsetLeft:IsVisible() then
		offset = self.offsetLeft:GetWide() + 2
	end
	for i = 1, self.offsetTabs do
		offset = offset - self.tabs[ i ]:GetWide() - 2
	end
	local bool = false
	for k, v in pairs( self.tabs ) do
		v:SetPos( offset, 0 )
		if offset < 0 then
			v:SetVisible( false )
		elseif offset + v:GetWide() > self:GetWide() - self.offsetRight:GetWide() - 2 then
			v:SetVisible( false )
			bool = true
		else
			v:SetVisible( true )
		end
		offset = offset + v:GetWide() + 2
	end

	if bool then
		self.offsetRight:SetVisible( true )
	else
		self.offsetRight:SetVisible( false )
	end
	if self.offsetTabs > 0 then
		self.offsetLeft:SetVisible( true )
	else
		self.offsetLeft:SetVisible( false )
	end
end
function PANEL:addTab ( text )
	local panel = self
	local tab = vgui.Create( "StarfallButton", self )
	tab:SetText( text )
	tab.isTab = true

	function tab:DoClick ()
		panel:selectTab( self )
	end

	function tab:DoRightClick ()
		panel.targetTab = self
		local menu = vgui.Create( "DMenu", panel:GetParent() )
		for k, v in pairs( panel.menuoptions ) do
			local option, func = v[ 1 ], v[ 2 ]
			if func == "SPACER" then
				menu:AddSpacer()
			else
				menu:AddOption( option, func )
			end
		end
		menu:Open()
	end

	function tab:DoMiddleClick ()
		panel:removeTab( self )
	end

	self.tabs[ #self.tabs + 1 ] = tab

	return tab
end
function PANEL:removeTab ( tab )
	local tabIndex 
	if type( tab ) == "number" then
		tabIndex = tab
		tab = self.tabs[ tab ]  
	else
		tabIndex = self:getTabIndex( tab )
	end

	table.remove( self.tabs, tabIndex )
	tab:Remove()

	self:OnRemoveTab( tabIndex )
end
function PANEL:getActiveTab ()
	for k,v in pairs( self.tabs ) do
		if v.active then return v end
	end
end
function PANEL:getTabIndex ( tab )
	return table.KeyFromValue( self.tabs, tab )
end
function PANEL:selectTab ( tab )
	if type( tab ) == "number" then
		tab = self.tabs[ tab ]  
	end
	if tab == nil then return end

	if self:getActiveTab() == tab then return end

	for k,v in pairs( self.tabs ) do
		v.active = false
	end
	tab.active = true

	if self:getTabIndex( tab ) <= self.offsetTabs then
		self.offsetTabs = self:getTabIndex( tab ) - 1
	elseif not tab:IsVisible() then
		while not tab:IsVisible() do
			self.offsetTabs = self.offsetTabs + 1
			self:PerformLayout()
		end
	end
end
function PANEL:OnRemoveTab ( tabIndex )

end
vgui.Register( "StarfallTabHolder", PANEL, "DPanel" )
-- End Tab Holder

--------------------------------------------------------------
--------------------------------------------------------------

-- File Tree
local invalid_filename_chars = {
	["*"] = "",
	["?"] = "",
	[">"] = "",
	["<"] = "",
	["|"] = "",
	["\\"] = "",
	['"'] = "",
}

PANEL = {}

function PANEL:Init ()

end
function PANEL:setup ( folder )
	self.folder = folder
	self.Root = self.RootNode:AddFolder( folder, folder, "DATA", true )
	self.Root:SetExpanded( true )
end
function PANEL:reloadTree ()
	self.Root:Remove()
	self:setup( self.folder )
end
function PANEL:DoRightClick ( node )
	self:openMenu( node )
end
function PANEL:openMenu ( node )
	local menu
	if node:GetFileName() then
		menu = "file"
	elseif node:GetFolder() then
		menu = "folder"
	end
	self.menu = vgui.Create( "DMenu", self:GetParent() )
	if menu == "file" then
		self.menu:AddOption( "Open", function ()
			self:OnNodeSelected( node )
		end )
		self.menu:AddSpacer()
		self.menu:AddOption( "Rename", function ()
			Derma_StringRequestNoBlur(
				"Rename file",
				"",
				string.StripExtension( node:GetText() ),
				function ( text )
					if text == "" then return end
					text = string.gsub( text, ".", invalid_filename_chars )
					local saveFile = "starfall/"..text..".txt"
					local contents = file.Read( node:GetFileName() )
					file.Delete( node:GetFileName() )
					file.Write( saveFile, contents )
					SF.AddNotify( LocalPlayer(), "File renamed as " .. saveFile .. ".", NOTIFY_GENERIC, 7, NOTIFYSOUND_DRIP3 )
					self:reloadTree()
				end
			)
		end )
		self.menu:AddSpacer()
		self.menu:AddOption( "Delete", function ()
			Derma_Query(
				"Are you sure you want to delete this file?",
				"Delete file",
				"Delete",
				function ()
					file.Delete( node:GetFileName() )
					SF.AddNotify( LocalPlayer(), "File deleted: " .. node:GetFileName(), NOTIFY_GENERIC, 7, NOTIFYSOUND_DRIP3 )
					self:reloadTree()
				end,
				"Cancel"
			)
		end )
	elseif menu == "folder" then
		self.menu:AddOption( "New file", function ()
			Derma_StringRequestNoBlur(
				"New file",
				"",
				"",
				function ( text )
					if text == "" then return end
					text = string.gsub( text, ".", invalid_filename_chars )
					local saveFile = node:GetFolder().."/"..text..".txt"
					file.Write( saveFile, "" )
					SF.AddNotify( LocalPlayer(), "New file: " .. saveFile, NOTIFY_GENERIC, 7, NOTIFYSOUND_DRIP3 )
					self:reloadTree()
				end
			)
		end )
		self.menu:AddSpacer()
		self.menu:AddOption( "New folder", function ()
			Derma_StringRequestNoBlur(
				"New folder",
				"",
				"",
				function ( text )
					if text == "" then return end
					text = string.gsub( text, ".", invalid_filename_chars )
					local saveFile = node:GetFolder().."/"..text
					file.CreateDir( saveFile )
					SF.AddNotify( LocalPlayer(), "New folder: " .. saveFile, NOTIFY_GENERIC, 7, NOTIFYSOUND_DRIP3 )
					self:reloadTree()
				end
			)
		end )
	end
	self.menu:Open()
end


derma.DefineControl( "StarfallFileTree", "", PANEL, "DTree" )
-- End File Tree

--------------------------------------------------------------
--------------------------------------------------------------

-- File Browser
PANEL = {}

function PANEL:Init ()

	self:Dock( FILL )
	self:DockMargin( 0, 5, 0, 0 )
	self.Paint = function () end

	local tree = vgui.Create( "StarfallFileTree", self )
	tree:Dock( FILL )

	self.tree = tree

	local searchBox = vgui.Create( "DTextEntry", self )
	searchBox:Dock( TOP )
	searchBox:SetValue( "Search..." )

	searchBox._OnGetFocus = searchBox.OnGetFocus
	function searchBox:OnGetFocus ()
		if self:GetValue() == "Search..." then
			self:SetValue( "" )
		end
		searchBox:_OnGetFocus()
	end

	searchBox._OnLoseFocus = searchBox.OnLoseFocus
	function searchBox:OnLoseFocus ()
		if self:GetValue() == "" then
			self:SetText( "Search..." )
		end
		searchBox:_OnLoseFocus()
	end

	function searchBox:OnChange ()

		if self:GetValue() == "" then
			tree:reloadTree()
			return
		end

		tree.Root.ChildNodes:Clear()
		local function containsFile ( dir, search )
			local files, folders = file.Find( dir .. "/*", "DATA" )
			for k, file in pairs( files ) do
				if string.find( string.lower( file ), string.lower( search ) ) then return true end
			end
			for k, folder in pairs( folders ) do
				if containsFile( dir .. "/" .. folder, search ) then return true end
			end
			return false
		end
		local function addFiles ( search, dir, node )
			local allFiles, allFolders = file.Find( dir .. "/*", "DATA" )
			for k, v in pairs( allFolders ) do
				if containsFile( dir .. "/" .. v, search ) then
					local newNode = node:AddNode( v )
					newNode:SetExpanded( true )
					addFiles( search, dir .. "/" .. v, newNode )
				end
			end
			for k, v in pairs( allFiles ) do
				if string.find( string.lower( v ), string.lower( search ) ) then
					node:AddNode( v, "icon16/page_white.png" )
				end
			end
		end
		addFiles( self:GetValue():PatternSafe(), "starfall", tree.Root )
		tree.Root:SetExpanded( true )
	end
	self.searchBox = searchBox

end
function PANEL:getComponents ()
	return self.searchBox, self.tree
end

derma.DefineControl( "StarfallFileBrowser", "", PANEL, "DPanel" )
-- End File Browser
