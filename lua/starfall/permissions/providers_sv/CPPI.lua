--- Provides permissions for entities based on CPPI if present

local P = setmetatable( {}, { __index = SF.Permissions.Provider } )

local ALLOW = SF.Permissions.Result.ALLOW
local DENY = SF.Permissions.Result.DENY
local NEUTRAL = SF.Permissions.Result.NEUTRAL

local canTool = {
	[ "entities.parent" ] = true,
	[ "entities.unparent" ] = true,
	[ "entities.setSolid" ] = true,
	[ "entities.enableGravity" ] = true,
	[ "entities.setColor" ] = true,
	[ "wire.createWire" ] = true,
	[ "wire.deleteWire" ] = true,
	[ "constraints.weld" ] = true,
	[ "constraints.axis" ] = true,
	[ "constraints.ballsocket" ] = true,
	[ "constraints.ballsocketadv" ] = true,
	[ "constraints.slider" ] = true,
	[ "constraints.rope" ] = true,
	[ "constraints.elastic" ] = true,
	[ "constraints.nocollide" ] = true,
	[ "constraints.any" ] = true
}

local canPhysgun = {
	[ "entities.applyForce" ] = true,
	[ "entities.setPos" ] = true,
	[ "entities.setAngles" ] = true,
	[ "entities.setVelocity" ] = true,
	[ "entities.setFrozen" ] = true
}

function P:check ( principal, target, key )
	if not CPPI then return NEUTRAL end
	if type( target ) ~= "Entity" and type( target ) ~= "Player" then return NEUTRAL end

	if canTool[ key ] then
		if target:CPPICanTool( principal, "starfall_ent_lib" ) then return ALLOW end
		return DENY
	elseif canPhysgun[ key ] then
		if target:CPPICanPhysgun( principal ) then return ALLOW end
		return DENY
	end

	return NEUTRAL
end

SF.Permissions.registerProvider( P )
