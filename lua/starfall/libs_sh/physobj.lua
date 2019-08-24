-------------------------------------------------------------------------------
-- PhysObj functions.
-------------------------------------------------------------------------------

SF.PhysObjs = {}

--- PhysObj Type
-- @shared
local physobj_methods, physobj_metatable = SF.RegisterType("PhysObj")
local wrap, unwrap = SF.CreateWrapper(physobj_metatable, true, false)
local checktype = SF.CheckType
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check

SF.PhysObjs.Methods = physobj_methods
SF.PhysObjs.Metatable = physobj_metamethods
SF.PhysObjs.Wrap = wrap
SF.PhysObjs.Unwrap = unwrap

local ewrap, eunwrap
local owrap, ounwrap = SF.WrapObject, SF.UnwrapObject
local ang_meta, vec_meta
local vwrap, vunwrap, awrap, aunwrap, mwrap

SF.AddHook("postload", function()
	ang_meta = SF.Angles.Metatable
	vec_meta = SF.Vectors.Metatable

	ewrap = SF.Entities.Wrap
	eunwrap = SF.Entities.Unwrap
	vwrap = SF.Vectors.Wrap
	vunwrap = SF.Vectors.Unwrap
	awrap = SF.Angles.Wrap
	aunwrap = SF.Angles.Unwrap
	mwrap = SF.VMatrix.Wrap
end)

local function checkvector(v)
	if v[1]<-1e12 or v[1]>1e12 or v[1]~=v[1] or
	   v[2]<-1e12 or v[2]>1e12 or v[2]~=v[2] or
	   v[3]<-1e12 or v[3]>1e12 or v[3]~=v[3] then

		SF.Throw("Input vector too large or NAN", 3)

	end
end

--- Checks if the physics object is valid
-- @shared
-- @return boolean if the physics object is valid
function physobj_methods:isValid()
	return unwrap(self):IsValid()
end

--- Gets the entity attached to the physics object
-- @shared
-- @return The entity attached to the physics object
function physobj_methods:getEntity()
	return ewrap(unwrap(self):GetEntity())
end

--- Gets the position of the physics object
-- @shared
-- @return Vector position of the physics object
function physobj_methods:getPos()
	return vwrap(unwrap(self):GetPos())
end

--- Returns the world transform matrix of the physobj
-- @shared
-- @return The matrix
function physobj_methods:getMatrix()
	return mwrap(unwrap(self):GetPositionMatrix())
end

--- Gets the angles of the physics object
-- @shared
-- @return Angle angles of the physics object
function physobj_methods:getAngles()
	return awrap(unwrap(self):GetAngles())
end

--- Gets the velocity of the physics object
-- @shared
-- @return Vector velocity of the physics object
function physobj_methods:getVelocity()
	return vwrap(unwrap(self):GetVelocity())
end

--- Gets the velocity of the physics object at an arbitrary point in its local reference frame
--- This includes velocity at the point induced by rotational velocity
-- @shared
-- @param vec The point to get velocity of in local reference frame
-- @return Vector Local velocity of the physics object at the point
function physobj_methods:getVelocityAtPoint(vec)
	checktype(vec, vec_meta)
	return vwrap(unwrap(self):GetVelocityAtPoint(vunwrap(vec)))
end

--- Gets the angular velocity of the physics object
-- @shared
-- @return Vector angular velocity of the physics object
function physobj_methods:getAngleVelocity()
	return vwrap(unwrap(self):GetAngleVelocity())
end

--- Gets the mass of the physics object
-- @shared
-- @return mass of the physics object
function physobj_methods:getMass()
	return unwrap(self):GetMass()
end

--- Gets the center of mass of the physics object in the local reference frame.
-- @shared
-- @return Center of mass vector in the physobject's local reference frame.
function physobj_methods:getMassCenter()
	return vwrap(unwrap(self):GetMassCenter())
end

--- Gets the inertia of the physics object
-- @shared
-- @return Vector Inertia of the physics object
function physobj_methods:getInertia()
	return vwrap(unwrap(self):GetInertia())
end

--- Gets the material of the physics object
-- @shared
-- @return The physics material of the physics object
function physobj_methods:getMaterial()
	return unwrap(self):GetMaterial()
end

--- Returns a vector in the local reference frame of the physicsobject from the world frame
-- @param vec The vector to transform
-- @return The transformed vector
function physobj_methods:worldToLocal(vec)
	checktype(vec, vec_meta)
	return vwrap(unwrap(self):WorldToLocal(vunwrap(vec)))
end

--- Returns a vector in the reference frame of the world from the local frame of the physicsobject
-- @param vec The vector to transform
-- @return The transformed vector
function physobj_methods:localToWorld(vec)
	checktype(vec, vec_meta)
	return vwrap(unwrap(self):LocalToWorld(vunwrap(vec)))
end

--- Returns a normal vector in the local reference frame of the physicsobject from the world frame
-- @param vec The normal vector to transform
-- @return The transformed vector
function physobj_methods:worldToLocalVector(vec)
	checktype(vec, vec_meta)
	return vwrap(unwrap(self):WorldToLocalVector(vunwrap(vec)))
end

--- Returns a normal vector in the reference frame of the world from the local frame of the physicsobject
-- @param vec The normal vector to transform
-- @return The transformed vector
function physobj_methods:localToWorldVector(vec)
	checktype(vec, vec_meta)
	return vwrap(unwrap(self):LocalToWorldVector(vunwrap(vec)))
end

--- Returns a table of MeshVertex structures where each 3 vertices represent a triangle. See: http://wiki.garrysmod.com/page/Structures/MeshVertex
-- @return table of MeshVertex structures
function physobj_methods:getMesh ()
	local mesh = unwrap(self):GetMesh()
	return SF.Sanitize(mesh)
end

--- Returns a structured table, the physics mesh of the physics object. See: http://wiki.garrysmod.com/page/Structures/MeshVertex
-- @return table of MeshVertex structures
function physobj_methods:getMeshConvexes ()
	local mesh = unwrap(self):GetMeshConvexes()
	return SF.Sanitize(mesh)
end

--- Sets the physical material of a physics object
-- @param material The physical material to set it to
function physobj_methods:setMaterial(material)
	checkluatype (material, TYPE_STRING)
	local phys = unwrap(self)
	checkpermission(SF.instance, phys:GetEntity(), "entities.setRenderProperty")
	phys:SetMaterial(material)
	if not phys:IsMoveable() then
		phys:EnableMotion(true)
		phys:EnableMotion(false)
	end
end

if SERVER then
	--- Sets the position of the physics object. Will cause interpolation of the entity in clientside, use entity.setPos to avoid this.
	-- @server
	-- @param pos The position vector to set it to
	function physobj_methods:setPos(pos)
		checktype(pos, vec_meta)

		local vec = vunwrap(pos)
		checkvector(vec)

		local phys = unwrap(self)
		checkpermission(SF.instance, phys:GetEntity(), "entities.setPos")
		phys:SetPos(vec)
	end

	--- Sets the velocity of the physics object
	-- @server
	-- @param vel The velocity vector to set it to
	function physobj_methods:setVelocity(vel)
		checktype(vel, vec_meta)

		local vec = vunwrap(vel)
		checkvector(vec)

		local phys = unwrap(self)
		checkpermission(SF.instance, phys:GetEntity(), "entities.setVelocity")
		phys:SetVelocity(vec)
	end

	--- Applys a force to the center of the physics object
	-- @server
	-- @param force The force vector to apply
	function physobj_methods:applyForceCenter(force)
		checktype(force, vec_meta)

		force = vunwrap(force)
		checkvector(force)

		local phys = unwrap(self)
		checkpermission(SF.instance, phys:GetEntity(), "entities.applyForce")
		phys:ApplyForceCenter(force)
	end

	--- Applys an offset force to a physics object
	-- @server
	-- @param force The force vector to apply
	-- @param position The position in world coordinates
	function physobj_methods:applyForceOffset(force, position)
		checktype(force, vec_meta)
		checktype(position, vec_meta)

		force = vunwrap(force)
		checkvector(force)
		position = vunwrap(position)
		checkvector(position)

		local phys = unwrap(self)
		checkpermission(SF.instance, phys:GetEntity(), "entities.applyForce")
		phys:ApplyForceOffset(force, position)
	end

	--- Sets the angular velocity of an object
	-- @server
	-- @param angvel The local angvel vector to set
	function physobj_methods:setAngleVelocity(angvel)
		checktype(angvel, vec_meta)
		angvel = vunwrap(angvel)
		checkvector(angvel)

		local phys = unwrap(self)
		checkpermission(SF.instance, phys:GetEntity(), "entities.applyForce")

		phys:AddAngleVelocity(angvel - phys:GetAngleVelocity())
	end

	--- Applys a angular velocity to an object
	-- @server
	-- @param angvel The local angvel vector to apply
	function physobj_methods:addAngleVelocity(angvel)
		checktype(angvel, vec_meta)
		angvel = vunwrap(angvel)
		checkvector(angvel)

		local phys = unwrap(self)
		checkpermission(SF.instance, phys:GetEntity(), "entities.applyForce")

		phys:AddAngleVelocity(angvel)
	end

	--- Applys a torque to a physics object
	-- @server
	-- @param torque The world torque vector to apply
	function physobj_methods:applyTorque(torque)
		checktype(torque, vec_meta)
		torque = vunwrap(torque)
		checkvector(torque)

		local phys = unwrap(self)
		checkpermission(SF.instance, phys:GetEntity(), "entities.applyForce")

		phys:ApplyTorqueCenter(torque)
	end

	--- Sets the mass of a physics object
	-- @server
	-- @param mass The mass to set it to
	function physobj_methods:setMass(mass)
		checkluatype(mass, TYPE_NUMBER)
		local phys = unwrap(self)
		local ent = phys:GetEntity()
		checkpermission(SF.instance, ent, "entities.setMass")
		local m = math.Clamp(mass, 1, 50000)
		phys:SetMass(m)
		duplicator.StoreEntityModifier(ent, "mass", { Mass = m })
	end

	--- Sets the inertia of a physics object
	-- @server
	-- @param inertia The inertia vector to set it to
	function physobj_methods:setInertia(inertia)
		local phys = unwrap(self)
		checkpermission(SF.instance, phys:GetEntity(), "entities.setInertia")

		local vec = vunwrap(inertia)
		checkvector(vec)
		vec[1] = math.Clamp(vec[1], 1, 100000)
		vec[2] = math.Clamp(vec[2], 1, 100000)
		vec[3] = math.Clamp(vec[3], 1, 100000)

		phys:SetInertia(vec)
	end
	
	--- Sets bone gravity
	-- @param grav Bool should the bone respect gravity?
	function physobj_methods:enableGravity (grav)
		local phys = unwrap(self)
		checkpermission(SF.instance, phys:GetEntity(), "entities.enableGravity")
		phys:EnableGravity(grav and true or false)
		phys:Wake()
	end

	--- Sets the bone drag state
	-- @param drag Bool should the bone have air resistence?
	function physobj_methods:enableDrag (drag)
		local phys = unwrap(self)
		checkpermission(SF.instance, phys:GetEntity(), "entities.enableDrag")
		phys:EnableDrag(drag and true or false)
	end

	--- Sets the bone movement state
	-- @param move Bool should the bone move?
	function physobj_methods:enableMotion (move)
		local phys = unwrap(self)
		checkpermission(SF.instance, phys:GetEntity(), "entities.enableMotion")
		phys:EnableMotion(move and true or false)
		phys:Wake()
	end

	--- Makes a sleeping physobj wakeup
	-- @server
	function physobj_methods:wake()
		local phys = unwrap(self)
		checkpermission(SF.instance, phys:GetEntity(), "entities.applyForce")
		phys:Wake()
	end
end
