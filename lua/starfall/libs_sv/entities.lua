-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege
local haspermission = SF.Permissions.hasAccess
local IsValid = FindMetaTable("Entity").IsValid
local IsValidPhys = FindMetaTable("PhysObj").IsValid
local isentity = isentity

local huge = math.huge
local abs = math.abs

-- Register privileges
registerprivilege("entities.applyDamage", "Apply damage", "Allows the user to apply damage to an entity", { entities = {} })
registerprivilege("entities.applyForce", "Apply force", "Allows the user to apply force to an entity", { entities = {} })
registerprivilege("entities.setPos", "Set Position", "Allows the user to teleport an entity to another location", { entities = {} })
registerprivilege("entities.setAngles", "Set Angles", "Allows the user to rotate an entity to another orientation", { entities = {} })
registerprivilege("entities.setEyeAngles", "Set eye angles", "Allows the user to rotate the view of an entity to another orientation", { entities = {} })
registerprivilege("entities.setVelocity", "Set Velocity", "Allows the user to change the velocity of an entity", { entities = {} })
registerprivilege("entities.setSolid", "Set Solid", "Allows the user to change the solidity of an entity", { entities = {} })
registerprivilege("entities.setMass", "Set Mass", "Allows the user to change the mass of an entity", { entities = {} })
registerprivilege("entities.setInertia", "Set Inertia", "Allows the user to change the inertia of an entity", { entities = {} })
registerprivilege("entities.enableGravity", "Enable gravity", "Allows the user to change whether an entity is affected by gravity", { entities = {} })
registerprivilege("entities.enableMotion", "Set Motion", "Allows the user to disable an entity's motion", { entities = {} })
registerprivilege("entities.enableDrag", "Set Drag", "Allows the user to disable an entity's air resistance and change it's coefficient", { entities = {} })
registerprivilege("entities.setDamping", "Set Damping", "Allows the user to change entity's air friction damping", { entities = {} })
registerprivilege("entities.remove", "Remove", "Allows the user to remove entities", { entities = {} })
registerprivilege("entities.ignite", "Ignite", "Allows the user to ignite entities", { entities = {} })
registerprivilege("entities.canTool", "CanTool", "Whether or not the user can use the toolgun on the entity", { entities = {} })
registerprivilege("entities.use", "Use", "Whether or not the user can use the entity", { entities = {} })

local function checkvector(v)
	if v[1]<-1e12 or v[1]>1e12 or v[1]~=v[1] or
	   v[2]<-1e12 or v[2]>1e12 or v[2]~=v[2] or
	   v[3]<-1e12 or v[3]>1e12 or v[3]~=v[3] then

		SF.Throw("Input vector too large or NAN", 3)
	end
end


return function(instance)
local base_physicscollide = baseclass.Get("base_gmodentity").PhysicsCollide
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local owrap, ounwrap = instance.WrapObject, instance.UnwrapObject
local ents_methods, ent_meta, ewrap, eunwrap = instance.Types.Entity.Methods, instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local cunwrap = instance.Types.Color.Unwrap

local getent
local collisionlisteners = {}
instance:AddHook("initialize", function()
	getent = ent_meta.GetEntity
end)
instance:AddHook("deinitialize", function()
	for ent in pairs(collisionlisteners) do
		if IsValid(ent) then
			if ent:IsScripted() then
				ent.PhysicsCollide = base_physicscollide
			else
				ent:RemoveCallback("PhysicsCollide", ent.SF_CollisionCallback)
				ent.SF_CollisionCallback = nil
			end
		end
	end
end)

-- ------------------------- Methods ------------------------- --

--- Links starfall components to a starfall processor or vehicle. Screen can only connect to processor. HUD can connect to processor and vehicle.
-- @param Entity? e Entity to link the component to, a vehicle or starfall for huds, or a starfall for screens. nil to clear links.
function ents_methods:linkComponent(e)
	local ent = getent(self)
	checkpermission(instance, ent, "entities.canTool")

	if e then
		local link = getent(e)
		checkpermission(instance, link, "entities.canTool")

		if link:GetClass()=="starfall_processor" and (ent:GetClass()=="starfall_screen" or ent:GetClass()=="starfall_hud") then
			SF.LinkEnt(ent, link)
		elseif link:IsVehicle() and ent:GetClass()=="starfall_hud" then
			ent:LinkVehicle(link)
		else
			SF.Throw("Invalid Link Entity", 2)
		end
	else
		if ent:GetClass()=="starfall_screen" then
			SF.LinkEnt(ent, nil)
		elseif ent:GetClass()=="starfall_hud" then
			SF.LinkEnt(ent, nil)
			ent:LinkVehicle(nil)
		else
			SF.Throw("Invalid Link Entity", 2)
		end
	end
end

--- Sets a component's ability to lock a player's controls
-- @param boolean enable Whether the component will lock the player's controls when used
function ents_methods:setComponentLocksControls(enable)
	local ent = getent(self)
	checkluatype(enable, TYPE_BOOL)
	checkpermission(instance, ent, "entities.canTool")
	if ent:GetClass()=="starfall_screen" or ent:GetClass()=="starfall_hud" then
		ent.locksControls = enable
	else
		SF.Throw("Entity must be a starfall_screen or starfall_hud", 2)
	end
end

--- Applies damage to an entity
-- @param number amt Damage amount
-- @param Entity? attacker Damage attacker
-- @param Entity? inflictor Damage inflictor
-- @param number? dmgtype The damage type number enum
-- @param Vector? pos The position of the damage
function ents_methods:applyDamage(amt, attacker, inflictor, dmgtype, pos)
	local ent = getent(self)

	checkluatype(amt, TYPE_NUMBER)
	checkpermission(instance, ent, "entities.applyDamage")

	local dmg = DamageInfo()
	dmg:SetDamage(amt)
	if attacker~=nil then
		dmg:SetAttacker(getent(attacker))
	end
	if inflictor~=nil then
		dmg:SetInflictor(getent(inflictor))
	end
	if dmgtype~=nil then
		checkluatype(dmgtype, TYPE_NUMBER)
		dmg:SetDamageType(dmgtype)
	end
	if pos~=nil then
		pos = vunwrap(pos)
		checkvector(pos)
		dmg:SetDamagePosition(pos)
	end
	ent:TakeDamageInfo(dmg)
end

--- Sets a custom prop's physics simulation forces. Thrusters and balloons use this.
-- This takes precedence over Entity.setCustomPropShadowForce and cannot be used together
-- @param Vector ang Angular Force (Torque)
-- @param Vector lin Linear Force
-- @param number mode The physics mode to use. 0 = Off (disables custom physics entirely), 1 = Local acceleration, 2 = Local force, 3 = Global Acceleration, 4 = Global force
function ents_methods:setCustomPropForces(ang, lin, mode)
	local ent = getent(self)
	if ent:GetClass()~="starfall_prop" then SF.Throw("The entity isn't a custom prop", 2) end

	checkpermission(instance, ent, "entities.applyForce")

	if mode == 0 then
		ent:EnableCustomPhysics(false)
	elseif mode == 1 or mode == 2 or mode == 3 or mode == 4 then
		ang = vunwrap(ang)
		checkvector(ang)
		lin = vunwrap(lin)
		checkvector(lin)

		ent.customForceMode = mode
		ent.customForceLinear = lin
		ent.customForceAngular = ang
		ent:EnableCustomPhysics(1)
	else
		SF.Throw("Invalid mode, see the SIM enum", 2)
	end
end

--- Sets a custom prop's shadow forces, moving the entity to the desired position and angles
-- This gets overriden by Entity.setCustomPropForces and cannot be used together
-- See available parameters here: https://wiki.facepunch.com/gmod/PhysObj:ComputeShadowControl
-- @param table|false data Shadow physics data, excluding 'deltatime'. 'teleportdistance' higher than 0 requires 'entities.setPos'. Pass a falsy value to disable custom physics entirely
function ents_methods:setCustomPropShadowForce(data)
	local ent = getent(self)
	if ent:GetClass()~="starfall_prop" then SF.Throw("The entity isn't a custom prop", 2) end

	checkpermission(instance, ent, "entities.applyForce")

	if not data then
		ent:EnableCustomPhysics(false)
	else
		local pos = vunwrap(data.pos)
		checkvector(pos)
		local ang = aunwrap(data.angle)
		checkvector(ang)

		checkluatype(data.teleportdistance, TYPE_NUMBER)
		if data.teleportdistance > 0 and not haspermission(instance, ent, "entities.setPos") then
			SF.Throw("Shadow force property 'teleportdistance' higher than 0 requires 'entities.setPos' permission access", 2)
		end

		checkluatype(data.secondstoarrive, TYPE_NUMBER)
		if data.secondstoarrive < 1e-3 then SF.Throw("Shadow force property 'secondstoarrive' cannot be lower than 0.001", 2) end
		checkluatype(data.dampfactor, TYPE_NUMBER)
		if data.dampfactor > 1 or data.dampfactor < 0 then SF.Throw("Shadow force property 'dampfactor' cannot be higher than 1 or lower than 0", 2) end
		checkluatype(data.maxangular, TYPE_NUMBER)
		checkluatype(data.maxangulardamp, TYPE_NUMBER)
		checkluatype(data.maxspeed, TYPE_NUMBER)
		checkluatype(data.maxspeeddamp, TYPE_NUMBER)

		ent.customShadowForce = {
			pos = pos,
			angle = ang,
			secondstoarrive = data.secondstoarrive,
			dampfactor = data.dampfactor,
			maxangular = data.maxangular,
			maxangulardamp = data.maxangulardamp,
			maxspeed = data.maxspeed,
			maxspeeddamp = data.maxspeeddamp,
			teleportdistance = data.teleportdistance,
		}
		ent:EnableCustomPhysics(2)
	end
end

--- Set the angular velocity of an object
-- @param Vector angvel The local angvel vector to set
function ents_methods:setAngleVelocity(angvel)
	local ent = getent(self)
	angvel = vunwrap(angvel)
	checkvector(angvel)

	local phys = ent:GetPhysicsObject()
	if not IsValidPhys(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(instance, ent, "entities.applyForce")

	phys:AddAngleVelocity(angvel - phys:GetAngleVelocity())
end

--- Applies a angular velocity to an object
-- @param Vector angvel The local angvel vector to apply
function ents_methods:addAngleVelocity(angvel)
	local ent = getent(self)
	angvel = vunwrap(angvel)
	checkvector(angvel)

	local phys = ent:GetPhysicsObject()
	if not IsValidPhys(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(instance, ent, "entities.applyForce")

	phys:AddAngleVelocity(angvel)
end

--- Returns how much friction the entity has, default is 1 (100%)
-- @return number friction
function ents_methods:getFriction()
	return getent(self):GetFriction()
end

--- Sets the entity's friction multiplier
-- @param number friction
function ents_methods:setFriction(friction)
	local ent = getent(self)
	checkpermission(instance, ent, "entities.canTool")
	ent:SetFriction(friction)
end

--- Sets the elasticity of the entity
-- @param number elasticity
function ents_methods:setElasticity(elasticity)
	local ent = getent(self)
	checkpermission(instance, ent, "entities.canTool")
	ent:SetElasticity(elasticity)
end

--- Applies linear force to the entity
-- @param Vector vec The force vector
function ents_methods:applyForceCenter(vec)
	local ent = getent(self)
	vec = vunwrap(vec)
	checkvector(vec)

	local phys = ent:GetPhysicsObject()
	if not IsValidPhys(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(instance, ent, "entities.applyForce")

	phys:ApplyForceCenter(vec)
end

--- Applies linear force to the entity with an offset
-- @param Vector force The force vector in world coordinates
-- @param Vector position The force position in world coordinates
function ents_methods:applyForceOffset(force, position)
	local ent = getent(self)

	force = vunwrap(force)
	checkvector(force)
	position = vunwrap(position)
	checkvector(position)

	local phys = ent:GetPhysicsObject()
	if not IsValidPhys(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(instance, ent, "entities.applyForce")

	phys:ApplyForceOffset(force, position)
end

--- Applies angular force to the entity (This function is garbage, use applyTorque instead)
-- @param Angle ang The force angle
function ents_methods:applyAngForce(ang)
	local ent = getent(self)

	ang = aunwrap(ang)
	checkvector(ang)

	local phys = ent:GetPhysicsObject()
	if not IsValidPhys(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(instance, ent, "entities.applyForce")

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
-- @param Vector torque The torque vector
function ents_methods:applyTorque(torque)
	local ent = getent(self)

	torque = vunwrap(torque)
	checkvector(torque)

	local phys = ent:GetPhysicsObject()
	if not IsValidPhys(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(instance, ent, "entities.applyForce")

	phys:ApplyTorqueCenter(torque)
end

local entity_collisions = {}
local function addCollisions(func)
	return function(data)
		if next(entity_collisions)==nil then
			timer.Simple(0, function()
				for i=1, #entity_collisions do
					instance:runFunction(func, SF.StructWrapper(instance, entity_collisions[i], "CollisionData"))
					entity_collisions[i] = nil
				end
			end)
		end
		entity_collisions[#entity_collisions+1] = data
	end
end
--- Allows detecting collisions on an entity. You can only do this once for the entity's entire lifespan so use it wisely.
-- @param function func The callback function with argument, table collsiondata, http://wiki.facepunch.com/gmod/Structures/CollisionData
function ents_methods:addCollisionListener(func)
	local ent = getent(self)
	if collisionlisteners[ent] then SF.Throw("The entity is already listening to collisions!", 2) end

	checkluatype(func, TYPE_FUNCTION)
	checkpermission(instance, ent, "entities.canTool")

	local callback = addCollisions(func)
	if ent:IsScripted() then
		if ent.PhysicsCollide ~= base_physicscollide and ent.PhysicsCollide ~= nil then SF.Throw("The entity is already listening to collisions!", 2) end
		function ent:PhysicsCollide( data, phys ) callback(data) end
	else
		ent.SF_CollisionCallback = ent:AddCallback("PhysicsCollide", function(ent, data) callback(data) end)
	end
	collisionlisteners[ent] = true
end

--- Removes a collision listening hook from the entity so that a new one can be added
function ents_methods:removeCollisionListener()
	local ent = getent(self)
	if not collisionlisteners[ent] then SF.Throw("The entity isn't listening to collisions!", 2) end

	checkpermission(instance, ent, "entities.canTool")

	if ent:IsScripted() then
		ent.PhysicsCollide = base_physicscollide
	else
		ent:RemoveCallback("PhysicsCollide", ent.SF_CollisionCallback)
		ent.SF_CollisionCallback = nil
	end
	collisionlisteners[ent] = nil
end

--- Sets whether an entity's shadow should be drawn
-- @param boolean draw Whether the shadow should draw
function ents_methods:setDrawShadow(draw)
	local ent = getent(self)
	checkpermission(instance, ent, "entities.setRenderProperty")
	checkluatype(draw, TYPE_BOOL)
	ent:DrawShadow(draw)
end

--- Sets the entity's position. No interpolation will occur clientside, use physobj.setPos to have interpolation.
-- @param Vector vec New position
function ents_methods:setPos(vec)
	local ent = getent(self)

	vec = vunwrap(vec)
	checkpermission(instance, ent, "entities.setPos")

	ent:SetPos(SF.clampPos(vec))
end

--- Sets the entity's angles
-- @param Angle ang New angles
function ents_methods:setAngles(ang)
	local ent = getent(self)

	ang = aunwrap(ang)
	checkpermission(instance, ent, "entities.setAngles")

	ent:SetAngles(ang)
end

--- Sets the entity's linear velocity. Physics entities, use physobj:setVelocity
-- @param Vector vel New velocity
function ents_methods:setVelocity(vel)
	local ent = getent(self)

	vel = vunwrap(vel)
	checkvector(vel)

	checkpermission(instance, ent, "entities.setVelocity")

	ent:SetVelocity(vel)
end

--- Applies velocity to an object
-- @param Vector vel The world velocity vector to apply
function ents_methods:addVelocity(vel)
	local ent = getent(self)
	vel = vunwrap(vel)
	checkvector(vel)

	local phys = ent:GetPhysicsObject()
	if not IsValidPhys(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(instance, ent, "entities.applyForce")

	phys:AddVelocity(vel)
end

--- Removes an entity
function ents_methods:remove()
	local ent = getent(self)
	if ent:IsWorld() or ent:IsPlayer() then SF.Throw("Cannot remove world or player", 2) end
	checkpermission(instance, ent, "entities.remove")

	ent:Remove()
end

--- Invokes the entity's breaking animation and removes it.
function ents_methods:breakEnt()
	local ent = getent(self)
	if ent:IsPlayer() or ent.WasBroken then SF.Throw("Entity is not valid", 2) end
	checkpermission(instance, ent, "entities.remove")

	ent.WasBroken = true
	ent:Fire("break", 1, 0)
end

--- Ignites an entity
-- @param number length How long the fire lasts
-- @param number? radius (optional) How large the fire hitbox is (entity obb is the max)
function ents_methods:ignite(length, radius)
	local ent = getent(self)
	checkluatype(length, TYPE_NUMBER)

	checkpermission(instance, ent, "entities.ignite")

	if radius~=nil then
		checkluatype(radius, TYPE_NUMBER)
		local obbmins, obbmaxs = ent:OBBMins(), ent:OBBMaxs()
		radius = math.Clamp(radius, 0, (obbmaxs.x - obbmins.x + obbmaxs.y - obbmins.y) / 2)
	end

	ent:Ignite(length, radius)
end

--- Extinguishes an entity
function ents_methods:extinguish()
	local ent = getent(self)
	checkpermission(instance, ent, "entities.ignite")

	ent:Extinguish()
end

--- Simulate a Use action on the entity by the chip owner
-- @param number? usetype The USE_ enum use type. (Default: USE_ON)
-- @param number? value The use value (Default: 0)
function ents_methods:use(usetype, value)
    local ent = getent(self)
    checkpermission(instance, ent, "entities.use")
    if usetype~=nil then checkluatype(usetype, TYPE_NUMBER) end
    if value~=nil then checkluatype(value, TYPE_NUMBER) end
    ent:Use(instance.player, instance.entity, usetype, value)
end

--- Sets the entity to be Solid or not.
-- @param boolean solid Should the entity be solid?
function ents_methods:setSolid(solid)
	local ent = getent(self)
	if ent:IsPlayer() then SF.Throw("Target is a player!", 2) end
	checkpermission(instance, ent, "entities.setSolid")

	ent:SetNotSolid(not solid)
end

--- Sets the entity's collision group
-- @param number group The COLLISION_GROUP value to set it to
function ents_methods:setCollisionGroup(group)
	checkluatype(group, TYPE_NUMBER)
	if group < 0 or group >= LAST_SHARED_COLLISION_GROUP then SF.Throw("Invalid collision group value", 2) end
	local ent = getent(self)
	if ent:IsPlayer() then SF.Throw("Target is a player!", 2) end
	checkpermission(instance, ent, "entities.setSolid")

	ent:SetCollisionGroup(group)
end

--- Set's the entity to collide with nothing but the world. Alias to entity:setCollisionGroup(COLLISION_GROUP_WORLD)
-- @param boolean nocollide Whether to collide with nothing except world or not.
function ents_methods:setNocollideAll(nocollide)
	local ent = getent(self)
	if ent:IsPlayer() then SF.Throw("Target is a player!", 2) end
	checkpermission(instance, ent, "entities.setSolid")

	ent:SetCollisionGroup(nocollide and COLLISION_GROUP_WORLD or COLLISION_GROUP_NONE)
end

--- Sets the entity's mass
-- @param number mass Mass to set to
function ents_methods:setMass(mass)
	local ent = getent(self)
	if ent:IsPlayer() then SF.Throw("Target is a player!", 2) end
	checkluatype(mass, TYPE_NUMBER)
	local phys = ent:GetPhysicsObject()
	if not IsValidPhys(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(instance, ent, "entities.setMass")

	local m = math.Clamp(mass, 1, 50000)
	phys:SetMass(m)
	duplicator.StoreEntityModifier(ent, "mass", { Mass = m })
end

--- Sets the entity's inertia
-- @param Vector vec Inertia tensor
function ents_methods:setInertia(vec)
	local ent = getent(self)
	if ent:IsPlayer() then SF.Throw("Target is a player!", 2) end
	checkpermission(instance, ent, "entities.setInertia")
	local phys = ent:GetPhysicsObject()
	if not IsValidPhys(phys) then SF.Throw("Physics object is invalid", 2) end

	vec = vunwrap(vec)
	checkvector(vec)
	vec[1] = math.Clamp(vec[1], 1, 100000)
	vec[2] = math.Clamp(vec[2], 1, 100000)
	vec[3] = math.Clamp(vec[3], 1, 100000)

	phys:SetInertia(vec)
end

--- Sets the physical material of the entity
-- @param string materialName Material to use
function ents_methods:setPhysMaterial(mat)
	local ent = getent(self)
	if ent:IsPlayer() then SF.Throw("Target is a player!", 2) end
	checkluatype(mat, TYPE_STRING)
	local phys = ent:GetPhysicsObject()
	if not IsValidPhys(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(instance, ent, "entities.setMass")

	construct.SetPhysProp(nil, ent, 0, phys, { Material = mat })
end

--- Get the physical material of the entity
-- @return string The physical material
function ents_methods:getPhysMaterial()
	local ent = getent(self)
	local phys = ent:GetPhysicsObject()
	if not IsValidPhys(phys) then SF.Throw("Physics object is invalid", 2) end

	return phys:GetMaterial()
end

--- Checks whether entity has physics
-- @return boolean If entity has physics
function ents_methods:isValidPhys()
	local ent = getent(self)
	local phys = ent:GetPhysicsObject()
	return IsValidPhys(phys)
end

--- Returns true if the entity is being held by a player. Either by Physics gun, Gravity gun or Use-key.
-- @server
-- @return boolean If the entity is being held or not
function ents_methods:isPlayerHolding()
	local ent = getent(self)
	return ent:IsPlayerHolding()
end

--- Returns if the entity is a constraint.
-- @server
-- @return boolean If the entity is a constraint
function ents_methods:isConstraint()
	return getent(self):IsConstraint()
end

--- Sets entity gravity
-- @param boolean grav Should the entity respect gravity?
function ents_methods:enableGravity(grav)
	local ent = getent(self)
	if ent:IsPlayer() then SF.Throw("Target is a player!", 2) end
	local phys = ent:GetPhysicsObject()
	if not IsValidPhys(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(instance, ent, "entities.enableGravity")

	phys:EnableGravity(grav and true or false)
	phys:Wake()
end

--- Sets the entity drag state
-- @param boolean drag Should the entity have air resistance?
function ents_methods:enableDrag(drag)
	local ent = getent(self)
	if ent:IsPlayer() then SF.Throw("Target is a player!", 2) end
	local phys = ent:GetPhysicsObject()
	if not IsValidPhys(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(instance, ent, "entities.enableDrag")

	phys:EnableDrag(drag and true or false)
end

--- Sets the entity movement state
-- @param boolean move Should the entity move?
function ents_methods:enableMotion(move)
	local ent = getent(self)
	if ent:IsPlayer() then SF.Throw("Target is a player!", 2) end
	local phys = ent:GetPhysicsObject()
	if not IsValidPhys(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(instance, ent, "entities.enableMotion")

	phys:EnableMotion(move and true or false)
	phys:Wake()
end

--- Sets the entity frozen state, same as `Entity.enableMotion` but inverted
-- @param boolean freeze Should the entity be frozen?
function ents_methods:setFrozen(freeze)
	self:enableMotion(not freeze)
end

--- Checks the entities frozen state
-- @return boolean True if entity is frozen
function ents_methods:isFrozen()
	local ent = getent(self)
	local phys = ent:GetPhysicsObject()
	if not IsValidPhys(phys) then SF.Throw("Physics object is invalid", 2) end
	return not phys:IsMoveable()
end

--- Sets the physics of an entity to be a sphere
-- @param boolean enabled Should the entity be spherical?
-- @param number? radius Optional custom radius to use (max 500). Otherwise the prop's obb is used
function ents_methods:enableSphere(enabled, radius)
	local ent = getent(self)
	if ent:GetClass() ~= "prop_physics" then SF.Throw("This function only works for prop_physics", 2) end
	local phys = ent:GetPhysicsObject()
	if not IsValidPhys(phys) then SF.Throw("Physics object is invalid", 2) end
	checkpermission(instance, ent, "entities.enableMotion")

	local ismove = phys:IsMoveable()
	local mass = phys:GetMass()

	if enabled then
		if ent:GetMoveType() == MOVETYPE_VPHYSICS then
			if radius~=nil then
				checkluatype(radius, TYPE_NUMBER)
				radius = math.Clamp(radius, 0.2, 500)
			else
				local OBB = ent:OBBMaxs() - ent:OBBMins()
				radius = math.max(OBB.x, OBB.y, OBB.z) / 2
			end
			ent:PhysicsInitSphere(radius, phys:GetMaterial())
			ent:SetCollisionBounds(Vector(-radius, -radius, -radius) , Vector(radius, radius, radius))
	
			-- https://github.com/daveth/makespherical/blob/80b702ba04ba4b64d6c378df8d405b2c113dec53/lua/weapons/gmod_tool/stools/makespherical.lua#L117
			local info = {
				obbcenter = ent.obbcenter,
				noradius = radius,
				radius = radius,
				mass = mass,
				enabled = enabled,
				isrenderoffset = 0
			}
			
			duplicator.StoreEntityModifier(ent, "MakeSphericalCollisions", info)
		end
	else
		ent:PhysicsInit(SOLID_VPHYSICS)
		ent:SetMoveType(MOVETYPE_VPHYSICS)
		ent:SetSolid(SOLID_VPHYSICS)

		duplicator.ClearEntityModifier(ent, "MakeSphericalCollisions")
	end

	-- New physobject after applying spherical collisions
	phys = ent:GetPhysicsObject()
	phys:SetMass(mass)
	phys:EnableMotion(ismove)
	phys:Wake()
end

--- Gets what the entity is welded to. If the entity is parented, returns the parent.
-- @return Entity The first welded/parent entity
function ents_methods:isWeldedTo()
	local ent = getent(self)
	local constr = constraint.FindConstraint(ent, "Weld")
	if constr then
		return owrap(constr.Ent1 == ent and constr.Ent2 or constr.Ent1)
	end

	local parent = ent:GetParent()
	if IsValid(parent) then
		return owrap(parent)
	end

	return nil
end

--- Gets a table of all constrained entities to each other
-- @param table? filter Optional constraint type filter table where keys are the type name and values are 'true'. "Wire" and "Parent" are used for wires and parents.
function ents_methods:getAllConstrained(filter)
	if filter ~= nil then checkluatype(filter, TYPE_TABLE) end

	local entity_lookup = {}
	local entity_table = {}
	local function recursive_find(ent)
		if entity_lookup[ent] then return end
		entity_lookup[ent] = true
		if IsValid(ent) then
			entity_table[#entity_table + 1] = owrap(ent)
			local constraints = constraint.GetTable(ent)
			for _, v in pairs(constraints) do
				if not filter or filter[v.Type] then
					if v.Ent1 then recursive_find(v.Ent1) end
					if v.Ent2 then recursive_find(v.Ent2) end
				end
			end
			if not filter or filter.Parent then
				local parent = ent:GetParent()
				if parent then recursive_find(parent) end
				for _, child in pairs(ent:GetChildren()) do
					recursive_find(child)
				end
			end
			if not filter or filter.Wire then
				if istable(ent.Inputs) then
					for _, v in pairs(ent.Inputs) do
						if isentity(v.Src) and IsValid(v.Src) then
							recursive_find(v.Src)
						end
					end
				end
				if istable(ent.Outputs) then
					for _, v in pairs(ent.Outputs) do
						if istable(v.Connected) then
							for _, v in pairs(v.Connected) do
								if isentity(v.Entity) and IsValid(v.Entity) then
									recursive_find(v.Entity)
								end
							end
						end
					end
				end
			end
		end
	end
	recursive_find(getent(self))

	return entity_table
end

--- Adds a trail to the entity with the specified attributes.
-- @param number startSize The start size of the trail (0-128)
-- @param number endSize The end size of the trail (0-128)
-- @param number length The length size of the trail
-- @param string material The material of the trail
-- @param Color color The color of the trail
-- @param number? attachmentID Optional attachmentid the trail should attach to
-- @param boolean? additive If the trail's rendering is additive
function ents_methods:setTrails(startSize, endSize, length, material, color, attachmentID, additive)
	local ent = getent(self)
	checkluatype(material, TYPE_STRING)
	local time = CurTime()
	if ent._lastTrailSet == time then SF.Throw("Can't modify trail more than once per frame", 2) end
	ent._lastTrailSet = time

	if string.find(material, '"', 1, true) then SF.Throw("Invalid Material", 2) end
	checkpermission(instance, ent, "entities.setRenderProperty")

	local Data = {
		Color = cunwrap(color),
		Length = length,
		StartSize = math.Clamp(startSize, 0, 128),
		EndSize = math.Clamp(endSize, 0, 128),
		Material = material,
		AttachmentID = attachmentID,
		Additive = additive,
	}

	duplicator.EntityModifiers.trail(instance.player, ent, Data)
end

--- Removes trails from the entity
function ents_methods:removeTrails()
	local ent = getent(self)
	checkpermission(instance, ent, "entities.setRenderProperty")

	duplicator.EntityModifiers.trail(instance.player, ent, nil)
end

--- Sets a prop_physics to be unbreakable
-- @param boolean on Whether to make the prop unbreakable
function ents_methods:setUnbreakable(on)
	local ent = getent(self)
	checkluatype(on, TYPE_BOOL)
	checkpermission(instance, ent, "entities.canTool")
	if ent:GetClass() ~= "prop_physics" then SF.Throw("setUnbreakable can only be used on prop_physics", 2) end

	if not IsValid(SF.UnbreakableFilter) then
		local FilterDamage = ents.FindByName("FilterDamage")[1]
		if not FilterDamage then
			FilterDamage = ents.Create( "filter_activator_name" )
			FilterDamage:SetKeyValue( "TargetName", "FilterDamage" )
			FilterDamage:SetKeyValue( "negated", "1" )
			FilterDamage:Spawn()
		end
		SF.UnbreakableFilter = FilterDamage
	end

	ent:Fire( "SetDamageFilter", on and "FilterDamage" or "", 0 )
end

--- Check if the given Entity or Vector is within this entity's PVS (Potentially Visible Set). See: https://developer.valvesoftware.com/wiki/PVS
-- @param Entity|Vector other Entity or Vector to test
-- @return boolean If the Entity/Vector is within the PVS
function ents_methods:testPVS(other)
	local ent = getent(self)

	local meta = debug.getmetatable(other)
	if meta==vec_meta then
		other = vunwrap(other)
	elseif meta==ent_meta then
		other = getent(other)
	else
		SF.ThrowTypeError("Entity or Vector", SF.GetType(other), 2)
	end

	return ent:TestPVS(other)
end

--- Returns entity's creation ID (similar to entIndex, but increments monotonically)
-- @return number The creation ID
function ents_methods:getCreationID()
	local ent = getent(self)
	return ent:GetCreationID()
end

local physUpdateWhitelist = {
	["starfall_prop"] = true,
	["starfall_processor"] = true,
}

--- Set the function to run whenever the physics of the entity are updated.
--- This won't be called if the physics object goes asleep.
---
--- You can only use this function on these classes:
--- - starfall_prop
--- - starfall_processor
-- @param function|nil func The callback function. Use nil to remove an existing callback.
function ents_methods:setPhysicsUpdateListener(func)
	local ent = getent(self)

	checkpermission(instance, ent, "entities.canTool")

	local class = ent:GetClass()

	if not physUpdateWhitelist[class] then
		SF.Throw("Cannot use physics update listener on " .. class, 2)
	end

	if func then
		checkluatype(func, TYPE_FUNCTION)

		ent.PhysicsUpdate = function()
			instance:runFunction(func)
		end
	else
		ent.PhysicsUpdate = nil
	end
end

end
