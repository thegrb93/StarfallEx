-- Starfall Derma

-- Starfall Frame
PANEL = {}

PANEL.windows = {}

SF.Editor.ShowExamplesVar = CreateClientConVar("sf_editor_showexamples", "1", true, false)
SF.Editor.ShowDataFilesVar = CreateClientConVar("sf_editor_showdatafiles", "0", true, false)


--[[ Loading SF Examples ]]

if SF.Editor.ShowExamplesVar:GetBool() then

	local examples_url = "https://api.github.com/repos/thegrb93/StarfallEx/contents/lua/starfall/examples"
	http.Fetch( examples_url,
		function( body, len, headers, code )
				if code == 200 then -- OK code
					local data = util.JSONToTable( body )
					SF.Docs["Examples"] = {}
					for k,v in pairs(data) do
						SF.Docs["Examples"][v.name] = v.download_url
					end
				end
		end,
		function( error )
			SF.Docs["Examples"] = {}
			print("[SF] Examples failed to load:"..tostring(error))
		end
	)
end
--[[ End of SF Examples ]]

--[[ Fonts ]]

surface.CreateFont( "SF_PermissionsWarning", {
	font = "roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 16,
} )

surface.CreateFont( "SF_PermissionName", {
	font = "roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 20,
} )

surface.CreateFont( "SF_PermissionDesc", {
	font = "roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 18,
} )

surface.CreateFont( "SF_PermissionsTitle", {
	font = "roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 20,
} )

surface.CreateFont("SFTitle", {
		font = "Roboto",
		size = 18,
		weight = 500,
		antialias = true,
		additive = false,
	})

--[[ StarfallFrame ]]

function PANEL:Init ()
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
	self.TitleBar.OnMousePressed = function(...) self:OnMousePressed(...) end

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

function PANEL:Open ()
	self:SetVisible(true)
	self:SetKeyBoardInputEnabled(true)
	self:MakePopup()
	self:InvalidateLayout(true)

	self:OnOpen()
end
function PANEL:new_Close ()
	self:OnClose()
	self:SetKeyBoardInputEnabled(false)
	self:_Close()
end

function PANEL:OnOpen ()
end
function PANEL:OnClose ()
end

vgui.Register("StarfallFrame", PANEL, "DFrame")
-- End Starfall Frame

--------------------------------------------------------------
--------------------------------------------------------------

-- Starfall Button
PANEL = {}

function PANEL:Init ()
self:SetText("")
self:SetSize(22, 22)
end
function PANEL:SetIcon (icon)
self.icon = SF.Editor.icons[icon]
end
function PANEL:PerformLayout ()
if self:GetText() ~= "" then
self:SizeToContentsX()
self:SetWide(self:GetWide() + 14)
end
end
PANEL.Paint = function (button, w, h)
if button.Hovered or button.active then
draw.RoundedBox(0, 0, 0, w, h, button.backgroundHoverCol or SF.Editor.colors.med)
else
draw.RoundedBox(0, 0, 0, w, h, button.backgroundCol or SF.Editor.colors.meddark)
end
if button.icon then
surface.SetDrawColor(SF.Editor.colors.medlight)
surface.SetMaterial(button.icon)
surface.DrawTexturedRect(2, 2, w - 4, h - 4)
end
end
function PANEL:UpdateColours (skin)
return self:SetTextStyleColor(self.labelCol or SF.Editor.colors.light)
end
function PANEL:SetHoverColor (col)
self.backgroundHoverCol = col
end
function PANEL:SetColor (col)
self.backgroundCol = col
end
function PANEL:SetLabelColor (col)
self.labelCol = col
end
function PANEL:DoClick ()

end

vgui.Register("StarfallButton", PANEL, "DButton")
-- End Starfall Button

--------------------------------------------------------------
--------------------------------------------------------------

-- Starfall Panel
PANEL = {}
PANEL.Paint = function (panel, w, h)
draw.RoundedBox(0, 0, 0, w, h, SF.Editor.colors.light)
end
vgui.Register("StarfallPanel", PANEL, "DPanel")
-- End Starfall Panel

--------------------------------------------------------------
--------------------------------------------------------------

-- Tab Holder
PANEL = {}

function PANEL:Init ()
self:SetTall(22)
self.offsetTabs = 0
self.tabs = {}

local parent = self

self.offsetRight = vgui.Create("StarfallButton", self)
self.offsetRight:SetVisible(false)
self.offsetRight:SetSize(22, 22)
self.offsetRight:SetIcon("arrowr")
function self.offsetRight:PerformLayout ()
local wide = 0
if parent.offsetLeft:IsVisible() then
	wide = parent.offsetLeft:GetWide() + 2
end
for i = parent.offsetTabs + 1, #parent.tabs do
	if wide + parent.tabs[i]:GetWide() > parent:GetWide() - self:GetWide() - 2 then
		break
	else
		wide = wide + parent.tabs[i]:GetWide() + 2
	end
end
self:SetPos(wide, 0)
end
function self.offsetRight:DoClick ()
parent.offsetTabs = parent.offsetTabs + 1
if parent.offsetTabs > #parent.tabs - 1 then
	parent.offsetTabs = #parent.tabs - 1
end
parent:InvalidateLayout()
end

self.offsetLeft = vgui.Create("StarfallButton", self)
self.offsetLeft:SetVisible(false)
self.offsetLeft:SetSize(22, 22)
self.offsetLeft:SetIcon("arrowl")
function self.offsetLeft:DoClick ()
parent.offsetTabs = parent.offsetTabs - 1
if parent.offsetTabs < 0 then
	parent.offsetTabs = 0
end
parent:InvalidateLayout()
end

self.menuoptions = {}

self.menuoptions[#self.menuoptions + 1] = { "Close", function ()
	if not self.targetTab then return end
	self:removeTab(self.targetTab)
	self.targetTab = nil
	end }
self.menuoptions[#self.menuoptions + 1] = { "Close Other Tabs", function ()
		if not self.targetTab then return end
		local n = 1
		while #self.tabs ~= 1 do
			v = self.tabs[n]
			if v ~= self.targetTab then
				self:removeTab(v)
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
	self:SetWide(parent:GetWide() - 10)
	self.offsetRight:PerformLayout()
	self.offsetLeft:PerformLayout()

	local offset = 0
	if self.offsetLeft:IsVisible() then
		offset = self.offsetLeft:GetWide() + 2
	end
	for i = 1, self.offsetTabs do
		offset = offset - self.tabs[i]:GetWide() - 2
	end
	local bool = false
	for k, v in pairs(self.tabs) do
		v:SetPos(offset, 0)
		if offset < 0 then
			v:SetVisible(false)
		elseif offset + v:GetWide() > self:GetWide() - self.offsetRight:GetWide() - 2 then
			v:SetVisible(false)
			bool = true
		else
			v:SetVisible(true)
		end
		offset = offset + v:GetWide() + 2
	end

	if bool then
		self.offsetRight:SetVisible(true)
	else
		self.offsetRight:SetVisible(false)
	end
	if self.offsetTabs > 0 then
		self.offsetLeft:SetVisible(true)
	else
		self.offsetLeft:SetVisible(false)
	end
end
function PANEL:addTab (text)
	local panel = self
	local tab = vgui.Create("StarfallButton", self)
	tab:SetText(text)
	tab.isTab = true

	function tab:DoClick ()
		panel:selectTab(self)
	end

	function tab:DoRightClick ()
		panel.targetTab = self
		local menu = vgui.Create("DMenu", panel:GetParent())
		for k, v in pairs(panel.menuoptions) do
			local option, func = v[1], v[2]
			if func == "SPACER" then
				menu:AddSpacer()
			else
				menu:AddOption(option, func)
			end
		end
		menu:Open()
	end

	function tab:DoMiddleClick ()
		panel:removeTab(self)
	end

	self.tabs[#self.tabs + 1] = tab

	return tab
end
function PANEL:removeTab (tab)
	local tabIndex
	if type(tab) == "number" then
		tabIndex = tab
		tab = self.tabs[tab]
	else
		tabIndex = self:getTabIndex(tab)
	end

	table.remove(self.tabs, tabIndex)
	tab:Remove()

	self:OnRemoveTab(tabIndex)
end
function PANEL:getActiveTab ()
	for k, v in pairs(self.tabs) do
		if v.active then return v end
	end
end
function PANEL:getTabIndex (tab)
	return table.KeyFromValue(self.tabs, tab)
end
function PANEL:selectTab (tab)
	if type(tab) == "number" then
		tab = self.tabs[tab]
	end
	if tab == nil then return end

	if self:getActiveTab() == tab then return end

	for k, v in pairs(self.tabs) do
		v.active = false
	end
	tab.active = true

	if self:getTabIndex(tab) <= self.offsetTabs then
		self.offsetTabs = self:getTabIndex(tab) - 1
	elseif not tab:IsVisible() then
		while not tab:IsVisible() do
			self.offsetTabs = self.offsetTabs + 1
			self:PerformLayout()
		end
	end
end
function PANEL:OnRemoveTab (tabIndex)

end
vgui.Register("StarfallTabHolder", PANEL, "DPanel")
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
function PANEL:setup (folder)
	self.folder = folder
	self.Root = self.RootNode:AddFolder(folder, folder, "DATA", true)
	--[[Waiting for examples, 10 tries each 1 second]]
	if SF.Editor.ShowDataFilesVar:GetBool() then
		self.DataFiles = self.RootNode:AddNode("Data Files","icon16/folder_database.png")
		self.DataFiles:MakeFolder("sf_filedata","DATA",true)
	end
	if SF.Editor.ShowExamplesVar:GetBool() then
		timer.Create("sf_filetree_waitforexamples",1, 10, function()

			if SF.Docs["Examples"] then
				self.Examples = self.RootNode:AddNode("Examples","icon16/help.png")
				for k,v in pairs(SF.Docs["Examples"]) do
					local node = self.Examples:AddNode(k,"icon16/page_white.png")
					node.FileURL = v
				end
				timer.Remove("sf_filetree_waitforexamples")
			end

		end)
	end
	self.Root:SetExpanded(true)
end
function PANEL:reloadTree ()
	self.Root:Remove()
	if self.Examples then
		self.Examples:Remove()
	end
	if self.DataFiles then
		self.DataFiles:Remove()
	end
	self:setup(self.folder)
end
function PANEL:DoRightClick (node)
	self:openMenu(node)
end
function PANEL:openMenu (node)
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
						local saveFile = string.GetPathFromFilename(oldFile) .. "/" .. text ..".txt"
						local contents = file.Read(oldFile)
						file.Delete(node:GetFileName())
						file.Write(saveFile, contents)
						SF.AddNotify(LocalPlayer(), "File renamed as " .. saveFile .. ".", "GENERIC", 7, "DRIP3")
						self:reloadTree()
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
						self:reloadTree()
					end,
					"Cancel")
			end)
	elseif menu == "folder" then
		self.menu:AddOption("New file", function ()
				Derma_StringRequestNoBlur("New file",
					"",
					"",
					function (text)
						if text == "" then return end
						text = string.gsub(text, ".", invalid_filename_chars)
						local saveFile = node:GetFolder().."/"..text..".txt"
						file.Write(saveFile, "")
						SF.AddNotify(LocalPlayer(), "New file: " .. saveFile, "GENERIC", 7, "DRIP3")
						self:reloadTree()
					end)
			end)
		self.menu:AddSpacer()
		self.menu:AddOption("New folder", function ()
				Derma_StringRequestNoBlur("New folder",
					"",
					"",
					function (text)
						if text == "" then return end
						text = string.gsub(text, ".", invalid_filename_chars)
						local saveFile = node:GetFolder().."/"..text
						file.CreateDir(saveFile)
						SF.AddNotify(LocalPlayer(), "New folder: " .. saveFile, "GENERIC", 7, "DRIP3")
						self:reloadTree()
					end)
			end)
		self.menu:AddSpacer()
		self.menu:AddOption("Delete", function ()
				Derma_Query("Are you sure you want to delete this folder?",
					"Delete folder",
					"Delete",
					function ()
						-- Recursive delete
						local folders = {}
						folders[#folders + 1] = node:GetFolder()
						while #folders > 0 do
							local folder = folders[#folders]
							local files, directories = file.Find(folder.."/*", "DATA")
							for I = 1, #files do
								file.Delete(folder .. "/" .. files[I])
							end
							if #directories == 0 then
								file.Delete(folder)
								folders[#folders] = nil
							else
								for I = 1, #directories do
									folders[#folders + 1] = folder .. "/" .. directories[I]
								end
							end
						end
						SF.AddNotify(LocalPlayer(), "Folder deleted: " .. node:GetFolder(), "GENERIC", 7, "DRIP3")
						self:reloadTree()
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

function PANEL:Init ()

	self:Dock(FILL)
	self:DockMargin(0, 5, 0, 0)
	self.Paint = function () end

	local tree = vgui.Create("StarfallFileTree", self)
	tree:Dock(FILL)

	self.tree = tree

	local searchBox = vgui.Create("DTextEntry", self)
	searchBox:Dock(TOP)
	searchBox:SetValue("Search...")

	searchBox._OnGetFocus = searchBox.OnGetFocus
	function searchBox:OnGetFocus ()
		if self:GetValue() == "Search..." then
			self:SetValue("")
		end
		searchBox:_OnGetFocus()
	end

	searchBox._OnLoseFocus = searchBox.OnLoseFocus
	function searchBox:OnLoseFocus ()
		if self:GetValue() == "" then
			self:SetText("Search...")
		end
		searchBox:_OnLoseFocus()
	end

	function searchBox:OnChange ()

		if self:GetValue() == "" then
			tree:reloadTree()
			return
		end

		tree.Root.ChildNodes:Clear()
		local function containsFile (dir, search)
			local files, folders = file.Find(dir .. "/*", "DATA")
			for k, file in pairs(files) do
				if string.find(string.lower(file), string.lower(search)) then return true end
			end
			for k, folder in pairs(folders) do
				if containsFile(dir .. "/" .. folder, search) then return true end
			end
			return false
		end
		local function addFiles (search, dir, node)
			local allFiles, allFolders = file.Find(dir .. "/*", "DATA")
			for k, v in pairs(allFolders) do
				if containsFile(dir .. "/" .. v, search) then
					local newNode = node:AddNode(v)
					newNode:SetExpanded(true)
					addFiles(search, dir .. "/" .. v, newNode)
				end
			end
			for k, v in pairs(allFiles) do
				if string.find(string.lower(v), string.lower(search)) then
					local fnode = node:AddNode(v, "icon16/page_white.png")
					fnode:SetFileName(dir.."/"..v)
				end
			end
		end
		addFiles(self:GetValue():PatternSafe(), "starfall", tree.Root)
		if tree.DataFiles then
			addFiles(self:GetValue():PatternSafe(), "sf_filedata", tree.DataFiles)
		end
		tree.Root:SetExpanded(true)
	end
	self.searchBox = searchBox

	self.Update = vgui.Create("DButton", self)
	self.Update:SetTall(20)
	self.Update:Dock(BOTTOM)
	self.Update:DockMargin(0, 0, 0, 0)
	self.Update:SetText("Update")
	self.Update.DoClick = function(button)
		tree:reloadTree()
		searchBox:SetValue("Search...")
	end
end
function PANEL:getComponents ()
	return self.searchBox, self.tree
end

derma.DefineControl("StarfallFileBrowser", "", PANEL, "DPanel")
-- End File Browser

--[[ Permissions ]]

PANEL = {}

local function createpermissionsPanel (parent)
	local chip = parent.chip
	local panel = vgui.Create( "DPanel",parent )
	panel:Dock( FILL )
	panel:DockMargin( 0, 0, 0, 0 )
	panel.Paint = function () end



	local scrollPanel = vgui.Create( "DScrollPanel", panel )
	scrollPanel:Dock( FILL )
	scrollPanel:SetPaintBackgroundEnabled( false )
	scrollPanel:Clear()

	for id,_ in pairs(chip.instance.permissionRequest.overrides) do
		local permission = SF.Permissions.privileges[id]


		local description = permission[2]
		local name = permission[1]

		local header = vgui.Create( "StarfallPanel" )
		header.Paint = function(s,w,h)
			draw.RoundedBox( 0, 0, h-1, w, 1, SF.Editor.colors.meddark )
		end
		header:DockMargin( 0, 5, 0, 0 )
		header:SetSize( 0, 50 )
		header:Dock( TOP )
		header:SetToolTip( id )

		local title = vgui.Create( "Panel",header )
		title:SetSize(16,16)
		title:Dock(TOP)

		local settingtext = vgui.Create( "DLabel", title )
		settingtext:SetFont( "SF_PermissionName" )
		settingtext:SetColor( Color(255, 255, 255) )
		settingtext:SetText( string.format("%s - %s",name,description) )
		settingtext:SetContentAlignment(4)
		settingtext:DockMargin( 5, 0, 0, 0 )
		settingtext:Dock( FILL )
		settingtext:SizeToContents()
		settingtext:SetIsToggle(true)

		local check = vgui.Create("DCheckBox",title)
		check:SetSize(16,16)
		check.Paint = function() end
		check:Dock(LEFT)
		check:SetValue(parent.acceptedPermissions[id] == true)

		local checkImg = vgui.Create("DImage",check)
		checkImg:Dock(FILL)
		checkImg:SetImage("icon16/cross.png")
		checkImg:SetImage(parent.acceptedPermissions[id] == true and "icon16/tick.png"or "icon16/cross.png")
		function check:OnChange(val)
			checkImg:SetImage(val and "icon16/tick.png"or "icon16/cross.png")
			parent.acceptedPermissions[id] = val and true or nil
		end

		local desc = vgui.Create( "DLabel", header )
		desc:SetFont( "SF_PermissionDesc" )
		desc:SetColor( Color(255, 255, 255) )
		desc:SetText( description )
		desc:DockMargin( 30, 0, 0, 0 )
		desc:SetContentAlignment(4)
		desc:Dock( FILL )
		scrollPanel:AddItem( header )
	end
	return panel
end

function PANEL:OpenForChip(chip)
	self.chip = chip
	self.description:SetText(chip.instance.permissionRequest.description)
	self.avatar:SetPlayer(chip.owner,128)
	self:MakePopup()
	self:Center()
	self.acceptedPermissions = {}
	if chip.instance.permissionOverrides then -- It had permissions set before
		for k,v in pairs(chip.instance.permissionOverrides) do
			self.acceptedPermissions[k] = v
		end
	end

	local permissions = createpermissionsPanel(self)
	permissions:SetParent(self)
	permissions:Dock(FILL)
	permissions:Refresh()
	permissions:DockMargin( 5, 0, 0, 0 )

end

function PANEL:Init ()
	self:ShowCloseButton(false)
	self:SetSize(600,ScrH())
	self:SetTitle("Permission Override")
	self:DockPadding(5,5,5,5)
	self.lblTitle:SetFont("SF_PermissionsTitle")
	self.lblTitle:Dock(TOP)
	self.lblTitle:DockMargin(2,2,2,2)
	self.lblTitle:DockPadding(0,0,0,0)
	self.lblTitle:SizeToContents()
	self.lblTitle:SetContentAlignment(5)

	local plyPanel = vgui.Create("DPanel",self)
	plyPanel.Paint = function(s,w,h)
		draw.RoundedBox( 0, 0, 0, w, h, Color(255,255,255) )
	end
	plyPanel:SetSize(0,128)
	plyPanel:Dock(TOP)
	plyPanel:DockMargin(0,0,0,10)

	local avatar = vgui.Create("AvatarImage",plyPanel)
	avatar:SetSize(128,128)
	avatar:Dock(LEFT)
	avatar:SetPlayer(LocalPlayer(),128)
	self.avatar = avatar

	local nick = vgui.Create( "DLabel", plyPanel )
	nick:Dock(TOP)
	nick:DockMargin(2,5,2,5)
	nick:SetDark(true)
	nick:SetContentAlignment( 5 )
	nick:SetFont("DermaLarge")
	nick:SetText( LocalPlayer():GetName() )
	self.nick = nick

	local text = vgui.Create( "DLabel", plyPanel )
	text:Dock(TOP)
	text:DockMargin(2,5,2,5)
	text:SetDark(true)
	text:SetAutoStretchVertical(true)
	text:SetFont("SF_PermissionsWarning")
	text:SetWrap(true)
	text:SetContentAlignment( 5 )

	text:SetText( "Requests additional permissions for single chip.\n If you grant them chip will ignore your global settings while checking permissions listed below." )

	local warning = vgui.Create( "DLabel", plyPanel )
	warning:Dock(FILL)
	warning:DockMargin(2,5,2,5)
	warning:SetDark(true)
	warning:SetContentAlignment( 5 )
	warning:SetFont("SF_PermissionsWarning")
	warning:SetTextColor(Color(255,130,10))
	warning:SetAutoStretchVertical(true)
	warning:SetWrap(true)
	warning:SetText( "Allowing additional permission for strangers may be dangerous!" )

	local buttons = vgui.Create("Panel",self)
	buttons:SetSize(0,40)
	buttons:Dock(BOTTOM)

	local accept = vgui.Create("StarfallButton",buttons)
	accept.PerformLayout = function() end
	accept:SetText("Grant Permissions")
	accept:SetFont("SF_PermissionDesc")
	accept:SetSize(self:GetWide()/2-7,40)
	accept:Dock(LEFT)
	accept.DoClick = function()
		self.chip.instance.permissionOverrides = self.acceptedPermissions
		self.chip.instance:runScriptHook("permissionrequest")
		self:Close()
	end

	local cancel = vgui.Create("StarfallButton",buttons)
	cancel.PerformLayout = function() end
	cancel:SetText("Cancel")
	cancel:SetSize(self:GetWide()/2-7,40)
	cancel:SetFont("SF_PermissionDesc")
	cancel:Dock(RIGHT)
	cancel.DoClick = function()
		self:Close()
	end

	local description = vgui.Create( "DPanel", self )
	function description:SetText(text)
		self.text = markup.Parse( "<font=SF_PermissionDesc>"..text.."</font>", self:GetWide() -10 )
	end
	function description:PaintOver(w,h)
		if self.text then
			self.text:Draw(5,5)
		end
	end
	description:SetSize(0,128)
	description:SetBackgroundColor(SF.Editor.colors.meddark)
	description:Dock(BOTTOM)
	description:DockMargin(0,0,0,10)
	self:InvalidateLayout( true )
	description:SetText("_SetText_")
	self.description = description
end
function PANEL:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, SF.Editor.colors.dark )
end
vgui.Register( "SFChipPermissions", PANEL, "DFrame" )
