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
function P.registerProvider (provider)
	P.providers[provider.id] = provider
end

--- Adds a provider which will be used on specified permissions. (Meant for outside addons)
-- Providers must implement the {@link SF.Permissions.Provider} interface.
-- @param provider the provider to be registered
-- @param privileges table of privs this provider will be added to
-- @param exclusive if true, this provider will replace all existing providers for the privilege. (Addons loaded later may add aditional providers)
function P.registerCustomProvider (provider, privileges, exclusive)
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
function P.registerPrivilege (id, name, description, arg)
	arg = arg or {}
	--All privileges should get usergroup
	if not arg.usergroup then
		arg.usergroups = {}
	end

	P.privileges[id] = {name, description, arg}
end

--- Checks whether a player may perform an action.
-- @param instance The instance checking permission
-- @param target the object on which the action is being performed
-- @param key a string identifying the action being performed
function P.check (instance, target, key)
	if instance.permissionOverrides and instance.permissionOverrides[key] then
		return
	end
	if P.permissionchecks[key](instance, target) then
		SF.Throw("Insufficient permissions: " .. key, 3)
	end
end

function P.hasAccess (instance, target, key)
	return (instance.permissionOverrides and instance.permissionOverrides[key]) or not P.permissionchecks[key](instance, target)
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
	for providerid, v in pairs(privilege[3]) do
		if P.providers[providerid] then
			checks[#checks+1] = P.providers[providerid].checks[v.setting]
		end
	end
	P.permissionchecks[privilegeid] = function(instance, target)
		for k, v in ipairs(checks) do
			if not v(instance, target) then return true end
		end
		return false
	end
end

-- Load the permission settings for each provider
SF.Libraries.AddHook("postload", function()
	local settings = util.JSONToTable(file.Read(P.filename) or "") or {}
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
end)

-- Find and include all provider files.
do
	local function IncludeClientFile (file)
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
			net.Start("sf_permissionsettings")

			net.WriteUInt(table.Count(P.providers), 8)
			for id, v in pairs(P.providers) do

				local privileges = {}
				for privilegeid, privilege in pairs(P.privileges) do
					if privilege[3][id] then
						privileges[privilegeid] = privilege
					end
				end

				net.WriteString(id)
				net.WriteString(v.name)
				net.WriteUInt(#v.settingsoptions, 8)
				for _, option in pairs(v.settingsoptions) do
					net.WriteString(option)
				end
				net.WriteUInt(table.Count(privileges), 8)
				for privid, setting in pairs(privileges) do
					net.WriteString(privid)
					net.WriteString(setting[1])
					net.WriteString(setting[2])
					net.WriteUInt(setting[3][id].setting, 8)
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
	net.Receive("sf_permissionsettings", function()
		if reqCallback then
			local providers = {}
			local nproviders = net.ReadUInt(8)
			for i = 1, nproviders do
				local provider = {
					id = net.ReadString(),
					name = net.ReadString(),
					settings = {},
					options = {}
				}
				local noptions = net.ReadUInt(8)
				for j = 1, noptions do
					provider.options[j] = net.ReadString()
				end
				local nsettings = net.ReadUInt(8)
				for j = 1, nsettings do
					provider.settings[net.ReadString()] = { net.ReadString(), net.ReadString(), net.ReadUInt(8) }
				end
				providers[i] = provider
			end
			reqCallback(providers)
			reqCallback = nil
			reqTimeout = nil
		end
	end)
end
