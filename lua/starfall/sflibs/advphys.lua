local advphys = {}
SF_Compiler.AddModule("advphysics",advphys)

--------------------------------- Physics ---------------------------------

function advphys.setPos(ent, pos)
	if not SF_Entities.IsWrappedEntity(ent) then error(type(ent).."-typed entity passed to setPos",2) end
	ent = SF_Entities.UnwrapEntity(ent)
	if not SF_Entities.IsValid(ent) then return false end
	if not SF_Permissions.CanModifyEntity(ent) then return false end
	if type(pos) ~= "Vector" then error(type(pos).."-typed position vector passed to setPos",2) end
	if not util.IsInWorld(pos) then return false end
	
	ent:SetPos(pos)
	ent:GetPhysicsObject():Wake()
	return true
end

function advphys.setAng(ent, ang)
	if not SF_Entities.IsWrappedEntity(ent) then error(type(ent).."-typed entity passed to setAng",2) end
	ent = SF_Entities.UnwrapEntity(ent)
	if not SF_Entities.IsValid(ent) then return false end
	if not SF_Permissions.CanModifyEntity(ent) then return false end
	if type(ang) ~= "Angle" then error(type(ang).."-typed angle passed to setAng",2) end
	
	ent:GetPhysicsObject():SetAngle(ang)
	ent:GetPhysicsObject():Wake()
	return true
end

function advphys.setFrozen(ent, freeze)
	if not SF_Entities.IsWrappedEntity(ent) then error(type(ent).."-typed entity passed to setFrozen",2) end
	ent = SF_Entities.UnwrapEntity(ent)
	if not SF_Entities.IsValid(ent) then return false end
	if not SF_Permissions.CanModifyEntity(ent) then return false end
	
	ent:GetPhysicsObject():EnableMotion(not (freeze and true or false))
	ent:GetPhysicsObject():Wake()
	return true
end

function advphys.setNotSolid(ent, notsolid)
	if not SF_Entities.IsWrappedEntity(ent) then error(type(ent).."-typed entity passed to setNotSolid",2) end
	ent = SF_Entities.UnwrapEntity(ent)
	if not SF_Entities.IsValid(ent) then return false end
	if not SF_Permissions.CanModifyEntity(ent) then return false end
	
	ent:SetNotSolid(notsolid and true or false)
	ent:GetPhysicsObject():Wake()
	return true
end

function advphys.enableGravity(ent, grav)
	if not SF_Entities.IsWrappedEntity(ent) then error(type(ent).."-typed entity passed to setGravity",2) end
	ent = SF_Entities.UnwrapEntity(ent)
	if not SF_Entities.IsValid(ent) then return false end
	if not SF_Permissions.CanModifyEntity(ent) then return false end
	
	ent:GetPhysicsObject():EnableGravity(grav and true or false)
	ent:GetPhysicsObject():Wake()
	return true
end

--------------------------------- Constraints ---------------------------------
local contstraints = {
	weld = function(ent1, ent2, breakforce, nocollide)
		constraint.Weld(ent1, ent2, tonumber(breakforce) or 0, nocollide and true or false)
	end,
	
	axis = function(ent1, ent2, origin, axis, nocollide, forcelim, torquelim, friction)
		if type(origin) ~= "vector" then error(type(origin).."-typed axis origin passed to constrain",3) end
		if type(axis) ~= "vector" then error(type(origin).."-typed axis direction passed to constrain",3) end
		constraint.Axis(ent1, ent2, 0, 0, origin, origin, forcelim or 0, torquelim or 0, friction or 0, nocollide and true or false, axis)
	end
}

function advphys.constrain(ent1, ent2, typ, ...)
	if not SF_Entities.IsWrappedEntity(ent1) then error(type(ent1).."-typed entity passed to constrain",2) end
	ent1 = SF_Entities.UnwrapEntity(ent1)
	if not SF_Entities.IsValid(ent1) then return false end
	if not SF_Permissions.CanModifyEntity(ent1) then return false end
	
	if not SF_Entities.IsWrappedEntity(ent2) then error(type(ent2).."-typed entity passed to constrain",2) end
	ent2 = SF_Entities.UnwrapEntity(ent2)
	if not SF_Entities.IsValid(ent2) then return false end
	if not SF_Permissions.CanModifyEntity(ent2) then return false end
	
	if type(typ) ~= "string" then error(type(typ).."-typed constraint type passed to constrain",2) end
	local func = constraints[typ:lower()]
	if not func then error("Constraint not supported: "..typ,2) end
	
	func(ent1, ent2, ...)
end