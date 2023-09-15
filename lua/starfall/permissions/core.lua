---------------------------------------------------------------------
-- SF Permissions management
---------------------------------------------------------------------

SF.Permissions = {}

local P = SF.Permissions
P.privileges = {}
P.providers = {}
P.settings = setmetatable({},{__index = function(t,k) local r={} t[k]=r return r end})
P.filename = SERVER and "sf_perms2_sv.txt" or "sf_perms2_cl.txt"


local Privilege = {
	__index = {
		buildcheck = function(self)
			local checks = {}
			local allAllow = true
			local anyBlock = false
			local overridable = false
			for providerid in pairs(self.providerconfig) do
				local provider = P.providers[providerid]
				local check = provider.checks[P.settings[self.id][providerid]]
				if provider.overridable then overridable = true end
				if check == "block" then
					if overridable then
						checks[#checks+1] = function() return false, "This function's permission is blocked!" end
					else
						allAllow = false
						anyBlock = true
						break
					end
				elseif check ~= "allow" then
					allAllow = false
					checks[#checks+1] = check
				end
			end

			if allAllow then
				self.check = function() return true end
			elseif anyBlock then
				self.check = function() return false, "This function's permission is blocked!" end
			elseif #checks==0 then
				allAllow = true
				self.check = function() return true end
			elseif #checks==1 then
				self.check = checks[1]
			else
				self.check = function(instance, target)
					for k, v in ipairs(checks) do
						local ok, reason = v(instance, target)
						if not ok then return false, reason end
					end
					return true
				end
			end

			if overridable and not allAllow then
				local check = self.check
				self.check = function(instance, target)
					if instance.permissionOverrides[self.id] then return true end
					return check(instance, target)
				end
			end
			self.overridable = overridable

		end,
		applySetting = function(self, providerid, setting)
			P.settings[self.id][providerid] = setting
			P.savePermissions()
			self:buildcheck()
		end,
		initSettings = function(self)
			for providerid, config in pairs(self.providerconfig) do
				if not P.settings[self.id][providerid] then
					P.settings[self.id][providerid] = config.default or P.providers[providerid].defaultsetting
				end
			end
			self:buildcheck()
		end,
	},
	__call = function(p, id, name, description, providerconfig)
		if not providerconfig then providerconfig = {} end
		if not providerconfig.usergroups then providerconfig.usergroups = {} end

		for providerid in pairs(providerconfig) do
			if not P.providers[providerid] then
				providerconfig[providerid] = nil
			end
		end

		return setmetatable({
			id = id,
			name = name,
			description = description,
			providerconfig = providerconfig
		}, p)
	end
}
setmetatable(Privilege, Privilege)

function P.registerProvider(provider)
	P.providers[provider.id] = provider
end

function P.registerPrivilege(id, name, description, providerconfig)
	P.privileges[id] = Privilege(id, name, description, providerconfig)
end

function P.check(instance, target, key)
	local ok, reason = P.privileges[key].check(instance, target)
	if not ok then SF.Throw("Permission " .. key .. ": " .. reason, 3) end
end

function P.hasAccess(instance, target, key)
	return P.privileges[key].check(instance, target)
end

function P.refreshSettingsCache()
	for providerid, provider in pairs(P.providers) do
		local settings = {}
		for privilegeid, privilege in pairs(P.privileges) do
			if privilege.providerconfig[providerid] then -- Check if this current provider manages privilege
				settings[privilegeid] = { privilege.name, privilege.description, P.settings[privilegeid][providerid] }
			end
		end
		provider.settings = settings
	end
end

local invalidators = {
	[1669008186] = { -- Nov 21, 2022
		message = "HTTP's URL whitelisting was misconfigured, and set by default to Disabled",
		realm = CLIENT,
		invalidate = {"http.get", "http.post"},
		check = function()
			return P.settings["http.get"]["urlwhitelist"] == 2 or P.settings["http.post"]["urlwhitelist"] == 2
		end
	}
}

local printC = function(...) (SERVER and MsgC or chat.AddText)(Color(255, 255, 255), "[", Color(11, 147, 234), "Starfall", Color(255, 255, 255), "]: ", ...) if SERVER then MsgC("\n") end end

function P.savePermissions()
	file.Write(P.filename, util.TableToJSON(P.settings))
end

-- Load the permission settings for each provider
function P.loadPermissions()
	local saveSettings = not file.Exists(P.filename, "DATA")
	P.settings = setmetatable(util.JSONToTable(file.Read(P.filename) or "") or {}, getmetatable(P.settings))

	local settingsTime = file.Time(P.filename, "DATA") or math.huge
	for issueTime, issue in pairs(invalidators) do
		if settingsTime < issueTime and issue.realm and (issue.check == nil or issue.check()) then 
			printC("Your configuration has been modified due to a misconfiguration.")
			printC("Reason: " .. issue.message)
			printC("Changes: " .. table.concat(issue.invalidate, ", "))
			for _, v in ipairs(issue.invalidate) do
				saveSettings = true
				P.settings[v] = nil
			end
		end
	end

	for k, v in pairs(P.privileges) do
		v:initSettings()
	end

	if saveSettings then
		P.savePermissions()
	end
end

-- Find and include all provider files.
do
	local sv_dir = "starfall/permissions/providers_sv/"
	local sv_files = file.Find(sv_dir.."*.lua", "LUA")
	local sh_dir = "starfall/permissions/providers_sh/"
	local sh_files = file.Find(sh_dir.."*.lua", "LUA")
	local cl_dir = "starfall/permissions/providers_cl/"
	local cl_files = file.Find(cl_dir.."*.lua", "LUA")

	if SERVER then
		for _, file in pairs(sv_files) do
			include(sv_dir..file)
		end
		for _, file in pairs(sh_files) do
			AddCSLuaFile(sh_dir..file)
			include(sh_dir..file)
		end
		for _, file in pairs(cl_files) do
			AddCSLuaFile(cl_dir..file)
		end
	else
		for _, file in pairs(sh_files) do
			include(sh_dir..file)
		end
		for _, file in pairs(cl_files) do
			include(cl_dir..file)
		end
	end
end

local function changePermission(ply, arg)
	if arg[1] then
		local privilege = P.privileges[arg[1]]
		if privilege then
			if arg[2] and privilege.providerconfig[arg[2]] then
				local val = tonumber(arg[3])
				if val and val>=1 and val<=#P.providers[arg[2]].settingsoptions then
					privilege:applySetting(arg[2], math.floor(val))
				else
					ply:PrintMessage(HUD_PRINTCONSOLE, "The setting's value is out of bounds or not a number.\n")
				end
			else
				ply:PrintMessage(HUD_PRINTCONSOLE, "Permission, " .. tostring(arg[2]) .. ", couldn't be found.\nHere's a list of permissions.\n")
				for id, _ in pairs(privilege.providerconfig) do ply:PrintMessage(HUD_PRINTCONSOLE, id.."\n") end
			end
		else
			ply:PrintMessage(HUD_PRINTCONSOLE, "Privilege, " .. tostring(arg[1]) .. ", couldn't be found.\nHere's a list of privileges.\n")
			for id, _ in SortedPairs(P.privileges) do ply:PrintMessage(HUD_PRINTCONSOLE, id.."\n") end
		end
	else
		ply:PrintMessage(HUD_PRINTCONSOLE, "Usage: sf_permission <privilege> <permission> <value>.\n")
	end
end

-- Console commands for changing permissions.
if SERVER then
	concommand.Add("sf_permission", function(ply, com, arg)
		if ply:IsValid() and not ply:IsSuperAdmin() then return end
		changePermission(ply, arg)
	end)
else
	concommand.Add("sf_permission_cl", function(ply, com, arg)
		changePermission(ply, arg)
	end)
end

-- Networking for administrators to get the server's settings
if SERVER then
	util.AddNetworkString("sf_permissionsettings")
	net.Receive("sf_permissionsettings", function(len, ply)
		if ply:IsSuperAdmin() then
			P.refreshSettingsCache () -- Refresh cache first
			net.Start("sf_permissionsettings")

			net.WriteUInt(table.Count(P.providers), 8)
			for _, v in pairs(P.providers) do
				net.WriteString(v.id)
				net.WriteString(v.name)
				net.WriteUInt(#v.settingsoptions, 8)
				for _, option in pairs(v.settingsoptions) do
					net.WriteString(option)
				end
				net.WriteUInt(table.Count(v.settings), 8)
				for privid, setting in pairs(v.settings) do
					net.WriteString(privid)
					net.WriteString(setting[1])
					net.WriteString(setting[2])
					net.WriteUInt(setting[3], 8)
				end
			end

			net.Send(ply)
		end
	end)
else
	local reqCallback, reqTimeout
	function P.requestPermissions(callback)
		if not reqCallback or (reqTimeout and reqTimeout<CurTime()) then
			reqCallback = callback
			reqTimeout = CurTime() + 2
			net.Start("sf_permissionsettings")
			net.SendToServer()
		end
	end
	function P.permissionRequestSatisfied( instance )
		if not instance.permissionRequest then
			SF.Throw( 'There is no permission request' )
		end
		for id, _ in pairs( instance.permissionRequest.overrides ) do
			if not instance.permissionOverrides[ id ] then return false end
		end
		return true
	end
	net.Receive("sf_permissionsettings", function()
		if reqCallback then
			local providers = {}
			local nproviders = net.ReadUInt(8)
			for i = 1, nproviders do
				local provider = {
					id = net.ReadString(),
					name = net.ReadString(),
					settings = {},
					settingsoptions = {}
				}
				local noptions = net.ReadUInt(8)
				for j = 1, noptions do
					provider.settingsoptions[j] = net.ReadString()
				end
				local nsettings = net.ReadUInt(8)
				for j = 1, nsettings do
					provider.settings[net.ReadString()] = { net.ReadString(), net.ReadString(), net.ReadUInt(8) }
				end
				providers[provider.id] = provider
			end
			reqCallback(providers)
			reqCallback = nil
			reqTimeout = nil
		end
	end)
end
