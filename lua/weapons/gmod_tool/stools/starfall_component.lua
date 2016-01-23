TOOL.Category		= "Visuals/Screens"
TOOL.Wire_MultiCategories = { "Chips, Gates" }
TOOL.Name			= "Starfall - Components"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.Tab			= "Wire"

-- ------------------------------- Sending / Recieving ------------------------------- --
include("starfall/sflib.lua")

TOOL.ClientConVar[ "Model" ] = "models/hunter/plates/plate2x2.mdl"
TOOL.ClientConVar[ "Type" ] = 1
cleanup.Register( "starfall_components" )

if SERVER then	
	CreateConVar('sbox_maxstarfall_components', 3, {FCVAR_REPLICATED,FCVAR_NOTIFY,FCVAR_ARCHIVE})
else
	language.Add( "Tool.starfall_component.name", "Starfall - Component" )
	language.Add( "Tool.starfall_component.desc", "Spawns a starfall component" )
	language.Add( "Tool.starfall_component.0", "Primary: Spawns a component, Secondary: Link to processor" )
	language.Add( "Tool.starfall_component.1", "Now select the processor to link to.")
	language.Add( "sboxlimit_starfall_components", "You've hit the Starfall Component limit!" )
	language.Add( "undone_Starfall Screen", "Undone Starfall Screen" )
	language.Add( "undone_Starfall HUD", "Undone Starfall HUD" )
end

function TOOL:LeftClick( trace )
	if not trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end

	local ply = self:GetOwner()
	
	if not self:GetSWEP():CheckLimit( "starfall_components" ) then return false end
	--if not ply:CheckLimit( "starfall_screen" ) then return false end
		
	local component_type = self:GetClientInfo( "Type" )
	
	if component_type == "1" then
	
		local model = self:GetClientInfo( "Model" )
		local Ang = trace.HitNormal:Angle()
		Ang.pitch = Ang.pitch + 90

		local sf = ents.Create( "starfall_screen" )
		if not IsValid(sf) then return false end

			sf:SetAngles( Ang )
			sf:SetPos( trace.HitPos )
			sf:SetModel( model )
			sf:Spawn()

			ply:AddCount( "starfall_components", sf )

		local min = sf:OBBMins()
		sf:SetPos( trace.HitPos - trace.HitNormal * min.z )

		local const = WireLib.Weld(sf, trace.Entity, trace.PhysicsBone, true)

		undo.Create( "Starfall Screen" )
			undo.AddEntity( sf )
			undo.AddEntity( const )
			undo.SetPlayer( ply )
		undo.Finish()

		ply:AddCleanup( "starfall_components", sf )

		return true
		
	elseif component_type == "2" then
	
		local Ang = trace.HitNormal:Angle()
		Ang.pitch = Ang.pitch + 90

		local sf = ents.Create( "starfall_hud" )
		if not IsValid(sf) then return false end

			sf:SetAngles( Ang )
			sf:SetPos( trace.HitPos )
			sf:SetModel( "models/bull/dynamicbutton.mdl" )
			sf:Spawn()

			ply:AddCount( "starfall_components", sf )

		local min = sf:OBBMins()
		sf:SetPos( trace.HitPos - trace.HitNormal * min.z )

		local const = WireLib.Weld(sf, trace.Entity, trace.PhysicsBone, true)

		undo.Create( "Starfall HUD" )
			undo.AddEntity( sf )
			undo.AddEntity( const )
			undo.SetPlayer( ply )
		undo.Finish()

		ply:AddCleanup( "starfall_components", sf )
		
		return true

	end
	return false
end

function TOOL:RightClick( trace )
	if not trace.HitPos or not IsValid(trace.Entity) or trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end

	local ent = trace.Entity
	local ply = self:GetOwner()
	
	if self:GetStage() == 0 then -- stage 0: right-clicking on our own class selects it
		if ent:GetClass()=="starfall_screen" or ent:GetClass()=="starfall_hud" then
			self.Component = ent
			self:SetStage(1)
			return true
		else
			return false
		end
	elseif self:GetStage() == 1 then -- stage 1: right-clicking on something links it
		if not IsValid(self.Component) then self:SetStage(0) return end
		if self.Component:GetClass()=="starfall_screen" and ent:GetClass()=="starfall_processor" then
		
			self.Component:LinkEnt( ent )
			self:SetStage(0)
			SF.AddNotify( ply, "Linked to starfall successfully.", NOTIFY_GENERIC , 4, NOTIFYSOUND_DRIP2 )
			return true
			
		elseif self.Component:GetClass()=="starfall_hud" and ent:GetClass()=="starfall_processor" then
		
			self.Component:LinkEnt( ent )
			self:SetStage(0)
			SF.AddNotify( ply, "Linked to starfall successfully.", NOTIFY_GENERIC , 4, NOTIFYSOUND_DRIP2 )
			return true
			
		elseif self.Component:GetClass()=="starfall_hud" and ent:IsVehicle() then
		
			self.Component:LinkVehicle( ent )
			self:SetStage(0)
			SF.AddNotify( ply, "Linked to vehicle successfully.", NOTIFY_GENERIC , 4, NOTIFYSOUND_DRIP2 )
			return true
		
		end
		SF.AddNotify( ply, "Link Invalid.", NOTIFY_ERROR , 4, NOTIFYSOUND_ERROR1 )
		return false
	end
end

function TOOL:Reload(trace)
	return false
end

function TOOL:DrawHUD()
end

function TOOL:Think()
end

if CLIENT then		
	function TOOL.BuildCPanel(panel)
		panel:AddControl( "Header", { Text = "#Tool.starfall_component.name", Description = "#Tool.starfall_component.desc" } )
		
		local modelpanel = WireDermaExts.ModelSelect( panel, "starfall_component_Model", list.Get( "WireScreenModels" ), 2 )
		panel:AddControl("Label", {Text = ""})
		

		local cbox = {}
		cbox.Label = "Component Type"
		cbox.MenuButton = 0
		cbox.Options = {}
		cbox.Options.Screen = { starfall_component_Type = 1 }
		cbox.Options.HUD = { starfall_component_Type = 2 }
		panel:AddControl("ComboBox", cbox)

	end
end
