--- Shared stuff between clientside entities and server-side entities

SF.Entities = {}

local ents_lib = {}
local ents_metatable = SF.Typedef("Entity")
local wrap, unwrap = SF.CreateWrapper(ents_metatable,true,true)

-- ------------------------- Internal functions ------------------------- --

SF.Entities.Wrap = wrap
SF.Entities.Unwrap = unwrap
SF.Entities.Metatable = ents_metatable
SF.Entities.Library = ents_lib

--- Returns true if valid and is not the world, false if not
-- @param entity Entity to check
function SF.Entities.IsValid(entity)
	return entity and entity:IsValid() and not entity:IsWorld()
--	if entity == nil then return false end
--	if not entity:IsValid() then return false end
--	if entity:IsWorld() then return false end
--	return true
end
local isValid = SF.Entities.IsValid

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

-- ------------------------- Methods ------------------------- --

function ents_metatable:__tostring()
	local ent = unwrap(self)
	if not ent then return "(null entity)"
	else return tostring(ent) end
end

--- Checks if an entity is valid.
-- @return True if valid, false if not
function ents_metatable:isValid()
	SF.CheckType(self,ents_metatable)
	local ent = unwrap(self)
	return isValid(ent)
end

--- Returns the EntIndex of the entity
-- @return The numerical index of the entity
function ents_metatable:index()
	SF.CheckType(self,ents_metatable)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
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
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetPos()
end

--- Returns the angle of the entity
-- @return The angle
function ents_metatable:ang()
	SF.CheckType(self,ents_metatable)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetAngles()
end

--- Returns the mass of the entity
-- @return The numerical mass
function ents_metatable:mass()
	SF.CheckType(self,ents_metatable)
	
	local ent = unwrap(self)
	local phys = getPhysObject(ent)
	if not phys then return false, "entity has no physics object or is not valid" end
	
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
