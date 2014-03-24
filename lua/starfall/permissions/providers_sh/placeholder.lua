--- Placeholder for the default provider. Allows a bunch of permissions for everyone

local P = setmetatable( {}, { __index = SF.Permissions.Provider } )

local ALLOW = SF.Permissions.Result.ALLOW
local DENY = SF.Permissions.Result.DENY
local NEUTRAL = SF.Permissions.Result.NEUTRAL

local allow = {
	[ "find" ] = true,
	[ "sound.create" ] = true,
	[ "sound.modify" ] = true,
	[ "wire.setOutputs" ] = true,
	[ "wire.setInputs" ] = true,
	[ "wire.output" ] = true,
	[ "wire.input" ] = true,
	[ "wire.wirelink.read" ] = true,
	[ "wire.wirelink.write" ] = true,
	[ "trace" ] = true,
	[ "find" ] = true
}

function P:check ( principal, target, key )
	if allow[ key ] then return ALLOW end
	return NEUTRAL
end

SF.Permissions.registerProvider( P )
