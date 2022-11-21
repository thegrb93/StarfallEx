---------------------------------------------------------------------
-- SF Permissions management
---------------------------------------------------------------------

SF.Permissions = {}

local P = SF.Permissions
P.privileges = {}
P.providers = {}
P.permissionchecks = {}
P.filename = SERVER and "sf_perms2_sv.txt" or "sf_perms2_cl.txt"

--- Adds a provider implementation to the set used by this library.
-- Providers must implement the {@link SF.Permissions.Provider} interface.
-- @param provider the provider to be registered
function P.registerProvider(provider)
	P.providers[provider.id] = provider
end

--- Refreshes cache of settings in provider
function P.refreshSettingsCache()
	for i, provider in pairs(P.providers) do
		local settings = {}

		for id, privilege in pairs(P.privileges) do
			if privilege[3][i] then -- Check if this current provider manages privilege
				settings[id] = { privilege[1], privilege[2], privilege[3][i].setting } -- Name, Description, Current Setting
			end
		end
		provider.settings = settings
	end
end

--- Adds a provider which will be used on specified permissions. (Meant for outside addons)
-- Providers must implement the {@link SF.Permissions.Provider} interface.
-- @param provider the provider to be registered
-- @param privileges table of privs this provider will be added to
-- @param exclusive if true, this provider will replace all existing providers for the privilege. (Addons loaded later may add aditional providers)
function P.registerCustomProvider(provider, privileges, exclusive)
	P.providers[provider.id] = provider
	for k,v in pairs(privileges) do
		if exclusive then
			P.privileges[v][3] = {}
		end
		P.privileges[v][3][provider.id] = {default = provider.defaultsetting}
	end
end

--- Registers a privilege
-- @param id unique identifier of the privilege being registered
-- @param name Human readable name of the privilege
-- @param description a short description of the privilege
function P.registerPrivilege(id, name, description, arg)
	arg = arg or {}
	--All privileges should get usergroup
	if not arg.usergroups then
		arg.usergroups = {}
	end

	P.privileges[id] = {name, description, arg}
end

--- Checks whether a player may perform an action. Throws an error if not allowed
-- @param instance The instance checking permission
-- @param target the object on which the action is being performed
-- @param key a string identifying the action being performed
function P.check(instance, target, key)
	if not (instance.permissionOverrides and instance.permissionOverrides[key]) then
		local notok, reason = P.permissionchecks[key](instance, target)
		if notok then
			SF.Throw("Permission " .. key .. ": " .. reason, 3)
		end
	end
end

--- Checks whether a player may perform an action.
-- @param instance The instance checking permission
-- @param target the object on which the action is being performed
-- @param key a string identifying the action being performed
-- @return boolean Whether the player may perform the action
-- @return string? Reason for action to not be allowed, or nil if it is allowed
function P.hasAccess(instance, target, key)
	if (instance.permissionOverrides and instance.permissionOverrides[key]) then
		return true
	else
		local notok, reason = P.permissionchecks[key](instance, target)
		if notok then return false, reason else return true end
	end
end

function P.savePermissions()
	local settings = {}
	for k, privilege in pairs(P.privileges) do
		settings[k] = {}
		for provider, v in pairs(privilege[3]) do
			settings[k][provider] = v.setting
		end
	end
	file.Write(P.filename, util.TableToJSON(settings))
end

function P.buildPermissionCheck(privilegeid)
	local privilege = P.privileges[privilegeid]	
	local checks = {}
	local allAllow = true
	local anyBlock = false
	for providerid, v in pairs(privilege[3]) do
		if P.providers[providerid] then
			local check = P.providers[providerid].checks[v.setting]
			if check == "block" then
				allAllow = false
				anyBlock = true
				break
			elseif check ~= "allow" then
				allAllow = false
				checks[#checks+1] = check
			end
		end
	end
	if allAllow then
		P.permissionchecks[privilegeid] = function() return false end
	elseif anyBlock then
		P.permissionchecks[privilegeid] = function() return true, "This function's permission is blocked!" end
	elseif #checks==0 then
		P.permissionchecks[privilegeid] = function() return false end
	elseif #checks==1 then
		local check = checks[1]
		P.permissionchecks[privilegeid] = function(instance, target)
			local ok, reason = check(instance, target)
			return not ok, reason
		end
	else
		P.permissionchecks[privilegeid] = function(instance, target)
			for k, v in ipairs(checks) do
				local ok, reason = v(instance, target)
				if not ok then return true, reason end
			end
			return false
		end
	end
end

local invalidators = {
	[1669008186] = { -- Nov 21, 2022
		message = "HTTP's URL whitelisting was misconfigured, and set by default to Disabled",
		realm = CLIENT,
		invalidate = {"http.get", "http.post"},
		check = function(settings_table)
			return (settings_table["http.get"] ~= nil and settings_table["http.get"]["urlwhitelist"] == 2) or
					(settings_table["http.post"] ~= nil and settings_table["http.post"]["urlwhitelist"] == 2)
		end
	}
}

local printC = function(...) (SERVER and MsgC or chat.AddText)(Color(255, 255, 255), "[", Color(11, 147, 234), "Starfall", Color(255, 255, 255), "]: ", ...) if SERVER then MsgC("\n") end end

-- Load the permission settings for each provider
function P.loadPermissionOptions()
	local saveSettings = not file.Exists(P.filename, "DATA")
	local settings = util.JSONToTable(file.Read(P.filename) or "") or {}
	local settingsTime = file.Time(P.filename, "DATA") or math.huge

	for issueTime, issue in pairs(invalidators) do
		if settingsTime < issueTime and issue.realm and (issue.check == nil or issue.check(settings)) then 
			printC("Your configuration has been modified due to a misconfiguration.")
			printC("Reason: " .. issue.message)
			printC("Changes: " .. table.concat(issue.invalidate, ", "))
			for _, v in ipairs(issue.invalidate) do
				saveSettings = true
				settings[v] = nil
			end
		end
	end
	
	for privilegeid, privilege in pairs(P.privileges) do
		if settings[privilegeid] then
			for permissionid, permission in pairs(privilege[3]) do
				if P.providers[permissionid] then
					if settings[privilegeid][permissionid] then
						permission.setting = settings[privilegeid][permissionid]
					else
						permission.setting = permission.default or P.providers[permissionid].defaultsetting
					end
				else
					privilege[3][permissionid] = nil
				end
			end
		else
			for permissionid, permission in pairs(privilege[3]) do
				if P.providers[permissionid] then
					permission.setting = permission.default or P.providers[permissionid].defaultsetting
				else
					privilege[3][permissionid] = nil
				end
			end
		end
		P.buildPermissionCheck(privilegeid)
	end

	if saveSettings then
		P.savePermissions()
	end
end

-- Find and include all provider files.
do
	local function IncludeClientFile(file)
		if SERVER then
			AddCSLuaFile(file)
		else
			include(file)
		end
	end

	if SERVER then
		local files = file.Find("starfall/permissions/providers_sv/*.lua", "LUA")

		for _, file in pairs(files) do
			include("starfall/permissions/providers_sv/" .. file)
		end
	end

	local sh_files = file.Find("starfall/permissions/providers_sh/*.lua", "LUA")

	for _, file in pairs(sh_files) do
		if SERVER then
			AddCSLuaFile("starfall/permissions/providers_sh/" .. file)
		end
		include("starfall/permissions/providers_sh/" .. file)
	end

	local cl_files = file.Find("starfall/permissions/providers_cl/*.lua", "LUA")

	for _, file in pairs(cl_files) do
		IncludeClientFile("starfall/permissions/providers_cl/" .. file)
	end
end

local function changePermission(ply, arg)
	if arg[1] then
		local privilege = P.privileges[arg[1]]
		if privilege then
			if arg[2] and privilege[3][arg[2]] then
				local val = tonumber(arg[3])
				if val and val>=1 and val<=#P.providers[arg[2]].settingsoptions then
					privilege[3][arg[2]].setting = math.floor(val)
					P.savePermissions()
					P.buildPermissionCheck(arg[1])
				else
					ply:PrintMessage(HUD_PRINTCONSOLE, "The setting's value is out of bounds or not a number.\n")
				end
			else
				ply:PrintMessage(HUD_PRINTCONSOLE, "Permission, " .. tostring(arg[2]) .. ", couldn't be found.\nHere's a list of permissions.\n")
				for id, _ in pairs(privilege[3]) do ply:PrintMessage(HUD_PRINTCONSOLE, id.."\n") end
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
			for id, v in pairs(P.providers) do

				net.WriteString(id)
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
		if instance.permissionOverrides then
			for id, _ in pairs( instance.permissionRequest.overrides ) do
				if not instance.permissionOverrides[ id ] then return false end
			end
			return true
		else return table.Count( instance.permissionRequest.overrides ) == 0 end
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
