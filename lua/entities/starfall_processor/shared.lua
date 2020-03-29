ENT.Type            = "anim"
ENT.Base            = "base_gmodentity"

ENT.PrintName       = "Starfall"
ENT.Author          = "Colonel Thirty Two"
ENT.Contact         = "initrd.gz@gmail.com"
ENT.Purpose         = ""
ENT.Instructions    = ""

ENT.Spawnable       = false

ENT.Starfall        = true
ENT.States          = {
	Normal = 1,
	Error = 2,
	None = 3,
}


function ENT:Compile()
	if self.instance then
		self:Destroy()
	end

	self.error = nil

	if not (self.mainfile and self.files and self.files[self.mainfile]) then return end
	local ok, instance = SF.Instance.Compile(self.files, self.mainfile, self.owner, { entity = self })
	if not ok then self:Error(instance) return end

	if instance.ppdata.scriptnames and instance.mainfile and instance.ppdata.scriptnames[instance.mainfile] then
		self.name = string.sub(tostring(instance.ppdata.scriptnames[instance.mainfile]), 1, 64)
	else
		self.name = "Generic ( No-Name )"
	end

	if instance.ppdata.scriptauthors and instance.mainfile and instance.ppdata.scriptauthors[instance.mainfile] then
		self.author = string.sub(tostring(instance.ppdata.scriptauthors[instance.mainfile]), 1, 64)
	else
		self.author = nil
	end


	self.instance = instance
	instance.runOnError = function(err)
		-- Have to make sure it's valid because the chip can be deleted before deinitialization and trigger errors
		if self:IsValid() then
			self:Error(err)
		end
	end

	local ok, msg, traceback = instance:initialize()
	if not ok then return end

	if SERVER then
		self.ErroredPlayers = {}
		local clr = self:GetColor()
		self:SetColor(Color(255, 255, 255, clr.a))
		self:SetNWInt("State", self.States.Normal)

		if self.Inputs then
			for k, v in pairs(self.Inputs) do
				self:TriggerInput(k, v.Value)
			end
		end
	end
end

function ENT:Destroy()
	if self.instance then
		self.instance:runScriptHook("removed")
		--removed hook can cause instance to become nil
		if self.instance then
			self.instance:deinitialize()
			self.instance = nil
		end
	end
end

function ENT:SetupFiles(sfdata)
	if SERVER and update then
		net.Start("starfall_processor_destroy")
		net.WriteEntity(self)
		net.Broadcast()
	end

	self.owner = sfdata.owner
	self.files = sfdata.files
	self.mainfile = sfdata.mainfile

	self:Compile()

	if SERVER then
		if self.instance and self.instance.ppdata.models and self.instance.mainfile then
			local model = self.instance.ppdata.models[self.instance.mainfile]
			if util.IsValidModel(model) and util.IsValidProp(model) then
				self:SetCustomModel(model)
			end
		end

		self:SendCode()
	end
end

function ENT:GetGateName()
	return self.name
end

function ENT:Error(err)
	self.error = err

	local msg = err.message
	local traceback = err.traceback

	if SERVER then
		self:SetNWInt("State", self.States.Error)
		self:SetColor(Color(255, 0, 0, 255))
		self:SetDTString(0, traceback or msg)
	end

	local newline = string.find(msg, "\n")
	if newline then
		msg = string.sub(msg, 1, newline - 1)
	end
	SF.AddNotify(self.owner, msg, "ERROR", 7, "ERROR1")

	if self.instance then
		self.instance:deinitialize()
		self.instance = nil
	end

	if SERVER then
		SF.Print(self.owner, traceback)
	else
		print(traceback)

		if self.owner ~= LocalPlayer() and GetConVarNumber("sf_timebuffer_cl")>0 then
			net.Start("starfall_report_error")
			net.WriteEntity(self)
			net.WriteString(msg.."\n"..traceback)
			net.SendToServer()
		end
	end
	
	for inst, _ in pairs(SF.allInstances) do
		inst:runScriptHook("starfallerror", inst.Types.Entity.Wrap(self), inst.Types.Player.Wrap(SERVER and self.owner or LocalPlayer()), msg)
	end
end

local function MenuOpen( ContextMenu, Option, Entity, Trace )
	local ent = Entity
	if Entity:GetClass() == 'starfall_screen' or Entity:GetClass() == "starfall_hud" then
		if not ent.link then return end
		ent = ent.link
	end
	local SubMenu = Option:AddSubMenu()
	SubMenu:AddOption("Restart Clientside", function ()
		ent:Compile()
	end)
	SubMenu:AddOption("Terminate Clientside", function ()
		ent:Error({message = "Terminated", traceback = ""})
	end)
	SubMenu:AddOption("Open Global Permissions", function ()
		SF.Editor.openPermissionsPopup()
	end)
	if ent.instance then
		if ent.instance.permissionRequest and ent.instance.permissionRequest.overrides and table.Count(ent.instance.permissionRequest.overrides) > 0
				or ent.instance.permissionOverrides and table.Count(ent.instance.permissionOverrides) > 0 then
			SubMenu:AddOption("Overriding Permissions", function ()
				local pnl = vgui.Create("SFChipPermissions")
				if pnl then pnl:OpenForChip(ent) end
			end)
		end
	end
end

properties.Add( "starfall", {
	MenuLabel = "StarfallEx",
	Order = 999,
	MenuIcon = "icon16/wrench.png", -- We should create an icon
	Filter = function( self, ent, ply )
		if not (ent and ent:IsValid()) then return false end
		if not gamemode.Call( "CanProperty", ply, "starfall", ent ) then return false end
		return ent.Starfall or ent.link and ent.link.Starfall
	end,
	MenuOpen = MenuOpen,
	Action = function ( self, ent ) end
} )
