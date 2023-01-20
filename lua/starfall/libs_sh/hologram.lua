-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege

registerprivilege("hologram.modify", "Modify holograms", "Allows the user to modify holograms", { entities = {} })
registerprivilege("hologram.create", "Create hologram", "Allows the user to create holograms", CLIENT and { client = {} } or nil)
registerprivilege("hologram.setRenderProperty", "RenderProperty", "Allows the user to change the rendering of an entity", { entities = {} })

local plyCount = SF.LimitObject("holograms", "holograms", 200, "The number of holograms allowed to spawn via Starfall scripts for a single player")
local maxclips = CreateConVar("sf_holograms_maxclips", "8", { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "The max number of clips per hologram entity")

SF.ResourceCounters.Holograms = {icon = "icon16/bricks.png", count = function(ply) return plyCount:get(ply).val end}

local entmeta = FindMetaTable("Entity")
local cl_hologram_meta = {
	__index = function(t,k,v)
		if k=="CPPIGetOwner" then return function(ent) return ent.SFHoloOwner end
		elseif k=="CPPICanTool" then return function(ent, pl) return ent.SFHoloOwner==pl end
		elseif k=="CPPICanPhysgun" then return function(ent, pl) return ent.SFHoloOwner==pl end
		else return entmeta.__index(t,k,v)
		end
	end,
	__newindex = entmeta.__newindex,
	__concat = entmeta.__concat,
	__tostring = entmeta.__tostring,
	__eq = entmeta.__eq,
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


local hologram_library = instance.Libraries.hologram
local hologram_methods, hologram_meta, wrap, unwrap = instance.Types.Hologram.Methods, instance.Types.Hologram, instance.Types.Hologram.Wrap, instance.Types.Hologram.Unwrap
local ents_methods, ent_meta, ewrap, eunwrap = instance.Types.Entity.Methods, instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local mtx_meta, mwrap, munwrap = instance.Types.VMatrix, instance.Types.VMatrix.Wrap, instance.Types.VMatrix.Unwrap

local getent
local holograms = {}
instance:AddHook("initialize", function()
	getent = instance.Types.Entity.GetEntity
	hologram_meta.__tostring = ent_meta.__tostring
end)

local function hologramOnDestroy(holo)
	holograms[holo] = nil
	plyCount:free(instance.player, 1)
end

local function removeHoloInternal(holo)
	holo:RemoveCallOnRemove("starfall_hologram_delete")
	hologramOnDestroy(holo)
	holo:Remove()
end

local function removeHolo(holo)
	if CLIENT and instance.data.render.isRendering then SF.Throw("Cannot remove while in rendering hook!", 3) end
	if not holo:IsValid() or not holo.IsSFHologram then SF.Throw("Invalid hologram!", 3) end
	return removeHoloInternal(holo)
end

local function removeAllHolosInternal()
	for holoent, _ in pairs(holograms) do 
		removeHoloInternal(holoent) 
	end
end

local function removeAllHolos()
	for holoent, _ in pairs(holograms) do 
		removeHolo(holoent) 
	end
end

instance:AddHook("deinitialize", function()
	if SERVER then
		removeAllHolosInternal()
	else
		if instance.data.render.isRendering then
			-- Removing hologram in render hook = crash
			timer.Simple(0, removeAllHolosInternal)
		else
			removeAllHolosInternal()
		end
	end
end)

local function getholo(self)
	local ent = unwrap(self)
	if ent:IsValid() then
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
	if not ent.IsSFHologram then SF.Throw("The entity isn't a hologram", 2) end
	return wrap(eunwrap(self))
end


--- Creates a hologram.
-- @param Vector pos The position to create the hologram
-- @param Angle ang The angle to create the hologram
-- @param string model The model to give the hologram
-- @param Vector? scale (Optional) The scale to give the hologram
-- @return Hologram The hologram object
function hologram_library.create(pos, ang, model, scale)
	checkpermission(instance, nil, "hologram.create")
	checkluatype(model, TYPE_STRING)

	local ply = instance.player
	pos = vunwrap(pos)
	ang = aunwrap(ang)
	model = SF.CheckModel(model, ply)

	plyCount:checkuse(ply, 1)

	local holoent
	if SERVER then
		holoent = ents.Create("starfall_hologram")
		if holoent and holoent:IsValid() then
			holoent:SetPos(SF.clampPos(pos))
			holoent:SetAngles(ang)
			holoent:SetModel(model)
			holoent:CallOnRemove("starfall_hologram_delete", hologramOnDestroy)
			holoent:Spawn()

			if CPPI then holoent:CPPISetOwner(ply == SF.Superuser and NULL or ply) end
			holograms[holoent] = true

			if scale~=nil then
				holoent:SetScale(vunwrap(scale))
			end
			plyCount:free(ply, -1)
			return wrap(holoent)
		end
	else
		holoent = ents.CreateClientside("starfall_hologram")
		if holoent and holoent:IsValid() then
			holoent.SFHoloOwner = ply

			holoent:SetPos(SF.clampPos(pos))
			holoent:SetAngles(ang)
			holoent:SetModel(model)
			holoent:SetRenderMode(RENDERGROUP_TRANSLUCENT)
			holoent:CallOnRemove("starfall_hologram_delete", hologramOnDestroy)
			
			debug.setmetatable(holoent, cl_hologram_meta)

			holoent:Spawn()
			holograms[holoent] = true

			if scale~=nil then
				holoent:SetScale(vunwrap(scale))
			else
				holoent:SetScale(Vector(1,1,1))
			end

			plyCount:free(ply, -1)
			return wrap(holoent)
		end
	end
end

--- Checks if a user can spawn anymore holograms.
-- @return boolean True if user can spawn holograms, False if not.
function hologram_library.canSpawn()
	if not SF.Permissions.hasAccess(instance,  nil, "hologram.create") then return false end
	return plyCount:check(instance.player) > 0
end

--- Checks how many holograms can be spawned
-- @return number Number of holograms able to be spawned
function hologram_library.hologramsLeft()
	if not SF.Permissions.hasAccess(instance,  nil, "hologram.create") then return 0 end
	return plyCount:check(instance.player)
end

if SERVER then
	--- Sets the hologram linear velocity
	-- @server
	-- @param Vector vel New velocity
	function hologram_methods:setVel(vel)
		local vel = vunwrap(vel)

		local holo = getholo(self)
		checkpermission(instance, holo, "hologram.setRenderProperty")

		holo:SetLocalVelocity(vel)
		holo.targetLocalVelocity = vel ~= vector_origin and vel or nil
	end

	--- Sets the hologram's angular velocity.
	-- @server
	-- @param Angle angvel *Vector* angular velocity.
	function hologram_methods:setAngVel(angvel)

		local holo = getholo(self)
		checkpermission(instance, holo, "hologram.setRenderProperty")

		holo:SetLocalAngularVelocity(aunwrap(angvel))
	end

	--- Sets the hologram's movetype
	-- @server
	-- @param number Movetype to set, either MOVETYPE.NOCLIP (default) or MOVETYPE.NONE
	function hologram_methods:setMoveType(move)
		if move ~= MOVETYPE_NONE and move ~= MOVETYPE_NOCLIP then
			SF.Throw("Invalid movetype provided, must be either MOVETYPE.NOCLIP or MOVETYPE.NONE", 2)
		end
		local holo = getholo(self)
		checkpermission(instance, holo, "hologram.setMoveType")
		holo:SetMoveType(move)
	end

else
	--- Sets the hologram's position.
	-- @shared
	-- @param Vector vec New position
	function hologram_methods:setPos(vec)
		local holo = getholo(self)
		local pos = SF.clampPos(vunwrap(vec))
		checkpermission(instance, holo, "hologram.setRenderProperty")

		holo:SetPos(pos)

		if CLIENT then
			local sfParent = holo.sfParent
			if sfParent and sfParent.parent and sfParent.parent:IsValid() then
				sfParent:updateTransform()
			end
		end
	end

	--- Sets the hologram's angles.
	-- @shared
	-- @param Angle ang New angles
	function hologram_methods:setAngles(ang)
		local holo = getholo(self)
		local angle = aunwrap(ang)
		checkpermission(instance, holo, "hologram.setRenderProperty")

		holo:SetAngles(angle)
		
		if CLIENT then
			local sfParent = holo.sfParent
			if sfParent and sfParent.parent and sfParent.parent:IsValid() then
				sfParent:updateTransform()
			end
		end
	end

	--- Sets the texture filtering function when viewing a close texture
	-- @client
	-- @param number val The filter function to use http://wiki.facepunch.com/gmod/Enums/TEXFILTER
	function hologram_methods:setFilterMag(val)
		local holo = getholo(self)

		checkpermission(instance, holo, "hologram.setRenderProperty")

		if val~=nil then
			checkluatype(val, TYPE_NUMBER)
			holo.filter_mag = val
		else
			holo.filter_mag = nil
		end
	end

	--- Sets the texture filtering function when viewing a far texture
	-- @client
	-- @param number val The filter function to use http://wiki.facepunch.com/gmod/Enums/TEXFILTER
	function hologram_methods:setFilterMin(val)
		local holo = getholo(self)

		checkpermission(instance, holo, "hologram.setRenderProperty")

		if val~=nil then
			checkluatype(val, TYPE_NUMBER)
			holo.filter_min = val
		else
			holo.filter_min = nil
		end
	end

	--- Sets a hologram entity's rendermatrix
	-- @client
	-- @param VMatrix mat Starfall matrix to use
	function hologram_methods:setRenderMatrix(mat)
		local holo = getholo(self)

		checkpermission(instance, holo, "hologram.setRenderProperty")

		if mat ~= nil then
			local matrix = munwrap(mat)
			if matrix:IsIdentity() then
				holo.HoloMatrix = nil
				holo:DisableMatrix("RenderMultiply")
			else
				holo.HoloMatrix = matrix
				holo:EnableMatrix("RenderMultiply", matrix)
			end
		else
			holo.HoloMatrix = nil
			holo:DisableMatrix("RenderMultiply")
		end
	end

	--- Manually draws a hologram, requires a 3d render context
	-- @client
	function hologram_methods:draw()
		if not instance.data.render.isRendering then SF.Throw("Not in rendering hook.", 2) end

		local holo = getholo(self)
		holo:SetupBones()
		holo:DrawModel()
	end
end

--- Updates a clip plane
-- @shared
-- @param number index Whatever number you want the clip to be
-- @param boolean enabled Whether the clip is enabled
-- @param Vector origin The center of the clip plane in world coordinates, or local to entity if it is specified
-- @param Vector normal The the direction of the clip plane in world coordinates, or local to entity if it is specified
-- @param Entity? entity (Optional) The entity to make coordinates local to, otherwise the world is used
function hologram_methods:setClip(index, enabled, origin, normal, entity)
	local holo = getholo(self)

	checkluatype(index, TYPE_NUMBER)
	checkluatype(enabled, TYPE_BOOL)

	if entity ~= nil then
		entity = getent(entity)
	end

	local origin, normal = vunwrap(origin), vunwrap(normal)

	checkpermission(instance, holo, "hologram.setRenderProperty")

	if enabled then
		local clips = holo.clips
		if not clips[index] then
			local max = maxclips:GetInt()
			if table.Count(clips)==max then
				SF.Throw("The maximum hologram clips is " .. max, 2)
			end
		end

		holo:SetClip(index, enabled, normal, origin, entity)
	else
		holo:SetClip(index, false)
	end
end

--- Sets the hologram scale. Basically the same as setRenderMatrix() with a scaled matrix
-- @shared
-- @param Vector scale Vector new scale
function hologram_methods:setScale(scale)
	local holo = getholo(self)
	local scale = vunwrap(scale)

	checkpermission(instance, holo, "hologram.setRenderProperty")

	holo:SetScale(scale)
end

--- Sets the hologram size in game units
-- @shared
-- @param Vector size Vector new size in game units
function hologram_methods:setSize(size)
	local holo = getholo(self)
	local size = vunwrap(size)

	checkpermission(instance, holo, "hologram.setRenderProperty")

	local bounds = holo:OBBMaxs() - holo:OBBMins()
	local scale = Vector(size[1] / bounds[1], size[2] / bounds[2], size[3] / bounds[3])
	holo:SetScale(scale)
end

--- Gets the hologram scale.
-- @shared
-- @return Vector Vector scale
function hologram_methods:getScale()
	return vwrap(getholo(self):GetScale())
end

--- Suppress Engine Lighting of a hologram. Disabled by default.
-- @shared
-- @param boolean suppress Boolean to represent if shading should be set or not.
function hologram_methods:suppressEngineLighting(suppress)
	local holo = getholo(self)

	checkluatype(suppress, TYPE_BOOL)

	checkpermission(instance, holo, "hologram.setRenderProperty")

	holo:SetSuppressEngineLighting(suppress)
end

--- Suppress Engine Lighting of a hologram. Disabled by default.
-- @shared
-- @return boolean Whether engine lighting is suppressed
function hologram_methods:getSuppressEngineLighting()
	return getholo(self):GetSuppressEngineLighting()
end

--- Sets the model of a hologram
-- @param string model string model path
function hologram_methods:setModel(model)
	local holo = getholo(self)
	checkluatype(model, TYPE_STRING)
	model = SF.NormalizePath(model)

	if (SERVER and not util.IsValidModel(model)) or (CLIENT and string.GetExtensionFromFilename(model) ~= "mdl") then SF.Throw("Invalid model", 2) end

	checkpermission(instance, holo, "hologram.setRenderProperty")

	holo:SetModel(model)
end

--- Animates a hologram
-- @shared
-- @param number|string animation Animation number or string name.
-- @param number? frame Optional int (Default 0) The starting frame number. Does nothing if nil
-- @param number? rate Optional float (Default 1) Frame speed. Does nothing if nil
function hologram_methods:setAnimation(animation, frame, rate)
	local holo = getholo(self)
	checkpermission(instance, holo, "hologram.setRenderProperty")

	if isstring(animation) then
		animation = holo:LookupSequence(animation)
	elseif not isnumber(animation) then
		SF.ThrowTypeError("number or string", SF.GetType(animation), 2)
	end

	if animation~=nil then
		holo:ResetSequence(animation)
		holo.AutomaticFrameAdvance = animation~=-1
	end
	if frame ~= nil then
		checkluatype(frame, TYPE_NUMBER)
		holo:SetCycle(frame)
	end
	if rate ~= nil then
		checkluatype(rate, TYPE_NUMBER)
		holo:SetPlaybackRate(rate)
	end
end

--- Applies engine effects to the hologram
-- @shared
-- @param number effect The effects to add. See EF Enums
function hologram_methods:addEffects(effect)
	checkluatype(effect, TYPE_NUMBER)

	local holo = getholo(self)
	checkpermission(instance, holo, "entities.setRenderProperty")

	holo:AddEffects(effect)
end

--- Removes engine effects from the hologram
-- @shared
-- @param number effect The effects to remove. See EF Enums
function hologram_methods:removeEffects(effect)
	checkluatype(effect, TYPE_NUMBER)

	local holo = getholo(self)
	checkpermission(instance, holo, "entities.setRenderProperty")

	holo:RemoveEffects(effect)
end

--- Removes a hologram
-- @shared
function hologram_methods:remove()
	local holo = getholo(self)
	checkpermission(instance, holo, "hologram.create")
	removeHolo(holo)
end

--- Removes all holograms created by the calling chip
-- @shared
function hologram_library.removeAll()
	removeAllHolos()
end


end
