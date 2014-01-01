---------------------------------------------------------------------
-- SF Permissions management
---------------------------------------------------------------------

-- TODO: Client version

--- Permission format
-- @name Permission
-- @class table
-- @field name The name of the permission
-- @field desc The description of the permission.
-- @field level The abusability of the permission. 0 = low (print to console),
--                1 = normal (modify entities), 2 = high (run arbitrary lua)
-- @field value Boolean. True to allow, false to deny

SF.Permissions = {}

local P = SF.Permissions
P.__index = P

do
	local lockmeta = {
		__newindex = function (table, key, value)
			error( "attempting to assign to a read-only table", 2 )
		end,
		__metatable = "constant"
	}
	
	local result_vals = {
		DENY	= setmetatable( {}, lockmeta ),
		ALLOW	= setmetatable( {}, lockmeta ),
		NEUTRAL	= setmetatable( {}, lockmeta )
	}
	
	P.Result = setmetatable( {}, {
		__index = result_vals,
		__newindex = lockmeta.__newindex,
		__metatable = "enum"
	} )
end

local DENY		= P.Result.DENY
local ALLOW		= P.Result.ALLOW
local NEUTRAL	= P.Result.NEUTRAL

local providers = {}

local have_owner = false

--- Adds a provider implementation to the set used by this library.
-- Providers must implement the {@link SF.Permissions.Provider} interface.
-- @param provider the provider to be registered
function P.registerProvider (provider)
	if type( provider ) ~= "table"
			or type( provider.supportsOwner ) ~= "function"
			or type( provider.isOwner ) ~= "function"
			or type( provider.check ) ~= "function" then
		error( "given object does not implement the provider interface", 2 )
	end
	
	providers[ provider ] = provider
	
	if provider:supportsOwner() then
		have_owner = true
	end
end

--- Checks whether a player may perform an action.
-- @param principal the player performing the action to be authorized
-- @param target the object on which the action is being performed
-- @param key a string identifying the action being performed
-- @return boolean whether the action is permitted
function P.check (principal, target, key)
	-- server owners can do whatever they want
	if have_owner then
		-- this can't be merged into the check loop below because that 
		for _, provider in pairs( providers ) do
			if provider:isOwner( principal ) then return true end
		end
	elseif principal:IsSuperAdmin() then
		return true
	end
	
	local allow = false;
	for _, provider in pairs( providers ) do
		local result = provider:check( principal, target, key )
		if DENY == result then
			-- a single deny overrides any allows, just deny it now
			return false
		elseif ALLOW == result then
			-- an allow can be overridden by a deny, so remember and keep going
			allow = true
		end
		-- otherwise, this provider has no opinion, just go on to the next one
	end
	
	return allow
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
		include( "starfall/permissions/provider.lua" )
	end
	
	IncludeClientFile( "starfall/permissions/provider.lua" )
	
	if SERVER then
		local files = file.Find( "starfall/permissions/providers_sv/*.lua", "LUA" )
		
		for _, file in pairs( files ) do
			include( "starfall/permissions/providers_sv/" .. file )
		end
	end
	
	local cl_files = file.Find( "starfall/permission/providers_cl/*.lua", "LUA" )
	
	for _, file in pairs( cl_files ) do
		IncludeClientFile( "starfall/permission/providers_cl/" .. file )
	end
end
