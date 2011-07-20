local advphys = {}
SF_Compiler.AddModule("advphysics",advphys)

--------------------------------- Physics ---------------------------------

function advphys.setPos(ent, pos)
	SF_Compiler.CheckType(ent,SF_Entities.metatable)
	SF_Compiler.CheckType(pos,"Vector")
	ent = SF_Entities.UnwrapEntity(ent)
	if not SF_Entities.IsValid(ent) then return false end
	if not SF_Permissions.CanModifyEntity(ent) then return false end
	if not util.IsInWorld(pos) then return false end
	
	ent:SetPos(pos)
	ent:GetPhysicsObject():Wake()
	return true
end

function advphys.setAng(ent, ang)
	SF_Compiler.CheckType(ent,SF_Entities.metatable)
	SF_Compiler.CheckType(ang,"Angle")
	ent = SF_Entities.UnwrapEntity(ent)
	if not SF_Entities.IsValid(ent) then return false end
	if not SF_Permissions.CanModifyEntity(ent) then return false end
	
	ent:GetPhysicsObject():SetAngle(ang)
	ent:GetPhysicsObject():Wake()
	return true
end

function advphys.setFrozen(ent, freeze)
	SF_Compiler.CheckType(ent,SF_Entities.metatable)
	ent = SF_Entities.UnwrapEntity(ent)
	if not SF_Entities.IsValid(ent) then return false end
	if not SF_Permissions.CanModifyEntity(ent) then return false end
	
	ent:GetPhysicsObject():EnableMotion(not (freeze and true or false))
	ent:GetPhysicsObject():Wake()
	return true
end

function advphys.setNotSolid(ent, notsolid)
	SF_Compiler.CheckType(ent,SF_Entities.metatable)
	ent = SF_Entities.UnwrapEntity(ent)
	if not SF_Entities.IsValid(ent) then return false end
	if not SF_Permissions.CanModifyEntity(ent) then return false end
	
	ent:SetNotSolid(notsolid and true or false)
	ent:GetPhysicsObject():Wake()
	return true
end

function advphys.enableGravity(ent, grav)
	SF_Compiler.CheckType(ent,SF_Entities.metatable)
	ent = SF_Entities.UnwrapEntity(ent)
	if not SF_Entities.IsValid(ent) then return false end
	if not SF_Permissions.CanModifyEntity(ent) then return false end
	
	ent:GetPhysicsObject():EnableGravity(grav and true or false)
	ent:GetPhysicsObject():Wake()
	return true
end

--------------------------------- Constraints ---------------------------------
local function checkents(ent1, ent2)
	SF_Compiler.CheckType(ent1,SF_Entities.metatable,1)
	ent1 = SF_Entities.UnwrapEntity(ent1)
	if not SF_Entities.IsValid(ent1) then return false end
	if not SF_Permissions.CanModifyEntity(ent1) then return false end
	
	SF_Compiler.CheckType(ent2,SF_Entities.metatable,1)
	ent2 = SF_Entities.UnwrapEntity(ent2)
	if not SF_Entities.IsValid(ent2) then return false end
	if not SF_Permissions.CanModifyEntity(ent2) then return false end
	
	return ent1, ent2
end

function advphys.weld(ent1, ent2, breakforce, nocollide)
	ent1, ent2 = checkents(ent1, ent2)
	if not ent1 then return false end
	constraint.Weld(ent1, ent2, tonumber(breakforce) or 0, nocollide and true or false)
	return true
end

function advphys.axis(ent1, ent2, origin, axis, nocollide, forcelim, torquelim, friction)
	ent1, ent2 = checkents(ent1, ent2)
	if not ent1 then return false end
	SF_Compiler.CheckType(origin, "Vector")
	SF_Compiler.CheckType(axis, "Vector")
	constraint.Axis(ent1, ent2, 0, 0, origin, axis, nocollide and true or false,
		tonumber(forcelim) or 0, tonumber(torquelim) or 0, tonumber(friction) or 0)
	return true
end