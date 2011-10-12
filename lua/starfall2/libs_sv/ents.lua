
SF.Entities = {}

local ents_lib = {}
local ents_metatable = SF.Typedef("Entity")
SF.Libraries.Register("ents",ents_lib)

SF.Permissions:registerPermission({
	name = "Modify All Entities",
	desc = "Allow modification of entities not created by the owner",
	level = 1,
	value = false,
})

-- ------------------------- Internal Library ------------------------- --

local wrap, unwrap = SF.CreateWrapper(ents_metatable)

--- Wraps a real entity to an entity wrapper
-- @name SF.Entities.Wrap
-- @class function
-- @param ent
SF.Entities.Wrap = wrap
--- Unwraps an entity wrapper to a real entity
-- @name SF.Entities.Unwrap
-- @class function
-- @param wrapped
SF.Entities.Unwrap = unwrap
--- The entity wrapper metatable
-- @name SF.Entities.Metatable
-- @class table
SF.Entities.Metatable = ents_metatable

--- Returns true if valid, false if not
function SF.Entities.IsValid(entity)
	if entity == nil then return false end
	if not entity:IsValid() then return false end
	if entity:IsWorld() then return false end
	return true
end

--- Gets the entity's owner
-- TODO: Optimize this!
-- @return The entities owner, or nil if not found
function SF.Entities.GetOwner(entity)
	local valid = SF.Entities.IsValid
	if not valid(entity) then return end
	
	if entity.IsPlayer and entity:IsPlayer() then
		return entity
	end
	
	if CPPI then
		local owner = entity:CPPIGetOwner()
		if valid(owner) then return owner end
	end
	
	if entity.GetPlayer then
		local ply = entity:GetPlayer()
		if valid(ply) then return ply end
	end
	
	local OnDieFunctions = entity.OnDieFunctions
	if OnDieFunctions then
		if OnDieFunctions.GetCountUpdate and OnDieFunctions.GetCountUpdate.Args and OnDieFunctions.GetCountUpdate.Args[1] then
			return OnDieFunctions.GetCountUpdate.Args[1]
		elseif OnDieFunctions.undo1 and OnDieFunctions.undo1.Args and OnDieFunctions.undo1.Args[2] then
			return OnDieFunctions.undo1.Args[2]
		end
	end
	
	if entity.GetOwner then
		local ply = entity:GetOwner()
		if valid(ply) then return ply end
	end

	return nil
end

--- Gets the physics object of the entity
-- @return The physobj, or nil if the entity isn't valid or isn't vphysics
function SF.Entities.GetPhysObject(entity)
	if not ents.IsValid(entity) then return nil end
	if entity:GetMoveType() ~= MOVETYPE_VPHYSICS then return nil end
	return entity:GetPhysicsObject()
end

--- Checks to see if a player can modify an entity without the override permission
-- @param ply The player
-- @param ent The entity being modified
function SF.Entities.CanModify(ply, ent)
	if CPPI and ent:CPPICanPhysgun(ply) then return true end
	return SF.Entitites.GetOwner(ent) == ply
end

local isValid = SF.Entities.IsValid
local getPhysObject = SF.Entities.GetPhysObject
local getOwner = SF.Entities.GetOwner
local canModify = SF.Entities.CanModify

-- Add wire inputs/outputs
local function postload()
	if SF.Wire then
		SF.Wire.AddInputType("ENTITY",function(data)
			if data == nil then return nil end
			return wrap(data)
		end)

		SF.Wire.AddOutputType("ENTITY", function(data)
			if data == nil then return nil end
			SF.CheckType(data,ents_metatable)
			
			return unwrap(data)
		end)
	end
end
SF.Libraries.AddHook("postload",postload)

-- ------------------------- Library functions ------------------------- --

--- Returns the entity representing a processor that this script is running on.
-- May be nil
function ents_lib.self()
	local ent = SF.instance.data.entity
	if ent then 
		return wrap(ent)
	else return nil end
end

--- Returns whoever created the script
function ents_lib.owner()
	return wrap(SF.instance.player)
end

--- Same as ents_lib.owner() on the server.
function ents_lib.player()
	return wrap(SF.instance.player)
end

-- ------------------------- Methods ------------------------- --

function ents_metatable:__tostring()
	local ent = unwrap(self)
	if not ent then return "Invalid Entity"
	else return tostring(ent) end
end

--- Checks if an entity is valid.
-- @return True if valid, false if not
function ents_metatable:isValid()
	SF.CheckType(self,ents_metatable)
	local ent = unwrap(self)
	return isValid(ent)
end

--- Gets the owner of the entity
function ents_metatable:owner()
	SF.CheckType(self,ents_metatable)
	local ent = unwrap(self)
	return wrap(getOwner(self))
end

--- Returns the EntIndex of the entity
-- @return The numerical index of the entity
function ents_metatable:index()
	SF.CheckType(self,ents_metatable)
	local ent = unwrap(self)
	if not isValid(ent) then return nil end
	return ent:EntIndex()
end

--- Returns the class of the entity
-- @return The string class name
function ents_metatable:class()
	SF.CheckType(self,ents_metatable)
	local ent = unwrap(self)
	if not isValid(ent) then return nil end
	return ent:GetClass()
end

--- Returns the position of the entity
-- @return The position vector
function ents_metatable:pos()
	SF.CheckType(self,ents_metatable)
	local ent = unwrap(self)
	if not isValid(ent) then return nil end
	return ent:GetPos()
end

--- Returns the angle of the entity
-- @return The angle
function ents_metatable:ang()
	SF.CheckType(self,ents_metatable)
	local ent = unwrap(self)
	if not isValid(ent) then return nil end
	return ent:GetAngles()
end

--- Returns the mass of the entity
-- @return The numerical mass
function ents_metatable:mass()
	SF.CheckType(self,ents_metatable)
	
	local ent = unwrap(self)
	if not isValid(ent) then return false, "entity not valid" end
	if not canModify(ent) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "access denied" end
	local phys = getPhysObject(ent)
	if not phys then return false, "entity has no physics object" end
	
	return phys:GetMass()
end

--- Returns the velocity of the entity
-- @return The velocity vector
function ents_metatable:vel()
	SF.CheckType(self,ents_metatable)
	local ent = unwrap(self)
	if not isValid(ent) then return nil end
	return ent:GetVelocity()
end

--- Converts a vector in entity local space to world space
-- @param data Local space vector
function ents_metatable:toWorld(data)
	SF.CheckType(self,ents_metatable)
	local ent = unwrap(self)
	if not isValid(ent) then return nil end
	
	if type(data) == "Vector" then
		return ent:LocalToWorld(data)
	elseif type(data) == "Angle" then
		return ent:LocalToWorldAngles(data)
	else
		SF.CheckType(data, "angle or vector") -- force error
	end
end

--- Converts a vector in world space to entity local space
-- @param data Local space vector
function ents_metatable:toLocal(data)
	SF.CheckType(self,ents_metatable)
	local ent = unwrap(self)
	if not isValid(ent) then return nil end
	
	if type(data) == "Vector" then
		return ent:WorldToLocal(data)
	elseif type(data) == "Angle" then
		return ent:WorldToLocalAngles(data)
	else
		SF.CheckType(data, "angle or vector") -- force error
	end
end


--- Applies linear force to the entity
-- @param vec The force vector
-- @param offset An optional offset position (TODO: Local or world?)
function ents_metatable:applyForce(vec, offset)
	SF.CheckType(self,ents_metatable)
	SF.CheckType(vec,"Vector")
	if offset then SF.CheckType(offset,"Vector") end
	
	local ent = unwrap(self)
	if not isValid(ent) then return false, "entity not valid" end
	if not canModify(ent) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "access denied" end
	local phys = getPhysObject(ent)
	if not phys then return false, "entity has no physics object" end
	
	if offset == nil then
		phys:ApplyForceCenter(vec)
	else
		phys:ApplyForceOffset(vec,offset)
	end
	return true
end

--- Applies angular force to the entity
-- @param ang The force angle
-- @depreciated Gmod has no phys:ApplyAngleForce function, so this uses black magic
function ents_metatable:applyAngForce(ang)
	SF.CheckType(self,ents_metatable)
	SF.CheckType(ang,"Angle")
	
	local ent = unwrap(self)
	if not isValid(ent) then return false, "entity not valid" end
	if not canModify(ent) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "access denied" end
	local phys = getPhysObject(ent)
	if not phys then return false, "entity has no physics object" end
	
	-- assign vectors
	local up = ent:GetUp()
	local left = ent:GetRight() * -1
	local forward = ent:GetForward()
	
	-- apply pitch force
	if ang.p ~= 0 then
		local pitch = up      * (ang.p * 0.5)
		phys:ApplyForceOffset( forward, pitch )
		phys:ApplyForceOffset( forward * -1, pitch * -1 )
	end
	
	-- apply yaw force
	if ang.y ~= 0 then
		local yaw   = forward * (ang.y * 0.5)
		phys:ApplyForceOffset( left, yaw )
		phys:ApplyForceOffset( left * -1, yaw * -1 )
	end
	
	-- apply roll force
	if ang.r ~= 0 then
		local roll  = left    * (ang.r * 0.5)
		phys:ApplyForceOffset( up, roll )
		phys:ApplyForceOffset( up * -1, roll * -1 )
	end
	
	return true
end

--- Applies torque
-- @param tq The torque vector
function ents_metatable:applyTorque(tq)
	SF.CheckType(self,ents_metatable)
	SF.CheckType(tq,"Vector")
	
	local ent = unwrap(self)
	if not isValid(ent) then return false, "entity not valid" end
	if not canModify(ent) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "access denied" end
	local phys = getPhysObject(ent)
	if not phys then return false, "entity has no physics object" end
	
	local torqueamount = tq:Length()
	
	-- Convert torque from local to world axis
	tq = phys:LocalToWorld( tq ) - phys:GetPos()
	
	-- Find two vectors perpendicular to the torque axis
	local off
	if abs(tq.x) > torqueamount * 0.1 or abs(tq.z) > torqueamount * 0.1 then
		off = Vector(-tq.z, 0, tq.x)
	else
		off = Vector(-tq.y, tq.x, 0)
	end
	off = off:GetNormal() * torqueamount * 0.5
	
	local dir = ( tq:Cross(off) ):GetNormal()
	
	phys:ApplyForceOffset( dir, off )
	phys:ApplyForceOffset( dir * -1, off * -1 )
	
	return true
end

--- Sets the entitiy's position
-- @param vec New position
function ents_metatable:setPos(vec)
	SF.CheckType(ent,ents_metatable)
	SF.CheckType(pos,"Vector")
	
	local ent = unwrap(self)
	if not isValid(ent) then return false, "entity not valid" end
	if not canModify(ent) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "access denied" end
	local phys = getPhysObject(ent)
	if not phys then return false, "entity has no physics object" end
	
	if not util.IsInWorld(pos) then return false, "position not in world" end
	
	phys:SetPos(pos)
	phys:Wake()
	return true
end

--- Sets the entity's angles
-- @param ang New angles
function ents_metatable:setAng(ang)
	SF.CheckType(self,ents_metatable)
	SF.CheckType(ang,"Angle")
	
	local ent = unwrap(self)
	if not isValid(ent) then return false, "entity not valid" end
	if not canModify(ent) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "access denied" end
	local phys = getPhysObject(ent)
	if not phys then return false, "entity has no physics object" end
	
	phys:SetAngle(ang)
	phys:Wake()
	return true
end

--- Sets the entity's linear velocity
-- @param vel New velocity
function ents_metatable:setVel(vel)
	SF.CheckType(self,ents_metatable)
	SF.CheckType(ang,"Vector")
	
	local ent = unwrap(self)
	if not isValid(ent) then return false, "entity not valid" end
	if not canModify(ent) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "access denied" end
	local phys = getPhysObject(ent)
	if not phys then return false, "entity has no physics object" end
	
	ent:SetVelocity(vel)
	return true
end

function ents_metatable:setFrozen(ent, freeze)
	SF.CheckType(self,ents_metatable)
	
	local ent = unwrap(self)
	if not isValid(ent) then return false, "entity not valid" end
	if not canModify(ent) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "access denied" end
	local phys = getPhysObject(ent)
	if not phys then return false, "entity has no physics object" end
	
	phys:EnableMotion(not (freeze and true or false))
	phys:Wake()
	return true
end

function ents_metatable:setNotSolid(notsolid)
	SF.CheckType(self,ents_metatable)
	
	local ent = unwrap(self)
	if not isValid(ent) then return false, "entity not valid" end
	if not canModify(ent) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "access denied" end
	
	ent:SetNotSolid(notsolid and true or false)
	return true
end

function ents_metatable:enableGravity(grav)
	SF.CheckType(self,ents_metatable)
	
	local ent = unwrap(self)
	if not isValid(ent) then return false, "entity not valid" end
	if not canModify(ent) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "access denied" end
	local phys = getPhysObject(ent)
	if not phys then return false, "entity has no physics object" end
	
	phys:EnableGravity(grav and true or false)
	phys:Wake()
	return true
end
