TOOL.Category		= "Starfall"
TOOL.Name			= "Starfall - Processor"
TOOL.Command		= nil
TOOL.ConfigName		= ""

-- ------------------------------- Sending / Receiving ------------------------------- --

local MakeSF

TOOL.ClientConVar["Model"] = "models/spacecode/sfchip.mdl"
TOOL.ClientConVar["ScriptModel"] = ""
TOOL.ClientConVar["parent"] = "0"
cleanup.Register("starfall_processor")

if SERVER then
	CreateConVar('sbox_maxstarfall_processor', 20, { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE })

	util.AddNetworkString("starfall_openeditor")

	function MakeSF(pl, Pos, Ang, model, inputs, outputs)
		if not pl:CheckLimit("starfall_processor") then return false end

		local sf = ents.Create("starfall_processor")
		if not (sf and sf:IsValid()) then return false end

		sf:SetAngles(Ang)
		sf:SetPos(Pos)
		sf:SetModel(model)
		sf:Spawn()

		if WireLib and inputs and inputs[1] and inputs[2] then
			sf.Inputs = WireLib.AdjustSpecialInputs(sf, inputs[1], inputs[2])
		end
		if WireLib and outputs and outputs[1] and outputs[2] then
			-- Initialize wirelink and entity outputs if present
			for _, iname in pairs(outputs[1]) do
				if iname == "entity" then
					WireLib.CreateEntityOutput( nil, sf, {true} )
				elseif iname == "wirelink" then
					WireLib.CreateWirelinkOutput( nil, sf, {true} )
				end
			end

			sf.Outputs = WireLib.AdjustSpecialOutputs(sf, outputs[1], outputs[2])
		end

		pl:AddCount("starfall_processor", sf)
		pl:AddCleanup("starfall_processor", sf)

		return sf
	end
	duplicator.RegisterEntityClass("starfall_processor", MakeSF, "Pos", "Ang", "Model", "_inputs", "_outputs")
else
	language.Add("Tool.starfall_processor.name", "Starfall - Processor")
	language.Add("Tool.starfall_processor.desc", "Spawns a Starfall processor. (Press Shift+F to switch to the component tool)")
	language.Add("Tool.starfall_processor.left", "Spawn a processor / upload code")
	language.Add("Tool.starfall_processor.right", "Open editor")
	language.Add("Tool.starfall_processor.reload", "Update code without changing main file")
	language.Add("Tool.starfall_processor.parent", "Parent instead of Weld" )
	language.Add("sboxlimit_starfall_processor", "You've hit the Starfall processor limit!")
	language.Add("undone_Starfall Processor", "Undone Starfall Processor")
	language.Add("Cleanup_starfall_processor", "Starfall Processors")
	TOOL.Information = { "left", "right", "reload" }

	net.Receive("starfall_openeditor", function(len)
		SF.Editor.open()

		if net.ReadBool() then
			net.ReadStarfall(nil, function(ok, sfdata)
				if ok then
					local mainfile = sfdata.files[sfdata.mainfile]
					sfdata.files[sfdata.mainfile] = nil
					for filename, code in pairs(sfdata.files) do
						SF.Editor.openWithCode(filename, code, nil, true)
					end
					-- Add mainfile last so it gets focus
					SF.Editor.openWithCode(sfdata.mainfile, mainfile, nil, true)
				else
					SF.AddNotify(LocalPlayer(), "Error downloading SF code.", "ERROR", 7, "ERROR1")
				end
			end)
		end
	end)
end

function TOOL:LeftClick(trace)
	if not trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end

	local ply = self:GetOwner()

	local ent = trace.Entity
	local sf

	local function doWeld()
		if sf==ent then return end
		local ret
		if ent:IsValid() then
			if self:GetClientNumber( "parent", 0 ) != 0 then
				sf:SetParent(ent)
			else
				local const = constraint.Weld(sf, ent, 0, trace.PhysicsBone, 0, true, true)
				ret = const
			end
			local phys = sf:GetPhysicsObject()
			if phys:IsValid() then phys:EnableCollisions(false) sf.nocollide = true end
		else
			local phys = sf:GetPhysicsObject()
			if phys:IsValid() then phys:EnableMotion(false) end
		end
		return ret
	end

	if not SF.RequestCode(ply, function(sfdata)
		if not (sf and sf:IsValid()) then return end -- Probably removed during transfer
		sf:SetupFiles(sfdata)
	end) then
		SF.AddNotify(ply, "Cannot upload SF code, please wait for the current upload to finish.", "ERROR", 7, "ERROR1")
		return false
	end

	if ent:IsValid() and ent:GetClass() == "starfall_processor" then
		sf = ent
	else
		local model = self:GetClientInfo("Model")
		if not (util.IsValidModel(model) and util.IsValidProp(model)) then return false end
		if not self:GetSWEP():CheckLimit("starfall_processor") then return false end

		local Ang = trace.HitNormal:Angle()
		Ang.pitch = Ang.pitch + 90

		sf = MakeSF(ply, trace.HitPos, Ang, model)
		if not sf then return false end

		local min = sf:OBBMins()
		sf:SetPos(trace.HitPos - trace.HitNormal * min.z)
		local const = doWeld()

		undo.Create("Starfall Processor")
			undo.AddEntity(sf)
			undo.AddEntity(const)
			undo.SetPlayer(ply)
		undo.Finish()
	end

	return true
end

function TOOL:RightClick(trace)
	if SERVER then

		local ply = self:GetOwner()
		local ent = trace.Entity

		if ent and ent:IsValid() and ent:GetClass() == "starfall_processor" then
			if ent.mainfile then
				net.Start("starfall_openeditor")
				net.WriteBool(true)
				net.WriteStarfall(ent)
				net.Send(ply)
			end
		else
			net.Start("starfall_openeditor")
			net.WriteBool(false)
			net.Send(ply)
		end

	end
	return false
end

function TOOL:Reload(trace)
	if not trace.HitPos then return false end
	local ply = self:GetOwner()
	local sf = trace.Entity

	if sf:IsValid() and sf:GetClass() == "starfall_processor" and sf.mainfile then
		if CLIENT then return true end

		if not SF.RequestCode(ply, function(sfdata)
			if not sf:IsValid() then return end -- Probably removed during transfer
			sf:SetupFiles(sfdata)
		end, sf.mainfile) then
			SF.AddNotify(ply, "Cannot upload SF code, please wait for the current upload to finish.", "ERROR", 7, "ERROR1")
		end

		return true
	else
		return false
	end
end

function TOOL:DrawHUD()
end

function TOOL:Think()

	local model = self:GetClientInfo("ScriptModel")
	if model=="" then
		model = self:GetClientInfo("Model")
	end
	if not (self.GhostEntity and self.GhostEntity:IsValid()) or self.GhostEntity:GetModel() ~= model then
		self:MakeGhostEntity(model, Vector(0, 0, 0), Angle(0, 0, 0))
	end

	local trace = util.TraceLine(util.GetPlayerTrace(self:GetOwner()))
	if (not trace.Hit) then return end
	local ent = self.GhostEntity

	if not (ent and ent:IsValid()) then return end
	if (trace.Entity and trace.Entity:GetClass() == "starfall_processor" or trace.Entity:IsPlayer()) then

		ent:SetNoDraw(true)
		return

	end

	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90

	local min = ent:OBBMins()
	ent:SetPos(trace.HitPos - trace.HitNormal * min.z)
	ent:SetAngles(Ang)

	ent:SetNoDraw(false)

end

if CLIENT then

	local lastclick = CurTime()

	local function GotoDocs(button)
		gui.OpenURL(SF.Editor.HelperURL:GetString())
	end

	function TOOL.BuildCPanel(panel)
		panel:AddControl("Header", { Text = "#Tool.starfall_processor.name", Description = "#Tool.starfall_processor.desc" })
		panel:AddControl("CheckBox", { Label = "#Tool.starfall_processor.parent", Command = "starfall_processor_parent" } )

		local gateModels = list.Get("Starfall_gate_Models")
		table.Merge(gateModels, list.Get("Wire_gate_Models"))

		local modelPanel = vgui.Create("DPanelSelect", panel)
		modelPanel:EnableVerticalScrollbar()
		modelPanel:SetTall(66 * 5 + 2)
		for model, v in pairs(gateModels) do
			local icon = vgui.Create("SpawnIcon")
			icon:SetModel(model)
			icon.Model = model
			icon:SetSize(64, 64)
			icon:SetTooltip(model)
			modelPanel:AddPanel(icon, { ["starfall_processor_Model"] = model })
		end
		modelPanel:SortByMember("Model", false)
		panel:AddPanel(modelPanel)
		panel:AddControl("Label", { Text = "" })

		local docbutton = vgui.Create("DButton" , panel)
		panel:AddPanel(docbutton)
		docbutton:SetText("Starfall Documentation")
		docbutton.DoClick = GotoDocs

		local filebrowser = vgui.Create("StarfallFileBrowser")
		panel:AddPanel(filebrowser)
		filebrowser.tree:Setup("starfall")
		filebrowser:SetSize(235, 400)

		local lastClick = 0
		filebrowser.tree.DoClick = function(self, node)
			if CurTime() <= lastClick + 0.5 then
				SF.Editor.openFile(node:GetFileName())
			end
			lastClick = CurTime()
		end

		local openeditor = vgui.Create("DButton", panel)
		panel:AddPanel(openeditor)
		openeditor:SetText("Open Editor")
		openeditor.DoClick = SF.Editor.open
	end

	local function hookfunc(ply, bind, pressed)
		if not pressed then return end

		if bind == "impulse 100" and ply:KeyDown(IN_SPEED) then
			local activeWep = ply:GetActiveWeapon()
			if activeWep:IsValid() and activeWep:GetClass() == "gmod_tool" then
				if activeWep.Mode == "starfall_processor" then
					spawnmenu.ActivateTool("starfall_component")
					return true
				elseif activeWep.Mode == "starfall_component" then
					spawnmenu.ActivateTool("starfall_processor")
					return true
				end
			end
		end
	end

	if game.SinglePlayer() then -- wtfgarry (have to have a delay in single player or the hook won't get added)
		timer.Simple(5, function() hook.Add("PlayerBindPress", "sf_toolswitch", hookfunc) end)
	else
		hook.Add("PlayerBindPress", "sf_toolswitch", hookfunc)
	end
end
