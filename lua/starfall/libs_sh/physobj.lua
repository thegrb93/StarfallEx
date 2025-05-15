-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local PHYS_META = FindMetaTable("PhysObj")

local checknumber = SF.CheckNumber
local checkvector = SF.CheckVector

--- PhysObj Type
-- @name PhysObj
-- @class type
-- @libtbl physobj_methods
SF.RegisterType("PhysObj", true, false, PHYS_META)


return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end
local Phys_AddAngleVelocity,Phys_AddGameFlag,Phys_AddVelocity,Phys_ApplyForceCenter,Phys_ApplyForceOffset,Phys_ApplyTorqueCenter,Phys_CalculateForceOffset,Phys_CalculateVelocityOffset,Phys_ClearGameFlag,Phys_EnableDrag,Phys_EnableGravity,Phys_EnableMotion,Phys_GetAABB,Phys_GetAngleVelocity,Phys_GetAngles,Phys_GetDamping,Phys_GetEntity,Phys_GetFrictionSnapshot,Phys_GetInertia,Phys_GetMass,Phys_GetMassCenter,Phys_GetMaterial,Phys_GetMesh,Phys_GetMeshConvexes,Phys_GetPos,Phys_GetPositionMatrix,Phys_GetStress,Phys_GetSurfaceArea,Phys_GetVelocity,Phys_GetVelocityAtPoint,Phys_GetVolume,Phys_HasGameFlag,Phys_IsAsleep,Phys_IsDragEnabled,Phys_IsGravityEnabled,Phys_IsMoveable,Phys_IsValid,Phys_LocalToWorld,Phys_LocalToWorldVector,Phys_SetAngleDragCoefficient,Phys_SetAngleVelocity,Phys_SetAngles,Phys_SetBuoyancyRatio,Phys_SetContents,Phys_SetDamping,Phys_SetDragCoefficient,Phys_SetInertia,Phys_SetMass,Phys_SetMaterial,Phys_SetPos,Phys_SetVelocity,Phys_Sleep,Phys_Wake,Phys_WorldToLocal,Phys_WorldToLocalVector = PHYS_META.AddAngleVelocity,PHYS_META.AddGameFlag,PHYS_META.AddVelocity,PHYS_META.ApplyForceCenter,PHYS_META.ApplyForceOffset,PHYS_META.ApplyTorqueCenter,PHYS_META.CalculateForceOffset,PHYS_META.CalculateVelocityOffset,PHYS_META.ClearGameFlag,PHYS_META.EnableDrag,PHYS_META.EnableGravity,PHYS_META.EnableMotion,PHYS_META.GetAABB,PHYS_META.GetAngleVelocity,PHYS_META.GetAngles,PHYS_META.GetDamping,PHYS_META.GetEntity,PHYS_META.GetFrictionSnapshot,PHYS_META.GetInertia,PHYS_META.GetMass,PHYS_META.GetMassCenter,PHYS_META.GetMaterial,PHYS_META.GetMesh,PHYS_META.GetMeshConvexes,PHYS_META.GetPos,PHYS_META.GetPositionMatrix,PHYS_META.GetStress,PHYS_META.GetSurfaceArea,PHYS_META.GetVelocity,PHYS_META.GetVelocityAtPoint,PHYS_META.GetVolume,PHYS_META.HasGameFlag,PHYS_META.IsAsleep,PHYS_META.IsDragEnabled,PHYS_META.IsGravityEnabled,PHYS_META.IsMoveable,PHYS_META.IsValid,PHYS_META.LocalToWorld,PHYS_META.LocalToWorldVector,PHYS_META.SetAngleDragCoefficient,PHYS_META.SetAngleVelocity,PHYS_META.SetAngles,PHYS_META.SetBuoyancyRatio,PHYS_META.SetContents,PHYS_META.SetDamping,PHYS_META.SetDragCoefficient,PHYS_META.SetInertia,PHYS_META.SetMass,PHYS_META.SetMaterial,PHYS_META.SetPos,PHYS_META.SetVelocity,PHYS_META.Sleep,PHYS_META.Wake,PHYS_META.WorldToLocal,PHYS_META.WorldToLocalVector


local physobj_methods, physobj_meta, wrap, unwrap = instance.Types.PhysObj.Methods, instance.Types.PhysObj, instance.Types.PhysObj.Wrap, instance.Types.PhysObj.Unwrap
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local mtx_meta, mwrap, munwrap = instance.Types.VMatrix, instance.Types.VMatrix.Wrap, instance.Types.VMatrix.Unwrap

local vunwrap1, vunwrap2
local aunwrap1
instance:AddHook("initialize", function()
	vunwrap1, vunwrap2 = vec_meta.QuickUnwrap1, vec_meta.QuickUnwrap2
	aunwrap1 = ang_meta.QuickUnwrap1
end)

--- Checks if the physics object is valid
-- @shared
-- @return boolean If the physics object is valid
function physobj_methods:isValid()
	return Phys_IsValid(unwrap(self))
end

--- Gets the entity attached to the physics object
-- @shared
-- @return Entity The entity attached to the physics object
function physobj_methods:getEntity()
	return ewrap(Phys_GetEntity(unwrap(self)))
end

--- Gets the position of the physics object
-- @shared
-- @return Vector Vector position of the physics object
function physobj_methods:getPos()
	return vwrap(Phys_GetPos(unwrap(self)))
end

--- Returns the world transform matrix of the physobj
-- @shared
-- @return VMatrix The matrix
function physobj_methods:getMatrix()
	return mwrap(Phys_GetPositionMatrix(unwrap(self)))
end

--- Gets the angles of the physics object
-- @shared
-- @return Angle Angle angles of the physics object
function physobj_methods:getAngles()
	return awrap(Phys_GetAngles(unwrap(self)))
end

--- Gets the velocity of the physics object
-- @shared
-- @return Vector Vector velocity of the physics object
function physobj_methods:getVelocity()
	return vwrap(Phys_GetVelocity(unwrap(self)))
end

--- Gets the velocity of the physics object in coordinates local to itself
-- @shared
-- @return Vector Vector velocity of the physics object local to itself
function physobj_methods:getLocalVelocity()
	local phys = unwrap(self)
	return vwrap(Phys_WorldToLocalVector(phys, Phys_GetVelocity(phys)))
end

--- Gets the axis aligned bounding box of the physics object
-- @shared
-- @return Vector The mins of the AABB
-- @return Vector The maxs of the AABB
function physobj_methods:getAABB()
	local a, b = Phys_GetAABB(unwrap(self))
	return vwrap(a), vwrap(b)
end

--- Gets the velocity of the physics object at an arbitrary point in its local reference frame
--- This includes velocity at the point induced by rotational velocity
-- @shared
-- @param Vector vec The point to get velocity of in local reference frame
-- @return Vector Vector Local velocity of the physics object at the point
function physobj_methods:getVelocityAtPoint(vec)
	return vwrap(Phys_GetVelocityAtPoint(unwrap(self), vunwrap1(vec)))
end

--- Gets the angular velocity of the physics object
-- @shared
-- @return Vector Vector angular velocity of the physics object
function physobj_methods:getAngleVelocity()
	return vwrap(Phys_GetAngleVelocity(unwrap(self)))
end

--- Gets the mass of the physics object
-- @shared
-- @return number Mass of the physics object
function physobj_methods:getMass()
	return Phys_GetMass(unwrap(self))
end

--- Gets the center of mass of the physics object in the local reference frame.
-- @shared
-- @return Vector Center of mass vector in the physobject's local reference frame.
function physobj_methods:getMassCenter()
	return vwrap(Phys_GetMassCenter(unwrap(self)))
end

--- Gets the inertia of the physics object
-- @shared
-- @return Vector Vector Inertia of the physics object
function physobj_methods:getInertia()
	return vwrap(Phys_GetInertia(unwrap(self)))
end

--- Gets the material of the physics object
-- @shared
-- @return string The physics material of the physics object
function physobj_methods:getMaterial()
	return Phys_GetMaterial(unwrap(self))
end

--- Returns a vector in the local reference frame of the physicsobject from the world frame
-- @param Vector vec The vector to transform
-- @return Vector The transformed vector
function physobj_methods:worldToLocal(vec)
	return vwrap(Phys_WorldToLocal(unwrap(self), vunwrap1(vec)))
end

--- Returns a vector in the reference frame of the world from the local frame of the physicsobject
-- @param Vector vec The vector to transform
-- @return Vector The transformed vector
function physobj_methods:localToWorld(vec)
	return vwrap(Phys_LocalToWorld(unwrap(self), vunwrap1(vec)))
end

--- Returns a normal vector in the local reference frame of the physicsobject from the world frame
-- @param Vector vec The normal vector to transform
-- @return Vector The transformed vector
function physobj_methods:worldToLocalVector(vec)
	return vwrap(Phys_WorldToLocalVector(unwrap(self), vunwrap1(vec)))
end

--- Returns a normal vector in the reference frame of the world from the local frame of the physicsobject
-- @param Vector vec The normal vector to transform
-- @return Vector The transformed vector
function physobj_methods:localToWorldVector(vec)
	return vwrap(Phys_LocalToWorldVector(unwrap(self), vunwrap1(vec)))
end

--- Returns a table of MeshVertex structures where each 3 vertices represent a triangle. See: http://wiki.facepunch.com/gmod/Structures/MeshVertex
-- @return table Table of MeshVertex structures
function physobj_methods:getMesh()
	return instance.Sanitize(Phys_GetMesh(unwrap(self)))
end

--- Returns a structured table, the physics mesh of the physics object. See: http://wiki.facepunch.com/gmod/Structures/MeshVertex
-- @return table Table of MeshVertex structures
function physobj_methods:getMeshConvexes()
	return instance.Sanitize(Phys_GetMeshConvexes(unwrap(self)))
end

--- Sets the physical material of a physics object
-- @param string materialName The physical material to set it to
function physobj_methods:setMaterial(material)
	checkluatype(material, TYPE_STRING)
	local phys = unwrap(self)
	checkpermission(instance, Phys_GetEntity(phys), "entities.setRenderProperty")
	Phys_SetMaterial(phys, material)
	if not Phys_IsMoveable(phys) then
		Phys_EnableMotion(phys, true)
		Phys_EnableMotion(phys, false)
	end
end

--- Returns the surface area of the object in Hammer units squared.
-- @return number? Surface area, or nil if a generated sphere or box
function physobj_methods:getSurfaceArea()
	return Phys_GetSurfaceArea(unwrap(self))
end

--- Returns whether the entity is able to move.
-- Inverse of Entity:isFrozen
-- @return boolean Whether the object is moveable
function physobj_methods:isMoveable()
	return Phys_IsMoveable(unwrap(self))
end

--- Returns whether the entity is affected by gravity.
-- @shared
-- @return boolean Whether the object is affect gravity
function physobj_methods:isGravityEnabled()
	return Phys_IsGravityEnabled(unwrap(self))
end

if SERVER then
	--- Sets the position of the physics object. Will cause interpolation of the entity in clientside, use entity.setPos to avoid this.
	-- @server
	-- @param Vector pos The position vector to set it to
	function physobj_methods:setPos(pos)
		pos = vunwrap1(pos)
		checkvector(pos)

		local phys = unwrap(self)
		checkpermission(instance, Phys_GetEntity(phys), "entities.setPos")
		Phys_SetPos(phys, pos)
	end

	--- Sets the angles of the physics object. Will cause interpolation of the entity in clientside, use entity.setAngles to avoid this.
	-- @server
	-- @param Angle ang The angle to set it to
	function physobj_methods:setAngles(ang)
		ang = aunwrap1(ang)
		checkvector(ang)

		local phys = unwrap(self)
		checkpermission(instance, Phys_GetEntity(phys), "entities.setAngles")
		Phys_SetAngles(phys, ang)
	end

	--- Sets the velocity of the physics object
	-- @server
	-- @param Vector vel The velocity vector to set it to
	function physobj_methods:setVelocity(vel)
		vel = vunwrap1(vel)
		checkvector(vel)

		local phys = unwrap(self)
		checkpermission(instance, Phys_GetEntity(phys), "entities.setVelocity")
		Phys_SetVelocity(phys, vel)
	end

    --- Applies velocity to an object
    -- @server
    -- @param Vector vel The world velocity vector to apply
    function physobj_methods:addVelocity(vel)
        vel = vunwrap1(vel)
        checkvector(vel)

        local phys = unwrap(self)
        checkpermission(instance, Phys_GetEntity(phys), "entities.applyForce")
        Phys_AddVelocity(phys, vel)
    end

	--- Sets the buoyancy ratio of a physobject
	-- @server
	-- @param number ratio The buoyancy ratio to use
	function physobj_methods:setBuoyancyRatio(ratio)
		checkluatype(ratio, TYPE_NUMBER)
		checknumber(ratio)

		local phys = unwrap(self)
		checkpermission(instance, Phys_GetEntity(phys), "entities.setMass")
		Phys_SetBuoyancyRatio(phys, ratio)
	end

	--- Sets the contents flag of the physobject
	-- @server
	-- @param number contents The CONTENTS enum
	function physobj_methods:setContents(contents)
		checkluatype(contents, TYPE_NUMBER)
		local phys = unwrap(self)
		checkpermission(instance, Phys_GetEntity(phys), "entities.setContents")
		Phys_SetContents(phys, contents)
	end

	--- Applies a force to the center of the physics object
	-- @server
	-- @param Vector force The force vector to apply
	function physobj_methods:applyForceCenter(force)
		force = vunwrap1(force)
		checkvector(force)

		local phys = unwrap(self)
		checkpermission(instance, Phys_GetEntity(phys), "entities.applyForce")
		Phys_ApplyForceCenter(phys, force)
	end

	--- Applies an offset force to a physics object
	-- @server
	-- @param Vector force The force vector in world coordinates
	-- @param Vector position The force position in world coordinates
	function physobj_methods:applyForceOffset(force, position)
		force = vunwrap1(force)
		checkvector(force)
		position = vunwrap2(position)
		checkvector(position)

		local phys = unwrap(self)
		checkpermission(instance, Phys_GetEntity(phys), "entities.applyForce")
		Phys_ApplyForceOffset(phys, force, position)
	end

	--- Sets the angular velocity of an object
	-- @server
	-- @param Vector angvel The local angvel vector to set
	function physobj_methods:setAngleVelocity(angvel)
		angvel = vunwrap1(angvel)
		checkvector(angvel)

		local phys = unwrap(self)
		checkpermission(instance, Phys_GetEntity(phys), "entities.applyForce")

		Phys_SetAngleVelocity(phys, angvel)
	end

	--- Applies a angular velocity to an object
	-- @server
	-- @param Vector angvel The local angvel vector to apply
	function physobj_methods:addAngleVelocity(angvel)
		angvel = vunwrap1(angvel)
		checkvector(angvel)

		local phys = unwrap(self)
		checkpermission(instance, Phys_GetEntity(phys), "entities.applyForce")

		Phys_AddAngleVelocity(phys, angvel)
	end

	--- Applies a torque to a physics object
	-- @server
	-- @param Vector torque The world torque vector to apply
	function physobj_methods:applyTorque(torque)
		torque = vunwrap1(torque)
		checkvector(torque)

		local phys = unwrap(self)
		checkpermission(instance, Phys_GetEntity(phys), "entities.applyForce")

		Phys_ApplyTorqueCenter(phys, torque)
	end

	--- Sets the mass of a physics object
	-- @server
	-- @param number mass The mass to set it to
	function physobj_methods:setMass(mass)
		checkluatype(mass, TYPE_NUMBER)
		local phys = unwrap(self)
		local ent = Phys_GetEntity(phys)
		checkpermission(instance, ent, "entities.setMass")
		local m = math.Clamp(mass, 1, 50000)
		Phys_SetMass(phys, m)
		duplicator.StoreEntityModifier(ent, "mass", { Mass = m })
	end

	--- Sets the inertia of a physics object
	-- @server
	-- @param Vector inertia The inertia vector to set it to
	function physobj_methods:setInertia(inertia)
		local phys = unwrap(self)
		checkpermission(instance, Phys_GetEntity(phys), "entities.setInertia")

		local vec = vunwrap1(inertia)
		checkvector(vec)
		vec[1] = math.Clamp(vec[1], 1, 100000)
		vec[2] = math.Clamp(vec[2], 1, 100000)
		vec[3] = math.Clamp(vec[3], 1, 100000)

		Phys_SetInertia(phys, vec)
	end


	local validGameFlags = FVPHYSICS_DMG_DISSOLVE + FVPHYSICS_DMG_SLICE + FVPHYSICS_HEAVY_OBJECT + FVPHYSICS_NO_IMPACT_DMG +
		FVPHYSICS_NO_NPC_IMPACT_DMG + FVPHYSICS_NO_PLAYER_PICKUP
	--- Adds game flags to the physics object. Some flags cannot be modified. Can be:
	-- FVPHYSICS.DMG_DISSOLVE
	-- FVPHYSICS.DMG_SLICE
	-- FVPHYSICS.HEAVY_OBJECT
	-- FVPHYSICS.NO_IMPACT_DMG
	-- FVPHYSICS.NO_NPC_IMPACT_DMG
	-- FVPHYSICS.NO_PLAYER_PICKUP
	-- @param number flags The flags to add. FVPHYSICS enum.
	function physobj_methods:addGameFlags(flags)
		checkluatype(flags, TYPE_NUMBER)
		local phys = unwrap(self)
		checkpermission(instance, Phys_GetEntity(phys), "entities.canTool")
		local invalidFlags = bit.band(bit.bnot(validGameFlags), flags)
		if invalidFlags == 0 then
			Phys_AddGameFlag(phys, flags)
		else
			SF.Throw("Invalid flags " .. invalidFlags, 2)
		end
	end

	--- Clears game flags from the physics object. Some flags cannot be modified. Can be:
	-- FVPHYSICS.DMG_DISSOLVE
	-- FVPHYSICS.DMG_SLICE
	-- FVPHYSICS.HEAVY_OBJECT
	-- FVPHYSICS.NO_IMPACT_DMG
	-- FVPHYSICS.NO_NPC_IMPACT_DMG
	-- FVPHYSICS.NO_PLAYER_PICKUP
	-- @param number flags The flags to clear. FVPHYSICS enum.
	function physobj_methods:clearGameFlags(flags)
		checkluatype(flags, TYPE_NUMBER)
		local phys = unwrap(self)
		checkpermission(instance, Phys_GetEntity(phys), "entities.canTool")
		local invalidFlags = bit.band(bit.bnot(validGameFlags), flags)
		if invalidFlags == 0 then
			Phys_ClearGameFlag(phys, flags)
		else
			SF.Throw("Invalid flags " .. invalidFlags, 2)
		end
	end

	--- Returns whether the game flags of the physics object are set.
	-- @param number flags The flags to test. FVPHYSICS enum.
	-- @return boolean If the flags are set
	function physobj_methods:hasGameFlags(flags)
		checkluatype(flags, TYPE_NUMBER)
		return Phys_HasGameFlag(unwrap(self), flags)
	end

	--- Sets bone gravity
	-- @param boolean grav Should the bone respect gravity?
	function physobj_methods:enableGravity(grav)
		local phys = unwrap(self)
		checkpermission(instance, Phys_GetEntity(phys), "entities.enableGravity")
		Phys_EnableGravity(phys, grav and true or false)
		Phys_Wake(phys)
	end

	--- Sets the bone drag state
	-- @param boolean drag Should the bone have air resistance?
	function physobj_methods:enableDrag(drag)
		local phys = unwrap(self)
		checkpermission(instance, Phys_GetEntity(phys), "entities.enableDrag")
		Phys_EnableDrag(phys, drag and true or false)
	end

	--- Check if bone is affected by air resistance
	-- @return boolean If bone is affected by drag
	function physobj_methods:isDragEnabled()
		return Phys_IsDragEnabled(unwrap(self))
	end

	--- Sets coefficient of air resistance affecting the bone. Air resistance depends on the cross-section of the object.
	-- @param number coeff How much drag affects the bone
	function physobj_methods:setDragCoefficient(coeff)
		checkluatype(coeff, TYPE_NUMBER)
		local phys = unwrap(self)
		checkpermission(instance, Phys_GetEntity(phys), "entities.enableDrag")
		Phys_SetDragCoefficient(phys, coeff)
	end

	--- Sets coefficient of air resistance affecting the bone when rotating. Air resistance depends on the cross-section of the object.
	-- @param number coeff How much drag affects the bone when rotating
	function physobj_methods:setAngleDragCoefficient(coeff)
		checkluatype(coeff, TYPE_NUMBER)
		local phys = unwrap(self)
		checkpermission(instance, Phys_GetEntity(phys), "entities.enableDrag")
		Phys_SetAngleDragCoefficient(phys, coeff)
	end

	--- Returns Movement damping of the bone.
	-- @return number Linear damping
	-- @return number Angular damping
	function physobj_methods:getDamping()
		return Phys_GetDamping(unwrap(self))
	end

	--- Sets the movement damping of the bone. Unlike air drag, it doesn't take into account the cross-section of the object.
	-- @param number linear Number of the linear damping
	-- @param number angular Number of the angular damping
	function physobj_methods:setDamping(linear, angular)
		checkluatype(linear, TYPE_NUMBER)
		checkluatype(angular, TYPE_NUMBER)
		checknumber(linear)
		checknumber(angular)
		local phys = unwrap(self)
		checkpermission(instance, Phys_GetEntity(phys), "entities.setDamping")
		Phys_SetDamping(phys, linear, angular)
	end

	--- Sets the bone movement state
	-- @param boolean move Should the bone move?
	function physobj_methods:enableMotion(move)
		local phys = unwrap(self)
		checkpermission(instance, Phys_GetEntity(phys), "entities.enableMotion")
		Phys_EnableMotion(phys, move and true or false)
		Phys_Wake(phys)
	end

	--- Returns whether the physobj is asleep
	-- @server
	-- @return boolean If the physobj is asleep
	function physobj_methods:isAsleep()
		return Phys_IsAsleep(unwrap(self))
	end

	--- Makes a physobj go to sleep. (like it's frozen but interacting wakes it back up)
	-- @server
	function physobj_methods:sleep()
		local phys = unwrap(self)
		checkpermission(instance, Phys_GetEntity(phys), "entities.applyForce")
		Phys_Sleep(phys)
	end

	--- Makes a sleeping physobj wakeup
	-- @server
	function physobj_methods:wake()
		local phys = unwrap(self)
		checkpermission(instance, Phys_GetEntity(phys), "entities.applyForce")
		Phys_Wake(phys)
	end

	--- Returns table of tables of friction data of a contact against the physobj
	-- @server
	-- @return table Table of tables of data. Each table will contain:
	-- PhysObj Other - The other physics object we came in contact with
	-- number EnergyAbsorbed -
	-- number FrictionCoefficient -
	-- number NormalForce -
	-- Vector Normal - Direction of the friction event
	-- Vector ContactPoint - Contact point of the friction event
	-- number Material - Surface Property ID of our physics obj
	-- number MaterialOther - Surface Property ID of the physics obj we came in contact with
	function physobj_methods:getFrictionSnapshot()
		local result = {}
		for k, v in ipairs(Phys_GetFrictionSnapshot(unwrap(self))) do
			result[k] = SF.StructWrapper(instance, v)
		end
		return result
	end

	--- Returns the volume in source units cubed. Or nil if the PhysObj is a generated sphere or box.
	-- @shared
	-- @return number? The volume or nil if the PhysObj is a generated sphere or box.
	function physobj_methods:getVolume()
		return Phys_GetVolume(unwrap(self))
	end
	
	--- Returns the stress of the entity.
	-- @server
	-- @return number External stress. Usually about the mass of the object if on the ground, usually 0 if in freefall.
	-- @return number Internal stress. Usually about the mass of every object resting on top of it combined.
	function physobj_methods:getStress()
		return Phys_GetStress(unwrap(self))
	end

	--- Calculates the linear and angular impulse on the object's center of mass for an offset impulse.
	--- The outputs can be used with PhysObj:applyForceCenter and PhysObj:applyTorque, respectively.
	---
	--- Be careful to convert the angular impulse to world frame (PhysObj:localToWorldVector)
	--- if you are going to use it with applyTorque.
	-- @server
	-- @param Vector impulse The impulse acting on the object in world coordinates (kg*source_unit/s)
	-- @param Vector position The location of the impulse in world coordinates
	-- @return Vector The calculated linear impulse on the physics object's center of mass in kg*source_unit/s. (World frame)
	-- @return Vector The calculated angular impulse on the physics object's center of mass in kg*m^2*degrees/s. (Local frame)
	function physobj_methods:calculateForceOffset(impulse, position)
		impulse = vunwrap1(impulse)
		position = vunwrap2(position)

		checkvector(impulse)
		checkvector(position)

		local linearImpulse, angularImpulse = Phys_CalculateForceOffset(unwrap(self), impulse, position)

		return vwrap(linearImpulse), vwrap(angularImpulse)
	end

	--- Calculates the linear and angular velocities on the center of mass for an offset impulse.
	--- The outputs can be directly passed to PhysObj:addVelocity and PhysObj:addAngleVelocity, respectively.
	-- @server
	-- @param Vector impulse The impulse acting on the object in world coordinates (kg*source_unit/s)
	-- @param Vector position The location of the impulse in world coordinates
	-- @return Vector The calculated linear velocity from the impulse on the physics object's center of mass in source_unit/s. (World frame)
	-- @return Vector The calculated angular velocity from the impulse on the physics object's center of mass in degrees/s. (Local frame)
	function physobj_methods:calculateVelocityOffset(impulse, position)
		impulse = vunwrap1(impulse)
		position = vunwrap2(position)

		checkvector(impulse)
		checkvector(position)

		local linearVelocity, angularVelocity = Phys_CalculateVelocityOffset(unwrap(self), impulse, position)

		return vwrap(linearVelocity), vwrap(angularVelocity)
	end
end

end
