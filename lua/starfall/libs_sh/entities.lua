-------------------------------------------------------------------------------
-- Shared entity library functions
-------------------------------------------------------------------------------

SF.Entities = {}

--- Entity type
-- @shared
local ents_methods, ents_metamethods = SF.Typedef("Entity")

local ewrap, eunwrap = SF.CreateWrapper(ents_metamethods, true, true, debug.getregistry().Entity)
local owrap, ounwrap = SF.WrapObject, SF.UnwrapObject
local ang_meta, vec_meta
local vwrap, vunwrap, awrap, aunwrap, cwrap, cunwrap, pwrap, punwrap
local isValid = IsValid

SF.Permissions.registerPrivilege("entities.setRenderProperty", "RenderProperty", "Allows the user to change the rendering of an entity", { entities = {} })

SF.Libraries.AddHook("postload", function()
	ang_meta = SF.Angles.Metatable
	vec_meta = SF.Vectors.Metatable

	vwrap = SF.Vectors.Wrap
	vunwrap = SF.Vectors.Unwrap
	awrap = SF.Angles.Wrap
	aunwrap = SF.Angles.Unwrap
	cwrap = SF.Color.Wrap
	cunwrap = SF.Color.Unwrap
	pwrap = SF.PhysObjs.Wrap
	punwrap = SF.PhysObjs.Unwrap

	function SF.DefaultEnvironment.chip ()
		return ewrap(SF.instance.data.entity)
	end

	function SF.DefaultEnvironment.owner ()
		return SF.WrapObject(SF.instance.player)
	end

	function SF.DefaultEnvironment.entity (num)
		SF.CheckLuaType(num, TYPE_NUMBER)
		return SF.WrapObject(Entity(num))
	end

	function SF.DefaultEnvironment.player (num)
		if num then
			SF.CheckLuaType(num, TYPE_NUMBER)
			return SF.WrapObject(Player(num))
		end

		return SERVER and SF.DefaultEnvironment.owner() or SF.WrapObject(LocalPlayer())
	end
end)

-- ------------------------- Internal functions ------------------------- --

SF.Entities.Wrap = ewrap
SF.Entities.Unwrap = eunwrap
SF.Entities.Methods = ents_methods
SF.Entities.Metatable = ents_metamethods

-- ------------------------- Methods ------------------------- --

--- Gets the owner of the entity
-- @return Owner
function ents_methods:getOwner ()
	SF.CheckType(self, ents_metamethods)
	local ent = eunwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end

	if SF.Permissions.getOwner then
		return ewrap(SF.Permissions.getOwner(ent))
	end
end

if CLIENT then
	--- Allows manipulation of a hologram's bones' positions
	-- @client
	-- @param bone The bone ID
	-- @param vec The position it should be manipulated to
	function ents_methods:manipulateBonePosition(bone, vec)
		SF.CheckLuaType(bone, TYPE_NUMBER)
		SF.CheckType(vec, vec_meta)
		local ent = eunwrap(self)
		if not isValid(ent) or not ent.GetHoloOwner then SF.Throw("The entity is invalid or not a hologram", 2) end
		if SF.instance.player ~= ent:GetHoloOwner() then SF.Throw("This hologram doesn't belong to you", 2) end
		ent:ManipulateBonePosition(bone, vunwrap(vec))
	end

	--- Allows manipulation of a hologram's bones' scale
	-- @client
	-- @param bone The bone ID
	-- @param vec The scale it should be manipulated to
	function ents_methods:manipulateBoneScale(bone, vec)
		SF.CheckLuaType(bone, TYPE_NUMBER)
		SF.CheckType(vec, vec_meta)
		local ent = eunwrap(self)
		if not isValid(ent) or not ent.GetHoloOwner then SF.Throw("The entity is invalid or not a hologram", 2) end
		if SF.instance.player ~= ent:GetHoloOwner() then SF.Throw("This hologram doesn't belong to you", 2) end
		ent:ManipulateBoneScale(bone, vunwrap(vec))
	end

	--- Allows manipulation of a hologram's bones' angles
	-- @client
	-- @param bone The bone ID
	-- @param ang The angle it should be manipulated to
	function ents_methods:manipulateBoneAngles(bone, ang)
		SF.CheckLuaType(bone, TYPE_NUMBER)
		SF.CheckType(ang, ang_meta)
		local ent = eunwrap(self)
		if not isValid(ent) or not ent.GetHoloOwner then SF.Throw("The entity is invalid or not a hologram", 2) end
		if SF.instance.player ~= ent:GetHoloOwner() then SF.Throw("This hologram doesn't belong to you", 2) end
		ent:ManipulateBoneAngles(bone, aunwrap(ang))
	end


	--- Sets a hologram entity's model to a custom Mesh
	-- @client
	-- @param mesh The mesh to set it to or nil to set back to normal
	function ents_methods:setHologramMesh(mesh)
		local instance = SF.instance
		SF.Permissions.check(instance, nil, "mesh")
		local ent = eunwrap(self)
		if not isValid(ent) or not ent.GetHoloOwner then SF.Throw("The entity is invalid or not a hologram", 2) end
		if instance.player ~= ent:GetHoloOwner() then SF.Throw("This hologram doesn't belong to you", 2) end
		if mesh then
			SF.CheckType(mesh, SF.Mesh.Metatable)
			ent:SetModelScale(0, 0)
			ent.custom_mesh = SF.Mesh.Unwrap(mesh)
			ent.custom_meta_data = instance.data.meshes
		else
			ent:SetModelScale(1, 0)
			ent.custom_mesh = nil
		end
	end

	--- Sets a hologram entity's renderbounds
	-- @client
	-- @param mins The lower bounding corner coordinate local to the hologram
	-- @param maxs The upper bounding corner coordinate local to the hologram
	function ents_methods:setHologramRenderBounds(mins, maxs)
		SF.CheckType(mins, vec_meta)
		SF.CheckType(maxs, vec_meta)
		local ent = eunwrap(self)
		if not isValid(ent) or not ent.GetHoloOwner then SF.Throw("The entity is invalid or not a hologram", 2) end
		if SF.instance.player ~= ent:GetHoloOwner() then SF.Throw("This hologram doesn't belong to you", 2) end
		ent:SetRenderBounds(vunwrap(mins), vunwrap(maxs))
	end

	--- Sets a hologram entity's rendermatrix
	-- @client
	-- @param mat VMatrix to use
	function ents_methods:setHologramRenderMatrix(mat)
		SF.CheckType(mat, SF.VMatrix.Metatable)
		local ent = eunwrap(self)
		if not isValid(ent) or not ent.GetHoloOwner then SF.Throw("The entity is invalid or not a hologram", 2) end
		if SF.instance.player ~= ent:GetHoloOwner() then SF.Throw("This hologram doesn't belong to you", 2) end
		local matrix = SF.VMatrix.Unwrap(mat)
		if matrix:IsIdentity() then
			ent:DisableMatrix("RenderMultiply")
		else
			ent:EnableMatrix("RenderMultiply", matrix)
		end
	end
end

--- Sets the color of the entity
-- @shared
-- @param clr New color
function ents_methods:setColor (clr)
	print(self, type(self), debug.getmetatable(self).__metatable)
	SF.CheckType(self, ents_metamethods)
	SF.CheckType(clr, SF.Types["Color"])

	local ent = eunwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance, ent, "entities.setRenderProperty")

	local rendermode = (clr.a == 255 and RENDERMODE_NORMAL or RENDERMODE_TRANSALPHA)
	ent:SetColor(clr)
	ent:SetRenderMode(rendermode)
	if SERVER then duplicator.StoreEntityModifier(ent, "colour", { Color = clr, RenderMode = rendermode }) end

end

--- Sets the whether an entity should be drawn or not
-- @shared
-- @param draw Whether to draw the entity or not.
function ents_methods:setNoDraw (draw)
	SF.CheckType(self, ents_metamethods)

	local ent = eunwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance, ent, "entities.setRenderProperty")

	ent:SetNoDraw(draw and true or false)
end

local shaderBlacklist = {
	["LightmappedGeneric"] = true,
}
local function invalidMaterial(material)
	if string.find(string.lower(material) , "pp[%./\\]+copy") then return true end
	local mat = Material(material)
	if mat and shaderBlacklist[mat:GetShader()] then return true end
end

--- Sets the material of the entity
-- @shared
-- @param material, string, New material name.
function ents_methods:setMaterial (material)
	SF.CheckType(self, ents_metamethods)
	SF.CheckLuaType(material, TYPE_STRING)
	if invalidMaterial(material) then SF.Throw("This material doesn't exist or is blacklisted", 2) end

	local ent = eunwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance, ent, "entities.setRenderProperty")

	ent:SetMaterial(material)
	if SERVER then duplicator.StoreEntityModifier(ent, "material", { MaterialOverride = material }) end
end

--- Sets the submaterial of the entity
-- @shared
-- @param index, number, submaterial index.
-- @param material, string, New material name.
function ents_methods:setSubMaterial (index, material)
	SF.CheckType(self, ents_metamethods)
	SF.CheckLuaType(material, TYPE_STRING)
	if invalidMaterial(material) then SF.Throw("This material doesn't exist or is blacklisted", 2) end

	local ent = eunwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance, ent, "entities.setRenderProperty")

	ent:SetSubMaterial(index, material)
	if SERVER then
		local mod = "SubMaterialOverride_"..index
		ent.EntityMods = ent.EntityMods or {}
		ent.EntityMods[mod] = ent.EntityMods[mod] or {}
		ent.EntityMods[mod] = material
	end
end

--- Sets the bodygroup of the entity
-- @shared
-- @param bodygroup Number, The ID of the bodygroup you're setting.
-- @param value Number, The value you're setting the bodygroup to.
function ents_methods:setBodygroup (bodygroup, value)
	SF.CheckType(self, ents_metamethods)
	SF.CheckLuaType(bodygroup, TYPE_NUMBER)
	SF.CheckLuaType(value, TYPE_NUMBER)

	local ent = eunwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance, ent, "entities.setRenderProperty")

	ent:SetBodygroup(bodygroup, value)
end

--- Sets the skin of the entity
-- @shared
-- @param skinIndex Number, Index of the skin to use.
function ents_methods:setSkin (skinIndex)
	SF.CheckType(self, ents_metamethods)
	SF.CheckLuaType(skinIndex, TYPE_NUMBER)

	local ent = eunwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance, ent, "entities.setRenderProperty")

	ent:SetSkin(skinIndex)
end

--- Sets the render mode of the entity
-- @shared
-- @class function
-- @param rendermode Number, rendermode to use. http://wiki.garrysmod.com/page/Enums/RENDERMODE
function ents_methods:setRenderMode (rendermode)
	SF.CheckType(self, ents_metamethods)
	SF.CheckLuaType(rendermode, TYPE_NUMBER)

	local ent = eunwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance, ent, "entities.setRenderProperty")

	ent:SetRenderMode(rendermode)
	if SERVER then duplicator.StoreEntityModifier(ent, "colour", { RenderMode = rendermode }) end
end

--- Sets the renderfx of the entity
-- @shared
-- @class function
-- @param renderfx Number, renderfx to use. http://wiki.garrysmod.com/page/Enums/kRenderFx
function ents_methods:setRenderFX (renderfx)
	SF.CheckType(self, ents_metamethods)
	SF.CheckLuaType(renderfx, TYPE_NUMBER)

	local ent = eunwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	SF.Permissions.check(SF.instance, ent, "entities.setRenderProperty")

	ent:SetRenderFX(renderfx)
	if SERVER then duplicator.StoreEntityModifier(ent, "colour", { RenderFX = renderfx }) end
end

--- To string
-- @shared
function ents_metamethods:__tostring ()
	local ent = eunwrap(self)
	if not ent then return "(null entity)"
	else return tostring(ent) end
end

--- Gets the parent of an entity
-- @shared
-- @return Entity's parent or nil
function ents_methods:getParent()
	local ent = eunwrap(self)
	return ewrap(ent:GetParent())
end

--- Gets the attachment index the entity is parented to
-- @shared
-- @return number index of the attachment the entity is parented to or 0
function ents_methods:getAttachmentParent()
	local ent = eunwrap(self)
	return ent:GetParentAttachment()
end

--- Gets the attachment index via the entity and it's attachment name
-- @shared
-- @param name
-- @return number of the attachment index, or 0 if it doesn't exist
function ents_methods:lookupAttachment(name)
	local ent = eunwrap(self)
	return ent:LookupAttachment(name)
end

--- Gets the position and angle of an attachment
-- @shared
-- @param index The index of the attachment
-- @return vector position, and angle orientation
function ents_methods:getAttachment(index)
	local ent = eunwrap(self)
	if ent then
		local t = ent:GetAttachment(index)
		if t then
			return vwrap(t.Pos), awrap(t.Ang)
		end
	end
end

--- Converts a ragdoll bone id to the corresponding physobject id
-- @param boneid The ragdoll boneid
-- @return The physobj id
function ents_methods:translateBoneToPhysBone(boneid)
	local ent = eunwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid.", 2) end
	return ent:TranslateBoneToPhysBone(boneid)
end

--- Converts a physobject id to the corresponding ragdoll bone id
-- @param boneid The physobject id
-- @return The ragdoll bone id
function ents_methods:translatePhysBoneToBone(boneid)
	local ent = eunwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid.", 2) end
	return ent:TranslatePhysBoneToBone(boneid)
end

--- Gets the number of physicsobjects of an entity
-- @return The number of physics objects on the entity
function ents_methods:getPhysicsObjectCount()
	local ent = eunwrap(self)
	if not isValid(ent) and ent ~= game.GetWorld() then SF.Throw("Entity is not valid.", 2) end
	return ent:GetPhysicsObjectCount()
end

--- Gets the main physics objects of an entity
-- @return The main physics object of the entity
function ents_methods:getPhysicsObject()
	local ent = eunwrap(self)
	if not isValid(ent) and ent ~= game.GetWorld() then SF.Throw("Entity is not valid.", 2) end
	return pwrap(ent:GetPhysicsObject())
end

--- Gets a physics objects of an entity
-- @param id The physics object id (starts at 0)
-- @return The physics object of the entity
function ents_methods:getPhysicsObjectNum(id)
	SF.CheckLuaType(id, TYPE_NUMBER)
	local ent = eunwrap(self)
	if not isValid(ent) and ent ~= game.GetWorld() then SF.Throw("Entity is not valid.", 2) end
	return pwrap(ent:GetPhysicsObjectNum(id))
end

--- Gets the color of an entity
-- @shared
-- @return Color
function ents_methods:getColor ()
	local this = eunwrap(self)
	return cwrap(this:GetColor())
end

--- Checks if an entity is valid.
-- @shared
-- @return True if valid, false if not
function ents_methods:isValid ()
	SF.CheckType(self, ents_metamethods)
	return isValid(eunwrap(self))
end

--- Checks if an entity is a player.
-- @shared
-- @return True if player, false if not
function ents_methods:isPlayer ()
	SF.CheckType(self, ents_metamethods)
	return eunwrap(self):IsPlayer()
end

--- Checks if an entity is a weapon.
-- @shared
-- @return True if weapon, false if not
function ents_methods:isWeapon ()
	SF.CheckType(self, ents_metamethods)
	return eunwrap(self):IsWeapon()
end

--- Checks if an entity is a vehicle.
-- @shared
-- @return True if vehicle, false if not
function ents_methods:isVehicle ()
	SF.CheckType(self, ents_metamethods)
	return eunwrap(self):IsVehicle()
end

--- Checks if an entity is an npc.
-- @shared
-- @return True if npc, false if not
function ents_methods:isNPC ()
	SF.CheckType(self, ents_metamethods)
	return eunwrap(self):IsNPC()
end

--- Checks if the entity ONGROUND flag is set
-- @shared
-- @return Boolean if it's flag is set or not
function ents_methods:isOnGround ()
	SF.CheckType(self, ents_metamethods)
	return eunwrap(self):IsOnGround()
end

--- Returns the EntIndex of the entity
-- @shared
-- @return The numerical index of the entity
function ents_methods:entIndex ()
	SF.CheckType(self, ents_metamethods)
	local ent = eunwrap(self)
	return ent:EntIndex()
end

--- Returns the class of the entity
-- @shared
-- @return The string class name
function ents_methods:getClass ()
	SF.CheckType(self, ents_metamethods)
	local ent = eunwrap(self)
	return ent:GetClass()
end

--- Returns the position of the entity
-- @shared
-- @return The position vector
function ents_methods:getPos ()
	SF.CheckType(self, ents_metamethods)
	local ent = eunwrap(self)
	return vwrap(ent:GetPos())
end

--- Returns how submerged the entity is in water
-- @shared
-- @return The water level. 0 none, 1 slightly, 2 at least halfway, 3 all the way
function ents_methods:getWaterLevel()
	SF.CheckType(self, ents_metamethods)
	local ent = eunwrap(self)
	return ent:WaterLevel()
end

--- Returns the ragdoll bone index given a bone name
-- @shared
-- @param name The bone's string name
-- @return The bone index
function ents_methods:lookupBone(name)
	SF.CheckLuaType(name, TYPE_STRING)
	return eunwrap(self):LookupBone(name)
end

--- Returns the matrix of the entity's bone
-- @shared
-- @param bone Bone index. (def 0)
-- @return The matrix
function ents_methods:getBoneMatrix(bone)
	SF.CheckType(self, ents_metamethods)
	bone = SF.CheckLuaType(bone, TYPE_NUMBER, 0, 0)

	local ent = eunwrap(self)
	return owrap(ent:GetBoneMatrix(bone))
end
ents_methods.getMatrix = ents_methods.getBoneMatrix

--- Returns the number of an entity's bones
-- @shared
-- @return Number of bones
function ents_methods:getBoneCount()
	SF.CheckType(self, ents_metamethods)
	local ent = eunwrap(self)
	return ent:GetBoneCount()
end

--- Returns the name of an entity's bone
-- @shared
-- @param bone Bone index. (def 0)
-- @return Name of the bone
function ents_methods:getBoneName(bone)
	SF.CheckType(self, ents_metamethods)
	bone = SF.CheckLuaType(bone, TYPE_NUMBER, 0, 0)
	local ent = eunwrap(self)
	return ent:GetBoneName(bone)
end

--- Returns the parent index of an entity's bone
-- @shared
-- @param bone Bone index. (def 0)
-- @return Parent index of the bone
function ents_methods:getBoneParent(bone)
	SF.CheckType(self, ents_metamethods)
	bone = SF.CheckLuaType(bone, TYPE_NUMBER, 0, 0)
	local ent = eunwrap(self)
	return ent:GetBoneParent(bone)
end

--- Returns the bone's position and angle in world coordinates
-- @shared
-- @param bone Bone index. (def 0)
-- @return Position of the bone
-- @return Angle of the bone
function ents_methods:getBonePosition(bone)
	SF.CheckType(self, ents_metamethods)
	bone = SF.CheckLuaType(bone, TYPE_NUMBER, 0, 0)
	local ent = eunwrap(self)
	local pos, ang = ent:GetBonePosition(bone)
	return vwrap(pos), awrap(ang)
end

--- Returns the x, y, z size of the entity's outer bounding box (local to the entity)
-- @shared
-- @return The outer bounding box size
function ents_methods:obbSize ()
	SF.CheckType(self, ents_metamethods)
	local ent = eunwrap(self)
	return vwrap(ent:OBBMaxs() - ent:OBBMins())
end

--- Returns the local position of the entity's outer bounding box
-- @shared
-- @return The position vector of the outer bounding box center
function ents_methods:obbCenter ()
	SF.CheckType(self, ents_metamethods)
	local ent = eunwrap(self)
	return vwrap(ent:OBBCenter())
end

--- Returns the world position of the entity's outer bounding box
-- @shared
-- @return The position vector of the outer bounding box center
function ents_methods:obbCenterW ()
	SF.CheckType(self, ents_metamethods)
	local ent = eunwrap(self)
	return vwrap(ent:LocalToWorld(ent:OBBCenter()))
end

--- Returns the local position of the entity's mass center
-- @shared
-- @return The position vector of the mass center
function ents_methods:getMassCenter ()
	SF.CheckType(self, ents_metamethods)
	local ent = eunwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	local phys = ent:GetPhysicsObject()
	if not isValid(phys) then SF.Throw("Physics object is invalid", 2) end
	return vwrap(phys:GetMassCenter())
end

--- Returns the world position of the entity's mass center
-- @shared
-- @return The position vector of the mass center
function ents_methods:getMassCenterW ()
	SF.CheckType(self, ents_metamethods)
	local ent = eunwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	local phys = ent:GetPhysicsObject()
	if not isValid(phys) then SF.Throw("Physics object is invalid", 2) end
	return vwrap(ent:LocalToWorld(phys:GetMassCenter()))
end

--- Returns the angle of the entity
-- @shared
-- @return The angle
function ents_methods:getAngles ()
	SF.CheckType(self, ents_metamethods)
	local ent = eunwrap(self)
	return awrap(ent:GetAngles())
end

--- Returns the mass of the entity
-- @shared
-- @return The numerical mass
function ents_methods:getMass ()
	SF.CheckType(self, ents_metamethods)

	local ent = eunwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	local phys = ent:GetPhysicsObject()
	if not isValid(phys) then SF.Throw("Physics object is invalid", 2) end

	return phys:GetMass()
end

--- Returns the principle moments of inertia of the entity
-- @shared
-- @return The principle moments of inertia as a vector
function ents_methods:getInertia ()
	SF.CheckType(self, ents_metamethods)

	local ent = eunwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	local phys = ent:GetPhysicsObject()
	if not isValid(phys) then SF.Throw("Physics object is invalid", 2) end

	return vwrap(phys:GetInertia())
end

--- Returns the velocity of the entity
-- @shared
-- @return The velocity vector
function ents_methods:getVelocity ()
	SF.CheckType(self, ents_metamethods)
	local ent = eunwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	return vwrap(ent:GetVelocity())
end

--- Returns the angular velocity of the entity
-- @shared
-- @return The angular velocity as a vector
function ents_methods:getAngleVelocity ()
	SF.CheckType(self, ents_metamethods)
	local ent = eunwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	local phys = ent:GetPhysicsObject()
	if not isValid(phys) then SF.Throw("Physics object is invalid", 2) end
	return vwrap(phys:GetAngleVelocity())
end

--- Returns the angular velocity of the entity
-- @shared
-- @return The angular velocity as an angle
function ents_methods:getAngleVelocityAngle ()
	SF.CheckType(self, ents_metamethods)
	local ent = eunwrap(self)
	if not isValid(ent) then SF.Throw("Entity is not valid", 2) end
	local phys = ent:GetPhysicsObject()
	if not isValid(phys) then SF.Throw("Physics object is invalid", 2) end
	local vec = phys:GetAngleVelocity()
	return awrap(Angle(vec.y, vec.z, vec.x))
end

--- Converts a vector in entity local space to world space
-- @shared
-- @param data Local space vector
-- @return data as world space vector
function ents_methods:localToWorld(data)
	SF.CheckType(self, ents_metamethods)
	SF.CheckType(data, vec_meta)
	local ent = eunwrap(self)

	return vwrap(ent:LocalToWorld(vunwrap(data)))
end

--- Converts an angle in entity local space to world space
-- @shared
-- @param data Local space angle
-- @return data as world space angle
function ents_methods:localToWorldAngles (data)
	SF.CheckType(self, ents_metamethods)
	SF.CheckType(data, ang_meta)
	local ent = eunwrap(self)
	local data = aunwrap(data)

	return awrap(ent:LocalToWorldAngles(data))
end

--- Converts a vector in world space to entity local space
-- @shared
-- @param data World space vector
-- @return data as local space vector
function ents_methods:worldToLocal (data)
	SF.CheckType(self, ents_metamethods)
	SF.CheckType(data, vec_meta)
	local ent = eunwrap(self)

	return vwrap(ent:WorldToLocal(vunwrap(data)))
end

--- Converts an angle in world space to entity local space
-- @shared
-- @param data World space angle
-- @return data as local space angle
function ents_methods:worldToLocalAngles (data)
	SF.CheckType(self, ents_metamethods)
	SF.CheckType(data, ang_meta)
	local ent = eunwrap(self)
	local data = aunwrap(data)

	return awrap(ent:WorldToLocalAngles(data))
end

--- Gets the model of an entity
-- @shared
-- @return Model of the entity
function ents_methods:getModel ()
	SF.CheckType(self, ents_metamethods)
	local ent = eunwrap(self)
	return ent:GetModel()
end

--- Gets the max health of an entity
-- @shared
-- @return Max Health of the entity
function ents_methods:getMaxHealth ()
	SF.CheckType(self, ents_metamethods)
	local ent = eunwrap(self)
	return ent:GetMaxHealth()
end

--- Gets the health of an entity
-- @shared
-- @return Health of the entity
function ents_methods:getHealth ()
	SF.CheckType(self, ents_metamethods)
	local ent = eunwrap(self)
	return ent:Health()
end

--- Gets the entitiy's eye angles
-- @shared
-- @return Angles of the entity's eyes
function ents_methods:getEyeAngles ()
	SF.CheckType(self, ents_metamethods)
	local ent = eunwrap(self)
	return awrap(ent:EyeAngles())
end

--- Gets the entity's eye position
-- @shared
-- @return Eye position of the entity
-- @return In case of a ragdoll, the position of the second eye
function ents_methods:getEyePos ()
	SF.CheckType(self, ents_metamethods)
	local ent = eunwrap(self)
	local pos1, pos2 = ent:EyePos()
	if pos2 then
		return vwrap(pos1), vwrap(pos2)
	end
	return vwrap(pos1)
end

--- Gets an entities' material
-- @shared
-- @class function
-- @return String material
function ents_methods:getMaterial ()
	local ent = eunwrap(self)
	return ent:GetMaterial() or ""
end

--- Gets an entities' submaterial
-- @shared
-- @class function
-- @return String material
function ents_methods:getSubMaterial (index)
	local ent = eunwrap(self)
	return ent:GetSubMaterial(index) or ""
end

--- Gets an entities' material list
-- @shared
-- @class function
-- @return Material
function ents_methods:getMaterials ()
	local ent = eunwrap(self)
	return ent:GetMaterials() or {}
end

--- Gets the skin number of the entity
-- @shared
-- @return Skin number
function ents_methods:getSkin ()
	local ent = eunwrap(self)
	return ent:GetSkin()
end

--- Gets the entity's up vector
-- @shared
-- @return Vector up
function ents_methods:getUp ()
	return vwrap(eunwrap(self):GetUp())
end

--- Gets the entity's right vector
-- @shared
-- @return Vector right
function ents_methods:getRight ()
	return vwrap(eunwrap(self):GetRight())
end

--- Gets the entity's forward vector
-- @shared
-- @return Vector forward
function ents_methods:getForward ()
	return vwrap(eunwrap(self):GetForward())
end
