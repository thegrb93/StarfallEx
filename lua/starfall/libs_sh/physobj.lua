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

local vwrap = SF.WrapObject

SF.PhysObjs.Methods = physobj_methods
SF.PhysObjs.Metatable = physobj_metamethods
SF.PhysObjs.Wrap = wrap
SF.PhysObjs.Unwrap = unwrap

local ewrap, eunwrap
local owrap, ounwrap = SF.WrapObject, SF.UnwrapObject
local ang_meta, vec_meta
local vwrap, vunwrap, awrap, aunwrap
local isValid = IsValid

SF.AddHook("postload", function()
	ang_meta = SF.Angles.Metatable
	vec_meta = SF.Vectors.Metatable

	vwrap = SF.Vectors.Wrap
	vunwrap = SF.Vectors.Unwrap
	awrap = SF.Angles.Wrap
	aunwrap = SF.Angles.Unwrap
end)

local function check (v)
	return 	-math.huge < v[1] and v[1] < math.huge and
			-math.huge < v[2] and v[2] < math.huge and
			-math.huge < v[3] and v[3] < math.huge
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
	return SF.WrapObject(unwrap(self):GetEntity())
end

--- Gets the position of the physics object
-- @shared
-- @return Vector position of the physics object
function physobj_methods:getPos()
	return vwrap(unwrap(self):GetPos())
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

if SERVER then
	--- Sets the position of the physics object
	-- @server
	-- @param pos The position vector to set it to
	function physobj_methods:setPos(pos)
		checktype(pos, vec_meta)

		local vec = vunwrap(pos)
		if not check(vec) then SF.Throw("infinite vector", 2) end

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
		if not check(vec) then SF.Throw("infinite vector", 2) end

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
		if not check(force) then SF.Throw("infinite vector", 2) end

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
		if not check(force) then SF.Throw("infinite force vector", 2) end
		position = vunwrap(position)
		if not check(position) then SF.Throw("infinite position vector", 2) end

		local phys = unwrap(self)
		checkpermission(SF.instance, phys:GetEntity(), "entities.applyForce")
		phys:ApplyForceOffset(force, position)
	end

	--- Applys a torque to a physics object
	-- @server
	-- @param torque The local torque vector to apply
	function physobj_methods:applyTorque(torque)
		checktype(torque, vec_meta)
		torque = vunwrap(torque)
		if not check(torque) then SF.Throw("infinite torque vector", 2) end

		local phys = unwrap(self)
		checkpermission(SF.instance, phys:GetEntity(), "entities.applyForce")

		phys:ApplyTorqueCenter(torque)
	end

	--- Sets the mass of a physics object
	-- @server
	-- @param mass The mass to set it to
	function physobj_methods:setMass(mass)
		local phys = unwrap(self)
		checkpermission(SF.instance, phys:GetEntity(), "entities.setMass")
		phys:SetMass(math.Clamp(mass, 1, 50000))
	end

	--- Sets the inertia of a physics object
	-- @server
	-- @param inertia The inertia vector to set it to
	function physobj_methods:setInertia(inertia)
		local phys = unwrap(self)
		checkpermission(SF.instance, phys:GetEntity(), "entities.setInertia")

		local vec = vunwrap(inertia)
		if not check(vec) then SF.Throw("infinite vector", 2) end
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

	--- Sets the physical material of a physics object
	-- @server
	-- @param material The physical material to set it to
	function physobj_methods:setMaterial(material)
		checkluatype (material, TYPE_STRING)
		local phys = unwrap(self)
		checkpermission(SF.instance, phys:GetEntity(), "entities.setMass")
		phys:SetMaterial(material)
		if not phys:IsMoveable() then
			phys:EnableMotion(true)
			phys:EnableMotion(false)
		end
	end

	--- Makes a sleeping physobj wakeup
	-- @server
	function physobj_methods:wake()
		local phys = unwrap(self)
		checkpermission(SF.instance, phys:GetEntity(), "entities.applyForce")
		phys:Wake()
	end
end
