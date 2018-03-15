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
AddCSLuaFile("tabhandlers/tab_helper.lua")

------------------
-- Tab Handlers
------------------

if CLIENT then

	SF.Editor.TabHandlers = { }
	SF.Editor.TabHandlers.wire = include("tabhandlers/tab_wire.lua")
	SF.Editor.TabHandlers.ace = include("tabhandlers/tab_ace.lua")
	SF.Editor.TabHandlers.helper = include("tabhandlers/tab_helper.lua")

	SF.Editor.CurrentTabHandler = CreateClientConVar("sf_editor_tabeditor", "ace", true, false)

end

SF.Editor.HelperURL = CreateConVar("sf_editor_helperurl", "http://thegrb93.github.io/StarfallEx/", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "URL for website used by SF Helper, change to allow custom documentation.")

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
		SF.Editor.initialized = true

		SF.Libraries.CallHook("editorinit")
	end

	function SF.Editor.open ()
		if not SF.Editor.initialized then
			SF.Editor.init ()
		end
		SF.Editor.editor:Open()
		RunConsoleCommand("starfall_event", "editor_open")
	end

	function SF.Editor.openFile(fl,forceNewTab)
		if not SF.Editor.initialized then SF.Editor.init() end
		SF.Editor.editor:Open(fl, nil, forceNewTab)
	end

	function SF.Editor.openWithCode(name, code,forceNewTab)
		if not SF.Editor.initialized then SF.Editor.init() end
		SF.Editor.editor:Open(name, code, forceNewTab)

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
		frame:SetSize(600, math.min(900, ScrH()))
		frame:Center()
		frame:SetTitle("Permissions")
		frame:Open()
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
			for i, v in pairs(SF.Permissions.providers) do
				local provider = { id = v.id, name = v.name, settings = {}, options = {} }
				local options = provider.options
				local settings = provider.settings
				for i, option in ipairs(v.settingsoptions) do
					options[i] = option
				end
				for id, privilege in pairs(SF.Permissions.privileges) do
					if privilege[3][i] then
						settings[id] = { privilege[1], privilege[2], privilege[3].setting }
					end
				end
				if next(settings) then
					clientProviders[#clientProviders+1] = provider
				end
			end

			local function createPermissions(providers, server)
				for _, p in ipairs(providers) do
					local header = vgui.Create("DLabel", header)
					header:SetFont("DermaLarge")
					header:SetColor(Color(255, 255, 255))
					header:SetText((server and "[Server] " or "[Client] ")..p.name)
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
							if server then
								button.active = setting[3]==i
							else
								button.active = SF.Permissions.privileges[id][3][p.id].setting == i
							end
							button.DoClick = function(self)
								RunConsoleCommand(server and "sf_permission" or "sf_permission_cl", id, p.id, i)
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
