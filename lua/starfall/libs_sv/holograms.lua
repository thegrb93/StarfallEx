
--- Library for creating and manipulating physics-less models AKA "Holograms".
-- @server
local holograms_library = SF.Libraries.Register("holograms")

--- Hologram type
local hologram_methods, hologram_metamethods = SF.Typedef("Hologram", SF.Entities.Metatable)
local wrap, unwrap = SF.CreateWrapper(hologram_metamethods, true, false, nil, SF.Entities.Metatable)

local ang_meta, vec_meta, ent_meta
local vunwrap, aunwrap, ewrap, eunwrap

SF.Libraries.AddHook("postload", function()
	ang_meta = SF.Angles.Metatable
	vec_meta = SF.Vectors.Metatable
	ent_meta = SF.Entities.Metatable

	vunwrap = SF.Vectors.Unwrap
	aunwrap = SF.Angles.Unwrap
	ewrap = SF.Entities.Wrap
	eunwrap = SF.Entities.Unwrap
end)

SF.Holograms = {}

SF.Holograms.personalquota = CreateConVar("sf_holograms_personalquota", "100", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
	"The number of holograms allowed to spawn via Starfall scripts for a single instance")

SF.Permissions.registerPrivilege("hologram.create", "Create hologram", "Allows the user to create holograms")

SF.Holograms.Methods = hologram_methods
SF.Holograms.Metatable = hologram_metamethods
SF.Holograms.Wrap = wrap
SF.Holograms.Unwrap = unwrap

-- Table with player keys that automatically cleans when player leaves.
local plyCount = SF.EntityTable("playerHolos")

SF.Libraries.AddHook("initialize", function(inst)
	inst.data.holograms = {
		holos = {},
		count = 0
	}
	plyCount[inst.player] = plyCount[inst.player] or 0
end)

local function hologramOnDestroy(holoent, holodata, ply)
	holodata[holoent] = nil
	if plyCount[ply] then
		plyCount[ply] = plyCount[ply] - 1
	end
end

SF.Libraries.AddHook("deinitialize", function(inst)
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

--- Sets the hologram linear velocity
-- @param vel New velocity
function hologram_methods:setVel (vel)
	SF.CheckType(self, hologram_metamethods)
	SF.CheckType(vel, vec_meta)
	local vel = vunwrap(vel)
	local holo = unwrap(self)
	if holo then holo:SetLocalVelocity(vel) end
end

--- Sets the hologram's angular velocity.
-- @param angvel *Vector* angular velocity.
function hologram_methods:setAngVel (angvel)
	SF.CheckType(self, hologram_metamethods)
	SF.CheckType(angvel, ang_meta)
	local holo = unwrap(self)
	if holo then holo:SetLocalAngularVelocity(aunwrap(angvel)) end
end

--- Sets the hologram scale
-- @param scale Vector new scale
function hologram_methods:setScale (scale)
	SF.CheckType(self, hologram_metamethods)
	SF.CheckType(scale, vec_meta)
	local scale = vunwrap(scale)
	local holo = unwrap(self)
	if holo then
		holo:SetScale(scale)
	end
end

--- Updates a clip plane
function hologram_methods:setClip (index, enabled, origin, normal, islocal)
	SF.CheckType(self, hologram_metamethods)
	SF.CheckLuaType(index, TYPE_NUMBER)
	SF.CheckLuaType(enabled, TYPE_BOOL)
	SF.CheckType(origin, vec_meta)
	SF.CheckType(normal, vec_meta)
	SF.CheckLuaType(islocal, TYPE_BOOL)

	local origin, normal = vunwrap(origin), vunwrap(normal)

	local holo = unwrap(self)
	if holo then
		if enabled and not holo.clips[index] and table.Count(holo.clips)==8 then
			SF.Throw("The maximum hologram clips is 8", 2)
		end
		holo:UpdateClip(index, enabled, origin, normal, islocal)
	end
end

--- Returns a table of flexname -> flexid pairs for use in flex functions.
-- These IDs become invalid when the hologram's model changes.
function hologram_methods:getFlexes()
	SF.CheckType(self, hologram_metamethods)
	local holoent = unwrap(self)
	local flexes = {}
	for i = 0, holoent:GetFlexNum()-1 do
		flexes[holoent:GetFlexName(i)] = i
	end
	return flexes
end

--- Sets the weight (value) of a flex.
function hologram_methods:setFlexWeight(flexid, weight)
	SF.CheckType(self, hologram_metamethods)
	SF.CheckLuaType(flexid, TYPE_NUMBER)
	SF.CheckLuaType(weight, TYPE_NUMBER)
	flexid = math.floor(flexid)
	if flexid < 0 or flexid >= holoent:GetFlexNum() then
		SF.Throw("Invalid flex: "..flexid, 2)
	end
	local holoent = unwrap(self)
	if IsValid(holoent) then
		holoent:SetFlexWeight(self, weight)
	end
end

--- Sets the scale of all flexes of a hologram
function hologram_methods:setFlexScale(scale)
	SF.CheckType(self, hologram_metamethods)
	SF.CheckLuaType(scale, TYPE_NUMBER)
	local holoent = unwrap(self)
	if IsValid(holoent) then
		holoent:SetFlexScale(scale)
	end
end

--- Sets the model of a hologram
-- @server
-- @class function
-- @param model string model path
function hologram_methods:setModel (model)
	SF.CheckLuaType(model, TYPE_STRING)
	if not util.IsValidModel(model) then SF.Throw("Model is invalid", 2) end

	local this = unwrap(self)
	if IsValid(this) then
		this:SetModel(model)
	end
end

--- Suppress Engine Lighting of a hologram. Disabled by default.
-- @server
-- @class function
-- @param suppress Boolean to represent if shading should be set or not.
function hologram_methods:suppressEngineLighting (suppress)
	SF.CheckLuaType(suppress, TYPE_BOOL)

	local this = unwrap(self)
	if IsValid(this) then
		this:SetSuppressEngineLighting(suppress)
	end
end

--- Animates a hologram
-- @server
-- @class function
-- @param animation number or string name
-- @param frame The starting frame number
-- @param rate Frame speed. (1 is normal)
function hologram_methods:setAnimation(animation, frame, rate)
	local Holo = unwrap(self)
	if not IsValid(Holo) then return end

	if type(animation)=="string" then
		animation = Holo:LookupSequence(animation)
	end
	
	frame = frame or 0
	rate = rate or 1
	
	if not Holo.Animated then
		-- This must be run once on entities that will be animated
		Holo.Animated = true
		Holo.AutomaticFrameAdvance = true
		
		local OldThink = Holo.Think
		function Holo:Think()
			OldThink(self)
			self:NextThink(CurTime())
			return true
		end
	end
	Holo:ResetSequence(animation)
	Holo:SetCycle(frame)
	Holo:SetPlaybackRate(rate)
end

--- Get the length of the current animation
-- @server
-- @class function
-- @return Length of current animation in seconds
function hologram_methods:getAnimationLength()
	local Holo = unwrap(self)
	if not IsValid(Holo) then return -1 end
	
	return Holo:SequenceDuration()
end

--- Convert animation name into animation number
-- @server
-- @param animation Name of the animation
-- @return Animation index
function hologram_methods:getAnimationNumber(animation)
	local Holo = unwrap(self)
	if not IsValid(Holo) then return 0 end
	
	return Holo:LookupSequence(animation) or 0
end

--- Set the pose value of an animation. Turret/Head angles for example.
-- @server
-- @class function
-- @param pose Name of the pose parameter
-- @param value Value to set it to.
function hologram_methods:setPose(pose, value)
	local Holo = unwrap(self)
	if not IsValid(Holo) then return end
	
	Holo:SetPoseParameter(pose, value)
end

--- Get the pose value of an animation
-- @server
-- @class function
-- @param pose Pose parameter name
-- @return Value of the pose parameter
function hologram_methods:getPose(pose)
	local Holo = unwrap(self)
	if not IsValid(Holo) then return end
	
	return Holo:GetPoseParameter(pose)
end

--- Creates a hologram.
-- @server
-- @return The hologram object
function holograms_library.create (pos, ang, model, scale)
	local instance = SF.instance
	SF.Permissions.check(instance.player,  nil, "hologram.create")
	SF.CheckType(pos, vec_meta)
	SF.CheckType(ang, ang_meta)
	SF.CheckLuaType(model, TYPE_STRING)
	if not util.IsValidModel(model) then SF.Throw("Model is invalid", 2) end
	if scale then
		SF.CheckType(scale, vec_meta)
		scale = vunwrap(scale)
	end

	local pos = vunwrap(pos)
	local ang = aunwrap(ang)

	local holodata = instance.data.holograms.holos
	
	if plyCount[instance.player] >= SF.Holograms.personalquota:GetInt() then 
		SF.Throw("Can't spawn holograms, maximum personal limit of " .. SF.Holograms.personalquota:GetInt() .. " has been reached", 2) 
	end

	local holoent = ents.Create("starfall_hologram")
	if holoent and holoent:IsValid() then
		SF.setPos(holoent, pos)
		SF.setAng(holoent, ang)
		holoent:SetModel(model)
		holoent:CallOnRemove("starfall_hologram_delete", hologramOnDestroy, holodata, instance.player)
		holoent:Spawn()

		if CPPI then
			holoent:CPPISetOwner(instance.player)
			holoent:SetHoloOwner(instance.player)
		end
		
		if scale then
			holoent:SetScale(scale)
		end

		holodata[holoent] = true
		plyCount[instance.player] = plyCount[instance.player] + 1
		
		return wrap(holoent)
	end
end

--- Checks if a user can spawn anymore holograms.
-- @server
-- @return True if user can spawn holograms, False if not.
function holograms_library.canSpawn()
	if not SF.Permissions.hasAccess(SF.instance.player,  nil, "hologram.create") then return false end
	return plyCount[SF.instance.player] < SF.Holograms.personalquota:GetInt()
end

--- Checks how many holograms can be spawned
-- @server
-- @return number of holograms able to be spawned
function holograms_library.hologramsLeft ()
	if not SF.Permissions.hasAccess(SF.instance.player,  nil, "hologram.create") then return 0 end
	return SF.Holograms.personalquota:GetInt() - plyCount[SF.instance.player]
end
