TOOL.Category		= "Starfall"
TOOL.Name			= "Starfall"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.Tab			= "Wire"

--------------------------------- Sending / Recieving ---------------------------------
LibTransfer = LibTransfer or {}
LibTransfer.callbacks = LibTransfer.callbacks or {}

if SERVER then
	local function callback(ply, task)
		local ent = ents.GetByIndex(task.entid)
		if ent == nil then
			ErrorNoHalt("SF: Player "..ply:GetName().." tried to send code to a nonexistant entity.\n")
			return
		end
		
		if ent:GetClass() ~= "gmod_starfall" then
			ErrorNoHalt("SF: Player "..ply:GetName().." tried to send code to a non-starfall entity.\n")
			return
		end
		
		ent:SendCode(ply,task)
	end
	LibTransfer.callbacks["starfall_upload"] = callback
	
	CreateConVar('sbox_maxwire_starfall', 10, {FCVAR_REPLICATED,FCVAR_NOTIFY,FCVAR_ARCHIVE})
	
	function MakeSF( pl, Pos, Ang, model)
		if !pl:CheckLimit( "wire_starfall" ) then return false end

		local sf = ents.Create( "gmod_starfall" )
		if !IsValid(sf) then return false end

		sf:SetAngles( Ang )
		sf:SetPos( Pos )
		sf:SetModel( model )
		sf:Spawn()

		sf.player = pl

		pl:AddCount( "wire_starfall", sf )

		return sf
	end
elseif CLIENT then
	language.Add( "Tool_starfall_name", "Starfall Tool (Wire)" )
    language.Add( "Tool_starfall_desc", "Spawns a starfall processor" )
    language.Add( "Tool_starfall_0", "Primary: Spawns a processor / uploads code, Secondary: Opens editor" )
	language.Add( "sboxlimit_starfall", "You've hit the Starfall processor limit!" )
	language.Add( "undone_Wire Starfall", "Undone Starfall" )
	
	function SF_InitEditor()
		if not SF_Editor then
			SF_Editor = vgui.Create("Expression2EditorFrame")
			SF_Editor:Setup("SF Editor", "Starfall", "nothing") -- Setting the editor type to not nil keeps the validator line
			
			-- Remove syntax highlighting
			local func = function(self, row) return {{self.Rows[row], { Color(255, 255, 255, 255), false}}} end
			SF_Editor:SetSyntaxColorLine( func )
			
			function SF_Editor:Validate(gotoerror)
				local err = CompileString(self:GetCode(), "SF:"..self:GetChosenFile(), false)
				
				if type(err) == "string" then
					self.C['Val'].panel:SetBGColor(128, 0, 0, 180)
					self.C['Val'].panel:SetFGColor(255, 255, 255, 128)
					self.C['Val'].panel:SetText( "   " .. err )
				else
					self.C['Val'].panel:SetBGColor(0, 128, 0, 180)
					self.C['Val'].panel:SetFGColor(255, 255, 255, 128)
					self.C['Val'].panel:SetText( "   No Syntax Errors" )
				end
			end
		end
	end
	
	function SF_OpenEditor()
		SF_InitEditor()
		SF_Editor:Open()
	end
	concommand.Add("sf_open_editor", SF_OpenEditor)
	
	function SF_Upload(entid)
		if not SF_Editor then return end
		local task = {}
		
		local currcode = SF_Editor:GetCode()
		local currpath = SF_Editor:GetChosenFile() or "main"
		task.entid = entid
		task.includes = SF_PProcessor.BuildSendList(currpath, currcode)
		task.mainpath = currpath
		
		LibTransfer:QueueTask("starfall_upload",task)
	end
end

TOOL.ClientConVar[ "Model" ] = "models/jaanus/wiretool/wiretool_siren.mdl"

cleanup.Register( "wire_starfall" )


function TOOL:LeftClick( trace )
	if !trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end

	if trace.Entity:IsValid() and trace.Entity:GetClass() == "gmod_starfall" then
		self:GetOwner():SendLua("SF_Upload("..trace.Entity:EntIndex()..")")
		return true
	end
	
	self:SetStage(0)

	local model = self:GetClientInfo( "Model" )
	local ply = self:GetOwner()
	if !self:GetSWEP():CheckLimit( "wire_starfall" ) then return false end

	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90

	local sf = MakeSF( ply, trace.HitPos, Ang, model)

	local min = sf:OBBMins()
	sf:SetPos( trace.HitPos - trace.HitNormal * min.z )

	local const = WireLib.Weld(sf, trace.Entity, trace.PhysicsBone, true)

	undo.Create("Wire Starfall")
		undo.AddEntity( sf )
		undo.AddEntity( const )
		undo.SetPlayer( ply )
	undo.Finish()

	ply:AddCleanup( "wire_starfall", sf )
	
	ply:SendLua("SF_Upload("..sf:EntIndex()..")")

	return true
end

function TOOL:RightClick( trace )
	if SERVER then self:GetOwner():SendLua("SF_OpenEditor()") end
	return false
end

function TOOL:Reload(trace)
	return false
end

function TOOL:DrawHUD()
end

function TOOL:Think()
end

local lastclick = CurTime()
function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", { Text = "#Tool_starfall_name", Description = "#Tool_starfall_desc" })
	
	local filebrowser = vgui.Create("wire_expression2_browser")
	panel:AddPanel(filebrowser)
	filebrowser:Setup("Starfall")
	filebrowser:SetSize(235,400)
	
	function filebrowser:OnFileClick()
		SF_InitEditor()
		if(dir == self.File.FileDir and CurTime() - lastclick < 1) then
			SF_Editor:Open(dir)
		else
			lastclick = CurTime()
			dir = self.File.FileDir
			SF_Editor:LoadFile(dir)
		end
	end
end