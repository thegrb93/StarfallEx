--- Provides permissions for entities based on CPPI if present

local P = {}

local canTool = {
	[ "entities.parent" ] = true,
	[ "entities.unparent" ] = true,
	[ "entities.setSolid" ] = true,
	[ "entities.setMass" ] = true,
	[ "entities.enableGravity" ] = true,
	[ "entities.enableMotion" ] = true,
	[ "entities.enableDrag" ] = true,
	[ "entities.applyDamage" ] = true,
	[ "entities.remove" ] = true,
	[ "entities.ignite" ] = true,
	[ "entities.emitSound" ] = true,
	[ "entities.setRenderPropery" ] = true,
	[ "entities.canTool" ] = true,
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
	[ "constraints.any" ] = true,
	[ "npcs.modify" ] = true
}

local canPhysgun = {
	[ "entities.applyForce" ] = true,
	[ "entities.setPos" ] = true,
	[ "entities.setAngles" ] = true,
	[ "entities.setVelocity" ] = true,
	[ "entities.setFrozen" ] = true
}

function P.check ( principal, target, key )
	if CPPI then
		if canTool[ key ] then
			return target:CPPICanTool( principal, "starfall_ent_lib" )
		elseif canPhysgun[ key ] then
			if target:IsPlayer() then
				if hook.Call( "PhysgunPickup", GAMEMODE, principal, target ) ~= false then
					-- Some mods expect a release when there's a player pickup involved.
					hook.Call( "PhysgunDrop", GAMEMODE, principal, target )
					return true
				else
					return false
				end
			else
				return target:CPPICanPhysgun( principal )
			end
		end
	end
end

SF.Permissions.registerProvider( P )
