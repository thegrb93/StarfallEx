-------------------------------------------------------------------------------
-- Serverside Entity functions
-------------------------------------------------------------------------------

assert(SF.Entities)

local huge = math.huge
local abs = math.abs
local isValid = IsValid

local ents_lib = SF.Entities.Library
local ents_metatable = SF.Entities.Metatable

--- Entity type
--@class class
--@name Entity
local ents_methods = SF.Entities.Methods
local wrap, unwrap = SF.Entities.Wrap, SF.Entities.Unwrap
local vwrap = SF.WrapObject
local vunwrap = SF.UnwrapObject
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
	P.registerPrivilege("entities.enableDrag", "Set Drag", "Allows the user to disable an entity's air resistence", { entities = {} })
	P.registerPrivilege("entities.remove", "Remove", "Allows the user to remove entities", { entities = {} })
	P.registerPrivilege("entities.ignite", "Ignite", "Allows the user to ignite entities", { entities = {} })
	P.registerPrivilege("entities.emitSound", "Emitsound", "Allows the user to play sounds on entities", { entities = {} })
	P.registerPrivilege("entities.canTool", "CanTool", "Whether or not the user can use the toolgun on the entity", { entities = {} })
end

-- ------------------------- Internal functions ------------------------- --

local function check (v)
	return 	-math.huge < v[1] and v[1] < math.huge and
			-math.huge < v[2] and v[2] < math.huge and
			-math.huge < v[3] and v[3] < math.huge
end

-- ------------------------- Methods ------------------------- --

--- Parents the entity to another entity
-- @param ent Entity to parent to. nil to unparent
-- @param attachment Optional string attachment name to parent to
function ents_methods:setParent (ent, attachment)
	checktype(self, ents_metatable)
	local this = unwrap(self)
	checkpermission(SF.instance, this, "entities.parent")

	if ent ~= nil then
		checktype(ent, ents_metatable)
		ent = unwrap(ent)
		if ent:IsPlayer() then
			if this:GetClass()~="starfall_hologram" then
				SF.Throw("Insufficient permissions", 2)
			end
		else
			checkpermission(SF.instance, ent, "entities.parent")
		end
	end

	this:SetParent(ent)

	if ent ~= nil and attachment then
		checkluatype(attachment, TYPE_STRING)
		this:Fire("SetParentAttachmentMaintainOffset", attachment, 0.01)
	end
end

--- Unparents the entity from another entity
function ents_methods:unparent ()
	local this = unwrap(self)
	checkpermission(SF.instance, this, "entities.unparent")
	this:SetParent(nil)
end

--- Links starfall components to a starfall processor or vehicle. Screen can only connect to processor. HUD can connect to processor and vehicle.
-- @param e Entity to link the component to. nil to clear links.
function ents_methods:linkComponent (e)
	checktype(self, ents_metatable)
	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	checkpermission(SF.instance, ent, "entities.canTool")

	if e then
		checktype(e, ents_metatable)
		local link = unwrap(e)
		if not isValid(link) then SF.Throw("Entity is not valid", 2) end
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


--- Plays a sound on the entity
-- @param snd string Sound path
-- @param lvl number soundLevel=75
-- @param pitch pitchPercent=100
-- @param volume volume=1
-- @param channel channel=CHAN_AUTO
function ents_methods:emitSound (snd, lvl, pitch, volume, channel)
	checktype(self, ents_metatable)
	checkluatype(snd, TYPE_STRING)

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	checkpermission(SF.instance, ent, "entities.emitSound")

	ent:EmitSound(snd, lvl, pitch, volume, channel)
end

--- Applies damage to an entity
-- @param amt damage amount
-- @param attacker damage attacker
-- @param inflictor damage inflictor
function ents_methods:applyDamage(amt, attacker, inflictor)
	checktype(self, ents_metatable)
	checkluatype(amt, TYPE_NUMBER)

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	checkpermission(SF.instance, ent, "entities.applyDamage")

	if attacker then
		checktype(attacker, ents_metatable)
		attacker = unwrap(attacker)
		if not isValid(attacker) then SF.Throw("Entity is not valid", 2) end
	end
	if inflictor then
		checktype(inflictor, ents_metatable)
		inflictor = unwrap(inflictor)
		if not isValid(inflictor) then SF.Throw("Entity is not valid", 2) end
	end

	ent:TakeDamage(amt, attacker, inflictor)
end


--- Applies linear force to the entity
-- @param vec The force vector
function ents_methods:applyForceCenter (vec)
	checktype(self, ents_metatable)
	checktype(vec, SF.Types["Vector"])
	local vec = vunwrap(vec)
	if not check(vec) then SF.Throw("infinite vector", 2) end

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	local phys = ent:GetPhysicsObject()
	if not isValid(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(SF.instance, ent, "entities.applyForce")

	phys:ApplyForceCenter(vec)
end

--- Applies linear force to the entity with an offset
-- @param vec The force vector
-- @param offset An optional offset position
function ents_methods:applyForceOffset (vec, offset)
	checktype(self, ents_metatable)
	checktype(vec, SF.Types["Vector"])
	checktype(offset, SF.Types["Vector"])

	local vec = vunwrap(vec)
	local offset = vunwrap(offset)

	if not check(vec) or not check(offset) then SF.Throw("infinite vector", 2) end

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	local phys = ent:GetPhysicsObject()
	if not isValid(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(SF.instance, ent, "entities.applyForce")

	phys:ApplyForceOffset(vec, offset)
end

--- Applies angular force to the entity
-- @param ang The force angle
function ents_methods:applyAngForce (ang)
	checktype(self, ents_metatable)
	checktype(ang, SF.Types["Angle"])

	local ang = SF.UnwrapObject(ang)
	local ent = unwrap(self)

	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	if not check(ang) then SF.Throw("infinite angle", 2) end

	local phys = ent:GetPhysicsObject()
	if not isValid(phys) then SF.Throw("Physics object is invalid", 2) end

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
function ents_methods:applyTorque (torque)
	checktype(self, ents_metatable)
	checktype(torque, SF.Types["Vector"])

	local torque = vunwrap(torque)

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	local phys = ent:GetPhysicsObject()
	if not isValid(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(SF.instance, ent, "entities.applyForce")

	phys:ApplyTorqueCenter(torque)
end

--- Allows detecting collisions on an entity. You can only do this once for the entity's entire lifespan so use it wisely.
-- @param func The callback function with argument, table collsiondata, http://wiki.garrysmod.com/page/Structures/CollisionData
function ents_methods:addCollisionListener (func)
	checktype(self, ents_metatable)
	checkluatype(func, TYPE_FUNCTION)
	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	checkpermission(SF.instance, ent, "entities.canTool")
	if ent.SF_CollisionCallback then SF.Throw("The entity is already listening to collisions!", 2) end

	local instance = SF.instance
	ent.SF_CollisionCallback = ent:AddCallback("PhysicsCollide", function(ent, data)
		instance:runFunction(func, setmetatable({}, {
			__index = function(t, k)
				return SF.WrapObject(data[k])
			end,
			__metatable = ""
		}))
	end)
end

--- Removes a collision listening hook from the entity so that a new one can be added
function ents_methods:removeCollisionListener ()
	checktype(self, ents_metatable)
	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	checkpermission(SF.instance, ent, "entities.canTool")
	if not ent.SF_CollisionCallback then SF.Throw("The entity isn't listening to collisions!", 2) end
	ent:RemoveCallback("PhysicsCollide", ent.SF_CollisionCallback)
	ent.SF_CollisionCallback = nil
end

--- Set's the entity to collide with nothing but the world
-- @param nocollide Whether to collide with nothing except world or not.
function ents_methods:setNocollideAll (nocollide)
	checktype(self, ents_metatable)
	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	checkpermission(SF.instance, ent, "entities.setSolid")

	ent:SetCollisionGroup (nocollide and COLLISION_GROUP_WORLD or COLLISION_GROUP_NONE)
end

--- Sets whether an entity's shadow should be drawn
-- @param ply Optional player argument to set only for that player. Can also be table of players.
function ents_methods:setDrawShadow (draw, ply)
	checktype(self, ents_metatable)

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	checkpermission(SF.instance, ent, "entities.setRenderProperty")

	if ply then
		sendRenderPropertyToClient(ply, ent, 9, draw and true or false)
	else
		ent:DrawShadow(draw and true or false)
	end
end

--- Sets the entitiy's position
-- @param vec New position
function ents_methods:setPos (vec)
	checktype(self, ents_metatable)
	checktype(vec, SF.Types["Vector"])

	local vec = vunwrap(vec)
	local ent = unwrap(self)

	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	checkpermission(SF.instance, ent, "entities.setPos")

	ent:SetPos(SF.clampPos(vec))
end

--- Sets the entity's angles
-- @param ang New angles
function ents_methods:setAngles (ang)
	checktype(self, ents_metatable)
	checktype(ang, SF.Types["Angle"])
	local ang = SF.UnwrapObject(ang)

	local ent = unwrap(self)

	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	checkpermission(SF.instance, ent, "entities.setAngles")

	ent:SetAngles(ang)
end

--- Sets the entity's linear velocity
-- @param vel New velocity
function ents_methods:setVelocity (vel)
	checktype(self, ents_metatable)
	checktype(vel, SF.Types["Vector"])

	local vel = vunwrap(vel)
	local ent = unwrap(self)

	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	if not check(vel) then SF.Throw("infinite vector", 2) end

	local phys = ent:GetPhysicsObject()
	if not isValid(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(SF.instance, ent, "entities.setVelocity")

	phys:SetVelocity(vel)
end

--- Removes an entity
function ents_methods:remove ()
	checktype(self, ents_metatable)

	local ent = unwrap(self)
	if not ent:IsValid() or ent:IsPlayer() then SF.Throw("Entity is not valid", 2) end
	checkpermission(SF.instance, ent, "entities.remove")

	ent:Remove()
end

--- Invokes the entity's breaking animation and removes it.
function ents_methods:breakEnt ()
	checktype(self, ents_metatable)

	local ent = unwrap(self)
	if not isValid(ent) or ent:IsPlayer() or ent:IsFlagSet(FL_KILLME) then SF.Throw("Entity is not valid", 2) end
	checkpermission(SF.instance, ent, "entities.remove")

	ent:AddFlags(FL_KILLME)
	ent:Fire("break", 1, 0)
end

--- Ignites an entity
-- @param length How long the fire lasts
-- @param radius (optional) How large the fire hitbox is (entity obb is the max)
function ents_methods:ignite(length, radius)
	checktype(self, ents_metatable)
	checkluatype(length, TYPE_NUMBER)

	local ent = unwrap(self)
	if not isValid(ent) or ent:IsPlayer() then SF.Throw("Entity is not valid", 2) end
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
	checktype(self, ents_metatable)

	local ent = unwrap(self)
	if not isValid(ent) or ent:IsPlayer() then SF.Throw("Entity is not valid", 2) end
	checkpermission(SF.instance, ent, "entities.ignite")

	ent:Extinguish()
end

--- Sets the entity frozen state
-- @param freeze Should the entity be frozen?
function ents_methods:setFrozen (freeze)
	checktype(self, ents_metatable)

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	local phys = ent:GetPhysicsObject()
	if not isValid(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(SF.instance, ent, "entities.setFrozen")

	phys:EnableMotion(not (freeze and true or false))
	phys:Wake()
end

--- Checks the entities frozen state
-- @return True if entity is frozen
function ents_methods:isFrozen ()
	checktype(self, ents_metatable)

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	local phys = ent:GetPhysicsObject()
	if not isValid(phys) then SF.Throw("Physics object is invalid", 2) end
	if phys:IsMoveable() then return false else return true end
end

--- Sets the entity to be Solid or not.
-- For more information please refer to GLua function http://wiki.garrysmod.com/page/Entity/SetNotSolid
-- @param solid Boolean, Should the entity be solid?
function ents_methods:setSolid (solid)
	checktype(self, ents_metatable)
	local ent = unwrap(self)

	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	checkpermission(SF.instance, ent, "entities.setSolid")

	ent:SetNotSolid(not solid)
end

--- Sets the entity's mass
-- @param mass number mass
function ents_methods:setMass (mass)
	checktype(self, ents_metatable)

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	local phys = ent:GetPhysicsObject()
	if not isValid(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(SF.instance, ent, "entities.setMass")

	phys:SetMass(math.Clamp(mass, 1, 50000))
end

--- Sets the entity's inertia
-- @param vec Inertia tensor
function ents_methods:setInertia (vec)
	checktype(self, ents_metatable)
	checktype(vec, SF.Types["Vector"])

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	checkpermission(SF.instance, ent, "entities.setInertia")
	local phys = ent:GetPhysicsObject()
	if not isValid(phys) then SF.Throw("Physics object is invalid", 2) end

	local vec = vunwrap(vec)
	if not check(vec) then SF.Throw("infinite vector", 2) end
	vec[1] = math.Clamp(vec[1], 1, 100000)
	vec[2] = math.Clamp(vec[2], 1, 100000)
	vec[3] = math.Clamp(vec[3], 1, 100000)

	phys:SetInertia(vec)
end

--- Sets the physical material of the entity
-- @param mat Material to use
function ents_methods:setPhysMaterial(mat)
	checktype(self, ents_metatable)
	checkluatype(mat, TYPE_STRING)

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	local phys = ent:GetPhysicsObject()
	if not isValid(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(SF.instance, ent, "entities.setMass")

	construct.SetPhysProp(nil, ent, 0, phys, { Material = mat })
end

--- Get the physical material of the entity
-- @return the physical material
function ents_methods:getPhysMaterial()
	checktype(self, ents_metatable)

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	local phys = ent:GetPhysicsObject()
	if not isValid(phys) then SF.Throw("Physics object is invalid", 2) end

	return phys:GetMaterial()
end

--- Checks whether entity has physics
-- @return True if entity has physics
function ents_methods:isValidPhys()
	checktype(self, ents_metatable)

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	local phys = ent:GetPhysicsObject()
	return phys ~= nil
end

--- Returns true if the entity is being held by a player. Either by Physics gun, Gravity gun or Use-key.
-- @server
-- @return Boolean if the entity is being held or not
function ents_methods:isPlayerHolding ()
	checktype(self, ents_metatable)
	return unwrap(self):IsPlayerHolding()
end

--- Sets entity gravity
-- @param grav Bool should the entity respect gravity?
function ents_methods:enableGravity (grav)
	checktype(self, ents_metatable)

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	local phys = ent:GetPhysicsObject()
	if not isValid(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(SF.instance, ent, "entities.enableGravity")

	phys:EnableGravity(grav and true or false)
	phys:Wake()
end

--- Sets the entity drag state
-- @param drag Bool should the entity have air resistence?
function ents_methods:enableDrag (drag)
	checktype(self, ents_metatable)

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	local phys = ent:GetPhysicsObject()
	if not isValid(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(SF.instance, ent, "entities.enableDrag")

	phys:EnableDrag(drag and true or false)
end

--- Sets the entity movement state
-- @param move Bool should the entity move?
function ents_methods:enableMotion (move)
	checktype(self, ents_metatable)

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	local phys = ent:GetPhysicsObject()
	if not isValid(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(SF.instance, ent, "entities.enableMotion")

	phys:EnableMotion(move and true or false)
	phys:Wake()
end


--- Sets the physics of an entity to be a sphere
-- @param enabled Bool should the entity be spherical?
function ents_methods:enableSphere (enabled)
	checktype(self, ents_metatable)

	local ent = unwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	if ent:GetClass() ~= "prop_physics" then SF.Throw("This function only works for prop_physics", 2) end
	local phys = ent:GetPhysicsObject()
	if not isValid(phys) then SF.Throw("Physics object is invalid", 2) end
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

--- Gets what the entity is welded to
--@return The first welded entity
function ents_methods:isWeldedTo()
	checktype(self, ents_metatable)
	local ent = unwrap(self)
	local constr = constraint.FindConstraint(ent, "Weld")
	if constr then
		return vwrap(constr.Ent1 == ent and constr.Ent2 or constr.Ent1)
	end
	return nil
end

--- Gets a table of all constrained entities to each other
--@param constraintype Optional type name of constraint to filter by
function ents_methods:getAllConstrained(constraintype)
	checktype(self, ents_metatable)
	if constraintype ~= nil then checkluatype(constraintype, TYPE_STRING) end

	local entity_lookup = {}
	local entity_table = {}
	local function recursive_find(ent)
		if entity_lookup[ent] then return end
		entity_lookup[ent] = true
		entity_table[#entity_table + 1] = wrap(ent)
		local constraints = constraintype and constraint.FindConstraints(ent, constraintype) or constraint.GetTable(ent)
		for k, v in pairs(constraints) do
			recursive_find(v.Ent1)
			recursive_find(v.Ent2)
		end
	end
	recursive_find(unwrap(self))

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
	checktype(self, ents_metatable)
	checkluatype(material, TYPE_STRING)
	local ent = unwrap(self)
	local time = CurTime()
	if ent._lastTrailSet == time then SF.Throw("Can't modify trail more than once per frame", 2) end
	ent._lastTrailSet = time

	if string.find(material, '"', 1, true) then SF.Throw("Invalid Material", 2) end
	if not IsValid(ent) then SF.Throw("Invalid Entity", 2) end
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
	checktype(self, ents_metatable)
	local ent = unwrap(self)

	if not IsValid(ent) then SF.Throw("Invalid Entity", 2) end
	checkpermission(SF.instance, ent, "entities.setRenderProperty")

	duplicator.EntityModifiers.trail(SF.instance.player, ent, nil)
end

--- Sets a prop_physics to be unbreakable
-- @param on Whether to make the prop unbreakable
function ents_methods:setUnbreakable(on)
	checktype(self, ents_metatable)
	checkluatype(on, TYPE_BOOL)
	local ent = unwrap(self)

	if not IsValid(ent) then SF.Throw("Invalid Entity", 2) end
	checkpermission(SF.instance, ent, "entities.canTool")
	if ent:GetClass() ~= "prop_physics" then SF.Throw("setUnbreakable can only be used on prop_physics", 2) end

	if not IsValid(SF.UnbreakableFilter) then
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

