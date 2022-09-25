TOOL.Category		= "Starfall"
TOOL.Wire_MultiCategories = { "Chips, Gates" }
TOOL.Name			= "Starfall - Components"
TOOL.Command		= nil
TOOL.ConfigName		= ""

-- ------------------------------- Sending / Receiving ------------------------------- --

TOOL.ClientConVar["Model"] = "models/hunter/plates/plate2x2.mdl"
TOOL.ClientConVar["ModelHUD"] = "models/bull/dynamicbuttonsf.mdl"
TOOL.ClientConVar["Type"] = "1"
TOOL.ClientConVar["parent"] = "0"
TOOL.ClientConVar["createflat"] = "0"
cleanup.Register("starfall_components")

local MakeComponent

if SERVER then
	CreateConVar('sbox_maxstarfall_components', 10, { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE })

	function MakeComponent(class, pl, Pos, Ang, model)
		if not pl:CheckLimit("starfall_components") then return false end

		local sf = ents.Create(class)
		if not (sf and sf:IsValid()) then return false end
		if not (util.IsValidModel(model) and util.IsValidProp(model)) then model = "models/spacecode/sfchip.mdl" end

		sf:SetAngles(Ang)
		sf:SetPos(Pos)
		sf:SetModel(model)
		sf:Spawn()

		pl:AddCount("starfall_components", sf)
		pl:AddCleanup("starfall_components", sf)

		return sf
	end

	duplicator.RegisterEntityClass("starfall_screen", function(...)
		return MakeComponent("starfall_screen", ...)
	end, "Pos", "Ang", "Model")

	duplicator.RegisterEntityClass("starfall_hud", function(...)
		return MakeComponent("starfall_hud", ...)
	end, "Pos", "Ang", "Model")

else
	language.Add("Tool.starfall_component.name", "Starfall - Component")
	language.Add("Tool.starfall_component.desc", "Spawns a Starfall component. (Press Shift+F to switch to the processor tool)")
	language.Add("Tool.starfall_component.parent", "Parent instead of Weld" )
	language.Add("Tool.starfall_component.createflat", "Create flat to surface" )
	language.Add("sboxlimit_starfall_components", "You've hit the Starfall Component limit!")
	language.Add("undone_Starfall Screen", "Undone Starfall Screen")
	language.Add("undone_Starfall HUD", "Undone Starfall HUD")
	language.Add("Cleanup_starfall_components", "Starfall Components")
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

-- Base function from WireMod tool_loader.lua
function TOOL:GetAngle( trace, model, disable_flat )
	local createflat = self:GetClientNumber("createflat")
	if disable_flat then createflat = 0 end

	local Ang
	if math.abs(trace.HitNormal.x) < 0.001 and math.abs(trace.HitNormal.y) < 0.001 then
		Ang = Vector(0,0,trace.HitNormal.z):Angle()
	else
		Ang = trace.HitNormal:Angle()
	end
	if self.GetGhostAngle then -- the tool as a function for getting the proper angle for the ghost
		Ang = self:GetGhostAngle( trace )
	elseif self.GhostAngle then -- the tool gives a fixed angle to add
		Ang = Ang + self.GhostAngle
	end

	if string.find(model, "pcb") or string.find(model, "hunter") then
		-- PHX Screen models should thus be +180 when not flat, +90 when flat
		if createflat == 0 then
			Ang.pitch = Ang.pitch + 180
		else
			Ang.pitch = Ang.pitch + 90
		end
	else
		if createflat == 0 then
			Ang.pitch = Ang.pitch + 90
		end
	end

	return Ang
end

-- Base function from WireMod tool_loader.lua
function TOOL:GetPos( ent, trace, model, disable_flat )
	local createflat = self:GetClientNumber("createflat")
	if disable_flat then createflat = 0 end

	-- move the ghost to aline properly to where the device will be made
	local min = ent:OBBMins()
	if self.GetGhostMin then -- tool has a function for getting the min
		return ( trace.HitPos - trace.HitNormal * self:GetGhostMin( min, trace ) )
	elseif self.GhostMin then -- tool gives the axis for the OBBmin to use
		return ( trace.HitPos - trace.HitNormal * min[self.GhostMin] )
	elseif self.ClientConVar.createflat and (createflat == 1) ~= ((string.find(model, "pcb") or string.find(model, "hunter")) ~= nil) then
		-- Screens have odd models. If createflat is 1, or its 0 and its a PHX model, use max.x
		return ( trace.HitPos + trace.HitNormal * ent:OBBMaxs().x )
	else -- default to the z OBBmin
		return ( trace.HitPos - trace.HitNormal * min.z )
	end
end

function TOOL:LeftClick(trace)
	if not trace.HitPos then return false end
	if trace.Entity:IsPlayer() or trace.Entity:IsNPC() then return false end
	if CLIENT then return true end

	local ply = self:GetOwner()

	local component_type = self:GetClientInfo("Type")
	if component_type == "1" then
		local model = self:GetClientInfo("Model")
		if not (util.IsValidModel(model) and util.IsValidProp(model)) then return false end

		local sf = MakeComponent("starfall_screen", ply, Vector(), Angle(), model)
		if not sf then return false end

		sf:SetPos( self:GetPos( sf, trace, model ) )
		sf:SetAngles( self:GetAngle( trace, model ) )

		local const
		if trace.Entity:IsValid() then
			if self:GetClientNumber( "parent", 0 ) ~= 0 then
				sf:SetParent(trace.Entity)
			else
				const = constraint.Weld(sf, trace.Entity, 0, trace.PhysicsBone, 0, true, true)
			end
			local phys = sf:GetPhysicsObject()
			if phys:IsValid() then phys:EnableCollisions(false) sf.nocollide = true end
		else
			local phys = sf:GetPhysicsObject()
			if phys:IsValid() then phys:EnableMotion(false) end
		end

		undo.Create("Starfall Screen")
			undo.AddEntity(sf)
			if const then undo.AddEntity(const) end
			undo.SetPlayer(ply)
		undo.Finish()

		return true

	elseif component_type == "2" then
		local model = self:GetClientInfo("ModelHUD")

		local sf = MakeComponent("starfall_hud", ply, Vector(), Angle(), model)
		if not sf then return false end

		sf:SetPos( self:GetPos( sf, trace, model, true ) )
		sf:SetAngles( self:GetAngle( trace, model, true ) )

		local const
		if trace.Entity:IsValid() then
			if self:GetClientNumber( "parent", 0 ) ~= 0 then
				sf:SetParent(trace.Entity)
			else
				const = constraint.Weld(sf, trace.Entity, 0, trace.PhysicsBone, 0, true, true)
			end
			local phys = sf:GetPhysicsObject()
			if phys:IsValid() then phys:EnableCollisions(false) sf.nocollide = true end
		else
			local phys = sf:GetPhysicsObject()
			if phys:IsValid() then phys:EnableMotion(false) end
		end

		undo.Create("Starfall HUD")
			undo.AddEntity(sf)
			if const then undo.AddEntity(const) end
			undo.SetPlayer(ply)
		undo.Finish()

		return true

	end
	return false
end

function TOOL:RightClick(trace)
	if not trace.HitPos or not (trace.Entity and trace.Entity:IsValid()) or trace.Entity:IsPlayer() then return false end
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
		if not (self.Component and self.Component:IsValid()) then self:SetStage(0) return end
		if self.Component:GetClass()=="starfall_screen" and ent:GetClass()=="starfall_processor" then

			SF.LinkEnt(self.Component, ent)
			self:SetStage(0)
			SF.AddNotify(ply, "Linked to starfall successfully.", "GENERIC" , 4, "DRIP2")
			return true

		elseif self.Component:GetClass()=="starfall_hud" and ent:GetClass()=="starfall_processor" then

			SF.LinkEnt(self.Component, ent)
			self:SetStage(0)
			SF.AddNotify(ply, "Linked to starfall successfully.", "GENERIC" , 4, "DRIP2")
			return true

		elseif self.Component:GetClass()=="starfall_hud" and ent:IsVehicle() then

			self.Component:LinkVehicle(ent)
			self:SetStage(0)
			SF.AddNotify(ply, "Linked to vehicle successfully.", "GENERIC" , 4, "DRIP2")
			return true

		end
		SF.AddNotify(ply, "Link Invalid.", "ERROR" , 4, "ERROR1")
		return false
	end
end

function TOOL:Reload(trace)
	if not trace.HitPos or not (trace.Entity and trace.Entity:IsValid()) or trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end

	local ent = trace.Entity

	if ent:GetClass()=="starfall_screen" then
		SF.LinkEnt(ent, nil)
		return true
	elseif ent:GetClass()=="starfall_hud" then
		SF.LinkEnt(ent, nil)
		ent:LinkVehicle(nil)
		return true
	end

	return false
end

function TOOL:DrawHUD()
end

function TOOL:Think()
	-- Ghost code
	if (SERVER and game.SinglePlayer()) or (CLIENT and not game.SinglePlayer()) then
		local model
		local Type = self:GetClientInfo("Type")
		if Type=="1" then
			model = self:GetClientInfo("Model")
		else
			model = self:GetClientInfo("ModelHUD")
		end

		local ghost = self.GhostEntity
		if not (ghost and ghost:IsValid() and ghost:GetModel() == model) then
			self:MakeGhostEntity(model, Vector(0, 0, 0), Angle(0, 0, 0))
			ghost = self.GhostEntity
		end

		if ghost and ghost:IsValid() then
			local trace = self:GetOwner():GetEyeTrace()
			if trace.Hit then
				ghost:SetPos( self:GetPos( ghost, trace, model, Type == "2" ) )
				ghost:SetAngles( self:GetAngle( trace, model, Type == "2" ) )
			end
		end
	end
end

if CLIENT then
	function TOOL.BuildCPanel(panel)
		panel:AddControl("Header", { Text = "#Tool.starfall_component.name", Description = "#Tool.starfall_component.desc" })
		panel:AddControl("CheckBox", { Label = "#Tool.starfall_component.parent", Command = "starfall_component_parent" } )
		panel:AddControl("CheckBox", { Label = "#Tool.starfall_component.createflat", Command = "starfall_component_createflat" } )

		local modelPanel = vgui.Create("DPanelSelect", panel)
		modelPanel:EnableVerticalScrollbar()
		modelPanel:SetTall(66 * 5 + 2)
		for model, v in pairs(scripted_ents.GetStored("starfall_screen").t.Monitor_Offsets) do
			local icon = vgui.Create("SpawnIcon")
			icon:SetModel(model)
			icon.Model = model
			icon:SetSize(64, 64)
			icon:SetTooltip(v.Name)
			icon.OpenMenu = function( button )
				local menu = DermaMenu()
				menu:AddOption( "#spawnmenu.menu.copy", function() SetClipboardText( model ) end ):SetIcon( "icon16/page_copy.png" )
				menu:Open()
			end
			modelPanel:AddPanel(icon, { ["starfall_component_Model"] = model })
		end
		modelPanel:SortByMember("Model", false)
		panel:AddPanel(modelPanel)

		panel:AddControl("Label", { Text = "" })


		local cbox = {}
		cbox.Label = "Component Type"
		cbox.MenuButton = 0
		cbox.Options = {}
		cbox.Options.Screen = { starfall_component_Type = 1 }
		cbox.Options.HUD = { starfall_component_Type = 2 }
		panel:AddControl("ComboBox", cbox)

	end
end
