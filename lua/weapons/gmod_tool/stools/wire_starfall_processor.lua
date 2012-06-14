TOOL.Category		= "Wire - Control"
TOOL.Name			= "Starfall - Processor"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.Tab			= "Wire"

TOOL.ClientConVar["Model"] = "models/bull/gates/processor.mdl"

include("libtransfer/libtransfer.lua")
include("starfall/sflib.lua")

if CLIENT then
	language.Add("Tool_wire_starfall_processor_name", 	"Starfall - Processor (Wire)")
    language.Add("Tool_wire_starfall_processor_desc", 	"Spawns a starfall processor")
    language.Add("Tool_wire_starfall_processor_0", 		"Primary: Spawns a processor and uploads code, Secondary: Opens editor")
	
	language.Add("Undone_Wire Starfall Processor", 		"Undone Starfall Processor")

	language.Add("Cleanup_wire_starfall_processors",   	"Starfall processors")
	language.Add("Cleaned_wire_starfall_processors",   	"Cleaned up all Wire Starfall Processors")
	language.Add("SBoxLimit_wire_starfall_processors", 	"You've hit the Starfall processor limit!")
end
cleanup.Register("wire_starfall_processors")

function TOOL:LeftClick(trace)
	if not trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end

	-- If there's no physics object then we can't constraint it!
    if SERVER and !util.IsValidPhysicsObject(trace.Entity, trace.PhysicsBone) then return false
    elseif CLIENT then return true end

	-- Upload code to existing entity?
	if trace.Entity:IsValid() and trace.Entity:GetClass() == "gmod_wire_starfall_processor" then
		SF.RequestUpload(self:GetOwner(), trace.Entity)
		return true
	end

	--self:SetStage(0) -- What is this? No doc in official gmod wiki

	local model = self:GetClientInfo("Model")
	local ply = self:GetOwner()

	-- Limit check
	if not self:GetSWEP():CheckLimit("wire_starfall_processors") then return false end

	-- Make the entity 
	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90

	local sf = MakeSF(ply, trace.HitPos, Ang, model)
	if not sf then return false end

	-- Fix position
	local min = sf:OBBMins()
	sf:SetPos(trace.HitPos - trace.HitNormal * min.z)

	local constraint = WireLib.Weld(sf, trace.Entity, trace.PhysicsBone, true)

	-- Undo
	undo.Create("Wire Starfall Processor")
		undo.AddEntity(sf)
		undo.AddEntity(constraint)
		undo.SetPlayer(ply)
	undo.Finish()
	
	-- Request client to send code
	SF.RequestUpload(ply, sf)

	return true
end

function TOOL:RightClick(trace)
	if SERVER then self:GetOwner():SendLua("SF.Editor.open()") end

	return false
end

if SERVER then
	CreateConVar("sbox_maxwire_starfall_processors", 10, {FCVAR_REPLICATED,FCVAR_NOTIFY,FCVAR_ARCHIVE})

	-- (Server) General function to spawn a processor
	function MakeSF(ply, pos, ang, model)
		if not ply:CheckLimit("wire_starfall_processors") then return nil end

		local sf = ents.Create("gmod_wire_starfall_processor")
		if not IsValid(sf) then return nil end

		sf:SetAngles(ang)
		sf:SetPos(pos)
		sf:SetModel(model)
		sf:Spawn()

		sf.owner = ply
		sf:SetPlayer(ply)

		ply:AddCount("wire_starfall_processors", sf)
		ply:AddCleanup("wire_starfall_processors", sf)

		return sf
	end

else
	local lastclick = CurTime()

	-- (Client)
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
end

--------------------------------- ToolScreen ---------------------------------
local uploading

if CLIENT then
	surface.CreateFont("Lucida Console", 100, 1000, true, false, "SFToolScreenFont")
	
	local uploadingCursor = 0
	local uploadingPercent = 0

	local boxes = 10
	local dPerBox = math.pi * 2 / boxes
	local tex = surface.GetTextureID("gui/gradient_down")

	function SF.RenderToolScreen()
		if uploading then
			if not uploadData then
				uploadData = LibTransfer.queue_c2s[#(LibTransfer.queue_c2s)] or {};
				uploadData.dataSize = string.len(uploadData[2])
				
				if uploadData[1] ~= "starfall_upload" then uploadData = nil end
			end
			
			if uploadData then
				uploadingCursor = uploadData[5]
				uploadingPercent = math.Clamp((uploadingCursor / uploadData.dataSize) * 100, 0, 100) -- Clamp to avoid division by zero
					
				if uploadingCursor >= uploadData.dataSize then
					uploading = nil
					uploadData = nil
				end
			end
		end
		
		cam.Start2D()
			surface.SetDrawColor(64, 64, 64, 255)
			surface.DrawRect(0, 0, 256, 256)
			
			draw.DrawText("SF", "SFToolScreenFont", 128 - 64, 128 - 64, Color(224, 244, 244, 255), 0)

			-- Neat progress bar by Cenius
			for box=1, boxes do
				local posx = 128 + math.cos(box * dPerBox) * 100
				local posy = 128 + math.sin(box * dPerBox) * 100
				local ang = math.Rad2Deg(math.atan2(128 - posx, 128 - posy))

				local clr = 0
				local startprogress = ((boxes + boxes/4 + box) % boxes) / boxes
				local progress = uploadingPercent / 100
				if progress > startprogress then
					if progress < (startprogress+(1/boxes)) and progress < 0.98 then -- < 0.98 because when upload finishes we don't know exactly progress
						clr = (progress % startprogress) * 10 * 255
					else
						clr = 255
					end
				end

				surface.SetTexture(tex)
				surface.SetDrawColor(255 - clr, clr, 0, 255)
				surface.DrawTexturedRectRotated(posx, posy, 48, 24, ang)
			end

		cam.End2D()
	end
	
	function TOOL.RenderToolScreen()
		SF.RenderToolScreen()
	end
end


--------------------------------- Uploading ---------------------------------
if SERVER then
	-- (Server) Makes client feel we really need his code
	function SF.RequestUpload(ply, ent)
		ply:ConCommand("wire_starfall_requpload "..ent:EntIndex())
	end

	-- (Server) Code from client arrived
	local function onUploadReceived(ply, task)
		local ent = ents.GetByIndex(task.entid)

		if not ent or not ent:IsValid() then
			--ErrorNoHalt("SF: Player "..ply:GetName().." tried to send code to a nonexistant entity.\n")
			-- There is possibly to spam with these errors. (Quickly spawn and undo entity)
			return
		end
		
		if ent:GetClass() ~= "gmod_wire_starfall_processor" and ent:GetClass() ~= "gmod_wire_starfall_screen" then
			ErrorNoHalt("SF: Player "..ply:GetName().." tried to send code to a non-starfall processor / screen entity.\n")
			-- This is only for debug. There is also a way to spam server's console using this.
			return
		end
		
		ent:CodeSent(ply, task)
	end
	LibTransfer.callbacks["starfall_upload"] = onUploadReceived
else
	-- (Client) Send code
	concommand.Add("wire_starfall_requpload", function(ply, cmds, args)
		if not SF.Editor.isInitialized() then SF.Editor.init() return end
		
		local code = SF.Editor.getCode()
		--if code:match("^%s*.*%s*$") == "" then return end
		
		local ok, buildlist = SF.Editor.BuildIncludesTable()
		if ok then
			buildlist.entid = tonumber(args[1])
			LibTransfer.QueueTask("starfall_upload", buildlist)
			uploading = true
		else
			WireLib.AddNotify("File not found: "..buildlist, NOTIFY_ERROR, 7, NOTIFYSOUND_ERROR1)
		end
	end)
end
