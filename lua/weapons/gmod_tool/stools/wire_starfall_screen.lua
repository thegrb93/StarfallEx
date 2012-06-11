TOOL.Category		= "Wire - Display"
TOOL.Name			= "Starfall - Screen"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.Tab			= "Wire"

TOOL.ClientConVar["Model"] = "models/hunter/plates/plate2x2.mdl"

include("libtransfer/libtransfer.lua")
include("starfall/sflib.lua")

if CLIENT then
	language.Add("Tool_wire_starfall_screen_name", 	"Starfall - Screen (Wire)")
    language.Add("Tool_wire_starfall_screen_desc", 	"Spawns a starfall screen")
    language.Add("Tool_wire_starfall_screen_0", 		"Primary: Spawns a screen and uploads code, Secondary: Opens editor")
	
	language.Add("Undone_Wire Starfall Screen", 		"Undone Starfall Screen")

	language.Add("Cleanup_wire_starfall_screens",   	"Starfall screens")
	language.Add("Cleaned_wire_starfall_screens",   	"Cleaned up all Wire Starfall Screens")
	language.Add("SBoxLimit_wire_starfall_screens", 	"You've hit the Starfall screen limit!")
end
cleanup.Register("wire_starfall_screens")

function TOOL:LeftClick(trace)
	if not trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end

	-- If there's no physics object then we can't constraint it!
    if SERVER and !util.IsValidPhysicsObject(trace.Entity, trace.PhysicsBone) then return false
    elseif CLIENT then return true end

	-- Upload code to existing entity?
	if trace.Entity:IsValid() and trace.Entity:GetClass() == "gmod_wire_starfall_screen" then
		SF.RequestUpload(self:GetOwner(), trace.Entity)
		return true
	end

	--self:SetStage(0) -- What is this? No doc in official gmod wiki

	local model = self:GetClientInfo("Model")
	local ply = self:GetOwner()

	-- Limit check
	if not self:GetSWEP():CheckLimit("wire_starfall_screens") then return false end

	-- Make the entity 
	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90

	local sf = MakeSFScreen(ply, trace.HitPos, Ang, model)
	if not sf then return false end

	-- Fix position
	local min = sf:OBBMins()
	sf:SetPos(trace.HitPos - trace.HitNormal * min.z)

	local constraint = WireLib.Weld(sf, trace.Entity, trace.PhysicsBone, true)

	-- Undo
	undo.Create("Wire Starfall Screen")
		undo.AddEntity(sf)
		undo.AddEntity(constraint)
		undo.SetPlayer(ply)
	undo.Finish()
	
	-- Request client to send code
	SF.RequestUpload(ply, sf)

	return true
end

function TOOL:RightClick( trace )
	if SERVER then self:GetOwner():SendLua("SF.Editor.open()") end
	return false
end

if SERVER then
	CreateConVar("sbox_maxwire_starfall_screens", 3, {FCVAR_REPLICATED,FCVAR_NOTIFY,FCVAR_ARCHIVE})

	-- (Server) General function to spawn a screen
	function MakeSFScreen(ply, pos, ang, model)
		if not ply:CheckLimit("wire_starfall_screens") then return nil end

		local sf = ents.Create("gmod_wire_starfall_screen")
		if not IsValid(sf) then return nil end

		sf:SetAngles(ang)
		sf:SetPos(pos)
		sf:SetModel(model)
		sf:Spawn()

		sf.owner = ply
		sf:SetPlayer(ply)

		ply:AddCount("wire_starfall_screens", sf)
		ply:AddCleanup("wire_starfall_screens", sf)

		return sf
	end

else
	local lastclick = CurTime()

	-- (Client)
	function TOOL.BuildCPanel(panel)
		panel:AddControl("Header", { Text = "#Tool_wire_starfall_screen_name", Description = "#Tool_wire_starfall_screen_desc" })
		
		local modelPanel = WireDermaExts.ModelSelect(panel, "wire_starfall_screen_Model", list.Get("WireScreenModels"), 2)
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

	function TOOL.RenderToolScreen()
		SF.RenderToolScreen()
	end
end

