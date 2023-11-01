-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege

registerprivilege("entities.setParent", "Parent", "Allows the user to parent an entity to another entity", { entities = {} })
registerprivilege("entities.setRenderProperty", "RenderProperty", "Allows the user to change the rendering of an entity", { client = (CLIENT and {} or nil), entities = {} })
registerprivilege("entities.setPlayerRenderProperty", "PlayerRenderProperty", "Allows the user to change the rendering of themselves", {})
registerprivilege("entities.setPersistent", "SetPersistent", "Allows the user to change entity's persistent state", { entities = {} })
registerprivilege("entities.emitSound", "Emitsound", "Allows the user to play sounds on entities", { client = (CLIENT and {} or nil), entities = {} })
registerprivilege("entities.setHealth", "SetHealth", "Allows the user to change an entity's health", { entities = {} })
registerprivilege("entities.setMaxHealth", "SetMaxHealth", "Allows the user to change an entity's max health", { entities = {} })
registerprivilege("entities.doNotDuplicate", "DoNotDuplicate", "Allows the user to set whether an entity will be saved on dupes or map saves", { entities = {} })

local emitSoundBurst = SF.BurstObject("emitSound", "emitsound", 180, 200, " sounds can be emitted per second", "Number of sounds that can be emitted in a short time")
local manipulations = SF.EntityTable("boneManipulations")

hook.Add("PAC3ResetBones","SF_BoneManipulations",function(ent)
	local manips = manipulations[ent]
	if manips then
		for bone, v in pairs(manips.Position) do
			ent:ManipulateBonePosition(bone, v)
		end
		for bone, v in pairs(manips.Scale) do
			ent:ManipulateBoneScale(bone, v)
		end
		for bone, v in pairs(manips.Angle) do
			ent:ManipulateBoneAngles(bone, v)
		end
		for bone, v in pairs(manips.Jiggle) do
			ent:ManipulateBoneJiggle(bone, v)
		end
	end
end)
local function setManipulation(ent, type, bone, val)
	if val then
		local manips = manipulations[ent]
		if not manips then
			manips = {Position = {}, Scale = {}, Angle = {}, Jiggle = {}}
			manipulations[ent] = manips
		end
		manips[type][bone] = val
	else
		local manips = manipulations[ent]
		if manips then
			manips[type][bone] = nil
			if next(manips.Position)==nil and next(manips.Scale)==nil and next(manips.Angle)==nil and next(manips.Jiggle)==nil then
				manipulations[ent] = nil
			end
		end
	end
end


--- Entity type
-- @name Entity
-- @class type
-- @libtbl ents_methods
-- @libtbl ent_meta
SF.RegisterType("Entity", false, true, debug.getregistry().Entity)


return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local owrap, ounwrap = instance.WrapObject, instance.UnwrapObject
local ents_methods, ent_meta, ewrap, eunwrap = instance.Types.Entity.Methods, instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local col_meta, cwrap, cunwrap = instance.Types.Color, instance.Types.Color.Wrap, instance.Types.Color.Unwrap
local phys_meta, pwrap, punwrap = instance.Types.PhysObj, instance.Types.PhysObj.Wrap, instance.Types.PhysObj.Unwrap
local mtx_meta, mwrap, munwrap = instance.Types.VMatrix, instance.Types.VMatrix.Wrap, instance.Types.VMatrix.Unwrap
local plywrap = instance.Types.Player.Wrap
local swrap, sunwrap = instance.Types.SurfaceInfo.Wrap, instance.Types.SurfaceInfo.Unwrap

local function getent(self)
	local ent = eunwrap(self)
	if ent:IsValid() or ent:IsWorld() then
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
	if not ent then return "(null entity)"
	else return tostring(ent) end
end

-- ------------------------- Methods ------------------------- --

--- Gets the owner of the entity
-- @return Entity Owner
function ents_methods:getOwner()
	local ent = getent(self)

	if SF.Permissions.getOwner then
		return plywrap(SF.Permissions.getOwner(ent))
	end
end

if CLIENT then
	instance.object_wrappers[debug.getregistry().NextBot] = ewrap
		
	--- Allows manipulation of an entity's bones' positions
	-- @client
	-- @param number bone The bone ID
	-- @param Vector vec The position it should be manipulated to
	function ents_methods:manipulateBonePosition(bone, vec)
		local ent = getent(self)
		checkluatype(bone, TYPE_NUMBER)
		bone = math.floor(bone)
		if bone<0 or bone>=ent:GetBoneCount() then SF.Throw("Invalid bone "..bone, 2) end

		vec = vunwrap(vec)
		checkpermission(instance, ent, "entities.setRenderProperty")
		setManipulation(ent, "Position", bone, (vec[1]~=0 or vec[2]~=0 or vec[3]~=0) and vec)
		ent:ManipulateBonePosition(bone, vec)
	end

	--- Allows manipulation of an entity's bones' scale
	-- @client
	-- @param number bone The bone ID
	-- @param Vector vec The scale it should be manipulated to
	function ents_methods:manipulateBoneScale(bone, vec)
		local ent = getent(self)
		checkluatype(bone, TYPE_NUMBER)
		bone = math.floor(bone)
		if bone<0 or bone>=ent:GetBoneCount() then SF.Throw("Invalid bone "..bone, 2) end

		vec = vunwrap(vec)
		checkpermission(instance, ent, "entities.setRenderProperty")
		setManipulation(ent, "Scale", bone, (vec[1]~=0 or vec[2]~=0 or vec[3]~=0) and vec)
		ent:ManipulateBoneScale(bone, vec)
	end

	--- Allows manipulation of an entity's bones' angles
	-- @client
	-- @param number bone The bone ID
	-- @param Angle ang The angle it should be manipulated to
	function ents_methods:manipulateBoneAngles(bone, ang)
		local ent = getent(self)
		checkluatype(bone, TYPE_NUMBER)
		bone = math.floor(bone)
		if bone<0 or bone>=ent:GetBoneCount() then SF.Throw("Invalid bone "..bone, 2) end

		ang = aunwrap(ang)
		checkpermission(instance, ent, "entities.setRenderProperty")
		setManipulation(ent, "Angle", bone, (ang[1]~=0 or ang[2]~=0 or ang[3]~=0) and ang)
		ent:ManipulateBoneAngles(bone, ang)
	end

	--- Allows manipulation of an entity's bones' jiggle status
	-- @client
	-- @param number bone The bone ID
	-- @param boolean enabled Whether to make the bone jiggly or not
	function ents_methods:manipulateBoneJiggle(bone, state)
		local ent = getent(self)
		checkluatype(bone, TYPE_NUMBER)
		bone = math.floor(bone)
		if bone<0 or bone>=ent:GetBoneCount() then SF.Throw("Invalid bone "..bone, 2) end

		checkluatype(state, TYPE_BOOL)
		checkpermission(instance, ent, "entities.setRenderProperty")
		setManipulation(ent, "Jiggle", bone, state and 1)
		ent:ManipulateBoneJiggle(bone, state and 1 or 0)
	end

	--- Sets a hologram or custom_prop model to a custom Mesh
	-- @client
	-- @param Mesh? mesh The mesh to set it to or nil to set back to normal
	function ents_methods:setMesh(mesh)
		local ent = getent(self)
		if not ent.IsSFHologram and not ent.IsSFProp then SF.Throw("The entity isn't a hologram or custom-prop", 2) end

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
	-- @param Material? material The material to set it to or nil to set back to default
	function ents_methods:setMeshMaterial(material)
		local ent = getent(self)
		if not ent.IsSFHologram and not ent.IsSFProp then SF.Throw("The entity isn't a hologram or custom-prop", 2) end

		checkpermission(instance, ent, "entities.setRenderProperty")

		if material then
			ent.Material = instance.Types.LockedMaterial.Unwrap(material)
		else
			ent.Material = ent.DefaultMaterial
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

		if ent:IsPlayer() then
			ent:SetPlayerColor(vec)
		elseif playerColorWhitelist[ent:GetClass()] then
			ent.GetPlayerColor = function() return vec end
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
		if not ent.IsSFHologram and not ent.IsSFProp then SF.Throw("The entity isn't a hologram or custom-prop", 2) end


		checkpermission(instance, ent, "entities.setRenderProperty")

		mins, maxs = vunwrap(mins), vunwrap(maxs)
		ent:SetRenderBounds(mins, maxs)
		ent.sf_userrenderbounds = {mins, maxs}
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
		ent:SetupBones()
		ent:DrawModel()
	end
end

local soundsByEntity = SF.EntityTable("emitSoundsByEntity", function(e, t)
	for snd, _ in pairs(t) do
		e:StopSound(snd)
	end
end, true)

local sound_library = instance.Libraries.sound

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

--- Plays a sound on the entity
-- @param string snd Sound path
-- @param number soundLevel Default 75
-- @param number pitchPercent Default 100
-- @param number volume Default 1
-- @param number channel Default CHAN_AUTO or CHAN_WEAPON for weapons
function ents_methods:emitSound(snd, lvl, pitch, volume, channel)
	checkluatype(snd, TYPE_STRING)
	emitSoundBurst:use(instance.player, 1)

	local ent = getent(self)
	checkpermission(instance, ent, "entities.emitSound")

	local snds = soundsByEntity[ent]
	if not snds then snds = {} soundsByEntity[ent] = snds end
	snds[snd] = true
	ent:EmitSound(snd, lvl, pitch, volume, channel)
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

	ent:StopSound(snd)
end

--- Returns a list of components linked to a processor. Can also return vehicles linked to a HUD, but only through the server.
-- @return table A list of components linked to the entity
function ents_methods:getLinkedComponents()
	local ent = getent(self)
	local list = {}
	if ent:GetClass() == "starfall_processor" then
		for k, v in ipairs(ents.FindByClass("starfall_screen")) do
			if v.link == ent then list[#list+1] = ewrap(v) end
		end
		for k, v in ipairs(ents.FindByClass("starfall_hud")) do
			if v.link == ent then list[#list+1] = ewrap(v) end
		end
	elseif ent:GetClass() == "starfall_hud" then
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
-- @param number|string? attachment Optional attachment name or ID.
-- @param number|string? bone Optional bone name or ID. Can't be used at the same time as attachment
function ents_methods:setParent(parent, attachment, bone)
	local child = getent(self)
	checkpermission(instance, child, "entities.setParent")
	if CLIENT and debug.getmetatable(child) ~= SF.Cl_Hologram_Meta then SF.Throw("Only clientside holograms can be parented in the CLIENT realm!", 2) end
	if attachment ~= nil and bone ~= nil then SF.Throw("Arguments `attachment` and `bone` are mutually exclusive!", 2) end
	if parent ~= nil then
		parent = getent(parent)
		if parent:IsPlayer() and not child.IsSFHologram then SF.Throw("Only holograms can be parented to players!", 2) end
		local param, type
		if bone ~= nil then
			if isstring(bone) then
				bone = parent:LookupBone(bone) or -1
			elseif not isnumber(bone) then
				SF.ThrowTypeError("string or number", SF.GetType(bone), 2)
			end
			if bone < 0 or bone > 255 then SF.Throw("Invalid bone provided!", 2) end
			type = "bone"
			param = bone
		elseif attachment ~= nil then
			if CLIENT then SF.Throw("Parenting to an attachment is not supported in clientside!", 2) end
			if isstring(attachment) then
				if parent:LookupAttachment(attachment) < 1 then SF.Throw("Invalid attachment provided!", 2) end
			elseif isnumber(attachment) then
				local attachments = parent:GetAttachments()
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

	local rendermode = (clr.a == 255 and RENDERMODE_NORMAL or RENDERMODE_TRANSALPHA)
	ent:SetColor(clr)
	ent:SetRenderMode(rendermode)
	if SERVER then duplicator.StoreEntityModifier(ent, "colour", { Color = {r = clr[1], g = clr[2], b = clr[3], a = clr[4]}, RenderMode = rendermode }) end
end

--- Sets the whether an entity should be drawn or not. If serverside, will also prevent networking the entity to the client. Don't use serverside on a starfall if you want its client code to work.
-- @shared
-- @param boolean draw Whether to draw the entity or not.
function ents_methods:setNoDraw(draw)
	local ent = getent(self)
	checkpermission(instance, ent, "entities.setRenderProperty")

	ent:SetNoDraw(draw and true or false)
end

--- Checks whether the entity should be drawn
-- @shared
-- @return boolean True if should draw, False otherwise
function ents_methods:getNoDraw()
	return getent(self):GetNoDraw()
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

	ent:SetMaterial(material)
	if SERVER then duplicator.StoreEntityModifier(ent, "material", { MaterialOverride = material }) end
end

--- Sets the submaterial of the entity
-- @shared
-- @param number index Submaterial index.
-- @param string material New material name.
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

	ent:SetBodygroup(bodygroup, value)
end

--- Returns the bodygroup value of the entity with given index
-- @shared
-- @param number id The bodygroup's number index
-- @return number The bodygroup value
function ents_methods:getBodygroup(id)
	checkluatype(id, TYPE_NUMBER)
	checkbodygroup(id)
	return getent(self):GetBodygroup(id)
end

--- Returns a list of all bodygroups of the entity
-- @shared
-- @return table Bodygroups as a table of BodyGroupDatas. https://wiki.facepunch.com/gmod/Structures/BodyGroupData
function ents_methods:getBodygroups()
	return getent(self):GetBodyGroups()
end

--- Returns the bodygroup index of the entity with given name
-- @shared
-- @param string name The bodygroup's string name
-- @return number The bodygroup index
function ents_methods:lookupBodygroup(name)
	checkluatype(name, TYPE_STRING)
	return getent(self):FindBodygroupByName(name)
end

--- Returns the bodygroup name of the entity with given index
-- @shared
-- @param number id The bodygroup's number index
-- @return string The bodygroup name
function ents_methods:getBodygroupName(id)
	checkluatype(id, TYPE_NUMBER)
	checkbodygroup(id)
	return getent(self):GetBodygroupName(id)
end

--- Returns the number of possible values for this bodygroup.
-- Note that bodygroups are 0-indexed, so this will not return the maximum allowed value.
-- @param number id The ID of the bodygroup to get the count for.
-- @return number Number of values of specified bodygroup, or 0 if there are none.
function ents_methods:getBodygroupCount(id)
	checkluatype(id, TYPE_NUMBER)
	checkbodygroup(id)
	return getent(self):GetBodygroupCount(id)
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

	ent:SetSkin(skinIndex)
end

--- Gets the skin number of the entity
-- @shared
-- @return number Skin number
function ents_methods:getSkin()
	return getent(self):GetSkin()
end

--- Returns the amount of skins of the entity
-- @shared
-- @return number The amount of skins
function ents_methods:getSkinCount()
	return getent(self):SkinCount()
end

--- Sets the render mode of the entity
-- @shared
-- @class function
-- @param number rendermode Rendermode to use. http://wiki.facepunch.com/gmod/Enums/RENDERMODE
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

--- Gets the render mode of the entity
-- @shared
-- @class function
-- @return number rendermode https://wiki.facepunch.com/gmod/Enums/RENDERMODE
function ents_methods:getRenderMode()
	return getent(self):GetRenderMode()
end

--- Sets the renderfx of the entity, most effects require entity's alpha to be less than 255 to take effect
-- @shared
-- @class function
-- @param number renderfx Renderfx to use. http://wiki.facepunch.com/gmod/Enums/kRenderFx
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

--- Gets the renderfx of the entity
-- @shared
-- @class function
-- @return number Renderfx, https://wiki.facepunch.com/gmod/Enums/kRenderFx
function ents_methods:getRenderFX()
	return getent(self):GetRenderFX()
end

--- Gets the parent of an entity
-- @shared
-- @return Entity? Entity's parent or nil if not parented
function ents_methods:getParent()
	return ewrap(getent(self):GetParent())
end

--- Gets the children (the parented entities) of an entity
-- @shared
-- @return table Table of parented children
function ents_methods:getChildren()
	return instance.Sanitize(getent(self):GetChildren())
end

--- Gets the attachment index the entity is parented to
-- @shared
-- @return number Index of the attachment the entity is parented to or 0
function ents_methods:getAttachmentParent()
	return getent(self):GetParentAttachment()
end

--- Gets the attachment index via the entity and it's attachment name
-- @shared
-- @param string name of the attachment to lookup
-- @return number Number of the attachment index, or 0 if it doesn't exist
function ents_methods:lookupAttachment(name)
	return getent(self):LookupAttachment(name)
end

--- Gets the position and angle of an attachment
-- @shared
-- @param number index The index of the attachment
-- @return Vector? Position, nil if the attachment doesn't exist
-- @return Angle? Orientation, nil if the attachment doesn't exist
function ents_methods:getAttachment(index)
	local t = getent(self):GetAttachment(index)
	if t then
		return vwrap(t.Pos), awrap(t.Ang)
	end
end

--- Returns a table of attachments
-- @shared
-- @return table? Table of attachment id and attachment name or nil
function ents_methods:getAttachments()
	return getent(self):GetAttachments()
end

--- Gets the collision group enum of the entity
-- @return number The collision group enum of the entity. https://wiki.facepunch.com/gmod/Enums/COLLISION_GROUP
function ents_methods:getCollisionGroup()
	return getent(self):GetCollisionGroup()
end

--- Gets the solid enum of the entity
-- @return number The solid enum of the entity. https://wiki.facepunch.com/gmod/Enums/SOLID
function ents_methods:getSolid()
	return getent(self):GetSolid()
end

--- Gets the solid flag enum of the entity
-- @return number The solid flag enum of the entity. https://wiki.facepunch.com/gmod/Enums/FSOLID
function ents_methods:getSolidFlags()
	return getent(self):GetSolidFlags()
end

--- Gets whether an entity is solid or not
-- @return boolean whether an entity is solid or not
function ents_methods:isSolid()
	return getent(self):IsSolid()
end

--- Gets the movetype enum of the entity
-- @return number The movetype enum of the entity. https://wiki.facepunch.com/gmod/Enums/MOVETYPE
function ents_methods:getMoveType()
	return getent(self):GetMoveType()
end

--- Converts a ragdoll bone id to the corresponding physobject id
-- @param number boneid The ragdoll boneid
-- @return number The physobj id
function ents_methods:translateBoneToPhysBone(boneid)
	return getent(self):TranslateBoneToPhysBone(boneid)
end

--- Converts a physobject id to the corresponding ragdoll bone id
-- @param number boneid The physobject id
-- @return number The ragdoll bone id
function ents_methods:translatePhysBoneToBone(boneid)
	return getent(self):TranslatePhysBoneToBone(boneid)
end

--- Gets the number of physicsobjects of an entity
-- @return number The number of physics objects on the entity
function ents_methods:getPhysicsObjectCount()
	return getent(self):GetPhysicsObjectCount()
end

--- Gets the main physics objects of an entity
-- @return PhysObj The main physics object of the entity
function ents_methods:getPhysicsObject()
	local ent = getent(self)
	if ent:IsWorld() then SF.Throw("Cannot get the world physobj.", 2) end
	return pwrap(ent:GetPhysicsObject())
end

--- Gets a physics objects of an entity
-- @param number id The physics object id (starts at 0)
-- @return PhysObj The physics object of the entity
function ents_methods:getPhysicsObjectNum(id)
	checkluatype(id, TYPE_NUMBER)
	return pwrap(getent(self):GetPhysicsObjectNum(id))
end

--- Returns the elasticity of the entity
-- @return number Elasticity
function ents_methods:getElasticity()
	return getent(self):GetElasticity()
end

--- Gets the color of an entity
-- @shared
-- @return Color Color
function ents_methods:getColor()
	return cwrap(getent(self):GetColor())
end

--- Gets the clipping of an entity
-- @shared
-- @return table Table containing the clipdata
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
-- @return boolean True if valid, false if not
function ents_methods:isValid()
	local ent = eunwrap(self)
	if ent then
		local isValid = ent.IsValid
		if isValid then
			return isValid(ent)
		end
	end
	return false
end

--- Checks if an entity is a player.
-- @shared
-- @return boolean True if player, false if not
function ents_methods:isPlayer()
	return getent(self):IsPlayer()
end

--- Checks if an entity is a weapon.
-- @shared
-- @return boolean True if weapon, false if not
function ents_methods:isWeapon()
	return getent(self):IsWeapon()
end

--- Checks if an entity is a vehicle.
-- @shared
-- @return boolean True if vehicle, false if not
function ents_methods:isVehicle()
	return getent(self):IsVehicle()
end

--- Checks if an entity is an npc.
-- @shared
-- @return boolean True if npc, false if not
function ents_methods:isNPC()
	return getent(self):IsNPC()
end

--- Checks if the entity ONGROUND flag is set
-- @shared
-- @return boolean If it's flag is set or not
function ents_methods:isOnGround()
	return getent(self):IsOnGround()
end

--- Returns if the entity is ignited
-- @shared
-- @return boolean If the entity is on fire or not
function ents_methods:isOnFire()
	return getent(self):IsOnFire()
end

--- Returns the starfall or expression2's name
-- @return string The name of the chip
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
-- @return string The author of the starfall chip.
function ents_methods:getChipAuthor()
	local ent = getent(self)
	if not ent.Starfall then SF.Throw("The entity isn't a starfall chip", 2) end

	return ent.author
end

--- Returns the current count for this Think's CPU Time of the specified starfall.
-- This value increases as more executions are done, may not be exactly as you want.
-- If used on screens, will show 0 if only rendering is done. Operations must be done in the Think loop for them to be counted.
-- @shared
-- @return number Current quota used this Think
function ents_methods:getQuotaUsed()
	local ent = getent(self)
	if not ent.Starfall then SF.Throw("The entity isn't a starfall chip", 2) end

	return ent.instance and ent.instance.cpu_total or 0
end

--- Gets the Average CPU Time in the buffer of the specified starfall or expression2.
-- @shared
-- @return number Average CPU Time of the buffer of the specified starfall or expression2.
function ents_methods:getQuotaAverage()
	local ent = getent(self)
	if ent.Starfall then
		return ent.instance and ent.instance:movingCPUAverage() or 0
	elseif ent:GetClass()=="gmod_wire_expression2" then
		return SERVER and ent.context.timebench or ent:GetOverlayData().timebench
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
	if ent.Starfall then
		return ent.instance and ent.instance.cpuQuota or 0
	elseif ent:GetClass()=="gmod_wire_expression2" then
		return GetConVarNumber("wire_expression2_quotatime")
	else
		SF.Throw("The entity isn't a starfall or expression2 chip", 2)
	end
end

if SERVER then
	--- Gets all players the specified starfall errored for.
	-- This excludes the owner of the starfall chip.
	-- @server
	-- @return table A table containing the errored players.
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
	
	--- Sets the health of the entity.
	-- @server
	-- @param number newhealth New health value.
	function ents_methods:setHealth(val)
		local ent = getent(self)
		checkpermission(instance, ent, "entities.setHealth")
		checkluatype(val, TYPE_NUMBER)
		ent:SetHealth(val)
	end
		
	--- Sets the maximum health for entity. Note, that you can still set entity's health above this amount with Entity:setHealth.
	-- @server
	-- @param number newmaxhealth New max health value.
	function ents_methods:setMaxHealth(val)
		local ent = getent(self)
		checkpermission(instance, ent, "entities.setMaxHealth")
		checkluatype(val, TYPE_NUMBER)
		ent:SetMaxHealth(val)
	end
		
	--- Stops the entity from being saved on duplication or map save.
	-- @server
	function ents_methods:doNotDuplicate()
		local ent = getent(self)
		checkpermission(instance, ent, "entities.doNotDuplicate")
		ent.DoNotDuplicate = true
	end
end

--- Returns the EntIndex of the entity
-- @shared
-- @return number The numerical index of the entity
function ents_methods:entIndex()
	return getent(self):EntIndex()
end

--- Returns the class of the entity
-- @shared
-- @return string The string class name
function ents_methods:getClass()
	return getent(self):GetClass()
end

--- Returns the position of the entity
-- @shared
-- @return Vector The position vector
function ents_methods:getPos()
	return vwrap(getent(self):GetPos())
end

--- Returns how submerged the entity is in water
-- @shared
-- @return number The water level. 0 none, 1 slightly, 2 at least halfway, 3 all the way
function ents_methods:getWaterLevel()
	return getent(self):WaterLevel()
end

--- Returns the ragdoll bone index given a bone name
-- @shared
-- @param string name The bone's string name
-- @return number The bone index
function ents_methods:lookupBone(name)
	checkluatype(name, TYPE_STRING)
	return getent(self):LookupBone(name)
end

--- Returns the matrix of the entity's bone. Note: this method is slow/doesnt work well if the entity isn't animated.
-- @shared
-- @param number? bone Bone index. (def 0)
-- @return VMatrix The matrix
function ents_methods:getBoneMatrix(bone)
	if bone == nil then bone = 0 else checkluatype(bone, TYPE_NUMBER) end

	return mwrap(getent(self):GetBoneMatrix(bone))
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

	ent:SetBoneMatrix(bone, matrix)
end

--- Returns the world transform matrix of the entity
-- @shared
-- @return VMatrix The matrix
function ents_methods:getMatrix()
	return mwrap(getent(self):GetWorldTransformMatrix())
end

--- Returns the number of an entity's bones
-- @shared
-- @return number Number of bones
function ents_methods:getBoneCount()
	return getent(self):GetBoneCount()
end

--- Returns the name of an entity's bone
-- @shared
-- @param number? bone Bone index. (def 0)
-- @return string Name of the bone
function ents_methods:getBoneName(bone)
	if bone == nil then bone = 0 else checkluatype(bone, TYPE_NUMBER) end
	return getent(self):GetBoneName(bone)
end

--- Returns the parent index of an entity's bone
-- @shared
-- @param number? bone Bone index. (def 0)
-- @return number Parent index of the bone. Returns -1 on error
function ents_methods:getBoneParent(bone)
	if bone == nil then bone = 0 else checkluatype(bone, TYPE_NUMBER) end
	return getent(self):GetBoneParent(bone)
end

--- Returns the bone's position and angle in world coordinates
-- @shared
-- @param number? bone Bone index. (def 0)
-- @return Vector Position of the bone
-- @return Angle Angle of the bone
function ents_methods:getBonePosition(bone)
	if bone == nil then bone = 0 else checkluatype(bone, TYPE_NUMBER) end
	local pos, ang = getent(self):GetBonePosition(bone)
	if not pos then SF.Throw("Invalid bone ("..bone..")!",2) end
	return vwrap(pos), awrap(ang)
end

--- Returns the manipulate angle of the bone (relative to its default angle)
-- @shared
-- @param number bone Bone index. (def 0)
-- @return Angle Manipulate angle of the bone
function ents_methods:getManipulateBoneAngles(bone)
	if bone == nil then bone = 0 else checkluatype(bone, TYPE_NUMBER) end
	return awrap(getent(self):GetManipulateBoneAngles(bone))
end

--- Returns the number manipulate jiggle of the bone (0 - 255)
-- @shared
-- @param number? bone Bone index. (def 0)
-- @return number Manipulate jiggle of the bone
function ents_methods:getManipulateBoneJiggle(bone)
	if bone == nil then bone = 0 else checkluatype(bone, TYPE_NUMBER) end
	return getent(self):GetManipulateBoneJiggle(bone)
end

--- Returns the vector manipulate position of the bone (relative to its default position)
-- @shared
-- @param number bone Bone index. (def 0)
-- @return Vector Manipulate position of the bone
function ents_methods:getManipulateBonePosition(bone)
	if bone == nil then bone = 0 else checkluatype(bone, TYPE_NUMBER) end
	return vwrap(getent(self):GetManipulateBonePosition(bone))
end

--- Returns the vector manipulate scale of the bone
-- @shared
-- @param number bone Bone index. (def 0)
-- @return Vector Manipulate scale of the bone
function ents_methods:getManipulateBoneScale(bone)
	if bone == nil then bone = 0 else checkluatype(bone, TYPE_NUMBER) end
	return vwrap(getent(self):GetManipulateBoneScale(bone))
end

--- Returns the x, y, z size of the entity's outer bounding box (local to the entity)
-- @shared
-- @return Vector The outer bounding box size
function ents_methods:obbSize()
	local ent = getent(self)
	return vwrap(ent:OBBMaxs() - ent:OBBMins())
end

--- Returns the local position of the entity's outer bounding box
-- @shared
-- @return Vector The position vector of the outer bounding box center
function ents_methods:obbCenter()
	return vwrap(getent(self):OBBCenter())
end

--- Returns the world position of the entity's outer bounding box
-- @shared
-- @return Vector The position vector of the outer bounding box center
function ents_methods:obbCenterW()
	local ent = getent(self)
	return vwrap(ent:LocalToWorld(ent:OBBCenter()))
end

--- Returns min local bounding box vector of the entity
-- @shared
-- @return Vector The min bounding box vector
function ents_methods:obbMins()
	return vwrap(getent(self):OBBMins())
end

--- Returns max local bounding box vector of the entity
-- @shared
-- @return Vector The max bounding box vector
function ents_methods:obbMaxs()
	return vwrap(getent(self):OBBMaxs())
end

--- Returns Entity axis aligned bounding box in world coordinates
-- @shared
-- @return Vector The min bounding box vector
-- @return Vector The max bounding box vector
function ents_methods:worldSpaceAABB()
	local a, b = getent(self):WorldSpaceAABB()
	return vwrap(a), vwrap(b)
end

--- Returns the local position of the entity's mass center
-- @shared
-- @return Vector The position vector of the mass center
function ents_methods:getMassCenter()
	local ent = getent(self)
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end
	return vwrap(phys:GetMassCenter())
end

--- Returns the world position of the entity's mass center
-- @shared
-- @return Vector The position vector of the mass center
function ents_methods:getMassCenterW()
	local ent = getent(self)
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end
	return vwrap(ent:LocalToWorld(phys:GetMassCenter()))
end

--- Returns the angle of the entity
-- @shared
-- @return Angle The angle
function ents_methods:getAngles()
	return awrap(getent(self):GetAngles())
end

--- Returns the mass of the entity
-- @shared
-- @return number The numerical mass
function ents_methods:getMass()
	local ent = getent(self)
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end

	return phys:GetMass()
end

--- Returns the principle moments of inertia of the entity
-- @shared
-- @return Vector The principle moments of inertia as a vector
function ents_methods:getInertia()
	local ent = getent(self)
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end

	return vwrap(phys:GetInertia())
end

--- Returns the velocity of the entity
-- @shared
-- @return Vector The velocity vector
function ents_methods:getVelocity()
	return vwrap(getent(self):GetVelocity())
end

--- Gets the velocity of the entity in its local coordinate system
-- @shared
-- @return Vector Vector velocity of the physics object local to itself
function ents_methods:getLocalVelocity()
	local ent = getent(self)
	return vwrap(ent:WorldToLocal(ent:GetVelocity() + ent:GetPos()))
end

--- Returns the angular velocity of the entity
-- @shared
-- @return Vector The angular velocity as a vector
function ents_methods:getAngleVelocity()
	local phys = getent(self):GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end
	return vwrap(phys:GetAngleVelocity())
end

--- Returns the angular velocity of the entity
-- @shared
-- @return Angle The angular velocity as an angle
function ents_methods:getAngleVelocityAngle()
	local phys = getent(self):GetPhysicsObject()
	if not phys:IsValid() then SF.Throw("Physics object is invalid", 2) end
	local vec = phys:GetAngleVelocity()
	return awrap(Angle(vec.y, vec.z, vec.x))
end

--- Converts a vector in entity local space to world space
-- @shared
-- @param Vector data Local space vector
-- @return Vector data as world space vector
function ents_methods:localToWorld(data)
	return vwrap(getent(self):LocalToWorld(vunwrap(data)))
end

--- Converts a direction vector in entity local space to world space
-- @shared
-- @param Vector data Local space vector direction
-- @return Vector data as world space vector direction
function ents_methods:localToWorldVector(data)
	return vwrap(getent(self):GetPhysicsObject():LocalToWorldVector(vunwrap(data)))
end

--- Converts an angle in entity local space to world space
-- @shared
-- @param Angle data Local space angle
-- @return Angle data as world space angle
function ents_methods:localToWorldAngles(data)
	return awrap(getent(self):LocalToWorldAngles(aunwrap(data)))
end

--- Converts a vector in world space to entity local space
-- @shared
-- @param Vector data World space vector
-- @return Vector data as local space vector
function ents_methods:worldToLocal(data)
	return vwrap(getent(self):WorldToLocal(vunwrap(data)))
end

--- Converts a direction vector in world space to entity local space
-- @shared
-- @param Vector data World space direction vector
-- @return Vector data as local space direction vector
function ents_methods:worldToLocalVector(data)
	return vwrap(getent(self):GetPhysicsObject():WorldToLocalVector(vunwrap(data)))
end

--- Converts an angle in world space to entity local space
-- @shared
-- @param Angle data World space angle
-- @return Angle data as local space angle
function ents_methods:worldToLocalAngles(data)
	return awrap(getent(self):WorldToLocalAngles(aunwrap(data)))
end

--- Gets the animation number from the animation name
-- @param string animation Name of the animation
-- @return number Animation index or -1 if invalid
function ents_methods:lookupSequence(animation)
	checkluatype(animation, TYPE_STRING)

	return getent(self):LookupSequence(animation)
end

--- Gets the current playing sequence
-- @return number The sequence number
function ents_methods:getSequence()
	return getent(self):GetSequence()
end

--- Gets the name of a sequence
-- @param number id The id of the animation
-- @return string The sequence name
function ents_methods:getSequenceName(id)
	checkluatype(id, TYPE_NUMBER)
	return getent(self):GetSequenceName(id)
end

--- Gets various information about the specified animation
-- @param number id The ID of the animation
-- @return table Animation info
function ents_methods:getSequenceInfo(id)
	local ent = getent(self)
	checkluatype(id, TYPE_NUMBER)
	if id < 0 or id > ent:GetSequenceCount() - 1 then SF.Throw("Sequence ID out of bounds", 2) end
	local info = getent(self):GetSequenceInfo(id)
	info.bbmin = vwrap(info.bbmin)
	info.bbmax = vwrap(info.bbmax)
	return info
end

--- Returns all animations of the entity
-- @return table List of animations, starts at index 0 where value is the animation's name
function ents_methods:getSequenceList()
	return getent(self):GetSequenceList()
end

--- Gets the number of animations the entity has
-- @return number Count of entity's animations
function ents_methods:getSequenceCount()
	return getent(self):GetSequenceCount()
end

--- Checks whether the animation is playing
-- @return boolean True if the animation is currently playing, False otherwise
function ents_methods:isSequenceFinished()
	return getent(self):IsSequenceFinished()
end

--- Get the length of an animation
-- @param number? id (Optional) The id of the sequence, or will default to the currently playing sequence
-- @return number Length of the animation in seconds
function ents_methods:sequenceDuration(id)
	local ent = getent(self)
	if id~=nil then checkluatype(id, TYPE_NUMBER) end

	return ent:SequenceDuration(id)
end

--- Set the pose value of an animation. Turret/Head angles for example.
-- @param string pose Name of the pose parameter
-- @param number value Value to set it to.
function ents_methods:setPose(pose, value)
	local ent = getent(self)
	checkpermission(instance, ent, "entities.setRenderProperty")

	ent:SetPoseParameter(pose, value)
end

--- Get the pose value of an animation
-- @param string pose Pose parameter name
-- @return number Value of the pose parameter
function ents_methods:getPose(pose)
	return getent(self):GetPoseParameter(pose)
end

--- Returns a table of flexname -> flexid pairs for use in flex functions.
-- @return table Table of flexes
function ents_methods:getFlexes()
	local ent = getent(self)
	local flexes = {}
	for i = 0, ent:GetFlexNum()-1 do
		flexes[ent:GetFlexName(i)] = i
	end
	return flexes
end

--- Returns the ID of the flex based on given name.
-- @param string flexname The name of the flex to get the ID of. Case sensitive.
-- @return number The ID of the flex based on given name.
function ents_methods:getFlexByName(name)
	local ent = getent(self)
	checkluatype(name, TYPE_STRING)
	return ent:GetFlexIDByName(name)
end

--- Returns flex name.
-- @param number flexid The flex id to look up name of.
-- @return string The flex name
function ents_methods:getFlexName(id)
	local ent = getent(self)
	checkluatype(id, TYPE_NUMBER)
	return ent:GetFlexName(id)
end

--- Returns whether or not the the entity has had flex manipulations performed with Entity:setFlexWeight or Entity:setFlexScale.
-- @return boolean True if the entity has flex manipulations, false otherwise.
function ents_methods:hasFlexManipulations()
	local ent = getent(self)
	return ent:HasFlexManipulator()
end

--- Gets the weight (value) of a flex.
-- @param number flexid The id of the flex
-- @return number The weight of the flex
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

	if flexid < 0 or flexid >= ent:GetFlexNum() then
		SF.Throw("Invalid flex: "..flexid, 2)
	end

	ent:SetFlexWeight(flexid, weight)
end

--- Gets the scale of the entity flexes
-- @return number The scale of the flexes
function ents_methods:getFlexScale()
	return getent(self):GetFlexScale()
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

	ent:SetFlexScale(scale)
end

--- Gets the model of an entity
-- @shared
-- @return string Model of the entity
function ents_methods:getModel()
	return getent(self):GetModel()
end

--- Returns the entity's model bounds. This is different than the collision bounds/hull.
-- This is not scaled with Entity:SetModelScale and will return the model's original, unmodified mins and maxs.
-- @shared
-- @return Vector Minimum vector of the bounds
-- @return Vector Maximum vector of the bounds
function ents_methods:getModelBounds()
	local minvec, maxvec = getent(self):GetModelBounds()
	return vwrap(minvec), vwrap(maxvec)
end

--- Returns the contents of the entity's current model
-- @shared
-- @return number Contents of the entity's model. https://wiki.facepunch.com/gmod/Enums/CONTENTS
function ents_methods:getModelContents()
	return getent(self):GetModelContents()
end

--- Returns the model's radius
-- @shared
-- @return number Radius of the model
function ents_methods:getModelRadius()
	return getent(self):GetModelRadius()
end

--- Returns the model's scale
-- @shared
-- @return number Scale of the model
function ents_methods:getModelScale()
	return getent(self):GetModelScale()
end

--- Gets the max health of an entity
-- @shared
-- @return number Max Health of the entity
function ents_methods:getMaxHealth()
	return getent(self):GetMaxHealth()
end

--- Gets the health of an entity
-- @shared
-- @return number Health of the entity
function ents_methods:getHealth()
	return getent(self):Health()
end

--- Gets the entity's eye angles
-- @shared
-- @return Angle Angles of the entity's eyes
function ents_methods:getEyeAngles()
	return awrap(getent(self):EyeAngles())
end

--- Gets the entity's eye position
-- @shared
-- @return Vector Eye position of the entity
-- @return Vector? In case of a ragdoll, the position of the second eye
function ents_methods:getEyePos()
	local pos1, pos2 = getent(self):EyePos()
	if pos2 then
		return vwrap(pos1), vwrap(pos2)
	end
	return vwrap(pos1)
end

--- Gets an entities' material
-- @shared
-- @class function
-- @return string String material
function ents_methods:getMaterial()
	return getent(self):GetMaterial() or ""
end

--- Gets an entities' submaterial
-- @shared
-- @class function
-- @param number index Number index of the sub material
-- @return string String material
function ents_methods:getSubMaterial(index)
	checkluatype(index, TYPE_NUMBER)
	if index<0 or index>31 then SF.Throw("Index must be an int in range 0 - 31") end

	return getent(self):GetSubMaterial(index) or ""
end

--- Gets an entities' material list
-- @shared
-- @class function
-- @return table Material
function ents_methods:getMaterials()
	return getent(self):GetMaterials() or {}
end

--- Gets the entity's up vector
-- @shared
-- @return Vector Vector up
function ents_methods:getUp()
	return vwrap(getent(self):GetUp())
end

--- Gets the entity's right vector
-- @shared
-- @return Vector Vector right
function ents_methods:getRight()
	return vwrap(getent(self):GetRight())
end

--- Gets the entity's forward vector
-- @shared
-- @return Vector Vector forward
function ents_methods:getForward()
	return vwrap(getent(self):GetForward())
end

--- Returns the timer.curtime() time the entity was created on
-- @shared
-- @return number Seconds relative to server map start
function ents_methods:getCreationTime()
	return getent(self):GetCreationTime()
end

--- Checks if an engine effect is applied to the entity
-- @shared
-- @param number effect The effect to check. EF table values
-- @return boolean True or false
function ents_methods:isEffectActive(effect)
	checkluatype(effect, TYPE_NUMBER)

	return getent(self):IsEffectActive(effect)
end

--- Marks entity as persistent, disallowing players from physgunning it. Persistent entities save on server shutdown when sbox_persist is set
-- @shared
-- @param boolean persist True to make persistent
function ents_methods:setPersistent(persist)
	checkluatype(persist, TYPE_BOOL)
	local ent = getent(self)
	checkpermission(instance, ent, "entities.setPersistent")
	ent:SetPersistent(persist)
end

--- Checks if entity is marked as persistent
-- @shared
-- @return boolean True if the entity is persistent
function ents_methods:getPersistent()
	return getent(self):GetPersistent()
end

--- Returns the game assigned owner of an entity. This doesn't take CPPI into account and will return nil for most standard entities.
-- Used on entities with custom physics like held SWEPs and fired bullets in which case player entity should be returned.
-- @shared
-- @return Entity Owner
function ents_methods:entOwner()
	return owrap(getent(self):GetOwner())
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
	local mins, maxs = getent(self):GetHitBoxBounds(hitbox, group)
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
	return getent(self):GetHitBoxCount(group)
end

--- Gets the bone the given hitbox is attached to.
-- @shared
-- @param number hitbox The number of the hitbox.
-- @param number group The number of the hitbox group, 0 in most cases.
-- @return number Bone ID
function ents_methods:getHitBoxBone(hitbox, group)
	checkluatype(hitbox, TYPE_NUMBER)
	checkluatype(group, TYPE_NUMBER)
	return getent(self):GetHitBoxBone(hitbox, group)
end

--- Returns entity's current hit box set.
-- @shared
-- @return number? Hitbox set number, nil if entity has no hitboxes.
-- @return string? Hitbox set name, nil if entity has no hitboxes.
function ents_methods:getHitBoxSet()
	return getent(self):GetHitboxSet()
end

--- Returns entity's number of hitbox sets.
-- @shared
-- @return number Number of hitbox sets.
function ents_methods:getHitBoxSetCount()
	return getent(self):GetHitboxSetCount()
end

--- Gets the hit group of a given hitbox in a given hitbox set.
-- @shared
-- @param number hitbox The number of the hit box.
-- @param number hitboxset The number of the hit box set. This should be 0 in most cases.
-- @return number The hitbox group of given hitbox. See https://wiki.facepunch.com/gmod/Enums/HITGROUP
function ents_methods:getHitBoxHitGroup(hitbox, hitboxset)
	checkluatype(hitbox, TYPE_NUMBER)
	checkluatype(hitboxset, TYPE_NUMBER)
	return getent(self):GetHitBoxHitGroup(hitbox, hitboxset)
end

--- Returns a table of brushes surfaces for brush model entities.
-- @shared
-- @return table Table of SurfaceInfos if the entity has a brush model, or no value otherwise.
function ents_methods:getBrushSurfaces()
	local t = getent(self):GetBrushSurfaces()
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
	local origin, normal, distance = getent(self):GetBrushPlane(id)
	return vwrap(origin), vwrap(normal), distance
end

--- Returns the amount of planes of the brush entity
-- @shared
-- @return number The amount of brush planes
function ents_methods:getBrushPlaneCount()
	return getent(self):GetBrushPlaneCount()
end

--- Gets a datatable angle
-- @shared
-- @param number key The number key. Valid keys are 0 - 31
-- @return Angle? The angle or nil if it doesn't exist
function ents_methods:getDTAngle(key)
	checkluatype(key, TYPE_NUMBER)
	if key<0 or key>31 then SF.Throw("Key must be a int in range 0 - 31") end
	return awrap(getent(self):GetDTAngle(key))
end

--- Gets a datatable boolean
-- @shared
-- @param number key The number key. Valid keys are 0 - 31
-- @return boolean? The boolean or nil if it doesn't exist
function ents_methods:getDTBool(key)
	checkluatype(key, TYPE_NUMBER)
	if key<0 or key>31 then SF.Throw("Key must be a int in range 0 - 31") end
	return getent(self):GetDTBool(key)
end

--- Gets a datatable entity
-- @shared
-- @param number key The number key. Valid keys are 0 - 31
-- @return Entity? The entity or nil if it doesn't exist
function ents_methods:getDTEntity(key)
	checkluatype(key, TYPE_NUMBER)
	if key<0 or key>31 then SF.Throw("Key must be a int in range 0 - 31") end
	return owrap(getent(self):GetDTEntity(key))
end

--- Gets a datatable float
-- @shared
-- @param number key The number key. Valid keys are 0 - 31
-- @return number? The float or nil if it doesn't exist
function ents_methods:getDTFloat(key)
	checkluatype(key, TYPE_NUMBER)
	if key<0 or key>31 then SF.Throw("Key must be a int in range 0 - 31") end
	return getent(self):GetDTFloat(key)
end

--- Gets a datatable int
-- @shared
-- @param number key The number key. Valid keys are 0 - 31
-- @return number? The int or nil if it doesn't exist
function ents_methods:getDTInt(key)
	checkluatype(key, TYPE_NUMBER)
	if key<0 or key>31 then SF.Throw("Key must be a int in range 0 - 31") end
	return getent(self):GetDTInt(key)
end

--- Gets a datatable string
-- @shared
-- @param number key The number key. Valid keys are 0 - 31
-- @return string? The string or nil if it doesn't exist
function ents_methods:getDTString(key)
	checkluatype(key, TYPE_NUMBER)
	if key<0 or key>31 then SF.Throw("Key must be a int in range 0 - 31") end
	return getent(self):GetDTString(key)
end

--- Gets a datatable vector
-- @shared
-- @param number key The number key. Valid keys are 0 - 31
-- @return Vector? The vector or nil if it doesn't exist
function ents_methods:getDTVector(key)
	checkluatype(key, TYPE_NUMBER)
	if key<0 or key>31 then SF.Throw("Key must be a int in range 0 - 31") end
	return vwrap(getent(self):GetDTVector(key))
end

--- Gets a networked variable of an entity
-- @shared
-- @param string key The string key to get
-- @return any The object associated with that key or nil if it's not set
function ents_methods:getNWVar(key)
	checkluatype(key, TYPE_STRING)
	-- GetNW* returns whatever the key is tied to regardless of the function name
	local result = getent(self):GetNWEntity(key)
	if result == NULL then return end
	return owrap(result)
end

--- Gets the table of all networked things on an entity
-- @shared
-- @return table The table of networked objects
function ents_methods:getNWVarTable()
	return instance.Sanitize(getent(self):GetNWVarTable())
end

--- Returns the distance between the center of the entity's bounding box and whichever corner of the bounding box is farthest away.
-- @shared
-- @return number The radius of the bounding box, or 0 for some entities such as worldspawn
function ents_methods:getBoundingRadius()
	return getent(self):BoundingRadius()
end

--- Returns whether the entity is dormant or not, i.e. whether or not information about the entity is being sent to your client. Not to be confused with PhysObj:isAsleep
-- Clientside, this will usually be true if the object is outside of your PVS (potentially visible set).
-- Serverside, this will almost always be false.
-- @shared
-- @return boolean Whether entity is dormant or not.
function ents_methods:isDormant()
	return getent(self):IsDormant()
end

--- Performs a Ray-Orientated Bounding Box intersection from the given position to the origin of the OBBox with the entity and returns the hit position on the OBBox.
-- This relies on the entity having a collision mesh (not a physics object) and will be affected by SOLID_NONE
-- @shared
-- @param Vector The vector to start the intersection from.
-- @return Vector The nearest hit point of the entity's bounding box in world coordinates, or Vector(0, 0, 0) for some entities such as worldspawn.
function ents_methods:getNearestPoint(pos)
	return vwrap(getent(self):NearestPoint(vunwrap(pos)))
end

--- Returns a table of save values for an entity.
-- These tables are not the same between the client and the server, and different entities may have different fields.
-- @shared
-- @param boolean showAll If set, shows all variables, not just the ones for save.
-- @return table A table containing all save values in key/value format. The value may be a sequential table (starting to 1) if the field in question is an array in engine.
function ents_methods:getSaveTable(showAll)
	return instance.Sanitize(getent(self):GetSaveTable(showAll and true or false))
end

--- Returns a variable from the entity's save table.
-- @shared
-- @param string variableName Name of the internal save table variable.
-- @return any The internal variable associated with the name.
function ents_methods:getInternalVariable(variableName)
	checkluatype(variableName, TYPE_STRING)
	local result = getent(self):GetInternalVariable(variableName)
	return istable(result) and instance.Sanitize(result) or owrap(result)
end

end
