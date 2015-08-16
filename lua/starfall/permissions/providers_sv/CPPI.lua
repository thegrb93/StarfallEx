--- Provides permissions for entities based on CPPI if present

local P = setmetatable( {}, { __index = SF.Permissions.Provider } )

local ALLOW = SF.Permissions.Result.ALLOW
local DENY = SF.Permissions.Result.DENY
local NEUTRAL = SF.Permissions.Result.NEUTRAL

local canTool = {
	[ "entities.parent" ] = true,
	[ "entities.unparent" ] = true,
	[ "entities.setSolid" ] = true,
	[ "entities.setMass" ] = true,
	[ "entities.enableGravity" ] = true,
	[ "entities.enableMotion" ] = true,
	[ "entities.enableDrag" ] = true,
	[ "entities.setColor" ] = true,
	[ "entities.remove" ] = true,
	[ "entities.emitSound" ] = true,
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
	
	if canTool[ key ] then
		if not IsValid( target:CPPIGetOwner() ) then return DENY end
		if target:CPPICanTool( principal, "starfall_ent_lib" ) then return ALLOW end
		return DENY
	elseif canPhysgun[ key ] then
		if target:IsPlayer() then
			return (hook.Call( "PhysgunPickup", GAMEMODE, principal, target ) ~= false) and ALLOW or DENY
		else
			if not IsValid( target:CPPIGetOwner() ) then return DENY end
			if target:CPPICanPhysgun( principal ) then return ALLOW end
		end
		return DENY
	end

	return NEUTRAL
end

SF.Permissions.registerProvider( P )
