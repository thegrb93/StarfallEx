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
		if pl and not pl:CheckLimit("starfall_processor") then return false end

		local sf = ents.Create("starfall_processor")
		if not (sf and sf:IsValid()) then return false end
		if not (util.IsValidModel(model) and util.IsValidProp(model)) then model = "models/spacecode/sfchip.mdl" end

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

		if pl then
			pl:AddCount("starfall_processor", sf)
			pl:AddCleanup("starfall_processor", sf)
		end

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
			net.ReadStarfall(nil, function(ok, sfdata, err)
				if ok then
					local mainfile = sfdata.files[sfdata.mainfile]
					sfdata.files[sfdata.mainfile] = nil
					for filename, code in pairs(sfdata.files) do
						SF.Editor.openWithCode(filename, code, nil, true)
					end
					-- Add mainfile last so it gets focus
					SF.Editor.openWithCode(sfdata.mainfile, mainfile, nil, false)
				else
					SF.AddNotify(LocalPlayer(), "Error downloading SF code. (" .. err .. ")", "ERROR", 7, "ERROR1")
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
			if self:GetClientNumber( "parent", 0 ) ~= 0 then
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
		sf:Compile(sfdata)
	end) then
		SF.AddNotify(ply, "Cannot upload SF code, please wait for the current upload to finish.", "ERROR", 7, "ERROR1")
		return false
	end

	if ent:IsValid() and ent:GetClass() == "starfall_processor" then
		sf = ent
	else
		local model = self:GetClientInfo("ScriptModel")
		if model == "" then
			model = self:GetClientInfo("Model")
		end
		if not pcall(SF.CheckModel, model, ply, true) then
			SF.AddNotify(ply, "Invalid chip model specified: " .. model, "ERROR", 7, "ERROR1")
			return false
		end
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
	return false
end

function TOOL:Reload(trace)
	if not trace.HitPos then return false end
	local ply = self:GetOwner()
	local sf = trace.Entity

	if sf:IsValid() and sf:GetClass() == "starfall_processor" and sf.sfdata then
		if CLIENT then return true end

		if not SF.RequestCode(ply, function(sfdata)
			if not sf:IsValid() then return end -- Probably removed during transfer
			sf:Compile(sfdata)
		end, sf.sfdata.mainfile) then
			SF.AddNotify(ply, "Cannot upload SF code, please wait for the current upload to finish.", "ERROR", 7, "ERROR1")
		end

		return true
	else
		return false
	end
end

function TOOL:DrawHUD()
end

function TOOL:OpenEditor(ply, ent)
	if ent then
		if ent.sfdata then
			net.Start("starfall_openeditor")
			net.WriteBool(true)
			net.WriteStarfall(ent.sfdata)
			net.Send(ply)
		end
	else
		net.Start("starfall_openeditor")
		net.WriteBool(false)
		net.Send(ply)
	end
end

function TOOL:Think()
	local ply = self:GetOwner()
	local trace = ply:GetEyeTrace()
	local ent = trace.Entity

	-- Ghost code
	if (SERVER and game.SinglePlayer()) or (CLIENT and not game.SinglePlayer()) then
		local model = self:GetClientInfo("ScriptModel")
		if model == "" then
			model = self:GetClientInfo("Model")
		end

		local ghost = self.GhostEntity
		if not (ghost and ghost:IsValid() and ghost:GetModel() == model) then
			self:MakeGhostEntity(model, Vector(0, 0, 0), Angle(0, 0, 0))
			ghost = self.GhostEntity
		end

		if ghost and ghost:IsValid() then
			if (ent:IsValid() and ent:GetClass() == "starfall_processor" or ent:IsPlayer()) then
				ghost:SetNoDraw(true)
			elseif trace.Hit then
				local Ang = trace.HitNormal:Angle()
				Ang.pitch = Ang.pitch + 90

				local min = ghost:OBBMins()
				ghost:SetPos(trace.HitPos - trace.HitNormal * min.z)
				ghost:SetAngles(Ang)
				ghost:SetNoDraw(false)
			end
		end
	end

	if SERVER then
		if ply:KeyPressed(IN_ATTACK2) then
			if not self.OpenedEditor then
				if ent:IsValid() and ent:GetClass() == "starfall_processor" then
					if gamemode.Call("CanTool", ply, trace, self.Mode, self, 2)~=false then
						self:OpenEditor(ply, ent)
					end
				else
					self:OpenEditor(ply)
				end
				self.OpenedEditor = true
			end
		else
			self.OpenedEditor = nil
		end
	end
end

if CLIENT then

	function TOOL:DrawStarfallToolScreen(w, h)
		local ent = LocalPlayer():GetEyeTrace().Entity
		local script_name
		if ent and ent:IsValid() and ent:GetClass() == "starfall_processor" then
			if ent.error then
				script_name = "< clientside errored >"
			elseif ent:GetNWInt("State", 1) == 2 then
				script_name = "< serverside errored >"
			else
				script_name = ent.name or "Generic"
			end
		elseif SF.Editor.editor then
			script_name = SF.Editor.editor:GetActiveTab():GetText()
		end
		SF.DrawToolgunScreen(w, h, "PROCESSOR", script_name)
	end
	local custom_toolscreen_convar = GetConVar("starfall_toolscreen")
	if custom_toolscreen_convar and custom_toolscreen_convar:GetBool() then
		TOOL.DrawToolScreen = TOOL.DrawStarfallToolScreen
	end

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
