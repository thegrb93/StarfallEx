-------------------------------------------------------------------------------
-- Shared entity library functions
-------------------------------------------------------------------------------

SF.Entities = {}

--- Entity type
-- @shared
local ents_methods, ents_metamethods = SF.Typedef( "Entity" )
local wrap, unwrap = SF.CreateWrapper( ents_metamethods, true, true, debug.getregistry().Entity )

local vwrap, vunwrap = SF.WrapObject, SF.UnwrapObject

-- ------------------------- Internal functions ------------------------- --

SF.Entities.Wrap = wrap
SF.Entities.Unwrap = unwrap
SF.Entities.Methods = ents_methods
SF.Entities.Metatable = ents_metamethods

--- Returns true if valid and is not the world, false if not
-- @param entity Entity to check
function SF.Entities.IsValid ( entity )
	return entity and entity:IsValid()
end
local isValid = SF.Entities.IsValid

--- Gets the physics object of the entity
-- @return The physobj, or nil if the entity isn't valid or isn't vphysics
function SF.Entities.GetPhysObject ( ent )
	return ( isValid( ent ) and ent:GetMoveType() == MOVETYPE_VPHYSICS and ent:GetPhysicsObject() ) or nil
end
local getPhysObject = SF.Entities.GetPhysObject

-- ------------------------- Library functions ------------------------- --

function SF.DefaultEnvironment.chip ()
	local ent = SF.instance.data.entity
	if ent then 
		return SF.Entities.Wrap( ent )
	end
end

function SF.DefaultEnvironment.owner ()
	return SF.WrapObject( SF.instance.player )
end

if SERVER then
	SF.DefaultEnvironment.player = SF.DefaultEnvironment.owner
else
	function SF.DefaultEnvironment.player ()
		return SF.WrapObject( LocalPlayer() )
	end
	
	local renderProperties = {
		[1] = function( ent ) --Color	
			ent:SetColor( Color( net.ReadUInt( 8 ), net.ReadUInt( 8 ), net.ReadUInt( 8 ), net.ReadUInt( 8 ) ) )
		end,
		[2] = function( ent ) --Nodraw
			ent:SetNoDraw( net.ReadBit() == 1 )
		end,
		[3] = function( ent ) --Material
			ent:SetMaterial( net.ReadString() )
		end,
		[4] = function( ent ) --Submaterial
			ent:SetSubMaterial( net.ReadUInt( 16 ), net.ReadString() )
		end,
		[5] = function( ent ) --Bodygroup
			ent:SetBodyGroup( net.ReadUInt( 16 ), net.ReadUInt ( 16 ) )
		end,
		[6] = function( ent ) --Skin
			ent:SetSkin( net.ReadUInt( 16 ) )
		end
	}
	
	--Net function that allows the server to set the render properties of entities for specific players
	net.Receive( "sf_setentityrenderproperty", function()
		local ent = net.ReadEntity()
		if not ent:IsValid() then return end
		local property = net.ReadUInt( 4 )
		if not renderProperties[ property ] then return end
		
		renderProperties[ property ]( ent )
	end)
end

function SF.DefaultEnvironment.entity ( num )
	SF.CheckType( num, "number" )
	
	return SF.WrapObject( Entity( num ) )
end

-- ------------------------- Methods ------------------------- --

--- To string
-- @shared
function ents_metamethods:__tostring ()
	local ent = unwrap( self )
	if not ent then return "(null entity)"
	else return tostring( ent ) end
end

--- Gets the parent of an entity
-- @shared
-- @return Entity's parent or nil
function ents_methods:getParent()
	local ent = unwrap(self)
	return ent and wrap(ent:GetParent())
end

--- Gets the attachment index the entity is parented to
-- @shared
-- @return number index of the attachment the entity is parented to or 0
function ents_methods:getAttachmentParent()
	local ent = unwrap(self)
	return ent and ent:GetParentAttachment() or 0
end

--- Gets the attachment index via the entity and it's attachment name
-- @shared
-- @param name
-- @return number of the attachment index, or 0 if it doesn't exist
function ents_methods:lookupAttachment(name)
	local ent = unwrap(self)
	return ent and ent:LookupAttachment(name) or 0
end

--- Gets the position and angle of an attachment
-- @shared
-- @param index The index of the attachment
-- @return vector position, and angle orientation
function ents_methods:getAttachment(index)
	local ent = unwrap(self)
	if ent then
		local t = ent:GetAttachment(index)
		if t then
			return vwrap(t.Pos), vwrap(t.Ang)
		end
	end
end

--- Gets the color of an entity
-- @shared
-- @return Color
function ents_methods:getColor ()
	local this = unwrap( self )
	return SF.Color.Wrap( this:GetColor() )
end

--- Checks if an entity is valid.
-- @shared
-- @return True if valid, false if not
function ents_methods:isValid ()
	SF.CheckType( self, ents_metamethods )
	return isValid( unwrap( self ) )
end

--- Checks if an entity is a player.
-- @shared
-- @return True if player, false if not
function ents_methods:isPlayer ()
	SF.CheckType( self, ents_metamethods )
	return unwrap( self ):IsPlayer()
end

--- Checks if an entity is a weapon.
-- @shared
-- @return True if weapon, false if not
function ents_methods:isWeapon ()
	SF.CheckType( self, ents_metamethods )
	return unwrap( self ):IsWeapon()
end

--- Checks if an entity is a vehicle.
-- @shared
-- @return True if vehicle, false if not
function ents_methods:isVehicle ()
	SF.CheckType( self, ents_metamethods )
	return unwrap( self ):IsVehicle()
end

--- Checks if an entity is an npc.
-- @shared
-- @return True if npc, false if not
function ents_methods:isNPC ()
	SF.CheckType( self, ents_metamethods )
	return unwrap( self ):IsNPC()
end

--- Returns the EntIndex of the entity
-- @shared
-- @return The numerical index of the entity
function ents_methods:entIndex ()
	SF.CheckType( self, ents_metamethods )
	local ent = unwrap( self )
	return ent:EntIndex()
end

--- Returns the class of the entity
-- @shared
-- @return The string class name
function ents_methods:getClass ()
	SF.CheckType( self, ents_metamethods )
	local ent = unwrap( self )
	return ent:GetClass()
end

--- Returns the position of the entity
-- @shared
-- @return The position vector
function ents_methods:getPos ()
	SF.CheckType( self, ents_metamethods )
	local ent = unwrap( self )
	return SF.WrapObject( ent:GetPos() )
end

--- Returns the matrix of the entity
-- @shared
-- @param bone Bone of the entity (def 0)
-- @return The matrix
function ents_methods:getMatrix (bone)
	SF.CheckType( self, ents_metamethods )
	bone = SF.CheckType( bone, "number", 0, 0 )
	
	local ent = unwrap( self )
	return vwrap( ent:GetBoneMatrix(bone) )
end

--- Returns the x, y, z size of the entity's outer bounding box (local to the entity)
-- @shared
-- @return The outer bounding box size
function ents_methods:obbSize ()
	SF.CheckType( self, ents_metamethods )
	local ent = unwrap( self )
	return SF.WrapObject( ent:OBBMaxs() - ent:OBBMins() )
end

--- Returns the local position of the entity's outer bounding box
-- @shared
-- @return The position vector of the outer bounding box center
function ents_methods:obbCenter ()
	SF.CheckType( self, ents_metamethods )
	local ent = unwrap( self )
	return SF.WrapObject( ent:OBBCenter() )
end

--- Returns the world position of the entity's outer bounding box
-- @shared
-- @return The position vector of the outer bounding box center
function ents_methods:obbCenterW ()
	SF.CheckType( self, ents_metamethods )
	local ent = unwrap( self )
	return SF.WrapObject( ent:LocalToWorld( ent:OBBCenter() ) )
end

--- Returns the local position of the entity's mass center
-- @shared
-- @return The position vector of the mass center
function ents_methods:getMassCenter ()
	SF.CheckType( self, ents_metamethods )
	local ent = unwrap( self )
	local phys = getPhysObject( ent )
	if not phys or not phys:IsValid() then SF.throw( "Entity has no physics object or is not valid", 2 ) end
	return SF.WrapObject( phys:GetMassCenter() )
end

--- Returns the world position of the entity's mass center
-- @shared
-- @return The position vector of the mass center
function ents_methods:getMassCenterW ()
	SF.CheckType( self, ents_metamethods )
	local ent = unwrap( self )
	local phys = getPhysObject( ent )
	if not phys or not phys:IsValid() then SF.throw( "Entity has no physics object or is not valid", 2 ) end
	return SF.WrapObject( ent:LocalToWorld( phys:GetMassCenter() ) )
end

--- Returns the angle of the entity
-- @shared
-- @return The angle
function ents_methods:getAngles ()
	SF.CheckType( self, ents_metamethods )
	local ent = unwrap( self )
	return SF.WrapObject( ent:GetAngles() )
end

--- Returns the mass of the entity
-- @shared
-- @return The numerical mass
function ents_methods:getMass ()
	SF.CheckType( self, ents_metamethods )
	
	local ent = unwrap( self )
	local phys = getPhysObject( ent )
	if not phys or not phys:IsValid() then SF.throw( "Entity has no physics object or is not valid", 2 ) end
	
	return phys:GetMass()
end

--- Returns the principle moments of inertia of the entity
-- @shared
-- @return The principle moments of inertia as a vector
function ents_methods:getInertia ()
	SF.CheckType( self, ents_metamethods )
	
	local ent = unwrap( self )
	local phys = getPhysObject( ent )
	if not phys or not phys:IsValid() then SF.throw( "Entity has no physics object or is not valid", 2 ) end
	
	return phys:GetInertia()
end

--- Returns the velocity of the entity
-- @shared
-- @return The velocity vector
function ents_methods:getVelocity ()
	SF.CheckType( self, ents_metamethods )
	local ent = unwrap( self )
	if not isValid( ent ) then SF.throw( "Entity is not valid", 2 ) end
	return SF.WrapObject( ent:GetVelocity() )
end

--- Returns the angular velocity of the entity
-- @shared
-- @return The angular velocity vector
function ents_methods:getAngleVelocity ()
	SF.CheckType( self, ents_metamethods )
	local phys = getPhysObject( unwrap( self ) )
	if not phys or not phys:IsValid() then SF.throw( "Entity has no physics object or is not valid", 2 ) end	
	return SF.WrapObject( phys:GetAngleVelocity() )
end

--- Converts a vector in entity local space to world space
-- @shared
-- @param data Local space vector
-- @return data as world space vector
function ents_methods:localToWorld( data )
	SF.CheckType( self, ents_metamethods )
	SF.CheckType( data, SF.Types[ "Vector" ] )
	local ent = unwrap( self )
	
	return SF.WrapObject( ent:LocalToWorld( vunwrap( data ) ) )
end

--- Converts an angle in entity local space to world space
-- @shared
-- @param data Local space angle
-- @return data as world space angle
function ents_methods:localToWorldAngles ( data )
	SF.CheckType( self, ents_metamethods )
	SF.CheckType( data, SF.Types[ "Angle" ] )
	local ent = unwrap( self )
	local data = SF.UnwrapObject( data )
	
	return SF.WrapObject( ent:LocalToWorldAngles( data ) )
end

--- Converts a vector in world space to entity local space
-- @shared
-- @param data World space vector
-- @return data as local space vector
function ents_methods:worldToLocal ( data )
	SF.CheckType( self, ents_metamethods )
	SF.CheckType( data, SF.Types[ "Vector" ] )
	local ent = unwrap( self )
	
	return SF.WrapObject( ent:WorldToLocal( vunwrap( data ) ) )
end

--- Converts an angle in world space to entity local space
-- @shared
-- @param data World space angle
-- @return data as local space angle
function ents_methods:worldToLocalAngles ( data )
	SF.CheckType( self, ents_metamethods )
	SF.CheckType( data, SF.Types[ "Angle" ] )
	local ent = unwrap( self )
	local data = SF.UnwrapObject( data )
	
	return SF.WrapObject( ent:WorldToLocalAngles( data ) )
end

--- Gets the model of an entity
-- @shared
-- @return Model of the entity
function ents_methods:getModel ()
	SF.CheckType( self, ents_metamethods )
	local ent = unwrap( self )
	return ent:GetModel()
end

--- Gets the max health of an entity
-- @shared
-- @return Max Health of the entity
function ents_methods:getMaxHealth ()
	SF.CheckType( self, ents_metamethods )
	local ent = unwrap( self )
	return ent:GetMaxHealth()
end

--- Gets the health of an entity
-- @shared
-- @return Health of the entity
function ents_methods:getHealth ()
	SF.CheckType( self, ents_metamethods )
	local ent = unwrap( self )
	return ent:Health()
end

--- Gets the entitiy's eye angles
-- @shared
-- @return Angles of the entity's eyes
function ents_methods:getEyeAngles ()
	SF.CheckType( self, ents_metamethods )
	local ent = unwrap( self )
	return SF.WrapObject( ent:EyeAngles() )
end

--- Gets the entity's eye position
-- @shared
-- @return Eye position of the entity
-- @return In case of a ragdoll, the position of the other eye
function ents_methods:getEyePos ()
	SF.CheckType( self, ents_metamethods )
	local ent = unwrap( self )
	return SF.WrapObject( ent:EyePos() )
end

--- Gets an entities' material
-- @shared
-- @class function
-- @return Material
function ents_methods:getMaterial ()
    local ent = unwrap( self )
    return ent:GetMaterial() or ""
end

--- Gets an entities' submaterial
-- @shared
-- @class function
-- @return Material
function ents_methods:getSubMaterial ( index )
    local ent = unwrap( self )
    return ent:GetSubMaterial( index ) or ""
end

--- Gets an entities' material list
-- @shared
-- @class function
-- @return Material
function ents_methods:getMaterials ()
    local ent = unwrap( self )
    return ent:GetMaterials() or {}
end

--- Gets the entities up vector
function ents_methods:getUp ()
	return SF.WrapObject( unwrap( self ):GetUp() )
end

--- Gets the entities right vector
function ents_methods:getRight ()
	return SF.WrapObject( unwrap( self ):GetRight() )
end

--- Gets the entities forward vector
function ents_methods:getForward ()
	return SF.WrapObject( unwrap( self ):GetForward() )
end
