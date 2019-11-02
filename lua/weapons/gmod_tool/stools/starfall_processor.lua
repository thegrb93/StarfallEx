TOOL.Category		= "Chips, Gates"
TOOL.Name			= "Starfall - Processor"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.Tab			= "Wire"

-- ------------------------------- Sending / Receiving ------------------------------- --

local MakeSF

TOOL.ClientConVar["Model"] = "models/spacecode/sfchip.mdl"
TOOL.ClientConVar["ScriptModel"] = ""
TOOL.ClientConVar["parent"] = "1"
cleanup.Register("starfall_processor")

if SERVER then
	CreateConVar('sbox_maxstarfall_processor', 20, { FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE })

	util.AddNetworkString("starfall_openeditor")
	util.AddNetworkString("starfall_openeditorcode")

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
	end)

	net.Receive("starfall_openeditorcode", function(len)
		SF.Editor.open()

		net.ReadStarfall(nil, function(sfdata)
			if sfdata then
				local function openfiles()
					local mainfile = sfdata.files[sfdata.mainfile]
					sfdata.files[sfdata.mainfile] = nil
					for filename, code in pairs(sfdata.files) do
						SF.Editor.openWithCode(filename, code)
					end
					-- Add mainfile last so it gets focus
					SF.Editor.openWithCode(sfdata.mainfile, mainfile)
				end

				if SF.Editor.initialized then
					openfiles()
				else
					hook.Add("Think", "SFWaitForEditor", function()
						if SF.Editor.initialized then
							openfiles()
							hook.Remove("Think", "SFWaitForEditor")
						end
					end)
				end
			else
				SF.AddNotify(LocalPlayer(), "Error downloading SF code.", "ERROR", 7, "ERROR1")
			end
		end)

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
				SF.SendStarfall("starfall_openeditorcode", ent, ply)
			end
		else
			net.Start("starfall_openeditor") net.Send(ply)
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
	
	--[[	TODO
		
			for editor script:
		- display @name directive instead of filepath
		- display realm
		
			for instance chip:
		- display name, authros, ops
		
		- better particles
		- search for a good font, mb starfall already has some good ones
		- mb turn off world tooltip for sf chips, optional turned off by default tho
		- convar to disable custom screen
		- loads of optimization
		
	]]--
	
	surface.CreateFont("StarfallToolTitle", {
		font = "Arial",
		extended = false,
		size = 64,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	})
	
	surface.CreateFont("StarfallToolSmall", {
		font = "Arial",
		extended = false,
		size = 35,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	})
	
	local colors = {
		bg = Color(33,33,33, 50),
		fg = Color(255,255,255),
		sf = Color(20,100,255),
		sv = Color(0,161,255),
		cl = Color(255,191,0),
	}
	
	
	local star_mat = Material("radon/starfall2")
	local star_count = 8
	local starflakes = {}
	
	local function getRandomFlake(id, prvVel, fromBottom)
		return {
			y = fromBottom and math.random(255+30,255+60) or math.random(-30,-60),
			--x = 235/star_count*id,
			x = 255 / star_count * id,
			xvel = (prvVel or 0) * 0.3 + math.Rand(-0.1,0.1),
			yvel = math.Rand(0.5,1) * (fromBottom and -1 or 1),
			ang = math.Rand(0.5, 1),
			angvel = math.Rand(0.5, 1),
			size = math.random(50,80),
			color = Color(math.random(0,40), math.random(120,190), math.random(200,255)),
		}
	end
	
	for i = 1, star_count do
		local flake = getRandomFlake(i)
		starflakes[i] = flake
	end
	
	local prvEyeYaw = 0
	
	local sfToolMat = nil
	local sfToolRt = nill
	
	local fileData = nil
	local function updateFileData()
		
		local path = SF.Editor.getOpenFile()
		if not path then return end
		
		local file = file.Read("starfall/"..path, "DATA")
		if not file then return end
		
		local ppdata = {}
		SF.Preprocessor.ParseDirectives("v", file, ppdata)
		
		fileData = {
			name   = ppdata.scriptnames.v,
			author = ppdata.scriptauthors.v,
			realm  = ppdata.serverorclient.v or "shared"
		}
		
	end
	
	
	updateFileData()
	PrintTable(fileData)
	
	
	function TOOL:DrawToolScreen(w, h)
		
		if not sfToolMat then
			sfToolRt = GetRenderTarget( "sf_tool_rt", w, h) 
			sfToolMat = CreateMaterial( "sf_tool_mat", "UnlitGeneric", {
				["$basetexture"] = sfToolRt:GetName(),
				["$translucent"] = 1,
				["$vertexcolor"] = 1
			} )
		end

		render.PushRenderTarget(sfToolRt)
		cam.Start2D()
			
			-- SF.Editor not valid at start of the game
			--local filename = SF.Editor.getOpenFile() or "main"
			
			local ply = self:GetOwner()
			
			-- shake particles based on view yaw rotation
			local eyeAng = ply:EyeAngles().y
			local eyeYawVel = (((eyeAng - prvEyeYaw) % 360 ) + 360 ) % 360
			if eyeYawVel > 180 then eyeYawVel = eyeYawVel - 360 end
			prvEyeYaw = eyeAng
			
			-- shake particles based on left/right velocity
			self.velY = self.velY or 0
			local vel = ply:WorldToLocal(ply:GetPos() + ply:GetVelocity())
			local velY = vel.y
			local velX = vel.x / 10000
			
			-- cover the default texture
			surface.SetDrawColor(colors.bg)
			surface.DrawRect(0,0,w,h)
			
			-- render the particles
			surface.SetMaterial(star_mat)
			for i = 1, star_count do
				
				local flake = starflakes[i]
				
				flake.yvel = flake.yvel + velX
				flake.xvel = flake.xvel + eyeYawVel/30 + velY/6000
				
				flake.x = flake.x + flake.xvel
				flake.y = flake.y + flake.yvel
				flake.ang = flake.ang + flake.angvel
				
				flake.angvel = flake.angvel + flake.xvel / 1000

				local flakeAlpha = 255+60-flake.y
				
				if flakeAlpha <= 0 or flake.y < -60 then
					starflakes[i] = getRandomFlake(i, flake.xvel, flake.y < -60)
				elseif flake.x < -30 then
					flake.x = w + 30
				elseif flake.x > w + 30 then
					flake.x = -30
				end
				
				surface.SetDrawColor(flake.color.r, flake.color.g, flake.color.b, flakeAlpha)
				surface.DrawTexturedRectRotated(flake.x, flake.y, flake.size, flake.size, flake.ang)
				
			end
			
			
			draw.SimpleTextOutlined("Starfall", "StarfallToolTitle", w/2, 40, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 4, colors.bg)
			
			local ent = ply:GetEyeTraceNoCursor().Entity
			
			if ent and ent:IsValid() and ent:GetClass() == "starfall_processor" and ent.instance then
				
				-- this will return nil sometimes, find out why
				--draw.SimpleTextOutlined(ent.instance.ppdata.scriptnames.main, "StarfallToolSmall", w/2, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 4, colors.bg)
				
			elseif SF.Editor then
				
				--draw.SimpleTextOutlined(SF.Editor.getOpenFile() or "main", "StarfallToolSmall", w/2, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 4, colors.bg)
				
			end
			--[[
				ppdata:
			scriptauthors:
					main	=	
			scriptnames:
					main	=	Cipeczka
			]]
		cam.End2D()
		render.PopRenderTarget()
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( sfToolMat )
		surface.DrawTexturedRect( 0, 0, w, h )
	
	end
	
	
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
