---------------------------------------------------------------------
-- SF Permissions management
---------------------------------------------------------------------

SF.Permissions = {}

local P = SF.Permissions
P.privileges = {}
P.providers = {}

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
function P.registerPrivilege ( id, name, description )
	P.privileges[ id ] = { name = name, description = description }
end

--- Checks whether a player may perform an action.
-- @param principal the player performing the action to be authorized
-- @param target the object on which the action is being performed
-- @param key a string identifying the action being performed
-- @return boolean whether the action is permitted
function P.check ( principal, target, key )

	for _, provider in ipairs( P.providers ) do
		local result = provider.check( principal, target, key )
		if result == false then
			-- a single deny overrides any allows, just deny it now
			return false
		end
		-- otherwise, this provider has no opinion, just go on to the next one
	end

	return true
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
