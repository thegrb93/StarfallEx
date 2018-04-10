ENT.Type            = "anim"
ENT.Base            = "base_gmodentity"

ENT.PrintName       = "Starfall"
ENT.Author          = "Colonel Thirty Two"
ENT.Contact         = "initrd.gz@gmail.com"
ENT.Purpose         = ""
ENT.Instructions    = ""

ENT.Spawnable       = false
ENT.AdminSpawnable  = false

ENT.Starfall        = true
ENT.States          = {
	Normal = 1,
	Error = 2,
	None = 3,
}

local getcachedata = {}

net.Receive("starfall_getcache", function()
	local cache = {}
	local filecount = 0
	local ply = net.ReadEntity()

	if not getcachedata[ply] then return end

	while net.ReadBit() == 1 and filecount < 256 do
		local filename = net.ReadString()
		filecount = filecount + 1

		net.ReadStream(nil, function(code)
			cache[filename] = code

			if #table.GetKeys(cache) == filecount then
				if ply:IsValid() and getcachedata[ply] then
					getcachedata[ply](cache)
				end

				getcachedata[ply] = nil
			end
		end)
	end
end)

local function getCacheOfPlayer(ply, callback)
	getcachedata[ply] = callback

	net.Start("starfall_reqcache")
	net.WriteEntity(ply)
	net.SendToServer()
end

function ENT:Compile(owner, files, mainfile)
	if self.instance then
		self.instance:runScriptHook("removed")
		self.instance:deinitialize()
		self.instance = nil
	end

	local useCache = false
	local update = self.mainfile ~= nil
	self.error = nil
	self.mainfile = mainfile
	self.files = self.files or {}
	self.owner = owner
	owner.sf_cache = owner.sf_cache or {}
	owner.sf_cache_first = owner.sf_cache_first == nil and true

	for filename, code in pairs(files) do
		if code == "-removed-" then
			self.files[filename] = nil
		elseif filename == "*use-cache*" then
			self.files[filename] = nil
			self.owner.sf_cache_ver = code
			self.cache_ver = code
			useCache = true
		else
			self.files[filename] = code
		end

		owner.sf_cache[filename] = self.files[filename]
	end

	if useCache then
		self.files = table.Merge(owner.sf_cache, self.files)

		if CLIENT and #table.GetKeys(owner.sf_cache) == 0 then
			getCacheOfPlayer(owner, function(cache)
				owner.sf_cache_first = false
				owner.sf_cache = cache

				self:Compile(owner, cache, mainfile)
			end)

			net.SendToServer()
			return
		end
	end

	if SERVER then
		if update then
			self:SendCode(files)
		elseif self.SendQueue then
			self:SendCode(files, self.SendQueue)
			self.SendQueue = nil
		end
	end

	local ok, instance = SF.Instance.Compile(self.files, mainfile, owner, { entity = self })
	if not ok then self:Error(instance) return end

	if instance.ppdata.scriptnames and instance.mainfile and instance.ppdata.scriptnames[instance.mainfile] then
		self.name = tostring(instance.ppdata.scriptnames[instance.mainfile])
	end

	self.instance = instance
	instance.runOnError = function(inst, ...)
		-- Have to make sure it's valid because the chip can be deleted before deinitialization and trigger errors
		if self:IsValid() then
			self:Error(...)
		end
	end
	instance.data.userdata = self.starfalluserdata
	self.starfalluserdata = nil

	local ok, msg, traceback = instance:initialize()
	if not ok then return end

	if SERVER then
		local clr = self:GetColor()
		self:SetColor(Color(255, 255, 255, clr.a))
		self:SetNWInt("State", self.States.Normal)

		if self.Inputs then
			for k, v in pairs(self.Inputs) do
				self:TriggerInput(k, v.Value)
			end
		end
	end

	--TriggerInput can cause self.instance to become nil
	if self.instance then
		self.instance:runScriptHook("initialize")
	end
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
		print(msg)
		print(traceback)
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
		ent:Restart()
	end)
	SubMenu:AddOption("Terminate Clientside", function ()
		ent:Terminate()
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
		if not IsValid( ent ) then return false end
		if not gamemode.Call( "CanProperty", ply, "starfall", ent ) then return false end
		return ent.Starfall or ent.link and ent.link.Starfall
	end,
	MenuOpen = MenuOpen,
	Action = function ( self, ent ) end
} )
