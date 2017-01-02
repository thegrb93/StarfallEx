TOOL.Category		= "Visuals/Screens"
TOOL.Wire_MultiCategories = { "Chips, Gates" }
TOOL.Name			= "Starfall - Components"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.Tab			= "Wire"

-- ------------------------------- Sending / Receiving ------------------------------- --
include("starfall/sflib.lua")

TOOL.ClientConVar[ "Model" ] = "models/hunter/plates/plate2x2.mdl"
TOOL.ClientConVar[ "Type" ] = 1
cleanup.Register( "starfall_components" )

if SERVER then	
	CreateConVar('sbox_maxstarfall_components', 3, {FCVAR_REPLICATED,FCVAR_NOTIFY,FCVAR_ARCHIVE})
	
	function MakeComponent( class, pl, Pos, Ang, model )
		if not pl:CheckLimit( "starfall_components" ) then return false end
		
		local sf = ents.Create( class )
		if not IsValid(sf) then return false end

		sf:SetAngles( Ang )
		sf:SetPos( Pos )
		sf:SetModel( model )
		sf:Spawn()
		
		pl:AddCount( "starfall_components", sf )
		pl:AddCleanup( "starfall_components", sf )

		return sf
	end
	
	duplicator.RegisterEntityClass("starfall_screen", function(...)
		return MakeComponent("starfall_screen", ...) 
	end, "Pos", "Ang", "Model")
	
	duplicator.RegisterEntityClass("starfall_hud", function(...)
		return MakeComponent("starfall_hud", select(1, ...), select(2, ...), select(3, ...), "models/bull/dynamicbutton.mdl") 
	end, "Pos", "Ang", "Model")
	
else
	language.Add( "Tool.starfall_component.name", "Starfall - Component" )
	language.Add( "Tool.starfall_component.desc", "Spawns a Starfall component. (Press Shift+F to switch to the processor tool)" )
	language.Add( "sboxlimit_starfall_components", "You've hit the Starfall Component limit!" )
	language.Add( "undone_Starfall Screen", "Undone Starfall Screen" )
	language.Add( "undone_Starfall HUD", "Undone Starfall HUD" )
	language.Add( "Cleanup_starfall_components", "Starfall Components" )
	TOOL.Information = {
		{ name = "left", stage = 0, text = "Spawn a component" },
		{ name = "right_0", stage = 0, text = "Link to processor" },
		{ name = "reload", stage = 0, text = "Clear the link" },
		{ name = "right_1", stage = 1, text = "Select the processor to link to" },
	}
	for _, info in pairs(TOOL.Information) do
		language.Add("Tool.starfall_component." .. info.name, info.text)
	end
end

function TOOL:LeftClick( trace )
	if not trace.HitPos then return false end
	if trace.Entity:IsPlayer() or trace.Entity:IsNPC() then return false end
	if CLIENT then return true end

	local ply = self:GetOwner()
	
	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90
	
	local component_type = self:GetClientInfo( "Type" )
	if component_type == "1" then
	
		local model = self:GetClientInfo( "Model" )
		if not (util.IsValidModel( model ) and util.IsValidProp( model )) then return false end

		local sf = MakeComponent( "starfall_screen", ply, Vector(), Ang, model )
		if not sf then return false end

		local min = sf:OBBMins()
		sf:SetPos( trace.HitPos - trace.HitNormal * min.z )

		local const
		local phys = sf:GetPhysicsObject()
		if trace.Entity:IsValid() then
			local const = constraint.Weld( sf, trace.Entity, 0, trace.PhysicsBone, 0, true, true )
			if phys:IsValid() then phys:EnableCollisions( false ) sf.nocollide = true end
		else
			if phys:IsValid() then phys:EnableMotion( false ) end
		end

		undo.Create( "Starfall Screen" )
			undo.AddEntity( sf )
			if const then undo.AddEntity( const ) end
			undo.SetPlayer( ply )
		undo.Finish()

		return true
		
	elseif component_type == "2" then

		local sf = MakeComponent( "starfall_hud", ply, Vector(), Ang, "models/bull/dynamicbutton.mdl" )
		if not sf then return false end

		local min = sf:OBBMins()
		sf:SetPos( trace.HitPos - trace.HitNormal * min.z )

		local const
		local phys = sf:GetPhysicsObject()
		if trace.Entity:IsValid() then
			local const = constraint.Weld( sf, trace.Entity, 0, trace.PhysicsBone, 0, true, true )
			if phys:IsValid() then phys:EnableCollisions( false ) sf.nocollide = true end
		else
			if phys:IsValid() then phys:EnableMotion( false ) end
		end

		undo.Create( "Starfall HUD" )
			undo.AddEntity( sf )
			undo.AddEntity( const )
			undo.SetPlayer( ply )
		undo.Finish()
		
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
			SF.AddNotify( ply, "Linked to starfall successfully.", "GENERIC" , 4, "DRIP2" )
			return true
			
		elseif self.Component:GetClass()=="starfall_hud" and ent:GetClass()=="starfall_processor" then
		
			self.Component:LinkEnt( ent )
			self:SetStage(0)
			SF.AddNotify( ply, "Linked to starfall successfully.", "GENERIC" , 4, "DRIP2" )
			return true
			
		elseif self.Component:GetClass()=="starfall_hud" and ent:IsVehicle() then
		
			self.Component:LinkVehicle( ent )
			self:SetStage(0)
			SF.AddNotify( ply, "Linked to vehicle successfully.", "GENERIC" , 4, "DRIP2" )
			return true
		
		end
		SF.AddNotify( ply, "Link Invalid.", "ERROR" , 4, "ERROR1" )
		return false
	end
end

function TOOL:Reload(trace)
	if not trace.HitPos or not IsValid(trace.Entity) or trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end
	
	local ent = trace.Entity
	
	if ent:GetClass()=="starfall_screen" then
		ent:LinkEnt( nil )
		return true
	elseif ent:GetClass()=="starfall_hud" then
		ent:LinkEnt( nil )
		ent:LinkVehicle( nil )
		return true
	end
	
	return false
end

function TOOL:DrawHUD()
end

function TOOL:Think()

	local Type = self:GetClientInfo( "Type" )
	local model
	if Type=="1" then 
		model = self:GetClientInfo( "Model" )
	else
		model = "models/bull/dynamicbutton.mdl"
	end
	if ( !IsValid( self.GhostEntity ) || self.GhostEntity:GetModel() != model ) then
		self:MakeGhostEntity( model, Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )
	end

	local trace = util.TraceLine( util.GetPlayerTrace( self:GetOwner() ) )
	if ( !trace.Hit ) then return end
	local ent = self.GhostEntity
	
	if not IsValid(ent) then return end

	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90

	local min = ent:OBBMins()
	ent:SetPos( trace.HitPos - trace.HitNormal * min.z )
	ent:SetAngles( Ang )

end

if CLIENT then		
	function TOOL.BuildCPanel(panel)
		panel:AddControl( "Header", { Text = "#Tool.starfall_component.name", Description = "#Tool.starfall_component.desc" } )
				
		local modelPanel = vgui.Create("DPanelSelect", panel)
		modelPanel:EnableVerticalScrollbar()
		modelPanel:SetTall(66 * 2 + 2)
		for model,v in pairs(scripted_ents.GetStored("starfall_screen").t.Monitor_Offsets) do
			local icon = vgui.Create("SpawnIcon")
			icon:SetModel(model)
			icon.Model = model
			icon:SetSize(64, 64)
			icon:SetTooltip(model)
			modelPanel:AddPanel(icon, {["starfall_component_Model"] = model})
		end
		modelPanel:SortByMember("Model", false)
		panel:AddPanel(modelPanel)
		
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
