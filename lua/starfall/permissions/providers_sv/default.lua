--- Default starfall permission provider

local P = {}

local ES = SF.DB.escape;

local function getUsergroupID ( ply )
	if ply:IsSuperAdmin() then
		return 2
	elseif ply:IsAdmin() then
		return 1
	end
	return 0
end

function P.check ( principal, target, key )
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
			return true
		elseif "1" == grant then
			return true
		elseif "2" == grant then
			return false
		end
	end
end

-- register the provider
-- The database can't be customized anyway so most people won't even be able to use this.
-- Also querying the database for every check is fucking slow
-- SF.Permissions.registerProvider( P )
