--- Starfall file library permission provider

-- start the provider table and set it to inherit from the default provider
local P = {}
P.__index = SF.Permissions.Provider
setmetatable( P, P )

-- localize the result set
local ALLOW = SF.Permissions.Result.ALLOW
local DENY = SF.Permissions.Result.DENY
local NEUTRAL = SF.Permissions.Result.NEUTRAL

-- define what permission keys we will allow
local keys = {
	[ "file.read" ] = true,
	[ "file.write" ] = true,
	[ "file.exists" ] = true
}

function P:check ( principal, target, key )
	if type( target ) ~= "string" then return NEUTRAL end

	-- allow if the localplayer is trying to write a file to their computer
	if keys[ key ] and principal == LocalPlayer() then
		return ALLOW
	else
		return NEUTRAL
	end
end

-- register the provider
SF.Permissions.registerProvider( P )
