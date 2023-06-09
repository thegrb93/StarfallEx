-------------------------------------------------------------------------------
-- SF Editor Interface
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
AddCSLuaFile("themes.lua")
AddCSLuaFile("xml.lua")


-----------------
-- Tab Handlers
------------------

if CLIENT then
	SF.Editor.TabHandlers = { }
	SF.Editor.CurrentTabHandler = CreateClientConVar("sf_editor_tab_editor", "wire", true, false)
end

local l = file.Find("starfall/editor/tabhandlers/tab_*.lua", "LUA")
for _, name in pairs(l) do
	name = name:sub(5,-5)
	AddCSLuaFile("starfall/editor/tabhandlers/tab_"..name..".lua")
	if CLIENT then
		SF.Editor.TabHandlers[name] = include("starfall/editor/tabhandlers/tab_"..name..".lua")
	end
end

SF.Editor.HelperURL = CreateConVar("sf_editor_helperurl", "http://thegrb93.github.io/StarfallEx/", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "URL for website used by SF Helper, change to allow custom documentation.")

------------------
-- Editor
--
-- For interaction with other modules and initialization
--
------------------

if CLIENT then
	include("sfderma.lua")
	include("sfframe.lua") -- Editor's frame
	include("themes.lua")

	if not file.Exists("starfall", "DATA") then
		file.CreateDir("starfall")
	end

	-- Colors
	SF.Editor.colors = {}
	SF.Editor.colors.dark = Color(36, 41, 53)
	SF.Editor.colors.meddark = Color(48, 57, 92)
	SF.Editor.colors.med = Color(78, 122, 199)
	SF.Editor.colors.medlight = Color(127, 178, 240)
	SF.Editor.colors.light = Color(173, 213, 247)

	local invalid_filename_chars = {
		["*"] = "",
		["?"] = "",
		[">"] = "",
		["<"] = "",
		["|"] = "",
		["\\"] = "",
		['"'] = "",
	}

	function SF.Editor.init()
		if SF.Editor.initialized or SF.Editor.editor then return end

		if not SF.Docs and not SF.WaitingForDocs then
			SF.WaitingForDocs = true
			local docfile = file.Open("sf_docs.txt", "rb", "DATA")
			if docfile then
				SF.DocsData = docfile:Read(docfile:Size()) or ""
				docfile:Close()
			else
				SF.DocsData = ""
			end
			net.Start("starfall_docs")
			net.WriteString(util.CRC(SF.DocsData))
			net.SendToServer()
		end

		SF.Editor.createEditor()
		if not SF.Editor.modelViewer then
			SF.Editor.modelViewer = SF.Editor.createModelViewer()
		end
		SF.Editor.initialized = true
	end

	function SF.Editor.open()
		if not SF.Editor.initialized then SF.Editor.init() end
		SF.Editor.editor:Open()
		RunConsoleCommand("starfall_event", "editor_open")
	end

	function SF.Editor.openFile(fl, forceNewTab)
		if not SF.Editor.initialized then SF.Editor.init() end
		SF.Editor.editor:Open(fl, nil, forceNewTab)
	end

	function SF.Editor.openWithCode(name, code, forceNewTab, checkFileExists)
		if not SF.Editor.initialized then SF.Editor.init() end
		SF.Editor.editor:Open(name, code, forceNewTab, checkFileExists)
	end

	function SF.Editor.pasteCode(code)
		SF.Editor.editor:PasteCode(code)
	end

	function SF.Editor.close()
		SF.Editor.editor:Close()
	end

	function SF.Editor.getCode()
		return SF.Editor.editor:GetCode() or ""
	end

	function SF.Editor.getOpenFile()
		local path = SF.Editor.editor:GetChosenFile()
		if path then
			path = path:match("starfall/(.+)") or path
		end
		return path
	end

	--- Converts given text to LF and tabs to spaces.
	-- Every code which goes into the editor is normalized first.
	-- Note: remember to normalize every input file when comparing it to already open files to avoid inconsistencies.
	function SF.Editor.normalizeCode(code)
		return string.gsub(code, "[\r\t]", {["\r"]="", ["\t"]="    "})
	end

	function SF.Editor.renameFile(oldFile, newFile)
		if file.Exists(newFile, "DATA") then
			SF.AddNotify(LocalPlayer(), "Failed to rename. File already exists there.", "ERROR", 7, "ERROR1")
		elseif file.Rename(oldFile, newFile) then
			SF.AddNotify(LocalPlayer(), "File renamed as " .. newFile .. ".", "GENERIC", 7, "DRIP3")
			for i = 1, SF.Editor.editor:GetNumTabs() do
				local ed = SF.Editor.editor:GetTabContent(i)
				local path = ed.chosenfile
				if path and path == oldFile then
					ed.chosenfile = newFile
					ed:OnTextChanged()
				end
			end
		else
			SF.AddNotify(LocalPlayer(), "Failed to rename " .. oldFile .. " to " .. newFile, "ERROR", 7, "ERROR1")
		end
	end

	function SF.Editor.getOpenFiles()
		local files = {}
		for i = 1, SF.Editor.editor:GetNumTabs() do
			local tab = SF.Editor.editor:GetTabContent(i)
			local path = tab.chosenfile
			if path and tab.GetCode then
				if SF.Editor.editor:ShouldReloadBeforeUpload() then
					SF.Editor.editor:ReloadTabs(false)
				end
				files[path:match("starfall/(.+)") or path] = tab:GetCode()
			end
		end
		return files
	end

	function SF.Editor.createEditor()
		local editor = vgui.Create("StarfallEditorFrame") --Should define own frame later

		if SF.Editor.editor then SF.Editor.editor:Remove() end
		SF.Editor.editor = editor

		for k, v in pairs(SF.Editor.TabHandlers) do
			if v.Init then v:Init() end
		end

		editor:Setup("Starfall Editor (" .. GetGlobalString("SF.Version") .. ")", "starfall", "Starfall")
	end

	function SF.Editor.createGlobalPermissionsPanel(client, server)
		if server ~= false then -- default to true
			server = true
		end
		if client ~= false then -- defualt to true
			client = true
		end
		local permsPanel = vgui.Create("StarfallPermissions")

		SF.Permissions.refreshSettingsCache () -- Refresh cache first
		local clientProviders = SF.Permissions.providers

		if LocalPlayer():IsSuperAdmin() and server then
			SF.Permissions.requestPermissions(function(serverProviders)
				permsPanel:AddProviders(serverProviders, true)
				if client then
					permsPanel:AddProviders(clientProviders)
				end
			end)
		elseif client then
			permsPanel:AddProviders(clientProviders)
		end
		permsPanel:Dock(FILL)
		return permsPanel
	end
	function SF.Editor.openPermissionsPopup()
		local frame = vgui.Create("StarfallFrame")
		frame:SetSize(600, math.min(900, ScrH()))
		frame:Center()
		frame:SetTitle("Permissions")
		frame:Open()
		local permsPanel = SF.Editor.createGlobalPermissionsPanel()
		permsPanel:SetParent(frame)
		permsPanel:Dock(FILL)
	end

	--- (Client) Builds a table for the compiler to use
	-- @param mainfile Manual selection of which file should be main. Otherwise it's the open file
	-- @return True if ok, false if a file was missing
	-- @return A table with mainfile name and files
	function SF.Editor.BuildIncludesTable(mainfile, success, err)
		if not SF.Editor.initialized then SF.Editor.init() end

		local openfiles = SF.Editor.getOpenFiles()
		if not (mainfile and (openfiles[mainfile] or file.Exists("starfall/" .. mainfile, "DATA"))) then
			mainfile = SF.Editor.getOpenFile() or "main"
			if #mainfile == 0 then err("Invalid main file") return end
			openfiles[mainfile] = SF.Editor.getCode()
		end

		local tbl = {}
		tbl.mainfile = mainfile
		tbl.files = {}

		local ppdata = {}

		local function getInclude(path)
			return openfiles[path] or file.Read("starfall/" .. path, "DATA") or error("Bad include: " .. path)
		end
		local function getIncludePath(path, curdir)
			local path = SF.ChoosePath(path, curdir, function(testpath)
				return openfiles[testpath] or file.Exists("starfall/" .. testpath, "DATA")
			end) or error("Bad include: " .. path)
			return path, string.GetPathFromFilename(path)
		end

		local function recursiveLoad(codepath, codedir, code, dontParse)
			if tbl.files[codepath] then return end
			tbl.files[codepath] = code

			if dontParse then return end

			SF.Preprocessor.ParseDirectives(codepath, code, ppdata)

			local clientmain = ppdata.clientmain and ppdata.clientmain[codepath]
			if clientmain then
				clientmain = getIncludePath(clientmain, codedir)
				if clientmain then ppdata.clientmain[codepath] = clientmain end
			end

			local dontParseTbl = {}
			local dataincludes = ppdata.includesdata and ppdata.includesdata[codepath]
			if dataincludes then
				for k, v in ipairs(dataincludes) do
					local datapath = getIncludePath(v, codedir)
					if datapath then dontParseTbl[datapath] = true end
				end
			end

			local includes = ppdata.includes and ppdata.includes[codepath]
			if includes then
				for k, v in ipairs(includes) do
					local codepath, codedir = getIncludePath(v, codedir)
					local code = getInclude(codepath)
					recursiveLoad(codepath, codedir, code, dontParseTbl[codepath])
				end
			end

			if ppdata.includedirs and ppdata.includedirs[codepath] then
				local inc = ppdata.includedirs[codepath]

				for i = 1, #inc do
					local origdir = inc[i]
					local dir = origdir
					local files
					if string.sub(dir, 1, 1)~="/" then
						dir = SF.NormalizePath(codedir .. origdir)
						files = file.Find("starfall/" .. dir .. "/*", "DATA")
					end
					if not files or #files==0 then
						dir = SF.NormalizePath(origdir)
						files = file.Find("starfall/" .. dir .. "/*", "DATA")
					end
					for k, v in ipairs(files) do
						local codepath, codedir = getIncludePath(v, dir.."/")
						local code = getInclude(codepath)
						recursiveLoad(codepath, codedir, code, dontParseTbl[codepath])
					end
				end
			end
		end

		local ok, msg = pcall(function()
			local codepath, codedir = getIncludePath(mainfile, string.GetPathFromFilename(mainfile))
			local code = getInclude(codepath)
			recursiveLoad(codepath, codedir, code)
		end)

		if not ok then
			local file = string.match(msg, "(Bad include%: .*)")
			return err(file or msg)
		end

		local clientmain = ppdata.clientmain and ppdata.clientmain[tbl.mainfile]
		if clientmain and not tbl.files[clientmain] then
			return err("Clientmain not found: " .. clientmain)
		end

		local includes = ppdata.includes
		local serverorclient = ppdata.serverorclient
		if includes and serverorclient then
			for filename, files in pairs(includes) do
				for _, inc in ipairs(files) do
					if serverorclient[inc] and serverorclient[filename] and serverorclient[filename] ~= serverorclient[inc] then
						return err("Incompatible client/server realm: \""..filename.."\" trying to include \""..inc.."\"")
					end
				end
			end
		end

		SF.Editor.HandlePostProcessing(tbl, ppdata, success, err)
	end

	--- Handles post-processing (as part of BuildIncludesTable)
	function SF.Editor.HandlePostProcessing(list, ppdata, onSuccessSignal, onErrorSignal)
		if not ppdata.httpincludes then onSuccessSignal(list) return end
		local files = list.files
		local usingCache, pendingRequestCount = {}, 0 -- a temporary HTTP in-memory cache
		-- First stage: Iterate through all http --@include directives in all files and prepare our HTTP queue structure.
		for fileName, fileUsing in next, ppdata.httpincludes do
			for _, data in next, fileUsing do
				local url, name = data[1], data[2]
				if not usingCache[url] then
					usingCache[url] = name or true -- prevents duplicate requests to the same URL
					pendingRequestCount = pendingRequestCount + 1
				end
			end
		end
		-- Second stage: Once we know the total amount of requests and URLs, we fetch all URLs as HTTP resources.
		--               Then we wait for all HTTP requests to complete.
		local function CheckAndUploadIfReady()
			pendingRequestCount = pendingRequestCount - 1
			if pendingRequestCount > 0 then return end
			-- The following should run only once, at the end when there are no more pending HTTP requests:
			-- Final stage: Substitute all http --@include directives with the contents of their HTTP response.
			for fileName, fileUsing in next, ppdata.httpincludes do
				local code = files[fileName]
				for _, data in next, fileUsing do
					local url, name = data[1], data[2]
					local result = usingCache[url]
					files[name] = result
				end
			end
			onSuccessSignal(list)
		end
		for url in next, usingCache do
			HTTP {
				method = "GET";
				url = url;
				success = function(_, contents)
					usingCache[url] = contents
					CheckAndUploadIfReady()
				end;
				failed = function(reason)
					onErrorSignal(string.format("Could not fetch --@include link (due %s): %s", reason, url))
				end;
			}
		end
	end

	function SF.Editor.createModelViewer ()
		local frame = vgui.Create("StarfallFrame")
		frame:SetTitle("Model Viewer - Click an icon to insert model filename into editor")
		frame:SetVisible(false)
		frame:SetSize(800,600)
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
					frame:Close()
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

	-- CLIENT ANIMATION

	local busy_players = SF.EntityTable("starfall_busy_animation")

	local emitter = ParticleEmitter(vector_origin)

	net.Receive("starfall_editor_status", function(len)
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

	local forceCloseEditor = function()
		if not SF.Editor.initialized then return end
		SF.Editor.editor:Close()
		for k, v in pairs(SF.Editor.TabHandlers) do
			if v.Cleanup then v:Cleanup() end
		end
		SF.Editor.initialized = false
		SF.Editor.editor:Remove()
		SF.Editor.editor = nil
		timer.Remove("sf_editor_file_auto_reload")

	end

	concommand.Add("sf_editor_reload", function()
		pcall(forceCloseEditor)
		include("starfall/editor/editor.lua")
		print("Editor reloaded")
	end)

	local function initDocs(data)
		local ok, docs
		if data then
			ok, docs = xpcall(function() return SF.StringToTable(util.Decompress(data)) end, debug.traceback)
		end
		if ok then
			SF.Docs = docs
			-- reinitialize tabhandler to regenerate libmap
			SF.Editor.TabHandlers.wire:Init()
			-- clear cache to redraw text
			SF.Editor.editor:OnThemeChange(SF.Editor.Themes.CurrentTheme)
			SF.WaitingForDocs = nil
		else
			if docs then
				ErrorNoHalt("There was an error decoding the docs. Rejoin to try again.\n" .. docs .. "\n")
			else
				ErrorNoHalt("There was an error transmitting the docs. Rejoin to try again.\n")
			end
			SF.AddNotify(LocalPlayer(), "Error processing Starfall documentation!", "GENERIC", 7, "DRIP3")
		end
	end
	net.Receive("starfall_docs", function(len, ply)
		if net.ReadBool() then
			initDocs(SF.DocsData)
			SF.DocsData = nil
		else
			SF.AddNotify(LocalPlayer(), "Downloading Starfall Documentation", "GENERIC", 7, "DRIP3")
			net.ReadStream(nil, function(data)
				local docfile = file.Open("sf_docs.txt", "wb", "DATA")
				if docfile then
					docfile:Write(data)
					docfile:Close()
					SF.AddNotify(LocalPlayer(), "Documentation saved to sf_docs.txt!", "GENERIC", 7, "DRIP3")
				else
					SF.AddNotify(LocalPlayer(), "Error saving Starfall documentation!", "GENERIC", 7, "DRIP3")
				end
				initDocs(data)
			end)
		end
	end)
elseif SERVER then

	util.AddNetworkString("starfall_editor_status")
	util.AddNetworkString("starfall_docs")

	local starfall_event = {}

	concommand.Add("starfall_event", function (ply, command, args)
		local handler = starfall_event[args[1] or ""]
		if not handler then return end
		return handler(ply, args)
	end)

	function starfall_event.editor_open(ply, args)
		local t = ply.SF_NextEditorStatus
		if t and CurTime()<t then return end
		ply.SF_NextEditorStatus = CurTime()+0.1

		net.Start("starfall_editor_status")
		net.WriteEntity(ply)
		net.WriteBit(true)
		net.Broadcast()
	end

	function starfall_event.editor_close(ply, args)
		local t = ply.SF_NextEditorStatus
		if t and CurTime()<t then return end
		ply.SF_NextEditorStatus = CurTime()+0.1

		net.Start("starfall_editor_status")
		net.WriteEntity(ply)
		net.WriteBit(false)
		net.Broadcast()
	end

	net.Receive("starfall_docs", function(len, ply)
		if not ply.SF_SentDocs then
			ply.SF_SentDocs = true

			net.Start("starfall_docs")
			if SF.DocsCRC == net.ReadString() then
				net.WriteBool(true)
			else
				net.WriteBool(false)
				net.WriteStream(SF.Docs, nil, true)
			end
			net.Send(ply)
		end
	end)
end
