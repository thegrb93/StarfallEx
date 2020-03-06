-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check
local registerprivilege = SF.Permissions.registerPrivilege

registerprivilege("entities.setRenderProperty", "RenderProperty", "Allows the user to change the rendering of an entity", { client = (CLIENT and {} or nil), entities = {} })
registerprivilege("entities.setPlayerRenderProperty", "PlayerRenderProperty", "Allows the user to change the rendering of themselves", {})
registerprivilege("entities.emitSound", "Emitsound", "Allows the user to play sounds on entities", { client = (CLIENT and {} or nil), entities = {} })


--- Entity type
-- @name Entity
-- @class type
-- @libtbl ents_methods
-- @libtbl ent_meta
SF.RegisterType("Entity", false, true, debug.getregistry().Entity)



return function(instance)

local ents_methods, ent_meta, ewrap, eunwrap = instance.Types.Entity.Methods, instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local col_meta, cwrap, cunwrap = instance.Types.Color, instance.Types.Color.Wrap, instance.Types.Color.Unwrap
local phys_meta, pwrap, punwrap = instance.Types.PhysObj, instance.Types.PhysObj.Wrap, instance.Types.PhysObj.Unwrap
local mtx_meta, mwrap, munwrap = instance.Types.VMatrix, instance.Types.VMatrix.Wrap, instance.Types.VMatrix.Unwrap
local plywrap = instance.Types.Player.Wrap

local function getent(self)
	local ent = eunwrap(self)
	if ent:IsValid() or ent:IsWorld() then
		return ent
	else
		SF.Throw("Entity is not valid.", 3)
	end
end
instance.Types.Entity.GetEntity = getent

--- To string
function ent_meta:__tostring()
	local ent = eunwrap(self)
	if not ent then return "(null entity)"
	else return tostring(ent) end
end

-- ------------------------- Methods ------------------------- --

--- Gets the owner of the entity
-- @return Owner
function ents_methods:getOwner()
	local ent = getent(self)

	if SF.Permissions.getOwner then
		return plywrap(SF.Permissions.getOwner(ent))
	end
end

if CLIENT then
	--- Allows manipulation of an entity's bones' positions
	-- @client
	-- @param bone The bone ID
	-- @param vec The position it should be manipulated to
	function ents_methods:manipulateBonePosition(bone, vec)
		checkluatype(bone, TYPE_NUMBER)
		local ent = getent(self)
		checkpermission(instance, ent, "entities.setRenderProperty")
		ent:ManipulateBonePosition(bone, vunwrap(vec))
	end

	--- Allows manipulation of an entity's bones' scale
	-- @client
	-- @param bone The bone ID
	-- @param vec The scale it should be manipulated to
	function ents_methods:manipulateBoneScale(bone, vec)
		checkluatype(bone, TYPE_NUMBER)
		local ent = getent(self)
		checkpermission(instance, ent, "entities.setRenderProperty")
		ent:ManipulateBoneScale(bone, vunwrap(vec))
	end

	--- Allows manipulation of an entity's bones' angles
	-- @client
	-- @param bone The bone ID
	-- @param ang The angle it should be manipulated to
	function ents_methods:manipulateBoneAngles(bone, ang)
		checkluatype(bone, TYPE_NUMBER)
		local ent = getent(self)
		checkpermission(instance, ent, "entities.setRenderProperty")
		ent:ManipulateBoneAngles(bone, aunwrap(ang))
	end

	--- Sets a hologram or custom_prop model to a custom Mesh
	-- @client
	-- @param mesh The mesh to set it to or nil to set back to normal
	function ents_methods:setMesh(mesh)
		local ent = getent(self)
		if not ent.IsHologram then SF.Throw("The entity isn't a hologram", 2) end

		checkpermission(instance, nil, "mesh")
		checkpermission(instance, ent, "entities.setRenderProperty")
		if mesh then
			ent.custom_mesh = instance.Types.Mesh.Unwrap(mesh)
			ent.custom_mesh_data = instance.data.meshes
		else
			ent.custom_mesh = nil
		end
	end

	--- Sets a hologram or custom_prop's custom mesh material
	-- @client
	-- @param material The material to set it to or nil to set back to default
	function ents_methods:setMeshMaterial(material)
		local ent = getent(self)
		if not ent.IsHologram then SF.Throw("The entity isn't a hologram", 2) end

		checkpermission(instance, ent, "entities.setRenderProperty")

		if material then
			local t = debug.getmetatable(material)
			if t~=instance.Types.Material and t~=instance.Types.LMaterial then SF.ThrowTypeError("Material", SF.GetType(material), 2) end
			ent.Material = instance.Types.Material.Unwrap(material)
		else
			ent.Material = ent.DefaultMaterial
		end
	end

	--- Sets a hologram or custom_prop's renderbounds
	-- @client
	-- @param mins The lower bounding corner coordinate local to the hologram
	-- @param maxs The upper bounding corner coordinate local to the hologram
	function ents_methods:setRenderBounds(mins, maxs)
		local ent = getent(self)
		if not ent.IsHologram then SF.Throw("The entity isn't a hologram", 2) end


		checkpermission(instance, ent, "entities.setRenderProperty")

		ent:SetRenderBounds(vunwrap(mins), vunwrap(maxs))
	end
end

local soundsByEntity = SF.EntityTable("emitSoundsByEntity", function(e, t)
	for snd, _ in pairs(t) do
		e:StopSound(snd)
	end
end, true)

--- Plays a sound on the entity
-- @param snd string Sound path
-- @param lvl number soundLevel=75
-- @param pitch pitchPercent=100
-- @param volume volume=1
-- @param channel channel=CHAN_AUTO
function ents_methods:emitSound(snd, lvl, pitch, volume, channel)
	checkluatype(snd, TYPE_STRING)

	local ent = getent(self)
	checkpermission(instance, ent, "entities.emitSound")

	local snds = soundsByEntity[ent]
	if not snds then snds = {} soundsByEntity[ent] = snds end
	snds[snd] = true
	ent:EmitSound(snd, lvl, pitch, volume, channel)
end

--- Stops a sound on the entity
-- @param snd string Soundscript path. See http://wiki.garrysmod.com/page/Entity/StopSound
function ents_methods:stopSound(snd)
	checkluatype(snd, TYPE_STRING)

	local ent = getent(self)
	checkpermission(instance, ent, "entities.emitSound")

	if soundsByEntity[ent] then
		soundsByEntity[ent][snd] = nil
	end

	ent:StopSound(snd)
end

--- Sets the color of the entity
-- @shared
-- @param clr New color
function ents_methods:setColor(clr)

	local ent = getent(self)
	if SERVER and ent == instance.player then
		checkpermission(instance, ent, "entities.setPlayerRenderProperty")
	else
		checkpermission(instance, ent, "entities.setRenderProperty")
	end

	local rendermode = (clr.a == 255 and RENDERMODE_NORMAL or RENDERMODE_TRANSALPHA)
	ent:SetColor(clr)
	ent:SetRenderMode(rendermode)
	if SERVER then duplicator.StoreEntityModifier(ent, "colour", { Color = {r = clr[1], g = clr[2], b = clr[3], a = clr[4]}, RenderMode = rendermode }) end
end

--- Sets the whether an entity should be drawn or not
-- @shared
-- @param draw Whether to draw the entity or not.
function ents_methods:setNoDraw(draw)
	local ent = getent(self)
	checkpermission(instance, ent, "entities.setRenderProperty")

	ent:SetNoDraw(draw and true or false)
end

--- Sets the material of the entity
-- @shared
-- @param material, string, New material name.
function ents_methods:setMaterial(material)
	checkluatype(material, TYPE_STRING)
	if SF.CheckMaterial(material) == false then SF.Throw("This material is invalid", 2) end

	local ent = getent(self)
	if SERVER and ent == instance.player then
		checkpermission(instance, ent, "entities.setPlayerRenderProperty")
	else
		checkpermission(instance, ent, "entities.setRenderProperty")
	end

	ent:SetMaterial(material)
	if SERVER then duplicator.StoreEntityModifier(ent, "material", { MaterialOverride = material }) end
end

--- Sets the submaterial of the entity
-- @shared
-- @param index, number, submaterial index.
-- @param material, string, New material name.
function ents_methods:setSubMaterial(index, material)
	checkluatype(material, TYPE_STRING)
	if SF.CheckMaterial(material) == false then SF.Throw("This material is invalid", 2) end
	index = math.Clamp(index, 0, 255)
	local ent = getent(self)
	if SERVER and ent == instance.player then
		checkpermission(instance, ent, "entities.setPlayerRenderProperty")
	else
		checkpermission(instance, ent, "entities.setRenderProperty")
	end

	ent:SetSubMaterial(index, material)
	if SERVER then
		duplicator.StoreEntityModifier( ent, "submaterial", {["SubMaterialOverride_"..index] = material} )
	end
end

--- Sets the bodygroup of the entity
-- @shared
-- @param bodygroup Number, The ID of the bodygroup you're setting.
-- @param value Number, The value you're setting the bodygroup to.
function ents_methods:setBodygroup(bodygroup, value)
	checkluatype(bodygroup, TYPE_NUMBER)
	checkluatype(value, TYPE_NUMBER)

	local ent = getent(self)
	if SERVER and ent == instance.player then
		checkpermission(instance, ent, "entities.setPlayerRenderProperty")
	else
		checkpermission(instance, ent, "entities.setRenderProperty")
	end

	ent:SetBodygroup(bodygroup, value)
end

--- Sets the skin of the entity
-- @shared
-- @param skinIndex Number, Index of the skin to use.
function ents_methods:setSkin(skinIndex)
	checkluatype(skinIndex, TYPE_NUMBER)

	local ent = getent(self)
	if SERVER and ent == instance.player then
		checkpermission(instance, ent, "entities.setPlayerRenderProperty")
	else
		checkpermission(instance, ent, "entities.setRenderProperty")
	end

	ent:SetSkin(skinIndex)
end

--- Sets the render mode of the entity
-- @shared
-- @class function
-- @param rendermode Number, rendermode to use. http://wiki.garrysmod.com/page/Enums/RENDERMODE
function ents_methods:setRenderMode(rendermode)
	checkluatype(rendermode, TYPE_NUMBER)

	local ent = getent(self)
	if SERVER and ent == instance.player then
		checkpermission(instance, ent, "entities.setPlayerRenderProperty")
	else
		checkpermission(instance, ent, "entities.setRenderProperty")
	end

	ent:SetRenderMode(rendermode)
	if SERVER then duplicator.StoreEntityModifier(ent, "colour", { RenderMode = rendermode }) end
end

--- Sets the renderfx of the entity
-- @shared
-- @class function
-- @param renderfx Number, renderfx to use. http://wiki.garrysmod.com/page/Enums/kRenderFx
function ents_methods:setRenderFX(renderfx)
	checkluatype(renderfx, TYPE_NUMBER)

	local ent = getent(self)
	if SERVER and ent == instance.player then
		checkpermission(instance, ent, "entities.setPlayerRenderProperty")
	else
		checkpermission(instance, ent, "entities.setRenderProperty")
	end

	ent:SetRenderFX(renderfx)
	if SERVER then duplicator.StoreEntityModifier(ent, "colour", { RenderFX = renderfx }) end
end

--- Gets the parent of an entity
-- @shared
-- @return Entity's parent or nil
function ents_methods:getParent()
	local ent = getent(self)
	return ewrap(ent:GetParent())
end

--- Gets the children (the parented entities) of an entity
-- @shared
-- @return table of parented children
function ents_methods:getChildren()
	local ent = getent(self)
	return instance.Sanitize(ent:GetChildren())
end

--- Gets the attachment index the entity is parented to
-- @shared
-- @return number index of the attachment the entity is parented to or 0
function ents_methods:getAttachmentParent()
	local ent = getent(self)
	return ent:GetParentAttachment()
end

--- Gets the attachment index via the entity and it's attachment name
-- @shared
-- @param name
-- @return number of the attachment index, or 0 if it doesn't exist
function ents_methods:lookupAttachment(name)
	local ent = getent(self)
	return ent:LookupAttachment(name)
end

--- Gets the position and angle of an attachment
-- @shared
-- @param index The index of the attachment
-- @return vector position, and angle orientation or nil if the attachment doesn't exist
function ents_methods:getAttachment(index)
	local ent = getent(self)
	local t = ent:GetAttachment(index)
	if t then
		return vwrap(t.Pos), awrap(t.Ang)
	end
end

--- Returns a table of attachments
-- @shared
-- @return table of attachment id and attachment name or nil
function ents_methods:getAttachments()
	local ent = getent(self)
	return ent:GetAttachments()
end

--- Converts a ragdoll bone id to the corresponding physobject id
-- @param boneid The ragdoll boneid
-- @return The physobj id
function ents_methods:translateBoneToPhysBone(boneid)
	local ent = getent(self)
	return ent:TranslateBoneToPhysBone(boneid)
end

--- Converts a physobject id to the corresponding ragdoll bone id
-- @param boneid The physobject id
-- @return The ragdoll bone id
function ents_methods:translatePhysBoneToBone(boneid)
	local ent = getent(self)
	return ent:TranslatePhysBoneToBone(boneid)
end

--- Gets the number of physicsobjects of an entity
-- @return The number of physics objects on the entity
function ents_methods:getPhysicsObjectCount()
	local ent = getent(self)
	return ent:GetPhysicsObjectCount()
end

--- Gets the main physics objects of an entity
-- @return The main physics object of the entity
function ents_methods:getPhysicsObject()
	local ent = getent(self)
	if ent:IsWorld() then SF.Throw("Cannot get the world physobj.", 2) end
	return pwrap(ent:GetPhysicsObject())
end

--- Gets a physics objects of an entity
-- @param id The physics object id (starts at 0)
-- @return The physics object of the entity
function ents_methods:getPhysicsObjectNum(id)
	checkluatype(id, TYPE_NUMBER)
	local ent = getent(self)
	return pwrap(ent:GetPhysicsObjectNum(id))
end

--- Gets the color of an entity
-- @shared
-- @return Color
function ents_methods:getColor()
	local ent = getent(self)
	return cwrap(ent:GetColor())
end

--- Gets the clipping of an entity
-- @shared
-- @return Table containing the clipdata
function ents_methods:getClipping()
	local ent = getent(self)
	
	local clips = {}
	
	-- Clips from visual clip tool
	if ent.ClipData then
		for i, clip in pairs(ent.ClipData) do
			local normal = (clip[1] or clip.n):Forward()
			
			table.insert(clips, {
				local_ent = self,
				origin = vwrap((clip[4] or Vector()) + normal * (clip[2] or clip.d)),
				normal = vwrap(normal)
			})
		end
	end
	
	-- Clips from Starfall and E2 holograms
	if ent.clips then
		for i, clip in pairs(ent.clips) do
			if clip.enabled ~= false then
				local local_ent = false
				
				if clip.localentid then
					local_ent = ewrap(Entity(clip.localentid))
				elseif clip.entity then
					local_ent = ewrap(clip.entity)
				end
				
				table.insert(clips, {
					local_ent = local_ent,
					origin = vwrap(clip.origin),
					normal = vwrap(clip.normal)
				})
			end
		end
	end
	
	-- Clips from Lemongate and ExpAdv holograms
	if ent.CLIPS then
		for i, clip in pairs(ent.CLIPS) do
			if clip.ENABLED then
				table.insert(clips, {
					local_ent = not clip.Global and self or false,
					origin = vwrap(Vector(clip.ORIGINX, clip.ORIGINY, clip.ORIGINZ)),
					normal = vwrap(Vector(clip.NORMALX, clip.NORMALY, clip.NORMALZ))
				})
			end
		end
	end
	
	return clips
end

--- Checks if an entity is valid.
-- @shared
-- @return True if valid, false if not
function ents_methods:isValid()
	local ent = eunwrap(self)
	if ent and ent:IsValid() then
		return true
	else
		return false
	end
end

--- Checks if an entity is a player.
-- @shared
-- @return True if player, false if not
function ents_methods:isPlayer()
	local ent = getent(self)
	return ent:IsPlayer()
end

--- Checks if an entity is a weapon.
-- @shared
-- @return True if weapon, false if not
function ents_methods:isWeapon()
	local ent = getent(self)
	return ent:IsWeapon()
end

--- Checks if an entity is a vehicle.
-- @shared
-- @return True if vehicle, false if not
function ents_methods:isVehicle()
	local ent = getent(self)
	return ent:IsVehicle()
end

--- Checks if an entity is an npc.
-- @shared
-- @return True if npc, false if not
function ents_methods:isNPC()
	local ent = getent(self)
	return ent:IsNPC()
end

--- Checks if the entity ONGROUND flag is set
-- @shared
-- @return Boolean if it's flag is set or not
function ents_methods:isOnGround()
	local ent = getent(self)
	return ent:IsOnGround()
end

--- Returns if the entity is ignited
-- @shared
-- @return Boolean if the entity is on fire or not
function ents_methods:isOnFire()
	local ent = getent(self)
	return ent:IsOnFire()
end

--- Returns the starfall or expression2's name
-- @return The name of the chip
function ents_methods:getChipName()
	local ent = getent(self)
	if ent.GetGateName then
		return ent:GetGateName()
	else
		SF.Throw("The entity is not a starfall or expression2!", 2)
	end
end

--- Gets the author of the specified starfall.
-- @shared
-- @return The author of the starfall chip.
function ents_methods:getChipAuthor()
	local ent = getent(self)
	if not ent.Starfall then SF.Throw("The entity isn't a starfall chip", 2) end
	
	return ent.author
end

--- Returns the current count for this Think's CPU Time of the specified starfall.
-- This value increases as more executions are done, may not be exactly as you want.
-- If used on screens, will show 0 if only rendering is done. Operations must be done in the Think loop for them to be counted.
-- @shared
-- @return Current quota used this Think
function ents_methods:getQuotaUsed()
	local ent = getent(self)
	if not ent.Starfall then SF.Throw("The entity isn't a starfall chip", 2) end
	
	return ent.instance.cpu_total
end

--- Gets the Average CPU Time in the buffer of the specified starfall or expression2.
-- @shared
-- @return Average CPU Time of the buffer of the specified starfall or expression2.
function ents_methods:getQuotaAverage()
	local ent = getent(self)
	if ent.Starfall then
		return ent.instance:movingCPUAverage()
	elseif ent.WireDebugName == "Expression 2" then
		return ent.context.timebench
	else
		SF.Throw("The entity isn't a starfall or expression2 chip", 2) end
	end
end

--- Gets the CPU Time max of the specified starfall of the specified starfall or expression2.
-- CPU Time is stored in a buffer of N elements, if the average of this exceeds quotaMax, the chip will error.
-- @shared
-- @return Max SysTime allowed to take for execution of the chip in a Think.
function ents_methods:getQuotaMax()
	local ent = getent(self)
	if ent.Starfall then
		return ent.instance.cpuQuota
	elseif ent.WireDebugName == "Expression 2" then
		return GetConVarNumber("wire_expression2_quotatime")
	else
		SF.Throw("The entity isn't a starfall or expression2 chip", 2) end
	end
end

if SERVER then
	--- Gets all players the specified starfall errored for.
	-- This excludes the owner of the starfall chip.
	-- @server
	-- @return A table containg the errored players.
	function ents_methods:getErroredPlayers()
		local ent = getent(self)
		if not ent.Starfall then SF.Throw("The entity isn't a starfall chip", 2) end
		
		local plys = {}
		for ply, _ in pairs(ent.ErroredPlayers) do
			if ply:IsValid() then
				table.insert(plys, plywrap(ply))
			end
		end
		
		return plys
	end
end

--- Returns the EntIndex of the entity
-- @shared
-- @return The numerical index of the entity
function ents_methods:entIndex()
	local ent = getent(self)
	return ent:EntIndex()
end

--- Returns the class of the entity
-- @shared
-- @return The string class name
function ents_methods:getClass()
	local ent = getent(self)
	return ent:GetClass()
end

--- Returns the position of the entity
-- @shared
-- @return The position vector
function ents_methods:getPos()
	local ent = getent(self)
	return vwrap(ent:GetPos())
end

--- Returns how submerged the entity is in water
-- @shared
-- @return The water level. 0 none, 1 slightly, 2 at least halfway, 3 all the way
function ents_methods:getWaterLevel()
	local ent = getent(self)
	return ent:WaterLevel()
end

--- Returns the ragdoll bone index given a bone name
-- @shared
-- @param name The bone's string name
-- @return The bone index
function ents_methods:lookupBone(name)
	checkluatype(name, TYPE_STRING)
	local ent = getent(self)
	return ent:LookupBone(name)
end

--- Returns the matrix of the entity's bone. Note: this method is slow/doesnt work well if the entity isn't animated.
-- @shared
-- @param bone Bone index. (def 0)
-- @return The matrix
function ents_methods:getBoneMatrix(bone)
	local ent = getent(self)
	if bone == nil then bone = 0 else checkluatype(bone, TYPE_NUMBER) end

	return mwrap(ent:GetBoneMatrix(bone))
end

--- Returns the world transform matrix of the entity
-- @shared
-- @return The matrix
function ents_methods:getMatrix()
	local ent = getent(self)
	return mwrap(ent:GetWorldTransformMatrix())
end

--- Returns the number of an entity's bones
-- @shared
-- @return Number of bones
function ents_methods:getBoneCount()
	local ent = getent(self)
	return ent:GetBoneCount()
end

--- Returns the name of an entity's bone
-- @shared
-- @param bone Bone index. (def 0)
-- @return Name of the bone
function ents_methods:getBoneName(bone)
	local ent = getent(self)
	if bone == nil then bone = 0 else checkluatype(bone, TYPE_NUMBER) end
	return ent:GetBoneName(bone)
end

--- Returns the parent index of an entity's bone
-- @shared
-- @param bone Bone index. (def 0)
-- @return Parent index of the bone
function ents_methods:getBoneParent(bone)
	local ent = getent(self)
	if bone == nil then bone = 0 else checkluatype(bone, TYPE_NUMBER) end
	return ent:GetBoneParent(bone)
end

--- Returns the bone's position and angle in world coordinates
-- @shared
-- @param bone Bone index. (def 0)
-- @return Position of the bone
-- @return Angle of the bone
function ents_methods:getBonePosition(bone)
	local ent = getent(self)
	if bone == nil then bone = 0 else checkluatype(bone, TYPE_NUMBER) end
	local pos, ang = ent:GetBonePosition(bone)
	return vwrap(pos), awrap(ang)
end

--- Returns the x, y, z size of the entity's outer bounding box (local to the entity)
-- @shared
-- @return The outer bounding box size
function ents_methods:obbSize()
	local ent = getent(self)
	return vwrap(ent:OBBMaxs() - ent:OBBMins())
end

--- Returns the local position of the entity's outer bounding box
-- @shared
-- @return The position vector of the outer bounding box center
function ents_methods:obbCenter()
	local ent = getent(self)
	return vwrap(ent:OBBCenter())
end

--- Returns the world position of the entity's outer bounding box
-- @shared
-- @return The position vector of the outer bounding box center
function ents_methods:obbCenterW()
	local ent = getent(self)
	return vwrap(ent:LocalToWorld(ent:OBBCenter()))
end

--- Returns min local bounding box vector of the entity
-- @shared
-- @return The min bounding box vector
function ents_methods:obbMins()
	local ent = getent(self)
	return vwrap(ent:OBBMins())
end

--- Returns max local bounding box vector of the entity
-- @shared
-- @return The max bounding box vector
function ents_methods:obbMaxs()
	local ent = getent(self)
	return vwrap(ent:OBBMaxs())
end

--- Returns Entity axis aligned bounding box in world coordinates
-- @shared
-- @return The min bounding box vector
-- @return The max bounding box vector
function ents_methods:worldSpaceAABB()
	local ent = getent(self)
	local a, b = ent:WorldSpaceAABB() 
	return vwrap(a), vwrap(b)
end

--- Returns the local position of the entity's mass center
-- @shared
-- @return The position vector of the mass center
function ents_methods:getMassCenter()
	local ent = getent(self)
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end
	return vwrap(phys:GetMassCenter())
end

--- Returns the world position of the entity's mass center
-- @shared
-- @return The position vector of the mass center
function ents_methods:getMassCenterW()
	local ent = getent(self)
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end
	return vwrap(ent:LocalToWorld(phys:GetMassCenter()))
end

--- Returns the angle of the entity
-- @shared
-- @return The angle
function ents_methods:getAngles()
	local ent = getent(self)
	return awrap(ent:GetAngles())
end

--- Returns the mass of the entity
-- @shared
-- @return The numerical mass
function ents_methods:getMass()
	local ent = getent(self)
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end

	return phys:GetMass()
end

--- Returns the principle moments of inertia of the entity
-- @shared
-- @return The principle moments of inertia as a vector
function ents_methods:getInertia()
	local ent = getent(self)
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end

	return vwrap(phys:GetInertia())
end

--- Returns the velocity of the entity
-- @shared
-- @return The velocity vector
function ents_methods:getVelocity()
	local ent = getent(self)
	return vwrap(ent:GetVelocity())
end

--- Returns the angular velocity of the entity
-- @shared
-- @return The angular velocity as a vector
function ents_methods:getAngleVelocity()
	local ent = getent(self)
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end
	return vwrap(phys:GetAngleVelocity())
end

--- Returns the angular velocity of the entity
-- @shared
-- @return The angular velocity as an angle
function ents_methods:getAngleVelocityAngle()
	local ent = getent(self)
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end
	local vec = phys:GetAngleVelocity()
	return awrap(Angle(vec.y, vec.z, vec.x))
end

--- Converts a vector in entity local space to world space
-- @shared
-- @param data Local space vector
-- @return data as world space vector
function ents_methods:localToWorld(data)
	local ent = getent(self)

	return vwrap(ent:LocalToWorld(vunwrap(data)))
end

--- Converts an angle in entity local space to world space
-- @shared
-- @param data Local space angle
-- @return data as world space angle
function ents_methods:localToWorldAngles(data)
	local ent = getent(self)
	local data = aunwrap(data)

	return awrap(ent:LocalToWorldAngles(data))
end

--- Converts a vector in world space to entity local space
-- @shared
-- @param data World space vector
-- @return data as local space vector
function ents_methods:worldToLocal(data)
	local ent = getent(self)

	return vwrap(ent:WorldToLocal(vunwrap(data)))
end

--- Converts an angle in world space to entity local space
-- @shared
-- @param data World space angle
-- @return data as local space angle
function ents_methods:worldToLocalAngles(data)
	local ent = getent(self)
	local data = aunwrap(data)

	return awrap(ent:WorldToLocalAngles(data))
end

--- Gets the animation number from the animation name
-- @param animation Name of the animation
-- @return Animation index or -1 if invalid
function ents_methods:lookupSequence(animation)
	local ent = getent(self)
	checkluatype(animation, TYPE_STRING)

	return ent:LookupSequence(animation)
end

--- Get the length of an animation
-- @param id (Optional) The id of the sequence, or will default to the currently playing sequence
-- @return Length of the animation in seconds
function ents_methods:sequenceDuration(id)
	local ent = getent(self)
	if id~=nil then checkluatype(id, TYPE_NUMBER) end

	return ent:SequenceDuration(id)
end

--- Set the pose value of an animation. Turret/Head angles for example.
-- @param pose Name of the pose parameter
-- @param value Value to set it to.
function ents_methods:setPose(pose, value)
	local ent = getent(self)
	checkpermission(instance, ent, "entities.setRenderProperty")

	ent:SetPoseParameter(pose, value)
end

--- Get the pose value of an animation
-- @param pose Pose parameter name
-- @return Value of the pose parameter
function ents_methods:getPose(pose)
	local ent = getent(self)
	return ent:GetPoseParameter(pose)
end

--- Returns a table of flexname -> flexid pairs for use in flex functions.
function ents_methods:getFlexes()
	local ent = getent(self)
	local flexes = {}
	for i = 0, ent:GetFlexNum()-1 do
		flexes[ent:GetFlexName(i)] = i
	end
	return flexes
end

--- Gets the weight (value) of a flex.
-- @param flexid The id of the flex
-- @return The weight of the flex
function ents_methods:getFlexWeight(flexid)
	local ent = getent(self)

	checkluatype(flexid, TYPE_NUMBER)
	flexid = math.floor(flexid)

	if flexid < 0 or flexid >= ent:GetFlexNum() then
		SF.Throw("Invalid flex: "..flexid, 2)
	end

	return ent:GetFlexWeight(flexid)
end

--- Sets the weight (value) of a flex.
-- @param flexid The id of the flex
-- @param weight The weight of the flex
function ents_methods:setFlexWeight(flexid, weight)
	local ent = getent(self)

	checkluatype(flexid, TYPE_NUMBER)
	checkluatype(weight, TYPE_NUMBER)
	flexid = math.floor(flexid)

	checkpermission(instance, ent, "entities.setRenderProperty")
	if flexid < 0 or flexid >= ent:GetFlexNum() then
		SF.Throw("Invalid flex: "..flexid, 2)
	end

	ent:SetFlexWeight(flexid, weight)
end

--- Gets the scale of the entity flexes
-- @return The scale of the flexes
function ents_methods:getFlexScale()
	local ent = getent(self)
	return ent:GetFlexScale()
end

--- Sets the scale of the entity flexes
-- @param scale The scale of the flexes to set
function ents_methods:setFlexScale(scale)
	local ent = getent(self)
	checkluatype(scale, TYPE_NUMBER)
	checkpermission(instance, ent, "entities.setRenderProperty")
	ent:SetFlexScale(scale)
end

--- Gets the model of an entity
-- @shared
-- @return Model of the entity
function ents_methods:getModel()
	local ent = getent(self)
	return ent:GetModel()
end

--- Gets the max health of an entity
-- @shared
-- @return Max Health of the entity
function ents_methods:getMaxHealth()
	local ent = getent(self)
	return ent:GetMaxHealth()
end

--- Gets the health of an entity
-- @shared
-- @return Health of the entity
function ents_methods:getHealth()
	local ent = getent(self)
	return ent:Health()
end

--- Gets the entitiy's eye angles
-- @shared
-- @return Angles of the entity's eyes
function ents_methods:getEyeAngles()
	local ent = getent(self)
	return awrap(ent:EyeAngles())
end

--- Gets the entity's eye position
-- @shared
-- @return Eye position of the entity
-- @return In case of a ragdoll, the position of the second eye
function ents_methods:getEyePos()
	local ent = getent(self)
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
function ents_methods:getMaterial()
	local ent = getent(self)
	return ent:GetMaterial() or ""
end

--- Gets an entities' submaterial
-- @shared
-- @class function
-- @return String material
function ents_methods:getSubMaterial(index)
	local ent = getent(self)
	return ent:GetSubMaterial(index) or ""
end

--- Gets an entities' material list
-- @shared
-- @class function
-- @return Material
function ents_methods:getMaterials()
	local ent = getent(self)
	return ent:GetMaterials() or {}
end

--- Gets the skin number of the entity
-- @shared
-- @return Skin number
function ents_methods:getSkin()
	local ent = getent(self)
	return ent:GetSkin()
end

--- Gets the entity's up vector
-- @shared
-- @return Vector up
function ents_methods:getUp()
	local ent = getent(self)
	return vwrap(ent:GetUp())
end

--- Gets the entity's right vector
-- @shared
-- @return Vector right
function ents_methods:getRight()
	local ent = getent(self)
	return vwrap(ent:GetRight())
end

--- Gets the entity's forward vector
-- @shared
-- @return Vector forward
function ents_methods:getForward()
	local ent = getent(self)
	return vwrap(ent:GetForward())
end

--- Returns the timer.curtime() time the entity was created on
-- @shared
-- @return Seconds relative to server map start
function ents_methods:getCreationTime()
	local ent = getent(self)
	return ent:GetCreationTime()
end

end
