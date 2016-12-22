TOOL.Category		= "Chips, Gates"
TOOL.Name			= "Starfall - Processor"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.Tab			= "Wire"

-- ------------------------------- Sending / Receiving ------------------------------- --
include("starfall/sflib.lua")

local MakeSF

TOOL.ClientConVar[ "Model" ] = "models/spacecode/sfchip.mdl"
TOOL.ClientConVar[ "ScriptModel" ] = ""
cleanup.Register( "starfall_processor" )

if SERVER then
	CreateConVar('sbox_maxstarfall_processor', 10, {FCVAR_REPLICATED,FCVAR_NOTIFY,FCVAR_ARCHIVE})
	
	function MakeSF( pl, Pos, Ang, model, inputs, outputs)
		if not pl:CheckLimit( "starfall_processor" ) then return false end

		local sf = ents.Create( "starfall_processor" )
		if not IsValid(sf) then return false end

		sf:SetAngles( Ang )
		sf:SetPos( Pos )
		sf:SetModel( model )
		sf:Spawn()

		sf.owner = pl
		
		if inputs and inputs[1] and inputs[2] then
			sf.Inputs = WireLib.AdjustSpecialInputs(sf, inputs[1], inputs[2])
		end
		if outputs and outputs[1] and outputs[2] then
			sf.Outputs = WireLib.AdjustSpecialOutputs(sf, outputs[1], outputs[2])
		end
		
		pl:AddCount( "starfall_processor", sf )
		pl:AddCleanup( "starfall_processor", sf )

		return sf
	end
	duplicator.RegisterEntityClass("starfall_processor", MakeSF, "Pos", "Ang", "Model", "_inputs", "_outputs")
else
	language.Add( "Tool.starfall_processor.name", "Starfall - Processor" )
	language.Add( "Tool.starfall_processor.desc", "Spawns a Starfall processor. (Press Shift+F to switch to the component tool)" )
	language.Add( "Tool.starfall_processor.left", "Spawn a processor / upload code" )
	language.Add( "Tool.starfall_processor.right", "Open editor" )
	language.Add( "sboxlimit_starfall_processor", "You've hit the Starfall processor limit!" )
	language.Add( "undone_Starfall Processor", "Undone Starfall Processor" )
	language.Add( "Cleanup_starfall_processor", "Starfall Processors" )
	TOOL.Information = { "left", "right" }
end

function TOOL:LeftClick( trace )
	if not trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end

	local ply = self:GetOwner()

	local ent = trace.Entity
	local sf
	if ent:IsValid() and ent:GetClass() == "starfall_processor" then
		sf = ent
		sf.owner = ply
	else
	
		--self:SetStage(0)

		local model = self:GetClientInfo( "Model" )
		if not (util.IsValidModel( model ) and util.IsValidProp( model )) then return false end
		if not self:GetSWEP():CheckLimit( "starfall_processor" ) then return false end

		local Ang = trace.HitNormal:Angle()
		Ang.pitch = Ang.pitch + 90

		sf = MakeSF( ply, trace.HitPos, Ang, model)

		local min = sf:OBBMins()
		sf:SetPos( trace.HitPos - trace.HitNormal * min.z )

		local const = WireLib.Weld(sf, ent, trace.PhysicsBone, true)

		undo.Create( "Starfall Processor" )
			undo.AddEntity( sf )
			undo.AddEntity( const )
			undo.SetPlayer( ply )
		undo.Finish()

	end
	
	if not SF.RequestCode(ply, function(mainfile, files)
		if not mainfile then return end
		if not IsValid(sf) then return end -- Probably removed during transfer
		sf:Compile(files, mainfile)
		if sf.instance and sf.instance.ppdata.models and sf.instance.mainfile then
			local model = sf.instance.ppdata.models[ sf.instance.mainfile ]
			if util.IsValidModel( model ) and util.IsValidProp( model ) then
				sf:SetModel( tostring( sf.instance.ppdata.models[ sf.instance.mainfile ] ) )
				sf:PhysicsInit( SOLID_VPHYSICS )
			end
		end
	end) then
		SF.AddNotify( ply, "Cannot upload SF code, please wait for the current upload to finish.", NOTIFY_ERROR, 7, NOTIFYSOUND_ERROR1 )
	end

	return true
end

function TOOL:RightClick( trace )
	if SERVER then 
	
		local ply = self:GetOwner()
		local ent = trace.Entity
		
		net.Start("starfall_openeditor")
		if IsValid( ent ) and ent:GetClass() == "starfall_processor" then
			net.WriteEntity( ent )
		else
			net.WriteEntity( nil )
		end
		net.Send(ply)
		
	end
	
	return false
end

function TOOL:Reload(trace)
	return false
end

function TOOL:DrawHUD()
end

function TOOL:Think()

	local model = self:GetClientInfo( "ScriptModel" )
	if model=="" then
		model = self:GetClientInfo( "Model" )
	end
	if ( !IsValid( self.GhostEntity ) || self.GhostEntity:GetModel() != model ) then
		self:MakeGhostEntity( model, Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )
	end

	local trace = util.TraceLine( util.GetPlayerTrace( self:GetOwner() ) )
	if ( !trace.Hit ) then return end
	local ent = self.GhostEntity
	
	if not IsValid(ent) then return end
	if ( trace.Entity && trace.Entity:GetClass() == "starfall_processor" || trace.Entity:IsPlayer() ) then

		ent:SetNoDraw( true )
		return

	end

	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90

	local min = ent:OBBMins()
	ent:SetPos( trace.HitPos - trace.HitNormal * min.z )
	ent:SetAngles( Ang )

	ent:SetNoDraw( false )

end

if CLIENT then

	local lastclick = CurTime()
	
	local function GotoDocs(button)
		gui.OpenURL("http://thegrb93.github.io/StarfallEx/") -- old one: http://sf.inp.io") -- old one: http://colonelthirtytwo.net/sfdoc/
	end
	
	function TOOL.BuildCPanel(panel)
		panel:AddControl( "Header", { Text = "#Tool.starfall_processor.name", Description = "#Tool.starfall_processor.desc" } )
		
		local gateModels = list.Get( "Starfall_gate_Models" )
		table.Merge( gateModels, list.Get( "Wire_gate_Models" ) )
		
		local modelPanel = WireDermaExts.ModelSelect( panel, "starfall_processor_Model", gateModels, 2 )
		panel:AddControl("Label", {Text = ""})
		
		local docbutton = vgui.Create("DButton" , panel)
		panel:AddPanel(docbutton)
		docbutton:SetText("Starfall Documentation")
		docbutton.DoClick = GotoDocs

		local filebrowser = vgui.Create( "StarfallFileBrowser" )
		panel:AddPanel( filebrowser )
		filebrowser.tree:setup( "starfall" )
		filebrowser:SetSize( 235,400 )
		
		local lastClick = 0
		filebrowser.tree.DoClick = function( self, node )
			if CurTime() <= lastClick + 0.5 then
				if not SF.Editor.initialized then SF.Editor.init() return end
				
				if not node:GetFileName() or string.GetExtensionFromFilename( node:GetFileName() ) ~= "txt" then return end
				local fileName = string.gsub( node:GetFileName(), "starfall/", "", 1 )
				local code = file.Read( node:GetFileName(), "DATA" )

				for k, v in pairs( SF.Editor.getTabHolder().tabs ) do
					if v.filename == fileName and v.code == code then
						SF.Editor.selectTab( v )
						SF.Editor.open()
						return
					end
				end

				SF.Editor.addTab( fileName, code )
				SF.Editor.open()
			end
			lastClick = CurTime()
		end
		
		local openeditor = vgui.Create("DButton", panel)
		panel:AddPanel(openeditor)
		openeditor:SetText("Open Editor")
		openeditor.DoClick = SF.Editor.open
	end
	
	local function hookfunc( ply, bind, pressed )
		if not pressed then return end

		local activeWep = ply:GetActiveWeapon()
		
		if bind == "impulse 100" and ply:KeyDown( IN_SPEED ) and IsValid(activeWep) and activeWep:GetClass() == "gmod_tool" then
			if activeWep.Mode == "starfall_processor" then
				spawnmenu.ActivateTool("starfall_component")
				return true
			elseif activeWep.Mode == "starfall_component" then
				spawnmenu.ActivateTool("starfall_processor")
				return true
			end
		end
	end
	
	if game.SinglePlayer() then -- wtfgarry (have to have a delay in single player or the hook won't get added)
		timer.Simple(5,function() hook.Add( "PlayerBindPress", "sf_toolswitch", hookfunc ) end)
	else
		hook.Add( "PlayerBindPress", "sf_toolswitch", hookfunc )
	end
end
