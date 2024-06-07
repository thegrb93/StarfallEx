-- Starfall Derma

-- Starfall Frame
local PANEL = {}

PANEL.windows = {}

--[[ Fonts ]]

surface.CreateFont( "SF_PermissionsWarning", {
	font = "roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 16,
})

surface.CreateFont( "SF_PermissionName", {
	font = "roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 20,
})

surface.CreateFont( "SF_PermissionDesc", {
	font = "roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 18,
})

surface.CreateFont( "SF_PermissionsTitle", {
	font = "roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 20,
})

surface.CreateFont("SFTitle", {
	font = "Roboto",
	size = 18,
	weight = 500,
	antialias = true,
	additive = false,
})

--[[ StarfallFrame ]]

function PANEL:Init()
	for _, v in pairs(self:GetChildren()) do v:Remove() end
	local frame = self
	self:ShowCloseButton(false)
	self:SetDraggable(true)
	self:SetSizable(true)
	self:SetScreenLock(true)
	self:SetDeleteOnClose(false)
	self:MakePopup()
	self:SetVisible(false)
	self.Title = ""
	self:DockPadding(5, 0, 5, 5)

	self.TitleBar = vgui.Create("DPanel", self)
	self.TitleBar:Dock(TOP)
	self.TitleBar:SetTall(24)
	self.TitleBar:DockPadding(2, 4, 2, 0)
	self.TitleBar:DockMargin(0, 0, 0, 2)
	self.TitleBar:SetCursor("sizeall")
	self.TitleBar.Paint = self.PaintTitle
	self.TitleBar.OnMousePressed = function(_,...) self:OnMousePressed(...) end

	self.CloseButton = vgui.Create("StarfallButton", self.TitleBar)
	self.CloseButton:SetText("Close")
	self.CloseButton:Dock(RIGHT)
	self.CloseButton.DoClick = function() self:Close() end

	self._Close = self.Close
	self.Close = self.new_Close
end

function PANEL:PerformLayout()

end

function PANEL:SetTitle(text)
	self.Title = text
	self.TitleWidth = surface.GetTextSize(self.Title)
end

function PANEL:GetTitle()
	return self.Title
end

function PANEL:PaintTitle(w,h)
	surface.SetFont("SFTitle")
	surface.SetTextColor(255, 255, 255, 255)
	surface.SetTextPos(0, 6)
	surface.DrawText(self:GetParent().Title)
end

function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, SF.Editor.colors.dark)
end

function PANEL:Open()
	self:SetVisible(true)
	self:SetKeyBoardInputEnabled(true)
	self:MakePopup()
	self:InvalidateLayout(true)

	self:OnOpen()
end
function PANEL:new_Close()
	self:OnClose()
	self:SetKeyBoardInputEnabled(false)
	self:_Close()
end

function PANEL:OnOpen()
end
function PANEL:OnClose()
end

vgui.Register("StarfallFrame", PANEL, "DFrame")
-- End Starfall Frame

--------------------------------------------------------------
--------------------------------------------------------------

-- Starfall Button
PANEL = {}

local icon_cache = {

}

function PANEL:Init()
	self:SetText("")
	self:SetSize(22, 22)
	self.autoSize = true
end
function PANEL:SetIcon(icon)
	if icon_cache[icon] then
		icon = icon_cache[icon]
	else
		icon = Material(icon, "noclamp smooth")
	end
	self.icon = icon
end
function PANEL:SetAutoSize(val)
	self.autoSize = val
end
function PANEL:PerformLayout()
	if self:GetText() ~= "" and self.autoSize then
		self:SizeToContentsX()
		self:SetWide(self:GetWide() + 14)
	end
end
PANEL.Paint = function (button, w, h)
	if not button:IsEnabled() then
		draw.RoundedBox(0, 0, 0, w, h, button.backgroundDisabledCol or SF.Editor.colors.meddark)
	elseif button.Hovered or button.active then
		draw.RoundedBox(0, 0, 0, w, h, button.backgroundHoverCol or SF.Editor.colors.med)
	else
		draw.RoundedBox(0, 0, 0, w, h, button.backgroundCol or SF.Editor.colors.meddark)
	end
	if button.icon then
		surface.SetDrawColor(Color(255,255,255,255))
		surface.SetMaterial(button.icon)
		surface.DrawTexturedRect(6, h/2 - 8, 16, 16)
	end
end
function PANEL:PaintOver(w, h)
	if not self:IsEnabled() then
		surface.SetDrawColor(Color(127, 127, 127, 127))
		surface.DrawRect(0, 0, w, h)
	end
end
function PANEL:UpdateColours(skin)
	return self:SetTextStyleColor(self.labelCol or SF.Editor.colors.light)
end
function PANEL:SetHoverColor(col)
	self.backgroundHoverCol = col
end
function PANEL:SetDisabledColor(col)
	self.backgroundDisabledCol = col
end
function PANEL:SetColor(col)
	self.backgroundCol = col
end
function PANEL:SetLabelColor(col)
	self.labelCol = col
end
function PANEL:DoClick()

end

vgui.Register("StarfallButton", PANEL, "DButton")
-- End Starfall Button

--------------------------------------------------------------
--------------------------------------------------------------

-- Starfall Panel
PANEL = {}

function PANEL:SetBackgroundColor(col)
	self.backgroundCol = col
end

function PANEL:Paint(w, h)
	draw.RoundedBox(0, 0, 0, w, h, self.backgroundCol or SF.Editor.colors.light)
end
vgui.Register("StarfallPanel", PANEL, "DPanel")
-- End Starfall Panel

-- File Tree
local invalid_filename_chars = {
	["*"] = "",
	["?"] = "",
	[">"] = "",
	["<"] = "",
	["|"] = "",
	['"'] = "",
}

local searchDebounceTimerId = "sf_editor_search_debounce"

PANEL = {}

function PANEL:Init()
end

local function moveFile(fileNode, toNode)
	if toNode:GetFileName() then return false end
	if fileNode == toNode then return false end
	local sourcePath

	if fileNode:GetFolder() then
		sourcePath = fileNode:GetFolder()
	elseif fileNode:GetFileName() then
		sourcePath = fileNode:GetFileName()
	end

	local sourceName = string.GetFileFromFilename(sourcePath)
	
	if file.Exists(toNode:GetFolder() .. "/" .. sourceName, "Data") then
		SF.AddNotify(LocalPlayer(), "Failed to move " .. sourceName .. ", it already exists in: " .. toNode:GetFolder(), "ERROR", 7, "ERROR1")
		return false
	end

	if file.Rename(sourcePath, toNode:GetFolder() .. "/" .. sourceName) then
		SF.AddNotify(LocalPlayer(), "Moved " .. sourceName .. " to " .. toNode:GetFolder(), "GENERIC", 7, "DRIP3")
	else return false end

	return true
end

local function addDragHandling(node)
	-- Monkey patch solution, the current implementation of draggable DTree_nodes requires extending and
	-- overriding AddNode. Along with copy-pasting behavior due to an annoying hard-code.
	local setparent = node.SetParent
	function node:SetParent(pnl)
		moveFile(node, pnl:GetParent())
		setparent(self, pnl)
		node:GetRoot():ReloadTree()
	end
end

function PANEL:Setup(folder)
	self.folder = folder
	self.Root = self.RootNode:AddNode(folder)
	self.expansions = {}
	addDragHandling(self.Root)
	self.Root:SetDraggableName("sf_filenode")
	self.Root:SetFolder(folder)

	self.Libraries = self.RootNode:AddNode("Public Libs","icon16/plugin.png")
	for k, v in pairs{
		{"Async", "https://raw.githubusercontent.com/keever50/StarfallLibraries/master/async.txt"},
		{"Console", "https://raw.githubusercontent.com/Derpius/public-starfalls/master/console/console.txt"},
		{"CriticalPD", "https://raw.githubusercontent.com/thegrb93/MyStarfallScripts/master/libs/CriticalPD.txt"},
		{"GifLoader", "https://raw.githubusercontent.com/thegrb93/MyStarfallScripts/master/libs/gifspritesheet.txt"},
		{"HoloText", "https://raw.githubusercontent.com/Derpius/public-starfalls/master/libs/holotext/main.txt"},
		{"HttpQueue", "https://raw.githubusercontent.com/ANormalTwig/PublicStarfalls/main/libraries/http_queueing.lua"},
		{"ModelLoader", "https://raw.githubusercontent.com/thegrb93/MyStarfallScripts/master/libs/custommodellib.txt"},
		{"ReadWriteType", "https://raw.githubusercontent.com/Jacbo1/Public-Starfall/main/ReadWriteType/readwritetype.lua"},
		{"SafeNet", "https://raw.githubusercontent.com/Jacbo1/Public-Starfall/main/SafeNet/safeNet.lua"},
		{"XInputNet", "https://raw.githubusercontent.com/thegrb93/MyStarfallScripts/master/libs/xinput.txt"},
	} do
		local node = self.Libraries:AddNode(v[1], "icon16/page_white.png")
		node.FileURL = v[2]
	end

	local examples_url = "https://api.github.com/repos/thegrb93/StarfallEx/contents/lua/starfall/examples"
	http.Fetch( examples_url,
		function( body, len, headers, code )
			if code == 200 then -- OK code
				local data = util.JSONToTable( body )
				self.Examples = self.RootNode:AddNode("Examples","icon16/help.png")
				for k,v in pairs(data) do
					if v.name ~= "resources" and v.type ~= "dir" then
						local node = self.Examples:AddNode(v.name,"icon16/page_white.png")
						node.FileURL = v.download_url
					end
				end
			end
		end,
		function( error )
			print("[SF] Examples failed to load:"..tostring(error))
		end
	)

	self:AddFiles("")
end

local function sort(tbl)
	local sorted = {}
	for k, v in pairs(tbl) do sorted[#sorted+1] = {string.lower(v), v} end
	table.sort(sorted, function(a,b) return a[1]<b[1] end)
	for k, v in pairs(sorted) do tbl[k] = v[2] end
end
local function addFiles(search, dir, node, expansions)
	local found = false
	local allFiles, allFolders = file.Find(dir .. "/*", "DATA")
	allFiles = allFiles or {}
	allFolders = allFolders or {}
	sort(allFiles)
	sort(allFolders)
	if search=="" then
		for k, v in pairs(allFolders) do
			local newNode = node:AddNode(v)
			addDragHandling(newNode)
			newNode:SetFolder(dir .. "/" .. v)
			local childExpansions = expansions[v]
			addFiles(search, dir .. "/" .. v, newNode, childExpansions or {})
			if childExpansions then
				newNode:SetExpanded(true)
			end
		end
		for k, v in pairs(allFiles) do
			local fnode = node:AddNode(v, "icon16/page_white.png")
			addDragHandling(fnode)
			fnode:SetFileName(dir.."/"..v)
		end
	else
		for k, v in pairs(allFolders) do
			local newNode = node:AddNode(v)
			addDragHandling(newNode)
			newNode:SetFolder(v)
			local childExpansions = expansions[v]
			if addFiles(search, dir .. "/" .. v, newNode, childExpansions or {}) then
				newNode:SetExpanded(true)
				found = true
			else
				newNode:Remove()
			end
		end
		for k, v in pairs(allFiles) do
			if string.find(string.lower(v), string.lower(search)) then
				local fnode = node:AddNode(v, "icon16/page_white.png")
				addDragHandling(fnode)
				fnode:SetFileName(dir.."/"..v)
				found = true
			end
		end
	end
	return found
end

local function getNodeExpansions(node)
	local expanded = {}
	for k, child in pairs(node:GetChildNodes()) do
		if child:GetExpanded() then
			local name = child:GetText()
			expanded[name] = getNodeExpansions(child)
		end
	end
	return expanded
end

function PANEL:UpdateNodeExpantions()
	local expansions = getNodeExpansions(self.Root)
	self.expansions = expansions
end

function PANEL:AddFiles(filter, keepExpanded)
	if self.Root.ChildNodes then self.Root.ChildNodes:Clear() end
	if addFiles(filter, "starfall", self.Root, keepExpanded and self.expansions or {}) then
		self.Root:SetExpanded(true)
	end
	self.Root:SetExpanded(true)
end

function PANEL:ReloadTree()
	if self:ShouldUpdateExpanded() then
		self:UpdateNodeExpantions()
	end
	timer.Remove(searchDebounceTimerId)
	self:AddFiles("", true)
end

function PANEL:ShouldUpdateExpanded()
	local searchStr = self:GetParent().searchBox:GetValue():PatternSafe()
	return searchStr == ""
end

function PANEL:DoRightClick(node)
	local menu
	if node:GetFileName() then
		menu = "file"
	elseif node:GetFolder() then
		menu = "folder"
	end
	self.menu = vgui.Create("DMenu", self:GetParent())
	if menu == "file" then
		self.menu:AddOption("Open", function ()
				SF.Editor.openFile(node:GetFileName())
			end)
		self.menu:AddOption("Open in new tab", function ()
				SF.Editor.openFile(node:GetFileName(), true)
			end)
		self.menu:AddSpacer()
		self.menu:AddOption("Rename", function ()
				Derma_StringRequestNoBlur("Rename file",
					"",
					string.StripExtension(node:GetText()),
					function (text)
						if text == "" then return end
						text = string.gsub(text, ".", invalid_filename_chars)
						local oldFile = node:GetFileName()
						local saveFile
						if string.sub(text, 1, 1)=="/" then
							saveFile = "starfall/"..SF.NormalizePath(text)
						else
							saveFile = string.GetPathFromFilename(node:GetFileName())..SF.NormalizePath(text)
						end
						if not string.match(saveFile, "%.txt$") then saveFile = saveFile .. ".txt" end
						SF.Editor.renameFile(oldFile,saveFile)
						self:ReloadTree()
					end)
				end)
		self.menu:AddSpacer()
		self.menu:AddOption("Delete", function ()
				Derma_Query("Are you sure you want to delete this file?",
					"Delete file",
					"Delete",
					function ()
						file.Delete(node:GetFileName())
						SF.AddNotify(LocalPlayer(), "File deleted: " .. node:GetFileName(), "GENERIC", 7, "DRIP3")
						self:ReloadTree()
					end,
					"Cancel")
			end)
	elseif menu == "folder" then
		local function expandChildren(node, expand)
			for k, child in pairs(node:GetChildNodes()) do
				if child:GetFolder() then
					child:SetExpanded(expand)
					expandChildren(child, expand)
				end
			end
		end

		self.menu:AddOption("Expand recursively", function ()
			node:SetExpanded(true)
			expandChildren(node, true)
		end)
		self.menu:AddOption("Collapse recursively", function ()
			node:SetExpanded(false)
			expandChildren(node, false)
		end)
		self.menu:AddSpacer()
		self.menu:AddOption("New file", function ()
				Derma_StringRequestNoBlur("New file",
					"",
					"",
					function (text)
						if text == "" then return end
						text = string.GetFileFromFilename(string.gsub(text, ".", invalid_filename_chars))
						local saveFile = node:GetFolder().."/"..text
						if not string.match(saveFile, "%.txt$") then saveFile = saveFile .. ".txt" end
						SF.FileWrite(saveFile, SF.DefaultCode())
						SF.AddNotify(LocalPlayer(), "New file: " .. saveFile, "GENERIC", 7, "DRIP3")
						self:ReloadTree()
						SF.Editor.openFile(saveFile)
					end)
			end)
		self.menu:AddSpacer()
		self.menu:AddOption("New folder", function ()
				Derma_StringRequestNoBlur("New folder",
					"",
					"",
					function (text)
						if text == "" then return end
						text = string.GetFileFromFilename(string.gsub(text, ".", invalid_filename_chars))
						local saveFile = node:GetFolder().."/"..text
						file.CreateDir(saveFile)
						SF.AddNotify(LocalPlayer(), "New folder: " .. saveFile, "GENERIC", 7, "DRIP3")
						self:ReloadTree()
					end)
			end)
		self.menu:AddSpacer()
		self.menu:AddOption("Delete", function ()
				Derma_Query("Are you sure you want to delete this folder?",
					"Delete folder",
					"Delete",
					function ()
						-- Recursive delete
						SF.DeleteFolder(node:GetFolder())
						SF.AddNotify(LocalPlayer(), "Folder deleted: " .. node:GetFolder(), "GENERIC", 7, "DRIP3")
						self:ReloadTree()
					end,
					"Cancel")
			end)
	end
	self.menu:Open()
end

derma.DefineControl("StarfallFileTree", "", PANEL, "DTree")
-- End File Tree

--------------------------------------------------------------
--------------------------------------------------------------

-- File Browser
PANEL = {}

function PANEL:Init()

	self:Dock(FILL)
	self:DockMargin(0, 5, 0, 0)
	self.Paint = function () end

	local tree = vgui.Create("StarfallFileTree", self)
	tree:Dock(FILL)

	self.tree = tree

	local searchBox = vgui.Create("DTextEntry", self)
	self.searchBox = searchBox
	searchBox:Dock(TOP)
	searchBox:SetPlaceholderText("Search...")

	searchBox._OnGetFocus = searchBox.OnGetFocus
	function searchBox:OnGetFocus()
		if tree:ShouldUpdateExpanded() then
			tree:UpdateNodeExpantions()
		end
		searchBox:_OnGetFocus()
	end

	searchBox._OnLoseFocus = searchBox.OnLoseFocus
	function searchBox:OnLoseFocus()
		timer.Adjust(searchDebounceTimerId, 0)
		searchBox:_OnLoseFocus()
	end

	function searchBox:OnChange()
		self:Debounce(function()
			local searchStr = self:GetValue():PatternSafe()
			tree:AddFiles(searchStr, searchStr == "")
		end)
	end

	function searchBox:Debounce(callback)
		timer.Create(searchDebounceTimerId, 0.5, 1, function()
			callback()
		end)
	end

	function searchBox:OnRemove()
		timer.Remove(searchDebounceTimerId)
	end

	self.Update = vgui.Create("DButton", self)
	self.Update:SetTall(20)
	self.Update:Dock(BOTTOM)
	self.Update:DockMargin(0, 0, 0, 0)
	self.Update:SetText("Refresh")
	self.Update.DoClick = function(button)
		tree:ReloadTree()
		searchBox:SetValue("")
	end
end

function PANEL:GetComponents()
	return self.searchBox, self.tree
end

derma.DefineControl("StarfallFileBrowser", "", PANEL, "DPanel")
-- End File Browser

--[[ Permissions ]]

PANEL = {}

local function CreatePermissionsPanel( parent )
	local chip = parent.chip
	local panel = vgui.Create( 'DPanel', parent )
	panel:Dock( FILL )
	panel:DockMargin( 0, 0, 0, 0 )
	panel.Paint = function () end
	panel.index = { [ 1 ] = {}, [ 2 ] = {} } -- Locate any permission panel by area and id with ease

	local permStates = {
		{
			iconMat = Material( 'icon16/joystick_add.png' ),
			color = Color( 0, 0, 0, 0 ),
			stillText = 'Awaiting your decision.\nLeft click to mark for granting.'
		},
		{
			iconMat = Material( 'icon16/tick.png' ),
			color = SF.Editor.colors.med,
			changedText = 'Override is marked for granting.\nYou need to apply it to make the change take effect.',
			stillText = 'Already granted override.\nLeft or right click to mark for revocation.'
		},
		{
			iconMat = Material( 'icon16/stop.png' ),
			color = Color( 50, 0, 0 ),
			changedText = 'Marked for revocation.\nLeft click to undo.'
		}
	}

	local listedPerms = {
		chip.instance.permissionRequest.overrides,
		parent.overrides
	}
	for area, set in ipairs( listedPerms ) do
		local scrollPanel = vgui.Create( 'DScrollPanel', panel )
		scrollPanel:Dock( FILL )
		--scrollPanel.Paint = function () end
		scrollPanel:Clear()
		for id, _ in SortedPairs( set ) do
			local permission = SF.Permissions.privileges[ id ]

			local name = permission.name
			local description = permission.description

			local perm = vgui.Create( 'DLabel' )
			perm:Dock( TOP )
			perm:DockMargin( 0, 5, 0, 5 )
			perm:DockPadding( 5, 5, 5, 5 )
			perm:SetTall( 50 )
			perm:SetIsToggle( true )
			perm:SetCursor( 'hand' )
			perm:SetText( '' )
			perm.Paint = function ( s, w, h )
				draw.RoundedBox( 0, 0, 0, w, h, permStates[ perm.state ].color )
				if perm.state ~= perm.initialState then
					draw.RoundedBox( 0, 0, 0, 26, h, SF.Editor.colors.medlight )
				end
				draw.RoundedBox( 0, 0, h - 1, w, 1, SF.Editor.colors.meddark )
			end
			perm.update = function ()
				if area == 2 then perm.state = perm:GetToggle() and 2 or 3
				else perm.state = perm:GetToggle() and 2 or 1 end
				if perm.initialState then
					local hint
					if perm.state ~= perm.initialState then hint = permStates[ perm.state ].changedText or ''
					else hint = permStates[ perm.state ].stillText or '' end
					perm:SetToolTip( id .. '\n' .. description .. '\n\n' .. hint )
					ChangeTooltip( perm )
				end
			end
			function perm:OnToggled()
				parent.overrides[ id ] = perm:GetToggle() and true or nil
				perm.update()
				parent.update()
			end
			perm:SetToggle( parent.overrides[ id ] ~= nil )
			perm.update()
			perm.initialState = perm.state
			perm.update()
			if area == 1 and perm.state == 2 then
				perm:SetIsToggle( false )
				perm.DoRightClick = function ()
					local mirror = panel.index[ 2 ][ id ]
					parent.area = 2
					parent.update()
					local x, y = mirror:GetPos()
					panel:GetChild( 1 ):GetVBar():AnimateTo( y + mirror:GetTall() / 2 - panel:GetTall() / 2, 0.5 )
				end
			elseif area == 2 then
				perm.DoRightClick = function ()
					perm:Toggle()
					perm:OnToggled()
				end
			end

			local title = vgui.Create( 'DLabel', perm )
			title:Dock( TOP )
			title:SetContentAlignment( 4 )
			title:SetTextInset( 26, 0 )
			title:SetFont( 'SF_PermissionName' )
			title:SetText( name )
			title:SetBright( true )
			title.Paint = function ()
				surface.SetDrawColor( 200, 200, 255 )
				surface.SetMaterial( permStates[ perm.state ].iconMat )
				surface.DrawTexturedRect( 0, 0, 16, 16 )
			end

			local desc = vgui.Create( 'DLabel', perm )
			desc:Dock( BOTTOM )
			desc:DockMargin( 31, 0, 0, 0 )
			desc:SetContentAlignment( 1 )
			desc:SetFont( 'SF_PermissionDesc' )
			desc:SetColor( SF.Editor.colors.light )
			desc:SetText( description )

			scrollPanel:AddItem( perm )
			panel.index[ area ][ id ] = perm
			local prev = table.maxn( panel.index[ area ] ) or 0
			panel.index[ area ][ prev + 1 ] = perm
		end
	end
	return panel
end

function PANEL:OpenForChip( chip, showOverrides )
	self.chip = chip
	self.entIcon:SetModel( chip:GetModel(), chip:GetSkin() )
	local rad = chip:GetModelRadius()
	self.entIcon:SetCamPos( Vector( rad * 1.4, rad * 1.4, rad * 2 ) )
	self.entIcon:SetLookAng( Angle( 135, 45, 180 ) )
	self.entIcon:SetTooltip( 'Entity ID: ' .. chip:EntIndex() .. '\n\nOwner:\n' .. chip.owner:GetName() .. ' [ ' .. chip.owner:SteamID() .. ' ]' )
	self.entName:SetText( #chip.name > 0 and chip.name or 'Starfall Processor' )
	local desc = chip.instance.permissionRequest.description
	self.description:SetText( #desc > 0 and desc or 'Please press "Grant" a couple of times. Then press "Apply Permissions", so this way we can provide you with interesting features.' )
	self.description:SetTooltip( 'Description attached to permission request from\n' .. chip.owner:GetName() .. ' [ ' .. chip.owner:SteamID() .. ' ]' )
	self.ownerAvatar:SetPlayer( chip.owner, self.ownerPanel:GetTall() )
	self:MakePopup()
	self:ParentToHUD()
	self:Center()

	self.overrides = {}
	if chip.instance.permissionOverrides then
		self.overrides = table.Copy( chip.instance.permissionOverrides )
	end
	self.satisfied = SF.Permissions.permissionRequestSatisfied( chip.instance )
	self.area = ( showOverrides or self.satisfied ) and 2 or 1

	local permissions = CreatePermissionsPanel( self )
	permissions:SetParent( self )
	permissions:Dock( FILL )
	self.permissionsPanel = permissions

	self.update()
	self.changeOverrides = function ()
		if chip and chip.instance then
			chip.instance.permissionOverrides = self.overrides
			chip.instance:runScriptHook( 'permissionrequest' )
		end
	end
end

function PANEL:Init()
	self:ShowCloseButton( false )
	self:DockPadding( 5, 5, 5, 5 )
	self:SetSize( 640, 400 )
	self:SetTitle( 'Overriding Permissions' )
	self.lblTitle:Dock( TOP )
	self.lblTitle:DockMargin( 2, 2, 2, 2 )
	self.lblTitle:DockPadding( 0, 0, 0, 0 )
	self.lblTitle:SetFont( 'SF_PermissionsTitle' )
	self.lblTitle:SizeToContents()
	self.lblTitle:SetContentAlignment( 5 )

	local entity = vgui.Create( 'DPanel', self )
	entity:Dock( TOP )
	entity:DockMargin( 0, 5, 0, 5 )
	entity:DockPadding( 5, 5, 5, 5 )
	entity:SetTall( 128 )
	entity.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 255, 255 ) )
	end

	local icon = vgui.Create( 'DModelPanel', entity )
	icon:Dock( LEFT )
	icon:DockMargin( 0, 0, 5, 0 )
	icon:SetSize( 118, 118 )
	icon:SetFOV( 60 )
	function icon:LayoutEntity( ent ) end
	self.entIcon = icon

	local name = vgui.Create( 'DLabel', entity )
	name:Dock( TOP )
	name:SetTall( 32 )
	name:SetFont( 'DermaLarge' )
	name:SetDark( true )
	self.entName = name

	local notice = vgui.Create( 'DLabel', entity )
	notice:Dock( FILL )
	notice:SetFont( 'SF_PermissionsWarning' )
	notice:SetWrap( true )
	notice:SetDark( true )
	notice.prefixes = { 'requires additional permissions.', 'may still require some permissions.' }
	notice.update = function ()
		notice:SetText( notice.prefixes[ self.area ] .. ' They might be useful to touch advanced technologies. There is place for any influence rendered by their features.' )
	end

	local pane = vgui.Create( 'Panel', entity )
	pane:Dock( BOTTOM )
	pane:SetTall( 40 )

	local warning = vgui.Create( 'DLabel', pane )
	warning:Dock( FILL )
	warning:SetAutoStretchVertical( true )
	warning:SetContentAlignment( 4 )
	warning:SetFont( 'SF_PermissionsWarning' )
	warning:SetWrap( true )
	warning:SetDark( true )
	warning:SetTextColor( Color( 200, 50, 0 ) )
	warning:SetText( 'State of permissions listed below will override global settings. Grant overrides only if you trust the owner.' )

	local showOverrides = vgui.Create( 'StarfallButton', pane )
	showOverrides:Dock( RIGHT )
	showOverrides:DockMargin( 5, 0, 0, 0 )
	showOverrides:SetWide( 150 )
	showOverrides:SetFont( 'SF_PermissionDesc' )
	showOverrides:SetColor( SF.Editor.colors.medlight )
	showOverrides:SetHoverColor( SF.Editor.colors.light )
	showOverrides:SetTextColor( SF.Editor.colors.meddark )
	showOverrides.PerformLayout = function () end
	showOverrides:SetText( 'Entity Overrides' )
	showOverrides:SetTooltip( 'You have some overrides already granted to the entity.\nPress to show only them.' )
	showOverrides.update = function ()
		showOverrides:SetVisible( self.area == 1 and self.chip.instance.permissionOverrides and table.Count( self.chip.instance.permissionOverrides ) > 0 )
	end
	showOverrides.DoClick = function ()
		self.area = 2
		self.update()
	end

	local buttons = vgui.Create( 'Panel', self )
	buttons:Dock( BOTTOM )
	buttons:DockMargin( 0, 5, 0, 0 )
	buttons:SetSize( 0, 40 )

	local grant = vgui.Create( 'StarfallButton', buttons )
	grant:Dock( LEFT )
	grant:SetWide( self:GetWide() / 2 - 7.5 )
	grant:SetFont( 'SF_PermissionDesc' )
	grant.states = {
		{
			label = 'Grant',
			hint = 'By pressing this button you mark all overrides visible on your screen for granting.'
		},
		{
			label = 'Apply Permissions',
			hint = 'Requested overrides are marked for granting. Now you can apply them!',
			color = Color( 50, 200, 50 ),
			hoverColor = Color( 100, 255, 100 ),
			textColor = SF.Editor.colors.dark
		},
		{
			label = 'Stay',
			hint = 'Nothing will change.'
		},
		{
			label = 'Revoke Selected',
			hint = 'You have selected overrides for revocation.\nBy pressing this button you revoke them.',
			color = Color( 100, 50, 0 ),
			hoverColor = Color( 150, 100, 0 ),
			textColor = Color( 255, 255, 255 )
		}
	}
	grant.PerformLayout = function () end
	grant.update = function ()
		if self.area == 1 then
			grant.state = 2
			for id, _ in pairs( self.chip.instance.permissionRequest.overrides ) do
				if not self.overrides[ id ] then
					grant.state = 1
					break
				end
			end
		else
			grant.state = 3
			if self.chip.instance.permissionOverrides then
				for id, _ in pairs( self.chip.instance.permissionOverrides ) do
					if not self.overrides[ id ] then
						grant.state = 4
						break
					end
				end
			end
		end
		grant:SetText( grant.states[ grant.state ].label )
		grant:SetTooltip( grant.states[ grant.state ].hint )
		grant:SetColor( grant.states[ grant.state ].color or SF.Editor.colors.meddark )
		grant:SetHoverColor( grant.states[ grant.state ].hoverColor or SF.Editor.colors.med )
		grant:SetTextColor( grant.states[ grant.state ].textColor or SF.Editor.colors.light )
	end
	grant.DoClick = function ()
		if grant.state == 1 then
			local sp1 = self.permissionsPanel:GetChild( 0 )
			local VBar = sp1:GetVBar()
			for i = 1, 2 do
				for id, perm in ipairs( self.permissionsPanel.index[ 1 ] ) do
					local x, y = perm:GetPos()
					if i == 1 then
						local h = perm:GetTall()
						if VBar:GetScroll() < y + h * 0.2 and VBar:GetScroll() + sp1:GetTall() > y + 0.8 * h then
							if not perm:GetToggle() then
								perm:SetToggle( true )
								perm:OnToggled()
							end
						end
					elseif not perm:GetToggle() then
						VBar:AnimateTo( y, 0.5 )
						break
					end
				end
			end
		else
			if grant.state ~= 3 then self.changeOverrides() end
			self:Close()
		end
		ChangeTooltip()
	end

	local decline = vgui.Create( 'StarfallButton', buttons )
	decline:Dock( RIGHT )
	decline:SetWide( self:GetWide() / 2 - 7.5 )
	decline:SetFont( 'SF_PermissionDesc' )
	decline.states = {
		{
			label = 'Decline',
			hint = 'You can confidently decline.\nNothing will change.'
		},
		{
			label = 'Revoke All Overrides',
			hint = 'By pressing this button you revoke all overrides per entity.',
			color = Color( 100, 50, 0 ),
			hoverColor = Color( 150, 100, 0 ),
			textColor = Color( 255, 255, 255 )
		}
	}
	decline.PerformLayout = function () end
	decline.update = function ()
		decline.state = self.area
		decline:SetText( decline.states[ decline.state ].label )
		decline:SetTooltip( decline.states[ decline.state ].hint )
		decline:SetColor( decline.states[ decline.state ].color or SF.Editor.colors.meddark )
		decline:SetHoverColor( decline.states[ decline.state ].hoverColor or SF.Editor.colors.med )
		decline:SetTextColor( decline.states[ decline.state ].textColor or SF.Editor.colors.light )
	end
	decline.DoClick = function ()
		if decline.state == 2 then
			self.overrides = {}
			self.changeOverrides()
		end
		self:Close()
	end

	local owner = vgui.Create( 'Panel', self )
	owner:Dock( BOTTOM )
	owner:DockMargin( 0, 5, 0, 0 )
	owner:SetSize( self:GetWide(), 118 )
	owner.update = function ()
		owner:SetVisible( self.area == 1 )
	end
	self.ownerPanel = owner

	local avatar = vgui.Create( 'AvatarImage', owner )
	avatar:Dock( LEFT )
	avatar:SetWide( owner:GetTall() )
	self.ownerAvatar = avatar

	local description = vgui.Create( 'DPanel', owner )
	description:Dock( LEFT )
	description:DockMargin( 5, 0, 0, 0 )
	description:SetWide( owner:GetWide() - avatar:GetWide() - 5 )
	description:SetBackgroundColor( SF.Editor.colors.meddark )
	local descMarkup
	local descWideMax = description:GetWide()
	function description:SetText( str )
		descMarkup = markup.Parse( '<font=SF_PermissionDesc>' .. str .. '</font>', descWideMax - 10 )
		self:SetWide( math.min( descMarkup:GetWidth() + 10, descWideMax ) )
		local tall = math.min( descMarkup:GetHeight(), 108 ) + 10
		self:GetParent():SetTall( tall )
		avatar:SetWide( tall )
	end
	function description:PaintOver( w, h )
		if descMarkup then
			descMarkup:Draw( 5, 5 )
		end
	end
	self.description = description

	self:InvalidateLayout( true )

	self.update = function ()
		showOverrides.update()
		notice.update()
		owner.update()
		grant.update()
		decline.update()
		local sp1 = self.permissionsPanel:GetChild( 0 )
		local sp2 = self.permissionsPanel:GetChild( 1 )
		sp1:SetVisible( self.area == 1 )
		sp2:SetVisible( self.area == 2 )
		sp1:GetCanvas():InvalidateLayout( true )
		sp2:GetCanvas():InvalidateLayout( true )
		self:InvalidateLayout( true )
	end
end
function PANEL:PerformLayout()
	if not self.tallAnimation and self.permissionsPanel then
		-- handle tall change when it's not animated
		local tall = self:GetTall() - self.permissionsPanel:GetTall()
		if not self.reservedTall then self:SetTall( tall ) end
		self.reservedTall = tall
	end
end
function PANEL:Think()
	if not self.area then return end
	local scrollPanel = self.permissionsPanel:GetChild( self.area - 1 )
	local VBar = scrollPanel:GetVBar()
	local dest = self.reservedTall + math.Clamp( scrollPanel:GetCanvas():GetTall(), 0, ScrH() - self.reservedTall )
	if self:GetTall() ~= dest then
		self.tallAnimation = true
		VBar:SetAlpha( 0 )
		local step = Lerp( 0.6, 0, dest - self:GetTall() )
		if self:GetTall() < dest then
			self:SetTall( self:GetTall() + math.ceil( step ) )
		else
			self:SetTall( self:GetTall() + math.floor( step ) )
		end
		self:Center()
	else
		self.tallAnimation = false
		VBar:SetAlpha( VBar:GetAlpha() + math.ceil( Lerp( 0.1, 0, 255 - VBar:GetAlpha() ) ) )
	end
end
function PANEL:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, SF.Editor.colors.dark )
end
vgui.Register( "SFChipPermissions", PANEL, "DFrame" )


-- End Instance Permissions

--------------------------------------------------------------
--------------------------------------------------------------

-- Starfall Permissions (Global)

PANEL  = {}
function PANEL:AddProviders(providers, server)
	for _, p in pairs(providers) do
		local header = vgui.Create("DLabel", header)
		header:SetFont("DermaLarge")
		header:SetColor(Color(255, 255, 255))
		header:SetText((server and "[Server] " or "[Client] ")..p.name)
		header:SetSize(0, 40)
		header:Dock(TOP)
		self.scrollPanel:AddItem(header)

		for id, setting in SortedPairs(p.settings) do

			local header = vgui.Create("StarfallPanel")
			header:DockMargin(0, 5, 0, 0)
			header:SetSize(0, 20)
			header:Dock(TOP)
			header:SetToolTip(id)
			header:SetBackgroundColor(Color(0,0,0,20))

			local settingtext = vgui.Create("DLabel", header)
			settingtext:SetFont("DermaDefault")
			settingtext:SetColor(Color(255, 255, 255))
			settingtext:SetText(id)
			settingtext:DockMargin(5, 0, 0, 0)
			settingtext:Dock(LEFT)
			settingtext:SizeToContents()

			local description = vgui.Create("DLabel", header)
			description:SetFont("DermaDefault")
			description:SetColor(Color(128, 128, 128))
			description:SetText(" - "..setting[2])
			description:DockMargin(5, 0, 0, 0)
			description:Dock(FILL)

			local buttons = {}
			for i,option in pairs(p.settingsoptions) do
				local button = vgui.Create("StarfallButton", header)
				button:SetText(option)
				button:DockMargin(0, 0, 3, 0)
				button:Dock(RIGHT)
				button.active = setting[3]==i

				button.DoClick = function(self)
					RunConsoleCommand(server and "sf_permission" or "sf_permission_cl", id, p.id, i)
					for _, b in ipairs(buttons) do
						b.active = false
					end
					self.active = true
				end
				buttons[i] = button
			end

			self.scrollPanel:AddItem(header)

		end
	end
end
function PANEL:Clear()
	self.scrollPanel:Clear()
end
function PANEL:Init()

	self.scrollPanel = vgui.Create("DScrollPanel", self)
	self.scrollPanel:Dock(FILL)
	self.scrollPanel:SetPaintBackgroundEnabled(false)
end
function PANEL:Paint(w,h)

end
vgui.Register( "StarfallPermissions", PANEL, "DPanel" )

SF.Editor.Query = function(...)
	local title = select(1, ...)
	local text = select(2, ...)
	local buttons = {select(3, ...)}

	local m = markup.Parse(text)
	local w,h = m:Size()
	local frame = vgui.Create("StarfallFrame")
	frame:SetDeleteOnClose(true)
	frame.CloseButton:Remove()
	frame:SetTitle(title)

	w = math.max(w, frame.TitleWidth - 90)
	w = w + 100
	h = h + 90


	frame:SetSize(w, h)
	local _oldPaint = frame.Paint
	frame.Paint = function(self, w, h, ...)
		_oldPaint(self, w, h, ...)
		m:Draw(w/2, 40, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

	local buttonContainer = vgui.Create("DPanel", frame)
	buttonContainer:SetTall(30)
	buttonContainer:Dock(BOTTOM)
	buttonContainer:SetPaintBackground(false)
	local bcount = #buttons/2
	for I = 1, #buttons, 2 do
		local button = vgui.Create("StarfallButton",buttonContainer)
		button:SetText(buttons[I])
		button:SetAutoSize(false)
		button.DoClick = function() 
			buttons[I+1]()
			frame:Close()
		end
		if I > 1 then
			button:DockMargin(5, 0, 0, 0)
		end
		button:SetSize(w/bcount - 5*(bcount-1), 30)
		button:Dock(LEFT)
	end
	frame:SetSizable(false)
	frame:MakePopup()
	frame:Center()
	frame:Open()
	return frame
end
PANEL = {}

function PANEL:Init()
	local mixer = vgui.Create( "DColorMixer", self )
	mixer:Dock( FILL )
	mixer:SetPalette( true )
	mixer:SetAlphaBar( true )
	mixer:SetWangs( true )
	mixer:SetCookieName("starfallcolorpicker")
	mixer:SetColor( Color( 30, 30, 30 ) )
	self.mixer = mixer
	self:SetSize(400,300)
	self:Center()
	local confirm = vgui.Create("DColorButton", self)
	mixer.ValueChanged = function(_, color)
		confirm:SetColor(color)
	end
	confirm:Dock(BOTTOM)
	confirm:DockMargin(2, 10, 2, 2)
	confirm:SetTall(30)
	confirm.DoClick = function()
		if self.OnColorPicked then
			self:OnColorPicked(self:GetColor())
		end
		self:Close()
	end
	self.confirm = confirm
end
function PANEL:SetColor(...)
	return self.mixer:SetColor(...)
end
function PANEL:GetColor(...)
	return self.mixer:GetColor(...)
end
vgui.Register( "StarfallColorPicker", PANEL, "StarfallFrame" )


PANEL = {}

local fontCache = {}

function PANEL:GetFont(tab)
	local name = string.format("sf_fonteditor_%s_%d_%d_%d_%d%d%d%d%d",
		tab.font or "Arial",
		tonumber(tab.size),
		tonumber(tab.weight),
		tonumber(tab.blursize),
		tab.antialias and 1 or 0,
		tab.additive and 1 or 0,
		tab.shadow and 1 or 0,
		tab.outline and 1 or 0,
		tab.extended and 1 or 0
	)

	if not fontCache[name] then
		surface.CreateFont(name, tab)
		fontCache[name] = true
	end

	return name
end

function PANEL:DefaultFontSettings()
	return {
		font = "Arial",
		extended = false,
		size = 16,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	}
end

function PANEL:BuildFontString(tab, pretty, tips, prependLocalVariable)
	local prepend = ""
	if prependLocalVariable then
		local fontName = string.gsub(tab.font,"[^a-zA-Z]","") -- remove all special characters
		prepend = string.format("local font%s%s = ", fontName, tab.size)
	end

	if pretty then
		-- pretty-print (maybe with tips)
		return string.format(
[=[%srender.createFont(
    "%s",%s
    %s,%s
    %s,%s
    %s,%s
    %s,%s
    %s,%s
    %s,%s
    %s,%s
    %s,%s
    %s%s
)]=],
	prepend,
	tab.font, tips and " -- Font name" or "",
	tab.size, tips and " -- Size" or "",
	tab.weight, tips and " -- Weight (how bold)" or "",
	tab.antialias, tips and " -- Antialias" or "",
	tab.additive, tips and " -- Additive" or "",
	tab.shadow, tips and " -- Shadow" or "",
	tab.outline, tips and " -- Outline" or "",
	tab.blursize, tips and " -- Blur size" or "",
	tab.extended, tips and " -- Extended (Allow more UTF8 chars)" or "",
	tab.scanlines, tips and " -- Scanlines" or ""
)

	else
		-- one-liner
		return string.format("%srender.createFont(\"%s\",%s,%s,%s,%s,%s,%s,%s,%s,%s)",
			prepend,
			tab.font,
			tab.size,
			tab.weight,
			tostring(tab.antialias),
			tostring(tab.additive),
			tostring(tab.shadow),
			tostring(tab.outline),
			tab.blursize,
			tostring(tab.extended),
			tab.scanlines
		)
	end
end

function PANEL:ParseFontString(str)
	local STRING = "%s*\"([a-zA-Z%s]-)\"%s*"
	local NUMBER = "%s*(%d-)%s*"
	local BOOLEAN = "%s*([tf][ra][ul][es]e?)%s*"

	local str = string.gsub(str,"%-%-.-\n","") -- erase comments

	local name, size, weight, antialias, 
		  additive, shadow, outline, blursize, 
		  extended, scanlines = string.match(str, 
		  	string.format("render.createFont%%s*%%(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s%%)",
		  		STRING, NUMBER, NUMBER, BOOLEAN, BOOLEAN, BOOLEAN, BOOLEAN, NUMBER, BOOLEAN, NUMBER
		  	)
		  )

	if not name or not size or not weight or not antialias or not additive
		or not shadow or not outline or not blursize
		or not extended or not scanlines then
			return
	end

	local tab = self:DefaultFontSettings()
	tab.font = name or "Arial"
	tab.size = tonumber(size) or 13
	tab.weight = tonumber(weight) or 500
	tab.blursize = tonumber(blursize) or 0
	tab.scanlines = tonumber(scanlines) or 0
	tab.antialias = antialias == "true"
	tab.shadow = shadow == "true"
	tab.additive = additive == "true"
	tab.extended = extended == "true"
	tab.outline = outline == "true"
	return tab 
end

function PANEL:Init()
	self.fontSettings = self:DefaultFontSettings()
	self:SetSize(math.min(ScrW()*0.9,800),math.min(ScrH(),430))
	self:Center()

	local previewPanel = vgui.Create( "DPanel", self )
	previewPanel:Dock(TOP)
	previewPanel:SetTall(100)
	previewPanel:SetBackgroundColor(Color(30,30,30,255))
	--previewPanel.Paint = function() end
	local preview = vgui.Create("DPanel", previewPanel)
	preview:Dock(FILL)
	function preview:Paint()
		local w,h = self:GetSize()
		draw.SimpleText(
			"This is a preview of the font", 
			self.font, w/2, h/2, 
			Color(255,255,255,255), 
			TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
		)
	end
	preview.font = self:GetFont(self.fontSettings)

	------------------- copy buttons
	local btns = {
		-- {"button text", onclick}
		{"Copy One-Liner", function() 
			SetClipboardText(self:BuildFontString(self.fontSettings,false,false,true)) 
		end},
		{"Copy Formatted",function()
			SetClipboardText(self:BuildFontString(self.fontSettings,true,false,true))
		end},
		{"Copy Formatted w/ Tips",function() 
			SetClipboardText(self:BuildFontString(self.fontSettings,true,true,true)) 
		end}
	}
	local btnPanel = vgui.Create( "DPanel", self )
	btnPanel:Dock(BOTTOM)
	btnPanel.Paint = function() end
	for k, btninfo in pairs(btns) do
		local btn = vgui.Create( "DButton", btnPanel )
		btn:SetText(btninfo[1])
		btn.DoClick = btninfo[2]
		btns[k][3] = btn
	end
	local old = btnPanel.PerformLayout
	function btnPanel:PerformLayout()
		old(self)
		local w,h = self:GetSize()
		for k, btninfo in pairs(btns) do
			btninfo[3]:SetWide(w/3,h)
			btninfo[3]:SetPos((k-1)*(w/3),0)
		end
	end

	local LRPanel = vgui.Create( "DPanel", self )
	LRPanel:Dock(FILL)
	LRPanel.Paint = function() end

	------------------- text box
	local textbox = vgui.Create("DTextEntry", LRPanel)
	textbox:Dock(LEFT)
	textbox:SetWide(220)
	textbox:SetMultiline(true)

	local fName = GetConVar("sf_editor_wire_fontname"):GetString()
	local fAA = GetConVar("sf_editor_wire_enable_antialiasing"):GetBool()
	textbox:SetFont(SF.Editor.editor:GetFont(fName, 20, fAA))

	textbox:SetValue(self:BuildFontString(self.fontSettings,true))

	local function doUpdate()
		preview.font = self:GetFont(self.fontSettings)
		if self.fontSettings.shadow or self.fontSettings.outline then
			previewPanel:SetBackgroundColor(Color(240,240,240,255))
		else
			previewPanel:SetBackgroundColor(Color(30,30,30,255))
		end
	end
	local function doUpdateText()
		textbox:SetText(self:BuildFontString(self.fontSettings,true))
	end
	local function updatePreviewTextLater(len)
		timer.Destroy("sf_font_editor_timer_preview")
		timer.Destroy("sf_font_editor_timer_textbox")
		timer.Create("sf_font_editor_timer_preview", len or 0.3, 1, doUpdate)
		timer.Create("sf_font_editor_timer_textbox", 0.1, 1, doUpdateText)
	end

	------------------- error panel
	local errorPanel = vgui.Create("DPanel", LRPanel)
	errorPanel:Dock(FILL)
	errorPanel:Hide()
	errorPanel.Paint = function() end
	errorPanel:DockPadding(4,2,4,2)
	local lbl = vgui.Create("DLabel",errorPanel)
	lbl:SetText( "Unable to parse string. Please input a valid string." )
	lbl:Dock(TOP)
	local resetBtn = vgui.Create("DButton", errorPanel)
	resetBtn:SetText("Reset to default")
	resetBtn:Dock(TOP)

	------------------- controls panel
	local controlsList = vgui.Create("DListLayout", LRPanel)
	controlsList:Dock(FILL)
	controlsList.Paint = function() end
	controlsList:DockPadding(4,0,4,0)
	local infolbl = vgui.Create("DLabel")
	infolbl:SetText("You can paste a createFont line into the text box on the left to parse its settings")
	controlsList:Add(infolbl)

	resetBtn.DoClick = function()
		self.fontSettings = self:DefaultFontSettings()
		doUpdate()
		doUpdateText()
		controlsList:Show()
		errorPanel:Hide()
	end

	local controls = {
		-- {"setting name", "label", "setting type", optional callback for more settings}
		{"font","Source Font","s"},
		{"size","Size","n", function(this) this:SetDecimals(0) this:SetMinMax(4,255) end},
		{"weight","Weight","n", function(this) this:SetDecimals(0) this:SetMinMax(100,1000) end},
		{"antialias","Antialias","b"},
		{"additive","Additive","b"},
		{"shadow","Shadow","b"},
		{"outline","Outline","b"},
		{"blursize","Blursize","n", function(this) this:SetDecimals(0) this:SetMinMax(0,10) end},
		{"extended","Extended","b"},
		{"scanlines","Scanlines","n", function(this) this:SetDecimals(0) this:SetMinMax(0,10) end}
	}

	for k, controlinfo in pairs(controls) do
		local settingName = controlinfo[1]
		local label = controlinfo[2]
		local inptype = controlinfo[3]
		local callback = controlinfo[4]

		local p = vgui.Create( "DPanel" )
		p.Paint = function() end

		local inp
		if inptype == "s" then
			local tempPanel = vgui.Create( "DPanel", p)
			tempPanel:Dock(FILL)
			tempPanel.Paint = function() end
			local lbl = vgui.Create("DLabel", tempPanel)
			lbl:SetText(label .. ":")
			lbl:Dock(LEFT)
			lbl:SizeToContents()
			lbl:DockMargin(0,0,4,0)
			inp = vgui.Create("DTextEntry", tempPanel)
			inp:Dock(FILL)
			inp:SetTall(18)
			controlsList:Add(tempPanel)
		elseif inptype == "n" then
			inp = vgui.Create("DNumSlider", p)
			inp:SetText(label .. ":")
			inp:Dock(FILL)
			inp:SetTall(18)
			controlsList:Add(inp)
		elseif inptype == "b" then
			local tempPanel = vgui.Create( "DPanel", p)
			tempPanel:Dock(FILL)
			tempPanel.Paint = function() end
			inp = vgui.Create("DCheckBoxLabel", tempPanel)
			inp:SetText(label)
			inp:SetTall(18)
			controlsList:Add(tempPanel)
		end

		if callback then callback(inp) end

		inp:SetValue(self.fontSettings[settingName])
		if inp.SetDefaultValue then inp:SetDefaultValue(self.fontSettings[settingName]) end
		controlinfo[5] = inp

		inp.OnChange = function(this, newvalue)
			local len = 1
			if inptype == "n" then
				len = 0.8
				newvalue = math.Round(newvalue)
			elseif inptype == "b" then
				len = 0.5
				newvalue = tobool(newvalue)
			elseif inptype == "s" then
				newvalue = newvalue ~= nil and newvalue or this:GetValue()
			end

			self.fontSettings[settingName] = newvalue

			updatePreviewTextLater(len)
		end
		inp.OnValueChanged = inp.OnChange -- some use OnChange and others use OnValueChanged
	end

	textbox.OnChange = function(this,val)
		local tab = self:ParseFontString(val or textbox:GetValue())
		if tab then
			controlsList:Show()
			errorPanel:Hide()
			for k,v in pairs(controls) do
				self.fontSettings[v[1]] = tab[v[1]]
				v[5]:SetValue(tab[v[1]])
			end
			updatePreviewTextLater()
		else
			errorPanel:Show()
			controlsList:Hide()
		end
	end
end

vgui.Register( "StarfallFontPicker", PANEL, "StarfallFrame" )
