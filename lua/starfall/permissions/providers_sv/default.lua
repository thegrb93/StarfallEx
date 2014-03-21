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

local function getUsergroupID ( ply )
	if ply:IsSuperAdmin() then
		return 2
	elseif ply:IsAdmin() then
		return 1
	end
	return 0
end

local function getUsergroupName ( ply )
	if ply:IsSuperAdmin() then
		return "superadmin"
	elseif ply:IsAdmin() then
		return "admin"
	end
	return "user"
end

function P:check ( principal, target, key )
	local result = SF.DB.query( [[
		SELECT grant
		FROM starfall_perms_grants
		WHERE	role = ]] .. ES( getUsergroupID( principal ) ) .. [[
			AND key = "]] .. ES( key ) .. [["]]
	)

	if result == false then
		error( "error in default provider " .. sql.LastError() )
	end

	if result and #result >= 1 then
		local row = result[ 1 ]
		local grant = row[ 'grant' ]

		if "0" == grant then
			return NEUTRAL
		elseif "1" == grant then
			return ALLOW
		elseif "2" == grant then
			return DENY
		end
	else
		return NEUTRAL
	end
end

-- register the provider
SF.Permissions.registerProvider( P )
