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

local getfiledata = {}

net.Receive("starfall_getcache", function()
	local files = {}
	local filecount = 0
	local chip = net.ReadEntity()
	local owner = net.ReadEntity()
	local mainfile = net.ReadString()

	if not getfiledata[chip] then return end

	while net.ReadBit() == 1 and filecount < 256 do
		local filename = net.ReadString()
		filecount = filecount + 1

		net.ReadStream(nil, function(code)
			files[filename] = code

			if table.Count(files) == filecount then
				if chip:IsValid() and getfiledata[chip] then
					getfiledata[chip](files, mainfile, owner)
				end

				getfiledata[chip] = nil
			end
		end)
	end
end)

function getFilesFromChip(chip, callback)
	getfiledata[chip] = callback
	excludeFiles = excludeFiles or {}

	net.Start("starfall_reqcache")
	net.WriteEntity(chip)
	net.SendToServer()
end

function ENT:Compile(owner, files, mainfile)
	if self.instance then
		self.instance:runScriptHook("removed")
		self.instance:deinitialize()
		self.instance = nil
	end

	if SERVER then
		self.skipCache = self.skipCache or setmetatable({}, {__mode = "k"})
	end

	-- PrintTable(table.GetKeys(files))

	local useCache, skipCache, newChecksum = false, false, nil
	local update = self.mainfile ~= nil

	self.error = nil
	self.mainfile = mainfile
	self.files = self.files or {}
	self.owner = owner

	owner.sf_cache = owner.sf_cache or {}

	for filename, code in pairs(files) do
		if code == "-removed-" then
			self.files[filename] = nil
		elseif filename == "*use-cache*" then
			self.files[filename] = nil
			newChecksum = code
			useCache = true
		else
			self.files[filename] = code
		end

		owner.sf_cache[filename] = self.files[filename]
	end

	if useCache then
		self.files = table.Merge(self.files, owner.sf_cache)

		if SERVER then -- Validate cache serverside
			for i, ply in ipairs(player.GetAll()) do
				self.skipCache[ply] = false

				if not ply.sf_latest_files[owner] then
					self.skipCache[ply] = true
				else
					local cache = ply.sf_latest_files[owner]

					if not cache then
						self.skipCache[ply] = true
					else
						for filename, code in pairs(self.files) do
							if cache[filename] ~= code then
								self.skipCache[ply] = true
								break
							end
						end
					end
				end
			end

			owner.sf_cache = table.Copy(self.files)
		end

		if CLIENT then -- Validate cache clientside
			if owner.sf_latest_chip == self then
				owner.sf_cache_id = newChecksum
				owner.sf_cache = table.Copy(self.files)
			end

			local cacheIsUpToDate = owner.sf_cache_id == newChecksum

			if not cacheIsUpToDate then
				self.files = nil
				owner.sf_cache = nil

				getFilesFromChip(self, function(cache)
					owner.sf_cache_id = newChecksum
					self:Compile(owner, cache, mainfile)
				end)
				return
			end
		end
	elseif SERVER then
		for i, ply in ipairs(player.GetAll()) do
			self.skipCache[ply] = true
		end
	end

	if SERVER then
		owner.sf_latest_chip = self
		owner.sf_latest_upload = files

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

function getCodebaseChecksum(files)
	local checksum = 0

	for filename, code in pairs(files) do
		checksum = checksum + file.Time("starfall/" .. filename, "DATA") / 10000000
	end

	return tostring(checksum)
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
