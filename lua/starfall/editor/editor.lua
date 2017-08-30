-------------------------------------------------------------------------------
-- SF Editor
-- Originally created by Jazzelhawk
--
-- To do:
-- Find new icons
-------------------------------------------------------------------------------

SF.Editor = {}

AddCSLuaFile("syntaxmodes/starfall.lua")
AddCSLuaFile("sfframe.lua")
AddCSLuaFile("sfderma.lua")
AddCSLuaFile("docs.lua")
AddCSLuaFile("sfhelper.lua")
AddCSLuaFile("themes.lua")
AddCSLuaFile("xml.lua")

AddCSLuaFile("tabhandlers/tab_wire.lua")
AddCSLuaFile("tabhandlers/tab_ace.lua")

------------------
-- Tab Handlers
------------------

if CLIENT then

	SF.Editor.TabHandlers = { }
	SF.Editor.TabHandlers.wire = include("tabhandlers/tab_wire.lua")
	SF.Editor.TabHandlers.ace = include("tabhandlers/tab_ace.lua")

	SF.Editor.CurrentTabHandler = CreateClientConVar("sf_editor_tabeditor", "ace", true, false)

end

------------------
-- Editor
--
-- For interaction with other modules and initialization
--
------------------

if CLIENT then
	include("docs.lua")
	include("sfhelper.lua")
	include("sfderma.lua")
	include("sfframe.lua") -- Editor's frame
	include("themes.lua")

	-- Colors
	SF.Editor.colors = {}
	SF.Editor.colors.dark = Color(36, 41, 53)
	SF.Editor.colors.meddark = Color(48, 57, 92)
	SF.Editor.colors.med = Color(78, 122, 199)
	SF.Editor.colors.medlight = Color(127, 178, 240)
	SF.Editor.colors.light = Color(173, 213, 247)

	-- Icons
	SF.Editor.icons = {}
	SF.Editor.icons.arrowr = Material("radon/arrow_right.png", "noclamp smooth")
	SF.Editor.icons.arrowl = Material("radon/arrow_left.png", "noclamp smooth")

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

	CreateClientConVar("sf_modelviewer_width", 930, true, false)
	CreateClientConVar("sf_modelviewer_height", 615, true, false)
	CreateClientConVar("sf_modelviewer_posx", ScrW() / 2 - 930 / 2, true, false)
	CreateClientConVar("sf_modelviewer_posy", ScrH() / 2 - 615 / 2, true, false)

	CreateClientConVar("sf_editor_ace_wordwrap", 1, true, false)
	CreateClientConVar("sf_editor_ace_widgets", 1, true, false)
	CreateClientConVar("sf_editor_ace_linenumbers", 1, true, false)
	CreateClientConVar("sf_editor_ace_gutter", 1, true, false)
	CreateClientConVar("sf_editor_ace_invisiblecharacters", 0, true, false)
	CreateClientConVar("sf_editor_ace_indentguides", 1, true, false)
	CreateClientConVar("sf_editor_ace_activeline", 1, true, false)
	CreateClientConVar("sf_editor_ace_autocompletion", 1, true, false)
	CreateClientConVar("sf_editor_ace_liveautocompletion", 0, true, false)
	CreateClientConVar("sf_editor_ace_fixkeys", system.IsLinux() and 1 or 0, true, false) --maybe osx too? need someone to check
	CreateClientConVar("sf_editor_ace_fixconsolebug", 0, true, false)
	CreateClientConVar("sf_editor_ace_disablelinefolding", 0, true, false)
	CreateClientConVar("sf_editor_ace_keybindings", "ace", true, false)
	CreateClientConVar("sf_editor_ace_fontsize", 13, true, false)

	local function createLibraryMap ()

		local libMap, libs = {}, {}

		libMap["Environment"] = {}
		for name, val in pairs(SF.DefaultEnvironment) do
			table.insert(libMap["Environment"], name)
			table.insert(libs, name)
		end

		for lib, tbl in pairs(SF.Libraries.libraries) do
			libMap[lib] = {}
			for name, val in pairs(tbl) do
				table.insert(libMap[lib], name)
				table.insert(libs, lib.."\\."..name)
			end
		end

		for lib, tbl in pairs(SF.Types) do
			if type(tbl.__index) == "table" then
				for name, val in pairs(tbl.__index) do
					table.insert(libs, "\\:"..name)
				end
			end
		end

		return libMap, table.concat(libs, "|")
	end

	function SF.Editor.init ()

		if not file.Exists("starfall", "DATA") then
			file.CreateDir("starfall")
		end
		if SF.Editor.editor then return end

		SF.Editor.createEditor()
		if not SF.Editor.modelViewer then
			SF.Editor.modelViewer = SF.Editor.createModelViewer()
		end
		SF.Editor.initialized = true
	end

	function SF.Editor.open ()
		if not SF.Editor.initialized then
			SF.Editor.init ()
		end
		SF.Editor.editor:Open()
		RunConsoleCommand("starfall_event", "editor_open")
	end

	function SF.Editor.openFile(fl)
		if not SF.Editor.initialized then SF.Editor.init() end
		SF.Editor.editor:Open(fl, nil, false)
	end

	function SF.Editor.openWithCode(name, code)
		if not SF.Editor.initialized then SF.Editor.init() end
		SF.Editor.editor:Open(name, code, false)

	end

	function SF.Editor.pasteCode(code)
		SF.Editor.editor:PasteCode(code)
	end

	function SF.Editor.close ()
		SF.Editor.editor:Close()
	end

	function SF.Editor.getCode ()
		return SF.Editor.editor:GetCode() or ""
	end

	function SF.Editor.getOpenFile (includeMainDirectory)
		local path = SF.Editor.editor:GetChosenFile()
		if not includeMainDirectory and path then
			maindir, path = path:match("(starfall/)(.+)")
		end
		return path
	end

	function SF.Editor.createEditor ()
		local editor = vgui.Create("StarfallEditorFrame") --Should define own frame later

		if SF.Editor.editor then SF.Editor.editor:Remove() end
		SF.Editor.editor = editor

		for k, v in pairs(SF.Editor.TabHandlers) do
			if v.init then v:init() end
		end

		editor:Setup("Starfall Editor", "starfall", "Starfall")

		for k, v in pairs(SF.Editor.TabHandlers) do -- We let TabHandlers register their settings but only if they are current editor or arent editor at all
			if v.registerSettings and (not v.IsEditor or (v.IsEditor and SF.Editor.CurrentTabHandler:GetString() == k)) then v:registerSettings() end
		end

	end
	function SF.Editor.openPermissionsPopup()
		local frame = vgui.Create("StarfallFrame")
		frame:SetSize(600, 900)
		frame:Center()
		frame:SetTitle("Permissions")
		frame:open()
		local permsPanel = SF.Editor.createpermissionsPanel (frame)
		permsPanel:Dock(FILL)
		permsPanel:Refresh()
	end
	function SF.Editor.createpermissionsPanel (parent)
		local panel = vgui.Create("StarfallPanel",parent)
		panel:Dock(FILL)
		panel:DockMargin(0, 0, 0, 0)
		panel.Paint = function () end

		local scrollPanel = vgui.Create("DScrollPanel", panel)
		scrollPanel:Dock(FILL)
		scrollPanel:SetPaintBackgroundEnabled(false)

		panel.Refresh = function()
			scrollPanel:Clear()
			local clientProviders = {}
			for i, v in ipairs(SF.Permissions.providers) do
				local provider = { id = v.id, name = v.name, settings = {}, options = {} }
				local options = provider.options
				local settings = provider.settings
				for i, option in ipairs(v.settingsoptions) do
					options[i] = option
				end
				for id, setting in pairs(v.settings) do
					settings[id] = { v.settingsdesc[id][1], v.settingsdesc[id][2], setting }
				end
				clientProviders[i] = provider
			end

			local function createPermissions(providers, server)
				for _, p in ipairs(providers) do
					local header = vgui.Create("DLabel", header)
					header:SetFont("DermaLarge")
					header:SetColor(Color(255, 255, 255))
					header:SetText(p.name)
					header:SetSize(0, 40)
					header:Dock(TOP)
					scrollPanel:AddItem(header)

					for id, setting in SortedPairs(p.settings) do

						local header = vgui.Create("StarfallPanel")
						header.Paint = function() end
						header:DockMargin(0, 5, 0, 0)
						header:SetSize(0, 20)
						header:Dock(TOP)
						header:SetToolTip(id)

						local settingtext = vgui.Create("DLabel", header)
						settingtext:SetFont("DermaDefault")
						settingtext:SetColor(Color(255, 255, 255))
						settingtext:SetText(id)
						settingtext:DockMargin(5, 0, 0, 0)
						settingtext:Dock(FILL)

						local buttons = {}
						for i = #p.options, 1, -1 do
							local button = vgui.Create("StarfallButton", header)
							button:SetText(p.options[i])
							button:SetTooltip(setting[2])
							button:DockMargin(0, 0, 3, 0)
							button:Dock(RIGHT)
							button.active = setting[3]==i
							button.DoClick = function(self)
								RunConsoleCommand(server and "sf_permission" or "sf_permission_cl", p.id, id, i)
								for _, b in ipairs(buttons) do
									b.active = false
								end
								self.active = true
							end
							buttons[i] = button
						end

						scrollPanel:AddItem(header)

					end
				end
			end

			if LocalPlayer():IsSuperAdmin() then
				SF.Permissions.requestPermissions(function(serverProviders)
						createPermissions(serverProviders, true)
						createPermissions(clientProviders)
					end)
			else
				createPermissions(clientProviders)
			end
		end

		return panel
	end

	function SF.Editor.createModelViewer ()
		local frame = vgui.Create("StarfallFrame")
		frame:SetTitle("Model Viewer - Click an icon to insert model filename into editor")
		frame:SetVisible(false)
		frame:Center()

		function frame:OnOpen ()
			if not self.initialized then
				self:Initialize()
			end
		end

		function frame:Initialize()
			local sidebarPanel = vgui.Create("StarfallPanel", frame)
			sidebarPanel:Dock(LEFT)
			sidebarPanel:SetSize(190, 10)
			sidebarPanel:DockMargin(0, 0, 4, 0)
			sidebarPanel.Paint = function () end

			frame.ContentNavBar = vgui.Create("ContentSidebar", sidebarPanel)
			frame.ContentNavBar:Dock(FILL)
			frame.ContentNavBar:DockMargin(0, 0, 0, 0)
			frame.ContentNavBar.Tree:SetBackgroundColor(Color(240, 240, 240))
			frame.ContentNavBar.Tree.OnNodeSelected = function (self, node)
				if not IsValid(node.propPanel) then return end

				if IsValid(frame.PropPanel.selected) then
					frame.PropPanel.selected:SetVisible(false)
					frame.PropPanel.selected = nil
				end

				frame.PropPanel.selected = node.propPanel

				frame.PropPanel.selected:Dock(FILL)
				frame.PropPanel.selected:SetVisible(true)
				frame.PropPanel:InvalidateParent()

				frame.HorizontalDivider:SetRight(frame.PropPanel.selected)
			end

			frame.PropPanel = vgui.Create("StarfallPanel", frame)
			frame.PropPanel:Dock(FILL)
			function frame.PropPanel:Paint (w, h)
				draw.RoundedBox(0, 0, 0, w, h, Color(240, 240, 240))
			end

			frame.HorizontalDivider = vgui.Create("DHorizontalDivider", frame)
			frame.HorizontalDivider:Dock(FILL)
			frame.HorizontalDivider:SetLeftWidth(175)
			frame.HorizontalDivider:SetLeftMin(175)
			frame.HorizontalDivider:SetRightMin(450)

			frame.HorizontalDivider:SetLeft(sidebarPanel)
			frame.HorizontalDivider:SetRight(frame.PropPanel)

			local root = frame.ContentNavBar.Tree:AddNode("Your Spawnlists")
			root:SetExpanded(true)
			root.info = {}
			root.info.id = 0

			local function hasGame (name)
				for k, v in pairs(engine.GetGames()) do
					if v.folder == name and v.mounted then
						return true
					end
				end
				return false
			end

			local function addModel (container, obj)

				local icon = vgui.Create("SpawnIcon", container)

				if (obj.body) then
					obj.body = string.Trim(tostring(obj.body), "B")
				end

				if (obj.wide) then
					icon:SetWide(obj.wide)
				end

				if (obj.tall) then
					icon:SetTall(obj.tall)
				end

				icon:InvalidateLayout(true)

				icon:SetModel(obj.model, obj.skin or 0, obj.body)

				icon:SetTooltip(string.Replace(string.GetFileFromFilename(obj.model), ".mdl", ""))

				icon.DoClick = function (icon)
					SF.Editor.pasteCode("\"" .. string.gsub(obj.model, "\\", "/") .. "\"")
					SF.AddNotify(LocalPlayer(), "\"" .. string.gsub(obj.model, "\\", "/") .. "\" inserted into editor.", "GENERIC", 5, "DRIP1")
					frame:close()
				end
				icon.OpenMenu = function (icon)

					local menu = DermaMenu()
					local submenu = menu:AddSubMenu("Re-Render", function () icon:RebuildSpawnIcon() end)
					submenu:AddOption("This Icon", function () icon:RebuildSpawnIcon() end)
					submenu:AddOption("All Icons", function () container:RebuildAll() end)

					local ChangeIconSize = function (w, h)

						icon:SetSize(w, h)
						icon:InvalidateLayout(true)
						container:OnModified()
						container:Layout()
						icon:SetModel(obj.model, obj.skin or 0, obj.body)

					end

					local submenu = menu:AddSubMenu("Resize", function () end)
					submenu:AddOption("64 x 64 (default)", function () ChangeIconSize(64, 64) end)
					submenu:AddOption("64 x 128", function () ChangeIconSize(64, 128) end)
					submenu:AddOption("64 x 256", function () ChangeIconSize(64, 256) end)
					submenu:AddOption("64 x 512", function () ChangeIconSize(64, 512) end)
					submenu:AddSpacer()
					submenu:AddOption("128 x 64", function () ChangeIconSize(128, 64) end)
					submenu:AddOption("128 x 128", function () ChangeIconSize(128, 128) end)
					submenu:AddOption("128 x 256", function () ChangeIconSize(128, 256) end)
					submenu:AddOption("128 x 512", function () ChangeIconSize(128, 512) end)
					submenu:AddSpacer()
					submenu:AddOption("256 x 64", function () ChangeIconSize(256, 64) end)
					submenu:AddOption("256 x 128", function () ChangeIconSize(256, 128) end)
					submenu:AddOption("256 x 256", function () ChangeIconSize(256, 256) end)
					submenu:AddOption("256 x 512", function () ChangeIconSize(256, 512) end)
					submenu:AddSpacer()
					submenu:AddOption("512 x 64", function () ChangeIconSize(512, 64) end)
					submenu:AddOption("512 x 128", function () ChangeIconSize(512, 128) end)
					submenu:AddOption("512 x 256", function () ChangeIconSize(512, 256) end)
					submenu:AddOption("512 x 512", function () ChangeIconSize(512, 512) end)

					menu:AddSpacer()
					menu:AddOption("Delete", function () icon:Remove() end)
					menu:Open()

				end

				icon:InvalidateLayout(true)

				if (IsValid(container)) then
					container:Add(icon)
				end

				return icon

			end

			local function addBrowseContent (viewPanel, node, name, icon, path, pathid)
				local models = node:AddFolder(name, path .. "models", pathid, false)
				models:SetIcon(icon)

				models.OnNodeSelected = function (self, node)

					if viewPanel and viewPanel.currentNode and viewPanel.currentNode == node then return end

					viewPanel:Clear(true)
					viewPanel.currentNode = node

					local path = node:GetFolder()
					local searchString = path .. "/*.mdl"

					local Models = file.Find(searchString, node:GetPathID())
					for k, v in pairs(Models) do
						if not IsUselessModel(v) then
							addModel(viewPanel, { model = path .. "/" .. v })
						end
					end

					node.propPanel = viewPanel
					frame.ContentNavBar.Tree:OnNodeSelected(node)

					viewPanel.currentNode = node

				end
			end

			local function addAddonContent (panel, folder, path)
				local files, folders = file.Find(folder .. "*", path)

				for k, v in pairs(files) do
					if string.EndsWith(v, ".mdl") then
						addModel(panel, { model = folder .. v })
					end
				end

				for k, v in pairs(folders) do
					addAddonContent(panel, folder .. v .. "/", path)
				end
			end

			local function fillNavBar (propTable, parentNode)
				for k, v in SortedPairs(propTable) do
					if v.parentid == parentNode.info.id and (v.needsapp ~= "" and hasGame(v.needsapp) or v.needsapp == "") then
						local node = parentNode:AddNode(v.name, v.icon)
						node:SetExpanded(true)
						node.info = v

						node.propPanel = vgui.Create("ContentContainer", frame.PropPanel)
						node.propPanel:DockMargin(5, 0, 0, 0)
						node.propPanel:SetVisible(false)

						for i, object in SortedPairs(node.info.contents) do
							if object.type == "model" then
								addModel(node.propPanel, object)
							elseif object.type == "header" then
								if not object.text or type(object.text) ~= "string" then return end

								local label = vgui.Create("ContentHeader", node.propPanel)
								label:SetText(object.text)

								node.propPanel:Add(label)
							end
						end

						fillNavBar(propTable, node)
					end
				end
			end

			if table.Count(spawnmenu.GetPropTable()) == 0 then
				hook.Call("PopulatePropMenu", GAMEMODE)
			end

			fillNavBar(spawnmenu.GetPropTable(), root)
			frame.OldSpawnlists = frame.ContentNavBar.Tree:AddNode("#spawnmenu.category.browse", "icon16/cog.png")
			frame.OldSpawnlists:SetExpanded(true)

			-- Games
			local gamesNode = frame.OldSpawnlists:AddNode("#spawnmenu.category.games", "icon16/folder_database.png")

			local viewPanel = vgui.Create("ContentContainer", frame.PropPanel)
			viewPanel:DockMargin(5, 0, 0, 0)
			viewPanel:SetVisible(false)

			local games = engine.GetGames()
			table.insert(games, {
					title = "All",
					folder = "GAME",
					icon = "all",
					mounted = true
				})
			table.insert(games, {
					title = "Garry's Mod",
					folder = "garrysmod",
					mounted = true
				})

			for _, game in SortedPairsByMemberValue(games, "title") do

				if game.mounted then
					addBrowseContent(viewPanel, gamesNode, game.title, "games/16/" .. (game.icon or game.folder) .. ".png", "", game.folder)
				end
			end

			-- Addons
			local addonsNode = frame.OldSpawnlists:AddNode("#spawnmenu.category.addons", "icon16/folder_database.png")

			local viewPanel = vgui.Create("ContentContainer", frame.PropPanel)
			viewPanel:DockMargin(5, 0, 0, 0)
			viewPanel:SetVisible(false)

			function addonsNode:OnNodeSelected (node)
				if node == addonsNode then return end
				viewPanel:Clear(true)
				addAddonContent(viewPanel, "models/", node.addon.title)
				node.propPanel = viewPanel
				frame.ContentNavBar.Tree:OnNodeSelected(node)
			end
			for _, addon in SortedPairsByMemberValue(engine.GetAddons(), "title") do
				if addon.downloaded and addon.mounted and addon.models > 0 then
					local node = addonsNode:AddNode(addon.title .. " ("..addon.models..")", "icon16/bricks.png")
					node.addon = addon
				end
			end

			-- Search box
			local viewPanel = vgui.Create("ContentContainer", frame.PropPanel)
			viewPanel:DockMargin(5, 0, 0, 0)
			viewPanel:SetVisible(false)

			frame.searchBox = vgui.Create("DTextEntry", sidebarPanel)
			frame.searchBox:Dock(TOP)
			frame.searchBox:SetValue("Search...")
			frame.searchBox:SetTooltip("Press enter to search")
			frame.searchBox.propPanel = viewPanel

			frame.searchBox._OnGetFocus = frame.searchBox.OnGetFocus
			function frame.searchBox:OnGetFocus ()
				if self:GetValue() == "Search..." then
					self:SetValue("")
				end
				frame.searchBox:_OnGetFocus()
			end

			frame.searchBox._OnLoseFocus = frame.searchBox.OnLoseFocus
			function frame.searchBox:OnLoseFocus ()
				if self:GetValue() == "" then
					self:SetText("Search...")
				end
				frame.searchBox:_OnLoseFocus()
			end

			function frame.searchBox:updateHeader ()
				self.header:SetText(frame.searchBox.results .. " Results for \"" .. self.search .. "\"")
			end

			local searchTime = nil

			function frame.searchBox:getAllModels (time, folder, extension, path)
				if searchTime and time ~= searchTime then return end
				if self.results and self.results >= 256 then return end
				self.load = self.load + 1
				local files, folders = file.Find(folder .. "/*", path)

				for k, v in pairs(files) do
					local file = folder .. v
					if v:EndsWith(extension) and file:find(self.search:PatternSafe()) and not IsUselessModel(file) then
						addModel(self.propPanel, { model = file })
						self.results = self.results + 1
						self:updateHeader()
					end
					if self.results >= 256 then break end
				end

				for k, v in pairs(folders) do
					timer.Simple(k * 0.02, function()
							if searchTime and time ~= searchTime then return end
							if self.results >= 256 then return end
							self:getAllModels(time, folder .. v .. "/", extension, path)
						end)
				end
				timer.Simple(1, function ()
						if searchTime and time ~= searchTime then return end
						self.load = self.load - 1
					end)
			end

			function frame.searchBox:OnEnter ()
				if self:GetValue() == "" then return end

				self.propPanel:Clear()

				self.results = 0
				self.load = 1
				self.search = self:GetText()

				self.header = vgui.Create("ContentHeader", self.propPanel)
				self.loading = vgui.Create("ContentHeader", self.propPanel)
				self:updateHeader()
				self.propPanel:Add(self.header)
				self.propPanel:Add(self.loading)

				searchTime = CurTime()
				self:getAllModels(searchTime, "models/", ".mdl", "GAME")
				self.load = self.load - 1

				frame.ContentNavBar.Tree:OnNodeSelected(self)
			end
			hook.Add("Think", "sf_header_update", function ()
					if frame.searchBox.loading and frame.searchBox.propPanel:IsVisible() then
						frame.searchBox.loading:SetText("Loading" .. string.rep(".", math.floor(CurTime()) % 4))
					end
					if frame.searchBox.load and frame.searchBox.load <= 0 then
						frame.searchBox.loading:Remove()
						frame.searchBox.loading = nil
						frame.searchBox.load = nil
					end
				end)

			self.initialized = true
		end

		return frame
	end

	--- (Client) Builds a table for the compiler to use
	-- @param maincode The source code for the main chunk
	-- @param codename The name of the main chunk
	-- @return True if ok, false if a file was missing
	-- @return A table with mainfile = codename and files = a table of filenames and their contents, or the missing file path.
	function SF.Editor.BuildIncludesTable (maincode, codename)
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

		local function recursiveLoad (path, curdir)
			if loaded[path] then return end
			loaded[path] = true

			local code
			local codedir
			local codepath
			if path == codename and maincode then
				code = maincode
				codedir = curdir
				codepath = path
			else
				if string.sub(path, 1, 1)~="/" then
					codepath = SF.NormalizePath(curdir .. path)
					code = file.Read("starfall/" .. codepath, "DATA")

				end
				if not code then
					codepath = SF.NormalizePath(path)
					code = file.Read("starfall/" .. codepath, "DATA")
				end
				codedir = string.GetPathFromFilename(codepath)
			end
			if not code then
				print("Bad include: " .. path)
				return
			end

			tbl.files[codepath] = code
			SF.Preprocessor.ParseDirectives(codepath, code, ppdata)

			if ppdata.includes and ppdata.includes[codepath] then
				local inc = ppdata.includes[codepath]
				if not tbl.includes[codepath] then
					tbl.includes[codepath] = inc
					tbl.filecount = tbl.filecount + 1
				else
					assert(tbl.includes[codepath] == inc)
				end

				for i = 1, #inc do
					recursiveLoad(inc[i], codedir)
				end
			end
		end
		local ok, msg = pcall(recursiveLoad, codename, string.GetPathFromFilename(codename))

		local function findCycle (file, visited, recStack)
			if not visited[file] then
				--Mark the current file as visited and part of recursion stack
				visited[file] = true
				recStack[file] = true

				--Recurse for all the files included in this file
				for k, v in pairs(ppdata.includes[file] or {}) do
					if recStack[v] then
						return true, file
					elseif not visited[v] then
						local cyclic, cyclicFile = findCycle(v, visited, recStack)
						if cyclic then return true, cyclicFile end
					end
				end
			end

			--Remove this file from the recursion stack
			recStack[file] = false
			return false, nil
		end

		local isCyclic = false
		local cyclicFile = nil
		for k, v in pairs(ppdata.includes or {}) do
			local cyclic, file = findCycle(k, {}, {})
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
		elseif msg:sub(1, 13) == "Bad include: " then
			return false, msg
		else
			error(msg, 0)
		end
	end

	-- CLIENT ANIMATION

	local busy_players = { }
	hook.Add("EntityRemoved", "starfall_busy_animation", function (ply)
			busy_players[ply] = nil
		end)

	local emitter = ParticleEmitter(vector_origin)

	net.Receive("starfall_editor_status", function (len)
			local ply = net.ReadEntity()
			local status = net.ReadBit() ~= 0 -- net.ReadBit returns 0 or 1, despite net.WriteBit taking a boolean
			if not ply:IsValid() or ply == LocalPlayer() then return end

			busy_players[ply] = status or nil
		end)

	local rolldelta = math.rad(80)
	timer.Create("starfall_editor_status", 1 / 3, 0, function ()
			rolldelta = -rolldelta
			for ply, _ in pairs(busy_players) do
				local BoneIndx = ply:LookupBone("ValveBiped.Bip01_Head1") or ply:LookupBone("ValveBiped.HC_Head_Bone") or 0
				local BonePos, BoneAng = ply:GetBonePosition(BoneIndx)
				local particle = emitter:Add("radon/starfall2", BonePos + Vector(math.random(-10, 10), math.random(-10, 10), 60 + math.random(0, 10)))
				if particle then
					particle:SetColor(math.random(30, 50), math.random(40, 150), math.random(180, 220))
					particle:SetVelocity(Vector(0, 0, -40))

					particle:SetDieTime(1.5)
					particle:SetLifeTime(0)

					particle:SetStartSize(10)
					particle:SetEndSize(5)

					particle:SetStartAlpha(255)
					particle:SetEndAlpha(0)

					particle:SetRollDelta(rolldelta)
				end
			end
		end)
	concommand.Add("sf_editor_restart", function()
		if not SF.Editor.initialized then return end
		SF.Editor.editor:Close()
		for k, v in pairs(SF.Editor.TabHandlers) do
			if v.cleanup then v:cleanup() end
		end
		SF.Editor.initialized = false
		SF.Editor.editor:Remove()
		SF.Editor.editor = nil
		SF.Editor.open ()
		print("Editor reloaded")
	end)
	concommand.Add("sf_editor_reload", function()
		include("starfall/editor/editor.lua")
	end)
elseif SERVER then

	util.AddNetworkString("starfall_editor_status")

	local starfall_event = {}

	concommand.Add("starfall_event", function (ply, command, args)
			local handler = starfall_event[args[1] or ""]
			if not handler then return end
			return handler(ply, args)
		end)

	function starfall_event.editor_open (ply, args)
		net.Start("starfall_editor_status")
		net.WriteEntity(ply)
		net.WriteBit(true)
		net.Broadcast()
	end

	function starfall_event.editor_close (ply, args)
		net.Start("starfall_editor_status")
		net.WriteEntity(ply)
		net.WriteBit(false)
		net.Broadcast()
	end
end
