-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege
local dgetmeta = debug.getmetatable
local ENT_META,NB_META,NPC_META,PHYS_META,PLY_META,VEH_META,WEP_META = FindMetaTable("Entity"),FindMetaTable("NextBot"),FindMetaTable("NPC"),FindMetaTable("PhysObj"),FindMetaTable("Player"),FindMetaTable("Vehicle"),FindMetaTable("Weapon")
local Ent_ManipulateBoneAngles,Ent_ManipulateBoneJiggle,Ent_ManipulateBonePosition,Ent_ManipulateBoneScale = ENT_META.ManipulateBoneAngles,ENT_META.ManipulateBoneJiggle,ENT_META.ManipulateBonePosition,ENT_META.ManipulateBoneScale

registerprivilege("entities.setParent", "Parent", "Allows the user to parent an entity to another entity", { entities = {} })
registerprivilege("entities.setRenderProperty", "RenderProperty", "Allows the user to change the rendering of an entity", { client = (CLIENT and {} or nil), entities = {} })
registerprivilege("entities.setPlayerRenderProperty", "PlayerRenderProperty", "Allows the user to change the rendering of themselves", {})
registerprivilege("entities.setPersistent", "SetPersistent", "Allows the user to change entity's persistent state", { entities = {} })
registerprivilege("entities.emitSound", "Emitsound", "Allows the user to play sounds on entities", { client = (CLIENT and {} or nil), entities = {} })
registerprivilege("entities.setHealth", "SetHealth", "Allows the user to change an entity's health", { entities = {} })
registerprivilege("entities.setMaxHealth", "SetMaxHealth", "Allows the user to change an entity's max health", { entities = {} })
registerprivilege("entities.doNotDuplicate", "DoNotDuplicate", "Allows the user to set whether an entity will be saved on dupes or map saves", { entities = {} })


local emitSoundBurst = SF.BurstObject("emitSound", "emitsound", 180, 200, " sounds can be emitted per second", "Number of sounds that can be emitted in a short time")

local manipulateBoneBurst
local manipulations = SF.EntityTable("boneManipulations")

if SERVER then
	manipulateBoneBurst = SF.BurstObject("manipulateBone", "manipulateBone", 60, 20, "Rate bones can be manipulated per second.", "Amount of manipulations that can happen in a short time")
end

getmetatable(manipulations).__index = function(t, k) local r = {Position = {}, Scale = {}, Angle = {}, Jiggle = {}} t[k] = r return r end

hook.Add("PAC3ResetBones","SF_BoneManipulations",function(ent)
	local manips = manipulations[ent]
	if manips then
		for bone, v in pairs(manips.Position) do
			Ent_ManipulateBonePosition(ent, bone, v)
		end
		for bone, v in pairs(manips.Scale) do
			Ent_ManipulateBoneScale(ent, bone, v)
		end
		for bone, v in pairs(manips.Angle) do
			Ent_ManipulateBoneAngles(ent, bone, v)
		end
		for bone, v in pairs(manips.Jiggle) do
			Ent_ManipulateBoneJiggle(ent, bone, v)
		end
	end
end)


--- Entity type
-- @name Entity
-- @class type
-- @libtbl ents_methods
-- @libtbl ent_meta
SF.RegisterType("Entity", false, true, ENT_META)


return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end
local Ent_BoundingRadius,Ent_DrawModel,Ent_EmitSound,Ent_EntIndex,Ent_EyeAngles,Ent_EyePos,Ent_FindBodygroupByName,Ent_GetAngles,Ent_GetAttachment,Ent_GetAttachments,Ent_GetBodygroup,Ent_GetBodygroupCount,Ent_GetBodygroupName,Ent_GetBodyGroups,Ent_GetBoneCount,Ent_GetBoneMatrix,Ent_GetBoneName,Ent_GetBoneParent,Ent_GetBonePosition,Ent_GetBrushPlane,Ent_GetBrushPlaneCount,Ent_GetBrushSurfaces,Ent_GetChildren,Ent_GetClass,Ent_GetCollisionBounds,Ent_GetCollisionGroup,Ent_GetColor,Ent_GetColor4Part,Ent_GetCreationTime,Ent_GetDTAngle,Ent_GetDTBool,Ent_GetDTEntity,Ent_GetDTFloat,Ent_GetDTInt,Ent_GetDTString,Ent_GetDTVector,Ent_GetElasticity,Ent_GetFlexIDByName,Ent_GetFlexName,Ent_GetFlexNum,Ent_GetFlexScale,Ent_GetFlexWeight,Ent_GetForward,Ent_GetHitBoxBone,Ent_GetHitBoxBounds,Ent_GetHitBoxCount,Ent_GetHitBoxHitGroup,Ent_GetHitboxSet,Ent_GetHitboxSetCount,Ent_GetInternalVariable,Ent_GetLocalAngles,Ent_GetLocalPos,Ent_GetManipulateBoneAngles,Ent_GetManipulateBoneJiggle,Ent_GetManipulateBonePosition,Ent_GetManipulateBoneScale,Ent_GetMaterial,Ent_GetMaterials,Ent_GetMaxHealth,Ent_GetModel,Ent_GetModelBounds,Ent_GetModelContents,Ent_GetModelRadius,Ent_GetModelRenderBounds,Ent_GetModelScale,Ent_GetMoveType,Ent_GetNoDraw,Ent_GetNumPoseParameters,Ent_GetNWEntity,Ent_GetNWVarTable,Ent_GetOwner,Ent_GetParent,Ent_GetParentAttachment,Ent_GetPersistent,Ent_GetPhysicsObject,Ent_GetPhysicsObjectCount,Ent_GetPhysicsObjectNum,Ent_GetPos,Ent_GetPoseParameter,Ent_GetPoseParameterName,Ent_GetPoseParameterRange,Ent_GetRenderFX,Ent_GetRenderGroup,Ent_GetRenderMode,Ent_GetRight,Ent_GetRotatedAABB,Ent_GetSaveTable,Ent_GetSequence,Ent_GetSequenceCount,Ent_GetSequenceInfo,Ent_GetSequenceList,Ent_GetSequenceName,Ent_GetSkin,Ent_GetSolid,Ent_GetSolidFlags,Ent_GetSubMaterial,Ent_GetTable,Ent_GetUp,Ent_GetVelocity,Ent_GetWorldTransformMatrix,Ent_HasFlexManipulatior,Ent_Health,Ent_IsDormant,Ent_IsEffectActive,Ent_IsOnFire,Ent_IsOnGround,Ent_IsSequenceFinished,Ent_IsSolid,Ent_IsValid,Ent_IsWorld,Ent_LocalToWorld,Ent_LocalToWorldAngles,Ent_LookupAttachment,Ent_LookupBone,Ent_LookupPoseParameter,Ent_LookupSequence,Ent_MapCreationID,Ent_NearestPoint,Ent_OBBCenter,Ent_OBBMaxs,Ent_OBBMins,Ent_SequenceDuration,Ent_SetBodygroup,Ent_SetBoneMatrix,Ent_SetColor,Ent_SetColor4Part,Ent_SetFlexScale,Ent_SetFlexWeight,Ent_SetHealth,Ent_SetLOD,Ent_SetMaterial,Ent_SetMaxHealth,Ent_SetNoDraw,Ent_SetPersistent,Ent_SetPoseParameter,Ent_SetRenderBounds,Ent_SetRenderFX,Ent_SetRenderMode,Ent_SetSkin,Ent_SetSubMaterial,Ent_SetupBones,Ent_SkinCount,Ent_StopSound,Ent_TranslateBoneToPhysBone,Ent_TranslatePhysBoneToBone,Ent_WaterLevel,Ent_WorldSpaceAABB,Ent_WorldToLocal,Ent_WorldToLocalAngles = ENT_META.BoundingRadius,ENT_META.DrawModel,ENT_META.EmitSound,ENT_META.EntIndex,ENT_META.EyeAngles,ENT_META.EyePos,ENT_META.FindBodygroupByName,ENT_META.GetAngles,ENT_META.GetAttachment,ENT_META.GetAttachments,ENT_META.GetBodygroup,ENT_META.GetBodygroupCount,ENT_META.GetBodygroupName,ENT_META.GetBodyGroups,ENT_META.GetBoneCount,ENT_META.GetBoneMatrix,ENT_META.GetBoneName,ENT_META.GetBoneParent,ENT_META.GetBonePosition,ENT_META.GetBrushPlane,ENT_META.GetBrushPlaneCount,ENT_META.GetBrushSurfaces,ENT_META.GetChildren,ENT_META.GetClass,ENT_META.GetCollisionBounds,ENT_META.GetCollisionGroup,ENT_META.GetColor,ENT_META.GetColor4Part,ENT_META.GetCreationTime,ENT_META.GetDTAngle,ENT_META.GetDTBool,ENT_META.GetDTEntity,ENT_META.GetDTFloat,ENT_META.GetDTInt,ENT_META.GetDTString,ENT_META.GetDTVector,ENT_META.GetElasticity,ENT_META.GetFlexIDByName,ENT_META.GetFlexName,ENT_META.GetFlexNum,ENT_META.GetFlexScale,ENT_META.GetFlexWeight,ENT_META.GetForward,ENT_META.GetHitBoxBone,ENT_META.GetHitBoxBounds,ENT_META.GetHitBoxCount,ENT_META.GetHitBoxHitGroup,ENT_META.GetHitboxSet,ENT_META.GetHitboxSetCount,ENT_META.GetInternalVariable,ENT_META.GetLocalAngles,ENT_META.GetLocalPos,ENT_META.GetManipulateBoneAngles,ENT_META.GetManipulateBoneJiggle,ENT_META.GetManipulateBonePosition,ENT_META.GetManipulateBoneScale,ENT_META.GetMaterial,ENT_META.GetMaterials,ENT_META.GetMaxHealth,ENT_META.GetModel,ENT_META.GetModelBounds,ENT_META.GetModelContents,ENT_META.GetModelRadius,ENT_META.GetModelRenderBounds,ENT_META.GetModelScale,ENT_META.GetMoveType,ENT_META.GetNoDraw,ENT_META.GetNumPoseParameters,ENT_META.GetNWEntity,ENT_META.GetNWVarTable,ENT_META.GetOwner,ENT_META.GetParent,ENT_META.GetParentAttachment,ENT_META.GetPersistent,ENT_META.GetPhysicsObject,ENT_META.GetPhysicsObjectCount,ENT_META.GetPhysicsObjectNum,ENT_META.GetPos,ENT_META.GetPoseParameter,ENT_META.GetPoseParameterName,ENT_META.GetPoseParameterRange,ENT_META.GetRenderFX,ENT_META.GetRenderGroup,ENT_META.GetRenderMode,ENT_META.GetRight,ENT_META.GetRotatedAABB,ENT_META.GetSaveTable,ENT_META.GetSequence,ENT_META.GetSequenceCount,ENT_META.GetSequenceInfo,ENT_META.GetSequenceList,ENT_META.GetSequenceName,ENT_META.GetSkin,ENT_META.GetSolid,ENT_META.GetSolidFlags,ENT_META.GetSubMaterial,ENT_META.GetTable,ENT_META.GetUp,ENT_META.GetVelocity,ENT_META.GetWorldTransformMatrix,ENT_META.HasFlexManipulatior,ENT_META.Health,ENT_META.IsDormant,ENT_META.IsEffectActive,ENT_META.IsOnFire,ENT_META.IsOnGround,ENT_META.IsSequenceFinished,ENT_META.IsSolid,ENT_META.IsValid,ENT_META.IsWorld,ENT_META.LocalToWorld,ENT_META.LocalToWorldAngles,ENT_META.LookupAttachment,ENT_META.LookupBone,ENT_META.LookupPoseParameter,ENT_META.LookupSequence,ENT_META.MapCreationID,ENT_META.NearestPoint,ENT_META.OBBCenter,ENT_META.OBBMaxs,ENT_META.OBBMins,ENT_META.SequenceDuration,ENT_META.SetBodygroup,ENT_META.SetBoneMatrix,ENT_META.SetColor,ENT_META.SetColor4Part,ENT_META.SetFlexScale,ENT_META.SetFlexWeight,ENT_META.SetHealth,ENT_META.SetLOD,ENT_META.SetMaterial,ENT_META.SetMaxHealth,ENT_META.SetNoDraw,ENT_META.SetPersistent,ENT_META.SetPoseParameter,ENT_META.SetRenderBounds,ENT_META.SetRenderFX,ENT_META.SetRenderMode,ENT_META.SetSkin,ENT_META.SetSubMaterial,ENT_META.SetupBones,ENT_META.SkinCount,ENT_META.StopSound,ENT_META.TranslateBoneToPhysBone,ENT_META.TranslatePhysBoneToBone,ENT_META.WaterLevel,ENT_META.WorldSpaceAABB,ENT_META.WorldToLocal,ENT_META.WorldToLocalAngles
local function Ent_IsNextBot(ent) return dgetmeta(ent)==NB_META end
local function Ent_IsNPC(ent) return dgetmeta(ent)==NPC_META end
local function Ent_IsPlayer(ent) return dgetmeta(ent)==PLY_META end
local function Ent_IsVehicle(ent) return dgetmeta(ent)==VEH_META end
local function Ent_IsWeapon(ent) return dgetmeta(ent)==WEP_META end

local Phys_GetAngleVelocity,Phys_GetInertia,Phys_GetMass,Phys_GetMassCenter,Phys_IsValid,Phys_LocalToWorldVector,Phys_WorldToLocalVector = PHYS_META.GetAngleVelocity,PHYS_META.GetInertia,PHYS_META.GetMass,PHYS_META.GetMassCenter,PHYS_META.IsValid,PHYS_META.LocalToWorldVector,PHYS_META.WorldToLocalVector

local owrap, ounwrap = instance.WrapObject, instance.UnwrapObject
local ents_methods, ent_meta, ewrap, eunwrap = instance.Types.Entity.Methods, instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local col_meta, cwrap, cunwrap = instance.Types.Color, instance.Types.Color.Wrap, instance.Types.Color.Unwrap
local phys_meta, pwrap, punwrap = instance.Types.PhysObj, instance.Types.PhysObj.Wrap, instance.Types.PhysObj.Unwrap
local mtx_meta, mwrap, munwrap = instance.Types.VMatrix, instance.Types.VMatrix.Wrap, instance.Types.VMatrix.Unwrap
local plywrap = instance.Types.Player.Wrap
local swrap, sunwrap = instance.Types.SurfaceInfo.Wrap, instance.Types.SurfaceInfo.Unwrap

local vunwrap1, vunwrap2
local aunwrap1
instance:AddHook("initialize", function()
	vunwrap1, vunwrap2 = vec_meta.QuickUnwrap1, vec_meta.QuickUnwrap2
	aunwrap1 = ang_meta.QuickUnwrap1
end)

local function getent(self)
	local ent = ent_meta.sf2sensitive[self]
	if Ent_IsValid(ent) or Ent_IsWorld(ent) then
		return ent
	else
		SF.Throw("Entity is not valid.", 3)
	end
end
instance.Types.Entity.GetEntity = getent

--- Gets the string representation of the entity
-- @return string String representation of the entity
function ent_meta:__tostring()
	local ent = eunwrap(self)
	return Ent_IsValid(ent) and tostring(ent) or "(null entity)"
end

-- ------------------------- Methods ------------------------- --

--- Gets the owner of the entity
-- @return Entity? Owner or nil if no owner
function ents_methods:getOwner()
	local ent = getent(self)

	if SF.Permissions.getOwner then
		return plywrap(SF.Permissions.getOwner(ent))
	end
end

if CLIENT then
	instance.object_wrappers[FindMetaTable("NextBot")] = ewrap

	--- Sets a hologram or custom_prop model to a custom Mesh
	-- @client
	-- @param Mesh? mesh The mesh to set it to or nil to set back to normal
	function ents_methods:setMesh(mesh)
		local ent = getent(self)
		local ent_tbl = Ent_GetTable(ent)
		if not ent_tbl.IsSFHologram and not ent_tbl.IsSFProp then SF.Throw("The entity isn't a hologram or custom-prop", 2) end

		checkpermission(instance, nil, "mesh")
		checkpermission(instance, ent, "entities.setRenderProperty")
		if mesh then
			ent_tbl.custom_mesh = instance.Types.Mesh.Unwrap(mesh)
			ent_tbl.custom_mesh_data = instance.data.meshes
		else
			ent_tbl.custom_mesh = nil
		end
	end

	--- Sets a hologram or custom_prop's custom mesh material
	-- @client
	-- @param Material? material The material to set it to or nil to set back to default
	function ents_methods:setMeshMaterial(material)
		local ent = getent(self)
		local ent_tbl = Ent_GetTable(ent)
		if not ent_tbl.IsSFHologram and not ent_tbl.IsSFProp then SF.Throw("The entity isn't a hologram or custom-prop", 2) end

		checkpermission(instance, ent, "entities.setRenderProperty")

		if material then
			ent_tbl.Material = instance.Types.LockedMaterial.Unwrap(material)
		else
			ent_tbl.Material = ent_tbl.DefaultMaterial
		end
	end

	local playerColorWhitelist = {
		["prop_ragdoll"]       = true,
		["starfall_cnextbot"]  = true,
		["starfall_hologram"]  = true,
		["gmod_wire_hologram"] = true,
	}
	--- Sets the sheet color of a player-model
	-- Can only be used on players, bots, ragdolls, holograms and Starfall NextBots
	-- @client
	-- @param Color clr RGB color to use, alpha channel not supported
	function ents_methods:setSheetColor(clr)
		local ent = getent(self)
		checkpermission(instance, ent, "entities.setRenderProperty")
		clr = cunwrap(clr)
		local vec = Vector(clr.r / 255, clr.g / 255, clr.b / 255)

		if Ent_IsPlayer(ent) then
			Ent_GetTable(ent).SetPlayerColor(ent, vec)
		elseif playerColorWhitelist[Ent_GetClass(ent)] then
			Ent_GetTable(ent).GetPlayerColor = function() return vec end
		else
			SF.Throw("The entity isn't whitelisted", 2)
		end
	end

	--- Sets a hologram or custom_prop's renderbounds
	-- @client
	-- @param Vector mins The lower bounding corner coordinate local to the hologram
	-- @param Vector maxs The upper bounding corner coordinate local to the hologram
	function ents_methods:setRenderBounds(mins, maxs)
		local ent = getent(self)
		local ent_tbl = Ent_GetTable(ent)
		if not ent_tbl.IsSFHologram and not ent_tbl.IsSFProp then SF.Throw("The entity isn't a hologram or custom-prop", 2) end

		checkpermission(instance, ent, "entities.setRenderProperty")

		mins, maxs = vunwrap(mins), vunwrap(maxs)
		Ent_SetRenderBounds(ent, mins, maxs)
		ent_tbl.sf_userrenderbounds = {mins, maxs}
	end

	--- Returns render bounds of the entity as local vectors
	-- If the render bounds are not inside players view, the entity will not be drawn!
	-- @client
	-- @return Vector The minimum vector of the bounds
	-- @return Vector The maximum vector of the bounds
	function ents_methods:getRenderBounds()
		local mins, maxs = getent(self):GetRenderBounds()
		return vwrap(mins), vwrap(maxs)
	end

	--- Sets the Level Of Detail model to use with this entity. This may not work for all models if the model doesn't include any LOD sub models.
	-- This function works exactly like the clientside r_lod convar and takes priority over it.
	-- -1 leaves the engine to automatically set the Level of Detail. The Level Of Detail may range from 0 to 8, with 0 being the highest quality and 8 the lowest.
	-- @client
	-- @param number lod The Level Of Detail model ID to use.
	function ents_methods:setLOD(num)
		local ent = getent(self)
		checkluatype(num, TYPE_NUMBER)
		checkpermission(instance, ent, "entities.setRenderProperty")
		Ent_SetLOD(ent, math.Clamp(num, 0, 8))
	end

	local canDrawEntity = SF.CanDrawEntity
	--- Returns whether or not the entity can be drawn using Entity.draw function
	-- Checks Entity against a predefined class whitelist
	-- Entities that have RenderOverride defined or are parented cannot be drawn
	-- @client
	-- @return boolean Whether the entity can be drawn
	function ents_methods:canDraw()
		return canDrawEntity(getent(self))
	end

	--- Draws the entity, requires 3D rendering context
	-- Only certain, whitelisted entities can be drawn. They can't be parented or have RenderOverride defined
	-- Use Entity.canDraw to check if you can draw the entity
	-- @client
	function ents_methods:draw()
		if not instance.data.render.isRendering then SF.Throw("Not in rendering hook.", 2) end

		local ent = getent(self)
		if not canDrawEntity(ent) then SF.Throw("Can't draw this entity.", 2) end
		Ent_SetupBones(ent)
		Ent_DrawModel(ent)
	end

	--- Returns the render group of the entity.
	-- @client
	-- @return number Render group
	function ents_methods:getRenderGroup()
		return Ent_GetRenderGroup(getent(self))
	end
end

local soundsByEntity = SF.EntityTable("emitSoundsByEntity", function(e, t)
	for snd, _ in pairs(t) do
		Ent_StopSound(e, snd)
	end
end, true)

local sound_library = instance.Libraries.sound

if sound_library then
	--- Returns if a sound is able to be emitted from an entity
	-- @return boolean If it is possible to emit a sound
	function sound_library.canEmitSound()
		return emitSoundBurst:check(instance.player) >= 1
	end

	--- Returns the number of sound emits left
	-- @return number The number of sounds left
	function sound_library:emitSoundsLeft()
		return emitSoundBurst:check(instance.player)
	end
end

--- Plays a sound on the entity
-- @param string snd Sound path
-- @param number soundLevel Default 75
-- @param number pitchPercent Default 100
-- @param number volume Default 1
-- @param number channel Default CHAN_AUTO or CHAN_WEAPON for weapons
function ents_methods:emitSound(snd, lvl, pitch, volume, channel)
	checkluatype(snd, TYPE_STRING)
	SF.CheckSound(instance.player, snd)

	local ent = getent(self)
	checkpermission(instance, ent, "entities.emitSound")
	emitSoundBurst:use(instance.player, 1)

	local snds = soundsByEntity[ent]
	if not snds then snds = {} soundsByEntity[ent] = snds end
	snds[snd] = true
	Ent_EmitSound(ent, snd, lvl, pitch, volume, channel)
end

--- Stops a sound on the entity
-- @param string snd string Soundscript path. See http://wiki.facepunch.com/gmod/Entity:StopSound
function ents_methods:stopSound(snd)
	checkluatype(snd, TYPE_STRING)

	local ent = getent(self)
	checkpermission(instance, ent, "entities.emitSound")

	if soundsByEntity[ent] then
		soundsByEntity[ent][snd] = nil
	end

	Ent_StopSound(ent, snd)
end

--- Returns a list of components linked to a processor. Can also return vehicles linked to a HUD, but only through the server.
-- @return table A list of components linked to the entity
function ents_methods:getLinkedComponents()
	local ent = getent(self)
	local list = {}
	if Ent_GetClass(ent) == "starfall_processor" then
		for k, v in ipairs(ents.FindByClass("starfall_screen")) do
			if Ent_GetTable(v).link == ent then list[#list+1] = ewrap(v) end
		end
		for k, v in ipairs(ents.FindByClass("starfall_hud")) do
			if Ent_GetTable(v).link == ent then list[#list+1] = ewrap(v) end
		end
	elseif Ent_GetClass(ent) == "starfall_hud" then
		if SERVER then
			for k, huds in pairs(SF.HudVehicleLinks) do if huds[ent] then list[#list+1] = owrap(k) end end
		else
			SF.Throw("You may only get starfall_hud links through the server", 2)
		end
	else
		SF.Throw("The target must be a starfall_processor or starfall_hud", 2)
	end

	return list
end

--- Parents or unparents an entity. Only holograms can be parented to players and clientside holograms can only be parented in the CLIENT realm.
-- @param Entity? parent Entity parent (nil to unparent)
-- @param number|string|nil attachment Optional attachment name or ID.
-- @param number|string|nil bone Optional bone name or ID. Can't be used at the same time as attachment
function ents_methods:setParent(parent, attachment, bone)
	local child = getent(self)
	checkpermission(instance, child, "entities.setParent")
	if CLIENT and dgetmeta(child) ~= SF.Cl_Hologram_Meta then SF.Throw("Only clientside holograms can be parented in the CLIENT realm!", 2) end
	if attachment ~= nil and bone ~= nil then SF.Throw("Arguments `attachment` and `bone` are mutually exclusive!", 2) end
	if parent ~= nil then
		parent = getent(parent)
		if Ent_IsPlayer(parent) and not Ent_GetTable(child).IsSFHologram then SF.Throw("Only holograms can be parented to players!", 2) end
		local param, type
		if bone ~= nil then
			if isstring(bone) then
				bone = Ent_LookupBone(parent, bone) or -1
			elseif not isnumber(bone) then
				SF.ThrowTypeError("string or number", SF.GetType(bone), 2)
			end
			if bone < 0 or bone > 255 then SF.Throw("Invalid bone provided!", 2) end
			type = "bone"
			param = bone
		elseif attachment ~= nil then
			if CLIENT then SF.Throw("Parenting to an attachment is not supported in clientside!", 2) end
			if isstring(attachment) then
				if Ent_LookupAttachment(parent, attachment) < 1 then SF.Throw("Invalid attachment provided!", 2) end
			elseif isnumber(attachment) then
				local attachments = Ent_GetAttachments(parent)
				if attachments and attachments[attachment] then
					attachment = attachments[attachment].name
				else
					SF.Throw("Invalid attachment ID provided!", 2)
				end
			else
				SF.ThrowTypeError("string or number", SF.GetType(attachment), 2)
			end
			type = "attachment"
			param = attachment
		else
			type = "entity"
		end

		SF.Parent(child, parent, type, param)
	else
		SF.Parent(child)
	end
end

if SERVER then
	local props_library = instance.Libraries.prop
	if props_library then
		--- Checks if a user can manipulate anymore bones. 
		-- @server
		-- @return boolean True if user can manipulate bones, False if not.
		function props_library.canManipulateBones()
			return manipulateBoneBurst:check(instance.player) >= 1
		end

		--- Returns the current number of calls to bone manipuation functions the player is allowed
		-- @server
		-- @return number Amount of manipulate bones calls remaining
		function props_library.manipulateBonesLeft()
			return manipulateBoneBurst:check(instance.player)
		end

		--- Returns how many bone manipulations per second the user can do
		-- @server
		-- @return number Number of props per second the user can spawn
		function props_library.manipulateBonesRate()
			return manipulateBoneBurst.rate
		end
	end
end

--- Allows manipulation of an entity's bones' positions
-- @shared
-- @param number bone The bone ID
-- @param Vector vec The position it should be manipulated to
function ents_methods:manipulateBonePosition(bone, vec)
	local ent = getent(self)
	checkluatype(bone, TYPE_NUMBER)
	bone = math.floor(bone)
	if bone<0 or bone>=Ent_GetBoneCount(ent) then SF.Throw("Invalid bone "..bone, 2) end

	vec = vunwrap1(vec)
	checkpermission(instance, ent, "entities.setRenderProperty")

	if SERVER then
		manipulateBoneBurst:use(instance.player, 1)
	end

	if vec ~= vector_origin then
		local manip = manipulations[ent].Position
		if manip[bone] then manip[bone]:Set(vec) else manip[bone] = Vector(vec) end
	else
		manipulations[ent].Position[bone] = nil
	end

	Ent_ManipulateBonePosition(ent, bone, vec)
end

--- Allows manipulation of an entity's bones' scale
-- @shared
-- @param number bone The bone ID
-- @param Vector vec The scale it should be manipulated to
function ents_methods:manipulateBoneScale(bone, vec)
	local ent = getent(self)
	checkluatype(bone, TYPE_NUMBER)
	bone = math.floor(bone)
	if bone<0 or bone>=Ent_GetBoneCount(ent) then SF.Throw("Invalid bone "..bone, 2) end

	vec = vunwrap1(vec)
	checkpermission(instance, ent, "entities.setRenderProperty")
	
	if SERVER then
		manipulateBoneBurst:use(instance.player, 1)
	end

	if vec ~= vector_origin then
		local manip = manipulations[ent].Scale
		if manip[bone] then manip[bone]:Set(vec) else manip[bone] = Vector(vec) end
	else
		manipulations[ent].Scale[bone] = nil
	end

	Ent_ManipulateBoneScale(ent, bone, vec)
end

--- Allows manipulation of an entity's bones' angles
-- @shared
-- @param number bone The bone ID
-- @param Angle ang The angle it should be manipulated to
function ents_methods:manipulateBoneAngles(bone, ang)
	local ent = getent(self)
	checkluatype(bone, TYPE_NUMBER)
	bone = math.floor(bone)
	if bone<0 or bone>=Ent_GetBoneCount(ent) then SF.Throw("Invalid bone "..bone, 2) end

	ang = aunwrap1(ang)
	checkpermission(instance, ent, "entities.setRenderProperty")

	if SERVER then
		manipulateBoneBurst:use(instance.player, 1)
	end

	if ang[1]~=0 or ang[2]~=0 or ang[3]~=0 then
		local manip = manipulations[ent].Angle
		if manip[bone] then manip[bone]:Set(ang) else manip[bone] = Angle(ang) end
	else
		manipulations[ent].Angle[bone] = nil
	end

	Ent_ManipulateBoneAngles(ent, bone, ang)
end

--- Allows manipulation of an entity's bones' jiggle status
-- @shared
-- @param number bone The bone ID
-- @param boolean enabled Whether to make the bone jiggly or not
function ents_methods:manipulateBoneJiggle(bone, state)
	local ent = getent(self)
	checkluatype(bone, TYPE_NUMBER)
	bone = math.floor(bone)
	if bone<0 or bone>=Ent_GetBoneCount(ent) then SF.Throw("Invalid bone "..bone, 2) end

	checkluatype(state, TYPE_BOOL)
	checkpermission(instance, ent, "entities.setRenderProperty")

	if SERVER then
		manipulateBoneBurst:use(instance.player, 1)
	end

	state = state and 1 or 0
	manipulations[ent].Jiggle[bone] = state

	Ent_ManipulateBoneJiggle(ent, bone, state)
end

--- Sets the color of the entity
-- @shared
-- @param Color clr New color
function ents_methods:setColor(clr)
	local ent = getent(self)
	if SERVER and ent == instance.player then
		checkpermission(instance, ent, "entities.setPlayerRenderProperty")
	else
		checkpermission(instance, ent, "entities.setRenderProperty")
	end

	local r,g,b,a = tonumber(clr.r) or 255, tonumber(clr.g) or 255, tonumber(clr.b) or 255, tonumber(clr.a) or 255
	local rendermode = (a == 255 and RENDERMODE_NORMAL or RENDERMODE_TRANSALPHA)
	Ent_SetColor4Part(ent, r, g, b, a)
	Ent_SetRenderMode(ent, rendermode)
	if SERVER then duplicator.StoreEntityModifier(ent, "colour", { Color = {r = r, g = g, b = b, a = a}, RenderMode = rendermode }) end
end

--- Sets the color of the entity
-- @shared
-- @param number r Red 0 - 255
-- @param number g Green 0 - 255
-- @param number b Blue 0 - 255
-- @param number a Alpha 0 - 255
function ents_methods:setColor4Part(r,g,b,a)
	local ent = getent(self)
	if SERVER and ent == instance.player then
		checkpermission(instance, ent, "entities.setPlayerRenderProperty")
	else
		checkpermission(instance, ent, "entities.setRenderProperty")
	end

	r,g,b,a = tonumber(r) or 255, tonumber(g) or 255, tonumber(b) or 255, tonumber(a) or 255
	local rendermode = (a == 255 and RENDERMODE_NORMAL or RENDERMODE_TRANSALPHA)
	Ent_SetColor4Part(ent, r, g, b, a)
	Ent_SetRenderMode(ent, rendermode)
	if SERVER then duplicator.StoreEntityModifier(ent, "colour", { Color = {r = r, g = g, b = b, a = a}, RenderMode = rendermode }) end
end

--- Sets the whether an entity should be drawn or not. If serverside, will also prevent networking the entity to the client. Don't use serverside on a starfall if you want its client code to work.
-- @shared
-- @param boolean draw Whether to draw the entity or not.
function ents_methods:setNoDraw(draw)
	local ent = getent(self)
	checkpermission(instance, ent, "entities.setRenderProperty")

	Ent_SetNoDraw(ent, draw and true or false)
end

--- Checks whether the entity should be drawn
-- @shared
-- @return boolean True if should draw, False otherwise
function ents_methods:getNoDraw()
	return Ent_GetNoDraw(getent(self))
end

--- Sets the material of the entity
-- @shared
-- @param string material New material name.
function ents_methods:setMaterial(material)
	checkluatype(material, TYPE_STRING)
	if SF.CheckMaterial(material) == false then SF.Throw("This material is invalid", 2) end

	local ent = getent(self)
	if SERVER and ent == instance.player then
		checkpermission(instance, ent, "entities.setPlayerRenderProperty")
	else
		checkpermission(instance, ent, "entities.setRenderProperty")
	end

	Ent_SetMaterial(ent, material)
	if SERVER then duplicator.StoreEntityModifier(ent, "material", { MaterialOverride = material }) end
end

--- Sets the submaterial of the entity
-- @shared
-- @param number index Submaterial index.
-- @param string material New material name.
function ents_methods:setSubMaterial(index, material)
	checkluatype(index, TYPE_NUMBER)
	index = math.Clamp(index, 0, 255)

	checkluatype(material, TYPE_STRING)
	if SF.CheckMaterial(material) == false then SF.Throw("This material is invalid", 2) end

	local ent = getent(self)
	if SERVER and ent == instance.player then
		checkpermission(instance, ent, "entities.setPlayerRenderProperty")
	else
		checkpermission(instance, ent, "entities.setRenderProperty")
	end

	Ent_SetSubMaterial(ent, index, material)
	if SERVER then
		duplicator.StoreEntityModifier( ent, "submaterial", {["SubMaterialOverride_"..index] = material} )
	end
end

-- Invalid bodygroup IDs can cause crashes, so it's necessary to check that they are within range.
local checkbodygroup
do
	local maxid = 2^31-1 -- Maximum signed 32-bit integer ("long") value
	local minid = 0 -- One can go lower, but there's no point since the negative indexes are never used.
	function checkbodygroup(id)
		if id < minid or id > maxid then
			SF.Throw("invalid bodygroup id", 3)
		end
	end
	SF.CheckBodygroup = checkbodygroup
end

--- Sets the bodygroup of the entity
-- @shared
-- @param number bodygroup The ID of the bodygroup you're setting.
-- @param number value The value you're setting the bodygroup to.
function ents_methods:setBodygroup(bodygroup, value)
	checkluatype(bodygroup, TYPE_NUMBER)
	checkbodygroup(bodygroup)
	checkluatype(value, TYPE_NUMBER)

	local ent = getent(self)
	if SERVER and ent == instance.player then
		checkpermission(instance, ent, "entities.setPlayerRenderProperty")
	else
		checkpermission(instance, ent, "entities.setRenderProperty")
	end

	Ent_SetBodygroup(ent, bodygroup, value)
end

--- Returns the bodygroup value of the entity with given index
-- @shared
-- @param number id The bodygroup's number index
-- @return number The bodygroup value
function ents_methods:getBodygroup(id)
	checkluatype(id, TYPE_NUMBER)
	checkbodygroup(id)
	return Ent_GetBodygroup(getent(self), id)
end

--- Returns a list of all bodygroups of the entity
-- @shared
-- @return table Bodygroups as a table of BodyGroupDatas. https://wiki.facepunch.com/gmod/Structures/BodyGroupData
function ents_methods:getBodygroups()
	return Ent_GetBodyGroups(getent(self))
end

--- Returns the bodygroup index of the entity with given name
-- @shared
-- @param string name The bodygroup's string name
-- @return number The bodygroup index
function ents_methods:lookupBodygroup(name)
	checkluatype(name, TYPE_STRING)
	return Ent_FindBodygroupByName(getent(self), name)
end

--- Returns the bodygroup name of the entity with given index
-- @shared
-- @param number id The bodygroup's number index
-- @return string The bodygroup name
function ents_methods:getBodygroupName(id)
	checkluatype(id, TYPE_NUMBER)
	checkbodygroup(id)
	return Ent_GetBodygroupName(getent(self), id)
end

--- Returns the number of possible values for this bodygroup.
-- Note that bodygroups are 0-indexed, so this will not return the maximum allowed value.
-- @param number id The ID of the bodygroup to get the count for.
-- @return number Number of values of specified bodygroup, or 0 if there are none.
function ents_methods:getBodygroupCount(id)
	checkluatype(id, TYPE_NUMBER)
	checkbodygroup(id)
	return Ent_GetBodygroupCount(getent(self), id)
end

--- Sets the skin of the entity
-- @shared
-- @param number skinIndex Index of the skin to use.
function ents_methods:setSkin(skinIndex)
	checkluatype(skinIndex, TYPE_NUMBER)

	local ent = getent(self)
	if SERVER and ent == instance.player then
		checkpermission(instance, ent, "entities.setPlayerRenderProperty")
	else
		checkpermission(instance, ent, "entities.setRenderProperty")
	end

	Ent_SetSkin(ent, skinIndex)
end

--- Gets the skin number of the entity
-- @shared
-- @return number Skin number
function ents_methods:getSkin()
	return Ent_GetSkin(getent(self))
end

--- Returns the amount of skins of the entity
-- @shared
-- @return number The amount of skins
function ents_methods:getSkinCount()
	return Ent_SkinCount(getent(self))
end

--- Sets the render mode of the entity
-- @shared
-- @param number rendermode Rendermode to use. http://wiki.facepunch.com/gmod/Enums/RENDERMODE
function ents_methods:setRenderMode(rendermode)
	checkluatype(rendermode, TYPE_NUMBER)

	local ent = getent(self)
	if SERVER and ent == instance.player then
		checkpermission(instance, ent, "entities.setPlayerRenderProperty")
	else
		checkpermission(instance, ent, "entities.setRenderProperty")
	end

	Ent_SetRenderMode(ent, rendermode)
	if SERVER then duplicator.StoreEntityModifier(ent, "colour", { RenderMode = rendermode }) end
end

--- Gets the render mode of the entity
-- @shared
-- @return number rendermode https://wiki.facepunch.com/gmod/Enums/RENDERMODE
function ents_methods:getRenderMode()
	return Ent_GetRenderMode(getent(self))
end

--- Sets the renderfx of the entity, most effects require entity's alpha to be less than 255 to take effect
-- @shared
-- @param number renderfx Renderfx to use. http://wiki.facepunch.com/gmod/Enums/kRenderFx
function ents_methods:setRenderFX(renderfx)
	checkluatype(renderfx, TYPE_NUMBER)

	local ent = getent(self)
	if SERVER and ent == instance.player then
		checkpermission(instance, ent, "entities.setPlayerRenderProperty")
	else
		checkpermission(instance, ent, "entities.setRenderProperty")
	end

	Ent_SetRenderFX(ent, renderfx)
	if SERVER then duplicator.StoreEntityModifier(ent, "colour", { RenderFX = renderfx }) end
end

--- Gets the renderfx of the entity
-- @shared
-- @return number Renderfx, https://wiki.facepunch.com/gmod/Enums/kRenderFx
function ents_methods:getRenderFX()
	return Ent_GetRenderFX(getent(self))
end

--- Gets the parent of an entity
-- @shared
-- @return Entity? Entity's parent or nil if not parented
function ents_methods:getParent()
	return ewrap(Ent_GetParent(getent(self)))
end

--- Gets the children (the parented entities) of an entity
-- @shared
-- @return table Table of parented children
function ents_methods:getChildren()
	return instance.Sanitize(Ent_GetChildren(getent(self)))
end

--- Gets the attachment index the entity is parented to
-- @shared
-- @return number Index of the attachment the entity is parented to or 0
function ents_methods:getAttachmentParent()
	return Ent_GetParentAttachment(getent(self))
end

--- Gets the attachment index via the entity and it's attachment name
-- @shared
-- @param string name of the attachment to lookup
-- @return number Number of the attachment index, or 0 if it doesn't exist
function ents_methods:lookupAttachment(name)
	return Ent_LookupAttachment(getent(self), name)
end

--- Gets the position and angle of an attachment
-- @shared
-- @param number index The index of the attachment
-- @return Vector? Position, nil if the attachment doesn't exist
-- @return Angle? Orientation, nil if the attachment doesn't exist
function ents_methods:getAttachment(index)
	local t = Ent_GetAttachment(getent(self), index)
	if t then return vwrap(t.Pos), awrap(t.Ang) end
end

--- Returns a table of attachments
-- @shared
-- @return table? Table of attachment id and attachment name or nil
function ents_methods:getAttachments()
	return Ent_GetAttachments(getent(self))
end

--- Gets the collision group enum of the entity
-- @return number The collision group enum of the entity. https://wiki.facepunch.com/gmod/Enums/COLLISION_GROUP
function ents_methods:getCollisionGroup()
	return Ent_GetCollisionGroup(getent(self))
end

--- Gets the solid enum of the entity
-- @return number The solid enum of the entity. https://wiki.facepunch.com/gmod/Enums/SOLID
function ents_methods:getSolid()
	return Ent_GetSolid(getent(self))
end

--- Gets the solid flag enum of the entity
-- @return number The solid flag enum of the entity. https://wiki.facepunch.com/gmod/Enums/FSOLID
function ents_methods:getSolidFlags()
	return Ent_GetSolidFlags(getent(self))
end

--- Gets whether an entity is solid or not
-- @return boolean whether an entity is solid or not
function ents_methods:isSolid()
	return Ent_IsSolid(getent(self))
end

--- Gets the movetype enum of the entity
-- @return number The movetype enum of the entity. https://wiki.facepunch.com/gmod/Enums/MOVETYPE
function ents_methods:getMoveType()
	return Ent_GetMoveType(getent(self))
end

--- Converts a ragdoll bone id to the corresponding physobject id
-- @param number boneid The ragdoll boneid
-- @return number The physobj id
function ents_methods:translateBoneToPhysBone(boneid)
	return Ent_TranslateBoneToPhysBone(getent(self), boneid)
end

--- Converts a physobject id to the corresponding ragdoll bone id
-- @param number boneid The physobject id
-- @return number The ragdoll bone id
function ents_methods:translatePhysBoneToBone(boneid)
	return Ent_TranslatePhysBoneToBone(getent(self), boneid)
end

--- Gets the number of physicsobjects of an entity
-- @return number The number of physics objects on the entity
function ents_methods:getPhysicsObjectCount()
	return Ent_GetPhysicsObjectCount(getent(self))
end

--- Gets the main physics objects of an entity
-- @return PhysObj The main physics object of the entity
function ents_methods:getPhysicsObject()
	local ent = getent(self)
	if Ent_IsWorld(ent) then SF.Throw("Cannot get the world physobj.", 2) end
	return pwrap(Ent_GetPhysicsObject(ent))
end

--- Gets a physics objects of an entity
-- @param number id The physics object id (starts at 0)
-- @return PhysObj The physics object of the entity
function ents_methods:getPhysicsObjectNum(id)
	checkluatype(id, TYPE_NUMBER)
	return pwrap(Ent_GetPhysicsObjectNum(getent(self), id))
end

--- Returns the elasticity of the entity
-- @return number Elasticity
function ents_methods:getElasticity()
	return Ent_GetElasticity(getent(self))
end

--- Gets the color of an entity
-- @shared
-- @return Color Color
function ents_methods:getColor()
	return setmetatable({Ent_GetColor4Part(getent(self))}, col_meta)
end

--- Gets the color values of an entity
-- @shared
-- @return number Red
-- @return number Green
-- @return number Blue
-- @return number Alpha
function ents_methods:getColor4Part()
	return Ent_GetColor4Part(getent(self))
end

--- Gets the clipping of an entity
-- @shared
-- @return table Table containing the clipdata
function ents_methods:getClipping()
	local ent = getent(self)
	local ent_tbl = Ent_GetTable(ent)

	local clips = {}

	-- Clips from visual clip tool
	if ent_tbl.ClipData then
		for i, clip in pairs(ent_tbl.ClipData) do
			local normal = (clip[1] or clip.n):Forward()

			table.insert(clips, {
				local_ent = self,
				origin = vwrap((clip[4] or Vector()) + normal * (clip[2] or clip.d)),
				normal = vwrap(normal)
			})
		end
	end

	-- Clips from Starfall and E2 holograms
	if ent_tbl.clips then
		for i, clip in pairs(ent_tbl.clips) do
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
	if ent_tbl.CLIPS then
		for i, clip in pairs(ent_tbl.CLIPS) do
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
-- @return boolean True if valid, false if not
function ents_methods:isValid()
	return Ent_IsValid(ent_meta.sf2sensitive[self])
end

--- Checks if an entity is a player.
-- @shared
-- @return boolean True if player, false if not
function ents_methods:isPlayer()
	return Ent_IsPlayer(getent(self))
end

--- Checks if an entity is a weapon.
-- @shared
-- @return boolean True if weapon, false if not
function ents_methods:isWeapon()
	return Ent_IsWeapon(getent(self))
end

--- Checks if an entity is a vehicle.
-- @shared
-- @return boolean True if vehicle, false if not
function ents_methods:isVehicle()
	return Ent_IsVehicle(getent(self))
end

--- Checks if an entity is an npc.
-- @shared
-- @return boolean True if npc, false if not
function ents_methods:isNPC()
	return Ent_IsNPC(getent(self))
end

--- Checks if the entity ONGROUND flag is set
-- @shared
-- @return boolean If it's flag is set or not
function ents_methods:isOnGround()
	return Ent_IsOnGround(getent(self))
end

--- Returns if the entity is ignited
-- @shared
-- @return boolean If the entity is on fire or not
function ents_methods:isOnFire()
	return Ent_IsOnFire(getent(self))
end

--- Returns the starfall or expression2's name
-- @return string The name of the chip
function ents_methods:getChipName()
	local ent = getent(self)
	local GetGateName = Ent_GetTable(ent).GetGateName
	if GetGateName then
		return tostring(GetGateName(ent))
	else
		SF.Throw("The entity is not a starfall or expression2!", 2)
	end
end

--- Gets the author of the specified starfall.
-- @shared
-- @return string The author of the starfall chip.
function ents_methods:getChipAuthor()
	local ent_tbl = Ent_GetTable(getent(self))
	if not ent_tbl.Starfall then SF.Throw("The entity isn't a starfall chip", 2) end

	return tostring(ent_tbl.author)
end

--- Returns the current count for this Think's CPU Time of the specified starfall.
-- This value increases as more executions are done, may not be exactly as you want.
-- If used on screens, will show 0 if only rendering is done. Operations must be done in the Think loop for them to be counted.
-- @shared
-- @return number Current quota used this Think
function ents_methods:getQuotaUsed()
	local ent_tbl = Ent_GetTable(getent(self))
	if not ent_tbl.Starfall then SF.Throw("The entity isn't a starfall chip", 2) end

	return ent_tbl.instance and ent_tbl.instance.cpu_total or 0
end

--- Gets the Average CPU Time in the buffer of the specified starfall or expression2.
-- @shared
-- @return number Average CPU Time of the buffer of the specified starfall or expression2.
function ents_methods:getQuotaAverage()
	local ent = getent(self)
	local ent_tbl = Ent_GetTable(ent)
	if ent_tbl.Starfall then
		return ent_tbl.instance and ent_tbl.instance:movingCPUAverage() or 0
	elseif Ent_GetClass(ent)=="gmod_wire_expression2" then
		return SERVER and ent_tbl.context.timebench or ent_tbl.GetOverlayData(ent).timebench
	else
		SF.Throw("The entity isn't a starfall or expression2 chip", 2)
	end
end

--- Gets the CPU Time max of the specified starfall of the specified starfall or expression2.
-- CPU Time is stored in a buffer of N elements, if the average of this exceeds quotaMax, the chip will error.
-- @shared
-- @return number Max SysTime allowed to take for execution of the chip in a Think.
function ents_methods:getQuotaMax()
	local ent = getent(self)
	local ent_tbl = Ent_GetTable(ent)

	if ent_tbl.Starfall then
		return ent_tbl.instance and ent_tbl.instance.cpuQuota or 0
	elseif Ent_GetClass(ent)=="gmod_wire_expression2" then
		return GetConVarNumber("wire_expression2_quotatime")
	else
		SF.Throw("The entity isn't a starfall or expression2 chip", 2)
	end
end

--- Return if the entity has a starfall instance or E2 instance
-- @shared
-- @return boolean if has starfall instance or E2 instance
function ents_methods:hasInstance()
	local ent = getent(self)
	local ent_tbl = Ent_GetTable(ent)

	if ent_tbl.Starfall then
		return ent_tbl.instance~=nil
	elseif Ent_GetClass(ent)=="gmod_wire_expression2" then
		return SERVER and not ent_tbl.error
	end

	return false
end

if SERVER then
	--- Gets all players the specified starfall errored for.
	-- This excludes the owner of the starfall chip.
	-- @server
	-- @return table A table containing the errored players.
	function ents_methods:getErroredPlayers()
		local ent = getent(self)
		local ent_tbl = Ent_GetTable(ent)
		if not ent_tbl.Starfall then SF.Throw("The entity isn't a starfall chip", 2) end

		local plys = {}
		for ply, _ in pairs(ent_tbl.ErroredPlayers) do
			if Ent_IsValid(ply) then
				table.insert(plys, plywrap(ply))
			end
		end

		return plys
	end

	--- Sets the health of the entity.
	-- @server
	-- @param number newhealth New health value.
	function ents_methods:setHealth(val)
		local ent = getent(self)
		checkpermission(instance, ent, "entities.setHealth")
		checkluatype(val, TYPE_NUMBER)
		Ent_SetHealth(ent, val)
	end

	--- Sets the maximum health for entity. Note, that you can still set entity's health above this amount with Entity:setHealth.
	-- @server
	-- @param number newmaxhealth New max health value.
	function ents_methods:setMaxHealth(val)
		local ent = getent(self)
		checkpermission(instance, ent, "entities.setMaxHealth")
		checkluatype(val, TYPE_NUMBER)
		Ent_SetMaxHealth(ent, val)
	end

	--- Stops the entity from being saved on duplication or map save.
	-- @server
	function ents_methods:doNotDuplicate()
		local ent = getent(self)
		checkpermission(instance, ent, "entities.doNotDuplicate")
		Ent_GetTable(ent).DoNotDuplicate = true
	end

end

--- Returns the id of the entity shared between server and client
-- @shared
-- @return number The numerical index of the entity
function ents_methods:entIndex()
	return Ent_EntIndex(getent(self))
end

--- Returns the class of the entity
-- @shared
-- @return string The string class name
function ents_methods:getClass()
	return Ent_GetClass(getent(self))
end

--- Returns the position of the entity
-- @shared
-- @return Vector The position vector
function ents_methods:getPos()
	return vwrap(Ent_GetPos(getent(self)))
end

--- Returns the position of the entity, local to its parent
-- @shared
-- @return Vector The position vector
function ents_methods:getLocalPos()
	return vwrap(Ent_GetLocalPos(getent(self)))
end

--- Returns how submerged the entity is in water
-- @shared
-- @return number The water level. 0 none, 1 slightly, 2 at least halfway, 3 all the way
function ents_methods:getWaterLevel()
	return Ent_WaterLevel(getent(self))
end

--- Returns the ragdoll bone index given a bone name
-- @shared
-- @param string name The bone's string name
-- @return number The bone index
function ents_methods:lookupBone(name)
	checkluatype(name, TYPE_STRING)
	return Ent_LookupBone(getent(self), name)
end

--- Returns the matrix of the entity's bone. Note: this method is slow/doesnt work well if the entity isn't animated.
-- @shared
-- @param number? bone Bone index. (def 0)
-- @return VMatrix The matrix
function ents_methods:getBoneMatrix(bone)
	if bone == nil then bone = 0 else checkluatype(bone, TYPE_NUMBER) end

	return mwrap(Ent_GetBoneMatrix(getent(self), bone))
end

--- Sets the bone matrix of given bone to given matrix. See also Entity:getBoneMatrix.
-- @shared
-- @param number bone The bone ID
-- @param VMatrix matrix The matrix to set
function ents_methods:setBoneMatrix(bone, matrix)
	local matrix = munwrap(matrix)
	local ent = getent(self)

	checkluatype(bone, TYPE_NUMBER)
	checkpermission(instance, ent, "entities.setRenderProperty")

	Ent_SetBoneMatrix(ent, bone, matrix)
end

--- Returns the world transform matrix of the entity
-- @shared
-- @return VMatrix The matrix
function ents_methods:getMatrix()
	return mwrap(Ent_GetWorldTransformMatrix(getent(self)))
end

--- Returns the number of an entity's bones
-- @shared
-- @return number Number of bones
function ents_methods:getBoneCount()
	return Ent_GetBoneCount(getent(self))
end

--- Returns the name of an entity's bone
-- @shared
-- @param number? bone Bone index. (def 0)
-- @return string Name of the bone
function ents_methods:getBoneName(bone)
	if bone == nil then bone = 0 else checkluatype(bone, TYPE_NUMBER) end
	return Ent_GetBoneName(getent(self), bone)
end

--- Returns the parent index of an entity's bone
-- @shared
-- @param number? bone Bone index. (def 0)
-- @return number Parent index of the bone. Returns -1 on error
function ents_methods:getBoneParent(bone)
	if bone == nil then bone = 0 else checkluatype(bone, TYPE_NUMBER) end
	return Ent_GetBoneParent(getent(self), bone)
end

--- Returns the bone's position and angle in world coordinates
-- @shared
-- @param number? bone Bone index. (def 0)
-- @return Vector Position of the bone
-- @return Angle Angle of the bone
function ents_methods:getBonePosition(bone)
	if bone == nil then bone = 0 else checkluatype(bone, TYPE_NUMBER) end
	local pos, ang = Ent_GetBonePosition(getent(self), bone)
	if not pos then SF.Throw("Invalid bone ("..bone..")!",2) end
	return vwrap(pos), awrap(ang)
end

--- Returns the manipulate angle of the bone (relative to its default angle)
-- @shared
-- @param number bone Bone index. (def 0)
-- @return Angle Manipulate angle of the bone
function ents_methods:getManipulateBoneAngles(bone)
	if bone == nil then bone = 0 else checkluatype(bone, TYPE_NUMBER) end
	return awrap(Ent_GetManipulateBoneAngles(getent(self), bone))
end

--- Returns the number manipulate jiggle of the bone (0 - 255)
-- @shared
-- @param number? bone Bone index. (def 0)
-- @return number Manipulate jiggle of the bone
function ents_methods:getManipulateBoneJiggle(bone)
	if bone == nil then bone = 0 else checkluatype(bone, TYPE_NUMBER) end
	return Ent_GetManipulateBoneJiggle(getent(self), bone)
end

--- Returns the vector manipulate position of the bone (relative to its default position)
-- @shared
-- @param number bone Bone index. (def 0)
-- @return Vector Manipulate position of the bone
function ents_methods:getManipulateBonePosition(bone)
	if bone == nil then bone = 0 else checkluatype(bone, TYPE_NUMBER) end
	return vwrap(Ent_GetManipulateBonePosition(getent(self), bone))
end

--- Returns the vector manipulate scale of the bone
-- @shared
-- @param number bone Bone index. (def 0)
-- @return Vector Manipulate scale of the bone
function ents_methods:getManipulateBoneScale(bone)
	if bone == nil then bone = 0 else checkluatype(bone, TYPE_NUMBER) end
	return vwrap(Ent_GetManipulateBoneScale(getent(self), bone))
end

--- Returns the x, y, z size of the entity's outer bounding box (local to the entity)
-- @shared
-- @return Vector The outer bounding box size
function ents_methods:obbSize()
	local ent = getent(self)
	return vwrap(Ent_OBBMaxs(ent) - Ent_OBBMins(ent))
end

--- Returns the local position of the entity's outer bounding box
-- @shared
-- @return Vector The position vector of the outer bounding box center
function ents_methods:obbCenter()
	return vwrap(Ent_OBBCenter(getent(self)))
end

--- Returns the world position of the entity's outer bounding box
-- @shared
-- @return Vector The position vector of the outer bounding box center
function ents_methods:obbCenterW()
	local ent = getent(self)
	return vwrap(Ent_LocalToWorld(ent, Ent_OBBCenter(ent)))
end

--- Returns min local bounding box vector of the entity
-- @shared
-- @return Vector The min bounding box vector
function ents_methods:obbMins()
	return vwrap(Ent_OBBMins(getent(self)))
end

--- Returns max local bounding box vector of the entity
-- @shared
-- @return Vector The max bounding box vector
function ents_methods:obbMaxs()
	return vwrap(Ent_OBBMaxs(getent(self)))
end

--- Returns Entity axis aligned bounding box in world coordinates
-- @shared
-- @return Vector The min bounding box vector
-- @return Vector The max bounding box vector
function ents_methods:worldSpaceAABB()
	local a, b = Ent_WorldSpaceAABB(getent(self))
	return vwrap(a), vwrap(b)
end

--- Returns the local position of the entity's mass center
-- @shared
-- @return Vector The position vector of the mass center
function ents_methods:getMassCenter()
	local phys = Ent_GetPhysicsObject(getent(self))
	if not Phys_IsValid(phys) then SF.Throw("Physics object is invalid", 2) end
	return vwrap(Phys_GetMassCenter(phys))
end

--- Returns the world position of the entity's mass center
-- @shared
-- @return Vector The position vector of the mass center
function ents_methods:getMassCenterW()
	local ent = getent(self)
	local phys = Ent_GetPhysicsObject(ent)
	if not Phys_IsValid(phys) then SF.Throw("Physics object is invalid", 2) end
	return vwrap(Ent_LocalToWorld(ent, Phys_GetMassCenter(phys)))
end

--- Returns the angle of the entity
-- @shared
-- @return Angle The angle
function ents_methods:getAngles()
	return awrap(Ent_GetAngles(getent(self)))
end

--- Returns the angle of the entity, local to its parent
-- @shared
-- @return Angle The angle
function ents_methods:getLocalAngles()
	return awrap(Ent_GetLocalAngles(getent(self)))
end

--- Returns the mass of the entity
-- @shared
-- @return number The numerical mass
function ents_methods:getMass()
	local phys = Ent_GetPhysicsObject(getent(self))
	if not Phys_IsValid(phys) then SF.Throw("Physics object is invalid", 2) end
	return Phys_GetMass(phys)
end

--- Returns the principle moments of inertia of the entity
-- @shared
-- @return Vector The principle moments of inertia as a vector
function ents_methods:getInertia()
	local phys = Ent_GetPhysicsObject(getent(self))
	if not Phys_IsValid(phys) then SF.Throw("Physics object is invalid", 2) end
	return vwrap(Phys_GetInertia(phys))
end

--- Returns the velocity of the entity
-- @shared
-- @return Vector The velocity vector
function ents_methods:getVelocity()
	return vwrap(Ent_GetVelocity(getent(self)))
end

--- Gets the velocity of the entity in its local coordinate system
-- @shared
-- @return Vector Vector velocity of the physics object local to itself
function ents_methods:getLocalVelocity()
	local ent = getent(self)
	return vwrap(Ent_WorldToLocal(ent, Ent_GetVelocity(ent) + Ent_GetPos(ent)))
end

--- Returns the angular velocity of the entity
-- @shared
-- @return Vector The angular velocity as a vector
function ents_methods:getAngleVelocity()
	local phys = Ent_GetPhysicsObject(getent(self))
	if not Phys_IsValid(phys) then SF.Throw("Physics object is invalid", 2) end
	return vwrap(Phys_GetAngleVelocity(phys))
end

--- Returns the angular velocity of the entity
-- @shared
-- @return Angle The angular velocity as an angle
function ents_methods:getAngleVelocityAngle()
	local phys = Ent_GetPhysicsObject(getent(self))
	if not Phys_IsValid(phys) then SF.Throw("Physics object is invalid", 2) end
	local vec = Phys_GetAngleVelocity(phys)
	return awrap(Angle(vec.y, vec.z, vec.x))
end

--- Converts a vector in entity local space to world space
-- @shared
-- @param Vector data Local space vector
-- @return Vector data as world space vector
function ents_methods:localToWorld(data)
	return vwrap(Ent_LocalToWorld(getent(self), vunwrap1(data)))
end

--- Converts a direction vector in entity local space to world space
-- @shared
-- @param Vector data Local space vector direction
-- @return Vector data as world space vector direction
function ents_methods:localToWorldVector(data)
	return vwrap(Phys_LocalToWorldVector(Ent_GetPhysicsObject(getent(self)), vunwrap1(data)))
end

--- Converts an angle in entity local space to world space
-- @shared
-- @param Angle data Local space angle
-- @return Angle data as world space angle
function ents_methods:localToWorldAngles(data)
	return awrap(Ent_LocalToWorldAngles(getent(self), aunwrap1(data)))
end

--- Converts a vector in world space to entity local space
-- @shared
-- @param Vector data World space vector
-- @return Vector data as local space vector
function ents_methods:worldToLocal(data)
	return vwrap(Ent_WorldToLocal(getent(self), vunwrap1(data)))
end

--- Converts a direction vector in world space to entity local space
-- @shared
-- @param Vector data World space direction vector
-- @return Vector data as local space direction vector
function ents_methods:worldToLocalVector(data)
	return vwrap(Phys_WorldToLocalVector(Ent_GetPhysicsObject(getent(self)), vunwrap1(data)))
end

--- Converts an angle in world space to entity local space
-- @shared
-- @param Angle data World space angle
-- @return Angle data as local space angle
function ents_methods:worldToLocalAngles(data)
	return awrap(Ent_WorldToLocalAngles(getent(self), aunwrap1(data)))
end

--- Gets the animation number from the animation name
-- @param string animation Name of the animation
-- @return number Animation index or -1 if invalid
function ents_methods:lookupSequence(animation)
	checkluatype(animation, TYPE_STRING)
	return Ent_LookupSequence(getent(self), animation)
end

--- Gets the current playing sequence
-- @return number The sequence number
function ents_methods:getSequence()
	return Ent_GetSequence(getent(self))
end

--- Gets the name of a sequence
-- @param number id The id of the animation
-- @return string The sequence name
function ents_methods:getSequenceName(id)
	checkluatype(id, TYPE_NUMBER)
	return Ent_GetSequenceName(getent(self), id)
end

--- Gets various information about the specified animation
-- @param number id The ID of the animation
-- @return table Animation info
function ents_methods:getSequenceInfo(id)
	local ent = getent(self)
	checkluatype(id, TYPE_NUMBER)
	if id < 0 or id > Ent_GetSequenceCount(ent) - 1 then SF.Throw("Sequence ID out of bounds", 2) end
	local info = Ent_GetSequenceInfo(getent(self), id)
	info.bbmin = vwrap(info.bbmin)
	info.bbmax = vwrap(info.bbmax)
	return info
end

--- Returns all animations of the entity
-- @return table List of animations, starts at index 0 where value is the animation's name
function ents_methods:getSequenceList()
	return Ent_GetSequenceList(getent(self))
end

--- Gets the number of animations the entity has
-- @return number Count of entity's animations
function ents_methods:getSequenceCount()
	return Ent_GetSequenceCount(getent(self))
end

--- Returns true if the entity is a nextbot
-- @return boolean Whether it is a nextbot
function ents_methods:isNextBot()
	return Ent_IsNextBot(getent(self))
end

--- Checks whether the animation is playing
-- @return boolean True if the animation is currently playing, False otherwise
function ents_methods:isSequenceFinished()
	return Ent_IsSequenceFinished(getent(self))
end

--- Get the length of an animation
-- @param number? id (Optional) The id of the sequence, or will default to the currently playing sequence
-- @return number Length of the animation in seconds
function ents_methods:sequenceDuration(id)
	local ent = getent(self)
	if id~=nil then checkluatype(id, TYPE_NUMBER) end

	return Ent_SequenceDuration(ent, id)
end

--- Set the pose value of an animation. Turret/Head angles for example.
-- @param string pose Name of the pose parameter
-- @param number value Value to set it to.
function ents_methods:setPose(pose, value)
	local ent = getent(self)
	checkpermission(instance, ent, "entities.setRenderProperty")

	Ent_SetPoseParameter(ent, pose, value)
end

--- Get the pose value of an animation
-- @param string pose Pose parameter name
-- @return number Value of the pose parameter
function ents_methods:getPose(pose)
	return Ent_GetPoseParameter(getent(self), pose)
end

--- Returns the amount of pose parameters the entity has
-- @return number Amount of poses
function ents_methods:getPoseCount()
	return Ent_GetNumPoseParameters(getent(self))
end

--- Returns pose index corresponding to the given name
-- @param string pose Pose name
-- @return number Pose index or -1 if not found
function ents_methods:getPoseIndex(pose)
	return Ent_LookupPoseParameter(getent(self), pose)
end

--- Returns pose name corresponding to the given index
-- @param number id Pose index (starting from 0)
-- @return string Pose name or empty string if not found
function ents_methods:getPoseName(id)
	return Ent_GetPoseParameterName(getent(self), id)
end

--- Returns pose value range
-- @param number id Pose index (starting from 0)
-- @return number? Minimum pose value or nil if pose not found
-- @return number? Maximum pose value or nil if pose not found
function ents_methods:getPoseRange(id)
	return Ent_GetPoseParameterRange(getent(self), id)
end

--- Returns a table of flexname -> flexid pairs for use in flex functions.
-- @return table Table of flexes
function ents_methods:getFlexes()
	local ent = getent(self)
	local flexes = {}
	for i = 0, Ent_GetFlexNum(ent)-1 do
		flexes[Ent_GetFlexName(ent, i)] = i
	end
	return flexes
end

--- Returns the ID of the flex based on given name.
-- @param string flexname The name of the flex to get the ID of. Case sensitive.
-- @return number The ID of the flex based on given name.
function ents_methods:getFlexByName(name)
	checkluatype(name, TYPE_STRING)
	return Ent_GetFlexIDByName(getent(self), name)
end

--- Returns flex name.
-- @param number flexid The flex id to look up name of.
-- @return string The flex name
function ents_methods:getFlexName(id)
	checkluatype(id, TYPE_NUMBER)
	return Ent_GetFlexName(getent(self), id)
end

--- Returns whether or not the the entity has had flex manipulations performed with Entity:setFlexWeight or Entity:setFlexScale.
-- @return boolean True if the entity has flex manipulations, false otherwise.
function ents_methods:hasFlexManipulations()
	return Ent_HasFlexManipulatior(getent(self))
end

--- Gets the weight (value) of a flex.
-- @param number flexid The id of the flex
-- @return number The weight of the flex
function ents_methods:getFlexWeight(flexid)
	local ent = getent(self)

	checkluatype(flexid, TYPE_NUMBER)
	flexid = math.floor(flexid)

	if flexid < 0 or flexid >= Ent_GetFlexNum(ent) then
		SF.Throw("Invalid flex: "..flexid, 2)
	end

	return Ent_GetFlexWeight(ent, flexid)
end

--- Sets the weight (value) of a flex.
-- @param number flexid The id of the flex
-- @param number weight The weight of the flex
function ents_methods:setFlexWeight(flexid, weight)
	local ent = getent(self)

	checkluatype(flexid, TYPE_NUMBER)
	checkluatype(weight, TYPE_NUMBER)
	flexid = math.floor(flexid)

	if SERVER and ent == instance.player then
		checkpermission(instance, ent, "entities.setPlayerRenderProperty")
	else
		checkpermission(instance, ent, "entities.setRenderProperty")
	end

	if flexid < 0 or flexid >= Ent_GetFlexNum(ent) then
		SF.Throw("Invalid flex: "..flexid, 2)
	end

	Ent_SetFlexWeight(ent, flexid, weight)
end

--- Gets the scale of the entity flexes
-- @return number The scale of the flexes
function ents_methods:getFlexScale()
	return Ent_GetFlexScale(getent(self))
end

--- Sets the scale of the entity flexes
-- @param number scale The scale of the flexes to set
function ents_methods:setFlexScale(scale)
	local ent = getent(self)
	checkluatype(scale, TYPE_NUMBER)

	if SERVER and ent == instance.player then
		checkpermission(instance, ent, "entities.setPlayerRenderProperty")
	else
		checkpermission(instance, ent, "entities.setRenderProperty")
	end

	Ent_SetFlexScale(ent, scale)
end

--- Gets the model of an entity
-- @shared
-- @return string Model of the entity
function ents_methods:getModel()
	return Ent_GetModel(getent(self))
end

--- Returns the entity's model bounds. This is different than the collision bounds/hull.
-- This is not scaled with Entity:setModelScale and will return the model's original, unmodified mins and maxs.
-- @shared
-- @return Vector Minimum vector of the bounds
-- @return Vector Maximum vector of the bounds
function ents_methods:getModelBounds()
	local minvec, maxvec = Ent_GetModelBounds(getent(self))
	return vwrap(minvec), vwrap(maxvec)
end

--- Returns the contents of the entity's current model
-- @shared
-- @return number Contents of the entity's model. https://wiki.facepunch.com/gmod/Enums/CONTENTS
function ents_methods:getModelContents()
	return Ent_GetModelContents(getent(self))
end

--- Returns the model's radius
-- @shared
-- @return number Radius of the model
function ents_methods:getModelRadius()
	return Ent_GetModelRadius(getent(self))
end

--- Returns the model's scale
-- @shared
-- @return number Scale of the model
function ents_methods:getModelScale()
	return Ent_GetModelScale(getent(self))
end

--- Returns the entity's model render bounds.
-- Unlike Entity:getModelBounds, bounds returning by this function will not be affected by animations (at compile time).
-- @shared
-- @return Vector The minimum vector of the bounds
-- @return Vector The maximum vector of the bounds
function ents_methods:getModelRenderBounds()
	local minvec, maxvec = Ent_GetModelRenderBounds(getent(self))
	return vwrap(minvec), vwrap(maxvec)
end

--- Returns an entity's collision bounding box.
-- In most cases, this will return the same bounding box as Entity:getModelBounds, unless the entity does not have a physics mesh or it has a PhysObj different from the default.
-- @shared
-- @return Vector The minimum vector of the collision bounds
-- @return Vector The maximum vector of the collision bounds
function ents_methods:getCollisionBounds()
	local minvec, maxvec = Ent_GetCollisionBounds(getent(self))
	return vwrap(minvec), vwrap(maxvec)
end

--- Returns axis-aligned bounding box (AABB) of a orientated bounding box (OBB) based on entity's rotation.
-- @shared
-- @param Vector min Minimum extent of an OBB in local coordinates.
-- @param Vector max Maximum extent of an OBB in local coordinates.
-- @return Vector Minimum extent of the AABB relative to entity's position.
-- @return Vector Maximum extent of the AABB relative to entity's position.
function ents_methods:getRotatedAABB(min, max)
	local minvec, maxvec = Ent_GetRotatedAABB(getent(self), vunwrap1(min), vunwrap2(max))
	return vwrap(minvec), vwrap(maxvec)
end

--- Gets the max health of an entity
-- @shared
-- @return number Max Health of the entity
function ents_methods:getMaxHealth()
	return Ent_GetMaxHealth(getent(self))
end

--- Gets the health of an entity
-- @shared
-- @return number Health of the entity
function ents_methods:getHealth()
	return Ent_Health(getent(self))
end

--- Gets the entity's eye angles
-- @shared
-- @return Angle Angles of the entity's eyes
function ents_methods:getEyeAngles()
	return awrap(Ent_EyeAngles(getent(self)))
end

--- Gets the entity's eye position
-- @shared
-- @return Vector Eye position of the entity
-- @return Vector? In case of a ragdoll, the position of the second eye
function ents_methods:getEyePos()
	local pos1, pos2 = Ent_EyePos(getent(self))
	if pos2 then
		return vwrap(pos1), vwrap(pos2)
	end
	return vwrap(pos1)
end

--- Gets an entities' material
-- @shared
-- @return string String material
function ents_methods:getMaterial()
	return Ent_GetMaterial(getent(self)) or ""
end

--- Gets an entities' submaterial
-- @shared
-- @param number index Number index of the sub material
-- @return string String material
function ents_methods:getSubMaterial(index)
	checkluatype(index, TYPE_NUMBER)
	if index<0 or index>31 then SF.Throw("Index must be an int in range 0 - 31") end

	return Ent_GetSubMaterial(getent(self), index) or ""
end

--- Gets an entities' material list
-- @shared
-- @return table Material
function ents_methods:getMaterials()
	return Ent_GetMaterials(getent(self)) or {}
end

--- Gets the entity's up vector
-- @shared
-- @return Vector Vector up
function ents_methods:getUp()
	return vwrap(Ent_GetUp(getent(self)))
end

--- Gets the entity's right vector
-- @shared
-- @return Vector Vector right
function ents_methods:getRight()
	return vwrap(Ent_GetRight(getent(self)))
end

--- Gets the entity's forward vector
-- @shared
-- @return Vector Vector forward
function ents_methods:getForward()
	return vwrap(Ent_GetForward(getent(self)))
end

--- Returns the timer.curtime() time the entity was created on
-- @shared
-- @return number Seconds relative to server map start
function ents_methods:getCreationTime()
	return Ent_GetCreationTime(getent(self))
end

--- Checks if an engine effect is applied to the entity
-- @shared
-- @param number effect The effect to check. EF table values
-- @return boolean True or false
function ents_methods:isEffectActive(effect)
	checkluatype(effect, TYPE_NUMBER)
	return Ent_IsEffectActive(getent(self), effect)
end

--- Marks entity as persistent, disallowing players from physgunning it. Persistent entities save on server shutdown when sbox_persist is set
-- @shared
-- @param boolean persist True to make persistent
function ents_methods:setPersistent(persist)
	checkluatype(persist, TYPE_BOOL)
	local ent = getent(self)
	checkpermission(instance, ent, "entities.setPersistent")
	Ent_SetPersistent(ent, persist)
end

--- Checks if entity is marked as persistent
-- @shared
-- @return boolean True if the entity is persistent
function ents_methods:getPersistent()
	return Ent_GetPersistent(getent(self))
end

--- Returns the game assigned owner of an entity. This doesn't take CPPI into account and will return nil for most standard entities.
-- Used on entities with custom physics like held SWEPs and fired bullets in which case player entity should be returned.
-- @shared
-- @return Entity Owner
function ents_methods:entOwner()
	return owrap(Ent_GetOwner(getent(self)))
end

--- Gets the bounds (min and max corners) of a hit box.
-- @shared
-- @param number hitbox The number of the hitbox.
-- @param number group The number of the hitbox group, 0 in most cases.
-- @return Vector Hitbox mins vector.
-- @return Vector Hitbox maxs vector.
function ents_methods:getHitBoxBounds(hitbox, group)
	checkluatype(hitbox, TYPE_NUMBER)
	checkluatype(group, TYPE_NUMBER)
	local mins, maxs = Ent_GetHitBoxBounds(getent(self), hitbox, group)
	if mins and maxs then
		return vwrap(mins), vwrap(maxs)
	end
end

--- Gets number of hitboxes in a group.
-- @shared
-- @param number group The number of the hitbox group.
-- @return number Number of hitboxes
function ents_methods:getHitBoxCount(group)
	checkluatype(group, TYPE_NUMBER)
	return Ent_GetHitBoxCount(getent(self), group)
end

--- Gets the bone the given hitbox is attached to.
-- @shared
-- @param number hitbox The number of the hitbox.
-- @param number group The number of the hitbox group, 0 in most cases.
-- @return number Bone ID
function ents_methods:getHitBoxBone(hitbox, group)
	checkluatype(hitbox, TYPE_NUMBER)
	checkluatype(group, TYPE_NUMBER)
	return Ent_GetHitBoxBone(getent(self), hitbox, group)
end

--- Returns entity's current hit box set.
-- @shared
-- @return number? Hitbox set number, nil if entity has no hitboxes.
-- @return string? Hitbox set name, nil if entity has no hitboxes.
function ents_methods:getHitBoxSet()
	return Ent_GetHitboxSet(getent(self))
end

--- Returns entity's number of hitbox sets.
-- @shared
-- @return number Number of hitbox sets.
function ents_methods:getHitBoxSetCount()
	return Ent_GetHitboxSetCount(getent(self))
end

--- Gets the hit group of a given hitbox in a given hitbox set.
-- @shared
-- @param number hitbox The number of the hit box.
-- @param number hitboxset The number of the hit box set. This should be 0 in most cases.
-- @return number The hitbox group of given hitbox. See https://wiki.facepunch.com/gmod/Enums/HITGROUP
function ents_methods:getHitBoxHitGroup(hitbox, hitboxset)
	checkluatype(hitbox, TYPE_NUMBER)
	checkluatype(hitboxset, TYPE_NUMBER)
	return Ent_GetHitBoxHitGroup(getent(self), hitbox, hitboxset)
end

--- Returns a table of brushes surfaces for brush model entities.
-- @shared
-- @return table Table of SurfaceInfos if the entity has a brush model, or no value otherwise.
function ents_methods:getBrushSurfaces()
	local t = Ent_GetBrushSurfaces(getent(self))
	if not t then return end
	local out = {}
	for k,surface in ipairs(t) do
		out[k] = swrap(surface)
	end
	return out
end

--- Returns info about the given brush plane
-- @shared
-- @param number id Plane index. Starts from 0
-- @return Vector The origin of the plane
-- @return Vector The normal of the plane
-- @return number The distance to the plane
function ents_methods:getBrushPlane(id)
	checkluatype(id, TYPE_NUMBER)
	local origin, normal, distance = Ent_GetBrushPlane(getent(self), id)
	return vwrap(origin), vwrap(normal), distance
end

--- Returns the amount of planes of the brush entity
-- @shared
-- @return number The amount of brush planes
function ents_methods:getBrushPlaneCount()
	return Ent_GetBrushPlaneCount(getent(self))
end

--- Gets a datatable angle
-- @shared
-- @param number key The number key. Valid keys are 0 - 31
-- @return Angle? The angle or nil if it doesn't exist
function ents_methods:getDTAngle(key)
	checkluatype(key, TYPE_NUMBER)
	if key<0 or key>31 then SF.Throw("Key must be a int in range 0 - 31") end
	return awrap(Ent_GetDTAngle(getent(self), key))
end

--- Gets a datatable boolean
-- @shared
-- @param number key The number key. Valid keys are 0 - 31
-- @return boolean? The boolean or nil if it doesn't exist
function ents_methods:getDTBool(key)
	checkluatype(key, TYPE_NUMBER)
	if key<0 or key>31 then SF.Throw("Key must be a int in range 0 - 31") end
	return Ent_GetDTBool(getent(self), key)
end

--- Gets a datatable entity
-- @shared
-- @param number key The number key. Valid keys are 0 - 31
-- @return Entity? The entity or nil if it doesn't exist
function ents_methods:getDTEntity(key)
	checkluatype(key, TYPE_NUMBER)
	if key<0 or key>31 then SF.Throw("Key must be a int in range 0 - 31") end
	return owrap(Ent_GetDTEntity(getent(self), key))
end

--- Gets a datatable float
-- @shared
-- @param number key The number key. Valid keys are 0 - 31
-- @return number? The float or nil if it doesn't exist
function ents_methods:getDTFloat(key)
	checkluatype(key, TYPE_NUMBER)
	if key<0 or key>31 then SF.Throw("Key must be a int in range 0 - 31") end
	return Ent_GetDTFloat(getent(self), key)
end

--- Gets a datatable int
-- @shared
-- @param number key The number key. Valid keys are 0 - 31
-- @return number? The int or nil if it doesn't exist
function ents_methods:getDTInt(key)
	checkluatype(key, TYPE_NUMBER)
	if key<0 or key>31 then SF.Throw("Key must be a int in range 0 - 31") end
	return Ent_GetDTInt(getent(self), key)
end

--- Gets a datatable string
-- @shared
-- @param number key The number key. Valid keys are 0 - 31
-- @return string? The string or nil if it doesn't exist
function ents_methods:getDTString(key)
	checkluatype(key, TYPE_NUMBER)
	if key<0 or key>31 then SF.Throw("Key must be a int in range 0 - 31") end
	return Ent_GetDTString(getent(self), key)
end

--- Gets a datatable vector
-- @shared
-- @param number key The number key. Valid keys are 0 - 31
-- @return Vector? The vector or nil if it doesn't exist
function ents_methods:getDTVector(key)
	checkluatype(key, TYPE_NUMBER)
	if key<0 or key>31 then SF.Throw("Key must be a int in range 0 - 31") end
	return vwrap(Ent_GetDTVector(getent(self), key))
end

--- Gets a networked variable of an entity
-- @shared
-- @param string key The string key to get
-- @return any The object associated with that key or nil if it's not set
function ents_methods:getNWVar(key)
	checkluatype(key, TYPE_STRING)
	-- GetNW* returns whatever the key is tied to regardless of the function name
	local result = Ent_GetNWEntity(getent(self), key)
	if result == NULL then return end
	return owrap(result)
end

--- Gets the table of all networked things on an entity
-- @shared
-- @return table The table of networked objects
function ents_methods:getNWVarTable()
	return instance.Sanitize(Ent_GetNWVarTable(getent(self)))
end

--- Returns the distance between the center of the entity's bounding box and whichever corner of the bounding box is farthest away.
-- @shared
-- @return number The radius of the bounding box, or 0 for some entities such as worldspawn
function ents_methods:getBoundingRadius()
	return Ent_BoundingRadius(getent(self))
end

--- Returns whether the entity is dormant or not, i.e. whether or not information about the entity is being sent to your client. Not to be confused with PhysObj:isAsleep
-- Clientside, this will usually be true if the object is outside of your PVS (potentially visible set).
-- Serverside, this will almost always be false.
-- @shared
-- @return boolean Whether entity is dormant or not.
function ents_methods:isDormant()
	return Ent_IsDormant(getent(self))
end

--- Performs a Ray-Orientated Bounding Box intersection from the given position to the origin of the OBBox with the entity and returns the hit position on the OBBox.
-- This relies on the entity having a collision mesh (not a physics object) and will be affected by SOLID_NONE
-- @shared
-- @param Vector The vector to start the intersection from.
-- @return Vector The nearest hit point of the entity's bounding box in world coordinates, or Vector(0, 0, 0) for some entities such as worldspawn.
function ents_methods:getNearestPoint(pos)
	return vwrap(Ent_NearestPoint(getent(self), vunwrap1(pos)))
end

--- Returns a table of save values for an entity.
-- These tables are not the same between the client and the server, and different entities may have different fields.
-- @shared
-- @param boolean showAll If set, shows all variables, not just the ones for save.
-- @return table A table containing all save values in key/value format. The value may be a sequential table (starting to 1) if the field in question is an array in engine.
function ents_methods:getSaveTable(showAll)
	return instance.Sanitize(Ent_GetSaveTable(getent(self), showAll and true or false))
end

--- Returns a variable from the entity's save table.
-- @shared
-- @param string variableName Name of the internal save table variable.
-- @return any The internal variable associated with the name.
function ents_methods:getInternalVariable(variableName)
	checkluatype(variableName, TYPE_STRING)
	local result = Ent_GetInternalVariable(getent(self), variableName)
	return istable(result) and instance.Sanitize(result) or owrap(result)
end

--- Returns entity's map creation ID. Unlike Entity:entIndex or Entity:getCreationID, it will always be the same on same map, no matter how much you clean up or restart it.
-- @shared
-- @return number The map creation ID or -1 if the entity is not compiled into the map.
function ents_methods:mapCreationID()
	return Ent_MapCreationID(getent(self))
end

--- Returns entity's networked variables table (data table).
-- @shared
-- @return table? The networked variables table of the entity or nil if it doesn't have one.
function ents_methods:getNetworkVars()
	local ent = getent(self)
	local ent_tbl = Ent_GetTable(ent)
	return istable(ent_tbl.dt) and instance.Sanitize(ent_tbl.GetNetworkVars(ent)) or nil
end


end
