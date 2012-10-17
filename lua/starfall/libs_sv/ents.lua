-------------------------------------------------------------------------------
-- Serverside Entity functions
-------------------------------------------------------------------------------

assert(SF.Entities)

local huge = math.huge
local abs = math.abs
local ents_lib = SF.Entities.Library
local ents_metatable = SF.Entities.Metatable
local ents_methods = SF.Entities.Methods
local wrap, unwrap = SF.Entities.Wrap, SF.Entities.Unwrap

local function fix_nan(v)
	if v < huge and v > -huge then return v else return 0 end
end

SF.Permissions:registerPermission({
	name = "Modify All Entities",
	desc = "Allow modification of entities not created by the owner",
	level = 1,
	value = false,
})

-- ------------------------- Internal Library ------------------------- --

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
	
	if entity.owner and valid(entity.owner) and entity.owner:IsPlayer() then
		return entity.owner
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

--- Checks to see if a player can modify an entity without the override permission
-- @param ply The player
-- @param ent The entity being modified
function SF.Entities.CanModify(ply, ent)
	return (CPPI and ent:CPPICanPhysgun(ply)) or SF.Entities.GetOwner(ent) == ply
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

--- Gets the owner of the entity
function ents_methods:owner()
	SF.CheckType(self,ents_metatable)
	local ent = unwrap(self)
	return wrap(getOwner(self))
end

--- Applies linear force to the entity
-- @param vec The force vector
-- @param offset An optional offset position (TODO: Local or world?)
function ents_methods:applyForce(vec, offset)
	SF.CheckType(self,ents_metatable)
	SF.CheckType(vec,"Vector")
	if offset then SF.CheckType(offset,"Vector") end
	
	local ent = unwrap(self)
	if not isValid(ent) then return false, "entity not valid" end
	if not canModify(SF.instance.player, ent) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "access denied" end
	local phys = getPhysObject(ent)
	if not phys then return false, "entity has no physics object" end
	
	-- TODO: This prevents server crashing when using insane amounts of force.
	-- GM13 doesn't seem to suffer from this issue.
	vec.x = fix_nan(vec.x)
	vec.y = fix_nan(vec.y)
	vec.z = fix_nan(vec.z)
	
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
function ents_methods:applyAngForce(ang)
	SF.CheckType(self,ents_metatable)
	SF.CheckType(ang,"Angle")
	
	local ent = unwrap(self)
	if not isValid(ent) then return false, "entity not valid" end
	if not canModify(SF.instance.player, ent) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "access denied" end
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
function ents_methods:applyTorque(tq)
	SF.CheckType(self,ents_metatable)
	SF.CheckType(tq,"Vector")
	
	local ent = unwrap(self)
	if not isValid(ent) then return false, "entity not valid" end
	if not canModify(SF.instance.player, ent) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "access denied" end
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
function ents_methods:setPos(vec)
	SF.CheckType(self,ents_metatable)
	SF.CheckType(vec,"Vector")
	
	local ent = unwrap(self)
	if not isValid(ent) then return false, "entity not valid" end
	if not canModify(SF.instance.player, ent) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "access denied" end
	local phys = getPhysObject(ent)
	if not phys then return false, "entity has no physics object" end
	
	-- TODO: Clamp insane positions to prevent crashing.
	
	phys:SetPos(vec)
	phys:Wake()
	return true
end

--- Sets the entity's angles
-- @param ang New angles
function ents_methods:setAng(ang)
	SF.CheckType(self,ents_metatable)
	SF.CheckType(ang,"Angle")
	
	local ent = unwrap(self)
	if not isValid(ent) then return false, "entity not valid" end
	if not canModify(SF.instance.player, ent) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "access denied" end
	local phys = getPhysObject(ent)
	if not phys then return false, "entity has no physics object" end
	
	phys:SetAngle(ang)
	phys:Wake()
	return true
end

--- Sets the entity's linear velocity
-- @param vel New velocity
function ents_methods:setVel(vel)
	SF.CheckType(self,ents_metatable)
	SF.CheckType(vel,"Vector")
	
	local ent = unwrap(self)
	if not isValid(ent) then return false, "entity not valid" end
	if not canModify(SF.instance.player, ent) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "access denied" end
	local phys = getPhysObject(ent)
	if not phys then return false, "entity has no physics object" end
	
	phys:SetVelocity(vel)
	return true
end

--- Sets the entity frozen state
-- @param freeze Should the entity be frozen?
function ents_methods:setFrozen(freeze)
	SF.CheckType(self,ents_metatable)
	
	local ent = unwrap(self)
	if not isValid(ent) then return false, "entity not valid" end
	if not canModify(SF.instance.player, ent) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "access denied" end
	local phys = getPhysObject(ent)
	if not phys then return false, "entity has no physics object" end
	
	phys:EnableMotion(not (freeze and true or false))
	phys:Wake()
	return true
end

--- Sets the entity solid state
-- @param notsolid Should the entity be not solid?
function ents_methods:setNotSolid(notsolid)
	SF.CheckType(self,ents_metatable)
	
	local ent = unwrap(self)
	if not isValid(ent) then return false, "entity not valid" end
	if not canModify(SF.instance.player, ent) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "access denied" end
	
	ent:SetNotSolid(notsolid and true or false)
	return true
end

--- Sets entity gravity
-- @param grav Should the entity respect gravity?
function ents_methods:enableGravity(grav)
	SF.CheckType(self,ents_metatable)
	
	local ent = unwrap(self)
	if not isValid(ent) then return false, "entity not valid" end
	if not canModify(SF.instance.player, ent) or SF.instance.permissions:checkPermission("Modify All Entities") then return false, "access denied" end
	local phys = getPhysObject(ent)
	if not phys then return false, "entity has no physics object" end
	
	phys:EnableGravity(grav and true or false)
	phys:Wake()
	return true
end
