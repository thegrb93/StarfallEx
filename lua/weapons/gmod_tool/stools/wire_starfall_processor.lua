TOOL.Category		= "Wire - Control"
TOOL.Name			= "Starfall - Processor"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.Tab			= "Wire"

-- ------------------------------- Sending / Recieving ------------------------------- --
include("libtransfer/libtransfer.lua")
include("starfall/sflib.lua")

local MakeSF
local RequestSend

if SERVER then
	local function callback(ply, task)
		local ent = ents.GetByIndex(task.entid)
		if not ent or not ent:IsValid() then
			ErrorNoHalt("SF: Player "..ply:GetName().." tried to send code to a nonexistant entity.\n")
			return
		end
		
		if ent:GetClass() ~= "gmod_wire_starfall_processor" then
			ErrorNoHalt("SF: Player "..ply:GetName().." tried to send code to a non-starfall processor entity.\n")
			return
		end
		
		ent:CodeSent(ply,task)
	end
	LibTransfer.callbacks["starfall_upload"] = callback
	
	CreateConVar('sbox_maxstarfall_processor', 10, {FCVAR_REPLICATED,FCVAR_NOTIFY,FCVAR_ARCHIVE})
	
	function MakeSF( pl, Pos, Ang, model)
		if not pl:CheckLimit( "starfall_processor" ) then return false end

		local sf = ents.Create( "gmod_wire_starfall_processor" )
		if not IsValid(sf) then return false end

		sf:SetAngles( Ang )
		sf:SetPos( Pos )
		sf:SetModel( model )
		sf:Spawn()

		sf.owner = pl

		pl:AddCount( "starfall_processor", sf )

		return sf
	end
	
	function RequestSend(ply,ent)
		umsg.Start("starfall_requpload",ply)
			umsg.Entity(ent)
		umsg.End()
	end
else
	language.Add( "Tool_wire_starfall_processor_name", "Starfall - Processor (Wire)" )
    language.Add( "Tool_wire_starfall_processor_desc", "Spawns a starfall processor" )
    language.Add( "Tool_wire_starfall_processor_0", "Primary: Spawns a processor / uploads code, Secondary: Opens editor" )
	language.Add( "sboxlimit_wire_starfall_processor", "You've hit the Starfall processor limit!" )
	language.Add( "undone_Wire Starfall Processor", "Undone Starfall Processor" )
	
	local function sendreq(msg)
		local ent = msg:ReadEntity()
		if not SF.Editor.editor then return end
		
		local code = SF.Editor.getCode()
		--if code:match("^%s*.*%s*$") == "" then return end
		
		local ok, buildlist = SF.Editor.BuildIncludesTable()
		if ok then
			buildlist.entid = ent:EntIndex()
			LibTransfer.QueueTask("starfall_upload",buildlist)
			uploading = true;
		else
			WireLib.AddNotify("File not found: "..buildlist,NOTIFY_ERROR,7,NOTIFYSOUND_ERROR1)
		end
	end
	usermessage.Hook("starfall_requpload",sendreq)
end

TOOL.ClientConVar[ "Model" ] = "models/jaanus/wiretool/wiretool_siren.mdl"

cleanup.Register( "starfall_processor" )


function TOOL:LeftClick( trace )
	if not trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end

	if trace.Entity:IsValid() and trace.Entity:GetClass() == "gmod_wire_starfall_processor" then
		RequestSend(self:GetOwner(),trace.Entity)
		return true
	end
	
	self:SetStage(0)

	local model = self:GetClientInfo( "Model" )
	local ply = self:GetOwner()
	if not self:GetSWEP():CheckLimit( "starfall_processor" ) then return false end

	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90

	local sf = MakeSF( ply, trace.HitPos, Ang, model)

	local min = sf:OBBMins()
	sf:SetPos( trace.HitPos - trace.HitNormal * min.z )

	local const = WireLib.Weld(sf, trace.Entity, trace.PhysicsBone, true)

	undo.Create("Wire Starfall Processor")
		undo.AddEntity( sf )
		undo.AddEntity( const )
		undo.SetPlayer( ply )
	undo.Finish()

	ply:AddCleanup( "starfall_processor", sf )
	
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
	function TOOL.BuildCPanel(panel)
		panel:AddControl("Header", { Text = "#Tool_wire_starfall_processor_name", Description = "#Tool_wire_starfall_processor_desc" })
		
		local modelPanel = WireDermaExts.ModelSelect(panel, "wire_starfall_processor_Model", list.Get("Wire_gate_Models"), 2)
		panel:AddControl("Label", {Text = ""})
		
		local docButton = vgui.Create("DButton" , panel)
		panel:AddPanel(docButton)
		docButton:SetText("Starfall LuaDoc")
		docButton.DoClick = function(button) gui.OpenURL("http://colonelthirtytwo.net/sfdoc/") end
		
		local filebrowser = vgui.Create("wire_expression2_browser")
		panel:AddPanel(filebrowser)
		filebrowser:Setup("Starfall")
		filebrowser:SetSize(235,400)
		
		function filebrowser:OnFileClick()
			SF.Editor.init()
			lastclick = CurTime()
			if(dir == self.File.FileDir and CurTime() - lastclick < 1) then
				SF.Editor.editor:Open(dir)
			else
				dir = self.File.FileDir
				SF.Editor.editor:LoadFile(dir)
			end
		end
		
		local openEditor = vgui.Create("DButton", panel)
		panel:AddPanel(openEditor)
		openEditor:SetText("Open Editor")
		openEditor.DoClick = SF.Editor.open
	end
	
	-- ------------------------------- Tool screen ------------------------------- --
	surface.CreateFont("Lucida Console", 25, 1000, true, false, "SFToolScreenFont")
	local function drawText(text, y, color) draw.DrawText(text, "SFToolScreenFont", 5, 32*y, color,0) end
	
	local uploadingCursor = 0;
	local uploadingPercent = 0;
	
	function TOOL:RenderToolScreen()
		if uploading then
			if not uploadData then
				uploadData = LibTransfer.queue_c2s[#(LibTransfer.queue_c2s)] or {};
				uploadData.dataSize = string.len(uploadData[2])
				
				if uploadData[1] ~= "starfall_upload" then uploadData = nil end
			end
			
			if uploadData then
				uploadingCursor = uploadData[5]
				uploadingPercent = math.Clamp((uploadingCursor / uploadData.dataSize) * 100, 0, 100)
					
				if uploadingCursor >= uploadData.dataSize then
					uploading = nil; uploadData = nil;
				end
			end
		end
		
		cam.Start2D()
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawRect(0, 0, 256, 256)
	
			drawText("SF Flasher", 1, Color(224, 244, 244, 255))
			
			drawText(string.format("Sent: %.2f KB", uploadingCursor / 1024), 3, Color(224, 244, 244, 255))
			drawText(string.format("Progress: %.0f %%", uploadingPercent), 4, Color(244, 244, 244, 255))
			if uploading then drawText("UPLOADING", 6, Color(0, 128, 0, 255)) end
		cam.End2D()
	end
end
