-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check
local registerprivilege = SF.Permissions.registerPrivilege

registerprivilege("hologram.modify", "Modify holograms", "Allows the user to modify holograms", { entities = {} })
registerprivilege("hologram.create", "Create hologram", "Allows the user to create holograms", CLIENT and { client = {} } or nil)
registerprivilege("hologram.setRenderProperty", "RenderProperty", "Allows the user to change the rendering of an entity", { entities = {} })

local plyCount = SF.LimitObject("holograms", "holograms", 200, "The number of holograms allowed to spawn via Starfall scripts for a single player")

local maxclips = CreateConVar("sf_holograms_maxclips", "8", { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "The max number of clips per hologram entity")

local hologramSENT
if CLIENT then
	hologramSENT = scripted_ents.GetStored( "starfall_hologram" )
	if not hologramSENT then
		hook.Add("Initialize","SF_GetHologramRenderFunc",function()
			hologramSENT = scripted_ents.GetStored( "starfall_hologram" )
		end)
	end
end

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

if CLIENT then
	registerprivilege("hologram.setParent", "Set Parent", "Allows the user to parent a hologram", { entities = {} })

	local function parentChildren(ent)
		for child, attachment in pairs(ent.sf_children) do
			if child and child:IsValid() then
				child:SetParent(ent, attachment)
				
				if child.sf_children then
					return parentChildren(child)
				end
			end
		end
	end

	hook.Add("NotifyShouldTransmit", "starfall_hologram_parents", function(ent, transmit)
		if ent and ent:IsValid() and ent.sf_children then
			parentChildren(ent)
		end
	end)
end

local function hologramOnDestroy(holo, holodata, ply)
	holodata[holo] = nil
	plyCount:free(ply, 1)
end


--- Library for creating and manipulating physics-less models AKA "Holograms".
-- @shared
SF.RegisterLibrary("holograms")

--- Hologram type
SF.RegisterType("Hologram", true, false, nil, "Entity")



return function(instance)

local getent
instance:AddHook("initialize", function()
	instance.data.holograms = {holos = {}}
	getent = instance.Types.Entity.GetEntity
end)

instance:AddHook("deinitialize", function()
	local holos = instance.data.holograms.holos
	for holo, _ in pairs(holos) do
		if holo:IsValid() then
			holo:RemoveCallOnRemove("starfall_hologram_delete")
			hologramOnDestroy(holo, holos, instance.player)
			if CLIENT then
				timer.Simple(0,function() holo:Remove() end)
			else
				holo:Remove()
			end
		end
	end
end)


local checktype = instance.CheckType
local holograms_library = instance.Libraries.holograms
local hologram_methods, hologram_meta, wrap, unwrap = instance.Types.Hologram.Methods, instance.Types.Hologram, instance.Types.Hologram.Wrap, instance.Types.Hologram.Unwrap
local ents_methods, ent_meta, ewrap, eunwrap = instance.Types.Entity.Methods, instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap
local ang_meta, awrap, aunwrap = instance.Types.Angle, instance.Types.Angle.Wrap, instance.Types.Angle.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap
local mtx_meta, mwrap, munwrap = instance.Types.VMatrix, instance.Types.VMatrix.Wrap, instance.Types.VMatrix.Unwrap


--- Casts a hologram entity into the hologram type
-- @shared
-- @return Hologram type
function ents_methods:toHologram()
	local ent = getent(self)
	if not ent.IsSFHologram then SF.Throw("The entity isn't a hologram", 2) end
	debug.setmetatable(self, hologram_meta)
	return self
end


--- Creates a hologram.
-- @return The hologram object
function holograms_library.create(pos, ang, model, scale)
	checkpermission(instance, nil, "hologram.create")
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
			holoent.IsSFHologram = true
			holoent.SFHoloOwner = ply
			holoent:SetPos(SF.clampPos(pos))
			holoent:SetAngles(ang)
			holoent:CallOnRemove("starfall_hologram_delete", hologramOnDestroy, holodata, ply)
			table.Inherit(holoent:GetTable(), hologramSENT.t)
			holoent:Initialize()
			holoent.RenderOverride = holoent.Draw
			holoent.DrawHologram = holoent.DrawCLHologram
			debug.setmetatable(holoent, cl_hologram_meta)

			holodata[holoent] = true

			if scale~=nil then
				checktype(scale, vec_meta)
				SF.SetHologramScale(holoent, vunwrap(scale))
			end

			plyCount:free(ply, -1)
			return wrap(holoent)
		end
	end
end

--- Checks if a user can spawn anymore holograms.
-- @return True if user can spawn holograms, False if not.
function holograms_library.canSpawn()
	if not SF.Permissions.hasAccess(instance,  nil, "hologram.create") then return false end
	return plyCount:check(instance.player) > 0
end

--- Checks how many holograms can be spawned
-- @return number of holograms able to be spawned
function holograms_library.hologramsLeft ()
	if not SF.Permissions.hasAccess(instance,  nil, "hologram.create") then return 0 end
	return plyCount:check(instance.player)
end

if SERVER then
	--- Sets the hologram scale. Basically the same as setRenderMatrix() with a scaled matrix
	-- @shared
	-- @param scale Vector new scale
	function hologram_methods:setScale(scale)
		checktype(self, hologram_meta)
		local holo = unwrap(self)
		if not (holo and holo:IsValid()) then SF.Throw("The hologram is invalid", 2) end

		checktype(scale, vec_meta)
		local scale = vunwrap(scale)

		checkpermission(instance, holo, "hologram.setRenderProperty")

		holo:SetScale(scale)
	end

	--- Suppress Engine Lighting of a hologram. Disabled by default.
	-- @shared
	-- @param suppress Boolean to represent if shading should be set or not.
	function hologram_methods:suppressEngineLighting (suppress)
		checktype(self, hologram_meta)
		local holo = unwrap(self)
		if not (holo and holo:IsValid()) then SF.Throw("The hologram is invalid", 2) end

		checkluatype(suppress, TYPE_BOOL)

		checkpermission(instance, holo, "hologram.setRenderProperty")

		holo:SetSuppressEngineLighting(suppress)
	end

	--- Sets the hologram linear velocity
	-- @server
	-- @param vel New velocity
	function hologram_methods:setVel (vel)
		checktype(self, hologram_meta)
		checktype(vel, vec_meta)
		local vel = vunwrap(vel)

		local holo = unwrap(self)
		if not (holo and holo:IsValid()) then SF.Throw("The hologram is invalid", 2) end
		checkpermission(instance, holo, "hologram.setRenderProperty")

		holo:SetLocalVelocity(vel)
	end

	--- Sets the hologram's angular velocity.
	-- @server
	-- @param angvel *Vector* angular velocity.
	function hologram_methods:setAngVel (angvel)
		checktype(self, hologram_meta)
		checktype(angvel, ang_meta)

		local holo = unwrap(self)
		if not (holo and holo:IsValid()) then SF.Throw("The hologram is invalid", 2) end
		checkpermission(instance, holo, "hologram.setRenderProperty")

		holo:SetLocalAngularVelocity(aunwrap(angvel))
	end

	--- Animates a hologram
	-- @server
	-- @param animation number or string name
	-- @param frame The starting frame number
	-- @param rate Frame speed. (1 is normal)
	function hologram_methods:setAnimation(animation, frame, rate)
		local holo = unwrap(self)
		if not (holo and holo:IsValid()) then SF.Throw("The hologram is invalid", 2) end
		checkpermission(instance, holo, "hologram.setRenderProperty")

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
	function SF.SetHologramScale(holo, scale)
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
		checktype(self, hologram_meta)
		local holo = unwrap(self)
		if not (holo and holo:IsValid()) then SF.Throw("The hologram is invalid", 2) end

		checktype(vec, vec_meta)
		local vec = vunwrap(vec)

		checkpermission(instance, holo, "hologram.setRenderProperty")

		holo:SetPos(SF.clampPos(vec))
	end

	--- Sets the hologram's angles.
	-- @shared
	-- @param ang New angles
	function hologram_methods:setAngles(ang)
		checktype(self, hologram_meta)
		local holo = unwrap(self)
		if not (holo and holo:IsValid()) then SF.Throw("The hologram is invalid", 2) end

		checktype(ang, ang_meta)
		local ang = aunwrap(ang)

		checkpermission(instance, holo, "hologram.setRenderProperty")

		holo:SetAngles(ang)
	end

	--- Removes a hologram
	function hologram_methods:remove()
		checktype(self, hologram_meta)
		local holo = unwrap(self)
		if not (holo and holo:IsValid()) then SF.Throw("The hologram is invalid", 2) end
		if instance.data.render.isRendering then SF.Throw("Cannot remove while in rendering hook!", 2) end

		checkpermission(instance, holo, "hologram.create")

		holo:Remove()
	end

	--- Sets the texture filtering function when viewing a close texture
	-- @client
	-- @param val The filter function to use http://wiki.garrysmod.com/page/Enums/TEXFILTER
	function hologram_methods:setFilterMag(val)
		checktype(self, hologram_meta)
		local holo = unwrap(self)
		if not (holo and holo:IsValid()) then SF.Throw("The hologram is invalid", 2) end

		checkpermission(instance, holo, "hologram.setRenderProperty")

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
		checktype(self, hologram_meta)
		local holo = unwrap(self)
		if not (holo and holo:IsValid()) then SF.Throw("The hologram is invalid", 2) end

		checkpermission(instance, holo, "hologram.setRenderProperty")

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
		checktype(self, hologram_meta)
		local holo = unwrap(self)
		if not (holo and holo:IsValid()) then SF.Throw("The hologram is invalid", 2) end

		checkpermission(instance, holo, "hologram.setRenderProperty")

		if mat ~= nil then
			checktype(mat, mtx_meta)
			local matrix = munwrap(mat)
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
		checktype(self, hologram_meta)
		local holo = unwrap(self)
		if not (holo and holo:IsValid()) then SF.Throw("The hologram is invalid", 2) end

		checktype(scale, vec_meta)
		local scale = vunwrap(scale)

		checkpermission(instance, holo, "hologram.setRenderProperty")

		SF.SetHologramScale(holo, scale)
	end

	function hologram_methods:suppressEngineLighting (suppress)
		checktype(self, hologram_meta)
		local holo = unwrap(self)
		if not (holo and holo:IsValid()) then SF.Throw("The hologram is invalid", 2) end

		checkluatype(suppress, TYPE_BOOL)

		checkpermission(instance, holo, "hologram.setRenderProperty")

		holo.suppressEngineLighting = suppress
	end
	
	local holoChildrenMeta = { __mode = "k" }
	
	--- Parents a hologram
	-- @param ent Entity parent (nil to unparent)
	-- @param attachment Optional attachment ID
	function hologram_methods:setParent (ent, attachment)
		
		checktype(self, hologram_meta)
		local holo = unwrap(self)
		if not (holo and holo:IsValid()) then SF.Throw("The hologram is invalid", 2) end
		
		checkpermission(instance, holo, "hologram.setParent")
		
		if ent ~= nil then
			local parent = getent(ent)
			
			if attachment == nil then attachment = -1 end
			checkluatype(attachment, TYPE_NUMBER)
			
			if not parent.sf_children then
				parent.sf_children = setmetatable({}, holoChildrenMeta)
			end
			
			if holo.sf_parent then
				holo.sf_parent.sf_children[holo] = nil
			end
			
			parent.sf_children[holo] = attachment
			holo.sf_parent = parent
			
			holo:SetParent(parent, attachment)
			
		else
			
			if holo.sf_parent then
				holo.sf_parent.sf_children[holo] = nil
			end
			
			holo.sf_parent = nil
			holo:SetParent()
			
		end
		
	end
	
end

--- Updates a clip plane
-- @shared
-- @param index Whatever number you want the clip to be
-- @param enabled Whether the clip is enabled
-- @param origin The center of the clip plane in world coordinates, or local to entity if it is specified
-- @param normal The the direction of the clip plane in world coordinates, or local to entity if it is specified
-- @param entity (Optional) The entity to make coordinates local to, otherwise the world is used
function hologram_methods:setClip(index, enabled, origin, normal, entity)
	checktype(self, hologram_meta)
	local holo = unwrap(self)
	if not (holo and holo:IsValid()) then SF.Throw("The hologram is invalid", 2) end

	checkluatype(index, TYPE_NUMBER)
	checkluatype(enabled, TYPE_BOOL)
	checktype(origin, vec_meta)
	checktype(normal, vec_meta)

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

--- Gets the hologram scale.
-- @shared
-- @return Vector scale
function hologram_methods:getScale()
	checktype(self, hologram_meta)
	local holo = unwrap(self)
	if not (holo and holo:IsValid()) then SF.Throw("The hologram is invalid", 2) end

	checkpermission(instance, holo, "hologram.setRenderProperty")

	return vwrap(holo.scale)
end

--- Sets the model of a hologram
-- @param model string model path
function hologram_methods:setModel(model)
	checktype(self, hologram_meta)
	local holo = unwrap(self)
	if not (holo and holo:IsValid()) then SF.Throw("The hologram is invalid", 2) end

	checkluatype(model, TYPE_STRING)
	if not util.IsValidModel(model) then SF.Throw("Model is invalid", 2) end

	checkpermission(instance, holo, "hologram.setRenderProperty")

	holo:SetModel(model)
end

end
