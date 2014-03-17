-------------------------------------------------------------------------------
-- Shared entity library functions
-------------------------------------------------------------------------------

SF.Entities = {}

--- Entity type
-- @shared
local ents_methods, ents_metamethods = SF.Typedef("Entity")
local wrap, unwrap = SF.CreateWrapper(ents_metamethods,true,true,debug.getregistry().Entity)

--- Entities Library
-- @shared
local ents_lib, _ = SF.Libraries.Register("entities")

-- ------------------------- Internal functions ------------------------- --

SF.Entities.Wrap = wrap
SF.Entities.Unwrap = unwrap
SF.Entities.Methods = ents_methods
SF.Entities.Metatable = ents_metamethods
SF.Entities.Library = ents_lib

--- Returns true if valid and is not the world, false if not
-- @param entity Entity to check
function SF.Entities.IsValid(entity)
	return entity and entity:IsValid() and not entity:IsWorld()
end
local isValid = SF.Entities.IsValid

--- Gets the physics object of the entity
-- @return The physobj, or nil if the entity isn't valid or isn't vphysics
function SF.Entities.GetPhysObject(ent)
	return (isValid(ent) and ent:GetMoveType() == MOVETYPE_VPHYSICS and ent:GetPhysicsObject()) or nil
end
local getPhysObject = SF.Entities.GetPhysObject

-- ------------------------- Library functions ------------------------- --

--- Returns the entity representing a processor that this script is running on.
-- May be nil
-- @return Starfall entity
function ents_lib.self()
	local ent = SF.instance.data.entity
	if ent then 
		return SF.Entities.Wrap(ent)
	else return nil end
end

--- Returns whoever created the script
-- @return Owner entity
function ents_lib.owner()
	return SF.WrapObject(SF.instance.player)
end

--- Same as ents_lib.owner() on the server. On the client, returns the local player
-- @name ents_lib.player
-- @class function
-- @return Either the owner (server) or the local player (client)
if SERVER then
	ents_lib.player = ents_lib.owner
else
	function ents_lib.player()
		return SF.WrapObject(LocalPlayer())
	end
end

--- Returns the entity with index 'num'
-- @name ents_lib.entity
-- @class function
-- @param num Entity index
-- @return entity
function ents_lib.entity( num )
	SF.CheckType( num, "number" )
	
	return SF.WrapObject(Entity(num))
end

-- ------------------------- Methods ------------------------- --

--- To string
-- @shared
function ents_metamethods:__tostring()
	local ent = unwrap(self)
	if not ent then return "(null entity)"
	else return tostring(ent) end
end

--- Sets the color of the entity
-- @shared
-- @param clr New color
function ents_methods:setColor( clr )
	SF.CheckType( clr, SF.Types["Color"] )

	local this = unwrap(self)
	this:SetColor(clr)
end

--- Gets the color of an entity
-- @shared
-- @return Color
function ents_methods:getColor()
	local this = unwrap(self)
	return this:GetColor()
end

--- Checks if an entity is valid.
-- @shared
-- @return True if valid, false if not
function ents_methods:isValid()
	SF.CheckType(self,ents_metamethods)
	return isValid(unwrap(self))
end

--- Returns the EntIndex of the entity
-- @shared
-- @return The numerical index of the entity
function ents_methods:entIndex()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:EntIndex()
end

--- Returns the class of the entity
-- @shared
-- @return The string class name
function ents_methods:getClass()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetClass()
end

--- Returns the position of the entity
-- @shared
-- @return The position vector
function ents_methods:getPos()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetPos()
end

--- Returns the x, y, z size of the entity's outer bounding box (local to the entity)
-- @shared
-- @return The outer bounding box size
function ents_methods:obbSize()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:OBBMaxs() - ent:OBBMins()
end

--- Returns the local position of the entity's outer bounding box
-- @shared
-- @return The position vector of the outer bounding box center
function ents_methods:obbCenter()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:OBBCenter()
end

--- Returns the world position of the entity's outer bounding box
-- @shared
-- @return The position vector of the outer bounding box center
function ents_methods:obbCenterW()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:LocalToWorld(ent:OBBCenter())
end

--- Returns the local position of the entity's mass center
-- @shared
-- @return The position vector of the mass center
function ents_methods:massCenter()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	local phys = getPhysObject(ent)
	if not phys or not phys:IsValid() then return nil, "entity has no physics object or is not valid" end
	return phys:GetMassCenter()
end

--- Returns the world position of the entity's mass center
-- @shared
-- @return The position vector of the mass center
function ents_methods:massCenterW()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	local phys = getPhysObject(ent)
	if not phys or not phys:IsValid() then return nil, "entity has no physics object or is not valid" end
	return ent:LocalToWorld(phys:GetMassCenter())
end

--- Returns the angle of the entity
-- @shared
-- @return The angle
function ents_methods:getAngles()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetAngles()
end

--- Returns the mass of the entity
-- @shared
-- @return The numerical mass
function ents_methods:getMass()
	SF.CheckType(self,ents_metamethods)
	
	local ent = unwrap(self)
	local phys = getPhysObject(ent)
	if not phys or not phys:IsValid() then return nil, "entity has no physics object or is not valid" end
	
	return phys:GetMass()
end

--- Returns the principle moments of inertia of the entity
-- @shared
-- @return The principle moments of inertia as a vector
function ents_methods:getInertia()
	SF.CheckType(self,ents_metamethods)
	
	local ent = unwrap(self)
	local phys = getPhysObject(ent)
	if not phys or not phys:IsValid() then return nil, "entity has no physics object or is not valid" end
	
	return phys:GetInertia()
end

--- Returns the velocity of the entity
-- @shared
-- @return The velocity vector
function ents_methods:getVelocity()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetVelocity()
end

--- Returns the angular velocity of the entity
-- @shared
-- @return The angular velocity vector
function ents_methods:getAngleVelocity()
	SF.CheckType(self,ents_metamethods)
	local phys = getPhysObject(unwrap(self)) 	
	if not phys or not phys:IsValid() then return nil, "entity has no physics object or is not valid" end	
	return phys:GetAngleVelocity()
end

--- Converts a vector in entity local space to world space
-- @shared
-- @param data Local space vector
-- @return data as world space vector
function ents_methods:localToWorld(data)
	SF.CheckType(self,ents_metamethods)
	SF.CheckType(data, "Vector")
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	
	return ent:LocalToWorld( data )
end

--- Converts an angle in entity local space to world space
-- @shared
-- @param data Local space angle
-- @return data as world space angle
function ents_methods:localToWorldAngles(data)
	SF.CheckType(self,ents_metamethods)
	SF.CheckType(data, "Angle")
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	
	return ent:LocalToWorldAngles( data )
end

--- Converts a vector in world space to entity local space
-- @shared
-- @param data World space vector
-- @return data as local space vector
function ents_methods:worldToLocal(data)
	SF.CheckType(self,ents_metamethods)
	SF.CheckType(data, "Vector")
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	
	return ent:WorldToLocal(data)
end

--- Converts an angle in world space to entity local space
-- @shared
-- @param data World space angle
-- @return data as local space angle
function ents_methods:worldToLocalAngles(data)
	SF.CheckType(self,ents_metamethods)
	SF.CheckType(data, "Angle")
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	
	return ent:WorldToLocalAngles(data)
end

--- Gets the model of an entity
-- @shared
-- @return Model of the entity
function ents_methods:getModel()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:GetModel()
end

--- Gets the entitiy's eye angles
-- @shared
-- @return Angles of the entity's eyes
function ents_methods:eyeAngles()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:EyeAngles()
end

--- Gets the entity's eye position
-- @shared
-- @return Eye position of the entity
-- @return In case of a ragdoll, the position of the other eye
function ents_methods:eyePos()
	SF.CheckType(self,ents_metamethods)
	local ent = unwrap(self)
	if not isValid(ent) then return nil, "invalid entity" end
	return ent:EyePos()
end

--- Gets an entities' material
-- @shared
-- @class function
-- @return Material
function ents_methods:getMaterial ()
    local ent = unwrap( self )
    if not isValid( ent ) then return nil, "invalid entity" end
    return ent:GetMaterial() or ""
end

--- Sets an entities' material
-- @shared
-- @class function
-- @param material, string, New material name.
-- @return The Entity being modified.
function ents_methods:setMaterial ( material )
    SF.CheckType( material, "string" )

    local ent = unwrap( self )
    if not isValid( ent ) then return nil, "invalid entity" end
    ent:SetMaterial( material )
    return wrap( ent )
end

--- Sets an entities' bodygroup
-- @shared
-- @class function
-- @param bodygroup Number, The ID of the bodygroup you're setting.
-- @param value Number, The value you're setting the bodygroup to.
-- @return The Entity being modified.
function ents_methods:setBodygroup ( bodygroup, value )
    SF.CheckType( bodygroup, "number" )
    SF.CheckType( value, "number" )

    local ent = unwrap( self )
    if not isValid( ent ) then return nil, "invalid entity" end

    ent:SetBodyGroup( bodygroup, value )

    return wrap( ent )
end

--- Sets the skin of the entity
-- @shared
-- @class function
-- @param skinIndex Number, Index of the skin to use.
-- @return The Entity being modified.
function ents_methods:setSkin ( skinIndex )
    SF.CheckType( skinIndex, "number" )

    local ent = unwrap( self )
    if not isValid( ent ) then return nil, "invalid entity" end

    ent:SetSkin( skinIndex )
    return wrap( ent )
end