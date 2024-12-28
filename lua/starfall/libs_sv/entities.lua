-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege
local haspermission = SF.Permissions.hasAccess
local dgetmeta = debug.getmetatable
local ENT_META,NPC_META,PHYS_META,PLY_META,VEH_META,WEP_META = FindMetaTable("Entity"),FindMetaTable("NPC"),FindMetaTable("PhysObj"),FindMetaTable("Player"),FindMetaTable("Vehicle"),FindMetaTable("Weapon")
local isentity = isentity

local Ent_AddCallback,Ent_GetTable,Ent_IsScripted,Ent_IsValid,Ent_RemoveCallback = ENT_META.AddCallback,ENT_META.GetTable,ENT_META.IsScripted,ENT_META.IsValid,ENT_META.RemoveCallback

-- Register privileges
registerprivilege("entities.applyDamage", "Apply damage", "Allows the user to apply damage to an entity", { entities = {} })
registerprivilege("entities.applyForce", "Apply force", "Allows the user to apply force to an entity", { entities = {} })
registerprivilege("entities.setPos", "Set Position", "Allows the user to teleport an entity to another location", { entities = {} })
registerprivilege("entities.setAngles", "Set Angles", "Allows the user to rotate an entity to another orientation", { entities = {} })
registerprivilege("entities.setEyeAngles", "Set eye angles", "Allows the user to rotate the view of an entity to another orientation", { entities = {} })
registerprivilege("entities.setVelocity", "Set Velocity", "Allows the user to change the velocity of an entity", { entities = {} })
registerprivilege("entities.setSolid", "Set Solid", "Allows the user to change the solidity of an entity", { entities = {} })
registerprivilege("entities.setContents", "Set Contents", "Allows the user to change the contents flag of an entity", { entities = {} })
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
registerprivilege("entities.getTable", "GetTable", "Allows the user to get an entity's table", { entities = {}, usergroups = { default = 1 } })

local function table_find(tbl, val)
	for i=1, #tbl do if tbl[i]==val then return i end end
end

local collisionListenerLimit = SF.LimitObject("collisionlistener", "collisionlistner", 128, "The number of concurrent starfall collision listeners")
local base_physicscollide
SF.GlobalCollisionListeners = {
	__index = {
		create = function(self, ent)
			local listenertable = {}
			local ent_tbl = Ent_GetTable(ent)

			local queue = {}
			local nqueue = 0
			local function collisionQueueProcess()
				if Ent_IsValid(ent) then
					for _, listener in ipairs(listenertable) do
						local instance = listener.instance
						for i=1, nqueue do
							listener:run(instance, SF.StructWrapper(instance, queue[i], "CollisionData"))
						end
					end
				end
				for i=1, nqueue do
					queue[i] = nil
				end
				nqueue = 0
			end

			local function collisionQueueCallback(ent, data)
				nqueue = nqueue + 1
				queue[nqueue] = data
				if nqueue==1 then timer.Simple(0, collisionQueueProcess) end
			end

			if Ent_IsScripted(ent) then
				local oldPhysicsCollide = ent_tbl.PhysicsCollide or base_physicscollide
				ent_tbl.SF_OldPhysicsCollide = oldPhysicsCollide

				function ent_tbl:PhysicsCollide(data, phys)
					oldPhysicsCollide(self, data, phys)
					collisionQueueCallback(self, data)
				end
			else
				ent_tbl.SF_CollisionCallback = Ent_AddCallback(ent, "PhysicsCollide", collisionQueueCallback)
			end
			SF.CallOnRemove(ent, "RemoveCollisionListeners", function(e) self:destroy(e) end)

			self.listeners[ent] = listenertable
			return listenertable
		end,
		destroy = function(self, ent)
			local entlisteners = self.listeners[ent]
			if entlisteners==nil then return end
			self.listeners[ent] = nil
			for _, listener in ipairs(entlisteners) do
				listener.manager:free(ent)
			end
			if Ent_IsValid(ent) then
				local ent_tbl = Ent_GetTable(ent)
				local oldPhysicsCollide = ent_tbl.SF_OldPhysicsCollide
				if oldPhysicsCollide then
					ent_tbl.PhysicsCollide = oldPhysicsCollide
				else
					Ent_RemoveCallback(ent, "PhysicsCollide", ent_tbl.SF_CollisionCallback)
				end

				SF.RemoveCallOnRemove(ent, "RemoveCollisionListeners")
			end
		end,
		add = function(self, ent, listener)
			local entlisteners = self.listeners[ent]
			if entlisteners == nil then
				entlisteners = self:create(ent)
			elseif table_find(entlisteners, listener) then
				return
			end
			entlisteners[#entlisteners + 1] = listener
		end,
		remove = function(self, ent, listener)
			local entlisteners = self.listeners[ent]
			if entlisteners==nil then return end
			local i = table_find(entlisteners, listener)
			if i==nil then return end

			entlisteners[i] = entlisteners[#entlisteners]
			entlisteners[#entlisteners] = nil
			if entlisteners[1]==nil then self:destroy(ent) end
		end
	},
	__call = function(p)
		return setmetatable({
			listeners = {}
		}, p)
	end
}
setmetatable(SF.GlobalCollisionListeners, SF.GlobalCollisionListeners)
local globalListeners = SF.GlobalCollisionListeners()

SF.InstanceCollisionListeners = {
	__index = {
		add = function(self, ent, name, func)
			local created = false
			local listener = self.hooksPerEnt[ent]
			if listener==nil then
				collisionListenerLimit:checkuse(self.instance.player, 1)
				listener = SF.HookTable()
				listener.manager = self
				listener.instance = self.instance
				self.hooksPerEnt[ent] = listener

				globalListeners:add(ent, listener)
				created = true
			elseif not listener:exists(name) then
				collisionListenerLimit:checkuse(self.instance.player, 1)
				created = true
			end

			listener:add(name, func)

			if created then
				collisionListenerLimit:free(self.instance.player, -1)
			end
		end,
		remove = function(self, ent, name)
			local listener = self.hooksPerEnt[ent]
			if listener and listener:exists(name) then
				listener:remove(name)
				collisionListenerLimit:free(self.instance.player, 1)
				if listener:isEmpty() then
					self.hooksPerEnt[ent] = nil
					globalListeners:remove(ent, listener)
				end
			end
		end,
		free = function(self, ent)
			local listener = self.hooksPerEnt[ent]
			if listener then
				collisionListenerLimit:free(self.instance.player, listener.n)
				self.hooksPerEnt[ent] = nil
			end
		end,
		destroy = function(self)
			for ent, listener in pairs(self.hooksPerEnt) do
				collisionListenerLimit:free(self.instance.player, listener.n)
				self.hooksPerEnt[ent] = nil
				globalListeners:remove(ent, listener)
			end
		end
	},
	__call = function(p, instance)
		return setmetatable({
			instance = instance,
			hooksPerEnt = {}
		}, p)
	end
}
setmetatable(SF.InstanceCollisionListeners, SF.InstanceCollisionListeners)

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

return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end
local Ent_AddCallback,Ent_DrawShadow,Ent_Extinguish,Ent_Fire,Ent_GetChildren,Ent_GetClass,Ent_GetCreationID,Ent_GetForward,Ent_GetFriction,Ent_GetMoveType,Ent_GetParent,Ent_GetPhysicsObject,Ent_GetRight,Ent_GetTable,Ent_GetUp,Ent_GetVar,Ent_Ignite,Ent_IsConstraint,Ent_IsPlayer,Ent_IsPlayerHolding,Ent_IsScripted,Ent_IsValid,Ent_IsVehicle,Ent_IsWorld,Ent_OBBMaxs,Ent_OBBMins,Ent_PhysicsInit,Ent_PhysicsInitSphere,Ent_Remove,Ent_RemoveCallback,Ent_SetAngles,Ent_SetCollisionBounds,Ent_SetCollisionGroup,Ent_SetElasticity,Ent_SetFriction,Ent_SetLightingOriginEntity,Ent_SetLocalAngles,Ent_SetLocalPos,Ent_SetMoveType,Ent_SetNotSolid,Ent_SetPos,Ent_SetSolid,Ent_SetVelocity,Ent_TestPVS,Ent_Use = ENT_META.AddCallback,ENT_META.DrawShadow,ENT_META.Extinguish,ENT_META.Fire,ENT_META.GetChildren,ENT_META.GetClass,ENT_META.GetCreationID,ENT_META.GetForward,ENT_META.GetFriction,ENT_META.GetMoveType,ENT_META.GetParent,ENT_META.GetPhysicsObject,ENT_META.GetRight,ENT_META.GetTable,ENT_META.GetUp,ENT_META.GetVar,ENT_META.Ignite,ENT_META.IsConstraint,ENT_META.IsPlayer,ENT_META.IsPlayerHolding,ENT_META.IsScripted,ENT_META.IsValid,ENT_META.IsVehicle,ENT_META.IsWorld,ENT_META.OBBMaxs,ENT_META.OBBMins,ENT_META.PhysicsInit,ENT_META.PhysicsInitSphere,ENT_META.Remove,ENT_META.RemoveCallback,ENT_META.SetAngles,ENT_META.SetCollisionBounds,ENT_META.SetCollisionGroup,ENT_META.SetElasticity,ENT_META.SetFriction,ENT_META.SetLightingOriginEntity,ENT_META.SetLocalAngles,ENT_META.SetLocalPos,ENT_META.SetMoveType,ENT_META.SetNotSolid,ENT_META.SetPos,ENT_META.SetSolid,ENT_META.SetVelocity,ENT_META.TestPVS,ENT_META.Use
local function Ent_IsNPC(ent) return dgetmeta(ent)==NPC_META end
local function Ent_IsPlayer(ent) return dgetmeta(ent)==PLY_META end
local function Ent_IsVehicle(ent) return dgetmeta(ent)==VEH_META end
local function Ent_IsWeapon(ent) return dgetmeta(ent)==WEP_META end

local Phys_AddAngleVelocity,Phys_AddVelocity,Phys_ApplyForceCenter,Phys_ApplyForceOffset,Phys_ApplyTorqueCenter,Phys_EnableDrag,Phys_EnableGravity,Phys_EnableMotion,Phys_GetAngleVelocity,Phys_GetMass,Phys_GetMaterial,Phys_IsMoveable,Phys_IsValid,Phys_SetContents,Phys_SetInertia,Phys_SetMass,Phys_Wake = PHYS_META.AddAngleVelocity,PHYS_META.AddVelocity,PHYS_META.ApplyForceCenter,PHYS_META.ApplyForceOffset,PHYS_META.ApplyTorqueCenter,PHYS_META.EnableDrag,PHYS_META.EnableGravity,PHYS_META.EnableMotion,PHYS_META.GetAngleVelocity,PHYS_META.GetMass,PHYS_META.GetMaterial,PHYS_META.IsMoveable,PHYS_META.IsValid,PHYS_META.SetContents,PHYS_META.SetInertia,PHYS_META.SetMass,PHYS_META.Wake

local owrap, ounwrap = instance.WrapObject, instance.UnwrapObject
local ents_methods, ent_meta, ewrap, eunwrap = instance.Types.Entity.Methods, instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local cunwrap = instance.Types.Color.Unwrap

local collisionListeners = SF.InstanceCollisionListeners(instance)
base_physicscollide = baseclass.Get("base_gmodentity").PhysicsCollide

local getent
local vunwrap1, vunwrap2, aunwrap1
instance:AddHook("initialize", function()
	getent = ent_meta.GetEntity
	vunwrap1, vunwrap2, aunwrap1 = vec_meta.QuickUnwrap1, vec_meta.QuickUnwrap2, ang_meta.QuickUnwrap1
end)

instance:AddHook("deinitialize", function()
	collisionListeners:destroy()
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

		if Ent_GetClass(link)=="starfall_processor" and (Ent_GetClass(ent)=="starfall_screen" or Ent_GetClass(ent)=="starfall_hud") then
			SF.LinkEnt(ent, link)
		elseif Ent_IsVehicle(link) and Ent_GetClass(ent)=="starfall_hud" then
			ent:LinkVehicle(link)
		else
			SF.Throw("Invalid Link Entity", 2)
		end
	else
		if Ent_GetClass(ent)=="starfall_screen" then
			SF.LinkEnt(ent, nil)
		elseif Ent_GetClass(ent)=="starfall_hud" then
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
	if Ent_GetClass(ent)=="starfall_screen" or Ent_GetClass(ent)=="starfall_hud" then
		Ent_GetTable(ent).locksControls = enable
	else
		SF.Throw("Entity must be a starfall_screen or starfall_hud", 2)
	end
end

--- Applies damage to an entity
-- @param number amt Damage amount
-- @param Entity? attacker Damage attacker. Defaults to chip owner
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
	else
		dmg:SetAttacker(instance.player)
	end
	if inflictor~=nil then
		dmg:SetInflictor(getent(inflictor))
	end
	if dmgtype~=nil then
		checkluatype(dmgtype, TYPE_NUMBER)
		dmg:SetDamageType(dmgtype)
	end
	if pos~=nil then
		pos = vunwrap1(pos)
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
	local ent_tbl = Ent_GetTable(ent)
	if Ent_GetClass(ent)~="starfall_prop" then SF.Throw("The entity isn't a custom prop", 2) end

	checkpermission(instance, ent, "entities.applyForce")

	if mode == 0 then
		ent_tbl.EnableCustomPhysics(ent, false)
	elseif mode == 1 or mode == 2 or mode == 3 or mode == 4 then
		ang = vunwrap1(ang)
		checkvector(ang)
		lin = vunwrap2(lin)
		checkvector(lin)

		ent_tbl.customForceMode = mode
		ent_tbl.customForceLinear:Set(lin)
		ent_tbl.customForceAngular:Set(ang)
		ent_tbl.EnableCustomPhysics(ent, 1)
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
	local ent_tbl = Ent_GetTable(ent)
	if Ent_GetClass(ent)~="starfall_prop" then SF.Throw("The entity isn't a custom prop", 2) end

	checkpermission(instance, ent, "entities.applyForce")

	if data then
		local pos = vunwrap1(data.pos)
		checkvector(pos)
		local ang = aunwrap1(data.angle)
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

		local customShadowForce = ent_tbl.customShadowForce
		customShadowForce.pos:Set(pos)
		customShadowForce.angle:Set(ang)
		customShadowForce.secondstoarrive = data.secondstoarrive
		customShadowForce.dampfactor = data.dampfactor
		customShadowForce.maxangular = data.maxangular
		customShadowForce.maxangulardamp = data.maxangulardamp
		customShadowForce.maxspeed = data.maxspeed
		customShadowForce.maxspeeddamp = data.maxspeeddamp
		customShadowForce.teleportdistance = data.teleportdistance

		ent_tbl.EnableCustomPhysics(ent, 2)
	else
		ent_tbl.EnableCustomPhysics(ent, false)
	end
end

--- Set the angular velocity of an object
-- @param Vector angvel The local angvel vector to set
function ents_methods:setAngleVelocity(angvel)
	local ent = getent(self)
	angvel = vunwrap1(angvel)
	checkvector(angvel)

	local phys = Ent_GetPhysicsObject(ent)
	if not Phys_IsValid(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(instance, ent, "entities.applyForce")

	angvel:Sub(Phys_GetAngleVelocity(phys))
	Phys_AddAngleVelocity(phys, angvel)
end

--- Applies a angular velocity to an object
-- @param Vector angvel The local angvel vector to apply
function ents_methods:addAngleVelocity(angvel)
	local ent = getent(self)
	angvel = vunwrap1(angvel)
	checkvector(angvel)

	local phys = Ent_GetPhysicsObject(ent)
	if not Phys_IsValid(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(instance, ent, "entities.applyForce")

	Phys_AddAngleVelocity(phys, angvel)
end

--- Returns how much friction the entity has, default is 1 (100%)
-- @return number friction
function ents_methods:getFriction()
	return Ent_GetFriction(getent(self))
end

--- Sets the entity's friction multiplier
-- @param number friction
function ents_methods:setFriction(friction)
	local ent = getent(self)
	checkpermission(instance, ent, "entities.canTool")
	checknumber(friction)
	Ent_SetFriction(ent, friction)
end

--- Sets the elasticity of the entity
-- @param number elasticity
function ents_methods:setElasticity(elasticity)
	local ent = getent(self)
	checkpermission(instance, ent, "entities.canTool")
	checknumber(elasticity)
	Ent_SetElasticity(ent, elasticity)
end

--- Applies linear force to the entity
-- @param Vector vec The force vector
function ents_methods:applyForceCenter(vec)
	local ent = getent(self)
	vec = vunwrap1(vec)
	checkvector(vec)

	local phys = Ent_GetPhysicsObject(ent)
	if not Phys_IsValid(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(instance, ent, "entities.applyForce")

	Phys_ApplyForceCenter(phys, vec)
end

--- Applies linear force to the entity with an offset
-- @param Vector force The force vector in world coordinates
-- @param Vector position The force position in world coordinates
function ents_methods:applyForceOffset(force, position)
	local ent = getent(self)

	force = vunwrap1(force)
	checkvector(force)
	position = vunwrap2(position)
	checkvector(position)

	local phys = Ent_GetPhysicsObject(ent)
	if not Phys_IsValid(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(instance, ent, "entities.applyForce")

	Phys_ApplyForceOffset(phys, force, position)
end

--- Applies angular force to the entity (This function is garbage, use applyTorque instead)
-- @param Angle ang The force angle
function ents_methods:applyAngForce(ang)
	local ent = getent(self)

	ang = aunwrap1(ang)
	checkvector(ang)

	local phys = Ent_GetPhysicsObject(ent)
	if not Phys_IsValid(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(instance, ent, "entities.applyForce")

	-- assign vectors
	local up = Ent_GetUp(ent)
	local left = Ent_GetRight(ent) * -1
	local forward = Ent_GetForward(ent)

	-- apply pitch force
	if ang.p ~= 0 then
		local pitch = up * (ang.p * 0.5)
		Phys_ApplyForceOffset(phys, forward, pitch)
		Phys_ApplyForceOffset(phys, forward * -1, pitch * -1)
	end

	-- apply yaw force
	if ang.y ~= 0 then
		local yaw = forward * (ang.y * 0.5)
		Phys_ApplyForceOffset(phys, left, yaw)
		Phys_ApplyForceOffset(phys, left * -1, yaw * -1)
	end

	-- apply roll force
	if ang.r ~= 0 then
		local roll = left * (ang.r * 0.5)
		Phys_ApplyForceOffset(phys, up, roll)
		Phys_ApplyForceOffset(phys, up * -1, roll * -1)
	end
end

--- Applies torque
-- @param Vector torque The torque vector
function ents_methods:applyTorque(torque)
	local ent = getent(self)

	torque = vunwrap1(torque)
	checkvector(torque)

	local phys = Ent_GetPhysicsObject(ent)
	if not Phys_IsValid(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(instance, ent, "entities.applyForce")

	Phys_ApplyTorqueCenter(phys, torque)
end

--- Allows detecting collisions on an entity.
-- @param function func The callback function with argument, table collsiondata, http://wiki.facepunch.com/gmod/Structures/CollisionData
-- @param string? name Optional name to distinguish multiple collision listeners and remove them individually later. (default: "")
function ents_methods:addCollisionListener(func, name)
	checkluatype(func, TYPE_FUNCTION)
	if name ~= nil then checkluatype(name, TYPE_STRING) else name = "" end

	local ent = getent(self)
	checkpermission(instance, ent, "entities.canTool")

	collisionListeners:add(ent, name, func)
end

--- Removes a collision listener from the entity
-- @param string? name The name of the collision listener to remove. (default: "")
function ents_methods:removeCollisionListener(name)
	if name ~= nil then checkluatype(name, TYPE_STRING) else name = "" end

	local ent = getent(self)
	checkpermission(instance, ent, "entities.canTool")

	collisionListeners:remove(ent, name)
end

--- Sets whether an entity's shadow should be drawn
-- @param boolean draw Whether the shadow should draw
function ents_methods:setDrawShadow(draw)
	local ent = getent(self)
	checkpermission(instance, ent, "entities.setRenderProperty")
	checkluatype(draw, TYPE_BOOL)
	Ent_DrawShadow(ent, draw)
end

--- Sets the entity's position. No interpolation will occur clientside, use physobj.setPos to have interpolation.
-- @param Vector vec New position
function ents_methods:setPos(vec)
	local ent = getent(self)
	checkpermission(instance, ent, "entities.setPos")
	Ent_SetPos(ent, SF.clampPos(vunwrap1(vec)))
end

--- Sets the entity's angles
-- @param Angle ang New angles
function ents_methods:setAngles(ang)
	local ent = getent(self)
	checkpermission(instance, ent, "entities.setAngles")
	Ent_SetAngles(ent, aunwrap1(ang))
end

--- Sets the entity's position local to its parent
-- @param Vector vec New position
function ents_methods:setLocalPos(vec)
	local ent = getent(self)
	checkpermission(instance, ent, "entities.setPos")
	Ent_SetLocalPos(ent, SF.clampPos(vunwrap1(vec)))
end

--- Sets the entity's angles local to its parent
-- @param Angle ang New angles
function ents_methods:setLocalAngles(ang)
	local ent = getent(self)
	checkpermission(instance, ent, "entities.setAngles")
	Ent_SetLocalAngles(ent, aunwrap1(ang))
end

--- Sets the entity's linear velocity. Physics entities, use physobj:setVelocity
-- @param Vector vel New velocity
function ents_methods:setVelocity(vel)
	local ent = getent(self)

	vel = vunwrap1(vel)
	checkvector(vel)

	checkpermission(instance, ent, "entities.setVelocity")

	Ent_SetVelocity(ent, vel)
end

--- Applies velocity to an object
-- @param Vector vel The world velocity vector to apply
function ents_methods:addVelocity(vel)
	local ent = getent(self)
	vel = vunwrap1(vel)
	checkvector(vel)

	local phys = Ent_GetPhysicsObject(ent)
	if not Phys_IsValid(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(instance, ent, "entities.applyForce")

	Phys_AddVelocity(phys, vel)
end

--- Removes an entity
function ents_methods:remove()
	local ent = getent(self)
	if Ent_IsWorld(ent) or Ent_IsPlayer(ent) then SF.Throw("Cannot remove world or player", 2) end
	checkpermission(instance, ent, "entities.remove")
	Ent_Remove(ent)
end

--- Invokes the entity's breaking animation and removes it.
function ents_methods:breakEnt()
	local ent = getent(self)
	local ent_tbl = Ent_GetTable(ent)
	if Ent_IsPlayer(ent) or ent_tbl.WasBroken then SF.Throw("Entity is not valid", 2) end
	checkpermission(instance, ent, "entities.remove")

	ent_tbl.WasBroken = true
	Ent_Fire(ent, "break", 1, 0)
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
		local obbmins, obbmaxs = Ent_OBBMins(ent), Ent_OBBMaxs(ent)
		radius = math.Clamp(radius, 0, (obbmaxs.x - obbmins.x + obbmaxs.y - obbmins.y) / 2)
	end

	Ent_Ignite(ent, length, radius)
end

--- Extinguishes an entity
function ents_methods:extinguish()
	local ent = getent(self)
	checkpermission(instance, ent, "entities.ignite")

	Ent_Extinguish(ent)
end

--- Simulate a Use action on the entity by the chip owner
-- @param number? usetype The USE_ enum use type. (Default: USE_ON)
-- @param number? value The use value (Default: 0)
function ents_methods:use(usetype, value)
	local ent = getent(self)
	checkpermission(instance, ent, "entities.use")
	if usetype~=nil then checkluatype(usetype, TYPE_NUMBER) end
	if value~=nil then checkluatype(value, TYPE_NUMBER) end
	Ent_Use(ent, instance.player, instance.entity, usetype, value)
end

--- Sets the entity to be Solid or not.
-- @param boolean solid Should the entity be solid?
function ents_methods:setSolid(solid)
	local ent = getent(self)
	if Ent_IsPlayer(ent) then SF.Throw("Target is a player!", 2) end
	checkpermission(instance, ent, "entities.setSolid")

	Ent_SetNotSolid(ent, not solid)
end

--- Sets the entity's collision group
-- @param number group The COLLISION_GROUP value to set it to
function ents_methods:setCollisionGroup(group)
	checkluatype(group, TYPE_NUMBER)
	if group < 0 or group >= LAST_SHARED_COLLISION_GROUP then SF.Throw("Invalid collision group value", 2) end
	local ent = getent(self)
	if Ent_IsPlayer(ent) then SF.Throw("Target is a player!", 2) end
	checkpermission(instance, ent, "entities.setSolid")

	Ent_SetCollisionGroup(ent, group)
end

--- Set's the entity to collide with nothing but the world. Alias to entity:setCollisionGroup(COLLISION_GROUP_WORLD)
-- @param boolean nocollide Whether to collide with nothing except world or not.
function ents_methods:setNocollideAll(nocollide)
	local ent = getent(self)
	if Ent_IsPlayer(ent) then SF.Throw("Target is a player!", 2) end
	checkpermission(instance, ent, "entities.setSolid")

	Ent_SetCollisionGroup(ent, nocollide and COLLISION_GROUP_WORLD or COLLISION_GROUP_NONE)
end

--- Sets the entity's mass
-- @param number mass Mass to set to
function ents_methods:setMass(mass)
	local ent = getent(self)
	if Ent_IsPlayer(ent) then SF.Throw("Target is a player!", 2) end
	checkluatype(mass, TYPE_NUMBER)
	local phys = Ent_GetPhysicsObject(ent)
	if not Phys_IsValid(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(instance, ent, "entities.setMass")

	local m = math.Clamp(mass, 1, 50000)
	Phys_SetMass(phys, m)
	duplicator.StoreEntityModifier(ent, "mass", { Mass = m })
end

--- Sets the entity's inertia
-- @param Vector vec Inertia tensor
function ents_methods:setInertia(vec)
	local ent = getent(self)
	if Ent_IsPlayer(ent) then SF.Throw("Target is a player!", 2) end
	checkpermission(instance, ent, "entities.setInertia")
	local phys = Ent_GetPhysicsObject(ent)
	if not Phys_IsValid(phys) then SF.Throw("Physics object is invalid", 2) end

	vec = vunwrap1(vec)
	checkvector(vec)
	vec[1] = math.Clamp(vec[1], 1, 100000)
	vec[2] = math.Clamp(vec[2], 1, 100000)
	vec[3] = math.Clamp(vec[3], 1, 100000)

	Phys_SetInertia(phys, vec)
end

--- Sets the physical material of the entity
-- @param string materialName Material to use
function ents_methods:setPhysMaterial(mat)
	local ent = getent(self)
	if Ent_IsPlayer(ent) then SF.Throw("Target is a player!", 2) end
	checkluatype(mat, TYPE_STRING)
	local phys = Ent_GetPhysicsObject(ent)
	if not Phys_IsValid(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(instance, ent, "entities.setMass")

	construct.SetPhysProp(nil, ent, 0, phys, { Material = mat })
end

--- Get the physical material of the entity
-- @return string The physical material
function ents_methods:getPhysMaterial()
	local ent = getent(self)
	local phys = Ent_GetPhysicsObject(ent)
	if not Phys_IsValid(phys) then SF.Throw("Physics object is invalid", 2) end

	return Phys_GetMaterial(phys)
end

--- Checks whether entity has physics
-- @return boolean If entity has physics
function ents_methods:isValidPhys()
	return Phys_IsValid(Ent_GetPhysicsObject(getent(self)))
end

--- Returns true if the entity is being held by a player. Either by Physics gun, Gravity gun or Use-key.
-- @server
-- @return boolean If the entity is being held or not
function ents_methods:isPlayerHolding()
	return Ent_IsPlayerHolding(getent(self))
end

--- Returns if the entity is a constraint.
-- @server
-- @return boolean If the entity is a constraint
function ents_methods:isConstraint()
	return Ent_IsConstraint(getent(self))
end

--- Sets entity gravity
-- @param boolean grav Should the entity respect gravity?
function ents_methods:enableGravity(grav)
	local ent = getent(self)
	if Ent_IsPlayer(ent) then SF.Throw("Target is a player!", 2) end
	local phys = Ent_GetPhysicsObject(ent)
	if not Phys_IsValid(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(instance, ent, "entities.enableGravity")

	Phys_EnableGravity(phys, grav and true or false)
	Phys_Wake(phys)
end

--- Sets the entity drag state
-- @param boolean drag Should the entity have air resistance?
function ents_methods:enableDrag(drag)
	local ent = getent(self)
	if Ent_IsPlayer(ent) then SF.Throw("Target is a player!", 2) end
	local phys = Ent_GetPhysicsObject(ent)
	if not Phys_IsValid(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(instance, ent, "entities.enableDrag")

	Phys_EnableDrag(phys, drag and true or false)
end

--- Sets the contents flag of the physobject
-- @server
-- @param number contents The CONTENTS enum
function ents_methods:setContents(contents)
	local ent = getent(self)
	if Ent_IsPlayer(ent) then SF.Throw("Target is a player!", 2) end
	local phys = Ent_GetPhysicsObject(ent)
	if not Phys_IsValid(phys) then SF.Throw("Physics object is invalid", 2) end

	checkluatype(contents, TYPE_NUMBER)
	
	checkpermission(instance, ent, "entities.setContents")
	Phys_SetContents(phys, contents)
end

--- Sets the entity movement state
-- @param boolean move Should the entity move?
function ents_methods:enableMotion(move)
	local ent = getent(self)
	if Ent_IsPlayer(ent) then SF.Throw("Target is a player!", 2) end
	local phys = Ent_GetPhysicsObject(ent)
	if not Phys_IsValid(phys) then SF.Throw("Physics object is invalid", 2) end

	checkpermission(instance, ent, "entities.enableMotion")

	Phys_EnableMotion(phys, move and true or false)
	Phys_Wake(phys)
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
	local phys = Ent_GetPhysicsObject(ent)
	if not Phys_IsValid(phys) then SF.Throw("Physics object is invalid", 2) end
	return not Phys_IsMoveable(phys)
end

--- Sets the physics of an entity to be a sphere
-- @param boolean enabled Should the entity be spherical?
-- @param number? radius Optional custom radius to use (max 500). Otherwise the prop's obb is used
function ents_methods:enableSphere(enabled, radius)
	local ent = getent(self)
	if Ent_GetClass(ent) ~= "prop_physics" then SF.Throw("This function only works for prop_physics", 2) end
	local phys = Ent_GetPhysicsObject(ent)
	if not Phys_IsValid(phys) then SF.Throw("Physics object is invalid", 2) end
	checkpermission(instance, ent, "entities.enableMotion")

	local ismove = Phys_IsMoveable(phys)
	local mass = Phys_GetMass(phys)

	if enabled then
		if Ent_GetMoveType(ent) == MOVETYPE_VPHYSICS then
			if radius~=nil then
				checkluatype(radius, TYPE_NUMBER)
				radius = math.Clamp(radius, 0.2, 500)
			else
				local OBB = Ent_OBBMaxs(ent) - Ent_OBBMins(ent)
				radius = math.max(OBB.x, OBB.y, OBB.z) / 2
			end
			Ent_PhysicsInitSphere(ent, radius, phys:GetMaterial())
			Ent_SetCollisionBounds(ent, Vector(-radius, -radius, -radius) , Vector(radius, radius, radius))
	
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
		Ent_PhysicsInit(ent, SOLID_VPHYSICS)
		Ent_SetMoveType(ent, MOVETYPE_VPHYSICS)
		Ent_SetSolid(ent, SOLID_VPHYSICS)

		duplicator.ClearEntityModifier(ent, "MakeSphericalCollisions")
	end

	-- New physobject after applying spherical collisions
	phys = Ent_GetPhysicsObject(ent)
	Phys_SetMass(phys, mass)
	Phys_EnableMotion(phys, ismove)
	Phys_Wake(phys)
end

--- Gets what the entity is welded to. If the entity is parented, returns the parent.
-- @return Entity The first welded/parent entity
function ents_methods:isWeldedTo()
	local ent = getent(self)
	local constr = constraint.FindConstraint(ent, "Weld")
	if constr then
		return owrap(constr.Ent1 == ent and constr.Ent2 or constr.Ent1)
	end

	local parent = Ent_GetParent(ent)
	if Ent_IsValid(parent) then
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
		if Ent_IsValid(ent) then
			entity_table[#entity_table + 1] = owrap(ent)
			local constraints = constraint.GetTable(ent)
			for _, v in pairs(constraints) do
				if not filter or filter[v.Type] then
					if v.Ent1 then recursive_find(v.Ent1) end
					if v.Ent2 then recursive_find(v.Ent2) end
				end
			end
			if not filter or filter.Parent then
				local parent = Ent_GetParent(ent)
				if parent then recursive_find(parent) end
				for _, child in pairs(Ent_GetChildren(ent)) do
					recursive_find(child)
				end
			end
			if not filter or filter.Wire then
				local ent_tbl = Ent_GetTable(ent)
				local inputs = ent_tbl.Inputs
				if istable(inputs) then
					for _, v in pairs(inputs) do
						if isentity(v.Src) and Ent_IsValid(v.Src) then
							recursive_find(v.Src)
						end
					end
				end
				local outputs = ent_tbl.Outputs
				if istable(outputs) then
					for _, v in pairs(outputs) do
						if istable(v.Connected) then
							for _, v in pairs(v.Connected) do
								if isentity(v.Entity) and Ent_IsValid(v.Entity) then
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
	local ent_tbl = Ent_GetTable(ent)
	checkluatype(material, TYPE_STRING)
	local time = CurTime()
	if ent_tbl._lastTrailSet == time then SF.Throw("Can't modify trail more than once per frame", 2) end
	ent_tbl._lastTrailSet = time

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
	if Ent_GetClass(ent) ~= "prop_physics" then SF.Throw("setUnbreakable can only be used on prop_physics", 2) end

	if not Ent_IsValid(SF.UnbreakableFilter) then
		local FilterDamage = ents.FindByName("FilterDamage")[1]
		if not FilterDamage then
			FilterDamage = ents.Create( "filter_activator_name" )
			FilterDamage:SetKeyValue( "TargetName", "FilterDamage" )
			FilterDamage:SetKeyValue( "negated", "1" )
			FilterDamage:Spawn()
		end
		SF.UnbreakableFilter = FilterDamage
	end

	Ent_Fire(ent, "SetDamageFilter", on and "FilterDamage" or "", 0)
end

--- Check if the given Entity or Vector is within this entity's PVS (Potentially Visible Set). See: https://developer.valvesoftware.com/wiki/PVS
-- @param Entity|Vector other Entity or Vector to test
-- @return boolean If the Entity/Vector is within the PVS
function ents_methods:testPVS(other)
	local ent = getent(self)

	local meta = debug.getmetatable(other)
	if meta==vec_meta then
		other = vunwrap1(other)
	elseif meta==ent_meta or (meta and meta.supertype == ent_meta) then
		other = getent(other)
	else
		SF.ThrowTypeError("Entity or Vector", SF.GetType(other), 2)
	end

	return Ent_TestPVS(ent, other)
end

--- Returns entity's creation ID (similar to entIndex, but increments monotonically)
-- @return number The creation ID
function ents_methods:getCreationID()
	return Ent_GetCreationID(getent(self))
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

	local class = Ent_GetClass(ent)
	if not physUpdateWhitelist[class] then SF.Throw("Cannot use physics update listener on " .. class, 2) end

	if func then
		checkluatype(func, TYPE_FUNCTION)

		Ent_GetTable(ent).PhysicsUpdate = function()
			instance:runFunction(func)
		end
	else
		Ent_GetTable(ent).PhysicsUpdate = nil
	end
end

--- Returns a copy of the entity's sanitized internal glua table.
-- @return table The entity's table.
function ents_methods:getTable()
	local ent = getent(self)
	checkpermission(instance, ent, "entities.getTable")
	return instance.Sanitize(Ent_GetTable(ent))
end

--- Returns a variable from the entity's internal glua table.
-- @param string key The variable's key.
-- @return any The variable.
function ents_methods:getVar(key)
	local ent = getent(self)
	checkpermission(instance, ent, "entities.getTable")
	local var = Ent_GetVar(ent, key)
	return istable(var) and instance.Sanitize(var) or owrap(var)
end

--- Sets the entity to be used as the light origin position for this entity.
-- @param Entity? lightOrigin The lighting entity or nil to reset.
function ents_methods:setLightingOriginEntity(lightOrigin)
	local ent = getent(self)
	checkpermission(instance, ent, "entities.setRenderProperty")
	if lightOrigin then lightOrigin = getent(lightOrigin) end
	Ent_SetLightingOriginEntity(ent, lightOrigin)
end

end
