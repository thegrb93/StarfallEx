
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
local wrap, unwrap, vunwrap, aunwrap, ewrap, eunwrap
local hologramSENT
SF.AddHook("postload", function()
	ang_meta = SF.Angles.Metatable
	vec_meta = SF.Vectors.Metatable
	ent_meta = SF.Entities.Metatable

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

	--- Casts a hologram entity into the hologram type
	-- @name Entity.toHologram
	-- @class function
	-- @return Hologram type
	function SF.Entities.Methods:toHologram()
		checktype(self, ent_meta)
		if eunwrap(self):GetClass() ~= "starfall_hologram" then SF.Throw("The entity isn't a hologram", 2) end
		return setmetatable(self, hologram_metamethods)
	end
end)

SF.Permissions.registerPrivilege("hologram.create", "Create hologram", "Allows the user to create holograms")
SF.Permissions.registerPrivilege("hologram.setRenderProperty", "RenderProperty", "Allows the user to change the rendering of an entity", { entities = {} })

if SERVER then

	SF.Holograms.personalquota = CreateConVar("sf_holograms_personalquota", "100", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
		"The number of holograms allowed to spawn via Starfall scripts for a single player")

else
	SF.Holograms.personalquota = CreateClientConVar("sf_holograms_personalquota_cl", "200", true, false,
		"The number of holograms allowed to spawn via Starfall scripts for a single player")

	--- Sets a hologram entity's model to a custom Mesh
	-- @client
	-- @param mesh The mesh to set it to or nil to set back to normal
	function hologram_methods:setMesh(mesh)
		checktype(self, hologram_metamethods)
		local holo = unwrap(self)
		if not IsValid(holo) then SF.Throw("The entity is invalid", 2) end

		local instance = SF.instance
		checkpermission(instance, nil, "mesh")
		checkpermission(instance, holo, "hologram.setRenderProperty")
		if mesh then
			checktype(mesh, SF.Mesh.Metatable)
			holo.custom_mesh = SF.Mesh.Unwrap(mesh)
			holo.custom_mesh_data = instance.data.meshes
		else
			holo.custom_mesh = nil
		end
	end
	
	--- Sets the texture filtering function when viewing a close texture
	-- @client
	-- @param val The filter function to use http://wiki.garrysmod.com/page/Enums/TEXFILTER
	function hologram_methods:setFilterMag(val)
		checktype(self, hologram_metamethods)
		local holo = unwrap(self)
		if not IsValid(holo) then SF.Throw("The entity is invalid", 2) end

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
		if not IsValid(holo) then SF.Throw("The entity is invalid", 2) end

		checkpermission(SF.instance, holo, "hologram.setRenderProperty")

		if val then
			checkluatype(val, TYPE_NUMBER)
			holo.filter_min = val
		else
			holo.filter_min = nil
		end
	end

	--- Sets a hologram entity's material to a custom starfall material
	-- @client
	-- @param material The material to set it to or nil to set back to default
	function hologram_methods:setMaterial(material)
		checktype(self, hologram_metamethods)
		local holo = unwrap(self)
		if not IsValid(holo) then SF.Throw("The entity is invalid", 2) end

		checkpermission(SF.instance, holo, "hologram.setRenderProperty")

		if material then
			checktype(material, SF.Materials.Metatable)
			holo.Material = SF.Materials.Unwrap(material)
		else
			holo.Material = holo.DefaultMaterial
		end
	end

	--- Sets a hologram entity's renderbounds
	-- @client
	-- @param mins The lower bounding corner coordinate local to the hologram
	-- @param maxs The upper bounding corner coordinate local to the hologram
	function hologram_methods:setRenderBounds(mins, maxs)
		checktype(self, hologram_metamethods)
		local holo = unwrap(self)
		if not IsValid(holo) then SF.Throw("The entity is invalid", 2) end

		checktype(mins, vec_meta)
		checktype(maxs, vec_meta)

		checkpermission(SF.instance, holo, "hologram.setRenderProperty")

		holo:SetRenderBounds(vunwrap(mins), vunwrap(maxs))
	end

	--- Sets a hologram entity's rendermatrix
	-- @client
	-- @param mat Starfall matrix to use
	function hologram_methods:setRenderMatrix(mat)
		checktype(self, hologram_metamethods)
		local holo = unwrap(self)
		if not IsValid(holo) then SF.Throw("The entity is invalid", 2) end

		checkpermission(SF.instance, holo, "hologram.setRenderProperty")

		if mat ~= nil then
			checktype(mat, SF.VMatrix.Metatable)
			local matrix = SF.VMatrix.Unwrap(mat)
			if matrix:IsIdentity() then
				holo:DisableMatrix("RenderMultiply")
			else
				holo:EnableMatrix("RenderMultiply", matrix)
			end
		else
			holo:DisableMatrix("RenderMultiply")
		end
	end
end

-- Table with player keys that automatically cleans when player leaves.
local plyCount = SF.EntityTable("playerHolos")

SF.AddHook("initialize", function(inst)
	inst.data.holograms = {
		holos = {},
		count = 0
	}
	plyCount[inst.player] = plyCount[inst.player] or 0
end)

local function hologramOnDestroy(holo, holodata, ply)
	holodata[holo] = nil
	if plyCount[ply] then
		plyCount[ply] = plyCount[ply] - 1
	end
end

SF.AddHook("deinitialize", function(inst)
	local holos = inst.data.holograms.holos
	local holo = next(holos)
	while holo do
		if IsValid(holo) then
			holo:RemoveCallOnRemove("starfall_hologram_delete")
			hologramOnDestroy(holo, holos, inst.player)
			holo:Remove()
		end
		holo = next(holos, holo)
	end
end)

--- Creates a hologram.
-- @return The hologram object
function holograms_library.create (pos, ang, model, scale)
	local instance = SF.instance
	checkpermission(instance,  nil, "hologram.create")
	checktype(pos, vec_meta)
	checktype(ang, ang_meta)
	checkluatype(model, TYPE_STRING)
	if scale ~= nil then
		checktype(scale, vec_meta)
		scale = vunwrap(scale)
	end

	local pos = vunwrap(pos)
	local ang = aunwrap(ang)

	local holodata = instance.data.holograms.holos

	if plyCount[instance.player] >= SF.Holograms.personalquota:GetInt() then
		SF.Throw("Can't spawn holograms, maximum personal limit of " .. SF.Holograms.personalquota:GetInt() .. " has been reached", 2)
	end

	local holoent
	if SERVER then
		holoent = ents.Create("starfall_hologram")
		if holoent and holoent:IsValid() then
			holoent:SetPos(SF.clampPos(pos))
			holoent:SetAngles(ang)
			holoent:SetModel(model)
			holoent:CallOnRemove("starfall_hologram_delete", hologramOnDestroy, holodata, instance.player)
			holoent:Spawn()

			hook.Run("PlayerSpawnedSENT", instance.player, holoent)

			if scale then
				holoent:SetScale(scale)
			end

			holodata[holoent] = true
			plyCount[instance.player] = plyCount[instance.player] + 1

			return wrap(holoent)
		end
	else
		holoent = ClientsideModel(model, RENDERGROUP_TRANSLUCENT)
		if holoent and holoent:IsValid() then
			holoent:SetPos(SF.clampPos(pos))
			holoent:SetAngles(ang)
			holoent:CallOnRemove("starfall_hologram_delete", hologramOnDestroy, holodata, instance.player)
			table.Inherit(holoent:GetTable(), hologramSENT.t)
			holoent:Initialize()
			function holoent:GetScale() return self.scale end
			function holoent:GetSuppressEngineLighting() return false end
			holoent.RenderOverride = holoent.Draw
			holoent.SFHoloOwner = instance.player

			if scale then
				holoent:SetScale(scale)
			end

			holodata[holoent] = true
			plyCount[instance.player] = plyCount[instance.player] + 1

			return wrap(holoent)
		end
	end
end

--- Checks if a user can spawn anymore holograms.
-- @return True if user can spawn holograms, False if not.
function holograms_library.canSpawn()
	if not SF.Permissions.hasAccess(SF.instance,  nil, "hologram.create") then return false end
	return plyCount[SF.instance.player] < SF.Holograms.personalquota:GetInt()
end

--- Checks how many holograms can be spawned
-- @return number of holograms able to be spawned
function holograms_library.hologramsLeft ()
	if not SF.Permissions.hasAccess(SF.instance,  nil, "hologram.create") then return 0 end
	return SF.Holograms.personalquota:GetInt() - plyCount[SF.instance.player]
end

--- Sets the hologram's position.
-- @param vec New position
function hologram_methods:setPos(vec)
	checktype(self, hologram_metamethods)
	local holo = unwrap(self)
	if not IsValid(holo) then SF.Throw("The entity is invalid", 2) end

	checktype(vec, vec_meta)
	local vec = vunwrap(vec)

	checkpermission(SF.instance, holo, "hologram.setRenderProperty")

	holo:SetPos(SF.clampPos(vec))
end

--- Sets the hologram linear velocity
-- @param vel New velocity
function hologram_methods:setVel (vel)
	checktype(self, hologram_metamethods)
	checktype(vel, vec_meta)
	local vel = vunwrap(vel)

	local holo = unwrap(self)
	if not IsValid(holo) then SF.Throw("The entity is invalid", 2) end
	checkpermission(SF.instance, holo, "hologram.setRenderProperty")

	holo:SetLocalVelocity(vel)
end

--- Sets the hologram's angular velocity.
-- @param angvel *Vector* angular velocity.
function hologram_methods:setAngVel (angvel)
	checktype(self, hologram_metamethods)
	checktype(angvel, ang_meta)

	local holo = unwrap(self)
	if not IsValid(holo) then SF.Throw("The entity is invalid", 2) end
	checkpermission(SF.instance, holo, "hologram.setRenderProperty")

	holo:SetLocalAngularVelocity(aunwrap(angvel))
end

--- Sets the hologram scale
-- @param scale Vector new scale
function hologram_methods:setScale (scale)
	checktype(self, hologram_metamethods)
	checktype(scale, vec_meta)
	local scale = vunwrap(scale)

	local holo = unwrap(self)
	if not IsValid(holo) then SF.Throw("The entity is invalid", 2) end
	checkpermission(SF.instance, holo, "hologram.setRenderProperty")

	holo:SetScale(scale)
end

--- Updates a clip plane
function hologram_methods:setClip (index, enabled, origin, normal, islocal)
	checktype(self, hologram_metamethods)
	checkluatype(index, TYPE_NUMBER)
	checkluatype(enabled, TYPE_BOOL)
	checktype(origin, vec_meta)
	checktype(normal, vec_meta)
	checkluatype(islocal, TYPE_BOOL)

	local origin, normal = vunwrap(origin), vunwrap(normal)

	local holo = unwrap(self)
	if not IsValid(holo) then SF.Throw("The entity is invalid", 2) end
	checkpermission(SF.instance, holo, "hologram.setRenderProperty")

	if enabled and not holo.clips[index] and table.Count(holo.clips)==8 then
		SF.Throw("The maximum hologram clips is 8", 2)
	end
	holo:UpdateClip(index, enabled, origin, normal, islocal)
end

--- Sets the model of a hologram
-- @param model string model path
function hologram_methods:setModel (model)
	checktype(self, hologram_metamethods)
	local holo = unwrap(self)
	if not IsValid(holo) then SF.Throw("The entity is invalid", 2) end

	checkluatype(model, TYPE_STRING)
	if not util.IsValidModel(model) then SF.Throw("Model is invalid", 2) end

	checkpermission(SF.instance, holo, "hologram.setRenderProperty")

	holo:SetModel(model)
end

--- Suppress Engine Lighting of a hologram. Disabled by default.
-- @param suppress Boolean to represent if shading should be set or not.
function hologram_methods:suppressEngineLighting (suppress)
	checktype(self, hologram_metamethods)
	local holo = unwrap(self)
	if not IsValid(holo) then SF.Throw("The entity is invalid", 2) end

	checkluatype(suppress, TYPE_BOOL)

	checkpermission(SF.instance, holo, "hologram.setRenderProperty")

	holo:SetSuppressEngineLighting(suppress)
end

--- Animates a hologram
-- @param animation number or string name
-- @param frame The starting frame number
-- @param rate Frame speed. (1 is normal)
function hologram_methods:setAnimation(animation, frame, rate)
	local holo = unwrap(self)
	if not IsValid(holo) then SF.Throw("The entity is invalid", 2) end
	checkpermission(SF.instance, holo, "hologram.setRenderProperty")

	if isstring(animation) then
		animation = holo:LookupSequence(animation)
	end

	frame = frame or 0
	rate = rate or 1

	if not holo.Animated then
		-- This must be run once on entities that will be animated
		holo.Animated = true
		holo.AutomaticFrameAdvance = true

		local OldThink = holo.Think
		function holo:Think()
			OldThink(self)
			self:NextThink(CurTime())
			return true
		end
	end
	holo:ResetSequence(animation)
	holo:SetCycle(frame)
	holo:SetPlaybackRate(rate)
end
