TOOL.Category		= "Wire - Display"
TOOL.Name			= "Starfall - Screen"
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
		
		if ent:GetClass() ~= "gmod_wire_starfall_screen" then
			ErrorNoHalt("SF: Player "..ply:GetName().." tried to send code to a non-starfall screen entity.\n")
			return
		end
		
		ent:CodeSent(ply,task)
	end
	LibTransfer.callbacks["starfallscreen_upload"] = callback
	
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
		umsg.Start("starfallscreen_requpload",ply)
			umsg.Entity(ent)
		umsg.End()
	end
else
	language.Add( "Tool_wire_starfall_screen_name", "Starfall - Screen (Wire)" )
    language.Add( "Tool_wire_starfall_screen_desc", "Spawns a starfall screen" )
    language.Add( "Tool_wire_starfall_screen_0", "Primary: Spawns a screen / uploads code, Secondary: Opens editor" )
	language.Add( "SBox_max_starfall_Screen", "You've hit the Starfall Screen limit!" )
	language.Add( "undone_Wire Starfall Screen", "Undone Starfall Screen" )
	
	local function sendreq(msg)
		local ent = msg:ReadEntity()
		if not SF.Editor.editor then return end
		
		local code = SF.Editor.getCode()
		--if code:match("^%s*.*%s*$") == "" then return end
		
		local ok, buildlist = SF.Editor.BuildIncludesTable()
		if ok then
			buildlist.entid = ent:EntIndex()
			LibTransfer.QueueTask("starfallscreen_upload",buildlist)
		else
			WireLib.AddNotify("File not found: "..buildlist,NOTIFY_ERROR,7,NOTIFYSOUND_ERROR1)
		end
	end
	usermessage.Hook("starfallscreen_requpload",sendreq)
end

TOOL.ClientConVar[ "Model" ] = "models/hunter/plates/plate2x2.mdl"

cleanup.Register( "starfall_screen" )


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
	function TOOL.BuildCPanel(panel)
		panel:AddControl("Header", { Text = "#Tool_wire_starfall_screen_name", Description = "#Tool_wire_starfall_screen_desc" })
		
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
	end
end
