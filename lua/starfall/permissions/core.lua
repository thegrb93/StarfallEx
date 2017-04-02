---------------------------------------------------------------------
-- SF Permissions management
---------------------------------------------------------------------

SF.Permissions = {}

local P = SF.Permissions
P.providers = {}
P.filename = SERVER and "sf_perms.txt" or "sf_perms_cl.txt"

--- Adds a provider implementation to the set used by this library.
-- Providers must implement the {@link SF.Permissions.Provider} interface.
-- @param provider the provider to be registered
function P.registerProvider ( provider )
	P.providers[ #P.providers + 1 ] = provider
end

--- Registers a privilege
-- @param id unique identifier of the privilege being registered
-- @param name Human readable name of the privilege
-- @param description a short description of the privilege
function P.registerPrivilege ( id, name, description, arg )
	for _, provider in ipairs( P.providers ) do
		provider.registered( id, name, description, arg )
	end
end

--- Checks whether a player may perform an action.
-- @param principal the player performing the action to be authorized
-- @param target the object on which the action is being performed
-- @param key a string identifying the action being performed
-- @return boolean whether the action is permitted
function P.check ( principal, target, key )

	for _, provider in ipairs( P.providers ) do
		local setting = provider.settings[ key ]
		if setting then
			local check = provider.checks[ setting ]
			if check then
				if not check( principal, target, key ) then
					SF.throw( "Insufficient permissions: " .. key, 3 )
				end
			else
				SF.throw( "'" .. provider.id .. "' bad setting for permission " .. key .. ": " .. setting, 3 )
			end
		end
	end

end

function P.hasAccess ( principal, target, key )

	for _, provider in ipairs( P.providers ) do
		local setting = provider.settings[ key ]
		if setting then
			local check = provider.checks[ setting ]
			if check then
				if not check( principal, target, key ) then return false end
			else
				SF.throw( "'" .. provider.id .. "' bad setting for permission " .. key .. ": " .. setting, 3 )
			end
		end
	end
	
	return true
end

function P.savePermissions()
	local settings = {}
	for _, provider in ipairs( P.providers ) do
		if next(provider.settings) then
			local tbl = {}
			for k, v in pairs(provider.settings) do
				tbl[k] = v
			end
			settings[ provider.id ] = tbl
		end
	end
	file.Write( P.filename, util.TableToJSON( settings ) )
end

-- Find and include all provider files.
do
	local function IncludeClientFile ( file )
		if SERVER then
			AddCSLuaFile( file )
		else
			include( file )
		end
	end

	if SERVER then
		local files = file.Find( "starfall/permissions/providers_sv/*.lua", "LUA" )

		for _, file in pairs( files ) do
			include( "starfall/permissions/providers_sv/" .. file )
		end
	end

	local sh_files = file.Find( "starfall/permissions/providers_sh/*.lua", "LUA" )

	for _, file in pairs( sh_files ) do
		if SERVER then
			AddCSLuaFile( "starfall/permissions/providers_sh/" .. file )
		end
		include( "starfall/permissions/providers_sh/" .. file )
	end

	local cl_files = file.Find( "starfall/permissions/providers_cl/*.lua", "LUA" )

	for _, file in pairs( cl_files ) do
		IncludeClientFile( "starfall/permissions/providers_cl/" .. file )
	end
end

-- Load the permission settings for each provider
do
	local settings = util.JSONToTable( file.Read( P.filename ) or "" ) or {}
	for _, provider in ipairs( P.providers ) do
		if settings[ provider.id ] then
			for k, v in pairs(settings[provider.id]) do
				-- Make sure the setting exists
				if provider.settings[k] then provider.settings[k] = v end
			end
		end
	end
end

local function changePermission( ply, arg )
	local provider
	for _, p in ipairs(P.providers) do if p.id == arg[1] then provider = p break end end
	if provider then
		if arg[2] and provider.settings[arg[2]] then
			local val = tonumber(arg[3])
			if val and val>=1 and val<=#provider.settingsoptions then
				provider.settings[arg[2]] = math.floor( val )
				P.savePermissions()
			else
				ply:PrintMessage( HUD_PRINTCONSOLE, "The setting's value is out of bounds or not a number.\n" )
			end
		else
			ply:PrintMessage( HUD_PRINTCONSOLE, "Setting, " .. tostring(arg[2]) .. ", couldn't be found.\nHere's a list of settings.\n")
			for id, _ in SortedPairs(provider.settings) do ply:PrintMessage( HUD_PRINTCONSOLE, id.."\n") end
		end
	else
		ply:PrintMessage( HUD_PRINTCONSOLE, "Permission provider, " .. tostring(arg[1]) .. ", couldn't be found.\nHere's a list of providers.\n" )
		for _, p in ipairs(P.providers) do ply:PrintMessage( HUD_PRINTCONSOLE, p.id.."\n" ) end
	end
end

-- Console commands for changing permissions.
if SERVER then
	concommand.Add("sf_permission", function(ply, com, arg)
		if ply:IsValid() and not ply:IsSuperAdmin() then return end
		changePermission(ply, arg)
	end)
else
	concommand.Add("sf_permission_cl", function(ply,com,arg)
		changePermission(ply, arg)
	end)
end

-- Networking for administrators to get the server's settings
if SERVER then
	util.AddNetworkString( "sf_permissionsettings" )
	net.Receive( "sf_permissionsettings", function( len, ply )
		if ply:IsSuperAdmin() then
			net.Start("sf_permissionsettings")
			
			net.WriteUInt( #P.providers, 8 )
			for _, v in ipairs(P.providers) do
				net.WriteString(v.id)
				net.WriteString(v.name)
				net.WriteUInt( #v.settingsoptions, 8 )
				for _, option in ipairs(v.settingsoptions) do
					net.WriteString(option)
				end
				net.WriteUInt( table.Count(v.settings), 8)
				for id, setting in pairs(v.settings) do
					net.WriteString(id)
					net.WriteString(v.settingsdesc[id][1])
					net.WriteString(v.settingsdesc[id][2])
					net.WriteUInt(setting, 8)
				end
			end
			
			net.Send(ply)
		end
	end)
else
	local reqCallback, reqTimeout
	function P.requestPermissions( callback )
		if not reqCallback or (reqTimeout and reqTimeout<CurTime()) then
			reqCallback = callback
			reqTimeout = CurTime()+2
			net.Start("sf_permissionsettings")
			net.SendToServer()
		end
	end
	net.Receive( "sf_permissionsettings", function()
		if reqCallback then
			local providers = {}
			local nproviders = net.ReadUInt(8)
			for i=1, nproviders do
				local provider = {
					id = net.ReadString(),
					name = net.ReadString(),
					settings = {},
					options = {}
				}
				local noptions = net.ReadUInt(8)
				for j=1, noptions do
					provider.options[j] = net.ReadString()
				end
				local nsettings = net.ReadUInt(8)
				for j=1, nsettings do
					provider.settings[net.ReadString()] = {net.ReadString(), net.ReadString(), net.ReadUInt(8)}
				end
				providers[i] = provider
			end
			reqCallback(providers)
			reqCallback = nil
			reqTimeout = nil
		end
	end)
end
