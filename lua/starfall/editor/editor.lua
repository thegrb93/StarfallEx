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
AddCSLuaFile("sfhelper.lua")
AddCSLuaFile("themes.lua")
AddCSLuaFile("xml.lua")


-----------------
-- Tab Handlers
------------------

if CLIENT then
	SF.Editor.TabHandlers = { }
	SF.Editor.CurrentTabHandler = CreateClientConVar("sf_editor_tabeditor", "ace", true, false)
end

MsgN("- Loading Editor TabHandlers")
l = file.Find("starfall/editor/tabhandlers/tab_*.lua", "LUA")
for _, name in pairs(l) do
	name = name:sub(5,-5)
	print("-  Loading "..name)
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

	local invalid_filename_chars = {
		["*"] = "",
		["?"] = "",
		[">"] = "",
		["<"] = "",
		["|"] = "",
		["\\"] = "",
		['"'] = "",
	}


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
			if v.Init then v:Init() end
		end

		editor:Setup("Starfall Editor", "starfall", "Starfall")
	end

	function SF.Editor.createGlobalPermissionsPanel(client, server)
		if server != false then -- default to true
			server = true
		end
		if client != false then -- defualt to true
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
			if v.Cleanup then v:Cleanup() end
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
