
--- Library for creating and manipulating physics-less models AKA "Holograms".
-- @shared
local holograms_library = SF.RegisterLibrary("holograms")

--- Hologram type
local hologram_methods, hologram_metamethods = SF.RegisterType("Hologram")

local checktype = SF.CheckType
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check


SF.Holograms = {}

SF.Permissions.registerPrivilege("hologram.modify", "Modify holograms", "Allows the user to modify holograms", { entities = {} })

SF.Holograms.Methods = hologram_methods
SF.Holograms.Metatable = hologram_metamethods

local ang_meta, vec_meta, ent_meta
local wrap, unwrap, vwrap, vunwrap, aunwrap, ewrap, eunwrap
local hologramSENT
SF.AddHook("postload", function()
	ang_meta = SF.Angles.Metatable
	vec_meta = SF.Vectors.Metatable
	ent_meta = SF.Entities.Metatable

	vwrap = SF.Vectors.Wrap
	vunwrap = SF.Vectors.Unwrap
	aunwrap = SF.Angles.Unwrap
	ewrap = SF.Entities.Wrap
	eunwrap = SF.Entities.Unwrap

	SF.ApplyTypeDependencies(hologram_methods, hologram_metamethods, ent_meta)
	wrap, unwrap = SF.CreateWrapper(hologram_metamethods, true, false, nil, ent_meta)

	SF.Holograms.Wrap = wrap
	SF.Holograms.Unwrap = unwrap

	if CLIENT then
		hologramSENT = scripted_ents.GetStored( "starfall_hologram" )
		if not hologramSENT then
			hook.Add("Initialize","SF_GetHologramRenderFunc",function()
				hologramSENT = scripted_ents.GetStored( "starfall_hologram" )
			end)
		end
	end
end)

SF.Permissions.registerPrivilege("hologram.create", "Create hologram", "Allows the user to create holograms", CLIENT and { client = { default = 2 } } or nil)
SF.Permissions.registerPrivilege("hologram.setRenderProperty", "RenderProperty", "Allows the user to change the rendering of an entity", { entities = {} })

local plyCount = SF.LimitObject("holograms", "holograms", 200, "The number of holograms allowed to spawn via Starfall scripts for a single player")

SF.AddHook("initialize", function(inst)
	inst.data.holograms = {holos = {}}
end)

local function hologramOnDestroy(holo, holodata, ply)
	holodata[holo] = nil
	plyCount:free(ply, 1)
end

SF.AddHook("deinitialize", function(inst)
	local holos = inst.data.holograms.holos
	local holo = next(holos)
	while holo do
		if (holo and holo:IsValid()) then
			holo:RemoveCallOnRemove("starfall_hologram_delete")
			hologramOnDestroy(holo, holos, inst.player)
			holo:Remove()
		end
		holo = next(holos, holo)
	end
end)

--- Creates a hologram.
-- @return The hologram object
function holograms_library.create(pos, ang, model, scale)
	local instance = SF.instance
	checkpermission(instance,  nil, "hologram.create")
	checktype(pos, vec_meta)
	checktype(ang, ang_meta)
	checkluatype(model, TYPE_STRING)

	local pos = vunwrap(pos)
	local ang = aunwrap(ang)

	local ply = instance.player
	local holodata = instance.data.holograms.holos

	plyCount:checkuse(ply, 1)

	local holoent
	if SERVER then
		holoent = ents.Create("starfall_hologram")
		if holoent and holoent:IsValid() then
			holoent:SetPos(SF.clampPos(pos))
			holoent:SetAngles(ang)
			holoent:SetModel(model)
			holoent:CallOnRemove("starfall_hologram_delete", hologramOnDestroy, holodata, ply)
			holoent:Spawn()

			hook.Run("PlayerSpawnedSENT", ply, holoent)

			holodata[holoent] = true

			if scale~=nil then
				checktype(scale, vec_meta)
				holoent:SetScale(vunwrap(scale))
			end
			plyCount:free(ply, -1)
			return wrap(holoent)
		end
	else
		holoent = ClientsideModel(model, RENDERGROUP_TRANSLUCENT)
		if holoent and holoent:IsValid() then
			function holoent:CPPIGetOwner() return ply end
			holoent.IsSFHologram = true
			holoent.SFHoloOwner = ply
			holoent:SetPos(SF.clampPos(pos))

			-- Due to garrysmod bug, null angle on initialization leads to invalid matrix
			holoent:SetAngles(Angle(1,0,0))

			holoent:SetAngles(ang)
			holoent:CallOnRemove("starfall_hologram_delete", hologramOnDestroy, holodata, ply)
			table.Inherit(holoent:GetTable(), hologramSENT.t)
			holoent:Initialize()
			holoent.RenderOverride = holoent.Draw

			holodata[holoent] = true

			if scale~=nil then
				checktype(scale, vec_meta)
				SF.Holograms.SetScale(holoent, vunwrap(scale))
			end

			plyCount:free(ply, -1)
			return wrap(holoent)
		end
	end
end

--- Checks if a user can spawn anymore holograms.
-- @return True if user can spawn holograms, False if not.
function holograms_library.canSpawn()
	if not SF.Permissions.hasAccess(SF.instance,  nil, "hologram.create") then return false end
	return plyCount:check(SF.instance.player) > 0
end

--- Checks how many holograms can be spawned
-- @return number of holograms able to be spawned
function holograms_library.hologramsLeft ()
	if not SF.Permissions.hasAccess(SF.instance,  nil, "hologram.create") then return 0 end
	return plyCount:check(SF.instance.player)
end

if SERVER then
	--- Sets the hologram scale. Basically the same as setRenderMatrix() with a scaled matrix
	-- @shared
	-- @param scale Vector new scale
	function hologram_methods:setScale(scale)
		checktype(self, hologram_metamethods)
		local holo = unwrap(self)
		if not (holo and holo:IsValid()) then SF.Throw("The entity is invalid", 2) end

		checktype(scale, vec_meta)
		local scale = vunwrap(scale)

		checkpermission(SF.instance, holo, "hologram.setRenderProperty")

		holo:SetScale(scale)
	end

	--- Suppress Engine Lighting of a hologram. Disabled by default.
	-- @shared
	-- @param suppress Boolean to represent if shading should be set or not.
	function hologram_methods:suppressEngineLighting (suppress)
		checktype(self, hologram_metamethods)
		local holo = unwrap(self)
		if not (holo and holo:IsValid()) then SF.Throw("The entity is invalid", 2) end

		checkluatype(suppress, TYPE_BOOL)

		checkpermission(SF.instance, holo, "hologram.setRenderProperty")

		holo:SetSuppressEngineLighting(suppress)
	end

	--- Sets the hologram linear velocity
	-- @server
	-- @param vel New velocity
	function hologram_methods:setVel (vel)
		checktype(self, hologram_metamethods)
		checktype(vel, vec_meta)
		local vel = vunwrap(vel)

		local holo = unwrap(self)
		if not (holo and holo:IsValid()) then SF.Throw("The entity is invalid", 2) end
		checkpermission(SF.instance, holo, "hologram.setRenderProperty")

		holo:SetLocalVelocity(vel)
	end

	--- Sets the hologram's angular velocity.
	-- @server
	-- @param angvel *Vector* angular velocity.
	function hologram_methods:setAngVel (angvel)
		checktype(self, hologram_metamethods)
		checktype(angvel, ang_meta)

		local holo = unwrap(self)
		if not (holo and holo:IsValid()) then SF.Throw("The entity is invalid", 2) end
		checkpermission(SF.instance, holo, "hologram.setRenderProperty")

		holo:SetLocalAngularVelocity(aunwrap(angvel))
	end

	--- Animates a hologram
	-- @server
	-- @param animation number or string name
	-- @param frame The starting frame number
	-- @param rate Frame speed. (1 is normal)
	function hologram_methods:setAnimation(animation, frame, rate)
		local holo = unwrap(self)
		if not (holo and holo:IsValid()) then SF.Throw("The entity is invalid", 2) end
		checkpermission(SF.instance, holo, "hologram.setRenderProperty")

		if isstring(animation) then
			animation = holo:LookupSequence(animation)
		end

		frame = frame or 0
		rate = rate or 1

		holo.AutomaticFrameAdvance = animation~=-1

		holo:ResetSequence(animation)
		holo:SetCycle(frame)
		holo:SetPlaybackRate(rate)
	end

else
	SF.Holograms.maxclips = CreateClientConVar("sf_holograms_maxclips_cl", "8", true, false,
		"The max number of clips per hologram entity")


	function SF.Holograms.SetScale(holo, scale)
		holo.scale = scale
		if scale == Vector(1, 1, 1) then
			holo.HoloMatrix = nil
			holo:DisableMatrix("RenderMultiply")
		else
			local scalematrix = Matrix()
			scalematrix:Scale(scale)
			holo.HoloMatrix = scalematrix
			holo:EnableMatrix("RenderMultiply", scalematrix)
		end
	end

	--- Sets the hologram's position.
	-- @shared
	-- @param vec New position
	function hologram_methods:setPos(vec)
		checktype(self, hologram_metamethods)
		local holo = unwrap(self)
		if not (holo and holo:IsValid()) then SF.Throw("The entity is invalid", 2) end

		checktype(vec, vec_meta)
		local vec = vunwrap(vec)

		checkpermission(SF.instance, holo, "hologram.setRenderProperty")

		holo:SetPos(SF.clampPos(vec))
	end

	--- Sets the hologram's angles.
	-- @shared
	-- @param ang New angles
	function hologram_methods:setAngles(ang)
		checktype(self, hologram_metamethods)
		local holo = unwrap(self)
		if not (holo and holo:IsValid()) then SF.Throw("The entity is invalid", 2) end

		checktype(ang, ang_meta)
		local ang = aunwrap(ang)

		checkpermission(SF.instance, holo, "hologram.setRenderProperty")

		holo:SetAngles(ang)
	end
	
	--- Sets the texture filtering function when viewing a close texture
	-- @client
	-- @param val The filter function to use http://wiki.garrysmod.com/page/Enums/TEXFILTER
	function hologram_methods:setFilterMag(val)
		checktype(self, hologram_metamethods)
		local holo = unwrap(self)
		if not (holo and holo:IsValid()) then SF.Throw("The entity is invalid", 2) end

		checkpermission(SF.instance, holo, "hologram.setRenderProperty")

		if val then
			checkluatype(val, TYPE_NUMBER)
			holo.filter_mag = val
		else
			holo.filter_mag = nil
		end
	end

	--- Sets the texture filtering function when viewing a far texture
	-- @client
	-- @param val The filter function to use http://wiki.garrysmod.com/page/Enums/TEXFILTER
	function hologram_methods:setFilterMin(val)
		checktype(self, hologram_metamethods)
		local holo = unwrap(self)
		if not (holo and holo:IsValid()) then SF.Throw("The entity is invalid", 2) end

		checkpermission(SF.instance, holo, "hologram.setRenderProperty")

		if val then
			checkluatype(val, TYPE_NUMBER)
			holo.filter_min = val
		else
			holo.filter_min = nil
		end
	end

	--- Sets a hologram entity's rendermatrix
	-- @client
	-- @param mat Starfall matrix to use
	function hologram_methods:setRenderMatrix(mat)
		checktype(self, hologram_metamethods)
		local holo = unwrap(self)
		if not (holo and holo:IsValid()) then SF.Throw("The entity is invalid", 2) end

		checkpermission(SF.instance, holo, "hologram.setRenderProperty")

		if mat ~= nil then
			checktype(mat, SF.VMatrix.Metatable)
			local matrix = SF.VMatrix.Unwrap(mat)
			if matrix:IsIdentity() then
				holo.HoloMatrix = nil
				holo:DisableMatrix("RenderMultiply")
			else
				holo.HoloMatrix = matrix
				holo:EnableMatrix("RenderMultiply", matrix)
			end
		else
			holo:DisableMatrix("RenderMultiply")
		end
	end

	function hologram_methods:setScale(scale)
		checktype(self, hologram_metamethods)
		local holo = unwrap(self)
		if not (holo and holo:IsValid()) then SF.Throw("The entity is invalid", 2) end

		checktype(scale, vec_meta)
		local scale = vunwrap(scale)

		checkpermission(SF.instance, holo, "hologram.setRenderProperty")

		SF.Holograms.SetScale(holo, scale)
	end

	--- Updates a clip plane
	-- @client
	-- @param index Whatever number you want the clip to be
	-- @param enabled Whether the clip is enabled
	-- @param origin The center of the clip plane in world coordinates, or local to entity if it is specified
	-- @param normal The the direction of the clip plane in world coordinates, or local to entity if it is specified
	-- @param entity (Optional) The entity to make coordinates local to, otherwise the world is used
	function hologram_methods:setClip(index, enabled, origin, normal, entity)
		checktype(self, hologram_metamethods)
		local holo = unwrap(self)
		if not (holo and holo:IsValid()) then SF.Throw("The entity is invalid", 2) end

		checkluatype(index, TYPE_NUMBER)
		checkluatype(enabled, TYPE_BOOL)
		checktype(origin, vec_meta)
		checktype(normal, vec_meta)

		if entity ~= nil then
			checktype(entity, ent_meta)
			entity = eunwrap(entity)
		end

		local origin, normal = vunwrap(origin), vunwrap(normal)

		checkpermission(SF.instance, holo, "hologram.setRenderProperty")

		local clips = holo.clips
		if enabled then
			local clip = clips[index]
			if not clip then
				local max = SF.Holograms.maxclips:GetInt()
				if table.Count(holo.clips)==max then
					SF.Throw("The maximum hologram clips is " .. max, 2)
				end
				clip = {}
				clips[index] = clip
			end

			clip.normal = normal
			clip.origin = origin
			clip.entity = entity
		else
			clips[index] = nil
		end
	end

	function hologram_methods:suppressEngineLighting (suppress)
		checktype(self, hologram_metamethods)
		local holo = unwrap(self)
		if not (holo and holo:IsValid()) then SF.Throw("The entity is invalid", 2) end

		checkluatype(suppress, TYPE_BOOL)

		checkpermission(SF.instance, holo, "hologram.setRenderProperty")

		holo.suppressEngineLighting = suppress
	end
end

--- Gets the hologram scale.
-- @shared
-- @return Vector scale
function hologram_methods:getScale()
	checktype(self, hologram_metamethods)
	local holo = unwrap(self)
	if not (holo and holo:IsValid()) then SF.Throw("The entity is invalid", 2) end

	checkpermission(SF.instance, holo, "hologram.setRenderProperty")

	return vwrap(holo.scale)
end

--- Sets the model of a hologram
-- @param model string model path
function hologram_methods:setModel(model)
	checktype(self, hologram_metamethods)
	local holo = unwrap(self)
	if not (holo and holo:IsValid()) then SF.Throw("The entity is invalid", 2) end

	checkluatype(model, TYPE_STRING)
	if not util.IsValidModel(model) then SF.Throw("Model is invalid", 2) end

	checkpermission(SF.instance, holo, "hologram.setRenderProperty")

	holo:SetModel(model)
end

