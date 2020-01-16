-------------------------------------------------------------------------------
-- Serverside Entity functions
-------------------------------------------------------------------------------

assert(SF.Entities)


local huge = math.huge
local abs = math.abs

local ents_lib = SF.Entities.Library
local ents_metatable = SF.Entities.Metatable
local getent = SF.Entities.GetEntity

--- Entity type
--@class class
--@name Entity
local ents_methods = SF.Entities.Methods
local ewrap, eunwrap = SF.Entities.Wrap, SF.Entities.Unwrap
local owrap = SF.WrapObject
local ounwrap = SF.UnwrapObject
local checktype = SF.CheckType
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check
-- Register privileges
do
	local P = SF.Permissions
	P.registerPrivilege("entities.parent", "Parent", "Allows the user to parent an entity to another entity", { entities = {} })
	P.registerPrivilege("entities.unparent", "Unparent", "Allows the user to remove the parent of an entity", { entities = {} })
	P.registerPrivilege("entities.applyDamage", "Apply damage", "Allows the user to apply damage to an entity", { entities = {} })
	P.registerPrivilege("entities.applyForce", "Apply force", "Allows the user to apply force to an entity", { entities = {} })
	P.registerPrivilege("entities.setPos", "Set Position", "Allows the user to teleport an entity to another location", { entities = {} })
	P.registerPrivilege("entities.setAngles", "Set Angles", "Allows the user to teleport an entity to another orientation", { entities = {} })
	P.registerPrivilege("entities.setVelocity", "Set Velocity", "Allows the user to change the velocity of an entity", { entities = {} })
	P.registerPrivilege("entities.setFrozen", "Set Frozen", "Allows the user to freeze and unfreeze an entity", { entities = {} })
	P.registerPrivilege("entities.setSolid", "Set Solid", "Allows the user to change the solidity of an entity", { entities = {} })
	P.registerPrivilege("entities.setMass", "Set Mass", "Allows the user to change the mass of an entity", { entities = {} })
	P.registerPrivilege("entities.setInertia", "Set Inertia", "Allows the user to change the inertia of an entity", { entities = {} })
	P.registerPrivilege("entities.enableGravity", "Enable gravity", "Allows the user to change whether an entity is affected by gravity", { entities = {} })
	P.registerPrivilege("entities.enableMotion", "Set Motion", "Allows the user to disable an entity's motion", { entities = {} })
	P.registerPrivilege("entities.enableDrag", "Set Drag", "Allows the user to disable an entity's air resistance and change it's coefficient", { entities = {} })
	P.registerPrivilege("entities.setDamping", "Set Damping", "Allows the user to change entity's air friction damping", { entities = {} })
	P.registerPrivilege("entities.remove", "Remove", "Allows the user to remove entities", { entities = {} })
	P.registerPrivilege("entities.ignite", "Ignite", "Allows the user to ignite entities", { entities = {} })
	P.registerPrivilege("entities.canTool", "CanTool", "Whether or not the user can use the toolgun on the entity", { entities = {} })
end

local vec_meta, ang_meta
local vwrap, vunwrap, awrap, aunwrap

SF.AddHook("postload", function()
	vec_meta = SF.Vectors.Metatable
	ang_meta = SF.Angles.Metatable

	vwrap = SF.Vectors.Wrap
	vunwrap = SF.Vectors.Unwrap
	awrap = SF.Angles.Wrap
	aunwrap = SF.Angles.Unwrap
end)

-- ------------------------- Internal functions ------------------------- --

local function checkvector(v)
	if v[1]<-1e12 or v[1]>1e12 or v[1]~=v[1] or
	   v[2]<-1e12 or v[2]>1e12 or v[2]~=v[2] or
	   v[3]<-1e12 or v[3]>1e12 or v[3]~=v[3] then

		SF.Throw("Input vector too large or NAN", 3)

	end
end

-- ------------------------- Methods ------------------------- --

--- Parents the entity to another entity
-- @param parent Entity to parent to. nil to unparent
-- @param attachment Optional string attachment name to parent to
function ents_methods:setParent(parent, attachment)
	local ent = getent(self)
	checkpermission(SF.instance, ent, "entities.parent")

	if parent ~= nil then
		local parentent = getent(parent)
		if parentent:IsPlayer() then
			if ent:GetClass()~="starfall_hologram" then
				SF.Throw("Insufficient permissions", 2)
			end
		else
			checkpermission(SF.instance, parentent, "entities.parent")
		end

		ent:SetParent(parentent)

		if attachment then
			checkluatype(attachment, TYPE_STRING)
			ent:Fire("SetParentAttachmentMaintainOffset", attachment, 0.01)
		end
	else
		ent:SetParent()
	end
end

--- Unparents the entity from another entity
function ents_methods:unparent()
	local ent = getent(self)
	checkpermission(SF.instance, ent, "entities.unparent")
	ent:SetParent(nil)
end

--- Links starfall components to a starfall processor or vehicle. Screen can only connect to processor. HUD can connect to processor and vehicle.
-- @param e Entity to link the component to. nil to clear links.
function ents_methods:linkComponent(e)
	local ent = getent(self)
	checkpermission(SF.instance, ent, "entities.canTool")

	if e then
		local link = getent(e)
		checkpermission(SF.instance, link, "entities.canTool")

		if link:GetClass()=="starfall_processor" and (ent:GetClass()=="starfall_screen" or ent:GetClass()=="starfall_hud") then
			ent:LinkEnt(link)
		elseif link:IsVehicle() and ent:GetClass()=="starfall_hud" then
			ent:LinkVehicle(link)
		else
			SF.Throw("Invalid Link Entity", 2)
		end
	else
		if ent:GetClass()=="starfall_screen" then
			ent:LinkEnt(nil)
		elseif ent:GetClass()=="starfall_hud" then
			ent:LinkEnt(nil)
			ent:LinkVehicle(nil)
		else
			SF.Throw("Invalid Link Entity", 2)
		end
	end
end

--- Sets a component's ability to lock a player's controls
-- @param enable Whether the component will lock the player's controls when used
function ents_methods:setComponentLocksControls(enable)
	local ent = getent(self)
	checkluatype(enable, TYPE_BOOL)
	checkpermission(SF.instance, ent, "entities.canTool")
	if ent:GetClass()=="starfall_screen" or ent:GetClass()=="starfall_hud" then
		ent.locksControls = enable
	else
		SF.Throw("Entity must be a starfall_screen or starfall_hud", 2)
	end
end

--- Returns a list of entities linked to a processor
-- @return A list of components linked to the entity
function ents_methods:getLinkedComponents()
	local ent = getent(self)
	if ent:GetClass() ~= "starfall_processor" then SF.Throw("The target must be a starfall_processor", 2) end
	
	local list = {}
	for k, v in ipairs(ents.FindByClass("starfall_screen")) do
		if v.link == ent then list[#list+1] = ewrap(v) end
	end
	for k, v in ipairs(ents.FindByClass("starfall_hud")) do
		if v.link == ent then list[#list+1] = ewrap(v) end
	end
	
	return list
end

--- Applies damage to an entity
-- @param amt damage amount
-- @param attacker damage attacker
-- @param inflictor damage inflictor
function ents_methods:applyDamage(amt, attacker, inflictor)
	local ent = getent(self)
	checkluatype(amt, TYPE_NUMBER)

	checkpermission(SF.instance, ent, "entities.applyDamage")

	if attacker then
		attacker = getent(attacker)
	end
	if inflictor then
		inflictor = getent(inflictor)
	end

	ent:TakeDamage(amt, attacker, inflictor)
end

--- Sets a custom prop's physics simulation forces. Thrusters and balloons use this.
-- @param ang Angular Force (Torque)
-- @param lin Linear Force
-- @param mode The physics mode to use. 0 = Off, 1 = Local acceleration, 2 = Local force, 3 = Global Acceleration, 4 = Global force
function ents_methods:setCustomPropForces(ang, lin, mode)
	local ent = getent(self)
	if ent:GetClass()~="starfall_prop" then SF.Throw("The entity isn't a custom prop", 2) end

	checkpermission(SF.instance, ent, "entities.applyForce")

	ang = vunwrap(ang)
	checkvector(ang)
	lin = vunwrap(lin)
	checkvector(lin)

	checkluatype(mode, TYPE_NUMBER)
	if mode ~= 0 and mode ~= 1 and mode ~= 2 and mode ~= 3 and mode ~= 4 then SF.Throw("Invalid mode", 2) end

	function ent:PhysicsSimulate()
		return ang, lin, mode
	end
	ent:StartMotionController()
end

--- Set the angular velocity of an object
-- @param angvel The local angvel vector to set
function ents_methods:setAngleVelocity(angvel)
	local ent = getent(self)
	checktype(angvel, vec_meta)
	angvel = vunwrap(angvel)
	checkvector(angvel)

	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end

	checkpermission(SF.instance, ent, "entities.applyForce")

	phys:AddAngleVelocity(angvel - phys:GetAngleVelocity())
end

--- Applys a angular velocity to an object
-- @param angvel The local angvel vector to apply
function ents_methods:addAngleVelocity(angvel)
	local ent = getent(self)
	checktype(angvel, vec_meta)
	angvel = vunwrap(angvel)
	checkvector(angvel)

	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end

	checkpermission(SF.instance, ent, "entities.applyForce")

	phys:AddAngleVelocity(angvel)
end
	
--- Applies linear force to the entity
-- @param vec The force vector
function ents_methods:applyForceCenter(vec)
	local ent = getent(self)
	checktype(vec, vec_meta)
	local vec = vunwrap(vec)
	checkvector(vec)

	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end

	checkpermission(SF.instance, ent, "entities.applyForce")

	phys:ApplyForceCenter(vec)
end

--- Applies linear force to the entity with an offset
-- @param vec The force vector
-- @param offset An optional offset position
function ents_methods:applyForceOffset(vec, offset)
	local ent = getent(self)
	checktype(vec, vec_meta)
	checktype(offset, vec_meta)

	local vec = vunwrap(vec)
	local offset = vunwrap(offset)

	checkvector(vec)
	checkvector(offset)

	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end

	checkpermission(SF.instance, ent, "entities.applyForce")

	phys:ApplyForceOffset(vec, offset)
end

--- Applies angular force to the entity
-- @param ang The force angle
function ents_methods:applyAngForce(ang)
	local ent = getent(self)
	checktype(ang, ang_meta)

	local ang = aunwrap(ang)
	checkvector(ang)

	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end

	checkpermission(SF.instance, ent, "entities.applyForce")

	-- assign vectors
	local up = ent:GetUp()
	local left = ent:GetRight() * -1
	local forward = ent:GetForward()

	-- apply pitch force
	if ang.p ~= 0 then
		local pitch = up * (ang.p * 0.5)
		phys:ApplyForceOffset(forward, pitch)
		phys:ApplyForceOffset(forward * -1, pitch * -1)
	end

	-- apply yaw force
	if ang.y ~= 0 then
		local yaw = forward * (ang.y * 0.5)
		phys:ApplyForceOffset(left, yaw)
		phys:ApplyForceOffset(left * -1, yaw * -1)
	end

	-- apply roll force
	if ang.r ~= 0 then
		local roll = left * (ang.r * 0.5)
		phys:ApplyForceOffset(up, roll)
		phys:ApplyForceOffset(up * -1, roll * -1)
	end
end

--- Applies torque
-- @param torque The torque vector
function ents_methods:applyTorque(torque)
	local ent = getent(self)
	checktype(torque, vec_meta)

	local torque = vunwrap(torque)
	checkvector(torque)

	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end

	checkpermission(SF.instance, ent, "entities.applyForce")

	phys:ApplyTorqueCenter(torque)
end

--- Allows detecting collisions on an entity. You can only do this once for the entity's entire lifespan so use it wisely.
-- @param func The callback function with argument, table collsiondata, http://wiki.garrysmod.com/page/Structures/CollisionData
function ents_methods:addCollisionListener(func)
	local ent = getent(self)
	checkluatype(func, TYPE_FUNCTION)
	checkpermission(SF.instance, ent, "entities.canTool")
	if ent.SF_CollisionCallback then SF.Throw("The entity is already listening to collisions!", 2) end

	local instance = SF.instance
	if ent:GetClass() ~= "starfall_prop" then
		ent.SF_CollisionCallback = ent:AddCallback("PhysicsCollide", function(ent, data)
			instance:runFunction(func, SF.StructWrapper(data))
		end)
	else
		function ent:PhysicsCollide( data, phys )
			instance:runFunction(func, SF.StructWrapper(data))
		end
	end
end

--- Removes a collision listening hook from the entity so that a new one can be added
function ents_methods:removeCollisionListener()
	local ent = getent(self)
	checkpermission(SF.instance, ent, "entities.canTool")
	if ent:GetClass() ~= "starfall_prop" then
		if not ent.SF_CollisionCallback then SF.Throw("The entity isn't listening to collisions!", 2) end
		ent:RemoveCallback("PhysicsCollide", ent.SF_CollisionCallback)
		ent.SF_CollisionCallback = nil
	else
		if not ent.PhysicsCollide then SF.Throw("The entity isn't listening to collisions!", 2) end
		ent.PhysicsCollide = nil
	end
end

--- Set's the entity to collide with nothing but the world
-- @param nocollide Whether to collide with nothing except world or not.
function ents_methods:setNocollideAll(nocollide)
	local ent = getent(self)
	checkpermission(SF.instance, ent, "entities.setSolid")

	ent:SetCollisionGroup (nocollide and COLLISION_GROUP_WORLD or COLLISION_GROUP_NONE)
end

--- Sets whether an entity's shadow should be drawn
-- @param ply Optional player argument to set only for that player. Can also be table of players.
function ents_methods:setDrawShadow(draw, ply)
	local ent = getent(self)
	checkpermission(SF.instance, ent, "entities.setRenderProperty")

	if ply then
		sendRenderPropertyToClient(ply, ent, 9, draw and true or false)
	else
		ent:DrawShadow(draw and true or false)
	end
end

--- Sets the entitiy's position. No interpolation will occur clientside, use physobj.setPos to have interpolation.
-- @param vec New position
function ents_methods:setPos(vec)
	local ent = getent(self)
	checktype(vec, vec_meta)

	local vec = vunwrap(vec)
	checkpermission(SF.instance, ent, "entities.setPos")

	ent:SetPos(SF.clampPos(vec))
end

--- Sets the entity's angles
-- @param ang New angles
function ents_methods:setAngles(ang)
	local ent = getent(self)
	checktype(ang, ang_meta)

	local ang = aunwrap(ang)
	checkpermission(SF.instance, ent, "entities.setAngles")

	ent:SetAngles(ang)
end

--- Sets the entity's linear velocity
-- @param vel New velocity
function ents_methods:setVelocity(vel)
	local ent = getent(self)
	checktype(vel, vec_meta)

	local vel = vunwrap(vel)
	checkvector(vel)

	checkpermission(SF.instance, ent, "entities.setVelocity")

	ent:SetVelocity(vel)
end

--- Removes an entity
function ents_methods:remove()
	local ent = getent(self)
	if ent:IsWorld() or ent:IsPlayer() then SF.Throw("Cannot remove world or player", 2) end
	checkpermission(SF.instance, ent, "entities.remove")

	ent:Remove()
end

--- Invokes the entity's breaking animation and removes it.
function ents_methods:breakEnt()
	local ent = getent(self)
	if ent:IsPlayer() or ent.WasBroken then SF.Throw("Entity is not valid", 2) end
	checkpermission(SF.instance, ent, "entities.remove")

	ent.WasBroken = true
	ent:Fire("break", 1, 0)
end

--- Ignites an entity
-- @param length How long the fire lasts
-- @param radius (optional) How large the fire hitbox is (entity obb is the max)
function ents_methods:ignite(length, radius)
	local ent = getent(self)
	checkluatype(length, TYPE_NUMBER)

	checkpermission(SF.instance, ent, "entities.ignite")

	if radius then
		checkluatype(radius, TYPE_NUMBER)
		local obbmins, obbmaxs = ent:OBBMins(), ent:OBBMaxs()
		radius = math.Clamp(radius, 0, (obbmaxs.x - obbmins.x + obbmaxs.y - obbmins.y) / 2)
	end

	ent:Ignite(length, radius)
end

--- Extinguishes an entity
function ents_methods:extinguish()
	local ent = getent(self)
	checkpermission(SF.instance, ent, "entities.ignite")

	ent:Extinguish()
end

--- Sets the entity frozen state
-- @param freeze Should the entity be frozen?
function ents_methods:setFrozen(freeze)
	local ent = getent(self)
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end

	checkpermission(SF.instance, ent, "entities.setFrozen")

	phys:EnableMotion(not (freeze and true or false))
	phys:Wake()
end

--- Checks the entities frozen state
-- @return True if entity is frozen
function ents_methods:isFrozen()
	local ent = getent(self)
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end
	if phys:IsMoveable() then return false else return true end
end

--- Sets the entity to be Solid or not.
-- For more information please refer to GLua function http://wiki.garrysmod.com/page/Entity/SetNotSolid
-- @param solid Boolean, Should the entity be solid?
function ents_methods:setSolid(solid)
	local ent = getent(self)
	checkpermission(SF.instance, ent, "entities.setSolid")

	ent:SetNotSolid(not solid)
end

--- Sets the entity's mass
-- @param mass number mass
function ents_methods:setMass(mass)
	local ent = getent(self)
	checkluatype(mass, TYPE_NUMBER)
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end

	checkpermission(SF.instance, ent, "entities.setMass")

	local m = math.Clamp(mass, 1, 50000)
	phys:SetMass(m)
	duplicator.StoreEntityModifier(ent, "mass", { Mass = m })
end

--- Sets the entity's inertia
-- @param vec Inertia tensor
function ents_methods:setInertia(vec)
	local ent = getent(self)
	checktype(vec, vec_meta)
	checkpermission(SF.instance, ent, "entities.setInertia")
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end

	local vec = vunwrap(vec)
	checkvector(vec)
	vec[1] = math.Clamp(vec[1], 1, 100000)
	vec[2] = math.Clamp(vec[2], 1, 100000)
	vec[3] = math.Clamp(vec[3], 1, 100000)

	phys:SetInertia(vec)
end

--- Sets the physical material of the entity
-- @param mat Material to use
function ents_methods:setPhysMaterial(mat)
	local ent = getent(self)
	checkluatype(mat, TYPE_STRING)
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end

	checkpermission(SF.instance, ent, "entities.setMass")

	construct.SetPhysProp(nil, ent, 0, phys, { Material = mat })
end

--- Get the physical material of the entity
-- @return the physical material
function ents_methods:getPhysMaterial()
	local ent = getent(self)
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end

	return phys:GetMaterial()
end

--- Checks whether entity has physics
-- @return True if entity has physics
function ents_methods:isValidPhys()
	local ent = getent(self)
	local phys = ent:GetPhysicsObject()
	return phys ~= nil
end

--- Returns true if the entity is being held by a player. Either by Physics gun, Gravity gun or Use-key.
-- @server
-- @return Boolean if the entity is being held or not
function ents_methods:isPlayerHolding()
	local ent = getent(self)
	return ent:IsPlayerHolding()
end

--- Sets entity gravity
-- @param grav Bool should the entity respect gravity?
function ents_methods:enableGravity(grav)
	local ent = getent(self)
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end

	checkpermission(SF.instance, ent, "entities.enableGravity")

	phys:EnableGravity(grav and true or false)
	phys:Wake()
end

--- Sets the entity drag state
-- @param drag Bool should the entity have air resistence?
function ents_methods:enableDrag(drag)
	local ent = getent(self)
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end

	checkpermission(SF.instance, ent, "entities.enableDrag")

	phys:EnableDrag(drag and true or false)
end

--- Sets the entity movement state
-- @param move Bool should the entity move?
function ents_methods:enableMotion(move)
	local ent = getent(self)
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end

	checkpermission(SF.instance, ent, "entities.enableMotion")

	phys:EnableMotion(move and true or false)
	phys:Wake()
end


--- Sets the physics of an entity to be a sphere
-- @param enabled Bool should the entity be spherical?
function ents_methods:enableSphere(enabled)
	local ent = getent(self)
	if ent:GetClass() ~= "prop_physics" then SF.Throw("This function only works for prop_physics", 2) end
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end
	checkpermission(SF.instance, ent, "entities.enableMotion")

	local ismove = phys:IsMoveable()
	local mass = phys:GetMass()

	if enabled then
		if ent:GetMoveType() == MOVETYPE_VPHYSICS then
			local OBB = ent:OBBMaxs() - ent:OBBMins()
			local radius = math.max(OBB.x, OBB.y, OBB.z) / 2
			ent:PhysicsInitSphere(radius, phys:GetMaterial())
			ent:SetCollisionBounds(Vector(-radius, -radius, -radius) , Vector(radius, radius, radius))
		end
	else
		if ent:GetMoveType() ~= MOVETYPE_VPHYSICS then
			ent:PhysicsInit(SOLID_VPHYSICS)
			ent:SetMoveType(MOVETYPE_VPHYSICS)
			ent:SetSolid(SOLID_VPHYSICS)
		end
	end

	-- New physobject after applying spherical collisions
	local phys = ent:GetPhysicsObject()
	phys:SetMass(mass)
	phys:EnableMotion(ismove)
	phys:Wake()
end

--- Gets what the entity is welded to. If the entity is parented, returns the parent.
--@return The first welded/parent entity
function ents_methods:isWeldedTo()
	local ent = getent(self)
	local constr = constraint.FindConstraint(ent, "Weld")
	if constr then
		return owrap(constr.Ent1 == ent and constr.Ent2 or constr.Ent1)
	else
		local parent = ent:GetParent()
		if parent:IsValid() then
			return owrap(parent)
		end
	end
	return nil
end

--- Gets a table of all constrained entities to each other
--@param filter Optional constraint type filter table where keys are the type name and values are 'true'. "Wire" and "Parent" are used for wires and parents.
function ents_methods:getAllConstrained(filter)
	local ent = getent(self)
	if filter ~= nil then checkluatype(filter, TYPE_TABLE) end

	local entity_lookup = {}
	local entity_table = {}
	local function recursive_find(ent)
		if entity_lookup[ent] then return end
		entity_lookup[ent] = true
		if ent:IsValid() then
			entity_table[#entity_table + 1] = owrap(ent)
			local constraints = constraint.GetTable(ent)
			for k, v in pairs(constraints) do
				if not filter or filter[v.Type] then
					if v.Ent1 then recursive_find(v.Ent1) end
					if v.Ent2 then recursive_find(v.Ent2) end
				end
			end
			if not filter or filter.Parent then
				local parent = ent:GetParent()
				if parent then recursive_find(parent) end
				for k, child in pairs(ent:GetChildren()) do
					recursive_find(child)
				end
			end
			if not filter or filter.Wire then
				if istable(ent.Inputs) then
					for k, v in pairs(ent.Inputs) do
						if isentity(v.Src) and v.Src:IsValid() then
							recursive_find(v.Src)
						end
					end
				end
				if istable(ent.Outputs) then
					for k, v in pairs(ent.Outputs) do
						if istable(v.Connected) then
							for k, v in pairs(v.Connected) do
								if isentity(v.Entity) and v.Entity:IsValid() then
									recursive_find(v.Entity)
								end
							end
						end
					end
				end
			end
		end
	end
	recursive_find(eunwrap(self))

	return entity_table
end

--- Adds a trail to the entity with the specified attributes.
-- @param startSize The start size of the trail
-- @param endSize The end size of the trail
-- @param length The length size of the trail
-- @param material The material of the trail
-- @param color The color of the trail
-- @param attachmentID Optional attachmentid the trail should attach to
-- @param additive If the trail's rendering is additive
function ents_methods:setTrails(startSize, endSize, length, material, color, attachmentID, additive)
	local ent = getent(self)
	checkluatype(material, TYPE_STRING)
	local time = CurTime()
	if ent._lastTrailSet == time then SF.Throw("Can't modify trail more than once per frame", 2) end
	ent._lastTrailSet = time

	if string.find(material, '"', 1, true) then SF.Throw("Invalid Material", 2) end
	checkpermission(SF.instance, ent, "entities.setRenderProperty")

	local Data = {
		Color = SF.Color.Unwrap(color),
		Length = length,
		StartSize = math.Clamp(startSize, 0, 128),
		EndSize = math.Clamp(endSize, 0, 128),
		Material = material,
		AttachmentID = attachmentID,
		Additive = additive,
	}

	duplicator.EntityModifiers.trail(SF.instance.player, ent, Data)
end

--- Removes trails from the entity
function ents_methods:removeTrails()
	local ent = getent(self)
	checkpermission(SF.instance, ent, "entities.setRenderProperty")

	duplicator.EntityModifiers.trail(SF.instance.player, ent, nil)
end

--- Sets a prop_physics to be unbreakable
-- @param on Whether to make the prop unbreakable
function ents_methods:setUnbreakable(on)
	local ent = getent(self)
	checkluatype(on, TYPE_BOOL)
	checkpermission(SF.instance, ent, "entities.canTool")
	if ent:GetClass() ~= "prop_physics" then SF.Throw("setUnbreakable can only be used on prop_physics", 2) end

	if not (SF.UnbreakableFilter and SF.UnbreakableFilter:IsValid()) then
		local FilterDamage = ents.FindByName("FilterDamage")[1]
		if not FilterDamage then
			local FilterDamage = ents.Create( "filter_activator_name" )
			FilterDamage:SetKeyValue( "TargetName", "FilterDamage" )
			FilterDamage:SetKeyValue( "negated", "1" )
			FilterDamage:Spawn()
		end
		SF.UnbreakableFilter = FilterDamage
	end

	ent:Fire( "SetDamageFilter", on and "FilterDamage" or "", 0 )
end

--- Check if the given Entity or Vector is within this entity's PVS (Potentially Visible Set). See: https://developer.valvesoftware.com/wiki/PVS
-- @param other Entity or Vector to test
-- @return bool True/False
function ents_methods:testPVS(other)
	local ent = getent(self)

	local meta = debug.getmetatable(other)
	if meta==vec_meta then
		other = vunwrap(other)
	elseif meta==ents_metatable then
		other = getent(other)
	else
		SF.ThrowTypeError("Entity or Vector", SF.GetType(other), 2)
	end

	return ent:TestPVS(other)
end

--- Returns entity's creation ID (similar to entIndex, but increments monotonically)
-- @return The creation ID
function ents_methods:getCreationID()
	local ent = getent(self)
	return ent:GetCreationID()
end
