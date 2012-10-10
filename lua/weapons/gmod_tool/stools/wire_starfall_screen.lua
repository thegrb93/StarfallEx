TOOL.Category		= "Wire - Display"
TOOL.Name			= "Starfall - Screen"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.Tab			= "Wire"

-- ------------------------------- Sending / Recieving ------------------------------- --
include("starfall/sflib.lua")

local MakeSF
local RequestSend

TOOL.ClientConVar[ "Model" ] = "models/hunter/plates/plate2x2.mdl"
cleanup.Register( "starfall_screen" )

if SERVER then
	util.AddNetworkString("starfall_screen_requpload")
	util.AddNetworkString("starfall_screen_upload")
	
	net.Receive("starfall_screen_upload", function(len, ply)
		local ent = net.ReadEntity()
		if not ent or not ent:IsValid() then
			ErrorNoHalt("SF: Player "..ply:GetName().." tried to send code to a nonexistant entity.\n")
			return
		end
		
		if ent:GetClass() ~= "gmod_wire_starfall_screen" then
			ErrorNoHalt("SF: Player "..ply:GetName().." tried to send code to a non-starfall screen entity.\n")
			return
		end
		
		local mainfile = net.ReadString()
		local numfiles = net.ReadUInt(16)
		local task = {
			mainfile = mainfile,
			files = {},
		}
		
		for i=1,numfiles do
			local filename = net.ReadString()
			local code = net.ReadString()
			task.files[filename] = code
		end
		
		ent:CodeSent(ply,task)
	end)
	
	RequestSend = function(ply, ent)
		net.Start("starfall_screen_requpload")
		net.WriteEntity(ent)
		net.Send(ply)
	end
	
	CreateConVar('sbox_maxstarfall_screen', 3, {FCVAR_REPLICATED,FCVAR_NOTIFY,FCVAR_ARCHIVE})
	
	function MakeSF( pl, Pos, Ang, model)
		if not pl:CheckLimit( "starfall_screen" ) then return false end

		local sf = ents.Create( "gmod_wire_starfall_screen" )
		if not IsValid(sf) then return false end

		sf:SetAngles( Ang )
		sf:SetPos( Pos )
		sf:SetModel( model )
		sf:Spawn()

		sf.owner = pl

		pl:AddCount( "starfall_screen", sf )

		return sf
	end
	
	function RequestSend(ply,ent)
		umsg.Start("starfall_screen_requpload",ply)
			umsg.Entity(ent)
		umsg.End()
	end
else
	language.Add( "Tool.wire_starfall_screen.name", "Starfall - Screen (Wire)" )
	language.Add( "Tool.wire_starfall_screen.desc", "Spawns a starfall screen" )
	language.Add( "Tool.wire_starfall_screen.0", "Primary: Spawns a screen / uploads code, Secondary: Opens editor" )
	language.Add( "SBox_max_starfall_Screen", "You've hit the Starfall Screen limit!" )
	language.Add( "undone_Wire Starfall Screen", "Undone Starfall Screen" )

	net.Receive("starfall_screen_requpload", function(len, ply)
		if not SF.Editor.editor then return end
		
		local ent = net.ReadEntity()
		local code = SF.Editor.getCode()
		
		local ok, buildlist = SF.Editor.BuildIncludesTable()
		if ok then
			net.Start("starfall_screen_upload")
				net.WriteEntity(ent)
				net.WriteString(buildlist.mainfile)
				net.WriteUInt(buildlist.filecount, 16)
				for name, file in pairs(buildlist.files) do
					net.WriteString(name)
					net.WriteString(file)
				end
				
			net.SendToServer()
		else
			WireLib.AddNotify("File not found: "..buildlist,NOTIFY_ERROR,7,NOTIFYSOUND_ERROR1)
		end
	end)
end

function TOOL:LeftClick( trace )
	if not trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end

	if trace.Entity:IsValid() and trace.Entity:GetClass() == "gmod_wire_starfall_screen" then
		RequestSend(self:GetOwner(),trace.Entity)
		return true
	end
	
	self:SetStage(0)

	local model = self:GetClientInfo( "Model" )
	local ply = self:GetOwner()
	if not self:GetSWEP():CheckLimit( "starfall_screen" ) then return false end

	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90

	local sf = MakeSF( ply, trace.HitPos, Ang, model)

	local min = sf:OBBMins()
	sf:SetPos( trace.HitPos - trace.HitNormal * min.z )

	local const = WireLib.Weld(sf, trace.Entity, trace.PhysicsBone, true)

	undo.Create("Wire Starfall Screen")
		undo.AddEntity( sf )
		undo.AddEntity( const )
		undo.SetPlayer( ply )
	undo.Finish()

	ply:AddCleanup( "starfall_screen", sf )
	
	RequestSend(ply,sf)

	return true
end

function TOOL:RightClick( trace )
	if SERVER then self:GetOwner():SendLua("SF.Editor.open()") end
	return false
end

function TOOL:Reload(trace)
	return false
end

function TOOL:DrawHUD()
end

function TOOL:Think()
end

if CLIENT then
	local lastclick = CurTime()
	
	local function GotoDocs(button)
		gui.OpenURL("http://colonelthirtytwo.net/sfdoc/")
	end
	
	local function FileBrowserOnFileClick(self)
		SF.Editor.init()
		if dir == self.File.FileDir and CurTime() - lastclick < 1 then
			SF.Editor.editor:Open(dir)
		else
			dir = self.File.FileDir
			SF.Editor.editor:LoadFile(dir)
		end
		lastclick = CurTime()
	end
	
	function TOOL.BuildCPanel(panel)
		panel:AddControl("Header", { Text = "#Tool.wire_starfall_screen.name", Description = "#Tool.wire_starfall_screen.desc" })
		
		local modelpanel = WireDermaExts.ModelSelect(panel, "wire_starfall_screen_Model", list.Get("WireScreenModels"), 2)
		panel:AddControl("Label", {Text = ""})
		
		local docbutton = vgui.Create("DButton" , panel)
		panel:AddPanel(docbutton)
		docbutton:SetText("Starfall Documentation")
		docbutton.DoClick = GotoDocs
		
		local filebrowser = vgui.Create("wire_expression2_browser")
		panel:AddPanel(filebrowser)
		filebrowser:Setup("Starfall")
		filebrowser:SetSize(235,400)
		filebrowser.OnFileClick = FileBrowserOnFileClick
		
		local openeditor = vgui.Create("DButton", panel)
		panel:AddPanel(openeditor)
		openeditor:SetText("Open Editor")
		openeditor.DoClick = SF.Editor.open
	end
end
