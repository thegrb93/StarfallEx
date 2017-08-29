-------------------------------------------------------------------------------
-- PhysObj functions.
-------------------------------------------------------------------------------

SF.PhysObjs = {}

--- PhysObj Type
-- @shared
local physobj_methods, physobj_metatable = SF.Typedef("PhysObj")
local wrap, unwrap = SF.CreateWrapper(physobj_metatable, true, false)

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

SF.Libraries.AddHook("postload", function()
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
	SF.CheckType(vec, vec_meta)
	return vwrap(unwrap(self):WorldToLocal(vunwrap(vec)))
end

--- Returns a vector in the reference frame of the world from the local frame of the physicsobject
-- @param vec The vector to transform
-- @return The transformed vector
function physobj_methods:localToWorld(vec)
	SF.CheckType(vec, vec_meta)
	return vwrap(unwrap(self):LocalToWorld(vunwrap(vec)))
end

--- Returns a normal vector in the local reference frame of the physicsobject from the world frame
-- @param vec The normal vector to transform
-- @return The transformed vector
function physobj_methods:worldToLocalVector(vec)
	SF.CheckType(vec, vec_meta)
	return vwrap(unwrap(self):WorldToLocalVector(vunwrap(vec)))
end

--- Returns a normal vector in the reference frame of the world from the local frame of the physicsobject
-- @param vec The normal vector to transform
-- @return The transformed vector
function physobj_methods:localToWorldVector(vec)
	SF.CheckType(vec, vec_meta)
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
		SF.CheckType(pos, vec_meta)
		
		local vec = vunwrap(pos)
		if not check(vec) then SF.Throw("infinite vector", 2) end
		
		local phys = unwrap(self)
		SF.Permissions.check(SF.instance.player, phys:GetEntity(), "entities.setPos")
		phys:SetPos(vec)
	end
	
	--- Sets the velocity of the physics object
	-- @server
	-- @param vel The velocity vector to set it to
	function physobj_methods:setVelocity(vel)
		SF.CheckType(vel, vec_meta)
		
		local vec = vunwrap(vel)
		if not check(vec) then SF.Throw("infinite vector", 2) end
		
		local phys = unwrap(self)
		SF.Permissions.check(SF.instance.player, phys:GetEntity(), "entities.setVelocity")
		phys:SetVelocity(vec)
	end
	
	--- Applys a force to the center of the physics object
	-- @server
	-- @param force The force vector to apply
	function physobj_methods:applyForceCenter(force)
		SF.CheckType(force, vec_meta)
		
		force = vunwrap(force)
		if not check(force) then SF.Throw("infinite vector", 2) end
		
		local phys = unwrap(self)
		SF.Permissions.check(SF.instance.player, phys:GetEntity(), "entities.applyForce")
		phys:ApplyForceCenter(force)
	end
	
	--- Applys an offset force to a physics object
	-- @server
	-- @param force The force vector to apply
	-- @param position The position in world coordinates
	function physobj_methods:applyForceOffset(force, position)
		SF.CheckType(force, vec_meta)
		SF.CheckType(position, vec_meta)
		
		force = vunwrap(force)
		if not check(force) then SF.Throw("infinite force vector", 2) end
		position = vunwrap(position)
		if not check(position) then SF.Throw("infinite position vector", 2) end
		
		local phys = unwrap(self)
		SF.Permissions.check(SF.instance.player, phys:GetEntity(), "entities.applyForce")
		phys:ApplyForceOffset(force, position)
	end
	
	--- Applys a torque to a physics object
	-- @server
	-- @param torque The local torque vector to apply
	function physobj_methods:applyTorque(torque)
		SF.CheckType(torque, vec_meta)
		torque = vunwrap(torque)
		if not check(torque) then SF.Throw("infinite torque vector", 2) end
		
		local phys = unwrap(self)
		SF.Permissions.check(SF.instance.player, phys:GetEntity(), "entities.applyForce")
		
		local torqueamount = torque:Length()
		if torqueamount < 1.192093e-07 then return end
		-- Convert torque from local to world axis
		torque = phys:LocalToWorldVector(torque / torqueamount)

		-- Find two vectors perpendicular to the torque axis
		local off
		if math.abs(torque.x) > 0.1 or math.abs(torque.z) > 0.1 then
			off = Vector(-torque.z, 0, torque.x):GetNormalized()
		else
			off = Vector(-torque.y, torque.x, 0):GetNormalized()
		end
		local dir = torque:Cross(off)
		off = off * torqueamount * 0.5

		phys:ApplyForceOffset(dir, off)
		phys:ApplyForceOffset(dir * -1, off * -1)
	end
	
	--- Sets the mass of a physics object
	-- @server
	-- @param mass The mass to set it to
	function physobj_methods:setMass(mass)
		local phys = unwrap(self)
		SF.Permissions.check(SF.instance.player, phys:GetEntity(), "entities.setMass")
		phys:SetMass(math.Clamp(mass, 1, 50000))
	end
	
	--- Sets the inertia of a physics object
	-- @server
	-- @param inertia The inertia vector to set it to
	function physobj_methods:setInertia(inertia)
		local phys = unwrap(self)
		SF.Permissions.check(SF.instance.player, phys:GetEntity(), "entities.setInertia")
	
		local vec = vunwrap(inertia)
		if not check(vec) then SF.Throw("infinite vector", 2) end
		vec[1] = math.Clamp(vec[1], 1, 100000)
		vec[2] = math.Clamp(vec[2], 1, 100000)
		vec[3] = math.Clamp(vec[3], 1, 100000)

		phys:SetInertia(vec)
	end
	
	--- Sets the physical material of a physics object
	-- @server
	-- @param material The physical material to set it to
	function physobj_methods:setMaterial(material)
		SF.CheckLuaType(material, TYPE_STRING)
		local phys = unwrap(self)
		SF.Permissions.check(SF.instance.player, phys:GetEntity(), "entities.setMass")
		phys:SetMaterial(material)
		if not phys:IsMoveable() then
			phys:EnableMotion(true)
			phys:EnableMotion(false)
		end
	end
end
