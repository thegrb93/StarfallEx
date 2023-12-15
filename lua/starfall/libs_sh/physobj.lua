-- Global to all starfalls
local checkluatype = SF.CheckLuaType

local function checknumber(n)
	if n<-1e12 or n>1e12 or n~=n then
		SF.Throw("Input number too large or NAN", 3)
	end
end

local function checkvector(v)
	if v[1]<-1e12 or v[1]>1e12 or v[1]~=v[1] or
	   v[2]<-1e12 or v[2]>1e12 or v[2]~=v[2] or
	   v[3]<-1e12 or v[3]>1e12 or v[3]~=v[3] then

		SF.Throw("Input vector too large or NAN", 3)

	end
end


--- PhysObj Type
-- @name PhysObj
-- @class type
-- @libtbl physobj_methods
SF.RegisterType("PhysObj", true, false)


return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end


local physobj_methods, physobj_meta, wrap, unwrap = instance.Types.PhysObj.Methods, instance.Types.PhysObj, instance.Types.PhysObj.Wrap, instance.Types.PhysObj.Unwrap
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local mtx_meta, mwrap, munwrap = instance.Types.VMatrix, instance.Types.VMatrix.Wrap, instance.Types.VMatrix.Unwrap


--- Checks if the physics object is valid
-- @shared
-- @return boolean If the physics object is valid
function physobj_methods:isValid()
	return unwrap(self):IsValid()
end

--- Gets the entity attached to the physics object
-- @shared
-- @return Entity The entity attached to the physics object
function physobj_methods:getEntity()
	return ewrap(unwrap(self):GetEntity())
end

--- Gets the position of the physics object
-- @shared
-- @return Vector Vector position of the physics object
function physobj_methods:getPos()
	return vwrap(unwrap(self):GetPos())
end

--- Returns the world transform matrix of the physobj
-- @shared
-- @return VMatrix The matrix
function physobj_methods:getMatrix()
	return mwrap(unwrap(self):GetPositionMatrix())
end

--- Gets the angles of the physics object
-- @shared
-- @return Angle Angle angles of the physics object
function physobj_methods:getAngles()
	return awrap(unwrap(self):GetAngles())
end

--- Gets the velocity of the physics object
-- @shared
-- @return Vector Vector velocity of the physics object
function physobj_methods:getVelocity()
	return vwrap(unwrap(self):GetVelocity())
end

--- Gets the velocity of the physics object in coordinates local to itself
-- @shared
-- @return Vector Vector velocity of the physics object local to itself
function physobj_methods:getLocalVelocity()
	local phys = unwrap(self)
	return vwrap(phys:WorldToLocalVector(phys:GetVelocity()))
end

--- Gets the axis aligned bounding box of the physics object
-- @shared
-- @return Vector The mins of the AABB
-- @return Vector The maxs of the AABB
function physobj_methods:getAABB()
	local a, b = unwrap(self):GetAABB()
	return vwrap(a), vwrap(b)
end

--- Gets the velocity of the physics object at an arbitrary point in its local reference frame
--- This includes velocity at the point induced by rotational velocity
-- @shared
-- @param Vector vec The point to get velocity of in local reference frame
-- @return Vector Vector Local velocity of the physics object at the point
function physobj_methods:getVelocityAtPoint(vec)
	return vwrap(unwrap(self):GetVelocityAtPoint(vunwrap(vec)))
end

--- Gets the angular velocity of the physics object
-- @shared
-- @return Vector Vector angular velocity of the physics object
function physobj_methods:getAngleVelocity()
	return vwrap(unwrap(self):GetAngleVelocity())
end

--- Gets the mass of the physics object
-- @shared
-- @return number Mass of the physics object
function physobj_methods:getMass()
	return unwrap(self):GetMass()
end

--- Gets the center of mass of the physics object in the local reference frame.
-- @shared
-- @return Vector Center of mass vector in the physobject's local reference frame.
function physobj_methods:getMassCenter()
	return vwrap(unwrap(self):GetMassCenter())
end

--- Gets the inertia of the physics object
-- @shared
-- @return Vector Vector Inertia of the physics object
function physobj_methods:getInertia()
	return vwrap(unwrap(self):GetInertia())
end

--- Gets the material of the physics object
-- @shared
-- @return string The physics material of the physics object
function physobj_methods:getMaterial()
	return unwrap(self):GetMaterial()
end

--- Returns a vector in the local reference frame of the physicsobject from the world frame
-- @param Vector vec The vector to transform
-- @return Vector The transformed vector
function physobj_methods:worldToLocal(vec)
	return vwrap(unwrap(self):WorldToLocal(vunwrap(vec)))
end

--- Returns a vector in the reference frame of the world from the local frame of the physicsobject
-- @param Vector vec The vector to transform
-- @return Vector The transformed vector
function physobj_methods:localToWorld(vec)
	return vwrap(unwrap(self):LocalToWorld(vunwrap(vec)))
end

--- Returns a normal vector in the local reference frame of the physicsobject from the world frame
-- @param Vector vec The normal vector to transform
-- @return Vector The transformed vector
function physobj_methods:worldToLocalVector(vec)
	return vwrap(unwrap(self):WorldToLocalVector(vunwrap(vec)))
end

--- Returns a normal vector in the reference frame of the world from the local frame of the physicsobject
-- @param Vector vec The normal vector to transform
-- @return Vector The transformed vector
function physobj_methods:localToWorldVector(vec)
	return vwrap(unwrap(self):LocalToWorldVector(vunwrap(vec)))
end

--- Returns a table of MeshVertex structures where each 3 vertices represent a triangle. See: http://wiki.facepunch.com/gmod/Structures/MeshVertex
-- @return table Table of MeshVertex structures
function physobj_methods:getMesh()
	local mesh = unwrap(self):GetMesh()
	return instance.Sanitize(mesh)
end

--- Returns a structured table, the physics mesh of the physics object. See: http://wiki.facepunch.com/gmod/Structures/MeshVertex
-- @return table Table of MeshVertex structures
function physobj_methods:getMeshConvexes()
	local mesh = unwrap(self):GetMeshConvexes()
	return instance.Sanitize(mesh)
end

--- Sets the physical material of a physics object
-- @param string materialName The physical material to set it to
function physobj_methods:setMaterial(material)
	checkluatype (material, TYPE_STRING)
	local phys = unwrap(self)
	checkpermission(instance, phys:GetEntity(), "entities.setRenderProperty")
	phys:SetMaterial(material)
	if not phys:IsMoveable() then
		phys:EnableMotion(true)
		phys:EnableMotion(false)
	end
end

--- Returns the surface area of the object in Hammer units squared.
-- @return number? Surface area, or nil if a generated sphere or box
function physobj_methods:getSurfaceArea()
	return unwrap(self):GetSurfaceArea()
end

--- Returns whether the entity is able to move.
-- Inverse of Entity:isFrozen
-- @return boolean Whether the object is moveable
function physobj_methods:isMoveable()
	return unwrap(self):IsMoveable()
end

--- Returns whether the entity is affected by gravity.
-- @shared
-- @return boolean Whether the object is affect gravity
function physobj_methods:isGravityEnabled()
	return unwrap(self):IsGravityEnabled()
end

if SERVER then
	--- Sets the position of the physics object. Will cause interpolation of the entity in clientside, use entity.setPos to avoid this.
	-- @server
	-- @param Vector pos The position vector to set it to
	function physobj_methods:setPos(pos)

		pos = vunwrap(pos)
		checkvector(pos)

		local phys = unwrap(self)
		checkpermission(instance, phys:GetEntity(), "entities.setPos")
		phys:SetPos(pos)
	end

	--- Sets the angles of the physics object. Will cause interpolation of the entity in clientside, use entity.setAngles to avoid this.
	-- @server
	-- @param Angle ang The angle to set it to
	function physobj_methods:setAngles(ang)

		ang = aunwrap(ang)
		checkvector(ang)

		local phys = unwrap(self)
		checkpermission(instance, phys:GetEntity(), "entities.setAngles")
		phys:SetAngles(ang)
	end

	--- Sets the velocity of the physics object
	-- @server
	-- @param Vector vel The velocity vector to set it to
	function physobj_methods:setVelocity(vel)

		vel = vunwrap(vel)
		checkvector(vel)

		local phys = unwrap(self)
		checkpermission(instance, phys:GetEntity(), "entities.setVelocity")
		phys:SetVelocity(vel)
	end

    --- Applies velocity to an object
    -- @server
    -- @param Vector vel The world velocity vector to apply
    function physobj_methods:addVelocity(vel)
        vel = vunwrap(vel)
        checkvector(vel)

        local phys = unwrap(self)
        checkpermission(instance, phys:GetEntity(), "entities.applyForce")
        phys:AddVelocity(vel)
    end

	--- Sets the buoyancy ratio of a physobject
	-- @server
	-- @param number ratio The buoyancy ratio to use
	function physobj_methods:setBuoyancyRatio(ratio)
		checkluatype(ratio, TYPE_NUMBER)

		if ratio<-1e12 or ratio>1e12 or ratio~=ratio then
			SF.Throw("Input number too large or NAN", 2)
		end

		local phys = unwrap(self)
		checkpermission(instance, phys:GetEntity(), "entities.setMass")
		phys:SetBuoyancyRatio(ratio)
	end

	--- Applies a force to the center of the physics object
	-- @server
	-- @param Vector force The force vector to apply
	function physobj_methods:applyForceCenter(force)

		force = vunwrap(force)
		checkvector(force)

		local phys = unwrap(self)
		checkpermission(instance, phys:GetEntity(), "entities.applyForce")
		phys:ApplyForceCenter(force)
	end

	--- Applies an offset force to a physics object
	-- @server
	-- @param Vector force The force vector in world coordinates
	-- @param Vector position The force position in world coordinates
	function physobj_methods:applyForceOffset(force, position)

		force = vunwrap(force)
		checkvector(force)
		position = vunwrap(position)
		checkvector(position)

		local phys = unwrap(self)
		checkpermission(instance, phys:GetEntity(), "entities.applyForce")
		phys:ApplyForceOffset(force, position)
	end

	--- Sets the angular velocity of an object
	-- @server
	-- @param Vector angvel The local angvel vector to set
	function physobj_methods:setAngleVelocity(angvel)
		angvel = vunwrap(angvel)
		checkvector(angvel)

		local phys = unwrap(self)
		checkpermission(instance, phys:GetEntity(), "entities.applyForce")

		phys:AddAngleVelocity(angvel - phys:GetAngleVelocity())
	end

	--- Applies a angular velocity to an object
	-- @server
	-- @param Vector angvel The local angvel vector to apply
	function physobj_methods:addAngleVelocity(angvel)
		angvel = vunwrap(angvel)
		checkvector(angvel)

		local phys = unwrap(self)
		checkpermission(instance, phys:GetEntity(), "entities.applyForce")

		phys:AddAngleVelocity(angvel)
	end

	--- Applies a torque to a physics object
	-- @server
	-- @param Vector torque The world torque vector to apply
	function physobj_methods:applyTorque(torque)
		torque = vunwrap(torque)
		checkvector(torque)

		local phys = unwrap(self)
		checkpermission(instance, phys:GetEntity(), "entities.applyForce")

		phys:ApplyTorqueCenter(torque)
	end

	--- Sets the mass of a physics object
	-- @server
	-- @param number mass The mass to set it to
	function physobj_methods:setMass(mass)
		checkluatype(mass, TYPE_NUMBER)
		local phys = unwrap(self)
		local ent = phys:GetEntity()
		checkpermission(instance, ent, "entities.setMass")
		local m = math.Clamp(mass, 1, 50000)
		phys:SetMass(m)
		duplicator.StoreEntityModifier(ent, "mass", { Mass = m })
	end

	--- Sets the inertia of a physics object
	-- @server
	-- @param Vector inertia The inertia vector to set it to
	function physobj_methods:setInertia(inertia)
		local phys = unwrap(self)
		checkpermission(instance, phys:GetEntity(), "entities.setInertia")

		local vec = vunwrap(inertia)
		checkvector(vec)
		vec[1] = math.Clamp(vec[1], 1, 100000)
		vec[2] = math.Clamp(vec[2], 1, 100000)
		vec[3] = math.Clamp(vec[3], 1, 100000)

		phys:SetInertia(vec)
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
		checkpermission(instance, phys:GetEntity(), "entities.canTool")
		local invalidFlags = bit.band(bit.bnot(validGameFlags), flags)
		if invalidFlags == 0 then
			phys:AddGameFlag(flags)
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
		checkpermission(instance, phys:GetEntity(), "entities.canTool")
		local invalidFlags = bit.band(bit.bnot(validGameFlags), flags)
		if invalidFlags == 0 then
			phys:ClearGameFlag(flags)
		else
			SF.Throw("Invalid flags " .. invalidFlags, 2)
		end
	end

	--- Returns whether the game flags of the physics object are set.
	-- @param number flags The flags to test. FVPHYSICS enum.
	-- @return boolean If the flags are set
	function physobj_methods:hasGameFlags(flags)
		checkluatype(flags, TYPE_NUMBER)
		local phys = unwrap(self)
		return phys:HasGameFlag(flags)
	end

	--- Sets bone gravity
	-- @param boolean grav Should the bone respect gravity?
	function physobj_methods:enableGravity(grav)
		local phys = unwrap(self)
		checkpermission(instance, phys:GetEntity(), "entities.enableGravity")
		phys:EnableGravity(grav and true or false)
		phys:Wake()
	end

	--- Sets the bone drag state
	-- @param boolean drag Should the bone have air resistance?
	function physobj_methods:enableDrag(drag)
		local phys = unwrap(self)
		checkpermission(instance, phys:GetEntity(), "entities.enableDrag")
		phys:EnableDrag(drag and true or false)
	end

	--- Check if bone is affected by air resistance
	-- @return boolean If bone is affected by drag
	function physobj_methods:isDragEnabled()
		local phys = unwrap(self)
		return phys:IsDragEnabled()
	end

	--- Sets coefficient of air resistance affecting the bone. Air resistance depends on the cross-section of the object.
	-- @param number coeff How much drag affects the bone
	function physobj_methods:setDragCoefficient(coeff)
		checkluatype(coeff, TYPE_NUMBER)
		local phys = unwrap(self)
		checkpermission(instance, phys:GetEntity(), "entities.enableDrag")
		phys:SetDragCoefficient(coeff)
	end

	--- Sets coefficient of air resistance affecting the bone when rotating. Air resistance depends on the cross-section of the object.
	-- @param number coeff How much drag affects the bone when rotating
	function physobj_methods:setAngleDragCoefficient(coeff)
		checkluatype(coeff, TYPE_NUMBER)
		local phys = unwrap(self)
		checkpermission(instance, phys:GetEntity(), "entities.enableDrag")
		phys:SetAngleDragCoefficient(coeff)
	end

	--- Returns Movement damping of the bone.
	-- @return number Linear damping
	-- @return number Angular damping
	function physobj_methods:getDamping()
		local phys = unwrap(self)
		return phys:GetDamping()
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
		checkpermission(instance, phys:GetEntity(), "entities.setDamping")
		phys:SetDamping(linear, angular)
	end

	--- Sets the bone movement state
	-- @param boolean move Should the bone move?
	function physobj_methods:enableMotion(move)
		local phys = unwrap(self)
		checkpermission(instance, phys:GetEntity(), "entities.enableMotion")
		phys:EnableMotion(move and true or false)
		phys:Wake()
	end

	--- Returns whether the physobj is asleep
	-- @server
	-- @return boolean If the physobj is asleep
	function physobj_methods:isAsleep()
		local phys = unwrap(self)
		return phys:IsAsleep()
	end

	--- Makes a physobj go to sleep. (like it's frozen but interacting wakes it back up)
	-- @server
	function physobj_methods:sleep()
		local phys = unwrap(self)
		checkpermission(instance, phys:GetEntity(), "entities.applyForce")
		phys:Sleep()
	end

	--- Makes a sleeping physobj wakeup
	-- @server
	function physobj_methods:wake()
		local phys = unwrap(self)
		checkpermission(instance, phys:GetEntity(), "entities.applyForce")
		phys:Wake()
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
		for k, v in ipairs(unwrap(self):GetFrictionSnapshot()) do
			result[k] = SF.StructWrapper(instance, v)
		end
		return result
	end

	--- Returns the volume in source units cubed. Or nil if the PhysObj is a generated sphere or box.
	-- @shared
	-- @return number? The volume or nil if the PhysObj is a generated sphere or box.
	function physobj_methods:getVolume()
		return unwrap(self):GetVolume()
	end
	
	--- Returns the stress of the entity.
	-- @server
	-- @return number External stress. Usually about the mass of the object if on the ground, usually 0 if in freefall.
	-- @return number Internal stress. Usually about the mass of every object resting on top of it combined.
	function physobj_methods:getStress()
		return unwrap(self):GetStress()
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
		impulse = vunwrap(impulse)
		position = vunwrap(position)

		checkvector(impulse)
		checkvector(position)

		local linearImpulse, angularImpulse = unwrap(self):CalculateForceOffset(impulse, position)

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
		impulse = vunwrap(impulse)
		position = vunwrap(position)

		checkvector(impulse)
		checkvector(position)

		local linearVelocity, angularVelocity = unwrap(self):CalculateVelocityOffset(impulse, position)

		return vwrap(linearVelocity), vwrap(angularVelocity)
	end
end

end
