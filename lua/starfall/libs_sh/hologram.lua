-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege
local ENT_META = FindMetaTable("Entity")
local Ent_GetTable = ENT_META.GetTable

registerprivilege("hologram.modify", "Modify holograms", "Allows the user to modify holograms", { entities = {} })
registerprivilege("hologram.create", "Create hologram", "Allows the user to create holograms", CLIENT and { client = {} } or nil)
registerprivilege("hologram.setRenderProperty", "RenderProperty", "Allows the user to change the rendering of an entity", { entities = {} })

local entList = SF.EntManager("holograms", "holograms", 200, "The number of holograms allowed to spawn via Starfall scripts for a single player")
local maxclips = CreateConVar("sf_holograms_maxclips", "8", { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "The max number of clips per hologram entity")

SF.ResourceCounters.Holograms = {icon = "icon16/bricks.png", count = function(ply) return entList:get(ply) end}

local cl_hologram_meta_overrides = {
	CPPIGetOwner = function(ent) return Ent_GetTable(ent).SFHoloOwner end,
	CPPICanTool = function(ent, pl) return Ent_GetTable(ent).SFHoloOwner==pl end,
	CPPICanPhysgun = function(ent, pl) return Ent_GetTable(ent).SFHoloOwner==pl end
}
local cl_hologram_meta = {
	__index = function(ent, k) return cl_hologram_meta_overrides[k] or ENT_META.__index(ent, k) end,
	__newindex = ENT_META.__newindex,
	__concat = ENT_META.__concat,
	__tostring = ENT_META.__tostring,
	__eq = ENT_META.__eq,
}
SF.Cl_Hologram_Meta = cl_hologram_meta

if SERVER then
	registerprivilege("hologram.setMoveType", "Set MoveType", "Allows the user to set hologram's movetype", { entities = {} })
end


--- Library for creating and manipulating physics-less models AKA "Holograms".
-- @name hologram
-- @class library
-- @libtbl hologram_library
SF.RegisterLibrary("hologram")

--- Hologram type
-- @name Hologram
-- @class type
-- @libtbl hologram_methods
SF.RegisterType("Hologram", true, false, nil, "Entity")



return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end
local Ent_AddEffects,Ent_DisableMatrix,Ent_DrawModel,Ent_EnableMatrix,Ent_GetColor4Part,Ent_GetTable,Ent_IsValid,Ent_LookupSequence,Ent_OBBMaxs,Ent_OBBMins,Ent_RemoveEffects,Ent_ResetSequence,Ent_SetAngles,Ent_SetCycle,Ent_SetLocalAngles,Ent_SetLocalAngularVelocity,Ent_SetLocalPos,Ent_SetLocalVelocity,Ent_SetModel,Ent_SetMoveType,Ent_SetPlaybackRate,Ent_SetPos,Ent_SetupBones,Ent_Spawn = ENT_META.AddEffects,ENT_META.DisableMatrix,ENT_META.DrawModel,ENT_META.EnableMatrix,ENT_META.GetColor4Part,ENT_META.GetTable,ENT_META.IsValid,ENT_META.LookupSequence,ENT_META.OBBMaxs,ENT_META.OBBMins,ENT_META.RemoveEffects,ENT_META.ResetSequence,ENT_META.SetAngles,ENT_META.SetCycle,ENT_META.SetLocalAngles,ENT_META.SetLocalAngularVelocity,ENT_META.SetLocalPos,ENT_META.SetLocalVelocity,ENT_META.SetModel,ENT_META.SetMoveType,ENT_META.SetPlaybackRate,ENT_META.SetPos,ENT_META.SetupBones,ENT_META.Spawn

local hologram_library = instance.Libraries.hologram
local hologram_methods, hologram_meta, wrap, unwrap = instance.Types.Hologram.Methods, instance.Types.Hologram, instance.Types.Hologram.Wrap, instance.Types.Hologram.Unwrap
local ents_methods, ent_meta, ewrap, eunwrap = instance.Types.Entity.Methods, instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local mtx_meta, mwrap, munwrap = instance.Types.VMatrix, instance.Types.VMatrix.Wrap, instance.Types.VMatrix.Unwrap

local VECTOR_PLAYER_COLOR_DISABLED = Vector(-1, -1, -1)

local getent
local vunwrap1, vunwrap2
local aunwrap1
instance:AddHook("initialize", function()
	getent = instance.Types.Entity.GetEntity
	hologram_meta.__tostring = ent_meta.__tostring
	vunwrap1, vunwrap2 = vec_meta.QuickUnwrap1, vec_meta.QuickUnwrap2
	aunwrap1 = ang_meta.QuickUnwrap1
end)

instance:AddHook("deinitialize", function()
	if SERVER or not instance.data.render.isRendering then
		entList:deinitialize(instance, true)
	else
		-- Removing hologram in render hook = crash
		timer.Simple(0, function()
			entList:deinitialize(instance, true)
		end)
	end
end)

local function getholo(self)
	local ent = hologram_meta.sf2sensitive[self]
	if Ent_IsValid(ent) then
		return ent
	else
		SF.Throw("Entity is not valid.", 3)
	end
end

--- Casts a hologram entity into the hologram type
-- @shared
-- @return Hologram Hologram instance
function ents_methods:toHologram()
	local ent = getent(self)
	if not Ent_GetTable(ent).IsSFHologram then SF.Throw("The entity isn't a hologram", 2) end
	return wrap(ent)
end

local scale_identity = Vector(1,1,1)
--- Creates a hologram.
-- @param Vector pos The position to create the hologram
-- @param Angle ang The angle to create the hologram
-- @param string model The model to give the hologram
-- @param Vector? scale (Optional) The scale to give the hologram
-- @return Hologram? The hologram object or nil if it failed to create
function hologram_library.create(pos, ang, model, scale)
	checkpermission(instance, nil, "hologram.create")
	checkluatype(model, TYPE_STRING)

	local ply = instance.player
	pos = SF.clampPos(vunwrap1(pos))
	ang = aunwrap1(ang)
	model = SF.CheckModel(model, ply)
	if scale~=nil then scale = vunwrap(scale) else scale = scale_identity end

	entList:checkuse(ply, 1)

	local holoent
	if SERVER then
		holoent = ents.Create("starfall_hologram")
	else
		if instance.data.render.isRendering then SF.Throw("Can't create hologram while rendering!", 2) end
		holoent = ents.CreateClientside("starfall_hologram")
		debug.setmetatable(holoent, cl_hologram_meta)
	end

	if Ent_IsValid(holoent) then
		local ent_tbl = Ent_GetTable(holoent)
		Ent_SetPos(holoent, pos)
		Ent_SetAngles(holoent, ang)
		Ent_SetModel(holoent, model)
		Ent_Spawn(holoent)
		ent_tbl.SetScale(holoent, scale)

		if SERVER then
			if CPPI then holoent:CPPISetOwner(ply == SF.Superuser and NULL or ply) end
		else
			ent_tbl.SFHoloOwner = ply
		end

		entList:register(instance, holoent)
		return wrap(holoent)
	end
end

--- Checks if a user can spawn anymore holograms.
-- @return boolean True if user can spawn holograms, False if not.
function hologram_library.canSpawn()
	if not SF.Permissions.hasAccess(instance,  nil, "hologram.create") then return false end
	return entList:check(instance.player) > 0
end

--- Checks how many holograms can be spawned
-- @return number Number of holograms able to be spawned
function hologram_library.hologramsLeft()
	if not SF.Permissions.hasAccess(instance,  nil, "hologram.create") then return 0 end
	return entList:check(instance.player)
end

if SERVER then
	--- Sets the hologram local linear velocity
	-- @server
	-- @param Vector vel New local velocity
	function hologram_methods:setLocalVelocity(vel)
		local holo = getholo(self)
		vel = vunwrap1(vel)
		checkpermission(instance, holo, "hologram.setRenderProperty")

		Ent_SetLocalVelocity(holo, vel)

		local sfParent = SF.Parent.Get(holo)
		if sfParent then sfParent.localVel:Set(vel) end
	end
	hologram_methods.setVel = hologram_methods.setLocalVelocity

	--- Sets the hologram's local angular velocity.
	-- @server
	-- @param Angle angvel *Vector* local angular velocity.
	function hologram_methods:setLocalAngularVelocity(angvel)
		local holo = getholo(self)
		angvel = aunwrap1(angvel)
		checkpermission(instance, holo, "hologram.setRenderProperty")

		Ent_SetLocalAngularVelocity(holo, angvel)

		local sfParent = SF.Parent.Get(holo)
		if sfParent then sfParent.localAngVel:Set(angvel) end
	end
	hologram_methods.setAngVel = hologram_methods.setLocalAngularVelocity

	--- Sets the hologram's movetype
	-- @server
	-- @param number Movetype to set, either MOVETYPE.NOCLIP (default) or MOVETYPE.NONE
	function hologram_methods:setMoveType(move)
		if move ~= MOVETYPE_NONE and move ~= MOVETYPE_NOCLIP then
			SF.Throw("Invalid movetype provided, must be either MOVETYPE.NOCLIP or MOVETYPE.NONE", 2)
		end
		local holo = getholo(self)
		checkpermission(instance, holo, "hologram.setMoveType")
		Ent_SetMoveType(holo, move)
	end

else
	--- Sets the hologram's position.
	-- @shared
	-- @param Vector vec New position
	function hologram_methods:setPos(vec)
		local holo = getholo(self)
		checkpermission(instance, holo, "hologram.setRenderProperty")

		Ent_SetPos(holo, SF.clampPos(vunwrap1(vec)))

		local sfParent = SF.Parent.Get(holo)
		if sfParent and Ent_IsValid(sfParent.parent) then sfParent:updateTransform() end
	end

	--- Sets the hologram's angles.
	-- @shared
	-- @param Angle ang New angles
	function hologram_methods:setAngles(ang)
		local holo = getholo(self)
		checkpermission(instance, holo, "hologram.setRenderProperty")

		Ent_SetAngles(holo, aunwrap1(ang))
		
		local sfParent = SF.Parent.Get(holo)
		if sfParent and Ent_IsValid(sfParent.parent) then sfParent:updateTransform() end
	end
	
	--- Sets the hologram's position local to its parent.
	-- @shared
	-- @param Vector vec New position
	function hologram_methods:setLocalPos(vec)
		local holo = getholo(self)
		checkpermission(instance, holo, "hologram.setRenderProperty")

		Ent_SetLocalPos(holo, SF.clampPos(vunwrap1(vec)))

		local sfParent = SF.Parent.Get(holo)
		if sfParent and Ent_IsValid(sfParent.parent) then sfParent:updateTransform() end
	end

	--- Sets the hologram's angles local to its parent.
	-- @shared
	-- @param Angle ang New angles
	function hologram_methods:setLocalAngles(ang)
		local holo = getholo(self)
		checkpermission(instance, holo, "hologram.setRenderProperty")

		Ent_SetLocalAngles(holo, aunwrap1(ang))
		
		local sfParent = SF.Parent.Get(holo)
		if sfParent and Ent_IsValid(sfParent.parent) then sfParent:updateTransform() end
	end

	--- Sets the texture filtering function when viewing a close texture
	-- @client
	-- @param number val The filter function to use http://wiki.facepunch.com/gmod/Enums/TEXFILTER
	function hologram_methods:setFilterMag(val)
		local holo = getholo(self)
		local ent_tbl = Ent_GetTable(holo)
		checkpermission(instance, holo, "hologram.setRenderProperty")

		if val~=nil then
			checkluatype(val, TYPE_NUMBER)
			ent_tbl.filter_mag = val
		else
			ent_tbl.filter_mag = nil
		end
		ent_tbl.renderstack:makeDirty()
	end

	--- Sets the texture filtering function when viewing a far texture
	-- @client
	-- @param number val The filter function to use http://wiki.facepunch.com/gmod/Enums/TEXFILTER
	function hologram_methods:setFilterMin(val)
		local holo = getholo(self)
		local ent_tbl = Ent_GetTable(holo)
		checkpermission(instance, holo, "hologram.setRenderProperty")

		if val~=nil then
			checkluatype(val, TYPE_NUMBER)
			ent_tbl.filter_min = val
		else
			ent_tbl.filter_min = nil
		end
		ent_tbl.renderstack:makeDirty()
	end

	--- Sets a hologram entity's rendermatrix
	-- @client
	-- @param VMatrix mat Starfall matrix to use
	function hologram_methods:setRenderMatrix(mat)
		local holo = getholo(self)
		local ent_tbl = Ent_GetTable(holo)
		checkpermission(instance, holo, "hologram.setRenderProperty")

		if mat ~= nil then
			local matrix = munwrap(mat)
			if matrix:IsIdentity() then
				ent_tbl.HoloMatrix = nil
				Ent_DisableMatrix(holo, "RenderMultiply")
			else
				ent_tbl.HoloMatrix = matrix
				Ent_EnableMatrix(holo, "RenderMultiply", matrix)
			end
		else
			ent_tbl.HoloMatrix = nil
			Ent_DisableMatrix(holo, "RenderMultiply")
		end
	end

	local render_GetColorModulation, render_GetBlend = render.GetColorModulation, render.GetBlend
	local render_SetColorModulation, render_SetBlend = render.SetColorModulation, render.SetBlend

	--- Manually draws a hologram, requires a 3d render context
	-- @client
	-- @param boolean? noTint If true, renders the hologram without its color and opacity. The default is for holograms to render with color or opacity, so use this argument if you need that behavior.
	function hologram_methods:draw(noTint)
		if not instance.data.render.isRendering then SF.Throw("Not in rendering hook.", 2) end

		local holo = getholo(self)
		Ent_SetupBones(holo)

		if noTint then
			Ent_DrawModel(holo)
		else
			local cr, cg, cb, ca = Ent_GetColor4Part(holo)
			local ocr, ocg, ocb = render_GetColorModulation()
			local oca = render_GetBlend()

			render_SetColorModulation(cr / 255, cg / 255, cb / 255)
			render_SetBlend(ca / 255)

			Ent_DrawModel(holo)

			render_SetColorModulation(ocr, ocg, ocb)
			render_SetBlend(oca)
		end
	end
end

--- Sets the player color of a hologram
-- The part of the model that is colored is determined by the model itself, and is different for each model
-- The format is Vector(r,g,b), and each color should be between 0 and 1
-- @shared
-- @param Vector? color The player color to use, or nil to disable
function hologram_methods:setPlayerColor(color)
	local holo = getholo(self)
	checkpermission(instance, holo, "hologram.setRenderProperty")
	color = color ~= nil and vunwrap(color) or VECTOR_PLAYER_COLOR_DISABLED
	Ent_GetTable(holo).SetPlayerColorInternal(holo, color)
end

--- Gets the player color of a hologram
-- The part of the model that is colored is determined by the model itself, and is different for each model
-- The format is Vector(r,g,b), and each color should be between 0 and 1
-- @shared
-- @return Vector? color The player color to use, or nil if disabled
function hologram_methods:getPlayerColor()
	local holo = getholo(self)
	local color = Ent_GetTable(holo).GetPlayerColorInternal(holo)
	if color == VECTOR_PLAYER_COLOR_DISABLED then return nil end
	return vwrap(color)
end

--- Updates a clip plane
-- @shared
-- @param number index Whatever number you want the clip to be
-- @param boolean enabled Whether the clip is enabled
-- @param Vector? origin The center of the clip plane in world coordinates, or local to entity if it is specified. Only used if enabled.
-- @param Vector? normal The the direction of the clip plane in world coordinates, or local to entity if it is specified. Only used if enabled.
-- @param Entity? entity (Optional) The entity to make coordinates local to, otherwise the world is used. Only used if enabled.
function hologram_methods:setClip(index, enabled, origin, normal, entity)
	local holo = getholo(self)
	local ent_tbl = Ent_GetTable(holo)

	checkluatype(index, TYPE_NUMBER)
	checkluatype(enabled, TYPE_BOOL)

	checkpermission(instance, holo, "hologram.setRenderProperty")

	if enabled then
		if entity ~= nil then
			entity = getent(entity)
		end

		origin, normal = vunwrap(origin), vunwrap(normal)

		local clips = holo.clips
		if not clips[index] then
			local max = maxclips:GetInt()
			if table.Count(clips)==max then
				SF.Throw("The maximum hologram clips is " .. max, 2)
			end
		end

		ent_tbl.SetClip(holo, index, enabled, normal, origin, entity)
	else
		ent_tbl.SetClip(holo, index, false)
	end
end

--- Sets the hologram scale. Basically the same as setRenderMatrix() with a scaled matrix
-- @shared
-- @param Vector scale Vector new scale
function hologram_methods:setScale(scale)
	local holo = getholo(self)
	checkpermission(instance, holo, "hologram.setRenderProperty")
	Ent_GetTable(holo).SetScale(holo, vunwrap(scale))
end

--- Sets the hologram size in game units
-- @shared
-- @param Vector size Vector new size in game units
function hologram_methods:setSize(size)
	local holo = getholo(self)
	checkpermission(instance, holo, "hologram.setRenderProperty")

	size = vunwrap1(size)
	local bounds = Ent_OBBMaxs(holo) - Ent_OBBMins(holo)
	local scale = Vector(size[1] / bounds[1], size[2] / bounds[2], size[3] / bounds[3])
	Ent_GetTable(holo).SetScale(holo, scale)
end

--- Gets the hologram scale.
-- @shared
-- @return Vector Vector scale
function hologram_methods:getScale()
	local holo = getholo(self)
	return vwrap(Ent_GetTable(holo).GetScale(holo))
end

--- Suppress Engine Lighting of a hologram. Disabled by default.
-- @shared
-- @param boolean suppress Boolean to represent if shading should be set or not.
function hologram_methods:suppressEngineLighting(suppress)
	local holo = getholo(self)
	checkluatype(suppress, TYPE_BOOL)
	checkpermission(instance, holo, "hologram.setRenderProperty")
	Ent_GetTable(holo).SetSuppressEngineLighting(holo, suppress)
end

--- Suppress Engine Lighting of a hologram. Disabled by default.
-- @shared
-- @return boolean Whether engine lighting is suppressed
function hologram_methods:getSuppressEngineLighting()
	local holo = getholo(self)
	return Ent_GetTable(holo).GetSuppressEngineLighting(holo)
end

--- Sets the model of a hologram
-- @param string model string model path
function hologram_methods:setModel(model)
	local holo = getholo(self)
	checkluatype(model, TYPE_STRING)
	model = SF.NormalizePath(model)

	if (SERVER and not util.IsValidModel(model)) or (CLIENT and string.GetExtensionFromFilename(model) ~= "mdl") then SF.Throw("Invalid model", 2) end

	checkpermission(instance, holo, "hologram.setRenderProperty")

	Ent_SetModel(holo, model)
end

--- Animates a hologram
-- @shared
-- @param number|string animation Animation number or string name.
-- @param number? frame Optional int (Default 0) The starting frame number. Does nothing if nil
-- @param number? rate Optional float (Default 1) Frame speed. Does nothing if nil
function hologram_methods:setAnimation(animation, frame, rate)
	local holo = getholo(self)
	local ent_tbl = Ent_GetTable(holo)
	checkpermission(instance, holo, "hologram.setRenderProperty")

	if isstring(animation) then
		animation = Ent_LookupSequence(holo, animation)
	elseif not isnumber(animation) then
		SF.ThrowTypeError("number or string", SF.GetType(animation), 2)
	end

	if animation~=nil then
		Ent_ResetSequence(holo, animation)
		ent_tbl.AutomaticFrameAdvance = animation~=-1
		if CLIENT then ent_tbl.renderstack:makeDirty() end
	end
	if frame ~= nil then
		checkluatype(frame, TYPE_NUMBER)
		Ent_SetCycle(holo, frame)
	end
	if rate ~= nil then
		checkluatype(rate, TYPE_NUMBER)
		Ent_SetPlaybackRate(holo, rate)
	end
end

--- Set the cull mode for a hologram.
-- @shared
-- @param number mode Cull mode. 0 for counter clock wise, 1 for clock wise
function hologram_methods:setCullMode(mode)
	checkluatype(mode, TYPE_NUMBER)
	local holo = getholo(self)
	checkpermission(instance, holo, "entities.setRenderProperty")

	Ent_GetTable(holo).SetCullMode(holo, mode==1)
end


--- Set the render group for a hologram.
-- @shared
-- @param number|nil group Render group. If unset, the engine will decide the render group based on the entity's materials. Can be RENDERGROUP.OPAQUE RENDERGROUP.TRANSLUCENT RENDERGROUP.BOTH RENDERGROUP.VIEWMODEL RENDERGROUP.VIEWMODEL.TRANSLUCENT RENDERGROUP.OPAQUE.BRUSH
function hologram_methods:setRenderGroup(group)
	local holo = getholo(self)
	checkpermission(instance, holo, "entities.setRenderProperty")
	
	if group then
		checkluatype(group, TYPE_NUMBER)
		if not SF.allowedRenderGroups[group] then SF.Throw("Invalid rendergroup!") end
		Ent_GetTable(holo).SetRenderGroupInternal(holo, group)
	else
		Ent_GetTable(holo).SetRenderGroupInternal(holo, -1)
	end
end

--- Applies engine effects to the hologram
-- @shared
-- @param number effect The effects to add. See EF Enums
function hologram_methods:addEffects(effect)
	checkluatype(effect, TYPE_NUMBER)
	local holo = getholo(self)
	checkpermission(instance, holo, "entities.setRenderProperty")

	Ent_AddEffects(holo, effect)
end

--- Removes engine effects from the hologram
-- @shared
-- @param number effect The effects to remove. See EF Enums
function hologram_methods:removeEffects(effect)
	checkluatype(effect, TYPE_NUMBER)
	local holo = getholo(self)
	checkpermission(instance, holo, "entities.setRenderProperty")

	Ent_RemoveEffects(holo, effect)
end

--- Removes a hologram
-- @shared
function hologram_methods:remove()
	if CLIENT and instance.data.render.isRendering then SF.Throw("Cannot remove while in rendering hook!", 2) end
	local holo = getholo(self)
	checkpermission(instance, holo, "hologram.create")

	entList:remove(instance, holo)
end

--- Removes all holograms created by the calling chip
-- @shared
function hologram_library.removeAll()
	if CLIENT and instance.data.render.isRendering then SF.Throw("Cannot remove while in rendering hook!", 2) end
	entList:clear(instance)
end


end
