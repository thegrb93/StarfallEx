--- Provides permissions for entities based on CPPI if present

local P = {}
P.id = "entities"
P.name = "Entity Permissions"
P.settings = {}
P.settingsdesc = {}
P.settingsoptions = {"Owner Only", "Can touch", "Anything"}

local canTool = {}
local canPhysgun = {}

function P.registered ( id, name, description, arg )
	if not arg then return end
	
	local addSetting
	if arg.CanPhysgun then
		canPhysgun[ id ] = true
		addSetting = arg.CanPhysgun
	elseif arg.CanTool then
		canTool[ id ] = true
		addSetting = arg.CanTool
	end
	
	if addSetting then
		P.settingsdesc[ id ] = { name, description }
		if not P.settings[ id ] then
			P.settings[ id ] = addSetting.default or 2
		end
	end
end

local function dumbtrace(ent)
	local pos = ent:GetPos()
	return {
		FractionLeftSolid = 0,
		HitNonWorld       = true,
		Fraction          = 0,
		Entity            = ent,
		HitPos            = pos,
		HitNormal         = Vector(0,0,0),
		HitBox            = 0,
		Normal            = Vector(1,0,0),
		Hit               = true,
		HitGroup          = 0,
		MatType           = 0,
		StartPos          = pos,
		PhysicsBone       = 0,
		WorldToLocal      = Vector(0,0,0),
	}
end
if CPPI then
	P.checks = {
		function( principal, target, key )
			return target:CPPIGetOwner()==principal
		end,
		function( principal, target, key )
			if not IsValid(target) then return false end
			if canPhysgun[ key ] then
				if target:IsPlayer() then
					if hook.Run( "PhysgunPickup", principal, target ) != false then
						-- Some mods expect a release when there's a pickup involved.
						hook.Run( "PhysgunDrop", principal, target )
						return true
					else
						return false
					end
				else
					return target:CPPICanPhysgun( principal )
				end
			elseif canTool[ key ] then
				return target:CPPICanTool( principal, "starfall_ent_lib" )
			end
		end,
		function( ) return true end
	}
else
	P.checks = {
		function( principal, target, key )
			return false
		end,
		function( principal, target, key )
			if not IsValid(target) then return false end
			if canPhysgun[ key ] then
				if hook.Run( "PhysgunPickup", principal, target ) != false then
					-- Some mods expect a release when there's a pickup involved.
					hook.Run( "PhysgunDrop", principal, target )
					return true
				else
					return false
				end
			elseif canTool[ key ] then
				return hook.Run( "CanTool", principal, dumbtrace( target ), "starfall_ent_lib" ) != false
			end
		end,
		function( ) return true end
	}
end

SF.Permissions.registerProvider( P )
