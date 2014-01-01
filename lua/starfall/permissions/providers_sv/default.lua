--- Default starfall permission provider

-- start the provider table and set it to inherit from the default provider
local P = {}
P.__index = SF.Permissions.Provider
setmetatable( P, P )

-- localize the result set
local ALLOW = SF.Permissions.Result.ALLOW
local DENY = SF.Permissions.Result.DENY
local NEUTRAL = SF.Permissions.Result.NEUTRAL

local ES = SF.DB.escape;

function P:check (principal, target, key)
	-- if target is not a string, we don't care about the permission 
	if type( target ) ~= "string" then return NEUTRAL end
	
	local result = SF.DB.query( [[
		SELECT grant.grant
		FROM starfall_perms_player_roles AS role
		INNER JOIN starfall_perms_grants AS grant ON grant.role = role.rowid
		WHERE role.player = "]] .. ES( principal:SteamID() ) .. [["
			AND grant.key = "]] .. ES( key ) .. [["
			AND grant.target = "]] .. ES( target ) .. [["]]
	)

	if result == false then
		error( "error in default provider " .. sql.LastError() )
	end
	
	local allow = false;
	for _, row in pairs( result or {} ) do
		local grant = row[ 'grant' ]
		
		if "1" == grant then
			allow = true
		elseif "0" == grant then
			return DENY
		end
	end
	
	if allow then
		return ALLOW
	else
		return NEUTRAL
	end
end



-- register the provider
SF.Permissions.registerProvider( P )